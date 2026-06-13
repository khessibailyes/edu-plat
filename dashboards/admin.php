<?php
// ============================================================
//  dashboards/admin.php
// ============================================================
declare(strict_types=1);
session_start();

if (empty($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header('Location: /auth/login.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';
$pdo = get_pdo();

// ── Stats ─────────────────────────────────────────────────
$total_users    = $pdo->query('SELECT COUNT(*) FROM users')->fetchColumn();
$total_teachers = $pdo->query("SELECT COUNT(*) FROM users WHERE role='teacher'")->fetchColumn();
$total_students = $pdo->query("SELECT COUNT(*) FROM users WHERE role='student'")->fetchColumn();
$total_docs     = $pdo->query('SELECT COUNT(*) FROM documents')->fetchColumn();

// ── Users list ────────────────────────────────────────────
$users = $pdo->query('SELECT * FROM view_users_alphabetical')->fetchAll();

// ── Products by price ─────────────────────────────────────
$products_sorted = $pdo->query('SELECT * FROM view_products_by_price')->fetchAll();

// ── Products mid-stock ────────────────────────────────────
$products_mid = $pdo->query('SELECT * FROM view_products_mid_stock')->fetchAll();

// ── Recent messages ───────────────────────────────────────
$messages = $pdo->query(
    'SELECT m.*, u.full_name AS sender_name
     FROM messages m JOIN users u ON u.id = m.sender_id
     ORDER BY m.timestamp DESC LIMIT 20'
)->fetchAll();

// ── Flash ─────────────────────────────────────────────────
$flash = $_SESSION['flash'] ?? null;
unset($_SESSION['flash']);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard – EduPlatform</title>
    <link rel="stylesheet" href="/assets/css/style.css">
    <style>
        .tab-group .tabs { display:flex; gap:.5rem; margin-bottom:1rem; flex-wrap:wrap; }
        .tab-btn { background:var(--clr-bg); border:1.5px solid var(--clr-border); border-radius:var(--radius); padding:.45rem 1rem; cursor:pointer; font-size:.85rem; font-weight:600; color:var(--clr-muted); transition:all .2s; }
        .tab-btn.active { background:var(--clr-primary); color:#fff; border-color:var(--clr-primary); }
    </style>
</head>
<body>
<div class="layout">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
            <span>EduPlatform</span>
        </div>
        <ul class="sidebar-nav">
            <li><a href="#" data-tab-goto="overview">
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>
                <span>Overview</span>
            </a></li>
            <li><a href="#" data-tab-goto="users">
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                <span>Users</span>
            </a></li>
            <li><a href="#" data-tab-goto="broadcast">
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                <span>Broadcast</span>
            </a></li>
            <li><a href="#" data-tab-goto="products">
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                <span>Products</span>
            </a></li>
        </ul>
        <div class="sidebar-footer">
            <div class="sidebar-user">
                <div class="avatar"><?= strtoupper(substr($_SESSION['full_name'], 0, 1)) ?></div>
                <div class="sidebar-user-info">
                    <div class="name"><?= htmlspecialchars($_SESSION['full_name']) ?></div>
                    <div class="role-badge">Administrator</div>
                </div>
            </div>
            <a href="/auth/logout.php" class="btn btn-outline btn-sm btn-block">Sign Out</a>
        </div>
    </aside>

    <!-- Main -->
    <div class="main">
        <header class="topbar">
            <h1>Admin Dashboard</h1>
            <div class="topbar-actions">
                <span class="badge badge-admin">Admin</span>
            </div>
        </header>

        <main class="content">
            <?php if ($flash): ?>
                <div class="alert alert-<?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
            <?php endif; ?>

            <div class="tab-group" id="main-tabs">
                <div class="tabs">
                    <button class="tab-btn" data-tab="overview">Overview</button>
                    <button class="tab-btn" data-tab="users">Users</button>
                    <button class="tab-btn" data-tab="broadcast">Broadcast</button>
                    <button class="tab-btn" data-tab="products">Products</button>
                    <button class="tab-btn" data-tab="messages">Messages</button>
                </div>

                <!-- OVERVIEW -->
                <div id="overview" class="tab-panel">
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-icon purple"><svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg></div>
                            <div><div class="stat-label">Total Users</div><div class="stat-value"><?= $total_users ?></div></div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon blue"><svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M20 7H4a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"/><polyline points="16 21 12 17 8 21"/><polyline points="12 3 12 7"/></svg></div>
                            <div><div class="stat-label">Teachers</div><div class="stat-value"><?= $total_teachers ?></div></div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon green"><svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg></div>
                            <div><div class="stat-label">Students</div><div class="stat-value"><?= $total_students ?></div></div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon amber"><svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
                            <div><div class="stat-label">Documents</div><div class="stat-value"><?= $total_docs ?></div></div>
                        </div>
                    </div>
                </div>

                <!-- USERS -->
                <div id="users" class="tab-panel" hidden>
                    <div class="card">
                        <div class="card-header">
                            <h3>All Users (Alphabetical)</h3>
                            <span class="text-muted"><?= count($users) ?> total</span>
                        </div>
                        <div class="card-body">
                            <div class="table-wrap">
                                <table>
                                    <thead><tr><th>#</th><th>Full Name</th><th>Email</th><th>Role</th><th>Joined</th><th>Action</th></tr></thead>
                                    <tbody>
                                    <?php foreach ($users as $u): ?>
                                        <tr>
                                            <td><?= $u['id'] ?></td>
                                            <td><?= htmlspecialchars($u['full_name']) ?></td>
                                            <td><?= htmlspecialchars($u['email']) ?></td>
                                            <td><span class="badge badge-<?= $u['role'] ?>"><?= ucfirst($u['role']) ?></span></td>
                                            <td><?= date('M j, Y', strtotime($u['created_at'])) ?></td>
                                            <td>
                                                <?php if ((int)$u['id'] !== (int)$_SESSION['user_id']): ?>
                                                <a href="/actions/delete_user.php?id=<?= $u['id'] ?>"
                                                   class="btn btn-danger btn-sm"
                                                   data-confirm="Delete this user permanently?">Delete</a>
                                                <?php endif; ?>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- BROADCAST -->
                <div id="broadcast" class="tab-panel" hidden>
                    <div class="card">
                        <div class="card-header"><h3>Send Broadcast Message</h3></div>
                        <div class="card-body">
                            <form method="POST" action="/actions/send_message.php">
                                <input type="hidden" name="receiver_id" value="all">
                                <input type="hidden" name="type" value="public">
                                <div class="form-group">
                                    <label>Message to ALL users</label>
                                    <textarea name="content" rows="4" required placeholder="Write your announcement here…"></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary">Send Broadcast</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- PRODUCTS -->
                <div id="products" class="tab-panel" hidden>
                    <div class="grid-2 mb-2">
                        <div class="card">
                            <div class="card-header"><h3>All Products (Price ASC)</h3></div>
                            <div class="card-body">
                                <div class="table-wrap">
                                    <table>
                                        <thead><tr><th>Product</th><th>Price</th><th>Stock</th></tr></thead>
                                        <tbody>
                                        <?php foreach ($products_sorted as $p): ?>
                                            <tr>
                                                <td><?= htmlspecialchars($p['product_name']) ?></td>
                                                <td>$<?= number_format((float)$p['price'], 2) ?></td>
                                                <td><?= $p['stock_quantity'] ?></td>
                                            </tr>
                                        <?php endforeach; ?>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="card">
                            <div class="card-header"><h3>Mid-Stock Products (10–30)</h3></div>
                            <div class="card-body">
                                <div class="table-wrap">
                                    <table>
                                        <thead><tr><th>Product</th><th>Price</th><th>Stock</th></tr></thead>
                                        <tbody>
                                        <?php foreach ($products_mid as $p): ?>
                                            <tr>
                                                <td><?= htmlspecialchars($p['product_name']) ?></td>
                                                <td>$<?= number_format((float)$p['price'], 2) ?></td>
                                                <td><?= $p['stock_quantity'] ?></td>
                                            </tr>
                                        <?php endforeach; ?>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Add product form -->
                    <div class="card">
                        <div class="card-header"><h3>Add Product</h3></div>
                        <div class="card-body">
                            <form method="POST" action="/actions/save_product.php" class="d-flex gap-2" style="flex-wrap:wrap">
                                <div class="form-group flex-1" style="min-width:160px">
                                    <label>Product Name</label>
                                    <input type="text" name="product_name" required>
                                </div>
                                <div class="form-group" style="width:120px">
                                    <label>Price ($)</label>
                                    <input type="number" name="price" step="0.01" min="0" required>
                                </div>
                                <div class="form-group" style="width:120px">
                                    <label>Stock Qty</label>
                                    <input type="number" name="stock_quantity" min="0" required>
                                </div>
                                <div class="form-group" style="align-self:flex-end">
                                    <button type="submit" class="btn btn-success">Add</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- MESSAGES -->
                <div id="messages" class="tab-panel" hidden>
                    <div class="card">
                        <div class="card-header"><h3>All Messages</h3></div>
                        <div class="card-body">
                            <div class="msg-list">
                            <?php foreach ($messages as $msg): ?>
                                <div class="msg-item">
                                    <div class="msg-meta">
                                        <span><strong><?= htmlspecialchars($msg['sender_name']) ?></strong>
                                            → <?= $msg['receiver_id'] === 'all' ? '<em>Everyone</em>' : 'User #' . htmlspecialchars($msg['receiver_id']) ?></span>
                                        <span><?= date('M j, H:i', strtotime($msg['timestamp'])) ?>
                                            &nbsp;<span class="badge badge-<?= $msg['type'] ?>"><?= $msg['type'] ?></span></span>
                                    </div>
                                    <p><?= nl2br(htmlspecialchars($msg['content'])) ?></p>
                                </div>
                            <?php endforeach; ?>
                            </div>
                        </div>
                    </div>
                </div>

            </div><!-- /tab-group -->
        </main>
    </div>
</div>
<script src="/assets/js/app.js"></script>
<script>
// Sidebar nav → tab switcher
document.querySelectorAll('[data-tab-goto]').forEach(link => {
    link.addEventListener('click', e => {
        e.preventDefault();
        const tabId = link.dataset.tabGoto;
        const btn = document.querySelector(`.tab-btn[data-tab="${tabId}"]`);
        if (btn) btn.click();
    });
});
</script>
</body>
</html>
