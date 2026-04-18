<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Menu Scanner</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<nav class="navbar">
    <span class="brand">Menu Scanner</span>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/menu-items">Menu</a>
        <a href="${pageContext.request.contextPath}/customers">Customers</a>
        <a href="${pageContext.request.contextPath}/campaigns">Campaigns</a>
        <form method="post" action="${pageContext.request.contextPath}/logout" style="display:inline">
            <button type="submit" class="btn-link">Logout</button>
        </form>
    </div>
</nav>

<main class="container">
    <h1>Welcome, <c:out value="${sessionScope.restaurantName}"/></h1>
    <p class="plan-badge plan-<c:out value="${sessionScope.planType}"/>">
        <c:out value="${sessionScope.planType}"/> Plan
    </p>

    <div class="stats-grid">
        <div class="stat-card">
            <h3>Menu Items</h3>
            <p class="stat-number"><c:out value="${menuItemCount}"/></p>
            <a href="${pageContext.request.contextPath}/menu-items" class="btn">Manage Menu</a>
        </div>
        <div class="stat-card">
            <h3>Customers Captured</h3>
            <p class="stat-number"><c:out value="${customerCount}"/></p>
            <a href="${pageContext.request.contextPath}/customers" class="btn">View List</a>
        </div>
        <div class="stat-card">
            <h3>Your QR Code</h3>
            <p>Customers scan this to view your menu</p>
            <a href="${pageContext.request.contextPath}/qr" class="btn btn-primary">Download QR</a>
        </div>
        <div class="stat-card">
            <h3>Public Menu URL</h3>
            <code id="menuUrl"><c:out value="${publicMenuUrl}"/></code>
            <br><br>
            <a href="${publicMenuUrl}" target="_blank" class="btn">Open Menu</a>
        </div>
    </div>
</main>
</body>
</html>
