<?php

namespace App\Http\Controllers;

class SearchController
{

    public function index()
    {
        $posts = Post::all()->sortByDesc('votes');
        $users = User::all()->sortByDesc('reputation');
        return view('searches.index', compact('posts', 'users'));
    }


    public function store(Request $request)
    {
        $data = $request->validate([
            'content' => ['required', 'string'],
        ]);

        auth()->user()->searches()->create($data);

        return Redirect('searches/' . $data['content'],302);
    }


    public function show($content)
    {
        $posts = Post::search($content)->get();

        //dd($posts);
        return view('searches/index', compact('posts'));
    }


    public function update(Request $request, Search $search)
    {
        //ToDo
    }


    public function destroy(Search $search)
    {
        //ToDo
    }


    public function search(Request $request)
    {
        $content = $request['content'];
        $posts = DB::table('post')
            ->select(
                'post.',
                'post.tsvectors as post_tsvectors',)
            ->selectRaw("*, ts_rank(post.tsvectors, plainto_tsquery('english', '$content')) as rank")
            ->whereRaw("post.tsvectors @@ to_tsquery('english', '$content')")
            ->orderBy('rank', 'DESC')
            ->get();

        return view('search.' . $content, compact('posts'));
    }
}
