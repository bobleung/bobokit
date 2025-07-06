<script>
  import { router } from '@inertiajs/svelte';
  import { Link } from '@inertiajs/svelte';
  import FormInput from '@components/FormInput.svelte';

  let { organisation = {}, membership = {}, members = [], organisation_types = [], errors = {} } = $props();
  let org = $state(organisation);

  function handleSubmit(event) {
    event.preventDefault();
    router.patch(`/organisations/${organisation.id}`, {organisation: org})
  }
  
  // Check if current user is owner and can deactivate
  const isOwner = $derived(membership.role === 'owner');
  const hasOtherMembers = $derived(members.length > 1);
  const canDeactivate = $derived(isOwner && !hasOtherMembers);
  
  function handleDeactivate() {
    router.patch(`/organisations/${organisation.id}/deactivate`);
  }

  // setup Deactivation Modal
  let modal;
  let confirmDeactivation = $state(false); // Setup confirmation checkbox

  function openModal() {
    confirmDeactivation = false; // Reset checkbox
    modal.showModal();
  }

  function closeModal() {
    modal.close();
  }
  
</script>

<!-- Page Container below nav bar -->
<div class="flex flex-col items-center px-4">
  <!-- Form -->
  <form onsubmit={handleSubmit} class="card card-body bg-base-200 shadow-sm w-full max-w-4xl my-6">

    <!-- Form Title -->
    <div class="flex items-left gap-2">
      <span class="material-symbols-outlined">edit</span>
      <h2 class="card-title">Edit {org.type}</h2>
    </div>
    
    <!-- Form Fields : Basic Info -->
    <fieldset class="fieldset">
      <legend class="fieldset-legend">Basic Info</legend>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
        <div class="md:col-span-2"><FormInput label="Name" type="text" bind:value={org.name} required></FormInput></div>
        <FormInput label="Email" type="email" bind:value={org.email} required></FormInput>
        <FormInput label="Phone" type="text" bind:value={org.phone}></FormInput>
      </div>
    </fieldset>

    <!-- Form Fields : Other Info -->
    <fieldset class="fieldset">
      <legend class="fieldset-legend">Additional Info</legend>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
        <FormInput label="Org Type" type="text" bind:value={org.code_type}></FormInput>
        <FormInput label="Org Code" type="text" bind:value={org.code}></FormInput>
      </div>
    </fieldset>
    
    <!-- Form Fields : Address -->
    <fieldset class="fieldset">
      <legend class="fieldset-legend">Address</legend>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-4">
        <FormInput label="Address Line 1" type="text" bind:value={org.address_line1}></FormInput>
        <FormInput label="Address Line 2" type="text" bind:value={org.address_line2}></FormInput>
        <FormInput label="City" type="text" bind:value={org.city}></FormInput>
        <FormInput label="County" type="text" bind:value={org.county}></FormInput>
        <FormInput label="Postcode" type="text" bind:value={org.postcode}></FormInput>
      </div>
    </fieldset>

    <!-- Validator Message -->
    <div class="validator-hint">Some fields is not valid</div>

    <!-- Divider -->
    <div class="divider"></div>

    <!-- Action Buttons -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <button class="btn btn-primary">Save</button>
      <Link href="/organisations/{org.id}" class="btn">Cancel</Link>
    </div>
  </form>

  <!-- Deactivation Org Section -->
    <!-- Button to trigger modal -->
    <div class="flex justify-center md:justify-end w-full max-w-4xl">
      <button class="btn btn-link text-base-content link-hover" onclick={openModal}>Deactivate this {org.type}</button>
    </div>

  <!-- Modal -->
  <dialog bind:this={modal} class="modal">
    <div class="modal-box bg-warning text-warning-content">
      <h3 class="font-bold text-lg">Deactivate {org.name} ?</h3>
      <p class="py-4">This action is irreversible. To proceed, you must first remove all users except the owner. Deactivation will only apply to future bookings, existing bookings will remain in the system to preserve data integrity.</p>
      
      <!-- Confirmation Checkbox -->
      <div class="form-control">
        <label class="label cursor-pointer justify-start gap-3">
          <input 
            type="checkbox" 
            class="checkbox checkbox-error" 
            bind:checked={confirmDeactivation}
          />
          <span class="label-text">I understand this action cannot be undone</span>
        </label>
      </div>
      
      <div class="modal-action">
        <form method="dialog">
          <button 
            class="btn btn-error mx-4" 
            onclick={handleDeactivate}
            disabled={!confirmDeactivation}
          >
            Yes, Deactivate
          </button>
          <button class="btn">Cancel</button>
        </form>
      </div>
    </div>
  </dialog>

  <br>
  <br>
  

</div>

