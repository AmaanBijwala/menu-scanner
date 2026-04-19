<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%
    Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
    if (statusCode == null) statusCode = 500;
    String heading, sub;
    if (statusCode == 404) {
        heading = "Table Not Found";
        sub     = "The page you're looking for has left the building.";
    } else if (statusCode == 403) {
        heading = "VIP Access Only";
        sub     = "You don't have permission to enter this area.";
    } else {
        heading = "Kitchen's on Fire";
        sub     = "Something went wrong on our end. We're fixing it.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= statusCode %> — Menu Scanner</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background: #131313;
            color: #e5e2e1;
            font-family: 'Inter', system-ui, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .err-card {
            text-align: center;
            padding: 2rem 1rem;
            max-width: 420px;
            width: 100%;
        }
        .err-code {
            font-size: 0.65rem;
            font-weight: 800;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            color: #8a8a8a;
            margin-bottom: 1.5rem;
        }
        .err-card h1 {
            font-size: 1.9rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            margin-top: 1.75rem;
            color: #e5e2e1;
        }
        .err-card p {
            font-size: 0.9rem;
            color: #8a8a8a;
            margin-top: 0.6rem;
            line-height: 1.6;
        }
        .err-actions {
            display: flex;
            gap: 0.75rem;
            justify-content: center;
            margin-top: 2rem;
            flex-wrap: wrap;
        }
        .btn-primary-err {
            background: linear-gradient(135deg, #f57c00, #e65100);
            color: #fff;
            border: none;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 700;
            padding: 0.7rem 1.8rem;
            cursor: pointer;
            text-decoration: none;
            letter-spacing: 0.02em;
            transition: opacity 0.15s;
        }
        .btn-primary-err:hover { opacity: 0.88; }
        .btn-ghost-err {
            background: rgba(229,226,225,0.06);
            color: #b0a9a7;
            border: none;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 600;
            padding: 0.7rem 1.6rem;
            cursor: pointer;
            text-decoration: none;
            transition: background 0.15s;
        }
        .btn-ghost-err:hover { background: rgba(229,226,225,0.10); }
    </style>
</head>
<body>
<div class="err-card">

    <div class="err-code">Error <%= statusCode %></div>

    <!-- Velvet Rope SVG Illustration -->
    <svg width="240" height="200" viewBox="0 0 240 200" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">

        <!-- Door frame -->
        <rect x="78" y="38" width="84" height="120" rx="4" fill="#1c1b1b" stroke="#2a2a2a" stroke-width="2"/>
        <!-- Door panel -->
        <rect x="84" y="44" width="72" height="108" rx="3" fill="#222222"/>
        <!-- Door arch hint -->
        <rect x="90" y="52" width="28" height="40" rx="2" fill="#2a2a2a"/>
        <rect x="122" y="52" width="28" height="40" rx="2" fill="#2a2a2a"/>
        <!-- Door knob -->
        <circle cx="114" cy="105" r="3.5" fill="#f57c00"/>

        <!-- Brand badge on door -->
        <circle cx="120" cy="30" r="18" fill="#1c1b1b" stroke="#2a2a2a" stroke-width="1.5"/>
        <text x="120" y="35" text-anchor="middle" font-family="Inter,sans-serif" font-size="16" font-weight="800" fill="#f57c00">M</text>

        <!-- Left post -->
        <rect x="52" y="110" width="10" height="56" rx="2" fill="#363636"/>
        <ellipse cx="57" cy="108" rx="10" ry="6" fill="#444"/>
        <ellipse cx="57" cy="168" rx="14" ry="5" fill="#2a2a2a"/>

        <!-- Right post -->
        <rect x="178" y="110" width="10" height="56" rx="2" fill="#363636"/>
        <ellipse cx="183" cy="108" rx="10" ry="6" fill="#444"/>
        <ellipse cx="183" cy="168" rx="14" ry="5" fill="#2a2a2a"/>

        <!-- Velvet rope (cubic bezier sag) -->
        <path d="M 57 118 C 90 148, 150 148, 183 118" stroke="#f57c00" stroke-width="4" stroke-linecap="round" fill="none"/>
        <!-- Rope sheen -->
        <path d="M 57 118 C 90 148, 150 148, 183 118" stroke="rgba(255,183,134,0.35)" stroke-width="2" stroke-linecap="round" fill="none"/>

        <!-- Left clip -->
        <circle cx="57" cy="118" r="5" fill="#ffb786"/>
        <!-- Right clip -->
        <circle cx="183" cy="118" r="5" fill="#ffb786"/>

        <!-- Ground line -->
        <line x1="30" y1="173" x2="210" y2="173" stroke="#1c1b1b" stroke-width="1.5"/>
    </svg>

    <h1><%= heading %></h1>
    <p><%= sub %></p>

    <div class="err-actions">
        <a href="javascript:history.back()" class="btn-primary-err">Go Back</a>
        <a href="${pageContext.request.contextPath}/login" class="btn-ghost-err">Home</a>
    </div>

</div>
</body>
</html>
