<script>
    import Master from "./master.svelte"
    import Detail from "./detail.svelte"
    import DetailNew from "./detail_new.svelte"
    import { router } from "@inertiajs/svelte";

    // Get Props
    let { jobs: list, type}= $props()

    // Define Local Variables
    let selectedId = $state(null)
    let previousType = type

    // Extract selected when selectedId changes
    const selected = $derived(list?.find(item => item.id === selectedId) || null)

    // Reload list when Type changes
    $effect(() => {
        if (type !== previousType) {
            previousType = type
            selectedId = null
            router.get("/super/orgs", {type }, {
                preserveState:true,
                preserveScroll: true
            });
        }
    })

    // Handle Closing Detail Panel
    function closeDetailPanel() {
        selectedId = '';
    }

    // Handle Update from Detail Panel
    function handleUpdate(updatedData) {
        console.log(`INDEX / Updated Data`, updatedData)
        router.patch(`/jobs/${updatedData.id}`,
            {job: updatedData
        });
    }

    // Handle Delete from Detail Panel
    function handleDelete(id) {
    console.log(`INDEX / Delete Org id: ` + id)
    router.delete(`/super/orgs/${id}`);
    }

    // Reactive Console Logs
    $inspect("INDEX / Type: " + type);
    $inspect("INDEX / selectedId: " + selectedId);
    $inspect("INDEX / Selected Item", selected);

</script>

<!-- Page Container below nav bar -->
<div class="flex flex-col h-full">
    <!-- Page Title -->
    <h1 class="font-bold text-2xl mb-6">Bookings Page</h1>

    <!-- Page Body -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 w-full h-1 flex-1 min-h-0">
        <!-- Left Column -->
        <div class="overflow-auto p-0.5">
            <Master {list} bind:type={type} bind:selectedId={selectedId}></Master>
        </div>
        
        <!-- Right Column, recommend to use "key" to force remount detail panel -->
        {#key selectedId}
        <div class="overflow-auto p-0.5">
            {#if selectedId === "new"}
                <DetailNew></DetailNew>
            {:else}
                <Detail data={ selected } {type} onClose={closeDetailPanel} onUpdate={handleUpdate} onDelete={handleDelete}></Detail>
            {/if}
        </div>
        {/key}
    </div>
</div>
