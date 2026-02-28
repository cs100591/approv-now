CREATE OR REPLACE FUNCTION get_workspace_name_from_code(invite_code text) 
RETURNS text 
LANGUAGE sql 
SECURITY DEFINER 
AS $$
  SELECT w.name 
  FROM workspaces w 
  JOIN workspace_invite_codes c ON w.id = c.workspace_id 
  WHERE c.code = invite_code 
  AND c.expires_at > timezone('utc', now())
  LIMIT 1;
$$;
