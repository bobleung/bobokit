<script>
    import FormCheckbox from "@components/FormCheckbox.svelte";
    import FormInput from "@components/FormInput.svelte";
    import { router } from "@inertiajs/svelte";

    let { user, onClose } = $props()
    let data = $state(user ? { ...user } : null);
    let emailVerified = $state(false);
    let newPassword = $state('');
  
    // Update data when user prop changes
    $effect(() => {
        if (user) {
            data = { ...user };
            emailVerified = !!user.email_verified_at;
            newPassword = ''; // Reset password field when user changes
        } else {
            data = null;
        }
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
                email_verified_at: emailVerified ? new Date().toISOString() : null,
                deactivated: data.deactivated
            }
        };

        // Only include password if a new password is provided
        if (newPassword && newPassword.trim() !== '') {
            updateData.user.password = newPassword;
            updateData.user.password_confirmation = newPassword;
        }

        router.patch(`/super/users/${data.id}`, updateData);
    }

    function handleDelete() {
        if (!data || !data.id) {
            console.error("No user data or ID available");
            return;
        }
        
        router.delete(`/super/users/${data.id}`);
    }

    // Setup Deletion Modal
    let modal = $state();
    let confirmDeletion = $state(false);

    function openModal() {
        confirmDeletion = false;
        modal.showModal();
    }

    function deselectUser(){
        if (onClose) {
            onClose();
            data = null
        }
    }

</script>


{#if data}
<div class="card shadow-sm w-full max-w-full max-h-full my-6">
    <!-- Panel Header -->
    <div class="flex items-center justify-between px-4 py-2 gap-4 bg-base-200 rounded-t-lg">
        <div class="flex items-center gap-2">
            <span class="material-symbols-outlined text-xl">edit</span>
            <h2 class="text-lg font-semibold">Edit User</h2>
        </div>
        <button type="button" class="btn btn-ghost btn-xs btn-square" onclick={deselectUser}>
            <span class="material-symbols-outlined">close</span>
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
            </div>
        </fieldset>

        <!-- Form Fields : Advanced Settings -->
        <fieldset class="fieldset">
            <legend class="fieldset-legend">Advanced Settings</legend>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
                <FormCheckbox bind:value={data.super_admin} label="Super Admin"></FormCheckbox>
                <FormCheckbox bind:value={emailVerified} label="Email Verified"></FormCheckbox>
                <FormCheckbox bind:value={data.deactivated} label="Deactivated"></FormCheckbox>
            </div>
        </fieldset>

        <!-- Form Fields : Manual Password Reset -->
        <fieldset class="fieldset">
            <legend class="fieldset-legend">Manual Password Reset</legend>
            Leave the password blank will mean user's password remains unchanged.
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
                <FormInput bind:value={newPassword} label="New Password" type="password"></FormInput>
            </div>
        </fieldset>

        <!-- Divider -->
        <div class="divider"></div>

        <!-- Action Buttons -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <button class="btn btn-primary">Update</button>
        </div>

    </form>
</div>

<!-- Button to trigger modal -->
<div class="flex justify-center md:justify-end w-full max-w-full">
    <button class="btn btn-link text-base-content link-hover" onclick={openModal}>Delete this User</button>
</div>

<!-- Delete Modal -->
<dialog bind:this={modal} class="modal">
    <div class="modal-box bg-warning text-warning-content/75">
        <h3 class="font-bold text-lg">Delete {data.first_name} {data.last_name}?</h3>
        <p class="py-4">This action is irreversible. Deleting this user will permanently remove their account and all associated data from the system.</p>
        
        <!-- Confirmation Checkbox -->
        <div class="form-control">
            <label class="label cursor-pointer justify-start gap-3">
                <input 
                    type="checkbox" 
                    class="checkbox checkbox-error" 
                    bind:checked={confirmDeletion}
                />
                <span class="label text-warning-content">I understand this action cannot be undone</span>
            </label>
        </div>
        
        <div class="modal-action">
            <form method="dialog">
                <button 
                    class="btn btn-error mx-4" 
                    onclick={handleDelete}
                    disabled={!confirmDeletion}
                >
                    Yes, Delete
                </button>
                <button class="btn">Cancel</button>
            </form>
        </div>
    </div>
</dialog>

<br>
<br>
{/if}


