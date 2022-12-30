<?php

namespace App\View\Components;

use Illuminate\View\Component;

class Comment extends Component
{
    public $comment;

    public function __construct($comment)
    {
        $this->comment = $comment;
    }

    public function render()
    {
        return view('components.comment');
    }
}
