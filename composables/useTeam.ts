// @ts-nocheck
export const useTeam = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  
  // Current active team
  const currentTeam = useState<any>('currentTeam', () => null)
  const userTeams = useState<any[]>('userTeams', () => [])
  
  // Fetch all teams user belongs to - SIMPLIFIED
  const fetchUserTeams = async () => {
    if (!user.value?.id) return
    
    try {
      // First get team memberships
      const { data: memberships, error: memberError } = await supabase
        .from('team_members')
        .select('team_id, role')
        .eq('user_id', user.value.id)
      
      if (memberError) throw memberError
      
      if (memberships && memberships.length > 0) {
        // Then get team details
        const teamIds = memberships.map(m => m.team_id)
        const { data: teams, error: teamsError } = await supabase
          .from('teams')
          .select('*')
          .in('id', teamIds)
          .order('created_at', { ascending: true })
        
        if (teamsError) throw teamsError
        
        // Combine team data with roles
        userTeams.value = teams.map(team => {
          const membership = memberships.find(m => m.team_id === team.id)
          return {
            ...team,
            role: membership?.role || 'member'
          }
        })
      } else {
        userTeams.value = []
      }
      
      // Set current team if not already set
      if (!currentTeam.value && userTeams.value.length > 0) {
        currentTeam.value = userTeams.value[0]
        // Store in localStorage for persistence
        if (process.client) {
          localStorage.setItem('currentTeamId', userTeams.value[0].id)
        }
      }
    } catch (error) {
      console.error('Error fetching user teams:', error)
    }
  }
  
  // Switch to a different team
  const switchTeam = (team: any) => {
    currentTeam.value = team
    if (process.client) {
      localStorage.setItem('currentTeamId', team.id)
    }
  }
  
  // Create a new team - SIMPLIFIED
  const createTeam = async (name: string, description?: string) => {
    if (!user.value?.id) return null
    
    try {
      // Create team
      const { data: teamData, error: teamError } = await supabase
        .from('teams')
        .insert({
          name,
          description,
          created_by: user.value.id
        })
        .select()
        .single()
      
      if (teamError) throw teamError
      
      // Add user as owner
      const { error: memberError } = await supabase
        .from('team_members')
        .insert({
          team_id: teamData.id,
          user_id: user.value.id,
          role: 'owner'
        })
      
      if (memberError) {
        // Clean up if member insertion fails
        await supabase.from('teams').delete().eq('id', teamData.id)
        throw memberError
      }
      
      // Refresh teams
      await fetchUserTeams()
      
      return teamData
    } catch (error) {
      console.error('Error creating team:', error)
      throw error
    }
  }

  // Update team details
  const updateTeam = async (teamId: string, updates: { name?: string; description?: string }) => {
    try {
      const { data, error } = await supabase
        .from('teams')
        .update(updates)
        .eq('id', teamId)
        .select()
        .single()

      if (error) throw error

      // Update local state
      await fetchUserTeams()
      
      // Update current team if it's the one being updated
      if (currentTeam.value?.id === teamId) {
        currentTeam.value = { ...currentTeam.value, ...updates }
      }

      return data
    } catch (error) {
      console.error('Error updating team:', error)
      throw error
    }
  }

  // Delete team
  const deleteTeam = async (teamId: string) => {
    try {
      const { error } = await supabase
        .from('teams')
        .delete()
        .eq('id', teamId)

      if (error) throw error

      // If deleted team was current team, switch to another team
      if (currentTeam.value?.id === teamId) {
        const remainingTeams = userTeams.value.filter(team => team.id !== teamId)
        if (remainingTeams.length > 0) {
          switchTeam(remainingTeams[0])
        } else {
          currentTeam.value = null
        }
      }

      // Refresh teams
      await fetchUserTeams()
    } catch (error) {
      console.error('Error deleting team:', error)
      throw error
    }
  }

  // Fetch team members
  const fetchTeamMembers = async (teamId: string) => {
    try {
      const { data, error } = await supabase
        .from('team_members')
        .select(`
          id,
          role,
          joined_at,
          user_id
        `)
        .eq('team_id', teamId)
        .order('joined_at', { ascending: true })

      if (error) throw error
      return data
    } catch (error) {
      console.error('Error fetching team members:', error)
      throw error
    }
  }

  // Simplified - just throw error for now since we need invitation system
  const addTeamMember = async (teamId: string, email: string, role: string = 'member') => {
    throw new Error('Team member invitations not yet implemented. This feature requires an invitation system.')
  }

  // Update team member role
  const updateTeamMemberRole = async (memberId: string, role: string) => {
    try {
      const { data, error } = await supabase
        .from('team_members')
        .update({ role })
        .eq('id', memberId)
        .select()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Error updating team member role:', error)
      throw error
    }
  }

  // Remove team member
  const removeTeamMember = async (memberId: string) => {
    try {
      const { error } = await supabase
        .from('team_members')
        .delete()
        .eq('id', memberId)

      if (error) throw error
    } catch (error) {
      console.error('Error removing team member:', error)
      throw error
    }
  }

  // Leave team
  const leaveTeam = async (teamId: string) => {
    try {
      const { error } = await supabase
        .from('team_members')
        .delete()
        .eq('team_id', teamId)
        .eq('user_id', user.value.id)

      if (error) throw error

      // If left team was current team, switch to another team
      if (currentTeam.value?.id === teamId) {
        const remainingTeams = userTeams.value.filter(team => team.id !== teamId)
        if (remainingTeams.length > 0) {
          switchTeam(remainingTeams[0])
        } else {
          currentTeam.value = null
        }
      }

      // Refresh teams
      await fetchUserTeams()
    } catch (error) {
      console.error('Error leaving team:', error)
      throw error
    }
  }
  
  // Initialize team state on client
  const initializeTeam = async () => {
    await fetchUserTeams()
    
    // Restore current team from localStorage
    if (process.client && userTeams.value.length > 0) {
      const savedTeamId = localStorage.getItem('currentTeamId')
      if (savedTeamId) {
        const savedTeam = userTeams.value.find(team => team.id === savedTeamId)
        if (savedTeam) {
          currentTeam.value = savedTeam
        }
      }
    }
  }
  
  return {
    currentTeam: readonly(currentTeam),
    userTeams: readonly(userTeams),
    fetchUserTeams,
    switchTeam,
    createTeam,
    updateTeam,
    deleteTeam,
    fetchTeamMembers,
    addTeamMember,
    updateTeamMemberRole,
    removeTeamMember,
    leaveTeam,
    initializeTeam
  }
}
