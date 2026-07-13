CREATE PROCEDURE "informix".sp_pp_consultarcveprog_bei(p_empresa Char(3), p_snum_cte Char(20), p_usuario INTEGER, pcve_pagoprog CHAR(10), p_sestado CHAR(2), pDesde INTEGER, pHasta INTEGER)


		RETURNING	CHAR(5),    --Codigo Retorno
					CHAR(250),  --Mensaje Retorno
					CHAR(10),   --Clave de Pago de Programacion
					CHAR(20),   --Concepto de Pago
					DATE,       --Fecha Programacion
					DATE,       --Fecha Inicio Programacion
					CHAR(40),   --Canal Programacion
					CHAR(20),   --Cuenta Origen
					CHAR(40),   --Tipo Cuenta Origen
					CHAR(60),   --Beneficiario
					CHAR(40),   --Banco
					CHAR(20),   --Cuenta Destino
					MONEY(16,2),--Monto
					CHAR(70),   --Tipo Operacion
					CHAR(30),   --Notifica Cliente
					CHAR(30),   --Notifica Receptor
					CHAR(30),   --Frecuencia
                    CHAR(10),   --Consecutivo de PagosPend
					DATE,		--Fecha de Aplicacion
					CHAR(2),    --Clave de Estado
					CHAR(30),	--Descripcion de Estado
					CHAR(2),    --clave de tipo de operacion
					CHAR(40),   --Referencia1
					CHAR(20),   --Referencia2
					CHAR(5),    --Convenio
					CHAR(1),    --tipo pago: 1-fijo,2-minimo, 3-porcentaje
                    CHAR(2);    
                        

		--Definicion de Variables  
		DEFINE v_sCodRet             CHAR(5);
		DEFINE v_sMensajeRet         CHAR(250);
			
		DEFINE sCve_PagoProg         CHAR(10);

		DEFINE aCve_Estado           CHAR(2);
		DEFINE sDescripcion_Estado   CHAR(30);

		DEFINE sConcepto_Pago        CHAR(20);
		DEFINE sFecha_Programacion   DATE;
		DEFINE sFrecuencia           CHAR(30);
		DEFINE sMonto                MONEY(16,2);
		DEFINE sFecha_Inicio         DATE;
		DEFINE sCanal_Programacion   CHAR(40);
		DEFINE sCuenta_Destino       CHAR(20);
		DEFINE sBeneficiario         CHAR(60);
		DEFINE sBanco_Descrip        CHAR(40);
		DEFINE sCuenta_Origen        CHAR(20);
		DEFINE sTipo_Operacion       CHAR(70);
		DEFINE sCve_Notifica_Emi     CHAR(2);
		DEFINE sCve_Notifica         CHAR(2);
		DEFINE sTipo_Cta_Origen      CHAR(40);
		DEFINE sNotifica_Cte         CHAR(30);
		DEFINE sNotifica_Recep       CHAR(30);
		DEFINE sCveOperacion         CHAR(2);
		DEFINE sFecha_Cancelacion    DATE;
		DEFINE v_dfecha              DATE;
		DEFINE iContador             INT;
		DEFINE sReferencia1          CHAR(40);
		DEFINE sReferencia2          CHAR(20);
		DEFINE sConvenio             CHAR(5);
		DEFINE sTipo_Pago            CHAR(1);
		DEFINE iNo_Repet             INT;
		DEFINE sFecha_Fin            DATE;
		DEFINE vNumcte               CHAR(9);
        DEFINE sFecha_Aplicacion     DATE;
		DEFINE sConsecutivo          CHAR(10);
        DEFINE sCveFrecuencia        CHAR(2);
				  
		--Inicializacion de Variables
		LET v_sCodRet = '00001';
		LET v_sMensajeRet = '';
		LET sCve_PagoProg = '';
		LET aCve_Estado = '';
		LET sDescripcion_Estado = '';
		LET sConcepto_Pago = '';
		LET sFecha_Programacion = '';
		LET sFrecuencia = '';
		LET sMonto = 0;
		LET sFecha_Inicio = '';
		LET sCanal_Programacion = '';
		LET sCuenta_Destino = '';
		LET sBeneficiario = '';
		LET sBanco_Descrip = '';
		LET sCuenta_Origen = '';
		LET sTipo_Operacion = '';
		LET sCve_Notifica_Emi = '';
		LET sCve_Notifica = '';
		LET sTipo_Cta_Origen = '';
		LET sNotifica_Cte = '';
		LET sNotifica_Recep = '';
		LET sCveOperacion = '';
		LET sFecha_Cancelacion = '';
		LET v_dfecha = '';        
		LET iContador = 0;
		LET sReferencia1 = '';
		LET sReferencia2 = '';
		LET sConvenio = '';
		LET sTipo_Pago = '';
		LET iNo_Repet = 0;
		LET sFecha_Fin = '';
		LET vNumcte = '';
        LET sFecha_Aplicacion = '';
        LET sConsecutivo = '';
        LET sCveFrecuencia = '';
      
  
		--***************************************************************************************************
		-- DESCRIPCION:  Procedimiento que se encarga de regresar todos los registros de los pagos programados
		--               pendientes segÃÂºn la clave de programaciÃÂ³n
		-- AUTOR : Edgar Azael Rosas Velazquez - Solsersistem
		-- FECHA : 05/10/2016
		-- BD: bdibei
		-- SOLICITO :BanCoppel
		--***************************************************************************************************



