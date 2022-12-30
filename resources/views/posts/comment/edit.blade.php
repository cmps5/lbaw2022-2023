@extends('layouts.app')

@section('content')
    <div class="container">

        <form action="{{ route('comments.update', $comment) }}" enctype="multipart/form-data" method="post">
            @method('PATCH')
            @csrf
            <div class="form-floating mb-3">
                <textarea class="form-control" id="post-content" placeholder="Post Content"
                          name="content" style="height: 15rem;">{{$comment->content}}</textarea>
                <label for="post-content" class="form-label fw-bold">{{ __('Content') }}</label>
            </div>

            <button type="submit" class="btn btn-primary">Edit</button>
        </form>

    </div>
@endsection
