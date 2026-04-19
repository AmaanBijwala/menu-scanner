<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Campaigns — Menu Scanner</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="admin-layout">

    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <script>document.getElementById('nav-campaigns').classList.add('active');</script>

    <div class="admin-main">
        <main class="container">

            <div class="page-header">
                <div>
                    <p class="page-label">Marketing</p>
                    <h1>Campaign Builder</h1>
                </div>
            </div>

            <c:choose>
                <c:when test="${not campaignsEnabled}">
                    <div class="coming-soon-card">
                        <div style="font-size:2.5rem;margin-bottom:1rem">📣</div>
                        <h2>Coming Soon</h2>
                        <p>WhatsApp &amp; SMS campaigns are being built and will be available for PRO plan users.</p>
                        <ul>
                            <c:if test="${not whatsappEnabled}"><li>WhatsApp integration — <strong>not yet active</strong></li></c:if>
                            <c:if test="${not smsEnabled}"><li>SMS integration — <strong>not yet active</strong></li></c:if>
                        </ul>
                        <p class="hint" style="margin-top:1rem">Once enabled, you'll be able to send targeted campaigns to your captured customers directly from here.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <section class="card">
                        <h2>Create Campaign</h2>
                        <form method="post" action="${pageContext.request.contextPath}/campaigns">
                            <div class="form-group">
                                <label>Campaign Name *</label>
                                <input type="text" name="name" required maxlength="200" placeholder="e.g. Weekend Special Offer">
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Channel *</label>
                                    <select name="channel" required>
                                        <c:if test="${whatsappEnabled}"><option value="WHATSAPP">WhatsApp</option></c:if>
                                        <c:if test="${smsEnabled}"><option value="SMS">SMS</option></c:if>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Target Segment</label>
                                    <select name="targetSegment">
                                        <option value="ALL">All Customers</option>
                                        <option value="CONSENT_ONLY">Consented Only</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Message *</label>
                                <textarea name="message" rows="5" required maxlength="1600" placeholder="Hi {name}, check out our latest offers!"></textarea>
                            </div>
                            <div class="form-group">
                                <label>Schedule (optional)</label>
                                <input type="datetime-local" name="scheduledAt">
                            </div>
                            <button type="submit" class="btn btn-primary">Send / Schedule Campaign</button>
                        </form>
                    </section>
                </c:otherwise>
            </c:choose>

        </main>
    </div>
</div>
</body>
</html>
