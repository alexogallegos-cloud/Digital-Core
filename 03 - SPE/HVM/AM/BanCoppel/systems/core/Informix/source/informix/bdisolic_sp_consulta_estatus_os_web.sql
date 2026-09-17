CREATE PROCEDURE "informix".sp_consulta_estatus_os_web(pAgrupamiento CHAR(25), pNumSucursal CHAR(4), pStatusSolct CHAR(2), pArea CHAR(3), pRegInicio INTEGER,
												pRegFin INTEGER,pMatriz_impr SMALLINT, pFecha_Inicio CHAR(10), pFecha_Fin CHAR(10),pNumCte CHAR(9), pNumCred CHAR(12))
												
RETURNING CHAR(5), INT, SMALLINT, CHAR(40), CHAR(5), CHAR(20), DATE, CHAR(2), CHAR(170), DATE, CHAR(50), DATE, INT, CHAR(30),
			CHAR(10), CHAR(10), CHAR(80), char(50), CHAR(10), CHAR(10), CHAR(13), CHAR(13), CHAR(13), CHAR(30), CHAR(20);

DEFINE sCodRet 				CHAR(5) ;
DEFINE iCodRet 				INTEGER ;
DEFINE sErrorInfo 			CHAR(80);
DEFINE cErrorInfo	 		CHAR(80);
DEFINE iIsamErr 			SMALLINT;
DEFINE vestatusos 			INTEGER ;
DEFINE vnumerocobranzas 	SMALLINT;
DEFINE vnombre 				CHAR(40);
DEFINE vabrevia_prod 		CHAR(5) ;
DEFINE vnum_solicitud 		CHAR(20);
DEFINE vfechasolic 			DATE    ;
DEFINE vstatus_solicitud 	CHAR(2) ;
DEFINE vnombre_cliente 		CHAR(170);
DEFINE vfecha_nac 			DATE    ;
DEFINE vfolio 				CHAR(50);
DEFINE vfechaos 			DATE    ;
DEFINE vdias 				INTEGER ;
DEFINE vnombrecalle 		CHAR(30);
DEFINE vnumeroextcalle 		CHAR(10);
DEFINE vnumerointcalle 		CHAR(10);
DEFINE vcomplemento 		CHAR(80);
DEFINE vzona 				CHAR(50);
DEFINE vciudad 				CHAR(10);
DEFINE vestado 				CHAR(10);
DEFINE vtelefono1 			CHAR(13);
DEFINE vtelefono2 			CHAR(13);
DEFINE vtelefono3 			CHAR(13);
DEFINE vNombreRegion 		CHAR(30);
DEFINE cNomSucursal 		CHAR(40);
DEFINE cNumCliente			CHAR(20);
DEFINE sRegistros 			SMALLINT;
DEFINE iBandRegOS			INTEGER ;
DEFINE iDiasMinOS			INTEGER ;
DEFINE iDiasMaxOS			INTEGER ;
DEFINE sExiste				SMALLINT;
DEFINE dtFechaIni 			DATE;
DEFINE dtFechaFin 			DATE;
DEFINE sHoraActual 			CHAR(15);
DEFINE sMinsActual 			CHAR(2);
DEFINE iHoraActual 			INTEGER;

LET sCodRet 			= "00000";
LET cErrorInfo			= "PROCESO EXITOSO";
LET sErrorInfo			= "";
LET	iCodRet				= 0;

LET vestatusos 			= 0;
LET vnumerocobranzas 	= 0;
LET vnombre 			= "";
LET vabrevia_prod 		= "";
LET vnum_solicitud 		= "";
LET vfechasolic 		= "01-01-1900";
LET vstatus_solicitud 	= "";
LET vnombre_cliente 	= "";
LET vfecha_nac 			= "01-01-1900";
LET vfolio 				= "";
LET vfechaos 			= "01-01-1900";
LET vdias 				= 0;
LET vnombrecalle 		= "";
LET vnumeroextcalle 	= "";
LET vnumerointcalle 	= "";
LET vcomplemento 		= "";
LET vzona 				= "";
LET vciudad			    = "";
LET vestado 			= "";
LET vtelefono1 			= "";
LET vtelefono2 			= "";
LET vtelefono3 			= "";
LET vNombreRegion 		= "";
LET cNomSucursal 		= "";
LET cNumCliente      	= "";
LET sRegistros			= 0;
LET iBandRegOS			= 0;
LET iDiasMinOS			= 0;
LET iDiasMaxOS			= 0;
LET sExiste				= 0;
LET dtFechaIni 			= pFecha_Inicio;
LET dtFechaFin 			= pFecha_Fin;
LET sHoraActual 		= '';
LET sMinsActual 		= '';
LET iHoraActual 		= 0;

