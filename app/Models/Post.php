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
        "post_id",
        "title",
        "content",
        "media",
        "media_type",
        "user_id"
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



}
