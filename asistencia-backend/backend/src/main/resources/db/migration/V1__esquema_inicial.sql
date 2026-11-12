-- Esquema inicial generado con pg_dump --schema-only de asistencia_escolar
-- (PostgreSQL 18, Hibernate ddl-auto=update). Sin owners ni privilegios.

CREATE TABLE public.attendances (
    id character varying(40) NOT NULL,
    date date NOT NULL,
    recorded_at timestamp(6) with time zone NOT NULL,
    status character varying(20) NOT NULL,
    group_id character varying(40) NOT NULL,
    student_id character varying(40) NOT NULL,
    teacher_id character varying(40) NOT NULL,
    CONSTRAINT attendances_status_check CHECK (((status)::text = ANY ((ARRAY['PRESENT'::character varying, 'ABSENT'::character varying, 'JUSTIFIED'::character varying, 'LATE'::character varying])::text[])))
);

CREATE TABLE public.class_periods (
    id integer NOT NULL,
    end_time character varying(8) NOT NULL,
    label character varying(10) NOT NULL,
    start_time character varying(8) NOT NULL
);

CREATE TABLE public.cover_assignments (
    id character varying(40) NOT NULL,
    absent_teacher_name character varying(240),
    created_at timestamp(6) with time zone NOT NULL,
    date date NOT NULL,
    file_content_type character varying(120),
    file_data oid NOT NULL,
    file_name character varying(255) NOT NULL,
    file_type character varying(20) NOT NULL,
    instructions character varying(4000),
    subject character varying(80) NOT NULL,
    title character varying(240) NOT NULL,
    weekday character varying(20) NOT NULL,
    group_id character varying(40) NOT NULL,
    period_id integer NOT NULL,
    CONSTRAINT cover_assignments_file_type_check CHECK (((file_type)::text = ANY ((ARRAY['PDF'::character varying, 'IMAGE'::character varying, 'WORD'::character varying, 'EXCEL'::character varying])::text[]))),
    CONSTRAINT cover_assignments_weekday_check CHECK (((weekday)::text = ANY ((ARRAY['MONDAY'::character varying, 'TUESDAY'::character varying, 'WEDNESDAY'::character varying, 'THURSDAY'::character varying, 'FRIDAY'::character varying])::text[])))
);

CREATE TABLE public.groups_ (
    id character varying(40) NOT NULL,
    grade integer NOT NULL,
    letter character varying(4) NOT NULL,
    name character varying(40) NOT NULL,
    school_year character varying(20) NOT NULL,
    student_count integer NOT NULL,
    teacher_id character varying(40) NOT NULL
);

CREATE TABLE public.justifications (
    id character varying(40) NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    date date NOT NULL,
    file_content_type character varying(120),
    file_data oid,
    file_name character varying(255),
    notes character varying(2000) NOT NULL,
    reason character varying(30) NOT NULL,
    student_id character varying(40) NOT NULL,
    CONSTRAINT justifications_reason_check CHECK (((reason)::text = ANY ((ARRAY['ILLNESS'::character varying, 'MEDICAL_APPOINTMENT'::character varying, 'FAMILY'::character varying, 'SCHOOL_ACTIVITY'::character varying, 'OTHER'::character varying])::text[])))
);

CREATE TABLE public.schedule_slots (
    id character varying(40) NOT NULL,
    classroom character varying(40) NOT NULL,
    subject character varying(80) NOT NULL,
    weekday character varying(20) NOT NULL,
    group_id character varying(40) NOT NULL,
    period_id integer NOT NULL,
    teacher_id character varying(40) NOT NULL,
    CONSTRAINT schedule_slots_weekday_check CHECK (((weekday)::text = ANY ((ARRAY['MONDAY'::character varying, 'TUESDAY'::character varying, 'WEDNESDAY'::character varying, 'THURSDAY'::character varying, 'FRIDAY'::character varying])::text[])))
);

CREATE TABLE public.students (
    id character varying(40) NOT NULL,
    first_name character varying(120) NOT NULL,
    full_name character varying(240) NOT NULL,
    last_name character varying(120) NOT NULL,
    school_year character varying(20) NOT NULL,
    status character varying(20) NOT NULL,
    student_number integer NOT NULL,
    group_id character varying(40) NOT NULL,
    CONSTRAINT students_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying])::text[])))
);

CREATE TABLE public.teacher_absence_groups (
    teacher_absence_id character varying(40) NOT NULL,
    group_name character varying(255)
);

CREATE TABLE public.teacher_absence_periods (
    teacher_absence_id character varying(40) NOT NULL,
    period_id integer
);

