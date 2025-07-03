<script>
  import { router } from '@inertiajs/svelte';
  import { Link } from '@inertiajs/svelte';

  let { token } = $props();
  
  let password = $state('');
  let password_confirmation = $state('');

  function handleSubmit(event) {
    event.preventDefault();
    router.put(`/passwords/${token}`, {
      password: password,
      password_confirmation: password_confirmation
    });
  }
</script>

<div class="min-h-[calc(100vh-4rem)] flex items-center justify-center">
  <form onsubmit={handleSubmit}>
    <div class="card w-96 bg-base-200 card-lg shadow-sm">
      <div class="card-body flex flex-col gap-4">
        <div class="text-center">
          <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-base-300 bg-opacity-20 mb-4">
            <span class="material-symbols-outlined text-base-content text-2xl">key_vertical</span>
          </div>
          <h2 class="card-title justify-center text-2xl">
            Update your password
          </h2>
          <p class="text-base-content/70 mt-2">
            Enter your new password below.
          </p>
        </div>
        
        <label class="input validator">
          <span class="material-symbols-outlined opacity-50">key_vertical</span>
          <input
            type="password"
            class="grow"
            placeholder="Enter new password"
            bind:value={password}
            required
            autofocus
            minlength="3"
            maxlength="72"
          />
        </label>
        
        <label class="input validator">
          <span class="material-symbols-outlined opacity-50">key_vertical</span>
          <input
            type="password"
            class="grow"
            placeholder="Repeat new password"
            bind:value={password_confirmation}
            required
            minlength="3"
            maxlength="72"
          />
        </label>
        
        <div class="flex flex-col gap-2">
          <button type="submit" class="btn btn-primary">
            Save password
          </button>
          
          <Link href="/login" class="btn btn-ghost">
            Back to login
          </Link>
        </div>
      </div>
    </div>
  </form>
</div>