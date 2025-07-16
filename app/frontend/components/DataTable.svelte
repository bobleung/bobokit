<script>
  let { 
    data = [],
    columns = [],
    selectedId = $bindable(),
    onRowSelect = null
  } = $props();

  function handleSelectRow(itemId) {
    selectedId = itemId;
    if (onRowSelect) {
      onRowSelect(itemId);
    }
  }

  function getCellValue(item, column) {
    if (column.render && typeof column.render === 'function') {
      return column.render(item);
    }
    
    return item[column.key] ?? '';
  }
</script>

<div class="card-body overflow-x-auto">
  <table class="table table-sm table-pin-rows">
    <!-- Column Headers -->
    <thead>
      <tr>
        {#each columns as column}
          <th>{column.label}</th>
        {/each}
      </tr>
    </thead>
    <!-- Rows -->
    <tbody>
      {#each data as item}
        <!-- Individual Row -->
        <tr class="hover:bg-base-300 cursor-pointer
            {selectedId === item.id ? 'bg-primary/20' : ''}"
            onclick={() => handleSelectRow(item.id)}>
          {#each columns as column, index}
            {#if index === 0}
              <th>{getCellValue(item, column)}</th>
            {:else}
              <td>{getCellValue(item, column)}</td>
            {/if}
          {/each}
        </tr>
      {/each}
    </tbody>
  </table>
</div>