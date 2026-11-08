<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Feedback — Menu Scanner Admin</title>
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
        .admin-topbar-nav { display: flex; gap: 0.25rem; flex-wrap: wrap; }
        .admin-topbar-nav a { padding: 0.35rem 0.75rem; border-radius: 0.5rem; font-size: 0.8rem; font-weight: 600; color: var(--on-surface-muted); text-decoration: none; }
        .admin-topbar-nav a.active, .admin-topbar-nav a:hover { color: var(--on-surface); background: rgba(255,255,255,0.06); }
        .admin-topbar-right { display: flex; align-items: center; gap: 1rem; font-size: 0.8rem; color: var(--on-surface-muted); }

        .admin-wrap { max-width: 1100px; margin: 0 auto; padding: 2rem 1.5rem 4rem; }
        .page-head { display: flex; justify-content: space-between; align-items: baseline; gap: 1rem; flex-wrap: wrap; margin-bottom: 0.5rem; }
        .page-head h1 { font-size: 1.4rem; margin: 0; }
        .page-head a { font-size: 0.85rem; color: var(--on-surface-muted); }
        .hint { font-size: 0.8rem; color: var(--on-surface-muted); margin-bottom: 1.25rem; }

        .fb-list { display: grid; gap: 0.85rem; }
        .fb { background: var(--surface-container); border: 1px solid var(--border); border-radius: 1rem; padding: 1.1rem 1.25rem;
              display: grid; grid-template-columns: 1fr auto; gap: 1rem; }
        .fb.hidden-fb { opacity: 0.5; }
        .fb-name { font-weight: 700; font-size: 1rem; }
        .fb-meta { font-size: 0.78rem; color: var(--on-surface-muted); margin-top: 0.15rem; }
        .fb-comment { margin-top: 0.6rem; font-size: 0.9rem; white-space: pre-wrap; word-break: break-word; }
        .pill { display: inline-block; padding: 0.15rem 0.55rem; border-radius: 999px; font-size: 0.7rem; font-weight: 700; margin-left: 0.4rem; }
        .pill-live { background: rgba(34,197,94,0.15); color: #22c55e; }
        .pill-hidden { background: rgba(255,255,255,0.06); color: var(--on-surface-muted); }
        .fb-actions { display: flex; flex-direction: column; gap: 0.4rem; min-width: 120px; }
        .btn-xs { padding: 0.4rem 0.75rem; font-size: 0.75rem; border-radius: 0.45rem; cursor: pointer; border: none; width: 100%; }
        .btn-outline { background: transparent; border: 1px solid var(--border) !important; color: var(--on-surface); }
        .btn-outline:hover { border-color: var(--primary) !important; color: var(--primary); }
        .btn-danger-outline { background: transparent; border: 1px solid var(--border) !important; color: var(--on-surface-muted); }
        .btn-danger-outline:hover { border-color: #ef4444 !important; color: #ef4444; }

        @media (max-width: 640px) {
            .admin-topbar { padding: 0.75rem 1rem; flex-wrap: wrap; }
            .admin-wrap { padding: 1rem 0.75rem 4rem; }
            .fb { grid-template-columns: 1fr; }
            .fb-actions { flex-direction: row; }
        }
    </style>
</head>
<body>

<header class="admin-topbar">
    <div class="admin-topbar-brand">Menu Scanner <span>Admin</span></div>
    <nav class="admin-topbar-nav">
        <a href="${pageContext.request.contextPath}/admin/">Restaurants</a>
        <a href="${pageContext.request.contextPath}/admin/review-scanners">Review Scanners</a>
        <a href="${pageContext.request.contextPath}/admin/enquiries">Enquiries</a>
        <a href="${pageContext.request.contextPath}/admin/feedback" class="active">Feedback</a>
    </nav>
    <div class="admin-topbar-right">
        <span><c:out value="${sessionScope.adminEmail}"/></span>
        <form method="post" action="${pageContext.request.contextPath}/admin/" style="display:inline">
            <input type="hidden" name="action" value="logout">
            <button type="submit" class="btn btn-xs btn-outline" style="width:auto">Logout</button>
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
        <h1>Client feedback <span class="pill pill-live">${visibleCount} live</span></h1>
        <a href="${pageContext.request.contextPath}/home#feedback" target="_blank" rel="noopener">View on landing page &rarr;</a>
    </div>
    <p class="hint">Feedback goes live as soon as a client submits it, exactly as written. You can hide spam or abuse, but you can't edit what someone wrote.</p>

    <c:choose>
        <c:when test="${empty feedbacks}">
            <p class="empty-state" style="padding:2rem 0">No feedback yet. Once a client shares feedback it appears here and on the landing page.</p>
        </c:when>
        <c:otherwise>
            <div class="fb-list">
                <c:forEach var="f" items="${feedbacks}">
                    <div class="fb ${f.visible ? '' : 'hidden-fb'}">
                        <div>
                            <div class="fb-name">
                                <c:out value="${f.personName}"/>
                                <span class="pill ${f.visible ? 'pill-live' : 'pill-hidden'}">${f.visible ? 'LIVE' : 'HIDDEN'}</span>
                            </div>
                            <div class="fb-meta">
                                <c:out value="${f.shopName}"/>
                                <c:if test="${not empty f.location}"> · <c:out value="${f.location}"/></c:if>
                                · <c:out value="${f.productLabel}"/>
                                · <fmt:formatDate value="${f.createdAt}" pattern="dd MMM yyyy, h:mm a"/>
                            </div>
                            <div class="fb-comment"><c:out value="${f.comment}"/></div>
                        </div>
                        <div class="fb-actions">
                            <form method="post" action="${pageContext.request.contextPath}/admin/feedback">
                                <input type="hidden" name="id" value="${f.id}">
                                <input type="hidden" name="action" value="${f.visible ? 'hide' : 'show'}">
                                <button type="submit" class="btn-xs btn-outline">${f.visible ? 'Hide' : 'Show again'}</button>
                            </form>
                            <form method="post" action="${pageContext.request.contextPath}/admin/feedback"
                                  onsubmit="return confirm('Delete this feedback permanently?')">
                                <input type="hidden" name="id" value="${f.id}">
                                <input type="hidden" name="action" value="delete">
                                <button type="submit" class="btn-xs btn-danger-outline">Delete</button>
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
