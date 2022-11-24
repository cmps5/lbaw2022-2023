@extends('layouts.app')

@section('content')
<div class="container"
     style="margin: 0 auto; width: 25%; height: 25%">

    <h1 class="fs-1 fw-bolder">Login</h1>
    <p class="fs-5">Don't miss on the news today!</p>
    @if (session('error'))
        <div class="alert alert-danger">
            {{ session('error') }}
        </div>
    @endif
    <form method="POST" action="{{ route('login') }}">
        @csrf
        <div class="form-floating mb-3">
            <input class="form-control @error('email') is-invalid @enderror" id="email" type="email" autocomplete="email"
                   placeholder="Type your e-mail address" name="email" required autofocus>
            <label for="email" class="fw-bold form-label">E-mail</label>
            @error('email')
            <span class="invalid-feedback" role="alert">
                <strong>{{ $message }}</strong>
            </span>
            @enderror
        </div>

        <div class="form-floating mb-2">
            <input class="form-control @error('password') is-invalid @enderror" id="password" type="password"
                   autocomplete="current-password" placeholder="Type your password" name="password" required>
            <label for="password" class="fw-bold form-label">Password</label>
            @error('Password')
            <span class="invalid-feedback" role="alert">
                <strong>{{ $message }}</strong>
            </span>
            @enderror
        </div>

        <div class="form-check form-switch flex-item mb-3">
            <input class="form-check-input" type="checkbox" id="remember" name="remember" {{ old('remember') ? 'checked' : '' }}>
            <label class="form-check-label" for="remember">{{ __('Remember me') }}</label>
        </div>

        <div class="flex-item">
            <button type="submit" class="btn btn-success">{{ __('Login') }}</button>
            @if (Route::has('password.request'))
                <a class="btn btn-link" href="{{ route('password.request') }}">
                    {{ __('Forgot Your Password?') }}
                </a>
            @endif
            <p class="fs-5 fw-bold mt-4 mb-1">Don't have an account yet?</p>
            <a class="btn btn-primary" href="{{ route('register') }}">Register</a>
        </div>
    </form>

</div>
@endsection
