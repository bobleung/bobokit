<script>
    import FormCheckbox from "@components/FormCheckbox.svelte";
    import FormInput from "@components/FormInput.svelte";
    
    // Get props from parent
    let { data, type, onClose } = $props()

    // Make a local copy
    let localData = $state()

    $effect(() => {
        localData = data ? structuredClone(data): null
    })

    function handleSubmit(){
        console.log("Update")
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

{:else}
    Select an organisation to view details
{/if}