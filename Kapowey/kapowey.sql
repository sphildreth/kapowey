--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4 (Debian 12.4-1.pgdg100+1)
-- Dumped by pg_dump version 12.5

-- Started on 2020-11-25 13:59:09

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
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3365 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 591 (class 1247 OID 16414)
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
-- TOC entry 588 (class 1247 OID 16397)
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
-- TOC entry 219 (class 1259 OID 16588)
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
-- TOC entry 218 (class 1259 OID 16586)
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
-- TOC entry 206 (class 1259 OID 16456)
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
-- TOC entry 205 (class 1259 OID 16454)
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
-- TOC entry 243 (class 1259 OID 17006)
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
-- TOC entry 242 (class 1259 OID 17004)
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
-- TOC entry 244 (class 1259 OID 17042)
-- Name: collection_issue_grade_term; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collection_issue_grade_term (
    collection_issue_id integer NOT NULL,
    grade_term_id integer NOT NULL
);


ALTER TABLE public.collection_issue_grade_term OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16720)
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
-- TOC entry 225 (class 1259 OID 16689)
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
-- TOC entry 224 (class 1259 OID 16687)
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
-- TOC entry 226 (class 1259 OID 16718)
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
-- TOC entry 231 (class 1259 OID 16793)
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
    reviewed_user_id integer,
    api_key uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE public.genre OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16791)
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
-- TOC entry 239 (class 1259 OID 16943)
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
-- TOC entry 238 (class 1259 OID 16941)
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
-- TOC entry 241 (class 1259 OID 16976)
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
-- TOC entry 240 (class 1259 OID 16974)
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
-- TOC entry 237 (class 1259 OID 16897)
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
-- TOC entry 236 (class 1259 OID 16895)
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
-- TOC entry 235 (class 1259 OID 16867)
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
-- TOC entry 234 (class 1259 OID 16865)
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
-- TOC entry 217 (class 1259 OID 16576)
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
-- TOC entry 223 (class 1259 OID 16651)
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
-- TOC entry 221 (class 1259 OID 16620)
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
-- TOC entry 220 (class 1259 OID 16618)
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
-- TOC entry 222 (class 1259 OID 16649)
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
-- TOC entry 233 (class 1259 OID 16824)
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
-- TOC entry 229 (class 1259 OID 16762)
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
-- TOC entry 228 (class 1259 OID 16760)
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
-- TOC entry 232 (class 1259 OID 16822)
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
-- TOC entry 204 (class 1259 OID 16429)
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
-- TOC entry 208 (class 1259 OID 16480)
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
-- TOC entry 207 (class 1259 OID 16478)
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
-- TOC entry 216 (class 1259 OID 16566)
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
-- TOC entry 209 (class 1259 OID 16495)
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
-- TOC entry 212 (class 1259 OID 16525)
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
-- TOC entry 214 (class 1259 OID 16536)
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
-- TOC entry 213 (class 1259 OID 16534)
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
-- TOC entry 211 (class 1259 OID 16523)
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
-- TOC entry 210 (class 1259 OID 16509)
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
-- TOC entry 203 (class 1259 OID 16427)
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
-- TOC entry 215 (class 1259 OID 16550)
-- Name: user_user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_user_role (
    user_id integer NOT NULL,
    user_role_id integer NOT NULL
);


ALTER TABLE public.user_user_role OWNER TO postgres;

