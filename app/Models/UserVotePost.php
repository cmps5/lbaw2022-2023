<?php

namespace App\Models;

class UserVotePost
{

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'user_vote_post';

    protected $fillable = [
        "blocker", "blocked"
    ];


}
