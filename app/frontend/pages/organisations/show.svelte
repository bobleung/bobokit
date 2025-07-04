<script>
  import { Link, router } from '@inertiajs/svelte';

  let { organisation = {}, membership = {}, members = [] } = $props();
  
  console.log("Org Page")
  console.log("Org prop", organisation)
  console.log("Membership prop", membership)
  console.log("members prop", members)
  
  let showInviteForm = $state(false);
  let inviteEmail = $state('');
  let inviteRole = $state('member');

  // Entity type to icon mapping
  const ENTITY_ICONS = {
    Agency: 'handshake',
    Client: 'home_health',
    default: 'person'
  };

  function getEntityIcon(type) {
    return ENTITY_ICONS[type] || ENTITY_ICONS.default;
  }
  
  // Check if current user can manage members
  const canManageUsers = $derived(
    (membership.role === 'admin' || membership.role === 'owner') && 
    organisation.type !== 'Locum'
  );
  
  function handleInviteSubmit(event) {
    event.preventDefault();
    
    if (!inviteEmail.trim()) {
      return;
    }
    
    router.post(`/organisations/${organisation.id}/invite_member`, {
      email: inviteEmail,
      role: inviteRole
    });
    
    // Reset form
    inviteEmail = '';
    inviteRole = 'member';
    showInviteForm = false;
  }
  
  function toggleInviteForm() {
    showInviteForm = !showInviteForm;
    if (!showInviteForm) {
      inviteEmail = '';
      inviteRole = 'member';
    }
  }
</script>

