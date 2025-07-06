<script>
  import { router } from '@inertiajs/svelte';
  import { Link } from '@inertiajs/svelte';

  let { organisation_types = [], errors = {}, organisation = {} } = $props();
  
  let type = $state(organisation.type || '');
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

    router.post('/organisations', {
      organisation: {
        type,
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
  
  const typeDescriptions = {
    Agency: 'Recruitment agencies that place locums',
    Client: 'Healthcare facilities that hire locums',
    Locum: 'Individual healthcare professionals'
  };
</script>

<div class="min-h-[calc(100vh-4rem)] flex items-center justify-center p-4">
  <form onsubmit={handleSubmit} class="w-full max-w-2xl">
    <div class="card bg-base-200 shadow-sm">
      <div class="card-body">
        <div class="text-center mb-6">
          <h2 class="card-title justify-center text-2xl mb-2">
            Create New Organisation
          </h2>
          <p class="text-base-content/70">
            Choose the type of organisation you want to create
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

        <!-- Organisation Type Selection -->
        <div class="form-control mb-4">
          <label class="label">
            <span class="label-text font-medium">Organisation Type *</span>
          </label>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            {#each organisation_types as org_type}
              <label class="cursor-pointer">
                <input
                  type="radio"
                  name="type"
                  value={org_type}
                  bind:group={type}
                  class="radio radio-primary"
                  required
                />
                <div class="card bg-base-100 border-2 ml-3 p-4" class:border-primary={type === org_type}>
                  <div class="card-body p-0">
                    <h3 class="font-medium">{org_type}</h3>
                    <p class="text-sm text-base-content/70">{typeDescriptions[org_type]}</p>
                  </div>
                </div>
              </label>
            {/each}
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

          {#if type === 'Locum'}
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
          {:else if type === 'Client'}
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

        {#if type === 'Locum' && code_type}
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
        {:else if type === 'Client' && code_type}
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
          <div class="form-control md:col-span-2">
            <label class="label">
              <span class="label-text">Address Line 1</span>
            </label>
            <input
              type="text"
              class="input input-bordered"
              placeholder="Street address"
              bind:value={address_line1}
            />
          </div>

          <div class="form-control md:col-span-2">
            <label class="label">
              <span class="label-text">Address Line 2</span>
            </label>
            <input
              type="text"
              class="input input-bordered"
              placeholder="Apartment, suite, etc. (optional)"
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
        <div class="form-control">
          <label class="label">
            <span class="label-text">Notes</span>
          </label>
          <textarea
            class="textarea textarea-bordered"
            placeholder="Additional information (optional)"
            bind:value={note}
          ></textarea>
        </div>

        <div class="flex flex-col sm:flex-row gap-3 mt-6">
          <button type="submit" class="btn btn-primary flex-1">
            <span class="material-symbols-outlined">add</span>
            Create Organisation
          </button>
          <Link href="/" class="btn btn-ghost flex-1">
            Cancel
          </Link>
        </div>
      </div>
    </div>
  </form>
</div>