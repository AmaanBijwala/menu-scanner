<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Public page for a WhatsApp offer with a photo (/o/{code}). The og:* tags make WhatsApp
     show the photo as a big preview card under the message. --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex">
    <title><c:out value="${offer.businessName}"/> — Special offer</title>
    <meta property="og:type" content="website">
    <meta property="og:title" content="<c:out value='${offer.businessName}'/> — Special offer">
    <meta property="og:description" content="<c:out value='${previewText}'/>">
    <meta property="og:image" content="<c:out value='${imageUrl}'/>">
    <meta property="og:image:type" content="image/jpeg">
    <meta property="og:url" content="<c:out value='${pageUrl}'/>">
    <meta name="twitter:card" content="summary_large_image">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; }
        html, body { margin: 0; }
        body {
            min-height: 100vh; min-height: 100dvh;
            font-family: 'Poppins', system-ui, -apple-system, 'Segoe UI', sans-serif;
            color: #241f33; background: #fff3e6;
            display: flex; align-items: flex-start; justify-content: center;
            padding: max(1rem, env(safe-area-inset-top)) 1rem max(1.5rem, env(safe-area-inset-bottom));
        }
        .card { width: 100%; max-width: 460px; background: #fff; border-radius: 22px; overflow: hidden;
                box-shadow: 0 18px 40px rgba(60, 30, 90, .14); }
        .card img { display: block; width: 100%; height: auto; background: #f1ecf7; }
        .body { padding: 1.1rem 1.2rem 1.3rem; }
        .tag { display: inline-block; font-size: .7rem; font-weight: 700; letter-spacing: .1em; color: #b0471e;
               background: #ffe7d6; padding: .25rem .65rem; border-radius: 999px; }
        h1 { margin: .55rem 0 .35rem; font-size: 1.25rem; line-height: 1.25; }
        .msg { margin: 0; font-size: .95rem; line-height: 1.55; white-space: pre-wrap; word-break: break-word; color: #3d3650; }
        .brand { margin: 1.1rem 0 0; text-align: center; font-size: .74rem; font-weight: 600; color: #8a85a0; }
        .brand span { font-weight: 400; }
    </style>
</head>
<body>
<main>
    <article class="card">
        <img src="<c:out value='${imageUrl}'/>" alt="Offer from <c:out value='${offer.businessName}'/>">
        <div class="body">
            <span class="tag">VIP OFFER</span>
            <h1><c:out value="${offer.businessName}"/></h1>
            <p class="msg"><c:out value="${offerText}"/></p>
        </div>
    </article>
    <p class="brand">The Socio Advert <span>by Bijwala Solutions</span></p>
</main>
</body>
</html>
