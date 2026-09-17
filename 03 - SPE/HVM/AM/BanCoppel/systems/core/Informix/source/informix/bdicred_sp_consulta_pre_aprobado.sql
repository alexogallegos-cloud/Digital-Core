CREATE PROCEDURE "informix".sp_consulta_pre_aprobado(canalOri SMALLINT, sucOri CHAR(5), idModulo CHAR(10), vNumCte CHAR(9), gen1 CHAR(20), gen2 CHAR(20), gen3 CHAR(20))
RETURNING   CHAR(5) AS codRet,
            CHAR(30) AS mensaje,
            INTEGER AS idOfert,
            CHAR(14) AS folioPre,
            CHAR(40) AS nomProd,
            DECIMAL(18,2) AS montoAut,
            SMALLINT AS esUltOfert,
            CHAR(20) AS gen1,
            CHAR(20) AS gen2,
            CHAR(20) AS gen3;
	
	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(5);
    DEFINE vMensaje CHAR(30);
    DEFINE vIdOfert INTEGER;
    DEFINE vFolioPre CHAR(14);
    DEFINE vNumProducto CHAR(31);
    DEFINE vNomProd CHAR(30);
    DEFINE vMontoAut DECIMAL(18,2);
    DEFINE vEsUltOfert SMALLINT;
    DEFINE vGen1 CHAR(20);
    DEFINE vGen2 CHAR(20);
    DEFINE vGen3 CHAR(20);
	DEFINE vPrioridad SMALLINT;
    DEFINE maxOferts SMALLINT;
    DEFINE numOfertsCte SMALLINT;
    DEFINE mesesNoOfertar SMALLINT;
    DEFINE vArchivo CHAR(31);
    DEFINE diasDespuesNoOfertar DATE;
    DEFINE vConsecutivoCte SMALLINT;
	DEFINE VMontoUDI CHAR(20);
	DEFINE vFechaDif SMALLINT;
	DEFINE vfecha_ofert DATE;
	DEFINE vProducto SMALLINT;
	DEFINE vPagoTipo CHAR(10);
	DEFINE vPagoDia CHAR(15);
	DEFINE vNominaCuenta CHAR(20);
	
	DEFINE PROD_NOMINA CHAR(4);
	DEFINE PROD_TDC CHAR(4);
	DEFINE PROD_PRES_DIG CHAR(4);
	DEFINE PROD_PRES_MAS CHAR(4);
	DEFINE PROD_TDCOPPEL CHAR(4);
	DEFINE vCod_error CHAR(5);
	DEFINE vMensajeListaN CHAR (40);
	DEFINE vGenps CHAR(15);
	
	DEFINE cNumcte CHAR(9);
	DEFINE cProducto CHAR(6);
	DEFINE vConsecutivo INTEGER;
	DEFINE vCodTipCred CHAR(2);
	DEFINE cArchivoPreAp CHAR(500);
	DEFINE cFechaCarga DATE;
	
	DEFINE sNumSol CHAR(20);
	DEFINE vNumProductoTrx CHAR(4);
	DEFINE iContador INTEGER;
	--SET DEBUG FILE TO "/informix/ErnestoRaygoza/out_sp_consulta_pre_aprobado.sql";
	--TRACE ON;

    LET iSqlErr = '0';
    LET vCodRet = '00000';
    LET vMensaje = 'CONSULTA EXITOSA';
    LET vIdOfert = 0;
    LET vFolioPre = '';
    LET vNumProducto = '';
    LET vNomProd = '';
    LET vMontoAut = 0.00;
    LET vEsUltOfert = 0;
    LET vGen1 = '';
    LET vGen2 = '';
    LET vGen3 = '';
	LET vPrioridad = 0;

    LET maxOferts = 0;
    LET numOfertsCte = 0;
    LET mesesNoOfertar = 0;

    LET vConsecutivoCte = 0;
	LET vMontoUDI = '';
	LET vFechaDif = 0;
	LET vProducto = 0;
	
	LET PROD_NOMINA = '6400';
	LET PROD_TDC = '6001';
	LET PROD_PRES_DIG = '6800';
	LET PROD_PRES_MAS = '9300';
	LET PROD_TDCOPPEL = '6500';
	LET vCod_error = '';
	LET vMensajeListaN = '';
    LET vGenps = '';
	
	LET cNumcte = '';
	LET cProducto = '';
	LET vConsecutivo = 0;
	LET vCodTipCred = '';
	LET cArchivoPreAp = '';
	
	LET sNumSol = '';
	LET vNumProductoTrx = '';
	LET iContador = 0;

   BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            LET vMensaje ='ERROR AL CONSULTAR CLIENTE';
			RETURN vCodRet, vMensaje, vIdOfert, vFolioPre, vNomProd, vMontoUDI, vEsUltOfert, vGen1, vGen2, vNumProducto; --  vMontoAut;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SE MODIFICA EL IF EXIST
	SELECT count(1) into vGenps FROM "informix".sd_pre_aprobados_param WHERE codparam = 5 AND valor = 1;
	IF vGenps > 0 THEN --VALIDA SI EL SERVICIO ESTA ACTIVO
		SELECT count(1) into vGenps FROM "informix".sd_pre_aprobados_param WHERE codparam = 4 AND valor LIKE '%' || canalOri || '%';
		IF vGenps > 0 THEN --VALIDA SI EL CANAL PUEDE OFERTAR
			SELECT count(1) into vGenps FROM "informix".sd_pre_aprobados_prod WHERE status = 1 AND  canal = canalOri AND producto IN 
			(SELECT num_producto FROM "informix".sd_pre_aprobados_trx WHERE numcte = vNumCte);
			IF vGenps > 0 THEN
			
				--ACTUALIZA INFORMACIÃÂÃÂÃÂÃÂÃÂÃÂ¢ÃÂÃÂÃÂÃÂN DEL CLIENTE EN LA TABLA sd_pre_aprobados_trx
				SELECT cod_tipcred into vCodTipCred FROM "informix".sd_definicion WHERE num_producto in (SELECT num_producto FROM "informix".sd_pre_aprobados_trx WHERE numcte = vNumCte);
				--SELECT TRIM(valor) || LPAD(MONTH(TODAY),2,0) || '-' || SUBSTR(YEAR(TODAY),3,2)|| '.txt' INTO cArchivoPreAp FROM "informix".sd_pre_aprobados_param WHERE codparam = 6;
				SELECT TRIM(valor) INTO cArchivoPreAp FROM "informix".sd_pre_aprobados_param WHERE codparam = 6;
				SELECT numcte, num_producto, fecha_carga into cNumcte, cProducto, cFechaCarga FROM "informix".sd_pre_aprobados_trx WHERE numcte = vNumCte;
				--SELECT consecutivo_cte into vConsecutivo FROM "informix".sd_pre_aprobados_trx WHERE numcte = vNumCte;
				LET vConsecutivo = (SELECT NVL(MAX(consecutivo_cte),0) FROM "informix".sd_pre_aprobados_his WHERE numcte = vNumCte);
				LET vConsecutivo = vConsecutivo + 1;
				LET cArchivoPreAp = TRIM(cArchivoPreAp) || LPAD(MONTH(cFechaCarga),2,0) || '-' || SUBSTR(YEAR(cFechaCarga),3,2)|| '.txt';
				
				--En caso que el cliente tenga alguna solicitud en AT de Layouts anteriores las cancela
				FOREACH SELECT S.num_solicitud INTO sNumSol 
                    FROM bdisolic:ss_solicitudes as S
                    INNER JOIN bdicred:sd_pre_aprobados_trx as TRX
                    ON S.numcte = TRX.numcte
                    WHERE 
                    S.status_solicitud = 'AT' 
                    AND S.canal_sol in (6,7) 
                    AND TRIM(TRX.solicitud) = '-'
                    AND S.numcte = vNumCte

                    EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol('001', 'sistema', sNumSol, 'CN', '', 'Solicitud Cancelada por Sistema') INTO vCodRet;
                END FOREACH;
				
				UPDATE "informix".sd_pre_aprobados_trx 
				SET consecutivo_cte = vConsecutivo, 
				    cod_tipcred = vCodTipCred, 
					archivo = cArchivoPreAp, 
				    folio_preaprobado = LPAD(TRIM(cNumcte),9,'0') || SUBSTR(cProducto,1,2) || LPAD(vConsecutivo,3,'0')
				WHERE numcte = vNumCte;
				--FIN DE ACTUALIZACIÃÂÃÂÃÂÃÂÃÂÃÂ¢ÃÂÃÂÃÂÃÂN
			
				--SE AGREGA VALIDACION A LISTA NEGRA Y SITUACIONES ESPECIALES
				FOREACH EXECUTE PROCEDURE bdicred:"informix".sp_consulta_pre_aprobado_listanegra (vNumCte,sucOri,'') INTO vCod_error, vMensajeListaN
					IF TRIM(vCod_error) <> '00000' THEN
						IF TRIM(vCod_error) = '00001' THEN
							--VALIDA LA EXISTENCIA DEL CLIENTE EN LA BDINTEG si_cliente y si_ctepf.
							LET vCodRet = '00011';
							LET vMensaje = 'CLIENTE NO ENCONTRADO EN TABLA';
						ELIF TRIM(vCod_error) = '00002' THEN
							--VALIDA LA EXISTENCIA DEL CLIENTE EN LISTA NEGRA.
							LET vCodRet = '00012';
							LET vMensaje = 'CLIENTE EN LISTA NEGRA';							
						ELIF TRIM(vCod_error) = '00003' THEN
							--VALIDA LA SITUACION DIFERENTE A U65.
							LET vCodRet = '00013';
							LET vMensaje = 'SITUACION ESPECIAL NO VALIDA';							
						ELIF TRIM(vCod_error) = '00004' THEN
							--VALIDA LA EXISTENCIA DEL CLIENTE EN LA TABLA DE SITUACIONES Y UN ESTATUS DE SITUACION Y CAUSA.
							LET vCodRet = '00014';
							LET vMensaje = 'SIN REGISTROS CAUSA/SITUACION';							
						ELSE
							LET vCodRet = vCod_error;
							LET vMensaje = vMensajeListaN;
						END IF;
										
						RETURN vCodRet, vMensaje, vIdOfert, vFolioPre, vNomProd, vMontoUDI, vEsUltOfert, vGen1, vGen2, vNumProducto; --  vMontoAut;
					END IF;
				END FOREACH;
				
				SELECT count(1) into vGenps FROM bdisolic:"informix".ss_solicitudes 
				WHERE numcte=vNumCte AND status_solicitud IN ("RT","IN","CM","EA","EE","AT","CC","OA","OS","BC","ST","CE","LC","MC","EC","PA");
				IF vGenps = 0 THEN
					LET vNumCte = vNumCte;

					DROP TABLE IF EXISTS tmp_ofert_ctrl;
					
					--OBTIENE OFERTAS PREVIAS
					SELECT DISTINCT TRIM(folio_preaprobado) folio_preaprobado, fecha_oferta, respuesta 
					FROM "informix".sd_pre_aprobados_ctrl 
					WHERE (numcte=vNumCte AND SUBSTR(folio_preaprobado,1,9)=vNumCte) AND respuesta IS NOT NULL --AGREGAR VALIDACIÃÂÃÂÃÂÃÂÃÂÃÂ¢ÃÂÃÂÃÂÃÂN POR FECHA DE ULTIMO OFERTAMIENTO AL CLIENTE
					INTO TEMP tmp_ofert_ctrl WITH NO LOG; --OBTIENE PRODUCTOS ACTIVOS
					
					DROP TABLE IF EXISTS tmp_productos_actuales;
				
					--OBTIENE EL PRODUCTO DE LA TRX PARA TRABAJAR SOBRE ESE PRODUCTO EN LOS PRODUCTOS ACTUALES
					select num_producto INTO vNumProductoTrx FROM bdicred:sd_pre_aprobados_trx WHERE numcte = vNumCte;
									
					 --Se agrega validacion para el producto 6500, ss_solicitudes, status AP ,no ofertar de nuevo el preaprobado.
					SELECT num_producto FROM bdicred:"informix".sd_maecred WHERE status_cred IN ('A','AA','BA','BT','E1','E2','E3') AND numcte = vNumCte AND num_producto = vNumProductoTrx
					UNION ALL
					SELECT num_producto FROM bdicred:"informix".sd_maecredcrd WHERE status_cred IN ('A','AA','BA','BT','E1','E2','E3') AND numcte = vNumCte AND num_producto IN (vNumProductoTrx)
					UNION ALL
					SELECT num_producto FROM bdisolic:"informix".ss_solicitudes WHERE status_solicitud = 'AP' AND numcte = vNumCte AND num_producto = PROD_TDCOPPEL AND vNumProductoTrx = PROD_TDCOPPEL
					INTO TEMP tmp_productos_actuales WITH NO LOG; 
					
					--VALIDACION TRX CON PRODUCTO 6800 SI CUMPLE CON LAS SIGUIENTES CONDICIONES SE NO SE LE APLICA LA OFERTA
					IF (vNumProductoTrx = '6800') THEN
					    INSERT INTO tmp_productos_actuales
						SELECT A.num_producto FROM bdicred:sd_maecredcrd AS A 
						INNER JOIN  bdicred:sd_linea_prestamo AS B ON A.num_credito = B.num_credito
						WHERE A.numcte = vNumCte AND  A.num_producto = vNumProductoTrx AND B.fecha_cancela IS NULL AND A.status_cred = 'FF';					
					END IF;
					
					SELECT COUNT(1) INTO vProducto FROM tmp_productos_actuales;
				
					IF (vProducto >= 1) THEN   --El cliente tiene un mismo producto activo
						LET vIdOfert = 0;
						LET vFolioPre = '';
						LET vNumProducto = '';
						LET vNomProd = '';
						LET vMontoAut = 0.00;
						LET vCodRet = '00002';
						LET vMensaje = 'CTE CON PRODUCTO APERTURADO.';
						RETURN vCodRet, vMensaje, vIdOfert, vFolioPre, vNomProd, vMontoUDI, vEsUltOfert, vGen1, vGen2, vNumProducto; --  vMontoAut;
					END IF;
					
					DROP TABLE IF EXISTS tmp_ofert_trx;
					
					SELECT FIRST 1 folio_preaprobado, linea_aprobada, T.num_producto, nombre_prod, archivo, consecutivo_cte, T.tasa, T.numctecoppel, R.prioridad, T.puntual_bc_20,
						T.valor_bc_20
					FROM bdicred:sd_pre_aprobados_trx AS T
					INNER JOIN bdicred:sd_definicion AS D
					ON T.num_producto = D.num_producto
					INNER JOIN bdicred:sd_pre_aprobados_prod AS P 
					ON P.producto = D.num_producto
					INNER JOIN bdicred:sd_pre_aprobados_priori AS R
					ON P.producto = R.producto
					WHERE P.status = 1
					AND T.num_producto NOT IN(SELECT DISTINCT num_producto FROM tmp_productos_actuales)
					AND (numcte = vNumCte AND SUBSTR(folio_preaprobado, 1, 9) = vNumCte) 
					ORDER BY consecutivo_cte ASC INTO TEMP tmp_ofert_trx WITH NO LOG;
					
					SELECT MAX(fecha_oferta) INTO vfecha_ofert FROM bdicred:sd_pre_aprobados_ctrl WHERE numcte = vNumCte ;
				
					SELECT DATE(CURRENT) -  DATE(vfecha_ofert::date) INTO vFechaDif FROM bdicred:"informix".sd_fechas;

					IF (SELECT COUNT(1) FROM tmp_ofert_trx) > 0 THEN
						SELECT FIRST 1 folio_preaprobado, linea_aprobada, num_producto, nombre_prod, archivo, consecutivo_cte, tasa,numctecoppel, puntual_bc_20, valor_bc_20
						INTO vFolioPre, vMontoAut, vNumProducto, vNomProd, vArchivo, vConsecutivoCte, VGen1, VGen2, vPagoTipo, vPagoDia
						FROM tmp_ofert_trx
						WHERE prioridad = (SELECT MIN(prioridad) FROM tmp_ofert_trx);
						
						--Inicia validaciones prÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ©stamo directo de nÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³mina
						IF(vNumProducto = PROD_NOMINA) THEN --ExtracciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n de informaciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n de pago cuando sea producto de nÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³mina
							IF(NVL(vPagoTipo, '0') = '0' OR NVL(vPagoDia, '0') = '0') THEN
								LET vCodRet = '00009';
								LET vMensaje = 'INF INCOMPLETA LAYOUT NOMINA';
								RETURN vCodRet, vMensaje, '0', '', '', '', '', '', '', '';
							END IF
							
							--Validar que el cliente cuente con una cuenta de nÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³mina activa(empresa, numcte, frecuencia, registros)
							FOREACH
								EXECUTE PROCEDURE bdisolic:sp_obtenerctanomina('001', vNumCte, 1, 0)
								INTO vCodRet, vNominaCuenta
								IF(NVL(vNominaCuenta, '') <> '') THEN
									EXIT FOREACH;
								END IF
							END FOREACH;
							IF(NVL(vCodRet, '00010') <> '00000') THEN
								LET vCodRet = '00010';
								LET vMensaje = 'CTE SIN CUENTA NOMINA ACTIVA';
								RETURN vCodRet, vMensaje, '0', '', '', '', '', '', '', '';
							END IF
						END IF
						
						IF (SELECT COUNT(*) FROM 'informix'.sd_pre_aprobados_trx WHERE numcte = vNumCte and num_producto = '6500') > 0 THEN 
							SELECT limitecreditopesos INTO vMontoUDI FROM 'informix'.sd_pre_aprobados_trx WHERE numcte = vNumCte and num_producto = '6500';
						ELIF (SELECT COUNT(*) FROM 'informix'.sd_pre_aprobados_trx WHERE numcte = vNumCte and num_producto = PROD_PRES_MAS) > 0 THEN 
							SELECT linea_aprobada INTO vMontoUDI FROM 'informix'.sd_pre_aprobados_trx WHERE numcte = vNumCte and num_producto = PROD_PRES_MAS;
						ELSE
							SELECT valor INTO vMontoUDI FROM sd_pre_aprobados_param WHERE  codparam = 11;
						END IF;
						--1 BUSCA PARAMETRO MAXIMO DE OFERTAMIENTOS POR CLIENTE - [MAXOFERTS] (sd_pre_aprobados_param) SELECT valor FROM "informix".sd_pre_aprobados_param WHERE codparam=1;
						LET maxOferts = (SELECT valor::INTEGER FROM "informix".sd_pre_aprobados_param WHERE codparam = 1);
						
						--2 BUSCA PARAMETRO DE DIAS DE NO OFERTAMIENTO, TRAS 3ER RECHAZO
						LET mesesNoOfertar = (SELECT valor::INTEGER FROM "informix".sd_pre_aprobados_param WHERE codparam = 3);
						
						--3 BUSCA NUMERO DE OFERTAS PREVIAS AL CTE Y CUENTA LOS DÃÂÃÂÃÂÃÂ AS DESPUES DE CUMPLIDO EL PERIODO DE NO OFERTAR (6 TRIMESTRES)
						SELECT NVL(SUM(CASE WHEN esultofert = 0 THEN 1 END), 0), NVL(SUM(CASE WHEN esultofert = 1 THEN NVL((TODAY - ADD_MONTHS(fecha_oferta::date,mesesNoOfertar)), 1) END),1)
						INTO numOfertsCte, diasDespuesNoOfertar
						FROM "informix".sd_pre_aprobados_ctrl
						WHERE (numcte=vNumCte AND SUBSTR(folio_preaprobado,1 , 9) = vNumCte)
						AND id_oferta >= (SELECT NVL(MAX(id_oferta), 0) FROM "informix".sd_pre_aprobados_ctrl WHERE (numcte=vNumCte AND SUBSTR(folio_preaprobado,1,9) = vNumCte) AND esultofert = 1) AND respuesta IS NOT NULL;
						
						LET numOfertsCte = numOfertsCte + 1;
						
						/*
						IF numOfertsCte > 1 AND  vFechaDif = 0 THEN 
							LET vIdOfert = 0;
							LET vFolioPre = '';
							LET vNumProducto = '';
							LET vNomProd = '';
							LET vMontoAut = 0.00;
							LET vCodRet = '00003';
							LET vMensaje = 'OFERTA VENCIDA';
							RETURN vCodRet, vMensaje, vIdOfert, vFolioPre, vNomProd, vMontoUDI, vEsUltOfert, vGen1, vGen2, vNumProducto; --  vMontoAut;
						END IF;
						*/
						
						IF diasDespuesNoOfertar > 0 AND numOfertsCte <= maxOferts THEN
							--si se oferta
							IF numOfertsCte = maxOferts THEN
								LET vEsUltOfert = 1;
							END IF;

							--INSERTA EN TABLA CTRL U OBTIENE EL ID_OFERTA SI YA EXISTE UNO
							SELECT COUNT(1) INTO iContador FROM bdicred:sd_pre_aprobados_ctrl WHERE numcte = vNumCte AND folio_preaprobado = vFolioPre AND respuesta IS NULL;
							--AND DATE(fecha_oferta::DATE) = DATE(CURRENT);
							IF iContador = 0 THEN
								INSERT INTO bdicred:sd_pre_aprobados_ctrl(canal, sucursal, id_modulo, numcte, folio_preaprobado, esultofert, archivo, fecha_oferta) 
								VALUES(canalOri, sucOri, idModulo, vNumCte, vFolioPre, vEsUltOfert, vArchivo, CURRENT);
								LET vIdOfert = DBINFO('sqlca.sqlerrd1');
							ELSE
								SELECT MAX(id_oferta) INTO vIdOfert FROM bdicred:sd_pre_aprobados_ctrl WHERE numcte = vNumCte AND folio_preaprobado = vFolioPre;
							END IF;
						ELSE
							--al entrar aqui no se ofertarÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ­a hasta despues de 6 trimeestres (parametro 3 en tabla param)
							--AGREGAR BITACORA SOLO DE NO OFERTADOS EXISTENTES
							LET vIdOfert = 0;
							LET vFolioPre = '';
							LET vNumProducto = '';
							LET vNomProd = '';
							LET vMontoAut = 0.00;
							LET vCodRet = '00001';
							LET vMensaje = 'OFERTAS SUPERADAS';
						END IF; --TERMINA VALIDACIÃÂÃÂÃÂÃÂÃÂÃÂ¢ÃÂÃÂÃÂÃÂN DE DIAS TRASCURRIDOS Y NUMERO DE OFERTAS POR CLIENTE
					ELSE
						LET vIdOfert = 0;
						LET vFolioPre = '';
						LET vNumProducto = '';
						LET vNomProd = '';
						LET vMontoAut = 0.00;
						LET vCodRet = '00004';
						LET vMensaje = 'SIN OFERTAS DISPONIBLES';
					END IF; ---SIN OFERTAS DISPONIBLES
				ELSE
					SELECT num_solicitud INTO sNumSol FROM bdisolic:"informix".ss_solicitudes 
					WHERE numcte = vNumCte AND status_solicitud IN ("AT") AND user_insert = 'sys_cred';
					
					SELECT T.tasa, D.nombre_prod, T.num_producto, 
					CASE WHEN T.num_producto = '6400' THEN TRIM(T.puntual_bc_20)||'-'||TRIM(T.valor_bc_20)||'|'||NVL(TRIM(T.num_cta_captacion),'') ELSE '' END
					INTO vGen1, vNomProd,vGen2,vNumProducto
					FROM bdicred:sd_pre_aprobados_trx AS T
					INNER JOIN bdicred:sd_definicion AS D
					ON T.num_producto = D.num_producto
					WHERE T.numcte = vNumCte;
				
					LET vIdOfert = 0;
					--LET vFolioPre = '';
					LET vFolioPre = sNumSol;
					--LET vNumProducto = '';
					--LET vNomProd = '';
					LET vMontoAut = 0.00;
					LET vCodRet = '00005';
					LET vMensaje = 'CTE CON SOLICITUDES ACTIVAS';
				END IF; --CON SOLICITUDES ACTIVAS
			ELSE
				LET vIdOfert = 0;
				LET vFolioPre = '';
				LET vNumProducto = '';
				LET vNomProd = '';
				LET vMontoAut = 0.00;
				LET vCodRet = '00008';
				LET vMensaje = 'SIN PRODUCTOS ACTIVOS';
			END IF; --NO HAY PRODUCTOS POR OFERTAR ACTIVOS

		ELSE
			LET vIdOfert = 0;
			LET vFolioPre = '';
			LET vNumProducto = '';
			LET vNomProd = '';
			LET vMontoAut = 0.00;
			LET vCodRet = '00006';
			LET vMensaje = 'NO ACTIVO PARA ESTE CANAL';
		END IF; --VALIDACION DE CANAL HABILITADO PARA PREAPROBADOS
	ELSE
		LET vIdOfert = 0;
		LET vFolioPre = '';
		LET vNumProducto = '';
		LET vNomProd = '';
		LET vMontoAut = 0.00;
		LET vCodRet = '00007';
		LET vMensaje = 'SERVICIO INHABILITADO';
	END IF;
	
	IF (SELECT COUNT(*) FROM 'informix'.sd_pre_aprobados_trx WHERE numcte = vNumCte and num_producto <> PROD_PRES_MAS) > 0 THEN 
		IF canalOri = '6' THEN
			LET vMontoUDI = '';
		END IF;
	END IF;

	RETURN vCodRet, vMensaje, vIdOfert, vFolioPre, vNomProd, vMontoUDI, vEsUltOfert, vGen1, vGen2, vNumProducto; --  vMontoAut;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : 90120580 - Miguel Angel Espinoza Salmoran.',