<div class="min-h-[calc(100vh-4rem)] p-4">
  <div class="max-w-4xl mx-auto">
    <!-- Header -->
    <div class="card bg-base-200 shadow-sm mb-6">
      <div class="card-body">
        <div class="flex items-center gap-4">
          <div class="avatar placeholder">
            <div class="bg-primary text-primary-content rounded-full w-16 flex items-center justify-center">
              <span class="material-symbols-outlined text-2xl">
                {getEntityIcon(organisation.type)}
              </span>
            </div>
          </div>
          
          <div class="flex-1">
            <h1 class="text-3xl font-bold">{organisation.name}</h1>
            <p class="text-lg opacity-70">{organisation.type}</p>
            {#if organisation.email}
              <p class="text-sm opacity-60">{organisation.email}</p>
            {/if}
          </div>
          
          <div class="flex gap-2">
            <Link href="/organisations/{organisation.id}/edit" class="btn btn-outline">
              <span class="material-symbols-outlined">edit</span>
              Edit Organisation
            </Link>
          </div>
        </div>
      </div>
    </div>

    <!-- Members Section -->
    <div class="card bg-base-100 shadow-sm">
      <div class="card-body">
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center gap-3">
            <h2 class="text-xl font-semibold">Members</h2>
            <div class="badge badge-neutral">{members.length} {members.length === 1 ? 'member' : 'members'}</div>
          </div>
          
          {#if canManageUsers}
            <button class="btn btn-primary btn-sm" onclick={toggleInviteForm}>
              <span class="material-symbols-outlined">person_add</span>
              {showInviteForm ? 'Cancel' : 'Add Member'}
            </button>
          {/if}
        </div>
        
        <!-- Invitation Form -->
        {#if showInviteForm}
          <form onsubmit={handleInviteSubmit} class="bg-base-300 p-4 rounded-lg mb-4">
            <h3 class="font-semibold mb-3">Invite New Member</h3>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
              <div class="md:col-span-2">
                <input
                  type="email"
                  class="input input-bordered w-full"
                  placeholder="Enter email address"
                  bind:value={inviteEmail}
                  required
                />
              </div>
              <select class="select select-bordered" bind:value={inviteRole}>
                <option value="member">Member</option>
                <option value="admin">Admin</option>
              </select>
            </div>
            <div class="flex gap-2 mt-3">
              <button type="submit" class="btn btn-primary btn-sm" disabled={!inviteEmail.trim()}>
                <span class="material-symbols-outlined">send</span>
                Send Invitation
              </button>
              <button type="button" class="btn btn-ghost btn-sm" onclick={toggleInviteForm}>
                Cancel
              </button>
            </div>
          </form>
        {/if}
        
        {#if members.length > 0}
          <div class="space-y-3">
            {#each members as member}
              <div class="flex items-center justify-between p-4 bg-base-200 rounded-lg">
                <div class="flex items-center gap-3">
                  <div class="avatar placeholder">
                    <div class="bg-neutral text-neutral-content rounded-full w-10 h-10 flex items-center justify-center">
                      {#if member.pending_invite}
                        <span class="material-symbols-outlined text-sm">mail</span>
                      {:else}
                        <span class="text-xs font-medium">
                          {member.user.first_name.charAt(0)}{member.user.last_name.charAt(0)}
                        </span>
                      {/if}
                    </div>
                  </div>
                  <div>
                    <div class="font-medium">
                      {member.display_name}
                    </div>
                    <div class="text-sm opacity-70">
                      {member.display_email}
                      {#if member.pending_invite}
                        <span class="badge badge-warning badge-xs ml-2">Pending</span>
                      {/if}
                    </div>
                  </div>
                </div>
                
                <div class="flex items-center gap-2">
                  <div class="badge" class:badge-primary={member.role === 'owner'} class:badge-secondary={member.role === 'admin'} class:badge-ghost={member.role === 'member'}>
                    {member.role.charAt(0).toUpperCase() + member.role.slice(1)}
                  </div>
                  
                  {#if canManageUsers && member.role !== 'owner' && !member.pending_invite}
                    <div class="dropdown dropdown-end">
                      <button class="btn btn-ghost btn-xs" aria-label="Member actions">
                        <span class="material-symbols-outlined text-sm">more_vert</span>
                      </button>
                      <ul class="dropdown-content menu bg-base-100 rounded-box z-[1] w-48 p-2 shadow">
                        {#if member.role === 'member'}
                          <li>
                            <button class="text-sm">
                              <span class="material-symbols-outlined text-sm">admin_panel_settings</span>
                              Make Admin
                            </button>
                          </li>
                        {:else if member.role === 'admin'}
                          <li>
                            <button class="text-sm">
                              <span class="material-symbols-outlined text-sm">person</span>
                              Make Member
                            </button>
                          </li>
                        {/if}
                        <li>
                          <button class="text-sm text-error">
                            <span class="material-symbols-outlined text-sm">person_remove</span>
                            {member.pending_invite ? 'Cancel Invitation' : 'Remove Member'}
                          </button>
                        </li>
                      </ul>
                    </div>
                  {:else if canManageUsers && member.pending_invite}
                    <button class="btn btn-ghost btn-xs text-error">
                      <span class="material-symbols-outlined text-sm">cancel</span>
                      Cancel Invite
                    </button>
                  {/if}
                </div>
              </div>
            {/each}
          </div>
        {:else}
          <div class="text-center py-8">
            <div class="mx-auto w-16 h-16 bg-base-200 rounded-full flex items-center justify-center mb-4">
              <span class="material-symbols-outlined text-2xl opacity-50">people</span>
            </div>
            <p class="text-base-content/70">No members found</p>
          </div>
        {/if}
        
        {#if organisation.type === 'Locum'}
          <div class="alert alert-info mt-4">
            <span class="material-symbols-outlined">info</span>
            <div>
              <p class="font-medium">Individual Profile</p>
              <p class="text-sm">Locum profiles are individual accounts and cannot have additional members.</p>
            </div>
          </div>
        {/if}
      </div>
    </div>

    <!-- Coming Soon Message -->
    <div class="card bg-base-100 shadow-sm mt-6">
      <div class="card-body text-center">
        <div class="mx-auto w-16 h-16 bg-base-200 rounded-full flex items-center justify-center mb-4">
          <span class="material-symbols-outlined text-2xl opacity-50">construction</span>
        </div>
        <h3 class="text-lg font-semibold mb-2">More Features Coming Soon</h3>
        <p class="text-base-content/70 mb-4">
          Additional organisation management features in development:
        </p>
        <ul class="text-left inline-block text-base-content/70 space-y-1 mb-6 text-sm">
          <li>• Member invitations and role management</li>
          <li>• Organisation settings and preferences</li>
          <li>• Activity history and audit logs</li>
          <li>• Integration settings and API access</li>
        </ul>
      </div>
    </div>
  </div>
</div>

