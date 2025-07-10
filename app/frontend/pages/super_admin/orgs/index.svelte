<script>
    let selectedId = ""
</script>

<!-- Page Container below nav bar -->
<div class="flex flex-col max-h-full">
    <!-- Page Title -->
    <h1 class="font-bold text-2xl mb-4">Super Admin Org Page</h1>

    <!-- Page Body -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-full">
        <!-- Left Column -->
        <div class="md:col-span-1">
            Master Panel
        </div>
        
        <!-- Right Column -->
        <div class="md:col-span-1">
            {#if selectedId === "new"}
                Detail New
            {:else}
                Detail Existing
            {/if}
        </div>
    </div>
</div>