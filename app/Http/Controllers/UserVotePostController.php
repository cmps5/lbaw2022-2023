<?php

namespace App\Http\Controllers;

use App\Models\Users_votes_on_post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redirect;

class UserVotePostController extends Controller
{
    public function upvotePost(request $request){

        if (Users_votes_on_post::where([['user_id', '=', auth()->user()->id], ['post_id', '=', $request['post_id']]])->exists()) {
            // vote found

            $vote = Users_votes_on_post::where([
                ['user_id', '=', auth()->user()->id],
                ['post_id', '=', $request['post_id']]
            ])->first();

            //dd($vote);
            if($vote['vote']){
                Users_votes_on_post::where([
                    ['user_id', '=', auth()->user()->id],
                    ['post_id', '=', $request['post_id']]
                ])->update([
                    'vote' => null,
                ]);
            }
            else{
                Users_votes_on_post::where([
                    ['user_id', '=', auth()->user()->id],
                    ['post_id', '=', $request['post_id']]
                ])->update([
                    'vote' => true,
                ]);
            }


            return Redirect::to('/posts/' . $request['post_id']);
        }

        DB::table('users_votes_on_posts')->insert([
            'user_id' => auth()->user()->id,
            'post_id'=> $request['post_id'],
            'vote' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Redirect::to('/posts/' . $request['post_id']);
    }

    public function downvotePost(request $request){

        if (Users_votes_on_post::where([['user_id', '=', auth()->user()->id], ['post_id', '=', $request['post_id']]])->exists()) {
            // vote found

            $vote = Users_votes_on_post::where([
                ['user_id', '=', auth()->user()->id],
                ['post_id', '=', $request['post_id']]
            ])->first();

            //dd($vote);
            if($vote['vote'] == null){
                Users_votes_on_post::where([
                    ['user_id', '=', auth()->user()->id],
                    ['post_id', '=', $request['post_id']]
                ])->update([
                    'vote' => false,
                ]);
            }
            else{
                Users_votes_on_post::where([
                    ['user_id', '=', auth()->user()->id],
                    ['post_id', '=', $request['post_id']]
                ])->update([
                    'vote' => null,
                ]);
            }


            return Redirect::to('/posts/' . $request['post_id']);
        }

        DB::table('users_votes_on_posts')->insert([
            'user_id' => auth()->user()->id,
            'post_id'=> $request['post_id'],
            'vote' => false,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return Redirect::to('/posts/' . $request['post_id']);
    }
}
