import { watch } from 'vue';

/**
 * Persist and restore unsaved screening form drafts in browser localStorage.
 * Existing database answers always take precedence over local drafts.
 */
export function useDraftAnswers(
    instrumentCode,
    sessionId,
    form,
    { hasExistingAnswers = false, extraKeys = [] } = {}
) {
    const storageKey = `spk_draft_${instrumentCode}_${sessionId}`;

    if (!hasExistingAnswers && typeof window !== 'undefined' && window.localStorage) {
        try {
            const raw = window.localStorage.getItem(storageKey);
            if (raw) {
                const parsed = JSON.parse(raw);
                if (Array.isArray(parsed?.answers) && parsed.answers.length === form.answers.length) {
                    form.answers = parsed.answers;
                }
                for (const key of extraKeys) {
                    if (parsed && Object.prototype.hasOwnProperty.call(parsed, key)) {
                        form[key] = parsed[key];
                    }
                }
            }
        } catch {
            // Ignore malformed or blocked localStorage entries.
        }
    }

    watch(
        () => [form.answers, ...extraKeys.map((key) => form[key])],
        () => {
            if (typeof window === 'undefined' || !window.localStorage) {
                return;
            }
            try {
                const payload = { answers: form.answers };
                for (const key of extraKeys) {
                    payload[key] = form[key];
                }
                window.localStorage.setItem(storageKey, JSON.stringify(payload));
            } catch {
                // Ignore storage quota errors.
            }
        },
        { deep: true }
    );

    function clearDraft() {
        if (typeof window === 'undefined' || !window.localStorage) {
            return;
        }
        try {
            window.localStorage.removeItem(storageKey);
        } catch {
            // Ignore storage removal errors.
        }
    }

    return {
        clearDraft,
    };
}
