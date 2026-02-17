-- Optional: single policy as per spec. Existing RLS already has select/update/insert own row.
-- This adds the named "Users can access own row" for all operations.
create policy "Users can access own row"
on public.users
for all
using (auth.uid() = id)
with check (auth.uid() = id);
