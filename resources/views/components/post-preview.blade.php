<div class="card d-flex flex-row">



    <!--Post itself -->
    <div class="flex-fill">
        <div class="d-flex flex-row">
            <div class="flex-grow-1">
                <div class="card-body">
                    <a href="{{ url('posts/' . $post->post_id) }}" style="text-decoration:none; color: black;">
                        <h3 class="card-title">{{ $post->title }}</h3>
                    </a>
                    <p class="card-text">{{ $post->content }}</p>
                    <p class="card-text">
                        <small class="text-muted">
                            Created {{ Carbon::parse($post->time_posted)->diffForHumans() }}
                        </small>
                    </p>
                </div>
                @if ($post->media)
                    <img src="{{ asset('storage/' . $post->media) }}" class="img-fluid p-2" alt="Post's media" style="width: 10rem; height: 10rem;">
                @endif
            </div>


            <p class="card-text">
                @isset($post->tags)
                    @foreach ($post->tags as $tag)
                        <x-tag :tag="$tag" />
                    @endforeach
                @endisset
            </p>
        </div>


    </div>


    <!--Post owner -->
    <div class="d-flex col-md-1 text-center p-2 flex-column justify-content-center" style="width: 12.499999995%">
        @if ($post->user->picture)
            <img src="{{ asset('storage/' . $post->user->picture) }}" alt="Post author profile picture"
                 class="align-self-center rounded-circle" width="40" height="40"/>
        @else
            <img src="{{ url('images/default.png') }}" alt="Post author profile picture"
                 class="align-self-center rounded-circle" width="40" height="40"/>
        @endif
        <p><small>{{ $post->user->username }}</small></p>
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
<br>


