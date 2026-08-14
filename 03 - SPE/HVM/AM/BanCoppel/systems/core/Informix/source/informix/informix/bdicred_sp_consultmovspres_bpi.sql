CREATE PROCEDURE "informix".sp_consultmovspres_bpi(pEmpresa CHAR(3), pNumCredito CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro INTEGER)
RETURNING CHAR(6)            AS codigo_retorno,
          DATE               AS fecha_movto,
		  VARCHAR(100,1)     AS concepto,
		  DECIMAL(18,2)      AS monto_cargo,
		  DECIMAL(18,2)      AS monto_abono;
		  
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      CHAR(80);
DEFINE cCodRet         CHAR(6); 
DEFINE cMensajeRet     CHAR(80);

DEFINE iSerial         INTEGER;
DEFINE dtFechaMov      DATE;
DEFINE vRefTotal       VARCHAR(100,1);
DEFINE vDescripcion    VARCHAR(100,1);
DEFINE vNaturaleza     CHAR(1);
DEFINE dMonto          DECIMAL(18,2);
DEFINE vReferencia23   VARCHAR(50,1);
DEFINE vRfcComer       VARCHAR(50,1);
DEFINE cTransaccion    CHAR(4);
DEFINE dMontoCargo     DECIMAL(18,2);
DEFINE dMontoAbono     DECIMAL(18,2);
DEFINE cNumProducto    CHAR(4);
DEFINE cTpSolicitud    CHAR(1);

LET cCodRet            = "000000";
LET cMensajeRet        = "Se realizo la consulta correctamente";

LET iSerial            = 0;
LET dtFechaMov         = DATE(1);
LET vRefTotal          = "";
LET vDescripcion       = "";
LET vNaturaleza        = "";
LET dMonto             = 0;
LET vReferencia23      = "";
LET vRfcComer          = "";
LET cTransaccion       = "";
LET dMontoCargo        = 0;
LET dMontoAbono        = 0;
LET cNumProducto       = "";
LET cTpSolicitud       = "";


 -- *****************************************************************************************************        
   -- Obejtivo:            Consulta de Movimietos de los productos de ('6400', '7600','7700','6300','6400','7800' )
   -- Creado por:			Paul Quintero
   -- Solicitado por: 		Alejandro Vazquez   
   -- Fecha: 				06/04/2017
   -- *****************************************************************************************************



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0);
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO '/informix/paulq/pruebas/sp_consultmovspres_bpi.out';
-- TRACE ON;


FOREACH WITH HOLD
	SELECT a.num_producto, b.cod_prod
	INTO cNumProducto, cTpSolicitud
	  FROM "informix".sd_maecred a, "informix".sd_tipprod b 
	 WHERE a.num_credito = pNumCredito
	   AND a.empresa = pEmpresa
	   AND b.abrevia_prod = a.num_producto 
	   AND b.empresa = a.empresa
UNION
		SELECT a.num_producto, b.cod_prod
		  FROM "informix".sd_maecredcrd a, "informix".sd_tipprod b
		 WHERE a.num_credito = pNumCredito
		   AND a.empresa = pEmpresa
		   AND b.abrevia_prod = a.num_producto 
		   AND b.empresa = a.empresa
END FOREACH;

IF TRIM(NVL(cTpSolicitud,'')) = '' THEN
	   LET cCodRet = "000001"; --No existe el crèdito indicado.
	   RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0);		 
END IF;


