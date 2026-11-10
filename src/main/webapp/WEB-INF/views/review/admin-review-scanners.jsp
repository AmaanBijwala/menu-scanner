<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Review Scanners — Menu Scanner Admin</title>
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

        .admin-wrap { max-width: 1280px; margin: 0 auto; padding: 2rem 1.5rem 4rem; }

        .admin-stats { display: flex; gap: 1rem; flex-wrap: wrap; margin-bottom: 2rem; }
        .admin-stat-card {
            flex: 1; min-width: 130px;
            background: var(--surface-container); border: 1px solid var(--border);
            border-radius: 0.75rem; padding: 1rem 1.25rem;
        }
        .admin-stat-card .stat-num { font-size: 2rem; font-weight: 800; line-height: 1; }
        .admin-stat-card .stat-lbl { font-size: 0.75rem; color: var(--on-surface-muted); margin-top: 0.25rem; }
        .admin-stat-card.pro .stat-num { color: var(--primary); }

        .admin-panel { background: var(--surface-container); border: 1px solid var(--border); border-radius: 1rem; padding: 1.25rem 1.5rem; margin-bottom: 2rem; }
        .admin-panel h2 { font-size: 1.1rem; margin-bottom: 0.35rem; }
        .admin-panel p.hint { font-size: 0.78rem; color: var(--on-surface-muted); margin-bottom: 1rem; }
        .inline-form { display: flex; gap: 0.75rem; align-items: flex-end; flex-wrap: wrap; }
        .inline-form .form-group { margin-bottom: 0; }
        .inline-form input[type=number] { width: 110px; }

        .admin-table-panel { background: var(--surface-container); border: 1px solid var(--border); border-radius: 1rem; overflow: hidden; }
        .admin-table-header { padding: 1rem 1.5rem; border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; gap: 1rem; flex-wrap: wrap; }
        .admin-table-header h2 { font-size: 1.1rem; margin: 0; }
        .admin-table-toolbar { display: flex; gap: 0.5rem; align-items: center; flex-wrap: wrap; }

        .rtable { width: 100%; border-collapse: collapse; font-size: 0.84rem; }
        .rtable th { padding: 0.7rem 0.9rem; text-align: left; font-size: 0.68rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--on-surface-muted); border-bottom: 1px solid var(--border); white-space: nowrap; }
        .rtable td { padding: 0.8rem 0.9rem; border-bottom: 1px solid var(--border); vertical-align: middle; }
        .rtable tr:last-child td { border-bottom: none; }
        .rtable tr:hover td { background: rgba(255,255,255,0.02); }
        .rtable th.col-check, .rtable td.col-check { width: 36px; text-align: center; padding-left: 1rem; padding-right: 0.5rem; }
        .rtable td.col-num { text-align: center; }

        .sticker-no { font-weight: 800; font-size: 0.95rem; }
        .sticker-code { font-family: ui-monospace, monospace; font-size: 0.72rem; color: var(--on-surface-muted); }
        .url-cell a { color: var(--on-surface-muted); text-decoration: underline; font-size: 0.75rem; word-break: break-all; }
        .url-cell a.link-chip { display: inline-block; text-decoration: none; padding: 0.1rem 0.45rem; margin: 0 0.2rem 0.2rem 0; border: 1px solid var(--border); border-radius: 999px; font-size: 0.7rem; color: var(--on-surface); }
        .url-cell a.link-chip:hover { border-color: var(--primary); color: var(--primary); }
        .modal-x .section-title { font-size: 0.78rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--on-surface-muted); margin: 1.25rem 0 0.6rem; padding-top: 1rem; border-top: 1px solid var(--border); }
        .muted { color: var(--on-surface-muted); }
        .scan-badge { display: inline-block; min-width: 28px; text-align: center; background: rgba(255,255,255,0.06); border-radius: 999px; padding: 0.15rem 0.55rem; font-size: 0.78rem; font-weight: 600; }
        .scan-badge.hot { background: rgba(255,107,0,0.15); color: var(--primary); }

        .state-badge { padding: 0.2rem 0.55rem; border-radius: 999px; font-size: 0.7rem; font-weight: 700; letter-spacing: 0.04em; white-space: nowrap; }
        .state-live   { background: rgba(34,197,94,0.15); color: #22c55e; }
        .state-free   { background: rgba(255,255,255,0.06); color: var(--on-surface-muted); }
        .state-paused { background: rgba(239,68,68,0.12); color: #ef4444; }

        .btn-xs { padding: 0.28rem 0.65rem; font-size: 0.72rem; border-radius: 0.4rem; cursor: pointer; border: none; text-decoration: none; display: inline-block; }
        .btn-outline { background: transparent; border: 1px solid var(--border) !important; color: var(--on-surface); }
        .btn-outline:hover { border-color: var(--primary) !important; color: var(--primary); }
        .btn-danger-outline { background: transparent; border: 1px solid var(--border) !important; color: var(--on-surface-muted); }
        .btn-danger-outline:hover { border-color: #ef4444 !important; color: #ef4444; }
        .btn-success-outline { background: transparent; border: 1px solid var(--border) !important; color: var(--on-surface-muted); }
        .btn-success-outline:hover { border-color: #22c55e !important; color: #22c55e; }
        .row-actions { display: flex; gap: 0.35rem; flex-wrap: wrap; }
        .paused-row td { opacity: 0.55; }

        .modal-backdrop-x {
            display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.6);
            z-index: 500; align-items: center; justify-content: center; padding: 1rem;
        }
        .modal-backdrop-x.open { display: flex; }
        .modal-x {
            background: var(--surface-container); border: 1px solid var(--border);
            border-radius: 1rem; padding: 2rem; width: 100%; max-width: 460px;
            position: relative; max-height: 90vh; overflow-y: auto;
        }
        .modal-x h3 { font-size: 1.1rem; margin-bottom: 1.25rem; }
        .modal-x .modal-close-btn {
            position: absolute; top: 1rem; right: 1rem;
            background: none; border: none; color: var(--on-surface-muted);
            font-size: 1.1rem; cursor: pointer; padding: 0.25rem 0.5rem;
        }
        .modal-x .field-hint { font-size: 0.72rem; color: var(--on-surface-muted); margin-top: 0.3rem; }
        .modal-x textarea.report-box { width: 100%; min-height: 190px; font-family: inherit; font-size: 0.85rem; resize: vertical; }
        .modal-x .qr-preview { display: block; margin: 0 auto 1rem; width: 240px; height: 240px; background: #fff; border-radius: 0.5rem; padding: 0.5rem; }
        .modal-x .qr-url { font-family: ui-monospace, monospace; font-size: 0.72rem; color: var(--on-surface-muted); text-align: center; word-break: break-all; margin-bottom: 1rem; }

        .overflow-x { overflow-x: auto; }

        @media (max-width: 768px) {
            .admin-topbar { padding: 0.75rem 1rem; flex-wrap: wrap; }
            .admin-wrap   { padding: 1rem 0.75rem 4rem; }
            .rtable th.col-phone, .rtable td.col-phone { display: none; }
            .rtable th.col-url,   .rtable td.col-url   { display: none; }
        }
    </style>
</head>
<body>

<header class="admin-topbar">
    <div class="admin-topbar-brand">Menu Scanner <span>Admin</span></div>
    <nav class="admin-topbar-nav">
        <a href="${pageContext.request.contextPath}/admin/">Restaurants</a>
        <a href="${pageContext.request.contextPath}/admin/review-scanners" class="active">Review Scanners</a>
        <a href="${pageContext.request.contextPath}/admin/enquiries">Enquiries</a>
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

    <c:if test="${not empty param.success}">
        <div class="alert alert-success" style="margin-bottom:1.25rem"><c:out value="${param.success}"/></div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-error" style="margin-bottom:1.25rem"><c:out value="${param.error}"/></div>
    </c:if>
    <c:if test="${not empty loadError}">
        <div class="alert alert-error" style="margin-bottom:1.25rem"><c:out value="${loadError}"/></div>
    </c:if>

    <%-- Stats --%>
    <div class="admin-stats">
        <div class="admin-stat-card">
            <div class="stat-num"><c:out value="${totalCount}"/></div>
            <div class="stat-lbl">Total Scanners</div>
        </div>
        <div class="admin-stat-card pro">
            <div class="stat-num"><c:out value="${assignedCount}"/></div>
            <div class="stat-lbl">Given to businesses</div>
        </div>
        <div class="admin-stat-card">
            <div class="stat-num"><c:out value="${unassignedCount}"/></div>
            <div class="stat-lbl">Free (ready to sell)</div>
        </div>
        <div class="admin-stat-card">
            <div class="stat-num"><c:out value="${scansThisMonth}"/></div>
            <div class="stat-lbl">Scans this month</div>
        </div>
    </div>

    <%-- Generate + print --%>
    <div class="admin-panel">
        <h2>+ Create new scanners</h2>
        <p class="hint">Each scanner gets a sticker number (#001) and a random code inside the QR. Print them now and assign a business later.</p>
        <div class="inline-form">
            <form method="post" action="${pageContext.request.contextPath}/admin/review-scanners" class="inline-form">
                <input type="hidden" name="action" value="generate">
                <div class="form-group">
                    <label>How many?</label>
                    <input type="number" name="count" min="1" max="100" value="5" required>
                </div>
                <button type="submit" class="btn btn-primary">Create</button>
            </form>
            <a class="btn btn-outline" target="_blank" rel="noopener"
               href="${pageContext.request.contextPath}/admin/review-scanners/print?ids=unassigned">&#128424; Print all free stickers</a>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/review-view">&#128065; Client dashboards</a>
        </div>
    </div>

    <%-- Scanner table --%>
    <div class="admin-table-panel">
        <div class="admin-table-header">
            <h2>All Scanners</h2>
            <div class="admin-table-toolbar">
                <form method="get" action="${pageContext.request.contextPath}/admin/review-scanners" style="display:flex;gap:0.5rem;align-items:center">
                    <label for="monthPick" style="font-size:0.78rem;color:var(--on-surface-muted)">Report month</label>
                    <input type="month" id="monthPick" name="month" value="${month}" onchange="this.form.submit()">
                </form>
                <button type="button" class="btn btn-xs btn-outline" id="printSelectedBtn" onclick="printSelected()" disabled>&#128424; Print selected</button>
            </div>
        </div>
        <div class="overflow-x">
        <c:choose>
            <c:when test="${empty scanners}">
                <p class="empty-state" style="padding:2rem">No scanners yet. Create a few above, print them, and assign them when you sell one.</p>
            </c:when>
            <c:otherwise>
                <table class="rtable">
                    <thead>
                        <tr>
                            <th class="col-check"><input type="checkbox" id="selectAll" title="Select all" onchange="toggleSelectAll(this)"></th>
                            <th>Sticker</th>
                            <th>Business</th>
                            <th class="col-phone">Owner phone</th>
                            <th class="col-url">Links</th>
                            <th>Status</th>
                            <th class="col-num">Scans<br><span style="text-transform:none;letter-spacing:0;font-weight:500"><c:out value="${monthLabel}"/></span></th>
                            <th class="col-num">All time</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="s" items="${scanners}">
                        <c:set var="state" value="${not s.assigned ? 'free' : (s.active ? 'live' : 'paused')}"/>
                        <tr class="${state eq 'paused' ? 'paused-row' : ''}"
                            data-id="${s.id}"
                            data-sticker="${s.stickerNo}"
                            data-name="<c:out value="${empty s.businessName ? '' : s.businessName}"/>"
                            data-phone="<c:out value="${empty s.ownerPhone ? '' : s.ownerPhone}"/>"
                            data-google="<c:out value="${s.linksByKey.google}"/>"
                            data-instagram="<c:out value="${s.linksByKey.instagram}"/>"
                            data-facebook="<c:out value="${s.linksByKey.facebook}"/>"
                            data-youtube="<c:out value="${s.linksByKey.youtube}"/>"
                            data-whatsapp="<c:out value="${s.linksByKey.whatsapp}"/>"
                            data-owner-name="<c:out value="${empty s.ownerName ? '' : s.ownerName}"/>"
                            data-login="<c:out value="${empty s.loginPhone ? '' : s.loginPhone}"/>"
                            data-join="${s.assigned ? s.joinForm : true}"
                            data-scan-url="<c:out value="${scanUrls[s.id]}"/>">
                            <td class="col-check"><input type="checkbox" class="row-check" value="${s.id}" onchange="updateSelection()"></td>
                            <td>
                                <div class="sticker-no"><c:out value="${s.stickerNo}"/></div>
                                <div class="sticker-code"><c:out value="${s.code}"/></div>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${s.assigned}">
                                        <div style="font-weight:600"><c:out value="${s.businessName}"/></div>
                                        <div style="font-size:0.72rem" class="muted">since <fmt:formatDate value="${s.assignedAt}" pattern="dd MMM yyyy"/></div>
                                        <div style="font-size:0.72rem" class="muted">
                                            <c:choose>
                                                <c:when test="${s.hasLogin}">&#128273; Login: <c:out value="${s.loginPhone}"/><c:if test="${not empty s.ownerName}"> (<c:out value="${s.ownerName}"/>)</c:if></c:when>
                                                <c:otherwise>No owner login</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:when>
                                    <c:otherwise><span class="muted">— not assigned —</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="col-phone"><c:out value="${empty s.ownerPhone ? '—' : s.ownerPhone}"/></td>
                            <td class="col-url url-cell">
                                <c:choose>
                                    <c:when test="${s.linkCount > 0}">
                                        <c:forEach var="e" items="${s.links}">
                                            <a class="link-chip" href="<c:out value="${e.value}"/>" target="_blank" rel="noopener noreferrer"><c:out value="${e.key.label}"/></a>
                                        </c:forEach>
                                        <div style="font-size:0.68rem" class="muted">${s.linkCount == 1 and not s.joinForm ? 'Direct redirect' : 'Choice page'}${s.joinForm ? ' + join form' : ''}</div>
                                    </c:when>
                                    <c:otherwise><span class="muted">${s.assigned and s.joinForm ? "VIP Club form only (owner adds links)" : "—"}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${state eq 'live'}"><span class="state-badge state-live">LIVE</span></c:when>
                                    <c:when test="${state eq 'paused'}"><span class="state-badge state-paused">PAUSED</span></c:when>
                                    <c:otherwise><span class="state-badge state-free">FREE</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="col-num"><span class="scan-badge ${monthScans[s.id] > 0 ? 'hot' : ''}">${monthScans[s.id]}</span></td>
                            <td class="col-num"><span class="scan-badge">${s.scansTotal}</span></td>
                            <td>
                                <div class="row-actions">
                                    <button type="button" class="btn btn-xs btn-outline" onclick="openAssignModal(this.closest('tr'))">
                                        ${s.assigned ? '&#9998; Edit' : '+ Assign'}
                                    </button>
                                    <button type="button" class="btn btn-xs btn-outline" onclick="openQrModal(this.closest('tr'))">QR</button>
                                    <c:if test="${s.assigned}">
                                        <a class="btn btn-xs btn-outline" href="${pageContext.request.contextPath}/admin/review-view?scanner=${s.id}"
                                           title="Open this client's dashboard (read-only)">&#128065; Dashboard</a>
                                        <button type="button" class="btn btn-xs btn-outline" onclick="openReportModal(this.closest('tr'))">&#128202; Report</button>
                                        <textarea hidden id="report-${s.id}"><c:out value="${reportTexts[s.id]}"/></textarea>
                                        <c:choose>
                                            <c:when test="${s.active}">
                                                <form style="display:inline" method="post" action="${pageContext.request.contextPath}/admin/review-scanners"
                                                      onsubmit="return confirm('Pause ${s.stickerNo}? Customers scanning it will see a not-active page instead of the links.')">
                                                    <input type="hidden" name="action" value="toggleActive">
                                                    <input type="hidden" name="id"     value="${s.id}">
                                                    <input type="hidden" name="active" value="false">
                                                    <button type="submit" class="btn btn-xs btn-danger-outline">Pause</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <form style="display:inline" method="post" action="${pageContext.request.contextPath}/admin/review-scanners">
                                                    <input type="hidden" name="action" value="toggleActive">
                                                    <input type="hidden" name="id"     value="${s.id}">
                                                    <input type="hidden" name="active" value="true">
                                                    <button type="submit" class="btn btn-xs btn-success-outline">Resume</button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                        <form style="display:inline" method="post" action="${pageContext.request.contextPath}/admin/review-scanners"
                                              onsubmit="return confirm('Free ${s.stickerNo}? The business details will be removed so the sticker can be given to someone else. Old scan counts will no longer show in reports.')">
                                            <input type="hidden" name="action" value="unassign">
                                            <input type="hidden" name="id"     value="${s.id}">
                                            <button type="submit" class="btn btn-xs btn-danger-outline">Unassign</button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
        </div>
    </div>

</div><%-- admin-wrap --%>

<%-- Assign / edit modal --%>
<div class="modal-backdrop-x" id="assignModal" onclick="closeModal(event, 'assignModal')">
    <div class="modal-x" onclick="event.stopPropagation()">
        <button class="modal-close-btn" onclick="closeModal(null, 'assignModal')">&#10005;</button>
        <h3>Assign scanner <span id="assignSticker"></span></h3>
        <form method="post" action="${pageContext.request.contextPath}/admin/review-scanners">
            <input type="hidden" name="action" value="assign">
            <input type="hidden" name="id" id="assignId">
            <div class="form-group">
                <label>Business name *</label>
                <input type="text" name="businessName" id="assignName" required maxlength="200" placeholder="e.g. Hotel Bostan">
            </div>
            <div class="form-group">
                <label>Owner phone (WhatsApp report + login)</label>
                <input type="text" name="ownerPhone" id="assignPhone" maxlength="15" inputmode="numeric" placeholder="10-digit number">
            </div>

            <div class="section-title">Links</div>
            <div class="field-hint" style="margin:-0.3rem 0 0.8rem">Fill at least one. One link (and no join form) = the QR opens it directly. Otherwise customers get a page to choose.</div>
            <div class="form-group">
                <label>Google review link</label>
                <input type="url" name="google" id="assign-google" maxlength="500" placeholder="https://g.page/r/.../review">
                <div class="field-hint">Google Business Profile &rarr; <b>Ask for reviews</b> &rarr; copy the link. It opens the "write a review" box directly.</div>
            </div>
            <div class="form-group">
                <label>Instagram</label>
                <input type="text" name="instagram" id="assign-instagram" maxlength="500" placeholder="@handle or instagram.com/handle">
            </div>
            <div class="form-group">
                <label>Facebook</label>
                <input type="text" name="facebook" id="assign-facebook" maxlength="500" placeholder="facebook.com/page">
            </div>
            <div class="form-group">
                <label>WhatsApp Channel</label>
                <input type="text" name="whatsapp" id="assign-whatsapp" maxlength="500" placeholder="whatsapp.com/channel/...">
            </div>
            <div class="form-group">
                <label>YouTube</label>
                <input type="text" name="youtube" id="assign-youtube" maxlength="500" placeholder="youtube.com/@channel">
            </div>

            <label class="checkbox-label" style="margin:0.2rem 0 1rem">
                <input type="checkbox" name="joinForm" id="assignJoin" value="1">
                Show the &ldquo;Join our VIP Club&rdquo; form at the top (customers leave name, age, gender &amp; mobile for WhatsApp offers). With this on, the scan page is always shown, even with one link.
            </label>

            <div class="section-title">Owner login</div>
            <div class="form-group">
                <label>Owner name</label>
                <input type="text" name="ownerName" id="assignOwnerName" maxlength="100" placeholder="e.g. Iqbal Hingora">
                <div class="field-hint">Shown as &ldquo;Hi Iqbal&rdquo; on their dashboard. It is saved with the login, so a login is needed.</div>
            </div>
            <div class="form-group">
                <label>Login password</label>
                <input type="text" name="loginPassword" id="assignPassword" maxlength="72" autocomplete="off">
                <div class="field-hint">The owner logs in at <b><c:out value="${ownerLoginUrl}"/></b> with the owner phone above and this password. Same phone on several stickers = one login.</div>
            </div>
            <div style="display:flex;gap:0.75rem;margin-top:0.5rem;flex-wrap:wrap">
                <button type="submit" class="btn btn-primary">Save</button>
                <button type="button" class="btn btn-outline" onclick="testUrl()">Test Google link</button>
                <button type="button" class="btn btn-outline" onclick="closeModal(null, 'assignModal')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<%-- QR modal --%>
<div class="modal-backdrop-x" id="qrModal" onclick="closeModal(event, 'qrModal')">
    <div class="modal-x" onclick="event.stopPropagation()" style="text-align:center">
        <button class="modal-close-btn" onclick="closeModal(null, 'qrModal')">&#10005;</button>
        <h3>QR for <span id="qrSticker"></span></h3>
        <img id="qrImg" class="qr-preview" alt="QR code">
        <div class="qr-url" id="qrUrl"></div>
        <div style="display:flex;gap:0.75rem;justify-content:center;flex-wrap:wrap">
            <a id="qrDownload" class="btn btn-primary">Download PNG</a>
            <a id="qrPrint" class="btn btn-outline" target="_blank" rel="noopener">&#128424; Print sticker</a>
        </div>
    </div>
</div>

<%-- Monthly report modal --%>
<div class="modal-backdrop-x" id="reportModal" onclick="closeModal(event, 'reportModal')">
    <div class="modal-x" onclick="event.stopPropagation()">
        <button class="modal-close-btn" onclick="closeModal(null, 'reportModal')">&#10005;</button>
        <h3>&#128202; Report — <c:out value="${monthLabel}"/></h3>
        <textarea class="report-box" id="reportText"></textarea>
        <div class="field-hint" style="margin-bottom:1rem">These are QR scans, not reviews. Google doesn't share who actually posted a review.</div>
        <div style="display:flex;gap:0.75rem;flex-wrap:wrap">
            <button type="button" class="btn btn-primary" onclick="copyReport()" id="copyBtn">Copy for WhatsApp</button>
            <a id="waLink" class="btn btn-outline" target="_blank" rel="noopener">Open WhatsApp chat</a>
        </div>
    </div>
</div>

<script>
var ctx = '${pageContext.request.contextPath}';

function openModal(id)  { document.getElementById(id).classList.add('open'); }
function closeModal(e, id) {
    if (e && e.target !== document.getElementById(id)) return;
    document.getElementById(id).classList.remove('open');
}

function openAssignModal(row) {
    document.getElementById('assignId').value          = row.dataset.id;
    document.getElementById('assignSticker').textContent = row.dataset.sticker;
    document.getElementById('assignName').value        = row.dataset.name;
    document.getElementById('assignPhone').value       = row.dataset.phone;
    ['google', 'instagram', 'facebook', 'whatsapp', 'youtube'].forEach(function (k) {
        document.getElementById('assign-' + k).value = row.dataset[k] || '';
    });
    document.getElementById('assignOwnerName').value = row.dataset.ownerName || '';
    document.getElementById('assignJoin').checked = row.dataset.join === 'true';
    var pw = document.getElementById('assignPassword');
    pw.value = '';
    pw.placeholder = row.dataset.login
        ? 'leave empty to keep the current password'
        : 'min 6 characters (leave empty for no login)';
    openModal('assignModal');
}

function testUrl() {
    var url = document.getElementById('assign-google').value.trim();
    if (url) window.open(url, '_blank', 'noopener');
}

function openQrModal(row) {
    var id = row.dataset.id;
    document.getElementById('qrSticker').textContent = row.dataset.sticker;
    document.getElementById('qrImg').src             = ctx + '/admin/review-scanners/qr?id=' + id + '&size=480';
    document.getElementById('qrUrl').textContent     = row.dataset.scanUrl;
    document.getElementById('qrDownload').href       = ctx + '/admin/review-scanners/qr?id=' + id + '&size=1000&download=1';
    document.getElementById('qrPrint').href          = ctx + '/admin/review-scanners/print?ids=' + id;
    openModal('qrModal');
}

function openReportModal(row) {
    var text  = document.getElementById('report-' + row.dataset.id).value;
    document.getElementById('reportText').value = text;
    var phone = (row.dataset.phone || '').replace(/\D/g, '');
    if (phone.length === 10) phone = '91' + phone;          // Indian numbers without country code
    var wa = document.getElementById('waLink');
    wa.href = 'https://wa.me/' + phone + '?text=' + encodeURIComponent(text);
    wa.style.display = phone ? '' : 'none';
    document.getElementById('copyBtn').textContent = 'Copy for WhatsApp';
    openModal('reportModal');
}

function copyReport() {
    var box = document.getElementById('reportText');
    var done = function () { document.getElementById('copyBtn').textContent = 'Copied ✓'; };
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(box.value).then(done);
    } else {
        box.select(); document.execCommand('copy'); done();
    }
}

function toggleSelectAll(cb) {
    document.querySelectorAll('.row-check').forEach(function (c) { c.checked = cb.checked; });
    updateSelection();
}

function updateSelection() {
    var n = document.querySelectorAll('.row-check:checked').length;
    document.getElementById('printSelectedBtn').disabled = n === 0;
    document.getElementById('printSelectedBtn').textContent = n ? '🖨 Print selected (' + n + ')' : '🖨 Print selected';
}

function printSelected() {
    var ids = Array.from(document.querySelectorAll('.row-check:checked')).map(function (c) { return c.value; });
    if (ids.length) window.open(ctx + '/admin/review-scanners/print?ids=' + ids.join(','), '_blank', 'noopener');
}
</script>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
