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
