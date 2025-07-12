
# Job Permission System Specification

## Overview

This platform is a multi-tenant healthcare locum job board that supports three types of organisations: **Agencies**, **Clients**, and **Locums**. Each type has different levels of access depending on the job ownership scenario.

### Scenario 1: Job Posted by an Agency on Behalf of a Client

- The **Agency** owns the job and can edit all fields.
- The **Client** can view the job and may gain limited editing capabilities in future (none at present).
- Some fields (e.g. internal notes, locum rates) are visible to agencies only.
- The platform aims to make as many fields public as possible to support transparency, while protecting sensitive data.

**If a Locum is appointed:**

- They gain access to a subset of relevant fields.
- They may propose changes (e.g. time or rate adjustments).
- After completing the job, they can submit start/end times and notes — visible to both agency and client.

### Scenario 2: Job Posted Directly by a Client

- The **Client** owns the job and has full control.
- It may be filled by a **Locum** directly or through an **Agency** acting on their behalf.

---

## Job Access and Scoping

Each job has a owner_type, either "Agency" or "Client"
Each job is always associated with one **Client**.  
Each job is only associated with one **Locum** once it's filled.
Each job must have one **Agency** if it's created by the agency

### Scenario 1: Owner_type = Agency
- Agency posts on behalf of Client
- Job must have an Agency & Client
- Agency can manage the job
- Client can edit only some parts of the job (such as their own notes)
- Locum is associated only once the job is filled.

### Scenario 2: Owner_type = Client
- Client posts directly
- Client owns and has full control
- Agency is associated only if they are the one who filled the job with their own Locum
- Locum is associated only once the job is filled.

In all cases, what jobs a user (via their org) can see and within it which field they can read/write is tied **user’s current organisation context**. Users only see and act on jobs their current org is allowed to access.

---

## Permission Enforcement: Three-layer Security

All job actions go through three server-side checks:

1. **User–Org Check**: Confirms the user belongs to the org they're acting for.
2. **Org–Job Scope Check**: Confirms the org has access to the job(s).
3. **Field Permission Check**: Filters which fields can be read/written based on org type and job state.

---

### Examples

#### Retrieving Jobs

- User sends request with `orgId`.
- Server checks user–org link.
- Returns jobs visible to that org only.
- Only permitted fields (based on org type) are returned.

#### Updating a Job

- User sends update with `orgId` and `jobId`.
- Server checks user–org link.
- Applies strong params based on org type:
  - e.g. if acting as a **Client**, only `client_notes` is permitted.
- `jobId` is used to find the job (not editable).
- Server updates and returns only permitted fields.



## Central Access Rules

- Three org types: **Agency**, **Client**, **Locum**
- Each has centrally defined read/write access per field.
- Some permissions may depend on job state (e.g. clients may edit more if no agency is assigned).
- Rules are enforced consistently across all endpoints.

---

## Implementation Details

### Job Scoping (Layer 1)

```ruby
# app/models/job.rb
scope :for_organisation, ->(org) {
  case org.type.downcase
  when 'agency' then where(agency: org)
  when 'client' then where(client: org)
  when 'locum'  then where(locum: org)
  end
}
```

```ruby
# In controllers
@jobs = Job.for_organisation(Current.entity)
```

### Field Filtering (Layer 2)

```ruby
# app/policies/job_policy.rb
class JobPolicy
  def initialize(job, organisation)
    @job = job
    @organisation = organisation
  end

  def permitted_fields(action = :read)
    # Define field-level rules here
  end

  def filter_attributes(attributes, action = :read)
    attributes.slice(*permitted_fields(action))
  end
end
```

```ruby
# Usage
job = @jobs_scope.find(params[:id])
policy = JobPolicy.new(job, Current.entity)

# On read
render inertia: 'jobs/show', props: {
  job: policy.filter_attributes(job.attributes, :read)
}

# On update
job.update(policy.filter_attributes(job_params.to_h, :write))
```

### Strong Params Helper

To simplify controllers:

```ruby
# app/controllers/concerns/job_permissions.rb
def permitted_job_params
  policy = JobPolicy.new(@job, Current.entity)
  policy.filter_attributes(job_params.to_h, :write)
end
```

### Standard Error Handling

```ruby
rescue_from JobPolicy::AccessDenied do |exception|
  render inertia: 'errors/forbidden', status: :forbidden
end
```

---

## Super Admins

- **Super Admins** are platform staff with `super_admin = true`.
- They can access and modify any job or data across the platform.
- Accessed via a dedicated frontend and `SuperAdminController`.
- Both frontend and backend enforce the `super_admin` check.
- Outside of these features, they behave like normal org users.

---

## Edge Cases

### Locum Org Changes Mid-Job

- A job is always assigned to one **locum org** at a time, so if a locum changes org mid-job, only the **currently assigned** locum org (or none) retains access.

---