'DESCRIPCION: Credito - Consulta Clientes Pre-Aprobados',
'FOLIO: ',
'FECHA : 18-05-2022',
'VERSION: 20220518.1702',
'BD: bdicred',
'-----------------------------------------------------------------------------------------------------------------------',
'AUTOR : 99805522 - Jorge Miguel Reyes Reyes.',
'DESCRIPCION: Se realiza modificacion para realizar consulta a sp_consulta_pre_aprobado_listanegra',
'FOLIO: ',
'FECHA : 04-10-2022',
'VERSION: 20220518.1703',
'-----------------------------------------------------------------------------------------------------------------------',
'AUTOR : 99805522 - Jorge Miguel Reyes Reyes.',
'DESCRIPCION: Se eliminan las sentencias IF EXIST & IF NOT EXIST reemplazandolas por un count',
'FOLIO: ',
'FECHA : 04-10-2022',
'VERSION: 20220518.1704',
'-----------------------------------------------------------------------------------------------------------------------',
'MODIFICACIÃÂÃÂÃÂÃÂÃÂÃÂ¢ÃÂÃÂÃÂÃÂN: 95579737 - JosÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ© Ernesto Raygoza Villa',
'FECHA: 25/10/2022',
'DESCRIPCIÃÂÃÂÃÂÃÂÃÂÃÂ¢ÃÂÃÂÃÂÃÂN: Se agrega lÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³gica para prÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ©stamo de nÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³mina',
'VERSION: 20221025.1744',
'-----------------------------------------------------------------------------------------------------------------------',
'MODIFICACIÃÂÃÂÃÂÃÂÃÂÃÂ¢ÃÂÃÂÃÂÃÂN: 93127324 - Rodolfo Javier Tortolero Varela',
'FECHA: 26/01/2023',
'DESCRIPCIÃÂÃÂÃÂÃÂÃÂÃÂ¢ÃÂÃÂÃÂÃÂN: Se modifica para que retorno del campo Gen3, regrese el nÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂºmero de producto en lugar del monto autorizado.',
'VERSION: 20230126.0845',
'-----------------------------------------------------------------------------------------------------------------------',
'MODIFICACION: Luis Fernando Trapero Soto',
'FECHA: 27/06/2024',
'DESCRIPCION: Se cambia la consulta a la trx para mostrar la oferta con el limitecreditopesos en vez de linea_aprobada',
'VERSION: 20221025.1744',
'-----------------------------------------------------------------------------------------------------------------------',
'MODIFICACION: Fernando Rodelo Barron',
'FECHA: 19/08/2024',
'DESCRIPCION: Se agrego validaciÃÂ³n para en caso que el cliente tenga alguna solicitud en AT de Layouts anteriores, las cancele.',
'VERSION: 20240819.1200',
'-----------------------------------------------------------------------------------------------------------------------',
'MODIFICACION: Luis Fernando Trapero Soto',
'FECHA: 21/08/2024',
'DESCRIPCION: Se modifica validando el producto 6500 en la tabla ss_solicitudes con status AP,para no ofertar de nuevo el preaprobado.',
'VERSION: 20230126.0845',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_genmov_vigencia(

	pCodigoRetorno			CHAR(5),
	
	
	p_num_credito            VARCHAR(20),
	p_num_producto           VARCHAR(4),
	p_codigo_ref             INTEGER,---
	p_codigo_fun             VARCHAR(3),---
	p_fecha_hoy              DATE,---
	p_monto                  MONEY(14,2),
	p_foliosuc               VARCHAR(16),
	p_sucursal               VARCHAR(4),
	p_transacc_suc           VARCHAR(4),
	

	p_Transacc               CHAR(5),
	
	eNumCte 				 CHAR(40),
	ePuntos 				 DECIMAL(18,2)
	) 
	
	RETURNING	 CHAR(5) as CodRet; --Codigo Retorno
	
