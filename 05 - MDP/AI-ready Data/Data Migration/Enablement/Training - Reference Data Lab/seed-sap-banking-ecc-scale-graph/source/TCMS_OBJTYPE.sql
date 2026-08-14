-- TCMS_OBJTYPE  ·  Collateral (BCA)  ·  arquetipo MASTER  ·  fan-in=8
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE TCMS_OBJTYPE (
  MANDT            CLNT      ,  -- mandante (client)
  TCMSID           CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  COLID            CHAR(10)  ,  -- FK -> CMS250
  COLID2           CHAR(10)  ,  -- FK -> CMS233
  BUKRS            CHAR(4)   ,  -- FK -> T001
  COLID3           CHAR(10)  ,  -- FK -> CMS107
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
