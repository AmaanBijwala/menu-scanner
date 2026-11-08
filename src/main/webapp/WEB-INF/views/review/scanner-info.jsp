<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Shown when a review sticker is scanned but isn't live:
     state = "unassigned" → sales pitch (the sticker is for sale)
     state = "inactive"   → neutral message for the business's customers --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex">
    <title>${state eq 'unassigned' ? 'Smart Google Review QR' : 'QR not active'}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root { --ink: #1f2937; --muted: #6b7280; --brand: #ff6b00; --bg: #fff7f0; --card: #ffffff; --line: #f1e4d8; }
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; display: flex; align-items: center; justify-content: center;
               padding: 1.25rem; background: var(--bg); color: var(--ink);
               font-family: 'Inter', system-ui, -apple-system, 'Segoe UI', sans-serif; }
        .card { width: 100%; max-width: 420px; background: var(--card); border: 1px solid var(--line);
                border-radius: 1.25rem; padding: 2rem 1.5rem; text-align: center;
                box-shadow: 0 10px 30px rgba(255,107,0,0.08); }
        .icon { font-size: 2.6rem; line-height: 1; margin-bottom: 0.75rem; }
        h1 { font-size: 1.4rem; font-weight: 800; margin: 0 0 0.6rem; letter-spacing: -0.01em; }
        p { margin: 0 0 1rem; color: var(--muted); line-height: 1.55; font-size: 0.95rem; }
        ul { text-align: left; padding: 0; margin: 0 0 1.5rem; list-style: none; }
        li { padding: 0.45rem 0 0.45rem 1.6rem; position: relative; font-size: 0.92rem; }
        li::before { content: '✓'; position: absolute; left: 0; color: var(--brand); font-weight: 800; }
        .btn { display: block; width: 100%; padding: 0.85rem 1rem; border-radius: 0.75rem; font-weight: 700;
               font-size: 0.95rem; text-decoration: none; margin-bottom: 0.6rem; }
        .btn-wa   { background: #25d366; color: #fff; }
        .btn-call { background: transparent; color: var(--ink); border: 1px solid var(--line); }
        .contact-name { font-size: 0.85rem; color: var(--muted); margin-bottom: 0.9rem; }
        .sticker { margin-top: 1.25rem; font-size: 0.72rem; color: #b8a99a; letter-spacing: 0.05em; }
        .brand { margin: 0.6rem 0 0; font-size: 0.74rem; font-weight: 600; color: #9a8b7c; }
        .brand span { font-weight: 400; }
    </style>
</head>
<body>
<main class="card">
    <c:choose>
        <c:when test="${state eq 'unassigned'}">
            <div class="icon">&#11088;</div>
            <h1>Get more Google reviews</h1>
            <p>This is a Smart Review QR. Put it on your cash counter and happy customers land straight on your Google review page with a single scan.</p>
            <ul>
                <li>Opens your Google "write a review" box directly</li>
                <li>Add your Instagram, Facebook &amp; YouTube too</li>
                <li>Your own dashboard: scans, busiest days and times</li>
            </ul>
            <c:choose>
                <c:when test="${not empty contactPhone}">
                    <c:if test="${not empty contactName}">
                        <div class="contact-name">Contact <c:out value="${contactName}"/></div>
                    </c:if>
                    <a class="btn btn-wa"
                       href="https://wa.me/<c:out value="${contactPhone}"/>?text=<c:out value="${waText}"/>">Chat on WhatsApp</a>
                    <a class="btn btn-call" href="tel:+<c:out value="${contactPhone}"/>">Call <c:out value="${contactPhoneDisplay}"/></a>
                </c:when>
                <c:otherwise>
                    <p>Ask the person who showed you this QR to set it up for your business.</p>
                </c:otherwise>
            </c:choose>
        </c:when>
        <c:otherwise>
            <div class="icon">&#9203;</div>
            <h1>This QR isn't active right now</h1>
            <p>Thanks for scanning! Please check back later, or ask the staff at the counter for help.</p>
        </c:otherwise>
    </c:choose>
    <div class="sticker">SCANNER <c:out value="${stickerNo}"/></div>
    <p class="brand">The Socio Advert <span>by Bijwala Solutions</span></p>
</main>
</body>
</html>
