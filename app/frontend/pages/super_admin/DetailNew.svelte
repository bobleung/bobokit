<script>
    import FormInput from "../../components/FormInput.svelte";
    import FormCheckbox from "../../components/FormCheckbox.svelte";
    import { router } from "@inertiajs/svelte";

    let { selectedId = $bindable() } = $props()

    $inspect("Detail New selected Id: " + selectedId)

    let data = $state({
        first_name: '',
        last_name: '',
        email_address: '',
        super_admin: false,
        password:'',
    })

    let emailVerified = $state(false)

    function closePanel(){
        selectedId = null
    }

    function handleSubmit(event) {
        event.preventDefault();

        const submitData = {
            user: {
                first_name: data.first_name,
                last_name: data.last_name,
                email_address: data.email_address,
                super_admin: data.super_admin,
                password: data.password,
                password_confirmation: data.password, // Set password_confirmation same as password
                email_verified_at: emailVerified ? new Date().toISOString() : null
            }
        };

        router.post('/super/users', submitData, {
            onSuccess: () => {
                // Reset form
                data.first_name = '';
                data.last_name = '';
                data.email_address = '';
                data.super_admin = false;
                data.password = '';
                emailVerified = false;
                
                // Close panel
                selectedId = '';
            }
        });
    }

</script>

<div class="card shadow-sm w-full max-w-full max-h-full my-6 animate-fade-in">
    <!-- Panel Header -->
    <div class="flex items-center justify-between px-6 py-4 bg-base-200 rounded-t-lg">
        <div class="flex items-center gap-2">
            <span class="material-symbols-outlined text-xl">person</span>
            <h2 class="text-lg font-semibold">New User</h2>
        </div>
        <button type="button" class="btn btn-ghost btn-xs btn-square">
            <span class="material-symbols-outlined" onclick={closePanel}>close</span>
        </button>
    </div>
    
    <!-- Form -->
    <form
        onsubmit={handleSubmit}
        class="card-body">

        <!-- Form Fields : Basic Info -->
        <fieldset class="fieldset">
            <legend class="fieldset-legend">Basic Info</legend>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
                <FormInput bind:value={data.first_name} label="First Name" type="text"></FormInput>
                <FormInput bind:value={data.last_name} label="Last Name" type="text"></FormInput>
                <FormInput bind:value={data.email_address} label="Email" type="email"></FormInput>
                <div></div>
                <FormInput bind:value={data.password} label="Password" type="text"></FormInput>
            </div>
        </fieldset>

        <!-- Form Fields : Advanced Settings -->
        <fieldset class="fieldset">
            <legend class="fieldset-legend">Advanced Settings</legend>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
                <FormCheckbox bind:value={data.super_admin} label="Super Admin"></FormCheckbox>
                <FormCheckbox bind:value={emailVerified} label="Email Verified"></FormCheckbox>
            </div>
        </fieldset>

        <!-- Divider -->
        <div class="divider"></div>

        <!-- Action Buttons -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <button class="btn btn-primary">Create User</button>
        </div>

    </form>
</div>