CREATE TABLE public.teacher_absences (
    id character varying(40) NOT NULL,
    covered_by character varying(240),
    date date NOT NULL,
    reason character varying(160) NOT NULL,
    weekday character varying(20) NOT NULL,
    teacher_id character varying(40) NOT NULL,
    CONSTRAINT teacher_absences_weekday_check CHECK (((weekday)::text = ANY ((ARRAY['MONDAY'::character varying, 'TUESDAY'::character varying, 'WEDNESDAY'::character varying, 'THURSDAY'::character varying, 'FRIDAY'::character varying])::text[])))
);

CREATE TABLE public.teachers (
    id character varying(40) NOT NULL,
    contracted_hours integer NOT NULL,
    email character varying(160) NOT NULL,
    first_name character varying(120) NOT NULL,
    full_name character varying(240) NOT NULL,
    last_name character varying(120) NOT NULL,
    subject character varying(80) NOT NULL
);

CREATE TABLE public.users (
    id character varying(40) NOT NULL,
    email character varying(160) NOT NULL,
    full_name character varying(240) NOT NULL,
    password_hash character varying(100) NOT NULL,
    role character varying(20) NOT NULL,
    username character varying(80) NOT NULL,
    teacher_id character varying(40),
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['TEACHER'::character varying, 'ADMIN'::character varying, 'COORDINATOR'::character varying])::text[])))
);

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT attendances_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.class_periods
    ADD CONSTRAINT class_periods_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.cover_assignments
    ADD CONSTRAINT cover_assignments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.groups_
    ADD CONSTRAINT groups__pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.justifications
    ADD CONSTRAINT justifications_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.schedule_slots
    ADD CONSTRAINT schedule_slots_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.teacher_absences
    ADD CONSTRAINT teacher_absences_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT uk4l9jjfvsct1dd5aufnurxcvbs UNIQUE (email);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uk6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email);

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT uk_attendance_student_date UNIQUE (student_id, date);

ALTER TABLE ONLY public.students
    ADD CONSTRAINT ukh7gboo6v79gig1eo7lt1fubew UNIQUE (student_number);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT ukr43af9ap4edm43mmtq01oddj6 UNIQUE (username);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.justifications
    ADD CONSTRAINT fk1jn1o22xxkyl912491kyrb6fl FOREIGN KEY (student_id) REFERENCES public.students(id);

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk1t76r6alksnxois057qwyooaj FOREIGN KEY (group_id) REFERENCES public.groups_(id);

ALTER TABLE ONLY public.cover_assignments
    ADD CONSTRAINT fk3s6pssn37tv5o415c0u5kweyl FOREIGN KEY (period_id) REFERENCES public.class_periods(id);

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk5uxbw3kpkq8nrljql5721i9lt FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk7bm4q4wptspkenhrsjgatdmk0 FOREIGN KEY (student_id) REFERENCES public.students(id);

ALTER TABLE ONLY public.teacher_absences
    ADD CONSTRAINT fk7evtpdlful61dnxwe6k14yrwy FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);

ALTER TABLE ONLY public.schedule_slots
    ADD CONSTRAINT fkagvlvv3qf88xuw24fr90x0wro FOREIGN KEY (group_id) REFERENCES public.groups_(id);

ALTER TABLE ONLY public.teacher_absence_groups
    ADD CONSTRAINT fkf3tw25d1pwv6e4lyheapjisdb FOREIGN KEY (teacher_absence_id) REFERENCES public.teacher_absences(id);

ALTER TABLE ONLY public.schedule_slots
    ADD CONSTRAINT fkfwlcdkrf0cwe6ggvg93wlu5mk FOREIGN KEY (period_id) REFERENCES public.class_periods(id);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fkh8y98ht94fcs3ndq0d2k0rh1 FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);

ALTER TABLE ONLY public.cover_assignments
    ADD CONSTRAINT fklgd51ngs8wexeu1hivsvyt3cr FOREIGN KEY (group_id) REFERENCES public.groups_(id);

ALTER TABLE ONLY public.schedule_slots
    ADD CONSTRAINT fklu53kh910qcerx7sjh6t5kdmp FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);

ALTER TABLE ONLY public.students
    ADD CONSTRAINT fksq352c5w0rxxcj2y6n6hxfj65 FOREIGN KEY (group_id) REFERENCES public.groups_(id);

ALTER TABLE ONLY public.teacher_absence_periods
    ADD CONSTRAINT fkt7hi9ciyp6sjekyhia7jt6rk6 FOREIGN KEY (teacher_absence_id) REFERENCES public.teacher_absences(id);

ALTER TABLE ONLY public.groups_
    ADD CONSTRAINT fktt887e51h1e2hjp39qwl9mwa FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);
