CREATE PROCEDURE "informix".sp_respuesta_ws_dotacion_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10),pId_solicitud char(25),pEstatus char(60))
		RETURNING CHAR(5) AS codret
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;

		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/Eder/CashManagement/sp_respuesta_ws_dotacion_masiva.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''	OR pId_solicitud='' OR pEstatus='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        UPDATE bdicnweb:"informix".arch_dotacion_sucursal 
		SET 
			estatus_final='Terminado'
		WHERE id_servicio=pId_solicitud;
           
        IF DBINFO('sqlca.sqlerrd2') = 0  THEN
            LET cCodRet = '00017';
		END IF;   
		
		RETURN cCodRet;
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Eder SolÃ­s LÃ³pez',
'FECHA: 03/02/2023',
'MODULO: Cash Management',
'FUNCIONALIDAD: Cash Management',
'DESCRIPCION: SP encargado de actualizar registros de DotaciÃ³n masiva de sucursales con respuesta de web service de ETV.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_consultamsi_detalle(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(30),pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING 	CHAR(5) AS codret,
				CHAR(10) AS fecha,
				CHAR(10) AS hora,
				CHAR(16) AS tarjeta,
				CHAR(16) AS folio, 
				CHAR(3) AS codfun,
				CHAR(100) AS descripcion,
				CHAR(40) AS infreceptor,
				CHAR(40) AS referencia,
				DECIMAL(18,2) AS monto,
				INTEGER AS plazo,
				CHAR(5) AS plazopago,
				CHAR(60) AS status,
				DECIMAL(18,2) AS saldoliq,
				DECIMAL(18,2) AS saldopag,
				INTEGER AS llave;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE dSdoTotalLiq DECIMAL(18,2);    
	DEFINE dSaldo_pagar DECIMAL(18,2);
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(10);
	DEFINE cTarjeta CHAR(16);
	DEFINE cFolio CHAR(16);
	DEFINE cCodFun CHAR(3);
	DEFINE cDescripcion CHAR(100);
	DEFINE cInfReceptor CHAR(40);
	DEFINE cReferencia CHAR(40);
	DEFINE dMontoOtorgado DECIMAL(18,2);
	DEFINE cStatus CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE cPlazoA CHAR(5);
	DEFINE cNumPago CHAR(5);
	DEFINE iLlave INTEGER;
    DEFINE iPlazo INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET dSdoTotalLiq  =0;    
	LET dSaldo_pagar  =0;
	LET cFecha ='';
	LET cHora ='';
	LET cTarjeta ='';
	LET cFolio ='';
	LET cCodFun ='';
	LET cDescripcion ='';
	LET cInfReceptor ='';
	LET cReferencia ='';
	LET dMontoOtorgado  =0;
	LET cStatus ='';
	LET iNoRegistros =0;
	LET cPlazoA='';
	LET cNumPago='';
	LET iLlave =0;
    LET iPlazo = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END EXCEPTION;

		--SET DEBUG FILE TO '/RESPALDOSNEW/sp_msi_consultamsi_detalle.out';
		--TRACE ON;

		IF pUsuario ='' OR pIdFuncion='' OR pNumCred='' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH SELECT 
				SKIP pRegistros FIRST pRecuperacion  
				     TO_CHAR(fecha,'%d/%m/%Y'), hora, tarjeta, folio,cod_fun,descripcion,infreceptor,referencia,montootorgado,plazo,cplazo,status,saldoliq,saldopag,llave
				INTO cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave
				FROM
				"informix".sw_msi_consultagrid where llave = pNumCred and id = 'D' and usuario = pUsuario ORDER BY fecha,referencia
				
				LET iNoRegistros = iNoRegistros +1;
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '01276';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2022',
'FUNCIONALIDAD: CONSULTA MSI',
'DESCRIPCION: SPL que realiza la consulta de las transaciones a MSI',
'AUTOR: Veronica Sanchez',
'FECHA: 10/02/2023',
'DESCRIPCION: Se realiza ajuste a SPL para aplicar formato en campo fecha',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_registracancelacion (pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(30),pFoliomvto CHAR(16),pPromo INTEGER,pCanal CHAR(1),pSucursal CHAR(4))
	RETURNING 	CHAR(5) AS codret;
	


	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRetSP 		CHAR(6);
	DEFINE cMsjResp			CHAR(80);
	
	LET cCodRet 			= '00000';
	LET iSqlErr 			= 0;
	LET cCodRetSP 			= '000000';
	LET cMsjResp			= '';
 
	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_msi_registracancelacion.out';
		--TRACE ON;

		IF pUsuario ='' OR pIdFuncion='' OR pNumCred='' OR pFoliomvto ='' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		EXECUTE PROCEDURE bdicred:"informix".sp_msi_cancela_msi_credito('001', pFoliomvto, pNumCred, pCanal, pSucursal, pUsuario)
		INTO cCodRetSP,cMsjResp;
				
		IF cCodRetSP ='000000' THEN
			LET cCodRet = '00000';
		ELSE
			LET cCodRet = '01280'; --CREDITO MSI NO VALIDO PARA CANCELARSE
		END IF;
		
		RETURN cCodRet;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2021',
