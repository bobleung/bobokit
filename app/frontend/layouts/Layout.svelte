<script>
  import Navbar from '../components/Navbar.svelte';
  
  let { children, user } = $props();
</script>

<div class="min-h-screen bg-base-100">
  <Navbar {user} />
  <main>
    {@render children()}
  </main>
</div>