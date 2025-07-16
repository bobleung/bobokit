<script>
    let { value = $bindable(), label, type, ...restProps } = $props()
</script>

<label class="floating-label input validator w-full"><span>{label}</span>
    <input type={type} placeholder={label} {...restProps}
    bind:value/>
</label>



