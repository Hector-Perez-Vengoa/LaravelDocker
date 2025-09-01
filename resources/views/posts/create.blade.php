@extends('layouts.app')
@section('title', 'Crear Post')
@section('content')
    <div class="container" style="max-width:840px;">
        <div class="d-flex align-items-center justify-content-between mb-4">
            <h1 class="h3 mb-0">Crear nuevo Post</h1>
            <a href="{{ route('posts.index') }}" class="btn btn-outline-secondary">← Volver</a>
        </div>
        <div class="card p-4 p-md-5">
            <form action="{{ route('posts.store') }}" method="POST" novalidate>
                @csrf
                <div class="mb-4">
                    <label for="title" class="form-label fw-semibold">Título <span class="text-danger">*</span></label>
                    <input type="text" name="title" id="title" class="form-control form-control-lg" placeholder="Ej: Mi primera entrada" required>
                </div>
                <div class="mb-4">
                    <label for="content" class="form-label fw-semibold">Contenido <span class="text-danger">*</span></label>
                    <textarea name="content" id="content" data-autosize class="form-control" rows="5" placeholder="Escribe el contenido..." required></textarea>
                </div>
                <div class="d-flex gap-3">
                    <button type="submit" class="btn btn-primary px-4">Guardar</button>
                    <a href="{{ route('posts.index') }}" class="btn btn-outline-secondary">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
@endsection
