<template>
  <div class="min-h-screen bg-gray-100">
    <!-- Sidebar -->
    <div class="fixed inset-y-0 left-0 w-64 bg-indigo-700 overflow-y-auto">
      <div class="flex items-center justify-center h-16 bg-indigo-800">
        <span class="text-white font-bold text-xl">TodoMaster</span>
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
          <button class="flex items-center text-gray-700 hover:text-indigo-600">
            <span class="material-icons mr-1">logout</span>
            Logout
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
