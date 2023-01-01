<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Providers\RouteServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Validation\Rule;


class UserController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth')->except('show');
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\View
     */
    public function show($id)
    {
        $user = User::findOrFail($id);
        return view('user.show', compact('user'));
    }

    /**
     * Displays the interface to edit a specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\View
     */
    public function edit($id)
    {
        $user = User::find($id);
        return view('user.edit', compact('user'));
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'username' => ['required', 'string', 'max:255', Rule::unique('user')->ignore($id)],
            'email' => ['required', 'email', 'max:255', Rule::unique('user')->ignore($id)],
            'bio' => ['nullable', 'string', 'max:255'],
            'picture' => ['nullable', 'image'],
        ]);

        $user = User::where('id', $id)->first();
        $userPicturePath = 'storage/' . $user->picture;

        if ($request->hasFile('picture'))
        {
            if (File::exists($userPicturePath))
            {
                File::delete($userPicturePath);
            }
        }

        $user->update([
            'name' => $request['name'],
            'username' => $request['username'],
            'email' => $request['email'],
            'bio' => $request['bio'],
            'media' => $request['picture'] ? $request['picture']->store('profiles', 'public') : null,
        ]);

        return Redirect::to('user/'. $id);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy($id)
    {
        User::find($id)->delete();
        return Redirect::to(RouteServiceProvider::HOME, 303);
    }

    public function requestChangePassword()
    {
        return view('auth.passwords.change');
    }

    public function commitChangePassword(Request $request)
    {
        $request->validate([
            'old-password' => ['required'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $oldPassword = Auth::user()->getAuthPassword();

        if (!Hash::check($request['old-password'], $oldPassword))
            return Redirect::back()->withErrors(['old' => 'Your current password do not match our records.']);

        if (Hash::check($request['password'], $oldPassword))
            return Redirect::back()->withErrors(['new' => 'Your old and new passwords cannot be the same.']);

        $user = User::find(Auth::user()->getAuthIdentifier());
        $user->update([
            'password' => Hash::make($request['password'])
        ]);

        return Redirect::to('users/'. $user->id)->with('success', 'Your password has been changed.');
    }

    public function extendTimeout($id)
    {
        $user = User::find($id);
        $user->update([
            'end_timeout' => now()->addDay(),
        ]);

        return Redirect::to('users/'. $id);
    }

}
