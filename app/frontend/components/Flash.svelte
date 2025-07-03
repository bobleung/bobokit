<script>
  import { page } from '@inertiajs/svelte';
  
  let visible = $state(true);
  const flash = $derived($page.props.flash || {});

  // Reset visiblity each time there's a new flash object
  $effect(() => {
    console.log("Hello")
    if (flash.success || flash.error || flash.notice || flash.alert) {
      visible = true
    }
  })
  
  function dismiss() {
    visible = false;
  }
</script>

{#if visible && (flash.success || flash.error || flash.notice || flash.alert)}
  <div class="toast toast-top toast-center">
    <div class="alert" class:alert-success={flash.success} class:alert-error={flash.error} class:alert-info={flash.notice} class:alert-warning={flash.alert}>
      <span>{flash.success || flash.error || flash.notice || flash.alert}</span>
      <button class="material-symbols-outlined opacity-50 cursor-pointer" onclick={dismiss}>close</button>
    </div>
  </div>
{/if}