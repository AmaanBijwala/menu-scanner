<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Super Admin — Menu Scanner</title>
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
        .admin-topbar-right { display: flex; align-items: center; gap: 1rem; font-size: 0.8rem; color: var(--on-surface-muted); }

        .admin-wrap { max-width: 1200px; margin: 0 auto; padding: 2rem 1.5rem 4rem; }

        .admin-stats { display: flex; gap: 1rem; flex-wrap: wrap; margin-bottom: 2rem; }
        .admin-stat-card {
            flex: 1; min-width: 130px;
            background: var(--surface-container); border: 1px solid var(--border);
            border-radius: 0.75rem; padding: 1rem 1.25rem;
        }
        .admin-stat-card .stat-num { font-size: 2rem; font-weight: 800; line-height: 1; }
        .admin-stat-card .stat-lbl { font-size: 0.75rem; color: var(--on-surface-muted); margin-top: 0.25rem; }
        .admin-stat-card.pro  .stat-num { color: var(--primary); }
        .admin-stat-card.off  .stat-num { color: var(--on-surface-muted); }

        .admin-add-panel { background: var(--surface-container); border: 1px solid var(--border); border-radius: 1rem; padding: 1.5rem; margin-bottom: 2rem; }
        .admin-add-panel h2 { font-size: 1.1rem; margin-bottom: 1.25rem; }
        .admin-form-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(190px, 1fr)); gap: 0.85rem; }
        .admin-form-grid .form-group { margin-bottom: 0; }
        .admin-form-actions { margin-top: 1rem; display: flex; gap: 0.75rem; align-items: center; }

        .admin-table-panel { background: var(--surface-container); border: 1px solid var(--border); border-radius: 1rem; overflow: hidden; }
        .admin-table-header { padding: 1rem 1.5rem; border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; gap: 1rem; flex-wrap: wrap; }
        .admin-table-header h2 { font-size: 1.1rem; margin: 0; }
        .admin-table-toolbar { display: flex; gap: 0.5rem; align-items: center; }

        .rtable { width: 100%; border-collapse: collapse; font-size: 0.84rem; }
        .rtable th { padding: 0.7rem 0.9rem; text-align: left; font-size: 0.68rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--on-surface-muted); border-bottom: 1px solid var(--border); white-space: nowrap; }
        .rtable td { padding: 0.8rem 0.9rem; border-bottom: 1px solid var(--border); vertical-align: middle; }
        .rtable tr:last-child td { border-bottom: none; }
        .rtable tr:hover td { background: rgba(255,255,255,0.02); }

        .rtable th.col-check, .rtable td.col-check { width: 36px; text-align: center; padding-left: 1rem; padding-right: 0.5rem; }
        .rtable th.col-num,   .rtable td.col-num   { width: 36px; color: var(--on-surface-muted); }
        .rtable th.col-dishes,.rtable td.col-dishes { text-align: center; }
        .dishes-badge {
            display: inline-block;
            min-width: 28px;
            text-align: center;
            background: rgba(255,255,255,0.06);
            border-radius: 999px;
            padding: 0.15rem 0.55rem;
            font-size: 0.78rem;
            font-weight: 600;
        }

        .btn-xs { padding: 0.28rem 0.65rem; font-size: 0.72rem; border-radius: 0.4rem; cursor: pointer; border: none; }
        .btn-outline { background: transparent; border: 1px solid var(--border) !important; color: var(--on-surface); }
        .btn-outline:hover { border-color: var(--primary) !important; color: var(--primary); }
        .btn-danger-outline { background: transparent; border: 1px solid var(--border) !important; color: var(--on-surface-muted); }
        .btn-danger-outline:hover { border-color: #ef4444 !important; color: #ef4444; }
        .btn-success-outline { background: transparent; border: 1px solid var(--border) !important; color: var(--on-surface-muted); }
        .btn-success-outline:hover { border-color: #22c55e !important; color: #22c55e; }
        .btn-edit { background: transparent; border: 1px solid var(--border) !important; color: var(--on-surface-muted); }
        .btn-edit:hover { border-color: var(--primary) !important; color: var(--primary); }

        .inactive-row td { opacity: 0.5; }
        .plan-badge { padding: 0.2rem 0.55rem; border-radius: 999px; font-size: 0.7rem; font-weight: 700; letter-spacing: 0.04em; }
        .plan-PRO   { background: rgba(255,107,0,0.15); color: var(--primary); }
        .plan-BASIC { background: rgba(255,255,255,0.06); color: var(--on-surface-muted); }
        .status-dot { display: inline-block; width: 7px; height: 7px; border-radius: 50%; margin-right: 5px; }
        .status-dot.on  { background: #22c55e; }
        .status-dot.off { background: #6b7280; }

        .row-actions { display: flex; gap: 0.35rem; flex-wrap: wrap; }

        /* Edit modal */
        .edit-modal-backdrop {
            display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.6);
            z-index: 500; align-items: center; justify-content: center;
        }
        .edit-modal-backdrop.open { display: flex; }
        .edit-modal {
            background: var(--surface-container); border: 1px solid var(--border);
            border-radius: 1rem; padding: 2rem; width: 100%; max-width: 420px;
            position: relative;
        }
        .edit-modal h3 { font-size: 1.1rem; margin-bottom: 1.25rem; }
        .edit-modal .modal-close-btn {
            position: absolute; top: 1rem; right: 1rem;
            background: none; border: none; color: var(--on-surface-muted);
            font-size: 1.1rem; cursor: pointer; padding: 0.25rem 0.5rem;
        }
        .edit-modal .modal-close-btn:hover { color: var(--on-surface); }

        .overflow-x { overflow-x: auto; }

        @media (max-width: 768px) {
            .admin-topbar { padding: 0.75rem 1rem; }
            .admin-wrap   { padding: 1rem 0.75rem 4rem; }
            .admin-form-grid { grid-template-columns: 1fr; }
            .rtable th.col-created, .rtable td.col-created { display: none; }
            .rtable th.col-phone,   .rtable td.col-phone   { display: none; }
        }
    </style>
</head>
<body>

<header class="admin-topbar">
    <div class="admin-topbar-brand">Menu Scanner <span>Admin</span></div>
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
            <div class="stat-lbl">Total Restaurants</div>
        </div>
        <div class="admin-stat-card pro">
            <div class="stat-num"><c:out value="${proCount}"/></div>
            <div class="stat-lbl">PRO Plan</div>
        </div>
        <div class="admin-stat-card">
            <div class="stat-num"><c:out value="${basicCount}"/></div>
            <div class="stat-lbl">BASIC Plan</div>
        </div>
        <div class="admin-stat-card">
            <div class="stat-num"><c:out value="${activeCount}"/></div>
            <div class="stat-lbl">Active</div>
        </div>
        <div class="admin-stat-card off">
            <div class="stat-num"><c:out value="${inactiveCount}"/></div>
            <div class="stat-lbl">Inactive</div>
        </div>
    </div>

    <%-- Add Restaurant --%>
    <div class="admin-add-panel">
        <h2>+ Add Restaurant</h2>
        <form method="post" action="${pageContext.request.contextPath}/admin/">
            <input type="hidden" name="action" value="add">
            <div class="admin-form-grid">
                <div class="form-group">
                    <label>Restaurant Name *</label>
                    <input type="text" name="name" required maxlength="200" placeholder="e.g. Hotel Spice Garden">
                </div>
                <div class="form-group">
                    <label>Email *</label>
                    <input type="email" name="email" required maxlength="150" placeholder="owner@restaurant.com">
                </div>
                <div class="form-group">
                    <label>Password *</label>
                    <input type="text" name="password" required maxlength="100" placeholder="Temporary password">
                </div>
                <div class="form-group">
                    <label>Phone</label>
                    <input type="text" name="phone" maxlength="15" placeholder="10-digit number">
                </div>
                <div class="form-group">
                    <label>Plan</label>
                    <select name="planType">
                        <option value="BASIC">BASIC</option>
                        <option value="PRO">PRO</option>
                    </select>
                </div>
            </div>
            <div class="admin-form-actions">
                <button type="submit" class="btn btn-primary">Create Restaurant</button>
                <span style="font-size:0.75rem;color:var(--on-surface-muted)">Slug is auto-generated from name.</span>
            </div>
        </form>
    </div>

    <%-- Restaurant Table --%>
    <div class="admin-table-panel">
        <div class="admin-table-header">
            <h2>All Restaurants</h2>
            <div class="admin-table-toolbar">
                <span id="selectedCount" style="font-size:0.78rem;color:var(--on-surface-muted);display:none">
                    <span id="selectedNum">0</span> selected
                </span>
                <span class="item-count"><c:out value="${totalCount}"/> total</span>
            </div>
        </div>
        <div class="overflow-x">
        <c:choose>
            <c:when test="${empty restaurants}">
                <p class="empty-state" style="padding:2rem">No restaurants yet.</p>
            </c:when>
            <c:otherwise>
                <table class="rtable" id="restaurantTable">
                    <thead>
                        <tr>
                            <th class="col-check">
                                <input type="checkbox" id="selectAll" title="Select all" onchange="toggleSelectAll(this)">
                            </th>
                            <th class="col-num">#</th>
                            <th>Name / Slug</th>
                            <th>Email</th>
                            <th class="col-phone">Phone</th>
                            <th>Plan</th>
                            <th class="col-dishes">Dishes</th>
                            <th>Status</th>
                            <th class="col-created">Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="r" items="${restaurants}" varStatus="st">
                        <tr class="${r.active ? '' : 'inactive-row'}"
                            data-id="${r.id}"
                            data-name="<c:out value="${r.name}"/>"
                            data-email="<c:out value="${r.email}"/>"
                            data-phone="<c:out value="${empty r.phone ? '' : r.phone}"/>">
                            <td class="col-check">
                                <input type="checkbox" class="row-check" value="${r.id}" onchange="updateSelectedCount()">
                            </td>
                            <td class="col-num">${st.count}</td>
                            <td>
                                <div style="font-weight:600"><c:out value="${r.name}"/></div>
                                <div style="font-size:0.72rem;color:var(--on-surface-muted)">
                                    <a href="${pageContext.request.contextPath}/menu?slug=<c:out value="${r.slug}"/>"
                                       target="_blank" rel="noopener"
                                       style="color:var(--on-surface-muted);text-decoration:underline">/<c:out value="${r.slug}"/></a>
                                </div>
                            </td>
                            <td><c:out value="${r.email}"/></td>
                            <td class="col-phone"><c:out value="${empty r.phone ? '—' : r.phone}"/></td>
                            <td>
                                <span class="plan-badge plan-<c:out value="${r.planType}"/>">
                                    <c:out value="${r.planType}"/>
                                </span>
                            </td>
                            <td class="col-dishes">
                                <span class="dishes-badge">${r.dishCount}</span>
                            </td>
                            <td>
                                <span class="status-dot ${r.active ? 'on' : 'off'}"></span>
                                ${r.active ? 'Active' : 'Inactive'}
                            </td>
                            <td class="col-created" style="color:var(--on-surface-muted);white-space:nowrap">
                                <fmt:formatDate value="${r.createdAt}" pattern="dd MMM yyyy"/>
                            </td>
                            <td>
                                <div class="row-actions">
                                    <%-- Edit contact --%>
                                    <button type="button" class="btn btn-xs btn-edit"
                                            onclick="openEditModal(this.closest('tr'))"
                                            title="Edit name / email / phone">&#9998; Edit</button>

                                    <%-- Switch plan --%>
                                    <form style="display:inline" method="post" action="${pageContext.request.contextPath}/admin/">
                                        <input type="hidden" name="action"   value="changePlan">
                                        <input type="hidden" name="id"       value="${r.id}">
                                        <input type="hidden" name="planType" value="${r.planType eq 'PRO' ? 'BASIC' : 'PRO'}">
                                        <button type="submit" class="btn btn-xs btn-outline"
                                                title="Switch to ${r.planType eq 'PRO' ? 'BASIC' : 'PRO'}">
                                            &#8646; ${r.planType eq 'PRO' ? 'BASIC' : 'PRO'}
                                        </button>
                                    </form>

                                    <%-- Toggle active --%>
                                    <c:choose>
                                        <c:when test="${r.active}">
                                            <form style="display:inline" method="post"
                                                  action="${pageContext.request.contextPath}/admin/"
                                                  onsubmit="return confirm('Deactivate ${r.name}? They will not be able to login.')">
                                                <input type="hidden" name="action" value="toggleActive">
                                                <input type="hidden" name="id"     value="${r.id}">
                                                <input type="hidden" name="active" value="false">
                                                <button type="submit" class="btn btn-xs btn-danger-outline">Deactivate</button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <form style="display:inline" method="post"
                                                  action="${pageContext.request.contextPath}/admin/">
                                                <input type="hidden" name="action" value="toggleActive">
                                                <input type="hidden" name="id"     value="${r.id}">
                                                <input type="hidden" name="active" value="true">
                                                <button type="submit" class="btn btn-xs btn-success-outline">Activate</button>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
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

<%-- Edit Contact Modal --%>
<div class="edit-modal-backdrop" id="editModalBackdrop" onclick="closeEditModal(event)">
    <div class="edit-modal" onclick="event.stopPropagation()">
        <button class="modal-close-btn" onclick="closeEditModal()">&#10005;</button>
        <h3>&#9998; Edit Restaurant</h3>
        <form method="post" action="${pageContext.request.contextPath}/admin/">
            <input type="hidden" name="action" value="editContact">
            <input type="hidden" name="id"     id="editId">
            <div class="form-group">
                <label>Name *</label>
                <input type="text" name="name" id="editName" required maxlength="200">
            </div>
            <div class="form-group">
                <label>Email *</label>
                <input type="email" name="email" id="editEmail" required maxlength="150">
            </div>
            <div class="form-group">
                <label>Phone</label>
                <input type="text" name="phone" id="editPhone" maxlength="15" placeholder="Leave blank to clear">
            </div>
            <div style="display:flex;gap:0.75rem;margin-top:0.5rem">
                <button type="submit" class="btn btn-primary">Save Changes</button>
                <button type="button" class="btn btn-outline" onclick="closeEditModal()">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script>
function openEditModal(row) {
    document.getElementById('editId').value    = row.dataset.id;
    document.getElementById('editName').value  = row.dataset.name;
    document.getElementById('editEmail').value = row.dataset.email;
    document.getElementById('editPhone').value = row.dataset.phone;
    document.getElementById('editModalBackdrop').classList.add('open');
}

function closeEditModal(e) {
    if (e && e.target !== document.getElementById('editModalBackdrop')) return;
    document.getElementById('editModalBackdrop').classList.remove('open');
}

function toggleSelectAll(cb) {
    document.querySelectorAll('.row-check').forEach(c => c.checked = cb.checked);
    updateSelectedCount();
}

function updateSelectedCount() {
    var n = document.querySelectorAll('.row-check:checked').length;
    var total = document.querySelectorAll('.row-check').length;
    var label = document.getElementById('selectedCount');
    var num   = document.getElementById('selectedNum');
    var all   = document.getElementById('selectAll');
    num.textContent   = n;
    label.style.display = n > 0 ? 'inline' : 'none';
    all.indeterminate = n > 0 && n < total;
    all.checked       = n === total && total > 0;
}
</script>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
