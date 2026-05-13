<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customers — Menu Scanner</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>
<div class="admin-layout">

    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <script>document.getElementById('nav-leads').classList.add('active');</script>

    <div class="admin-main">
        <main class="container">

            <div class="page-header">
                <div>
                    <p class="page-label">Acquisition</p>
                    <h1>Customer Leads</h1>
                </div>
                <span class="item-count"><c:out value="${customerCount}"/> total</span>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-error"><c:out value="${error}"/></div>
            </c:if>

            <%-- Search & Export row --%>
            <div class="leads-toolbar">
                <div class="leads-search-wrap">
                    <span class="leads-search-icon">&#128269;</span>
                    <input type="text" id="customerSearch" class="leads-search-input" placeholder="Search by name or phone...">
                </div>
                <a href="${pageContext.request.contextPath}/customers/export" class="btn btn-secondary leads-export-btn">
                    &#8615; Export CSV
                </a>
            </div>

            <c:choose>
                <c:when test="${empty customers}">
                    <div class="card">
                        <p class="empty-state">No customers yet. They appear here after submitting the "Get Offers" form on your public menu page.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="customer-cards" id="customerList">
                        <c:forEach var="c" items="${customers}">
                            <div class="customer-card">
                                <div class="customer-avatar">
                                    <c:choose>
                                        <c:when test="${fn:length(c.name) >= 2}">${fn:toUpperCase(fn:substring(c.name,0,2))}</c:when>
                                        <c:otherwise>${fn:toUpperCase(c.name)}</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="customer-info">
                                    <div class="customer-name"><c:out value="${c.name}"/></div>
                                    <div class="customer-meta">
                                        Captured · <fmt:formatDate value="${c.capturedAt}" pattern="dd MMM yyyy"/>
                                        <c:if test="${c.age > 0}"> · Age <c:out value="${c.age}"/></c:if>
                                        <c:if test="${not empty c.gender}"> · <c:out value="${c.gender}"/></c:if>
                                    </div>
                                    <div class="customer-phone">&#128222; <c:out value="${c.phone}"/></div>
                                </div>
                                <div class="customer-consent">
                                    <c:choose>
                                        <c:when test="${c.consentWhatsapp}"><span class="badge veg">WA &#10003;</span></c:when>
                                        <c:otherwise><span class="badge">No WA</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    <p id="noResults" class="empty-state" style="display:none">No customers match your search.</p>
                </c:otherwise>
            </c:choose>

        </main>
    </div>
</div>

<script>
$(function () {
    $('#customerSearch').on('input', function () {
        var q = $(this).val().toLowerCase().trim();
        var count = 0;
        $('.customer-card').each(function () {
            var name  = $(this).find('.customer-name').text().toLowerCase();
            var phone = $(this).find('.customer-phone').text().toLowerCase();
            var show  = !q || name.indexOf(q) !== -1 || phone.indexOf(q) !== -1;
            $(this).toggle(show);
            if (show) count++;
        });
        $('#noResults').toggle(count === 0 && q.length > 0);
    });
});
</script>
<script>const contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
