/* ─── Menu Manager: Edit Modal ───────────────────────────────────────────── */

function openEdit(id, name, category, price, discountAmount, isVeg, isAvailable, displayOrder, imagePath) {
    $('#editId').val(id);
    $('#editName').val(name);
    $('#editCategory').val(category);
    $('#editPrice').val(price);
    $('#editDiscount').val(discountAmount > 0 ? discountAmount : '');
    $('#editVeg').prop('checked', isVeg);
    $('#editAvailable').prop('checked', isAvailable);
    $('#editOrder').val(displayOrder);
    $('#editImagePath').val(imagePath || '');
    calcFinal('edit');
    $('#editModal').css('display', 'flex');
}

function calcFinal(prefix) {
    const priceId  = prefix === 'edit' ? 'editPrice' : 'addActualPrice';
    const actual   = parseFloat($('#' + priceId).val()) || 0;
    const discount = parseFloat($('#' + prefix + 'Discount').val()) || 0;
    const $el      = $('#' + prefix + 'FinalPrice');
    if ($el.length) $el.val(discount > 0 ? Math.max(0, actual - discount).toFixed(2) : '');
}

// Close modal when clicking the backdrop
$(function () {
    const $modal = $('#editModal');
    if ($modal.length) {
        $modal.on('click', function (e) {
            if (e.target === this) $modal.css('display', 'none');
        });
    }
});

/* ─── Menu Manager: Image Upload ─────────────────────────────────────────── */

function showToast(message, type) {
    let $toast = $('#uploadToast');
    if (!$toast.length) {
        $toast = $('<div id="uploadToast"></div>').appendTo('body');
    }
    $toast.text(message)
          .attr('class', 'upload-toast upload-toast-' + type + ' upload-toast-show');
    clearTimeout($toast.data('timer'));
    $toast.data('timer', setTimeout(() => $toast.removeClass('upload-toast-show'), 3000));
}

function uploadImage() {
    const itemId = $('#uploadItemId').val();
    const file   = $('#imageFile')[0].files[0];

    if (!itemId) { showToast('Please select an item first.', 'error'); return; }
    if (!file)   { showToast('Please choose an image file.', 'error'); return; }

    const formData = new FormData();
    formData.append('image',  file);
    formData.append('itemId', itemId);

    $.ajax({
        url:         contextPath + '/upload-image',
        type:        'POST',
        data:        formData,
        processData: false,
        contentType: false,
        success: function (data) {
            if (data.path) {
                showToast('Image updated successfully!', 'success');

                // Live update: find the card for this item and swap its image
                const imgUrl = contextPath + '/images/' + data.path;
                $('.collection-card').each(function () {
                    const $editBtn = $(this).find('[onclick]');
                    if ($editBtn.length && $editBtn.attr('onclick').startsWith('openEdit(' + itemId + ',')) {
                        const $wrap = $(this).find('.collection-card-img-wrap');
                        if ($wrap.length) {
                            let $img = $wrap.find('img.collection-card-img');
                            if (!$img.length) {
                                $wrap.find('.collection-card-no-img').remove();
                                $img = $('<img class="collection-card-img" alt="">').prependTo($wrap);
                            }
                            $img.attr('src', imgUrl + '?t=' + Date.now());
                        }
                    }
                });

                // Reset upload zone
                $('#uploadItemId').val('');
                $('#imageFile').val('');
                $('#uploadLabelText').html('Upload Visual Identity<br><span style="font-size:0.65rem;opacity:0.6">JPEG / PNG · max 5 MB</span>');
            } else {
                showToast('Error: ' + (data.error || 'Unknown error'), 'error');
            }
        },
        error: function () {
            showToast('Network error. Please try again.', 'error');
        }
    });
}

/* ─── Menu Manager: Bulk Upload ──────────────────────────────────────────── */

function toggleBulk() {
    const $body    = $('#bulkBody');
    const $chevron = $('#bulkChevron');
    const open     = $body.css('display') === 'none';
    $body.css('display', open ? 'block' : 'none');
    $chevron.css('transform', open ? 'rotate(180deg)' : '');
}

