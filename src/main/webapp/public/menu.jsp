<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${restaurant.name}"/> — Menu</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=6">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body class="public-menu">

<header class="menu-header">
    <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:1rem">
        <div>
            <p style="font-size:0.65rem;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:var(--primary-container);margin-bottom:0.35rem">
                Digital Menu
            </p>
            <h1><c:out value="${restaurant.name}"/></h1>
            <c:if test="${not empty restaurant.socialWhatsapp or not empty restaurant.socialInstagram or not empty restaurant.socialFacebook or not empty restaurant.socialYoutube}">
                <div class="social-links">
                    <c:if test="${not empty restaurant.socialWhatsapp}">
                        <a href="https://wa.me/<c:out value="${restaurant.socialWhatsapp}"/>" target="_blank" rel="noopener" class="social-icon-btn social-wa" aria-label="WhatsApp">
                            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
                        </a>
                    </c:if>
                    <c:if test="${not empty restaurant.socialInstagram}">
                        <a href="https://instagram.com/<c:out value="${restaurant.socialInstagram}"/>" target="_blank" rel="noopener" class="social-icon-btn social-ig" aria-label="Instagram">
                            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z"/></svg>
                        </a>
                    </c:if>
                    <c:if test="${not empty restaurant.socialFacebook}">
                        <a href="https://facebook.com/<c:out value="${restaurant.socialFacebook}"/>" target="_blank" rel="noopener" class="social-icon-btn social-fb" aria-label="Facebook">
                            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>
                        </a>
                    </c:if>
                    <c:if test="${not empty restaurant.socialYoutube}">
                        <a href="https://youtube.com/<c:out value="${restaurant.socialYoutube}"/>" target="_blank" rel="noopener" class="social-icon-btn social-yt" aria-label="YouTube">
                            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M23.495 6.205a3.007 3.007 0 00-2.088-2.088c-1.87-.501-9.396-.501-9.396-.501s-7.507-.01-9.396.501A3.007 3.007 0 00.527 6.205a31.247 31.247 0 00-.522 5.805 31.247 31.247 0 00.522 5.783 3.007 3.007 0 002.088 2.088c1.868.502 9.396.502 9.396.502s7.506 0 9.396-.502a3.007 3.007 0 002.088-2.088 31.247 31.247 0 00.5-5.783 31.247 31.247 0 00-.5-5.805zM9.609 15.601V8.408l6.264 3.602z"/></svg>
                        </a>
                    </c:if>
                </div>
            </c:if>
        </div>
        <button class="btn btn-primary vip-cta" onclick="openOffersModal()">
            <span class="vip-cta-icon" aria-hidden="true">&#11088;</span> Join VIP Club
        </button>
    </div>
</header>

<%-- Public Gallery Strip --%>
<c:if test="${not empty galleryImages}">
<section class="pub-gallery-strip" aria-label="Restaurant photos">
    <div class="pub-gallery-scroll">
        <c:forEach var="img" items="${galleryImages}">
            <button class="pub-gallery-thumb" onclick="openLightbox('${pageContext.request.contextPath}/images/<c:out value="${img.imagePath}"/>', '<c:out value="${fn:escapeXml(img.caption)}"/>')" aria-label="<c:out value="${empty img.caption ? 'Restaurant photo' : img.caption}"/>">
                <img src="${pageContext.request.contextPath}/images/<c:out value="${img.imagePath}"/>"
                     alt="<c:out value="${empty img.caption ? 'Restaurant photo' : img.caption}"/>"
                     loading="lazy">
                <c:if test="${not empty img.caption}">
                    <span class="pub-gallery-thumb-cap"><c:out value="${img.caption}"/></span>
                </c:if>
            </button>
        </c:forEach>
    </div>
</section>

<%-- Lightbox --%>
<div id="pubLightbox" class="pub-lightbox" style="display:none" onclick="closeLightbox()">
    <button class="pub-lightbox-close" onclick="closeLightbox()" aria-label="Close">&#10005;</button>
    <img id="pubLightboxImg" src="" alt="" onclick="event.stopPropagation()">
    <p id="pubLightboxCap" class="pub-lightbox-cap"></p>
</div>
</c:if>

