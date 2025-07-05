<script>
    let { selectedId = $bindable(''), users } = $props()

    function selectedUser(userId) {
        selectedId = userId
    }
</script>

<div class="flex grow card card-body card-border shadow-sm w-full max-w-full max-h-full my-6">
    <div class="overflow-x-auto">
        <table class="table table-xs table-pin-rows">
            <!-- Column Headers -->
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Super</th>
                </tr>
            </thead>
            <!-- Rows -->
            <tbody>
                {#each users as user}
                <!-- Individual Row -->
                <tr class="hover:bg-base-300 cursor-pointer {selectedId === user.id ? 'bg-primary/20' : ''}"
                    onclick={() => selectedUser(user.id)}>
                    <th>{user.first_name + " " + user.last_name}</th>
                    <td>{user.email_address}
                        {#if !user.email_verified_at}
                            <span class="italic">(unverified)</span>
                        {/if}
                    </td>
                    <td>
                    {#if user.super_admin}
                        <div class="badge badge-primary badge-xs rounded-xl">Super Admin</div>
                    {/if}
                    </td>
                </tr>
                {/each}
            </tbody>
        </table>
    </div>
</div>