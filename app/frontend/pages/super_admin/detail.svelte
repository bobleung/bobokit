<script>
    import FormInput from "../../components/FormInput.svelte";
    import { router } from "@inertiajs/svelte";

    let { user } = $props()
    let data = $derived(user ? { ...user } : null);
    let emailVerified = $state(false);
    
    // Update emailVerified when data changes
    $effect(() => {
        emailVerified = data ? !!data.email_verified_at : false;
    });

    function handleSubmit(event){
        event.preventDefault();
        
        if (!data || !data.id) {
            console.error("No user data or ID available");
            return;
        }

        const updateData = {
            user: {
                first_name: data.first_name,
                last_name: data.last_name,
                email_address: data.email_address,
                super_admin: data.super_admin,
                email_verified_at: emailVerified ? new Date().toISOString() : null
            }
        };

        router.patch(`/super/users/${data.id}`, updateData);
    }

</script>

<!-- Form -->
{#if data}
<form
    onsubmit={handleSubmit}
    class="flex grow card card-body card-border shadow-sm w-full max-w-full max-h-full my-6"
>
    <!-- Form Title -->
    <div class="flex items-left gap-2">
        <span class="material-symbols-outlined">edit</span>
        <h2 class="card-title">Edit User</h2>
    </div>

    <!-- Form Fields : Basic Info -->
    <fieldset class="fieldset">
        <legend class="fieldset-legend">Basic Info</legend>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
            <FormInput bind:value={data.first_name} label="First Name" type="text"></FormInput>
            <FormInput bind:value={data.last_name} label="Last Name" type="text"></FormInput>
            <FormInput bind:value={data.email_address} label="Email" type="email"></FormInput>
            <label class="label text-base-content">
                Super Admin
                <input type="checkbox" bind:checked={data.super_admin} class="toggle toggle-success" />
            </label>
            <label class="label text-base-content">
                Email Verified
                <input type="checkbox" bind:checked={emailVerified} class="toggle toggle-success" />
            </label>
        </div>
    </fieldset>

    <!-- Divider -->
    <div class="divider"></div>

    <!-- Action Buttons -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <button class="btn btn-primary">Save</button>
    </div>
      
      

</form>
{/if}