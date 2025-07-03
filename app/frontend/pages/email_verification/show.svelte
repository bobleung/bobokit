<script>
  import { Link } from '@inertiajs/svelte';

  let { user } = $props();
  
  const handleResend = () => {
    // Form submission will be handled by Inertia
    const form = document.getElementById('resend-form');
    if (form) {
      form.submit();
    }
  };
</script>

<div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
  <div class="sm:mx-auto sm:w-full sm:max-w-md">
    <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
      <div class="text-center">
        <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-blue-100">
          <svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
          </svg>
        </div>
        <h2 class="mt-6 text-3xl font-extrabold text-gray-900">
          Check your email
        </h2>
        <p class="mt-2 text-sm text-gray-600">
          We've sent a verification email to <strong>{user?.email_address}</strong>
        </p>
      </div>

      <div class="mt-8">
        <div class="rounded-md bg-blue-50 p-4">
          <div class="text-sm text-blue-700">
            <p>Click the verification link in your email to complete your account setup.</p>
            <p class="mt-2">The link will expire in 24 hours.</p>
          </div>
        </div>

        <div class="mt-6">
          <form id="resend-form" action="/resend_verification" method="post" class="space-y-4">
            <div>
              <button type="submit" class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                Resend verification email
              </button>
            </div>
          </form>
        </div>

        <div class="mt-6 text-center">
          <p class="text-sm text-gray-600">
            Wrong email address? 
            <Link href="/profile" class="font-medium text-blue-600 hover:text-blue-500">
              Update your profile
            </Link>
          </p>
        </div>
      </div>
    </div>
  </div>
</div>