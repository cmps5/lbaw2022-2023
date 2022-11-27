<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Tag extends Model
{

    // Don't add create and update timestamps in database.
    public $timestamps = false;

    protected $table = 'tag';

    protected $primaryKey = 'tag_id';

    protected $fillable = [
        "name", "description"
    ];

}
