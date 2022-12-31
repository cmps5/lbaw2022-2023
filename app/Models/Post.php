<?php


namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'post';

    protected $primaryKey = 'post_id';

    protected $fillable = [
        'title',
        'content',
        'media',
        'status'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function scopeSearch($query, $search)
    {
        if (!$search) {
            return $query;
        }

        return $query
            ->orderByRaw('ts_rank(tsvectors, to_tsquery(\'english\', ?)) DESC', [$search]);
    }
    public function comments()
    {
        return $this->hasMany(Comment::class, "post_id")->orderBy('post_id');
    }


    public function tags()
    {
        return $this->hasMany(Tags::class);
    }

}
