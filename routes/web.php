<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/



use App\Http\Controllers\CommentController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\SearchController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\UsersFollowsOnTagController;
use App\Http\Controllers\UsersVotesOnCommentController;
use App\Http\Controllers\UsersVotesOnPostController;
use App\Http\Controllers\BlockingController;
use App\Models\Users_votes_on_comment;
use App\Models\Users_votes_on_post;

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Auth::routes();
Route::get('/', [HomeController::class, 'index'])->name('home');

// Static pages
Route::get('/about', function () {
    return view('static.about');
})->name('about');
Route::get('/contacts', function () {
    return view('static.contacts');
})->name('contacts');
Route::get('/help', function () {
    return view('static.help');
})->name('help');
Route::get('/features', function () {
    return view('static.features');
})->name('features');

// User
Route::get('/users/{user}/edit', [UserController::class, 'edit'])->name('userszz.edit');
Route::patch('/users/{user}', [UserController::class, 'update'])->name('users.update');
Route::get('/users/{user}', [UserController::class, 'show'])->name('users.show');
Route::delete('/users/{user}/delete', [UserController::class, 'delete'])->name('users.delete');
//needs improvement
Route::patch('/users/{user}/extendTimeout', [UserController::class, 'extendTimeout'])->name('users.extendTimeout');

// Post
Route::get('/posts', [PostController::class, 'index'])->name('posts.index');
Route::get('/posts/create', [PostController::class, 'create'])->name('posts.create');
Route::get('/posts/{post}/edit', [PostController::class, 'edit'])->name('posts.edit');
Route::patch('/posts/{post}', [PostController::class, 'update'])->name('posts.update');
Route::post('/posts', [PostController::class, 'store'])->name('posts.store');
Route::get('/posts/{post}', [PostController::class, 'show'])->name('posts.show');
Route::delete('/posts/{post}', [PostController::class, 'destroy'])->name('posts.destroy');

// Search
Route::get('/searches', [SearchController::class, 'index'])->name('search.index');
Route::get('/searches/{search}', [SearchController::class, 'show'])->name('search.show');
Route::post('/searches', [SearchController::class, 'store'])->name('search.store');
// Comment
Route::get('/comments/{comments}/edit', [CommentController::class, 'edit'])->name('comments.edit');
Route::patch('/comments/{comments}', [CommentController::class, 'update'])->name('comments.update');
Route::post('/comments', [CommentController::class, 'store'])->name('comments.store');
Route::delete('/comments/{comments}', [CommentController::class, 'destroy'])->name('comments.destroy');

// --------------------------------------------
// Report
Route::get('/reports', function () {
    return view('report');
});
