@extends('layouts.app')

@section('content')
    <div class="container" style="margin: 0 auto; width: 50%">

        <h1 class="fs-1 fw-bolder">Change Password</h1>
        <p class="fs-5">Please, type your old password and your new password.</p>

        <form method="POST" action="{{ route('users.commitChangePassword') }}">
            @csrf
            @method('PATCH')

            <div class="form-floating mb-3">
                <input class="form-control @error('old') is-invalid @enderror" id="old-password" type="password" value="{{ old('old-password') }}"
                       autocomplete="current-password" placeholder="Type your current password" name="old-password" required>
                <label for="old-password" class="fw-bold form-label">Current Password</label>
                @error('old')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
            </div>

            <div class="form-floating mb-2">
                <input class="form-control @error('new') is-invalid @enderror" id="password" type="password" value="{{ old('password') }}"
                       autocomplete="new-password" placeholder="Type your new password" name="password" required>
                <label for="password" class="fw-bold form-label">New Password</label>
                @error('new')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
            </div>

            <div class="form-floating mb-4">
                <input class="form-control" id="password_confirmation" type="password" autocomplete="new-password"
                       placeholder="Type your new password again" name="password_confirmation" required>
                <label for="password_confirmation" class="fw-bold form-label">Confirm the New Password</label>
            </div>

            <button type="submit" class="btn btn-primary">Change Password</button>
        </form>
    </div>
@endsection
