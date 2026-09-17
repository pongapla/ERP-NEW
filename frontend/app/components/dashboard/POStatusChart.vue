<script setup lang="ts">
const statuses = [
  { label: 'รออนุมัติ', value: 3, class: 'bg-amber-400' },
  { label: 'ส่งแล้ว', value: 12, class: 'bg-blue-500' },
  { label: 'รับบางส่วน', value: 5, class: 'bg-orange-400' },
  { label: 'รับครบ', value: 3, class: 'bg-emerald-500' },
  { label: 'ยกเลิก', value: 1, class: 'bg-slate-400' }
]
</script>

<template>
  <UCard class="h-full shadow-sm">
    <template #header>
      <h2 class="font-semibold text-slate-900">
        สัดส่วนสถานะ PO
      </h2>
    </template>

    <div class="flex flex-col items-center">
      <div
        class="relative flex size-40 items-center justify-center rounded-full"
        style="
          background:
            conic-gradient(
              #3b82f6 0 50%,
              #fb923c 50% 71%,
              #10b981 71% 83.5%,
              #fbbf24 83.5% 96%,
              #94a3b8 96% 100%
            );
        "
      >
        <div
          class="flex size-24 flex-col items-center justify-center rounded-full bg-white"
        >
          <span class="text-xs text-slate-500">
            ทั้งหมด
          </span>

          <span class="text-2xl font-bold text-slate-900">
            24
          </span>
        </div>
      </div>

      <div class="mt-6 w-full space-y-2">
        <div
          v-for="status in statuses"
          :key="status.label"
          class="flex items-center justify-between text-sm"
        >
          <div class="flex items-center gap-2">
            <span
              class="size-2.5 rounded-full"
              :class="status.class"
            />

            <span class="text-slate-600">
              {{ status.label }}
            </span>
          </div>

          <span class="font-medium text-slate-900">
            {{ status.value }}
          </span>
        </div>
      </div>
    </div>
  </UCard>
</template>
