-- ============================================
-- Approve Now - Supabase Database Schema
-- Run this in Supabase SQL Editor
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PROFILES TABLE (User profiles)
-- ============================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT,
  photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Trigger to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'display_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- WORKSPACES TABLE
-- ============================================
CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  company_name TEXT,
  address TEXT,
  footer_text TEXT,
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  member_ids UUID[] DEFAULT '{}',
  plan TEXT DEFAULT 'free',
  settings JSONB DEFAULT '{}',
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;

-- RLS Policies for workspaces
CREATE POLICY "Users can view workspaces they own or are members of" ON workspaces
  FOR SELECT USING (
    auth.uid() = owner_id OR 
    auth.uid() = ANY(member_ids)
  );

CREATE POLICY "Users can create workspaces" ON workspaces
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can update workspaces" ON workspaces
  FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Owners can delete workspaces" ON workspaces
  FOR DELETE USING (auth.uid() = owner_id);

-- Index for workspace queries
CREATE INDEX idx_workspaces_owner_id ON workspaces(owner_id);
CREATE INDEX idx_workspaces_member_ids ON workspaces USING GIN(member_ids);

-- ============================================
-- WORKSPACE MEMBERS TABLE (Detailed member info)
-- ============================================
CREATE TABLE workspace_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT,
  photo_url TEXT,
  role TEXT DEFAULT 'viewer', -- owner, admin, editor, viewer
  status TEXT DEFAULT 'pending', -- pending, active, inactive
  invited_by UUID REFERENCES auth.users(id),
  invited_at TIMESTAMPTZ DEFAULT NOW(),
  joined_at TIMESTAMPTZ,
  invite_token TEXT,
  UNIQUE(workspace_id, user_id)
);

-- Enable RLS
ALTER TABLE workspace_members ENABLE ROW LEVEL SECURITY;

-- RLS Policies for workspace_members
CREATE POLICY "Users can view members of their workspaces" ON workspace_members
  FOR SELECT USING (
    workspace_id IN (
      SELECT id FROM workspaces 
      WHERE auth.uid() = owner_id OR auth.uid() = ANY(member_ids)
    )
  );

CREATE POLICY "Workspace owners can manage members" ON workspace_members
  FOR ALL USING (
    workspace_id IN (SELECT id FROM workspaces WHERE auth.uid() = owner_id)
  );

-- Indexes
CREATE INDEX idx_workspace_members_workspace_id ON workspace_members(workspace_id);
CREATE INDEX idx_workspace_members_user_id ON workspace_members(user_id);

-- ============================================
-- TEMPLATES TABLE
-- ============================================
CREATE TABLE templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  fields JSONB DEFAULT '[]',
  approval_steps JSONB DEFAULT '[]',
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;

-- RLS Policies for templates
CREATE POLICY "Users can view templates of their workspaces" ON templates
  FOR SELECT USING (
    workspace_id IN (
      SELECT id FROM workspaces 
      WHERE auth.uid() = owner_id OR auth.uid() = ANY(member_ids)
    )
  );

CREATE POLICY "Users can create templates in their workspaces" ON templates
  FOR INSERT WITH CHECK (
    workspace_id IN (
      SELECT id FROM workspaces 
      WHERE auth.uid() = owner_id OR auth.uid() = ANY(member_ids)
    )
  );

CREATE POLICY "Users can update templates in their workspaces" ON templates
  FOR UPDATE USING (
    workspace_id IN (
      SELECT id FROM workspaces 
      WHERE auth.uid() = owner_id OR auth.uid() = ANY(member_ids)
    )
  );

CREATE POLICY "Users can delete templates in their workspaces" ON templates
  FOR DELETE USING (
    workspace_id IN (
      SELECT id FROM workspaces 
      WHERE auth.uid() = owner_id OR auth.uid() = ANY(member_ids)
    )
  );

-- Indexes
CREATE INDEX idx_templates_workspace_id ON templates(workspace_id);
CREATE INDEX idx_templates_is_active ON templates(is_active);
CREATE INDEX idx_templates_created_at ON templates(created_at DESC);

-- ============================================
-- REQUESTS TABLE
-- ============================================
CREATE TABLE requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  template_id UUID REFERENCES templates(id) ON DELETE SET NULL,
  template_name TEXT,
  submitted_by UUID NOT NULL REFERENCES auth.users(id),
  submitted_by_name TEXT,
  status TEXT DEFAULT 'draft', -- draft, pending, approved, rejected, revised
  current_level INTEGER DEFAULT 1,
  field_values JSONB DEFAULT '[]',
  approval_actions JSONB DEFAULT '[]',
  current_approver_ids UUID[] DEFAULT '{}',
  revision_number INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE requests ENABLE ROW LEVEL SECURITY;

