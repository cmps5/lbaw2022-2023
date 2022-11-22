<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class block extends Model
{
    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'block';

    protected $fillable = [
        "blocker", "blocked"
    ];

    public function blocker()
    {
        return $this->belongsTo(User::class, 'blocker');
    }

    public function blocked()
    {
        return $this->belongsTo(User::class, 'blocked');
    }

}
