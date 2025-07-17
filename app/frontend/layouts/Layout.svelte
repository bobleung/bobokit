<script>
  import Navbar from '../components/Navbar.svelte';
  import Flash from '../components/Flash.svelte';
  
  let { children, user, currentEntity = null, availableEntities = [], pendingInvites = [], userContext, ...rest } = $props();
</script>

<div class="h-screen bg-base-100 flex flex-col">
  <!-- Navbar Zone -->
  <Navbar {user} {currentEntity} {availableEntities} {pendingInvites} {userContext}, {...rest} />
  <Flash />
  <!-- Page Body Zone -->
  <main class="flex-1 overflow-auto p-6">
    {@render children()}
  </main>
</div>