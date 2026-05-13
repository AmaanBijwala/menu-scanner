<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — Menu Scanner</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
</head>
<body class="auth-page">

<div class="auth-container">
    <p class="brand-title">Menu Scanner</p>
    <h2>Welcome back.</h2>
    <p class="auth-subtitle">Sign in to manage your restaurant.</p>

    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/login" autocomplete="on">
        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email" required
                   autocomplete="username" placeholder="you@restaurant.com">
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required
                   autocomplete="current-password" placeholder="••••••••">
        </div>
        <button type="submit" class="btn btn-primary btn-full" style="margin-top:0.5rem">Sign In</button>
    </form>
</div>

</body>
</html>