-- RLS Policies for requests
CREATE POLICY "Users can view requests of their workspaces" ON requests
  FOR SELECT USING (
    workspace_id IN (
      SELECT id FROM workspaces 
      WHERE auth.uid() = owner_id OR auth.uid() = ANY(member_ids)
    )
  );

CREATE POLICY "Users can create requests in their workspaces" ON requests
  FOR INSERT WITH CHECK (
    workspace_id IN (
      SELECT id FROM workspaces 
      WHERE auth.uid() = owner_id OR auth.uid() = ANY(member_ids)
    )
  );

CREATE POLICY "Users can update requests in their workspaces" ON requests
  FOR UPDATE USING (
    workspace_id IN (
      SELECT id FROM workspaces 
      WHERE auth.uid() = owner_id OR auth.uid() = ANY(member_ids)
    )
  );

CREATE POLICY "Users can delete requests in their workspaces" ON requests
  FOR DELETE USING (
    workspace_id IN (
      SELECT id FROM workspaces 
      WHERE auth.uid() = owner_id OR auth.uid() = ANY(member_ids)
    )
  );

-- Indexes
CREATE INDEX idx_requests_workspace_id ON requests(workspace_id);
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_requests_submitted_by ON requests(submitted_by);
CREATE INDEX idx_requests_current_approver_ids ON requests USING GIN(current_approver_ids);
CREATE INDEX idx_requests_created_at ON requests(created_at DESC);

-- Composite index for common query pattern
CREATE INDEX idx_requests_workspace_status ON requests(workspace_id, status);

-- ============================================
-- MEMBER GROUPS TABLE
-- ============================================
CREATE TABLE member_groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT DEFAULT '#3B82F6',
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workspace_id, name)
);

-- Enable RLS
ALTER TABLE member_groups ENABLE ROW LEVEL SECURITY;

-- RLS Policies for member_groups
CREATE POLICY "Users can view groups of their workspaces" ON member_groups
  FOR SELECT USING (
    workspace_id IN (
      SELECT id FROM workspaces 
      WHERE auth.uid() = owner_id OR auth.uid() = ANY(member_ids)
    )
  );

CREATE POLICY "Owners and admins can manage groups" ON member_groups
  FOR ALL USING (
    workspace_id IN (
      SELECT id FROM workspaces WHERE auth.uid() = owner_id
    )
    OR
    workspace_id IN (
      SELECT workspace_id FROM workspace_members 
      WHERE user_id = auth.uid() AND role = 'admin' AND status = 'active'
    )
  );

-- Indexes
CREATE INDEX idx_member_groups_workspace_id ON member_groups(workspace_id);
CREATE INDEX idx_member_groups_created_at ON member_groups(created_at DESC);

-- ============================================
-- GROUP MEMBERS TABLE (Junction table)
-- ============================================
CREATE TABLE group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES member_groups(id) ON DELETE CASCADE,
  workspace_member_id UUID NOT NULL REFERENCES workspace_members(id) ON DELETE CASCADE,
  added_by UUID REFERENCES auth.users(id),
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(group_id, workspace_member_id)
);

-- Enable RLS
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- RLS Policies for group_members
CREATE POLICY "Users can view group members of their workspaces" ON group_members
  FOR SELECT USING (
    group_id IN (
      SELECT mg.id FROM member_groups mg
      JOIN workspaces w ON mg.workspace_id = w.id
      WHERE auth.uid() = w.owner_id OR auth.uid() = ANY(w.member_ids)
    )
  );

CREATE POLICY "Owners and admins can manage group members" ON group_members
  FOR ALL USING (
    group_id IN (
      SELECT mg.id FROM member_groups mg
      JOIN workspaces w ON mg.workspace_id = w.id
      WHERE auth.uid() = w.owner_id
      OR EXISTS (
        SELECT 1 FROM workspace_members wm
        WHERE wm.workspace_id = w.id 
        AND wm.user_id = auth.uid() 
        AND wm.role = 'admin' 
        AND wm.status = 'active'
      )
    )
  );

-- Indexes
CREATE INDEX idx_group_members_group_id ON group_members(group_id);
CREATE INDEX idx_group_members_workspace_member_id ON group_members(workspace_member_id);

-- ============================================
-- NOTIFICATIONS TABLE (Persistent)
-- ============================================
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN (
    'workspace_invitation',
    'invitation_accepted',
    'invitation_declined',
    'pending_request',
    'request_approved',
    'request_rejected',
    'request_revision',
    'member_added',
    'member_removed',
    'mention'
  )),
  title TEXT NOT NULL,
  message TEXT,
  data JSONB DEFAULT '{}',
  action_type TEXT CHECK (action_type IN ('accept_invitation', 'decline_invitation', 'view_request', 'view_workspace', 'none')),
  action_data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT false,
  is_dismissed BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  dismissed_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days'),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies for notifications
CREATE POLICY "Users can view their own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications" ON notifications
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can delete their own notifications" ON notifications
  FOR DELETE USING (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, created_at DESC) 
  WHERE is_read = false AND is_dismissed = false;
