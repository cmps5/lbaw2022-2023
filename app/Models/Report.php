<?php

namespace App\Models;

class Report
{
    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'user_vote_post';

    protected $fillable = [
        "content", "reviewer", "reporter", "reported_user", "reported_post", "reported_comment"
    ];



}