--		SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET LOCK MODE TO WAIT 3;
      
		--Cuerpo del procedimiento.
		BEGIN

			SET LOCK MODE TO WAIT 10;

			--Consulta la fecha de sistema
			SELECT fecha_hoy INTO v_dfecha FROM bdinteg:"informix".si_fechas;

            
            -- ValidaciÃÂ³n de el cliente
            IF (NVL(p_snum_cte,'') <> '')  THEN
            ELSE
				--Consulta cÃÂ³digo de error
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '104';

				--Regresa las variables
				RETURN 	v_sCodRet, v_sMensajeRet, sCve_PagoProg, sConcepto_Pago, sFecha_Programacion, sFecha_Inicio, sCanal_Programacion, sCuenta_Origen,
						sTipo_Cta_Origen, sBeneficiario, sBanco_Descrip, sCuenta_Destino, sMonto, sTipo_Operacion, sNotifica_Cte, sNotifica_Recep, sFrecuencia,
						sConsecutivo, sFecha_Aplicacion, aCve_Estado, sDescripcion_Estado, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago, sCveFrecuencia;
            END IF;
			
            -- ValidaciÃÂ³n del usuario
            IF (NVL(p_usuario,'') <> '')  THEN
            ELSE
                --Consulta cÃÂ³digo de error
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '04';
				
				--Regresa las variables
				RETURN 	v_sCodRet, v_sMensajeRet, sCve_PagoProg, sConcepto_Pago, sFecha_Programacion, sFecha_Inicio, sCanal_Programacion, sCuenta_Origen,
						sTipo_Cta_Origen, sBeneficiario, sBanco_Descrip, sCuenta_Destino, sMonto, sTipo_Operacion, sNotifica_Cte, sNotifica_Recep, sFrecuencia,
						sConsecutivo, sFecha_Aplicacion, aCve_Estado, sDescripcion_Estado, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago, sCveFrecuencia;
            END IF;

            -- ValidaciÃÂ³n del pago programado
            IF (NVL(pcve_pagoprog,'') <> '')  THEN
            ELSE
                --Consulta cÃÂ³digo de error
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '10016';
				
				--Regresa las variables
				RETURN 	v_sCodRet, v_sMensajeRet, sCve_PagoProg, sConcepto_Pago, sFecha_Programacion, sFecha_Inicio, sCanal_Programacion, sCuenta_Origen,
						sTipo_Cta_Origen, sBeneficiario, sBanco_Descrip, sCuenta_Destino, sMonto, sTipo_Operacion, sNotifica_Cte, sNotifica_Recep, sFrecuencia,
						sConsecutivo, sFecha_Aplicacion, aCve_Estado, sDescripcion_Estado, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago, sCveFrecuencia;
            END IF;
			
            -- ValidaciÃÂ³n de el estado
            IF (NVL(p_sestado,'') <> '')  THEN
            ELSE
                --Consulta cÃÂ³digo de error
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '126';
				
				--Regresa las variables
				RETURN 	v_sCodRet, v_sMensajeRet, sCve_PagoProg, sConcepto_Pago, sFecha_Programacion, sFecha_Inicio, sCanal_Programacion, sCuenta_Origen,
						sTipo_Cta_Origen, sBeneficiario, sBanco_Descrip, sCuenta_Destino, sMonto, sTipo_Operacion, sNotifica_Cte, sNotifica_Recep, sFrecuencia,
						sConsecutivo, sFecha_Aplicacion, aCve_Estado, sDescripcion_Estado, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago, sCveFrecuencia;
            END IF;
			
			
					--se valida que el cliente exista
					IF EXISTS(SELECT empresa  FROM bdinteg:"informix".si_cliente WHERE numcte =  p_snum_cte) THEN
						
                        --SE VALIDA EL VALOR DE ESTADO PERMITIDO
						-------------------------------------------------------------------------------------------------------------
                        IF p_sestado = '03' THEN
                            --SE valida que existan pagos programados para ese cliente --Se pone por USUARIO**** primer
								IF EXISTS(SELECT descripcion 
											FROM bdiprog:"informix".pp_pagoprog 
										   WHERE num_cte IN (select num_cte 
											                   from bdibei:"informix".bei_pp_usuprog 
															  where id_usuario = p_usuario 
															    and num_cte = p_snum_cte)) THEN
										--Se seleccionan todos los pagos programados de ese Usuario.
                                        FOREACH     
											SELECT 	
													SKIP pDesde
													a.cve_pagoprog,
													h.estado,
													i.descripcion as concepto_estado,
													a.descripcion as concepto_pago,
													h.fecha_insert as fecha_programacion,
													NVL(b.descripcion,'No Definida') as frecuencia, 
													NVL(a.importe,0) + NVL(a.importe_iva,0) as monto,
													a.fecha_inicio,
													NVL(c.descripcion,'No Definido') as canal_programacion,
													a.cuenta_destino,
													NVL(d.nombre,'No Definido') as beneficiario,
													NVL(e.descripcion,'No Definido') as banco_descrip, 
													a.cuenta_origen,
													f.cve_pago,
													f.descripcion as tipo_operacion,
													a.cve_notifica_emi,
													a.cve_notifica,
													a.fecha_cancela, 
													a.referencia1, 
													a.referencia2, 
													a.convenio,
													CASE WHEN TRIM(f.cve_pago) == '05' AND a.tipo_spei IN (1,2,3) THEN a.tipo_spei ELSE 1 END, 
													NVL(a.no_repeticiones,0), 
													a.fecha_fin,
													h.fecha_prog as fecha_apllicacion,
                                                    h.consecutivo,
                                                    b.cve_programa
											   INTO	sCve_PagoProg,
													aCve_Estado,
													sDescripcion_Estado,
													sConcepto_Pago,
													sFecha_Programacion,
													sFrecuencia,
													sMonto,
													sFecha_Inicio,
													sCanal_Programacion,
													sCuenta_Destino,
													sBeneficiario,
													sBanco_Descrip,
													sCuenta_Origen,
													sCveOperacion, 
													sTipo_Operacion,
													sCve_Notifica_Emi,
													sCve_Notifica,
													sFecha_Cancelacion, 
													sReferencia1, 
													sReferencia2, 
													sConvenio,
													sTipo_Pago, 
													iNo_Repet, 
													sFecha_Fin,
													sFecha_Aplicacion,
                                                    sConsecutivo,
                                                    sCveFrecuencia
                                               FROM bdiprog:"informix".pp_pagoprog a 
											   --INNER JOIN bdibei:"informix".bei_pp_usuprog g  ON (a.num_cte=g.num_cte) --Tabla para usuario
											   LEFT JOIN bdiprog:"informix".pp_tpprograma b ON (a.cve_programa = b.cve_programa)
                                               LEFT JOIN bdiprog:"informix".pp_tpcanal c ON (a.cve_canal = c.cve_canal)
                                               LEFT JOIN bdiprog:"informix".pp_ctasterceros d ON (a.num_cte = d.num_cte and a.banco_destino = d.cve_banco and a.cuenta_destino = d.cuenta)
                                               LEFT JOIN bdinteg:"informix".si_bancos e ON ( a.banco_destino = e.banco )
                                               LEFT JOIN bdiprog:"informix".pp_tppago f ON (a.cve_pago = f.cve_pago)
                                               LEFT JOIN bdiprog:"informix".pp_pagospend h ON (a.cve_pagoprog = h.cve_pagoprog)
											   LEFT JOIN bdiprog:"informix".pp_estados i ON (h.estado = i.cve_estado)
                                               WHERE a.num_cte = p_snum_cte
                                               and a.cve_pagoprog = pcve_pagoprog
											   --and g.id_usuario = p_usuario --restriccion 
                                               --and h.estado = '03'
                                                ORDER BY h.consecutivo ASC

													IF ( iContador = 10 ) THEN
														EXIT foreach;
													END IF;

													IF ( TRIM(aCve_Estado) != '01'  ) THEN
															IF (TRIM(aCve_Estado) = '04'  ) THEN
																  IF(iNo_Repet != 0) THEN
																		SELECT fecha_prog 
                                                                          INTO sFecha_Programacion
                                                                          FROM bdiprog:pp_pagospend 
                                                                         WHERE cve_pagoprog = sCve_PagoProg 
																		   AND consecutivo = (SELECT MAX(consecutivo) 
                                                                                                FROM bdiprog:pp_pagospend 
                                                                                               WHERE cve_pagoprog = sCve_PagoProg);
																  END IF;
																  CALL bdicred:"informix".monthadd(sFecha_Programacion,+6) returning sFecha_Programacion;
																  IF (sFecha_Programacion < v_dfecha) THEN
																		CONTINUE foreach;
																  END IF; 
															ELSE
																  CALL bdicred:"informix".monthadd(sFecha_Cancelacion,+6) returning sFecha_Cancelacion;
																  IF (sFecha_Cancelacion < v_dfecha) THEN
																		CONTINUE foreach;
																  END IF;                                                                
															END IF;
													END IF;                                              
                                                                
													SELECT limit 1 b.nombre_prod
													INTO sTipo_Cta_Origen
													FROM bdicred:"informix".sd_maecred a
													JOIN bdicred:"informix".sd_definicion b ON (a.num_producto=b.num_producto and a.empresa=b.empresa)
													WHERE a.num_credito = sCuenta_Origen and a.empresa = p_empresa;

													IF NVL(sTipo_Cta_Origen,'') = '' THEN
															SELECT limit 1 b.nombre
															INTO sTipo_Cta_Origen
															FROM bdicheq:"informix".sc_maechq a
															JOIN bdicheq:"informix".sc_producto b ON (a.producto=b.producto and a.empresa=b.empresa)
															WHERE a.cuenta = sCuenta_Origen and a.empresa = p_empresa;
													END IF;

															IF sCveOperacion = '01' THEN --Se obtiene nombre de beneficiario en caso de ser propia
																  SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																  INTO sBeneficiario
																  FROM  bdinteg:"informix".si_cliente WHERE numcte = p_snum_cte;
															ELIF sCveOperacion = '05' THEN
																SELECT numcte INTO vNumcte FROM bdicred:"informix".sd_tarjeta where empresa = '001' AND num_tarjeta = sCuenta_Destino;
																IF vNumcte = sBeneficiario THEN
																	SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																	INTO sBeneficiario
																	FROM  bdinteg:"informix".si_cliente WHERE numcte = p_snum_cte;
																ELSE
																	SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																	INTO sBeneficiario
																	FROM  bdinteg:"informix".si_cliente WHERE numcte = vNumcte;
																END IF;
															END IF;
                                                                                                    
															SELECT descripcion
															INTO sNotifica_Cte
															FROM bdiprog:"informix".pp_tpnotifica
															WHERE cve_notifica = sCve_Notifica_Emi;

															SELECT descripcion
															INTO sNotifica_Recep
															FROM bdiprog:"informix".pp_tpnotifica
															WHERE cve_notifica = sCve_Notifica;
															
															--Consulta codigo de error
															SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '00';
															
															--Incrementa el contador
															LET iContador = iContador + 1;
															
															--Regresa las variables
															RETURN 	v_sCodRet, v_sMensajeRet, sCve_PagoProg, sConcepto_Pago, sFecha_Programacion, sFecha_Inicio, sCanal_Programacion, sCuenta_Origen,
																	sTipo_Cta_Origen, sBeneficiario, sBanco_Descrip, sCuenta_Destino, sMonto, sTipo_Operacion, sNotifica_Cte, sNotifica_Recep, sFrecuencia,
																	sConsecutivo, sFecha_Aplicacion, aCve_Estado, sDescripcion_Estado, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago, sCveFrecuencia 
															WITH RESUME;
										END FOREACH;
								ELSE
									--Se informa que no existen pagos programados para ese cliente
									 SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '88';
									 
									--Regresa las variables
									 RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, sConcepto_Pago, sFecha_Programacion, sFecha_Inicio, sCanal_Programacion, sCuenta_Origen,
											sTipo_Cta_Origen, sBeneficiario, sBanco_Descrip, sCuenta_Destino, sMonto, sTipo_Operacion, sNotifica_Cte, sNotifica_Recep, sFrecuencia,
											sConsecutivo, sFecha_Aplicacion, aCve_Estado, sDescripcion_Estado, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago, sCveFrecuencia;
								END IF;
                        
                        END IF;
						
					--Se informa que el cliente exista
					ELSE
                        --Consulta codigo de error
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '04';
						
						--Regresa las variables
									 RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, sConcepto_Pago, sFecha_Programacion, sFecha_Inicio, sCanal_Programacion, sCuenta_Origen,
											sTipo_Cta_Origen, sBeneficiario, sBanco_Descrip, sCuenta_Destino, sMonto, sTipo_Operacion, sNotifica_Cte, sNotifica_Recep, sFrecuencia,
											sConsecutivo, sFecha_Aplicacion, aCve_Estado, sDescripcion_Estado, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago, sCveFrecuencia;
					END IF;
		END;
END PROCEDURE;