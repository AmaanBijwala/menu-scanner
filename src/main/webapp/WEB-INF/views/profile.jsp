<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile — Menu Scanner</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=3">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>
<div class="admin-layout">

    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <script>document.getElementById('nav-profile').classList.add('active');</script>

    <div class="admin-main">
        <main class="container">

            <p class="welcome-label">Settings</p>
            <h1 class="welcome-heading">Profile</h1>

            <%-- Success / Error alerts --%>
            <c:if test="${not empty success}">
                <div class="alert alert-success" style="margin-bottom:1.5rem"><c:out value="${success}"/></div>
            </c:if>

            <div class="profile-sections">

                <%-- ── Restaurant Info & Social Links ── --%>
                <div class="card">
                    <h2 class="card-title">Restaurant Info &amp; Social Links</h2>
                    <p class="card-subtitle">These social icons will appear on your public menu page.</p>

                    <form method="post" action="${pageContext.request.contextPath}/profile">
                        <input type="hidden" name="action" value="social">

                        <div class="form-grid">
                            <div class="form-group">
                                <label>Restaurant Name *</label>
                                <input type="text" name="name" required maxlength="200"
                                       value="<c:out value="${restaurant.name}"/>">
                            </div>
                            <div class="form-group">
                                <label>Phone</label>
                                <input type="tel" name="phone" maxlength="15"
                                       placeholder="e.g. 9876543210"
                                       value="<c:out value="${restaurant.phone}"/>">
                            </div>
                            <div class="form-group">
                                <label>Email</label>
                                <input type="email" value="<c:out value="${restaurant.email}"/>" disabled>
                                <span class="form-hint">Email cannot be changed.</span>
                            </div>
                            <div class="form-group">
                                <label>Plan</label>
                                <input type="text" value="<c:out value="${sessionScope.planType}"/> Plan" disabled>
                            </div>
                        </div>

                        <h3 class="section-subheading">Social Links</h3>
                        <p class="card-subtitle">These appear as icons on your public menu. Leave blank to hide.</p>

                        <div class="form-grid">
                            <div class="form-group">
                                <label class="label-with-icon">
                                    <span class="social-label-icon social-wa">
                                        <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
                                    </span>
                                    WhatsApp Number
                                </label>
                                <input type="tel" name="socialWhatsapp" maxlength="20"
                                       placeholder="e.g. 919876543210 (with country code)"
                                       value="<c:out value="${restaurant.socialWhatsapp}"/>">
                                <span class="form-hint">Include country code, no + or spaces. Used as wa.me link.</span>
                            </div>
                            <div class="form-group">
                                <label class="label-with-icon">
                                    <span class="social-label-icon social-ig">
                                        <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z"/></svg>
                                    </span>
                                    Instagram Handle
                                </label>
                                <input type="text" name="socialInstagram" maxlength="255"
                                       placeholder="e.g. hotelbostan (without @)"
                                       value="<c:out value="${restaurant.socialInstagram}"/>">
                            </div>
                            <div class="form-group">
                                <label class="label-with-icon">
                                    <span class="social-label-icon social-fb">
                                        <svg viewBox="0 0 24 24" fill="currentColor"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>
                                    </span>
                                    Facebook Page URL
                                </label>
                                <input type="text" name="socialFacebook" maxlength="255"
                                       placeholder="e.g. HotelBostan"
                                       value="<c:out value="${restaurant.socialFacebook}"/>">
                            </div>
                            <div class="form-group">
                                <label>YouTube Channel URL</label>
                                <input type="text" name="socialYoutube" maxlength="255"
                                       placeholder="e.g. @HotelBostan"
                                       value="<c:out value="${restaurant.socialYoutube}"/>">
                            </div>
                        </div>

                        <div style="margin-top:1.5rem">
                            <button type="submit" class="btn btn-primary">Save Changes</button>
                        </div>
                    </form>
                </div>

                <%-- ── Change Password ── --%>
                <div class="card">
                    <h2 class="card-title">Change Password</h2>

                    <c:if test="${not empty pwdError}">
                        <div class="alert alert-error" style="margin-bottom:1rem"><c:out value="${pwdError}"/></div>
                    </c:if>
                    <c:if test="${not empty pwdSuccess}">
                        <div class="alert alert-success" style="margin-bottom:1rem"><c:out value="${pwdSuccess}"/></div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/profile">
                        <input type="hidden" name="action" value="password">
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Current Password</label>
                                <input type="password" name="currentPassword" required>
                            </div>
                            <div class="form-group">
                                <label>New Password</label>
                                <input type="password" name="newPassword" required minlength="8">
                                <span class="form-hint">Minimum 8 characters.</span>
                            </div>
                            <div class="form-group">
                                <label>Confirm New Password</label>
                                <input type="password" name="confirmPassword" required minlength="8">
                            </div>
                        </div>
                        <div style="margin-top:1.5rem">
                            <button type="submit" class="btn btn-primary">Change Password</button>
                        </div>
                    </form>
                </div>

            </div><%-- end .profile-sections --%>
        </main>
    </div>
</div>
</body>
</html>
