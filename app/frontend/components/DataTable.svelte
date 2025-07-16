<script>
  let { 
    data = [],
    columns = [],
    selectedId = $bindable(),
    onRowSelect = null,
    rowStyles = []
  } = $props();

  /**
   * rowStyles format:
   * [
   *   ['item.active === false', 'opacity-50', ['client.name', 'start']], // Apply to specific columns
   *   ['item.status === "pending"', 'bg-yellow-50'],                    // Apply to whole row
   *   ['item.priority === "high"', 'font-bold', 'name']                 // Apply to single column
   * ]
   * 
   * Each array contains:
   * [0] condition (string) - JavaScript expression evaluated against the item
   * [1] cssClass (string) - CSS classes to apply
   * [2] columns (optional) - string for single column, array for multiple columns, undefined for whole row
   */

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

  /**
   * Evaluates a condition string against an item object
   * @param {Object} item - The data item to evaluate
   * @param {string} condition - JavaScript expression as string (e.g., "item.active === false")
   * @returns {boolean} - Result of the condition evaluation
   */
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

  /**
   * Gets CSS classes to apply to a row based on rowStyles
   * @param {Object} item - The data item for the current row
   * @returns {string} - Space-separated CSS classes
   */
  function getRowClasses(item) {
    const classes = [];
    
    rowStyles.forEach(([condition, cssClass, targetColumns]) => {
      // Only apply to row if no specific columns are targeted or if it's a row-level style
      if (!targetColumns && evaluateCondition(item, condition)) {
        classes.push(cssClass);
      }
    });
    
    return classes.join(' ');
  }

  /**
   * Gets CSS classes to apply to a specific cell based on rowStyles
   * @param {Object} item - The data item for the current row
   * @param {string} columnKey - The key of the current column
   * @returns {string} - Space-separated CSS classes
   */
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
        <tr class="cursor-pointer
            {getRowClasses(item)}
            hover:bg-base-300
            {selectedId === item.id ? 'bg-primary/20' : ''}"
            onclick={() => handleSelectRow(item.id)}>
          {#each columns as column, index}
            {#if index === 0}
              <th class="{getCellClasses(item, column.key)}">{getCellValue(item, column)}</th>
            {:else}
              <td class="{getCellClasses(item, column.key)}">{getCellValue(item, column)}</td>
            {/if}
          {/each}
        </tr>
      {/each}
    </tbody>
  </table>
</div>