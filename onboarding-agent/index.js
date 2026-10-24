'use strict';
/**
 * Menu Scanner Onboarding Agent
 *
 * Usage:
 *   node index.js --email EMAIL --password PASSWORD --zomato-url "ZOMATO_URL" [--base-url BASE_URL]
 *
 * Example:
 *   node index.js \
 *     --email "restaurant@gmail.com" \
 *     --password "Admin1234" \
 *     --zomato-url "https://www.zomato.com/mumbai/some-restaurant/order" \
 *     --base-url "https://menuscanner.duckdns.org/menu-scanner"
 *
 * What it does:
 *   1. Scrapes all categories, items, veg flags, prices, and dish images from Zomato
 *   2. Logs into Menu Scanner with the given credentials
 *   3. Creates all unique categories
 *   4. Bulk uploads all items via CSV
 *   5. Uploads dish images (canvas-converted to JPEG) for every item that has one
 */

const puppeteer = require('puppeteer');
const fs        = require('fs');
const path      = require('path');

// ── CLI argument parsing ──────────────────────────────────────────────────────

const argv = process.argv.slice(2);
function arg(name) {
  const i = argv.indexOf('--' + name);
  return i !== -1 ? argv[i + 1] : null;
}

const EMAIL      = arg('email');
const PASSWORD   = arg('password');
const ZOMATO_URL = arg('zomato-url');
const BASE_URL   = (arg('base-url') || 'https://menuscanner.duckdns.org/menu-scanner').replace(/\/$/, '');

if (!EMAIL || !PASSWORD || !ZOMATO_URL) {
  console.error('');
  console.error('Usage:');
  console.error('  node index.js --email EMAIL --password PASSWORD --zomato-url "URL" [--base-url BASE_URL]');
  console.error('');
  process.exit(1);
}

// ── Step 1: Scrape Zomato ─────────────────────────────────────────────────────

async function scrapeZomato(page) {
  console.log('\n[1/5] Opening Zomato page...');
  await page.goto(ZOMATO_URL, { waitUntil: 'networkidle2', timeout: 60000 });

  // Wait for the menu sections to render
  try {
    await page.waitForSelector('.iGYweR', { timeout: 20000 });
  } catch {
    // Scroll half-way and retry — some pages need a scroll to trigger lazy render
    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight / 2));
    await delay(3000);
    await page.waitForSelector('.iGYweR', { timeout: 15000 });
  }

  // Scroll the full page slowly so all lazy images load
  console.log('[1/5] Scrolling to load lazy images...');
  await page.evaluate(async () => {
    await new Promise(resolve => {
      const step = 500;
      let y = 0;
      const id = setInterval(() => {
        window.scrollBy(0, step);
        y += step;
        if (y >= document.body.scrollHeight) { clearInterval(id); resolve(); }
      }, 150);
    });
  });
  await delay(2000);

  console.log('[1/5] Extracting menu data...');
  const items = await page.evaluate(() => {
    const result = [];
    const sections = document.querySelectorAll('.iGYweR');

    sections.forEach(sec => {
      const catEl = sec.querySelector('h4');
      if (!catEl) return;
      const catName = catEl.textContent.trim();

      sec.querySelectorAll('.sc-jhLVlY').forEach(card => {
        // Name
        const nameEl = card.querySelector('h4.sc-cdQEHs');
        if (!nameEl) return;
        const name = nameEl.textContent.trim().replace(/\.$/, '');

        // Veg / non-veg indicator
        const typeEl = card.querySelector('div[type]');
        const isVeg  = typeEl?.getAttribute('type') === 'veg' ? 'Y' : 'N';

        // Price — try several selectors Zomato uses
        let price = 0;
        const priceSelectors = [
          'span[class*="sc-"][class*="Price"]',
          'span[class*="price"]',
          '[class*="itemPrice"]',
          '[class*="rupee"]',
          'span.sc-17hyc2s-1',
        ];
        for (const sel of priceSelectors) {
          const el = card.querySelector(sel);
          if (el) {
            const text = el.textContent.replace(/[^0-9.]/g, '').trim();
            if (text) { price = parseFloat(text) || 0; break; }
          }
        }
        // Fallback: find any text node that starts with ₹
        if (!price) {
          const all = card.querySelectorAll('*');
          for (const el of all) {
            const t = el.childNodes;
            for (const node of t) {
              if (node.nodeType === 3 && node.textContent.includes('₹')) {
                const m = node.textContent.match(/₹\s*([\d,]+)/);
                if (m) { price = parseFloat(m[1].replace(/,/g, '')) || 0; break; }
              }
            }
            if (price) break;
          }
        }

        // Dish image (full-res URL without query params)
        const imgEl  = card.querySelector('img[src*="dish_photos"]');
        const imgUrl = imgEl ? imgEl.src.replace(/\?.*/, '') : '';

        result.push({ name, category: catName, isVeg, price, imgUrl });
      });
    });

    return result;
  });

  const cats = [...new Set(items.map(i => i.category))];
  console.log(`[1/5] Done — ${items.length} items in ${cats.length} categories`);
  fs.writeFileSync(path.join(__dirname, 'scraped.json'), JSON.stringify(items, null, 2));
  console.log('      (raw data saved to scraped.json)');
  return items;
}

