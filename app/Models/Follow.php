<?php


namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Follow extends Model
{

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'follow';

    protected $fillable = [
        "follower", "followed"
    ];

    public function follower()
    {
        return $this->belongsTo(User::class, "follower");
    }

    public function followed()
    {
        return $this->belongsTo(User::class, "followed");
    }
}
