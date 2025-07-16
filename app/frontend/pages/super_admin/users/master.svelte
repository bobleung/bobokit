<script>
    import { DataTable, Search } from "@components";
    import { router } from "@inertiajs/svelte";

    let { selectedId = $bindable(''), searchTerm = $bindable(), users } = $props()

    // Initial search value
    const search = searchTerm || ""
    
    const columns = [
        { 
            key: 'full_name', 
            label: 'Name',
            render: (user) => `${user.first_name} ${user.last_name}`
        },
        { 
            key: 'email_address', 
            label: 'Email',
            render: (user) => user.email_verified_at 
                ? user.email_address 
                : `${user.email_address} (unverified)`
        },
        { 
            key: 'super_admin', 
            label: 'Super Admin',
            type: 'badge',
            style: 'badge-info badge-xs text-white',
            render: (user) => user.super_admin ? 'super' : ''
        }
    ]
    
    const rowStyles = [
        ['item.deactivated === true', 'line-through opacity-50']
    ]

    function selectedUser(userId) {
        selectedId = userId
    }

    function newUser(){
        selectedId = "new"
    }

    function handleSearch(term) {
        router.get('/super/users', { search: term }, {
            preserveState: true,
            replace: true
        });
    }

</script>

<div class="card shadow-sm w-full max-w-full max-h-full">
    <!-- Panel Header -->
    <div class="flex items-center justify-between px-4 py-2 bg-base-200 rounded-t-lg gap-4">
        <div class="flex items-center gap-2">
            <span class="material-symbols-outlined text-xl">group</span>
            <h2 class="text-lg font-semibold">Users</h2>
        </div>
        <Search onSearch={handleSearch} initialValue={search}></Search>
        <button type="button" class="btn btn-ghost btn-xs btn-square" onclick={newUser}>
            <span class="material-symbols-outlined">add</span>
        </button>
    </div>
    
    <!-- Table --> 
    <DataTable 
        data={users}
        {columns}
        {rowStyles}
        bind:selectedId
        onRowSelect={selectedUser}
    />
</div>