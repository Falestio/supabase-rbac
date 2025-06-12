<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold text-gray-800">All Projects</h1>
      <button 
        @click="showCreateModal = true"
        class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
      >
        Create Project
      </button>
    </div>

    <!-- Projects Grid -->
    <div v-if="projects.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div 
        v-for="project in projects" 
        :key="project.id"
        class="bg-white shadow rounded-lg p-6 hover:shadow-md transition-shadow cursor-pointer"
        @click="navigateTo(`/dashboard/projects/${project.id}`)"
      >
        <h3 class="text-lg font-semibold text-gray-800 mb-2">{{ project.name }}</h3>
        <p class="text-gray-600 text-sm mb-4">{{ project.description || 'No description' }}</p>
        <div class="flex justify-between items-center text-sm text-gray-500">
          <span>{{ formatDate(project.created_at) }}</span>
          <span>{{ project.todo_count || 0 }} todos</span>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="bg-white shadow rounded-lg p-12 text-center">
      <div class="text-gray-400 mb-4">
        <span class="material-icons text-6xl">folder_open</span>
      </div>
      <h3 class="text-lg font-medium text-gray-900 mb-2">No projects yet</h3>
      <p class="text-gray-600 mb-4">Get started by creating your first project.</p>
      <button 
        @click="showCreateModal = true"
        class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
      >
        Create Project
      </button>
    </div>

    <!-- Create Project Modal -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-lg font-semibold mb-4">Create New Project</h2>
        <form @submit.prevent="createProject">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Project Name</label>
            <input 
              v-model="newProject.name"
              type="text" 
              required
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            >
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Description</label>
            <textarea 
              v-model="newProject.description"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            ></textarea>
          </div>
          <div class="flex justify-end space-x-3">
            <button 
              type="button"
              @click="showCreateModal = false"
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
  </div>
</template>

<script setup>
definePageMeta({
  layout: 'sidebar',
})

const supabase = useSupabaseClient()
const user = useSupabaseUser()

const projects = ref([])
const loading = ref(false)
const showCreateModal = ref(false)
const newProject = reactive({
  name: '',
  description: ''
})

const fetchProjects = async () => {
  try {
    const { data, error } = await supabase
      .from('projects')
      .select(`
        *,
        todos!inner(count)
      `)
      .eq('user_id', user.value.id)
      .order('created_at', { ascending: false })

    if (error) throw error
    
    // Process the data to get todo counts
    projects.value = data.map(project => ({
      ...project,
      todo_count: project.todos?.length || 0
    }))
  } catch (error) {
    console.error('Error fetching projects:', error)
  }
}

const createProject = async () => {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('projects')
      .insert([
        {
          name: newProject.name,
          description: newProject.description,
          user_id: user.value.id
        }
      ])
      .select()

    if (error) throw error

    projects.value.unshift({ ...data[0], todo_count: 0 })
    showCreateModal.value = false
    newProject.name = ''
    newProject.description = ''
  } catch (error) {
    console.error('Error creating project:', error)
  } finally {
    loading.value = false
  }
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString()
}

onMounted(() => {
  fetchProjects()
})
</script>