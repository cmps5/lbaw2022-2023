<?php

namespace App\Models;

use Illuminate\Auth\Passwords\CanResetPassword;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\DB;

class User extends Authenticatable
{
    use HasFactory;
    use Notifiable;
    use CanResetPassword;

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'users';

    protected $primaryKey = 'user_id';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'user_id',
        'name',
        'username',
        'email',
        'bio',
        'picture',
        'password',
        'end_timeout',
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token'
    ];

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

    public function tags()
    {
        $tags = $this->belongsToMany(Tag::class, "users_follows_on_tags")->get();

        return $tags;
    }
    public function votes_on_posts()
    {
        return $this->hasMany(Users_votes_on_post::class);
    }

    public function votes_on_comments()
    {
        return $this->hasMany(Users_votes_on_comment::class);
    }


    public function comments(){
        return $this->hasMany(Comment::class);
    }

    public function followers()
    {
        $followers = $this->belongsToMany(User::class, 'follows', 'followed', "follower")->get();
        return $followers;
    }

    public function following()
    {
        return $this->belongsToMany(User::class, "follows", "follower", "followed")->get();
    }

    public function blocking()
    {
        $blocking = $this->belongsToMany(User::class, "blocks", "blocker", "blocked")->get();
        //dd($blocking);
        return $blocking;
    }

    public function reports()
    {
        return $this->hasMany(Report::class, 'reporter');
    }
    public function notifications(){
        return $this->hasMany(Notification::class)->orderByDesc('created_at');
    }
}
