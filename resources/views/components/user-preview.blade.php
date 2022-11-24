<div style="width: 8rem; height: 16rem;">
    <div class="d-flex flex-column gap-2 text-center">
        <div>
            <a class="fw-bold link-dark" href="{{ url('users/' . $user->id) }}" style="text-decoration: none">
                <img class="rounded-circle position-sticky img-thumbnail" alt="Profile image"
                     src="{{ asset('storage/' . $user->picture) }}">
            </a>
        </div>
        <div>
            <a class="fw-bold link-dark" href="{{ url('users/' . $user->id) }}" style="text-decoration: none">
                {{$user->name}}
            </a>
            <br>
            <span class="fw-thin text-secondary">{{$user->username}}</span>

        </div>
    </div>

    <!-- It is quality rather than quantity that matters. - Lucius Annaeus Seneca -->
</div>