/*
--SET DEBUG FILE TO '/respaldosbd/hectorb/sp_consulta_estatus_os.out';
--TRACE ON;
*/
BEGIN
    ON EXCEPTION SET iCodRet, iIsamErr, sErrorInfo
        LET sCodRet = iCodRet;
		LET cErrorInfo = sErrorInfo;
        RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
			vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1,
			vtelefono2, vtelefono3, vNombreRegion, cNumCliente;

    END Exception;

	--SE AGREGA PARA INICIALIZAR LAS VARIABLES DE LA FECHA EN CASO DE QUE LLEGUEN VACIAS...HECTOR  BOJORQUEZ
	IF NVL(dtFechaIni,"") = "" THEN
		LET dtFechaIni = DATE(1);
	END IF;
	IF NVL(dtFechaFin,"") = "" THEN
		LET dtFechaFin = CURRENT;
	END IF;	

	--VALIDAMOS LOS DATOS DE ENTRADA
	IF NVL(pAgrupamiento,'')='' THEN
		LET sCodRet='00001';
		LET cErrorInfo='DATOS DE ENTRADA NO VALIDOS';
		RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
			vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1,
			vtelefono2, vtelefono3, vNombreRegion, cNumCliente;
	ELSE

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;

		--VALIDAMOS QUE LA CONSULTA NOS REGRESE DATOS
		SELECT limit 1 num_solicitud INTO vnum_solicitud from bdisolic:ss_solicitud_env_os;
		LET sRegistros = dbinfo("sqlca.sqlerrd2");

		IF sRegistros > 0 THEN

			--DESPLEGAMOS LA INFORMACION CONTENIDA EN LA TABLA TEMPORAL ORDENADA DEPENDIENDO EL TIPO DE ORDENAMIENTO SELECCIONADO
			--SUCURSAL
			IF pAgrupamiento = 'SUCURSAL' THEN
			    FOREACH
				    SELECT { + INDEX (ss_solicitud_env_os numero_solicitud)}   NVL(matriz_impr,0), NVL(numero_cobranza,0),
								NVL(nombre_sucursal,''), NVL(producto,''), NVL(SOL.num_solicitud,''),NVL(fecha_solicitud,''), NVL(SOL.status_solicitud,''),
								NVL(nombre_cliente,''), NVL(fecha_nacimiento,''), NVL(folio_os,''),NVL(fecha_os,''), NVL(dias_os,0), NVL(nombre_calle,''),
								NVL(num_exterior,''), NVL(num_interior,''), NVL(comple_domicilio,''),NVL(nombre_colonia,''), NVL(nombre_ciudad,''),
								NVL(nombre_estado,''), NVL(tel_particular,''), NVL(tel_celular,''),NVL(tel_trabajo,''), nvl(nombre_region,'SIN REGION')
		            INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
						         vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado,
						         vtelefono1, vtelefono2, vtelefono3, vNombreRegion
					FROM bdisolic:ss_solicitud_env_os  as SOL 
					LEFT JOIN bdinteg:si_regiones as REG ON (SOL.numero_region = REG.numero_region)						
					INNER JOIN bdisolic:ss_solicitudes as SOLIC ON (SOL.num_solicitud = SOLIC.num_solicitud )
					INNER JOIN bdisolic:ss_autorizacion aut ON (aut.num_solicitud= SOLIC.num_solicitud )
					AND aut.empresa= SOLIC.empresa
					AND aut.status_solicitud= SOLIC.status_solicitud
					AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
								   FROM bdisolic:ss_autorizacion aut_aux
								   WHERE aut_aux.empresa= SOLIC.empresa
								   AND aut_aux.num_solicitud= SOLIC.num_solicitud
								   AND aut_aux.status_solicitud= SOLIC.status_solicitud)
					INNER JOIN bdinteg:si_cliente as CTE ON (SOLIC.numcte = CTE.numcte )						
					WHERE SOLIC.numcte = CASE WHEN(pNumCte <> "") THEN pNumCte ELSE SOLIC.numcte END
					AND SOLIC.num_solicitud = CASE WHEN(pNumCred <> "") THEN pNumCred ELSE SOLIC.num_solicitud END
					AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin
					ORDER BY sol.nombre_sucursal, sol.num_solicitud

				    IF NVL(vdias,0) <= (NVL((SELECT valor from bdicobranza:cb_param where cod_param = 7),0))  THEN
							RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
								vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
								vciudad, vestado, vtelefono1, vtelefono2, vtelefono3, vNombreRegion, cNumCliente WITH RESUME;
				    END IF

		        END FOREACH;
			--PRODUCTO
		    ELIF pAgrupamiento = 'PRODUCTO' THEN
		        FOREACH
 				    SELECT { + INDEX (ss_solicitud_env_os numero_solicitud)}   NVL(matriz_impr,0), NVL(numero_cobranza,0),
								NVL(nombre_sucursal,''), NVL(producto,''), NVL(SOL.num_solicitud,''),NVL(fecha_solicitud,''), NVL(SOL.status_solicitud,''),
								NVL(nombre_cliente,''), NVL(fecha_nacimiento,''), NVL(folio_os,''),NVL(fecha_os,''), NVL(dias_os,0), NVL(nombre_calle,''),
								NVL(num_exterior,''), NVL(num_interior,''), NVL(comple_domicilio,''),NVL(nombre_colonia,''), NVL(nombre_ciudad,''),
								NVL(nombre_estado,''), NVL(tel_particular,''), NVL(tel_celular,''),NVL(tel_trabajo,''), nvl(nombre_region,'SIN REGION')
		            INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
						         vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado,
						         vtelefono1, vtelefono2, vtelefono3, vNombreRegion
					FROM bdisolic:ss_solicitud_env_os  as SOL 
					LEFT JOIN bdinteg:si_regiones as REG ON (SOL.numero_region = REG.numero_region)						
					INNER JOIN bdisolic:ss_solicitudes as SOLIC ON (SOL.num_solicitud = SOLIC.num_solicitud )
					INNER JOIN bdisolic:ss_autorizacion aut ON (aut.num_solicitud= SOLIC.num_solicitud )
					AND aut.empresa= SOLIC.empresa
					AND aut.status_solicitud= SOLIC.status_solicitud
					AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
								   FROM bdisolic:ss_autorizacion aut_aux
								   WHERE aut_aux.empresa= SOLIC.empresa
								   AND aut_aux.num_solicitud= SOLIC.num_solicitud
								   AND aut_aux.status_solicitud= SOLIC.status_solicitud)
					INNER JOIN bdinteg:si_cliente as CTE ON (SOLIC.numcte = CTE.numcte )						
					WHERE SOLIC.numcte = CASE WHEN(pNumCte <> "") THEN pNumCte ELSE SOLIC.numcte END
					AND SOLIC.num_solicitud = CASE WHEN(pNumCred <> "") THEN pNumCred ELSE SOLIC.num_solicitud END
					AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin
					ORDER BY sol.producto, sol.num_solicitud
		     
					IF NVL(vdias,0) <= (NVL((SELECT valor from bdicobranza:cb_param where cod_param = 7),0))  THEN
						RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
						vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
						vciudad, vestado, vtelefono1, vtelefono2, vtelefono3, vNombreRegion, cNumCliente WITH RESUME;
					END IF

		        END FOREACH;
			--CLIENTE
		    ELIF pAgrupamiento = 'CLIENTE' THEN
		        FOREACH
				    SELECT { + INDEX (ss_solicitud_env_os numero_solicitud)}   NVL(matriz_impr,0), NVL(numero_cobranza,0),
								NVL(nombre_sucursal,''), NVL(producto,''), NVL(SOL.num_solicitud,''),NVL(fecha_solicitud,''), NVL(SOL.status_solicitud,''),
								NVL(nombre_cliente,''), NVL(fecha_nacimiento,''), NVL(folio_os,''),NVL(fecha_os,''), NVL(dias_os,0), NVL(nombre_calle,''),
								NVL(num_exterior,''), NVL(num_interior,''), NVL(comple_domicilio,''),NVL(nombre_colonia,''), NVL(nombre_ciudad,''),
								NVL(nombre_estado,''), NVL(tel_particular,''), NVL(tel_celular,''),NVL(tel_trabajo,''), nvl(nombre_region,'SIN REGION')
		            INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
						         vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado,
						         vtelefono1, vtelefono2, vtelefono3, vNombreRegion
					FROM bdisolic:ss_solicitud_env_os  as SOL 
					LEFT JOIN bdinteg:si_regiones as REG ON (SOL.numero_region = REG.numero_region)						
					INNER JOIN bdisolic:ss_solicitudes as SOLIC ON (SOL.num_solicitud = SOLIC.num_solicitud )
					INNER JOIN bdisolic:ss_autorizacion aut ON (aut.num_solicitud= SOLIC.num_solicitud )
					AND aut.empresa= SOLIC.empresa
					AND aut.status_solicitud= SOLIC.status_solicitud
					AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
								   FROM bdisolic:ss_autorizacion aut_aux
								   WHERE aut_aux.empresa= SOLIC.empresa
								   AND aut_aux.num_solicitud= SOLIC.num_solicitud
								   AND aut_aux.status_solicitud= SOLIC.status_solicitud)
					INNER JOIN bdinteg:si_cliente as CTE ON (SOLIC.numcte = CTE.numcte )						
					WHERE SOLIC.numcte = CASE WHEN(pNumCte <> "") THEN pNumCte ELSE SOLIC.numcte END
					AND SOLIC.num_solicitud = CASE WHEN(pNumCred <> "") THEN pNumCred ELSE SOLIC.num_solicitud END
					AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin
					ORDER BY sol.nombre_cliente, sol.num_solicitud

					IF NVL(vdias,0) <= (NVL((SELECT valor from bdicobranza:cb_param where cod_param = 7),0))  THEN
						RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
						vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
						vciudad, vestado, vtelefono1, vtelefono2, vtelefono3, vNombreRegion, cNumCliente WITH RESUME;
					END IF

		        END FOREACH;
			--STATUS
		    ELIF pAgrupamiento = 'STATUS' THEN
		        IF pArea = "OFI" THEN
					--Valida que el número de la sucursal y el estatus de la solicitud sean válidos
					IF NVL(pNumSucursal,'') = '' OR NVL(pStatusSolct,'') = '' THEN
						LET sCodRet = '00003';
						LET cErrorInfo = 'NUMERO DE SUCURSAL O STATUS INVALIDO';
						RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
								vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
								vciudad, vestado, vtelefono1, vtelefono2, vtelefono3, vNombreRegion, cNumCliente;
					END IF

          /*  -- 2012-01-09  MACF
					SELECT nombre 
					INTO cNomSucursal
					FROM bdinteg:si_sucursales 
					WHERE sucursal = pNumSucursal;
					
					-------SE ANEXA NUEVA CONDICION PARA IDENTIFICAR SI LA SUCURSAL ES MATRIZ
					
					SELECT COUNT(matriz_impr)
					INTO sExiste
					FROM bdisolic:"informix".ss_solicitud_env_os 
					WHERE status_solicitud = pStatusSolct  
					AND matriz_impr = pMatriz_Impr
					AND pNumSucursal = pMatriz_Impr;

					IF sExiste = 0 THEN
						LET sCodRet = "00007";
						LET cErrorInfo='LA SUCURSAL NO ES UNA TIENDA MATRIZ';
						LET vnum_solicitud='';
						RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
							vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1,
							vtelefono2, vtelefono3, vNombreRegion, cNumCliente;
					END IF;
					*/
					------------------------------------------------------------------------------------------------------------------------------------
						---VALIDAR SI LA HORA ES DESPUÉS DE LAS 17 HRS. ( SOLAMENTE PARA OFI )
           SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
              INTO sHoraActual
        	    FROM sysmaster:sysshmvals;  
        
           LET sMinsActual = SUBSTR(sHoraActual,4,2);
           LET sHoraActual = SUBSTR(sHoraActual,1,2);
           LET iHoraActual = trim(sHoraActual) || sMinsActual;
            
           IF iHoraActual <= 1700 THEN
                LET sCodRet='00004';
				LET cErrorInfo= 'NO EXISTE INFORMACION DISPONIBLE U HORARIO DE IMPRESION INVALIDO INTENTE DESPUES DE LAS 5 PM';
				RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
					 vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1,
					 vtelefono2, vtelefono3, vNombreRegion, cNumCliente;
           END IF;
					
					SELECT valor INTO iDiasMinOS from bdicobranza:cb_param where cod_param = 17;
					SELECT valor INTO iDiasMaxOS from bdicobranza:cb_param where cod_param = 18;
					
					FOREACH
					
						SELECT { + INDEX (ss_solicitud_env_os numero_solicitud)} SKIP pRegInicio FIRST pRegFin  NVL(matriz_impr,0), NVL(numero_cobranza,0),
								NVL(nombre_sucursal,''), NVL(producto,''), NVL(SOL.num_solicitud,''),NVL(fecha_solicitud,''), NVL(SOL.status_solicitud,''),
								NVL(nombre_cliente,''), NVL(fecha_nacimiento,''), NVL(folio_os,''),NVL(fecha_os,''), NVL(dias_os,0), NVL(nombre_calle,''),
								NVL(num_exterior,''), NVL(num_interior,''), NVL(comple_domicilio,''),NVL(nombre_colonia,''), NVL(nombre_ciudad,''),
								NVL(nombre_estado,''), NVL(tel_particular,''), NVL(tel_celular,''),NVL(tel_trabajo,''), nvl(nombre_region,'SIN REGION')
						INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
								 vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado,
								 vtelefono1, vtelefono2, vtelefono3, vNombreRegion
						FROM bdisolic:ss_solicitud_env_os  as SOL 
                            						              LEFT JOIN bdinteg:si_regiones as REG ON (SOL.numero_region = REG.numero_region)
					                                                   INNER JOIN bdisolic:ss_solicitudes as SOLIC ON (SOL.num_solicitud = SOLIC.num_solicitud )
						                                                 INNER JOIN bdisolic:ss_autorizacion aut ON (aut.num_solicitud= SOLIC.num_solicitud )
						    AND aut.empresa= SOLIC.empresa
						    AND aut.status_solicitud= SOLIC.status_solicitud
						    AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
								    	                   FROM bdisolic:ss_autorizacion aut_aux
									                      WHERE aut_aux.empresa= SOLIC.empresa
									                        AND aut_aux.num_solicitud= SOLIC.num_solicitud
									                        AND aut_aux.status_solicitud= SOLIC.status_solicitud)
						--AND aut.ejecutivo_auto= aut.ejecutivo_auto
						INNER JOIN bdinteg:si_cliente as CTE ON (SOLIC.numcte = CTE.numcte ),
						  bdinteg:si_sucursales s
						WHERE SOL.status_solicitud = pStatusSolct 
						  --AND SOL.matriz_impr = pMatriz_Impr
						  AND SOL.nombre_sucursal = s.nombre
						  AND s.sucursal = LPAD(pMatriz_Impr,4,'0')   
						  AND NVL(SOL.dias_os,0) > iDiasMinOS
						  AND NVL(SOL.dias_os,0) <= iDiasMaxOS
						
						  AND SOLIC.numcte = CASE WHEN(pNumCte <> "") THEN pNumCte ELSE SOLIC.numcte END
						  AND SOLIC.num_solicitud = CASE WHEN(pNumCred <> "") THEN pNumCred ELSE SOLIC.num_solicitud END
						  AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin
						  ORDER BY SOL.status_solicitud, SOL.num_solicitud
						
						LET iBandRegOS = 1;

						SELECT b.numcte INTO cNumCliente
						FROM bdisolic:ss_solicitudes a INNER JOIN bdinteg:si_cliente b ON (a.empresa = b.empresa AND a.numcte = b.numcte)
						WHERE b.sucursal = pNumSucursal AND a.num_solicitud = vnum_solicitud;
																			
						RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
								vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
								vciudad, vestado, vtelefono1, vtelefono2, vtelefono3, vNombreRegion, NVL(cNumCliente,'') WITH RESUME;
					END FOREACH;
					
					IF iBandRegOS = 0 THEN
						LET sCodRet='00004';
						LET cErrorInfo='NO EXISTEN DATOS PARA EL RANGO DE DIAS SIN REVISION ENTRE' || iDiasMinOS || 'Y' ||iDiasMaxOS;
                            
						RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
							vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
							vciudad, vestado, vtelefono1, vtelefono2, vtelefono3,vNombreRegion, cNumCliente;
					END IF
					LET pRegInicio = pRegInicio;
					LET pRegFin = pRegFin;
				ELIF pArea = "SIF" THEN 
					FOREACH
						SELECT { + INDEX (ss_solicitud_env_os numero_solicitud)}   NVL(matriz_impr,0), NVL(numero_cobranza,0),
							NVL(nombre_sucursal,''), NVL(producto,''), NVL(SOL.num_solicitud,''),NVL(fecha_solicitud,''), NVL(SOL.status_solicitud,''),
							NVL(nombre_cliente,''), NVL(fecha_nacimiento,''), NVL(folio_os,''),NVL(fecha_os,''), NVL(dias_os,0), NVL(nombre_calle,''),
							NVL(num_exterior,''), NVL(num_interior,''), NVL(comple_domicilio,''),NVL(nombre_colonia,''), NVL(nombre_ciudad,''),
							NVL(nombre_estado,''), NVL(tel_particular,''), NVL(tel_celular,''),NVL(tel_trabajo,''), nvl(nombre_region,'SIN REGION')
						INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
							 vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado,
							 vtelefono1, vtelefono2, vtelefono3, vNombreRegion
						FROM bdisolic:ss_solicitud_env_os  as SOL 
						LEFT JOIN bdinteg:si_regiones as REG ON (SOL.numero_region = REG.numero_region)						
						INNER JOIN bdisolic:ss_solicitudes as SOLIC ON (SOL.num_solicitud = SOLIC.num_solicitud )
						INNER JOIN bdisolic:ss_autorizacion aut ON (aut.num_solicitud= SOLIC.num_solicitud )
						AND aut.empresa= SOLIC.empresa
						AND aut.status_solicitud= SOLIC.status_solicitud
						AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
									   FROM bdisolic:ss_autorizacion aut_aux
									   WHERE aut_aux.empresa= SOLIC.empresa
									   AND aut_aux.num_solicitud= SOLIC.num_solicitud
									   AND aut_aux.status_solicitud= SOLIC.status_solicitud)
						INNER JOIN bdinteg:si_cliente as CTE ON (SOLIC.numcte = CTE.numcte )						
						WHERE SOLIC.numcte = CASE WHEN(pNumCte <> "") THEN pNumCte ELSE SOLIC.numcte END
						AND SOLIC.num_solicitud = CASE WHEN(pNumCred <> "") THEN pNumCred ELSE SOLIC.num_solicitud END
						AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin
						ORDER BY SOL.status_solicitud, SOL.num_solicitud

						IF NVL(vdias,0) <= (NVL((SELECT valor from bdicobranza:cb_param where cod_param = 7),0))  THEN
							RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
								vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
								vciudad, vestado, vtelefono1, vtelefono2, vtelefono3, vNombreRegion, cNumCliente WITH RESUME;
						END IF
					END FOREACH;
				ELSE
					LET sCodRet='00005';
					LET cErrorInfo='AREA DE EJECUCION NO VALIDA';

					RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
						vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
						vciudad, vestado, vtelefono1, vtelefono2, vtelefono3,vNombreRegion, cNumCliente;
				END IF
			--ESTADO
		    ELIF pAgrupamiento = 'ESTADO' THEN
		        FOREACH
					SELECT { + INDEX (ss_solicitud_env_os numero_solicitud)}   NVL(matriz_impr,0), NVL(numero_cobranza,0),
										NVL(nombre_sucursal,''), NVL(producto,''), NVL(SOL.num_solicitud,''),NVL(fecha_solicitud,''), NVL(SOL.status_solicitud,''),
										NVL(nombre_cliente,''), NVL(fecha_nacimiento,''), NVL(folio_os,''),NVL(fecha_os,''), NVL(dias_os,0), NVL(nombre_calle,''),
										NVL(num_exterior,''), NVL(num_interior,''), NVL(comple_domicilio,''),NVL(nombre_colonia,''), NVL(nombre_ciudad,''),
										NVL(nombre_estado,''), NVL(tel_particular,''), NVL(tel_celular,''),NVL(tel_trabajo,''), nvl(nombre_region,'SIN REGION')
					INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
								 vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado,
								 vtelefono1, vtelefono2, vtelefono3, vNombreRegion
					FROM bdisolic:ss_solicitud_env_os  as SOL 
					LEFT JOIN bdinteg:si_regiones as REG ON (SOL.numero_region = REG.numero_region)						
					INNER JOIN bdisolic:ss_solicitudes as SOLIC ON (SOL.num_solicitud = SOLIC.num_solicitud )
					INNER JOIN bdisolic:ss_autorizacion aut ON (aut.num_solicitud= SOLIC.num_solicitud )
					AND aut.empresa= SOLIC.empresa
					AND aut.status_solicitud= SOLIC.status_solicitud
					AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
								   FROM bdisolic:ss_autorizacion aut_aux
								   WHERE aut_aux.empresa= SOLIC.empresa
								   AND aut_aux.num_solicitud= SOLIC.num_solicitud
								   AND aut_aux.status_solicitud= SOLIC.status_solicitud)
					INNER JOIN bdinteg:si_cliente as CTE ON (SOLIC.numcte = CTE.numcte )						
					WHERE SOLIC.numcte = CASE WHEN(pNumCte <> "") THEN pNumCte ELSE SOLIC.numcte END
					AND SOLIC.num_solicitud = CASE WHEN(pNumCred <> "") THEN pNumCred ELSE SOLIC.num_solicitud END
					AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin
					ORDER BY SOL.nombre_estado, SOL.num_solicitud

              IF NVL(vdias,0) <= (NVL((SELECT valor from bdicobranza:cb_param where cod_param = 7),0))  THEN
					       RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
						          vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
						          vciudad, vestado, vtelefono1, vtelefono2, vtelefono3, vNombreRegion, cNumCliente WITH RESUME;
              END IF
		        END FOREACH;
                        -- REGIONES
			ELIF pAgrupamiento = 'REGIONES' THEN
                        -- Primero traemos las solicitudes que tienen asignada cualquier región.
		        FOREACH
					SELECT { + INDEX (ss_solicitud_env_os numero_solicitud)}   NVL(matriz_impr,0), NVL(numero_cobranza,0),
								NVL(nombre_sucursal,''), NVL(producto,''), NVL(SOL.num_solicitud,''),NVL(fecha_solicitud,''), NVL(SOL.status_solicitud,''),
								NVL(nombre_cliente,''), NVL(fecha_nacimiento,''), NVL(folio_os,''),NVL(fecha_os,''), NVL(dias_os,0), NVL(nombre_calle,''),
								NVL(num_exterior,''), NVL(num_interior,''), NVL(comple_domicilio,''),NVL(nombre_colonia,''), NVL(nombre_ciudad,''),
								NVL(nombre_estado,''), NVL(tel_particular,''), NVL(tel_celular,''),NVL(tel_trabajo,''), nvl(nombre_region,'SIN REGION')
		            INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
						         vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado,
						         vtelefono1, vtelefono2, vtelefono3, vNombreRegion
					FROM bdisolic:ss_solicitud_env_os  as SOL 
					LEFT JOIN bdinteg:si_regiones as REG ON (SOL.numero_region = REG.numero_region)						
					INNER JOIN bdisolic:ss_solicitudes as SOLIC ON (SOL.num_solicitud = SOLIC.num_solicitud )
					INNER JOIN bdisolic:ss_autorizacion aut ON (aut.num_solicitud= SOLIC.num_solicitud )
					AND aut.empresa= SOLIC.empresa
					AND aut.status_solicitud= SOLIC.status_solicitud
					AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
								   FROM bdisolic:ss_autorizacion aut_aux
								   WHERE aut_aux.empresa= SOLIC.empresa
								   AND aut_aux.num_solicitud= SOLIC.num_solicitud
								   AND aut_aux.status_solicitud= SOLIC.status_solicitud)
					INNER JOIN bdinteg:si_cliente as CTE ON (SOLIC.numcte = CTE.numcte )						
					WHERE ( SOL.numero_region is not null and SOL.numero_region <> 0)
					AND SOLIC.numcte = CASE WHEN(pNumCte <> "") THEN pNumCte ELSE SOLIC.numcte END
					AND SOLIC.num_solicitud = CASE WHEN(pNumCred <> "") THEN pNumCred ELSE SOLIC.num_solicitud END
					AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin

					ORDER BY REG.nombre_region, SOL.num_solicitud

					IF NVL(vdias,0) <= (NVL((SELECT valor from bdicobranza:cb_param where cod_param = 7),0))  THEN
						RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
						   vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
							vciudad, vestado, vtelefono1, vtelefono2, vtelefono3, vNombreRegion, cNumCliente WITH RESUME;
					END IF

		        END FOREACH;
                        -- Obtenemos las solicitudes que no tienen asignada región.
                FOREACH
    		        SELECT { + INDEX (ss_solicitud_env_os numero_solicitud)}   NVL(matriz_impr,0), NVL(numero_cobranza,0),
								NVL(nombre_sucursal,''), NVL(producto,''), NVL(SOL.num_solicitud,''),NVL(fecha_solicitud,''), NVL(SOL.status_solicitud,''),
								NVL(nombre_cliente,''), NVL(fecha_nacimiento,''), NVL(folio_os,''),NVL(fecha_os,''), NVL(dias_os,0), NVL(nombre_calle,''),
								NVL(num_exterior,''), NVL(num_interior,''), NVL(comple_domicilio,''),NVL(nombre_colonia,''), NVL(nombre_ciudad,''),
								NVL(nombre_estado,''), NVL(tel_particular,''), NVL(tel_celular,''),NVL(tel_trabajo,''), nvl(nombre_region,'SIN REGION')
					INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
							 vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado,
							 vtelefono1, vtelefono2, vtelefono3, vNombreRegion
					FROM bdisolic:ss_solicitud_env_os  as SOL 
					LEFT JOIN bdinteg:si_regiones as REG ON (SOL.numero_region = REG.numero_region)						
					INNER JOIN bdisolic:ss_solicitudes as SOLIC ON (SOL.num_solicitud = SOLIC.num_solicitud )
					INNER JOIN bdisolic:ss_autorizacion aut ON (aut.num_solicitud= SOLIC.num_solicitud )
					AND aut.empresa= SOLIC.empresa
					AND aut.status_solicitud= SOLIC.status_solicitud
					AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
								   FROM bdisolic:ss_autorizacion aut_aux
								   WHERE aut_aux.empresa= SOLIC.empresa
								   AND aut_aux.num_solicitud= SOLIC.num_solicitud
								   AND aut_aux.status_solicitud= SOLIC.status_solicitud)
					INNER JOIN bdinteg:si_cliente as CTE ON (SOLIC.numcte = CTE.numcte )						
					WHERE ( SOL.numero_region is null OR SOL.numero_region = 0)
					AND SOLIC.numcte = CASE WHEN(pNumCte <> "") THEN pNumCte ELSE SOLIC.numcte END
					AND SOLIC.num_solicitud = CASE WHEN(pNumCred <> "") THEN pNumCred ELSE SOLIC.num_solicitud END
					AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin
					ORDER BY REG.nombre_region, SOL.num_solicitud

                   IF NVL(vdias,0) <= (NVL((SELECT valor from bdicobranza:cb_param where cod_param = 7),0))  THEN
      								RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
      								vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
      								vciudad, vestado, vtelefono1, vtelefono2, vtelefono3, vNombreRegion, cNumCliente WITH RESUME;
                   END IF
		        END FOREACH;
			END IF;
		ELSE --SI NO EXISTEN DATOS ALMACENADOS
			LET sCodRet='00002';
			LET cErrorInfo='NO EXISTEN DATOS ALMACENADOS EN LA TABLA';

			RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
				vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
				vciudad, vestado, vtelefono1, vtelefono2, vtelefono3,vNombreRegion, cNumCliente;
		END IF;
	END IF;

/*
	LET sCodRet='00002';
	LET cErrorInfo='NO EXISTEN DATOS ALMACENADOS EN LA TABLA';
	
	RETURN sCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud,
			vnombre_cliente, vfecha_nac,vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona,
			vciudad, vestado, vtelefono1, vtelefono2, vtelefono3,vNombreRegion, cNumCliente;
*/			

END ;
END PROCEDURE 

