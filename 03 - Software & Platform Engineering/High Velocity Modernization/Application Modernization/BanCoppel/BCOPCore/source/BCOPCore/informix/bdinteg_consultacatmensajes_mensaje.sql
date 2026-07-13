CREATE PROCEDURE "informix".consultacatmensajes_mensaje
(
	iTipoConsulta	INTEGER,
	iTipoProceso	INTEGER,
	sAuxiliar1		CHAR(20), --Auxiliar1 sSituacionEspecial - sNumero_Solicitud - sPuntualidad - Comprobante domicilio digitalizado tipoconsulta = 2
	sAuxiliar2		CHAR(20), --Auxiliar2 sCausa
	sAuxiliar3		CHAR(20)  --Auxiliar3 Numcte
)

RETURNING	CHAR(5),
			CHAR(2);


--DEFINICION DE VARIABLES

DEFINE maes_CodRet			   CHAR(5);
DEFINE maes_NumMnje			   SMALLINT;
DEFINE maes_Sec				   SMALLINT;
DEFINE maes_Descrip		       CHAR(100);
DEFINE cCodRet					CHAR(5);
DEFINE vsqlerr 		INTEGER;
DEFINE sExiste              SMALLINT;
DEFINE p_CodRet					CHAR(5);
DEFINE p_NumMnje 				CHAR(2);
DEFINE cOfertar           char(1);
--Estas variables son para el tipo de proceso numero 2, cuando iTipoProceso = 2
--Se usan para la pantalla Asignacion de Tarjeta de Credito (APERTC)
--INICIALIZACION DE VARIABLES
LET maes_CodRet			  = '00000';
LET maes_NumMnje		  = 0;
LET maes_Sec		      = 0;
LET maes_Descrip		  = '';
LET cCodRet               = '1';
LET sExiste                 = 0;
LET p_CodRet				= '000';
LET p_NumMnje 			='';
LET cOfertar            = "";

--SET DEBUG FILE TO '/informix/consultacatmensajes_mensaje.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET vsqlerr
		IF vsqlerr != 0 THEN
			LET maes_CodRet = vsqlerr;
			SELECT COUNT(tabname) INTO sExiste FROM systables WHERE tabname = "tmp_mensajes";
			IF sExiste > 0 THEN
				DROP TABLE tmp_mensajes;
			END IF;
			RETURN maes_CodRet,maes_NumMnje;
		END IF ;
	END EXCEPTION ;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(tabname) INTO sExiste FROM systables WHERE tabname = "tmp_mensajes";
	
	IF sExiste > 0 THEN
		DROP TABLE tmp_mensajes;
	END IF;
	
	FOREACH
      EXECUTE PROCEDURE bdinteg:"informix".consultacatmensajesmaestro2(2,1,'0','', sAuxiliar3)
      INTO maes_CodRet,maes_NumMnje,maes_Sec,maes_Descrip
        IF maes_CodRet::INTEGER = 2 THEN
          LET cOfertar = "N";
          --EXIT FOREACH;
         --END IF
			ELSE
			IF maes_CodRet::INTEGER = 0 THEN
			 LET cOfertar = "S";
			END if 
		END IF;
    END FOREACH;

    RETURN maes_CodRet,maes_NumMnje;
	
	SELECT COUNT(tabname) INTO sExiste FROM systables WHERE tabname = "tmp_mensajes";

	IF sExiste > 0 THEN
		DROP TABLE tmp_mensajes;
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'REALIZO: IVAN CASTILLO MONTALVO.',
'Descripcion : Ejecuta catmensajesmaestro2 para obtener el numero de mensaje',
'FECHA: 01/11/2019',
'BD: BDINTEG',
'Fecha : 01/11/2019',
'BD  : Bdinteg';

CREATE PROCEDURE "informix".sp_elimina_referencias(pEmpresa CHAR(3),
														pNumSolicitudActual CHAR(20) ,
														pNumcte CHAR(20))

--RETORNOS-
RETURNING
CHAR(6)  AS codigo_ret;

--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(6);
DEFINE iSql_err				    INTEGER; 
DEFINE iIsamErr                 INTEGER;
DEFINE iBandera                 INTEGER;
DEFINE sSecuencia               INTEGER;


