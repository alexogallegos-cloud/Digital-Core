CREATE PROCEDURE "informix".sp_genmovbitacoramovimientos(
                                               p_empresa                CHAR(3),
                                               p_num_credito            CHAR(20),
                                               p_tipo_movto             CHAR(2),
                                               p_campo_modificado       CHAR(20),
                                               p_saldo_anterior         DECIMAL(18,2),
                                               p_monto_a_modificar      DECIMAL(18,2),
                                               p_saldo_nuevo            DECIMAL(18,2),
                                               p_Justificacion          CHAR(100),
                                               p_user_insert            CHAR(20),
                                               p_fecha_insert           DATE )

RETURNING CHAR(6),CHAR(80);

DEFINE cCodRet            CHAR(6);
DEFINE cMensaje           CHAR(80);

DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);

DEFINE cEmpresa            CHAR(3);
DEFINE cNumCredito         CHAR(20);
DEFINE cTpoMovto           CHAR (2);
DEFINE cCampoModificado    CHAR (20);
DEFINE dSdoAnterior        DECIMAL (18,2);
DEFINE dMtoModificar       DECIMAL (18,2);
DEFINE dSdoNvo             DECIMAL (18,2);
DEFINE cJustificacion      CHAR (100);
DEFINE cUserInsert         CHAR (20);
DEFINE dtFechaInsert       DATE;

LET cEmpresa         = p_empresa;
LET cNumCredito      = p_num_credito;
LET cTpoMovto        = p_tipo_movto;
LET cCampoModificado = p_campo_modificado;
LET dSdoAnterior     = p_saldo_anterior ;
LET dMtoModificar    = p_monto_a_modificar;
LET dSdoNvo          = p_saldo_nuevo;
LET cJustificacion   = p_Justificacion;
LET cUserInsert      = p_user_insert;
LET dtFechaInsert    = p_fecha_insert;

-- Fecha Creacion: 13-02-2009
-- Autor: David Uriel Prieto Hurtado.
-- Observaciones: Se realiza sp para insertar movimiento dentro de la tabla "bdicred:sd_bitacoramovimientos".

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cCodRet= SQL_ERR;
      LET cMensaje= ERROR_INFO;
      RETURN cCodRet, cMensaje;
   END EXCEPTION;

SET LOCK MODE TO WAIT 3;

  -- Valida los parametros recibidos
   IF (p_tipo_movto IS NULL) THEN
      LET cCodRet = '000001';
      LET cMensaje = 'ERROR SIN TIPO DE MOVIMIENTO';
      RETURN cCodRet, cMensaje;
   ELIF (p_fecha_insert IS NULL) THEN
      SELECT fecha_hoy
        INTO dtFechaInsert
        FROM bdicred:sd_fechas;
   ELIF (p_campo_modificado IS NULL) THEN
      LET cCampoModificado = " ";
   ELIF (p_saldo_anterior IS NULL) THEN
      LET dSdoAnterior = 0;
   ELIF (p_monto_a_modificar IS NULL) THEN
      LET dMtoModificar = 0;
   ELIF (p_saldo_nuevo IS NULL) THEN
      LET dSdoNvo = 0;
   ELIF (p_Justificacion IS NULL) THEN
      LET cJustificacion = "";
   ELIF (p_user_insert IS NULL) THEN
      LET cUserInsert = "### ";
   END IF;

   LET cCodRet= '000000';
   LET cMensaje= 'PROCESO EXITOSO';

   --######################################################
   --####  GENERACION DE MOVIMIENTOS EN BITACORA      #####
   --######################################################

   INSERT INTO "informix".sd_bitacoramovimientos (empresa,
											   num_credito,
											   tipo_movto,
											   campo_modificado,
											   saldo_anterior,
											   monto_a_modificar,
											   saldo_nuevo,
											   justificacion,
											   user_insert,
											   fecha_insert )
                      VALUES (cEmpresa,
                              cNumCredito,
                              cTpoMovto,
                              cCampoModificado,
                              dSdoAnterior,
                              dMtoModificar,
                              dSdoNvo,
                              cJustificacion,
                              cUserInsert,
                              dtFechaInsert);

   RETURN cCodRet, cMensaje;

END;
END PROCEDURE;