<script>
    import FormInput from "../../components/FormInput.svelte";
    import { router } from "@inertiajs/svelte";

    let { user } = $props()
    let data = $derived(user ? { ...user } : null);
    let emailVerified = $state(false);
    // let deactivated = $state(false);
    
    // Update emailVerified and deactivated when data changes
    $effect(() => {
        emailVerified = data ? !!data.email_verified_at : false;
        // deactivated = data ? !!data.deactivated : false;
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
            <label class="label text-base-content">
                Deactivate
                <input type="checkbox" bind:checked={data.deactivated} class="toggle toggle-success" />
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

<!-- Deletion User Section -->
{#if data}
    <!-- Button to trigger modal -->
    <div class="flex justify-center md:justify-end w-full max-w-full">
        <button class="btn btn-link text-base-content link-hover" onclick={openModal}>Delete this User</button>
    </div>

    <!-- Modal -->
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
{/if}