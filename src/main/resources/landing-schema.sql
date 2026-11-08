-- ============================================================
-- Landing page (com.menuscanner.landing) — client enquiries
-- Run after schema.sql. Safe to re-run (IF NOT EXISTS).
-- Timestamps are IST wall-clock, like review-schema.sql.
-- ============================================================

CREATE TABLE IF NOT EXISTS landing_enquiries (
    id            BIGSERIAL      PRIMARY KEY,
    name          VARCHAR(100)   NOT NULL,
    phone         VARCHAR(20)    NOT NULL,
    business_name VARCHAR(200),
    interest      VARCHAR(30),                 -- MENU_QR | REVIEW_QR | CUSTOM | OTHER
    message       VARCHAR(1000),
    status        VARCHAR(20)    DEFAULT 'NEW' NOT NULL,   -- NEW | CONTACTED
    visitor_hash  VARCHAR(64),                 -- SHA-256 of IP + User-Agent, for rate limiting only
    created_at    TIMESTAMP      DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    CONSTRAINT ck_enquiry_status CHECK (status IN ('NEW', 'CONTACTED'))
);

CREATE INDEX IF NOT EXISTS idx_enquiries_created ON landing_enquiries (created_at DESC);

-- ── Client feedback (shown in the rotating strip on the landing page) ──
-- Published as submitted (no editing). is_visible lets the admin hide spam/abuse.
CREATE TABLE IF NOT EXISTS landing_feedback (
    id            BIGSERIAL      PRIMARY KEY,
    person_name   VARCHAR(100)   NOT NULL,
    shop_name     VARCHAR(200)   NOT NULL,
    location      VARCHAR(120),
    product       VARCHAR(30)    NOT NULL,     -- MENU_QR | REVIEW_QR | CUSTOM
    comment       VARCHAR(600)   NOT NULL,
    is_visible    SMALLINT       DEFAULT 1 NOT NULL,
    visitor_hash  VARCHAR(64),                 -- SHA-256 of IP + User-Agent, for rate limiting only
    created_at    TIMESTAMP      DEFAULT (NOW() AT TIME ZONE 'Asia/Kolkata') NOT NULL,
    CONSTRAINT ck_feedback_product CHECK (product IN ('MENU_QR', 'REVIEW_QR', 'CUSTOM'))
);

CREATE INDEX IF NOT EXISTS idx_feedback_visible ON landing_feedback (is_visible, created_at DESC);
