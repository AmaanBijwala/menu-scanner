<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${restaurant.name}"/> — Menu</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body class="public-menu">

<header class="menu-header">
    <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:1rem">
        <div>
            <p style="font-size:0.65rem;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:var(--primary-container);margin-bottom:0.35rem">
                Digital Menu
            </p>
            <h1><c:out value="${restaurant.name}"/></h1>
            <c:if test="${not empty restaurant.socialInstagram or not empty restaurant.socialFacebook}">
                <div class="social-links" style="margin-top:0.75rem">
                    <c:if test="${not empty restaurant.socialInstagram}">
                        <a href="https://instagram.com/<c:out value="${restaurant.socialInstagram}"/>" target="_blank" rel="noopener">Instagram</a>
                    </c:if>
                    <c:if test="${not empty restaurant.socialFacebook}">
                        <a href="https://facebook.com/<c:out value="${restaurant.socialFacebook}"/>" target="_blank" rel="noopener">Facebook</a>
                    </c:if>
                </div>
            </c:if>
        </div>
        <button class="btn btn-primary" onclick="openOffersModal()" style="flex-shrink:0;margin-top:0.25rem">
            Get Offers
        </button>
    </div>
</header>

<main class="menu-container">
    <c:choose>
        <c:when test="${empty menuItems}">
            <p class="empty-state" style="margin-top:3rem">Menu coming soon!</p>
        </c:when>
        <c:otherwise>
            <c:set var="currentCategory" value=""/>
            <c:forEach var="item" items="${menuItems}">
                <c:if test="${item.available}">
                    <c:if test="${item.category != currentCategory}">
                        <c:set var="currentCategory" value="${item.category}"/>
                        <h2 class="category-heading"><c:out value="${empty item.category ? 'Our Menu' : item.category}"/></h2>
                    </c:if>

                    <div class="menu-card">
                        <c:if test="${not empty item.imagePath}">
                            <img src="${pageContext.request.contextPath}/images/<c:out value="${item.imagePath}"/>"
                                 alt="<c:out value="${item.name}"/>" class="menu-item-img" loading="lazy">
                        </c:if>
                        <div class="menu-item-body">
                            <div class="menu-item-header">
                                <div style="display:flex;align-items:center;gap:0.5rem;flex:1;min-width:0">
                                    <span class="veg-indicator ${item.veg ? 'veg' : 'nonveg'}"></span>
                                    <h3><c:out value="${item.name}"/></h3>
                                </div>
                                <div class="price-block">
                                    <c:choose>
                                        <c:when test="${item.hasDiscount()}">
                                            <span class="price">&#8377;<fmt:formatNumber value="${item.finalPrice}" pattern="#,##0"/></span>
                                            <span class="price-was">&#8377;<fmt:formatNumber value="${item.price}" pattern="#,##0"/></span>
                                            <span class="price-save">${item.discountPercent}% off</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="price">&#8377;<fmt:formatNumber value="${item.price}" pattern="#,##0"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
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

<%-- Lead Capture Modal --%>
<div id="offersModal" class="modal" style="display:none" role="dialog" aria-modal="true">
    <div class="modal-content">
        <button class="modal-close" onclick="closeOffersModal()" aria-label="Close">✕</button>
        <h3>Unlock Exclusive Offers</h3>
        <p style="color:var(--on-surface-muted);font-size:0.875rem;margin-bottom:1.5rem">
            Share your details to receive deals directly on WhatsApp!
        </p>
        <div id="offerFormMsg" class="alert" style="display:none"></div>
        <form id="leadForm" method="post" action="${pageContext.request.contextPath}/lead-capture" onsubmit="submitLead(event)">
            <input type="hidden" name="slug" id="leadSlug" value="<c:out value="${restaurant.slug}"/>">
            <div class="form-group">
                <label>Name *</label>
                <input type="text" name="name" required maxlength="100" placeholder="Your name">
            </div>
            <div class="form-group">
                <label>Phone *</label>
                <input type="tel" name="phone" required maxlength="15" placeholder="10-digit mobile number">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Age</label>
                    <input type="number" name="age" min="1" max="120" placeholder="Optional">
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