<%-- Sticky search + category navigation (built from the sections below by script) --%>
<c:if test="${not empty menuItems}">
<div class="mt-bar" id="menuTools">
    <div class="mt-row">
        <label class="mt-search">
            <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7" fill="none" stroke="currentColor" stroke-width="2"/><path d="M20 20l-4-4" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
            <input type="search" id="mtSearch" placeholder="Search dishes, e.g. fried rice" autocomplete="off" enterkeyhint="search" aria-label="Search the menu">
            <button type="button" id="mtClear" class="mt-clear" aria-label="Clear search" hidden>&#10005;</button>
        </label>
        <button type="button" id="mtVeg" class="mt-veg" aria-pressed="false" title="Show veg items only">
            <span class="veg-indicator veg"></span>Veg
        </button>
        <button type="button" id="mtMenuBtn" class="mt-menu-btn" aria-label="All categories" aria-haspopup="dialog">
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 7h16M4 12h16M4 17h16" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
        </button>
    </div>
    <nav class="mt-chips" id="mtChips" aria-label="Menu categories"></nav>
</div>

<div id="mtSheet" class="mt-sheet" hidden>
    <div class="mt-sheet-box" role="dialog" aria-modal="true" aria-labelledby="mtSheetTitle">
        <div class="mt-sheet-head">
            <h3 id="mtSheetTitle">Menu</h3>
            <button type="button" class="mt-sheet-close" id="mtSheetClose" aria-label="Close">&#10005;</button>
        </div>
        <ul id="mtSheetList"></ul>
    </div>
</div>
</c:if>

<main class="menu-container">
    <c:choose>
        <c:when test="${empty menuItems}">
            <p class="empty-state" style="margin-top:3rem">Menu coming soon!</p>
        </c:when>
        <c:otherwise>
            <c:set var="currentCategory" value=""/>
            <c:set var="sectionOpen" value="${false}"/>
            <c:forEach var="item" items="${menuItems}">
                <c:if test="${item.available}">
                    <c:if test="${item.category != currentCategory or not sectionOpen}">
                        <c:if test="${sectionOpen}"></section></c:if>
                        <c:set var="currentCategory" value="${item.category}"/>
                        <c:set var="sectionOpen" value="${true}"/>
                        <section class="menu-cat">
                        <h2 class="category-heading"><c:out value="${empty item.category ? 'Our Menu' : item.category}"/></h2>
                    </c:if>

                    <div class="menu-card menu-card-clickable"
                         onclick="openItemModal(this)"
                         data-name="<c:out value="${fn:escapeXml(item.name)}"/>"
                         data-desc="<c:out value="${fn:escapeXml(item.description)}"/>"
                         data-price="${item.price}"
                         data-final="${item.finalPrice}"
                         data-disc="${item.discountPercent}"
                         data-img="${not empty item.imagePath ? pageContext.request.contextPath.concat('/images/').concat(item.imagePath) : ''}"
                         data-veg="${item.veg}"
                         data-cat="<c:out value="${fn:escapeXml(item.category)}"/>">
                        <c:if test="${not empty item.imagePath}">
                            <img src="${pageContext.request.contextPath}/images/<c:out value="${item.imagePath}"/>"
                                 alt="<c:out value="${item.name}"/>" class="menu-item-img" loading="lazy">
                        </c:if>
                        <div class="menu-item-body">
                            <div class="menu-item-header">
                                <div style="display:flex;align-items:center;gap:0.5rem;flex:1;min-width:0">
                                    <span class="veg-indicator ${item.veg ? 'veg' : 'nonveg'}"></span>
                                    <h3><c:out value="${item.name}"/></h3>
                                </div>
                                <div class="price-block">
                                    <c:choose>
                                        <c:when test="${item.hasDiscount()}">
                                            <span class="price">&#8377;<fmt:formatNumber value="${item.finalPrice}" pattern="#,##0"/></span>
                                            <span class="price-was">&#8377;<fmt:formatNumber value="${item.price}" pattern="#,##0"/></span>
                                            <span class="price-save">${item.discountPercent}% off</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="price">&#8377;<fmt:formatNumber value="${item.price}" pattern="#,##0"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <c:if test="${not empty item.description}">
                                <p class="item-desc"><c:out value="${item.description}"/></p>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </c:forEach>
            <c:if test="${sectionOpen}"></section></c:if>
            <div id="mtEmpty" class="mt-empty" hidden>
                <p>No dishes match <b id="mtEmptyQ"></b></p>
                <button type="button" class="btn btn-secondary" id="mtReset">Show full menu</button>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<%-- Lead Capture Modal --%>
