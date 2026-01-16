-- Change the password column to a hash
ALTER TABLE users RENAME password TO password_hash;
