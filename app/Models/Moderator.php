<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Notifications\Notifiable;

class Moderator  extends Model
{
    use Notifiable;

    protected $primaryKey = 'moderator_id';
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


    public function user()
    {
        return $this->belongsTo(User::class, 'moderator_id');
    }

    public function assignedBy()
    {
        return $this->belongsTo(Admin::class, 'assigned_by');
    }

}
