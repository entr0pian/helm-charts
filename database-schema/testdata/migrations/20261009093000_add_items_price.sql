-- Additive change: safe to apply before the code that uses it.
ALTER TABLE items ADD COLUMN price_cents integer;
