@extends('layouts.app')

@section('content')
    <div class="container">
        <div class="d-flex gap-2">
            <!-- user information -->
            <div class="flex-item mx-1" style="min-width:300px">
                <div class="d-flex flex-column gap-2">
                    <!-- image profile -->
                    <div class="row p-2 align-self-center" style="width: 200px; height: 200px;">
                        @if ($user->picture)
                            <img class="rounded-circle img-thumbnail " alt="Profile picture" src="{{ asset('storage/' . $user->picture) }}"
                                 data-holder-rendered="true"/>
                        @else
                            <img class="rounded-circle img-thumbnail" alt="Profile picture" src="{{ asset('images/default.png') }}"
                                 data-holder-rendered="true"/>
                        @endif
                    </div>
                    <!-- data -->
                    <div class="row flex-column gap-5 flex-grow-1 text-center align-items-center border-top p-2">
                        <!-- identification -->
                        <div class="row align-center w-100 h-auto p-2">
                            <div class="fw-bolder">{{ $user->name }}</div>
                            <div class="fst-italic fw-light" style="color: gray"> {{ $user->username }}</div>
                            @if($user->moderator)
                                <div class="fw-light" style="color: lightseagreen;">Moderator</div>
                            @endif
                        </div>
                        <!-- bio -->
                        @if ($user->description)
                            <div class="row w-100 h-auto border rounded-1 p-3" style="height:25%">{{ $user->description }}</div>
                        @endif

                        <!-- actions -->
                        @if (Auth::user() != $user)
                            <div class="row">
                                <div class="d-flex gap-2 h-auto justify-content-around">
                                    <button class="flex-item fw-light h-auto btn btn-primary">{{ __('Follow') }}</button>
                                    <div class="vr"></div>
                                    <button class="flex-item fw-light h-auto btn btn-primary">{{ __('Message') }}</button>
                                </div>
                            </div>
                        @endif
                        <!-- reputation -->
                        <div class="row fw-light">
                            <div>{{ __('Reputation') }}</div>
                            <div class="fs-3">{{ $user->reputation }}</div>
                        </div>
                        <!-- time being member -->
                        <div class="row fw-light">
                            <div style="font-size:75%">Member since {{ Carbon::parse($user->created_at)->format('d-m-Y') }}</div>
                        </div>


                        <!-- Moderator actions -->
                        @if (Auth::user()->moderator)
                            <h3>
                                MODERATOR ACTIONS
                            </h3>

                            <div class="row">
                                <div class="d-flex gap-2 h-auto justify-content-around">
                                    <form action="{{ route('users.extendTimeout', $user->id) }}" method="post">
                                        @method('PATCH')
                                        @csrf
                                        <button class="flex-item fw-light h-auto btn btn-danger" href="UserController@extendTimeout">
                                            {{ __('Timeout') }}
                                        </button>
                                    </form>
                                </div>
                            </div>

                            <div>
                                Timeout = {{$user->end_timeout}}
                            </div>
                        @endif
                    </div>
                </div>
            </div>

            <div class="flex-item flex-column flex-grow-1 mx-1 gap-2">
                <div class="row border-top border-1 m-3">
                    <div class="d-flex gap-2 d-flex justify-content-evenly">
                        <div class="flex-item ml-3 border-top border-secondary">
                            <div class="fw-light p-2">{{ __('Posts') }}</div>
                        </div>
                        <div class="flex-item ml-3">
                            <div class="fw-light p-2">{{ __('Saved Posts')}}</div>
                        </div>
                    </div>

                </div>
                <div class="row flex-grow-1 m-3">
                    <!-- card -->
                    @foreach($user->posts as $post)
                        <x-post-preview :post="$post"/>
                    @endforeach
                </div>
            </div>
        </div>

    </div>
@endsection
