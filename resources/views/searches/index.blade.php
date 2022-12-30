@extends('layouts.app')

@section('content')
    <div class="container" style="width: 50%;">

        <nav style="--bs-breadcrumb-divider: url(&#34;data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpath d='M2.5 0L1 1.5 3.5 4 1 6.5 2.5 8l4-4-4-4z' fill='currentColor'/%3E%3C/svg%3E&#34;);" aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{ route('home') }}">Home</a></li>
                <li class="breadcrumb-item active" aria-current="page">Search</li>
                <li class="breadcrumb-item active" aria-current="page">{{ $content }}</li>
            </ol>
        </nav>

        <h1 class="fs-1 fw-bolder mb-2">
            Search results for "{{$content}}"
        </h1>

        <!-- Filter -->
        <div class="accordion my-3">
            <div class="accordion-item">
                <h2 class="accordion-header" id="FilterResults">
                    <button class="accordion-button collapsed" type="button"
                            data-bs-toggle="collapse" data-bs-target="#collapse-FilterResults"
                            aria-expanded="false" aria-controls="collapse-changeStatus">
                        Filter search results
                    </button>
                </h2>
                <div class="accordion-collapse collapse" id="collapse-FilterResults"
                     aria-labelledby="FilterResults" data-bs-parent="#help">
                    <div class="accordion-body d-flex flex-column gap-2">

                        <form enctype="multipart/form-data" method="get"
                              action="{{ route('searches.filter', $content) }}">
                            @csrf
                            @isset($tags)
                                @foreach ($tags as $tag)
                                    <div class="d-flex flex-row">
                                        <label for="tag{{$tag->id}}" hidden>{{$tag->name}}</label>
                                        <input type="checkbox" class="form-check-input me-3" name="tag{{$tag->id}}" checked>
                                        <x-tag :tag="$tag" />
                                    </div>
                                @endforeach
                            @endisset


                            <button class="btn btn-primary" type="submit" style="width: 6rem;">Filter</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        @isset($users)
            @foreach($users as $user)
                <x-user-preview :user="$user"/>
            @endforeach
        @endisset

        @isset($posts)
            @foreach($posts as $post)
                <x-post-preview :post="$post"/>
            @endforeach
        @endisset



    </div>

@endsection