DEFINE cCodret				    CHAR(5);
DEFINE iSqlerr				    INTEGER;

DEFINE cCodret2				    CHAR(5);

---vigencia Reverso
DEFINE vNumCte				    CHAR(40);
DEFINE cNumCte				    CHAR(40);
DEFINE vPuntos				    DECIMAL(18,2);
DEFINE vFolio					CHAR(40);
DEFINE vOrigen					CHAR(40);
DEFINE vTipo				    CHAR(40);
DEFINE vReferencia23			CHAR(40);
DEFINE vAbonoRecuperado			DECIMAL(18,2);
DEFINE vMontoValida			    DECIMAL(18,2);

DEFINE bFolio					CHAR(40);
DEFINE bAbonoRecuperado			DECIMAL(18,2);

---genmov
DEFINE gEmpresa             VARCHAR(3);
DEFINE gNumCredito          VARCHAR(20);
DEFINE gNumProducto         VARCHAR(4);
DEFINE gCodigoRef           INTEGER;
DEFINE gCodigoFun           VARCHAR(3);
DEFINE gCodigoRef2           INTEGER;
DEFINE gCodigoFun2           VARCHAR(3);
DEFINE gFechaHoy            DATE;
DEFINE gMonto               MONEY(14,2);
DEFINE gMonto2              MONEY(14,2);
DEFINE gFoliosuc            VARCHAR(16);
DEFINE gSucursal            VARCHAR(4);
DEFINE gDivisa              VARCHAR(2);
DEFINE gTransaccSuc         VARCHAR(4);
DEFINE gTransaccSuc2         VARCHAR(4);

