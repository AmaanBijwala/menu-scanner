<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Campaigns — Menu Scanner</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<nav class="navbar">
    <span class="brand">Menu Scanner</span>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/menu-items">Menu</a>
        <a href="${pageContext.request.contextPath}/customers">Customers</a>
        <a href="${pageContext.request.contextPath}/campaigns" class="active">Campaigns</a>
        <form method="post" action="${pageContext.request.contextPath}/logout" style="display:inline">
            <button type="submit" class="btn-link">Logout</button>
        </form>
    </div>
</nav>

<main class="container">
    <h1>Campaign Builder</h1>

    <c:choose>
        <c:when test="${not campaignsEnabled}">
            <%-- Phase 2 coming-soon state --%>
            <div class="coming-soon-card">
                <h2>Coming Soon</h2>
                <p>WhatsApp &amp; SMS campaigns are currently disabled.</p>
                <ul>
                    <c:if test="${not whatsappEnabled}">
                        <li>WhatsApp integration: <strong>not yet active</strong></li>
                    </c:if>
                    <c:if test="${not smsEnabled}">
                        <li>SMS integration: <strong>not yet active</strong></li>
                    </c:if>
                </ul>
                <p class="hint">
                    Once enabled, PRO plan users can send targeted campaigns to
                    captured customers directly from here.
                </p>
            </div>
        </c:when>
        <c:otherwise>
            <%-- Phase 2: Campaign form — rendered when feature flags are ON --%>
            <section class="card">
                <h2>Create Campaign</h2>
                <form method="post" action="${pageContext.request.contextPath}/campaigns">
                    <div class="form-group">
                        <label>Campaign Name *</label>
                        <input type="text" name="name" required maxlength="200">
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
                        <textarea name="message" rows="5" required maxlength="1600"
                                  placeholder="Hi {name}, check out our latest offers!"></textarea>
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
</body>
</html>
