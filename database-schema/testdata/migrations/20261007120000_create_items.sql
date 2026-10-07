-- Test fixture: what a service's first migration looks like.
CREATE TABLE items (
  id         bigserial PRIMARY KEY,
  name       text        NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
