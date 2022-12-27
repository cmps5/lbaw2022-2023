<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\User;
use App\Providers\RouteServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Redirect;


class PostController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth')->only('store', 'create');
    }

    public function create()
    {
        return view('posts.create');
    }

    public function show($id)
    {
        $post = Post::findOrFail($id);
        return view('posts.index', compact('post'));
    }

    public function index()
    {
        $post = Post::findOrFail(1);
        $user = User::findOrFail($post['user_id']);
        return view('posts.index', compact('user', 'post'));
    }


    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => ['required', 'max:255', 'string'],
            'content' => ['string'],
            'media' => ['nullable', 'image'],
        ]);

        $data['media'] = $request['media'] ? $request['media']->store('posts', 'public') : null;
        auth()->user()->posts()->create($data);

        return Redirect(RouteServiceProvider::HOME,201);
    }


    public function edit($id)
    {
        $post = Post::findOrFail($id);
        return view('posts.edit', compact('post'));
    }


    public function update(Request $request, $id)
    {
        $post = Post::find($id);
        if (File::exists('storage/' . $post['media']))
            File::delete('storage/' . $post['media']);

        Post::where('id', $id)->update([
            'title' => $request['title'],
            'content' => $request['content'],
            'media' => $request['media'] ? $request['media']->store('posts', 'public') : null,
        ]);
        return Redirect::to('/posts/' . $id);
    }

    public function destroy($id)
    {
        Post::destroy($id);
        return Redirect(RouteServiceProvider::HOME, 302);


    }
}
