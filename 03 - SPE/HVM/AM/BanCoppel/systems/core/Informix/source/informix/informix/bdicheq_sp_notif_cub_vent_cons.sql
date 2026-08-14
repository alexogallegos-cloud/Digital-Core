CREATE PROCEDURE "informix".sp_notif_cub_vent_cons(pNumreg INTEGER, pOp1 VARCHAR(50), pOp2 VARCHAR(50), pOp3 VARCHAR(50))
	RETURNING VARCHAR(5) AS iCodRet,
		      VARCHAR(50) as iMensaje,
		      VARCHAR(4) AS cSucursal,
		      VARCHAR(4) AS cTransacc,
		      VARCHAR(4) AS cTransacc_suc,
		      VARCHAR(20) AS cNumcte,
		      VARCHAR(20) AS cCuenta,
	      	  VARCHAR(16) AS cNum_tarjeta,
		      MONEY(14,2) AS cMonto_tot,
		      VARCHAR(16) AS cFolio_suc,
		      INTEGER AS cEstatus,
		      VARCHAR(50) AS cOp1,
		      VARCHAR(50) AS cOp2,
		      VARCHAR(50) AS cOp3;
	
	DEFINE iCodRet 		   VARCHAR(5);
	DEFINE iMensaje		   VARCHAR(50);
	DEFINE iSqlErr 		   INTEGER;	
	DEFINE cSucursal	   VARCHAR(4);
	DEFINE cTransacc       VARCHAR(4);
	DEFINE cTransacc_suc   VARCHAR(4);
	DEFINE cNumcte         VARCHAR(20);
    DEFINE cCuenta         VARCHAR(20);
    DEFINE cNum_tarjeta    VARCHAR(16);
	DEFINE cMonto_tot	   MONEY(14,2);
	DEFINE cFolio_suc      VARCHAR(16);
	DEFINE cEstatus		   INTEGER;
	DEFINE cNumreg		   INTEGER;
	DEFINE dFecha_Hoy      DATE;
	DEFINE cOp1			   VARCHAR(50);
	DEFINE cOp2			   VARCHAR(50);
	DEFINE cOp3			   VARCHAR(50);
    DEFINE lv_dFec_Hoy_Ini DATETIME YEAR TO SECOND; 
    DEFINE lv_dFec_Hoy_Fin DATETIME YEAR TO SECOND;  
    --
	LET iCodRet           = "00000";
	LET iMensaje          = "";
	LET iSqlErr           = 0;
	LET cSucursal         = '';
	LET cTransacc         = '';
	LET cTransacc_suc     = '';
	LET cNumcte           = '';
	LET cCuenta           = '';
	LET cNum_tarjeta      = '';
	LET cMonto_tot        = '';
	LET cFolio_suc        = '';
	LET cEstatus          = 0;
	LET cNumreg           = 0;
	LET cOp1              = '';
	LET cOp2              = '';
	LET cOp3              = '';
	LET dFecha_Hoy        = MDY('01','01','1900');
    LET lv_dFec_Hoy_Ini   = null;
    LET lv_dFec_Hoy_Fin   = null; 
	/* 'AUTOR:	      Concepcion Alvarez Carrillo',
       'FECHA:	      enero/2016',
       'DESCRIPCION: Se consulta los limites de deposito de la transaccion 204 y 209',
       'VERSION:     1.0',
       'BD: BDICHEQ';	
        No. ticket:          2198250
        Motivo modificaciÃ³n: Optimizar el SPL 
        â¢	Cambiar char por Varchar
        â¢	Uso del exists debido a que solo se valida que exista el registro
        â¢	Se eliminan variables que no aportan valor o que pueden ser reemplazadas por expresiones directas.
        ModificaciÃ³n por: Accenture
        Fecha: Julio/2025
               Oct/2025: Por observacion del Owner(Ivan LÃ³pez Escorza) se obtendran registros solo del dÃ­a fecha_insert = lv_dFecha_Hoy, se quita > */	


BEGIN
	ON EXCEPTION SET iSqlErr
       --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_notif_cub_vent_cons.out';
       --TRACE ON; 
	   IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			LET iMensaje = "Proceso NO Exitoso Error BD";
			
			RETURN iCodRet,iMensaje,cSucursal,cTransacc,cTransacc_suc,cNumcte,cCuenta,cNum_tarjeta,cMonto_tot,cFolio_suc,cEstatus,cOp1,cOp2,cOp3;
		END IF;
	 END EXCEPTION;	
	 
      -- Bloque de inicializaciÃ³n
     SET ISOLATION TO DIRTY READ;
	 SET LOCK MODE TO WAIT 3;
	 --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_notif_cub_vent_cons.out';
     --TRACE ON; 

      LET iCodRet = '00000';

      IF (pNumreg IS NULL OR pNumreg = 0) THEN
			LET iMensaje = 'Parametro de Entrada Invalido';	
			LET iCodRet = '00001';
	  ELSE 
			LET cNumreg = pNumreg;
	  END IF;
		
	  IF iCodRet = '00000' THEN 
			
			IF EXISTS(SELECT 1
	                    FROM sc_notif_cub_vent
				       WHERE estatus = 0 ) THEN
			
				SELECT fecha_hoy 
				INTO dFecha_Hoy
				FROM sc_fechas
				WHERE empresa = '001';

                -- Inicio del dÃ­a: 00:00:00
                LET lv_dFec_Hoy_Ini = EXTEND(dFecha_Hoy, YEAR to SECOND) + 00 UNITS HOUR + 00 UNITS MINUTE + 00 UNITS SECOND;

                -- Fin del dÃ­a: 23:59:59
                LET lv_dFec_Hoy_Fin = EXTEND(dFecha_Hoy, YEAR TO SECOND) + 23 UNITS HOUR + 59 UNITS MINUTE + 59 UNITS SECOND;

				FOREACH curIni FOR
                   SELECT FIRST cNumreg sucursal,transacc,transacc_suc,numcte,cuenta,num_tarjeta,monto_tot,folio_suc,estatus 
				     INTO cSucursal,cTransacc,cTransacc_suc,cNumcte,cCuenta,cNum_tarjeta,cMonto_tot,cFolio_suc,cEstatus
				     FROM sc_notif_cub_vent
	                WHERE fecha_insert BETWEEN lv_dFec_Hoy_Ini AND lv_dFec_Hoy_Fin	
				      AND estatus = 0

				   LET cNumcte = TRIM(cNumcte);
					
				   IF (cNumcte = '' OR cNumcte is null OR cNumcte = '000000000') THEN
						SELECT FIRST 1 num_cte
						INTO cNumcte
						FROM sc_maechq 
						WHERE cuenta = cCuenta;
						
						LET cNumcte = NVL(cNumcte,'000000000');
						
					END IF;
					
					LET iMensaje = 'Consulta Exitosa';	
					LET iCodRet = '00000';
					RETURN iCodRet,iMensaje,cSucursal,cTransacc,cTransacc_suc,cNumcte,cCuenta,cNum_tarjeta,cMonto_tot,cFolio_suc,cEstatus,cOp1,cOp2,cOp3 WITH RESUME;
				END FOREACH;
			ELSE
					LET iMensaje = 'Sin Registros Disponibles';
					LET iCodRet = '11111';
					RETURN iCodRet,iMensaje,cSucursal,cTransacc,cTransacc_suc,cNumcte,cCuenta,cNum_tarjeta,cMonto_tot,cFolio_suc,cEstatus,cOp1,cOp2,cOp3;
			END IF;
			
	  END IF;
	END;
END PROCEDURE;