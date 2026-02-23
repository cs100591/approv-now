-- Migration script: Update all viewer roles to editor
-- Run this in Supabase SQL Editor

-- Update workspace_members table
UPDATE workspace_members 
SET role = 'editor' 
WHERE role = 'viewer';

-- Verify the update
SELECT role, COUNT(*) as count 
FROM workspace_members 
GROUP BY role;
