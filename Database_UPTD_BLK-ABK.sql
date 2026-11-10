--
-- PostgreSQL database dump
--

\restrict E0SOSpUtS36jL2hna2g372NpjA8GELuBB0j3XP1fspeodKShXLkcVfdaXJ75Q48

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg12+2)
-- Dumped by pg_dump version 18.6 (Debian 18.6-1.pgdg12+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cache; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache OWNER TO spk_user;

--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache_locks OWNER TO spk_user;

--
-- Name: doctors; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.doctors (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    specialization character varying(150),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.doctors OWNER TO spk_user;

--
-- Name: doctors_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.doctors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctors_id_seq OWNER TO spk_user;

--
-- Name: doctors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.doctors_id_seq OWNED BY public.doctors.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO spk_user;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO spk_user;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: gpph_screenings; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.gpph_screenings (
    id bigint NOT NULL,
    screening_session_id bigint NOT NULL,
    answers jsonb NOT NULL,
    score smallint NOT NULL,
    examiner_doubtful boolean DEFAULT false NOT NULL,
    category character varying(40) NOT NULL,
    recommendation text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT gpph_screenings_category_check CHECK (((category)::text = ANY ((ARRAY['normal'::character varying, 'meragukan'::character varying, 'kemungkinan_gpph'::character varying])::text[]))),
    CONSTRAINT gpph_screenings_score_check CHECK (((score >= 0) AND (score <= 30)))
);


ALTER TABLE public.gpph_screenings OWNER TO spk_user;

--
-- Name: gpph_screenings_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.gpph_screenings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gpph_screenings_id_seq OWNER TO spk_user;

--
-- Name: gpph_screenings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.gpph_screenings_id_seq OWNED BY public.gpph_screenings.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE public.job_batches OWNER TO spk_user;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE public.jobs OWNER TO spk_user;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jobs_id_seq OWNER TO spk_user;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: kpsp_screenings; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.kpsp_screenings (
    id bigint NOT NULL,
    screening_session_id bigint NOT NULL,
    answers jsonb NOT NULL,
    score smallint NOT NULL,
    category character varying(40) NOT NULL,
    recommendation text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    form_age_months smallint,
    domain_scores json,
    sdidtk_code character varying(10),
    clinical_action character varying(50),
    is_re_evaluation boolean DEFAULT false NOT NULL,
    CONSTRAINT kpsp_screenings_category_check CHECK (((category)::text = ANY ((ARRAY['sesuai_umur'::character varying, 'meragukan'::character varying, 'kemungkinan_penyimpangan'::character varying])::text[]))),
    CONSTRAINT kpsp_screenings_form_age_months_check CHECK (((form_age_months IS NULL) OR (form_age_months = ANY (ARRAY[3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 42, 48, 54, 60, 66, 72])))),
    CONSTRAINT kpsp_screenings_score_check CHECK (((score >= 0) AND (score <= 10)))
);


ALTER TABLE public.kpsp_screenings OWNER TO spk_user;

--
-- Name: kpsp_screenings_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.kpsp_screenings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kpsp_screenings_id_seq OWNER TO spk_user;

--
-- Name: kpsp_screenings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.kpsp_screenings_id_seq OWNED BY public.kpsp_screenings.id;


--
-- Name: mchat_screenings; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.mchat_screenings (
    id bigint NOT NULL,
    screening_session_id bigint NOT NULL,
    answers jsonb NOT NULL,
    score smallint NOT NULL,
    category character varying(30) NOT NULL,
    recommendation text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT mchat_screenings_category_check CHECK (((category)::text = ANY ((ARRAY['risiko_rendah'::character varying, 'risiko_sedang_tinggi'::character varying])::text[]))),
    CONSTRAINT mchat_screenings_score_check CHECK (((score >= 0) AND (score <= 20)))
);


ALTER TABLE public.mchat_screenings OWNER TO spk_user;

--
-- Name: mchat_screenings_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.mchat_screenings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mchat_screenings_id_seq OWNER TO spk_user;

--
-- Name: mchat_screenings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.mchat_screenings_id_seq OWNED BY public.mchat_screenings.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO spk_user;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO spk_user;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: nurses; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.nurses (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    registration_number character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.nurses OWNER TO spk_user;

--
-- Name: nurses_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.nurses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nurses_id_seq OWNER TO spk_user;

--
-- Name: nurses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.nurses_id_seq OWNED BY public.nurses.id;


--
-- Name: parent_guardians; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.parent_guardians (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    phone character varying(30),
    address text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.parent_guardians OWNER TO spk_user;

--
-- Name: parent_guardians_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.parent_guardians_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parent_guardians_id_seq OWNER TO spk_user;

--
-- Name: parent_guardians_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.parent_guardians_id_seq OWNED BY public.parent_guardians.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO spk_user;

--
-- Name: patients; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.patients (
    id bigint NOT NULL,
    parent_guardian_id bigint NOT NULL,
    medical_record_number character varying(100) NOT NULL,
    name character varying(150) NOT NULL,
    birth_date date NOT NULL,
    gender character varying(1) NOT NULL,
    guardian_relationship character varying(50),
    is_premature boolean DEFAULT false NOT NULL,
    gestational_age_weeks smallint,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    address text,
    education character varying(50) DEFAULT 'tidak_sekolah'::character varying,
    school_name character varying(200),
    CONSTRAINT patients_gender_check CHECK (((gender)::text = ANY ((ARRAY['L'::character varying, 'P'::character varying])::text[]))),
    CONSTRAINT patients_gestational_age_weeks_check CHECK ((((is_premature = false) AND (gestational_age_weeks IS NULL)) OR ((is_premature = true) AND ((gestational_age_weeks >= 20) AND (gestational_age_weeks <= 45)))))
);


ALTER TABLE public.patients OWNER TO spk_user;

--
-- Name: patients_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.patients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.patients_id_seq OWNER TO spk_user;

--
-- Name: patients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.patients_id_seq OWNED BY public.patients.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.roles OWNER TO spk_user;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO spk_user;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: screening_interpretations; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.screening_interpretations (
    id bigint NOT NULL,
    screening_session_id bigint NOT NULL,
    instrument_code character varying(20) NOT NULL,
    doctor_id bigint NOT NULL,
    clinical_notes text,
    follow_up_decision character varying(100),
    follow_up_notes text,
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    completed_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.screening_interpretations OWNER TO spk_user;

--
-- Name: screening_interpretations_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.screening_interpretations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.screening_interpretations_id_seq OWNER TO spk_user;

--
-- Name: screening_interpretations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.screening_interpretations_id_seq OWNED BY public.screening_interpretations.id;


--
-- Name: screening_session_instruments; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.screening_session_instruments (
    id bigint NOT NULL,
    screening_session_id bigint NOT NULL,
    instrument_code character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    started_at timestamp(0) without time zone,
    completed_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT screening_session_instruments_code_check CHECK (((instrument_code)::text = ANY ((ARRAY['KPSP'::character varying, 'MCHAT'::character varying, 'GPPH'::character varying, 'SDQ'::character varying, 'SRQ'::character varying])::text[]))),
    CONSTRAINT screening_session_instruments_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.screening_session_instruments OWNER TO spk_user;

--
-- Name: screening_session_instruments_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.screening_session_instruments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.screening_session_instruments_id_seq OWNER TO spk_user;

--
-- Name: screening_session_instruments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.screening_session_instruments_id_seq OWNED BY public.screening_session_instruments.id;


--
-- Name: screening_sessions; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.screening_sessions (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    nurse_id bigint NOT NULL,
    doctor_id bigint,
    screening_date date NOT NULL,
    age_months smallint NOT NULL,
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    notes text,
    doctor_notes text,
    reviewed_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    created_by_user_id bigint NOT NULL,
    evaluation_type character varying(40) DEFAULT 'initial'::character varying NOT NULL,
    parent_session_id bigint,
    case_type character varying(20),
    referral_source character varying(100),
    referral_target character varying(100),
    interventions json,
    recap_notes text,
    CONSTRAINT screening_sessions_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'in_progress'::character varying, 'pending_parent'::character varying, 'pending_doctor_review'::character varying, 'reviewed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.screening_sessions OWNER TO spk_user;

--
-- Name: screening_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.screening_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.screening_sessions_id_seq OWNER TO spk_user;

--
-- Name: screening_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.screening_sessions_id_seq OWNED BY public.screening_sessions.id;


--
-- Name: sdq_screenings; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.sdq_screenings (
    id bigint NOT NULL,
    screening_session_id bigint NOT NULL,
    answers jsonb NOT NULL,
    emotional_score smallint NOT NULL,
    conduct_score smallint NOT NULL,
    hyperactivity_score smallint NOT NULL,
    peer_score smallint NOT NULL,
    total_difficulties_score smallint NOT NULL,
    prosocial_score smallint NOT NULL,
    total_difficulties_category character varying(30) NOT NULL,
    prosocial_category character varying(30) NOT NULL,
    recommendation text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    emotional_category character varying(30) NOT NULL,
    conduct_category character varying(30) NOT NULL,
    hyperactivity_category character varying(30) NOT NULL,
    peer_category character varying(30) NOT NULL,
    CONSTRAINT sdq_screenings_conduct_category_check CHECK (((conduct_category)::text = ANY ((ARRAY['normal'::character varying, 'ambang_borderline'::character varying, 'abnormal'::character varying])::text[]))),
    CONSTRAINT sdq_screenings_conduct_score_check CHECK (((conduct_score >= 0) AND (conduct_score <= 10))),
    CONSTRAINT sdq_screenings_emotional_category_check CHECK (((emotional_category)::text = ANY ((ARRAY['normal'::character varying, 'ambang_borderline'::character varying, 'abnormal'::character varying])::text[]))),
    CONSTRAINT sdq_screenings_emotional_score_check CHECK (((emotional_score >= 0) AND (emotional_score <= 10))),
    CONSTRAINT sdq_screenings_hyperactivity_category_check CHECK (((hyperactivity_category)::text = ANY ((ARRAY['normal'::character varying, 'ambang_borderline'::character varying, 'abnormal'::character varying])::text[]))),
    CONSTRAINT sdq_screenings_hyperactivity_score_check CHECK (((hyperactivity_score >= 0) AND (hyperactivity_score <= 10))),
    CONSTRAINT sdq_screenings_peer_category_check CHECK (((peer_category)::text = ANY ((ARRAY['normal'::character varying, 'ambang_borderline'::character varying, 'abnormal'::character varying])::text[]))),
    CONSTRAINT sdq_screenings_peer_score_check CHECK (((peer_score >= 0) AND (peer_score <= 10))),
    CONSTRAINT sdq_screenings_prosocial_category_check CHECK (((prosocial_category)::text = ANY ((ARRAY['normal'::character varying, 'ambang_borderline'::character varying, 'abnormal'::character varying])::text[]))),
    CONSTRAINT sdq_screenings_prosocial_score_check CHECK (((prosocial_score >= 0) AND (prosocial_score <= 10))),
    CONSTRAINT sdq_screenings_total_difficulties_category_check CHECK (((total_difficulties_category)::text = ANY ((ARRAY['normal'::character varying, 'ambang_borderline'::character varying, 'abnormal'::character varying])::text[]))),
    CONSTRAINT sdq_screenings_total_difficulties_score_check CHECK (((total_difficulties_score >= 0) AND (total_difficulties_score <= 40)))
);


ALTER TABLE public.sdq_screenings OWNER TO spk_user;

--
-- Name: sdq_screenings_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.sdq_screenings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sdq_screenings_id_seq OWNER TO spk_user;

--
-- Name: sdq_screenings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.sdq_screenings_id_seq OWNED BY public.sdq_screenings.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO spk_user;

--
-- Name: srq_screenings; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.srq_screenings (
    id bigint NOT NULL,
    screening_session_id bigint NOT NULL,
    answers jsonb NOT NULL,
    score smallint NOT NULL,
    category character varying(50) NOT NULL,
    recommendation text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    depression_score smallint DEFAULT '0'::smallint NOT NULL,
    anxiety_score smallint DEFAULT '0'::smallint NOT NULL,
    somatic_score smallint DEFAULT '0'::smallint NOT NULL,
    cognitive_score smallint DEFAULT '0'::smallint NOT NULL,
    energy_score smallint DEFAULT '0'::smallint NOT NULL,
    CONSTRAINT srq_screenings_anxiety_score_check CHECK (((anxiety_score >= 0) AND (anxiety_score <= 3))),
    CONSTRAINT srq_screenings_category_check CHECK (((category)::text = ANY ((ARRAY['di_bawah_nilai_pisah'::character varying, 'gangguan_mental_emosional_distres'::character varying])::text[]))),
    CONSTRAINT srq_screenings_cognitive_score_check CHECK (((cognitive_score >= 0) AND (cognitive_score <= 3))),
    CONSTRAINT srq_screenings_depression_score_check CHECK (((depression_score >= 0) AND (depression_score <= 7))),
    CONSTRAINT srq_screenings_energy_score_check CHECK (((energy_score >= 0) AND (energy_score <= 6))),
    CONSTRAINT srq_screenings_score_check CHECK (((score >= 0) AND (score <= 20))),
    CONSTRAINT srq_screenings_somatic_score_check CHECK (((somatic_score >= 0) AND (somatic_score <= 4)))
);


ALTER TABLE public.srq_screenings OWNER TO spk_user;

--
-- Name: srq_screenings_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.srq_screenings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.srq_screenings_id_seq OWNER TO spk_user;

--
-- Name: srq_screenings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.srq_screenings_id_seq OWNED BY public.srq_screenings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: spk_user
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    role_id bigint NOT NULL
);


ALTER TABLE public.users OWNER TO spk_user;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: spk_user
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO spk_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spk_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: doctors id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.doctors ALTER COLUMN id SET DEFAULT nextval('public.doctors_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: gpph_screenings id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.gpph_screenings ALTER COLUMN id SET DEFAULT nextval('public.gpph_screenings_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: kpsp_screenings id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.kpsp_screenings ALTER COLUMN id SET DEFAULT nextval('public.kpsp_screenings_id_seq'::regclass);


--
-- Name: mchat_screenings id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.mchat_screenings ALTER COLUMN id SET DEFAULT nextval('public.mchat_screenings_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: nurses id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.nurses ALTER COLUMN id SET DEFAULT nextval('public.nurses_id_seq'::regclass);


--
-- Name: parent_guardians id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.parent_guardians ALTER COLUMN id SET DEFAULT nextval('public.parent_guardians_id_seq'::regclass);


--
-- Name: patients id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.patients ALTER COLUMN id SET DEFAULT nextval('public.patients_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: screening_interpretations id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_interpretations ALTER COLUMN id SET DEFAULT nextval('public.screening_interpretations_id_seq'::regclass);


--
-- Name: screening_session_instruments id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_session_instruments ALTER COLUMN id SET DEFAULT nextval('public.screening_session_instruments_id_seq'::regclass);


--
-- Name: screening_sessions id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_sessions ALTER COLUMN id SET DEFAULT nextval('public.screening_sessions_id_seq'::regclass);


--
-- Name: sdq_screenings id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.sdq_screenings ALTER COLUMN id SET DEFAULT nextval('public.sdq_screenings_id_seq'::regclass);


--
-- Name: srq_screenings id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.srq_screenings ALTER COLUMN id SET DEFAULT nextval('public.srq_screenings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.cache (key, value, expiration) FROM stdin;
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: doctors; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.doctors (id, user_id, specialization, created_at, updated_at) FROM stdin;
1	3	Dokter Anak	2026-11-06 11:05:50	2026-11-06 11:05:50
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- Data for Name: gpph_screenings; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.gpph_screenings (id, screening_session_id, answers, score, examiner_doubtful, category, recommendation, created_at, updated_at) FROM stdin;
1	1	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:50	2026-11-06 11:05:50
2	2	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:50	2026-11-06 11:05:50
3	3	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:50	2026-11-06 11:05:50
4	4	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:50	2026-11-06 11:05:50
5	5	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
6	6	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
7	7	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
8	8	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
9	9	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
10	10	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:51	2026-11-06 11:05:51
11	11	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
12	12	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
13	13	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
14	14	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
15	15	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
16	16	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
17	17	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
18	18	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
19	19	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
20	20	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
21	21	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
22	22	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
23	23	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
24	24	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
25	25	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
26	26	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:51	2026-11-06 11:05:51
27	27	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:51	2026-11-06 11:05:51
28	28	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
29	29	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
30	30	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
31	31	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:51	2026-11-06 11:05:51
32	32	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
33	33	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
34	34	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
35	35	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:51	2026-11-06 11:05:51
36	36	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
37	37	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
38	38	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
39	39	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
40	40	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
41	41	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
42	42	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
43	43	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
44	44	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
45	45	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:51	2026-11-06 11:05:51
46	46	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
47	47	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
48	48	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
49	49	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
50	50	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
51	51	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
52	52	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:51	2026-11-06 11:05:51
53	53	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
54	54	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
55	55	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
56	56	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:51	2026-11-06 11:05:51
57	57	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
58	58	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:51	2026-11-06 11:05:51
59	59	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:51	2026-11-06 11:05:51
60	60	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:51	2026-11-06 11:05:51
61	61	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
62	62	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
63	63	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:52	2026-11-06 11:05:52
64	64	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
65	65	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
66	66	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
67	67	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
68	68	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
69	69	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
70	70	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
71	71	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
72	72	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
73	73	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
74	74	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
75	75	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
76	76	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:52	2026-11-06 11:05:52
77	77	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
78	78	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
79	79	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
80	80	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:52	2026-11-06 11:05:52
81	81	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
82	82	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:52	2026-11-06 11:05:52
83	83	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
84	84	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
85	85	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
86	86	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
87	87	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
88	88	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
89	89	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:52	2026-11-06 11:05:52
90	90	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
91	91	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
92	92	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
93	93	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
94	94	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
95	95	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
96	96	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
97	97	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
98	98	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
99	99	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
100	100	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:52	2026-11-06 11:05:52
101	101	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
102	102	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
103	103	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
104	104	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:52	2026-11-06 11:05:52
105	105	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
106	106	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
107	107	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
108	108	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
109	109	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:52	2026-11-06 11:05:52
110	110	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
111	111	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
112	112	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
113	113	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
114	114	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
115	115	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
116	116	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
117	117	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
118	118	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
119	119	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
120	120	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
121	121	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
122	122	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
123	123	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
124	124	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
125	125	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
126	126	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
127	127	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
128	128	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
129	129	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
130	130	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
131	131	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
132	132	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
133	133	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
134	134	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
135	135	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
136	136	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
137	137	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
138	138	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
139	139	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
140	140	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
141	141	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
142	142	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
143	143	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
144	144	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
145	145	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
146	146	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
147	147	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
148	148	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
149	149	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
150	150	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
151	151	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
152	152	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
153	153	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
154	154	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
155	155	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
156	156	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:53	2026-11-06 11:05:53
157	157	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
158	158	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:53	2026-11-06 11:05:53
159	159	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
160	160	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
161	161	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
162	162	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
163	163	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
164	164	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:54	2026-11-06 11:05:54
165	165	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:54	2026-11-06 11:05:54
166	166	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:54	2026-11-06 11:05:54
167	167	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
168	168	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
169	169	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
170	170	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
171	171	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
172	172	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
173	173	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
174	174	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
175	175	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	4	f	normal	Tidak menunjukkan GPPH.	2026-11-06 11:05:54	2026-11-06 11:05:54
176	176	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]	14	f	kemungkinan_gpph	Terindikasi kemungkinan GPPH, disarankan konsultasi spesialis.	2026-11-06 11:05:54	2026-11-06 11:05:54
177	177	[0, 1, 0, 0, 1, 0, 0, 0, 1, 0]	3	f	normal	Pemusatan perhatian dan aktivitas motorik dalam batas wajar.	2026-11-06 11:05:54	2026-11-06 11:05:54
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
\.


--
-- Data for Name: kpsp_screenings; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.kpsp_screenings (id, screening_session_id, answers, score, category, recommendation, created_at, updated_at, form_age_months, domain_scores, sdidtk_code, clinical_action, is_re_evaluation) FROM stdin;
1	1	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:50	2026-11-06 11:05:50	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
2	2	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:50	2026-11-06 11:05:50	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
3	3	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:50	2026-11-06 11:05:50	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
4	4	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:50	2026-11-06 11:05:50	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
5	5	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:50	2026-11-06 11:05:50	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
6	6	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar"],"optimal_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
7	7	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
8	8	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
9	9	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
10	10	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
11	11	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
12	12	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar"],"all_optimal":false}	\N	\N	f
13	13	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
14	14	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Sosialisasi dan Kemandirian"],"optimal_domains":["Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
15	15	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar"],"all_optimal":false}	\N	\N	f
16	16	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
17	17	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
18	18	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
19	19	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
20	20	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
21	21	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
22	22	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Bicara dan Bahasa"],"optimal_domains":["Gerak Halus","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
23	23	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
24	24	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
25	25	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
26	26	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
27	27	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar"],"optimal_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
28	28	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
29	29	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Bicara dan Bahasa"],"optimal_domains":["Gerak Halus","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
30	30	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
31	31	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
32	32	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
33	33	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
34	34	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar"],"all_optimal":false}	\N	\N	f
35	35	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
36	36	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar"],"optimal_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
37	37	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
38	38	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
39	39	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
40	40	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
41	41	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
42	42	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
43	43	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
44	44	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
45	45	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
46	46	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
47	47	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
48	48	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
49	49	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar"],"all_optimal":false}	\N	\N	f
50	50	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
51	51	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
52	52	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
53	53	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar"],"all_optimal":false}	\N	\N	f
54	54	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
55	55	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
56	56	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	12	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
57	57	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	30	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
58	58	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
59	59	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:51	2026-11-06 11:05:51	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
60	60	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:51	2026-11-06 11:05:51	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
61	61	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
62	62	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
63	63	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
64	64	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
65	65	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
66	66	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
67	67	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
68	68	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
69	69	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
70	70	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
71	71	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
72	72	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
73	73	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
74	74	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
75	75	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
76	76	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
77	77	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar"],"all_optimal":false}	\N	\N	f
78	78	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
79	79	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
80	80	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
81	81	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Halus","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
82	82	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
83	83	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
84	84	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
85	85	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
86	86	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
87	87	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
88	88	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:52	2026-11-06 11:05:52	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
89	89	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
90	90	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
91	91	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
92	92	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
93	93	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
94	94	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	30	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Gerak Halus"],"all_optimal":false}	\N	\N	f
95	95	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
96	96	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
97	97	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
98	98	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Gerak Halus"],"all_optimal":false}	\N	\N	f
99	99	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Halus"],"optimal_domains":["Gerak Kasar","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
100	100	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
101	101	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
102	102	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
103	103	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
104	104	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
105	105	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
106	106	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
107	107	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
108	108	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
109	109	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:52	2026-11-06 11:05:52	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar"],"all_optimal":false}	\N	\N	f
110	110	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
111	111	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
112	112	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
113	113	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
114	114	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
115	115	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
116	116	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
117	117	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
118	118	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
119	119	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar"],"all_optimal":false}	\N	\N	f
120	120	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
121	121	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
122	122	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
123	123	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
124	124	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
125	125	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
126	126	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Halus"],"all_optimal":false}	\N	\N	f
127	127	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
128	128	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
129	129	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
130	130	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Halus"],"optimal_domains":["Gerak Kasar","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
131	131	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
132	132	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
133	133	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
134	134	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
135	135	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
136	136	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Halus","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
137	137	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Sosialisasi dan Kemandirian"],"optimal_domains":["Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
138	138	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
139	139	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	48	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
140	140	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
141	141	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
142	142	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
143	143	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	54	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
144	144	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
145	145	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
146	146	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
147	147	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Bicara dan Bahasa"],"optimal_domains":["Gerak Kasar","Gerak Halus","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
148	148	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Gerak Kasar","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
149	149	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
150	150	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Bicara dan Bahasa"],"optimal_domains":["Gerak Kasar","Gerak Halus","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
151	151	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
152	152	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar"],"all_optimal":false}	\N	\N	f
153	153	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
154	154	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
155	155	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
156	156	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:53	2026-11-06 11:05:53	30	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
157	157	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
158	158	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:53	2026-11-06 11:05:53	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
159	159	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Halus","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
160	160	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
161	161	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Gerak Kasar","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
162	162	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	66	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
163	163	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:54	2026-11-06 11:05:54	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
164	164	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	30	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
165	165	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar"],"optimal_domains":["Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
166	166	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Halus","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
167	167	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Halus"],"optimal_domains":["Gerak Kasar","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
168	168	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:54	2026-11-06 11:05:54	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
169	169	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
170	170	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
171	171	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	42	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
172	172	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan sesuai umur.	2026-11-06 11:05:54	2026-11-06 11:05:54	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
173	173	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":[],"all_optimal":false}	\N	\N	f
174	174	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	42	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa"],"optimal_domains":["Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
175	175	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":3,"total":3,"percentage":100,"status":"sesuai"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":1,"total":2,"percentage":50,"status":"meragukan"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":3,"percentage":33,"status":"meragukan"}},"lacking_domains":["Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Gerak Halus"],"all_optimal":false}	\N	\N	f
176	176	[true, true, true, true, true, true, true, true, true, true]	8	meragukan	Lakukan stimulasi terarah pada domain yang mengalami hambatan.	2026-11-06 11:05:54	2026-11-06 11:05:54	72	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":1,"total":3,"percentage":33,"status":"meragukan"},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":1,"total":2,"percentage":50,"status":"meragukan"},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":2,"total":2,"percentage":100,"status":"sesuai"},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai"}},"lacking_domains":["Gerak Kasar","Gerak Halus"],"optimal_domains":["Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":false}	\N	\N	f
177	177	[true, true, true, true, true, true, true, true, true, true]	10	sesuai_umur	Perkembangan Chairil Rafqi Nababan sesuai usia 60 bulan. Lanjutkan stimulasi rutin di rumah.	2026-11-06 11:05:54	2026-11-06 11:05:54	60	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":2,"total":2,"percentage":100,"status":"sesuai","status_label":"Sesuai (Optimal)","missed_questions":[]},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai","status_label":"Sesuai (Optimal)","missed_questions":[]},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":3,"total":3,"percentage":100,"status":"sesuai","status_label":"Sesuai (Optimal)","missed_questions":[]},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":3,"total":3,"percentage":100,"status":"sesuai","status_label":"Sesuai (Optimal)","missed_questions":[]}},"lacking_domains":[],"optimal_domains":["Gerak Kasar","Gerak Halus","Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"all_optimal":true}	\N	\N	f
178	178	[true, true, true, true, false, true, true, false, true, true]	8	meragukan	Hasil perkembangan meragukan. Lakukan stimulasi intensif selama 2 minggu dan jadwalkan evaluasi ulang.	2026-11-06 11:05:54	2026-11-06 11:05:54	24	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":2,"total":3,"percentage":66.7,"status":"perlu_stimulasi","status_label":"Perlu Stimulasi","missed_questions":[{"number":8,"text":"Tanyakan kepada orang tua atau pengasuh, apakah anak dapat berjalan naik tangga sen diri? Jawab \\u2018Ya\\u2019 jika ia naik tangga dengan posisi tegak atau berpegangan pada dinding atau pegangan tangga. tangga dengan merangkak, orang tua tidak memperbolehkan anak naik tangga, atau anak harus berpegangan pada seseorang."}]},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai","status_label":"Sesuai (Optimal)","missed_questions":[]},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":3,"total":3,"percentage":100,"status":"sesuai","status_label":"Sesuai (Optimal)","missed_questions":[]},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":2,"percentage":50,"status":"perlu_stimulasi","status_label":"Perlu Stimulasi","missed_questions":[{"number":5,"text":"Tanyakan kepada orang tua atau pengasuh, apakah anak dapat melepas pakaiannya seper ti baju, rok, atau celana?"}]}},"lacking_domains":["Gerak Kasar","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Halus","Bicara dan Bahasa"],"all_optimal":false}	\N	\N	f
179	179	[true, true, true, true, false, true, true, false, true, true]	8	meragukan	Hasil perkembangan meragukan. Lakukan stimulasi intensif selama 2 minggu dan jadwalkan evaluasi ulang.	2026-11-06 11:05:54	2026-11-06 11:05:54	36	{"domains":{"gerak_kasar":{"key":"gerak_kasar","name":"Gerak Kasar","score":2,"total":2,"percentage":100,"status":"sesuai","status_label":"Sesuai (Optimal)","missed_questions":[]},"gerak_halus":{"key":"gerak_halus","name":"Gerak Halus","score":2,"total":2,"percentage":100,"status":"sesuai","status_label":"Sesuai (Optimal)","missed_questions":[]},"bicara_bahasa":{"key":"bicara_bahasa","name":"Bicara dan Bahasa","score":3,"total":4,"percentage":75,"status":"perlu_stimulasi","status_label":"Perlu Stimulasi","missed_questions":[{"number":5,"text":"Tanyakan kepada orang tua atau pengasuh, apakah sebagian dari bicara anak dapat dipa hami oleh orang asing (yang tidak bertemu setiap hari)?"}]},"sosialisasi_kemandirian":{"key":"sosialisasi_kemandirian","name":"Sosialisasi dan Kemandirian","score":1,"total":2,"percentage":50,"status":"perlu_stimulasi","status_label":"Perlu Stimulasi","missed_questions":[{"number":8,"text":"Tanyakan kepada orang tua atau pengasuh, dapatkah anak mengenakan baju, celana, atau sepatu sendiri (tidak termasuk mengancing dan menali)?"}]}},"lacking_domains":["Bicara dan Bahasa","Sosialisasi dan Kemandirian"],"optimal_domains":["Gerak Kasar","Gerak Halus"],"all_optimal":false}	\N	\N	f
\.


