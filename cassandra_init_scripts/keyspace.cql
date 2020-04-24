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
