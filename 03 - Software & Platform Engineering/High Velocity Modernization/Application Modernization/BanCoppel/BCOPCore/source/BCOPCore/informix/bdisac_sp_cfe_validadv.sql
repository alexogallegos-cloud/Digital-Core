CREATE PROCEDURE "informix".sp_cfe_validadv(pReferencia CHAR(30),pImporte CHAR(10))
	RETURNING 
    CHAR (5)  AS cCodRet,
    CHAR (80) AS Descripcion;

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE cCodRet			CHAR(5);
DEFINE cDescripcion 	CHAR(80);
DEFINE cDigVerRef      	CHAR(1);
DEFINE cFechaRef		CHAR(6);
DEFINE cFechaHoy		CHAR(8);
DEFINE cFechaFinal		CHAR(6);
DEFINE iMultiplo		INTEGER;
DEFINE i 				INTEGER;
DEFINE iNum				INTEGER;
DEFINE iLongDV			INTEGER;
DEFINE iSuma        	INTEGER;
DEFINE iModulo			INTEGER;
DEFINE iDigVer			INTEGER;	
DEFINE cImporte         CHAR(10);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cDescripcion	= '';
LET cDigVerRef		= 0;
LET cFechaRef		= '';
LET cFechaHoy		= '';
LET cFechaFinal		= '';
LET iMultiplo		= 0;
LET i       		= 0;
LET iNum			= 0;
LET iLongDV			= 0;
LET iSuma			= 0;
LET iModulo			= 0;
LET iDigVer			= 0;
let cImporte        = '';

	--SET DEBUG FILE TO '/informix/yuri/sp_validadv_cfe.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet,cDescripcion;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pReferencia,'')) = '' OR LENGTH(TRIM(pReferencia)) < 30 THEN
		LET cCodRet = '00003';
		LET cDescripcion = 'Referencia incorrecta, favor de validar';
	ELSE
		
		SELECT TO_CHAR(fecha_hoy,'%Y%m%d') INTO cFechaHoy
		FROM bdisac:"informix".sac_fechas;	

		--LET cFechaHoy= '20150512';
		
		LET iLongDV = LENGTH(TRIM(pReferencia)) -1 ;
		LET cDigVerRef = SUBSTR (pReferencia, LENGTH(TRIM(pReferencia)), 1);
		LET cFechaRef = SUBSTR(pReferencia,15,6);
        LET cImporte = SUBSTR(pReferencia,21,9);

		LET cFechaFinal  = SUBSTR(cFechaHoy,3,6);

        
        IF (cImporte::money) <> (pImporte::money) THEN
			LET cCodRet = '00001';
			LET cDescripcion = 'El importe es diferente al de la referencia';
            RETURN cCodRet,cDescripcion;
        END IF;
		
		
		IF (cFechaRef - cFechaFinal) < 2 THEN
			LET cCodRet = '00001';
			LET cDescripcion = 'Fecha fuera de rango, favor de validar';
            
		ELSE 
			LET iMultiplo  = 2;
			
			FOR i = 1 TO iLongDV
				LET iNum = SUBSTRING (pReferencia FROM iLongDV FOR 1);
				LET iDigVer = iNum * iMultiplo;
				
				LET iSuma = iSuma + iDigVer;
				LET iLongDV = iLongDV - 1;
				LET iMultiplo = iMultiplo + 1;
				
				IF iMultiplo > 7 THEN 
					LET iMultiplo  = 2;
				END IF;
				
			END FOR;
			
			LET iModulo = MOD(iSuma,11);
			IF iModulo = 10 THEN	    
				LET iModulo = 0;
			END IF;
			
			IF iModulo <> cDigVerRef THEN
				LET cCodRet = '00002';
				LET cDescripcion = 'Digito verificador incorrecto, favor de validar';
			ELSE 
				LET cCodRet = '00000';
				LET cDescripcion = 'Referencia valida';
				
			END IF;
			
		END IF;
		
			
	END IF;
	
	RETURN cCodRet,cDescripcion;
	
END;
	
