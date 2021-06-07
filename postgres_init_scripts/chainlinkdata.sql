--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Debian 13.3-1.pgdg100+1)
-- Dumped by pg_dump version 13.3 (Debian 13.3-1.pgdg100+1)

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
-- Name: eth_tx_attempts_state; Type: TYPE; Schema: public; Owner: streamr
--

CREATE TYPE public.eth_tx_attempts_state AS ENUM (
    'in_progress',
    'insufficient_eth',
    'broadcast'
);


ALTER TYPE public.eth_tx_attempts_state OWNER TO streamr;

--
-- Name: eth_txes_state; Type: TYPE; Schema: public; Owner: streamr
--

CREATE TYPE public.eth_txes_state AS ENUM (
    'unstarted',
    'in_progress',
    'fatal_error',
    'unconfirmed',
    'confirmed_missing_receipt',
    'confirmed'
);


ALTER TYPE public.eth_txes_state OWNER TO streamr;

--
-- Name: run_status; Type: TYPE; Schema: public; Owner: streamr
--

CREATE TYPE public.run_status AS ENUM (
    'unstarted',
    'in_progress',
    'pending_incoming_confirmations',
    'pending_outgoing_confirmations',
    'pending_connection',
    'pending_bridge',
    'pending_sleep',
    'errored',
    'completed',
    'cancelled'
);


ALTER TYPE public.run_status OWNER TO streamr;

--
-- Name: notifyethtxinsertion(); Type: FUNCTION; Schema: public; Owner: streamr
--

CREATE FUNCTION public.notifyethtxinsertion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
		PERFORM pg_notify('insert_on_eth_txes'::text, NOW()::text);
		RETURN NULL;
        END
        $$;


ALTER FUNCTION public.notifyethtxinsertion() OWNER TO streamr;

--
-- Name: notifyjobcreated(); Type: FUNCTION; Schema: public; Owner: streamr
--

CREATE FUNCTION public.notifyjobcreated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
            PERFORM pg_notify('insert_on_jobs', NEW.id::text);
            RETURN NEW;
        END
        $$;


ALTER FUNCTION public.notifyjobcreated() OWNER TO streamr;

--
-- Name: notifyjobdeleted(); Type: FUNCTION; Schema: public; Owner: streamr
--

CREATE FUNCTION public.notifyjobdeleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		PERFORM pg_notify('delete_from_jobs', OLD.id::text);
		RETURN OLD;
	END
	$$;


ALTER FUNCTION public.notifyjobdeleted() OWNER TO streamr;

--
-- Name: notifypipelinerunstarted(); Type: FUNCTION; Schema: public; Owner: streamr
--

CREATE FUNCTION public.notifypipelinerunstarted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		IF NEW.finished_at IS NULL THEN
			PERFORM pg_notify('pipeline_run_started', NEW.id::text);
		END IF;
		RETURN NEW;
	END
	$$;


