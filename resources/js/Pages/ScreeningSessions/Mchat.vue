<script setup>
import { ref, computed } from 'vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { useDraftAnswers } from '@/composables/useDraftAnswers';

const props = defineProps({
    session: {
        type: Object,
        required: true,
    },
    questions: {
        type: Array,
        required: true,
    },
    existingAnswers: {
        type: Array,
        default: () => [],
    },
});

const form = useForm({
    answers: Array.from(
        { length: 20 },
        (_, index) => props.existingAnswers[index] ?? null
    ),
});

const { clearDraft } = useDraftAnswers('MCHAT', props.session.id, form, {
    hasExistingAnswers: props.existingAnswers.length > 0,
});

const currentIndex = ref(0);

const questionDetails = [
    {
        domain: 'Joint Attention (Atensi Bersama)',
        guidance: 'Tunjuk suatu benda/mainan di seberang ruangan dan katakan "Lihat, itu ada [nama mainan]!". Amati apakah anak melihat ke arah benda yang Anda tunjuk, bukan hanya melihat jari tangan Anda.',
        objective: 'Menilai kemampuan koordinasi atensi visual bersama (joint attention), yaitu kemampuan anak untuk berbagi fokus perhatian terhadap suatu objek menarik di sekitarnya bersama orang dewasa.',
        positive_indicators: 'Anak langsung menolehkan kepala atau mengarahkan pandangan matanya ke objek yang ditunjuk; anak menunjukkan ekspresi tertarik pada objek tersebut.',
        negative_indicators: 'Anak hanya menatap jari tangan yang menunjuk, tidak menoleh sama sekali, atau tampak tidak menyadari keberadaan objek yang ditunjuk.',
        testing_steps: 'Tunjuk mainan atau gambar di dinding (jarak 1–2 meter) sambil berkata: "[Nama Anak], lihat itu!". Pastikan anak melihat ke arah benda, bukan hanya ke tangan Anda.',
    },
    {
        domain: 'Sensori Pendengaran & Respon Suara',
        guidance: 'Tanyakan kepada orang tua apakah pernah curiga anak memiliki masalah pendengaran (seperti tidak merespons suara keras atau panggilan).',
        objective: 'Menilai apakah orang tua pernah meragukan fungsi pendengaran anak karena anak sering tidak menanggapi rangsangan suara atau panggilan nama dalam keseharian.',
        positive_indicators: 'Orang tua pernah atau sering merasa curiga anak tuli karena anak acuh tak acuh terhadap suara bising di sekitarnya. (Catatan M-CHAT-R: Jawaban "Ya" pada butir ini mengindikasikan risiko klinis).',
        negative_indicators: 'Orang tua yakin pendengaran anak normal karena anak responsif menoleh terhadap suara mainan, musik, atau panggilan sehari-hari.',
        testing_steps: 'Tanyakan secara mendalam: "Apakah Ibu/Bapak pernah berpikir bahwa anak Anda memiliki gangguan pendengaran atau tuli?".',
    },
    {
        domain: 'Bermain Simbolik (Pretend Play)',
        guidance: 'Amati atau tanyakan apakah anak bermain pura-pura, misalnya menyuapi boneka, minum dari cangkir kosong, atau berbicara melalui telepon mainan.',
        objective: 'Menilai perkembangan imajinasi dan kemampuan bermain simbolik yang merupakan tonggak penting perkembangan kognitif dan interaksi sosial anak usia batita.',
        positive_indicators: 'Anak berpura-pura minum dari cangkir kosong, menyuapi boneka dengan sendok mainan, berbicara di telepon mainan, atau menidurkan boneka.',
        negative_indicators: 'Anak tidak menunjukkan permainan imajinatif; hanya memutar-mutar roda mainan, mengetukkan benda berulang kali, atau melempar barang tanpa makna simbolik.',
        testing_steps: 'Sediakan cangkir kosong dan boneka/hewan mainan. Berikan contoh mengajak minum teh atau menyuapi boneka, lalu amati apakah anak berinisiatif meniru atau bermain pura-pura.',
    },
    {
        domain: 'Motorik Kasar & Eksplorasi Lingkungan',
        guidance: 'Amati apakah anak suka memanjat perabotan rumah, sofa, tangga, atau mainan di taman bermain.',
        objective: 'Menilai inisiatif eksplorasi fisik, kekuatan otot motorik kasar, serta koordinasi gerak tubuh anak terhadap lingkungan sekitarnya.',
        positive_indicators: 'Anak aktif dan percaya diri memanjat sofa, ranjang, tangga rumah, atau peralatan panjat di taman bermain anak secara mandiri.',
        negative_indicators: 'Anak pasif, takut bergerak, enggan mencoba memanjat, atau mengalami hambatan koordinasi fisik motorik kasar yang nyata.',
        testing_steps: 'Konfirmasi kepada orang tua mengenai kebiasaan anak saat berada di sekitar sofa, kasur, atau tangga, atau amati langsung kelincahan gerak anak di ruang periksa.',
    },
    {
        domain: 'Sensori Visual & Gerakan Repetitif (Stimming)',
        guidance: 'Perhatikan apakah anak sering menggerakkan jari-jarinya di dekat matanya secara tidak wajar (misal: mengepakkan jari atau melambaikannya di depan mata).',
        objective: 'Menilai keberadaan stereotipi motorik visual atau gerakan stimulasi diri (stimming) yang tidak lazim pada jari-jari tangan di dekat area mata.',
        positive_indicators: 'Anak sering menggerakkan, menjentikkan, atau melambaikan jari-jemarinya di dekat mata sambil memperhatikannya dengan intensitas tinggi. (Catatan: Jawaban "Ya" mengindikasikan risiko klinis).',
        negative_indicators: 'Gerakan tangan dan jari anak wajar, bertujuan fungsional (memegang, menggenggam, meremas), dan tidak ada gerakan repetitif dekat mata.',
        testing_steps: 'Amati gestur tangan anak atau tanyakan: "Apakah anak suka melambai-lambaikan atau menggoyangkan jarinya di depan matanya?".',
    },
    {
        domain: 'Komunikasi Permintaan (Protoimperative Pointing)',
        guidance: 'Amati apakah anak menunjuk dengan jari telunjuknya untuk meminta benda yang jauh dari jangkauannya (misal menunjuk kue di atas meja).',
        objective: 'Menilai kemampuan komunikasi gestural instrumental, yaitu menggunakan jari telunjuk sebagai alat komunikasi untuk menyatakan kebutuhan atau meminta bantuan.',
        positive_indicators: 'Anak mengacungkan satu jari telunjuk ke arah makanan atau mainan di tempat tinggi yang tidak bisa dijangkaunya sambil melihat ke arah pengasuh.',
        negative_indicators: 'Anak hanya menangis, menarik tangan pengasuh tanpa menunjuk, atau berusaha memanjat sendiri tanpa berkomunikasi.',
        testing_steps: 'Letakkan mainan menarik di rak atau meja yang agak tinggi di luar jangkauan anak, lalu perhatikan apakah anak menunjuk benda tersebut dengan telunjuknya.',
    },
    {
        domain: 'Berbagi Ketertarikan (Protodeclarative Pointing)',
        guidance: 'Amati apakah anak menunjuk sesuatu hanya untuk menunjukkan hal menarik kepada Anda (misal menunjuk pesawat di langit atau burung).',
        objective: 'Menilai gestur sosial murni untuk membagikan pengalaman menarik kepada orang lain tanpa meminta barang tersebut (tonggak penting interaksi sosial).',
        positive_indicators: 'Anak menunjuk pesawat di langit, burung, atau mobil lewat lalu menoleh ke orang tua seolah mengajak: "Lihat itu, ada yang menarik!".',
        negative_indicators: 'Anak tidak pernah berinisiatif menunjuk sesuatu hanya untuk menunjukkan ketertarikan kepada orang lain.',
        testing_steps: 'Tanyakan kepada orang tua: "Jika ada sesuatu yang baru atau menarik di luar, apakah anak spontan menunjuknya agar Anda juga melihatnya?".',
    },
    {
        domain: 'Ketertarikan pada Teman Sebaya (Peer Interest)',
        guidance: 'Amati ketertarikan anak terhadap anak seusianya: apakah anak memperhatikan, tersenyum, atau mendekati anak lain.',
        objective: 'Menilai minat sosial alami terhadap teman sebaya seusianya, yang merupakan pondasi kemampuan sosialisasi dan empati kelompok.',
        positive_indicators: 'Anak memperhatikan anak lain yang lewat, tersenyum pada mereka, mendekat, atau berusaha bergabung dalam permainan.',
        negative_indicators: 'Anak mengabaikan keberadaan anak lain, bersikap acuh seolah sendirian di ruangan, atau menghindar jika didekati anak sebaya.',
        testing_steps: 'Tanyakan perilaku anak saat di taman, posyandu, atau lingkungan rumah ketika bertemu balita lain seusianya.',
    },
    {
        domain: 'Berbagi Afek Positif (Showing / Memperlihatkan)',
        guidance: 'Amati apakah anak membawa mainan atau benda kepada Anda hanya untuk memperlihatkannya dan berbagi rasa senang, bukan untuk meminta tolong.',
        objective: 'Menilai inisiatif berbagi rasa senang (sharing affect) dengan memperlihatkan objek atau hal yang ditemukannya kepada orang tua/figur lekat.',
        positive_indicators: 'Anak membawa gambar, bunga, mainan mobil, atau daun lalu mengangkatnya ke hadapan orang tua sambil tersenyum bangga, bukan untuk meminta bantuan.',
        negative_indicators: 'Anak hanya membawa barang kepada orang tua jika barang tersebut rusak, terkunci, atau anak membutuhkan pertolongan.',
        testing_steps: 'Tanyakan: "Apakah anak pernah membawakan suatu benda kepada Anda hanya untuk memperlihatkannya kepada Anda tanpa meminta bantuan?".',
    },
    {
        domain: 'Respons Panggilan Nama (Response to Name)',
        guidance: 'Panggil nama anak dari belakang atau samping dengan nada normal. Amati apakah anak menoleh, menghentikan aktivitas, atau menatap Anda.',
        objective: 'Menilai orientasi atensi sosial spontan anak ketika namanya dipanggil oleh orang yang dikenalnya.',
        positive_indicators: 'Anak segera menoleh, menghentikan aktivitas sejenak, atau membuat kontak mata ketika namanya dipanggil dari arah samping atau belakang.',
        negative_indicators: 'Anak sama sekali tidak menoleh atau bereaksi saat namanya dipanggil, seolah tidak mendengar panggilan tersebut.',
        testing_steps: 'Panggil nama anak dengan nada suara percakapan normal saat anak sedang asyik bermain. Uji hingga 2 kali bila diperlukan.',
    },
    {
        domain: 'Senyum Balik Sosial (Social Smiling)',
        guidance: 'Tersenyumlah langsung kepada anak saat berhadapan. Amati apakah anak membalas senyuman Anda secara spontan.',
        objective: 'Menilai timbal balik afek emosional sosial (social reciprocity) melalui ekspresi wajah bersahabat.',
        positive_indicators: 'Anak membalas tersenyum secara spontan dan hangat ketika pengasuh atau pemeriksa tersenyum ramah dan menatap wajahnya.',
        negative_indicators: 'Anak tetap berwajah datar, tanpa ekspresi, atau memalingkan wajah saat diberikan senyuman ramah.',
        testing_steps: 'Tatap wajah anak dari jarak sekitar 50 cm, panggil dengan ramah, dan berikan senyuman hangat. Amati respon ekspresi wajah anak.',
    },
    {
        domain: 'Hipersensitivitas Sensori Suara (Auditory Sensitivity)',
        guidance: 'Tanyakan apakah anak bereaksi sangat negatif (menangis hebat, menutup telinga, menjerit) terhadap suara bising sehari-hari seperti blender atau vacuum cleaner.',
        objective: 'Menilai hipersensitivitas sensori auditorik atau gangguan regulasi respon terhadap kebisingan suara lingkungan sehari-hari.',
        positive_indicators: 'Anak marah besar, berteriak histeris, menangis kencang, atau menutup telinga rapat-rapat saat mendengar vacuum cleaner, blender, atau klakson. (Catatan: Jawaban "Ya" mengindikasikan risiko).',
        negative_indicators: 'Anak tidak menunjukkan reaksi penolakan berlebihan; anak terbiasa atau hanya bereaksi terkejut sesaat yang wajar.',
        testing_steps: 'Tanyakan reaksi anak terhadap peralatan rumah tangga yang bersuara keras (blender, vacuum cleaner, hair dryer).',
    },
    {
        domain: 'Kemampuan Berjalan Mandiri (Locomotor)',
        guidance: 'Konfirmasi apakah anak sudah mampu berjalan sendiri tanpa dibantu atau dituntun.',
        objective: 'Menilai pencapaian motorik kasar lokomotor mandiri tanpa bantuan alat maupun pegangan orang dewasa.',
        positive_indicators: 'Anak dapat berdiri dan melangkah bebas di ruangan secara stabil dan mandiri.',
        negative_indicators: 'Anak belum dapat berjalan sendiri, masih harus berpegangan pada furnitur, atau digendong.',
        testing_steps: 'Amati apakah anak berjalan sendiri di ruang periksa atau tanyakan apakah anak sudah lancar berjalan tanpa dipegangi.',
    },
    {
        domain: 'Kontak Mata Sosial (Eye Contact)',
        guidance: 'Amati apakah anak menatap mata Anda saat diajak bicara, bermain bersama, atau saat sedang dipakaikan baju.',
        objective: 'Menilai kualitas dan durasi tatapan mata saat terjadi komunikasi verbal, pengasuhan, atau bermain dua arah.',
        positive_indicators: 'Anak menatap mata pengasuh atau pemeriksa saat diajak berbicara, bermain cilukba, atau saat dipakaikan baju.',
        negative_indicators: 'Anak menghindari tatapan mata, pandangan sering melayang ke samping, atau kontak mata sangat singkat di bawah 1 detik.',
        testing_steps: 'Ajak anak berbicara langsung berhadapan dan amati apakah anak mempertahankan tatapan mata secara wajar dan interaktif.',
    },
    {
        domain: 'Imitasi Gerakan & Perilaku (Imitation)',
        guidance: 'Lakukan gerakan sederhana seperti tepuk tangan atau melambaikan tangan "da-dah". Amati apakah anak mencoba meniru gerakan tersebut.',
        objective: 'Menilai kemampuan belajar sosial melalui imitasi gerakan tubuh, ekspresi wajah, atau bunyi suara.',
        positive_indicators: 'Anak meniru tepuk tangan, melambaikan tangan "da-dah", meniup, menjulurkan lidah, atau meniru suara binatang.',
        negative_indicators: 'Anak tidak menanggapi atau tidak mampu mereplikasi gestur sederhana yang dicontohkan di hadapannya.',
        testing_steps: 'Tepuk tangan di hadapan anak sambil berkata: "Ayo tepuk tangan!". Amati apakah anak mencoba meniru gerakan tersebut.',
    },
    {
        domain: 'Mengikuti Arah Pandang (Gaze Following)',
        guidance: 'Tolehkan kepala Anda melihat ke arah tertentu. Amati apakah anak ikut menoleh untuk melihat apa yang sedang Anda perhatikan.',
        objective: 'Menilai pemahaman anak bahwa arah tatapan mata orang lain mengarah pada objek tertentu di luar dirinya (joint visual attention).',
        positive_indicators: 'Ketika orang tua menolehkan kepala ke jendela atau pintu, anak spontan ikut menoleh ke arah yang sama untuk melihat apa yang sedang diperhatikan.',
        negative_indicators: 'Anak tidak memperhatikan perubahan arah pandang orang lain dan tetap terpaku pada kegiatannya sendiri.',
        testing_steps: 'Pastikan anak menatap Anda, lalu dengan jelas tolehkan kepala Anda ke arah lukisan atau pintu. Amati apakah kepala anak ikut menoleh.',
    },
    {
        domain: 'Menarik Perhatian Sosial (Attention Seeking)',
        guidance: 'Amati apakah anak berusaha membuat Anda memperhatikannya, misalnya memanggil "lihat!", menarik tangan Anda, atau tersenyum menanti pujian.',
        objective: 'Menilai inisiatif sosial anak untuk mencari pengakuan, apresiasi, atau keterlibatan orang tua terhadap tindakannya.',
        positive_indicators: 'Anak berkata "lihat!", menarik baju pengasuh, atau tersenyum menatap pengasuh setelah berhasil menyusun balok.',
        negative_indicators: 'Anak tidak peduli apakah tindakannya diperhatikan atau tidak; tidak ada usaha mengajak orang lain mengapresiasi pencapaiannya.',
        testing_steps: 'Tanyakan: "Apakah anak berusaha membuat Anda memperhatikannya saat dia melakukan sesuatu yang baru atau bermain?".',
    },
    {
        domain: 'Pemahaman Bahasa Reseptif Tanpa Gestur',
        guidance: 'Berikan instruksi verbal sederhana ("Taruh buku di meja" atau "Ambil bola itu") tanpa Anda menunjuk ke arah benda tersebut.',
        objective: 'Menilai bahasa reseptif murni tanpa mengandalkan petunjuk gestur tangan atau tatapan mata.',
        positive_indicators: 'Anak memahami dan melaksanakan instruksi sederhana seperti "ambil sepatumu" atau "duduk di kursi" tanpa Anda menunjuk ke benda tersebut.',
        negative_indicators: 'Anak tidak memahami kalimat instruksi jika Anda tidak mengarahkan atau menunjuk bendanya secara langsung.',
        testing_steps: 'Beri instruksi tenang tanpa menunjuk: "[Nama anak], tolong ambilkan botol itu". Amati apakah anak mengerti instruksi verbal tersebut.',
    },
    {
        domain: 'Social Referencing (Konfirmasi Emosi)',
        guidance: 'Ketika ada peristiwa baru atau bunyi yang asing, amati apakah anak menatap wajah Anda untuk mengecek reaksi atau perasaan Anda.',
        objective: 'Menilai penggunaan ekspresi wajah figur lekat sebagai acuan rasa aman anak saat menghadapi situasi, bunyi, atau objek yang baru.',
        positive_indicators: 'Saat mendengar suara asing atau mainan baru bergerak, anak menatap wajah orang tua untuk mengecek apakah situasinya aman atau lucu.',
        negative_indicators: 'Anak tidak menoleh ke wajah orang tua saat ada peristiwa mengejutkan, langsung panik atau acuh tanpa konfirmasi sosial.',
        testing_steps: 'Tanyakan kepada pengasuh: "Jika terjadi sesuatu yang baru atau aneh, apakah anak menatap wajah Anda untuk melihat reaksi Anda?".',
    },
    {
        domain: 'Kebutuhan Sensori Gerak (Vestibular)',
        guidance: 'Tanyakan apakah anak menyukai aktivitas gerak seperti diayun perlahan atau diangkat-angkat pada lutut pengasuh.',
        objective: 'Menilai integrasi sensori vestibular dan kesenangan berinteraksi fisik kinestetik dengan pengasuh.',
        positive_indicators: 'Anak tertawa ceria, menikmati dan meminta lagi saat diayun perlahan, digendong meluncur, atau dihentak-hentakkan di lutut pengasuh.',
        negative_indicators: 'Anak menolak keras, ketakutan luar biasa, atau menangis histeris terhadap gerakan berayun atau goyangan ringan.',
        testing_steps: 'Tanyakan: "Apakah anak menyukai permainan fisik seperti diayun perlahan atau diangkat meluncur?".',
    },
];

