<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu Manager — Menu Scanner</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>

<div class="admin-layout">

    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <script>$(function(){ $('#nav-menu').addClass('active'); });</script>

    <%-- Main Content --%>
    <div class="admin-main">

        <%-- Hero Header --%>
        <div class="mm-hero">
            <h1>Curate Your<br><span>Atmosphere.</span></h1>
            <p>The menu is the heartbeat of your restaurant. Design each entry with the precision of a chef and the eye of a gallery curator.</p>
        </div>

        <%-- Flash Messages --%>
        <div class="mm-alerts">
            <c:if test="${param.success eq 'added'}"><div class="alert alert-success">Item added to the collection.</div></c:if>
            <c:if test="${param.success eq 'updated'}"><div class="alert alert-success">Item updated successfully.</div></c:if>
            <c:if test="${param.success eq 'deleted'}"><div class="alert alert-success">Item removed from collection.</div></c:if>
            <c:if test="${param.error eq 'plan_limit_reached'}"><div class="alert alert-error">Plan limit reached. Upgrade to PRO for unlimited items.</div></c:if>
            <c:if test="${not empty error}"><div class="alert alert-error"><c:out value="${error}"/></div></c:if>
            <c:if test="${not empty uploadSuccess}"><div class="alert alert-success"><c:out value="${uploadSuccess}"/></div></c:if>
        </div>

        <div class="mm-body">

            <%-- Category Management --%>
            <div class="mm-category-panel">
                <div class="mm-category-header">
                    <h3>Categories</h3>
                    <form method="post" action="${pageContext.request.contextPath}/categories" class="mm-cat-add-form">
                        <input type="hidden" name="action" value="add">
                        <input type="text" name="name" placeholder="New category..." maxlength="100" required class="mm-cat-input">
                        <button type="submit" class="btn btn-primary btn-sm-cat">+ Add</button>
                    </form>
                </div>
                <div class="mm-cat-chips">
                    <c:choose>
                        <c:when test="${empty categories}">
                            <span class="mm-cat-empty">No categories yet</span>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="cat" items="${categories}">
                                <span class="mm-cat-chip">
                                    <c:out value="${cat.name}"/>
                                    <form method="post" action="${pageContext.request.contextPath}/categories" style="display:inline">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${cat.id}">
                                        <button type="submit" class="mm-cat-chip-del" title="Remove">×</button>
                                    </form>
                                </span>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        <%-- Bulk Upload Panel --%>
            <div class="mm-bulk-panel">
                <div class="mm-bulk-header" onclick="toggleBulk()">
                    <span>&#8645; Bulk Upload Items</span>
                    <span class="mm-bulk-chevron" id="bulkChevron">&#8964;</span>
                </div>
                <div class="mm-bulk-body" id="bulkBody" style="display:none">
                    <p class="mm-bulk-hint">
                        Download the template, fill in your items, then upload. All rows are validated before saving.
                        Category names must match exactly (case-sensitive) what you've added above.
                    </p>
                    <div class="mm-bulk-row">
                        <a href="${pageContext.request.contextPath}/bulk-template" class="btn btn-secondary">
                            &#8659; Download Template (.xlsx)
                        </a>
                        <div class="mm-bulk-file-wrap">
                            <input type="file" id="bulkFile" accept=".xlsx,.xls,.csv" class="mm-bulk-file-input">
                            <label for="bulkFile" class="mm-bulk-file-label" id="bulkFileLabel">Choose .xlsx or .csv</label>
                        </div>
                        <button class="btn btn-primary" onclick="bulkUpload()">Upload &amp; Save</button>
                    </div>
                    <div id="bulkResult"></div>
                </div>
            </div>

        <%-- Add Form --%>
            <div class="mm-form-panel">
                <h2>+ Add New Curated Entry</h2>
                <form method="post" action="${pageContext.request.contextPath}/menu-items" id="addForm">
                    <input type="hidden" name="action" value="add">
                    <div class="mm-form-inner">

                        <%-- LEFT: Upload zone --%>
                        <div>
                            <label class="upload-area-tall" for="imageFile">
                                <select class="upload-item-select" id="uploadItemId"
                                        onclick="event.preventDefault()" onchange="event.stopPropagation()">
                                    <option value="">— choose item —</option>
                                    <c:forEach var="item" items="${menuItems}">
                                        <option value="${item.id}"><c:out value="${item.name}"/></option>
                                    </c:forEach>
                                </select>
                                <div class="upload-area-icon-lg">📷</div>
                                <p id="uploadLabelText">Upload Visual Identity<br>
                                    <span style="font-size:0.65rem;opacity:0.6">JPEG / PNG · max 5 MB</span>
                                </p>
                                <input type="file" id="imageFile" accept=".jpg,.jpeg,.png">
                            </label>
                            <button type="button" class="btn btn-secondary btn-full"
                                    onclick="uploadImage()" style="margin-top:0.6rem">Upload Image</button>
                        </div>

                        <%-- RIGHT: Fields --%>
                        <div class="mm-form-fields">
                            <div class="mm-form-row">
                                <div class="form-group">
                                    <label>Dish Identity</label>
                                    <input type="text" name="name" required maxlength="200" placeholder="e.g. Dal Makhani">
                                </div>
                                <div class="form-group">
                                    <label>Category</label>
                                    <select name="category">
                                        <option value="">— None —</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat.name}"><c:out value="${cat.name}"/></option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="mm-form-row mm-price-row">
                                <div class="form-group">
                                    <label>Actual Price (&#8377;)</label>
                                    <input type="number" name="price" id="addActualPrice" step="0.01" min="0" required placeholder="0.00" oninput="calcFinal('add')">
                                </div>
                                <div class="form-group">
                                    <label>Discount (&#8377;) <span class="field-optional">optional</span></label>
                                    <input type="number" name="discountAmount" id="addDiscount" step="0.01" min="0" placeholder="0.00" oninput="calcFinal('add')">
                                </div>
                                <div class="form-group">
                                    <label>Final Price (&#8377;)</label>
                                    <input type="number" id="addFinalPrice" step="0.01" min="0" placeholder="0.00" readonly tabindex="-1" class="input-readonly">
                                </div>
                            </div>
                            <div class="mm-form-row">
                                <div class="form-group">
                                    <label>Display Order</label>
                                    <input type="number" name="displayOrder" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Description</label>
                                <textarea name="description" maxlength="500" rows="4"
                                          placeholder="Describe the sensory experience, ingredients and soul of this dish..."></textarea>
                            </div>
                            <div class="toggle-row">
                                <label class="toggle-chip">
                                    <input type="checkbox" name="isVeg"> 🌿 Veg
                                </label>
                                <label class="toggle-chip">
                                    <input type="checkbox" name="isAvailable" checked> ✓ Available
                                </label>
                            </div>
                            <button type="submit" class="btn btn-primary btn-full">Archive Entry</button>
                        </div>

                    </div>
                </form>
            </div>

            <%-- Active Collection --%>
            <div class="mm-collection-panel">
                <div class="mm-collection-header">
                    <h2>The Active Collection</h2>
                    <span class="mm-collection-count">
                        <c:out value="${itemCount}"/> /
                        <c:choose>
                            <c:when test="${maxItems == 2147483647}">Unlimited</c:when>
                            <c:otherwise><c:out value="${maxItems}"/></c:otherwise>
                        </c:choose>
                        curated items
                    </span>
                </div>

                <c:choose>
                    <c:when test="${empty menuItems}">
                        <p class="empty-state">No items yet. Add your first dish to begin curating.</p>
                    </c:when>
                    <c:otherwise>
                        <%-- Category grouping --%>
                        <c:set var="currentCat" value="__none__"/>
                        <c:forEach var="item" items="${menuItems}">
                            <c:if test="${item.category != currentCat}">
                                <c:if test="${currentCat ne '__none__'}"></div></c:if>
                                <c:set var="currentCat" value="${item.category}"/>
                                <div style="margin-bottom:0.75rem;display:flex;align-items:center;gap:0.75rem">
                                    <span style="font-size:0.65rem;font-weight:800;letter-spacing:0.12em;text-transform:uppercase;color:var(--on-surface-muted);white-space:nowrap">
                                        <c:out value="${empty item.category ? 'Uncategorized' : item.category}"/>
                                    </span>
                                    <div style="height:1px;flex:1;background:var(--outline-variant)"></div>
                                </div>
                                <div class="collection-grid" style="margin-bottom:2rem">
                            </c:if>

                            <div class="collection-card">
                                <div class="collection-card-img-wrap">
                                    <c:choose>
                                        <c:when test="${not empty item.imagePath}">
                                            <img src="${pageContext.request.contextPath}/images/<c:out value="${item.imagePath}"/>"
                                                 alt="<c:out value="${item.name}"/>" class="collection-card-img">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="collection-card-no-img">🍽</div>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:choose>
                                        <c:when test="${item.hasDiscount()}">
                                            <span class="collection-card-price">
                                                &#8377;<fmt:formatNumber value="${item.finalPrice}" pattern="#,##0"/>
                                                <span class="price-original">&#8377;<fmt:formatNumber value="${item.price}" pattern="#,##0"/></span>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="collection-card-price">&#8377;<fmt:formatNumber value="${item.price}" pattern="#,##0"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="collection-card-body">
                                    <div class="collection-card-name"><c:out value="${item.name}"/></div>
                                    <c:if test="${not empty item.description}">
                                        <div class="collection-card-desc"><c:out value="${item.description}"/></div>
                                    </c:if>
                                    <div class="collection-card-footer">
                                        <div style="display:flex;gap:0.35rem;align-items:center;flex-wrap:wrap">
                                            <c:choose>
                                                <c:when test="${item.veg}"><span class="badge veg">Veg</span></c:when>
                                                <c:otherwise><span class="badge nonveg">Non-Veg</span></c:otherwise>
                                            </c:choose>
                                            <c:if test="${item.hasDiscount()}">
                                                <span class="badge discount">${item.discountPercent}% off</span>
                                            </c:if>
                                        </div>
                                        <div class="collection-card-actions">
                                            <button class="btn-sm"
                                                    onclick="openEdit(${item.id},'<c:out value="${item.name}"/>','<c:out value="${item.category}"/>',${item.price},${item.discountAmount},${item.veg},${item.available},${item.displayOrder},'<c:out value="${item.imagePath}"/>')">
                                                &#9998;
                                            </button>
                                            <form method="post" action="${pageContext.request.contextPath}/menu-items"
                                                  style="display:inline" onsubmit="return confirm('Delete this item?')">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${item.id}">
                                                <button type="submit" class="btn-sm btn-danger">&#10005;</button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                        </div><%-- close last grid --%>
                    </c:otherwise>
                </c:choose>
            </div>

        </div><%-- mm-body --%>
    </div><%-- admin-main --%>
</div><%-- admin-layout --%>

<%-- Edit Modal --%>
<div id="editModal" class="modal" style="display:none">
    <div class="modal-content">
        <button class="modal-close" onclick="$('#editModal').css('display','none')">✕</button>
        <h3>Edit Item</h3>
        <form method="post" action="${pageContext.request.contextPath}/menu-items">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="editId">
            <input type="hidden" name="imagePath" id="editImagePath">
            <div class="form-group"><label>Name</label><input type="text" name="name" id="editName" required></div>
            <div class="form-group"><label>Category</label>
                <select name="category" id="editCategory">
                    <option value="">— None —</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.name}"><c:out value="${cat.name}"/></option>
                    </c:forEach>
                </select>
            </div>
            <div class="mm-form-row mm-price-row">
                <div class="form-group"><label>Actual Price (&#8377;)</label><input type="number" name="price" id="editPrice" step="0.01" min="0" oninput="calcFinal('edit')"></div>
                <div class="form-group"><label>Discount (&#8377;) <span class="field-optional">optional</span></label><input type="number" name="discountAmount" id="editDiscount" step="0.01" min="0" placeholder="0.00" oninput="calcFinal('edit')"></div>
                <div class="form-group"><label>Final Price (&#8377;)</label><input type="number" id="editFinalPrice" step="0.01" min="0" readonly tabindex="-1" class="input-readonly"></div>
            </div>
            <div class="form-row">
                <label class="checkbox-label"><input type="checkbox" name="isVeg" id="editVeg"> Vegetarian</label>
                <label class="checkbox-label"><input type="checkbox" name="isAvailable" id="editAvailable"> Available</label>
            </div>
            <div class="form-group"><label>Display Order</label><input type="number" name="displayOrder" id="editOrder"></div>
            <div class="modal-actions">
                <button type="submit" class="btn btn-primary">Save Changes</button>
                <button type="button" class="btn" onclick="$('#editModal').css('display','none')">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script>
$(function () {
    $('#imageFile').on('change', function () {
        $('#uploadLabelText').html(this.files[0]
            ? '&#128206; ' + this.files[0].name
            : 'Upload Visual Identity<br><span style="font-size:0.72rem;color:var(--on-surface-muted)">JPEG / PNG · max 5 MB</span>');
    });
});
</script>
<script>const contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
