@extends('layouts.app')
@section('title', 'Editar Post')
@section('content')
    <div class="container" style="max-width:840px;">
        <div class="d-flex align-items-center justify-content-between mb-4">
            <h1 class="h3 mb-0">Editar Post</h1>
            <a href="{{ route('posts.index') }}" class="btn btn-outline-secondary">← Volver</a>
        </div>
        <div class="card p-4 p-md-5">
            <form action="{{ route('posts.update', $post) }}" method="POST" novalidate>
                @csrf
                @method('PUT')
                <div class="mb-4">
                    <label for="title" class="form-label fw-semibold">Título <span class="text-danger">*</span></label>
                    <input type="text" name="title" id="title" class="form-control form-control-lg" value="{{ $post->title }}" required>
                </div>
                <div class="mb-4">
                    <label for="content" class="form-label fw-semibold">Contenido <span class="text-danger">*</span></label>
                    <textarea name="content" id="content" data-autosize class="form-control" rows="6" required>{{ $post->content }}</textarea>
                </div>
                <div class="d-flex gap-3">
                    <button type="submit" class="btn btn-primary px-4">Actualizar</button>
                    <a href="{{ route('posts.index') }}" class="btn btn-outline-secondary">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
@endsection
