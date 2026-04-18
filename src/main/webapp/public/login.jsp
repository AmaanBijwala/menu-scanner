<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — Menu Scanner</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="auth-page">
<div class="auth-container">
    <h1 class="brand-title">Menu Scanner</h1>
    <h2>Restaurant Login</h2>

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
                   autocomplete="current-password">
        </div>
        <button type="submit" class="btn btn-primary btn-full">Login</button>
    </form>
</div>
</body>
</html>
