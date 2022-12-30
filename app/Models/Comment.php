<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'comment';

    protected $primaryKey = 'comment_id';

    protected $fillable = [
        "content", "user_id", "post_id", "parent_comment"
    ];


    public function post()
    {
        return $this->belongsTo(Post::class, 'post_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function parentComment()
    {
        return $this->belongsTo(Comment::class, "parent_comment");
    }

    public function replies()
    {
        return $this->hasMany(Comment::class, "comment");
    }

    //UPVoteMissing


}