--INICIALIZACION DE VARIABLES--
LET cCodret                 = '000000'; --EJECUCION EXITOSA
LET iIsamErr                = 0;
LET iSql_err                = 0; 
LET iBandera                = 0;
LET sSecuencia				= 0;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err , iIsamErr
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret);
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/home/sysifx/Lerma/sp_elimina_referencias_debug.sql';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	 
	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSolicitudActual,'')= '' OR  NVL(pNumcte, '') = ''   THEN
		LET cCodret = '000001'; 
		RETURN TRIM(cCodret);
	 END IF;
	 
	 DELETE FROM bdisolic:"informix".ss_refpersonales where  num_solicitud = pNumSolicitudActual;
	
	 SELECT COUNT(*) 
	 INTO iBandera
	 FROM bdinteg:"informix".si_refclientes 
	 WHERE numcte = pNumcte 
	 AND num_solicitud = pNumSolicitudActual 
	 AND empresa = pEmpresa; 
	 
	If iBandera > 0 THEN	
		FOREACH
		
			SELECT {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} secuencia
			INTO sSecuencia
			FROM bdinteg:"informix".si_refclientes 
			WHERE numcte = pNumcte 
			AND num_solicitud = pNumSolicitudActual 
					
			
			DELETE {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} FROM bdinteg:"informix".si_refdirecciones WHERE secuencia = sSecuencia;
			
		END FOREACH;
		
		DELETE {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} FROM bdinteg:"informix".si_refclientes 
		WHERE numcte = pNumcte
		AND num_solicitud = pNumSolicitudActual 
		AND empresa = pEmpresa ;
		
	ELSE
		LET cCodret = '000002';  
	END IF;
	
	RETURN TRIM(cCodret) ;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃN: PROCEDIMIENTO PARA OBTENER LA SOLICITUD, VALIDA PARA HEREDAR LA INFORMACION A LA SOLICITUD NUEVA',
'FECHA DE CREACIÃN: 12 DE JULIO DE 2013',
'BASE DE DATOS: BDISOLIC',
'CREADOR: JESUS AGUILAR',
'VERSION: 201307121100';

CREATE PROCEDURE "informix".sp_detalle_boletos_v2(pClaveSort CHAR(5), pFechaActual DATE)
RETURNING CHAR (5) AS Codigo, CHAR(5) AS Clave_Sorteo, CHAR (80) AS Mensaje;

--- DECLARACION DE VARIABLES

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
	DEFINE vconsecutivo 	INTEGER;
    DEFINE vCodret          CHAR(5);
    DEFINE vCveSorteo       CHAR(5);
    DEFINE vMensaje         CHAR(80);

    DEFINE vF_Proceso       DATE;
    DEFINE vEmpresa         CHAR(3);
    DEFINE vCve_Sorteo      CHAR(5);
    DEFINE vF_ini           DATE;
    DEFINE vF_Fin           DATE;

    DEFINE vNumcte          CHAR(10);
	  DEFINE iNumcte          INTEGER;

    DEFINE vCve_Sort        CHAR(5);
    DEFINE vBoleto_ini      INT8;
    DEFINE vBoleto_Fin      INT8;
    DEFINE vF_registro      DATETIME YEAR TO SECOND;
    DEFINE vNumCliente      CHAR(10);
    DEFINE vEstado          INTEGER;
    DEFINE vSucursal        CHAR(4);
    DEFINE vArea            CHAR(1);
    DEFINE vCaja            INTEGER;
    DEFINE vTipomov         CHAR(10);
    DEFINE vFoliosuc        CHAR(16);
    DEFINE vImporte         MONEY;
    DEFINE vTel1            CHAR(10);
    DEFINE vTel2            CHAR(13);
    DEFINE vNombre          CHAR(45);
    DEFINE vCiudad          CHAR(20);
    DEFINE vDomicilio       CHAR(50);
	DEFINE vEntfed		    CHAR(25);
    DEFINE vFecha           DATE;
    DEFINE vOrigen          CHAR(10);
    DEFINE vSecuencia       INTEGER;
    DEFINE vLimite          INTEGER;
    DEFINE vContador        INTEGER;
    DEFINE vContSecuencia   INTEGER;

    DEFINE cCodRet          CHAR(3);
    DEFINE v_Valor          CHAR(5);
	  --DEFINE vrowid       	  INTEGER;
	  DEFINE vCuentaBoletos   INTEGER;
	  DEFINE vCuentaEmpleados INTEGER;
  	DEFINE vcontador2 		INTEGER;


