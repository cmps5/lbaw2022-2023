@extends('layouts.app')

@section('content')
    <div class="container">
        <div class="card d-flex flex-row">
            <!--Post itself -->
            <div class="flex-fill">
                <div class="d-flex flex-row">
                    <div class="flex-grow-1">
                        <div class="card-body">
                            <h3 class="card-title">{{ $post->title }}
                                @if (Auth::user() != null && Auth::user()->id == $post->user->id)
                                    <div class="d-flex">

                                        <form action="{{ route('posts.edit', $post) }}" method="POST">
                                            @method('GET')
                                            @csrf
                                            <button type="submit" href="{{ route('posts.edit', $post) }}" class="btn btn-link fs-5">[Edit]</button>
                                        </form>

                                        <form action="{{ route('posts.destroy', $post) }}" method="POST">
                                            @method('DELETE')
                                            @csrf
                                            <button type="submit" class="btn btn-link fs-5">[Delete]</button>
                                        </form>
                                    </div>
                                @endif
                            </h3>
                            <p class="card-text">{{ $post->content }}</p>
                            <p class="card-text">
                                <small class="text-muted">
                                    Created {{ Carbon::parse($post->created_at)->diffForHumans() }}.
                                    @if ($post->created_at != $post->updated_at)
                                        Last updated {{ Carbon::parse($post->updated_at)->diffForHumans() }}
                                    @endif
                                </small>
                            </p>
                        </div>
                    </div>

                    @if ($post->media)
                        <div>
                            <img src="{{ asset('storage/' . $post->media) }}" class="img-fluid m-3"
                                 style="width: 15rem; height: 15rem;">
                        </div>
                    @endif
                </div>
            </div>

            <!--Post owner -->
            <div class="d-flex col-md-1 text-center p-2 flex-column justify-content-center">
                @if($post->user->picture)
                    <img src="{{ asset('storage/' . $post->user->picture) }}" class="align-self-center rounded-circle"
                         width="40" height="40" />
                @else
                    <img src="{{ url('images/default.png') }}" alt="Post author profile picture"
                         class="align-self-center rounded-circle" width="40" height="40"/>
                @endif
                <small>{{ $post->user->username }}</small>
            </div>

            <!-- Votes -->
            <div class="d-flex flex-column justify-content-center text-center p-4">
                <div>
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor"
                         class="bi bi-arrow-up-circle-fill align-self-center" viewBox="0 0 16 16">
                        <path
                            d="M16 8A8 8 0 1 0 0 8a8 8 0 0 0 16 0zm-7.5 3.5a.5.5 0 0 1-1 0V5.707L5.354 7.854a.5.5 0 1 1-.708-.708l3-3a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1-.708.708L8.5 5.707V11.5z" />
                    </svg>
                </div>
                <div class="mt-1">{{ $post->votes }}</div>
                <div>
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor"
                         class="bi bi-arrow-down-circle-fill" viewBox="0 0 16 16">
                        <path
                            d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM8.5 4.5a.5.5 0 0 0-1 0v5.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V4.5z" />
                    </svg>
                </div>
            </div>
            <div class="flex-fill">
                <div class="d-flex flex-row">
                    <div class="flex-grow-1">
                        <div class="card-body">
                            <h3 class="card-title">{{ $post->title }}
                                @auth()
                                    @if (Auth::user()->id == $post->user->id)
                                        <div class="d-flex">

                                            <form action="{{ route('posts.edit', $post) }}" method="POST">
                                                @method('GET')
                                                @csrf
                                                <button type="submit" href="{{ route('posts.edit', $post) }}" class="btn btn-link fs-5">[Edit]</button>
                                            </form>

                                            <form action="{{ route('posts.destroy', $post) }}" method="POST">
                                                @method('DELETE')
                                                @csrf
                                                <button type="submit" class="btn btn-link fs-5">[Delete]</button>
                                            </form>
                                        </div>
                                    @endif
                                @endauth
                            </h3>
                            <p class="card-text">{{ $post->content }}</p>
                            <p class="card-text">
                                <small class="text-muted">
                                    Created {{ Carbon::parse($post->created_at)->diffForHumans() }}.
                                    @if ($post->created_at != $post->updated_at)
                                        Last updated {{ Carbon::parse($post->updated_at)->diffForHumans() }}
                                    @endif
                                </small>
                            </p>
                        </div>
                    </div>

                    @if ($post->media)
                        <div>
                            <img src="{{ asset('storage/' . $post->media) }}" class="img-fluid m-3"
                                 style="width: 15rem; height: 15rem;">
                        </div>
                    @endif
                </div>
            </div>

        </div>
    </div>
@endsection
