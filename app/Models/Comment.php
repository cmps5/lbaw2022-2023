<?php

namespace App\Models;

class Comment extends Model
{
    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'comment';

    protected $fillable = [
        "content", "user_id", "post_id", "parent_comment"
    ];


    public function Post()
    {
        return $this->belongsTo(Post::class, 'post_id');
    }

    public function User()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function parentComment()
    {
        return $this->belongsTo(Comment::class, "parent_comment");
    }

}
