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

## Important Constraints

- **No ORM** — all SQL is hand-written in DAOs with `PreparedStatement`. Keep it that way.
- **Session tracking is COOKIE-only** (`web.xml`) — URL session IDs are disabled.
- **External image directory** — images live outside the WAR; the config path must exist and be writable by Tomcat.
- **PostgreSQL dialect** — use PostgreSQL SQL syntax (e.g., `BIGSERIAL` for auto-increment IDs, `CURRENT_TIMESTAMP`, `TEXT` for long text). The `campaigns.message` column is `TEXT`.
