<script setup lang="ts">
const email = ref("");
const password = ref("");
const loading = ref(false);

async function handleLogin() {
  loading.value = true;

  try {
    // mock login ก่อน
    await new Promise((resolve) => setTimeout(resolve, 500));

    await navigateTo("/dashboard");
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 px-4">
    <UCard class="w-full max-w-md">
      <template #header>
        <div class="text-center">
          <h1 class="text-2xl font-bold">ERP-NEW</h1>

          <p class="mt-1 text-sm text-gray-500">Sign in to continue</p>
        </div>
      </template>

      <form class="space-y-4" @submit.prevent="handleLogin">
        <UFormField label="Email">
          <UInput
            v-model="email"
            type="email"
            placeholder="name@company.com"
            class="w-full"
          />
        </UFormField>

        <UFormField label="Password">
          <UInput
            v-model="password"
            type="password"
            placeholder="••••••••"
            class="w-full"
          />
        </UFormField>

        <UButton type="submit" block :loading="loading"> Login </UButton>
      </form>
    </UCard>
  </div>
</template>
