<?php

namespace App\Models;

class Tag extends Model
{

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'tag';

    protected $fillable = [
        "name", "description"
    ];

    public function madeBy()
    {
        return $this->belongsTo(User::class, "user_id");
    }

}
