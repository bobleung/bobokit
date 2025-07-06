<script>
    import Master from './master.svelte';
    import Detail from './detail.svelte';
    let { users } = $props()
    let selectedId = $state('');
    let selectedUser = $derived(users?.find(user => user.id === selectedId));                                                                                   

    console.log("Users", users)
    $inspect("Selected User ID: " + selectedId)
    $inspect("Selected User ", selectedUser)
    
</script>

<!-- Page Container below nav bar -->
<div class="flex flex-col max-h-full">
    <!-- Page Title -->
    <h1 class="font-bold text-2xl">Super Admin User Page</h1>

    <!-- Page Body -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-full">
        <!-- Left Column -->
        <div class="md:col-span-1">
            <Master bind:selectedId={selectedId} users={users}></Master>
        </div>
        
        <!-- Right Column -->
        <div class="md:col-span-1">
            <Detail bind:user={selectedUser}></Detail>
        </div>
    </div>
</div>


