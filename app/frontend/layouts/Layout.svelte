<script>
  import Navbar from '../components/Navbar.svelte';
  import Flash from '../components/Flash.svelte';
  
  let { children, user, currentEntity = null, availableEntities = [], userContext = null } = $props();
</script>

<div class="min-h-screen bg-base-100 flex flex-col">
  <Navbar {user} {currentEntity} {availableEntities} {userContext} />
  <Flash />
  <main class="flex-1">
    {@render children()}
  </main>
</div>