-- ============================================================
-- Menu Scanner — Oracle XE Schema
-- Requires Oracle 12c+ for GENERATED AS IDENTITY
-- Run as: menuscanner user (or a DBA who grants to menuscanner)
-- ============================================================

-- ── 1. restaurants ──────────────────────────────────────────
CREATE TABLE restaurants (
    id               NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             VARCHAR2(200)   NOT NULL,
    slug             VARCHAR2(100)   NOT NULL,
    email            VARCHAR2(150)   NOT NULL,
    password_hash    VARCHAR2(255)   NOT NULL,
    phone            VARCHAR2(15),
    plan_type        VARCHAR2(20)    DEFAULT 'BASIC' NOT NULL,  -- BASIC | PRO
    social_instagram VARCHAR2(255),
    social_facebook  VARCHAR2(255),
    social_youtube   VARCHAR2(255),
    social_twitter   VARCHAR2(255),
    created_at       TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    is_active        NUMBER(1)       DEFAULT 1 NOT NULL,
    CONSTRAINT uq_restaurants_slug  UNIQUE (slug),
    CONSTRAINT uq_restaurants_email UNIQUE (email),
    CONSTRAINT ck_plan_type         CHECK (plan_type IN ('BASIC', 'PRO'))
);

-- ── 2. menu_items ────────────────────────────────────────────
CREATE TABLE menu_items (
    id            NUMBER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_id NUMBER         NOT NULL,
    name          VARCHAR2(200)  NOT NULL,
    description   VARCHAR2(500),
    price         NUMBER(8,2)    DEFAULT 0 NOT NULL,
    category      VARCHAR2(50),
    image_path    VARCHAR2(255), -- relative: "{restaurant_id}/{uuid}.jpg"
    is_veg        NUMBER(1)      DEFAULT 0 NOT NULL,
    is_available  NUMBER(1)      DEFAULT 1 NOT NULL,
    display_order NUMBER         DEFAULT 0 NOT NULL,
    created_at    TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_menu_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE INDEX idx_menu_restaurant ON menu_items (restaurant_id, display_order);

-- ── 3. customers ─────────────────────────────────────────────
CREATE TABLE customers (
    id                NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_id     NUMBER        NOT NULL,
    name              VARCHAR2(100) NOT NULL,
    phone             VARCHAR2(15)  NOT NULL,
    age               NUMBER,
    gender            VARCHAR2(10),
    captured_at       TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    consent_whatsapp  NUMBER(1)     DEFAULT 0 NOT NULL,
    CONSTRAINT fk_customers_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE INDEX idx_customers_restaurant ON customers (restaurant_id);

-- ── 4. campaigns (Phase 2 — code present, feature disabled) ──
CREATE TABLE campaigns (
    id              NUMBER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_id   NUMBER         NOT NULL,
    name            VARCHAR2(200)  NOT NULL,
    message         CLOB,
    channel         VARCHAR2(20)   NOT NULL,  -- WHATSAPP | SMS
    target_segment  VARCHAR2(50),
    sent_count      NUMBER         DEFAULT 0,
    status          VARCHAR2(20)   DEFAULT 'DRAFT' NOT NULL,  -- DRAFT|SCHEDULED|SENT|FAILED
    created_at      TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    scheduled_at    TIMESTAMP,
    sent_at         TIMESTAMP,
    CONSTRAINT fk_campaigns_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    CONSTRAINT ck_campaign_channel     CHECK (channel IN ('WHATSAPP', 'SMS')),
    CONSTRAINT ck_campaign_status      CHECK (status  IN ('DRAFT', 'SCHEDULED', 'SENT', 'FAILED'))
);

CREATE INDEX idx_campaigns_restaurant ON campaigns (restaurant_id);

-- ── 5. scan_analytics (Phase 2) ──────────────────────────────
CREATE TABLE scan_analytics (
    id            NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_id NUMBER        NOT NULL,
    scanned_at    TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    user_agent    VARCHAR2(255),
    ip_address    VARCHAR2(45), -- IPv6-safe; consider hashing for GDPR compliance
    CONSTRAINT fk_analytics_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE INDEX idx_analytics_restaurant ON scan_analytics (restaurant_id, scanned_at);

-- ── Sample seed data (remove before production) ──────────────
-- Password hash below = BCrypt of "admin123" with 12 rounds
INSERT INTO restaurants (name, slug, email, password_hash, phone, plan_type)
VALUES ('Demo Dhaba', 'demo-dhaba', 'admin@demo.com',
        '$2a$12$examplehashreplacewithrealhash00000000000000000000000000',
        '9999999999', 'PRO');

COMMIT;
