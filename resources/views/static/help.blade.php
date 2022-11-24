@extends('layouts.app')

@section('content')
    <div class="content"
         style="margin: 0 auto; width: 50%;">

        <h1 class="fs-1 fw-bolder">Help</h1>
        <p class="fs-5 mb-5">Here are the most frequently asked questions.</p>

        <div class="accordion" id="help">
            <div class="accordion-item">
                <h2 class="accordion-header" id="question-one">
                    <button class="accordion-button collapsed" type="button"
                            data-bs-toggle="collapse" data-bs-target="#collapse-question-one"
                            aria-expanded="false" aria-controls="collapse-question-one">
                        Who can use Eat&Peas?
                    </button>
                </h2>
                <div class="accordion-collapse collapse" id="collapse-question-one"
                     aria-labelledby="question-one" data-bs-parent="#help">
                    <div class="accordion-body">
                        <strong>Every one how cooks!</strong> You dont need any previoes experience in cuisine to use our app!
                    </div>
                </div>
            </div>


            <div class="accordion-item">
                <h2 class="accordion-header" id="question-three">
                    <button class="accordion-button collapsed" type="button"
                            data-bs-toggle="collapse" data-bs-target="#collapse-question-three"
                            aria-expanded="true" aria-controls="collapse-question-three">
                        Who is behind Eat&Peas?
                    </button>
                </h2>
                <div class="accordion-collapse collapse" id="collapse-question-three"
                     aria-labelledby="question-two" data-bs-parent="#help">
                    <div class="accordion-body">
                        Eat&Peas is being developed by 4 UP students.
                    </div>
                </div>
            </div>


            <div class="accordion-item">
                <h2 class="accordion-header" id="question-five">
                    <button class="accordion-button collapsed" type="button"
                            data-bs-toggle="collapse" data-bs-target="#collapse-question-five"
                            aria-expanded="true" aria-controls="collapse-question-five">
                        What are the rules to post/comment?
                    </button>
                </h2>
                <div class="accordion-collapse collapse" id="collapse-question-five"
                     aria-labelledby="question-two" data-bs-parent="#help">
                    <div class="accordion-body">
                        <p>
                            Isnt always easy to set what is a correct behaviour, but is important to always try to be <strong>respectful</strong>.
                            Here a few examples:
                        </p>
                        <ol class="list-group list-group-numbered">
                            <li class="list-group-item">Don't spam.</li>
                            <li class="list-group-item">Don't harass anyone.</li>
                            <li class="list-group-item">Don't threaten anyone.</li>
                            <li class="list-group-item">Report anything that you think is inappropriate.</li>
                            <li class="list-group-item">Try to keep comments to the topic in question.</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

    </div>
@endsection
