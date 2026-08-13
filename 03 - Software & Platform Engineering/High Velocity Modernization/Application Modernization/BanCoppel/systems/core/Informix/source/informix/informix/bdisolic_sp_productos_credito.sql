CREATE PROCEDURE "informix".sp_productos_credito()
	RETURNING  
    CHAR(20)  AS cCodRet,
    CHAR(100) AS cMensajeRet
    
	-- pFechaini date,pFechaFIN date     -- drop procedure sp_Pruebas_Productos_Credito;
-- TarjetAS Coppel tramitadAS en lAS sucursales. Se generara cada semana
	----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
    -- Declara lAS variables											-- DeclaraciON de variables para ASignarlAS a la tabla 
    DEFINE cCodRet              CHAR(5);								DEFINE cnum_cte					CHAR(20); 
    DEFINE cMensajeRet          CHAR(100);								DEFINE dfecha_Alta 				DATE;
	DEFINE iSqlErr              INTEGER;								DEFINE csuc_alta 				CHAR(4);
    DEFINE cErrorinfo           CHAR(80);								DEFINE ctipo_tramite 			CHAR(2);
    DEFINE cNum_Solicitud 		CHAR(20);								DEFINE cnumsol_CPL 				CHAR(20);
	DEFINE vCoppel		 		CHAR(20);								DEFINE cEstatus_CPL 			CHAR(2);
	DEFINE vBanco		 		CHAR(20);								DEFINE ccausaRT_CPL 			CHAR(3);
    DEFINE cNumCte              CHAR(20);								DEFINE cnumsol_BCPL 			CHAR(20);
    DEFINE cStatus_Solicitud    CHAR(2);								DEFINE cestatus_BCPL 			CHAR(2);
	DEFINE vcstatusSol			CHAR(2);								DEFINE ccausaRT_BCPL 			CHAR(3);
    DEFINE dfecha_insert        DATE;									DEFINE crep_SupTel 				CHAR(1);
    DEFINE cValor               CHAR(5);								DEFINE ctiempo_Sup_Tel 			CHAR(1);
    DEFINE cSql                 CHAR(6000);								DEFINE dBC_Score 				DECIMAL(5,2);
    DEFINE cNombre_Archivo      CHAR(35);								DEFINE cscore_Propietario 		CHAR(20);
    DEFINE cExiste              CHAR(1);								DEFINE spuntosparcn 			SMALLINT;
	DEFINE vCvalortramite		INTEGER;								DEFINE ilimitecreditopesos 		INTEGER;
	DEFINE ibandera				INTEGER;								DEFINE ilimitecredito 			INTEGER;	
	DEFINE ccausa				CHAR(3);								DEFINE ccoppel		 			CHAR(20);	
	DEFINE cbanco		 		CHAR(20);								DEFINE ccstatusSol				CHAR(2);	
	DEFINE icvalortramite		INTEGER;								DEFINE cbstatusSol				CHAR(2);
	DEFINE vbstatusSol			CHAR(2);								DEFINE cn_cte					CHAR(20);
	DEFINE ctipo_solicitud		CHAR(1);								DEFINE vdfec_insert				DATE;
	DEFINE vcn_cte				CHAR(20);								DEFINE pFechaini				DATE;
	DEFINE vdf_insert			DATE;									DEFINE pFechaFin				DATE;
	----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- 
    -- ASigna valor a lAS variables										-- ASignan valor a lAS variables de la tabla
    LET cCodRet             = '000';									LET cnum_cte 				= '';
	LET iSqlErr             = 0;										LET dfecha_Alta 			= DATE(1);
    LET cMensajeRet         = "PROCESO EXITOSO"; 						LET csuc_alta 				= '';
    LET cErrorinfo         	= "";										LET ctipo_tramite			= '';
    LET cNum_Solicitud 		= "";										LET cnumsol_CPL				= '';
	LET vCoppel				= "";										LET cEstatus_CPL			= '';
	LET vBanco  			= "";										LET ccausaRT_CPL			= '';
    LET cNumCte      		= "";										LET cnumsol_BCPL			= '';
    LET cStatus_Solicitud	= "";										LET cestatus_BCPL			= '';
    LET cSql                = "";										LET ccausaRT_BCPL			= '';
    LET cExiste             = "";										LET crep_SupTel				= '';
	LET vCvalortramite       = 0;										LET ctiempo_Sup_Tel			= '';
	LET vcstatusSol			= "";										LET dBC_Score				= 0;
	LET ibandera			= 0;										LET cscore_Propietario		= '';
	LET ccausa 					= "";									LET spuntosparcn			= '';
	LET ccoppel		 		= "";										LET ilimitecreditopesos 	= 0;
	LET cbanco		 		= "";										LET ilimitecredito			= 0;	
	LET ccstatusSol			= "";										LET cbstatusSol				= "";
	LET icvalortramite		= 0;										LET cn_cte					= "";
	LET vbstatusSol			= "";										LET vdfec_insert			= DATE(1);
	LET ctipo_solicitud		= "";										LET pFechaini				= DATE(1);
	LET vcn_cte				= "";										LET pFechaFin				= DATE(1);
	LET vdf_insert			= DATE(1);
	----- ----- ----- ----- ----- ----- ----- ----- 
     -- Creo un archivo en cASo que ocurra unu error en el sp
        --SET DEBUG FILE TO "/informix/Gisela/Detalle_error.out";
        --TRACE ON;
	----- ----- ----- ----- ----- ----- ----- ----- 
