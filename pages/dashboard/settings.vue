<template>
  <div>
    <h1 class="text-2xl font-bold text-gray-800 mb-6">Settings</h1>
    
    <!-- Tabs -->
    <div class="border-b border-gray-200 mb-6">
      <nav class="-mb-px flex space-x-8">
        <button
          @click="activeTab = 'teams'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'teams' 
              ? 'border-indigo-500 text-indigo-600' 
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Team Management
        </button>
        <button
          @click="activeTab = 'account'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'account' 
              ? 'border-indigo-500 text-indigo-600' 
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Account Settings
        </button>
      </nav>
    </div>

    <!-- Team Management Tab -->
    <div v-if="activeTab === 'teams'">
      <!-- Teams List -->
      <div class="bg-white shadow rounded-lg mb-6">
        <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
          <h2 class="text-lg font-medium text-gray-900">Your Teams</h2>
          <button
            @click="showCreateTeamModal = true"
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 text-sm"
          >
            <span class="material-icons text-sm mr-1">add</span>
            Create Team
          </button>
        </div>
        
        <div class="divide-y divide-gray-200">
          <div
            v-for="team in userTeams"
            :key="team.id"
            class="px-6 py-4 flex items-center justify-between"
          >
            <div class="flex-1">
              <div class="flex items-center">
                <h3 class="text-sm font-medium text-gray-900">{{ team.name }}</h3>
                <span
                  :class="[
                    'ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
                    team.role === 'owner' ? 'bg-purple-100 text-purple-800' :
                    team.role === 'admin' ? 'bg-blue-100 text-blue-800' :
                    'bg-gray-100 text-gray-800'
                  ]"
                >
                  {{ team.role }}
                </span>
                <span
                  v-if="team.id === currentTeam?.id"
                  class="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
                >
                  Current
                </span>
              </div>
              <p v-if="team.description" class="text-sm text-gray-500 mt-1">{{ team.description }}</p>
              <p class="text-xs text-gray-400 mt-1">
                Created {{ formatDate(team.created_at) }}
              </p>
            </div>
            <div class="flex items-center space-x-2">
              <button
                v-if="team.id !== currentTeam?.id"
                @click="handleSwitchTeam(team)"
                class="text-indigo-600 hover:text-indigo-800 text-sm"
              >
                Switch
              </button>
              <button
                @click="viewTeamDetails(team)"
                class="text-gray-600 hover:text-gray-800 text-sm"
              >
                <span class="material-icons text-sm">settings</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Account Settings Tab -->
    <div v-if="activeTab === 'account'" class="bg-white shadow rounded-lg p-6">
      <h2 class="text-lg font-medium text-gray-900 mb-4">Account Information</h2>
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700">Email</label>
          <p class="mt-1 text-sm text-gray-900">{{ user?.email }}</p>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700">Full Name</label>
          <p class="mt-1 text-sm text-gray-900">{{ user?.user_metadata?.full_name || 'Not set' }}</p>
        </div>
      </div>
    </div>

    <!-- Create Team Modal -->
    <div v-if="showCreateTeamModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-lg font-semibold mb-4">Create New Team</h2>
        <form @submit.prevent="handleCreateTeam">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Team Name</label>
            <input 
              v-model="newTeam.name"
              type="text" 
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            >
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Description</label>
            <textarea 
              v-model="newTeam.description"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            ></textarea>
          </div>
          <div class="flex justify-end space-x-3">
            <button 
              type="button"
              @click="showCreateTeamModal = false"
              class="px-4 py-2 text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50"
            >
              Cancel
            </button>
            <button 
              type="submit"
              :disabled="loading"
              class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
            >
              {{ loading ? 'Creating...' : 'Create' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Team Details Modal -->
    <div v-if="showTeamDetailsModal && selectedTeam" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg w-full max-w-2xl max-h-screen overflow-y-auto">
        <!-- Modal Header -->
        <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
          <h2 class="text-lg font-semibold">{{ selectedTeam.name }} Settings</h2>
          <button @click="closeTeamDetailsModal" class="text-gray-400 hover:text-gray-600">
            <span class="material-icons">close</span>
          </button>
        </div>

        <!-- Modal Content -->
        <div class="p-6">
          <!-- Team Info Section -->
          <div class="mb-8">
            <h3 class="text-md font-medium text-gray-900 mb-4">Team Information</h3>
            <form @submit.prevent="handleUpdateTeam" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Team Name</label>
                <input 
                  v-model="editTeam.name"
                  type="text" 
                  required
                  :disabled="!canManageTeam"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 disabled:bg-gray-100"
                >
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Description</label>
                <textarea 
                  v-model="editTeam.description"
                  rows="3"
                  :disabled="!canManageTeam"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 disabled:bg-gray-100"
                ></textarea>
              </div>
              <div v-if="canManageTeam" class="flex justify-end space-x-3">
                <button 
                  type="submit"
                  :disabled="loading"
                  class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
                >
                  {{ loading ? 'Updating...' : 'Update Team' }}
                </button>
              </div>
            </form>
          </div>

          <!-- Team Members Section -->
          <div class="mb-8">
            <div class="flex justify-between items-center mb-4">
              <h3 class="text-md font-medium text-gray-900">Team Members</h3>
              <button
                v-if="canManageTeam"
                @click="showAddMemberForm = true"
                class="px-3 py-1 bg-indigo-600 text-white rounded text-sm hover:bg-indigo-700"
              >
                Add Member
              </button>
            </div>

            <!-- Add Member Form -->
            <div v-if="showAddMemberForm && canManageTeam" class="mb-4 p-4 bg-gray-50 rounded-lg">
              <form @submit.prevent="handleAddMember" class="flex space-x-3">
                <input
                  v-model="newMember.email"
                  type="email"
                  placeholder="Enter email address"
                  required
                  class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                >
                <select
                  v-model="newMember.role"
                  class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                >
                  <option value="member">Member</option>
                  <option value="admin">Admin</option>
                </select>
                <button 
                  type="submit"
                  :disabled="loading"
                  class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
                >
                  Add
                </button>
                <button 
                  type="button"
                  @click="showAddMemberForm = false"
                  class="px-4 py-2 text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50"
                >
                  Cancel
                </button>
              </form>
            </div>

            <!-- Members List -->
            <div class="space-y-2">
              <div
                v-for="member in teamMembers"
                :key="member.id"
                class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
              >
                <div class="flex items-center">
                  <div class="h-8 w-8 rounded-full bg-indigo-300 flex items-center justify-center mr-3">
                    <span class="text-indigo-800 font-medium text-sm">
                      {{ member.user_id?.charAt(0)?.toUpperCase() }}
                    </span>
                  </div>
                  <div>
                    <p class="text-sm font-medium text-gray-900">{{ member.user_id }}</p>
                    <p class="text-xs text-gray-500">{{ member.role }}</p>
                  </div>
                </div>
                <div v-if="canManageTeam && member.user_id !== user?.id" class="flex items-center space-x-2">
                  <select
                    :value="member.role"
                    @change="handleUpdateMemberRole(member.id, $event.target.value)"
                    class="text-xs px-2 py-1 border border-gray-300 rounded"
                  >
                    <option value="member">Member</option>
                    <option value="admin">Admin</option>
                  </select>
                  <button
                    @click="handleRemoveMember(member.id)"
                    class="text-red-600 hover:text-red-800 text-xs"
                  >
                    Remove
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Danger Zone -->
          <div class="border-t border-gray-200 pt-6">
            <h3 class="text-md font-medium text-red-900 mb-4">Danger Zone</h3>
            <div class="space-y-3">
              <div v-if="selectedTeam.role !== 'owner'" class="flex justify-between items-center p-4 border border-yellow-200 rounded-lg bg-yellow-50">
                <div>
                  <h4 class="text-sm font-medium text-yellow-800">Leave Team</h4>
                  <p class="text-sm text-yellow-700">You will lose access to all projects in this team.</p>
                </div>
                <button
                  @click="handleLeaveTeam"
                  :disabled="loading"
                  class="px-4 py-2 bg-yellow-600 text-white rounded-md hover:bg-yellow-700 disabled:opacity-50"
                >
                  Leave Team
                </button>
              </div>
              
              <div v-if="selectedTeam.role === 'owner'" class="flex justify-between items-center p-4 border border-red-200 rounded-lg bg-red-50">
                <div>
                  <h4 class="text-sm font-medium text-red-800">Delete Team</h4>
                  <p class="text-sm text-red-700">This action cannot be undone. All projects and data will be lost.</p>
                </div>
                <button
                  @click="handleDeleteTeam"
                  :disabled="loading"
                  class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 disabled:opacity-50"
                >
                  Delete Team
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
definePageMeta({
  layout: 'sidebar'
})

const user = useSupabaseUser()
const { 
  userTeams, 
  currentTeam, 
  createTeam, 
  updateTeam, 
  deleteTeam, 
  switchTeam,
  fetchTeamMembers,
  addTeamMember,
  updateTeamMemberRole,
  removeTeamMember,
  leaveTeam
} = useTeam()

const activeTab = ref('teams')
const loading = ref(false)
const showCreateTeamModal = ref(false)
const showTeamDetailsModal = ref(false)
const showAddMemberForm = ref(false)
const selectedTeam = ref(null)
const teamMembers = ref([])

const newTeam = reactive({
  name: '',
  description: ''
})

const editTeam = reactive({
  name: '',
  description: ''
})

const newMember = reactive({
  email: '',
  role: 'member'
})

const canManageTeam = computed(() => {
  return selectedTeam.value?.role === 'owner' || selectedTeam.value?.role === 'admin'
})

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString()
}

const handleSwitchTeam = (team) => {
  switchTeam(team)
  window.location.reload()
}

const handleCreateTeam = async () => {
  if (!newTeam.name.trim()) return
  
  loading.value = true
  try {
    await createTeam(newTeam.name, newTeam.description)
    showCreateTeamModal.value = false
    newTeam.name = ''
    newTeam.description = ''
  } catch (error) {
    console.error('Error creating team:', error)
  } finally {
    loading.value = false
  }
}

const viewTeamDetails = async (team) => {
  selectedTeam.value = team
  editTeam.name = team.name
  editTeam.description = team.description || ''
  
  // Fetch team members
  try {
    teamMembers.value = await fetchTeamMembers(team.id)
  } catch (error) {
    console.error('Error fetching team members:', error)
  }
  
  showTeamDetailsModal.value = true
}

const closeTeamDetailsModal = () => {
  showTeamDetailsModal.value = false
  showAddMemberForm.value = false
  selectedTeam.value = null
  teamMembers.value = []
}

const handleUpdateTeam = async () => {
  if (!selectedTeam.value?.id) return
  
  loading.value = true
  try {
    await updateTeam(selectedTeam.value.id, {
      name: editTeam.name,
      description: editTeam.description
    })
    selectedTeam.value = { ...selectedTeam.value, name: editTeam.name, description: editTeam.description }
  } catch (error) {
    console.error('Error updating team:', error)
  } finally {
    loading.value = false
  }
}

const handleAddMember = async () => {
  if (!selectedTeam.value?.id || !newMember.email.trim()) return
  
  loading.value = true
  try {
    await addTeamMember(selectedTeam.value.id, newMember.email, newMember.role)
    teamMembers.value = await fetchTeamMembers(selectedTeam.value.id)
    showAddMemberForm.value = false
    newMember.email = ''
    newMember.role = 'member'
  } catch (error) {
    console.error('Error adding team member:', error)
  } finally {
    loading.value = false
  }
}

const handleUpdateMemberRole = async (memberId, newRole) => {
  try {
    await updateTeamMemberRole(memberId, newRole)
    teamMembers.value = await fetchTeamMembers(selectedTeam.value.id)
  } catch (error) {
    console.error('Error updating member role:', error)
  }
}

const handleRemoveMember = async (memberId) => {
  if (!confirm('Are you sure you want to remove this member?')) return
  
  try {
    await removeTeamMember(memberId)
    teamMembers.value = await fetchTeamMembers(selectedTeam.value.id)
  } catch (error) {
    console.error('Error removing team member:', error)
  }
}

const handleLeaveTeam = async () => {
  if (!confirm('Are you sure you want to leave this team? You will lose access to all projects.')) return
  
  loading.value = true
  try {
    await leaveTeam(selectedTeam.value.id)
    closeTeamDetailsModal()
  } catch (error) {
    console.error('Error leaving team:', error)
  } finally {
    loading.value = false
  }
}

const handleDeleteTeam = async () => {
  if (!confirm('Are you sure you want to delete this team? This action cannot be undone.')) return
  
  const confirmText = prompt('Type "DELETE" to confirm:')
  if (confirmText !== 'DELETE') return
  
  loading.value = true
  try {
    await deleteTeam(selectedTeam.value.id)
    closeTeamDetailsModal()
  } catch (error) {
    console.error('Error deleting team:', error)
  } finally {
    loading.value = false
  }
}
</script>