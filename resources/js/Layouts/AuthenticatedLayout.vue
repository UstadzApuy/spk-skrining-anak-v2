<script setup>
import { router, usePage } from '@inertiajs/vue3';

const page = usePage();

const user = page.props.auth.user;

const logout = () => {
    router.post('/logout');
};
</script>

<template>
    <div class="min-h-screen bg-gray-100">
        <aside
            class="fixed inset-y-0 left-0 flex w-64 flex-col border-r border-gray-200 bg-white"
        >
            <div class="border-b border-gray-200 px-6 py-5">
                <h1 class="text-lg font-bold text-gray-900">
                    SPK Skrining Anak
                </h1>

                <p class="mt-1 text-xs text-gray-500">
                    Sistem Pendukung Keputusan
                </p>
            </div>

            <nav class="flex-1 px-4 py-6">
                <a
                    href="/dashboard"
                    class="block rounded-lg px-4 py-3 text-sm font-medium text-gray-700 hover:bg-gray-100"
                >
                    Dashboard
                </a>
            </nav>

            <div class="border-t border-gray-200 p-4">
                <div class="mb-4">
                    <p class="truncate text-sm font-semibold text-gray-900">
                        {{ user.name }}
                    </p>

                    <p class="truncate text-xs text-gray-500">
                        {{ user.role }}
                    </p>
                </div>

                <button
                    type="button"
                    class="w-full rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
                    @click="logout"
                >
                    Keluar
                </button>
            </div>
        </aside>

        <div class="min-h-screen pl-64">
            <header class="border-b border-gray-200 bg-white px-8 py-5">
                <slot name="header" />
            </header>

            <main class="p-8">
                <slot />
            </main>
        </div>
    </div>
</template>