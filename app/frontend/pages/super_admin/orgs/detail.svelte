<script>
    let { selected } = $props()
</script>

{#if selected}
    Detail Panel {selected.id} / {selected.name}
{:else}
    Select an organisation to view details
{/if}