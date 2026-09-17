CREATE PROCEDURE "informix".genmov_calif_cnr( p_empresa                CHAR(3),
											   p_num_credito            CHAR(20),
											   p_num_producto           CHAR(4),
											   p_codigo_ref             INTEGER,
											   p_codigo_fun             CHAR(3),
											   p_fecha_hoy              DATE,
											   p_monto                  MONEY(14,2),
											   p_foliosuc               CHAR(16),
											   p_sucursal               CHAR(4),
											   p_divisa                 CHAR(2),
											   p_transacc_suc           CHAR(4))
RETURNING CHAR(10), CHAR(80);

DEFINE cCodret        CHAR(10);
DEFINE cMensaje       CHAR(80);
DEFINE cPlaza         CHAR(3);
DEFINE dtHora         DATETIME HOUR TO FRACTION(3);
DEFINE cReversado     CHAR(1);
DEFINE cUsuario       CHAR(8);
DEFINE cNumProducto   CHAR(4);
DEFINE iCodigoRef     INTEGER;
DEFINE cCodigoFun     CHAR(3);
DEFINE dtFechaHoy     DATE;
DEFINE dMonto         DECIMAL(18,2);
DEFINE cFolioSuc      CHAR(16);
DEFINE cSucursal      CHAR(4);
DEFINE cDivisa        CHAR(2);
DEFINE cTransaccSuc   CHAR(4);
DEFINE iSqlErr        INTEGER;
DEFINE iIsamErr       INTEGER;
DEFINE cErrorInfo     CHAR(80);
DEFINE iCadena        INTEGER;
DEFINE cSucOri        CHAR(4);

LET cCodret       = '00000';
LET cMensaje      = 'PROCESO EXITOSO';
LET cNumProducto  =  p_num_producto ;
LET iCodigoRef    =  p_codigo_ref   ;
LET cCodigoFun    =  p_codigo_fun   ;
LET dtFechaHoy    =  p_fecha_hoy    ;
LET dMonto        =  p_monto        ;
LET cFolioSuc     =  p_foliosuc     ;
LET cSucursal     =  p_sucursal     ;
LET cDivisa       =  p_divisa       ;
LET cTransaccSuc  =  p_transacc_suc ;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = "";
LET cSucOri       = "";

BEGIN
   ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodret  = iSqlErr;
      LET cMensaje  = cErrorInfo;
      RETURN cCodret, cMensaje;
   END EXCEPTION;

--SET DEBUG FILE TO "/respaldosbd/hectorb/genmov_calif_cnr.out";
--TRACE ON;

   IF (p_transacc_suc IS NULL) THEN
      LET cTransaccSuc = '0000';
   END IF;
   
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
   IF (dtFechaHoy IS NULL) THEN
      SELECT fecha_hoy
      INTO   dtFechaHoy
      FROM   bdicred:"informix".sd_fechas;
   END IF;
   
   IF (dMonto IS NULL) THEN
      LET dMonto = 0;
   END IF;
   
   IF (cDivisa IS NULL) THEN
      LET cDivisa = '00';
   END IF;
   
   IF (cNumProducto IS NULL) THEN
      LET cNumProducto = '    ';
   END IF;

   IF (cFolioSuc IS NULL) THEN
      LET cCodret = '110';
      LET cMensaje = 'ERROR';
      RETURN cCodret, cMensaje;
   END IF;

   LET cCodret     = '00000';
   LET cMensaje    = 'PROCESO EXITOSO';
   LET dtHora      = EXTEND(CURRENT,HOUR TO fraction(3));
   LET cReversado  = 'N';
   LET iCadena     = 0;
   let iCadena     = LENGTH(p_foliosuc) - 8;
   LET cUsuario    = SUBSTR(p_foliosuc,1,iCadena);


   --############################################################
   --####  GENERACION DE MOVIMIENTOS Y DETALLE CONTABLE     #####
   --############################################################
 

   SELECT plaza
   INTO   cPlaza
   FROM   bdinteg:"informix".si_sucursales
   WHERE  empresa  = p_empresa
   AND    sucursal = cSucursal;

   IF cPlaza IS NULL OR cPlaza = '' THEN
      LET cCodret  = '00100';
      LET cMensaje = 'LA INFORMACION PLAZA/SUCURSAL DEL CREDITO ES INCORRECTA';
      RETURN cCodret, cMensaje;
   END IF;

   SELECT sucursal INTO cSucOri
     FROM bdicred:"informix".sd_maecredcrd
    WHERE empresa     = p_empresa
      AND num_credito = p_num_credito;

   INSERT INTO bdicred:"informix".sd_movhis_calif_cnr (
				EMPRESA        ,
				FECHA_MOV      ,
				HORA_MOV       ,
				SUCURSAL       ,
				NUM_CREDITO    ,
				PLAZA          ,
				TRANSACC_SUC   ,
				USUARIO        ,
				MONTO          ,
				CODIGO_FUN     ,
				CODIGO_REF     ,
				DIVISA         ,
				REVERSADO      ,
				FOLIO_SUC      ,
				NUM_PRODUCTO   ,
				SUC_ORIGEN     )
		VALUES (p_empresa,
				dtFechaHoy,
				current,
				cSucursal,
				p_num_credito,
				cPlaza,
				cTransaccSuc,
				cUsuario,
				dMonto,
				cCodigoFun,
				iCodigoRef,
				cDivisa,
				cReversado,
				cFolioSuc,
				cNumProducto,
				cSucOri);

   RETURN cCodret, cMensaje;

END;
END PROCEDURE
;