# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy

```bash
# Build WAR
mvn clean package

# Output: target/menu-scanner.war
# Deploy by copying to <tomcat-home>/webapps/ or via IntelliJ Smart Tomcat plugin
```

Tomcat 10 (Jakarta EE 10) is required. The project uses Jakarta namespaces (`jakarta.servlet.*`), not `javax.servlet.*`.

## Tech Stack

- **Backend:** Java 17, Jakarta Servlet 6.0 + JSP (no Spring/frameworks)
- **Database:** PostgreSQL 15+ via HikariCP connection pool (10 max connections)
- **Cache:** Redis via Jedis — menu JSON cached at `menu:{restaurantId}` with 1-hour TTL
- **Templates:** JSP files in `src/main/webapp/WEB-INF/views/` (protected) and `src/main/webapp/public/` (open)

## Configuration

Copy `src/main/resources/application.properties` and set:
- PostgreSQL JDBC URL (`jdbc:postgresql://localhost:5432/menuscanner`), username, password
- Redis host (default `localhost:6379`)
- External image upload directory (survives WAR redeployment)
- App base URL (used for QR code generation)

PostgreSQL setup:
```sql
CREATE USER menuscanner WITH PASSWORD 'your_password';
CREATE DATABASE menuscanner OWNER menuscanner;
```

Run `src/main/resources/schema.sql` against the PostgreSQL instance to create all 6 tables.

## Architecture

### Request Lifecycle

1. **`AuthFilter`** (`filter/`) — intercepts every request; allows public paths (`/login`, `/menu`, `/lead-capture`, `/public/*`, `/images/*`, static assets); blocks unauthenticated access to everything else
2. **Servlets** (`servlet/`) — one per route, annotation-mapped (`@WebServlet`); extract `restaurantId` from session, delegate to DAOs
3. **DAOs** (`dao/`) — `DBConnection` singleton provides pooled PostgreSQL connections; all queries use `PreparedStatement`
4. **Models** (`model/`) — plain POJOs: `Restaurant`, `MenuItem`, `Customer`, `Campaign`, `Category`
5. **Utils** (`util/`) — `RedisCache` (menu caching), `PasswordUtil` (BCrypt cost 12), `QRGenerator` (ZXing PNG), `ImageProcessor` (Thumbnailator resize), `PlanConfig` (plan feature flags)

### Key Data Flows

- **Menu display:** `LeadCaptureServlet` checks Redis first; on cache miss, queries DB and writes JSON to Redis with 1-hour TTL. Any menu edit (add/update/delete) calls `RedisCache.invalidate(restaurantId)`.
- **Authentication:** BCrypt-validated in `RestaurantDAO`; session stores `restaurantId` and `slug`.
- **Image upload:** Magic bytes validated, file resized via Thumbnailator, saved to the external directory from config (not inside the WAR).
- **Plan enforcement:** `PlanConfig` gates features — BASIC plan caps at 50 menu items; campaigns and analytics are PRO-only. Check plan before writing new feature-gated code.

### Routes (from `web.xml` + servlet annotations)

| Path | Access |
|---|---|
| `/login`, `/register` | Public |
| `/menu` | Public (QR landing, by `?slug=`) |
| `/lead-capture` | Public (customer data capture) |
| `/dashboard`, `/menu-items`, `/categories`, `/campaigns`, `/analytics`, `/qr-code`, `/profile` | Auth required |

Error pages (404/403/500) route to `/public/error.jsp`.

### Product 2 — Google Review Scanner (`com.menuscanner.review`)

A separate product in the same WAR, kept in its own package (`review/model`, `review/dao`, `review/servlet`) and its own views folder (`WEB-INF/views/review/`). It does not depend on Product 1's restaurant accounts.

