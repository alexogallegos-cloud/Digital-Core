CREATE PROCEDURE "informix".sp_rep_reserva_interes(pEmpresa CHAR(3))
RETURNING 
          CHAR(6)  AS resultado,
          CHAR(80) AS mensaje;
    
DEFINE iSqlErr                      INTEGER;
DEFINE iIsamErr                     INTEGER;
DEFINE cErrorInfo                   CHAR(80);
DEFINE cCodRet                      CHAR(6); 
DEFINE cMensajeRet                  CHAR(80);

DEFINE cEmpresa                     CHAR(3);
DEFINE dtFechaHoy                   DATE;
DEFINE dtFechaCierre                DATE;
DEFINE cNombreArchivo               CHAR(30);
DEFINE cNombreArchivoAux            CHAR(30);
DEFINE cSentencia                   CHAR(5000);
DEFINE var_rga                      CHAR(5);
DEFINE cSql                         CHAR(5024);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      LET cSentencia = '';
      LET cSentencia = 'rm infor.sql ' || cNombreArchivoAux;
      SYSTEM cSentencia;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

LET iSqlErr           = 0;
LET iIsamErr          = 0;
LET cErrorInfo        = '';
LET cCodRet           = '000000';
LET cMensajeRet       = 'El archivo RESERVAS POR INTERES se generó correctamente';

LET cEmpresa          = '';
LET dtFechaHoy        = DATE(1);
LET dtFechaCierre     = DATE (1);
LET cNombreArchivo    = '';
LET cNombreArchivoAux = 'his_res_temp';
LET cSql              = '';

 --SET DEBUG FILE TO "sp_reporte_reserva_interes.out";
 --TRACE ON;

     SELECT empresa
       INTO cEmpresa     
       FROM bdinteg:si_empresas 
      WHERE empresa= pEmpresa;
      
      IF cEmpresa IS NULL THEN
          LET cCodRet = '000001';
          LET cMensajeRet = 'El parámetro no es valido';
          RETURN cCodRet, cMensajeRet;
      END IF;

      SELECT fecha_hoy,
	         DECODE( MONTH(fecha_hoy - 1 UNITS MONTH),
                    "1","enero","2","febrero","3","marzo",
              		"4","abril","5","mayo","6","junio",
              		"7","julio","8","agosto","9","septiembre",
               		"10","octubre","11","noviembre","12","diciembre")
        INTO dtFechaHoy, cNombreArchivo
        FROM "informix".sd_fechas
        WHERE empresa = pEmpresa;
		
      LET dtFechaCierre = DATE(MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy))- 1 UNITS DAY);

	  LET cNombreArchivo = 'his_res_'|| TRIM(cNombreArchivo) || '_' || YEAR(dtFechaCierre) || ".txt";      

      LET cSentencia = '';
      LET cSentencia = ' UNLOAD TO ' || cNombreArchivoAux ;
      CALL sp_genera_archivo ('infor.sql',cSentencia) returning var_rga;
      
      LET cSentencia =  ' SELECT a.num_credito, monto, codigo_fun, codigo_ref, fecha_mov, num_periodos, calif_actual, porcentaje ';
      CALL sp_genera_archivo ('infor.sql',cSentencia) returning var_rga;
      
      LET cSentencia = ' FROM bdicred:sd_movhis a ';
      CALL sp_genera_archivo ('infor.sql',cSentencia) returning var_rga;
      
      LET cSentencia = ' LEFT OUTER JOIN bdicred:sd_histvalcon b ' ;
      CALL sp_genera_archivo ('infor.sql',cSentencia) returning var_rga;
      
      LET cSentencia = ' ON"("b.empresa = a.empresa AND a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_alta = a.fecha_mov")"'; 
      CALL sp_genera_archivo ('infor.sql',cSentencia) returning var_rga;
      
      LET cSentencia = ' WHERE a.empresa = ' || '''"''' || cEmpresa || '''"''';
      CALL sp_genera_archivo ('infor.sql',cSentencia) returning var_rga;
      
      LET cSentencia = ' AND codigo_fun = ' || '''"''' || 661 || '''"''';
      CALL sp_genera_archivo ('infor.sql',cSentencia) returning var_rga;
      
      LET cSentencia = '  AND codigo_ref IN '|| '"("50,51")"' ;
      CALL sp_genera_archivo ('infor.sql',cSentencia) returning var_rga;
     
      LET cSentencia = ' "AND a.fecha_mov = ' || '''' || dtFechaCierre || '''' || '"' ;
      CALL sp_genera_archivo ('infor.sql',cSentencia) returning var_rga;
      
      LET cSentencia = '';
      LET cSentencia = 'dbaccess bdicred infor.sql';
      SYSTEM cSentencia;

      LET cSentencia = "sed 's/|$//g' " || cNombreArchivoAux || ' > ' || cNombreArchivo;
      SYSTEM cSentencia;

      LET cSentencia = '';
  
      LET cSentencia = 'rm infor.sql ' || cNombreArchivoAux;
      SYSTEM cSentencia;
      
      RETURN cCodRet, cMensajeRet;
    
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para:',
'Reporte de la reserva por interes',
'AUTOR : Roque Enrique Solis C.',
'FECHA : 09/JULIO/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_actualizaivaintvdo( pEmpresa      CHAR(3),
                                                   pNumCred      CHAR(20),
                                                   pSaldo        DECIMAL (18,2)
                                                  )