--- INICIALIZACION DE VARIABLES

    LET sql_err         = 0;
    LET isam_err        = 0;
    LET vCodret         = '00000';
    LET vCveSorteo      = pClaveSort;
    LET vMensaje        = 'El proceso concluyÃÂ³ exitosamente';

    LET vF_Proceso      = '';
    LET vEmpresa        = '001';
    LET vCve_Sorteo     = '0';
    LET vF_ini          = '';
    LET vF_Fin          = '';

    LET vNumcte         = '';

    LET vCve_Sort       = '';
    LET vBoleto_ini     = '';
    LET vBoleto_Fin     = '';
    LET vF_registro     = '';
    LET vNumCliente     = '';
    LET vEstado         = '';
    LET vSucursal       = '';
    LET vArea           = '';
    LET vCaja           = '';
    LET vTipomov        = '';
    LET vFoliosuc       = '';
    LET vImporte        = 0.00;
    LET vTel1           = '';
    LET vTel2           = '';
    LET vNombre         = '';
    LET vCiudad         = '';
    LET vDomicilio      = '';
	LET vEntfed			= '';
    LET vFecha          = '';
    LET vOrigen         = '';
    LET vSecuencia      = '';
    LET vLimite         = 0;
    LET vContador       = 0;
    LET vContSecuencia  = 1;
	LET vconsecutivo 	= 1;

    LET cCodRet          = '';
    LET v_Valor          = '';
	  --LET vrowid      	   = 0;
	  LET iNumcte      	   = 0;
	  LET vCuentaBoletos   = 0;
	  LET vCuentaEmpleados = 0;
	  LET vcontador2		= 0;



     --****************************************************************
     -- Creado por RaÃÂºl RamÃÂ­rez    01/Septiembre/2010
     -- Proceso para traducir rangos de boletos a un detalle de boletos
     --****************************************************************


