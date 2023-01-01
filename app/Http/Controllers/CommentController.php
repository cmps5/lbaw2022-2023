<?php

namespace App\Http\Controllers;

use App\Models\Comment;
use App\Models\Post;
use App\Providers\RouteServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\Facades\DB;

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
            'parent_comment' => $request['parent'],
            'user_id' => auth()->user()->user_id,
            'time_posted' => now()
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
        Comment::where('comment_id', $id)->update([
            'content' => $request['content'],
        ]);
        return Redirect::to('/posts/' . $comment->post->post_id);
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
        return view('posts.comment.edit', compact('comment'));
    }
}
