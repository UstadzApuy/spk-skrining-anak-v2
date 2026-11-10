<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { usePage } from '@inertiajs/vue3';
import { renderMarkdown } from '@/utils/markdown';
import dokterGuide from '../../../docs/testing/GUIDE_TESTING_DOKTER.md?raw';
import perawatGuide from '../../../docs/testing/GUIDE_TESTING_PERAWAT.md?raw';
import orangTuaGuide from '../../../docs/testing/GUIDE_TESTING_ORANG_TUA.md?raw';

const guideTabs = [
    { key: 'dokter', label: 'Dokter', html: renderMarkdown(dokterGuide) },
    { key: 'perawat', label: 'Perawat', html: renderMarkdown(perawatGuide) },
    { key: 'orang_tua', label: 'Orang Tua', html: renderMarkdown(orangTuaGuide) },
];

const validTabKeys = guideTabs.map((tab) => tab.key);

function readStorage(key, fallback) {
    if (typeof window === 'undefined') {
        return fallback;
    }

    try {
        const value = window.localStorage.getItem(key);

        return value === null ? fallback : value;
    } catch {
        return fallback;
    }
}

function writeStorage(key, value) {
    if (typeof window === 'undefined') {
        return;
    }

    try {
        window.localStorage.setItem(key, String(value));
    } catch {
        return;
    }
}

function readPosition() {
    const stored = readStorage('testing-guide:position', null);

    if (!stored) {
        return null;
    }

    try {
        const position = JSON.parse(stored);

        if (typeof position?.x === 'number' && typeof position?.y === 'number') {
            return position;
        }
    } catch {
    }

    return null;
}

const page = usePage();
const role = computed(() => page.props.auth?.user?.role);

const defaultTab = computed(() => {
    if (role.value === 'dokter') {
        return 'dokter';
    }

    if (role.value === 'orang_tua') {
        return 'orang_tua';
    }

    return 'perawat';
});

const storedTab = readStorage('testing-guide:tab', null);
const isOpen = ref(readStorage('testing-guide:open', 'true') !== 'false');
const isMinimized = ref(readStorage('testing-guide:minimized', 'false') === 'true');
const activeTab = ref(validTabKeys.includes(storedTab) ? storedTab : defaultTab.value);
const position = ref(readPosition());
const dragging = ref(false);
const panelRef = ref(null);

const dragOffset = { x: 0, y: 0 };

const activeGuide = computed(
    () => guideTabs.find((tab) => tab.key === activeTab.value) ?? guideTabs[0],
);

const panelStyle = computed(() => {
    if (!position.value) {
        return {};
    }

    return {
        left: `${position.value.x}px`,
        top: `${position.value.y}px`,
        right: 'auto',
        bottom: 'auto',
    };
});

function clampPosition(x, y) {
    const panel = panelRef.value;
    const width = panel?.offsetWidth ?? 420;
    const height = panel?.offsetHeight ?? 480;
    const maxX = Math.max(8, window.innerWidth - width - 8);
    const maxY = Math.max(8, window.innerHeight - height - 8);

    return {
        x: Math.min(Math.max(8, x), maxX),
        y: Math.min(Math.max(8, y), maxY),
    };
}

function startDrag(event) {
    if (event.target.closest('button')) {
        return;
    }

    const panel = panelRef.value;

    if (!panel) {
        return;
    }

    const point = event.touches ? event.touches[0] : event;
    const rect = panel.getBoundingClientRect();

    dragOffset.x = point.clientX - rect.left;
    dragOffset.y = point.clientY - rect.top;
    dragging.value = true;

    window.addEventListener('mousemove', onDrag);
    window.addEventListener('mouseup', stopDrag);
    window.addEventListener('touchmove', onDrag, { passive: false });
    window.addEventListener('touchend', stopDrag);
}

function onDrag(event) {
    if (!dragging.value) {
        return;
    }

    const point = event.touches ? event.touches[0] : event;
    position.value = clampPosition(point.clientX - dragOffset.x, point.clientY - dragOffset.y);

    if (event.cancelable) {
        event.preventDefault();
    }
}

function stopDrag() {
    dragging.value = false;

    if (position.value) {
        writeStorage('testing-guide:position', JSON.stringify(position.value));
    }

    window.removeEventListener('mousemove', onDrag);
    window.removeEventListener('mouseup', stopDrag);
    window.removeEventListener('touchmove', onDrag);
    window.removeEventListener('touchend', stopDrag);
}

function openGuide() {
    isOpen.value = true;
    isMinimized.value = false;
}

function closeGuide() {
    isOpen.value = false;
}

function toggleMinimized() {
    isMinimized.value = !isMinimized.value;

    if (position.value) {
        nextTick(() => {
            position.value = clampPosition(position.value.x, position.value.y);
        });
    }
}