BEGIN

    ON EXCEPTION SET sql_err

        IF sql_err <> 0  THEN
            LET vCodret   = sql_err;
            LET vCodret   = '00045';
            LET vMensaje  = 'ERROR EN LA EJECUCION';
            RETURN vCodret, vCveSorteo, vMensaje;        -- Termina proceso del SP
        END IF;
    END EXCEPTION;
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
					FROM bdinteg:si_sorteo 
					--WHERE cve_sorteo = vCveSorteo AND pFechaActual -1 BETWEEN  f_ini AND f_fin AND flag_sort = 2) THEN 
					WHERE cve_sorteo = vCveSorteo AND pFechaActual BETWEEN  f_ini AND f_fin AND flag_sort = 2) THEN
        --SET DEBUG FILE TO "/ids10_uc9/raul/sorteo/sp_detalle_boletos.out";
        --TRACE ON;

				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				LET vF_Proceso = pFechaActual;
				--LET vF_Proceso = pFechaActual -1;

				SELECT {+INDEX(si_param ix_si_param)} valor
				INTO v_Valor
				FROM bdinteg:si_param
				WHERE empresa = vEmpresa
				AND cod_param = 118;

				SELECT {+INDEX (si_sorteo idx_si_sorteo2)} cve_sorteo, f_ini, f_fin
				INTO vCve_Sorteo, vF_ini, vF_Fin
				FROM bdinteg:si_sorteo
				WHERE cve_sorteo = v_Valor;


				IF (v_Valor IS NULL OR v_Valor = '') OR -- Valida clave sorteo vigente
				   (v_Valor <> pClaveSort) THEN
					 LET vCodret = '00040';
					 LET vMensaje = 'NO EXISTE SORTEO';
						RETURN vCodret, vCveSorteo, vMensaje;    -- Termina proceso del SP
				ELSE
					IF (vF_ini IS NULL OR vF_ini = '') OR      -- Valida fecha sorteo vigente
					   (vF_Fin IS NULL OR vF_Fin = '') OR
					   (vF_Proceso NOT BETWEEN vF_ini AND vF_Fin) THEN
						  LET vCodret = '00042';
						  LET vMensaje = 'SORTEO NO ESTA VIGENTE?';
						RETURN vCodret, vCveSorteo, vMensaje;    -- Termina proceso del SP
					END IF;
				END IF;

				-- BGM 11-Nov-2010: Se agrega depuraciÃÂ³n de tabla si_boleto_temp
				TRUNCATE si_boleto_temp;
				
				EXECUTE PROCEDURE "informix".sp_movtos_reversados ('001')
						INTO cCodRet;
				
				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist2)} bdinteg:si_boleto_hist set estado = 101 
				WHERE foliosuc in (SELECT folio_suc FROM si_movreversados) 
				AND fecha = vF_Proceso;
					
				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist3)} bdinteg:si_boleto_hist set estado = 101 
				WHERE numcte in (SELECT numcte FROM si_syssorteo_emp)
				AND fecha = vF_Proceso;
				
				
				FOREACH cursor_inserta WITH HOLD FOR
						


						SELECT {+INDEX (si_boleto_hist idx_si_boleto_hist2)}
								cve_sorteo, boleto_ini, boleto_fin, f_registro, numcte, estado, sucursal, area, caja, tipomov,
								foliosuc, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia, ent_fed
						INTO  vCve_Sort, vBoleto_Ini, vBoleto_Fin, vF_registro, vNumCliente, vEstado, vSucursal, vArea, vCaja, vTipomov,
						  vFoliosuc, vImporte, vTel1, vTel2, vNombre, vCiudad, vDomicilio, vFecha, vOrigen, vSecuencia, vEntfed
						FROM bdinteg:si_boleto_hist
						WHERE cve_sorteo =  vCveSorteo
						AND foliosuc <> ''
						AND fecha = vF_Proceso
						AND estado = 2
						
						LET vLimite = vBoleto_Fin;
						BEGIN WORK;
							FOR vContador = vBoleto_Ini TO vLimite

								LET vcontador2 = vcontador2 +1 ;

								INSERT INTO si_boleto_temp(cve_sorteo, boleto, f_registro, numcte, estado, sucursal, area, caja, tipomov,
											foliosuc, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia, ent_fed, consecutivo)
								VALUES (vCve_Sort, vContador, vF_registro, vNumCliente, vEstado, vSucursal, vArea, vCaja, vTipomov,
										vFoliosuc, vImporte, vTel1, vTel2, vNombre, vCiudad, vDomicilio, vFecha, vOrigen, vContSecuencia, vEntfed, vconsecutivo);
								LET vContSecuencia = vContSecuencia + 1;
								LET vconsecutivo = vconsecutivo + 1;

								IF vcontador2 >= 1000 THEN
									LET vcontador2 = 0;
									COMMIT WORK;
									BEGIN WORK;									
								END IF;
							END FOR

							LET vContSecuencia = 1;
						COMMIT WORK;             
						   
				END FOREACH;

			  -- BGM 11-Nov-2010: Se agrega depuraciÃÂ³n de tabla si_boleto;
				--TRUNCATE si_boleto;
				TRUNCATE si_movreversados;
	
	ELSE
		LET vCodret = "22222";
        LET vMensaje = "ÃÂ¡EL SORTEO NAVIDEÃÂO NO ESTA ACTIVO!";
	END IF;	
		  
END
    RETURN vCodret, vCveSorteo, vMensaje;

END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÃÂLEZ',
'FECHA DE MODIFICACIÃÂN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_elimina_referencias_pba(pEmpresa CHAR(3),
														pNumSolicitudActualbco CHAR(20) ,
														pNumcte CHAR(20),
														pNumSolicitudActualcpl CHAR(20)
														)

--RETORNOS-
RETURNING
CHAR(6)  AS codigo_ret;

--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(6);
DEFINE iSql_err				    INTEGER; 
DEFINE iIsamErr                 INTEGER;
DEFINE iBandera                 INTEGER;
DEFINE iBandera1                 INTEGER;
DEFINE sSecuencia               INTEGER;


