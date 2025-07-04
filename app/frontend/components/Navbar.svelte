<script>
  import { Link } from '@inertiajs/svelte';
  import EntitySwitcher from './EntitySwitcher.svelte';
  
  let { user = null, currentEntity = null, availableEntities = [], pendingInvites = [] } = $props();
  
  const isAuthenticated = $derived(!!user);
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

  <!-- Right side - entity switcher or login button -->
  <div class="navbar-end gap-2">
    {#if isAuthenticated}
      <!-- Entity Switcher with integrated user profile -->
      <EntitySwitcher {currentEntity} {availableEntities} {pendingInvites} {user} />
    {:else}
      <!-- Login button - shown when not authenticated -->
      <Link href="/login" class="btn btn-primary">Login</Link>
    {/if}
  </div>
</div>