IF TRIM(NVL(cTpSolicitud,'')) = 'T' THEN

	FOREACH WITH HOLD
		(SELECT SKIP pRegistro FIRST 10
					secuencia, fecha_mov, CASE WHEN NVL(TRIM(a.referencia),'') = '' THEN c.transacc ELSE TRIM(a.referencia) END CASE, c.descripcion, naturaleza, 
					monto, a.referencia23, a.rfc_comer, b.numero
				 INTO iSerial, dtFechaMov, vRefTotal, vDescripcion, vNaturaleza,
					  dMonto, vReferencia23, vRfcComer, cTransaccion
				 FROM "informix".sd_movdia a, bdinteg:"informix".si_transacc b, "informix".sd_transfun c
				 WHERE a.empresa = pEmpresa
				 AND a.num_credito = pNumCredito
				 AND c.empresa = a.empresa
			 AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
				 AND b.empresa = c.empresa
				 AND b.numero = c.transacc
				 AND b.sistema = "06"
				 AND b.se_emite_edocta = "S"
				 AND a.reversado = "N"
				 AND fecha_mov >= pFechaInicial
				 AND fecha_mov <= pFechaFinal
		 UNION
				SELECT secuencia, fecha_mov, CASE WHEN NVL(TRIM(a.referencia),'') = ''
					THEN c.transacc ELSE TRIM(a.referencia) END CASE, c.descripcion,
					naturaleza, monto, a.referencia23, a.rfc_comer, b.numero
				 FROM "informix".sd_movhis a, bdinteg:"informix".si_transacc b, "informix".sd_transfun c
				 WHERE a.empresa = pEmpresa
				 AND a.num_credito = pNumCredito
				 AND c.empresa = a.empresa
			 AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
				 AND b.empresa = c.empresa
				 AND b.numero = c.transacc
				 AND b.se_emite_edocta = "S"
				 AND a.reversado = "N"
				 AND fecha_mov >= pFechaInicial
				 AND fecha_mov <= pFechaFinal)
		 ORDER BY fecha_mov,secuencia
		 
		 IF TRIM(NVL(vNaturaleza,'')) = "C" THEN 
			LET dMontoCargo = NVL(dMonto,0);
		 ELSE 
			LET dMontoAbono = NVL(dMonto,0);
		 END IF;	 
		 
		 RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0) WITH RESUME;
		 
		 LET dMontoCargo = 0;
		 LET dMontoAbono = 0; 
		 LET dMonto = 0;
		 
	END FOREACH;
	
	IF DBINFO("sqlca.sqlerrd2") <=	0 THEN
	   LET cCodRet = "000003"; --No hay registros con el filtro de consulta indicado.
	   RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0);		 
	END IF;


ELSE

	FOREACH WITH HOLD
		(SELECT SKIP pRegistro FIRST 10
					secuencia, fecha_mov, CASE WHEN NVL(TRIM(a.referencia),'') = '' THEN c.transacc ELSE TRIM(a.referencia) END CASE, c.descripcion, naturaleza, 
					monto, a.referencia23, a.rfc_comer, b.numero
				 INTO iSerial, dtFechaMov, vRefTotal, vDescripcion, vNaturaleza,
					  dMonto, vReferencia23, vRfcComer, cTransaccion
				 FROM "informix".sd_movdiacrd a, bdinteg:"informix".si_transacc b, "informix".sd_transfun c
				 WHERE a.empresa = pEmpresa
				 AND a.num_credito = pNumCredito
				 AND c.empresa = a.empresa
			 AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
				 AND b.empresa = c.empresa
				 AND b.numero = c.transacc
				 AND b.sistema = "06"
				 AND b.se_emite_edocta = "S"
				 AND a.reversado = "N"
				 AND fecha_mov >= pFechaInicial
				 AND fecha_mov <= pFechaFinal
		 UNION
				SELECT secuencia, fecha_mov, CASE WHEN NVL(TRIM(a.referencia),'') = ''
					THEN c.transacc ELSE TRIM(a.referencia) END CASE, c.descripcion,
					naturaleza, monto, a.referencia23, a.rfc_comer, b.numero
				 FROM "informix".sd_movhiscrd a, bdinteg:"informix".si_transacc b, "informix".sd_transfun c
				 WHERE a.empresa = pEmpresa
				 AND a.num_credito = pNumCredito
				 AND c.empresa = a.empresa
			 AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
				 AND b.empresa = c.empresa
				 AND b.numero = c.transacc
				 AND b.se_emite_edocta = "S"
				 AND a.reversado = "N"
				 AND fecha_mov >= pFechaInicial
				 AND fecha_mov <= pFechaFinal)
		 ORDER BY fecha_mov,secuencia
		 
		 IF TRIM(NVL(vNaturaleza,'')) = "C" THEN 
			LET dMontoCargo = NVL(dMonto,0);
		 ELSE 
			LET dMontoAbono = NVL(dMonto,0);
		 END IF;	 
		 
		 RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0) WITH RESUME;
		 
		 LET dMontoCargo = 0;
		 LET dMontoAbono = 0; 
		 LET dMonto = 0;
		 
	END FOREACH;
	
	IF DBINFO("sqlca.sqlerrd2") <=	0 THEN
	   LET cCodRet = "000003"; --No hay registros con el filtro de consulta indicado.
	   RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0);		 
	END IF;
	
END IF;

END
END PROCEDURE;