const currentQuestionText = computed(() => props.questions[currentIndex.value] ?? '');
const currentDetail = computed(() => questionDetails[currentIndex.value] ?? { domain: 'Pengamatan Perilaku', guidance: 'Amati perilaku khas anak sehari-hari.' });

const answeredCount = computed(() => {
    return form.answers.filter(
        (answer) => answer !== null && answer !== ''
    ).length;
});

const allAnswered = computed(() => answeredCount.value === 20);

const progressPercent = computed(() => {
    return Math.round(((currentIndex.value + 1) / props.questions.length) * 100);
});

function scrollToTop() {
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function goToNext() {
    if (currentIndex.value < props.questions.length - 1) {
        currentIndex.value++;
        scrollToTop();
    }
}

function goToPrev() {
    if (currentIndex.value > 0) {
        currentIndex.value--;
        scrollToTop();
    }
}

function goToQuestion(index) {
    if (index >= 0 && index < props.questions.length) {
        currentIndex.value = index;
        scrollToTop();
    }
}

function selectAnswer(val) {
    form.answers[currentIndex.value] = val;
}

function submit() {
    form.post(`/spk/screening-sessions/${props.session.id}/mchat`, {
        onSuccess: () => clearDraft(),
    });
}
</script>

<template>
    <Head title="Pengisian M-CHAT-R" />

    <AuthenticatedLayout>
        <!-- Top Navigation Breadcrumb & Header -->
        <template #header>
            <div class="flex flex-wrap items-center justify-between gap-4">
                <nav class="flex items-center gap-2 text-xs font-semibold text-gray-500">
                    <Link :href="`/spk/screening-sessions/${session.id}`" class="text-teal hover:text-navy transition font-bold">
                        Detail Sesi #{{ session.id }}
                    </Link>
                    <span>&rsaquo;</span>
                    <span class="text-gray-400">Instrumen Skrining</span>
                    <span>&rsaquo;</span>
                    <span class="text-navy font-bold">M-CHAT-R (Deteksi Dini Autisme)</span>
                </nav>

                <div class="flex items-center gap-3">
                    <span class="rounded-full bg-blue-50 px-3 py-1 text-xs font-bold text-blue-700 border border-blue-200">
                        SESI ID: #{{ session.id }}
                    </span>
                    <span class="rounded-full bg-amber-50 px-3 py-1 text-xs font-bold text-amber-700 border border-amber-200">
                        Target Usia: 16–30 Bulan
                    </span>
                </div>
            </div>
        </template>

        <div class="mx-auto max-w-4xl space-y-6">
            <!-- Patient Quick Pill & Back Link -->
            <div class="flex flex-wrap items-center justify-between gap-4">
                <Link
                    :href="`/spk/screening-sessions/${session.id}`"
                    class="inline-flex items-center gap-1.5 text-xs font-bold text-gray-600 hover:text-navy transition"
                >
                    &larr; Kembali ke Detail Sesi Skrining
                </Link>

                <div class="flex items-center gap-3 rounded-xl bg-white px-4 py-2 border border-sand/40 shadow-2xs text-xs">
                    <span class="text-gray-400 font-semibold">Pasien:</span>
                    <span class="font-bold text-navy">{{ session.patient?.name ?? '-' }}</span>
                    <span class="text-gray-300">|</span>
                    <span class="text-gray-400 font-semibold">No. RM:</span>
                    <span class="font-bold text-teal">{{ session.patient?.medical_record_number ?? '-' }}</span>
                    <span class="text-gray-300">|</span>
                    <span class="text-gray-400 font-semibold">Umur:</span>
                    <span class="font-bold text-navy">{{ session.age_months }} Bulan</span>
                </div>
            </div>

            <!-- TITLE & PROGRESS SECTION (Matching Visily UI Mockup #3) -->
            <section class="rounded-2xl border border-sand/40 bg-white p-6 shadow-xs space-y-5">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <div class="flex items-center gap-2">
                            <span class="flex h-5 w-5 items-center justify-center rounded-full bg-blue-600 text-white text-2xs font-black">
                                ✓
                            </span>
                            <span class="text-xs font-bold uppercase tracking-wider text-blue-700">
                                Modified Checklist for Autism in Toddlers, Revised (M-CHAT-R)
                            </span>
                        </div>
                        <h1 class="mt-1 text-xl sm:text-2xl font-black text-navy tracking-tight">
                            Skrining Tumbuh Kembang & Deteksi Dini Autisme Balita
                        </h1>
                    </div>

                    <div class="text-right">
                        <span class="text-xs font-bold text-gray-400 block uppercase tracking-wider">Status Pengisian</span>
                        <span class="text-sm font-black" :class="allAnswered ? 'text-emerald-600' : 'text-blue-600'">
                            {{ answeredCount }} dari {{ questions.length }} Butir Terisi
                        </span>
                    </div>
                </div>

                <!-- Progress Bar & Stepper Counter -->
                <div class="space-y-2">
                    <div class="flex items-center justify-between text-xs font-bold">
                        <span class="uppercase tracking-wider text-blue-700">
                            PROGRES PENGERJAAN
                        </span>
                        <span class="text-gray-600">
                            PERTANYAAN {{ currentIndex + 1 }} DARI {{ questions.length }}
                        </span>
                    </div>

                    <!-- Progress bar -->
                    <div class="h-2 w-full overflow-hidden rounded-full bg-blue-100">
                        <div
                            class="h-full bg-blue-600 transition-all duration-300 ease-out"
                            :style="{ width: `${progressPercent}%` }"
                        />
                    </div>
                </div>

                <!-- Question Navigation Pills / Quick Jumper -->
                <div class="flex flex-wrap items-center gap-1.5 pt-1">
                    <button
                        v-for="(q, idx) in questions"
                        :key="idx"
                        type="button"
                        @click="goToQuestion(idx)"
                        class="flex h-8 w-8 items-center justify-center rounded-lg text-xs font-bold transition shadow-2xs"
                        :class="
                            currentIndex === idx
                                ? 'bg-blue-600 text-white ring-2 ring-blue-400 ring-offset-1'
                                : form.answers[idx] !== null && form.answers[idx] !== ''
                                ? 'bg-emerald-50 dark:bg-emerald-950/80 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800 font-bold hover:bg-emerald-100 dark:hover:bg-emerald-900/60'
                                : 'bg-gray-50 dark:bg-white/10 text-gray-600 dark:text-gray-300 border border-gray-200 dark:border-white/10 hover:bg-gray-100 dark:hover:bg-white/20'
                        "
                        :title="`Menuju pertanyaan ke-${idx + 1}`"
                    >
                        {{ idx + 1 }}
                    </button>
                </div>
            </section>

            <!-- SINGLE QUESTION STEP CARD (Per Page 1 Soal + Petunjuk + Penjelasan Detail) -->
            <form @submit.prevent="submit" class="space-y-6">
                <section class="rounded-2xl border border-sand/40 bg-white p-6 sm:p-8 shadow-xs space-y-6">
                    <!-- Domain Badge & Question Header -->
                    <div class="space-y-2">
                        <div class="flex items-center gap-2">
                            <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-bold border bg-teal-50 dark:bg-teal-950/70 text-teal-800 dark:text-teal-300 border-teal-300 dark:border-teal-700">
                                Sektor: {{ currentDetail.domain }}
                            </span>
                            <span class="text-xs font-semibold text-gray-400">
                                Pertanyaan Nomor {{ currentIndex + 1 }}
                            </span>
                        </div>

                        <!-- Question Text -->
                        <h2 class="text-lg sm:text-xl font-black text-navy leading-relaxed">
                            {{ currentQuestionText }}
                        </h2>
                    </div>

                    <!-- PETUNJUK PENGISIAN & OBSERVASI (Selalu Ada di Setiap Halaman) -->
                    <div class="rounded-xl border border-blue-200 dark:border-blue-800/60 bg-blue-50/70 dark:bg-blue-950/40 p-4 sm:p-5 text-xs text-blue-950 dark:text-blue-100 space-y-1.5">
                        <div class="flex items-center gap-2 font-bold text-blue-900 dark:text-blue-300 text-sm">
                            <svg class="h-4 w-4 shrink-0 text-blue-700 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            <span>Petunjuk Pengamatan Klinis</span>
                        </div>
                        <p class="leading-relaxed font-medium">
                            {{ currentDetail.guidance }}
                        </p>
                        <div class="mt-2 pt-2 border-t border-blue-200/60 dark:border-blue-800/40 flex flex-wrap gap-4 text-3xs sm:text-2xs font-semibold text-blue-800 dark:text-blue-200">
                            <span>&bull; <strong>Pilih 'Ya'</strong> jika perilaku ini biasa atau sering dilakukan anak dalam keseharian.</span>
                            <span>&bull; <strong>Pilih 'Tidak'</strong> jika perilaku ini jarang sekali (hanya 1-2 kali) atau belum pernah dilakukan anak.</span>
                        </div>
                    </div>

                    <!-- PENJELASAN DETAIL & PANDUAN OBSERVASI KLINIS (Tanpa Gambar, Penjelasan Rinci) -->
                    <div class="rounded-2xl border border-sand/50 dark:border-white/10 bg-[#FAF9F5] dark:bg-[#071D37] p-5 sm:p-6 space-y-4 shadow-2xs">
                        <div class="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-teal dark:text-teal-300">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                            <span>Penjelasan Detail & Panduan Evaluasi Klinis</span>
                        </div>

                        <!-- Deskripsi Fokus Klinis -->
                        <p class="text-xs sm:text-sm text-gray-700 dark:text-gray-200 leading-relaxed font-medium">
                            {{ currentDetail.objective }}
                        </p>

                        <!-- Grid Indikator Ya vs Indikator Tidak -->
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                            <div class="rounded-xl border border-emerald-200 dark:border-emerald-800/60 bg-emerald-50/70 dark:bg-emerald-950/40 p-3.5 space-y-1">
                                <div class="flex items-center gap-1.5 font-bold text-emerald-800 dark:text-emerald-300">
                                    <span>✓</span>
                                    <span>Kriteria 'Ya' (Perilaku Positif)</span>
                                </div>
                                <p class="text-emerald-900 dark:text-emerald-100 leading-relaxed text-2xs sm:text-xs">
                                    {{ currentDetail.positive_indicators }}
                                </p>
                            </div>

                            <div class="rounded-xl border border-rose-200 dark:border-rose-800/60 bg-rose-50/70 dark:bg-rose-950/40 p-3.5 space-y-1">
                                <div class="flex items-center gap-1.5 font-bold text-rose-800 dark:text-rose-300">
                                    <span>✕</span>
                                    <span>Kriteria 'Tidak' (Risiko / Belum Mampu)</span>
                                </div>
                                <p class="text-rose-900 dark:text-rose-100 leading-relaxed text-2xs sm:text-xs">
                                    {{ currentDetail.negative_indicators }}
                                </p>
                            </div>
                        </div>

                        <!-- Cara Pengujian / Konfirmasi -->
                        <div class="rounded-xl border border-sand/40 dark:border-white/10 bg-white dark:bg-[#0C2038] p-3.5 space-y-1 text-2xs sm:text-xs">
                            <span class="font-bold text-navy dark:text-white block">Langkah Pemeriksaan / Konfirmasi Orang Tua:</span>
                            <p class="text-gray-600 dark:text-gray-300 leading-relaxed">
                                {{ currentDetail.testing_steps }}
                            </p>
                        </div>
                    </div>

                    <!-- KARTU PILIHAN JAWABAN (Interactive Selection Cards - Visily Mockup #3) -->
                    <div class="space-y-3">
                        <label class="block text-xs font-bold uppercase tracking-wider text-gray-500">
                            Pilih Jawaban Pengamatan:
                        </label>

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <!-- Opsi Ya -->
                            <button
                                type="button"
                                @click="selectAnswer(true)"
                                class="flex items-center justify-between rounded-2xl border-2 p-5 text-left transition shadow-xs cursor-pointer group"
                                :class="
                                    form.answers[currentIndex] === true
                                        ? 'border-emerald-600 dark:border-emerald-500 bg-emerald-50/80 dark:bg-emerald-950/60 text-emerald-950 dark:text-emerald-100 ring-2 ring-emerald-500/20'
                                        : 'border-gray-200 dark:border-white/10 bg-white dark:bg-[#071D37] hover:border-emerald-300 dark:hover:border-emerald-500/40 hover:bg-emerald-50/20 dark:hover:bg-emerald-950/20 text-gray-800 dark:text-gray-200'
                                "
                            >
                                <div class="space-y-1">
                                    <span class="block text-base font-black text-emerald-800 dark:text-emerald-300">
                                        Ya (Biasa / Sering Dilakukan)
                                    </span>
                                    <span class="block text-xs text-gray-600 dark:text-gray-400 font-medium">
                                        Anak terbiasa atau sering menunjukkan perilaku ini secara konsisten.
                                    </span>
                                </div>

                                <div
                                    class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full border-2 transition ml-3"
                                    :class="
                                        form.answers[currentIndex] === true
                                            ? 'border-emerald-600 bg-emerald-600 text-white'
                                            : 'border-gray-300 dark:border-gray-600 bg-white dark:bg-transparent'
                                    "
                                >
                                    <span v-if="form.answers[currentIndex] === true" class="text-xs font-black">✓</span>
                                </div>
                            </button>

                            <!-- Opsi Tidak -->
                            <button
                                type="button"
                                @click="selectAnswer(false)"
                                class="flex items-center justify-between rounded-2xl border-2 p-5 text-left transition shadow-xs cursor-pointer group"
                                :class="
                                    form.answers[currentIndex] === false
                                        ? 'border-rose-600 dark:border-rose-500 bg-rose-50/80 dark:bg-rose-950/60 text-rose-950 dark:text-rose-100 ring-2 ring-rose-500/20'
                                        : 'border-gray-200 dark:border-white/10 bg-white dark:bg-[#071D37] hover:border-rose-300 dark:hover:border-rose-500/40 hover:bg-rose-50/20 dark:hover:bg-rose-950/20 text-gray-800 dark:text-gray-200'
                                "
                            >
                                <div class="space-y-1">
                                    <span class="block text-base font-black text-rose-800 dark:text-rose-300">
                                        Tidak (Jarang / Belum Pernah)
                                    </span>
                                    <span class="block text-xs text-gray-600 dark:text-gray-400 font-medium">
                                        Anak jarang sekali (1–2 kali saja) atau tidak pernah menunjukkan perilaku ini.
                                    </span>
                                </div>

                                <div
                                    class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full border-2 transition ml-3"
                                    :class="
                                        form.answers[currentIndex] === false
                                            ? 'border-rose-600 bg-rose-600 text-white'
                                            : 'border-gray-300 dark:border-gray-600 bg-white dark:bg-transparent'
                                    "
                                >
                                    <span v-if="form.answers[currentIndex] === false" class="text-xs font-black">✓</span>
                                </div>
                            </button>
                        </div>
                    </div>
                </section>

                <!-- BOTTOM ACTION BAR (Back, Auto-saved Notice, Next / Submit) -->
                <section class="flex flex-wrap items-center justify-between gap-4 rounded-2xl border border-sand/40 bg-white p-5 shadow-xs">
                    <button
                        type="button"
                        @click="goToPrev"
                        :disabled="currentIndex === 0"
                        class="rounded-xl border border-sand/60 px-5 py-2.5 text-xs font-bold text-navy hover:bg-sand-light disabled:opacity-40 disabled:cursor-not-allowed transition shadow-2xs"
                    >
                        &larr; Butir Sebelumnya
                    </button>

                    <div class="flex items-center gap-2 text-xs text-gray-500">
                        <span class="flex h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                        <span>Jawaban tersimpan otomatis</span>
                        <span>&bull;</span>
                        <span class="font-bold text-navy">{{ answeredCount }} / {{ questions.length }} Terjawab</span>
                    </div>

                    <div class="flex items-center gap-3">
                        <button
                            v-if="currentIndex < questions.length - 1"
                            type="button"
                            @click="goToNext"
                            class="rounded-xl bg-blue-600 hover:bg-blue-700 px-6 py-2.5 text-xs font-bold text-white transition shadow-xs"
                        >
                            Butir Selanjutnya &rarr;
                        </button>

                        <button
                            v-else
                            type="submit"
                            :disabled="form.processing || !allAnswered"
                            class="rounded-xl bg-emerald-600 hover:bg-emerald-700 px-6 py-2.5 text-xs font-bold text-white disabled:opacity-50 disabled:cursor-not-allowed transition shadow-sm"
                        >
                            {{ form.processing ? 'Menghitung Risiko...' : 'Simpan Jawaban & Hitung Skor M-CHAT-R' }}
                        </button>
                    </div>
                </section>
            </form>

            <!-- GUIDELINES REFERENCE CARD (Matching Visily UI Mockup #3) -->
            <section class="rounded-2xl border border-sand/40 bg-[#FAF7F0] p-6 shadow-xs space-y-4">
                <h3 class="text-xs font-bold uppercase tracking-wider text-navy">
                    PEDOMAN KLINIS & ACUAN EVALUASI M-CHAT-R
                </h3>

                <div class="grid grid-cols-1 gap-4 sm:grid-cols-3 text-xs">
                    <div class="rounded-xl bg-white p-4 border border-sand/30 space-y-1">
                        <span class="font-bold text-navy block">Ambang Batas Skor (Threshold)</span>
                        <p class="text-gray-600 leading-relaxed text-2xs">
                            Skor 0–2: <strong>Risiko Rendah</strong> (Lanjutkan stimulasi dan jadwalkan kunjungan berikutnya).<br>
                            Skor 3–20: <strong>Risiko Sedang-Tinggi</strong> (Rujuk ke RS tumbuh kembang level 1 untuk pemeriksaan lebih lanjut).
                        </p>
                    </div>

                    <div class="rounded-xl bg-white p-4 border border-sand/30 space-y-1">
                        <span class="font-bold text-navy block">Aturan Pembobotan &amp; Tindak Lanjut</span>
                        <p class="text-gray-600 leading-relaxed text-2xs">
                            Jawaban <em>Tidak</em> bernilai 1 pada 17 butir umum, sedangkan butir 2, 5, dan 12 bernilai 1 jika dijawab <em>Ya</em>. Bila skor total &ge; 3, anak direkomendasikan dirujuk ke RS tumbuh kembang level 1.
                        </p>
                    </div>

                    <div class="rounded-xl bg-white p-4 border border-sand/30 space-y-1">
                        <span class="font-bold text-navy block">Kesesuaian Rentang Usia</span>
                        <p class="text-gray-600 leading-relaxed text-2xs">
                            Instrumen ini divalidasi khusus untuk balita usia 16 hingga 30 bulan. Saat ini usia anak adalah {{ session.age_months }} bulan.
                        </p>
                    </div>
                </div>
            </section>
        </div>
    </AuthenticatedLayout>
</template>