END PROCEDURE
DOCUMENT
'Folio: 1483',
'Autor: 95347143, Jesus Isaias Bueno',
'Fecha: 15/04/2015',
'DescripciÃ³n: Se crea procedimiento para validar la linea de captura de CFE',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_cons_pagos_msw(pOrigen CHAR(4),pUsuario CHAR(8),pCategoria CHAR(2),pConvenio CHAR(3),pFolio_sucu CHAR(16),pFolio_oper CHAR(18),pSucursal CHAR(4),pCaja CHAR(3),pFecha CHAR(8),pHora CHAR(6))
	RETURNING
	CHAR(5)  AS Codigo,
	CHAR(30) AS Mensaje,
	CHAR(5)  AS Status,
	CHAR(16) AS Folio_sucursal,
	CHAR(10) AS Importe;
	
	DEFINE iSqlErr           INTEGER;
    DEFINE iIsamErr          INTEGER;
    DEFINE cInfoErr          CHAR(100);
	DEFINE cCodRet           CHAR(5);
	DEFINE cMensaje		     CHAR(30);
	DEFINE cFolio_Suc	     CHAR(16);
	DEFINE cImporte		     CHAR(20);
	DEFINE dFecha_Sac	     DATE;
	DEFINE cFechaFormat	     DATE;
	DEFINE iExiste_suc	     INTEGER;
	DEFINE iExiste_ope	     INTEGER;
	DEFINE iExisteHis	     INTEGER;
	DEFINE cStatus_cancelado CHAR(2);
    DEFINE cFolio_oper       INTEGER;
	DEFINE cSucursal_bcpl    CHAR(4);
	
	LET cCodRet           = "00000";
	LET cMensaje          = "Exitoso";
	LET cFolio_Suc	      = '';
	LET cImporte	      = '';
	LET dFecha_Sac	      = '';
	LET cFechaFormat      = '';
	LET iExiste_suc	      = 0;
	LET iExiste_ope	      = 0;
	LET iExisteHis	      = '';
	LET cStatus_cancelado = '';
    LET cFolio_oper       = 0;
	LET cSucursal_bcpl    ='';
	
	--SET DEBUG FILE TO  '/informix/EPG/sp_cons_pagos_msw_epg.out'; 
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "Error:sp_cons_pagos_msw";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_cons_pagos_msw");
                RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
            END IF;
        END EXCEPTION;
		
		    ON EXCEPTION IN (-284)
				LET cCodRet = '00000';
				LET cMensaje = 'Folio operacion duplicado';
				RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
			END EXCEPTION;
		
		SELECT fecha_hoy
		INTO dFecha_Sac
		FROM bdisac:"informix".sac_fechas
		WHERE empresa = "001";
		
		SELECT valor
		INTO cSucursal_bcpl
		FROM bdisac:"informix".sac_param where cod_param = '9997';

        IF pFolio_sucu <> '' AND pFolio_sucu IS NOT NULL THEN
            LET cFolio_oper = 1;
        ELIF pFolio_oper <> '' AND pFolio_oper IS NOT NULL THEN
            LET cFolio_oper = 2;
        ELSE
			LET cCodRet = '00500';
			LET cMensaje = 'Error:No Existe Folio por Consultar';
            RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
        END IF;

		IF pOrigen = "" OR pUsuario = "" OR pCategoria = "" OR pConvenio = "" OR
		   pSucursal = "" OR pCaja = "" OR pFecha = "" OR pHora = "" THEN
			LET cCodRet = '00501';
			LET cMensaje = 'Error:Faltan parametros de entrada';
            RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
		END IF
		
		LET cFechaFormat = MDY(SUBSTR(pFecha,5,2), SUBSTR(pFecha,7,2), SUBSTR(pFecha,1,4));
		
		IF pOrigen = "CPL"  THEN
			IF cFechaFormat = dFecha_Sac THEN
  				--VERIFICA SI EXISTE EL FOLIO OPERACION                  
				
				IF pFolio_sucu <> "" AND pFolio_oper <> "" THEN 
					SELECT COUNT(*)
					  INTO iExiste_suc
					  FROM bdisac:"informix".sac_movimientos
					 WHERE numcategoria = pCategoria AND numconvenio = pConvenio
					   AND folio_suc = pFolio_sucu
					   AND folio_operacion = pFolio_oper
					   AND caja_cpl = pCaja
					   AND id_sucursal  = cSucursal_bcpl
					   AND sucursal_cpl = pSucursal;
			   END IF;
				
	   		   IF pFolio_sucu <> "" AND pFolio_oper = "" THEN  
					SELECT COUNT(*)
					  INTO iExiste_suc
					  FROM bdisac:"informix".sac_movimientos
					 WHERE numcategoria = pCategoria 
                       AND numconvenio = pConvenio
					   AND id_sucursal  = cSucursal_bcpl
                       AND sucursal_cpl = pSucursal
					   AND caja_cpl = pCaja
					   AND folio_suc = pFolio_sucu;
			   END IF;	
				
			   IF pFolio_sucu = "" AND pFolio_oper <> "" THEN  
					SELECT COUNT(*)
					  INTO iExiste_ope
					  FROM bdisac:"informix".sac_movimientos
					 WHERE numcategoria = pCategoria 
                       AND numconvenio = pConvenio
                       AND id_sucursal  = cSucursal_bcpl
                       AND sucursal_cpl = pSucursal
					   AND caja_cpl = pCaja
					   AND folio_operacion = pFolio_oper;
			   END IF;		
 				
				IF iExiste_suc < 1 AND iExiste_ope < 1 THEN
					LET cCodRet = '00000';
					LET cMensaje = 'Exitoso';
					LET cStatus_cancelado = 'NE';
					RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte; 
				END IF;

				IF iExiste_suc = 1 THEN
                    SELECT NVL(folio_suc,''), NVL(importe_pago::CHAR(20),''),  status_cancelado
                    INTO cFolio_Suc, cImporte, cStatus_cancelado
                    FROM bdisac:"informix".sac_movimientos
                    WHERE numcategoria = pCategoria 
                    AND numconvenio = pConvenio
                    AND folio_suc = pFolio_sucu
 				    AND caja_cpl = pCaja
					AND id_sucursal  = cSucursal_bcpl
                    AND sucursal_cpl = pSucursal;
				ELSE
                    SELECT NVL(folio_suc,''), NVL(importe_pago::CHAR(20),''),  status_cancelado
                    INTO cFolio_Suc, cImporte, cStatus_cancelado
                    FROM bdisac:"informix".sac_movimientos
                    WHERE numcategoria = pCategoria 
                    AND numconvenio = pConvenio
                    AND folio_operacion = pFolio_oper
                    AND caja_cpl = pCaja
					AND id_sucursal  = cSucursal_bcpl
                    AND sucursal_cpl = pSucursal;	
                END IF;
			
			ELSE	
				--VERIFICA SI EXISTE EL FOLIO OPERACION HISTORIAL
				
    		   IF pFolio_sucu <> "" AND pFolio_oper <> "" THEN 
					SELECT COUNT(*)
					  INTO iExiste_suc
					  FROM bdisac:"informix".sac_movimientoshistorial
					 WHERE numcategoria = pCategoria AND numconvenio = pConvenio
					   AND folio_suc = pFolio_sucu
                       AND caja_cpl = pCaja
					   AND id_sucursal  = cSucursal_bcpl
                       AND sucursal_cpl = pSucursal
					   AND folio_operacion = pFolio_oper;
			   END IF;
				
	   		   IF pFolio_sucu <> "" AND pFolio_oper = "" THEN  
					SELECT COUNT(*)
					  INTO iExiste_suc
					  FROM bdisac:"informix".sac_movimientoshistorial
					 WHERE numcategoria = pCategoria 
                       AND numconvenio = pConvenio
                       AND caja_cpl = pCaja
					   AND id_sucursal  = cSucursal_bcpl
                       AND sucursal_cpl = pSucursal
					   AND folio_suc = pFolio_sucu;
			   END IF;	
				
			   IF pFolio_sucu = "" AND pFolio_oper <> "" THEN  
					SELECT COUNT(*)
					  INTO iExiste_ope
					  FROM bdisac:"informix".sac_movimientoshistorial
					 WHERE numcategoria = pCategoria 
                       AND numconvenio = pConvenio
					   AND id_sucursal  = cSucursal_bcpl
                       AND sucursal_cpl = pSucursal
					   AND caja_cpl = pCaja
					   AND folio_operacion = pFolio_oper;
			   END IF;		
 				
				IF iExiste_suc < 1 AND iExiste_ope < 1 THEN
					LET cCodRet = '00000';
					LET cMensaje = 'Exitoso';
					LET cStatus_cancelado = 'NE';
					RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte; 
				END IF;

				IF iExiste_suc = 1 THEN
                    SELECT NVL(folio_suc,''), NVL(importe_pago::CHAR(20),''),  status_cancelado
                    INTO cFolio_Suc, cImporte, cStatus_cancelado
                    FROM bdisac:"informix".sac_movimientoshistorial
                    WHERE numcategoria = pCategoria 
                    AND numconvenio = pConvenio
					AND id_sucursal  = cSucursal_bcpl
                    AND sucursal_cpl = pSucursal
  				    AND caja_cpl = pCaja
                    AND folio_suc = pFolio_sucu;
				ELSE
                    SELECT NVL(folio_suc,''), NVL(importe_pago::CHAR(20),''),  status_cancelado
                    INTO cFolio_Suc, cImporte, cStatus_cancelado
                    FROM bdisac:"informix".sac_movimientoshistorial
                    WHERE numcategoria = pCategoria 
                    AND numconvenio = pConvenio
                    AND folio_operacion = pFolio_oper
  				    AND caja_cpl = pCaja
					AND id_sucursal  = cSucursal_bcpl
                    AND sucursal_cpl = pSucursal;					
                END IF;
	        END IF;		

			IF cFolio_Suc = '' OR cFolio_Suc IS NULL OR cImporte = '' OR cImporte IS NULL THEN
				LET cCodRet = '00000'; 
				LET cMensaje = 'exitoso';
				LET cStatus_cancelado = 'NE';
				LET cFolio_Suc = '';
				LET cImporte = '';
				RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
			ELSE
				IF cStatus_cancelado = 'S' THEN
					LET cStatus_cancelado = 'R';
				ELSE
					LET cStatus_cancelado = 'P';
				END IF;	
				RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
			END IF;			
	
		ELSE 
			LET cCodRet = '00505';
			LET cMensaje = 'Origen Desconocido';
            RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
		END IF;
		
	END;
	
END PROCEDURE
;