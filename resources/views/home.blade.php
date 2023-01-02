@extends('layouts.app')

@section('content')
    <div class="container">
        <script src="{{ asset('js/home.js') }}" defer></script>

        <div class="border-top border-1 m-3">
            <div class="d-flex gap-3 justify-content-evenly">
                <div class="ml-3 border-top border-secondary" id="ViewTopPosts"
                     onclick="ShowTopPosts()" style="cursor: pointer">
                    <div class="fw-light p-2">{{ __('View Top Posts') }}</div>
                </div>
                <div class="ml-3" id="ViewRecentPosts" onclick="ShowRecentPosts()"
                     style="cursor: pointer">
                    <div class="fw-light p-2">{{ __('View Recent Posts') }}</div>
                </div>
            </div>
        </div>

        <div class="row justify-content-center">
            <div class="col-md-8" id="ShowTopPosts">
                @foreach($topposts as $post)
                    <x-post-preview :post="$post"/>
                @endforeach
            </div>
            <div class="col-md-8" id="ShowRecentPosts" style="display: none;">
                @foreach($recentposts as $post)
                    <x-post-preview :post="$post"/>
                @endforeach
            </div>
        </div>
    </div>
@endsection
