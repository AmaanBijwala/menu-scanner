<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics — Menu Scanner</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=3">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        /* ── Stat cards ── */
        .an-stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1rem;
            margin-bottom: 2rem;
        }
        @media(max-width:900px) { .an-stats { grid-template-columns: repeat(2,1fr); } }
        @media(max-width:500px) { .an-stats { grid-template-columns: 1fr 1fr; } }

        .an-stat-card {
            background: #fff;
            border-radius: 16px;
            padding: 1.5rem 1.4rem 1.2rem;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            border: 1px solid #eef0f6;
            position: relative;
            overflow: hidden;
        }
        .an-stat-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            border-radius: 16px 16px 0 0;
        }
        .an-stat-card.today::before  { background: var(--primary); }
        .an-stat-card.week::before   { background: #7C3AED; }
        .an-stat-card.month::before  { background: #2D9CDB; }
        .an-stat-card.total::before  { background: #38A169; }

        .an-stat-label {
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: #8a94a6;
            margin-bottom: 0.5rem;
        }
        .an-stat-value {
            font-size: 2.4rem;
            font-weight: 900;
            line-height: 1;
            color: #1a202c;
            letter-spacing: -1px;
        }
        .an-stat-icon {
            position: absolute;
            right: 1.2rem;
            top: 50%;
            transform: translateY(-50%);
            font-size: 2rem;
            opacity: 0.08;
        }
        .an-stat-sub {
            font-size: 0.75rem;
            color: #a0aec0;
            margin-top: 0.35rem;
        }

        /* ── Chart panel ── */
        .an-panel {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            border: 1px solid #eef0f6;
            padding: 1.6rem 1.8rem;
            margin-bottom: 1.5rem;
        }
        .an-panel-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.4rem;
            flex-wrap: wrap;
            gap: 0.5rem;
        }
        .an-panel-title {
            font-size: 1rem;
            font-weight: 800;
            color: #1a202c;
        }
        .an-panel-sub {
            font-size: 0.78rem;
            color: #a0aec0;
        }
        .an-chart-wrap {
            position: relative;
            height: 260px;
        }

        /* ── Top items ── */
        .an-items-grid {
            display: flex;
            flex-direction: column;
            gap: 0.6rem;
        }
        .an-item-row {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 0.75rem 0;
            border-bottom: 1px solid #f1f3f8;
        }
        .an-item-row:last-child { border-bottom: none; }

        .an-item-rank {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: #f7f8fc;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            font-weight: 800;
            color: #8a94a6;
            flex-shrink: 0;
        }
        .an-item-rank.top1 { background: #FFF3CD; color: #B7791F; }
        .an-item-rank.top2 { background: #EDF2F7; color: #4A5568; }
        .an-item-rank.top3 { background: #FFF0EB; color: #C05621; }

        .an-item-img {
            width: 42px; height: 42px;
            border-radius: 10px;
            object-fit: cover;
            background: #f1f3f8;
            flex-shrink: 0;
        }
        .an-item-img-placeholder {
            width: 42px; height: 42px;
            border-radius: 10px;
            background: #f1f3f8;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            flex-shrink: 0;
        }
        .an-item-info { flex: 1; min-width: 0; }
        .an-item-name {
            font-size: 0.88rem;
            font-weight: 600;
            color: #1a202c;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .an-item-cat {
            font-size: 0.72rem;
            color: #a0aec0;
        }
        .an-item-bar-wrap { flex: 1; min-width: 80px; max-width: 160px; }
        .an-item-bar-bg {
            height: 6px;
            background: #f1f3f8;
            border-radius: 99px;
            overflow: hidden;
        }
        .an-item-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--primary), #FF8C42);
            border-radius: 99px;
            transition: width 1s ease;
        }
        .an-item-count {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--primary);
            white-space: nowrap;
            min-width: 48px;
            text-align: right;
        }

        /* ── Empty state ── */
        .an-empty {
            text-align: center;
            padding: 3rem 1rem;
            color: #a0aec0;
        }
        .an-empty .an-empty-icon { font-size: 2.5rem; margin-bottom: 0.75rem; }
        .an-empty p { font-size: 0.875rem; }

        /* ── Two-col layout ── */
        .an-two-col {
            display: grid;
            grid-template-columns: 1.6fr 1fr;
            gap: 1.2rem;
            margin-bottom: 1.5rem;
        }
        @media(max-width:800px) { .an-two-col { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

<div class="admin-layout">

    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <script>$(function(){ $('#nav-analytics').addClass('active'); });</script>

    <div class="admin-main">

        <!-- Hero -->
        <div class="mm-hero">
            <h1>Your Analytics<br><span>Dashboard.</span></h1>
            <p>See how customers are engaging with your digital menu. Track QR scans, daily traffic patterns, and your most-viewed dishes.</p>
        </div>

        <!-- Stat cards -->
        <div class="an-stats">
            <div class="an-stat-card today">
                <div class="an-stat-label">Today's Scans</div>
                <div class="an-stat-value"><c:out value="${todayScans}"/></div>
                <div class="an-stat-sub">QR scans today</div>
                <div class="an-stat-icon">📲</div>
            </div>
            <div class="an-stat-card week">
                <div class="an-stat-label">This Week</div>
                <div class="an-stat-value"><c:out value="${weekScans}"/></div>
                <div class="an-stat-sub">Since Monday</div>
                <div class="an-stat-icon">📅</div>
            </div>
            <div class="an-stat-card month">
                <div class="an-stat-label">This Month</div>
                <div class="an-stat-value"><c:out value="${monthScans}"/></div>
                <div class="an-stat-sub">Since 1st of the month</div>
                <div class="an-stat-icon">📆</div>
            </div>
            <div class="an-stat-card total">
                <div class="an-stat-label">All Time</div>
                <div class="an-stat-value"><c:out value="${totalScans}"/></div>
                <div class="an-stat-sub">Total QR scans ever</div>
                <div class="an-stat-icon">🏆</div>
            </div>
        </div>

        <!-- Chart + Top items side by side -->
        <div class="an-two-col">

            <!-- Daily traffic chart -->
            <div class="an-panel">
                <div class="an-panel-header">
                    <div>
                        <div class="an-panel-title">📈 Daily QR Scans</div>
                        <div class="an-panel-sub">Last 30 days</div>
                    </div>
                </div>
                <div class="an-chart-wrap">
                    <canvas id="dailyChart"></canvas>
                </div>
            </div>

            <!-- Top items -->
            <div class="an-panel">
                <div class="an-panel-header">
                    <div>
                        <div class="an-panel-title">🍽️ Most Viewed Items</div>
                        <div class="an-panel-sub">Top 10 by menu views</div>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty topItems}">
                        <div class="an-empty">
                            <div class="an-empty-icon">🍽️</div>
                            <p>No item views yet.<br>Share your QR code to start collecting data!</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="an-items-grid">
                            <c:set var="maxViews" value="${topItems[0].views}"/>
                            <c:forEach items="${topItems}" var="item" varStatus="s">
                                <div class="an-item-row">
                                    <div class="an-item-rank <c:if test="${s.index==0}">top1</c:if><c:if test="${s.index==1}">top2</c:if><c:if test="${s.index==2}">top3</c:if>">
                                        ${s.index + 1}
                                    </div>

                                    <c:choose>
                                        <c:when test="${not empty item.imagePath}">
                                            <img class="an-item-img"
                                                 src="${pageContext.request.contextPath}/images/<c:out value="${item.imagePath}"/>"
                                                 alt="<c:out value="${item.name}"/>"
                                                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                                            <div class="an-item-img-placeholder" style="display:none">🍽️</div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="an-item-img-placeholder">🍽️</div>
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="an-item-info">
                                        <div class="an-item-name"><c:out value="${item.name}"/></div>
                                        <div class="an-item-cat"><c:out value="${item.category}"/></div>
                                    </div>

                                    <div class="an-item-bar-wrap">
                                        <div class="an-item-bar-bg">
                                            <div class="an-item-bar-fill"
                                                 style="width: <c:choose><c:when test="${maxViews > 0}">${(item.views * 100) / maxViews}</c:when><c:otherwise>0</c:otherwise></c:choose>%">
                                            </div>
                                        </div>
                                    </div>

                                    <div class="an-item-count">${item.views} views</div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Info note -->
        <div style="background:#fff8f5;border:1px solid #ffe0d0;border-radius:12px;padding:1rem 1.2rem;font-size:0.82rem;color:#8a4a2a;display:flex;gap:0.75rem;align-items:flex-start;">
            <span style="font-size:1rem;flex-shrink:0;margin-top:1px;">💡</span>
            <span>Analytics data is collected every time a customer scans your QR code or visits your menu link. Item view counts reflect how many times each dish appeared on a customer's screen. Data updates in real time.</span>
        </div>

    </div><!-- /admin-main -->
</div><!-- /admin-layout -->

<script>
(function() {
    const raw = ${dailyScansJson};
    const labels = raw.map(d => d.label);
    const data   = raw.map(d => d.count);

    const ctx = document.getElementById('dailyChart').getContext('2d');

    // Gradient fill
    const gradient = ctx.createLinearGradient(0, 0, 0, 260);
    gradient.addColorStop(0, 'rgba(255,107,53,0.25)');
    gradient.addColorStop(1, 'rgba(255,107,53,0.0)');

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'QR Scans',
                data: data,
                borderColor: '#FF6B35',
                backgroundColor: gradient,
                borderWidth: 2.5,
                pointRadius: 3,
                pointBackgroundColor: '#FF6B35',
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { mode: 'index', intersect: false },
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: '#1a202c',
                    titleColor: '#fff',
                    bodyColor: '#cbd5e0',
                    padding: 10,
                    cornerRadius: 8,
                    callbacks: {
                        label: ctx => ' ' + ctx.parsed.y + ' scan' + (ctx.parsed.y !== 1 ? 's' : '')
                    }
                }
            },
            scales: {
                x: {
                    grid: { display: false },
                    ticks: {
                        color: '#a0aec0',
                        font: { size: 10 },
                        maxTicksLimit: 10
                    }
                },
                y: {
                    beginAtZero: true,
                    grid: { color: '#f1f3f8' },
                    ticks: {
                        color: '#a0aec0',
                        font: { size: 10 },
                        stepSize: 1,
                        precision: 0
                    }
                }
            }
        }
    });
})();
</script>

</body>
</html>
