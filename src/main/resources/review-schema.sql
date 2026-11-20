-- ============================================================
-- Product 2 — Google Review Scanner
-- Pre-printed "dynamic" QR stickers. Each sticker encodes /s/{code};
-- the admin later maps the scanner to a business's Google review URL.
--
-- Run after schema.sql. Safe to re-run (IF NOT EXISTS).
-- All timestamps are stored as IST wall-clock time (NOW() AT TIME ZONE 'Asia/Kolkata')
-- so monthly reports and "busiest time" match what restaurant owners see.
-- ============================================================

-- ── 1. review_scanners ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS review_scanners (
    id                BIGSERIAL      PRIMARY KEY,   -- printed on the sticker as #001
    code              VARCHAR(12)    NOT NULL,      -- random code inside the QR: /s/{code}
    business_name     VARCHAR(200),                 -- NULL = not assigned yet
    owner_phone       VARCHAR(15),
    google_review_url VARCHAR(500),
    is_active         SMALLINT       DEFAULT 1 NOT NULL,
    assigned_at       TIMESTAMP,                    -- reports only count scans after this
    created_at        TIMESTAMP      DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    CONSTRAINT uq_review_scanners_code UNIQUE (code)
);

-- ── 2. review_scans ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS review_scans (
    id            BIGSERIAL     PRIMARY KEY,
    scanner_id    BIGINT        NOT NULL,
    scanned_at    TIMESTAMP     DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    visitor_hash  VARCHAR(64),  -- SHA-256 of IP + User-Agent; used only to de-duplicate repeat scans
    CONSTRAINT fk_review_scans_scanner FOREIGN KEY (scanner_id) REFERENCES review_scanners(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_review_scans_scanner ON review_scans (scanner_id, scanned_at);

-- ============================================================
-- v2 — owner logins, social links, per-app click tracking
-- ============================================================

-- ── 3. review_owners ────────────────────────────────────────
-- A business owner's login for /review/dashboard. One owner can own several
-- stickers (e.g. counter + reception); the admin creates the login.
CREATE TABLE IF NOT EXISTS review_owners (
    id             BIGSERIAL     PRIMARY KEY,
    phone          VARCHAR(10)   NOT NULL,          -- 10-digit Indian mobile, used as the username
    password_hash  VARCHAR(100)  NOT NULL,          -- BCrypt
    created_at     TIMESTAMP     DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    last_login_at  TIMESTAMP,
    CONSTRAINT uq_review_owners_phone UNIQUE (phone)
);

-- ── 4. extra links on each scanner ──────────────────────────
-- One configured link → the scan redirects straight to it.
-- Two or more        → the scan shows a "choose an app" page.
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS instagram_url VARCHAR(500);
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS facebook_url  VARCHAR(500);
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS youtube_url   VARCHAR(500);
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS owner_id      BIGINT
    REFERENCES review_owners(id) ON DELETE SET NULL;

-- ── 5. review_clicks ────────────────────────────────────────
-- Which app the customer went to. A scan (review_scans) is one visit to the sticker;
-- a click is one trip to Google / Instagram / Facebook / YouTube from it.
CREATE TABLE IF NOT EXISTS review_clicks (
    id            BIGSERIAL     PRIMARY KEY,
    scanner_id    BIGINT        NOT NULL,
    platform      VARCHAR(20)   NOT NULL,
    clicked_at    TIMESTAMP     DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    visitor_hash  VARCHAR(64),
    CONSTRAINT fk_review_clicks_scanner FOREIGN KEY (scanner_id) REFERENCES review_scanners(id) ON DELETE CASCADE,
    CONSTRAINT chk_review_clicks_platform CHECK (platform IN ('GOOGLE', 'INSTAGRAM', 'FACEBOOK', 'YOUTUBE'))
);

CREATE INDEX IF NOT EXISTS idx_review_clicks_scanner ON review_clicks (scanner_id, clicked_at);

-- Before v2 every counted scan was redirected straight to Google, so carry those over
-- as Google clicks. Runs only while review_clicks is still empty.
INSERT INTO review_clicks (scanner_id, platform, clicked_at, visitor_hash)
SELECT scanner_id, 'GOOGLE', scanned_at, visitor_hash FROM review_scans
WHERE NOT EXISTS (SELECT 1 FROM review_clicks);

-- ============================================================
-- v3 — "Join our club" form on the scan page (customer list for WhatsApp offers)
-- ============================================================

-- ── 6. join form switch ─────────────────────────────────────
-- When on, the scan page is always shown (even with one link) so the form can be.
-- Stickers that existed before v3 keep their old behaviour (off); new ones get it on.
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS join_form BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE review_scanners ALTER COLUMN join_form SET DEFAULT TRUE;

-- ── 7. review_contacts ──────────────────────────────────────
-- Customers who filled the form. One row per phone per sticker; filling it again updates the row.
CREATE TABLE IF NOT EXISTS review_contacts (
    id                BIGSERIAL     PRIMARY KEY,
    scanner_id        BIGINT        NOT NULL,
    name              VARCHAR(100)  NOT NULL,
    age               SMALLINT,
    gender            VARCHAR(10),
    phone             VARCHAR(10)   NOT NULL,       -- 10-digit Indian mobile
    consent_whatsapp  BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP     DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    updated_at        TIMESTAMP     DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    CONSTRAINT fk_review_contacts_scanner FOREIGN KEY (scanner_id) REFERENCES review_scanners(id) ON DELETE CASCADE,
    CONSTRAINT uq_review_contacts_phone UNIQUE (scanner_id, phone)
);

CREATE INDEX IF NOT EXISTS idx_review_contacts_scanner ON review_contacts (scanner_id, created_at);

-- ── 8. owner name ───────────────────────────────────────────
-- Shown as "Hi Iqbal" on the dashboard. Optional; set from the admin assign form.
ALTER TABLE review_owners ADD COLUMN IF NOT EXISTS name VARCHAR(100);

-- ── 9. WhatsApp Channel link ────────────────────────────────
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS whatsapp_url VARCHAR(500);
ALTER TABLE review_clicks DROP CONSTRAINT IF EXISTS chk_review_clicks_platform;
ALTER TABLE review_clicks ADD CONSTRAINT chk_review_clicks_platform
    CHECK (platform IN ('GOOGLE', 'INSTAGRAM', 'FACEBOOK', 'WHATSAPP', 'YOUTUBE'));

-- ── 10. WhatsApp offer history ──────────────────────────────
-- One row per offer the owner sends from the VIP Club tab (the message as typed, with {name}).
CREATE TABLE IF NOT EXISTS review_broadcasts (
    id          BIGSERIAL  PRIMARY KEY,
    scanner_id  BIGINT     NOT NULL REFERENCES review_scanners(id) ON DELETE CASCADE,
    message     TEXT       NOT NULL,
    created_at  TIMESTAMP  DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_review_broadcasts_scanner ON review_broadcasts (scanner_id, created_at);

-- Who the offer was for. sent_at is set when the owner taps "Send" (WhatsApp then opens on their phone).
CREATE TABLE IF NOT EXISTS review_broadcast_recipients (
    broadcast_id  BIGINT        NOT NULL REFERENCES review_broadcasts(id) ON DELETE CASCADE,
    phone         VARCHAR(10)   NOT NULL,
    name          VARCHAR(100)  NOT NULL,
    sent_at       TIMESTAMP,
    PRIMARY KEY (broadcast_id, phone)
);

-- ── 11. Photo on a WhatsApp offer ───────────────────────────
-- WhatsApp click-to-chat links carry text only, so a photo goes as a link to a public
-- offer page (/o/{code}); WhatsApp shows that page's og:image as a big preview card.
ALTER TABLE review_broadcasts ADD COLUMN IF NOT EXISTS image_path VARCHAR(200);   -- under the images dir, e.g. offers/12/<uuid>.jpg
ALTER TABLE review_broadcasts ADD COLUMN IF NOT EXISTS code       VARCHAR(12);    -- only set when there is a photo
CREATE UNIQUE INDEX IF NOT EXISTS uq_review_broadcasts_code ON review_broadcasts (code);

-- ── 12. Rewards: digital stamp card + scratch card ──────────
-- Both are off for every sticker until the super admin allows them (Features on the admin page).
-- Customers prove their number by sending "VERIFY <token>" to our WhatsApp Business number
-- (review_verifications); the WhatsApp Cloud API webhook (/wa/webhook) marks the token verified.
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS stamp_allowed   BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS scratch_allowed BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS geo_check       BOOLEAN NOT NULL DEFAULT FALSE;   -- customer must be near the shop
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS shop_lat        DOUBLE PRECISION;
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS shop_lng        DOUBLE PRECISION;

CREATE TABLE IF NOT EXISTS review_verifications (
    token        VARCHAR(8)   PRIMARY KEY,           -- what the customer sends: "VERIFY K7P2QX"
    scanner_id   BIGINT       NOT NULL REFERENCES review_scanners(id) ON DELETE CASCADE,
    browser_key  VARCHAR(64)  NOT NULL,              -- kept in the customer's session; only that browser can use the result
    phone        VARCHAR(10),                        -- set by the webhook from the WhatsApp sender
    verified_at  TIMESTAMP,
    created_at   TIMESTAMP    DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_review_verifications_created ON review_verifications (created_at);

-- Stamp card settings, one per sticker
CREATE TABLE IF NOT EXISTS review_stamp_programs (
    scanner_id     BIGINT        PRIMARY KEY REFERENCES review_scanners(id) ON DELETE CASCADE,
    stamps_needed  SMALLINT      NOT NULL CHECK (stamps_needed BETWEEN 2 AND 50),
    reward         VARCHAR(150)  NOT NULL,
    active         BOOLEAN       NOT NULL DEFAULT TRUE,
    updated_at     TIMESTAMP     DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL
);

-- One stamp per phone per sticker per day. redeemed_at is set on all of a card's stamps when
-- the owner gives the reward, so the card starts again from 0.
CREATE TABLE IF NOT EXISTS review_stamps (
    id           BIGSERIAL    PRIMARY KEY,
    scanner_id   BIGINT       NOT NULL REFERENCES review_scanners(id) ON DELETE CASCADE,
    phone        VARCHAR(10)  NOT NULL,
    stamped_on   DATE         NOT NULL,
    created_at   TIMESTAMP    DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    redeemed_at  TIMESTAMP,
    CONSTRAINT uq_review_stamps_day UNIQUE (scanner_id, phone, stamped_on)
);
CREATE INDEX IF NOT EXISTS idx_review_stamps_open ON review_stamps (scanner_id, phone) WHERE redeemed_at IS NULL;

-- A scratch-card campaign. AMOUNT: prizes come from slabs until they run out.
-- OFFER: every scratch shows one of the owner's offer texts. Only one active campaign per sticker;
-- the owner starts a new one by hand when the budget is used up.
CREATE TABLE IF NOT EXISTS review_scratch_campaigns (
    id           BIGSERIAL   PRIMARY KEY,
    scanner_id   BIGINT      NOT NULL REFERENCES review_scanners(id) ON DELETE CASCADE,
    mode         VARCHAR(10) NOT NULL CHECK (mode IN ('AMOUNT', 'OFFER')),
    win_percent  SMALLINT    NOT NULL DEFAULT 40 CHECK (win_percent BETWEEN 1 AND 100),
    active       BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP   DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    ended_at     TIMESTAMP
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_review_scratch_one_active ON review_scratch_campaigns (scanner_id) WHERE active;

-- AMOUNT mode: "₹50 off × 2, min bill ₹500". remaining goes down as customers win.
CREATE TABLE IF NOT EXISTS review_scratch_slabs (
    id           BIGSERIAL  PRIMARY KEY,
    campaign_id  BIGINT     NOT NULL REFERENCES review_scratch_campaigns(id) ON DELETE CASCADE,
    amount       INT        NOT NULL CHECK (amount > 0),
    min_bill     INT        NOT NULL DEFAULT 0 CHECK (min_bill >= 0),
    total_count  INT        NOT NULL CHECK (total_count > 0),
    remaining    INT        NOT NULL CHECK (remaining >= 0)
);

-- OFFER mode texts
CREATE TABLE IF NOT EXISTS review_scratch_offers (
    id           BIGSERIAL     PRIMARY KEY,
    campaign_id  BIGINT        NOT NULL REFERENCES review_scratch_campaigns(id) ON DELETE CASCADE,
    text         VARCHAR(200)  NOT NULL
);

-- One scratch per phone per sticker per day. code is shown at the counter to claim a win.
CREATE TABLE IF NOT EXISTS review_scratch_plays (
    id           BIGSERIAL     PRIMARY KEY,
    scanner_id   BIGINT        NOT NULL REFERENCES review_scanners(id) ON DELETE CASCADE,
    campaign_id  BIGINT        NOT NULL REFERENCES review_scratch_campaigns(id) ON DELETE CASCADE,
    phone        VARCHAR(10)   NOT NULL,
    played_on    DATE          NOT NULL,
    bill_amount  INT,
    won          BOOLEAN       NOT NULL,
    slab_id      BIGINT        REFERENCES review_scratch_slabs(id) ON DELETE SET NULL,
    amount       INT,
    offer_text   VARCHAR(200),
    code         VARCHAR(8)    UNIQUE,
    redeemed_at  TIMESTAMP,
    created_at   TIMESTAMP     DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    CONSTRAINT uq_review_scratch_day UNIQUE (scanner_id, phone, played_on)
);
CREATE INDEX IF NOT EXISTS idx_review_scratch_plays_campaign ON review_scratch_plays (campaign_id, created_at);

-- ── 13. Link order on the scan page ──────────────────────────────────────────
-- Comma-separated platform names set by the super admin, e.g. 'INSTAGRAM,GOOGLE'.
-- NULL = the default order (Google, Instagram, Facebook, WhatsApp, YouTube).
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS link_order VARCHAR(100);

-- Guest WiFi shown on the scan page ("WIFI" in link_order); the owner can change it.
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS wifi_name     VARCHAR(64);
ALTER TABLE review_scanners ADD COLUMN IF NOT EXISTS wifi_password VARCHAR(64);
ALTER TABLE review_clicks DROP CONSTRAINT IF EXISTS chk_review_clicks_platform;
ALTER TABLE review_clicks ADD CONSTRAINT chk_review_clicks_platform
    CHECK (platform IN ('GOOGLE', 'INSTAGRAM', 'FACEBOOK', 'WHATSAPP', 'YOUTUBE', 'WIFI'));
