@extends('layouts.app')

@section('content')
    <div class="container"
         style="width: 50%;">



        <h1 class="fs-1 fw-bolder mb-3">Create a new post</h1>
        <form enctype="multipart/form-data" method="post" action="{{ route('posts.store') }}">
            @csrf

            <!-- Title -->
            <div class="form-floating mb-3">
                <input type="text" class="form-control" id="post-title" placeholder="Post Title" name="title" required>
                <label for="post-title" class="form-label fw-bold">Title</label>
            </div>


            <!-- Content -->
            <div class="form-floating mb-3">
                <textarea class="form-control" id="post-content" placeholder="Post Content" name="content"
                          style="height: 15rem;"></textarea>
                <label for="post-content" class="form-label fw-bold">Content</label>
            </div>


            <!-- Media -->
            <div class="form mb-3">
                <label for="post-media" class="form-label fw-bold">Media</label> <br>
                <input type="file" class="form-control" id="post-media" name="media">
            </div>

            <!-- tags -->
            <label for="post-tags" class="form-label fw-bold">Tags</label>
            @isset($tags)
                @foreach ($tags as $tag)
                    <div class="d-flex flex-row">
                        <label for="tag{{$tag->id}}" hidden>{{$tag->name}}</label>
                        <input type="checkbox" class="form-check-input me-3" name="tag{{$tag->id}}">
                        <x-tag :tag="$tag" />
                    </div>
                @endforeach
            @endisset
            <br>
            <button type="submit" class="btn btn-primary mt-3">Create Post</button>
        </form>

    </div>
@endsection
