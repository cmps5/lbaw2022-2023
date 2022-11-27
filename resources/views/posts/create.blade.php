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

            <!-- FIXME: We are already passing an array but then its necessary to check with DB -->
            <label for="post-tags" class="form-label fw-bold">Tags</label>
            <div class="input-group mb-3 d-flex flex-row justify-content-around" id="post-tags">
                <div class="flex-item form-check-inline">
                    <input type="checkbox" class="form-check-input" id="politics" name="tags[]">
                    <label for="politics" class="form-check-label badge rounded-pill bg-primary">Politics</label>
                </div>
                <div class="flex-item form-check-inline">
                    <input type="checkbox" class="form-check-input" id="science" name="tags[]">
                    <label for="science" class="form-check-label badge rounded-pill bg-secondary">Science</label>
                </div>
                <div class="flex-item form-check-inline">
                    <input type="checkbox" class="form-check-input" id="sports" name="tags[]">
                    <label for="sports" class="form-check-label badge rounded-pill bg-success">Sports</label>
                </div>
                <div class="flex-item form-check-inline">
                    <input type="checkbox" class="form-check-input" id="economics" name="tags[]">
                    <label for="economics" class="form-check-label badge rounded-pill bg-danger">Economics</label>
                </div>
                <div class="flex-item form-check-inline">
                    <input type="checkbox" class="form-check-input" id="lifestyle" name="tags[]">
                    <label for="lifestyle" class="form-check-label badge rounded-pill bg-warning text-dark">Lifestyle</label>
                </div>
            </div>
            <button type="submit" class="btn btn-primary">Create Post</button>
        </form>

    </div>
@endsection
