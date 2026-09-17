<template>
  <UCard class="h-full shadow-sm">
    <template #header>
      <div class="flex items-center justify-between">
        <div>
          <h2 class="font-semibold text-slate-900">
            สรุปการจัดซื้อ
          </h2>

          <p class="mt-1 text-xs text-slate-500">
            ประจำเดือนกันยายน 2026
          </p>
        </div>

        <UButton
          color="neutral"
          variant="outline"
          trailing-icon="i-lucide-chevron-down"
          size="sm"
        >
          กันยายน 2026
        </UButton>
      </div>
    </template>

    <div class="grid gap-6 sm:grid-cols-2 xl:grid-cols-4">
      <div>
        <p class="text-sm text-slate-500">
          จำนวน PR
        </p>
        <p class="mt-1 text-2xl font-bold">
          28
        </p>
        <p class="mt-1 text-xs text-emerald-600">
          ↑ 12% จากเดือนก่อน
        </p>
      </div>

      <div>
        <p class="text-sm text-slate-500">
          จำนวน PO
        </p>
        <p class="mt-1 text-2xl font-bold">
          18
        </p>
        <p class="mt-1 text-xs text-emerald-600">
          ↑ 8% จากเดือนก่อน
        </p>
      </div>

      <div>
        <p class="text-sm text-slate-500">
          มูลค่าการสั่งซื้อ
        </p>
        <p class="mt-1 text-2xl font-bold">
          ฿1.24M
        </p>
        <p class="mt-1 text-xs text-emerald-600">
          ↑ 15% จากเดือนก่อน
        </p>
      </div>

      <div>
        <p class="text-sm text-slate-500">
          รับของแล้ว
        </p>
        <p class="mt-1 text-2xl font-bold">
          65%
        </p>

        <div class="mt-3 h-2 overflow-hidden rounded-full bg-slate-100">
          <div class="h-full w-[65%] rounded-full bg-blue-600" />
        </div>
      </div>
    </div>
  </UCard>
</template>
