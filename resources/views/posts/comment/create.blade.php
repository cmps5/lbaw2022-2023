@extends('layouts.app')

@section('content')
    <div class="container"
         style="width: 50%;">

        <form enctype="multipart/form-data" method="post" action="{{ route('comments.store') }}">
            @csrf

            <!-- Content -->
            <div class="form-floating mb-3">
                <textarea class="form-control" id="post-content" placeholder="Post Content" name="content"
                          style="height: 15rem;"></textarea>
                <label for="post-content" class="form-label fw-bold">Content</label>
            </div>

            <button type="submit" class="btn btn-primary">Comment</button>
        </form>

    </div>
@endsection