<div id="offersModal" class="modal" style="display:none" role="dialog" aria-modal="true">
    <div class="modal-content">
        <button class="modal-close" onclick="closeOffersModal()" aria-label="Close">✕</button>
        <h3>Join our VIP Club &#11088;</h3>
        <p style="color:var(--on-surface-muted);font-size:0.875rem;margin-bottom:1.5rem">
            Get exclusive deals from <c:out value="${restaurant.name}"/> straight on WhatsApp!
        </p>
        <div id="offerFormMsg" class="alert" style="display:none"></div>
        <form id="leadForm" method="post" action="${pageContext.request.contextPath}/lead-capture" onsubmit="submitLead(event)">
            <input type="hidden" name="slug" id="leadSlug" value="<c:out value="${restaurant.slug}"/>">
            <div class="form-group">
                <label>Name *</label>
                <input type="text" name="name" required maxlength="100" placeholder="Your name">
            </div>
            <div class="form-group">
                <label>Phone *</label>
                <input type="tel" name="phone" required maxlength="15" inputmode="numeric" autocomplete="tel" placeholder="10-digit mobile number">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Age</label>
                    <input type="number" name="age" min="1" max="120" placeholder="Optional">
                </div>
                <div class="form-group">
                    <label>Gender</label>
                    <select name="gender">
                        <option value="">Prefer not to say</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
            </div>
            <label class="checkbox-label">
                <input type="checkbox" name="consentWhatsapp" value="true" checked>
                I agree to receive offers on WhatsApp
            </label>
            <button type="submit" class="btn btn-primary btn-full">Join VIP Club</button>
        </form>
    </div>
</div>

<%-- ─── Menu Item Detail Modal ─────────────────────────────────────────────── --%>
<div id="itemModal" class="im-overlay" onclick="closeItemModal()">
    <div class="im-box" onclick="event.stopPropagation()" role="dialog" aria-modal="true">
        <button class="im-close" onclick="closeItemModal()" aria-label="Close">&#10005;</button>

        <div class="im-img-wrap" id="imImgWrap">
            <img id="imImg" src="" alt="">
            <span id="imVegDot" class="veg-indicator im-veg-dot"></span>
        </div>

        <div class="im-body">
            <div class="im-meta">
                <span id="imVegInline" class="veg-indicator"></span>
                <span id="imCat" class="im-cat"></span>
            </div>
            <h2 id="imName" class="im-name"></h2>
            <div id="imPrice" class="im-price-block"></div>
            <p  id="imDesc" class="im-desc"></p>
        </div>
    </div>
</div>

<script>
const contextPath = '${pageContext.request.contextPath}';
function openLightbox(src, cap) {
    document.getElementById('pubLightboxImg').src = src;
    document.getElementById('pubLightboxCap').textContent = cap || '';
    document.getElementById('pubLightbox').style.display = 'flex';
    document.body.style.overflow = 'hidden';
}
function closeLightbox() {
    document.getElementById('pubLightbox').style.display = 'none';
    document.body.style.overflow = '';
}
document.addEventListener('keydown', function(e){
    if(e.key==='Escape'){ closeLightbox(); closeItemModal(); closeOffersModal(); }
});

function fmt(n) {
    return '₹' + Number(n).toLocaleString('en-IN', {maximumFractionDigits:0});
}

