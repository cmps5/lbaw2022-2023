@extends('layouts.app')

@section('content')
    <div class="container" style="margin: 0 auto; width: 50%">
        <div class="mb-5">
            <h1 class="fs-1 fw-bolder">Contacts</h1>
            <p class="fs-5">The team behind this project.</p>
        </div>

        <div class="row">
            <div class="col-sm">
                <div class="d-flex flex-column gap-2 text-center">
                    <div>
                        <img class="rounded-circle position-sticky img-thumbnail" alt="100x100"
                            src="{{ url('/images/miguelBitmoji.png') }}">
                    </div>
                    <div>
                        <a class="fw-bold link-dark" href="mailto:up20190194@fe.up.pt" style="text-decoration: none">
                            Matias
                        </a>
                        <br><span class="fw-thin text-secondary">up201900194@fe.up.pt</span>

                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>
@endsection
