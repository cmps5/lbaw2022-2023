<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Search;
use App\Models\Tag;
use App\Models\User;
use App\Providers\RouteServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use phpDocumentor\Reflection\Types\True_;

class SearchController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth')->only('index', 'store', 'show', 'search');
    }

    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $posts = Post::all()->sortByDesc('votes');
        $users = User::all()->sortByDesc('reputation');
        $content = 'all';
        return view('searches.index', compact('posts', 'users', 'content'));
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'content' => ['required', 'string'],
        ]);


        return Redirect('searches/' . $data['content'],302);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Search  $search
     * @return \Illuminate\Http\Response
     */
    public function show($content)
    {
        $posts = Post::search($content)->get();
        $tags = Tag::all();
        //dd($posts);
        return view('searches/index', compact('posts', 'tags', 'content'));
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Search  $search
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Search $search)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Search  $search
     * @return \Illuminate\Http\Response
     */
    public function destroy(Search $search)
    {
        //
    }



    public function filter(Request $request, $content)
    {
        $posts = Post::search($content)->get();

        $posts = $posts->filter(function ($post) use ($request) {
            foreach ($post->tags as $tag){
                $tagname = 'tag' . $tag->id;
                if($request[$tagname])
                    return true;
            }
            return false;
        });

        $tags = Tag::all();

        return view('searches/index', compact('posts', 'tags', 'content'));
    }
}
