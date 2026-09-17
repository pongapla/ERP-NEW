<script setup lang="ts">
const { t } = useI18n()

const menus = computed(() => [
  {
    label: t('menu.dashboard'),
    icon: 'i-lucide-layout-dashboard',
    to: '/dashboard'
  },
  {
    label: t('menu.purchasing'),
    icon: 'i-lucide-shopping-cart'
  },
  {
    label: t('menu.sales'),
    icon: 'i-lucide-chart-column'
  },
  {
    label: t('menu.inventory'),
    icon: 'i-lucide-package'
  },
  {
    label: t('menu.planning'),
    icon: 'i-lucide-calendar-days'
  },
  {
    label: t('menu.production'),
    icon: 'i-lucide-settings'
  },
  {
    label: t('menu.qualityControl'),
    icon: 'i-lucide-shield-check'
  },
  {
    label: t('menu.maintenance'),
    icon: 'i-lucide-wrench'
  },
  {
    label: t('menu.accounting'),
    icon: 'i-lucide-receipt-text'
  },
  {
    label: t('menu.reports'),
    icon: 'i-lucide-bar-chart-3'
  }
])

const systemMenus = computed(() => [
  {
    label: t('menu.masterData'),
    icon: 'i-lucide-database'
  },
  {
    label: t('menu.settings'),
    icon: 'i-lucide-cog'
  }
])
</script>

<template>
  <aside class="flex h-screen w-72 flex-col bg-slate-950 text-white">
    <div class="border-b border-white/10 px-6 py-5">
      <div class="text-2xl font-bold">
        TrainX <span class="text-blue-400">ERP</span>
      </div>

      <div class="mt-1 text-xs text-slate-400">
        Simple • Efficient • Together
      </div>
    </div>

    <nav class="flex-1 overflow-y-auto px-3 py-5">
      <div class="space-y-1">
        <template
          v-for="menu in menus"
          :key="menu.label"
        >
          <NuxtLink
            v-if="menu.to"
            :to="menu.to"
            class="flex items-center gap-3 rounded-xl px-4 py-3 text-sm transition hover:bg-white/10"
            active-class="bg-blue-600 text-white"
          >
            <UIcon
              :name="menu.icon"
              class="size-5"
            />

            <span>
              {{ menu.label }}
            </span>
          </NuxtLink>

          <button
            v-else
            class="flex w-full items-center justify-between rounded-xl px-4 py-3 text-sm text-slate-200 transition hover:bg-white/10"
          >
            <span class="flex items-center gap-3">
              <UIcon
                :name="menu.icon"
                class="size-5"
              />

              {{ menu.label }}
            </span>

            <UIcon
              name="i-lucide-chevron-right"
              class="size-4 text-slate-500"
            />
          </button>
        </template>
      </div>

      <div class="my-5 border-t border-white/10" />

      <div class="space-y-1">
        <button
          v-for="menu in systemMenus"
          :key="menu.label"
          class="flex w-full items-center gap-3 rounded-xl px-4 py-3 text-sm text-slate-200 transition hover:bg-white/10"
        >
          <UIcon
            :name="menu.icon"
            class="size-5"
          />

          {{ menu.label }}
        </button>
      </div>
    </nav>

    <div class="border-t border-white/10 px-6 py-5">
      <div class="text-sm font-medium">
        ABC Manufacturing Co., Ltd.
      </div>

      <div class="mt-1 text-xs text-slate-500">
        Version 1.0.0
      </div>
    </div>
  </aside>
</template>
