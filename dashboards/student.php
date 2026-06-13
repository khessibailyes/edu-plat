<?php
// ============================================================
//  dashboards/student.php
// ============================================================
declare(strict_types=1);
session_start();

if (empty($_SESSION['user_id']) || $_SESSION['role'] !== 'student') {
    header('Location: /auth/login.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';
$pdo = get_pdo();
$uid = (int)$_SESSION['user_id'];

// Profile data
$me = $pdo->prepare('SELECT id, full_name, email, created_at FROM users WHERE id = ?');
$me->execute([$uid]);
$me = $me->fetch();

// Public feed (broadcast messages)
$feed = $pdo->query(
    "SELECT m.*, u.full_name AS sender_name
     FROM messages m JOIN users u ON u.id = m.sender_id
     WHERE m.type = 'public' OR m.receiver_id = 'all'
     ORDER BY m.timestamp DESC LIMIT 30"
)->fetchAll();

// Private inbox
$inbox = $pdo->prepare(
    "SELECT m.*, u.full_name AS sender_name
     FROM messages m JOIN users u ON u.id = m.sender_id
     WHERE m.receiver_id = ? AND m.type = 'private'
     ORDER BY m.timestamp DESC"
);
$inbox->execute([$uid]);
$inbox = $inbox->fetchAll();

// Teachers to message
$teachers = $pdo->query("SELECT id, full_name FROM users WHERE role='teacher' ORDER BY full_name")->fetchAll();

// Available documents (all teachers)
$documents = $pdo->query(
    "SELECT d.*, u.full_name AS teacher_name
     FROM documents d JOIN users u ON u.id = d.teacher_id
     ORDER BY d.upload_date DESC"
)->fetchAll();

$flash = $_SESSION['flash'] ?? null;
unset($_SESSION['flash']);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard – EduPlatform</title>
    <link rel="stylesheet" href="/assets/css/style.css">
    <style>
        .tab-group .tabs { display:flex; gap:.5rem; margin-bottom:1rem; flex-wrap:wrap; }
        .tab-btn { background:var(--clr-bg); border:1.5px solid var(--clr-border); border-radius:var(--radius); padding:.45rem 1rem; cursor:pointer; font-size:.85rem; font-weight:600; color:var(--clr-muted); transition:all .2s; }
        .tab-btn.active { background:var(--clr-success); color:#fff; border-color:var(--clr-success); }
        .profile-card { display:flex; align-items:center; gap:1.25rem; }
        .avatar-lg { width:64px; height:64px; border-radius:50%; background:var(--clr-primary); color:#fff; display:flex; align-items:center; justify-content:center; font-size:1.6rem; font-weight:700; flex-shrink:0; }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="sidebar-brand">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
            <span>EduPlatform</span>
        </div>
        <ul class="sidebar-nav">
            <li><a href="#">
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                <span>Profile</span>
            </a></li>
            <li><a href="#">
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                <span>Public Feed</span>
            </a></li>
            <li><a href="#">
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                <span>Messages</span>
            </a></li>
        </ul>
        <div class="sidebar-footer">
            <div class="sidebar-user">
                <div class="avatar"><?= strtoupper(substr($_SESSION['full_name'], 0, 1)) ?></div>
                <div class="sidebar-user-info">
                    <div class="name"><?= htmlspecialchars($_SESSION['full_name']) ?></div>
                    <div class="role-badge">Student</div>
                </div>
            </div>
            <a href="/auth/logout.php" class="btn btn-outline btn-sm btn-block">Sign Out</a>
        </div>
    </aside>

    <div class="main">
        <header class="topbar">
            <h1>Student Dashboard</h1>
            <span class="badge badge-student">Student</span>
        </header>

        <main class="content">
            <?php if ($flash): ?>
                <div class="alert alert-<?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
            <?php endif; ?>

            <div class="tab-group">
                <div class="tabs">
                    <button class="tab-btn" data-tab="profile">My Profile</button>
                    <button class="tab-btn" data-tab="feed">Public Feed</button>
                    <button class="tab-btn" data-tab="inbox">Inbox</button>
                    <button class="tab-btn" data-tab="ask">Ask a Teacher</button>
                    <button class="tab-btn" data-tab="docs">Documents</button>
                </div>

                <!-- PROFILE -->
                <div id="profile" class="tab-panel">
                    <div class="card">
                        <div class="card-header"><h3>My Profile</h3></div>
                        <div class="card-body">
                            <div class="profile-card mb-3">
                                <div class="avatar-lg"><?= strtoupper(substr($me['full_name'], 0, 1)) ?></div>
                                <div>
                                    <h2><?= htmlspecialchars($me['full_name']) ?></h2>
                                    <p class="text-muted"><?= htmlspecialchars($me['email']) ?></p>
                                    <p class="text-muted">Member since <?= date('F Y', strtotime($me['created_at'])) ?></p>
                                </div>
                            </div>
                            <form method="POST" action="/actions/update_profile.php">
                                <div class="grid-2">
                                    <div class="form-group">
                                        <label>Full Name</label>
                                        <input type="text" name="full_name" value="<?= htmlspecialchars($me['full_name']) ?>" required>
                                    </div>
                                    <div class="form-group">
                                        <label>Email Address</label>
                                        <input type="email" name="email" value="<?= htmlspecialchars($me['email']) ?>" required>
                                    </div>
                                    <div class="form-group">
                                        <label>New Password <span class="text-muted">(leave blank to keep current)</span></label>
                                        <input type="password" name="password" placeholder="••••••••">
                                    </div>
                                    <div class="form-group">
                                        <label>Confirm New Password</label>
                                        <input type="password" name="confirm" placeholder="••••••••">
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary">Save Changes</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- PUBLIC FEED -->
                <div id="feed" class="tab-panel" hidden>
                    <div class="card">
                        <div class="card-header"><h3>Public Announcements &amp; Posts</h3></div>
                        <div class="card-body">
                            <?php if (empty($feed)): ?>
                                <p class="text-muted">No public posts yet.</p>
                            <?php else: ?>
                                <div class="msg-list">
                                <?php foreach ($feed as $msg): ?>
                                    <div class="msg-item">
                                        <div class="msg-meta">
                                            <span><strong><?= htmlspecialchars($msg['sender_name']) ?></strong></span>
                                            <span><?= date('M j, H:i', strtotime($msg['timestamp'])) ?>
                                                &nbsp;<span class="badge badge-public">broadcast</span></span>
                                        </div>
                                        <p><?= nl2br(htmlspecialchars($msg['content'])) ?></p>
                                    </div>
                                <?php endforeach; ?>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>

                <!-- INBOX -->
                <div id="inbox" class="tab-panel" hidden>
                    <div class="card">
                        <div class="card-header"><h3>Private Messages</h3><span class="text-muted"><?= count($inbox) ?></span></div>
                        <div class="card-body">
                            <?php if (empty($inbox)): ?>
                                <p class="text-muted">Your inbox is empty.</p>
                            <?php else: ?>
                                <div class="msg-list">
                                <?php foreach ($inbox as $msg): ?>
                                    <div class="msg-item received">
                                        <div class="msg-meta">
                                            <span>From <strong><?= htmlspecialchars($msg['sender_name']) ?></strong></span>
                                            <span><?= date('M j, H:i', strtotime($msg['timestamp'])) ?></span>
                                        </div>
                                        <p><?= nl2br(htmlspecialchars($msg['content'])) ?></p>
                                    </div>
                                <?php endforeach; ?>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>

                <!-- ASK A TEACHER -->
                <div id="ask" class="tab-panel" hidden>
                    <div class="card">
                        <div class="card-header"><h3>Ask a Teacher</h3></div>
                        <div class="card-body">
                            <form method="POST" action="/actions/send_message.php">
                                <input type="hidden" name="type" value="private">
                                <div class="form-group">
                                    <label>Select Teacher</label>
                                    <select name="receiver_id" required>
                                        <option value="">— choose teacher —</option>
                                        <?php foreach ($teachers as $t): ?>
                                            <option value="<?= $t['id'] ?>"><?= htmlspecialchars($t['full_name']) ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Your Question</label>
                                    <textarea name="content" rows="4" required placeholder="Ask anything…"></textarea>
                                </div>
                                <button type="submit" class="btn btn-success">Send Question</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- DOCUMENTS -->
                <div id="docs" class="tab-panel" hidden>
                    <div class="card">
                        <div class="card-header"><h3>Available Documents</h3></div>
                        <div class="card-body">
                            <?php if (empty($documents)): ?>
                                <p class="text-muted">No documents available yet.</p>
                            <?php else: ?>
                                <div class="table-wrap">
                                    <table>
                                        <thead><tr><th>File</th><th>Description</th><th>Teacher</th><th>Date</th></tr></thead>
                                        <tbody>
                                        <?php foreach ($documents as $d): ?>
                                            <tr>
                                                <td><a href="/<?= htmlspecialchars($d['file_path']) ?>" target="_blank">📄 <?= htmlspecialchars(basename($d['file_path'])) ?></a></td>
                                                <td><?= htmlspecialchars($d['description'] ?? '—') ?></td>
                                                <td><?= htmlspecialchars($d['teacher_name']) ?></td>
                                                <td><?= date('M j, Y', strtotime($d['upload_date'])) ?></td>
                                            </tr>
                                        <?php endforeach; ?>
                                        </tbody>
                                    </table>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>
</div>
<script src="/assets/js/app.js"></script>
</body>
</html>
