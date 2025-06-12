<template>
  <div>
    <h1 class="text-2xl font-bold text-gray-800 mb-6">Project Details</h1>
    <div class="bg-white shadow rounded-lg p-6">
      <p class="text-gray-600">Details for project ID: {{ $route.params['project-id'] }}</p>
    </div>
  </div>
</template>

<script setup>
definePageMeta({
  layout: 'sidebar'
})
</script>