CREATE PROCEDURE "informix".sp_consulta_estatus_os3(pUsuario CHAR(8), pAgrupamiento CHAR(25), pNumSucursal CHAR(4), pStatusSolct CHAR(2), pArea CHAR(3), pRegInicio INTEGER,
												pRegFin INTEGER,pMatriz_impr SMALLINT, pFecha_Inicio CHAR(10), pFecha_Fin CHAR(10),pNumCte CHAR(9), pNumCred CHAR(12), pNombreReporte CHAR(100))
RETURNING CHAR(5);

DEFINE cCodRet 					CHAR(5) ;
DEFINE iCodRet 					INTEGER ;
DEFINE sErrorInfo 				CHAR(80);
DEFINE cErrorInfo	 			CHAR(80);
DEFINE iIsamErr 				SMALLINT;
DEFINE vestatusos 				INTEGER ;
DEFINE vnumerocobranzas 		SMALLINT;
DEFINE vnombre 					CHAR(40);
DEFINE vabrevia_prod 			CHAR(5) ;
DEFINE vnum_solicitud 			CHAR(20);
DEFINE vfechasolic 				DATE    ;
DEFINE vstatus_solicitud 		CHAR(2) ;
DEFINE vnombre_cliente 			CHAR(170);
DEFINE vfecha_nac 				DATE    ;
DEFINE vfolio 					CHAR(50);
DEFINE vfechaos 				DATE    ;
DEFINE vdias 					INTEGER ;
DEFINE vnombrecalle 			CHAR(30);
DEFINE vnumeroextcalle 			CHAR(10);
DEFINE vnumerointcalle 			CHAR(10);
DEFINE vcomplemento 			CHAR(80);
DEFINE vzona 					CHAR(50);
DEFINE vciudad 					CHAR(10);
DEFINE vestado 					CHAR(10);
DEFINE vtelefono1 				CHAR(13);
DEFINE vtelefono2 				CHAR(13);
DEFINE vtelefono3 				CHAR(13);
DEFINE vNombreRegion 			CHAR(30);
DEFINE cNomSucursal 			CHAR(40);
DEFINE cNumCliente				CHAR(20);
DEFINE sRegistros 				SMALLINT;
DEFINE iBandRegOS				INTEGER ;
DEFINE iDiasMinOS				INTEGER ;
DEFINE iDiasMaxOS				INTEGER ;
DEFINE sExiste					SMALLINT;
DEFINE dtFechaIni DATE;
DEFINE dtFechaFin DATE;
DEFINE sHoraActual char(15);
DEFINE sMinsActual char(2);
DEFINE iHoraActual integer;
--
DEFINE bInTransaccion   BOOLEAN;
DEFINE iRow INTEGER;
DEFINE iContBloque INTEGER;
DEFINE iRecuperacion INTEGER;

DEFINE vnumero_region SMALLINT;
DEFINE vstatus_solic CHAR(2);
DEFINE vnumcte_solic CHAR(20);
DEFINE dmaxfecha DATE;
DEFINE vnum_solicitud_f CHAR(20);

LET cCodRet 					= "00000";
LET cErrorInfo					= "PROCESO EXITOSO";
LET sErrorInfo					= "";
LET	iCodRet						= 0;

LET vestatusos 					= 0;
LET vnumerocobranzas 			= 0;
LET vnombre 					= "";
LET vabrevia_prod 				= "";
LET vnum_solicitud 				= "";
LET vfechasolic 				= "01-01-1900";
LET vstatus_solicitud 			= "";
LET vnombre_cliente 			= "";
LET vfecha_nac 					= "01-01-1900";
LET vfolio 						= "";
LET vfechaos 					= "01-01-1900";
LET vdias 						= 0;
LET vnombrecalle 				= "";
LET vnumeroextcalle 			= "";
LET vnumerointcalle 			= "";
LET vcomplemento 				= "";
LET vzona 						= "";
LET vciudad					  	= "";
LET vestado 					= "";
LET vtelefono1 					= "";
LET vtelefono2 					= "";
LET vtelefono3 					= "";
LET vNombreRegion 				= "";
LET cNomSucursal 				= "";
LET cNumCliente      	 		= "";
LET sRegistros					= 0;
LET iBandRegOS					= 0;
LET iDiasMinOS					= 0;
LET iDiasMaxOS					= 0;
LET sExiste						= 0;
LET dtFechaIni = pFecha_Inicio;
LET dtFechaFin = pFecha_Fin;
LET sHoraActual = '';
LET sMinsActual = '';
LET iHoraActual = 0;
--
LET bInTransaccion   = 'f';
LET iRow = 0;
LET iContBloque = 0;
LET iRecuperacion = 0;

