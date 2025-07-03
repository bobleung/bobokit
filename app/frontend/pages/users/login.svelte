<script>
    import { router, Link } from "@inertiajs/svelte";
    
    let { errors = {} } = $props();
    
    let email = $state('');
    let password = $state('');

    function handleSubmit(event) {
        event.preventDefault();

        router.post('/session', {
            email_address: email,
            password: password
        });
    }
</script>

<div class="min-h-screen flex items-center justify-center">
    <form onsubmit={handleSubmit}>
        <div class="card w-96 bg-base-200 card-lg shadow-sm">
            <div class="card-body flex flex-col gap-4">
                <h2 class="card-title">Login</h2>
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
                    <span class="material-symbols-outlined opacity-50">search</span>
                    <input
                        type="email"
                        class="grow"
                        placeholder="Email"
                        bind:value={email}
                        required
                    />
                </label>
                <label class="input validator">
                    <span class="material-symbols-outlined opacity-50">key_vertical</span>
                    <input 
                        type="password"
                        class="grow"
                        placeholder="Password"
                        bind:value={password}
                        required
                        minlength="3"
                        maxlength="30"
                    />
                </label>
                <p class="validator-hint">
                    Invalid Email or Password.
                </p>
                <div class="flex flex-col items-end gap-2">
                    <button type="submit" class="btn btn-primary">Login</button>
                    <p>No Account? <Link href="/signup" class="link">Sign up here.</Link></p>
                </div>
            </div>
        </div>
    </form>
</div>