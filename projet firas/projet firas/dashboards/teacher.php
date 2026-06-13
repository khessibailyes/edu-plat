<?php
// ============================================================
//  dashboards/teacher.php
// ============================================================
declare(strict_types=1);
session_start();

if (empty($_SESSION['user_id']) || $_SESSION['role'] !== 'teacher') {
    header('Location: /auth/login.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';
$pdo = get_pdo();
$uid = (int)$_SESSION['user_id'];

// My documents
$docs = $pdo->prepare('SELECT * FROM documents WHERE teacher_id = ? ORDER BY upload_date DESC');
$docs->execute([$uid]);
$docs = $docs->fetchAll();

// Q&A: messages received (students asking questions)
$inbox = $pdo->prepare(
    'SELECT m.*, u.full_name AS sender_name
     FROM messages m JOIN users u ON u.id = m.sender_id
     WHERE m.receiver_id = ? AND m.type = \'private\'
     ORDER BY m.timestamp DESC'
);
$inbox->execute([$uid]);
$inbox = $inbox->fetchAll();

// List of students for messaging
$students = $pdo->query("SELECT id, full_name FROM users WHERE role='student' ORDER BY full_name")->fetchAll();

$flash = $_SESSION['flash'] ?? null;
unset($_SESSION['flash']);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard – EduPlatform</title>
    <link rel="stylesheet" href="/assets/css/style.css">
    <style>
        .tab-group .tabs { display:flex; gap:.5rem; margin-bottom:1rem; flex-wrap:wrap; }
        .tab-btn { background:var(--clr-bg); border:1.5px solid var(--clr-border); border-radius:var(--radius); padding:.45rem 1rem; cursor:pointer; font-size:.85rem; font-weight:600; color:var(--clr-muted); transition:all .2s; }
        .tab-btn.active { background:var(--clr-secondary); color:#fff; border-color:var(--clr-secondary); }
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
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                <span>Documents</span>
            </a></li>
            <li><a href="#">
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                <span>Q&amp;A</span>
            </a></li>
        </ul>
        <div class="sidebar-footer">
            <div class="sidebar-user">
                <div class="avatar"><?= strtoupper(substr($_SESSION['full_name'], 0, 1)) ?></div>
                <div class="sidebar-user-info">
                    <div class="name"><?= htmlspecialchars($_SESSION['full_name']) ?></div>
                    <div class="role-badge">Teacher</div>
                </div>
            </div>
            <a href="/auth/logout.php" class="btn btn-outline btn-sm btn-block">Sign Out</a>
        </div>
    </aside>

    <div class="main">
        <header class="topbar">
            <h1>Teacher Dashboard</h1>
            <span class="badge badge-teacher">Teacher</span>
        </header>

        <main class="content">
            <?php if ($flash): ?>
                <div class="alert alert-<?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
            <?php endif; ?>

            <div class="tab-group">
                <div class="tabs">
                    <button class="tab-btn" data-tab="upload">Upload Documents</button>
                    <button class="tab-btn" data-tab="mydocs">My Documents</button>
                    <button class="tab-btn" data-tab="qa">Q&amp;A Inbox</button>
                    <button class="tab-btn" data-tab="reply">Reply to Student</button>
                </div>

                <!-- UPLOAD -->
                <div id="upload" class="tab-panel">
                    <div class="card">
                        <div class="card-header"><h3>Upload a Document</h3></div>
                        <div class="card-body">
                            <form method="POST" action="/actions/upload_document.php" enctype="multipart/form-data">
                                <div id="upload-box" class="upload-box mb-2">
                                    <svg width="40" height="40" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                                    <p>Drag &amp; drop or click to select a file</p>
                                    <input type="file" id="file-input" name="document" required style="display:none" accept=".pdf,.doc,.docx,.ppt,.pptx,.txt,.zip">
                                </div>
                                <div class="form-group">
                                    <label>Description (optional)</label>
                                    <textarea name="description" rows="3" placeholder="Briefly describe the document…"></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary">Upload Document</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- MY DOCS -->
                <div id="mydocs" class="tab-panel" hidden>
                    <div class="card">
                        <div class="card-header"><h3>My Documents</h3><span class="text-muted"><?= count($docs) ?> files</span></div>
                        <div class="card-body">
                            <?php if (empty($docs)): ?>
                                <p class="text-muted">No documents uploaded yet.</p>
                            <?php else: ?>
                                <div class="table-wrap">
                                    <table>
                                        <thead><tr><th>File</th><th>Description</th><th>Date</th><th>Action</th></tr></thead>
                                        <tbody>
                                        <?php foreach ($docs as $d): ?>
                                            <tr>
                                                <td><a href="/<?= htmlspecialchars($d['file_path']) ?>" target="_blank">📄 <?= htmlspecialchars(basename($d['file_path'])) ?></a></td>
                                                <td><?= htmlspecialchars($d['description'] ?? '—') ?></td>
                                                <td><?= date('M j, Y', strtotime($d['upload_date'])) ?></td>
                                                <td><a href="/actions/delete_document.php?id=<?= $d['id'] ?>" class="btn btn-danger btn-sm" data-confirm="Delete this document?">Delete</a></td>
                                            </tr>
                                        <?php endforeach; ?>
                                        </tbody>
                                    </table>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>

                <!-- Q&A INBOX -->
                <div id="qa" class="tab-panel" hidden>
                    <div class="card">
                        <div class="card-header"><h3>Q&amp;A Inbox</h3><span class="text-muted"><?= count($inbox) ?> messages</span></div>
                        <div class="card-body">
                            <?php if (empty($inbox)): ?>
                                <p class="text-muted">No questions received yet.</p>
                            <?php else: ?>
                                <div class="msg-list">
                                <?php foreach ($inbox as $msg): ?>
                                    <div class="msg-item received">
                                        <div class="msg-meta">
                                            <span><strong><?= htmlspecialchars($msg['sender_name']) ?></strong></span>
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

                <!-- REPLY -->
                <div id="reply" class="tab-panel" hidden>
                    <div class="card">
                        <div class="card-header"><h3>Send Reply to Student</h3></div>
                        <div class="card-body">
                            <form method="POST" action="/actions/send_message.php">
                                <input type="hidden" name="type" value="private">
                                <div class="form-group">
                                    <label>Select Student</label>
                                    <select name="receiver_id" required>
                                        <option value="">— choose student —</option>
                                        <?php foreach ($students as $s): ?>
                                            <option value="<?= $s['id'] ?>"><?= htmlspecialchars($s['full_name']) ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Message</label>
                                    <textarea name="content" rows="4" required placeholder="Your reply…"></textarea>
                                </div>
                                <button type="submit" class="btn btn-secondary">Send Reply</button>
                            </form>
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
