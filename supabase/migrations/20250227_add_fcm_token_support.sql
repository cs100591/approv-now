-- Add FCM token support for push notifications

-- Add fcm_token column to user_profiles table
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS fcm_token TEXT,
ADD COLUMN IF NOT EXISTS fcm_token_updated_at TIMESTAMP WITH TIME ZONE;

-- Create index for faster token lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_fcm_token 
ON user_profiles(fcm_token) 
WHERE fcm_token IS NOT NULL;

-- Update RLS policies to allow users to update their own FCM token
CREATE POLICY "Users can update their own FCM token"
ON user_profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Allow users to read their own FCM token (for debugging)
CREATE POLICY "Users can read their own profile"
ON user_profiles
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
