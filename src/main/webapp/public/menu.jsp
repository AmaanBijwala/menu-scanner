<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${restaurant.name}"/> — Menu</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="public-menu">

<header class="menu-header">
    <h1><c:out value="${restaurant.name}"/></h1>
    <div class="social-links">
        <c:if test="${not empty restaurant.socialInstagram}">
            <a href="https://instagram.com/<c:out value="${restaurant.socialInstagram}"/>" target="_blank" rel="noopener">Instagram</a>
        </c:if>
        <c:if test="${not empty restaurant.socialFacebook}">
            <a href="https://facebook.com/<c:out value="${restaurant.socialFacebook}"/>" target="_blank" rel="noopener">Facebook</a>
        </c:if>
    </div>
    <button class="btn btn-primary" onclick="openOffersModal()">Get Offers</button>
</header>

<main class="menu-container">
    <c:choose>
        <c:when test="${empty menuItems}">
            <p class="empty-state">Menu coming soon!</p>
        </c:when>
        <c:otherwise>
            <%-- Group items by category --%>
            <c:set var="currentCategory" value=""/>
            <c:forEach var="item" items="${menuItems}">
                <c:if test="${item.available}">
                    <c:if test="${item.category != currentCategory}">
                        <c:set var="currentCategory" value="${item.category}"/>
                        <h2 class="category-heading"><c:out value="${item.category}"/></h2>
                    </c:if>
                    <div class="menu-card">
                        <c:if test="${not empty item.imagePath}">
                            <img src="${pageContext.request.contextPath}/images/<c:out value="${item.imagePath}"/>"
                                 alt="<c:out value="${item.name}"/>" class="menu-item-img"
                                 loading="lazy">
                        </c:if>
                        <div class="menu-item-info">
                            <div class="menu-item-header">
                                <span class="veg-indicator ${item.veg ? 'veg' : 'nonveg'}"></span>
                                <h3><c:out value="${item.name}"/></h3>
                                <span class="price">₹<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/></span>
                            </div>
                            <c:if test="${not empty item.description}">
                                <p class="item-desc"><c:out value="${item.description}"/></p>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</main>

<%-- Lead Capture Modal — Step 2 of the flow, optional for customers --%>
<div id="offersModal" class="modal" style="display:none" role="dialog" aria-modal="true">
    <div class="modal-content">
        <button class="modal-close" onclick="closeOffersModal()" aria-label="Close">&times;</button>
        <h2>Get Exclusive Offers</h2>
        <p>Share your details to receive deals directly on WhatsApp!</p>
        <div id="offerFormMsg" class="alert" style="display:none"></div>
        <form id="leadForm" onsubmit="submitLead(event)">
            <input type="hidden" name="slug" value="<c:out value="${restaurant.slug}"/>">
            <div class="form-group">
                <label>Name *</label>
                <input type="text" name="name" required maxlength="100">
            </div>
            <div class="form-group">
                <label>Phone *</label>
                <input type="tel" name="phone" required maxlength="15" placeholder="10-digit mobile">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Age</label>
                    <input type="number" name="age" min="1" max="120">
                </div>
                <div class="form-group">
                    <label>Gender</label>
                    <select name="gender">
                        <option value="">Prefer not to say</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
            </div>
            <label class="checkbox-label">
                <input type="checkbox" name="consentWhatsapp" value="true" checked>
                I agree to receive offers on WhatsApp
            </label>
            <button type="submit" class="btn btn-primary btn-full">Subscribe to Offers</button>
        </form>
    </div>
</div>

<script>const contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
