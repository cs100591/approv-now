-- Create storage bucket for request attachments
insert into storage.buckets (id, name, public)
values ('request-attachments', 'request-attachments', true)
on conflict (id) do nothing;

-- Set up storage policies for the bucket
create policy "Anyone can read request attachments"
  on storage.objects for select
  using ( bucket_id = 'request-attachments' );

create policy "Authenticated users can upload attachments"
  on storage.objects for insert
  with check ( bucket_id = 'request-attachments' and auth.role() = 'authenticated' );

create policy "Users can update their own attachments"
  on storage.objects for update
  with check ( bucket_id = 'request-attachments' and auth.uid() = owner_id );

create policy "Users can delete their own attachments"
  on storage.objects for delete
  using ( bucket_id = 'request-attachments' and auth.uid() = owner_id );
