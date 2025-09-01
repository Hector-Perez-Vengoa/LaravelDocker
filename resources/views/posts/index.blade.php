@extends('layouts.app')
@section('title', 'Posts')
@section('content')
    <div class="container">
        <div class="d-flex flex-wrap align-items-end justify-content-between mb-4 gap-3">
            <div>
                <h1 class="h2 mb-1 fw-semibold">Listado de Posts</h1>
                <p class="text-muted mb-0" style="color:#9aa4b1 !important">@choice(':count registro|:count registros', $posts->count(), ['count' => $posts->count()])</p>
            </div>
            <div class="d-flex gap-2">
                <a href="{{ route('posts.create') }}" class="btn btn-primary">Nuevo Post</a>
            </div>
        </div>
        @if(session('success'))
            <div class="alert alert-success mb-4">{{ session('success') }}</div>
        @endif
        @if($posts->isEmpty())
            <div class="card p-5 text-center">
                <div class="mb-3">📭</div>
                <h5 class="mb-2">Sin posts todavía</h5>
                <p class="text-muted mb-4">Crea tu primer post para comenzar.</p>
                <a href="{{ route('posts.create') }}" class="btn btn-primary">Crear Post</a>
            </div>
        @else
            <div class="row g-4">
                @foreach($posts as $post)
                    <div class="col-12 col-md-6 col-lg-4">
                        <div class="card h-100 position-relative card-hover p-3 d-flex flex-column">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h5 class="mb-0 me-2 gradient-text" style="line-height:1.2; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:200px">{{ $post->title }}</h5>
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">Acciones</button>
                                    <ul class="dropdown-menu dropdown-menu-dark">
                                        <li><a class="dropdown-item" href="{{ route('posts.show', $post) }}">Ver</a></li>
                                        <li><a class="dropdown-item" href="{{ route('posts.edit', $post) }}">Editar</a></li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li>
                                            <form action="{{ route('posts.destroy', $post) }}" method="POST" onsubmit="return confirm('¿Eliminar este post?')">
                                                @csrf
                                                @method('DELETE')
                                                <button class="dropdown-item text-danger" type="submit">Eliminar</button>
                                            </form>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                            <p class="mb-3 text-muted" style="flex-grow:1; white-space:pre-line; overflow:hidden; display:-webkit-box; -webkit-line-clamp:5; -webkit-box-orient:vertical;">{{ $post->content }}</p>
                            <div class="d-flex justify-content-between align-items-center small text-muted mt-auto pt-2 border-top" style="border-color:#2a3039 !important">
                                <span>ID #{{ $post->id }}</span>
                                <a class="text-decoration-none" href="{{ route('posts.show', $post) }}">Detalles →</a>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
        @endif
    </div>
@endsection
