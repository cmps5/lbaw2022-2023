<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Tag;
use App\Models\User;
use App\Providers\RouteServiceProvider;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\Facades\View;

class PostController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth')->only('store', 'create');
    }

    public function create()
    {
        $tags = Tag::all();
        return view('posts.create', compact('tags'));
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $post = Post::findOrFail($id);
        return view('posts.index', compact('post'));
    }

    /**
     * Display a listing of the resource.
     *
     * @return string
     */
    public function index()
    {
        $post = Post::findOrFail(1);
        $user = User::findOrFail($post['user_id']);
        return view('posts.index', compact('user', 'post')) . view('posts.index', compact('user', 'post'));
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => ['required', 'max:255', 'string'],
            'content' => ['string'],
            'media' => ['nullable', 'image'],
        ]);

        $data['media'] = $request['media'] ? $request['media']->store('posts', 'public') : null;
        $post = auth()->user()->posts()->create($data);

        foreach (Tag::all() as $tag){
            $tagname = 'tag' . $tag->id;
            if($request[$tagname]) {
                DB::table('posts_tags')->insert([
                    'post_id' => $post->id,
                    'tag_id' => $tag->id
                ]);
            }
        }

        return Redirect::to('/posts/' . $post->id);
    }

    /**
     * Shows the page for editing a resource.
     *
     * @param $id
     * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\View
     */
    public function edit($id)
    {
        $post = Post::findOrFail($id);
        $tags = Tag::all();
        return view('posts.edit', compact('post', 'tags'));
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(Request $request, $id)
    {
        $post = Post::find($id);
        $post->tags()->delete();

        if (File::exists('storage/' . $post['media']))
            File::delete('storage/' . $post['media']);

        Post::where('id', $id)->update([
            'title' => $request['title'],
            'content' => $request['content'],
            'media' => $request['media'] ? $request['media']->store('posts', 'public') : null,
        ]);


        foreach (Tag::all() as $tag){
            $tagname = 'tag' . $tag->id;
            if($request[$tagname]) {
                DB::table('posts_tags')->insert([
                    'post_id' => $post->id,
                    'tag_id' => $tag->id
                ]);
            }
        }
        return Redirect::to('/posts/' . $id);
    }


    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy($id)
    {
        try {
            Post::destroy($id);
        } catch (QueryException $exception) {
            return Redirect::back()->withErrors(['destroy' => 'Your request cannot be satisfied at the moment.']);
        }

        return Redirect(RouteServiceProvider::HOME);
    }

    public function closePost($id){

        Post::where('id', $id)->update([
            'status' => 'closed',
        ]);

        return redirect()->back();
    }
    public function hidePost($id){

        Post::where('id', $id)->update([
            'status' => 'hidden',
        ]);

        return redirect()->back();
    }
    public function deletePost($id){

        Post::where('id', $id)->update([
            'status' => 'deleted',
        ]);

        return redirect()->back();
    }
    public function openPost($id){

        Post::where('id', $id)->update([
            'status' => 'open',
        ]);

        return redirect()->back();
    }

}
