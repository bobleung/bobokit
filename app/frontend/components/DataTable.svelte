<script>
  /**
   * A flexible table component with conditional styling and row selection capabilities.
   * 
   * @component
   * @param {Array<Object>} data - Array of data objects to display in the table
   * @param {Array<Object>} columns - Column configuration objects with key, label, and optional render function
   *   @param {string} columns[].key - Property key or dot-notation path (e.g., 'user.name')
   *   @param {string} columns[].label - Display label for the column header
   *   @param {Function} [columns[].render] - Optional custom render function that receives the item
   *   @param {string} [columns[].type] - Optional column type: 'text' (default) or 'badge'
   *   @param {string} [columns[].style] - Optional style classes for the column type
   * @param {string|number|null} selectedId - Currently selected row ID (bindable)
   * @param {Function|null} onRowSelect - Callback function called when a row is selected with itemId
   * @param {Array<Array>} rowStyles - Conditional styling rules for rows and cells
   *   Format: [condition, cssClass, targetColumns]
   *   - condition: JavaScript expression as string (e.g., "item.active === false")
   *   - cssClass: CSS classes to apply
   *   - targetColumns: undefined for whole row, string for single column, array for multiple columns
   * 
   * @example
   * // Basic usage
   * <Table 
   *   data={users} 
   *   columns={[
   *     {key: 'name', label: 'Name'}, 
   *     {key: 'email', label: 'Email'},
   *     {key: 'agency.name', label: 'Agency'},
   *     {key: 'status', label: 'Status', type: 'badge', style: 'badge-primary badge-xs'}
   *   ]}
   *   bind:selectedId={selectedUserId}
   *   onRowSelect={(id) => console.log('Selected:', id)}
   *   rowStyles={[
   *     ['item.active === false', 'opacity-50'],
   *     ['item.status === "pending"', 'bg-yellow-50', ['name', 'email']]
   *   ]}
   * />
   */
  let { 
    data = [],
    columns = [],
    selectedId = $bindable(),
    onRowSelect = null,
    rowStyles = []
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
    
    // Handle nested properties like 'agency.name'
    if (column.key.includes('.')) {
      return getNestedValue(item, column.key);
    }
    
    return item[column.key] ?? '';
  }

  function getNestedValue(obj, path) {
    return path.split('.').reduce((current, key) => {
      return current && current[key] !== undefined ? current[key] : '';
    }, obj);
  }

  function evaluateCondition(item, condition) {
    try {
      // Create a function that evaluates the condition with the item in scope
      const func = new Function('item', `return ${condition}`);
      return func(item);
    } catch (error) {
      console.warn(`Invalid condition in rowStyles: "${condition}"`, error);
      return false;
    }
  }

  function getRowClasses(item) {
    const classes = [];
    
    rowStyles.forEach(([condition, cssClass, targetColumns]) => {
      // Only apply to row if no specific columns are targeted (row-level style)
      if (!targetColumns && evaluateCondition(item, condition)) {
        classes.push(cssClass);
      }
    });
    
    return classes.join(' ');
  }

  function getCellClasses(item, columnKey) {
    const classes = [];
    
    rowStyles.forEach(([condition, cssClass, targetColumns]) => {
      if (targetColumns && evaluateCondition(item, condition)) {
        // Check if this column should receive the styling
        const shouldApply = Array.isArray(targetColumns) 
          ? targetColumns.includes(columnKey)
          : targetColumns === columnKey;
          
        if (shouldApply) {
          classes.push(cssClass);
        }
      }
    });
    
    return classes.join(' ');
  }
</script>

<!-- 
  Table container with horizontal scroll support
  Uses DaisyUI table classes for consistent styling
-->
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
    
    <!-- Table Body with Data Rows -->
    <tbody>
      {#each data as item}
        <!-- 
          Individual row with:
          - Click handler for selection
          - Dynamic classes for conditional styling
          - Hover effects and selection highlighting
        -->
        <tr class="cursor-pointer
            {getRowClasses(item)}
            hover:bg-base-300
            {selectedId === item.id ? 'bg-primary/20' : ''}"
            onclick={() => handleSelectRow(item.id)}>
          {#each columns as column, index}
            <!-- First column uses <th> for semantic importance, others use <td> -->
            {#if index === 0}
              <th class="{getCellClasses(item, column.key)}">
                {#if column.type === 'badge'}
                  {#if getCellValue(item, column)}
                    <span class="badge {column.style || 'badge-neutral badge-xs'}">{getCellValue(item, column)}</span>
                  {/if}
                {:else}
                  {getCellValue(item, column)}
                {/if}
              </th>
            {:else}
              <td class="{getCellClasses(item, column.key)}">
                {#if column.type === 'badge'}
                  {#if getCellValue(item, column)}
                    <span class="badge {column.style || 'badge-neutral badge-xs'}">{getCellValue(item, column)}</span>
                  {/if}
                {:else}
                  {getCellValue(item, column)}
                {/if}
              </td>
            {/if}
          {/each}
        </tr>
      {/each}
    </tbody>
  </table>
</div>