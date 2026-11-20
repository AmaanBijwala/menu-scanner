<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Customer rewards page (/rw/{code}): verify the number on WhatsApp → details → today's
     stamp and/or scratch card. All steps run on this one page with fetch(). --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <meta name="robots" content="noindex">
    <meta name="theme-color" content="#3b1d5e">
    <title><c:out value="${scanner.businessName}"/> — Rewards</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root { --ink: #1d1b2f; --muted: #6b6880; --line: #ebe8f3; --soft: #faf9fd; --violet: #7b4bff; --wa: #25D366; }
        * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
        html, body { margin: 0; }
        body {
            min-height: 100vh; min-height: 100dvh; overflow-x: hidden;
            font-family: 'Poppins', system-ui, -apple-system, 'Segoe UI', sans-serif; color: var(--ink); background: #fff3e6;
            display: flex; align-items: flex-start; justify-content: center;
            padding: max(1.25rem, env(safe-area-inset-top)) 1rem max(1.5rem, env(safe-area-inset-bottom));
        }
        .bg { position: fixed; inset: 0; z-index: -1; overflow: hidden; }
        .blob { position: absolute; border-radius: 50%; filter: blur(60px); opacity: .65; }
        .b1 { width: 60vmax; height: 60vmax; left: -20vmax; top: -22vmax; background: #ff9a8b; animation: drift 16s ease-in-out infinite alternate; }
        .b2 { width: 55vmax; height: 55vmax; right: -22vmax; top: 15vh; background: #a18cff; animation: drift 19s ease-in-out infinite alternate-reverse; }
        .b3 { width: 50vmax; height: 50vmax; left: -10vmax; bottom: -25vmax; background: #ffd36e; animation: drift 14s ease-in-out infinite alternate; }
        @keyframes drift { to { transform: translate(8vmax, 8vmax) scale(1.1); } }

        .card {
            width: 100%; max-width: 420px; margin-top: .5rem;
            background: rgba(255,255,255,.8); backdrop-filter: blur(18px) saturate(1.4); -webkit-backdrop-filter: blur(18px) saturate(1.4);
            border: 1px solid rgba(255,255,255,.9); border-radius: 28px; padding: 1.5rem 1.25rem 1.25rem; text-align: center;
            box-shadow: 0 30px 60px -20px rgba(80,40,120,.35); animation: cardIn .6s cubic-bezier(.2,.9,.3,1.2) both;
        }
        @keyframes cardIn { from { opacity: 0; transform: translateY(24px) scale(.95); } }
        .back { display: inline-block; margin-bottom: .6rem; font-size: .8rem; font-weight: 600; color: var(--muted); text-decoration: none; }
        .hello { margin: 0; font-size: .82rem; font-weight: 600; color: var(--muted); }
        h1 { margin: .1rem 0 .4rem; font-size: clamp(1.4rem, 6vw, 1.8rem); line-height: 1.15; font-weight: 800;
             background: linear-gradient(90deg, #ff5e3a, #d62976, #7b4bff); -webkit-background-clip: text; background-clip: text; color: transparent; }
        h2 { margin: 0 0 .3rem; font-size: 1.2rem; font-weight: 800; }
        .lead { margin: 0 auto 1rem; max-width: 32ch; color: var(--muted); font-size: .9rem; line-height: 1.5; }
        .perks { display: grid; gap: .55rem; margin: 0 0 1.1rem; text-align: left; }
        .perk { display: flex; gap: .7rem; align-items: center; padding: .7rem .8rem; border-radius: 16px; background: #fff; border: 1px solid var(--line); }
        .perk .ic { flex: none; width: 40px; height: 40px; border-radius: 12px; display: grid; place-items: center; font-size: 1.3rem;
                    background: linear-gradient(135deg, #ffe08a, #ffb627); }
        .perk b { display: block; font-size: .92rem; }
        .perk small { display: block; font-size: .76rem; color: var(--muted); }
        .step[hidden] { display: none; }

        .btn { display: flex; align-items: center; justify-content: center; gap: .5rem; width: 100%; border: 0; border-radius: 16px;
               padding: .95rem; cursor: pointer; font: 700 1rem 'Poppins', system-ui, sans-serif; color: #fff; text-decoration: none;
               background: linear-gradient(90deg, #ff8a00, #d62976, #7b4bff); box-shadow: 0 12px 24px -12px rgba(214,41,118,.7); }
        .btn:disabled { opacity: .5; cursor: not-allowed; }
        .btn[hidden] { display: none; }
        .btn.wa { background: linear-gradient(135deg, #25D366, #128C7E); box-shadow: 0 12px 24px -12px rgba(18,140,126,.7); }
        .btn.ghost { background: #f1eff7; color: var(--ink); box-shadow: none; font-weight: 600; font-size: .9rem; padding: .75rem; margin-top: .6rem; }
        .fine { margin: .7rem 0 0; font-size: .72rem; color: #a7a3b8; line-height: 1.5; }
        .err { display: none; margin: .2rem 0 .7rem; padding: .6rem .8rem; border-radius: 12px; background: #fff1f0; color: #c62828; font-size: .84rem; font-weight: 600; text-align: left; }
        .wait { display: none; align-items: center; justify-content: center; gap: .6rem; margin-top: .9rem; font-size: .86rem; color: var(--muted); font-weight: 600; }
        .spin { width: 18px; height: 18px; border-radius: 50%; border: 3px solid #e4dff3; border-top-color: var(--violet); animation: spin 1s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .who { margin: 0 0 1rem; font-size: .82rem; color: var(--muted); }
        .who button { border: 0; background: none; color: var(--violet); font: 600 .82rem 'Poppins', sans-serif; cursor: pointer; padding: 0; text-decoration: underline; }

        .fld { margin-bottom: .9rem; text-align: left; }
        .fld > label, .fld > .lbl { display: block; font-size: .8rem; font-weight: 700; margin-bottom: .35rem; }
        .inp { display: flex; align-items: center; gap: .5rem; border: 2px solid var(--line); border-radius: 14px; padding: 0 .85rem; background: var(--soft); }
        .inp:focus-within { border-color: var(--violet); background: #fff; box-shadow: 0 0 0 4px rgba(123,75,255,.12); }
        .inp input { flex: 1; min-width: 0; border: 0; outline: 0; background: none; font: 600 1rem 'Poppins', system-ui, sans-serif; color: var(--ink); padding: .8rem 0; }
        .inp .pre { font-weight: 700; color: var(--muted); }
        .pills { display: grid; grid-template-columns: repeat(3, 1fr); gap: .5rem; }
        .pills label { position: relative; }
        .pills input { position: absolute; opacity: 0; inset: 0; }
        .pills span { display: block; text-align: center; padding: .7rem .3rem; border-radius: 14px; border: 2px solid var(--line); background: var(--soft); font-weight: 600; font-size: .9rem; cursor: pointer; }
        .pills input:checked + span { border-color: var(--violet); background: #f3eeff; color: #5b2fd6; }
        .hint { margin: .3rem 0 0; font-size: .72rem; color: var(--muted); }

        /* Stamp card */
        .stampcard { margin: 0 0 1rem; padding: 1rem; border-radius: 22px; color: #fff; text-align: center;
                     background: linear-gradient(135deg, #1d1b2f, #3b1d5e 55%, #6a1b5f); box-shadow: 0 16px 30px -14px rgba(106,27,95,.75); }
        .stampcard .top { display: flex; justify-content: space-between; align-items: baseline; font-size: .8rem; opacity: .85; margin-bottom: .7rem; }
        .stampcard .top b { font-size: 1.1rem; opacity: 1; }
        .dots { display: grid; grid-template-columns: repeat(5, 1fr); gap: .5rem; justify-items: center; }
        .dot { width: 100%; max-width: 52px; aspect-ratio: 1; border-radius: 50%; display: grid; place-items: center; font-size: 1.25rem;
               border: 2px dashed rgba(255,255,255,.35); color: rgba(255,255,255,.35); font-weight: 700; font-size: .8rem; }
        .dot.on { border: 0; background: linear-gradient(135deg, #ffe08a, #ffb627); color: #6a1b5f; font-size: 1.5rem; box-shadow: 0 4px 12px rgba(255,182,39,.45); }
        .dot.new { animation: stampIn .7s cubic-bezier(.2,.9,.3,1.6) both .3s; }
        @keyframes stampIn { from { transform: scale(2.4) rotate(-30deg); opacity: 0; } }
        .dot.gift { border-style: solid; border-color: #ffe08a; color: #ffe08a; font-size: 1.2rem; }
        .reward-line { margin: .8rem 0 0; font-size: .82rem; opacity: .9; }
        .msg { margin: 0 0 1rem; font-size: 1.05rem; font-weight: 700; line-height: 1.4; }
        .msg small { display: block; margin-top: .25rem; font-size: .84rem; font-weight: 500; color: var(--muted); }

        /* Scratch card */
        .scratch-wrap { position: relative; margin: 0 auto 1rem; width: 100%; max-width: 320px; aspect-ratio: 16 / 10; border-radius: 22px; overflow: hidden;
                        box-shadow: 0 16px 30px -14px rgba(80,40,120,.5); user-select: none; -webkit-user-select: none; touch-action: none; }
        .prize { position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 1rem;
                 background: radial-gradient(circle at 30% 20%, #fff7d6, #ffe08a 60%, #ffb627); color: #3b1d5e; }
        .prize.lose { background: radial-gradient(circle at 30% 20%, #ffffff, #eef0ff 60%, #d9dcf5); }
        .prize .big { font-size: 1.6rem; font-weight: 800; line-height: 1.15; }
        .prize .small { margin-top: .3rem; font-size: .82rem; font-weight: 600; opacity: .8; }
        .scratch-wrap canvas { position: absolute; inset: 0; width: 100%; height: 100%; cursor: grab; transition: opacity .5s; }
        .codebox { display: inline-block; margin: .2rem 0 .6rem; padding: .55rem 1.1rem; border-radius: 14px; border: 2px dashed var(--violet);
                   font: 800 1.35rem 'Poppins', monospace; letter-spacing: .18em; color: #5b2fd6; background: #f6f2ff; }
        .section-gap { height: .4rem; }
        .confetti { position: fixed; width: 8px; height: 12px; border-radius: 2px; pointer-events: none; z-index: 80; animation: burst 1.1s cubic-bezier(.1,.7,.3,1) forwards; }
        @keyframes burst { to { transform: translate(var(--dx), var(--dy)) rotate(var(--rot)); opacity: 0; } }

        .preview-bar { position: fixed; top: 0; left: 0; right: 0; z-index: 60; padding: .5rem 1rem; text-align: center; font-size: .78rem; font-weight: 600; background: #1d1b2f; color: #fff; }
        .brand { margin: 1rem 0 0; font-size: .74rem; font-weight: 600; color: #8a85a0; }
        .brand span { display: block; margin-top: .15rem; font-size: .68rem; font-weight: 400; }
        @media (prefers-reduced-motion: reduce) { *, *::before, *::after { animation-duration: .001s !important; animation-iteration-count: 1 !important; transition: none !important; } }
    </style>
</head>
<body>
<c:if test="${preview}"><div class="preview-bar">Preview: WhatsApp is skipped and nothing is saved</div></c:if>
<div class="bg" aria-hidden="true"><div class="blob b1"></div><div class="blob b2"></div><div class="blob b3"></div></div>

<main class="card">
    <a class="back" href="${backUrl}">&lsaquo; Back</a>
    <p class="hello">Rewards at</p>
    <h1><c:out value="${scanner.businessName}"/></h1>

    <%-- Step 1: verify on WhatsApp --%>
    <section class="step" id="stepVerify" ${not empty phone or preview ? 'hidden' : ''}>
        <div class="perks">
            <c:if test="${rewards.stampOn}">
                <div class="perk"><span class="ic" aria-hidden="true">&#127941;</span><span><b>Stamp card</b><small>One stamp a visit. <c:out value="${rewards.stamp.stampsNeeded}"/> stamps = <c:out value="${rewards.stamp.reward}"/></small></span></div>
            </c:if>
            <c:if test="${rewards.scratchOn}">
                <div class="perk"><span class="ic" aria-hidden="true">&#127873;</span><span><b>Scratch &amp; win</b><small>One scratch card every day</small></span></div>
            </c:if>
        </div>
        <p class="lead">First, confirm your WhatsApp number. It takes one tap and keeps your rewards safe.</p>
        <div class="err" id="verifyErr" role="alert"></div>
        <button type="button" class="btn wa" id="verifyBtn">&#9989; Verify with WhatsApp</button>
        <div class="wait" id="verifyWait"><span class="spin" aria-hidden="true"></span><span>Waiting for your WhatsApp message&hellip;</span></div>
        <button type="button" class="btn ghost" id="verifyAgain" hidden>Open WhatsApp again</button>
        <p class="fine">WhatsApp opens with a short code ready. Just press <b>Send</b>, then come back here.</p>
    </section>

    <%-- Step 2: details (only what we don't know yet) --%>
    <section class="step" id="stepDetails" ${empty phone and not preview ? 'hidden' : ''}>
        <p class="who" id="whoLine">
            <c:choose>
                <c:when test="${preview}">Preview mode</c:when>
                <c:otherwise>&#9989; Verified: +91 <span id="whoPhone"><c:out value="${phoneMasked}"/></span> &middot; <button type="button" id="notYou">Not you?</button></c:otherwise>
            </c:choose>
        </p>
        <h2 id="detailsTitle"><c:choose><c:when test="${not empty knownName}">Welcome back, <c:out value="${fn:split(knownName, ' ')[0]}"/>! &#128075;</c:when><c:otherwise>Almost there!</c:otherwise></c:choose></h2>
        <form id="claimForm" novalidate>
            <div id="personFields" ${not empty knownName ? 'hidden' : ''}>
                <div class="fld">
                    <label for="rName">Your name</label>
                    <div class="inp"><input id="rName" name="name" type="text" maxlength="100" autocomplete="name" placeholder="e.g. Sameer"></div>
                </div>
                <div class="fld">
                    <label for="rAge">Age</label>
                    <div class="inp"><input id="rAge" name="age" type="number" inputmode="numeric" min="5" max="110" placeholder="e.g. 25"></div>
                </div>
                <div class="fld">
                    <span class="lbl" id="rGenderLbl">Gender</span>
                    <div class="pills" role="radiogroup" aria-labelledby="rGenderLbl">
                        <label><input type="radio" name="gender" value="Male"><span>&#128104; Male</span></label>
                        <label><input type="radio" name="gender" value="Female"><span>&#128105; Female</span></label>
                        <label><input type="radio" name="gender" value="Other"><span>&#10024; Other</span></label>
                    </div>
                </div>
            </div>
            <c:if test="${rewards.needBill}">
                <div class="fld">
                    <label for="rBill">Today's bill amount</label>
                    <div class="inp"><span class="pre">&#8377;</span><input id="rBill" name="bill" type="number" inputmode="numeric" min="1" placeholder="e.g. 450"></div>
                    <p class="hint">Bigger bills can win bigger prizes. The shop checks your bill when you claim.</p>
                </div>
            </c:if>
            <div class="err" id="claimErr" role="alert"></div>
            <button type="submit" class="btn" id="claimBtn">
                <c:choose>
                    <c:when test="${rewards.stampOn and rewards.scratchOn}">Get my stamp &amp; scratch card</c:when>
                    <c:when test="${rewards.stampOn}">Collect today's stamp &#11088;</c:when>
                    <c:otherwise>Get my scratch card &#127873;</c:otherwise>
                </c:choose>
            </button>
            <p class="fine">You'll also join the <c:out value="${scanner.businessName}"/> VIP Club for offers on WhatsApp.</p>
        </form>
    </section>

    <%-- Step 3: results --%>
    <section class="step" id="stepResult" hidden>
        <div id="stampResult" hidden>
            <p class="msg" id="stampMsg"></p>
            <div class="stampcard">
                <div class="top"><span>Stamp card</span><b id="stampCount"></b></div>
                <div class="dots" id="stampDots"></div>
                <p class="reward-line">&#127873; <span id="stampReward"></span></p>
            </div>
        </div>
        <div class="section-gap"></div>
        <div id="scratchResult" hidden>
            <p class="msg" id="scratchHead">Scratch the card! &#128070;</p>
            <div class="scratch-wrap" id="scratchWrap">
                <div class="prize" id="prizeBox"><div class="big" id="prizeBig"></div><div class="small" id="prizeSmall"></div></div>
                <canvas id="scratchCanvas" aria-label="Scratch card: rub with your finger to reveal"></canvas>
            </div>
            <div id="scratchAfter" hidden>
                <p class="msg" id="scratchMsg"></p>
                <div id="codeWrap" hidden>
                    <div class="codebox" id="codeBox"></div>
                    <p class="fine" style="margin-top:0">Show this code at the counter to claim. Screenshot it to be safe!</p>
                </div>
            </div>
        </div>
        <a class="btn ghost" href="${backUrl}">Done</a>
    </section>

    <p class="brand">The Socio Advert<span>Powered by Bijwala Solutions</span></p>
</main>

<script>
(function () {
    var base = '${base}', preview = ${preview ? 'true' : 'false'};
    var geo = ${scanner.geoCheck and not preview ? 'true' : 'false'};
    var q = preview ? '?preview=1' : '';
    var $ = function (id) { return document.getElementById(id); };
    var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    function show(id) { ['stepVerify', 'stepDetails', 'stepResult'].forEach(function (s) { $(s).hidden = s !== id; }); window.scrollTo(0, 0); }
    function err(box, text) { box.textContent = text || ''; box.style.display = text ? 'block' : 'none'; }
    function post(path, data) {
        var body = new URLSearchParams(data || {});
        return fetch(base + path + q, { method: 'POST', body: body, credentials: 'same-origin' })
            .then(function (r) { return r.json().then(function (j) { if (!r.ok) throw new Error(j.error || 'Something went wrong.'); return j; }); });
    }

    // ── Step 1: WhatsApp verify ──
    var waUrl = null, polling = null;
    // New tab, so this page (and its polling) stays open while WhatsApp is in front
    function openWa() { if (waUrl && !window.open(waUrl, '_blank')) window.location.href = waUrl; }
    $('verifyBtn').addEventListener('click', function () {
        var btn = this;
        btn.disabled = true;
        err($('verifyErr'));
        post('/verify').then(function (res) {
            waUrl = res.waUrl;
            $('verifyWait').style.display = 'flex';
            $('verifyAgain').hidden = false;
            startPolling();
            openWa();
        }).catch(function (e) { err($('verifyErr'), e.message); btn.disabled = false; });
    });
    $('verifyAgain').addEventListener('click', openWa);

    function check() {
        return fetch(base + '/status', { credentials: 'same-origin', cache: 'no-store' })
            .then(function (r) { return r.json(); })
            .then(function (res) {
                if (!res.verified) {
                    if (res.pending && !polling) { $('verifyWait').style.display = 'flex'; startPolling(); }
                    return;
                }
                clearInterval(polling);
                polling = null;
                $('whoPhone').textContent = res.phoneMasked;
                if (res.known) {
                    $('personFields').hidden = true;
                    $('detailsTitle').textContent = 'Welcome back, ' + res.name + '! 👋';
                }
                show('stepDetails');
            }).catch(function () {});
    }
    function startPolling() {
        if (polling) return;
        polling = setInterval(check, 2500);
        setTimeout(function () { if (polling) { clearInterval(polling); polling = null; } }, 15 * 60 * 1000);
    }
    document.addEventListener('visibilitychange', function () { if (!document.hidden && waUrl) { check(); startPolling(); } });
    // Back from WhatsApp in the same tab (page reloaded): the token is in the session, so ask once
    if (!$('stepVerify').hidden) check();

    var notYou = $('notYou');
    if (notYou) notYou.addEventListener('click', function () {
        post('/forget').finally(function () { window.location.reload(); });
    });

    // ── Step 2: claim ──
    $('claimForm').addEventListener('submit', function (e) {
        e.preventDefault();
        var f = this, btn = $('claimBtn');
        err($('claimErr'));
        var data = {};
        if (!$('personFields').hidden) {
            data.name = f.name.value.trim();
            data.age = f.age.value.trim();
            var g = f.querySelector('input[name=gender]:checked');
            data.gender = g ? g.value : '';
            if (data.name.length < 2) return err($('claimErr'), 'Please enter your name.');
            if (!(+data.age >= 5 && +data.age <= 110)) return err($('claimErr'), 'Please enter a valid age.');
            if (!data.gender) return err($('claimErr'), 'Please pick your gender.');
        }
        if (f.bill) {
            data.bill = f.bill.value.trim();
            if (!(+data.bill >= 1)) return err($('claimErr'), "Please enter today's bill amount.");
        }
        btn.disabled = true;
        withLocation(data).then(function (d) { return post('/claim', d); })
            .then(showResult)
            .catch(function (e2) { err($('claimErr'), e2.message); btn.disabled = false; });
    });

    function withLocation(data) {
        if (!geo) return Promise.resolve(data);
        return new Promise(function (resolve, reject) {
            if (!navigator.geolocation) return reject(new Error('Please allow location to collect rewards at the shop.'));
            navigator.geolocation.getCurrentPosition(function (pos) {
                data.lat = pos.coords.latitude; data.lng = pos.coords.longitude; data.acc = pos.coords.accuracy;
                resolve(data);
            }, function () { reject(new Error('Please allow location. Rewards are only for customers at the shop.')); },
            { enableHighAccuracy: true, timeout: 15000, maximumAge: 60000 });
        });
    }

    // ── Step 3: results ──
    var cheers = ["Nice! You're on a roll 🔥", 'Another one in the bag! ⭐', 'Loyalty looks good on you 😎', 'Great to see you again! 💖'];
    function showResult(res) {
        show('stepResult');                          // first: the scratch canvas needs a visible, sized box
        if (res.stamp) renderStamp(res.stamp);
        if (res.scratch) renderScratch(res.scratch);
        if (res.stamp && res.stamp.added) confetti();
    }

    function renderStamp(s) {
        $('stampResult').hidden = false;
        var left = s.needed - s.count, msg;
        if (s.complete) msg = '🎉 Card complete!<small>Show this screen at the counter to get your reward.</small>';
        else if (s.already) msg = "You've already collected today's stamp ✅<small>See you tomorrow!</small>";
        else if (s.count === 1) msg = 'Welcome aboard! Your first stamp is in 🎉<small>' + left + ' more to go.</small>';
        else if (left === 1) msg = 'Just 1 more visit to unlock your reward! 🔥';
        else if (s.count * 2 >= s.needed && (s.count - 1) * 2 < s.needed) msg = 'Halfway there! Keep it up 💪<small>' + left + ' more to go.</small>';
        else msg = cheers[Math.floor(Math.random() * cheers.length)] + '<small>' + left + ' more to go.</small>';
        $('stampMsg').innerHTML = msg;
        $('stampCount').textContent = s.count + ' / ' + s.needed;
        $('stampReward').textContent = s.reward;
        var dots = $('stampDots');
        dots.innerHTML = '';
        for (var i = 1; i <= s.needed; i++) {
            var d = document.createElement('span');
            d.className = 'dot' + (i <= s.count ? ' on' : '') + (i === s.count && s.added ? ' new' : '') + (i === s.needed && i > s.count ? ' gift' : '');
            d.textContent = i <= s.count ? '★' : (i === s.needed ? '🎁' : i);
            dots.appendChild(d);
        }
    }

    function renderScratch(s) {
        $('scratchResult').hidden = false;
        var box = $('prizeBox');
        if (s.won) {
            $('prizeBig').textContent = s.prize;
            $('prizeSmall').textContent = 'You won! 🎉';
        } else {
            box.classList.add('lose');
            $('prizeBig').textContent = 'Better luck next time 🍀';
            $('prizeSmall').textContent = 'Come back tomorrow for another scratch';
        }
        function reveal() {
            $('scratchAfter').hidden = false;
            if (s.won) {
                $('scratchMsg').innerHTML = (s.already ? "You've already scratched today ✅<br>" : '') + '🎉 Yay! You got <b></b>!';
                $('scratchMsg').querySelector('b').textContent = s.prize;
                $('codeBox').textContent = s.code;
                $('codeWrap').hidden = false;
                if (s.redeemed) $('codeWrap').querySelector('.fine').textContent = 'This prize has already been claimed.';
                if (!s.already) confetti();
            } else {
                $('scratchMsg').textContent = s.already ? "You've already scratched today. Come back tomorrow! 🍀" : 'Better luck next time! Come back tomorrow 🍀';
            }
        }
        if (s.already) {
            $('scratchHead').textContent = "Today's scratch card";
            $('scratchCanvas').remove();
            reveal();
            return;
        }
        setupScratch($('scratchCanvas'), reveal);
    }

    function setupScratch(cv, onDone) {
        var wrap = cv.parentNode, ratio = window.devicePixelRatio || 1, done = false;
        var w = wrap.clientWidth, h = wrap.clientHeight;
        cv.width = w * ratio; cv.height = h * ratio;
        var ctx = cv.getContext('2d');
        ctx.scale(ratio, ratio);
        var grad = ctx.createLinearGradient(0, 0, w, h);
        grad.addColorStop(0, '#b9b4c9'); grad.addColorStop(.5, '#e4e1ee'); grad.addColorStop(1, '#a9a3bd');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, w, h);
        ctx.fillStyle = 'rgba(59,29,94,.75)';
        ctx.font = '700 18px Poppins, sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText('SCRATCH HERE', w / 2, h / 2 - 4);
        ctx.font = '600 13px Poppins, sans-serif';
        ctx.fillText('rub with your finger 👆', w / 2, h / 2 + 18);
        ctx.globalCompositeOperation = 'destination-out';
        ctx.lineCap = ctx.lineJoin = 'round';
        ctx.lineWidth = 38;
        var drawing = false, last = null, moves = 0;
        function pt(e) { var r = cv.getBoundingClientRect(), t = e.touches ? e.touches[0] : e; return { x: t.clientX - r.left, y: t.clientY - r.top }; }
        function start(e) { drawing = true; last = pt(e); e.preventDefault(); }
        function move(e) {
            if (!drawing || done) return;
            e.preventDefault();
            var p = pt(e);
            ctx.beginPath(); ctx.moveTo(last.x, last.y); ctx.lineTo(p.x, p.y); ctx.stroke();
            last = p;
            if (++moves % 8 === 0 && cleared() > .5) finish();
        }
        function end() { drawing = false; }
        function cleared() {
            var data = ctx.getImageData(0, 0, cv.width, cv.height).data, clear = 0, n = 0;
            for (var i = 3; i < data.length; i += 64) { n++; if (data[i] === 0) clear++; }
            return clear / n;
        }
        function finish() { if (done) return; done = true; cv.style.opacity = '0'; setTimeout(function () { cv.remove(); }, 500); onDone(); }
        cv.addEventListener('mousedown', start); cv.addEventListener('mousemove', move); window.addEventListener('mouseup', end);
        cv.addEventListener('touchstart', start, { passive: false }); cv.addEventListener('touchmove', move, { passive: false }); cv.addEventListener('touchend', end);
        cv.addEventListener('dblclick', finish);   // accessibility fallback
    }

    function confetti() {
        if (reduce) return;
        var colors = ['#ff8a00', '#d62976', '#7b4bff', '#22c55e', '#ffd36e'];
        for (var i = 0; i < 40; i++) {
            var c = document.createElement('i');
            c.className = 'confetti';
            c.style.left = (window.innerWidth / 2) + 'px';
            c.style.top = (window.innerHeight / 3) + 'px';
            c.style.background = colors[i % colors.length];
            c.style.setProperty('--dx', (Math.random() * 360 - 180) + 'px');
            c.style.setProperty('--dy', (Math.random() * 360 - 120) + 'px');
            c.style.setProperty('--rot', (Math.random() * 720) + 'deg');
            document.body.appendChild(c);
            setTimeout(function (el) { el.remove(); }.bind(null, c), 1200);
        }
    }
})();
</script>
</body>
</html>
