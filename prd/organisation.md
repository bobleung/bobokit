## Organisation Structure

### One org, many users
Agencies, Clients, and Locums are all considered types of “org”.

- Locums are typically individuals.  
- Agencies and Clients usually include multiple users.  
- So, multiple users can belong to the same org.

### One user, many orgs
A single user can belong to multiple orgs.

For example, a doctor might work as a locum and also be a partner at a GP surgery (client org), allowing them to use the platform in both roles.

### Parent-child orgs
Some Clients are part of a group structure, where a parent entity oversees multiple subsidiaries.

- Subsidiaries may have special invoicing or approval flows linked to the parent.  
  E.g. invoices from child entities may be sent to the parent.  
- Admin users at the parent level should be able to manage access across all subsidiaries, including inviting or removing users.

## User Context

Because users can belong to multiple organisations, every action on the platform must be done within a specific **user context**.

- The app must provide the server with **both** the user’s authentication token **and** the org they are acting on behalf of.  
- The server will:
  - First verify the user belongs to the specified org.  
  - Then check whether the org has permission to perform the requested action.

For convenience, the server stores the user's **last active context**. This becomes their default context at login.

For example:

- A user logs into "Client A" on one browser.  
- Later, they log into a different browser — they’ll automatically start in "Client A" context.  
- They can then switch to "Client B" to act on its behalf.  
- Returning to the original browser, they’ll still be in "Client A" context and can continue working as such.

This behaviour supports users who work across multiple sites or roles throughout the week, enabling seamless switching without losing continuity.

## Super Admin

Some users are designated as **Super Admins** — typically internal platform staff with elevated privileges.

- A user becomes a Super Admin if their `super_admin` field is set to `true` in the `users` table.
- Super Admins have access to features handled by the `SuperAdminController`.
- These features bypass most standard permission checks, allowing platform-wide actions such as managing any organisation or user.

Super Admins are still regular users in other respects:

- They can belong to organisations like any other user.  
- When using the platform **outside of Super Admin features**, they operate within the normal limits of their current user context — just like any other user.

What grants them elevated access is **both**:

1. Logging in with `super_admin = true`, and  
2. Using a route or action designated as a Super Admin feature.

Access to these features is protected on both ends:

- The **frontend** will only show Super Admin features to users flagged as `super_admin = true`.
- The **backend** will enforce the same check before allowing any privileged action.

This dual-layer check ensures that Super Admin capabilities are secure and cannot be accidentally or maliciously accessed by regular users.