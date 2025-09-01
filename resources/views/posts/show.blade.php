@extends('layouts.app')
@section('title', 'Detalle Post')
@section('content')
    <div class="container" style="max-width:900px;">
        <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
            <div>
                <h1 class="h3 mb-1 gradient-text">{{ $post->title }}</h1>
                <div class="text-muted small">ID #{{ $post->id }}</div>
            </div>
            <div class="d-flex gap-2">
                <a href="{{ route('posts.edit', $post) }}" class="btn btn-warning">Editar</a>
                <form action="{{ route('posts.destroy', $post) }}" method="POST" onsubmit="return confirm('¿Eliminar este post?')">
                    @csrf
                    @method('DELETE')
                    <button class="btn btn-danger" type="submit">Eliminar</button>
                </form>
                <a href="{{ route('posts.index') }}" class="btn btn-outline-secondary">Volver</a>
            </div>
        </div>
        <div class="card p-4 p-md-5 mb-4">
            <article class="fs-5" style="white-space:pre-line; line-height:1.55">{{ $post->content }}</article>
        </div>
    </div>
@endsection
