<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserVoteComment extends Model
{
    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'user_vote_comment';

    protected $fillable = [
       "user_id", "comment_id", "type_of_vote"
    ];


    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function comment()
    {
        return $this->belongsTo(Tag::class, 'comment_id');
    }
}