--
-- TOC entry 3334 (class 0 OID 16588)
-- Dependencies: 219
-- Data for Name: api_application; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_application (api_application_id, status, api_key, name, short_name, description, url, tags, last_activity, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.


--
-- TOC entry 3321 (class 0 OID 16456)
-- Dependencies: 206
-- Data for Name: collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection (collection_id, user_id, status, sort_order, api_key, name, short_name, description, tags, is_public, last_activity, created_date) FROM stdin;
\.


--
-- TOC entry 3358 (class 0 OID 17006)
-- Dependencies: 243
-- Data for Name: collection_issue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection_issue (collection_issue_id, collection_id, issue_id, status, grade_id, rating, sort_order, api_key, notes, tags, number_of_copies_owned, is_digital, is_wanted, is_public, has_read, is_for_sale, price_paid, acquisition_date, last_activity, created_date) FROM stdin;
\.


--
-- TOC entry 3359 (class 0 OID 17042)
-- Dependencies: 244
-- Data for Name: collection_issue_grade_term; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection_issue_grade_term (collection_issue_id, grade_term_id) FROM stdin;
\.


--
-- TOC entry 3342 (class 0 OID 16720)
-- Dependencies: 227
-- Data for Name: franchise; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.franchise (franchise_id, publisher_id, parent_franchise_id, franchise_category_id, status, api_key, gcd_id, name, short_name, year_began, year_end, description, url, tags, series_count, issue_count, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.


--
-- TOC entry 3340 (class 0 OID 16689)
-- Dependencies: 225
-- Data for Name: franchise_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.franchise_category (franchise_category_id, parent_franchise_category_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM stdin;
\.


--
-- TOC entry 3346 (class 0 OID 16793)
-- Dependencies: 231
-- Data for Name: genre; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.genre (genre_id, parent_genre_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM stdin;
\.


--
-- TOC entry 3354 (class 0 OID 16943)
-- Dependencies: 239
-- Data for Name: grade; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grade (grade_id, status, scale, sort_order, name, abbreviation, description, api_key, notes, tags, is_basic_grade, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
1	New	10.0	\N	Gem Mint	GM	\N	e5e965e7-81c9-4ae3-a63a-13b8742e9a41	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
2	New	9.9	\N	Mint	M	\N	4d879fa2-b5dd-4a00-b773-f063204204f8	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
3	New	9.8	\N	Near Mint/Mint	NM/M	\N	c37c6743-abef-43f7-b549-b081263faa4a	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
4	New	9.6	\N	Near Mint+	NM+	\N	2b67fa75-ffed-46bd-8c21-da5bcf50eaec	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
5	New	9.4	\N	Near Mint	NM	\N	461682b5-a38d-4717-bb86-20c1f365c6f0	\N	\N	t	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
6	New	9.2	\N	Near Mint-	NM-	\N	e0fc1ea3-cdcb-49b9-ae16-76dd60709e7e	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
7	New	9.0	\N	Very Fine/Near Mint	VF/NM	\N	4b652047-a6e2-457c-b436-3846326b4cb6	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
8	New	8.0	\N	Very Fine	VF	\N	1c01db77-9d62-4edf-8a1f-d8ce1975f9d8	\N	\N	t	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
9	New	8.5	\N	Very Fine+	VF+	\N	8a0b00fc-1195-4a59-b13c-dcd860a7c2ce	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
10	New	7.5	\N	Very Find-	VF-	\N	a9fa1e6a-665e-42cd-b544-029b27c8119f	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
11	New	7.0	\N	Fine/Very Fine	FN/VF	\N	942ed3b5-3bea-499b-a42d-febb179cfc50	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
12	New	6.5	\N	Fine+	FN+	\N	7883c15a-473c-49be-a376-b8409fd9fa10	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
13	New	6.0	\N	Fine	FN	\N	904c6ffd-53e0-496b-8ae5-8fc6e1b2211f	\N	\N	t	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
14	New	5.5	\N	Fine-	FN-	\N	fbded776-bdf0-4f1a-b9f7-e67321708546	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
15	New	5.0	\N	Very Good/Fine	VG/FN	\N	2f4578f2-6268-4f20-b001-e6d27ca61df1	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
16	New	4.5	\N	Very Good+	VG+	\N	1acb5de2-3f49-4604-ae78-23ceece3da4c	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
17	New	4.0	\N	Very Good	VG	\N	e1908706-7075-4f16-a093-b90ad2243c1d	\N	\N	t	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
18	New	3.5	\N	Very Good-	VG-	\N	da77c180-3798-48c3-a79a-646779ade2b5	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
19	New	3.0	\N	Good/Very Good	GD/VG	\N	c301d0c3-bc17-4c8d-8ff6-f9045de2a212	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
20	New	2.5	\N	Good+	GD+	\N	deb40468-c144-4b73-afec-dd37ef590cb6	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
21	New	2.0	\N	Good	GD	\N	d6f20f87-8318-4b69-811b-dd8b00fc1a3c	\N	\N	t	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
22	New	1.8	\N	Good-	GD-	\N	b3f5079a-7fcd-4b6b-9bde-3b647c2d247e	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
23	New	1.5	\N	Fair/Good	FR/GD	\N	82bd892a-7bae-4a50-ac90-88beea8b4a66	\N	\N	f	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
24	New	1.0	\N	Fair	FR	\N	8c779b10-4bf1-4a82-8471-41a60df0d898	\N	\N	t	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
25	New	0.5	\N	Poor	PR	\N	984775b3-3b87-4a4b-b900-f8a4c3ef91d0	\N	\N	t	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3356 (class 0 OID 16976)
-- Dependencies: 241
-- Data for Name: grade_term; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grade_term (grade_term_id, status, sort_order, name, description, api_key, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
1	New	\N	Bend	When part of a comic is curved, interrupting the flat, smooth cover surface. Bends WILL NOT show distinct lines.	c03f799a-13e9-4b62-a772-99407a56086f	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
2	New	\N	Bindery Tear	A small horizontal rip in a comic's cover that can usually be seen on both the front and the back. These are always found along the spine and should be graded like spine stress if they are shorter than 1/4".	92105189-cd2f-4fd0-b908-8e195d34d211	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
3	New	\N	Chew	Damage caused by the gnawing of rodents or insects (usually). Results in multi-page paper loss with jagged edges. Very visually distinct.	e976a60e-fbf0-432b-b9d6-ff5d779ee718	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
4	New	\N	Cockling	Bubbling on a cover's surface (typically a printing defect).	393ef014-d7e3-48de-a8be-5d2cf68cb01b	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
5	New	\N	Crease	A fold that causes ink removal/color break, usually resulting in a white line (see bend/fold).	f102a38d-dda1-4608-801c-66a4a8ee09ef	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
6	New	\N	Denting	Indentations or dimpling (usually in the cover) that don't penetrate the paper or remove any gloss, but do interrupt the smooth, flat surface.	524cc1d5-7bc8-4ff6-bcfc-24292580c198	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
7	New	\N	Double Cover	Technically a printing defect, double-cover books had an extra copy of the cover stapled on during manufacturing. This protective extra cover can be a boon, as these books are graded by the condition of the innermost cover.	84932353-7de6-46ae-8873-82852e3d260e	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
8	New	\N	Dust Shadow	When a comic has been stored in a stack at some point in its life, any portions of the cover that weren't covered up by the adjacent books have been exposed to environmental air, light, and settling dust particles, sometimes creating lines of discoloration along the edges.	c63ef1eb-2868-4274-9af3-60bc19093139	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
9	New	\N	Fingerprints	When finger oils left behind from everyday handling remain on a comic's surface, they can begin to eat away at the ink, literally creating color-breaking fingerprints on the cover that are sometimes distinct and sometimes smudged. Finger oils can usually be wiped away, but fingerprints are irreversible.	42c226a4-9559-4650-9f46-5a7336dfeda8	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
10	New	\N	Flash	A method of examining a comic that uses its natural gloss and light (glare) to help you see imperfections in its surface, like denting.	c07ad1d7-be24-4012-9b61-3f10efd2372f	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
11	New	\N	Foxing	Bacterial or fungal growth in the paper of a comic (usually the cover) that presents in brownish discolored clusters or spots.	34f05e0e-cf1e-4919-b4bc-9be00eec4253	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
12	New	\N	Fold	Linear dents in paper that have distinct lines, but DO NOT break color (see also bend/crease).	e0cd317e-42ae-487c-b2a1-fb8b0569153a	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
13	New	\N	Gloss	The shiny surface finish of a comic.	480514a4-ffd6-4eff-98d2-4d20acc40ae5	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
14	New	\N	Moisture/Water Damage	The damage left behind when a comic has been exposed to moisture (directly or environmentally). Water damage often presents with staining and/or a stiff or swollen feel to the paper. Look for lines of demarcation.	33b27bc1-bd12-4cf7-a051-b81b4143469a	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
15	New	\N	Paper Loss	When the surface of a comic has been compromised. This can be the result of heavy scuffing/abrasion, accidental tape pull, or the chemical reactions caused by some kinds of moisture damage.	a37bada9-3942-4359-a7e9-a5297799ef22	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
16	New	\N	Paper Quality	Paper quality refers to the coloration and structural integrity of a comic's cover and interior pages. We do give some leeway on pre-1980s comics, but when environmental conditions have caused the paper to oxidize and/or deteriorate significantly, the decrease in eye appeal and paper strength will bring a book's grade down. Generally, paper quality will not be a concern for most modern (post-1980) comics.	a8d78b66-0588-49d3-a388-7cadf1f9347b	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
17	New	\N	Printing Defect	A flaw caused in the printing process. Examples: paper wrinkling, mis-cut edges, mis-folded or mis-wrapped spine, untrimmed pages/corners, off-registered color, color artifacts, off-centered trimming, mis-folded or unbound pages, missing staples.	2b4f9d36-ea81-418b-b7f8-e86cb07ac73b	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
18	New	\N	Reading Crease	A vertical cover crease near the staples that runs (generally) parallel to the spine, caused by bending the cover over the staples or just too far to the left. Squarebound books get these very easily.	b7f91355-126e-45bb-981f-284457dc8309	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
19	New	\N	Restoration	Any attempt (professional or amateur) to enhance the appearance of an aging or damaged comic book. Dry pressing/cleaning and the simple addition of tape repairs are not considered restoration, but the following techniques are: recoloring/color touch, adding missing paper, stain/ink/dirt/tape removal, whitening, chemical pressing, staple replacement, trimming, re- glossing, married pages, etc. Restored comics generally carry lower value than their unaltered counterparts.	0d8c9a56-6955-4aa9-af2a-e9972ac033d2	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
20	New	\N	Scuffing	A light paper abrasion that may or may not break color, but interrupts the surface gloss of the book. Its effect on grading is determined by severity.	732839a1-4fcc-4b39-a6de-a7e4233e58ae	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
21	New	\N	Soiling	Substances or residue on the surface of a comic. Most commonly found in white spaces. Residue is a more severe form of soiling.	6b0e5cf9-44fc-4a36-b5bd-a519c86c755f	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
22	New	\N	Spine Break	A spine stress that has devolved into a tear (usually through multiple wraps). Spine breaks greatly decrease the spine's structural integrity and are often found close to the staples.	7e3a5836-0451-4047-88c2-c17f541edee7	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
23	New	\N	Spine Roll	A condition where the left edge of a comic curves toward the front or back, caused by folding back each page as the comic was read. Also usually results in page fanning.	79a9e144-60f6-474b-9a86-ec247a4cb6d3	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
24	New	\N	Spine Split	A clean, even separation at the spine fold, commonly above or below the staple, but can occur anywhere along the spine length.	b5a11e07-9449-4689-8407-026e08d844d7	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
25	New	\N	Spine Stress	A small crimp/fold perpendicular to the spine, usually less than 1/4" long.	64006c2d-4c41-45a0-ab7d-01262da149dd	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
26	New	\N	Staple Detached	When a wrap has come completely loose from a staple and is no longer bound to the comic in that area.	0f0db405-a6e8-4ab0-bbc1-a14323229083	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
27	New	\N	Staple Migration	When staple rust has moved onto the surrounding paper, causing staining.	a9b5220b-8b7d-47f6-b337-c997977004f6	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
28	New	\N	Staple Popped	When one side of a cover has torn right next to the staple, but is still attached by the slip of paper beneath the staple. If not handled carefully, a popped staple can lead to a detached staple.	a521f035-5510-4e59-a937-7a752ff04ad1	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
29	New	\N	Staple Rust	Literally, rust on the staple.	e199f6eb-f2ed-407d-891b-5d65c947e917	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
30	New	\N	Store Stamp	Store name, or other details, stamped in ink on cover.	c2fbedf1-c61e-428d-b0f8-fcb331f80332	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
31	New	\N	Subscription Crease	A vertical cover-to-cover fold caused by the book being folded in half when sent through the mail directly from the publisher.	5781047f-9875-4eaa-a36c-0f1cdf9bf2bb	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
32	New	\N	Wrap	A single sheet of paper folded to form four pages of a story.	60805bc5-5cac-421d-8f3f-7df5f469abec	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
33	New	\N	Writing/Signed	Has one or more signature or writing can be found on/in comic in any form.	b362cc8a-f1e1-4499-a268-a2c4caf0d91a	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3352 (class 0 OID 16897)
-- Dependencies: 237
-- Data for Name: issue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.issue (issue_id, series_id, status, rating, issuetype_id, api_key, gcd_id, reprint_of_issue_id, sort_order, number, title, variant_title, short_title, culture_code, description, url, tags, key_date, isbn, cover_price, barcode, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.


--
-- TOC entry 3350 (class 0 OID 16867)
-- Dependencies: 235
-- Data for Name: issuetype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.issuetype (issuetype_id, status, name, abbreviation, description, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM stdin;
1	New	Annual	AN	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	27d86ae1-7d49-4515-a8a1-f29054d3fecc
2	New	Bound	BO	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	fee986f1-552e-4f92-b626-8fbaca301f02
3	New	Digest	DI	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	97cb8edf-3d2f-4589-8cae-bd4d4af98182
4	New	Digital	DG	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	6ffec58a-6be9-47f5-a8e1-bcf28faa4586
5	New	Floppy (standard/comic/issue)	FL	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	3d131c97-4a18-4110-bfab-47f084847dd5
6	New	Graphic Novel (book/usually has isbn)	GN	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	cb41d3fa-1ae6-4f56-835e-27bffb712d67
7	New	Giant-Size	GS	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	d736053c-0e46-4725-9cd1-16c29c7795f0
8	New	Hardcover	HC	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	fedcefa9-d476-49c0-979a-c196ccedfff5
9	New	Omnibus	OB	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	810b1e84-8230-4aea-a7d4-54039eefcaf4
10	New	One-Shot	OS	Single stand alone issue with self-contained story, not part of a series	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	fc176221-7586-4b39-8a8a-a85def172ef1
11	New	Pamphlet	PA	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	51d959ad-6e3b-4ff1-9258-b858f7a4e4cc
12	New	Prestige	PR	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	a9593432-80f6-400e-885f-eb06addae808
13	New	Quarterly	QA	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	e7088d64-cb86-4ad5-829c-d8daa934e9c1
14	New	Special	SP	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	b7abe37a-25b9-45c2-b139-c14fc0149a94
15	New	Trade (Trade Paperback, TPB)	TP	A collection of issues or stories.	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	d868c673-8b59-45f1-91ef-a107fe7a15d0
16	New	Variant	VI	\N	\N	2020-11-25 17:49:40.691693+00	\N	\N	\N	\N	\N	ac43a49e-b1fa-4a62-b871-45fab5666605
\.


--
-- TOC entry 3332 (class 0 OID 16576)
-- Dependencies: 217
-- Data for Name: persisted_grant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.persisted_grant (key, type, subject_id, client_id, creation_time, expiration, data) FROM stdin;
\.


--
-- TOC entry 3338 (class 0 OID 16651)
-- Dependencies: 223
-- Data for Name: publisher; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publisher (publisher_id, parent_publisher_id, publisher_category_id, status, api_key, gcd_id, name, short_name, year_began, year_end, country_code, description, url, tags, franchise_count, series_count, issue_count, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.


--
-- TOC entry 3336 (class 0 OID 16620)
-- Dependencies: 221
-- Data for Name: publisher_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publisher_category (publisher_category_id, parent_publisher_category_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM stdin;
\.


--
-- TOC entry 3348 (class 0 OID 16824)
-- Dependencies: 233
-- Data for Name: series; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.series (series_id, franchise_id, series_category_id, genre_id, status, rating, api_key, gcd_id, first_issue_id, last_issue_id, name, short_name, year_began, year_end, culture_code, description, url, tags, issue_count, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id) FROM stdin;
\.


--
-- TOC entry 3344 (class 0 OID 16762)
-- Dependencies: 229
-- Data for Name: series_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.series_category (series_category_id, parent_series_category_id, status, name, short_name, description, url, tags, created_date, created_user_id, modified_date, modified_user_id, reviewed_date, reviewed_user_id, api_key) FROM stdin;
\.


--
-- TOC entry 3319 (class 0 OID 16429)
-- Dependencies: 204
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (user_id, status, api_key, user_name, normalized_user_name, email, normalized_email, email_confirmed, password_hash, security_stamp, concurrency_stamp, phone_number, phone_number_confirmed, two_factor_enabled, lockout_end, lockout_enabled, access_failed_count, tags, is_public, created_date, modified_date, modified_user_id, last_authenticate_date, successful_authenticate_count) FROM stdin;
1	New	062abe1f-3227-4404-bedf-d86113f9a671	steven	STEVEN	sphildreth@gmail.com	SPHILDRETH@GMAIL.COM	f	$2a$10$WK2iJ0qALNBwCJ3VqUVrOuUUhn4TEeOpPhB8Av2M5lZsR1hq2d6nG	f7807868-cea5-4da8-8bff-bf251cb13c61	51c4e20f-3799-4259-880d-8d1518e54f40	\N	f	f	\N	f	0	\N	f	2020-11-25 18:38:07.682566+00	\N	\N	2020-11-25 18:38:33.790776+00	1
\.


--
-- TOC entry 3323 (class 0 OID 16480)
-- Dependencies: 208
-- Data for Name: user_claim; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_claim (user_claim_id, user_id, claim_type, claim_value) FROM stdin;
\.


--
-- TOC entry 3331 (class 0 OID 16566)
-- Dependencies: 216
-- Data for Name: user_device_code; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_device_code (user_code, device_code, subject_id, client_id, creation_time, expiration, data) FROM stdin;
\.


--
-- TOC entry 3324 (class 0 OID 16495)
-- Dependencies: 209
-- Data for Name: user_login; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_login (login_provider, provider_key, provider_display_name, user_id) FROM stdin;
\.


--
-- TOC entry 3327 (class 0 OID 16525)
-- Dependencies: 212
-- Data for Name: user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_role (user_role_id, name, normalized_name, concurrency_stamp) FROM stdin;
1	Admin	ADMIN	b09e6626-4b85-456d-a96f-ff24159f135b
2	Manager	MANAGER	bd2ad612-168a-4075-8511-6c55477ec899
3	Editor	EDITOR	8adcc30f-aa36-40a5-98de-38a942ecb5b9
4	Contributor	CONTRIBUTOR	d9c787e1-a8fd-4e3f-88ca-adeeb9fb8ded
\.


--
-- TOC entry 3329 (class 0 OID 16536)
-- Dependencies: 214
-- Data for Name: user_role_claim; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_role_claim (user_role_claim_id, user_role_id, claim_type, claim_value) FROM stdin;
\.


--
-- TOC entry 3325 (class 0 OID 16509)
-- Dependencies: 210
-- Data for Name: user_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_token (user_id, login_provider, name, value) FROM stdin;
\.


--
-- TOC entry 3330 (class 0 OID 16550)
-- Dependencies: 215
-- Data for Name: user_user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_user_role (user_id, user_role_id) FROM stdin;
1	1
\.


--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 218
-- Name: api_application_api_application_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.api_application_api_application_id_seq', 1, false);


--
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 205
-- Name: collection_collection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collection_collection_id_seq', 1, false);


--
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 242
-- Name: collection_issue_collection_issue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collection_issue_collection_issue_id_seq', 1, false);


--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 224
-- Name: franchise_category_franchise_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.franchise_category_franchise_category_id_seq', 1, false);


--
-- TOC entry 3370 (class 0 OID 0)
-- Dependencies: 226
-- Name: franchise_franchise_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.franchise_franchise_id_seq', 1, false);


--
-- TOC entry 3371 (class 0 OID 0)
-- Dependencies: 230
-- Name: genre_genre_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.genre_genre_id_seq', 1, false);


--
-- TOC entry 3372 (class 0 OID 0)
-- Dependencies: 238
-- Name: grade_grade_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grade_grade_id_seq', 25, true);


--
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 240
-- Name: grade_term_grade_term_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grade_term_grade_term_id_seq', 33, true);


--
-- TOC entry 3374 (class 0 OID 0)
-- Dependencies: 236
-- Name: issue_issue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.issue_issue_id_seq', 1, false);


--
-- TOC entry 3375 (class 0 OID 0)
-- Dependencies: 234
-- Name: issuetype_issuetype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.issuetype_issuetype_id_seq', 16, true);


--
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 220
-- Name: publisher_category_publisher_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publisher_category_publisher_category_id_seq', 1, false);


--
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 222
-- Name: publisher_publisher_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publisher_publisher_id_seq', 1, false);


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 228
-- Name: series_category_series_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.series_category_series_category_id_seq', 1, false);


--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 232
-- Name: series_series_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.series_series_id_seq', 1, false);


--
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 207
-- Name: user_claim_user_claim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_claim_user_claim_id_seq', 1, false);


--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 213
-- Name: user_role_claim_user_role_claim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_role_claim_user_role_claim_id_seq', 1, false);


--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 211
-- Name: user_role_user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_role_user_role_id_seq', 4, true);


--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 203
-- Name: user_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_user_id_seq', 1, true);


--
-- TOC entry 3053 (class 2606 OID 16598)
-- Name: api_application api_application_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_application
    ADD CONSTRAINT api_application_id_pkey PRIMARY KEY (api_application_id);


--
-- TOC entry 3134 (class 2606 OID 17022)
-- Name: collection_issue collection_issue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue
    ADD CONSTRAINT collection_issue_pkey PRIMARY KEY (collection_issue_id);


--
-- TOC entry 3020 (class 2606 OID 16467)
-- Name: collection collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_pkey PRIMARY KEY (collection_id);


--
-- TOC entry 3072 (class 2606 OID 16698)
-- Name: franchise_category franchise_category_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise_category
    ADD CONSTRAINT franchise_category_id_pkey PRIMARY KEY (franchise_category_id);


--
-- TOC entry 3082 (class 2606 OID 16732)
-- Name: franchise franchise_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT franchise_pkey PRIMARY KEY (franchise_id);


--
-- TOC entry 3093 (class 2606 OID 16802)
-- Name: genre genre_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_id_pkey PRIMARY KEY (genre_id);


--
-- TOC entry 3123 (class 2606 OID 16954)
-- Name: grade grade_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade
    ADD CONSTRAINT grade_pkey PRIMARY KEY (grade_id);


--
-- TOC entry 3127 (class 2606 OID 16986)
-- Name: grade_term grade_term_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_term
    ADD CONSTRAINT grade_term_id_pkey PRIMARY KEY (grade_term_id);


--
-- TOC entry 3115 (class 2606 OID 16909)
-- Name: issue issue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_pkey PRIMARY KEY (issue_id);


--
-- TOC entry 3109 (class 2606 OID 16876)
-- Name: issuetype issuetype_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuetype
    ADD CONSTRAINT issuetype_id_pkey PRIMARY KEY (issuetype_id);


--
-- TOC entry 3138 (class 2606 OID 17046)
-- Name: collection_issue_grade_term pk_collection_issue_grade_term; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue_grade_term
    ADD CONSTRAINT pk_collection_issue_grade_term PRIMARY KEY (collection_issue_id, grade_term_id);


--
-- TOC entry 3046 (class 2606 OID 16573)
-- Name: user_device_code pk_device_codes; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_device_code
    ADD CONSTRAINT pk_device_codes PRIMARY KEY (user_code);


--
-- TOC entry 3050 (class 2606 OID 16583)
-- Name: persisted_grant pk_persisted_grants; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persisted_grant
    ADD CONSTRAINT pk_persisted_grants PRIMARY KEY (key);


--
-- TOC entry 3031 (class 2606 OID 16502)
-- Name: user_login pk_user_logins; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login
    ADD CONSTRAINT pk_user_logins PRIMARY KEY (login_provider, provider_key);


--
-- TOC entry 3042 (class 2606 OID 16554)
-- Name: user_user_role pk_user_roles; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_user_role
    ADD CONSTRAINT pk_user_roles PRIMARY KEY (user_id, user_role_id);


--
-- TOC entry 3033 (class 2606 OID 16516)
-- Name: user_token pk_user_tokens; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_token
    ADD CONSTRAINT pk_user_tokens PRIMARY KEY (user_id, login_provider, name);


--
-- TOC entry 3059 (class 2606 OID 16629)
-- Name: publisher_category publisher_category_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_category
    ADD CONSTRAINT publisher_category_id_pkey PRIMARY KEY (publisher_category_id);


--
-- TOC entry 3067 (class 2606 OID 16665)
-- Name: publisher publisher_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_pkey PRIMARY KEY (publisher_id);


--
-- TOC entry 3087 (class 2606 OID 16771)
-- Name: series_category series_category_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series_category
    ADD CONSTRAINT series_category_id_pkey PRIMARY KEY (series_category_id);


--
-- TOC entry 3103 (class 2606 OID 16837)
-- Name: series series_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_pkey PRIMARY KEY (series_id);


--
-- TOC entry 3026 (class 2606 OID 16487)
-- Name: user_claim user_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_claim
    ADD CONSTRAINT user_claim_pkey PRIMARY KEY (user_claim_id);


--
-- TOC entry 3014 (class 2606 OID 16444)
-- Name: user user_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_id_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3038 (class 2606 OID 16543)
-- Name: user_role_claim user_role_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_claim
    ADD CONSTRAINT user_role_claim_pkey PRIMARY KEY (user_role_claim_id);


--
-- TOC entry 3035 (class 2606 OID 16532)
-- Name: user_role user_role_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_id_pkey PRIMARY KEY (user_role_id);


--
-- TOC entry 3051 (class 1259 OID 16615)
-- Name: api_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX api_api_key_idx ON public.api_application USING btree (api_key);


--
-- TOC entry 3054 (class 1259 OID 16616)
-- Name: api_application_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX api_application_name_idx ON public.api_application USING btree (name);


--
-- TOC entry 3055 (class 1259 OID 16617)
-- Name: api_application_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX api_application_short_name_idx ON public.api_application USING btree (short_name);


--
-- TOC entry 3056 (class 1259 OID 16614)
-- Name: api_application_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_application_tags ON public.api_application USING gin (tags);


--
-- TOC entry 3017 (class 1259 OID 16474)
-- Name: collection_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_api_key_idx ON public.collection USING btree (api_key);


--
-- TOC entry 3130 (class 1259 OID 17041)
-- Name: collection_issue_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_issue_api_key_idx ON public.collection_issue USING btree (api_key);


--
-- TOC entry 3131 (class 1259 OID 17039)
-- Name: collection_issue_collection_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_issue_collection_id_idx ON public.collection_issue USING btree (collection_id);


--
-- TOC entry 3136 (class 1259 OID 17057)
-- Name: collection_issue_grade_term_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_issue_grade_term_idx ON public.collection_issue_grade_term USING btree (collection_issue_id, grade_term_id);


--
-- TOC entry 3132 (class 1259 OID 17040)
-- Name: collection_issue_issue_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_issue_issue_id_idx ON public.collection_issue USING btree (issue_id);


--
-- TOC entry 3135 (class 1259 OID 17038)
-- Name: collection_issue_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX collection_issue_tags ON public.collection_issue USING gin (tags);


--
-- TOC entry 3018 (class 1259 OID 16476)
-- Name: collection_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_name_idx ON public.collection USING btree (name);


--
-- TOC entry 3021 (class 1259 OID 16477)
-- Name: collection_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_short_name_idx ON public.collection USING btree (short_name);


--
-- TOC entry 3022 (class 1259 OID 16473)
-- Name: collection_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX collection_tags ON public.collection USING gin (tags);


--
-- TOC entry 3023 (class 1259 OID 16475)
-- Name: collection_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX collection_user_id_idx ON public.collection USING btree (user_id);


--
-- TOC entry 3077 (class 1259 OID 16757)
-- Name: franchise_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX franchise_api_key_idx ON public.franchise USING btree (api_key);


--
-- TOC entry 3073 (class 1259 OID 16716)
-- Name: franchise_category_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX franchise_category_name_idx ON public.franchise_category USING btree (name);


--
-- TOC entry 3074 (class 1259 OID 16715)
-- Name: franchise_category_parent_franchise_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_category_parent_franchise_category_idx ON public.franchise_category USING btree (parent_franchise_category_id);


--
-- TOC entry 3075 (class 1259 OID 16717)
-- Name: franchise_category_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX franchise_category_short_name_idx ON public.franchise_category USING btree (short_name);


--
-- TOC entry 3076 (class 1259 OID 16714)
-- Name: franchise_category_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_category_tags ON public.franchise_category USING gin (tags);


--
-- TOC entry 3078 (class 1259 OID 16755)
-- Name: franchise_franchise_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_franchise_category_idx ON public.franchise USING btree (franchise_category_id);


--
-- TOC entry 3079 (class 1259 OID 16758)
-- Name: franchise_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX franchise_name_idx ON public.franchise USING btree (name);


--
-- TOC entry 3080 (class 1259 OID 16754)
-- Name: franchise_parent_franchise_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_parent_franchise_idx ON public.franchise USING btree (parent_franchise_id);


--
-- TOC entry 3083 (class 1259 OID 16756)
-- Name: franchise_publisher_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_publisher_idx ON public.franchise USING btree (publisher_id);


--
-- TOC entry 3084 (class 1259 OID 16759)
-- Name: franchise_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX franchise_short_name_idx ON public.franchise USING btree (short_name);


--
-- TOC entry 3085 (class 1259 OID 16753)
-- Name: franchise_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX franchise_tags ON public.franchise USING gin (tags);


--
-- TOC entry 3094 (class 1259 OID 16820)
-- Name: genre_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX genre_name_idx ON public.genre USING btree (name);


--
-- TOC entry 3095 (class 1259 OID 16819)
-- Name: genre_parent_genre_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX genre_parent_genre_idx ON public.genre USING btree (parent_genre_id);


--
-- TOC entry 3096 (class 1259 OID 16821)
-- Name: genre_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX genre_short_name_idx ON public.genre USING btree (short_name);


--
-- TOC entry 3097 (class 1259 OID 16818)
-- Name: genre_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX genre_tags ON public.genre USING gin (tags);


--
-- TOC entry 3120 (class 1259 OID 16973)
-- Name: grade_abbreviation_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_abbreviation_idx ON public.grade USING btree (abbreviation);


--
-- TOC entry 3121 (class 1259 OID 16971)
-- Name: grade_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_name_idx ON public.grade USING btree (name);


--
-- TOC entry 3124 (class 1259 OID 16972)
-- Name: grade_scale_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_scale_idx ON public.grade USING btree (scale);


--
-- TOC entry 3125 (class 1259 OID 16970)
-- Name: grade_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX grade_tags ON public.grade USING gin (tags);


--
-- TOC entry 3128 (class 1259 OID 17002)
-- Name: grade_term_ide_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX grade_term_ide_tags ON public.grade_term USING gin (tags);


--
-- TOC entry 3129 (class 1259 OID 17003)
-- Name: grade_term_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_term_name_idx ON public.grade_term USING btree (name);


--
-- TOC entry 3112 (class 1259 OID 16938)
-- Name: issue_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX issue_api_key_idx ON public.issue USING btree (api_key);


--
-- TOC entry 3113 (class 1259 OID 16937)
-- Name: issue_issuetype_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issue_issuetype_idx ON public.issue USING btree (issuetype_id);


--
-- TOC entry 3116 (class 1259 OID 16936)
-- Name: issue_series_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issue_series_idx ON public.issue USING btree (series_id);


--
-- TOC entry 3117 (class 1259 OID 16940)
-- Name: issue_short_title_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX issue_short_title_idx ON public.issue USING btree (short_title);


--
-- TOC entry 3118 (class 1259 OID 16935)
-- Name: issue_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issue_tags ON public.issue USING gin (tags);


--
-- TOC entry 3119 (class 1259 OID 16939)
-- Name: issue_title_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX issue_title_idx ON public.issue USING btree (title);


--
-- TOC entry 3107 (class 1259 OID 16894)
-- Name: issuetype_abbreviation_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX issuetype_abbreviation_idx ON public.issuetype USING btree (abbreviation);


--
-- TOC entry 3110 (class 1259 OID 16893)
-- Name: issuetype_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX issuetype_name_idx ON public.issuetype USING btree (name);


--
-- TOC entry 3111 (class 1259 OID 16892)
-- Name: issuetype_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issuetype_tags ON public.issuetype USING gin (tags);


--
-- TOC entry 3043 (class 1259 OID 16574)
-- Name: ix_device_codes_device_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_device_codes_device_code ON public.user_device_code USING btree (device_code);


--
-- TOC entry 3044 (class 1259 OID 16575)
-- Name: ix_device_codes_expiration; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_device_codes_expiration ON public.user_device_code USING btree (expiration);


--
-- TOC entry 3047 (class 1259 OID 16584)
-- Name: ix_persisted_grants_expiration; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_persisted_grants_expiration ON public.persisted_grant USING btree (expiration);


--
-- TOC entry 3048 (class 1259 OID 16585)
-- Name: ix_persisted_grants_subject_id_client_id_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_persisted_grants_subject_id_client_id_type ON public.persisted_grant USING btree (subject_id, client_id, type);


--
-- TOC entry 3024 (class 1259 OID 16494)
-- Name: ix_user_claim_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_claim_user_id ON public.user_claim USING btree (user_id);


--
-- TOC entry 3028 (class 1259 OID 16508)
-- Name: ix_user_logins_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_logins_user_id ON public.user_login USING btree (user_id);


--
-- TOC entry 3040 (class 1259 OID 16565)
-- Name: ix_user_roles_role_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_roles_role_id ON public.user_user_role USING btree (user_id, user_role_id);


--
-- TOC entry 3029 (class 1259 OID 16522)
-- Name: ix_user_token_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_token_user_id ON public.user_login USING btree (user_id);


--
-- TOC entry 3057 (class 1259 OID 16646)
-- Name: pc_parent_pc_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pc_parent_pc_idx ON public.publisher_category USING btree (parent_publisher_category_id);


--
-- TOC entry 3063 (class 1259 OID 16684)
-- Name: publisher_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX publisher_api_key_idx ON public.publisher USING btree (api_key);


--
-- TOC entry 3060 (class 1259 OID 16647)
-- Name: publisher_category_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX publisher_category_name_idx ON public.publisher_category USING btree (name);


--
-- TOC entry 3061 (class 1259 OID 16648)
-- Name: publisher_category_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX publisher_category_short_name_idx ON public.publisher_category USING btree (short_name);


--
-- TOC entry 3062 (class 1259 OID 16645)
-- Name: publisher_category_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX publisher_category_tags ON public.publisher_category USING gin (tags);


--
-- TOC entry 3064 (class 1259 OID 16685)
-- Name: publisher_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX publisher_name_idx ON public.publisher USING btree (name);


--
-- TOC entry 3065 (class 1259 OID 16682)
-- Name: publisher_parent_publisher_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX publisher_parent_publisher_idx ON public.publisher USING btree (parent_publisher_id);


--
-- TOC entry 3068 (class 1259 OID 16683)
-- Name: publisher_publisher_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX publisher_publisher_category_idx ON public.publisher USING btree (publisher_category_id);


--
-- TOC entry 3069 (class 1259 OID 16686)
-- Name: publisher_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX publisher_short_name_idx ON public.publisher USING btree (short_name);


--
-- TOC entry 3070 (class 1259 OID 16681)
-- Name: publisher_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX publisher_tags ON public.publisher USING gin (tags);


--
-- TOC entry 3098 (class 1259 OID 16862)
-- Name: series_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX series_api_key_idx ON public.series USING btree (api_key);


--
-- TOC entry 3088 (class 1259 OID 16789)
-- Name: series_category_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX series_category_name_idx ON public.series_category USING btree (name);


--
-- TOC entry 3089 (class 1259 OID 16790)
-- Name: series_category_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX series_category_short_name_idx ON public.series_category USING btree (short_name);


--
-- TOC entry 3090 (class 1259 OID 16787)
-- Name: series_category_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_category_tags ON public.series_category USING gin (tags);


--
-- TOC entry 3099 (class 1259 OID 16861)
-- Name: series_franchise_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_franchise_idx ON public.series USING btree (franchise_id);


--
-- TOC entry 3100 (class 1259 OID 16860)
-- Name: series_genre_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_genre_idx ON public.series USING btree (genre_id);


--
-- TOC entry 3101 (class 1259 OID 16863)
-- Name: series_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX series_name_idx ON public.series USING btree (name);


--
-- TOC entry 3091 (class 1259 OID 16788)
-- Name: series_parent_series_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_parent_series_category_idx ON public.series_category USING btree (parent_series_category_id);


--
-- TOC entry 3104 (class 1259 OID 16859)
-- Name: series_series_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_series_category_idx ON public.series USING btree (series_category_id);


--
-- TOC entry 3105 (class 1259 OID 16864)
-- Name: series_short_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX series_short_name_idx ON public.series USING btree (short_name);


--
-- TOC entry 3106 (class 1259 OID 16858)
-- Name: series_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX series_tags ON public.series USING gin (tags);


--
-- TOC entry 3011 (class 1259 OID 16452)
-- Name: user_api_key_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_api_key_idx ON public."user" USING btree (api_key);


--
-- TOC entry 3027 (class 1259 OID 16493)
-- Name: user_claim_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_claim_user_idx ON public.user_claim USING btree (user_claim_id);


--
-- TOC entry 3012 (class 1259 OID 16451)
-- Name: user_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_email_idx ON public."user" USING btree (normalized_email);


--
-- TOC entry 3039 (class 1259 OID 16549)
-- Name: user_role_claim_user_role_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_role_claim_user_role_idx ON public.user_role_claim USING btree (user_role_id);


--
-- TOC entry 3036 (class 1259 OID 16533)
-- Name: user_role_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_role_name_idx ON public.user_role USING btree (normalized_name);


--
-- TOC entry 3015 (class 1259 OID 16450)
-- Name: user_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_tags ON public."user" USING gin (tags);


--
-- TOC entry 3016 (class 1259 OID 16453)
-- Name: user_username_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_username_idx ON public."user" USING btree (normalized_user_name);


--
-- TOC entry 3147 (class 2606 OID 16599)
-- Name: api_application api_application_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_application
    ADD CONSTRAINT api_application_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3148 (class 2606 OID 16604)
-- Name: api_application api_application_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_application
    ADD CONSTRAINT api_application_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3149 (class 2606 OID 16609)
-- Name: api_application api_application_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_application
    ADD CONSTRAINT api_application_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3187 (class 2606 OID 17023)
-- Name: collection_issue collection_issue_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue
    ADD CONSTRAINT collection_issue_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collection(collection_id) ON DELETE CASCADE;


--
-- TOC entry 3189 (class 2606 OID 17033)
-- Name: collection_issue collection_issue_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue
    ADD CONSTRAINT collection_issue_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade(grade_id) ON DELETE RESTRICT;


--
-- TOC entry 3190 (class 2606 OID 17047)
-- Name: collection_issue_grade_term collection_issue_grade_term_collection_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue_grade_term
    ADD CONSTRAINT collection_issue_grade_term_collection_issue_id_fkey FOREIGN KEY (collection_issue_id) REFERENCES public.collection_issue(collection_issue_id) ON DELETE CASCADE;


--
-- TOC entry 3191 (class 2606 OID 17052)
-- Name: collection_issue_grade_term collection_issue_grade_term_grade_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue_grade_term
    ADD CONSTRAINT collection_issue_grade_term_grade_term_id_fkey FOREIGN KEY (grade_term_id) REFERENCES public.grade_term(grade_term_id) ON DELETE CASCADE;


--
-- TOC entry 3188 (class 2606 OID 17028)
-- Name: collection_issue collection_issue_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_issue
    ADD CONSTRAINT collection_issue_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES public.issue(issue_id) ON DELETE RESTRICT;


--
-- TOC entry 3140 (class 2606 OID 16468)
-- Name: collection collection_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id) ON DELETE CASCADE;


--
-- TOC entry 3156 (class 2606 OID 16699)
-- Name: franchise_category franchise_category_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise_category
    ADD CONSTRAINT franchise_category_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3157 (class 2606 OID 16704)
-- Name: franchise_category franchise_category_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise_category
    ADD CONSTRAINT franchise_category_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3158 (class 2606 OID 16709)
-- Name: franchise_category franchise_category_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise_category
    ADD CONSTRAINT franchise_category_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3160 (class 2606 OID 16738)
-- Name: franchise franchise_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT franchise_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3161 (class 2606 OID 16743)
-- Name: franchise franchise_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT franchise_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3159 (class 2606 OID 16733)
-- Name: franchise franchise_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT franchise_publisher_id_fkey FOREIGN KEY (publisher_id) REFERENCES public.publisher(publisher_id) ON DELETE CASCADE;


--
-- TOC entry 3162 (class 2606 OID 16748)
-- Name: franchise franchise_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT franchise_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3166 (class 2606 OID 16803)
-- Name: genre genre_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3167 (class 2606 OID 16808)
-- Name: genre genre_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3168 (class 2606 OID 16813)
-- Name: genre genre_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3181 (class 2606 OID 16955)
-- Name: grade grade_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade
    ADD CONSTRAINT grade_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3182 (class 2606 OID 16960)
-- Name: grade grade_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade
    ADD CONSTRAINT grade_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3183 (class 2606 OID 16965)
-- Name: grade grade_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade
    ADD CONSTRAINT grade_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3184 (class 2606 OID 16987)
-- Name: grade_term grade_term_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_term
    ADD CONSTRAINT grade_term_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3185 (class 2606 OID 16992)
-- Name: grade_term grade_term_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_term
    ADD CONSTRAINT grade_term_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3186 (class 2606 OID 16997)
-- Name: grade_term grade_term_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_term
    ADD CONSTRAINT grade_term_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3178 (class 2606 OID 16920)
-- Name: issue issue_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3177 (class 2606 OID 16915)
-- Name: issue issue_issuetype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_issuetype_id_fkey FOREIGN KEY (issuetype_id) REFERENCES public.issuetype(issuetype_id) ON DELETE RESTRICT;


--
-- TOC entry 3179 (class 2606 OID 16925)
-- Name: issue issue_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3180 (class 2606 OID 16930)
-- Name: issue issue_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3176 (class 2606 OID 16910)
-- Name: issue issue_series_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series(series_id) ON DELETE CASCADE;


--
-- TOC entry 3173 (class 2606 OID 16877)
-- Name: issuetype issuetype_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuetype
    ADD CONSTRAINT issuetype_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3174 (class 2606 OID 16882)
-- Name: issuetype issuetype_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuetype
    ADD CONSTRAINT issuetype_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3175 (class 2606 OID 16887)
-- Name: issuetype issuetype_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuetype
    ADD CONSTRAINT issuetype_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3150 (class 2606 OID 16630)
-- Name: publisher_category publisher_category_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_category
    ADD CONSTRAINT publisher_category_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3151 (class 2606 OID 16635)
-- Name: publisher_category publisher_category_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_category
    ADD CONSTRAINT publisher_category_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3152 (class 2606 OID 16640)
-- Name: publisher_category publisher_category_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_category
    ADD CONSTRAINT publisher_category_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3153 (class 2606 OID 16666)
-- Name: publisher publisher_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3154 (class 2606 OID 16671)
-- Name: publisher publisher_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3155 (class 2606 OID 16676)
-- Name: publisher publisher_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3163 (class 2606 OID 16772)
-- Name: series_category series_category_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series_category
    ADD CONSTRAINT series_category_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3164 (class 2606 OID 16777)
-- Name: series_category series_category_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series_category
    ADD CONSTRAINT series_category_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3165 (class 2606 OID 16782)
-- Name: series_category series_category_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series_category
    ADD CONSTRAINT series_category_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3170 (class 2606 OID 16843)
-- Name: series series_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_created_user_id_fkey FOREIGN KEY (created_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3169 (class 2606 OID 16838)
-- Name: series series_franchise_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_franchise_id_fkey FOREIGN KEY (franchise_id) REFERENCES public.franchise(franchise_id) ON DELETE CASCADE;


--
-- TOC entry 3171 (class 2606 OID 16848)
-- Name: series series_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3172 (class 2606 OID 16853)
-- Name: series series_reviewed_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_reviewed_user_id_fkey FOREIGN KEY (reviewed_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3141 (class 2606 OID 16488)
-- Name: user_claim user_claim_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_claim
    ADD CONSTRAINT user_claim_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id) ON DELETE CASCADE;


--
-- TOC entry 3142 (class 2606 OID 16503)
-- Name: user_login user_login_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login
    ADD CONSTRAINT user_login_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id) ON DELETE CASCADE;


--
-- TOC entry 3139 (class 2606 OID 16445)
-- Name: user user_modified_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_modified_user_id_fkey FOREIGN KEY (modified_user_id) REFERENCES public."user"(user_id) ON DELETE RESTRICT;


--
-- TOC entry 3144 (class 2606 OID 16544)
-- Name: user_role_claim user_role_claim_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_claim
    ADD CONSTRAINT user_role_claim_user_role_id_fkey FOREIGN KEY (user_role_id) REFERENCES public.user_role(user_role_id) ON DELETE CASCADE;


--
-- TOC entry 3143 (class 2606 OID 16517)
-- Name: user_token user_token_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_token
    ADD CONSTRAINT user_token_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id) ON DELETE CASCADE;


--
-- TOC entry 3145 (class 2606 OID 16555)
-- Name: user_user_role user_user_role_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_user_role
    ADD CONSTRAINT user_user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id) ON DELETE CASCADE;


--
-- TOC entry 3146 (class 2606 OID 16560)
-- Name: user_user_role user_user_role_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_user_role
    ADD CONSTRAINT user_user_role_user_role_id_fkey FOREIGN KEY (user_role_id) REFERENCES public.user_role(user_role_id) ON DELETE CASCADE;


-- Completed on 2020-11-25 13:59:10

--
-- PostgreSQL database dump complete
--

