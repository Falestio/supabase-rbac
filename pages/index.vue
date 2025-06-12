<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Navigation Bar -->
    <nav class="bg-white shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <span class="text-xl font-bold text-indigo-600">TodoMaster</span>
          </div>
          <div class="flex items-center space-x-4">
            <NuxtLink to="/login" class="px-4 py-2 text-sm font-medium text-gray-700 hover:text-indigo-600">
              Login
            </NuxtLink>
            <NuxtLink to="/register" class="px-4 py-2 text-sm font-medium bg-indigo-600 text-white rounded-md hover:bg-indigo-700">
              Register
            </NuxtLink>
          </div>
        </div>
      </div>
    </nav>

    <!-- Hero Section -->
    <main>
      <div class="max-w-7xl mx-auto py-16 px-4 sm:px-6 lg:px-8">
        <div class="text-center">
          <h1 class="text-4xl font-extrabold text-gray-900 sm:text-5xl sm:tracking-tight lg:text-6xl">
            Organize your tasks with ease
          </h1>
          <p class="mt-5 max-w-xl mx-auto text-xl text-gray-500">
            TodoMaster helps you manage your daily tasks, set priorities, and track your progress to boost productivity.
          </p>
          <div class="mt-8 flex justify-center">
            <NuxtLink to="/register" class="px-8 py-3 border border-transparent text-base font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 md:py-4 md:text-lg md:px-10">
              Get started
            </NuxtLink>
          </div>
        </div>
        
        <div class="mt-16">
          <div class="bg-white shadow overflow-hidden rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900">
                Features that make task management simple
              </h3>
              <div class="mt-5 grid grid-cols-1 gap-5 sm:grid-cols-3">
                <div class="bg-gray-50 p-4 rounded-lg">
                  <h4 class="font-semibold text-indigo-600">Easy Task Creation</h4>
                  <p class="mt-2 text-sm text-gray-500">Create tasks quickly with just a few clicks</p>
                </div>
                <div class="bg-gray-50 p-4 rounded-lg">
                  <h4 class="font-semibold text-indigo-600">Task Categories</h4>
                  <p class="mt-2 text-sm text-gray-500">Organize tasks by categories for better management</p>
                </div>
                <div class="bg-gray-50 p-4 rounded-lg">
                  <h4 class="font-semibold text-indigo-600">Progress Tracking</h4>
                  <p class="mt-2 text-sm text-gray-500">Monitor your productivity with visual statistics</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>