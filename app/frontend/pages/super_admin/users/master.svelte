<script>
    import Search from "@components/Search.svelte";
    import { router } from "@inertiajs/svelte";

    let { selectedId = $bindable(''), searchTerm = $bindable(), users } = $props()

    // Initial search value
    const search = searchTerm || ""

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

<div class="card shadow-sm w-full max-w-full max-h-full my-6">
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
    
    <div class="card-body overflow-x-auto">
        <table class="table table-sm table-pin-rows">
            <!-- Column Headers -->
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Super Admin</th>
                </tr>
            </thead>
            <!-- Rows -->
            <tbody>
                {#each users as user}
                <!-- Individual Row -->
                <tr class="hover:bg-base-300 cursor-pointer
                    {selectedId === user.id ? 'bg-primary/20' : ''} 
                    {user.deactivated ? 'line-through' : ''} 
                    {user.deactivated && selectedId !== user.id ? 'opacity-50' : ''}"
                    onclick={() => selectedUser(user.id)}>
                    <th class="{user.deactivated ? 'line-through' : ''} {user.deactivated && selectedId !== user.id ? 'opacity-50' : ''}">{user.first_name + " " + user.last_name}</th>
                    <td>{user.email_address}
                        {#if !user.email_verified_at}
                            <span class="italic">(unverified)</span>
                        {/if}
                    </td>
                    <td>
                    {#if user.super_admin}
                        <div class="badge badge-primary badge-xs rounded-xl">super</div>  
                    {/if}
                    </td>
                </tr>
                {/each}
            </tbody>
        </table>
    </div>
</div>