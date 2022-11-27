<div class="container m-2">
    <div class="card d-flex flex-row">

        <!-- Votes -->
        <div class="d-flex flex-column justify-content-center text-center p-4">
            <div>
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-arrow-up-circle-fill align-self-center" viewBox="0 0 16 16">
                    <path d="M16 8A8 8 0 1 0 0 8a8 8 0 0 0 16 0zm-7.5 3.5a.5.5 0 0 1-1 0V5.707L5.354 7.854a.5.5 0 1 1-.708-.708l3-3a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1-.708.708L8.5 5.707V11.5z"/>
                </svg>
            </div>
            <div class="mt-1">{{ $post->votes }}</div>
            <div>
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-arrow-down-circle-fill" viewBox="0 0 16 16">
                    <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM8.5 4.5a.5.5 0 0 0-1 0v5.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V4.5z"/>
                </svg>
            </div>
        </div>

        <!--Post owner -->
        <div class="d-flex flex-column text-center p-2">

        </div>

        <!--Post itself -->
        <div class="flex-fill">
            <div class="d-flex flex-row">
                <div class="flex-grow-1">
                    <div class="card-body">
                        <a href="{{ url('posts/' . $post->id) }}" style="text-decoration:none; color: black;">
                            <h3 class="card-title">{{ $post->title }}</h3>
                        </a>
                        <p class="card-text">{{ $post->content }}</p>
                        <p class="card-text">
                        </p>
                    </div>
                    @if ($post->media)
                        <img src="{{ asset('storage/' . $post->media) }}" class="img-fluid p-2" alt="Post's media" style="width: 10rem; height: 10rem;">
                    @endif
                </div>
            </div>
        </div>

    </div>
    <!-- Nothing in life is to be feared, it is only to be understood. Now is the time to understand more, so that we may fear less. - Marie Curie -->
</div>