function onWindowResize() {
    if (position.value) {
        position.value = clampPosition(position.value.x, position.value.y);
    }
}

watch(isOpen, (value) => writeStorage('testing-guide:open', value));
watch(isMinimized, (value) => writeStorage('testing-guide:minimized', value));
watch(activeTab, (value) => writeStorage('testing-guide:tab', value));

onMounted(() => {
    window.addEventListener('resize', onWindowResize);

    if (position.value) {
        nextTick(() => {
            position.value = clampPosition(position.value.x, position.value.y);
        });
    }
});

onBeforeUnmount(() => {
    stopDrag();
    window.removeEventListener('resize', onWindowResize);
});
</script>

<template>
    <section
        v-if="isOpen"
        ref="panelRef"
        class="testing-guide fixed bottom-6 right-6 z-50 flex max-h-[calc(100vh-3rem)] w-[26rem] max-w-[calc(100vw-2rem)] flex-col overflow-hidden rounded-2xl border border-sand/60 bg-white/98 shadow-2xl ring-1 ring-navy/10 backdrop-blur-md dark:border-white/15 dark:bg-[#0C2038]/98 dark:ring-white/10 print:hidden"
        :class="{ 'h-[70vh]': !isMinimized, 'opacity-95': dragging }"
        :style="panelStyle"
        aria-label="Panduan pengujian sistem"
    >
        <header
            class="flex cursor-move select-none items-center justify-between gap-2 bg-gradient-to-r from-navy to-teal px-3 py-2.5 text-white"
            @mousedown="startDrag"
            @touchstart="startDrag"
        >
            <div class="flex min-w-0 items-center gap-2">
                <div class="flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-white/15 ring-1 ring-white/20">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                </div>
                <div class="min-w-0">
                    <p class="truncate text-xs font-extrabold tracking-tight">Panduan Pengujian</p>
                    <p class="truncate text-[10px] font-semibold text-sand-light/80">
                        Blackbox &amp; SUS &bull; SDIDTK
                    </p>
                </div>
            </div>

            <div class="flex shrink-0 items-center gap-1">
                <button
                    type="button"
                    class="rounded-lg p-1.5 text-white/80 transition hover:bg-white/15 hover:text-white"
                    :title="isMinimized ? 'Perbesar panduan' : 'Perkecil panduan'"
                    :aria-label="isMinimized ? 'Perbesar panduan' : 'Perkecil panduan'"
                    @click="toggleMinimized"
                >
                    <svg v-if="isMinimized" class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" />
                    </svg>
                    <svg v-else class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14" />
                    </svg>
                </button>

                <button
                    type="button"
                    class="rounded-lg p-1.5 text-white/80 transition hover:bg-rose-500/30 hover:text-white"
                    title="Tutup panduan"
                    aria-label="Tutup panduan"
                    @click="closeGuide"
                >
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </header>

        <template v-if="!isMinimized">
            <div class="grid grid-cols-3 gap-1 border-b border-sand/50 bg-sand/15 p-1.5 dark:border-white/10 dark:bg-white/5">
                <button
                    v-for="tab in guideTabs"
                    :key="tab.key"
                    type="button"
                    class="rounded-lg px-2 py-1.5 text-[11px] font-bold transition"
                    :class="
                        activeTab === tab.key
                            ? 'bg-teal text-white shadow-sm ring-1 ring-teal-dark/30'
                            : 'text-navy/70 hover:bg-white hover:text-teal dark:text-gray-300 dark:hover:bg-white/10 dark:hover:text-sand-light'
                    "
                    @click="activeTab = tab.key"
                >
                    {{ tab.label }}
                </button>
            </div>

            <div class="guide-content min-h-0 flex-1 overflow-y-auto px-4 py-3 text-navy dark:text-gray-200" v-html="activeGuide.html"></div>
        </template>
    </section>

    <button
        v-else
        type="button"
        class="fixed bottom-6 right-6 z-50 flex items-center gap-2 rounded-full bg-gradient-to-r from-navy to-teal px-4 py-3 text-xs font-extrabold text-white shadow-xl ring-1 ring-white/20 transition hover:scale-105 hover:from-teal hover:to-navy print:hidden"
        title="Buka panduan pengujian"
        @click="openGuide"
    >
        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
        </svg>
        Panduan
    </button>
</template>

<style scoped>
.testing-guide {
    transition:
        box-shadow 150ms ease,
        opacity 150ms ease;
}

.guide-content {
    font-size: 0.75rem;
    line-height: 1.55;
}

.guide-content :deep(h1) {
    margin: 0.25rem 0 0.5rem;
    font-size: 1rem;
    font-weight: 800;
    line-height: 1.3;
    color: var(--color-teal-dark);
}

