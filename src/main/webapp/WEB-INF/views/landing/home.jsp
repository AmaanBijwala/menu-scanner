<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- NOTE: no JS template literals in this file — JSP would treat their placeholders as EL. --%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="waHello" value="https://wa.me/${phoneE164}?text=Hi%20Amaan%2C%20I%20saw%20your%20website%20and%20want%20to%20know%20more."/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <title><c:out value="${name}"/> · <c:out value="${brand}"/> — Digital Menu QR, Google Review QR &amp; Custom Software</title>
    <meta name="description" content="Java developer in Mumbai. QR digital menus, Google review QR stickers and custom web apps for local businesses. Free demo.">

    <%-- Link previews (WhatsApp, LinkedIn, etc.) --%>
    <meta property="og:type"        content="website">
    <meta property="og:url"         content="<c:out value="${siteUrl}"/>">
    <meta property="og:title"       content="<c:out value="${name}"/> · Digital tools for local businesses">
    <meta property="og:description" content="QR digital menu, Google review QR and custom software. Free demo. Call / WhatsApp <c:out value="${phoneDisplay}"/>">
    <meta name="theme-color" content="#09090b">
    <meta name="color-scheme" content="dark">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
    <script>document.documentElement.classList.add('js');</script>
    <style>
        :root {
            --bg: #09090b; --bg-2: #0f0f12; --card: rgba(255,255,255,0.035); --card-solid: #131316;
            --line: rgba(255,255,255,0.08); --line-2: rgba(255,255,255,0.14);
            --ink: #fafafa; --muted: #a1a1aa; --faint: #71717a;
            --brand: #ff6b00; --brand-2: #ffb347; --pink: #ff3d7f; --wa: #25d366; --green: #4ade80;
            --grad: linear-gradient(120deg, #ff6b00 0%, #ff3d7f 50%, #ffb347 100%);
            --radius: 1.25rem;
            --display: 'Space Grotesk', 'Inter', system-ui, sans-serif;
        }
        * { box-sizing: border-box; }
        html { scroll-behavior: smooth; background: var(--bg); color-scheme: dark; }
        /* body stays transparent so the fixed glow layer (z-index:-1) shows; html paints the dark base */
        body { margin: 0; background: transparent; color: var(--ink); line-height: 1.6; overflow-x: hidden;
               font-family: 'Inter', system-ui, -apple-system, 'Segoe UI', sans-serif; -webkit-font-smoothing: antialiased; }
        a { color: inherit; }
        img { max-width: 100%; }
        ::selection { background: var(--brand); color: #fff; }
        .wrap { max-width: 1160px; margin: 0 auto; padding: 0 1.25rem; position: relative; }
        section { padding: 6rem 0; scroll-margin-top: 4rem; position: relative; }
        .eyebrow { display: inline-flex; align-items: center; gap: 0.5rem; font-size: 0.72rem; font-weight: 700; letter-spacing: 0.14em;
                   text-transform: uppercase; color: var(--brand-2); margin-bottom: 0.9rem; }
        .eyebrow::before { content: ''; width: 18px; height: 2px; background: var(--grad); border-radius: 2px; }
        h1, h2, h3 { font-family: var(--display); }
        h2 { font-size: clamp(1.9rem, 4.2vw, 3rem); line-height: 1.08; letter-spacing: -0.03em; margin: 0 0 1rem; font-weight: 700; }
        .lead { color: var(--muted); font-size: 1.08rem; max-width: 620px; margin: 0 0 3rem; }
        .grad-text { background: var(--grad); background-size: 200% auto; -webkit-background-clip: text; background-clip: text;
                     color: transparent; animation: shine 6s linear infinite; }
        @keyframes shine { to { background-position: 200% center; } }

        /* ── Background: glows + grid ── */
        .bg-fx { position: fixed; inset: 0; z-index: -1; pointer-events: none; overflow: hidden; }
        .bg-fx .grid { position: absolute; inset: 0;
            background-image: linear-gradient(var(--line) 1px, transparent 1px), linear-gradient(90deg, var(--line) 1px, transparent 1px);
            background-size: 64px 64px; mask-image: radial-gradient(ellipse 80% 60% at 50% 0%, #000 30%, transparent 75%);
            -webkit-mask-image: radial-gradient(ellipse 80% 60% at 50% 0%, #000 30%, transparent 75%); opacity: 0.5; }
        .blob { position: absolute; border-radius: 50%; filter: blur(90px); opacity: 0.45; animation: drift 18s ease-in-out infinite alternate; }
        .blob.b1 { width: 520px; height: 520px; background: #ff6b00; top: -180px; left: -120px; }
        .blob.b2 { width: 460px; height: 460px; background: #ff3d7f; top: 10%; right: -160px; opacity: 0.28; animation-duration: 22s; }
        .blob.b3 { width: 380px; height: 380px; background: #7c3aed; bottom: -160px; left: 30%; opacity: 0.18; animation-duration: 26s; }
        @keyframes drift { 0% { transform: translate(0, 0) scale(1); } 100% { transform: translate(60px, 40px) scale(1.15); } }

        /* ── Scroll progress ── */
        .progress { position: fixed; top: 0; left: 0; height: 3px; width: 100%; z-index: 100; background: var(--grad);
                    transform-origin: 0 50%; transform: scaleX(0); }

        /* ── Buttons ── */
        .btn { position: relative; display: inline-flex; align-items: center; justify-content: center; gap: 0.55rem; padding: 0.95rem 1.5rem;
               border-radius: 999px; font-weight: 700; font-size: 0.95rem; text-decoration: none; border: 1px solid transparent; cursor: pointer;
               font-family: inherit; transition: transform .2s ease, box-shadow .25s ease, background .2s ease, border-color .2s ease; overflow: hidden; }
        .btn svg { width: 18px; height: 18px; flex: none; }
        .btn-primary { background: var(--grad); background-size: 200% auto; color: #fff; box-shadow: 0 8px 30px rgba(255,107,0,0.35); }
        .btn-primary:hover { background-position: right center; box-shadow: 0 12px 40px rgba(255,61,127,0.45); transform: translateY(-2px); }
        .btn-wa { background: var(--wa); color: #04210f; box-shadow: 0 8px 30px rgba(37,211,102,0.3); }
        .btn-wa:hover { transform: translateY(-2px); box-shadow: 0 12px 40px rgba(37,211,102,0.45); }
        .btn-ghost { background: rgba(255,255,255,0.04); color: var(--ink); border-color: var(--line-2); backdrop-filter: blur(8px); }
        .btn-ghost:hover { border-color: var(--brand); background: rgba(255,107,0,0.08); transform: translateY(-2px); }
        .btn .shine-sweep { position: absolute; inset: 0; background: linear-gradient(110deg, transparent 30%, rgba(255,255,255,0.35) 50%, transparent 70%);
                            transform: translateX(-120%); animation: sweep 3.5s ease-in-out infinite; }
        @keyframes sweep { 0%, 60% { transform: translateX(-120%); } 100% { transform: translateX(120%); } }

        /* ── Header ── */
        header.top { position: fixed; top: 0; left: 0; right: 0; z-index: 90; padding-top: env(safe-area-inset-top, 0px);
                     transition: background .3s ease, border-color .3s ease; border-bottom: 1px solid transparent; }
        header.top.scrolled { background: rgba(9,9,11,0.72); backdrop-filter: saturate(160%) blur(14px); -webkit-backdrop-filter: saturate(160%) blur(14px);
                              border-bottom-color: var(--line); }
        header.top .wrap { display: flex; align-items: center; justify-content: space-between; height: 4.25rem; gap: 1rem; }
        .logo { display: flex; align-items: center; gap: 0.65rem; font-weight: 800; text-decoration: none; letter-spacing: -0.01em; font-family: var(--display); }
        .logo-mark { width: 36px; height: 36px; border-radius: 11px; background: var(--grad); background-size: 200% auto; color: #fff;
                     display: grid; place-items: center; font-size: 0.85rem; font-weight: 800; animation: shine 6s linear infinite;
                     box-shadow: 0 0 24px rgba(255,107,0,0.4); }
        nav.links { display: flex; gap: 0.25rem; font-size: 0.88rem; font-weight: 600; padding: 0.3rem; border-radius: 999px;
                    background: rgba(255,255,255,0.04); border: 1px solid var(--line); }
        nav.links a { text-decoration: none; color: var(--muted); padding: 0.4rem 0.9rem; border-radius: 999px; transition: color .2s, background .2s; }
        nav.links a:hover, nav.links a.active { color: var(--ink); background: rgba(255,255,255,0.08); }
        header.top .btn { padding: 0.6rem 1.05rem; font-size: 0.85rem; }

        /* ── Hero ── */
        .hero { padding: 9rem 0 5rem; }
        .hero .wrap { display: grid; grid-template-columns: 1.15fr 0.85fr; gap: 3rem; align-items: center; }
        .badge { display: inline-flex; align-items: center; gap: 0.55rem; padding: 0.4rem 0.9rem 0.4rem 0.45rem; border-radius: 999px;
                 background: rgba(255,255,255,0.05); border: 1px solid var(--line-2); font-size: 0.8rem; color: var(--muted); margin-bottom: 1.5rem; }
        .badge .dot { position: relative; width: 22px; height: 22px; border-radius: 50%; background: rgba(74,222,128,0.15); display: grid; place-items: center; }
        .badge .dot::after { content: ''; width: 8px; height: 8px; border-radius: 50%; background: var(--green); box-shadow: 0 0 0 0 rgba(74,222,128,0.6);
                             animation: pulse 2s infinite; }
        @keyframes pulse { 0% { box-shadow: 0 0 0 0 rgba(74,222,128,0.6); } 70% { box-shadow: 0 0 0 10px rgba(74,222,128,0); } 100% { box-shadow: 0 0 0 0 rgba(74,222,128,0); } }
        .hero h1 { font-size: clamp(2.5rem, 6.4vw, 4.6rem); line-height: 1.02; letter-spacing: -0.045em; margin: 0 0 1.4rem; font-weight: 700; }
        .rotator { display: inline-block; min-width: 1ch; }
        .rotator::after { content: ''; display: inline-block; width: 3px; height: 0.85em; margin-left: 4px; vertical-align: -0.05em;
                          background: var(--brand); animation: blink 1s steps(1) infinite; }
        @keyframes blink { 50% { opacity: 0; } }
        .hero p.sub { font-size: 1.15rem; color: var(--muted); margin: 0 0 2rem; max-width: 540px; }
        .hero .ctas { display: flex; gap: 0.8rem; flex-wrap: wrap; margin-bottom: 2rem; }
        .ticks { display: flex; gap: 0.6rem; flex-wrap: wrap; font-size: 0.85rem; color: var(--muted); padding: 0; margin: 0; list-style: none; }
        .ticks li { padding: 0.35rem 0.8rem; border-radius: 999px; border: 1px solid var(--line); background: rgba(255,255,255,0.03); }
        .ticks li::before { content: '✓'; color: var(--green); font-weight: 800; margin-right: 0.4rem; }

        /* Phone mockup */
        .stage { position: relative; display: grid; place-items: center; min-height: 560px; perspective: 1200px; }
        .phone { position: relative; width: 270px; height: 550px; border-radius: 44px; padding: 12px; background: linear-gradient(145deg, #2a2a30, #0d0d10);
                 border: 1px solid var(--line-2); box-shadow: 0 40px 100px rgba(0,0,0,0.6), 0 0 80px rgba(255,107,0,0.25), inset 0 0 0 2px #1d1d22;
                 transform: rotateY(-14deg) rotateX(6deg); transition: transform .3s ease; animation: float 6s ease-in-out infinite; }
        @keyframes float { 0%, 100% { translate: 0 0; } 50% { translate: 0 -14px; } }
        .phone .notch { position: absolute; top: 20px; left: 50%; transform: translateX(-50%); width: 90px; height: 24px; border-radius: 20px; background: #000; z-index: 3; }
        .screen { position: relative; height: 100%; border-radius: 34px; overflow: hidden; background: #fffaf5; color: #1c1917; }
        .scr-head { position: absolute; top: 0; left: 0; right: 0; z-index: 2; padding: 3.1rem 1rem 0.75rem; background: linear-gradient(#fffaf5 75%, rgba(255,250,245,0)); }
        .scr-head b { display: block; font-family: var(--display); font-size: 1.05rem; }
        .scr-head .cats { display: flex; gap: 0.35rem; margin-top: 0.55rem; }
        .scr-head .cats span { font-size: 0.62rem; font-weight: 700; padding: 0.25rem 0.55rem; border-radius: 999px; background: #f3e8de; color: #7c5a3e; }
        .scr-head .cats span:first-child { background: #ff6b00; color: #fff; }
        .menu-roll { position: absolute; top: 6.6rem; left: 0; right: 0; padding: 0 0.85rem; animation: roll 16s linear infinite; }
        @keyframes roll { from { transform: translateY(0); } to { transform: translateY(-50%); } }
        .dish { display: flex; gap: 0.65rem; align-items: center; padding: 0.6rem; margin-bottom: 0.55rem; border-radius: 14px; background: #fff;
                box-shadow: 0 2px 10px rgba(120,60,10,0.07); }
        .dish .pic { width: 52px; height: 52px; border-radius: 11px; display: grid; place-items: center; font-size: 1.6rem; flex: none; }
        .dish b { display: block; font-size: 0.78rem; line-height: 1.25; }
        .dish small { display: block; font-size: 0.62rem; color: #8a7a6d; }
        .dish .price { margin-left: auto; font-size: 0.78rem; font-weight: 800; color: #ff6b00; }
        .veg { display: inline-block; width: 9px; height: 9px; border: 1.5px solid #16a34a; border-radius: 2px; position: relative; margin-right: 4px; vertical-align: 0; }
        .veg::after { content: ''; position: absolute; inset: 1.5px; border-radius: 50%; background: #16a34a; }
        .veg.non { border-color: #dc2626; } .veg.non::after { background: #dc2626; }

        .float-chip { position: absolute; z-index: 4; display: flex; align-items: center; gap: 0.6rem; padding: 0.65rem 0.9rem; border-radius: 14px;
                      background: rgba(20,20,24,0.78); backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px); border: 1px solid var(--line-2);
                      box-shadow: 0 20px 40px rgba(0,0,0,0.45); font-size: 0.78rem; white-space: nowrap; animation: float 5s ease-in-out infinite; }
        .float-chip .ic { width: 32px; height: 32px; border-radius: 10px; display: grid; place-items: center; font-size: 1rem; }
        .float-chip b { display: block; font-size: 0.8rem; } .float-chip small { color: var(--muted); font-size: 0.7rem; }
        .chip-1 { top: 70px; left: -10px; animation-delay: -1s; }
        .chip-1 .ic { background: rgba(255,107,0,0.18); }
        .chip-2 { bottom: 110px; right: -20px; animation-delay: -2.5s; }
        .chip-2 .ic { background: rgba(251,191,36,0.18); }
        .chip-3 { bottom: 30px; left: 0; animation-delay: -4s; }
        .chip-3 .ic { background: rgba(37,211,102,0.18); }
        .stars { color: #fbbf24; letter-spacing: 1px; }

        /* ── Marquee ── */
        .marquee { border-block: 1px solid var(--line); background: rgba(255,255,255,0.02); overflow: hidden; padding: 1.15rem 0;
                   mask-image: linear-gradient(90deg, transparent, #000 10%, #000 90%, transparent);
                   -webkit-mask-image: linear-gradient(90deg, transparent, #000 10%, #000 90%, transparent); }
        .marquee-track { display: flex; gap: 3rem; width: max-content; animation: marquee 32s linear infinite; }
        .marquee:hover .marquee-track { animation-play-state: paused; }
        .marquee span { font-family: var(--display); font-weight: 700; font-size: 1.15rem; color: var(--faint); white-space: nowrap; display: flex; align-items: center; gap: 3rem; }
        .marquee span::after { content: '✦'; color: var(--brand); font-size: 0.8rem; }
        @keyframes marquee { to { transform: translateX(-50%); } }

        /* ── Glow cards (spotlight follows the pointer) ── */
        .glow-card { position: relative; background: var(--card); border: 1px solid var(--line); border-radius: var(--radius);
                     transition: border-color .3s ease, transform .3s ease; transform-style: preserve-3d; isolation: isolate; }
        .glow-card::before { content: ''; position: absolute; inset: 0; border-radius: inherit; z-index: -1; opacity: 0; transition: opacity .3s ease;
                             background: radial-gradient(420px circle at var(--mx, 50%) var(--my, 50%), rgba(255,107,0,0.16), transparent 45%); }
        .glow-card:hover { border-color: rgba(255,107,0,0.4); }
        .glow-card:hover::before { opacity: 1; }

        /* ── Services ── */
        .grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.25rem; }
        .service { padding: 2rem; display: flex; flex-direction: column; }
        .service .top-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
        .service .tag { font-size: 0.68rem; font-weight: 800; letter-spacing: 0.1em; text-transform: uppercase; padding: 0.3rem 0.7rem; border-radius: 999px;
                        background: rgba(255,107,0,0.12); color: var(--brand-2); border: 1px solid rgba(255,107,0,0.25); }
        .service .icon { width: 56px; height: 56px; border-radius: 16px; display: grid; place-items: center; font-size: 1.7rem;
                         background: linear-gradient(145deg, rgba(255,255,255,0.08), rgba(255,255,255,0.02)); border: 1px solid var(--line-2);
                         transition: transform .4s cubic-bezier(.34,1.56,.64,1); }
        .service:hover .icon { transform: rotate(-8deg) scale(1.1); }
        .service h3 { font-size: 1.45rem; margin: 0 0 0.6rem; letter-spacing: -0.02em; }
        .service p { color: var(--muted); margin: 0 0 1.4rem; font-size: 0.95rem; }
        .service ul { list-style: none; padding: 0; margin: 0 0 1.75rem; flex: 1; }
        .service li { position: relative; padding: 0.45rem 0 0.45rem 1.75rem; font-size: 0.92rem; color: #d4d4d8; border-top: 1px dashed var(--line); }
        .service li:first-child { border-top: none; }
        .service li::before { content: ''; position: absolute; left: 0; top: 0.8rem; width: 16px; height: 16px; border-radius: 50%;
                              background: rgba(255,107,0,0.15) url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3E%3Cpath d='M4 8.5l2.5 2.5L12 5.5' fill='none' stroke='%23ff8a3d' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E") center/12px no-repeat; }
        .service .btn { width: 100%; }
        .service.featured { background: linear-gradient(160deg, rgba(255,107,0,0.12), rgba(255,61,127,0.05) 60%, rgba(255,255,255,0.02)); border-color: rgba(255,107,0,0.3); }

        /* ── Stats strip ── */
        .stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; margin-top: 3.5rem; }
        .stat { padding: 1.5rem; text-align: center; }
        .stat .num { font-family: var(--display); font-size: clamp(1.9rem, 4vw, 2.6rem); font-weight: 700; line-height: 1; letter-spacing: -0.03em; }
        .stat .lbl { font-size: 0.82rem; color: var(--muted); margin-top: 0.45rem; }

        /* ── Demo ── */
        .demo { padding: 3.5rem; display: grid; grid-template-columns: 1fr auto; gap: 3rem; align-items: center; overflow: hidden;
                background: linear-gradient(135deg, rgba(255,107,0,0.14), rgba(124,58,237,0.08) 60%, rgba(255,255,255,0.02)); border-color: rgba(255,107,0,0.25); }
        .demo p { color: #d4d4d8; margin: 0 0 1.75rem; font-size: 1.05rem; }
        .qr-box { position: relative; background: #fff; padding: 1.1rem; border-radius: 1.4rem; text-align: center;
                  box-shadow: 0 0 0 8px rgba(255,255,255,0.05), 0 30px 60px rgba(0,0,0,0.5); }
        .qr-box img { width: 200px; height: 200px; display: block; }
        .qr-box small { display: block; color: #52525b; font-size: 0.75rem; margin-top: 0.5rem; font-weight: 700; }
        .qr-box .scan { position: absolute; left: 1.1rem; right: 1.1rem; top: 1.1rem; height: 3px; border-radius: 3px;
                        background: linear-gradient(90deg, transparent, #ff6b00, transparent); box-shadow: 0 0 18px 4px rgba(255,107,0,0.6);
                        animation: scan 2.6s ease-in-out infinite; }
        @keyframes scan { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(200px); } }
        .qr-box .corner { position: absolute; width: 26px; height: 26px; border: 3px solid var(--brand); }
        .qr-box .c1 { top: -6px; left: -6px; border-right: none; border-bottom: none; border-radius: 10px 0 0 0; }
        .qr-box .c2 { top: -6px; right: -6px; border-left: none; border-bottom: none; border-radius: 0 10px 0 0; }
        .qr-box .c3 { bottom: -6px; left: -6px; border-right: none; border-top: none; border-radius: 0 0 0 10px; }
        .qr-box .c4 { bottom: -6px; right: -6px; border-left: none; border-top: none; border-radius: 0 0 10px 0; }

        /* ── Steps ── */
        .steps { position: relative; display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.25rem; }
        .steps .rail { position: absolute; top: 2.6rem; left: 12%; right: 12%; height: 2px; background: var(--line); overflow: hidden; z-index: 0; }
        .steps .rail::after { content: ''; position: absolute; inset: 0; background: var(--grad); transform-origin: 0 50%; transform: scaleX(0);
                              transition: transform 1.6s cubic-bezier(.65,0,.35,1) .3s; }
        .steps.in .rail::after { transform: scaleX(1); }
        .step { position: relative; z-index: 1; padding: 1.75rem; }
        .step .n { width: 46px; height: 46px; border-radius: 14px; display: grid; place-items: center; font-family: var(--display); font-weight: 700;
                   font-size: 1.1rem; background: var(--grad); color: #fff; margin-bottom: 1.1rem; box-shadow: 0 10px 30px rgba(255,107,0,0.35); }
        .step h3 { margin: 0 0 0.45rem; font-size: 1.2rem; }
        .step p { margin: 0; color: var(--muted); font-size: 0.93rem; }

        /* ── About ── */
        .about { display: grid; grid-template-columns: 0.85fr 1.15fr; gap: 3rem; align-items: start; }
        .profile { padding: 2.25rem; text-align: center; position: sticky; top: 6rem; }
        .avatar-ring { position: relative; width: 120px; height: 120px; margin: 0 auto 1.25rem; border-radius: 50%; padding: 3px; }
        .avatar-ring::before { content: ''; position: absolute; inset: 0; border-radius: 50%;
                               background: conic-gradient(from 0deg, #ff6b00, #ff3d7f, #ffb347, #ff6b00); animation: spin 6s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .avatar { position: relative; width: 100%; height: 100%; border-radius: 50%; background: var(--bg-2); display: grid; place-items: center;
                  font-family: var(--display); font-size: 2.4rem; font-weight: 700; letter-spacing: -0.03em; }
        .profile h3 { margin: 0; font-size: 1.5rem; }
        .profile .role { color: var(--muted); font-size: 0.9rem; margin-bottom: 1.5rem; }
        .facts { text-align: left; border-top: 1px solid var(--line); padding-top: 1.1rem; margin: 0; }
        .facts div { display: flex; gap: 0.75rem; padding: 0.5rem 0; font-size: 0.88rem; }
        .facts dt { color: var(--faint); min-width: 90px; }
        .facts dd { margin: 0; font-weight: 600; color: #e4e4e7; }
        .profile .socials { display: flex; gap: 0.5rem; justify-content: center; margin-top: 1.5rem; }
        .profile .socials .btn { padding: 0.6rem 1rem; font-size: 0.82rem; }
        .about-text p { color: var(--muted); font-size: 1.05rem; margin: 0 0 1.1rem; }
        .about-text p strong { color: var(--ink); font-weight: 600; }
        .chips { display: flex; flex-wrap: wrap; gap: 0.5rem; margin: 1.5rem 0 2.25rem; padding: 0; list-style: none; }
        .chips li { font-size: 0.8rem; font-weight: 600; padding: 0.4rem 0.85rem; border-radius: 999px; background: rgba(255,255,255,0.04);
                    border: 1px solid var(--line); transition: all .2s ease; cursor: default; }
        .chips li:hover { border-color: var(--brand); color: var(--brand-2); background: rgba(255,107,0,0.08); transform: translateY(-2px); }
        .projects { display: grid; gap: 0.8rem; }
        .project { display: flex; justify-content: space-between; align-items: center; gap: 1rem; padding: 1.15rem 1.35rem; text-decoration: none; }
        .project b { display: block; font-size: 1rem; font-family: var(--display); }
        .project span { font-size: 0.84rem; color: var(--muted); }
        .project .arrow { width: 38px; height: 38px; flex: none; border-radius: 50%; display: grid; place-items: center; border: 1px solid var(--line-2);
                          color: var(--brand-2); transition: transform .3s ease, background .3s ease; }
        .project:hover .arrow { transform: rotate(-45deg); background: var(--brand); color: #fff; border-color: var(--brand); }

        /* ── Contact ── */
        .contact { display: grid; grid-template-columns: 1.15fr 0.85fr; gap: 1.5rem; align-items: start; }
        form.enquiry { padding: 2.25rem; }
        .field { position: relative; margin-bottom: 1.1rem; }
        .field input, .field select, .field textarea {
            width: 100%; padding: 1.35rem 1rem 0.55rem; border-radius: 0.9rem; border: 1px solid var(--line-2); background: rgba(255,255,255,0.03);
            font: inherit; font-size: 0.95rem; color: var(--ink); transition: border-color .2s ease, background .2s ease, box-shadow .2s ease; }
        .field select { appearance: none; -webkit-appearance: none; cursor: pointer;
                        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3E%3Cpath d='M4 6l4 4 4-4' fill='none' stroke='%23a1a1aa' stroke-width='2' stroke-linecap='round'/%3E%3C/svg%3E");
                        background-repeat: no-repeat; background-position: right 1rem center; background-size: 14px; }
        .field select option { background: #18181b; color: var(--ink); }
        .field textarea { min-height: 110px; resize: vertical; }
        .field label { position: absolute; left: 1rem; top: 0.95rem; font-size: 0.95rem; color: var(--faint); pointer-events: none;
                       transition: all .18s ease; }
        .field input:focus, .field select:focus, .field textarea:focus { outline: none; border-color: var(--brand); background: rgba(255,107,0,0.05);
                                                                        box-shadow: 0 0 0 4px rgba(255,107,0,0.12); }
        .field input:focus + label, .field input:not(:placeholder-shown) + label,
        .field textarea:focus + label, .field textarea:not(:placeholder-shown) + label,
        .field select + label { top: 0.45rem; font-size: 0.7rem; font-weight: 600; color: var(--brand-2); letter-spacing: 0.02em; }
        .two { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
        .hp { position: absolute; left: -9999px; width: 1px; height: 1px; overflow: hidden; }
        .form-msg { margin-top: 1rem; padding: 0.85rem 1rem; border-radius: 0.8rem; font-size: 0.9rem; font-weight: 600; display: none; }
        .form-msg.ok  { display: block; background: rgba(74,222,128,0.12); color: #86efac; border: 1px solid rgba(74,222,128,0.3); }
        .form-msg.err { display: block; background: rgba(248,113,113,0.12); color: #fca5a5; border: 1px solid rgba(248,113,113,0.3); }
        form.enquiry .btn { width: 100%; }

        .reach { display: grid; gap: 0.8rem; }
        .reach a { display: flex; align-items: center; gap: 1rem; padding: 1.15rem 1.3rem; text-decoration: none; }
        .reach .ic { width: 46px; height: 46px; border-radius: 14px; display: grid; place-items: center; font-size: 1.25rem; flex: none;
                     background: rgba(255,255,255,0.05); border: 1px solid var(--line); transition: transform .3s cubic-bezier(.34,1.56,.64,1); }
        .reach a:hover .ic { transform: scale(1.12) rotate(-6deg); }
        .reach b { display: block; font-size: 0.98rem; }
        .reach span { font-size: 0.84rem; color: var(--muted); word-break: break-all; }

        /* "Follow Bijwala Solutions" card */
        .follow { padding: 1.15rem 1.3rem; }
        .follow .head { display: flex; align-items: center; gap: 1rem; margin-bottom: 0.9rem; }
        .follow .socials { display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.6rem; }
        .follow .socials a {
            display: flex; flex-direction: column; align-items: center; gap: 0.4rem; padding: 0.8rem 0.4rem;
            border-radius: 14px; border: 1px solid var(--line); background: rgba(255,255,255,0.03);
            text-decoration: none; color: var(--ink); font-size: 0.78rem; font-weight: 600; text-align: center;
            transition: transform .25s cubic-bezier(.34,1.56,.64,1), border-color .2s, background .2s;
        }
        .follow .socials a:hover { transform: translateY(-3px); border-color: var(--sc); background: color-mix(in srgb, var(--sc) 12%, transparent); }
        .follow .socials svg { width: 26px; height: 26px; color: var(--sc); }
        .follow .socials .ig { --sc: #e1306c; }
        .follow .socials .fb { --sc: #1877f2; }
        .follow .socials .wc { --sc: var(--wa); }
        .reach .ic.ig-grad { background: linear-gradient(45deg, #feda75, #fa7e1e, #d62976, #962fbf, #4f5bd5); }

        footer { border-top: 1px solid var(--line); padding: 2.25rem 0 calc(6.5rem + env(safe-area-inset-bottom, 0px)); font-size: 0.85rem; color: var(--faint); }
        footer .wrap { display: flex; justify-content: space-between; gap: 1rem; flex-wrap: wrap; }
        footer a { color: var(--muted); }
        footer .social-links { display: flex; gap: 0.5rem; align-items: center; }
        footer .social-links a { width: 34px; height: 34px; border-radius: 10px; display: grid; place-items: center;
                                 border: 1px solid var(--line); color: var(--muted); transition: color .2s, border-color .2s, transform .2s; }
        footer .social-links a:hover { color: var(--ink); border-color: var(--muted); transform: translateY(-2px); }
        footer .social-links svg { width: 17px; height: 17px; }

        .wa-float { position: fixed; right: 1.2rem; bottom: calc(1.2rem + env(safe-area-inset-bottom, 0px)); z-index: 80;
                    width: 60px; height: 60px; border-radius: 50%; background: var(--wa); display: grid; place-items: center; color: #fff;
                    box-shadow: 0 10px 30px rgba(37,211,102,0.45); transition: transform .2s ease; }
        .wa-float::before { content: ''; position: absolute; inset: 0; border-radius: 50%; border: 2px solid var(--wa); animation: ring 2.4s ease-out infinite; }
        @keyframes ring { 0% { transform: scale(1); opacity: 0.8; } 100% { transform: scale(1.7); opacity: 0; } }
        .wa-float:hover { transform: scale(1.08); }
        .wa-float svg { width: 30px; height: 30px; }

        /* ── Client feedback strip ── */
        .fb-head { display: flex; justify-content: space-between; align-items: flex-end; gap: 1.5rem; flex-wrap: wrap; margin-bottom: 2.5rem; }
        .fb-head .lead { margin: 0; }
        .fb-strip { overflow: hidden; padding: 0.5rem 0 1rem;
                    mask-image: linear-gradient(90deg, transparent, #000 6%, #000 94%, transparent);
                    -webkit-mask-image: linear-gradient(90deg, transparent, #000 6%, #000 94%, transparent); }
        .fb-track { display: flex; gap: 1.25rem; width: max-content; padding: 0 1.25rem; }
        .fb-track.looping { animation: fbScroll var(--fb-dur, 40s) linear infinite; }
        .fb-strip:hover .fb-track, .fb-strip:focus-within .fb-track { animation-play-state: paused; }
        @keyframes fbScroll { to { transform: translateX(-50%); } }
        /* Few cards: show each once, centred, no fade mask */
        .fb-strip.static { display: flex; justify-content: center; mask-image: none; -webkit-mask-image: none; overflow-x: auto; }
        .fb-card { width: 340px; flex: none; margin: 0; padding: 1.6rem; display: flex; flex-direction: column; gap: 1.1rem; }
        .fb-card .q { font-family: Georgia, serif; font-size: 3rem; line-height: 0.6; height: 1.4rem; color: var(--brand); opacity: 0.9; }
        .fb-card blockquote { margin: 0; flex: 1; color: #e4e4e7; font-size: 0.95rem; line-height: 1.6; white-space: pre-line; word-break: break-word;
                              display: -webkit-box; -webkit-line-clamp: 6; -webkit-box-orient: vertical; overflow: hidden; }
        .fb-card figcaption { display: flex; align-items: center; gap: 0.75rem; padding-top: 1rem; border-top: 1px solid var(--line); }
        .fb-av { width: 40px; height: 40px; border-radius: 50%; flex: none; display: grid; place-items: center; font-weight: 800; color: #fff;
                 font-family: var(--display); background: var(--grad); }
        .fb-card b { display: block; font-size: 0.92rem; }
        .fb-card small { display: block; font-size: 0.78rem; color: var(--muted); }
        .fb-tag { align-self: flex-start; font-size: 0.68rem; font-weight: 800; letter-spacing: 0.08em; text-transform: uppercase;
                  padding: 0.25rem 0.65rem; border-radius: 999px; background: rgba(255,107,0,0.12); color: var(--brand-2); border: 1px solid rgba(255,107,0,0.25); }
        .fb-card.just-added { border-color: rgba(74,222,128,0.5); box-shadow: 0 0 40px rgba(74,222,128,0.15); }

        .fb-cta { display: flex; align-items: center; gap: 1rem; padding: 1.15rem 1.3rem; width: 100%; text-align: left; cursor: pointer;
                  font: inherit; color: var(--ink); }
        .fb-cta .ic { background: rgba(251,191,36,0.12); }
        .link-btn { background: none; border: none; padding: 0; font: inherit; color: var(--muted); text-decoration: underline; cursor: pointer; }
        .link-btn:hover { color: var(--ink); }

        /* ── Feedback dialog ── */
        dialog.fb-dialog { width: min(520px, calc(100vw - 2rem)); max-height: calc(100dvh - 2rem); padding: 0; border: 1px solid var(--line-2);
                           border-radius: 1.5rem; background: #121215; color: var(--ink); box-shadow: 0 40px 120px rgba(0,0,0,0.7); overflow: auto; }
        dialog.fb-dialog::backdrop { background: rgba(0,0,0,0.65); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px); }
        dialog.fb-dialog[open] { animation: dlgIn .35s cubic-bezier(.2,.8,.2,1); }
        @keyframes dlgIn { from { opacity: 0; transform: translateY(24px) scale(.97); } to { opacity: 1; transform: none; } }
        .dlg-inner { padding: 2rem; position: relative; }
        .dlg-inner h3 { font-size: 1.5rem; margin: 0 0 0.35rem; letter-spacing: -0.02em; }
        .dlg-inner > p { color: var(--muted); margin: 0 0 1.5rem; font-size: 0.92rem; }
        .dlg-close { position: absolute; top: 1rem; right: 1rem; width: 36px; height: 36px; border-radius: 50%; border: 1px solid var(--line-2);
                     background: rgba(255,255,255,0.04); color: var(--muted); font-size: 1rem; cursor: pointer; display: grid; place-items: center; }
        .dlg-close:hover { color: var(--ink); border-color: var(--brand); }
        .dlg-inner form .btn { width: 100%; }
        .char-count { position: absolute; right: 0.8rem; bottom: 0.55rem; font-size: 0.7rem; color: var(--faint); pointer-events: none; }

        /* ── Scroll reveal (only when JS is on, so the page never stays hidden) ── */
        .js .reveal { opacity: 0; transform: translateY(36px); filter: blur(6px);
                      transition: opacity .9s cubic-bezier(.2,.7,.2,1), transform .9s cubic-bezier(.2,.7,.2,1), filter .9s ease; }
        .js .reveal.in { opacity: 1; transform: none; filter: none; }
        /* Hero animates on load (no waiting for the scroll observer) */
        .intro { animation: introUp .8s cubic-bezier(.2,.7,.2,1) both; }
        @keyframes introUp { from { opacity: 0; transform: translateY(28px); filter: blur(6px); } to { opacity: 1; transform: none; filter: none; } }

        @media (max-width: 960px) {
            .hero .wrap, .about, .contact { grid-template-columns: 1fr; }
            .grid-3, .steps { grid-template-columns: 1fr; }
            .steps .rail { display: none; }
            .stats { grid-template-columns: repeat(2, 1fr); }
            .demo { grid-template-columns: 1fr; padding: 2.25rem 1.5rem; text-align: center; }
            .demo .qr-wrap { justify-self: center; }
            nav.links { display: none; }
            section { padding: 4.5rem 0; }
            .hero { padding-top: 7rem; }
            .stage { min-height: 520px; }
            .profile { position: static; }
        }
        @media (max-width: 480px) {
            .two { grid-template-columns: 1fr; gap: 0; }
            .hero .ctas .btn { flex: 1 1 100%; }
            form.enquiry, .profile, .service { padding: 1.6rem; }
            .phone { width: 240px; height: 490px; }
            .chip-1 { left: -4px; } .chip-2 { right: -4px; } .chip-3 { left: 4px; }
            .fb-card { width: 280px; padding: 1.3rem; }
            .dlg-inner { padding: 1.6rem 1.3rem; }
            .float-chip { font-size: 0.72rem; padding: 0.55rem 0.75rem; }
        }
        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after { animation-duration: 0.001ms !important; animation-iteration-count: 1 !important; transition-duration: 0.001ms !important; }
            .js .reveal { opacity: 1; transform: none; filter: none; }
            html { scroll-behavior: auto; }
            .fb-strip { overflow-x: auto; }   /* no auto-scroll: let people swipe through instead */
        }
    </style>
</head>
<body>

<svg width="0" height="0" style="position:absolute" aria-hidden="true">
    <symbol id="i-wa" viewBox="0 0 24 24"><path fill="currentColor" d="M17.47 14.38c-.3-.15-1.75-.86-2.02-.96-.27-.1-.47-.15-.67.15-.2.3-.77.96-.94 1.16-.17.2-.35.22-.64.07-.3-.15-1.26-.46-2.4-1.48-.89-.79-1.49-1.77-1.66-2.07-.17-.3-.02-.46.13-.6.13-.13.3-.35.45-.52.15-.17.2-.3.3-.5.1-.2.05-.37-.03-.52-.07-.15-.67-1.62-.92-2.22-.24-.58-.49-.5-.67-.51h-.57c-.2 0-.52.07-.79.37-.27.3-1.04 1.02-1.04 2.48s1.07 2.88 1.21 3.08c.15.2 2.1 3.2 5.08 4.49.71.31 1.26.49 1.69.63.71.23 1.36.2 1.87.12.57-.09 1.75-.72 2-1.41.25-.69.25-1.29.17-1.41-.07-.12-.27-.2-.57-.35zM12.05 21.5h-.01a9.4 9.4 0 0 1-4.8-1.31l-.34-.2-3.57.94.95-3.48-.22-.36a9.39 9.39 0 0 1-1.44-5.01c0-5.2 4.23-9.43 9.44-9.43a9.38 9.38 0 0 1 9.43 9.44c0 5.2-4.24 9.42-9.44 9.42zm8.03-17.46A11.3 11.3 0 0 0 12.05.7C5.8.7.7 5.79.7 12.05c0 2 .52 3.95 1.52 5.67L.6 23.6l6.03-1.58a11.33 11.33 0 0 0 5.42 1.38h.01c6.25 0 11.35-5.09 11.35-11.35 0-3.03-1.18-5.88-3.33-8.02z"/></symbol>
    <symbol id="i-ig" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="5" fill="none" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="12" r="4.2" fill="none" stroke="currentColor" stroke-width="2"/><circle cx="17.4" cy="6.6" r="1.3" fill="currentColor"/></symbol>
    <symbol id="i-fb" viewBox="0 0 24 24"><path fill="currentColor" d="M24 12a12 12 0 1 0-13.9 11.9v-8.4H7.1V12h3V9.4c0-3 1.8-4.7 4.5-4.7 1.3 0 2.7.2 2.7.2v3h-1.5c-1.5 0-2 .9-2 1.9V12h3.4l-.5 3.5h-2.9v8.4A12 12 0 0 0 24 12z"/></symbol>
    <symbol id="i-channel" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round" d="M4 9.5v5h3.2L13 19V5L7.2 9.5z"/><path fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" d="M16.5 9a4.2 4.2 0 0 1 0 6M19.2 6.4a8 8 0 0 1 0 11.2"/></symbol>
    <symbol id="i-arrow" viewBox="0 0 24 24"><path d="M5 12h14M13 6l6 6-6 6" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
</svg>

<div class="bg-fx" aria-hidden="true"><div class="grid"></div><div class="blob b1"></div><div class="blob b2"></div><div class="blob b3"></div></div>
<div class="progress" id="progress" aria-hidden="true"></div>

<header class="top" id="topbar">
    <div class="wrap">
        <a href="#" class="logo"><span class="logo-mark">BS</span><span><c:out value="${name}"/> · <c:out value="${brand}"/></span></a>
        <nav class="links" id="navLinks">
            <a href="#services">Services</a>
            <a href="#demo">Live demo</a>
            <a href="#about">About</a>
            <a href="#contact">Contact</a>
        </nav>
        <a class="btn btn-wa" href="${waHello}" target="_blank" rel="noopener"><svg><use href="#i-wa"/></svg>WhatsApp</a>
    </div>
</header>

<main>
    <%-- ── Hero ── --%>
    <section class="hero">
        <div class="wrap">
            <div>
                <div class="badge intro"><span class="dot"></span>Available for new projects · <c:out value="${city}"/></div>
                <h1 class="intro" style="animation-delay:.08s">
                    Digital tools that bring <span class="grad-text">more customers</span><br>
                    to your <span class="rotator" id="rotator">restaurant</span>
                </h1>
                <p class="sub intro" style="animation-delay:.16s">I'm <strong style="color:var(--ink)"><c:out value="${name}"/></strong>, a <c:out value="${title}"/>. I build and run simple QR products for local businesses, and custom software when you need something of your own.</p>
                <div class="ctas intro" style="animation-delay:.24s">
                    <a class="btn btn-primary" href="${waHello}" target="_blank" rel="noopener"><span class="shine-sweep"></span><svg><use href="#i-wa"/></svg>Book a free demo</a>
                    <a class="btn btn-ghost" href="#services">Explore services <svg><use href="#i-arrow"/></svg></a>
                </div>
                <ul class="ticks intro" style="animation-delay:.32s">
                    <li>Free demo</li>
                    <li>Works on every phone, no app</li>
                    <li>Local support in Mumbai</li>
                </ul>
            </div>

            <div class="stage intro" style="animation-delay:.2s" aria-hidden="true">
                <div class="phone" id="phone">
                    <div class="notch"></div>
                    <div class="screen">
                        <div class="scr-head">
                            <b>Your Restaurant</b>
                            <div class="cats"><span>Starters</span><span>Mains</span><span>Biryani</span><span>Drinks</span></div>
                        </div>
                        <div class="menu-roll">
                            <%-- Listed twice so the scroll loops seamlessly --%>
                            <c:forEach begin="1" end="2">
                                <div class="dish"><div class="pic" style="background:#fff1e6">&#127831;</div><div><b><i class="veg non"></i>Chicken Tikka</b><small>Smoky, charcoal grilled</small></div><span class="price">&#8377;280</span></div>
                                <div class="dish"><div class="pic" style="background:#fef3c7">&#129368;</div><div><b><i class="veg"></i>Paneer Tikka</b><small>Bestseller</small></div><span class="price">&#8377;240</span></div>
                                <div class="dish"><div class="pic" style="background:#ffe4e6">&#127835;</div><div><b><i class="veg non"></i>Mutton Biryani</b><small>Slow-cooked dum</small></div><span class="price">&#8377;360</span></div>
                                <div class="dish"><div class="pic" style="background:#dcfce7">&#129367;</div><div><b><i class="veg"></i>Garden Salad</b><small>Fresh &amp; light</small></div><span class="price">&#8377;160</span></div>
                                <div class="dish"><div class="pic" style="background:#e0f2fe">&#129380;</div><div><b><i class="veg"></i>Mango Lassi</b><small>Chilled</small></div><span class="price">&#8377;120</span></div>
                                <div class="dish"><div class="pic" style="background:#fae8ff">&#127856;</div><div><b><i class="veg"></i>Gulab Jamun</b><small>Served warm</small></div><span class="price">&#8377;90</span></div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
                <div class="float-chip chip-1"><div class="ic">&#128241;</div><div><b>Menu scanned</b><small>Table 4 · just now</small></div></div>
                <div class="float-chip chip-2"><div class="ic">&#11088;</div><div><b class="stars">&#9733;&#9733;&#9733;&#9733;&#9733;</b><small>Review page opened</small></div></div>
                <div class="float-chip chip-3"><div class="ic">&#128202;</div><div><b>Monthly report</b><small>Sent on WhatsApp</small></div></div>
            </div>
        </div>
    </section>

    <%-- ── Marquee ── --%>
    <div class="marquee" aria-hidden="true">
        <div class="marquee-track">
            <c:forEach begin="1" end="2">
                <span>Digital Menu QR</span><span>Google Review QR</span><span>Java</span><span>Spring Boot</span><span>Custom Web Apps</span>
                <span>PostgreSQL</span><span>Redis</span><span>Admin Dashboards</span><span>REST APIs</span><span>AWS</span>
            </c:forEach>
        </div>
    </div>

    <%-- ── Services ── --%>
    <section id="services">
        <div class="wrap">
            <div class="reveal"><span class="eyebrow">Services</span></div>
            <h2 class="reveal">What I can do for <span class="grad-text">your business</span></h2>
            <p class="lead reveal">Two ready-made products for local businesses, and custom development for everything else.</p>

            <div class="grid-3">
                <article class="service glow-card tilt reveal">
                    <div class="top-row"><div class="icon">&#127869;</div><span class="tag">Product 1</span></div>
                    <h3>Digital Menu QR</h3>
                    <p>Customers scan a QR on the table and your full menu opens on their phone, with photos.</p>
                    <ul>
                        <li>Change prices and dishes anytime, no reprinting</li>
                        <li>Photos, categories and veg / non-veg tags</li>
                        <li>Collect customer names and numbers</li>
                        <li>See your most-viewed dishes and daily scans</li>
                    </ul>
                    <a class="btn btn-ghost" href="#demo">Try the live demo <svg><use href="#i-arrow"/></svg></a>
                </article>

                <article class="service glow-card tilt featured reveal" style="transition-delay:.12s">
                    <div class="top-row"><div class="icon">&#11088;</div><span class="tag">Product 2</span></div>
                    <h3>Google Review QR</h3>
                    <p>A QR sticker on your counter or reception. Customers scan it and land straight on your Google "write a review" box. For restaurants, salons, hotels &amp; more.</p>
                    <ul>
                        <li>One scan opens the review box directly</li>
                        <li>Monthly report: how many customers scanned</li>
                        <li>Your busiest days and times</li>
                        <li>Link can be changed anytime without a new sticker</li>
                    </ul>
                    <a class="btn btn-primary" href="https://wa.me/${phoneE164}?text=Hi%20Amaan%2C%20I%27m%20interested%20in%20the%20Google%20Review%20QR." target="_blank" rel="noopener"><span class="shine-sweep"></span>Ask about Review QR</a>
                </article>

                <article class="service glow-card tilt reveal" style="transition-delay:.24s">
                    <div class="top-row"><div class="icon">&#128187;</div><span class="tag">Custom</span></div>
                    <h3>Custom Software</h3>
                    <p>Need something specific to your business? I design, build and host it.</p>
                    <ul>
                        <li>Business websites and admin dashboards</li>
                        <li>Billing, booking and inventory tools</li>
                        <li>API integrations and automation</li>
                        <li>Hosting, maintenance and support</li>
                    </ul>
                    <a class="btn btn-ghost" href="#contact">Discuss your idea <svg><use href="#i-arrow"/></svg></a>
                </article>
            </div>

            <div class="stats">
                <div class="stat glow-card reveal"><div class="num grad-text" data-count="2022">2022</div><div class="lbl">Writing Java since</div></div>
                <div class="stat glow-card reveal" style="transition-delay:.08s"><div class="num grad-text"><span data-count="2">2</span></div><div class="lbl">Live products</div></div>
                <div class="stat glow-card reveal" style="transition-delay:.16s"><div class="num grad-text">&#8377;<span data-count="0">0</span></div><div class="lbl">Reprinting cost for menu changes</div></div>
                <div class="stat glow-card reveal" style="transition-delay:.24s"><div class="num grad-text">24/7</div><div class="lbl">Menu online, on every phone</div></div>
            </div>
        </div>
    </section>

    <%-- ── Live demo ── --%>
    <section id="demo">
        <div class="wrap">
            <div class="demo glow-card reveal">
                <div>
                    <span class="eyebrow">Live demo</span>
                    <h2>See a real menu <span class="grad-text">running right now</span></h2>
                    <p>This is <strong style="color:#fff"><c:out value="${demoMenuName}"/></strong>'s live digital menu on my platform. Scan the QR with your phone camera, or open it here.</p>
                    <a class="btn btn-primary" href="<c:out value="${demoMenuUrl}"/>" target="_blank" rel="noopener"><span class="shine-sweep"></span>Open the demo menu <svg><use href="#i-arrow"/></svg></a>
                </div>
                <div class="qr-wrap">
                    <div class="qr-box">
                        <span class="corner c1"></span><span class="corner c2"></span><span class="corner c3"></span><span class="corner c4"></span>
                        <img src="${demoQrDataUri}" alt="QR code for the demo menu" width="200" height="200">
                        <span class="scan"></span>
                        <small>Scan with your camera</small>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <%-- ── How it works ── --%>
    <section>
        <div class="wrap">
            <div class="reveal"><span class="eyebrow">How it works</span></div>
            <h2 class="reveal">Live in <span class="grad-text">three simple steps</span></h2>
            <p class="lead reveal">You run your business. I take care of the tech.</p>
            <div class="steps reveal" id="steps">
                <div class="rail"></div>
                <div class="step glow-card"><div class="n">01</div><h3>Free demo</h3><p>I show you how it works on your own phone, at your shop or on a call.</p></div>
                <div class="step glow-card"><div class="n">02</div><h3>I set it up</h3><p>I upload your menu and photos or link your Google page, and give you the QR codes.</p></div>
                <div class="step glow-card"><div class="n">03</div><h3>Go live</h3><p>Place the QR on tables or the counter. I send you a report every month.</p></div>
            </div>
        </div>
    </section>

    <%-- ── Client feedback (hidden until there's at least one real entry) ── --%>
    <section id="feedback" ${empty feedbacks ? 'hidden' : ''}>
        <div class="wrap">
            <div class="fb-head">
                <div>
                    <div class="reveal"><span class="eyebrow">Client feedback</span></div>
                    <h2 class="reveal">What clients <span class="grad-text">say</span></h2>
                    <p class="lead reveal">Real feedback from businesses using my products, published exactly as they wrote it.</p>
                </div>
                <button type="button" class="btn btn-ghost reveal" data-open-feedback>&#9733; Share your feedback</button>
            </div>
        </div>
        <div class="fb-strip reveal" id="fbStrip" tabindex="0" aria-label="Client feedback">
            <div class="fb-track" id="fbTrack">
                <c:forEach var="f" items="${feedbacks}">
                    <figure class="fb-card glow-card">
                        <div class="q" aria-hidden="true">&ldquo;</div>
                        <blockquote><c:out value="${f.comment}"/></blockquote>
                        <span class="fb-tag"><c:out value="${f.productLabel}"/></span>
                        <figcaption>
                            <span class="fb-av" aria-hidden="true"><c:out value="${f.initial}"/></span>
                            <div>
                                <b><c:out value="${f.personName}"/></b>
                                <small><c:out value="${f.shopName}"/><c:if test="${not empty f.location}"> · <c:out value="${f.location}"/></c:if></small>
                            </div>
                        </figcaption>
                    </figure>
                </c:forEach>
            </div>
        </div>
    </section>

    <%-- ── About ── --%>
    <section id="about">
        <div class="wrap about">
            <div class="profile glow-card reveal">
                <div class="avatar-ring"><div class="avatar">AB</div></div>
                <h3><c:out value="${name}"/></h3>
                <div class="role"><c:out value="${title}"/> · <c:out value="${city}"/></div>
                <dl class="facts">
                    <div><dt>Experience</dt><dd>Java developer since 2022</dd></div>
                    <div><dt>Education</dt><dd>B.E., M.H. Saboo Siddik College of Engineering (CGPA 8.83)</dd></div>
                    <div><dt>Languages</dt><dd>English, Hindi, Marathi, Gujarati</dd></div>
                </dl>
                <div class="socials">
                    <a class="btn btn-ghost" href="<c:out value="${github}"/>" target="_blank" rel="noopener">GitHub</a>
                    <a class="btn btn-ghost" href="<c:out value="${linkedin}"/>" target="_blank" rel="noopener">LinkedIn</a>
                </div>
            </div>

            <div class="about-text">
                <div class="reveal"><span class="eyebrow">About me</span></div>
                <h2 class="reveal">Hi, I'm <span class="grad-text">Amaan</span></h2>
                <p class="reveal">I'm a <strong>Java developer</strong> who has been building backend systems since 2022, mostly for <strong>fintech payment platforms</strong>: invoice discounting and cross-border remittance, where every transaction has to be correct.</p>
                <p class="reveal">I bring the same reliability to the products I build for local businesses. I built Menu Scanner and the Review QR end to end, from the database to the QR on your counter, and I run and support them myself.</p>
                <ul class="chips reveal">
                    <li>Java</li><li>Spring Boot</li><li>REST APIs</li><li>PostgreSQL</li><li>Oracle SQL</li>
                    <li>Redis</li><li>Kafka</li><li>JSP / Servlets</li><li>Docker</li><li>AWS</li>
                </ul>
                <div class="projects">
                    <a class="project glow-card reveal" href="https://github.com/AmaanBijwala/spring-ai-project" target="_blank" rel="noopener">
                        <div><b>AI Stock Photo Generator</b><span>Spring Boot + Spring AI with OpenAI image generation</span></div><span class="arrow"><svg width="18" height="18"><use href="#i-arrow"/></svg></span>
                    </a>
                    <a class="project glow-card reveal" href="https://github.com/AmaanBijwala/SpringBoot_E-commerce_Proj" target="_blank" rel="noopener">
                        <div><b>Enterprise eCommerce App</b><span>Spring Boot, React, JWT security, cart, orders and payments</span></div><span class="arrow"><svg width="18" height="18"><use href="#i-arrow"/></svg></span>
                    </a>
                    <a class="project glow-card reveal" href="https://github.com/AmaanBijwala/Invoice-Porcessing-System" target="_blank" rel="noopener">
                        <div><b>Invoice Processing System</b><span>Automated invoice generation and tracking dashboard</span></div><span class="arrow"><svg width="18" height="18"><use href="#i-arrow"/></svg></span>
                    </a>
                </div>
            </div>
        </div>
    </section>

    <%-- ── Contact ── --%>
    <section id="contact">
        <div class="wrap">
            <div class="reveal"><span class="eyebrow">Contact</span></div>
            <h2 class="reveal">Let's talk about <span class="grad-text">your business</span></h2>
            <p class="lead reveal">Send a message and I'll call or WhatsApp you back. Or reach me directly.</p>

            <div class="contact">
                <form class="enquiry glow-card reveal" id="enquiryForm" method="post" action="${ctx}/enquiry" novalidate>
                    <div class="two">
                        <div class="field">
                            <input id="f-name" name="name" required maxlength="100" autocomplete="name" placeholder=" ">
                            <label for="f-name">Your name *</label>
                        </div>
                        <div class="field">
                            <input id="f-phone" name="phone" type="tel" required maxlength="20" autocomplete="tel" inputmode="tel" placeholder=" ">
                            <label for="f-phone">Phone / WhatsApp *</label>
                        </div>
                    </div>
                    <div class="two">
                        <div class="field">
                            <input id="f-biz" name="businessName" maxlength="200" autocomplete="organization" placeholder=" ">
                            <label for="f-biz">Business name</label>
                        </div>
                        <div class="field">
                            <select id="f-interest" name="interest">
                                <option value="MENU_QR">Digital Menu QR</option>
                                <option value="REVIEW_QR">Google Review QR</option>
                                <option value="CUSTOM">Custom software</option>
                                <option value="OTHER">Something else</option>
                            </select>
                            <label for="f-interest">Interested in</label>
                        </div>
                    </div>
                    <div class="field">
                        <textarea id="f-msg" name="message" maxlength="1000" placeholder=" "></textarea>
                        <label for="f-msg">Tell me a little about what you need (optional)</label>
                    </div>
                    <div class="hp" aria-hidden="true"><label>Website <input name="website" tabindex="-1" autocomplete="off"></label></div>
                    <button type="submit" class="btn btn-primary" id="f-submit"><span class="shine-sweep"></span><span id="f-submit-text">Send message</span> <svg><use href="#i-arrow"/></svg></button>
                    <div class="form-msg ${param.sent eq '1' ? 'ok' : (param.error eq '1' ? 'err' : '')}" id="f-msg-box" role="status">
                        <c:if test="${param.sent eq '1'}">Thanks! I'll call or WhatsApp you soon.</c:if>
                        <c:if test="${param.error eq '1'}">Please check your name and phone number and try again.</c:if>
                    </div>
                </form>

                <div class="reach">
                    <a class="glow-card reveal" href="${waHello}" target="_blank" rel="noopener">
                        <div class="ic" style="color:var(--wa);background:rgba(37,211,102,0.12)"><svg width="22" height="22"><use href="#i-wa"/></svg></div>
                        <div><b>WhatsApp</b><span><c:out value="${phoneDisplay}"/></span></div>
                    </a>
                    <a class="glow-card reveal" style="transition-delay:.08s" href="tel:+${phoneE164}">
                        <div class="ic">&#128222;</div>
                        <div><b>Call</b><span><c:out value="${phoneDisplay}"/></span></div>
                    </a>
                    <a class="glow-card reveal" style="transition-delay:.16s" href="mailto:<c:out value="${email}"/>">
                        <div class="ic">&#9993;&#65039;</div>
                        <div><b>Email</b><span><c:out value="${email}"/></span></div>
                    </a>
                    <a class="glow-card reveal" style="transition-delay:.24s" href="${ctx}/contact.vcf">
                        <div class="ic">&#128100;</div>
                        <div><b>Save my contact</b><span>Add me to your phone in one tap</span></div>
                    </a>
                    <div class="follow glow-card reveal" style="transition-delay:.32s">
                        <div class="head">
                            <div class="ic ig-grad" style="color:#fff;border:none"><svg width="22" height="22"><use href="#i-ig"/></svg></div>
                            <div><b>Follow <c:out value="${brand}"/></b><span>Updates, new work and offers</span></div>
                        </div>
                        <div class="socials">
                            <a class="ig" href="<c:out value="${instagram}"/>" target="_blank" rel="noopener"><svg><use href="#i-ig"/></svg>Instagram</a>
                            <a class="fb" href="<c:out value="${facebook}"/>" target="_blank" rel="noopener"><svg><use href="#i-fb"/></svg>Facebook</a>
                            <a class="wc" href="<c:out value="${waChannel}"/>" target="_blank" rel="noopener"><svg><use href="#i-channel"/></svg>WhatsApp Channel</a>
                        </div>
                    </div>
                    <button type="button" class="fb-cta glow-card reveal" style="transition-delay:.4s" data-open-feedback>
                        <div class="ic">&#11088;</div>
                        <div><b>Already a client?</b><span>Share your feedback</span></div>
                    </button>
                </div>
            </div>
        </div>
    </section>
</main>

<footer>
    <div class="wrap">
        <jsp:useBean id="now" class="java.util.Date"/>
        <span>&copy; <fmt:formatDate value="${now}" pattern="yyyy"/> <c:out value="${brand}"/> · <c:out value="${name}"/> · <c:out value="${city}"/></span>
        <nav class="social-links" aria-label="${brand} on social media">
            <a href="<c:out value="${instagram}"/>" target="_blank" rel="noopener" aria-label="Instagram" title="Instagram"><svg><use href="#i-ig"/></svg></a>
            <a href="<c:out value="${facebook}"/>" target="_blank" rel="noopener" aria-label="Facebook" title="Facebook"><svg><use href="#i-fb"/></svg></a>
            <a href="<c:out value="${waChannel}"/>" target="_blank" rel="noopener" aria-label="WhatsApp Channel" title="WhatsApp Channel"><svg><use href="#i-channel"/></svg></a>
        </nav>
        <span><button type="button" class="link-btn" data-open-feedback>Share feedback</button> · <a href="${ctx}/login">Restaurant login</a></span>
    </div>
</footer>

<%-- Feedback dialog --%>
<dialog class="fb-dialog" id="fbDialog" aria-labelledby="fbDialogTitle">
    <div class="dlg-inner">
        <button type="button" class="dlg-close" data-close-feedback aria-label="Close">&#10005;</button>
        <h3 id="fbDialogTitle">Share your <span class="grad-text">feedback</span></h3>
        <p>How has it been working with me? Your feedback is shown on this page exactly as you write it.</p>
        <form id="feedbackForm" method="post" action="${ctx}/feedback" novalidate>
            <div class="two">
                <div class="field">
                    <input id="fb-name" name="personName" required maxlength="100" autocomplete="name" placeholder=" ">
                    <label for="fb-name">Your name *</label>
                </div>
                <div class="field">
                    <input id="fb-shop" name="shopName" required maxlength="200" autocomplete="organization" placeholder=" ">
                    <label for="fb-shop">Shop / business name *</label>
                </div>
            </div>
            <div class="two">
                <div class="field">
                    <input id="fb-loc" name="location" maxlength="120" autocomplete="address-level2" placeholder=" ">
                    <label for="fb-loc">Location (area, city)</label>
                </div>
                <div class="field">
                    <select id="fb-product" name="product" required>
                        <option value="" disabled selected>Select a product</option>
                        <option value="MENU_QR">Digital Menu QR</option>
                        <option value="REVIEW_QR">Google Review QR</option>
                        <option value="CUSTOM">Custom Software</option>
                    </select>
                    <label for="fb-product">Product you bought *</label>
                </div>
            </div>
            <div class="field">
                <textarea id="fb-comment" name="comment" required maxlength="600" placeholder=" " style="min-height:130px"></textarea>
                <label for="fb-comment">Your comments *</label>
                <span class="char-count" id="fbCount">0 / 600</span>
            </div>
            <div class="hp" aria-hidden="true"><label>Website <input name="website" tabindex="-1" autocomplete="off"></label></div>
            <button type="submit" class="btn btn-primary" id="fb-submit"><span class="shine-sweep"></span><span id="fb-submit-text">Post feedback</span></button>
            <div class="form-msg" id="fb-msg-box" role="status"></div>
        </form>
    </div>
</dialog>

<a class="wa-float" href="${waHello}" target="_blank" rel="noopener" aria-label="Chat on WhatsApp"><svg><use href="#i-wa"/></svg></a>

<script>
(function () {
    var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var finePointer  = window.matchMedia('(hover: hover) and (pointer: fine)').matches;

    /* Header background + scroll progress */
    var topbar = document.getElementById('topbar'), progress = document.getElementById('progress');
    function onScroll() {
        var y = window.scrollY, max = document.documentElement.scrollHeight - window.innerHeight;
        topbar.classList.toggle('scrolled', y > 10);
        progress.style.transform = 'scaleX(' + (max > 0 ? y / max : 0) + ')';
    }
    window.addEventListener('scroll', onScroll, { passive: true }); onScroll();

    /* Scroll reveal */
    var revealEls = document.querySelectorAll('.reveal');
    if ('IntersectionObserver' in window && !reduceMotion) {
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) {
                if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); }
            });
        }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
        revealEls.forEach(function (el) { io.observe(el); });
    } else {
        revealEls.forEach(function (el) { el.classList.add('in'); });
    }

    /* Active nav link */
    var navLinks = document.querySelectorAll('#navLinks a');
    if ('IntersectionObserver' in window) {
        var navIo = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) {
                if (!e.isIntersecting) return;
                navLinks.forEach(function (a) { a.classList.toggle('active', a.getAttribute('href') === '#' + e.target.id); });
            });
        }, { rootMargin: '-45% 0px -50% 0px' });
        ['services', 'demo', 'about', 'contact'].forEach(function (id) { var s = document.getElementById(id); if (s) navIo.observe(s); });
    }

    /* Typing rotator in the hero */
    // Keep words no longer than 'restaurant' so the heading never re-wraps and shifts the page
    var words = ['restaurant', 'café', 'salon', 'bakery', 'hotel'];
    var rot = document.getElementById('rotator');
    if (rot && !reduceMotion) {
        var wi = 0, ci = words[0].length, deleting = true;
        setTimeout(function tick() {
            if (deleting) {
                ci--;
                if (ci <= 0) { deleting = false; wi = (wi + 1) % words.length; }
            } else {
                ci++;
            }
            rot.textContent = words[wi].slice(0, Math.max(ci, 0));
            var delay = deleting ? 45 : 90;
            if (!deleting && ci >= words[wi].length) { deleting = true; delay = 2200; }
            setTimeout(tick, delay);
        }, 2200);   // let the first word sit before it starts changing
    }

    /* Count-up numbers */
    var counters = document.querySelectorAll('[data-count]');
    if ('IntersectionObserver' in window && !reduceMotion) {
        var cio = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) {
                if (!e.isIntersecting) return;
                var el = e.target, target = parseInt(el.getAttribute('data-count'), 10);
                var start = target >= 1000 ? target - 30 : 0, t0 = performance.now(), dur = 1400;
                (function step(now) {
                    var p = Math.min((now - t0) / dur, 1), eased = 1 - Math.pow(1 - p, 3);
                    el.textContent = Math.round(start + (target - start) * eased);
                    if (p < 1) requestAnimationFrame(step);
                })(t0);
                cio.unobserve(el);
            });
        }, { threshold: 0.6 });
        counters.forEach(function (el) { cio.observe(el); });
    }

    /* Draw the line between steps */
    var steps = document.getElementById('steps');
    if (steps && 'IntersectionObserver' in window) {
        new IntersectionObserver(function (entries, obs) {
            if (entries[0].isIntersecting) { steps.classList.add('in'); obs.disconnect(); }
        }, { threshold: 0.4 }).observe(steps);
    }

    /* Spotlight that follows the pointer on cards */
    document.querySelectorAll('.glow-card').forEach(function (card) {
        card.addEventListener('pointermove', function (e) {
            var r = card.getBoundingClientRect();
            card.style.setProperty('--mx', (e.clientX - r.left) + 'px');
            card.style.setProperty('--my', (e.clientY - r.top) + 'px');
        });
    });

    /* Subtle 3D tilt (desktop only) */
    if (finePointer && !reduceMotion) {
        document.querySelectorAll('.tilt').forEach(function (card) {
            card.addEventListener('pointermove', function (e) {
                var r = card.getBoundingClientRect();
                var x = (e.clientX - r.left) / r.width - 0.5, y = (e.clientY - r.top) / r.height - 0.5;
                card.style.transform = 'perspective(900px) rotateX(' + (-y * 6) + 'deg) rotateY(' + (x * 6) + 'deg) translateY(-4px)';
            });
            card.addEventListener('pointerleave', function () { card.style.transform = ''; });
        });

        /* Phone follows the mouse a little */
        var phone = document.getElementById('phone'), hero = document.querySelector('.hero');
        hero.addEventListener('pointermove', function (e) {
            var x = e.clientX / window.innerWidth - 0.5, y = e.clientY / window.innerHeight - 0.5;
            phone.style.transform = 'rotateY(' + (-14 + x * 16) + 'deg) rotateX(' + (6 - y * 10) + 'deg)';
        });
        hero.addEventListener('pointerleave', function () { phone.style.transform = ''; });
    }

    /* ── Client feedback: rotating strip ── */
    var fbSection = document.getElementById('feedback');
    var fbTrack   = document.getElementById('fbTrack');

    // Honest display: each feedback appears once. Only when the real cards are wider than the screen
    // does the strip rotate, using exactly one extra copy so translateX(-50%) loops seamlessly.
    // Clones are aria-hidden so screen readers read each card once.
    var fbStrip = document.getElementById('fbStrip');
    function buildFeedbackLoop() {
        fbTrack.querySelectorAll('.fb-clone').forEach(function (c) { c.remove(); });
        fbTrack.classList.remove('looping');
        var originals = Array.prototype.slice.call(fbTrack.children);
        var fits = fbTrack.scrollWidth <= fbStrip.clientWidth;
        fbStrip.classList.toggle('static', fits || reduceMotion);
        if (!originals.length || fits || reduceMotion) return;

        originals.forEach(function (card) { fbTrack.appendChild(makeClone(card)); });
        var px = fbTrack.scrollWidth / 2;                                     // distance of one loop
        fbTrack.style.setProperty('--fb-dur', Math.max(px / 45, 18) + 's');  // ~45px per second
        fbTrack.classList.add('looping');
    }
    function makeClone(card) {
        var c = card.cloneNode(true);
        c.classList.add('fb-clone'); c.classList.remove('just-added');
        c.setAttribute('aria-hidden', 'true');
        return c;
    }
    if (fbTrack.children.length) buildFeedbackLoop();
    var resizeTimer;
    window.addEventListener('resize', function () { clearTimeout(resizeTimer); resizeTimer = setTimeout(buildFeedbackLoop, 300); });

    // Build a card from what the client typed (textContent only — never innerHTML with user text)
    function feedbackCard(data) {
        var fig = document.createElement('figure');
        fig.className = 'fb-card glow-card just-added';
        var q = document.createElement('div'); q.className = 'q'; q.setAttribute('aria-hidden', 'true'); q.textContent = '“';
        var bq = document.createElement('blockquote'); bq.textContent = data.comment;
        var tag = document.createElement('span'); tag.className = 'fb-tag'; tag.textContent = data.productLabel;
        var cap = document.createElement('figcaption');
        var av = document.createElement('span'); av.className = 'fb-av'; av.setAttribute('aria-hidden', 'true');
        av.textContent = data.name.charAt(0).toUpperCase();
        var who = document.createElement('div');
        var b = document.createElement('b'); b.textContent = data.name;
        var sm = document.createElement('small'); sm.textContent = data.shop + (data.location ? ' · ' + data.location : '');
        who.appendChild(b); who.appendChild(sm);
        cap.appendChild(av); cap.appendChild(who);
        fig.appendChild(q); fig.appendChild(bq); fig.appendChild(tag); fig.appendChild(cap);
        fig.addEventListener('pointermove', function (e) {
            var r = fig.getBoundingClientRect();
            fig.style.setProperty('--mx', (e.clientX - r.left) + 'px');
            fig.style.setProperty('--my', (e.clientY - r.top) + 'px');
        });
        return fig;
    }

    /* ── Client feedback: dialog ── */
    var fbDialog = document.getElementById('fbDialog');
    var fbForm   = document.getElementById('feedbackForm');
    var fbBox    = document.getElementById('fb-msg-box');
    var fbBtn    = document.getElementById('fb-submit'), fbBtnText = document.getElementById('fb-submit-text');
    var fbCount  = document.getElementById('fbCount');
    function fbShow(text, ok) { fbBox.textContent = text; fbBox.className = 'form-msg ' + (ok ? 'ok' : 'err'); }

    function openFeedback() {
        fbBox.className = 'form-msg'; fbBox.textContent = '';
        if (typeof fbDialog.showModal === 'function') fbDialog.showModal(); else fbDialog.setAttribute('open', '');
        setTimeout(function () { fbForm.elements['personName'].focus(); }, 60);
    }
    function closeFeedback() { if (fbDialog.open) fbDialog.close(); }

    document.querySelectorAll('[data-open-feedback]').forEach(function (b) { b.addEventListener('click', openFeedback); });
    document.querySelectorAll('[data-close-feedback]').forEach(function (b) { b.addEventListener('click', closeFeedback); });
    fbDialog.addEventListener('click', function (e) { if (e.target === fbDialog) closeFeedback(); });   // backdrop click
    fbForm.elements['comment'].addEventListener('input', function () { fbCount.textContent = this.value.length + ' / 600'; });

    fbForm.addEventListener('submit', function (e) {
        e.preventDefault();
        var els = fbForm.elements;
        var data = {
            name:     els['personName'].value.trim(),
            shop:     els['shopName'].value.trim(),
            location: els['location'].value.trim(),
            product:  els['product'].value,
            productLabel: els['product'].value ? els['product'].options[els['product'].selectedIndex].text : '',
            comment:  els['comment'].value.trim()
        };
        if (!data.name)    { fbShow('Please enter your name.', false); els['personName'].focus(); return; }
        if (!data.shop)    { fbShow('Please enter your shop or business name.', false); els['shopName'].focus(); return; }
        if (!data.product) { fbShow('Please choose the product you bought.', false); els['product'].focus(); return; }
        if (data.comment.length < 5) { fbShow('Please write a little more in your comments.', false); els['comment'].focus(); return; }

        fbBtn.disabled = true; fbBtnText.textContent = 'Posting…';
        fetch(fbForm.action, {
            method: 'POST',
            headers: { 'X-Requested-With': 'fetch', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(fbForm))
        }).then(function (r) {
            return r.text().then(function (t) { return { ok: r.ok, text: t }; });
        }).then(function (res) {
            fbShow(res.text, res.ok);
            if (!res.ok) return;
            // Show it straight away: unhide the section and put the new card first
            fbSection.hidden = false;
            fbTrack.querySelectorAll('.fb-clone').forEach(function (c) { c.remove(); });
            fbTrack.insertBefore(feedbackCard(data), fbTrack.firstChild);
            fbSection.querySelectorAll('.reveal').forEach(function (el) { el.classList.add('in'); });
            buildFeedbackLoop();
            fbForm.reset(); fbCount.textContent = '0 / 600';
            setTimeout(function () {
                closeFeedback();
                fbSection.scrollIntoView({ behavior: reduceMotion ? 'auto' : 'smooth', block: 'start' });
            }, 1400);
        }).catch(function () {
            fbShow('Could not send. Please try again.', false);
        }).finally(function () {
            fbBtn.disabled = false; fbBtnText.textContent = 'Post feedback';
        });
    });

    /* Enquiry form */
    var form = document.getElementById('enquiryForm');
    var box  = document.getElementById('f-msg-box');
    var btn  = document.getElementById('f-submit'), btnText = document.getElementById('f-submit-text');
    function show(text, ok) { box.textContent = text; box.className = 'form-msg ' + (ok ? 'ok' : 'err'); }

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        // form.elements, not form.name — HTMLFormElement.name is the form's own name attribute
        var nameEl = form.elements['name'], phoneEl = form.elements['phone'];
        var name  = nameEl.value.trim();
        var phone = phoneEl.value.replace(/\D/g, '');
        if (!name)             { show('Please enter your name.', false); nameEl.focus(); return; }
        if (phone.length < 10) { show('Please enter a valid phone number.', false); phoneEl.focus(); return; }

        btn.disabled = true; btnText.textContent = 'Sending…';
        fetch(form.action, {
            method: 'POST',
            headers: { 'X-Requested-With': 'fetch', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(form))
        }).then(function (r) {
            return r.text().then(function (t) { return { ok: r.ok, text: t }; });
        }).then(function (res) {
            show(res.text, res.ok);
            if (res.ok) form.reset();
        }).catch(function () {
            show('Could not send. Please WhatsApp me instead.', false);
        }).finally(function () {
            btn.disabled = false; btnText.textContent = 'Send message';
        });
    });
})();
</script>
</body>
</html>
