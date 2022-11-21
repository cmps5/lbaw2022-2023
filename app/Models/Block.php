<?php

namespace App\Models;

class block
{
    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'user_vote_post';

    protected $fillable = [
        "user_id", "post_id", "type_of_vote"
    ];



}
