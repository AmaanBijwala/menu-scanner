<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- A4 sheet of counter stickers: 2 per row, each with a big QR and the sticker number. --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Print Review Stickers</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800;900&display=swap" rel="stylesheet">
    <style>
        @page { size: A4; margin: 10mm; }
        * { box-sizing: border-box; }
        body { margin: 0; background: #f3f4f6; color: #111827;
               font-family: 'Inter', system-ui, -apple-system, 'Segoe UI', sans-serif; }
        .toolbar { position: sticky; top: 0; display: flex; gap: 1rem; align-items: center; justify-content: space-between;
                   padding: 0.85rem 1.5rem; background: #111827; color: #fff; font-size: 0.9rem; }
        .toolbar button { background: #ff6b00; color: #fff; border: none; border-radius: 0.5rem;
                          padding: 0.55rem 1.1rem; font-weight: 700; cursor: pointer; font-size: 0.9rem; }
        .sheet { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8mm; padding: 10mm;
                 max-width: 210mm; margin: 0 auto; background: #fff; }
        .sticker { border: 1.5px dashed #d1d5db; border-radius: 6mm; padding: 7mm 6mm 5mm;
                   text-align: center; break-inside: avoid; page-break-inside: avoid; }
        .stars { color: #fbbf24; font-size: 18pt; letter-spacing: 2pt; line-height: 1; }
        .headline { font-size: 16pt; font-weight: 900; margin: 2.5mm 0 1mm; letter-spacing: -0.01em; }
        .sub { font-size: 10pt; color: #4b5563; margin-bottom: 4mm; }
        .qr { width: 58mm; height: 58mm; display: block; margin: 0 auto 3mm; image-rendering: pixelated; }
        .google { font-size: 10pt; font-weight: 600; color: #374151; }
        .google b { color: #4285f4; } .google i { color: #ea4335; font-style: normal; font-weight: 700; }
        .google u { color: #fbbc05; text-decoration: none; font-weight: 700; } .google s { color: #34a853; text-decoration: none; font-weight: 700; }
        .no { margin-top: 3mm; font-size: 7pt; color: #9ca3af; letter-spacing: 0.08em; }
        .empty { padding: 3rem; text-align: center; color: #6b7280; }
        @media print {
            body { background: #fff; }
            .toolbar { display: none; }
            .sheet { padding: 0; max-width: none; }
        }
        @media (max-width: 600px) { .sheet { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<div class="toolbar">
    <span>${scanners.size()} sticker(s) &middot; A4, 2 per row &middot; scan one with your phone before printing a batch</span>
    <button onclick="window.print()">&#128424; Print</button>
</div>

<c:choose>
    <c:when test="${empty scanners}">
        <div class="empty">Nothing to print. Every scanner is already assigned, or none were selected.</div>
    </c:when>
    <c:otherwise>
        <div class="sheet">
            <c:forEach var="s" items="${scanners}">
                <div class="sticker">
                    <div class="stars">&#9733;&#9733;&#9733;&#9733;&#9733;</div>
                    <div class="headline">Enjoyed your visit?</div>
                    <div class="sub">Scan to leave us a review</div>
                    <img class="qr" alt="QR ${s.stickerNo}"
                         src="${pageContext.request.contextPath}/admin/review-scanners/qr?id=${s.id}&size=700">
                    <div class="google">on <b>G</b><i>o</i><u>o</u><b>g</b><s>l</s><i>e</i></div>
                    <div class="no"><c:out value="${s.stickerNo}"/></div>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>
</body>
</html>
