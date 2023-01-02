<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class FollowTagController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth')->only('store', 'create');
    }

}
