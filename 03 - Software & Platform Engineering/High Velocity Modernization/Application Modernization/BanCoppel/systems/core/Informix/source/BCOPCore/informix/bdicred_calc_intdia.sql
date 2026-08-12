CREATE PROCEDURE "informix".calc_intdia(enum_credito CHAR(20))
RETURNING CHAR(5), DECIMAL(16,2), SMALLINT;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_tasa       DECIMAL(8,6);
DEFINE v_tpcred     CHAR(2);
DEFINE v_capital    MONEY(14,2);
DEFINE v_hoy        DATE;
DEFINE v_cuota1	    DATE;
DEFINE v_cuotavig   DATE;
DEFINE v_fechacalc  DATE;
DEFINE ax_intdia    DECIMAL(16,2);
DEFINE ax_difint    DECIMAL(16,2);
DEFINE ax_diascalc  SMALLINT;
DEFINE v_diasano    SMALLINT;
DEFINE v_status     CHAR(1);
DEFINE v_intant     DECIMAL(16,2);
define existe       smallint;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "00000";
LET vsqlerr      = 0;
LET ax_intdia    = 0;
LET ax_diascalc  = 0;
LET ax_difint    = 0;
LET v_intant     = 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, ax_intdia, ax_diascalc;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	IF SUBSTR(enum_credito,10,3) = "410" THEN
  IF NOT EXISTS  (select num_credito from sd_maecred where num_credito = enum_credito) then
          SELECT {+INDEX (sd_maesdoscrd idx_maesdoscrd1)} sdo_no_exig, dias_acum_int
	 	  INTO ax_intdia, ax_diascalc
	 	  FROM sd_maesdoscrd
		 WHERE num_credito = enum_credito AND empresa='001';
         else
          SELECT sdo_no_exig, dias_acum_int
	 	  INTO ax_intdia, ax_diascalc
	 	  FROM sd_maesdos
		 WHERE num_credito = enum_credito;
         end if
		 RETURN scod_ret, ax_intdia, ax_diascalc;
	END IF
  IF NOT EXISTS  (select num_credito from sd_maecred where num_credito = enum_credito) then
	SELECT {+INDEX (sd_maesdoscrd idx_maesdoscrd1) +INDEX (sd_definicioncrd definicioncrd1)}
               a.tasa_interes / 100, cod_tipcred, sdo_capital	
	  INTO v_tasa, v_tpcred, v_capital
	  FROM sd_maecredcrd a, sd_definicioncrd b, sd_maesdoscrd c
	 WHERE a.num_producto = b.num_producto and b.empresa='001'
	   AND c.num_credito = a.num_credito and c.empresa='001'
	   AND a.num_credito = enum_credito;
         let existe = 1;
  else
	SELECT a.tasa_interes / 100, cod_tipcred, sdo_capital	
	  INTO v_tasa, v_tpcred, v_capital
	  FROM sd_maecred a, sd_definicion b, sd_maesdos c
	 WHERE a.num_producto = b.num_producto
	   AND c.num_credito = a.num_credito
	   AND a.num_credito = enum_credito;
         let existe = 2;
  end if

	IF v_tpcred = "01" OR v_tpcred = "04" THEN
		LET v_diasano = 365;
	ELSE
		LET v_diasano = 360;
	END IF

	SELECT {+INDEX (sd_fechas idx_sdfechas)} fecha_hoy INTO v_hoy FROM sd_fechas where empresa='001';
      if existe = 1 then
	SELECT {+INDEX(sd_amortiza_creditocrd amorx)} MIN(fecha_cuota) INTO v_cuota1
	  FROM sd_amortiza_creditocrd
	 WHERE num_credito = enum_credito and empresa='001';
        SELECT NVL(MIN(fecha_cuota),"01/01/1800")
          INTO v_cuotavig
          FROM sd_amortiza_creditocrd, sd_fechas
         WHERE fecha_cuota >= fecha_hoy
           AND num_credito = enum_credito
	   AND (capital_status ="1" or interes_status = "1");
      else
	SELECT {+INDEX (sd_amortiza_credito amor1)} MIN(fecha_cuota) INTO v_cuota1
	  FROM sd_amortiza_credito
	 WHERE num_credito = enum_credito and empresa='001';
        SELECT NVL(MIN(fecha_cuota),"01/01/1800")
          INTO v_cuotavig
          FROM sd_amortiza_credito, sd_fechas
         WHERE fecha_cuota >= fecha_hoy
           AND num_credito = enum_credito
	   AND (capital_status ="1" or interes_status = "1");
      end if
	IF v_cuotavig = "01/01/1800" THEN
		RETURN scod_ret, ax_intdia, ax_diascalc;
	END IF

      if existe = 1 then
	SELECT {+INDEX (sd_amortiza_creditocrd amor2sx)} interes_status, interes_pagado 
	  INTO v_status , ax_difint
	  FROM sd_amortiza_creditocrd 
	 WHERE num_credito = enum_credito and empresa='001'
	   AND fecha_cuota = v_cuotavig;
      else
	SELECT {+INDEX (sd_amortiza_credito amor1)} interes_status, interes_pagado 
	  INTO v_status , ax_difint
	  FROM sd_amortiza_credito 
	 WHERE num_credito = enum_credito
	   AND fecha_cuota = v_cuotavig and empresa='001'; 
      end if

	IF v_status = "5" THEN
		RETURN scod_ret, ax_intdia, ax_diascalc;
	END IF


	IF v_cuotavig = v_cuota1 THEN
           if existe = 1 then
		SELECT {+INDEX (sd_maecredcrd idx_maecrd)} fecha_apertura INTO v_fechacalc 
		  FROM sd_maecredcrd
		 WHERE num_credito = enum_credito and empresa='001';
           else
		SELECT fecha_apertura INTO v_fechacalc 
		  FROM sd_maecred
		 WHERE num_credito = enum_credito;
           END IF
		IF v_fechacalc = v_hoy THEN
			RETURN scod_ret, ax_intdia, ax_diascalc;
		END IF

	ELSE
           if existe = 1 then
		SELECT {+INDEX(sd_amortiza_creditocrd amor2sx)} MAX(fecha_cuota) INTO  v_fechacalc  
		  FROM sd_amortiza_creditocrd 
		 WHERE num_credito = enum_credito 
		   AND fecha_cuota < v_cuotavig and empresa='001';
           else
		SELECT {+INDEX (sd_amortiza_credito amor1)} MAX(fecha_cuota) INTO  v_fechacalc  
		  FROM sd_amortiza_credito 
		 WHERE num_credito = enum_credito 
		   AND fecha_cuota < v_cuotavig and empresa='001';
           END IF
	END IF


	LET ax_diascalc = v_hoy - v_fechacalc ;
	IF ax_diascalc <=0 then
		RETURN scod_ret, ax_intdia, ax_diascalc;
	END IF


	LET ax_intdia = ((v_capital * v_tasa) / v_diasano) * ax_diascalc ;
	LET ax_intdia = ax_intdia - ( ax_difint + v_intant);
	IF ax_intdia < 0 THEN
		LET ax_difint = 0;
	END IF
	
END
	RETURN scod_ret, ax_intdia, ax_diascalc;


END PROCEDURE DOCUMENT "Version 1.00.000";

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