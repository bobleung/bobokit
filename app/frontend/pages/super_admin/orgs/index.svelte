<script>
    import Master from "./master.svelte"
    import Detail from "./detail.svelte"
    import DetailNew from "./detail_new.svelte"
    import { router } from "@inertiajs/svelte";

    // Get Props
    let { orgs: list, type }= $props()

    // Define Local Variables
    let selectedId = $state(null)
    let previousType = type

    // Extract selected when selectedId changes
    const selected = $derived(list.find(item => item.id === selectedId) || null)

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

    // Reactive Console Logs
    $inspect("INDEX / Type: " + type);
    $inspect("INDEX / selectedId: " + selectedId);
    $inspect("INDEX / Selected Item", selected);

</script>

<!-- Page Container below nav bar -->
<div class="flex flex-col max-h-full">
    <!-- Page Title -->
    <h1 class="font-bold text-2xl mb-6">Super Admin selected Page</h1>

    <!-- Page Body -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-full">
        <!-- Left Column -->
        <div class="md:col-span-1">
            <Master {list} bind:type={type} bind:selectedId={selectedId}></Master>
        </div>
        
        <!-- Right Column -->
        <div class="md:col-span-1">
            {#if selectedId === "new"}
                <DetailNew></DetailNew>
            {:else}
                <Detail { selected }></Detail>
            {/if}
        </div>
    </div>
</div>