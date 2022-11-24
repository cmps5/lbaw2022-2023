<footer>
    <nav>
        <ul class="nav fixed-bottom navbar-light justify-content-around" style="background-color: #7ec699;">
            <li class="nav-item p-3 ">
                <a class="nav-link text-dark fw-bold" href="{{ route('about') }}">About Us</a>
            </li>
            <li class="nav-item p-3">
                <a class="nav-link text-dark fw-bold" href="{{ route('contacts') }}">Contacts</a>
            </li>
            <li class="nav-item p-3">
                <a class="nav-link text-dark fw-bold" href="{{ route('help') }}">Help</a>
            </li>
            <li class="nav-item p-3">
                <a class="nav-link text-dark fw-bold" href="{{ route('features') }}">Main Features</a>
            </li>
        </ul>
    </nav>
</footer>

@yield('footer')
