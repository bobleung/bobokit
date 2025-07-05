<script>
  import { Link } from '@inertiajs/svelte';
  import EntitySwitcher from './EntitySwitcher.svelte';
  
  let { user = null, currentEntity = null, availableEntities = [], pendingInvites = [] } = $props();
  
  const isAuthenticated = $derived(!!user);
  const isSuperAdmin = $derived(user?.super_admin);

  function showProps(){
    console.log("User", user)
  }
  
</script>

<div class="navbar bg-base-100 shadow-sm">
  <!-- Brand/Logo - always on left -->
  
  <div class="navbar-start">
    <span onclick={showProps} class="material-symbols-outlined pl-4 text-accent">heart_smile</span>
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
  
  <!-- Center Items -->
  <div class="navbar-center hidden lg:flex">
    <!-- User menu - only show navigation items when authenticated -->
    {#if isAuthenticated}
      <ul class="menu menu-horizontal px-1">
        <li><Link href="/">Bookings</Link></li>
        <li><Link href="/">Invoices</Link></li>
      </ul>
    {/if}

    <!-- Super Admin Menu -->
    {#if isSuperAdmin}
      <span class="text-base-content/25">|</span>
      <ul class="menu menu-horizontal px-1">
        <li>
          <details>
            <summary>Super Admin</summary>
            <ul class="p-2 min-w-40">
              <li><Link href="/super/users">Users</Link></li>
              <li><Link href="/super/orgs">Orgs</Link></li>
            </ul>
          </details>
        </li>
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