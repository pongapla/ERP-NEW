<script setup lang="ts">
const alerts = [
  {
    title: 'PO เลยกำหนดส่ง',
    detail: 'มี 3 รายการที่เลยกำหนดส่ง',
    icon: 'i-lucide-triangle-alert',
    iconClass: 'bg-red-50 text-red-600'
  },
  {
    title: 'Quotation ใกล้หมดอายุ',
    detail: 'มี 2 รายการภายใน 7 วัน',
    icon: 'i-lucide-clock-3',
    iconClass: 'bg-orange-50 text-orange-600'
  },
  {
    title: 'PR ค้างอนุมัติ',
    detail: 'มี 4 รายการค้างเกิน 3 วัน',
    icon: 'i-lucide-file-clock',
    iconClass: 'bg-blue-50 text-blue-600'
  },
  {
    title: 'รับของไม่ครบตาม PO',
    detail: 'มี 5 รายการที่ยังรับไม่ครบ',
    icon: 'i-lucide-package-open',
    iconClass: 'bg-slate-100 text-slate-600'
  }
]
</script>

<template>
  <UCard class="h-full shadow-sm">
    <template #header>
      <h2 class="font-semibold text-slate-900">
        แจ้งเตือน / สิ่งที่ต้องติดตาม
      </h2>
    </template>

    <div class="space-y-2">
      <button
        v-for="alert in alerts"
        :key="alert.title"
        class="flex w-full items-center gap-3 rounded-xl p-3 text-left transition hover:bg-slate-50"
      >
        <span
          class="flex size-10 shrink-0 items-center justify-center rounded-xl"
          :class="alert.iconClass"
        >
          <UIcon
            :name="alert.icon"
            class="size-5"
          />
        </span>

        <span class="min-w-0 flex-1">
          <span class="block text-sm font-medium text-slate-900">
            {{ alert.title }}
          </span>

          <span class="mt-0.5 block text-xs text-slate-500">
            {{ alert.detail }}
          </span>
        </span>

        <UIcon
          name="i-lucide-chevron-right"
          class="size-4 text-slate-400"
        />
      </button>
    </div>
  </UCard>
</template>