--
-- Data for Name: mchat_screenings; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.mchat_screenings (id, screening_session_id, answers, score, category, recommendation, created_at, updated_at) FROM stdin;
1	1	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:50	2026-11-06 11:05:50
2	2	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:50	2026-11-06 11:05:50
3	3	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:50	2026-11-06 11:05:50
4	4	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:50	2026-11-06 11:05:50
5	5	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:50	2026-11-06 11:05:50
6	6	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
7	7	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
8	8	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
9	9	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
10	10	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
11	11	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
12	12	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
13	13	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
14	14	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
15	15	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
16	16	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
17	17	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
18	18	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
19	19	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
20	20	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
21	21	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
22	22	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
23	23	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
24	24	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
25	25	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
26	26	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
27	27	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
28	28	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
29	29	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
30	30	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
31	31	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
32	32	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
33	33	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
34	34	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
35	35	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
36	36	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
37	37	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
38	38	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
39	39	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
40	40	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
41	41	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
42	42	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
43	43	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
44	44	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
45	45	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
46	46	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
47	47	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
48	48	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
49	49	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
50	50	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
51	51	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
52	52	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
53	53	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
54	54	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
55	55	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
56	56	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
57	57	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
58	58	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
59	59	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
60	60	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:51	2026-11-06 11:05:51
61	61	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
62	62	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
63	63	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
64	64	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
65	65	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
66	66	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
67	67	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
68	68	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
69	69	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
70	70	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
71	71	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
72	72	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
73	73	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
74	74	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
75	75	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
76	76	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
77	77	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
78	78	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
79	79	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
80	80	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
81	81	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
82	82	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
83	83	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
84	84	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
85	85	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
86	86	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
87	87	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
88	88	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
89	89	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
90	90	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
91	91	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
92	92	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
93	93	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
94	94	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
95	95	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
96	96	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
97	97	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
98	98	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
99	99	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
100	100	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
101	101	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
102	102	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
103	103	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
104	104	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
105	105	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
106	106	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
107	107	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
108	108	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
109	109	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:52	2026-11-06 11:05:52
110	110	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
111	111	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
112	112	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
113	113	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
153	153	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
114	114	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
115	115	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
116	116	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
117	117	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
118	118	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
119	119	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
120	120	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
121	121	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
122	122	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
123	123	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
124	124	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
125	125	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
126	126	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
127	127	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
128	128	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
129	129	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
130	130	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
131	131	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
132	132	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
133	133	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
134	134	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
135	135	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
136	136	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
137	137	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
138	138	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
139	139	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
140	140	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
141	141	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
142	142	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
143	143	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
144	144	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
145	145	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
146	146	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
147	147	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
148	148	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
149	149	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
150	150	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
151	151	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
152	152	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
154	154	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
155	155	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
156	156	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
157	157	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
158	158	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:53	2026-11-06 11:05:53
159	159	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
160	160	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
161	161	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
162	162	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
163	163	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
164	164	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
165	165	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
166	166	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
167	167	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
168	168	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
169	169	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
170	170	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
171	171	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	5	risiko_sedang_tinggi	Rujuk untuk evaluasi komprehensif spektrum autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
172	172	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
173	173	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
174	174	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
175	175	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
176	176	[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	1	risiko_rendah	Risiko rendah autisme.	2026-11-06 11:05:54	2026-11-06 11:05:54
177	178	[true, false, true, true, false, true, true, true, true, true, true, false, true, true, true, true, true, true, true, true]	0	risiko_rendah	Risiko autisme rendah. Lanjutkan pemantauan tumbuh kembang rutin.	2026-11-06 11:05:54	2026-11-06 11:05:54
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2026_09_25_091729_create_roles_table	1
5	2026_09_25_093009_add_role_id_to_users_table	1
6	2026_09_25_093407_create_parent_guardians_table	1
7	2026_09_25_094141_create_doctors_table	1
8	2026_09_25_094534_create_nurses_table	1
9	2026_09_25_095015_create_patients_table	1
10	2026_09_25_095659_create_screening_sessions_table	1
11	2026_09_25_100301_create_screening_session_instruments_table	1
12	2026_09_25_101244_create_kpsp_screenings_table	1
13	2026_09_25_102958_create_mchat_screenings_table	1
14	2026_09_25_103313_create_gpph_screenings_table	1
15	2026_09_25_103536_create_sdq_screenings_table	1
16	2026_09_25_103750_create_srq_screenings_table	1
17	2026_10_11_112128_add_form_age_months_to_kpsp_screenings_table	1
18	2026_10_11_194920_add_subscale_categories_to_sdq_screenings_table	1
19	2026_10_12_054704_add_created_by_user_id_to_screening_sessions_table	1
20	2026_10_12_080000_create_screening_interpretations_table	1
21	2026_10_19_100000_add_subscale_scores_to_srq_screenings_table	1
22	2026_10_21_180000_add_domain_scores_to_kpsp_screenings_table	1
23	2026_10_21_183000_add_sdidtk_workflow_to_screening_sessions_and_kpsp_table	1
24	2026_11_06_072822_add_monthly_recap_fields_to_patients_and_screening_sessions_table	1
25	2026_11_06_090000_add_school_name_to_patients_table	1
\.


--
-- Data for Name: nurses; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.nurses (id, user_id, registration_number, created_at, updated_at) FROM stdin;
1	2	NURSE-001	2026-11-06 11:05:50	2026-11-06 11:05:50
\.


--
-- Data for Name: parent_guardians; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.parent_guardians (id, user_id, phone, address, created_at, updated_at) FROM stdin;
1	4	080000000000	Data development	2026-11-06 11:05:50	2026-11-06 11:05:50
2	5	081234567890	Balikpapan	2026-11-06 11:05:50	2026-11-06 11:05:50
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.patients (id, parent_guardian_id, medical_record_number, name, birth_date, gender, guardian_relationship, is_premature, gestational_age_weeks, is_active, created_at, updated_at, address, education, school_name) FROM stdin;
1	2	RM-001	Muhammad Zain Ageng Pangestu	2019-08-14	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Al Makmur 2 Blok No. A	tidak_sekolah	\N
2	1	RM-002	Chairil Rafqi Nababan	2021-09-13	L	Ibu	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Karang Jati	sekolah_reguler	TK Tunas Karya
3	2	RM-003	Rychi Yislam Gaza	2023-11-17	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Impres IV No. 62	tidak_sekolah	\N
4	2	RM-004	Nausyad Ezzar A.	2020-02-13	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Jend Sudirman	sekolah_reguler	KB EDELWEIS
5	2	RM-005	Adelio Vember	2022-11-20	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Brantas C Kilo 3	tidak_sekolah	\N
6	2	RM-006	Yara Kinandari Pangestu	2020-05-17	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Palm Hils Batakan	sekolah_reguler	SD 012
7	2	RM-007	Akhtar Syafiqfatz H	2019-09-24	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Jendral Sudirman Markoni	sekolah_reguler	SDN 011
8	2	RM-008	Raja Separagic Perdana	2017-08-14	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Wonorejo RT 36 No. 30	tidak_sekolah	\N
9	2	RM-009	Febian Imanuel	2016-12-07	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Pupuk Timur VI n.3	sekolah_reguler	SD IT AL Aqsa (Rujuk Ggigi Klinik Ibnu Sina)
10	2	RM-010	Muhammad Azka Idzatulhaq	2015-10-01	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Manggar Baru	slb	SLBN 8
11	2	RM-011	Dzaky Al Farizi	2018-11-21	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perumahan Taman Bukit Asri	tidak_sekolah	\N
12	2	RM-012	Reyshaka Oliviera Chiko	2022-07-26	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	JL. MT.Haryono RT 12	tidak_sekolah	\N
13	2	RM-013	Qonitah Mumtazah	2017-12-01	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum PMI Polda	sekolah_reguler	\N
14	2	RM-014	Muhammad Zaydan Abdillah	2022-01-21	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Pelita No. 108	sekolah_reguler	Paud An Nur
15	2	RM-015	Handika Abid Aqila	2015-09-18	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. LKMD Sumber Indah	tidak_sekolah	\N
16	2	RM-016	Raidhika Apriliansyah	2021-04-30	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Telagaga Sari 2 RT 36 No.31	tidak_sekolah	\N
17	2	RM-017	Ghaliya farhana akbar	2019-12-07	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. MT.Haryono RT 24 No.22	sekolah_reguler	KB Cahaya Bintang
18	2	RM-018	Muhammad Kahfi Muin	2017-02-06	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Letjen Suprapto	sekolah_reguler	MI Al Ula
19	2	RM-019	Andi Muhamad  Falih Andi Aqmar	2020-12-20	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Sepinggan Baru no 21 Rt 17	sekolah_reguler	KB Baitul Ilmi
20	2	RM-020	Arfan Nur Zeeshan	2022-06-21	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Pembangunan Rt 24 Kel. Telaga Sari	tidak_sekolah	\N
21	2	RM-021	Hani Putri Sapardiansyah	2019-07-17	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Letjen Soprapto No 4	tidak_sekolah	sd 009 Balikpapan Barat
22	2	RM-022	Arumi Nasya Naina	2020-04-12	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Persatuan Manggar	tidak_sekolah	\N
23	2	RM-023	Muhammad Alzam Raskha	2018-11-20	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Gunung Gungtur	tidak_sekolah	\N
24	2	RM-024	Uwais Al Qarni Ardalefa	2020-04-10	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Jendral Sudirman Klandasan	sekolah_reguler	TK
25	2	RM-025	Muhammad Fahri Muhtarom	2022-10-04	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum. Batakan Mas	tidak_sekolah	\N
26	2	RM-026	Hans Christian Sitorus	2019-07-11	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Grand City	sekolah_reguler	TK/KB Cahaya Andika
27	2	RM-027	Shakila khanza Khairinandika	2018-03-02	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Letjend S. Parman	sekolah_reguler	SDN 026
28	2	RM-028	Keenan Athaya Pradipta	2021-11-17	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Giri Rejo KM. 15  RT 26	tidak_sekolah	\N
29	2	RM-029	Gamaliel Baskara Sulu	2022-06-08	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. S. Parman RT 29	tidak_sekolah	\N
30	2	RM-030	Muhammad Fathan Zen	2021-04-12	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl Pipit 3 No. 58	sekolah_inklusi	\N
31	2	RM-031	Andi Athaar Mappaola	2020-05-27	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum Renosari No. 19	sekolah_reguler	TK Pelangi
32	2	RM-032	Xabier Adham Rafidzky	2022-11-19	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. AW Syahrani RT 31	tidak_sekolah	\N
33	2	RM-033	Kaizi Akalanka	2021-05-07	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	JL. MT Bubutan No. 17 RT 15	tidak_sekolah	\N
34	2	RM-034	Rico Argani Davanka	2021-08-05	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Belibis V No. 10	sekolah_reguler	TK Pembina 1
35	2	RM-035	Muhammad Faaz Adza A	2023-08-08	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. 21 Januari rt 09	tidak_sekolah	\N
36	2	RM-036	Elvano Hisyam	2020-06-03	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Serindit 3 No. 78	sekolah_reguler	TK Pembina
37	2	RM-037	Tafne Sashenka	2020-01-11	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Wika BR 6	sekolah_reguler	KB
38	2	RM-038	Eko Yudho Purnomo	2022-07-07	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. W. Mongonsidi RT 21	tidak_sekolah	\N
39	2	RM-039	Muhammad Sultan Al Fatih	2022-07-02	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. DI Panjaitan RT 26 NO. 59	tidak_sekolah	\N
40	2	RM-040	Qarizh Alfarizqy	2020-02-26	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Indrakila rt 56	sekolah_reguler	Tk Bitul Ilmi
41	2	RM-041	Azka Maulana Risman	2018-10-13	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perumahan Batakan Asri	sekolah_reguler	SD 012
42	2	RM-042	Muhammad Ikhwan Ma'ruf	2017-10-15	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Sungai Ampal	tidak_sekolah	\N
43	2	RM-043	Arsene Rodrigo Nathaniel	2021-02-01	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Gunung Rejo No. 20	sekolah_inklusi	TK. Golden
44	2	RM-044	Muhammad Azka Pratama	2021-03-10	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Pemuda RT. 10 No. 60	tidak_sekolah	\N
45	2	RM-045	Muhammad Zaky Alfarizqi	2020-02-29	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum Batuah	tidak_sekolah	\N
46	2	RM-046	Sarfraz El Mavis Jevera	2021-03-14	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. M. Iswahyudi RT. 05	tidak_sekolah	\N
47	2	RM-047	Hafidz Khalish Shadiq	2020-11-23	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	PJHI RT 14 Balikpapan	sekolah_reguler	TK
48	2	RM-048	Maiza Azkia  Hanan	2022-03-22	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Sepinggan	sekolah_reguler	Paud Qurota
49	2	RM-049	Muhammad Syauqi Tsaqib	2020-01-14	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Flamboyan No.11 Gunung Sari Ilir	sekolah_reguler	TK IT Alfatihah
50	2	RM-050	Muhammad Amran Syabani	2019-09-18	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Memtari Village KM 21	tidak_sekolah	\N
51	2	RM-051	Muzaki Kato Abzaar	2021-06-21	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Penegak Rt 7	tidak_sekolah	\N
52	2	RM-052	Adam Khalaf Murtazam	2019-05-19	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perumahan Batakan Asri II	sekolah_reguler	TK Al-Qomar
53	2	RM-053	Ervan Hafidz Athallah	2024-07-17	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Gunung Rejo	tidak_sekolah	\N
54	2	RM-054	Keenan Damario	2015-12-29	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. RE Martadinata	tidak_sekolah	\N
55	2	RM-055	Zionel Matthew Nainggolan	2022-03-02	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Agung Tunggal No 2	tidak_sekolah	\N
56	2	RM-056	Raden Ghania Zakeisha	2024-12-03	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum. Balikpapan Kota Blok A/2	tidak_sekolah	\N
57	2	RM-057	Samudra Arkhananta	2024-01-17	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Karang Jawa	tidak_sekolah	\N
58	2	RM-058	Fatimah AlFaqih	2019-03-25	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perumahan Batu Ampar	tidak_sekolah	\N
59	2	RM-059	Nussa Azru Putra Theo	2021-06-13	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Wanayasa KM. 10 rt 43	tidak_sekolah	\N
60	2	RM-060	David Fadillah Rizqia	2019-10-25	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Mulawarman gg Indah	sekolah_reguler	TK
61	2	RM-061	Yislam Wibisono	2022-01-29	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Penegak Rt 08	sekolah_reguler	Paud Teratai 3
62	2	RM-062	Muhammad Rif'at Syabil	2021-06-18	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Gg. Polda	tidak_sekolah	\N
63	2	RM-063	Syafiyyah Nadhifa Susanto	2021-06-10	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	JL.Manuntung 1 Blok C1	tidak_sekolah	\N
64	2	RM-064	Khalid Abyan hakim	2018-12-07	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Suka Maju Penajam	sekolah_reguler	TK Dianugraha Penajam
65	2	RM-065	Ahmad Hasyim	2015-12-23	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Green Valley	sekolah_reguler	MI Al Muttaqien
66	2	RM-066	Rafanza Rafka Rumangit	2021-08-09	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Klamono 1	tidak_sekolah	\N
67	2	RM-067	Ananda Rangga Mahesa	2018-10-29	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Sepaku gg Utama	tidak_sekolah	\N
68	2	RM-068	Fatia Zefanya Az Zahrah	2021-06-05	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. A.W Syahrani RT 001	tidak_sekolah	TK Harapan
69	2	RM-069	Nadira Humaira	2018-09-09	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Manggar Baru	sekolah_reguler	TK Mawar Merah
70	2	RM-070	Zayn Malik Achmad	2020-09-30	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Griya Telaga Mas	tidak_sekolah	\N
71	2	RM-071	Hameez Bilal Prakoso	2020-12-11	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum BDI 1 Blok III/13	tidak_sekolah	\N
72	2	RM-072	Raffasya al farizi	2022-06-20	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum. Jakarta Regency Gardenia B.22	sekolah_reguler	Paud
73	2	RM-073	Nabil Mahrez Yuke Aswangga	2019-12-26	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Sulawesi No. 05 RT 60	sekolah_reguler	KB Taman ceria km 7
74	2	RM-074	Farid Alfarizqi	2022-03-15	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Pandan Arum	sekolah_reguler	TK Manuntung
75	2	RM-075	Kaisan Al-Rahman Handoyo	2021-03-20	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Siaga No. 20	tidak_sekolah	\N
76	2	RM-076	Sakhi Nalendra Akhtar	2021-10-13	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Strat 3	tidak_sekolah	\N
77	2	RM-077	Queenzha Khumaira	2023-08-26	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Sepinggan Baru RT 49	tidak_sekolah	\N
78	2	RM-078	Faizan sanjaya resi	2023-11-06	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Manggar Baru	tidak_sekolah	\N
79	2	RM-079	Gala Bantala Pratama	2024-07-19	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl.Rengganis	tidak_sekolah	\N
80	2	RM-080	Andi Afiyah Salimah Arindra	2019-06-19	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Samboja Km 30	tidak_sekolah	\N
81	2	RM-081	Al Zidan Arikaisyah	2020-01-19	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Serobong RT 12 No. 43	sekolah_reguler	TK.Cempaka
82	2	RM-082	Kyomi Isaura Febriel	2021-08-07	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Wika BR 5/12	sekolah_reguler	Mitta School
83	2	RM-083	Muhammad Assajid Devian	2022-03-23	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Sepinggan Asri	sekolah_reguler	Toodler Class
84	2	RM-084	Rizky Tian Ramadhan	2020-04-30	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum Batuah	tidak_sekolah	\N
85	2	RM-085	Maisara Azkadina	2020-01-22	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	JL. LKMD Blok K3 No. 15	sekolah_reguler	\N
86	2	RM-086	Reza Rafli Nugraha	2016-12-14	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Siaga Dalam No. 21	sekolah_reguler	SD 012 Balikpapan Kota
87	2	RM-087	Elvano Farhan	2020-07-31	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	MT Haryono	tidak_sekolah	\N
88	2	RM-088	Adnan Maliki Subakti	2021-03-16	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Mulawarman Manggar	tidak_sekolah	RQ
89	2	RM-089	Alles Bassamah	2020-03-28	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Sepinggan Baru	tidak_sekolah	\N
90	2	RM-090	Nicky Canal	2020-02-06	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. MT Haryono RT 12	sekolah_reguler	TK Islam Al Azhar
91	2	RM-091	Zayyan Ashraf Alfarizqi	2022-05-15	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Soekarno Hatta KM 21	tidak_sekolah	\N
92	2	RM-092	Amoereza Mireia P	2021-08-27	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Telaga Sari 3 Nomor 39	tidak_sekolah	\N
93	2	RM-093	Timothy Emmanuel Tasin	2019-12-31	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Daksa	sekolah_reguler	PAUD Baitul Ilmi
94	2	RM-094	Kalista Adriana Siregar	2024-01-20	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Balikpapan Baru Blok G3/22	tidak_sekolah	\N
95	2	RM-095	Anugrah Maher Z	2019-01-29	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Pipit BDS	sekolah_reguler	tk/paud
96	2	RM-096	Muhammad Dirgantara Permadi	2022-01-12	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. AMD No. 36	tidak_sekolah	\N
97	2	RM-097	Iyas Al Muzami	2019-06-06	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Sulawesi Rt 34	sekolah_reguler	TK Gemilang
98	2	RM-098	Zakaria Abdurrazzaq	2023-06-01	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl.  RE Martadinata RT4	tidak_sekolah	\N
99	2	RM-099	Aruna Meera Putri Wahyudi	2022-04-14	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Gurinda V RT 42 Gunung Samarinda	tidak_sekolah	\N
100	2	RM-100	Maliq Ramiro Ahmad	2020-09-30	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum Pesona Bukit Batuah	tidak_sekolah	\N
101	2	RM-101	Quinnsha Qiana Qalesya	2018-08-25	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Syarifuddin Yoes Rt 15	sekolah_reguler	SDN 016 Balikpapan
102	2	RM-102	Diwangkara Abyad Arroqou	2016-12-07	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Pupuk Timur VI	sekolah_reguler	SD IT AL Aqsa
103	2	RM-103	Abdul Khalid	2020-04-19	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Al Falah RT. 36	sekolah_reguler	TK
104	2	RM-104	Uwais Al fathan	2021-12-13	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Sepinggan Baru I	tidak_sekolah	\N
105	2	RM-105	Muhammad Kenzi Arshaka	2020-10-24	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Safir 3 No. 21 Rt 36	tidak_sekolah	\N
106	2	RM-106	Agus Setiawan	2026-08-01	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. MT Haryono	tidak_sekolah	\N
107	2	RM-107	Rara Hama Tangguh	2020-10-20	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Palm Hils	tidak_sekolah	\N
108	2	RM-108	Muhammad Kenzo Arshaka	2020-10-24	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl.Bukit Damai Lestari	tidak_sekolah	\N
109	2	RM-109	Muh. Yahya An Nazmi	2021-12-01	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Rohani No 30 Rt 05	tidak_sekolah	\N
110	2	RM-110	Muhammad Zafran wibaskara	2021-11-01	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum. Batuah blok CD. No 44	tidak_sekolah	\N
111	2	RM-111	Rafa Putra Wijaya	2019-07-14	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Wono Agung No.30	sekolah_reguler	\N
112	2	RM-112	Medina Sevim Zeanissa	2020-05-29	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. 21 Januari Rt 48	tidak_sekolah	\N
113	2	RM-113	Syaqila Shabihah	2021-02-25	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Bunga Rampai	tidak_sekolah	CP
114	2	RM-114	Muhammad Alvin Djahir	2019-03-01	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Tiga No 5	sekolah_reguler	\N
115	2	RM-115	Muhammad Shakti Maulana Irhamsyah	2022-02-03	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Blora I RT. 21	tidak_sekolah	\N
116	2	RM-116	Nallendra zavier Elvino Munzir	2020-12-26	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Gn. Empat	tidak_sekolah	\N
117	2	RM-117	Hanif Khalis Khadif	2020-07-23	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. PJHI rt 14 No 39	sekolah_reguler	TK Al Qomar
118	2	RM-118	Shafiqa Ariqah Farzana	2018-08-25	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Mayjend Sutoyo	sekolah_reguler	TK Salman Alfarisi
119	2	RM-119	Muhammad Arshaka Alfahrizki	2021-10-22	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Kampung baru	sekolah_reguler	Paud Teratai
120	2	RM-120	Muhammad Alfahreza Ramadhan	2019-05-28	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Arjuna No 51	sekolah_reguler	SKB Balikpapan Utara
121	2	RM-121	Maryam Nafisa	2018-03-29	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Serindit 4 No. 20	sekolah_reguler	KBBI
122	2	RM-122	Aminatul Azizah	2020-05-14	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl.Letjend Suorapto	tidak_sekolah	\N
123	2	RM-123	Eben Maruli Tampubolon	2021-10-06	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Mulawarman No.34	tidak_sekolah	\N
124	2	RM-124	Ray Gemilang Ramadhan	2018-05-25	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Batakan	tidak_sekolah	\N
125	2	RM-125	Almira Anandita Kirani	2019-10-09	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Baru Ulu	sekolah_reguler	TK Gemilang
126	2	RM-126	Daztan Maulana Putra	2023-11-17	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Mayjend Sutoyo	tidak_sekolah	\N
127	2	RM-127	Rahmat Arayan	2018-08-02	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Sepinggan Rt 08	tidak_sekolah	\N
128	2	RM-128	Rafi alfatah	2018-08-02	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Sepinggan Rt 08	sekolah_reguler	\N
129	2	RM-129	Muhammad Kenzo Narendra	2021-08-14	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Gang Dahlin Gunung Sari	sekolah_reguler	Paud Primananda
130	2	RM-130	Muhammad El Fathan	2022-01-20	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Letjend Suprapto	sekolah_reguler	SKB Balikpapan Barat
131	2	RM-131	Andrea Pirlo Winston Tandibua	2022-04-17	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	BDS 2	tidak_sekolah	\N
132	2	RM-132	Alesha Adelia Prayoga	2022-11-05	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum Kartini Raisidence	sekolah_reguler	Edelweis
133	2	RM-133	Arkana Zhafran Darmawan	2021-05-24	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. AMD Imat Sali No 47	sekolah_reguler	tk Al Muharram
134	2	RM-134	Muhammad Nabil Hibatullah	2020-01-23	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Padat Karya 4	sekolah_reguler	TK BAP 02 BALTIM
135	2	RM-135	Ahmad Fauzan Syafitrah	2020-05-25	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Sultan Hassanudin	tidak_sekolah	\N
136	2	RM-136	Muhammad Giovan Atharrazka	2021-05-28	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Kelurahan Damai Habagia 2, Rt 27	tidak_sekolah	\N
137	2	RM-137	Syeira Elvina Nuwaira	2024-09-04	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Rengganis Blok 6B	tidak_sekolah	\N
138	2	RM-138	Zia Ehsan Abrar	2019-02-12	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Martadinata No. 35	sekolah_reguler	SD 014
139	2	RM-139	M. Zaid Alzam Azzami	2021-02-12	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Prona 1	tidak_sekolah	\N
140	2	RM-140	Ibadurrohman	2020-09-11	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Penggalang No. 87	tidak_sekolah	\N
141	2	RM-141	Yaza Al Ishaq Amrullah	2022-11-06	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Telindung No. 172	sekolah_reguler	KB Baitul Ilmi
142	2	RM-142	Muhammad Azam Al Ghazali	2022-01-18	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Batu pirus, perusda	tidak_sekolah	\N
143	2	RM-143	Alkhalifi Rifatul Taqawa	2021-11-01	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. AMD km 16	tidak_sekolah	\N
144	2	RM-144	Canavarro Ezra Timothy	2017-11-10	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. PT Her 2	sekolah_reguler	SDN 010
145	2	RM-145	Zabran  Ajjila Razka	2023-09-25	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	JL. Suka Asri RT 7 No. 40	tidak_sekolah	\N
146	2	RM-146	Muhammad Hanif Al Fatih	2020-06-11	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Bonto Bulaeng No. 32	sekolah_reguler	Paud Puspita
147	2	RM-147	Muhammad Rafandra A.Y	2015-10-21	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum Pesona Bukit Batuah	sekolah_reguler	SD 002 Balikpapan Utara
148	2	RM-148	Muhammad Raizel Kenideval Diputra	2020-01-27	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Penggalang Gg Pramuka	tidak_sekolah	\N
149	2	RM-149	Syafa Nur Aulia	2018-03-01	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	JL. Tepo KM 10	sekolah_reguler	SDN 025
150	2	RM-150	Naura Azzahrah Almahyra M	2023-05-26	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Pelangi Metro Residene G11	tidak_sekolah	\N
151	2	RM-151	Muhammad Cemal Al Emrys	2019-11-09	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Meyjend Sutoyo	sekolah_reguler	PKBM
152	2	RM-152	Rizaidan Fathariano F	2023-11-14	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Sumberejo V Gang Timur	tidak_sekolah	\N
153	2	RM-153	Muhammad Alvarendra Colle	2023-11-18	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Perum Pesona Bukit Batua	tidak_sekolah	\N
154	2	RM-154	Muhammad Ali Abidin Rahmatullah	2017-09-06	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Pelayaran RT 12	sekolah_reguler	SD Muhammadiyah 1
155	2	RM-155	Nazriel Attaya Khalfani	2019-07-25	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Taman Sepinggan RT 33	sekolah_reguler	SD 004 Balikpapan Selatan
156	2	RM-156	Ryuga Rayyan Abbas	2024-03-25	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Padat Karya No. 13	tidak_sekolah	\N
157	2	RM-157	Agnes Elva Pangestu	2023-08-30	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Batakan	tidak_sekolah	\N
158	2	RM-158	Khalid	2019-06-03	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Markoni	sekolah_reguler	TK Anggrek Markoni
159	2	RM-159	Andi Muhammad Daffa	2020-02-24	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Indrakila	sekolah_reguler	\N
160	2	RM-160	Muhammad Ibrahim Hafidz Muslim	2026-09-23	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	KampungTimur (Perum Ar Raudah)	sekolah_reguler	TK Khalifah
161	2	RM-161	Azalea Adriela W	2019-05-28	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Projakal Gang Semangka	sekolah_reguler	TK Mandaya
162	2	RM-162	Rizka Fitri Ramadhan	2021-04-15	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Pesona Bukit Batuah	sekolah_reguler	TK Momy 2
163	2	RM-163	Arvino Abisatya Mainu	2021-10-19	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Bhineka RT 30	tidak_sekolah	\N
164	2	RM-164	Aqsa Alvarendra Mainu	2023-12-28	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Bhineka RT 30	tidak_sekolah	\N
165	2	RM-165	Muhammad Fahrul Arya Putra Rachim	2019-09-27	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Bantopbulaeng RT 0 1	sekolah_reguler	sd 028 balikpapan tengah
166	2	RM-166	Safraz Malik Zubair	2024-05-12	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Ar Rahman	tidak_sekolah	\N
167	2	RM-167	Muhammad Maulansyah Al Fatih	2017-09-15	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Antasari No. 20	sekolah_reguler	SD 005
168	2	RM-168	Arsene Faeyza Zulkarnaen	2018-01-08	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl.Gn Malang RT 51	sekolah_reguler	SD 11 Balikpapan Kota
169	2	RM-169	Razan Ammar	2022-12-21	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Graha Indah	sekolah_reguler	Rumah Tilawati
170	2	RM-170	Fatka Alesha G	2019-05-08	P	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Persatuan Manggar	sekolah_reguler	MI Melati 1
171	2	RM-171	Mahesa Elfathan	2022-12-24	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Persatuan Manggar	sekolah_reguler	KB Mawar Putih
172	2	RM-172	Raid Ammar Rifqi Syahputra	2019-03-24	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Indrakila Gg Satria	sekolah_reguler	Nurul Fikri
173	2	RM-173	Rafly Nur Rahmat	2019-09-06	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl, Jendral Sudirman	sekolah_reguler	SD 011
174	2	RM-174	Mahren Mecca S	2022-12-02	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	jL. 21 Januari Kampung Baru	tidak_sekolah	\N
175	2	RM-175	Emran Khalid	2024-08-01	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Karang Jati Dalam	tidak_sekolah	\N
176	2	RM-176	Abyan Ismail Rizky	2017-07-19	L	Orang Tua	f	\N	t	2026-11-06 11:05:50	2026-11-06 11:05:50	Jl. Imus Payau RT 32 No. 19	sekolah_reguler	SD019 Balikpapan Utara
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.roles (id, name, created_at, updated_at) FROM stdin;
1	administrator	2026-11-06 11:05:49	2026-11-06 11:05:49
2	perawat	2026-11-06 11:05:49	2026-11-06 11:05:49
3	dokter	2026-11-06 11:05:49	2026-11-06 11:05:49
4	orang_tua	2026-11-06 11:05:49	2026-11-06 11:05:49
\.


--
-- Data for Name: screening_interpretations; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.screening_interpretations (id, screening_session_id, instrument_code, doctor_id, clinical_notes, follow_up_decision, follow_up_notes, status, completed_at, created_at, updated_at) FROM stdin;
1	1	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-01 02:00:00	2026-11-06 11:05:50	2026-11-06 11:05:50
2	2	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-01 02:00:00	2026-11-06 11:05:50	2026-11-06 11:05:50
3	3	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-01 02:00:00	2026-11-06 11:05:50	2026-11-06 11:05:50
4	4	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-01 02:00:00	2026-11-06 11:05:50	2026-11-06 11:05:50
5	5	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-01 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
6	6	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-01 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
7	7	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-01 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
8	8	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-02 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
9	9	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-02 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
10	10	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-02 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
11	11	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-02 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
12	12	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-02 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
13	13	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-02 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
14	14	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-03 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
15	15	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-03 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
16	16	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-03 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
17	17	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-03 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
18	18	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-03 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
19	19	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-03 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
20	20	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-04 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
21	21	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-04 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
22	22	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-04 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
23	23	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-04 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
24	24	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-04 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
25	25	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-04 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
26	26	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-05 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
27	27	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-05 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
28	28	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-05 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
29	29	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-05 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
30	30	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-05 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
31	31	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-05 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
32	32	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-06 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
33	33	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-06 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
34	34	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-06 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
35	35	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-06 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
36	36	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-06 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
37	37	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-06 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
38	38	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-07 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
39	39	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-07 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
40	40	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-07 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
41	41	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-07 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
42	42	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-07 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
43	43	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-07 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
44	44	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-08 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
45	45	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-08 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
46	46	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-08 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
47	47	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-08 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
48	48	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-08 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
49	49	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-08 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
50	50	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-09 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
51	51	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-09 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
52	52	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-09 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
53	53	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-09 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
54	54	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-09 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
55	55	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-09 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
56	56	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-10 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
57	57	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-10 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
58	58	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-10 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
59	59	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-10 02:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51
60	60	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-10 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
61	61	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-10 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
62	62	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-11 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
63	63	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-11 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
64	64	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-11 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
65	65	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-11 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
66	66	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-11 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
67	67	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-11 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
68	68	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-12 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
69	69	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-12 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
70	70	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-12 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
71	71	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-12 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
72	72	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-12 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
73	73	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-12 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
74	74	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-13 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
75	75	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-13 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
76	76	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-13 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
77	77	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-13 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
78	78	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-13 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
79	79	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-13 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
80	80	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-14 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
81	81	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-14 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
82	82	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-14 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
83	83	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-14 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
84	84	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-14 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
85	85	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-14 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
86	86	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-15 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
87	87	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-15 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
88	88	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-15 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
89	89	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-15 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
90	90	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-15 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
91	91	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-15 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
92	92	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-15 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
93	93	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-16 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
94	94	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-16 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
95	95	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-16 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
96	96	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-16 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
97	97	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-16 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
98	98	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-16 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
99	99	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-17 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
100	100	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-17 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
101	101	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-17 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
102	102	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-17 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
103	103	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-17 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
104	104	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-17 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
105	105	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-18 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
106	106	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-18 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
107	107	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-18 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
108	108	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-18 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
109	109	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-18 02:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52
110	110	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-18 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
111	111	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-19 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
112	112	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-19 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
113	113	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-19 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
114	114	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-19 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
115	115	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-19 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
116	116	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-19 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
117	117	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-20 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
118	118	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-20 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
119	119	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-20 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
120	120	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-20 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
121	121	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-20 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
122	122	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-20 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
123	123	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-21 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
124	124	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-21 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
125	125	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-21 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
126	126	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-21 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
127	127	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-21 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
128	128	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-21 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
129	129	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-22 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
130	130	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-22 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
131	131	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-22 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
132	132	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-22 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
133	133	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-22 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
134	134	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-22 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
135	135	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-23 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
136	136	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-23 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
137	137	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-23 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
138	138	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-23 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
139	139	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-23 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
140	140	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-23 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
141	141	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-24 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
142	142	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-24 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
143	143	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-24 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
144	144	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-24 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
145	145	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-24 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
146	146	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-24 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
147	147	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-25 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
148	148	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-25 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
149	149	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-25 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
150	150	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-25 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
151	151	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-25 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
152	152	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-25 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
153	153	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-26 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
154	154	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-26 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
155	155	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-26 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
156	156	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-26 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
157	157	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-26 02:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53
158	158	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-26 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
159	159	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-27 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
160	160	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-27 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
161	161	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-27 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
162	162	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-27 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
163	163	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-27 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
164	164	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-27 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
165	165	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-28 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
166	166	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-28 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
167	167	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-28 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
168	168	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-28 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
169	169	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-28 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
170	170	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-28 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
171	171	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-29 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
172	172	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-29 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
173	173	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-29 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
174	174	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-29 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
175	175	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-29 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
176	176	KPSP	1	Tinjauan klinis selesai. Program intervensi disetujui.	konseling_stimulasi	Jadwalkan pemantauan berkala di UPTD BLK-ABK.	completed	2026-10-29 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
177	179	KPSP	1	Hasil KPSP Meragukan (Dm: 8/10). Disarankan intervensi stimulasi dini intensif di rumah selama 2 minggu.	konseling_stimulasi	Jadwalkan evaluasi ulang KPSP 14 hari kemudian.	completed	2026-10-23 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
\.


--
-- Data for Name: screening_session_instruments; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.screening_session_instruments (id, screening_session_id, instrument_code, status, started_at, completed_at, created_at, updated_at) FROM stdin;
1	1	KPSP	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
2	1	MCHAT	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
3	1	GPPH	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
4	1	SDQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
5	1	SRQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
6	2	KPSP	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
7	2	MCHAT	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
8	2	GPPH	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
9	2	SDQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
10	2	SRQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
11	3	KPSP	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
12	3	MCHAT	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
13	3	GPPH	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
14	3	SDQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
15	3	SRQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
16	4	KPSP	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
17	4	MCHAT	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
18	4	GPPH	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
19	4	SDQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
20	4	SRQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
21	5	KPSP	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
22	5	MCHAT	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
23	5	GPPH	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:50	2026-11-06 11:05:50
24	5	SDQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
25	5	SRQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
26	6	KPSP	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
27	6	MCHAT	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
28	6	GPPH	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
29	6	SDQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
30	6	SRQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
31	7	KPSP	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
32	7	MCHAT	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
33	7	GPPH	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
34	7	SDQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
35	7	SRQ	completed	2026-09-30 23:00:00	2026-09-30 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
36	8	KPSP	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
37	8	MCHAT	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
38	8	GPPH	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
39	8	SDQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
40	8	SRQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
41	9	KPSP	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
42	9	MCHAT	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
43	9	GPPH	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
44	9	SDQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
45	9	SRQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
46	10	KPSP	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
47	10	MCHAT	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
48	10	GPPH	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
49	10	SDQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
50	10	SRQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
51	11	KPSP	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
52	11	MCHAT	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
53	11	GPPH	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
54	11	SDQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
55	11	SRQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
56	12	KPSP	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
57	12	MCHAT	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
58	12	GPPH	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
59	12	SDQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
60	12	SRQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
61	13	KPSP	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
62	13	MCHAT	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
63	13	GPPH	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
64	13	SDQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
65	13	SRQ	completed	2026-10-01 23:00:00	2026-10-01 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
66	14	KPSP	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
67	14	MCHAT	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
68	14	GPPH	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
69	14	SDQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
70	14	SRQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
71	15	KPSP	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
72	15	MCHAT	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
73	15	GPPH	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
74	15	SDQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
75	15	SRQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
76	16	KPSP	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
77	16	MCHAT	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
78	16	GPPH	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
79	16	SDQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
80	16	SRQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
81	17	KPSP	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
82	17	MCHAT	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
83	17	GPPH	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
84	17	SDQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
85	17	SRQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
86	18	KPSP	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
87	18	MCHAT	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
88	18	GPPH	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
89	18	SDQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
90	18	SRQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
91	19	KPSP	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
92	19	MCHAT	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
93	19	GPPH	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
94	19	SDQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
95	19	SRQ	completed	2026-10-02 23:00:00	2026-10-02 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
96	20	KPSP	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
97	20	MCHAT	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
98	20	GPPH	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
99	20	SDQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
100	20	SRQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
101	21	KPSP	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
102	21	MCHAT	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
103	21	GPPH	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
104	21	SDQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
105	21	SRQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
106	22	KPSP	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
107	22	MCHAT	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
108	22	GPPH	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
109	22	SDQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
110	22	SRQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
111	23	KPSP	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
112	23	MCHAT	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
113	23	GPPH	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
114	23	SDQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
115	23	SRQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
116	24	KPSP	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
117	24	MCHAT	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
118	24	GPPH	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
119	24	SDQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
120	24	SRQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
121	25	KPSP	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
122	25	MCHAT	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
123	25	GPPH	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
124	25	SDQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
125	25	SRQ	completed	2026-10-03 23:00:00	2026-10-03 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
126	26	KPSP	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
127	26	MCHAT	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
128	26	GPPH	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
129	26	SDQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
130	26	SRQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
131	27	KPSP	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
132	27	MCHAT	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
133	27	GPPH	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
134	27	SDQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
135	27	SRQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
136	28	KPSP	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
137	28	MCHAT	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
138	28	GPPH	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
139	28	SDQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
140	28	SRQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
141	29	KPSP	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
142	29	MCHAT	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
143	29	GPPH	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
144	29	SDQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
145	29	SRQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
146	30	KPSP	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
147	30	MCHAT	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
148	30	GPPH	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
149	30	SDQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
150	30	SRQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
151	31	KPSP	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
152	31	MCHAT	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
153	31	GPPH	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
154	31	SDQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
155	31	SRQ	completed	2026-10-04 23:00:00	2026-10-04 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
156	32	KPSP	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
157	32	MCHAT	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
158	32	GPPH	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
159	32	SDQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
160	32	SRQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
161	33	KPSP	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
162	33	MCHAT	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
163	33	GPPH	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
164	33	SDQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
165	33	SRQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
166	34	KPSP	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
167	34	MCHAT	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
168	34	GPPH	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
169	34	SDQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
170	34	SRQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
171	35	KPSP	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
172	35	MCHAT	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
173	35	GPPH	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
174	35	SDQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
175	35	SRQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
176	36	KPSP	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
177	36	MCHAT	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
178	36	GPPH	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
179	36	SDQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
180	36	SRQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
181	37	KPSP	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
182	37	MCHAT	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
183	37	GPPH	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
184	37	SDQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
185	37	SRQ	completed	2026-10-05 23:00:00	2026-10-05 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
186	38	KPSP	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
187	38	MCHAT	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
188	38	GPPH	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
189	38	SDQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
190	38	SRQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
191	39	KPSP	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
192	39	MCHAT	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
193	39	GPPH	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
194	39	SDQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
195	39	SRQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
196	40	KPSP	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
197	40	MCHAT	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
198	40	GPPH	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
199	40	SDQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
200	40	SRQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
201	41	KPSP	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
202	41	MCHAT	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
203	41	GPPH	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
204	41	SDQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
205	41	SRQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
206	42	KPSP	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
207	42	MCHAT	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
208	42	GPPH	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
209	42	SDQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
210	42	SRQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
211	43	KPSP	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
212	43	MCHAT	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
213	43	GPPH	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
214	43	SDQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
215	43	SRQ	completed	2026-10-06 23:00:00	2026-10-06 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
216	44	KPSP	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
217	44	MCHAT	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
218	44	GPPH	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
219	44	SDQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
220	44	SRQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
221	45	KPSP	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
222	45	MCHAT	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
223	45	GPPH	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
224	45	SDQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
225	45	SRQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
226	46	KPSP	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
227	46	MCHAT	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
228	46	GPPH	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
229	46	SDQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
230	46	SRQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
231	47	KPSP	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
232	47	MCHAT	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
233	47	GPPH	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
234	47	SDQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
235	47	SRQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
236	48	KPSP	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
237	48	MCHAT	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
238	48	GPPH	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
239	48	SDQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
240	48	SRQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
241	49	KPSP	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
242	49	MCHAT	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
243	49	GPPH	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
244	49	SDQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
245	49	SRQ	completed	2026-10-07 23:00:00	2026-10-07 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
246	50	KPSP	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
247	50	MCHAT	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
248	50	GPPH	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
249	50	SDQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
250	50	SRQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
251	51	KPSP	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
252	51	MCHAT	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
253	51	GPPH	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
254	51	SDQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
255	51	SRQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
256	52	KPSP	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
257	52	MCHAT	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
258	52	GPPH	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
259	52	SDQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
260	52	SRQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
261	53	KPSP	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
262	53	MCHAT	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
263	53	GPPH	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
264	53	SDQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
265	53	SRQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
266	54	KPSP	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
267	54	MCHAT	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
268	54	GPPH	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
269	54	SDQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
270	54	SRQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
271	55	KPSP	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
272	55	MCHAT	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
273	55	GPPH	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
274	55	SDQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
275	55	SRQ	completed	2026-10-08 23:00:00	2026-10-08 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
276	56	KPSP	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
277	56	MCHAT	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
278	56	GPPH	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
279	56	SDQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
280	56	SRQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
281	57	KPSP	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
282	57	MCHAT	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
283	57	GPPH	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
284	57	SDQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
285	57	SRQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
286	58	KPSP	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
287	58	MCHAT	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
288	58	GPPH	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
289	58	SDQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
290	58	SRQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
291	59	KPSP	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
292	59	MCHAT	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
293	59	GPPH	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
294	59	SDQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
295	59	SRQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
296	60	KPSP	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
297	60	MCHAT	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
298	60	GPPH	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
299	60	SDQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:51	2026-11-06 11:05:51
300	60	SRQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
301	61	KPSP	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
302	61	MCHAT	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
303	61	GPPH	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
304	61	SDQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
305	61	SRQ	completed	2026-10-09 23:00:00	2026-10-09 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
306	62	KPSP	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
307	62	MCHAT	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
308	62	GPPH	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
309	62	SDQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
310	62	SRQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
311	63	KPSP	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
312	63	MCHAT	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
313	63	GPPH	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
314	63	SDQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
315	63	SRQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
316	64	KPSP	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
317	64	MCHAT	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
318	64	GPPH	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
319	64	SDQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
320	64	SRQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
321	65	KPSP	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
322	65	MCHAT	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
323	65	GPPH	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
324	65	SDQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
325	65	SRQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
326	66	KPSP	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
327	66	MCHAT	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
328	66	GPPH	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
329	66	SDQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
330	66	SRQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
331	67	KPSP	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
332	67	MCHAT	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
333	67	GPPH	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
334	67	SDQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
335	67	SRQ	completed	2026-10-10 23:00:00	2026-10-10 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
336	68	KPSP	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
337	68	MCHAT	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
338	68	GPPH	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
339	68	SDQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
340	68	SRQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
341	69	KPSP	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
342	69	MCHAT	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
343	69	GPPH	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
344	69	SDQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
345	69	SRQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
346	70	KPSP	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
347	70	MCHAT	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
348	70	GPPH	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
349	70	SDQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
350	70	SRQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
351	71	KPSP	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
352	71	MCHAT	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
353	71	GPPH	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
354	71	SDQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
355	71	SRQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
356	72	KPSP	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
357	72	MCHAT	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
358	72	GPPH	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
359	72	SDQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
360	72	SRQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
361	73	KPSP	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
362	73	MCHAT	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
363	73	GPPH	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
364	73	SDQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
365	73	SRQ	completed	2026-10-11 23:00:00	2026-10-11 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
366	74	KPSP	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
367	74	MCHAT	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
368	74	GPPH	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
369	74	SDQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
370	74	SRQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
371	75	KPSP	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
372	75	MCHAT	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
373	75	GPPH	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
374	75	SDQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
375	75	SRQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
376	76	KPSP	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
377	76	MCHAT	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
378	76	GPPH	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
379	76	SDQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
380	76	SRQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
381	77	KPSP	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
382	77	MCHAT	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
383	77	GPPH	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
384	77	SDQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
385	77	SRQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
386	78	KPSP	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
387	78	MCHAT	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
388	78	GPPH	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
389	78	SDQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
390	78	SRQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
391	79	KPSP	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
392	79	MCHAT	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
393	79	GPPH	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
394	79	SDQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
395	79	SRQ	completed	2026-10-12 23:00:00	2026-10-12 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
396	80	KPSP	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
397	80	MCHAT	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
398	80	GPPH	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
399	80	SDQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
400	80	SRQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
401	81	KPSP	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
402	81	MCHAT	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
403	81	GPPH	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
404	81	SDQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
405	81	SRQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
406	82	KPSP	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
407	82	MCHAT	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
408	82	GPPH	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
409	82	SDQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
410	82	SRQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
411	83	KPSP	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
412	83	MCHAT	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
413	83	GPPH	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
414	83	SDQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
415	83	SRQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
416	84	KPSP	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
417	84	MCHAT	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
418	84	GPPH	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
419	84	SDQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
420	84	SRQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
421	85	KPSP	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
422	85	MCHAT	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
423	85	GPPH	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
424	85	SDQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
425	85	SRQ	completed	2026-10-13 23:00:00	2026-10-13 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
426	86	KPSP	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
427	86	MCHAT	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
428	86	GPPH	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
429	86	SDQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
430	86	SRQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
431	87	KPSP	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
432	87	MCHAT	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
433	87	GPPH	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
434	87	SDQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
435	87	SRQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
436	88	KPSP	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
437	88	MCHAT	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
438	88	GPPH	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
439	88	SDQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
440	88	SRQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
441	89	KPSP	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
442	89	MCHAT	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
443	89	GPPH	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
444	89	SDQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
445	89	SRQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
446	90	KPSP	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
447	90	MCHAT	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
448	90	GPPH	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
449	90	SDQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
450	90	SRQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
451	91	KPSP	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
452	91	MCHAT	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
453	91	GPPH	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
454	91	SDQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
455	91	SRQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
456	92	KPSP	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
457	92	MCHAT	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
458	92	GPPH	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
459	92	SDQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
460	92	SRQ	completed	2026-10-14 23:00:00	2026-10-14 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
461	93	KPSP	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
462	93	MCHAT	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
463	93	GPPH	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
464	93	SDQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
465	93	SRQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
466	94	KPSP	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
467	94	MCHAT	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
468	94	GPPH	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
469	94	SDQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
470	94	SRQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
471	95	KPSP	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
472	95	MCHAT	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
473	95	GPPH	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
474	95	SDQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
475	95	SRQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
476	96	KPSP	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
477	96	MCHAT	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
478	96	GPPH	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
479	96	SDQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
480	96	SRQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
481	97	KPSP	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
482	97	MCHAT	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
483	97	GPPH	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
484	97	SDQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
485	97	SRQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
486	98	KPSP	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
487	98	MCHAT	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
488	98	GPPH	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
489	98	SDQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
490	98	SRQ	completed	2026-10-15 23:00:00	2026-10-15 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
491	99	KPSP	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
492	99	MCHAT	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
493	99	GPPH	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
494	99	SDQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
495	99	SRQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
496	100	KPSP	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
497	100	MCHAT	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
498	100	GPPH	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
499	100	SDQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
500	100	SRQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
501	101	KPSP	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
502	101	MCHAT	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
503	101	GPPH	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
504	101	SDQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
505	101	SRQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
506	102	KPSP	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
507	102	MCHAT	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
508	102	GPPH	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
509	102	SDQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
510	102	SRQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
511	103	KPSP	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
512	103	MCHAT	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
513	103	GPPH	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
514	103	SDQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
515	103	SRQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
516	104	KPSP	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
517	104	MCHAT	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
518	104	GPPH	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
519	104	SDQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
520	104	SRQ	completed	2026-10-16 23:00:00	2026-10-16 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
521	105	KPSP	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
522	105	MCHAT	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
523	105	GPPH	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
524	105	SDQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
525	105	SRQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
526	106	KPSP	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
527	106	MCHAT	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
528	106	GPPH	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
529	106	SDQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
530	106	SRQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
531	107	KPSP	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
532	107	MCHAT	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
533	107	GPPH	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
534	107	SDQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
535	107	SRQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
536	108	KPSP	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
537	108	MCHAT	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
538	108	GPPH	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
539	108	SDQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
540	108	SRQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
541	109	KPSP	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
542	109	MCHAT	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
543	109	GPPH	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
544	109	SDQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
545	109	SRQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
546	110	KPSP	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:52	2026-11-06 11:05:52
547	110	MCHAT	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
548	110	GPPH	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
549	110	SDQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
550	110	SRQ	completed	2026-10-17 23:00:00	2026-10-17 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
551	111	KPSP	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
552	111	MCHAT	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
553	111	GPPH	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
554	111	SDQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
555	111	SRQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
556	112	KPSP	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
557	112	MCHAT	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
558	112	GPPH	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
559	112	SDQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
560	112	SRQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
561	113	KPSP	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
562	113	MCHAT	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
563	113	GPPH	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
564	113	SDQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
565	113	SRQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
566	114	KPSP	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
567	114	MCHAT	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
568	114	GPPH	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
569	114	SDQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
570	114	SRQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
571	115	KPSP	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
572	115	MCHAT	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
573	115	GPPH	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
574	115	SDQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
575	115	SRQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
576	116	KPSP	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
577	116	MCHAT	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
578	116	GPPH	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
579	116	SDQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
580	116	SRQ	completed	2026-10-18 23:00:00	2026-10-18 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
581	117	KPSP	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
582	117	MCHAT	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
583	117	GPPH	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
584	117	SDQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
585	117	SRQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
586	118	KPSP	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
587	118	MCHAT	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
588	118	GPPH	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
589	118	SDQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
590	118	SRQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
591	119	KPSP	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
592	119	MCHAT	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
593	119	GPPH	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
594	119	SDQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
595	119	SRQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
596	120	KPSP	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
597	120	MCHAT	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
598	120	GPPH	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
599	120	SDQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
600	120	SRQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
601	121	KPSP	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
602	121	MCHAT	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
603	121	GPPH	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
604	121	SDQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
605	121	SRQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
606	122	KPSP	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
607	122	MCHAT	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
608	122	GPPH	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
609	122	SDQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
610	122	SRQ	completed	2026-10-19 23:00:00	2026-10-19 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
611	123	KPSP	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
612	123	MCHAT	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
613	123	GPPH	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
614	123	SDQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
615	123	SRQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
616	124	KPSP	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
617	124	MCHAT	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
618	124	GPPH	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
619	124	SDQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
620	124	SRQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
621	125	KPSP	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
622	125	MCHAT	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
623	125	GPPH	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
624	125	SDQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
625	125	SRQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
626	126	KPSP	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
627	126	MCHAT	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
628	126	GPPH	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
629	126	SDQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
630	126	SRQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
631	127	KPSP	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
632	127	MCHAT	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
633	127	GPPH	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
634	127	SDQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
635	127	SRQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
636	128	KPSP	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
637	128	MCHAT	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
638	128	GPPH	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
639	128	SDQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
640	128	SRQ	completed	2026-10-20 23:00:00	2026-10-20 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
641	129	KPSP	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
642	129	MCHAT	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
643	129	GPPH	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
644	129	SDQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
645	129	SRQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
646	130	KPSP	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
647	130	MCHAT	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
648	130	GPPH	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
649	130	SDQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
650	130	SRQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
651	131	KPSP	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
652	131	MCHAT	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
653	131	GPPH	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
654	131	SDQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
655	131	SRQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
656	132	KPSP	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
657	132	MCHAT	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
658	132	GPPH	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
659	132	SDQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
660	132	SRQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
661	133	KPSP	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
662	133	MCHAT	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
663	133	GPPH	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
664	133	SDQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
665	133	SRQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
666	134	KPSP	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
667	134	MCHAT	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
668	134	GPPH	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
669	134	SDQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
670	134	SRQ	completed	2026-10-21 23:00:00	2026-10-21 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
671	135	KPSP	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
672	135	MCHAT	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
673	135	GPPH	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
674	135	SDQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
675	135	SRQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
676	136	KPSP	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
677	136	MCHAT	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
678	136	GPPH	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
679	136	SDQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
680	136	SRQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
681	137	KPSP	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
682	137	MCHAT	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
683	137	GPPH	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
684	137	SDQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
685	137	SRQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
686	138	KPSP	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
687	138	MCHAT	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
688	138	GPPH	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
689	138	SDQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
690	138	SRQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
691	139	KPSP	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
692	139	MCHAT	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
693	139	GPPH	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
694	139	SDQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
695	139	SRQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
696	140	KPSP	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
697	140	MCHAT	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
698	140	GPPH	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
699	140	SDQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
700	140	SRQ	completed	2026-10-22 23:00:00	2026-10-22 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
701	141	KPSP	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
702	141	MCHAT	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
703	141	GPPH	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
704	141	SDQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
705	141	SRQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
706	142	KPSP	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
707	142	MCHAT	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
708	142	GPPH	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
709	142	SDQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
710	142	SRQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
711	143	KPSP	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
712	143	MCHAT	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
713	143	GPPH	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
714	143	SDQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
715	143	SRQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
716	144	KPSP	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
717	144	MCHAT	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
718	144	GPPH	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
719	144	SDQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
720	144	SRQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
721	145	KPSP	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
722	145	MCHAT	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
723	145	GPPH	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
724	145	SDQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
725	145	SRQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
726	146	KPSP	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
727	146	MCHAT	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
728	146	GPPH	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
729	146	SDQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
730	146	SRQ	completed	2026-10-23 23:00:00	2026-10-23 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
731	147	KPSP	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
732	147	MCHAT	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
733	147	GPPH	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
734	147	SDQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
735	147	SRQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
736	148	KPSP	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
737	148	MCHAT	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
738	148	GPPH	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
739	148	SDQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
740	148	SRQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
741	149	KPSP	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
742	149	MCHAT	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
743	149	GPPH	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
744	149	SDQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
745	149	SRQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
746	150	KPSP	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
747	150	MCHAT	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
748	150	GPPH	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
749	150	SDQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
750	150	SRQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
751	151	KPSP	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
752	151	MCHAT	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
753	151	GPPH	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
754	151	SDQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
755	151	SRQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
756	152	KPSP	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
757	152	MCHAT	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
758	152	GPPH	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
759	152	SDQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
760	152	SRQ	completed	2026-10-24 23:00:00	2026-10-24 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
761	153	KPSP	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
762	153	MCHAT	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
763	153	GPPH	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
764	153	SDQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
765	153	SRQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
766	154	KPSP	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
767	154	MCHAT	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
768	154	GPPH	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
769	154	SDQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
770	154	SRQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
771	155	KPSP	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
772	155	MCHAT	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
773	155	GPPH	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
774	155	SDQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
775	155	SRQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
776	156	KPSP	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
777	156	MCHAT	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
778	156	GPPH	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
779	156	SDQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
780	156	SRQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
781	157	KPSP	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
782	157	MCHAT	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
783	157	GPPH	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
784	157	SDQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
785	157	SRQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
786	158	KPSP	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
787	158	MCHAT	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
788	158	GPPH	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:53	2026-11-06 11:05:53
789	158	SDQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
790	158	SRQ	completed	2026-10-25 23:00:00	2026-10-25 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
791	159	KPSP	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
792	159	MCHAT	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
793	159	GPPH	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
794	159	SDQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
795	159	SRQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
796	160	KPSP	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
797	160	MCHAT	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
798	160	GPPH	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
799	160	SDQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
800	160	SRQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
801	161	KPSP	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
802	161	MCHAT	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
803	161	GPPH	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
804	161	SDQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
805	161	SRQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
806	162	KPSP	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
807	162	MCHAT	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
808	162	GPPH	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
809	162	SDQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
810	162	SRQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
811	163	KPSP	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
812	163	MCHAT	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
813	163	GPPH	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
814	163	SDQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
815	163	SRQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
816	164	KPSP	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
817	164	MCHAT	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
818	164	GPPH	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
819	164	SDQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
820	164	SRQ	completed	2026-10-26 23:00:00	2026-10-26 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
821	165	KPSP	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
822	165	MCHAT	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
823	165	GPPH	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
824	165	SDQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
825	165	SRQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
826	166	KPSP	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
827	166	MCHAT	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
828	166	GPPH	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
829	166	SDQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
830	166	SRQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
831	167	KPSP	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
832	167	MCHAT	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
833	167	GPPH	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
834	167	SDQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
835	167	SRQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
836	168	KPSP	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
837	168	MCHAT	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
838	168	GPPH	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
839	168	SDQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
840	168	SRQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
841	169	KPSP	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
842	169	MCHAT	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
843	169	GPPH	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
844	169	SDQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
845	169	SRQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
846	170	KPSP	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
847	170	MCHAT	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
848	170	GPPH	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
849	170	SDQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
850	170	SRQ	completed	2026-10-27 23:00:00	2026-10-27 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
851	171	KPSP	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
852	171	MCHAT	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
853	171	GPPH	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
854	171	SDQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
855	171	SRQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
856	172	KPSP	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
857	172	MCHAT	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
858	172	GPPH	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
859	172	SDQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
860	172	SRQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
861	173	KPSP	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
862	173	MCHAT	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
863	173	GPPH	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
864	173	SDQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
865	173	SRQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
866	174	KPSP	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
867	174	MCHAT	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
868	174	GPPH	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
869	174	SDQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
870	174	SRQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
871	175	KPSP	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
872	175	MCHAT	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
873	175	GPPH	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
874	175	SDQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
875	175	SRQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
876	176	KPSP	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
877	176	MCHAT	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
878	176	GPPH	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
879	176	SDQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
880	176	SRQ	completed	2026-10-28 23:00:00	2026-10-28 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
881	177	KPSP	completed	2026-11-05 22:00:00	2026-11-05 23:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
882	177	GPPH	completed	2026-11-05 23:00:00	2026-11-05 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
883	177	SDQ	pending	\N	\N	2026-11-06 11:05:54	2026-11-06 11:05:54
884	177	SRQ	pending	\N	\N	2026-11-06 11:05:54	2026-11-06 11:05:54
885	178	KPSP	completed	2026-11-04 22:00:00	2026-11-04 23:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
886	178	MCHAT	completed	2026-11-04 23:00:00	2026-11-04 23:30:00	2026-11-06 11:05:54	2026-11-06 11:05:54
887	179	KPSP	completed	2026-10-22 22:00:00	2026-10-22 23:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54
888	180	KPSP	pending	\N	\N	2026-11-06 11:05:54	2026-11-06 11:05:54
\.


--
-- Data for Name: screening_sessions; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.screening_sessions (id, patient_id, nurse_id, doctor_id, screening_date, age_months, status, notes, doctor_notes, reviewed_at, created_at, updated_at, created_by_user_id, evaluation_type, parent_session_id, case_type, referral_source, referral_target, interventions, recap_notes) FROM stdin;
1	1	1	1	2026-10-01	86	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-01 03:00:00	2026-11-06 11:05:50	2026-11-06 11:05:50	2	initial	\N	lama	\N	\N	["ot","si"]	\N
2	2	1	1	2026-10-01	61	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-01 03:00:00	2026-11-06 11:05:50	2026-11-06 11:05:50	2	initial	\N	lama	\N	\N	["aba","ot","si"]	TK Tunas Karya
3	3	1	1	2026-10-01	25	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-01 03:00:00	2026-11-06 11:05:50	2026-11-06 11:05:50	2	initial	\N	lama	\N	\N	["aba","ot","si"]	\N
4	4	1	1	2026-10-01	81	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-01 03:00:00	2026-11-06 11:05:50	2026-11-06 11:05:50	2	initial	\N	lama	\N	\N	["ot"]	KB EDELWEIS
5	5	1	1	2026-10-01	37	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-01 03:00:00	2026-11-06 11:05:50	2026-11-06 11:05:50	2	initial	\N	lama	\N	\N	["aba","ot","si"]	\N
6	6	1	1	2026-10-01	78	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-01 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	SD 012
7	7	1	1	2026-10-01	85	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-01 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	SDN 011
8	8	1	1	2026-10-02	110	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-02 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
9	9	1	1	2026-10-02	118	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-02 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	SD IT AL Aqsa (Rujuk Ggigi Klinik Ibnu Sina)
10	10	1	1	2026-10-02	132	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-02 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	SLBN 8
11	11	1	1	2026-10-02	85	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-02 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
12	12	1	1	2026-10-02	51	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-02 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
13	13	1	1	2026-10-02	97	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-02 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
14	14	1	1	2026-10-03	58	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-03 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	Paud An Nur
15	15	1	1	2026-10-03	132	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-03 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
16	16	1	1	2026-10-03	67	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-03 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	\N
17	17	1	1	2026-10-03	73	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-03 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	KB Cahaya Bintang
18	18	1	1	2026-10-03	112	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-03 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	MI Al Ula
19	19	1	1	2026-10-03	61	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-03 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	KB Baitul Ilmi
20	20	1	1	2026-10-04	52	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-04 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	\N
21	21	1	1	2026-10-04	87	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-04 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	sd 009 Balikpapan Barat
22	22	1	1	2026-10-04	79	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-04 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
23	23	1	1	2026-10-04	85	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-04 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	\N
24	24	1	1	2026-10-04	78	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-04 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","ot","si"]	TK
25	25	1	1	2026-10-04	48	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-04 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["ot","si"]	\N
26	26	1	1	2026-10-05	73	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-05 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","ot","si"]	TK/KB Cahaya Andika
27	27	1	1	2026-10-05	105	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-05 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["ot","fisioterapi"]	SDN 026
28	28	1	1	2026-10-05	49	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-05 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
29	29	1	1	2026-10-05	52	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-05 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
30	30	1	1	2026-10-05	67	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-05 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","ot","si"]	\N
31	31	1	1	2026-10-05	78	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-05 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","ot","si"]	TK Pelangi
32	32	1	1	2026-10-06	37	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-06 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","ot","si"]	\N
33	33	1	1	2026-10-06	66	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-06 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","ot","si"]	\N
34	34	1	1	2026-10-06	62	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-06 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	TK Pembina 1
35	35	1	1	2026-10-06	38	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-06 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
36	36	1	1	2026-10-06	76	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-06 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	baru	\N	\N	["aba","si"]	TK Pembina
37	37	1	1	2026-10-06	61	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-06 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	KB
38	38	1	1	2026-10-07	51	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-07 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
39	39	1	1	2026-10-07	51	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-07 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	\N
40	40	1	1	2026-10-07	81	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-07 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	Tk Bitul Ilmi
41	41	1	1	2026-10-07	96	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-07 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	SD 012
42	42	1	1	2026-10-07	108	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-07 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["fisioterapi"]	\N
43	43	1	1	2026-10-07	69	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-07 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	baru	\N	\N	["aba","si"]	TK. Golden
44	44	1	1	2026-10-08	68	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-08 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["ot","si"]	\N
45	45	1	1	2026-10-08	81	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-08 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["ot"]	\N
46	46	1	1	2026-10-08	68	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-08 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["ot"]	\N
47	47	1	1	2026-10-08	61	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-08 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","ot"]	TK
48	48	1	1	2026-10-08	56	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-08 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	Paud Qurota
49	49	1	1	2026-10-08	82	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-08 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","ot"]	TK IT Alfatihah
50	50	1	1	2026-10-09	85	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-09 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
51	51	1	1	2026-10-09	64	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-09 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
52	52	1	1	2026-10-09	90	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-09 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	TK Al-Qomar
53	53	1	1	2026-10-09	27	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-09 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	\N
54	54	1	1	2026-10-09	121	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-09 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N		["si"]	\N
55	55	1	1	2026-10-09	56	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-09 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	\N
56	56	1	1	2026-10-10	13	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-10 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["fisioterapi"]	\N
57	57	1	1	2026-10-10	34	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-10 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	\N
58	58	1	1	2026-10-10	92	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-10 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["si"]	\N
59	59	1	1	2026-10-10	64	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-10 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","ot","si"]	\N
60	60	1	1	2026-10-10	84	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-10 03:00:00	2026-11-06 11:05:51	2026-11-06 11:05:51	2	initial	\N	lama	\N	\N	["aba","si"]	TK
61	61	1	1	2026-10-10	58	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-10 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	Paud Teratai 3
62	62	1	1	2026-10-11	64	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-11 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
63	63	1	1	2026-10-11	64	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-11 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
64	64	1	1	2026-10-11	85	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-11 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	TK Dianugraha Penajam
65	65	1	1	2026-10-11	121	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-11 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["ot"]	MI Al Muttaqien
66	66	1	1	2026-10-11	62	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-11 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","ot","si"]	\N
67	67	1	1	2026-10-11	85	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-11 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["ot"]	\N
68	68	1	1	2026-10-12	63	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-12 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	TK Harapan
69	69	1	1	2026-10-12	97	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-12 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	TK Mawar Merah
70	70	1	1	2026-10-12	73	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-12 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
71	71	1	1	2026-10-12	61	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-12 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
72	72	1	1	2026-10-12	52	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-12 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	Paud
73	73	1	1	2026-10-12	73	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-12 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	KB Taman ceria km 7
74	74	1	1	2026-10-13	56	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-13 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	baru	\N	\N	["si"]	TK Manuntung
75	75	1	1	2026-10-13	68	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-13 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
76	76	1	1	2026-10-13	60	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-13 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
77	77	1	1	2026-10-13	38	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-13 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
78	78	1	1	2026-10-13	25	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-13 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
79	79	1	1	2026-10-13	27	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-13 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
80	80	1	1	2026-10-14	88	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-14 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["fisioterapi"]	\N
81	81	1	1	2026-10-14	82	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-14 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","ot"]	TK.Cempaka
82	82	1	1	2026-10-14	63	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-14 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["ot","si"]	Mitta School
83	83	1	1	2026-10-14	56	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-14 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["ot"]	Toodler Class
84	84	1	1	2026-10-14	79	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-14 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
85	85	1	1	2026-10-14	82	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-14 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
86	86	1	1	2026-10-15	109	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-15 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba"]	SD 012 Balikpapan Kota
87	87	1	1	2026-10-15	63	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-15 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
88	88	1	1	2026-10-15	68	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-15 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	baru	\N	\N	["aba","si"]	RQ
89	89	1	1	2026-10-15	80	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-15 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
90	90	1	1	2026-10-15	68	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-15 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	TK Islam Al Azhar
91	91	1	1	2026-10-15	54	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-15 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
92	92	1	1	2026-10-15	74	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-15 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
93	93	1	1	2026-10-16	73	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-16 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	PAUD Baitul Ilmi
94	94	1	1	2026-10-16	34	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-16 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
95	95	1	1	2026-10-16	94	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-16 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	tk/paud
96	96	1	1	2026-10-16	49	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-16 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["fisioterapi"]	\N
97	97	1	1	2026-10-16	88	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-16 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	TK Gemilang
98	98	1	1	2026-10-16	40	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-16 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
99	99	1	1	2026-10-17	55	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-17 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["ot"]	\N
100	100	1	1	2026-10-17	73	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-17 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["ot"]	\N
101	101	1	1	2026-10-17	98	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-17 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba"]	SDN 016 Balikpapan
102	102	1	1	2026-10-17	109	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-17 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	SD IT AL Aqsa
103	103	1	1	2026-10-17	79	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-17 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	TK
104	104	1	1	2026-10-17	49	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-17 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
105	105	1	1	2026-10-18	72	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-18 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
106	106	1	1	2026-10-18	122	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-18 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba"]	\N
107	107	1	1	2026-10-18	72	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-18 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
108	108	1	1	2026-10-18	72	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-18 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
109	109	1	1	2026-10-18	49	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-18 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["aba","si"]	\N
110	110	1	1	2026-10-18	49	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-18 03:00:00	2026-11-06 11:05:52	2026-11-06 11:05:52	2	initial	\N	lama	\N	\N	["si"]	\N
111	111	1	1	2026-10-19	87	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-19 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
112	112	1	1	2026-10-19	78	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-19 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
113	113	1	1	2026-10-19	69	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-19 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["fisioterapi"]	CP
114	114	1	1	2026-10-19	92	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-19 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba","si"]	\N
115	115	1	1	2026-10-19	57	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-19 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba","si"]	\N
116	116	1	1	2026-10-19	61	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-19 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
117	117	1	1	2026-10-20	74	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-20 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba","si"]	TK Al Qomar
118	118	1	1	2026-10-20	98	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-20 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["ot","si"]	TK Salman Alfarisi
119	119	1	1	2026-10-20	60	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-20 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba","si"]	Paud Teratai
120	120	1	1	2026-10-20	84	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-20 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	SKB Balikpapan Utara
121	121	1	1	2026-10-20	104	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-20 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba","si"]	KBBI
122	122	1	1	2026-10-20	79	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-20 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba","si"]	\N
123	123	1	1	2026-10-21	64	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-21 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba","si"]	\N
124	124	1	1	2026-10-21	102	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-21 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["fisioterapi"]	\N
125	125	1	1	2026-10-21	85	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-21 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	TK Gemilang
126	126	1	1	2026-10-21	25	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-21 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
127	127	1	1	2026-10-21	98	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-21 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
128	128	1	1	2026-10-21	98	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-21 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
129	129	1	1	2026-10-22	62	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-22 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba","si"]	Paud Primananda
130	130	1	1	2026-10-22	58	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-22 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["aba"]	SKB Balikpapan Barat
131	131	1	1	2026-10-22	55	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-22 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
132	132	1	1	2026-10-22	54	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-22 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	Edelweis
133	133	1	1	2026-10-22	66	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-22 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	tk Al Muharram
134	134	1	1	2026-10-22	82	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-22 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	TK BAP 02 BALTIM
135	135	1	1	2026-10-23	78	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-23 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba","si"]	\N
136	136	1	1	2026-10-23	66	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-23 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["ot","si"]	\N
137	137	1	1	2026-10-23	25	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-23 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["fisioterapi"]	\N
138	138	1	1	2026-10-23	92	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-23 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	SD 014
139	139	1	1	2026-10-23	49	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-23 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
140	140	1	1	2026-10-23	73	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-23 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
141	141	1	1	2026-10-24	37	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-24 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	KB Baitul Ilmi
142	142	1	1	2026-10-24	58	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-24 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
143	143	1	1	2026-10-24	58	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-24 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["si"]	\N
144	144	1	1	2026-10-24	97	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-24 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba"]	SDN 010
145	145	1	1	2026-10-24	37	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-24 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba","si"]	\N
146	146	1	1	2026-10-24	76	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-24 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	lama	\N	\N	["aba"]	Paud Puspita
147	147	1	1	2026-10-25	121	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-25 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","aba","si","konseling"]	SD 002 Balikpapan Utara
148	148	1	1	2026-10-25	81	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-25 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","aba","si","konseling"]	\N
149	149	1	1	2026-10-25	104	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-25 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	SDN 025
150	150	1	1	2026-10-25	40	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-25 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","si","konseling"]	\N
151	151	1	1	2026-10-25	73	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-25 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","si","konseling"]	PKBM
152	152	1	1	2026-10-25	25	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-25 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	\N
153	153	1	1	2026-10-26	25	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-26 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","si","konseling"]	\N
154	154	1	1	2026-10-26	109	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-26 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","aba","konseling"]	SD Muhammadiyah 1
155	155	1	1	2026-10-26	86	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-26 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","si","konseling"]	SD 004 Balikpapan Selatan
156	156	1	1	2026-10-26	31	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-26 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	\N
157	157	1	1	2026-10-26	37	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-26 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	\N
158	158	1	1	2026-10-26	88	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-26 03:00:00	2026-11-06 11:05:53	2026-11-06 11:05:53	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	TK Anggrek Markoni
159	159	1	1	2026-10-27	79	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-27 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","aba","si","konseling"]	\N
160	160	1	1	2026-10-27	72	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-27 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","si","konseling"]	TK Khalifah
161	161	1	1	2026-10-27	88	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-27 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	TK Mandaya
162	162	1	1	2026-10-27	66	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-27 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","si","konseling"]	TK Momy 2
163	163	1	1	2026-10-27	60	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-27 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	\N
164	164	1	1	2026-10-27	34	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-27 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	\N
165	165	1	1	2026-10-28	84	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-28 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	sd 028 balikpapan tengah
166	166	1	1	2026-10-28	28	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-28 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","si","konseling"]	\N
167	167	1	1	2026-10-28	109	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-28 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","aba","si","konseling"]	SD 005
168	168	1	1	2026-10-28	105	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-28 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	SD 11 Balikpapan Kota
169	169	1	1	2026-10-28	37	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-28 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	Rumah Tilawati
170	170	1	1	2026-10-28	90	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-28 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	MI Melati 1
171	171	1	1	2026-10-29	46	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-29 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	KB Mawar Putih
172	172	1	1	2026-10-29	84	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-29 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	Nurul Fikri
173	173	1	1	2026-10-29	84	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-29 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	SD 011
174	174	1	1	2026-10-29	45	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-29 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	\N
175	175	1	1	2026-10-29	24	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-29 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	\N
176	176	1	1	2026-10-29	110	reviewed	Pemeriksaan register SDIDTK UPTD BLK-ABK Balikpapan bulan Oktober 2026.	Hasil evaluasi klinis dan program intervensi disetujui dokter.	2026-10-29 03:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	\N	\N	["psikolog","konseling"]	SD019 Balikpapan Utara
177	2	1	\N	2026-11-06	61	in_progress	Pemeriksaan berkala usia 5 tahun. Menunggu pengisian kuesioner SDQ dan SRQ-20 oleh Orang Tua.	\N	\N	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	lama	Puskesmas Karang Rejo	\N	["konseling"]	\N
178	3	1	1	2026-11-05	25	pending_doctor_review	Pemeriksaan evaluasi 25 bulan - Hasil KPSP meragukan (8/10). Menunggu tinjauan dokter.	\N	\N	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	lama	Puskesmas Damai	\N	["ot","tw","konseling"]	\N
179	5	1	1	2026-10-23	37	reviewed	Pemeriksaan skrining berkala 36 bulan - Hasil KPSP Meragukan (Dm: Skor 8/10). Diberikan instruksi intervensi stimulasi intensif 2 minggu di rumah.	KPSP Meragukan (Dm) pada domain motorik kasar dan bicara. Lakukan stimulasi terarah selama 14 hari sesuai buku KIA, lalu lakukan evaluasi ulang KPSP.	2026-10-23 02:00:00	2026-11-06 11:05:54	2026-11-06 11:05:54	2	initial	\N	baru	Puskesmas Manggar	\N	["konseling"]	\N
180	5	1	1	2026-11-06	37	draft	Evaluasi ulang KPSP 2 minggu pasca intervensi dini perkembangan dari Sesi #179 (Hasil sebelumnya: Meragukan / Dm: 8/10).	\N	\N	2026-11-06 11:05:54	2026-11-06 11:05:54	2	kpsp_re_evaluation_2_weeks	179	lama	Puskesmas Manggar	RSUD Kanujoso Djatiwibowo	["ot","tw","rujukan"]	\N
\.


--
-- Data for Name: sdq_screenings; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.sdq_screenings (id, screening_session_id, answers, emotional_score, conduct_score, hyperactivity_score, peer_score, total_difficulties_score, prosocial_score, total_difficulties_category, prosocial_category, recommendation, created_at, updated_at, emotional_category, conduct_category, hyperactivity_category, peer_category) FROM stdin;
1	1	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:50	2026-11-06 11:05:50	abnormal	abnormal	abnormal	abnormal
2	2	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:50	2026-11-06 11:05:50	abnormal	abnormal	abnormal	abnormal
3	3	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:50	2026-11-06 11:05:50	abnormal	abnormal	abnormal	abnormal
4	4	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:50	2026-11-06 11:05:50	abnormal	abnormal	abnormal	abnormal
5	5	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
6	6	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
7	7	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
8	8	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
9	9	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
10	10	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	normal	normal	normal	normal
11	11	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
12	12	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
13	13	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
14	14	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
15	15	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
16	16	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
17	17	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
18	18	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
19	19	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
20	20	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
21	21	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
22	22	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
23	23	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
24	24	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
25	25	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
26	26	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
27	27	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	normal	normal	normal	normal
28	28	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
29	29	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
30	30	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
31	31	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
32	32	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
33	33	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
34	34	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
35	35	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	normal	normal	normal	normal
36	36	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
37	37	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
38	38	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
39	39	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
40	40	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
41	41	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
42	42	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
43	43	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
44	44	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
45	45	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	normal	normal	normal	normal
46	46	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
47	47	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
48	48	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
49	49	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
50	50	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
51	51	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
52	52	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
53	53	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
54	54	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
55	55	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
56	56	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	normal	normal	normal	normal
57	57	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
58	58	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	normal	normal	normal	normal
59	59	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
60	60	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:51	2026-11-06 11:05:51	abnormal	abnormal	abnormal	abnormal
61	61	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
62	62	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
63	63	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
64	64	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
65	65	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
66	66	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
67	67	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
68	68	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
69	69	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
70	70	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
71	71	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
72	72	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
73	73	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
74	74	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
75	75	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
76	76	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
77	77	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
78	78	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
79	79	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
80	80	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	normal	normal	normal	normal
81	81	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
82	82	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	normal	normal	normal	normal
83	83	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
84	84	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
85	85	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
86	86	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
87	87	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
88	88	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
89	89	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
90	90	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
91	91	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
92	92	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
93	93	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
94	94	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
95	95	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
96	96	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
97	97	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
98	98	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
99	99	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
100	100	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
101	101	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
102	102	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
103	103	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
104	104	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	normal	normal	normal	normal
105	105	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
106	106	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
107	107	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
108	108	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
109	109	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:52	2026-11-06 11:05:52	abnormal	abnormal	abnormal	abnormal
110	110	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
111	111	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
112	112	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
113	113	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
114	114	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
115	115	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
116	116	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
117	117	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
118	118	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
119	119	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
120	120	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
121	121	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
122	122	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
123	123	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
124	124	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
125	125	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
126	126	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
127	127	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
128	128	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
129	129	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
130	130	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
131	131	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
132	132	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
133	133	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
134	134	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
135	135	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
136	136	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
137	137	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
138	138	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
139	139	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
140	140	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
141	141	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
142	142	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
143	143	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
144	144	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
145	145	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
146	146	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
147	147	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
148	148	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
149	149	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
150	150	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
151	151	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
152	152	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
153	153	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
154	154	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
155	155	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
156	156	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	normal	normal	normal	normal
157	157	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:53	2026-11-06 11:05:53	abnormal	abnormal	abnormal	abnormal
158	158	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
159	159	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
160	160	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
161	161	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
162	162	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
163	163	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
164	164	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	normal	normal	normal	normal
165	165	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	normal	normal	normal	normal
166	166	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	normal	normal	normal	normal
167	167	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
168	168	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
169	169	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
170	170	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
171	171	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
172	172	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
173	173	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
174	174	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
175	175	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]	1	1	2	2	6	9	normal	normal	Perkembangan perilaku emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	normal	normal	normal	normal
176	176	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]	5	4	5	4	18	6	abnormal	normal	Perlu pendampingan psikologis terarah.	2026-11-06 11:05:54	2026-11-06 11:05:54	abnormal	abnormal	abnormal	abnormal
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
pBzsbS06DDV5aNeZbyHu9HHBsSh0IpdEjhLaWgTl	2	172.19.0.1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36	YTo1OntzOjY6Il90b2tlbiI7czo0MDoiMzNhVjI3ZTgwZDVNRk9RMFFzb25xM2FjNUdqN2p6S1BobDhJTGdhOCI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjMxOiJodHRwOi8vbG9jYWxob3N0OjgwMDEvZGFzaGJvYXJkIjtzOjU6InJvdXRlIjtzOjk6ImRhc2hib2FyZCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjI7fQ==	1793970281
HpPYiUQzo46tZtGdRjGjmqcKuRR7Uy2t6jtqPrwj	\N	172.19.0.1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36	YTo0OntzOjY6Il90b2tlbiI7czo0MDoiZXIyM2M5bWFhb09LdkN2U2ROdllvNnJPYmhhNktRZDV5Q3MwVnNxaCI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozMToiaHR0cDovL2xvY2FsaG9zdDo4MDAxL2Rhc2hib2FyZCI7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjI3OiJodHRwOi8vbG9jYWxob3N0OjgwMDEvbG9naW4iO3M6NToicm91dGUiO3M6NToibG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19	1794065296
kAJAryzacNzxhAooKcpW9uwNc2yrIefJKJKea80F	\N	172.19.0.1	curl/8.23.0	YToyOntzOjY6Il90b2tlbiI7czo0MDoiZXdjWjNWWFF0cGVOTnBmUGp5NUIyM1BpcXFvSGZJcHRjeWZCa3p6NCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1793964014
U6F3jK5AIILkI3Cvrk2Me8ahqt09VvWMa5V2UA8r	2	172.19.0.1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36	YTo0OntzOjY6Il90b2tlbiI7czo0MDoiajZEcThrU1B4RFZ0V1NXTURBTFFqTzZreWZVa05PMFF3N3dwVFpzUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NzM6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMS9yZWthcGl0dWxhc2k/Z3JhbnVsYXJpdHk9YnVsYW5hbiZtb250aD0xMCZ5ZWFyPTIwMjYiO3M6NToicm91dGUiO3M6MjE6InNjcmVlbmluZy1yZWNhcC5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjI7fQ==	1794205285
FzmclbWLGGZ8t3hvO5zA7MhZdUTnRi1eAEkSGjti	2	172.19.0.1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36	YTo0OntzOjY6Il90b2tlbiI7czo0MDoiRGhJVUtPZWYyVXdEN2lUZEVVdXVKM3FRZTVrd1BPajJaTU4zWHVldyI7czozOiJ1cmwiO2E6MDp7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjI7fQ==	1794216223
\.


