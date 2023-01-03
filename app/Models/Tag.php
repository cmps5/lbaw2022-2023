<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Tag extends Model
{
    use HasFactory;

    protected $table = 'tag';
    protected $primaryKey = 'tag_id';

    protected $fillable = [
        'name',
        'description',
        'tag_id'
    ];

    public function posts()
    {
        return $this->belongsToMany(Post::class, 'post_id');
    }

    public function users()
    {
        return $this->belongsToMany(User::class, 'user_id');
    }


}
