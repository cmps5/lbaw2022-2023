@extends('layouts.app')

@section('content')
    <div class="container">


        @error('destroy')
        <div class="alert alert-danger" role="alert">{{ $message }}</div>
        @enderror

        <!-- Moderator actions on post -->
        @if(@isset(Auth()->user()->moderator))
            <div class="card d-flex p-2 fs-4 mb-3">
                Post current status: {{$post->status}}


                <div class="accordion my-2">
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="changeStatus">
                            <button class="accordion-button collapsed" type="button"
                                    data-bs-toggle="collapse" data-bs-target="#collapse-changeStatus"
                                    aria-expanded="false" aria-controls="collapse-changeStatus">
                                Change Post Status
                            </button>
                        </h2>
                        <div class="accordion-collapse collapse" id="collapse-changeStatus"
                             aria-labelledby="changeStatus" data-bs-parent="#help">
                            <div class="accordion-body d-flex flex-row gap-2">

                                <form enctype="multipart/form-data" id="closePost" action="{{ route('posts.openPost', $post->post_id) }}"
                                      method="POST">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="btn btn-primary">
                                        open
                                    </button>
                                </form>

                                <form enctype="multipart/form-data" id="closePost" action="{{ route('posts.closePost', $post->post_id) }}"
                                      method="POST">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="btn btn-success">
                                        close
                                    </button>
                                </form>

                                <form enctype="multipart/form-data" id="closePost" action="{{ route('posts.hidePost', $post->post_id) }}"
                                      method="POST">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="btn btn-warning">
                                        hide
                                    </button>
                                </form>

                                <form enctype="multipart/form-data" id="closePost" action="{{ route('posts.deletePost', $post->post_id) }}"
                                      method="POST">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="btn btn-danger">
                                        delete
                                    </button>
                                </form>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        @endif
        <!-- Post Card -->
        @if($post->status == 'open' || $post->status == 'closed' || @isset(Auth()->user()->moderator)  ||
            ($post->status == 'hidden' && @isset(Auth()->user()->id) == $post->user->id))

            <div class="card d-flex flex-row">

                <!--Post itself -->
                <div class="flex-fill">
                    <div class="d-flex flex-row">
                        <div class="flex-grow-1">
                            <div class="card-body">
                                <h3 class="card-title d-flex flex-row justify-content-between">{{ $post->title }}
                                    @auth
                                        @if (Auth::user()->id == $post->user->id)
                                            <div class="d-inline-flex gap-2 flex-item">
                                                <form action="{{ route('posts.edit', $post) }}" method="POST">
                                                    @method('GET')
                                                    @csrf
                                                    <button type="submit" href="{{ route('posts.edit', $post) }}"
                                                            class="btn btn-primary btn-sm">Edit Post</button>
                                                </form>
                                                <form action="{{ route('posts.destroy', $post) }}" method="POST">
                                                    @method('DELETE')
                                                    @csrf
                                                    <button type="submit" class="btn btn-danger btn-sm">Delete Post</button>
                                                </form>
                                            </div>
                                        @endif
                                    @endauth
                                </h3>
                                <p class="card-text">{{ $post->content }}</p>


                                <!-- Reply and/or report -->
                                <p class="d-flex flex-row my-2">

                                <div class="dropdown">
                                    <a class="btn navbar-toggler" type="button" data-bs-toggle="dropdown" aria-expanded="false"
                                       aria-expanded="false">

                                        <!-- Comment icon -->
                                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor"
                                             class="bi bi-chat me-3" viewBox="0 0 16 16">
                                            <path
                                                d="M2.678 11.894a1 1 0 0 1 .287.801 10.97 10.97 0 0 1-.398 2c1.395-.323 2.247-.697 2.634-.893a1 1 0 0 1 .71-.074A8.06 8.06 0 0 0 8 14c3.996 0 7-2.807 7-6 0-3.192-3.004-6-7-6S1 4.808 1 8c0 1.468.617 2.83 1.678 3.894zm-.493 3.905a21.682 21.682 0 0 1-.713.129c-.2.032-.352-.176-.273-.362a9.68 9.68 0 0 0 .244-.637l.003-.01c.248-.72.45-1.548.524-2.319C.743 11.37 0 9.76 0 8c0-3.866 3.582-7 8-7s8 3.134 8 7-3.582 7-8 7a9.06 9.06 0 0 1-2.347-.306c-.52.263-1.639.742-3.468 1.105z" />
                                        </svg>
                                    </a>


                                    <div class="dropdown-menu" style="width: 30rem;" aria-labelledby="comment">
                                        <form enctype="multipart/form-data" method="post"
                                              action="{{ route('comments.store') }}">
                                            @csrf

                                            <!-- Content -->
                                            <div class="form-floating mb-2">
                                                <textarea class="form-control mx-2" id="comment-content"
                                                          placeholder="Post Content" name="content"
                                                          style="height: 5rem; width: 29rem;"></textarea>
                                                <label for="comment-content" class="form-label fw-bold">Comment</label>
                                            </div>
                                            <input name="post_id" value="{{ $post->post_id }}" hidden />
                                            <button type="submit" class="btn btn-primary mx-3">Leave a comment</button>
                                        </form>
                                    </div>


                                </div>
                                <div class="dropdown ">
                                    <a class="btn navbar-toggler" type="button" data-bs-toggle="dropdown" aria-expanded="false"
                                       aria-expanded="false">
                                        <!-- Report icon -->
                                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor"
                                             class="bi bi-flag" viewBox="0 0 16 16">
                                            <path
                                                d="M14.778.085A.5.5 0 0 1 15 .5V8a.5.5 0 0 1-.314.464L14.5 8l.186.464-.003.001-.006.003-.023.009a12.435 12.435 0 0 1-.397.15c-.264.095-.631.223-1.047.35-.816.252-1.879.523-2.71.523-.847 0-1.548-.28-2.158-.525l-.028-.01C7.68 8.71 7.14 8.5 6.5 8.5c-.7 0-1.638.23-2.437.477A19.626 19.626 0 0 0 3 9.342V15.5a.5.5 0 0 1-1 0V.5a.5.5 0 0 1 1 0v.282c.226-.079.496-.17.79-.26C4.606.272 5.67 0 6.5 0c.84 0 1.524.277 2.121.519l.043.018C9.286.788 9.828 1 10.5 1c.7 0 1.638-.23 2.437-.477a19.587 19.587 0 0 0 1.349-.476l.019-.007.004-.002h.001M14 1.221c-.22.078-.48.167-.766.255-.81.252-1.872.523-2.734.523-.886 0-1.592-.286-2.203-.534l-.008-.003C7.662 1.21 7.139 1 6.5 1c-.669 0-1.606.229-2.415.478A21.294 21.294 0 0 0 3 1.845v6.433c.22-.078.48-.167.766-.255C4.576 7.77 5.638 7.5 6.5 7.5c.847 0 1.548.28 2.158.525l.028.01C9.32 8.29 9.86 8.5 10.5 8.5c.668 0 1.606-.229 2.415-.478A21.317 21.317 0 0 0 14 7.655V1.222z" />
                                        </svg>
                                    </a>

                                    <div class="dropdown-menu" style="width: 30rem;" aria-labelledby="report">
                                        <form enctype="multipart/form-data" method="POST"
                                              action="{{ route('reports.store') }}">
                                            @csrf

                                            <!-- Content -->
                                            <div class="form-floating mb-2">
                                                <textarea class="form-control mx-2" id="report-content"
                                                          placeholder="Report Content" name="content"
                                                          style="height: 5rem; width: 29rem;"></textarea>
                                                <label for="report-content" class="form-label fw-bold">Report</label>
                                            </div>
                                            <button type="submit" class="btn btn-primary mx-3">Leave a report</button>
                                        </form>
                                    </div>
                                </div>
                                </p>

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
                    <div><a href="{{ route('upvotePost') }}"
                            onclick="event.preventDefault(); document.getElementById('upvotePost').submit();">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor"
                                 class="bi bi-arrow-up-circle-fill align-self-center" viewBox="0 0 16 16">
                                <path
                                    d="M16 8A8 8 0 1 0 0 8a8 8 0 0 0 16 0zm-7.5 3.5a.5.5 0 0 1-1 0V5.707L5.354 7.854a.5.5 0 1 1-.708-.708l3-3a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1-.708.708L8.5 5.707V11.5z" />
                            </svg></a>
                    </div>
                    <form enctype="multipart/form-data" id="upvotePost" action="{{ route('upvotePost') }}" method="POST"
                          class="d-none">
                        @csrf
                        <input name="post_id" value="{{ $post->post_id }}" hidden />
                    </form>

                    <div class="mt-1">{{ $post->votes }}</div>

                    <div><a href="{{ route('downvotePost') }}"
                            onclick="event.preventDefault(); document.getElementById('downvotePost').submit();">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor"
                                 class="bi bi-arrow-down-circle-fill" viewBox="0 0 16 16">
                                <path
                                    d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM8.5 4.5a.5.5 0 0 0-1 0v5.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V4.5z" />
                            </svg></a>
                    </div>
                    <form enctype="multipart/form-data" id="downvotePost" action="{{ route('downvotePost') }}" method="POST"
                          class="d-none">
                        @csrf
                        <input name="post_id" value="{{ $post->post_id }}" hidden />
                    </form>
                </div>
            </div>

            <!-- Comments -->
            @isset($post->comments)
                @foreach ($post->comments as $comment)
                    @if (!$comment->parent)
                        <div class="ms-5 mt-3">
                            <x-comment :comment="$comment" />
                        </div>
                    @endif
                @endforeach
            @endisset

        @else

            <div class="card d-flex p-2 fs-4 mb-3">
                This post is currently {{ $post->status }} <br>
                <p>For more information <a href="{{ route('contacts') }}" target="_blank">contact the moderators</a></p>
            </div>

       @endif
    </div>
@endsection
