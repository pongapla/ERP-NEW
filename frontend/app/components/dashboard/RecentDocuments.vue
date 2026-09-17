<script setup lang="ts">
const documents = [
  {
    no: 'PR-2609-0012',
    type: 'PR',
    party: '-',
    status: 'รออนุมัติ',
    date: '16/09/2026'
  },
  {
    no: 'PO-2609-0008',
    type: 'PO',
    party: 'ABC Co., Ltd.',
    status: 'ส่งแล้ว',
    date: '16/09/2026'
  },
  {
    no: 'GR-2609-0003',
    type: 'GR',
    party: 'ABC Co., Ltd.',
    status: 'รับครบ',
    date: '15/09/2026'
  },
  {
    no: 'PR-2609-0011',
    type: 'PR',
    party: '-',
    status: 'ถูกส่งกลับ',
    date: '15/09/2026'
  }
]

function statusClass(status: string) {
  if (status === 'รับครบ') {
    return 'bg-emerald-50 text-emerald-700'
  }

  if (status === 'ส่งแล้ว') {
    return 'bg-blue-50 text-blue-700'
  }

  if (status === 'ถูกส่งกลับ') {
    return 'bg-orange-50 text-orange-700'
  }

  return 'bg-amber-50 text-amber-700'
}
</script>

<template>
  <UCard class="h-full shadow-sm">
    <template #header>
      <div class="flex items-center justify-between">
        <h2 class="font-semibold text-slate-900">
          เอกสารล่าสุด
        </h2>

        <UButton
          color="neutral"
          variant="ghost"
          size="sm"
          trailing-icon="i-lucide-arrow-right"
        >
          ดูทั้งหมด
        </UButton>
      </div>
    </template>

    <div class="overflow-x-auto">
      <table class="w-full text-left text-sm">
        <thead>
          <tr class="border-b text-xs text-slate-500">
            <th class="pb-3 font-medium">
              เลขที่เอกสาร
            </th>
            <th class="pb-3 font-medium">
              ประเภท
            </th>
            <th class="pb-3 font-medium">
              Supplier / ลูกค้า
            </th>
            <th class="pb-3 font-medium">
              สถานะ
            </th>
            <th class="pb-3 text-right font-medium">
              วันที่
            </th>
          </tr>
        </thead>

        <tbody>
          <tr
            v-for="doc in documents"
            :key="doc.no"
            class="border-b border-slate-100 last:border-0"
          >
            <td class="py-4 font-medium text-blue-600">
              {{ doc.no }}
            </td>

            <td class="py-4 text-slate-600">
              {{ doc.type }}
            </td>

            <td class="py-4 text-slate-600">
              {{ doc.party }}
            </td>

            <td class="py-4">
              <span
                class="rounded-full px-2.5 py-1 text-xs font-medium"
                :class="statusClass(doc.status)"
              >
                {{ doc.status }}
              </span>
            </td>

            <td class="py-4 text-right text-slate-500">
              {{ doc.date }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </UCard>
</template>
