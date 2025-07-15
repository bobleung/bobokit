# Jobs

## Background
This is a healthcare recruitment platform. The platform has Agencies, Clients and Locums.

## Job Fields

* start (timestamp) <- required
* end (timestamp) <- required
* break (minutes, integer)

* actual_start
* actual_end
* actual_break (minutes, integer)

* client_pays <- money in pence
* locum_gets <- money in pence
* agency_gets <- money in pence

* notes_job
* notes_client
* notes_agency
* not

The below are linked to the organisation STI
* agency_id <- linked to organisation, type must be agency, required if owned_by = agency
* client_id <- linked to organisation, type must be client, required
* locum_id <- linked to organisation, type must be locum

* owned_by (agency / client / locum)