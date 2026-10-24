Onboard a new restaurant into Menu Scanner by scraping their Zomato menu and importing everything automatically.

Arguments: $ARGUMENTS
(Pass them as: email=x@gmail.com password=Admin1234 zomato-url=https://www.zomato.com/... slug=restaurant-slug)

Parse the arguments from $ARGUMENTS. Extract: email, password, zomato-url (or zomatoUrl), slug (optional, for verification at the end), and base-url (default: https://menuscanner.duckdns.org/menu-scanner).

Then perform the following steps IN ORDER using your tools. Do not skip any step. Report progress after each step.

---

## Step 1 — Scrape Zomato

Use the Puppeteer MCP tool to:
1. Launch browser: `{ headless: false, args: ["--no-sandbox", "--disable-setuid-sandbox", "--disable-http2"] }` with `allowDangerous: true`
2. Navigate to the zomato-url
3. Wait 5 seconds for the page to load
4. Run this evaluate script to scroll the full page and load all lazy images:
```javascript
await new Promise(resolve => {
  const step = 500; let y = 0;
  const id = setInterval(() => {
    window.scrollBy(0, step); y += step;
    if (y >= document.body.scrollHeight) { clearInterval(id); resolve(); }
  }, 150);
});
```
5. Wait 2 more seconds
6. Run this evaluate script to extract ALL menu items:
```javascript
const result = [];
const sections = document.querySelectorAll('.iGYweR');
sections.forEach(sec => {
  const catEl = sec.querySelector('h4');
  if (!catEl) return;
  const catName = catEl.textContent.trim();
  sec.querySelectorAll('.sc-jhLVlY').forEach(card => {
    const nameEl = card.querySelector('h4.sc-cdQEHs');
    if (!nameEl) return;
    const name = nameEl.textContent.trim().replace(/\.$/, '');
    const typeEl = card.querySelector('div[type]');
    const isVeg = typeEl?.getAttribute('type') === 'veg' ? 'Y' : 'N';
    const imgEl = card.querySelector('img[src*="dish_photos"]');
    const imgUrl = imgEl ? imgEl.src.replace(/\?.*/, '') : '';
    let price = 0;
    const all = card.querySelectorAll('*');
    for (const el of all) {
      for (const node of el.childNodes) {
        if (node.nodeType === 3 && node.textContent.includes('₹')) {
          const m = node.textContent.match(/₹\s*([\d,]+)/);
          if (m) { price = parseFloat(m[1].replace(/,/g, '')) || 0; break; }
        }
      }
      if (price) break;
    }
    result.push({ name, category: catName, isVeg, price, imgUrl });
  });
});
return JSON.stringify(result);
```

Store the full scraped list. Report: how many items, how many categories, how many have images.

---

## Step 2 — Log into Menu Scanner

Still using the Puppeteer browser:
1. Navigate to `{base-url}/login`
2. Fill `input[name="email"]` with the email
3. Fill `input[name="password"]` with the password
4. Click `button[type="submit"]`
5. Wait for navigation
6. Confirm the URL no longer contains `/login` — if it does, stop and report login failure

---

## Step 3 — Create Categories

1. Navigate to `{base-url}/menu-items`
2. Evaluate to get existing categories:
```javascript
return JSON.stringify([...document.querySelectorAll('.mm-cat-chip')].map(el => el.textContent.replace('×','').trim()));
```
3. For each unique category from Step 1 that is NOT already in the existing list, run:
```javascript
const fd = new FormData();
fd.append('action', 'add');
fd.append('name', 'CATEGORY_NAME_HERE');
await fetch('{base-url}/categories', { method: 'POST', body: fd, credentials: 'include' });
return 'ok';
```
Wait 300ms between each category creation.

Report: how many categories created vs skipped.

---

## Step 4 — Bulk Upload Items via CSV

Build a CSV string with this exact header row:
```
Dish Identity,Category,Actual Price,Discount (optional),Display Order,Description,Veg (Y/N),Available (Y/N)
```

For each item from Step 1, add a row. Rules:
- Wrap any field that contains a comma in double-quotes
- price defaults to 0 if not scraped
- Discount (optional) = 0
- Display Order = row index (0-based)
- Description = empty
- Veg (Y/N) = Y or N from scrape
- Available (Y/N) = Y

Navigate to `{base-url}/menu-items`, then evaluate:
```javascript
const csv = `FULL_CSV_STRING_HERE`;
const file = new File([csv], 'menu.csv', { type: 'text/csv' });
const fd = new FormData();
fd.append('bulkFile', file);
const r = await fetch(contextPath + '/bulk-upload', { method: 'POST', body: fd, credentials: 'include' });
return JSON.stringify(await r.json());
```

Check the response:
- If `inserted > 0` → success, report count
- If `error` contains "Plan limit" → tell the user to upgrade the restaurant to PRO plan via PuTTY SQL: `UPDATE restaurants SET plan_type = 'PRO' WHERE email = 'EMAIL';` then re-run after they confirm
- If `errors` array → report the first few row errors and stop

---

## Step 5 — Upload Dish Images

1. Navigate to `{base-url}/menu-items`
2. Extract item ID → name map:
```javascript
const sel = document.querySelector('#uploadItemId');
const m = {};
[...sel.options].forEach(opt => { if (opt.value) m[opt.textContent.trim()] = parseInt(opt.value); });
return JSON.stringify(m);
```
3. Build an array of [itemId, imageUrl] pairs by matching item names to the ID map. Only include items that have an imgUrl.
4. Run the image upload script (process in batches of 3, 500ms between batches):
```javascript
const PAIRS = [[id1, 'url1'], [id2, 'url2'] /* ... all pairs ... */];
let ok = 0, fail = 0;
async function uploadOne(itemId, imgUrl) {
  try {
    const resp = await fetch(imgUrl);
    const blob = await resp.blob();
    const bmp = await createImageBitmap(blob);
    const canvas = document.createElement('canvas');
    canvas.width = 800; canvas.height = 800;
    const ctx = canvas.getContext('2d');
    const s = Math.min(bmp.width, bmp.height);
    ctx.drawImage(bmp, (bmp.width-s)/2, (bmp.height-s)/2, s, s, 0, 0, 800, 800);
    const jpegBlob = await new Promise(r => canvas.toBlob(r, 'image/jpeg', 0.88));
    const fd = new FormData();
    fd.append('image', new File([jpegBlob], 'dish.jpg', { type: 'image/jpeg' }));
    fd.append('itemId', String(itemId));
    const r = await fetch(contextPath + '/upload-image', { method: 'POST', body: fd, credentials: 'include' });
    const j = await r.json();
    if (j.path) ok++; else fail++;
  } catch { fail++; }
}
for (let i = 0; i < PAIRS.length; i += 3) {
  await Promise.all(PAIRS.slice(i, i+3).map(([id,url]) => uploadOne(id, url)));
  await new Promise(r => setTimeout(r, 500));
}
return JSON.stringify({ ok, fail, total: PAIRS.length });
```

Report the final ok/fail counts.

---

## Final Report

Summarize:
- Total items imported
- Total categories created
- Total images uploaded
- Public menu URL: `{base-url}/menu?slug={slug}` (if slug was provided)
- Any items that had no image
