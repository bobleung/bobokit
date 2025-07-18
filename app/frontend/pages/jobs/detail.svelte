<script>
    import {FormCheckbox, FormInput, JobTimePicker} from "@components"
    import { getJobDuration } from "@utils"
    
    // Get props from parent
    let { data, type, onClose, onUpdate, onDelete } = $props()

    // Make a local copy
    let localData = $state()
    let duration = $derived(
        localData 
            ? getJobDuration(localData.start, localData.end, localData.break_minutes)
            : { minutes: 0, hours: 0, hoursAndMinutes: '0h 00m', hoursAndMinutesShort: '0h' }
    );

    $effect(() => {
        localData = data ? structuredClone(data): null
    })

    function onsubmit(event){
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

    // Logging
    $inspect("localData: ", localData)
</script>

{#if localData}
    <div class="card shadow-sm w-full max-w-full h-full">
         <!-- Panel Header -->
        <div class="flex items-center justify-between px-4 py-2 gap-4 bg-base-200 rounded-t-lg">
            <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-xl">edit</span>
                <h2 class="text-lg font-semibold">Edit ({duration.hoursAndMinutesShort})</h2>
            </div>
            <button type="button" class="btn btn-ghost btn-xs btn-square" onclick={onClose}>
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
    

     <!-- Form -->
    
     <form
        {onsubmit}
        class="card-body overflow-auto">

        <!-- Form Fields : Basic Info -->
        <fieldset class="fieldset">
            <legend class="fieldset-legend">Basic Info</legend>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
                <span class="col-span-2"><JobTimePicker
                    bind:start={localData.start}
                    bind:end={localData.end}
                    bind:break_minutes={localData.break_minutes}>
                </JobTimePicker></span>
                <FormInput bind:value={localData.agency.name} label="Agency" type="text"></FormInput>
                <FormInput bind:value={localData.client.name} label="Client" type="text"></FormInput>
                <FormInput bind:value={localData.locum.name} label="Locum" type="text"></FormInput>
            </div>
        </fieldset>

        <!-- Form Fields : Actuals -->
        <fieldset class="fieldset">
            <legend class="fieldset-legend">Actual Worked Time</legend>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
                <span class="col-span-2"><JobTimePicker
                    bind:start={localData.actual_start}
                    bind:end={localData.actual_end}
                    bind:break_minutes={localData.actual_break_minutes}>
                </JobTimePicker></span>
            </div>
        </fieldset>

        <!-- Form Fields : Notes -->
        <fieldset class="fieldset">
            <legend class="fieldset-legend">Notes</legend>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
                <FormInput bind:value={localData.notes_job} label="Notes Job" type="text"></FormInput>
                <FormInput bind:value={localData.notes_client} label="Notes (by Client)" type="text"></FormInput>
                <FormInput bind:value={localData.notes_agency} label="Notes (by Agency)" type="text"></FormInput>
            </div>
        </fieldset>

        <!-- Divider -->
        <div class="divider"></div>

            <!-- Action Buttons -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <button class="btn btn-primary">Update2</button>
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