// ── Step 2: Login ─────────────────────────────────────────────────────────────

async function login(page) {
  console.log('\n[2/5] Logging into Menu Scanner...');
  await page.goto(`${BASE_URL}/login`, { waitUntil: 'networkidle2' });
  await page.type('input[name="email"]',    EMAIL,    { delay: 40 });
  await page.type('input[name="password"]', PASSWORD, { delay: 40 });
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 30000 }),
    page.click('button[type="submit"]'),
  ]);
  if (page.url().includes('/login')) {
    throw new Error('Login failed — check email and password');
  }
  console.log('[2/5] Logged in successfully');
}

// ── Step 3: Create categories ─────────────────────────────────────────────────

async function createCategories(page, items) {
  const cats = [...new Set(items.map(i => i.category))].filter(Boolean);
  console.log(`\n[3/5] Creating ${cats.length} categories...`);

  await page.goto(`${BASE_URL}/menu-items`, { waitUntil: 'networkidle2' });

  // Read existing categories to skip duplicates
  const existing = await page.evaluate(() =>
    [...document.querySelectorAll('.mm-cat-chip')]
      .map(el => el.textContent.replace('×', '').trim())
  );

  let created = 0;
  for (const cat of cats) {
    if (existing.includes(cat)) {
      console.log(`      skip "${cat}" (already exists)`);
      continue;
    }
    // POST via fetch inside the page (carries the session cookie automatically)
    const ok = await page.evaluate(async (base, catName) => {
      const fd = new FormData();
      fd.append('action', 'add');
      fd.append('name', catName);
      try {
        await fetch(base + '/categories', { method: 'POST', body: fd, credentials: 'include' });
        return true;
      } catch { return false; }
    }, BASE_URL, cat);

    console.log(`      ${ok ? '+' : 'FAIL'} "${cat}"`);
    if (ok) created++;
    await delay(250); // small pause between POSTs
  }
  console.log(`[3/5] Categories: ${created} created, ${cats.length - created} skipped`);
}

// ── Step 4: Bulk upload items ─────────────────────────────────────────────────

function buildCsv(items) {
  const esc = v => {
    const s = String(v ?? '');
    return (s.includes(',') || s.includes('"') || s.includes('\n'))
      ? `"${s.replace(/"/g, '""')}"` : s;
  };

  // Column names must match exactly what BulkUploadServlet.parseCsv() expects
  const header = 'Dish Identity,Category,Actual Price,Discount (optional),Display Order,Description,Veg (Y/N),Available (Y/N)';
  const rows   = items.map((it, i) =>
    [it.name, it.category, it.price || 0, 0, i, '', it.isVeg, 'Y'].map(esc).join(',')
  );
  return [header, ...rows].join('\r\n');
}

async function bulkUpload(page, csv) {
  console.log('\n[4/5] Bulk uploading menu items...');
  await page.goto(`${BASE_URL}/menu-items`, { waitUntil: 'networkidle2' });

  const result = await page.evaluate(async (csvStr, base) => {
    const file = new File([csvStr], 'menu.csv', { type: 'text/csv' });
    const fd   = new FormData();
    fd.append('bulkFile', file);
    try {
      const r = await fetch(base + '/bulk-upload', { method: 'POST', body: fd, credentials: 'include' });
      return r.json();
    } catch (e) {
      return { error: e.message };
    }
  }, csv, BASE_URL);

  if (result.error) {
    throw new Error('Bulk upload rejected: ' + result.error);
  }
  if (result.errors && result.errors.length > 0) {
    console.error('      Validation errors from server:');
    result.errors.slice(0, 10).forEach(e => console.error(`        row ${e.row} [${e.col}]: ${e.msg}`));
    throw new Error(`Bulk upload had ${result.errors.length} validation error(s) — nothing was saved`);
  }

  console.log(`[4/5] Inserted ${result.inserted} items`);
  return result.inserted;
}

