<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Providers\RouteServiceProvider;
use Illuminate\Support\Facades\Redirect;


class UserController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth')->except('show');
    }


    public function show($id)
    {
        $user = User::find($id);
        return view('user.show', compact('user'));
    }


    public function edit($id)
    {
        $user = User::find($id);
        return view('user.edit', compact('user'));
    }

    public function destroy($id)
    {
        User::where('id', $id)->delete();

        return Redirect::to(RouteServiceProvider::HOME, 200);
    }
}