function openItemModal(card) {
    var d = card.dataset;
    var hasImg = d.img && d.img.length > 0;

    // Image
    var imgWrap = document.getElementById('imImgWrap');
    var imgEl   = document.getElementById('imImg');
    if (hasImg) {
        imgEl.src = d.img;
        imgEl.alt = d.name;
        imgWrap.style.display = 'block';
    } else {
        imgWrap.style.display = 'none';
    }

    // Veg indicator
    var isVeg = d.veg === 'true';
    document.getElementById('imVegDot').className   = 'veg-indicator im-veg-dot ' + (isVeg ? 'veg' : 'nonveg');
    document.getElementById('imVegInline').className = 'veg-indicator ' + (isVeg ? 'veg' : 'nonveg');

    // Category
    var catEl = document.getElementById('imCat');
    catEl.textContent = d.cat || '';
    catEl.style.display = d.cat ? 'inline-block' : 'none';

    // Name
    document.getElementById('imName').textContent = d.name;

    // Price
    var disc = parseFloat(d.disc) || 0;
    var priceHtml;
    if (disc > 0) {
        priceHtml = '<span class="im-price-final">' + fmt(d.final) + '</span>'
                  + '<span class="im-price-was">' + fmt(d.price) + '</span>'
                  + '<span class="im-price-badge">' + Math.round(disc) + '% off</span>';
    } else {
        priceHtml = '<span class="im-price-final">' + fmt(d.price) + '</span>';
    }
    document.getElementById('imPrice').innerHTML = priceHtml;

    // Description
    var descEl = document.getElementById('imDesc');
    descEl.textContent = d.desc || '';
    descEl.style.display = d.desc ? 'block' : 'none';

    // Show with animation
    var overlay = document.getElementById('itemModal');
    overlay.style.display = 'flex';
    requestAnimationFrame(function() {
        requestAnimationFrame(function() { overlay.classList.add('open'); });
    });
    document.body.style.overflow = 'hidden';
}

