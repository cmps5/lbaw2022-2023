<header style= "background-color: #7ec699;">
    <nav class="navbar navbar-light">
        <div class="container d-flex">
            <a href="{{ url('/') }}">
                <img src="{{ url('/images/logo.png') }}" alt="Eat&Peas logo"
                     class="navbar-brand" width="80" height="80" href="{{ url('/') }}"/>
            </a>
            <a class="navbar-brand fs-1" href="{{ url('/') }}">{{ config('app.name', 'Laravel') }}</a>

            <!-- Search bar -->
            <form class="form-inline flex-grow-1 p-2" action="{{ route('search.store') }}" method="post">
                @csrf
                    <input class="form-control mr-sm-2" id="search-content" type="search" placeholder="Search" name="content" aria-label="Search">
            </form>



            @guest
                @if (Route::has('login'))
                    <a class="nav-link" href="{{ route('login') }}">{{ __('Login') }}</a>
                @endif
                @if (Route::has('register'))
                    <a class="nav-link" href="{{ route('register') }}">{{ __('Register') }}</a>
                @endif
            @else
                <div class="position-relative m-3">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
                        <path d="M8 16a2 2 0 0 0 2-2H6a2 2 0 0 0 2 2zm.995-14.901a1 1 0 1 0-1.99 0A5.002 5.002 0 0 0 3 6c0 1.098-.5 6-2 7h14c-1.5-1-2-5.902-2-7 0-2.42-1.72-4.44-4.005-4.901z"/>
                    </svg>
                    <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-secondary">
                        +99
                        <span class="visually-hidden">unread messages</span>
                    </span>
                </div>

                <div class="fw-bold m-3">{{ Auth::user()->username }}</div>

                <!-- Username + profile picture -->
                <div class="dropdown row">
                    <a class="btn" role="button" id="dropdownMenuLink" data-bs-toggle="dropdown" aria-expanded="false">
                        @if (Auth::user()->picture)
                            <img src="{{ asset('storage/' . Auth::user()->picture) }}" alt="Authenticated user picture"
                                 class="rounded-circle" width="60" height="60"/>
                        @else
                            <img src="{{ asset('images/default.png') }}" alt="Authenticated user picture"
                                 class="rounded-circle" width="60" height="60"/>
                        @endif
                    </a>

                    <ul class="dropdown-menu" aria-labelledby="dropdownMenuLink">
                        <li><a class="dropdown-item" href="{{ url('users/' . Auth::user()->user_id) }}">{{ __('Profile') }}</a></li>
                        <li><a class="dropdown-item" href="{{ url('posts/create') }}">{{ __('Create Post') }}</a></li>
                        <li><a class="dropdown-item" href="{{ route('logout') }}"
                               onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                                {{ __('Logout') }}
                            </a>
                            <form id="logout-form" action="{{ route('logout') }}" method="POST" class="d-none">
                                @csrf
                            </form>
                        </li>
                    </ul>
                </div>

            @endguest

            <a class="btn navbar-toggler m-3" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="{{ __('Toggle navigation') }}">
                <span class="navbar-toggler-icon"></span>
            </a>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">

                <!-- Right Side Of Navbar -->
                <ul class="nav navbar-light">
                    <ul class="nav navbar-light justify-content-center w-100">
                        <li class="nav-item" style="padding-top:0.75rem; padding-left:2.75rem; padding-right:2.75rem;">
                            <a class="nav-link text-dark h5 fw-bold" href="{{ route('about') }}">{{ __('About Us') }}</a>
                        </li>
                        <li class="nav-item" style="padding-top:0.75rem; padding-left:2.75rem; padding-right:2.75rem;">
                            <a class="nav-link text-dark h5 fw-bold" href="{{ route('contacts') }}">{{ __('Contacts') }}</a>
                        </li>
                        <li class="nav-item" style="padding-top:0.75rem; padding-left:2.75rem; padding-right:2.75rem;">
                            <a class="nav-link text-dark h5 fw-bold" href="{{ route('help') }}">{{ __('Help') }}</a>
                        </li>
                        <li class="nav-item" style="padding-top:0.75rem; padding-left:2.75rem; padding-right:2.75rem;">
                            <a class="nav-link text-dark h5 fw-bold" href="{{ route('features') }}">{{ __('Main Features') }}</a>
                        </li>
                    </ul>

                </ul>


            </div>

        </div>

    </nav>

</header>

@yield('header')
