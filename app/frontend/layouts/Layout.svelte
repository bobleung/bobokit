<script>
  import Navbar from '../components/Navbar.svelte';
  import Flash from '../components/Flash.svelte';
  
  let { children, user, currentEntity = null, availableEntities = [], pendingInvites = [] } = $props();
</script>

<div class="min-h-screen bg-base-100 flex flex-col">
  <Navbar {user} {currentEntity} {availableEntities} {pendingInvites} />
  <Flash />
  <main class="flex-1">
    {@render children()}
  </main>
</div>