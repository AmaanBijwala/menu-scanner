<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gallery — Menu Scanner</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=3">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>

<div class="admin-layout">

    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <script>$(function(){ $('#nav-gallery').addClass('active'); });</script>

    <div class="admin-main">

        <div class="mm-hero">
            <h1>Your Visual<br><span>Story.</span></h1>
            <p>Showcase your restaurant's ambience. These photos appear on your public menu page, giving guests a taste of your space before they arrive.</p>
        </div>

        <div class="mm-alerts">
            <c:if test="${param.success eq 'deleted'}"><div class="alert alert-success">Photo removed from your gallery.</div></c:if>
            <c:if test="${param.success eq 'updated'}"><div class="alert alert-success">Caption updated.</div></c:if>
            <div id="galleryMsg" class="alert" style="display:none"></div>
        </div>

        <div class="mm-body">

            <%-- Upload Panel --%>
            <div class="mm-form-panel">
                <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:1rem;margin-bottom:1.5rem">
                    <h2 style="margin-bottom:0">+ Add Ambience Photo</h2>
                    <span class="item-count">
                        <c:out value="${galleryCount}"/> /
                        <c:choose>
                            <c:when test="${maxGalleryImages == 2147483647}">Unlimited</c:when>
                            <c:otherwise><c:out value="${maxGalleryImages}"/></c:otherwise>
                        </c:choose>
                        photos
                    </span>
                </div>

                <c:choose>
                    <c:when test="${canUpload}">
                        <div class="gallery-upload-row">
                            <label class="gallery-drop-zone" for="galleryFile" id="galleryDropZone">
                                <div class="upload-area-icon-lg">&#128247;</div>
                                <p id="galleryFileLabel">Drop photo here or click to browse<br>
                                    <span style="font-size:0.65rem;opacity:0.6">JPEG / PNG &middot; max 5 MB</span>
                                </p>
                                <input type="file" id="galleryFile" accept=".jpg,.jpeg,.png" style="display:none">
                            </label>
                            <div class="gallery-upload-meta">
                                <div class="form-group">
                                    <label>Caption <span class="field-optional">optional</span></label>
                                    <input type="text" id="galleryCaption" maxlength="200"
                                           placeholder="e.g. Our rooftop dining area at sunset">
                                </div>
                                <button class="btn btn-primary btn-full" onclick="uploadGalleryImage()">
                                    Upload Photo
                                </button>
                                <p class="mm-bulk-hint" style="margin-top:0.75rem">
                                    Photos are resized and optimised automatically. They appear in the order uploaded.
                                </p>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-error">
                            Gallery limit reached (<c:out value="${maxGalleryImages}"/> photos).
                            Upgrade to PRO for unlimited gallery photos.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- Gallery Grid --%>
            <div class="mm-collection-panel">
                <div class="mm-collection-header">
                    <h2>Uploaded Photos</h2>
                </div>

                <c:choose>
                    <c:when test="${empty galleryImages}">
                        <p class="empty-state">No photos yet. Upload your first ambience shot above.</p>
                    </c:when>
                    <c:otherwise>
                        <div class="gallery-admin-grid" id="galleryGrid">
                            <c:forEach var="img" items="${galleryImages}">
                                <div class="gallery-admin-card" id="gcard-${img.id}">
                                    <div class="gallery-admin-img-wrap">
                                        <img src="${pageContext.request.contextPath}/images/<c:out value="${img.imagePath}"/>"
                                             alt="<c:out value="${empty img.caption ? 'Gallery photo' : img.caption}"/>"
                                             class="gallery-admin-img" loading="lazy">
                                        <button type="button" class="gallery-admin-edit" title="Edit caption"
                                                onclick="openEditModal(${img.id}, '${fn:escapeXml(img.caption)}')">&#9998;</button>
                                        <form method="post" action="${pageContext.request.contextPath}/gallery"
                                              style="display:inline"
                                              onsubmit="return confirm('Remove this photo from your gallery?')">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${img.id}">
                                            <button type="submit" class="gallery-admin-del" title="Remove photo">&#10005;</button>
                                        </form>
                                    </div>
                                    <p class="gallery-admin-caption" id="gcap-${img.id}">
                                        <c:out value="${empty img.caption ? '' : img.caption}"/>
                                    </p>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

        </div><%-- mm-body --%>
    </div><%-- admin-main --%>
</div><%-- admin-layout --%>

<%-- Edit Caption Modal --%>
<div id="editCaptionModal" class="modal" style="display:none" onclick="if(event.target===this)closeEditModal()">
    <div class="modal-content" style="max-width:440px">
        <button class="modal-close" onclick="closeEditModal()">&#10005;</button>
        <h3>Edit Caption</h3>
        <div class="form-group">
            <label>Caption <span class="field-optional">optional</span></label>
            <input type="text" id="editCaptionInput" maxlength="200" placeholder="Describe this photo…"
                   style="width:100%;box-sizing:border-box">
        </div>
        <div class="modal-actions">
            <button class="btn btn-ghost" onclick="closeEditModal()">Cancel</button>
            <button class="btn btn-primary" id="editCaptionSave" onclick="saveCaption()">Save</button>
        </div>
    </div>
