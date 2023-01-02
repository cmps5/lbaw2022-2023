<?php

namespace App\Http\Controllers;

use App\Models\Post;

class HomeController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        $topposts = Post::all()->sortByDesc('votes');
        $recentposts = Post::all()->sortByDesc('created_at')->sortByDesc('votes');
        return view('home', compact('topposts', 'recentposts'));
    }
}
