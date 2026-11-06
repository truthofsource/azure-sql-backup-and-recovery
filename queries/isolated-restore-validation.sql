-- Read-only reference, for an already isolated owned target only.
-- A correct name does not itself prove custodian-only permissions or isolation.
IF DB_NAME() NOT LIKE N'restore-drill-%'
    THROW 51000, 'Expected an owned isolated restore database; stop.', 1;

SELECT COUNT(*) AS migration_entries, MAX(version) AS latest_lexical_migration
FROM dbo.schema_migrations;

SELECT COUNT(*) AS user_tables FROM sys.tables WHERE is_ms_shipped = 0;

SELECT COUNT(*) AS disabled_foreign_keys FROM sys.foreign_keys WHERE is_disabled = 1;
SELECT COUNT(*) AS untrusted_foreign_keys FROM sys.foreign_keys WHERE is_not_trusted = 1;

SELECT type_desc, authentication_type_desc, COUNT(*) AS principal_count
FROM sys.database_principals
WHERE principal_id > 4
GROUP BY type_desc, authentication_type_desc;
-- Aggregate catalog results are not row-by-row data validation, permission
-- acceptance, current schema compatibility or proof of an Azure restore.
