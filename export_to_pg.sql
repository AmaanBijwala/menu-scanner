SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF
SET ECHO OFF
SET TRIMSPOOL ON
SET LINESIZE 32767
SET LONG 32767

-- Export restaurants
SPOOL C:\Users\Lenovo\Amaan_AI\menu-scanner\pg_restaurants.sql
SELECT 'INSERT INTO restaurants (id, name, slug, email, password_hash, phone, plan_type, social_instagram, social_facebook, social_youtube, social_twitter, created_at, is_active) VALUES (' ||
    id || ',' ||
    '''' || REPLACE(name, '''', '''''') || ''',' ||
    '''' || REPLACE(slug, '''', '''''') || ''',' ||
    '''' || REPLACE(email, '''', '''''') || ''',' ||
    '''' || REPLACE(password_hash, '''', '''''') || ''',' ||
    CASE WHEN phone IS NULL THEN 'NULL' ELSE '''' || phone || '''' END || ',' ||
    '''' || plan_type || ''',' ||
    CASE WHEN social_instagram IS NULL THEN 'NULL' ELSE '''' || REPLACE(social_instagram, '''', '''''') || '''' END || ',' ||
    CASE WHEN social_facebook IS NULL THEN 'NULL' ELSE '''' || REPLACE(social_facebook, '''', '''''') || '''' END || ',' ||
    CASE WHEN social_youtube IS NULL THEN 'NULL' ELSE '''' || REPLACE(social_youtube, '''', '''''') || '''' END || ',' ||
    CASE WHEN social_twitter IS NULL THEN 'NULL' ELSE '''' || REPLACE(social_twitter, '''', '''''') || '''' END || ',' ||
    '''' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') || ''',' ||
    is_active || ');'
FROM restaurants;
SPOOL OFF

-- Export categories
SPOOL C:\Users\Lenovo\Amaan_AI\menu-scanner\pg_categories.sql
SELECT 'INSERT INTO categories (id, restaurant_id, name) VALUES (' ||
    id || ',' ||
    restaurant_id || ',' ||
    '''' || REPLACE(name, '''', '''''') || ''');'
FROM categories;
SPOOL OFF

-- Export menu_items
SPOOL C:\Users\Lenovo\Amaan_AI\menu-scanner\pg_menu_items.sql
SELECT 'INSERT INTO menu_items (id, restaurant_id, name, description, price, discount_amount, category, image_path, is_veg, is_available, display_order, created_at) VALUES (' ||
    id || ',' ||
    restaurant_id || ',' ||
    '''' || REPLACE(name, '''', '''''') || ''',' ||
    CASE WHEN description IS NULL THEN 'NULL' ELSE '''' || REPLACE(description, '''', '''''') || '''' END || ',' ||
    price || ',' ||
    CASE WHEN discount_amount IS NULL THEN '0' ELSE TO_CHAR(discount_amount) END || ',' ||
    CASE WHEN category IS NULL THEN 'NULL' ELSE '''' || REPLACE(category, '''', '''''') || '''' END || ',' ||
    CASE WHEN image_path IS NULL THEN 'NULL' ELSE '''' || REPLACE(image_path, '''', '''''') || '''' END || ',' ||
    is_veg || ',' ||
    is_available || ',' ||
    display_order || ',' ||
    '''' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') || ''');'
FROM menu_items;
SPOOL OFF

EXIT
