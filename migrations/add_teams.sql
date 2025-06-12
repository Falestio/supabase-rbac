-- Migration: Add teams functionality (Idempotent version with fixed policies)
-- This migration adds teams to the existing structure and can be run multiple times safely

-- Create teams table if it doesn't exist
CREATE TABLE IF NOT EXISTS teams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create team_members table if it doesn't exist
CREATE TABLE IF NOT EXISTS team_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role VARCHAR(50) DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(team_id, user_id)
);

-- Add team_id to existing projects table if column doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'team_id') THEN
    ALTER TABLE projects ADD COLUMN team_id UUID REFERENCES teams(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Add team_id to existing todos table if column doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'todos' AND column_name = 'team_id') THEN
    ALTER TABLE todos ADD COLUMN team_id UUID REFERENCES teams(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Enable RLS on new tables (safe to run multiple times)
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies to start fresh
DROP POLICY IF EXISTS "Users can view teams they belong to" ON teams;
DROP POLICY IF EXISTS "Users can create teams" ON teams;
DROP POLICY IF EXISTS "Team owners and admins can update teams" ON teams;
DROP POLICY IF EXISTS "Team owners can delete teams" ON teams;
DROP POLICY IF EXISTS "Users can view team members of their teams" ON team_members;
DROP POLICY IF EXISTS "Allow team creation" ON team_members;
DROP POLICY IF EXISTS "Team owners and admins can update members" ON team_members;
DROP POLICY IF EXISTS "Team owners and admins can remove members" ON team_members;

-- SIMPLIFIED POLICIES FOR TEAMS
-- Allow users to see teams they created
CREATE POLICY "Users can view teams they created" ON teams
  FOR SELECT USING (created_by = auth.uid());

-- Allow users to create teams
CREATE POLICY "Users can create teams" ON teams
  FOR INSERT WITH CHECK (created_by = auth.uid());

-- Allow team creators to update their teams
CREATE POLICY "Team creators can update teams" ON teams
  FOR UPDATE USING (created_by = auth.uid());

-- Allow team creators to delete their teams
CREATE POLICY "Team creators can delete teams" ON teams
  FOR DELETE USING (created_by = auth.uid());

-- SIMPLIFIED POLICIES FOR TEAM_MEMBERS
-- Allow users to see their own memberships
CREATE POLICY "Users can view their own memberships" ON team_members
  FOR SELECT USING (user_id = auth.uid());

-- Allow team owners to see all members of their teams
CREATE POLICY "Team owners can view team members" ON team_members
  FOR SELECT USING (
    team_id IN (
      SELECT id FROM teams WHERE created_by = auth.uid()
    )
  );

-- Allow inserting team memberships for team creation (owner adding themselves)
CREATE POLICY "Allow team membership creation" ON team_members
  FOR INSERT WITH CHECK (
    user_id = auth.uid() AND
    team_id IN (
      SELECT id FROM teams WHERE created_by = auth.uid()
    )
  );

-- Allow team owners to update member roles
CREATE POLICY "Team owners can update member roles" ON team_members
  FOR UPDATE USING (
    team_id IN (
      SELECT id FROM teams WHERE created_by = auth.uid()
    )
  );

-- Allow team owners to remove members, and users to remove themselves
CREATE POLICY "Team owners can remove members" ON team_members
  FOR DELETE USING (
    user_id = auth.uid() OR
    team_id IN (
      SELECT id FROM teams WHERE created_by = auth.uid()
    )
  );

-- Drop and recreate project policies to include team access
DROP POLICY IF EXISTS "Users can view their own projects" ON projects;
DROP POLICY IF EXISTS "Users can insert their own projects" ON projects;
DROP POLICY IF EXISTS "Users can update their own projects" ON projects;
DROP POLICY IF EXISTS "Users can delete their own projects" ON projects;
DROP POLICY IF EXISTS "Users can view projects in their teams" ON projects;
DROP POLICY IF EXISTS "Users can insert projects in their teams" ON projects;
DROP POLICY IF EXISTS "Users can update projects in their teams" ON projects;
DROP POLICY IF EXISTS "Users can delete projects in their teams" ON projects;

-- Simplified project policies
CREATE POLICY "Users can view projects in teams they belong to" ON projects
  FOR SELECT USING (
    team_id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create projects in teams they belong to" ON projects
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND
    team_id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own projects" ON projects
  FOR UPDATE USING (
    auth.uid() = user_id AND
    team_id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own projects" ON projects
  FOR DELETE USING (
    auth.uid() = user_id AND
    team_id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

-- Drop and recreate todo policies to include team access
DROP POLICY IF EXISTS "Users can view their own todos" ON todos;
DROP POLICY IF EXISTS "Users can insert their own todos" ON todos;
DROP POLICY IF EXISTS "Users can update their own todos" ON todos;
DROP POLICY IF EXISTS "Users can delete their own todos" ON todos;
DROP POLICY IF EXISTS "Users can view todos in their teams" ON todos;
DROP POLICY IF EXISTS "Users can insert todos in their teams" ON todos;
DROP POLICY IF EXISTS "Users can update todos in their teams" ON todos;
DROP POLICY IF EXISTS "Users can delete todos in their teams" ON todos;

-- Simplified todo policies
CREATE POLICY "Users can view todos in teams they belong to" ON todos
  FOR SELECT USING (
    team_id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create todos in teams they belong to" ON todos
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND
    team_id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own todos" ON todos
  FOR UPDATE USING (
    auth.uid() = user_id AND
    team_id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own todos" ON todos
  FOR DELETE USING (
    auth.uid() = user_id AND
    team_id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_teams_created_by ON teams(created_by);
CREATE INDEX IF NOT EXISTS idx_team_members_team_id ON team_members(team_id);
CREATE INDEX IF NOT EXISTS idx_team_members_user_id ON team_members(user_id);
CREATE INDEX IF NOT EXISTS idx_team_members_team_user ON team_members(team_id, user_id);
CREATE INDEX IF NOT EXISTS idx_projects_team_id ON projects(team_id);
CREATE INDEX IF NOT EXISTS idx_todos_team_id ON todos(team_id);

-- Drop and recreate function to avoid conflicts
DROP FUNCTION IF EXISTS create_default_team_for_user() CASCADE;

-- Function to automatically create a default team for new users
CREATE OR REPLACE FUNCTION create_default_team_for_user()
RETURNS TRIGGER AS $$
DECLARE
  team_id UUID;
BEGIN
  -- Create a default team for the new user
  INSERT INTO teams (name, description, created_by)
  VALUES ('Personal Team', 'Your personal workspace', NEW.id)
  RETURNING id INTO team_id;
  
  -- Add the user as owner of their default team
  INSERT INTO team_members (team_id, user_id, role)
  VALUES (team_id, NEW.id, 'owner');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS create_default_team_trigger ON auth.users;

-- Create trigger to automatically create default team for new users
CREATE TRIGGER create_default_team_trigger
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_default_team_for_user();
