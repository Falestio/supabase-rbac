<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <div>
        <NuxtLink to="/dashboard/projects" class="text-indigo-600 hover:text-indigo-800 text-sm mb-2 inline-block">
          ← Back to Projects
        </NuxtLink>
        <h1 class="text-2xl font-bold text-gray-800">{{ project?.name || 'Loading...' }}</h1>
        <p v-if="project?.description" class="text-gray-600 mt-1">{{ project.description }}</p>
      </div>
    </div>

    <div v-if="project" class="bg-white shadow rounded-lg p-6">
      <!-- Add Todo Form -->
      <form @submit.prevent="addTodo" class="mb-6">
        <div class="flex space-x-3">
          <input 
            v-model="newTodo.title"
            type="text" 
            placeholder="Add a new todo..."
            required
            class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
          >
          <button 
            type="submit"
            :disabled="loading"
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
          >
            {{ loading ? 'Adding...' : 'Add' }}
          </button>
        </div>
        <input 
          v-model="newTodo.description"
          type="text" 
          placeholder="Description (optional)"
          class="w-full mt-2 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
        >
      </form>

      <!-- Todo List -->
      <div v-if="todos.length > 0" class="space-y-3">
        <div 
          v-for="todo in todos" 
          :key="todo.id"
          class="flex items-center space-x-3 p-3 border border-gray-200 rounded-md hover:bg-gray-50"
        >
          <input 
            :checked="todo.completed"
            @change="toggleTodo(todo)"
            type="checkbox"
            class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
          >
          <div class="flex-1">
            <p :class="['font-medium', todo.completed ? 'line-through text-gray-500' : 'text-gray-800']">
              {{ todo.title }}
            </p>
            <p v-if="todo.description" :class="['text-sm', todo.completed ? 'line-through text-gray-400' : 'text-gray-600']">
              {{ todo.description }}
            </p>
          </div>
          <button 
            @click="deleteTodo(todo.id)"
            class="text-red-600 hover:text-red-800 p-1"
          >
            <span class="material-icons text-sm">delete</span>
          </button>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-8">
        <div class="text-gray-400 mb-4">
          <span class="material-icons text-4xl">checklist</span>
        </div>
        <p class="text-gray-600">No todos yet. Add your first todo above!</p>
      </div>

      <!-- Todo Stats -->
      <div v-if="todos.length > 0" class="mt-6 pt-4 border-t border-gray-200">
        <div class="flex justify-between text-sm text-gray-600">
          <span>{{ completedCount }} of {{ todos.length }} completed</span>
          <span>{{ Math.round((completedCount / todos.length) * 100) }}% done</span>
        </div>
        <div class="w-full bg-gray-200 rounded-full h-2 mt-2">
          <div 
            class="bg-indigo-600 h-2 rounded-full transition-all duration-300"
            :style="{ width: `${(completedCount / todos.length) * 100}%` }"
          ></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
definePageMeta({
  layout: 'sidebar',
})

const route = useRoute()
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const { currentTeam } = useTeam()

const todos = ref([])
const project = ref(null)
const loading = ref(false)
const newTodo = reactive({
  title: '',
  description: ''
})

const projectId = route.params.projectid

const completedCount = computed(() => {
  return todos.value.filter(todo => todo.completed).length
})

const fetchProject = async () => {
  if (!projectId || !user.value?.id || !currentTeam.value?.id) {
    console.error('Missing project ID, user ID, or team ID')
    return
  }

  try {
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .eq('id', projectId)
      .eq('team_id', currentTeam.value.id)
      .single()

    if (error) throw error
    project.value = data
  } catch (error) {
    console.error('Error fetching project:', error)
  }
}

const fetchTodos = async () => {
  if (!projectId || !user.value?.id || !currentTeam.value?.id) {
    console.error('Missing project ID, user ID, or team ID')
    return
  }

  try {
    const { data, error } = await supabase
      .from('todos')
      .select('*')
      .eq('project_id', projectId)
      .eq('team_id', currentTeam.value.id)
      .order('created_at', { ascending: false })

    if (error) throw error
    todos.value = data
  } catch (error) {
    console.error('Error fetching todos:', error)
  }
}

const addTodo = async () => {
  if (!newTodo.title.trim() || !projectId || !user.value?.id || !currentTeam.value?.id) return
  
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('todos')
      .insert([
        {
          title: newTodo.title,
          description: newTodo.description,
          project_id: projectId,
          user_id: user.value.id,
          team_id: currentTeam.value.id
        }
      ])
      .select()

    if (error) throw error

    todos.value.unshift(data[0])
    newTodo.title = ''
    newTodo.description = ''
  } catch (error) {
    console.error('Error adding todo:', error)
  } finally {
    loading.value = false
  }
}

const toggleTodo = async (todo) => {
  try {
    const { error } = await supabase
      .from('todos')
      .update({ completed: !todo.completed })
      .eq('id', todo.id)

    if (error) throw error

    const index = todos.value.findIndex(t => t.id === todo.id)
    if (index !== -1) {
      todos.value[index].completed = !todos.value[index].completed
    }
  } catch (error) {
    console.error('Error updating todo:', error)
  }
}

const deleteTodo = async (todoId) => {
  try {
    const { error } = await supabase
      .from('todos')
      .delete()
      .eq('id', todoId)

    if (error) throw error

    todos.value = todos.value.filter(todo => todo.id !== todoId)
  } catch (error) {
    console.error('Error deleting todo:', error)
  }
}

// Watch for team and user changes
watchEffect(async () => {
  if (user.value && projectId && currentTeam.value) {
    await fetchProject()
    await fetchTodos()
  }
})
</script>