<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Menu Scanner</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="admin-layout">

    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <script>document.getElementById('nav-dashboard').classList.add('active');</script>

    <div class="admin-main">
        <main class="container">

            <p class="welcome-label">Overview</p>
            <h1 class="welcome-heading">Welcome back, <c:out value="${sessionScope.restaurantName}"/></h1>
            <p class="plan-badge plan-<c:out value="${sessionScope.planType}"/>"><c:out value="${sessionScope.planType}"/> Plan</p>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-card-top">
                        <span style="font-size:1.25rem">🍽️</span>
                        <span class="stat-live-badge">Live Now</span>
                    </div>
                    <div class="stat-number"><c:out value="${menuItemCount}"/></div>
                    <h3>Menu Items</h3>
                    <a href="${pageContext.request.contextPath}/menu-items" class="btn">Manage Menu</a>
                </div>

                <div class="stat-card">
                    <div class="stat-card-top">
                        <span style="font-size:1.25rem">👥</span>
                    </div>
                    <div class="stat-number"><c:out value="${customerCount}"/></div>
                    <h3>Customers Captured</h3>
                    <a href="${pageContext.request.contextPath}/customers" class="btn">View List</a>
                </div>
            </div>

            <div class="url-card">
                <p class="url-card-label">⬡ Public Menu URL</p>
                <div class="url-display">
                    <code id="menuUrl"><c:out value="${publicMenuUrl}"/></code>
                    <button class="url-copy-btn" onclick="copyUrl()" title="Copy URL">⎘</button>
                </div>
                <p class="url-hint">Share this link on your social bio or display it at tables.</p>
            </div>

            <div class="qr-card" id="qr">
                <div class="qr-img-wrap">
                    <img src="${pageContext.request.contextPath}/qr" alt="Your QR Code" width="200" height="200">
                </div>
                <h3>Your QR Code</h3>
                <p>Display it on tables, storefronts, or windows to give guests instant access to your menu.</p>
                <div class="qr-actions">
                    <a href="${pageContext.request.contextPath}/qr" download="menu-qr.png" class="btn btn-primary">⬇ Download QR</a>
                    <a href="${pageContext.request.contextPath}/menu?slug=<c:out value="${slug}"/>" target="_blank" class="btn btn-secondary">Open Menu ↗</a>
                </div>
            </div>

        </main>
    </div>
</div>

<script>
function copyUrl() {
    const url = document.getElementById('menuUrl').textContent.trim();
    navigator.clipboard.writeText(url).then(() => {
        const btn = document.querySelector('.url-copy-btn');
        btn.textContent = '✓';
        btn.style.color = '#f57c00';
        setTimeout(() => { btn.textContent = '⎘'; btn.style.color = ''; }, 2000);
    });
}
</script>
</body>
</html>