ALTER FUNCTION public.notifypipelinerunstarted() OWNER TO streamr;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bridge_types; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.bridge_types (
    name text NOT NULL,
    url text NOT NULL,
    confirmations bigint DEFAULT 0 NOT NULL,
    incoming_token_hash text NOT NULL,
    salt text NOT NULL,
    outgoing_token text NOT NULL,
    minimum_contract_payment character varying(255),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.bridge_types OWNER TO streamr;

--
-- Name: configurations; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.configurations (
    id bigint NOT NULL,
    name text NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.configurations OWNER TO streamr;

--
-- Name: configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.configurations_id_seq OWNER TO streamr;

--
-- Name: configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.configurations_id_seq OWNED BY public.configurations.id;


--
-- Name: cron_specs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.cron_specs (
    id integer NOT NULL,
    cron_schedule text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.cron_specs OWNER TO streamr;

--
-- Name: cron_specs_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.cron_specs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cron_specs_id_seq OWNER TO streamr;

--
-- Name: cron_specs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.cron_specs_id_seq OWNED BY public.cron_specs.id;


--
-- Name: direct_request_specs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.direct_request_specs (
    id integer NOT NULL,
    contract_address bytea NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    on_chain_job_spec_id bytea NOT NULL,
    num_confirmations bigint,
    CONSTRAINT direct_request_specs_on_chain_job_spec_id_check CHECK ((octet_length(on_chain_job_spec_id) = 32)),
    CONSTRAINT eth_request_event_specs_contract_address_check CHECK ((octet_length(contract_address) = 20))
);


ALTER TABLE public.direct_request_specs OWNER TO streamr;

--
-- Name: encrypted_ocr_key_bundles; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.encrypted_ocr_key_bundles (
    id bytea NOT NULL,
    on_chain_signing_address bytea NOT NULL,
    off_chain_public_key bytea NOT NULL,
    encrypted_private_keys jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    config_public_key bytea NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.encrypted_ocr_key_bundles OWNER TO streamr;

--
-- Name: encrypted_p2p_keys; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.encrypted_p2p_keys (
    id integer NOT NULL,
    peer_id text NOT NULL,
    pub_key bytea NOT NULL,
    encrypted_priv_key jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_pub_key_length CHECK ((octet_length(pub_key) = 32))
);


ALTER TABLE public.encrypted_p2p_keys OWNER TO streamr;

--
-- Name: encrypted_p2p_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.encrypted_p2p_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.encrypted_p2p_keys_id_seq OWNER TO streamr;

--
-- Name: encrypted_p2p_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.encrypted_p2p_keys_id_seq OWNED BY public.encrypted_p2p_keys.id;


--
-- Name: encrypted_vrf_keys; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.encrypted_vrf_keys (
    public_key character varying(68) NOT NULL,
    vrf_key text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.encrypted_vrf_keys OWNER TO streamr;

--
-- Name: encumbrances; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.encumbrances (
    id bigint NOT NULL,
    payment numeric(78,0),
    expiration bigint,
    end_at timestamp with time zone,
    oracles text,
    aggregator bytea NOT NULL,
    agg_initiate_job_selector bytea NOT NULL,
    agg_fulfill_selector bytea NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.encumbrances OWNER TO streamr;

--
-- Name: encumbrances_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.encumbrances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.encumbrances_id_seq OWNER TO streamr;

--
-- Name: encumbrances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.encumbrances_id_seq OWNED BY public.encumbrances.id;


--
-- Name: eth_receipts; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.eth_receipts (
    id bigint NOT NULL,
    tx_hash bytea NOT NULL,
    block_hash bytea NOT NULL,
    block_number bigint NOT NULL,
    transaction_index bigint NOT NULL,
    receipt jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT chk_hash_length CHECK (((octet_length(tx_hash) = 32) AND (octet_length(block_hash) = 32)))
);


ALTER TABLE public.eth_receipts OWNER TO streamr;

--
-- Name: eth_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.eth_receipts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.eth_receipts_id_seq OWNER TO streamr;

--
-- Name: eth_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.eth_receipts_id_seq OWNED BY public.eth_receipts.id;


--
-- Name: eth_request_event_specs_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.eth_request_event_specs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.eth_request_event_specs_id_seq OWNER TO streamr;

--
-- Name: eth_request_event_specs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.eth_request_event_specs_id_seq OWNED BY public.direct_request_specs.id;


--
-- Name: eth_task_run_txes; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.eth_task_run_txes (
    task_run_id uuid NOT NULL,
    eth_tx_id bigint NOT NULL
);


ALTER TABLE public.eth_task_run_txes OWNER TO streamr;

--
-- Name: eth_tx_attempts; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.eth_tx_attempts (
    id bigint NOT NULL,
    eth_tx_id bigint NOT NULL,
    gas_price numeric(78,0) NOT NULL,
    signed_raw_tx bytea NOT NULL,
    hash bytea NOT NULL,
    broadcast_before_block_num bigint,
    state public.eth_tx_attempts_state NOT NULL,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT chk_cannot_broadcast_before_block_zero CHECK (((broadcast_before_block_num IS NULL) OR (broadcast_before_block_num > 0))),
    CONSTRAINT chk_eth_tx_attempts_fsm CHECK ((((state = ANY (ARRAY['in_progress'::public.eth_tx_attempts_state, 'insufficient_eth'::public.eth_tx_attempts_state])) AND (broadcast_before_block_num IS NULL)) OR (state = 'broadcast'::public.eth_tx_attempts_state))),
    CONSTRAINT chk_hash_length CHECK ((octet_length(hash) = 32)),
    CONSTRAINT chk_signed_raw_tx_present CHECK ((octet_length(signed_raw_tx) > 0))
);


ALTER TABLE public.eth_tx_attempts OWNER TO streamr;

--
-- Name: eth_tx_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.eth_tx_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.eth_tx_attempts_id_seq OWNER TO streamr;

--
-- Name: eth_tx_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.eth_tx_attempts_id_seq OWNED BY public.eth_tx_attempts.id;


--
-- Name: eth_txes; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.eth_txes (
    id bigint NOT NULL,
    nonce bigint,
    from_address bytea NOT NULL,
    to_address bytea NOT NULL,
    encoded_payload bytea NOT NULL,
    value numeric(78,0) NOT NULL,
    gas_limit bigint NOT NULL,
    error text,
    broadcast_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    state public.eth_txes_state DEFAULT 'unstarted'::public.eth_txes_state NOT NULL,
    CONSTRAINT chk_broadcast_at_is_sane CHECK ((broadcast_at > '2019-01-01 00:00:00+00'::timestamp with time zone)),
    CONSTRAINT chk_error_cannot_be_empty CHECK (((error IS NULL) OR (length(error) > 0))),
    CONSTRAINT chk_eth_txes_fsm CHECK ((((state = 'unstarted'::public.eth_txes_state) AND (nonce IS NULL) AND (error IS NULL) AND (broadcast_at IS NULL)) OR ((state = 'in_progress'::public.eth_txes_state) AND (nonce IS NOT NULL) AND (error IS NULL) AND (broadcast_at IS NULL)) OR ((state = 'fatal_error'::public.eth_txes_state) AND (nonce IS NULL) AND (error IS NOT NULL) AND (broadcast_at IS NULL)) OR ((state = 'unconfirmed'::public.eth_txes_state) AND (nonce IS NOT NULL) AND (error IS NULL) AND (broadcast_at IS NOT NULL)) OR ((state = 'confirmed'::public.eth_txes_state) AND (nonce IS NOT NULL) AND (error IS NULL) AND (broadcast_at IS NOT NULL)) OR ((state = 'confirmed_missing_receipt'::public.eth_txes_state) AND (nonce IS NOT NULL) AND (error IS NULL) AND (broadcast_at IS NOT NULL)))),
    CONSTRAINT chk_from_address_length CHECK ((octet_length(from_address) = 20)),
    CONSTRAINT chk_to_address_length CHECK ((octet_length(to_address) = 20))
);


ALTER TABLE public.eth_txes OWNER TO streamr;

--
-- Name: eth_txes_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.eth_txes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.eth_txes_id_seq OWNER TO streamr;

--
-- Name: eth_txes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.eth_txes_id_seq OWNED BY public.eth_txes.id;


--
-- Name: external_initiators; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.external_initiators (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    name text NOT NULL,
    url text,
    access_key text NOT NULL,
    salt text NOT NULL,
    hashed_secret text NOT NULL,
    outgoing_secret text NOT NULL,
    outgoing_token text NOT NULL
);


ALTER TABLE public.external_initiators OWNER TO streamr;

--
-- Name: external_initiators_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.external_initiators_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.external_initiators_id_seq OWNER TO streamr;

--
-- Name: external_initiators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.external_initiators_id_seq OWNED BY public.external_initiators.id;


--
-- Name: flux_monitor_round_stats; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.flux_monitor_round_stats (
    id bigint NOT NULL,
    aggregator bytea NOT NULL,
    round_id integer NOT NULL,
    num_new_round_logs integer DEFAULT 0 NOT NULL,
    num_submissions integer DEFAULT 0 NOT NULL,
    job_run_id uuid
);


ALTER TABLE public.flux_monitor_round_stats OWNER TO streamr;

--
-- Name: flux_monitor_round_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.flux_monitor_round_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flux_monitor_round_stats_id_seq OWNER TO streamr;

--
-- Name: flux_monitor_round_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.flux_monitor_round_stats_id_seq OWNED BY public.flux_monitor_round_stats.id;


--
-- Name: flux_monitor_round_stats_v2; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.flux_monitor_round_stats_v2 (
    id bigint NOT NULL,
    aggregator bytea NOT NULL,
    round_id integer NOT NULL,
    num_new_round_logs integer DEFAULT 0 NOT NULL,
    num_submissions integer DEFAULT 0 NOT NULL,
    pipeline_run_id bigint
);


ALTER TABLE public.flux_monitor_round_stats_v2 OWNER TO streamr;

--
-- Name: flux_monitor_round_stats_v2_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.flux_monitor_round_stats_v2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flux_monitor_round_stats_v2_id_seq OWNER TO streamr;

--
-- Name: flux_monitor_round_stats_v2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.flux_monitor_round_stats_v2_id_seq OWNED BY public.flux_monitor_round_stats_v2.id;


--
-- Name: flux_monitor_specs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.flux_monitor_specs (
    id integer NOT NULL,
    contract_address bytea NOT NULL,
    "precision" integer,
    threshold real,
    absolute_threshold real,
    poll_timer_period bigint,
    poll_timer_disabled boolean,
    idle_timer_period bigint,
    idle_timer_disabled boolean,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    min_payment numeric(78,0),
    CONSTRAINT flux_monitor_specs_check CHECK ((poll_timer_disabled OR (poll_timer_period > 0))),
    CONSTRAINT flux_monitor_specs_check1 CHECK ((idle_timer_disabled OR (idle_timer_period > 0))),
    CONSTRAINT flux_monitor_specs_contract_address_check CHECK ((octet_length(contract_address) = 20))
);


ALTER TABLE public.flux_monitor_specs OWNER TO streamr;

--
-- Name: flux_monitor_specs_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.flux_monitor_specs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flux_monitor_specs_id_seq OWNER TO streamr;

--
-- Name: flux_monitor_specs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.flux_monitor_specs_id_seq OWNED BY public.flux_monitor_specs.id;


--
-- Name: heads; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.heads (
    id bigint NOT NULL,
    hash bytea NOT NULL,
    number bigint NOT NULL,
    parent_hash bytea NOT NULL,
    created_at timestamp with time zone NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    CONSTRAINT chk_hash_size CHECK ((octet_length(hash) = 32)),
    CONSTRAINT chk_parent_hash_size CHECK ((octet_length(parent_hash) = 32))
);


ALTER TABLE public.heads OWNER TO streamr;

--
-- Name: heads_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.heads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.heads_id_seq OWNER TO streamr;

--
-- Name: heads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.heads_id_seq OWNED BY public.heads.id;


--
-- Name: initiators; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.initiators (
    id bigint NOT NULL,
    job_spec_id uuid NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    schedule text,
    "time" timestamp with time zone,
    ran boolean,
    address bytea,
    requesters text,
    name character varying(255),
    params jsonb,
    from_block numeric(78,0),
    to_block numeric(78,0),
    topics jsonb,
    request_data text,
    feeds text,
    threshold double precision,
    "precision" smallint,
    polling_interval bigint,
    absolute_threshold double precision,
    updated_at timestamp with time zone NOT NULL,
    poll_timer jsonb,
    idle_timer jsonb,
    job_id_topic_filter uuid
);


ALTER TABLE public.initiators OWNER TO streamr;

--
-- Name: initiators_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.initiators_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.initiators_id_seq OWNER TO streamr;

--
-- Name: initiators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.initiators_id_seq OWNED BY public.initiators.id;


--
-- Name: job_runs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.job_runs (
    result_id bigint,
    run_request_id bigint,
    status public.run_status DEFAULT 'unstarted'::public.run_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    finished_at timestamp with time zone,
    updated_at timestamp with time zone NOT NULL,
    initiator_id bigint NOT NULL,
    deleted_at timestamp with time zone,
    creation_height numeric(78,0),
    observed_height numeric(78,0),
    payment numeric(78,0),
    job_spec_id uuid NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE public.job_runs OWNER TO streamr;

--
-- Name: job_spec_errors; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.job_spec_errors (
    id bigint NOT NULL,
    job_spec_id uuid NOT NULL,
    description text NOT NULL,
    occurrences integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.job_spec_errors OWNER TO streamr;

--
-- Name: job_spec_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.job_spec_errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_spec_errors_id_seq OWNER TO streamr;

--
-- Name: job_spec_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.job_spec_errors_id_seq OWNED BY public.job_spec_errors.id;


--
-- Name: job_spec_errors_v2; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.job_spec_errors_v2 (
    id bigint NOT NULL,
    job_id integer,
    description text NOT NULL,
    occurrences integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.job_spec_errors_v2 OWNER TO streamr;

--
-- Name: job_spec_errors_v2_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.job_spec_errors_v2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_spec_errors_v2_id_seq OWNER TO streamr;

--
-- Name: job_spec_errors_v2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.job_spec_errors_v2_id_seq OWNED BY public.job_spec_errors_v2.id;


--
-- Name: job_specs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.job_specs (
    created_at timestamp with time zone NOT NULL,
    start_at timestamp with time zone,
    end_at timestamp with time zone,
    deleted_at timestamp with time zone,
    min_payment numeric(78,0),
    id uuid NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(255)
);


ALTER TABLE public.job_specs OWNER TO streamr;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.jobs (
    id integer NOT NULL,
    pipeline_spec_id integer,
    offchainreporting_oracle_spec_id integer,
    name character varying(255),
    schema_version integer NOT NULL,
    type character varying(255) NOT NULL,
    max_task_duration bigint,
    direct_request_spec_id integer,
    flux_monitor_spec_id integer,
    keeper_spec_id integer,
    cron_spec_id integer,
    CONSTRAINT chk_only_one_spec CHECK ((num_nonnulls(offchainreporting_oracle_spec_id, direct_request_spec_id, flux_monitor_spec_id, keeper_spec_id, cron_spec_id) = 1)),
    CONSTRAINT chk_schema_version CHECK ((schema_version > 0)),
    CONSTRAINT chk_type CHECK (((type)::text <> ''::text))
);


ALTER TABLE public.jobs OWNER TO streamr;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jobs_id_seq OWNER TO streamr;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: keeper_registries; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.keeper_registries (
    id bigint NOT NULL,
    job_id integer NOT NULL,
    keeper_index integer NOT NULL,
    contract_address bytea NOT NULL,
    from_address bytea NOT NULL,
    check_gas integer NOT NULL,
    block_count_per_turn integer NOT NULL,
    num_keepers integer NOT NULL,
    CONSTRAINT keeper_registries_contract_address_check CHECK ((octet_length(contract_address) = 20)),
    CONSTRAINT keeper_registries_from_address_check CHECK ((octet_length(from_address) = 20))
);


ALTER TABLE public.keeper_registries OWNER TO streamr;

--
-- Name: keeper_registries_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.keeper_registries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.keeper_registries_id_seq OWNER TO streamr;

--
-- Name: keeper_registries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.keeper_registries_id_seq OWNED BY public.keeper_registries.id;


--
-- Name: keeper_specs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.keeper_specs (
    id bigint NOT NULL,
    contract_address bytea NOT NULL,
    from_address bytea NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT keeper_specs_contract_address_check CHECK ((octet_length(contract_address) = 20)),
    CONSTRAINT keeper_specs_from_address_check CHECK ((octet_length(from_address) = 20))
);


ALTER TABLE public.keeper_specs OWNER TO streamr;

--
-- Name: keeper_specs_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.keeper_specs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.keeper_specs_id_seq OWNER TO streamr;

--
-- Name: keeper_specs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.keeper_specs_id_seq OWNED BY public.keeper_specs.id;


--
-- Name: keys; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.keys (
    address bytea NOT NULL,
    json jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    next_nonce bigint DEFAULT 0 NOT NULL,
    id integer NOT NULL,
    last_used timestamp with time zone,
    is_funding boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_address_length CHECK ((octet_length(address) = 20))
);


ALTER TABLE public.keys OWNER TO streamr;

--
-- Name: keys_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.keys_id_seq OWNER TO streamr;

--
-- Name: keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.keys_id_seq OWNED BY public.keys.id;


--
-- Name: log_broadcasts; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.log_broadcasts (
    id bigint NOT NULL,
    block_hash bytea NOT NULL,
    log_index bigint NOT NULL,
    job_id uuid,
    created_at timestamp without time zone NOT NULL,
    block_number bigint,
    job_id_v2 integer,
    consumed boolean DEFAULT false NOT NULL,
    CONSTRAINT chk_log_broadcasts_exactly_one_job_id CHECK ((((job_id IS NOT NULL) AND (job_id_v2 IS NULL)) OR ((job_id_v2 IS NOT NULL) AND (job_id IS NULL))))
);


ALTER TABLE public.log_broadcasts OWNER TO streamr;

--
-- Name: log_consumptions_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.log_consumptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_consumptions_id_seq OWNER TO streamr;

--
-- Name: log_consumptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.log_consumptions_id_seq OWNED BY public.log_broadcasts.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.migrations (
    id character varying(255) NOT NULL
);


ALTER TABLE public.migrations OWNER TO streamr;

--
-- Name: node_versions; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.node_versions (
    version text NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.node_versions OWNER TO streamr;

--
-- Name: offchainreporting_contract_configs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.offchainreporting_contract_configs (
    offchainreporting_oracle_spec_id integer NOT NULL,
    config_digest bytea NOT NULL,
    signers bytea[],
    transmitters bytea[],
    threshold integer,
    encoded_config_version bigint,
    encoded bytea,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT offchainreporting_contract_configs_config_digest_check CHECK ((octet_length(config_digest) = 16))
);


ALTER TABLE public.offchainreporting_contract_configs OWNER TO streamr;

--
-- Name: offchainreporting_latest_round_requested; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.offchainreporting_latest_round_requested (
    offchainreporting_oracle_spec_id integer NOT NULL,
    requester bytea NOT NULL,
    config_digest bytea NOT NULL,
    epoch bigint NOT NULL,
    round bigint NOT NULL,
    raw jsonb NOT NULL,
    CONSTRAINT offchainreporting_latest_round_requested_config_digest_check CHECK ((octet_length(config_digest) = 16)),
    CONSTRAINT offchainreporting_latest_round_requested_requester_check CHECK ((octet_length(requester) = 20))
);


ALTER TABLE public.offchainreporting_latest_round_requested OWNER TO streamr;

--
-- Name: offchainreporting_oracle_specs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.offchainreporting_oracle_specs (
    id integer NOT NULL,
    contract_address bytea NOT NULL,
    p2p_peer_id text,
    p2p_bootstrap_peers text[],
    is_bootstrap_peer boolean NOT NULL,
    encrypted_ocr_key_bundle_id bytea,
    monitoring_endpoint text,
    transmitter_address bytea,
    observation_timeout bigint,
    blockchain_timeout bigint,
    contract_config_tracker_subscribe_interval bigint,
    contract_config_tracker_poll_interval bigint,
    contract_config_confirmations integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT chk_contract_address_length CHECK ((octet_length(contract_address) = 20))
);


ALTER TABLE public.offchainreporting_oracle_specs OWNER TO streamr;

--
-- Name: offchainreporting_oracle_specs_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.offchainreporting_oracle_specs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.offchainreporting_oracle_specs_id_seq OWNER TO streamr;

--
-- Name: offchainreporting_oracle_specs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.offchainreporting_oracle_specs_id_seq OWNED BY public.offchainreporting_oracle_specs.id;


--
-- Name: offchainreporting_pending_transmissions; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.offchainreporting_pending_transmissions (
    offchainreporting_oracle_spec_id integer NOT NULL,
    config_digest bytea NOT NULL,
    epoch bigint NOT NULL,
    round bigint NOT NULL,
    "time" timestamp with time zone NOT NULL,
    median numeric(78,0) NOT NULL,
    serialized_report bytea NOT NULL,
    rs bytea[] NOT NULL,
    ss bytea[] NOT NULL,
    vs bytea NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT offchainreporting_pending_transmissions_config_digest_check CHECK ((octet_length(config_digest) = 16))
);


ALTER TABLE public.offchainreporting_pending_transmissions OWNER TO streamr;

--
-- Name: offchainreporting_persistent_states; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.offchainreporting_persistent_states (
    offchainreporting_oracle_spec_id integer NOT NULL,
    config_digest bytea NOT NULL,
    epoch bigint NOT NULL,
    highest_sent_epoch bigint NOT NULL,
    highest_received_epoch bigint[] NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT offchainreporting_persistent_states_config_digest_check CHECK ((octet_length(config_digest) = 16))
);


ALTER TABLE public.offchainreporting_persistent_states OWNER TO streamr;

--
-- Name: p2p_peers; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.p2p_peers (
    id text NOT NULL,
    addr text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    peer_id text NOT NULL
);


ALTER TABLE public.p2p_peers OWNER TO streamr;

--
-- Name: pipeline_runs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.pipeline_runs (
    id bigint NOT NULL,
    pipeline_spec_id integer NOT NULL,
    meta jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL,
    finished_at timestamp with time zone,
    errors jsonb,
    outputs jsonb,
    CONSTRAINT pipeline_runs_check CHECK ((((outputs IS NULL) AND (errors IS NULL) AND (finished_at IS NULL)) OR ((outputs IS NOT NULL) AND (errors IS NOT NULL) AND (finished_at IS NOT NULL))))
);


ALTER TABLE public.pipeline_runs OWNER TO streamr;

--
-- Name: pipeline_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.pipeline_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pipeline_runs_id_seq OWNER TO streamr;

--
-- Name: pipeline_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.pipeline_runs_id_seq OWNED BY public.pipeline_runs.id;


--
-- Name: pipeline_specs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.pipeline_specs (
    id integer NOT NULL,
    dot_dag_source text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    max_task_duration bigint
);


ALTER TABLE public.pipeline_specs OWNER TO streamr;

--
-- Name: pipeline_specs_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.pipeline_specs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pipeline_specs_id_seq OWNER TO streamr;

--
-- Name: pipeline_specs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.pipeline_specs_id_seq OWNED BY public.pipeline_specs.id;


--
-- Name: pipeline_task_runs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.pipeline_task_runs (
    id bigint NOT NULL,
    pipeline_run_id bigint NOT NULL,
    type text NOT NULL,
    index integer DEFAULT 0 NOT NULL,
    output jsonb,
    error text,
    created_at timestamp with time zone NOT NULL,
    finished_at timestamp with time zone,
    dot_id text NOT NULL,
    CONSTRAINT chk_pipeline_task_run_fsm CHECK ((((finished_at IS NOT NULL) AND (num_nonnulls(output, error) <> 2)) OR (num_nulls(finished_at, output, error) = 3)))
);


ALTER TABLE public.pipeline_task_runs OWNER TO streamr;

--
-- Name: pipeline_task_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.pipeline_task_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pipeline_task_runs_id_seq OWNER TO streamr;

--
-- Name: pipeline_task_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.pipeline_task_runs_id_seq OWNED BY public.pipeline_task_runs.id;


--
-- Name: run_requests; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.run_requests (
    id bigint NOT NULL,
    request_id bytea,
    tx_hash bytea,
    requester bytea,
    created_at timestamp with time zone NOT NULL,
    block_hash bytea,
    payment numeric(78,0),
    request_params jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.run_requests OWNER TO streamr;

--
-- Name: run_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.run_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.run_requests_id_seq OWNER TO streamr;

--
-- Name: run_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.run_requests_id_seq OWNED BY public.run_requests.id;


--
-- Name: run_results; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.run_results (
    id bigint NOT NULL,
    data jsonb,
    error_message text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.run_results OWNER TO streamr;

--
-- Name: run_results_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.run_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.run_results_id_seq OWNER TO streamr;

--
-- Name: run_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.run_results_id_seq OWNED BY public.run_results.id;


--
-- Name: service_agreements; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.service_agreements (
    id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    encumbrance_id bigint,
    request_body text,
    signature character varying(255),
    job_spec_id uuid,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.service_agreements OWNER TO streamr;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.sessions (
    id text NOT NULL,
    last_used timestamp with time zone,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.sessions OWNER TO streamr;

--
-- Name: sync_events; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.sync_events (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    body text NOT NULL
);


ALTER TABLE public.sync_events OWNER TO streamr;

--
-- Name: sync_events_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.sync_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sync_events_id_seq OWNER TO streamr;

--
-- Name: sync_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.sync_events_id_seq OWNED BY public.sync_events.id;


--
-- Name: task_runs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.task_runs (
    result_id bigint,
    status public.run_status DEFAULT 'unstarted'::public.run_status NOT NULL,
    task_spec_id bigint NOT NULL,
    minimum_confirmations bigint,
    created_at timestamp with time zone NOT NULL,
    confirmations bigint,
    job_run_id uuid NOT NULL,
    id uuid NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.task_runs OWNER TO streamr;

--
-- Name: task_specs; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.task_specs (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    type text NOT NULL,
    confirmations bigint,
    params jsonb,
    job_spec_id uuid NOT NULL
);


ALTER TABLE public.task_specs OWNER TO streamr;

--
-- Name: task_specs_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.task_specs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.task_specs_id_seq OWNER TO streamr;

--
-- Name: task_specs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.task_specs_id_seq OWNED BY public.task_specs.id;


--
-- Name: upkeep_registrations; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.upkeep_registrations (
    id bigint NOT NULL,
    registry_id bigint NOT NULL,
    execute_gas integer NOT NULL,
    check_data bytea NOT NULL,
    upkeep_id bigint NOT NULL,
    positioning_constant integer NOT NULL,
    last_run_block_height bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.upkeep_registrations OWNER TO streamr;

--
-- Name: upkeep_registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.upkeep_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.upkeep_registrations_id_seq OWNER TO streamr;

--
-- Name: upkeep_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.upkeep_registrations_id_seq OWNED BY public.upkeep_registrations.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.users (
    email text NOT NULL,
    hashed_password text,
    created_at timestamp with time zone NOT NULL,
    token_key text,
    token_salt text,
    token_hashed_secret text,
    updated_at timestamp with time zone NOT NULL,
    token_secret text
);


ALTER TABLE public.users OWNER TO streamr;

--
-- Name: configurations id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.configurations ALTER COLUMN id SET DEFAULT nextval('public.configurations_id_seq'::regclass);


--
-- Name: cron_specs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.cron_specs ALTER COLUMN id SET DEFAULT nextval('public.cron_specs_id_seq'::regclass);


--
-- Name: direct_request_specs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.direct_request_specs ALTER COLUMN id SET DEFAULT nextval('public.eth_request_event_specs_id_seq'::regclass);


--
-- Name: encrypted_p2p_keys id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.encrypted_p2p_keys ALTER COLUMN id SET DEFAULT nextval('public.encrypted_p2p_keys_id_seq'::regclass);


--
-- Name: encumbrances id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.encumbrances ALTER COLUMN id SET DEFAULT nextval('public.encumbrances_id_seq'::regclass);


--
-- Name: eth_receipts id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_receipts ALTER COLUMN id SET DEFAULT nextval('public.eth_receipts_id_seq'::regclass);


--
-- Name: eth_tx_attempts id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_tx_attempts ALTER COLUMN id SET DEFAULT nextval('public.eth_tx_attempts_id_seq'::regclass);


--
-- Name: eth_txes id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_txes ALTER COLUMN id SET DEFAULT nextval('public.eth_txes_id_seq'::regclass);


--
-- Name: external_initiators id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.external_initiators ALTER COLUMN id SET DEFAULT nextval('public.external_initiators_id_seq'::regclass);


--
-- Name: flux_monitor_round_stats id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.flux_monitor_round_stats ALTER COLUMN id SET DEFAULT nextval('public.flux_monitor_round_stats_id_seq'::regclass);


--
-- Name: flux_monitor_round_stats_v2 id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.flux_monitor_round_stats_v2 ALTER COLUMN id SET DEFAULT nextval('public.flux_monitor_round_stats_v2_id_seq'::regclass);


--
-- Name: flux_monitor_specs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.flux_monitor_specs ALTER COLUMN id SET DEFAULT nextval('public.flux_monitor_specs_id_seq'::regclass);


--
-- Name: heads id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.heads ALTER COLUMN id SET DEFAULT nextval('public.heads_id_seq'::regclass);


--
-- Name: initiators id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.initiators ALTER COLUMN id SET DEFAULT nextval('public.initiators_id_seq'::regclass);


--
-- Name: job_spec_errors id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_spec_errors ALTER COLUMN id SET DEFAULT nextval('public.job_spec_errors_id_seq'::regclass);


--
-- Name: job_spec_errors_v2 id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_spec_errors_v2 ALTER COLUMN id SET DEFAULT nextval('public.job_spec_errors_v2_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: keeper_registries id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.keeper_registries ALTER COLUMN id SET DEFAULT nextval('public.keeper_registries_id_seq'::regclass);


--
-- Name: keeper_specs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.keeper_specs ALTER COLUMN id SET DEFAULT nextval('public.keeper_specs_id_seq'::regclass);


--
-- Name: keys id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.keys ALTER COLUMN id SET DEFAULT nextval('public.keys_id_seq'::regclass);


--
-- Name: log_broadcasts id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.log_broadcasts ALTER COLUMN id SET DEFAULT nextval('public.log_consumptions_id_seq'::regclass);


--
-- Name: offchainreporting_oracle_specs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_oracle_specs ALTER COLUMN id SET DEFAULT nextval('public.offchainreporting_oracle_specs_id_seq'::regclass);


--
-- Name: pipeline_runs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.pipeline_runs ALTER COLUMN id SET DEFAULT nextval('public.pipeline_runs_id_seq'::regclass);


--
-- Name: pipeline_specs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.pipeline_specs ALTER COLUMN id SET DEFAULT nextval('public.pipeline_specs_id_seq'::regclass);


--
-- Name: pipeline_task_runs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.pipeline_task_runs ALTER COLUMN id SET DEFAULT nextval('public.pipeline_task_runs_id_seq'::regclass);


--
-- Name: run_requests id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.run_requests ALTER COLUMN id SET DEFAULT nextval('public.run_requests_id_seq'::regclass);


--
-- Name: run_results id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.run_results ALTER COLUMN id SET DEFAULT nextval('public.run_results_id_seq'::regclass);


--
-- Name: sync_events id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.sync_events ALTER COLUMN id SET DEFAULT nextval('public.sync_events_id_seq'::regclass);


--
-- Name: task_specs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.task_specs ALTER COLUMN id SET DEFAULT nextval('public.task_specs_id_seq'::regclass);


--
-- Name: upkeep_registrations id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.upkeep_registrations ALTER COLUMN id SET DEFAULT nextval('public.upkeep_registrations_id_seq'::regclass);


--
-- Data for Name: bridge_types; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.bridge_types (name, url, confirmations, incoming_token_hash, salt, outgoing_token, minimum_contract_payment, created_at, updated_at) FROM stdin;
ensbridge	http://streamr-dev-chainlink-adapter:8080	0	6606fa5ecd7d690ee7acb7d342597a5d26fe7284f115fd9482850622ce9d2523	lnBQfiO7UmUtAUM2n+lR2r1VfJJhzSQB	Gq0piFD2rxGUlCtNDgsX0ZL7/ryYR8TQ	0	2021-06-06 15:08:14.298391+00	2021-06-06 15:08:14.298391+00
\.


--
-- Data for Name: configurations; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.configurations (id, name, value, created_at, updated_at, deleted_at) FROM stdin;
1	ETH_GAS_PRICE_DEFAULT	5000000000	2021-06-06 15:05:58.618834+00	2021-06-06 15:11:29.746506+00	\N
\.


--
-- Data for Name: cron_specs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.cron_specs (id, cron_schedule, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: direct_request_specs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.direct_request_specs (id, contract_address, created_at, updated_at, on_chain_job_spec_id, num_confirmations) FROM stdin;
\.


--
-- Data for Name: encrypted_ocr_key_bundles; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.encrypted_ocr_key_bundles (id, on_chain_signing_address, off_chain_public_key, encrypted_private_keys, created_at, updated_at, config_public_key, deleted_at) FROM stdin;
\\x2be396d0cfa1d75f6d924e9ada154f69da4cb35da2830e7989547e6317eabe71	\\x48eb19be3f1b4a78a0f4cccf6ea72d6f664aa6bb	\\x41054e48f26e869584eca0bea72167d215c8dc760bb6831bfac30f26f9d99f2e	{"kdf": "scrypt", "mac": "a8685003a4ce7a74a5974d01b0b5e9be58098247dcb03d45df3f826e53440329", "cipher": "aes-128-ctr", "kdfparams": {"n": 262144, "p": 1, "r": 8, "salt": "fe029699de9cb497e0c3a2bae7d7ebca8f5e56e749e7582483947b7bbb02d753", "dklen": 32}, "ciphertext": "5b14a3baa7ca4e92950cfc648011a08fb4cefcfc8e7a300fb3476999828435bddd878cb03563f54d0b6a72a5371f2358b641e2bfc82079fb662609eb3928dc9a875dc0db1a48d50203e457725d8f051040b3f9e53a12fe613440cd508786f8771f0bb74eac7382cef2b52dbedace9f9f504b1004b7b855e6c09020c8cb9b45b6da99a5865201c296c8cdbc63b8da4fb422bad548ef1c40bd69a6405373029ba0f97adb23ef613fdb6fe993e3698a2b1cd0a6cb990e7b00decc5a6e33abb8fdb45e8f5404d7b3cf2267b622a419bd295f6e2b005266e5da133d560bfa7714f6a394ce92fc0869bbf703d9f1311db2a56aa1144a692b209570eac9b0e7c29d63b49d22bad67a6b62d899dc5f56f19674094a850ae3fc44ed485e44f2bf9621c3c2f38c5549e6fa560863aa0adaf5dd1905403ba4ff886e0dce2de297fcb881791d2180ca14b239b747dabff2d0", "cipherparams": {"iv": "e833f7a4a02e805d3c01d67390ebcdb4"}}	2021-06-06 15:05:58.488219+00	2021-06-06 15:05:58.488219+00	\\x67ecd77346b77ca2d98f91476b67eaefd9012ea74c93398b53d22d88b8797f1b	\N
\.


--
-- Data for Name: encrypted_p2p_keys; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.encrypted_p2p_keys (id, peer_id, pub_key, encrypted_priv_key, created_at, updated_at, deleted_at) FROM stdin;
1	12D3KooWKPaE45ivNMtPJZ4x9b1aLi5RGvTqbqBsSJ8meHpbRErY	\\x8e3afb643b05b07fafab749ae2b1126c5fbdd243c43100f0cd4baa2a876734cd	{"kdf": "scrypt", "mac": "bb82042c6f66beccf41fe43a9865a88c0263c3ca86b10a414417fb8fd55267ea", "cipher": "aes-128-ctr", "kdfparams": {"n": 262144, "p": 1, "r": 8, "salt": "dd6124cf522dc705206a0ef0155dc5726d27ade59ca594a8ab7a7efc0c30d460", "dklen": 32}, "ciphertext": "fdccd715bce76a920ab9879376de69f72c3c520241a7a8b05821270f0b24ecf9538abef3594e077b0b6e374007cc6df9a25349aee9a74c51d78c577ddfd88293b2ec09df", "cipherparams": {"iv": "117860c29f0a06fab71df9cf85755aab"}}	2021-06-06 15:05:57.729316+00	2021-06-06 15:05:57.729316+00	\N
\.


--
-- Data for Name: encrypted_vrf_keys; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.encrypted_vrf_keys (public_key, vrf_key, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: encumbrances; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.encumbrances (id, payment, expiration, end_at, oracles, aggregator, agg_initiate_job_selector, agg_fulfill_selector, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: eth_receipts; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.eth_receipts (id, tx_hash, block_hash, block_number, transaction_index, receipt, created_at) FROM stdin;
\.


--
-- Data for Name: eth_task_run_txes; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.eth_task_run_txes (task_run_id, eth_tx_id) FROM stdin;
\.


--
-- Data for Name: eth_tx_attempts; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.eth_tx_attempts (id, eth_tx_id, gas_price, signed_raw_tx, hash, broadcast_before_block_num, state, created_at) FROM stdin;
\.


--
-- Data for Name: eth_txes; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.eth_txes (id, nonce, from_address, to_address, encoded_payload, value, gas_limit, error, broadcast_at, created_at, state) FROM stdin;
\.


--
-- Data for Name: external_initiators; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.external_initiators (id, created_at, updated_at, deleted_at, name, url, access_key, salt, hashed_secret, outgoing_secret, outgoing_token) FROM stdin;
\.


--
-- Data for Name: flux_monitor_round_stats; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.flux_monitor_round_stats (id, aggregator, round_id, num_new_round_logs, num_submissions, job_run_id) FROM stdin;
\.


--
-- Data for Name: flux_monitor_round_stats_v2; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.flux_monitor_round_stats_v2 (id, aggregator, round_id, num_new_round_logs, num_submissions, pipeline_run_id) FROM stdin;
\.


--
-- Data for Name: flux_monitor_specs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.flux_monitor_specs (id, contract_address, "precision", threshold, absolute_threshold, poll_timer_period, poll_timer_disabled, idle_timer_period, idle_timer_disabled, created_at, updated_at, min_payment) FROM stdin;
\.


--
-- Data for Name: heads; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.heads (id, hash, number, parent_hash, created_at, "timestamp") FROM stdin;
1	\\x1b602bdee23765f479e204f242e5f05b495f85d12c5a944e5bf1ded9d2f14422	144	\\xce64ce298fb520242d199b157bb5eb7b0435251ae87a1da321860026d5a7f0cf	2021-06-06 15:06:00.252049+00	2021-06-06 15:06:00+00
2	\\xce64ce298fb520242d199b157bb5eb7b0435251ae87a1da321860026d5a7f0cf	143	\\xb554af059f1778a34185a1ff1fbafcd62ba729bb259ff9e0647391f512832f19	2021-06-06 15:06:00.268031+00	2021-06-06 15:05:57+00
3	\\xb554af059f1778a34185a1ff1fbafcd62ba729bb259ff9e0647391f512832f19	142	\\x76edce95a647a77982b8779e8809d158547ef43a35e8ab887ed2a37bdf60e8fd	2021-06-06 15:06:00.272158+00	2021-06-06 14:05:24+00
4	\\x76edce95a647a77982b8779e8809d158547ef43a35e8ab887ed2a37bdf60e8fd	141	\\xcac57580d834612a347d61bfdbd96ba5bf170cc848c94a714add54376d751d22	2021-06-06 15:06:00.275458+00	2021-06-06 14:05:21+00
5	\\xcac57580d834612a347d61bfdbd96ba5bf170cc848c94a714add54376d751d22	140	\\x89b4ecc7e76e6842683162356d5a5ffb055c90f84bd8ed4ffa56c4794d7163fa	2021-06-06 15:06:00.27905+00	2021-06-06 14:05:18+00
6	\\x89b4ecc7e76e6842683162356d5a5ffb055c90f84bd8ed4ffa56c4794d7163fa	139	\\x28f632879228e4ab630c92c1d9864159b86d22ab256edcd937c7824f3844f38c	2021-06-06 15:06:00.280993+00	2021-06-06 14:05:12+00
7	\\x28f632879228e4ab630c92c1d9864159b86d22ab256edcd937c7824f3844f38c	138	\\x9b2aced6ba54ecba3fc46f6baaf744be3f40ea15944dac0a73a5cc0a12a52a08	2021-06-06 15:06:00.283487+00	2021-06-06 14:05:06+00
8	\\x9b2aced6ba54ecba3fc46f6baaf744be3f40ea15944dac0a73a5cc0a12a52a08	137	\\xe5135cdbf520d4a31a16dd2055abac3769562bc9b2dd17c062e6c4457b1016ff	2021-06-06 15:06:00.286062+00	2021-06-06 14:05:03+00
9	\\xe5135cdbf520d4a31a16dd2055abac3769562bc9b2dd17c062e6c4457b1016ff	136	\\x44d33ba57c243185ef19cf878e1d1b18b450caa1af24cf660b974beb19be4d3e	2021-06-06 15:06:00.288536+00	2021-06-06 14:04:57+00
10	\\x44d33ba57c243185ef19cf878e1d1b18b450caa1af24cf660b974beb19be4d3e	135	\\xa3d164571dfdcfa5baa032c885fb872f76868342a54e9c41ea54ecf07cd29f31	2021-06-06 15:06:00.290474+00	2021-06-06 14:04:54+00
11	\\xa3d164571dfdcfa5baa032c885fb872f76868342a54e9c41ea54ecf07cd29f31	134	\\x34b61cfb548dc1e701bd149b200cca5377987c2c874b8ced6a37bbabc6599035	2021-06-06 15:06:00.292949+00	2021-06-06 14:04:51+00
12	\\x34b61cfb548dc1e701bd149b200cca5377987c2c874b8ced6a37bbabc6599035	133	\\xce027c497ad2deb41490e51267b25b42e76c88a75df7dbff8f2aca1e8ac4be95	2021-06-06 15:06:00.294903+00	2021-06-06 14:04:45+00
13	\\xce027c497ad2deb41490e51267b25b42e76c88a75df7dbff8f2aca1e8ac4be95	132	\\x512aa49fbb93617eb3eafba5e8c9b9a20a2c48b4033ca0133e519b563353147e	2021-06-06 15:06:00.296858+00	2021-06-06 14:04:39+00
14	\\x512aa49fbb93617eb3eafba5e8c9b9a20a2c48b4033ca0133e519b563353147e	131	\\x33d85b9ec14a9751fde3c3e0f99e12757e1ee1163c738bb32ac007b5cbdef993	2021-06-06 15:06:00.298886+00	2021-06-06 14:04:36+00
15	\\x33d85b9ec14a9751fde3c3e0f99e12757e1ee1163c738bb32ac007b5cbdef993	130	\\x3e430c4cd1df2417a1862833a95634345d3f66f2839a55d3435cc8cf68488796	2021-06-06 15:06:00.300916+00	2021-06-06 14:04:33+00
16	\\x3e430c4cd1df2417a1862833a95634345d3f66f2839a55d3435cc8cf68488796	129	\\x21f67ae7f1ced130df732c7e85deb1b39cd0ff4ba7d81a30102543f3251b6480	2021-06-06 15:06:00.302905+00	2021-06-06 14:04:30+00
17	\\x21f67ae7f1ced130df732c7e85deb1b39cd0ff4ba7d81a30102543f3251b6480	128	\\x3235f55eac0bea0ddb27b0a03a11fa244432bbf28474e6c8aeae32517f73243d	2021-06-06 15:06:00.304869+00	2021-06-06 14:04:24+00
18	\\x3235f55eac0bea0ddb27b0a03a11fa244432bbf28474e6c8aeae32517f73243d	127	\\x65a162b396ddc954a09f98c5c93efa8ed4afbae2a88ccd6681a0de403358ee6b	2021-06-06 15:06:00.306504+00	2021-06-06 14:04:21+00
19	\\x65a162b396ddc954a09f98c5c93efa8ed4afbae2a88ccd6681a0de403358ee6b	126	\\x1a91923109d94b1c67e92a092a3907b59ac8f36a7e98dbb865c9655ea8921665	2021-06-06 15:06:00.308635+00	2021-06-06 14:04:18+00
20	\\x1a91923109d94b1c67e92a092a3907b59ac8f36a7e98dbb865c9655ea8921665	125	\\x8c75fa90187b12361057784b166615319e194faad976df76b072019532a3c2a3	2021-06-06 15:06:00.310649+00	2021-06-06 14:04:15+00
21	\\x8c75fa90187b12361057784b166615319e194faad976df76b072019532a3c2a3	124	\\x26754f84103c878c18fb94483429ed62cccf84b27ae1b7abedb06ef8ccbf4187	2021-06-06 15:06:00.31268+00	2021-06-06 14:04:12+00
22	\\x26754f84103c878c18fb94483429ed62cccf84b27ae1b7abedb06ef8ccbf4187	123	\\xa18abfe37ec4a6db23052e393cce5d379d5bbcf5960ba688ccbf726112ad7be6	2021-06-06 15:06:00.314435+00	2021-06-06 14:04:09+00
23	\\xa18abfe37ec4a6db23052e393cce5d379d5bbcf5960ba688ccbf726112ad7be6	122	\\xc3af2d0a6119ed471375f034bf8afc96268ee20fabaeb44d6d91a05c27e1a590	2021-06-06 15:06:00.316198+00	2021-06-06 14:04:06+00
24	\\xc3af2d0a6119ed471375f034bf8afc96268ee20fabaeb44d6d91a05c27e1a590	121	\\xc5fc06882d80beee90aa26a7aadb8eaaaac1b79176a7811cd605f64b3b961d99	2021-06-06 15:06:00.317968+00	2021-06-06 14:04:03+00
25	\\xc5fc06882d80beee90aa26a7aadb8eaaaac1b79176a7811cd605f64b3b961d99	120	\\x849c4a461f0682221348f275384cf9a35d789e9ab95c8388da70473e1a321689	2021-06-06 15:06:00.319951+00	2021-06-06 14:04:00+00
26	\\x849c4a461f0682221348f275384cf9a35d789e9ab95c8388da70473e1a321689	119	\\x5f153d2c821951d55dda572941ec1b9d2f6bcef40769db5a3191c8991be68f45	2021-06-06 15:06:00.321854+00	2021-06-06 14:03:54+00
27	\\x5f153d2c821951d55dda572941ec1b9d2f6bcef40769db5a3191c8991be68f45	118	\\xcdf29c72c1fa9f62708237386f5ce1f8f5ab8432f916a2651eb76f59fc462449	2021-06-06 15:06:00.323853+00	2021-06-06 14:03:48+00
28	\\xcdf29c72c1fa9f62708237386f5ce1f8f5ab8432f916a2651eb76f59fc462449	117	\\xf6aa822843def249748493a22f83cc5eb83cd8844cfb17e031f9895ed0d87313	2021-06-06 15:06:00.325733+00	2021-06-06 14:03:45+00
29	\\xf6aa822843def249748493a22f83cc5eb83cd8844cfb17e031f9895ed0d87313	116	\\x6908d25d34d376bd8e0af5401d82b5e492d763a3d6fc67baaba6352b1e9beaa2	2021-06-06 15:06:00.327692+00	2021-06-06 14:03:42+00
30	\\x6908d25d34d376bd8e0af5401d82b5e492d763a3d6fc67baaba6352b1e9beaa2	115	\\x8a07251f9a22580dd0fd412e4ce6f2c220128151ae3b51bb41348cca63bfd1b1	2021-06-06 15:06:00.329514+00	2021-06-06 14:03:36+00
31	\\x8a07251f9a22580dd0fd412e4ce6f2c220128151ae3b51bb41348cca63bfd1b1	114	\\x289aece5ef93099d2d523219d41a695a301cb82b0362c47afdbf671687ef7647	2021-06-06 15:06:00.33135+00	2021-06-06 14:03:30+00
32	\\x289aece5ef93099d2d523219d41a695a301cb82b0362c47afdbf671687ef7647	113	\\x2d098a4296699d4b42d21001cab852b642e931a7e4da37bd9f90b591df45f395	2021-06-06 15:06:00.333193+00	2021-06-06 14:03:24+00
33	\\x2d098a4296699d4b42d21001cab852b642e931a7e4da37bd9f90b591df45f395	112	\\xbe6e49f9d02d760395ae260c19ed51f5a9477ded64ae67070a9c58d98fb53318	2021-06-06 15:06:00.335111+00	2021-06-06 14:03:21+00
34	\\xbe6e49f9d02d760395ae260c19ed51f5a9477ded64ae67070a9c58d98fb53318	111	\\x256dcd8bc2bfde57fd6b1808ac823dacc65b614dedca43a39523f26f5509dfe3	2021-06-06 15:06:00.33696+00	2021-06-06 14:03:18+00
35	\\x256dcd8bc2bfde57fd6b1808ac823dacc65b614dedca43a39523f26f5509dfe3	110	\\x6c8b177a2addc174408ae2171c115fcc6b6300d692e1ae46045f56b3c1fc977e	2021-06-06 15:06:00.338808+00	2021-06-06 14:03:15+00
36	\\x6c8b177a2addc174408ae2171c115fcc6b6300d692e1ae46045f56b3c1fc977e	109	\\xb20e39385acdd6c82cd22bfee494292f6cce5648255f3a0b9373e08d679ea604	2021-06-06 15:06:00.340665+00	2021-06-06 14:03:09+00
37	\\xb20e39385acdd6c82cd22bfee494292f6cce5648255f3a0b9373e08d679ea604	108	\\xd5818ed3c4b2e49deaac7a9ad9c1d8c18681a9f42670c0ffdc5c155205aab0a8	2021-06-06 15:06:00.342488+00	2021-06-06 14:03:06+00
38	\\xd5818ed3c4b2e49deaac7a9ad9c1d8c18681a9f42670c0ffdc5c155205aab0a8	107	\\xcaf0356cb6dfe435e85ebd1af4d71b3b7b9baf98b9f47770fce8fe6b57c2cb29	2021-06-06 15:06:00.344356+00	2021-06-06 14:03:00+00
39	\\xcaf0356cb6dfe435e85ebd1af4d71b3b7b9baf98b9f47770fce8fe6b57c2cb29	106	\\x66f7592e08e8bff6485e6e3362f2e5324b990c63823a66cf25f2a0ac1eadf1ba	2021-06-06 15:06:00.346279+00	2021-06-06 14:02:54+00
40	\\x66f7592e08e8bff6485e6e3362f2e5324b990c63823a66cf25f2a0ac1eadf1ba	105	\\x992be724dc9202a696895a4376bfcdde81ad7f13b131c65118afd09595ca986b	2021-06-06 15:06:00.348058+00	2021-06-06 14:02:48+00
41	\\x992be724dc9202a696895a4376bfcdde81ad7f13b131c65118afd09595ca986b	104	\\x13b280a24bd408cc1aa1b0409125f26de20edff3f2f5695f08a3a248cc2ebc2e	2021-06-06 15:06:00.35011+00	2021-06-06 14:02:45+00
42	\\x13b280a24bd408cc1aa1b0409125f26de20edff3f2f5695f08a3a248cc2ebc2e	103	\\x98dcc75d80f581e8ed5b43139ada49adf5be4560f180898aa26e4880f0dbb279	2021-06-06 15:06:00.352115+00	2021-06-06 14:02:42+00
43	\\x98dcc75d80f581e8ed5b43139ada49adf5be4560f180898aa26e4880f0dbb279	102	\\x16f15ee57118dd44bda30c2713b8dcd1eb27ea337a6d299b4da666d7d02ae345	2021-06-06 15:06:00.354035+00	2021-06-06 14:02:39+00
44	\\x16f15ee57118dd44bda30c2713b8dcd1eb27ea337a6d299b4da666d7d02ae345	101	\\x9335185dfeaad0c2169cefbfe96c40a2c1be53dacf3722262dd78459dbd69eee	2021-06-06 15:06:00.355922+00	2021-06-06 14:02:36+00
45	\\x9335185dfeaad0c2169cefbfe96c40a2c1be53dacf3722262dd78459dbd69eee	100	\\xa203fc336961bd4a8c6252dc50c6e2b7c176c4840c2bfb5e1c4ce8100537f235	2021-06-06 15:06:00.357715+00	2021-06-06 14:02:30+00
46	\\xa203fc336961bd4a8c6252dc50c6e2b7c176c4840c2bfb5e1c4ce8100537f235	99	\\x7a5562bdfd4daed7a6ad397ab450825299c4bb5f070583b276f8f2f932d36038	2021-06-06 15:06:00.359597+00	2021-06-06 14:02:27+00
47	\\x7a5562bdfd4daed7a6ad397ab450825299c4bb5f070583b276f8f2f932d36038	98	\\x788dc3577ab49e7a35ca89f857f3302e07e7e8028c8fe9d1f87585750e6dc237	2021-06-06 15:06:00.361427+00	2021-06-06 14:02:24+00
48	\\x788dc3577ab49e7a35ca89f857f3302e07e7e8028c8fe9d1f87585750e6dc237	97	\\x89c37c388898bb85b90e787b6eda590a6fd4081e4630d7fdf75e5531c4a10ebd	2021-06-06 15:06:00.363271+00	2021-06-06 14:02:18+00
49	\\x89c37c388898bb85b90e787b6eda590a6fd4081e4630d7fdf75e5531c4a10ebd	96	\\xb693c2e28dc5d9bd820326594410d032c2b6b4b2a5ac1a357480ba30dd07e859	2021-06-06 15:06:00.365154+00	2021-06-06 14:02:15+00
50	\\xb693c2e28dc5d9bd820326594410d032c2b6b4b2a5ac1a357480ba30dd07e859	95	\\x9ec833309d37a40d02deb94c3c0430c77d48bf9ec652408e8bc10c7474c08d4e	2021-06-06 15:06:00.367126+00	2021-06-06 14:02:12+00
51	\\xab675cb402c36af6fa3e707dda62fb46d59a44b64665f78845154e944968af47	145	\\x1b602bdee23765f479e204f242e5f05b495f85d12c5a944e5bf1ded9d2f14422	2021-06-06 15:06:03.26571+00	2021-06-06 15:06:03+00
52	\\xf0055363cebfa7e4bc3b7df8da507cb5b3b6c883939af203cd7a1925b135b42a	146	\\xab675cb402c36af6fa3e707dda62fb46d59a44b64665f78845154e944968af47	2021-06-06 15:07:05.72098+00	2021-06-06 15:07:05+00
53	\\x43d8a462b3bcb5aec4e1b2269d31731767c20398c8de4cedaea8401e94200e23	147	\\xf0055363cebfa7e4bc3b7df8da507cb5b3b6c883939af203cd7a1925b135b42a	2021-06-06 15:09:39.635736+00	2021-06-06 15:09:39+00
54	\\x23f6c4e42c4b28f300e638548c7d3a375ca61249c3791721ccb2c0150ca2de96	148	\\x43d8a462b3bcb5aec4e1b2269d31731767c20398c8de4cedaea8401e94200e23	2021-06-06 15:11:29.729021+00	2021-06-06 15:11:29+00
\.


--
-- Data for Name: initiators; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.initiators (id, job_spec_id, type, created_at, deleted_at, schedule, "time", ran, address, requesters, name, params, from_block, to_block, topics, request_data, feeds, threshold, "precision", polling_interval, absolute_threshold, updated_at, poll_timer, idle_timer, job_id_topic_filter) FROM stdin;
1	c99333d0-32ed-4cb8-967b-956c7f0329b5	runlog	2021-06-06 15:09:37.359462+00	\N		\N	f	\\xd94d41f23f1d42c51ab61685e5617bbc858e5871			\N	\N	\N	null	\N	\N	0	0	\N	0	2021-06-06 15:09:37.359462+00	{"period": "0s"}	{"duration": "0s"}	00000000-0000-0000-0000-000000000000
2	edc06e41-74cc-4c2e-a6c5-4e5dcaf7bb20	web	2021-06-06 15:10:02.996627+00	\N		\N	f	\\x0000000000000000000000000000000000000000			\N	\N	\N	null	\N	\N	0	0	\N	0	2021-06-06 15:10:02.996627+00	{"period": "0s"}	{"duration": "0s"}	00000000-0000-0000-0000-000000000000
\.


--
-- Data for Name: job_runs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.job_runs (result_id, run_request_id, status, created_at, finished_at, updated_at, initiator_id, deleted_at, creation_height, observed_height, payment, job_spec_id, id) FROM stdin;
\.


--
-- Data for Name: job_spec_errors; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.job_spec_errors (id, job_spec_id, description, occurrences, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: job_spec_errors_v2; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.job_spec_errors_v2 (id, job_id, description, occurrences, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: job_specs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.job_specs (created_at, start_at, end_at, deleted_at, min_payment, id, updated_at, name) FROM stdin;
2021-06-06 15:09:37.3538+00	\N	\N	\N	\N	c99333d0-32ed-4cb8-967b-956c7f0329b5	2021-06-06 15:09:37.357296+00	ResolveENSname
2021-06-06 15:10:02.992692+00	\N	\N	\N	\N	edc06e41-74cc-4c2e-a6c5-4e5dcaf7bb20	2021-06-06 15:10:02.99577+00	ResolveENSnameWebTrigger
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.jobs (id, pipeline_spec_id, offchainreporting_oracle_spec_id, name, schema_version, type, max_task_duration, direct_request_spec_id, flux_monitor_spec_id, keeper_spec_id, cron_spec_id) FROM stdin;
\.


--
-- Data for Name: keeper_registries; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.keeper_registries (id, job_id, keeper_index, contract_address, from_address, check_gas, block_count_per_turn, num_keepers) FROM stdin;
\.


--
-- Data for Name: keeper_specs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.keeper_specs (id, contract_address, from_address, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: keys; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.keys (address, json, created_at, updated_at, next_nonce, id, last_used, is_funding, deleted_at) FROM stdin;
\\x7b5f1610920d5baf00d684929272213baf962efe	{"id": "c90a93de-913a-42ba-830c-80761e4b2873", "crypto": {"kdf": "scrypt", "mac": "bd84013d0ba6dde0a848674ee2871ccd6061d571234f2e119b2230df56312e3e", "cipher": "aes-128-ctr", "kdfparams": {"n": 262144, "p": 1, "r": 8, "salt": "5c6f877db46bec876ca303abc4a1ba12bfbbc52903fb081ab1e92a4a3a14de6f", "dklen": 32}, "ciphertext": "85271a6da2f5310a3b7120d3a2401565b03b83fc8c40e3d6fac0e4343eef33cf", "cipherparams": {"iv": "43e3915ee0e323a0b47e37ac17a63ccd"}}, "address": "7b5f1610920d5baf00d684929272213baf962efe", "version": 3}	2021-06-06 15:05:56.959776+00	2021-06-06 15:05:56.959776+00	0	1	\N	f	\N
\\x1dcaf21e385bbfafa02b0cc936eb2df7da155e64	{"id": "8363bfd3-6d24-4af6-84f6-821fec3312bf", "crypto": {"kdf": "scrypt", "mac": "adcc934de92b724ccd6547d22ea3b4d8f36a105fa4aa5c354bd6ad711a01c9bd", "cipher": "aes-128-ctr", "kdfparams": {"n": 262144, "p": 1, "r": 8, "salt": "9879bbb813be8a0abf17bbc7caff86559f9e3cb99c3a5ef1a7ed01081474192a", "dklen": 32}, "ciphertext": "7bc03ac5ec53c1c9adf968cdc9ebb94c5ee569bb2c21e79693bd7cb64298a9f9", "cipherparams": {"iv": "0ebad6066a3541219e722830ccb575e9"}}, "address": "1dcaf21e385bbfafa02b0cc936eb2df7da155e64", "version": 3}	2021-06-06 15:06:02.551935+00	2021-06-06 15:06:02.551935+00	0	3	\N	t	\N
\.


--
-- Data for Name: log_broadcasts; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.log_broadcasts (id, block_hash, log_index, job_id, created_at, block_number, job_id_v2, consumed) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.migrations (id) FROM stdin;
1611847145
0002_gormv2
0003_eth_logs_table
0004_cleanup_tx_state
0005_eth_tx_attempts_insufficient_eth_index
0006_unique_task_specs_per_pipeline_run
0007_reverse_eth_logs_table
0008_reapply_eth_logs_table
0009_add_min_payment_to_flux_monitor_spec
0010_bridge_fk
0011_latest_round_requested
0012_change_jobs_to_numeric
0013_create_flux_monitor_round_stats_v2
0014_add_keeper_tables
0015_simplify_log_broadcaster
0016_pipeline_task_run_dot_id
0017_bptxm_chain_nonce_fastforward
0018_add_node_version_table
0019_last_run_height_column_to_keeper_table
0020_remove_result_task
0021_add_job_id_topic_filter
0022_unfinished_pipeline_task_run_idx
0023_add_confirmations_to_direct_request
0024_add_cron_spec_tables
\.


--
-- Data for Name: node_versions; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.node_versions (version, created_at) FROM stdin;
0.10.5	2021-06-06 15:05:54.422283
\.


--
-- Data for Name: offchainreporting_contract_configs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.offchainreporting_contract_configs (offchainreporting_oracle_spec_id, config_digest, signers, transmitters, threshold, encoded_config_version, encoded, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: offchainreporting_latest_round_requested; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.offchainreporting_latest_round_requested (offchainreporting_oracle_spec_id, requester, config_digest, epoch, round, raw) FROM stdin;
\.


--
-- Data for Name: offchainreporting_oracle_specs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.offchainreporting_oracle_specs (id, contract_address, p2p_peer_id, p2p_bootstrap_peers, is_bootstrap_peer, encrypted_ocr_key_bundle_id, monitoring_endpoint, transmitter_address, observation_timeout, blockchain_timeout, contract_config_tracker_subscribe_interval, contract_config_tracker_poll_interval, contract_config_confirmations, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: offchainreporting_pending_transmissions; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.offchainreporting_pending_transmissions (offchainreporting_oracle_spec_id, config_digest, epoch, round, "time", median, serialized_report, rs, ss, vs, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: offchainreporting_persistent_states; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.offchainreporting_persistent_states (offchainreporting_oracle_spec_id, config_digest, epoch, highest_sent_epoch, highest_received_epoch, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: p2p_peers; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.p2p_peers (id, addr, created_at, updated_at, peer_id) FROM stdin;
\.


--
-- Data for Name: pipeline_runs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.pipeline_runs (id, pipeline_spec_id, meta, created_at, finished_at, errors, outputs) FROM stdin;
\.


--
-- Data for Name: pipeline_specs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.pipeline_specs (id, dot_dag_source, created_at, max_task_duration) FROM stdin;
\.


--
-- Data for Name: pipeline_task_runs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.pipeline_task_runs (id, pipeline_run_id, type, index, output, error, created_at, finished_at, dot_id) FROM stdin;
\.


--
-- Data for Name: run_requests; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.run_requests (id, request_id, tx_hash, requester, created_at, block_hash, payment, request_params) FROM stdin;
\.


--
-- Data for Name: run_results; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.run_results (id, data, error_message, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: service_agreements; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.service_agreements (id, created_at, encumbrance_id, request_body, signature, job_spec_id, updated_at) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.sessions (id, last_used, created_at) FROM stdin;
cf15204e5bc94885a7b9bd979bcd07af	2021-06-06 15:11:25.384324+00	2021-06-06 15:06:56.541637+00
\.


--
-- Data for Name: sync_events; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.sync_events (id, created_at, updated_at, body) FROM stdin;
\.


--
-- Data for Name: task_runs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.task_runs (result_id, status, task_spec_id, minimum_confirmations, created_at, confirmations, job_run_id, id, updated_at) FROM stdin;
\.


--
-- Data for Name: task_specs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.task_specs (id, created_at, updated_at, deleted_at, type, confirmations, params, job_spec_id) FROM stdin;
1	2021-06-06 15:09:37.364097+00	2021-06-06 15:09:37.364097+00	\N	ensbridge	\N	\N	c99333d0-32ed-4cb8-967b-956c7f0329b5
2	2021-06-06 15:09:37.364097+00	2021-06-06 15:09:37.364097+00	\N	ethint256	\N	\N	c99333d0-32ed-4cb8-967b-956c7f0329b5
3	2021-06-06 15:09:37.364097+00	2021-06-06 15:09:37.364097+00	\N	ethtx	\N	\N	c99333d0-32ed-4cb8-967b-956c7f0329b5
4	2021-06-06 15:10:02.99815+00	2021-06-06 15:10:02.99815+00	\N	ensbridge	\N	{"name": "testdomain1.eth"}	edc06e41-74cc-4c2e-a6c5-4e5dcaf7bb20
5	2021-06-06 15:10:02.99815+00	2021-06-06 15:10:02.99815+00	\N	ethint256	\N	\N	edc06e41-74cc-4c2e-a6c5-4e5dcaf7bb20
\.


--
-- Data for Name: upkeep_registrations; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.upkeep_registrations (id, registry_id, execute_gas, check_data, upkeep_id, positioning_constant, last_run_block_height) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.users (email, hashed_password, created_at, token_key, token_salt, token_hashed_secret, updated_at, token_secret) FROM stdin;
a@a.com	$2a$10$mLz91THsFc23sfVDFFOQs.azopL4yfPab/MAM1VvNV2CrD8J6asgm	2021-06-06 15:05:58.56358+00				2021-06-06 15:05:58.562642+00	\N
\.


--
-- Name: configurations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.configurations_id_seq', 1, true);


--
-- Name: cron_specs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.cron_specs_id_seq', 1, false);


--
-- Name: encrypted_p2p_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.encrypted_p2p_keys_id_seq', 1, true);


--
-- Name: encumbrances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.encumbrances_id_seq', 1, false);


--
-- Name: eth_receipts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.eth_receipts_id_seq', 1, false);


--
-- Name: eth_request_event_specs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.eth_request_event_specs_id_seq', 1, false);


--
-- Name: eth_tx_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.eth_tx_attempts_id_seq', 1, false);


--
-- Name: eth_txes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.eth_txes_id_seq', 1, false);


--
-- Name: external_initiators_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.external_initiators_id_seq', 1, false);


--
-- Name: flux_monitor_round_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.flux_monitor_round_stats_id_seq', 1, false);


--
-- Name: flux_monitor_round_stats_v2_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.flux_monitor_round_stats_v2_id_seq', 1, false);


--
-- Name: flux_monitor_specs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.flux_monitor_specs_id_seq', 1, false);


--
-- Name: heads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.heads_id_seq', 54, true);


--
-- Name: initiators_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.initiators_id_seq', 2, true);


--
-- Name: job_spec_errors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.job_spec_errors_id_seq', 1, false);


--
-- Name: job_spec_errors_v2_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.job_spec_errors_v2_id_seq', 1, false);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: keeper_registries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.keeper_registries_id_seq', 1, false);


--
-- Name: keeper_specs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.keeper_specs_id_seq', 1, false);


--
-- Name: keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.keys_id_seq', 3, true);


--
-- Name: log_consumptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.log_consumptions_id_seq', 1, false);


--
-- Name: offchainreporting_oracle_specs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.offchainreporting_oracle_specs_id_seq', 1, false);


--
-- Name: pipeline_runs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.pipeline_runs_id_seq', 1, false);


--
-- Name: pipeline_specs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.pipeline_specs_id_seq', 1, false);


--
-- Name: pipeline_task_runs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.pipeline_task_runs_id_seq', 1, false);


--
-- Name: run_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.run_requests_id_seq', 1, false);


--
-- Name: run_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.run_results_id_seq', 1, false);


--
-- Name: sync_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.sync_events_id_seq', 1, false);


--
-- Name: task_specs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.task_specs_id_seq', 5, true);


--
-- Name: upkeep_registrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.upkeep_registrations_id_seq', 1, false);


--
-- Name: external_initiators access_key_unique; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.external_initiators
    ADD CONSTRAINT access_key_unique UNIQUE (access_key);


--
-- Name: bridge_types bridge_types_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.bridge_types
    ADD CONSTRAINT bridge_types_pkey PRIMARY KEY (name);


--
-- Name: configurations configurations_name_key; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.configurations
    ADD CONSTRAINT configurations_name_key UNIQUE (name);


--
-- Name: configurations configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.configurations
    ADD CONSTRAINT configurations_pkey PRIMARY KEY (id);


--
-- Name: cron_specs cron_specs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.cron_specs
    ADD CONSTRAINT cron_specs_pkey PRIMARY KEY (id);


--
-- Name: direct_request_specs direct_request_specs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.direct_request_specs
    ADD CONSTRAINT direct_request_specs_pkey PRIMARY KEY (id);


--
-- Name: encrypted_ocr_key_bundles encrypted_ocr_key_bundles_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.encrypted_ocr_key_bundles
    ADD CONSTRAINT encrypted_ocr_key_bundles_pkey PRIMARY KEY (id);


--
-- Name: encrypted_p2p_keys encrypted_p2p_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.encrypted_p2p_keys
    ADD CONSTRAINT encrypted_p2p_keys_pkey PRIMARY KEY (id);


--
-- Name: encrypted_vrf_keys encrypted_secret_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.encrypted_vrf_keys
    ADD CONSTRAINT encrypted_secret_keys_pkey PRIMARY KEY (public_key);


--
-- Name: encumbrances encumbrances_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.encumbrances
    ADD CONSTRAINT encumbrances_pkey PRIMARY KEY (id);


--
-- Name: eth_receipts eth_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_receipts
    ADD CONSTRAINT eth_receipts_pkey PRIMARY KEY (id);


--
-- Name: eth_tx_attempts eth_tx_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_tx_attempts
    ADD CONSTRAINT eth_tx_attempts_pkey PRIMARY KEY (id);


--
-- Name: eth_txes eth_txes_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_txes
    ADD CONSTRAINT eth_txes_pkey PRIMARY KEY (id);


--
-- Name: external_initiators external_initiators_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.external_initiators
    ADD CONSTRAINT external_initiators_pkey PRIMARY KEY (id);


--
-- Name: flux_monitor_round_stats flux_monitor_round_stats_aggregator_round_id_key; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.flux_monitor_round_stats
    ADD CONSTRAINT flux_monitor_round_stats_aggregator_round_id_key UNIQUE (aggregator, round_id);


--
-- Name: flux_monitor_round_stats flux_monitor_round_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.flux_monitor_round_stats
    ADD CONSTRAINT flux_monitor_round_stats_pkey PRIMARY KEY (id);


--
-- Name: flux_monitor_round_stats_v2 flux_monitor_round_stats_v2_aggregator_round_id_key; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.flux_monitor_round_stats_v2
    ADD CONSTRAINT flux_monitor_round_stats_v2_aggregator_round_id_key UNIQUE (aggregator, round_id);


--
-- Name: flux_monitor_round_stats_v2 flux_monitor_round_stats_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.flux_monitor_round_stats_v2
    ADD CONSTRAINT flux_monitor_round_stats_v2_pkey PRIMARY KEY (id);


--
-- Name: flux_monitor_specs flux_monitor_specs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.flux_monitor_specs
    ADD CONSTRAINT flux_monitor_specs_pkey PRIMARY KEY (id);


--
-- Name: heads heads_pkey1; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.heads
    ADD CONSTRAINT heads_pkey1 PRIMARY KEY (id);


--
-- Name: initiators initiators_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.initiators
    ADD CONSTRAINT initiators_pkey PRIMARY KEY (id);


--
-- Name: job_runs job_run_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_runs
    ADD CONSTRAINT job_run_pkey PRIMARY KEY (id);


--
-- Name: job_spec_errors job_spec_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_spec_errors
    ADD CONSTRAINT job_spec_errors_pkey PRIMARY KEY (id);


--
-- Name: job_spec_errors_v2 job_spec_errors_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_spec_errors_v2
    ADD CONSTRAINT job_spec_errors_v2_pkey PRIMARY KEY (id);


--
-- Name: job_specs job_spec_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_specs
    ADD CONSTRAINT job_spec_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: keeper_registries keeper_registries_contract_address_key; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.keeper_registries
    ADD CONSTRAINT keeper_registries_contract_address_key UNIQUE (contract_address);


--
-- Name: keeper_registries keeper_registries_job_id_key; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.keeper_registries
    ADD CONSTRAINT keeper_registries_job_id_key UNIQUE (job_id);


--
-- Name: keeper_registries keeper_registries_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.keeper_registries
    ADD CONSTRAINT keeper_registries_pkey PRIMARY KEY (id);


--
-- Name: keeper_specs keeper_specs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.keeper_specs
    ADD CONSTRAINT keeper_specs_pkey PRIMARY KEY (id);


--
-- Name: keys keys_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_pkey PRIMARY KEY (id);


--
-- Name: log_broadcasts log_consumptions_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.log_broadcasts
    ADD CONSTRAINT log_consumptions_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: node_versions node_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.node_versions
    ADD CONSTRAINT node_versions_pkey PRIMARY KEY (version);


--
-- Name: offchainreporting_contract_configs offchainreporting_contract_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_contract_configs
    ADD CONSTRAINT offchainreporting_contract_configs_pkey PRIMARY KEY (offchainreporting_oracle_spec_id);


--
-- Name: offchainreporting_latest_round_requested offchainreporting_latest_round_requested_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_latest_round_requested
    ADD CONSTRAINT offchainreporting_latest_round_requested_pkey PRIMARY KEY (offchainreporting_oracle_spec_id);


--
-- Name: offchainreporting_oracle_specs offchainreporting_oracle_specs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_oracle_specs
    ADD CONSTRAINT offchainreporting_oracle_specs_pkey PRIMARY KEY (id);


--
-- Name: offchainreporting_pending_transmissions offchainreporting_pending_transmissions_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_pending_transmissions
    ADD CONSTRAINT offchainreporting_pending_transmissions_pkey PRIMARY KEY (offchainreporting_oracle_spec_id, config_digest, epoch, round);


--
-- Name: offchainreporting_persistent_states offchainreporting_persistent_states_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_persistent_states
    ADD CONSTRAINT offchainreporting_persistent_states_pkey PRIMARY KEY (offchainreporting_oracle_spec_id, config_digest);


--
-- Name: pipeline_runs pipeline_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.pipeline_runs
    ADD CONSTRAINT pipeline_runs_pkey PRIMARY KEY (id);


--
-- Name: pipeline_specs pipeline_specs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.pipeline_specs
    ADD CONSTRAINT pipeline_specs_pkey PRIMARY KEY (id);


--
-- Name: pipeline_task_runs pipeline_task_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.pipeline_task_runs
    ADD CONSTRAINT pipeline_task_runs_pkey PRIMARY KEY (id);


--
-- Name: run_requests run_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.run_requests
    ADD CONSTRAINT run_requests_pkey PRIMARY KEY (id);


--
-- Name: run_results run_results_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.run_results
    ADD CONSTRAINT run_results_pkey PRIMARY KEY (id);


--
-- Name: service_agreements service_agreements_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.service_agreements
    ADD CONSTRAINT service_agreements_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sync_events sync_events_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.sync_events
    ADD CONSTRAINT sync_events_pkey PRIMARY KEY (id);


--
-- Name: task_runs task_run_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.task_runs
    ADD CONSTRAINT task_run_pkey PRIMARY KEY (id);


--
-- Name: task_specs task_specs_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.task_specs
    ADD CONSTRAINT task_specs_pkey PRIMARY KEY (id);


--
-- Name: offchainreporting_oracle_specs unique_contract_addr; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_oracle_specs
    ADD CONSTRAINT unique_contract_addr UNIQUE (contract_address);


--
-- Name: upkeep_registrations upkeep_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.upkeep_registrations
    ADD CONSTRAINT upkeep_registrations_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (email);


--
-- Name: external_initiators_name_key; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX external_initiators_name_key ON public.external_initiators USING btree (lower(name));


--
-- Name: idx_bridge_types_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_bridge_types_created_at ON public.bridge_types USING brin (created_at);


--
-- Name: idx_bridge_types_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_bridge_types_updated_at ON public.bridge_types USING brin (updated_at);


--
-- Name: idx_configurations_name; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_configurations_name ON public.configurations USING btree (name);


--
-- Name: idx_direct_request_specs_unique_job_spec_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_direct_request_specs_unique_job_spec_id ON public.direct_request_specs USING btree (on_chain_job_spec_id);


--
-- Name: idx_encumbrances_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_encumbrances_created_at ON public.encumbrances USING brin (created_at);


--
-- Name: idx_encumbrances_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_encumbrances_updated_at ON public.encumbrances USING brin (updated_at);


--
-- Name: idx_eth_receipts_block_number; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_eth_receipts_block_number ON public.eth_receipts USING btree (block_number);


--
-- Name: idx_eth_receipts_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_eth_receipts_created_at ON public.eth_receipts USING brin (created_at);


--
-- Name: idx_eth_receipts_unique; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_eth_receipts_unique ON public.eth_receipts USING btree (tx_hash, block_hash);


--
-- Name: idx_eth_task_run_txes_eth_tx_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_eth_task_run_txes_eth_tx_id ON public.eth_task_run_txes USING btree (eth_tx_id);


--
-- Name: idx_eth_task_run_txes_task_run_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_eth_task_run_txes_task_run_id ON public.eth_task_run_txes USING btree (task_run_id);


--
-- Name: idx_eth_tx_attempts_broadcast_before_block_num; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_eth_tx_attempts_broadcast_before_block_num ON public.eth_tx_attempts USING btree (broadcast_before_block_num);


--
-- Name: idx_eth_tx_attempts_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_eth_tx_attempts_created_at ON public.eth_tx_attempts USING brin (created_at);


--
-- Name: idx_eth_tx_attempts_hash; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_eth_tx_attempts_hash ON public.eth_tx_attempts USING btree (hash);


--
-- Name: idx_eth_tx_attempts_unbroadcast; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_eth_tx_attempts_unbroadcast ON public.eth_tx_attempts USING btree (state) WHERE (state <> 'broadcast'::public.eth_tx_attempts_state);


--
-- Name: idx_eth_tx_attempts_unique_gas_prices; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_eth_tx_attempts_unique_gas_prices ON public.eth_tx_attempts USING btree (eth_tx_id, gas_price);


--
-- Name: idx_eth_txes_broadcast_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_eth_txes_broadcast_at ON public.eth_txes USING brin (broadcast_at);


--
-- Name: idx_eth_txes_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_eth_txes_created_at ON public.eth_txes USING brin (created_at);


--
-- Name: idx_eth_txes_min_unconfirmed_nonce_for_key; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_eth_txes_min_unconfirmed_nonce_for_key ON public.eth_txes USING btree (nonce, from_address) WHERE (state = 'unconfirmed'::public.eth_txes_state);


--
-- Name: idx_eth_txes_nonce_from_address; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_eth_txes_nonce_from_address ON public.eth_txes USING btree (nonce, from_address);


--
-- Name: idx_eth_txes_state_from_address; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_eth_txes_state_from_address ON public.eth_txes USING btree (state, from_address) WHERE (state <> 'confirmed'::public.eth_txes_state);


--
-- Name: idx_external_initiators_deleted_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_external_initiators_deleted_at ON public.external_initiators USING btree (deleted_at);


--
-- Name: idx_heads_hash; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_heads_hash ON public.heads USING btree (hash);


--
-- Name: idx_heads_number; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_heads_number ON public.heads USING btree (number);


--
-- Name: idx_initiators_address; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_initiators_address ON public.initiators USING btree (address);


--
-- Name: idx_initiators_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_initiators_created_at ON public.initiators USING btree (created_at);


--
-- Name: idx_initiators_deleted_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_initiators_deleted_at ON public.initiators USING btree (deleted_at);


--
-- Name: idx_initiators_job_spec_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_initiators_job_spec_id ON public.initiators USING btree (job_spec_id);


--
-- Name: idx_initiators_type; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_initiators_type ON public.initiators USING btree (type);


--
-- Name: idx_initiators_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_initiators_updated_at ON public.initiators USING brin (updated_at);


--
-- Name: idx_job_runs_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_runs_created_at ON public.job_runs USING brin (created_at);


--
-- Name: idx_job_runs_deleted_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_runs_deleted_at ON public.job_runs USING btree (deleted_at);


--
-- Name: idx_job_runs_finished_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_runs_finished_at ON public.job_runs USING brin (finished_at);


--
-- Name: idx_job_runs_initiator_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_runs_initiator_id ON public.job_runs USING btree (initiator_id);


--
-- Name: idx_job_runs_job_spec_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_runs_job_spec_id ON public.job_runs USING btree (job_spec_id);


--
-- Name: idx_job_runs_result_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_runs_result_id ON public.job_runs USING btree (result_id);


--
-- Name: idx_job_runs_run_request_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_runs_run_request_id ON public.job_runs USING btree (run_request_id);


--
-- Name: idx_job_runs_status; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_runs_status ON public.job_runs USING btree (status) WHERE (status <> 'completed'::public.run_status);


--
-- Name: idx_job_runs_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_runs_updated_at ON public.job_runs USING brin (updated_at);


--
-- Name: idx_job_spec_errors_v2_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_spec_errors_v2_created_at ON public.job_spec_errors_v2 USING brin (created_at);


--
-- Name: idx_job_spec_errors_v2_finished_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_spec_errors_v2_finished_at ON public.job_spec_errors_v2 USING brin (updated_at);


--
-- Name: idx_job_specs_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_specs_created_at ON public.job_specs USING btree (created_at);


--
-- Name: idx_job_specs_deleted_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_specs_deleted_at ON public.job_specs USING btree (deleted_at);


--
-- Name: idx_job_specs_end_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_specs_end_at ON public.job_specs USING btree (end_at);


--
-- Name: idx_job_specs_start_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_specs_start_at ON public.job_specs USING btree (start_at);


--
-- Name: idx_job_specs_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_job_specs_updated_at ON public.job_specs USING brin (updated_at);


--
-- Name: idx_jobs_unique_direct_request_spec_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_jobs_unique_direct_request_spec_id ON public.jobs USING btree (direct_request_spec_id);


--
-- Name: idx_jobs_unique_offchain_reporting_oracle_spec_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_jobs_unique_offchain_reporting_oracle_spec_id ON public.jobs USING btree (offchainreporting_oracle_spec_id);


--
-- Name: idx_jobs_unique_pipeline_spec_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_jobs_unique_pipeline_spec_id ON public.jobs USING btree (pipeline_spec_id);


--
-- Name: idx_keeper_registries_keeper_index; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_keeper_registries_keeper_index ON public.keeper_registries USING btree (keeper_index);


--
-- Name: idx_keys_only_one_funding; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_keys_only_one_funding ON public.keys USING btree (is_funding) WHERE (is_funding = true);


--
-- Name: idx_log_broadcasts_unconsumed_job_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_log_broadcasts_unconsumed_job_id ON public.log_broadcasts USING btree (job_id) WHERE ((consumed = false) AND (job_id IS NOT NULL));


--
-- Name: idx_log_broadcasts_unconsumed_job_id_v2; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_log_broadcasts_unconsumed_job_id_v2 ON public.log_broadcasts USING btree (job_id_v2) WHERE ((consumed = false) AND (job_id_v2 IS NOT NULL));


--
-- Name: idx_offchainreporting_oracle_specs_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_offchainreporting_oracle_specs_created_at ON public.offchainreporting_oracle_specs USING brin (created_at);


--
-- Name: idx_offchainreporting_oracle_specs_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_offchainreporting_oracle_specs_updated_at ON public.offchainreporting_oracle_specs USING brin (updated_at);


--
-- Name: idx_offchainreporting_pending_transmissions_time; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_offchainreporting_pending_transmissions_time ON public.offchainreporting_pending_transmissions USING btree ("time");


--
-- Name: idx_only_one_in_progress_tx_per_account; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_only_one_in_progress_tx_per_account ON public.eth_txes USING btree (from_address) WHERE (state = 'in_progress'::public.eth_txes_state);


--
-- Name: idx_only_one_unbroadcast_attempt_per_eth_tx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_only_one_unbroadcast_attempt_per_eth_tx ON public.eth_tx_attempts USING btree (eth_tx_id) WHERE (state <> 'broadcast'::public.eth_tx_attempts_state);


--
-- Name: idx_pipeline_runs_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_pipeline_runs_created_at ON public.pipeline_runs USING brin (created_at);


--
-- Name: idx_pipeline_runs_finished_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_pipeline_runs_finished_at ON public.pipeline_runs USING brin (finished_at);


--
-- Name: idx_pipeline_runs_pipeline_spec_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_pipeline_runs_pipeline_spec_id ON public.pipeline_runs USING btree (pipeline_spec_id);


--
-- Name: idx_pipeline_runs_unfinished_runs; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_pipeline_runs_unfinished_runs ON public.pipeline_runs USING btree (id) WHERE (finished_at IS NULL);


--
-- Name: idx_pipeline_specs_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_pipeline_specs_created_at ON public.pipeline_specs USING brin (created_at);


--
-- Name: idx_pipeline_task_runs_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_pipeline_task_runs_created_at ON public.pipeline_task_runs USING brin (created_at);


--
-- Name: idx_pipeline_task_runs_finished_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_pipeline_task_runs_finished_at ON public.pipeline_task_runs USING brin (finished_at);


--
-- Name: idx_run_requests_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_run_requests_created_at ON public.run_requests USING brin (created_at);


--
-- Name: idx_run_results_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_run_results_created_at ON public.run_results USING brin (created_at);


--
-- Name: idx_run_results_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_run_results_updated_at ON public.run_results USING brin (updated_at);


--
-- Name: idx_service_agreements_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_service_agreements_created_at ON public.service_agreements USING btree (created_at);


--
-- Name: idx_service_agreements_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_service_agreements_updated_at ON public.service_agreements USING brin (updated_at);


--
-- Name: idx_sessions_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_sessions_created_at ON public.sessions USING brin (created_at);


--
-- Name: idx_sessions_last_used; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_sessions_last_used ON public.sessions USING brin (last_used);


--
-- Name: idx_task_runs_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_runs_created_at ON public.task_runs USING brin (created_at);


--
-- Name: idx_task_runs_job_run_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_runs_job_run_id ON public.task_runs USING btree (job_run_id);


--
-- Name: idx_task_runs_result_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_runs_result_id ON public.task_runs USING btree (result_id);


--
-- Name: idx_task_runs_status; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_runs_status ON public.task_runs USING btree (status) WHERE (status <> 'completed'::public.run_status);


--
-- Name: idx_task_runs_task_spec_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_runs_task_spec_id ON public.task_runs USING btree (task_spec_id);


--
-- Name: idx_task_runs_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_runs_updated_at ON public.task_runs USING brin (updated_at);


--
-- Name: idx_task_specs_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_specs_created_at ON public.task_specs USING brin (created_at);


--
-- Name: idx_task_specs_deleted_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_specs_deleted_at ON public.task_specs USING btree (deleted_at);


--
-- Name: idx_task_specs_job_spec_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_specs_job_spec_id ON public.task_specs USING btree (job_spec_id);


--
-- Name: idx_task_specs_type; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_specs_type ON public.task_specs USING btree (type);


--
-- Name: idx_task_specs_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_task_specs_updated_at ON public.task_specs USING brin (updated_at);


--
-- Name: idx_unfinished_pipeline_task_runs; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_unfinished_pipeline_task_runs ON public.pipeline_task_runs USING btree (pipeline_run_id) WHERE (finished_at IS NULL);


--
-- Name: idx_unique_keys_address; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_unique_keys_address ON public.keys USING btree (address);


--
-- Name: idx_unique_peer_ids; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_unique_peer_ids ON public.encrypted_p2p_keys USING btree (peer_id);


--
-- Name: idx_unique_pub_keys; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_unique_pub_keys ON public.encrypted_p2p_keys USING btree (pub_key);


--
-- Name: idx_upkeep_registrations_unique_upkeep_ids_per_keeper; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX idx_upkeep_registrations_unique_upkeep_ids_per_keeper ON public.upkeep_registrations USING btree (registry_id, upkeep_id);


--
-- Name: idx_upkeep_registrations_upkeep_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_upkeep_registrations_upkeep_id ON public.upkeep_registrations USING btree (upkeep_id);


--
-- Name: idx_users_created_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_users_created_at ON public.users USING btree (created_at);


--
-- Name: idx_users_updated_at; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX idx_users_updated_at ON public.users USING brin (updated_at);


--
-- Name: job_spec_errors_created_at_idx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX job_spec_errors_created_at_idx ON public.job_spec_errors USING brin (created_at);


--
-- Name: job_spec_errors_occurrences_idx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX job_spec_errors_occurrences_idx ON public.job_spec_errors USING btree (occurrences);


--
-- Name: job_spec_errors_unique_idx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX job_spec_errors_unique_idx ON public.job_spec_errors USING btree (job_spec_id, description);


--
-- Name: job_spec_errors_updated_at_idx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX job_spec_errors_updated_at_idx ON public.job_spec_errors USING brin (updated_at);


--
-- Name: job_spec_errors_v2_unique_idx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX job_spec_errors_v2_unique_idx ON public.job_spec_errors_v2 USING btree (job_id, description);


--
-- Name: log_consumptions_created_at_idx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX log_consumptions_created_at_idx ON public.log_broadcasts USING brin (created_at);


--
-- Name: log_consumptions_unique_v1_idx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX log_consumptions_unique_v1_idx ON public.log_broadcasts USING btree (job_id, block_hash, log_index) INCLUDE (consumed) WHERE (job_id IS NOT NULL);


--
-- Name: log_consumptions_unique_v2_idx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX log_consumptions_unique_v2_idx ON public.log_broadcasts USING btree (job_id_v2, block_hash, log_index) INCLUDE (consumed) WHERE (job_id_v2 IS NOT NULL);


--
-- Name: p2p_peers_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX p2p_peers_id ON public.p2p_peers USING btree (id);


--
-- Name: p2p_peers_peer_id; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX p2p_peers_peer_id ON public.p2p_peers USING btree (peer_id);


--
-- Name: pipeline_task_runs_pipeline_run_id_dot_id_idx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX pipeline_task_runs_pipeline_run_id_dot_id_idx ON public.pipeline_task_runs USING btree (pipeline_run_id, dot_id);


--
-- Name: sync_events_id_created_at_idx; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX sync_events_id_created_at_idx ON public.sync_events USING btree (id, created_at);


--
-- Name: eth_txes notify_eth_tx_insertion; Type: TRIGGER; Schema: public; Owner: streamr
--

CREATE TRIGGER notify_eth_tx_insertion AFTER INSERT ON public.eth_txes FOR EACH STATEMENT EXECUTE FUNCTION public.notifyethtxinsertion();


--
-- Name: jobs notify_job_created; Type: TRIGGER; Schema: public; Owner: streamr
--

CREATE TRIGGER notify_job_created AFTER INSERT ON public.jobs FOR EACH ROW EXECUTE FUNCTION public.notifyjobcreated();


--
-- Name: jobs notify_job_deleted; Type: TRIGGER; Schema: public; Owner: streamr
--

CREATE TRIGGER notify_job_deleted AFTER DELETE ON public.jobs FOR EACH ROW EXECUTE FUNCTION public.notifyjobdeleted();


--
-- Name: pipeline_runs notify_pipeline_run_started; Type: TRIGGER; Schema: public; Owner: streamr
--

CREATE TRIGGER notify_pipeline_run_started AFTER INSERT ON public.pipeline_runs FOR EACH ROW EXECUTE FUNCTION public.notifypipelinerunstarted();


--
-- Name: eth_receipts eth_receipts_tx_hash_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_receipts
    ADD CONSTRAINT eth_receipts_tx_hash_fkey FOREIGN KEY (tx_hash) REFERENCES public.eth_tx_attempts(hash) ON DELETE CASCADE;


--
-- Name: eth_task_run_txes eth_task_run_txes_eth_tx_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_task_run_txes
    ADD CONSTRAINT eth_task_run_txes_eth_tx_id_fkey FOREIGN KEY (eth_tx_id) REFERENCES public.eth_txes(id) ON DELETE CASCADE;


--
-- Name: eth_task_run_txes eth_task_run_txes_task_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_task_run_txes
    ADD CONSTRAINT eth_task_run_txes_task_run_id_fkey FOREIGN KEY (task_run_id) REFERENCES public.task_runs(id) ON DELETE CASCADE;


--
-- Name: eth_tx_attempts eth_tx_attempts_eth_tx_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_tx_attempts
    ADD CONSTRAINT eth_tx_attempts_eth_tx_id_fkey FOREIGN KEY (eth_tx_id) REFERENCES public.eth_txes(id) ON DELETE CASCADE;


--
-- Name: eth_txes eth_txes_from_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_txes
    ADD CONSTRAINT eth_txes_from_address_fkey FOREIGN KEY (from_address) REFERENCES public.keys(address);


--
-- Name: initiators fk_initiators_job_spec_id; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.initiators
    ADD CONSTRAINT fk_initiators_job_spec_id FOREIGN KEY (job_spec_id) REFERENCES public.job_specs(id) ON DELETE RESTRICT;


--
-- Name: job_runs fk_job_runs_initiator_id; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_runs
    ADD CONSTRAINT fk_job_runs_initiator_id FOREIGN KEY (initiator_id) REFERENCES public.initiators(id) ON DELETE CASCADE;


--
-- Name: job_runs fk_job_runs_result_id; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_runs
    ADD CONSTRAINT fk_job_runs_result_id FOREIGN KEY (result_id) REFERENCES public.run_results(id) ON DELETE CASCADE;


--
-- Name: job_runs fk_job_runs_run_request_id; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_runs
    ADD CONSTRAINT fk_job_runs_run_request_id FOREIGN KEY (run_request_id) REFERENCES public.run_requests(id) ON DELETE CASCADE;


--
-- Name: service_agreements fk_service_agreements_encumbrance_id; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.service_agreements
    ADD CONSTRAINT fk_service_agreements_encumbrance_id FOREIGN KEY (encumbrance_id) REFERENCES public.encumbrances(id) ON DELETE RESTRICT;


--
-- Name: task_runs fk_task_runs_result_id; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.task_runs
    ADD CONSTRAINT fk_task_runs_result_id FOREIGN KEY (result_id) REFERENCES public.run_results(id) ON DELETE CASCADE;


--
-- Name: task_runs fk_task_runs_task_spec_id; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.task_runs
    ADD CONSTRAINT fk_task_runs_task_spec_id FOREIGN KEY (task_spec_id) REFERENCES public.task_specs(id) ON DELETE CASCADE;


--
-- Name: flux_monitor_round_stats flux_monitor_round_stats_job_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.flux_monitor_round_stats
    ADD CONSTRAINT flux_monitor_round_stats_job_run_id_fkey FOREIGN KEY (job_run_id) REFERENCES public.job_runs(id) ON DELETE CASCADE;


--
-- Name: flux_monitor_round_stats_v2 flux_monitor_round_stats_v2_pipeline_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.flux_monitor_round_stats_v2
    ADD CONSTRAINT flux_monitor_round_stats_v2_pipeline_run_id_fkey FOREIGN KEY (pipeline_run_id) REFERENCES public.pipeline_runs(id) ON DELETE CASCADE;


--
-- Name: job_runs job_runs_job_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_runs
    ADD CONSTRAINT job_runs_job_spec_id_fkey FOREIGN KEY (job_spec_id) REFERENCES public.job_specs(id) ON DELETE CASCADE;


--
-- Name: job_spec_errors job_spec_errors_job_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_spec_errors
    ADD CONSTRAINT job_spec_errors_job_spec_id_fkey FOREIGN KEY (job_spec_id) REFERENCES public.job_specs(id) ON DELETE CASCADE;


--
-- Name: job_spec_errors_v2 job_spec_errors_v2_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.job_spec_errors_v2
    ADD CONSTRAINT job_spec_errors_v2_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE CASCADE;


--
-- Name: jobs jobs_cron_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_cron_spec_id_fkey FOREIGN KEY (cron_spec_id) REFERENCES public.cron_specs(id);


--
-- Name: jobs jobs_direct_request_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_direct_request_spec_id_fkey FOREIGN KEY (direct_request_spec_id) REFERENCES public.direct_request_specs(id);


--
-- Name: jobs jobs_flux_monitor_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_flux_monitor_spec_id_fkey FOREIGN KEY (flux_monitor_spec_id) REFERENCES public.flux_monitor_specs(id);


--
-- Name: jobs jobs_keeper_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_keeper_spec_id_fkey FOREIGN KEY (keeper_spec_id) REFERENCES public.keeper_specs(id);


--
-- Name: jobs jobs_offchainreporting_oracle_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_offchainreporting_oracle_spec_id_fkey FOREIGN KEY (offchainreporting_oracle_spec_id) REFERENCES public.offchainreporting_oracle_specs(id) ON DELETE CASCADE;


--
-- Name: jobs jobs_pipeline_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pipeline_spec_id_fkey FOREIGN KEY (pipeline_spec_id) REFERENCES public.pipeline_specs(id) ON DELETE CASCADE;


--
-- Name: keeper_registries keeper_registries_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.keeper_registries
    ADD CONSTRAINT keeper_registries_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: log_broadcasts log_broadcasts_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.log_broadcasts
    ADD CONSTRAINT log_broadcasts_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.job_specs(id) ON DELETE CASCADE;


--
-- Name: log_broadcasts log_consumptions_job_id_v2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.log_broadcasts
    ADD CONSTRAINT log_consumptions_job_id_v2_fkey FOREIGN KEY (job_id_v2) REFERENCES public.jobs(id) ON DELETE CASCADE;


--
-- Name: offchainreporting_contract_configs offchainreporting_contract_co_offchainreporting_oracle_spe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_contract_configs
    ADD CONSTRAINT offchainreporting_contract_co_offchainreporting_oracle_spe_fkey FOREIGN KEY (offchainreporting_oracle_spec_id) REFERENCES public.offchainreporting_oracle_specs(id) ON DELETE CASCADE;


--
-- Name: offchainreporting_latest_round_requested offchainreporting_latest_roun_offchainreporting_oracle_spe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_latest_round_requested
    ADD CONSTRAINT offchainreporting_latest_roun_offchainreporting_oracle_spe_fkey FOREIGN KEY (offchainreporting_oracle_spec_id) REFERENCES public.offchainreporting_oracle_specs(id) DEFERRABLE;


--
-- Name: offchainreporting_oracle_specs offchainreporting_oracle_specs_encrypted_ocr_key_bundle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_oracle_specs
    ADD CONSTRAINT offchainreporting_oracle_specs_encrypted_ocr_key_bundle_id_fkey FOREIGN KEY (encrypted_ocr_key_bundle_id) REFERENCES public.encrypted_ocr_key_bundles(id);


--
-- Name: offchainreporting_oracle_specs offchainreporting_oracle_specs_p2p_peer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_oracle_specs
    ADD CONSTRAINT offchainreporting_oracle_specs_p2p_peer_id_fkey FOREIGN KEY (p2p_peer_id) REFERENCES public.encrypted_p2p_keys(peer_id);


--
-- Name: offchainreporting_oracle_specs offchainreporting_oracle_specs_transmitter_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_oracle_specs
    ADD CONSTRAINT offchainreporting_oracle_specs_transmitter_address_fkey FOREIGN KEY (transmitter_address) REFERENCES public.keys(address);


--
-- Name: offchainreporting_pending_transmissions offchainreporting_pending_tra_offchainreporting_oracle_spe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_pending_transmissions
    ADD CONSTRAINT offchainreporting_pending_tra_offchainreporting_oracle_spe_fkey FOREIGN KEY (offchainreporting_oracle_spec_id) REFERENCES public.offchainreporting_oracle_specs(id) ON DELETE CASCADE;


--
-- Name: offchainreporting_persistent_states offchainreporting_persistent__offchainreporting_oracle_spe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.offchainreporting_persistent_states
    ADD CONSTRAINT offchainreporting_persistent__offchainreporting_oracle_spe_fkey FOREIGN KEY (offchainreporting_oracle_spec_id) REFERENCES public.offchainreporting_oracle_specs(id) ON DELETE CASCADE;


--
-- Name: p2p_peers p2p_peers_peer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.p2p_peers
    ADD CONSTRAINT p2p_peers_peer_id_fkey FOREIGN KEY (peer_id) REFERENCES public.encrypted_p2p_keys(peer_id) DEFERRABLE;


--
-- Name: pipeline_runs pipeline_runs_pipeline_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.pipeline_runs
    ADD CONSTRAINT pipeline_runs_pipeline_spec_id_fkey FOREIGN KEY (pipeline_spec_id) REFERENCES public.pipeline_specs(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: pipeline_task_runs pipeline_task_runs_pipeline_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.pipeline_task_runs
    ADD CONSTRAINT pipeline_task_runs_pipeline_run_id_fkey FOREIGN KEY (pipeline_run_id) REFERENCES public.pipeline_runs(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: service_agreements service_agreements_job_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.service_agreements
    ADD CONSTRAINT service_agreements_job_spec_id_fkey FOREIGN KEY (job_spec_id) REFERENCES public.job_specs(id) ON DELETE CASCADE;


--
-- Name: task_runs task_runs_job_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.task_runs
    ADD CONSTRAINT task_runs_job_run_id_fkey FOREIGN KEY (job_run_id) REFERENCES public.job_runs(id) ON DELETE CASCADE;


--
-- Name: task_specs task_specs_job_spec_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.task_specs
    ADD CONSTRAINT task_specs_job_spec_id_fkey FOREIGN KEY (job_spec_id) REFERENCES public.job_specs(id) ON DELETE CASCADE;


--
-- Name: upkeep_registrations upkeep_registrations_registry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.upkeep_registrations
    ADD CONSTRAINT upkeep_registrations_registry_id_fkey FOREIGN KEY (registry_id) REFERENCES public.keeper_registries(id) ON DELETE CASCADE DEFERRABLE;


--
-- PostgreSQL database dump complete
--