BEGIN
		----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
				-- Detecta si hay algun problema en la cONsulta
				ON EXCEPTION SET iSqlErr
					IF iSqlErr !=0 THEN					
						 LET cCodRet = iSqlErr;
						 LET cMensajeRet = ccoppel || '-' || cbanco; --cErrorinfo;
							truncate TABLE bdisolic:tmp_datosgeneral;
							truncate TABLE bdisolic:tmp_tipotramite;
						RETURN cCodRet,cMensajeRet;
					END IF;
				END EXCEPTION;
				----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
				SET ISOLATION TO DIRTY READ; -- Hace consultas "sucias"
				SET LOCK MODE TO WAIT 3; -- Espera 3 segundos si la tabla y/o el registro esta bloqueado				
				----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----				
					truncate table "informix".tmp_datosgeneral ;
					truncate table "informix".tmp_tipotramite ;
				----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----					
				select fecha_hoy into pFechaFin from bdicred:"informix".sd_fechas where empresa = '001';
				LET pFechaIni = pFechaFin -7;
				--LET pFechaIni = '10-14-2014';
				--LET pFechaFin = '10-14-2014';
				----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----					
				----- *** CASO 4 *** ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
				-- Solicitud de TDC Coppel						
				FOREACH with hold									
					SELECT a.num_solicitud as Coppel,'' as Banco,a.status_solicitud as cstatusSol,
						'' as bstatusSol,a.numcte as n_cte, a.fecha_insert as dfec_insert, 4 as Cvalortramite
					INTO vCoppel,vbanco,vcstatusSol,vbstatusSol,vcn_cte,vdfec_insert,vCvalortramite
					FROM bdisolic:"informix".ss_solicitudes as a
					WHERE a.empresa ='001'
					AND a.num_producto ='6500' AND a.sucursal = a.sucursal
					AND a.status_solicitud NOT IN('AN','PC')
					AND a.numcte NOT IN (select numcte from bdisolic:"informix".ss_solicitudes WHERE empresa ='001' AND
							fecha_insert = a.fecha_insert and num_producto in('6001') and status_solicitud NOT IN('AN','PC') AND user_insert = a.user_insert AND sucursal = a.sucursal)
					AND a.numcte NOT IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq mae
									INNER JOIN bdicheq:"informix".sc_maenoc noc ON (mae.empresa = noc.empresa AND mae.cuenta = noc.cuenta and noc.clase_cta = noc.clase_cta) 
									where mae.empresa ='001' and mae.producto = 2000 and noc.fecha_alta = a.fecha_insert)
					AND a.fecha_insert  BETWEEN pFechaIni and pFechaFin
					----- ----- ----- ----- -----
						BEGIN;   
							insert into bdisolic:"informix".tmp_tipotramite(coppel,banco,cstatussol,bstatusSol,n_cte,dfec_insert,cvalortramite)
							values (vCoppel,vbanco,vcstatusSol,vbstatusSol,vcn_cte,vdfec_insert,vCvalortramite);				  
						COMMIT;		
					----- ----- ----- ----- -----
				END FOREACH;	
				----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----					
				----- *** CASO 3 *** ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
				-- Solicitud de TDC Coppel - Solicitud de Cuenta Efectiva
				FOREACH with hold					
					SELECT a.num_solicitud as Coppel,'' as Banco,a.status_solicitud as cstatussol,
						'' as bstatusSol, a.numcte as n_cte, a.fecha_insert as dfec_insert, 3 as Cvalortramite
					INTO vCoppel,vbanco,vcstatusSol,vbstatusSol,vcn_cte,vdfec_insert,vCvalortramite
					FROM bdisolic:"informix".ss_solicitudes as a
					WHERE a.empresa ='001'
					AND a.num_producto ='6500' AND a.sucursal = a.sucursal
					AND a.status_solicitud NOT IN('AN','PC')
					AND a.numcte NOT IN (select numcte from bdisolic:"informix".ss_solicitudes WHERE empresa ='001' AND
							fecha_insert = a.fecha_insert and num_producto in('6001') and status_solicitud NOT IN('AN','PC') AND user_insert = a.user_insert AND sucursal = a.sucursal)
					AND a.numcte in (SELECT num_cte FROM bdicheq:"informix".sc_maechq mae
									INNER JOIN bdicheq:"informix".sc_maenoc noc ON (mae.empresa = noc.empresa AND mae.cuenta = noc.cuenta and noc.clase_cta = noc.clase_cta) 
									where mae.empresa ='001' and mae.producto = 2000 and noc.fecha_alta = a.fecha_insert)
					AND a.fecha_insert  BETWEEN pFechaIni and pFechaFin
					----- ----- ----- ----- -----
						BEGIN;   
							insert into bdisolic:"informix".tmp_tipotramite(coppel,banco,cstatussol,bstatusSol,n_cte,dfec_insert,cvalortramite)
							values (vCoppel,vbanco,vcstatusSol,vbstatusSol,vcn_cte,vdfec_insert,vCvalortramite);				  
						COMMIT;	
					----- ----- ----- ----- -----
				END FOREACH;	
				----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----										
				----- *** CASO 2 *** ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
				-- Solicitud de TDC Coppel - Solicitud de TDC VISA 
				FOREACH with hold					
					SELECT a.num_solicitud as Coppel, b.num_solicitud as Banco,a.status_solicitud as cstatussol,
						b.status_solicitud as bstatusSol, a.numcte as n_cte, a.fecha_insert as dfec_insert, 2 as Cvalortramite
					INTO vCoppel,vbanco,vcstatusSol,vbstatusSol,vcn_cte,vdfec_insert,vCvalortramite
					FROM bdisolic:"informix".ss_solicitudes AS a 
					JOIN bdisolic:"informix".ss_solicitudes AS b 
					ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.sucursal = b.sucursal AND a.user_insert = b.user_insert 
									AND a.fecha_insert = b.fecha_insert)
					WHERE a.empresa = '001' 
					AND a.rowid = (b.rowid + 1) AND a.sucursal = a.sucursal
					AND a.num_producto = '6500' AND b.num_producto = '6001'
					AND a.status_solicitud NOT IN ('PC','AN')
					AND b.status_solicitud NOT IN ('PC','AN')
					AND a.numcte not IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq mae
										INNER JOIN bdicheq:"informix".sc_maenoc noc ON (mae.empresa = noc.empresa AND mae.cuenta = noc.cuenta and noc.clase_cta = noc.clase_cta) 
										where mae.empresa ='001' and mae.producto = 2000 and noc.fecha_alta  = a.fecha_insert)			
					AND a.fecha_insert BETWEEN pFechaIni and pFechaFin
					AND b.fecha_insert BETWEEN pFechaIni and pFechaFin
					----- ----- ----- ----- -----
					UNION
					----- ----- ----- ----- -----
					SELECT a.num_solicitud as Coppel, b.num_solicitud as Banco,a.status_solicitud as cstatussol,
						b.status_solicitud as bstatusSol, a.numcte as n_cte, a.fecha_insert as dfec_insert, 2 as Cvalortramite
					FROM bdisolic:"informix".ss_solicitudes AS a 
					JOIN bdisolic:"informix".ss_solicitudes AS b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.sucursal = b.sucursal AND a.user_insert = b.user_insert AND a.fecha_insert = b.fecha_insert)
					WHERE a.empresa = '001' 
					and a.num_solicitud not in (SELECT a.num_solicitud FROM bdisolic:"informix".ss_solicitudes AS a 
												JOIN bdisolic:"informix".ss_solicitudes AS b 
												ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.sucursal = b.sucursal AND a.user_insert = b.user_insert AND a.fecha_insert = b.fecha_insert)
												WHERE a.empresa = '001' 
												AND a.rowid = (b.rowid + 1) AND a.sucursal = a.sucursal
												AND a.num_producto = '6500' AND b.num_producto = '6001'
												AND a.status_solicitud NOT IN ('PC','AN')
												AND b.status_solicitud NOT IN ('PC','AN')
												AND a.numcte not IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq mae
																	INNER JOIN bdicheq:"informix".sc_maenoc noc ON (mae.empresa = noc.empresa AND mae.cuenta = noc.cuenta and noc.clase_cta = noc.clase_cta) 
																	where mae.empresa ='001' and mae.producto = 2000 and noc.fecha_alta = a.fecha_insert)			
												AND a.fecha_insert BETWEEN pFechaIni and pFechaFin
												AND b.fecha_insert BETWEEN pFechaIni and pFechaFin)
					AND a.rowid <> (b.rowid + 1) AND a.sucursal = a.sucursal
					AND a.num_producto = '6500' AND b.num_producto = '6001'
					AND a.status_solicitud NOT IN ('PC','AN')
					AND b.status_solicitud NOT IN ('PC','AN')
					AND a.numcte not IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq mae
										INNER JOIN bdicheq:"informix".sc_maenoc noc ON (mae.empresa = noc.empresa AND mae.cuenta = noc.cuenta and noc.clase_cta = noc.clase_cta) 
										where mae.empresa ='001' and mae.producto = 2000 and noc.fecha_alta = a.fecha_insert)
					AND a.fecha_insert BETWEEN pFechaIni and pFechaFin
					AND b.fecha_insert BETWEEN pFechaIni and pFechaFin
					----- ----- ----- ----- -----
						BEGIN;   
							insert into bdisolic:tmp_tipotramite(coppel,banco,cstatussol,bstatusSol,n_cte,dfec_insert,cvalortramite)
							values (vCoppel,vbanco,vcstatusSol,vbstatusSol,vcn_cte,vdfec_insert,vCvalortramite);				  
						COMMIT;
					----- ----- ----- ----- -----
				END FOREACH;
				----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----											
				----- *** CASO 1 *** ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
				-- Solicitud de TDC Coppel - Solicitud de TDC VISA - Solicitud de Cuenta Efectiva
				FOREACH with hold					
					SELECT a.num_solicitud as Coppel, b.num_solicitud as Banco,a.status_solicitud as cstatussol,
						b.status_solicitud as bstatusSol, a.numcte as n_cte, a.fecha_insert as dfec_insert, 1 as Cvalortramite
					INTO vCoppel,vbanco,vcstatusSol,vbstatusSol,vcn_cte,vdfec_insert,vCvalortramite 
					FROM bdisolic:"informix".ss_solicitudes AS a 
					JOIN bdisolic:"informix".ss_solicitudes AS b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.sucursal = b.sucursal 
										AND a.user_insert = b.user_insert AND a.fecha_insert = b.fecha_insert)
					WHERE a.empresa = '001' 
					AND a.rowid = (b.rowid + 1) AND a.sucursal = a.sucursal
					AND a.num_producto = '6500' AND b.num_producto = '6001'
					AND a.status_solicitud NOT IN ('PC','AN')
					AND b.status_solicitud NOT IN ('PC','AN')
					AND a.numcte IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq mae
									INNER JOIN bdicheq:"informix".sc_maenoc noc ON (mae.empresa = noc.empresa AND mae.cuenta = noc.cuenta and noc.clase_cta = noc.clase_cta) 
									where mae.empresa ='001' and mae.producto = 2000 and noc.fecha_alta = a.fecha_insert)			
					AND a.fecha_insert BETWEEN pFechaIni and pFechaFin
					AND b.fecha_insert BETWEEN pFechaIni and pFechaFin
					----- ----- ----- ----- -----
					UNION
					----- ----- ----- ----- -----
					SELECT a.num_solicitud as Coppel, b.num_solicitud as Banco,a.status_solicitud as cstatussol,
						b.status_solicitud as bstatusSol, a.numcte as n_cte, a.fecha_insert as dfec_insert, 1 as Cvalortramite
					FROM bdisolic:"informix".ss_solicitudes AS a 
					JOIN bdisolic:"informix".ss_solicitudes AS b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.sucursal = b.sucursal 
										AND a.user_insert = b.user_insert AND a.fecha_insert = b.fecha_insert)
					WHERE a.empresa = '001' 
					AND a.num_solicitud NOT IN (SELECT a.num_solicitud FROM bdisolic:"informix".ss_solicitudes AS a 
												JOIN bdisolic:"informix".ss_solicitudes AS b 
												ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.sucursal = b.sucursal AND a.user_insert = b.user_insert AND a.fecha_insert = b.fecha_insert)
												WHERE a.empresa = '001' 
												AND a.rowid = (b.rowid + 1) AND a.sucursal = a.sucursal
												AND a.num_producto = '6500' AND b.num_producto = '6001'
												AND a.status_solicitud NOT IN ('PC','AN')
												AND b.status_solicitud NOT IN ('PC','AN')
												AND a.numcte IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq mae
																INNER JOIN bdicheq:"informix".sc_maenoc noc ON (mae.empresa = noc.empresa AND mae.cuenta = noc.cuenta and noc.clase_cta = noc.clase_cta) 
																where mae.empresa ='001' and mae.producto = 2000 and noc.fecha_alta = a.fecha_insert)			
												AND a.fecha_insert BETWEEN pFechaIni and pFechaFin
												AND b.fecha_insert BETWEEN pFechaIni and pFechaFin)
					AND a.rowid <> (b.rowid + 1) AND a.sucursal = a.sucursal
					AND a.num_producto = '6500' AND b.num_producto = '6001'
					AND a.status_solicitud NOT IN ('PC','AN')
					AND b.status_solicitud NOT IN ('PC','AN')
					AND a.numcte IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq mae
									INNER JOIN bdicheq:"informix".sc_maenoc noc ON (mae.empresa = noc.empresa AND mae.cuenta = noc.cuenta and noc.clase_cta = noc.clase_cta) 
									where mae.empresa ='001' and mae.producto = 2000 and noc.fecha_alta = a.fecha_insert)			
					AND a.fecha_insert BETWEEN pFechaIni and pFechaFin
					AND b.fecha_insert BETWEEN pFechaIni and pFechaFin
					----- ----- ----- ----- -----
						BEGIN;   
							insert into bdisolic:tmp_tipotramite(coppel,banco,cstatussol,bstatusSol,n_cte,dfec_insert,cvalortramite)
							values (vCoppel,vbanco,vcstatusSol,vbstatusSol,vcn_cte,vdfec_insert,vCvalortramite);				  
						COMMIT;
					----- ----- ----- ----- -----
				END FOREACH;								
				----- ----- ----- ----- ----- -----				
			----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
            -- VALIDA LOS PARAMETROS DE ENTRADA
            IF  NVL(pFechaini,"") =  ""  OR  NVL(pFechaFIN,"") =  "" THEN
                LET cCodRet = '000001';
                LET cMensajeRet = 'Parametros de entrada incompletos,verifique';
            ELSE							
                foreach	
                    ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
                     SELECT numcte,fecha_insert,tipo_solicitud 
                        INTO cNumCte, dfecha_insert,ctipo_solicitud
                        FROM bdisolic:"informix".ss_solicitudes
                        WHERE empresa = '001' AND sucursal = sucursal
						AND	num_producto = '6500'
						AND status_solicitud NOT IN ('PC','AN')
						AND fecha_insert BETWEEN pFechaini AND pFechaFIN
                    ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
					SELECT FIRST 1 coppel,banco,cstatussol,bstatusSol,n_cte,dfec_insert,cvalortramite
					INTO ccoppel,cbanco,ccstatusSol,cbstatusSol,cn_cte,vdf_insert,icvalortramite
					FROM bdisolic:tmp_tipotramite where n_cte = cNumCte and dfec_insert = dfecha_insert;
					----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----					
					IF (ccoppel <> '')THEN
						LET cnumsol_CPL = ccoppel;
					ELSE
						LET cnumsol_CPL = '';
					END IF;
					----- ----- ----- -----
					IF (icvalortramite = 1) OR (icvalortramite = 2) THEN
						LET cnumsol_BCPL = cbanco;
						-----
						LET cestatus_BCPL = cbstatusSol;
						-----
						select evaluacion into dBC_Score from bdisolic:"informix".ss_resumen_scoring 
							WHERE empresa = '001' AND num_solicitud = ccoppel AND seccion = '1';
							
						IF (dBC_Score is null) or (dBC_Score = '')THEN
						
							Select nvl(sum(nvl(puntuacion,0)),0) 
							 INTO dBC_Score
							From bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf 
							where rsf.empresa = '001'
							and rsf.num_solicitud = ccoppel
							and rsf.empresa = sf.empresa 
							and upper(sf.tp_solicitud) = ctipo_solicitud
							and sf.circulo_credito = rsf.evalua_cc
							and sf.min_mes_hist <= rsf.meses_historia 
							and sf.max_mes_hist >= rsf.meses_historia 
							and sf.min_porc_pago <= rsf.situacion_pago 
							and sf.max_porc_pago >= rsf.situacion_pago;		
						END IF;
						-----
						select evaluacion into cscore_Propietario from bdisolic:"informix".ss_resumen_scoring 
							WHERE empresa = '001' AND num_solicitud = ccoppel AND seccion = '2';
							
						IF (cscore_Propietario is null) or (cscore_Propietario = '') THEN
						
							Select  nvl(sum(nvl(dc.valor,0)),0) 
						     INTO cscore_Propietario
							From bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg 
							Where sg.empresa = dc.empresa 
							and sg.grupo = dc.grupo 
							and sg.seccion = dc.seccion 
							and dc.num_solicitud = ccoppel 
							and dc.seccion = '2' 
							and dc.empresa = '001';  
						
						END IF;
						-----
					ELSE
						LET cnumsol_BCPL = '';
						LET cestatus_BCPL = '';
						LET dBC_Score = '';	
						LET cscore_Propietario = '';
					END IF;
					----- ----- ----- -----	
						IF (ccstatusSol = 'RT') THEN
							SELECT {+INDEX ( bdisolic:"informix".ss_autorizacion empsolsta )} causa_solicitud INTO ccausaRT_CPL --ccausa
								FROM bdisolic:"informix".ss_autorizacion
								where empresa = '001' AND num_solicitud = ccoppel 
								AND status_solicitud = ccstatusSol AND fecha_insert = dfecha_insert
								AND ROWID in (SELECT max(rowid) from bdisolic:"informix".ss_autorizacion 
											WHERE num_solicitud = ccoppel and status_solicitud = ccstatusSol 
											and fecha_insert = dfecha_insert);
						ELSE	
							--LET ccausaRT_BCPL = '';
							LET ccausaRT_CPL = '';
						END IF;
						-----
						IF (cbstatusSol = 'RT') THEN							
							SELECT {+INDEX ( bdisolic:"informix".ss_autorizacion empsolsta )} causa_solicitud INTO ccausaRT_BCPL
							FROM bdisolic:"informix".ss_autorizacion
							where empresa = '001' AND num_solicitud = cbanco 
							AND status_solicitud = cbstatusSol AND fecha_insert = dfecha_insert
							AND ROWID in (SELECT max(rowid) from bdisolic:"informix".ss_autorizacion 
									WHERE num_solicitud = cbanco and status_solicitud = cbstatusSol 
									and fecha_insert = dfecha_insert);
						ELSE	
							LET ccausaRT_BCPL = '';
							--LET ccausaRT_CPL = ccausa;
						END IF;
					----- ----- ----- -----
					SELECT (CASE resultadofinal WHEN NULL THEN 'S' WHEN '' THEN 'S' ELSE resultadofinal END) AS Rep_SupTel
						INTO crep_SupTel FROM bdisolic:"informix".ss_ostelrefsolicitud WHERE num_solicitud = ccoppel 
						AND ROWID IN (SELECT MAX(rowid) from bdisolic:"informix".ss_ostelrefsolicitud WHERE num_solicitud = ccoppel);
					----- ----- ----- -----
					SELECT (CASE automatico WHEN NULL THEN '0' WHEN '' THEN '1' ELSE automatico END) AS Tiempo_Sup_Tel
						INTO ctiempo_Sup_Tel FROM bdisolic:"informix".ss_ostelrefsolicitud WHERE num_solicitud = ccoppel
						AND ROWID IN (SELECT MAX(rowid) from bdisolic:"informix".ss_ostelrefsolicitud WHERE num_solicitud = ccoppel);
					----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----					
                    SELECT FIRST 1 a.sucursal AS Suc_alta, a.status_solicitud AS Estatus_CPL,                    
                    d.puntos_parcn AS Puntosparcn, d.limitecreditopesos AS Limitecreditopesos, d.limitecredito AS Limitecredito
					INTO csuc_alta,cEstatus_CPL, 
						spuntosparcn,ilimitecreditopesos,ilimitecredito
                    FROM bdisolic:"informix".ss_solicitudes               AS a                     
                    LEFT JOIN bdisolic:"informix".ss_nuevo_parametrico    AS d ON (a.empresa = d.empresa AND a.num_solicitud = d.num_solicitud)                    
                    WHERE a.empresa = '001'
					AND a.num_solicitud = ccoppel
					AND a.numcte = cNumCte
					AND a.fecha_insert = dfecha_insert;				
                    ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----                    
					-- ASignamos el valor a una tabla fisica para despues ser elimINada
					INSERT INTO bdisolic:tmp_datosgeneral(numcte,Fecha_Alta,Suc_alta,Tipo_tramite,numsol_CPL,Estatus_CPL,causaRT_CPL,
						numsol_BCPL,estatus_BCPL,causaRT_BCPL,Rep_SupTel,Tiempo_Sup_Tel,BC_Score,Score_Propietario,Puntosparcn, 
						Limitecreditopesos, Limitecredito)
					values(cNumCte,dfecha_insert,csuc_alta,icvalortramite,cnumsol_CPL,cEstatus_CPL,ccausaRT_CPL,cnumsol_BCPL,cestatus_BCPL,
							ccausaRT_BCPL,crep_SupTel,ctiempo_Sup_Tel,dBC_Score,cscore_Propietario,spuntosparcn,ilimitecreditopesos,ilimitecredito);				
					----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
                END foreach;
                ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
				-- ASignar el nombre del archivo que debe de cargar.
                -- "ProdCred_130101_130107.txt" (Nombre del archivo)
                LET cNombre_Archivo ='ProdCred_'||SUBSTRING(pFechaini FROM 9 FOR 2)||SUBSTRING(pFechaini FROM 1 FOR 2)||SUBSTRING(pFechaini FROM 4 FOR 2)||'_'||
                    SUBSTRING(pFechaFIN FROM 9 FOR 2)||SUBSTRING(pFechaFIN FROM 1 FOR 2)||SUBSTRING(pFechaFIN FROM 4 FOR 2)||'.txt';
								
				-- // DESCARGA ARCHIVO  \\10.26.211.78\sisperproc\Alta Unica\semanal
				LET cSql = '';
				let cSql = ' echo "numcte|Fecha_Alta|Suc_alta|Tipo_tramite|numsol_CPL|Estatus_CPL|causaRT_CPL|'|| ' ' ||
					'numsol_BCPL|estatus_BCPL|causaRT_BCPL|Rep_SupTel|Tiempo_Sup_Tel|BC_Score|Score_Propietario|'|| ' ' ||
					'Puntosparcn|Limitecreditopesos|Limitecredito'|| ' ' || 
					'">/resplogifx/archivoscartera/' || trim(cNombre_Archivo);
				system cSql;
				let cSql = '';
				-- se le asigna el resultado a un archivo extra que sera agregado al archivo final el archivo es prod_credito1
				--- el cual se le asigna el resultado final de la consulta.
				let cSql= 	'echo "SET ISOLATION TO DIRTY READ;'||' '||
							'set lock mode to wait 4;'||' '||
							'UNLOAD TO /resplogifx/archivoscartera/prod_credito1.unl '|| ' ' ||
							'SELECT numcte,Fecha_Alta,Suc_alta,Tipo_tramite,numsol_CPL,Estatus_CPL,causaRT_CPL, '|| ' ' ||
							'numsol_BCPL,estatus_BCPL,causaRT_BCPL,Rep_SupTel,Tiempo_Sup_Tel,BC_Score,Score_Propietario,Puntosparcn, '|| ' ' ||
							'Limitecreditopesos, Limitecredito '|| ' ' ||
							'FROM bdisolic:tmp_datosgeneral; " > /resplogifx/archivoscartera/prod_credito.sql';
				system cSql;
				LET cSql = '';
				-- Asignamos el unload a un archivo .sql para ser cargado.
				LET cSql = "dbaccess bdisolic /resplogifx/archivoscartera/prod_credito.sql"; 
				SYSTEM cSql;
				LET cSql = '';
				-- borramos el archivo de la carpeta.
				let cSql ='rm /resplogifx/archivoscartera/prod_credito.sql';
				system cSql;
				LET cSql = '';
				-- Le asignamos el valor al archivo final.
				let cSql = "sed 's/|$//g' /resplogifx/archivoscartera/prod_credito1.unl >>/resplogifx/archivoscartera/" || trim(cNombre_Archivo);
				system cSql;
				-- Borramos el archivo que se genero para cargar la informacion del select.
				let cSql ='rm /resplogifx/archivoscartera/prod_credito1.unl';
				system cSql;
				
            END IF;
			----- ----- ----- -----
			RETURN cCodRet,cMensajeRet;
            ----- ----- ----- ----- 
END;
END PROCEDURE
;