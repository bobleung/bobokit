<script>
  import { router } from '@inertiajs/svelte';
  
  // Entity type to icon mapping
  const ENTITY_ICONS = {
    Agency: 'handshake',
    Client: 'home_health',
    default: 'person'
  };
  
  let { currentEntity = null, availableEntities = [], pendingInvites = [] } = $props();
  
  let dropdownOpen = $state(false);
  
  // Get icon for entity type
  function getEntityIcon(type) {
    return ENTITY_ICONS[type] || ENTITY_ICONS.default;
  }
  
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
  
  function goToEntityProfile() {
    if (currentEntity) {
      dropdownOpen = false;
      router.visit(`/organisations/${currentEntity.id}`);
    }
  }
  
  function acceptInvitation(inviteId) {
    dropdownOpen = false;
    router.post(`/memberships/${inviteId}/accept`);
  }
  
  function declineInvitation(inviteId) {
    dropdownOpen = false;
    router.post(`/memberships/${inviteId}/decline`);
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
          {getEntityIcon(currentEntity.type)}
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
  
  <ul class="dropdown-content menu bg-base-100 rounded-box z-[1] mt-4 w-64 p-2 shadow-lg">
    <!-- Current Entity Management -->
    {#if currentEntity}
      <li>
        <button
          class="flex items-center gap-3 p-3 hover:bg-base-300"
          onclick={goToEntityProfile}
        >
          <span class="material-symbols-outlined">settings</span>
          <div class="flex flex-col items-start">
            <span class="font-medium">Manage {currentEntity.name}</span>
            <span class="text-xs opacity-70">View and edit settings</span>
          </div>
        </button>
      </li>
      
      <div class="divider my-1">Switch Entity</div>
    {/if}
    
    <!-- Available Entities List -->
    {#each availableEntities as entity}
      <li>
        <button
          class="flex items-center gap-3 p-3"
          class:active={currentEntity?.id === entity.id}
          onclick={() => handleEntitySwitch(entity.id)}
        >
          <span class="material-symbols-outlined">
            {getEntityIcon(entity.type)}
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
    
    <!-- Pending Invitations -->
    {#if pendingInvites.length > 0}
      <div class="divider my-1">Pending Invitations</div>
      
      {#each pendingInvites as invite}
        <li>
          <div class="p-3">
            <div class="flex items-center gap-3 mb-2">
              <span class="material-symbols-outlined text-warning">
                {getEntityIcon(invite.entity.type)}
              </span>
              <div class="flex flex-col items-start flex-1">
                <span class="font-medium">{invite.entity.name}</span>
                <span class="text-xs opacity-70">{invite.entity.type} • {invite.role}</span>
              </div>
            </div>
            <div class="flex gap-2">
              <button 
                class="btn btn-success btn-xs flex-1"
                onclick={() => acceptInvitation(invite.id)}
              >
                <span class="material-symbols-outlined text-xs">check</span>
                Accept
              </button>
              <button 
                class="btn btn-error btn-xs flex-1"
                onclick={() => declineInvitation(invite.id)}
              >
                <span class="material-symbols-outlined text-xs">close</span>
                Decline
              </button>
            </div>
          </div>
        </li>
      {/each}
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