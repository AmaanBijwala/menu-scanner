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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=3">
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
            <c:if test="${not empty restaurant.socialWhatsapp or not empty restaurant.socialInstagram or not empty restaurant.socialFacebook or not empty restaurant.socialYoutube}">
                <div class="social-links">
                    <c:if test="${not empty restaurant.socialWhatsapp}">
                        <a href="https://wa.me/<c:out value="${restaurant.socialWhatsapp}"/>" target="_blank" rel="noopener" class="social-icon-btn social-wa" aria-label="WhatsApp">
                            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
                        </a>
                    </c:if>
                    <c:if test="${not empty restaurant.socialInstagram}">
                        <a href="https://instagram.com/<c:out value="${restaurant.socialInstagram}"/>" target="_blank" rel="noopener" class="social-icon-btn social-ig" aria-label="Instagram">
                            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z"/></svg>
                        </a>
                    </c:if>
                    <c:if test="${not empty restaurant.socialFacebook}">
                        <a href="https://facebook.com/<c:out value="${restaurant.socialFacebook}"/>" target="_blank" rel="noopener" class="social-icon-btn social-fb" aria-label="Facebook">
                            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>
                        </a>
                    </c:if>
                    <c:if test="${not empty restaurant.socialYoutube}">
                        <a href="https://youtube.com/<c:out value="${restaurant.socialYoutube}"/>" target="_blank" rel="noopener" class="social-icon-btn social-yt" aria-label="YouTube">
                            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M23.495 6.205a3.007 3.007 0 00-2.088-2.088c-1.87-.501-9.396-.501-9.396-.501s-7.507-.01-9.396.501A3.007 3.007 0 00.527 6.205a31.247 31.247 0 00-.522 5.805 31.247 31.247 0 00.522 5.783 3.007 3.007 0 002.088 2.088c1.868.502 9.396.502 9.396.502s7.506 0 9.396-.502a3.007 3.007 0 002.088-2.088 31.247 31.247 0 00.5-5.783 31.247 31.247 0 00-.5-5.805zM9.609 15.601V8.408l6.264 3.602z"/></svg>
                        </a>
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
