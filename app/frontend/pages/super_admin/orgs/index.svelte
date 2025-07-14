<script>
    import Master from "./master.svelte"
    import Detail from "./detail.svelte"
    import DetailNew from "./detail_new.svelte"
    import { router } from "@inertiajs/svelte";

    let { orgs, type }= $props()
    $inspect(type);

    let selectedId = $state("")
    let previousType = type

    // Reload Orgs when Type changes
    $effect(() => {
        if (type !== previousType) {
            previousType = type
            router.get("/super/orgs", {type }, {
                preserveState:true,
                preserveScroll: true
            });
        }
    })

</script>

<!-- Page Container below nav bar -->
<div class="flex flex-col max-h-full">
    <!-- Page Title -->
    <h1 class="font-bold text-2xl mb-6">Super Admin Org Page</h1>

    <!-- Page Body -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-full">
        <!-- Left Column -->
        <div class="md:col-span-1">
            <Master {orgs} bind:type={type} bind:selectedId={selectedId}></Master>
        </div>
        
        <!-- Right Column -->
        <div class="md:col-span-1">
            {#if selectedId === "new"}
                <DetailNew></DetailNew>
            {:else}
                <Detail { selectedId }></Detail>
            {/if}
        </div>
    </div>
</div>