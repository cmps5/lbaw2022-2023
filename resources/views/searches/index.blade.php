@extends('layouts.app')

@section('content')
    <div class="container"
         style="width: 50%;">

        <h1 class="fs-1 fw-bolder mb-3">Search results</h1>

            <div class="row border-top border-1 my-3">
                <div class="d-flex gap-2 d-flex justify-content-evenly">
                    <div class="flex-item ml-3 border-top border-secondary">
                        <div class="fw-bold p-2">Post</div>
                    </div>
                    <div class="flex-item ml-3">
                        <div class="fw-bold p-2">User</div>
                    </div>
                </div>

            </div>

        @foreach($users as $user)
            <x-user-preview :user="$user"/>
        @endforeach

        @foreach($posts as $post)
            <x-post-preview :post="$post"/>
        @endforeach




    </div>

@endsection
