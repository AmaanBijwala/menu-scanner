<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customers — Menu Scanner</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<nav class="navbar">
    <span class="brand">Menu Scanner</span>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/menu-items">Menu</a>
        <a href="${pageContext.request.contextPath}/customers" class="active">Customers</a>
        <a href="${pageContext.request.contextPath}/campaigns">Campaigns</a>
        <form method="post" action="${pageContext.request.contextPath}/logout" style="display:inline">
            <button type="submit" class="btn-link">Logout</button>
        </form>
    </div>
</nav>

<main class="container">
    <div class="page-header">
        <h1>Captured Customers</h1>
        <span class="item-count"><c:out value="${customerCount}"/> total</span>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>

    <section class="card">
        <c:choose>
            <c:when test="${empty customers}">
                <p class="empty-state">
                    No customers yet. Customers appear here after they submit the "Get Offers" form
                    on your public menu page.
                </p>
            </c:when>
            <c:otherwise>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Name</th>
                            <th>Phone</th>
                            <th>Age</th>
                            <th>Gender</th>
                            <th>WhatsApp Consent</th>
                            <th>Captured At</th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="c" items="${customers}" varStatus="loop">
                        <tr>
                            <td><c:out value="${loop.count}"/></td>
                            <td><c:out value="${c.name}"/></td>
                            <td><c:out value="${c.phone}"/></td>
                            <td><c:out value="${c.age > 0 ? c.age : '—'}"/></td>
                            <td><c:out value="${not empty c.gender ? c.gender : '—'}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.consentWhatsapp}">
                                        <span class="badge veg">Yes</span>
                                    </c:when>
                                    <c:otherwise><span class="badge">No</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <fmt:formatDate value="${c.capturedAt}" pattern="dd MMM yyyy, hh:mm a"/>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </section>
</main>
</body>
</html>
