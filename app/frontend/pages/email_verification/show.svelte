<script>
  import { Link, router } from '@inertiajs/svelte';

  let { user } = $props();
  
  const handleResend = (event) => {
    event.preventDefault();
    router.post('/resend_verification');
  };
</script>

<div class="min-h-[calc(100vh-4rem)] flex items-center justify-center">
  <div class="card w-96 bg-base-200 card-lg shadow-sm">
    <div class="card-body flex flex-col gap-4">
      <div class="text-center">
        <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-base-300 bg-opacity-20 mb-4">
          <span class="material-symbols-outlined text-base-content text-2xl">mail</span>
        </div>
        <h2 class="card-title justify-center text-2xl">
          Check your email
        </h2>
        <p class="text-base-content/70 mt-2">
          We've sent a verification email to <strong>{user?.email_address}</strong>
        </p>
      </div>

      <div class="alert alert-info">
        <span class="material-symbols-outlined">info</span>
        <div>
          <p>Click the verification link in your email to complete your account setup.</p>
          <p class="mt-1">The link will expire in 24 hours.</p>
        </div>
      </div>

      <form onsubmit={handleResend} class="flex flex-col gap-4">
        <button type="submit" class="btn btn-primary w-full">
          <span class="material-symbols-outlined">refresh</span>
          Resend verification email
        </button>
      </form>

      <div class="text-center">
        <p class="text-sm text-base-content/70">
          Wrong email address? 
          <Link href="/profile" class="link">
            Update your profile
          </Link>
        </p>
      </div>
    </div>
  </div>
</div>