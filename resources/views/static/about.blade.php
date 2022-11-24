@extends('layouts.app')

@section('content')
    <div class="container"
         style="margin: 0 auto; width: 50%">

        <div class="d-flex flex-column">
            <h1 class="fs-1 fw-bolder">About Us</h1>
            <p class="fs-5">
                Eat&Peas is one of the best places ever created to learn how to cook.
                What are you wanting to join us?
            </p>
            <p class="fs-5">
                Here we have a lot of content about cuisine to you never stop learn.
            </p>
            <p class="fs-5">
                Any doubt? Visit <a href={{ route('help') }} class="link-dark">our help page!</a>
            </p>
        </div>

        <div class="d-flex flex-column align-items-end">
            <span class="fw-bolder">LBAW @ L.EIC</span>
        </div>

    </div>
@endsection
