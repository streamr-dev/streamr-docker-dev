--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2 (Debian 13.2-1.pgdg100+1)
-- Dumped by pg_dump version 13.2 (Debian 13.2-1.pgdg100+1)

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
-- Name: chain1; Type: SCHEMA; Schema: -; Owner: streamr
--

CREATE SCHEMA chain1;


ALTER SCHEMA chain1 OWNER TO streamr;

--
-- Name: info; Type: SCHEMA; Schema: -; Owner: streamr
--

CREATE SCHEMA info;


ALTER SCHEMA info OWNER TO streamr;

--
-- Name: primary_public; Type: SCHEMA; Schema: -; Owner: streamr
--

CREATE SCHEMA primary_public;


ALTER SCHEMA primary_public OWNER TO streamr;

--
-- Name: sgd1; Type: SCHEMA; Schema: -; Owner: streamr
--

CREATE SCHEMA sgd1;


ALTER SCHEMA sgd1 OWNER TO streamr;

--
-- Name: subgraphs; Type: SCHEMA; Schema: -; Owner: streamr
--

CREATE SCHEMA subgraphs;


ALTER SCHEMA subgraphs OWNER TO streamr;

--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


--
-- Name: deployment_schema_version; Type: TYPE; Schema: public; Owner: streamr
--

CREATE TYPE public.deployment_schema_version AS ENUM (
    'split',
    'relational'
);


ALTER TYPE public.deployment_schema_version OWNER TO streamr;

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
-- Name: health; Type: TYPE; Schema: subgraphs; Owner: streamr
--

CREATE TYPE subgraphs.health AS ENUM (
    'failed',
    'healthy',
    'unhealthy'
);


ALTER TYPE subgraphs.health OWNER TO streamr;

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

--
-- Name: reduce_dim(anyarray); Type: FUNCTION; Schema: public; Owner: streamr
--

CREATE FUNCTION public.reduce_dim(anyarray) RETURNS SETOF anyarray
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
DECLARE
    s $1%TYPE;
BEGIN
    FOREACH s SLICE 1  IN ARRAY $1 LOOP
        RETURN NEXT s;
    END LOOP;
    RETURN;
END;
$_$;


ALTER FUNCTION public.reduce_dim(anyarray) OWNER TO streamr;

--
-- Name: subgraph_log_entity_event(); Type: FUNCTION; Schema: public; Owner: streamr
--

CREATE FUNCTION public.subgraph_log_entity_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    event_id INTEGER;
    new_event_id INTEGER;
    is_reversion BOOLEAN := FALSE;
    operation_type INTEGER := 10;
    event_source  VARCHAR;
    entity VARCHAR;
    entity_id VARCHAR;
    data_before JSONB;
BEGIN
    -- Get operation type and source
    IF (TG_OP = 'INSERT') THEN
        operation_type := 0;
        event_source := NEW.event_source;
        entity := NEW.entity;
        entity_id := NEW.id;
        data_before := NULL;
    ELSIF (TG_OP = 'UPDATE') THEN
        operation_type := 1;
        event_source := NEW.event_source;
        entity := OLD.entity;
        entity_id := OLD.id;
        data_before := OLD.data;
    ELSIF (TG_OP = 'DELETE') THEN
        operation_type := 2;
        event_source := current_setting('vars.current_event_source', TRUE);
        entity := OLD.entity;
        entity_id := OLD.id;
        data_before := OLD.data;
    ELSE
        RAISE EXCEPTION 'unexpected entity row operation type, %', TG_OP;
    END IF;

    IF event_source = 'REVERSION' THEN
        is_reversion := TRUE;
    END IF;

    SELECT id INTO event_id
    FROM event_meta_data
    WHERE db_transaction_id = txid_current();

    new_event_id := null;

    IF event_id IS NULL THEN
        -- Log information on the postgres transaction for later use in
        -- revert operations
        INSERT INTO event_meta_data
            (db_transaction_id, db_transaction_time, source)
        VALUES
            (txid_current(), statement_timestamp(), event_source)
        RETURNING event_meta_data.id INTO new_event_id;
    END IF;

    -- Log row metadata and changes, specify whether event was an original
    -- ethereum event or a reversion
    EXECUTE format('INSERT INTO %I.entity_history
        (event_id, entity_id, entity,
         data_before, reversion, op_id)
      VALUES
        ($1, $2, $3, $4, $5, $6)', TG_TABLE_SCHEMA)
    USING COALESCE(new_event_id, event_id), entity_id, entity,
          data_before, is_reversion, operation_type;
    RETURN NULL;
END;
$_$;


ALTER FUNCTION public.subgraph_log_entity_event() OWNER TO streamr;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: blocks; Type: TABLE; Schema: chain1; Owner: streamr
--

CREATE TABLE chain1.blocks (
    hash bytea NOT NULL,
    number bigint NOT NULL,
    parent_hash bytea NOT NULL,
    data jsonb NOT NULL
);


ALTER TABLE chain1.blocks OWNER TO streamr;

--
-- Name: call_cache; Type: TABLE; Schema: chain1; Owner: streamr
--

CREATE TABLE chain1.call_cache (
    id bytea NOT NULL,
    return_value bytea NOT NULL,
    contract_address bytea NOT NULL,
    block_number integer NOT NULL
);


ALTER TABLE chain1.call_cache OWNER TO streamr;

--
-- Name: call_meta; Type: TABLE; Schema: chain1; Owner: streamr
--

CREATE TABLE chain1.call_meta (
    contract_address bytea NOT NULL,
    accessed_at date NOT NULL
);


ALTER TABLE chain1.call_meta OWNER TO streamr;

--
-- Name: activity; Type: VIEW; Schema: info; Owner: streamr
--

CREATE VIEW info.activity AS
 SELECT COALESCE(NULLIF(pg_stat_activity.application_name, ''::text), 'unknown'::text) AS application_name,
    pg_stat_activity.pid,
    date_part('epoch'::text, age(now(), pg_stat_activity.query_start)) AS query_age,
    date_part('epoch'::text, age(now(), pg_stat_activity.xact_start)) AS txn_age,
    pg_stat_activity.query
   FROM pg_stat_activity
  WHERE (pg_stat_activity.state = 'active'::text)
  ORDER BY pg_stat_activity.query_start DESC;


ALTER TABLE info.activity OWNER TO streamr;

--
-- Name: deployment_schemas; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.deployment_schemas (
    id integer NOT NULL,
    subgraph character varying NOT NULL,
    name character varying NOT NULL,
    version public.deployment_schema_version NOT NULL,
    shard text NOT NULL,
    network text NOT NULL,
    active boolean NOT NULL
);


ALTER TABLE public.deployment_schemas OWNER TO streamr;

--
-- Name: subgraph_sizes; Type: MATERIALIZED VIEW; Schema: info; Owner: streamr
--

CREATE MATERIALIZED VIEW info.subgraph_sizes AS
 SELECT a.name,
    a.subgraph,
    a.version,
    a.row_estimate,
    a.total_bytes,
    a.index_bytes,
    a.toast_bytes,
    a.table_bytes,
    pg_size_pretty(a.total_bytes) AS total,
    pg_size_pretty(a.index_bytes) AS index,
    pg_size_pretty(a.toast_bytes) AS toast,
    pg_size_pretty(a.table_bytes) AS "table"
   FROM ( SELECT a_1.name,
            a_1.subgraph,
            a_1.version,
            a_1.row_estimate,
            a_1.total_bytes,
            a_1.index_bytes,
            a_1.toast_bytes,
            ((a_1.total_bytes - a_1.index_bytes) - COALESCE(a_1.toast_bytes, (0)::numeric)) AS table_bytes
           FROM ( SELECT n.nspname AS name,
                    ds.subgraph,
                    (ds.version)::text AS version,
                    sum(c.reltuples) AS row_estimate,
                    sum(pg_total_relation_size((c.oid)::regclass)) AS total_bytes,
                    sum(pg_indexes_size((c.oid)::regclass)) AS index_bytes,
                    sum(pg_total_relation_size((c.reltoastrelid)::regclass)) AS toast_bytes
                   FROM ((pg_class c
                     JOIN pg_namespace n ON ((n.oid = c.relnamespace)))
                     JOIN public.deployment_schemas ds ON (((ds.name)::text = n.nspname)))
                  WHERE ((c.relkind = 'r'::"char") AND (n.nspname ~~ 'sgd%'::text))
                  GROUP BY n.nspname, ds.subgraph, ds.version) a_1) a
  WITH NO DATA;


ALTER TABLE info.subgraph_sizes OWNER TO streamr;

--
-- Name: table_sizes; Type: MATERIALIZED VIEW; Schema: info; Owner: streamr
--

CREATE MATERIALIZED VIEW info.table_sizes AS
 SELECT a.table_schema,
    a.table_name,
    a.version,
    a.row_estimate,
    a.total_bytes,
    a.index_bytes,
    a.toast_bytes,
    a.table_bytes,
    pg_size_pretty(a.total_bytes) AS total,
    pg_size_pretty(a.index_bytes) AS index,
    pg_size_pretty(a.toast_bytes) AS toast,
    pg_size_pretty(a.table_bytes) AS "table"
   FROM ( SELECT a_1.table_schema,
            a_1.table_name,
            a_1.version,
            a_1.row_estimate,
            a_1.total_bytes,
            a_1.index_bytes,
            a_1.toast_bytes,
            ((a_1.total_bytes - a_1.index_bytes) - COALESCE(a_1.toast_bytes, (0)::bigint)) AS table_bytes
           FROM ( SELECT n.nspname AS table_schema,
                    c.relname AS table_name,
                    'shared'::text AS version,
                    c.reltuples AS row_estimate,
                    pg_total_relation_size((c.oid)::regclass) AS total_bytes,
                    pg_indexes_size((c.oid)::regclass) AS index_bytes,
                    pg_total_relation_size((c.reltoastrelid)::regclass) AS toast_bytes
                   FROM (pg_class c
                     JOIN pg_namespace n ON ((n.oid = c.relnamespace)))
                  WHERE ((c.relkind = 'r'::"char") AND (n.nspname = ANY (ARRAY['public'::name, 'subgraphs'::name])))) a_1) a
  WITH NO DATA;


ALTER TABLE info.table_sizes OWNER TO streamr;

--
-- Name: all_sizes; Type: VIEW; Schema: info; Owner: streamr
--

CREATE VIEW info.all_sizes AS
 SELECT subgraph_sizes.name,
    subgraph_sizes.subgraph,
    subgraph_sizes.version,
    subgraph_sizes.row_estimate,
    subgraph_sizes.total_bytes,
    subgraph_sizes.index_bytes,
    subgraph_sizes.toast_bytes,
    subgraph_sizes.table_bytes,
    subgraph_sizes.total,
    subgraph_sizes.index,
    subgraph_sizes.toast,
    subgraph_sizes."table"
   FROM info.subgraph_sizes
UNION ALL
 SELECT table_sizes.table_schema AS name,
    table_sizes.table_name AS subgraph,
    table_sizes.version,
    table_sizes.row_estimate,
    table_sizes.total_bytes,
    table_sizes.index_bytes,
    table_sizes.toast_bytes,
    table_sizes.table_bytes,
    table_sizes.total,
    table_sizes.index,
    table_sizes.toast,
    table_sizes."table"
   FROM info.table_sizes;


ALTER TABLE info.all_sizes OWNER TO streamr;

--
-- Name: subgraph; Type: TABLE; Schema: subgraphs; Owner: streamr
--

CREATE TABLE subgraphs.subgraph (
    id text NOT NULL,
    name text NOT NULL,
    current_version text,
    pending_version text,
    created_at numeric NOT NULL,
    vid bigint NOT NULL,
    block_range int4range NOT NULL
);


ALTER TABLE subgraphs.subgraph OWNER TO streamr;

--
-- Name: subgraph_deployment; Type: TABLE; Schema: subgraphs; Owner: streamr
--

CREATE TABLE subgraphs.subgraph_deployment (
    deployment text NOT NULL,
    failed boolean NOT NULL,
    synced boolean NOT NULL,
    earliest_ethereum_block_hash bytea,
    earliest_ethereum_block_number numeric,
    latest_ethereum_block_hash bytea,
    latest_ethereum_block_number numeric,
    entity_count numeric NOT NULL,
    graft_base text,
    graft_block_hash bytea,
    graft_block_number numeric,
    fatal_error text,
    non_fatal_errors text[] DEFAULT '{}'::text[],
    health subgraphs.health NOT NULL,
    reorg_count integer DEFAULT 0 NOT NULL,
    current_reorg_depth integer DEFAULT 0 NOT NULL,
    max_reorg_depth integer DEFAULT 0 NOT NULL,
    last_healthy_ethereum_block_hash bytea,
    last_healthy_ethereum_block_number numeric,
    id integer NOT NULL
);


ALTER TABLE subgraphs.subgraph_deployment OWNER TO streamr;

--
-- Name: subgraph_version; Type: TABLE; Schema: subgraphs; Owner: streamr
--

CREATE TABLE subgraphs.subgraph_version (
    id text NOT NULL,
    subgraph text NOT NULL,
    deployment text NOT NULL,
    created_at numeric NOT NULL,
    vid bigint NOT NULL,
    block_range int4range NOT NULL
);


ALTER TABLE subgraphs.subgraph_version OWNER TO streamr;

--
-- Name: subgraph_info; Type: VIEW; Schema: info; Owner: streamr
--

CREATE VIEW info.subgraph_info AS
 SELECT ds.id AS schema_id,
    ds.name AS schema_name,
    ds.subgraph,
    ds.version,
    s.name,
        CASE
            WHEN (s.pending_version = v.id) THEN 'pending'::text
            WHEN (s.current_version = v.id) THEN 'current'::text
            ELSE 'unused'::text
        END AS status,
    d.failed,
    d.synced
   FROM public.deployment_schemas ds,
    subgraphs.subgraph_deployment d,
    subgraphs.subgraph_version v,
    subgraphs.subgraph s
  WHERE ((d.deployment = (ds.subgraph)::text) AND (v.deployment = d.deployment) AND (v.subgraph = s.id));


ALTER TABLE info.subgraph_info OWNER TO streamr;

--
-- Name: wraparound; Type: VIEW; Schema: info; Owner: streamr
--

CREATE VIEW info.wraparound AS
 SELECT ((pg_class.oid)::regclass)::text AS "table",
    LEAST((( SELECT (pg_settings.setting)::integer AS setting
           FROM pg_settings
          WHERE (pg_settings.name = 'autovacuum_freeze_max_age'::text)) - age(pg_class.relfrozenxid)), (( SELECT (pg_settings.setting)::integer AS setting
           FROM pg_settings
          WHERE (pg_settings.name = 'autovacuum_multixact_freeze_max_age'::text)) - mxid_age(pg_class.relminmxid))) AS tx_before_wraparound_vacuum,
    pg_size_pretty(pg_total_relation_size((pg_class.oid)::regclass)) AS size,
    pg_stat_get_last_autovacuum_time(pg_class.oid) AS last_autovacuum,
    age(pg_class.relfrozenxid) AS xid_age,
    mxid_age(pg_class.relminmxid) AS mxid_age
   FROM pg_class
  WHERE ((pg_class.relfrozenxid <> 0) AND (pg_class.oid > (16384)::oid) AND (pg_class.relkind = 'r'::"char"))
  ORDER BY LEAST((( SELECT (pg_settings.setting)::integer AS setting
           FROM pg_settings
          WHERE (pg_settings.name = 'autovacuum_freeze_max_age'::text)) - age(pg_class.relfrozenxid)), (( SELECT (pg_settings.setting)::integer AS setting
           FROM pg_settings
          WHERE (pg_settings.name = 'autovacuum_multixact_freeze_max_age'::text)) - mxid_age(pg_class.relminmxid)));


ALTER TABLE info.wraparound OWNER TO streamr;

--
-- Name: active_copies; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.active_copies (
    src integer NOT NULL,
    dst integer NOT NULL,
    queued_at timestamp with time zone NOT NULL,
    cancelled_at timestamp with time zone
);


ALTER TABLE public.active_copies OWNER TO streamr;

--
-- Name: active_copies; Type: VIEW; Schema: primary_public; Owner: streamr
--

CREATE VIEW primary_public.active_copies AS
 SELECT active_copies.src,
    active_copies.dst,
    active_copies.queued_at,
    active_copies.cancelled_at
   FROM public.active_copies;


ALTER TABLE primary_public.active_copies OWNER TO streamr;

--
-- Name: chains; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.chains (
    id integer NOT NULL,
    name text NOT NULL,
    net_version text NOT NULL,
    genesis_block_hash text NOT NULL,
    shard text NOT NULL,
    namespace text NOT NULL,
    CONSTRAINT chains_genesis_version_check CHECK (((net_version IS NULL) = (genesis_block_hash IS NULL)))
);


ALTER TABLE public.chains OWNER TO streamr;

--
-- Name: chains; Type: VIEW; Schema: primary_public; Owner: streamr
--

CREATE VIEW primary_public.chains AS
 SELECT chains.id,
    chains.name,
    chains.net_version,
    chains.genesis_block_hash,
    chains.shard,
    chains.namespace
   FROM public.chains;


ALTER TABLE primary_public.chains OWNER TO streamr;

--
-- Name: deployment_schemas; Type: VIEW; Schema: primary_public; Owner: streamr
--

CREATE VIEW primary_public.deployment_schemas AS
 SELECT deployment_schemas.id,
    deployment_schemas.subgraph,
    deployment_schemas.name,
    deployment_schemas.version,
    deployment_schemas.shard,
    deployment_schemas.network,
    deployment_schemas.active
   FROM public.deployment_schemas;


ALTER TABLE primary_public.deployment_schemas OWNER TO streamr;

--
-- Name: __diesel_schema_migrations; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.__diesel_schema_migrations (
    version character varying(50) NOT NULL,
    run_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.__diesel_schema_migrations OWNER TO streamr;

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
-- Name: chains_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.chains_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chains_id_seq OWNER TO streamr;

--
-- Name: chains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.chains_id_seq OWNED BY public.chains.id;


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
-- Name: db_version; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.db_version (
    db_version bigint NOT NULL
);


ALTER TABLE public.db_version OWNER TO streamr;

--
-- Name: deployment_schemas_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.deployment_schemas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deployment_schemas_id_seq OWNER TO streamr;

--
-- Name: deployment_schemas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.deployment_schemas_id_seq OWNED BY public.deployment_schemas.id;


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
-- Name: ens_names; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.ens_names (
    hash character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.ens_names OWNER TO streamr;

--
-- Name: eth_call_cache; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.eth_call_cache (
    id bytea NOT NULL,
    return_value bytea NOT NULL,
    contract_address bytea NOT NULL,
    block_number integer NOT NULL
);


ALTER TABLE public.eth_call_cache OWNER TO streamr;

--
-- Name: eth_call_meta; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.eth_call_meta (
    contract_address bytea NOT NULL,
    accessed_at date NOT NULL
);


ALTER TABLE public.eth_call_meta OWNER TO streamr;

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
-- Name: ethereum_blocks; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.ethereum_blocks (
    hash character varying NOT NULL,
    number bigint NOT NULL,
    parent_hash character varying NOT NULL,
    network_name character varying NOT NULL,
    data jsonb NOT NULL
);


ALTER TABLE public.ethereum_blocks OWNER TO streamr;

--
-- Name: ethereum_networks; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.ethereum_networks (
    name character varying NOT NULL,
    head_block_hash character varying,
    head_block_number bigint,
    net_version character varying NOT NULL,
    genesis_block_hash character varying NOT NULL,
    namespace text NOT NULL,
    CONSTRAINT ethereum_networks_check CHECK (((head_block_hash IS NULL) = (head_block_number IS NULL))),
    CONSTRAINT ethereum_networks_check1 CHECK (((net_version IS NULL) = (genesis_block_hash IS NULL)))
);


ALTER TABLE public.ethereum_networks OWNER TO streamr;

--
-- Name: event_meta_data; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.event_meta_data (
    id integer NOT NULL,
    db_transaction_id bigint NOT NULL,
    db_transaction_time timestamp without time zone NOT NULL,
    source character varying
);


ALTER TABLE public.event_meta_data OWNER TO streamr;

--
-- Name: event_meta_data_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.event_meta_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_meta_data_id_seq OWNER TO streamr;

--
-- Name: event_meta_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.event_meta_data_id_seq OWNED BY public.event_meta_data.id;


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
-- Name: large_notifications; Type: TABLE; Schema: public; Owner: streamr
--

CREATE UNLOGGED TABLE public.large_notifications (
    id integer NOT NULL,
    payload character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.large_notifications OWNER TO streamr;

--
-- Name: TABLE large_notifications; Type: COMMENT; Schema: public; Owner: streamr
--

COMMENT ON TABLE public.large_notifications IS 'Table for notifications whose payload is too big to send directly';


--
-- Name: large_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: streamr
--

CREATE SEQUENCE public.large_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.large_notifications_id_seq OWNER TO streamr;

--
-- Name: large_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: streamr
--

ALTER SEQUENCE public.large_notifications_id_seq OWNED BY public.large_notifications.id;


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
-- Name: unneeded_event_ids; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.unneeded_event_ids (
    event_id bigint NOT NULL
);


ALTER TABLE public.unneeded_event_ids OWNER TO streamr;

--
-- Name: unused_deployments; Type: TABLE; Schema: public; Owner: streamr
--

CREATE TABLE public.unused_deployments (
    deployment text NOT NULL,
    unused_at timestamp with time zone DEFAULT now() NOT NULL,
    removed_at timestamp with time zone,
    subgraphs text[],
    namespace text NOT NULL,
    shard text NOT NULL,
    entity_count integer DEFAULT 0 NOT NULL,
    latest_ethereum_block_hash bytea,
    latest_ethereum_block_number integer,
    failed boolean DEFAULT false NOT NULL,
    synced boolean DEFAULT false NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.unused_deployments OWNER TO streamr;

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
-- Name: permission; Type: TABLE; Schema: sgd1; Owner: streamr
--

CREATE TABLE sgd1.permission (
    id text NOT NULL,
    "user" bytea NOT NULL,
    stream text,
    edit boolean,
    can_delete boolean,
    publish boolean,
    subscribed boolean,
    share boolean,
    vid bigint NOT NULL,
    block_range int4range NOT NULL
);


ALTER TABLE sgd1.permission OWNER TO streamr;

--
-- Name: permission_vid_seq; Type: SEQUENCE; Schema: sgd1; Owner: streamr
--

CREATE SEQUENCE sgd1.permission_vid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sgd1.permission_vid_seq OWNER TO streamr;

--
-- Name: permission_vid_seq; Type: SEQUENCE OWNED BY; Schema: sgd1; Owner: streamr
--

ALTER SEQUENCE sgd1.permission_vid_seq OWNED BY sgd1.permission.vid;


--
-- Name: poi2$; Type: TABLE; Schema: sgd1; Owner: streamr
--

CREATE TABLE sgd1."poi2$" (
    digest bytea NOT NULL,
    id text NOT NULL,
    vid bigint NOT NULL,
    block_range int4range NOT NULL
);


ALTER TABLE sgd1."poi2$" OWNER TO streamr;

--
-- Name: poi2$_vid_seq; Type: SEQUENCE; Schema: sgd1; Owner: streamr
--

CREATE SEQUENCE sgd1."poi2$_vid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sgd1."poi2$_vid_seq" OWNER TO streamr;

--
-- Name: poi2$_vid_seq; Type: SEQUENCE OWNED BY; Schema: sgd1; Owner: streamr
--

ALTER SEQUENCE sgd1."poi2$_vid_seq" OWNED BY sgd1."poi2$".vid;


--
-- Name: stream; Type: TABLE; Schema: sgd1; Owner: streamr
--

CREATE TABLE sgd1.stream (
    id text NOT NULL,
    metadata text NOT NULL,
    vid bigint NOT NULL,
    block_range int4range NOT NULL
);


ALTER TABLE sgd1.stream OWNER TO streamr;

--
-- Name: stream_vid_seq; Type: SEQUENCE; Schema: sgd1; Owner: streamr
--

CREATE SEQUENCE sgd1.stream_vid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sgd1.stream_vid_seq OWNER TO streamr;

--
-- Name: stream_vid_seq; Type: SEQUENCE OWNED BY; Schema: sgd1; Owner: streamr
--

ALTER SEQUENCE sgd1.stream_vid_seq OWNED BY sgd1.stream.vid;


--
-- Name: copy_state; Type: TABLE; Schema: subgraphs; Owner: streamr
--

CREATE TABLE subgraphs.copy_state (
    src integer NOT NULL,
    dst integer NOT NULL,
    target_block_hash bytea NOT NULL,
    target_block_number integer NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    cancelled_at timestamp with time zone
);


ALTER TABLE subgraphs.copy_state OWNER TO streamr;

--
-- Name: copy_table_state; Type: TABLE; Schema: subgraphs; Owner: streamr
--

CREATE TABLE subgraphs.copy_table_state (
    id integer NOT NULL,
    entity_type text NOT NULL,
    dst integer NOT NULL,
    next_vid bigint NOT NULL,
    target_vid bigint NOT NULL,
    batch_size bigint NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    duration_ms bigint DEFAULT 0 NOT NULL
);


ALTER TABLE subgraphs.copy_table_state OWNER TO streamr;

--
-- Name: copy_table_state_id_seq; Type: SEQUENCE; Schema: subgraphs; Owner: streamr
--

CREATE SEQUENCE subgraphs.copy_table_state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subgraphs.copy_table_state_id_seq OWNER TO streamr;

--
-- Name: copy_table_state_id_seq; Type: SEQUENCE OWNED BY; Schema: subgraphs; Owner: streamr
--

ALTER SEQUENCE subgraphs.copy_table_state_id_seq OWNED BY subgraphs.copy_table_state.id;


--
-- Name: dynamic_ethereum_contract_data_source; Type: TABLE; Schema: subgraphs; Owner: streamr
--

CREATE TABLE subgraphs.dynamic_ethereum_contract_data_source (
    name text NOT NULL,
    ethereum_block_hash bytea NOT NULL,
    ethereum_block_number numeric NOT NULL,
    deployment text NOT NULL,
    vid bigint NOT NULL,
    context text,
    address bytea NOT NULL,
    abi text NOT NULL,
    start_block integer NOT NULL
);


ALTER TABLE subgraphs.dynamic_ethereum_contract_data_source OWNER TO streamr;

--
-- Name: dynamic_ethereum_contract_data_source_vid_seq; Type: SEQUENCE; Schema: subgraphs; Owner: streamr
--

CREATE SEQUENCE subgraphs.dynamic_ethereum_contract_data_source_vid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subgraphs.dynamic_ethereum_contract_data_source_vid_seq OWNER TO streamr;

--
-- Name: dynamic_ethereum_contract_data_source_vid_seq; Type: SEQUENCE OWNED BY; Schema: subgraphs; Owner: streamr
--

ALTER SEQUENCE subgraphs.dynamic_ethereum_contract_data_source_vid_seq OWNED BY subgraphs.dynamic_ethereum_contract_data_source.vid;


--
-- Name: subgraph_deployment_assignment; Type: TABLE; Schema: subgraphs; Owner: streamr
--

CREATE TABLE subgraphs.subgraph_deployment_assignment (
    node_id text NOT NULL,
    id integer NOT NULL
);


ALTER TABLE subgraphs.subgraph_deployment_assignment OWNER TO streamr;

--
-- Name: subgraph_error; Type: TABLE; Schema: subgraphs; Owner: streamr
--

CREATE TABLE subgraphs.subgraph_error (
    id text NOT NULL,
    subgraph_id text NOT NULL,
    message text NOT NULL,
    block_hash bytea,
    handler text,
    vid bigint NOT NULL,
    block_range int4range NOT NULL,
    deterministic boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE subgraphs.subgraph_error OWNER TO streamr;

--
-- Name: subgraph_error_vid_seq; Type: SEQUENCE; Schema: subgraphs; Owner: streamr
--

CREATE SEQUENCE subgraphs.subgraph_error_vid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subgraphs.subgraph_error_vid_seq OWNER TO streamr;

--
-- Name: subgraph_error_vid_seq; Type: SEQUENCE OWNED BY; Schema: subgraphs; Owner: streamr
--

ALTER SEQUENCE subgraphs.subgraph_error_vid_seq OWNED BY subgraphs.subgraph_error.vid;


--
-- Name: subgraph_manifest; Type: TABLE; Schema: subgraphs; Owner: streamr
--

CREATE TABLE subgraphs.subgraph_manifest (
    spec_version text NOT NULL,
    description text,
    repository text,
    schema text NOT NULL,
    features text[] DEFAULT '{}'::text[] NOT NULL,
    id integer NOT NULL
);


ALTER TABLE subgraphs.subgraph_manifest OWNER TO streamr;

--
-- Name: subgraph_version_vid_seq; Type: SEQUENCE; Schema: subgraphs; Owner: streamr
--

CREATE SEQUENCE subgraphs.subgraph_version_vid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subgraphs.subgraph_version_vid_seq OWNER TO streamr;

--
-- Name: subgraph_version_vid_seq; Type: SEQUENCE OWNED BY; Schema: subgraphs; Owner: streamr
--

ALTER SEQUENCE subgraphs.subgraph_version_vid_seq OWNED BY subgraphs.subgraph_version.vid;


--
-- Name: subgraph_vid_seq; Type: SEQUENCE; Schema: subgraphs; Owner: streamr
--

CREATE SEQUENCE subgraphs.subgraph_vid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subgraphs.subgraph_vid_seq OWNER TO streamr;

--
-- Name: subgraph_vid_seq; Type: SEQUENCE OWNED BY; Schema: subgraphs; Owner: streamr
--

ALTER SEQUENCE subgraphs.subgraph_vid_seq OWNED BY subgraphs.subgraph.vid;


--
-- Name: chains id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.chains ALTER COLUMN id SET DEFAULT nextval('public.chains_id_seq'::regclass);


--
-- Name: chains namespace; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.chains ALTER COLUMN namespace SET DEFAULT ('chain'::text || currval('public.chains_id_seq'::regclass));


--
-- Name: configurations id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.configurations ALTER COLUMN id SET DEFAULT nextval('public.configurations_id_seq'::regclass);


--
-- Name: cron_specs id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.cron_specs ALTER COLUMN id SET DEFAULT nextval('public.cron_specs_id_seq'::regclass);


--
-- Name: deployment_schemas id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.deployment_schemas ALTER COLUMN id SET DEFAULT nextval('public.deployment_schemas_id_seq'::regclass);


--
-- Name: deployment_schemas name; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.deployment_schemas ALTER COLUMN name SET DEFAULT ('sgd'::text || currval('public.deployment_schemas_id_seq'::regclass));


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
-- Name: event_meta_data id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.event_meta_data ALTER COLUMN id SET DEFAULT nextval('public.event_meta_data_id_seq'::regclass);


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
-- Name: large_notifications id; Type: DEFAULT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.large_notifications ALTER COLUMN id SET DEFAULT nextval('public.large_notifications_id_seq'::regclass);


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
-- Name: permission vid; Type: DEFAULT; Schema: sgd1; Owner: streamr
--

ALTER TABLE ONLY sgd1.permission ALTER COLUMN vid SET DEFAULT nextval('sgd1.permission_vid_seq'::regclass);


--
-- Name: poi2$ vid; Type: DEFAULT; Schema: sgd1; Owner: streamr
--

ALTER TABLE ONLY sgd1."poi2$" ALTER COLUMN vid SET DEFAULT nextval('sgd1."poi2$_vid_seq"'::regclass);


--
-- Name: stream vid; Type: DEFAULT; Schema: sgd1; Owner: streamr
--

ALTER TABLE ONLY sgd1.stream ALTER COLUMN vid SET DEFAULT nextval('sgd1.stream_vid_seq'::regclass);


--
-- Name: copy_table_state id; Type: DEFAULT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.copy_table_state ALTER COLUMN id SET DEFAULT nextval('subgraphs.copy_table_state_id_seq'::regclass);


--
-- Name: dynamic_ethereum_contract_data_source vid; Type: DEFAULT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.dynamic_ethereum_contract_data_source ALTER COLUMN vid SET DEFAULT nextval('subgraphs.dynamic_ethereum_contract_data_source_vid_seq'::regclass);


--
-- Name: subgraph vid; Type: DEFAULT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph ALTER COLUMN vid SET DEFAULT nextval('subgraphs.subgraph_vid_seq'::regclass);


--
-- Name: subgraph_error vid; Type: DEFAULT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_error ALTER COLUMN vid SET DEFAULT nextval('subgraphs.subgraph_error_vid_seq'::regclass);


--
-- Name: subgraph_version vid; Type: DEFAULT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_version ALTER COLUMN vid SET DEFAULT nextval('subgraphs.subgraph_version_vid_seq'::regclass);


--
-- Data for Name: blocks; Type: TABLE DATA; Schema: chain1; Owner: streamr
--

COPY chain1.blocks (hash, number, parent_hash, data) FROM stdin;
\\xfacba8827d937891d382a254270147631c8ca9d967fb642f7ab237946cc2c7c6	141	\\xfeea29ff7745d0cbaf00b3fab5d82a9e9d172227378ca86b93c618fe286387e6	{"block": {"hash": "0xfacba8827d937891d382a254270147631c8ca9d967fb642f7ab237946cc2c7c6", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8d", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x690ec9", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a679f5", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xfeea29ff7745d0cbaf00b3fab5d82a9e9d172227378ca86b93c618fe286387e6", "sealFields": ["0x8420377df1", "0xb84112e39d2e9ad0615a14334ab49a9896a6ef9d6ca65df5d2de96cf852caa74d1775a65bc4671b35bc50622ba9ef4a75b8730be96534aed014ca14759a1656c733600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x8cffffffffffffffffffffffffdfca8182", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xfeea29ff7745d0cbaf00b3fab5d82a9e9d172227378ca86b93c618fe286387e6	140	\\xeb65848dc76fc886e24845fb4b51b3f8398d0473f28bf4bc2826aaf9dadb533c	{"block": {"hash": "0xfeea29ff7745d0cbaf00b3fab5d82a9e9d172227378ca86b93c618fe286387e6", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8c", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x68f48d", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a679d0", "difficulty": "0xfffffffffffffffffffffffffffffe0d", "parentHash": "0xeb65848dc76fc886e24845fb4b51b3f8398d0473f28bf4bc2826aaf9dadb533c", "sealFields": ["0x8420377df0", "0xb8413e8a1400b4a4661fbe45d5f0650331a71d34855ee34e8f1a74cba769c99825fa4a128dc45af60cb8801e08abb34ebeb80dc471a1c99aebb40b3769f44225254300"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x8bffffffffffffffffffffffffdfca8184", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xeb65848dc76fc886e24845fb4b51b3f8398d0473f28bf4bc2826aaf9dadb533c	139	\\x777db114ff2b553e1fff9d8ff777a07c42ba669b4ee97dffbd8f267483df223d	{"block": {"hash": "0xeb65848dc76fc886e24845fb4b51b3f8398d0473f28bf4bc2826aaf9dadb533c", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8b", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x68da58", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a673fa", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x777db114ff2b553e1fff9d8ff777a07c42ba669b4ee97dffbd8f267483df223d", "sealFields": ["0x8420377bfe", "0xb841cffdfa9ffbd990053e70ca7fca643584e90d7e44b3f8e6776f0afefd15c1d3483eef9f0ddd2457e354b1ee1fd098d291ea5fec0d84d04ba03a6fe474c3fd369701"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x8affffffffffffffffffffffffdfca8377", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x777db114ff2b553e1fff9d8ff777a07c42ba669b4ee97dffbd8f267483df223d	138	\\x32a82c945903a4c35e4c60a885ae20312f43d06a063a27cb91715d8137f11dc4	{"block": {"hash": "0x777db114ff2b553e1fff9d8ff777a07c42ba669b4ee97dffbd8f267483df223d", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8a", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x68c029", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a673f7", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x32a82c945903a4c35e4c60a885ae20312f43d06a063a27cb91715d8137f11dc4", "sealFields": ["0x8420377bfd", "0xb841550ba7fcbe32347d259d09a0751d06cb0f22a94a80b8515569e325009d1fd9dd28c54f76f4dfb747e7051e37f56480273e0446fa864237db945c9b7859787ca300"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x89ffffffffffffffffffffffffdfca8379", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x89285670247a7026d03bc310ab6c0928b7d9852800da3143e36bd77939f5bc85	124	\\x9c881f08a4fc010825b703c758f7f864065aa3cc84cacf64e3f51fb431fffc71	{"block": {"hash": "0x89285670247a7026d03bc310ab6c0928b7d9852800da3143e36bd77939f5bc85", "size": "0x2194", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7c", "uncles": [], "gasUsed": "0x183d55", "mixHash": null, "gasLimit": "0x67544b", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xd9210d6089c50c57d8b4dd0826f08c615c5c9a86d94e8c44d8d902d6b02882ed", "timestamp": "0x60a6847a", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x9c881f08a4fc010825b703c758f7f864065aa3cc84cacf64e3f51fb431fffc71", "sealFields": ["0x842037817e", "0xb841adad9476427130c942288162f43c0eb1fe5a39f71853e718f086e37671ca16ec16a22cc59626fc827b3977199e19fb031797a540600b2f6830966a642fb921a301"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x0d95abf5043f8a17dc1cdb136d0df5f211746309d29ab3d8915ac2bb1b5e017a", "transactions": [{"to": null, "gas": "0x307aaa", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xe7c5de4fd8313746eaa52dfbb519154d41ef58d9a8c9bcee48778dc1b25e7e8d", "input": "0x60806040526006805460a060020a60ff02191690553480156200002157600080fd5b5060405162001e2e38038062001e2e83398101604090815281516020808401519284015160608501519285018051909594909401939092918591859185918491849184916200007691600091860190620002d0565b5081516200008c906001906020850190620002d0565b506002805460ff90921660ff19909216919091179055505060068054600160a060020a03191633179055505050801515620000c657600080fd5b60405180807f454950373132446f6d61696e28737472696e67206e616d652c737472696e672081526020017f76657273696f6e2c75696e7432353620636861696e49642c616464726573732081526020017f766572696679696e67436f6e747261637429000000000000000000000000000081525060520190506040518091039020846040518082805190602001908083835b602083106200017a5780518252601f19909201916020918201910162000159565b51815160209384036101000a600019018019909216911617905260408051929094018290038220828501855260018084527f3100000000000000000000000000000000000000000000000000000000000000928401928352945190965091945090928392508083835b60208310620002045780518252601f199092019160209182019101620001e3565b51815160209384036101000a6000190180199092169116179052604080519290940182900382208282019890985281840196909652606081019690965250608085018690523060a0808701919091528151808703909101815260c09095019081905284519093849350850191508083835b60208310620002965780518252601f19909201916020918201910162000275565b5181516020939093036101000a60001901801990911692169190911790526040519201829003909120600855506200037595505050505050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106200031357805160ff191683800117855562000343565b8280016001018555821562000343579182015b828111156200034357825182559160200191906001019062000326565b506200035192915062000355565b5090565b6200037291905b808211156200035157600081556001016200035c565b90565b611aa980620003856000396000f30060806040526004361061019d5763ffffffff60e060020a60003504166305d2035b81146101a257806306fdde03146101cb578063095ea7b3146102555780630b26cf661461027957806318160ddd1461029c57806323b872dd146102c357806330adf81f146102ed578063313ce567146103025780633644e5151461032d57806339509351146103425780634000aea01461036657806340c10f191461039757806342966c68146103bb57806354fd4d50146103d357806366188463146103e857806369ffa08a1461040c57806370a0823114610433578063715018a614610454578063726600ce146104695780637d64bcb41461048a5780637ecebe001461049f578063859ba28c146104c05780638da5cb5b146105015780638fcbaf0c1461053257806395d89b4114610570578063a457c2d714610585578063a9059cbb146105a9578063b753a98c146105cd578063bb35783b146105f1578063cd5965831461061b578063d73dd62314610630578063dd62ed3e14610654578063f2d5d56b1461067b578063f2fde38b1461069f578063ff9e884d146106c0575b600080fd5b3480156101ae57600080fd5b506101b76106e7565b604080519115158252519081900360200190f35b3480156101d757600080fd5b506101e0610708565b6040805160208082528351818301528351919283929083019185019080838360005b8381101561021a578181015183820152602001610202565b50505050905090810190601f1680156102475780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34801561026157600080fd5b506101b7600160a060020a0360043516602435610796565b34801561028557600080fd5b5061029a600160a060020a03600435166107d9565b005b3480156102a857600080fd5b506102b1610833565b60408051918252519081900360200190f35b3480156102cf57600080fd5b506101b7600160a060020a0360043581169060243516604435610839565b3480156102f957600080fd5b506102b1610a08565b34801561030e57600080fd5b50610317610a2c565b6040805160ff9092168252519081900360200190f35b34801561033957600080fd5b506102b1610a35565b34801561034e57600080fd5b506101b7600160a060020a0360043516602435610a3b565b34801561037257600080fd5b506101b760048035600160a060020a0316906024803591604435918201910135610aa1565b3480156103a357600080fd5b506101b7600160a060020a0360043516602435610bb2565b3480156103c757600080fd5b5061029a600435610cbd565b3480156103df57600080fd5b506101e0610cca565b3480156103f457600080fd5b506101b7600160a060020a0360043516602435610d01565b34801561041857600080fd5b5061029a600160a060020a0360043581169060243516610dde565b34801561043f57600080fd5b506102b1600160a060020a0360043516610e03565b34801561046057600080fd5b5061029a610e1e565b34801561047557600080fd5b506101b7600160a060020a0360043516610e35565b34801561049657600080fd5b506101b7610e49565b3480156104ab57600080fd5b506102b1600160a060020a0360043516610e50565b3480156104cc57600080fd5b506104d5610e62565b6040805167ffffffffffffffff9485168152928416602084015292168183015290519081900360600190f35b34801561050d57600080fd5b50610516610e6d565b60408051600160a060020a039092168252519081900360200190f35b34801561053e57600080fd5b5061029a600160a060020a0360043581169060243516604435606435608435151560ff60a4351660c43560e435610e7c565b34801561057c57600080fd5b506101e06111d0565b34801561059157600080fd5b506101b7600160a060020a036004351660243561122a565b3480156105b557600080fd5b506101b7600160a060020a036004351660243561123d565b3480156105d957600080fd5b5061029a600160a060020a0360043516602435611268565b3480156105fd57600080fd5b5061029a600160a060020a0360043581169060243516604435611278565b34801561062757600080fd5b50610516611289565b34801561063c57600080fd5b506101b7600160a060020a0360043516602435611298565b34801561066057600080fd5b506102b1600160a060020a036004358116906024351661131f565b34801561068757600080fd5b5061029a600160a060020a036004351660243561134a565b3480156106ab57600080fd5b5061029a600160a060020a0360043516611355565b3480156106cc57600080fd5b506102b1600160a060020a0360043581169060243516611375565b60065474010000000000000000000000000000000000000000900460ff1681565b6000805460408051602060026001851615610100026000190190941693909304601f8101849004840282018401909252818152929183018282801561078e5780601f106107635761010080835404028352916020019161078e565b820191906000526020600020905b81548152906001019060200180831161077157829003601f168201915b505050505081565b60006107a28383611392565b90506000198214156107d357336000908152600a60209081526040808320600160a060020a03871684529091528120555b92915050565b600654600160a060020a031633146107f057600080fd5b6107f9816113e6565b151561080457600080fd5b6007805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b60045490565b600080600160a060020a038516151561085157600080fd5b600160a060020a038416151561086657600080fd5b600160a060020a03851660009081526003602052604090205461088f908463ffffffff6113ee16565b600160a060020a0380871660009081526003602052604080822093909355908616815220546108c4908463ffffffff61140016565b600160a060020a038086166000818152600360209081526040918290209490945580518781529051919392891692600080516020611a3e83398151915292918290030190a3600160a060020a03851633146109f257610923853361131f565b9050600019811461098d5761093e818463ffffffff6113ee16565b600160a060020a038616600081815260056020908152604080832033808552908352928190208590558051948552519193600080516020611a5e833981519152929081900390910190a36109f2565b600160a060020a0385166000908152600a6020908152604080832033845290915290205415806109e757506109c061140d565b600160a060020a0386166000908152600a6020908152604080832033845290915290205410155b15156109f257600080fd5b6109fd858585611411565b506001949350505050565b7fea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb81565b60025460ff1681565b60085481565b6000610a478383611448565b336000908152600560209081526040808320600160a060020a038816845290915290205490915060001914156107d357336000908152600a60209081526040808320600160a060020a038716845290915281205592915050565b600084600160a060020a03811615801590610ac55750600160a060020a0381163014155b1515610ad057600080fd5b610ada8686611454565b1515610ae557600080fd5b85600160a060020a031633600160a060020a03167fe19260aff97b920c7df27010903aeb9c8d2be5d310a2c67824cf3f15396e4c16878787604051808481526020018060200182810382528484828181526020019250808284376040519201829003965090945050505050a3610b5a866113e6565b15610ba657610b9b33878787878080601f01602080910402602001604051908101604052809392919081815260200183838082843750611460945050505050565b1515610ba657600080fd5b50600195945050505050565b600654600090600160a060020a03163314610bcc57600080fd5b60065474010000000000000000000000000000000000000000900460ff1615610bf457600080fd5b600454610c07908363ffffffff61140016565b600455600160a060020a038316600090815260036020526040902054610c33908363ffffffff61140016565b600160a060020a038416600081815260036020908152604091829020939093558051858152905191927f0f6798a560793a54c3bcfe86a93cde1e73087d944c0ea20544137d412139688592918290030190a2604080518381529051600160a060020a03851691600091600080516020611a3e8339815191529181900360200190a350600192915050565b610cc733826115dd565b50565b60408051808201909152600181527f3100000000000000000000000000000000000000000000000000000000000000602082015281565b336000908152600560209081526040808320600160a060020a0386168452909152812054808310610d5557336000908152600560209081526040808320600160a060020a0388168452909152812055610d8a565b610d65818463ffffffff6113ee16565b336000908152600560209081526040808320600160a060020a03891684529091529020555b336000818152600560209081526040808320600160a060020a038916808552908352928190205481519081529051929392600080516020611a5e833981519152929181900390910190a35060019392505050565b600654600160a060020a03163314610df557600080fd5b610dff82826116cc565b5050565b600160a060020a031660009081526003602052604090205490565b600654600160a060020a0316331461019d57600080fd5b600754600160a060020a0390811691161490565b6000806000fd5b60096020526000908152604090205481565b600260046000909192565b600654600160a060020a031681565b600080600160a060020a038a161515610e9457600080fd5b600160a060020a0389161515610ea957600080fd5b861580610ebd575086610eba61140d565b11155b1515610ec857600080fd5b8460ff16601b1480610edd57508460ff16601c145b1515610ee857600080fd5b7f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0831115610f1557600080fd5b600854604080517fea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb602080830191909152600160a060020a03808f16838501528d166060830152608082018c905260a082018b905289151560c0808401919091528351808403909101815260e090920192839052815191929182918401908083835b60208310610fb65780518252601f199092019160209182019101610f97565b51815160209384036101000a6000190180199092169116179052604080519290940182900382207f190100000000000000000000000000000000000000000000000000000000000083830152602283019790975260428083019790975283518083039097018752606290910192839052855192945084935085019190508083835b602083106110565780518252601f199092019160209182019101611037565b51815160209384036101000a600019018019909216911617905260408051929094018290038220600080845283830180875282905260ff8d1684870152606084018c9052608084018b905294519098506001965060a080840196509194601f19820194509281900390910191865af11580156110d6573d6000803e3d6000fd5b50505060206040510351600160a060020a03168a600160a060020a03161415156110ff57600080fd5b600160a060020a038a166000908152600960205260409020805460018101909155881461112b57600080fd5b8561113757600061113b565b6000195b600160a060020a03808c166000908152600560209081526040808320938e16835292905220819055905085611171576000611173565b865b600160a060020a03808c166000818152600a60209081526040808320948f1680845294825291829020949094558051858152905192939192600080516020611a5e833981519152929181900390910190a350505050505050505050565b60018054604080516020600284861615610100026000190190941693909304601f8101849004840282018401909252818152929183018282801561078e5780601f106107635761010080835404028352916020019161078e565b60006112368383610d01565b9392505050565b60006112498383611454565b151561125457600080fd5b61125f338484611411565b50600192915050565b611273338383610839565b505050565b611283838383610839565b50505050565b600754600160a060020a031690565b336000908152600560209081526040808320600160a060020a03861684529091528120546112cc908363ffffffff61140016565b336000818152600560209081526040808320600160a060020a038916808552908352928190208590558051948552519193600080516020611a5e833981519152929081900390910190a350600192915050565b600160a060020a03918216600090815260056020908152604080832093909416825291909152205490565b611273823383610839565b600654600160a060020a0316331461136c57600080fd5b610cc78161170a565b600a60209081526000928352604080842090915290825290205481565b336000818152600560209081526040808320600160a060020a03871680855290835281842086905581518681529151939490939092600080516020611a5e833981519152928290030190a350600192915050565b6000903b1190565b6000828211156113fa57fe5b50900390565b818101828110156107d357fe5b4290565b61141a82610e35565b156112735760408051600081526020810190915261143d90849084908490611460565b151561127357600080fd5b60006112368383611298565b60006112368383611788565b600083600160a060020a031663a4c0ed3660e060020a028685856040516024018084600160a060020a0316600160a060020a0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b838110156114d85781810151838201526020016114c0565b50505050905090810190601f1680156115055780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529181526020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167fffffffff00000000000000000000000000000000000000000000000000000000909916989098178852518151919790965086955093509150819050838360005b8381101561159357818101518382015260200161157b565b50505050905090810190601f1680156115c05780820380516001836020036101000a031916815260200191505b509150506000604051808303816000865af1979650505050505050565b600160a060020a03821660009081526003602052604090205481111561160257600080fd5b600160a060020a03821660009081526003602052604090205461162b908263ffffffff6113ee16565b600160a060020a038316600090815260036020526040902055600454611657908263ffffffff6113ee16565b600455604080518281529051600160a060020a038416917fcc16f5dbb4873280815c1ee09dbd06736cffcc184412cf7a71a0fdb75d397ca5919081900360200190a2604080518281529051600091600160a060020a03851691600080516020611a3e8339815191529181900360200190a35050565b80600160a060020a03811615156116e257600080fd5b600160a060020a0383161515611700576116fb82611857565b611273565b6112738383611863565b600160a060020a038116151561171f57600080fd5b600654604051600160a060020a038084169216907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a36006805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b336000908152600360205260408120548211156117a457600080fd5b600160a060020a03831615156117b957600080fd5b336000908152600360205260409020546117d9908363ffffffff6113ee16565b3360009081526003602052604080822092909255600160a060020a0385168152205461180b908363ffffffff61140016565b600160a060020a038416600081815260036020908152604091829020939093558051858152905191923392600080516020611a3e8339815191529281900390910190a350600192915050565b3031610dff8282611910565b604080517f70a0823100000000000000000000000000000000000000000000000000000000815230600482015290518391600091600160a060020a038416916370a0823191602480830192602092919082900301818787803b1580156118c857600080fd5b505af11580156118dc573d6000803e3d6000fd5b505050506040513d60208110156118f257600080fd5b50519050611283600160a060020a038516848363ffffffff61197816565b604051600160a060020a0383169082156108fc029083906000818181858888f193505050501515610dff578082611945611a0d565b600160a060020a039091168152604051908190036020019082f080158015611971573d6000803e3d6000fd5b5050505050565b82600160a060020a031663a9059cbb83836040518363ffffffff1660e060020a0281526004018083600160a060020a0316600160a060020a0316815260200182815260200192505050600060405180830381600087803b1580156119db57600080fd5b505af11580156119ef573d6000803e3d6000fd5b505050503d156112735760206000803e600051151561127357600080fd5b604051602180611a1d833901905600608060405260405160208060218339810160405251600160a060020a038116ff00ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925a165627a7a723058202868d22f1d55ff8de23e437047d596d9719a8126999958de569af1ac09beb8460029000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000232500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "nonce": "0x1b", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x89285670247a7026d03bc310ab6c0928b7d9852800da3143e36bd77939f5bc85", "blockNumber": "0x7c", "transactionIndex": "0x0"}], "totalDifficulty": "0x7bffffffffffffffffffffffffdfca7e06", "transactionsRoot": "0x19016e58011129e38356a63d53b64748809d85b05a2e79c878e06568abcb264b"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x183d55", "blockHash": "0x89285670247a7026d03bc310ab6c0928b7d9852800da3143e36bd77939f5bc85", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x7c", "contractAddress": "0xf16f8cebea74106664032e6b2963b81743484306", "transactionHash": "0xe7c5de4fd8313746eaa52dfbb519154d41ef58d9a8c9bcee48778dc1b25e7e8d", "transactionIndex": "0x0", "cumulativeGasUsed": "0x183d55"}]}
\\x9c881f08a4fc010825b703c758f7f864065aa3cc84cacf64e3f51fb431fffc71	123	\\x4ad9382fb10592f66ba755f722ebc12dbe0e2fe2bb409769b16735930433c223	{"block": {"hash": "0x9c881f08a4fc010825b703c758f7f864065aa3cc84cacf64e3f51fb431fffc71", "size": "0x7bc", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7b", "uncles": [], "gasUsed": "0x52aca", "mixHash": null, "gasLimit": "0x673a7e", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x53c2badc199ec3def2a3ac4ccf876dc4470ba8e8b4ea147335144e4fb23b2ab6", "timestamp": "0x60a68477", "difficulty": "0xffffffffffffffffffffffffffffffeb", "parentHash": "0x4ad9382fb10592f66ba755f722ebc12dbe0e2fe2bb409769b16735930433c223", "sealFields": ["0x842037817d", "0xb841357a30b908842e01b72e40eb86d4e35165f692698d6673f84d6f447680254d7a60e685f8383e3be3360e9774d48cf105e285988ac381a37330f3503fdb8e430100"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0xe8f1297a9e607c18adad156d9527c574f85065ac02912f86c365c570774543d0", "transactions": [{"to": null, "gas": "0xa5594", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x20650772c8f39ec8aad2c0ea594592db6502cf3bef862c8fea68f1792a59c0fd", "input": "0x608060405234801561001057600080fd5b5061001a3361001f565b610041565b600680546001600160a01b0319166001600160a01b0392909216919091179055565b6104c6806100506000396000f3fe6080604052600436106100555760003560e01c80633ad06d161461009e57806354fd4d50146100d95780635c60da1b146101005780636fde820214610131578063a9c45fcb14610146578063f1739cae146101cb575b600061005f6101fe565b90506001600160a01b03811661007457600080fd5b60405136600082376000803683855af43d82016040523d6000833e80801561009a573d83f35b3d83fd5b3480156100aa57600080fd5b506100d7600480360360408110156100c157600080fd5b50803590602001356001600160a01b031661020d565b005b3480156100e557600080fd5b506100ee610240565b60408051918252519081900360200190f35b34801561010c57600080fd5b506101156101fe565b604080516001600160a01b039092168252519081900360200190f35b34801561013d57600080fd5b50610115610246565b6100d76004803603606081101561015c57600080fd5b8135916001600160a01b036020820135169181019060608101604082013564010000000081111561018c57600080fd5b82018360208201111561019e57600080fd5b803590602001918460018302840111640100000000831117156101c057600080fd5b509092509050610255565b3480156101d757600080fd5b506100d7600480360360208110156101ee57600080fd5b50356001600160a01b03166102fe565b600061020861038d565b905090565b610215610246565b6001600160a01b0316336001600160a01b03161461023257600080fd5b61023c828261039c565b5050565b60075490565b6006546001600160a01b031690565b61025d610246565b6001600160a01b0316336001600160a01b03161461027a57600080fd5b610284848461020d565b6000306001600160a01b0316348484604051808383808284376040519201945060009350909150508083038185875af1925050503d80600081146102e4576040519150601f19603f3d011682016040523d82523d6000602084013e6102e9565b606091505b50509050806102f757600080fd5b5050505050565b610306610246565b6001600160a01b0316336001600160a01b03161461032357600080fd5b6001600160a01b03811661033657600080fd5b7f5a3e66efaa1e445ebd894728a69d6959842ea1e97bd79b892797106e270efcd961035f610246565b604080516001600160a01b03928316815291841660208301528051918290030190a161038a81610432565b50565b6008546001600160a01b031690565b6008546001600160a01b03828116911614156103b757600080fd5b6103c081610454565b6103c957600080fd5b60075482116103d757600080fd5b6007829055600880546001600160a01b0383166001600160a01b031990911681179091556040805184815290517f4289d6195cf3c2d2174adf98d0e19d4d2d08887995b99cb7b100e7ffe795820e9181900360200190a25050565b600680546001600160a01b0319166001600160a01b0392909216919091179055565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061048857508115155b94935050505056fea2646970667358221220d9973dddb90f377ca5b26b72075526ad86c08bc9ef57e825e4a7a45e638fa23064736f6c63430007050033", "nonce": "0x1a", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x9c881f08a4fc010825b703c758f7f864065aa3cc84cacf64e3f51fb431fffc71", "blockNumber": "0x7b", "transactionIndex": "0x0"}], "totalDifficulty": "0x7affffffffffffffffffffffffdfca7e08", "transactionsRoot": "0x55e22859d657510ba264528f40abf29f09ea1515130bfb8c859a8e66f234d54e"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x52aca", "blockHash": "0x9c881f08a4fc010825b703c758f7f864065aa3cc84cacf64e3f51fb431fffc71", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x7b", "contractAddress": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "transactionHash": "0x20650772c8f39ec8aad2c0ea594592db6502cf3bef862c8fea68f1792a59c0fd", "transactionIndex": "0x0", "cumulativeGasUsed": "0x52aca"}]}
\\x32a82c945903a4c35e4c60a885ae20312f43d06a063a27cb91715d8137f11dc4	137	\\xbb3c49607246c91e53339f3ad5eed36043d5545ae203c4128416a69c6de0fbcd	{"block": {"hash": "0x32a82c945903a4c35e4c60a885ae20312f43d06a063a27cb91715d8137f11dc4", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x89", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x68a601", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a673f4", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xbb3c49607246c91e53339f3ad5eed36043d5545ae203c4128416a69c6de0fbcd", "sealFields": ["0x8420377bfc", "0xb8412fcc0df11baf1aca72df78b4c14a8d54362240215eef5cfb7773f9e4ec9f62920b0e605077e4c7a1d693a757911ac453a9b1bd1f0ff570036f58cacee24b59d100"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x88ffffffffffffffffffffffffdfca837b", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xbb3c49607246c91e53339f3ad5eed36043d5545ae203c4128416a69c6de0fbcd	136	\\x1f624bc35df568b83a7d73e7ebf598f69a009f3971acc433e94a1e35c7aa6456	{"block": {"hash": "0xbb3c49607246c91e53339f3ad5eed36043d5545ae203c4128416a69c6de0fbcd", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x88", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x688be0", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a673f1", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x1f624bc35df568b83a7d73e7ebf598f69a009f3971acc433e94a1e35c7aa6456", "sealFields": ["0x8420377bfb", "0xb8418a4e5dccf5d39ca70ee7bbec8dd1e35559026d0cdce851dde7a58571ed8628ff061ecb78cfa6efaa47290d308834331cd6a08eea41a7f764605d6b10f65dd49901"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x87ffffffffffffffffffffffffdfca837d", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x1f624bc35df568b83a7d73e7ebf598f69a009f3971acc433e94a1e35c7aa6456	135	\\x327b3777967d1efb74653cef9af597bde8812c0c1bb9e7811d7558224183d40f	{"block": {"hash": "0x1f624bc35df568b83a7d73e7ebf598f69a009f3971acc433e94a1e35c7aa6456", "size": "0x10e6", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x87", "uncles": [], "gasUsed": "0xd2c19", "mixHash": null, "gasLimit": "0x6871c5", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a673eb", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x327b3777967d1efb74653cef9af597bde8812c0c1bb9e7811d7558224183d40f", "sealFields": ["0x8420377bf9", "0xb841e6e900f64e52004ea52bda695753c8e44f4cb8726bc9e525d33d85a05f54bd646683ac2a1cc66deb4f5c6aba1f4f03492f661e6d5b094d74bd884947807454f600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x07c8c175b5e002b797aa81f397cecaaed5537a9d4d5918b5f017543c38d4d6c2", "transactions": [{"to": null, "gas": "0x5b8d80", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x9c40ecf257e0dde6129d51a8657269186545ea11877666e4389f2a5cffb6e0fd", "input": "0x608060405234801561001057600080fd5b50604051610dff380380610dff8339818101604052604081101561003357600080fd5b508051602090910151600080546001600160a01b03199081163317909155600680546001600160a01b0394851690831617905560028054939092169216919091179055610d7a806100856000396000f3fe6080604052600436106100f75760003560e01c8063afc6224b1161008a578063f0ef0b0611610059578063f0ef0b0614610322578063f2fde38b1461034c578063f7c1329e1461037f578063fc0c546a14610394576100fe565b8063afc6224b146102bc578063cfeef807146102e3578063e22ab5ae146102f8578063e30c39781461030d576100fe565b806337dd8b05116100c657806337dd8b051461023c5780634e51a863146102685780634e71e0c8146102925780638da5cb5b146102a7576100fe565b80631062b39a1461010357806317c2a98c14610134578063187ac4cb14610167578063325ff66f1461017c576100fe565b366100fe57005b600080fd5b34801561010f57600080fd5b506101186103a9565b604080516001600160a01b039092168252519081900360200190f35b34801561014057600080fd5b506101186004803603602081101561015757600080fd5b50356001600160a01b031661048d565b34801561017357600080fd5b506101186104b2565b34801561018857600080fd5b506101186004803603604081101561019f57600080fd5b6001600160a01b0382351691908101906040810160208201356401000000008111156101ca57600080fd5b8201836020820111156101dc57600080fd5b803590602001918460208302840111640100000000831117156101fe57600080fd5b9190808060200260200160405190810160405280939291908181526020018383602002808284376000920191909152509295506104c1945050505050565b34801561024857600080fd5b506102666004803603602081101561025f57600080fd5b50356107bd565b005b34801561027457600080fd5b506102666004803603602081101561028b57600080fd5b5035610853565b34801561029e57600080fd5b506102666108e8565b3480156102b357600080fd5b5061011861099e565b3480156102c857600080fd5b506102d16109ad565b60408051918252519081900360200190f35b3480156102ef57600080fd5b506101186109b3565b34801561030457600080fd5b506102d16109c2565b34801561031957600080fd5b506101186109c8565b34801561032e57600080fd5b506102666004803603602081101561034557600080fd5b50356109d7565b34801561035857600080fd5b506102666004803603602081101561036f57600080fd5b50356001600160a01b0316610a6c565b34801561038b57600080fd5b506102d1610ad9565b3480156103a057600080fd5b50610118610adf565b6006546040805163533426d160e01b815290516000926001600160a01b03169163533426d1916004808301926020929190829003018186803b1580156103ee57600080fd5b505afa158015610402573d6000803e3d6000fd5b505050506040513d602081101561041857600080fd5b50516040805163cd59658360e01b815290516001600160a01b039092169163cd59658391600480820192602092909190829003018186803b15801561045c57600080fd5b505afa158015610470573d6000803e3d6000fd5b505050506040513d602081101561048657600080fd5b5051905090565b6002546000906104ac906001600160a01b039081169030908516610b24565b92915050565b6006546001600160a01b031681565b60006104cb6103a9565b6001600160a01b0316336001600160a01b03161461051b576040805162461bcd60e51b815260206004820152600860248201526737b7363cafa0a6a160c11b604482015290519081900360640190fd5b60006105256103a9565b6001600160a01b031663d67bdd256040518163ffffffff1660e01b815260040160206040518083038186803b15801561055d57600080fd5b505afa158015610571573d6000803e3d6000fd5b505050506040513d602081101561058757600080fd5b50516006546005546040516001600160a01b0388811660248301908152938116604483018190529085166084830181905260a4830184905260a060648401908152895160c4850152895196975090956060958b9593948b948a949093909160e401906020878101910280838360005b8381101561060e5781810151838201526020016105f6565b50506040805193909501838103601f1901845290945250602081018051634d6b976f60e01b6001600160e01b03909116179052600254909a5060009950610672985061066b97506001600160a01b03169550610b90945050505050565b8385610be2565b600254604080516001600160a01b0392831681529051929350818a1692828516928816917f90d0a5d098b9a181ff8ddc866f840cc210e5b91eaf27bc267d5822a0deafad25919081900360200190a4600354158015906106d457506003544710155b1561073a576003546040516001600160a01b0383169180156108fc02916000818181858888f193505050501561073a5760035460408051918252517f517165f169759cdb94227d1c50f4f47895eb099a7f04a780f519bf1739face6f9181900360200190a15b6004541580159061074d57506004544710155b156107b3576004546040516001600160a01b0389169180156108fc02916000818181858888f19350505050156107b35760045460408051918252517f69e30c0bf438d0d3e0afb7f68d57ef394a0d5e8712f82fa00aa599e42574bc2a9181900360200190a15b9695505050505050565b6000546001600160a01b03163314610808576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b60055481141561081757610850565b60058190556040805182815290517f7a78bdfbfb2e909f35c05c77e80038cfd0a22c704748eba8b1d20aab76cd5d9c9181900360200190a15b50565b6000546001600160a01b0316331461089e576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b6003548114156108ad57610850565b60038190556040805182815290517fa02ce31a8a8adcdc2e2811a0c7f5d1eb1aa920ca9fdfaeaebfe3a2163e69a6549181900360200190a150565b6001546001600160a01b0316331461093a576040805162461bcd60e51b815260206004820152601060248201526f37b7363ca832b73234b733a7bbb732b960811b604482015290519081900360640190fd5b600154600080546040516001600160a01b0393841693909116917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e091a360018054600080546001600160a01b03199081166001600160a01b03841617909155169055565b6000546001600160a01b031681565b60045481565b6002546001600160a01b031681565b60055481565b6001546001600160a01b031681565b6000546001600160a01b03163314610a22576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600454811415610a3157610850565b60048190556040805182815290517fe08bf32e9c0e823a76d0088908afba678014c513e2311bba64fc72f38ae809709181900360200190a150565b6000546001600160a01b03163314610ab7576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600180546001600160a01b0319166001600160a01b0392909216919091179055565b60035481565b6006546040805163836c081d60e01b815290516000926001600160a01b03169163836c081d916004808301926020929190829003018186803b15801561045c57600080fd5b600080610b3085610b90565b8051602091820120604080516001600160f81b0319818501526bffffffffffffffffffffffff19606089901b1660218201526035810187905260558082019390935281518082039093018352607501905280519101209150509392505050565b604080516057810190915260378152733d602d80600a3d3981f3363d3d373d3d3d363d7360601b602082015260609190911b60348201526e5af43d82803e903d91602b57fd5bf360881b604882015290565b825160009082816020870184f591506001600160a01b038216610c43576040805162461bcd60e51b8152602060048201526014602482015273195c9c9bdc97d85b1c9958591e50dc99585d195960621b604482015290519081900360640190fd5b835115610d3c576000826001600160a01b0316856040518082805190602001908083835b60208310610c865780518252601f199092019160209182019101610c67565b6001836020036101000a0380198251168184511680821785525050505050509050019150506000604051808303816000865af19150503d8060008114610ce8576040519150601f19603f3d011682016040523d82523d6000602084013e610ced565b606091505b5050905080610d3a576040805162461bcd60e51b815260206004820152601460248201527332b93937b92fb4b734ba34b0b634bd30ba34b7b760611b604482015290519081900360640190fd5b505b50939250505056fea2646970667358221220e10751fb6e1f2fd0035d38326971ac2be99e8073732656a09e684385d393c27864736f6c63430006060033000000000000000000000000ba4b4c7facd055990aa3eabd53db0a87a65b8e0b00000000000000000000000035f1b900e63579ec0bd3904941de7e8fe5e7f3b4", "nonce": "0x26", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x1f624bc35df568b83a7d73e7ebf598f69a009f3971acc433e94a1e35c7aa6456", "blockNumber": "0x87", "transactionIndex": "0x0"}], "totalDifficulty": "0x86ffffffffffffffffffffffffdfca8380", "transactionsRoot": "0xfd7f0fc07fa16db7b6854d3f850cd46ad7b55b2ef6b8413d20e95f17e33de40c"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0xd2c19", "blockHash": "0x1f624bc35df568b83a7d73e7ebf598f69a009f3971acc433e94a1e35c7aa6456", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x87", "contractAddress": "0x031fdeaa6da80fdbcd75f14ba8887c535f41eb7e", "transactionHash": "0x9c40ecf257e0dde6129d51a8657269186545ea11877666e4389f2a5cffb6e0fd", "transactionIndex": "0x0", "cumulativeGasUsed": "0xd2c19"}]}
\\x327b3777967d1efb74653cef9af597bde8812c0c1bb9e7811d7558224183d40f	134	\\x25138b16307b03f37999b82f2e76f93de8a3a5f3d145c1d0495b35f84068276d	{"block": {"hash": "0x327b3777967d1efb74653cef9af597bde8812c0c1bb9e7811d7558224183d40f", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x86", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6857b1", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xa57992346ec5c4ea217258c4cc79d9fbf3fb5ba2f2a9dc979d96c32e572106ff", "timestamp": "0x60a673e8", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x25138b16307b03f37999b82f2e76f93de8a3a5f3d145c1d0495b35f84068276d", "sealFields": ["0x8420377bf8", "0xb8417ff8d28e94399527c38ee860c045cd842720c8c898f8d4e73b1bb303b3ccdcf011828fb861df9fc7454d405e3673d991499d965722d72895602810ae1473f94a00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x85ffffffffffffffffffffffffdfca8382", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x25138b16307b03f37999b82f2e76f93de8a3a5f3d145c1d0495b35f84068276d	133	\\x6e6905216c5f00e0a877deeb01852a3237630b8939ee28f65f4f6e2b70d825cb	{"block": {"hash": "0x25138b16307b03f37999b82f2e76f93de8a3a5f3d145c1d0495b35f84068276d", "size": "0xd48", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x85", "uncles": [], "gasUsed": "0x9fab8", "mixHash": null, "gasLimit": "0x683da3", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xa57992346ec5c4ea217258c4cc79d9fbf3fb5ba2f2a9dc979d96c32e572106ff", "timestamp": "0x60a673e5", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x6e6905216c5f00e0a877deeb01852a3237630b8939ee28f65f4f6e2b70d825cb", "sealFields": ["0x8420377bf7", "0xb8416bc78eced6026db38d2ad1247cfe0cf70be91b6e1764b278358740c648ee9b062397395ed11110b9e7c7e078ca2d8862e9d7362abe42580e04049dc46fb07ec400"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x8c4ba35006ac755a346708184f601baa415c1c65795b9ef6a16901eeab980ec9", "transactions": [{"to": null, "gas": "0x5b8d80", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xa69081025431ff1d2f2972226184b9956de54e123014370e2780811bbdff00d8", "input": "0x608060405234801561001057600080fd5b50604051610a41380380610a418339818101604052606081101561003357600080fd5b5080516020820151604090920151600080546001600160a01b03199081163317909155600280546001600160a01b0394851690831617905560038054948416948216949094179093556004805492909116919092161790556109a78061009a6000396000f3fe608060405234801561001057600080fd5b50600436106100b45760003560e01c80638da5cb5b116100715780638da5cb5b1461016157806394b918de14610169578063b31c710a14610186578063e30c39781461018e578063e39f456514610196578063f2fde38b146101bc576100b4565b80634e71e0c8146100b957806351cff8d9146100c3578063533426d1146100e95780635b7a50f71461010d578063834bc59414610133578063836c081d14610159575b600080fd5b6100c16101e2565b005b6100c1600480360360208110156100d957600080fd5b50356001600160a01b0316610298565b6100f1610476565b604080516001600160a01b039092168252519081900360200190f35b6100c16004803603602081101561012357600080fd5b50356001600160a01b0316610485565b6100c16004803603602081101561014957600080fd5b50356001600160a01b031661052d565b6100f16105d5565b6100f16105e4565b6100c16004803603602081101561017f57600080fd5b50356105f3565b6100f161083e565b6100f161084d565b6100c1600480360360208110156101ac57600080fd5b50356001600160a01b031661085c565b6100c1600480360360208110156101d257600080fd5b50356001600160a01b0316610904565b6001546001600160a01b03163314610234576040805162461bcd60e51b815260206004820152601060248201526f37b7363ca832b73234b733a7bbb732b960811b604482015290519081900360640190fd5b600154600080546040516001600160a01b0393841693909116917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e091a360018054600080546001600160a01b03199081166001600160a01b03841617909155169055565b6000546001600160a01b031633146102e3576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b604080516370a0823160e01b8152306004820152905182916000916001600160a01b038416916370a08231916024808301926020929190829003018186803b15801561032e57600080fd5b505afa158015610342573d6000803e3d6000fd5b505050506040513d602081101561035857600080fd5b5051905080610368575050610473565b600080546040805163a9059cbb60e01b81526001600160a01b0392831660048201526024810185905290519185169263a9059cbb926044808401936020939083900390910190829087803b1580156103bf57600080fd5b505af11580156103d3573d6000803e3d6000fd5b505050506040513d60208110156103e957600080fd5b505161042e576040805162461bcd60e51b815260206004820152600f60248201526e1d1c985b9cd9995c97d9985a5b1959608a1b604482015290519081900360640190fd5b6000546040805183815290516001600160a01b03909216917f7fcf532c15f0a6db0bd6d0e038bea71d30d808c7d98cb3bf7268a95bf5081b659181900360200190a250505b50565b6004546001600160a01b031681565b6000546001600160a01b031633146104d0576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b6003546040516001600160a01b03918216918316907f1aa7dd3c81658118943ae26982827c3fe431efc748245477507938313ff1092690600090a3600380546001600160a01b0319166001600160a01b0392909216919091179055565b6000546001600160a01b03163314610578576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b6002546040516001600160a01b03918216918316907f77f72df9021d6c85a85c9539e22c507f137341a44dc236249d2ac2ec94332a6590600090a3600280546001600160a01b0319166001600160a01b0392909216919091179055565b6002546001600160a01b031681565b6000546001600160a01b031681565b6003546001600160a01b03161580159061061757506002546001600160a01b031615155b610659576040805162461bcd60e51b815260206004820152600e60248201526d1d1bdad95b9cd7db9bdd17dcd95d60921b604482015290519081900360640190fd5b600354600254604080516323b872dd60e01b81523360048201523060248201526044810185905290516001600160a01b03938416939092169183916323b872dd9160648083019260209291908290030181600087803b1580156106bb57600080fd5b505af11580156106cf573d6000803e3d6000fd5b505050506040513d60208110156106e557600080fd5b505161072e576040805162461bcd60e51b81526020600482015260136024820152721d1c985b9cd9995c919c9bdb57d9985a5b1959606a1b604482015290519081900360640190fd5b6040805163a9059cbb60e01b81523360048201526024810185905290516001600160a01b0383169163a9059cbb9160448083019260209291908290030181600087803b15801561077d57600080fd5b505af1158015610791573d6000803e3d6000fd5b505050506040513d60208110156107a757600080fd5b50516107ec576040805162461bcd60e51b815260206004820152600f60248201526e1d1c985b9cd9995c97d9985a5b1959608a1b604482015290519081900360640190fd5b6002546003546040805186815290516001600160a01b0393841693929092169133917fffebebfb273923089a3ed6bac0fd4686ac740307859becadeb82f998e30db614919081900360200190a4505050565b6003546001600160a01b031681565b6001546001600160a01b031681565b6000546001600160a01b031633146108a7576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b6004546040516001600160a01b03918216918316907feeaab2a31d713c6b25c64e6ea1a3b6aa9c2ef0be563ab7280ef8444b70226a2590600090a3600480546001600160a01b0319166001600160a01b0392909216919091179055565b6000546001600160a01b0316331461094f576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600180546001600160a01b0319166001600160a01b039290921691909117905556fea2646970667358221220e3065e8eb8c4a0379ec2f360441f73b5396ac8197f3a86b568adc6d1066074d464736f6c6343000606003300000000000000000000000067dda81caa260dd5a972f16fa3dae114b11505f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041b89db86be735c03a9296437e39f5fdadc4c678", "nonce": "0x25", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x25138b16307b03f37999b82f2e76f93de8a3a5f3d145c1d0495b35f84068276d", "blockNumber": "0x85", "transactionIndex": "0x0"}], "totalDifficulty": "0x84ffffffffffffffffffffffffdfca8384", "transactionsRoot": "0xceb51b8ff38e09229e10e0019fc9bbbc4990aadb63542bcbf6b068f6d7220db4"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x9fab8", "blockHash": "0x25138b16307b03f37999b82f2e76f93de8a3a5f3d145c1d0495b35f84068276d", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x85", "contractAddress": "0xba4b4c7facd055990aa3eabd53db0a87a65b8e0b", "transactionHash": "0xa69081025431ff1d2f2972226184b9956de54e123014370e2780811bbdff00d8", "transactionIndex": "0x0", "cumulativeGasUsed": "0x9fab8"}]}
\\x6e6905216c5f00e0a877deeb01852a3237630b8939ee28f65f4f6e2b70d825cb	132	\\xa20abfdffc45f74d144095e9dd9a95d5341f0802a8135536a7e8d4fbbcaa2b75	{"block": {"hash": "0x6e6905216c5f00e0a877deeb01852a3237630b8939ee28f65f4f6e2b70d825cb", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x84", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x68239c", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x43948fad6eb57478b83318a8dc0431d3c68a62829ebc50ccfa1c09dc9783e169", "timestamp": "0x60a673df", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0xa20abfdffc45f74d144095e9dd9a95d5341f0802a8135536a7e8d4fbbcaa2b75", "sealFields": ["0x8420377bf5", "0xb84157801b73181bf52e35c611040a11b417fe4542516806106209e47be7619a255b69b010abc051291636bd0a654add1bf376e323013541adb1b488801d82c2d3d501"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x83ffffffffffffffffffffffffdfca8387", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xa20abfdffc45f74d144095e9dd9a95d5341f0802a8135536a7e8d4fbbcaa2b75	131	\\x7abd152db0597fa30f0290c2b815a2e0cb211ce8d477db7d24423cd651ce0f3b	{"block": {"hash": "0xa20abfdffc45f74d144095e9dd9a95d5341f0802a8135536a7e8d4fbbcaa2b75", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x83", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x68099b", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x43948fad6eb57478b83318a8dc0431d3c68a62829ebc50ccfa1c09dc9783e169", "timestamp": "0x60a673d9", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x7abd152db0597fa30f0290c2b815a2e0cb211ce8d477db7d24423cd651ce0f3b", "sealFields": ["0x8420377bf3", "0xb841da0dd5db9f5237a48a15d7649adeafd52edb950eaf198d9ffdffc4594b88cc8f460bd5babf77159344a68b3343a76430b4c793f3c065629457e2d8e16d2a2a3b00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x82ffffffffffffffffffffffffdfca838a", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x7abd152db0597fa30f0290c2b815a2e0cb211ce8d477db7d24423cd651ce0f3b	130	\\x40c944b68adaf1a16f738bb64d3c63d344a77d95fd949a108e8a46eac882c6fe	{"block": {"hash": "0x7abd152db0597fa30f0290c2b815a2e0cb211ce8d477db7d24423cd651ce0f3b", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x82", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x67efa1", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x43948fad6eb57478b83318a8dc0431d3c68a62829ebc50ccfa1c09dc9783e169", "timestamp": "0x60a673d6", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x40c944b68adaf1a16f738bb64d3c63d344a77d95fd949a108e8a46eac882c6fe", "sealFields": ["0x8420377bf2", "0xb841a7f1554149bc6f115a1476e94ac4e0e159333ee5e8b364e46aef46730279f934098e062d7695185e121a81d0dabb31a5fdd43a8de27e41c801ce5ee88de6e7b101"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x81ffffffffffffffffffffffffdfca838c", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x40c944b68adaf1a16f738bb64d3c63d344a77d95fd949a108e8a46eac882c6fe	129	\\x403362b45a168eb941d85cb44eb24635821d3428b219e16e34dfba25389c5259	{"block": {"hash": "0x40c944b68adaf1a16f738bb64d3c63d344a77d95fd949a108e8a46eac882c6fe", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x81", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x67d5ad", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x43948fad6eb57478b83318a8dc0431d3c68a62829ebc50ccfa1c09dc9783e169", "timestamp": "0x60a673d3", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x403362b45a168eb941d85cb44eb24635821d3428b219e16e34dfba25389c5259", "sealFields": ["0x8420377bf1", "0xb84139144181786ae0a9fbbffa716b0b88a77c5770aa1c2dd3ab66e139e42608cc487b7d521f37deb263ffee816d76dc9cd7a1f31e88a63d7c4f78ffad95034a344601"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x80ffffffffffffffffffffffffdfca838e", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x403362b45a168eb941d85cb44eb24635821d3428b219e16e34dfba25389c5259	128	\\x366f8bf5fcb132e0a2eddd3bce40e9caba4afc7706ffbebfbf5e7747aecfa275	{"block": {"hash": "0x403362b45a168eb941d85cb44eb24635821d3428b219e16e34dfba25389c5259", "size": "0x3621", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x80", "uncles": [], "gasUsed": "0x2c19e0", "mixHash": null, "gasLimit": "0x67bbc0", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x43948fad6eb57478b83318a8dc0431d3c68a62829ebc50ccfa1c09dc9783e169", "timestamp": "0x60a673d0", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x366f8bf5fcb132e0a2eddd3bce40e9caba4afc7706ffbebfbf5e7747aecfa275", "sealFields": ["0x8420377bf0", "0xb8417bca1cbc1c61e342b1604e0f66d599e44aff7bf9f48de7280a4b23e3138f6c711b6d2d0e43d25e7375ef0bf135ee22fd8f65dc152617d4e2310929057df6aff601"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56a22e4ff0414db466a9e463b81b9ae3c2a39e92ca505d871c7f328012c26e5c", "transactions": [{"to": null, "gas": "0x5b8d80", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xc6ed8334b34ecdd281e6727d76a6b7261373eb830e953597a1f658275cdfec67", "input": "0x608060405234801561001057600080fd5b50600080546001600160a01b031916905561334a806100306000396000f3fe60806040526004361061028c5760003560e01c806373e2290c1161015a578063bf1e42c0116100c1578063db7af8541161007a578063db7af85414610f0d578063e30c397814610fd3578063e6018c3114610fe8578063ead5d35914611012578063f2fde38b14611053578063fc0c546a1461108657610293565b8063bf1e42c014610d39578063c44b73a314610d4e578063c59d484714610da5578063ca6d56dc14610df2578063cc77244014610e25578063ce7b786414610e3a57610293565b80639107d08e116101135780639107d08e14610a50578063a2d3cf4b14610abc578063a4c0ed3614610b8d578063a4d6ddc014610c1d578063ae66d94814610ccd578063b274bcc714610d0057610293565b806373e2290c1461090d578063790490171461094e5780637b30ed431461096357806385a2124614610a115780638da5cb5b14610a265780638fd3ab8014610a3b57610293565b80633d8e36a3116101fe578063593b79fe116101b7578063593b79fe146107215780635fb6c6ed146107c9578063662d45a2146107de5780636d8018b8146108115780636f4d469b1461082657806371cdfd68146108d457610293565b80633d8e36a31461059f5780633ebff90e146105b45780634bee9137146105c95780634d6b976f146106045780634e40ea64146106d95780634e71e0c81461070c57610293565b80631a79246c116102505780631a79246c146104065780632b94411f146104de5780632df3eba4146105195780632e0d42121461052e578063331beb5f14610561578063392e53cd1461057657610293565b80630600a8651461029857806309a6400b146102bf578063131b9c04146102f45780631796621a14610327578063187ac4cb146103d557610293565b3661029357005b600080fd5b3480156102a457600080fd5b506102ad61109b565b60408051918252519081900360200190f35b3480156102cb57600080fd5b506102f2600480360360208110156102e257600080fd5b50356001600160a01b03166110ba565b005b34801561030057600080fd5b506102ad6004803603602081101561031757600080fd5b50356001600160a01b03166111da565b34801561033357600080fd5b506102f26004803603602081101561034a57600080fd5b810190602081018135600160201b81111561036457600080fd5b82018360208201111561037657600080fd5b803590602001918460208302840111600160201b8311171561039757600080fd5b91908080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525092955061128a945050505050565b3480156103e157600080fd5b506103ea611309565b604080516001600160a01b039092168252519081900360200190f35b34801561041257600080fd5b506102ad600480360360a081101561042957600080fd5b6001600160a01b038235811692602081013590911691604082013591606081013515159181019060a081016080820135600160201b81111561046a57600080fd5b82018360208201111561047c57600080fd5b803590602001918460018302840111600160201b8311171561049d57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550611318945050505050565b3480156104ea57600080fd5b506102ad6004803603604081101561050157600080fd5b506001600160a01b0381351690602001351515611382565b34801561052557600080fd5b506102ad61139e565b34801561053a57600080fd5b506102ad6004803603602081101561055157600080fd5b50356001600160a01b03166113a4565b34801561056d57600080fd5b506102ad6113cd565b34801561058257600080fd5b5061058b611542565b604080519115158252519081900360200190f35b3480156105ab57600080fd5b506102ad611553565b3480156105c057600080fd5b506102ad611559565b3480156105d557600080fd5b506102ad600480360360408110156105ec57600080fd5b506001600160a01b038135169060200135151561155f565b34801561061057600080fd5b506102f2600480360360a081101561062757600080fd5b6001600160a01b038235811692602081013590911691810190606081016040820135600160201b81111561065a57600080fd5b82018360208201111561066c57600080fd5b803590602001918460208302840111600160201b8311171561068d57600080fd5b919080806020026020016040519081016040528093929190818152602001838360200280828437600092019190915250929550506001600160a01b038335169350505060200135611574565b3480156106e557600080fd5b506102f2600480360360208110156106fc57600080fd5b50356001600160a01b0316611762565b34801561071857600080fd5b506102f26118cb565b34801561072d57600080fd5b506107546004803603602081101561074457600080fd5b50356001600160a01b0316611981565b6040805160208082528351818301528351919283929083019185019080838360005b8381101561078e578181015183820152602001610776565b50505050905090810190601f1680156107bb5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b3480156107d557600080fd5b506102ad6119a5565b3480156107ea57600080fd5b506102f26004803603602081101561080157600080fd5b50356001600160a01b03166119ab565b34801561081d57600080fd5b506102ad611acf565b34801561083257600080fd5b506102f26004803603602081101561084957600080fd5b810190602081018135600160201b81111561086357600080fd5b82018360208201111561087557600080fd5b803590602001918460208302840111600160201b8311171561089657600080fd5b919080806020026020016040519081016040528093929190818152602001838360200280828437600092019190915250929550611ad5945050505050565b3480156108e057600080fd5b506102f2600480360360408110156108f757600080fd5b506001600160a01b038135169060200135611b71565b34801561091957600080fd5b506102ad6004803603606081101561093057600080fd5b506001600160a01b0381351690602081013590604001351515611c42565b34801561095a57600080fd5b506102ad611c58565b34801561096f57600080fd5b506102f26004803603602081101561098657600080fd5b810190602081018135600160201b8111156109a057600080fd5b8201836020820111156109b257600080fd5b803590602001918460208302840111600160201b831117156109d357600080fd5b919080806020026020016040519081016040528093929190818152602001838360200280828437600092019190915250929550611c5e945050505050565b348015610a1d57600080fd5b506102ad611c8e565b348015610a3257600080fd5b506103ea611c94565b348015610a4757600080fd5b506102f2611ca3565b348015610a5c57600080fd5b50610a8360048036036020811015610a7357600080fd5b50356001600160a01b03166122f5565b60405180856002811115610a9357fe5b60ff16815260200184815260200183815260200182815260200194505050505060405180910390f35b348015610ac857600080fd5b5061058b60048036036080811015610adf57600080fd5b6001600160a01b03823581169260208101359091169160408201359190810190608081016060820135600160201b811115610b1957600080fd5b820183602082011115610b2b57600080fd5b803590602001918460018302840111600160201b83111715610b4c57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550612320945050505050565b348015610b9957600080fd5b5061058b60048036036060811015610bb057600080fd5b6001600160a01b0382351691602081013591810190606081016040820135600160201b811115610bdf57600080fd5b820183602082011115610bf157600080fd5b803590602001918460018302840111600160201b83111715610c1257600080fd5b509092509050612521565b348015610c2957600080fd5b506102ad60048036036040811015610c4057600080fd5b810190602081018135600160201b811115610c5a57600080fd5b820183602082011115610c6c57600080fd5b803590602001918460208302840111600160201b83111715610c8d57600080fd5b9190808060200260200160405190810160405280939291908181526020018383602002808284376000920191909152509295505050503515159050612552565b348015610cd957600080fd5b506102ad60048036036020811015610cf057600080fd5b50356001600160a01b031661259f565b348015610d0c57600080fd5b506102f260048036036040811015610d2357600080fd5b506001600160a01b038135169060200135612617565b348015610d4557600080fd5b506103ea61288d565b348015610d5a57600080fd5b50610d8160048036036020811015610d7157600080fd5b50356001600160a01b031661289c565b60405180826002811115610d9157fe5b60ff16815260200191505060405180910390f35b348015610db157600080fd5b50610dba6128b1565b604051808260c080838360005b83811015610ddf578181015183820152602001610dc7565b5050505090500191505060405180910390f35b348015610dfe57600080fd5b506102f260048036036020811015610e1557600080fd5b50356001600160a01b03166128f7565b348015610e3157600080fd5b506103ea612afd565b348015610e4657600080fd5b506102ad60048036036080811015610e5d57600080fd5b6001600160a01b038235811692602081013590911691604082013515159190810190608081016060820135600160201b811115610e9957600080fd5b820183602082011115610eab57600080fd5b803590602001918460018302840111600160201b83111715610ecc57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550612b0c945050505050565b348015610f1957600080fd5b506102f260048036036060811015610f3057600080fd5b6001600160a01b0382351691602081013591810190606081016040820135600160201b811115610f5f57600080fd5b820183602082011115610f7157600080fd5b803590602001918460018302840111600160201b83111715610f9257600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550612b7e945050505050565b348015610fdf57600080fd5b506103ea612b8c565b348015610ff457600080fd5b506102f26004803603602081101561100b57600080fd5b5035612b9b565b34801561101e57600080fd5b506102ad6004803603606081101561103557600080fd5b506001600160a01b0381351690602081013590604001351515612c31565b34801561105f57600080fd5b506102f26004803603602081101561107657600080fd5b50356001600160a01b0316612ca6565b34801561109257600080fd5b506103ea612d13565b60006110b4600654600554612d2290919063ffffffff16565b90505b90565b6000546001600160a01b03163314611105576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b60016001600160a01b0382166000908152600e602052604090205460ff16600281111561112e57fe5b14611177576040805162461bcd60e51b8152602060048201526014602482015273195c9c9bdc97db9bdd1058dd1a5d995059d95b9d60621b604482015290519081900360640190fd5b6001600160a01b0381166000818152600e6020526040808220805460ff19166002179055517feac6c7d5a1c157497119a5d4f661d5f23b844c415452ef440ed346bd127d885e9190a2600a546111d490600163ffffffff612d2216565b600a5550565b6001600160a01b0381166000908152600d6020526040812081815460ff16600281111561120357fe5b1415611248576040805162461bcd60e51b815260206004820152600f60248201526e32b93937b92fb737ba26b2b6b132b960891b604482015290519081900360640190fd5b6001815460ff16600281111561125a57fe5b1461126657600061127d565b600281015460095461127d9163ffffffff612d2216565b6001909101540192915050565b6000546001600160a01b031633146112d5576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b60005b8151811015611305576112fd8282815181106112f057fe5b60200260200101516119ab565b6001016112d8565b5050565b600c546001600160a01b031681565b600061132686868685612320565b61136c576040805162461bcd60e51b81526020600482015260126024820152716572726f725f6261645369676e617475726560701b604482015290519081900360640190fd5b61137886868686612d64565b9695505050505050565b600061139783611391336113a4565b84611c42565b9392505050565b60055481565b60006113c76113b28361259f565b6113bb846111da565b9063ffffffff612d2216565b92915050565b600254604080516370a0823160e01b8152306004820152905160009283926001600160a01b03909116916370a0823191602480820192602092909190829003018186803b15801561141d57600080fd5b505afa158015611431573d6000803e3d6000fd5b505050506040513d602081101561144757600080fd5b50519050600061146561145861109b565b839063ffffffff612d2216565b90508015806114745750600754155b15611484576000925050506110b7565b600061149b600754836130f390919063ffffffff16565b6009549091506114b1908263ffffffff61313516565b6009556005546114c7908363ffffffff61313516565b6005556040805183815290517f41b06c6e0a1531dcb4b86d53ec6268666aa12d55775f8e5a63596fc935cdcc229181900360200190a160075460408051838152602081019290925280517f24a9873073eba764d17ef9fa7475b3b209c02e6e6f7ed991c9c80e09226a37a79281900390910190a15091505090565b6002546001600160a01b0316151590565b60085481565b600a5481565b60006113978361156e856113a4565b84612c31565b61157c611542565b156115ce576040805162461bcd60e51b815260206004820152601860248201527f6572726f725f616c7265616479496e697469616c697a65640000000000000000604482015290519081900360640190fd5b600080546001600160a01b03199081163317909155600c80546001600160a01b038781169190931617908190556040805163836c081d60e01b81529051919092169163836c081d916004808301926020929190829003018186803b15801561163557600080fd5b505afa158015611649573d6000803e3d6000fd5b505050506040513d602081101561165f57600080fd5b5051600280546001600160a01b0319166001600160a01b039092169190911790556116898361128a565b600c60009054906101000a90046001600160a01b03166001600160a01b031663533426d16040518163ffffffff1660e01b815260040160206040518083038186803b1580156116d757600080fd5b505afa1580156116eb573d6000803e3d6000fd5b505050506040513d602081101561170157600080fd5b5051600380546001600160a01b03199081166001600160a01b03938416179091556004805490911691841691909117905561173b81612b9b565b5050600080546001600160a01b0319166001600160a01b0394909416939093179092555050565b336001600160a01b038216148061179657506001336000908152600e602052604090205460ff16600281111561179457fe5b145b6117dc576040805162461bcd60e51b8152602060048201526012602482015271195c9c9bdc97db9bdd14195c9b5a5d1d195960721b604482015290519081900360640190fd5b6001600160a01b0381166000908152600d602052604090206001815460ff16600281111561180657fe5b14611850576040805162461bcd60e51b815260206004820152601560248201527432b93937b92fb737ba20b1ba34bb32a6b2b6b132b960591b604482015290519081900360640190fd5b611859826111da565b600182810191909155815460ff1916600217825560075461187991612d22565b60075560085461189090600163ffffffff61313516565b6008556040516001600160a01b038316907f7df2bff504799b36cafb9574b3fcfd8432ef4a1fa89d1ba9fe40324501adf5f590600090a25050565b6001546001600160a01b0316331461191d576040805162461bcd60e51b815260206004820152601060248201526f37b7363ca832b73234b733a7bbb732b960811b604482015290519081900360640190fd5b600154600080546040516001600160a01b0393841693909116917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e091a360018054600080546001600160a01b03199081166001600160a01b03841617909155169055565b604080516001600160a01b0392909216600560a21b18601483015260348201905290565b60075481565b6000546001600160a01b031633146119f6576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b60016001600160a01b0382166000908152600e602052604090205460ff166002811115611a1f57fe5b1415611a72576040805162461bcd60e51b815260206004820152601860248201527f6572726f725f616c72656164794163746976654167656e740000000000000000604482015290519081900360640190fd5b6001600160a01b0381166000818152600e6020526040808220805460ff19166001179055517f10581818fb1ffbfd9ac8500cba931a30c3a57b5e9b7972f2fa0aef002b3fde2b9190a2600a546111d490600163ffffffff61313516565b60095481565b6001336000908152600e602052604090205460ff166002811115611af557fe5b14611b41576040805162461bcd60e51b8152602060048201526017602482015276195c9c9bdc97dbdb9b1e529bda5b94185c9d1059d95b9d604a1b604482015290519081900360640190fd5b60005b815181101561130557611b69828281518110611b5c57fe5b60200260200101516128f7565b600101611b44565b80611b7b336113a4565b1015611bca576040805162461bcd60e51b81526020600482015260196024820152786572726f725f696e73756666696369656e7442616c616e636560381b604482015290519081900360640190fd5b336000908152600d602052604090206003810154611bee908363ffffffff61313516565b6003820155611bfd838361318f565b6040805183815290516001600160a01b0385169133917f638ce96e87261f007ef5c0389bb59b90db3e19c42edee859d6b09739d8d79f7f9181900360200190a3505050565b6000611c5033858585612d64565b949350505050565b600b5481565b60005b815181101561130557611c86828281518110611c7957fe5b6020026020010151611762565b600101611c61565b60065481565b6000546001600160a01b031681565b6000546001600160a01b03163314611cee576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600c546040805163533426d160e01b815290516000926001600160a01b03169163533426d1916004808301926020929190829003018186803b158015611d3357600080fd5b505afa158015611d47573d6000803e3d6000fd5b505050506040513d6020811015611d5d57600080fd5b505190506001600160a01b03811615801590611d8757506003546001600160a01b03828116911614155b15611de3576003546040516001600160a01b03918216918316907f5d82b60ad3cf3639e02e96994b2b10060c4c0a7c0214695baa228363fb910c3490600090a3600380546001600160a01b0319166001600160a01b0383161790555b600c546040805163836c081d60e01b815290516000926001600160a01b03169163836c081d916004808301926020929190829003018186803b158015611e2857600080fd5b505afa158015611e3c573d6000803e3d6000fd5b505050506040513d6020811015611e5257600080fd5b505190506001600160a01b03811615801590611e7c57506002546001600160a01b03828116911614155b8015611f065750600254600c546040805163598e388560e11b815290516001600160a01b03938416939092169163b31c710a91600480820192602092909190829003018186803b158015611ecf57600080fd5b505afa158015611ee3573d6000803e3d6000fd5b505050506040513d6020811015611ef957600080fd5b50516001600160a01b0316145b1561130557611f136113cd565b50600254604080516370a0823160e01b815230600482015290516000926001600160a01b0316916370a08231916024808301926020929190829003018186803b158015611f5f57600080fd5b505afa158015611f73573d6000803e3d6000fd5b505050506040513d6020811015611f8957600080fd5b5051604080516370a0823160e01b815230600482015290519192506000916001600160a01b038516916370a08231916024808301926020929190829003018186803b158015611fd757600080fd5b505afa158015611feb573d6000803e3d6000fd5b505050506040513d602081101561200157600080fd5b50519050811561228c57600254600c546040805163095ea7b360e01b81526001600160a01b039283166004820152602481018690529051919092169163095ea7b39160448083019260209291908290030181600087803b15801561206457600080fd5b505af1158015612078573d6000803e3d6000fd5b505050506040513d602081101561208e57600080fd5b5050600c5460408051634a5c8c6f60e11b81526004810185905290516001600160a01b03909216916394b918de9160248082019260009290919082900301818387803b1580156120dd57600080fd5b505af11580156120f1573d6000803e3d6000fd5b5050600254604080516370a0823160e01b815230600482015290516001600160a01b0390921693506370a082319250602480820192602092909190829003018186803b15801561214057600080fd5b505afa158015612154573d6000803e3d6000fd5b505050506040513d602081101561216a57600080fd5b5051156121b0576040805162461bcd60e51b815260206004820152600f60248201526e1d1bdad95b9cd7db9bdd17dcd95b9d608a1b604482015290519081900360640190fd5b8161224382856001600160a01b03166370a08231306040518263ffffffff1660e01b815260040180826001600160a01b03166001600160a01b0316815260200191505060206040518083038186803b15801561220b57600080fd5b505afa15801561221f573d6000803e3d6000fd5b505050506040513d602081101561223557600080fd5b50519063ffffffff612d2216565b101561228c576040805162461bcd60e51b81526020600482015260136024820152721d1bdad95b9cd7db9bdd17dc9958d95a5d9959606a1b604482015290519081900360640190fd5b6002546040805184815290516001600160a01b03928316928616917fd05a160a091ef7d70215da5058f251bcba4363a35c404ba3345403d4cf86b0e1919081900360200190a35050600280546001600160a01b0383166001600160a01b03199091161790555050565b600d60205260009081526040902080546001820154600283015460039093015460ff90921692909184565b60008151604114612378576040805162461bcd60e51b815260206004820152601860248201527f6572726f725f6261645369676e61747572654c656e6774680000000000000000604482015290519081900360640190fd5b60208201516040830151606084015160001a601b81101561239757601b015b8060ff16601b14806123ac57508060ff16601c145b6123fd576040805162461bcd60e51b815260206004820152601960248201527f6572726f725f6261645369676e617475726556657273696f6e00000000000000604482015290519081900360640190fd5b600087873061240b8c61259f565b60405160200180807f19457468657265756d205369676e6564204d6573736167653a0a313034000000815250601d01856001600160a01b03166001600160a01b031660601b8152601401848152602001836001600160a01b03166001600160a01b031660601b8152601401828152602001945050505050604051602081830303815290604052805190602001209050600060018284878760405160008152602001604052604051808581526020018460ff1660ff1681526020018381526020018281526020019450505050506020604051602081039080840390855afa1580156124f9573d6000803e3d6000fd5b5050604051601f1901516001600160a01b038c81169116149650505050505050949350505050565b6002546000906001600160a01b0316331461253e57506000611c50565b6125466113cd565b50600195945050505050565b600080805b84518110156125975761258d61258086838151811061257257fe5b60200260200101518661155f565b839063ffffffff61313516565b9150600101612557565b509392505050565b6001600160a01b0381166000908152600d6020526040812081815460ff1660028111156125c857fe5b141561260d576040805162461bcd60e51b815260206004820152600f60248201526e32b93937b92fb737ba26b2b6b132b960891b604482015290519081900360640190fd5b6003015492915050565b600254604080516370a0823160e01b815230600482015290516000926001600160a01b0316916370a08231916024808301926020929190829003018186803b15801561266257600080fd5b505afa158015612676573d6000803e3d6000fd5b505050506040513d602081101561268c57600080fd5b5051600254604080516323b872dd60e01b81523360048201523060248201526044810186905290519293506001600160a01b03909116916323b872dd916064808201926020929091908290030181600087803b1580156126eb57600080fd5b505af11580156126ff573d6000803e3d6000fd5b505050506040513d602081101561271557600080fd5b5051612759576040805162461bcd60e51b815260206004820152600e60248201526d32b93937b92fba3930b739b332b960911b604482015290519081900360640190fd5b600254604080516370a0823160e01b815230600482015290516000926001600160a01b0316916370a08231916024808301926020929190829003018186803b1580156127a457600080fd5b505afa1580156127b8573d6000803e3d6000fd5b505050506040513d60208110156127ce57600080fd5b50519050826127e3828463ffffffff612d2216565b1015612827576040805162461bcd60e51b815260206004820152600e60248201526d32b93937b92fba3930b739b332b960911b604482015290519081900360640190fd5b612831848461318f565b600554612844908463ffffffff61313516565b6005556040805184815290516001600160a01b0386169133917f4e018df3c92158645fcf45007db7029d3fa97d269866be2bd4360c5f5a6163e49181900360200190a350505050565b6004546001600160a01b031681565b600e6020526000908152604090205460ff1681565b6128b96132f6565b6040518060c0016040528060055481526020016006548152602001600754815260200160085481526020016009548152602001600a54815250905090565b6001336000908152600e602052604090205460ff16600281111561291757fe5b14612963576040805162461bcd60e51b8152602060048201526017602482015276195c9c9bdc97dbdb9b1e529bda5b94185c9d1059d95b9d604a1b604482015290519081900360640190fd5b6001600160a01b0381166000908152600d602052604090206001815460ff16600281111561298d57fe5b14156129d6576040805162461bcd60e51b815260206004820152601360248201527232b93937b92fb0b63932b0b23ca6b2b6b132b960691b604482015290519081900360640190fd5b6002815460ff1660028111156129e857fe5b1415612a0657600854612a0290600163ffffffff612d2216565b6008555b600080825460ff166002811115612a1957fe5b148015612a275750600b5415155b8015612a355750600b544710155b825460ff1916600190811784556009546002850155600754919250612a5a9190613135565b6007556040516001600160a01b038416907f0abf3b3f643594d958297062a019458e27d7766629590ac621aa1000fa1298ab90600090a28015612af857600b546040516001600160a01b0385169180156108fc02916000818181858888f1935050505015612af857600b5460408051918252517f55e2724f03f2711a94cf86d8b10c57130b103d6c2f1726076fbf9430340d41e79181900360200190a15b505050565b6003546001600160a01b031681565b6000612b1b8585600085612320565b612b61576040805162461bcd60e51b81526020600482015260126024820152716572726f725f6261645369676e617475726560701b604482015290519081900360640190fd5b612b758585612b6f886113a4565b86612d64565b95945050505050565b612b866113cd565b50505050565b6001546001600160a01b031681565b6000546001600160a01b03163314612be6576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600b54811415612bf557612c2e565b600b8190556040805182815290517f749d0aa4ca45d6142166deb1820b64a888996311bb9f74a88c081f5b041d949c9181900360200190a15b50565b6000336001600160a01b0385161480612c5457506000546001600160a01b031633145b612c9a576040805162461bcd60e51b8152602060048201526012602482015271195c9c9bdc97db9bdd14195c9b5a5d1d195960721b604482015290519081900360640190fd5b611c5084858585612d64565b6000546001600160a01b03163314612cf1576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600180546001600160a01b0319166001600160a01b0392909216919091179055565b6002546001600160a01b031681565b600061139783836040518060400160405280601e81526020017f536166654d6174683a207375627472616374696f6e206f766572666c6f7700008152506131fa565b600082612d7357506000611c50565b612d7c856113a4565b831115612dcc576040805162461bcd60e51b81526020600482015260196024820152786572726f725f696e73756666696369656e7442616c616e636560381b604482015290519081900360640190fd5b6001600160a01b0385166000908152600d602052604090206003810154612df9908563ffffffff61313516565b6003820155600654612e11908563ffffffff61313516565b6006558215612f68576002546003546001600160a01b0391821691634000aea0911686612e3d89611981565b6040518463ffffffff1660e01b815260040180846001600160a01b03166001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b83811015612ea7578181015183820152602001612e8f565b50505050905090810190601f168015612ed45780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b158015612ef557600080fd5b505af1158015612f09573d6000803e3d6000fd5b505050506040513d6020811015612f1f57600080fd5b5051612f63576040805162461bcd60e51b815260206004820152600e60248201526d32b93937b92fba3930b739b332b960911b604482015290519081900360640190fd5b6130aa565b6002546001600160a01b0316634000aea08686612f848a611981565b6040518463ffffffff1660e01b815260040180846001600160a01b03166001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b83811015612fee578181015183820152602001612fd6565b50505050905090810190601f16801561301b5780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b15801561303c57600080fd5b505af1158015613050573d6000803e3d6000fd5b505050506040513d602081101561306657600080fd5b50516130aa576040805162461bcd60e51b815260206004820152600e60248201526d32b93937b92fba3930b739b332b960911b604482015290519081900360640190fd5b6040805185815290516001600160a01b038816917f48dc35af7b45e2a81fffad55f6e2fafacdb1d3d0d50d24ebdc16324f5ba757f1919081900360200190a25091949350505050565b600061139783836040518060400160405280601a81526020017f536166654d6174683a206469766973696f6e206279207a65726f000000000000815250613291565b600082820183811015611397576040805162461bcd60e51b815260206004820152601b60248201527f536166654d6174683a206164646974696f6e206f766572666c6f770000000000604482015290519081900360640190fd5b6001600160a01b0382166000908152600d6020526040902060018101546131bc908363ffffffff61313516565b60018201556000815460ff1660028111156131d357fe5b1415612af857805460ff191660021781556008546131f2906001613135565b600855505050565b600081848411156132895760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b8381101561324e578181015183820152602001613236565b50505050905090810190601f16801561327b5780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b505050900390565b600081836132e05760405162461bcd60e51b815260206004820181815283516024840152835190928392604490910191908501908083836000831561324e578181015183820152602001613236565b5060008385816132ec57fe5b0495945050505050565b6040518060c00160405280600690602082028036833750919291505056fea2646970667358221220c057f0951032741c15f13595949ab49c5f1611e01611edeee27a8cac3b53fc1864736f6c63430006060033", "nonce": "0x24", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x403362b45a168eb941d85cb44eb24635821d3428b219e16e34dfba25389c5259", "blockNumber": "0x80", "transactionIndex": "0x0"}], "totalDifficulty": "0x7fffffffffffffffffffffffffdfca8390", "transactionsRoot": "0x28eef0194ea238c91f4cf63464c75920945244a1397cacc2b2eb50619829c07f"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x2c19e0", "blockHash": "0x403362b45a168eb941d85cb44eb24635821d3428b219e16e34dfba25389c5259", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x80", "contractAddress": "0x35f1b900e63579ec0bd3904941de7e8fe5e7f3b4", "transactionHash": "0xc6ed8334b34ecdd281e6727d76a6b7261373eb830e953597a1f658275cdfec67", "transactionIndex": "0x0", "cumulativeGasUsed": "0x2c19e0"}]}
\\x366f8bf5fcb132e0a2eddd3bce40e9caba4afc7706ffbebfbf5e7747aecfa275	127	\\xef795ee266ef20e3d72361bd8f7b44beb853a24620d733421bd0a0ec3752cd50	{"block": {"hash": "0x366f8bf5fcb132e0a2eddd3bce40e9caba4afc7706ffbebfbf5e7747aecfa275", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7f", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x67a1d9", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x55968f5dfaacab53a5944ef1db85c75f1deb07b99dba0407683a798764f9985c", "timestamp": "0x60a673ca", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xef795ee266ef20e3d72361bd8f7b44beb853a24620d733421bd0a0ec3752cd50", "sealFields": ["0x8420377bee", "0xb841ad20cc0eb457a866d2b68626be46512881b1c84b9db224675087707f0876d7a946c6d55daa8c8a052f5cc2eae3f6abd90e230e799a36e7e8ff87c3ef8cca0ba001"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x7effffffffffffffffffffffffdfca8393", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xef795ee266ef20e3d72361bd8f7b44beb853a24620d733421bd0a0ec3752cd50	126	\\x5a1531e521463e3566764de80749569e1e12ec666287d7b20bbcaf9a795474fd	{"block": {"hash": "0xef795ee266ef20e3d72361bd8f7b44beb853a24620d733421bd0a0ec3752cd50", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7e", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6787f9", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x55968f5dfaacab53a5944ef1db85c75f1deb07b99dba0407683a798764f9985c", "timestamp": "0x60a673c7", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x5a1531e521463e3566764de80749569e1e12ec666287d7b20bbcaf9a795474fd", "sealFields": ["0x8420377bed", "0xb8419144c0b21ed36b4626db1d72e8549e3deb4135f4d7a4d5d9547f4820aab5b8f75bf1d5da3b9cbcaf4337086501d77c0dda2a7a3912cee2f9661ca7946d42f60301"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x7dffffffffffffffffffffffffdfca8395", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x5a1531e521463e3566764de80749569e1e12ec666287d7b20bbcaf9a795474fd	125	\\xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db	{"block": {"hash": "0x5a1531e521463e3566764de80749569e1e12ec666287d7b20bbcaf9a795474fd", "size": "0x2d8", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7d", "uncles": [], "gasUsed": "0x782e", "mixHash": null, "gasLimit": "0x676e1f", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000800000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000", "stateRoot": "0x55968f5dfaacab53a5944ef1db85c75f1deb07b99dba0407683a798764f9985c", "timestamp": "0x60a673c4", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db", "sealFields": ["0x8420377bec", "0xb8413bf604be9485f1c16e6a751230902e8e52f6a6f686d71e35768201db822278656a3f3efb3c2356ecc253200669b7e44449f44517e7f7f1ca8319bfd5d8bdf92500"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x8efa8c42fd49920f55e4bca2ebad49bfb7d2893498f5ea1c0aabe2b9cca6cb68", "transactions": [{"to": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "gas": "0xf05c", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x8abcf782657d790b4e658a2e38cb878e93694e2c4b030d7a0b3d8763da301c7c", "input": "0xf1739cae000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "nonce": "0x23", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x5a1531e521463e3566764de80749569e1e12ec666287d7b20bbcaf9a795474fd", "blockNumber": "0x7d", "transactionIndex": "0x0"}], "totalDifficulty": "0x7cffffffffffffffffffffffffdfca8397", "transactionsRoot": "0xd80aa234e0123e2a1278e73709caf3275e276d01d4579fa8e58f608f01135a77"}, "transaction_receipts": [{"logs": [{"data": "0x0000000000000000000000004178babe9e5148c6d5fd431cd72884b07ad855a0000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "topics": ["0x5a3e66efaa1e445ebd894728a69d6959842ea1e97bd79b892797106e270efcd9"], "address": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0x5a1531e521463e3566764de80749569e1e12ec666287d7b20bbcaf9a795474fd", "blockNumber": "0x7d", "transactionHash": "0x8abcf782657d790b4e658a2e38cb878e93694e2c4b030d7a0b3d8763da301c7c", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}], "root": null, "status": "0x1", "gasUsed": "0x782e", "blockHash": "0x5a1531e521463e3566764de80749569e1e12ec666287d7b20bbcaf9a795474fd", "logsBloom": "0x00000000000800000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000", "blockNumber": "0x7d", "contractAddress": null, "transactionHash": "0x8abcf782657d790b4e658a2e38cb878e93694e2c4b030d7a0b3d8763da301c7c", "transactionIndex": "0x0", "cumulativeGasUsed": "0x782e"}]}
\\xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db	124	\\x66b2f16e9d22fa80da4f9bffc9bc6f74276b90d59e6cf7051300c8b2162f7653	{"block": {"hash": "0xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db", "size": "0x43e", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7c", "uncles": [], "gasUsed": "0x4b9d7", "mixHash": null, "gasLimit": "0x67544b", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000020000000000200000000024000000000000000000800000000000000000000000000000000400200000000000000100000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020000000000000000000000000000040000000000000000000000000000000000000", "stateRoot": "0xec02de6b24ed1c0bbd29622a22102f1b03f37d11e1f62580c115348b9feee992", "timestamp": "0x60a673c1", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x66b2f16e9d22fa80da4f9bffc9bc6f74276b90d59e6cf7051300c8b2162f7653", "sealFields": ["0x8420377beb", "0xb84181d97de7f8c8c363e3959a93ee4306e98ec06e9f37cd54b15c3f2fffd651153908db1bb298824b3df738c40c86966ce5575784d7dc4175573092ed3f8770f37800"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x6ca4dd7ec7671cb4fb7b151d5369e2eb1c43f09b36d710e21afded4923739104", "transactions": [{"to": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "gas": "0x99658", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x2fde728224e64a26637b7fd87234e3ab2b49a85a6805cdbe4e687c46d93e309d", "input": "0x3da98c8b00000000000000000000000073be21733cc5d08e1a14ea9a399fb27db3bef8ff0000000000000000000000006346ed242ade018bd9320d5e3371c377bab29c310000000000000000000000000000000000000000000c685fa11e01ec6f000000000000000000000000000000000000000000000000009ed194db19b238c0000000000000000000000000000000000000000000000000000006f05b59d3b200000000000000000000000000000000000000000000000c685fa11e01ec6f000000000000000000000000000000000000000000000000009ed194db19b238c00000000000000000000000000000c2f87e37019e227f2be5030aabbcc7eaf136e05c000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de100000000000000000000000036afc8c9283cc866b8eb6a61c6e6862a83cd6ee80000000000000000000000001def1497df0e103d58fd14c4f8e0365fe5f944230000000000000000000000004a4c4759eb3b7abee079f832850cd3d0dc48d927", "nonce": "0x22", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db", "blockNumber": "0x7c", "transactionIndex": "0x0"}], "totalDifficulty": "0x7bffffffffffffffffffffffffdfca8399", "transactionsRoot": "0x4e5265a9d908e235dce395b3059b90c1999bb83415c0347477407a7006960dbb"}, "transaction_receipts": [{"logs": [{"data": "0x0000000000000000000000000000000000000000000c685fa11e01ec6f000000", "topics": ["0xca0b3dabefdbd8c72c0a9cf4a6e9d107da897abf036ef3f3f3b010cdd2594159", "0x0000000000000000000000000000000000000000000000000000000000000000"], "address": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db", "blockNumber": "0x7c", "transactionHash": "0x2fde728224e64a26637b7fd87234e3ab2b49a85a6805cdbe4e687c46d93e309d", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}, {"data": "0x0000000000000000000000000000000000000000000c685fa11e01ec6f000000", "topics": ["0x4c177b42dbe934b3abbc0208c11a42e46589983431616f1710ab19969c5ed62e", "0x0000000000000000000000000000000000000000000000000000000000000000"], "address": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "logType": null, "removed": false, "logIndex": "0x1", "blockHash": "0xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db", "blockNumber": "0x7c", "transactionHash": "0x2fde728224e64a26637b7fd87234e3ab2b49a85a6805cdbe4e687c46d93e309d", "transactionIndex": "0x0", "transactionLogIndex": "0x1"}, {"data": "0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "topics": ["0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0"], "address": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "logType": null, "removed": false, "logIndex": "0x2", "blockHash": "0xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db", "blockNumber": "0x7c", "transactionHash": "0x2fde728224e64a26637b7fd87234e3ab2b49a85a6805cdbe4e687c46d93e309d", "transactionIndex": "0x0", "transactionLogIndex": "0x2"}], "root": null, "status": "0x1", "gasUsed": "0x4b9d7", "blockHash": "0xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db", "logsBloom": "0x00000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000020000000000200000000024000000000000000000800000000000000000000000000000000400200000000000000100000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020000000000000000000000000000040000000000000000000000000000000000000", "blockNumber": "0x7c", "contractAddress": null, "transactionHash": "0x2fde728224e64a26637b7fd87234e3ab2b49a85a6805cdbe4e687c46d93e309d", "transactionIndex": "0x0", "cumulativeGasUsed": "0x4b9d7"}]}
\\x66b2f16e9d22fa80da4f9bffc9bc6f74276b90d59e6cf7051300c8b2162f7653	123	\\xa9ffa8c89a60375c22d4f38a2c554c44bf07d99602ea35700f868a3fe92f21a5	{"block": {"hash": "0x66b2f16e9d22fa80da4f9bffc9bc6f74276b90d59e6cf7051300c8b2162f7653", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7b", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x673a7e", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xabc3eec24d4037fe827e5b12eb377f5102bfb634eba0206d34b2f9b2e9d6034a", "timestamp": "0x60a673bb", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xa9ffa8c89a60375c22d4f38a2c554c44bf07d99602ea35700f868a3fe92f21a5", "sealFields": ["0x8420377be9", "0xb8416ce967a99f0a5062aa329bb8f3db3f2abb7b818823c06b4423391042e5122dce3fac39c1db0756d7a3bebf74ea4731508c0b653aafeed335fa17b8543a23689601"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x7affffffffffffffffffffffffdfca839c", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xa9ffa8c89a60375c22d4f38a2c554c44bf07d99602ea35700f868a3fe92f21a5	122	\\xb2ac715c3e227e9d337402dacda23d0c57441fb7e4a50f050a10ad6384075a7e	{"block": {"hash": "0xa9ffa8c89a60375c22d4f38a2c554c44bf07d99602ea35700f868a3fe92f21a5", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7a", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6720b7", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xabc3eec24d4037fe827e5b12eb377f5102bfb634eba0206d34b2f9b2e9d6034a", "timestamp": "0x60a673b8", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xb2ac715c3e227e9d337402dacda23d0c57441fb7e4a50f050a10ad6384075a7e", "sealFields": ["0x8420377be8", "0xb841e3efa732b115bcfd4e71b6693811700826d3585e814d12bf11d07d030c98cd5c5718dc89fbccb0892166db296f5a85940d79852cf0e45b60b8bbbc8237618d2d01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x79ffffffffffffffffffffffffdfca839e", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xb2ac715c3e227e9d337402dacda23d0c57441fb7e4a50f050a10ad6384075a7e	121	\\xa99de549c4e38d11ba152bd58b982314f58ffaee350f969156bb1827a345bc25	{"block": {"hash": "0xb2ac715c3e227e9d337402dacda23d0c57441fb7e4a50f050a10ad6384075a7e", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x79", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6706f7", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xabc3eec24d4037fe827e5b12eb377f5102bfb634eba0206d34b2f9b2e9d6034a", "timestamp": "0x60a673b5", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0xa99de549c4e38d11ba152bd58b982314f58ffaee350f969156bb1827a345bc25", "sealFields": ["0x8420377be7", "0xb84140885080f81232d8c31675119a457124601290ee131e4a45b1e0567d7f57352e73bcea1c2f519dfed3ed7d0471b274e9d82d3c55e282264453721702f17b381901"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x78ffffffffffffffffffffffffdfca83a0", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x9bb20cbfa578ec534adf8a59528ca522ec05f7a44a43eeb9d04012d6f27730e9	119	\\xc5946e019b3510e58305b571db89f952a23b4fc326c2cd33c2948e3a0fb06796	{"block": {"hash": "0x9bb20cbfa578ec534adf8a59528ca522ec05f7a44a43eeb9d04012d6f27730e9", "size": "0x62fa", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x77", "uncles": [], "gasUsed": "0x50d51f", "mixHash": null, "gasLimit": "0x66d38a", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xf0908729c3b1bcb4612c3b832e29591ff2b9c5510dec5105e83a01af696c629a", "timestamp": "0x60a673ac", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xc5946e019b3510e58305b571db89f952a23b4fc326c2cd33c2948e3a0fb06796", "sealFields": ["0x8420377be4", "0xb8418f6bac17b7de92bfb6bc83e565ede9730f942ad1441d9da54a0c725a3e79a4de42ba6639b682183569d1a0d7216a959e76f390460ee30c10b2de32dd6171340d01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x6a50f7a4ccd3752e3249e2d6cad941fa85eb876184e3e94e0a4ea9dfa12fafba", "transactions": [{"to": null, "gas": "0x66b9dd", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xe479b9e3f37ef68a4649fec5725d0e5df8cc4c530351964b50bc6e26a99bbdb7", "input": "0x60c06040523480156200001157600080fd5b5060405162005ff438038062005ff4833981810160405260208110156200003757600080fd5b81019080805160405193929190846401000000008211156200005857600080fd5b9083019060208201858111156200006e57600080fd5b82516401000000008111828201881017156200008957600080fd5b82525081516020918201929091019080838360005b83811015620000b85781810151838201526020016200009e565b50505050905090810190601f168015620000e65780820380516001836020036101000a031916815260200191505b5060405250505080602081511115620000fe57600080fd5b602081015160a052516080525060805160a051615ec56200012f60003980614ced525080614d725250615ec56000f3fe608060405234801561001057600080fd5b50600436106103a45760003560e01c80636e5d6bea116101e9578063c2173d431161010f578063d7405481116100ad578063ec47de2a1161007c578063ec47de2a14611045578063f2c54fe814611071578063f2fde38b1461109d578063f3f51415146110c3576103a4565b8063d740548114610f27578063db6fff8c14610feb578063dfbe4ae014611017578063e77772fe1461103d576103a4565b8063cd596583116100e9578063cd59658314610dad578063d0342acd14610db5578063d0fb020314610de3578063d522cfd714610deb576103a4565b8063c2173d4314610cbb578063c534576114610ce1578063c722b1be14610da5576103a4565b80639a4a439511610187578063a4c0ed3611610156578063a4c0ed3614610b7a578063ab3a25d914610c33578063ad58bdd114610c5f578063ae813e9f14610c95576103a4565b80639a4a439514610afb5780639cb7595a14610b185780639d4051ae14610b4c578063a4b1c24314610b54576103a4565b8063867f7a4d116101c3578063867f7a4d14610a01578063871c076014610ac55780638da5cb5b14610acd57806390ad84a814610ad5576103a4565b80636e5d6bea146109895780637610722f146109af5780637837cf91146109d5576103a4565b80632f73a9f8116102ce578063472d35b91161026c578063613fa2f21161023b578063613fa2f2146108d757806361c04f84146108fd57806364696f971461092357806369ffa08a1461095b576103a4565b8063472d35b91461083257806347ac7d6a14610858578063593399821461087e578063613f1e4e1461089b576103a4565b80633da98c8b116102a85780633da98c8b146107785780633e6968b6146107df57806340f8dd86146107e7578063437764df1461080d576103a4565b80632f73a9f81461071e578063392e53cd146107445780633a50bc871461074c576103a4565b8063125e4cfb11610346578063272255bb11610315578063272255bb146105945780632803212f146105ca5780632ae87cdd146105f65780632d70061f146106dc576103a4565b8063125e4cfb146104ec57806316ef191314610522578063194153d31461054857806326aa101f1461056e576103a4565b80630950d515116103825780630950d5151461043b5780630b26cf66146104585780630b71a4a71461047e57806310775238146104ac576103a4565b806301e4f53a146103a957806301fcc1d3146103d7578063032f693f14610403575b600080fd5b6103d5600480360360408110156103bf57600080fd5b506001600160a01b0381351690602001356110e9565b005b6103d5600480360360408110156103ed57600080fd5b506001600160a01b038135169060200135611128565b6104296004803603602081101561041957600080fd5b50356001600160a01b03166111c7565b60408051918252519081900360200190f35b6103d56004803603602081101561045157600080fd5b503561121f565b6103d56004803603602081101561046e57600080fd5b50356001600160a01b03166112c8565b6103d56004803603604081101561049457600080fd5b506001600160a01b03813581169160200135166112dc565b6104d8600480360360408110156104c257600080fd5b506001600160a01b0381351690602001356113b1565b604080519115158252519081900360200190f35b6103d56004803603606081101561050257600080fd5b506001600160a01b03813581169160208101359091169060400135611424565b6104296004803603602081101561053857600080fd5b50356001600160a01b031661145e565b6104296004803603602081101561055e57600080fd5b50356001600160a01b03166114bb565b6104d86004803603602081101561058457600080fd5b50356001600160a01b0316611516565b6103d5600480360360608110156105aa57600080fd5b506001600160a01b03813581169160208101359091169060400135611529565b6103d5600480360360408110156105e057600080fd5b506001600160a01b03813516906020013561154c565b6103d5600480360360c081101561060c57600080fd5b6001600160a01b038235169190810190604081016020820135600160201b81111561063657600080fd5b82018360208201111561064857600080fd5b803590602001918460018302840111600160201b8311171561066957600080fd5b919390929091602081019035600160201b81111561068657600080fd5b82018360208201111561069857600080fd5b803590602001918460018302840111600160201b831117156106b957600080fd5b919350915060ff813516906001600160a01b03602082013516906040013561161b565b610702600480360360208110156106f257600080fd5b50356001600160a01b031661164d565b604080516001600160a01b039092168252519081900360200190f35b6103d56004803603602081101561073457600080fd5b50356001600160a01b03166116b3565b6104d86116c4565b6104d86004803603604081101561076257600080fd5b506001600160a01b038135169060200135611715565b6104d8600480360361018081101561078f57600080fd5b506001600160a01b0381358116916020810135821691604082019160a081019160e0820135811691610100810135821691610120820135811691610140810135821691610160909101351661176b565b610429611953565b610429600480360360208110156107fd57600080fd5b50356001600160a01b031661195c565b6108156119bb565b604080516001600160e01b03199092168252519081900360200190f35b6103d56004803603602081101561084857600080fd5b50356001600160a01b03166119c6565b6107026004803603602081101561086e57600080fd5b50356001600160a01b03166119d7565b6104d86004803603602081101561089457600080fd5b50356119e2565b6103d5600480360360808110156108b157600080fd5b506001600160a01b03813581169160208101358216916040820135169060600135611a35565b6103d5600480360360208110156108ed57600080fd5b50356001600160a01b0316611adc565b6107026004803603602081101561091357600080fd5b50356001600160a01b0316611aed565b6103d56004803603606081101561093957600080fd5b506001600160a01b038135811691602081013582169160409091013516611b56565b6103d56004803603604081101561097157600080fd5b506001600160a01b0381358116916020013516611c4c565b6103d56004803603602081101561099f57600080fd5b50356001600160a01b0316611cf4565b610429600480360360208110156109c557600080fd5b50356001600160a01b0316611d05565b6103d5600480360360408110156109eb57600080fd5b506001600160a01b038135169060200135611d5f565b6103d560048036036080811015610a1757600080fd5b6001600160a01b03823581169260208101359091169160408201359190810190608081016060820135600160201b811115610a5157600080fd5b820183602082011115610a6357600080fd5b803590602001918460018302840111600160201b83111715610a8457600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550611e37945050505050565b610702611e61565b610702611eb8565b6103d560048036036020811015610aeb57600080fd5b50356001600160a01b0316611f0f565b6103d560048036036020811015610b1157600080fd5b5035611f20565b610b20612115565b6040805167ffffffffffffffff9485168152928416602084015292168183015290519081900360600190f35b61070261211e565b61042960048036036020811015610b6a57600080fd5b50356001600160a01b0316612175565b6104d860048036036060811015610b9057600080fd5b6001600160a01b0382351691602081013591810190606081016040820135600160201b811115610bbf57600080fd5b820183602082011115610bd157600080fd5b803590602001918460018302840111600160201b83111715610bf257600080fd5b91908080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509295506121c9945050505050565b61042960048036036040811015610c4957600080fd5b506001600160a01b038135169060200135612230565b6103d560048036036060811015610c7557600080fd5b506001600160a01b03813581169160208101359091169060400135612296565b6104d860048036036020811015610cab57600080fd5b50356001600160a01b03166122a4565b6104d860048036036020811015610cd157600080fd5b50356001600160a01b03166122fd565b6103d560048036036080811015610cf757600080fd5b6001600160a01b03823581169260208101359091169160408201359190810190608081016060820135600160201b811115610d3157600080fd5b820183602082011115610d4357600080fd5b803590602001918460018302840111600160201b83111715610d6457600080fd5b91908080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525092955061232a945050505050565b61070261236a565b6107026123c1565b6103d560048036036040811015610dcb57600080fd5b506001600160a01b0381358116916020013516612418565b6107026125c7565b6103d5600480360360e0811015610e0157600080fd5b6001600160a01b038235169190810190604081016020820135600160201b811115610e2b57600080fd5b820183602082011115610e3d57600080fd5b803590602001918460018302840111600160201b83111715610e5e57600080fd5b919390929091602081019035600160201b811115610e7b57600080fd5b820183602082011115610e8d57600080fd5b803590602001918460018302840111600160201b83111715610eae57600080fd5b9193909260ff833516926001600160a01b03602082013516926040820135929091608081019060600135600160201b811115610ee957600080fd5b820183602082011115610efb57600080fd5b803590602001918460018302840111600160201b83111715610f1c57600080fd5b50909250905061261e565b6103d560048036036080811015610f3d57600080fd5b6001600160a01b03823581169260208101359091169160408201359190810190608081016060820135600160201b811115610f7757600080fd5b820183602082011115610f8957600080fd5b803590602001918460018302840111600160201b83111715610faa57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550612694945050505050565b6103d56004803603604081101561100157600080fd5b506001600160a01b0381351690602001356126a0565b6107026004803603602081101561102d57600080fd5b50356001600160a01b031661273d565b610702612748565b6103d56004803603604081101561105b57600080fd5b506001600160a01b03813516906020013561279f565b6104296004803603604081101561108757600080fd5b506001600160a01b038135169060200135612840565b6103d5600480360360208110156110b357600080fd5b50356001600160a01b03166128a9565b610429600480360360208110156110d957600080fd5b50356001600160a01b03166128ba565b6111248233836000805b506040519080825280601f01601f19166020018201604052801561111e576020820181803683370190505b50612910565b5050565b611130612a71565b61113982611516565b61114257600080fd5b8015806111615750600081118015611161575061115e8261195c565b81105b61116a57600080fd5b60408051700caf0cac6eae8d2dedc9ac2f0a0cae4a8f607b1b60208083019190915260609490941b6001600160601b0319166031820152815180820360250181526045909101825280519084012060009081529283905290912055565b60408051670dac2f0a0cae4a8f60c31b6020808301919091526001600160601b0319606085901b1660288301528251601c818403018152603c909201835281519181019190912060009081529081905220545b919050565b611227612a98565b611230816119e2565b1561123a57600080fd5b600061124582612b42565b9050600061125283612b9b565b9050600061125f84612bf8565b905061126a84612c47565b611275838383612ca0565b604080516001600160a01b03808616825284166020820152808201839052905185917f07b5483b8e4bd8ea240a474d5117738350e7d431e3668c48a97910b0b397796a919081900360600190a250505050565b6112d0612a71565b6112d981612cc1565b50565b6112e4612a71565b6112ed81611516565b156112f757600080fd5b600061130282611aed565b6001600160a01b03161461131557600080fd5b60006113208361164d565b6001600160a01b03161461133357600080fd5b6113486001600160a01b038216306001612d3d565b806001600160a01b03166342966c6860016040518263ffffffff1660e01b815260040180828152602001915050600060405180830381600087803b15801561138f57600080fd5b505af11580156113a3573d6000803e3d6000fd5b505050506111248282612dc9565b6000806113cf836113c9866113c4611953565b612230565b90612ec4565b905060006113dd60006128ba565b1180156113f25750806113ef856128ba565b10155b80156114065750611402846111c7565b8311155b801561141a575061141684612175565b8310155b9150505b92915050565b61142c612a98565b60006114378461164d565b905061144281611516565b61144b57600080fd5b6114588160008585612f25565b50505050565b60408051700caf0cac6eae8d2dedc9ac2f0a0cae4a8f607b1b60208083019190915260609390931b6001600160601b0319166031820152815180820360250181526045909101825280519083012060009081529182905290205490565b604080516e6d65646961746f7242616c616e636560881b60208083019190915260609390931b6001600160601b031916602f820152815180820360230181526043909101825280519083012060009081529182905290205490565b60008061152283612175565b1192915050565b611531612a98565b61153a8361304f565b6115478360018484612f25565b505050565b611554612a71565b61155d82611516565b61156657600080fd5b61156f826111c7565b81118061157a575080155b61158357600080fd5b604080516919185a5b1e531a5b5a5d60b21b6020808301919091526001600160601b0319606086901b16602a8301528251601e818403018152603e83018085528151918301919091206000908152918290529083902084905583905290516001600160a01b038416917fca0b3dabefdbd8c72c0a9cf4a6e9d107da897abf036ef3f3f3b010cdd25941599190819003605e0190a25050565b611623612a98565b600061163389898989898961310b565b90506116428160008585612f25565b505050505050505050565b604080516f686f6d65546f6b656e4164647265737360801b60208083019190915260609390931b6001600160601b03191660308201528151808203602401815260449091018252805190830120600090815260029092529020546001600160a01b031690565b6116bb612a71565b6112d981613459565b7f0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba60005260046020527f078d888f9b66f3f8bfa10909e31f1e16240db73449f0500afdbbe3a70da457cc5460ff1690565b60008061172d836113c986611728611953565b612840565b9050600061173b600061195c565b11801561175057508061174d8561195c565b10155b801561141a57506117608461145e565b909211159392505050565b60408051600481526024810182526020810180516001600160e01b03166337ef410160e11b1781529151815160009384936060933093919290918291908083835b602083106117cb5780518252601f1990920191602091820191016117ac565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d806000811461182b576040519150601f19603f3d011682016040523d82523d6000602084013e611830565b606091505b509150915081158061186c57508051602014801561186c575080806020019051602081101561185e57600080fd5b50516001600160a01b031633145b8061187657503330145b61187f57600080fd5b6118876116c4565b1561189157600080fd5b61189a8c612cc1565b6118a38b6134d5565b6118d760008b600380602002604051908101604052809291908260036020028082843760009201919091525061353f915050565b60408051808201825261190691600091908c906002908390839080828437600092019190915250613693915050565b61190f88613782565b6119188761380f565b61192186613459565b61192a856138d7565b61193384613964565b61193b6139f1565b6119436116c4565b9c9b505050505050505050505050565b62015180420490565b6040805172195e1958dd5d1a5bdb91185a5b1e531a5b5a5d606a1b60208083019190915260609390931b6001600160601b0319166033820152815180820360270181526047909101825280519083012060009081529182905290205490565b6358a8b61360e11b90565b6119ce612a71565b6112d9816138d7565b600061141e82611aed565b604080516b1b595cdcd859d9519a5e195960a21b602080830191909152602c80830185905283518084039091018152604c909201835281519181019190912060009081526004909152205460ff16919050565b333014611a4157600080fd5b611a4a84613459565b611a5383613964565b611a5c82613782565b604080516919185a5b1e531a5b5a5d60b21b6020808301919091526000602a83018190528351601e818503018152603e84018086528151918401919091208252918190528381208590559084905291517fca0b3dabefdbd8c72c0a9cf4a6e9d107da897abf036ef3f3f3b010cdd259415991819003605e0190a250505050565b611ae4612a71565b6112d981613782565b6040805172666f726569676e546f6b656e4164647265737360681b60208083019190915260609390931b6001600160601b03191660338201528151808203602701815260479091018252805190830120600090815260029092529020546001600160a01b031690565b306001600160a01b0316636fde82026040518163ffffffff1660e01b815260040160206040518083038186803b158015611b8f57600080fd5b505afa158015611ba3573d6000803e3d6000fd5b505050506040513d6020811015611bb957600080fd5b50516001600160a01b03163314611bcf57600080fd5b826001600160a01b03166369ffa08a83836040518363ffffffff1660e01b815260040180836001600160a01b03168152602001826001600160a01b0316815260200192505050600060405180830381600087803b158015611c2f57600080fd5b505af1158015611c43573d6000803e3d6000fd5b50505050505050565b306001600160a01b0316636fde82026040518163ffffffff1660e01b815260040160206040518083038186803b158015611c8557600080fd5b505afa158015611c99573d6000803e3d6000fd5b505050506040513d6020811015611caf57600080fd5b50516001600160a01b03163314611cc557600080fd5b6001600160a01b0382161580611ce15750611cdf82611516565b155b611cea57600080fd5b6111248282613a48565b611cfc612a71565b6112d9816134d5565b600080611d11836111c7565b90506000611d1e846128ba565b90506000611d2e856113c4611953565b90506000818311611d40576000611d44565b8183035b9050808410611d535780611d55565b835b9695505050505050565b611d67612a71565b611d7082611516565b611d7957600080fd5b611d828261145e565b811180611d8d575080155b611d9657600080fd5b6040805172195e1958dd5d1a5bdb91185a5b1e531a5b5a5d606a1b6020808301919091526001600160601b0319606086901b16603383015282516027818403018152604783018085528151918301919091206000908152918290529083902084905583905290516001600160a01b038416917f4c177b42dbe934b3abbc0208c11a42e46589983431616f1710ab19969c5ed62e919081900360670190a25050565b611e3f612a98565b611e488461304f565b611e558460018585612f25565b61145883858484613a82565b7f98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab988060005260026020527f0c1206883be66049a02d4937078367c00b3d71dd1a9465df969363c6ddeac96d546001600160a01b031690565b7f02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c060005260026020527fb7802e97e87ef2842a6cce7da7ffaeaedaa2f61a6a7870b23d9d01fc9b73712e546001600160a01b031690565b611f17612a71565b6112d981613964565b6000611f2a6123c1565b9050806001600160a01b031663cb08a10c836040518263ffffffff1660e01b81526004018082815260200191505060206040518083038186803b158015611f7057600080fd5b505afa158015611f84573d6000803e3d6000fd5b505050506040513d6020811015611f9a57600080fd5b505115611fa657600080fd5b306001600160a01b0316816001600160a01b0316633f9a8e7e846040518263ffffffff1660e01b81526004018082815260200191505060206040518083038186803b158015611ff457600080fd5b505afa158015612008573d6000803e3d6000fd5b505050506040513d602081101561201e57600080fd5b50516001600160a01b03161461203357600080fd5b61203b611e61565b6001600160a01b0316816001600160a01b0316634a610b04846040518263ffffffff1660e01b81526004018082815260200191505060206040518083038186803b15801561208857600080fd5b505afa15801561209c573d6000803e3d6000fd5b505050506040513d60208110156120b257600080fd5b50516001600160a01b0316146120c757600080fd5b6040805160248082018590528251808303909101815260449091019091526020810180516001600160e01b0316630950d51560e01b9081179091529061210e816001613bef565b5050505050565b60036000809192565b7f5f5bc4e0b888be22a35f2166061a04607296c26861006b9b8e089a172696a82260005260026020527f60072fd9ffad01d76b1d1421ce17a3613dc06795e4b113745995ad1d84a52121546001600160a01b031690565b60408051670dad2dca0cae4a8f60c31b60208083019190915260609390931b6001600160601b03191660288201528151808203601c018152603c909101825280519083012060009081529182905290205490565b60006121d3613e03565b6122265760408051600081526020810190915282518590601411612216576121fa84613e28565b9050601484511115612216578351601319016014850190815291505b6122233387838886613e2f565b50505b5060019392505050565b604080516f746f74616c5370656e7450657244617960801b60208083019190915260609490941b6001600160601b031916603082015260448082019390935281518082039093018352606401815281519183019190912060009081529182905290205490565b6115478383836000806110f3565b604080516861636b4465706c6f7960b81b60208083019190915260609390931b6001600160601b03191660298201528151808203601d018152603d90910182528051908301206000908152600490925290205460ff1690565b600061230882611516565b801561141e5750600061231a83611aed565b6001600160a01b03161492915050565b612332612a98565b600061233d8561164d565b905061234881611516565b61235157600080fd5b61235e8160008686612f25565b61210e84828585613a82565b7f5f86f226cd489cc09187d5f5e0adfb94308af0d4ceac482dd8a8adea9d80daf460005260026020527fab9e97adef29adb9492a44df89badb4a706f8f35202918df21ca61ed056c4868546001600160a01b031690565b7f811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f60005260026020527fb4ed64697d3ef8518241966f7c6f28b0d72f20f51198717d198d2d55076c593d546001600160a01b031690565b306001600160a01b0316636fde82026040518163ffffffff1660e01b815260040160206040518083038186803b15801561245157600080fd5b505afa158015612465573d6000803e3d6000fd5b505050506040513d602081101561247b57600080fd5b50516001600160a01b0316331461249157600080fd5b806001600160a01b0381166124a557600080fd5b6124ae836122fd565b6124b757600080fd5b6000836001600160a01b03166370a08231306040518263ffffffff1660e01b815260040180826001600160a01b0316815260200191505060206040518083038186803b15801561250657600080fd5b505afa15801561251a573d6000803e3d6000fd5b505050506040513d602081101561253057600080fd5b50519050600061253f856114bb565b905080821161254d57600080fd5b808203600061255b87611d05565b90506000811161256a57600080fd5b80821115612576578091505b61258887612582611953565b84613f8f565b604080516000808252602082019092526060916125aa918a908a90879061400d565b905060006125b9826001613bef565b9050611642818a8a87614688565b7f779a349c5bee7817f04c960f525ee3e2f2516078c38c68a3149787976ee837e560005260026020527fc155b21a14c4592b97825e495fbe0d2705fb46420018cac5bfa7a09c43fae517546001600160a01b031690565b612626612a98565b60006126368b8b8b8b8b8b61310b565b90506126458160008787612f25565b61268785828686868080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250613a8292505050565b5050505050505050505050565b61145884848484612910565b6126a8612a71565b6126b182611516565b6126ba57600080fd5b8015806126e057506126cb82612175565b811180156126e057506126dd826128ba565b81105b6126e957600080fd5b60408051670dac2f0a0cae4a8f60c31b60208083019190915260609490941b6001600160601b03191660288201528151808203601c018152603c909101825280519084012060009081529283905290912055565b600061141e8261164d565b7f269c5905f777ee6391c7a361d17039a7d62f52ba9fffeb98c5ade342705731a360005260026020527f15c764a0cd4bb3d72a49abedd3d6793c3b93c0d57f43174a348b443be86f79c1546001600160a01b031690565b6127a7612a71565b6127b082611516565b6127b957600080fd5b6000811180156127d057506127cd826128ba565b81105b80156127e357506127e0826111c7565b81105b6127ec57600080fd5b60408051670dad2dca0cae4a8f60c31b60208083019190915260609490941b6001600160601b03191660288201528151808203601c018152603c909101825280519084012060009081529283905290912055565b6040805172746f74616c457865637574656450657244617960681b60208083019190915260609490941b6001600160601b031916603382015260478082019390935281518082039093018352606701815281519183019190912060009081529182905290205490565b6128b1612a71565b6112d98161380f565b604080516919185a5b1e531a5b5a5d60b21b60208083019190915260609390931b6001600160601b031916602a8201528151808203601e018152603e909101825280519083012060009081529182905290205490565b612918613e03565b1561292257600080fd5b6000846001600160a01b03166370a08231306040518263ffffffff1660e01b815260040180826001600160a01b0316815260200191505060206040518083038186803b15801561297157600080fd5b505afa158015612985573d6000803e3d6000fd5b505050506040513d602081101561299b57600080fd5b505190506129a960016146f8565b6129be6001600160a01b03861633308661471c565b6129c860006146f8565b6000612a4d82876001600160a01b03166370a08231306040518263ffffffff1660e01b815260040180826001600160a01b0316815260200191505060206040518083038186803b158015612a1b57600080fd5b505afa158015612a2f573d6000803e3d6000fd5b505050506040513d6020811015612a4557600080fd5b505190614776565b905083811115612a5c57600080fd5b612a698633878487613e2f565b505050505050565b612a79611eb8565b6001600160a01b0316336001600160a01b031614612a9657600080fd5b565b6000612aa26123c1565b9050336001600160a01b03821614612ab957600080fd5b612ac1611e61565b6001600160a01b0316816001600160a01b031663d67bdd256040518163ffffffff1660e01b815260040160206040518083038186803b158015612b0357600080fd5b505afa158015612b17573d6000803e3d6000fd5b505050506040513d6020811015612b2d57600080fd5b50516001600160a01b0316146112d957600080fd5b604080516b36b2b9b9b0b3b2aa37b5b2b760a11b602080830191909152602c80830185905283518084039091018152604c90920183528151918101919091206000908152600290915220546001600160a01b0316919050565b604080516f1b595cdcd859d9549958da5c1a595b9d60821b602080830191909152603080830185905283518084039091018152605090920183528151918101919091206000908152600290915220546001600160a01b0316919050565b604080516b6d65737361676556616c756560a01b602080830191909152602c80830185905283518084039091018152604c90920183528151918101919091206000908152908190522054919050565b604080516b1b595cdcd859d9519a5e195960a21b602080830191909152602c8083019490945282518083039094018452604c9091018252825192810192909220600090815260049092529020805460ff19166001179055565b6115476000612cae85611aed565b6001600160a01b031614848484856147b8565b612cca8161480c565b612cd357600080fd5b7f811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f60005260026020527fb4ed64697d3ef8518241966f7c6f28b0d72f20f51198717d198d2d55076c593d80546001600160a01b0319166001600160a01b0392909216919091179055565b826001600160a01b03166340c10f1983836040518363ffffffff1660e01b815260040180836001600160a01b0316815260200182815260200192505050602060405180830381600087803b158015612d9457600080fd5b505af1158015612da8573d6000803e3d6000fd5b505050506040513d6020811015612dbe57600080fd5b505161154757600080fd5b604080516f686f6d65546f6b656e4164647265737360801b6020808301919091526001600160601b0319606086811b82166030850152845160248186030181526044850186528051908401206000908152600280855286822080546001600160a01b03808b166001600160a01b0319928316811790935572666f726569676e546f6b656e4164647265737360681b60648a0152948a901b90951660778801528751606b818903018152608b909701808952875197870197909720835294529485208054909216908716908117909155909290917f78d063210f4fb6b4cc932390bb8045fa2465e51349590182dab8b9e84c57a6ee9190a35050565b600082820183811015612f1e576040805162461bcd60e51b815260206004820152601b60248201527f536166654d6174683a206164646974696f6e206f766572666c6f770000000000604482015290519081900360640190fd5b9392505050565b612f2d613e03565b15612f3757600080fd5b612f418482611715565b612f4a57600080fd5b612f5c84612f56611953565b83614848565b806000612f8c7f03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f12625868389866148c9565b90506000612f98614c74565b90508115612fed5760408051838152905182916001600160a01b038a16917fd560a522f77cfb4924d6fe51be1615e540a48a8931c48fe0349c7f47ebabe7479181900360200190a3612fea8383614776565b92505b612ffa86888786886147b8565b80856001600160a01b0316886001600160a01b03167f9afd47907e25028cdaca89d193518c302bbb128617d5a992c5abd45815526593866040518082815260200191505060405180910390a450505050505050565b604080516861636b4465706c6f7960b81b6020808301919091526001600160601b0319606085901b1660298301528251601d818403018152603d909201835281519181019190912060009081526004909152205460ff166112d957604080516861636b4465706c6f7960b81b6020808301919091526001600160601b0319606085901b1660298301528251601d818403018152603d90920183528151918101919091206000908152600490915220805460ff1916600117905550565b6000806131178861164d565b90506001600160a01b0381166133be57606087878080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525050604080516020601f8b01819004810282018101909252898152939450606093925089915088908190840183828082843760009201919091525050845192935050501515806131ac575060008151115b6131b557600080fd5b81516131c3578091506131cc565b80516131cc5750805b6131d582614ce7565b91506131df612748565b6001600160a01b031663a39d6acf8383886131f86123c1565b6001600160a01b0316631544298e6040518163ffffffff1660e01b815260040160206040518083038186803b15801561323057600080fd5b505afa158015613244573d6000803e3d6000fd5b505050506040513d602081101561325a57600080fd5b50516040516001600160e01b031960e087901b16815260ff831660448201526064810182905260806004820190815285516084830152855190918291602482019160a40190602089019080838360005b838110156132c25781810151838201526020016132aa565b50505050905090810190601f1680156132ef5780820380516001836020036101000a031916815260200191505b50838103825286518152865160209182019188019080838360005b8381101561332257818101518382015260200161330a565b50505050905090810190601f16801561334f5780820380516001836020036101000a031916815260200191505b509650505050505050602060405180830381600087803b15801561337257600080fd5b505af1158015613386573d6000803e3d6000fd5b505050506040513d602081101561339c57600080fd5b505192506133aa8a84612dc9565b6133b7838660ff16614d9c565b505061344e565b6133c781611516565b61344e578260ff16816001600160a01b031663313ce5676040518163ffffffff1660e01b815260040160206040518083038186803b15801561340857600080fd5b505afa15801561341c573d6000803e3d6000fd5b505050506040513d602081101561343257600080fd5b505160ff161461344157600080fd5b61344e818460ff16614d9c565b979650505050505050565b6134628161480c565b61346b57600080fd5b7f269c5905f777ee6391c7a361d17039a7d62f52ba9fffeb98c5ade342705731a360005260026020527f15c764a0cd4bb3d72a49abedd3d6793c3b93c0d57f43174a348b443be86f79c180546001600160a01b0319166001600160a01b0392909216919091179055565b7f98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab988060005260026020527f0c1206883be66049a02d4937078367c00b3d71dd1a9465df969363c6ddeac96d80546001600160a01b0319166001600160a01b0392909216919091179055565b604081015115801590613559575060408101516020820151115b8015613569575060208101518151115b61357257600080fd5b8051604080516919185a5b1e531a5b5a5d60b21b602082810191909152606086901b6001600160601b031916602a83018190528351808403601e018152603e8401855280519083012060009081528083528481209590955581860151670dac2f0a0cae4a8f60c31b605e850152606684018290528451605a818603018152607a8501865280519084012086528583528486205583860151670dad2dca0cae4a8f60c31b609a85015260a28401919091528351609681850301815260b690930184528251928201929092208452839052908220556001600160a01b038316907fca0b3dabefdbd8c72c0a9cf4a6e9d107da897abf036ef3f3f3b010cdd25941599083905b60200201516040518082815260200191505060405180910390a25050565b80516020820151106136a457600080fd5b80516040805172195e1958dd5d1a5bdb91185a5b1e531a5b5a5d606a1b602082810191909152606086901b6001600160601b031916603383018190528351808403602701815260478401855280519083012060009081528083528481209590955581860151700caf0cac6eae8d2dedc9ac2f0a0cae4a8f607b1b606785015260788401919091528351606c818503018152608c90930184528251928201929092208452839052908220556001600160a01b038316907f4c177b42dbe934b3abbc0208c11a42e46589983431616f1710ab19969c5ed62e908390613675565b6001600160a01b038116158061379c575061379c8161480c565b6137a557600080fd5b7f5f5bc4e0b888be22a35f2166061a04607296c26861006b9b8e089a172696a82260005260026020527f60072fd9ffad01d76b1d1421ce17a3613dc06795e4b113745995ad1d84a5212180546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160a01b03811661382257600080fd5b7f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e061384b611eb8565b604080516001600160a01b03928316815291841660208301528051918290030190a17f02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c060005260026020527fb7802e97e87ef2842a6cce7da7ffaeaedaa2f61a6a7870b23d9d01fc9b73712e80546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160a01b03811615806138f157506138f18161480c565b6138fa57600080fd5b7f779a349c5bee7817f04c960f525ee3e2f2516078c38c68a3149787976ee837e560005260026020527fc155b21a14c4592b97825e495fbe0d2705fb46420018cac5bfa7a09c43fae51780546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160a01b038116158061397e575061397e8161480c565b61398757600080fd5b7f5f86f226cd489cc09187d5f5e0adfb94308af0d4ceac482dd8a8adea9d80daf460005260026020527fab9e97adef29adb9492a44df89badb4a706f8f35202918df21ca61ed056c486880546001600160a01b0319166001600160a01b0392909216919091179055565b7f0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba60005260046020527f078d888f9b66f3f8bfa10909e31f1e16240db73449f0500afdbbe3a70da457cc805460ff19166001179055565b806001600160a01b038116613a5c57600080fd5b6001600160a01b038316613a7857613a7382614f20565b611547565b6115478383614f2b565b613a8b8461480c565b1561145857836001600160a01b031663db7af85460e01b84848460405160240180846001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b83811015613afa578181015183820152602001613ae2565b50505050905090810190601f168015613b275780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529181526020820180516001600160e01b03166001600160e01b031990991698909817885251815191979096508695509350915081905083835b60208310613b8d5780518252601f199092019160209182019101613b6e565b6001836020036101000a0380198251168184511680821785525050505050509050019150506000604051808303816000865af19150503d8060008114611c43576040519150601f19603f3d011682016040523d82523d6000602084013e611c43565b600080613bfa611e61565b90506000613c0785614fb8565b90506000613c136123c1565b905084613d0c57806001600160a01b03166394643f718488856040518463ffffffff1660e01b815260040180846001600160a01b0316815260200180602001838152602001828103825284818151815260200191508051906020019080838360005b83811015613c8d578181015183820152602001613c75565b50505050905090810190601f168015613cba5780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b158015613cdb57600080fd5b505af1158015613cef573d6000803e3d6000fd5b505050506040513d6020811015613d0557600080fd5b5051611d55565b806001600160a01b031663dc8601b38488856040518463ffffffff1660e01b815260040180846001600160a01b0316815260200180602001838152602001828103825284818151815260200191508051906020019080838360005b83811015613d7f578181015183820152602001613d67565b50505050905090810190601f168015613dac5780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b158015613dcd57600080fd5b505af1158015613de1573d6000803e3d6000fd5b505050506040513d6020811015613df757600080fd5b50519695505050505050565b7f6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e925490565b6014015190565b6001600160a01b03831615801590613e605750613e4a611e61565b6001600160a01b0316836001600160a01b031614155b613e6957600080fd5b613e7285611516565b613e92576000613e81866150ec565b9050613e90868260ff16614d9c565b505b613e9c85836113b1565b613ea557600080fd5b613eb185612582611953565b6000613ebc86611aed565b90506000613ef77f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee266001600160a01b03841615888a886148c9565b90506000613f058583614776565b90506060613f16848a89858961400d565b90506000613f2e82613f298c8c8c6152ba565b613bef565b9050613f3c818b8b86614688565b8315613f835760408051858152905182916001600160a01b038d16917fd560a522f77cfb4924d6fe51be1615e540a48a8931c48fe0349c7f47ebabe7479181900360200190a35b50505050505050505050565b613f9d816113c98585612230565b600080858560405160200180806f746f74616c5370656e7450657244617960801b815250601001836001600160a01b031660601b81526014018281526020019250505060405160208183030381529060405280519060200120815260200190815260200160002081905550505050565b60606000808351118061403257506000356001600160e01b03191663d740548160e01b145b90506001600160a01b0387166144ed5761405886614053866113c98a6114bb565b61536a565b614061866122a4565b1561419e57806140bf57604080516001600160a01b0380891660248301528716604482015260648082018790528251808303909101815260849091019091526020810180516001600160e01b031663125e4cfb60e01b179052614196565b63c534576160e01b8686868660405160240180856001600160a01b03168152602001846001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b8381101561412f578181015183820152602001614117565b50505050905090810190601f16801561415c5780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b03166001600160e01b0319909916989098179097525050505050505b91505061467f565b60006141a9876150ec565b905060606141b6886153c5565b905060606141c38961558b565b90506000825111806141d6575060008151115b6141df57600080fd5b8361433257632ae87cdd60e01b898383868c8c60405160240180876001600160a01b0316815260200180602001806020018660ff168152602001856001600160a01b03168152602001848152602001838103835288818151815260200191508051906020019080838360005b8381101561426357818101518382015260200161424b565b50505050905090810190601f1680156142905780820380516001836020036101000a031916815260200191505b50838103825287518152875160209182019189019080838360005b838110156142c35781810151838201526020016142ab565b50505050905090810190601f1680156142f05780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b03166001600160e01b0319909c169b909b17909a52506144e2975050505050505050565b63d522cfd760e01b898383868c8c8c60405160240180886001600160a01b0316815260200180602001806020018760ff168152602001866001600160a01b031681526020018581526020018060200184810384528a818151815260200191508051906020019080838360005b838110156143b657818101518382015260200161439e565b50505050905090810190601f1680156143e35780820380516001836020036101000a031916815260200191505b5084810383528951815289516020918201918b019080838360005b838110156144165781810151838201526020016143fe565b50505050905090810190601f1680156144435780820380516001836020036101000a031916815260200191505b50848103825285518152855160209182019187019080838360005b8381101561447657818101518382015260200161445e565b50505050905090810190601f1680156144a35780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b03166001600160e01b0319909e169d909d17909c5250505050505050505050505b94505050505061467f565b856001600160a01b03166342966c68856040518263ffffffff1660e01b815260040180828152602001915050600060405180830381600087803b15801561453357600080fd5b505af1158015614547573d6000803e3d6000fd5b50505050806145a457604080516001600160a01b03808a1660248301528716604482015260648082018790528251808303909101815260849091019091526020810180516001600160e01b031663272255bb60e01b17905261467b565b63867f7a4d60e01b8786868660405160240180856001600160a01b03168152602001846001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b838110156146145781810151838201526020016145fc565b50505050905090810190601f1680156146415780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b03166001600160e01b0319909916989098179097525050505050505b9150505b95945050505050565b61469284846156be565b61469c848361572a565b6146a6848261579a565b83826001600160a01b0316846001600160a01b03167f59a9a8027b9c87b961e254899821c9a276b5efc35d1f7409ea4f291470f1629a846040518082815260200191505060405180910390a450505050565b7f6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e9255565b604080516001600160a01b0380861660248301528416604482015260648082018490528251808303909101815260849091019091526020810180516001600160e01b03166323b872dd60e01b1790526114589085906157e9565b6000612f1e83836040518060400160405280601e81526020017f536166654d6174683a207375627472616374696f6e206f766572666c6f77000081525061589a565b84156147ee576147d26001600160a01b0385168484615931565b6147e984614053836147e3886114bb565b90614776565b61210e565b61210e83836147fc87615983565b6001600160a01b03169190612d3d565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061484057508115155b949350505050565b614856816113c98585612840565b6000808585604051602001808072746f74616c457865637574656450657244617960681b815250601301836001600160a01b031660601b81526014018281526020019250505060405160208183030381529060405280519060200120815260200190815260200160002081905550505050565b6000806148d46125c7565b90506001600160a01b03811615614c67577f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26871480156149895750806001600160a01b031663071664c5866040518263ffffffff1660e01b815260040180826001600160a01b0316815260200191505060206040518083038186803b15801561495c57600080fd5b505afa158015614970573d6000803e3d6000fd5b505050506040513d602081101561498657600080fd5b50515b1561499857600091505061467f565b6000816001600160a01b031663710c60138987876040518463ffffffff1660e01b815260040180848152602001836001600160a01b03168152602001828152602001935050505060206040518083038186803b1580156149f757600080fd5b505afa158015614a0b573d6000803e3d6000fd5b505050506040513d6020811015614a2157600080fd5b505190508015614c5e577f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26881415614a6c57614a676001600160a01b0386168383615931565b614bf6565b600087614a80576340c10f1960e01b614a89565b63a9059cbb60e01b5b604080516001600160a01b038681166024830152604480830187905283518084039091018152606490920183526020820180516001600160e01b03166001600160e01b0319861617815292518251949550600094606094928c16939282918083835b60208310614b0a5780518252601f199092019160209182019101614aeb565b6001836020036101000a0380198251168184511680821785525050505050509050019150506000604051808303816000865af19150503d8060008114614b6c576040519150601f19603f3d011682016040523d82523d6000602084013e614b71565b606091505b509150915081614bc8576040805185815290516001600160a01b038a16917fb8842ee9d1603ef0f5620c01feb6cf2e7921091eba728cbce562041a86ee109a919081900360200190a260009550505050505061467f565b80511580614be95750808060200190516020811015614be657600080fd5b50515b614bf257600080fd5b5050505b816001600160a01b0316634e281a7b866040518263ffffffff1660e01b815260040180826001600160a01b03168152602001915050600060405180830381600087803b158015614c4557600080fd5b505af1158015614c59573d6000803e3d6000fd5b505050505b915061467f9050565b5060009695505050505050565b6000614c7e6123c1565b6001600160a01b031663669f618b6040518163ffffffff1660e01b815260040160206040518083038186803b158015614cb657600080fd5b505afa158015614cca573d6000803e3d6000fd5b505050506040513d6020811015614ce057600080fd5b5051905090565b606080827f00000000000000000000000000000000000000000000000000000000000000006040516020018083805190602001908083835b60208310614d3e5780518252601f199092019160209182019101614d1f565b51815160209384036101000a60001901801990921691161790529201938452506040805180850381529390910190525093517f0000000000000000000000000000000000000000000000000000000000000000018452509192915050565b60006012821015614e905781601203600a0a90506000614dc682614dc06000612175565b906159c9565b90506000614dd883614dc060006111c7565b90506000614dea84614dc060006128ba565b90506000614dfc85614dc0600061145e565b90506000614e0e86614dc0600061195c565b905084614e445760019450848411614e445760649350606491508383111580614e375750818111155b15614e4457506127109150815b614e688860405180606001604052808681526020018781526020018881525061353f565b614e8688604051806040016040528084815260200185815250613693565b5050505050611547565b60128203600a0a9050614ee9836040518060600160405280614ebc85614eb660006128ba565b90615a0b565b8152602001614ecf85614eb660006111c7565b8152602001614ee285614eb66000612175565b905261353f565b611547836040518060400160405280614f0685614eb6600061195c565b8152602001614f1985614eb6600061145e565b9052613693565b476111248282615a64565b604080516370a0823160e01b8152306004820152905183916000916001600160a01b038416916370a08231916024808301926020929190829003018186803b158015614f7657600080fd5b505afa158015614f8a573d6000803e3d6000fd5b505050506040513d6020811015614fa057600080fd5b505190506114586001600160a01b0383168483615931565b600080614fc361211e565b90506001600160a01b03811661504857614fdb6123c1565b6001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b15801561501357600080fd5b505afa158015615027573d6000803e3d6000fd5b505050506040513d602081101561503d57600080fd5b5051915061121a9050565b60405163fb47201960e01b81526020600482018181528551602484015285516001600160a01b0385169363fb4720199388939283926044019185019080838360005b838110156150a257818101518382015260200161508a565b50505050905090810190601f1680156150cf5780820380516001836020036101000a031916815260200191505b509250505060206040518083038186803b15801561501357600080fd5b60408051600481526024810182526020810180516001600160e01b031663313ce56760e01b1781529151815160009384936060936001600160a01b03881693919290918291908083835b602083106151555780518252601f199092019160209182019101615136565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d80600081146151b5576040519150601f19603f3d011682016040523d82523d6000602084013e6151ba565b606091505b50915091508161529b5760408051600481526024810182526020810180516001600160e01b0316632e0f262560e01b178152915181516001600160a01b0388169382918083835b602083106152205780518252601f199092019160209182019101615201565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d8060008114615280576040519150601f19603f3d011682016040523d82523d6000602084013e615285565b606091505b5090925090508161529b5760009250505061121a565b8080602001905160208110156152b057600080fd5b5051949350505050565b6000806152c561236a565b90506001600160a01b038116158061467f57506040805163f7baa04960e01b81526001600160a01b03878116600483015286811660248301528581166044830152915160009284169163f7baa049916064808301926020929190829003018186803b15801561533357600080fd5b505afa158015615347573d6000803e3d6000fd5b505050506040513d602081101561535d57600080fd5b5051121595945050505050565b604080516e6d65646961746f7242616c616e636560881b60208083019190915260609490941b6001600160601b031916602f820152815180820360230181526043909101825280519084012060009081529283905290912055565b60408051600481526024810182526020810180516001600160e01b03166306fdde0360e01b1781529151815160609360009385936001600160a01b03881693919290918291908083835b6020831061542e5780518252601f19909201916020918201910161540f565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d806000811461548e576040519150601f19603f3d011682016040523d82523d6000602084013e615493565b606091505b5091509150816155825760408051600481526024810182526020810180516001600160e01b03166351fa6fbf60e11b178152915181516001600160a01b0388169382918083835b602083106154f95780518252601f1990920191602091820191016154da565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d8060008114615559576040519150601f19603f3d011682016040523d82523d6000602084013e61555e565b606091505b5090925090508161558257604051806020016040528060008152509250505061121a565b61484081615ac9565b60408051600481526024810182526020810180516001600160e01b03166395d89b4160e01b1781529151815160609360009385936001600160a01b03881693919290918291908083835b602083106155f45780518252601f1990920191602091820191016155d5565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d8060008114615654576040519150601f19603f3d011682016040523d82523d6000602084013e615659565b606091505b5091509150816155825760408051600481526024810182526020810180516001600160e01b0316631eedf1af60e31b178152915181516001600160a01b038816938291808383602083106154f95780518252601f1990920191602091820191016154da565b604080516b36b2b9b9b0b3b2aa37b5b2b760a11b602080830191909152602c8083019590955282518083039095018552604c90910182528351938101939093206000908152600290935290912080546001600160a01b0319166001600160a01b03909216919091179055565b604080516f1b595cdcd859d9549958da5c1a595b9d60821b60208083019190915260308083019590955282518083039095018552605090910182528351938101939093206000908152600290935290912080546001600160a01b0319166001600160a01b03909216919091179055565b604080516b6d65737361676556616c756560a01b602080830191909152602c8083019590955282518083039095018552604c909101825283519381019390932060009081529283905290912055565b606061583e826040518060400160405280602081526020017f5361666545524332303a206c6f772d6c6576656c2063616c6c206661696c6564815250856001600160a01b0316615c259092919063ffffffff16565b8051909150156115475780806020019051602081101561585d57600080fd5b50516115475760405162461bcd60e51b815260040180806020018281038252602a815260200180615e66602a913960400191505060405180910390fd5b600081848411156159295760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b838110156158ee5781810151838201526020016158d6565b50505050905090810190601f16801561591b5780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b505050900390565b604080516001600160a01b038416602482015260448082018490528251808303909101815260649091019091526020810180516001600160e01b031663a9059cbb60e01b1790526115479084906157e9565b60006001600160a01b03821673b7d311e2eb55f2f68a9440da38e7989210b9a05e14156159c5575073b7d311e2eb55f2f68a9440da38e7989210b9a05e61121a565b5090565b6000612f1e83836040518060400160405280601a81526020017f536166654d6174683a206469766973696f6e206279207a65726f000000000000815250615c34565b600082615a1a5750600061141e565b82820282848281615a2757fe5b0414612f1e5760405162461bcd60e51b8152600401808060200182810382526021815260200180615e456021913960400191505060405180910390fd5b6040516001600160a01b0383169082156108fc029083906000818181858888f19350505050611124578082604051615a9b90615e06565b6001600160a01b039091168152604051908190036020019082f0905080158015611458573d6000803e3d6000fd5b6060602082511115615b9f57818060200190516020811015615aea57600080fd5b8101908080516040519392919084600160201b821115615b0957600080fd5b908301906020820185811115615b1e57600080fd5b8251600160201b811182820188101715615b3757600080fd5b82525081516020918201929091019080838360005b83811015615b64578181015183820152602001615b4c565b50505050905090810190601f168015615b915780820380516001836020036101000a031916815260200191505b50604052505050905061121a565b815160201415615c10576000828060200190516020811015615bc057600080fd5b50516040805160208082528183019092529192506060919060208201818036833701905050905060008260208301525b8215615c055760089290921b91600101615bf0565b8152915061121a9050565b5060408051602081019091526000815261121a565b60606148408484600085615c99565b60008183615c835760405162461bcd60e51b81526020600482018181528351602484015283519092839260449091019190850190808383600083156158ee5781810151838201526020016158d6565b506000838581615c8f57fe5b0495945050505050565b6060615ca48561480c565b615cf5576040805162461bcd60e51b815260206004820152601d60248201527f416464726573733a2063616c6c20746f206e6f6e2d636f6e7472616374000000604482015290519081900360640190fd5b60006060866001600160a01b031685876040518082805190602001908083835b60208310615d345780518252601f199092019160209182019101615d15565b6001836020036101000a03801982511681845116808217855250505050505090500191505060006040518083038185875af1925050503d8060008114615d96576040519150601f19603f3d011682016040523d82523d6000602084013e615d9b565b606091505b50915091508115615daf5791506148409050565b805115615dbf5780518082602001fd5b60405162461bcd60e51b81526020600482018181528651602484015286518793919283926044019190850190808383600083156158ee5781810151838201526020016158d6565b603280615e138339019056fe60806040526040516032380380603283398181016040526020811015602357600080fd5b50516001600160a01b038116fffe536166654d6174683a206d756c7469706c69636174696f6e206f766572666c6f775361666545524332303a204552433230206f7065726174696f6e20646964206e6f742073756363656564a2646970667358221220e8d5914e4628a90bfd037e0dd681437876568a42b6dca2716ef23cd9fd49e72a64736f6c634300070500330000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000a22206f6e20784461692200000000000000000000000000000000000000000000", "nonce": "0x20", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x9bb20cbfa578ec534adf8a59528ca522ec05f7a44a43eeb9d04012d6f27730e9", "blockNumber": "0x77", "transactionIndex": "0x0"}], "totalDifficulty": "0x76ffffffffffffffffffffffffdfca83a5", "transactionsRoot": "0xf07b49b6ab0a0b88c20967eb2068768a9454e6cd3160b42f7e2ebde46b90d3d6"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x50d51f", "blockHash": "0x9bb20cbfa578ec534adf8a59528ca522ec05f7a44a43eeb9d04012d6f27730e9", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x77", "contractAddress": "0xd1fa6c06e1d838bb989640a2c4b8a499fd0ab187", "transactionHash": "0xe479b9e3f37ef68a4649fec5725d0e5df8cc4c530351964b50bc6e26a99bbdb7", "transactionIndex": "0x0", "cumulativeGasUsed": "0x50d51f"}]}
\\xc5946e019b3510e58305b571db89f952a23b4fc326c2cd33c2948e3a0fb06796	118	\\x37daafe452dfa2ac0688ce3067e6b3c9a7b2db989d2da19f7883baa98161f6a6	{"block": {"hash": "0xc5946e019b3510e58305b571db89f952a23b4fc326c2cd33c2948e3a0fb06796", "size": "0x14c2", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x76", "uncles": [], "gasUsed": "0xf8aad", "mixHash": null, "gasLimit": "0x66b9dd", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xdb04d0963abdf9c78c282c217b97ca80b17098550465b0e8e36b1750dc7665b6", "timestamp": "0x60a673a9", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x37daafe452dfa2ac0688ce3067e6b3c9a7b2db989d2da19f7883baa98161f6a6", "sealFields": ["0x8420377be3", "0xb84146a1091dbb3c4673f554aff4751bc026c54cb81aac3d241ec14091ad48660c6f5790f01b9099df0eb25f66463c0e6d48c4ee08d593f380b121b5bb8e07cc172801"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x4ff19dc46437902c866b5de890329d700e297327f182984c5f56be17d2e4eb58", "transactions": [{"to": null, "gas": "0x1f155a", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x0b287ccf1b3f2d332041530b637718414c2a7558051c899d2d29b8f814a16536", "input": "0x60a060405234801561001057600080fd5b506040516111bc3803806111bc8339818101604052606081101561003357600080fd5b508051602080830151604093840151600080546001600160a01b0319166001600160a01b0380851691909117909155855163e5789d0360e01b815295519495929491939086169263e5789d039260048083019392829003018186803b15801561009b57600080fd5b505afa1580156100af573d6000803e3d6000fd5b505050506040513d60208110156100c557600080fd5b50518111156100d357600080fd5b606083901b6001600160601b031916608052600155506001600160a01b03166110956101276000398061045e52806108425280610a3c5280610b145280610deb5280610e275280610f5752506110956000f3fe608060405234801561001057600080fd5b50600436106100cf5760003560e01c8063e3e994171161008c578063f2fde38b11610066578063f2fde38b14610325578063f34220281461034b578063f3b8379114610372578063fb4720191461038f576100cf565b8063e3e9941714610263578063e78cea92146102e1578063ec84fd5e146102e9576100cf565b806334bc2d09146100d457806337dab817146101445780638da5cb5b146101c257806396a8254e146101e6578063be3b625b1461022e578063d313107314610236575b600080fd5b610142600480360360208110156100ea57600080fd5b810190602081018135600160201b81111561010457600080fd5b82018360208201111561011657600080fd5b803590602001918460208302840111600160201b8311171561013757600080fd5b509092509050610433565b005b6101426004803603604081101561015a57600080fd5b6001600160a01b038235169190810190604081016020820135600160201b81111561018457600080fd5b82018360208201111561019657600080fd5b803590602001918460208302840111600160201b831117156101b757600080fd5b509092509050610817565b6101ca6109d9565b604080516001600160a01b039092168252519081900360200190f35b61021c600480360360408110156101fc57600080fd5b5080356001600160e01b03191690602001356001600160a01b03166109e8565b60408051918252519081900360200190f35b61021c610a1c565b6101426004803603604081101561024c57600080fd5b506001600160e01b03198135169060200135610a22565b6101426004803603604081101561027957600080fd5b6001600160a01b038235169190810190604081016020820135600160201b8111156102a357600080fd5b8201836020820111156102b557600080fd5b803590602001918460208302840111600160201b831117156102d657600080fd5b509092509050610ae9565b6101ca610de9565b610142600480360360608110156102ff57600080fd5b506001600160e01b0319813516906001600160a01b036020820135169060400135610e0d565b6101426004803603602081101561033b57600080fd5b50356001600160a01b0316610ee8565b61021c6004803603602081101561036157600080fd5b50356001600160e01b031916610f21565b6101426004803603602081101561038857600080fd5b5035610f3d565b61021c600480360360208110156103a557600080fd5b810190602081018135600160201b8111156103bf57600080fd5b8201836020820111156103d157600080fd5b803590602001918460018302840111600160201b831117156103f257600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550610fec945050505050565b6000546001600160a01b0316331461044a57600080fd5b6007828280831461045a57600080fd5b60007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b1580156104b557600080fd5b505afa1580156104c9573d6000803e3d6000fd5b505050506040513d60208110156104df57600080fd5b5051905060005b8481101561051557818484838181106104fb57fe5b90506020020135111561050d57600080fd5b6001016104e6565b508585600081811061052357fe5b905060200201358686600181811061053757fe5b90506020020135101561054957600080fd5b8585600281811061055657fe5b905060200201358686600381811061056a57fe5b90506020020135101561057c57600080fd5b8585600481811061058957fe5b905060200201358686600581811061059d57fe5b9050602002013510156105af57600080fd5b858560028181106105bc57fe5b90506020020135868660008181106105d057fe5b9050602002013510156105e257600080fd5b858560038181106105ef57fe5b905060200201358686600181811061060357fe5b90506020020135101561061557600080fd5b8585600081811061062257fe5b632ae87cdd60e01b600052600260209081520291909101357f62a9500d3c776e557907e8c4e9d229aaa1558a8f5506186f14b6b6033c73dc9155508585600181811061066a57fe5b63d522cfd760e01b6000526002602081815290910292909201357f0fe9c952e0abfeacd2a15c8b2e9c86d4ce396bb3b22aa6a92bb05dcb330a72fc5550869086908181106106b457fe5b63125e4cfb60e01b600052600260209081520291909101357f9b596a45ce3292dcc0ae4d526137f44a04d3591c7e20f340f6cb69893f71938d5550858560038181106106fc57fe5b63c534576160e01b600052600260209081520291909101357fdecaf0d4210f056c5b5d45994395b1bb92499eaabced50a3f14e30dcb91eb6dc55508585600481811061074457fe5b63272255bb60e01b600052600260209081520291909101357f68f7a009dfc6477288240a635717ee1756983e0e7b020ce91b8ea7ca26abfd1e55508585600581811061078c57fe5b63867f7a4d60e01b600052600260209081520291909101357ffb5f3b053b454d2891c72f995506a0635691ad8230af03a191d1a48e30b02e7d5550858560068181106107d457fe5b630950d51560e01b600052600260209081520291909101357f2fbb309585be3644e71d446e7606807d2350a396c50abf9fd40aa383758edea55550505050505050565b6000546001600160a01b0316331461082e57600080fd5b6002828280831461083e57600080fd5b60007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b15801561089957600080fd5b505afa1580156108ad573d6000803e3d6000fd5b505050506040513d60208110156108c357600080fd5b5051905060005b848110156108f957818484838181106108df57fe5b9050602002013511156108f157600080fd5b6001016108ca565b508585600081811061090757fe5b905060200201358686600181811061091b57fe5b90506020020135101561092d57600080fd5b8585600081811061093a57fe5b6001600160a01b038a1660009081527e9b08b2dd6ebca17ba38eec3968d43de116b034e4c6180c63321ca2a69a13ac6020908152604090912091029290920135909155508585600181811061098b57fe5b6001600160a01b0390991660009081527fdc3367de4ae318686fa43fedfab309e4583980e6e10c84c9fe6b1d85489c1585602090815260409091209902919091013590975550505050505050565b6000546001600160a01b031681565b6001600160e01b0319821660009081526003602090815260408083206001600160a01b038516845290915290205492915050565b60015490565b6000546001600160a01b03163314610a3957600080fd5b807f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b158015610a9357600080fd5b505afa158015610aa7573d6000803e3d6000fd5b505050506040513d6020811015610abd57600080fd5b5051811115610acb57600080fd5b506001600160e01b0319909116600090815260026020526040902055565b6000546001600160a01b03163314610b0057600080fd5b60048282808314610b1057600080fd5b60007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b158015610b6b57600080fd5b505afa158015610b7f573d6000803e3d6000fd5b505050506040513d6020811015610b9557600080fd5b5051905060005b84811015610bcb5781848483818110610bb157fe5b905060200201351115610bc357600080fd5b600101610b9c565b5085856000818110610bd957fe5b9050602002013586866001818110610bed57fe5b905060200201351015610bff57600080fd5b85856002818110610c0c57fe5b9050602002013586866003818110610c2057fe5b905060200201351015610c3257600080fd5b85856002818110610c3f57fe5b9050602002013586866000818110610c5357fe5b905060200201351015610c6557600080fd5b85856003818110610c7257fe5b9050602002013586866001818110610c8657fe5b905060200201351015610c9857600080fd5b85856000818110610ca557fe5b6001600160a01b038a1660009081527ff82d3bc3eb326524ec784f499048e99f7d728f97e7a2f692a8a1bb3c85cafd4560209081526040909120910292909201359091555085856001818110610cf757fe5b6001600160a01b038a1660009081527f7b7fe953d4abfebb3e47c7c30a925fd8b1071924bc736814c55193623d57cedd60209081526040909120910292909201359091555085856002818110610d4957fe5b6001600160a01b038a1660009081527f2175433c11e201b5af00c87b33933460257bfa1f2d0bd31e7b9110a2c40526c360209081526040909120910292909201359091555085856003818110610d9b57fe5b6001600160a01b0390991660009081527f42dbfff0ae36ef1d4a902ec7e6d03352c7913fbcf13711cb82731a9e7ca8ffd6602090815260409091209902919091013590975550505050505050565b7f000000000000000000000000000000000000000000000000000000000000000081565b6000546001600160a01b03163314610e2457600080fd5b807f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b158015610e7e57600080fd5b505afa158015610e92573d6000803e3d6000fd5b505050506040513d6020811015610ea857600080fd5b5051811115610eb657600080fd5b506001600160e01b031990921660009081526003602090815260408083206001600160a01b0390941683529290522055565b6000546001600160a01b03163314610eff57600080fd5b600080546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160e01b03191660009081526002602052604090205490565b6000546001600160a01b03163314610f5457600080fd5b807f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b158015610fae57600080fd5b505afa158015610fc2573d6000803e3d6000fd5b505050506040513d6020811015610fd857600080fd5b5051811115610fe657600080fd5b50600155565b6004810151602482015160e09190911b6001600160e01b0319811660009081526003602090815260408083206001600160a01b03861684529091528120549092908061105757506001600160e01b031982166000908152600260205260409020548061105757506001545b94935050505056fea2646970667358221220225302f1b9da4fc15002ae25aa7b041185f40ed01eceb1cd20728e99374e3c7c64736f6c6343000705003300000000000000000000000073be21733cc5d08e1a14ea9a399fb27db3bef8ff000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de100000000000000000000000000000000000000000000000000000000002dc6c0", "nonce": "0x1f", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xc5946e019b3510e58305b571db89f952a23b4fc326c2cd33c2948e3a0fb06796", "blockNumber": "0x76", "transactionIndex": "0x0"}], "totalDifficulty": "0x75ffffffffffffffffffffffffdfca83a7", "transactionsRoot": "0xd7169ef4235cada832bd95de02685daebf17b4272875883fad2932fe88fe5200"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0xf8aad", "blockHash": "0xc5946e019b3510e58305b571db89f952a23b4fc326c2cd33c2948e3a0fb06796", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x76", "contractAddress": "0xc2f87e37019e227f2be5030aabbcc7eaf136e05c", "transactionHash": "0x0b287ccf1b3f2d332041530b637718414c2a7558051c899d2d29b8f814a16536", "transactionIndex": "0x0", "cumulativeGasUsed": "0xf8aad"}]}
\\x37daafe452dfa2ac0688ce3067e6b3c9a7b2db989d2da19f7883baa98161f6a6	117	\\x277068c567185803522188761b2aa54e94c8e22dfee89f5a0f571273bdaf5602	{"block": {"hash": "0x37daafe452dfa2ac0688ce3067e6b3c9a7b2db989d2da19f7883baa98161f6a6", "size": "0x94b", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x75", "uncles": [], "gasUsed": "0x652e2", "mixHash": null, "gasLimit": "0x66a036", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2f5a330fcc70e9895693ae19503bf34c5224e2aa4de22e80e2826087317f8abb", "timestamp": "0x60a673a3", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x277068c567185803522188761b2aa54e94c8e22dfee89f5a0f571273bdaf5602", "sealFields": ["0x8420377be1", "0xb8415b40424c100d92ed7c826c3284b8dbe97d7a607b888fefe78c435458d48705d63b6071eb1e9c8fd8f7a7ef11639a16786dfa5b679c82e5418fdc3bbf3711fb5d01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x6fad0bac4e73bf872e30f2a053200fc97b284793bb240293cf41f211f8654a27", "transactions": [{"to": null, "gas": "0xca5c4", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xc3d6cdcab1ccd56b86225aadc9ae3d45ba24e08100bea65be8ca3310d28bf1f5", "input": "0x608060405234801561001057600080fd5b506040516106863803806106868339818101604052602081101561003357600080fd5b5051600080546001600160a01b039092166001600160a01b0319909216919091179055610621806100656000396000f3fe608060405234801561001057600080fd5b50600436106100935760003560e01c80638da5cb5b116100665780638da5cb5b1461016e5780638efeb22d14610192578063c98cb30e146101ca578063f2fde38b14610202578063f7baa0491461022857610093565b806324d05aa2146100985780634721ff79146100c85780637060ed89146100f65780638782361914610140575b600080fd5b6100c6600480360360408110156100ae57600080fd5b506001600160a01b0381351690602001351515610260565b005b6100c6600480360360408110156100de57600080fd5b506001600160a01b038135169060200135151561029c565b61012e6004803603606081101561010c57600080fd5b506001600160a01b0381358116916020810135821691604090910135166102cb565b60408051918252519081900360200190f35b6100c66004803603604081101561015657600080fd5b506001600160a01b03813516906020013515156102ee565b610176610324565b604080516001600160a01b039092168252519081900360200190f35b6100c6600480360360608110156101a857600080fd5b506001600160a01b038135811691602081013590911690604001351515610333565b6100c6600480360360608110156101e057600080fd5b506001600160a01b038135811691602081013590911690604001351515610384565b6100c66004803603602081101561021857600080fd5b50356001600160a01b03166103c9565b61012e6004803603606081101561023e57600080fd5b506001600160a01b038135811691602081013582169160409091013516610402565b6001600160a01b03828116141561027657600080fd5b610298826001600160a01b03808461028f576000610293565b6000195b610550565b5050565b6001600160a01b0382811614156102b257600080fd5b6102986001600160a01b0380848461028f576000610293565b600160209081526000938452604080852082529284528284209052825290205481565b6001600160a01b03828116141561030457600080fd5b6102986001600160a01b03836001600160a01b038461028f576000610293565b6000546001600160a01b031681565b6001600160a01b03838116141561034957600080fd5b6001600160a01b03828116141561035f57600080fd5b61037f83836001600160a01b0384610378576000610293565b6001610550565b505050565b6001600160a01b03838116141561039a57600080fd5b6001600160a01b0382811614156103b057600080fd5b61037f836001600160a01b038484610378576000610293565b6000546001600160a01b031633146103e057600080fd5b600080546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160a01b03808416600090815260016020908152604080832093835292815282822090529081205481808212156104ba57506001600160a01b03808616600090815260016020908152604080832088851684528252808320938352929052205480156104745791506105499050565b506001600160a01b03808616600090815260016020908152604080832084845282528083209387168352929052205480156104b25791506105499050565b509050610549565b506001600160a01b0384811660009081527f73df27e0fa8bbb6c6a588f907379871e0f69a2bae64ea632056f6dabc259f362602090815260408083209383529290522054801561050d5791506105499050565b5050506001600160a01b03811660009081527f4233c29e78663f7ecc2ce2bfaada6ca8a0d1dac6601afb2e1235b6fe26bb589e60205260409020545b9392505050565b6000546001600160a01b0316331461056757600080fd5b6001600160a01b03808516600081815260016020908152604080832088861680855290835281842095881680855295835292819020869055805193845290830191909152818101929092526060810183905290517fa999f8c73447a5021a8e358783df77bbe2c90529cadb1fb1ef8f30cd9f9d8c939181900360800190a15050505056fea26469706673582212203e55a70a1bf01a6dc73829b9fbef5f6c563f2c5930f193f9ca7023f875028eea64736f6c63430007050033000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "nonce": "0x1e", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x37daafe452dfa2ac0688ce3067e6b3c9a7b2db989d2da19f7883baa98161f6a6", "blockNumber": "0x75", "transactionIndex": "0x0"}], "totalDifficulty": "0x74ffffffffffffffffffffffffdfca83aa", "transactionsRoot": "0x0c629a3f5a358d8f7857c70a6239e60d0e63bd26c7bade3b7beeb6367223d55b"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x652e2", "blockHash": "0x37daafe452dfa2ac0688ce3067e6b3c9a7b2db989d2da19f7883baa98161f6a6", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x75", "contractAddress": "0x4a4c4759eb3b7abee079f832850cd3d0dc48d927", "transactionHash": "0xc3d6cdcab1ccd56b86225aadc9ae3d45ba24e08100bea65be8ca3310d28bf1f5", "transactionIndex": "0x0", "cumulativeGasUsed": "0x652e2"}]}
\\x277068c567185803522188761b2aa54e94c8e22dfee89f5a0f571273bdaf5602	116	\\xef19e231d89c960767c19a5825696e9f4330aa6928bfaed8437d400fa20428d8	{"block": {"hash": "0x277068c567185803522188761b2aa54e94c8e22dfee89f5a0f571273bdaf5602", "size": "0x1691", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x74", "uncles": [], "gasUsed": "0xfcaa2", "mixHash": null, "gasLimit": "0x668696", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000001000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000010000000000000000000000000000000000000400000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000001000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xe7c96f908031fa7a279c1070104456e2ccb2a7e2d7479938df0507a1f1c431ba", "timestamp": "0x60a673a0", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xef19e231d89c960767c19a5825696e9f4330aa6928bfaed8437d400fa20428d8", "sealFields": ["0x8420377be0", "0xb8419bf5a41aa11ea33f306bdf17bed79778e8c37cac3cf8fb7ae5ed4df9c462e58f743b79abe2ae1c6b4660f66270555a51df30d32e1cea1e376954258bc49522d600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x7c55d5764cfa303fd61d37680bac649240a08b374ebd457670f3834b2c8d70df", "transactions": [{"to": null, "gas": "0x1f9544", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x11d444048eade58215c243a4dae5d1d6f4381bfab7d58c9e622d15bd66e4dd78", "input": "0x60806040523480156200001157600080fd5b506040516200130b3803806200130b833981810160405260a08110156200003757600080fd5b815160208301516040808501805191519395929483019291846401000000008211156200006357600080fd5b9083019060208201858111156200007957600080fd5b82518660208202830111640100000000821117156200009757600080fd5b82525081516020918201928201910280838360005b83811015620000c6578181015183820152602001620000ac565b505050509190910160405250600080546001600160a01b0319166001600160a01b0387161790556020908101925085915084906200010f90839062000273811b620008e017901c565b6200011957600080fd5b50600180546001600160a01b0319166001600160a01b03929092169190911790558151603210156200014a57600080fd5b6200017f7f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26600083815b6020020151620002b0565b620001af7f03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f12625600083600162000174565b60005b82518110156200025257620001e1838281518110620001cd57fe5b60200260200101516200032e60201b60201c565b620001eb57600080fd5b60005b8181101562000248578382815181106200020457fe5b60200260200101516001600160a01b03168482815181106200022257fe5b60200260200101516001600160a01b031614156200023f57600080fd5b600101620001ee565b50600101620001b2565b508151620002689060039060208501906200035d565b5050505050620003de565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470818114801590620002a857508115155b949350505050565b80670de0b6b3a76400008110620002c657600080fd5b60008481526002602090815260408083206001600160a01b03871680855290835292819020600186019055805187815291820185905280517fb8ff7722579ab646299f4f7d3ec42f3aaa482cce1e47d6041e8ca971600455309281900390910190a250505050565b60006001600160a01b038216158015906200035757506001546001600160a01b03838116911614155b92915050565b828054828255906000526020600020908101928215620003b5579160200282015b82811115620003b557825182546001600160a01b0319166001600160a01b039091161782556020909201916001909101906200037e565b50620003c3929150620003c7565b5090565b5b80821115620003c35760008155600101620003c8565b610f1d80620003ee6000396000f3fe608060405234801561001057600080fd5b50600436106100ea5760003560e01c806371e9a8b21161008c578063e9d6c05911610066578063e9d6c05914610273578063f2fde38b146102cb578063f3ce14c2146102f1578063fab19091146102f9576100ea565b806371e9a8b21461023d5780638da5cb5b14610245578063b4be506e1461024d576100ea565b80634e281a7b116100c85780634e281a7b1461018357806368400963146101a95780636d0501f6146101e7578063710c60131461020b576100ea565b8063071664c5146100ef57806310b8075b146101295780634b1a758214610151575b600080fd5b6101156004803603602081101561010557600080fd5b50356001600160a01b0316610301565b604080519115158252519081900360200190f35b61014f6004803603602081101561013f57600080fd5b50356001600160a01b031661035e565b005b61014f6004803603606081101561016757600080fd5b508035906001600160a01b036020820135169060400135610488565b61014f6004803603602081101561019957600080fd5b50356001600160a01b0316610507565b6101d5600480360360408110156101bf57600080fd5b50803590602001356001600160a01b031661063f565b60408051918252519081900360200190f35b6101ef6106f5565b604080516001600160a01b039092168252519081900360200190f35b6101d56004803603606081101561022157600080fd5b508035906001600160a01b036020820135169060400135610704565b6101d561074b565b6101ef610751565b61014f6004803603602081101561026357600080fd5b50356001600160a01b0316610760565b61027b6107fd565b60408051602080825283518183015283519192839290830191858101910280838360005b838110156102b757818101518382015260200161029f565b505050509050019250505060405180910390f35b61014f600480360360208110156102e157600080fd5b50356001600160a01b031661085f565b6101d5610898565b6101d56108bc565b6000805b60035481101561035357826001600160a01b03166003828154811061032657fe5b6000918252602090912001546001600160a01b0316141561034b576001915050610359565b600101610305565b50600090505b919050565b6000546001600160a01b0316331461037557600080fd5b60035460005b8181101561047f57826001600160a01b03166003828154811061039a57fe5b6000918252602090912001546001600160a01b0316141561047757600360018303815481106103c557fe5b600091825260209091200154600380546001600160a01b0390921691839081106103eb57fe5b9060005260206000200160006101000a8154816001600160a01b0302191690836001600160a01b031602179055506003600183038154811061042957fe5b600091825260209091200180546001600160a01b0319169055600380548061044d57fe5b600082815260209020810160001990810180546001600160a01b0319169055019055506104859050565b60010161037b565b50600080fd5b50565b827f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee268114806104d657507f03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f1262581145b6104df57600080fd5b6000546001600160a01b031633146104f657600080fd5b61050184848461091c565b50505050565b6001546001600160a01b0316331461051e57600080fd5b600354604080516370a0823160e01b815230600482015290516000916001600160a01b038516916370a0823191602480820192602092909190829003018186803b15801561056b57600080fd5b505afa15801561057f573d6000803e3d6000fd5b505050506040513d602081101561059557600080fd5b5051905060006105a58284610999565b90506000806105be6105b784876109e4565b8590610a3d565b905080156105d2576105cf85610a7f565b91505b60005b85811015610636578382158015906105ec57508184145b156105fe576105fb8184610a9c565b90505b61062d6003838154811061060e57fe5b6000918252602090912001546001600160a01b038a8116911683610af6565b506001016105d5565b50505050505050565b6000827f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee2681148061068f57507f03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f1262581145b61069857600080fd5b60008481526002602090815260408083206001600160a01b038716845290915290205480156106cc576000190191506106ee565b5060008481526002602090815260408083208380529091529020546000190191505b5092915050565b6001546001600160a01b031681565b60035460009061071657506000610744565b6000610722858561063f565b9050610740670de0b6b3a764000061073a85846109e4565b90610999565b9150505b9392505050565b60035490565b6000546001600160a01b031681565b6000546001600160a01b0316331461077757600080fd5b61078081610b4d565b61078957600080fd5b61079281610301565b1561079c57600080fd5b6003546032116107ab57600080fd5b600380546001810182556000919091527fc2575a0e9e593c00f959f8c92f12db2869c3395a3b0502d05e2516446f71f85b0180546001600160a01b0319166001600160a01b0392909216919091179055565b6060600380548060200260200160405190810160405280929190818152602001828054801561085557602002820191906000526020600020905b81546001600160a01b03168152600190910190602001808311610837575b5050505050905090565b6000546001600160a01b0316331461087657600080fd5b600080546001600160a01b0319166001600160a01b0392909216919091179055565b7f03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f1262581565b7f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee2681565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061091457508115155b949350505050565b80670de0b6b3a7640000811061093157600080fd5b60008481526002602090815260408083206001600160a01b03871680855290835292819020600186019055805187815291820185905280517fb8ff7722579ab646299f4f7d3ec42f3aaa482cce1e47d6041e8ca971600455309281900390910190a250505050565b60006109db83836040518060400160405280601a81526020017f536166654d6174683a206469766973696f6e206279207a65726f000000000000815250610b78565b90505b92915050565b6000826109f3575060006109de565b82820282848281610a0057fe5b04146109db5760405162461bcd60e51b8152600401808060200182810382526021815260200180610e9d6021913960400191505060405180910390fd5b60006109db83836040518060400160405280601e81526020017f536166654d6174683a207375627472616374696f6e206f766572666c6f770000815250610c1a565b600081610a8d436001610a3d565b4081610a9557fe5b0692915050565b6000828201838110156109db576040805162461bcd60e51b815260206004820152601b60248201527f536166654d6174683a206164646974696f6e206f766572666c6f770000000000604482015290519081900360640190fd5b604080516001600160a01b038416602482015260448082018490528251808303909101815260649091019091526020810180516001600160e01b031663a9059cbb60e01b179052610b48908490610c74565b505050565b60006001600160a01b038216158015906109de5750506001546001600160a01b039081169116141590565b60008183610c045760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b83811015610bc9578181015183820152602001610bb1565b50505050905090810190601f168015610bf65780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b506000838581610c1057fe5b0495945050505050565b60008184841115610c6c5760405162461bcd60e51b8152602060048201818152835160248401528351909283926044909101919085019080838360008315610bc9578181015183820152602001610bb1565b505050900390565b6060610cc9826040518060400160405280602081526020017f5361666545524332303a206c6f772d6c6576656c2063616c6c206661696c6564815250856001600160a01b0316610d259092919063ffffffff16565b805190915015610b4857808060200190516020811015610ce857600080fd5b5051610b485760405162461bcd60e51b815260040180806020018281038252602a815260200180610ebe602a913960400191505060405180910390fd5b606061091484846000856060610d3a856108e0565b610d8b576040805162461bcd60e51b815260206004820152601d60248201527f416464726573733a2063616c6c20746f206e6f6e2d636f6e7472616374000000604482015290519081900360640190fd5b60006060866001600160a01b031685876040518082805190602001908083835b60208310610dca5780518252601f199092019160209182019101610dab565b6001836020036101000a03801982511681845116808217855250505050505090500191505060006040518083038185875af1925050503d8060008114610e2c576040519150601f19603f3d011682016040523d82523d6000602084013e610e31565b606091505b50915091508115610e455791506109149050565b805115610e555780518082602001fd5b60405162461bcd60e51b8152602060048201818152865160248401528651879391928392604401919085019080838360008315610bc9578181015183820152602001610bb156fe536166654d6174683a206d756c7469706c69636174696f6e206f766572666c6f775361666545524332303a204552433230206f7065726174696f6e20646964206e6f742073756363656564a2646970667358221220698293eb81753aac11593920aa19142509b026dc0457bcaf0df0dec5ade8658164736f6c63430007050033000000000000000000000000e983692122e45a00bba14454ebf4d00bf71aa245000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000004178babe9e5148c6d5fd431cd72884b07ad855a0", "nonce": "0x1d", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x277068c567185803522188761b2aa54e94c8e22dfee89f5a0f571273bdaf5602", "blockNumber": "0x74", "transactionIndex": "0x0"}], "totalDifficulty": "0x73ffffffffffffffffffffffffdfca83ac", "transactionsRoot": "0x3f69fdf31687f29eb5d44c0f2bf3cdd1d466d43960723ff5fdd3b870f5ccaa71"}, "transaction_receipts": [{"logs": [{"data": "0x741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee260000000000000000000000000000000000000000000000000000000000000000", "topics": ["0xb8ff7722579ab646299f4f7d3ec42f3aaa482cce1e47d6041e8ca97160045530", "0x0000000000000000000000000000000000000000000000000000000000000000"], "address": "0x1def1497df0e103d58fd14c4f8e0365fe5f94423", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0x277068c567185803522188761b2aa54e94c8e22dfee89f5a0f571273bdaf5602", "blockNumber": "0x74", "transactionHash": "0x11d444048eade58215c243a4dae5d1d6f4381bfab7d58c9e622d15bd66e4dd78", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}, {"data": "0x03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f126250000000000000000000000000000000000000000000000000000000000000000", "topics": ["0xb8ff7722579ab646299f4f7d3ec42f3aaa482cce1e47d6041e8ca97160045530", "0x0000000000000000000000000000000000000000000000000000000000000000"], "address": "0x1def1497df0e103d58fd14c4f8e0365fe5f94423", "logType": null, "removed": false, "logIndex": "0x1", "blockHash": "0x277068c567185803522188761b2aa54e94c8e22dfee89f5a0f571273bdaf5602", "blockNumber": "0x74", "transactionHash": "0x11d444048eade58215c243a4dae5d1d6f4381bfab7d58c9e622d15bd66e4dd78", "transactionIndex": "0x0", "transactionLogIndex": "0x1"}], "root": null, "status": "0x1", "gasUsed": "0xfcaa2", "blockHash": "0x277068c567185803522188761b2aa54e94c8e22dfee89f5a0f571273bdaf5602", "logsBloom": "0x00000000000000000000000001000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000010000000000000000000000000000000000000400000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000001000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x74", "contractAddress": "0x1def1497df0e103d58fd14c4f8e0365fe5f94423", "transactionHash": "0x11d444048eade58215c243a4dae5d1d6f4381bfab7d58c9e622d15bd66e4dd78", "transactionIndex": "0x0", "cumulativeGasUsed": "0xfcaa2"}]}
\\xef19e231d89c960767c19a5825696e9f4330aa6928bfaed8437d400fa20428d8	115	\\x319b64206514616ed0ecaedb152a1d7fc675ce53de911a5aa1c60b7851cdd401	{"block": {"hash": "0xef19e231d89c960767c19a5825696e9f4330aa6928bfaed8437d400fa20428d8", "size": "0xc77", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x73", "uncles": [], "gasUsed": "0x92390", "mixHash": null, "gasLimit": "0x666cfc", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xa07ba73de7a99830e551829609e24d17444a02e4d98a37c5c6b327ea8b8eddb2", "timestamp": "0x60a6739d", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x319b64206514616ed0ecaedb152a1d7fc675ce53de911a5aa1c60b7851cdd401", "sealFields": ["0x8420377bdf", "0xb84123b29128f60cc1382173eaa8607de9b171e805b11f2391de9428879c68ac72822dba6b12eb04de240c4f4950bb98c579f5091d60772b5fc817bb371a64ca7f0100"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x58aa98cbed1cb60fe36462181bb5e6880a01ee587502d455c37b25766664a34a", "transactions": [{"to": null, "gas": "0x124720", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x81452b9b07eb53cef6e520a88ea5c10b474d8dbae50a3c2f804a1aa132259f6f", "input": "0x608060405234801561001057600080fd5b506040516109913803806109918339818101604052604081101561003357600080fd5b508051602090910151600080546001600160a01b039384166001600160a01b031991821617909155600180549390921692169190911790556109178061007a6000396000f3fe608060405234801561001057600080fd5b50600436106100575760003560e01c80631fa2195f1461005c5780638da5cb5b14610084578063a39d6acf146100a8578063c1aef4f214610173578063f2fde38b1461017b575b600080fd5b6100826004803603602081101561007257600080fd5b50356001600160a01b03166101a1565b005b61008c6101ec565b604080516001600160a01b039092168252519081900360200190f35b61008c600480360360808110156100be57600080fd5b8101906020810181356401000000008111156100d957600080fd5b8201836020820111156100eb57600080fd5b8035906020019184600183028401116401000000008311171561010d57600080fd5b91939092909160208101903564010000000081111561012b57600080fd5b82018360208201111561013d57600080fd5b8035906020019184600183028401116401000000008311171561015f57600080fd5b919350915060ff81351690602001356101fb565b61008c6102d3565b6100826004803603602081101561019157600080fd5b50356001600160a01b03166102e2565b6000546001600160a01b031633146101b857600080fd5b6101c18161031b565b6101ca57600080fd5b600180546001600160a01b0319166001600160a01b0392909216919091179055565b6000546001600160a01b031681565b6000600160009054906101000a90046001600160a01b03168787878787873360405161022690610357565b6001600160a01b03808a16825260ff8516606083015260808201849052821660a082015260c0602082018181529082018890526040820160e083018a8a80828437600083820152601f01601f1916909101848103835288815260200190508888808284376000838201819052604051601f909201601f19169093018190039d509b50909950505050505050505050f0801580156102c7573d6000803e3d6000fd5b50979650505050505050565b6001546001600160a01b031681565b6000546001600160a01b031633146102f957600080fd5b600080546001600160a01b0319166001600160a01b0392909216919091179055565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061034f57508115155b949350505050565b61057d806103658339019056fe608060405234801561001057600080fd5b5060405161057d38038061057d833981810160405260c081101561003357600080fd5b81516020830180516040519294929383019291908464010000000082111561005a57600080fd5b90830190602082018581111561006f57600080fd5b825164010000000081118282018810171561008957600080fd5b82525081516020918201929091019080838360005b838110156100b657818101518382015260200161009e565b50505050905090810190601f1680156100e35780820380516001836020036101000a031916815260200191505b506040526020018051604051939291908464010000000082111561010657600080fd5b90830190602082018581111561011b57600080fd5b825164010000000081118282018810171561013557600080fd5b82525081516020918201929091019080838360005b8381101561016257818101518382015260200161014a565b50505050905090810190601f16801561018f5780820380516001836020036101000a031916815260200191505b50604081815260208301518382015160609485015163054fd4d560e41b8552925191965094509092916001600160a01b038916916354fd4d5091600480820192600092909190829003018186803b1580156101e957600080fd5b505afa1580156101fd573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f19168201604052602081101561022657600080fd5b810190808051604051939291908464010000000082111561024657600080fd5b90830190602082018581111561025b57600080fd5b825164010000000081118282018810171561027557600080fd5b82525081516020918201929091019080838360005b838110156102a257818101518382015260200161028a565b50505050905090810190601f1680156102cf5780820380516001836020036101000a031916815260200191505b506040525050507f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc88905586519091506103109060009060208901906103e4565b5084516103249060019060208801906103e4565b506002805460ff90951660ff1990951694909417909355600680546001600160a01b039092166001600160a01b03199283168117909155600780549092161790558351602094850120825192850192909220604080517f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f8188015280820194909452606084019190915260808301919091523060a0808401919091528151808403909101815260c090920190528051920191909120600855506104859050565b828054600181600116156101000203166002900490600052602060002090601f01602090048101928261041a5760008555610460565b82601f1061043357805160ff1916838001178555610460565b82800160010185558215610460579182015b82811115610460578251825591602001919060010190610445565b5061046c929150610470565b5090565b5b8082111561046c5760008155600101610471565b60ea806104936000396000f3fe608060405260043610601c5760003560e01c80635c60da1b146061575b60006024608f565b90506001600160a01b038116603857600080fd5b60405136600082376000803683855af43d82016040523d6000833e808015605d573d83f35b3d83fd5b348015606c57600080fd5b506073608f565b604080516001600160a01b039092168252519081900360200190f35b7f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc549056fea2646970667358221220f64904f9f497222eca8798ca4c7cdddb76670c8ec8ec21c0c26eeb47d9e606d764736f6c63430007050033a26469706673582212204ffefcabadf3338cbf5dc4321cda6224988280eae1dc8b0d3f140c2c5ddaff0364736f6c63430007050033000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1000000000000000000000000f16f8cebea74106664032e6b2963b81743484306", "nonce": "0x1c", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xef19e231d89c960767c19a5825696e9f4330aa6928bfaed8437d400fa20428d8", "blockNumber": "0x73", "transactionIndex": "0x0"}], "totalDifficulty": "0x72ffffffffffffffffffffffffdfca83ae", "transactionsRoot": "0x198e0556d125a125ca035bfa25601907f6b4a25924b6e4c5f4ef03563f79cdaf"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x92390", "blockHash": "0xef19e231d89c960767c19a5825696e9f4330aa6928bfaed8437d400fa20428d8", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x73", "contractAddress": "0x36afc8c9283cc866b8eb6a61c6e6862a83cd6ee8", "transactionHash": "0x81452b9b07eb53cef6e520a88ea5c10b474d8dbae50a3c2f804a1aa132259f6f", "transactionIndex": "0x0", "cumulativeGasUsed": "0x92390"}]}
\\x319b64206514616ed0ecaedb152a1d7fc675ce53de911a5aa1c60b7851cdd401	114	\\xc1a66488b6564456edb27f0495c0fbc3cd838b96d3830fd6609d7bb7b1efc211	{"block": {"hash": "0x319b64206514616ed0ecaedb152a1d7fc675ce53de911a5aa1c60b7851cdd401", "size": "0x2194", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x72", "uncles": [], "gasUsed": "0x183d55", "mixHash": null, "gasLimit": "0x665369", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x12c60020acd90950a6f0d0903385a55c95d4c955f6e9cf2cfab66cedbb3710a6", "timestamp": "0x60a6739a", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xc1a66488b6564456edb27f0495c0fbc3cd838b96d3830fd6609d7bb7b1efc211", "sealFields": ["0x8420377bde", "0xb8416bd232d1ecd7e513aa8560be7631794eac8c2ad2f376bf0b2ffa2ab1c62c68325e023460115b8649a68d887bc58c46d2846aca9eddc85790b71a1bdce28d766600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x0d95abf5043f8a17dc1cdb136d0df5f211746309d29ab3d8915ac2bb1b5e017a", "transactions": [{"to": null, "gas": "0x307aaa", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xe7c5de4fd8313746eaa52dfbb519154d41ef58d9a8c9bcee48778dc1b25e7e8d", "input": "0x60806040526006805460a060020a60ff02191690553480156200002157600080fd5b5060405162001e2e38038062001e2e83398101604090815281516020808401519284015160608501519285018051909594909401939092918591859185918491849184916200007691600091860190620002d0565b5081516200008c906001906020850190620002d0565b506002805460ff90921660ff19909216919091179055505060068054600160a060020a03191633179055505050801515620000c657600080fd5b60405180807f454950373132446f6d61696e28737472696e67206e616d652c737472696e672081526020017f76657273696f6e2c75696e7432353620636861696e49642c616464726573732081526020017f766572696679696e67436f6e747261637429000000000000000000000000000081525060520190506040518091039020846040518082805190602001908083835b602083106200017a5780518252601f19909201916020918201910162000159565b51815160209384036101000a600019018019909216911617905260408051929094018290038220828501855260018084527f3100000000000000000000000000000000000000000000000000000000000000928401928352945190965091945090928392508083835b60208310620002045780518252601f199092019160209182019101620001e3565b51815160209384036101000a6000190180199092169116179052604080519290940182900382208282019890985281840196909652606081019690965250608085018690523060a0808701919091528151808703909101815260c09095019081905284519093849350850191508083835b60208310620002965780518252601f19909201916020918201910162000275565b5181516020939093036101000a60001901801990911692169190911790526040519201829003909120600855506200037595505050505050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106200031357805160ff191683800117855562000343565b8280016001018555821562000343579182015b828111156200034357825182559160200191906001019062000326565b506200035192915062000355565b5090565b6200037291905b808211156200035157600081556001016200035c565b90565b611aa980620003856000396000f30060806040526004361061019d5763ffffffff60e060020a60003504166305d2035b81146101a257806306fdde03146101cb578063095ea7b3146102555780630b26cf661461027957806318160ddd1461029c57806323b872dd146102c357806330adf81f146102ed578063313ce567146103025780633644e5151461032d57806339509351146103425780634000aea01461036657806340c10f191461039757806342966c68146103bb57806354fd4d50146103d357806366188463146103e857806369ffa08a1461040c57806370a0823114610433578063715018a614610454578063726600ce146104695780637d64bcb41461048a5780637ecebe001461049f578063859ba28c146104c05780638da5cb5b146105015780638fcbaf0c1461053257806395d89b4114610570578063a457c2d714610585578063a9059cbb146105a9578063b753a98c146105cd578063bb35783b146105f1578063cd5965831461061b578063d73dd62314610630578063dd62ed3e14610654578063f2d5d56b1461067b578063f2fde38b1461069f578063ff9e884d146106c0575b600080fd5b3480156101ae57600080fd5b506101b76106e7565b604080519115158252519081900360200190f35b3480156101d757600080fd5b506101e0610708565b6040805160208082528351818301528351919283929083019185019080838360005b8381101561021a578181015183820152602001610202565b50505050905090810190601f1680156102475780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34801561026157600080fd5b506101b7600160a060020a0360043516602435610796565b34801561028557600080fd5b5061029a600160a060020a03600435166107d9565b005b3480156102a857600080fd5b506102b1610833565b60408051918252519081900360200190f35b3480156102cf57600080fd5b506101b7600160a060020a0360043581169060243516604435610839565b3480156102f957600080fd5b506102b1610a08565b34801561030e57600080fd5b50610317610a2c565b6040805160ff9092168252519081900360200190f35b34801561033957600080fd5b506102b1610a35565b34801561034e57600080fd5b506101b7600160a060020a0360043516602435610a3b565b34801561037257600080fd5b506101b760048035600160a060020a0316906024803591604435918201910135610aa1565b3480156103a357600080fd5b506101b7600160a060020a0360043516602435610bb2565b3480156103c757600080fd5b5061029a600435610cbd565b3480156103df57600080fd5b506101e0610cca565b3480156103f457600080fd5b506101b7600160a060020a0360043516602435610d01565b34801561041857600080fd5b5061029a600160a060020a0360043581169060243516610dde565b34801561043f57600080fd5b506102b1600160a060020a0360043516610e03565b34801561046057600080fd5b5061029a610e1e565b34801561047557600080fd5b506101b7600160a060020a0360043516610e35565b34801561049657600080fd5b506101b7610e49565b3480156104ab57600080fd5b506102b1600160a060020a0360043516610e50565b3480156104cc57600080fd5b506104d5610e62565b6040805167ffffffffffffffff9485168152928416602084015292168183015290519081900360600190f35b34801561050d57600080fd5b50610516610e6d565b60408051600160a060020a039092168252519081900360200190f35b34801561053e57600080fd5b5061029a600160a060020a0360043581169060243516604435606435608435151560ff60a4351660c43560e435610e7c565b34801561057c57600080fd5b506101e06111d0565b34801561059157600080fd5b506101b7600160a060020a036004351660243561122a565b3480156105b557600080fd5b506101b7600160a060020a036004351660243561123d565b3480156105d957600080fd5b5061029a600160a060020a0360043516602435611268565b3480156105fd57600080fd5b5061029a600160a060020a0360043581169060243516604435611278565b34801561062757600080fd5b50610516611289565b34801561063c57600080fd5b506101b7600160a060020a0360043516602435611298565b34801561066057600080fd5b506102b1600160a060020a036004358116906024351661131f565b34801561068757600080fd5b5061029a600160a060020a036004351660243561134a565b3480156106ab57600080fd5b5061029a600160a060020a0360043516611355565b3480156106cc57600080fd5b506102b1600160a060020a0360043581169060243516611375565b60065474010000000000000000000000000000000000000000900460ff1681565b6000805460408051602060026001851615610100026000190190941693909304601f8101849004840282018401909252818152929183018282801561078e5780601f106107635761010080835404028352916020019161078e565b820191906000526020600020905b81548152906001019060200180831161077157829003601f168201915b505050505081565b60006107a28383611392565b90506000198214156107d357336000908152600a60209081526040808320600160a060020a03871684529091528120555b92915050565b600654600160a060020a031633146107f057600080fd5b6107f9816113e6565b151561080457600080fd5b6007805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b60045490565b600080600160a060020a038516151561085157600080fd5b600160a060020a038416151561086657600080fd5b600160a060020a03851660009081526003602052604090205461088f908463ffffffff6113ee16565b600160a060020a0380871660009081526003602052604080822093909355908616815220546108c4908463ffffffff61140016565b600160a060020a038086166000818152600360209081526040918290209490945580518781529051919392891692600080516020611a3e83398151915292918290030190a3600160a060020a03851633146109f257610923853361131f565b9050600019811461098d5761093e818463ffffffff6113ee16565b600160a060020a038616600081815260056020908152604080832033808552908352928190208590558051948552519193600080516020611a5e833981519152929081900390910190a36109f2565b600160a060020a0385166000908152600a6020908152604080832033845290915290205415806109e757506109c061140d565b600160a060020a0386166000908152600a6020908152604080832033845290915290205410155b15156109f257600080fd5b6109fd858585611411565b506001949350505050565b7fea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb81565b60025460ff1681565b60085481565b6000610a478383611448565b336000908152600560209081526040808320600160a060020a038816845290915290205490915060001914156107d357336000908152600a60209081526040808320600160a060020a038716845290915281205592915050565b600084600160a060020a03811615801590610ac55750600160a060020a0381163014155b1515610ad057600080fd5b610ada8686611454565b1515610ae557600080fd5b85600160a060020a031633600160a060020a03167fe19260aff97b920c7df27010903aeb9c8d2be5d310a2c67824cf3f15396e4c16878787604051808481526020018060200182810382528484828181526020019250808284376040519201829003965090945050505050a3610b5a866113e6565b15610ba657610b9b33878787878080601f01602080910402602001604051908101604052809392919081815260200183838082843750611460945050505050565b1515610ba657600080fd5b50600195945050505050565b600654600090600160a060020a03163314610bcc57600080fd5b60065474010000000000000000000000000000000000000000900460ff1615610bf457600080fd5b600454610c07908363ffffffff61140016565b600455600160a060020a038316600090815260036020526040902054610c33908363ffffffff61140016565b600160a060020a038416600081815260036020908152604091829020939093558051858152905191927f0f6798a560793a54c3bcfe86a93cde1e73087d944c0ea20544137d412139688592918290030190a2604080518381529051600160a060020a03851691600091600080516020611a3e8339815191529181900360200190a350600192915050565b610cc733826115dd565b50565b60408051808201909152600181527f3100000000000000000000000000000000000000000000000000000000000000602082015281565b336000908152600560209081526040808320600160a060020a0386168452909152812054808310610d5557336000908152600560209081526040808320600160a060020a0388168452909152812055610d8a565b610d65818463ffffffff6113ee16565b336000908152600560209081526040808320600160a060020a03891684529091529020555b336000818152600560209081526040808320600160a060020a038916808552908352928190205481519081529051929392600080516020611a5e833981519152929181900390910190a35060019392505050565b600654600160a060020a03163314610df557600080fd5b610dff82826116cc565b5050565b600160a060020a031660009081526003602052604090205490565b600654600160a060020a0316331461019d57600080fd5b600754600160a060020a0390811691161490565b6000806000fd5b60096020526000908152604090205481565b600260046000909192565b600654600160a060020a031681565b600080600160a060020a038a161515610e9457600080fd5b600160a060020a0389161515610ea957600080fd5b861580610ebd575086610eba61140d565b11155b1515610ec857600080fd5b8460ff16601b1480610edd57508460ff16601c145b1515610ee857600080fd5b7f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0831115610f1557600080fd5b600854604080517fea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb602080830191909152600160a060020a03808f16838501528d166060830152608082018c905260a082018b905289151560c0808401919091528351808403909101815260e090920192839052815191929182918401908083835b60208310610fb65780518252601f199092019160209182019101610f97565b51815160209384036101000a6000190180199092169116179052604080519290940182900382207f190100000000000000000000000000000000000000000000000000000000000083830152602283019790975260428083019790975283518083039097018752606290910192839052855192945084935085019190508083835b602083106110565780518252601f199092019160209182019101611037565b51815160209384036101000a600019018019909216911617905260408051929094018290038220600080845283830180875282905260ff8d1684870152606084018c9052608084018b905294519098506001965060a080840196509194601f19820194509281900390910191865af11580156110d6573d6000803e3d6000fd5b50505060206040510351600160a060020a03168a600160a060020a03161415156110ff57600080fd5b600160a060020a038a166000908152600960205260409020805460018101909155881461112b57600080fd5b8561113757600061113b565b6000195b600160a060020a03808c166000908152600560209081526040808320938e16835292905220819055905085611171576000611173565b865b600160a060020a03808c166000818152600a60209081526040808320948f1680845294825291829020949094558051858152905192939192600080516020611a5e833981519152929181900390910190a350505050505050505050565b60018054604080516020600284861615610100026000190190941693909304601f8101849004840282018401909252818152929183018282801561078e5780601f106107635761010080835404028352916020019161078e565b60006112368383610d01565b9392505050565b60006112498383611454565b151561125457600080fd5b61125f338484611411565b50600192915050565b611273338383610839565b505050565b611283838383610839565b50505050565b600754600160a060020a031690565b336000908152600560209081526040808320600160a060020a03861684529091528120546112cc908363ffffffff61140016565b336000818152600560209081526040808320600160a060020a038916808552908352928190208590558051948552519193600080516020611a5e833981519152929081900390910190a350600192915050565b600160a060020a03918216600090815260056020908152604080832093909416825291909152205490565b611273823383610839565b600654600160a060020a0316331461136c57600080fd5b610cc78161170a565b600a60209081526000928352604080842090915290825290205481565b336000818152600560209081526040808320600160a060020a03871680855290835281842086905581518681529151939490939092600080516020611a5e833981519152928290030190a350600192915050565b6000903b1190565b6000828211156113fa57fe5b50900390565b818101828110156107d357fe5b4290565b61141a82610e35565b156112735760408051600081526020810190915261143d90849084908490611460565b151561127357600080fd5b60006112368383611298565b60006112368383611788565b600083600160a060020a031663a4c0ed3660e060020a028685856040516024018084600160a060020a0316600160a060020a0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b838110156114d85781810151838201526020016114c0565b50505050905090810190601f1680156115055780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529181526020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167fffffffff00000000000000000000000000000000000000000000000000000000909916989098178852518151919790965086955093509150819050838360005b8381101561159357818101518382015260200161157b565b50505050905090810190601f1680156115c05780820380516001836020036101000a031916815260200191505b509150506000604051808303816000865af1979650505050505050565b600160a060020a03821660009081526003602052604090205481111561160257600080fd5b600160a060020a03821660009081526003602052604090205461162b908263ffffffff6113ee16565b600160a060020a038316600090815260036020526040902055600454611657908263ffffffff6113ee16565b600455604080518281529051600160a060020a038416917fcc16f5dbb4873280815c1ee09dbd06736cffcc184412cf7a71a0fdb75d397ca5919081900360200190a2604080518281529051600091600160a060020a03851691600080516020611a3e8339815191529181900360200190a35050565b80600160a060020a03811615156116e257600080fd5b600160a060020a0383161515611700576116fb82611857565b611273565b6112738383611863565b600160a060020a038116151561171f57600080fd5b600654604051600160a060020a038084169216907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a36006805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b336000908152600360205260408120548211156117a457600080fd5b600160a060020a03831615156117b957600080fd5b336000908152600360205260409020546117d9908363ffffffff6113ee16565b3360009081526003602052604080822092909255600160a060020a0385168152205461180b908363ffffffff61140016565b600160a060020a038416600081815260036020908152604091829020939093558051858152905191923392600080516020611a3e8339815191529281900390910190a350600192915050565b3031610dff8282611910565b604080517f70a0823100000000000000000000000000000000000000000000000000000000815230600482015290518391600091600160a060020a038416916370a0823191602480830192602092919082900301818787803b1580156118c857600080fd5b505af11580156118dc573d6000803e3d6000fd5b505050506040513d60208110156118f257600080fd5b50519050611283600160a060020a038516848363ffffffff61197816565b604051600160a060020a0383169082156108fc029083906000818181858888f193505050501515610dff578082611945611a0d565b600160a060020a039091168152604051908190036020019082f080158015611971573d6000803e3d6000fd5b5050505050565b82600160a060020a031663a9059cbb83836040518363ffffffff1660e060020a0281526004018083600160a060020a0316600160a060020a0316815260200182815260200192505050600060405180830381600087803b1580156119db57600080fd5b505af11580156119ef573d6000803e3d6000fd5b505050503d156112735760206000803e600051151561127357600080fd5b604051602180611a1d833901905600608060405260405160208060218339810160405251600160a060020a038116ff00ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925a165627a7a723058202868d22f1d55ff8de23e437047d596d9719a8126999958de569af1ac09beb8460029000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000232500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "nonce": "0x1b", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x319b64206514616ed0ecaedb152a1d7fc675ce53de911a5aa1c60b7851cdd401", "blockNumber": "0x72", "transactionIndex": "0x0"}], "totalDifficulty": "0x71ffffffffffffffffffffffffdfca83b0", "transactionsRoot": "0x19016e58011129e38356a63d53b64748809d85b05a2e79c878e06568abcb264b"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x183d55", "blockHash": "0x319b64206514616ed0ecaedb152a1d7fc675ce53de911a5aa1c60b7851cdd401", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x72", "contractAddress": "0xf16f8cebea74106664032e6b2963b81743484306", "transactionHash": "0xe7c5de4fd8313746eaa52dfbb519154d41ef58d9a8c9bcee48778dc1b25e7e8d", "transactionIndex": "0x0", "cumulativeGasUsed": "0x183d55"}]}
\\xc1a66488b6564456edb27f0495c0fbc3cd838b96d3830fd6609d7bb7b1efc211	113	\\x0eb2ffe635e5c07c858af44a109bafc3ec04806926ba5ba4c501e96fdfd2cf1d	{"block": {"hash": "0xc1a66488b6564456edb27f0495c0fbc3cd838b96d3830fd6609d7bb7b1efc211", "size": "0x7bc", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x71", "uncles": [], "gasUsed": "0x52aca", "mixHash": null, "gasLimit": "0x6639dc", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x3016250b9c2984e1d42e4fc3ca814047c091d2a57b17c7bbc3b8dff720c2376a", "timestamp": "0x60a67397", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x0eb2ffe635e5c07c858af44a109bafc3ec04806926ba5ba4c501e96fdfd2cf1d", "sealFields": ["0x8420377bdd", "0xb8410718aa2f1589a790dcfb7ccd711122e58efed94ab9b9684b9a2d40ce2fed00653d15f8af18c324c58901ee8aca55c3c4d44811e5635525e238eefcb2e8f74ba800"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0xe8f1297a9e607c18adad156d9527c574f85065ac02912f86c365c570774543d0", "transactions": [{"to": null, "gas": "0xa5594", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x20650772c8f39ec8aad2c0ea594592db6502cf3bef862c8fea68f1792a59c0fd", "input": "0x608060405234801561001057600080fd5b5061001a3361001f565b610041565b600680546001600160a01b0319166001600160a01b0392909216919091179055565b6104c6806100506000396000f3fe6080604052600436106100555760003560e01c80633ad06d161461009e57806354fd4d50146100d95780635c60da1b146101005780636fde820214610131578063a9c45fcb14610146578063f1739cae146101cb575b600061005f6101fe565b90506001600160a01b03811661007457600080fd5b60405136600082376000803683855af43d82016040523d6000833e80801561009a573d83f35b3d83fd5b3480156100aa57600080fd5b506100d7600480360360408110156100c157600080fd5b50803590602001356001600160a01b031661020d565b005b3480156100e557600080fd5b506100ee610240565b60408051918252519081900360200190f35b34801561010c57600080fd5b506101156101fe565b604080516001600160a01b039092168252519081900360200190f35b34801561013d57600080fd5b50610115610246565b6100d76004803603606081101561015c57600080fd5b8135916001600160a01b036020820135169181019060608101604082013564010000000081111561018c57600080fd5b82018360208201111561019e57600080fd5b803590602001918460018302840111640100000000831117156101c057600080fd5b509092509050610255565b3480156101d757600080fd5b506100d7600480360360208110156101ee57600080fd5b50356001600160a01b03166102fe565b600061020861038d565b905090565b610215610246565b6001600160a01b0316336001600160a01b03161461023257600080fd5b61023c828261039c565b5050565b60075490565b6006546001600160a01b031690565b61025d610246565b6001600160a01b0316336001600160a01b03161461027a57600080fd5b610284848461020d565b6000306001600160a01b0316348484604051808383808284376040519201945060009350909150508083038185875af1925050503d80600081146102e4576040519150601f19603f3d011682016040523d82523d6000602084013e6102e9565b606091505b50509050806102f757600080fd5b5050505050565b610306610246565b6001600160a01b0316336001600160a01b03161461032357600080fd5b6001600160a01b03811661033657600080fd5b7f5a3e66efaa1e445ebd894728a69d6959842ea1e97bd79b892797106e270efcd961035f610246565b604080516001600160a01b03928316815291841660208301528051918290030190a161038a81610432565b50565b6008546001600160a01b031690565b6008546001600160a01b03828116911614156103b757600080fd5b6103c081610454565b6103c957600080fd5b60075482116103d757600080fd5b6007829055600880546001600160a01b0383166001600160a01b031990911681179091556040805184815290517f4289d6195cf3c2d2174adf98d0e19d4d2d08887995b99cb7b100e7ffe795820e9181900360200190a25050565b600680546001600160a01b0319166001600160a01b0392909216919091179055565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061048857508115155b94935050505056fea2646970667358221220d9973dddb90f377ca5b26b72075526ad86c08bc9ef57e825e4a7a45e638fa23064736f6c63430007050033", "nonce": "0x1a", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xc1a66488b6564456edb27f0495c0fbc3cd838b96d3830fd6609d7bb7b1efc211", "blockNumber": "0x71", "transactionIndex": "0x0"}], "totalDifficulty": "0x70ffffffffffffffffffffffffdfca83b2", "transactionsRoot": "0x55e22859d657510ba264528f40abf29f09ea1515130bfb8c859a8e66f234d54e"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x52aca", "blockHash": "0xc1a66488b6564456edb27f0495c0fbc3cd838b96d3830fd6609d7bb7b1efc211", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x71", "contractAddress": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "transactionHash": "0x20650772c8f39ec8aad2c0ea594592db6502cf3bef862c8fea68f1792a59c0fd", "transactionIndex": "0x0", "cumulativeGasUsed": "0x52aca"}]}
\\x0eb2ffe635e5c07c858af44a109bafc3ec04806926ba5ba4c501e96fdfd2cf1d	112	\\x33cc73673175111ec66e1d6f3a0a96c6ffd8fdbe281631fdf60ccfe1443400d0	{"block": {"hash": "0x0eb2ffe635e5c07c858af44a109bafc3ec04806926ba5ba4c501e96fdfd2cf1d", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x70", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x662055", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x756635e8bb0355c642800a4c8992f1c59ab562502078d3cd61e0cf46812df604", "timestamp": "0x60a67391", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x33cc73673175111ec66e1d6f3a0a96c6ffd8fdbe281631fdf60ccfe1443400d0", "sealFields": ["0x8420377bdb", "0xb841c6a885071ebab886e20d3d76c910fda4becf1fd3ab19f4df3f0992d6e77e832b549734744d2a4ccc65b0b865be7a6db72c57ded8c89e036e82d106f01b29ab1701"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x6fffffffffffffffffffffffffdfca83b5", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x33cc73673175111ec66e1d6f3a0a96c6ffd8fdbe281631fdf60ccfe1443400d0	111	\\x3e3700d700e14964b8e2db3d17f863618f80b4cb969d00e5fb8dedba27a1289f	{"block": {"hash": "0x33cc73673175111ec66e1d6f3a0a96c6ffd8fdbe281631fdf60ccfe1443400d0", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x6f", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6606d5", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x756635e8bb0355c642800a4c8992f1c59ab562502078d3cd61e0cf46812df604", "timestamp": "0x60a6738e", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x3e3700d700e14964b8e2db3d17f863618f80b4cb969d00e5fb8dedba27a1289f", "sealFields": ["0x8420377bda", "0xb84177a0ba9760e07e4070e4aa0ffd8e2ed7689cf9b36331390660f415085b3cd6c84e48d058e950fc952af372afc5df6356e88196ef6c11484b6853a71202184cde00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x6effffffffffffffffffffffffdfca83b7", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x3e3700d700e14964b8e2db3d17f863618f80b4cb969d00e5fb8dedba27a1289f	110	\\x2ad47a72becd1fbdd335d5d0ef7e10bea2a9e88d0222201ea563ac2d31aa2d7d	{"block": {"hash": "0x3e3700d700e14964b8e2db3d17f863618f80b4cb969d00e5fb8dedba27a1289f", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x6e", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x65ed5b", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x756635e8bb0355c642800a4c8992f1c59ab562502078d3cd61e0cf46812df604", "timestamp": "0x60a6738b", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x2ad47a72becd1fbdd335d5d0ef7e10bea2a9e88d0222201ea563ac2d31aa2d7d", "sealFields": ["0x8420377bd9", "0xb8418a693ac3d4daf8cf6cb7b603af0ae49b56ebd41dd312278244738a98baca62943d096ee173c34ab71d1a69b31cf7aeaa19645e5411898a8f1eb18c4f4c391a6101"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x6dffffffffffffffffffffffffdfca83b9", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x2ad47a72becd1fbdd335d5d0ef7e10bea2a9e88d0222201ea563ac2d31aa2d7d	109	\\x9fb3195cb4bfcd69b79d3660021b9ccf21885eb9be2d6f32587dd662a5ef24ca	{"block": {"hash": "0x2ad47a72becd1fbdd335d5d0ef7e10bea2a9e88d0222201ea563ac2d31aa2d7d", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x6d", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x65d3e8", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x756635e8bb0355c642800a4c8992f1c59ab562502078d3cd61e0cf46812df604", "timestamp": "0x60a67388", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x9fb3195cb4bfcd69b79d3660021b9ccf21885eb9be2d6f32587dd662a5ef24ca", "sealFields": ["0x8420377bd8", "0xb8417260f76c47ed0437a05104a25f3ddae2441a9cc284d6a39ead7bd0061294bb2a78b35dd8b5f83a76c903505194ac9094ed24422a5a83b00eb0a631cc80d2b55000"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x6cffffffffffffffffffffffffdfca83bb", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x9fb3195cb4bfcd69b79d3660021b9ccf21885eb9be2d6f32587dd662a5ef24ca	108	\\x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f	{"block": {"hash": "0x9fb3195cb4bfcd69b79d3660021b9ccf21885eb9be2d6f32587dd662a5ef24ca", "size": "0x2d6", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x6c", "uncles": [], "gasUsed": "0x7989", "mixHash": null, "gasLimit": "0x65ba7b", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000800000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200", "stateRoot": "0x756635e8bb0355c642800a4c8992f1c59ab562502078d3cd61e0cf46812df604", "timestamp": "0x60a67385", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f", "sealFields": ["0x8420377bd7", "0xb8416abfe0acd482106e10785dee336a8322f0fe8d085477dd72d671c976f30e42870773f8347cef09326b62f5badcfafb38f61023ae8fb752e73d46f238f34ea27d01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x8a1954cebaac9a2d513768a885c85e39fcd8d067367e0c751c35a001f613ba94", "transactions": [{"to": "0x41b89db86be735c03a9296437e39f5fdadc4c678", "gas": "0xf312", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xe476ca24250c9dd91e065a200f492112c3c789ab91e47e4f060ef5387de81ec7", "input": "0xf1739cae000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "nonce": "0x19", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x9fb3195cb4bfcd69b79d3660021b9ccf21885eb9be2d6f32587dd662a5ef24ca", "blockNumber": "0x6c", "transactionIndex": "0x0"}], "totalDifficulty": "0x6bffffffffffffffffffffffffdfca83bd", "transactionsRoot": "0x55067adafa0cee2e49f251dd9624b8bd7c02c683299e110012f042f7d1029c4f"}, "transaction_receipts": [{"logs": [{"data": "0x0000000000000000000000004178babe9e5148c6d5fd431cd72884b07ad855a0000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "topics": ["0x5a3e66efaa1e445ebd894728a69d6959842ea1e97bd79b892797106e270efcd9"], "address": "0x41b89db86be735c03a9296437e39f5fdadc4c678", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0x9fb3195cb4bfcd69b79d3660021b9ccf21885eb9be2d6f32587dd662a5ef24ca", "blockNumber": "0x6c", "transactionHash": "0xe476ca24250c9dd91e065a200f492112c3c789ab91e47e4f060ef5387de81ec7", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}], "root": null, "status": "0x1", "gasUsed": "0x7989", "blockHash": "0x9fb3195cb4bfcd69b79d3660021b9ccf21885eb9be2d6f32587dd662a5ef24ca", "logsBloom": "0x00000000000800000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200", "blockNumber": "0x6c", "contractAddress": null, "transactionHash": "0xe476ca24250c9dd91e065a200f492112c3c789ab91e47e4f060ef5387de81ec7", "transactionIndex": "0x0", "cumulativeGasUsed": "0x7989"}]}
\\x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f	107	\\x5d08464d36be385afb6aa9e7b727022aa376e880506806c47baf581d486eb79e	{"block": {"hash": "0x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f", "size": "0x41c", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x6b", "uncles": [], "gasUsed": "0x42b08", "mixHash": null, "gasLimit": "0x65a114", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000400400000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000200080000000000000000000000000000000000000000000000000000000000000000000000000100000000000200", "stateRoot": "0xcd52c2864ac67e8198847d641fff7c346be80748481470cbb5101319761a618a", "timestamp": "0x60a6737f", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x5d08464d36be385afb6aa9e7b727022aa376e880506806c47baf581d486eb79e", "sealFields": ["0x8420377bd5", "0xb8415ef3ed62a70319d941aefe6a771713b5a8f4e93c6b35d03988d6b290503d3f2b5b98965ee756330b3be798bf98565a72a9c6894d3423638b0a20fed2c9385a5001"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0xa2c2f7244f49650e356cd3505cef9f07cd2078bfb95a8e1749a3856e13667092", "transactions": [{"to": "0x41b89db86be735c03a9296437e39f5fdadc4c678", "gas": "0x87448", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x1b8c98278fc0a7594cae988255ebd4b056766b163680a245f2203b1560a53342", "input": "0xc0b0d02200000000000000000000000073be21733cc5d08e1a14ea9a399fb27db3bef8ff000000000000000000000000edd2aa644a6843f2e5133fe3d6bd3f4080d97d9f00000000000000000000000067dda81caa260dd5a972f16fa3dae114b11505f70000000000000000000000000000000000000000000c685fa11e01ec6f000000000000000000000000000000000000000000000000009ed194db19b238c0000000000000000000000000000000000000000000000000000006f05b59d3b200000000000000000000000000000000000000000000000c685fa11e01ec6f000000000000000000000000000000000000000000000000009ed194db19b238c0000000000000000000000000000000000000000000000000000000000000000493e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "nonce": "0x18", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f", "blockNumber": "0x6b", "transactionIndex": "0x0"}], "totalDifficulty": "0x6affffffffffffffffffffffffdfca83c0", "transactionsRoot": "0x26a7b85f5bdb1ac859c758ea1b28e745b9421418c407b824b67891bf9519a255"}, "transaction_receipts": [{"logs": [{"data": "0x0000000000000000000000000000000000000000000c685fa11e01ec6f000000", "topics": ["0xad4123ae17c414d9c6d2fec478b402e6b01856cc250fd01fbfd252fda0089d3c"], "address": "0x41b89db86be735c03a9296437e39f5fdadc4c678", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f", "blockNumber": "0x6b", "transactionHash": "0x1b8c98278fc0a7594cae988255ebd4b056766b163680a245f2203b1560a53342", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}, {"data": "0x0000000000000000000000000000000000000000000c685fa11e01ec6f000000", "topics": ["0x9bebf928b90863f24cc31f726a3a7545efd409f1dcf552301b1ee3710da70d3b"], "address": "0x41b89db86be735c03a9296437e39f5fdadc4c678", "logType": null, "removed": false, "logIndex": "0x1", "blockHash": "0x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f", "blockNumber": "0x6b", "transactionHash": "0x1b8c98278fc0a7594cae988255ebd4b056766b163680a245f2203b1560a53342", "transactionIndex": "0x0", "transactionLogIndex": "0x1"}, {"data": "0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "topics": ["0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0"], "address": "0x41b89db86be735c03a9296437e39f5fdadc4c678", "logType": null, "removed": false, "logIndex": "0x2", "blockHash": "0x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f", "blockNumber": "0x6b", "transactionHash": "0x1b8c98278fc0a7594cae988255ebd4b056766b163680a245f2203b1560a53342", "transactionIndex": "0x0", "transactionLogIndex": "0x2"}], "root": null, "status": "0x1", "gasUsed": "0x42b08", "blockHash": "0x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f", "logsBloom": "0x00000000000000000000000000000000000000000000000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000010000000000000000000000000000000000000000000000000400400000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000200080000000000000000000000000000000000000000000000000000000000000000000000000100000000000200", "blockNumber": "0x6b", "contractAddress": null, "transactionHash": "0x1b8c98278fc0a7594cae988255ebd4b056766b163680a245f2203b1560a53342", "transactionIndex": "0x0", "cumulativeGasUsed": "0x42b08"}]}
\\x5d08464d36be385afb6aa9e7b727022aa376e880506806c47baf581d486eb79e	106	\\x7222d740c34004e0b532ad5df04bb130ed9710ca4de8274a1b6851f03e0de1f9	{"block": {"hash": "0x5d08464d36be385afb6aa9e7b727022aa376e880506806c47baf581d486eb79e", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x6a", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6587b4", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x727dbfe66fa45fc85fb5b0819dca7192bfd8d491c257c8f2af0b74ef37fa5377", "timestamp": "0x60a6737c", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x7222d740c34004e0b532ad5df04bb130ed9710ca4de8274a1b6851f03e0de1f9", "sealFields": ["0x8420377bd4", "0xb841c79290ed3d3260613c85373163a3eb20a7fb55209074ae656a4cb7abca6a87945ff5909e5fbed54fb2333d75174725b30c2a192a22e484cddda052907ae1efae01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x69ffffffffffffffffffffffffdfca83c2", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x7222d740c34004e0b532ad5df04bb130ed9710ca4de8274a1b6851f03e0de1f9	105	\\xd6ad5639370542f349d3f3a1b0e02073fc1cbda82a47037e4e78ca011d08e969	{"block": {"hash": "0x7222d740c34004e0b532ad5df04bb130ed9710ca4de8274a1b6851f03e0de1f9", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x69", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x656e5a", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x727dbfe66fa45fc85fb5b0819dca7192bfd8d491c257c8f2af0b74ef37fa5377", "timestamp": "0x60a67379", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xd6ad5639370542f349d3f3a1b0e02073fc1cbda82a47037e4e78ca011d08e969", "sealFields": ["0x8420377bd3", "0xb841d476aa39b655f23720bd8da67ed2cd41776eef7b8eb81d52bab9706aa9a554877ef48fa3e920beb02eeeae74f30e4970d379b9261ac160a3c9e9b82a4f0dc00001"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x68ffffffffffffffffffffffffdfca83c4", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xd6ad5639370542f349d3f3a1b0e02073fc1cbda82a47037e4e78ca011d08e969	104	\\x9a591a7401cf0fe57bc0eff3040d5acd1b071b176e294bb307f738a66dfe57e2	{"block": {"hash": "0xd6ad5639370542f349d3f3a1b0e02073fc1cbda82a47037e4e78ca011d08e969", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x68", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x655506", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x727dbfe66fa45fc85fb5b0819dca7192bfd8d491c257c8f2af0b74ef37fa5377", "timestamp": "0x60a67376", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x9a591a7401cf0fe57bc0eff3040d5acd1b071b176e294bb307f738a66dfe57e2", "sealFields": ["0x8420377bd2", "0xb8414a4578180d460c7e6e82aedee2ffc9c8da51aeba5d8ddb0476db099063b6ffb1315f1038ee95c504bda5ee5c8f617ec48c67e4e9ebfb625e218eb1c8bff9c50201"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x67ffffffffffffffffffffffffdfca83c6", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x9a591a7401cf0fe57bc0eff3040d5acd1b071b176e294bb307f738a66dfe57e2	103	\\x3bf5863f91a2a59433547dce0a45b3514fbf5a2b058c907ceb6292c3936660c5	{"block": {"hash": "0x9a591a7401cf0fe57bc0eff3040d5acd1b071b176e294bb307f738a66dfe57e2", "size": "0x2d6", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x67", "uncles": [], "gasUsed": "0x7c25", "mixHash": null, "gasLimit": "0x653bb9", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000001040000000000000000000000000020000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000008000000000000000000000000000000000000000000000000080000000000020000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000010", "stateRoot": "0x727dbfe66fa45fc85fb5b0819dca7192bfd8d491c257c8f2af0b74ef37fa5377", "timestamp": "0x60a67373", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x3bf5863f91a2a59433547dce0a45b3514fbf5a2b058c907ceb6292c3936660c5", "sealFields": ["0x8420377bd1", "0xb841b971b03acc4fa3ae8a3621fc8e32a49165231d638645953acdf8aca04cc9a47f63504689fdefc572357733300bbb399300068d73c525a69c0e35072d0abac09f00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x880355a66a3039fd0374dee2e23681607e4876d02e4c2efe91cd7763911276b2", "transactions": [{"to": "0x67dda81caa260dd5a972f16fa3dae114b11505f7", "gas": "0xf84a", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x503cd551a31215445c78d0953867a0d03f2dd2bc7099306245f85350290e0782", "input": "0xf2fde38b00000000000000000000000041b89db86be735c03a9296437e39f5fdadc4c678", "nonce": "0x17", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x9a591a7401cf0fe57bc0eff3040d5acd1b071b176e294bb307f738a66dfe57e2", "blockNumber": "0x67", "transactionIndex": "0x0"}], "totalDifficulty": "0x66ffffffffffffffffffffffffdfca83c8", "transactionsRoot": "0xa0971d7b73245269a64aaebcef379e548ed0addcc90b3f84b2ae67c17c3e8466"}, "transaction_receipts": [{"logs": [{"data": "0x", "topics": ["0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0", "0x0000000000000000000000004178babe9e5148c6d5fd431cd72884b07ad855a0", "0x00000000000000000000000041b89db86be735c03a9296437e39f5fdadc4c678"], "address": "0x67dda81caa260dd5a972f16fa3dae114b11505f7", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0x9a591a7401cf0fe57bc0eff3040d5acd1b071b176e294bb307f738a66dfe57e2", "blockNumber": "0x67", "transactionHash": "0x503cd551a31215445c78d0953867a0d03f2dd2bc7099306245f85350290e0782", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}], "root": null, "status": "0x1", "gasUsed": "0x7c25", "blockHash": "0x9a591a7401cf0fe57bc0eff3040d5acd1b071b176e294bb307f738a66dfe57e2", "logsBloom": "0x00000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000001040000000000000000000000000020000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000008000000000000000000000000000000000000000000000000080000000000020000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000010", "blockNumber": "0x67", "contractAddress": null, "transactionHash": "0x503cd551a31215445c78d0953867a0d03f2dd2bc7099306245f85350290e0782", "transactionIndex": "0x0", "cumulativeGasUsed": "0x7c25"}]}
\\x3bf5863f91a2a59433547dce0a45b3514fbf5a2b058c907ceb6292c3936660c5	102	\\x56bce38a89f0c5c9013823382f9be447ac4cd016ab01dc6d736b6ac48aecf3d6	{"block": {"hash": "0x3bf5863f91a2a59433547dce0a45b3514fbf5a2b058c907ceb6292c3936660c5", "size": "0x2d7", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x66", "uncles": [], "gasUsed": "0xad36", "mixHash": null, "gasLimit": "0x652272", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2d74877e08e3d20da29011d4b63e6d9a326aa198c96b024a77244801c88eaa04", "timestamp": "0x60a67370", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x56bce38a89f0c5c9013823382f9be447ac4cd016ab01dc6d736b6ac48aecf3d6", "sealFields": ["0x8420377bd0", "0xb84187102774a5f9c499bdbe2884999a78c77b5ebf0ed667b2641da478f3b0006998191625a0cec5a19291d790054f59238aca2ce02a430964864a6a28c6f0386c2100"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x0940eef220abfa14b05c65ceb8d38b72a6106d1352bec34128479322c32dc152", "transactions": [{"to": "0x67dda81caa260dd5a972f16fa3dae114b11505f7", "gas": "0x15a6c", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xa4eacee982ae595b49c6162d84ee2c21a20a6c08313c6404c20fe896e24a95ea", "input": "0x0b26cf6600000000000000000000000041b89db86be735c03a9296437e39f5fdadc4c678", "nonce": "0x16", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x3bf5863f91a2a59433547dce0a45b3514fbf5a2b058c907ceb6292c3936660c5", "blockNumber": "0x66", "transactionIndex": "0x0"}], "totalDifficulty": "0x65ffffffffffffffffffffffffdfca83ca", "transactionsRoot": "0xb6bd728c41cb9de0770fc23b2e05fe9622d878c0808131f8fafbb2963c0d8ede"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0xad36", "blockHash": "0x3bf5863f91a2a59433547dce0a45b3514fbf5a2b058c907ceb6292c3936660c5", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x66", "contractAddress": null, "transactionHash": "0xa4eacee982ae595b49c6162d84ee2c21a20a6c08313c6404c20fe896e24a95ea", "transactionIndex": "0x0", "cumulativeGasUsed": "0xad36"}]}
\\x56bce38a89f0c5c9013823382f9be447ac4cd016ab01dc6d736b6ac48aecf3d6	101	\\xd2075f15f615e7a7683984e693d76d8bbacbc963c4b7bd582690eb72b12c338b	{"block": {"hash": "0x56bce38a89f0c5c9013823382f9be447ac4cd016ab01dc6d736b6ac48aecf3d6", "size": "0x21d2", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x65", "uncles": [], "gasUsed": "0x192069", "mixHash": null, "gasLimit": "0x650931", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xdb24e2cc7bc1ceb0583fb6fefb02899f3d071c44d73729ecfacce320da5d8dc3", "timestamp": "0x60a6736d", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xd2075f15f615e7a7683984e693d76d8bbacbc963c4b7bd582690eb72b12c338b", "sealFields": ["0x8420377bcf", "0xb8419d293ede5d5a4dd95bb3fc43e275a752824c57c6e9aa18a9ef60d52890b256f719ad855f7c83c812f524385cebb2eb4ceadbe81ffbc7bb0596f72c9d5319868201"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x3a3943f4ab75ecc987a2d47b8d44128b1d71163ccd00ed6a129d757f36044096", "transactions": [{"to": null, "gas": "0x3240d2", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x80076746a4c9bba9c4e2322fb072834ec5de438b44a3de539f531a39de9c3aed", "input": "0x60806040526006805460a060020a60ff02191690553480156200002157600080fd5b5060405162001e2e38038062001e2e83398101604090815281516020808401519284015160608501519285018051909594909401939092918591859185918491849184916200007691600091860190620002d0565b5081516200008c906001906020850190620002d0565b506002805460ff90921660ff19909216919091179055505060068054600160a060020a03191633179055505050801515620000c657600080fd5b60405180807f454950373132446f6d61696e28737472696e67206e616d652c737472696e672081526020017f76657273696f6e2c75696e7432353620636861696e49642c616464726573732081526020017f766572696679696e67436f6e747261637429000000000000000000000000000081525060520190506040518091039020846040518082805190602001908083835b602083106200017a5780518252601f19909201916020918201910162000159565b51815160209384036101000a600019018019909216911617905260408051929094018290038220828501855260018084527f3100000000000000000000000000000000000000000000000000000000000000928401928352945190965091945090928392508083835b60208310620002045780518252601f199092019160209182019101620001e3565b51815160209384036101000a6000190180199092169116179052604080519290940182900382208282019890985281840196909652606081019690965250608085018690523060a0808701919091528151808703909101815260c09095019081905284519093849350850191508083835b60208310620002965780518252601f19909201916020918201910162000275565b5181516020939093036101000a60001901801990911692169190911790526040519201829003909120600855506200037595505050505050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106200031357805160ff191683800117855562000343565b8280016001018555821562000343579182015b828111156200034357825182559160200191906001019062000326565b506200035192915062000355565b5090565b6200037291905b808211156200035157600081556001016200035c565b90565b611aa980620003856000396000f30060806040526004361061019d5763ffffffff60e060020a60003504166305d2035b81146101a257806306fdde03146101cb578063095ea7b3146102555780630b26cf661461027957806318160ddd1461029c57806323b872dd146102c357806330adf81f146102ed578063313ce567146103025780633644e5151461032d57806339509351146103425780634000aea01461036657806340c10f191461039757806342966c68146103bb57806354fd4d50146103d357806366188463146103e857806369ffa08a1461040c57806370a0823114610433578063715018a614610454578063726600ce146104695780637d64bcb41461048a5780637ecebe001461049f578063859ba28c146104c05780638da5cb5b146105015780638fcbaf0c1461053257806395d89b4114610570578063a457c2d714610585578063a9059cbb146105a9578063b753a98c146105cd578063bb35783b146105f1578063cd5965831461061b578063d73dd62314610630578063dd62ed3e14610654578063f2d5d56b1461067b578063f2fde38b1461069f578063ff9e884d146106c0575b600080fd5b3480156101ae57600080fd5b506101b76106e7565b604080519115158252519081900360200190f35b3480156101d757600080fd5b506101e0610708565b6040805160208082528351818301528351919283929083019185019080838360005b8381101561021a578181015183820152602001610202565b50505050905090810190601f1680156102475780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34801561026157600080fd5b506101b7600160a060020a0360043516602435610796565b34801561028557600080fd5b5061029a600160a060020a03600435166107d9565b005b3480156102a857600080fd5b506102b1610833565b60408051918252519081900360200190f35b3480156102cf57600080fd5b506101b7600160a060020a0360043581169060243516604435610839565b3480156102f957600080fd5b506102b1610a08565b34801561030e57600080fd5b50610317610a2c565b6040805160ff9092168252519081900360200190f35b34801561033957600080fd5b506102b1610a35565b34801561034e57600080fd5b506101b7600160a060020a0360043516602435610a3b565b34801561037257600080fd5b506101b760048035600160a060020a0316906024803591604435918201910135610aa1565b3480156103a357600080fd5b506101b7600160a060020a0360043516602435610bb2565b3480156103c757600080fd5b5061029a600435610cbd565b3480156103df57600080fd5b506101e0610cca565b3480156103f457600080fd5b506101b7600160a060020a0360043516602435610d01565b34801561041857600080fd5b5061029a600160a060020a0360043581169060243516610dde565b34801561043f57600080fd5b506102b1600160a060020a0360043516610e03565b34801561046057600080fd5b5061029a610e1e565b34801561047557600080fd5b506101b7600160a060020a0360043516610e35565b34801561049657600080fd5b506101b7610e49565b3480156104ab57600080fd5b506102b1600160a060020a0360043516610e50565b3480156104cc57600080fd5b506104d5610e62565b6040805167ffffffffffffffff9485168152928416602084015292168183015290519081900360600190f35b34801561050d57600080fd5b50610516610e6d565b60408051600160a060020a039092168252519081900360200190f35b34801561053e57600080fd5b5061029a600160a060020a0360043581169060243516604435606435608435151560ff60a4351660c43560e435610e7c565b34801561057c57600080fd5b506101e06111d0565b34801561059157600080fd5b506101b7600160a060020a036004351660243561122a565b3480156105b557600080fd5b506101b7600160a060020a036004351660243561123d565b3480156105d957600080fd5b5061029a600160a060020a0360043516602435611268565b3480156105fd57600080fd5b5061029a600160a060020a0360043581169060243516604435611278565b34801561062757600080fd5b50610516611289565b34801561063c57600080fd5b506101b7600160a060020a0360043516602435611298565b34801561066057600080fd5b506102b1600160a060020a036004358116906024351661131f565b34801561068757600080fd5b5061029a600160a060020a036004351660243561134a565b3480156106ab57600080fd5b5061029a600160a060020a0360043516611355565b3480156106cc57600080fd5b506102b1600160a060020a0360043581169060243516611375565b60065474010000000000000000000000000000000000000000900460ff1681565b6000805460408051602060026001851615610100026000190190941693909304601f8101849004840282018401909252818152929183018282801561078e5780601f106107635761010080835404028352916020019161078e565b820191906000526020600020905b81548152906001019060200180831161077157829003601f168201915b505050505081565b60006107a28383611392565b90506000198214156107d357336000908152600a60209081526040808320600160a060020a03871684529091528120555b92915050565b600654600160a060020a031633146107f057600080fd5b6107f9816113e6565b151561080457600080fd5b6007805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b60045490565b600080600160a060020a038516151561085157600080fd5b600160a060020a038416151561086657600080fd5b600160a060020a03851660009081526003602052604090205461088f908463ffffffff6113ee16565b600160a060020a0380871660009081526003602052604080822093909355908616815220546108c4908463ffffffff61140016565b600160a060020a038086166000818152600360209081526040918290209490945580518781529051919392891692600080516020611a3e83398151915292918290030190a3600160a060020a03851633146109f257610923853361131f565b9050600019811461098d5761093e818463ffffffff6113ee16565b600160a060020a038616600081815260056020908152604080832033808552908352928190208590558051948552519193600080516020611a5e833981519152929081900390910190a36109f2565b600160a060020a0385166000908152600a6020908152604080832033845290915290205415806109e757506109c061140d565b600160a060020a0386166000908152600a6020908152604080832033845290915290205410155b15156109f257600080fd5b6109fd858585611411565b506001949350505050565b7fea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb81565b60025460ff1681565b60085481565b6000610a478383611448565b336000908152600560209081526040808320600160a060020a038816845290915290205490915060001914156107d357336000908152600a60209081526040808320600160a060020a038716845290915281205592915050565b600084600160a060020a03811615801590610ac55750600160a060020a0381163014155b1515610ad057600080fd5b610ada8686611454565b1515610ae557600080fd5b85600160a060020a031633600160a060020a03167fe19260aff97b920c7df27010903aeb9c8d2be5d310a2c67824cf3f15396e4c16878787604051808481526020018060200182810382528484828181526020019250808284376040519201829003965090945050505050a3610b5a866113e6565b15610ba657610b9b33878787878080601f01602080910402602001604051908101604052809392919081815260200183838082843750611460945050505050565b1515610ba657600080fd5b50600195945050505050565b600654600090600160a060020a03163314610bcc57600080fd5b60065474010000000000000000000000000000000000000000900460ff1615610bf457600080fd5b600454610c07908363ffffffff61140016565b600455600160a060020a038316600090815260036020526040902054610c33908363ffffffff61140016565b600160a060020a038416600081815260036020908152604091829020939093558051858152905191927f0f6798a560793a54c3bcfe86a93cde1e73087d944c0ea20544137d412139688592918290030190a2604080518381529051600160a060020a03851691600091600080516020611a3e8339815191529181900360200190a350600192915050565b610cc733826115dd565b50565b60408051808201909152600181527f3100000000000000000000000000000000000000000000000000000000000000602082015281565b336000908152600560209081526040808320600160a060020a0386168452909152812054808310610d5557336000908152600560209081526040808320600160a060020a0388168452909152812055610d8a565b610d65818463ffffffff6113ee16565b336000908152600560209081526040808320600160a060020a03891684529091529020555b336000818152600560209081526040808320600160a060020a038916808552908352928190205481519081529051929392600080516020611a5e833981519152929181900390910190a35060019392505050565b600654600160a060020a03163314610df557600080fd5b610dff82826116cc565b5050565b600160a060020a031660009081526003602052604090205490565b600654600160a060020a0316331461019d57600080fd5b600754600160a060020a0390811691161490565b6000806000fd5b60096020526000908152604090205481565b600260046000909192565b600654600160a060020a031681565b600080600160a060020a038a161515610e9457600080fd5b600160a060020a0389161515610ea957600080fd5b861580610ebd575086610eba61140d565b11155b1515610ec857600080fd5b8460ff16601b1480610edd57508460ff16601c145b1515610ee857600080fd5b7f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0831115610f1557600080fd5b600854604080517fea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb602080830191909152600160a060020a03808f16838501528d166060830152608082018c905260a082018b905289151560c0808401919091528351808403909101815260e090920192839052815191929182918401908083835b60208310610fb65780518252601f199092019160209182019101610f97565b51815160209384036101000a6000190180199092169116179052604080519290940182900382207f190100000000000000000000000000000000000000000000000000000000000083830152602283019790975260428083019790975283518083039097018752606290910192839052855192945084935085019190508083835b602083106110565780518252601f199092019160209182019101611037565b51815160209384036101000a600019018019909216911617905260408051929094018290038220600080845283830180875282905260ff8d1684870152606084018c9052608084018b905294519098506001965060a080840196509194601f19820194509281900390910191865af11580156110d6573d6000803e3d6000fd5b50505060206040510351600160a060020a03168a600160a060020a03161415156110ff57600080fd5b600160a060020a038a166000908152600960205260409020805460018101909155881461112b57600080fd5b8561113757600061113b565b6000195b600160a060020a03808c166000908152600560209081526040808320938e16835292905220819055905085611171576000611173565b865b600160a060020a03808c166000818152600a60209081526040808320948f1680845294825291829020949094558051858152905192939192600080516020611a5e833981519152929181900390910190a350505050505050505050565b60018054604080516020600284861615610100026000190190941693909304601f8101849004840282018401909252818152929183018282801561078e5780601f106107635761010080835404028352916020019161078e565b60006112368383610d01565b9392505050565b60006112498383611454565b151561125457600080fd5b61125f338484611411565b50600192915050565b611273338383610839565b505050565b611283838383610839565b50505050565b600754600160a060020a031690565b336000908152600560209081526040808320600160a060020a03861684529091528120546112cc908363ffffffff61140016565b336000818152600560209081526040808320600160a060020a038916808552908352928190208590558051948552519193600080516020611a5e833981519152929081900390910190a350600192915050565b600160a060020a03918216600090815260056020908152604080832093909416825291909152205490565b611273823383610839565b600654600160a060020a0316331461136c57600080fd5b610cc78161170a565b600a60209081526000928352604080842090915290825290205481565b336000818152600560209081526040808320600160a060020a03871680855290835281842086905581518681529151939490939092600080516020611a5e833981519152928290030190a350600192915050565b6000903b1190565b6000828211156113fa57fe5b50900390565b818101828110156107d357fe5b4290565b61141a82610e35565b156112735760408051600081526020810190915261143d90849084908490611460565b151561127357600080fd5b60006112368383611298565b60006112368383611788565b600083600160a060020a031663a4c0ed3660e060020a028685856040516024018084600160a060020a0316600160a060020a0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b838110156114d85781810151838201526020016114c0565b50505050905090810190601f1680156115055780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529181526020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167fffffffff00000000000000000000000000000000000000000000000000000000909916989098178852518151919790965086955093509150819050838360005b8381101561159357818101518382015260200161157b565b50505050905090810190601f1680156115c05780820380516001836020036101000a031916815260200191505b509150506000604051808303816000865af1979650505050505050565b600160a060020a03821660009081526003602052604090205481111561160257600080fd5b600160a060020a03821660009081526003602052604090205461162b908263ffffffff6113ee16565b600160a060020a038316600090815260036020526040902055600454611657908263ffffffff6113ee16565b600455604080518281529051600160a060020a038416917fcc16f5dbb4873280815c1ee09dbd06736cffcc184412cf7a71a0fdb75d397ca5919081900360200190a2604080518281529051600091600160a060020a03851691600080516020611a3e8339815191529181900360200190a35050565b80600160a060020a03811615156116e257600080fd5b600160a060020a0383161515611700576116fb82611857565b611273565b6112738383611863565b600160a060020a038116151561171f57600080fd5b600654604051600160a060020a038084169216907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a36006805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b336000908152600360205260408120548211156117a457600080fd5b600160a060020a03831615156117b957600080fd5b336000908152600360205260409020546117d9908363ffffffff6113ee16565b3360009081526003602052604080822092909255600160a060020a0385168152205461180b908363ffffffff61140016565b600160a060020a038416600081815260036020908152604091829020939093558051858152905191923392600080516020611a3e8339815191529281900390910190a350600192915050565b3031610dff8282611910565b604080517f70a0823100000000000000000000000000000000000000000000000000000000815230600482015290518391600091600160a060020a038416916370a0823191602480830192602092919082900301818787803b1580156118c857600080fd5b505af11580156118dc573d6000803e3d6000fd5b505050506040513d60208110156118f257600080fd5b50519050611283600160a060020a038516848363ffffffff61197816565b604051600160a060020a0383169082156108fc029083906000818181858888f193505050501515610dff578082611945611a0d565b600160a060020a039091168152604051908190036020019082f080158015611971573d6000803e3d6000fd5b5050505050565b82600160a060020a031663a9059cbb83836040518363ffffffff1660e060020a0281526004018083600160a060020a0316600160a060020a0316815260200182815260200192505050600060405180830381600087803b1580156119db57600080fd5b505af11580156119ef573d6000803e3d6000fd5b505050503d156112735760206000803e600051151561127357600080fd5b604051602180611a1d833901905600608060405260405160208060218339810160405251600160a060020a038116ff00ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925a165627a7a72305820226f245a63d38f9f56e75d66011684f4d50f4fc3fce06a9c73091f58c2d913d80029000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000002325000000000000000000000000000000000000000000000000000000000000001144617461636f696e53696465636861696e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024453000000000000000000000000000000000000000000000000000000000000", "nonce": "0x15", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x56bce38a89f0c5c9013823382f9be447ac4cd016ab01dc6d736b6ac48aecf3d6", "blockNumber": "0x65", "transactionIndex": "0x0"}], "totalDifficulty": "0x64ffffffffffffffffffffffffdfca83cc", "transactionsRoot": "0xdb0e85d7498a2f094b7ee21709f565cf63b7c99c64ca5127f9b6d08a36cbc688"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x192069", "blockHash": "0x56bce38a89f0c5c9013823382f9be447ac4cd016ab01dc6d736b6ac48aecf3d6", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x65", "contractAddress": "0x67dda81caa260dd5a972f16fa3dae114b11505f7", "transactionHash": "0x80076746a4c9bba9c4e2322fb072834ec5de438b44a3de539f531a39de9c3aed", "transactionIndex": "0x0", "cumulativeGasUsed": "0x192069"}]}
\\xd2075f15f615e7a7683984e693d76d8bbacbc963c4b7bd582690eb72b12c338b	100	\\xb8d67fe74fc18041298216a6e377c0536feaf70d5c3cf2a9993f9d2c5c2f03c6	{"block": {"hash": "0xd2075f15f615e7a7683984e693d76d8bbacbc963c4b7bd582690eb72b12c338b", "size": "0x2f9", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x64", "uncles": [], "gasUsed": "0x10859", "mixHash": null, "gasLimit": "0x64eff7", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000004000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000200080000000000000000000000000000000000000000000400000000000000000000000000000000000000000200", "stateRoot": "0x9a34771f4d5d75966a4181aa3248331ab2a3dc1ba88200685d921004018450f2", "timestamp": "0x60a6736a", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xb8d67fe74fc18041298216a6e377c0536feaf70d5c3cf2a9993f9d2c5c2f03c6", "sealFields": ["0x8420377bce", "0xb84128b64b8144fff1060d36c19ee3d810ed9b2d612f8569ea8fb8f800a99065e0452418d87681f35c7a6d4aead3e5c67ebf85b39cdf032646c861ab82689722991e01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x3fff869f4f93e1bdfac5e9c4bbb056fdcaa40ede186870576aa3a00818d65dbc", "transactions": [{"to": "0x41b89db86be735c03a9296437e39f5fdadc4c678", "gas": "0x210b2", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xd3044506c11faae1ea06f466d57efad7c5a3ea93cd8d9dff9f2459f1267970bd", "input": "0x3ad06d1600000000000000000000000000000000000000000000000000000000000000010000000000000000000000004081b7e107e59af8e82756f96c751174590989fe", "nonce": "0x14", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xd2075f15f615e7a7683984e693d76d8bbacbc963c4b7bd582690eb72b12c338b", "blockNumber": "0x64", "transactionIndex": "0x0"}], "totalDifficulty": "0x63ffffffffffffffffffffffffdfca83ce", "transactionsRoot": "0xe48e36784b8cf225182cece50444b08dba047dcc46d75a1717515b035012614d"}, "transaction_receipts": [{"logs": [{"data": "0x0000000000000000000000000000000000000000000000000000000000000001", "topics": ["0x4289d6195cf3c2d2174adf98d0e19d4d2d08887995b99cb7b100e7ffe795820e", "0x0000000000000000000000004081b7e107e59af8e82756f96c751174590989fe"], "address": "0x41b89db86be735c03a9296437e39f5fdadc4c678", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0xd2075f15f615e7a7683984e693d76d8bbacbc963c4b7bd582690eb72b12c338b", "blockNumber": "0x64", "transactionHash": "0xd3044506c11faae1ea06f466d57efad7c5a3ea93cd8d9dff9f2459f1267970bd", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}], "root": null, "status": "0x1", "gasUsed": "0x10859", "blockHash": "0xd2075f15f615e7a7683984e693d76d8bbacbc963c4b7bd582690eb72b12c338b", "logsBloom": "0x00000000000000000000000000000000000000004000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000200080000000000000000000000000000000000000000000400000000000000000000000000000000000000000200", "blockNumber": "0x64", "contractAddress": null, "transactionHash": "0xd3044506c11faae1ea06f466d57efad7c5a3ea93cd8d9dff9f2459f1267970bd", "transactionIndex": "0x0", "cumulativeGasUsed": "0x10859"}]}
\\xb8d67fe74fc18041298216a6e377c0536feaf70d5c3cf2a9993f9d2c5c2f03c6	99	\\x7eb6478b401fadee5edd35307060e5e8de667e1e90b4afb382b6bed0c158ef2c	{"block": {"hash": "0xb8d67fe74fc18041298216a6e377c0536feaf70d5c3cf2a9993f9d2c5c2f03c6", "size": "0x38c0", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x63", "uncles": [], "gasUsed": "0x2e3f67", "mixHash": null, "gasLimit": "0x64d6c3", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x9b35438becfe1b0b6df1b4c99a3576ac332e03ded284b5fa58038a2f3c4d99de", "timestamp": "0x60a67367", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x7eb6478b401fadee5edd35307060e5e8de667e1e90b4afb382b6bed0c158ef2c", "sealFields": ["0x8420377bcd", "0xb8415f1e55a4eb3d61be11e2069ab28c638db22dd11f14c75031248f95b088d301b65bb048464bb164d12c8c89dc1e2824380bc8d240b4e54cb6868be2c9c18bef6500"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0xeeb37fb9b70810286fa0230f430bbf66404e81384d6b906cf910826ab86e1ffb", "transactions": [{"to": null, "gas": "0x5c7ece", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xc7c6281dbed0ec3c350cb69339de12fa875a10e16e2addc97200dbcefba31f50", "input": "0x608060405234801561001057600080fd5b506135fc806100206000396000f3006080604052600436106101d45763ffffffff60e060020a60003504166301e4f53a81146101d95780630950d515146101ff5780630b26cf661461021757806318d8f9c9146102385780632bd0bb0514610269578063392e53cd146102935780633dd95d1b146102bc5780633e6968b6146102d4578063437764df146102e957806343b37dd3146103335780634fb3fef714610348578063593399821461036057806367eeba0c1461037857806369ffa08a1461038d5780636e5d6bea146103b4578063871c0760146103d5578063879ce676146103ea5780638aa1949a146104025780638b6c0354146104175780638da5cb5b1461043b57806395e54a17146104505780639a4a4395146104655780639cb7595a1461047d578063a0189345146104be578063a2a6ca27146104d3578063a4c0ed36146104eb578063a7444c0d1461051c578063b20d30a91461053c578063be3b625b14610554578063c0b0d02214610569578063c6f6f216146105fe578063cd59658314610616578063d74054811461062b578063dae5f0fd1461069a578063df25f3f0146106af578063ea9f4968146106c4578063f20151e1146106dc578063f2fde38b146106f4578063f3b8379114610715578063f968adbe1461072d575b600080fd5b3480156101e557600080fd5b506101fd600160a060020a0360043516602435610742565b005b34801561020b57600080fd5b506101fd60043561088e565b34801561022357600080fd5b506101fd600160a060020a036004351661095d565b34801561024457600080fd5b5061024d610985565b60408051600160a060020a039092168252519081900360200190f35b34801561027557600080fd5b50610281600435610994565b60408051918252519081900360200190f35b34801561029f57600080fd5b506102a8610a51565b604080519115158252519081900360200190f35b3480156102c857600080fd5b506101fd600435610aa2565b3480156102e057600080fd5b50610281610b62565b3480156102f557600080fd5b506102fe610b6b565b604080517fffffffff000000000000000000000000000000000000000000000000000000009092168252519081900360200190f35b34801561033f57600080fd5b50610281610b8f565b34801561035457600080fd5b50610281600435610bdd565b34801561036c57600080fd5b506102a8600435610c58565b34801561038457600080fd5b50610281610d21565b34801561039957600080fd5b506101fd600160a060020a0360043581169060243516610d6f565b3480156103c057600080fd5b506101fd600160a060020a0360043516610dfb565b3480156103e157600080fd5b5061024d610e20565b3480156103f657600080fd5b506102a8600435610e77565b34801561040e57600080fd5b50610281610ec1565b34801561042357600080fd5b506101fd600160a060020a0360043516602435610f0f565b34801561044757600080fd5b5061024d610f8f565b34801561045c57600080fd5b50610281610fe6565b34801561047157600080fd5b506101fd600435611040565b34801561048957600080fd5b50610492611391565b6040805167ffffffffffffffff9485168152928416602084015292168183015290519081900360600190f35b3480156104ca57600080fd5b5061028161139c565b3480156104df57600080fd5b506101fd6004356113ea565b3480156104f757600080fd5b506102a860048035600160a060020a0316906024803591604435918201910135611486565b34801561052857600080fd5b506101fd6004356024351515604435611523565b34801561054857600080fd5b506101fd600435611686565b34801561056057600080fd5b50610281611746565b34801561057557600080fd5b506040805160608181019092526102a891600160a060020a03600480358216936024358316936044359093169236929160c49160649060039083908390808284375050604080518082018252949796958181019594509250600291508390839080828437509396505083359450505060208201359160400135600160a060020a03169050611794565b34801561060a57600080fd5b506101fd600435611960565b34801561062257600080fd5b5061024d6119f8565b34801561063757600080fd5b50604080516020601f6064356004818101359283018490048402850184019095528184526101fd94600160a060020a038135811695602480359092169560443595369560849401918190840183828082843750949750611a4f9650505050505050565b3480156106a657600080fd5b50610281611ada565b3480156106bb57600080fd5b50610281611b28565b3480156106d057600080fd5b506102a8600435611b76565b3480156106e857600080fd5b506101fd600435611bc1565b34801561070057600080fd5b506101fd600160a060020a0360043516611c3d565b34801561072157600080fd5b506101fd600435611c62565b34801561073957600080fd5b50610281611c87565b60008061074d611cd5565b1561075757600080fd5b61075f610985565b915030905061076d83611b76565b151561077857600080fd5b610789610783610b62565b84611cfa565b6107936001611dc3565b604080517f23b872dd000000000000000000000000000000000000000000000000000000008152336004820152600160a060020a038381166024830152604482018690529151918416916323b872dd916064808201926020929091908290030181600087803b15801561080557600080fd5b505af1158015610819573d6000803e3d6000fd5b505050506040513d602081101561082f57600080fd5b5061083c90506000611dc3565b610888823385876040516020018082600160a060020a0316600160a060020a03166c01000000000000000000000000028152601401915050604051602081830303815290604052611de7565b50505050565b6000806108996119f8565b600160a060020a031633146108ad57600080fd5b6108b5610e20565b600160a060020a03166108c6611e6a565b600160a060020a0316146108d957600080fd5b6108e283610c58565b156108ec57600080fd5b6108f583611ee2565b915061090083611fb1565b905061090b83612034565b6109158282612106565b60408051600160a060020a038416815260208101839052815185927f06297b0797e3363e96e454edd4ab62862051bf559a7a431ce09415306771d133928290030190a2505050565b610965610f8f565b600160a060020a0316331461097957600080fd5b6109828161219a565b50565b600061098f612225565b905090565b60008060008360405160200180807f746f74616c5370656e74506572446179000000000000000000000000000000008152506010018281526020019150506040516020818303038152906040526040518082805190602001908083835b60208310610a105780518252601f1990920191602091820191016109f1565b51815160209384036101000a600019018019909216911617905260408051929094018290039091208652850195909552929092016000205495945050505050565b7f0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba60005260046020527f078d888f9b66f3f8bfa10909e31f1e16240db73449f0500afdbbe3a70da457cc5460ff1690565b610aaa610f8f565b600160a060020a03163314610abe57600080fd5b610ac6610ec1565b811180610ad1575080155b1515610adc57600080fd5b7f21dbcab260e413c20dc13c28b7db95e2b423d1135f42bb8b7d5214a92270d237600090815260209081527fadd938dbd083a16bae12238cd914fca0afc7a30edb55b1cd5c7f1823f1b0e4218290556040805183815290517f9bebf928b90863f24cc31f726a3a7545efd409f1dcf552301b1ee3710da70d3b929181900390910190a150565b62015180420490565b7f76595b560000000000000000000000000000000000000000000000000000000090565b7f21dbcab260e413c20dc13c28b7db95e2b423d1135f42bb8b7d5214a92270d23760009081526020527fadd938dbd083a16bae12238cd914fca0afc7a30edb55b1cd5c7f1823f1b0e4215490565b60008060008360405160200180807f746f74616c45786563757465645065724461790000000000000000000000000081525060130182815260200191505060405160208183030381529060405260405180828051906020019080838360208310610a105780518252601f1990920191602091820191016109f1565b6000600460008360405160200180807f6d65737361676546697865640000000000000000000000000000000000000000815250600c0182600019166000191681526020019150506040516020818303038152906040526040518082805190602001908083835b60208310610cdd5780518252601f199092019160209182019101610cbe565b51815160209384036101000a600019018019909216911617905260408051929094018290039091208652850195909552929092016000205460ff1695945050505050565b7f4a6a899679f26b73530d8cf1001e83b6f7702e04b6fdb98f3c62dc7e47e041a560009081526020527f1ab29a5cca988aee50edccdd61c5bcaa7ad4b29a03b7ee50f298ceccfe14cc4e5490565b30600160a060020a0316636fde82026040518163ffffffff1660e060020a028152600401602060405180830381600087803b158015610dad57600080fd5b505af1158015610dc1573d6000803e3d6000fd5b505050506040513d6020811015610dd757600080fd5b5051600160a060020a03163314610ded57600080fd5b610df7828261227c565b5050565b610e03610f8f565b600160a060020a03163314610e1757600080fd5b610982816122bf565b7f98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab988060005260026020527f0c1206883be66049a02d4937078367c00b3d71dd1a9465df969363c6ddeac96d54600160a060020a031690565b600080610e9a83610e8e610e89610b62565b610bdd565b9063ffffffff61233616565b905080610ea5610b8f565b10158015610eba5750610eb6610ec1565b8311155b9392505050565b7fc0ed44c192c86d1cc1ba51340b032c2766b4a2b0041031de13c46dd7104888d560009081526020527ff8e983ee86e5e377e9e34c9131b266382c3f04113d20de077f9e12663c7a646b5490565b610f176119f8565b600160a060020a03163314610f2b57600080fd5b610f33610e20565b600160a060020a0316610f44611e6a565b600160a060020a031614610f5757600080fd5b610f6081610e77565b15610f8557610f76610f70610b62565b82612349565b610f8082826123cf565b610df7565b610df78282612649565b7f02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c060005260026020527fb7802e97e87ef2842a6cce7da7ffaeaedaa2f61a6a7870b23d9d01fc9b73712e54600160a060020a031690565b6000806000806000610ff6611c87565b9350611000610d21565b925061101261100d610b62565b610994565b9150818311611022576000611026565b8183035b90508084106110355780611037565b835b94505050505090565b6000606061104c6119f8565b600160a060020a031663cb08a10c846040518263ffffffff1660e060020a028152600401808260001916600019168152602001915050602060405180830381600087803b15801561109c57600080fd5b505af11580156110b0573d6000803e3d6000fd5b505050506040513d60208110156110c657600080fd5b5051156110d257600080fd5b306110db6119f8565b600160a060020a0316633f9a8e7e856040518263ffffffff1660e060020a028152600401808260001916600019168152602001915050602060405180830381600087803b15801561112b57600080fd5b505af115801561113f573d6000803e3d6000fd5b505050506040513d602081101561115557600080fd5b5051600160a060020a03161461116a57600080fd5b611172610e20565b600160a060020a03166111836119f8565b600160a060020a0316634a610b04856040518263ffffffff1660e060020a028152600401808260001916600019168152602001915050602060405180830381600087803b1580156111d357600080fd5b505af11580156111e7573d6000803e3d6000fd5b505050506040513d60208110156111fd57600080fd5b5051600160a060020a03161461121257600080fd5b50506040805160248082018490528251808303909101815260449091019091526020810180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167f0950d51500000000000000000000000000000000000000000000000000000000908117909152906112866119f8565b600160a060020a031663dc8601b361129c610e20565b836112a5611746565b6040518463ffffffff1660e060020a0281526004018084600160a060020a0316600160a060020a0316815260200180602001838152602001828103825284818151815260200191508051906020019080838360005b838110156113125781810151838201526020016112fa565b50505050905090810190601f16801561133f5780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b15801561136057600080fd5b505af1158015611374573d6000803e3d6000fd5b505050506040513d602081101561138a57600080fd5b5050505050565b600160046000909192565b7f145286dc85799b6fb9fe322391ba2d95683077b2adf34dd576dedc437e537ba760009081526020527fba10c7a68bf463c41368d64adcf7df23c0de931ea3b09f061e2dfec302fef95f5490565b6113f2610f8f565b600160a060020a0316331461140657600080fd5b60008111801561141c5750611419610d21565b81105b801561142e575061142b611c87565b81105b151561143957600080fd5b7fbbb088c505d18e049d114c7c91f11724e69c55ad6c5397e2b929e68b41fa05d160009081526020527f8df5c48c6b6e11d97548adc824ba0c99103ec09830fa5d53a179984085e6eaa055565b600080611491610985565b905033600160a060020a038216146114a857600080fd5b6114b0611cd5565b15156114db576114bf85611b76565b15156114ca57600080fd5b6114db6114d5610b62565b86611cfa565b61151781878787878080601f01602080910402602001604051908101604052809392919081815260200183838082843750611de7945050505050565b50600195945050505050565b600080600030600160a060020a0316636fde82026040518163ffffffff1660e060020a028152600401602060405180830381600087803b15801561156657600080fd5b505af115801561157a573d6000803e3d6000fd5b505050506040513d602081101561159057600080fd5b5051600160a060020a031633146115a657600080fd5b6115af866126ea565b9093509150600160a060020a038316158015906115cc5750600082115b80156115d85750838210155b15156115e357600080fd5b6116036115fe856115f261139c565b9063ffffffff61287116565b612883565b611613828563ffffffff61287116565b905061161f81876128d0565b6040805185815260208101839052815188927f5bcec6564fe8d2cbb4e4eb8237510ceb6b291a5c2ee2e429948d25e9c924c1fa928290030190a2841561167e57611667611c87565b84111561167357600080fd5b61167e838486612952565b505050505050565b61168e610f8f565b600160a060020a031633146116a257600080fd5b6116aa611c87565b8111806116b5575080155b15156116c057600080fd5b7f4a6a899679f26b73530d8cf1001e83b6f7702e04b6fdb98f3c62dc7e47e041a5600090815260209081527f1ab29a5cca988aee50edccdd61c5bcaa7ad4b29a03b7ee50f298ceccfe14cc4e8290556040805183815290517fad4123ae17c414d9c6d2fec478b402e6b01856cc250fd01fbfd252fda0089d3c929181900390910190a150565b7f2dfd6c9f781bb6bbb5369c114e949b69ebb440ef3d4dd6b2836225eb1dc3a2be60009081526020527f2de0d2cdc19d356cb53b5984f91bfd3b31fe0c678a0d190a6db39274bb34753f5490565b60408051600481526024810182526020810180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167f6fde8202000000000000000000000000000000000000000000000000000000001781529151815160009330939291829190808383895b838110156118155781810151838201526020016117fd565b50505050905090810190601f1680156118425780820380516001836020036101000a031916815260200191505b509150506000604051808303816000865af191505015806118d4575030600160a060020a0316636fde82026040518163ffffffff1660e060020a028152600401602060405180830381600087803b15801561189c57600080fd5b505af11580156118b0573d6000803e3d6000fd5b505050506040513d60208110156118c657600080fd5b5051600160a060020a031633145b806118de57503330145b15156118e957600080fd5b6118f1610a51565b156118fb57600080fd5b6119048961219a565b61190d886122bf565b61191687612b39565b61191f86612bc4565b61192885612d21565b61193184612df6565b61193a83612e57565b61194382612ec0565b61194b612f97565b611953610a51565b9998505050505050505050565b611968610f8f565b600160a060020a0316331461197c57600080fd5b8015806119a0575061198c611b28565b811180156119a0575061199d610d21565b81105b15156119ab57600080fd5b7f0f8803acad17c63ee38bf2de71e1888bc7a079a6f73658e274b08018bea4e29c60009081526020527f9de0f81379b4d8e60fe509315d071b56e7b732abaf193e74e0d15808b0951d0955565b7f811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f60005260026020527fb4ed64697d3ef8518241966f7c6f28b0d72f20f51198717d198d2d55076c593d54600160a060020a031690565b611a57610985565b600160a060020a03858116911614611ad057604080517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152600b60248201527f77726f6e675f746f6b656e000000000000000000000000000000000000000000604482015290519081900360640190fd5b6108888383610742565b7f1e8ecaafaddea96ed9ac6d2642dcdfe1bebe58a930b1085842d8fc122b371ee560009081526020527fd5c78dd9468716ca9bb96be25d56436811b20aab3523a9904b12deef1cab239d5490565b7fbbb088c505d18e049d114c7c91f11724e69c55ad6c5397e2b929e68b41fa05d160009081526020527f8df5c48c6b6e11d97548adc824ba0c99103ec09830fa5d53a179984085e6eaa05490565b600080611b8883610e8e61100d610b62565b905080611b93610d21565b10158015611ba85750611ba4611c87565b8311155b8015610eba5750611bb7611b28565b9092101592915050565b611bc9610f8f565b600160a060020a03163314611bdd57600080fd5b611be5610b8f565b8110611bf057600080fd5b7fc0ed44c192c86d1cc1ba51340b032c2766b4a2b0041031de13c46dd7104888d560009081526020527ff8e983ee86e5e377e9e34c9131b266382c3f04113d20de077f9e12663c7a646b55565b611c45610f8f565b600160a060020a03163314611c5957600080fd5b61098281612ec0565b611c6a610f8f565b600160a060020a03163314611c7e57600080fd5b61098281612df6565b7f0f8803acad17c63ee38bf2de71e1888bc7a079a6f73658e274b08018bea4e29c60009081526020527f9de0f81379b4d8e60fe509315d071b56e7b732abaf193e74e0d15808b0951d095490565b7f6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e925490565b611d0781610e8e84610994565b6000808460405160200180807f746f74616c5370656e74506572446179000000000000000000000000000000008152506010018281526020019150506040516020818303038152906040526040518082805190602001908083835b60208310611d815780518252601f199092019160209182019101611d62565b51815160209384036101000a60001901801990921691161790526040805192909401829003909120865285019590955292909201600020939093555050505050565b7f6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e9255565b611def611cd5565b15156108885783600160a060020a03166342966c68836040518263ffffffff1660e060020a02815260040180828152602001915050600060405180830381600087803b158015611e3e57600080fd5b505af1158015611e52573d6000803e3d6000fd5b5050505061088883611e648584612fee565b84612952565b6000611e746119f8565b600160a060020a031663d67bdd256040518163ffffffff1660e060020a028152600401602060405180830381600087803b158015611eb157600080fd5b505af1158015611ec5573d6000803e3d6000fd5b505050506040513d6020811015611edb57600080fd5b5051905090565b6000600260008360405160200180807f6d657373616765526563697069656e740000000000000000000000000000000081525060100182600019166000191681526020019150506040516020818303038152906040526040518082805190602001908083835b60208310611f675780518252601f199092019160209182019101611f48565b51815160209384036101000a6000190180199092169116179052604080519290940182900390912086528501959095529290920160002054600160a060020a031695945050505050565b60008060008360405160200180807f6d65737361676556616c75650000000000000000000000000000000000000000815250600c01826000191660001916815260200191505060405160208183030381529060405260405180828051906020019080838360208310610a105780518252601f1990920191602091820191016109f1565b6001600460008360405160200180807f6d65737361676546697865640000000000000000000000000000000000000000815250600c0182600019166000191681526020019150506040516020818303038152906040526040518082805190602001908083835b602083106120b95780518252601f19909201916020918201910161209a565b51815160209384036101000a60001901801990921691161790526040805192909401829003909120865285019590955292909201600020805460ff19169415159490941790935550505050565b61210e610985565b600160a060020a03166340c10f1983836040518363ffffffff1660e060020a0281526004018083600160a060020a0316600160a060020a0316815260200182815260200192505050602060405180830381600087803b15801561217057600080fd5b505af1158015612184573d6000803e3d6000fd5b505050506040513d602081101561088857600080fd5b6121a381613048565b15156121ae57600080fd5b7f811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f60005260026020527fb4ed64697d3ef8518241966f7c6f28b0d72f20f51198717d198d2d55076c593d805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b7fa8b0ade3e2b734f043ce298aca4cc8d19d74270223f34531d0988b7d00cba21d60005260026020527f603cd9dcbfa185d5c37504f4c8b3f16117ed744fba48d08b7aad44a162af1c9354600160a060020a031690565b80600160a060020a038116151561229257600080fd5b600160a060020a03831615156122b0576122ab82613050565b6122ba565b6122ba838361305c565b505050565b7f98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab988060005260026020527f0c1206883be66049a02d4937078367c00b3d71dd1a9465df969363c6ddeac96d805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b8181018281101561234357fe5b92915050565b61235681610e8e84610bdd565b6000808460405160200180807f746f74616c45786563757465645065724461790000000000000000000000000081525060130182815260200191505060405160208183030381529060405260405180828051906020019080838360208310611d815780518252601f199092019160209182019101611d62565b6000806123db83613109565b91506123e561311c565b90506123ef610985565b600160a060020a03166340c10f1930846040518363ffffffff1660e060020a0281526004018083600160a060020a0316600160a060020a0316815260200182815260200192505050602060405180830381600087803b15801561245157600080fd5b505af1158015612465573d6000803e3d6000fd5b505050506040513d602081101561247b57600080fd5b506124869050610985565b60408051600080825260208201928390527f4000aea0000000000000000000000000000000000000000000000000000000008352600160a060020a0388811660248401908152604484018890526060606485019081528451608486018190529690921695634000aea0958b958a9590949260a4860192918190849084905b8381101561251c578181015183820152602001612504565b50505050905090810190601f1680156125495780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b15801561256a57600080fd5b505af115801561257e573d6000803e3d6000fd5b505050506040513d602081101561259457600080fd5b5051151561260357604080517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152600f60248201527f7472616e736665725f6661696c65640000000000000000000000000000000000604482015290519081900360640190fd5b6040805183815290518291600160a060020a038716917f2f9a6098d4503a127779ba975f5f6b04f842362b1809f346989e9abc0b4dedb69181900360200190a350505050565b600080600061265661311c565b9250612661836126ea565b9092509050600160a060020a03821615801561267b575080155b151561268657600080fd5b6126956115fe85610e8e61139c565b6126a0858585613163565b60408051600160a060020a038716815260208101869052815185927f3344bbb992063ed4b833dabd5d5e55fc18df085bb96654e83aafbfe22e4116ff928290030190a25050505050565b600080600260008460405160200180807f74784f75744f664c696d6974526563697069656e74000000000000000000000081525060150182600019166000191681526020019150506040516020818303038152906040526040518082805190602001908083835b602083106127705780518252601f199092019160209182019101612751565b51815160209384036101000a600019018019909216911617905260408051929094018290039091208652858101969096525092830160009081205484517f74784f75744f664c696d697456616c75650000000000000000000000000000008188015260318082018b9052865180830390910181526051909101958690528051600160a060020a0390921698509195869592945091925082918401908083835b6020831061282e5780518252601f19909201916020918201910161280f565b51815160209384036101000a6000190180199092169116179052604080519290940182900390912086528501959095529290920160002054949694955050505050565b60008282111561287d57fe5b50900390565b7f145286dc85799b6fb9fe322391ba2d95683077b2adf34dd576dedc437e537ba760009081526020527fba10c7a68bf463c41368d64adcf7df23c0de931ea3b09f061e2dfec302fef95f55565b816000808360405160200180807f74784f75744f664c696d697456616c7565000000000000000000000000000000815250601101826000191660001916815260200191505060405160208183030381529060405260405180828051906020019080838360208310611d815780518252601f199092019160209182019101611d62565b60408051600160a060020a038416602482015260448082018490528251808303909101815260649091019091526020810180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167f8b6c0354000000000000000000000000000000000000000000000000000000009081179091529060006129d56119f8565b600160a060020a031663dc8601b36129eb610e20565b846129f4611746565b6040518463ffffffff1660e060020a0281526004018084600160a060020a0316600160a060020a0316815260200180602001838152602001828103825284818151815260200191508051906020019080838360005b83811015612a61578181015183820152602001612a49565b50505050905090810190601f168015612a8e5780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b158015612aaf57600080fd5b505af1158015612ac3573d6000803e3d6000fd5b505050506040513d6020811015612ad957600080fd5b50519050612ae78185613259565b612af181876132db565b6040805185815290518291600160a060020a038916917f3a5557a7cf72d28e8da836aeff2de822440d01a036e571c12c4c48611a0a41799181900360200190a3505050505050565b612b4281613048565b1515612b4d57600080fd5b7fa8b0ade3e2b734f043ce298aca4cc8d19d74270223f34531d0988b7d00cba21d60005260026020527f603cd9dcbfa185d5c37504f4c8b3f16117ed744fba48d08b7aad44a162af1c93805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b60408101516000108015612bdf575060408101516020820151115b8015612bef575060208101518151115b1515612bfa57600080fd5b80517f4a6a899679f26b73530d8cf1001e83b6f7702e04b6fdb98f3c62dc7e47e041a5600090815260208181527f1ab29a5cca988aee50edccdd61c5bcaa7ad4b29a03b7ee50f298ceccfe14cc4e92909255908201517f0f8803acad17c63ee38bf2de71e1888bc7a079a6f73658e274b08018bea4e29c82527f9de0f81379b4d8e60fe509315d071b56e7b732abaf193e74e0d15808b0951d095560408201517fbbb088c505d18e049d114c7c91f11724e69c55ad6c5397e2b929e68b41fa05d182527f8df5c48c6b6e11d97548adc824ba0c99103ec09830fa5d53a179984085e6eaa0557fad4123ae17c414d9c6d2fec478b402e6b01856cc250fd01fbfd252fda0089d3c9082905b60200201516040518082815260200191505060405180910390a150565b8051602082015110612d3257600080fd5b80517f21dbcab260e413c20dc13c28b7db95e2b423d1135f42bb8b7d5214a92270d237600090815260208181527fadd938dbd083a16bae12238cd914fca0afc7a30edb55b1cd5c7f1823f1b0e42192909255908201517fc0ed44c192c86d1cc1ba51340b032c2766b4a2b0041031de13c46dd7104888d582527ff8e983ee86e5e377e9e34c9131b266382c3f04113d20de077f9e12663c7a646b557f9bebf928b90863f24cc31f726a3a7545efd409f1dcf552301b1ee3710da70d3b908290612d04565b612dfe6133c9565b811115612e0a57600080fd5b7f2dfd6c9f781bb6bbb5369c114e949b69ebb440ef3d4dd6b2836225eb1dc3a2be60009081526020527f2de0d2cdc19d356cb53b5984f91bfd3b31fe0c678a0d190a6db39274bb34753f55565b604c1981138015612e685750604d81125b1515612e7357600080fd5b7f1e8ecaafaddea96ed9ac6d2642dcdfe1bebe58a930b1085842d8fc122b371ee560009081526020527fd5c78dd9468716ca9bb96be25d56436811b20aab3523a9904b12deef1cab239d55565b600160a060020a0381161515612ed557600080fd5b7f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0612efe610f8f565b60408051600160a060020a03928316815291841660208301528051918290030190a17f02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c060005260026020527fb7802e97e87ef2842a6cce7da7ffaeaedaa2f61a6a7870b23d9d01fc9b73712e805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b7f0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba60005260046020527f078d888f9b66f3f8bfa10909e31f1e16240db73449f0500afdbbe3a70da457cc805460ff19166001179055565b805182906000101561234357815160141461300857600080fd5b61301182613410565b9050600160a060020a038116151561302857600080fd5b613030613417565b600160a060020a038281169116141561234357600080fd5b6000903b1190565b3031610df78282613421565b604080517f70a0823100000000000000000000000000000000000000000000000000000000815230600482015290518391600091600160a060020a038416916370a0823191602480830192602092919082900301818787803b1580156130c157600080fd5b505af11580156130d5573d6000803e3d6000fd5b505050506040513d60208110156130eb57600080fd5b50519050610888600160a060020a038516848363ffffffff61348216565b600061234382613117611ada565b613517565b60006131266119f8565b600160a060020a031663669f618b6040518163ffffffff1660e060020a028152600401602060405180830381600087803b158015611eb157600080fd5b82600260008360405160200180807f74784f75744f664c696d6974526563697069656e74000000000000000000000081525060150182600019166000191681526020019150506040516020818303038152906040526040518082805190602001908083835b602083106131e75780518252601f1990920191602091820191016131c8565b51815160209384036101000a60001901801990921691161790526040805192909401829003909120865285019590955292909201600020805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a039590951694909417909355506122ba9150839050826128d0565b806000808460405160200180807f6d65737361676556616c75650000000000000000000000000000000000000000815250600c01826000191660001916815260200191505060405160208183030381529060405260405180828051906020019080838360208310611d815780518252601f199092019160209182019101611d62565b80600260008460405160200180807f6d657373616765526563697069656e740000000000000000000000000000000081525060100182600019166000191681526020019150506040516020818303038152906040526040518082805190602001908083835b6020831061335f5780518252601f199092019160209182019101613340565b51815160209384036101000a60001901801990921691161790526040805192909401829003909120865285019590955292909201600020805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0395909516949094179093555050505050565b60006133d36119f8565b600160a060020a031663e5789d036040518163ffffffff1660e060020a028152600401602060405180830381600087803b158015611eb157600080fd5b6014015190565b600061098f610e20565b604051600160a060020a0383169082156108fc029083906000818181858888f193505050501515610df75780826134566135a0565b600160a060020a039091168152604051908190036020019082f08015801561138a573d6000803e3d6000fd5b82600160a060020a031663a9059cbb83836040518363ffffffff1660e060020a0281526004018083600160a060020a0316600160a060020a0316815260200182815260200192505050600060405180830381600087803b1580156134e557600080fd5b505af11580156134f9573d6000803e3d6000fd5b505050503d156122ba5760206000803e60005115156122ba57600080fd5b6000811515613527575081612343565b600082131561354b5761354483600a84900a63ffffffff61356216565b9050612343565b610eba836000849003600a0a63ffffffff61358b16565b600082151561357357506000612343565b5081810281838281151561358357fe5b041461234357fe5b6000818381151561359857fe5b049392505050565b6040516021806135b0833901905600608060405260405160208060218339810160405251600160a060020a038116ff00a165627a7a72305820d24bd2b9bcbb23669dc1623807c868c3055e291807df2b3b48410297f8adf24d0029", "nonce": "0x13", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xb8d67fe74fc18041298216a6e377c0536feaf70d5c3cf2a9993f9d2c5c2f03c6", "blockNumber": "0x63", "transactionIndex": "0x0"}], "totalDifficulty": "0x62ffffffffffffffffffffffffdfca83d0", "transactionsRoot": "0xecf9ecc02b9c9ae48471768d7cd668054ba045ee470d4f55ec30179502151365"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x2e3f67", "blockHash": "0xb8d67fe74fc18041298216a6e377c0536feaf70d5c3cf2a9993f9d2c5c2f03c6", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x63", "contractAddress": "0x4081b7e107e59af8e82756f96c751174590989fe", "transactionHash": "0xc7c6281dbed0ec3c350cb69339de12fa875a10e16e2addc97200dbcefba31f50", "transactionIndex": "0x0", "cumulativeGasUsed": "0x2e3f67"}]}
\\x7eb6478b401fadee5edd35307060e5e8de667e1e90b4afb382b6bed0c158ef2c	98	\\xd0cf769c48ac8ac0463110d58a08989903fbcba16f5a8baccb7bf8d01f29c71d	{"block": {"hash": "0x7eb6478b401fadee5edd35307060e5e8de667e1e90b4afb382b6bed0c158ef2c", "size": "0x6d0", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x62", "uncles": [], "gasUsed": "0x4683b", "mixHash": null, "gasLimit": "0x64bd95", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xed21583abcd18e9a88c858523d306b650279fe3b8bdb6929536a1a88fdeeff75", "timestamp": "0x60a67364", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xd0cf769c48ac8ac0463110d58a08989903fbcba16f5a8baccb7bf8d01f29c71d", "sealFields": ["0x8420377bcc", "0xb84192ec093ee3d0354f4ca672d341a42d272c0389106db512c22f760c13030535ad64b48a384c013782664ddfc06eed3dcb0ab1ac81f5e492d3dcf4efa63693c0e201"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x5b6c14fa487a0a41976d8d29691679cd999cc1ad84eea0c2dfe891bc0ce82b9c", "transactions": [{"to": null, "gas": "0x8d076", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xab7ee3184e3bd6057413a3b3d079b9356924747ee75863ff185c2f1b88f99280", "input": "0x60806040526100163364010000000061001b810204565b61003d565b60068054600160a060020a031916600160a060020a0392909216919091179055565b6103e08061004c6000396000f3006080604052600436106100775763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416633ad06d1681146100c257806354fd4d50146100e85780635c60da1b1461010f5780636fde820214610140578063a9c45fcb14610155578063f1739cae14610179575b600061008161019a565b9050600160a060020a038116151561009857600080fd5b60405136600082376000803683855af43d82016040523d6000833e8080156100be573d83f35b3d83fd5b3480156100ce57600080fd5b506100e6600435600160a060020a03602435166101a9565b005b3480156100f457600080fd5b506100fd6101d3565b60408051918252519081900360200190f35b34801561011b57600080fd5b5061012461019a565b60408051600160a060020a039092168252519081900360200190f35b34801561014c57600080fd5b506101246101d9565b6100e6600480359060248035600160a060020a0316916044359182019101356101e8565b34801561018557600080fd5b506100e6600160a060020a0360043516610250565b600854600160a060020a031690565b6101b16101d9565b600160a060020a031633146101c557600080fd5b6101cf82826102d8565b5050565b60075490565b600654600160a060020a031690565b6101f06101d9565b600160a060020a0316331461020457600080fd5b61020e84846101a9565b30600160a060020a03163483836040518083838082843782019150509250505060006040518083038185875af192505050151561024a57600080fd5b50505050565b6102586101d9565b600160a060020a0316331461026c57600080fd5b600160a060020a038116151561028157600080fd5b7f5a3e66efaa1e445ebd894728a69d6959842ea1e97bd79b892797106e270efcd96102aa6101d9565b60408051600160a060020a03928316815291841660208301528051918290030190a16102d58161037d565b50565b600854600160a060020a03828116911614156102f357600080fd5b6102fc816103ac565b151561030757600080fd5b600754821161031557600080fd5b600782905560088054600160a060020a03831673ffffffffffffffffffffffffffffffffffffffff1990911681179091556040805184815290517f4289d6195cf3c2d2174adf98d0e19d4d2d08887995b99cb7b100e7ffe795820e9181900360200190a25050565b6006805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a0392909216919091179055565b6000903b11905600a165627a7a7230582078bac02704e0c07980df83f6082a0453ef0e0259d68860b6e0f2c5dc0d11c56c0029", "nonce": "0x12", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x7eb6478b401fadee5edd35307060e5e8de667e1e90b4afb382b6bed0c158ef2c", "blockNumber": "0x62", "transactionIndex": "0x0"}], "totalDifficulty": "0x61ffffffffffffffffffffffffdfca83d2", "transactionsRoot": "0x2853b2d6f8be8f7e8f82db878a16f280c75f9959e350b8196a0fd837def1315c"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x4683b", "blockHash": "0x7eb6478b401fadee5edd35307060e5e8de667e1e90b4afb382b6bed0c158ef2c", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x62", "contractAddress": "0x41b89db86be735c03a9296437e39f5fdadc4c678", "transactionHash": "0xab7ee3184e3bd6057413a3b3d079b9356924747ee75863ff185c2f1b88f99280", "transactionIndex": "0x0", "cumulativeGasUsed": "0x4683b"}]}
\\xd0cf769c48ac8ac0463110d58a08989903fbcba16f5a8baccb7bf8d01f29c71d	97	\\xae32fb105e7af15448d4f0f530254138556ad3a395f54b8adbc0d28c470e69d5	{"block": {"hash": "0xd0cf769c48ac8ac0463110d58a08989903fbcba16f5a8baccb7bf8d01f29c71d", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x61", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x64a46d", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x9def885dbd5addd823669693608647b03930285e8eebdf6082746a72ae0d0e00", "timestamp": "0x60a67361", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0xae32fb105e7af15448d4f0f530254138556ad3a395f54b8adbc0d28c470e69d5", "sealFields": ["0x8420377bcb", "0xb841d580e8e75762ee59cb58189e5f80144ccc71826c4639d10d5e159591d26d96d32ee2e74dd379bae10faded6650c7ba6f195ce975ecb96687e3b5296e5e598f3800"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x60ffffffffffffffffffffffffdfca83d4", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xae32fb105e7af15448d4f0f530254138556ad3a395f54b8adbc0d28c470e69d5	96	\\x3ea41936adfe889d3bddda9a0070ae6ae5cf1325f752fc26eb98b08ff3b10df6	{"block": {"hash": "0xae32fb105e7af15448d4f0f530254138556ad3a395f54b8adbc0d28c470e69d5", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x60", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x648b4c", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x9def885dbd5addd823669693608647b03930285e8eebdf6082746a72ae0d0e00", "timestamp": "0x60a6735b", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x3ea41936adfe889d3bddda9a0070ae6ae5cf1325f752fc26eb98b08ff3b10df6", "sealFields": ["0x8420377bc9", "0xb841ce99e51a20e1b4b924ed41c1f2f122c463c1a2af173bc2c0e294c72fdde6d0ca0758d389b2a7bff238bbdd2ca05364d969e7df53db76dbd32af41a308c59ffde01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x5fffffffffffffffffffffffffdfca83d7", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x3ea41936adfe889d3bddda9a0070ae6ae5cf1325f752fc26eb98b08ff3b10df6	95	\\x178aebd6f171245e3326b1b7903c35af718a6e925f8eeb9756032085edafc924	{"block": {"hash": "0x3ea41936adfe889d3bddda9a0070ae6ae5cf1325f752fc26eb98b08ff3b10df6", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x5f", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x647231", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x9def885dbd5addd823669693608647b03930285e8eebdf6082746a72ae0d0e00", "timestamp": "0x60a67358", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x178aebd6f171245e3326b1b7903c35af718a6e925f8eeb9756032085edafc924", "sealFields": ["0x8420377bc8", "0xb841210bf4e4c1191b6d1a97618ab5373e8fa493673d99d9be4d4f62a2b2e02d18ee44bccb725654f1d48c62b533179c9693a6f583b7d462d99108f6c1e3d2f32fd900"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x5effffffffffffffffffffffffdfca83d9", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x178aebd6f171245e3326b1b7903c35af718a6e925f8eeb9756032085edafc924	94	\\xa8a4ff77a17736416a2e6025d2e09e1c324285c7afb9532944775178b956aebe	{"block": {"hash": "0x178aebd6f171245e3326b1b7903c35af718a6e925f8eeb9756032085edafc924", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x5e", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x64591c", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x9def885dbd5addd823669693608647b03930285e8eebdf6082746a72ae0d0e00", "timestamp": "0x60a67355", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xa8a4ff77a17736416a2e6025d2e09e1c324285c7afb9532944775178b956aebe", "sealFields": ["0x8420377bc7", "0xb841d4d44eb38ac29fc292550c9b2aff07b51594df05d4f11bc69edb0ecc439215520e316ea88e502c9574917b73dbcd8078117c0b4f10fa70753338a230d262036400"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x5dffffffffffffffffffffffffdfca83db", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xa8a4ff77a17736416a2e6025d2e09e1c324285c7afb9532944775178b956aebe	93	\\x5553cd20423825b8b955ca4c7da1a3b654a269f9f0b154d19eb92fc141e9ee68	{"block": {"hash": "0xa8a4ff77a17736416a2e6025d2e09e1c324285c7afb9532944775178b956aebe", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x5d", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x64400d", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x9def885dbd5addd823669693608647b03930285e8eebdf6082746a72ae0d0e00", "timestamp": "0x60a67352", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x5553cd20423825b8b955ca4c7da1a3b654a269f9f0b154d19eb92fc141e9ee68", "sealFields": ["0x8420377bc6", "0xb8411c08930f986d2443a0f6019256186c98540039d1dc56c4482d1809afdf418a4e430424f9e9b118f323ce3c7c91ee6bda5b0e77ea035ecf1e7d7d65e2a33365a000"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x5cffffffffffffffffffffffffdfca83dd", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x5553cd20423825b8b955ca4c7da1a3b654a269f9f0b154d19eb92fc141e9ee68	92	\\xbd24ade8f2f68ac53290d16fb57fba3427fcacd738804ef01db2ab8c8842e537	{"block": {"hash": "0x5553cd20423825b8b955ca4c7da1a3b654a269f9f0b154d19eb92fc141e9ee68", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x5c", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x642705", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x9def885dbd5addd823669693608647b03930285e8eebdf6082746a72ae0d0e00", "timestamp": "0x60a6734c", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xbd24ade8f2f68ac53290d16fb57fba3427fcacd738804ef01db2ab8c8842e537", "sealFields": ["0x8420377bc4", "0xb841faf11188d0bbd0edf2ee4722355975729356bca36254c229c33819e46d09c69a6c56f881f72cf85c960f37c90e31c0e8f430b31ccf163e6763978fac1ef8b2b301"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x5bffffffffffffffffffffffffdfca83e0", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xbd24ade8f2f68ac53290d16fb57fba3427fcacd738804ef01db2ab8c8842e537	91	\\x2513552b19251ca6505d7bbf1698210d0950971fb980425b9a5b11f368bf37b4	{"block": {"hash": "0xbd24ade8f2f68ac53290d16fb57fba3427fcacd738804ef01db2ab8c8842e537", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x5b", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x640e03", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x9def885dbd5addd823669693608647b03930285e8eebdf6082746a72ae0d0e00", "timestamp": "0x60a67349", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x2513552b19251ca6505d7bbf1698210d0950971fb980425b9a5b11f368bf37b4", "sealFields": ["0x8420377bc3", "0xb8416fe8344dfe734e5be9b590bdf1d0cb6223d418f3126fe518a8ffd84cbfe70f391353350c7f0c3f25fa3c151106ba840ef4bf7ad252d60e2595cb1a56e04244ed00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x5affffffffffffffffffffffffdfca83e2", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xf4f36daefc595c63ba0e0c0bfb4361900b07df09bc564271ae1e6ee83fbaa4f6	142	\\xfacba8827d937891d382a254270147631c8ca9d967fb642f7ab237946cc2c7c6	{"block": {"hash": "0xf4f36daefc595c63ba0e0c0bfb4361900b07df09bc564271ae1e6ee83fbaa4f6", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8e", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x69290b", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a67a08", "difficulty": "0xfffffffffffffffffffffffffffffff2", "parentHash": "0xfacba8827d937891d382a254270147631c8ca9d967fb642f7ab237946cc2c7c6", "sealFields": ["0x8420377dfe", "0xb84146a85d35030f54342d9ae2161c55efd6ad5c8c8d4f9588f522056fa72b0949d53ec4d86ebf489cd162c3a53c0a8a09ecc1c1ead08c179073166deb8667d3c6e900"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x8dffffffffffffffffffffffffdfca8174", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x3e76831e8256834b341768c9c55f7d29380d03d6e2063dd987411036e4f4b37e	143	\\xf4f36daefc595c63ba0e0c0bfb4361900b07df09bc564271ae1e6ee83fbaa4f6	{"block": {"hash": "0x3e76831e8256834b341768c9c55f7d29380d03d6e2063dd987411036e4f4b37e", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8f", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x694354", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a67bac", "difficulty": "0xfffffffffffffffffffffffffffffff9", "parentHash": "0xf4f36daefc595c63ba0e0c0bfb4361900b07df09bc564271ae1e6ee83fbaa4f6", "sealFields": ["0x8420377e04", "0xb84105311921a84f0e5ea76ecb699a55abf2919dc5827908328fd5560153754f3eec5a400909d133bebb506bec64a2c03050098080b0c62928b4e8d89a07e0db055500"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x8effffffffffffffffffffffffdfca816d", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x96e3a5e23b3e142511b8b8a201dfc36662772764cdfe14264e6731ec0f5638b7	144	\\x3e76831e8256834b341768c9c55f7d29380d03d6e2063dd987411036e4f4b37e	{"block": {"hash": "0x96e3a5e23b3e142511b8b8a201dfc36662772764cdfe14264e6731ec0f5638b7", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x90", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x695da3", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a67bb9", "difficulty": "0xffffffffffffffffffffffffffffff73", "parentHash": "0x3e76831e8256834b341768c9c55f7d29380d03d6e2063dd987411036e4f4b37e", "sealFields": ["0x8420377e90", "0xb841fe6424a0f8b76a287da66bee117ecdb9ddf1708eab922c9a839c6a86501194b72a0c2bc88b8dd0a8cd948ed225e97f3f2f0545b8d21d7affb16c1bf538456a8801"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x8fffffffffffffffffffffffffdfca80e0", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x959bbcc51566e0325eba69ef30d937ecc29a4599c373b43ccee4ef10e1fd877c	145	\\x96e3a5e23b3e142511b8b8a201dfc36662772764cdfe14264e6731ec0f5638b7	{"block": {"hash": "0x959bbcc51566e0325eba69ef30d937ecc29a4599c373b43ccee4ef10e1fd877c", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x91", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6977f9", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a67d19", "difficulty": "0xfffffffffffffffffffffffffffffffb", "parentHash": "0x96e3a5e23b3e142511b8b8a201dfc36662772764cdfe14264e6731ec0f5638b7", "sealFields": ["0x8420377e94", "0xb8414cfa2181c7072281d02d4f60032e10c62a539b76cb8988822419e3dfb26d921c263372325ae5eee4d26922052136fa0bac5c14bdc7e1ac7f4c18e2402c3d9e1e00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x90ffffffffffffffffffffffffdfca80db", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x374b16e431b242769d8cf5bedd9c2fde9d6872966b7792b41d759d8a1fa901da	0	\\x0000000000000000000000000000000000000000000000000000000000000000	{"block": {"hash": "0x374b16e431b242769d8cf5bedd9c2fde9d6872966b7792b41d759d8a1fa901da", "size": "0x215", "miner": "0x0000000000000000000000000000000000000000", "nonce": null, "number": "0x0", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x5b8d80", "extraData": "0x", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xa7d0c478c52c435abb2df13fa713c0d5ce404c8c5b74cac8e5610ff0131389a5", "timestamp": "0x0", "difficulty": "0x20000", "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000", "sealFields": ["0x80", "0xb8410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x20000", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x5ae189121b6b9da08db702583d91be75d6c339cd27e0148ad4b28738af4f808b	10	\\xed048a17acdd032559bff987c389fd0e54ebec78d6330ca899b75c9515a5791b	{"block": {"hash": "0x5ae189121b6b9da08db702583d91be75d6c339cd27e0148ad4b28738af4f808b", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x5c7356", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xa7d0c478c52c435abb2df13fa713c0d5ce404c8c5b74cac8e5610ff0131389a5", "timestamp": "0x60a6720e", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xed048a17acdd032559bff987c389fd0e54ebec78d6330ca899b75c9515a5791b", "sealFields": ["0x8420377b5a", "0xb841d8540323a296d4d68c9778e981f006c98b7b4b5827ebfc954331ba3a2b39ae09216ff5b846ef51586427060e30cdc037d6e28bf62219e26d1fd67c4447f00b6b01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x9ffffffffffffffffffffffffdfca849c", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x139c57b86dd3b31d072832e211efc1e6aeb7e6b5e5cbcd248cb19498c1baa63e	146	\\x959bbcc51566e0325eba69ef30d937ecc29a4599c373b43ccee4ef10e1fd877c	{"block": {"hash": "0x139c57b86dd3b31d072832e211efc1e6aeb7e6b5e5cbcd248cb19498c1baa63e", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x92", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x699255", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a67f9a", "difficulty": "0xffffffffffffffffffffffffffffff89", "parentHash": "0x959bbcc51566e0325eba69ef30d937ecc29a4599c373b43ccee4ef10e1fd877c", "sealFields": ["0x8420377f0a", "0xb841966906534b91d4f8b8fec49d4b9295833f1cd413c21567711d15927ee99654723dd5696976d980932b38011a91f100ae2cffcac75a88af31e35747fed9326c5600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x91ffffffffffffffffffffffffdfca8064", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x8b51a6198d9108267f293f0281b2c175e4e8ddae8259b30676215200cc881b8a	147	\\x139c57b86dd3b31d072832e211efc1e6aeb7e6b5e5cbcd248cb19498c1baa63e	{"block": {"hash": "0x8b51a6198d9108267f293f0281b2c175e4e8ddae8259b30676215200cc881b8a", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x93", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x69acb8", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a67fa0", "difficulty": "0xffffffffffffffffffffffffffffff29", "parentHash": "0x139c57b86dd3b31d072832e211efc1e6aeb7e6b5e5cbcd248cb19498c1baa63e", "sealFields": ["0x8420377fe0", "0xb8414164f60892902d10fd09d5e30c63769948e31438d88d3fac62001291035a100459308b9e65efcc0255383d84d2bf8ab1c98c9f96684afcdc9373041ce921133801"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x92ffffffffffffffffffffffffdfca7f8d", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xf35905dd1c55e8284389fe7d95285bf2d34d60ce38cff2188bfec63e65e0b3b7	148	\\x8b51a6198d9108267f293f0281b2c175e4e8ddae8259b30676215200cc881b8a	{"block": {"hash": "0xf35905dd1c55e8284389fe7d95285bf2d34d60ce38cff2188bfec63e65e0b3b7", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x94", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x69c722", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a67fc3", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x8b51a6198d9108267f293f0281b2c175e4e8ddae8259b30676215200cc881b8a", "sealFields": ["0x8420377fe1", "0xb8417b4677b6eb0d966871846b9bda8528c05690f1b333e6c26c973a2bbb76557d7e45ce2779e8da934838ebf2a92c08ef515c10adcbb52c0b59f2a1e39442d9ee7c01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x93ffffffffffffffffffffffffdfca7f8b", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x67c3641b0c3f2b27d738e82a75015f69afaf54401badb75f921b0947b4f800d7	149	\\xf35905dd1c55e8284389fe7d95285bf2d34d60ce38cff2188bfec63e65e0b3b7	{"block": {"hash": "0x67c3641b0c3f2b27d738e82a75015f69afaf54401badb75f921b0947b4f800d7", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x95", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x69e192", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x83dfd73a6ecc322c1b6eb5be107b7d0ec664ee5c63d740f5d1b1ee1f53c1dadc", "timestamp": "0x60a67fc7", "difficulty": "0xfffffffffffffffffffffffffffffff3", "parentHash": "0xf35905dd1c55e8284389fe7d95285bf2d34d60ce38cff2188bfec63e65e0b3b7", "sealFields": ["0x8420377fed", "0xb841079c8e60da0a45922a3fee9702bf00038209518ef8dc3365bbb0939be9a9acc356aee089c2650a25fb88923c198aef47e432c7403d7c00ca42b494d62876921901"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x94ffffffffffffffffffffffffdfca7f7e", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x933079d0e43a0403fed8ce97a75b8972606c65a40813cb37ed69d79add20b14d	170	\\x971559b5b743f085142391cd3f89ded2fc7f17151a9198ba0d13467081e71da4	{"block": {"hash": "0x933079d0e43a0403fed8ce97a75b8972606c65a40813cb37ed69d79add20b14d", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xaa", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6c12c9", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc34", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x971559b5b743f085142391cd3f89ded2fc7f17151a9198ba0d13467081e71da4", "sealFields": ["0x84203afebc", "0xb8415ab96a6df2a8195633a920703f87c70a00a5d5f67791febc7800c463b06aba8257c87ee9178e1022cfa08e0fa8c15bde918b173e6c424689849e8351177b0eba00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xa9ffffffffffffffffffffffffdfc7009a", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x971559b5b743f085142391cd3f89ded2fc7f17151a9198ba0d13467081e71da4	169	\\x384c812d388a6cad81f71c36e21b66e300462a5757d74a5b748f4d2f9a909ad2	{"block": {"hash": "0x971559b5b743f085142391cd3f89ded2fc7f17151a9198ba0d13467081e71da4", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa9", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6bf7cd", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc31", "difficulty": "0xfffffffffffffffffffffffffffffff2", "parentHash": "0x384c812d388a6cad81f71c36e21b66e300462a5757d74a5b748f4d2f9a909ad2", "sealFields": ["0x84203afebb", "0xb841a3eb1e8bfeb62d524ef4e1ff01754de8295549164137ea699a93e516caef01967ac9ac6050eef7d32880dd0d281beb3bd32cfff6d045dc318fe66e426ab8b1b900"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xa8ffffffffffffffffffffffffdfc7009c", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x384c812d388a6cad81f71c36e21b66e300462a5757d74a5b748f4d2f9a909ad2	168	\\x6294a7f55cc1e026a9fe7e3becf19c933f6b5f2694ab81bb69f562d171afa9ce	{"block": {"hash": "0x384c812d388a6cad81f71c36e21b66e300462a5757d74a5b748f4d2f9a909ad2", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa8", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6bdcd7", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc2c", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x6294a7f55cc1e026a9fe7e3becf19c933f6b5f2694ab81bb69f562d171afa9ce", "sealFields": ["0x84203afeae", "0xb841d0d08c6ef97f3eed3346ca071c4f270e0077ec4fbb9747169a4c3b3a96f26f535cc02f802462c17674b29596457b3c35bd98de3a2a6a46c52710d457c497c0be01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xa7ffffffffffffffffffffffffdfc700aa", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x6294a7f55cc1e026a9fe7e3becf19c933f6b5f2694ab81bb69f562d171afa9ce	167	\\xcc3be090903b813899f128fd00086de527d5533b7936a94f554913e178a127dc	{"block": {"hash": "0x6294a7f55cc1e026a9fe7e3becf19c933f6b5f2694ab81bb69f562d171afa9ce", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa7", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6bc1e8", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc07", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xcc3be090903b813899f128fd00086de527d5533b7936a94f554913e178a127dc", "sealFields": ["0x84203afead", "0xb84174128dc3b17b14e5f5a3b47c59af6e0805faac7806b14a10945baefbca568a3e0120feea7424a30466919a73f7933b12d3cee419ff723c718dbb7cc842b248fe00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xa6ffffffffffffffffffffffffdfc700ac", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xcc3be090903b813899f128fd00086de527d5533b7936a94f554913e178a127dc	166	\\x8032551d0c9c84e0b93b470080003d71238cbc57d31b7eaaa848e21740124541	{"block": {"hash": "0xcc3be090903b813899f128fd00086de527d5533b7936a94f554913e178a127dc", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa6", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6ba700", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc04", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x8032551d0c9c84e0b93b470080003d71238cbc57d31b7eaaa848e21740124541", "sealFields": ["0x84203afeac", "0xb841ad5d1ccec6c446ee624ad23ba73e1a60b4c74351e3ed6d729ee501dd9a0535fe7ce5fe9b18f55bc5281c5e6671a64ed0f9ad21fe4c59897aeb50ee11ea3d6ad101"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xa5ffffffffffffffffffffffffdfc700ae", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x8032551d0c9c84e0b93b470080003d71238cbc57d31b7eaaa848e21740124541	165	\\x4229f616315802c4363bb904a6752f7e7e8d9132ea45f955e95fc15c285c2cff	{"block": {"hash": "0x8032551d0c9c84e0b93b470080003d71238cbc57d31b7eaaa848e21740124541", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa5", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6b8c1e", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc01", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x4229f616315802c4363bb904a6752f7e7e8d9132ea45f955e95fc15c285c2cff", "sealFields": ["0x84203afeab", "0xb841f40af1c588c9e3ac09bd6f6df6d679a8ad2a2fd9cdccc33150f54e279105c5c13991edc53ef05e67ff9b8cee05ff4032d7249918fcabd224cabe23e39cd03a5c01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xa4ffffffffffffffffffffffffdfc700b0", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x4229f616315802c4363bb904a6752f7e7e8d9132ea45f955e95fc15c285c2cff	164	\\x778eff3f6dc2fe713fca101cdac7086ce81cce61b0c1fab56b4d5d72ee3724a7	{"block": {"hash": "0x4229f616315802c4363bb904a6752f7e7e8d9132ea45f955e95fc15c285c2cff", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa4", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6b7143", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fbfb", "difficulty": "0xfffffffffffffffffffffffffffffff8", "parentHash": "0x778eff3f6dc2fe713fca101cdac7086ce81cce61b0c1fab56b4d5d72ee3724a7", "sealFields": ["0x84203afea9", "0xb8413942f23e22cfda8b93b0a27e003a7d012ed6ab89600ce3b57507dc15429d24816b2ecfccee63f82adeb7cd9ae11a6bb26b4ba6c7edf5ca63cf287dbcbb39a2d301"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xa3ffffffffffffffffffffffffdfc700b3", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x778eff3f6dc2fe713fca101cdac7086ce81cce61b0c1fab56b4d5d72ee3724a7	163	\\xd95d0033a47ad6e933a049db515bd7044b82ff8d29f3dda0d9fab76f282bbbf6	{"block": {"hash": "0x778eff3f6dc2fe713fca101cdac7086ce81cce61b0c1fab56b4d5d72ee3724a7", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa3", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6b566f", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fbf8", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xd95d0033a47ad6e933a049db515bd7044b82ff8d29f3dda0d9fab76f282bbbf6", "sealFields": ["0x84203afea2", "0xb84196252b9b7f09a2ac275bb0785aff7c7c597fc79cd9a9faac1b2d3067ca622809266fd865c696161442ece859d997a8bf52b3ca19a04cf84e1db03ca912185e5200"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xa2ffffffffffffffffffffffffdfc700bb", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xd95d0033a47ad6e933a049db515bd7044b82ff8d29f3dda0d9fab76f282bbbf6	162	\\xbfa5d9670462954f3afd38ad07928528c2d4c6c4b5207cfdb13c3d2bc8f2fd58	{"block": {"hash": "0xd95d0033a47ad6e933a049db515bd7044b82ff8d29f3dda0d9fab76f282bbbf6", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa2", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6b3ba2", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fbe3", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xbfa5d9670462954f3afd38ad07928528c2d4c6c4b5207cfdb13c3d2bc8f2fd58", "sealFields": ["0x84203afea1", "0xb841bf84f3629f8bfa7558c5f84104d5e7a30dd3405ae83448122465201b106678b535e9ab5711c7f83be4096ce4d473d30b6fb425de614733bae00bb5ad3a49b6a600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xa1ffffffffffffffffffffffffdfc700bd", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xbfa5d9670462954f3afd38ad07928528c2d4c6c4b5207cfdb13c3d2bc8f2fd58	161	\\x4a7e568f8c911075a659003eb7c530916211751cc31ae062d946e3d310fadeb6	{"block": {"hash": "0xbfa5d9670462954f3afd38ad07928528c2d4c6c4b5207cfdb13c3d2bc8f2fd58", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa1", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6b20db", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fbe0", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x4a7e568f8c911075a659003eb7c530916211751cc31ae062d946e3d310fadeb6", "sealFields": ["0x84203afea0", "0xb84175f908d629cc045b23cc345938c3a3330757a2b5cef392e3c9a38fec9b2959ff389fa8508d3b818788ea4779e32dbe98d259da181c791e60ccdae9317856748a01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xa0ffffffffffffffffffffffffdfc700bf", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x4a7e568f8c911075a659003eb7c530916211751cc31ae062d946e3d310fadeb6	160	\\xab8b9fc1c5540d7bdc9b4fe5a5a41cde89ee2534d348d6af6f91448a188eb457	{"block": {"hash": "0x4a7e568f8c911075a659003eb7c530916211751cc31ae062d946e3d310fadeb6", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xa0", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6b061b", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fbdd", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xab8b9fc1c5540d7bdc9b4fe5a5a41cde89ee2534d348d6af6f91448a188eb457", "sealFields": ["0x84203afe9f", "0xb8413b304590e3f93f30dfa55985ac5da41de996f954a8e476c1af03ca8505d189be427e68817daf0ad93418f18276f2cb2a7f182ef8f67cd590c57d323a1e913f0301"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x9fffffffffffffffffffffffffdfc700c1", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xab8b9fc1c5540d7bdc9b4fe5a5a41cde89ee2534d348d6af6f91448a188eb457	159	\\xea4ebeec8843c5ed8347dcf2467d17a6b11b918cf0c29425d0b523cae6c1a03a	{"block": {"hash": "0xab8b9fc1c5540d7bdc9b4fe5a5a41cde89ee2534d348d6af6f91448a188eb457", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x9f", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6aeb62", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fbda", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0xea4ebeec8843c5ed8347dcf2467d17a6b11b918cf0c29425d0b523cae6c1a03a", "sealFields": ["0x84203afe9e", "0xb8417b2d58493c256799d4fbbeaf7683ab8c97b23481dcb0db757957867b43df40f34e4e964efe388d906904e2fbc083d8fca9438fd39a1a81a06fe08918e9dd3ef600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x9effffffffffffffffffffffffdfc700c3", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xea4ebeec8843c5ed8347dcf2467d17a6b11b918cf0c29425d0b523cae6c1a03a	158	\\xd762f1ff2a344747feb875fc11b8a248e5d6f6a2b4217769568e15763b014b55	{"block": {"hash": "0xea4ebeec8843c5ed8347dcf2467d17a6b11b918cf0c29425d0b523cae6c1a03a", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x9e", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6ad0af", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fbd4", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xd762f1ff2a344747feb875fc11b8a248e5d6f6a2b4217769568e15763b014b55", "sealFields": ["0x84203afe9c", "0xb841f419b76d74e4e3d3a9d238183687740941228740381be6dfde26357058886d5954c59f5dd0e990e406e4743bacc3a2381c5a4d5125efcc1592a7151cb4ac645c01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x9dffffffffffffffffffffffffdfc700c6", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xd762f1ff2a344747feb875fc11b8a248e5d6f6a2b4217769568e15763b014b55	157	\\xb6693224e9b73792d4878061027f5ef93cf78c472d2b4c609a40c70ee1fe773c	{"block": {"hash": "0xd762f1ff2a344747feb875fc11b8a248e5d6f6a2b4217769568e15763b014b55", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x9d", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6ab603", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fbd1", "difficulty": "0xfffffffffffffffffffffffffffffff2", "parentHash": "0xb6693224e9b73792d4878061027f5ef93cf78c472d2b4c609a40c70ee1fe773c", "sealFields": ["0x84203afe9b", "0xb841a71af1437740d4f3369d699196c9225d3022251b0df41a309c5bae4d40c0151345c5ff077262679fa6d971d33941edb45740e56446dba3f21d295dc3219fffe600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x9cffffffffffffffffffffffffdfc700c8", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xb6693224e9b73792d4878061027f5ef93cf78c472d2b4c609a40c70ee1fe773c	156	\\x226d1baf091df6b6e7647e349b07b5489407391d395715b7a03a01951ad9df79	{"block": {"hash": "0xb6693224e9b73792d4878061027f5ef93cf78c472d2b4c609a40c70ee1fe773c", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x9c", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6a9b5e", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fbcd", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x226d1baf091df6b6e7647e349b07b5489407391d395715b7a03a01951ad9df79", "sealFields": ["0x84203afe8e", "0xb841fb16c81d54608dce28ee532a5f68fda00184b9d63fc3af58618e701d959f18244f704a7aa0c14087c04811308d3f4df92e97884d40429c69aaa58fb271e282ba01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x9bffffffffffffffffffffffffdfc700d6", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x226d1baf091df6b6e7647e349b07b5489407391d395715b7a03a01951ad9df79	155	\\x911beb60c8e10ca695cef2459c4db6874412df583a183b7cb507cc8cbf712f69	{"block": {"hash": "0x226d1baf091df6b6e7647e349b07b5489407391d395715b7a03a01951ad9df79", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x9b", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6a80bf", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fba4", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x911beb60c8e10ca695cef2459c4db6874412df583a183b7cb507cc8cbf712f69", "sealFields": ["0x84203afe8c", "0xb841fc2a5c06f4318d1b1d5aa755516fcfbfb9d1403d665381b1277b712f158ae045249e6ec605b728b5a2feece3561afc7db94b418c91ea02d20b92258f657e411500"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x9affffffffffffffffffffffffdfc700d9", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x911beb60c8e10ca695cef2459c4db6874412df583a183b7cb507cc8cbf712f69	154	\\x804f8f2f87a170325539997ef82595e64d769e321227958436716a5619657b1f	{"block": {"hash": "0x911beb60c8e10ca695cef2459c4db6874412df583a183b7cb507cc8cbf712f69", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x9a", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6a6627", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fba1", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x804f8f2f87a170325539997ef82595e64d769e321227958436716a5619657b1f", "sealFields": ["0x84203afe8b", "0xb8414cf4c242b8762b192eecf8cf3bd0c4bb3edc1b88920328d63f2480aaf1c494ec7ee8c3de58ea8db6447ac73bcdb258377dca90b51ba76a5210d694da8240e1a501"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x99ffffffffffffffffffffffffdfc700db", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x804f8f2f87a170325539997ef82595e64d769e321227958436716a5619657b1f	153	\\x8c5bf19c683e8d7e7605f6fe08ee076ec2fa1b71ff668a40defcc969f56b1814	{"block": {"hash": "0x804f8f2f87a170325539997ef82595e64d769e321227958436716a5619657b1f", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x99", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6a4b96", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fb9b", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x8c5bf19c683e8d7e7605f6fe08ee076ec2fa1b71ff668a40defcc969f56b1814", "sealFields": ["0x84203afe89", "0xb841b4494670a9a4253191995846f335586247837e6df05b8211993a3fddab39803a4b3a6f2f8f4362e6d2579e41773c8bce09f39ccd65a21e5da3c2f94b6bb5f0f000"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x98ffffffffffffffffffffffffdfc700de", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x8c5bf19c683e8d7e7605f6fe08ee076ec2fa1b71ff668a40defcc969f56b1814	152	\\x096be2141e49a64eecc51f712e0bb30194b4c81d756d57303eb5e66d9daf9781	{"block": {"hash": "0x8c5bf19c683e8d7e7605f6fe08ee076ec2fa1b71ff668a40defcc969f56b1814", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x98", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6a310b", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fb98", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x096be2141e49a64eecc51f712e0bb30194b4c81d756d57303eb5e66d9daf9781", "sealFields": ["0x84203afe88", "0xb8419cfff3b5fdfae995877aee8bb53e92eb84339ffa8571daa6460499ad14d2f70258f3b257069db3d836a61b839a2a381e5d7fda3983ac7d44e848f4685c4ca2a701"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x97ffffffffffffffffffffffffdfc700e0", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x096be2141e49a64eecc51f712e0bb30194b4c81d756d57303eb5e66d9daf9781	151	\\x2af1693a193d2cc7cdd0afef13dec848cb6fe003af1c066ab76c072202ebe640	{"block": {"hash": "0x096be2141e49a64eecc51f712e0bb30194b4c81d756d57303eb5e66d9daf9781", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x97", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6a1687", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fb95", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x2af1693a193d2cc7cdd0afef13dec848cb6fe003af1c066ab76c072202ebe640", "sealFields": ["0x84203afe87", "0xb8415725ea611d61153cb48726f1272d30e2aedf568f97fb6646449636e09f812e5322711e8c76fb48bd67a788542b3e8fda08f06511760011df06b366e78de5b42c00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x96ffffffffffffffffffffffffdfc700e2", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x2af1693a193d2cc7cdd0afef13dec848cb6fe003af1c066ab76c072202ebe640	150	\\x84b92f175de875e069ce71c04851f68671b934c93d039544fe854a0cbc185f77	{"block": {"hash": "0x2af1693a193d2cc7cdd0afef13dec848cb6fe003af1c066ab76c072202ebe640", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x96", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x69fc09", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fb92", "difficulty": "0xfffffffffffffffffffffffffffc8316", "parentHash": "0x84b92f175de875e069ce71c04851f68671b934c93d039544fe854a0cbc185f77", "sealFields": ["0x84203afe86", "0xb841485bc268530c4d36d921338385f1aa5c156021babb7e6403370d3ba6fb5348bc30082ab8bc75c43f44a90162bb5c16ccfed24fd6b85d22764e91ba1beaac2bbf01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x95ffffffffffffffffffffffffdfc700e4", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x84b92f175de875e069ce71c04851f68671b934c93d039544fe854a0cbc185f77	149	\\xdb5d1dc8b6bbaa86fb8137bab36f452698aad4f999283d0e71322330defe8331	{"block": {"hash": "0x84b92f175de875e069ce71c04851f68671b934c93d039544fe854a0cbc185f77", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x95", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x69e192", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60a684d7", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0xdb5d1dc8b6bbaa86fb8137bab36f452698aad4f999283d0e71322330defe8331", "sealFields": ["0x842037819d", "0xb841093b070588093a6d6ae19301490f0a84d3b42bc7548cbab51be8e9aa362bbf3d4ca7b4f17da313d4e77ee7255a62acba350996251d4c041643c6a4dd7ed7fbb601"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x94ffffffffffffffffffffffffdfca7dce", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xdb5d1dc8b6bbaa86fb8137bab36f452698aad4f999283d0e71322330defe8331	148	\\x7dfb81a2794b9fb0745747a12da999ee935ac41e48a4b46c805cd1163f485e65	{"block": {"hash": "0xdb5d1dc8b6bbaa86fb8137bab36f452698aad4f999283d0e71322330defe8331", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x94", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x69c722", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60a684d1", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x7dfb81a2794b9fb0745747a12da999ee935ac41e48a4b46c805cd1163f485e65", "sealFields": ["0x842037819b", "0xb841a8bdf7f86bf37399a31326cb484876b7bf639a6943452cd011a728d29218d1b019db0fe971138b83b054b3e661e0d35b2f21377c60f5e8bab1e1cce507d0623d01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x93ffffffffffffffffffffffffdfca7dd1", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x7dfb81a2794b9fb0745747a12da999ee935ac41e48a4b46c805cd1163f485e65	147	\\xb0f9464b893f4492dfa0448040b178a04e2a56bd9c5df46b86f5d4b20533ddfd	{"block": {"hash": "0x7dfb81a2794b9fb0745747a12da999ee935ac41e48a4b46c805cd1163f485e65", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x93", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x69acb8", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60a684ce", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xb0f9464b893f4492dfa0448040b178a04e2a56bd9c5df46b86f5d4b20533ddfd", "sealFields": ["0x842037819a", "0xb84176fb5333f7569b7575b861881979fa2fa6d9146bf35ef57bd3b053e73f5b3ae005e9e6ea82a3fcdc9727abf8c0a3b63bd31d8a65ead13b7b5e1fcc501e66621f01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x92ffffffffffffffffffffffffdfca7dd3", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xb0f9464b893f4492dfa0448040b178a04e2a56bd9c5df46b86f5d4b20533ddfd	146	\\xc7104402a5e69e699f2e8a531814e6424bc8112137933fe95cf8faf9bbd2874c	{"block": {"hash": "0xb0f9464b893f4492dfa0448040b178a04e2a56bd9c5df46b86f5d4b20533ddfd", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x92", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x699255", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60a684cb", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xc7104402a5e69e699f2e8a531814e6424bc8112137933fe95cf8faf9bbd2874c", "sealFields": ["0x8420378199", "0xb8411a7b9563ebcc4640bade63bb9e352a8a6e427706b8b45644e4f774f28a0f46b30679b9c487c29d8dd1c0a6fb9f2d76d21a7dabb8dd95e76dafd47a6668edd6ec00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x91ffffffffffffffffffffffffdfca7dd5", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xc7104402a5e69e699f2e8a531814e6424bc8112137933fe95cf8faf9bbd2874c	145	\\xda67362114c6bbf02e55e43ddb21fd327d9f6c661571bf16c9bdd949dadcb164	{"block": {"hash": "0xc7104402a5e69e699f2e8a531814e6424bc8112137933fe95cf8faf9bbd2874c", "size": "0x10e6", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x91", "uncles": [], "gasUsed": "0xd2c19", "mixHash": null, "gasLimit": "0x6977f9", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60a684c8", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0xda67362114c6bbf02e55e43ddb21fd327d9f6c661571bf16c9bdd949dadcb164", "sealFields": ["0x8420378198", "0xb8418fb57ba1a10a780b5738d1b3a48bdb17f92230dfc828964f6637ec97e4f9f7227f930f28ff293027200420a6f44cf912d7d77065758dab1ff55414b486faf4a101"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x07c8c175b5e002b797aa81f397cecaaed5537a9d4d5918b5f017543c38d4d6c2", "transactions": [{"to": null, "gas": "0x5b8d80", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x9c40ecf257e0dde6129d51a8657269186545ea11877666e4389f2a5cffb6e0fd", "input": "0x608060405234801561001057600080fd5b50604051610dff380380610dff8339818101604052604081101561003357600080fd5b508051602090910151600080546001600160a01b03199081163317909155600680546001600160a01b0394851690831617905560028054939092169216919091179055610d7a806100856000396000f3fe6080604052600436106100f75760003560e01c8063afc6224b1161008a578063f0ef0b0611610059578063f0ef0b0614610322578063f2fde38b1461034c578063f7c1329e1461037f578063fc0c546a14610394576100fe565b8063afc6224b146102bc578063cfeef807146102e3578063e22ab5ae146102f8578063e30c39781461030d576100fe565b806337dd8b05116100c657806337dd8b051461023c5780634e51a863146102685780634e71e0c8146102925780638da5cb5b146102a7576100fe565b80631062b39a1461010357806317c2a98c14610134578063187ac4cb14610167578063325ff66f1461017c576100fe565b366100fe57005b600080fd5b34801561010f57600080fd5b506101186103a9565b604080516001600160a01b039092168252519081900360200190f35b34801561014057600080fd5b506101186004803603602081101561015757600080fd5b50356001600160a01b031661048d565b34801561017357600080fd5b506101186104b2565b34801561018857600080fd5b506101186004803603604081101561019f57600080fd5b6001600160a01b0382351691908101906040810160208201356401000000008111156101ca57600080fd5b8201836020820111156101dc57600080fd5b803590602001918460208302840111640100000000831117156101fe57600080fd5b9190808060200260200160405190810160405280939291908181526020018383602002808284376000920191909152509295506104c1945050505050565b34801561024857600080fd5b506102666004803603602081101561025f57600080fd5b50356107bd565b005b34801561027457600080fd5b506102666004803603602081101561028b57600080fd5b5035610853565b34801561029e57600080fd5b506102666108e8565b3480156102b357600080fd5b5061011861099e565b3480156102c857600080fd5b506102d16109ad565b60408051918252519081900360200190f35b3480156102ef57600080fd5b506101186109b3565b34801561030457600080fd5b506102d16109c2565b34801561031957600080fd5b506101186109c8565b34801561032e57600080fd5b506102666004803603602081101561034557600080fd5b50356109d7565b34801561035857600080fd5b506102666004803603602081101561036f57600080fd5b50356001600160a01b0316610a6c565b34801561038b57600080fd5b506102d1610ad9565b3480156103a057600080fd5b50610118610adf565b6006546040805163533426d160e01b815290516000926001600160a01b03169163533426d1916004808301926020929190829003018186803b1580156103ee57600080fd5b505afa158015610402573d6000803e3d6000fd5b505050506040513d602081101561041857600080fd5b50516040805163cd59658360e01b815290516001600160a01b039092169163cd59658391600480820192602092909190829003018186803b15801561045c57600080fd5b505afa158015610470573d6000803e3d6000fd5b505050506040513d602081101561048657600080fd5b5051905090565b6002546000906104ac906001600160a01b039081169030908516610b24565b92915050565b6006546001600160a01b031681565b60006104cb6103a9565b6001600160a01b0316336001600160a01b03161461051b576040805162461bcd60e51b815260206004820152600860248201526737b7363cafa0a6a160c11b604482015290519081900360640190fd5b60006105256103a9565b6001600160a01b031663d67bdd256040518163ffffffff1660e01b815260040160206040518083038186803b15801561055d57600080fd5b505afa158015610571573d6000803e3d6000fd5b505050506040513d602081101561058757600080fd5b50516006546005546040516001600160a01b0388811660248301908152938116604483018190529085166084830181905260a4830184905260a060648401908152895160c4850152895196975090956060958b9593948b948a949093909160e401906020878101910280838360005b8381101561060e5781810151838201526020016105f6565b50506040805193909501838103601f1901845290945250602081018051634d6b976f60e01b6001600160e01b03909116179052600254909a5060009950610672985061066b97506001600160a01b03169550610b90945050505050565b8385610be2565b600254604080516001600160a01b0392831681529051929350818a1692828516928816917f90d0a5d098b9a181ff8ddc866f840cc210e5b91eaf27bc267d5822a0deafad25919081900360200190a4600354158015906106d457506003544710155b1561073a576003546040516001600160a01b0383169180156108fc02916000818181858888f193505050501561073a5760035460408051918252517f517165f169759cdb94227d1c50f4f47895eb099a7f04a780f519bf1739face6f9181900360200190a15b6004541580159061074d57506004544710155b156107b3576004546040516001600160a01b0389169180156108fc02916000818181858888f19350505050156107b35760045460408051918252517f69e30c0bf438d0d3e0afb7f68d57ef394a0d5e8712f82fa00aa599e42574bc2a9181900360200190a15b9695505050505050565b6000546001600160a01b03163314610808576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b60055481141561081757610850565b60058190556040805182815290517f7a78bdfbfb2e909f35c05c77e80038cfd0a22c704748eba8b1d20aab76cd5d9c9181900360200190a15b50565b6000546001600160a01b0316331461089e576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b6003548114156108ad57610850565b60038190556040805182815290517fa02ce31a8a8adcdc2e2811a0c7f5d1eb1aa920ca9fdfaeaebfe3a2163e69a6549181900360200190a150565b6001546001600160a01b0316331461093a576040805162461bcd60e51b815260206004820152601060248201526f37b7363ca832b73234b733a7bbb732b960811b604482015290519081900360640190fd5b600154600080546040516001600160a01b0393841693909116917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e091a360018054600080546001600160a01b03199081166001600160a01b03841617909155169055565b6000546001600160a01b031681565b60045481565b6002546001600160a01b031681565b60055481565b6001546001600160a01b031681565b6000546001600160a01b03163314610a22576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600454811415610a3157610850565b60048190556040805182815290517fe08bf32e9c0e823a76d0088908afba678014c513e2311bba64fc72f38ae809709181900360200190a150565b6000546001600160a01b03163314610ab7576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600180546001600160a01b0319166001600160a01b0392909216919091179055565b60035481565b6006546040805163836c081d60e01b815290516000926001600160a01b03169163836c081d916004808301926020929190829003018186803b15801561045c57600080fd5b600080610b3085610b90565b8051602091820120604080516001600160f81b0319818501526bffffffffffffffffffffffff19606089901b1660218201526035810187905260558082019390935281518082039093018352607501905280519101209150509392505050565b604080516057810190915260378152733d602d80600a3d3981f3363d3d373d3d3d363d7360601b602082015260609190911b60348201526e5af43d82803e903d91602b57fd5bf360881b604882015290565b825160009082816020870184f591506001600160a01b038216610c43576040805162461bcd60e51b8152602060048201526014602482015273195c9c9bdc97d85b1c9958591e50dc99585d195960621b604482015290519081900360640190fd5b835115610d3c576000826001600160a01b0316856040518082805190602001908083835b60208310610c865780518252601f199092019160209182019101610c67565b6001836020036101000a0380198251168184511680821785525050505050509050019150506000604051808303816000865af19150503d8060008114610ce8576040519150601f19603f3d011682016040523d82523d6000602084013e610ced565b606091505b5050905080610d3a576040805162461bcd60e51b815260206004820152601460248201527332b93937b92fb4b734ba34b0b634bd30ba34b7b760611b604482015290519081900360640190fd5b505b50939250505056fea2646970667358221220e10751fb6e1f2fd0035d38326971ac2be99e8073732656a09e684385d393c27864736f6c63430006060033000000000000000000000000ba4b4c7facd055990aa3eabd53db0a87a65b8e0b00000000000000000000000035f1b900e63579ec0bd3904941de7e8fe5e7f3b4", "nonce": "0x26", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xc7104402a5e69e699f2e8a531814e6424bc8112137933fe95cf8faf9bbd2874c", "blockNumber": "0x91", "transactionIndex": "0x0"}], "totalDifficulty": "0x90ffffffffffffffffffffffffdfca7dd7", "transactionsRoot": "0xfd7f0fc07fa16db7b6854d3f850cd46ad7b55b2ef6b8413d20e95f17e33de40c"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0xd2c19", "blockHash": "0xc7104402a5e69e699f2e8a531814e6424bc8112137933fe95cf8faf9bbd2874c", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x91", "contractAddress": "0x031fdeaa6da80fdbcd75f14ba8887c535f41eb7e", "transactionHash": "0x9c40ecf257e0dde6129d51a8657269186545ea11877666e4389f2a5cffb6e0fd", "transactionIndex": "0x0", "cumulativeGasUsed": "0xd2c19"}]}
\\xda67362114c6bbf02e55e43ddb21fd327d9f6c661571bf16c9bdd949dadcb164	144	\\xb2023d43078e02e10dae80727fad16466637eeae0c3f87a8f77d0c95f678fdad	{"block": {"hash": "0xda67362114c6bbf02e55e43ddb21fd327d9f6c661571bf16c9bdd949dadcb164", "size": "0xd48", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x90", "uncles": [], "gasUsed": "0x9fab8", "mixHash": null, "gasLimit": "0x695da3", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2133936ea3d16a7776aa7d42a08ec21823fd5eaa561c6ef56f46bab743aedb00", "timestamp": "0x60a684c2", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xb2023d43078e02e10dae80727fad16466637eeae0c3f87a8f77d0c95f678fdad", "sealFields": ["0x8420378196", "0xb84162f9903cba36164e65d29450a6199d653ad91ae7adf4f452f3e36b6454cd5af665d043e736978df363440f5e394f100adcdcceb8e972322cb1bc6e2a1ed0701a01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x8c4ba35006ac755a346708184f601baa415c1c65795b9ef6a16901eeab980ec9", "transactions": [{"to": null, "gas": "0x5b8d80", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xa69081025431ff1d2f2972226184b9956de54e123014370e2780811bbdff00d8", "input": "0x608060405234801561001057600080fd5b50604051610a41380380610a418339818101604052606081101561003357600080fd5b5080516020820151604090920151600080546001600160a01b03199081163317909155600280546001600160a01b0394851690831617905560038054948416948216949094179093556004805492909116919092161790556109a78061009a6000396000f3fe608060405234801561001057600080fd5b50600436106100b45760003560e01c80638da5cb5b116100715780638da5cb5b1461016157806394b918de14610169578063b31c710a14610186578063e30c39781461018e578063e39f456514610196578063f2fde38b146101bc576100b4565b80634e71e0c8146100b957806351cff8d9146100c3578063533426d1146100e95780635b7a50f71461010d578063834bc59414610133578063836c081d14610159575b600080fd5b6100c16101e2565b005b6100c1600480360360208110156100d957600080fd5b50356001600160a01b0316610298565b6100f1610476565b604080516001600160a01b039092168252519081900360200190f35b6100c16004803603602081101561012357600080fd5b50356001600160a01b0316610485565b6100c16004803603602081101561014957600080fd5b50356001600160a01b031661052d565b6100f16105d5565b6100f16105e4565b6100c16004803603602081101561017f57600080fd5b50356105f3565b6100f161083e565b6100f161084d565b6100c1600480360360208110156101ac57600080fd5b50356001600160a01b031661085c565b6100c1600480360360208110156101d257600080fd5b50356001600160a01b0316610904565b6001546001600160a01b03163314610234576040805162461bcd60e51b815260206004820152601060248201526f37b7363ca832b73234b733a7bbb732b960811b604482015290519081900360640190fd5b600154600080546040516001600160a01b0393841693909116917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e091a360018054600080546001600160a01b03199081166001600160a01b03841617909155169055565b6000546001600160a01b031633146102e3576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b604080516370a0823160e01b8152306004820152905182916000916001600160a01b038416916370a08231916024808301926020929190829003018186803b15801561032e57600080fd5b505afa158015610342573d6000803e3d6000fd5b505050506040513d602081101561035857600080fd5b5051905080610368575050610473565b600080546040805163a9059cbb60e01b81526001600160a01b0392831660048201526024810185905290519185169263a9059cbb926044808401936020939083900390910190829087803b1580156103bf57600080fd5b505af11580156103d3573d6000803e3d6000fd5b505050506040513d60208110156103e957600080fd5b505161042e576040805162461bcd60e51b815260206004820152600f60248201526e1d1c985b9cd9995c97d9985a5b1959608a1b604482015290519081900360640190fd5b6000546040805183815290516001600160a01b03909216917f7fcf532c15f0a6db0bd6d0e038bea71d30d808c7d98cb3bf7268a95bf5081b659181900360200190a250505b50565b6004546001600160a01b031681565b6000546001600160a01b031633146104d0576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b6003546040516001600160a01b03918216918316907f1aa7dd3c81658118943ae26982827c3fe431efc748245477507938313ff1092690600090a3600380546001600160a01b0319166001600160a01b0392909216919091179055565b6000546001600160a01b03163314610578576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b6002546040516001600160a01b03918216918316907f77f72df9021d6c85a85c9539e22c507f137341a44dc236249d2ac2ec94332a6590600090a3600280546001600160a01b0319166001600160a01b0392909216919091179055565b6002546001600160a01b031681565b6000546001600160a01b031681565b6003546001600160a01b03161580159061061757506002546001600160a01b031615155b610659576040805162461bcd60e51b815260206004820152600e60248201526d1d1bdad95b9cd7db9bdd17dcd95d60921b604482015290519081900360640190fd5b600354600254604080516323b872dd60e01b81523360048201523060248201526044810185905290516001600160a01b03938416939092169183916323b872dd9160648083019260209291908290030181600087803b1580156106bb57600080fd5b505af11580156106cf573d6000803e3d6000fd5b505050506040513d60208110156106e557600080fd5b505161072e576040805162461bcd60e51b81526020600482015260136024820152721d1c985b9cd9995c919c9bdb57d9985a5b1959606a1b604482015290519081900360640190fd5b6040805163a9059cbb60e01b81523360048201526024810185905290516001600160a01b0383169163a9059cbb9160448083019260209291908290030181600087803b15801561077d57600080fd5b505af1158015610791573d6000803e3d6000fd5b505050506040513d60208110156107a757600080fd5b50516107ec576040805162461bcd60e51b815260206004820152600f60248201526e1d1c985b9cd9995c97d9985a5b1959608a1b604482015290519081900360640190fd5b6002546003546040805186815290516001600160a01b0393841693929092169133917fffebebfb273923089a3ed6bac0fd4686ac740307859becadeb82f998e30db614919081900360200190a4505050565b6003546001600160a01b031681565b6001546001600160a01b031681565b6000546001600160a01b031633146108a7576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b6004546040516001600160a01b03918216918316907feeaab2a31d713c6b25c64e6ea1a3b6aa9c2ef0be563ab7280ef8444b70226a2590600090a3600480546001600160a01b0319166001600160a01b0392909216919091179055565b6000546001600160a01b0316331461094f576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600180546001600160a01b0319166001600160a01b039290921691909117905556fea2646970667358221220e3065e8eb8c4a0379ec2f360441f73b5396ac8197f3a86b568adc6d1066074d464736f6c6343000606003300000000000000000000000067dda81caa260dd5a972f16fa3dae114b11505f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041b89db86be735c03a9296437e39f5fdadc4c678", "nonce": "0x25", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xda67362114c6bbf02e55e43ddb21fd327d9f6c661571bf16c9bdd949dadcb164", "blockNumber": "0x90", "transactionIndex": "0x0"}], "totalDifficulty": "0x8fffffffffffffffffffffffffdfca7dda", "transactionsRoot": "0xceb51b8ff38e09229e10e0019fc9bbbc4990aadb63542bcbf6b068f6d7220db4"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x9fab8", "blockHash": "0xda67362114c6bbf02e55e43ddb21fd327d9f6c661571bf16c9bdd949dadcb164", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x90", "contractAddress": "0xba4b4c7facd055990aa3eabd53db0a87a65b8e0b", "transactionHash": "0xa69081025431ff1d2f2972226184b9956de54e123014370e2780811bbdff00d8", "transactionIndex": "0x0", "cumulativeGasUsed": "0x9fab8"}]}
\\xb2023d43078e02e10dae80727fad16466637eeae0c3f87a8f77d0c95f678fdad	143	\\x610aa45a8b12ff572f0d32c74820aaed87bb8244b4a6c1331cd065822d13f545	{"block": {"hash": "0xb2023d43078e02e10dae80727fad16466637eeae0c3f87a8f77d0c95f678fdad", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8f", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x694354", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x6f9e27c9130c802c22fcb9f0b057cf138d82aa2f4c1d5b96f89b526caa8c8a03", "timestamp": "0x60a684bf", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x610aa45a8b12ff572f0d32c74820aaed87bb8244b4a6c1331cd065822d13f545", "sealFields": ["0x8420378195", "0xb841f4ab94bf650cd4e5c1b5bb052f53a4ddcab401c53bc10fa9ebc61cdbda2b7d002a65662f4ccfd404afdee029afcfae6bb605247a63ac1cbd0ee4770e39b008a300"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x8effffffffffffffffffffffffdfca7ddc", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x610aa45a8b12ff572f0d32c74820aaed87bb8244b4a6c1331cd065822d13f545	142	\\x5421efad8e97a26f12dde2ecf7d32f1fd6d08ba62e6fe6fc48802472ecbe89f5	{"block": {"hash": "0x610aa45a8b12ff572f0d32c74820aaed87bb8244b4a6c1331cd065822d13f545", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8e", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x69290b", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x6f9e27c9130c802c22fcb9f0b057cf138d82aa2f4c1d5b96f89b526caa8c8a03", "timestamp": "0x60a684bc", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x5421efad8e97a26f12dde2ecf7d32f1fd6d08ba62e6fe6fc48802472ecbe89f5", "sealFields": ["0x8420378194", "0xb841be1caae6b9dc88359446135dc7bc4b9f92154d1808e246fd26ca4c11e5b3d4c51b61460ac9f3b3e04b01bd21a47f301a1eb20e0ea45afcfd553e7f16a3ced75800"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x8dffffffffffffffffffffffffdfca7dde", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x5421efad8e97a26f12dde2ecf7d32f1fd6d08ba62e6fe6fc48802472ecbe89f5	141	\\x8a3b7ac3b0ab5f44acad1b266680f985106532f987f75a79bea3cb5812d0df64	{"block": {"hash": "0x5421efad8e97a26f12dde2ecf7d32f1fd6d08ba62e6fe6fc48802472ecbe89f5", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8d", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x690ec9", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x6f9e27c9130c802c22fcb9f0b057cf138d82aa2f4c1d5b96f89b526caa8c8a03", "timestamp": "0x60a684b9", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x8a3b7ac3b0ab5f44acad1b266680f985106532f987f75a79bea3cb5812d0df64", "sealFields": ["0x8420378193", "0xb841a1cc5e7ea730fe490fe6a8fe4c6c952aa8b5a120c3f26fa2cab5688cfa3537bd52b49da6c05196665311e1c59b1e58398b64f082e1f8db7764a4f2e69efa0d1a01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x8cffffffffffffffffffffffffdfca7de0", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x8a3b7ac3b0ab5f44acad1b266680f985106532f987f75a79bea3cb5812d0df64	140	\\x5fc520141deeb1def3f964b911397ba590ab17f3cc821ecc603b8f5864b74152	{"block": {"hash": "0x8a3b7ac3b0ab5f44acad1b266680f985106532f987f75a79bea3cb5812d0df64", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8c", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x68f48d", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x6f9e27c9130c802c22fcb9f0b057cf138d82aa2f4c1d5b96f89b526caa8c8a03", "timestamp": "0x60a684b3", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x5fc520141deeb1def3f964b911397ba590ab17f3cc821ecc603b8f5864b74152", "sealFields": ["0x8420378191", "0xb841c4ae040d08bf871304d4b531ca8f91c3d2d7a8ddbeba46c32b74b73ac0e1e34b333a2a8206559d292b8764b472eeb7d504863c2bee80a535f6c53ff3909eceee01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x8bffffffffffffffffffffffffdfca7de3", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x5fc520141deeb1def3f964b911397ba590ab17f3cc821ecc603b8f5864b74152	139	\\x96f5dda580c73ac22e847e3ae42275ea6927bf91e0bd6afa782d814fd7537179	{"block": {"hash": "0x5fc520141deeb1def3f964b911397ba590ab17f3cc821ecc603b8f5864b74152", "size": "0x3621", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8b", "uncles": [], "gasUsed": "0x2c19e0", "mixHash": null, "gasLimit": "0x68da58", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x6f9e27c9130c802c22fcb9f0b057cf138d82aa2f4c1d5b96f89b526caa8c8a03", "timestamp": "0x60a684b0", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x96f5dda580c73ac22e847e3ae42275ea6927bf91e0bd6afa782d814fd7537179", "sealFields": ["0x8420378190", "0xb841d4af2606f88cd8547cac73b159550d5622008e7fa6b5003673dcb7dfa81fca8949ff10ebb64889f54994dfb7b66a2508da95821e798388418ebee7c7abc9c1af01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56a22e4ff0414db466a9e463b81b9ae3c2a39e92ca505d871c7f328012c26e5c", "transactions": [{"to": null, "gas": "0x5b8d80", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xc6ed8334b34ecdd281e6727d76a6b7261373eb830e953597a1f658275cdfec67", "input": "0x608060405234801561001057600080fd5b50600080546001600160a01b031916905561334a806100306000396000f3fe60806040526004361061028c5760003560e01c806373e2290c1161015a578063bf1e42c0116100c1578063db7af8541161007a578063db7af85414610f0d578063e30c397814610fd3578063e6018c3114610fe8578063ead5d35914611012578063f2fde38b14611053578063fc0c546a1461108657610293565b8063bf1e42c014610d39578063c44b73a314610d4e578063c59d484714610da5578063ca6d56dc14610df2578063cc77244014610e25578063ce7b786414610e3a57610293565b80639107d08e116101135780639107d08e14610a50578063a2d3cf4b14610abc578063a4c0ed3614610b8d578063a4d6ddc014610c1d578063ae66d94814610ccd578063b274bcc714610d0057610293565b806373e2290c1461090d578063790490171461094e5780637b30ed431461096357806385a2124614610a115780638da5cb5b14610a265780638fd3ab8014610a3b57610293565b80633d8e36a3116101fe578063593b79fe116101b7578063593b79fe146107215780635fb6c6ed146107c9578063662d45a2146107de5780636d8018b8146108115780636f4d469b1461082657806371cdfd68146108d457610293565b80633d8e36a31461059f5780633ebff90e146105b45780634bee9137146105c95780634d6b976f146106045780634e40ea64146106d95780634e71e0c81461070c57610293565b80631a79246c116102505780631a79246c146104065780632b94411f146104de5780632df3eba4146105195780632e0d42121461052e578063331beb5f14610561578063392e53cd1461057657610293565b80630600a8651461029857806309a6400b146102bf578063131b9c04146102f45780631796621a14610327578063187ac4cb146103d557610293565b3661029357005b600080fd5b3480156102a457600080fd5b506102ad61109b565b60408051918252519081900360200190f35b3480156102cb57600080fd5b506102f2600480360360208110156102e257600080fd5b50356001600160a01b03166110ba565b005b34801561030057600080fd5b506102ad6004803603602081101561031757600080fd5b50356001600160a01b03166111da565b34801561033357600080fd5b506102f26004803603602081101561034a57600080fd5b810190602081018135600160201b81111561036457600080fd5b82018360208201111561037657600080fd5b803590602001918460208302840111600160201b8311171561039757600080fd5b91908080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525092955061128a945050505050565b3480156103e157600080fd5b506103ea611309565b604080516001600160a01b039092168252519081900360200190f35b34801561041257600080fd5b506102ad600480360360a081101561042957600080fd5b6001600160a01b038235811692602081013590911691604082013591606081013515159181019060a081016080820135600160201b81111561046a57600080fd5b82018360208201111561047c57600080fd5b803590602001918460018302840111600160201b8311171561049d57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550611318945050505050565b3480156104ea57600080fd5b506102ad6004803603604081101561050157600080fd5b506001600160a01b0381351690602001351515611382565b34801561052557600080fd5b506102ad61139e565b34801561053a57600080fd5b506102ad6004803603602081101561055157600080fd5b50356001600160a01b03166113a4565b34801561056d57600080fd5b506102ad6113cd565b34801561058257600080fd5b5061058b611542565b604080519115158252519081900360200190f35b3480156105ab57600080fd5b506102ad611553565b3480156105c057600080fd5b506102ad611559565b3480156105d557600080fd5b506102ad600480360360408110156105ec57600080fd5b506001600160a01b038135169060200135151561155f565b34801561061057600080fd5b506102f2600480360360a081101561062757600080fd5b6001600160a01b038235811692602081013590911691810190606081016040820135600160201b81111561065a57600080fd5b82018360208201111561066c57600080fd5b803590602001918460208302840111600160201b8311171561068d57600080fd5b919080806020026020016040519081016040528093929190818152602001838360200280828437600092019190915250929550506001600160a01b038335169350505060200135611574565b3480156106e557600080fd5b506102f2600480360360208110156106fc57600080fd5b50356001600160a01b0316611762565b34801561071857600080fd5b506102f26118cb565b34801561072d57600080fd5b506107546004803603602081101561074457600080fd5b50356001600160a01b0316611981565b6040805160208082528351818301528351919283929083019185019080838360005b8381101561078e578181015183820152602001610776565b50505050905090810190601f1680156107bb5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b3480156107d557600080fd5b506102ad6119a5565b3480156107ea57600080fd5b506102f26004803603602081101561080157600080fd5b50356001600160a01b03166119ab565b34801561081d57600080fd5b506102ad611acf565b34801561083257600080fd5b506102f26004803603602081101561084957600080fd5b810190602081018135600160201b81111561086357600080fd5b82018360208201111561087557600080fd5b803590602001918460208302840111600160201b8311171561089657600080fd5b919080806020026020016040519081016040528093929190818152602001838360200280828437600092019190915250929550611ad5945050505050565b3480156108e057600080fd5b506102f2600480360360408110156108f757600080fd5b506001600160a01b038135169060200135611b71565b34801561091957600080fd5b506102ad6004803603606081101561093057600080fd5b506001600160a01b0381351690602081013590604001351515611c42565b34801561095a57600080fd5b506102ad611c58565b34801561096f57600080fd5b506102f26004803603602081101561098657600080fd5b810190602081018135600160201b8111156109a057600080fd5b8201836020820111156109b257600080fd5b803590602001918460208302840111600160201b831117156109d357600080fd5b919080806020026020016040519081016040528093929190818152602001838360200280828437600092019190915250929550611c5e945050505050565b348015610a1d57600080fd5b506102ad611c8e565b348015610a3257600080fd5b506103ea611c94565b348015610a4757600080fd5b506102f2611ca3565b348015610a5c57600080fd5b50610a8360048036036020811015610a7357600080fd5b50356001600160a01b03166122f5565b60405180856002811115610a9357fe5b60ff16815260200184815260200183815260200182815260200194505050505060405180910390f35b348015610ac857600080fd5b5061058b60048036036080811015610adf57600080fd5b6001600160a01b03823581169260208101359091169160408201359190810190608081016060820135600160201b811115610b1957600080fd5b820183602082011115610b2b57600080fd5b803590602001918460018302840111600160201b83111715610b4c57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550612320945050505050565b348015610b9957600080fd5b5061058b60048036036060811015610bb057600080fd5b6001600160a01b0382351691602081013591810190606081016040820135600160201b811115610bdf57600080fd5b820183602082011115610bf157600080fd5b803590602001918460018302840111600160201b83111715610c1257600080fd5b509092509050612521565b348015610c2957600080fd5b506102ad60048036036040811015610c4057600080fd5b810190602081018135600160201b811115610c5a57600080fd5b820183602082011115610c6c57600080fd5b803590602001918460208302840111600160201b83111715610c8d57600080fd5b9190808060200260200160405190810160405280939291908181526020018383602002808284376000920191909152509295505050503515159050612552565b348015610cd957600080fd5b506102ad60048036036020811015610cf057600080fd5b50356001600160a01b031661259f565b348015610d0c57600080fd5b506102f260048036036040811015610d2357600080fd5b506001600160a01b038135169060200135612617565b348015610d4557600080fd5b506103ea61288d565b348015610d5a57600080fd5b50610d8160048036036020811015610d7157600080fd5b50356001600160a01b031661289c565b60405180826002811115610d9157fe5b60ff16815260200191505060405180910390f35b348015610db157600080fd5b50610dba6128b1565b604051808260c080838360005b83811015610ddf578181015183820152602001610dc7565b5050505090500191505060405180910390f35b348015610dfe57600080fd5b506102f260048036036020811015610e1557600080fd5b50356001600160a01b03166128f7565b348015610e3157600080fd5b506103ea612afd565b348015610e4657600080fd5b506102ad60048036036080811015610e5d57600080fd5b6001600160a01b038235811692602081013590911691604082013515159190810190608081016060820135600160201b811115610e9957600080fd5b820183602082011115610eab57600080fd5b803590602001918460018302840111600160201b83111715610ecc57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550612b0c945050505050565b348015610f1957600080fd5b506102f260048036036060811015610f3057600080fd5b6001600160a01b0382351691602081013591810190606081016040820135600160201b811115610f5f57600080fd5b820183602082011115610f7157600080fd5b803590602001918460018302840111600160201b83111715610f9257600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550612b7e945050505050565b348015610fdf57600080fd5b506103ea612b8c565b348015610ff457600080fd5b506102f26004803603602081101561100b57600080fd5b5035612b9b565b34801561101e57600080fd5b506102ad6004803603606081101561103557600080fd5b506001600160a01b0381351690602081013590604001351515612c31565b34801561105f57600080fd5b506102f26004803603602081101561107657600080fd5b50356001600160a01b0316612ca6565b34801561109257600080fd5b506103ea612d13565b60006110b4600654600554612d2290919063ffffffff16565b90505b90565b6000546001600160a01b03163314611105576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b60016001600160a01b0382166000908152600e602052604090205460ff16600281111561112e57fe5b14611177576040805162461bcd60e51b8152602060048201526014602482015273195c9c9bdc97db9bdd1058dd1a5d995059d95b9d60621b604482015290519081900360640190fd5b6001600160a01b0381166000818152600e6020526040808220805460ff19166002179055517feac6c7d5a1c157497119a5d4f661d5f23b844c415452ef440ed346bd127d885e9190a2600a546111d490600163ffffffff612d2216565b600a5550565b6001600160a01b0381166000908152600d6020526040812081815460ff16600281111561120357fe5b1415611248576040805162461bcd60e51b815260206004820152600f60248201526e32b93937b92fb737ba26b2b6b132b960891b604482015290519081900360640190fd5b6001815460ff16600281111561125a57fe5b1461126657600061127d565b600281015460095461127d9163ffffffff612d2216565b6001909101540192915050565b6000546001600160a01b031633146112d5576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b60005b8151811015611305576112fd8282815181106112f057fe5b60200260200101516119ab565b6001016112d8565b5050565b600c546001600160a01b031681565b600061132686868685612320565b61136c576040805162461bcd60e51b81526020600482015260126024820152716572726f725f6261645369676e617475726560701b604482015290519081900360640190fd5b61137886868686612d64565b9695505050505050565b600061139783611391336113a4565b84611c42565b9392505050565b60055481565b60006113c76113b28361259f565b6113bb846111da565b9063ffffffff612d2216565b92915050565b600254604080516370a0823160e01b8152306004820152905160009283926001600160a01b03909116916370a0823191602480820192602092909190829003018186803b15801561141d57600080fd5b505afa158015611431573d6000803e3d6000fd5b505050506040513d602081101561144757600080fd5b50519050600061146561145861109b565b839063ffffffff612d2216565b90508015806114745750600754155b15611484576000925050506110b7565b600061149b600754836130f390919063ffffffff16565b6009549091506114b1908263ffffffff61313516565b6009556005546114c7908363ffffffff61313516565b6005556040805183815290517f41b06c6e0a1531dcb4b86d53ec6268666aa12d55775f8e5a63596fc935cdcc229181900360200190a160075460408051838152602081019290925280517f24a9873073eba764d17ef9fa7475b3b209c02e6e6f7ed991c9c80e09226a37a79281900390910190a15091505090565b6002546001600160a01b0316151590565b60085481565b600a5481565b60006113978361156e856113a4565b84612c31565b61157c611542565b156115ce576040805162461bcd60e51b815260206004820152601860248201527f6572726f725f616c7265616479496e697469616c697a65640000000000000000604482015290519081900360640190fd5b600080546001600160a01b03199081163317909155600c80546001600160a01b038781169190931617908190556040805163836c081d60e01b81529051919092169163836c081d916004808301926020929190829003018186803b15801561163557600080fd5b505afa158015611649573d6000803e3d6000fd5b505050506040513d602081101561165f57600080fd5b5051600280546001600160a01b0319166001600160a01b039092169190911790556116898361128a565b600c60009054906101000a90046001600160a01b03166001600160a01b031663533426d16040518163ffffffff1660e01b815260040160206040518083038186803b1580156116d757600080fd5b505afa1580156116eb573d6000803e3d6000fd5b505050506040513d602081101561170157600080fd5b5051600380546001600160a01b03199081166001600160a01b03938416179091556004805490911691841691909117905561173b81612b9b565b5050600080546001600160a01b0319166001600160a01b0394909416939093179092555050565b336001600160a01b038216148061179657506001336000908152600e602052604090205460ff16600281111561179457fe5b145b6117dc576040805162461bcd60e51b8152602060048201526012602482015271195c9c9bdc97db9bdd14195c9b5a5d1d195960721b604482015290519081900360640190fd5b6001600160a01b0381166000908152600d602052604090206001815460ff16600281111561180657fe5b14611850576040805162461bcd60e51b815260206004820152601560248201527432b93937b92fb737ba20b1ba34bb32a6b2b6b132b960591b604482015290519081900360640190fd5b611859826111da565b600182810191909155815460ff1916600217825560075461187991612d22565b60075560085461189090600163ffffffff61313516565b6008556040516001600160a01b038316907f7df2bff504799b36cafb9574b3fcfd8432ef4a1fa89d1ba9fe40324501adf5f590600090a25050565b6001546001600160a01b0316331461191d576040805162461bcd60e51b815260206004820152601060248201526f37b7363ca832b73234b733a7bbb732b960811b604482015290519081900360640190fd5b600154600080546040516001600160a01b0393841693909116917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e091a360018054600080546001600160a01b03199081166001600160a01b03841617909155169055565b604080516001600160a01b0392909216600560a21b18601483015260348201905290565b60075481565b6000546001600160a01b031633146119f6576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b60016001600160a01b0382166000908152600e602052604090205460ff166002811115611a1f57fe5b1415611a72576040805162461bcd60e51b815260206004820152601860248201527f6572726f725f616c72656164794163746976654167656e740000000000000000604482015290519081900360640190fd5b6001600160a01b0381166000818152600e6020526040808220805460ff19166001179055517f10581818fb1ffbfd9ac8500cba931a30c3a57b5e9b7972f2fa0aef002b3fde2b9190a2600a546111d490600163ffffffff61313516565b60095481565b6001336000908152600e602052604090205460ff166002811115611af557fe5b14611b41576040805162461bcd60e51b8152602060048201526017602482015276195c9c9bdc97dbdb9b1e529bda5b94185c9d1059d95b9d604a1b604482015290519081900360640190fd5b60005b815181101561130557611b69828281518110611b5c57fe5b60200260200101516128f7565b600101611b44565b80611b7b336113a4565b1015611bca576040805162461bcd60e51b81526020600482015260196024820152786572726f725f696e73756666696369656e7442616c616e636560381b604482015290519081900360640190fd5b336000908152600d602052604090206003810154611bee908363ffffffff61313516565b6003820155611bfd838361318f565b6040805183815290516001600160a01b0385169133917f638ce96e87261f007ef5c0389bb59b90db3e19c42edee859d6b09739d8d79f7f9181900360200190a3505050565b6000611c5033858585612d64565b949350505050565b600b5481565b60005b815181101561130557611c86828281518110611c7957fe5b6020026020010151611762565b600101611c61565b60065481565b6000546001600160a01b031681565b6000546001600160a01b03163314611cee576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600c546040805163533426d160e01b815290516000926001600160a01b03169163533426d1916004808301926020929190829003018186803b158015611d3357600080fd5b505afa158015611d47573d6000803e3d6000fd5b505050506040513d6020811015611d5d57600080fd5b505190506001600160a01b03811615801590611d8757506003546001600160a01b03828116911614155b15611de3576003546040516001600160a01b03918216918316907f5d82b60ad3cf3639e02e96994b2b10060c4c0a7c0214695baa228363fb910c3490600090a3600380546001600160a01b0319166001600160a01b0383161790555b600c546040805163836c081d60e01b815290516000926001600160a01b03169163836c081d916004808301926020929190829003018186803b158015611e2857600080fd5b505afa158015611e3c573d6000803e3d6000fd5b505050506040513d6020811015611e5257600080fd5b505190506001600160a01b03811615801590611e7c57506002546001600160a01b03828116911614155b8015611f065750600254600c546040805163598e388560e11b815290516001600160a01b03938416939092169163b31c710a91600480820192602092909190829003018186803b158015611ecf57600080fd5b505afa158015611ee3573d6000803e3d6000fd5b505050506040513d6020811015611ef957600080fd5b50516001600160a01b0316145b1561130557611f136113cd565b50600254604080516370a0823160e01b815230600482015290516000926001600160a01b0316916370a08231916024808301926020929190829003018186803b158015611f5f57600080fd5b505afa158015611f73573d6000803e3d6000fd5b505050506040513d6020811015611f8957600080fd5b5051604080516370a0823160e01b815230600482015290519192506000916001600160a01b038516916370a08231916024808301926020929190829003018186803b158015611fd757600080fd5b505afa158015611feb573d6000803e3d6000fd5b505050506040513d602081101561200157600080fd5b50519050811561228c57600254600c546040805163095ea7b360e01b81526001600160a01b039283166004820152602481018690529051919092169163095ea7b39160448083019260209291908290030181600087803b15801561206457600080fd5b505af1158015612078573d6000803e3d6000fd5b505050506040513d602081101561208e57600080fd5b5050600c5460408051634a5c8c6f60e11b81526004810185905290516001600160a01b03909216916394b918de9160248082019260009290919082900301818387803b1580156120dd57600080fd5b505af11580156120f1573d6000803e3d6000fd5b5050600254604080516370a0823160e01b815230600482015290516001600160a01b0390921693506370a082319250602480820192602092909190829003018186803b15801561214057600080fd5b505afa158015612154573d6000803e3d6000fd5b505050506040513d602081101561216a57600080fd5b5051156121b0576040805162461bcd60e51b815260206004820152600f60248201526e1d1bdad95b9cd7db9bdd17dcd95b9d608a1b604482015290519081900360640190fd5b8161224382856001600160a01b03166370a08231306040518263ffffffff1660e01b815260040180826001600160a01b03166001600160a01b0316815260200191505060206040518083038186803b15801561220b57600080fd5b505afa15801561221f573d6000803e3d6000fd5b505050506040513d602081101561223557600080fd5b50519063ffffffff612d2216565b101561228c576040805162461bcd60e51b81526020600482015260136024820152721d1bdad95b9cd7db9bdd17dc9958d95a5d9959606a1b604482015290519081900360640190fd5b6002546040805184815290516001600160a01b03928316928616917fd05a160a091ef7d70215da5058f251bcba4363a35c404ba3345403d4cf86b0e1919081900360200190a35050600280546001600160a01b0383166001600160a01b03199091161790555050565b600d60205260009081526040902080546001820154600283015460039093015460ff90921692909184565b60008151604114612378576040805162461bcd60e51b815260206004820152601860248201527f6572726f725f6261645369676e61747572654c656e6774680000000000000000604482015290519081900360640190fd5b60208201516040830151606084015160001a601b81101561239757601b015b8060ff16601b14806123ac57508060ff16601c145b6123fd576040805162461bcd60e51b815260206004820152601960248201527f6572726f725f6261645369676e617475726556657273696f6e00000000000000604482015290519081900360640190fd5b600087873061240b8c61259f565b60405160200180807f19457468657265756d205369676e6564204d6573736167653a0a313034000000815250601d01856001600160a01b03166001600160a01b031660601b8152601401848152602001836001600160a01b03166001600160a01b031660601b8152601401828152602001945050505050604051602081830303815290604052805190602001209050600060018284878760405160008152602001604052604051808581526020018460ff1660ff1681526020018381526020018281526020019450505050506020604051602081039080840390855afa1580156124f9573d6000803e3d6000fd5b5050604051601f1901516001600160a01b038c81169116149650505050505050949350505050565b6002546000906001600160a01b0316331461253e57506000611c50565b6125466113cd565b50600195945050505050565b600080805b84518110156125975761258d61258086838151811061257257fe5b60200260200101518661155f565b839063ffffffff61313516565b9150600101612557565b509392505050565b6001600160a01b0381166000908152600d6020526040812081815460ff1660028111156125c857fe5b141561260d576040805162461bcd60e51b815260206004820152600f60248201526e32b93937b92fb737ba26b2b6b132b960891b604482015290519081900360640190fd5b6003015492915050565b600254604080516370a0823160e01b815230600482015290516000926001600160a01b0316916370a08231916024808301926020929190829003018186803b15801561266257600080fd5b505afa158015612676573d6000803e3d6000fd5b505050506040513d602081101561268c57600080fd5b5051600254604080516323b872dd60e01b81523360048201523060248201526044810186905290519293506001600160a01b03909116916323b872dd916064808201926020929091908290030181600087803b1580156126eb57600080fd5b505af11580156126ff573d6000803e3d6000fd5b505050506040513d602081101561271557600080fd5b5051612759576040805162461bcd60e51b815260206004820152600e60248201526d32b93937b92fba3930b739b332b960911b604482015290519081900360640190fd5b600254604080516370a0823160e01b815230600482015290516000926001600160a01b0316916370a08231916024808301926020929190829003018186803b1580156127a457600080fd5b505afa1580156127b8573d6000803e3d6000fd5b505050506040513d60208110156127ce57600080fd5b50519050826127e3828463ffffffff612d2216565b1015612827576040805162461bcd60e51b815260206004820152600e60248201526d32b93937b92fba3930b739b332b960911b604482015290519081900360640190fd5b612831848461318f565b600554612844908463ffffffff61313516565b6005556040805184815290516001600160a01b0386169133917f4e018df3c92158645fcf45007db7029d3fa97d269866be2bd4360c5f5a6163e49181900360200190a350505050565b6004546001600160a01b031681565b600e6020526000908152604090205460ff1681565b6128b96132f6565b6040518060c0016040528060055481526020016006548152602001600754815260200160085481526020016009548152602001600a54815250905090565b6001336000908152600e602052604090205460ff16600281111561291757fe5b14612963576040805162461bcd60e51b8152602060048201526017602482015276195c9c9bdc97dbdb9b1e529bda5b94185c9d1059d95b9d604a1b604482015290519081900360640190fd5b6001600160a01b0381166000908152600d602052604090206001815460ff16600281111561298d57fe5b14156129d6576040805162461bcd60e51b815260206004820152601360248201527232b93937b92fb0b63932b0b23ca6b2b6b132b960691b604482015290519081900360640190fd5b6002815460ff1660028111156129e857fe5b1415612a0657600854612a0290600163ffffffff612d2216565b6008555b600080825460ff166002811115612a1957fe5b148015612a275750600b5415155b8015612a355750600b544710155b825460ff1916600190811784556009546002850155600754919250612a5a9190613135565b6007556040516001600160a01b038416907f0abf3b3f643594d958297062a019458e27d7766629590ac621aa1000fa1298ab90600090a28015612af857600b546040516001600160a01b0385169180156108fc02916000818181858888f1935050505015612af857600b5460408051918252517f55e2724f03f2711a94cf86d8b10c57130b103d6c2f1726076fbf9430340d41e79181900360200190a15b505050565b6003546001600160a01b031681565b6000612b1b8585600085612320565b612b61576040805162461bcd60e51b81526020600482015260126024820152716572726f725f6261645369676e617475726560701b604482015290519081900360640190fd5b612b758585612b6f886113a4565b86612d64565b95945050505050565b612b866113cd565b50505050565b6001546001600160a01b031681565b6000546001600160a01b03163314612be6576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600b54811415612bf557612c2e565b600b8190556040805182815290517f749d0aa4ca45d6142166deb1820b64a888996311bb9f74a88c081f5b041d949c9181900360200190a15b50565b6000336001600160a01b0385161480612c5457506000546001600160a01b031633145b612c9a576040805162461bcd60e51b8152602060048201526012602482015271195c9c9bdc97db9bdd14195c9b5a5d1d195960721b604482015290519081900360640190fd5b611c5084858585612d64565b6000546001600160a01b03163314612cf1576040805162461bcd60e51b815260206004820152600960248201526837b7363ca7bbb732b960b91b604482015290519081900360640190fd5b600180546001600160a01b0319166001600160a01b0392909216919091179055565b6002546001600160a01b031681565b600061139783836040518060400160405280601e81526020017f536166654d6174683a207375627472616374696f6e206f766572666c6f7700008152506131fa565b600082612d7357506000611c50565b612d7c856113a4565b831115612dcc576040805162461bcd60e51b81526020600482015260196024820152786572726f725f696e73756666696369656e7442616c616e636560381b604482015290519081900360640190fd5b6001600160a01b0385166000908152600d602052604090206003810154612df9908563ffffffff61313516565b6003820155600654612e11908563ffffffff61313516565b6006558215612f68576002546003546001600160a01b0391821691634000aea0911686612e3d89611981565b6040518463ffffffff1660e01b815260040180846001600160a01b03166001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b83811015612ea7578181015183820152602001612e8f565b50505050905090810190601f168015612ed45780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b158015612ef557600080fd5b505af1158015612f09573d6000803e3d6000fd5b505050506040513d6020811015612f1f57600080fd5b5051612f63576040805162461bcd60e51b815260206004820152600e60248201526d32b93937b92fba3930b739b332b960911b604482015290519081900360640190fd5b6130aa565b6002546001600160a01b0316634000aea08686612f848a611981565b6040518463ffffffff1660e01b815260040180846001600160a01b03166001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b83811015612fee578181015183820152602001612fd6565b50505050905090810190601f16801561301b5780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b15801561303c57600080fd5b505af1158015613050573d6000803e3d6000fd5b505050506040513d602081101561306657600080fd5b50516130aa576040805162461bcd60e51b815260206004820152600e60248201526d32b93937b92fba3930b739b332b960911b604482015290519081900360640190fd5b6040805185815290516001600160a01b038816917f48dc35af7b45e2a81fffad55f6e2fafacdb1d3d0d50d24ebdc16324f5ba757f1919081900360200190a25091949350505050565b600061139783836040518060400160405280601a81526020017f536166654d6174683a206469766973696f6e206279207a65726f000000000000815250613291565b600082820183811015611397576040805162461bcd60e51b815260206004820152601b60248201527f536166654d6174683a206164646974696f6e206f766572666c6f770000000000604482015290519081900360640190fd5b6001600160a01b0382166000908152600d6020526040902060018101546131bc908363ffffffff61313516565b60018201556000815460ff1660028111156131d357fe5b1415612af857805460ff191660021781556008546131f2906001613135565b600855505050565b600081848411156132895760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b8381101561324e578181015183820152602001613236565b50505050905090810190601f16801561327b5780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b505050900390565b600081836132e05760405162461bcd60e51b815260206004820181815283516024840152835190928392604490910191908501908083836000831561324e578181015183820152602001613236565b5060008385816132ec57fe5b0495945050505050565b6040518060c00160405280600690602082028036833750919291505056fea2646970667358221220c057f0951032741c15f13595949ab49c5f1611e01611edeee27a8cac3b53fc1864736f6c63430006060033", "nonce": "0x24", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x5fc520141deeb1def3f964b911397ba590ab17f3cc821ecc603b8f5864b74152", "blockNumber": "0x8b", "transactionIndex": "0x0"}], "totalDifficulty": "0x8affffffffffffffffffffffffdfca7de5", "transactionsRoot": "0x28eef0194ea238c91f4cf63464c75920945244a1397cacc2b2eb50619829c07f"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x2c19e0", "blockHash": "0x5fc520141deeb1def3f964b911397ba590ab17f3cc821ecc603b8f5864b74152", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x8b", "contractAddress": "0x35f1b900e63579ec0bd3904941de7e8fe5e7f3b4", "transactionHash": "0xc6ed8334b34ecdd281e6727d76a6b7261373eb830e953597a1f658275cdfec67", "transactionIndex": "0x0", "cumulativeGasUsed": "0x2c19e0"}]}
\\x96f5dda580c73ac22e847e3ae42275ea6927bf91e0bd6afa782d814fd7537179	138	\\xfe8806605334281ad912f85c13bfaacdbef4544e44ba5e5a5d05275a965d168f	{"block": {"hash": "0x96f5dda580c73ac22e847e3ae42275ea6927bf91e0bd6afa782d814fd7537179", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x8a", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x68c029", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x49fbf27054b39c3da145e0c1f6223d8ec805b4dcbb3cc64af6ae6e162f09c53d", "timestamp": "0x60a684aa", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0xfe8806605334281ad912f85c13bfaacdbef4544e44ba5e5a5d05275a965d168f", "sealFields": ["0x842037818e", "0xb841632ce9c0ef50d5669de0789e37dea11cd84d563296c3e97f24a9c6a90e0f7f15666197754b04bddf43dac1afd7e9955c2d0456701bc87992cbb5d75cdf12e9ab01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x89ffffffffffffffffffffffffdfca7de8", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xfe8806605334281ad912f85c13bfaacdbef4544e44ba5e5a5d05275a965d168f	137	\\xa2b0cbc08eff959893facfdc4185eb442f67fd830e5c3820143f25c9eced102e	{"block": {"hash": "0xfe8806605334281ad912f85c13bfaacdbef4544e44ba5e5a5d05275a965d168f", "size": "0x2d9", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x89", "uncles": [], "gasUsed": "0x782e", "mixHash": null, "gasLimit": "0x68a601", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000800000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000", "stateRoot": "0x49fbf27054b39c3da145e0c1f6223d8ec805b4dcbb3cc64af6ae6e162f09c53d", "timestamp": "0x60a684a4", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xa2b0cbc08eff959893facfdc4185eb442f67fd830e5c3820143f25c9eced102e", "sealFields": ["0x842037818c", "0xb84150611131cd337196a813ea073fad71be971c6aa19ac8d6913a9b58b71ec572fe2f88432ce0609a5e35db7b1d11acddbefb6a74def51a463ab16a91d162e01fd600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x8efa8c42fd49920f55e4bca2ebad49bfb7d2893498f5ea1c0aabe2b9cca6cb68", "transactions": [{"to": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "gas": "0xf05c", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x8abcf782657d790b4e658a2e38cb878e93694e2c4b030d7a0b3d8763da301c7c", "input": "0xf1739cae000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "nonce": "0x23", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xfe8806605334281ad912f85c13bfaacdbef4544e44ba5e5a5d05275a965d168f", "blockNumber": "0x89", "transactionIndex": "0x0"}], "totalDifficulty": "0x88ffffffffffffffffffffffffdfca7deb", "transactionsRoot": "0xd80aa234e0123e2a1278e73709caf3275e276d01d4579fa8e58f608f01135a77"}, "transaction_receipts": [{"logs": [{"data": "0x0000000000000000000000004178babe9e5148c6d5fd431cd72884b07ad855a0000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "topics": ["0x5a3e66efaa1e445ebd894728a69d6959842ea1e97bd79b892797106e270efcd9"], "address": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0xfe8806605334281ad912f85c13bfaacdbef4544e44ba5e5a5d05275a965d168f", "blockNumber": "0x89", "transactionHash": "0x8abcf782657d790b4e658a2e38cb878e93694e2c4b030d7a0b3d8763da301c7c", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}], "root": null, "status": "0x1", "gasUsed": "0x782e", "blockHash": "0xfe8806605334281ad912f85c13bfaacdbef4544e44ba5e5a5d05275a965d168f", "logsBloom": "0x00000000000800000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000", "blockNumber": "0x89", "contractAddress": null, "transactionHash": "0x8abcf782657d790b4e658a2e38cb878e93694e2c4b030d7a0b3d8763da301c7c", "transactionIndex": "0x0", "cumulativeGasUsed": "0x782e"}]}
\\xa2b0cbc08eff959893facfdc4185eb442f67fd830e5c3820143f25c9eced102e	136	\\x108155924f4e1e1ac48d9d8c43289c74f2b261eb57931037b8f40413d675ee23	{"block": {"hash": "0xa2b0cbc08eff959893facfdc4185eb442f67fd830e5c3820143f25c9eced102e", "size": "0x43f", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x88", "uncles": [], "gasUsed": "0x4b9d7", "mixHash": null, "gasLimit": "0x688be0", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000020000000000200000000024000000000000000000800000000000000000000000000000000400200000000000000100000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020000000000000000000000000000040000000000000000000000000000000000000", "stateRoot": "0x30f49872c7844b6bdc3a6dd85e788f6ba2b02cb216658da40c1200a42c83e6b2", "timestamp": "0x60a684a1", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x108155924f4e1e1ac48d9d8c43289c74f2b261eb57931037b8f40413d675ee23", "sealFields": ["0x842037818b", "0xb841d2543c8b679b136f560a90a71f1235a92efdd94c0be4ebbcda6c56c949e7b7d72c70f71261ffba9a4cf0adf11e3620440603ae49a7f96946f37b20145f625cc900"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x6ca4dd7ec7671cb4fb7b151d5369e2eb1c43f09b36d710e21afded4923739104", "transactions": [{"to": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "gas": "0x99658", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x2fde728224e64a26637b7fd87234e3ab2b49a85a6805cdbe4e687c46d93e309d", "input": "0x3da98c8b00000000000000000000000073be21733cc5d08e1a14ea9a399fb27db3bef8ff0000000000000000000000006346ed242ade018bd9320d5e3371c377bab29c310000000000000000000000000000000000000000000c685fa11e01ec6f000000000000000000000000000000000000000000000000009ed194db19b238c0000000000000000000000000000000000000000000000000000006f05b59d3b200000000000000000000000000000000000000000000000c685fa11e01ec6f000000000000000000000000000000000000000000000000009ed194db19b238c00000000000000000000000000000c2f87e37019e227f2be5030aabbcc7eaf136e05c000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de100000000000000000000000036afc8c9283cc866b8eb6a61c6e6862a83cd6ee80000000000000000000000001def1497df0e103d58fd14c4f8e0365fe5f944230000000000000000000000004a4c4759eb3b7abee079f832850cd3d0dc48d927", "nonce": "0x22", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xa2b0cbc08eff959893facfdc4185eb442f67fd830e5c3820143f25c9eced102e", "blockNumber": "0x88", "transactionIndex": "0x0"}], "totalDifficulty": "0x87ffffffffffffffffffffffffdfca7ded", "transactionsRoot": "0x4e5265a9d908e235dce395b3059b90c1999bb83415c0347477407a7006960dbb"}, "transaction_receipts": [{"logs": [{"data": "0x0000000000000000000000000000000000000000000c685fa11e01ec6f000000", "topics": ["0xca0b3dabefdbd8c72c0a9cf4a6e9d107da897abf036ef3f3f3b010cdd2594159", "0x0000000000000000000000000000000000000000000000000000000000000000"], "address": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0xa2b0cbc08eff959893facfdc4185eb442f67fd830e5c3820143f25c9eced102e", "blockNumber": "0x88", "transactionHash": "0x2fde728224e64a26637b7fd87234e3ab2b49a85a6805cdbe4e687c46d93e309d", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}, {"data": "0x0000000000000000000000000000000000000000000c685fa11e01ec6f000000", "topics": ["0x4c177b42dbe934b3abbc0208c11a42e46589983431616f1710ab19969c5ed62e", "0x0000000000000000000000000000000000000000000000000000000000000000"], "address": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "logType": null, "removed": false, "logIndex": "0x1", "blockHash": "0xa2b0cbc08eff959893facfdc4185eb442f67fd830e5c3820143f25c9eced102e", "blockNumber": "0x88", "transactionHash": "0x2fde728224e64a26637b7fd87234e3ab2b49a85a6805cdbe4e687c46d93e309d", "transactionIndex": "0x0", "transactionLogIndex": "0x1"}, {"data": "0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "topics": ["0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0"], "address": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "logType": null, "removed": false, "logIndex": "0x2", "blockHash": "0xa2b0cbc08eff959893facfdc4185eb442f67fd830e5c3820143f25c9eced102e", "blockNumber": "0x88", "transactionHash": "0x2fde728224e64a26637b7fd87234e3ab2b49a85a6805cdbe4e687c46d93e309d", "transactionIndex": "0x0", "transactionLogIndex": "0x2"}], "root": null, "status": "0x1", "gasUsed": "0x4b9d7", "blockHash": "0xa2b0cbc08eff959893facfdc4185eb442f67fd830e5c3820143f25c9eced102e", "logsBloom": "0x00000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000020000000000200000000024000000000000000000800000000000000000000000000000000400200000000000000100000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020000000000000000000000000000040000000000000000000000000000000000000", "blockNumber": "0x88", "contractAddress": null, "transactionHash": "0x2fde728224e64a26637b7fd87234e3ab2b49a85a6805cdbe4e687c46d93e309d", "transactionIndex": "0x0", "cumulativeGasUsed": "0x4b9d7"}]}
\\x108155924f4e1e1ac48d9d8c43289c74f2b261eb57931037b8f40413d675ee23	135	\\xfb76da3f118d1c84f443ef6d2a81a0c4d07c281ffd8fcfa1cd3e4254a7cae24b	{"block": {"hash": "0x108155924f4e1e1ac48d9d8c43289c74f2b261eb57931037b8f40413d675ee23", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x87", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6871c5", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xc9dacc06cb6c28bed821b73abfd0ecf15b0fb116c4e81f499a751aa77d73e318", "timestamp": "0x60a6849e", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xfb76da3f118d1c84f443ef6d2a81a0c4d07c281ffd8fcfa1cd3e4254a7cae24b", "sealFields": ["0x842037818a", "0xb841779aea54d62dc56a00b6c379f2455cef7e1b88b2581eb99523d9fbbf9f5add31145b2c3ce0ddd0fe11e92d64500da07f3406b7edb201620504f0909b9cf415f801"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x86ffffffffffffffffffffffffdfca7def", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xfb76da3f118d1c84f443ef6d2a81a0c4d07c281ffd8fcfa1cd3e4254a7cae24b	134	\\xc4aec9aef38d2b1a7ef8ad32b3371c97f95d4f9550d557177bcd0367bf9b3700	{"block": {"hash": "0xfb76da3f118d1c84f443ef6d2a81a0c4d07c281ffd8fcfa1cd3e4254a7cae24b", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x86", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6857b1", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xc9dacc06cb6c28bed821b73abfd0ecf15b0fb116c4e81f499a751aa77d73e318", "timestamp": "0x60a6849b", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0xc4aec9aef38d2b1a7ef8ad32b3371c97f95d4f9550d557177bcd0367bf9b3700", "sealFields": ["0x8420378189", "0xb841fdbd3b9343b1b277dbe2965a0ae7b1c8569fc6f211ac29504daebc77f52a7957245709cc78b4b1cb2f69551ab660f89d110f73fee8104bcbdb0d0d799e52e12100"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x85ffffffffffffffffffffffffdfca7df1", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xc4aec9aef38d2b1a7ef8ad32b3371c97f95d4f9550d557177bcd0367bf9b3700	133	\\xb1e301614b3665f5967f213549f0ef8ab8c07951e9f890fbcc24abe11df926ef	{"block": {"hash": "0xc4aec9aef38d2b1a7ef8ad32b3371c97f95d4f9550d557177bcd0367bf9b3700", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x85", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x683da3", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xc9dacc06cb6c28bed821b73abfd0ecf15b0fb116c4e81f499a751aa77d73e318", "timestamp": "0x60a68495", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xb1e301614b3665f5967f213549f0ef8ab8c07951e9f890fbcc24abe11df926ef", "sealFields": ["0x8420378187", "0xb8419e0b822bd50d80ef09f3b279ae34d73e82e83496baebe2ad6ca9856e83c7a73147851c4997d4da09b9d8beaf34952b0f1d98951203fcfef6ee9c78eaff508cd100"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x84ffffffffffffffffffffffffdfca7df4", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xb1e301614b3665f5967f213549f0ef8ab8c07951e9f890fbcc24abe11df926ef	132	\\x26700e6103c9a2792bf0d74529dc42902a2637661f6b49db30d87a2637cf0e2c	{"block": {"hash": "0xb1e301614b3665f5967f213549f0ef8ab8c07951e9f890fbcc24abe11df926ef", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x84", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x68239c", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xc9dacc06cb6c28bed821b73abfd0ecf15b0fb116c4e81f499a751aa77d73e318", "timestamp": "0x60a68492", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x26700e6103c9a2792bf0d74529dc42902a2637661f6b49db30d87a2637cf0e2c", "sealFields": ["0x8420378186", "0xb841f9683efaf9dbd76b3033d3afd9399f48e3193efb43c80e51070cfe1232f868191c7e367b6feb199aaef8c9409f222d51ea4d0ccaedf4548fa1b395bf7e3a5bcb00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x83ffffffffffffffffffffffffdfca7df6", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x26700e6103c9a2792bf0d74529dc42902a2637661f6b49db30d87a2637cf0e2c	131	\\x4a355261f3a55a6a059f7b4108d0ae170e97b066c864d6caf900e4d1da87839b	{"block": {"hash": "0x26700e6103c9a2792bf0d74529dc42902a2637661f6b49db30d87a2637cf0e2c", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x83", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x68099b", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xc9dacc06cb6c28bed821b73abfd0ecf15b0fb116c4e81f499a751aa77d73e318", "timestamp": "0x60a6848f", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x4a355261f3a55a6a059f7b4108d0ae170e97b066c864d6caf900e4d1da87839b", "sealFields": ["0x8420378185", "0xb8419d0d9b942a5c1450c425ca1712f94d84910bd30754e4c44b20214ed88822e0bb46a58d1d6866372865dbc3e55976e32fe0b5f3c0b711033cb8bbd5862fb8f00800"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x82ffffffffffffffffffffffffdfca7df8", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x4a355261f3a55a6a059f7b4108d0ae170e97b066c864d6caf900e4d1da87839b	130	\\xe3df8ca2e9e239b39b06422db56a2f82eb8ed0dc98793f9ef251bd5d36e377f7	{"block": {"hash": "0x4a355261f3a55a6a059f7b4108d0ae170e97b066c864d6caf900e4d1da87839b", "size": "0x2fc", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x82", "uncles": [], "gasUsed": "0x107af", "mixHash": null, "gasLimit": "0x67efa1", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000800000000000000000000000000000010000040000000000000000000000000000000000000000000000000000000000000001000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000040000000000000000000000000000000000000", "stateRoot": "0xc9dacc06cb6c28bed821b73abfd0ecf15b0fb116c4e81f499a751aa77d73e318", "timestamp": "0x60a6848c", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xe3df8ca2e9e239b39b06422db56a2f82eb8ed0dc98793f9ef251bd5d36e377f7", "sealFields": ["0x8420378184", "0xb841cb95f2451ba88c33fa95cf78f2962f8a2de0fdba61890a00c88e39c46437eebe741cd2a605371b71afddca4c3f73fa53e6b7c99c2d9ba2d00eb1bc9e8a54013c01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0xb31d34b563b96b27b68f547f4d2e4d4bd91608dd6f5e2ef5387f288272a62ed4", "transactions": [{"to": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "gas": "0x20f5e", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x0a9bcae70148bae8974c1142fb19bf7b73fea869e18617be6adc49748a8f68b3", "input": "0x3ad06d160000000000000000000000000000000000000000000000000000000000000001000000000000000000000000d1fa6c06e1d838bb989640a2c4b8a499fd0ab187", "nonce": "0x21", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x4a355261f3a55a6a059f7b4108d0ae170e97b066c864d6caf900e4d1da87839b", "blockNumber": "0x82", "transactionIndex": "0x0"}], "totalDifficulty": "0x81ffffffffffffffffffffffffdfca7dfa", "transactionsRoot": "0xd93067e4805280c88731b1b5c18f7ffa844c53edfcbddb4b780e1ddb65413e7d"}, "transaction_receipts": [{"logs": [{"data": "0x0000000000000000000000000000000000000000000000000000000000000001", "topics": ["0x4289d6195cf3c2d2174adf98d0e19d4d2d08887995b99cb7b100e7ffe795820e", "0x000000000000000000000000d1fa6c06e1d838bb989640a2c4b8a499fd0ab187"], "address": "0xe983692122e45a00bba14454ebf4d00bf71aa245", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0x4a355261f3a55a6a059f7b4108d0ae170e97b066c864d6caf900e4d1da87839b", "blockNumber": "0x82", "transactionHash": "0x0a9bcae70148bae8974c1142fb19bf7b73fea869e18617be6adc49748a8f68b3", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}], "root": null, "status": "0x1", "gasUsed": "0x107af", "blockHash": "0x4a355261f3a55a6a059f7b4108d0ae170e97b066c864d6caf900e4d1da87839b", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000800000000000000000000000000000010000040000000000000000000000000000000000000000000000000000000000000001000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000040000000000000000000000000000000000000", "blockNumber": "0x82", "contractAddress": null, "transactionHash": "0x0a9bcae70148bae8974c1142fb19bf7b73fea869e18617be6adc49748a8f68b3", "transactionIndex": "0x0", "cumulativeGasUsed": "0x107af"}]}
\\xe3df8ca2e9e239b39b06422db56a2f82eb8ed0dc98793f9ef251bd5d36e377f7	129	\\x7c9392add0998a5858df4a5525c4a5416390c6146fa4dc8d1545208cc14e31a1	{"block": {"hash": "0xe3df8ca2e9e239b39b06422db56a2f82eb8ed0dc98793f9ef251bd5d36e377f7", "size": "0x62fb", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x81", "uncles": [], "gasUsed": "0x50d51f", "mixHash": null, "gasLimit": "0x67d5ad", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xd900775376cb60e3535d8db3422d21e83d4caa2fac97a5286173c42c86ed478d", "timestamp": "0x60a68489", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x7c9392add0998a5858df4a5525c4a5416390c6146fa4dc8d1545208cc14e31a1", "sealFields": ["0x8420378183", "0xb8417a580db2b554a3bb0fac7e923cd68a78455d32cb1a24f7d1f8621485b4b68bea7ccd7e8382cb668d8aa3d10c7ba05eba923fce59d55dcb1c5ce2ccf88db50c9600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x6a50f7a4ccd3752e3249e2d6cad941fa85eb876184e3e94e0a4ea9dfa12fafba", "transactions": [{"to": null, "gas": "0x67bbc0", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xba71e19626fab310d835b17fe5f78ceb574f03915df77edf7fe79438b879e21b", "input": "0x60c06040523480156200001157600080fd5b5060405162005ff438038062005ff4833981810160405260208110156200003757600080fd5b81019080805160405193929190846401000000008211156200005857600080fd5b9083019060208201858111156200006e57600080fd5b82516401000000008111828201881017156200008957600080fd5b82525081516020918201929091019080838360005b83811015620000b85781810151838201526020016200009e565b50505050905090810190601f168015620000e65780820380516001836020036101000a031916815260200191505b5060405250505080602081511115620000fe57600080fd5b602081015160a052516080525060805160a051615ec56200012f60003980614ced525080614d725250615ec56000f3fe608060405234801561001057600080fd5b50600436106103a45760003560e01c80636e5d6bea116101e9578063c2173d431161010f578063d7405481116100ad578063ec47de2a1161007c578063ec47de2a14611045578063f2c54fe814611071578063f2fde38b1461109d578063f3f51415146110c3576103a4565b8063d740548114610f27578063db6fff8c14610feb578063dfbe4ae014611017578063e77772fe1461103d576103a4565b8063cd596583116100e9578063cd59658314610dad578063d0342acd14610db5578063d0fb020314610de3578063d522cfd714610deb576103a4565b8063c2173d4314610cbb578063c534576114610ce1578063c722b1be14610da5576103a4565b80639a4a439511610187578063a4c0ed3611610156578063a4c0ed3614610b7a578063ab3a25d914610c33578063ad58bdd114610c5f578063ae813e9f14610c95576103a4565b80639a4a439514610afb5780639cb7595a14610b185780639d4051ae14610b4c578063a4b1c24314610b54576103a4565b8063867f7a4d116101c3578063867f7a4d14610a01578063871c076014610ac55780638da5cb5b14610acd57806390ad84a814610ad5576103a4565b80636e5d6bea146109895780637610722f146109af5780637837cf91146109d5576103a4565b80632f73a9f8116102ce578063472d35b91161026c578063613fa2f21161023b578063613fa2f2146108d757806361c04f84146108fd57806364696f971461092357806369ffa08a1461095b576103a4565b8063472d35b91461083257806347ac7d6a14610858578063593399821461087e578063613f1e4e1461089b576103a4565b80633da98c8b116102a85780633da98c8b146107785780633e6968b6146107df57806340f8dd86146107e7578063437764df1461080d576103a4565b80632f73a9f81461071e578063392e53cd146107445780633a50bc871461074c576103a4565b8063125e4cfb11610346578063272255bb11610315578063272255bb146105945780632803212f146105ca5780632ae87cdd146105f65780632d70061f146106dc576103a4565b8063125e4cfb146104ec57806316ef191314610522578063194153d31461054857806326aa101f1461056e576103a4565b80630950d515116103825780630950d5151461043b5780630b26cf66146104585780630b71a4a71461047e57806310775238146104ac576103a4565b806301e4f53a146103a957806301fcc1d3146103d7578063032f693f14610403575b600080fd5b6103d5600480360360408110156103bf57600080fd5b506001600160a01b0381351690602001356110e9565b005b6103d5600480360360408110156103ed57600080fd5b506001600160a01b038135169060200135611128565b6104296004803603602081101561041957600080fd5b50356001600160a01b03166111c7565b60408051918252519081900360200190f35b6103d56004803603602081101561045157600080fd5b503561121f565b6103d56004803603602081101561046e57600080fd5b50356001600160a01b03166112c8565b6103d56004803603604081101561049457600080fd5b506001600160a01b03813581169160200135166112dc565b6104d8600480360360408110156104c257600080fd5b506001600160a01b0381351690602001356113b1565b604080519115158252519081900360200190f35b6103d56004803603606081101561050257600080fd5b506001600160a01b03813581169160208101359091169060400135611424565b6104296004803603602081101561053857600080fd5b50356001600160a01b031661145e565b6104296004803603602081101561055e57600080fd5b50356001600160a01b03166114bb565b6104d86004803603602081101561058457600080fd5b50356001600160a01b0316611516565b6103d5600480360360608110156105aa57600080fd5b506001600160a01b03813581169160208101359091169060400135611529565b6103d5600480360360408110156105e057600080fd5b506001600160a01b03813516906020013561154c565b6103d5600480360360c081101561060c57600080fd5b6001600160a01b038235169190810190604081016020820135600160201b81111561063657600080fd5b82018360208201111561064857600080fd5b803590602001918460018302840111600160201b8311171561066957600080fd5b919390929091602081019035600160201b81111561068657600080fd5b82018360208201111561069857600080fd5b803590602001918460018302840111600160201b831117156106b957600080fd5b919350915060ff813516906001600160a01b03602082013516906040013561161b565b610702600480360360208110156106f257600080fd5b50356001600160a01b031661164d565b604080516001600160a01b039092168252519081900360200190f35b6103d56004803603602081101561073457600080fd5b50356001600160a01b03166116b3565b6104d86116c4565b6104d86004803603604081101561076257600080fd5b506001600160a01b038135169060200135611715565b6104d8600480360361018081101561078f57600080fd5b506001600160a01b0381358116916020810135821691604082019160a081019160e0820135811691610100810135821691610120820135811691610140810135821691610160909101351661176b565b610429611953565b610429600480360360208110156107fd57600080fd5b50356001600160a01b031661195c565b6108156119bb565b604080516001600160e01b03199092168252519081900360200190f35b6103d56004803603602081101561084857600080fd5b50356001600160a01b03166119c6565b6107026004803603602081101561086e57600080fd5b50356001600160a01b03166119d7565b6104d86004803603602081101561089457600080fd5b50356119e2565b6103d5600480360360808110156108b157600080fd5b506001600160a01b03813581169160208101358216916040820135169060600135611a35565b6103d5600480360360208110156108ed57600080fd5b50356001600160a01b0316611adc565b6107026004803603602081101561091357600080fd5b50356001600160a01b0316611aed565b6103d56004803603606081101561093957600080fd5b506001600160a01b038135811691602081013582169160409091013516611b56565b6103d56004803603604081101561097157600080fd5b506001600160a01b0381358116916020013516611c4c565b6103d56004803603602081101561099f57600080fd5b50356001600160a01b0316611cf4565b610429600480360360208110156109c557600080fd5b50356001600160a01b0316611d05565b6103d5600480360360408110156109eb57600080fd5b506001600160a01b038135169060200135611d5f565b6103d560048036036080811015610a1757600080fd5b6001600160a01b03823581169260208101359091169160408201359190810190608081016060820135600160201b811115610a5157600080fd5b820183602082011115610a6357600080fd5b803590602001918460018302840111600160201b83111715610a8457600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550611e37945050505050565b610702611e61565b610702611eb8565b6103d560048036036020811015610aeb57600080fd5b50356001600160a01b0316611f0f565b6103d560048036036020811015610b1157600080fd5b5035611f20565b610b20612115565b6040805167ffffffffffffffff9485168152928416602084015292168183015290519081900360600190f35b61070261211e565b61042960048036036020811015610b6a57600080fd5b50356001600160a01b0316612175565b6104d860048036036060811015610b9057600080fd5b6001600160a01b0382351691602081013591810190606081016040820135600160201b811115610bbf57600080fd5b820183602082011115610bd157600080fd5b803590602001918460018302840111600160201b83111715610bf257600080fd5b91908080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509295506121c9945050505050565b61042960048036036040811015610c4957600080fd5b506001600160a01b038135169060200135612230565b6103d560048036036060811015610c7557600080fd5b506001600160a01b03813581169160208101359091169060400135612296565b6104d860048036036020811015610cab57600080fd5b50356001600160a01b03166122a4565b6104d860048036036020811015610cd157600080fd5b50356001600160a01b03166122fd565b6103d560048036036080811015610cf757600080fd5b6001600160a01b03823581169260208101359091169160408201359190810190608081016060820135600160201b811115610d3157600080fd5b820183602082011115610d4357600080fd5b803590602001918460018302840111600160201b83111715610d6457600080fd5b91908080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525092955061232a945050505050565b61070261236a565b6107026123c1565b6103d560048036036040811015610dcb57600080fd5b506001600160a01b0381358116916020013516612418565b6107026125c7565b6103d5600480360360e0811015610e0157600080fd5b6001600160a01b038235169190810190604081016020820135600160201b811115610e2b57600080fd5b820183602082011115610e3d57600080fd5b803590602001918460018302840111600160201b83111715610e5e57600080fd5b919390929091602081019035600160201b811115610e7b57600080fd5b820183602082011115610e8d57600080fd5b803590602001918460018302840111600160201b83111715610eae57600080fd5b9193909260ff833516926001600160a01b03602082013516926040820135929091608081019060600135600160201b811115610ee957600080fd5b820183602082011115610efb57600080fd5b803590602001918460018302840111600160201b83111715610f1c57600080fd5b50909250905061261e565b6103d560048036036080811015610f3d57600080fd5b6001600160a01b03823581169260208101359091169160408201359190810190608081016060820135600160201b811115610f7757600080fd5b820183602082011115610f8957600080fd5b803590602001918460018302840111600160201b83111715610faa57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550612694945050505050565b6103d56004803603604081101561100157600080fd5b506001600160a01b0381351690602001356126a0565b6107026004803603602081101561102d57600080fd5b50356001600160a01b031661273d565b610702612748565b6103d56004803603604081101561105b57600080fd5b506001600160a01b03813516906020013561279f565b6104296004803603604081101561108757600080fd5b506001600160a01b038135169060200135612840565b6103d5600480360360208110156110b357600080fd5b50356001600160a01b03166128a9565b610429600480360360208110156110d957600080fd5b50356001600160a01b03166128ba565b6111248233836000805b506040519080825280601f01601f19166020018201604052801561111e576020820181803683370190505b50612910565b5050565b611130612a71565b61113982611516565b61114257600080fd5b8015806111615750600081118015611161575061115e8261195c565b81105b61116a57600080fd5b60408051700caf0cac6eae8d2dedc9ac2f0a0cae4a8f607b1b60208083019190915260609490941b6001600160601b0319166031820152815180820360250181526045909101825280519084012060009081529283905290912055565b60408051670dac2f0a0cae4a8f60c31b6020808301919091526001600160601b0319606085901b1660288301528251601c818403018152603c909201835281519181019190912060009081529081905220545b919050565b611227612a98565b611230816119e2565b1561123a57600080fd5b600061124582612b42565b9050600061125283612b9b565b9050600061125f84612bf8565b905061126a84612c47565b611275838383612ca0565b604080516001600160a01b03808616825284166020820152808201839052905185917f07b5483b8e4bd8ea240a474d5117738350e7d431e3668c48a97910b0b397796a919081900360600190a250505050565b6112d0612a71565b6112d981612cc1565b50565b6112e4612a71565b6112ed81611516565b156112f757600080fd5b600061130282611aed565b6001600160a01b03161461131557600080fd5b60006113208361164d565b6001600160a01b03161461133357600080fd5b6113486001600160a01b038216306001612d3d565b806001600160a01b03166342966c6860016040518263ffffffff1660e01b815260040180828152602001915050600060405180830381600087803b15801561138f57600080fd5b505af11580156113a3573d6000803e3d6000fd5b505050506111248282612dc9565b6000806113cf836113c9866113c4611953565b612230565b90612ec4565b905060006113dd60006128ba565b1180156113f25750806113ef856128ba565b10155b80156114065750611402846111c7565b8311155b801561141a575061141684612175565b8310155b9150505b92915050565b61142c612a98565b60006114378461164d565b905061144281611516565b61144b57600080fd5b6114588160008585612f25565b50505050565b60408051700caf0cac6eae8d2dedc9ac2f0a0cae4a8f607b1b60208083019190915260609390931b6001600160601b0319166031820152815180820360250181526045909101825280519083012060009081529182905290205490565b604080516e6d65646961746f7242616c616e636560881b60208083019190915260609390931b6001600160601b031916602f820152815180820360230181526043909101825280519083012060009081529182905290205490565b60008061152283612175565b1192915050565b611531612a98565b61153a8361304f565b6115478360018484612f25565b505050565b611554612a71565b61155d82611516565b61156657600080fd5b61156f826111c7565b81118061157a575080155b61158357600080fd5b604080516919185a5b1e531a5b5a5d60b21b6020808301919091526001600160601b0319606086901b16602a8301528251601e818403018152603e83018085528151918301919091206000908152918290529083902084905583905290516001600160a01b038416917fca0b3dabefdbd8c72c0a9cf4a6e9d107da897abf036ef3f3f3b010cdd25941599190819003605e0190a25050565b611623612a98565b600061163389898989898961310b565b90506116428160008585612f25565b505050505050505050565b604080516f686f6d65546f6b656e4164647265737360801b60208083019190915260609390931b6001600160601b03191660308201528151808203602401815260449091018252805190830120600090815260029092529020546001600160a01b031690565b6116bb612a71565b6112d981613459565b7f0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba60005260046020527f078d888f9b66f3f8bfa10909e31f1e16240db73449f0500afdbbe3a70da457cc5460ff1690565b60008061172d836113c986611728611953565b612840565b9050600061173b600061195c565b11801561175057508061174d8561195c565b10155b801561141a57506117608461145e565b909211159392505050565b60408051600481526024810182526020810180516001600160e01b03166337ef410160e11b1781529151815160009384936060933093919290918291908083835b602083106117cb5780518252601f1990920191602091820191016117ac565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d806000811461182b576040519150601f19603f3d011682016040523d82523d6000602084013e611830565b606091505b509150915081158061186c57508051602014801561186c575080806020019051602081101561185e57600080fd5b50516001600160a01b031633145b8061187657503330145b61187f57600080fd5b6118876116c4565b1561189157600080fd5b61189a8c612cc1565b6118a38b6134d5565b6118d760008b600380602002604051908101604052809291908260036020028082843760009201919091525061353f915050565b60408051808201825261190691600091908c906002908390839080828437600092019190915250613693915050565b61190f88613782565b6119188761380f565b61192186613459565b61192a856138d7565b61193384613964565b61193b6139f1565b6119436116c4565b9c9b505050505050505050505050565b62015180420490565b6040805172195e1958dd5d1a5bdb91185a5b1e531a5b5a5d606a1b60208083019190915260609390931b6001600160601b0319166033820152815180820360270181526047909101825280519083012060009081529182905290205490565b6358a8b61360e11b90565b6119ce612a71565b6112d9816138d7565b600061141e82611aed565b604080516b1b595cdcd859d9519a5e195960a21b602080830191909152602c80830185905283518084039091018152604c909201835281519181019190912060009081526004909152205460ff16919050565b333014611a4157600080fd5b611a4a84613459565b611a5383613964565b611a5c82613782565b604080516919185a5b1e531a5b5a5d60b21b6020808301919091526000602a83018190528351601e818503018152603e84018086528151918401919091208252918190528381208590559084905291517fca0b3dabefdbd8c72c0a9cf4a6e9d107da897abf036ef3f3f3b010cdd259415991819003605e0190a250505050565b611ae4612a71565b6112d981613782565b6040805172666f726569676e546f6b656e4164647265737360681b60208083019190915260609390931b6001600160601b03191660338201528151808203602701815260479091018252805190830120600090815260029092529020546001600160a01b031690565b306001600160a01b0316636fde82026040518163ffffffff1660e01b815260040160206040518083038186803b158015611b8f57600080fd5b505afa158015611ba3573d6000803e3d6000fd5b505050506040513d6020811015611bb957600080fd5b50516001600160a01b03163314611bcf57600080fd5b826001600160a01b03166369ffa08a83836040518363ffffffff1660e01b815260040180836001600160a01b03168152602001826001600160a01b0316815260200192505050600060405180830381600087803b158015611c2f57600080fd5b505af1158015611c43573d6000803e3d6000fd5b50505050505050565b306001600160a01b0316636fde82026040518163ffffffff1660e01b815260040160206040518083038186803b158015611c8557600080fd5b505afa158015611c99573d6000803e3d6000fd5b505050506040513d6020811015611caf57600080fd5b50516001600160a01b03163314611cc557600080fd5b6001600160a01b0382161580611ce15750611cdf82611516565b155b611cea57600080fd5b6111248282613a48565b611cfc612a71565b6112d9816134d5565b600080611d11836111c7565b90506000611d1e846128ba565b90506000611d2e856113c4611953565b90506000818311611d40576000611d44565b8183035b9050808410611d535780611d55565b835b9695505050505050565b611d67612a71565b611d7082611516565b611d7957600080fd5b611d828261145e565b811180611d8d575080155b611d9657600080fd5b6040805172195e1958dd5d1a5bdb91185a5b1e531a5b5a5d606a1b6020808301919091526001600160601b0319606086901b16603383015282516027818403018152604783018085528151918301919091206000908152918290529083902084905583905290516001600160a01b038416917f4c177b42dbe934b3abbc0208c11a42e46589983431616f1710ab19969c5ed62e919081900360670190a25050565b611e3f612a98565b611e488461304f565b611e558460018585612f25565b61145883858484613a82565b7f98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab988060005260026020527f0c1206883be66049a02d4937078367c00b3d71dd1a9465df969363c6ddeac96d546001600160a01b031690565b7f02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c060005260026020527fb7802e97e87ef2842a6cce7da7ffaeaedaa2f61a6a7870b23d9d01fc9b73712e546001600160a01b031690565b611f17612a71565b6112d981613964565b6000611f2a6123c1565b9050806001600160a01b031663cb08a10c836040518263ffffffff1660e01b81526004018082815260200191505060206040518083038186803b158015611f7057600080fd5b505afa158015611f84573d6000803e3d6000fd5b505050506040513d6020811015611f9a57600080fd5b505115611fa657600080fd5b306001600160a01b0316816001600160a01b0316633f9a8e7e846040518263ffffffff1660e01b81526004018082815260200191505060206040518083038186803b158015611ff457600080fd5b505afa158015612008573d6000803e3d6000fd5b505050506040513d602081101561201e57600080fd5b50516001600160a01b03161461203357600080fd5b61203b611e61565b6001600160a01b0316816001600160a01b0316634a610b04846040518263ffffffff1660e01b81526004018082815260200191505060206040518083038186803b15801561208857600080fd5b505afa15801561209c573d6000803e3d6000fd5b505050506040513d60208110156120b257600080fd5b50516001600160a01b0316146120c757600080fd5b6040805160248082018590528251808303909101815260449091019091526020810180516001600160e01b0316630950d51560e01b9081179091529061210e816001613bef565b5050505050565b60036000809192565b7f5f5bc4e0b888be22a35f2166061a04607296c26861006b9b8e089a172696a82260005260026020527f60072fd9ffad01d76b1d1421ce17a3613dc06795e4b113745995ad1d84a52121546001600160a01b031690565b60408051670dad2dca0cae4a8f60c31b60208083019190915260609390931b6001600160601b03191660288201528151808203601c018152603c909101825280519083012060009081529182905290205490565b60006121d3613e03565b6122265760408051600081526020810190915282518590601411612216576121fa84613e28565b9050601484511115612216578351601319016014850190815291505b6122233387838886613e2f565b50505b5060019392505050565b604080516f746f74616c5370656e7450657244617960801b60208083019190915260609490941b6001600160601b031916603082015260448082019390935281518082039093018352606401815281519183019190912060009081529182905290205490565b6115478383836000806110f3565b604080516861636b4465706c6f7960b81b60208083019190915260609390931b6001600160601b03191660298201528151808203601d018152603d90910182528051908301206000908152600490925290205460ff1690565b600061230882611516565b801561141e5750600061231a83611aed565b6001600160a01b03161492915050565b612332612a98565b600061233d8561164d565b905061234881611516565b61235157600080fd5b61235e8160008686612f25565b61210e84828585613a82565b7f5f86f226cd489cc09187d5f5e0adfb94308af0d4ceac482dd8a8adea9d80daf460005260026020527fab9e97adef29adb9492a44df89badb4a706f8f35202918df21ca61ed056c4868546001600160a01b031690565b7f811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f60005260026020527fb4ed64697d3ef8518241966f7c6f28b0d72f20f51198717d198d2d55076c593d546001600160a01b031690565b306001600160a01b0316636fde82026040518163ffffffff1660e01b815260040160206040518083038186803b15801561245157600080fd5b505afa158015612465573d6000803e3d6000fd5b505050506040513d602081101561247b57600080fd5b50516001600160a01b0316331461249157600080fd5b806001600160a01b0381166124a557600080fd5b6124ae836122fd565b6124b757600080fd5b6000836001600160a01b03166370a08231306040518263ffffffff1660e01b815260040180826001600160a01b0316815260200191505060206040518083038186803b15801561250657600080fd5b505afa15801561251a573d6000803e3d6000fd5b505050506040513d602081101561253057600080fd5b50519050600061253f856114bb565b905080821161254d57600080fd5b808203600061255b87611d05565b90506000811161256a57600080fd5b80821115612576578091505b61258887612582611953565b84613f8f565b604080516000808252602082019092526060916125aa918a908a90879061400d565b905060006125b9826001613bef565b9050611642818a8a87614688565b7f779a349c5bee7817f04c960f525ee3e2f2516078c38c68a3149787976ee837e560005260026020527fc155b21a14c4592b97825e495fbe0d2705fb46420018cac5bfa7a09c43fae517546001600160a01b031690565b612626612a98565b60006126368b8b8b8b8b8b61310b565b90506126458160008787612f25565b61268785828686868080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250613a8292505050565b5050505050505050505050565b61145884848484612910565b6126a8612a71565b6126b182611516565b6126ba57600080fd5b8015806126e057506126cb82612175565b811180156126e057506126dd826128ba565b81105b6126e957600080fd5b60408051670dac2f0a0cae4a8f60c31b60208083019190915260609490941b6001600160601b03191660288201528151808203601c018152603c909101825280519084012060009081529283905290912055565b600061141e8261164d565b7f269c5905f777ee6391c7a361d17039a7d62f52ba9fffeb98c5ade342705731a360005260026020527f15c764a0cd4bb3d72a49abedd3d6793c3b93c0d57f43174a348b443be86f79c1546001600160a01b031690565b6127a7612a71565b6127b082611516565b6127b957600080fd5b6000811180156127d057506127cd826128ba565b81105b80156127e357506127e0826111c7565b81105b6127ec57600080fd5b60408051670dad2dca0cae4a8f60c31b60208083019190915260609490941b6001600160601b03191660288201528151808203601c018152603c909101825280519084012060009081529283905290912055565b6040805172746f74616c457865637574656450657244617960681b60208083019190915260609490941b6001600160601b031916603382015260478082019390935281518082039093018352606701815281519183019190912060009081529182905290205490565b6128b1612a71565b6112d98161380f565b604080516919185a5b1e531a5b5a5d60b21b60208083019190915260609390931b6001600160601b031916602a8201528151808203601e018152603e909101825280519083012060009081529182905290205490565b612918613e03565b1561292257600080fd5b6000846001600160a01b03166370a08231306040518263ffffffff1660e01b815260040180826001600160a01b0316815260200191505060206040518083038186803b15801561297157600080fd5b505afa158015612985573d6000803e3d6000fd5b505050506040513d602081101561299b57600080fd5b505190506129a960016146f8565b6129be6001600160a01b03861633308661471c565b6129c860006146f8565b6000612a4d82876001600160a01b03166370a08231306040518263ffffffff1660e01b815260040180826001600160a01b0316815260200191505060206040518083038186803b158015612a1b57600080fd5b505afa158015612a2f573d6000803e3d6000fd5b505050506040513d6020811015612a4557600080fd5b505190614776565b905083811115612a5c57600080fd5b612a698633878487613e2f565b505050505050565b612a79611eb8565b6001600160a01b0316336001600160a01b031614612a9657600080fd5b565b6000612aa26123c1565b9050336001600160a01b03821614612ab957600080fd5b612ac1611e61565b6001600160a01b0316816001600160a01b031663d67bdd256040518163ffffffff1660e01b815260040160206040518083038186803b158015612b0357600080fd5b505afa158015612b17573d6000803e3d6000fd5b505050506040513d6020811015612b2d57600080fd5b50516001600160a01b0316146112d957600080fd5b604080516b36b2b9b9b0b3b2aa37b5b2b760a11b602080830191909152602c80830185905283518084039091018152604c90920183528151918101919091206000908152600290915220546001600160a01b0316919050565b604080516f1b595cdcd859d9549958da5c1a595b9d60821b602080830191909152603080830185905283518084039091018152605090920183528151918101919091206000908152600290915220546001600160a01b0316919050565b604080516b6d65737361676556616c756560a01b602080830191909152602c80830185905283518084039091018152604c90920183528151918101919091206000908152908190522054919050565b604080516b1b595cdcd859d9519a5e195960a21b602080830191909152602c8083019490945282518083039094018452604c9091018252825192810192909220600090815260049092529020805460ff19166001179055565b6115476000612cae85611aed565b6001600160a01b031614848484856147b8565b612cca8161480c565b612cd357600080fd5b7f811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f60005260026020527fb4ed64697d3ef8518241966f7c6f28b0d72f20f51198717d198d2d55076c593d80546001600160a01b0319166001600160a01b0392909216919091179055565b826001600160a01b03166340c10f1983836040518363ffffffff1660e01b815260040180836001600160a01b0316815260200182815260200192505050602060405180830381600087803b158015612d9457600080fd5b505af1158015612da8573d6000803e3d6000fd5b505050506040513d6020811015612dbe57600080fd5b505161154757600080fd5b604080516f686f6d65546f6b656e4164647265737360801b6020808301919091526001600160601b0319606086811b82166030850152845160248186030181526044850186528051908401206000908152600280855286822080546001600160a01b03808b166001600160a01b0319928316811790935572666f726569676e546f6b656e4164647265737360681b60648a0152948a901b90951660778801528751606b818903018152608b909701808952875197870197909720835294529485208054909216908716908117909155909290917f78d063210f4fb6b4cc932390bb8045fa2465e51349590182dab8b9e84c57a6ee9190a35050565b600082820183811015612f1e576040805162461bcd60e51b815260206004820152601b60248201527f536166654d6174683a206164646974696f6e206f766572666c6f770000000000604482015290519081900360640190fd5b9392505050565b612f2d613e03565b15612f3757600080fd5b612f418482611715565b612f4a57600080fd5b612f5c84612f56611953565b83614848565b806000612f8c7f03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f12625868389866148c9565b90506000612f98614c74565b90508115612fed5760408051838152905182916001600160a01b038a16917fd560a522f77cfb4924d6fe51be1615e540a48a8931c48fe0349c7f47ebabe7479181900360200190a3612fea8383614776565b92505b612ffa86888786886147b8565b80856001600160a01b0316886001600160a01b03167f9afd47907e25028cdaca89d193518c302bbb128617d5a992c5abd45815526593866040518082815260200191505060405180910390a450505050505050565b604080516861636b4465706c6f7960b81b6020808301919091526001600160601b0319606085901b1660298301528251601d818403018152603d909201835281519181019190912060009081526004909152205460ff166112d957604080516861636b4465706c6f7960b81b6020808301919091526001600160601b0319606085901b1660298301528251601d818403018152603d90920183528151918101919091206000908152600490915220805460ff1916600117905550565b6000806131178861164d565b90506001600160a01b0381166133be57606087878080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525050604080516020601f8b01819004810282018101909252898152939450606093925089915088908190840183828082843760009201919091525050845192935050501515806131ac575060008151115b6131b557600080fd5b81516131c3578091506131cc565b80516131cc5750805b6131d582614ce7565b91506131df612748565b6001600160a01b031663a39d6acf8383886131f86123c1565b6001600160a01b0316631544298e6040518163ffffffff1660e01b815260040160206040518083038186803b15801561323057600080fd5b505afa158015613244573d6000803e3d6000fd5b505050506040513d602081101561325a57600080fd5b50516040516001600160e01b031960e087901b16815260ff831660448201526064810182905260806004820190815285516084830152855190918291602482019160a40190602089019080838360005b838110156132c25781810151838201526020016132aa565b50505050905090810190601f1680156132ef5780820380516001836020036101000a031916815260200191505b50838103825286518152865160209182019188019080838360005b8381101561332257818101518382015260200161330a565b50505050905090810190601f16801561334f5780820380516001836020036101000a031916815260200191505b509650505050505050602060405180830381600087803b15801561337257600080fd5b505af1158015613386573d6000803e3d6000fd5b505050506040513d602081101561339c57600080fd5b505192506133aa8a84612dc9565b6133b7838660ff16614d9c565b505061344e565b6133c781611516565b61344e578260ff16816001600160a01b031663313ce5676040518163ffffffff1660e01b815260040160206040518083038186803b15801561340857600080fd5b505afa15801561341c573d6000803e3d6000fd5b505050506040513d602081101561343257600080fd5b505160ff161461344157600080fd5b61344e818460ff16614d9c565b979650505050505050565b6134628161480c565b61346b57600080fd5b7f269c5905f777ee6391c7a361d17039a7d62f52ba9fffeb98c5ade342705731a360005260026020527f15c764a0cd4bb3d72a49abedd3d6793c3b93c0d57f43174a348b443be86f79c180546001600160a01b0319166001600160a01b0392909216919091179055565b7f98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab988060005260026020527f0c1206883be66049a02d4937078367c00b3d71dd1a9465df969363c6ddeac96d80546001600160a01b0319166001600160a01b0392909216919091179055565b604081015115801590613559575060408101516020820151115b8015613569575060208101518151115b61357257600080fd5b8051604080516919185a5b1e531a5b5a5d60b21b602082810191909152606086901b6001600160601b031916602a83018190528351808403601e018152603e8401855280519083012060009081528083528481209590955581860151670dac2f0a0cae4a8f60c31b605e850152606684018290528451605a818603018152607a8501865280519084012086528583528486205583860151670dad2dca0cae4a8f60c31b609a85015260a28401919091528351609681850301815260b690930184528251928201929092208452839052908220556001600160a01b038316907fca0b3dabefdbd8c72c0a9cf4a6e9d107da897abf036ef3f3f3b010cdd25941599083905b60200201516040518082815260200191505060405180910390a25050565b80516020820151106136a457600080fd5b80516040805172195e1958dd5d1a5bdb91185a5b1e531a5b5a5d606a1b602082810191909152606086901b6001600160601b031916603383018190528351808403602701815260478401855280519083012060009081528083528481209590955581860151700caf0cac6eae8d2dedc9ac2f0a0cae4a8f607b1b606785015260788401919091528351606c818503018152608c90930184528251928201929092208452839052908220556001600160a01b038316907f4c177b42dbe934b3abbc0208c11a42e46589983431616f1710ab19969c5ed62e908390613675565b6001600160a01b038116158061379c575061379c8161480c565b6137a557600080fd5b7f5f5bc4e0b888be22a35f2166061a04607296c26861006b9b8e089a172696a82260005260026020527f60072fd9ffad01d76b1d1421ce17a3613dc06795e4b113745995ad1d84a5212180546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160a01b03811661382257600080fd5b7f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e061384b611eb8565b604080516001600160a01b03928316815291841660208301528051918290030190a17f02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c060005260026020527fb7802e97e87ef2842a6cce7da7ffaeaedaa2f61a6a7870b23d9d01fc9b73712e80546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160a01b03811615806138f157506138f18161480c565b6138fa57600080fd5b7f779a349c5bee7817f04c960f525ee3e2f2516078c38c68a3149787976ee837e560005260026020527fc155b21a14c4592b97825e495fbe0d2705fb46420018cac5bfa7a09c43fae51780546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160a01b038116158061397e575061397e8161480c565b61398757600080fd5b7f5f86f226cd489cc09187d5f5e0adfb94308af0d4ceac482dd8a8adea9d80daf460005260026020527fab9e97adef29adb9492a44df89badb4a706f8f35202918df21ca61ed056c486880546001600160a01b0319166001600160a01b0392909216919091179055565b7f0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba60005260046020527f078d888f9b66f3f8bfa10909e31f1e16240db73449f0500afdbbe3a70da457cc805460ff19166001179055565b806001600160a01b038116613a5c57600080fd5b6001600160a01b038316613a7857613a7382614f20565b611547565b6115478383614f2b565b613a8b8461480c565b1561145857836001600160a01b031663db7af85460e01b84848460405160240180846001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b83811015613afa578181015183820152602001613ae2565b50505050905090810190601f168015613b275780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529181526020820180516001600160e01b03166001600160e01b031990991698909817885251815191979096508695509350915081905083835b60208310613b8d5780518252601f199092019160209182019101613b6e565b6001836020036101000a0380198251168184511680821785525050505050509050019150506000604051808303816000865af19150503d8060008114611c43576040519150601f19603f3d011682016040523d82523d6000602084013e611c43565b600080613bfa611e61565b90506000613c0785614fb8565b90506000613c136123c1565b905084613d0c57806001600160a01b03166394643f718488856040518463ffffffff1660e01b815260040180846001600160a01b0316815260200180602001838152602001828103825284818151815260200191508051906020019080838360005b83811015613c8d578181015183820152602001613c75565b50505050905090810190601f168015613cba5780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b158015613cdb57600080fd5b505af1158015613cef573d6000803e3d6000fd5b505050506040513d6020811015613d0557600080fd5b5051611d55565b806001600160a01b031663dc8601b38488856040518463ffffffff1660e01b815260040180846001600160a01b0316815260200180602001838152602001828103825284818151815260200191508051906020019080838360005b83811015613d7f578181015183820152602001613d67565b50505050905090810190601f168015613dac5780820380516001836020036101000a031916815260200191505b50945050505050602060405180830381600087803b158015613dcd57600080fd5b505af1158015613de1573d6000803e3d6000fd5b505050506040513d6020811015613df757600080fd5b50519695505050505050565b7f6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e925490565b6014015190565b6001600160a01b03831615801590613e605750613e4a611e61565b6001600160a01b0316836001600160a01b031614155b613e6957600080fd5b613e7285611516565b613e92576000613e81866150ec565b9050613e90868260ff16614d9c565b505b613e9c85836113b1565b613ea557600080fd5b613eb185612582611953565b6000613ebc86611aed565b90506000613ef77f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee266001600160a01b03841615888a886148c9565b90506000613f058583614776565b90506060613f16848a89858961400d565b90506000613f2e82613f298c8c8c6152ba565b613bef565b9050613f3c818b8b86614688565b8315613f835760408051858152905182916001600160a01b038d16917fd560a522f77cfb4924d6fe51be1615e540a48a8931c48fe0349c7f47ebabe7479181900360200190a35b50505050505050505050565b613f9d816113c98585612230565b600080858560405160200180806f746f74616c5370656e7450657244617960801b815250601001836001600160a01b031660601b81526014018281526020019250505060405160208183030381529060405280519060200120815260200190815260200160002081905550505050565b60606000808351118061403257506000356001600160e01b03191663d740548160e01b145b90506001600160a01b0387166144ed5761405886614053866113c98a6114bb565b61536a565b614061866122a4565b1561419e57806140bf57604080516001600160a01b0380891660248301528716604482015260648082018790528251808303909101815260849091019091526020810180516001600160e01b031663125e4cfb60e01b179052614196565b63c534576160e01b8686868660405160240180856001600160a01b03168152602001846001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b8381101561412f578181015183820152602001614117565b50505050905090810190601f16801561415c5780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b03166001600160e01b0319909916989098179097525050505050505b91505061467f565b60006141a9876150ec565b905060606141b6886153c5565b905060606141c38961558b565b90506000825111806141d6575060008151115b6141df57600080fd5b8361433257632ae87cdd60e01b898383868c8c60405160240180876001600160a01b0316815260200180602001806020018660ff168152602001856001600160a01b03168152602001848152602001838103835288818151815260200191508051906020019080838360005b8381101561426357818101518382015260200161424b565b50505050905090810190601f1680156142905780820380516001836020036101000a031916815260200191505b50838103825287518152875160209182019189019080838360005b838110156142c35781810151838201526020016142ab565b50505050905090810190601f1680156142f05780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b03166001600160e01b0319909c169b909b17909a52506144e2975050505050505050565b63d522cfd760e01b898383868c8c8c60405160240180886001600160a01b0316815260200180602001806020018760ff168152602001866001600160a01b031681526020018581526020018060200184810384528a818151815260200191508051906020019080838360005b838110156143b657818101518382015260200161439e565b50505050905090810190601f1680156143e35780820380516001836020036101000a031916815260200191505b5084810383528951815289516020918201918b019080838360005b838110156144165781810151838201526020016143fe565b50505050905090810190601f1680156144435780820380516001836020036101000a031916815260200191505b50848103825285518152855160209182019187019080838360005b8381101561447657818101518382015260200161445e565b50505050905090810190601f1680156144a35780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b03166001600160e01b0319909e169d909d17909c5250505050505050505050505b94505050505061467f565b856001600160a01b03166342966c68856040518263ffffffff1660e01b815260040180828152602001915050600060405180830381600087803b15801561453357600080fd5b505af1158015614547573d6000803e3d6000fd5b50505050806145a457604080516001600160a01b03808a1660248301528716604482015260648082018790528251808303909101815260849091019091526020810180516001600160e01b031663272255bb60e01b17905261467b565b63867f7a4d60e01b8786868660405160240180856001600160a01b03168152602001846001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b838110156146145781810151838201526020016145fc565b50505050905090810190601f1680156146415780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529190526020810180516001600160e01b03166001600160e01b0319909916989098179097525050505050505b9150505b95945050505050565b61469284846156be565b61469c848361572a565b6146a6848261579a565b83826001600160a01b0316846001600160a01b03167f59a9a8027b9c87b961e254899821c9a276b5efc35d1f7409ea4f291470f1629a846040518082815260200191505060405180910390a450505050565b7f6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e9255565b604080516001600160a01b0380861660248301528416604482015260648082018490528251808303909101815260849091019091526020810180516001600160e01b03166323b872dd60e01b1790526114589085906157e9565b6000612f1e83836040518060400160405280601e81526020017f536166654d6174683a207375627472616374696f6e206f766572666c6f77000081525061589a565b84156147ee576147d26001600160a01b0385168484615931565b6147e984614053836147e3886114bb565b90614776565b61210e565b61210e83836147fc87615983565b6001600160a01b03169190612d3d565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061484057508115155b949350505050565b614856816113c98585612840565b6000808585604051602001808072746f74616c457865637574656450657244617960681b815250601301836001600160a01b031660601b81526014018281526020019250505060405160208183030381529060405280519060200120815260200190815260200160002081905550505050565b6000806148d46125c7565b90506001600160a01b03811615614c67577f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26871480156149895750806001600160a01b031663071664c5866040518263ffffffff1660e01b815260040180826001600160a01b0316815260200191505060206040518083038186803b15801561495c57600080fd5b505afa158015614970573d6000803e3d6000fd5b505050506040513d602081101561498657600080fd5b50515b1561499857600091505061467f565b6000816001600160a01b031663710c60138987876040518463ffffffff1660e01b815260040180848152602001836001600160a01b03168152602001828152602001935050505060206040518083038186803b1580156149f757600080fd5b505afa158015614a0b573d6000803e3d6000fd5b505050506040513d6020811015614a2157600080fd5b505190508015614c5e577f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26881415614a6c57614a676001600160a01b0386168383615931565b614bf6565b600087614a80576340c10f1960e01b614a89565b63a9059cbb60e01b5b604080516001600160a01b038681166024830152604480830187905283518084039091018152606490920183526020820180516001600160e01b03166001600160e01b0319861617815292518251949550600094606094928c16939282918083835b60208310614b0a5780518252601f199092019160209182019101614aeb565b6001836020036101000a0380198251168184511680821785525050505050509050019150506000604051808303816000865af19150503d8060008114614b6c576040519150601f19603f3d011682016040523d82523d6000602084013e614b71565b606091505b509150915081614bc8576040805185815290516001600160a01b038a16917fb8842ee9d1603ef0f5620c01feb6cf2e7921091eba728cbce562041a86ee109a919081900360200190a260009550505050505061467f565b80511580614be95750808060200190516020811015614be657600080fd5b50515b614bf257600080fd5b5050505b816001600160a01b0316634e281a7b866040518263ffffffff1660e01b815260040180826001600160a01b03168152602001915050600060405180830381600087803b158015614c4557600080fd5b505af1158015614c59573d6000803e3d6000fd5b505050505b915061467f9050565b5060009695505050505050565b6000614c7e6123c1565b6001600160a01b031663669f618b6040518163ffffffff1660e01b815260040160206040518083038186803b158015614cb657600080fd5b505afa158015614cca573d6000803e3d6000fd5b505050506040513d6020811015614ce057600080fd5b5051905090565b606080827f00000000000000000000000000000000000000000000000000000000000000006040516020018083805190602001908083835b60208310614d3e5780518252601f199092019160209182019101614d1f565b51815160209384036101000a60001901801990921691161790529201938452506040805180850381529390910190525093517f0000000000000000000000000000000000000000000000000000000000000000018452509192915050565b60006012821015614e905781601203600a0a90506000614dc682614dc06000612175565b906159c9565b90506000614dd883614dc060006111c7565b90506000614dea84614dc060006128ba565b90506000614dfc85614dc0600061145e565b90506000614e0e86614dc0600061195c565b905084614e445760019450848411614e445760649350606491508383111580614e375750818111155b15614e4457506127109150815b614e688860405180606001604052808681526020018781526020018881525061353f565b614e8688604051806040016040528084815260200185815250613693565b5050505050611547565b60128203600a0a9050614ee9836040518060600160405280614ebc85614eb660006128ba565b90615a0b565b8152602001614ecf85614eb660006111c7565b8152602001614ee285614eb66000612175565b905261353f565b611547836040518060400160405280614f0685614eb6600061195c565b8152602001614f1985614eb6600061145e565b9052613693565b476111248282615a64565b604080516370a0823160e01b8152306004820152905183916000916001600160a01b038416916370a08231916024808301926020929190829003018186803b158015614f7657600080fd5b505afa158015614f8a573d6000803e3d6000fd5b505050506040513d6020811015614fa057600080fd5b505190506114586001600160a01b0383168483615931565b600080614fc361211e565b90506001600160a01b03811661504857614fdb6123c1565b6001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b15801561501357600080fd5b505afa158015615027573d6000803e3d6000fd5b505050506040513d602081101561503d57600080fd5b5051915061121a9050565b60405163fb47201960e01b81526020600482018181528551602484015285516001600160a01b0385169363fb4720199388939283926044019185019080838360005b838110156150a257818101518382015260200161508a565b50505050905090810190601f1680156150cf5780820380516001836020036101000a031916815260200191505b509250505060206040518083038186803b15801561501357600080fd5b60408051600481526024810182526020810180516001600160e01b031663313ce56760e01b1781529151815160009384936060936001600160a01b03881693919290918291908083835b602083106151555780518252601f199092019160209182019101615136565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d80600081146151b5576040519150601f19603f3d011682016040523d82523d6000602084013e6151ba565b606091505b50915091508161529b5760408051600481526024810182526020810180516001600160e01b0316632e0f262560e01b178152915181516001600160a01b0388169382918083835b602083106152205780518252601f199092019160209182019101615201565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d8060008114615280576040519150601f19603f3d011682016040523d82523d6000602084013e615285565b606091505b5090925090508161529b5760009250505061121a565b8080602001905160208110156152b057600080fd5b5051949350505050565b6000806152c561236a565b90506001600160a01b038116158061467f57506040805163f7baa04960e01b81526001600160a01b03878116600483015286811660248301528581166044830152915160009284169163f7baa049916064808301926020929190829003018186803b15801561533357600080fd5b505afa158015615347573d6000803e3d6000fd5b505050506040513d602081101561535d57600080fd5b5051121595945050505050565b604080516e6d65646961746f7242616c616e636560881b60208083019190915260609490941b6001600160601b031916602f820152815180820360230181526043909101825280519084012060009081529283905290912055565b60408051600481526024810182526020810180516001600160e01b03166306fdde0360e01b1781529151815160609360009385936001600160a01b03881693919290918291908083835b6020831061542e5780518252601f19909201916020918201910161540f565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d806000811461548e576040519150601f19603f3d011682016040523d82523d6000602084013e615493565b606091505b5091509150816155825760408051600481526024810182526020810180516001600160e01b03166351fa6fbf60e11b178152915181516001600160a01b0388169382918083835b602083106154f95780518252601f1990920191602091820191016154da565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d8060008114615559576040519150601f19603f3d011682016040523d82523d6000602084013e61555e565b606091505b5090925090508161558257604051806020016040528060008152509250505061121a565b61484081615ac9565b60408051600481526024810182526020810180516001600160e01b03166395d89b4160e01b1781529151815160609360009385936001600160a01b03881693919290918291908083835b602083106155f45780518252601f1990920191602091820191016155d5565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d8060008114615654576040519150601f19603f3d011682016040523d82523d6000602084013e615659565b606091505b5091509150816155825760408051600481526024810182526020810180516001600160e01b0316631eedf1af60e31b178152915181516001600160a01b038816938291808383602083106154f95780518252601f1990920191602091820191016154da565b604080516b36b2b9b9b0b3b2aa37b5b2b760a11b602080830191909152602c8083019590955282518083039095018552604c90910182528351938101939093206000908152600290935290912080546001600160a01b0319166001600160a01b03909216919091179055565b604080516f1b595cdcd859d9549958da5c1a595b9d60821b60208083019190915260308083019590955282518083039095018552605090910182528351938101939093206000908152600290935290912080546001600160a01b0319166001600160a01b03909216919091179055565b604080516b6d65737361676556616c756560a01b602080830191909152602c8083019590955282518083039095018552604c909101825283519381019390932060009081529283905290912055565b606061583e826040518060400160405280602081526020017f5361666545524332303a206c6f772d6c6576656c2063616c6c206661696c6564815250856001600160a01b0316615c259092919063ffffffff16565b8051909150156115475780806020019051602081101561585d57600080fd5b50516115475760405162461bcd60e51b815260040180806020018281038252602a815260200180615e66602a913960400191505060405180910390fd5b600081848411156159295760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b838110156158ee5781810151838201526020016158d6565b50505050905090810190601f16801561591b5780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b505050900390565b604080516001600160a01b038416602482015260448082018490528251808303909101815260649091019091526020810180516001600160e01b031663a9059cbb60e01b1790526115479084906157e9565b60006001600160a01b03821673b7d311e2eb55f2f68a9440da38e7989210b9a05e14156159c5575073b7d311e2eb55f2f68a9440da38e7989210b9a05e61121a565b5090565b6000612f1e83836040518060400160405280601a81526020017f536166654d6174683a206469766973696f6e206279207a65726f000000000000815250615c34565b600082615a1a5750600061141e565b82820282848281615a2757fe5b0414612f1e5760405162461bcd60e51b8152600401808060200182810382526021815260200180615e456021913960400191505060405180910390fd5b6040516001600160a01b0383169082156108fc029083906000818181858888f19350505050611124578082604051615a9b90615e06565b6001600160a01b039091168152604051908190036020019082f0905080158015611458573d6000803e3d6000fd5b6060602082511115615b9f57818060200190516020811015615aea57600080fd5b8101908080516040519392919084600160201b821115615b0957600080fd5b908301906020820185811115615b1e57600080fd5b8251600160201b811182820188101715615b3757600080fd5b82525081516020918201929091019080838360005b83811015615b64578181015183820152602001615b4c565b50505050905090810190601f168015615b915780820380516001836020036101000a031916815260200191505b50604052505050905061121a565b815160201415615c10576000828060200190516020811015615bc057600080fd5b50516040805160208082528183019092529192506060919060208201818036833701905050905060008260208301525b8215615c055760089290921b91600101615bf0565b8152915061121a9050565b5060408051602081019091526000815261121a565b60606148408484600085615c99565b60008183615c835760405162461bcd60e51b81526020600482018181528351602484015283519092839260449091019190850190808383600083156158ee5781810151838201526020016158d6565b506000838581615c8f57fe5b0495945050505050565b6060615ca48561480c565b615cf5576040805162461bcd60e51b815260206004820152601d60248201527f416464726573733a2063616c6c20746f206e6f6e2d636f6e7472616374000000604482015290519081900360640190fd5b60006060866001600160a01b031685876040518082805190602001908083835b60208310615d345780518252601f199092019160209182019101615d15565b6001836020036101000a03801982511681845116808217855250505050505090500191505060006040518083038185875af1925050503d8060008114615d96576040519150601f19603f3d011682016040523d82523d6000602084013e615d9b565b606091505b50915091508115615daf5791506148409050565b805115615dbf5780518082602001fd5b60405162461bcd60e51b81526020600482018181528651602484015286518793919283926044019190850190808383600083156158ee5781810151838201526020016158d6565b603280615e138339019056fe60806040526040516032380380603283398181016040526020811015602357600080fd5b50516001600160a01b038116fffe536166654d6174683a206d756c7469706c69636174696f6e206f766572666c6f775361666545524332303a204552433230206f7065726174696f6e20646964206e6f742073756363656564a2646970667358221220e8d5914e4628a90bfd037e0dd681437876568a42b6dca2716ef23cd9fd49e72a64736f6c634300070500330000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000a22206f6e20784461692200000000000000000000000000000000000000000000", "nonce": "0x20", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xe3df8ca2e9e239b39b06422db56a2f82eb8ed0dc98793f9ef251bd5d36e377f7", "blockNumber": "0x81", "transactionIndex": "0x0"}], "totalDifficulty": "0x80ffffffffffffffffffffffffdfca7dfc", "transactionsRoot": "0x609b7bb86ed5e80c88e20325f35c7806c82fed13a485fda22b421919d19cc083"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x50d51f", "blockHash": "0xe3df8ca2e9e239b39b06422db56a2f82eb8ed0dc98793f9ef251bd5d36e377f7", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x81", "contractAddress": "0xd1fa6c06e1d838bb989640a2c4b8a499fd0ab187", "transactionHash": "0xba71e19626fab310d835b17fe5f78ceb574f03915df77edf7fe79438b879e21b", "transactionIndex": "0x0", "cumulativeGasUsed": "0x50d51f"}]}
\\x7c9392add0998a5858df4a5525c4a5416390c6146fa4dc8d1545208cc14e31a1	128	\\xa0d3c4d23a54bdcca3b180f01d3d2458de77c3985d920f6eea2fff1572afdb1a	{"block": {"hash": "0x7c9392add0998a5858df4a5525c4a5416390c6146fa4dc8d1545208cc14e31a1", "size": "0x14c3", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x80", "uncles": [], "gasUsed": "0xf8aad", "mixHash": null, "gasLimit": "0x67bbc0", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x5617cb709c7a530c5ac347556d5c8cff72ccd99a0aa70a1edbb448763d944857", "timestamp": "0x60a68486", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xa0d3c4d23a54bdcca3b180f01d3d2458de77c3985d920f6eea2fff1572afdb1a", "sealFields": ["0x8420378182", "0xb8410e211f9ee4d62a8b6031f416d49fb5c3e8acbf420750c5fb2f9adac28ccfce0c4bd1b8bd4d35656918d123b507a08ccfc2a8f569e553997e49a4a2212128de5701"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x4ff19dc46437902c866b5de890329d700e297327f182984c5f56be17d2e4eb58", "transactions": [{"to": null, "gas": "0x1f155a", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x0b287ccf1b3f2d332041530b637718414c2a7558051c899d2d29b8f814a16536", "input": "0x60a060405234801561001057600080fd5b506040516111bc3803806111bc8339818101604052606081101561003357600080fd5b508051602080830151604093840151600080546001600160a01b0319166001600160a01b0380851691909117909155855163e5789d0360e01b815295519495929491939086169263e5789d039260048083019392829003018186803b15801561009b57600080fd5b505afa1580156100af573d6000803e3d6000fd5b505050506040513d60208110156100c557600080fd5b50518111156100d357600080fd5b606083901b6001600160601b031916608052600155506001600160a01b03166110956101276000398061045e52806108425280610a3c5280610b145280610deb5280610e275280610f5752506110956000f3fe608060405234801561001057600080fd5b50600436106100cf5760003560e01c8063e3e994171161008c578063f2fde38b11610066578063f2fde38b14610325578063f34220281461034b578063f3b8379114610372578063fb4720191461038f576100cf565b8063e3e9941714610263578063e78cea92146102e1578063ec84fd5e146102e9576100cf565b806334bc2d09146100d457806337dab817146101445780638da5cb5b146101c257806396a8254e146101e6578063be3b625b1461022e578063d313107314610236575b600080fd5b610142600480360360208110156100ea57600080fd5b810190602081018135600160201b81111561010457600080fd5b82018360208201111561011657600080fd5b803590602001918460208302840111600160201b8311171561013757600080fd5b509092509050610433565b005b6101426004803603604081101561015a57600080fd5b6001600160a01b038235169190810190604081016020820135600160201b81111561018457600080fd5b82018360208201111561019657600080fd5b803590602001918460208302840111600160201b831117156101b757600080fd5b509092509050610817565b6101ca6109d9565b604080516001600160a01b039092168252519081900360200190f35b61021c600480360360408110156101fc57600080fd5b5080356001600160e01b03191690602001356001600160a01b03166109e8565b60408051918252519081900360200190f35b61021c610a1c565b6101426004803603604081101561024c57600080fd5b506001600160e01b03198135169060200135610a22565b6101426004803603604081101561027957600080fd5b6001600160a01b038235169190810190604081016020820135600160201b8111156102a357600080fd5b8201836020820111156102b557600080fd5b803590602001918460208302840111600160201b831117156102d657600080fd5b509092509050610ae9565b6101ca610de9565b610142600480360360608110156102ff57600080fd5b506001600160e01b0319813516906001600160a01b036020820135169060400135610e0d565b6101426004803603602081101561033b57600080fd5b50356001600160a01b0316610ee8565b61021c6004803603602081101561036157600080fd5b50356001600160e01b031916610f21565b6101426004803603602081101561038857600080fd5b5035610f3d565b61021c600480360360208110156103a557600080fd5b810190602081018135600160201b8111156103bf57600080fd5b8201836020820111156103d157600080fd5b803590602001918460018302840111600160201b831117156103f257600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550610fec945050505050565b6000546001600160a01b0316331461044a57600080fd5b6007828280831461045a57600080fd5b60007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b1580156104b557600080fd5b505afa1580156104c9573d6000803e3d6000fd5b505050506040513d60208110156104df57600080fd5b5051905060005b8481101561051557818484838181106104fb57fe5b90506020020135111561050d57600080fd5b6001016104e6565b508585600081811061052357fe5b905060200201358686600181811061053757fe5b90506020020135101561054957600080fd5b8585600281811061055657fe5b905060200201358686600381811061056a57fe5b90506020020135101561057c57600080fd5b8585600481811061058957fe5b905060200201358686600581811061059d57fe5b9050602002013510156105af57600080fd5b858560028181106105bc57fe5b90506020020135868660008181106105d057fe5b9050602002013510156105e257600080fd5b858560038181106105ef57fe5b905060200201358686600181811061060357fe5b90506020020135101561061557600080fd5b8585600081811061062257fe5b632ae87cdd60e01b600052600260209081520291909101357f62a9500d3c776e557907e8c4e9d229aaa1558a8f5506186f14b6b6033c73dc9155508585600181811061066a57fe5b63d522cfd760e01b6000526002602081815290910292909201357f0fe9c952e0abfeacd2a15c8b2e9c86d4ce396bb3b22aa6a92bb05dcb330a72fc5550869086908181106106b457fe5b63125e4cfb60e01b600052600260209081520291909101357f9b596a45ce3292dcc0ae4d526137f44a04d3591c7e20f340f6cb69893f71938d5550858560038181106106fc57fe5b63c534576160e01b600052600260209081520291909101357fdecaf0d4210f056c5b5d45994395b1bb92499eaabced50a3f14e30dcb91eb6dc55508585600481811061074457fe5b63272255bb60e01b600052600260209081520291909101357f68f7a009dfc6477288240a635717ee1756983e0e7b020ce91b8ea7ca26abfd1e55508585600581811061078c57fe5b63867f7a4d60e01b600052600260209081520291909101357ffb5f3b053b454d2891c72f995506a0635691ad8230af03a191d1a48e30b02e7d5550858560068181106107d457fe5b630950d51560e01b600052600260209081520291909101357f2fbb309585be3644e71d446e7606807d2350a396c50abf9fd40aa383758edea55550505050505050565b6000546001600160a01b0316331461082e57600080fd5b6002828280831461083e57600080fd5b60007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b15801561089957600080fd5b505afa1580156108ad573d6000803e3d6000fd5b505050506040513d60208110156108c357600080fd5b5051905060005b848110156108f957818484838181106108df57fe5b9050602002013511156108f157600080fd5b6001016108ca565b508585600081811061090757fe5b905060200201358686600181811061091b57fe5b90506020020135101561092d57600080fd5b8585600081811061093a57fe5b6001600160a01b038a1660009081527e9b08b2dd6ebca17ba38eec3968d43de116b034e4c6180c63321ca2a69a13ac6020908152604090912091029290920135909155508585600181811061098b57fe5b6001600160a01b0390991660009081527fdc3367de4ae318686fa43fedfab309e4583980e6e10c84c9fe6b1d85489c1585602090815260409091209902919091013590975550505050505050565b6000546001600160a01b031681565b6001600160e01b0319821660009081526003602090815260408083206001600160a01b038516845290915290205492915050565b60015490565b6000546001600160a01b03163314610a3957600080fd5b807f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b158015610a9357600080fd5b505afa158015610aa7573d6000803e3d6000fd5b505050506040513d6020811015610abd57600080fd5b5051811115610acb57600080fd5b506001600160e01b0319909116600090815260026020526040902055565b6000546001600160a01b03163314610b0057600080fd5b60048282808314610b1057600080fd5b60007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b158015610b6b57600080fd5b505afa158015610b7f573d6000803e3d6000fd5b505050506040513d6020811015610b9557600080fd5b5051905060005b84811015610bcb5781848483818110610bb157fe5b905060200201351115610bc357600080fd5b600101610b9c565b5085856000818110610bd957fe5b9050602002013586866001818110610bed57fe5b905060200201351015610bff57600080fd5b85856002818110610c0c57fe5b9050602002013586866003818110610c2057fe5b905060200201351015610c3257600080fd5b85856002818110610c3f57fe5b9050602002013586866000818110610c5357fe5b905060200201351015610c6557600080fd5b85856003818110610c7257fe5b9050602002013586866001818110610c8657fe5b905060200201351015610c9857600080fd5b85856000818110610ca557fe5b6001600160a01b038a1660009081527ff82d3bc3eb326524ec784f499048e99f7d728f97e7a2f692a8a1bb3c85cafd4560209081526040909120910292909201359091555085856001818110610cf757fe5b6001600160a01b038a1660009081527f7b7fe953d4abfebb3e47c7c30a925fd8b1071924bc736814c55193623d57cedd60209081526040909120910292909201359091555085856002818110610d4957fe5b6001600160a01b038a1660009081527f2175433c11e201b5af00c87b33933460257bfa1f2d0bd31e7b9110a2c40526c360209081526040909120910292909201359091555085856003818110610d9b57fe5b6001600160a01b0390991660009081527f42dbfff0ae36ef1d4a902ec7e6d03352c7913fbcf13711cb82731a9e7ca8ffd6602090815260409091209902919091013590975550505050505050565b7f000000000000000000000000000000000000000000000000000000000000000081565b6000546001600160a01b03163314610e2457600080fd5b807f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b158015610e7e57600080fd5b505afa158015610e92573d6000803e3d6000fd5b505050506040513d6020811015610ea857600080fd5b5051811115610eb657600080fd5b506001600160e01b031990921660009081526003602090815260408083206001600160a01b0390941683529290522055565b6000546001600160a01b03163314610eff57600080fd5b600080546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160e01b03191660009081526002602052604090205490565b6000546001600160a01b03163314610f5457600080fd5b807f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663e5789d036040518163ffffffff1660e01b815260040160206040518083038186803b158015610fae57600080fd5b505afa158015610fc2573d6000803e3d6000fd5b505050506040513d6020811015610fd857600080fd5b5051811115610fe657600080fd5b50600155565b6004810151602482015160e09190911b6001600160e01b0319811660009081526003602090815260408083206001600160a01b03861684529091528120549092908061105757506001600160e01b031982166000908152600260205260409020548061105757506001545b94935050505056fea2646970667358221220225302f1b9da4fc15002ae25aa7b041185f40ed01eceb1cd20728e99374e3c7c64736f6c6343000705003300000000000000000000000073be21733cc5d08e1a14ea9a399fb27db3bef8ff000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de100000000000000000000000000000000000000000000000000000000002dc6c0", "nonce": "0x1f", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x7c9392add0998a5858df4a5525c4a5416390c6146fa4dc8d1545208cc14e31a1", "blockNumber": "0x80", "transactionIndex": "0x0"}], "totalDifficulty": "0x7fffffffffffffffffffffffffdfca7dfe", "transactionsRoot": "0xd7169ef4235cada832bd95de02685daebf17b4272875883fad2932fe88fe5200"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0xf8aad", "blockHash": "0x7c9392add0998a5858df4a5525c4a5416390c6146fa4dc8d1545208cc14e31a1", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x80", "contractAddress": "0xc2f87e37019e227f2be5030aabbcc7eaf136e05c", "transactionHash": "0x0b287ccf1b3f2d332041530b637718414c2a7558051c899d2d29b8f814a16536", "transactionIndex": "0x0", "cumulativeGasUsed": "0xf8aad"}]}
\\xa0d3c4d23a54bdcca3b180f01d3d2458de77c3985d920f6eea2fff1572afdb1a	127	\\xc7f17980943eb704b25c5eb5ff0071d028e90b34e31d5230c56e6422f17ab0bb	{"block": {"hash": "0xa0d3c4d23a54bdcca3b180f01d3d2458de77c3985d920f6eea2fff1572afdb1a", "size": "0x94b", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7f", "uncles": [], "gasUsed": "0x652e2", "mixHash": null, "gasLimit": "0x67a1d9", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x8902790fa9ca62eec8b0cb2f8b8be9d9f7c005326a8902722650a0cc3a6e9166", "timestamp": "0x60a68483", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xc7f17980943eb704b25c5eb5ff0071d028e90b34e31d5230c56e6422f17ab0bb", "sealFields": ["0x8420378181", "0xb841b18386e453f98da61bceba30daff1176441f2db171d8fc881f6e005f1c0724373f2a0a5e06840cd09c00a8626c5ba6bdd4dcad46214af063668c09c6caa99cdd00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x6fad0bac4e73bf872e30f2a053200fc97b284793bb240293cf41f211f8654a27", "transactions": [{"to": null, "gas": "0xca5c4", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0xc3d6cdcab1ccd56b86225aadc9ae3d45ba24e08100bea65be8ca3310d28bf1f5", "input": "0x608060405234801561001057600080fd5b506040516106863803806106868339818101604052602081101561003357600080fd5b5051600080546001600160a01b039092166001600160a01b0319909216919091179055610621806100656000396000f3fe608060405234801561001057600080fd5b50600436106100935760003560e01c80638da5cb5b116100665780638da5cb5b1461016e5780638efeb22d14610192578063c98cb30e146101ca578063f2fde38b14610202578063f7baa0491461022857610093565b806324d05aa2146100985780634721ff79146100c85780637060ed89146100f65780638782361914610140575b600080fd5b6100c6600480360360408110156100ae57600080fd5b506001600160a01b0381351690602001351515610260565b005b6100c6600480360360408110156100de57600080fd5b506001600160a01b038135169060200135151561029c565b61012e6004803603606081101561010c57600080fd5b506001600160a01b0381358116916020810135821691604090910135166102cb565b60408051918252519081900360200190f35b6100c66004803603604081101561015657600080fd5b506001600160a01b03813516906020013515156102ee565b610176610324565b604080516001600160a01b039092168252519081900360200190f35b6100c6600480360360608110156101a857600080fd5b506001600160a01b038135811691602081013590911690604001351515610333565b6100c6600480360360608110156101e057600080fd5b506001600160a01b038135811691602081013590911690604001351515610384565b6100c66004803603602081101561021857600080fd5b50356001600160a01b03166103c9565b61012e6004803603606081101561023e57600080fd5b506001600160a01b038135811691602081013582169160409091013516610402565b6001600160a01b03828116141561027657600080fd5b610298826001600160a01b03808461028f576000610293565b6000195b610550565b5050565b6001600160a01b0382811614156102b257600080fd5b6102986001600160a01b0380848461028f576000610293565b600160209081526000938452604080852082529284528284209052825290205481565b6001600160a01b03828116141561030457600080fd5b6102986001600160a01b03836001600160a01b038461028f576000610293565b6000546001600160a01b031681565b6001600160a01b03838116141561034957600080fd5b6001600160a01b03828116141561035f57600080fd5b61037f83836001600160a01b0384610378576000610293565b6001610550565b505050565b6001600160a01b03838116141561039a57600080fd5b6001600160a01b0382811614156103b057600080fd5b61037f836001600160a01b038484610378576000610293565b6000546001600160a01b031633146103e057600080fd5b600080546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160a01b03808416600090815260016020908152604080832093835292815282822090529081205481808212156104ba57506001600160a01b03808616600090815260016020908152604080832088851684528252808320938352929052205480156104745791506105499050565b506001600160a01b03808616600090815260016020908152604080832084845282528083209387168352929052205480156104b25791506105499050565b509050610549565b506001600160a01b0384811660009081527f73df27e0fa8bbb6c6a588f907379871e0f69a2bae64ea632056f6dabc259f362602090815260408083209383529290522054801561050d5791506105499050565b5050506001600160a01b03811660009081527f4233c29e78663f7ecc2ce2bfaada6ca8a0d1dac6601afb2e1235b6fe26bb589e60205260409020545b9392505050565b6000546001600160a01b0316331461056757600080fd5b6001600160a01b03808516600081815260016020908152604080832088861680855290835281842095881680855295835292819020869055805193845290830191909152818101929092526060810183905290517fa999f8c73447a5021a8e358783df77bbe2c90529cadb1fb1ef8f30cd9f9d8c939181900360800190a15050505056fea26469706673582212203e55a70a1bf01a6dc73829b9fbef5f6c563f2c5930f193f9ca7023f875028eea64736f6c63430007050033000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1", "nonce": "0x1e", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xa0d3c4d23a54bdcca3b180f01d3d2458de77c3985d920f6eea2fff1572afdb1a", "blockNumber": "0x7f", "transactionIndex": "0x0"}], "totalDifficulty": "0x7effffffffffffffffffffffffdfca7e00", "transactionsRoot": "0x0c629a3f5a358d8f7857c70a6239e60d0e63bd26c7bade3b7beeb6367223d55b"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x652e2", "blockHash": "0xa0d3c4d23a54bdcca3b180f01d3d2458de77c3985d920f6eea2fff1572afdb1a", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x7f", "contractAddress": "0x4a4c4759eb3b7abee079f832850cd3d0dc48d927", "transactionHash": "0xc3d6cdcab1ccd56b86225aadc9ae3d45ba24e08100bea65be8ca3310d28bf1f5", "transactionIndex": "0x0", "cumulativeGasUsed": "0x652e2"}]}
\\xc7f17980943eb704b25c5eb5ff0071d028e90b34e31d5230c56e6422f17ab0bb	126	\\x43ac9a784fad28a03f8b154d9a961a0e9dfd2f87ee54a0ef5134688e1e82775f	{"block": {"hash": "0xc7f17980943eb704b25c5eb5ff0071d028e90b34e31d5230c56e6422f17ab0bb", "size": "0x1691", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7e", "uncles": [], "gasUsed": "0xfcaa2", "mixHash": null, "gasLimit": "0x6787f9", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000001000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000010000000000000000000000000000000000000400000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000001000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x5b0e69ef4bad1334a4c3306c025d80e33857d03f5b5c856810b5ee47df91d6ae", "timestamp": "0x60a68480", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x43ac9a784fad28a03f8b154d9a961a0e9dfd2f87ee54a0ef5134688e1e82775f", "sealFields": ["0x8420378180", "0xb841477da7ab835cddcdce5accf3e53d307bd417569a820a6526766a6a188b20080c38b1ac33021b809b2bd55e0f5196712f44587d2ff9289ab4a83f2d3a273fa03b01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x7c55d5764cfa303fd61d37680bac649240a08b374ebd457670f3834b2c8d70df", "transactions": [{"to": null, "gas": "0x1f9544", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x11d444048eade58215c243a4dae5d1d6f4381bfab7d58c9e622d15bd66e4dd78", "input": "0x60806040523480156200001157600080fd5b506040516200130b3803806200130b833981810160405260a08110156200003757600080fd5b815160208301516040808501805191519395929483019291846401000000008211156200006357600080fd5b9083019060208201858111156200007957600080fd5b82518660208202830111640100000000821117156200009757600080fd5b82525081516020918201928201910280838360005b83811015620000c6578181015183820152602001620000ac565b505050509190910160405250600080546001600160a01b0319166001600160a01b0387161790556020908101925085915084906200010f90839062000273811b620008e017901c565b6200011957600080fd5b50600180546001600160a01b0319166001600160a01b03929092169190911790558151603210156200014a57600080fd5b6200017f7f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26600083815b6020020151620002b0565b620001af7f03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f12625600083600162000174565b60005b82518110156200025257620001e1838281518110620001cd57fe5b60200260200101516200032e60201b60201c565b620001eb57600080fd5b60005b8181101562000248578382815181106200020457fe5b60200260200101516001600160a01b03168482815181106200022257fe5b60200260200101516001600160a01b031614156200023f57600080fd5b600101620001ee565b50600101620001b2565b508151620002689060039060208501906200035d565b5050505050620003de565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470818114801590620002a857508115155b949350505050565b80670de0b6b3a76400008110620002c657600080fd5b60008481526002602090815260408083206001600160a01b03871680855290835292819020600186019055805187815291820185905280517fb8ff7722579ab646299f4f7d3ec42f3aaa482cce1e47d6041e8ca971600455309281900390910190a250505050565b60006001600160a01b038216158015906200035757506001546001600160a01b03838116911614155b92915050565b828054828255906000526020600020908101928215620003b5579160200282015b82811115620003b557825182546001600160a01b0319166001600160a01b039091161782556020909201916001909101906200037e565b50620003c3929150620003c7565b5090565b5b80821115620003c35760008155600101620003c8565b610f1d80620003ee6000396000f3fe608060405234801561001057600080fd5b50600436106100ea5760003560e01c806371e9a8b21161008c578063e9d6c05911610066578063e9d6c05914610273578063f2fde38b146102cb578063f3ce14c2146102f1578063fab19091146102f9576100ea565b806371e9a8b21461023d5780638da5cb5b14610245578063b4be506e1461024d576100ea565b80634e281a7b116100c85780634e281a7b1461018357806368400963146101a95780636d0501f6146101e7578063710c60131461020b576100ea565b8063071664c5146100ef57806310b8075b146101295780634b1a758214610151575b600080fd5b6101156004803603602081101561010557600080fd5b50356001600160a01b0316610301565b604080519115158252519081900360200190f35b61014f6004803603602081101561013f57600080fd5b50356001600160a01b031661035e565b005b61014f6004803603606081101561016757600080fd5b508035906001600160a01b036020820135169060400135610488565b61014f6004803603602081101561019957600080fd5b50356001600160a01b0316610507565b6101d5600480360360408110156101bf57600080fd5b50803590602001356001600160a01b031661063f565b60408051918252519081900360200190f35b6101ef6106f5565b604080516001600160a01b039092168252519081900360200190f35b6101d56004803603606081101561022157600080fd5b508035906001600160a01b036020820135169060400135610704565b6101d561074b565b6101ef610751565b61014f6004803603602081101561026357600080fd5b50356001600160a01b0316610760565b61027b6107fd565b60408051602080825283518183015283519192839290830191858101910280838360005b838110156102b757818101518382015260200161029f565b505050509050019250505060405180910390f35b61014f600480360360208110156102e157600080fd5b50356001600160a01b031661085f565b6101d5610898565b6101d56108bc565b6000805b60035481101561035357826001600160a01b03166003828154811061032657fe5b6000918252602090912001546001600160a01b0316141561034b576001915050610359565b600101610305565b50600090505b919050565b6000546001600160a01b0316331461037557600080fd5b60035460005b8181101561047f57826001600160a01b03166003828154811061039a57fe5b6000918252602090912001546001600160a01b0316141561047757600360018303815481106103c557fe5b600091825260209091200154600380546001600160a01b0390921691839081106103eb57fe5b9060005260206000200160006101000a8154816001600160a01b0302191690836001600160a01b031602179055506003600183038154811061042957fe5b600091825260209091200180546001600160a01b0319169055600380548061044d57fe5b600082815260209020810160001990810180546001600160a01b0319169055019055506104859050565b60010161037b565b50600080fd5b50565b827f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee268114806104d657507f03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f1262581145b6104df57600080fd5b6000546001600160a01b031633146104f657600080fd5b61050184848461091c565b50505050565b6001546001600160a01b0316331461051e57600080fd5b600354604080516370a0823160e01b815230600482015290516000916001600160a01b038516916370a0823191602480820192602092909190829003018186803b15801561056b57600080fd5b505afa15801561057f573d6000803e3d6000fd5b505050506040513d602081101561059557600080fd5b5051905060006105a58284610999565b90506000806105be6105b784876109e4565b8590610a3d565b905080156105d2576105cf85610a7f565b91505b60005b85811015610636578382158015906105ec57508184145b156105fe576105fb8184610a9c565b90505b61062d6003838154811061060e57fe5b6000918252602090912001546001600160a01b038a8116911683610af6565b506001016105d5565b50505050505050565b6000827f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee2681148061068f57507f03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f1262581145b61069857600080fd5b60008481526002602090815260408083206001600160a01b038716845290915290205480156106cc576000190191506106ee565b5060008481526002602090815260408083208380529091529020546000190191505b5092915050565b6001546001600160a01b031681565b60035460009061071657506000610744565b6000610722858561063f565b9050610740670de0b6b3a764000061073a85846109e4565b90610999565b9150505b9392505050565b60035490565b6000546001600160a01b031681565b6000546001600160a01b0316331461077757600080fd5b61078081610b4d565b61078957600080fd5b61079281610301565b1561079c57600080fd5b6003546032116107ab57600080fd5b600380546001810182556000919091527fc2575a0e9e593c00f959f8c92f12db2869c3395a3b0502d05e2516446f71f85b0180546001600160a01b0319166001600160a01b0392909216919091179055565b6060600380548060200260200160405190810160405280929190818152602001828054801561085557602002820191906000526020600020905b81546001600160a01b03168152600190910190602001808311610837575b5050505050905090565b6000546001600160a01b0316331461087657600080fd5b600080546001600160a01b0319166001600160a01b0392909216919091179055565b7f03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f1262581565b7f741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee2681565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061091457508115155b949350505050565b80670de0b6b3a7640000811061093157600080fd5b60008481526002602090815260408083206001600160a01b03871680855290835292819020600186019055805187815291820185905280517fb8ff7722579ab646299f4f7d3ec42f3aaa482cce1e47d6041e8ca971600455309281900390910190a250505050565b60006109db83836040518060400160405280601a81526020017f536166654d6174683a206469766973696f6e206279207a65726f000000000000815250610b78565b90505b92915050565b6000826109f3575060006109de565b82820282848281610a0057fe5b04146109db5760405162461bcd60e51b8152600401808060200182810382526021815260200180610e9d6021913960400191505060405180910390fd5b60006109db83836040518060400160405280601e81526020017f536166654d6174683a207375627472616374696f6e206f766572666c6f770000815250610c1a565b600081610a8d436001610a3d565b4081610a9557fe5b0692915050565b6000828201838110156109db576040805162461bcd60e51b815260206004820152601b60248201527f536166654d6174683a206164646974696f6e206f766572666c6f770000000000604482015290519081900360640190fd5b604080516001600160a01b038416602482015260448082018490528251808303909101815260649091019091526020810180516001600160e01b031663a9059cbb60e01b179052610b48908490610c74565b505050565b60006001600160a01b038216158015906109de5750506001546001600160a01b039081169116141590565b60008183610c045760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b83811015610bc9578181015183820152602001610bb1565b50505050905090810190601f168015610bf65780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b506000838581610c1057fe5b0495945050505050565b60008184841115610c6c5760405162461bcd60e51b8152602060048201818152835160248401528351909283926044909101919085019080838360008315610bc9578181015183820152602001610bb1565b505050900390565b6060610cc9826040518060400160405280602081526020017f5361666545524332303a206c6f772d6c6576656c2063616c6c206661696c6564815250856001600160a01b0316610d259092919063ffffffff16565b805190915015610b4857808060200190516020811015610ce857600080fd5b5051610b485760405162461bcd60e51b815260040180806020018281038252602a815260200180610ebe602a913960400191505060405180910390fd5b606061091484846000856060610d3a856108e0565b610d8b576040805162461bcd60e51b815260206004820152601d60248201527f416464726573733a2063616c6c20746f206e6f6e2d636f6e7472616374000000604482015290519081900360640190fd5b60006060866001600160a01b031685876040518082805190602001908083835b60208310610dca5780518252601f199092019160209182019101610dab565b6001836020036101000a03801982511681845116808217855250505050505090500191505060006040518083038185875af1925050503d8060008114610e2c576040519150601f19603f3d011682016040523d82523d6000602084013e610e31565b606091505b50915091508115610e455791506109149050565b805115610e555780518082602001fd5b60405162461bcd60e51b8152602060048201818152865160248401528651879391928392604401919085019080838360008315610bc9578181015183820152602001610bb156fe536166654d6174683a206d756c7469706c69636174696f6e206f766572666c6f775361666545524332303a204552433230206f7065726174696f6e20646964206e6f742073756363656564a2646970667358221220698293eb81753aac11593920aa19142509b026dc0457bcaf0df0dec5ade8658164736f6c63430007050033000000000000000000000000e983692122e45a00bba14454ebf4d00bf71aa245000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000004178babe9e5148c6d5fd431cd72884b07ad855a0", "nonce": "0x1d", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0xc7f17980943eb704b25c5eb5ff0071d028e90b34e31d5230c56e6422f17ab0bb", "blockNumber": "0x7e", "transactionIndex": "0x0"}], "totalDifficulty": "0x7dffffffffffffffffffffffffdfca7e02", "transactionsRoot": "0x3f69fdf31687f29eb5d44c0f2bf3cdd1d466d43960723ff5fdd3b870f5ccaa71"}, "transaction_receipts": [{"logs": [{"data": "0x741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee260000000000000000000000000000000000000000000000000000000000000000", "topics": ["0xb8ff7722579ab646299f4f7d3ec42f3aaa482cce1e47d6041e8ca97160045530", "0x0000000000000000000000000000000000000000000000000000000000000000"], "address": "0x1def1497df0e103d58fd14c4f8e0365fe5f94423", "logType": null, "removed": false, "logIndex": "0x0", "blockHash": "0xc7f17980943eb704b25c5eb5ff0071d028e90b34e31d5230c56e6422f17ab0bb", "blockNumber": "0x7e", "transactionHash": "0x11d444048eade58215c243a4dae5d1d6f4381bfab7d58c9e622d15bd66e4dd78", "transactionIndex": "0x0", "transactionLogIndex": "0x0"}, {"data": "0x03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f126250000000000000000000000000000000000000000000000000000000000000000", "topics": ["0xb8ff7722579ab646299f4f7d3ec42f3aaa482cce1e47d6041e8ca97160045530", "0x0000000000000000000000000000000000000000000000000000000000000000"], "address": "0x1def1497df0e103d58fd14c4f8e0365fe5f94423", "logType": null, "removed": false, "logIndex": "0x1", "blockHash": "0xc7f17980943eb704b25c5eb5ff0071d028e90b34e31d5230c56e6422f17ab0bb", "blockNumber": "0x7e", "transactionHash": "0x11d444048eade58215c243a4dae5d1d6f4381bfab7d58c9e622d15bd66e4dd78", "transactionIndex": "0x0", "transactionLogIndex": "0x1"}], "root": null, "status": "0x1", "gasUsed": "0xfcaa2", "blockHash": "0xc7f17980943eb704b25c5eb5ff0071d028e90b34e31d5230c56e6422f17ab0bb", "logsBloom": "0x00000000000000000000000001000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000010000000000000000000000000000000000000400000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000001000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x7e", "contractAddress": "0x1def1497df0e103d58fd14c4f8e0365fe5f94423", "transactionHash": "0x11d444048eade58215c243a4dae5d1d6f4381bfab7d58c9e622d15bd66e4dd78", "transactionIndex": "0x0", "cumulativeGasUsed": "0xfcaa2"}]}
\\x43ac9a784fad28a03f8b154d9a961a0e9dfd2f87ee54a0ef5134688e1e82775f	125	\\x89285670247a7026d03bc310ab6c0928b7d9852800da3143e36bd77939f5bc85	{"block": {"hash": "0x43ac9a784fad28a03f8b154d9a961a0e9dfd2f87ee54a0ef5134688e1e82775f", "size": "0xc77", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7d", "uncles": [], "gasUsed": "0x92390", "mixHash": null, "gasLimit": "0x676e1f", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x78d9e7b3015b2bfe8de45c83f18fb6a56db3cd61e2e2174d5c424475ad64142d", "timestamp": "0x60a6847d", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x89285670247a7026d03bc310ab6c0928b7d9852800da3143e36bd77939f5bc85", "sealFields": ["0x842037817f", "0xb8412299aac2d15aab7a7a1686a52e02a08d852a494f17fe15aaccaf3af851296808017f9ed4b97cf81887fd2659d4721aef4b7498275b3e97fe9f0fca29f0b5f4b000"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x58aa98cbed1cb60fe36462181bb5e6880a01ee587502d455c37b25766664a34a", "transactions": [{"to": null, "gas": "0x124720", "from": "0x4178babe9e5148c6d5fd431cd72884b07ad855a0", "hash": "0x81452b9b07eb53cef6e520a88ea5c10b474d8dbae50a3c2f804a1aa132259f6f", "input": "0x608060405234801561001057600080fd5b506040516109913803806109918339818101604052604081101561003357600080fd5b508051602090910151600080546001600160a01b039384166001600160a01b031991821617909155600180549390921692169190911790556109178061007a6000396000f3fe608060405234801561001057600080fd5b50600436106100575760003560e01c80631fa2195f1461005c5780638da5cb5b14610084578063a39d6acf146100a8578063c1aef4f214610173578063f2fde38b1461017b575b600080fd5b6100826004803603602081101561007257600080fd5b50356001600160a01b03166101a1565b005b61008c6101ec565b604080516001600160a01b039092168252519081900360200190f35b61008c600480360360808110156100be57600080fd5b8101906020810181356401000000008111156100d957600080fd5b8201836020820111156100eb57600080fd5b8035906020019184600183028401116401000000008311171561010d57600080fd5b91939092909160208101903564010000000081111561012b57600080fd5b82018360208201111561013d57600080fd5b8035906020019184600183028401116401000000008311171561015f57600080fd5b919350915060ff81351690602001356101fb565b61008c6102d3565b6100826004803603602081101561019157600080fd5b50356001600160a01b03166102e2565b6000546001600160a01b031633146101b857600080fd5b6101c18161031b565b6101ca57600080fd5b600180546001600160a01b0319166001600160a01b0392909216919091179055565b6000546001600160a01b031681565b6000600160009054906101000a90046001600160a01b03168787878787873360405161022690610357565b6001600160a01b03808a16825260ff8516606083015260808201849052821660a082015260c0602082018181529082018890526040820160e083018a8a80828437600083820152601f01601f1916909101848103835288815260200190508888808284376000838201819052604051601f909201601f19169093018190039d509b50909950505050505050505050f0801580156102c7573d6000803e3d6000fd5b50979650505050505050565b6001546001600160a01b031681565b6000546001600160a01b031633146102f957600080fd5b600080546001600160a01b0319166001600160a01b0392909216919091179055565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061034f57508115155b949350505050565b61057d806103658339019056fe608060405234801561001057600080fd5b5060405161057d38038061057d833981810160405260c081101561003357600080fd5b81516020830180516040519294929383019291908464010000000082111561005a57600080fd5b90830190602082018581111561006f57600080fd5b825164010000000081118282018810171561008957600080fd5b82525081516020918201929091019080838360005b838110156100b657818101518382015260200161009e565b50505050905090810190601f1680156100e35780820380516001836020036101000a031916815260200191505b506040526020018051604051939291908464010000000082111561010657600080fd5b90830190602082018581111561011b57600080fd5b825164010000000081118282018810171561013557600080fd5b82525081516020918201929091019080838360005b8381101561016257818101518382015260200161014a565b50505050905090810190601f16801561018f5780820380516001836020036101000a031916815260200191505b50604081815260208301518382015160609485015163054fd4d560e41b8552925191965094509092916001600160a01b038916916354fd4d5091600480820192600092909190829003018186803b1580156101e957600080fd5b505afa1580156101fd573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f19168201604052602081101561022657600080fd5b810190808051604051939291908464010000000082111561024657600080fd5b90830190602082018581111561025b57600080fd5b825164010000000081118282018810171561027557600080fd5b82525081516020918201929091019080838360005b838110156102a257818101518382015260200161028a565b50505050905090810190601f1680156102cf5780820380516001836020036101000a031916815260200191505b506040525050507f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc88905586519091506103109060009060208901906103e4565b5084516103249060019060208801906103e4565b506002805460ff90951660ff1990951694909417909355600680546001600160a01b039092166001600160a01b03199283168117909155600780549092161790558351602094850120825192850192909220604080517f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f8188015280820194909452606084019190915260808301919091523060a0808401919091528151808403909101815260c090920190528051920191909120600855506104859050565b828054600181600116156101000203166002900490600052602060002090601f01602090048101928261041a5760008555610460565b82601f1061043357805160ff1916838001178555610460565b82800160010185558215610460579182015b82811115610460578251825591602001919060010190610445565b5061046c929150610470565b5090565b5b8082111561046c5760008155600101610471565b60ea806104936000396000f3fe608060405260043610601c5760003560e01c80635c60da1b146061575b60006024608f565b90506001600160a01b038116603857600080fd5b60405136600082376000803683855af43d82016040523d6000833e808015605d573d83f35b3d83fd5b348015606c57600080fd5b506073608f565b604080516001600160a01b039092168252519081900360200190f35b7f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc549056fea2646970667358221220f64904f9f497222eca8798ca4c7cdddb76670c8ec8ec21c0c26eeb47d9e606d764736f6c63430007050033a26469706673582212204ffefcabadf3338cbf5dc4321cda6224988280eae1dc8b0d3f140c2c5ddaff0364736f6c63430007050033000000000000000000000000a3d1f77acff0060f7213d7bf3c7fec78df847de1000000000000000000000000f16f8cebea74106664032e6b2963b81743484306", "nonce": "0x1c", "value": "0x0", "gasPrice": "0x12a05f200", "blockHash": "0x43ac9a784fad28a03f8b154d9a961a0e9dfd2f87ee54a0ef5134688e1e82775f", "blockNumber": "0x7d", "transactionIndex": "0x0"}], "totalDifficulty": "0x7cffffffffffffffffffffffffdfca7e04", "transactionsRoot": "0x198e0556d125a125ca035bfa25601907f6b4a25924b6e4c5f4ef03563f79cdaf"}, "transaction_receipts": [{"logs": [], "root": null, "status": "0x1", "gasUsed": "0x92390", "blockHash": "0x43ac9a784fad28a03f8b154d9a961a0e9dfd2f87ee54a0ef5134688e1e82775f", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "blockNumber": "0x7d", "contractAddress": "0x36afc8c9283cc866b8eb6a61c6e6862a83cd6ee8", "transactionHash": "0x81452b9b07eb53cef6e520a88ea5c10b474d8dbae50a3c2f804a1aa132259f6f", "transactionIndex": "0x0", "cumulativeGasUsed": "0x92390"}]}
\\x4ad9382fb10592f66ba755f722ebc12dbe0e2fe2bb409769b16735930433c223	122	\\x0309343a732d2a063f0961df552f89eac66db7f04b7126d410c9156536b8b5b9	{"block": {"hash": "0x4ad9382fb10592f66ba755f722ebc12dbe0e2fe2bb409769b16735930433c223", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x7a", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6720b7", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xdb2861b55d3b73f081285417761abf9392ff069aacbe4c6ae1f72ee534bfb747", "timestamp": "0x60a68471", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x0309343a732d2a063f0961df552f89eac66db7f04b7126d410c9156536b8b5b9", "sealFields": ["0x8420378169", "0xb8411aefdcfd3a8350db20d60998b4ca2c3daedd17b2f9f462c75892d3ed442228396b02caf18e578f78418a43fabfe63dfa989cd877750e1ca76a435d44ee5ea6cb01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x79ffffffffffffffffffffffffdfca7e1d", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x0309343a732d2a063f0961df552f89eac66db7f04b7126d410c9156536b8b5b9	121	\\xfdd189d8b99dc1a3ff39bc77169ff40b1223ac9ff9cd8a8fd9631b57c620e469	{"block": {"hash": "0x0309343a732d2a063f0961df552f89eac66db7f04b7126d410c9156536b8b5b9", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x79", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6706f7", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xdb2861b55d3b73f081285417761abf9392ff069aacbe4c6ae1f72ee534bfb747", "timestamp": "0x60a68438", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0xfdd189d8b99dc1a3ff39bc77169ff40b1223ac9ff9cd8a8fd9631b57c620e469", "sealFields": ["0x8420378168", "0xb841854db9d650497dc55900e230cc8ae163d0404485f82b8162ae871840e7093c4b39d00c7905996542c75d6476f3606d5c70b91e7a9fc9375b908a36c945c4960100"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x78ffffffffffffffffffffffffdfca7e1f", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xfdd189d8b99dc1a3ff39bc77169ff40b1223ac9ff9cd8a8fd9631b57c620e469	120	\\xb6206698e82be0653411d44d628b45a6c005419053c7d66b6b313187aa5d67dc	{"block": {"hash": "0xfdd189d8b99dc1a3ff39bc77169ff40b1223ac9ff9cd8a8fd9631b57c620e469", "size": "0x249", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0x78", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x66ed3d", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0xdb2861b55d3b73f081285417761abf9392ff069aacbe4c6ae1f72ee534bfb747", "timestamp": "0x60a68432", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xb6206698e82be0653411d44d628b45a6c005419053c7d66b6b313187aa5d67dc", "sealFields": ["0x8420378166", "0xb8414e58a7e50ab945f6f4e1f5324c256abedb36ee213769ae15b2780082cd92607d5e5c8571cad250c2d49b86bc554d10fd40a75e9067914c9c5960df092f682fcb00"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0x77ffffffffffffffffffffffffdfca7e22", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xcf9aecf5b970372da7931e28e494a73d8d875d43f0343638dcd9e0ed75cd214c	171	\\x933079d0e43a0403fed8ce97a75b8972606c65a40813cb37ed69d79add20b14d	{"block": {"hash": "0xcf9aecf5b970372da7931e28e494a73d8d875d43f0343638dcd9e0ed75cd214c", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xab", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6c2dcc", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc3a", "difficulty": "0xfffffffffffffffffffffffffffffffd", "parentHash": "0x933079d0e43a0403fed8ce97a75b8972606c65a40813cb37ed69d79add20b14d", "sealFields": ["0x84203afebe", "0xb841f8667669bb5457c88bf48c49889876fbc59ecb806f1ebf77f914cbf5b985008427cf8d35d2d1550bd23791def413e5bd9fa5c1b039b9530f944b812eb479b45501"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xaaffffffffffffffffffffffffdfc70097", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x76f7204d12c18279658983c2d24eba4fa8c246ecaf261f463cf91d3c6e46ba8b	172	\\xcf9aecf5b970372da7931e28e494a73d8d875d43f0343638dcd9e0ed75cd214c	{"block": {"hash": "0x76f7204d12c18279658983c2d24eba4fa8c246ecaf261f463cf91d3c6e46ba8b", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xac", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6c48d6", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc4f", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xcf9aecf5b970372da7931e28e494a73d8d875d43f0343638dcd9e0ed75cd214c", "sealFields": ["0x84203afebf", "0xb841654225fb7db473179ad5b1757f1a38a38dc0091a8c8927e3e3971d958025973b46e50c9a2246c1da9e42fda3aaf0863211e2b83e37304400d255c6cf3215a62300"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xabffffffffffffffffffffffffdfc70095", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x9badf37c3ede49f6cc96bf3816f635a3d6c75641944e090309e920ae5f611097	173	\\x76f7204d12c18279658983c2d24eba4fa8c246ecaf261f463cf91d3c6e46ba8b	{"block": {"hash": "0x9badf37c3ede49f6cc96bf3816f635a3d6c75641944e090309e920ae5f611097", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xad", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6c63e7", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc55", "difficulty": "0xfffffffffffffffffffffffffffffff7", "parentHash": "0x76f7204d12c18279658983c2d24eba4fa8c246ecaf261f463cf91d3c6e46ba8b", "sealFields": ["0x84203afec7", "0xb841020dd214c3ace529d017c5d963ecaa8ac34cbe957715c38ae409a05944409ddb41a62bb461a6df60f7632fd7cf9ef8ba72c5469940f5162f349b49f25547230600"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xacffffffffffffffffffffffffdfc7008c", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\xc5aa89c3cc8083207328938ae0ad6a5754b651b469479ce5bc9f57d1577266ce	174	\\x9badf37c3ede49f6cc96bf3816f635a3d6c75641944e090309e920ae5f611097	{"block": {"hash": "0xc5aa89c3cc8083207328938ae0ad6a5754b651b469479ce5bc9f57d1577266ce", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xae", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6c7efe", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc58", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0x9badf37c3ede49f6cc96bf3816f635a3d6c75641944e090309e920ae5f611097", "sealFields": ["0x84203afec8", "0xb8415ec2918e7ba1f7c5aff43091eb273577f2fcef19a6c429cc960180813cc7cc4651b4efd8db784eea0cdce455409c5bd3f3168a630c2903216678d2b66a5d01e800"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xadffffffffffffffffffffffffdfc7008a", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\\x8a0558dbad53e775757271ceb3db1b7bd3018a06c40c56e259b999f1d57d8df0	175	\\xc5aa89c3cc8083207328938ae0ad6a5754b651b469479ce5bc9f57d1577266ce	{"block": {"hash": "0x8a0558dbad53e775757271ceb3db1b7bd3018a06c40c56e259b999f1d57d8df0", "size": "0x24a", "miner": "0x00bd138abd70e2f00903268f3db08f2d25677c9e", "nonce": null, "number": "0xaf", "uncles": [], "gasUsed": "0x0", "mixHash": null, "gasLimit": "0x6c9a1c", "extraData": "0xde830207028f5061726974792d457468657265756d86312e34312e30826c69", "logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", "stateRoot": "0x2a4249e3ae1d9294cb88f57f825c6a011e865c927b281f7e643e704a880d3d34", "timestamp": "0x60b0fc5b", "difficulty": "0xfffffffffffffffffffffffffffffffe", "parentHash": "0xc5aa89c3cc8083207328938ae0ad6a5754b651b469479ce5bc9f57d1577266ce", "sealFields": ["0x84203afec9", "0xb841351017bfb984d674620f648a788ae94b52f821f2223fb5a1a68c78c430dc0ae12c322d5ca7fd54c06447b5951d403b794057bdee4e994e7d10b5bd3603bde4bb01"], "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347", "receiptsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421", "transactions": [], "totalDifficulty": "0xaeffffffffffffffffffffffffdfc70088", "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}, "transaction_receipts": []}
\.


--
-- Data for Name: call_cache; Type: TABLE DATA; Schema: chain1; Owner: streamr
--

COPY chain1.call_cache (id, return_value, contract_address, block_number) FROM stdin;
\.


--
-- Data for Name: call_meta; Type: TABLE DATA; Schema: chain1; Owner: streamr
--

COPY chain1.call_meta (contract_address, accessed_at) FROM stdin;
\.


--
-- Data for Name: __diesel_schema_migrations; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.__diesel_schema_migrations (version, run_on) FROM stdin;
20180710061642	2021-05-20 15:02:13.23816
20180710061659	2021-05-20 15:02:13.255547
20180710062717	2021-05-20 15:02:13.277789
20180710062730	2021-05-20 15:02:13.281779
20180816143800	2021-05-20 15:02:13.284715
20180822130000	2021-05-20 15:02:13.28658
20180822140000	2021-05-20 15:02:13.296997
20180829120000	2021-05-20 15:02:13.29852
20180907220000	2021-05-20 15:02:13.304317
20180918180000	2021-05-20 15:02:13.305586
20181202114100	2021-05-20 15:02:13.307407
20181203150000	2021-05-20 15:02:13.317117
20181221003727	2021-05-20 15:02:13.318818
20190107120000	2021-05-20 15:02:13.329114
20190118195346	2021-05-20 15:02:13.332745
20190118195526	2021-05-20 15:02:13.33751
20190201045927	2021-05-20 15:02:13.339232
20190204114900	2021-05-20 15:02:13.342523
20190225182843	2021-05-20 15:02:13.344098
20190226182914	2021-05-20 15:02:13.349801
20190226183156	2021-05-20 15:02:13.350905
20190227035443	2021-05-20 15:02:13.354474
20190228190800	2021-05-20 15:02:13.363663
20190304235349	2021-05-20 15:02:13.366971
20190307171355	2021-05-20 15:02:13.368547
20190328004319	2021-05-20 15:02:13.371727
20190331010824	2021-05-20 15:02:13.374203
20190419171709	2021-05-20 15:02:13.375819
20190422190022	2021-05-20 15:02:13.390994
20190503164052	2021-05-20 15:02:13.392748
20190509135900	2021-05-20 15:02:13.395576
20190509232642	2021-05-20 15:02:13.402864
20190514200255	2021-05-20 15:02:13.408959
20190515215022	2021-05-20 15:02:13.412051
20190605214320	2021-05-20 15:02:13.415946
20190626164405	2021-05-20 15:02:13.417767
20190720195916	2021-05-20 15:02:13.421316
20190802001120	2021-05-20 15:02:13.438456
20190901135850	2021-05-20 15:02:13.440147
20190902230613	2021-05-20 15:02:13.448768
20191001173616	2021-05-20 15:02:13.486758
20200114235608	2021-05-20 15:02:13.498168
20200117013633	2021-05-20 15:02:13.510043
20200124065338	2021-05-20 15:02:13.512023
20200306020253	2021-05-20 15:02:13.513425
20200311162100	2021-05-20 15:02:13.785714
20200325170527	2021-05-20 15:02:13.787245
20200404002817	2021-05-20 15:02:13.788878
20200410111111	2021-05-20 15:02:13.799847
20200516225611	2021-05-20 15:02:13.820188
20200707002933	2021-05-20 15:02:13.827441
20200731162138	2021-05-20 15:02:13.829484
20201031150000	2021-05-20 15:02:13.847688
20201103170839	2021-05-20 15:02:13.849262
20201110100000	2021-05-20 15:02:13.854125
20201211142000	2021-05-20 15:02:13.856032
20201212000001	2021-05-20 15:02:13.85745
20201212000002	2021-05-20 15:02:13.858665
20201212000003	2021-05-20 15:02:13.86009
20201212000004	2021-05-20 15:02:13.861201
20201212000005	2021-05-20 15:02:13.865204
20201215000000	2021-05-20 15:02:13.866323
2020127190800	2021-05-20 15:02:13.867729
20210107004939	2021-05-20 15:02:13.86933
20210114175654	2021-05-20 15:02:13.875227
20210114193022	2021-05-20 15:02:13.878744
20210115013524	2021-05-20 15:02:13.879903
20210119033749	2021-05-20 15:02:13.880983
20210126044443	2021-05-20 15:02:13.891713
20210126172953	2021-05-20 15:02:13.892878
20210126173710	2021-05-20 15:02:13.89392
20210126204036	2021-05-20 15:02:13.903261
20210217205502	2021-05-20 15:02:13.904689
20210218000721	2021-05-20 15:02:13.917509
20210218171423	2021-05-20 15:02:13.921253
20210224051050	2021-05-20 15:02:13.925553
20210225233156	2021-05-20 15:02:13.926826
20210311010830	2021-05-20 15:02:13.928447
20210311231340	2021-05-20 15:02:13.92948
20210312014815	2021-05-20 15:02:13.931082
20210312070453	2021-05-20 15:02:13.935286
20210316001809	2021-05-20 15:02:13.954382
20210316165131	2021-05-20 15:02:13.960585
20210319161012	2021-05-20 15:02:13.966305
20210320001347	2021-05-20 15:02:13.97023
20210324220541	2021-05-20 15:02:13.974007
\.


--
-- Data for Name: active_copies; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.active_copies (src, dst, queued_at, cancelled_at) FROM stdin;
\.


--
-- Data for Name: bridge_types; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.bridge_types (name, url, confirmations, incoming_token_hash, salt, outgoing_token, minimum_contract_payment, created_at, updated_at) FROM stdin;
ensbridge	http://streamr-dev-chainlink-adapter:8080	0	d3f30aa9c89b77f20500846572f50501bfa354f37998d0ac96efe84a819c5543	08agtAHX5UwtweYgWCwv8L4N4YeImBf2	exS4BCL628+Faxju+cvLxELK7LLSERkA	0	2021-05-20 15:14:55.638205+00	2021-05-20 15:14:55.638205+00
\.


--
-- Data for Name: chains; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.chains (id, name, net_version, genesis_block_hash, shard, namespace) FROM stdin;
1	xDai	8997	374b16e431b242769d8cf5bedd9c2fde9d6872966b7792b41d759d8a1fa901da	primary	chain1
\.


--
-- Data for Name: configurations; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.configurations (id, name, value, created_at, updated_at, deleted_at) FROM stdin;
1	ETH_GAS_PRICE_DEFAULT	5000000000	2021-05-20 15:02:13.23751+00	2021-05-20 15:15:37.391216+00	\N
\.


--
-- Data for Name: cron_specs; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.cron_specs (id, cron_schedule, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: db_version; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.db_version (db_version) FROM stdin;
2
\.


--
-- Data for Name: deployment_schemas; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.deployment_schemas (id, subgraph, name, version, shard, network, active) FROM stdin;
1	Qmb1h8mpRTpwHfk3W6DTVmnwAiqrpMrvM4iPqYXLRp28ew	sgd1	relational	primary	xDai	t
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
\\x30e4e84909389580784ba39f1eb3b95c8b79816e9cb43072ff8394fc4fd4ed03	\\x72ff32f831e297a1ae6136c3ecda89fc57567ca7	\\xdf9001206a08617f974a1b47a26e9ba19c73f53d2877321333a7ea957e849ba0	{"kdf": "scrypt", "mac": "a3897dd7e3dbde91f6fd98dc9414a66a7a3c6ba4a2d6dccd9eb12f395c551395", "cipher": "aes-128-ctr", "kdfparams": {"n": 262144, "p": 1, "r": 8, "salt": "e92fbd0e5f1f6413cd44c2f98033a33a32681d5d802b3ec3c60b6307cec0f23a", "dklen": 32}, "ciphertext": "25c82918c09c5b78d31ae0ac8cf7f153c70dcc4deaed6b2ed17fcff7546e1c5e440aa351695a8f69f1a7326a702d6c3639decbf6a9eb0f9df4c0c05c5fd7e30632d1e67f69a680efa026b745db34d6a4c0fcc201ed23c705f09599790a4561e70f73cd3249b0f82d0ee2a51b979f023742f40d3f4d9f98aef3a73a15cfdbd0d0c138544cdbc4a515a5f9f45e293a787bd7a3c4fff3d8ca09110586e8dd4a8275fce7da4d0dc196b0753e444d0a3a93649f28ca7606cc192f40fe9dd459cb7c1e92eed4b6c6d3dda85321288ed09550b40c19d4150fc61fc5c7c7463580aae2460f010647cf9e1974011c7c974b06bab66aa5fbf7b9754b0c4c6b184c681a9a7a16e2e583902d6802640d80a870710e6f0466d555930fb8b2f32b48355e631980dbdedbb0062ef4988303a2b67d2285bc9bc07e5a74669a9cc66d6c4890b8adb2ea3dd06f3763cdba5aca", "cipherparams": {"iv": "0dac29b9bd6b194d0cbe8e9a734987f3"}}	2021-05-20 15:01:41.381572+00	2021-05-20 15:01:41.381572+00	\\x41d0e09194045f38b01cf13836c56933d7e81029151423fda9f287827e4fab06	\N
\.


--
-- Data for Name: encrypted_p2p_keys; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.encrypted_p2p_keys (id, peer_id, pub_key, encrypted_priv_key, created_at, updated_at, deleted_at) FROM stdin;
1	12D3KooWQGiE341F6R7n8E8KT4Tgghuo5KdJJnJq3EsYJq3Ah85z	\\xd6c36570957762136c37ab25a1e49fdb61845054e3edcda76e295b62437cc9ad	{"kdf": "scrypt", "mac": "d802b400854ea0b3b40ea54f9d1e21155dd36a5124a070b67b11da4d24720914", "cipher": "aes-128-ctr", "kdfparams": {"n": 262144, "p": 1, "r": 8, "salt": "a033ee9b9bc4600e9587eaadb5893bf27cb6ea1b0cf7d74d44cbf674979daf6f", "dklen": 32}, "ciphertext": "ccf392cd0b683c8b9b3d809460f775cb0ff666a31428a6138807a279171c2a18625cf98890fbbcd0a43d4a3f66e8a4501ed41aa2017ece08afa872ceb5c436a6e6e18097", "cipherparams": {"iv": "cc0266d372c2df261ec3f631222716ac"}}	2021-05-20 15:01:40.612802+00	2021-05-20 15:01:40.612802+00	\N
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
-- Data for Name: ens_names; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.ens_names (hash, name) FROM stdin;
\.


--
-- Data for Name: eth_call_cache; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.eth_call_cache (id, return_value, contract_address, block_number) FROM stdin;
\.


--
-- Data for Name: eth_call_meta; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.eth_call_meta (contract_address, accessed_at) FROM stdin;
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
-- Data for Name: ethereum_blocks; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.ethereum_blocks (hash, number, parent_hash, network_name, data) FROM stdin;
\.


--
-- Data for Name: ethereum_networks; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.ethereum_networks (name, head_block_hash, head_block_number, net_version, genesis_block_hash, namespace) FROM stdin;
xDai	8a0558dbad53e775757271ceb3db1b7bd3018a06c40c56e259b999f1d57d8df0	175	8997	374b16e431b242769d8cf5bedd9c2fde9d6872966b7792b41d759d8a1fa901da	chain1
\.


--
-- Data for Name: event_meta_data; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.event_meta_data (id, db_transaction_id, db_transaction_time, source) FROM stdin;
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
1	\\xf4f36daefc595c63ba0e0c0bfb4361900b07df09bc564271ae1e6ee83fbaa4f6	142	\\xfacba8827d937891d382a254270147631c8ca9d967fb642f7ab237946cc2c7c6	2021-05-20 15:02:32.246522+00	2021-05-20 15:02:32+00
2	\\xfacba8827d937891d382a254270147631c8ca9d967fb642f7ab237946cc2c7c6	141	\\xfeea29ff7745d0cbaf00b3fab5d82a9e9d172227378ca86b93c618fe286387e6	2021-05-20 15:02:32.269939+00	2021-05-20 15:02:13+00
3	\\xfeea29ff7745d0cbaf00b3fab5d82a9e9d172227378ca86b93c618fe286387e6	140	\\xeb65848dc76fc886e24845fb4b51b3f8398d0473f28bf4bc2826aaf9dadb533c	2021-05-20 15:02:32.279748+00	2021-05-20 15:01:36+00
4	\\xeb65848dc76fc886e24845fb4b51b3f8398d0473f28bf4bc2826aaf9dadb533c	139	\\x777db114ff2b553e1fff9d8ff777a07c42ba669b4ee97dffbd8f267483df223d	2021-05-20 15:02:32.284489+00	2021-05-20 14:36:42+00
5	\\x777db114ff2b553e1fff9d8ff777a07c42ba669b4ee97dffbd8f267483df223d	138	\\x32a82c945903a4c35e4c60a885ae20312f43d06a063a27cb91715d8137f11dc4	2021-05-20 15:02:32.288008+00	2021-05-20 14:36:39+00
6	\\x32a82c945903a4c35e4c60a885ae20312f43d06a063a27cb91715d8137f11dc4	137	\\xbb3c49607246c91e53339f3ad5eed36043d5545ae203c4128416a69c6de0fbcd	2021-05-20 15:02:32.291009+00	2021-05-20 14:36:36+00
7	\\xbb3c49607246c91e53339f3ad5eed36043d5545ae203c4128416a69c6de0fbcd	136	\\x1f624bc35df568b83a7d73e7ebf598f69a009f3971acc433e94a1e35c7aa6456	2021-05-20 15:02:32.293837+00	2021-05-20 14:36:33+00
8	\\x1f624bc35df568b83a7d73e7ebf598f69a009f3971acc433e94a1e35c7aa6456	135	\\x327b3777967d1efb74653cef9af597bde8812c0c1bb9e7811d7558224183d40f	2021-05-20 15:02:32.296462+00	2021-05-20 14:36:27+00
9	\\x327b3777967d1efb74653cef9af597bde8812c0c1bb9e7811d7558224183d40f	134	\\x25138b16307b03f37999b82f2e76f93de8a3a5f3d145c1d0495b35f84068276d	2021-05-20 15:02:32.298806+00	2021-05-20 14:36:24+00
10	\\x25138b16307b03f37999b82f2e76f93de8a3a5f3d145c1d0495b35f84068276d	133	\\x6e6905216c5f00e0a877deeb01852a3237630b8939ee28f65f4f6e2b70d825cb	2021-05-20 15:02:32.301065+00	2021-05-20 14:36:21+00
11	\\x6e6905216c5f00e0a877deeb01852a3237630b8939ee28f65f4f6e2b70d825cb	132	\\xa20abfdffc45f74d144095e9dd9a95d5341f0802a8135536a7e8d4fbbcaa2b75	2021-05-20 15:02:32.303688+00	2021-05-20 14:36:15+00
12	\\xa20abfdffc45f74d144095e9dd9a95d5341f0802a8135536a7e8d4fbbcaa2b75	131	\\x7abd152db0597fa30f0290c2b815a2e0cb211ce8d477db7d24423cd651ce0f3b	2021-05-20 15:02:32.305741+00	2021-05-20 14:36:09+00
13	\\x7abd152db0597fa30f0290c2b815a2e0cb211ce8d477db7d24423cd651ce0f3b	130	\\x40c944b68adaf1a16f738bb64d3c63d344a77d95fd949a108e8a46eac882c6fe	2021-05-20 15:02:32.307944+00	2021-05-20 14:36:06+00
14	\\x40c944b68adaf1a16f738bb64d3c63d344a77d95fd949a108e8a46eac882c6fe	129	\\x403362b45a168eb941d85cb44eb24635821d3428b219e16e34dfba25389c5259	2021-05-20 15:02:32.309985+00	2021-05-20 14:36:03+00
15	\\x403362b45a168eb941d85cb44eb24635821d3428b219e16e34dfba25389c5259	128	\\x366f8bf5fcb132e0a2eddd3bce40e9caba4afc7706ffbebfbf5e7747aecfa275	2021-05-20 15:02:32.312233+00	2021-05-20 14:36:00+00
16	\\x366f8bf5fcb132e0a2eddd3bce40e9caba4afc7706ffbebfbf5e7747aecfa275	127	\\xef795ee266ef20e3d72361bd8f7b44beb853a24620d733421bd0a0ec3752cd50	2021-05-20 15:02:32.314287+00	2021-05-20 14:35:54+00
17	\\xef795ee266ef20e3d72361bd8f7b44beb853a24620d733421bd0a0ec3752cd50	126	\\x5a1531e521463e3566764de80749569e1e12ec666287d7b20bbcaf9a795474fd	2021-05-20 15:02:32.317087+00	2021-05-20 14:35:51+00
18	\\x5a1531e521463e3566764de80749569e1e12ec666287d7b20bbcaf9a795474fd	125	\\xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db	2021-05-20 15:02:32.319433+00	2021-05-20 14:35:48+00
19	\\xbf6a658a24324e18df1a16f354db06ca3ba4dff5260f114cc8e9806804b924db	124	\\x66b2f16e9d22fa80da4f9bffc9bc6f74276b90d59e6cf7051300c8b2162f7653	2021-05-20 15:02:32.321433+00	2021-05-20 14:35:45+00
20	\\x66b2f16e9d22fa80da4f9bffc9bc6f74276b90d59e6cf7051300c8b2162f7653	123	\\xa9ffa8c89a60375c22d4f38a2c554c44bf07d99602ea35700f868a3fe92f21a5	2021-05-20 15:02:32.323478+00	2021-05-20 14:35:39+00
21	\\xa9ffa8c89a60375c22d4f38a2c554c44bf07d99602ea35700f868a3fe92f21a5	122	\\xb2ac715c3e227e9d337402dacda23d0c57441fb7e4a50f050a10ad6384075a7e	2021-05-20 15:02:32.325783+00	2021-05-20 14:35:36+00
22	\\xb2ac715c3e227e9d337402dacda23d0c57441fb7e4a50f050a10ad6384075a7e	121	\\xa99de549c4e38d11ba152bd58b982314f58ffaee350f969156bb1827a345bc25	2021-05-20 15:02:32.328285+00	2021-05-20 14:35:33+00
23	\\xa99de549c4e38d11ba152bd58b982314f58ffaee350f969156bb1827a345bc25	120	\\x9bb20cbfa578ec534adf8a59528ca522ec05f7a44a43eeb9d04012d6f27730e9	2021-05-20 15:02:32.330725+00	2021-05-20 14:35:27+00
24	\\x9bb20cbfa578ec534adf8a59528ca522ec05f7a44a43eeb9d04012d6f27730e9	119	\\xc5946e019b3510e58305b571db89f952a23b4fc326c2cd33c2948e3a0fb06796	2021-05-20 15:02:32.333386+00	2021-05-20 14:35:24+00
25	\\xc5946e019b3510e58305b571db89f952a23b4fc326c2cd33c2948e3a0fb06796	118	\\x37daafe452dfa2ac0688ce3067e6b3c9a7b2db989d2da19f7883baa98161f6a6	2021-05-20 15:02:32.335693+00	2021-05-20 14:35:21+00
26	\\x37daafe452dfa2ac0688ce3067e6b3c9a7b2db989d2da19f7883baa98161f6a6	117	\\x277068c567185803522188761b2aa54e94c8e22dfee89f5a0f571273bdaf5602	2021-05-20 15:02:32.338049+00	2021-05-20 14:35:15+00
27	\\x277068c567185803522188761b2aa54e94c8e22dfee89f5a0f571273bdaf5602	116	\\xef19e231d89c960767c19a5825696e9f4330aa6928bfaed8437d400fa20428d8	2021-05-20 15:02:32.340531+00	2021-05-20 14:35:12+00
28	\\xef19e231d89c960767c19a5825696e9f4330aa6928bfaed8437d400fa20428d8	115	\\x319b64206514616ed0ecaedb152a1d7fc675ce53de911a5aa1c60b7851cdd401	2021-05-20 15:02:32.342817+00	2021-05-20 14:35:09+00
29	\\x319b64206514616ed0ecaedb152a1d7fc675ce53de911a5aa1c60b7851cdd401	114	\\xc1a66488b6564456edb27f0495c0fbc3cd838b96d3830fd6609d7bb7b1efc211	2021-05-20 15:02:32.345079+00	2021-05-20 14:35:06+00
30	\\xc1a66488b6564456edb27f0495c0fbc3cd838b96d3830fd6609d7bb7b1efc211	113	\\x0eb2ffe635e5c07c858af44a109bafc3ec04806926ba5ba4c501e96fdfd2cf1d	2021-05-20 15:02:32.347328+00	2021-05-20 14:35:03+00
31	\\x0eb2ffe635e5c07c858af44a109bafc3ec04806926ba5ba4c501e96fdfd2cf1d	112	\\x33cc73673175111ec66e1d6f3a0a96c6ffd8fdbe281631fdf60ccfe1443400d0	2021-05-20 15:02:32.349287+00	2021-05-20 14:34:57+00
32	\\x33cc73673175111ec66e1d6f3a0a96c6ffd8fdbe281631fdf60ccfe1443400d0	111	\\x3e3700d700e14964b8e2db3d17f863618f80b4cb969d00e5fb8dedba27a1289f	2021-05-20 15:02:32.351401+00	2021-05-20 14:34:54+00
33	\\x3e3700d700e14964b8e2db3d17f863618f80b4cb969d00e5fb8dedba27a1289f	110	\\x2ad47a72becd1fbdd335d5d0ef7e10bea2a9e88d0222201ea563ac2d31aa2d7d	2021-05-20 15:02:32.353526+00	2021-05-20 14:34:51+00
34	\\x2ad47a72becd1fbdd335d5d0ef7e10bea2a9e88d0222201ea563ac2d31aa2d7d	109	\\x9fb3195cb4bfcd69b79d3660021b9ccf21885eb9be2d6f32587dd662a5ef24ca	2021-05-20 15:02:32.355668+00	2021-05-20 14:34:48+00
35	\\x9fb3195cb4bfcd69b79d3660021b9ccf21885eb9be2d6f32587dd662a5ef24ca	108	\\x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f	2021-05-20 15:02:32.357646+00	2021-05-20 14:34:45+00
36	\\x309c603041f4318ac0a34fb296f70e5c337fda97281c17feeb00dd5f9e2eb74f	107	\\x5d08464d36be385afb6aa9e7b727022aa376e880506806c47baf581d486eb79e	2021-05-20 15:02:32.359889+00	2021-05-20 14:34:39+00
37	\\x5d08464d36be385afb6aa9e7b727022aa376e880506806c47baf581d486eb79e	106	\\x7222d740c34004e0b532ad5df04bb130ed9710ca4de8274a1b6851f03e0de1f9	2021-05-20 15:02:32.362101+00	2021-05-20 14:34:36+00
38	\\x7222d740c34004e0b532ad5df04bb130ed9710ca4de8274a1b6851f03e0de1f9	105	\\xd6ad5639370542f349d3f3a1b0e02073fc1cbda82a47037e4e78ca011d08e969	2021-05-20 15:02:32.364475+00	2021-05-20 14:34:33+00
39	\\xd6ad5639370542f349d3f3a1b0e02073fc1cbda82a47037e4e78ca011d08e969	104	\\x9a591a7401cf0fe57bc0eff3040d5acd1b071b176e294bb307f738a66dfe57e2	2021-05-20 15:02:32.366734+00	2021-05-20 14:34:30+00
40	\\x9a591a7401cf0fe57bc0eff3040d5acd1b071b176e294bb307f738a66dfe57e2	103	\\x3bf5863f91a2a59433547dce0a45b3514fbf5a2b058c907ceb6292c3936660c5	2021-05-20 15:02:32.368938+00	2021-05-20 14:34:27+00
41	\\x3bf5863f91a2a59433547dce0a45b3514fbf5a2b058c907ceb6292c3936660c5	102	\\x56bce38a89f0c5c9013823382f9be447ac4cd016ab01dc6d736b6ac48aecf3d6	2021-05-20 15:02:32.371163+00	2021-05-20 14:34:24+00
42	\\x56bce38a89f0c5c9013823382f9be447ac4cd016ab01dc6d736b6ac48aecf3d6	101	\\xd2075f15f615e7a7683984e693d76d8bbacbc963c4b7bd582690eb72b12c338b	2021-05-20 15:02:32.373421+00	2021-05-20 14:34:21+00
43	\\xd2075f15f615e7a7683984e693d76d8bbacbc963c4b7bd582690eb72b12c338b	100	\\xb8d67fe74fc18041298216a6e377c0536feaf70d5c3cf2a9993f9d2c5c2f03c6	2021-05-20 15:02:32.37546+00	2021-05-20 14:34:18+00
44	\\xb8d67fe74fc18041298216a6e377c0536feaf70d5c3cf2a9993f9d2c5c2f03c6	99	\\x7eb6478b401fadee5edd35307060e5e8de667e1e90b4afb382b6bed0c158ef2c	2021-05-20 15:02:32.37767+00	2021-05-20 14:34:15+00
45	\\x7eb6478b401fadee5edd35307060e5e8de667e1e90b4afb382b6bed0c158ef2c	98	\\xd0cf769c48ac8ac0463110d58a08989903fbcba16f5a8baccb7bf8d01f29c71d	2021-05-20 15:02:32.3796+00	2021-05-20 14:34:12+00
46	\\xd0cf769c48ac8ac0463110d58a08989903fbcba16f5a8baccb7bf8d01f29c71d	97	\\xae32fb105e7af15448d4f0f530254138556ad3a395f54b8adbc0d28c470e69d5	2021-05-20 15:02:32.381879+00	2021-05-20 14:34:09+00
47	\\xae32fb105e7af15448d4f0f530254138556ad3a395f54b8adbc0d28c470e69d5	96	\\x3ea41936adfe889d3bddda9a0070ae6ae5cf1325f752fc26eb98b08ff3b10df6	2021-05-20 15:02:32.383872+00	2021-05-20 14:34:03+00
48	\\x3ea41936adfe889d3bddda9a0070ae6ae5cf1325f752fc26eb98b08ff3b10df6	95	\\x178aebd6f171245e3326b1b7903c35af718a6e925f8eeb9756032085edafc924	2021-05-20 15:02:32.385657+00	2021-05-20 14:34:00+00
49	\\x178aebd6f171245e3326b1b7903c35af718a6e925f8eeb9756032085edafc924	94	\\xa8a4ff77a17736416a2e6025d2e09e1c324285c7afb9532944775178b956aebe	2021-05-20 15:02:32.387717+00	2021-05-20 14:33:57+00
50	\\xa8a4ff77a17736416a2e6025d2e09e1c324285c7afb9532944775178b956aebe	93	\\x5553cd20423825b8b955ca4c7da1a3b654a269f9f0b154d19eb92fc141e9ee68	2021-05-20 15:02:32.389903+00	2021-05-20 14:33:54+00
51	\\x3e76831e8256834b341768c9c55f7d29380d03d6e2063dd987411036e4f4b37e	143	\\xf4f36daefc595c63ba0e0c0bfb4361900b07df09bc564271ae1e6ee83fbaa4f6	2021-05-20 15:09:32.27295+00	2021-05-20 15:09:32+00
52	\\x96e3a5e23b3e142511b8b8a201dfc36662772764cdfe14264e6731ec0f5638b7	144	\\x3e76831e8256834b341768c9c55f7d29380d03d6e2063dd987411036e4f4b37e	2021-05-20 15:09:45.980098+00	2021-05-20 15:09:45+00
53	\\x959bbcc51566e0325eba69ef30d937ecc29a4599c373b43ccee4ef10e1fd877c	145	\\x96e3a5e23b3e142511b8b8a201dfc36662772764cdfe14264e6731ec0f5638b7	2021-05-20 15:15:37.362895+00	2021-05-20 15:15:37+00
\.


--
-- Data for Name: initiators; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.initiators (id, job_spec_id, type, created_at, deleted_at, schedule, "time", ran, address, requesters, name, params, from_block, to_block, topics, request_data, feeds, threshold, "precision", polling_interval, absolute_threshold, updated_at, poll_timer, idle_timer, job_id_topic_filter) FROM stdin;
1	c0d1fe92-d7f2-4c5d-b788-8198f5afaa88	runlog	2021-05-20 15:15:31.974177+00	\N		\N	f	\\x999a3afce3becf423380bf568aa8c7f344388148			\N	\N	\N	null	\N	\N	0	0	\N	0	2021-05-20 15:15:31.974177+00	{"period": "0s"}	{"duration": "0s"}	00000000-0000-0000-0000-000000000000
2	84d945bc-e1b4-4e3d-a3be-068cc2780705	web	2021-05-20 15:17:31.213875+00	\N		\N	f	\\x0000000000000000000000000000000000000000			\N	\N	\N	null	\N	\N	0	0	\N	0	2021-05-20 15:17:31.213875+00	{"period": "0s"}	{"duration": "0s"}	00000000-0000-0000-0000-000000000000
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
2021-05-20 15:15:31.967004+00	\N	\N	\N	\N	c0d1fe92-d7f2-4c5d-b788-8198f5afaa88	2021-05-20 15:15:31.971305+00	ResolveENSname
2021-05-20 15:17:31.207725+00	\N	\N	\N	\N	84d945bc-e1b4-4e3d-a3be-068cc2780705	2021-05-20 15:17:31.21265+00	ResolveENSnameWebTrigger
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
\\xdf0107f91eccd830ca0f0697ad42259ae3459097	{"id": "bbc7c7d9-7659-46f5-84b6-18187e71f0fc", "crypto": {"kdf": "scrypt", "mac": "72f151285fa3a6d39576adaedbdb4fbd980bde525a016f72a3de4ef955e37355", "cipher": "aes-128-ctr", "kdfparams": {"n": 262144, "p": 1, "r": 8, "salt": "21dda81687e521d912cbcd765e19454ce2d6c51629eba377150ded61d620bcd7", "dklen": 32}, "ciphertext": "a4e0241182ddacac4800a4ba7542fe992f44c9b4f699c389d01c542713d7f5b9", "cipherparams": {"iv": "db67c2631bda7ff07dc2d9072a59ed85"}}, "address": "df0107f91eccd830ca0f0697ad42259ae3459097", "version": 3}	2021-05-20 15:01:39.857325+00	2021-05-20 15:01:39.857325+00	0	1	\N	f	\N
\\x37e136d2c9b8095455127658465d35199568bb33	{"id": "0d3a9e75-797b-4e7e-95e4-31b5f8032408", "crypto": {"kdf": "scrypt", "mac": "c67e3e56220db2ff37bdd4187f07bfe19da110c7529d73b940c14bd93426ed87", "cipher": "aes-128-ctr", "kdfparams": {"n": 262144, "p": 1, "r": 8, "salt": "07d7fac0533957c400361c625850e5b69564c3a1c1fc3b5c57f62caa0df0a760", "dklen": 32}, "ciphertext": "c570c8eb267e40db3d46360e67b481f6d2653bc622bf757e3c9e5d69ccd31a6e", "cipherparams": {"iv": "5dcbbd1de5d0ea81f54abe2859fd5687"}}, "address": "37e136d2c9b8095455127658465d35199568bb33", "version": 3}	2021-05-20 15:02:17.479576+00	2021-05-20 15:02:17.479576+00	0	3	\N	t	\N
\.


--
-- Data for Name: large_notifications; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.large_notifications (id, payload, created_at) FROM stdin;
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
0.10.5	2021-05-20 15:01:37.378496
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
1e0f42aadb7e455ab654753b72b388a3	2021-05-20 15:02:29.838488+00	2021-05-20 15:02:27.974949+00
3d5bb57514bc4450a8af75cf015a2957	2021-05-20 15:17:38.902203+00	2021-05-20 15:09:24.001823+00
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
1	2021-05-20 15:15:31.977124+00	2021-05-20 15:15:31.977124+00	\N	ensbridge	\N	\N	c0d1fe92-d7f2-4c5d-b788-8198f5afaa88
2	2021-05-20 15:15:31.977124+00	2021-05-20 15:15:31.977124+00	\N	ethint256	\N	\N	c0d1fe92-d7f2-4c5d-b788-8198f5afaa88
3	2021-05-20 15:15:31.977124+00	2021-05-20 15:15:31.977124+00	\N	ethtx	\N	\N	c0d1fe92-d7f2-4c5d-b788-8198f5afaa88
4	2021-05-20 15:17:31.217287+00	2021-05-20 15:17:31.217287+00	\N	ensbridge	\N	{"name": "data.eth"}	84d945bc-e1b4-4e3d-a3be-068cc2780705
5	2021-05-20 15:17:31.217287+00	2021-05-20 15:17:31.217287+00	\N	ethint256	\N	\N	84d945bc-e1b4-4e3d-a3be-068cc2780705
\.


--
-- Data for Name: unneeded_event_ids; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.unneeded_event_ids (event_id) FROM stdin;
\.


--
-- Data for Name: unused_deployments; Type: TABLE DATA; Schema: public; Owner: streamr
--

COPY public.unused_deployments (deployment, unused_at, removed_at, subgraphs, namespace, shard, entity_count, latest_ethereum_block_hash, latest_ethereum_block_number, failed, synced, id) FROM stdin;
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
a@a.com	$2a$10$9LvuiTKwJbmV0pCeLPI.3u1B/qJhckd1Soz0Ff/8nZsrKPSzejvOa	2021-05-20 15:01:41.457487+00				2021-05-20 15:01:41.456379+00	\N
\.


--
-- Data for Name: permission; Type: TABLE DATA; Schema: sgd1; Owner: streamr
--

COPY sgd1.permission (id, "user", stream, edit, can_delete, publish, subscribed, share, vid, block_range) FROM stdin;
\.


--
-- Data for Name: poi2$; Type: TABLE DATA; Schema: sgd1; Owner: streamr
--

COPY sgd1."poi2$" (digest, id, vid, block_range) FROM stdin;
\.


--
-- Data for Name: stream; Type: TABLE DATA; Schema: sgd1; Owner: streamr
--

COPY sgd1.stream (id, metadata, vid, block_range) FROM stdin;
\.


--
-- Data for Name: copy_state; Type: TABLE DATA; Schema: subgraphs; Owner: streamr
--

COPY subgraphs.copy_state (src, dst, target_block_hash, target_block_number, started_at, finished_at, cancelled_at) FROM stdin;
\.


--
-- Data for Name: copy_table_state; Type: TABLE DATA; Schema: subgraphs; Owner: streamr
--

COPY subgraphs.copy_table_state (id, entity_type, dst, next_vid, target_vid, batch_size, started_at, finished_at, duration_ms) FROM stdin;
\.


--
-- Data for Name: dynamic_ethereum_contract_data_source; Type: TABLE DATA; Schema: subgraphs; Owner: streamr
--

COPY subgraphs.dynamic_ethereum_contract_data_source (name, ethereum_block_hash, ethereum_block_number, deployment, vid, context, address, abi, start_block) FROM stdin;
\.


--
-- Data for Name: subgraph; Type: TABLE DATA; Schema: subgraphs; Owner: streamr
--

COPY subgraphs.subgraph (id, name, current_version, pending_version, created_at, vid, block_range) FROM stdin;
df690b67d9ae77f7e98a86448348f020	githubname/subgraphname	ed8f7f36feccfec3203daf59d6073b3b	\N	1621524304	1	[-1,)
\.


--
-- Data for Name: subgraph_deployment; Type: TABLE DATA; Schema: subgraphs; Owner: streamr
--

COPY subgraphs.subgraph_deployment (deployment, failed, synced, earliest_ethereum_block_hash, earliest_ethereum_block_number, latest_ethereum_block_hash, latest_ethereum_block_number, entity_count, graft_base, graft_block_hash, graft_block_number, fatal_error, non_fatal_errors, health, reorg_count, current_reorg_depth, max_reorg_depth, last_healthy_ethereum_block_hash, last_healthy_ethereum_block_number, id) FROM stdin;
Qmb1h8mpRTpwHfk3W6DTVmnwAiqrpMrvM4iPqYXLRp28ew	f	t	\N	\N	\\x8a0558dbad53e775757271ceb3db1b7bd3018a06c40c56e259b999f1d57d8df0	175	0	\N	\N	\N	\N	{}	healthy	30	0	30	\N	\N	1
\.


--
-- Data for Name: subgraph_deployment_assignment; Type: TABLE DATA; Schema: subgraphs; Owner: streamr
--

COPY subgraphs.subgraph_deployment_assignment (node_id, id) FROM stdin;
default	1
\.


--
-- Data for Name: subgraph_error; Type: TABLE DATA; Schema: subgraphs; Owner: streamr
--

COPY subgraphs.subgraph_error (id, subgraph_id, message, block_hash, handler, vid, block_range, deterministic, created_at) FROM stdin;
\.


--
-- Data for Name: subgraph_manifest; Type: TABLE DATA; Schema: subgraphs; Owner: streamr
--

COPY subgraphs.subgraph_manifest (spec_version, description, repository, schema, features, id) FROM stdin;
0.0.2	Subgraph definitions for the stream permission registry	\N	type Stream @entity @subgraphId(id: "Qmb1h8mpRTpwHfk3W6DTVmnwAiqrpMrvM4iPqYXLRp28ew") {\n  id: ID!\n  metadata: String!\n  permissions: [Permission]! @derivedFrom(field: "stream")\n}\n\ntype Permission @entity @subgraphId(id: "Qmb1h8mpRTpwHfk3W6DTVmnwAiqrpMrvM4iPqYXLRp28ew") {\n  id: ID!\n  user: Bytes!\n  stream: Stream\n  edit: Boolean\n  canDelete: Boolean\n  publish: Boolean\n  subscribed: Boolean\n  share: Boolean\n}\n	{}	1
\.


--
-- Data for Name: subgraph_version; Type: TABLE DATA; Schema: subgraphs; Owner: streamr
--

COPY subgraphs.subgraph_version (id, subgraph, deployment, created_at, vid, block_range) FROM stdin;
ed8f7f36feccfec3203daf59d6073b3b	df690b67d9ae77f7e98a86448348f020	Qmb1h8mpRTpwHfk3W6DTVmnwAiqrpMrvM4iPqYXLRp28ew	1621524308	1	[-1,)
\.


--
-- Name: chains_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.chains_id_seq', 1, true);


--
-- Name: configurations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.configurations_id_seq', 1, true);


--
-- Name: cron_specs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.cron_specs_id_seq', 1, false);


--
-- Name: deployment_schemas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.deployment_schemas_id_seq', 1, true);


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
-- Name: event_meta_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.event_meta_data_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.heads_id_seq', 53, true);


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
-- Name: large_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: streamr
--

SELECT pg_catalog.setval('public.large_notifications_id_seq', 1, false);


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
-- Name: permission_vid_seq; Type: SEQUENCE SET; Schema: sgd1; Owner: streamr
--

SELECT pg_catalog.setval('sgd1.permission_vid_seq', 1, false);


--
-- Name: poi2$_vid_seq; Type: SEQUENCE SET; Schema: sgd1; Owner: streamr
--

SELECT pg_catalog.setval('sgd1."poi2$_vid_seq"', 1, false);


--
-- Name: stream_vid_seq; Type: SEQUENCE SET; Schema: sgd1; Owner: streamr
--

SELECT pg_catalog.setval('sgd1.stream_vid_seq', 1, false);


--
-- Name: copy_table_state_id_seq; Type: SEQUENCE SET; Schema: subgraphs; Owner: streamr
--

SELECT pg_catalog.setval('subgraphs.copy_table_state_id_seq', 1, false);


--
-- Name: dynamic_ethereum_contract_data_source_vid_seq; Type: SEQUENCE SET; Schema: subgraphs; Owner: streamr
--

SELECT pg_catalog.setval('subgraphs.dynamic_ethereum_contract_data_source_vid_seq', 1, false);


--
-- Name: subgraph_error_vid_seq; Type: SEQUENCE SET; Schema: subgraphs; Owner: streamr
--

SELECT pg_catalog.setval('subgraphs.subgraph_error_vid_seq', 1, false);


--
-- Name: subgraph_version_vid_seq; Type: SEQUENCE SET; Schema: subgraphs; Owner: streamr
--

SELECT pg_catalog.setval('subgraphs.subgraph_version_vid_seq', 1, true);


--
-- Name: subgraph_vid_seq; Type: SEQUENCE SET; Schema: subgraphs; Owner: streamr
--

SELECT pg_catalog.setval('subgraphs.subgraph_vid_seq', 2, true);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: chain1; Owner: streamr
--

ALTER TABLE ONLY chain1.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (hash);


--
-- Name: call_cache call_cache_pkey; Type: CONSTRAINT; Schema: chain1; Owner: streamr
--

ALTER TABLE ONLY chain1.call_cache
    ADD CONSTRAINT call_cache_pkey PRIMARY KEY (id);


--
-- Name: call_meta call_meta_pkey; Type: CONSTRAINT; Schema: chain1; Owner: streamr
--

ALTER TABLE ONLY chain1.call_meta
    ADD CONSTRAINT call_meta_pkey PRIMARY KEY (contract_address);


--
-- Name: __diesel_schema_migrations __diesel_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.__diesel_schema_migrations
    ADD CONSTRAINT __diesel_schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: external_initiators access_key_unique; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.external_initiators
    ADD CONSTRAINT access_key_unique UNIQUE (access_key);


--
-- Name: active_copies active_copies_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.active_copies
    ADD CONSTRAINT active_copies_pkey PRIMARY KEY (dst);


--
-- Name: active_copies active_copies_src_dst_key; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.active_copies
    ADD CONSTRAINT active_copies_src_dst_key UNIQUE (src, dst);


--
-- Name: bridge_types bridge_types_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.bridge_types
    ADD CONSTRAINT bridge_types_pkey PRIMARY KEY (name);


--
-- Name: chains chains_name_key; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.chains
    ADD CONSTRAINT chains_name_key UNIQUE (name);


--
-- Name: chains chains_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.chains
    ADD CONSTRAINT chains_pkey PRIMARY KEY (id);


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
-- Name: db_version db_version_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.db_version
    ADD CONSTRAINT db_version_pkey PRIMARY KEY (db_version);


--
-- Name: deployment_schemas deployment_schemas_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.deployment_schemas
    ADD CONSTRAINT deployment_schemas_pkey PRIMARY KEY (id);


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
-- Name: ens_names ens_names_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.ens_names
    ADD CONSTRAINT ens_names_pkey PRIMARY KEY (hash);


--
-- Name: eth_call_cache eth_call_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_call_cache
    ADD CONSTRAINT eth_call_cache_pkey PRIMARY KEY (id);


--
-- Name: eth_call_meta eth_call_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.eth_call_meta
    ADD CONSTRAINT eth_call_meta_pkey PRIMARY KEY (contract_address);


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
-- Name: ethereum_blocks ethereum_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.ethereum_blocks
    ADD CONSTRAINT ethereum_blocks_pkey PRIMARY KEY (hash);


--
-- Name: ethereum_networks ethereum_networks_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.ethereum_networks
    ADD CONSTRAINT ethereum_networks_pkey PRIMARY KEY (name);


--
-- Name: event_meta_data event_meta_data_db_transaction_id_key; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.event_meta_data
    ADD CONSTRAINT event_meta_data_db_transaction_id_key UNIQUE (db_transaction_id);


--
-- Name: event_meta_data event_meta_data_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.event_meta_data
    ADD CONSTRAINT event_meta_data_pkey PRIMARY KEY (id);


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
-- Name: large_notifications large_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.large_notifications
    ADD CONSTRAINT large_notifications_pkey PRIMARY KEY (id);


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
-- Name: unneeded_event_ids unneeded_event_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.unneeded_event_ids
    ADD CONSTRAINT unneeded_event_ids_pkey PRIMARY KEY (event_id);


--
-- Name: unused_deployments unused_deployments_pkey; Type: CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.unused_deployments
    ADD CONSTRAINT unused_deployments_pkey PRIMARY KEY (id);


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
-- Name: permission permission_id_block_range_excl; Type: CONSTRAINT; Schema: sgd1; Owner: streamr
--

ALTER TABLE ONLY sgd1.permission
    ADD CONSTRAINT permission_id_block_range_excl EXCLUDE USING gist (id WITH =, block_range WITH &&);


--
-- Name: permission permission_pkey; Type: CONSTRAINT; Schema: sgd1; Owner: streamr
--

ALTER TABLE ONLY sgd1.permission
    ADD CONSTRAINT permission_pkey PRIMARY KEY (vid);


--
-- Name: poi2$ poi2$_id_block_range_excl; Type: CONSTRAINT; Schema: sgd1; Owner: streamr
--

ALTER TABLE ONLY sgd1."poi2$"
    ADD CONSTRAINT "poi2$_id_block_range_excl" EXCLUDE USING gist (id WITH =, block_range WITH &&);


--
-- Name: poi2$ poi2$_pkey; Type: CONSTRAINT; Schema: sgd1; Owner: streamr
--

ALTER TABLE ONLY sgd1."poi2$"
    ADD CONSTRAINT "poi2$_pkey" PRIMARY KEY (vid);


--
-- Name: stream stream_id_block_range_excl; Type: CONSTRAINT; Schema: sgd1; Owner: streamr
--

ALTER TABLE ONLY sgd1.stream
    ADD CONSTRAINT stream_id_block_range_excl EXCLUDE USING gist (id WITH =, block_range WITH &&);


--
-- Name: stream stream_pkey; Type: CONSTRAINT; Schema: sgd1; Owner: streamr
--

ALTER TABLE ONLY sgd1.stream
    ADD CONSTRAINT stream_pkey PRIMARY KEY (vid);


--
-- Name: copy_state copy_state_pkey; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.copy_state
    ADD CONSTRAINT copy_state_pkey PRIMARY KEY (dst);


--
-- Name: copy_table_state copy_table_state_dst_entity_type_key; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.copy_table_state
    ADD CONSTRAINT copy_table_state_dst_entity_type_key UNIQUE (dst, entity_type);


--
-- Name: copy_table_state copy_table_state_pkey; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.copy_table_state
    ADD CONSTRAINT copy_table_state_pkey PRIMARY KEY (id);


--
-- Name: dynamic_ethereum_contract_data_source dynamic_ethereum_contract_data_source_pkey; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.dynamic_ethereum_contract_data_source
    ADD CONSTRAINT dynamic_ethereum_contract_data_source_pkey PRIMARY KEY (vid);


--
-- Name: subgraph_deployment_assignment subgraph_deployment_assignment_pkey; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_deployment_assignment
    ADD CONSTRAINT subgraph_deployment_assignment_pkey PRIMARY KEY (id);


--
-- Name: subgraph_deployment subgraph_deployment_id_key; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_deployment
    ADD CONSTRAINT subgraph_deployment_id_key UNIQUE (deployment);


--
-- Name: subgraph_deployment subgraph_deployment_pkey; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_deployment
    ADD CONSTRAINT subgraph_deployment_pkey PRIMARY KEY (id);


--
-- Name: subgraph_error subgraph_error_id_block_range_excl; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_error
    ADD CONSTRAINT subgraph_error_id_block_range_excl EXCLUDE USING gist (id WITH =, block_range WITH &&);


--
-- Name: subgraph_error subgraph_error_pkey; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_error
    ADD CONSTRAINT subgraph_error_pkey PRIMARY KEY (vid);


--
-- Name: subgraph subgraph_id_block_range_excl; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph
    ADD CONSTRAINT subgraph_id_block_range_excl EXCLUDE USING gist (id WITH =, block_range WITH &&);


--
-- Name: subgraph_manifest subgraph_manifest_pkey; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_manifest
    ADD CONSTRAINT subgraph_manifest_pkey PRIMARY KEY (id);


--
-- Name: subgraph subgraph_name_uq; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph
    ADD CONSTRAINT subgraph_name_uq UNIQUE (name);


--
-- Name: subgraph subgraph_pkey; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph
    ADD CONSTRAINT subgraph_pkey PRIMARY KEY (vid);


--
-- Name: subgraph_version subgraph_version_id_block_range_excl; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_version
    ADD CONSTRAINT subgraph_version_id_block_range_excl EXCLUDE USING gist (id WITH =, block_range WITH &&);


--
-- Name: subgraph_version subgraph_version_pkey; Type: CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_version
    ADD CONSTRAINT subgraph_version_pkey PRIMARY KEY (vid);


--
-- Name: blocks_number; Type: INDEX; Schema: chain1; Owner: streamr
--

CREATE INDEX blocks_number ON chain1.blocks USING btree (number);


--
-- Name: deployment_schemas_deployment_active; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX deployment_schemas_deployment_active ON public.deployment_schemas USING btree (subgraph) WHERE active;


--
-- Name: deployment_schemas_subgraph_shard_uq; Type: INDEX; Schema: public; Owner: streamr
--

CREATE UNIQUE INDEX deployment_schemas_subgraph_shard_uq ON public.deployment_schemas USING btree (subgraph, shard);


--
-- Name: ethereum_blocks_name_number; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX ethereum_blocks_name_number ON public.ethereum_blocks USING btree (network_name, number);


--
-- Name: event_meta_data_source; Type: INDEX; Schema: public; Owner: streamr
--

CREATE INDEX event_meta_data_source ON public.event_meta_data USING btree (source);


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
-- Name: attr_0_0_stream_id; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX attr_0_0_stream_id ON sgd1.stream USING btree (id);


--
-- Name: attr_0_1_stream_metadata; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX attr_0_1_stream_metadata ON sgd1.stream USING btree ("left"(metadata, 256));


--
-- Name: attr_1_0_permission_id; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX attr_1_0_permission_id ON sgd1.permission USING btree (id);


--
-- Name: attr_1_1_permission_user; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX attr_1_1_permission_user ON sgd1.permission USING btree ("user");


--
-- Name: attr_1_2_permission_stream; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX attr_1_2_permission_stream ON sgd1.permission USING gist (stream, block_range);


--
-- Name: attr_1_3_permission_edit; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX attr_1_3_permission_edit ON sgd1.permission USING btree (edit);


--
-- Name: attr_1_4_permission_can_delete; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX attr_1_4_permission_can_delete ON sgd1.permission USING btree (can_delete);


--
-- Name: attr_1_5_permission_publish; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX attr_1_5_permission_publish ON sgd1.permission USING btree (publish);


--
-- Name: attr_1_6_permission_subscribed; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX attr_1_6_permission_subscribed ON sgd1.permission USING btree (subscribed);


--
-- Name: attr_1_7_permission_share; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX attr_1_7_permission_share ON sgd1.permission USING btree (share);


--
-- Name: attr_2_0_poi2$_digest; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX "attr_2_0_poi2$_digest" ON sgd1."poi2$" USING btree (digest);


--
-- Name: attr_2_1_poi2$_id; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX "attr_2_1_poi2$_id" ON sgd1."poi2$" USING btree ("left"(id, 256));


--
-- Name: brin_permission; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX brin_permission ON sgd1.permission USING brin (lower(block_range), COALESCE(upper(block_range), 2147483647), vid);


--
-- Name: brin_poi2$; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX "brin_poi2$" ON sgd1."poi2$" USING brin (lower(block_range), COALESCE(upper(block_range), 2147483647), vid);


--
-- Name: brin_stream; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX brin_stream ON sgd1.stream USING brin (lower(block_range), COALESCE(upper(block_range), 2147483647), vid);


--
-- Name: permission_block_range_closed; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX permission_block_range_closed ON sgd1.permission USING btree (COALESCE(upper(block_range), 2147483647)) WHERE (COALESCE(upper(block_range), 2147483647) < 2147483647);


--
-- Name: poi2$_block_range_closed; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX "poi2$_block_range_closed" ON sgd1."poi2$" USING btree (COALESCE(upper(block_range), 2147483647)) WHERE (COALESCE(upper(block_range), 2147483647) < 2147483647);


--
-- Name: stream_block_range_closed; Type: INDEX; Schema: sgd1; Owner: streamr
--

CREATE INDEX stream_block_range_closed ON sgd1.stream USING btree (COALESCE(upper(block_range), 2147483647)) WHERE (COALESCE(upper(block_range), 2147483647) < 2147483647);


--
-- Name: attr_0_0_subgraph_id; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_0_0_subgraph_id ON subgraphs.subgraph USING btree (id);


--
-- Name: attr_0_1_subgraph_name; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_0_1_subgraph_name ON subgraphs.subgraph USING btree ("left"(name, 256));


--
-- Name: attr_0_2_subgraph_current_version; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_0_2_subgraph_current_version ON subgraphs.subgraph USING btree (current_version);


--
-- Name: attr_0_3_subgraph_pending_version; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_0_3_subgraph_pending_version ON subgraphs.subgraph USING btree (pending_version);


--
-- Name: attr_0_4_subgraph_created_at; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_0_4_subgraph_created_at ON subgraphs.subgraph USING btree (created_at);


--
-- Name: attr_16_0_subgraph_error_id; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_16_0_subgraph_error_id ON subgraphs.subgraph_error USING btree (id);


--
-- Name: attr_16_1_subgraph_error_subgraph_id; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_16_1_subgraph_error_subgraph_id ON subgraphs.subgraph_error USING btree ("left"(subgraph_id, 256));


--
-- Name: attr_1_0_subgraph_version_id; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_1_0_subgraph_version_id ON subgraphs.subgraph_version USING btree (id);


--
-- Name: attr_1_1_subgraph_version_subgraph; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_1_1_subgraph_version_subgraph ON subgraphs.subgraph_version USING btree (subgraph);


--
-- Name: attr_1_2_subgraph_version_deployment; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_1_2_subgraph_version_deployment ON subgraphs.subgraph_version USING btree (deployment);


--
-- Name: attr_1_3_subgraph_version_created_at; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_1_3_subgraph_version_created_at ON subgraphs.subgraph_version USING btree (created_at);


--
-- Name: attr_2_0_subgraph_deployment_id; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_2_0_subgraph_deployment_id ON subgraphs.subgraph_deployment USING btree (deployment);


--
-- Name: attr_2_11_subgraph_deployment_entity_count; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_2_11_subgraph_deployment_entity_count ON subgraphs.subgraph_deployment USING btree (entity_count);


--
-- Name: attr_2_2_subgraph_deployment_failed; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_2_2_subgraph_deployment_failed ON subgraphs.subgraph_deployment USING btree (failed);


--
-- Name: attr_2_3_subgraph_deployment_synced; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_2_3_subgraph_deployment_synced ON subgraphs.subgraph_deployment USING btree (synced);


--
-- Name: attr_2_4_subgraph_deployment_earliest_ethereum_block_hash; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_2_4_subgraph_deployment_earliest_ethereum_block_hash ON subgraphs.subgraph_deployment USING btree (earliest_ethereum_block_hash);


--
-- Name: attr_2_5_subgraph_deployment_earliest_ethereum_block_number; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_2_5_subgraph_deployment_earliest_ethereum_block_number ON subgraphs.subgraph_deployment USING btree (earliest_ethereum_block_number);


--
-- Name: attr_2_6_subgraph_deployment_latest_ethereum_block_hash; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_2_6_subgraph_deployment_latest_ethereum_block_hash ON subgraphs.subgraph_deployment USING btree (latest_ethereum_block_hash);


--
-- Name: attr_2_7_subgraph_deployment_latest_ethereum_block_number; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_2_7_subgraph_deployment_latest_ethereum_block_number ON subgraphs.subgraph_deployment USING btree (latest_ethereum_block_number);


--
-- Name: attr_3_1_subgraph_deployment_assignment_node_id; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_3_1_subgraph_deployment_assignment_node_id ON subgraphs.subgraph_deployment_assignment USING btree ("left"(node_id, 256));


--
-- Name: attr_6_9_dynamic_ethereum_contract_data_source_deployment; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_6_9_dynamic_ethereum_contract_data_source_deployment ON subgraphs.dynamic_ethereum_contract_data_source USING btree (deployment);


--
-- Name: attr_subgraph_deployment_health; Type: INDEX; Schema: subgraphs; Owner: streamr
--

CREATE INDEX attr_subgraph_deployment_health ON subgraphs.subgraph_deployment USING btree (health);


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
-- Name: active_copies active_copies_dst_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.active_copies
    ADD CONSTRAINT active_copies_dst_fkey FOREIGN KEY (dst) REFERENCES public.deployment_schemas(id) ON DELETE CASCADE;


--
-- Name: active_copies active_copies_src_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.active_copies
    ADD CONSTRAINT active_copies_src_fkey FOREIGN KEY (src) REFERENCES public.deployment_schemas(id);


--
-- Name: deployment_schemas deployment_schemas_network_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.deployment_schemas
    ADD CONSTRAINT deployment_schemas_network_fkey FOREIGN KEY (network) REFERENCES public.chains(name);


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
-- Name: ethereum_blocks ethereum_blocks_network_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: streamr
--

ALTER TABLE ONLY public.ethereum_blocks
    ADD CONSTRAINT ethereum_blocks_network_name_fkey FOREIGN KEY (network_name) REFERENCES public.ethereum_networks(name);


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
-- Name: copy_state copy_state_dst_fkey; Type: FK CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.copy_state
    ADD CONSTRAINT copy_state_dst_fkey FOREIGN KEY (dst) REFERENCES subgraphs.subgraph_deployment(id) ON DELETE CASCADE;


--
-- Name: copy_table_state copy_table_state_dst_fkey; Type: FK CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.copy_table_state
    ADD CONSTRAINT copy_table_state_dst_fkey FOREIGN KEY (dst) REFERENCES subgraphs.copy_state(dst) ON DELETE CASCADE;


--
-- Name: subgraph_error subgraph_error_subgraph_id_fkey; Type: FK CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_error
    ADD CONSTRAINT subgraph_error_subgraph_id_fkey FOREIGN KEY (subgraph_id) REFERENCES subgraphs.subgraph_deployment(deployment) ON DELETE CASCADE;


--
-- Name: subgraph_manifest subgraph_manifest_new_id_fkey; Type: FK CONSTRAINT; Schema: subgraphs; Owner: streamr
--

ALTER TABLE ONLY subgraphs.subgraph_manifest
    ADD CONSTRAINT subgraph_manifest_new_id_fkey FOREIGN KEY (id) REFERENCES subgraphs.subgraph_deployment(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

