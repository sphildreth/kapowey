--
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4 (Debian 12.4-1.pgdg100+1)
-- Dumped by pg_dump version 12.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE kapowey;
--
-- Name: kapowey; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE kapowey WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE kapowey OWNER TO postgres;

\connect kapowey

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: e_rating; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.e_rating AS ENUM (
    'Not Specified',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent'
);


ALTER TYPE public.e_rating OWNER TO postgres;

--
-- Name: e_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.e_status AS ENUM (
    'New',
    'Imported',
    'Ok',
    'Edited',
    'Pending Review',
    'Under Review',
    'Locked',
    'Inactive'
);


ALTER TYPE public.e_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_application; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_application (
    api_application_id integer NOT NULL,
    status public.e_status DEFAULT 'New'::public.e_status,
    api_key uuid DEFAULT public.uuid_generate_v4(),
    name character varying(500) NOT NULL,
    short_name character varying(10) NOT NULL,
    description text,
    url character varying(1000),
    tags text[],
    last_activity timestamp with time zone,
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer
);


ALTER TABLE public.api_application OWNER TO postgres;

--
-- Name: api_application_api_application_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.api_application ALTER COLUMN api_application_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.api_application_api_application_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collection (
    collection_id integer NOT NULL,
    user_id integer,
    status public.e_status DEFAULT 'New'::public.e_status,
    sort_order integer,
    api_key uuid DEFAULT public.uuid_generate_v4(),
    name character varying(500) NOT NULL,
    short_name character varying(10) NOT NULL,
    description text,
    tags text[],
    is_public boolean DEFAULT false,
    last_activity timestamp with time zone,
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.collection OWNER TO postgres;

--
-- Name: collection_collection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.collection ALTER COLUMN collection_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.collection_collection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: collection_issue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collection_issue (
    collection_issue_id integer NOT NULL,
    collection_id integer,
    issue_id integer,
    status public.e_status DEFAULT 'New'::public.e_status,
    grade_id integer,
    rating public.e_rating DEFAULT 'Not Specified'::public.e_rating,
    sort_order integer,
    api_key uuid DEFAULT public.uuid_generate_v4(),
    notes text,
    tags text[],
    number_of_copies_owned integer,
    is_digital boolean DEFAULT false,
    is_wanted boolean DEFAULT false,
    is_public boolean DEFAULT false,
    has_read boolean DEFAULT false,
    is_for_sale boolean DEFAULT false,
    price_paid numeric(12,2),
    acquisition_date timestamp with time zone,
    last_activity timestamp with time zone,
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.collection_issue OWNER TO postgres;

--
-- Name: collection_issue_collection_issue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.collection_issue ALTER COLUMN collection_issue_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.collection_issue_collection_issue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: collection_issue_grade_term; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collection_issue_grade_term (
    collection_issue_id integer NOT NULL,
    grade_term_id integer NOT NULL
);


ALTER TABLE public.collection_issue_grade_term OWNER TO postgres;

--
-- Name: franchise; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.franchise (
    franchise_id integer NOT NULL,
    publisher_id integer,
    parent_franchise_id integer,
    franchise_category_id integer,
    status public.e_status DEFAULT 'New'::public.e_status,
    api_key uuid DEFAULT public.uuid_generate_v4(),
    gcd_id integer,
    name character varying(500) NOT NULL,
    short_name character varying(20) NOT NULL,
    year_began integer,
    year_end integer,
    description text,
    url character varying(1000),
    tags text[],
    series_count integer DEFAULT 0 NOT NULL,
    issue_count integer DEFAULT 0 NOT NULL,
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer
);


ALTER TABLE public.franchise OWNER TO postgres;

--
-- Name: franchise_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.franchise_category (
    franchise_category_id integer NOT NULL,
    parent_franchise_category_id integer,
    status public.e_status DEFAULT 'New'::public.e_status,
    name character varying(500) NOT NULL,
    short_name character varying(10) NOT NULL,
    description text,
    url character varying(1000),
    tags text[],
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer,
    api_key uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE public.franchise_category OWNER TO postgres;

--
-- Name: franchise_category_franchise_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.franchise_category ALTER COLUMN franchise_category_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.franchise_category_franchise_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: franchise_franchise_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.franchise ALTER COLUMN franchise_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.franchise_franchise_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: genre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genre (
    genre_id integer NOT NULL,
    parent_genre_id integer,
    status public.e_status DEFAULT 'New'::public.e_status,
    name character varying(500) NOT NULL,
    short_name character varying(10) NOT NULL,
    description text,
    url character varying(1000),
    tags text[],
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer
);


ALTER TABLE public.genre OWNER TO postgres;

--
-- Name: genre_genre_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.genre ALTER COLUMN genre_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.genre_genre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: grade; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grade (
    grade_id integer NOT NULL,
    status public.e_status DEFAULT 'New'::public.e_status,
    scale numeric(3,1),
    sort_order integer,
    name character varying(500) NOT NULL,
    abbreviation character varying(6) NOT NULL,
    description text,
    api_key uuid DEFAULT public.uuid_generate_v4(),
    notes text,
    tags text[],
    is_basic_grade boolean DEFAULT false,
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer
);


ALTER TABLE public.grade OWNER TO postgres;

--
-- Name: grade_grade_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.grade ALTER COLUMN grade_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.grade_grade_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: grade_term; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grade_term (
    grade_term_id integer NOT NULL,
    status public.e_status DEFAULT 'New'::public.e_status,
    sort_order integer,
    name character varying(500) NOT NULL,
    description text,
    api_key uuid DEFAULT public.uuid_generate_v4(),
    tags text[],
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer
);


ALTER TABLE public.grade_term OWNER TO postgres;

--
-- Name: grade_term_grade_term_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.grade_term ALTER COLUMN grade_term_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.grade_term_grade_term_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: issue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.issue (
    issue_id integer NOT NULL,
    series_id integer,
    status public.e_status DEFAULT 'New'::public.e_status,
    rating public.e_rating DEFAULT 'Not Specified'::public.e_rating,
    issuetype_id integer,
    api_key uuid DEFAULT public.uuid_generate_v4(),
    gcd_id integer,
    reprint_of_issue_id integer,
    sort_order integer,
    number character varying(10),
    title character varying(500) NOT NULL,
    variant_title character varying(500),
    short_title character varying(20),
    culture_code character varying(2) DEFAULT 'en'::character varying NOT NULL,
    description text,
    url character varying(1000),
    tags text[],
    key_date timestamp with time zone NOT NULL,
    isbn character varying(25),
    cover_price numeric(12,2),
    barcode character varying(25),
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer
);


ALTER TABLE public.issue OWNER TO postgres;

--
-- Name: issue_issue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.issue ALTER COLUMN issue_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.issue_issue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: issuetype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.issuetype (
    issuetype_id integer NOT NULL,
    status public.e_status DEFAULT 'New'::public.e_status,
    name character varying(500) NOT NULL,
    abbreviation character varying(2) NOT NULL,
    description text,
    tags text[],
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer,
    api_key uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE public.issuetype OWNER TO postgres;

--
-- Name: issuetype_issuetype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.issuetype ALTER COLUMN issuetype_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.issuetype_issuetype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: persisted_grant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persisted_grant (
    key character varying(200) NOT NULL,
    type character varying(50) NOT NULL,
    subject_id character varying(200),
    client_id character varying(200) NOT NULL,
    creation_time timestamp without time zone NOT NULL,
    expiration timestamp without time zone,
    data character varying(50000) NOT NULL
);


ALTER TABLE public.persisted_grant OWNER TO postgres;

--
-- Name: publisher; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publisher (
    publisher_id integer NOT NULL,
    parent_publisher_id integer,
    publisher_category_id integer,
    status public.e_status DEFAULT 'New'::public.e_status,
    api_key uuid DEFAULT public.uuid_generate_v4(),
    gcd_id integer,
    name character varying(500) NOT NULL,
    short_name character varying(10) NOT NULL,
    year_began integer,
    year_end integer,
    country_code character varying(3) DEFAULT 'USA'::character varying NOT NULL,
    description text,
    url character varying(1000),
    tags text[],
    franchise_count integer DEFAULT 0 NOT NULL,
    series_count integer DEFAULT 0 NOT NULL,
    issue_count integer DEFAULT 0 NOT NULL,
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer
);


ALTER TABLE public.publisher OWNER TO postgres;

--
-- Name: publisher_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publisher_category (
    publisher_category_id integer NOT NULL,
    parent_publisher_category_id integer,
    status public.e_status DEFAULT 'New'::public.e_status,
    name character varying(500) NOT NULL,
    short_name character varying(10) NOT NULL,
    description text,
    url character varying(1000),
    tags text[],
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer,
    api_key uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE public.publisher_category OWNER TO postgres;

--
-- Name: publisher_category_publisher_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.publisher_category ALTER COLUMN publisher_category_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.publisher_category_publisher_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: publisher_publisher_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.publisher ALTER COLUMN publisher_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.publisher_publisher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: series; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.series (
    series_id integer NOT NULL,
    franchise_id integer,
    series_category_id integer,
    genre_id integer,
    status public.e_status DEFAULT 'New'::public.e_status,
    rating public.e_rating DEFAULT 'Not Specified'::public.e_rating,
    api_key uuid DEFAULT public.uuid_generate_v4(),
    gcd_id integer,
    first_issue_id integer,
    last_issue_id integer,
    name character varying(500) NOT NULL,
    short_name character varying(20) NOT NULL,
    year_began integer,
    year_end integer,
    culture_code character varying(2) DEFAULT 'en'::character varying NOT NULL,
    description text,
    url character varying(1000),
    tags text[],
    issue_count integer DEFAULT 0 NOT NULL,
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer
);


ALTER TABLE public.series OWNER TO postgres;

--
-- Name: series_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.series_category (
    series_category_id integer NOT NULL,
    parent_series_category_id integer,
    status public.e_status DEFAULT 'New'::public.e_status,
    name character varying(500) NOT NULL,
    short_name character varying(10) NOT NULL,
    description text,
    url character varying(1000),
    tags text[],
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_user_id integer,
    modified_date timestamp with time zone,
    modified_user_id integer,
    reviewed_date timestamp with time zone,
    reviewed_user_id integer,
    api_key uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE public.series_category OWNER TO postgres;

--
-- Name: series_category_series_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.series_category ALTER COLUMN series_category_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.series_category_series_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: series_series_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.series ALTER COLUMN series_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.series_series_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    user_id integer NOT NULL,
    status public.e_status DEFAULT 'New'::public.e_status,
    api_key uuid DEFAULT public.uuid_generate_v4(),
    user_name character varying(256),
    normalized_user_name character varying(256),
    email character varying(256),
    normalized_email character varying(256),
    email_confirmed boolean DEFAULT false,
    password_hash text,
    security_stamp text,
    concurrency_stamp text,
    phone_number text,
    phone_number_confirmed boolean DEFAULT false,
    two_factor_enabled boolean DEFAULT false,
    lockout_end timestamp with time zone,
    lockout_enabled boolean DEFAULT false,
    access_failed_count integer NOT NULL,
    tags text[],
    is_public boolean DEFAULT false,
    created_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    modified_date timestamp with time zone,
    modified_user_id integer,
    last_authenticate_date timestamp with time zone,
    successful_authenticate_count integer
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: user_claim; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_claim (
    user_claim_id integer NOT NULL,
    user_id integer,
    claim_type text,
    claim_value text
);


ALTER TABLE public.user_claim OWNER TO postgres;

--
-- Name: user_claim_user_claim_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.user_claim ALTER COLUMN user_claim_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_claim_user_claim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_device_code; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_device_code (
    user_code character varying(200) NOT NULL,
    device_code character varying(200) NOT NULL,
    subject_id character varying(200),
    client_id character varying(200) NOT NULL,
    creation_time timestamp without time zone NOT NULL,
    expiration timestamp without time zone NOT NULL,
    data character varying(50000) NOT NULL
);


ALTER TABLE public.user_device_code OWNER TO postgres;

--
-- Name: user_login; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_login (
    login_provider character varying(128) NOT NULL,
    provider_key character varying(128) NOT NULL,
    provider_display_name text,
    user_id integer
);


ALTER TABLE public.user_login OWNER TO postgres;

--
-- Name: user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_role (
    user_role_id integer NOT NULL,
    name character varying(256),
    normalized_name character varying(256),
    concurrency_stamp text
);


ALTER TABLE public.user_role OWNER TO postgres;

--
-- Name: user_role_claim; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_role_claim (
    user_role_claim_id integer NOT NULL,
    user_role_id integer,
    claim_type text,
    claim_value text
);


ALTER TABLE public.user_role_claim OWNER TO postgres;

--
-- Name: user_role_claim_user_role_claim_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.user_role_claim ALTER COLUMN user_role_claim_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_role_claim_user_role_claim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_role_user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.user_role ALTER COLUMN user_role_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_role_user_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_token (
    user_id integer NOT NULL,
    login_provider character varying(128) NOT NULL,
    name character varying(128) NOT NULL,
    value text
);


ALTER TABLE public.user_token OWNER TO postgres;

--
-- Name: user_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."user" ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_user_role (
    user_id integer NOT NULL,
    user_role_id integer NOT NULL
);


ALTER TABLE public.user_user_role OWNER TO postgres;

--
-- Data for Name: api_application; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_application (api_application_id, status, api_key, name, short_name, description, url, tags, last_activity, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.
COPY public.api_application (api_application_id, status, api_key, name, short_name, description, url, tags, last_activity, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM '$$PATH$$/3333.dat';

--
-- Data for Name: collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection (collection_id, user_id, status, sort_order, api_key, name, short_name, description, tags, is_public, last_activity, created_date) FROM stdin;
\.
COPY public.collection (collection_id, user_id, status, sort_order, api_key, name, short_name, description, tags, is_public, last_activity, created_date) FROM '$$PATH$$/3320.dat';

--
-- Data for Name: collection_issue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection_issue (collection_issue_id, collection_id, issue_id, status, grade_id, rating, sort_order, api_key, notes, tags, number_of_copies_owned, is_digital, is_wanted, is_public, has_read, is_for_sale, price_paid, acquisition_date, last_activity, created_date) FROM stdin;
\.
COPY public.collection_issue (collection_issue_id, collection_id, issue_id, status, grade_id, rating, sort_order, api_key, notes, tags, number_of_copies_owned, is_digital, is_wanted, is_public, has_read, is_for_sale, price_paid, acquisition_date, last_activity, created_date) FROM '$$PATH$$/3357.dat';

--
-- Data for Name: collection_issue_grade_term; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection_issue_grade_term (collection_issue_id, grade_term_id) FROM stdin;
\.
COPY public.collection_issue_grade_term (collection_issue_id, grade_term_id) FROM '$$PATH$$/3358.dat';

--
-- Data for Name: franchise; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.franchise (franchise_id, publisher_id, parent_franchise_id, franchise_category_id, status, api_key, gcd_id, name, short_name, year_began, year_end, description, url, tags, series_count, issue_count, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.
COPY public.franchise (franchise_id, publisher_id, parent_franchise_id, franchise_category_id, status, api_key, gcd_id, name, short_name, year_began, year_end, description, url, tags, series_count, issue_count, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM '$$PATH$$/3341.dat';

--
-- Data for Name: franchise_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.franchise_category (franchise_category_id, parent_franchise_category_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM stdin;
\.
COPY public.franchise_category (franchise_category_id, parent_franchise_category_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM '$$PATH$$/3339.dat';

--
-- Data for Name: genre; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.genre (genre_id, parent_genre_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.
COPY public.genre (genre_id, parent_genre_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM '$$PATH$$/3345.dat';

--
-- Data for Name: grade; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grade (grade_id, status, scale, sort_order, name, abbreviation, description, api_key, notes, tags, is_basic_grade, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.
COPY public.grade (grade_id, status, scale, sort_order, name, abbreviation, description, api_key, notes, tags, is_basic_grade, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM '$$PATH$$/3353.dat';

--
-- Data for Name: grade_term; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grade_term (grade_term_id, status, sort_order, name, description, api_key, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.
COPY public.grade_term (grade_term_id, status, sort_order, name, description, api_key, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM '$$PATH$$/3355.dat';

--
-- Data for Name: issue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.issue (issue_id, series_id, status, rating, issuetype_id, api_key, gcd_id, reprint_of_issue_id, sort_order, number, title, variant_title, short_title, culture_code, description, url, tags, key_date, isbn, cover_price, barcode, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.
COPY public.issue (issue_id, series_id, status, rating, issuetype_id, api_key, gcd_id, reprint_of_issue_id, sort_order, number, title, variant_title, short_title, culture_code, description, url, tags, key_date, isbn, cover_price, barcode, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM '$$PATH$$/3351.dat';

--
-- Data for Name: issuetype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.issuetype (issuetype_id, status, name, abbreviation, description, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM stdin;
\.
COPY public.issuetype (issuetype_id, status, name, abbreviation, description, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM '$$PATH$$/3349.dat';

--
-- Data for Name: persisted_grant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.persisted_grant (key, type, subject_id, client_id, creation_time, expiration, data) FROM stdin;
\.
COPY public.persisted_grant (key, type, subject_id, client_id, creation_time, expiration, data) FROM '$$PATH$$/3331.dat';

--
-- Data for Name: publisher; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publisher (publisher_id, parent_publisher_id, publisher_category_id, status, api_key, gcd_id, name, short_name, year_began, year_end, country_code, description, url, tags, franchise_count, series_count, issue_count, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.
COPY public.publisher (publisher_id, parent_publisher_id, publisher_category_id, status, api_key, gcd_id, name, short_name, year_began, year_end, country_code, description, url, tags, franchise_count, series_count, issue_count, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM '$$PATH$$/3337.dat';

--
-- Data for Name: publisher_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publisher_category (publisher_category_id, parent_publisher_category_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM stdin;
\.
COPY public.publisher_category (publisher_category_id, parent_publisher_category_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM '$$PATH$$/3335.dat';

--
-- Data for Name: series; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.series (series_id, franchise_id, series_category_id, genre_id, status, rating, api_key, gcd_id, first_issue_id, last_issue_id, name, short_name, year_began, year_end, culture_code, description, url, tags, issue_count, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.
COPY public.series (series_id, franchise_id, series_category_id, genre_id, status, rating, api_key, gcd_id, first_issue_id, last_issue_id, name, short_name, year_began, year_end, culture_code, description, url, tags, issue_count, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM '$$PATH$$/3347.dat';

--
-- Data for Name: series_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.series_category (series_category_id, parent_series_category_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM stdin;
\.
COPY public.series_category (series_category_id, parent_series_category_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM '$$PATH$$/3343.dat';

--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (user_id, status, api_key, user_name, normalized_user_name, email, normalized_email, email_confirmed, password_hash, security_stamp, concurrency_stamp, phone_number, phone_number_confirmed, two_factor_enabled, lockout_end, lockout_enabled, access_failed_count, tags, is_public, created_date, modified_date, modified_user_id, last_authenticate_date, successful_authenticate_count) FROM stdin;
\.
COPY public."user" (user_id, status, api_key, user_name, normalized_user_name, email, normalized_email, email_confirmed, password_hash, security_stamp, concurrency_stamp, phone_number, phone_number_confirmed, two_factor_enabled, lockout_end, lockout_enabled, access_failed_count, tags, is_public, created_date, modified_date, modified_user_id, last_authenticate_date, successful_authenticate_count) FROM '$$PATH$$/3318.dat';

--
-- Data for Name: user_claim; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_claim (user_claim_id, user_id, claim_type, claim_value) FROM stdin;
\.
COPY public.user_claim (user_claim_id, user_id, claim_type, claim_value) FROM '$$PATH$$/3322.dat';

--
-- Data for Name: user_device_code; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_device_code (user_code, device_code, subject_id, client_id, creation_time, expiration, data) FROM stdin;
\.
COPY public.user_device_code (user_code, device_code, subject_id, client_id, creation_time, expiration, data) FROM '$$PATH$$/3330.dat';

--
-- Data for Name: user_login; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_login (login_provider, provider_key, provider_display_name, user_id) FROM stdin;
\.
COPY public.user_login (login_provider, provider_key, provider_display_name, user_id) FROM '$$PATH$$/3323.dat';

--
-- Data for Name: user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_role (user_role_id, name, normalized_name, concurrency_stamp) FROM stdin;
\.
COPY public.user_role (user_role_id, name, normalized_name, concurrency_stamp) FROM '$$PATH$$/3326.dat';

--
-- Data for Name: user_role_claim; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_role_claim (user_role_claim_id, user_role_id, claim_type, claim_value) FROM stdin;
\.
COPY public.user_role_claim (user_role_claim_id, user_role_id, claim_type, claim_value) FROM '$$PATH$$/3328.dat';

--
-- Data for Name: user_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_token (user_id, login_provider, name, value) FROM stdin;
\.
COPY public.user_token (user_id, login_provider, name, value) FROM '$$PATH$$/3324.dat';

--
-- Data for Name: user_user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_user_role (user_id, user_role_id) FROM stdin;
\.
COPY public.user_user_role (user_id, user_role_id) FROM '$$PATH$$/3329.dat';

--
-- Name: api_application_api_application_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.api_application_api_application_id_seq', 1, false);


--
-- Name: collection_collection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collection_collection_id_seq', 1, false);


--
-- Name: collection_issue_collection_issue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collection_issue_collection_issue_id_seq', 1, false);


--
-- Name: franchise_category_franchise_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.franchise_category_franchise_category_id_seq', 1, false);


--
-- Name: franchise_franchise_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.franchise_franchise_id_seq', 1, false);


--
-- Name: genre_genre_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.genre_genre_id_seq', 1, false);


--
-- Name: grade_grade_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grade_grade_id_seq', 1, false);


--
-- Name: grade_term_grade_term_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grade_term_grade_term_id_seq', 1, false);


--
-- Name: issue_issue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.issue_issue_id_seq', 1, false);


--
-- Name: issuetype_issuetype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.issuetype_issuetype_id_seq', 1, false);


--
-- Name: publisher_category_publisher_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publisher_category_publisher_category_id_seq', 1, false);


--
-- Name: publisher_publisher_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publisher_publisher_id_seq', 1, false);


--
-- Name: series_category_series_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.series_category_series_category_id_seq', 1, false);


--
-- Name: series_series_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.series_series_id_seq', 1, false);


--
-- Name: user_claim_user_claim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_claim_user_claim_id_seq', 1, false);


--
-- Name: user_role_claim_user_role_claim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_role_claim_user_role_claim_id_seq', 1, false);


--
-- Name: user_role_user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_role_user_role_id_seq', 4, true);


--
-- Name: user_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_user_id_seq', 1, true);


--
-- Name: api_application api_application_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_application
    ADD CONSTRAINT api_application_id_pkey PRIMARY KEY (api_application_id);


--
-- Name: collection_issue collection_issue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue
    ADD CONSTRAINT collection_issue_pkey PRIMARY KEY (collection_issue_id);


--
-- Name: collection collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_pkey PRIMARY KEY (collection_id);


--
-- Name: franchise_category franchise_category_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise_category
    ADD CONSTRAINT franchise_category_id_pkey PRIMARY KEY (franchise_category_id);


--
-- Name: franchise franchise_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT franchise_pkey PRIMARY KEY (franchise_id);


--
-- Name: genre genre_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_id_pkey PRIMARY KEY (genre_id);


--
-- Name: grade grade_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade
    ADD CONSTRAINT grade_pkey PRIMARY KEY (grade_id);


--
-- Name: grade_term grade_term_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_term
    ADD CONSTRAINT grade_term_id_pkey PRIMARY KEY (grade_term_id);


--
-- Name: issue issue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_pkey PRIMARY KEY (issue_id);


--
-- Name: issuetype issuetype_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuetype
    ADD CONSTRAINT issuetype_id_pkey PRIMARY KEY (issuetype_id);


--
-- Name: collection_issue_grade_term pk_collection_issue_grade_term; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue_grade_term
    ADD CONSTRAINT pk_collection_issue_grade_term PRIMARY KEY (collection_issue_id, grade_term_id);


--
-- Name: user_device_code pk_device_codes; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_device_code
    ADD CONSTRAINT pk_device_codes PRIMARY KEY (user_code);


--
-- Name: persisted_grant pk_persisted_grants; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persisted_grant
    ADD CONSTRAINT pk_persisted_grants PRIMARY KEY (key);


--
-- Name: user_login pk_user_logins; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login
    ADD CONSTRAINT pk_user_logins PRIMARY KEY (login_provider, provider_key);


--
-- Name: user_user_role pk_user_roles; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_user_role
    ADD CONSTRAINT pk_user_roles PRIMARY KEY (user_id, user_role_id);


--
-- Name: user_token pk_user_tokens; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_token
    ADD CONSTRAINT pk_user_tokens PRIMARY KEY (user_id, login_provider, name);


--
-- Name: publisher_category publisher_category_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_category
    ADD CONSTRAINT publisher_category_id_pkey PRIMARY KEY (publisher_category_id);


--
-- Name: publisher publisher_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_pkey PRIMARY KEY (publisher_id);


--
-- Name: series_category series_category_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series_category
    ADD CONSTRAINT series_category_id_pkey PRIMARY KEY (series_category_id);


--
-- Name: series series_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_pkey PRIMARY KEY (series_id);


--
-- Name: user_claim user_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_claim
    ADD CONSTRAINT user_claim_pkey PRIMARY KEY (user_claim_id);


--
-- Name: user user_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_id_pkey PRIMARY KEY (user_id);


--
-- Name: user_role_claim user_role_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_claim
    ADD CONSTRAINT user_role_claim_pkey PRIMARY KEY (user_role_claim_id);


--
-- Name: user_role user_role_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_id_pkey PRIMARY KEY (user_role_id);


--
-- Name: api_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX api_api_key_idx ON public.api_application USING btree (api_key);


--
-- Name: api_application_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX api_application_name_idx ON public.api_application USING btree (name);


--
-- Name: api_application_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX api_application_short_name_idx ON public.api_application USING btree (short_name);


--
-- Name: api_application_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_application_tags ON public.api_application USING gin (tags);


--
-- Name: collection_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_api_key_idx ON public.collection USING btree (api_key);


--
-- Name: collection_issue_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_issue_api_key_idx ON public.collection_issue USING btree (api_key);


--
-- Name: collection_issue_collection_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_issue_collection_id_idx ON public.collection_issue USING btree (collection_id);


--
-- Name: collection_issue_grade_term_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_issue_grade_term_idx ON public.collection_issue_grade_term USING btree (collection_issue_id, grade_term_id);


--
-- Name: collection_issue_issue_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_issue_issue_id_idx ON public.collection_issue USING btree (issue_id);


--
-- Name: collection_issue_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX collection_issue_tags ON public.collection_issue USING gin (tags);


--
-- Name: collection_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_name_idx ON public.collection USING btree (name);


--
-- Name: collection_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_short_name_idx ON public.collection USING btree (short_name);


--
-- Name: collection_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX collection_tags ON public.collection USING gin (tags);


--
-- Name: collection_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_user_id_idx ON public.collection USING btree (user_id);


--
-- Name: franchise_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX franchise_api_key_idx ON public.franchise USING btree (api_key);


--
-- Name: franchise_category_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX franchise_category_name_idx ON public.franchise_category USING btree (name);


--
-- Name: franchise_category_parent_franchise_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_category_parent_franchise_category_idx ON public.franchise_category USING btree (parent_franchise_category_id);


--
-- Name: franchise_category_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX franchise_category_short_name_idx ON public.franchise_category USING btree (short_name);


--
-- Name: franchise_category_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_category_tags ON public.franchise_category USING gin (tags);


--
-- Name: franchise_franchise_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_franchise_category_idx ON public.franchise USING btree (franchise_category_id);


--
-- Name: franchise_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX franchise_name_idx ON public.franchise USING btree (name);


--
-- Name: franchise_parent_franchise_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_parent_franchise_idx ON public.franchise USING btree (parent_franchise_id);


--
-- Name: franchise_publisher_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_publisher_idx ON public.franchise USING btree (publisher_id);


--
-- Name: franchise_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX franchise_short_name_idx ON public.franchise USING btree (short_name);


--
-- Name: franchise_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_tags ON public.franchise USING gin (tags);


--
-- Name: genre_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX genre_name_idx ON public.genre USING btree (name);


--
-- Name: genre_parent_genre_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX genre_parent_genre_idx ON public.genre USING btree (parent_genre_id);


--
-- Name: genre_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX genre_short_name_idx ON public.genre USING btree (short_name);


--
-- Name: genre_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX genre_tags ON public.genre USING gin (tags);


--
-- Name: grade_abbreviation_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_abbreviation_idx ON public.grade USING btree (abbreviation);


--
-- Name: grade_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_name_idx ON public.grade USING btree (name);


--
-- Name: grade_scale_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_scale_idx ON public.grade USING btree (scale);


--
-- Name: grade_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX grade_tags ON public.grade USING gin (tags);


--
-- Name: grade_term_ide_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX grade_term_ide_tags ON public.grade_term USING gin (tags);


--
-- Name: grade_term_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_term_name_idx ON public.grade_term USING btree (name);


--
-- Name: issue_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX issue_api_key_idx ON public.issue USING btree (api_key);


--
-- Name: issue_issuetype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issue_issuetype_idx ON public.issue USING btree (issuetype_id);


--
-- Name: issue_series_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issue_series_idx ON public.issue USING btree (series_id);


--
-- Name: issue_short_title_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX issue_short_title_idx ON public.issue USING btree (short_title);


--
-- Name: issue_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issue_tags ON public.issue USING gin (tags);


--
-- Name: issue_title_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX issue_title_idx ON public.issue USING btree (title);


--
-- Name: issuetype_abbreviation_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX issuetype_abbreviation_idx ON public.issuetype USING btree (abbreviation);


--
-- Name: issuetype_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX issuetype_name_idx ON public.issuetype USING btree (name);


--
-- Name: issuetype_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issuetype_tags ON public.issuetype USING gin (tags);


--
-- Name: ix_device_codes_device_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_device_codes_device_code ON public.user_device_code USING btree (device_code);


--
-- Name: ix_device_codes_expiration; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_device_codes_expiration ON public.user_device_code USING btree (expiration);


--
-- Name: ix_persisted_grants_expiration; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_persisted_grants_expiration ON public.persisted_grant USING btree (expiration);


--
-- Name: ix_persisted_grants_subject_id_client_id_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_persisted_grants_subject_id_client_id_type ON public.persisted_grant USING btree (subject_id, client_id, type);


--
-- Name: ix_user_claim_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_claim_user_id ON public.user_claim USING btree (user_id);


--
-- Name: ix_user_logins_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_logins_user_id ON public.user_login USING btree (user_id);


--
-- Name: ix_user_roles_role_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_roles_role_id ON public.user_user_role USING btree (user_id, user_role_id);


--
-- Name: ix_user_token_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_token_user_id ON public.user_login USING btree (user_id);


--
-- Name: pc_parent_pc_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pc_parent_pc_idx ON public.publisher_category USING btree (parent_publisher_category_id);


--
-- Name: publisher_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX publisher_api_key_idx ON public.publisher USING btree (api_key);


--
-- Name: publisher_category_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX publisher_category_name_idx ON public.publisher_category USING btree (name);


--
-- Name: publisher_category_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX publisher_category_short_name_idx ON public.publisher_category USING btree (short_name);


--
-- Name: publisher_category_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX publisher_category_tags ON public.publisher_category USING gin (tags);


--
-- Name: publisher_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX publisher_name_idx ON public.publisher USING btree (name);


--
-- Name: publisher_parent_publisher_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX publisher_parent_publisher_idx ON public.publisher USING btree (parent_publisher_id);


--
-- Name: publisher_publisher_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX publisher_publisher_category_idx ON public.publisher USING btree (publisher_category_id);


--
-- Name: publisher_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX publisher_short_name_idx ON public.publisher USING btree (short_name);


--
-- Name: publisher_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX publisher_tags ON public.publisher USING gin (tags);


--
-- Name: series_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX series_api_key_idx ON public.series USING btree (api_key);


--
-- Name: series_category_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX series_category_name_idx ON public.series_category USING btree (name);


--
-- Name: series_category_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX series_category_short_name_idx ON public.series_category USING btree (short_name);


--
-- Name: series_category_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_category_tags ON public.series_category USING gin (tags);


--
-- Name: series_franchise_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_franchise_idx ON public.series USING btree (franchise_id);


--
-- Name: series_genre_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_genre_idx ON public.series USING btree (genre_id);


--
-- Name: series_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX series_name_idx ON public.series USING btree (name);


--
-- Name: series_parent_series_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_parent_series_category_idx ON public.series_category USING btree (parent_series_category_id);


--
-- Name: series_series_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_series_category_idx ON public.series USING btree (series_category_id);


--
-- Name: series_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX series_short_name_idx ON public.series USING btree (short_name);


--
-- Name: series_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_tags ON public.series USING gin (tags);


--
-- Name: user_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_api_key_idx ON public."user" USING btree (api_key);


--
-- Name: user_claim_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_claim_user_idx ON public.user_claim USING btree (user_claim_id);


--
-- Name: user_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_email_idx ON public."user" USING btree (normalized_email);


--
-- Name: user_role_claim_user_role_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_role_claim_user_role_idx ON public.user_role_claim USING btree (user_role_id);


--
-- Name: user_role_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_role_name_idx ON public.user_role USING btree (normalized_name);


--
-- Name: user_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_tags ON public."user" USING gin (tags);


--
-- Name: user_username_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_username_idx ON public."user" USING btree (normalized_user_name);


--
-- Name: api_application api_application_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_application
    ADD CONSTRAINT api_application_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: api_application api_application_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_application
    ADD CONSTRAINT api_application_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: api_application api_application_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_application
    ADD CONSTRAINT api_application_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: collection_issue collection_issue_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue
    ADD CONSTRAINT collection_issue_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collection(collection_id) ON DELETE CASCADE;


--
-- Name: collection_issue collection_issue_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue
    ADD CONSTRAINT collection_issue_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade(grade_id) ON DELETE RESTRICT;


--
-- Name: collection_issue_grade_term collection_issue_grade_term_collection_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue_grade_term
    ADD CONSTRAINT collection_issue_grade_term_collection_issue_id_fkey FOREIGN KEY (collection_issue_id) REFERENCES public.collection_issue(collection_issue_id) ON DELETE CASCADE;


--
-- Name: collection_issue_grade_term collection_issue_grade_term_grade_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue_grade_term
    ADD CONSTRAINT collection_issue_grade_term_grade_term_id_fkey FOREIGN KEY (grade_term_id) REFERENCES public.grade_term(grade_term_id) ON DELETE CASCADE;


--
-- Name: collection_issue collection_issue_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue
    ADD CONSTRAINT collection_issue_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES public.issue(issue_id) ON DELETE RESTRICT;


--
-- Name: collection collection_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id) ON DELETE CASCADE;


--
-- Name: franchise_category franchise_category_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise_category
    ADD CONSTRAINT franchise_category_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: franchise_category franchise_category_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise_category
    ADD CONSTRAINT franchise_category_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: franchise_category franchise_category_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise_category
    ADD CONSTRAINT franchise_category_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: franchise franchise_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT franchise_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: franchise franchise_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT franchise_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: franchise franchise_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT franchise_publisher_id_fkey FOREIGN KEY (publisher_id) REFERENCES public.publisher(publisher_id) ON DELETE CASCADE;


--
-- Name: franchise franchise_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT franchise_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: genre genre_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: genre genre_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: genre genre_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: grade grade_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade
    ADD CONSTRAINT grade_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: grade grade_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade
    ADD CONSTRAINT grade_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: grade grade_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade
    ADD CONSTRAINT grade_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: grade_term grade_term_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_term
    ADD CONSTRAINT grade_term_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: grade_term grade_term_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_term
    ADD CONSTRAINT grade_term_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: grade_term grade_term_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_term
    ADD CONSTRAINT grade_term_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: issue issue_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: issue issue_issuetype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_issuetype_id_fkey FOREIGN KEY (issuetype_id) REFERENCES public.issuetype(issuetype_id) ON DELETE RESTRICT;


--
-- Name: issue issue_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: issue issue_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: issue issue_series_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series(series_id) ON DELETE CASCADE;


--
-- Name: issuetype issuetype_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuetype
    ADD CONSTRAINT issuetype_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: issuetype issuetype_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuetype
    ADD CONSTRAINT issuetype_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: issuetype issuetype_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuetype
    ADD CONSTRAINT issuetype_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: publisher_category publisher_category_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_category
    ADD CONSTRAINT publisher_category_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: publisher_category publisher_category_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_category
    ADD CONSTRAINT publisher_category_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: publisher_category publisher_category_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_category
    ADD CONSTRAINT publisher_category_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: publisher publisher_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: publisher publisher_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: publisher publisher_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: series_category series_category_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series_category
    ADD CONSTRAINT series_category_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: series_category series_category_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series_category
    ADD CONSTRAINT series_category_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: series_category series_category_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series_category
    ADD CONSTRAINT series_category_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: series series_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: series series_franchise_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_franchise_id_fkey FOREIGN KEY (franchise_id) REFERENCES public.franchise(franchise_id) ON DELETE CASCADE;


--
-- Name: series series_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: series series_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: user_claim user_claim_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_claim
    ADD CONSTRAINT user_claim_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id) ON DELETE CASCADE;


--
-- Name: user_login user_login_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login
    ADD CONSTRAINT user_login_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id) ON DELETE CASCADE;


--
-- Name: user user_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- Name: user_role_claim user_role_claim_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_claim
    ADD CONSTRAINT user_role_claim_user_role_id_fkey FOREIGN KEY (user_role_id) REFERENCES public.user_role(user_role_id) ON DELETE CASCADE;


--
-- Name: user_token user_token_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_token
    ADD CONSTRAINT user_token_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id) ON DELETE CASCADE;


--
-- Name: user_user_role user_user_role_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_user_role
    ADD CONSTRAINT user_user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id) ON DELETE CASCADE;


--
-- Name: user_user_role user_user_role_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_user_role
    ADD CONSTRAINT user_user_role_user_role_id_fkey FOREIGN KEY (user_role_id) REFERENCES public.user_role(user_role_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--




BEGIN;

INSERT INTO issuetype (abbreviation, name) VALUES ('AN', 'Annual');
INSERT INTO issuetype (abbreviation, name) VALUES ('BO', 'Bound');
INSERT INTO issuetype (abbreviation, name) VALUES ('DI', 'Digest');
INSERT INTO issuetype (abbreviation, name) VALUES ('DG', 'Digital');
INSERT INTO issuetype (abbreviation, name) VALUES ('FL', 'Floppy (standard/comic/issue)');
INSERT INTO issuetype (abbreviation, name) VALUES ('GN', 'Graphic Novel (book/usually has isbn)');
INSERT INTO issuetype (abbreviation, name) VALUES ('GS', 'Giant-Size');
INSERT INTO issuetype (abbreviation, name) VALUES ('HC', 'Hardcover');
INSERT INTO issuetype (abbreviation, name) VALUES ('OB', 'Omnibus');
INSERT INTO issuetype (abbreviation, name, description) VALUES ('OS', 'One-Shot', 'Single stand alone issue with self-contained story, not part of a series');
INSERT INTO issuetype (abbreviation, name) VALUES ('PA', 'Pamphlet');
INSERT INTO issuetype (abbreviation, name) VALUES ('PR', 'Prestige');
INSERT INTO issuetype (abbreviation, name) VALUES ('QA', 'Quarterly');
INSERT INTO issuetype (abbreviation, name) VALUES ('SP', 'Special');
INSERT INTO issuetype (abbreviation, name, description) VALUES ('TP', 'Trade (Trade Paperback, TPB)', 'A collection of issues or stories.');
INSERT INTO issuetype (abbreviation, name) VALUES ('VI', 'Variant');


INSERT INTO grade (scale, abbreviation, "name") VALUES (10.0,'GM','Gem Mint');
INSERT INTO grade (scale, abbreviation, "name") VALUES (9.9,'M','Mint');
INSERT INTO grade (scale, abbreviation, "name") VALUES (9.8,'NM/M','Near Mint/Mint');
INSERT INTO grade (scale, abbreviation, "name") VALUES (9.6,'NM+','Near Mint+');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (9.4,'NM','Near Mint', true);
INSERT INTO grade (scale, abbreviation, "name") VALUES (9.2,'NM-','Near Mint-');
INSERT INTO grade (scale, abbreviation, "name") VALUES (9.0,'VF/NM','Very Fine/Near Mint');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (8.0,'VF','Very Fine', true);
INSERT INTO grade (scale, abbreviation, "name") VALUES (8.5,'VF+','Very Fine+');
INSERT INTO grade (scale, abbreviation, "name") VALUES (7.5,'VF-','Very Find-');
INSERT INTO grade (scale, abbreviation, "name") VALUES (7.0,'FN/VF','Fine/Very Fine');
INSERT INTO grade (scale, abbreviation, "name") VALUES (6.5,'FN+','Fine+');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (6.0,'FN','Fine', true);
INSERT INTO grade (scale, abbreviation, "name") VALUES (5.5,'FN-','Fine-');
INSERT INTO grade (scale, abbreviation, "name") VALUES (5.0,'VG/FN','Very Good/Fine');
INSERT INTO grade (scale, abbreviation, "name") VALUES (4.5,'VG+','Very Good+');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (4.0,'VG','Very Good', true);
INSERT INTO grade (scale, abbreviation, "name") VALUES (3.5,'VG-','Very Good-');
INSERT INTO grade (scale, abbreviation, "name") VALUES (3.0,'GD/VG','Good/Very Good');
INSERT INTO grade (scale, abbreviation, "name") VALUES (2.5,'GD+','Good+');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (2.0,'GD','Good', true);
INSERT INTO grade (scale, abbreviation, "name") VALUES (1.8,'GD-','Good-');
INSERT INTO grade (scale, abbreviation, "name") VALUES (1.5,'FR/GD','Fair/Good');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (1.0,'FR','Fair', true);
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (0.5,'PR','Poor', true);

INSERT INTO grade_term ("name", description) VALUES('Bend', 'When part of a comic is curved, interrupting the flat, smooth cover surface. Bends WILL NOT show distinct lines.');
INSERT INTO grade_term ("name", description) VALUES('Bindery Tear', 'A small horizontal rip in a comic''s cover that can usually be seen on both the front and the back. These are always found along the spine and should be graded like spine stress if they are shorter than 1/4".');
INSERT INTO grade_term ("name", description) VALUES('Chew', 'Damage caused by the gnawing of rodents or insects (usually). Results in multi-page paper loss with jagged edges. Very visually distinct.');
INSERT INTO grade_term ("name", description) VALUES('Cockling', 'Bubbling on a cover''s surface (typically a printing defect).');
INSERT INTO grade_term ("name", description) VALUES('Crease', 'A fold that causes ink removal/color break, usually resulting in a white line (see bend/fold).');
INSERT INTO grade_term ("name", description) VALUES('Denting', 'Indentations or dimpling (usually in the cover) that don''t penetrate the paper or remove any gloss, but do interrupt the smooth, flat surface.');
INSERT INTO grade_term ("name", description) VALUES('Double Cover', 'Technically a printing defect, double-cover books had an extra copy of the cover stapled on during manufacturing. This protective extra cover can be a boon, as these books are graded by the condition of the innermost cover.');
INSERT INTO grade_term ("name", description) VALUES('Dust Shadow', 'When a comic has been stored in a stack at some point in its life, any portions of the cover that weren''t covered up by the adjacent books have been exposed to environmental air, light, and settling dust particles, sometimes creating lines of discoloration along the edges.');
INSERT INTO grade_term ("name", description) VALUES('Fingerprints', 'When finger oils left behind from everyday handling remain on a comic''s surface, they can begin to eat away at the ink, literally creating color-breaking fingerprints on the cover that are sometimes distinct and sometimes smudged. Finger oils can usually be wiped away, but fingerprints are irreversible.');
INSERT INTO grade_term ("name", description) VALUES('Flash', 'A method of examining a comic that uses its natural gloss and light (glare) to help you see imperfections in its surface, like denting.');
INSERT INTO grade_term ("name", description) VALUES('Foxing', 'Bacterial or fungal growth in the paper of a comic (usually the cover) that presents in brownish discolored clusters or spots.');
INSERT INTO grade_term ("name", description) VALUES('Fold', 'Linear dents in paper that have distinct lines, but DO NOT break color (see also bend/crease).');
INSERT INTO grade_term ("name", description) VALUES('Gloss', 'The shiny surface finish of a comic.');
INSERT INTO grade_term ("name", description) VALUES('Moisture/Water Damage', 'The damage left behind when a comic has been exposed to moisture (directly or environmentally). Water damage often presents with staining and/or a stiff or swollen feel to the paper. Look for lines of demarcation.');
INSERT INTO grade_term ("name", description) VALUES('Paper Loss', 'When the surface of a comic has been compromised. This can be the result of heavy scuffing/abrasion, accidental tape pull, or the chemical reactions caused by some kinds of moisture damage.');
INSERT INTO grade_term ("name", description) VALUES('Paper Quality', 'Paper quality refers to the coloration and structural integrity of a comic''s cover and interior pages. We do give some leeway on pre-1980s comics, but when environmental conditions have caused the paper to oxidize and/or deteriorate significantly, the decrease in eye appeal and paper strength will bring a book''s grade down. Generally, paper quality will not be a concern for most modern (post-1980) comics.');
INSERT INTO grade_term ("name", description) VALUES('Printing Defect', 'A flaw caused in the printing process. Examples: paper wrinkling, mis-cut edges, mis-folded or mis-wrapped spine, untrimmed pages/corners, off-registered color, color artifacts, off-centered trimming, mis-folded or unbound pages, missing staples.');
INSERT INTO grade_term ("name", description) VALUES('Reading Crease', 'A vertical cover crease near the staples that runs (generally) parallel to the spine, caused by bending the cover over the staples or just too far to the left. Squarebound books get these very easily.');
INSERT INTO grade_term ("name", description) VALUES('Restoration', 'Any attempt (professional or amateur) to enhance the appearance of an aging or damaged comic book. Dry pressing/cleaning and the simple addition of tape repairs are not considered restoration, but the following techniques are: recoloring/color touch, adding missing paper, stain/ink/dirt/tape removal, whitening, chemical pressing, staple replacement, trimming, re- glossing, married pages, etc. Restored comics generally carry lower value than their unaltered counterparts.');
INSERT INTO grade_term ("name", description) VALUES('Scuffing', 'A light paper abrasion that may or may not break color, but interrupts the surface gloss of the book. Its effect on grading is determined by severity.');
INSERT INTO grade_term ("name", description) VALUES('Soiling', 'Substances or residue on the surface of a comic. Most commonly found in white spaces. Residue is a more severe form of soiling.');
INSERT INTO grade_term ("name", description) VALUES('Spine Break', 'A spine stress that has devolved into a tear (usually through multiple wraps). Spine breaks greatly decrease the spine''s structural integrity and are often found close to the staples.');
INSERT INTO grade_term ("name", description) VALUES('Spine Roll', 'A condition where the left edge of a comic curves toward the front or back, caused by folding back each page as the comic was read. Also usually results in page fanning.');
INSERT INTO grade_term ("name", description) VALUES('Spine Split', 'A clean, even separation at the spine fold, commonly above or below the staple, but can occur anywhere along the spine length.');
INSERT INTO grade_term ("name", description) VALUES('Spine Stress', 'A small crimp/fold perpendicular to the spine, usually less than 1/4" long.');
INSERT INTO grade_term ("name", description) VALUES('Staple Detached', 'When a wrap has come completely loose from a staple and is no longer bound to the comic in that area.');
INSERT INTO grade_term ("name", description) VALUES('Staple Migration', 'When staple rust has moved onto the surrounding paper, causing staining.');
INSERT INTO grade_term ("name", description) VALUES('Staple Popped', 'When one side of a cover has torn right next to the staple, but is still attached by the slip of paper beneath the staple. If not handled carefully, a popped staple can lead to a detached staple.');
INSERT INTO grade_term ("name", description) VALUES('Staple Rust', 'Literally, rust on the staple.');
INSERT INTO grade_term ("name", description) VALUES('Store Stamp', 'Store name, or other details, stamped in ink on cover.');
INSERT INTO grade_term ("name", description) VALUES('Subscription Crease', 'A vertical cover-to-cover fold caused by the book being folded in half when sent through the mail directly from the publisher.');
INSERT INTO grade_term ("name", description) VALUES('Wrap', 'A single sheet of paper folded to form four pages of a story.');
INSERT INTO grade_term ("name", description) VALUES('Writing/Signed', 'Has one or more signature or writing can be found on/in comic in any form.');


COMMIT;
