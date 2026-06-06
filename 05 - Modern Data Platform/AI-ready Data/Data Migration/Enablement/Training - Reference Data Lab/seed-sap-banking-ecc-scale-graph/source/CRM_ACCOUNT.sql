-- CRM_ACCOUNT  ·  crm  ·  arquetipo MASTER  ·  fan-in=29
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CRM_ACCOUNT (
  CRMID            CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  SAP_PARTNER_REF  CHAR(10)  ,  -- -> BUT000 (entity-link; NO hay FK declarada)
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
