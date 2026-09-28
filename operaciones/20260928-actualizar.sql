
set search_path=base;

--tener en cuenta admin

CREATE SEQUENCE "lote_seq" START 1;
ALTER TABLE "lotes" ALTER COLUMN "lote" SET DEFAULT nextval('lote_seq'::regclass);
GRANT USAGE, SELECT ON SEQUENCE "lote_seq" TO ggs2026_admin;