--
-- Data for Name: srq_screenings; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.srq_screenings (id, screening_session_id, answers, score, category, recommendation, created_at, updated_at, depression_score, anxiety_score, somatic_score, cognitive_score, energy_score) FROM stdin;
1	1	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, true, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:50	2026-11-06 11:05:50	3	2	1	1	0
2	2	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:50	2026-11-06 11:05:50	1	1	0	0	0
3	3	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:50	2026-11-06 11:05:50	3	2	1	1	0
4	4	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:50	2026-11-06 11:05:50	1	1	0	0	0
5	5	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
6	6	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
7	7	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
8	8	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
9	9	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
10	10	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
11	11	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
12	12	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
13	13	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
14	14	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
15	15	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
16	16	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
17	17	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
18	18	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
19	19	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
20	20	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
21	21	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, true, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
22	22	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
23	23	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
24	24	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
25	25	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
26	26	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
27	27	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
28	28	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
29	29	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
30	30	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
31	31	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
32	32	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
33	33	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
34	34	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
35	35	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
36	36	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
37	37	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
38	38	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
39	39	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
40	40	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
41	41	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, true, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
42	42	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
43	43	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
44	44	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
45	45	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
46	46	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
47	47	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
48	48	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
49	49	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
50	50	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
51	51	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
52	52	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
53	53	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
54	54	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
55	55	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
56	56	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
57	57	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
58	58	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:51	2026-11-06 11:05:51	1	1	0	0	0
59	59	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:51	2026-11-06 11:05:51	3	2	1	1	0
60	60	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
61	61	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, true, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
62	62	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
63	63	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
64	64	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
65	65	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
66	66	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
67	67	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
68	68	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
69	69	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
70	70	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
71	71	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
72	72	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
73	73	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
74	74	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
75	75	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
76	76	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
77	77	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
78	78	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
79	79	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
80	80	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
81	81	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, true, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
82	82	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
83	83	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
84	84	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
85	85	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
86	86	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
87	87	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
88	88	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
89	89	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
90	90	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
91	91	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
92	92	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
93	93	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
94	94	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
95	95	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
96	96	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
97	97	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
98	98	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
99	99	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
100	100	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
101	101	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, true, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
102	102	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
103	103	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
104	104	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
105	105	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
106	106	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
107	107	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
108	108	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:52	2026-11-06 11:05:52	1	1	0	0	0
109	109	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:52	2026-11-06 11:05:52	3	2	1	1	0
110	110	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
111	111	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
112	112	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
113	113	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
114	114	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
115	115	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
116	116	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
117	117	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
118	118	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
119	119	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
120	120	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
121	121	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, true, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
122	122	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
123	123	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
124	124	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
125	125	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
126	126	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
127	127	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
128	128	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
129	129	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
130	130	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
131	131	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
132	132	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
133	133	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
134	134	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
135	135	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
136	136	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
137	137	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
138	138	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
139	139	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
140	140	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
141	141	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, true, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
142	142	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
143	143	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
144	144	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
145	145	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
146	146	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
147	147	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
148	148	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
149	149	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
150	150	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
151	151	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
152	152	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
153	153	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
154	154	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
155	155	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
156	156	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:53	2026-11-06 11:05:53	1	1	0	0	0
157	157	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:53	2026-11-06 11:05:53	3	2	1	1	0
158	158	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
159	159	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:54	2026-11-06 11:05:54	3	2	1	1	0
160	160	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
161	161	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, true, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:54	2026-11-06 11:05:54	3	2	1	1	0
162	162	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
163	163	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:54	2026-11-06 11:05:54	3	2	1	1	0
164	164	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
165	165	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:54	2026-11-06 11:05:54	3	2	1	1	0
166	166	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
167	167	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:54	2026-11-06 11:05:54	3	2	1	1	0
168	168	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
169	169	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:54	2026-11-06 11:05:54	3	2	1	1	0
170	170	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
171	171	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:54	2026-11-06 11:05:54	3	2	1	1	0
172	172	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
173	173	[true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]	7	gangguan_mental_emosional_distres	Disarankan konseling suportif bagi orang tua.	2026-11-06 11:05:54	2026-11-06 11:05:54	3	2	1	1	0
174	174	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
175	175	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
176	176	[true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]	2	di_bawah_nilai_pisah	Kondisi kesehatan mental emosional baik.	2026-11-06 11:05:54	2026-11-06 11:05:54	1	1	0	0	0
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: spk_user
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at, role_id) FROM stdin;
1	Administrator	admin@spk.test	2026-11-06 11:05:49	$2y$12$ZXmLrJ0CScy8EDoOAIGhx.Ul8h3TxSLcQsSL.BigJx.QzijHc2LHO	\N	2026-11-06 11:05:49	2026-11-06 11:05:49	1
2	Perawat Uji	perawat@spk.test	2026-11-06 11:05:50	$2y$12$cOYh6CZNcIvjCR74pieWculrvbBBejxCw/EzmuAqgDyDFS9zU9gfi	\N	2026-11-06 11:05:50	2026-11-06 11:05:50	2
3	Dokter Uji	dokter@spk.test	2026-11-06 11:05:50	$2y$12$N/nCyRdktrBek8NEPoZWeu6HmWnswwh0iluqs/y8kFCJ6fC6jnrQi	\N	2026-11-06 11:05:50	2026-11-06 11:05:50	3
4	Orang Tua Uji	orangtua@spk.test	2026-11-06 11:05:50	$2y$12$LRSgQmChW.7hSxE9r5eUBOe9C7I/vXiEq.wt5gPH20PgzbDhVOO.q	\N	2026-11-06 11:05:50	2026-11-06 11:05:50	4
5	Wali Pasien UPTD	wali_uptd@spk.test	2026-11-06 11:05:50	$2y$12$IrqAeDOFSeZobK3vpJbIZuBrXyEjVTO5bPgiJ2uyQQMJCTfAgiige	\N	2026-11-06 11:05:50	2026-11-06 11:05:50	4
\.


