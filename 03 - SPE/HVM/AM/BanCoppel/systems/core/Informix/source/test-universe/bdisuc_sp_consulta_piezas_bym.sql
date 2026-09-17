CREATE PROCEDURE "informix".sp_consulta_piezas_bym(pOpcion CHAR(1),pDato CHAR(10),pFechaIni DATE,pFechafin DATE,pRegistros INTEGER)
RETURNING   CHAR(6)   AS CodRet, 
			INTEGER   AS IdPieza, 
			CHAR(10)  AS Denominacion , 
			CHAR(40)  AS Serie, 
			CHAR(40)  AS Folio, 
			DATE      AS FechaEmision, 
			CHAR(10)  AS NumRecibo, 
			CHAR(20)  AS Estatus, 
			CHAR(20)  AS Dictamen,
			DATE      AS FechaPago, 
			CHAR(11)  AS CuentaCliente,
			CHAR(200) AS Nota,
			CHAR(104) AS NomTenedor,
			INTEGER   AS Secuencia,
			INTEGER   AS Termino;

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err           INTEGER;
DEFINE cCodRet            CHAR(6);
DEFINE iIdpieza           INTEGER;
DEFINE cDenominacion      CHAR(10);
DEFINE cSerie             CHAR(40);
DEFINE cFolio             CHAR(40);
DEFINE dFechaEmision      DATE;
DEFINE cNumRecibo         CHAR(10);
DEFINE cEstatus           CHAR(20);
DEFINE cDictamen          CHAR(20);
DEFINE dFechaPago         DATE;
DEFINE cCuentaCliente     CHAR(11);
DEFINE cNota              CHAR(200);
DEFINE cNomTenedor        CHAR(104);
DEFINE iIdTenedor         INTEGER;
DEFINE iDenominacion      INTEGER;
DEFINE iDictamen          INTEGER;
DEFINE iEstatus           INTEGER;
DEFINE cNombre1           CHAR(26);
DEFINE cNombre2           CHAR(26);
DEFINE cApPaterno         CHAR(26); 
DEFINE cApMaterno         CHAR(26);
DEFINE iBandCons1         INTEGER;
DEFINE iBandCons2         INTEGER;
DEFINE iBandCons3         INTEGER;
DEFINE iContador          INTEGER;
DEFINE iContadorSec       INTEGER;
DEFINE iSecuencia         INTEGER;
DEFINE iSecuencia2        INTEGER;
DEFINE iTermino           INTEGER;
DEFINE iResivos           INTEGER;
DEFINE iContRep           INTEGER;
DEFINE iFin               INTEGER;
DEFINE iQuedan            INTEGER;
DEFINE iLimit             INTEGER;
DEFINE iLimit2            INTEGER;
DEFINE iInicio            INTEGER;
DEFINE iFaltan            INTEGER;
DEFINE iContadorParaFin   INTEGER;
DEFINE cNumReciboContando CHAR(10);
DEFINE iSiguienteResivo   INTEGER; 

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '000000';
LET iIdpieza            = 0;
LET cDenominacion       = '';
LET cSerie              = '';
LET cFolio              = '';
LET dFechaEmision       = DATE(1);
LET cNumRecibo          = '';
LET cEstatus            = '';
LET cDictamen           = '';
LET dFechaPago          = DATE(1);
LET cCuentaCliente      = '';
LET cNota               = '';
LET cNomTenedor         = '';
LET iIdTenedor          = 0;
LET iDenominacion       = 0;
LET iDictamen           = 0;
LET iEstatus            = 0;
LET cNombre1            = '';
LET cNombre2            = '';  
LET cApPaterno          = '';
LET cApMaterno          = '';
LET iBandCons1          = 0;
LET iBandCons2          = 0;
LET iBandCons3          = 0;
LET iContador           = 0;
LET iContadorSec        = 0;
LET iTermino            = 0;
LET iSecuencia          = 0;
LET iSecuencia2         = 0;
LET iResivos            = 0;
LET iContRep            = 0;
LET iFin                = 0;
LET iQuedan             = 0;
LET iLimit              = 10;
LET iLimit2             = 0;
LET iInicio             = 0;
LET iFaltan             = 0;
LET iContadorParaFin    = 0;
LET cNumReciboContando  = '';
LET iSiguienteResivo    = 0;

SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/informix/Acuellar/sp_consulta_piezas_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			RETURN cCodRet, iIdpieza, cDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, cEstatus, cDictamen, dFechaPago, cCuentaCliente, cNota, cNomTenedor, iSecuencia, iTermino WITH RESUME;
		END IF;
	END EXCEPTION;
	
	--validacion inicio
	IF TRIM(NVL(pOpcion,'')) = '1' OR TRIM(NVL(pOpcion,'')) = '2' OR TRIM(NVL(pOpcion,'')) = '3' OR TRIM(NVL(pOpcion,'')) = '4' THEN
		
		IF TRIM(NVL(pOpcion,'')) = '3' THEN
			IF TRIM(NVL(pFechaIni,'')) = '' OR TRIM(NVL(pFechafin,'')) = '' THEN
				LET cCodRet = '000001';
			END IF;
		ELSE
			IF TRIM(NVL(pDato,'')) = '' THEN
				LET cCodRet = '000001';
			END IF;
		END IF;
	
	ELSE
		LET cCodRet = '000001';
	END IF;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF  cCodRet =  '000000' THEN
	
		LET iSecuencia = pRegistros;
		
       IF TRIM(NVL(pOpcion,'')) = '2' THEN  --------------------------------  FOLIO     -----------------------------------------------------------------------
	
	        SELECT {+INDEX (bdisuc:"informix".ss_recibo_bym_falsos 7153_569)} COUNT(num_recibo)
			INTO iContadorSec  
			FROM bdisuc:"informix".ss_recibo_bym_falsos
			WHERE num_recibo = pDato; 
			
			LET iSecuencia2 = pRegistros;
			
			WHILE (cCodRet = '000000' AND iContRep < iLimit AND iResivos < iContadorSec  AND iTermino = 0)
			
            FOREACH 		
                SELECT {+AVOID_FULL(bdisuc:"informix".ss_recibo_bym_falsos)} SKIP iResivos LIMIT 1  num_recibo, id_tenedor
                INTO cNumRecibo, iIdTenedor
                FROM bdisuc:"informix".ss_recibo_bym_falsos
                WHERE num_recibo = pDato 
                ORDER BY num_recibo
                 
                LET iBandCons1  = 1;
                LET iSiguienteResivo = iResivos + 1; 
                
                SELECT COUNT(id_denominacion)
                INTO iContador
                FROM bdisuc:"informix".ss_piezas_bym_falsos
                WHERE  num_recibo =  cNumRecibo;

                IF iSecuencia2 > iContador THEN
                    LET iSecuencia2 = iSecuencia2 - iContador;
                ELSE
                    LET iQuedan =  iContador - iSecuencia2;
                    LET iInicio = iContador - iQuedan;
                    LET iSecuencia2 = 0;
                END IF;

                IF iSecuencia2 = 0 AND iQuedan > 0 THEN
					
						IF iContRep <> 0 THEN
							LET iLimit2 = iLimit - iContRep;
						ELSE
							LET iLimit2 = iLimit;	
						END IF;
					
						LET iFaltan = 0;
						
						IF iSiguienteResivo < iContadorSec THEN
							FOREACH 		
								SELECT SKIP iSiguienteResivo LIMIT iContadorSec  num_recibo
								INTO cNumReciboContando
								FROM bdisuc:"informix".ss_recibo_bym_falsos
								WHERE num_recibo = pDato 
								ORDER BY num_recibo
		
								SELECT COUNT(id_denominacion)
								INTO iContadorParaFin
								FROM bdisuc:"informix".ss_piezas_bym_falsos
								WHERE num_recibo = cNumReciboContando;
			
								LET iFaltan = iFaltan + NVL(iContadorParaFin,0);
		
							END FOREACH ;
						END  IF;				
						
						FOREACH																
							SELECT  SKIP iInicio LIMIT iLimit2 id_denominacion, serie, folio, fecha_emision,  estatus, dictamen_banxico, fecha_pago, nota, id_pieza, num_cta_cliente
							INTO iDenominacion, cSerie, cFolio, dFechaEmision, iEstatus, iDictamen, dFechaPago, cNota, iIdpieza, cCuentaCliente 
							FROM bdisuc:"informix".ss_piezas_bym_falsos
							WHERE num_recibo =  cNumRecibo							
							ORDER BY id_denominacion
							
							LET iBandCons2  = 1;
							
							SELECT  desc_dictamen
							INTO cDictamen
							FROM bdisuc:"informix".ss_cat_dictamen_bym_falsos
							WHERE empresa = '001' 
							AND id_dictamen = iDictamen;
							
							LET cDictamen = NVL(cDictamen,'');
							
							SELECT denominacion
							INTO cDenominacion
							FROM bdisuc:"informix".ss_denominacion_bym_falsos
							WHERE empresa = '001' 
							AND id_denominacion = iDenominacion;
							
							IF dbinfo("sqlca.sqlerrd2") = 1 THEN 

								SELECT desc_estatus
								INTO cEstatus
								FROM bdisuc:"informix".ss_cat_estatus_bym_falsos
								WHERE empresa = '001' 
								AND id_estatus = iEstatus;
									
								IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
								
									SELECT nombre_1, nombre_2, ap_paterno, ap_materno
									INTO cNombre1, cNombre2, cApPaterno, cApMaterno
									FROM bdisuc:"informix".ss_tenedor_pieza
									WHERE id_tenedor = iIdTenedor;
										
									IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
										LET cNomTenedor = TRIM(TRIM(cNombre1) || ' ' || TRIM(cNombre2)) || ' ' || TRIM(TRIM(cApPaterno) || ' ' || TRIM(cApMaterno));
									ELSE
										LET cCodRet ='000002';
									END IF;
								ELSE
									LET cCodRet = '000002';
								END IF;

							ELSE
								LET cCodRet = '000002';
							END IF;
							
							IF cCodRet <> '000000' THEN
								LET iIdpieza       = 0;
								LET cDenominacion  = '';
								LET cSerie         = '';
								LET cFolio         = '';
								LET cDictamen      = '';
								LET cEstatus       = '';
								LET cNota          = '';
								LET cNomTenedor    = '';
								LET dFechaEmision  = DATE(1);
								LET cNumRecibo     = '';
								LET dFechaPago     = DATE(1);
								LET cCuentaCliente = '';
								LET iSecuencia     = 0;
							ELSE
								LET iSecuencia =  iSecuencia +1;
								LET iContRep = iContRep +1;
							END IF;
							
							IF iFaltan = 0 OR iContadorSec = iSiguienteResivo THEN
								IF iLimit2 >= iQuedan  THEN
									LET iFin = iFin + 1;
								END IF;
				
								IF iFin = iQuedan AND iFin <> 0 THEN
									LET iTermino = 1;
								END IF;
							END IF;
							
							IF  dFechaEmision  = DATE(1) THEN
								LET dFechaEmision = '';
							END IF;
							
							RETURN cCodRet, iIdpieza, cDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, cEstatus, cDictamen, dFechaPago, cCuentaCliente, cNota, cNomTenedor, iSecuencia, iTermino  WITH RESUME;
							LET iBandCons3 = 1;
						END FOREACH						
					END IF;
			END FOREACH;
				
				IF iContadorSec = iSiguienteResivo OR iContadorSec = 0 THEN
					IF  iBandCons1  = 0 OR iBandCons2  = 0  THEN
						LET cCodRet = '000002';
					END IF;
				END IF;
				
				IF cCodRet = '000000' THEN
					IF iContRep < iLimit THEN
						LET iResivos = iSiguienteResivo;
					END IF;	
				END IF;
			END WHILE;		
			IF iContadorSec = 0 THEN
				LET cCodRet = '000002';
			END IF;			
		END IF;	
				
		IF TRIM(NVL(pOpcion,'')) = '1' or TRIM(NVL(pOpcion,'')) = '4' THEN  --------------------------------  Sucursal     -----------------------------------------------------------------------
	
	        SELECT {+INDEX (bdisuc:"informix".ss_recibo_bym_falsos 7153_569)} COUNT(a.num_recibo)
			INTO iContadorSec  --3
			FROM bdisuc:"informix".ss_recibo_bym_falsos a
            INNER JOIN bdisuc:"informix".ss_piezas_bym_falsos b ON a.num_Recibo=b.num_recibo AND b.num_guia IS NULL
			WHERE num_sucursal_retencion = pDato
            AND a.fecha_insert>=today-5; 
			
			LET iSecuencia2 = pRegistros;
			
			WHILE (cCodRet = '000000' AND iContRep < iLimit AND iResivos < iContadorSec  AND iTermino = 0)
			
            FOREACH 		
                SELECT {+AVOID_FULL(bdisuc:"informix".ss_recibo_bym_falsos)} SKIP iResivos LIMIT 1  num_recibo, id_tenedor
                INTO cNumRecibo, iIdTenedor
                FROM bdisuc:"informix".ss_recibo_bym_falsos
                WHERE num_sucursal_retencion = pDato 
                ORDER BY num_recibo
                 
                LET iBandCons1  = 1;
                LET iSiguienteResivo = iResivos + 1; 
                
                SELECT COUNT(id_denominacion)
                INTO iContador
                FROM bdisuc:"informix".ss_piezas_bym_falsos
                WHERE  num_recibo =  cNumRecibo;

                IF iSecuencia2 > iContador THEN
                    LET iSecuencia2 = iSecuencia2 - iContador;
                ELSE
                    LET iQuedan =  iContador - iSecuencia2;
                    LET iInicio = iContador - iQuedan;
                    LET iSecuencia2 = 0;
                END IF;

                IF iSecuencia2 = 0 AND iQuedan > 0 THEN
					
						IF iContRep <> 0 THEN
							LET iLimit2 = iLimit - iContRep;
						ELSE
							LET iLimit2 = iLimit;	
						END IF;
					
						LET iFaltan = 0;
						
						IF iSiguienteResivo < iContadorSec THEN
							FOREACH 		
								SELECT SKIP iSiguienteResivo LIMIT iContadorSec  num_recibo
								INTO cNumReciboContando
								FROM bdisuc:"informix".ss_recibo_bym_falsos
								WHERE num_sucursal_retencion = pDato 
								ORDER BY num_recibo
		
								SELECT COUNT(id_denominacion)
								INTO iContadorParaFin
								FROM bdisuc:"informix".ss_piezas_bym_falsos
								WHERE num_recibo = cNumReciboContando;
			
								LET iFaltan = iFaltan + NVL(iContadorParaFin,0);
		
							END FOREACH ;
						END  IF;				
						
						FOREACH																
							SELECT  SKIP iInicio LIMIT iLimit2 id_denominacion, serie, folio, fecha_emision,  estatus, dictamen_banxico, fecha_pago, nota, id_pieza, num_cta_cliente
							INTO iDenominacion, cSerie, cFolio, dFechaEmision, iEstatus, iDictamen, dFechaPago, cNota, iIdpieza, cCuentaCliente 
							FROM bdisuc:"informix".ss_piezas_bym_falsos
							WHERE num_recibo =  cNumRecibo							
							ORDER BY id_denominacion
							
							LET iBandCons2  = 1;
							
							SELECT  desc_dictamen
							INTO cDictamen
							FROM bdisuc:"informix".ss_cat_dictamen_bym_falsos
							WHERE empresa = '001' 
							AND id_dictamen = iDictamen;
							
							LET cDictamen = NVL(cDictamen,'');
							
							SELECT denominacion
							INTO cDenominacion
							FROM bdisuc:"informix".ss_denominacion_bym_falsos
							WHERE empresa = '001' 
							AND id_denominacion = iDenominacion;
							
							IF dbinfo("sqlca.sqlerrd2") = 1 THEN 

								SELECT desc_estatus
								INTO cEstatus
								FROM bdisuc:"informix".ss_cat_estatus_bym_falsos
								WHERE empresa = '001' 
								AND id_estatus = iEstatus;
									
								IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
								
									SELECT nombre_1, nombre_2, ap_paterno, ap_materno
									INTO cNombre1, cNombre2, cApPaterno, cApMaterno
									FROM bdisuc:"informix".ss_tenedor_pieza
									WHERE id_tenedor = iIdTenedor;
										
									IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
										LET cNomTenedor = TRIM(TRIM(cNombre1) || ' ' || TRIM(cNombre2)) || ' ' || TRIM(TRIM(cApPaterno) || ' ' || TRIM(cApMaterno));
									ELSE
										LET cCodRet ='0000-1'; --'000002';
									END IF;
								ELSE
									LET cCodRet = '000001'; --'000002';
								END IF;

							ELSE
								LET cCodRet = '000002';
							END IF;
							
							IF cCodRet <> '000000' THEN
								LET iIdpieza       = 0;
								LET cDenominacion  = '';
								LET cSerie         = '';
								LET cFolio         = '';
								LET cDictamen      = '';
								LET cEstatus       = '';
								LET cNota          = '';
								LET cNomTenedor    = '';
								LET dFechaEmision  = DATE(1);
								LET cNumRecibo     = '';
								LET dFechaPago     = DATE(1);
								LET cCuentaCliente = '';
								LET iSecuencia     = 0;
							ELSE
								LET iSecuencia =  iSecuencia +1;
								LET iContRep = iContRep +1;
							END IF;
							
							IF iFaltan = 0 OR iContadorSec = iSiguienteResivo THEN
								IF iLimit2 >= iQuedan  THEN
									LET iFin = iFin + 1;
								END IF;
				
								IF iFin = iQuedan AND iFin <> 0 THEN
									LET iTermino = 1;
								END IF;
							END IF;
							
							IF  dFechaEmision  = DATE(1) THEN
								LET dFechaEmision = '';
							END IF;
							
							RETURN cCodRet, iIdpieza, cDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, cEstatus, cDictamen, dFechaPago, cCuentaCliente, cNota, cNomTenedor, iSecuencia, iTermino  WITH RESUME;
							LET iBandCons3 = 1;
						END FOREACH						
					END IF;
			END FOREACH;
				
				IF iContadorSec = iSiguienteResivo OR iContadorSec = 0 THEN
					IF  iBandCons1  = 0 OR iBandCons2  = 0  THEN
						LET cCodRet = '000002';
					END IF;
				END IF;
				
				IF cCodRet = '000000' THEN
					IF iContRep < iLimit THEN
						LET iResivos = iSiguienteResivo;
					END IF;	
				END IF;
			END WHILE;		
			IF iContadorSec = 0 THEN
				LET cCodRet = '000002';
			END IF;			
		END IF;	
	
	
		IF TRIM(NVL(pOpcion,'')) = '3' THEN  --------------------------------  Rango de fechas     -----------------------------------------------------------------------
		
			SELECT COUNT(id_denominacion)
			INTO iContador 	
			FROM bdisuc:"informix".ss_piezas_bym_falsos
			WHERE fecha_insert >= pFechaIni AND fecha_insert <= pFechafin;
	
			FOREACH
				SELECT SKIP pRegistros LIMIT iLimit  id_denominacion, serie, folio, fecha_emision, num_recibo, estatus, dictamen_banxico, fecha_pago, nota, id_pieza, num_cta_cliente
				INTO iDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, iEstatus, iDictamen, dFechaPago, cNota, iIdpieza, cCuentaCliente 
				FROM bdisuc:"informix".ss_piezas_bym_falsos
				WHERE fecha_insert >= pFechaIni AND  fecha_insert <= pFechafin
				ORDER BY id_denominacion
				
				LET iBandCons2  = 1;	
				
				SELECT desc_dictamen
				INTO cDictamen
				FROM bdisuc:"informix".ss_cat_dictamen_bym_falsos
				WHERE empresa = '001' 
				AND id_dictamen = iDictamen;
				
				LET cDictamen = NVL(cDictamen,'');
				
				SELECT  num_recibo, id_tenedor
				INTO    cNumRecibo, iIdTenedor
				FROM bdisuc:"informix".ss_recibo_bym_falsos
				WHERE num_recibo= cNumRecibo;
				
				IF dbinfo("sqlca.sqlerrd2") = 1 THEN 	
				
					SELECT denominacion
					INTO cDenominacion
					FROM bdisuc:"informix".ss_denominacion_bym_falsos
					WHERE empresa = '001' 
					AND id_denominacion = iDenominacion;
					
					IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
						
						SELECT desc_estatus
						INTO cEstatus
						FROM bdisuc:"informix".ss_cat_estatus_bym_falsos
						WHERE empresa = '001' 
						AND id_estatus = iEstatus;
						
						IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
						
							SELECT nombre_1, nombre_2, ap_paterno, ap_materno
							INTO cNombre1, cNombre2, cApPaterno, cApMaterno
							FROM bdisuc:"informix".ss_tenedor_pieza
							WHERE id_tenedor = iIdTenedor;
								
							IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
								LET cNomTenedor = TRIM(TRIM(cNombre1) || ' ' || TRIM(cNombre2)) || ' ' || TRIM(TRIM(cApPaterno) || ' ' || TRIM(cApMaterno));
							ELSE
								LET cCodRet = '000002';
							END IF;
							
						ELSE
							LET cCodRet = '000002';
						END IF;
					ELSE
						LET cCodRet = '000002';
					END IF;
				ELSE
					LET cCodRet = '000002';
				END IF;	
					
				IF cCodRet <> '000000' THEN
					LET iIdpieza       = 0;
					LET cDenominacion  = '';
					LET cSerie         = '';
					LET cFolio         = '';
					LET cDictamen      = '';
					LET cEstatus       = '';
					LET cNota          = '';
					LET cNomTenedor    = '';
					LET dFechaEmision  = DATE(1);
					LET cNumRecibo     = '';
					LET dFechaPago     = DATE(1);
					LET cCuentaCliente = '';
					LET iSecuencia     = 0;
				ELSE
					LET iSecuencia = iSecuencia +1;
				END IF;
				
				IF iSecuencia = iContador  THEN
					LET iTermino = 1;
				END IF;
					
				RETURN cCodRet, iIdpieza, cDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, cEstatus, cDictamen, dFechaPago, cCuentaCliente, cNota, cNomTenedor, iSecuencia, iTermino  WITH RESUME;
				LET iBandCons3 = 1;
	
			END FOREACH;
			
			IF  iBandCons2  = 0 OR iBandCons2  = 0 THEN
				LET cCodRet = '000002';
			END IF;		
		
		IF iContadorSec = 0 THEN
			LET cCodRet = '000002';
		END IF;
			
	   END IF;	
	 END IF;
	
	IF iBandCons3 = 0 THEN
		IF cCodRet <> '000000' THEN
			LET iIdpieza       = 0;
			LET cDenominacion  = '';
			LET cSerie         = '';
			LET cFolio         = '';
			LET cDictamen      = '';
			LET cEstatus       = '';
			LET cNota          = '';
			LET cNomTenedor    = '';
			LET dFechaEmision  = DATE(1);
			LET cNumRecibo     = '';
			LET dFechaPago     = DATE(1);
			LET cCuentaCliente = '';
			LET iSecuencia     = 0;
		END IF;
						
		RETURN cCodRet, iIdpieza, cDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, cEstatus, cDictamen, dFechaPago, cCuentaCliente, cNota, cNomTenedor, iSecuencia, iTermino WITH RESUME;
	END IF;
	
END;    
END PROCEDURE;