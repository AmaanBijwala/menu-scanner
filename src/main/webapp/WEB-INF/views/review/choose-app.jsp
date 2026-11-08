<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Shown when a sticker has two or more links: the customer picks where to go.
     Each button goes through /s/{code}/go/{platform} so the trip is counted. --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <meta name="robots" content="noindex">
    <meta name="theme-color" content="#fff3e6">
    <title><c:out value="${scanner.businessName}"/></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --ink: #1d1b2f; --muted: #6b6880;
            --g-blue: #4285F4; --g-red: #EA4335; --g-yellow: #FBBC05; --g-green: #34A853;
            --ig: linear-gradient(45deg, #feda75 0%, #fa7e1e 22%, #d62976 50%, #962fbf 75%, #4f5bd5 100%);
            --fb: linear-gradient(135deg, #1877F2, #0a5bd3);
            --yt: linear-gradient(135deg, #ff2a2a, #c4000a);
            --wa: linear-gradient(135deg, #25D366, #128C7E);
        }
        * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
        html, body { margin: 0; }
        body {
            min-height: 100vh; min-height: 100dvh;
            font-family: 'Poppins', system-ui, -apple-system, 'Segoe UI', sans-serif;
            color: var(--ink); background: #fff3e6; overflow-x: hidden;
            display: flex; align-items: center; justify-content: center;
            padding: max(1.25rem, env(safe-area-inset-top)) 1rem max(1.5rem, env(safe-area-inset-bottom));
        }

        /* ── Animated colour blobs behind everything ── */
        .bg { position: fixed; inset: 0; z-index: -2; overflow: hidden; }
        .blob { position: absolute; border-radius: 50%; filter: blur(60px); opacity: .7; will-change: transform; }
        .b1 { width: 60vmax; height: 60vmax; left: -20vmax; top: -22vmax; background: #ff9a8b; animation: drift1 16s ease-in-out infinite alternate; }
        .b2 { width: 55vmax; height: 55vmax; right: -22vmax; top: 10vh;   background: #a18cff; animation: drift2 19s ease-in-out infinite alternate; }
        .b3 { width: 50vmax; height: 50vmax; left: -10vmax; bottom: -25vmax; background: #ffd36e; animation: drift3 14s ease-in-out infinite alternate; }
        .b4 { width: 35vmax; height: 35vmax; right: -5vmax; bottom: -10vmax; background: #6ee7c8; animation: drift1 21s ease-in-out infinite alternate-reverse; }
        @keyframes drift1 { to { transform: translate(12vmax, 10vmax) scale(1.15); } }
        @keyframes drift2 { to { transform: translate(-14vmax, 12vmax) scale(.9); } }
        @keyframes drift3 { to { transform: translate(10vmax, -12vmax) scale(1.1); } }

        /* Floating sparkles */
        .floaters { position: fixed; inset: 0; z-index: -1; pointer-events: none; overflow: hidden; }
        .floaters span { position: absolute; bottom: -40px; font-size: 1.2rem; opacity: 0; animation: rise linear infinite; }
        @keyframes rise {
            0%   { transform: translateY(0) rotate(0); opacity: 0; }
            10%  { opacity: .85; }
            100% { transform: translateY(-110vh) rotate(260deg); opacity: 0; }
        }

        /* ── Card ── */
        .card {
            width: 100%; max-width: 420px; position: relative;
            background: rgba(255,255,255,.72); backdrop-filter: blur(18px) saturate(1.4); -webkit-backdrop-filter: blur(18px) saturate(1.4);
            border: 1px solid rgba(255,255,255,.9); border-radius: 28px;
            padding: 2rem 1.25rem 1.25rem; text-align: center;
            box-shadow: 0 30px 60px -20px rgba(80, 40, 120, .35), 0 0 0 1px rgba(255,255,255,.4) inset;
            animation: cardIn .7s cubic-bezier(.2,.9,.3,1.2) both;
        }
        @keyframes cardIn { from { opacity: 0; transform: translateY(30px) scale(.94); } }

        .avatar { width: 84px; height: 84px; margin: -0.25rem auto 1rem; position: relative; animation: pop .6s .15s cubic-bezier(.2,.9,.3,1.4) both; }
        .avatar::before {
            content: ''; position: absolute; inset: -5px; border-radius: 50%;
            background: conic-gradient(var(--g-blue), var(--g-red), var(--g-yellow), var(--g-green), #d62976, var(--g-blue));
            animation: spin 4s linear infinite;
        }
        .avatar .in {
            position: absolute; inset: 0; border-radius: 50%; background: #fff;
            display: grid; place-items: center; font-size: 2.2rem; font-weight: 800;
        }
        .avatar .in span {
            background-image: linear-gradient(135deg, #ff6a3d, #d62976 55%, #7b4bff);
            -webkit-background-clip: text; background-clip: text; color: transparent;
        }
        .wave { position: absolute; right: -10px; bottom: -4px; font-size: 1.6rem; transform-origin: 70% 70%; animation: wave 2.4s 1s ease-in-out infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        @keyframes pop  { from { opacity: 0; transform: scale(.4); } }
        @keyframes wave { 0%,60%,100% { transform: rotate(0); } 10%,30% { transform: rotate(16deg); } 20%,40% { transform: rotate(-10deg); } }

        .hello { font-size: .85rem; font-weight: 600; color: var(--muted); letter-spacing: .02em; margin: 0; animation: up .6s .25s both; }
        h1 {
            margin: .15rem 0 .5rem; font-size: clamp(1.5rem, 6.5vw, 1.95rem); line-height: 1.15; font-weight: 800;
            background: linear-gradient(90deg, #ff5e3a, #d62976, #7b4bff, #1e88e5, #ff5e3a);
            background-size: 300% 100%;
            -webkit-background-clip: text; background-clip: text; color: transparent;
            animation: up .6s .32s both, shimmer 6s linear infinite;
            word-break: break-word;
        }
        @keyframes shimmer { to { background-position: 300% 0; } }
        .sub { margin: 0 auto 1.4rem; max-width: 30ch; color: var(--muted); font-size: .92rem; line-height: 1.5; animation: up .6s .4s both; }
        @keyframes up { from { opacity: 0; transform: translateY(14px); } }

        /* ── App buttons ── */
        .apps { display: grid; gap: .8rem; }
        .app {
            position: relative; display: flex; align-items: center; gap: .9rem;
            padding: .85rem 1rem .85rem .85rem; border-radius: 20px;
            text-decoration: none; color: #fff; text-align: left; overflow: hidden; isolation: isolate;
            box-shadow: 0 12px 24px -12px var(--shadow, rgba(0,0,0,.4));
            transform: translateZ(0);
            transition: transform .18s ease, box-shadow .18s ease;
            animation: slideIn .6s cubic-bezier(.2,.9,.3,1.25) both;
            animation-delay: calc(.5s + var(--i) * .11s);
        }
        @keyframes slideIn { from { opacity: 0; transform: translateX(-26px) scale(.96); } }
        .app:hover  { transform: translateY(-3px); box-shadow: 0 18px 30px -12px var(--shadow, rgba(0,0,0,.45)); }
        .app:active { transform: scale(.97); }
        .app:focus-visible { outline: 3px solid #1d1b2f; outline-offset: 3px; }

        /* Light sweep that runs across each button now and then */
        .app::after {
            content: ''; position: absolute; inset: 0; z-index: -1; pointer-events: none;
            background: linear-gradient(105deg, transparent 35%, rgba(255,255,255,.45) 50%, transparent 65%);
            transform: translateX(-120%);
            animation: sweep 4.5s ease-in-out infinite; animation-delay: calc(1.6s + var(--i) * .5s);
        }
        @keyframes sweep { 0%, 70% { transform: translateX(-120%); } 100% { transform: translateX(120%); } }

        .tile {
            flex: none; width: 50px; height: 50px; border-radius: 15px; background: #fff;
            display: grid; place-items: center; box-shadow: 0 4px 10px rgba(0,0,0,.12);
            transition: transform .3s cubic-bezier(.2,.9,.3,1.6);
        }
        .app:hover .tile { transform: rotate(-8deg) scale(1.08); }
        .tile .pi { width: 30px; height: 30px; }
        .txt { flex: 1; min-width: 0; }
        .txt b { display: block; font-size: 1.02rem; font-weight: 700; line-height: 1.25; }
        .txt small { display: block; font-size: .78rem; opacity: .88; margin-top: .1rem; }
        .arrow {
            flex: none; width: 32px; height: 32px; border-radius: 50%; background: rgba(255,255,255,.22);
            display: grid; place-items: center; font-size: 1rem; font-weight: 700;
            animation: nudge 1.8s ease-in-out infinite; animation-delay: calc(var(--i) * .2s);
        }
        @keyframes nudge { 0%, 100% { transform: translateX(0); } 50% { transform: translateX(4px); } }

        .app.instagram { background: var(--ig); --shadow: rgba(214, 41, 118, .55); background-size: 160% 160%; animation-name: slideIn, igShift; animation-duration: .6s, 8s; animation-iteration-count: 1, infinite; animation-direction: normal, alternate; }
        @keyframes igShift { from { background-position: 0% 50%; } to { background-position: 100% 50%; } }
        .app.facebook  { background: var(--fb); --shadow: rgba(24, 119, 242, .55); }
        .app.youtube   { background: var(--yt); --shadow: rgba(220, 0, 20, .5); }
        .app.whatsapp  { background: var(--wa); --shadow: rgba(18, 140, 126, .55); }

        /* Google: white button with a spinning four-colour border */
        .app.google { color: var(--ink); background: #fff; --shadow: rgba(66, 133, 244, .45); padding: 1rem 1rem 1rem .9rem; }
        .app.google::before {
            content: ''; position: absolute; inset: -60%; z-index: -2;
            background: conic-gradient(var(--g-blue) 0 25%, var(--g-red) 0 50%, var(--g-yellow) 0 75%, var(--g-green) 0 100%);
            animation: spin 3.5s linear infinite;
        }
        .app.google .face { position: absolute; inset: 3px; border-radius: 17px; background: #fff; z-index: -1; }
        .app.google .tile { box-shadow: 0 4px 12px rgba(66,133,244,.25); }
        .app.google .arrow { background: #eef3ff; color: var(--g-blue); }
        .app.google::after { background: linear-gradient(105deg, transparent 35%, rgba(66,133,244,.14) 50%, transparent 65%); }
        .stars { display: flex; gap: 2px; margin-top: .2rem; }
        .stars i {
            font-style: normal; font-size: 1rem; line-height: 1; color: var(--g-yellow);
            text-shadow: 0 1px 0 rgba(0,0,0,.08);
            animation: starPop .45s cubic-bezier(.2,.9,.3,1.8) both, twinkle 2.6s ease-in-out infinite;
            animation-delay: calc(.9s + var(--s) * .12s), calc(2s + var(--s) * .18s);
        }
        @keyframes starPop { from { opacity: 0; transform: scale(0) rotate(-90deg); } }
        @keyframes twinkle { 0%, 80%, 100% { transform: scale(1); } 90% { transform: scale(1.35); } }

        /* Tap ripple + confetti */
        .ripple { position: absolute; border-radius: 50%; transform: scale(0); background: rgba(255,255,255,.55); pointer-events: none; animation: ripple .6s ease-out forwards; z-index: 0; }
        .app.google .ripple { background: rgba(66,133,244,.22); }
        @keyframes ripple { to { transform: scale(4); opacity: 0; } }
        .confetti { position: fixed; width: 8px; height: 12px; border-radius: 2px; pointer-events: none; z-index: 80; animation: burst .9s cubic-bezier(.1,.7,.3,1) forwards; }
        @keyframes burst { to { transform: translate(var(--dx), var(--dy)) rotate(var(--rot)); opacity: 0; } }

        .thanks { margin: 1.3rem 0 0; font-size: .82rem; color: var(--muted); animation: up .6s 1.2s both; }
        .thanks span { display: inline-block; animation: beat 1.4s ease-in-out infinite; }
        @keyframes beat { 0%, 100% { transform: scale(1); } 15% { transform: scale(1.3); } 30% { transform: scale(1); } }
        .sticker { margin-top: .6rem; font-size: .66rem; letter-spacing: .12em; color: #a7a3b8; }
        .brand { margin: .9rem 0 0; font-size: .74rem; font-weight: 600; color: #8a85a0; }
        .brand span { font-weight: 400; }
        .preview-bar { position: fixed; top: 0; left: 0; right: 0; z-index: 60; padding: .5rem 1rem calc(.5rem); padding-top: max(.5rem, env(safe-area-inset-top)); text-align: center; font-size: .78rem; font-weight: 600; background: #1d1b2f; color: #fff; }

        /* ── "Join our VIP Club" box (always first) ── */
        .vip {
            position: relative; display: flex; align-items: center; gap: .9rem; width: 100%;
            padding: 1rem 1rem 1rem .9rem; margin-bottom: .8rem; border: 0; border-radius: 20px;
            font: inherit; color: #fff; text-align: left; cursor: pointer; overflow: hidden; isolation: isolate;
            background: linear-gradient(120deg, #1d1b2f, #3b1d5e 55%, #6a1b5f);
            box-shadow: 0 16px 30px -14px rgba(106, 27, 95, .75);
            animation: slideIn .6s .45s cubic-bezier(.2,.9,.3,1.25) both;
            transition: transform .18s ease;
        }
        .vip:hover { transform: translateY(-3px); }
        .vip:active { transform: scale(.97); }
        .vip:focus-visible { outline: 3px solid #1d1b2f; outline-offset: 3px; }
        /* spinning gold border */
        .vip::before {
            content: ''; position: absolute; inset: -60%; z-index: -2;
            background: conic-gradient(#ffd36e, #ff8a00, #d62976, #7b4bff, #ffd36e);
            animation: spin 4s linear infinite;
        }
        .vip .face { position: absolute; inset: 2.5px; border-radius: 18px; z-index: -1;
                     background: linear-gradient(120deg, #1d1b2f, #3b1d5e 55%, #6a1b5f); }
        .vip::after {
            content: ''; position: absolute; inset: 0; z-index: -1; pointer-events: none;
            background: linear-gradient(105deg, transparent 35%, rgba(255,211,110,.28) 50%, transparent 65%);
            transform: translateX(-120%); animation: sweep 4s 1.2s ease-in-out infinite;
        }
        .vip .tile { background: linear-gradient(135deg, #ffe08a, #ffb627); font-size: 1.6rem; animation: bob 2.4s ease-in-out infinite; }
        @keyframes bob { 0%, 100% { transform: translateY(0) rotate(0); } 50% { transform: translateY(-3px) rotate(-6deg); } }
        .vip .txt b { font-size: 1.05rem; }
        .vip .txt b em { font-style: normal; background: linear-gradient(90deg, #ffe08a, #ffb627); -webkit-background-clip: text; background-clip: text; color: transparent; }
        .vip .badge { display: inline-block; margin-top: .3rem; font-size: .64rem; font-weight: 700; letter-spacing: .08em;
                      padding: .15rem .5rem; border-radius: 999px; background: rgba(255,211,110,.18); color: #ffe08a; }
        .vip .arrow { background: linear-gradient(135deg, #ffe08a, #ffb627); color: #3b1d5e; }
        .vip.joined { background: linear-gradient(120deg, #0f5132, #198754); box-shadow: 0 16px 30px -14px rgba(25,135,84,.7); }
        .vip.joined .face { background: linear-gradient(120deg, #0f5132, #198754); }
        .vip.joined .arrow { background: #fff; color: #198754; animation: none; }

        /* ── Join form sheet ── */
        .sheet { position: fixed; inset: 0; z-index: 70; display: flex; align-items: flex-end; justify-content: center;
                 background: rgba(29,27,47,.55); backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px);
                 opacity: 0; transition: opacity .25s ease; }
        .sheet[hidden] { display: none; }
        .sheet.open { opacity: 1; }
        .sheet-box {
            width: 100%; max-width: 440px; max-height: 92vh; max-height: 92dvh; overflow-y: auto; position: relative;
            background: #fff; border-radius: 26px 26px 0 0; text-align: left;
            padding: 1.4rem 1.25rem max(1.25rem, env(safe-area-inset-bottom));
            transform: translateY(100%); transition: transform .38s cubic-bezier(.2,.9,.3,1.1);
        }
        .sheet.open .sheet-box { transform: none; }
        @media (min-width: 560px) { .sheet { align-items: center; } .sheet-box { border-radius: 26px; } }
        .sheet-close { position: absolute; top: .9rem; right: .9rem; width: 34px; height: 34px; border-radius: 50%; border: 0;
                       background: #f1eff7; color: var(--ink); font-size: .9rem; cursor: pointer; }
        .sheet h2 { margin: 0 2.5rem .2rem 0; font-size: 1.35rem; font-weight: 800; line-height: 1.2; }
        .sheet .lead { margin: 0 0 1rem; font-size: .86rem; color: var(--muted); }

        .progress { margin-bottom: 1.1rem; }
        .progress .bar { height: 10px; border-radius: 999px; background: #f1eff7; overflow: hidden; position: relative; }
        .progress .bar i { display: block; height: 100%; width: 0; border-radius: inherit;
                           background: linear-gradient(90deg, #ff8a00, #d62976, #7b4bff); background-size: 200% 100%;
                           transition: width .5s cubic-bezier(.2,.9,.3,1.3); animation: flow 2.5s linear infinite; }
        @keyframes flow { to { background-position: 200% 0; } }
        .progress.full .bar i { background: linear-gradient(90deg, #22c55e, #16a34a); box-shadow: 0 0 14px rgba(34,197,94,.6); }
        .progress .steps { display: flex; justify-content: space-between; margin-top: .45rem; font-size: .72rem; font-weight: 600; color: #a7a3b8; }
        .progress .steps span { transition: color .3s, transform .3s; }
        .progress .steps span.done { color: #16a34a; transform: scale(1.06); }
        .progress .count { display: block; text-align: right; font-size: .74rem; font-weight: 700; color: var(--muted); margin-bottom: .3rem; }

        /* No opacity:0 here: "up" only has a "from" frame, so it animates back to this value, and 0 would keep the fields invisible */
        .fld { margin-bottom: .95rem; animation: up .45s both; animation-delay: calc(.12s + var(--i) * .07s); }
        .sheet:not(.open) .fld { animation: none; }
        .fld > label, .fld > .lbl { display: block; font-size: .8rem; font-weight: 700; margin-bottom: .35rem; }
        .fld .ok { float: right; color: #16a34a; font-size: .8rem; opacity: 0; transform: scale(.4); transition: opacity .25s, transform .3s cubic-bezier(.2,.9,.3,1.8); }
        .fld.valid .ok { opacity: 1; transform: none; }
        .inp { display: flex; align-items: center; gap: .5rem; border: 2px solid #ebe8f3; border-radius: 14px; padding: 0 .85rem;
               background: #faf9fd; transition: border-color .2s, box-shadow .2s, background .2s; }
        .inp:focus-within { border-color: #7b4bff; background: #fff; box-shadow: 0 0 0 4px rgba(123,75,255,.12); }
        .fld.valid .inp { border-color: #22c55e; }
        .inp input { flex: 1; min-width: 0; border: 0; outline: 0; background: none; font: 600 1rem 'Poppins', system-ui, sans-serif;
                     color: var(--ink); padding: .8rem 0; }
        .inp .pre { font-weight: 700; color: var(--muted); font-size: .95rem; }
        .pills { display: grid; grid-template-columns: repeat(3, 1fr); gap: .5rem; }
        .pills label { position: relative; }
        .pills input { position: absolute; opacity: 0; inset: 0; }
        .pills span { display: block; text-align: center; padding: .7rem .3rem; border-radius: 14px; border: 2px solid #ebe8f3;
                      background: #faf9fd; font-weight: 600; font-size: .9rem; cursor: pointer;
                      transition: border-color .2s, background .2s, transform .2s cubic-bezier(.2,.9,.3,1.8); }
        .pills input:checked + span { border-color: #7b4bff; background: #f3eeff; color: #5b2fd6; transform: scale(1.04); }
        .pills input:focus-visible + span { box-shadow: 0 0 0 4px rgba(123,75,255,.2); }
        .hp { position: absolute; left: -9999px; width: 1px; height: 1px; overflow: hidden; }

        .join-btn { width: 100%; margin-top: .3rem; border: 0; border-radius: 16px; padding: .95rem; cursor: pointer;
                    font: 700 1rem 'Poppins', system-ui, sans-serif; color: #fff;
                    background: linear-gradient(90deg, #ff8a00, #d62976, #7b4bff); background-size: 200% 100%;
                    box-shadow: 0 12px 24px -12px rgba(214,41,118,.7); transition: filter .2s, transform .15s, opacity .2s; }
        .join-btn:disabled { opacity: .45; cursor: not-allowed; box-shadow: none; }
        .join-btn:not(:disabled) { animation: flow 3s linear infinite; }
        .join-btn:not(:disabled):active { transform: scale(.98); }
        .form-err { display: none; margin: .2rem 0 .6rem; padding: .6rem .8rem; border-radius: 12px; background: #fff1f0; color: #c62828; font-size: .82rem; font-weight: 600; }
        .fine { margin: .7rem 0 0; font-size: .7rem; color: #a7a3b8; text-align: center; }

        .done-view { text-align: center; padding: 1rem 0 .4rem; }
        .done-view .tick { width: 86px; height: 86px; margin: 0 auto 1rem; }
        .done-view .tick circle { stroke: #22c55e; stroke-width: 4; fill: #ecfdf3; stroke-dasharray: 260; stroke-dashoffset: 260; animation: draw .6s ease-out forwards; }
        .done-view .tick path { stroke: #16a34a; stroke-width: 6; fill: none; stroke-linecap: round; stroke-linejoin: round;
                                stroke-dasharray: 60; stroke-dashoffset: 60; animation: draw .4s .5s ease-out forwards; }
        @keyframes draw { to { stroke-dashoffset: 0; } }
        .done-view h2 { margin: 0 0 .4rem; }
        .done-view p { margin: 0 auto 1.2rem; max-width: 30ch; color: var(--muted); font-size: .9rem; }

        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after { animation-duration: .001s !important; animation-iteration-count: 1 !important; animation-delay: 0s !important; transition: none !important; }
            .floaters { display: none; }
        }
    </style>
</head>
<body>

<c:if test="${preview}">
    <div class="preview-bar">Preview: visits from this page are not counted</div>
</c:if>

<div class="bg" aria-hidden="true"><div class="blob b1"></div><div class="blob b2"></div><div class="blob b3"></div><div class="blob b4"></div></div>
<div class="floaters" aria-hidden="true" id="floaters"></div>

<main class="card">
    <div class="avatar" aria-hidden="true">
        <div class="in"><span><c:out value="${fn:toUpperCase(fn:substring(fn:trim(scanner.businessName), 0, 1))}"/></span></div>
        <span class="wave">&#128075;</span>
    </div>
    <p class="hello">Thanks for visiting</p>
    <h1><c:out value="${scanner.businessName}"/></h1>
    <p class="sub">${empty links ? 'Join our VIP Club for exclusive offers on WhatsApp. It only takes a few seconds!' : 'Share your experience or follow us. It only takes a few seconds!'}</p>

    <c:if test="${scanner.joinForm}">
        <button type="button" class="vip" id="vipBtn" aria-haspopup="dialog">
            <span class="face" aria-hidden="true"></span>
            <span class="tile" aria-hidden="true">&#128081;</span>
            <span class="txt">
                <b id="vipTitle">Join our <em>VIP Club</em></b>
                <small id="vipSub">Exclusive offers &amp; updates on WhatsApp</small>
                <span class="badge" id="vipBadge">FREE &middot; TAKES 20 SECONDS</span>
            </span>
            <span class="arrow" aria-hidden="true" id="vipArrow">&#10140;</span>
        </button>
    </c:if>

    <nav class="apps" aria-label="Choose an app">
        <c:forEach var="p" items="${links}" varStatus="st">
            <c:set var="iconKey" value="${p.key}"/>
            <a class="app ${p.key}" style="--i:${st.index}"
               href="${goBase}${p.key}${preview ? '?preview=1' : ''}">
                <c:if test="${p.key eq 'google'}"><span class="face" aria-hidden="true"></span></c:if>
                <span class="tile"><%@ include file="_platform-icon.jspf" %></span>
                <span class="txt">
                    <b><c:out value="${p.callToAction}"/></b>
                    <c:choose>
                        <c:when test="${p.key eq 'google'}">
                            <span class="stars" aria-hidden="true"><i style="--s:0">&#9733;</i><i style="--s:1">&#9733;</i><i style="--s:2">&#9733;</i><i style="--s:3">&#9733;</i><i style="--s:4">&#9733;</i></span>
                        </c:when>
                        <c:when test="${p.key eq 'instagram'}"><small>See our latest posts &amp; reels</small></c:when>
                        <c:when test="${p.key eq 'facebook'}"><small>Join our community</small></c:when>
                        <c:when test="${p.key eq 'whatsapp'}"><small>Get updates straight on WhatsApp</small></c:when>
                        <c:when test="${p.key eq 'youtube'}"><small>Watch our videos</small></c:when>
                    </c:choose>
                </span>
                <span class="arrow" aria-hidden="true">&#10140;</span>
            </a>
        </c:forEach>
    </nav>

    <p class="thanks">Your support means a lot <span>&#10084;&#65039;</span></p>
    <div class="sticker">SCANNER <c:out value="${scanner.stickerNo}"/></div>
    <p class="brand">The Socio Advert <span>by Bijwala Solutions</span></p>
</main>

<c:if test="${scanner.joinForm}">
<div class="sheet" id="joinSheet" hidden>
    <div class="sheet-box" role="dialog" aria-modal="true" aria-labelledby="joinTitle">
        <button type="button" class="sheet-close" id="joinClose" aria-label="Close">&#10005;</button>

        <form id="joinForm" novalidate action="${joinUrl}${preview ? '?preview=1' : ''}" method="post">
            <h2 id="joinTitle">&#128081; Join the VIP Club</h2>
            <p class="lead">Be the first to hear about offers from <b><c:out value="${scanner.businessName}"/></b>.</p>

            <div class="progress" id="joinProgress">
                <span class="count" id="joinCount">0 of 4</span>
                <div class="bar" role="progressbar" aria-valuemin="0" aria-valuemax="4" aria-valuenow="0" aria-label="Form progress"><i id="joinBar"></i></div>
                <div class="steps" aria-hidden="true">
                    <span data-step="name">Name</span><span data-step="age">Age</span><span data-step="gender">Gender</span><span data-step="phone">Mobile</span>
                </div>
            </div>

            <div class="fld" data-field="name" style="--i:0">
                <label for="jName">Your name <span class="ok">&#10004;</span></label>
                <div class="inp"><input id="jName" name="name" type="text" maxlength="100" autocomplete="name" placeholder="e.g. Sameer" required></div>
            </div>
            <div class="fld" data-field="age" style="--i:1">
                <label for="jAge">Age <span class="ok">&#10004;</span></label>
                <div class="inp"><input id="jAge" name="age" type="number" inputmode="numeric" min="5" max="110" placeholder="e.g. 25" required></div>
            </div>
            <div class="fld" data-field="gender" style="--i:2">
                <span class="lbl" id="jGenderLbl">Gender <span class="ok">&#10004;</span></span>
                <div class="pills" role="radiogroup" aria-labelledby="jGenderLbl">
                    <label><input type="radio" name="gender" value="Male"><span>&#128104; Male</span></label>
                    <label><input type="radio" name="gender" value="Female"><span>&#128105; Female</span></label>
                    <label><input type="radio" name="gender" value="Other"><span>&#10024; Other</span></label>
                </div>
            </div>
            <div class="fld" data-field="phone" style="--i:3">
                <label for="jPhone">WhatsApp number <span class="ok">&#10004;</span></label>
                <div class="inp"><span class="pre">+91</span><input id="jPhone" name="phone" type="tel" inputmode="numeric" maxlength="14" autocomplete="tel-national" placeholder="10-digit mobile" required></div>
            </div>
            <div class="hp" aria-hidden="true"><label>Website <input type="text" name="website" tabindex="-1" autocomplete="off"></label></div>

            <div class="form-err" id="joinErr" role="alert"></div>
            <button type="submit" class="join-btn" id="joinSubmit" disabled>Fill all 4 to join</button>
            <p class="fine">By joining you agree to get offers from <c:out value="${scanner.businessName}"/> on WhatsApp. No spam, promise.</p>
        </form>

        <div class="done-view" id="joinDone" hidden>
            <svg class="tick" viewBox="0 0 86 86" aria-hidden="true"><circle cx="43" cy="43" r="40"/><path d="M26 44l11 11 23-24"/></svg>
            <h2 id="joinDoneTitle">Welcome to the club!</h2>
            <p id="joinDoneText">You're on the VIP list. Watch WhatsApp for exclusive offers.</p>
            <button type="button" class="join-btn" id="joinDoneBtn">Awesome!</button>
        </div>
    </div>
</div>
</c:if>

<script>
(function () {
    var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    // Floating sparkles
    if (!reduce) {
        var box = document.getElementById('floaters');
        var glyphs = ['⭐', '✨', '💖', '👍', '🎉', '⭐', '💫'];
        for (var i = 0; i < 14; i++) {
            var s = document.createElement('span');
            s.textContent = glyphs[i % glyphs.length];
            s.style.left = (Math.random() * 100) + 'vw';
            s.style.fontSize = (0.8 + Math.random() * 1.1) + 'rem';
            s.style.animationDuration = (9 + Math.random() * 9) + 's';
            s.style.animationDelay = (-Math.random() * 16) + 's';
            box.appendChild(s);
        }
    }

    var colors = ['#4285F4', '#EA4335', '#FBBC05', '#34A853', '#d62976', '#7b4bff', '#ff8a00'];

    function confetti(x, y) {
        for (var i = 0; i < 26; i++) {
            var c = document.createElement('i');
            c.className = 'confetti';
            var angle = Math.random() * Math.PI * 2, dist = 60 + Math.random() * 110;
            c.style.left = x + 'px';
            c.style.top  = y + 'px';
            c.style.background = colors[i % colors.length];
            c.style.setProperty('--dx', Math.cos(angle) * dist + 'px');
            c.style.setProperty('--dy', (Math.sin(angle) * dist - 40) + 'px');
            c.style.setProperty('--rot', (Math.random() * 720 - 360) + 'deg');
            document.body.appendChild(c);
            setTimeout(function (el) { el.remove(); }, 950, c);
        }
    }

    document.querySelectorAll('.app').forEach(function (a) {
        a.addEventListener('click', function (e) {
            // Let new-tab / modified clicks behave normally
            if (e.metaKey || e.ctrlKey || e.shiftKey || e.button !== 0) return;
            var r = a.getBoundingClientRect();
            var x = (e.clientX || r.left + r.width / 2), y = (e.clientY || r.top + r.height / 2);
            if (!reduce) {
                var size = Math.max(r.width, r.height);
                var rp = document.createElement('span');
                rp.className = 'ripple';
                rp.style.width = rp.style.height = size + 'px';
                rp.style.left = (x - r.left - size / 2) + 'px';
                rp.style.top  = (y - r.top  - size / 2) + 'px';
                a.appendChild(rp);
                confetti(x, y);
                e.preventDefault();
                // Short pause so the celebration is seen, then go
                setTimeout(function () { window.location.href = a.href; }, 380);
            }
        });
    });

    // ── "Join our VIP Club" form ──────────────────────────────────────────────
    var vip = document.getElementById('vipBtn');
    if (vip) {
        var sheet  = document.getElementById('joinSheet');
        var form   = document.getElementById('joinForm');
        var submit = document.getElementById('joinSubmit');
        var errBox = document.getElementById('joinErr');
        var fName  = document.getElementById('jName');   // not form.name: that is the form's own name attribute
        var fAge   = document.getElementById('jAge');
        var fPhone = document.getElementById('jPhone');
        var joinedKey = 'vip-joined-' + location.pathname;

        function store(get, val) {
            try { return get ? localStorage.getItem(joinedKey) : localStorage.setItem(joinedKey, val); } catch (e) { return null; }
        }
        function showJoined(name) {
            vip.classList.add('joined');
            document.getElementById('vipTitle').textContent = "You're in the VIP Club!";
            document.getElementById('vipSub').textContent = name ? 'Thanks, ' + name + '. Offers will reach you on WhatsApp.' : 'Offers will reach you on WhatsApp.';
            document.getElementById('vipBadge').textContent = 'TAP TO UPDATE YOUR DETAILS';
            document.getElementById('vipArrow').innerHTML = '&#10004;';
        }
        if (store(true)) showJoined(store(true));

        var checks = {
            name:   function () { return fName.value.trim().length >= 2; },
            age:    function () { var a = parseInt(fAge.value, 10); return a >= 5 && a <= 110; },
            gender: function () { return !!form.querySelector('input[name=gender]:checked'); },
            phone:  function () { return /^[6-9]\d{9}$/.test(phoneDigits()); }
        };
        function phoneDigits() {
            var d = fPhone.value.replace(/\D/g, '');
            if (d.length === 12 && d.indexOf('91') === 0) d = d.slice(2);
            if (d.length === 11 && d.charAt(0) === '0') d = d.slice(1);
            return d;
        }
        var lastDone = 0;
        function update() {
            var done = 0;
            Object.keys(checks).forEach(function (k) {
                var ok = checks[k]();
                if (ok) done++;
                form.querySelector('[data-field=' + k + ']').classList.toggle('valid', ok);
                document.querySelector('.steps [data-step=' + k + ']').classList.toggle('done', ok);
            });
            document.getElementById('joinBar').style.width = (done * 25) + '%';
            document.querySelector('#joinProgress .bar').setAttribute('aria-valuenow', done);
            document.getElementById('joinProgress').classList.toggle('full', done === 4);
            document.getElementById('joinCount').textContent = done === 4 ? 'All set! 🎉' : done + ' of 4';
            submit.disabled = done < 4;
            submit.textContent = done === 4 ? 'Join the VIP Club 👑' : (done === 3 ? 'Just 1 more to go' : 'Fill all 4 to join');
            if (done === 4 && lastDone < 4 && !reduce) {
                var r = submit.getBoundingClientRect();
                confetti(r.left + r.width / 2, r.top);
            }
            lastDone = done;
        }
        form.addEventListener('input', function () { errBox.style.display = 'none'; update(); });
        form.addEventListener('change', update);

        function open() {
            sheet.hidden = false;
            document.body.style.overflow = 'hidden';
            requestAnimationFrame(function () { requestAnimationFrame(function () { sheet.classList.add('open'); }); });
            update();
            setTimeout(function () { if (!form.hidden) fName.focus(); }, 400);
        }
        function close() {
            sheet.classList.remove('open');
            document.body.style.overflow = '';
            setTimeout(function () { sheet.hidden = true; }, 300);
        }
        vip.addEventListener('click', function () {
            form.hidden = false;
            document.getElementById('joinDone').hidden = true;
            open();
        });
        document.getElementById('joinClose').addEventListener('click', close);
        document.getElementById('joinDoneBtn').addEventListener('click', close);
        sheet.addEventListener('click', function (e) { if (e.target === sheet) close(); });
        document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !sheet.hidden) close(); });

        form.addEventListener('submit', function (e) {
            e.preventDefault();
            if (submit.disabled) return;
            submit.disabled = true;
            submit.textContent = 'Joining…';
            var body = new URLSearchParams(new FormData(form));
            body.set('phone', phoneDigits());
            fetch(form.action, { method: 'POST', body: body })
                .then(function (r) { return r.json().catch(function () { return { error: 'Something went wrong. Please try again.' }; }); })
                .then(function (res) {
                    if (!res.ok) throw new Error(res.error || 'Something went wrong. Please try again.');
                    var first = fName.value.trim().split(' ')[0];
                    document.getElementById('joinDoneTitle').textContent = (res.already ? 'Welcome back, ' : 'Welcome to the club, ') + first + '!';
                    document.getElementById('joinDoneText').textContent = res.already
                        ? 'Your details are updated. Watch WhatsApp for exclusive offers.'
                        : "You're on the VIP list. Watch WhatsApp for exclusive offers.";
                    form.hidden = true;
                    document.getElementById('joinDone').hidden = false;
                    if (!res.preview) { store(false, first); }
                    showJoined(first);
                    if (!reduce) {
                        confetti(window.innerWidth / 2, window.innerHeight * 0.45);
                        setTimeout(function () { confetti(window.innerWidth * 0.3, window.innerHeight * 0.4); }, 180);
                        setTimeout(function () { confetti(window.innerWidth * 0.7, window.innerHeight * 0.4); }, 340);
                    }
                })
                .catch(function (err) {
                    errBox.textContent = err.message && err.message !== 'Failed to fetch' ? err.message : 'No internet? Please try again.';
                    errBox.style.display = 'block';
                })
                .then(function () { if (!form.hidden) update(); });
        });
    }

    // Coming back from the app (back button) — don't show a frozen ripple
    window.addEventListener('pageshow', function () {
        document.querySelectorAll('.ripple').forEach(function (el) { el.remove(); });
    });
})();
</script>
</body>
</html>
