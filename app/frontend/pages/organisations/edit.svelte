<script>
  import { router } from '@inertiajs/svelte';
  import { Link } from '@inertiajs/svelte';

  let { organisation = {}, membership = {}, members = [], organisation_types = [], errors = {} } = $props();
  
  let name = $state(organisation.name || '');
  let email = $state(organisation.email || '');
  let phone = $state(organisation.phone || '');
  let address_line1 = $state(organisation.address_line1 || '');
  let address_line2 = $state(organisation.address_line2 || '');
  let city = $state(organisation.city || '');
  let county = $state(organisation.county || '');
  let postcode = $state(organisation.postcode || '');
  let country = $state(organisation.country || 'GB');
  let code_type = $state(organisation.code_type || '');
  let code = $state(organisation.code || '');
  let note = $state(organisation.note || '');

  function handleSubmit(event) {
    event.preventDefault();

    router.patch(`/organisations/${organisation.id}`, {
      organisation: {
        name,
        email,
        phone,
        address_line1,
        address_line2,
        city,
        county,
        postcode,
        country,
        code_type,
        code,
        note
      }
    });
  }
  
  // Entity type to icon mapping
  const ENTITY_ICONS = {
    Agency: 'handshake',
    Client: 'home_health',
    default: 'person'
  };
  
  function getEntityIcon(type) {
    return ENTITY_ICONS[type] || ENTITY_ICONS.default;
  }
  
  // Check if current user is owner and can deactivate
  const isOwner = $derived(membership.role === 'owner');
  const hasOtherMembers = $derived(members.length > 1);
  const canDeactivate = $derived(isOwner && !hasOtherMembers);
  
  function handleDeactivate() {
    if (!canDeactivate) return;
    
    const confirmMessage = `Are you sure you want to deactivate "${organisation.name}"? This will make it unavailable for new bookings and hide it from the organisation switcher. This action cannot be undone.`;
    
    if (confirm(confirmMessage)) {
      router.patch(`/organisations/${organisation.id}/deactivate`);
    }
  }
</script>

