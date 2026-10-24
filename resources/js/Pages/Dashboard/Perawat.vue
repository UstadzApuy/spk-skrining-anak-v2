<script setup>
import PatientSelectionDashboard from '@/Components/PatientSelectionDashboard.vue';

defineProps({
    patients: {
        type: Array,
        default: () => [],
    },
    stats: {
        type: Object,
        default: () => ({
            active_profiles: 0,
            today_screenings: 0,
            pending_reports: 0,
        }),
    },
});
</script>

<template>
    <PatientSelectionDashboard :patients="patients" :stats="stats" />
</template>