- **Dynamic QR stickers:** each scanner has a sticker number (`#001`, which is the `id`) and a random 6-char `code`. The QR encodes `{app.base.url}/s/{code}`. Stickers are printed first, and an admin assigns a business and its Google review URL later.
- **Links:** each scanner can have Google review, Instagram, Facebook, WhatsApp Channel and YouTube links (`ReviewPlatform` enum, which also validates and normalises pasted links).
  - **Order on the scan page** is set with ↑ ↓ by the super admin in the assign modal or by the owner under "Button order" in the dashboard's links form (`linkOrder`, saved with `saveLinks`) (`link_order`, e.g. `INSTAGRAM,VIP,GOOGLE,...`; NULL = VIP box on top, then enum order). `VIP` is the VIP Club / rewards box (`_vip-box.jspf`) and `WIFI` the guest WiFi button; the choose page loops over `ReviewScanner.getDisplayKeys()`.
  - **Guest WiFi** (`wifi_name`, `wifi_password`; empty password = open network): set in the admin assign modal or by the owner in the dashboard's links form. The button opens a sheet with the name, password and Copy buttons (a web page cannot join WiFi by itself). The tap is counted via `GET /s/{code}/go/wifi` (204) as a `WIFI` row in `review_clicks`, shown to the owner as "WiFi details opened N times", not in the app trips. `ReviewScanner.getLinks()` returns links in that order, so the choose page, the admin table and the single-link redirect all follow it. Unassign resets it.
- **`/s/{code}`** (public, whitelisted in `AuthFilter`): handling depends on the scanner's state.
  - Assigned and active with **one** link: records the scan and sends a **302** redirect straight to that link.
  - Assigned and active with **two or more** links: shows `choose-app.jsp`. Each button goes through `/s/{code}/go/{platform}`, which records a click in `review_clicks` and then sends a 302 redirect.
  - If the sticker's **join form** is on (`join_form`, the default for new assignments), the choose page is always shown, even for one link. Its "Join our VIP Club" box sits at the top, and its form (name, age, gender, mobile) POSTs to `/s/{code}/join`. That stores one row per phone per sticker in `review_contacts` for later WhatsApp offers. The owner sees the list in the dashboard's "VIP Club" tab and can download it as CSV.
    - In that tab the owner can **add a VIP by hand** (`action=addContact`; an existing phone is left untouched) and **send offers**: tick rows (or Select all) → Next → write the message (`{name}` = first name) → Confirm → a queue of `wa.me/91…?text=` links sent one tap at a time from the owner's own WhatsApp. It costs nothing and uses no API. Confirm saves the offer (`action=startBroadcast`, JSON) in `review_broadcasts` + `review_broadcast_recipients`, and each Send tap sets `sent_at` (`action=markSent`). The last 20 offers show under "Offers sent", where Open resumes an unfinished one.
    - **Photo on an offer:** `wa.me` links carry text only, so "📎 Add photo" uploads to `/review/offer-image` (`{images dir}/offers/{scannerId}/{uuid}.jpg`, max 1080px). The offer then gets a public `code`, and each message ends with a link to `/o/{code}` (public, whitelisted in `AuthFilter`). That page's `og:image` makes WhatsApp show the photo as a preview card; `{name}` reads "there" on it.
  - The scan page, the unassigned/paused page and the offer page end with "The Socio Advert", with "Powered by Bijwala Solutions" on the line below. The scan page does not show the sticker number (the unassigned page still does, so the sticker can be identified); the owner dashboard shows it as "Your scanner unique ID #NNN" under the greeting.
  - Never use 301, because browsers cache it and the target URL can change.
  - Unassigned: shows a sales page. Paused: shows a neutral page.
  - `?preview=1`: nothing is counted.
- **Owner dashboard:** the login page is `/review/login` (phone and password, `review_owners`). The login is created from the admin assign form, where the same phone means the same login. `/review/*` is guarded by `ReviewOwnerAuthFilter`.
  - `/review/dashboard` has two tabs: analytics (built with CSS bars, no chart library) and links/password.
  - Owners can only update scanners where `owner_id` matches their own.
