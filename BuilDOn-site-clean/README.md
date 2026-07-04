# BuildOn Site

BuildOn landing page and consultation admin page.

## Files

- `index.html`: public landing page
- `admin-x7k2.html`: admin page for consultation management
- `api/notify.js`: Vercel serverless function for email notifications
- `brand_logo/`: logo assets used by the landing page
- `Difference/`: section images used by the landing page
- `supabase_setup.sql`: Supabase table and policy setup
- `vercel.json`: deployment headers and security policy

## Local Preview

Open `index.html` directly in a browser for the static page.

The notification API requires a Vercel-style Node runtime and these environment variables:

```bash
RESEND_API_KEY=
ADMIN_NOTIFY_EMAIL=
```

Copy `.env.example` to `.env` locally if you need to run API behavior.

## Deploy

This project is set up for Vercel.

1. Create the `consultations` table by running `supabase_setup.sql` in Supabase SQL Editor.
2. Set `RESEND_API_KEY` and `ADMIN_NOTIFY_EMAIL` in Vercel environment variables.
3. Deploy the folder to Vercel.
