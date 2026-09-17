<script setup lang="ts">
const now = new Date()

const dateText = new Intl.DateTimeFormat('th-TH', {
  dateStyle: 'full'
}).format(now)

const timeText = new Intl.DateTimeFormat('th-TH', {
  hour: '2-digit',
  minute: '2-digit'
}).format(now)
</script>

<template>
  <section
    class="relative overflow-hidden rounded-2xl bg-slate-900 px-6 py-7 text-white lg:px-8"
  >
    <div
      class="absolute inset-0 bg-gradient-to-r from-blue-950/80 via-slate-900/90 to-slate-900"
    />

    <div class="relative flex flex-col justify-between gap-8 lg:flex-row lg:items-center">
      <div>
        <p class="text-sm text-blue-300">
          ERP Dashboard
        </p>

        <h1 class="mt-2 text-2xl font-bold lg:text-3xl">
          สวัสดีครับ Pong
        </h1>

        <p class="mt-2 max-w-xl text-sm leading-6 text-slate-300 lg:text-base">
          ยินดีต้อนรับสู่ระบบ ERP จัดการธุรกิจของคุณให้ง่ายขึ้นในที่เดียว
        </p>
      </div>

      <div class="lg:text-right">
        <p class="text-sm text-slate-300">
          {{ dateText }}
        </p>

        <p class="mt-1 text-3xl font-bold">
          {{ timeText }}
        </p>

        <p class="mt-2 text-xs text-slate-400">
          ควบคุมงานได้ดี ธุรกิจเดินหน้าได้ไกลกว่า
        </p>
      </div>
    </div>
  </section>
</template>
