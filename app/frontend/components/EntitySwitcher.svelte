<script>
  import { router } from '@inertiajs/svelte';
  import { Link } from '@inertiajs/svelte';
  
  // Entity type to icon mapping
  const ENTITY_ICONS = {
    Agency: 'handshake',
    Client: 'home_health',
    default: 'person'
  };

  let { currentEntity = null, availableEntities = [], pendingInvites = [], user = null } = $props();

  // $inspect("current entity mount: ", currentEntity)
  
  // Get icon for entity type
  function getEntityIcon(type) {
    return ENTITY_ICONS[type] || ENTITY_ICONS.default;
  }
  
  // Generate display name: "Bob (Freshmedic Ltd)"
  const displayName = $derived(
    user && currentEntity 
      ? `${user.first_name} (${currentEntity.name})`
      : user 
        ? user.first_name
        : 'User'
  );
  
  function handleEntitySwitch(entityId) {
    console.log("current entity : ", currentEntity)
    document.activeElement.blur();
    router.post('/user/switch_context', { entity_id: entityId });
    console.log("current entity after : ", currentEntity)
  }
  
  function acceptInvitation(inviteId) {
    document.activeElement.blur();
    router.post(`/memberships/${inviteId}/accept`);
  }
  
  function declineInvitation(inviteId) {
    document.activeElement.blur();
    router.post(`/memberships/${inviteId}/decline`);
  }
  
</script>

<div class="dropdown dropdown-end">
  <div
    tabindex="0" 
    role="button" 
    class="btn btn-ghost btn-sm gap-2"
  >
    <div class="flex items-center gap-2">
      <span class="material-symbols-outlined text-sm">
        {#if currentEntity}
          {getEntityIcon(currentEntity.type)}
        {:else}
          person
        {/if}
      </span>
      <span class="text-sm font-medium">{displayName}</span>
    </div>
    <span class="material-symbols-outlined text-sm">expand_more</span>
    </div>
  
  <ul tabindex="-1" class="dropdown-content menu bg-base-100 rounded-box z-[1] mt-4 w-64 p-2 shadow-lg">
    <!-- User Profile Options -->
    <li>
      <Link href="/profile" class="flex items-center gap-3 p-3" onclick={() => document.activeElement.blur()}>
        <span class="material-symbols-outlined">person</span>
        <span>Profile</span>
      </Link>
    </li>
    <li>
      <Link href="/logout" class="flex items-center gap-3 p-3" onclick={() => document.activeElement.blur()}>
        <span class="material-symbols-outlined">logout</span>
        <span>Log Out</span>
      </Link>
    </li>
    
    <div class="divider my-1"></div>
    
    <!-- Current Entity Management -->
    {#if currentEntity}
      <li>
        <button
          class="flex items-center gap-3 p-3 w-full text-left hover:bg-base-200"
          onclick={() => {
            document.activeElement.blur();
            router.get(`/organisations/${currentEntity.id}`);
          }}
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
          class="flex items-center gap-3 p-3 {currentEntity?.id === entity.id ? 'active' : ''}"
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
          <div class="flex flex-col gap-3
           p-3">
            <div class="flex gap-3 items-center w-full">
              <span class="material-symbols-outlined">
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
      <Link href="/organisations/new" method="get" class="flex items-center gap-3 p-3" onclick={() => document.activeElement.blur()}>
        <span class="material-symbols-outlined">add</span>
        <span>Create New Entity</span>
      </Link>
    </li>
  </ul>
</div>