// ── Step 5: Upload images ─────────────────────────────────────────────────────

async function extractIdMap(page) {
  await page.goto(`${BASE_URL}/menu-items`, { waitUntil: 'networkidle2' });
  // #uploadItemId is the image-upload select dropdown; each option has value=itemId, text=itemName
  const map = await page.evaluate(() => {
    const sel = document.querySelector('#uploadItemId');
    if (!sel) return {};
    const m = {};
    [...sel.options].forEach(opt => { if (opt.value) m[opt.textContent.trim()] = parseInt(opt.value); });
    return m;
  });
  console.log(`      ID map: ${Object.keys(map).length} items`);
  return map;
}

async function uploadImages(page, items, idMap) {
  const pairs = items
    .filter(it => it.imgUrl)
    .map(it => ({ id: idMap[it.name], url: it.imgUrl }))
    .filter(p => p.id != null);

  const noId = items.filter(it => it.imgUrl && idMap[it.name] == null).map(i => i.name);
  if (noId.length) console.log(`      ${noId.length} items with images had no ID match (name mismatch)`);

  console.log(`\n[5/5] Uploading ${pairs.length} dish images (batches of 3)...`);
  await page.goto(`${BASE_URL}/menu-items`, { waitUntil: 'networkidle2' });

  const { ok, fail } = await page.evaluate(async (PAIRS, base) => {
    let ok = 0, fail = 0;

    async function uploadOne(itemId, imgUrl) {
      try {
        const imgResp = await fetch(imgUrl);
        if (!imgResp.ok) { fail++; return; }
        const blob = await imgResp.blob();
        const bmp  = await createImageBitmap(blob);

        const canvas = document.createElement('canvas');
        canvas.width = 800; canvas.height = 800;
        const ctx = canvas.getContext('2d');
        const s  = Math.min(bmp.width, bmp.height);
        const sx = (bmp.width  - s) / 2;
        const sy = (bmp.height - s) / 2;
        ctx.drawImage(bmp, sx, sy, s, s, 0, 0, 800, 800);

        const jpegBlob = await new Promise(r => canvas.toBlob(r, 'image/jpeg', 0.88));
        const fd = new FormData();
        fd.append('image',  new File([jpegBlob], 'dish.jpg', { type: 'image/jpeg' }));
        fd.append('itemId', String(itemId));

        const r = await fetch(base + '/upload-image', { method: 'POST', body: fd, credentials: 'include' });
        const j = await r.json();
        if (j.path) ok++; else fail++;
      } catch { fail++; }
    }

    for (let i = 0; i < PAIRS.length; i += 3) {
      const batch = PAIRS.slice(i, i + 3);
      await Promise.all(batch.map(p => uploadOne(p.id, p.url)));
      await new Promise(r => setTimeout(r, 500));
    }
    return { ok, fail };
  }, pairs, BASE_URL);

  console.log(`[5/5] Images: ${ok} uploaded, ${fail} failed`);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function delay(ms) { return new Promise(r => setTimeout(r, ms)); }

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  console.log('====================================');
  console.log(' Menu Scanner Onboarding Agent');
  console.log('====================================');
  console.log(`Email:      ${EMAIL}`);
  console.log(`Zomato URL: ${ZOMATO_URL}`);
  console.log(`Target:     ${BASE_URL}`);

  const browser = await puppeteer.launch({
    headless: false,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-http2'],
  });

  try {
    const page = await browser.newPage();
    page.setDefaultNavigationTimeout(60000);

    // 1. Scrape
    const items = await scrapeZomato(page);
    if (items.length === 0) throw new Error('No items scraped — check the Zomato URL');

    // 2. Login
    await login(page);

    // 3. Categories
    await createCategories(page, items);

    // 4. Build CSV + bulk upload
    const csv = buildCsv(items);
    fs.writeFileSync(path.join(__dirname, 'menu.csv'), csv);
    console.log('      (CSV saved to menu.csv)');
    await bulkUpload(page, csv);

    // Wait a moment for DB to settle
    await delay(2000);

    // 5. Images — need DB IDs first
    const idMap = await extractIdMap(page);
    await uploadImages(page, items, idMap);

    console.log('\n====================================');
    console.log(' Onboarding complete!');
    console.log(`Public menu: ${BASE_URL.replace('/menu-scanner', '')}/menu-scanner/menu?slug=<slug>`);
    console.log('====================================\n');

  } finally {
    await browser.close();
  }
}

main().catch(err => {
  console.error('\nFatal:', err.message);
  process.exit(1);
});