RETURNING
   CHAR(6),
   CHAR (80);


-- Autor: David Uriel Prieto Hurtado
-- Fecha de Creacion 11/02/2009
-- Observaciones: Se realiza procedimiento para realizar la modificaciól iva de
--  Vencido.

DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE cCodRet            CHAR(6);
DEFINE cMensajeRet        CHAR(80);

DEFINE cStatusCred        CHAR(2);
DEFINE dtFechaCuota       DATE;
DEFINE dIvaMes            DECIMAL(18,2);
DEFINE dIvaDebe           DECIMAL(18,2);
DEFINE dIvaPagado         DECIMAl(18,2);
DEFINE dSdoModificar      DECIMAL(18,2);
DEFINE iBanIvaPagado      INTEGER;
DEFINE dtFechaCuotaAct    DATE;
DEFINE dtFechaUltPag      DATE;
DEFINE cSdoAfectado       CHAR(20);
DEFINE dMtoActual         DECIMAL(18,2);
DEFINE dMtoFinal          DECIMAL(18,2);
DEFINE d_resta            DECIMAL (18,2);
DEFINE d_ivaIntVenc       DECIMAL (18,2);
DEFINE dAbono             DECIMAL(18,2);
DEFINE dPagoIva           DECIMAL(18,2);
DEFINE cMovimiento        CHAR(2);


LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
Let cCodRet               = '000000';
Let cMensajeRet           = 'SE REALIZO LA OPERACION CORRECTAMENTE';

LET cStatusCred           = "";
LET dtFechaCuota          = DATE(1);
LET dIvaMes               = 0;
LET dIvaDebe              = 0;
LET dIvaPagado            = 0;
LET dSdoModificar         = pSaldo;
LET dtFechaCuotaAct       = DATE(1);
LET dtFechaUltPag         = DATE(1);
LET cSdoAfectado          = '';
LET dMtoActual            = 0;
LET dMtoFinal             = 0;
LET d_resta               = 0;
LET d_ivaIntVenc          = 0;
LET dAbono                = 0;
LET dPagoIva              = 0;
LET cMovimiento           = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/tmp/sp_actualizaivaintvdo.out";
--TRACE ON;

  SELECT fecha_hoy
    INTO dtFechaCuotaAct
    FROM "informix".sd_fechas
    WHERE empresa = pEmpresa;

    IF DAY(dtFechaCuotaAct) <= 20 THEN
       LET dtFechaCuotaAct = MDY(MONTH(dtFechaCuotaAct - 1 UNITS MONTH),20, YEAR(dtFechaCuotaAct));
	ELSE
	   LET dtFechaCuotaAct = MDY(MONTH(dtFechaCuotaAct),20, YEAR(dtFechaCuotaAct));
    END IF;

     SELECT status_cred
       INTO cStatusCred
       FROM "informix".sd_maecred
      WHERE empresa     = pEmpresa
        AND num_credito = pNumCred;
       

       SELECT nvl(SUM(b.iva_debe - b.iva_pagado),0)
     INTO dIvaMes
     FROM "informix".sd_amortiza_credito b
    WHERE b.empresa = pEmpresa
      AND b.num_credito = pNumCred
      AND capital_status = '1';

    SELECT nvl(SUM(iva_debe - iva_pagado),0)
	  INTO d_ivaIntVenc
	  FROM "informix".sd_amortiza_credito
	 WHERE empresa = pEmpresa
       AND num_credito = pNumCred
       AND capital_status IN ("2")
       AND fecha_cuota <= dtFechaCuotaAct;

      /* IF cStatusCred IN ('BT') THEN
          IF pSaldo > 0 THEN
            LET d_ivaIntVenc = d_ivaIntVenc - dIvaMes;
          END IF;
       END IF;*/
      
