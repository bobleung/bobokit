<script>
    /**
     * @typedef {Object} Props
     * @property {boolean} value - The checkbox value (bindable)
     * @property {string} label - The checkbox label text
     */

    /** @type {Props} */
    let { value = $bindable(), label } = $props()
</script>

<label class="label text-base-content">
    <input type="checkbox" bind:checked={value} class="toggle toggle-success" />
    {label}
</label>