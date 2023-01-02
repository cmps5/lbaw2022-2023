<?php

namespace App\Http\Controllers;

use App\Models\Comment;
use App\Models\Post;
use App\Providers\RouteServiceProvider;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redirect;

class CommentController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth')->only('store', 'create');
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $request->validate([
            'content' => ['required', 'string'],
        ]);

        //da imensos erros de outra forma
        DB::table('comments')->insert([
            'content' => $request['content'],
            'post_id' => $request['post_id'],
            'parent' => $request['parent'],
            'user_id' => auth()->user()->id,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Redirect('/posts/' . $request['post_id'],201);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Comment  $comment
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $comment = Comment::find($id);
        Comment::where('id', $id)->update([
            'content' => $request['content'],
        ]);
        return Redirect::to('/posts/' . $comment->post->id);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy($id)
    {
        $post = Comment::findOrFail($id)->post;

        try {
            Comment::destroy($id);
        } catch (QueryException $exception) {
            return Redirect::back()->withErrors(['destroy' => 'Your request cannot be satisfied at the moment.']);
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
        $comment = Comment::findOrFail($id);
        return view('posts.comments.edit', compact('comment'));
    }
}