DEFINE gMensaje 			VARCHAR(80);
---
---principal
DEFINE pMonto               MONEY(14,2);
DEFINE pTransacc            CHAR(5);

---
---vigencia
DEFINE mNumCte 		CHAR(40);
DEFINE mPuntos 		DECIMAL(18,2);


--INICIALIZANDO VARIABLES -------------
---------------------------------------
LET iSqlerr    			= 0;
LET cCodret    			= "00000";

LET cCodret2 	= pCodigoRetorno;

--vigencia Reverso
LET vFolio				= "";
LET vOrigen				= "";
LET vTipo 				= "";
LET vNumCte				= eNumCte;
LET vPuntos				= ePuntos;
LET vReferencia23		= "";
LET vAbonoRecuperado	= "";
LET cNumCte				= "";
LET vMontoValida		= "";

LET bAbonoRecuperado	= "";
LET bFolio				= "";
---genmov
LET gEmpresa        = '001';
LET gNumCredito     = p_num_credito;
LET gNumProducto    = p_num_producto;
LET gCodigoRef      = 0;
LET gCodigoFun      = 0;
LET gCodigoRef2     = 0;
LET gCodigoFun2     = 0;
LET gFechaHoy       = p_fecha_hoy;
LET gMonto          = p_monto;
LET gFoliosuc       = p_foliosuc;
LET gSucursal       = p_sucursal;
LET gDivisa         = '01';
LET gTransaccSuc    = 0;
LET gTransaccSuc2   = 0;
LET gMonto2			= p_monto;

