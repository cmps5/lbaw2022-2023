<link href="{{ asset('css/tag.css') }}" rel="stylesheet">
<script src="{{ asset('js/tag.js') }}" defer></script>

@if ($tag != null)
    @if ($tag->color)

        <div class="badge rounded-pill position-relative w-auto my-1 tag" style="background-color: {{ $tag->color }} "
             ( onmouseover="appearPlus('{{ $tag->name }}')" onmouseout="disappearPlus('{{ $tag->name }}')"
             onmousedown="pressedPlus('{{ $tag->name }}')" onmouseup="unpressedPlus('{{ $tag->name }}')"
             user_id='{{ Auth::id() }}' tag_id="{{ $tag->id }}" >

            {{ $tag->name }}


            @if (@isset(Auth()->user()->id) && Auth::user()->tags()->contains($tag->id))
                <span class="position-absolute top-0 start-100 translate-middle px-1 border border-light rounded-circle"
                      id="unfollow{{ $tag->name }}" style="display:none; background-color:azure">
                    <div class="fs-5">-</div>
                    <span class="visually-hidden">Unfollow</span>
                </span>

            @else
                <span class="position-absolute top-0 start-100 translate-middle px-1 border border-light rounded-circle"
                      id="follow{{ $tag->name }}" style="display:none; background-color:azure">
                    <div class="fs-5">+</div>
                    <span class="visually-hidden">Follow</span>
                </span>
            @endif

        </div>
    @else

        <div class="badge rounded-pill position-relative w-auto my-1 tag" style="background-color: black"
             onmouseover="appearPlus('{{ $tag->name }}')" onmouseout="disappearPlus('{{ $tag->name }}')"
             onmousedown="pressedPlus('{{ $tag->name }}')" onmouseup="unpressedPlus('{{ $tag->name }}')"
             @if(@isset(Auth()->user()->id))
                 user_id="{{ auth()->user()->id }}"
             @endif
             tag_id="{{ $tag->id }}">

            {{ $tag->name }}


            <span class="position-absolute top-0 start-100 translate-middle px-1 border border-light rounded-circle"
                  id="follow{{ $tag->name }}" style="display:none; background-color:azure">

                @if (@isset(Auth()->user()->id) && Auth::user()->tags()->contains($tag->id))
                    <div class="fs-5">-</div>
                    <span class="visually-hidden">Unfollow</span>

                @else

                    <div class="fs-5">+</div>
                    <span class="visually-hidden">Follow</span>

            </span>

            @endif

        </div>
    @endif
@endif
