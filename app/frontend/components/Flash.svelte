<script>
  import { page } from '@inertiajs/svelte';
  
  let visible = $state(true);
  const flash = $derived($page.props.flash || {});

  // Reset visiblity each time there's a new flash object
  $effect(() => {
    if (flash.success || flash.error || flash.notice || flash.alert) {
      visible = true
      
      // Auto-dismiss success and notice after 2 seconds
      if (flash.success || flash.notice) {
        setTimeout(() => {
          visible = false;
        }, 2000);
      }
    }
  })
  
  function dismiss() {
    visible = false;
  }
</script>

{#if visible && (flash.success || flash.error || flash.notice || flash.alert)}
  <div class="toast toast-right" style="top: 4.5rem; animation-duration: 0.5s; animation-iteration-count: 1;">
    <div class="alert shadow-lg" class:alert-success={flash.success} class:alert-error={flash.error} class:alert-info={flash.notice} class:alert-warning={flash.alert}>
      <span>{flash.success || flash.error || flash.notice || flash.alert}</span>
      <button class="material-symbols-outlined opacity-50 cursor-pointer" onclick={dismiss}>close</button>
    </div>
  </div>
{/if}