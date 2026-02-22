-- Clean up old data with email-based approvers
-- This script removes all templates and requests to start fresh with UUID-based system

-- Delete all requests first (they depend on templates)
DELETE FROM requests;

-- Delete all templates
DELETE FROM templates;

-- Verify cleanup
SELECT 'Requests remaining: ' || COUNT(*) FROM requests;
SELECT 'Templates remaining: ' || COUNT(*) FROM templates;

-- Reset sequences if needed (PostgreSQL specific)
-- ALTER SEQUENCE requests_id_seq RESTART WITH 1;
-- ALTER SEQUENCE templates_id_seq RESTART WITH 1;
