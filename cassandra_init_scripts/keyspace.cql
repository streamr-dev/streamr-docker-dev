CREATE KEYSPACE IF NOT EXISTS streamr_dev WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };
USE streamr_dev;

/* current */
CREATE TABLE IF NOT EXISTS stream_events (
    stream varchar,
    stream_partition int,
    kafka_partition int,
    kafka_offset bigint,
    previous_offset bigint,
    ts timestamp,
    payload blob,
    PRIMARY KEY ((stream, stream_partition), kafka_offset)
);

CREATE TABLE IF NOT EXISTS stream_timestamps (
    stream varchar,
    stream_partition int,
    kafka_offset bigint,
    ts timestamp,
    PRIMARY KEY ((stream, stream_partition), ts)
);

COPY stream_events FROM '/init_scripts/hsl-demo-data.csv' WITH DELIMITER = '|' AND HEADER = true;
COPY stream_timestamps FROM '/init_scripts/hsl-demo-data-ts.csv' WITH DELIMITER = '|' AND HEADER = true;

/* new messageID version */
CREATE TABLE IF NOT EXISTS stream_data (
    id varchar,
    partition int,
    ts timestamp,
    sequence_no int,
    publisher_id varchar,
    payload blob,
    PRIMARY KEY ((id, partition), ts, sequence_no, publisher_id)
);
