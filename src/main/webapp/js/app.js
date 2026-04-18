/* ─── Menu Manager: Edit Modal ───────────────────────────────────────────── */

function openEdit(id, name, category, price, isVeg, isAvailable, displayOrder) {
    document.getElementById('editId').value        = id;
    document.getElementById('editName').value      = name;
    document.getElementById('editCategory').value  = category;
    document.getElementById('editPrice').value     = price;
    document.getElementById('editVeg').checked     = isVeg;
    document.getElementById('editAvailable').checked = isAvailable;
    document.getElementById('editOrder').value     = displayOrder;
    document.getElementById('editModal').style.display = 'flex';
}

// Close modal when clicking the backdrop
document.addEventListener('DOMContentLoaded', function () {
    const modal = document.getElementById('editModal');
    if (modal) {
        modal.addEventListener('click', function (e) {
            if (e.target === modal) modal.style.display = 'none';
        });
    }
});

/* ─── Menu Manager: Image Upload ─────────────────────────────────────────── */

async function uploadImage() {
    const itemId = document.getElementById('uploadItemId').value;
    const file   = document.getElementById('imageFile').files[0];
    const result = document.getElementById('uploadResult');

    if (!itemId || !file) {
        result.textContent = 'Please enter an item ID and select a file.';
        result.className   = 'alert alert-error';
        result.style.display = 'block';
        return;
    }

    const formData = new FormData();
    formData.append('image',  file);
    formData.append('itemId', itemId);

    try {
        const resp = await fetch(contextPath + '/upload-image', {
            method: 'POST',
            body:   formData
        });
        const data = await resp.json();

        if (data.path) {
            result.textContent   = 'Upload successful! Path: ' + data.path;
            result.className     = 'alert alert-success';
        } else {
            result.textContent   = 'Error: ' + (data.error || 'Unknown error');
            result.className     = 'alert alert-error';
        }
        result.style.display = 'block';
    } catch (err) {
        result.textContent   = 'Network error. Please try again.';
        result.className     = 'alert alert-error';
        result.style.display = 'block';
    }
}

/* ─── Public Menu: Offers Modal ──────────────────────────────────────────── */

function openOffersModal() {
    document.getElementById('offersModal').style.display = 'flex';
}

function closeOffersModal() {
    document.getElementById('offersModal').style.display = 'none';
}

// Close modal on backdrop click
document.addEventListener('DOMContentLoaded', function () {
    const modal = document.getElementById('offersModal');
    if (modal) {
        modal.addEventListener('click', function (e) {
            if (e.target === modal) closeOffersModal();
        });
    }
});

/* ─── Public Menu: Lead Capture Submit ───────────────────────────────────── */

async function submitLead(event) {
    event.preventDefault();
    const form    = document.getElementById('leadForm');
    const msgBox  = document.getElementById('offerFormMsg');
    const formData = new FormData(form);

    try {
        const resp = await fetch(contextPath + '/lead-capture', {
            method: 'POST',
            body:   formData
        });
        const data = await resp.json();

        if (data.success) {
            msgBox.textContent     = 'You\'re subscribed! Watch for exclusive offers.';
            msgBox.className       = 'alert alert-success';
            form.style.display     = 'none';
        } else {
            msgBox.textContent     = data.error || 'Something went wrong. Please try again.';
            msgBox.className       = 'alert alert-error';
        }
        msgBox.style.display = 'block';
    } catch (err) {
        msgBox.textContent   = 'Network error. Please try again.';
        msgBox.className     = 'alert alert-error';
        msgBox.style.display = 'block';
    }
}

/* ─── Context path (set in JSP via <script> tag before this file loads) ──── */
// Usage in JSPs: <script>const contextPath = '${pageContext.request.contextPath}';</script>
// Fallback for pages that forget to set it:
if (typeof contextPath === 'undefined') {
    const contextPath = '';
}
