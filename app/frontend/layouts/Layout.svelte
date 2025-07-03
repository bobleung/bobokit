<script>
  import Navbar from '../components/Navbar.svelte';
  import Flash from '../components/Flash.svelte';
  
  let { children, user } = $props();
</script>

<div class="min-h-screen bg-base-100">
  <Navbar {user} />
  <Flash />
  <main>
    {@render children()}
  </main>
</div>