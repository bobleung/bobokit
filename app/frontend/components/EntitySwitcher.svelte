<script>
  import { router } from '@inertiajs/svelte';
  
  let { currentEntity = null, availableEntities = [], userContext = null } = $props();
  
  let dropdownOpen = $state(false);
  
  function handleEntitySwitch(entityId) {
    dropdownOpen = false;
    router.post('/user/switch_context', { entity_id: entityId });
  }
  
  function toggleDropdown() {
    dropdownOpen = !dropdownOpen;
  }
  
  function closeDropdown() {
    dropdownOpen = false;
  }
</script>

<div class="dropdown" class:dropdown-open={dropdownOpen}>
  <div
    tabindex="0" 
    role="button" 
    class="btn btn-ghost btn-sm gap-2"
    onclick={toggleDropdown}
    onblur={closeDropdown}
  >
    {#if currentEntity}
      <div class="flex items-center gap-2">
        <span class="material-symbols-outlined text-sm">
          {#if currentEntity.type === 'Agency'}business{:else if currentEntity.type === 'Client'}corporate_fare{:else}person{/if}
        </span>
        <div class="flex flex-col items-start">
          <span class="text-sm font-medium">{currentEntity.name}</span>
          <span class="text-xs opacity-70">{currentEntity.type}</span>
        </div>
      </div>
    {:else}
      <span class="text-sm">Select Entity</span>
    {/if}
    <span class="material-symbols-outlined text-sm">expand_more</span>
  </div>
  
  <ul tabindex="0" class="dropdown-content menu bg-base-200 rounded-box z-[1] w-64 p-2 shadow-lg">
    {#each availableEntities as entity}
      <li>
        <button
          class="flex items-center gap-3 p-3"
          class:active={currentEntity?.id === entity.id}
          onclick={() => handleEntitySwitch(entity.id)}
        >
          <span class="material-symbols-outlined">
            {#if entity.type === 'Agency'}business{:else if entity.type === 'Client'}corporate_fare{:else}person{/if}
          </span>
          <div class="flex flex-col items-start">
            <span class="font-medium">{entity.name}</span>
            <span class="text-xs opacity-70">{entity.type}</span>
          </div>
          {#if currentEntity?.id === entity.id}
            <span class="material-symbols-outlined text-primary ml-auto">check</span>
          {/if}
        </button>
      </li>
    {/each}
    
    {#if availableEntities.length === 0}
      <li>
        <span class="text-sm opacity-70 p-3">No entities available</span>
      </li>
    {/if}
    
    <div class="divider my-1"></div>
    
    <li>
      <a href="/organisations/new" class="flex items-center gap-3 p-3">
        <span class="material-symbols-outlined">add</span>
        <span>Create New Entity</span>
      </a>
    </li>
  </ul>
</div>