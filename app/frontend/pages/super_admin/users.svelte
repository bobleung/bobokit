<script>
    let { users } = $props()

    console.log("Users", users)
</script>

<!-- Page Container below nav bar -->

Super Admin User Page

<div class="overflow-x-auto h-full">
    <table class="table table-xs table-pin-rows table-pin-cols">
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
            <tr>
                <th>{user.first_name}</th>
                <td>{user.email_address}</td>
                <td>
                {#if user.super_admin}
                    <div class="badge badge-primary rounded-xl text-xs">Super Admin</div>
                {/if}
                </td>
            </tr>
            {/each}
        </tbody>
    </table>
</div>


