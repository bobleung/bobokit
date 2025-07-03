<script>
    import { router, Link } from "@inertiajs/svelte";

    let email = $state('');
    let password = $state('');
    let password_confirmation = $state('');

    function handleSubmit(event) {
        event.preventDefault();

        router.post('/users', {
            user: {
                email_address: email,
                password: password,
                password_confirmation: password_confirmation
            }
        });
    }
</script>

<div class="min-h-screen flex items-center justify-center">
    <form onsubmit={handleSubmit}>
        <div class="card w-96 bg-base-200 card-lg shadow-sm">
            <div class="card-body flex flex-col gap-4">
                <h2 class="card-title">Sign up</h2>
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
                <label class="input validator">
                    <span class="material-symbols-outlined opacity-50">key_vertical</span>
                    <input 
                        type="password"
                        class="grow"
                        placeholder="Password Confirmation"
                        bind:value={password_confirmation}
                        required
                        minlength="3"
                        maxlength="30"
                    />
                </label>
                <p class="validator-hint">
                    Invalid Email or Password.
                </p>
                <div class="flex flex-col items-end gap-2">
                    <button type="submit" class="btn btn-primary">Sign up</button>
                    <Link href="/login" class="link">Back to login</Link>
                </div>
            </div>
        </div>
    </form>
</div>