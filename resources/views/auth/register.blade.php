@extends('layouts.app')

@section('content')
<div class="container d-flex flex-row justify-content-around align-items-center"
     style="margin: 0 auto; width: 50%;">

    <div class="flex-item">
        <h1 class="fs-1 fw-bolder">Register</h1>
        <p class="fs-5">Join Eat&Peas today!</p>


        <form method="POST" enctype="multipart/form-data" action="{{ route('register') }}">
            @csrf

            <div class="form-floating mb-3">
                <input class="form-control @error('name') is-invalid @enderror" id="name" type="text" autocomplete="name"
                   placeholder="Type your name" name="name" value="{{ old('name') }}" required autofocus>
                @error('name')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
                <label for="name" class="fw-bold form-label">{{ __('Name') }}</label>
            </div>

            <div class="form-floating mb-3">
                <input class="form-control @error('username') is-invalid @enderror" id="username" type="text" autocomplete="username"
                       placeholder="Type your username" name="username" value="{{ old('username') }}" required>
                @error('username')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
                <label for="username" class="fw-bold form-label">{{ __('Username') }}</label>
            </div>

            <div class="form-floating mb-3">
                <input class="form-control @error('email') is-invalid @enderror" id="email" type="email" autocomplete="email"
                       placeholder="Type your e-mail address" name="email" value="{{ old('email') }}" required>
                @error('email')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
                <label for="email" class="fw-bold form-label">{{ __('E-Mail Address') }}</label>
            </div>


            <div class="form-floating mb-3">
                <textarea class="form-control @error('description') is-invalid @enderror" id="description" name="description"
                          placeholder="Give the others a brief about you!" style="height: 8rem; resize: none;"></textarea>
                @error('description')
                <span class="is-invalid" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
                <label for="description" class="fw-bold form-label">{{ __('Description') }}</label>
            </div>

            <div class="mb-3">
                <label for="picture" class="fw-bold form-label">{{ __('Profile Picture') }}</label>
                <input class="form-control @error('picture') is-invalid @enderror" id="picture" type="file"
                       placeholder="Choose a profile picture" name="picture" value="{{ old('picture') }}">
                @error('picture')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
            </div>

            <div class="form-floating mb-3">
                <input class="form-control @error('password') is-invalid @enderror"
                       id="password" type="password" autocomplete="new-password" name="password"
                       placeholder="Type your password" value="{{ old('password') }}" required>
                @error('password')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
                <label for="password" class="fw-bold form-label">{{ __('Password') }}</label>
            </div>

            <div class="form-floating mb-3">
                <input class="form-control" id="password_confirmation" type="password" autocomplete="new-password"
                       placeholder="Type your password, again" name="password_confirmation" value="{{ old('password') }}" required>
                <label for="password_confirmation" class="fw-bold form-label">{{ __('Confirm Password') }}</label>
            </div>

            <button type="submit" class="btn btn-success">{{ __('Register') }}</button>
        </form>
    </div>

    <div class="flex-item d-flex flex-column align-items-center">
        <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" fill="currentColor" class="bi bi-person-square" viewBox="0 0 16 16">
            <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/>
            <path d="M2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2zm12 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1v-1c0-1-1-4-6-4s-6 3-6 4v1a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12z"/>
        </svg>
        <p class="fs-5 fw-bold mb-2">Already have an account?</p>
        <a class="btn btn-primary" href="{{ route('login') }}">{{ __('Login') }}</a>
    </div>

</div>
@endsection
