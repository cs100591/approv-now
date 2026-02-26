-- Migration: Add user notification settings table
-- Date: 2025-02-27
-- Purpose: Allow users to control their email notification preferences

-- Create table for user notification settings
CREATE TABLE IF NOT EXISTS user_notification_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email_notifications_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comment explaining the table
COMMENT ON TABLE user_notification_settings IS 
  'Stores user preferences for email notifications. Default is disabled to control costs.';

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_notification_settings_user_id 
ON user_notification_settings(user_id);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_notification_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_user_notification_settings_timestamp 
ON user_notification_settings;

CREATE TRIGGER update_user_notification_settings_timestamp
  BEFORE UPDATE ON user_notification_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_user_notification_settings_updated_at();

-- Insert default settings for all existing users (disabled by default)
INSERT INTO user_notification_settings (user_id, email_notifications_enabled)
SELECT id, false FROM auth.users
ON CONFLICT (user_id) DO NOTHING;

-- Create function to get user email from auth.users
-- This is needed because we can't directly query auth.users from client
CREATE OR REPLACE FUNCTION get_user_email(user_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (SELECT email FROM auth.users WHERE id = user_id);
END;
$$;

-- Add comment explaining the function
COMMENT ON FUNCTION get_user_email IS 
  'Returns the email address of a user from auth.users. Used by notification system.';

-- Enable RLS on the settings table
ALTER TABLE user_notification_settings ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can view their own settings
DROP POLICY IF EXISTS "Users can view own notification settings" ON user_notification_settings;
CREATE POLICY "Users can view own notification settings" ON user_notification_settings
  FOR SELECT USING (auth.uid() = user_id);

-- Users can update their own settings
DROP POLICY IF EXISTS "Users can update own notification settings" ON user_notification_settings;
CREATE POLICY "Users can update own notification settings" ON user_notification_settings
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can insert their own settings
DROP POLICY IF EXISTS "Users can insert own notification settings" ON user_notification_settings;
CREATE POLICY "Users can insert own notification settings" ON user_notification_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Service role can manage all settings (for backend operations)
DROP POLICY IF EXISTS "Service role can manage all notification settings" ON user_notification_settings;
CREATE POLICY "Service role can manage all notification settings" ON user_notification_settings
  FOR ALL USING (
    auth.jwt() ->> 'role' = 'service_role'
  );
