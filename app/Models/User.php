<?php

namespace App\Models;

use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use Notifiable;

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'user';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        "email",
        "username",
        "name",
        "password",
        "profile_picture",
        "bio" ,
        "birth_date",
        "banned_by"
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password'
    ]; //IN THE FUTURE - REMEMBER TOKEN FOR STAYING LOGGED IN



    public function posts()
    {
        return $this->hasMany(Post::class);
    }

    public function searches()
    {
        return $this->hasMany(Search::class);
    }

    public function moderator()
    {
        return $this->belongsTo(Moderator::class, 'id');
    }


}