$(function () {
    $('#bulkFile').on('change', function () {
        $('#bulkFileLabel').text(this.files[0] ? this.files[0].name : 'Choose .xlsx or .csv');
    });
});

function bulkUpload() {
    const $input = $('#bulkFile');
    if (!$input.length || !$input[0].files[0]) { showToast('Please choose a file first.', 'error'); return; }

    const formData = new FormData();
    formData.append('bulkFile', $input[0].files[0]);

    const $resultEl = $('#bulkResult');
    $resultEl.html('<p style="color:var(--on-surface-muted);font-size:0.8rem;margin-top:0.75rem">Uploading...</p>');

    $.ajax({
        url:         contextPath + '/bulk-upload',
        type:        'POST',
        data:        formData,
        processData: false,
        contentType: false,
        success: function (data) {
            if (data.error) {
                $resultEl.html('<div class="bulk-result-error">' + esc(data.error) + '</div>');
                return;
            }
            if (data.errors && data.errors.length > 0) {
                let html = '<div class="bulk-error-table-wrap">'
                    + '<p class="bulk-error-title">&#9888; ' + data.errors.length + ' error(s) found — nothing was saved. Fix the sheet and re-upload.</p>'
                    + '<table class="bulk-error-table"><thead><tr><th>Row</th><th>Column</th><th>Issue</th></tr></thead><tbody>';
                $.each(data.errors, function (i, e) {
                    html += '<tr><td>' + e.row + '</td><td>' + esc(e.col) + '</td><td>' + esc(e.msg) + '</td></tr>';
                });
                html += '</tbody></table></div>';
                $resultEl.html(html);
                return;
            }
            $resultEl.html('');
            showToast(data.inserted + ' item(s) added successfully!', 'success');
            $input.val('');
            $('#bulkFileLabel').text('Choose .xlsx or .csv');
            setTimeout(() => location.reload(), 1500);
        },
        error: function () {
            $resultEl.html('<div class="bulk-result-error">Network error. Please try again.</div>');
        }
    });
}

function esc(str) {
    return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* ─── Public Menu: Offers Modal ──────────────────────────────────────────── */

function openOffersModal() {
    $('#offersModal').css('display', 'flex');
}

function closeOffersModal() {
    $('#offersModal').css('display', 'none');
}

$(function () {
    $('#offersModal').on('click', function (e) {
        if (e.target === this) closeOffersModal();
    });
});

/* ─── Public Menu: Lead Capture Submit ───────────────────────────────────── */

function submitLead(event) {
    event.preventDefault();
    const $form   = $('#leadForm');
    const $msgBox = $('#offerFormMsg');

    const formData = $form.serialize();
    const urlSlug  = new URLSearchParams(window.location.search).get('slug') || '';

    // Build data object; add slug from URL if hidden field is empty
    const data = $form.serializeArray();
    const slugField = data.find(f => f.name === 'slug');
    if (urlSlug && (!slugField || !slugField.value)) {
        data.push({ name: 'slug', value: urlSlug });
    }

    $.ajax({
        url:  contextPath + '/lead-capture',
        type: 'POST',
        data: data,
        success: function (res) {
            if (res.success) {
                $msgBox.text("You're subscribed! Watch for exclusive offers.")
                       .attr('class', 'alert alert-success')
                       .css('display', 'block');
                $form.css('display', 'none');
            } else {
                $msgBox.text(res.error || 'Something went wrong. Please try again.')
                       .attr('class', 'alert alert-error')
                       .css('display', 'block');
            }
        },
        error: function () {
            $msgBox.text('Network error. Please try again.')
                   .attr('class', 'alert alert-error')
                   .css('display', 'block');
        }
    });
}

/* ─── Context path fallback ──────────────────────────────────────────────── */
if (typeof contextPath === 'undefined') {
    var contextPath = '';
}