<div class="min-h-[calc(100vh-4rem)] p-4">
  <div class="max-w-2xl mx-auto">
    <form onsubmit={handleSubmit}>
      <div class="card bg-base-200 shadow-sm">
        <div class="card-body">
          <div class="text-center mb-6">
            <div class="avatar avatar-placeholder mb-4">
              <div class="bg-accent text-primary-content rounded-full w-16">
                <span class="material-symbols-outlined" style="font-size: 2.5rem">
                  {getEntityIcon(organisation.type)}
                </span>
              </div>
            </div>
            <h2 class="card-title justify-center text-2xl mb-2">
              {organisation.name}
            </h2>
            <p class="text-base-content/70">
              Update your {organisation.type.toLowerCase()} information
            </p>
          </div>

          {#if errors && Object.keys(errors).length > 0}
            <div class="alert alert-error mb-4">
              {#each Object.entries(errors) as [field, messages]}
                {#each messages as message}
                  <p>{field.charAt(0).toUpperCase() + field.slice(1)} {message}</p>
                {/each}
              {/each}
            </div>
          {/if}

          <!-- Organisation Type (Read-only) -->
          <div class="form-control mb-4">
            <label class="label">
              <span class="label-text font-medium">Organisation Type</span>
            </label>
            <div class="bg-base-100 border border-base-300 rounded-lg p-3">
              <span class="text-base-content">{organisation.type}</span>
              <span class="text-xs text-base-content/50 ml-2">(Cannot be changed)</span>
            </div>
          </div>

          <!-- Basic Information -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="form-control">
              <label class="label">
                <span class="label-text">Organisation Name *</span>
              </label>
              <input
                type="text"
                class="input input-bordered"
                placeholder="Enter organisation name"
                bind:value={name}
                required
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Email</span>
              </label>
              <input
                type="email"
                class="input input-bordered"
                placeholder="contact@organisation.com"
                bind:value={email}
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Phone</span>
              </label>
              <input
                type="tel"
                class="input input-bordered"
                placeholder="+44 20 1234 5678"
                bind:value={phone}
              />
            </div>

            {#if organisation.type === 'Locum'}
              <div class="form-control">
                <label class="label">
                  <span class="label-text">Licence Type</span>
                </label>
                <select class="select select-bordered" bind:value={code_type}>
                  <option value="">Select licence type</option>
                  <option value="GMC">GMC (General Medical Council)</option>
                  <option value="NMC">NMC (Nursing and Midwifery Council)</option>
                  <option value="HCPC">HCPC (Health and Care Professions Council)</option>
                  <option value="Other">Other</option>
                </select>
              </div>
            {:else if organisation.type === 'Client'}
              <div class="form-control">
                <label class="label">
                  <span class="label-text">Facility Type</span>
                </label>
                <select class="select select-bordered" bind:value={code_type}>
                  <option value="">Select facility type</option>
                  <option value="Hospital">Hospital</option>
                  <option value="GP Surgery">GP Surgery</option>
                  <option value="Care Home">Care Home</option>
                  <option value="Prison">Prison</option>
                  <option value="Other">Other</option>
                </select>
              </div>
            {/if}
          </div>

          {#if organisation.type === 'Locum' && code_type}
            <div class="form-control">
              <label class="label">
                <span class="label-text">Licence Number</span>
              </label>
              <input
                type="text"
                class="input input-bordered"
                placeholder="Enter licence number"
                bind:value={code}
              />
            </div>
          {:else if organisation.type === 'Client' && code_type}
            <div class="form-control">
              <label class="label">
                <span class="label-text">Facility Code</span>
              </label>
              <input
                type="text"
                class="input input-bordered"
                placeholder="Enter facility code (if applicable)"
                bind:value={code}
              />
            </div>
          {/if}

          <!-- Address -->
          <div class="divider">Address</div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="form-control">
              <label class="label">
                <span class="label-text">Address Line 1</span>
              </label>
              <input
                type="text"
                class="input input-bordered"
                placeholder="House number and street name"
                bind:value={address_line1}
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Address Line 2</span>
              </label>
              <input
                type="text"
                class="input input-bordered"
                placeholder="Flat, building, etc. (optional)"
                bind:value={address_line2}
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">City</span>
              </label>
              <input
                type="text"
                class="input input-bordered"
                placeholder="City"
                bind:value={city}
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">County</span>
              </label>
              <input
                type="text"
                class="input input-bordered"
                placeholder="County"
                bind:value={county}
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Postcode</span>
              </label>
              <input
                type="text"
                class="input input-bordered"
                placeholder="SW1A 1AA"
                bind:value={postcode}
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Country</span>
              </label>
              <select class="select select-bordered" bind:value={country}>
                <option value="GB">United Kingdom</option>
                <option value="IE">Ireland</option>
                <option value="US">United States</option>
                <option value="CA">Canada</option>
                <option value="AU">Australia</option>
              </select>
            </div>
          </div>

          <!-- Notes -->
          <fieldset class="form-control">
            <legend class="label">
              <span class="label-text">Notes</span>
            </legend>
            <textarea
              class="textarea textarea-bordered h-24"
              placeholder="Additional information (optional)"
              bind:value={note}
            ></textarea>
          </fieldset>

          <div class="flex flex-col sm:flex-row gap-3 mt-6">
            <button type="submit" class="btn btn-primary flex-1">
              <span class="material-symbols-outlined">save</span>
              Save Changes
            </button>
            <Link href="/organisations/{organisation.id}" class="btn btn-ghost flex-1">
              Cancel
            </Link>
          </div>
        </div>
      </div>
    </form>

    <!-- Deactivation Section -->
    <div class="card bg-base-100 shadow-sm mt-6">
      <div class="card-body">
        <h3 class="text-lg font-semibold text-error mb-4">
          <span class="material-symbols-outlined mr-2">warning</span>
          Danger Zone
        </h3>
        
        {#if isOwner}
          {#if hasOtherMembers}
            <div class="alert alert-warning mb-4">
              <span class="material-symbols-outlined">group</span>
              <div>
                <p class="font-medium">Cannot Deactivate Organisation</p>
                <p class="text-sm">You must remove all other members before deactivating this organisation. Only the owner can remain.</p>
              </div>
            </div>
          {:else}
            <div class="alert alert-error mb-4">
              <span class="material-symbols-outlined">info</span>
              <div>
                <p class="font-medium">Deactivate Organisation</p>
                <p class="text-sm">This will make the organisation unavailable for new bookings and hide it from the organisation switcher. Historical data will be preserved.</p>
              </div>
            </div>
          {/if}
          
          <button 
            class="btn btn-error"
            disabled={!canDeactivate}
            onclick={handleDeactivate}
          >
            <span class="material-symbols-outlined">block</span>
            Deactivate Organisation
          </button>
        {:else}
          <div class="alert alert-info">
            <span class="material-symbols-outlined">info</span>
            <div>
              <p class="font-medium">Owner Access Required</p>
              <p class="text-sm">Only organisation owners can deactivate an organisation. Contact your organisation owner if you need to deactivate this organisation.</p>
            </div>
          </div>
        {/if}
      </div>
    </div>
  </div>
</div>