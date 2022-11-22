<?php


namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'post';

    protected $fillable = [
        "title",
        "content",
        "media",
        "media_type",
        "user_id"
    ];

    public function madeBy()
    {
        return $this->belongsTo(User::class, "user_id");
    }

    public function comments()
    {
        return $this->hasMany(Comment::class, "id");
    }

}
