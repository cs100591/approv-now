-- Create user_push_tokens table for OneSignal Player IDs
-- This table stores the OneSignal subscription IDs (formerly "player IDs")
-- for each user's device to enable targeted push notifications.

CREATE TABLE IF NOT EXISTS user_push_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  player_id TEXT NOT NULL,
  platform TEXT NOT NULL DEFAULT 'ios',  -- 'ios' | 'android'
  enabled BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE (user_id, player_id)
);

-- Index for fast lookup by user
CREATE INDEX IF NOT EXISTS idx_user_push_tokens_user_id
  ON user_push_tokens(user_id);

-- Index for enabled tokens per user
CREATE INDEX IF NOT EXISTS idx_user_push_tokens_user_enabled
  ON user_push_tokens(user_id, enabled)
  WHERE enabled = true;

-- Enable Row Level Security
ALTER TABLE user_push_tokens ENABLE ROW LEVEL SECURITY;

-- Users can insert/upsert their own tokens
CREATE POLICY "Users can insert own push tokens"
  ON user_push_tokens
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own tokens (e.g. toggle enabled)
CREATE POLICY "Users can update own push tokens"
  ON user_push_tokens
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can read their own tokens
CREATE POLICY "Users can read own push tokens"
  ON user_push_tokens
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Service role (used by Edge Functions) can read ALL tokens for sending
-- This is covered by the service_role key bypassing RLS.
