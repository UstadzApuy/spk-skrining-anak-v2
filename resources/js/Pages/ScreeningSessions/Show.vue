<script setup>
import { computed, ref } from 'vue';
import { Head, Link, router, useForm, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const page = usePage();
const isDoctor = computed(() => page.props.auth?.user?.role === 'dokter');

const showDeleteConfirm = ref(false);
const isDeleting = ref(false);

function executeDelete() {
    isDeleting.value = true;
    router.delete(`/screening-sessions/${props.session.id}`, {
        onFinish: () => {
            isDeleting.value = false;
            showDeleteConfirm.value = false;
        },
    });
}

const props = defineProps({
    session: {
        type: Object,
        required: true,
    },
    milestones: {
        type: Object,
        default: null,
    },
});

function formatDate(value) {
    if (!value) return '-';
    const [year, month, day] = String(value).slice(0, 10).split('-');
    return `${day}/${month}/${year}`;
}

const instrumentLabels = {
    KPSP: 'KPSP (Kuesioner Pra Skrining Perkembangan)',
    MCHAT: 'M-CHAT-R (Risiko Autisme Balita)',
    GPPH: 'GPPH / ACTRS (Hiperaktivitas & Pemusatan Perhatian)',
    SDQ: 'SDQ (Strengths and Difficulties Questionnaire)',
    SRQ: 'SRQ-20 (Kesehatan Mental Orang Tua/Pengasuh)',
};

const instrumentStatusLabels = {
    pending: 'Belum Dikerjakan',
    in_progress: 'Sedang Dikerjakan',
    completed: 'Selesai',
    cancelled: 'Dibatalkan',
};

const instrumentStatusClasses = {
    pending: 'bg-gray-100 dark:bg-white/10 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-white/10 font-semibold',
    in_progress: 'bg-blue-100 dark:bg-blue-950/70 text-blue-800 dark:text-blue-300 border-blue-200 dark:border-blue-800 font-semibold',
    completed: 'bg-emerald-100 dark:bg-emerald-950/70 text-emerald-800 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800 font-bold',
    cancelled: 'bg-rose-100 dark:bg-rose-950/70 text-rose-700 dark:text-rose-300 border-rose-200 dark:border-rose-800 font-semibold',
};

const sessionStatusLabels = {
    draft: 'Draft',
    in_progress: 'Sedang Berlangsung',
    pending_parent: 'Menunggu Orang Tua',
    pending_doctor_review: 'Menunggu Tinjauan Dokter',
    reviewed: 'Selesai Ditinjau',
    cancelled: 'Dibatalkan',
};

const sessionStatusClasses = {
    draft: 'bg-gray-100 dark:bg-white/10 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-white/10 font-semibold',
    in_progress: 'bg-blue-100 dark:bg-blue-950/70 text-blue-800 dark:text-blue-300 border-blue-200 dark:border-blue-800 font-semibold',
    pending_parent: 'bg-purple-100 dark:bg-purple-950/70 text-purple-800 dark:text-purple-300 border-purple-200 dark:border-purple-800 font-semibold',
    pending_doctor_review: 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-300 border-amber-200 dark:border-amber-800 font-semibold',
    reviewed: 'bg-emerald-100 dark:bg-emerald-950/70 text-emerald-800 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800 font-bold',
    cancelled: 'bg-rose-100 dark:bg-rose-950/70 text-rose-700 dark:text-rose-300 border-rose-200 dark:border-rose-800 font-semibold',
};

function categoryLabel(category) {
    const labels = {
        normal: 'Normal',
        ambang_borderline: 'Ambang / Borderline',
        abnormal: 'Abnormal',
        sesuai: 'Sesuai Tahap Perkembangan (Ds)',
        sesuai_umur: 'Sesuai Umur Perkembangan (Ds)',
        meragukan: 'Meragukan (Dm)',
        penyimpangan: 'Kemungkinan Penyimpangan (Dp)',
        kemungkinan_penyimpangan: 'Kemungkinan Penyimpangan (Dp)',
        risiko_rendah: 'Risiko Rendah',
        risiko_sedang_tinggi: 'Risiko Sedang - Tinggi',
        tidak_menunjukkan_gpph: 'Tidak Menunjukkan GPPH',
        kemungkinan_gpph: 'Kemungkinan GPPH',
        di_bawah_nilai_pisah: 'Di bawah nilai pisah (Skor 0–5)',
        gangguan_mental_emosional_distres: 'Memenuhi nilai pisah (Skor 6–20)',
        tidak_ada_gejala: 'Tidak Ada Gejala',
        gejala_ringan: 'Gejala Ringan',
        gejala_signifikan: 'Gejala Bermakna',
    };
    return labels[category] ?? category ?? '-';
}

const sdidtkCodeDetails = {
    Ds: {
        code: 'Ds',
        name: 'Sesuai Tahap Perkembangan',
        badge: 'bg-emerald-100 dark:bg-emerald-950/70 text-emerald-800 dark:text-emerald-200 border-emerald-300 dark:border-emerald-700 font-black',
        desc: 'Perkembangan anak optimal sesuai umur.',
    },
    Dm: {
        code: 'Dm',
        name: 'Meragukan',
        badge: 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-200 border-amber-300 dark:border-amber-700 font-black',
        desc: 'Perlu stimulasi intensif 2 minggu & evaluasi ulang.',
    },
    Dp: {
        code: 'Dp',
        name: 'Kemungkinan Penyimpangan',
        badge: 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-700 font-black',
        desc: 'Perlu segera dirujuk ke Rumah Sakit.',
    },
};

function getCategoryLevel(category) {
    switch (category) {
        case 'normal':
        case 'sesuai':
        case 'sesuai_umur':
        case 'risiko_rendah':
        case 'tidak_menunjukkan_gpph':
        case 'di_bawah_nilai_pisah':
        case 'tidak_ada_gejala':
            return 'good';
        case 'ambang_borderline':
        case 'meragukan':
        case 'gejala_ringan':
            return 'warning';
        case 'abnormal':
        case 'penyimpangan':
        case 'kemungkinan_penyimpangan':
        case 'risiko_sedang_tinggi':
        case 'kemungkinan_gpph':
        case 'gangguan_mental_emosional_distres':
        case 'gejala_signifikan':
            return 'danger';
        default:
            return 'neutral';
    }
}

function categoryBadgeClass(category) {
    const level = getCategoryLevel(category);
    if (level === 'good') {
        return 'bg-emerald-100 dark:bg-emerald-950/80 text-emerald-800 dark:text-emerald-200 border-emerald-300 dark:border-emerald-700 font-bold';
    }
    if (level === 'warning') {
        return 'bg-amber-100 dark:bg-amber-950/80 text-amber-800 dark:text-amber-200 border-amber-300 dark:border-amber-700 font-bold';
    }
    if (level === 'danger') {
        return 'bg-rose-100 dark:bg-rose-950/80 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-700 font-bold';
    }
    return 'bg-gray-100 dark:bg-white/10 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-white/10 font-semibold';
}

function getInstrumentTheme(category) {
    const level = getCategoryLevel(category);
    if (level === 'good') {
        return {
            level: 'good',
            headerBg: 'bg-emerald-50/80 dark:bg-emerald-950/40 border-b border-emerald-200 dark:border-emerald-800/60',
            headerTitle: 'text-emerald-950 dark:text-emerald-100',
            headerSubtitle: 'text-emerald-800/80 dark:text-emerald-300/80',
            headerTag: 'bg-emerald-600 dark:bg-emerald-500 text-white',
            statusBadge: 'bg-emerald-100 dark:bg-emerald-900/60 text-emerald-800 dark:text-emerald-200 border-emerald-300 dark:border-emerald-700 font-bold',
            scoreBox: 'bg-emerald-50/80 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-800/50',
            scoreLabel: 'text-emerald-800 dark:text-emerald-300',
            scoreValue: 'text-emerald-700 dark:text-emerald-300',
            scoreSubtext: 'text-emerald-700/80 dark:text-emerald-300/80',
            interpBox: 'bg-emerald-50/40 dark:bg-emerald-950/20 border border-emerald-200 dark:border-emerald-800/40',
            interpLabel: 'text-emerald-800 dark:text-emerald-300',
            interpTitle: 'text-emerald-900 dark:text-emerald-100 font-bold',
            interpText: 'text-emerald-900/90 dark:text-emerald-200/90',
        };
    }
    if (level === 'warning') {
        return {
            level: 'warning',
            headerBg: 'bg-amber-50/80 dark:bg-amber-950/40 border-b border-amber-200 dark:border-amber-800/60',
            headerTitle: 'text-amber-950 dark:text-amber-100',
            headerSubtitle: 'text-amber-800/80 dark:text-amber-300/80',
            headerTag: 'bg-amber-600 dark:bg-amber-500 text-white',
            statusBadge: 'bg-amber-100 dark:bg-amber-900/60 text-amber-800 dark:text-amber-200 border-amber-300 dark:border-amber-700 font-bold',
            scoreBox: 'bg-amber-50/80 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-800/50',
            scoreLabel: 'text-amber-800 dark:text-amber-300',
            scoreValue: 'text-amber-700 dark:text-amber-300',
            scoreSubtext: 'text-amber-700/80 dark:text-amber-300/80',
            interpBox: 'bg-amber-50/40 dark:bg-amber-950/20 border border-amber-200 dark:border-amber-800/40',
            interpLabel: 'text-amber-800 dark:text-amber-300',
            interpTitle: 'text-amber-900 dark:text-amber-100 font-bold',
            interpText: 'text-amber-900/90 dark:text-amber-200/90',
        };
    }
    if (level === 'danger') {
        return {
            level: 'danger',
            headerBg: 'bg-rose-50/80 dark:bg-rose-950/40 border-b border-rose-200 dark:border-rose-800/60',
            headerTitle: 'text-rose-950 dark:text-rose-100',
            headerSubtitle: 'text-rose-800/80 dark:text-rose-300/80',
            headerTag: 'bg-rose-600 dark:bg-rose-500 text-white',
            statusBadge: 'bg-rose-100 dark:bg-rose-900/60 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-700 font-bold',
            scoreBox: 'bg-rose-50/80 dark:bg-rose-950/30 border border-rose-200 dark:border-rose-800/50',
            scoreLabel: 'text-rose-800 dark:text-rose-300',
            scoreValue: 'text-rose-700 dark:text-rose-300',
            scoreSubtext: 'text-rose-700/80 dark:text-rose-300/80',
            interpBox: 'bg-rose-50/40 dark:bg-rose-950/20 border border-rose-200 dark:border-rose-800/40',
            interpLabel: 'text-rose-800 dark:text-rose-300',
            interpTitle: 'text-rose-900 dark:text-rose-100 font-bold',
            interpText: 'text-rose-900/90 dark:text-rose-200/90',
        };
    }
    return {
        level: 'neutral',
        headerBg: 'bg-gray-50/80 dark:bg-white/5 border-b border-gray-200 dark:border-white/10',
        headerTitle: 'text-gray-900 dark:text-gray-100',
        headerSubtitle: 'text-gray-600 dark:text-gray-400',
        headerTag: 'bg-gray-600 text-white',
        statusBadge: 'bg-gray-100 dark:bg-white/10 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-white/10 font-semibold',
        scoreBox: 'bg-gray-50/80 dark:bg-white/5 border border-gray-200 dark:border-white/10',
        scoreLabel: 'text-gray-700 dark:text-gray-300',
        scoreValue: 'text-gray-900 dark:text-gray-100',
        scoreSubtext: 'text-gray-600 dark:text-gray-400',
        interpBox: 'bg-gray-50/40 dark:bg-white/5 border border-gray-200 dark:border-white/10',
        interpLabel: 'text-gray-700 dark:text-gray-300',
        interpTitle: 'text-gray-900 dark:text-gray-100 font-bold',
        interpText: 'text-gray-700 dark:text-gray-300',
    };
}

function getSubscaleBoxTheme(category) {
    const level = getCategoryLevel(category);
    if (level === 'good') {
        return {
            box: 'rounded-lg border border-emerald-200 dark:border-emerald-800/50 p-3 bg-emerald-50/80 dark:bg-emerald-950/30',
            label: 'text-2xs uppercase font-semibold text-emerald-800 dark:text-emerald-300',
            value: 'mt-1 text-xl font-bold text-emerald-700 dark:text-emerald-300',
            catText: 'mt-1 text-xs font-semibold text-emerald-800 dark:text-emerald-300',
        };
    }
    if (level === 'warning') {
        return {
            box: 'rounded-lg border border-amber-200 dark:border-amber-800/50 p-3 bg-amber-50/80 dark:bg-amber-950/30',
            label: 'text-2xs uppercase font-semibold text-amber-800 dark:text-amber-300',
            value: 'mt-1 text-xl font-bold text-amber-700 dark:text-amber-300',
            catText: 'mt-1 text-xs font-semibold text-amber-800 dark:text-amber-300',
        };
    }
    if (level === 'danger') {
        return {
            box: 'rounded-lg border border-rose-200 dark:border-rose-800/50 p-3 bg-rose-50/80 dark:bg-rose-950/30',
            label: 'text-2xs uppercase font-semibold text-rose-800 dark:text-rose-300',
            value: 'mt-1 text-xl font-bold text-rose-700 dark:text-rose-300',
            catText: 'mt-1 text-xs font-semibold text-rose-800 dark:text-rose-300',
        };
    }
    return {
        box: 'rounded-lg border border-gray-200 dark:border-white/10 p-3 bg-gray-50/80 dark:bg-white/5',
        label: 'text-2xs uppercase font-semibold text-gray-700 dark:text-gray-300',
        value: 'mt-1 text-xl font-bold text-gray-900 dark:text-gray-100',
        catText: 'mt-1 text-xs font-semibold text-gray-700 dark:text-gray-300',
    };
}

function getSrqSubscaleCategory(score, max) {
    if (score === 0 || score == null) {
        return 'tidak_ada_gejala';
    }
    if (score >= Math.ceil(max / 2)) {
        return 'gejala_signifikan';
    }
    return 'gejala_ringan';
}

const srqSubscales = computed(() => {
    const srq = props.session?.srq_screening;
    if (!srq) return [];

    const answers = Array.isArray(srq.answers) ? srq.answers : [];
    const getItem = (num) => (answers[num - 1] === true || answers[num - 1] === 1 || answers[num - 1] === '1') ? 1 : 0;
    const sumList = (items) => items.reduce((acc, num) => acc + getItem(num), 0);

    const depressionScore = srq.depression_score ?? sumList([6, 9, 10, 14, 15, 16, 17]);
    const anxietyScore = srq.anxiety_score ?? sumList([3, 4, 5]);
    const somaticScore = srq.somatic_score ?? sumList([1, 2, 7, 19]);
    const cognitiveScore = srq.cognitive_score ?? sumList([8, 12, 13]);
    const energyScore = srq.energy_score ?? sumList([8, 11, 12, 13, 18, 20]);

    return [
        {
            key: 'depression',
            name: 'Gejala Depresi',
            score: depressionScore,
            max: 7,
            items: 'No. 6, 9, 10, 14, 15, 16, 17',
            category: getSrqSubscaleCategory(depressionScore, 7),
        },
        {
            key: 'anxiety',
            name: 'Gejala Cemas',
            score: anxietyScore,
            max: 3,
            items: 'No. 3, 4, 5',
            category: getSrqSubscaleCategory(anxietyScore, 3),
        },
        {
            key: 'somatic',
            name: 'Gejala Somatik',
            score: somaticScore,
            max: 4,
            items: 'No. 1, 2, 7, 19',
            category: getSrqSubscaleCategory(somaticScore, 4),
        },
        {
            key: 'cognitive',
            name: 'Gejala Kognitif',
            score: cognitiveScore,
            max: 3,
            items: 'No. 8, 12, 13',
            category: getSrqSubscaleCategory(cognitiveScore, 3),
        },
        {
            key: 'energy',
            name: 'Penurunan Energi',
            score: energyScore,
            max: 6,
            items: 'No. 8, 11, 12, 13, 18, 20',
            category: getSrqSubscaleCategory(energyScore, 6),
        },
    ];
});

const hasScreeningResults = computed(() => {
    return Boolean(
        props.session?.kpsp_screening ||
        props.session?.mchat_screening ||
        props.session?.gpph_screening ||
        props.session?.sdq_screening ||
        props.session?.srq_screening
    );
});

const availableResultTabs = computed(() => {
    const tabs = [];
    if (props.session?.kpsp_screening) {
        const k = props.session.kpsp_screening;
        const code = k.sdidtk_code ?? (k.score >= 9 ? 'Ds' : (k.score >= 7 ? 'Dm' : 'Dp'));
        tabs.push({
            code: 'KPSP',
            label: 'KPSP',
            fullName: `KPSP (${k.form_age_months} Bln)`,
            badge: code,
            category: k.category,
            badgeClass: code === 'Ds'
                ? 'bg-emerald-100 dark:bg-emerald-950/70 text-emerald-800 dark:text-emerald-200 border-emerald-300 dark:border-emerald-700'
                : code === 'Dm'
                ? 'bg-amber-100 dark:bg-amber-950/70 text-amber-800 dark:text-amber-200 border-amber-300 dark:border-amber-700'
                : 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-700',
        });
    }
    if (props.session?.mchat_screening) {
        const m = props.session.mchat_screening;
        const isLow = m.category === 'risiko_rendah';
        tabs.push({
            code: 'MCHAT',
            label: 'M-CHAT-R',
            fullName: 'M-CHAT-R (Autisme Balita)',
            badge: isLow ? 'Rendah' : 'Tinggi',
            category: m.category,
            badgeClass: isLow
                ? 'bg-emerald-100 dark:bg-emerald-950/70 text-emerald-800 dark:text-emerald-200 border-emerald-300 dark:border-emerald-700'
                : 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-700',
        });
    }
    if (props.session?.gpph_screening) {
        const g = props.session.gpph_screening;
        const isNormal = g.category === 'tidak_menunjukkan_gpph';
        tabs.push({
            code: 'GPPH',
            label: 'GPPH',
            fullName: 'GPPH / ACTRS',
            badge: isNormal ? 'Normal' : 'Positif GPPH',
            category: g.category,
            badgeClass: isNormal
                ? 'bg-emerald-100 dark:bg-emerald-950/70 text-emerald-800 dark:text-emerald-200 border-emerald-300 dark:border-emerald-700'
                : 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-700',
        });
    }
    if (props.session?.sdq_screening) {
        const s = props.session.sdq_screening;
        const cat = s.total_difficulties_category;
        tabs.push({
            code: 'SDQ',
            label: 'SDQ',
            fullName: 'SDQ (Kekuatan & Kesulitan)',
            badge: cat === 'normal' ? 'Normal' : cat === 'abnormal' ? 'Abnormal' : 'Ambang',
            category: cat,
            badgeClass: categoryBadgeClass(cat),
        });
    }
    if (props.session?.srq_screening) {
        const sq = props.session.srq_screening;
        const isBelow = sq.category === 'di_bawah_nilai_pisah';
        tabs.push({
            code: 'SRQ',
            label: 'SRQ-20',
            fullName: 'SRQ-20 (Orang Tua)',
            badge: isBelow ? 'Normal' : 'Distres',
            category: sq.category,
            badgeClass: isBelow
                ? 'bg-emerald-100 dark:bg-emerald-950/70 text-emerald-800 dark:text-emerald-200 border-emerald-300 dark:border-emerald-700'
                : 'bg-rose-100 dark:bg-rose-950/70 text-rose-800 dark:text-rose-200 border-rose-300 dark:border-rose-700',
        });
    }
    return tabs;
});

const activeResultTab = ref(availableResultTabs.value[0]?.code ?? 'all');

// Doctor Interpretation State & Form
const activeInterpretationCode = ref(null);

const interpForm = useForm({
    instrument_code: '',
    clinical_notes: '',
    follow_up_decision: '',
    follow_up_notes: '',
    status: 'completed',
});

function openInterpretationForm(code) {
    activeInterpretationCode.value = code;
    interpForm.instrument_code = code;
    if (availableResultTabs.value.some((t) => t.code === code)) {
        activeResultTab.value = code;
    }
    const existing = props.session.screening_interpretations?.find(
        (i) => i.instrument_code === code
    );
    if (existing) {
        interpForm.clinical_notes = existing.clinical_notes ?? '';
        interpForm.follow_up_decision = existing.follow_up_decision ?? '';
        interpForm.follow_up_notes = existing.follow_up_notes ?? '';
        interpForm.status = existing.status ?? 'completed';
    } else {
        if (code === 'KPSP' && props.session.kpsp_screening) {
            const kpsp = props.session.kpsp_screening;
            const isReEval = Boolean(
                kpsp.is_re_evaluation ||
                props.session.evaluation_type === 'kpsp_re_evaluation_2_weeks' ||
                props.session.parent_session_id
            );
            const codeVal = kpsp.sdidtk_code ?? (kpsp.score >= 9 ? 'Ds' : (kpsp.score >= 7 ? 'Dm' : 'Dp'));

            if (codeVal === 'Dp' || (isReEval && codeVal === 'Dm')) {
                interpForm.follow_up_decision = 'rujuk_rs';
                interpForm.clinical_notes = isReEval
                    ? `Hasil evaluasi ulang KPSP 2 minggu tetap menunjukkan hasil belum optimal (Skor: ${kpsp.score}/10, Kodifikasi: ${codeVal}). Sesuai algoritma SDIDTK Kemenkes RI, anak wajib segera dirujuk ke Rumah Sakit untuk evaluasi & penanganan dokter spesialis anak.`
                    : `Hasil skrining KPSP menunjukkan kemungkinan penyimpangan perkembangan (Skor: ${kpsp.score}/10, Kodifikasi: Dp). Direkomendasikan segera dirujuk ke Rumah Sakit untuk penanganan dokter spesialis anak.`;
                interpForm.follow_up_notes = `Buatkan surat rujukan ke Poli Tumbuh Kembang / Dokter Spesialis Anak di RS rujukan. Lampirkan lembar KPSP dan rincian domain yang belum tercapai: ${(kpsp.domain_scores?.lacking_domains || []).join(', ') || '-'}.`;
            } else if (codeVal === 'Dm') {
                interpForm.follow_up_decision = 'stimulasi_2_minggu';
                interpForm.clinical_notes = `Hasil skrining KPSP meragukan (Skor: ${kpsp.score}/10, Kodifikasi: Dm). Sektor yang belum optimal: ${(kpsp.domain_scores?.lacking_domains || []).join(', ') || '-'}.`;
                interpForm.follow_up_notes = `Edukasi orang tua/pengasuh untuk melakukan intervensi stimulasi intensif selama 2 minggu di rumah terfokus pada domain yang kurang. Jadwalkan evaluasi ulang KPSP 14 hari kemudian.`;
            } else {
                interpForm.follow_up_decision = 'stimulasi_rutin';
                interpForm.clinical_notes = isReEval
                    ? `Evaluasi ulang KPSP berhasil: perkembangan anak meningkat sesuai umur (Skor: ${kpsp.score}/10, Kodifikasi: Ds). Seluruh indikator tugas perkembangan berhasil dicapai.`
                    : `Perkembangan anak sesuai dengan tahapan umur (Skor: ${kpsp.score}/10, Kodifikasi: Ds). Seluruh tugas perkembangan tercapai dengan baik.`;
                interpForm.follow_up_notes = `Beri pujian kepada orang tua atas pengasuhan dan stimulasinya. Anjurkan meneruskan stimulasi rutin sesuai panduan Buku KIA dan jadwalkan skrining rutin pada kelompok umur berikutnya.`;
            }
        } else {
            interpForm.clinical_notes = '';
            interpForm.follow_up_decision = '';
            interpForm.follow_up_notes = '';
        }
        interpForm.status = 'completed';
    }
}

const schedulingReEval = ref(false);
function scheduleKpspReEvaluation() {
    if (confirm('Jadwalkan sesi evaluasi ulang KPSP 14 hari ke depan untuk pasien ini?')) {
        schedulingReEval.value = true;
        router.post(`/screening-sessions/${props.session.id}/schedule-kpsp-re-evaluation`, {}, {
            onFinish: () => {
                schedulingReEval.value = false;
            },
        });
    }
}

function submitInterpretation() {
    interpForm.post(`/screening-sessions/${props.session.id}/interpretations`, {
        onSuccess: () => {
            activeInterpretationCode.value = null;
        },
    });
}

// Finalize Form
const finalizeForm = useForm({
    doctor_notes: props.session.doctor_notes ?? '',
});

function submitFinalize() {
    if (confirm('Apakah Anda yakin ingin menyelesaikan dan memfinalisasi tinjauan sesi skrining ini?')) {
        finalizeForm.post(`/screening-sessions/${props.session.id}/finalize`);
    }
}

function printReport() {
    window.print();
}
</script>

<template>
    <Head :title="`Sesi Skrining - ${session.patient?.name ?? 'Detail'}`" />

    <AuthenticatedLayout>
        <template #header>
            <div class="flex flex-wrap items-center justify-between gap-4 print:hidden">
                <div>
                    <h2 class="text-xl font-bold text-gray-900">
                        Detail & Hasil Sesi Skrining
                    </h2>
                    <p class="mt-1 text-sm text-gray-500">
                        Hasil evaluasi instrumen, sintesis SPK, stimulasi perkembangan, dan tinjauan dokter.
                    </p>
                </div>
                <div class="flex items-center gap-3">
                    <button
                        type="button"
                        @click="printReport"
                        class="inline-flex items-center gap-2 rounded-lg border border-gray-300 bg-white px-3.5 py-2 text-sm font-semibold text-gray-700 shadow-sm hover:bg-gray-50 transition"
                    >
                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4H9v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                        </svg>
                        Cetak Laporan
                    </button>

                    <!-- Doctor Delete Button -->
                    <button
                        v-if="isDoctor"
                        type="button"
                        @click="showDeleteConfirm = true"
                        class="inline-flex items-center gap-1.5 rounded-xl border border-rose-200 bg-rose-50 px-3 py-2 text-sm font-bold text-rose-700 shadow-2xs hover:bg-rose-100 transition"
                        title="Hapus Sesi Skrining"
                    >
                        <svg class="w-4 h-4 text-rose-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                        Hapus Sesi
                    </button>

                    <span
                        class="rounded-full px-3 py-1.5 text-xs font-bold border"
                        :class="sessionStatusClasses[session.status] ?? 'bg-sand/30 text-navy'"
                    >
                        {{ sessionStatusLabels[session.status] ?? session.status }}
                    </span>
                </div>
            </div>
        </template>

        <div class="space-y-6">
            <!-- Navigation back -->
            <div class="print:hidden flex items-center gap-2 text-xs font-bold text-teal">
                <Link
                    v-if="session.patient?.id"
                    :href="`/screening-sessions?patient_id=${session.patient.id}`"
                    class="inline-flex items-center gap-1 hover:text-navy transition"
                >
                    &larr; Kembali ke Daftar Sesi Pasien
                </Link>
                <span v-if="session.patient?.id" class="text-sand/60">|</span>
                <Link
                    href="/dashboard"
                    class="inline-flex items-center gap-1 text-gray-500 hover:text-navy transition"
                >
                    Patient Directory (Dashboard)
                </Link>
            </div>

            <!-- Print Header Banner (only visible on print) -->
            <div class="hidden print:block border-b-2 border-gray-900 pb-4 mb-6 text-center">
                <h1 class="text-xl font-bold uppercase tracking-wide text-gray-900">
                    Sistem Pendukung Keputusan Skrining Tumbuh Kembang Anak
                </h1>
                <p class="text-xs text-gray-600 mt-1">
                    Laporan Hasil Skrining, Sintesis Rekomendasi Klinis & Rencana Tindak Lanjut
                </p>
            </div>

            <!-- Patient and Session Overview Card -->
            <section class="overflow-hidden rounded-2xl bg-white dark:bg-[#0C2038] shadow-xs border border-sand/40 dark:border-white/10">
                <!-- Re-evaluation Relationship Quick Link -->
                <div
                    v-if="session.parent_session_id"
                    class="border-b border-sand/30 dark:border-white/10 bg-amber-50/70 dark:bg-amber-950/30 px-6 py-2 flex items-center justify-between text-xs"
                >
                    <span class="text-amber-900 dark:text-amber-200 font-bold">
                        🔄 Sesi Evaluasi Ulang (dari Sesi #{{ session.parent_session_id }})
                    </span>
                    <Link
                        :href="`/screening-sessions/${session.parent_session_id}`"
                        class="text-2xs font-bold text-amber-800 dark:text-amber-300 hover:underline"
                    >
                        Lihat Sesi Awal &rarr;
                    </Link>
                </div>
                <div
                    v-else-if="session.re_evaluations?.length"
                    class="border-b border-sand/30 dark:border-white/10 bg-indigo-50/70 dark:bg-indigo-950/30 px-6 py-2 flex items-center justify-between text-xs"
                >
                    <span class="text-indigo-900 dark:text-indigo-200 font-bold">
                        📅 Terjadwal Evaluasi Ulang: Sesi #{{ session.re_evaluations[0].id }} ({{ formatDate(session.re_evaluations[0].screening_date) }})
                    </span>
                    <Link
                        :href="`/screening-sessions/${session.re_evaluations[0].id}`"
                        class="text-2xs font-bold text-indigo-800 dark:text-indigo-300 hover:underline"
                    >
                        Buka Sesi Evaluasi &rarr;
                    </Link>
                </div>

                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-sand/30 dark:border-white/10 bg-[#FAF7F0] dark:bg-[#071D37] px-6 py-4">
                    <h3 class="text-base font-bold text-navy dark:text-gray-100 flex items-center gap-2">
                        <svg class="w-5 h-5 text-teal" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7 7z" />
                        </svg>
                        Identitas Anak & Informasi Pemeriksaan
                    </h3>
                    <span class="text-xs text-gray-500 dark:text-gray-400 font-mono">
                        ID Sesi: #{{ session.id }}
                    </span>
                </div>

                <div class="grid grid-cols-2 gap-5 p-6 sm:grid-cols-4 text-sm">
                    <div>
                        <span class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400 block">Nama Anak</span>
                        <span class="font-black text-navy dark:text-white text-base">{{ session.patient?.name ?? '-' }}</span>
                    </div>

                    <div>
                        <span class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400 block">No. Rekam Medis</span>
                        <span class="font-bold text-teal dark:text-teal-300">{{ session.patient?.medical_record_number ?? '-' }}</span>
                    </div>

                    <div>
                        <span class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400 block">Tanggal Lahir & Usia</span>
                        <span class="font-semibold text-gray-900 dark:text-gray-200">
                            {{ formatDate(session.patient?.birth_date) }} ({{ session.age_months }} Bulan)
                        </span>
                    </div>

                    <div>
                        <span class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400 block">Jenis Kelamin</span>
                        <span class="font-semibold text-gray-900 dark:text-gray-200">
                            {{ session.patient?.gender === 'L' ? 'Laki-laki' : session.patient?.gender === 'P' ? 'Perempuan' : '-' }}
                        </span>
                    </div>

                    <div>
                        <span class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400 block">Tanggal Pemeriksaan</span>
                        <span class="font-semibold text-gray-900 dark:text-gray-200">{{ formatDate(session.screening_date) }}</span>
                    </div>

                    <div>
                        <span class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400 block">Perawat Pelaksana</span>
                        <span class="font-semibold text-navy dark:text-gray-200">{{ session.nurse?.user?.name ?? '-' }}</span>
                    </div>

                    <div>
                        <span class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400 block">Dokter Peninjau</span>
                        <span class="font-semibold text-navy dark:text-gray-200">
                            {{ session.doctor?.user?.name ?? 'Belum ditugaskan' }}
                        </span>
                    </div>

                    <div>
                        <span class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400 block">Status Prematuritas</span>
                        <span class="font-semibold text-gray-900 dark:text-gray-200">
                            {{ session.patient?.is_premature ? `Prematur (${session.patient?.gestational_age_weeks} mg)` : 'Cukup Bulan' }}
                        </span>
                    </div>
                </div>

                <div v-if="session.notes" class="border-t border-sand/30 dark:border-white/10 bg-[#FAF7F0] dark:bg-[#071D37] px-6 py-3 text-xs text-gray-700 dark:text-gray-300">
                    <span class="font-bold text-navy dark:text-gray-100">Catatan Pra-Skrining:</span> {{ session.notes }}
                </div>
            </section>

            <!-- Instruments Workflow & Action Cards -->
            <section class="overflow-hidden rounded-2xl bg-white dark:bg-[#0C2038] shadow-xs border border-sand/40 dark:border-white/10">
                <div class="border-b border-sand/30 dark:border-white/10 bg-[#FAF7F0] dark:bg-[#071D37] px-6 py-4 flex items-center justify-between">
                    <div>
                        <h3 class="text-base font-bold text-navy dark:text-gray-100">
                            Daftar Paket Instrumen Skrining
                        </h3>
                        <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
                            Status pengerjaan dan tombol akses kuesioner bagi tenaga perawat.
                        </p>
                    </div>
                    <span class="text-xs font-bold text-teal dark:text-teal-300">
                        {{ session.screening_session_instruments?.length ?? 0 }} Instrumen
                    </span>
                </div>

                <div class="divide-y divide-gray-100 dark:divide-white/10">
                    <div
                        v-for="inst in session.screening_session_instruments"
                        :key="inst.id"
                        class="flex flex-wrap items-center justify-between gap-4 px-6 py-4 hover:bg-[#FAF6EE] dark:hover:bg-white/5 transition"
                    >
                        <div class="flex items-center gap-3">
                            <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-teal/10 dark:bg-teal-950/50 text-teal dark:text-teal-300 font-extrabold text-xs border border-teal/20 dark:border-teal-700/50">
                                {{ inst.instrument_code }}
                            </span>
                            <div>
                                <p class="text-sm font-bold text-navy">
                                    {{ instrumentLabels[inst.instrument_code] ?? inst.instrument_code }}
                                </p>
                                <p class="text-xs text-gray-500">
                                    Status:
                                    <span class="font-semibold" :class="inst.status === 'completed' ? 'text-forest dark:text-emerald-400' : 'text-gray-600 dark:text-gray-300'">
                                        {{ instrumentStatusLabels[inst.status] ?? inst.status }}
                                    </span>
                                </p>
                            </div>
                        </div>

                        <div class="flex items-center gap-3">
                            <span
                                class="rounded-full px-3 py-1 text-xs font-semibold border"
                                :class="instrumentStatusClasses[inst.status] ?? 'bg-gray-100 text-gray-700'"
                            >
                                {{ instrumentStatusLabels[inst.status] ?? inst.status }}
                            </span>

                            <!-- Actions for Perawat -->
                            <div
                                v-if="page.props.auth?.user?.role === 'perawat' && !['reviewed', 'cancelled'].includes(session.status)"
                                class="print:hidden"
                            >
                                <Link
                                    v-if="inst.instrument_code === 'KPSP'"
                                    :href="`/screening-sessions/${session.id}/kpsp`"
                                    class="rounded-xl px-3.5 py-1.5 text-xs font-bold transition shadow-xs"
                                    :class="inst.status === 'completed'
                                        ? 'bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-300'
                                        : 'bg-blue-600 hover:bg-blue-700 text-white'"
                                >
                                    {{ inst.status === 'completed' ? 'Lihat / Edit KPSP' : 'Isi KPSP' }}
                                </Link>

                                <Link
                                    v-else-if="inst.instrument_code === 'MCHAT'"
                                    :href="`/screening-sessions/${session.id}/mchat`"
                                    class="rounded-xl px-3.5 py-1.5 text-xs font-bold transition shadow-xs"
                                    :class="inst.status === 'completed'
                                        ? 'bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-300'
                                        : 'bg-blue-600 hover:bg-blue-700 text-white'"
                                >
                                    {{ inst.status === 'completed' ? 'Lihat / Edit M-CHAT' : 'Isi M-CHAT-R' }}
                                </Link>

                                <Link
                                    v-else-if="inst.instrument_code === 'GPPH'"
                                    :href="`/screening-sessions/${session.id}/gpph`"
                                    class="rounded-xl px-3.5 py-1.5 text-xs font-bold transition shadow-xs"
                                    :class="inst.status === 'completed'
                                        ? 'bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-300'
                                        : 'bg-blue-600 hover:bg-blue-700 text-white'"
                                >
                                    {{ inst.status === 'completed' ? 'Lihat / Edit GPPH' : 'Isi GPPH' }}
                                </Link>

                                <Link
                                    v-else-if="inst.instrument_code === 'SDQ'"
                                    :href="`/screening-sessions/${session.id}/sdq`"
                                    class="rounded-xl px-3.5 py-1.5 text-xs font-bold transition shadow-xs"
                                    :class="inst.status === 'completed'
                                        ? 'bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-300'
                                        : 'bg-blue-600 hover:bg-blue-700 text-white'"
                                >
                                    {{ inst.status === 'completed' ? 'Lihat / Edit SDQ' : 'Isi SDQ' }}
                                </Link>

                                <Link
                                    v-else-if="inst.instrument_code === 'SRQ'"
                                    :href="`/screening-sessions/${session.id}/srq`"
                                    class="rounded-xl px-3.5 py-1.5 text-xs font-bold transition shadow-xs"
                                    :class="inst.status === 'completed'
                                        ? 'bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-300'
                                        : 'bg-blue-600 hover:bg-blue-700 text-white'"
                                >
                                    {{ inst.status === 'completed' ? 'Lihat / Edit SRQ-20' : 'Isi SRQ-20' }}
                                </Link>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- SKOR & HASIL INSTRUMEN SKRINING (PAGE BREAK BEFORE IN PRINT) -->
            <div
                v-if="hasScreeningResults"
                class="space-y-6 print:break-before-page print-break-before"
            >
                <!-- TAB NAVIGASI HASIL KUESIONER (Screen View Only) -->
                <div class="print:hidden rounded-2xl bg-white dark:bg-[#0C2038] p-4 shadow-xs border border-sand/40 dark:border-white/10 space-y-3">
                    <div class="flex flex-wrap items-center justify-between gap-3">
                        <div class="flex items-center gap-2">
                            <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-teal/10 dark:bg-teal-950/50 text-teal dark:text-teal-300 font-black text-xs">
                                📊
                            </span>
                            <div>
                                <h3 class="text-sm font-black text-navy dark:text-gray-100">
                                    Hasil Pemeriksaan Instrumen Skrining
                                </h3>
                                <p class="text-2xs text-gray-500 dark:text-gray-400">
                                    Pilih tab instrumen di bawah untuk melihat rincian evaluasi masing-masing kuesioner.
                                </p>
                            </div>
                        </div>

                        <!-- Pill Count -->
                        <span class="text-2xs font-extrabold text-teal dark:text-teal-300">
                            {{ availableResultTabs.length }} Instrumen Terisi
                        </span>
                    </div>

                    <!-- TAB BUTTONS -->
                    <div class="flex flex-wrap items-center gap-2 pt-2 border-t border-sand/30 dark:border-white/10">
                        <button
                            v-for="tab in availableResultTabs"
                            :key="tab.code"
                            type="button"
                            @click="activeResultTab = tab.code"
                            class="inline-flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-bold transition shadow-2xs border"
                            :class="activeResultTab === tab.code
                                ? 'bg-navy dark:bg-teal text-white border-navy dark:border-teal ring-2 ring-navy/20 dark:ring-teal/30'
                                : 'bg-slate-50 dark:bg-white/5 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-white/10 hover:bg-white dark:hover:bg-white/10'"
                        >
                            <span>{{ tab.label }}</span>
                            <span
                                v-if="tab.badge"
                                class="rounded-full px-2 py-0.5 text-3xs font-black uppercase border"
                                :class="activeResultTab === tab.code
                                    ? 'bg-white/20 text-white border-white/30'
                                    : tab.badgeClass"
                            >
                                {{ tab.badge }}
                            </span>
                        </button>

                        <button
                            v-if="availableResultTabs.length > 1"
                            type="button"
                            @click="activeResultTab = 'all'"
                            class="inline-flex items-center gap-1.5 rounded-xl px-3.5 py-2 text-xs font-bold transition border"
                            :class="activeResultTab === 'all'
                                ? 'bg-navy dark:bg-teal text-white border-navy dark:border-teal ring-2 ring-navy/20 dark:ring-teal/30'
                                : 'bg-slate-50 dark:bg-white/5 text-gray-600 dark:text-gray-400 border-gray-200 dark:border-white/10 hover:bg-white dark:hover:bg-white/10'"
                        >
                            <span>Semua Instrumen</span>
                            <span
                                class="rounded-full px-1.5 py-0.2 text-3xs font-extrabold"
                                :class="activeResultTab === 'all' ? 'bg-white/20 text-white' : 'bg-gray-200 dark:bg-white/15 text-gray-700 dark:text-gray-300'"
                            >
                                {{ availableResultTabs.length }}
                            </span>
                        </button>
                    </div>
                </div>

                <!-- KPSP RESULTS CARD -->
                <section
                    v-if="session.kpsp_screening"
                    :class="[
                        activeResultTab === 'KPSP' || activeResultTab === 'all' ? 'block' : 'hidden print:block',
                        'overflow-hidden rounded-xl bg-white dark:bg-[#0C2038] shadow-sm border border-gray-200 dark:border-white/10 print:break-inside-avoid print-show-all'
                    ]"
                >
                <div
                    class="px-6 py-4 flex flex-wrap items-center justify-between gap-3 transition-colors"
                    :class="getInstrumentTheme(session.kpsp_screening.category).headerBg"
                >
                    <div>
                        <div class="flex items-center gap-2 flex-wrap">
                            <span
                                class="rounded px-2 py-0.5 text-xs font-bold uppercase transition-colors"
                                :class="getInstrumentTheme(session.kpsp_screening.category).headerTag"
                            >
                                KPSP
                            </span>
                            <h3
                                class="text-base font-bold transition-colors"
                                :class="getInstrumentTheme(session.kpsp_screening.category).headerTitle"
                            >
                                Hasil Kuesioner Pra Skrining Perkembangan (Form {{ session.kpsp_screening.form_age_months }} Bulan)
                            </h3>
                            <!-- Kodifikasi SDIDTK Tag -->
                            <span
                                v-if="session.kpsp_screening.sdidtk_code"
                                class="rounded-full px-2.5 py-0.5 text-xs font-black border"
                                :class="sdidtkCodeDetails[session.kpsp_screening.sdidtk_code]?.badge ?? 'bg-white text-gray-800 border-gray-300'"
                            >
                                SDIDTK: {{ session.kpsp_screening.sdidtk_code }}
                            </span>
                            <!-- Re-evaluation Tag -->
                            <span
                                v-if="session.kpsp_screening.is_re_evaluation || session.evaluation_type === 'kpsp_re_evaluation_2_weeks' || session.parent_session_id"
                                class="rounded-full bg-amber-100 dark:bg-amber-900/60 border border-amber-300 dark:border-amber-700 px-2.5 py-0.5 text-2xs font-black text-amber-800 dark:text-amber-200"
                            >
                                🔄 Re-evaluasi 2 Minggu
                            </span>
                        </div>
                        <p
                            class="text-xs mt-1 transition-colors"
                            :class="getInstrumentTheme(session.kpsp_screening.category).headerSubtitle"
                        >
                            Berdasarkan 10 butir tugas perkembangan Kementerian Kesehatan RI.
                        </p>
                    </div>

                    <span
                        class="rounded-full px-3.5 py-1 text-xs font-bold border transition-colors"
                        :class="categoryBadgeClass(session.kpsp_screening.category)"
                    >
                        {{ categoryLabel(session.kpsp_screening.category) }}
                    </span>
                </div>

                <div class="p-6 space-y-6">
                    <!-- Tindakan Klinis SDIDTK (Hanya tampil jika ada tindak lanjut spesifik) -->
                    <!-- Re-evaluasi Belum Optimal (Dm/Dp) -->
                    <div
                        v-if="(session.kpsp_screening.is_re_evaluation || session.parent_session_id) && ['Dm', 'Dp'].includes(session.kpsp_screening.sdidtk_code)"
                        class="rounded-xl border border-rose-300 dark:border-rose-800 bg-rose-50 dark:bg-rose-950/40 px-4 py-2.5 flex items-center justify-between gap-3 text-xs"
                    >
                        <span class="font-bold text-rose-900 dark:text-rose-200 flex items-center gap-2">
                            <span>🚨</span>
                            <span>Re-evaluasi Belum Optimal: Segera rujuk ke Rumah Sakit (Poli Tumbuh Kembang / Sp.A).</span>
                        </span>
                    </div>

                    <!-- Sesi Awal Meragukan (Dm) -->
                    <div
                        v-else-if="session.kpsp_screening.sdidtk_code === 'Dm'"
                        class="rounded-xl border border-amber-300 dark:border-amber-700 bg-amber-50 dark:bg-amber-950/40 px-4 py-2.5 flex flex-wrap items-center justify-between gap-3 text-xs"
                    >
                        <span class="font-bold text-amber-900 dark:text-amber-200 flex items-center gap-2">
                            <span>⚠️</span>
                            <span>Hasil Meragukan (Dm): Berikan stimulasi 2 minggu di rumah.</span>
                        </span>

                        <template v-if="session.re_evaluations?.length">
                            <Link
                                :href="`/screening-sessions/${session.re_evaluations[0].id}`"
                                class="font-bold text-indigo-700 dark:text-indigo-300 hover:underline text-2xs"
                            >
                                Buka Sesi Evaluasi Ulang #{{ session.re_evaluations[0].id }} &rarr;
                            </Link>
                        </template>
                        <template v-else-if="page.props.auth?.user?.role === 'perawat' || page.props.auth?.user?.role === 'dokter'">
                            <button
                                type="button"
                                @click="scheduleKpspReEvaluation"
                                :disabled="schedulingReEval"
                                class="rounded-lg bg-amber-600 hover:bg-amber-700 text-white font-bold text-2xs px-3 py-1 shadow-2xs transition disabled:opacity-50"
                            >
                                {{ schedulingReEval ? 'Menjadwalkan...' : 'Jadwalkan Evaluasi Ulang (14 Hari)' }}
                            </button>
                        </template>
                    </div>

                    <!-- Sesi Awal Penyimpangan (Dp) -->
                    <div
                        v-else-if="session.kpsp_screening.sdidtk_code === 'Dp'"
                        class="rounded-xl border border-rose-300 dark:border-rose-800 bg-rose-50 dark:bg-rose-950/40 px-4 py-2 flex items-center gap-2 text-xs font-bold text-rose-900 dark:text-rose-200"
                    >
                        <span>🚨</span>
                        <span>Kemungkinan Penyimpangan (Dp): Segera rujuk ke Rumah Sakit.</span>
                    </div>

                    <!-- Re-evaluasi Berhasil (Ds) -->
                    <div
                        v-else-if="(session.kpsp_screening.is_re_evaluation || session.parent_session_id) && session.kpsp_screening.sdidtk_code === 'Ds'"
                        class="rounded-xl border border-emerald-300 dark:border-emerald-700 bg-emerald-50 dark:bg-emerald-950/30 px-4 py-2 flex items-center gap-2 text-xs font-bold text-emerald-900 dark:text-emerald-200"
                    >
                        <span>✓</span>
                        <span>Evaluasi ulang berhasil: Perkembangan normal sesuai umur (Ds). Teruskan stimulasi Buku KIA.</span>
                    </div>

                    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                        <div
                            class="rounded-xl p-4 transition-colors"
                            :class="getInstrumentTheme(session.kpsp_screening.category).scoreBox"
                        >
                            <span
                                class="text-xs uppercase font-semibold block"
                                :class="getInstrumentTheme(session.kpsp_screening.category).scoreLabel"
                            >
                                Skor Jawaban "Ya"
                            </span>
                            <p
                                class="mt-2 text-3xl font-extrabold"
                                :class="getInstrumentTheme(session.kpsp_screening.category).scoreValue"
                            >
                                {{ session.kpsp_screening.score }} <span class="text-base font-normal opacity-70">/ 10</span>
                            </p>
                            <p
                                class="text-xs mt-1"
                                :class="getInstrumentTheme(session.kpsp_screening.category).scoreSubtext"
                            >
                                Tugas yang dapat dilakukan anak
                            </p>

                            <!-- SDIDTK Kodifikasi Badge in Score Box -->
                            <div class="flex items-center gap-2 mt-3 pt-2.5 border-t border-sand/30 dark:border-white/10">
                                <span class="text-3xs font-extrabold text-gray-500 uppercase">Kodifikasi:</span>
                                <span
                                    class="rounded px-2 py-0.5 text-xs font-black uppercase"
                                    :class="session.kpsp_screening.sdidtk_code === 'Ds'
                                        ? 'bg-emerald-200 dark:bg-emerald-900 text-emerald-950 dark:text-emerald-100'
                                        : session.kpsp_screening.sdidtk_code === 'Dm'
                                        ? 'bg-amber-200 dark:bg-amber-900 text-amber-950 dark:text-amber-100'
                                        : 'bg-rose-200 dark:bg-rose-900 text-rose-950 dark:text-rose-100'"
                                >
                                    {{ session.kpsp_screening.sdidtk_code ?? (session.kpsp_screening.score >= 9 ? 'Ds' : (session.kpsp_screening.score >= 7 ? 'Dm' : 'Dp')) }}
                                </span>
                                <span class="text-3xs text-gray-500 font-medium">
                                    {{ (session.kpsp_screening.sdidtk_code ?? (session.kpsp_screening.score >= 9 ? 'Ds' : (session.kpsp_screening.score >= 7 ? 'Dm' : 'Dp'))) === 'Ds' ? 'Normal' : (session.kpsp_screening.sdidtk_code ?? (session.kpsp_screening.score >= 9 ? 'Ds' : (session.kpsp_screening.score >= 7 ? 'Dm' : 'Dp'))) === 'Dm' ? 'Meragukan' : 'Penyimpangan' }}
                                </span>
                            </div>
                        </div>

                        <div
                            class="rounded-xl p-4 sm:col-span-2 transition-colors"
                            :class="getInstrumentTheme(session.kpsp_screening.category).interpBox"
                        >
                            <span
                                class="text-xs uppercase font-semibold block"
                                :class="getInstrumentTheme(session.kpsp_screening.category).interpLabel"
                            >
                                Interpretasi Hasil Skrining
                            </span>
                            <p
                                class="mt-1 text-base font-bold"
                                :class="getInstrumentTheme(session.kpsp_screening.category).interpTitle"
                            >
                                {{ categoryLabel(session.kpsp_screening.category) }}
                            </p>
                            <p
                                class="text-xs leading-relaxed mt-1"
                                :class="getInstrumentTheme(session.kpsp_screening.category).interpText"
                            >
                                {{ session.kpsp_screening.recommendation }}
                            </p>
                        </div>
                    </div>

                    <!-- KPSP DOMAIN BREAKDOWN (Evaluasi 4 Sektor Perkembangan) -->
                    <div
                        v-if="session.kpsp_screening.domain_scores?.domains"
                        class="pt-5 border-t border-sand/40 dark:border-white/10 space-y-4"
                    >
                        <div class="flex flex-wrap items-center justify-between gap-2">
                            <h4 class="text-xs font-extrabold uppercase tracking-wider text-navy dark:text-sand flex items-center gap-1.5">
                                <span>🎯</span> Profil 4 Domain Perkembangan
                            </h4>

                            <!-- Lacking Domains Pill Indicator -->
                            <div v-if="!session.kpsp_screening.domain_scores.all_optimal && session.kpsp_screening.domain_scores.lacking_domains?.length">
                                <span class="inline-flex items-center gap-1 rounded-full bg-rose-100 dark:bg-rose-950/70 border border-rose-300 dark:border-rose-800 px-3 py-1 text-2xs font-extrabold text-rose-800 dark:text-rose-200">
                                    <span>⚠️ Belum Optimal:</span>
                                    <span>{{ session.kpsp_screening.domain_scores.lacking_domains.join(', ') }}</span>
                                </span>
                            </div>
                            <div v-else-if="session.kpsp_screening.domain_scores.all_optimal">
                                <span class="inline-flex items-center gap-1 rounded-full bg-emerald-100 dark:bg-emerald-950/70 border border-emerald-300 dark:border-emerald-800 px-3 py-1 text-2xs font-extrabold text-emerald-800 dark:text-emerald-200">
                                    <span>✓ Seluruh Domain Optimal</span>
                                </span>
                            </div>
                        </div>

                        <!-- 4 DOMAIN CARDS GRID -->
                        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                            <div
                                v-for="(domain, dKey) in session.kpsp_screening.domain_scores.domains"
                                :key="dKey"
                                class="rounded-xl border p-3.5 space-y-2 transition shadow-2xs"
                                :class="domain.status === 'sesuai'
                                    ? 'bg-emerald-50/50 dark:bg-emerald-950/30 border-emerald-200 dark:border-emerald-800/60'
                                    : 'bg-rose-50/60 dark:bg-rose-950/40 border-rose-300 dark:border-rose-800'"
                            >
                                <div class="flex items-center justify-between">
                                    <span class="text-xs font-bold text-navy dark:text-white flex items-center gap-1.5">
                                        <span v-if="domain.key === 'gerak_kasar'">🏃</span>
                                        <span v-else-if="domain.key === 'gerak_halus'">✍️</span>
                                        <span v-else-if="domain.key === 'bicara_bahasa'">🗣️</span>
                                        <span v-else>🤝</span>
                                        {{ domain.name }}
                                    </span>
                                    <span
                                        class="rounded px-1.5 py-0.5 text-3xs font-extrabold uppercase border"
                                        :class="domain.status === 'sesuai'
                                            ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-900/60 dark:text-emerald-200 border-emerald-300'
                                            : 'bg-rose-100 text-rose-800 dark:bg-rose-900/60 dark:text-rose-200 border-rose-300'"
                                    >
                                        {{ domain.status === 'sesuai' ? 'Optimal' : 'Perlu Stimulasi' }}
                                    </span>
                                </div>

                                <div class="flex items-baseline justify-between">
                                    <span
                                        class="text-2xl font-black"
                                        :class="domain.status === 'sesuai' ? 'text-emerald-700 dark:text-emerald-300' : 'text-rose-600 dark:text-rose-400'"
                                    >
                                        {{ domain.score }} <span class="text-xs text-gray-500 font-normal">/ {{ domain.total }}</span>
                                    </span>
                                    <span class="text-xs font-bold" :class="domain.status === 'sesuai' ? 'text-emerald-700 dark:text-emerald-300' : 'text-rose-600 dark:text-rose-400'">
                                        {{ domain.percentage }}%
                                    </span>
                                </div>

                                <!-- Progress Bar -->
                                <div class="w-full bg-gray-200 dark:bg-white/10 rounded-full h-1.5 overflow-hidden">
                                    <div
                                        class="h-1.5 rounded-full transition-all duration-500"
                                        :class="domain.status === 'sesuai' ? 'bg-emerald-500' : 'bg-rose-500'"
                                        :style="{ width: `${domain.percentage}%` }"
                                    />
                                </div>

                                <p class="text-3xs text-gray-500 dark:text-gray-400">
                                    <template v-if="domain.status === 'sesuai'">
                                        ✓ Semua {{ domain.total }} tugas tercapai
                                    </template>
                                    <template v-else>
                                        ⚠️ {{ domain.missed_questions?.length ?? (domain.total - domain.score) }} belum tercapai
                                    </template>
                                </p>
                            </div>
                        </div>

                        <!-- Butir yang belum tercapai -->
                        <div
                            v-if="!session.kpsp_screening.domain_scores.all_optimal"
                            class="rounded-xl border border-rose-200 dark:border-rose-900/60 bg-rose-50/30 dark:bg-rose-950/20 p-3.5 space-y-2.5"
                        >
                            <h5 class="text-xs font-bold text-rose-900 dark:text-rose-200 flex items-center gap-1.5">
                                <span>📌</span> Butir Belum Tercapai (Jawaban "Tidak"):
                            </h5>

                            <div class="space-y-2">
                                <template v-for="(domain, dKey) in session.kpsp_screening.domain_scores.domains" :key="dKey">
                                    <div
                                        v-if="domain.missed_questions?.length"
                                        class="space-y-1"
                                    >
                                        <div class="text-2xs font-extrabold text-navy dark:text-sand uppercase tracking-wider flex items-center gap-1.5">
                                            <span class="inline-block w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                                            <span>{{ domain.name }} ({{ domain.missed_questions.length }} butir):</span>
                                        </div>

                                        <div class="grid grid-cols-1 gap-1.5 pl-3">
                                            <div
                                                v-for="q in domain.missed_questions"
                                                :key="q.number"
                                                class="rounded-lg bg-white dark:bg-[#071D37] border border-rose-200 dark:border-rose-900/40 p-2 text-xs text-gray-800 dark:text-gray-200 shadow-2xs flex items-start gap-2"
                                            >
                                                <span class="shrink-0 rounded bg-rose-100 dark:bg-rose-950/80 text-rose-800 dark:text-rose-300 font-bold text-3xs px-1.5 py-0.5 border border-rose-300">
                                                    #{{ q.number }}
                                                </span>
                                                <p class="leading-relaxed text-2xs text-gray-700 dark:text-gray-300">
                                                    {{ q.text }}
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </template>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- M-CHAT-R RESULTS CARD -->
            <section
                v-if="session.mchat_screening"
                :class="[
                    activeResultTab === 'MCHAT' || activeResultTab === 'all' ? 'block' : 'hidden print:block',
                    'overflow-hidden rounded-xl bg-white dark:bg-[#0C2038] shadow-sm border border-gray-200 dark:border-white/10 print:break-inside-avoid print-show-all'
                ]"
            >
                <div
                    class="px-6 py-4 flex flex-wrap items-center justify-between gap-3 transition-colors"
                    :class="getInstrumentTheme(session.mchat_screening.category).headerBg"
                >
                    <div>
                        <div class="flex items-center gap-2">
                            <span
                                class="rounded px-2 py-0.5 text-xs font-bold uppercase transition-colors"
                                :class="getInstrumentTheme(session.mchat_screening.category).headerTag"
                            >
                                M-CHAT-R
                            </span>
                            <h3
                                class="text-base font-bold transition-colors"
                                :class="getInstrumentTheme(session.mchat_screening.category).headerTitle"
                            >
                                Hasil Skrining Risiko Autisme Balita (M-CHAT-R)
                            </h3>
                        </div>
                        <p
                            class="text-xs mt-1 transition-colors"
                            :class="getInstrumentTheme(session.mchat_screening.category).headerSubtitle"
                        >
                            Deteksi dini Gangguan Spektrum Autisme usia 16–30 bulan.
                        </p>
                    </div>

                    <span
                        class="rounded-full px-3.5 py-1 text-xs font-bold border transition-colors"
                        :class="categoryBadgeClass(session.mchat_screening.category)"
                    >
                        {{ categoryLabel(session.mchat_screening.category) }}
                    </span>
                </div>

                <div class="p-6">
                    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                        <div
                            class="rounded-xl p-4 transition-colors"
                            :class="getInstrumentTheme(session.mchat_screening.category).scoreBox"
                        >
                            <span
                                class="text-xs uppercase font-semibold block"
                                :class="getInstrumentTheme(session.mchat_screening.category).scoreLabel"
                            >
                                Skor Risiko Autisme
                            </span>
                            <p
                                class="mt-2 text-3xl font-extrabold"
                                :class="getInstrumentTheme(session.mchat_screening.category).scoreValue"
                            >
                                {{ session.mchat_screening.score }} <span class="text-base font-normal opacity-70">/ 20</span>
                            </p>
                            <p
                                class="text-xs mt-1"
                                :class="getInstrumentTheme(session.mchat_screening.category).scoreSubtext"
                            >
                                Jumlah butir risiko teridentifikasi
                            </p>
                        </div>

                        <div
                            class="rounded-xl p-4 sm:col-span-2 transition-colors"
                            :class="getInstrumentTheme(session.mchat_screening.category).interpBox"
                        >
                            <span
                                class="text-xs uppercase font-semibold block"
                                :class="getInstrumentTheme(session.mchat_screening.category).interpLabel"
                            >
                                Tindak Lanjut M-CHAT-R
                            </span>
                            <p
                                class="mt-1 text-base font-bold"
                                :class="getInstrumentTheme(session.mchat_screening.category).interpTitle"
                            >
                                {{ categoryLabel(session.mchat_screening.category) }}
                            </p>
                            <p
                                class="text-xs leading-relaxed mt-1"
                                :class="getInstrumentTheme(session.mchat_screening.category).interpText"
                            >
                                {{ session.mchat_screening.recommendation }}
                            </p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- GPPH / ACTRS RESULTS CARD -->
            <section
                v-if="session.gpph_screening"
                :class="[
                    activeResultTab === 'GPPH' || activeResultTab === 'all' ? 'block' : 'hidden print:block',
                    'overflow-hidden rounded-xl bg-white dark:bg-[#0C2038] shadow-sm border border-gray-200 dark:border-white/10 print:break-inside-avoid print-show-all'
                ]"
            >
                <div
                    class="px-6 py-4 flex flex-wrap items-center justify-between gap-3 transition-colors"
                    :class="getInstrumentTheme(session.gpph_screening.category).headerBg"
                >
                    <div>
                        <div class="flex items-center gap-2">
                            <span
                                class="rounded px-2 py-0.5 text-xs font-bold uppercase transition-colors"
                                :class="getInstrumentTheme(session.gpph_screening.category).headerTag"
                            >
                                GPPH
                            </span>
                            <h3
                                class="text-base font-bold transition-colors"
                                :class="getInstrumentTheme(session.gpph_screening.category).headerTitle"
                            >
                                Hasil Deteksi Dini GPPH (ACTRS)
                            </h3>
                        </div>
                        <p
                            class="text-xs mt-1 transition-colors"
                            :class="getInstrumentTheme(session.gpph_screening.category).headerSubtitle"
                        >
                            Deteksi Gangguan Pemusatan Perhatian dan Hiperaktivitas anak 3–6 tahun.
                        </p>
                    </div>

                    <span
                        class="rounded-full px-3.5 py-1 text-xs font-bold border transition-colors"
                        :class="categoryBadgeClass(session.gpph_screening.category)"
                    >
                        {{ categoryLabel(session.gpph_screening.category) }}
                    </span>
                </div>

                <div class="p-6 space-y-4">
                    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                        <div
                            class="rounded-xl p-4 transition-colors"
                            :class="getInstrumentTheme(session.gpph_screening.category).scoreBox"
                        >
                            <span
                                class="text-xs uppercase font-semibold block"
                                :class="getInstrumentTheme(session.gpph_screening.category).scoreLabel"
                            >
                                Total Skor ACTRS
                            </span>
                            <p
                                class="mt-2 text-3xl font-extrabold"
                                :class="getInstrumentTheme(session.gpph_screening.category).scoreValue"
                            >
                                {{ session.gpph_screening.score }} <span class="text-base font-normal opacity-70">/ 30</span>
                            </p>
                            <p
                                class="text-xs mt-1"
                                :class="getInstrumentTheme(session.gpph_screening.category).scoreSubtext"
                            >
                                Cut-off kemungkinan GPPH: Skor ≥ 13
                            </p>
                        </div>

                        <div
                            class="rounded-xl p-4 sm:col-span-2 transition-colors"
                            :class="getInstrumentTheme(session.gpph_screening.category).interpBox"
                        >
                            <span
                                class="text-xs uppercase font-semibold block"
                                :class="getInstrumentTheme(session.gpph_screening.category).interpLabel"
                            >
                                Rekomendasi Tindak Lanjut
                            </span>
                            <p
                                class="mt-1 text-base font-bold"
                                :class="getInstrumentTheme(session.gpph_screening.category).interpTitle"
                            >
                                {{ categoryLabel(session.gpph_screening.category) }}
                            </p>
                            <p
                                class="text-xs leading-relaxed mt-1"
                                :class="getInstrumentTheme(session.gpph_screening.category).interpText"
                            >
                                {{ session.gpph_screening.recommendation }}
                            </p>
                        </div>
                    </div>

                    <div
                        v-if="session.gpph_screening.examiner_doubtful"
                        class="rounded-lg border border-amber-300 dark:border-amber-800/60 bg-amber-50/80 dark:bg-amber-950/30 p-3.5 text-xs text-amber-900 dark:text-amber-200"
                    >
                        <span class="font-bold block">Perhatian Pemeriksa:</span>
                        Pemeriksa mencatat keragu-raguan klinis. Sesuai panduan Kemenkes, bila pemeriksa ragu-ragu anak GPPH atau tidak, anak direkomendasikan dirujuk ke Rumah Sakit dengan fasilitas psikiatri anak/tumbuh kembang.
                    </div>
                </div>
            </section>

            <!-- SDQ RESULTS CARD -->
            <section
                v-if="session.sdq_screening"
                :class="[
                    activeResultTab === 'SDQ' || activeResultTab === 'all' ? 'block' : 'hidden print:block',
                    'overflow-hidden rounded-xl bg-white dark:bg-[#0C2038] shadow-sm border border-gray-200 dark:border-white/10 print:break-inside-avoid print-show-all'
                ]"
            >
                <div
                    class="px-6 py-4 flex flex-wrap items-center justify-between gap-3 transition-colors"
                    :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).headerBg"
                >
                    <div>
                        <div class="flex items-center gap-2">
                            <span
                                class="rounded px-2 py-0.5 text-xs font-bold uppercase transition-colors"
                                :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).headerTag"
                            >
                                SDQ
                            </span>
                            <h3
                                class="text-base font-bold transition-colors"
                                :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).headerTitle"
                            >
                                Hasil Skoring SDQ (Usia 4–11 Tahun)
                            </h3>
                        </div>
                        <p
                            class="text-xs mt-1 transition-colors"
                            :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).headerSubtitle"
                        >
                            Strengths and Difficulties Questionnaire — 5 Subskala Perilaku & Emosi.
                        </p>
                    </div>

                    <span
                        class="rounded-full px-3.5 py-1 text-xs font-bold border transition-colors"
                        :class="categoryBadgeClass(session.sdq_screening.total_difficulties_category)"
                    >
                        Total Kesulitan: {{ categoryLabel(session.sdq_screening.total_difficulties_category) }}
                    </span>
                </div>

                <div class="p-6 space-y-6">
                    <!-- 2 NILAI UTAMA SDQ: TOTAL KESULITAN & PROSOSIAL (LEBIH BESAR & UTAMA) -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <!-- Total Kesulitan (Headline 1) -->
                        <div
                            class="rounded-2xl p-5 sm:p-6 transition-colors shadow-2xs flex flex-col justify-between"
                            :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).scoreBox"
                        >
                            <div>
                                <div class="flex items-center justify-between gap-2 mb-2">
                                    <span
                                        class="text-xs uppercase font-extrabold tracking-wider"
                                        :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).scoreLabel"
                                    >
                                        Nilai Utama: Total Kesulitan
                                    </span>
                                    <span
                                        class="rounded-full px-3 py-0.5 text-xs font-extrabold border"
                                        :class="categoryBadgeClass(session.sdq_screening.total_difficulties_category)"
                                    >
                                        {{ categoryLabel(session.sdq_screening.total_difficulties_category) }}
                                    </span>
                                </div>
                                <div class="flex items-baseline gap-2">
                                    <span
                                        class="text-4xl sm:text-5xl font-black tracking-tight"
                                        :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).scoreValue"
                                    >
                                        {{ session.sdq_screening.total_difficulties_score }}
                                    </span>
                                    <span
                                        class="text-base sm:text-lg font-semibold opacity-70"
                                        :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).scoreLabel"
                                    >
                                        / 40
                                    </span>
                                </div>
                            </div>
                            <p
                                class="mt-3 text-xs leading-relaxed"
                                :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).scoreSubtext"
                            >
                                Penjumlahan 4 Domain Masalah: Gejala Emosional, Masalah Perilaku, Hiperaktivitas, dan Teman Sebaya.
                            </p>
                        </div>

                        <!-- Prososial / Kekuatan (Headline 2) -->
                        <div
                            class="rounded-2xl p-5 sm:p-6 transition-colors shadow-2xs flex flex-col justify-between"
                            :class="getInstrumentTheme(session.sdq_screening.prosocial_category).scoreBox"
                        >
                            <div>
                                <div class="flex items-center justify-between gap-2 mb-2">
                                    <span
                                        class="text-xs uppercase font-extrabold tracking-wider"
                                        :class="getInstrumentTheme(session.sdq_screening.prosocial_category).scoreLabel"
                                    >
                                        Nilai Utama: Prososial (Kekuatan)
                                    </span>
                                    <span
                                        class="rounded-full px-3 py-0.5 text-xs font-extrabold border"
                                        :class="categoryBadgeClass(session.sdq_screening.prosocial_category)"
                                    >
                                        {{ categoryLabel(session.sdq_screening.prosocial_category) }}
                                    </span>
                                </div>
                                <div class="flex items-baseline gap-2">
                                    <span
                                        class="text-4xl sm:text-5xl font-black tracking-tight"
                                        :class="getInstrumentTheme(session.sdq_screening.prosocial_category).scoreValue"
                                    >
                                        {{ session.sdq_screening.prosocial_score }}
                                    </span>
                                    <span
                                        class="text-base sm:text-lg font-semibold opacity-70"
                                        :class="getInstrumentTheme(session.sdq_screening.prosocial_category).scoreLabel"
                                    >
                                        / 10
                                    </span>
                                </div>
                            </div>
                            <p
                                class="mt-3 text-xs leading-relaxed"
                                :class="getInstrumentTheme(session.sdq_screening.prosocial_category).scoreSubtext"
                            >
                                Mengukur kekuatan positif anak: empati, kepedulian berbagi, dan kemampuan membina pertemanan.
                            </p>
                        </div>
                    </div>

                    <!-- RINCIAN 4 SUB-SKALA DOMAIN KESULITAN -->
                    <div class="space-y-3 pt-1">
                        <div class="flex items-center justify-between">
                            <h4 class="text-xs font-bold uppercase tracking-wider text-gray-700 dark:text-gray-300">
                                Rincian 4 Subskala Domain Kesulitan (Masing-masing Maks. 10)
                            </h4>
                            <span class="text-2xs text-gray-500 dark:text-gray-400">
                                Subdomain pembentuk Total Kesulitan
                            </span>
                        </div>

                        <div class="grid grid-cols-2 gap-3 sm:grid-cols-4">
                            <div :class="getSubscaleBoxTheme(session.sdq_screening.emotional_category).box">
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.emotional_category).label">Gejala Emosional (E)</p>
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.emotional_category).value">{{ session.sdq_screening.emotional_score }} / 10</p>
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.emotional_category).catText">
                                    {{ categoryLabel(session.sdq_screening.emotional_category) }}
                                </p>
                            </div>

                            <div :class="getSubscaleBoxTheme(session.sdq_screening.conduct_category).box">
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.conduct_category).label">Masalah Perilaku (C)</p>
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.conduct_category).value">{{ session.sdq_screening.conduct_score }} / 10</p>
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.conduct_category).catText">
                                    {{ categoryLabel(session.sdq_screening.conduct_category) }}
                                </p>
                            </div>

                            <div :class="getSubscaleBoxTheme(session.sdq_screening.hyperactivity_category).box">
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.hyperactivity_category).label">Hiperaktivitas (H)</p>
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.hyperactivity_category).value">{{ session.sdq_screening.hyperactivity_score }} / 10</p>
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.hyperactivity_category).catText">
                                    {{ categoryLabel(session.sdq_screening.hyperactivity_category) }}
                                </p>
                            </div>

                            <div :class="getSubscaleBoxTheme(session.sdq_screening.peer_category).box">
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.peer_category).label">Masalah Teman Sebaya (P)</p>
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.peer_category).value">{{ session.sdq_screening.peer_score }} / 10</p>
                                <p :class="getSubscaleBoxTheme(session.sdq_screening.peer_category).catText">
                                    {{ categoryLabel(session.sdq_screening.peer_category) }}
                                </p>
                            </div>
                        </div>
                    </div>

                    <div
                        v-if="session.sdq_screening.recommendation"
                        class="rounded-xl p-4 transition-colors"
                        :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).interpBox"
                    >
                        <span
                            class="font-bold block mb-1 text-xs"
                            :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).interpTitle"
                        >
                            Rekomendasi SPK SDQ:
                        </span>
                        <p
                            class="text-xs leading-relaxed"
                            :class="getInstrumentTheme(session.sdq_screening.total_difficulties_category).interpText"
                        >
                            {{ session.sdq_screening.recommendation }}
                        </p>
                    </div>
                </div>
            </section>

            <!-- SRQ-20 RESULTS CARD -->
            <section
                v-if="session.srq_screening"
                :class="[
                    activeResultTab === 'SRQ' || activeResultTab === 'all' ? 'block' : 'hidden print:block',
                    'overflow-hidden rounded-xl bg-white dark:bg-[#0C2038] shadow-sm border border-gray-200 dark:border-white/10 print:break-inside-avoid print-show-all'
                ]"
            >
                <div
                    class="px-6 py-4 flex flex-wrap items-center justify-between gap-3 transition-colors"
                    :class="getInstrumentTheme(session.srq_screening.category).headerBg"
                >
                    <div>
                        <div class="flex items-center gap-2">
                            <span
                                class="rounded px-2 py-0.5 text-xs font-bold uppercase transition-colors"
                                :class="getInstrumentTheme(session.srq_screening.category).headerTag"
                            >
                                SRQ-20
                            </span>
                            <h3
                                class="text-base font-bold transition-colors"
                                :class="getInstrumentTheme(session.srq_screening.category).headerTitle"
                            >
                                Hasil SRQ-20 Orang Tua / Pengasuh
                            </h3>
                        </div>
                        <p
                            class="text-xs mt-1 transition-colors"
                            :class="getInstrumentTheme(session.srq_screening.category).headerSubtitle"
                        >
                            Evaluasi kesehatan mental dan distres emosional pendamping anak selama 30 hari terakhir.
                        </p>
                    </div>

                    <span
                        class="rounded-full px-3.5 py-1 text-xs font-bold border transition-colors"
                        :class="categoryBadgeClass(session.srq_screening.category)"
                    >
                        {{ categoryLabel(session.srq_screening.category) }}
                    </span>
                </div>

                <div class="p-6 space-y-4">
                    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                        <div
                            class="rounded-xl p-4 transition-colors"
                            :class="getInstrumentTheme(session.srq_screening.category).scoreBox"
                        >
                            <span
                                class="text-xs uppercase font-semibold block"
                                :class="getInstrumentTheme(session.srq_screening.category).scoreLabel"
                            >
                                Skor Total SRQ-20
                            </span>
                            <p
                                class="mt-2 text-3xl font-extrabold"
                                :class="getInstrumentTheme(session.srq_screening.category).scoreValue"
                            >
                                {{ session.srq_screening.score }} <span class="text-base font-normal opacity-70">/ 20</span>
                            </p>
                            <p
                                class="text-xs mt-1"
                                :class="getInstrumentTheme(session.srq_screening.category).scoreSubtext"
                            >
                                Nilai pisah / cut-off: 6 atau lebih
                            </p>
                        </div>

                        <div
                            class="rounded-xl p-4 sm:col-span-2 transition-colors"
                            :class="getInstrumentTheme(session.srq_screening.category).interpBox"
                        >
                            <span
                                class="text-xs uppercase font-semibold block"
                                :class="getInstrumentTheme(session.srq_screening.category).interpLabel"
                            >
                                Status Distres Emosional Pendamping
                            </span>
                            <p
                                class="mt-1 text-base font-bold"
                                :class="getInstrumentTheme(session.srq_screening.category).interpTitle"
                            >
                                {{ categoryLabel(session.srq_screening.category) }}
                            </p>
                            <p
                                class="text-xs leading-relaxed mt-1"
                                :class="getInstrumentTheme(session.srq_screening.category).interpText"
                            >
                                {{ session.srq_screening.recommendation ?? 'Kondisi psikologis orang tua/pengasuh berpengaruh langsung terhadap stimulasi dan pola asuh tumbuh kembang anak.' }}
                            </p>
                        </div>
                    </div>

                    <!-- SRQ-20 Subscale Breakdown (Riskesdas / Litbang Kemenkes / WHO) -->
                    <div v-if="srqSubscales && srqSubscales.length" class="space-y-3 pt-2">
                        <div class="flex items-center justify-between border-t border-gray-200 dark:border-white/10 pt-4">
                            <div>
                                <h4 class="text-xs font-bold uppercase tracking-wider text-gray-700 dark:text-gray-300">
                                    Rincian Domain Gejala Klinis SRQ-20
                                </h4>
                                <p class="text-2xs text-gray-500 dark:text-gray-400">
                                    Pedoman Analisis Faktor WHO / Balitbang Kemenkes RI
                                </p>
                            </div>
                        </div>

                        <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
                            <div
                                v-for="subscale in srqSubscales"
                                :key="subscale.key"
                                :class="getSubscaleBoxTheme(subscale.category).box"
                            >
                                <p :class="getSubscaleBoxTheme(subscale.category).label">
                                    {{ subscale.name }}
                                </p>
                                <p :class="getSubscaleBoxTheme(subscale.category).value">
                                    {{ subscale.score }} / {{ subscale.max }}
                                </p>
                                <p :class="getSubscaleBoxTheme(subscale.category).catText">
                                    {{ categoryLabel(subscale.category) }}
                                </p>
                                <p class="mt-1 text-2xs text-gray-500 dark:text-gray-400">
                                    Butir {{ subscale.items }}
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Critical Alert for Q17 (Thoughts of ending life) -->
                    <div
                        v-if="session.srq_screening.answers?.[16] === true"
                        class="rounded-xl border-2 border-red-400 dark:border-rose-600 bg-red-50 dark:bg-rose-950/40 p-4 text-xs text-red-900 dark:text-rose-100 flex items-start gap-3"
                    >
                        <svg class="w-6 h-6 text-red-600 dark:text-rose-400 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                        <div>
                            <span class="font-bold text-sm block text-red-950 dark:text-white">PERINGATAN KRITIS: Butir 17 Dijawab "Ya"</span>
                            Responden mengonfirmasi adanya pikiran untuk mengakhiri hidup. Dokter pemeriksa wajib segera melakukan intervensi krisis kesehatan jiwa dan rujukan darurat sesuai protokol klinis.
                        </div>
                    </div>
                </div>
            </section>
            </div>

            <!-- DEVELOPMENTAL MILESTONES & STIMULATION GUIDANCE (VISILY MOCKUP #4) -->
            <section
                v-if="milestones"
                class="overflow-hidden rounded-xl bg-white dark:bg-[#0C2038] shadow-sm border border-gray-200 dark:border-white/10 print:break-before-page print-break-before print:break-inside-avoid print-break-inside-avoid"
            >
                <div class="border-b border-emerald-200 dark:border-emerald-800/60 bg-emerald-50/70 dark:bg-emerald-950/40 px-6 py-4 flex items-center justify-between">
                    <div>
                        <h3 class="text-base font-bold text-emerald-950 dark:text-emerald-100 flex items-center gap-2">
                            <svg class="w-5 h-5 text-emerald-600 dark:text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            Panduan Perkembangan & Stimulasi (Rentang Usia: {{ milestones.group_label }})
                        </h3>
                        <p class="text-xs text-emerald-800/80 dark:text-emerald-300/80 mt-0.5">
                            Target kemampuan perkembangan dan instruksi stimulasi orang tua sesuai pedoman Kemenkes RI.
                        </p>
                    </div>
                </div>

                <div class="p-6 space-y-6">
                    <!-- Milestones by 4 Sectors -->
                    <div>
                        <h4 class="text-xs uppercase tracking-wider font-bold text-gray-700 dark:text-gray-300 mb-3">
                            Target Kemampuan Sesuai Usia (4 Sektor Perkembangan)
                        </h4>
                        <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
                            <div class="rounded-lg border border-emerald-200 dark:border-emerald-800/60 bg-emerald-50/40 dark:bg-emerald-950/40 p-3">
                                <span class="text-2xs font-bold uppercase text-emerald-800 dark:text-emerald-300">Gerak Kasar</span>
                                <ul class="mt-1.5 list-disc list-inside text-xs text-gray-700 dark:text-gray-200 space-y-1">
                                    <li v-for="(item, i) in milestones.milestones?.gross_motor ?? []" :key="i">
                                        {{ item }}
                                    </li>
                                </ul>
                            </div>

                            <div class="rounded-lg border border-sky-200 dark:border-sky-800/60 bg-sky-50/40 dark:bg-sky-950/40 p-3">
                                <span class="text-2xs font-bold uppercase text-sky-800 dark:text-sky-300">Gerak Halus</span>
                                <ul class="mt-1.5 list-disc list-inside text-xs text-gray-700 dark:text-gray-200 space-y-1">
                                    <li v-for="(item, i) in milestones.milestones?.fine_motor ?? []" :key="i">
                                        {{ item }}
                                    </li>
                                </ul>
                            </div>

                            <div class="rounded-lg border border-violet-200 dark:border-violet-800/60 bg-violet-50/40 dark:bg-violet-950/40 p-3">
                                <span class="text-2xs font-bold uppercase text-violet-800 dark:text-violet-300">Bicara & Bahasa</span>
                                <ul class="mt-1.5 list-disc list-inside text-xs text-gray-700 dark:text-gray-200 space-y-1">
                                    <li v-for="(item, i) in milestones.milestones?.speech_language ?? []" :key="i">
                                        {{ item }}
                                    </li>
                                </ul>
                            </div>

                            <div class="rounded-lg border border-amber-200 dark:border-amber-800/60 bg-amber-50/40 dark:bg-amber-950/40 p-3">
                                <span class="text-2xs font-bold uppercase text-amber-800 dark:text-amber-300">Sosialisasi & Kemandirian</span>
                                <ul class="mt-1.5 list-disc list-inside text-xs text-gray-700 dark:text-gray-200 space-y-1">
                                    <li v-for="(item, i) in milestones.milestones?.social_independence ?? []" :key="i">
                                        {{ item }}
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>

                    <!-- Stimulation Instructions -->
                    <div>
                        <h4 class="text-xs uppercase tracking-wider font-bold text-gray-700 dark:text-gray-300 mb-2">
                            Poin Kunci Stimulasi Orang Tua
                        </h4>
                        <ul class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs text-gray-700 dark:text-gray-200">
                            <li
                                v-for="(stim, i) in milestones.stimulation ?? []"
                                :key="i"
                                class="flex items-start gap-2 rounded-lg bg-gray-50 dark:bg-white/5 p-2.5 border border-gray-100 dark:border-white/10"
                            >
                                <span class="text-teal-600 dark:text-teal-400 font-bold">•</span>
                                <span>{{ stim }}</span>
                            </li>
                        </ul>
                    </div>

                    <!-- Red Flags Box -->
                    <div class="rounded-xl border border-rose-200 dark:border-rose-800/70 bg-rose-50/60 dark:bg-rose-950/40 p-4">
                        <h4 class="text-xs font-bold uppercase tracking-wider text-rose-800 dark:text-rose-300 flex items-center gap-1.5 mb-2">
                            <svg class="w-4 h-4 text-rose-600 dark:text-rose-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                            Tanda Bahaya Perkembangan (Red Flags)
                        </h4>
                        <ul class="grid grid-cols-1 sm:grid-cols-2 gap-1.5 text-xs text-rose-900 dark:text-rose-100">
                            <li v-for="(flag, i) in milestones.red_flags ?? []" :key="i" class="flex items-start gap-1.5">
                                <span class="text-rose-500 dark:text-rose-400 font-bold">⚠</span>
                                <span>{{ flag }}</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </section>

            <!-- DOCTOR CLINICAL REVIEW & INTERPRETATION SECTION -->
            <section class="overflow-hidden rounded-xl bg-white dark:bg-[#0C2038] shadow-sm border border-gray-100 dark:border-white/10 print:break-before-page print-break-before print:break-inside-avoid print-break-inside-avoid">
                <div class="border-b border-gray-100 dark:border-white/10 bg-slate-50 dark:bg-[#071D37] px-6 py-4 flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <h3 class="text-base font-bold text-gray-900 dark:text-gray-100 flex items-center gap-2">
                            <svg class="w-5 h-5 text-indigo-700 dark:text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                            Interpretasi Klinis & Keputusan Tindak Lanjut Dokter
                        </h3>
                        <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
                            Dokter meninjau seluruh hasil skrining, memberikan interpretasi klinis per instrumen, dan memfinalisasi rekomendasi.
                        </p>
                    </div>

                    <div v-if="session.status === 'reviewed'" class="inline-flex items-center gap-1.5 rounded-full bg-emerald-100 px-3 py-1 text-xs font-bold text-emerald-800">
                        <svg class="w-4 h-4 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                        </svg>
                        Review Selesai & Difinalisasi
                    </div>
                </div>

                <div class="p-6 space-y-6">
                    <!-- Recorded Interpretations List -->
                    <div v-if="session.screening_interpretations?.length" class="space-y-4">
                        <h4 class="text-xs font-bold uppercase tracking-wider text-gray-600">
                            Interpretasi Tercatat Per Instrumen
                        </h4>

                        <div class="grid grid-cols-1 gap-4">
                            <div
                                v-for="interp in session.screening_interpretations"
                                :key="interp.id"
                                class="rounded-xl border border-gray-200 dark:border-white/10 p-4 bg-gray-50/50 dark:bg-white/5"
                            >
                                <div class="flex items-center justify-between border-b border-gray-200/60 dark:border-white/10 pb-2 mb-2">
                                    <span class="font-bold text-sm text-gray-900 dark:text-gray-100">
                                        Instrumen: {{ interp.instrument_code }}
                                    </span>
                                    <div class="flex items-center gap-2 text-xs">
                                        <span class="text-gray-500 dark:text-gray-400">
                                            dr. {{ interp.doctor?.user?.name ?? '-' }} ({{ formatDate(interp.created_at) }})
                                        </span>
                                        <span
                                            class="rounded px-2 py-0.5 text-2xs font-semibold uppercase"
                                            :class="interp.status === 'completed' ? 'bg-emerald-100 dark:bg-emerald-950/80 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-700' : 'bg-gray-200 dark:bg-white/10 text-gray-700 dark:text-gray-300'"
                                        >
                                            {{ interp.status }}
                                        </span>
                                    </div>
                                </div>

                                <div class="text-xs space-y-2 text-gray-700 dark:text-gray-200">
                                    <p v-if="interp.clinical_notes">
                                        <strong class="text-gray-900 dark:text-white">Catatan Klinis:</strong> {{ interp.clinical_notes }}
                                    </p>
                                    <p v-if="interp.follow_up_decision">
                                        <strong class="text-gray-900 dark:text-white">Keputusan Tindak Lanjut:</strong> {{ interp.follow_up_decision }}
                                    </p>
                                    <p v-if="interp.follow_up_notes">
                                        <strong class="text-gray-900 dark:text-white">Instruksi Tindak Lanjut:</strong> {{ interp.follow_up_notes }}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div v-else class="text-xs text-gray-500 dark:text-gray-400 italic">
                        Belum ada interpretasi dokter yang dicatat untuk sesi ini.
                    </div>

                    <!-- Final Doctor Notes from Session -->
                    <div v-if="session.doctor_notes" class="rounded-xl border border-indigo-200 dark:border-indigo-800/60 bg-indigo-50/40 dark:bg-indigo-950/40 p-4">
                        <span class="text-xs uppercase tracking-wider font-bold text-indigo-900 dark:text-indigo-300 block mb-1">
                            Kesimpulan & Arahan Dokter Sesi:
                        </span>
                        <p class="text-xs leading-relaxed text-indigo-950 dark:text-indigo-100 font-medium">
                            {{ session.doctor_notes }}
                        </p>
                        <p class="text-2xs text-indigo-700 dark:text-indigo-300 mt-2">
                            Ditinjau oleh: {{ session.doctor?.user?.name ?? 'Dokter' }}
                            <span v-if="session.reviewed_at"> pada {{ formatDate(session.reviewed_at) }}</span>
                        </p>
                    </div>

                    <!-- Doctor Action Panel (Visible only when logged in as dokter and session not finalized) -->
                    <div
                        v-if="page.props.auth?.user?.role === 'dokter' && !['reviewed', 'cancelled'].includes(session.status)"
                        class="rounded-xl border border-gray-200 dark:border-white/10 bg-slate-50/60 dark:bg-white/5 p-5 space-y-5 print:hidden"
                    >
                        <h4 class="text-sm font-bold text-gray-900 dark:text-gray-100 flex items-center gap-2">
                            <span>Form Pengisian Tinjauan Dokter</span>
                        </h4>

                        <!-- Instrument Selector for Interpretation -->
                        <div class="flex flex-wrap gap-2">
                            <button
                                v-for="inst in session.screening_session_instruments"
                                :key="inst.id"
                                type="button"
                                :disabled="inst.status !== 'completed'"
                                @click="openInterpretationForm(inst.instrument_code)"
                                class="rounded-lg px-3 py-1.5 text-xs font-semibold border transition disabled:opacity-40 disabled:cursor-not-allowed"
                                :class="activeInterpretationCode === inst.instrument_code
                                    ? 'bg-indigo-700 text-white border-indigo-700'
                                    : 'bg-white dark:bg-white/10 text-gray-700 dark:text-gray-200 border-gray-300 dark:border-white/10 hover:bg-gray-50 dark:hover:bg-white/15'"
                            >
                                Interpretasi {{ inst.instrument_code }}
                                <span v-if="inst.status !== 'completed'" class="text-2xs block text-amber-600 dark:text-amber-400">(Kuesioner belum selesai)</span>
                            </button>
                        </div>

                        <!-- Interpretation Subform -->
                        <form
                            v-if="activeInterpretationCode"
                            class="rounded-xl bg-white dark:bg-[#071D37] p-4 border border-gray-200 dark:border-white/10 space-y-4"
                            @submit.prevent="submitInterpretation"
                        >
                            <div class="flex items-center justify-between border-b border-gray-200 dark:border-white/10 pb-2">
                                <h5 class="text-xs font-bold text-gray-900 dark:text-gray-100">
                                    Catat Interpretasi Klinis: {{ activeInterpretationCode }}
                                </h5>
                                <button type="button" @click="activeInterpretationCode = null" class="text-xs text-gray-500 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200">
                                    Tutup
                                </button>
                            </div>

                            <div>
                                <label class="block text-xs font-medium text-gray-700 dark:text-gray-300">Catatan Klinis Dokter</label>
                                <textarea
                                    v-model="interpForm.clinical_notes"
                                    rows="2"
                                    placeholder="Tuliskan interpretasi medis dan analisis kondisi anak..."
                                    class="mt-1 w-full rounded-lg border-gray-300 dark:border-white/15 text-xs shadow-sm focus:border-indigo-600 focus:ring-indigo-600"
                                />
                            </div>

                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-xs font-medium text-gray-700 dark:text-gray-300">Keputusan Tindak Lanjut</label>
                                    <select
                                        v-model="interpForm.follow_up_decision"
                                        class="mt-1 w-full rounded-lg border-gray-300 dark:border-white/15 text-xs shadow-sm focus:border-indigo-600 focus:ring-indigo-600"
                                    >
                                        <option value="">-- Pilih keputusan --</option>
                                        <option value="stimulasi_rutin">Stimulasi Rutin di Rumah</option>
                                        <option value="stimulasi_2_minggu">Stimulasi Intensif 2 Minggu & Evaluasi</option>
                                        <option value="skrining_ulang">Jadwalkan Skrining Ulang</option>
                                        <option value="rujuk_rs">Rujukan ke Rumah Sakit / Spesialis Tumbuh Kembang</option>
                                        <option value="konseling_jiwa">Konseling Kesehatan Jiwa / Psikolog</option>
                                    </select>
                                </div>

                                <div>
                                    <label class="block text-xs font-bold text-navy dark:text-gray-200">Status Interpretasi</label>
                                    <select
                                        v-model="interpForm.status"
                                        class="mt-1 w-full rounded-xl border-sand/60 dark:border-white/15 text-xs shadow-2xs focus:border-teal focus:ring-teal"
                                    >
                                        <option value="draft">Draf (Belum Selesai)</option>
                                        <option value="completed">Selesai (Final untuk instrumen ini)</option>
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label class="block text-xs font-bold text-navy dark:text-gray-200">Rincian Tindak Lanjut / Resep Edukasi</label>
                                <textarea
                                    v-model="interpForm.follow_up_notes"
                                    rows="2"
                                    placeholder="Instruksi spesifik yang diberikan kepada orang tua..."
                                    class="mt-1 w-full rounded-xl border-sand/60 dark:border-white/15 text-xs shadow-2xs focus:border-teal focus:ring-teal"
                                />
                            </div>

                            <div class="flex justify-end gap-2">
                                <button
                                    type="submit"
                                    :disabled="interpForm.processing"
                                    class="rounded-xl bg-blue-600 px-4 py-2 text-xs font-bold text-white hover:bg-blue-700 disabled:opacity-50 transition shadow-xs"
                                >
                                    {{ interpForm.processing ? 'Menyimpan...' : 'Simpan Interpretasi' }}
                                </button>
                            </div>
                        </form>

                        <!-- Finalize Session Form -->
                        <div class="border-t border-gray-200 dark:border-white/10 pt-4">
                            <label class="block text-xs font-bold text-navy dark:text-gray-200 mb-1">
                                Kesimpulan Tinjauan Sesi (Catatan Dokter untuk Laporan)
                            </label>
                            <textarea
                                v-model="finalizeForm.doctor_notes"
                                rows="3"
                                placeholder="Tuliskan kesimpulan menyeluruh hasil skrining untuk keluarga pasien..."
                                class="w-full rounded-xl border-gray-300 dark:border-white/15 text-xs shadow-2xs focus:border-blue-600 focus:ring-blue-600"
                            />

                            <div class="mt-3 flex justify-end">
                                <button
                                    type="button"
                                    :disabled="finalizeForm.processing"
                                    @click="submitFinalize"
                                    class="rounded-xl bg-emerald-600 px-5 py-2.5 text-xs font-bold text-white hover:bg-emerald-700 disabled:opacity-50 transition shadow-sm"
                                >
                                    {{ finalizeForm.processing ? 'Memproses...' : 'Finalisasi & Selesaikan Review Sesi' }}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>

        <!-- Confirmation Modal Window for Delete -->
        <Teleport to="body">
            <div
                v-if="showDeleteConfirm"
                class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-navy/60 backdrop-blur-xs transition-opacity"
                @click.self="showDeleteConfirm = false"
            >
                <div class="relative w-full max-w-md overflow-hidden rounded-2xl bg-white dark:bg-[#0C2038] p-6 shadow-2xl border border-sand/40 dark:border-white/10 animate-in fade-in zoom-in-95 duration-200">
                    <div class="flex items-center gap-3.5 mb-4">
                        <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-rose-100 dark:bg-rose-950/60 text-rose-600 dark:text-rose-400 shadow-xs">
                            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                        </div>
                        <div>
                            <h3 class="text-base font-extrabold text-navy dark:text-white">
                                Konfirmasi Hapus Sesi Skrining
                            </h3>
                            <p class="text-xs text-gray-500 dark:text-gray-400">
                                Tindakan ini permanen dan tidak dapat dibatalkan.
                            </p>
                        </div>
                    </div>

                    <div class="rounded-xl bg-[#FAF7F0] dark:bg-white/5 p-3.5 mb-5 border border-sand/40 dark:border-white/10 text-xs text-gray-700 dark:text-gray-300 space-y-1.5">
                        <p>
                            Apakah Anda yakin ingin menghapus sesi skrining tanggal
                            <span class="font-bold text-navy dark:text-white">{{ formatDate(session.screening_date) }}</span>
                            untuk pasien
                            <span class="font-bold text-teal dark:text-teal-300">{{ session.patient?.name }}</span>?
                        </p>
                        <p class="text-2xs text-rose-600 dark:text-rose-400 font-semibold">
                            * Seluruh riwayat pengisian instrumen, hasil skor, dan interpretasi klinis terkait sesi ini akan dihapus dari sistem secara permanen.
                        </p>
                    </div>

                    <div class="flex items-center justify-end gap-3">
                        <button
                            type="button"
                            :disabled="isDeleting"
                            @click="showDeleteConfirm = false"
                            class="rounded-xl border border-sand/60 dark:border-white/10 bg-white dark:bg-white/10 px-4 py-2 text-xs font-bold text-navy dark:text-gray-200 hover:bg-sand-light dark:hover:bg-white/15 transition shadow-2xs"
                        >
                            Batal
                        </button>
                        <button
                            type="button"
                            :disabled="isDeleting"
                            @click="executeDelete"
                            class="inline-flex items-center gap-1.5 rounded-xl bg-rose-600 px-4 py-2 text-xs font-bold text-white hover:bg-rose-700 disabled:opacity-50 transition shadow-xs"
                        >
                            <svg v-if="isDeleting" class="animate-spin h-3.5 w-3.5 text-white" fill="none" viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                            </svg>
                            <span>{{ isDeleting ? 'Menghapus...' : 'Ya, Hapus Sesi' }}</span>
                        </button>
                    </div>
                </div>
            </div>
        </Teleport>
    </AuthenticatedLayout>
</template>

<style scoped>
.text-2xs {
    font-size: 0.6875rem;
    line-height: 0.95rem;
}

@media print {
    body {
        background-color: white !important;
        font-size: 11pt;
    }

    .print-break-before,
    .print\:break-before-page {
        break-before: page !important;
        page-break-before: always !important;
        overflow: visible !important;
    }

    .print-break-inside-avoid,
    .print\:break-inside-avoid {
        break-inside: avoid !important;
        page-break-inside: avoid !important;
    }
}
</style>
