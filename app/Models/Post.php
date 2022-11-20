<?php


namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Follow extends Model
{

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'comment';

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

}
