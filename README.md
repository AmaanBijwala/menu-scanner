# Menu Scanner

A SaaS QR-menu platform for restaurants. Restaurant owners manage their digital menu through an admin dashboard; customers scan a QR code to view the menu instantly — no app download required.

Built with plain Java Servlets + JSP, Oracle XE, Redis, and Tomcat 10.

---

## Features

- **Menu Management** — Add, edit, delete menu items with images, categories, pricing, and veg/non-veg tags
- **QR Code Generation** — One-click downloadable QR code that links to the public menu
- **Public Menu Page** — Fast, mobile-friendly menu page for customers (Redis-cached)
- **Lead Capture** — Customers can leave their name and phone number when viewing the menu
- **Plan Limits** — BASIC plan (max 50 items) and PRO plan (unlimited items)
- **Image Upload** — JPEG/PNG upload with magic byte validation and external storage
- **Campaigns** *(coming soon)* — WhatsApp/SMS campaign builder scaffold is in place, disabled until enabled via feature flags

---

## Tech Stack

| Layer | Technology |
|---|---|
| Server | Apache Tomcat 10 (Jakarta EE 10) |
| Language | Java 17 |
| Database | Oracle XE 21c |
| Connection Pool | HikariCP 5.x |
| Cache | Redis (Jedis 5.x) |
| Build | Maven (WAR packaging) |
| Auth | BCrypt (jBCrypt) |
| QR Code | ZXing 3.5 |
| Image Resize | Thumbnailator |
| JSON | Gson |

---

## Project Structure

```
src/
├── main/
│   ├── java/com/menuscanner/
│   │   ├── dao/          # Database access (HikariCP + PreparedStatements)
│   │   ├── filter/       # AuthFilter — session-based route protection
│   │   ├── model/        # Plain Java models (Restaurant, MenuItem, Customer, Campaign)
│   │   ├── servlet/      # One servlet per route
│   │   └── util/         # Redis cache, image processor, QR generator, BCrypt, plan config
│   ├── resources/
│   │   ├── application.properties.example   # Copy to application.properties and fill in
│   │   └── schema.sql                       # Oracle DDL — run once as the app DB user
│   └── webapp/
│       ├── META-INF/context.xml   # SameSite=Strict cookie config
│       ├── WEB-INF/
│       │   ├── views/             # JSP pages (admin-only, behind AuthFilter)
│       │   └── web.xml
│       ├── public/                # Login, public menu, error pages (no auth required)
│       ├── css/
│       └── js/
```

---

## Routes

| Route | Access | Description |
|---|---|---|
| `/login` | Public | Restaurant login |
| `/dashboard` | Auth | Stats overview, QR download, public menu link |
| `/menu-items` | Auth | Menu CRUD |
| `/upload-image` | Auth | Upload image for a menu item |
| `/customers` | Auth | View captured leads |
| `/campaigns` | Auth | Campaign builder (coming soon) |
| `/qr` | Auth | Download QR code as PNG |
| `/images/*` | Public | Serves uploaded images from external directory |
| `/menu` | Public | Customer-facing menu page |
| `/lead-capture` | Public | Saves customer lead from menu page |

---

## Local Setup

### Prerequisites

- Java 17+
- Maven 3.8+
- Oracle XE 21c
- Redis (Windows: [tporadowski/redis](https://github.com/tporadowski/redis/releases))
- Apache Tomcat 10.x

### 1. Database

Connect to Oracle XE as SYSDBA and create the app user:

```sql
ALTER SESSION SET CONTAINER = XEPDB1;
CREATE USER menuscanner IDENTIFIED BY your_password;
GRANT CONNECT, RESOURCE TO menuscanner;
ALTER USER menuscanner QUOTA UNLIMITED ON USERS;
```

Then connect as `menuscanner` and run the schema:

```
sqlplus menuscanner/your_password@localhost:1521/xepdb1 @src/main/resources/schema.sql
```

### 2. Configuration

```bash
cp src/main/resources/application.properties.example src/main/resources/application.properties
```

Edit `application.properties` with your DB credentials, Redis host, image storage path, and base URL.

### 3. Image Storage Directory

Create the directory where uploaded images will be stored:

```bash
# Windows
mkdir C:\menuscanner-data\images

# Linux
mkdir -p /opt/menuscanner-data/images
```

### 4. Oracle JDBC Driver

Copy `ojdbc11.jar` to your Tomcat `lib/` directory so the driver is available at runtime:

```
<tomcat-home>/lib/ojdbc11.jar
```

### 5. Build & Deploy

```bash
mvn clean package
```

Copy `target/menu-scanner.war` to `<tomcat-home>/webapps/` and start Tomcat.

Or use the **Smart Tomcat** plugin in IntelliJ Community Edition for a one-click run.

### 6. Seed Admin Account

Insert a restaurant row with a BCrypt-hashed password. You can generate a hash by temporarily running `PasswordUtil.hash("yourpassword")` and inserting via SQL:

```sql
INSERT INTO restaurants (name, slug, email, password_hash, plan_type)
VALUES ('Your Restaurant', 'your-slug', 'admin@example.com', '<bcrypt-hash>', 'PRO');
COMMIT;
```

Then open `http://localhost:8080/menu-scanner/login`.

---

## Security Notes

- Passwords hashed with BCrypt (cost factor 12)
- Session fixation protection on login
- `SameSite=Strict` cookies via Tomcat `CookieProcessor`
- `HttpOnly` cookies, 30-minute session timeout
- All DB queries use `PreparedStatement` (no SQL injection)
- Image uploads validated by magic bytes (not just file extension)
- Path traversal guard on image serving
- `application.properties` is excluded from version control — never commit credentials

---

## License

MIT