- **Rewards (stamp card + scratch card):** off for every sticker until the super admin ticks them in the admin row's "🎁 Features" (`stamp_allowed`, `scratch_allowed`, optional `geo_check` with `shop_lat`/`shop_lng`, ~150 m). The owner sets them up in the dashboard's "🎁 Rewards" tab (`rw*` POST actions). When a reward is live, the scan page's VIP box becomes a "Collect your stamp / Scratch & win" link to `/rw/{code}` (`ReviewRewardsServlet`, public, whitelisted as `/rw/`).
  - **Number check without SMS:** the customer taps "Verify with WhatsApp", which opens `wa.me/{review.wa.number}?text=VERIFY <token>`; Meta's WhatsApp Cloud API posts the message to `/wa/webhook` (`WhatsAppWebhookServlet`, signature-checked with `review.wa.appSecret`), and the sender's number becomes the verified phone for that browser's token (`review_verifications`, 15 min). A signed cookie (`review.rewards.secret`) remembers the number on that phone for 180 days. Nothing shows to customers until `ReviewConfig.waVerifyReady()`. One WhatsApp number (ours) serves every client; clients need no WhatsApp Business account. The Meta app's privacy policy URL is the static `public/privacy.html` (data deletion: `#delete`).
  - **Stamp:** one per phone per IST day (`review_stamps`, unique per day; "You've already collected today's stamp ✅"). A full card stops adding stamps; the owner's "Give reward" sets `redeemed_at` and the card starts from 0.
  - **Scratch:** one per phone per IST day (`review_scratch_plays`). AMOUNT mode: slabs (amount × count, min bill); the customer types the bill, a win needs `win_percent` (default 40) and a slab with prizes left whose min bill is reached, weighted by prizes left; `remaining` drops in the same transaction, so the budget can't be overspent. When it runs out everyone sees "Better luck next time" until the owner starts a new campaign. OFFER mode: always shows one random offer text. Wins get a 6-char code the owner claims once in the Rewards tab.
  - The rewards form also saves the customer to `review_contacts` (VIP Club). Stamps/scratches before `assigned_at` are ignored, and unassign resets the features.
- **Super admin view:** `/admin/review-view?scanner={id}` (`ReviewAdminDashboardServlet`, guarded by `AdminAuthFilter`) shows any assigned sticker's owner dashboard read-only: analytics, VIP Club list + CSV, offers sent, links. It reuses `ReviewOwnerDashboardServlet.render` and the same JSP with `adminView` set, which hides every form; its POST returns 403. Customer phone numbers are masked there (last 4 digits shown as XXXX, also in its CSV) and the offer recipients' numbers are not sent to the page. Opened from "👁 Dashboard" on each admin row or "Client dashboards".
- **Admin:** `/admin/review-scanners` (create, assign, pause, unassign, QR, monthly WhatsApp report) and `/admin/review-scanners/print`. Both are guarded by `AdminAuthFilter`.
- **Scan counting:** the same visitor (SHA-256 of IP + User-Agent) within 30 min counts once. Bots and link-preview user agents and HEAD requests are not counted. Reports only count scans after `assigned_at`.
- **Timestamps are IST wall-clock** (`NOW() AT TIME ZONE 'Asia/Kolkata'`), because the server runs in UTC.
- **Schema:** `src/main/resources/review-schema.sql`. Run it after `schema.sql`.
- **Config:** `review.contact.name` and `review.contact.phone` (shown on the unassigned sales page).

### Landing page (`com.menuscanner.landing`)

This is the owner's public services/portfolio page. It lives in its own package and views folder (`WEB-INF/views/landing/`).

- **`/home`**: nginx serves it at the site root (`location = /` proxies to `/menu-scanner/home`), so the link to share is `https://<domain>/`.
- **`/enquiry`**: contact form POST. It uses a honeypot field (`website`) and allows at most 5 per visitor per hour. Results are stored in `landing_enquiries` (see `landing-schema.sql`).
- **`/contact.vcf`**: the "Save my contact" vCard.
- **`/admin/enquiries`**: the admin list, with a WhatsApp reply link and a "mark contacted" action.
- **`/feedback`**: the "Share feedback" dialog POST (name, shop, location, product, comment). It is published immediately and exactly as written. Limits: 3 per visitor per hour, plus a honeypot. Stored in `landing_feedback`.
  - The "What clients say" section is `hidden` when there is no visible feedback.
  - The strip only auto-rotates when the real cards are wider than the screen. It never pads the strip with repeated cards.
- **`/admin/feedback`**: hide/show/delete only. Feedback text is deliberately not editable.
- Owner details (name, phone, email, links, demo restaurant slug) are in `LandingProfile.java`. Edit them there.

## Important Constraints

- **No ORM** — all SQL is hand-written in DAOs with `PreparedStatement`. Keep it that way.
- **Session tracking is COOKIE-only** (`web.xml`) — URL session IDs are disabled.
- **External image directory** — images live outside the WAR; the config path must exist and be writable by Tomcat.
- **PostgreSQL dialect** — use PostgreSQL SQL syntax (e.g., `BIGSERIAL` for auto-increment IDs, `CURRENT_TIMESTAMP`, `TEXT` for long text). The `campaigns.message` column is `TEXT`.