'FUNCIONALIDAD: CANCELA MSI',
'DESCRIPCION: SPL que realiza el registro de una cancelacion para MSI',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 16/06/2023',
'DESCRIPCION: Se realiza ajuste a SP para modificar los parametros de entrada del SPL sp_msi_cancela_msi_credito';

CREATE PROCEDURE "informix".sp_msi_genrepmsigrid(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(300), pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cBanDetError CHAR(1);
	DEFINE iTotal INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cFechaHoraArchivo CHAR(35);
	
	DEFINE cAux CHAR(100);
    DEFINE cAux2 CHAR(100);
    DEFINE i INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cBanDetError = 'f';
	LET iTotal = 0;
	LET dFechaHoy ='';
	LET dHoraHoy = '';
	LET cFechaHoraArchivo='';
	
	LET cAux ='';
    LET cAux2 = '';
    LET i =0;

	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
			
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;      

		--SET DEBUG FILE TO '/tmp/mfinis/sp_msi_genrepmsigrid.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR pNumCred ='' THEN
			LET cCodRet = '00003';				
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN		     
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		
		 -- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".sw_msi_numcred_tmp WHERE usuario = pUsuario;
		
		FOR i = 1 TO LENGTH(TRIM(pNumCred)) 
		
			IF SUBSTR(TRIM(pNumCred), i, 1) = ',' THEN
            INSERT INTO "informix".sw_msi_numcred_tmp VALUES(cAux,pUsuario);
            LET cAux ='';
			ELSE
			LET cAux2 =  SUBSTR(TRIM(pNumCred), i, 1);
            LET cAux = TRIM(cAux)||TRIM(cAux2);
			END IF 
			
			IF i = LENGTH(TRIM(pNumCred)) THEN 
             INSERT INTO "informix".sw_msi_numcred_tmp VALUES(cAux,pUsuario);
			END IF;
		END FOR;
  
		SELECT COUNT(*) INTO iTotal FROM "informix".sw_msi_consultagrid WHERE usuario = pUsuario;
		
		IF iTotal = 0 THEN			
			LET cCodRet ='00017';					
		END IF;
		
		
        IF cCodRet='00000' THEN 
		--GENERACION DE REPORTE	
		LET cCmd1 ="";
        LET cCmd1 ="SELECT 'FECHA','HORA','TARJETA','FOLIO','TRANSACCION','DESCRIPCION','CONCEPTO','REFERENCIA','MONTO','PLAZO','NO. DE PAGO/PLAZO','ESTATUS','SALDO PENDIENTE','SALDO A PAGAR' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ( ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(fecha),2,0)||'/'||LPAD(MONTH(fecha),2,0)||'/'||YEAR(fecha),hora::CHAR(10),''''||tarjeta::CHAR(16),folio::CHAR(16),''''||cod_fun::CHAR(3),descripcion::CHAR(60),infreceptor::CHAR(40),referencia::CHAR(40),montootorgado::CHAR(20),plazo::CHAR(11),CASE WHEN cplazo= '' THEN ' ' ELSE ''''||cplazo END ,status::CHAR(60),saldoliq::CHAR(20),saldopag::CHAR(20) FROM ""informix"".sw_msi_consultagrid WHERE llave in (select num_cred from  ""informix"".sw_msi_numcred_tmp where usuario ='"||pUsuario||"') and usuario ='"||pUsuario||"' ORDER BY llave,id,fecha)"; 
		
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		
		LET cFechaHoraArchivo = TO_CHAR(dFechaHoy, '%d%m%Y')||"_"||TO_CHAR(dHoraHoy, '%H%M%S');
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		
		LET cNombreArchivo = 'REP_DET_MOVTOS_'||TRIM(cFechaHoraArchivo)||'.xls';
		
        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
 
						LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'repmsisoc.sql';
             
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'repmsisoc.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        --RUTA PRUEBAS
						--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'repmsisoc.sql';
						--RUTA PRODUCTIVA
						LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'repmsisoc.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'repmsisoc.sql';
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de lÃ­nea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el archivo original
                        LET cSql = '';
                        LET cSql = "rm -rf "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de lÃ­nea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

        LET cBanDetError = 't';

				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
	
                             
	    END IF;
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT  
'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2022',
'DESCRIPCION: SPL que genera el reporte para la funcionalidad de MSI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultanumsolicitudcoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumSolicitud CHAR(20))
		RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_cte,
		CHAR(20) AS num_solicitud,
		CHAR(104) AS nombre,
		CHAR(4) AS 	sucursal,
		DATE AS 	fecha_solicitud,
		DATE AS 	fecha_cambio_solicitud,
		CHAR(2) AS 	status_solicitud,
		CHAR(3) AS 	causa_solicitud,
		CHAR(1) AS bandera,
		CHAR(1) AS estatus;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNumCte CHAR(20);
	DEFINE cNoCte CHAR(20);
	DEFINE cNumSolicitud  CHAR(20);
	DEFINE cNoSolicitud  CHAR(20);
	DEFINE cNombre	CHAR(90);	
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaSolicitud DATE; 
	DEFINE dFechaCambioSolicitud DATE;
	DEFINE cStatusSolicitud	CHAR(2);
	DEFINE cCausaSolicitud CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE vNumProducto CHAR(4);
	DEFINE vFechaSolictudUltima CHAR(25);
	DEFINE vNumSolicitud CHAR(20);
	DEFINE cBandera CHAR(1);
	DEFINE cStatus CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cNumCte = '';
	LET cNumSolicitud = '';
	LET cNombre = '';
	LET cSucursal = '';
	LET dFechaSolicitud = '';
	LET dFechaCambioSolicitud = '';
	LET cStatusSolicitud = '';
	LET cCausaSolicitud = '';
	LET iNoRegistros = 0;
	LET vNumProducto = '6001';
	LET vFechaSolictudUltima = '';
	LET vNumSolicitud = '';
	LET cBandera = '';
	LET cStatus = '';
	LET cNoCte = '';
	LET cNoSolicitud = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/ifxsif01/roman/ambientacion/TDC_INFINITE/Spl/sp_cre_consultanumsolicitudcoppel.out';
        --TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
		END IF;
						
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF pNumCte <> '' AND pNumSolicitud = '' THEN 
		
			SELECT LIMIT 1 MAX (fecha_insert)
			INTO vFechaSolictudUltima
			FROM bdisolic:"informix".ss_solicitudes
			WHERE numcte = pNumCte
			AND num_producto = vNumProducto;
			
			IF vFechaSolictudUltima <> '' OR vFechaSolictudUltima IS NOT NULL THEN 			
				SELECT LIMIT 1 num_solicitud 
				INTO vNumSolicitud
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE numcte = pNumCte
				AND fecha_insert = vFechaSolictudUltima::DATE
				AND num_producto = vNumProducto;				
				LET pNumSolicitud = vNumSolicitud;				
			ELSE			
				LET pNumSolicitud = '';
			END IF;
		ELIF (pNumCte = '' AND pNumSolicitud <> '') THEN
				
				IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pNumSolicitud) > 0 THEN
					SELECT num_solicitud, numcte
					INTO cNoSolicitud, cNoCte
					FROM bdisolic:"informix".ss_solicitudes
					WHERE num_solicitud = pNumSolicitud;
					
					LET pNumSolicitud = cNoSolicitud;
					
				ELSE
					LET cNoSolicitud = '';
					LET cNoCte = '';
				END IF;
				
				IF cNoSolicitud = '' THEN
					LET cCodRet = '00017';
					RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
				END IF;
		
		END IF;		
		
		EXECUTE PROCEDURE "informix".sp_cre_consultaestatuscoppel(pUsuario, pIdFuncion, pNumSolicitud, pNumCte)
		INTO cCodRet, cStatus; 
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_cre_consultaestatuscoppel';
			ELIF cCodRetSp::INTEGER = 17 THEN
				LET cCodRet = '00017';
			END IF;
					
		IF (SELECT COUNT (s.num_solicitud) FROM  bdisolic:"informix".ss_solicitudes s INNER JOIN bdisolic:"informix".ss_autorizacion a ON  s.num_solicitud = a.num_solicitud
		WHERE num_producto = vNumProducto	AND s.num_solicitud = pNumSolicitud AND a.status_solicitud = 'CN' AND a.causa_solicitud = 'CR') > 0 THEN
				
										
				IF (SELECT COUNT (z.num_solicitud) FROM  bdisolic:"informix".ss_solicitudes z INNER JOIN bdisolic:"informix".ss_autorizacion k ON  z.num_solicitud = k.num_solicitud 	WHERE num_producto = vNumProducto	AND z.num_solicitud = pNumSolicitud)> 0 THEN-- AND k.causa_solicitud = 'RGC' AND k.status_solicitud = 'RT') > 0 THEN
									
					SELECT solic.numcte, solic.num_solicitud
					, TRIM(clit.nombre1) || ' ' || TRIM(clit.nombre2) || ' ' || TRIM(clit.apell_paterno) || ' ' || TRIM(clit.apell_materno) AS nombre
					, solic.sucursal, solic.fecha_insert, aut.fecha_insert, aut.status_solicitud, aut.causa_solicitud, '1' AS bandera
						INTO cNumCte, cNumSolicitud, cNombre, cSucursal, dFechaSolicitud, dFechaCambioSolicitud, cStatusSolicitud, cCausaSolicitud, cBandera
					FROM bdisolic:"informix".ss_solicitudes solic
						INNER JOIN bdisolic:"informix".ss_autorizacion aut ON  solic.num_solicitud = aut.num_solicitud AND solic.status_solicitud = aut.status_solicitud
						INNER JOIN bdinteg:"informix".si_cliente clit ON  solic.numcte = clit.numcte
					WHERE num_producto = '6001'
						AND solic.num_solicitud = pNumSolicitud
						AND aut.status_solicitud = 'CN'
						AND aut.causa_solicitud = 'CR';
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
				ELSE

					IF (pNumCte = '') THEN
						LET pNumCte = cNoCte;
					END IF;
									
					SELECT numcte, TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno) AS nombre, '0' AS bandera
						INTO cNumCte, cNombre, cBandera
					FROM  bdinteg:"informix".si_cliente 
					WHERE  numcte = pNumCte;
										
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
				END IF;
			ELSE 
				IF (SELECT COUNT (j.num_solicitud) FROM  bdisolic:"informix".ss_solicitudes j INNER JOIN bdisolic:"informix".ss_autorizacion o ON  j.num_solicitud = o.num_solicitud	WHERE num_producto = vNumProducto	AND j.num_solicitud = pNumSolicitud) > 0 THEN --AND o.status_solicitud = 'RT' AND o.causa_solicitud = 'RGC'
					
					SELECT solic.numcte, solic.num_solicitud
				, TRIM(clit.nombre1) || ' ' || TRIM(clit.nombre2) || ' ' || TRIM(clit.apell_paterno) || ' ' || TRIM(clit.apell_materno) AS nombre
				, solic.sucursal, solic.fecha_insert, aut.fecha_insert, aut.status_solicitud, aut.causa_solicitud, '1' AS bandera
					INTO cNumCte, cNumSolicitud, cNombre, cSucursal, dFechaSolicitud, dFechaCambioSolicitud, cStatusSolicitud, cCausaSolicitud, cBandera
				FROM bdisolic:"informix".ss_solicitudes solic
					INNER JOIN bdisolic:"informix".ss_autorizacion aut ON  solic.num_solicitud = aut.num_solicitud AND solic.status_solicitud = aut.status_solicitud
					INNER JOIN bdinteg:"informix".si_cliente clit ON  solic.numcte = clit.numcte
				WHERE num_producto = '6001'
					AND solic.num_solicitud = pNumSolicitud;
					--AND aut.status_solicitud = 'RT'
					--AND aut.causa_solicitud = 'RGC';
					
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
				ELSE
					LET iNoRegistros = 0;
				END IF;		
			END IF;				
			
			IF (iNoRegistros > 0) OR (pNumCte <> '') THEN
				IF (pNumCte <> '') THEN
					SELECT DISTINCT si.numcte, TRIM(si.nombre1) || ' ' || TRIM(si.nombre2) || ' ' || TRIM(si.apell_paterno) || ' ' || TRIM(si.apell_materno) AS nombre, '1' AS bandera
						INTO cNumCte, cNombre, cBandera
					FROM bdinteg:"informix".si_cliente si 
					WHERE si.numcte = pNumCte;
				ELSE
					SELECT DISTINCT s.numcte, TRIM(si.nombre1) || ' ' || TRIM(si.nombre2) || ' ' || TRIM(si.apell_paterno) || ' ' || TRIM(si.apell_materno) AS nombre, '1' AS bandera
						INTO cNumCte, cNombre, cBandera
						FROM bdisolic:"informix".ss_solicitudes s
							INNER JOIN bdinteg:"informix".si_cliente si ON  s.numcte = si.numcte
							AND s.num_solicitud = pNumSolicitud;
				END IF;	
				RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
			
			ELSE 
					IF (pNumCte = '') THEN
						LET pNumCte = cNoCte;
					END IF;
					
					SELECT DISTINCT si.numcte, TRIM(si.nombre1) || ' ' || TRIM(si.nombre2) || ' ' || TRIM(si.apell_paterno) || ' ' || TRIM(si.apell_materno) AS nombre, '0' AS bandera
					INTO cNumCte, cNombre, cBandera
					FROM bdinteg:"informix".si_cliente si 
					WHERE si.numcte = pNumCte;
					RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
		
			END IF;		
			
		RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 27/04/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: CREDITO GRUPO COPPEL',
