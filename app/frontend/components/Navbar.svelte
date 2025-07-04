<script>
  import { Link } from '@inertiajs/svelte';
  import EntitySwitcher from './EntitySwitcher.svelte';
  
  let { user = null, currentEntity = null, availableEntities = [], userContext = null } = $props();
  
  const isAuthenticated = $derived(!!user);
  const userFirstName = $derived(user?.first_name);
</script>

<div class="navbar bg-base-100 shadow-sm">
  <!-- Brand/Logo - always on left -->
  <div class="navbar-start">
    <!-- Mobile menu button - only show when authenticated -->
    {#if isAuthenticated}
      <div class="dropdown">
        <button class="btn btn-ghost lg:hidden" aria-label="Open mobile menu">
          <span class="material-symbols-outlined">menu</span>
        </button>
        <div class="dropdown-content menu bg-base-100 rounded-box z-[1] mt-3 w-52 p-2 shadow">
          <ul>
            <li><Link href="/bookings">Bookings</Link></li>
            <li><Link href="/invoices">Invoices</Link></li>
          </ul>
        </div>
      </div>
    {/if}
    <Link href="/" class="btn btn-ghost text-xl">myLocums</Link>
  </div>

  <!-- Desktop center menu - only show navigation items when authenticated -->
  <div class="navbar-center hidden lg:flex">
    {#if isAuthenticated}
      <ul class="menu menu-horizontal px-1">
        <li><Link href="/bookings">Bookings</Link></li>
        <li><Link href="/invoices">Invoices</Link></li>
      </ul>
    {/if}
  </div>

  <!-- Right side - entity switcher, user dropdown (desktop) or login button -->
  <div class="navbar-end gap-2">
    {#if isAuthenticated}
      <!-- Entity Switcher -->
      <EntitySwitcher {currentEntity} {availableEntities} {userContext} />
      <!-- Desktop user dropdown - visible on all screen sizes when authenticated -->
      <div class="dropdown dropdown-end">
        <button class="btn btn-ghost" aria-label="User menu">
          <span class="hidden sm:inline">{userFirstName}</span>
          <span class="sm:hidden">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
          </span>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </button>
        <div class="dropdown-content menu bg-base-100 rounded-box z-[1] mt-3 w-32 p-2 shadow">
          <ul>
            <li><Link href="/profile">Profile</Link></li>
            <li><Link href="/logout">Log Out</Link></li>
          </ul>
        </div>
      </div>
    {:else}
      <!-- Login button - shown when not authenticated -->
      <Link href="/login" class="btn btn-primary">Login</Link>
    {/if}
  </div>
</div>