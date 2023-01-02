<?php

namespace App\Http\Controllers;

use App\Models\UserVotePost;
use http\Env\Response;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redirect;

class UserVotePostController extends Controller
{


    public function __construct()
    {
        $this->middleware('auth')->only('upvotePost', 'downvotePost');
    }


    public function upvotePost(request $request){

        if (UserVotePost::where([['user_id', '=', auth()->user()->user_id], ['post_id', '=', $request['post_id']]])->exists()) {

            $vote = UserVotePost::where([
                ['user_id', '=', auth()->user()->user_id],
                ['post_id', '=', $request['post_id']]
            ])->first();

            if($vote['vote']){
                UserVotePost::where([
                    ['user_id', '=', auth()->user()->user_id],
                    ['post_id', '=', $request['post_id']]
                ])->update([
                    'type_of_vote' => null,
                ]);
            }
            else{
                UserVotePost::where([
                    ['user_id', '=', auth()->user()->user_id],
                    ['post_id', '=', $request['post_id']]
                ])->update([
                    'type_of_vote' => true,
                ]);
            }


            return redirect()->back();
        }

        DB::table('user_vote_post')->insert([
            'user_id' => auth()->user()->user_id,
            'post_id'=> $request['post_id'],
            'type_of_vote' => true
        ]);

        return redirect()->back();
    }

    public function downvotePost(request $request){

        if (UserVotePost::where([['user_id', '=', auth()->user()->user_id], ['post_id', '=', $request['post_id']]])->exists()) {

            $vote = UserVotePost::where([
                ['user_id', '=', auth()->user()->user_id],
                ['post_id', '=', $request['post_id']]
            ])->first();

            if($vote['vote']){
                UserVotePost::where([
                    ['user_id', '=', auth()->user()->user_id],
                    ['post_id', '=', $request['post_id']]
                ])->update([
                    'type_of_vote' => null,
                ]);
            }
            else{
                UserVotePost::where([
                    ['user_id', '=', auth()->user()->user_id],
                    ['post_id', '=', $request['post_id']]
                ])->update([
                    'type_of_vote' => false,
                ]);
            }


            return redirect()->back();
        }

        DB::table('user_vote_post')->insert([
            'user_id' => auth()->user()->user_id,
            'post_id'=> $request['post_id'],
            'type_of_vote' => false
        ]);

        return redirect()->back();
    }
}