'DESCRIPCION:SPL que realiza la bÃºsqueda por nÃºmero de solicitud o nÃºmero de cliente que cuentas con estatus RT o CN y motivo de cancelaciÃ³n RGC y CR..',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultamanttogat(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
		INTEGER		 AS plazo_inicio,
		INTEGER      AS plazo_fin,
		DECIMAL(9,6) AS tasa,
		DECIMAL(9,6) AS gat_nomina,
		DECIMAL(9,6) AS gat_real,
		DATE         AS fecha_publicacion,
		CHAR (2)     AS periodo,
		MONEY (14,2) AS rango_min,
		MONEY (14,2) AS rango_max,
		CHAR(4) 	 AS num_producto,
		CHAR(30)	 AS desc_producto,
		INTEGER 	 AS ROWID; 

    
	--DEFINICIÃN DE VARIABLES
	DEFINE cCodRet 		     CHAR(5);
	DEFINE iSqlErr 		     INTEGER;
	DEFINE iPlazoInicio      INTEGER;
	DEFINE iPlazoFin 	     INTEGER;
	DEFINE dTasa 		     DECIMAL(9,6);
	DEFINE dGatNomina 	     DECIMAL(9,6);
	DEFINE dGatReal 	     DECIMAL(9,6);
	DEFINE dFechaPublicacion DATE;
	DEFINE iNoRegistros      INTEGER;
	DEFINE iRegistros        INTEGER;
	DEFINE iRecuperacion     INTEGER;
	DEFINE iRowID			 INTEGER;

	DEFINE iPeriodo			 CHAR(2);
	DEFINE iRangoMin		 MONEY (14,2) ;
	DEFINE iRangoMax		 MONEY (14,2) ;
	DEFINE cNumProducto      CHAR(4);
	DEFINE cProductoDesc 	 CHAR(30);

	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET iPlazoInicio 	=0;
	LET iPlazoFin 	 	=0;
	LET dTasa 		 	=0.00;
	LET dGatNomina 	 	=0.00;
	LET dGatReal 	 	=0.00;
	LET dFechaPublicacion = '';
	LET iNoRegistros	= 0;
	LET iRegistros 		= 0;
	LET iRecuperacion	= 0;
	LET iRowID	= 0;

	LET iPeriodo		=0;
	LET iRangoMin		=0;
	LET iRangoMax		=0;
	LET cNumProducto 	= '';
	LET cProductoDesc	= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END EXCEPTION;

		-- SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultamanttogat.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--pagare,
		IF pBandera = '1' THEN
			FOREACH
				SELECT plazo_inicio, plazo_fin, tasa, gat_nomina, gat_real, periodo, rowid
				INTO 	iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal,iPeriodo, iRowID
				FROM bdinvers:"informix".sv_gat
				ORDER BY 1 ASC

			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
			END FOREACH;
		
		--1100 inversiï¿½n creciente
		ELIF pBandera = '2'  THEN

			FOREACH
				SELECT gat.fecha_publicacion, tipo.num_producto, tipo.desc_producto,  gat.tasa, gat.gat_nominal, gat.gat_real, gat.periodo, gat.ROWID 
				INTO dFechaPublicacion, cNumProducto, cProductoDesc, dTasa, dGatNomina, dGatReal, iPeriodo , iRowID  
				FROM bdicheq:"informix".sc_gat gat INNER JOIN bdicnweb:"informix".sw_cap_tipoproductogat tipo
				ON gat.producto = tipo.num_producto
				WHERE gat.producto = pProducto
				ORDER BY 1, 8 ASC


			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
			END FOREACH;

	
		ELIF pBandera = '3' THEN
			IF pProducto = "2500" OR pProducto = "2000" OR pProducto = "1900" OR pProducto = "1400" OR pProducto = "2400" OR pProducto = "1800" THEN  
				FOREACH
					SELECT gat.fecha_publicacion, gat.producto, gat.rango_min , gat.rango_max  ,gat.tasa, gat.gat_nominal, gat.gat_real, gat.periodo, gat.ROWID 
					INTO dFechaPublicacion, cNumProducto, iRangoMin, iRangoMax, dTasa, dGatNomina, dGatReal, iPeriodo, iRowID 
					FROM bdicheq:"informix".sc_gat gat
					WHERE gat.producto = pProducto
					ORDER BY 1, 8 ASC

					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
				END FOREACH;
			END IF;

		ELIF pBandera = '4' THEN
			IF pProducto = "2900" OR pProducto = "1300" THEN  
				FOREACH
					SELECT gat.fecha_publicacion, gat.producto, gat.tasa, gat.gat_nominal, gat.gat_real, gat.periodo, gat.ROWID 
					INTO dFechaPublicacion, cNumProducto, dTasa, dGatNomina, dGatReal, iPeriodo, iRowID
					FROM bdicheq:"informix".sc_gat gat
					WHERE gat.producto = pProducto
					ORDER BY 1, 7 ASC 

					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
				END FOREACH;
			END IF;
		END IF;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END IF;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angï¿½lica Hï¿½rnandez Pï¿½rez',
'FECHA: 09/08/2016',
'MODULO: Dï¿½BITO',
'FUNCIONALIDAD: MANTENIMIENTOS GAT',
'DESCRIPCION: SPL que realiza la consulta los registros para producto pagare, inversiï¿½n creciente y cuenta ejecutiva jï¿½venes',
'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 30/06/2023',
'DESCRIPCION: Se agregaron nuevas banderas para mostrar los registros de Cuenta Efectiva Digital (2000), Cuenta Efectiva Cheques (1900), Cuenta BÃ¡sica general (1400), Cuenta Clic (2900), Cuenta Platino (2400), Cuenta Efectiva Plus (1800) y Cuenta Efectiva GC (1300)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_calculagat(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5) 		AS codret;

/*=====================================
|     DEFINICIÃN DE VARIABLES         |
=====================================*/
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRet 			CHAR(5);

/*======================================
|     INICIALIZACIÃN DE VARIABLES      |
======================================*/
	LET iSqlErr = 0;
	LET cCodRet = "00000";

    BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_calculagat.out';
		--TRACE ON;

        IF  pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;

        EXECUTE PROCEDURE bdicheq:"informix".sp_calculagat() INTO cCodRet;
        

        IF cCodRet = '-1202' THEN
            LET cCodRet = '00454'; --Probable divisiÃ³n entre 0 en periodos
        END IF;

        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 30/06/2023',
'MODULO: DÃBITO',
'FUNCIONALIDAD: MANTENIMIENTOS GAT',
'DESCRIPCION: SPL que llama al SP calculagat para calcular automaticamente la GAT para las cuentas de captacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_insermedianainflacion(pUsuario CHAR(8), 
													pIdFuncion CHAR(10), 
													pIdConsulta INTEGER, 
													pMedInflacion DECIMAL(9,6), 
													pFechaPublicacion DATETIME YEAR TO FRACTION(3))

