-- Migration: Fix RLS policies for edge function email access
-- Allow service_role to read all profiles for email notification purposes

-- Drop existing policies that might be too restrictive
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

-- Recreate policy for authenticated users to view their own profile
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Create policy for service_role to view all profiles (for edge functions)
-- This allows the email-notifications edge function to fetch user emails
DROP POLICY IF EXISTS "Service role can view all profiles" ON profiles;
CREATE POLICY "Service role can view all profiles" ON profiles
  FOR SELECT USING (
    -- Allow if authenticated as service role (edge functions)
    auth.jwt() ->> 'role' = 'service_role'
  );

-- Add comment explaining the policy
COMMENT ON POLICY "Service role can view all profiles" ON profiles IS 
  'Allows edge functions to read user emails for sending notifications';
