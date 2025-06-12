<template>
  <div class="min-h-screen bg-gray-100">
    <!-- Sidebar -->
    <div class="fixed inset-y-0 left-0 w-64 bg-indigo-700 overflow-y-auto">
      <div class="flex items-center justify-center h-16 bg-indigo-800">
        <span class="text-white font-bold text-xl">TodoMaster</span>
      </div>
      
      <!-- Team Selector -->
      <div v-if="currentTeam" class="px-4 py-3 bg-indigo-800 border-b border-indigo-600">
        <div class="relative">
          <button 
            @click="showTeamDropdown = !showTeamDropdown"
            class="w-full flex items-center justify-between px-3 py-2 text-sm text-white bg-indigo-700 rounded-md hover:bg-indigo-600"
          >
            <div class="flex items-center">
              <span class="material-icons text-sm mr-2">groups</span>
              <span class="truncate">{{ currentTeam.name }}</span>
            </div>
            <span class="material-icons text-sm">expand_more</span>
          </button>
          
          <!-- Team Dropdown -->
          <div v-if="showTeamDropdown" class="absolute top-full left-0 right-0 mt-1 bg-white rounded-md shadow-lg z-50">
            <div class="py-1">
              <div class="px-3 py-2 text-xs font-medium text-gray-500 uppercase tracking-wide">
                Switch Team
              </div>
              <button
                v-for="team in userTeams"
                :key="team.id"
                @click="handleTeamSwitch(team)"
                class="w-full text-left px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 flex items-center"
                :class="{ 'bg-indigo-50 text-indigo-700': team.id === currentTeam.id }"
              >
                <span class="material-icons text-sm mr-2">
                  {{ team.id === currentTeam.id ? 'check_circle' : 'group' }}
                </span>
                <div class="flex-1">
                  <div class="font-medium">{{ team.name }}</div>
                  <div class="text-xs text-gray-500">{{ team.role }}</div>
                </div>
              </button>
              <div class="border-t border-gray-100 mt-1">
                <button
                  @click="showCreateTeamModal = true; showTeamDropdown = false"
                  class="w-full text-left px-3 py-2 text-sm text-indigo-600 hover:bg-gray-100 flex items-center"
                >
                  <span class="material-icons text-sm mr-2">add</span>
                  Create New Team
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- User Info Section -->
      <div v-if="user" class="px-4 py-3 bg-indigo-800 border-b border-indigo-600">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <div class="h-8 w-8 rounded-full bg-indigo-300 flex items-center justify-center">
              <span class="text-indigo-800 font-medium text-sm">
                {{ userInitials }}
              </span>
            </div>
          </div>
          <div class="ml-3">
            <p class="text-sm font-medium text-white">
              {{ userName }}
            </p>
            <p class="text-xs text-indigo-200 truncate">
              {{ user.email }}
            </p>
          </div>
        </div>
      </div>

      <nav class="mt-5">
        <NuxtLink 
          to="/dashboard" 
          class="mt-1 group flex items-center px-4 py-2 text-base font-medium text-white hover:bg-indigo-600"
          :class="{ 'bg-indigo-800': $route.path === '/dashboard' }"
        >
          <span class="material-icons mr-3">dashboard</span>
          Dashboard
        </NuxtLink>
        <NuxtLink 
          to="/dashboard/projects" 
          class="mt-1 group flex items-center px-4 py-2 text-base font-medium text-white hover:bg-indigo-600"
          :class="{ 'bg-indigo-800': $route.path.includes('/dashboard/projects') }"
        >
          <span class="material-icons mr-3">list</span>
          Projects
        </NuxtLink>
        <NuxtLink 
          to="/dashboard/settings" 
          class="mt-1 group flex items-center px-4 py-2 text-base font-medium text-white hover:bg-indigo-600"
          :class="{ 'bg-indigo-800': $route.path === '/dashboard/settings' }"
        >
          <span class="material-icons mr-3">settings</span>
          Settings
        </NuxtLink>
      </nav>
    </div>

    <!-- Main Content -->
    <div class="pl-64">
      <!-- Top Navigation -->
      <div class="bg-white h-16 flex items-center justify-end px-4 shadow">
        <div class="flex items-center">
          <button 
            @click="handleLogout"
            :disabled="loading"
            class="flex items-center text-gray-700 hover:text-indigo-600 disabled:opacity-50"
          >
            <span class="material-icons mr-1">logout</span>
            {{ loading ? 'Logging out...' : 'Logout' }}
          </button>
        </div>
      </div>

      <main class="p-6">
        <slot />
      </main>
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
              :disabled="teamLoading"
              class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
            >
              {{ teamLoading ? 'Creating...' : 'Create' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Click outside to close dropdown -->
    <div v-if="showTeamDropdown" @click="showTeamDropdown = false" class="fixed inset-0 z-40"></div>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const { currentTeam, userTeams, switchTeam, createTeam, initializeTeam } = useTeam()

const loading = ref(false)
const showTeamDropdown = ref(false)
const showCreateTeamModal = ref(false)
const teamLoading = ref(false)
const newTeam = reactive({
  name: '',
  description: ''
})

// Computed properties for user display
const userName = computed(() => {
  if (!user.value) return ''
  return user.value.user_metadata?.full_name || 
         user.value.email?.split('@')[0] || 
         'User'
})

const userInitials = computed(() => {
  if (!user.value) return ''
  const name = user.value.user_metadata?.full_name || user.value.email || ''
  return name.split(' ')
    .map(word => word.charAt(0))
    .join('')
    .toUpperCase()
    .slice(0, 2)
})

const handleTeamSwitch = (team) => {
  switchTeam(team)
  showTeamDropdown.value = false
  // Refresh current page to load team-specific data
  window.location.reload()
}

const handleCreateTeam = async () => {
  if (!newTeam.name.trim()) return
  
  teamLoading.value = true
  try {
    await createTeam(newTeam.name, newTeam.description)
    showCreateTeamModal.value = false
    newTeam.name = ''
    newTeam.description = ''
  } catch (error) {
    console.error('Error creating team:', error)
  } finally {
    teamLoading.value = false
  }
}

const handleLogout = async () => {
  loading.value = true
  
  try {
    const { error } = await supabase.auth.signOut()
    if (error) {
      console.error('Error logging out:', error.message)
    } else {
      await navigateTo('/login')
    }
  } catch (error) {
    console.error('Unexpected error during logout:', error)
  } finally {
    loading.value = false
  }
}

// Initialize teams when component mounts
onMounted(async () => {
  if (user.value) {
    await initializeTeam()
  }
})
</script>