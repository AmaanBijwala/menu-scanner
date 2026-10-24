<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login — Menu Scanner</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=3">
    <style>
        body { display:flex; align-items:center; justify-content:center; min-height:100vh; background:var(--surface); }
        .admin-login-box {
            background: var(--surface-container);
            border: 1px solid var(--border);
            border-radius: 1rem;
            padding: 2.5rem 2rem;
            width: 100%;
            max-width: 400px;
        }
        .admin-login-badge {
            display: inline-block;
            background: var(--primary);
            color: var(--on-primary);
            font-size: 0.65rem;
            font-weight: 700;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            padding: 0.25rem 0.6rem;
            border-radius: 999px;
            margin-bottom: 1rem;
        }
        .admin-login-box h1 { font-size: 1.6rem; margin-bottom: 0.25rem; }
        .admin-login-box p  { color: var(--on-surface-muted); font-size: 0.875rem; margin-bottom: 1.75rem; }
    </style>
</head>
<body>
<div class="admin-login-box">
    <span class="admin-login-badge">Super Admin</span>
    <h1>Admin Login</h1>
    <p>Menu Scanner control panel</p>

    <c:if test="${not empty error}">
        <div class="alert alert-error" style="margin-bottom:1.25rem"><c:out value="${error}"/></div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/admin/login">
        <div class="form-group">
            <label>Admin Email</label>
            <input type="email" name="email" required autofocus placeholder="admin@menuscanner.com"
                   value="<c:out value="${param.email}"/>">
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" required placeholder="••••••••">
        </div>
        <button type="submit" class="btn btn-primary btn-full" style="margin-top:0.5rem">Sign In</button>
    </form>

    <p style="text-align:center;margin-top:1.5rem;font-size:0.8rem;color:var(--on-surface-muted)">
        <a href="${pageContext.request.contextPath}/login" style="color:var(--primary)">Back to restaurant login</a>
    </p>
</div>
</body>
</html>
