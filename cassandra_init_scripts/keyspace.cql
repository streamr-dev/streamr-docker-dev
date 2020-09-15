CREATE KEYSPACE IF NOT EXISTS streamr_dev WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };
USE streamr_dev;

CREATE TABLE IF NOT EXISTS stream_data (
    id varchar,
    partition int,
    ts timestamp,
    sequence_no bigint,
    publisher_id varchar,
    msg_chain_id varchar,
    payload blob,
    PRIMARY KEY ((id, partition), ts, sequence_no, publisher_id, msg_chain_id)
);

-- ### NEW KEYSPACE ### --
CREATE KEYSPACE IF NOT EXISTS streamr_dev_v2 WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };
USE streamr_dev_v2;

CREATE TABLE IF NOT EXISTS bucket
(
    stream_id   text,
    partition   int,
    date_create timestamp,
    id          timeuuid,
    records     int,
    size        int,
    primary key ((stream_id, partition), date_create)
) WITH CLUSTERING ORDER BY (date_create desc);

CREATE TABLE IF NOT EXISTS stream_data
(
    stream_id    text,
    partition    int,
    bucket_id    timeuuid,
    ts           timestamp,
    sequence_no  int,
    publisher_id text,
    msg_chain_id text,
    payload      blob,
    primary key ((stream_id, partition, bucket_id), ts, sequence_no, publisher_id, msg_chain_id)
) WITH CLUSTERING ORDER BY (ts ASC, sequence_no ASC);