--INICIALIZACION DE VARIABLES--
LET cCodret                 = '000000'; --EJECUCION EXITOSA
LET iIsamErr                = 0;
LET iSql_err                = 0; 
LET iBandera                = 0;
LET iBandera1                = 0;
LET sSecuencia				= 0;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err , iIsamErr
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret);
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/home/sysifx/Lerma/sp_elimina_referencias_debug.sql';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	 
	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSolicitudActualbco,'')= '' OR  NVL(pNumcte, '') = ''   THEN
		LET cCodret = '000001'; 
		RETURN TRIM(cCodret);
	 END IF;
	 
	 DELETE FROM bdisolic:"informix".ss_refpersonales where  num_solicitud in (pNumSolicitudActualbco, pNumSolicitudActualcpl);
	
	 SELECT COUNT(*) 
	 INTO iBandera
	 FROM bdinteg:"informix".si_refclientes 
	 WHERE numcte = pNumcte 
	 AND num_solicitud = pNumSolicitudActualbco
	 AND empresa = pEmpresa;
	 
	 SELECT COUNT(*) 
	 INTO iBandera1
	 FROM bdinteg:"informix".si_refclientes 
	 WHERE numcte = pNumcte 
	 AND num_solicitud = pNumSolicitudActualcpl
	 AND empresa = pEmpresa;
	 
	  
	If iBandera > 0 THEN	
		
		FOREACH
		
			SELECT secuencia
			INTO sSecuencia
			FROM bdinteg:"informix".si_refclientes 
			WHERE numcte = pNumcte 
			AND num_solicitud = pNumSolicitudActualbco
		
			DELETE FROM bdinteg:"informix".si_refdirecciones WHERE numcte = pNumcte and secuencia = sSecuencia;
			DELETE FROM bdinteg:"informix".si_refclientes WHERE empresa = pEmpresa AND numcte = pNumcte AND secuencia = sSecuencia;
		
		END FOREACH;
	
	ELIF iBandera1 > 0 THEN	
		
		FOREACH
		
			SELECT {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} secuencia
			INTO sSecuencia
			FROM bdinteg:"informix".si_refclientes 
			WHERE numcte = pNumcte 
			AND num_solicitud = pNumSolicitudActualcpl
		
			DELETE FROM bdinteg:"informix".si_refdirecciones WHERE numcte = pNumcte and secuencia = sSecuencia;
			DELETE FROM bdinteg:"informix".si_refclientes WHERE empresa = pEmpresa AND numcte = pNumcte AND sSecuencia = sSecuencia;
		
	
		END FOREACH;
		
	ELSE
		LET cCodret = '000002';  
	END IF;
	
	RETURN TRIM(cCodret) ;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃN: PROCEDIMIENTO PARA OBTENER LA SOLICITUD, VALIDA PARA HEREDAR LA INFORMACION A LA SOLICITUD NUEVA',
'FECHA DE CREACIÃN: 12 DE JULIO DE 2013',
'BASE DE DATOS: BDISOLIC',
'CREADOR: JESUS AGUILAR',
'VERSION: 201307121100';