LET gMensaje		= 0;
---
---principal
LET pMonto          = p_monto;
LET pTransacc       = p_Transacc;

---
---vigencia
LET mNumCte 	= eNumCte;
LET mPuntos 	= ePuntos;
---------------------------------------
BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			rollback work;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/Fausto/Sps/genmov_principal_vigencia.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
---------------------------------------
-------  	
	if p_Transacc = '9814' then 
		LET gCodigoRef      = 137;
		LET gCodigoFun      = '151';
		LET gCodigoRef2     = 142;
		LET gCodigoFun2     = '151';
		LET gTransaccSuc    = '9817';
		LET gTransaccSuc2   = '9823';
	
							
	
	elif p_Transacc = '9829' then
		LET gCodigoRef      = 137;
		LET gCodigoFun      = '152';
		LET gCodigoRef2     = 142;
		LET gCodigoFun2     = '152';
		LET gTransaccSuc    = '9990';
		LET gTransaccSuc2   = '9830';
	----------------------------------------MODIFICAR CODIGO FUN Y REF---------------------------------------
	elif p_Transacc = '6622' then
		LET gCodigoRef      = 145;
		LET gCodigoFun      = '151';
		LET gTransaccSuc    = '6622';
	
	elif p_Transacc = '6623' then
		LET gCodigoRef      = 145;
		LET gCodigoFun      = '152';
		LET gTransaccSuc    = '6623';
	
	end if;

