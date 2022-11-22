<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserVotePost extends Model
{

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'user_vote_post';

    protected $fillable = [
        "user_id", "post_id", "type_of_vote"
    ];


    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function tag()
    {
        return $this->belongsTo(Post::class, 'post_id');
    }
}
