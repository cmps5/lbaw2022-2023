<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'report';

    protected $primaryKey = 'report_id';

    protected $fillable = [
        "content", "reviewer", "reporter", "reported_user", "reported_post", "reported_comment"
    ];

    public function post()
    {
        return $this->belongsTo(Post::class, 'reported_post');
    }

    public function comment()
    {
        return $this->belongsTo(Comment::class, 'reported_comment');
    }

    public function reportedUser()
    {
        return $this->belongsTo(User::class, 'reported_user');
    }

    public function reviewer()
    {
        return $this->belongsTo(Moderator::class, 'reviewer');
    }

}
