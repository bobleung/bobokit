<script>
  export let user = null;
  
  $: isAuthenticated = !!user;
  $: userFirstName = user?.first_name;
</script>

<div class="navbar bg-base-100 shadow-sm">
  <div class="navbar-start">
    {#if isAuthenticated}
      <div class="dropdown">
        <div tabindex="0" role="button" class="btn btn-ghost lg:hidden">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h8m-8 6h16" />
          </svg>
        </div>
        <ul
          tabindex="0"
          class="menu menu-sm dropdown-content bg-base-100 rounded-box z-[1] mt-3 w-52 p-2 shadow">
          <li><a href="/bookings">Bookings</a></li>
          <li><a href="/invoices">Invoices</a></li>
          <li class="border-t border-base-300 mt-2 pt-2">
            <a href="/profile">Profile</a>
          </li>
          <li><a href="/logout">Log Out</a></li>
        </ul>
      </div>
    {/if}
    <a class="btn btn-ghost text-xl" href="/">myLocums</a>
  </div>
  <div class="navbar-center hidden lg:flex">
    {#if isAuthenticated}
      <ul class="menu menu-horizontal px-1">
        <li><a href="/bookings">Bookings</a></li>
        <li><a href="/invoices">Invoices</a></li>
      </ul>
    {/if}
  </div>
  <div class="navbar-end">
    {#if isAuthenticated}
      <div class="dropdown dropdown-end">
        <div tabindex="0" role="button" class="btn btn-ghost">
          {userFirstName}
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </div>
        <ul
          tabindex="0"
          class="menu menu-sm dropdown-content bg-base-100 rounded-box z-[1] mt-3 w-32 p-2 shadow">
          <li><a href="/profile">Profile</a></li>
          <li><a href="/logout">Log Out</a></li>
        </ul>
      </div>
    {:else}
      <a class="btn btn-primary" href="/login">Login</a>
    {/if}
  </div>
</div>