LET vnumero_region = 0;
LET vstatus_solic = '';
LET vnumcte_solic = '';
LET dmaxfecha = '';
LET vnum_solicitud_f = '';

BEGIN

    ON EXCEPTION SET iCodRet, iIsamErr, sErrorInfo
        Let cCodRet = iCodRet;
        RETURN cCodRet;
    END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		COMMIT WORK;
		BEGIN WORK;
		LET bInTransaccion = 't';                       
	END EXCEPTION WITH RESUME;

	--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_estatus_os3.out';
	--TRACE ON;

	--SE AGREGA PARA INICIALIZAR LAS VARIABLES DE LA FECHA EN CASO DE QUE LLEGUEN VACIAS...HECTOR  BOJORQUEZ
	IF NVL(dtFechaIni,"") = "" THEN
		LET dtFechaIni = DATE(1);
	END IF;
	IF NVL(dtFechaFin,"") = "" THEN
		LET dtFechaFin = CURRENT;
	END IF;
	
	--IF pNumCte = '' THEN
	--	LET pNumCte = NULL;
	--END IF;
	--IF pNumCred = '' THEN
	--	LET pNumCred = NULL;
	--END IF;
	--IF pNumSucursal = '' THEN
	--	LET pNumSucursal = NULL;
	--END IF;
	
	--VALIDAMOS LOS DATOS DE ENTRADA
	--IF NVL(pAgrupamiento,'')='' THEN
	--	LET cCodRet='00003';
	--	RETURN cCodRet;
	--ELSE

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--VALIDAMOS QUE LA CONSULTA NOS REGRESE DATOS
		SELECT LIMIT 1 num_solicitud INTO vnum_solicitud FROM bdisolic:ss_solicitud_env_os;
		LET sRegistros = dbinfo("sqlca.sqlerrd2");

		IF sRegistros > 0 THEN
			BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
				    /*SELECT {+INDEX (bdisolic:"informix".ss_autorizacion idx_ss_solicitud_status_fecha)} matriz_impr, numero_cobranza,
								nombre_sucursal, producto, SOL.num_solicitud, fecha_solicitud, SOL.status_solicitud,
								nombre_cliente, fecha_nacimiento, folio_os, fecha_os, dias_os, nombre_calle,
								num_exterior, num_interior, comple_domicilio, nombre_colonia, nombre_ciudad,
								nombre_estado, tel_particular, tel_celular, tel_trabajo, nombre_region
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
						AND SOLIC.sucursal = CASE WHEN(pNumSucursal <> "") THEN pNumSucursal ELSE SOLIC.sucursal END
						--WHERE SOLIC.numcte = NVL(pNumCte,SOLIC.numcte)
						--AND SOLIC.num_solicitud = NVL(pNumCred,SOLIC.num_solicitud)
						--AND SOLIC.sucursal = NVL(pNumSucursal,SOLIC.sucursal)
						AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin
						ORDER BY sol.nombre_sucursal, sol.num_solicitud*/
						
						SELECT {+INDEX (bdisolic:"informix".ss_solicitud_env_os numero_solicitud)} 
						matriz_impr, numero_cobranza,
						nombre_sucursal, producto, SOL.num_solicitud, fecha_solicitud, SOL.status_solicitud,
						nombre_cliente, fecha_nacimiento, folio_os, fecha_os, dias_os, nombre_calle,
						num_exterior, num_interior, comple_domicilio, nombre_colonia, nombre_ciudad,
						nombre_estado, tel_particular, tel_celular, tel_trabajo, 
						numero_region,SOLIC.status_solicitud,SOLIC.numcte
						INTO vestatusos, vnumerocobranzas, 
						vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, 
						vnombre_cliente, vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, 
						vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, 
						vestado, vtelefono1, vtelefono2, vtelefono3,
						vnumero_region,vstatus_solic,vnumcte_solic
						FROM bdisolic:ss_solicitud_env_os  as SOL
						INNER JOIN bdisolic:ss_solicitudes as SOLIC ON (SOL.num_solicitud = SOLIC.num_solicitud)
						WHERE SOLIC.numcte = CASE WHEN(pNumCte <> "") THEN pNumCte ELSE SOLIC.numcte END
						AND SOLIC.num_solicitud = CASE WHEN(pNumCred <> "") THEN pNumCred ELSE SOLIC.num_solicitud END
						AND SOLIC.sucursal = CASE WHEN(pNumSucursal <> "") THEN pNumSucursal ELSE SOLIC.sucursal END
						ORDER BY sol.nombre_sucursal, sol.num_solicitud

						SELECT MAX(aut_aux.fecha_entrada)
						INTO dmaxfecha
						FROM bdisolic:ss_autorizacion aut_aux
						WHERE aut_aux.empresa= '001'
						AND aut_aux.num_solicitud= vnum_solicitud
						AND aut_aux.status_solicitud= vstatus_solic;
						
						SELECT nombre_region INTO vNombreRegion 
						FROM bdinteg:si_regiones as REG WHERE REG.numero_region = vnumero_region;
						
						FOREACH
						SELECT aut.num_solicitud INTO vnum_solicitud_f
						FROM bdisolic:ss_autorizacion aut, bdinteg:si_cliente as CTE
						WHERE aut.num_solicitud = vnum_solicitud       
						AND aut.empresa= '001'
						AND aut.status_solicitud= vstatus_solic
						AND aut.fecha_entrada= dmaxfecha
						AND CTE.numcte = vnumcte_solic
						AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin
						
						IF NVL(vdias,0) <= (NVL((SELECT valor from bdicobranza:cb_param where cod_param = 7 AND empresa = '001'),0))  THEN
							
							INSERT INTO bdicnweb:"informix".sw_cnt_detallemonitorsol (estatusos,numerocobranzas,nombre,abrevia_prod,
							num_solicitud,fechasolic,status_solicitud,nombre_cliente,fecha_nac,folio,fechaos,dias,nombrecalle,	
							numeroextcalle,numerointcalle,complemento,zona,ciudad,estado,telefono1,telefono2,telefono3,nombreregion,num_cliente,usuario_insert,nombre_reporte,fecha_insert)			
							VALUES(vestatusos,vnumerocobranzas,vnombre,vabrevia_prod,vnum_solicitud,vfechasolic,vstatus_solicitud,
							vnombre_cliente,vfecha_nac,vfolio,vfechaos,vdias,vnombrecalle,vnumeroextcalle,vnumerointcalle,
							vcomplemento,vzona,vciudad,vestado,vtelefono1,vtelefono2,vtelefono3,NVL(vNombreRegion,'SIN REGION'),cNumCliente,pUsuario,pNombreReporte,CURRENT);
							
							LET iRecuperacion = iRecuperacion + 1;
							
							LET iContBloque = iContBloque + 1;
							IF iContBloque = 5000 THEN
								LET iContBloque = 0;
								COMMIT WORK;
								BEGIN WORK;
							END IF;
			
						END IF
						
						END FOREACH;
						
		    END FOREACH;
			COMMIT WORK;
			
			IF bInTransaccion = 't' THEN
				BEGIN WORK;
			END IF;
				
			IF iRecuperacion = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet;
			END IF;
			
			RETURN cCodRet;
			
		ELSE --SI NO EXISTEN DATOS ALMACENADOS
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
	--END IF;

END ;
END PROCEDURE
