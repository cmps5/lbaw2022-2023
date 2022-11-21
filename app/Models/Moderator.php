<?php

namespace App\Models;

use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

class Moderator extends Authenticatable
{
    use Notifiable;

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'moderator';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        "moderator_id", "assigned_by"
    ];


    public function User()
    {
        return $this->belongsTo(User::class, 'moderator_id');
    }

    public function AssignedBy()
    {
        return $this->belongsTo(Admin::class, 'assigned_by');
    }

}