.guide-content :deep(h2) {
    margin: 1rem 0 0.4rem;
    padding-bottom: 0.2rem;
    border-bottom: 1px solid rgb(223 203 158 / 0.7);
    font-size: 0.875rem;
    font-weight: 800;
    line-height: 1.35;
    color: var(--color-navy);
}

.guide-content :deep(h3) {
    margin: 0.85rem 0 0.35rem;
    font-size: 0.8125rem;
    font-weight: 800;
    line-height: 1.35;
    color: var(--color-teal-dark);
}

.guide-content :deep(h4) {
    margin: 0.7rem 0 0.3rem;
    font-size: 0.75rem;
    font-weight: 800;
    color: var(--color-navy);
}

.guide-content :deep(p) {
    margin: 0.4rem 0;
}

.guide-content :deep(strong) {
    font-weight: 800;
}

.guide-content :deep(em) {
    font-style: italic;
}

.guide-content :deep(a) {
    color: var(--color-teal);
    font-weight: 600;
    text-decoration: underline;
    text-underline-offset: 2px;
}

.guide-content :deep(ul) {
    margin: 0.4rem 0;
    padding-left: 1.1rem;
    list-style: disc;
}

.guide-content :deep(ol) {
    margin: 0.4rem 0;
    padding-left: 1.1rem;
    list-style: decimal;
}

.guide-content :deep(li) {
    margin: 0.2rem 0;
}

.guide-content :deep(li > ul),
.guide-content :deep(li > ol) {
    margin: 0.2rem 0;
}

.guide-content :deep(hr) {
    margin: 0.75rem 0;
    border: 0;
    border-top: 1px solid rgb(223 203 158 / 0.7);
}

.guide-content :deep(blockquote) {
    margin: 0.5rem 0;
    padding: 0.4rem 0.65rem;
    border-left: 3px solid var(--color-teal);
    border-radius: 0 0.4rem 0.4rem 0;
    background: rgb(17 96 103 / 0.08);
    color: inherit;
}

.guide-content :deep(blockquote p) {
    margin: 0.15rem 0;
}

.guide-content :deep(code) {
    border-radius: 0.25rem;
    background: rgb(7 29 55 / 0.08);
    padding: 0.08rem 0.3rem;
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    font-size: 0.9em;
}

.guide-content :deep(pre) {
    margin: 0.5rem 0;
    overflow-x: auto;
    border-radius: 0.5rem;
    background: #0b1220;
    padding: 0.55rem 0.65rem;
    color: #e2e8f0;
}

.guide-content :deep(pre code) {
    background: transparent;
    padding: 0;
    color: inherit;
}

.guide-content :deep(.md-table-wrap) {
    margin: 0.5rem 0;
    overflow-x: auto;
    border: 1px solid rgb(223 203 158 / 0.8);
    border-radius: 0.5rem;
}

.guide-content :deep(table) {
    width: 100%;
    min-width: 30rem;
    border-collapse: collapse;
    font-size: 0.6875rem;
    line-height: 1.4;
}

.guide-content :deep(th) {
    background: rgb(223 203 158 / 0.35);
    padding: 0.35rem 0.4rem;
    font-weight: 800;
    color: var(--color-navy);
    border-bottom: 1px solid rgb(223 203 158 / 0.9);
}

.guide-content :deep(td) {
    padding: 0.35rem 0.4rem;
    border-top: 1px solid rgb(223 203 158 / 0.45);
    vertical-align: top;
}

.guide-content :deep(tbody tr:nth-child(even)) {
    background: rgb(223 203 158 / 0.1);
}

.dark .guide-content :deep(h1),
.dark .guide-content :deep(h2),
.dark .guide-content :deep(h3),
.dark .guide-content :deep(h4) {
    color: var(--color-sand-light);
}

.dark .guide-content :deep(h2) {
    border-bottom-color: rgb(255 255 255 / 0.12);
}

.dark .guide-content :deep(hr) {
    border-top-color: rgb(255 255 255 / 0.12);
}

.dark .guide-content :deep(blockquote) {
    background: rgb(17 96 103 / 0.25);
}

.dark .guide-content :deep(code) {
    background: rgb(255 255 255 / 0.1);
}

.dark .guide-content :deep(.md-table-wrap) {
    border-color: rgb(255 255 255 / 0.14);
}

.dark .guide-content :deep(th) {
    background: rgb(255 255 255 / 0.08);
    color: var(--color-sand-light);
    border-bottom-color: rgb(255 255 255 / 0.16);
}

.dark .guide-content :deep(td) {
    border-top-color: rgb(255 255 255 / 0.1);
}

.dark .guide-content :deep(tbody tr:nth-child(even)) {
    background: rgb(255 255 255 / 0.03);
}
</style>
