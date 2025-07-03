<script>
  import { router } from '@inertiajs/svelte';
  import { Link } from '@inertiajs/svelte';

  let email = $state('');

  function handleSubmit(event) {
    event.preventDefault();
    router.post('/passwords', {
      email_address: email
    });
  }
</script>

<div class="min-h-[calc(100vh-4rem)] flex items-center justify-center">
  <form onsubmit={handleSubmit}>
    <div class="card w-96 bg-base-200 card-lg shadow-sm">
      <div class="card-body flex flex-col gap-4">
        <div class="text-center">
          <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-base-300 bg-opacity-20 mb-4">
            <span class="material-symbols-outlined text-base-content text-2xl">key</span>
          </div>
          <h2 class="card-title justify-center text-2xl">
            Forgot your password?
          </h2>
          <p class="text-base-content/70 mt-2">
            Enter your email address and we'll send you a link to reset your password.
          </p>
        </div>
        
        <label class="input validator">
          <span class="material-symbols-outlined opacity-50">mail</span>
          <input
            type="email"
            class="grow"
            placeholder="Enter your email address"
            bind:value={email}
            required
            autofocus
          />
        </label>
        
        <div class="flex flex-col gap-2">
          <button type="submit" class="btn btn-primary">
            Send reset instructions
          </button>
          
          <Link href="/login" class="btn btn-ghost">
            Back to login
          </Link>
        </div>
      </div>
    </div>
  </form>
</div>