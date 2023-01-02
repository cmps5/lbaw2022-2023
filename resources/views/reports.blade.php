@extends('layouts.app')

@section('content')
    <div class="container">

        <ol class="list-group " style="padding:150px">
            @if ($reports)
                @foreach ($reports as $report)
                    <li class="list-group-item">


                        <div class="hstack gap-4 fw-bold ms-2 me-auto ">
                            <div> {{ $report->id }} </div>
                            <div> {{ $report->reporter}} </div>
                            <div> {{ $report->reported }} </div>

                            {{ $report->content }}
                            <div class="vr ms-auto"></div>

                            <button type="button" class="btn btn-secondary align-middle">Resolve</button>
                        </div>
                    </li>
                @endforeach
            @endif
        </ol>
    </div>
@endsection
