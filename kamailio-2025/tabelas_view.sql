CREATE TABLE public.dominio (
    id SERIAL,
    fqdn character varying(255)
);

CREATE VIEW public.vw_kamailio_domain AS
 SELECT DISTINCT dominio.fqdn,
    NULL::text AS did
   FROM public.dominio;
   
CREATE TABLE public.pabx (
    id SERIAL,
    endereco_ip character varying(255) NOT NULL,
    porta INTEGER NOT NULL
);
   
CREATE VIEW public.vw_kamailio_server AS
 SELECT pabx.id || '_sip'::text AS key_name,
    0 AS key_type,
    0 AS value_type,
    (pabx.endereco_ip::text || ':'::text) || pabx.porta AS key_value,
    0 AS expires
   FROM pabx;
   
CREATE TABLE public.endpoint (
  id SERIAL,
  login INTEGER NOT NULL,
  senha VARCHAR(255) NOT NULL,
  dominio INTEGER NOT NULL,
  pabx INTEGER NOT NULL
);

CREATE VIEW public.vw_kamailio_users AS
 SELECT e.id,
    e.login,
    e.senha,
    d.fqdn as dominio,
    (p.endereco_ip::text || ':'::text) || p.porta AS pabx
 FROM endpoint e
     JOIN dominio d ON d.id = e.dominio
     JOIN pabx p ON p.id = e.pabx;

ALTER TABLE acc ADD COLUMN src_user VARCHAR(64) NOT NULL DEFAULT '';
ALTER TABLE acc ADD COLUMN src_domain VARCHAR(128) NOT NULL DEFAULT '';
ALTER TABLE acc ADD COLUMN src_ip varchar(64) NOT NULL default '';
ALTER TABLE acc ADD COLUMN dst_ouser VARCHAR(64) NOT NULL DEFAULT '';
ALTER TABLE acc ADD COLUMN dst_user VARCHAR(64) NOT NULL DEFAULT '';
ALTER TABLE acc ADD COLUMN dst_domain VARCHAR(128) NOT NULL DEFAULT '';
ALTER TABLE missed_calls ADD COLUMN src_user VARCHAR(64) NOT NULL DEFAULT '';
ALTER TABLE missed_calls ADD COLUMN src_domain VARCHAR(128) NOT NULL DEFAULT '';
ALTER TABLE missed_calls ADD COLUMN src_ip varchar(64) NOT NULL default '';
ALTER TABLE missed_calls ADD COLUMN dst_ouser VARCHAR(64) NOT NULL DEFAULT '';
ALTER TABLE missed_calls ADD COLUMN dst_user VARCHAR(64) NOT NULL DEFAULT '';
ALTER TABLE missed_calls ADD COLUMN dst_domain VARCHAR(128) NOT NULL DEFAULT '';

insert into version(table_name,table_version) values ('vw_kamailio_domain',2);