IF pCodigoRetorno = '000'then
			EXECUTE PROCEDURE "informix".sp_modificacion_vigencia_pl(
				mNumCte,
				mPuntos)
			INTO cCodRet;
		
		if p_Transacc = '9814' or p_Transacc = '9829' then 
		
			EXECUTE PROCEDURE "informix".genmov(
			gEmpresa,
			gNumCredito,
			gNumProducto,
			gCodigoRef,
			gCodigoFun,
			gFechaHoy,
			mPuntos,
			gFoliosuc,
			gSucursal,
			gDivisa,
			gTransaccSuc)
			INTO cCodRet,gMensaje;
		
			EXECUTE PROCEDURE "informix".genmov(
			gEmpresa,
			gNumCredito,
			gNumProducto,
			gCodigoRef2,
			gCodigoFun2,
			gFechaHoy,
			gMonto,
			gFoliosuc,
			gSucursal,
			gDivisa,
			gTransaccSuc2)
			INTO cCodRet,gMensaje;
		
		elif p_Transacc = '6622' or p_Transacc = '6623' then
		
			EXECUTE PROCEDURE "informix".genmov(
			gEmpresa,
			gNumCredito,
			gNumProducto,
			gCodigoRef,
			gCodigoFun,
			gFechaHoy,
			mPuntos,
			gFoliosuc,
			gSucursal,
			gDivisa,
			gTransaccSuc)
			INTO cCodRet,gMensaje;
		
		end if;
