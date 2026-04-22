-- Update admin password to 'admin1234' (BCrypt hash of 'admin1234')
UPDATE hirafi_db.users
SET password = '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGniYE6Nd.NumkQDmm3QIYkMhTe'
WHERE email = 'admin@hirafi.com';

-- Also check artisan status - set to ACTIVE so they can login
UPDATE hirafi_db.users
SET status = 'ACTIVE'
WHERE email = 'artisan@hirafi.com';

SELECT id, email, role, status FROM hirafi_db.users;
