/*
  pges.sql
  ~~~~~~~~~~

  ...
 */

drop schema public cascade;
create schema public;

CREATE SEQUENCE next_id_seq;

CREATE OR REPLACE FUNCTION pges_next_id(OUT result BIGINT) AS $$
DECLARE
  custom_epoch bigint := 1314220021721;
  ids_per_shard_per_ms int := 1024;
  shard_id int := 5;
  sequence_id bigint;
  now_ms bigint;
BEGIN
  SELECT nextval(next_id_seq) % ids_per_shard_per_ms INTO sequence_id;
  SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_ms;
  result := (now_ms - custom_epoch) << 23;
  result := result | (shard_id << 10);
  result := result | (sequence_id);
END
$$ LANGUAGE plpgsql;


/*
CREATE TABLE IF NOT EXISTS pges_options(


);
*/


CREATE TABLE IF NOT EXISTS pges_aggregates(
  id BIGINT PRIMARY KEY DEFAULT pges_next_id(),
  type TEXT UNIQUE NOT NULL,
  version INTEGER NOT NULL DEFAULT 0
);


CREATE TABLE IF NOT EXISTS pges_events(
  id BIGINT PRIMARY KEY DEFAULT pges_next_id(),
  aggregate_id BIGINT REFERENCES pges_aggregates ON DELETE CASCADE,
  aggregate_version INTEGER NOT NULL DEFAULT 0,
  version INTEGER NOT NULL DEFAULT 0,
  data JSON NOT NULL
);


CREATE TABLE IF NOT EXISTS pges_snapshots(
  id BIGINT PRIMARY KEY DEFAULT pges_next_id(),
  aggregate_id BIGINT REFERENCES pges_aggregates,
  aggregate_version INTEGER NOT NULL DEFAULT 0,
  data JSON NOT NULL
);


CREATE OR REPLACE FUNCTION pges_set_event_aggregate_version() RETURNS TRIGGER AS $$
BEGIN
  SELECT version INTO NEW.aggregate_version FROM pges_aggregates WHERE id=NEW.aggregate_id;
  return NEW;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION pges_increment_aggregate_version() RETURNS TRIGGER AS $$
BEGIN

END
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS pges_increment_aggregate_version_trigger ON pges_events;

CREATE TRIGGER pges_increment_aggregate_version_trigger
  BEFORE INSERT ON pges_events
  FOR EACH ROW
  EXECUTE PROCEDURE pges_increment_aggregate_version();


DROP TRIGGER IF EXISTS pges_set_event_aggregate_version_trigger ON pges_events;

CREATE TRIGGER pges_set_event_aggregate_version_trigger
  AFTER INSERT ON pges_events
  FOR EACH ROW
  EXECUTE PROCEDURE pges_set_event_aggregate_version();



