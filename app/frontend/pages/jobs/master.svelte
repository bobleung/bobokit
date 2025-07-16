<script>
    import Search from "@components/Search.svelte"

    let {list, selectedId = $bindable()} = $props()
    let search = ""

    function handleSelectRow(id){
        selectedId = id
        console.log("Selected ID : " + selectedId)
    }

    function handleSearch(){
        console.log("Search Triggered")
    }
</script>

<div class="card shadow-sm w-full max-w-full max-h-full">
    <!-- Panel Header -->
    <div class="flex items-center justify-between px-4 py-2 bg-base-200 rounded-t-sm gap-4">
        <div class="flex items-center gap-2">
            <span class="material-symbols-outlined text-xl">group</span>
            <h2 class="text-lg font-semibold">Bookings</h2>
        </div>
        <Search onSearch={handleSearch} initialValue={search}></Search>
        <button type="button" class="btn btn-ghost btn-xs btn-square" onclick={newUser}>
            <span class="material-symbols-outlined">add</span>
        </button>
    </div>
    
    <!-- Table --> 
    <div class="card-body overflow-x-auto">
        <table class="table table-sm table-pin-rows">
            <!-- Column Headers -->
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Site Code</th>
                    <th>Email</th>
                </tr>
            </thead>
            <!-- Rows -->
            <tbody>
                {#each list as item}
                <!-- Individual Row -->
                <tr class="hover:bg-base-300 cursor-pointer
                    {selectedId === item.id ? 'bg-primary/20' : ''}"
                    onclick={() => handleSelectRow(item.id)}>
                    <th >{item.start}</th>
                    <td>{item.end}</td>
                    <td>{item.break_minutes}</td>
                </tr>
                {/each}
            </tbody>
        </table>
    </div>
</div>