--
-- Name: doctors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.doctors_id_seq', 1, true);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: gpph_screenings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.gpph_screenings_id_seq', 177, true);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: kpsp_screenings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.kpsp_screenings_id_seq', 179, true);


--
-- Name: mchat_screenings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.mchat_screenings_id_seq', 177, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.migrations_id_seq', 25, true);


--
-- Name: nurses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.nurses_id_seq', 1, true);


--
-- Name: parent_guardians_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.parent_guardians_id_seq', 2, true);


--
-- Name: patients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.patients_id_seq', 176, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- Name: screening_interpretations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.screening_interpretations_id_seq', 177, true);


--
-- Name: screening_session_instruments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.screening_session_instruments_id_seq', 888, true);


--
-- Name: screening_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.screening_sessions_id_seq', 180, true);


--
-- Name: sdq_screenings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.sdq_screenings_id_seq', 176, true);


--
-- Name: srq_screenings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.srq_screenings_id_seq', 176, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spk_user
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: doctors doctors_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_pkey PRIMARY KEY (id);


--
-- Name: doctors doctors_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_user_id_unique UNIQUE (user_id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: gpph_screenings gpph_screenings_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.gpph_screenings
    ADD CONSTRAINT gpph_screenings_pkey PRIMARY KEY (id);


--
-- Name: gpph_screenings gpph_screenings_screening_session_id_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.gpph_screenings
    ADD CONSTRAINT gpph_screenings_screening_session_id_unique UNIQUE (screening_session_id);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: kpsp_screenings kpsp_screenings_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.kpsp_screenings
    ADD CONSTRAINT kpsp_screenings_pkey PRIMARY KEY (id);


--
-- Name: kpsp_screenings kpsp_screenings_screening_session_id_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.kpsp_screenings
    ADD CONSTRAINT kpsp_screenings_screening_session_id_unique UNIQUE (screening_session_id);


--
-- Name: mchat_screenings mchat_screenings_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.mchat_screenings
    ADD CONSTRAINT mchat_screenings_pkey PRIMARY KEY (id);


--
-- Name: mchat_screenings mchat_screenings_screening_session_id_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.mchat_screenings
    ADD CONSTRAINT mchat_screenings_screening_session_id_unique UNIQUE (screening_session_id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: nurses nurses_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.nurses
    ADD CONSTRAINT nurses_pkey PRIMARY KEY (id);


--
-- Name: nurses nurses_registration_number_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.nurses
    ADD CONSTRAINT nurses_registration_number_unique UNIQUE (registration_number);


--
-- Name: nurses nurses_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.nurses
    ADD CONSTRAINT nurses_user_id_unique UNIQUE (user_id);


--
-- Name: parent_guardians parent_guardians_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.parent_guardians
    ADD CONSTRAINT parent_guardians_pkey PRIMARY KEY (id);


--
-- Name: parent_guardians parent_guardians_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.parent_guardians
    ADD CONSTRAINT parent_guardians_user_id_unique UNIQUE (user_id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: patients patients_medical_record_number_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_medical_record_number_unique UNIQUE (medical_record_number);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_unique UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: screening_interpretations screening_interpretations_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_interpretations
    ADD CONSTRAINT screening_interpretations_pkey PRIMARY KEY (id);


--
-- Name: screening_session_instruments screening_session_instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_session_instruments
    ADD CONSTRAINT screening_session_instruments_pkey PRIMARY KEY (id);


--
-- Name: screening_session_instruments screening_session_instruments_session_instrument_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_session_instruments
    ADD CONSTRAINT screening_session_instruments_session_instrument_unique UNIQUE (screening_session_id, instrument_code);


--
-- Name: screening_sessions screening_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_sessions
    ADD CONSTRAINT screening_sessions_pkey PRIMARY KEY (id);


--
-- Name: sdq_screenings sdq_screenings_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.sdq_screenings
    ADD CONSTRAINT sdq_screenings_pkey PRIMARY KEY (id);


--
-- Name: sdq_screenings sdq_screenings_screening_session_id_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.sdq_screenings
    ADD CONSTRAINT sdq_screenings_screening_session_id_unique UNIQUE (screening_session_id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: srq_screenings srq_screenings_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.srq_screenings
    ADD CONSTRAINT srq_screenings_pkey PRIMARY KEY (id);


--
-- Name: srq_screenings srq_screenings_screening_session_id_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.srq_screenings
    ADD CONSTRAINT srq_screenings_screening_session_id_unique UNIQUE (screening_session_id);


--
-- Name: screening_interpretations uq_session_instrument_interpretation; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_interpretations
    ADD CONSTRAINT uq_session_instrument_interpretation UNIQUE (screening_session_id, instrument_code);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: cache_expiration_index; Type: INDEX; Schema: public; Owner: spk_user
--

CREATE INDEX cache_expiration_index ON public.cache USING btree (expiration);


--
-- Name: cache_locks_expiration_index; Type: INDEX; Schema: public; Owner: spk_user
--

CREATE INDEX cache_locks_expiration_index ON public.cache_locks USING btree (expiration);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: spk_user
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: spk_user
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: spk_user
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: doctors doctors_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: gpph_screenings gpph_screenings_screening_session_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.gpph_screenings
    ADD CONSTRAINT gpph_screenings_screening_session_id_foreign FOREIGN KEY (screening_session_id) REFERENCES public.screening_sessions(id) ON DELETE RESTRICT;


--
-- Name: kpsp_screenings kpsp_screenings_screening_session_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.kpsp_screenings
    ADD CONSTRAINT kpsp_screenings_screening_session_id_foreign FOREIGN KEY (screening_session_id) REFERENCES public.screening_sessions(id) ON DELETE RESTRICT;


--
-- Name: mchat_screenings mchat_screenings_screening_session_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.mchat_screenings
    ADD CONSTRAINT mchat_screenings_screening_session_id_foreign FOREIGN KEY (screening_session_id) REFERENCES public.screening_sessions(id) ON DELETE RESTRICT;


--
-- Name: nurses nurses_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.nurses
    ADD CONSTRAINT nurses_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: parent_guardians parent_guardians_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.parent_guardians
    ADD CONSTRAINT parent_guardians_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: patients patients_parent_guardian_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_parent_guardian_id_foreign FOREIGN KEY (parent_guardian_id) REFERENCES public.parent_guardians(id) ON DELETE RESTRICT;


--
-- Name: screening_interpretations screening_interpretations_doctor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_interpretations
    ADD CONSTRAINT screening_interpretations_doctor_id_foreign FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE RESTRICT;


--
-- Name: screening_interpretations screening_interpretations_screening_session_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_interpretations
    ADD CONSTRAINT screening_interpretations_screening_session_id_foreign FOREIGN KEY (screening_session_id) REFERENCES public.screening_sessions(id) ON DELETE CASCADE;


--
-- Name: screening_session_instruments screening_session_instruments_screening_session_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_session_instruments
    ADD CONSTRAINT screening_session_instruments_screening_session_id_foreign FOREIGN KEY (screening_session_id) REFERENCES public.screening_sessions(id) ON DELETE RESTRICT;


--
-- Name: screening_sessions screening_sessions_created_by_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_sessions
    ADD CONSTRAINT screening_sessions_created_by_user_id_foreign FOREIGN KEY (created_by_user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: screening_sessions screening_sessions_doctor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_sessions
    ADD CONSTRAINT screening_sessions_doctor_id_foreign FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE RESTRICT;


--
-- Name: screening_sessions screening_sessions_nurse_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_sessions
    ADD CONSTRAINT screening_sessions_nurse_id_foreign FOREIGN KEY (nurse_id) REFERENCES public.nurses(id) ON DELETE RESTRICT;


--
-- Name: screening_sessions screening_sessions_parent_session_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_sessions
    ADD CONSTRAINT screening_sessions_parent_session_id_foreign FOREIGN KEY (parent_session_id) REFERENCES public.screening_sessions(id) ON DELETE SET NULL;


--
-- Name: screening_sessions screening_sessions_patient_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.screening_sessions
    ADD CONSTRAINT screening_sessions_patient_id_foreign FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE RESTRICT;


--
-- Name: sdq_screenings sdq_screenings_screening_session_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.sdq_screenings
    ADD CONSTRAINT sdq_screenings_screening_session_id_foreign FOREIGN KEY (screening_session_id) REFERENCES public.screening_sessions(id) ON DELETE RESTRICT;


--
-- Name: srq_screenings srq_screenings_screening_session_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.srq_screenings
    ADD CONSTRAINT srq_screenings_screening_session_id_foreign FOREIGN KEY (screening_session_id) REFERENCES public.screening_sessions(id) ON DELETE RESTRICT;


--
-- Name: users users_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: spk_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_foreign FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict E0SOSpUtS36jL2hna2g372NpjA8GELuBB0j3XP1fspeodKShXLkcVfdaXJ75Q48

