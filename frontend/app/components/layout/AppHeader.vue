<script setup lang="ts">
const { t } = useI18n()

const handleLogout = async () => {
  await navigateTo('/login')
}
</script>

<template>
  <header class="flex h-20 items-center border-b border-slate-200 bg-white px-6">
    <div class="flex w-full items-center gap-6">
      <UButton
        icon="i-lucide-menu"
        color="neutral"
        variant="ghost"
        square
      />

      <button class="flex items-center gap-2 font-semibold text-slate-800">
        {{ t('header.company') }}
        <UIcon
          name="i-lucide-chevron-down"
          class="size-4"
        />
      </button>

      <div class="mx-auto w-full max-w-md">
        <UInput
          icon="i-lucide-search"
          :placeholder="t('header.searchPlaceholder')"
          class="w-full"
        />
      </div>

      <div class="flex items-center gap-3">
        <UButton
          icon="i-lucide-bell"
          color="neutral"
          variant="ghost"
          square
        />

        <UDropdownMenu
          :items="[
            [
              {
                label: t('common.profile'),
                icon: 'i-lucide-user'
              },
              {
                label: t('common.changePassword'),
                icon: 'i-lucide-key-round'
              }
            ],
            [
              {
                label: t('common.logout'),
                icon: 'i-lucide-log-out',
                onSelect: handleLogout
              }
            ]
          ]"
        >
          <UButton
            color="neutral"
            variant="ghost"
            trailing-icon="i-lucide-chevron-down"
          >
            <div class="text-left">
              <div class="text-sm font-semibold text-slate-900">
                Pong
              </div>

              <div class="text-xs text-slate-500">
                {{ t('header.administrator') }}
              </div>
            </div>
          </UButton>
        </UDropdownMenu>

        <LayoutAppLanguageSwitcher />
      </div>
    </div>
  </header>
</template>
