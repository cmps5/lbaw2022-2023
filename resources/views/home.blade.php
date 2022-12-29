@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col">

            @foreach($posts as $post)
                <x-post-preview :post="$post"/>
            @endforeach

        </div>
    </div>
</div>
@endsection
