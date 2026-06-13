// ============================================================
//  assets/js/app.js  –  EduPlatform Shared JavaScript
// ============================================================

// ── Flash message auto-dismiss ────────────────────────────
document.querySelectorAll('.alert').forEach(el => {
    setTimeout(() => {
        el.style.transition = 'opacity .5s';
        el.style.opacity = '0';
        setTimeout(() => el.remove(), 500);
    }, 4000);
});

// ── Active sidebar link highlighting ─────────────────────
document.querySelectorAll('.sidebar-nav a').forEach(link => {
    if (link.href === window.location.href) {
        link.classList.add('active');
    }
});

// ── Confirm before destructive actions ───────────────────
document.querySelectorAll('[data-confirm]').forEach(el => {
    el.addEventListener('click', e => {
        if (!confirm(el.dataset.confirm)) e.preventDefault();
    });
});

// ── Tab switching ─────────────────────────────────────────
function initTabs() {
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const group = btn.closest('.tab-group');
            const target = btn.dataset.tab;
            group.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            group.querySelectorAll('.tab-panel').forEach(p => p.hidden = true);
            btn.classList.add('active');
            const panel = document.getElementById(target);
            if (panel) panel.hidden = false;
        });
    });
    // Activate first tab by default
    document.querySelectorAll('.tab-group').forEach(group => {
        const first = group.querySelector('.tab-btn');
        if (first) first.click();
    });
}

document.addEventListener('DOMContentLoaded', initTabs);

// ── Drag-and-drop upload preview ─────────────────────────
const uploadBox = document.getElementById('upload-box');
const fileInput = document.getElementById('file-input');

if (uploadBox && fileInput) {
    uploadBox.addEventListener('click', () => fileInput.click());

    uploadBox.addEventListener('dragover', e => {
        e.preventDefault();
        uploadBox.style.borderColor = 'var(--clr-primary)';
        uploadBox.style.background  = '#eef2ff';
    });

    uploadBox.addEventListener('dragleave', () => {
        uploadBox.style.borderColor = '';
        uploadBox.style.background  = '';
    });

    uploadBox.addEventListener('drop', e => {
        e.preventDefault();
        uploadBox.style.borderColor = '';
        uploadBox.style.background  = '';
        if (e.dataTransfer.files.length) {
            fileInput.files = e.dataTransfer.files;
            showFileName(e.dataTransfer.files[0].name);
        }
    });

    fileInput.addEventListener('change', () => {
        if (fileInput.files.length) showFileName(fileInput.files[0].name);
    });

    function showFileName(name) {
        const p = uploadBox.querySelector('p');
        if (p) p.textContent = '📎 ' + name;
    }
}
