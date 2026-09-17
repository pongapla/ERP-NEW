<template>
  <div class="flex min-h-screen bg-slate-100">
    <LayoutAppSidebar />

    <div class="min-w-0 flex-1">
      <LayoutAppHeader />

      <main class="min-h-[calc(100vh-5rem)] p-5 lg:p-6">
        <slot />
      </main>
    </div>
  </div>
</template>