else
		---------------------------------------	
		SELECT numcte,sum(monto_abono_recuperado)
		INTO cNumCte,bAbonoRecuperado
		FROM bdicred: "informix".sd_vigencia_monedero_plan_lealtad
		WHERE numcte = vNumCte
		and monto_abono_recuperado > 0
		group by numcte;
		
		let vPuntos = mPuntos;
	
		IF cNumCte is not null and bAbonoRecuperado is not null and bAbonoRecuperado >= vPuntos THEN
			FOREACH
							
				SELECT monto_abono,folio, origen, referencia23, monto_abono_recuperado,tipo
				INTO vMontoValida,vFolio, vOrigen, vReferencia23, vAbonoRecuperado,vTipo
				FROM bdicred: "informix".sd_vigencia_monedero_plan_lealtad
				WHERE numcte = vNumCte
				and monto_abono_recuperado > 0
				ORDER BY 
				CASE 
			        WHEN origen = "Reworth" THEN 0
			        WHEN origen = "Plan_Lealtad" THEN 1
	    		END,
				fecha_insert DESC 	
				
					IF vPuntos >= vAbonoRecuperado then
					
						let vPuntos = vPuntos - vAbonoRecuperado;
						
						if vTipo = 'gastado' then 
						
							UPDATE sd_vigencia_monedero_plan_lealtad SET estatus = "f", tipo = "vigente", monto_abono_recuperado = 0
							WHERE numcte = vNumCte
							and referencia23 = vReferencia23
							and folio = vFolio
							and origen = vOrigen
							and monto_abono = vMontoValida;
						else
							UPDATE sd_vigencia_monedero_plan_lealtad SET monto_abono_recuperado = 0
							WHERE numcte = vNumCte
							and referencia23 = vReferencia23
							and folio = vFolio
							and origen = vOrigen
							and monto_abono = vMontoValida;
						end if;
					
					else
						LET vAbonoRecuperado = vAbonoRecuperado - vPuntos;
						
						UPDATE sd_vigencia_monedero_plan_lealtad SET estatus = "f", tipo = "vigente", monto_abono_recuperado = vAbonoRecuperado
						WHERE numcte = vNumCte
						and referencia23 = vReferencia23
						and folio = vFolio
						and origen = vOrigen
						and monto_abono = vMontoValida;
						
						LET vPuntos = 0;
						
					END IF;
				
				IF vPuntos = 0 then
					EXIT FOREACH;
				END if;
			END FOREACH;
		END IF;

		---------------------------------------
		delete from 'informix'.sd_movdia a 
		where a.num_credito = gNumCredito 
		and a.folio_suc = gFolioSuc
		and a.codigo_ref in (137,142,145);
end if;		
---------------------------------------
	RETURN cCodret;
END;
--------------------------------------
END procedure;