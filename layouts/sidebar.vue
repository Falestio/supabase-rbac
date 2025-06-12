<template>
  <div class="min-h-screen bg-gray-100">
    <!-- Sidebar -->
    <div class="fixed inset-y-0 left-0 w-64 bg-indigo-700 overflow-y-auto">
      <div class="flex items-center justify-center h-16 bg-indigo-800">
        <span class="text-white font-bold text-xl">TodoMaster</span>
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
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const loading = ref(false)

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

// Add material icons link to head
useHead({
  link: [
    {
      rel: 'stylesheet',
      href: 'https://fonts.googleapis.com/icon?family=Material+Icons',
    }
  ]
})
</script>
