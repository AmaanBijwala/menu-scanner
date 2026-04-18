<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu Manager — Menu Scanner</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<nav class="navbar">
    <span class="brand">Menu Scanner</span>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/menu-items" class="active">Menu</a>
        <a href="${pageContext.request.contextPath}/customers">Customers</a>
        <a href="${pageContext.request.contextPath}/campaigns">Campaigns</a>
        <form method="post" action="${pageContext.request.contextPath}/logout" style="display:inline">
            <button type="submit" class="btn-link">Logout</button>
        </form>
    </div>
</nav>

<main class="container">
    <div class="page-header">
        <h1>Menu Manager</h1>
        <span class="item-count">
            <c:out value="${itemCount}"/> /
            <c:choose>
                <c:when test="${maxItems == 2147483647}">Unlimited</c:when>
                <c:otherwise><c:out value="${maxItems}"/></c:otherwise>
            </c:choose>
            items
        </span>
    </div>

    <%-- Flash messages --%>
    <c:if test="${param.success eq 'added'}">
        <div class="alert alert-success">Item added successfully.</div>
    </c:if>
    <c:if test="${param.success eq 'updated'}">
        <div class="alert alert-success">Item updated successfully.</div>
    </c:if>
    <c:if test="${param.success eq 'deleted'}">
        <div class="alert alert-success">Item deleted.</div>
    </c:if>
    <c:if test="${param.error eq 'plan_limit_reached'}">
        <div class="alert alert-error">Plan limit reached. Upgrade to PRO for unlimited items.</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>

    <%-- Add Item Form --%>
    <section class="card">
        <h2>Add New Item</h2>
        <form method="post" action="${pageContext.request.contextPath}/menu-items">
            <input type="hidden" name="action" value="add">
            <div class="form-row">
                <div class="form-group">
                    <label>Name *</label>
                    <input type="text" name="name" required maxlength="200">
                </div>
                <div class="form-group">
                    <label>Category</label>
                    <input type="text" name="category" maxlength="50" placeholder="e.g. Starters">
                </div>
                <div class="form-group">
                    <label>Price (₹) *</label>
                    <input type="number" name="price" step="0.01" min="0" required>
                </div>
                <div class="form-group">
                    <label>Display Order</label>
                    <input type="number" name="displayOrder" value="0" min="0">
                </div>
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="description" maxlength="500" rows="2"></textarea>
            </div>
            <div class="form-row">
                <label class="checkbox-label">
                    <input type="checkbox" name="isVeg"> Vegetarian
                </label>
                <label class="checkbox-label">
                    <input type="checkbox" name="isAvailable" checked> Available
                </label>
            </div>
            <button type="submit" class="btn btn-primary">Add Item</button>
        </form>
    </section>

    <%-- Image Upload (separate step after item is created) --%>
    <section class="card" id="image-upload-section" style="display:none">
        <h3>Upload Image for Item</h3>
        <p class="hint">Select the menu item and upload an image (JPEG/PNG, max 5 MB).</p>
        <div class="form-row">
            <div class="form-group">
                <label>Menu Item</label>
                <select id="uploadItemId">
                    <option value="">— select item —</option>
                    <c:forEach var="item" items="${menuItems}">
                        <option value="${item.id}"><c:out value="${item.name}"/></option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label>Image File</label>
                <input type="file" id="imageFile" accept=".jpg,.jpeg,.png">
            </div>
            <button class="btn" onclick="uploadImage()">Upload</button>
        </div>
        <div id="uploadResult"></div>
    </section>
    <button class="btn" onclick="document.getElementById('image-upload-section').style.display='block'">
        + Upload Image for Existing Item
    </button>

    <%-- Menu Items Table --%>
    <section class="card">
        <h2>Current Menu</h2>
        <c:choose>
            <c:when test="${empty menuItems}">
                <p class="empty-state">No menu items yet. Add your first item above.</p>
            </c:when>
            <c:otherwise>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Name</th>
                            <th>Category</th>
                            <th>Price</th>
                            <th>Type</th>
                            <th>Available</th>
                            <th>Order</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="item" items="${menuItems}">
                        <tr>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty item.imagePath}">
                                        <img src="${pageContext.request.contextPath}/images/<c:out value="${item.imagePath}"/>"
                                             alt="" class="thumb">
                                    </c:when>
                                    <c:otherwise><span class="no-image">—</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${item.name}"/></td>
                            <td><c:out value="${item.category}"/></td>
                            <td>₹<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${item.veg}">
                                        <span class="badge veg">Veg</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge nonveg">Non-Veg</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${item.available ? 'Yes' : 'No'}</td>
                            <td><c:out value="${item.displayOrder}"/></td>
                            <td class="actions">
                                <%-- Inline edit form --%>
                                <button class="btn-sm"
                                        onclick="openEdit(${item.id}, '<c:out value="${item.name}"/>',
                                                          '<c:out value="${item.category}"/>',
                                                          ${item.price}, ${item.veg}, ${item.available},
                                                          ${item.displayOrder})">
                                    Edit
                                </button>
                                <form method="post"
                                      action="${pageContext.request.contextPath}/menu-items"
                                      style="display:inline"
                                      onsubmit="return confirm('Delete this item?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${item.id}">
                                    <button type="submit" class="btn-sm btn-danger">Delete</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<%-- Edit Modal --%>
<div id="editModal" class="modal" style="display:none">
    <div class="modal-content">
        <h3>Edit Item</h3>
        <form method="post" action="${pageContext.request.contextPath}/menu-items">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="editId">
            <div class="form-group"><label>Name</label><input type="text" name="name" id="editName" required></div>
            <div class="form-group"><label>Category</label><input type="text" name="category" id="editCategory"></div>
            <div class="form-group"><label>Price</label><input type="number" name="price" id="editPrice" step="0.01"></div>
            <div class="form-row">
                <label class="checkbox-label"><input type="checkbox" name="isVeg" id="editVeg"> Vegetarian</label>
                <label class="checkbox-label"><input type="checkbox" name="isAvailable" id="editAvailable"> Available</label>
            </div>
            <div class="form-group"><label>Display Order</label><input type="number" name="displayOrder" id="editOrder"></div>
            <div class="modal-actions">
                <button type="submit" class="btn btn-primary">Save</button>
                <button type="button" class="btn" onclick="document.getElementById('editModal').style.display='none'">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script>const contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
