CREATE TABLE IF NOT EXISTS EFTM_inventories (
    steamid BIGINT PRIMARY KEY,
    inventory JSON,
    stash JSON
);
