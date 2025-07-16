<script>
    import { DataTable, Search } from "@components"

    let {list, selectedId = $bindable()} = $props()
    let search = ""

    const columns = [
        { key: 'start', label: 'Start' },
        { key: 'end', label: 'End' },
        { key: 'break_minutes', label: 'Break (mins)' },
        { key: 'client.name', label: 'Client' },
        { key: 'locum.name', label: 'Locum' },
    ]

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
    <DataTable 
        data={list}
        {columns}
        bind:selectedId
        onRowSelect={handleSelectRow}
    />
</div>