<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="selfQs" value="scanner=${current.id}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex">
    <title><c:out value="${empty current ? 'Review QR' : current.businessName}"/> — Review QR Dashboard</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/css/style.css?v=3">
    <style>
        :root {
            --bar: #3987e5;          /* single series colour (validated dark-surface blue) */
            --bar-dim: #2a4a72;
            --line: rgba(255,255,255,0.08);
        }
        body { background: var(--surface); }
        .topbar {
            position: sticky; top: 0; z-index: 50; display: flex; align-items: center; justify-content: space-between; gap: .75rem;
            padding: .8rem 1.25rem; background: rgba(19,19,19,.9); backdrop-filter: blur(10px); border-bottom: 1px solid var(--line);
        }
        .ob-brand { display: flex; align-items: center; gap: .6rem; min-width: 0; }
        .ob-brand .logo { width: 34px; height: 34px; border-radius: 10px; display: grid; place-items: center; font-weight: 900; color: #fff; flex: none;
                       background: conic-gradient(#4285F4 0 25%, #EA4335 0 50%, #FBBC05 0 75%, #34A853 0); }
        .ob-brand .logo span { width: 26px; height: 26px; border-radius: 7px; background: var(--surface); display: grid; place-items: center; font-size: .9rem; color: #FBBC05; }
        .ob-brand b { display: block; font-size: .95rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .ob-brand small { display: block; font-size: .7rem; color: var(--on-surface-muted); }
        .logout { background: none; border: 1px solid var(--line); color: var(--on-surface-muted); padding: .4rem .8rem; border-radius: .5rem; font-size: .78rem; cursor: pointer; font-family: inherit; }
        .logout:hover { color: var(--on-surface); border-color: var(--on-surface-muted); }

        .wrap { max-width: 980px; margin: 0 auto; padding: 1.25rem 1rem 4rem; }
        .row-between { display: flex; align-items: center; justify-content: space-between; gap: .75rem; flex-wrap: wrap; }

        .switcher select { background: var(--surface-container); color: var(--on-surface); border: 1px solid var(--line); border-radius: .6rem; padding: .5rem .75rem; font-family: inherit; font-size: .85rem; }

        .tabs { display: flex; gap: .25rem; background: var(--surface-container); border: 1px solid var(--line); padding: .25rem; border-radius: .8rem; margin: 1rem 0 1.25rem; }
        .tabs a { flex: 1; text-align: center; padding: .6rem .5rem; border-radius: .6rem; font-size: .88rem; font-weight: 600; color: var(--on-surface-muted); text-decoration: none; }
        .tabs a.on { background: var(--surface-container-highest); color: var(--on-surface); }

        .panel { background: var(--surface-container); border: 1px solid var(--line); border-radius: 1rem; padding: 1.1rem 1.15rem; margin-bottom: 1rem; }
        .panel h2 { font-size: 1rem; margin: 0 0 .2rem; }
        .panel .hint { font-size: .78rem; color: var(--on-surface-muted); margin: 0 0 1rem; line-height: 1.5; }

        /* Month nav */
        .month-nav { display: flex; align-items: center; gap: .5rem; }
        .month-nav a, .month-nav span.dis { width: 34px; height: 34px; display: grid; place-items: center; border-radius: .6rem; border: 1px solid var(--line); color: var(--on-surface); text-decoration: none; font-weight: 700; }
        .month-nav span.dis { opacity: .3; }
        .month-nav strong { min-width: 9.5rem; text-align: center; font-size: .95rem; }

        /* KPI tiles */
        .kpis { display: grid; grid-template-columns: repeat(3, 1fr); gap: .75rem; margin: 1rem 0; }
        .kpi { background: var(--surface-container); border: 1px solid var(--line); border-radius: 1rem; padding: 1rem; min-width: 0; }
        .kpi .lbl { font-size: .74rem; color: var(--on-surface-muted); font-weight: 600; }
        .kpi .num { font-size: 2rem; font-weight: 800; line-height: 1.1; margin-top: .25rem; font-variant-numeric: tabular-nums; }
        .kpi .delta { font-size: .74rem; color: var(--on-surface-muted); margin-top: .2rem; }
        .kpi .app-name { display: flex; align-items: center; gap: .45rem; font-size: 1.15rem; font-weight: 800; margin-top: .45rem; }
        .kpi .pi { width: 22px; height: 22px; flex: none; }

        /* Column charts */
        .cols { display: flex; align-items: flex-end; gap: 3px; height: 160px; padding-top: 1.4rem; border-bottom: 1px solid var(--line); }
        .cols.short { height: 120px; gap: 6px; }
        .col { flex: 1; height: 100%; display: flex; align-items: flex-end; position: relative; outline: none; cursor: default; }
        .col i { display: block; width: 100%; background: var(--bar); border-radius: 4px 4px 0 0; min-height: 0; transition: filter .15s; }
        .col.zero i { height: 2px !important; background: var(--bar-dim); border-radius: 2px; }
        .col:hover i, .col:focus i { filter: brightness(1.25); }
        .col .tip {
            position: absolute; bottom: calc(100% + 6px); left: 50%; transform: translateX(-50%);
            background: #f0efec; color: #0b0b0b; font-size: .72rem; font-weight: 600; white-space: nowrap;
            padding: .3rem .5rem; border-radius: .4rem; pointer-events: none; display: none; z-index: 5;
            box-shadow: 0 4px 14px rgba(0,0,0,.4);
        }
        .col:hover .tip, .col:focus .tip { display: block; }
        /* Edge bars: anchor the tooltip inwards so it never runs off the screen */
        .col:nth-child(-n+4) .tip      { left: 0; transform: none; }
        .col:nth-last-child(-n+4) .tip { left: auto; right: 0; transform: none; }
        .cols:not(.short) .col:nth-child(-n+8) .tip      { left: 0; transform: none; }
        .cols:not(.short) .col:nth-last-child(-n+8) .tip { left: auto; right: 0; transform: none; }
        .xlabels { display: flex; gap: 3px; margin-top: .35rem; }
        .xlabels.short { gap: 6px; }
        .xlabels span { flex: 1; text-align: center; font-size: .64rem; color: var(--on-surface-muted); min-width: 0; overflow: visible; white-space: nowrap; }
        .two { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }

        /* App rows */
        .apps { display: grid; gap: .85rem; }
        .app-row { display: grid; grid-template-columns: 28px 1fr auto; align-items: center; gap: .3rem .7rem; }
        .app-row .pi { width: 26px; height: 26px; grid-row: span 2; }
        .app-row .nm { font-size: .88rem; font-weight: 600; }
        .app-row .nm small { color: var(--on-surface-muted); font-weight: 500; }
        .app-row .val { font-weight: 800; font-variant-numeric: tabular-nums; grid-row: span 2; font-size: 1.1rem; }
        .track { height: 10px; background: rgba(255,255,255,.05); border-radius: 0 4px 4px 0; overflow: hidden; }
        .track i { display: block; height: 100%; background: var(--bar); border-radius: 0 4px 4px 0; min-width: 2px; }

        .empty { text-align: center; padding: 2rem 1rem; color: var(--on-surface-muted); font-size: .9rem; }
        .empty b { display: block; font-size: 2rem; margin-bottom: .4rem; }
        details.tbl { margin-top: .75rem; font-size: .78rem; color: var(--on-surface-muted); }
        details.tbl summary { cursor: pointer; }
        details.tbl table { width: 100%; border-collapse: collapse; margin-top: .5rem; }
        details.tbl td, details.tbl th { padding: .3rem .4rem; border-bottom: 1px solid var(--line); text-align: left; }
        details.tbl td:last-child, details.tbl th:last-child { text-align: right; font-variant-numeric: tabular-nums; }

        .report { width: 100%; min-height: 170px; background: var(--surface-container-low); color: var(--on-surface); border: 1px solid var(--line); border-radius: .6rem; padding: .75rem; font-family: inherit; font-size: .85rem; resize: vertical; }
        .btns { display: flex; gap: .6rem; flex-wrap: wrap; margin-top: .75rem; }
        .btn-wa { background: #25d366; color: #fff; border: none; }

        /* Links form */
        .flow { display: flex; align-items: center; gap: .6rem; padding: .8rem .9rem; border-radius: .8rem; background: var(--surface-container-low); border: 1px dashed var(--line); font-size: .85rem; margin-bottom: 1rem; }
        .flow b { color: var(--on-surface); }
        .link-field { display: grid; grid-template-columns: 42px 1fr; gap: .25rem .75rem; align-items: center; margin-bottom: 1rem; }
        .link-field .ic { width: 42px; height: 42px; border-radius: 12px; background: #fff; display: grid; place-items: center; grid-row: span 2; }
        .link-field .ic .pi { width: 24px; height: 24px; }
        .link-field label { font-size: .82rem; font-weight: 600; margin: 0; }
        .link-field input { width: 100%; padding: .65rem .85rem; background: var(--surface-container-lowest); border: 1px solid transparent;
                            border-radius: var(--radius-lg); font-size: .9rem; color: var(--on-surface); font-family: inherit; }
        .link-field input::placeholder { color: var(--on-surface-muted); }
        .link-field input:focus { outline: none; border-color: rgba(245,124,0,.45); box-shadow: 0 0 0 3px rgba(245,124,0,.08); }
        .link-field .fh { grid-column: 2; font-size: .72rem; color: var(--on-surface-muted); line-height: 1.45; }
        .state { font-size: .7rem; font-weight: 700; padding: .2rem .55rem; border-radius: 999px; letter-spacing: .04em; }
        .state.live { background: rgba(34,197,94,.15); color: #22c55e; }
        .state.paused { background: rgba(239,68,68,.12); color: #ef4444; }

        .greet { margin: .25rem 0; }
        .greet h1 { font-size: 1.5rem; font-weight: 800; letter-spacing: -.02em; margin: 0; }
        .greet p { margin: .15rem 0 0; font-size: .85rem; color: var(--on-surface-muted); }
        .greet .sid { display: inline-flex; align-items: center; gap: .4rem; margin-top: .55rem; padding: .3rem .75rem;
                      border-radius: 999px; background: #f1ecf7; color: var(--on-surface-muted); font-size: .76rem; }
        .greet .sid b { color: #5b3fa8; font-weight: 800; letter-spacing: .04em; }
        .greet .wave { display: inline-block; transform-origin: 70% 70%; animation: wave 2.4s .4s ease-in-out 2; }
        @keyframes wave { 0%,60%,100% { transform: rotate(0); } 10%,30% { transform: rotate(16deg); } 20%,40% { transform: rotate(-10deg); } }

        /* VIP Club list */
        .kpis.vip-kpis { grid-template-columns: 1fr; }
        .tbl-wrap { overflow-x: auto; margin-top: .5rem; }
        table.contacts { width: 100%; border-collapse: collapse; font-size: .86rem; }
        table.contacts th { text-align: left; font-size: .72rem; font-weight: 600; color: var(--on-surface-muted); padding: .5rem .6rem; border-bottom: 1px solid var(--line); white-space: nowrap; }
        table.contacts td { padding: .65rem .6rem; border-bottom: 1px solid var(--line); white-space: nowrap; }
        table.contacts td a { color: #25d366; font-weight: 600; }
        table.contacts td.when { color: var(--on-surface-muted); font-size: .78rem; }
        .tabs a { white-space: nowrap; }
        table.contacts .ck { width: 1%; padding-right: 0; }
        table.contacts input[type=checkbox], #selAll { width: 18px; height: 18px; accent-color: #25d366; cursor: pointer; }
        .sel-bar { display: flex; align-items: center; justify-content: space-between; gap: .75rem; margin-top: .75rem; font-size: .85rem; color: var(--on-surface-muted); }
        .sel-bar .btn:disabled { opacity: .45; cursor: not-allowed; }
        .add-vip { display: grid; grid-template-columns: 1fr 1fr auto; gap: .5rem .75rem; align-items: end; padding: .9rem; margin: .5rem 0 1rem; border-radius: .8rem; background: var(--surface-container-low); border: 1px dashed var(--line); }
        .add-vip[hidden], .panel[hidden] { display: none; }
        .add-vip .form-group { margin: 0; }
        .wa-bubble { margin-top: .35rem; padding: .7rem .85rem; border-radius: .2rem .9rem .9rem .9rem; background: #dcf8c6; color: #111; font-size: .88rem; line-height: 1.45; word-break: break-word; max-width: 420px; }
        #msgPreview { white-space: pre-wrap; }
        .wa-photo { position: relative; margin: -.4rem -.55rem .6rem; }
        .wa-photo[hidden], .wa-link[hidden] { display: none; }
        .wa-photo img { display: block; width: 100%; max-height: 320px; object-fit: cover; border-radius: .6rem; }
        .photo-x { position: absolute; top: .4rem; right: .4rem; width: 30px; height: 30px; border-radius: 50%; border: none;
                   background: rgba(0,0,0,.6); color: #fff; font-size: .85rem; cursor: pointer; }
        .wa-link { margin-top: .5rem; color: #075e54; font-size: .82rem; }
        .attach { display: flex; align-items: center; gap: .75rem; flex-wrap: wrap; margin-top: .6rem; }
        .attach-note { font-size: .75rem; color: var(--on-surface-muted); }
        .attach-note.err { color: #ef4444; }
        .queue { list-style: none; margin: .5rem 0 0; padding: 0; }
        .queue li { display: flex; align-items: center; gap: .75rem; padding: .65rem .2rem; border-bottom: 1px solid var(--line); font-size: .88rem; }
        .queue li .who { flex: 1; min-width: 0; }
        .queue li .who small { display: block; color: var(--on-surface-muted); font-size: .75rem; }
        .queue li.sent { opacity: .55; }
        .queue li.sent .btn-wa { background: transparent; color: #22c55e; border: 1px solid rgba(34,197,94,.4); }
        .history { list-style: none; margin: .5rem 0 0; padding: 0; }
        .history li { display: flex; align-items: center; gap: .75rem; padding: .7rem .2rem; border-bottom: 1px solid var(--line); font-size: .86rem; }
        .history .who { flex: 1; min-width: 0; }
        .history .msg { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .history small { display: block; color: var(--on-surface-muted); font-size: .75rem; margin-top: .15rem; }
        .history .btn { padding: .4rem .8rem; font-size: .8rem; }
        .queue-error { color: #ef4444; font-size: .82rem; margin-top: .5rem; }

        @media (max-width: 640px) {
            .kpis.vip-kpis .kpi:first-child { grid-column: auto; }
            .tabs a { font-size: .78rem; padding: .6rem .3rem; }
            .kpis { grid-template-columns: 1fr 1fr; }
            .kpis .kpi:first-child { grid-column: span 2; }
            .two { grid-template-columns: 1fr; }
            .add-vip { grid-template-columns: 1fr; }
            .cols { gap: 2px; }
            .xlabels { gap: 2px; }
        }
    </style>
</head>
<body>

<header class="topbar">
    <div class="ob-brand">
        <div class="logo" aria-hidden="true"><span>&#9733;</span></div>
        <div style="min-width:0">
            <b><c:out value="${empty current ? 'Review QR' : current.businessName}"/></b>
            <small>Review QR dashboard</small>
        </div>
    </div>
    <form method="post" action="${ctx}/review/logout">
        <button class="logout" type="submit">Log out</button>
    </form>
</header>

<div class="wrap">
    <div class="greet">
        <h1>Hi<c:if test="${not empty ownerFirstName}"> <c:out value="${ownerFirstName}"/></c:if> <span class="wave" aria-hidden="true">&#128075;</span></h1>
        <p>Here's how your QR is doing.</p>
        <c:if test="${not empty current}">
            <div class="sid" title="Share this ID with Bijwala Solutions when you need help">Your scanner unique ID <b><c:out value="${current.stickerNo}"/></b></div>
        </c:if>
    </div>
    <c:if test="${not empty loadError}"><div class="alert alert-error"><c:out value="${loadError}"/></div></c:if>

    <c:choose>
    <c:when test="${empty current}">
        <div class="panel empty">
            <b>&#128279;</b>
            No QR sticker is linked to your account yet.<br>Please contact the person who set up your account.
        </div>
    </c:when>
    <c:otherwise>

    <c:if test="${fn:length(scanners) > 1}">
        <form class="switcher row-between" method="get" action="${ctx}/review/dashboard">
            <input type="hidden" name="tab" value="${tab}">
            <input type="hidden" name="month" value="${month}">
            <label for="sw" style="font-size:.8rem;color:var(--on-surface-muted)">Sticker</label>
            <select id="sw" name="scanner" onchange="this.form.submit()">
                <c:forEach var="s" items="${scanners}">
                    <option value="${s.id}" ${s.id == current.id ? 'selected' : ''}><c:out value="${s.stickerNo}"/> · <c:out value="${s.businessName}"/></option>
                </c:forEach>
            </select>
        </form>
    </c:if>

    <nav class="tabs">
        <a href="${ctx}/review/dashboard?tab=analytics&${selfQs}" class="${tab eq 'analytics' ? 'on' : ''}">&#128202; Analytics</a>
        <a href="${ctx}/review/dashboard?tab=customers&${selfQs}" class="${tab eq 'customers' ? 'on' : ''}">&#128081; VIP Club</a>
        <a href="${ctx}/review/dashboard?tab=links&${selfQs}" class="${tab eq 'links' ? 'on' : ''}">&#128279; Links &amp; settings</a>
    </nav>

    <%-- ═══════════════════════ VIP CLUB (customers) ═══════════════════════ --%>
    <c:if test="${tab eq 'customers'}">
        <div class="kpis vip-kpis">
            <div class="kpi">
                <div class="lbl">VIP Club members</div>
                <div class="num">${fn:length(contacts)}</div>
                <div class="delta">Customers who left their WhatsApp number</div>
            </div>
        </div>

        <c:if test="${param.vipAdded eq '1'}"><div class="alert alert-success">Customer added to your VIP Club.</div></c:if>
        <c:if test="${not empty param.vipError}"><div class="alert alert-error"><c:out value="${param.vipError}"/></div></c:if>

        <div class="panel" id="vipList">
            <div class="row-between" style="margin-bottom:.35rem">
                <h2>Your VIP Club list</h2>
                <div class="btns" style="margin-top:0">
                    <button type="button" class="btn btn-primary" onclick="toggleAddVip()">&#10133; Add VIP</button>
                    <c:if test="${not empty contacts}">
                        <a class="btn btn-outline" href="${ctx}/review/dashboard?tab=customers&${selfQs}&export=csv">&#11015; Download Excel (CSV)</a>
                    </c:if>
                </div>
            </div>
            <form id="addVip" class="add-vip" method="post" action="${ctx}/review/dashboard" hidden>
                <input type="hidden" name="action" value="addContact">
                <input type="hidden" name="scanner" value="${current.id}">
                <div class="form-group"><label for="vipName">Name</label><input type="text" id="vipName" name="name" required minlength="2" maxlength="100" placeholder="e.g. Ayesha Khan"></div>
                <div class="form-group"><label for="vipPhone">WhatsApp number</label><input type="tel" id="vipPhone" name="phone" required inputmode="numeric" placeholder="10-digit mobile"></div>
                <button type="submit" class="btn btn-primary">Save</button>
                <p class="hint" style="grid-column:1/-1;margin:0">Only add customers who agreed to get offers on WhatsApp.</p>
            </form>
            <p class="hint">
                <c:choose>
                    <c:when test="${current.joinForm}">Customers who scan your QR can tap <b style="color:var(--on-surface)">&ldquo;Join our VIP Club&rdquo;</b> and leave their details. Use this list to send offers on WhatsApp.</c:when>
                    <c:otherwise>The VIP Club form is <b style="color:var(--on-surface)">switched off</b> for this sticker. Ask us to switch it on to start collecting customers.</c:otherwise>
                </c:choose>
            </p>
            <c:choose>
                <c:when test="${empty contacts}">
                    <div class="empty" style="padding:1.5rem 0 .5rem">
                        <b>&#128081;</b>
                        No members yet. Tell customers: &ldquo;Scan the QR and join our VIP Club for special offers!&rdquo;
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="sel-bar">
                        <span id="selCount">0 selected</span>
                        <button type="button" class="btn btn-wa" id="nextBtn" onclick="openCompose()" disabled>Next &rsaquo;</button>
                    </div>
                    <div class="tbl-wrap">
                        <table class="contacts">
                            <thead><tr><th class="ck"><input type="checkbox" id="selAll" aria-label="Select all" onchange="selectAll(this.checked)"></th><th>Name</th><th>Age</th><th>Gender</th><th>WhatsApp</th><th>Joined</th></tr></thead>
                            <tbody>
                            <c:forEach var="m" items="${contacts}">
                                <tr>
                                    <td class="ck"><input type="checkbox" class="vip-ck" data-name="<c:out value='${m.name}'/>" data-phone="${m.phone}" aria-label="Select <c:out value='${m.name}'/>" onchange="updateSel()"></td>
                                    <td><c:out value="${m.name}"/></td>
                                    <td>${empty m.age ? '—' : m.age}</td>
                                    <td><c:out value="${empty m.gender ? '—' : m.gender}"/></td>
                                    <td><a href="https://wa.me/91${m.phone}" target="_blank" rel="noopener">+91 ${m.phone}</a></td>
                                    <td class="when"><fmt:formatDate value="${m.createdAt}" pattern="dd MMM, hh:mm a"/></td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <c:if test="${not empty broadcasts}">
            <div class="panel" id="vipHistory">
                <h2>Offers sent</h2>
                <p class="hint">Your last ${fn:length(broadcasts)} offers. Tap <b style="color:var(--on-surface)">Open</b> to see who got it or to finish sending.</p>
                <ul class="history">
                    <c:forEach var="b" items="${broadcasts}">
                        <li class="bc" data-id="${b.id}" data-message="<c:out value='${b.message}'/>" data-link="<c:out value='${b.offerUrl}'/>">
                            <div class="who">
                                <div class="msg"><c:if test="${not empty b.imagePath}">&#128248; </c:if><c:out value="${b.message}"/></div>
                                <small><fmt:formatDate value="${b.createdAt}" pattern="dd MMM yyyy, hh:mm a"/> &middot; sent to ${b.sentCount} of ${b.total}</small>
                            </div>
                            <span class="state ${b.sentCount == b.total ? 'live' : 'paused'}">${b.sentCount}/${b.total}</span>
                            <button type="button" class="btn btn-outline" onclick="openHistory(this.closest('.bc'))">Open</button>
                            <c:forEach var="r" items="${b.recipients}">
                                <i hidden class="rcpt" data-name="<c:out value='${r.name}'/>" data-phone="${r.phone}" data-sent="${r.sent}"></i>
                            </c:forEach>
                        </li>
                    </c:forEach>
                </ul>
            </div>
        </c:if>

        <%-- Step 2: write the offer --%>
        <div class="panel" id="vipCompose" hidden>
            <h2>Write your offer</h2>
            <p class="hint">Sending to <b style="color:var(--on-surface)" id="composeCount"></b>. Type <code>{name}</code> where the customer's name should go.</p>
            <textarea id="vipMsg" class="report" maxlength="1000" oninput="renderPreview()">Hi {name}! &#127881; Special offer for our VIP Club members at <c:out value="${current.businessName}"/>: </textarea>
            <div class="attach">
                <input type="file" id="offerFile" accept="image/jpeg,image/png" hidden onchange="uploadOfferImage(this)">
                <button type="button" class="btn btn-outline" id="attachBtn" onclick="document.getElementById('offerFile').click()">&#128206; Add photo</button>
                <span class="attach-note" id="attachNote">Optional. JPG or PNG, up to 5 MB.</span>
            </div>
            <div class="lbl" style="margin-top:.75rem;font-size:.72rem;color:var(--on-surface-muted)">Preview</div>
            <div class="wa-bubble" id="msgBubble">
                <div class="wa-photo" id="photoWrap" hidden>
                    <img id="photoPreview" alt="Offer photo">
                    <button type="button" class="photo-x" onclick="removeOfferImage()" aria-label="Remove photo">&#10005;</button>
                </div>
                <div id="msgPreview"></div>
                <div class="wa-link" id="linkPreview" hidden>&#128248; See the offer: <u>link added when you confirm</u></div>
            </div>
            <div class="btns">
                <button type="button" class="btn btn-outline" onclick="showStep('vipList')">&lsaquo; Back</button>
                <button type="button" class="btn btn-wa" onclick="openQueue()">Confirm</button>
            </div>
        </div>

        <%-- Step 3: send one by one from the owner's own WhatsApp --%>
        <div class="panel" id="vipQueue" hidden>
            <div class="row-between" style="margin-bottom:.35rem">
                <h2>Send on WhatsApp</h2>
                <span class="state live" id="queueProgress"></span>
            </div>
            <p class="hint">Tap <b style="color:var(--on-surface)">Send</b>. WhatsApp opens with your message ready. Press send there, come back, and tap the next one. Progress is saved, so you can finish later from &ldquo;Offers sent&rdquo;.</p>
            <ul class="queue" id="queueList"></ul>
            <div class="btns">
                <a class="btn btn-outline" href="${ctx}/review/dashboard?tab=customers&${selfQs}">Done</a>
            </div>
        </div>
    </c:if>

    <%-- ═══════════════════════ ANALYTICS ═══════════════════════ --%>
    <c:if test="${tab eq 'analytics' and not empty a}">
        <div class="row-between">
            <div class="month-nav">
                <a href="${ctx}/review/dashboard?tab=analytics&${selfQs}&month=${prevMonth}" aria-label="Previous month">&#8249;</a>
                <strong><c:out value="${monthLabel}"/></strong>
                <c:choose>
                    <c:when test="${not empty nextMonth}"><a href="${ctx}/review/dashboard?tab=analytics&${selfQs}&month=${nextMonth}" aria-label="Next month">&#8250;</a></c:when>
                    <c:otherwise><span class="dis" aria-hidden="true">&#8250;</span></c:otherwise>
                </c:choose>
            </div>
            <span style="font-size:.74rem;color:var(--on-surface-muted)">Sticker <c:out value="${current.stickerNo}"/></span>
        </div>

        <div class="kpis">
            <div class="kpi">
                <div class="lbl">Customers who scanned</div>
                <div class="num">${a.totalScans}</div>
                <div class="delta">
                    <c:choose>
                        <c:when test="${empty a.changePct}">${isCurrentMonth ? 'so far this month' : 'in this month'}</c:when>
                        <c:when test="${a.changePct > 0}">&#9650; ${a.changePct}% vs last month (${a.previousMonthScans})</c:when>
                        <c:when test="${a.changePct < 0}">&#9660; ${-a.changePct}% vs last month (${a.previousMonthScans})</c:when>
                        <c:otherwise>Same as last month (${a.previousMonthScans})</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="kpi">
                <div class="lbl">Trips to your apps</div>
                <div class="num">${a.totalClicks}</div>
                <div class="delta">Google, Instagram &amp; more</div>
            </div>
            <div class="kpi">
                <div class="lbl">Most opened</div>
                <c:choose>
                    <c:when test="${not empty a.topApp}">
                        <c:set var="iconKey" value="${a.topApp.platform.key}"/>
                        <div class="app-name"><%@ include file="_platform-icon.jspf" %><c:out value="${a.topApp.platform.label}"/></div>
                        <div class="delta">${a.topApp.value} trips</div>
                    </c:when>
                    <c:otherwise><div class="num">—</div></c:otherwise>
                </c:choose>
            </div>
        </div>

        <c:choose>
        <c:when test="${a.totalScans == 0 and a.totalClicks == 0}">
            <div class="panel empty">
                <b>&#128247;</b>
                No scans in <c:out value="${monthLabel}"/> yet.<br>
                Keep the QR where customers can see it, like the counter or the reception desk, and ask them to scan it.
            </div>
        </c:when>
        <c:otherwise>

        <div class="panel">
            <h2>Scans per day</h2>
            <p class="hint">How many customers scanned the QR each day. Tap or hover a bar to see the number.</p>
            <div class="cols" role="img" aria-label="Scans per day in ${monthLabel}">
                <c:forEach var="b" items="${a.daily}">
                    <div class="col ${b.value == 0 ? 'zero' : ''}" tabindex="0">
                        <i style="height:${b.pct}%"></i>
                        <span class="tip"><c:out value="${b.fullLabel}"/>: ${b.value} scan${b.value == 1 ? '' : 's'}</span>
                    </div>
                </c:forEach>
            </div>
            <div class="xlabels" aria-hidden="true">
                <c:forEach var="b" items="${a.daily}" varStatus="st">
                    <span style="${st.index % 5 == 0 ? '' : 'visibility:hidden'}">${b.label}</span>
                </c:forEach>
            </div>
            <details class="tbl">
                <summary>Show as table</summary>
                <table><tr><th>Day</th><th>Scans</th></tr>
                    <c:forEach var="b" items="${a.daily}"><c:if test="${b.value > 0}"><tr><td><c:out value="${b.fullLabel}"/></td><td>${b.value}</td></tr></c:if></c:forEach>
                </table>
            </details>
        </div>

        <div class="panel">
            <h2>Where customers went</h2>
            <p class="hint">Which app customers opened from your QR. One customer can open more than one app.</p>
            <div class="apps">
                <c:forEach var="r" items="${a.apps}">
                    <c:set var="iconKey" value="${r.platform.key}"/>
                    <div class="app-row">
                        <%@ include file="_platform-icon.jspf" %>
                        <div class="nm"><c:out value="${r.platform.label}"/><c:if test="${not r.configured}"> <small>(link removed)</small></c:if></div>
                        <div class="val">${r.value}</div>
                        <div class="track"><i style="width:${r.pct}%"></i></div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <div class="two">
            <div class="panel">
                <h2>Busiest days</h2>
                <p class="hint"><c:if test="${not empty a.busiestDay}">Most scans on <b style="color:var(--on-surface)"><c:out value="${a.busiestDay}"/></b>.</c:if>&nbsp;</p>
                <div class="cols short">
                    <c:forEach var="b" items="${a.days}">
                        <div class="col ${b.value == 0 ? 'zero' : ''}" tabindex="0">
                            <i style="height:${b.pct}%"></i>
                            <span class="tip"><c:out value="${b.fullLabel}"/>: ${b.value}</span>
                        </div>
                    </c:forEach>
                </div>
                <div class="xlabels short" aria-hidden="true"><c:forEach var="b" items="${a.days}"><span>${b.label}</span></c:forEach></div>
            </div>
            <div class="panel">
                <h2>Busiest time</h2>
                <p class="hint"><c:if test="${not empty a.busiestTime}">Most scans between <b style="color:var(--on-surface)"><c:out value="${a.busiestTime}"/></b>.</c:if>&nbsp;</p>
                <div class="cols short">
                    <c:forEach var="b" items="${a.hours}">
                        <div class="col ${b.value == 0 ? 'zero' : ''}" tabindex="0">
                            <i style="height:${b.pct}%"></i>
                            <span class="tip"><c:out value="${b.fullLabel}"/>: ${b.value}</span>
                        </div>
                    </c:forEach>
                </div>
                <div class="xlabels short" aria-hidden="true">
                    <c:forEach var="b" items="${a.hours}" varStatus="st"><span style="${st.index % 3 == 0 ? '' : 'visibility:hidden'}">${b.label}</span></c:forEach>
                </div>
            </div>
        </div>

        </c:otherwise>
        </c:choose>

        <div class="panel">
            <h2>&#128221; Monthly report</h2>
            <p class="hint">A short summary you can save or send on WhatsApp. These are QR scans, not reviews. Google doesn't tell anyone who actually posted a review.</p>
            <textarea class="report" id="reportText" readonly><c:out value="${reportText}"/></textarea>
            <div class="btns">
                <a class="btn btn-wa" href="<c:out value="${reportWa}"/>" target="_blank" rel="noopener">Share on WhatsApp</a>
                <button type="button" class="btn btn-outline" id="copyBtn" onclick="copyReport()">Copy</button>
            </div>
        </div>
    </c:if>

    <%-- ═══════════════════════ LINKS ═══════════════════════ --%>
    <c:if test="${tab eq 'links'}">
        <c:if test="${param.saved eq '1'}"><div class="alert alert-success">Links saved. Your QR uses them right away, no new sticker needed.</div></c:if>
        <c:if test="${not empty param.error}"><div class="alert alert-error"><c:out value="${param.error}"/></div></c:if>

        <div class="panel">
            <div class="row-between" style="margin-bottom:.35rem">
                <h2>Where your QR sends customers</h2>
                <span class="state ${current.active ? 'live' : 'paused'}">${current.active ? 'LIVE' : 'PAUSED'}</span>
            </div>
            <p class="hint">Add the links you want. Leave a box empty to hide that app.</p>

            <div class="flow">
                <span style="font-size:1.3rem" aria-hidden="true">&#128073;</span>
                <span>
                    <c:choose>
                        <c:when test="${current.linkCount == 1 and not current.joinForm}">Customers go <b>straight to <c:forEach var="e" items="${current.links}"><c:out value="${e.key.label}"/></c:forEach></b> when they scan.</c:when>
                        <c:when test="${current.linkCount == 0}">Customers see just the <b>&ldquo;Join our VIP Club&rdquo;</b> form. Add your links below to show those buttons too.</c:when>
                        <c:otherwise>Customers see a page with <b>${current.linkCount} button${current.linkCount == 1 ? '' : 's'}</b><c:if test="${current.joinForm}"> and the VIP Club form</c:if>.</c:otherwise>
                    </c:choose>
                    <a href="<c:out value="${previewUrl}"/>" target="_blank" rel="noopener" style="white-space:nowrap">Preview &#8599;</a>
                </span>
            </div>

            <form method="post" action="${ctx}/review/dashboard">
                <input type="hidden" name="action" value="saveLinks">
                <input type="hidden" name="scanner" value="${current.id}">
                <c:forEach var="p" items="${platforms}">
                    <c:set var="iconKey" value="${p.key}"/>
                    <div class="link-field">
                        <div class="ic"><%@ include file="_platform-icon.jspf" %></div>
                        <label for="f-${p.key}"><c:out value="${p.label}"/><c:if test="${p.key eq 'google'}"> review link</c:if></label>
                        <input type="${p.key eq 'instagram' ? 'text' : 'url'}" id="f-${p.key}" name="${p.key}" maxlength="500"
                               value="<c:out value="${current.linksByKey[p.key]}"/>"
                               placeholder="${p.key eq 'google' ? 'https://g.page/r/.../review' : (p.key eq 'instagram' ? '@yourpage or instagram.com/yourpage' : (p.key eq 'facebook' ? 'facebook.com/yourpage' : (p.key eq 'whatsapp' ? 'https://whatsapp.com/channel/...' : 'youtube.com/@yourchannel')))}">
                        <div class="fh">
                            <c:choose>
                                <c:when test="${p.key eq 'google'}">Google Business Profile &rarr; <b>Ask for reviews</b> &rarr; copy link. It opens the "write a review" box directly.</c:when>
                                <c:when test="${p.key eq 'instagram'}">Your Instagram username or profile link.</c:when>
                                <c:when test="${p.key eq 'facebook'}">Your Facebook page link.</c:when>
                                <c:when test="${p.key eq 'whatsapp'}">WhatsApp &rarr; Updates &rarr; your channel &rarr; <b>Share</b> &rarr; copy link.</c:when>
                                <c:otherwise>Your YouTube channel link.</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
                <button type="submit" class="btn btn-primary">Save links</button>
            </form>
        </div>

        <div class="panel" id="password">
            <h2>Change password</h2>
            <p class="hint">You log in with <b style="color:var(--on-surface)">+91 <c:out value="${sessionScope.reviewOwnerPhone}"/></b>.</p>
            <c:if test="${param.pwSaved eq '1'}"><div class="alert alert-success">Password changed.</div></c:if>
            <c:if test="${not empty param.pwError}"><div class="alert alert-error"><c:out value="${param.pwError}"/></div></c:if>
            <form method="post" action="${ctx}/review/dashboard#password" style="max-width:360px">
                <input type="hidden" name="action" value="changePassword">
                <input type="hidden" name="scanner" value="${current.id}">
                <div class="form-group"><label for="cp">Current password</label><input type="password" id="cp" name="currentPassword" required autocomplete="current-password"></div>
                <div class="form-group"><label for="np">New password</label><input type="password" id="np" name="newPassword" required minlength="6" autocomplete="new-password"></div>
                <div class="form-group"><label for="np2">New password again</label><input type="password" id="np2" name="confirmPassword" required minlength="6" autocomplete="new-password"></div>
                <button type="submit" class="btn btn-outline">Change password</button>
            </form>
        </div>
    </c:if>

    </c:otherwise>
    </c:choose>
</div>

<script>
function copyReport() {
    var box = document.getElementById('reportText');
    var done = function () { document.getElementById('copyBtn').textContent = 'Copied ✓'; };
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(box.value).then(done);
    } else {
        box.select(); document.execCommand('copy'); done();
    }
}

/* ── VIP Club: pick customers → write offer → send one by one from the owner's WhatsApp ── */
var picked = [];

function toggleAddVip() {
    var f = document.getElementById('addVip');
    f.hidden = !f.hidden;
    if (!f.hidden) document.getElementById('vipName').focus();
}

function boxes() { return Array.prototype.slice.call(document.querySelectorAll('.vip-ck')); }

function selectAll(on) { boxes().forEach(function (b) { b.checked = on; }); updateSel(); }

function updateSel() {
    var all = boxes(), n = all.filter(function (b) { return b.checked; }).length;
    document.getElementById('selCount').textContent = n + ' selected';
    document.getElementById('nextBtn').disabled = n === 0;
    var sa = document.getElementById('selAll');
    sa.checked = n > 0 && n === all.length;
    sa.indeterminate = n > 0 && n < all.length;
}

function showStep(id) {
    ['vipList', 'vipHistory', 'vipCompose', 'vipQueue'].forEach(function (s) {
        var el = document.getElementById(s);
        if (el) el.hidden = s === 'vipHistory' ? id !== 'vipList' : s !== id;
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function openCompose() {
    picked = boxes().filter(function (b) { return b.checked; })
                    .map(function (b) { return { name: b.dataset.name, phone: b.dataset.phone }; });
    if (!picked.length) return;
    document.getElementById('composeCount').textContent =
        picked.length + (picked.length === 1 ? ' customer' : ' customers');
    renderPreview();
    showStep('vipCompose');
}

/* "{name}" becomes the customer's first name, e.g. "Ayesha Khan" → "Ayesha" */
function personalise(msg, name) {
    var first = (name || '').trim().split(/\s+/)[0] || '';
    return msg.replace(/\{name\}/gi, first);
}

function renderPreview() {
    var msg = document.getElementById('vipMsg').value;
    document.getElementById('msgPreview').textContent = personalise(msg, picked.length ? picked[0].name : 'Ayesha');
}

var dashUrl = '${ctx}/review/dashboard', scannerId = '${current.id}';

/* ── Optional photo. wa.me links carry text only, so the photo goes as a link to a public
   offer page; WhatsApp shows that page's photo as a big preview card. ── */
var offerImage = null;

function uploadOfferImage(input) {
    var file = input.files && input.files[0];
    input.value = '';
    if (!file) return;
    var note = document.getElementById('attachNote'), btn = document.getElementById('attachBtn');
    note.classList.remove('err');
    if (file.size > 5 * 1024 * 1024) { note.textContent = 'Photo is bigger than 5 MB.'; note.classList.add('err'); return; }
    note.textContent = 'Uploading…';
    btn.disabled = true;
    var fd = new FormData();
    fd.append('scanner', scannerId);
    fd.append('image', file);
    fetch('${ctx}/review/offer-image', { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(function (r) { return r.json(); })
        .then(function (res) {
            if (!res.path) throw new Error(res.error || 'Upload failed.');
            offerImage = res.path;
            document.getElementById('photoPreview').src = res.url;
            document.getElementById('photoWrap').hidden = false;
            document.getElementById('linkPreview').hidden = false;
            note.textContent = 'Photo added. Customers see it as a preview under your message.';
            btn.textContent = '📎 Change photo';
        })
        .catch(function (e) {
            note.textContent = e.message && e.message !== 'Failed to fetch' ? e.message : 'Upload failed. Check your internet.';
            note.classList.add('err');
        })
        .then(function () { btn.disabled = false; });
}

function removeOfferImage() {
    offerImage = null;
    document.getElementById('photoWrap').hidden = true;
    document.getElementById('linkPreview').hidden = true;
    document.getElementById('attachNote').textContent = 'Optional. JPG or PNG, up to 5 MB.';
    document.getElementById('attachBtn').textContent = '📎 Add photo';
}

/* The text that goes into WhatsApp for one customer */
function finalText(msg, name, link) {
    var text = personalise(msg, name);
    return link ? text + '\n\n📸 See the offer: ' + link : text;
}

function post(params) {
    var body = new URLSearchParams();
    Object.keys(params).forEach(function (k) {
        [].concat(params[k]).forEach(function (v) { body.append(k, v); });
    });
    return fetch(dashUrl, { method: 'POST', body: body, credentials: 'same-origin', keepalive: true })
        .then(function (r) { return r.json(); });
}

/* Confirm: save the offer to history first, then show the send list */
function openQueue() {
    var msg = document.getElementById('vipMsg').value.trim();
    if (!msg) { document.getElementById('vipMsg').focus(); return; }
    var btn = document.querySelector('#vipCompose .btn-wa');
    btn.disabled = true;
    post({ action: 'startBroadcast', scanner: scannerId, message: msg, image: offerImage || '',
           phone: picked.map(function (p) { return p.phone; }) })
        .then(function (res) {
            if (!res.ok) throw new Error();
            renderQueue(res.id, msg, picked, res.link);
        })
        .catch(function () { alert('Could not save the offer. Please check your internet and try again.'); })
        .then(function () { btn.disabled = false; });
}

/* Re-open an offer from "Offers sent" to see who got it or finish sending */
function openHistory(li) {
    var people = Array.prototype.map.call(li.querySelectorAll('.rcpt'), function (r) {
        return { name: r.dataset.name, phone: r.dataset.phone, sent: r.dataset.sent === 'true' };
    });
    renderQueue(li.dataset.id, li.dataset.message, people, li.dataset.link);
}

function renderQueue(broadcastId, msg, people, link) {
    var list = document.getElementById('queueList');
    list.innerHTML = '';
    people.forEach(function (p) {
        var li = document.createElement('li');
        var who = document.createElement('div');
        who.className = 'who';
        who.textContent = p.name;
        var small = document.createElement('small');
        small.textContent = '+91 ' + p.phone;
        who.appendChild(small);
        var a = document.createElement('a');
        a.className = 'btn btn-wa';
        a.target = '_blank';
        a.rel = 'noopener';
        a.href = 'https://wa.me/91' + p.phone + '?text=' + encodeURIComponent(finalText(msg, p.name, link));
        a.textContent = p.sent ? 'Sent ✓' : 'Send';
        if (p.sent) li.classList.add('sent');
        a.addEventListener('click', function () {
            if (li.classList.contains('sent')) return;
            li.classList.add('sent');
            a.textContent = 'Sent ✓';
            updateProgress();
            post({ action: 'markSent', broadcast: broadcastId, phone: p.phone }).catch(function () {});
        });
        li.appendChild(who);
        li.appendChild(a);
        list.appendChild(li);
    });
    updateProgress();
    showStep('vipQueue');
}

function updateProgress() {
    var total = document.querySelectorAll('#queueList li').length;
    var sent = document.querySelectorAll('#queueList li.sent').length;
    document.getElementById('queueProgress').textContent = sent + ' / ' + total + ' sent';
}
</script>
</body>
</html>
