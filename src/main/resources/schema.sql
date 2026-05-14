-- ============================================================
-- Menu Scanner — PostgreSQL Schema
-- Run as: menuscanner user (or a superuser who grants to menuscanner)
-- ============================================================

-- ── 1. restaurants ──────────────────────────────────────────
CREATE TABLE restaurants (
    id               BIGSERIAL       PRIMARY KEY,
    name             VARCHAR(200)    NOT NULL,
    slug             VARCHAR(100)    NOT NULL,
    email            VARCHAR(150)    NOT NULL,
    password_hash    VARCHAR(255)    NOT NULL,
    phone            VARCHAR(15),
    plan_type        VARCHAR(20)     DEFAULT 'BASIC' NOT NULL,  -- BASIC | PRO
    social_whatsapp  VARCHAR(20),
    social_instagram VARCHAR(255),
    social_facebook  VARCHAR(255),
    social_youtube   VARCHAR(255),
    social_twitter   VARCHAR(255),
    created_at       TIMESTAMP       DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_active        SMALLINT        DEFAULT 1 NOT NULL,
    CONSTRAINT uq_restaurants_slug  UNIQUE (slug),
    CONSTRAINT uq_restaurants_email UNIQUE (email),
    CONSTRAINT ck_plan_type         CHECK (plan_type IN ('BASIC', 'PRO'))
);

-- ── 2. menu_items ────────────────────────────────────────────
CREATE TABLE menu_items (
    id            BIGSERIAL      PRIMARY KEY,
    restaurant_id BIGINT         NOT NULL,
    name          VARCHAR(200)   NOT NULL,
    description   VARCHAR(500),
    price         NUMERIC(8,2)   DEFAULT 0 NOT NULL,
    discount_amount NUMERIC(8,2) DEFAULT 0 NOT NULL,
    category      VARCHAR(50),
    image_path    VARCHAR(255),
    is_veg        SMALLINT       DEFAULT 0 NOT NULL,
    is_available  SMALLINT       DEFAULT 1 NOT NULL,
    display_order INTEGER        DEFAULT 0 NOT NULL,
    created_at    TIMESTAMP      DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_menu_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE INDEX idx_menu_restaurant ON menu_items (restaurant_id, display_order);

-- ── 3. customers ─────────────────────────────────────────────
CREATE TABLE customers (
    id                BIGSERIAL     PRIMARY KEY,
    restaurant_id     BIGINT        NOT NULL,
    name              VARCHAR(100)  NOT NULL,
    phone             VARCHAR(15)   NOT NULL,
    age               INTEGER,
    gender            VARCHAR(10),
    captured_at       TIMESTAMP     DEFAULT CURRENT_TIMESTAMP NOT NULL,
    consent_whatsapp  SMALLINT      DEFAULT 0 NOT NULL,
    CONSTRAINT fk_customers_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE INDEX idx_customers_restaurant ON customers (restaurant_id);

-- ── 4. campaigns (Phase 2 — code present, feature disabled) ──
CREATE TABLE campaigns (
    id              BIGSERIAL      PRIMARY KEY,
    restaurant_id   BIGINT         NOT NULL,
    name            VARCHAR(200)   NOT NULL,
    message         TEXT,
    channel         VARCHAR(20)    NOT NULL,  -- WHATSAPP | SMS
    target_segment  VARCHAR(50),
    sent_count      INTEGER        DEFAULT 0,
    status          VARCHAR(20)    DEFAULT 'DRAFT' NOT NULL,  -- DRAFT|SCHEDULED|SENT|FAILED
    created_at      TIMESTAMP      DEFAULT CURRENT_TIMESTAMP NOT NULL,
    scheduled_at    TIMESTAMP,
    sent_at         TIMESTAMP,
    CONSTRAINT fk_campaigns_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    CONSTRAINT ck_campaign_channel     CHECK (channel IN ('WHATSAPP', 'SMS')),
    CONSTRAINT ck_campaign_status      CHECK (status  IN ('DRAFT', 'SCHEDULED', 'SENT', 'FAILED'))
);

CREATE INDEX idx_campaigns_restaurant ON campaigns (restaurant_id);

-- ── 5. scan_analytics (Phase 2) ──────────────────────────────
CREATE TABLE scan_analytics (
    id            BIGSERIAL     PRIMARY KEY,
    restaurant_id BIGINT        NOT NULL,
    scanned_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_agent    VARCHAR(255),
    ip_address    VARCHAR(45),  -- IPv6-safe; consider hashing for GDPR compliance
    CONSTRAINT fk_analytics_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE INDEX idx_analytics_restaurant ON scan_analytics (restaurant_id, scanned_at);

-- ── 6. categories ───────────────────────────────────────────
CREATE TABLE categories (
    id            BIGSERIAL      PRIMARY KEY,
    restaurant_id BIGINT         NOT NULL,
    name          VARCHAR(100)   NOT NULL,
    CONSTRAINT fk_cat_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE INDEX idx_categories_restaurant ON categories (restaurant_id);

-- ── Sample seed data (remove before production) ──────────────
-- Password hash below = BCrypt of "admin123" with 12 rounds
INSERT INTO restaurants (name, slug, email, password_hash, phone, plan_type)
VALUES ('Demo Dhaba', 'demo-dhaba', 'admin@demo.com',
        '$2a$12$examplehashreplacewithrealhash00000000000000000000000000',
        '9999999999', 'PRO');
