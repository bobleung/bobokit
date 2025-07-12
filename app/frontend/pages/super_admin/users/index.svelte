<script>
    import Master from './master.svelte';
    import Detail from './detail.svelte';
    import DetailNew from './DetailNew.svelte';
    import { router } from '@inertiajs/svelte';
    
    let { users } = $props()
    
    // Initialize selectedId from URL params
    const urlParams = new URLSearchParams(window.location.search);
    let selectedId = $state(Number(urlParams.get('selectedId')) || '');
    let selectedUser = $derived(users?.find(user => user.id === selectedId));
    let searchTerm = $state(urlParams.get('search') || '');

    // Update URL when selectedId changes
    $effect(() => {
        const currentUrl = new URL(window.location);
        if (selectedId) {
            currentUrl.searchParams.set('selectedId', selectedId);
        } else {
            currentUrl.searchParams.delete('selectedId');
        }
        
        // Only update if the URL actually changed
        if (currentUrl.toString() !== window.location.toString()) {
            router.get(currentUrl.pathname + currentUrl.search, {}, {
                preserveState: true,
                preserveScroll: true,
                replace: true
            });
        }
    });

    function deselectUser() {
        selectedId = '';
    }

    console.log("Users", users)
    $inspect("Selected User ID: " + selectedId)
    $inspect("Selected User ", selectedUser)
    $inspect("Search Term: " + searchTerm)
    
</script>

<!-- Page Container below nav bar -->
<div class="flex flex-col max-h-full">
    <!-- Page Title -->
    <h1 class="font-bold text-2xl mb-6">Super Admin User Page</h1>

    <!-- Page Body -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-full">
        <!-- Left Column -->
        <div class="md:col-span-1">
            <Master bind:selectedId={selectedId} bind:searchTerm={searchTerm} users={users}></Master>
        </div>
        
        <!-- Right Column -->
        <div class="md:col-span-1">
            {#if selectedId === "new"}
                <DetailNew bind:selectedId={selectedId}></DetailNew>
            {:else}
                <Detail user={selectedUser} onClose={deselectUser}></Detail>
            {/if}
        </div>
    </div>
</div>