CREATE PROCEDURE "informix".sp_ws_inyeccion_au(
 pUserName CHAR(8),
 pUserPass CHAR(8),
 pSessionId CHAR(80),
 pIpOrigen CHAR(15),
 pAgentTransTypeCode CHAR(10),
 pAgentCd CHAR(3),
 pProductos CHAR(200),
 pNumCliente CHAR(20),
 pPrimerNombre CHAR(26),
 pSegundoNombre CHAR(26),
 pPrimerApellido CHAR(26),
 pSegundoApellido CHAR(26),
 pGenero CHAR(1),
 pFechNac CHAR(10),
 pRfc CHAR(13),
 pCorreo CHAR(100),
 pTelCasa CHAR(10),
 pTelCel CHAR(10),
 pCarrier CHAR(1),
 pPais CHAR(3),
 pCodPostal CHAR(5),
 pEstado CHAR(2),
 pCiudad CHAR(3),
 pColonia CHAR(10),
 pDeleMcpo CHAR(5),
 pCalle CHAR(10),
 pNumExterior CHAR(10),
 pNumInterior CHAR(10),
 pEntreCalles CHAR(40),
 pComplemento CHAR(80),
 pTarjetaActiva CHAR(1),
 pUltCuatroDigi CHAR(4),
 pCredHipote CHAR(1),
 pCredAutom CHAR(1),
 pAutoBuro CHAR(1),
 pEscolaridad CHAR(2),
 pEdoCivil CHAR(1),
 pTpoEdoCivilA CHAR(2),
 pTpoEdoCivilM CHAR(2),
 pTipoVivienda CHAR(1),
 pTpoDomActual CHAR(2),
 pNumHabitantes CHAR(2),
 pPerTrabajan CHAR(2),
 pPerDepen CHAR(2),
 pEmpresa CHAR(60),
 pTpoEmpActual CHAR(2),
 pTpoEmpAnte CHAR(2),
 pActividad CHAR(2),
 pSubactividad CHAR(2),
 pIngreso CHAR(8),
 pTelOficina CHAR(10),
 pPrimerNombreRef CHAR(26),
 pSegundoNombreRef CHAR(26),
 pPrimerApellRef CHAR(26),
 pSegundoApellRef CHAR(26),
 pFechNacRef CHAR(10),
 pGeneroRef CHAR(1),
 pParentescoRef CHAR(2),
 pTelCelRef CHAR(10),
 pEjecutivo CHAR(8),
 pNumeroControl CHAR (25)
)
RETURNING 
CHAR(4)    AS codRet,
CHAR(120)  AS mensajeResp,
CHAR(2)    AS estatusSolBcpl,
CHAR(40)   AS descEstatusBcpl,
CHAR(255)  AS motivoRechazoBcpl,
CHAR(4)    AS claveProductoBcpl,
CHAR(20)   AS folioSolicitudBcpl,
CHAR(2)    AS estatusSolCpl,
CHAR(40)   AS descEstatusCpl,
CHAR(255)  AS causaSituacionCpl,
CHAR(4)    AS claveProducto,
CHAR(20)   AS folioSolicitudCpl;
         
DEFINE sql_err INTEGER;
DEFINE codRet CHAR(4);
DEFINE mensajeResp CHAR(120);
DEFINE estatusSolBcpl CHAR(2);
DEFINE descEstatusBcpl CHAR(40);
DEFINE motivoRechazoBcpl CHAR(255);
DEFINE claveProductoBcpl CHAR(4);
DEFINE folioSolicitudBcpl CHAR(20);
DEFINE estatusSolCpl CHAR(2);
DEFINE descEstatusCpl CHAR(40);
DEFINE causaSituacionCpl CHAR(255);
DEFINE claveProducto CHAR(4);
DEFINE folioSolicitudCpl CHAR(20);
DEFINE tipoCliente CHAR(1);

