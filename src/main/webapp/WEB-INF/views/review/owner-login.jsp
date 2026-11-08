<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex">
    <title>Login — Review QR Dashboard</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=3">
    <style>
        .stars-row { font-size: 1.4rem; letter-spacing: .15rem; color: #FBBC05; margin-bottom: .5rem; }
        .phone-wrap { display: flex; align-items: stretch; }
        .phone-wrap span { display: flex; align-items: center; padding: 0 .75rem; border: 1px solid var(--outline-variant); border-right: none; border-radius: var(--radius) 0 0 var(--radius); color: var(--on-surface-muted); font-size: .9rem; background: var(--surface-container-high); }
        .phone-wrap input { border-radius: 0 var(--radius) var(--radius) 0; }
        .help { margin-top: 1.25rem; font-size: .8rem; color: var(--on-surface-muted); text-align: center; line-height: 1.5; }
    </style>
</head>
<body class="auth-page">

<div class="auth-container">
    <div class="stars-row" aria-hidden="true">&#9733;&#9733;&#9733;&#9733;&#9733;</div>
    <p class="brand-title">Review QR</p>
    <h2>Your dashboard</h2>
    <p class="auth-subtitle">See how many customers scanned your QR and manage your links.</p>

    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>
    <c:if test="${param.loggedOut eq '1'}">
        <div class="alert alert-success">You're logged out.</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/review/login" autocomplete="on">
        <div class="form-group">
            <label for="phone">Mobile number</label>
            <div class="phone-wrap">
                <span>+91</span>
                <input type="tel" id="phone" name="phone" required inputmode="numeric"
                       autocomplete="username" placeholder="98XXXXXXXX" maxlength="15"
                       value="<c:out value="${phone}"/>">
            </div>
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required
                   autocomplete="current-password" placeholder="••••••••">
        </div>
        <button type="submit" class="btn btn-primary btn-full" style="margin-top:0.5rem">Log in</button>
    </form>
    <p class="help">Don't have a password or forgot it?<br>Ask the person who set up your QR sticker.</p>
</div>

</body>
</html>
