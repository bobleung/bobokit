<script>
    import {FormCheckbox, FormInput} from "@components"
    
    // Get props from parent
    let { data, type, onClose, onUpdate, onDelete } = $props()

    // Make a local copy
    let localData = $state()

    $effect(() => {
        localData = data ? structuredClone(data): null
    })

    function handleSubmit(event){
        event.preventDefault();
        console.log("Update");
        onUpdate(localData);
    }

    // Setup Deletion Modal
    let modal = $state();
    let confirmDeletion = $state(false);

    function openModal() {
        confirmDeletion = false;
        modal.showModal();
    }
</script>

{#if localData}
    <div class="card shadow-sm w-full max-w-full max-h-full">
         <!-- Panel Header -->
        <div class="flex items-center justify-between px-4 py-2 gap-4 bg-base-200 rounded-t-lg">
            <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-xl">edit</span>
                <h2 class="text-lg font-semibold">Edit {type}</h2>
            </div>
            <button type="button" class="btn btn-ghost btn-xs btn-square" onclick={onClose}>
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
                <FormInput bind:value={localData.name} label="{type} Name" type="text"></FormInput>
                <FormInput bind:value={localData.email} label="Email" type="email"></FormInput>
            </div>
        </fieldset>

        <!-- Form Fields : Address -->
        <fieldset class="fieldset">
            <legend class="fieldset-legend">Address</legend>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
                <FormInput bind:value={localData.address_line1} label="Address Line 1" type="text"></FormInput>
                <FormInput bind:value={localData.address_line2} label="Address Line 2" type="text"></FormInput>
                <FormInput bind:value={localData.city} label="City" type="text"></FormInput>
                <FormInput bind:value={localData.county} label="County" type="text"></FormInput>
                <FormInput bind:value={localData.postcode} label="Postcode" type="text"></FormInput>
                <FormInput bind:value={localData.country} label="Country" type="text"></FormInput>
            </div>
        </fieldset>

        <!-- Form Fields : Advanced Settings -->
        <fieldset class="fieldset">
            <legend class="fieldset-legend">Advanced Settings</legend>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
                <FormCheckbox bind:value={localData.active} label="Active"></FormCheckbox>
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
    <button class="btn btn-link text-base-content link-hover" onclick={openModal}>Delete this {type}</button>
</div>

<!-- Delete Modal -->
<dialog bind:this={modal} class="modal">
    <div class="modal-box bg-warning text-warning-content/75">
        <h3 class="font-bold text-lg">Delete {localData.name}?</h3>
        <p class="py-4">This action is irreversible. Deleting this {type} will permanently remove it from the system. Associated users will not be deleted, but they will no longer have access to the system.</p>
        
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
                    onclick={onDelete(localData.id)}
                    disabled={!confirmDeletion}
                >
                    Yes, Delete
                </button>
                <button class="btn">Cancel</button>
            </form>
        </div>
    </div>
</dialog>

{:else}
    Select an organisation to view details
{/if}