function closeItemModal() {
    var overlay = document.getElementById('itemModal');
    overlay.classList.remove('open');
    setTimeout(function() { overlay.style.display = 'none'; }, 320);
    document.body.style.overflow = '';
}
</script>
<script src="${pageContext.request.contextPath}/js/app.js?v=3"></script>
<script>
(function() {
    var ids = [<c:forEach items="${menuItems}" var="i" varStatus="s">${i.id}<c:if test="${!s.last}">,</c:if></c:forEach>];
    if (!ids.length) return;
    // URLSearchParams posts as application/x-www-form-urlencoded, which getParameter() reads;
    // FormData would post multipart and the servlet would see no parameters (400).
    var body = new URLSearchParams();
    body.append('slug', '<c:out value="${restaurant.slug}"/>');
    body.append('ids', ids.join(','));
    fetch(contextPath + '/track-items', { method: 'POST', body: body, keepalive: true });
})();
</script>
<script>
// Sticky search, veg filter and category navigation for long menus
(function() {
    var bar = document.getElementById('menuTools');
    if (!bar) return;
    var input   = document.getElementById('mtSearch');
    var clearBt = document.getElementById('mtClear');
    var vegBt   = document.getElementById('mtVeg');
    var chipNav = document.getElementById('mtChips');
    var sheet   = document.getElementById('mtSheet');
    var list    = document.getElementById('mtSheetList');
    var empty   = document.getElementById('mtEmpty');
    var main    = document.querySelector('.menu-container');

    var sections = Array.prototype.map.call(document.querySelectorAll('.menu-cat'), function(sec, i) {
        sec.id = 'cat-' + i;
        var cards = Array.prototype.map.call(sec.querySelectorAll('.menu-card'), function(card) {
            var d = card.dataset;
            return { el: card, veg: d.veg === 'true',
                     text: norm([d.name, d.desc, d.cat].join(' ')) };
        });
        var chip = document.createElement('button');
        chip.type = 'button';
        chip.className = 'mt-chip';
        chip.textContent = sec.querySelector('.category-heading').textContent;
        chip.addEventListener('click', function() { jumpTo(i); });
        chipNav.appendChild(chip);
        return { el: sec, name: chip.textContent, cards: cards, chip: chip, visible: cards.length };
    });

    function norm(s) { return (s || '').toLowerCase().replace(/[^a-z0-9ऀ-ॿ]+/g, ' '); }

    var vegOnly = false;
    function apply() {
        var words = norm(input.value).split(' ').filter(Boolean);
        var total = 0;
        sections.forEach(function(s) {
            var n = 0;
            s.cards.forEach(function(c) {
                var show = (!vegOnly || c.veg) && words.every(function(w) { return c.text.indexOf(w) !== -1; });
                c.el.hidden = !show;
                if (show) n++;
            });
            s.visible = n;
            s.el.hidden = n === 0;
            s.chip.hidden = n === 0;
            total += n;
        });
        clearBt.hidden = !input.value;
        empty.hidden = total > 0;
        document.getElementById('mtEmptyQ').textContent =
            (input.value.trim() ? '"' + input.value.trim() + '"' : '') + (vegOnly ? ' (veg only)' : '');
        // Chips moved around, so re-center the active one even if it is still the same category
        if (active !== -1) sections[active].chip.classList.remove('active');
        active = -1;
        updateActive();
    }

    // Keep results in view: when filtering from far down the page, go back to the top of the menu
    function toMenuTop() {
        var top = main.getBoundingClientRect().top + window.scrollY - bar.offsetHeight;
        if (window.scrollY > top) window.scrollTo(0, top);
    }

    input.addEventListener('input', function() { apply(); toMenuTop(); });
    input.addEventListener('keydown', function(e) { if (e.key === 'Enter') input.blur(); });
    clearBt.addEventListener('click', function() { input.value = ''; apply(); input.focus(); });
    vegBt.addEventListener('click', function() {
        vegOnly = !vegOnly;
        vegBt.setAttribute('aria-pressed', vegOnly);
        apply(); toMenuTop();
    });
    document.getElementById('mtReset').addEventListener('click', function() {
        input.value = ''; vegOnly = false; vegBt.setAttribute('aria-pressed', 'false'); apply();
    });

    function jumpTo(i) {
        var top = sections[i].el.getBoundingClientRect().top + window.scrollY - bar.offsetHeight - 8;
        window.scrollTo({ top: top, behavior: 'smooth' });
    }

    // Highlight the category currently under the bar, and keep its chip in view
    var active = -1;
    function updateActive() {
        var line = bar.getBoundingClientRect().bottom + 24, cur = -1;
        sections.forEach(function(s, i) {
            if (!s.el.hidden && s.el.getBoundingClientRect().top <= line) cur = i;
        });
        if (cur === -1) sections.some(function(s, i) { if (!s.el.hidden) { cur = i; return true; } });
        if (cur === active) return;
        if (active !== -1) sections[active].chip.classList.remove('active');
        active = cur;
        if (cur === -1) return;
        var chip = sections[cur].chip;
        chip.classList.add('active');
        chipNav.scrollTo({ left: chip.offsetLeft - (chipNav.clientWidth - chip.offsetWidth) / 2, behavior: 'smooth' });
    }
    var ticking = false;
    window.addEventListener('scroll', function() {
        if (ticking) return;
        ticking = true;
        requestAnimationFrame(function() { ticking = false; updateActive(); });
    }, { passive: true });

    // Full category list (☰)
    function openSheet() {
        list.innerHTML = '';
        sections.forEach(function(s, i) {
            if (s.el.hidden) return;
            var li = document.createElement('li');
            var b = document.createElement('button');
            b.type = 'button';
            if (i === active) b.className = 'active';
            var name = document.createElement('span');
            name.textContent = s.name;
            var count = document.createElement('span');
            count.className = 'mt-count';
            count.textContent = s.visible;
            b.appendChild(name); b.appendChild(count);
            b.addEventListener('click', function() { closeSheet(); jumpTo(i); });
            li.appendChild(b);
            list.appendChild(li);
        });
        sheet.hidden = false;
        requestAnimationFrame(function() { sheet.classList.add('open'); });
        document.body.style.overflow = 'hidden';
    }
    function closeSheet() {
        sheet.classList.remove('open');
        sheet.hidden = true;
        document.body.style.overflow = '';
    }
    document.getElementById('mtMenuBtn').addEventListener('click', openSheet);
    document.getElementById('mtSheetClose').addEventListener('click', closeSheet);
    sheet.addEventListener('click', function(e) { if (e.target === sheet) closeSheet(); });
    document.addEventListener('keydown', function(e) { if (e.key === 'Escape' && !sheet.hidden) closeSheet(); });

    apply();
})();
</script>
</body>
</html>