IF pSaldo >= d_ivaIntVenc THEN  -- Identificador de la realizacióe un abono

      LET cMovimiento = 'C';
      
      SELECT MAX(fecha_cuota)
        INTO dtFechaUltPag
        FROM "informix".sd_amortiza_credito
       WHERE empresa = pEmpresa
         AND num_credito = pNumCred
         AND capital_status = "2"
         AND fecha_cuota <= dtFechaCuotaAct;
         
         IF dtFechaUltPag IS NULL THEN
            SELECT MAX(fecha_cuota)
              INTO dtFechaUltPag
              FROM "informix".sd_amortiza_credito
             WHERE empresa = pEmpresa
              AND  num_credito = pNumCred
               AND  capital_status = "5"
               AND fecha_cuota <= dtFechaCuotaAct;
            
            --LET dtFechaUltPag= dtFechaCuotaAct - 1 UNITS MONTH;
         END IF;

      UPDATE "informix".sd_amortiza_credito
         SET iva_debe =  dSdoModificar - d_ivaIntVenc + iva_debe,
             capital_status= CASE WHEN capital_status IN ("5") THEN "2" ELSE capital_status END
       WHERE empresa = pEmpresa
          AND num_Credito= pNumCred
         AND fecha_cuota= dtFechaUltPag;   --dtFechaCuotaAct - 1 UNITS MONTH;
ELSE
    LET cMovimiento = 'A';
    LET dAbono = d_ivaIntVenc - pSaldo;

    FOREACH

        SELECT fecha_cuota, iva_debe, iva_pagado
          INTO dtFechaCuota, dIvaDebe, dIvaPagado
          FROM "informix".sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = pNumCred
           AND capital_status in  ("2")
           AND fecha_cuota <= dtFechaCuotaAct
         ORDER BY fecha_cuota ASC

        IF dAbono > 0 then
             IF dAbono > (dIvaDebe- dIvaPagado) THEN
                  LET dAbono = dAbono - (dIvaDebe - dIvaPagado);
                  LET dPagoIva = dIvaDebe ;
             ELIF dAbono = (dIvaDebe- dIvaPagado) THEN
                  LET dPagoIva = dIvaDebe;
                  LET dAbono = dAbono - dAbono ;
             ELIF  dAbono < (dIvaDebe- dIvaPagado) THEN
                  LET dPagoIva =  dAbono + dIvaPagado;
                  LET dAbono = dAbono - dAbono;
             END IF;

             UPDATE "informix".sd_amortiza_credito
                   SET iva_pagado = dPagoIva
                       --capital_status = CASE WHEN iva_debe = dPagoIva THEN "5" ELSE capital_status END
                 WHERE empresa= pEmpresa
                   AND num_Credito= pNumCred
                   AND fecha_cuota= dtFechaCuota
                   AND capital_status IN ("2");
        ELSE
           EXIT FOREACH;
        END IF;
    END FOREACH;
END IF;
RETURN cCodRet,cMensajeRet;

END;
END PROCEDURE;