<script>
    import { router, Link } from "@inertiajs/svelte";

    let { user = {}, errors = {} } = $props();

    let first_name = $state(user.first_name || '');
    let last_name = $state(user.last_name || '');
    let email = $state(user.email_address || '');
    let password = $state('');
    let password_confirmation = $state('');
    let showPasswordFields = $state(false);

    function handleSubmit(event) {
        event.preventDefault();

        const updateData = {
            user: {
                first_name: first_name,
                last_name: last_name,
                email_address: email
            }
        };

        if (showPasswordFields && password) {
            updateData.user.password = password;
            updateData.user.password_confirmation = password_confirmation;
        }

        router.patch('/profile', updateData);
    }

    function togglePasswordFields() {
        showPasswordFields = !showPasswordFields;
        if (!showPasswordFields) {
            password = '';
            password_confirmation = '';
        }
    }
</script>

<div class="min-h-[calc(100vh-4rem)] flex items-center justify-center">
    <form onsubmit={handleSubmit}>
        <div class="card w-96 bg-base-200 card-lg shadow-sm">
            <div class="card-body flex flex-col gap-4">
                <h2 class="card-title">Profile</h2>
                {#if errors && Object.keys(errors).length > 0}
                    <div class="alert alert-error">
                        {#each Object.entries(errors) as [field, messages]}
                            {#each messages as message}
                                <p>{field.charAt(0).toUpperCase() + field.slice(1)} {message}</p>
                            {/each}
                        {/each}
                    </div>
                {/if}
                <label class="input validator">
                    <span class="material-symbols-outlined opacity-50">person</span>
                    <input
                        type="text"
                        class="grow"
                        placeholder="First Name"
                        bind:value={first_name}
                        required
                    />
                </label>
                <label class="input validator">
                    <span class="material-symbols-outlined opacity-50">person</span>
                    <input
                        type="text"
                        class="grow"
                        placeholder="Last Name"
                        bind:value={last_name}
                        required
                    />
                </label>
                <label class="input validator">
                    <span class="material-symbols-outlined opacity-50">mail</span>
                    <input
                        type="email"
                        class="grow"
                        placeholder="Email"
                        bind:value={email}
                        required
                    />
                </label>
                
                {#if !user?.email_verified}
                    <p class="text-sm text-warning">
                        <span class="material-symbols-outlined text-warning inline-block mr-1" style="font-size: 1rem;">warning</span>
                        <Link href="/email_verification" class="link link-warning">
                            Email unverified
                        </Link>
                    </p>
                {/if}
                
                <div class="divider">Password</div>
                
                {#if !showPasswordFields}
                    <p class="text-sm text-base-content/70">
                        <button type="button" class="link" onclick={togglePasswordFields}>
                            Click here to change your password
                        </button>
                    </p>
                {:else}
                    <p class="text-sm text-base-content/70 mb-2">
                        Fill in both fields only if you want to change your password. 
                        <button type="button" class="link" onclick={togglePasswordFields}>
                            Cancel password change
                        </button>
                    </p>
                    <label class="input validator">
                        <span class="material-symbols-outlined opacity-50">key_vertical</span>
                        <input 
                            type="password"
                            class="grow"
                            placeholder="New Password"
                            bind:value={password}
                            minlength="3"
                            maxlength="30"
                        />
                    </label>
                    <label class="input validator">
                        <span class="material-symbols-outlined opacity-50">key_vertical</span>
                        <input 
                            type="password"
                            class="grow"
                            placeholder="Confirm New Password"
                            bind:value={password_confirmation}
                            minlength="3"
                            maxlength="30"
                            pattern={password}
                            title="Password confirmation must match password"
                        />
                    </label>
                {/if}
                
                <p class="validator-hint">
                    Invalid Email or Password.
                </p>
                <div class="flex flex-col items-end gap-2">
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </div>
        </div>
    </form>
</div>