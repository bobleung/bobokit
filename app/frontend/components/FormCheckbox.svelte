<script>
    let { value = $bindable(false), label } = $props()
</script>

<label class="label text-base-content">
    <input type="checkbox" bind:checked={value} class="toggle toggle-success" />
    {label}
</label>