</div>

<script>
$(function () {
    $('#galleryFile').on('change', function () {
        var name = this.files[0] ? this.files[0].name : null;
        $('#galleryFileLabel').html(name
            ? '&#128206; ' + name
            : 'Drop photo here or click to browse<br><span style="font-size:0.65rem;opacity:0.6">JPEG / PNG &middot; max 5 MB</span>');
    });
});

function uploadGalleryImage() {
    var file    = $('#galleryFile')[0].files[0];
    var caption = $('#galleryCaption').val().trim();

    if (!file) { showGalleryMsg('Please choose a photo first.', 'error'); return; }

    var formData = new FormData();
    formData.append('galleryImage', file);
    if (caption) formData.append('caption', caption);

    var $btn = $('button[onclick="uploadGalleryImage()"]');
    $btn.prop('disabled', true).text('Uploading...');

    $.ajax({
        url:         '${pageContext.request.contextPath}/upload-gallery-image',
        type:        'POST',
        data:        formData,
        processData: false,
        contentType: false,
        success: function (data) {
            $btn.prop('disabled', false).text('Upload Photo');
            if (data.error) {
                showGalleryMsg(data.error, 'error');
                return;
            }
            showGalleryMsg('Photo uploaded successfully!', 'success');

            // Prepend new card to grid without page reload
            var imgUrl = '${pageContext.request.contextPath}/images/' + data.path;
            var cap    = data.caption ? esc(data.caption) : '';
            var card = '<div class="gallery-admin-card" id="gcard-' + data.id + '">'
                + '<div class="gallery-admin-img-wrap">'
                + '<img src="' + imgUrl + '" alt="Gallery photo" class="gallery-admin-img" loading="lazy">'
                + '<button type="button" class="gallery-admin-edit" title="Edit caption"'
                + '  onclick="openEditModal(' + data.id + ', \'' + cap + '\')">&#9998;</button>'
                + '<form method="post" action="${pageContext.request.contextPath}/gallery" style="display:inline"'
                + '      onsubmit="return confirm(\'Remove this photo from your gallery?\')">'
                + '<input type="hidden" name="action" value="delete">'
                + '<input type="hidden" name="id" value="' + data.id + '">'
                + '<button type="submit" class="gallery-admin-del" title="Remove photo">&#10005;</button>'
                + '</form>'
                + '</div>'
                + '<p class="gallery-admin-caption" id="gcap-' + data.id + '">' + cap + '</p>'
                + '</div>';

            var $grid = $('#galleryGrid');
            if (!$grid.length) {
                // Grid didn't exist (was showing empty state) — reload to render it properly
                location.reload();
                return;
            }
            $grid.append(card);

            // Reset form
            $('#galleryFile').val('');
            $('#galleryCaption').val('');
            $('#galleryFileLabel').html('Drop photo here or click to browse<br><span style="font-size:0.65rem;opacity:0.6">JPEG / PNG &middot; max 5 MB</span>');
        },
        error: function () {
            $btn.prop('disabled', false).text('Upload Photo');
            showGalleryMsg('Network error. Please try again.', 'error');
        }
    });
}

var _editId = null;

function openEditModal(id, caption) {
    _editId = id;
    $('#editCaptionInput').val(caption || '');
    $('#editCaptionModal').css('display', 'flex');
    setTimeout(function(){ $('#editCaptionInput').focus(); }, 50);
}

function closeEditModal() {
    $('#editCaptionModal').css('display', 'none');
    _editId = null;
}

function saveCaption() {
    if (!_editId) return;
    var caption = $('#editCaptionInput').val().trim();
    var $btn = $('#editCaptionSave');
    $btn.prop('disabled', true).text('Saving…');
    $.post('${pageContext.request.contextPath}/gallery',
        { action: 'updateCaption', id: _editId, caption: caption },
        function(data) {
            $btn.prop('disabled', false).text('Save');
            if (data.error) { showGalleryMsg(data.error, 'error'); return; }
            var $cap = $('#gcap-' + _editId);
            $cap.text(data.caption || '');
            closeEditModal();
            showGalleryMsg('Caption updated.', 'success');
        }, 'json'
    ).fail(function() {
        $btn.prop('disabled', false).text('Save');
        showGalleryMsg('Save failed. Please try again.', 'error');
    });
}

$(document).on('keydown', function(e) {
    if (e.key === 'Escape') closeEditModal();
    if (e.key === 'Enter' && $('#editCaptionModal').is(':visible')) saveCaption();
});

function showGalleryMsg(msg, type) {
    var $el = $('#galleryMsg');
    $el.text(msg).attr('class', 'alert alert-' + type).css('display', 'block');
    clearTimeout($el.data('t'));
    $el.data('t', setTimeout(function () { $el.css('display', 'none'); }, 4000));
}

function esc(str) {
    return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
</script>

<script>const contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
