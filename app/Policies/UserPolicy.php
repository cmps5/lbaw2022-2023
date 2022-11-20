<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Client;

use Illuminate\Auth\Access\HandlesAuthorization;

class UserPolicy
{
    use HandlesAuthorization;

    public function update(User $userRequesting, User $UserToChange)
    {
        // Only the user can update his information
        return $userRequesting->id == $UserToChange->id;
    }

    public function deleteByUser(User $userRequesting, User $UserToChange)
    {
        // Only the user can delete his account
        return $userRequesting->id == $UserToChange->id;
    }

    public function BanUser(Admin $admin, User $user)
    {
        // Only the admin can ban an account
        return $admin->id == $user->id;
    }

}
