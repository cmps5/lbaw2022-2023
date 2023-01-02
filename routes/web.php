<?php

use App\Http\Controllers\BlockController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\SearchController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\UserFollowTagController;
use App\Http\Controllers\FollowController;
use App\Http\Controllers\UserVoteCommentController;
use App\Http\Controllers\UserVotePostController;
use App\Http\Controllers\ReportController;
use App\Models\UserVoteComment;
use App\Models\UserVotePost;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Auth::routes();
Route::get('/', [HomeController::class, 'index'])->name('home');

// Static pages
Route::get('/about', function() { return view('static.about'); })->name('about');
Route::get('/contacts', function() { return view('static.contacts'); })->name('contacts');
Route::get('/help', function() { return view('static.help'); })->name('help');
Route::get('/features', function() { return view('static.features'); })->name('features');

// User
Route::get('/users/{user}/edit', [UserController::class, 'edit'])->name('users.edit');
Route::get('/users/{user}', [UserController::class, 'show'])->name('users.show');
Route::patch('/users/{user}', [UserController::class, 'update'])->name('users.update');
Route::delete('/users/{user}/delete', [UserController::class, 'destroy'])->name('users.delete');
//needs improvement
Route::patch('/users/{user}/extendTimeout', [UserController::class, 'extendTimeout'])->name('users.extendTimeout');
Route::get('/changePassword', [UserController::class, 'requestChangePassword'])->name('users.requestChangePassword');
Route::patch('/changePassword', [UserController::class, 'commitChangePassword'])->name('users.commitChangePassword');

// Post
Route::get('/posts', [PostController::class, 'index'])->name('posts.index');
Route::get('/posts/create', [PostController::class, 'create'])->name('posts.create');
Route::get('/posts/{post}/edit', [PostController::class, 'edit'])->name('posts.edit');
Route::patch('/posts/{post}', [PostController::class, 'update'])->name('posts.update');
Route::post('/posts', [PostController::class, 'store'])->name('posts.store');
Route::get('/posts/{post}', [PostController::class, 'show'])->name('posts.show');
Route::delete('/posts/{post}', [PostController::class, 'destroy'])->name('posts.destroy');

//Change Post Status
Route::patch('/posts/{post}/openPost', [PostController::class, 'openPost'])->name('posts.openPost');
Route::patch('/posts/{post}/closePost', [PostController::class, 'closePost'])->name('posts.closePost');
Route::patch('/posts/{post}/hidePost', [PostController::class, 'hidePost'])->name('posts.hidePost');
Route::patch('/posts/{post}/deletePost', [PostController::class, 'deletePost'])->name('posts.deletePost');

// Comment
Route::get('/comments/{comments}/edit', [CommentController::class, 'edit'])->name('comments.edit');
Route::patch('/comments/{comments}', [CommentController::class, 'update'])->name('comments.update');
Route::post('/comments', [CommentController::class, 'store'])->name('comments.store');
Route::delete('/comments/{comments}', [CommentController::class, 'destroy'])->name('comments.destroy');

// Search
Route::get('/searches', [SearchController::class, 'index'])->name('search.index');
Route::get('/searches/{search}', [SearchController::class, 'show'])->name('search.show');
Route::post('/searches', [SearchController::class, 'store'])->name('search.store');
Route::get('/searches/{search}/filter', [SearchController::class, 'filter'])->name('searches.filter');

// Vote
Route::post('/upvotePost', [UserVotePostController::class, 'upvotePost'])->name('upvotePost');
Route::post('/downvotePost', [UserVotePostController::class, 'downvotePost'])->name('downvotePost');
Route::post('/upvoteComment', [UserVoteCommentController::class, 'upvoteComment'])->name('upvoteComment');
Route::post('/downvoteComment', [UserVoteCommentController::class, 'downvoteComment'])->name('downvoteComment');


Route::post('/api/user_tags', [UserFollowTagController::class, 'store'])->name('usersTags.store');
Route::delete('/api/user_tags', [UserFollowTagController::class, 'destroy'])->name('usersTags.destroy');

Route::get('/notification/{notification}/unread', [NotificationController::class, 'unmarkRead'])->name('notification.unread');
Route::get('/notification/{notification}/read', [NotificationController::class, 'markAsRead'])->name('notification.read');

Route::post('/api/followers', [FollowController::class, 'store'])->name('followers.store');
Route::delete('/api/followers', [FollowController::class, 'destroy'])->name('followers.destroy');

Route::post('/api/blocks', [BlockController::class, 'store'])->name('block.store');
Route::delete('/api/blocks', [BlockController::class, 'destroy'])->name('block.destroy');

// --------------------------------------------
// Report
Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
Route::post('/reports/create', [ReportController::class, 'store'])->name('reports.store');
