SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF
SET ECHO OFF
SET TRIMSPOOL ON
SET LINESIZE 32767

-- Export restaurants
SPOOL C:\Users\Lenovo\Amaan_AI\menu-scanner\restaurants_data.sql
SELECT 'INSERT INTO restaurants (id, name, slug, email, password_hash, phone, plan_type, social_instagram, social_facebook, social_youtube, social_twitter, created_at, is_active) VALUES (' ||
    id || ', ' ||
    '''' || REPLACE(name, '''', '''''') || ''', ' ||
    '''' || REPLACE(slug, '''', '''''') || ''', ' ||
    '''' || REPLACE(email, '''', '''''') || ''', ' ||
    '''' || REPLACE(password_hash, '''', '''''') || ''', ' ||
    NVL('''' || REPLACE(phone, '''', '''''') || '''', 'NULL') || ', ' ||
    '''' || plan_type || ''', ' ||
    NVL('''' || REPLACE(social_instagram, '''', '''''') || '''', 'NULL') || ', ' ||
    NVL('''' || REPLACE(social_facebook, '''', '''''') || '''', 'NULL') || ', ' ||
    NVL('''' || REPLACE(social_youtube, '''', '''''') || '''', 'NULL') || ', ' ||
    NVL('''' || REPLACE(social_twitter, '''', '''''') || '''', 'NULL') || ', ' ||
    '''' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') || ''', ' ||
    is_active || ');'
FROM restaurants;
SPOOL OFF

-- Export categories
SPOOL C:\Users\Lenovo\Amaan_AI\menu-scanner\categories_data.sql
SELECT 'INSERT INTO categories (id, restaurant_id, name) VALUES (' ||
    id || ', ' ||
    restaurant_id || ', ' ||
    '''' || REPLACE(name, '''', '''''') || ''');'
FROM categories;
SPOOL OFF

-- Export menu_items
SPOOL C:\Users\Lenovo\Amaan_AI\menu-scanner\menu_items_data.sql
SELECT 'INSERT INTO menu_items (id, restaurant_id, name, description, price, category, image_path, is_veg, is_available, display_order, created_at) VALUES (' ||
    id || ', ' ||
    restaurant_id || ', ' ||
    '''' || REPLACE(name, '''', '''''') || ''', ' ||
    NVL('''' || REPLACE(description, '''', '''''') || '''', 'NULL') || ', ' ||
    price || ', ' ||
    NVL('''' || REPLACE(category, '''', '''''') || '''', 'NULL') || ', ' ||
    NVL('''' || REPLACE(image_path, '''', '''''') || '''', 'NULL') || ', ' ||
    is_veg || ', ' ||
    is_available || ', ' ||
    display_order || ', ' ||
    '''' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') || ''');'
FROM menu_items;
SPOOL OFF

EXIT
