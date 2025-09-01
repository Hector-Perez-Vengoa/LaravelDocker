<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'CRUD Laravel')</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            :root {
                --bg: #0f1115;
                --bg-alt: #181b21;
                --card: #1f232b;
                --border: #2a3039;
                --text: #f2f5f9; /* un poco más claro */
                --text-dim: #b0bac5; /* más contraste que antes */
                --primary: #6366f1;
                --danger: #ef4444;
                --warning: #f59e0b;
                --success: #22c55e;
            }
            body { background: var(--bg); color: var(--text); font-family: 'Inter', system-ui, sans-serif; }
            a, .nav-link, .navbar-brand { color: var(--text) !important; }
            a:hover { color: var(--primary) !important; }
            .navbar { background: rgba(15,17,21,.85) !important; backdrop-filter: blur(8px); border-bottom: 1px solid var(--border); }
            .card { background: var(--card); border: 1px solid var(--border); border-radius: 14px; box-shadow: 0 4px 16px -4px rgba(0,0,0,.5); }
            .card-hover:hover { transform: translateY(-3px); transition: .25s; box-shadow: 0 8px 24px -6px rgba(0,0,0,.55); }
            .btn-primary { background: var(--primary); border-color: var(--primary); }
            .btn-primary:hover { filter: brightness(1.1); }
            .btn-danger { background: var(--danger); border-color: var(--danger); }
            .btn-warning { background: var(--warning); border-color: var(--warning); color:#222; }
            .btn-success { background: var(--success); border-color: var(--success); }
            .table-dark-custom { --bs-table-bg: var(--card); --bs-table-striped-bg: #252b34; --bs-table-striped-color: var(--text); }
            table thead th { color: var(--text-dim); font-weight: 600; font-size: .75rem; letter-spacing: .08em; text-transform: uppercase; }
            .form-control, textarea { background: #252a33; border: 1px solid var(--border); color: var(--text); }
            .form-control:focus { background:#2b313b; color:var(--text); border-color: var(--primary); box-shadow:0 0 0 .2rem rgba(99,102,241,.25); }
        .badge-soft { background: #2b3040; color: var(--primary); font-weight:500; }
        .text-muted, .form-text { color: var(--text-dim) !important; }
        label { color: var(--text) !important; }
        ::placeholder { color: var(--text-dim) !important; opacity: .85; }
        .dropdown-menu-dark { background:#242a33; }
        .dropdown-menu-dark .dropdown-item { color: var(--text-dim); }
        .dropdown-menu-dark .dropdown-item:hover { color: var(--text); background:#303845; }
            .alert-success { background:#123524; border:1px solid #1f7041; color:#6de7a1; }
            footer { font-size:.75rem; color: var(--text-dim); margin-top:3rem; text-align:center; padding:2rem 0; border-top:1px solid var(--border); }
            .gradient-text { background: linear-gradient(90deg,#6366f1,#8b5cf6,#ec4899); -webkit-background-clip: text; color: transparent; }
        </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg mb-4 sticky-top">
        <div class="container">
            <a class="navbar-brand fw-bold gradient-text" href="{{ url('/') }}">CRUD Laravel</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav" aria-controls="nav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="nav">
                <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-3">
                    <li class="nav-item"><a class="nav-link" href="{{ route('posts.index') }}">Posts</a></li>
                    <li class="nav-item"><a class="nav-link" href="{{ route('posts.create') }}">Crear</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <main class="pb-5">
        @yield('content')
    </main>
    <footer>
        <div class="container">Hecho con Laravel • {{ date('Y') }}</div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.querySelectorAll('textarea[data-autosize]')?.forEach(t => { t.addEventListener('input', e=> { t.style.height='auto'; t.style.height=(t.scrollHeight)+'px';}); });
    </script>
</body>
</html>
