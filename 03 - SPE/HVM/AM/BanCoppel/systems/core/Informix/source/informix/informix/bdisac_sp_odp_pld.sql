CREATE PROCEDURE "informix".sp_odp_pld(NombreProceso CHAR(3),FechaIni DATE, FechaFin DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

	DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
	DEFINE cCodRet              CHAR(5);
	DEFINE cMensaje				CHAR(80);	
	DEFINE cStatus				CHAR(1);	
	DEFINE dFecha_Envio             DATE;
    DEFINE dFecha_Pago         		DATE;
    DEFINE cTipo_Orden              CHAR(3);
    DEFINE cNum_Control            	CHAR(20);
    DEFINE cEstatus	                CHAR(10);
    DEFINE mMonto_Total		        MONEY;
    DEFINE cFolio_Sucursal          CHAR(16);
    DEFINE cBeneficiario_Nombre1    CHAR(30);
    DEFINE cBeneficiario_Nombre2    CHAR(30);
    DEFINE cBeneficiario_Appaterno  CHAR(30);
    DEFINE cBeneficiario_Apmaterno  CHAR(30);
    DEFINE cBeneficiario_tpo_Identificacion	CHAR(2);
    DEFINE cBeneficiario_num_Identificacion CHAR(25);
    DEFINE cBeneficiario_Direccion	CHAR(80);
	DEFINE cOrdenante_Nombre1		CHAR(30);
	DEFINE cOrdenante_Nombre2		CHAR(30);
	DEFINE cOrdenante_Appaterno		CHAR(30);
	DEFINE cOrdenante_Apmaterno		CHAR(30);
	DEFINE cOrdenante_Direccion		CHAR(80);
	DEFINE cOrdenante_Telefono		CHAR(20);
	DEFINE cSucursal_Numero_Origen	CHAR(4);
	DEFINE cUsuario_Envio			CHAR(8);
	DEFINE cSucursal_Numero_Destino	CHAR(4);
	DEFINE cUsuario_Pago			CHAR(8);
	DEFINE dFecha_Proceso			DATE;	
	DEFINE dFecha_alt				DATE;
	DEFINE cCancelad				CHAR(1);
	DEFINE cSucursal				CHAR(4);
	DEFINE cReferencia				CHAR(40);
	DEFINE cReferencia1				CHAR(40);
	DEFINE cUsuario					CHAR(8);
	DEFINE cCategoria				CHAR(2);
	DEFINE cConvenio				CHAR(5);	
	DEFINE iCuantosCheq				INTEGER;
	DEFINE iCuantosMovtos			INTEGER;
	DEFINE iCuantosEnvTot			INTEGER;
	DEFINE cTransacc				CHAR(4);	
	
	DEFINE dHora_envio				DATETIME HOUR TO FRACTION (3);
	DEFINE dHora_pago				DATETIME HOUR TO FRACTION (3);
	DEFINE cBeneficiario_telefono	CHAR(20);
	DEFINE cTipo_identificacion		CHAR(2);
	DEFINE cNumero_identificacion	CHAR(25);
	DEFINE cSucursal_pagadora		CHAR(4);	
	DEFINE cDescripcionSPJ	 CHAR(100);
	
	LET cCodRet  =   "00000";
	LET cMensaje = 'PROCESO EXITOSO';	
	LET cStatus  					= '0';	
	LET dFecha_Envio             	= mdy(01,01,1900);
    LET dFecha_Pago         		= mdy(01,01,1900);
    LET cTipo_Orden              	= '';
    LET cNum_Control            	= '';
    LET cEstatus	                = '';
    LET mMonto_Total		        = 0;
    LET cFolio_Sucursal          	= '';
    LET cBeneficiario_Nombre1    	= '';
    LET cBeneficiario_Nombre2    	= '';
    LET cBeneficiario_Appaterno  	= '';
    LET cBeneficiario_Apmaterno  	= '';
    LET cBeneficiario_tpo_Identificacion	= '';
    LET cBeneficiario_num_Identificacion 	= '';
    LET cBeneficiario_Direccion		= '';
	LET cOrdenante_Nombre1			= '';
	LET cOrdenante_Nombre2			= '';
	LET cOrdenante_Appaterno		= '';
	LET cOrdenante_Apmaterno		= '';
	LET cOrdenante_Direccion		= '';
	LET cOrdenante_Telefono			= '';
	LET cSucursal_Numero_Origen		= '';
	LET cUsuario_Envio				= '';
	LET cSucursal_Numero_Destino	= '';
	LET cUsuario_Pago				= '';
	LET dFecha_Proceso				= FechaFin;	
	LET dFecha_alt					= '';
	LET cCancelad					= '';
	LET cSucursal					= '';
	LET cReferencia					= '';
	LET cReferencia1				= '';
	LET cUsuario					= '';
	LET cCategoria					= '';
	LET cConvenio					= '';
	LET iCuantosCheq				= 0;
	LET iCuantosMovtos				= 0;
	LET iCuantosEnvTot				= 0;
	LET cTransacc					 = '';
	
	LET dHora_envio					= MDY(9,1,1700);
	LET dHora_pago					= MDY(9,1,1700);
	LET cBeneficiario_telefono		= '';
	LET cTipo_identificacion		= '';
	LET cNumero_identificacion		= '';
	LET cSucursal_pagadora			= '';	
	LET cDescripcionSPJ	 			= 'Inserta datos de Ordenes de Pago para sistema de PLD';
	
	--SET DEBUG FILE TO  '/informix/adrian/pld/sp_odp_pld.out';
	--TRACE ON;
	
	BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_odp_pld" || " " || "Numero Orden:" || cNum_Control);
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		IF NombreProceso = "" OR FechaIni = "" OR FechaFin = "" THEN
			LET cCodRet = '00001';
			LET cMensaje = "FALTAN PARAMETROS DE ENTRADA";
            RETURN cCodRet, cMensaje;
		ELSE
			delete {+INDEX(bdisac:"informix".sac_cheques_odp idxsac_cheques_odpff)} from bdisac:"informix".sac_cheques_odp;
			delete {+INDEX(bdisac:"informix".sac_movtos_odp idxsac_movtos_odpr1)} from bdisac:"informix".sac_movtos_odp;
			IF FechaIni = FechaFin THEN
		
				IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='IND_PLD_OP' and fecha_proceso = FechaFin) THEN									
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_OP', FechaFin, '0', 'informix', 'sp_odp_pld', cDescripcionSPJ);
				ELSE
					SELECT status 
					INTO cStatus
					FROM bdisac:"informix".sac_procesos_jobs 
					WHERE proceso='IND_PLD_OP' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN
						DELETE {+INDEX(bdisac:"informix".sac_pld_ordenes_pago idxsac_pld_odpft)} FROM bdisac:"informix".sac_pld_ordenes_pago 
						WHERE tipo_orden = 'OPA' and fecha_proceso = FechaFin;						
					END IF;
				END IF;			
			END IF;
			
			IF cStatus = '0' THEN
				set isolation to dirty read;
				FOREACH
					--CHEQUES INCLUYENDO ENVIOS,COBROS, CANCELADAS Y REVERSOS
					select NVL(folio_suc,''),NVL(fech_alt,mdy(01,01,1900)),NVL(cancelad,''),NVL(sucursal,''),NVL(referencia,''), NVL(usuario,''), NVL(monto_tot,0), NVL(transacc,'')
					into cFolio_Sucursal, dFecha_alt, cCancelad, cSucursal, cReferencia, cUsuario_Envio, mMonto_Total, cTransacc
					from bdicheq:"informix".sc_movhis
					where fech_alt >= FechaIni
					and fech_alt <= FechaFin
					and transacc in ('1104','1164','1191','1192')			

					INSERT INTO bdisac:"informix".sac_cheques_odp (folio_suc,fech_alt,cancelad,sucursal,referencia, usua, monto_tot, transacc)
					VALUES (cFolio_Sucursal, dFecha_alt, cCancelad, cSucursal, cReferencia, cUsuario_Envio, mMonto_Total, cTransacc);		
					
				END FOREACH;
				
				SELECT count(*)
				INTO iCuantosCheq
				FROM "informix".sac_cheques_odp;
				
				set isolation to dirty read;
				FOREACH
					--MOVIMIENTOS
					select {+INDEX(bdisac:"informix".sac_cheques_odp idxsac_cheques_odpff)} NVL(referencia1,''),NVL(a.folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(b.usua,''),NVL(id_sucursal,''), NVL(numcategoria,''), NVL(numconvenio,''), NVL(referencia,'')
					into cReferencia1, cFolio_Sucursal, dFecha_Pago, cUsuario, cSucursal, cCategoria, cConvenio, cReferencia
					from bdisac:"informix".sac_movimientoshistorial a, bdisac:"informix".sac_cheques_odp b
					where fecha_pago >= FechaIni
					  and fecha_pago <= FechaFin
					  and numcategoria = '07'
					  and numconvenio in ('001','002','003')
					  and a.folio_suc = b.folio_suc
					  and a.fecha_pago = b.fech_alt						  		
					
					INSERT INTO bdisac:"informix".sac_movtos_odp (referencia1,folio_suc,fecha_pago,usuario,id_sucursal, numcategoria, 
						numconvenio, referencia)
					VALUES (cReferencia1, cFolio_Sucursal, dFecha_Pago, cUsuario, cSucursal, cCategoria, cConvenio, cReferencia);
					
				END FOREACH;
				
				SELECT count(*)
				INTO iCuantosMovtos
				FROM "informix".sac_movtos_odp;
				
				FOREACH
				
					--ACTIVAS
					select {+INDEX("informix".sac_movtos_odp idxsac_movtos_odpr1)} NVL(a.fecha_envio,mdy(01,01,1900)),
					NVL(a.fecha_pago,mdy(01,01,1900)),
					'OPA' tipo_orden,NVL(no_control,'') num_control, case when estatus = '01' then 'ENVIADA'
																  when estatus = '01' and numcategoria = '07' and numconvenio ='002' and referencia ='REV' then 'REVERSADA'
																  when estatus = '04' and numcategoria = '07' and numconvenio ='001' then 'ENVIADA'
																 when estatus = '04' and referencia = 'REV' then 'REVERSADA'
																 when estatus = '04' and numcategoria = '07' and numconvenio ='002' then 'PAGADA'
																 when estatus = '02' and numcategoria ='07' and numconvenio='001' then 'ENVIADA'
																 when estatus = '02' and referencia = 'REV' then 'REVERSADA'
																 when estatus = '02' and numcategoria ='07' and numconvenio='003' then 'CANCELADA'                                                     
																 when estatus = '05' and referencia <> 'REV' then 'ENVIADA'
																 when estatus = '05' and referencia = 'REV' then 'REVERSADA' end estatus,
					case when referencia = 'REV' then (select {+INDEX(bdisac:"informix".sac_cheques_odp idxsac_cheques_odpff)}  NVL(monto_tot,0) from bdisac:"informix".sac_cheques_odp where folio_suc = b.folio_suc and fech_alt = b.fecha_pago and cancelad = 'S' and referencia='REV') else NVL(importe_pago,0) end,
					NVL(folio_suc,'') folio_sucursal,NVL(pri_nom_ben,'') beneficiario_nombre1,
					NVL(seg_nom_ben,'') beneficiario_nombre2,NVL(apell_pat_ben,'') beneficiario_appaterno,NVL(apell_mat_ben,'') beneficiario_apmaterno,
					NVL(identificacion,'') beneficiario_tpo_identificacion,NVL(num_ident,'') beneficiario_num_identificacion,
					NVL(direc_ben,'') beneficiario_direccion,NVL(pri_nom_rem,'') ordenante_nombre1,NVL(seg_nom_rem,'') ordenante_nombre2,
					NVL(apell_pat_rem,'') ordenante_appaterno,NVL(apell_mat_rem,'') ordenante_apmaterno,NVL(direc_rem,'') ordenante_direccion,
					NVL(telefono_rem,'') ordenante_telefono,NVL(suc_origen,'') sucursal_numero_origen,NVL(usua_envio,'') usuario_envio,
					NVL(suc_cobropago,'') sucursal_numero_destino,NVL(usua_pago,'') usuario_pago,
					NVL(hora_envio,MDY(9,1,1700)),
					NVL(hora_pago,MDY(9,1,1700)), 
					NVL(telefono_ben,''), NVL(identificacion,''), NVL(num_ident,''), NVL(suc_cobropago,'')
					INTO dFecha_Envio,dFecha_Pago,cTipo_Orden,cNum_Control,cEstatus,mMonto_Total,cFolio_Sucursal,cBeneficiario_Nombre1,
						cBeneficiario_Nombre2,cBeneficiario_Appaterno,cBeneficiario_Apmaterno,cBeneficiario_tpo_Identificacion,
						cBeneficiario_num_Identificacion,cBeneficiario_Direccion,cOrdenante_Nombre1,cOrdenante_Nombre2,cOrdenante_Appaterno,
						cOrdenante_Apmaterno,cOrdenante_Direccion,cOrdenante_Telefono,cSucursal_Numero_Origen,cUsuario_Envio,cSucursal_Numero_Destino,
						cUsuario_Pago,
						dHora_envio,dHora_pago,cBeneficiario_telefono,cTipo_identificacion,cNumero_identificacion,cSucursal_pagadora
					 from bdisac:"informix".sac_enviosdineroya a,bdisac:"informix".sac_movtos_odp b
					where no_control = referencia1
					and estatus in ('00','01','02','03','04','05')

					INSERT INTO bdisac:"informix".sac_pld_ordenes_pago (fecha_envio,fecha_pago,tipo_orden,num_control,estatus,monto_total,    
						folio_sucursal,beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,
						beneficiario_tpo_identificacion,beneficiario_num_identificacion,beneficiario_direccion,ordenante_nombre1,
						ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,ordenante_telefono,
						sucursal_numero_origen,usuario_envio,sucursal_numero_destino,usuario_pago, fecha_proceso,
						hora_envio,hora_pago,beneficiario_telefono,tipo_identificacion,numero_identificacion,sucursal_pagadora)
					VALUES (dFecha_Envio,dFecha_Pago,cTipo_Orden,cNum_Control,cEstatus,mMonto_Total,cFolio_Sucursal,cBeneficiario_Nombre1,
						cBeneficiario_Nombre2,cBeneficiario_Appaterno,cBeneficiario_Apmaterno,cBeneficiario_tpo_Identificacion,
						cBeneficiario_num_Identificacion,cBeneficiario_Direccion,cOrdenante_Nombre1,cOrdenante_Nombre2,cOrdenante_Appaterno,
						cOrdenante_Apmaterno,cOrdenante_Direccion,cOrdenante_Telefono,cSucursal_Numero_Origen,cUsuario_Envio,cSucursal_Numero_Destino,
						cUsuario_Pago,dFecha_Proceso,
						dHora_envio,dHora_pago,cBeneficiario_telefono,cTipo_identificacion,cNumero_identificacion,cSucursal_pagadora);					
					
				END FOREACH;
				
				FOREACH
					--PAGADAS, CANCELADAS Y REVERSADAS
					select {+INDEX(bdisac:"informix".sac_movtos_odp idxsac_movtos_odpr1)} NVL(a.fecha_envio,mdy(01,01,1900)),
						   NVL(a.fecha_pago,mdy(01,01,1900)),
						   'OPA' tipo_orden,NVL(no_control,'') num_control, case when estatus = '01' then 'ENVIADA'
																	when estatus = '01' and numcategoria = '07' and numconvenio ='002' and referencia ='REV' then 'REVERSADA'
																	 when estatus = '04' and numcategoria = '07' and numconvenio ='001' then 'ENVIADA'
																	 when estatus = '04' and referencia = 'REV' then 'REVERSADA'																	 
																	 when estatus = '04' and numcategoria = '07' and numconvenio ='002' then 'PAGADA'
																	 when estatus = '02' and numcategoria ='07' and numconvenio='001' then 'ENVIADA'
																	 when estatus = '02' and referencia = 'REV' then 'REVERSADA'
																	 when estatus = '02' and numcategoria ='07' and numconvenio='003' then 'CANCELADA'                                                     
																	 when estatus = '05' and referencia <> 'REV' then 'ENVIADA'
																	 when estatus = '05' and referencia = 'REV' then 'REVERSADA' end estatus,
					case when referencia = 'REV' then (select {+INDEX(bdisac:"informix".sac_cheques_odp idxsac_cheques_odpff)} NVL(monto_tot,0) from bdisac:"informix".sac_cheques_odp where folio_suc = b.folio_suc and fech_alt = b.fecha_pago and cancelad = 'S' and referencia='REV') else importe_pago end,
					NVL(folio_suc,'') folio_sucursal,NVL(pri_nom_ben,'') beneficiario_nombre1,
					NVL(seg_nom_ben,'') beneficiario_nombre2,NVL(apell_pat_ben,'') beneficiario_appaterno,NVL(apell_mat_ben,'') beneficiario_apmaterno,
					NVL(identificacion,'') beneficiario_tpo_identificacion,NVL(num_ident,'') beneficiario_num_identificacion,
					NVL(direc_ben,'') beneficiario_direccion,NVL(pri_nom_rem,'') ordenante_nombre1,NVL(seg_nom_rem,'') ordenante_nombre2,
					NVL(apell_pat_rem,'') ordenante_appaterno,NVL(apell_mat_rem,'') ordenante_apmaterno,NVL(direc_rem,'') ordenante_direccion,
					NVL(telefono_rem,'') ordenante_telefono,NVL(suc_origen,'') sucursal_numero_origen,NVL(usua_envio,'') usuario_envio,
					NVL(suc_cobropago,'') sucursal_numero_destino,NVL(usua_pago,'') usuario_pago,
					NVL(hora_envio,MDY(9,1,1700)), 
					NVL(hora_pago,MDY(9,1,1700)), 
					NVL(telefono_ben,''), NVL(identificacion,''), NVL(num_ident,''), NVL(suc_cobropago,'')
					INTO dFecha_Envio,dFecha_Pago,cTipo_Orden,cNum_Control,cEstatus,mMonto_Total,cFolio_Sucursal,cBeneficiario_Nombre1,
						cBeneficiario_Nombre2,cBeneficiario_Appaterno,cBeneficiario_Apmaterno,cBeneficiario_tpo_Identificacion,
						cBeneficiario_num_Identificacion,cBeneficiario_Direccion,cOrdenante_Nombre1,cOrdenante_Nombre2,cOrdenante_Appaterno,
						cOrdenante_Apmaterno,cOrdenante_Direccion,cOrdenante_Telefono,cSucursal_Numero_Origen,cUsuario_Envio,cSucursal_Numero_Destino,
						cUsuario_Pago,
						dHora_envio,dHora_pago,cBeneficiario_telefono,cTipo_identificacion,cNumero_identificacion,cSucursal_pagadora
					 from bdisac:"informix".sac_enviosdineroyahis a,bdisac:"informix".sac_movtos_odp b
					where no_control = referencia1
						  
					INSERT INTO "informix".sac_pld_ordenes_pago (fecha_envio,fecha_pago,tipo_orden,num_control,estatus,monto_total,    
						folio_sucursal,beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,
						beneficiario_tpo_identificacion,beneficiario_num_identificacion,beneficiario_direccion,ordenante_nombre1,
						ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,ordenante_telefono,
						sucursal_numero_origen,usuario_envio,sucursal_numero_destino,usuario_pago, fecha_proceso,
						hora_envio,hora_pago,beneficiario_telefono,tipo_identificacion,numero_identificacion,sucursal_pagadora)
					VALUES (dFecha_Envio,dFecha_Pago,cTipo_Orden,cNum_Control,cEstatus,mMonto_Total,cFolio_Sucursal,cBeneficiario_Nombre1,
						cBeneficiario_Nombre2,cBeneficiario_Appaterno,cBeneficiario_Apmaterno,cBeneficiario_tpo_Identificacion,
						cBeneficiario_num_Identificacion,cBeneficiario_Direccion,cOrdenante_Nombre1,cOrdenante_Nombre2,cOrdenante_Appaterno,
						cOrdenante_Apmaterno,cOrdenante_Direccion,cOrdenante_Telefono,cSucursal_Numero_Origen,cUsuario_Envio,cSucursal_Numero_Destino,
						cUsuario_Pago,dFecha_Proceso,
						dHora_envio,dHora_pago,cBeneficiario_telefono,cTipo_identificacion,cNumero_identificacion,cSucursal_pagadora);
						  
				END FOREACH;
				
				SELECT {+INDEX(bdisac:"informix".sac_pld_ordenes_pago idxsac_pld_odpft)} count(*)
				INTO iCuantosEnvTot
				FROM "informix".sac_pld_ordenes_pago
				WHERE fecha_proceso = dFecha_Proceso
				AND tipo_orden = 'OPA';
				
				IF iCuantosCheq <> iCuantosMovtos THEN
				
					FOREACH
								
						select {+INDEX("informix".sac_cheques_odp idxsac_cheques_odpff)} 
							NVL(folio_suc,''),NVL(fech_alt,mdy(01,01,1900)),NVL(cancelad,''),NVL(sucursal,''),case when referencia='REV' then 'REVERSADA' 
																	when transacc in ('1104','1164') and referencia<>'REV' then 'ENVIADA'
																	when transacc ='1191' and referencia<>'REV' then 'PAGADA'
																	when transacc ='1192' and referencia<>'REV' then 'CANCELADA'
																	else '' end, NVL(usua,''), NVL(monto_tot,0)
						into cFolio_Sucursal, dFecha_alt, cCancelad, cSucursal, cEstatus, cUsuario_Envio, mMonto_Total
						from "informix".sac_cheques_odp 
						where folio_suc not in (select {+INDEX("informix".sac_movtos_odp idxsac_movtos_odpr1)} folio_suc from "informix".sac_movtos_odp)
						
						IF cEstatus = 'REVERSADA' THEN
							LET dFecha_Envio = dFecha_alt;
							LET dFecha_Pago = mdy(01,01,1900);
							ELSE IF cEstatus = 'ENVIADA' THEN
								LET dFecha_Envio = dFecha_alt;
								LET dFecha_Pago = mdy(01,01,1900);								
								ELSE IF cEstatus = 'PAGADA' THEN
									LET dFecha_Envio = mdy(01,01,1900);
									LET dFecha_Pago = dFecha_alt;	
									ELSE IF cEstatus = 'CANCELADA' THEN
										LET dFecha_Envio = mdy(01,01,1900);
										LET dFecha_Pago = mdy(01,01,1900);	
									END IF;
								END IF;
							END IF;
						END IF;
						
						INSERT INTO "informix".sac_pld_ordenes_pago (fecha_envio,fecha_pago,tipo_orden,num_control,estatus,monto_total,    
						folio_sucursal,beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,
						beneficiario_tpo_identificacion,beneficiario_num_identificacion,beneficiario_direccion,ordenante_nombre1,
						ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,ordenante_telefono,
						sucursal_numero_origen,usuario_envio,sucursal_numero_destino,usuario_pago, fecha_proceso,
						hora_envio,hora_pago,beneficiario_telefono,tipo_identificacion,numero_identificacion,sucursal_pagadora)
						VALUES (dFecha_alt,mdy(01,01,1900),'OPA','',cEstatus,mMonto_Total,cFolio_Sucursal,'', '','','','','','','','','','','','',cSucursal,cUsuario_Envio,'','',dFecha_Proceso,
						MDY(9,1,1700),MDY(9,1,1700),
						'','','',cSucursal);
									
					END FOREACH;				
				
				END IF;
				
				IF iCuantosMovtos <> iCuantosEnvTot THEN
					
					FOREACH
					
						SELECT {+INDEX(bdisac:"informix".sac_movtos_odp idxsac_movtos_odpr1)} NVL(referencia1,''),NVL(folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(numcategoria,''), 
							NVL(numconvenio,''), case when referencia='REV' then 'REVERSADA' 
											when numcategoria='07' and numconvenio='001' and referencia<>'REV' then 'ENVIADA' 
											when numcategoria='07' and numconvenio='002' and referencia<>'REV' then 'PAGADA' 
											when numcategoria='07' and numconvenio='003' and referencia<>'REV' then 'CANCELADA' 
											else '' end, NVL(referencia,'')
						INTO cReferencia1, cFolio_Sucursal, dFecha_alt, cUsuario, cSucursal, cCategoria, cConvenio, cEstatus, cReferencia
						FROM bdisac:"informix".sac_movtos_odp
						WHERE folio_suc not in (select {+INDEX(bdisac:"informix".sac_pld_ordenes_pago idxsac_pld_odpft)} folio_sucursal from bdisac:"informix".sac_pld_ordenes_pago where fecha_proceso = dFecha_Proceso and tipo_orden = 'OPA')
											
						select {+INDEX("informix".sac_cheques_odp idxsac_cheques_odpff)} NVL(monto_tot,0)
						into mMonto_total
						from "informix".sac_cheques_odp 
						where folio_suc = cFolio_Sucursal
						and fech_alt = dFecha_alt
						and sucursal = cSucursal
						and usua = cUsuario
						and referencia = cReferencia;	

						IF cEstatus = 'REVERSADA' THEN
							LET dFecha_Envio = dFecha_alt;
							LET dFecha_Pago = mdy(01,01,1900);
							ELSE IF cEstatus = 'ENVIADA' THEN
								LET dFecha_Envio = dFecha_alt;
								LET dFecha_Pago = mdy(01,01,1900);								
								ELSE IF cEstatus = 'PAGADA' THEN
									LET dFecha_Envio = mdy(01,01,1900);
									LET dFecha_Pago = dFecha_alt;	
									ELSE IF cEstatus = 'CANCELADA' THEN
										LET dFecha_Envio = mdy(01,01,1900);
										LET dFecha_Pago = mdy(01,01,1900);	
									END IF;
								END IF;
							END IF;
						END IF;						
					
						INSERT INTO bdisac:"informix".sac_pld_ordenes_pago (fecha_envio,fecha_pago,tipo_orden,num_control,estatus,monto_total,    
						folio_sucursal,beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,
						beneficiario_tpo_identificacion,beneficiario_num_identificacion,beneficiario_direccion,ordenante_nombre1,
						ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,ordenante_telefono,
						sucursal_numero_origen,usuario_envio,sucursal_numero_destino,usuario_pago, fecha_proceso,
						hora_envio,hora_pago,beneficiario_telefono,tipo_identificacion,numero_identificacion,sucursal_pagadora)
						VALUES (dFecha_Envio,dFecha_Pago,'OPA',cReferencia1,cEstatus,mMonto_Total,cFolio_Sucursal,'',
							'','','','','','','','','','','','',cSucursal,cUsuario,'','',dFecha_Proceso,
							MDY(9,1,1700),MDY(9,1,1700),
							'','','',cSucursal);			
					
					END FOREACH;
						
				END IF;
				
			END IF;
		END IF;
		
		set pdqpriority 0;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_pld_ordenes_pago;		
		--ACTUALIZA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_OP', FechaFin, '1', 'informix', 'sp_odp_pld', cDescripcionSPJ);		
		RETURN cCodRet, cMensaje;
		
	END;
	delete {+INDEX(bdisac:"informix".sac_cheques_odp idxsac_cheques_odpff)} from bdisac:"informix".sac_cheques_odp;
	delete {+INDEX(bdisac:"informix".sac_movtos_odp idxsac_movtos_odpr1)} from bdisac:"informix".sac_movtos_odp;
END PROCEDURE;