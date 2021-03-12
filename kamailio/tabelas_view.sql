INSERT INTO version(table_name,table_version) values('vw_kamailio_domain',2);

CREATE TABLE public.empresa (
  codigo SERIAL,
  ativo BOOLEAN NOT NULL,
  cpf_cnpj VARCHAR(255) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  CONSTRAINT empresa_pkey PRIMARY KEY(codigo)
) 
WITH (oids = false);

CREATE TABLE public.empresa_dominio (
  codigo SERIAL,
  dominio VARCHAR(255) NOT NULL,
  empresa INTEGER NOT NULL,
  CONSTRAINT empresa_dominio_pkey PRIMARY KEY(codigo),
  CONSTRAINT fk_empresa_dominio FOREIGN KEY (empresa)
    REFERENCES public.empresa(codigo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE
) 
WITH (oids = false);

CREATE TABLE public.servidor_voip (
  codigo SERIAL,
  ativo BOOLEAN NOT NULL,
  endereco_ip VARCHAR(255) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  CONSTRAINT servidor_voip_pkey PRIMARY KEY(codigo)
) 
WITH (oids = false);

CREATE TABLE public.ramal (
  codigo BIGSERIAL,
  nome VARCHAR(255) NOT NULL,
  numero INTEGER NOT NULL,
  senha VARCHAR(255),
  empresa INTEGER,
  servidor_voip INTEGER NOT NULL,
  CONSTRAINT ramal_pkey PRIMARY KEY(codigo),
  CONSTRAINT fk_empresa_ramal FOREIGN KEY (empresa)
    REFERENCES public.empresa(codigo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT fk_ramal_servidor_voip FOREIGN KEY (servidor_voip)
    REFERENCES public.servidor_voip(codigo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE
) 
WITH (oids = false);


CREATE OR REPLACE VIEW public.vw_kamailio_domain (
    dominio,
    did)
AS
SELECT d.dominio,
    NULL::text AS did
FROM empresa_dominio d;

CREATE OR REPLACE VIEW public.vw_kamailio_users (
    numero,
    senha,
    dominio,
    pabx)
AS
SELECT r.numero,
    r.senha,
    ed.dominio,
    s.endereco_ip AS pabx
FROM ramal r
     JOIN servidor_voip s ON r.servidor_voip = s.codigo
     JOIN empresa_dominio ed ON r.empresa = ed.empresa
WHERE r.empresa IS NOT NULL;

CREATE VIEW public.vw_kamailio_server (
    key_name,
    key_type,
    value_type,
    key_value,
    expires)
AS
SELECT (ku.numero || '@'::text) || ku.dominio::text AS key_name,
    0 AS key_type,
    0 AS value_type,
    ku.pabx AS key_value,
    0 AS expires
FROM vw_kamailio_users ku;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO kamailio;
