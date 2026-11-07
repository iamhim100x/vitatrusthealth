# VitatrustHealth — starter application

A responsive Next.js prototype for a Nigerian hybrid physical + online pharmacy.

## Included
- Customer-facing landing page (`/`)
- Admin dashboard preview (`/admin`)
- Initial PostgreSQL/Supabase schema (`supabase/schema.sql`)
- Environment variable template (`.env.example`)

## Run locally
1. Install Node.js 20.9+.
2. In this folder run `npm install`.
3. Copy `.env.example` to `.env.local` (database keys are not needed to view the static prototype).
4. Run `npm run dev` and open http://localhost:3000.

## Database setup
Create a Supabase project, then run `supabase/schema.sql` in its SQL Editor. Before real customer data is added, implement and test Row Level Security policies, role assignment, private prescription storage, audit logging and server-side authorization. Never put the Supabase service-role key in browser code.

## Production work still required
This is a first visual/structural prototype, not a production pharmacy system. It intentionally does not accept orders, process payments, authenticate users, validate prescriptions or update inventory. The next build phase is secure authentication + RLS, then product/stock management, order processing and POS workflows. Add Paystack only through server-side verified payment callbacks.

## Nigeria-specific launch checks
Confirm applicable pharmacy premises and online pharmacy requirements with the Pharmacy Council of Nigeria and obtain professional/legal review before enabling online dispensing or delivery. Establish prescription review and restricted-medicine workflows. Implement NDPA-aligned privacy, retention, access controls and breach response. Prices are stored as integer kobo to avoid floating-point currency errors.
