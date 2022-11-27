<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Message extends Model
{
    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'message';

    protected $primaryKey = 'message_id';

    protected $fillable = [
        "content", "sender", "receiver"
    ];

    public function sender()
    {
        return $this->belongsTo(User::class, "sender");
    }

    public function receiver()
    {
        return $this->belongsTo(User::class, "receiver");
    }
}
