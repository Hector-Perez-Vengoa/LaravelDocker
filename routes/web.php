<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PostController;

// Ruta principal: mostramos directamente el listado de posts
Route::get('/', [PostController::class, 'index'])->name('home');

// Rutas RESTful completas para posts (index, create, store, show, edit, update, destroy)
Route::resource('posts', PostController::class);

// Fallback: cualquier ruta no encontrada redirige al listado
Route::fallback(function () {
    return redirect()->route('posts.index');
});