LET codRet = '0000';
LET mensajeResp = '';
LET estatusSolBcpl = '';
LET descEstatusBcpl = '';
LET motivoRechazoBcpl = '';
LET claveProductoBcpl = '';
LET folioSolicitudBcpl = '';
LET estatusSolCpl = '';
LET descEstatusCpl = '';
LET causaSituacionCpl = '';
LET claveProducto = '';
LET folioSolicitudCpl = '';
LET tipoCliente = '';
		 

    BEGIN
 
    ON EXCEPTION SET sql_err

		IF sql_err <> 0 THEN
				LET codRet = REPLACE(sql_err,'-','');
				LET mensajeResp = 'Error en base de datos.';
				
				RETURN codRet, mensajeResp, estatusSolBcpl, descEstatusBcpl, motivoRechazoBcpl, claveProductoBcpl, folioSolicitudBcpl, estatusSolCpl, descEstatusCpl, causaSituacionCpl, claveProducto, folioSolicitudCpl;
		END IF;

    END EXCEPTION;

	 --SET DEBUG FILE TO "/tmp/sp_ws_inyeccion_au.out";
	 --TRACE ON;
 
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NVL(TRIM(pUserName),'') <> '' AND NVL(TRIM(pUserPass),'') <> '' AND NVL(TRIM(pSessionId),'') <> '' AND NVL(TRIM(pIpOrigen),'') <> '' AND NVL(TRIM(pAgentTransTypeCode),'') <> '' AND NVL(TRIM(pAgentCd),'') <> ''
	   AND NVL(TRIM(pProductos),'') <> '' AND NVL(TRIM(pNumCliente),'') <> '' AND NVL(TRIM(pPrimerNombre),'') <> '' AND NVL(TRIM(pPrimerApellido),'') <> '' AND NVL(TRIM(pGenero),'') <> '' AND NVL(TRIM(pFechNac),'') <> ''
	   AND NVL(TRIM(pRfc),'') <> '' AND NVL(TRIM(pCorreo),'') <> '' AND NVL(TRIM(pTelCel),'') <> '' AND NVL(TRIM(pCarrier),'') <> '' AND NVL(TRIM(pPais),'') <> '' 
	   AND NVL(TRIM(pCodPostal),'') <> '' AND NVL(TRIM(pEstado),'') <> '' AND NVL(TRIM(pCiudad),'') <> '' AND NVL(TRIM(pColonia),'') <> '' AND NVL(TRIM(pDeleMcpo),'') <> '' AND NVL(TRIM(pCalle),'') <> ''
	   AND NVL(TRIM(pNumExterior),'') <> '' AND NVL(TRIM(pTarjetaActiva),'') <> '' AND NVL(TRIM(pUltCuatroDigi),'') <> '' AND NVL(TRIM(pCredHipote),'') <> '' AND NVL(TRIM(pCredAutom),'') <> '' 
	   AND NVL(TRIM(pAutoBuro),'') <> '' AND NVL(TRIM(pEscolaridad),'') <> '' AND NVL(TRIM(pEdoCivil),'') <> '' AND NVL(TRIM(pTpoEdoCivilA),'') <> '' --AND NVL(TRIM(pTpoEdoCivilM),'') <> ''
	   AND NVL(TRIM(pTipoVivienda),'') <> '' AND NVL(TRIM(pTpoDomActual),'') <> '' AND NVL(TRIM(pNumHabitantes),'') <> '' AND NVL(TRIM(pPerTrabajan),'') <> '' AND NVL(TRIM(pPerDepen),'') <> '' 
	   AND NVL(TRIM(pTpoEmpActual),'') <> '' AND NVL(TRIM(pTpoEmpAnte),'') <> '' AND NVL(TRIM(pActividad),'') <> '' AND NVL(TRIM(pSubactividad),'') <> '' AND NVL(TRIM(pIngreso),'') <> '' AND NVL(TRIM(pPrimerNombreRef),'') <> ''
	   AND NVL(TRIM(pPrimerApellRef),'') <> '' AND NVL(TRIM(pFechNacRef),'') <> '' AND NVL(TRIM(pGeneroRef),'') <> '' AND NVL(TRIM(pParentescoRef),'') <> '' AND NVL(TRIM(pTelCelRef),'') <> '' AND NVL(TRIM(pEjecutivo),'') <> '' THEN
	
		EXECUTE PROCEDURE  bdisac:"informix".sp_valida_session(TRIM(pAgentTransTypeCode), TRIM(pAgentCd), TRIM(pUserName), TRIM(pUserPass), TRIM(pIpOrigen), TRIM(pSessionId) ) INTO codRet, mensajeResp;
		
		IF TRIM(codRet) = '0000' THEN 
	
			SELECT NVL(tipo_cliente,'') INTO estatusSolBcpl FROM bdinteg:si_cliente where numcte = TRIM(pNumCliente);
	
		END IF;		
	ELSE	
		LET codRet= "9996";
		LET mensajeResp = "Uno de los parÃÂ¡metros de seguridad viene vacÃÂ­o";
	END IF;
	
 RETURN codRet, mensajeResp, estatusSolBcpl, descEstatusBcpl, motivoRechazoBcpl, claveProductoBcpl, folioSolicitudBcpl, estatusSolCpl, descEstatusCpl, causaSituacionCpl, claveProducto, folioSolicitudCpl;
 
END;
END PROCEDURE;