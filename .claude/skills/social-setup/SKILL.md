---
name: social-setup
description: Guide the user step by step, one step at a time, while they create a client's Instagram account and Facebook Page by hand on the client's phone, after preparing the profile photo, cover, bio and first posts. Then save the new links on the client's review scanner. Use when the user says they are onboarding a client on Instagram/Facebook, "insta/fb account banana hai", or asks for the social-media setup steps.
---

# Social setup: Instagram + Facebook for a client

The user (Amaan) sits with the client and makes the accounts **by hand on the client's phone**. Your job:
1. Prepare everything in advance (images + copy-paste text).
2. Walk him through **one step per message**, in short Hinglish, and wait for "done"/"ho gaya" before the next step.
3. At the end, put the new links on the client's review scanner.

**Never create, log in to, or automate Instagram/Facebook accounts yourself** (no Puppeteer, no API signups). Meta bans bot-made accounts and links them to each other, so one ban can take down other clients. You only prepare the kit and give instructions.

## 0. Collect inputs (ask only for what is missing)

- Business name, area/city, full address
- Category (e.g. Hostel / Dormitory, Library / Study centre, Restaurant)
- Timings, and the phone number to show publicly
- Logo file (photo or image the user sends or a path). For existing clients, also check
  `C:\Users\Lenovo\OneDrive\Desktop\Acrylic-Stands\` for the stand image `<Name>_<sticker>_Stand_4x6.png`.
- Review scanner sticker number, if the client has one (e.g. #011)
- Google Maps link, if known
- Does the **owner already have a personal Facebook account** on this phone? (decides step 3A or 3B)

## 1. Prepare the kit (you do this before he starts)

Folder: `C:\Users\Lenovo\OneDrive\Desktop\Social-Kits\<Business-Name>\`

1. Images. Run this from the skill folder:
   ```
   python make_kit.py --name "<Business Name>" --logo "<logo path>" --tagline "<one line>" --out "<kit folder>" [--stand "<stand png>"]
   ```
   It writes `profile_1080.png`, `fb_cover_1640x624.png`, `post1_welcome_1080x1350.png`, and `post2_scan_qr_1080x1350.png` (only with `--stand`).
   **Open and look at the images** before going on. If the logo is a photo with a busy background, crop it first (use `ImageOps.exif_transpose` for phone photos).
2. Write `kit.md` in the same folder with the copy-paste text:
   - **Username ideas (5)**: lowercase, max 30 characters, only letters/numbers/`.`/`_`, e.g. `ribat_inn_dormitory`, `ribatinn.mumbai`, `ribatinn_jogeshwari`. Say which one to try first. Availability is checked in the app at step 2.6; do not scrape Instagram.
   - **Instagram name field** (max 64 chars; it is searchable, so add a keyword): `Ribat Inn Dormitory | Mumbai`
   - **Bio** (max 150 characters; count them), 3–4 short lines with emoji: what it is, area, timing or USP, then a call to action (e.g. `📲 Scan our QR & join the VIP Club`).
   - **Facebook Page**: name, category, "Intro" (max 101 chars), address, phone, hours, website = Google Maps link.
   - **Captions** for post 1 (welcome) and post 2 (scan the QR and join the VIP Club), each with 5–8 local hashtags (`#jogeshwari #mumbaihostel …`).
3. Send the kit to the user's phone (SendUserFile, if available: the images plus kit.md), and tell him the folder path.

## 2. Instagram (one step per message)

Tips to give once, at the start:
- Use the **client's mobile data, not shop/office WiFi**, and make only **one** new account per phone per day.
- Instagram may ask for a birthday: use the **owner's real one**, 18+.