RETURNING   CHAR(5)    					 AS codret,
  			DECIMAL(9,6) 				 AS med_inflacion,
    		DATETIME YEAR TO FRACTION(3) AS fecha_publicacion;


/*=====================================
|     DEFINICIÃN DE VARIABLES         |
=====================================*/
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRet 			CHAR(5);
	DEFINE dMedianInflacion DECIMAL(9,6);
	DEFINE dfechaPubli 		DATETIME YEAR TO FRACTION(3);
	DEFINE iregistros 		INTEGER;


/*======================================
|     INICIALIZACIÃN DE VARIABLES      |
======================================*/
	LET iSqlErr = 0;
	LET cCodRet = "00000";

	LET dMedianInflacion = 0.0;
	LET dfechaPubli = "";
	LET iregistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_insermedianainflacion.out';
		--TRACE ON;

		IF  pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END IF;

		IF pIdConsulta = '2' THEN
			IF pMedInflacion IS NULL OR pFechaPublicacion IS NULL OR pMedInflacion = '' OR pFechaPublicacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,dMedianInflacion, dfechaPubli;
			END IF;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet,dMedianInflacion, dfechaPubli;
			END IF;

		/* CONSULTAMOS LA TODAS LAS MEDIANAS DE INFLACIÃN */
		IF pIdConsulta = '1' THEN 
			FOREACH
				SELECT med_inflacion, fecha_publicacion
				INTO dMedianInflacion, dfechaPubli
				FROM bdicheq:sc_medianainflacion 
				ORDER BY 2 DESC
				
				LET iregistros = iregistros + 1;
				RETURN cCodRet,dMedianInflacion, dfechaPubli WITH RESUME;
			END FOREACH;

		/* INSERCIÃN DE UNA NUEVA MEDIANA DE INFLACIÃN*/
		ELIF pIdConsulta = '2' THEN 
			INSERT INTO bdicheq:sc_medianainflacion(med_inflacion, fecha_publicacion) VALUES (pMedInflacion, pFechaPublicacion);
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END IF;	

		IF iregistros = 0 THEN
			LET cCodRet = "00017";
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END IF;
	END;
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 27/06/2023',
'MODULO: DÃBITO',
'FUNCIONALIDAD: MEDIANA INFLACIÃN ',
'DESCRIPCION: SP ENCARGADO DE REALIZAR CONSULTAR TODAS LAS MEDIANAS DE INFLACIÃN EXISTENTES EN LA TABLA bdicheq:sc_medianainflacion (IdConsulta = 1) Ã REALIZAR LA INSERCIÃN DE UNA NUEVA MEDIANA DE INFLACIÃN (IdConsulta = 2)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_grabarcambiostatusolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud1 CHAR(20), pNumSolicitud2 CHAR(20), pNumCliente CHAR(20), pEjecutivoAnaliza CHAR(10), pEjecutivoAutoriza CHAR(10), pStatusInicial CHAR(2), pStatusFinal CHAR(2), pMontoAnterior  DECIMAL(18,2), pMontoNuevo DECIMAL(18,2), pCausa CHAR(3), pComentario CHAR(500), pTipoMovto CHAR(1), pTipoBusqueda CHAR(1), pBanderaMotor CHAR(1))

        RETURNING CHAR(5) AS codret, CHAR(80) AS DESCRIPCION, CHAR(1) AS BANDERAMOTORMC;

        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;
        DEFINE cMensaje CHAR(80);
        DEFINE cEmpresa CHAR(3);
	DEFINE cBanderaMotorMC CHAR(1);
        
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iSqlErr = 0;
        LET cMensaje = '';
        LET cEmpresa = '001';
	LET cBanderaMotorMC = '0';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cMensaje, cBanderaMotorMC;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_grabarcambiostatusolicitudmc.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud1 = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,  cMensaje, cBanderaMotorMC;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,  cMensaje, cBanderaMotorMC;
                END IF;
                
                EXECUTE PROCEDURE bdisolic:'informix'.sp_mc_grabacambiostatus (cEmpresa, pNumSolicitud1, pNumSolicitud2, pNumCliente, pEjecutivoAnaliza, pEjecutivoAutoriza, 
                            pStatusInicial, pStatusFinal, pMontoAnterior, pMontoNuevo, pCausa, UPPER(pComentario), pTipoMovto, pTipoBusqueda, pBanderaMotor) INTO cCodRetSp, cMensaje, cBanderaMotorMC;

                IF cCodRetSp::INTEGER < 0 THEN
                        RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃÂON DEL SP bdisolic:sp_mc_grabacambiostatus';
                ELIF cCodRetSp::INTEGER = 1 THEN
                        LET cCodRet = '00003';
                ELIF cCodRetSp::INTEGER = 2 THEN -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD.
                        LET cCodRet = '00219';
                ELIF cCodRetSp::INTEGER = 3 THEN -- ERROR AL PROCESAR LA SOLICITUD
                        LET cCodRet = '00236';
                END IF;
                
                RETURN cCodRet, cMensaje, cBanderaMotorMC;
        
        END;
                                                
END PROCEDURE

;