<script setup lang="ts">
const { locale, setLocale } = useI18n()

const items = [
  [
    {
      label: 'ไทย',
      icon: 'i-lucide-languages',
      onSelect: () => setLocale('th')
    },
    {
      label: 'English',
      icon: 'i-lucide-languages',
      onSelect: () => setLocale('en')
    }
  ]
]

const currentLabel = computed(() => {
  return locale.value === 'th' ? 'TH' : 'EN'
})
</script>

<template>
  <UDropdownMenu :items="items">
    <UButton
      color="neutral"
      variant="outline"
      trailing-icon="i-lucide-chevron-down"
    >
      {{ currentLabel }}
    </UButton>
  </UDropdownMenu>
</template>
