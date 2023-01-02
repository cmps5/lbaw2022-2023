<div>
    <!-- It is never too late to be what you might have been. - George Eliot -->

    <div class="d-flex flex-row justify-content-start card p-1">
        <div class="flex-fill m-1" style="width:auto;">
            @if($notification->seen)
                <p class="text-danger">
                    ALREADY SEEN
                </p>
            @endif
            <div class="p-2 text-wrap" style="">
                <a href="{{ route('notification.read', $notification->id) }}" style="text-decoration:none; color: black;">
                    {{$notification->content}}
                    <br>
                    Post's title:
                    <br>
                    <h3>
                        {{$notification->post->title}}
                    </h3>
                    Created {{ Carbon::parse($notification->post->created_at)->diffForHumans() }}
                </a>
            </div>
        </div>

        <div>
            @isset($notification->user)
                <div style="width: 7rem;">
                    <div class="d-flex flex-column gap-2 text-center m-1">
                        <div>
                            <a class="fw-bold link-dark" href="{{ url('users/' . $notification->post->user->id) }}" style="text-decoration: none">
                                <img class="rounded-circle position-sticky img-thumbnail" alt="Profile image"
                                     src="{{ asset('storage/' . $notification->post->user->picture) }}">
                            </a>
                        </div>
                        <div>
                            <a class="fw-bold link-dark text-wrap" href="{{ url('users/' . $notification->post->user->id) }}" style="text-decoration: none">
                                {{$notification->post->user->name}}
                            </a>
                            <br>
                            <span class="fw-thin text-secondary">{{$notification->post->user->username}}</span>

                        </div>
                    </div>

                    <!-- It is quality rather than quantity that matters. - Lucius Annaeus Seneca -->
                </div>
            @endisset
        </div>
    </div>
</div>
