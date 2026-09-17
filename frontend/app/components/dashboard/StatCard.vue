<script setup lang="ts">
defineProps<{
  label: string
  value: number | string
  icon: string
  detail?: string
  tone?: 'blue' | 'orange' | 'amber' | 'green' | 'red'
}>()

const toneClass = {
  blue: 'bg-blue-50 text-blue-600',
  orange: 'bg-orange-50 text-orange-600',
  amber: 'bg-amber-50 text-amber-600',
  green: 'bg-emerald-50 text-emerald-600',
  red: 'bg-red-50 text-red-600'
}
</script>

<template>
  <UCard class="shadow-sm">
    <div class="flex items-start justify-between gap-4">
      <div>
        <p class="text-sm text-slate-500">
          {{ label }}
        </p>

        <p class="mt-2 text-3xl font-bold text-slate-900">
          {{ value }}
        </p>

        <p
          v-if="detail"
          class="mt-2 text-xs text-slate-400"
        >
          {{ detail }}
        </p>
      </div>

      <div
        class="flex size-11 items-center justify-center rounded-xl"
        :class="toneClass[tone || 'blue']"
      >
        <UIcon
          :name="icon"
          class="size-5"
        />
      </div>
    </div>
  </UCard>
</template>
