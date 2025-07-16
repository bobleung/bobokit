<script>
    import { DataTable, Search } from "@components"

    let { selectedId = $bindable(''), searchTerm = $bindable(), list, type = $bindable() } = $props()
    let typeIcon = $derived(ENTITIES[type].icon)
    
    const columns = [
        { key: 'name', label: 'Name' },
        { key: 'code', label: 'Site Code' },
        { key: 'email', label: 'Email' }
    ]
    
    function setType(newType, event) {
        event.preventDefault()
        type = newType
        // You can add additional logic here when type changes
        console.log(`Type changed to: ${newType}`)

    }
    let search = ""

    function handleSearch(){
        console.log("Search Triggered")
    }

    function neworg(){
        selectedId = "new"
        console.log("Selected ID : " + selectedId)
    }

    function handleSelectRow(id){
        selectedId = id
        console.log("Selected ID : " + selectedId)
    }
</script>

<div class="card shadow-sm w-full max-w-full max-h-full">
    <!-- Panel Header -->
    <div class="flex items-center justify-between px-4 py-2 bg-base-200 rounded-t-lg gap-4">
        <div class="flex items-center gap-2">

            
            <!-- Org Type Selector -->
            <div class="dropdown dropdown-hover">
                <div tabindex="0" role="button" class="btn m-1" aria-haspopup="menu" aria-expanded="false">
                    <span class="material-symbols-outlined text-xl">{typeIcon}</span>
                    {type}
                </div>
                <ul role="menu" class="dropdown-content menu bg-base-100 rounded-box z-1 w-52 p-2 shadow-sm">
                  <li role="menuitem">
                    <button type="button" class="w-full text-left" onclick={(e) => setType('Agency', e)}>Agencies</button>
                  </li>
                  <li role="menuitem">
                    <button type="button" class="w-full text-left" onclick={(e) => setType('Client', e)}>Clients</button>
                  </li>
                  <li role="menuitem">
                    <button type="button" class="w-full text-left" onclick={(e) => setType('Locum', e)}>Locums</button>
                  </li>
                </ul>
            </div>

        </div>
        <Search onSearch={handleSearch} initialValue={search}></Search>
        <button type="button" class="btn btn-ghost btn-xs btn-square" onclick={neworg}>
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