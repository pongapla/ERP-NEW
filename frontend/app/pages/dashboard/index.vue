<script setup lang="ts">
definePageMeta({
  layout: 'default'
})

const stats = [
  {
    label: 'PR รออนุมัติ',
    value: 5,
    detail: '↑ 2 จากเมื่อวาน',
    icon: 'i-lucide-file-clock',
    tone: 'blue' as const
  },
  {
    label: 'PR ถูกส่งกลับ',
    value: 2,
    detail: '↑ 1 จากเมื่อวาน',
    icon: 'i-lucide-rotate-ccw',
    tone: 'orange' as const
  },
  {
    label: 'PO รอออก',
    value: 3,
    detail: '↓ 1 จากเมื่อวาน',
    icon: 'i-lucide-shopping-cart',
    tone: 'amber' as const
  },
  {
    label: 'รอรับของ (GR)',
    value: 4,
    detail: '↑ 2 จากเมื่อวาน',
    icon: 'i-lucide-package-check',
    tone: 'green' as const
  },
  {
    label: 'เอกสารเลยกำหนด',
    value: 6,
    detail: '↑ 3 จากเมื่อวาน',
    icon: 'i-lucide-triangle-alert',
    tone: 'red' as const
  }
]
</script>

<template>
  <div class="space-y-5">
    <DashboardHero />

    <section class="grid gap-4 sm:grid-cols-2 xl:grid-cols-5">
      <DashboardStatCard
        v-for="stat in stats"
        :key="stat.label"
        v-bind="stat"
      />
    </section>

    <section class="grid gap-5 xl:grid-cols-3">
      <DashboardPurchasingSummary class="xl:col-span-2" />
      <DashboardPOStatusChart />
    </section>

    <section class="grid gap-5 xl:grid-cols-3">
      <DashboardRecentDocuments class="xl:col-span-2" />
      <DashboardFollowUpPanel />
    </section>
  </div>
</template>
