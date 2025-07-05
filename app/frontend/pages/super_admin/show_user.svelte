<script>
    import { Link } from '@inertiajs/svelte';
    
    let { user } = $props();
    
    console.log("User details", user);
</script>

<!-- Page Container -->
<div class="flex flex-col items-center max-h-full">
    <!-- Page Title -->
    <div class="flex items-center gap-4 mb-6">
        <Link href="/super/users" class="btn btn-ghost btn-sm">
            ← Back to Users
        </Link>
        <h1 class="font-bold text-2xl">User Details</h1>
    </div>

    <!-- User Details Card -->
    <div class="card card-body card-border shadow-sm w-full max-w-2xl">
        <div class="grid gap-6">
            <!-- User Name -->
            <div>
                <label class="label">
                    <span class="label-text font-semibold">Name</span>
                </label>
                <div class="text-lg">{user.first_name} {user.last_name}</div>
            </div>

            <!-- Email -->
            <div>
                <label class="label">
                    <span class="label-text font-semibold">Email</span>
                </label>
                <div class="flex items-center gap-2">
                    <span>{user.email_address}</span>
                    {#if !user.email_verified_at}
                        <span class="badge badge-warning badge-sm">Unverified</span>
                    {:else}
                        <span class="badge badge-success badge-sm">Verified</span>
                    {/if}
                </div>
            </div>

            <!-- Super Admin Status -->
            <div>
                <label class="label">
                    <span class="label-text font-semibold">Admin Status</span>
                </label>
                <div>
                    {#if user.super_admin}
                        <div class="badge badge-primary">Super Admin</div>
                    {:else}
                        <div class="badge badge-ghost">Regular User</div>
                    {/if}
                </div>
            </div>

            <!-- Created Date -->
            <div>
                <label class="label">
                    <span class="label-text font-semibold">Account Created</span>
                </label>
                <div>{new Date(user.created_at).toLocaleDateString()}</div>
            </div>

            <!-- Email Verified Date -->
            {#if user.email_verified_at}
                <div>
                    <label class="label">
                        <span class="label-text font-semibold">Email Verified</span>
                    </label>
                    <div>{new Date(user.email_verified_at).toLocaleDateString()}</div>
                </div>
            {/if}
        </div>
    </div>
</div>