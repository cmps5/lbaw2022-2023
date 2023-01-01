@extends('layouts.app')

@section('content')
    <div class="container d-flex flex-column gap-3" style="width: 50%">
        <form method="POST" enctype="multipart/form-data" action="{{ route('users.update', $user->id) }}" class="flex-item">
            @csrf
            @method('PATCH')

            <div class="form-floating mb-3">
                <input class="form-control @error('name') is-invalid @enderror" id="name" type="text" autocomplete="name"
                       placeholder="Type your name" name="name" value="{{ $user->name }}" required autofocus>
                @error('name')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
                <label for="name" class="fw-bold form-label">{{ __('Name') }}</label>
            </div>

            <div class="form-floating mb-3">
                <input class="form-control @error('username') is-invalid @enderror" id="username" type="text" autocomplete="username"
                       placeholder="Type your username" name="username" value="{{ $user->username }}" required>
                @error('username')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
                <label for="username" class="fw-bold form-label">{{ __('Username') }}</label>
            </div>

            <div class="form-floating mb-3">
                <input class="form-control @error('email') is-invalid @enderror" id="email" type="email" autocomplete="email"
                       placeholder="Type your e-mail address" name="email" value="{{ $user->email }}" required>
                @error('email')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
                <label for="email" class="fw-bold form-label">{{ __('E-Mail Address') }}</label>
            </div>


            <div class="form-floating mb-3">
                <textarea class="form-control @error('description') is-invalid @enderror" id="description" name="description"
                          placeholder="Give the others a brief about you!" style="height: 8rem; resize: none;">{{ $user->description }}</textarea>
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
                       placeholder="Choose a profile picture" name="picture" value="{{ $user->picture }}">
                @error('picture')
                <span class="invalid-feedback" role="alert">
                    <strong>{{ $message }}</strong>
                </span>
                @enderror
            </div>

            <button type="submit" class="btn btn-success">{{ __('Update Account') }}</button>
        </form>
        <form method="POST" action="{{ route('users.delete', $user) }}" class="flex-item">
            @csrf
            @method('DELETE')
            <button type="submit" class="btn btn-danger">{{ __('Delete Account') }}</button>
        </form>
    </div>
@endsection
