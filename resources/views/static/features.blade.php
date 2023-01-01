@extends('layouts.app')

@section('content')
    <div class="container d-flex flex-column justify-content-around gap-4"
         style="margin: 0 auto; width: 50%">

        <div class="flex-item mb-5">
            <h1 class="fs-1 fw-bolder">Features</h1>
            <p class="fs-4 fs-bold">Take a look at what we have to offer!</p>
        </div>

        <div class="flex-item my-2 d-flex flex-row align-items-center gap-3">
            <div class="flex-item">
                <h2 class="fs-3 fw-bold">Always Learning!</h2>
                <p class="fs-5">
                    With Eat&Peas you can always learn how to cook better!
                </p>
            </div>

            <div class="flex-item mx-5">
                <img src="https://static.thenounproject.com/png/3030217-200.png" alt="Hand Shaking" width="150" height="150">
            </div>
        </div>

        <div class="flex-item my-2 d-flex flex-row align-items-center gap-3">
            <div class="flex-item">
                <h2 class="fs-3 fw-bold">Stay always in touch with your community!</h2>
                <p class="fs-5">
                    Share with locals about your tradicional recipes, always!
                </p>
            </div>

            <div class="flex-item mx-5">
                <img src="https://cdn-icons-png.flaticon.com/512/4087/4087698.png" alt="Hand Shaking" width="150" height="150">
            </div>
        </div>

        <div class="flex-item my-2 d-flex flex-row align-items-center gap-3">
            <div class="flex-item">
                <h2 class="fs-3 fw-bold">Leave your mark!</h2>
                <p class="fs-5">
                    Eat&Peas is the best place to learn everythig about cuisine. <br>
                    Show your questions, answer the doubts of other. <br>
                    We are here! <strong>The choice is yours!</strong>
                </p>
            </div>

            <div class="flex-item mx-5">
                <img src="https://www.iconpacks.net/icons/2/free-target-and-goal-icon-2852-thumb.png" alt="Goal achieved" width="150" height="150">
            </div>
        </div>

    </div>
@endsection
