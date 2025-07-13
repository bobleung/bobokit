<script>
    import Search from "@components/Search.svelte"

    let { selectedId = $bindable(''), searchTerm = $bindable(), orgs } = $props()
    let type = $state("Agency")
    let typeIcon = $derived(ENTITIES[type].icon)
    
    function setType(newType, event) {
        event.preventDefault()
        type = newType
        // You can add additional logic here when type changes
        console.log(`Type changed to: ${newType}`)
    }
    let search = ""
    selectedId = ""
    orgs = [
        {
            id: 1,
            name: "FML",
            code: "123",
            email_address: "fml@test.com"
        },
        {
            id: 2,
            name: "ABC",
            code: "234",
            email_address: "abc@test.com"
        }
    ]

    function handleSearch(){
        console.log("Search Triggered")
    }

    function neworg(){
        console.log("New org Clicked")
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
                {#each orgs as org}
                <!-- Individual Row -->
                <tr class="hover:bg-base-300 cursor-pointer
                    {selectedId === org.id ? 'bg-primary/20' : ''} 
                    {org.deactivated ? 'line-through' : ''} 
                    {org.deactivated && selectedId !== org.id ? 'opacity-50' : ''}"
                    onclick={() => selectedorg(org.id)}>
                    <th >{org.name}</th>
                    <td>{org.code}</td>
                    <td>{org.code}</td>
                </tr>
                {/each}
            </tbody>
        </table>
    </div>
</div>