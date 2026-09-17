CREATE PROCEDURE "informix".sp_obtiene_productos_prospecteo(	pEmpresa 		CHAR(3),	-- Cod. de empresa
																pSucursal 		CHAR(4),	-- Cod de Sucursal
																pEjecutivo 		CHAR(8),    -- Ejecutivo
																pPuesto_local 	CHAR(2),  	-- Puesto local del ejecutivo
																pNumcte 		CHAR(20), 	-- Num. de Cliente
																pCoppel 		CHAR (1), 	-- Indica si el cte ya tiene un credito coppel efectuado en tienda.
																							-- (1:Tiene credito coppel, 0: No tiene credito coppel)
																pPrecalCoppel 	CHAR(1), 	--Indica el resultado de la precalificacion del cte en coppel
																							-- (1: Mala eficiencia, 0: Buena eficiencia)
																pPrecalBco 		CHAR(1),    -- Indica el resultado de la precalificacion del cte en banco
																							-- (1:Mala eficiencia del cte en Banco, 0: Buena eficiencia del cte)
																pDigiDomicilio 	CHAR(1), 	-- Indica si el cte digitalizo un comprobante de domicilio.
																pIdentificacion CHAR(1),	-- Indica si el cte digitalizo una identificacion oficial
																pOfertaProdCred CHAR(1))	--Indica si oferta o no productos de credito)
	RETURNING 	CHAR(6), -- Codigo de retorno
				CHAR(4), -- Cod de producto a ofrecer al cte
				CHAR(1), -- Tipo de solicitud correspondiente al producto a ofrecer
				CHAR(40),-- Descripcion del producto
				CHAR(2); -- Prioridad del producto al momento de mostrarse

	
	-- Declaracion de variables
	DEFINE cdescripcion     	VARCHAR(60);
	DEFINE cPrioridad       	CHAR (2);
	DEFINE cProdCop         	CHAR(4);
	DEFINE cprod_final      	CHAR(4);
	DEFINE cnomcte          	CHAR(104);
	DEFINE cedadcte         	SMALLINT;
	DEFINE sql_err          	INTEGER;
	DEFINE isam_err         	INTEGER;
	DEFINE error_info       	VARCHAR(60);
	DEFINE CodRet           	CHAR(6);
	DEFINE cSucCajaUnica    	CHAR(1);
	DEFINE cTpSolicitudOfr  	CHAR(1);
	DEFINE cCodret          	CHAR(3);
	DEFINE cPuesto          	CHAR(3);
	DEFINE dFechaAlta			DATE;
	DEFINE dFechaHoy			DATE;
	DEFINE iMeses				INTEGER;
	DEFINE dFechaValida			DATE;
	DEFINE cOfertar				CHAR(1);
	DEFINE iPrestamosActivos  	INTEGER;
	--------------vARIABLES BUSQUEDA COPPEL
	DEFINE es_coppel            INTEGER;
	DEFINE prod_coppel          CHAR(4);
	DEFINE cop_solic            CHAR(20);
	DEFINE act_codret              CHAR(6);
    DEFINE existe_rechazo       INTEGER;
    DEFINE ife_sinvalidar       CHAR (20);
	DEFINE ref_coppel           CHAR (20);
	DEFINE sol_ref              CHAR (20);
	-- Asignacion variables
	LET cdescripcion        	= "";
	LET cPrioridad          	= "";
	LET cProdCop            	= "";
	LET cprod_final         	= "";
	LET cnomcte             	= "";
	LET cedadcte            	= 0;
	LET sql_err             	= 0;
	LET isam_err            	= 0;
	LET error_info          	= "";
	LET CodRet              	= '000000';
	LET cSucCajaUnica       	= "";
	LET cTpSolicitudOfr     	= "";

	LET cCodret             	= "";

	LET cPuesto             	= "";

	LET dFechaAlta				= '';
	LET dFechaHoy				= '';
	LET iMeses					= 0;
	LET dFechaValida			= '';
	LET cOfertar				= 'N';
	
	LET iPrestamosActivos 		= 0;
		--------------vARIABLES BUSQUEDA COPPEL
	LET es_coppel               = 0;
	LET prod_coppel             = "";
	LET cop_solic               = "";
	LET act_codret              = "000000";
	LET existe_rechazo          = 0;
	LET ife_sinvalidar          = "";
	LET ref_coppel              = "";
	LET sol_ref					= "";
	BEGIN
		ON EXCEPTION SET sql_err, isam_err, error_info
			DELETE FROM bdisolic:"informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo;
			LET CodRet = sql_err;
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/sysifx/respaldosbd/JoseLuis/529/sp_obtiene_productos_prospecteo.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		SELECT puesto
		INTO cPuesto
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pEjecutivo;

		IF NVL(cPuesto,"") = "" THEN
			LET CodRet = '000003';
		ELSE
			IF NOT EXISTS(SELECT perfilprom FROM  bdinteg:"informix".si_perfilproductos WHERE empresa = '001' AND puesto = cPuesto AND activo = '1') THEN
				LET CodRet = '000012';
			END IF;
		END IF;

		IF CodRet = '000003'OR CodRet = '000012' THEN
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;

		DELETE FROM bdisolic:"informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo;
		
		SELECT 1, numcte_ref INTO es_coppel, ref_coppel from bdinteg:"informix".si_cliente 
		WHERE numcte = pNumcte and numcte_ref <> '';
		
	 IF es_coppel = 1 THEN
		
		SELECT ss.num_producto, ss.num_solicitud  INTO prod_coppel,cop_solic
        FROM bdisolic:"informix".ss_solicitudes ss, bdisolic:"informix".ss_prospecteo_solicitudes pR
        WHERE ss.empresa= PR.Empresa
        AND ss.num_producto = pr.num_producto
        AND ss.numcte = pr.numcte
        AND ss.numcte = pNumcte
        AND ss.status_solicitud IN("EA","EE","AT","AP","OA","OS","BC","ST","CE","LC","MC","EC", "PA","IN")
		AND ss.num_producto = '6500'
        AND pr.estatus = 'A';
		
	  IF prod_coppel = '6500' THEN 
		EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pEmpresa,pEjecutivo,cop_solic,'RT','','CLIENTE YA CUENTA CON CREDITO COPPEL')
		INTO act_codret;
		
		UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
		SET estatus = 'C'
		WHERE numcte = pNumcte 
		AND empresa = pEmpresa
		AND num_solicitud = cop_solic;
	  END IF;
	 END IF;
    
		
		-- Validacion de NO OFERTAMIENTO para productos de credito que cuenten con (malos antecedentes en banco) o (malos antecedentes en coppel)
	SELECT 1 INTO existe_rechazo FROM bdisolic:ss_bitacora_precal WHERE num_referencia = ref_coppel AND fecha = TODAY  AND consecutivo IN (
	  SELECT MAX(consecutivo) FROM bdisolic:ss_bitacora_precal WHERE num_referencia = ref_coppel AND fecha = TODAY);
	     
	     SELECT resultado INTO ife_sinvalidar FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = pNumcte and fecha in (
	      select max(fecha) from bdinteg:"informix".si_bitacora_ife where numcte = pNumcte); 
              IF ife_sinvalidar <> 'Verdadero' THEN 
                LET existe_rechazo = 1;
              END IF;
	IF  existe_rechazo = 1 OR pPrecalBco = '1'  OR pPrecalCoppel = '1'  THEN
		UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr <> 'D';
	----Validando solicitudes bancoppel 	
		SELECT ss.num_producto, ss.num_solicitud  INTO prod_coppel,cop_solic
        FROM bdisolic:"informix".ss_solicitudes ss, bdisolic:"informix".ss_prospecteo_solicitudes pR
        WHERE ss.empresa= pEmpresa
        AND ss.num_producto = pr.num_producto
        AND ss.numcte = pr.numcte
        AND ss.numcte = pNumcte
        AND ss.status_solicitud IN("EA","EE","AT","AP","OA","OS","BC","ST","CE","LC","MC","EC", "PA","IN")
		AND ss.num_producto in ('6001','6300','6800','7600','7700')
        AND pr.estatus = 'A';
		
	  IF prod_coppel in ('6001','6300','6800','7600','7700') THEN 
		EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pEmpresa,pEjecutivo,cop_solic,'RT','','CLIENTE CUENTA CON UNA SITUACION ESPECIAL')
		INTO act_codret;
		
		UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
		SET estatus = 'C', status_solicitud = 'RT'
		WHERE numcte = pNumcte 
		AND empresa = pEmpresa
		AND num_solicitud = cop_solic;
		
		-- Elimina Relacion	
		SELECT num_solicitud_ref INTO sol_ref FROM bdisolic:ss_resum_scor_fin WHERE num_solicitud = cop_solic;
		
		UPDATE bdisolic:ss_resum_scor_fin SET tipo_movimiento = 'U', num_solicitud_ref = '' 
		WHERE num_solicitud = cop_solic;
		
		UPDATE bdisolic:ss_resum_scor_fin SET tipo_movimiento = 'U', num_solicitud_ref = '' 
		WHERE num_solicitud = sol_ref;		
		
	  END IF;
	END IF;
		
		FOREACH
			/*SELECT s.num_producto,s.tp_solicitud
			INTO cProdCop,cTpSolicitudOfr
			FROM bdisolic:"informix".ss_solic_producto s
			INNER JOIN bdinteg:"informix".si_prod_sucursal p ON (p.empresa = s.empresa AND p.num_producto = s.num_producto AND p.sucursal = pSucursal)
			INNER JOIN bdinteg:"informix".si_prod_ejecut e   ON (s.empresa = e.empresa AND s.num_producto = e.num_producto AND e.perfil = pPuesto_local)
			WHERE s.empresa = pEmpresa
			AND s.num_producto  IN (	SELECT num_producto
											FROM bdisolic:"informix".ss_solicitudes
											WHERE empresa= pEmpresa
											AND numcte = pNumcte
											AND status_solicitud IN("EA","EE","AT","AP","OA","OS","BC","ST","CE","LC","MC","EC", "PA","IN"))--JMAH RQM 09279 / RQM 18 023
*/
            SELECT s.num_producto,s.tp_solicitud
			INTO cProdCop,cTpSolicitudOfr
			FROM bdisolic:"informix".ss_solic_producto s
			INNER JOIN bdinteg:"informix".si_prod_sucursal p ON (p.empresa = s.empresa AND p.num_producto = s.num_producto AND p.sucursal = pSucursal)
			INNER JOIN bdinteg:"informix".si_prod_ejecut e   ON (s.empresa = e.empresa AND s.num_producto = e.num_producto AND e.perfil = pPuesto_local)
			WHERE s.empresa = pEmpresa
			AND s.num_producto  IN (	SELECT ss.num_producto
											FROM bdisolic:"informix".ss_solicitudes ss, bdisolic:"informix".ss_prospecteo_solicitudes pR
											WHERE ss.empresa= pEmpresa
											AND ss.num_producto = pr.num_producto
											AND ss.numcte = pr.numcte
											AND ss.numcte = pNumcte
											AND ss.status_solicitud IN("EA","EE","AT","AP","OA","OS","BC","ST","CE","LC","MC","EC", "PA","IN")
											AND pr.estatus = 'A')


				INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_ofr,tp_solicitud_ofr,aplica) VALUES (pNumcte,pSucursal,pEjecutivo,cProdCop,cTpSolicitudOfr,'S');
		END FOREACH

		

		-- Valida si la sucursal puede ofrecer el producto coppel
		SELECT cajaunica
		INTO cSucCajaUnica
		FROM bditarjcop:"informix".sucursalescajaunica
		WHERE empresa = pEmpresa
		AND cvesucursal = pSucursal;

		IF NVL(cSucCajaUnica,'') = "" THEN
			LET cSucCajaUnica = 'F';
		END IF;

		LET cTpSolicitudOfr = "";
		LET cprod_final     = "";
		FOREACH
			SELECT {+AVOID_FULL(bdisolic:"informix".ss_tramite_productos_clasif)} DISTINCT (tp.producto_ofr), tp.tp_solicitud_ofr, t.prioridad, 
				(CASE WHEN t.sistema = '01' THEN
					(SELECT UPPER(p.nombre) FROM bdicheq:"informix".sc_producto p
					WHERE empresa = pEmpresa AND p.producto = tp.producto_ofr)
				ELSE
					(CASE WHEN t.sistema = '03' THEN
						(SELECT UPPER(i.nombre) FROM bdinvers:"informix".sv_instrum i
							WHERE empresa = pEmpresa AND i.cod_instrum = tp.producto_ofr)
					ELSE
						(CASE WHEN t.sistema = '06' THEN
							(CASE WHEN tp.tp_solicitud_ofr = 'C' THEN 
								(SELECT UPPER(descripcion) FROM bdisolic:"informix".ss_tp_solicitud 
								WHERE empresa = pEmpresa AND tp_solicitud = 'C')
							ELSE
								(SELECT UPPER(nombre_prod) FROM bdicred:"informix".sd_definicion d
								WHERE empresa = pEmpresa AND d.num_producto = tp.producto_ofr)                          
							END)
						END)
					END)
				END)
			INTO cprod_final, cTpSolicitudOfr, cPrioridad, cdescripcion
			FROM bdisolic:"informix".ss_productos_ofrecer  tp
			INNER JOIN bdisolic:"informix".ss_tramite_productos_clasif t ON (tp.producto_ofr = t.prod_ofrecer)
			WHERE tp.cliente = pNumcte
			AND tp.sucursal = pSucursal
			AND tp.ejecutivo = pEjecutivo
			AND aplica = 'S'
			ORDER BY t.prioridad

			--Valida si el producto a ofrecer es de credito, para validar la fecha alta en caso que lo requiera.
			IF cprod_final = '6400' THEN
				IF EXISTS(SELECT 1 FROM bdisolic:"informix".ss_producto_credcap WHERE num_producto = cprod_final AND meses_alta IS NOT NULL) THEN
					--se valida que debe tener una cuenta con la vigencia valida para ofrecer credinomina.
					--Obtiene meses necesarios de alta para ofrecer el producto
					SELECT fecha_hoy
					INTO dFechaHoy
					FROM bdicred:"informix".sd_fechas 
					WHERE empresa = pEmpresa;

					FOREACH
						SELECT tp2.fecha_alta, cp2.meses_alta
						INTO dFechaAlta, iMeses
						FROM bdisolic:"informix".ss_productos_ofrecer tp2
						INNER JOIN bdisolic:"informix".ss_producto_credcap cp2 ON (cp2.num_producto = cprod_final AND cp2.producto_cap = tp2.producto_act)		
						WHERE tp2.fecha_alta IS NOT NULL	
						CALL bdicred:"informix".monthadd(dFechaHoy,-iMeses) RETURNING dFechaValida;	
						IF NOT dFechaAlta <= dFechaValida THEN
							CONTINUE FOREACH;
						END IF;						
						LET cOfertar = "S";
						EXIT FOREACH;						
					END  FOREACH;

					IF cOfertar <> "S" THEN
						CONTINUE FOREACH;
					END  IF;
				END IF;
			END IF;
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'')  WITH resume;
		END FOREACH;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET CodRet = '000001';
		END IF;

		DELETE FROM bdisolic:"informix".ss_productos_ofrecer  WHERE cliente = pNumcte AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo;

		IF CodRet = '000001' THEN
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;
	END;
END PROCEDURE
