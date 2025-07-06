<script>
  import Navbar from '../components/Navbar.svelte';
  import Flash from '../components/Flash.svelte';
  
  let { children, user, currentEntity = null, availableEntities = [], pendingInvites = [] } = $props();
</script>

<div class="min-h-screen bg-base-100 flex flex-col">
  <!-- Navbar Zone -->
  <Navbar {user} {currentEntity} {availableEntities} {pendingInvites} />
  <Flash />
  <!-- Page Body Zone -->
  <main class="flex-1 h-[calc(100vh-4rem)] overflow-auto p-6">
    {@render children()}
  </main>
</div>