Steps:
1. Install or open **Instagram**. If someone is already logged in: Profile → ☰ → **Add account → Create new account**.
2. **Mobile number** → enter the client's number → enter the **OTP** that arrives by SMS.
3. **Password**: pick one with the owner and note it down safely. Never paste it into this chat.
4. **Birthday** → owner's date of birth.
5. **Name** → paste the Instagram name from kit.md.
6. **Username** → try idea #1. If it is taken, try the next one. Tell me which one worked.
7. Skip "Find contacts", "Follow people" and "Save login info" if they slow things down (Save login is OK on the owner's own phone).
8. **Profile photo** → upload `profile_1080.png`.
9. **Edit profile → Bio** → paste the bio. **Links → Add external link** → Google Maps link (or skip).
10. **Switch to professional**: ☰ → *Account type and tools* → **Switch to professional account** → **Business** → pick the category → show the contact options (phone, address).
11. **First posts** (oldest first): post `post1_welcome` with its caption, then `post2_scan_qr` with its caption.
12. Ask him for the profile link (`https://www.instagram.com/<username>/`).

## 3. Facebook Page

Meta requires a **Page to belong to a real person's profile**. Never make a fake personal profile in the business's name.

**3A. The owner already has Facebook** (preferred)
1. Open Facebook (logged in as the owner) → ☰ Menu → **Pages** → **Create** (or "+ Create new Page").
2. **Page name** + **category** from kit.md → **Create Page**.
3. **Profile picture** → `profile_1080.png`. **Cover photo** → `fb_cover_1640x624.png`.
4. **Bio/Intro**, **contact** (phone, address, hours), **website** → from kit.md → **Done**.
5. Ask for the Page link. Open the Page → Share → Copy link (a `facebook.com/share/...` link is fine; the scanner accepts it).

**3B. The owner has no Facebook**
1. Install Facebook → **Create new account** with the **owner's real name**, the client's number, and the OTP.
2. Then follow 3A from step 1.

## 4. Link Instagram ↔ Facebook (optional, 1 minute)

Instagram → ☰ → **Accounts Centre** → **Accounts** → *Add accounts* → log in to the owner's Facebook. Then in Instagram: Edit profile → **Page** → connect the new Page. This lets posts be shared to both and unlocks Meta Business Suite.

## 5. Save the links on the review scanner

Only if the client has a review scanner sticker. Prod: `https://dinestack.duckdns.org/menu-scanner`.

1. **Read the scanner's current values first** (SSH + `psql`, read-only). Look up `business_name`, `owner_phone`, every link column, `join_form` and the owner's name. The admin `assign` action **overwrites every field**, so all existing values must be sent back unchanged.
2. **Show the user the before → after list and get a "yes"** before changing a live client's scanner.
3. Log in as admin with a cookie jar: `POST /admin/login` with `email` and `password`. The admin login is in the project memory, not here.
4. `POST /admin/review-scanners` with:
   - `action=assign`, `id`, `businessName`, `ownerPhone`, `ownerName`
   - `google`, `instagram`, `facebook`, `whatsapp`, `youtube`
   - `joinForm=1` if it was on
   - `loginPassword` **empty**, so the owner's password stays the same
5. Check the redirect says `success`. Then open `/s/<code>?preview=1` (preview does not count a scan) and confirm the new buttons are there.

## 6. Wrap up

- Tell him what is live: the Instagram URL, the Page URL, and the scanner buttons.
- Remind him: the owner should keep the password and turn on **two-factor authentication** (Accounts Centre → Password and security). Keep the phone number on the account, so the owner can always recover it.
- Do not save the client's passwords anywhere (not in memory, files or chat).

## When things go wrong

- **OTP not arriving**: wait 60 seconds, then "Resend". Check the client has DND or SMS blocking off. Or switch to email signup and add the phone later.
- **"Confirm you're human" / selfie video check**: let the owner do it. It is normal for new accounts.
- **Account suspended right after signup**: tap Appeal and follow the steps (usually a selfie video). Do **not** create another account on the same phone the same day.
- **Username taken**: add the area (`_jogeshwari`), `.mumbai`, or `official`.
- **Cannot switch to professional / no category**: update the Instagram app and try again later. It is not needed to go live.
