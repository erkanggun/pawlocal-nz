# PawLocal NZ 🐾

An Auckland-first pet care marketplace prototype with a coral-and-cream interface.

## What works

- Supabase email/password signup and login.
- Public sitter profiles, profile editing and JPG/PNG/WebP photo upload (up to 5 MB).
- Optional pet types, years of experience and usual available weekdays after the profile-details migration.
- Profile cards and detail dialogs display those self-reported details.
- Booking requests and My Bookings: sitters accept/decline; owners cancel pending requests through constrained RPC functions.
- A separate fictional listings section with suburb, service and price filters. These filters apply to demo listings only.

## Prototype boundaries

Registered member profiles and booking requests use the database. The separate sample listings and their booking preview are fictional and send nothing. Identity, experience and qualifications are not verified. Weekday preferences are not a date-specific calendar, a capacity check or a confirmed reservation. There are no payments, messaging, reviews or email booking notifications.

## Supabase setup

In a new Supabase project, run these files in SQL Editor in this order:

1. `supabase/schema.sql` — public sitter profiles and owner-only insert/update RLS.
2. `supabase/photos.sql` — photo column, public bucket and user-folder storage policies.
3. `supabase/bookings.sql` — participant-only booking reads and accept/decline/cancel RPCs.
4. `supabase/profile-details.sql` — pet types, experience and usual weekdays with database constraints.

For an already configured installation, run only `profile-details.sql` to add the new fields. This migration can be rerun; the original schema and booking scripts create policies and should not be blindly rerun. The new migration leaves existing profiles, bookings and RLS policies intact. Empty fields mean unspecified, not unavailable.

The interface tolerates a missing profile-details migration: existing profiles still load and save, while the extra form fields are disabled with an explanatory message. Reload the page after running the migration.

Enable the Email auth provider. Configure the Site URL and allowed redirect URLs to the actual deployed site, including its `/pawlocal-nz/` path. Set the project URL and publishable key in `index.html` for your installation. The publishable key is intended for client use; never put a secret/service-role key in the browser. Verify live RLS and storage policies before accepting real users.

## Local preview and publishing

Run `python3 -m http.server 8000` from the repository and open `http://localhost:8000`. Account operations require the configured Supabase project.

The included `.github/workflows/static.yml` deploys the root to GitHub Pages when `main` changes. In Settings → Pages, set Source to **GitHub Actions**, then check the deployment run. Production: https://erkanggun.github.io/pawlocal-nz/.

## Check the new profile details

After applying the migration, sign in and choose **My sitter profile**. Select pets and weekdays, enter experience (0 is valid; blank is unspecified), save, refresh and reopen. Check the public profile in a second session. Existing users should be able to edit only their own profile. A signed-out visitor may browse profiles but cannot save one.

Local JavaScript checks cover syntax, reads against the new and old schemas, authorization errors, save payloads, zero/blank experience and network failures with a mocked Supabase client. Browser-based visual testing was blocked by the execution environment. These checks do not verify live database policies or apply the migration.
