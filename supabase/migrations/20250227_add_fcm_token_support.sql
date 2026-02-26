-- Add FCM token support for push notifications

-- Add fcm_token column to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS fcm_token TEXT,
ADD COLUMN IF NOT EXISTS fcm_token_updated_at TIMESTAMP WITH TIME ZONE;

-- Create index for faster token lookups
CREATE INDEX IF NOT EXISTS idx_profiles_fcm_token 
ON profiles(fcm_token) 
WHERE fcm_token IS NOT NULL;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can update their own FCM token" ON profiles;
DROP POLICY IF EXISTS "Users can read their own profile" ON profiles;

-- Create policy to allow users to update their own FCM token
CREATE POLICY "Users can update their own FCM token"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Create policy to allow users to read their own profile
CREATE POLICY "Users can read their own profile"
ON profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id);
