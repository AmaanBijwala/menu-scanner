<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enquiries — Menu Scanner Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=3">
    <style>
        .admin-topbar {
            position: sticky; top: 0; z-index: 100;
            display: flex; align-items: center; justify-content: space-between;
            gap: 1rem; padding: 0.85rem 2rem;
            background: var(--surface-container);
            border-bottom: 1px solid var(--border);
        }
        .admin-topbar-brand { font-weight: 800; font-size: 1rem; letter-spacing: -0.01em; }
        .admin-topbar-brand span { color: var(--primary); }
        .admin-topbar-nav { display: flex; gap: 0.25rem; }
        .admin-topbar-nav a { padding: 0.35rem 0.75rem; border-radius: 0.5rem; font-size: 0.8rem; font-weight: 600; color: var(--on-surface-muted); text-decoration: none; }
        .admin-topbar-nav a.active, .admin-topbar-nav a:hover { color: var(--on-surface); background: rgba(255,255,255,0.06); }
        .admin-topbar-right { display: flex; align-items: center; gap: 1rem; font-size: 0.8rem; color: var(--on-surface-muted); }

        .admin-wrap { max-width: 1100px; margin: 0 auto; padding: 2rem 1.5rem 4rem; }
        .page-head { display: flex; justify-content: space-between; align-items: baseline; gap: 1rem; flex-wrap: wrap; margin-bottom: 1.25rem; }
        .page-head h1 { font-size: 1.4rem; margin: 0; }
        .page-head a { font-size: 0.85rem; color: var(--on-surface-muted); }

        .enq-list { display: grid; gap: 0.85rem; }
        .enq { background: var(--surface-container); border: 1px solid var(--border); border-radius: 1rem; padding: 1.1rem 1.25rem;
               display: grid; grid-template-columns: 1fr auto; gap: 1rem; }
        .enq.done { opacity: 0.55; }
        .enq-name { font-weight: 700; font-size: 1rem; }
        .enq-meta { font-size: 0.78rem; color: var(--on-surface-muted); margin-top: 0.15rem; }
        .enq-msg { margin-top: 0.6rem; font-size: 0.88rem; white-space: pre-wrap; word-break: break-word; }
        .pill { display: inline-block; padding: 0.15rem 0.55rem; border-radius: 999px; font-size: 0.7rem; font-weight: 700; margin-left: 0.4rem; }
        .pill-new  { background: rgba(255,107,0,0.15); color: var(--primary); }
        .pill-done { background: rgba(255,255,255,0.06); color: var(--on-surface-muted); }
        .enq-actions { display: flex; flex-direction: column; gap: 0.4rem; align-items: stretch; min-width: 140px; }
        .btn-xs { padding: 0.4rem 0.75rem; font-size: 0.75rem; border-radius: 0.45rem; cursor: pointer; border: none; text-decoration: none; text-align: center; }
        .btn-wa { background: #25d366; color: #fff; }
        .btn-outline { background: transparent; border: 1px solid var(--border) !important; color: var(--on-surface); }
        .btn-outline:hover { border-color: var(--primary) !important; color: var(--primary); }

        @media (max-width: 640px) {
            .admin-topbar { padding: 0.75rem 1rem; flex-wrap: wrap; }
            .admin-wrap { padding: 1rem 0.75rem 4rem; }
            .enq { grid-template-columns: 1fr; }
            .enq-actions { flex-direction: row; flex-wrap: wrap; }
        }
    </style>
</head>
<body>

<header class="admin-topbar">
    <div class="admin-topbar-brand">Menu Scanner <span>Admin</span></div>
    <nav class="admin-topbar-nav">
        <a href="${pageContext.request.contextPath}/admin/">Restaurants</a>
        <a href="${pageContext.request.contextPath}/admin/review-scanners">Review Scanners</a>
        <a href="${pageContext.request.contextPath}/admin/enquiries" class="active">Enquiries</a>
        <a href="${pageContext.request.contextPath}/admin/feedback">Feedback</a>
    </nav>
    <div class="admin-topbar-right">
        <span><c:out value="${sessionScope.adminEmail}"/></span>
        <form method="post" action="${pageContext.request.contextPath}/admin/" style="display:inline">
            <input type="hidden" name="action" value="logout">
            <button type="submit" class="btn btn-xs btn-outline">Logout</button>
        </form>
    </div>
</header>

<div class="admin-wrap">
    <c:if test="${not empty param.error}">
        <div class="alert alert-error" style="margin-bottom:1.25rem"><c:out value="${param.error}"/></div>
    </c:if>
    <c:if test="${not empty loadError}">
        <div class="alert alert-error" style="margin-bottom:1.25rem"><c:out value="${loadError}"/></div>
    </c:if>

    <div class="page-head">
        <h1>Enquiries <c:if test="${newCount > 0}"><span class="pill pill-new">${newCount} new</span></c:if></h1>
        <a href="${pageContext.request.contextPath}/home" target="_blank" rel="noopener">View landing page &rarr;</a>
    </div>

    <c:choose>
        <c:when test="${empty enquiries}">
            <p class="empty-state" style="padding:2rem 0">No enquiries yet. Share your landing page link with clients and they'll show up here.</p>
        </c:when>
        <c:otherwise>
            <div class="enq-list">
                <c:forEach var="e" items="${enquiries}">
                    <div class="enq ${e.status eq 'CONTACTED' ? 'done' : ''}">
                        <div>
                            <div class="enq-name">
                                <c:out value="${e.name}"/>
                                <span class="pill ${e.status eq 'NEW' ? 'pill-new' : 'pill-done'}">${e.status eq 'NEW' ? 'NEW' : 'CONTACTED'}</span>
                            </div>
                            <div class="enq-meta">
                                <c:out value="${e.phone}"/>
                                <c:if test="${not empty e.businessName}"> · <c:out value="${e.businessName}"/></c:if>
                                · <c:out value="${e.interestLabel}"/>
                                · <fmt:formatDate value="${e.createdAt}" pattern="dd MMM yyyy, h:mm a"/>
                            </div>
                            <c:if test="${not empty e.message}"><div class="enq-msg"><c:out value="${e.message}"/></div></c:if>
                        </div>
                        <div class="enq-actions">
                            <a class="btn-xs btn-wa" target="_blank" rel="noopener"
                               href="<c:out value="${e.whatsappReplyUrl}"/>">WhatsApp</a>
                            <a class="btn-xs btn-outline" href="tel:<c:out value="${e.phone}"/>">Call</a>
                            <form method="post" action="${pageContext.request.contextPath}/admin/enquiries">
                                <input type="hidden" name="id" value="${e.id}">
                                <input type="hidden" name="status" value="${e.status eq 'NEW' ? 'CONTACTED' : 'NEW'}">
                                <button type="submit" class="btn-xs btn-outline" style="width:100%">
                                    ${e.status eq 'NEW' ? '&#10003; Mark contacted' : 'Mark as new'}
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
