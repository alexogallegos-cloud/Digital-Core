CREATE PROCEDURE "informix".sp_obtienedatos_solbco(pEmpresa CHAR(3),pNumSol CHAR(20),pNumCte CHAR(20))
	RETURNING 	CHAR(6) 					AS Cod_Ret,
				CHAR(5) 					AS Prod_Banco,
				CHAR(3)						AS Status_Solbco,
				INTEGER						AS Monto_LcBanco,
				CHAR(19)					AS Fecha_RespBanco,
				CHAR(1)						AS Origen_SolCoppel;
	
	DEFINE iSqlErr						INTEGER;					
	DEFINE cCod_Ret						CHAR(6);	
	DEFINE dtFechaHoy					DATE;
	DEFINE cNumSolicMixta				CHAR(20);
	DEFINE cNum_producto_bco			CHAR(5);
	DEFINE cStatus_solicitud_bco		CHAR(3);
	DEFINE iMonto_lc_bco				INTEGER;
	DEFINE cFecha_resp_bco				CHAR(19);
	DEFINE cOrigenSolic					CHAR(1);
	DEFINE dtFechaHora					DATETIME YEAR TO SECOND;
	DEFINE cCteProsp					CHAR(1);
	DEFINE iNumSucursal					INTEGER;
	DEFINE cEjecutivo					CHAR(9);
	DEFINE cOrigenPros					CHAR(1);
	DEFINE cTpsol                       CHAR(1);
	DEFINE iIdEmpCob					INTEGER; --DSB 23/12/2021

	LET cCod_Ret						= '000000';	
	LET iSqlErr							= 0;
	LET dtFechaHoy						=  DATE(1);
	LET cNumSolicMixta					= '';
	LET cNum_producto_bco				= '';
	LET cStatus_solicitud_bco			= '';
	LET iMonto_lc_bco					= 0;
	LET cFecha_resp_bco					= '1900-01-01 00:00:00';
	LET cOrigenSolic					= '0';
	LET dtFechaHora						= DATE(1);
	LET cCteProsp						= '';
	LET iNumSucursal					= 0;
	LET pEmpresa						= TRIM(NVL(pEmpresa,''));
	LET pNumSol							= TRIM(NVL(pNumSol,''));
	LET pNumCte							= TRIM(NVL(pNumCte,''));
	LET cOrigenPros						= '';
	LET cTpsol                          = '';
	LET iIdEmpCob						= 0;	--DSB 23/12/2021
	LET cEjecutivo						= '';	 
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCod_Ret = iSqlErr;
			RETURN cCod_Ret,cNum_producto_bco,cStatus_solicitud_bco,iMonto_lc_bco,cFecha_resp_bco,cOrigenSolic;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/sp_obtienedatos_solbco.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEmpresa <> '' AND pNumCte <> '' AND pNumSol <> '' THEN
		
			SELECT fecha_hoy
			INTO dtFechaHoy
			FROM bdinteg:"informix".si_fechas
			WHERE empresa = pEmpresa;	
			
			LET dtFechaHoy = nvl(dtFechaHoy,date(1));
			
			--SELECCIONA EL TIPO DE SOLICITUD QUE ES
			SELECT tipo_solicitud 
			INTO cTpsol
			FROM bdisolic:"informix".ss_solicitudes
			WHERE num_solicitud = pNumSol;
					
			--SELECCIONA SI EL PROCESO DE SOLICITUD COPPEL
			-- FUE MIXTO O UNICO			
			SELECT num_solicitud_ref
			INTO cNumSolicMixta
			FROM "informix".ss_resum_scor_fin
			WHERE empresa = pEmpresa
			AND num_solicitud = pNumSol; 

			LET cNumSolicMixta = TRIM(NVL(cNumSolicMixta,''));		

			IF cTpsol = 'C' THEN
			    IF cNumSolicMixta <> '' THEN					  
					FOREACH
						--SELECT FIRST 1 fecha_hora,status_solicitud
						SELECT FIRST 1 '1900-01-01 00:00:00',status_solicitud
						INTO dtFechaHora,cStatus_solicitud_bco
						FROM bdisolic:"informix".ss_autorizacion
						WHERE num_solicitud = cNumSolicMixta
						AND status_solicitud != 'BC'
						AND fecha_hora >= (SELECT MAX(fecha_hora)
											FROM bdisolic:"informix".ss_autorizacion
											WHERE num_solicitud = cNumSolicMixta
											AND status_solicitud = 'BC')
						AND status_solicitud NOT IN ('BC','PC','AN','CC')
						GROUP BY fecha_hora,status_solicitud
						ORDER BY fecha_hora ASC
					END FOREACH;

					--MONTO DE LA LINEA DE CREDITO DE LA SOLICITU DE BANCO
					--SELECT linea_credito,num_producto
					SELECT '0',num_producto
					INTO iMonto_lc_bco,cNum_producto_bco
					FROM "informix".ss_revision_determinacion
					WHERE empresa = pEmpresa
					AND num_solicitud = cNumSolicMixta;
				
					LET cStatus_solicitud_bco	= TRIM(NVL(cStatus_solicitud_bco,''));  
					
					IF cStatus_solicitud_bco = '' THEN
						LET cNum_producto_bco = '';
					END IF;
				ELSE
					--PROCESO UNICO
					--SELECCIONA LOS DATOS DE ALGUN PRODUCTO DE BANCO PARA ENVIAR AL PARAMETRICO DE COPPEL
					--CON ANTIGÃÂÃÂ¼EDAD NO MAYOR A 3 MESES DE LA FECHA ACTUAL
					SELECT FIRST 1  num_solicitud, status_solicitud, fecha_hora
					INTO  cNumSolicMixta,cStatus_solicitud_bco,dtFechaHora
					FROM bdisolic:"informix".ss_solicitudes
					WHERE empresa = pEmpresa
					AND numcte = pNumCte
					AND num_solicitud != pNumSol
					AND status_solicitud IN ('AT','AP')
					AND (MONTHS_BETWEEN(dtFechaHoy, fecha_hora)) <= 3;
		
					--MONTO DE LA LINEA DE CREDITO DE LA SOLICITU DE BANCO
					SELECT linea_credito,num_producto
					INTO iMonto_lc_bco,cNum_producto_bco
					FROM "informix".ss_revision_determinacion
					WHERE empresa = pEmpresa
					AND num_solicitud = cNumSolicMixta;
						
					LET cStatus_solicitud_bco	= TRIM(NVL(cStatus_solicitud_bco,''));  
							
					IF cStatus_solicitud_bco = '' THEN
						LET cNum_producto_bco = '';
					END IF;
				END IF;
			ELIF cTpsol = 'T' THEN
				FOREACH
					--SELECT FIRST 1 fecha_hora,status_solicitud
					SELECT FIRST 1 '1900-01-01 00:00:00',status_solicitud
					INTO dtFechaHora,cStatus_solicitud_bco
					FROM bdisolic:"informix".ss_autorizacion
					WHERE num_solicitud = pNumSol
					AND status_solicitud != 'BC'
					AND fecha_hora >= (SELECT MAX(fecha_hora)
										FROM bdisolic:"informix".ss_autorizacion
										WHERE num_solicitud = pNumSol
										AND status_solicitud = 'BC')
					AND status_solicitud NOT IN ('BC','PC','AN','CC')
					GROUP BY fecha_hora,status_solicitud
					ORDER BY fecha_hora ASC
				END FOREACH;

				--MONTO DE LA LINEA DE CREDITO DE LA SOLICITU DE BANCO
				--SELECT linea_credito,num_producto
				SELECT '0',num_producto
				INTO iMonto_lc_bco,cNum_producto_bco
				FROM "informix".ss_revision_determinacion
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol;
			
				LET cStatus_solicitud_bco	= TRIM(NVL(cStatus_solicitud_bco,''));  
				
				IF cStatus_solicitud_bco = '' THEN
					LET cNum_producto_bco = '';
				END IF;
			END IF;
			
			/*SELECT s.sucursal, l.ejecutivo INTO iNumSucursal, cEjecutivo
			FROM bdisolic: "informix".ss_solicitudes s 
			inner join  bdinteg: si_solicitud_movil_online  l on s.numcte = l.numcte
			WHERE s.empresa = pEmpresa AND s.num_solicitud = pNumSol ;
			*/ 
			
			--DSB 23/12/2021 INI
			SELECT sucursal INTO iNumSucursal
			FROM "informix".ss_solicitudes
			WHERE empresa = pEmpresa AND num_solicitud = pNumSol;
			
			
			
			IF iNumSucursal = 8503 THEN
				--DSB cobranza calle
				SELECT  canal_sol
				INTO cOrigenSolic
				FROM bdisolic: "informix".ss_solicitudes s 
				WHERE  empresa = pEmpresa AND  num_solicitud = pNumSol ; 
					
			ELSE
				LET iNumSucursal = 0;
			--DSB 23/12/2021 FIN

				--VERIFICA EL CANAL DE ORIGEN DE LA SOLICITUD COPPEL
				SELECT MAX(cliente_pros)
				INTO cCteProsp
				FROM "informix".ss_autorizacion
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol;

				LET cCteProsp = TRIM(NVL(cCteProsp,''));
				
				IF cCteProsp <> '' THEN
					SELECT sucursal:: INTEGER
					INTO iNumSucursal
					FROM bdiprospectos:"informix".pr_cliente
					WHERE numcte = pNumCte;

					LET iNumSucursal = NVL(iNumSucursal,0);
					
					IF iNumSucursal = 800 THEN
						--EL ALTA FUE REALIZADO EN COPPEL.COM
						LET cOrigenSolic = '3';
					ELSE
						--DSB 23/12/2021 INI
						/*SELECT prn.canal_origenpros INTO cOrigenPros FROM  bdiprospectos:"informix".pr_nuevo_parametrico prn
						INNER JOIN bdiprospectos:"informix".pr_cliente pc ON pc.numcte_pros = prn.num_solicitud 							
						WHERE pc.numcte = pNumCte;					
						IF NVL(cOrigenPros,'') = '' THEN
							--EL ALTA FUE REALIZADO EN CALLE,
							--O ESUN CLIENTE PRESENTE EN SUCURSAL
							--SIN IDENTIFICACION OFICIAL
							LET cOrigenSolic = '2';
						ELSE	
							LET cOrigenSolic = cOrigenPros;
						END IF;*/

						SELECT prn.canal_origenpros, pc.id_empcob INTO cOrigenPros, iIdEmpCob
						FROM bdiprospectos:"informix".pr_nuevo_parametrico prn
						INNER JOIN bdiprospectos:"informix".pr_cliente pc ON pc.numcte_pros = prn.num_solicitud
							AND pc.status_numcte_pros NOT IN ('CN','AN','PC','RT')
						WHERE prn.empresa = '001'
						AND pc.numcte = pNumCte;

						IF NVL(cOrigenPros,'') = '' THEN
							--EL ALTA FUE REALIZADO EN CALLE,
							--O ESUN CLIENTE PRESENTE EN SUCURSAL
							--SIN IDENTIFICACION OFICIAL
							LET cOrigenSolic = '2';
						ELIF NVL(cOrigenPros,'') = '0' THEN
							IF NVL(iIdEmpCob,0) = 0 THEN
								LET cOrigenSolic = "1";
							ELSE
								LET cOrigenSolic = "2";
							END IF;
						ELSE
							LET cOrigenSolic = cOrigenPros;
						END IF;
						--DSB 23/12/2021 FIN
					END IF; 
				ELSE
					--SE VALIDA SI ES UNA SOLICITUD WEB ---ANJ2020
					SELECT canal_sol INTO cOrigenSolic FROM ss_prospecteo_solicitudes WHERE num_solicitud = pNumSol; 
					
					IF NVL(cOrigenSolic,'0')= '0' THEN
						--DSB 23/12/2021 INI
						/*SELECT prn.canal_origenpros INTO cOrigenPros FROM  bdiprospectos:"informix".pr_nuevo_parametrico prn
						INNER JOIN bdiprospectos:"informix".pr_cliente pc ON pc.numcte_pros = prn.num_solicitud 							
						WHERE pc.numcte = pNumCte;						
						IF NVL(cOrigenPros,'') = '' THEN
							--EL ALTA FUE REALIZADO EN SUCURSAL
							LET cOrigenSolic = '1';
						ELSE	
							LET cOrigenSolic = cOrigenPros;
						END IF;*/
						
						SELECT prn.canal_origenpros, pc.id_empcob INTO cOrigenPros, iIdEmpCob
						FROM bdiprospectos:"informix".pr_nuevo_parametrico prn
						INNER JOIN bdiprospectos:"informix".pr_cliente pc ON pc.numcte_pros = prn.num_solicitud
							AND pc.status_numcte_pros NOT IN ('CN','AN','PC','RT')
						WHERE prn.empresa = '001'
						AND pc.numcte = pNumCte;

						IF NVL(cOrigenPros,'') = '' THEN
							--EL ALTA FUE REALIZADO EN SUCURSAL
							LET cOrigenSolic = '1';
						ELIF NVL(cOrigenPros,'') = '0' THEN
							IF NVL(iIdEmpCob,0) = 0 THEN
								LET cOrigenSolic = "1";
							ELSE
								LET cOrigenSolic = "2";
							END IF;
						ELSE
							LET cOrigenSolic = cOrigenPros;
						END IF;
						--DSB 23/12/2021 FIN
					END IF;
				END IF;
				LET cNum_producto_bco	= TRIM(NVL(cNum_producto_bco,''));
				LET cFecha_resp_bco	= TRIM(NVL(dtFechaHora::CHAR(19),'1900-01-01 00:00:00'));
				LET iMonto_lc_bco	= NVL(iMonto_lc_bco,0);
				LET cOrigenSolic = TRIM(NVL(cOrigenSolic,'0'));
			END IF;	--DSB 23/12/2021
		ELSE
			LET cCod_Ret = '000001';	
		END IF;
		
        IF NVL(cOrigenSolic,'')='' THEN
            LET cOrigenSolic="2";
        END IF;


		RETURN cCod_Ret,cNum_producto_bco,cStatus_solicitud_bco,iMonto_lc_bco,cFecha_resp_bco,cOrigenSolic;
		
	END;				
END PROCEDURE