CREATE INDEX idx_notifications_user_all ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_expires ON notifications(expires_at);
CREATE INDEX idx_notifications_workspace_id ON notifications(workspace_id);

-- ============================================
-- TEMPLATE VISIBILITY TABLE
-- ============================================
CREATE TABLE template_visibility (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  template_id UUID NOT NULL REFERENCES templates(id) ON DELETE CASCADE,
  workspace_member_id UUID REFERENCES workspace_members(id) ON DELETE CASCADE,
  member_group_id UUID REFERENCES member_groups(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT visibility_target_check CHECK (
    (workspace_member_id IS NOT NULL AND member_group_id IS NULL) OR
    (workspace_member_id IS NULL AND member_group_id IS NOT NULL)
  ),
  UNIQUE(template_id, workspace_member_id),
  UNIQUE(template_id, member_group_id)
);

-- Enable RLS
ALTER TABLE template_visibility ENABLE ROW LEVEL SECURITY;

-- RLS Policies for template_visibility
CREATE POLICY "Users can view template visibility of their workspaces" ON template_visibility
  FOR SELECT USING (
    template_id IN (
      SELECT t.id FROM templates t
      JOIN workspaces w ON t.workspace_id = w.id
      WHERE auth.uid() = w.owner_id OR auth.uid() = ANY(w.member_ids)
    )
  );

CREATE POLICY "Users can manage template visibility in their workspaces" ON template_visibility
  FOR ALL USING (
    template_id IN (
      SELECT t.id FROM templates t
      JOIN workspaces w ON t.workspace_id = w.id
      WHERE auth.uid() = w.owner_id OR auth.uid() = ANY(w.member_ids)
    )
  );

-- Indexes
CREATE INDEX idx_template_visibility_template_id ON template_visibility(template_id);
CREATE INDEX idx_template_visibility_member_id ON template_visibility(workspace_member_id);
CREATE INDEX idx_template_visibility_group_id ON template_visibility(member_group_id);

-- Add visibility_type column to templates
ALTER TABLE templates ADD COLUMN IF NOT EXISTS visibility_type TEXT NOT NULL DEFAULT 'everyone'
  CHECK (visibility_type IN ('everyone', 'specific_members', 'specific_groups'));

-- Apply triggers for new tables
CREATE TRIGGER update_member_groups_updated_at BEFORE UPDATE ON member_groups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- RPC FUNCTIONS FOR WORKSPACE MEMBERS
-- ============================================

-- Function to add member to workspace member_ids array
CREATE OR REPLACE FUNCTION add_member_to_workspace(
  p_workspace_id UUID,
  p_user_id UUID
)
RETURNS void AS $$
BEGIN
  UPDATE workspaces
  SET member_ids = array_append(member_ids, p_user_id)
  WHERE id = p_workspace_id
    AND NOT (p_user_id = ANY(member_ids));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to remove member from workspace member_ids array
CREATE OR REPLACE FUNCTION remove_member_from_workspace(
  p_workspace_id UUID,
  p_user_id UUID
)
RETURNS void AS $$
BEGIN
  UPDATE workspaces
  SET member_ids = array_remove(member_ids, p_user_id)
  WHERE id = p_workspace_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get workspaces owned by user
CREATE OR REPLACE FUNCTION get_owned_workspaces(p_user_id UUID)
RETURNS SETOF workspaces AS $$
BEGIN
  RETURN QUERY SELECT * FROM workspaces WHERE owner_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get workspaces user has joined (not owned)
CREATE OR REPLACE FUNCTION get_joined_workspaces(p_user_id UUID)
RETURNS SETOF workspaces AS $$
BEGIN
  RETURN QUERY SELECT * FROM workspaces 
  WHERE p_user_id = ANY(member_ids) AND owner_id != p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STORAGE BUCKETS
-- ============================================
-- Create storage buckets for file uploads
INSERT INTO storage.buckets (id, name, public) VALUES ('attachments', 'attachments', false);
INSERT INTO storage.buckets (id, name, public) VALUES ('logos', 'logos', false);

-- Storage policies for attachments
CREATE POLICY "Users can upload attachments to their workspaces"
  ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'attachments' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view attachments from their workspaces"
  ON storage.objects FOR SELECT USING (
    bucket_id = 'attachments' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Storage policies for logos
CREATE POLICY "Users can upload logos"
  ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'logos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view logos"
  ON storage.objects FOR SELECT USING (bucket_id = 'logos');

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workspaces_updated_at BEFORE UPDATE ON workspaces
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_templates_updated_at BEFORE UPDATE ON templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_requests_updated_at BEFORE UPDATE ON requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- DONE! 
-- ============================================
-- After running this schema:
-- 1. Go to Authentication > Providers and enable Email provider
-- 2. Check that all tables are created in Table Editor
-- 3. Verify RLS policies are working
