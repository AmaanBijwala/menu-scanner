<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Error — Menu Scanner</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="auth-page">
<div class="auth-container">
    <h1>Oops!</h1>
    <p>Something went wrong. Please try again or go back.</p>
    <a href="${pageContext.request.contextPath}/login" class="btn">Go to Login</a>
</div>
</body>
</html>
