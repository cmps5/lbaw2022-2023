<?php

namespace App\Http\Controllers;

use App\Models\UserVoteComment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redirect;

class UserVoteCommentController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth')->only('upvoteComment', 'downvoteComment');
    }

    public function upvoteComment(request $request){

        if (UserVoteComment::where([['user_id', '=', auth()->user()->user_id], ['comment_id', '=', $request['comment_id']]])->exists()) {
            // vote found

            $vote = UserVoteComment::where([
                ['user_id', '=', auth()->user()->user_id],
                ['comment_id', '=', $request['comment_id']]
            ])->first();

            if($vote['type_of_vote']){
                UserVoteComment::where([
                    ['user_id', '=', auth()->user()->user_id],
                    ['comment_id', '=', $request['comment_id']]
                ])->update([
                    'type_of_vote' => null,
                ]);
            }
            else{
                UserVoteComment::where([
                    ['user_id', '=', auth()->user()->user_id],
                    ['comment_id', '=', $request['comment_id']]
                ])->update([
                    'type_of_vote' => true,
                ]);
            }

            return redirect()->back();
        }

        DB::table('user_vote_comment')->insert([
            'user_id' => auth()->user()->user_id,
            'comment_id'=> $request['comment_id'],
            'type_of_vote' => true
        ]);

        return redirect()->back();
    }

    public function downvoteComment(request $request){

        
        if (UserVoteComment::where([['user_id', '=', auth()->user()->user_id], ['comment_id', '=', $request['comment_id']]])->exists()) {
            // vote found

            $vote = UserVoteComment::where([
                ['user_id', '=', auth()->user()->user_id],
                ['comment_id', '=', $request['comment_id']]
            ])->first();

            if($vote['type_of_vote']){
                UserVoteComment::where([
                    ['user_id', '=', auth()->user()->user_id],
                    ['comment_id', '=', $request['comment_id']]
                ])->update([
                    'type_of_vote' => null,
                ]);
            }
            else{
                UserVoteComment::where([
                    ['user_id', '=', auth()->user()->user_id],
                    ['comment_id', '=', $request['comment_id']]
                ])->update([
                    'type_of_vote' => false,
                ]);
            }

            return redirect()->back();
        }

        DB::table('user_vote_comment')->insert([
            'user_id' => auth()->user()->user_id,
            'comment_id'=> $request['comment_id'],
            'type_of_vote' => false
        ]);

        return redirect()->back();
    }
}
