<?php


namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PostTag extends Model
{

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'post_tag';

    protected $fillable = [
        "post_id", "tag_id"
    ];


    public function Post()
    {
        return $this->belongsTo(Post::class, 'post_id');
    }

    public function Tag()
    {
        return $this->belongsTo(Tag::class, 'tag_id');
    }

}
