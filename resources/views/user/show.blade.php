@extends('layouts.app')

@section('content')
    <script src="{{ asset('js/user.js') }}" defer></script>
    <div class="container">


        @if (Session::has('success'))
            <div class="alert alert-success" role="alert">{{ Session::get('success') }}</div>
        @endif
        @if (@isset(Auth()->user()->id) && $user->blocking()->contains(Auth::user()->id))
            You have been blocked!
        @else
            <div class="d-flex gap-2">
                <!-- user information -->

                <div class="flex-item mx-1" style="min-width:300px">
                    <div class="d-flex flex-column gap-2">
                        <!-- image profile -->
                        <div class="row p-2 align-self-center" style="width: 200px; height: 200px;">
                            @if ($user->picture)
                                <img class="rounded-circle img-thumbnail " alt="Profile picture"
                                     src="{{ asset('storage/' . $user->picture) }}" data-holder-rendered="true" />
                            @else
                                <img class="rounded-circle img-thumbnail" alt="Profile picture"
                                     src="{{ asset('images/default.png') }}" data-holder-rendered="true" />
                            @endif
                        </div>
                        <!-- data -->
                        <div class="row flex-column gap-5 flex-grow-1 text-center align-items-center border-top p-2">
                            <!-- identification -->
                            <div class="row align-center w-100 h-auto p-2">
                                <div class="fw-bolder">{{ $user->name }}</div>
                                <div class="fst-italic fw-light" style="color: gray"> {{ $user->username }}</div>
                                @if ($user->moderator)
                                    <div class="fw-light" style="color: lightseagreen;">Moderator</div>
                                @endif
                            </div>
                            <!-- bio -->
                            @if ($user->description)
                                <div class="row w-100 h-auto border rounded-1 p-3" style="height:25%">
                                    {{ $user->description }}
                                </div>
                            @endif

                            <!-- actions -->
                            @if (@isset(Auth()->user()->user_id) && Auth::user()->user_id != $user->user_id)
                                <div class="row">
                                    <div class="d-flex gap-2 h-auto justify-content-around">
                                        @if (Auth::user()->following()->contains($user->user_id))
                                            <button class="flex-item fw-light h-auto btn btn-primary follow"
                                                    id="unfollow-btn" follower='{{ Auth::user()->id }}'
                                                    followed='{{ $user->user_id }}'>{{ __('Unfollow') }} </button>
                                        @else

                                            <button class="flex-item fw-light h-auto btn btn-primary follow" id="follow-btn"
                                                    follower='{{ Auth::user()->id }}'
                                                    followed='{{ $user->user_id }}'>{{ __('Follow') }} </button>
                                        @endif
                                        <div class="vr"></div>
                                        @if (Auth::user()->blocking()->contains($user->user_id))
                                            <button class="flex-item fw-light h-auto btn btn-danger block" id="unblock-btn"
                                                    blocker='{{ Auth::user()->id }}' blocked='{{ $user->user_id }}'>
                                                {{ __('UnBlock') }}
                                            </button>
                                        @else
                                            <button class="flex-item fw-light h-auto btn btn-danger block" id="block-btn"
                                                    blocker='{{ Auth::user()->id }}' blocked='{{ $user->user_id }}'>
                                                {{ __('Block') }}
                                            </button>
                                        @endif
                                        <div class="vr"></div>

                                        <div class="dropdown ">
                                            <a class="btn text-light btn-warning" type="button" data-bs-toggle="dropdown"
                                               aria-expanded="false" aria-expanded="false">
                                                <!-- Report icon -->

                                                {{ __('Report') }}

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
                                                        <label for="report-content"
                                                               class="form-label fw-bold">Report</label>
                                                    </div>
                                                    <input name="user_id" value="{{ $user->user_id }}" hidden />
                                                    <input name="reporter" value="{{ Auth::user()->id }}" hidden />
                                                    <button type="submit" class="btn btn-primary mx-3">Leave a
                                                        report</button>
                                                </form>
                                            </div>
                                        </div>




                                    </div>
                                </div>
                            @else
                                <a class="flex-item fw-light h-auto btn btn-primary" style="width: 33%;"
                                   href="{{ route('users.edit', $user->user_id) }}">{{ __('Edit Profile') }}
                                </a>
                            @endif
                            <!-- reputation -->
                            <div class="row fw-light">
                                <div>{{ __('Reputation') }}</div>
                                <div class="fs-3">{{ $user->reputation }}</div>
                            </div>
                            <!-- time being member -->
                            <div class="row fw-light">
                                <div style="font-size:75%">Member since
                                    {{ Carbon::parse($user->created_at)->format('d-m-Y') }}</div>
                            </div>


                            <!-- Moderator actions -->
                            @if (@isset(Auth()->user()->id) && (Auth::user()->moderator && Auth::user()->id != $user->user_id))
                                <h3>
                                    MODERATOR ACTIONS
                                </h3>

                                <div class="row">
                                    <div class="d-flex gap-2 h-auto justify-content-around">
                                        <form action="{{ route('users.extendTimeout', $user->user_id) }}" method="post">
                                            @method('PATCH')
                                            @csrf
                                            <button class="flex-item fw-light h-auto btn btn-danger"
                                                    href="UserController@extendTimeout">
                                                {{ __('Timeout') }}
                                            </button>
                                        </form>
                                    </div>
                                </div>

                                <div>
                                    Timeout = {{ $user->end_timeout }}
                                </div>
                            @endif
                        </div>
                    </div>
                </div>

                <div class="flex-item flex-column flex-grow-1 mx-1 gap-2">
                    <div class="row border-top border-1 m-3">
                        <div class="d-flex gap-3 d-flex justify-content-evenly">
                            <div class="flex-item ml-3 border-top border-secondary" id="postsSelector"
                                 onclick="showUserPosts()">
                                <div class="fw-light p-2">{{ __('Posts') }}</div>
                            </div>

                            <div class="flex-item ml-3" id="tagsSelector" onclick="showUserTags()">
                                <div class="fw-light p-2">{{ __('Followed Tags') }}</div>
                            </div>
                            <div class="flex-item ml-3" id="followersSelector" onclick="showFollowers()">
                                <div class="fw-light p-2">{{ __('Followers') }}</div>
                            </div>
                            <div class="flex-item ml-3" id="followingSelector" onclick="showFollowing()">
                                <div class="fw-light p-2">{{ __('Following') }}</div>
                            </div>
                            @if (@isset(Auth()->user()->id) && Auth::user()->id == $user->user_id)
                                <div class="flex-item ml-3" id="blockingSelector" onclick="showBlocking()">
                                    <div class="fw-light p-2">{{ __('Blocking') }}</div>
                                </div>
                            @endif
                        </div>

                        <div class="row flex-grow-1 m-3" style="overflow:scroll; height: 500px; display:unset" id="posts">

                            <!-- card -->
                            @foreach ($user->posts as $post)
                                <x-post-preview :post="$post" />
                            @endforeach

                            
                        </div>
                        <div class="row flex-grow-1 m-3" style="overflow:scroll; height: 500px; display:none" id="savedPosts">
                                <!-- card -->
                                ola
                        </div>

                            
                        <div class="row flex-grow-1 m-3" style="overflow:scroll; height: 500px; display:none" id="followers">
                        </div>

                        <div class="row flex-grow-1 m-3" style="overflow:scroll; height: 500px; display:none" id="following">
                        </div>

                        <div class="row flex-grow-1 m-3" style="overflow:scroll; height: 500px; display:none" id="tags">
                        </div>

                    </div>

                </div>




                
            </div>
        @endif

    </div>

@endsection

