<link href="{{ asset('css/tag.css') }}" rel="stylesheet">
<script src="{{ asset('js/tag.js') }}" defer></script>
@if ($tag->color)

    <div class="badge rounded-pill position-relative w-auto my-1" style="background-color: {{ $tag->color }} " (
         onmouseover="appearFollowTag('{{ $tag->name }}')" onmouseout="disappearFollowTag('{{ $tag->name }}')"
         onmousedown="followTagPressed('{{ $tag->name }}')" onmouseup="followTagUnpressed('{{ $tag->name }}')">

        {{ $tag->name }}
        <span class="position-absolute top-0 start-100 translate-middle px-1 border border-light rounded-circle"
              id="follow{{ $tag->name }}" style="display:none; background-color:azure">
            <div class="fs-5">+</div>
            <span class="visually-hidden">Follow</span>
        </span>
    </div>
@else

    <div class="badge rounded-pill position-relative w-auto my-1" style="background-color: black"
         onmouseover="appearFollowTag('{{ $tag->name }}')" onmouseout="disappearFollowTag('{{ $tag->name }}')"
         onmousedown="followTagPressed('{{ $tag->name }}')" onmouseup="followTagUnpressed('{{ $tag->name }}')">

        {{ $tag->name }}
        <span class="position-absolute top-0 start-100 translate-middle px-1 border border-light rounded-circle"
              id="follow{{ $tag->name }}" style="display:none; background-color:azure">
            <div class="fs-5">+</div>
            <span class="visually-hidden">Follow</span>
        </span>

    </div>
@endif
