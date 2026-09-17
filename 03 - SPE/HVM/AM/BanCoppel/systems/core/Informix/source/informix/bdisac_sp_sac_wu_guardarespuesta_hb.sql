CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_hb
(
 pEmpresa 		CHAR(3),
 pUsuario		CHAR(8), 
 pPartnerId 	CHAR(10), 
 pSystemIp 		CHAR(15), 
 pConnectorId 	CHAR(9), 
 pDeviceId 		CHAR(3),
 pDeviceType 	CHAR(6),
 pFechaHoraRq 	DATETIME YEAR TO SECOND, 
 pRetCode 		CHAR(5),
 pStatusMsj 	CHAR(20),
 pDescError 	CHAR(250),
 pPartnerldErr 	CHAR(10),
 pFechaHoraRP 	DATETIME YEAR TO SECOND,
 pUserInsert 	CHAR(8),
 pFechaInsert 	DATETIME YEAR TO SECOND
)

RETURNING CHAR(5) AS cod_err, CHAR(30) AS error_desc;

--DEFINICION DE VARIABLES--
    DEFINE	iSql_Err		INTEGER;
	DEFINE 	iIsamErr		INTEGER;
    DEFINE	cCodRet			CHAR(5);
	DEFINE	cCodRetAux		CHAR(5);
	DEFINE	cTxnStatus		CHAR(1);
	DEFINE	cNombreSP		CHAR(45);
	DEFINE 	cCadena_ent		CHAR(100);
	DEFINE cError_Desc  	CHAR(30);
	DEFINE cFechaProceso	DATETIME YEAR TO SECOND;
	DEFINE cStatus 			CHAR(1);
	
--INICIALIZACION DE VARIABLES--
    LET	iSql_Err		= 0;
	LET	iIsamErr 		= 0;
    LET cCodRet			= '00000';
	LET cCodRetAux		= '00000';
	LET cTxnStatus		= 'C';
	LET	cNombreSP		= 'sp_sac_wu_guardarespuesta_hb';
	LET cCadena_ent		=  TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pPartnerId,'NULL'))||'|'||TRIM(NVL(pConnectorId,'NULL'));
	LET cError_Desc 	="Error en el proceso";
	LET cFechaProceso	= CURRENT::DATETIME YEAR TO SECOND;
	LET cStatus 		= '2';


BEGIN
	ON EXCEPTION SET iSql_Err, iIsamErr
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
			LET cStatus = '1';

--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
				LET cTxnStatus		 = 'C';
--	2014.11.11 FRG-f

			INSERT INTO bdisac:"informix".sac_wu_heartbeat	 
						(txn_status, partner_id, system_ipadds, connector_id, device_id, device_type, fecha_hora_rq, retcode, status_message, 
						 desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert)
						
				  VALUES(cTxnStatus, pPartnerId, pSystemIp, pConnectorId, pDeviceId, pDeviceType, pFechaHoraRq, pRetCode, pStatusMsj,
				         pDescError, pPartnerldErr, pFechaHoraRP, pUserInsert, current);
					 
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cNombreSP,cCodRet,'',iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso)
			INTO cCodRetAux;
			
			IF cCodRetAux <> '00000' THEN
			   LET cCodRet = cCodRetAux;
		    END IF
			
			RETURN cCodRet,cError_Desc;
        END IF;
		
		
    END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_hb.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	/*	EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
	INTO cCodRetAux;
	
	
	IF cCodRetAux <> '00000' OR pRetCode <> '00000' THEN
		LET	cTxnStatus	= 'C';
		LET cStatus = '1';
		LET cCodret = '00001';
	ELSE
		LET	cTxnStatus	= 'A';
		LET cStatus ='3';
	END IF */

--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
			LET	cTxnStatus	= 'A';
--	2014.11.11 FRG-f
	
	INSERT INTO bdisac:"informix".sac_wu_heartbeat	
						(txn_status, partner_id, system_ipadds, connector_id, device_id, device_type, fecha_hora_rq, retcode, status_message, 
						 desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert)
						
				  VALUES(cTxnStatus, pPartnerId, pSystemIp, pConnectorId, pDeviceId, pDeviceType, pFechaHoraRq, pRetCode, pStatusMsj,
				         pDescError, pPartnerldErr, pFechaHoraRP, pUserInsert, current);
					   
    /*IF  cCodret <> '00000' THEN
	
		--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cNombreSP,cCodret,cError_Desc,iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
        --INTO cCodRetAux;
		IF cCodRetAux <> '00000' THEN
			LET cCodret = cCodRetAux;
		END IF
		  
		RETURN  cCodret, cError_Desc;
	ELSE	
		--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
		--INTO cCodRetAux;	
		
		IF cCodRetAux <> '00000' THEN
			LET cCodret = cCodRetAux;
		END IF
		
		IF cCodRet = '00000' THEN
			LET cError_Desc = "Ejecucion SP exitosa";
		END IF;	
		RETURN  cCodret, cError_Desc;
    END IF;	*/

    IF cCodRet = '00000' THEN
		LET cError_Desc = "Ejecucion SP exitosa";
	END IF;	
	RETURN  cCodret, cError_Desc;

END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje <esp-heartbeat> (request-reply) en la tabla bdisac:sac_wu_heartbeat' ,  
'AUTOR: Christian Echavarria',			
'FECHA: 12/Jul/2013',
' DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',
' MODIFICO : FRG',
' FECHA : 2014/07/30',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sacreporteconciliacionconveniosucursal(cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE)

-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno, --Codigo de Retorno
CHAR(4) AS id_sucursal, INTEGER AS numpagos, CHAR(40) AS nomconvenio, MONEY(16,2) AS importe_pago, MONEY(16,2) AS importe_comision_convenio, MONEY(16,2) AS iva_comision_convenio, MONEY(16,2) AS importe_comision_cte,
MONEY(16,2) AS iva_comision_cte, INTEGER AS flag_confirmacion_central, INTEGER AS flag_confirmacion_sucursal;


-- DEFINICION DE VARIABLES
DEFINE cCodRet                  CHAR(5);
DEFINE iSqlErr                  INTEGER;
DEFINE cNumcategoria            CHAR(2);
DEFINE cIdSucursal              CHAR(4);
DEFINE cNumconvenio             CHAR(3);
DEFINE cNomconvenio             CHAR(40);
DEFINE mImpComisionConvenio    MONEY(16,2);
DEFINE mIVAComisionConvenio    MONEY(16,2);
DEFINE mImpComisionCte         MONEY(16,2);
DEFINE mIVAComisionCte         MONEY(16,2);
DEFINE mImportePago            MONEY(16,2);
DEFINE iConfirmacionCentral     INTEGER;
DEFINE iConfirmacionSucursal    INTEGER;
DEFINE iNumPagos                INTEGER;
DEFINE dFechaTabla			DATE;

--SET DEBUG FILE TO '/informix/adrian/sp_sacreporteconciliacionconveniosucursal_aia.out';
--TRACE ON;

--INICIALIZACION DE VARIABLES--
LET cCodRet               = "00000";
LET cNumcategoria         = SUBSTRING(cConvenio FROM 1 FOR 2);
LET cNumconvenio          = SUBSTRING(cConvenio FROM 3 FOR 3);
LET cIdSucursal           = "";
LET cNomConvenio          = "";
LET mImportePago         = 0;
LET mImpComisionConvenio = 0;
LET mIVAComisionConvenio = 0;
LET mImpComisionCte      = 0;
LET mIVAComisionCte      = 0;
LET iConfirmacionCentral  = 0;
LET iConfirmacionSucursal = 0;
LET iNumPagos             = 0;
LET dFechaTabla			= '';

BEGIN

    ON EXCEPTION SET iSqlErr

        IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
        END IF;

    END EXCEPTION;
	
	SELECT MIN (fecha_pago)
	INTO dFechaTabla
	FROM bdisac:"informix".sac_conciliaciontotalporconvenio;

    IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
    ELSE
		IF (dFechaIni>=dFechaTabla) THEN --Nuevo Proceso utilizando la tabla sac_conciliaciontotalporconvenio
			IF cConvenio = "00000" THEN      -- Todos los convenios
				IF cSucursal = "0000"  THEN   -- Todos los convenios y todas las sucursales
					FOREACH
						SELECT numcategoria, numconvenio 
						INTO cNumcategoria, cNumconvenio
						FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio					
						FOREACH
							SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
							SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
							SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_conciliaciontotalporconvenio
							WHERE fecha_pago::DATE  >= dFechaIni
							AND fecha_pago::DATE  <= dFechaFin
							AND numcategoria = cNumcategoria
							AND numconvenio = cNumconvenio
							GROUP BY nomconvenio, id_sucursal
							ORDER BY 2,1

							RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH;
					END FOREACH;
				ELSE   --Todos los convenios y una sucursal
					FOREACH
						SELECT numcategoria, numconvenio 
						INTO cNumcategoria, cNumconvenio
						FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
						FOREACH
							SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
							SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
							SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_conciliaciontotalporconvenio
							WHERE fecha_pago::DATE  >= dFechaIni
							AND fecha_pago::DATE  <= dFechaFin
							AND id_sucursal = cSucursal
							AND numcategoria = cNumcategoria
							AND numconvenio = cNumconvenio
							GROUP BY nomconvenio, id_sucursal
							ORDER BY 2,1

							RETURN cCodRet, cIdSucursal, iNumPagos,  cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH
					END FOREACH;
				END IF;
			ELSE
				IF cSucursal = "0000"  THEN   -- Un convenio y todas las sucursales
					FOREACH
						SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
						SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
						SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_conciliaciontotalporconvenio
						WHERE fecha_pago::DATE  >= dFechaIni
						AND fecha_pago::DATE  <= dFechaFin
						AND numcategoria = cNumcategoria
						AND numconvenio = cNumconvenio
						GROUP BY nomconvenio, id_sucursal
						ORDER BY 2,1

						RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						WITH RESUME;
					END FOREACH;
				ELSE   --Un convenio y una sucursal
					FOREACH
						SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
						SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
						SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_conciliaciontotalporconvenio
						WHERE fecha_pago::DATE  >= dFechaIni
						AND fecha_pago::DATE  <= dFechaFin
						AND numcategoria = cNumcategoria
						AND numconvenio = cNumconvenio
						AND id_sucursal = cSucursal
						GROUP BY nomconvenio,id_sucursal					
					
					END FOREACH;
					
					RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;

				END IF;

			END IF;
		ELSE --Proceso anterior consultando los movimiento
		
			IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
			ELSE
				IF cConvenio = "00000" THEN      -- Todos los convenios
					IF cSucursal = "0000"  THEN   -- Todos los convenios y todas las sucursales
						FOREACH
							SELECT numcategoria, numconvenio 
							INTO cNumcategoria, cNumconvenio
							FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
							FOREACH
								SELECT TRIM(b.id_sucursal),TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
								SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
								SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
								INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
								WHERE b.fecha_pago::DATE  >= dFechaIni
								AND b.fecha_pago::DATE  <= dFechaFin
								AND a.numcategoria = b.numcategoria
								AND a.numconvenio = b.numconvenio
								AND b.numcategoria = cNumcategoria
								AND b.numconvenio = cNumconvenio
								AND b.status_cancelado <> 'S'
								AND flag_confirmacion_central = 1
								AND flag_confirmacion_sucursal = 1
								GROUP BY a.nomconvenio, b.id_sucursal
								ORDER BY 2,1

								RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								WITH RESUME;

							END FOREACH;
						END FOREACH;
					ELSE   --Todos los convenios y una sucursal
						FOREACH
							SELECT numcategoria, numconvenio 
							INTO cNumcategoria, cNumconvenio
							FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
							FOREACH
								SELECT TRIM(b.id_sucursal)AS id_sucursal, TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
								SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
								SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
								INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
								WHERE b.fecha_pago::DATE  >= dFechaIni
								AND b.fecha_pago::DATE  <= dFechaFin
								AND a.numcategoria = b.numcategoria
								AND a.numconvenio = b.numconvenio
								AND b.numcategoria = cNumcategoria
								AND b.numconvenio = cNumconvenio
								AND b.id_sucursal = cSucursal
								AND b.status_cancelado <> 'S'
								AND flag_confirmacion_central = 1
								AND flag_confirmacion_sucursal = 1
								GROUP BY a.nomconvenio, b.id_sucursal
								ORDER BY 2, 1

								RETURN cCodRet, cIdSucursal, iNumPagos,  cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								WITH RESUME;
							END FOREACH
						END FOREACH;
					END IF;
				ELSE
					IF cSucursal = "0000"  THEN   -- Un convenio y todas las sucursales
						FOREACH
							SELECT TRIM(b.id_sucursal), TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
							SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
							SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
							WHERE b.fecha_pago::DATE  >= dFechaIni
							AND b.fecha_pago::DATE  <= dFechaFin
							AND b.numcategoria = cNumcategoria
							AND b.numconvenio = cNumconvenio
							AND b.status_cancelado <> 'S'
							AND a.numcategoria = b.numcategoria
							AND a.numconvenio = b.numconvenio
							AND flag_confirmacion_central = 1
							AND flag_confirmacion_sucursal = 1
							GROUP BY a.nomconvenio, b.id_sucursal
							ORDER BY 2, 1

							RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH;
					ELSE   --Un convenio y una sucursal
						SELECT TRIM(b.id_sucursal), TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
						SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
						SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio , iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
						WHERE b.fecha_pago::DATE  >= dFechaIni
						AND b.fecha_pago::DATE  <= dFechaFin
						AND b.numcategoria = cNumcategoria
						AND b.numconvenio = cNumconvenio
						AND b.status_cancelado <> 'S'
						AND a.numcategoria = b.numcategoria
						AND a.numconvenio = b.numconvenio
						AND b.id_sucursal = cSucursal
						AND flag_confirmacion_central = 1
						AND flag_confirmacion_sucursal = 1
						GROUP BY a.nomconvenio, b.id_sucursal;

						RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;

					END IF;

				END IF;

			END IF;
		
		END IF;

    END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener los totales captados por convenio en un rango de fechas especificas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080905',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_search
(
pEmpresa				CHAR(3), 
pUsuario				CHAR(8),
pMarca					CHAR(2),
pForeignRsRefNumRq    	CHAR(16),
pMtcn              	    CHAR(10),
pFechaHoraRq       	    DATETIME YEAR TO SECOND,
pRetCode         		CHAR(5),
pEmisorNameType     	CHAR(1),
pEmisorNombre1          CHAR(40),
pEmisorNombre2          CHAR(40),
pEmisorApPaterno    	CHAR(40),
pEmisorApMaterno    	CHAR(40),
pEmisorCiudad       	CHAR(20),
pEmisorEdo          	CHAR(40),
pEmisorCodPais      	CHAR(3),
pEmisorCodMoneda    	CHAR(3),
pEmisorCp           	CHAR(8), 
pEmisorCalle        	CHAR(30), 
pEmisorTel          	CHAR(15), 
pBenefNameType 			CHAR(1),
pBenefNombre1           CHAR(40),
pBenefNombre2           CHAR(40),
pBenefApaterno      	CHAR(40), 
pBenefAmaterno      	CHAR(40),
pBenefCiudad        	CHAR(20), 
pBenefEdo           	CHAR(40), 
pBenefCodPais       	CHAR(3),
pBenefCodMoneda     	CHAR(3), 
pBenefCp            	CHAR(8), 
pBenefCalle         	CHAR(30), 
pBenefTelPart       	CHAR(15),
pBenefTelCel       		CHAR(10), 
pMontoTotalOrigen  		CHAR(10),
pMontoToTDestino    	CHAR(10),
pMontoOrigen        	CHAR(10),
pMontoCargos        	CHAR(10), 
pCdOrigenPago       	CHAR(30), 
pTipoCambio         	CHAR(10),
pFechaAltaRemesa    	CHAR(8),
pHoraAltaRemesa     	CHAR(16), 
pMoneyTransKey      	CHAR(10),
pEstatusRemesa      	CHAR(4), 
pNewMtcn            	CHAR(16),
pFusionStatus       	CHAR(4),
pNoPaginas          	CHAR(2),
pPaginaActual       	CHAR(2), 
pNumCoincidencias   	CHAR(2), 
pForeignRsSystemIdRp  	CHAR(11), 
pForeignRsRefNumRp      CHAR(16), 
pForeingRsCantIdRp      CHAR(11),
pDescError              CHAR(250),
pPartnerIdErr           CHAR(10), 
pFechaHoraRp            DATETIME YEAR TO SECOND, 
pUserInsert             CHAR(8), 
pFechaInsert            DATETIME YEAR TO SECOND
)

RETURNING CHAR(5) AS cod_err, CHAR(30) AS error_desc;

--DEFINICION DE VARIABLES--
    DEFINE	iSql_Err		INTEGER;
	DEFINE 	iIsamErr		INTEGER;
    DEFINE	cCodRet			CHAR(5);
	DEFINE  cRetCode		CHAR(5);
	DEFINE  cDesc_Error		CHAR(250);
	DEFINE	cCodRetAux		CHAR(5);
	DEFINE	cTxnStatus		CHAR(1);
	DEFINE	cNombreSP		CHAR(45);
	DEFINE 	cCadena_ent		CHAR(100);
	DEFINE cError_Desc  	CHAR(30);
	DEFINE cChannelType 	CHAR(3);
    DEFINE cChannelName 	CHAR(3); 
    DEFINE cChannelVersion	CHAR(4);  
    DEFINE cForeignSystemId	CHAR(11); 
	DEFINE cForeignRsCntRq  CHAR(11);
	DEFINE cFechaProceso    DATETIME YEAR TO SECOND;
	DEFINE cStatus			CHAR(1);
	DEFINE cNumconvenio		CHAR(3);
	DEFINE cSucursal		CHAR(4);
	
--INICIALIZACION DE VARIABLES--
    LET	iSql_Err		 = 0;
	LET	iIsamErr 		 = 0;
    LET cCodRet			 = '00000';
	LET cRetCode		 = '00000';
	LET cDesc_Error		 = "";
	LET cCodRetAux		 = '00000';
	LET cTxnStatus		 = 'C';
	LET	cNombreSP		 = 'sp_sac_wu_guardarespuesta_search';
	LET cCadena_ent		 =  TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pForeignRsSystemIdRp,'NULL'))||'|'||TRIM(NVL(pMtcn,'NULL'));
	LET cError_Desc	     = "Error en el proceso";
	LET cChannelType 	 ="";	
    LET cChannelName 	 ="";	 
    LET cChannelVersion	 ="";  
    LET cForeignSystemId =""; 
	LET cForeignRsCntRq  ="" ;
	LET cFechaProceso	 = CURRENT::DATETIME YEAR TO SECOND;
	LET cStatus		     ="";
	LET cNumconvenio     ="";
	LET cSucursal 			="";
	
--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_search.out';
--	TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
BEGIN
	ON EXCEPTION SET iSql_Err, iIsamErr
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
			
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
				INTO cCodRetAux;
				
				IF cCodRetAux <> '00000' THEN
			       LET cCodRet = cCodRetAux;
		        END IF
--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
				LET cTxnStatus		 = 'C';
--	2014.11.11 FRG-f

					INSERT INTO bdisac:"informix".sac_wu_search	 
							(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,mtcn,fecha_hora_rq,
							 retcode,emisor_nametype,emisor_nombre1,emisor_nombre2,emisor_appaterno,emisor_apmaterno,emisor_ciudad,emisor_edo,emisor_cod_pais,
							 emisor_cod_moneda,emisor_cp,emisor_calle,emisor_telefono,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,
							 benef_ciudad,benef_edo,benef_cod_pais,benef_cod_moneda,benef_cp,benef_calle,benef_tel_part,benef_tel_celular,monto_total_origen,
							 monto_total_destino,monto_origen,monto_cargos,cd_origen_pago,tipo_cambio,fecha_alta_remesa,hora_alta_remesa,money_transfer_key,
							 estatus_remesa,new_mtcn,fusion_status,no_paginas,pagina_actual,num_coincidencias,foreign_rs_system_id_rp,foreign_rs_refnum_rp,
							 foreign_rs_cntid_rp,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert)
							
					  VALUES(cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignSystemId,pForeignRsRefNumRq,cForeignRsCntRq,pMtcn,pFechaHoraRq,pRetCode,pEmisorNameType,
							 pEmisorNombre1,pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,
							 pEmisorTel,pBenefNameType,pBenefNombre1,pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,
							 pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,
							 pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,pNumCoincidencias,
							 pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,pFechaHoraRp,pUserInsert,current);
				
				RETURN cCodRet,cError_Desc;
        END IF;
		
    END EXCEPTION;

	/*	
	--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (2,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso)  
	--INTO cCodRetAux;
	
	IF cCodRetAux <> '00000' OR pRetCode <> '00000' THEN
		LET	cTxnStatus	= 'C';		
		LET cCodRet = '00001';
	ELSE
		LET	cTxnStatus	= 'A';
	END IF
	*/
	IF pRetCode = '504' THEN
	    LET cRetCode = '99999';
		LET pDescError = 'Aplicativo WU no activo, validar';
	END  IF;
	
	IF pRetCode <>  '504' AND pRetCode <> '00000' AND pRetCode <> '66666'  THEN		
		LET cRetCode = '99998';
		LET pDescError = 'Sin respuesta del aplicativo, validar';
	END IF
	IF pRetCode = '66666' THEN
		LET cDesc_Error = pDescError;
		LET cRetCode = pRetCode;
	END IF
	
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
		IF (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87054') = pMarca
		OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87055') = pMarca
		OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87056') = pMarca THEN
				IF pUsuario = "sys_wu" THEN
					LET cSucursal = '9250';
				ELSE
					SELECT sucursal
					INTO cSucursal
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
				END IF;
				IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN
					SELECT fsid ,counter_id
					INTO cForeignSystemId ,cForeignRsCntRq
					FROM bdisac:"informix".sac_wu_identificadores
					WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = cSucursal;

					IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
						LET cCodRet = '00027';
						LET cError_Desc	= 'Usuario no tiene Id. Asignado';						
					END IF;
				ELSE
					LET	cCodRet = '00026'; --- Usuario no se encuentra
					LET cError_Desc	= 'NO EXISTE USUARIO';
			   END IF;
		ELSE
			LET	cCodRet = '00003'; --- Marca Inválida
			LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';			
		END IF;
  
			SELECT valor
			INTO cChannelType
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87050';  
			 
			SELECT valor
			INTO cChannelName
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87051'; 
			 
			SELECT valor
			INTO cChannelVersion
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87052'; 
																		
--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
			LET	cTxnStatus	= 'A';
--	2014.11.11 FRG-f

	INSERT INTO bdisac:"informix".sac_wu_search	
						(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,mtcn,fecha_hora_rq,
						 retcode,emisor_nametype,emisor_nombre1,emisor_nombre2,emisor_appaterno,emisor_apmaterno,emisor_ciudad,emisor_edo,emisor_cod_pais,
						 emisor_cod_moneda,emisor_cp,emisor_calle,emisor_telefono,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,
						 benef_ciudad,benef_edo,benef_cod_pais,benef_cod_moneda,benef_cp,benef_calle,benef_tel_part,benef_tel_celular,monto_total_origen,
						 monto_total_destino,monto_origen,monto_cargos,cd_origen_pago,tipo_cambio,fecha_alta_remesa,hora_alta_remesa,money_transfer_key,
						 estatus_remesa,new_mtcn,fusion_status,no_paginas,pagina_actual,num_coincidencias,foreign_rs_system_id_rp,foreign_rs_refnum_rp,
						 foreign_rs_cntid_rp,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert)
						
				  VALUES(cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignSystemId,pForeignRsRefNumRq,cForeignRsCntRq,pMtcn,pFechaHoraRq,cRetCode,pEmisorNameType,
				         pEmisorNombre1,pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,
                         pEmisorTel,pBenefNameType,pBenefNombre1,pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,
						 pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,
						 pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,pNumCoincidencias,
						 pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,pFechaHoraRp,pUserInsert,current);
						 
		SELECT status_cancelado 
		INTO cStatus 
		FROM bdisac:sac_movimientos 
		WHERE numcategoria = '07' AND numconvenio = cNumconvenio 
		AND referencia1 = pMtcn
		AND flag_confirmacion_sucursal = '0'
		AND status_cancelado = 'N' ;

		IF cStatus ='N' AND pFusionStatus = 'W/C' THEN -- Si encontró un intento de pago previo y no ha sido reversado			   
			   LET cCodRet = '00023'; -- Se tiene que reversar primero antes de intentar el pago nuevamente
		END IF;

		IF  cCodRet <> '00000' THEN	
		    --EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,cDesc_Error,iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
		    --INTO cCodRetAux;
			
			IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
				RETURN cCodRet,cError_Desc;	
			END IF;
            
			
/*			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
*/
			IF cCodRet <>  '00023'  THEN		
				LET cCodRet = '00001';
			END IF;
            RETURN cCodRet,cError_Desc;		
	    ELSE	
/*
		    --EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (3,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
	        --INTO cCodRetAux;	
			
			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF;
*/		
			IF cCodRet = '00000' THEN
				LET cError_Desc = "Ejecucion SP exitosa";
			END IF;	
			
           RETURN cCodRet,cError_Desc;
	    END IF;	
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje <receive-money-search> (request-reply) en la tabla bdisac:sac_wu_search',  
'AUTOR: Christian Echavarria',			
'FECHA: 15/Jul/2013',
'DESCRIPCION: Se modifica para que consulte los campos counter_id y  fsid de sac_wu_identificadores',  
'AUTOR: Mario Gallardo',			
'FECHA: 03/10/2013',
'DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
'AUTOR: FRG',
'FECHA: 30/Jul/2014',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_bts_recuperacdep_pba(pcUsuario CHAR(8), piRegs_recup INTEGER, pcFecha_peticion CHAR(8), pcHora_peticion CHAR(6))
	RETURNING CHAR(5),CHAR(11),CHAR(4),CHAR(8),CHAR(6);

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(4);
DEFINE cConfirmation_nm CHAR(11);
DEFINE cOpcode_cdep 	CHAR(4);
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE cNombre_preceso	CHAR(19);
DEFINE cCadena_ent		CHAR(100);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE cCod_retorno		CHAR(5);

DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;
DEFINE cValor			CHAR(100);

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err = '0000';
LET cConfirmation_nm = '';
LET cOpcode_cdep = '0000';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cNombre_preceso = 'sp_bts_recuperacdep';
LET cCadena_ent = 	NVL(piRegs_recup,0) || '|' || TRIM(NVL(pcFecha_peticion,'NULL')) || '|' || TRIM(NVL(pcHora_peticion,'NULL'));
LET cOpcode 		= '';
LET cDescr_mensaje 	= '';
LET cCod_retorno 	= '';
LET cValor	 		= '';

LET cFecha_dia = '';
LET dtFecha_dia = CURRENT::DATE;

--SET DEBUG FILE TO '/tmp/RMBTS/sp_bts_recuperacdep.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError
		IF iSqlErr <> 0 THEN
			LET cCod_err = iSqlErr;			
			LET cDescr_mensaje = '';
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
			INTO cCod_retorno;
			
			RETURN cCod_err,cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Se inserta el registro del proceso en curso
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombre_preceso,pcFecha_peticion,pcHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);
	
	IF piRegs_recup > 0 THEN

		SELECT NVL(valor,'0')
			INTO cValor
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87013';	
			
			FOREACH
				SELECT LIMIT piRegs_recup num_confirmacion
					INTO cConfirmation_nm
					FROM bdisac:"informix".sac_bts_sdep 
					WHERE estatus_sdep = '01'					
--					WHERE estatus_sdep = 'XX'										
						AND intentos_envio <= cValor
				
				RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso WITH RESUME;
			END FOREACH;
			
			 IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_err = '9984';

					--Se obtienen los mensajes de error asi como el codigo del mensaje
				SELECT NVL(opcode, ''),NVL(opcode_sd, '')
					INTO cOpcode,cDescr_mensaje 
					FROM bdisac:"informix".sac_bts_catmensajes WHERE agent_trans_type_code = 'CDEP' AND opcode = cCod_err;
					
				--En caso de que no exista el codigo del mensaje se les asigna otros valores
				IF cOpcode IS NULL THEN			
					LET cDescr_mensaje = 'Código no registrado en catálogo.';			
				END IF;

				-- En caso de que existan registros que fueron bloqueados temporalmente estatus_sdep='08', se regresan a '01'
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET estatus_sdep = '01'
				WHERE estatus_sdep = '08';							
					
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
					INTO cCod_retorno;

				RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)		
			INTO cCod_retorno;
			
/*		ELSE
			LET cCod_err = '9986';
		END IF;*/
	ELSE
		LET cCod_err = '9001';
	END IF;
	
	IF cCod_err <> '0000' THEN		
		
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, '')
		INTO cOpcode,cDescr_mensaje 
		FROM bdisac:"informix".sac_bts_catmensajes WHERE agent_trans_type_code = 'CDEP' AND opcode = cCod_err;
	
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN			
			LET cDescr_mensaje = 'Código no registrado en catálogo.';			
		END IF;
		
		--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)		
		INTO cCod_retorno;		
		
		RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
	END IF;		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Regresa un numero determinado de registros guadado0s de forma exitosa',
'AUTOR : José Luís Polanco B.',
'FECHA : 05 de Noviembre de 2012',
'VERSION: 1.0',
'BD: BDISAC',
'SISTEMA : Sistema Administrador de Convenios';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_pay 
(
	pEmpresa			CHAR(3), 
	pMarca              CHAR(2),
	pUsuario			CHAR(8),  
	pBenefNameType 		CHAR(1), 
	pBenefNombreUno		CHAR(40), 
	pBenefNombreDos		CHAR(40), 
	pBenefApaterno		CHAR(40), 
	pBenefAmaterno		CHAR(40), 
	pBenefCiudad 		CHAR(24),-- se adapta a la longitud del campo benef_ciudad  
	pBenefEdo  			CHAR(40), 
	pBeneCP				CHAR(9),-- se adapta a la longitud del campo benef_cp
	pBenefIdType  		CHAR(1), 
	pBenefIdPaisExpedi	CHAR(45), 
	pBenefIdNumber  	CHAR(20), 
	pBenefTieneFechVenc	CHAR(1), 
	pBenefFechaVenc  	CHAR(8),
	pBenefFechNac  		CHAR(8), 
	pBenefOcupacion  	CHAR(30), 
	pBenefCalleNum  	CHAR(40), 
	pBenefColDelMun  	CHAR(40), 
	pBenefPais  		CHAR(45), 
	pBenefTelPart 		CHAR(20), -- se adapta a la longitud del campo benef_tel_particular 
	pBenefTelCel  		CHAR(20), -- se adapta a la longitud del campo benef_tel_celular 
	pBenefEmail  		CHAR(40), 
	pBenefPaisNac  		CHAR(2), 
	pBenefNacionalidad 	CHAR(15), 
	pBenefSexo  		CHAR(1), 
	pBenefCiudadNac		CHAR(20), 
	pBenefEdoNac		CHAR(20), 
	pBenefCodPais		CHAR(3), 
	pBenefCodMoneda		CHAR(3), 
	pMontoOrigen		CHAR(10), 
	pMontoDestino		CHAR(10), 
	pMoneyTransferKey	CHAR(10), 
	pNewMtcn			CHAR(16), 
	pMtcn				CHAR(10), 
	pConfPago			CHAR(1), 
	pForeignRefNumRq	CHAR(16), 
	pFechaHrRq			DATETIME YEAR TO SECOND, 
	pRetCode			CHAR(5), 
	pDatosBufer			CHAR(500), 
	pMtcnRp				CHAR(10), 
	pPuntosGanados		CHAR(4), 
	pWuFechaPago		CHAR(16), 
	pForeignSystemIdRp	CHAR(11), 
	pForeingRefNumRp	CHAR(16), 
	pForeignRsCantIdRp	CHAR(11), 
	pDesError			CHAR(250), 
	pPartnerIdErr		CHAR(10), 
	pFechaHoraRp		DATETIME YEAR TO SECOND, 
	pUserInsert			CHAR(8), 
	pFechaInsert		DATETIME YEAR TO SECOND
)

RETURNING  CHAR(5) AS cod_err, CHAR(30) AS error_desc;

	--DEFINICION DE VARIABLES--
    DEFINE	iSqlErr				INTEGER;
	DEFINE 	iIsamErr			INTEGER;
    DEFINE	cCodRet				CHAR(5);
	DEFINE  cRetCode			CHAR(5);
	DEFINE  cDesc_Error         CHAR(250);
	DEFINE	cCodRetAux			CHAR(5);
	DEFINE	cTxnStatus			CHAR(1);
	DEFINE	cNombreSP			CHAR(45);
	DEFINE 	cCadena_ent			CHAR(100);
	DEFINE cError_Desc  		CHAR(30);
	DEFINE cFechaProceso    	DATETIME YEAR TO SECOND;
	DEFINE cChannelType 		CHAR(3);
    DEFINE cChannelName 		CHAR(3); 
    DEFINE cChannelVersion		CHAR(4);
	DEFINE cForeignSystemId		CHAR(11); 
	DEFINE cForeignRsCntRq  	CHAR(11);
	DEFINE cTemplateId          CHAR(10);
	DEFINE cSucursal		CHAR(4);
	
	--INICIALIZACION DE VARIABLES--
    LET	iSqlErr				= 0;
	LET	iIsamErr 			= 0;
    LET cCodRet				= '00000';
	LET cRetCode			= '00000';
	LET cDesc_Error			= "";
	LET cCodRetAux			= '00000';
	LET cTxnStatus			= 'C';
	LET	cNombreSP			= 'sp_sac_wu_guardarespuesta_pay';
	LET cCadena_ent			= TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pMoneyTransferKey,'NULL'))||'|'||TRIM(NVL(pNewMtcn,'NULL'));
    LET cError_Desc 		= "Error en el proceso";
	LET cFechaProceso		=  CURRENT::DATETIME YEAR TO SECOND;
	LET cChannelType 	 	= "";	
    LET cChannelName 	 	= "";	 
    LET cChannelVersion	 	= "";
	LET cForeignSystemId 	= ""; 
	LET cForeignRsCntRq  	= "" ;
	LET cTemplateId			= "";
	LET cSucursal 			= "";

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;

			EXECUTE PROCEDURE "informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSqlErr,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
			INTO cCodRetAux;

			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
			--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
				LET cTxnStatus		 = 'C';
			--	2014.11.11 FRG-f

			INSERT INTO "informix".sac_wu_pay
					(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1,    benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type, benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago, foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp, puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert)
			
			VALUES
					(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun, pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac,  pBenefNacionalidad, pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey, pNewMtcn, pMtcn, pConfPago, cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, pRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago,pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp, pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current);

			RETURN cCodRet, cError_Desc;
		END IF;

	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_pay.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF pRetCode = '504' THEN
	    LET cRetCode = '99999';
		LET pDesError = 'Aplicativo WU no activo, validar';
		
	END  IF;

	IF pRetCode <>  '504' AND pRetCode <> '00000' AND pRetCode <> '66666' THEN		
        IF pRetCode <> '20001' then
            LET cRetCode = '99998';
            LET pDesError = 'Sin respuesta del aplicativo, validar';
        ELIF pRetCode = '20001' then
            LET cRetCode = '20001';
            LET pDesError = 'Caracter invalido en la cadena';
        END IF;
	END IF;

	IF pRetCode = '66666' THEN
		LET cDesc_Error = pDesError;
		LET cRetCode = pRetCode;
	END IF
	
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
		IF (SELECT valor FROM "informix".sac_param WHERE cod_param ='87054') = pMarca
		OR (SELECT valor FROM "informix".sac_param WHERE cod_param ='87055') = pMarca
		OR (SELECT valor FROM "informix".sac_param WHERE cod_param ='87056') = pMarca THEN
			IF pUsuario = "sys_wu" THEN
				LET cSucursal = '9250';
			ELSE
				SELECT sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
			END IF;
			IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN
			
				SELECT fsid ,counter_id
				INTO cForeignSystemId ,cForeignRsCntRq
				FROM "informix".sac_wu_identificadores
				WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = cSucursal;

				IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
					LET cCodRet = '00027';
					LET cError_Desc	= 'Usuario no tiene Id. Asignado';
				END IF;
			ELSE
				LET	cCodRet = '00026'; --- Usuario no se encuentra
				LET cError_Desc	= 'NO EXISTE USUARIO';
		   END IF;
		ELSE
			LET	cCodRet = '00003'; --- Marca Inválida
			LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';
		END IF;
		
		SELECT valor
		INTO cChannelType
		FROM "informix".sac_param 
		WHERE cod_param = '87050';  
		 
		SELECT valor
		INTO cChannelName
		FROM "informix".sac_param 
		WHERE cod_param = '87051'; 
		 
		SELECT valor
		INTO cChannelVersion
		FROM "informix".sac_param 
		WHERE cod_param = '87052'; 
		
		SELECT valor
		INTO cTemplateId
		FROM "informix".sac_param 
		WHERE cod_param = '87063';

		--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
			LET	cTxnStatus	= 'A';
		--	2014.11.11 FRG-f
	
		INSERT INTO "informix".sac_wu_pay	
				(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1, benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type,benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago,foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp,puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err,fecha_hora_rp, user_insert, fecha_insert)
						
		VALUES
				(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun,pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac, pBenefNacionalidad,pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey,pNewMtcn, pMtcn, pConfPago,cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, cRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago, pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp,pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current);
					   
		IF  cCodRet <> '00000' THEN
			
			IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
				RETURN cCodRet,cError_Desc;	
			END IF;
		  
            RETURN cCodRet,cError_Desc;		
	    ELSE	
			
			IF cCodRet = '00000' THEN
				LET cError_Desc = "Ejecucion SP exitosa";
			END IF;	
			
           RETURN cCodRet,cError_Desc;
	    END IF;	
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje  <receive-money-pay> (request-reply) en la tabla bdisac:sac_wu_pay',  
'AUTOR: Christian Echavarria',			
'FECHA: 17/Jul/2013',
'DESCRIPCION: Se modifica para que consulte los campos counter_id y  fsid de sac_wu_identificadores',  
'AUTOR: Mario Gallardo',			
'FECHA: 03/10/2013',
'DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
'AUTOR: FRG',
'FECHA: 30/Jul/2014',
'BD: bdisac',
'AUTOR: Mario Olivo',
'Empleado: 95358919',
'Folio: 1457',
'Centro: 230202',
'Descripcion: Se aumenta la longitud del parametro pBenefPais por que se aumento la longitud en la tabla sac_wu_pay para',
'			  guardar el nombre completo del pais.',
'Fecha:10/SEP/2014',
'Version: 20140910.1627',
'AUTOR: Pedro Jimenez',
'Empleado: 95689966',
'Folio: 1485',
'Centro: 230202',
'Descripcion: Se aumenta la longitud de los parametro pBenefCiudad,pBeneCP,pBenefTelPart,pBenefTelCel  por que se aumento la longitud en la tabla sac_wu_pay',
'Fecha:26/02/2015',
'Version: 20150226.1651';

CREATE PROCEDURE "informix".sp_dinya_calcularcomisioniva_bei (pCategoria CHAR(2), pConvenio CHAR(3), pMonto MONEY)
	RETURNING  CHAR(5) ,MONEY, MONEY ,MONEY, CHAR(1), MONEY;

	DEFINE cCodRet 				CHAR(5);
	DEFINE mMontoMax			MONEY;
	DEFINE mMontoMin			MONEY;
	DEFINE mIva					MONEY;
	DEFINE mComision			MONEY;
	DEFINE mTotIvaComision		MONEY;
	DEFINE cTipo				CHAR(1);
	DEFINE iSqlErr				INTEGER;
	DEFINE isam_error			INTEGER;
	
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_dinya_calcularcomisioniva_bei.out";
	--TRACE ON;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr,isam_error
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
			END IF;
		END EXCEPTION;

		LET cCodRet 				= '00000';
		LET mMontoMax				= '0.00';
		LET mMontoMin				= '0.00';
		LET mIva					= 0;
		LET mComision				= '0.00';
		LET mTotIvaComision			= '0.00';
		LET cTipo					= '';
		LET iSqlErr					= 0;
		LET isam_error				= 0;


		IF pCategoria IS NULL OR pConvenio IS NULL THEN
			LET cCodRet = '00001';
			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF;
		
		IF  pMonto = 0.0 THEN
		
			FOREACH
				SELECT montomaximo, iva_comcte, comision_cte, tipo 
				INTO mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal 
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio and cve_canal = '15'
				
				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;
				
				
				IF cTipo = 1 THEN
					LET mComision = mComision;
				END IF;
				
				LET mIva = mIva/100;
				
				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;
				
			END FOREACH;
		
		ELSE 
			
			FOREACH
				SELECT montominimo, montomaximo, iva_comcte, comision_cte, tipo 
				INTO mMontoMin, mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal 
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio and cve_canal = '15'
				
				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					--RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;
				
				IF pMonto <= mMontoMax AND pMonto >= mMontoMin THEN
					
					IF cTipo = 1 THEN
						LET mComision = mComision;
					END IF;
					
					LET mIva = mComision * (mIva/100);
					LET mTotIvaComision = mIva + mComision;
				
					EXIT FOREACH;
					--RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;
					
				END IF;
				
			END FOREACH;
			
			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF ;
	END
END PROCEDURE
Document
'DESCRIPCION: Calcula el IVA y Comision de un importe y regresa las comisiones para Ordenes de Pago para EmpresaNEt', 
'AUTOR: Bibiana Gaxiola',
'FECHA: 03/03/2015',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_dinya_calcularcomisioniva_bpi (pCategoria CHAR(2), pConvenio CHAR(3), pMonto MONEY)
	RETURNING  CHAR(5) ,MONEY, MONEY ,MONEY, CHAR(1), MONEY;
	DEFINE cCodRet 				CHAR(5);
	DEFINE mMontoMax			MONEY;
	DEFINE mMontoMin			MONEY;
	DEFINE mIva					MONEY;
	DEFINE mComision			MONEY;
	DEFINE mTotIvaComision		MONEY;
	DEFINE cTipo				CHAR(1);
	DEFINE iSqlErr				INTEGER;
	DEFINE isam_error			INTEGER;


	--SET DEBUG FILE TO "/home/sysifx/ilse/sp_dinya_calcularcomisioniva_bpi.out";
	--TRACE ON;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	BEGIN
		ON EXCEPTION SET iSqlErr,isam_error
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
			END IF;
		END EXCEPTION;
		LET cCodRet 				= '00000';
		LET mMontoMax				= '0.00';
		LET mMontoMin				= '0.00';
		LET mIva					= 0;
		LET mComision				= '0.00';
		LET mTotIvaComision			= '0.00';
		LET cTipo					= '';
		LET iSqlErr					= 0;
		LET isam_error				= 0;
		IF pCategoria IS NULL OR pConvenio IS NULL THEN
			LET cCodRet = '00001';
			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF;

		IF  pMonto = 0.0 THEN

			FOREACH
				SELECT montomaximo, iva_comcte, comision_cte, tipo
				INTO mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio and cve_canal = '3'

				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;


				IF cTipo = 1 THEN
					LET mComision = mComision;
				END IF;

				-- COMISION CON %
				IF cTipo = 2 THEN
					LET mComision = mComision/100;
				END IF;

				LET mIva = mIva/100;

				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;

			END FOREACH;

		ELSE

			FOREACH
				SELECT montominimo, montomaximo, iva_comcte, comision_cte, tipo
				INTO mMontoMin, mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio

				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					--RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;

				IF pMonto <= mMontoMax AND pMonto >= mMontoMin THEN

					IF cTipo = 1 THEN
						LET mComision = mComision;
					END IF;

					-- COMISION EN %
					IF cTipo = 2 THEN
						LET mComision = pMonto * (mComision/100);

					END IF;
					LET mIva = mComision * (mIva/100);
					LET mTotIvaComision = mIva + mComision;

					EXIT FOREACH;
					--RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;

				END IF;

			END FOREACH;

			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF ;
	END
END PROCEDURE
Document
'DESCRIPCION: Calcula el IVA y Comision de un importe y regresa las comisiones para Ordenes de Pago',
'AUTOR: Ilse Gómez',
'FECHA: 15 de enero de 2015',
'VERSION: 20141216.0900',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_dinya_insertaenvios3 
	(mMontoEnvio MONEY(16,2),
	pMontoCargo MONEY(16,2),
	pCuentaCargo CHAR(20),
	pSucursal CHAR(4),
	cEjecutivo CHAR(8),
	pFolioSuc CHAR(16))

	RETURNING  CHAR(5), CHAR(16);

	DEFINE cCodRet 			 		CHAR(5);
	DEFINE iSqlErr			 		INTEGER;
	DEFINE cCuentaPrestadora 		CHAR(20);
	DEFINE cTransaccAbonoEnvio		CHAR(4);
	DEFINE cTransaccAbonoIva		CHAR(4);
	DEFINE cTransaccAbonoComision	CHAR(4);
	DEFINE mTotComision				MONEY (16,2);
	DEFINE mTotIVA					MONEY (16,2);
	DEFINE mTotIvaComision			MONEY (16,2);
	DEFINE pImporte					MONEY (16,2);
	DEFINE mTotalaCobrar			MONEY (16,2);
	DEFINE cTransaccSuc				CHAR(4);
	DEFINE cTransaccCargoEnvio 		CHAR(4);
	DEFINE ctranret					CHAR(4);
	DEFINE dfechoy					DATE;
	DEFINE msdodisp					MONEY (14,2);
	DEFINE mmontoret				MONEY (14,2);
	DEFINE dFecha_hoy				DATE;
	DEFINE isam_error				INTEGER;
	DEFINE cDescripcion				CHAR(200);
	DEFINE cTransaccCargoiva		CHAR(4);
	DEFINE cTransaccCargocomi		CHAR(4);
	DEFINE cTransaccCargocomiCte	CHAR(4);
	DEFINE cTransaccCargoivaCte		CHAR(4);

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (iSqlErr,isam_error,cDescripcion,'sp_dinya_insertaenvios3',dFecha_hoy,CURRENT );
				RETURN cCodRet, pFolioSuc;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/informix/bibiana/sp_dinya_InsertaEnvios3.out";
		--TRACE ON;

		LET cCodRet 			   = '00000';
		LET iSqlErr			 	   = 0;
		LET cCuentaPrestadora 	   = '';
		LET cTransaccAbonoEnvio	   = '';
		LET cTransaccAbonoIva	   = '';
		LET cTransaccAbonoComision = '';
		LET mTotComision		   = '';
		LET mTotIVA				   = '';
		LET mTotIvaComision 	   = '';
		LET pImporte			   = '';
		LET mTotalaCobrar		   = '';	
		LET cTransaccSuc		   = '';
		LET cTransaccCargoEnvio	   = '';
		LET ctranret			   = '';
		LET dfechoy				   = '';
		LET msdodisp			   = '';
		LET mmontoret			   = '';
		LET dFecha_hoy			   = '';
		LET isam_error			   = '';
		LET cDescripcion		   = '';
		LET cTransaccCargoiva	='';
		LET cTransaccCargocomi	='';
		LET cTransaccCargocomiCte	='';
		LET cTransaccCargoivaCte		='';

		--Obtiene parametros
		SELECT valor INTO cCuentaPrestadora
		FROM Bdisac:sac_param
		WHERE cod_param='75';

		SELECT valor INTO cTransaccAbonoEnvio
		FROM Bdisac:sac_param
		WHERE cod_param='5070012';

		SELECT valor INTO cTransaccCargoEnvio
		FROM Bdisac:sac_param
		WHERE cod_param='414070021';

		SELECT valor INTO cTransaccAbonoComision
		FROM Bdisac:sac_param
		WHERE cod_param='511070012';

		SELECT valor INTO cTransaccAbonoIva
		FROM Bdisac:sac_param
		WHERE cod_param='510070012';

		SELECT valor INTO cTransaccSuc
		FROM Bdisac:sac_param
		WHERE cod_param='807001';	

		SELECT valor INTO cTransaccCargocomiCte
		FROM Bdisac:sac_param
		WHERE cod_param='413070011';

		SELECT valor INTO cTransaccCargoivaCte
		FROM Bdisac:sac_param
		WHERE cod_param='4070011';

		SELECT valor INTO cTransaccCargocomi
		FROM Bdisac:sac_param
		WHERE cod_param='413070012';

		SELECT valor INTO cTransaccCargoiva
		FROM Bdisac:sac_param
		WHERE cod_param='4070012';		
		
		SELECT fecha_hoy 
		INTO dFecha_hoy
		FROM Bdisac:sac_fechas;			

		
		IF pSucursal = '5003' THEN

			--Calcula la comision e Iva bpi
			CALL  bdisac:"informix".sp_dinya_calcularcomisioniva_bpi ('07', '001', mMontoEnvio)
			RETURNING cCodRet,pImporte,mTotIVA,mTotComision,mTotalaCobrar,mTotIvaComision;  
			
			LET mTotalaCobrar=pImporte+mTotIvaComision;
			
		ELIF pSucursal = '5008' THEN
		
			CALL  bdisac:"informix".sp_dinya_calcularcomisioniva_bei ('07', '001', mMontoEnvio)
			RETURNING cCodRet,pImporte,mTotIVA,mTotComision,mTotalaCobrar,mTotIvaComision;  
			
			LET mTotalaCobrar=pImporte+mTotIvaComision;	
			
		ELSE
		
			--Calcula la comision e Iva
			CALL  bdisac:sp_DinYa_CalcularComisionIva ('07001',mMontoEnvio,pSucursal)
			RETURNING cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
			
		END IF;
		
		IF cCodRet <> 0 THEN
			LET cCodRet = '00015'; --Error en el calculo de comision e iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta del cte por orden de pago	
		LET pMontoCargo= pMontoCargo- mTotIvaComision;
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoEnvio, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, pMontoCargo,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
			LET cCodRet = '00016'; --Error en el cargo de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;	

		--Abono a la cuenta prestadora de servicios por el monto del Envio
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoEnvio, cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, pMontoCargo, mMontoEnvio, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;  

		IF cCodRet <> 0 THEN
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00017'; --Error en el abono de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;		
		
		--Cargo a la cte del cliente por el monto de la comision
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargocomiCte, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, mTotComision,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00018'; --Error en el cargo de la comision
			RETURN cCodRet,pFolioSuc;
		END IF;
		
		--Abono a la cuenta receptora (Comision)
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoComision ,cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, mTotComision, mTotComision, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00019'; --Error en el abono de la comision
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta del cliente por el Iva			
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoivaCte, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, mTotIVA,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
			LET cCodRet = '00020'; --Error en el cargo por el Iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Abono a la cuenta receptora (Iva)
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoIva , cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, mTotIVA, mTotIVA, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;
		
		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion del abono y cargo
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00021'; --Error en el abono del iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta prestadora por la comision			
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargocomi, cTransaccSuc, pFolioSuc, 
		cCuentaPrestadora, 0, mTotComision,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
			LET cCodRet = '00023'; --Error en el cargo por el Iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta prestadora por el iva		
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoiva, cTransaccSuc, pFolioSuc, 
		cCuentaPrestadora, 0, mTotIVA,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
			LET cCodRet = '00024'; --Error en el cargo por el Iva
			RETURN cCodRet,pFolioSuc;
		END IF;
		
		RETURN cCodRet,pFolioSuc; 

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: GENERA EL ENVIO CON PAGO CON CARGO A CUENTA DE MONTO ENVIO, COMISION E IVA, ACTIVA ENVIO EN SAC_ENVIOSDINEROYA', 
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'FECHA: DICIEMBRE 2009',
'VERSION: 20100125.1024',
'MODIFICACION: Se agrega validacion para ejecutar el sp sp_dinya_calcularcomisioniva_bpi cuando se realize una orden de pago desde la BPI', 
'AUTOR: Ilse Gomez',
'FECHA: 15 de enero de 2015',
'VERSION: 20141216.0900',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_pasemovshistorial()
    RETURNING CHAR(5), char(10);  --Códigos de retorno

DEFINE cCodRet                      CHAR(5);
DEFINE vfecha_insert                DATETIME YEAR to FRACTION(5);
DEFINE vtotregshist                 CHAR (40);
DEFINE iSqlErr                      INTEGER;
DEFINE iContBorra                   INTEGER;
DEFINE vmax_fechaold                DATE;
DEFINE vfecharesp                   DATE;
DEFINE vfechacomp                   DATE;
DEFINE  Cid_sucursal               	CHAR(4);
DEFINE  Cnumcategoria              	CHAR(2);
DEFINE  Cnumconvenio               	CHAR(5);
DEFINE  Creferencia1               	CHAR(40);
DEFINE  Creferencia2               	CHAR(40);
DEFINE  Cforma_pago                	CHAR(1);
DEFINE  Mimporte_pago              	MONEY;
DEFINE  Mimporte_comision_convenio 	MONEY;
DEFINE  Miva_comision_convenio     	MONEY;
DEFINE  Mimporte_comision_cte      	MONEY;
DEFINE  Miva_comision_cte          	MONEY;
DEFINE  Ccuenta_cargo              	CHAR(12);
DEFINE  Cusuario                   	CHAR(8);
DEFINE  Cfolio_suc                 	CHAR(16);
DEFINE  Ctransacc_suc              	CHAR(4);
DEFINE  Sflag_confirmacion_central 	SMALLINT;
DEFINE  Sflag_confirmacion_sucursal	SMALLINT;
DEFINE  Dfecha_pago                	DATE;
DEFINE  Dfecha_insert              	DATETIME YEAR to FRACTION(3);
DEFINE  Cstatus_cancelado          	CHAR(1);

 --SET DEBUG FILE TO "/informix/EPG/sp_sac_pasemovshistorial.out";
 --TRACE ON;

 LET cCodRet                    = '00000';
LET vfecha_insert               = CURRENT;
LET vtotregshist                = '0000000000000000000000000000000000000000';
LET iSqlErr                     = 0;
LET iContBorra                  = 0;
LET vmax_fechaold               = '';
LET vfecharesp                  = '';
LET vfechacomp                  = '';
LET Cid_sucursal                ='';
LET Cnumcategoria               ='';
LET Cnumconvenio                ='';
LET Creferencia1                ='';
LET Creferencia2                ='';
LET Cforma_pago                 ='';
LET Mimporte_pago               = 0;
LET Mimporte_comision_convenio  = 0;
LET Miva_comision_convenio      = 0;
LET Mimporte_comision_cte       = 0;
LET Miva_comision_cte           = 0;
LET Ccuenta_cargo               ='';
LET Cusuario                    ='';
LET Cfolio_suc                  ='';
LET Ctransacc_suc               ='';
LET Sflag_confirmacion_central  ='';
LET Sflag_confirmacion_sucursal ='';
LET Dfecha_pago                 ='';
LET Dfecha_insert               ='';
LET Cstatus_cancelado           ='';

BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vtotregshist;
		END IF;
   END EXCEPTION;
	
	SELECT MAX (fecha_pago) INTO vmax_fechaold
	  FROM "c92357113".sac_movimientoshistorial_old;
	
	let vfecharesp = vmax_fechaold + 1;
	let vfechacomp = TODAY - 91;

  SELECT COUNT({+INDEX ("informix".sac_movimientoshistorial)}referencia1) 
	INTO vtotregshist 
	FROM "informix".sac_movimientoshistorial
   WHERE fecha_pago BETWEEN vfecharesp AND vfechacomp;

  FOREACH cursor_borra WITH HOLD FOR
		
		 SELECT id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio,
				iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
				flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado
		   INTO	Cid_sucursal, Cnumcategoria, Cnumconvenio, Creferencia1, Creferencia2, Cforma_pago, Mimporte_pago, Mimporte_comision_convenio,
				Miva_comision_convenio, Mimporte_comision_cte, Miva_comision_cte, Ccuenta_cargo, Cusuario, Cfolio_suc, Ctransacc_suc,
				Sflag_confirmacion_central, Sflag_confirmacion_sucursal, Dfecha_pago, Dfecha_insert, Cstatus_cancelado
           FROM "informix".sac_movimientoshistorial
          WHERE fecha_pago >= vfecharesp
		    AND fecha_pago <= vfechacomp

		IF iContBorra = 0 THEN
		   BEGIN WORK;
		END IF;
		
		INSERT INTO "c92357113".sac_movimientoshistorial_old VALUES (Cid_sucursal, Cnumcategoria, Cnumconvenio, Creferencia1, Creferencia2, Cforma_pago, 
				Mimporte_pago, Mimporte_comision_convenio,Miva_comision_convenio, Mimporte_comision_cte, Miva_comision_cte, Ccuenta_cargo, Cusuario, 
				Cfolio_suc, Ctransacc_suc,Sflag_confirmacion_central, Sflag_confirmacion_sucursal, Dfecha_pago, Dfecha_insert, Cstatus_cancelado);
         
		DELETE FROM "informix".sac_movimientoshistorial WHERE numcategoria = Cnumcategoria AND numconvenio = Cnumconvenio AND fecha_pago = Dfecha_pago AND folio_suc = Cfolio_suc;

		LET iContBorra = iContBorra + 1;

		IF iContBorra = 1000 THEN
		   COMMIT WORK;
		   LET iContBorra = 0;
		END IF;
  
  END FOREACH;

  IF iContBorra < 1000 AND vtotregshist > 0 THEN
     COMMIT WORK;
  END IF;

END;
RETURN cCodRet, vtotregshist;
END PROCEDURE
DOCUMENT
'AUTOR : EPG',
'DESCRIPCION: Elimina registros de tabla bdisac:"informix".sac_movimientoshistorial por medio de cursor',
'y los respalda en bdisac:"informix".sac_movimientoshistorial_old.',
'EJECUTADO O LLAMADO POR: Proceso especial (se ejecuta por script en casos especiales).',
'FECHA : Abril/2014',
'VERSION: 20140413',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_envpag_valmontmax
(
	pModalidad   SMALLINT,  	--Modalidad
	pImporte     MONEY(14,2),  	--Monto a enviar-recibir
	pNombre1   	 CHAR (26), 	--nombre cliente-usuario
	pNombre2	 CHAR (26),
	pApellidoPat CHAR (26),
	pApellidoMat CHAR (26)
)

RETURNING CHAR (6) AS cCodRet;

	DEFINE cCodRet				CHAR(6);
	DEFINE iSqlErr 		  		INTEGER;
	DEFINE mLimite_envio  		MONEY(14,2);
	DEFINE iDias_limit   		INTEGER;
	DEFINE dtFecha_hoy   		DATE;
	DEFINE dtFecha_limit 		DATE;
	DEFINE mImporte_ya	 		MONEY(14,2);
	DEFINE mImporte_yahis 		MONEY(14,2);
	DEFINE mImporte_ya_movhis 	MONEY(14,2);
		
	LET cCodRet		 			= '000000';
	LET iSqlErr 				= 0;
	LET mLimite_envio   		= 0.00;
	LET iDias_limit     		= 0;
	LET dtFecha_hoy     		= DATE(1);
	LET dtFecha_limit   		= DATE(1);
	LET mImporte_ya				= 0.00;
	LET mImporte_yahis			= 0.00;
	LET mImporte_ya_movhis		= 0.00;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/adrian/sp_envpag_valmontmax_aia.out';
		--TRACE ON;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;  		
				
		IF NVL(pModalidad,0) NOT IN (1,2) OR NVL(pNombre1,'') ='' OR NVL(pApellidoPat,'') ='' THEN 
			LET cCodRet = '000001';
			RETURN cCodRet;
		END IF;
		
		-- BUSCANDO LA CANTIDAD LIMITE PERMITIDA
		SELECT NVL(valor,0) 
		INTO mLimite_envio
		FROM "informix".sac_param 
		WHERE cod_param = '6070033';
		
		/*
		-- BUSCANDO LOS DIAS LIMITES PARA EL CALCULO DE LA FECHA RANGO
		SELECT NVL(valor,0) 
		INTO iDias_limit
		FROM "informix".sac_param 
		WHERE cod_param = '6070034';
		*/
		
		--CONSULTAR FECHAHOY
		SELECT fecha_hoy 
		INTO dtFecha_hoy
		FROM "informix".sac_fechas
		WHERE empresa ='001';		
		
		--OBTENER FECHA LIMITE
		LET dtFecha_limit = MDY(MONTH(dtFecha_hoy),01,YEAR(dtFecha_hoy));
		
		-- ASEGURANDO DATOS EN MAYUSCULA
		LET pNombre1 = UPPER(pNombre1);
		LET pNombre2 = UPPER(pNombre2);
		LET pApellidoPat = UPPER(pApellidoPat);
		LET pApellidoMat = UPPER(pApellidoMat);		
		
		--ENVIO DE LA ORDEN DEL PAGO
		IF NVL(pImporte, 0) = 0 THEN
				LET cCodRet = '000001';
				RETURN cCodRet;
			END IF;
			
		IF pModalidad = 1 THEN							
			-- BUSCANDO LA SUMATORIA DE MOVIMIENTOS DE PAGOS EN EFECTIVO PARA EL ORDENANTE				
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_envio,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientos WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_ya
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_rem = pNombre1
			AND envio.seg_nom_rem = pNombre2
			AND envio.apell_pat_rem = pApellidoPat
			AND envio.apell_mat_rem = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(enviohis.importe_envio,0) <> 0 AND enviohis.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = enviohis.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1'  AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_yahis
			FROM "informix".sac_enviosdineroyahis enviohis
			WHERE enviohis.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (enviohis.estatus ='01' OR enviohis.estatus ='04') -- ACTIVOS Y PAGADOS
			AND enviohis.pri_nom_rem = pNombre1
			AND enviohis.seg_nom_rem = pNombre2
			AND enviohis.apell_pat_rem = pApellidoPat
			AND enviohis.apell_mat_rem = pApellidoMat;

			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_envio,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_ya_movhis
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_rem = pNombre1
			AND envio.seg_nom_rem = pNombre2
			AND envio.apell_pat_rem = pApellidoPat
			AND envio.apell_mat_rem = pApellidoMat;
						
		ELSE
			-- BUSCANDO LA SUMATORIA DE MOVIMIENTOS DE COBROS EN EFECTIVO PARA EL BENEFICIARIO
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_pago,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientos WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_ya
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_ben = pNombre1
			AND envio.seg_nom_ben = pNombre2
			AND envio.apell_pat_ben = pApellidoPat
			AND envio.apell_mat_ben = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(enviohis.importe_pago,0) <> 0 AND enviohis.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = enviohis.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_yahis
			FROM "informix".sac_enviosdineroyahis enviohis
			WHERE enviohis.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (enviohis.estatus ='01' OR enviohis.estatus ='04') -- ACTIVOS Y PAGADOS
			AND enviohis.pri_nom_ben = pNombre1
			AND enviohis.seg_nom_ben = pNombre2
			AND enviohis.apell_pat_ben = pApellidoPat
			AND enviohis.apell_mat_ben = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_pago,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_ya_movhis
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_ben = pNombre1
			AND envio.seg_nom_ben = pNombre2
			AND envio.apell_pat_ben = pApellidoPat
			AND envio.apell_mat_ben = pApellidoMat;
					
		END IF;
		
		IF (NVL(mImporte_ya,0) + NVL(mImporte_yahis,0) + NVL(mImporte_ya_movhis,0) + NVL(pImporte,0)) > mLimite_envio THEN
				LET cCodRet = '000004';
				RETURN cCodRet;
		END IF
		
	RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que validará el monto máximo mensual en efectivo por usuario para envíos y/o cobros previa validación de los parámetros de entrada ',
'AUTOR: Antonio Cebreros Perez',
'FECHA DE CREACION: 13 de Octubre del 2014',
'VERSION: 20141030.1500',
'BD: bdisac',
'Folio: 1464 - LimiteOrdPagEfec',

'DESCRIPCION: Ahora se contemplará Envios/Cobros para la sumatoria del acumulado cuando ocurre el siguiente caso',
'por ejemplo: Hoy se realiza un envío y no es cobrado',
'AUTOR: Francisco Eduardo Benitez Baez',
'FECHA DE CREACION: 01 de Diciembre del 2014',
'VERSION: 20141201.1552',
'BD: BDISAC',
'Folio: 1474 - MttoLimiteOrdPagEfec',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE FUNCTION "informix".fn_instr(pString VARCHAR(255),pToken VARCHAR(255),pStar INTEGER DEFAULT 1 )
RETURNING SMALLINT ;

	DEFINE i,j SMALLINT ;
	DEFINE w_1 VARCHAR(255) ;

	IF ( pString IS NULL) OR (pToken IS NULL ) THEN
		RETURN -1 ;
	END IF ;
	LET j = LENGTH(pString);
	FOR i = pStar TO j 
		IF ( SUBSTR(pString,I,1) = SUBSTR(pToken,1,1) ) THEN
			LET w_1 = SUBSTR(pString,i,LENGTH(pToken)) ;
			IF ( w_1 = pToken) THEN
				RETURN i ;
			END IF ;
		END IF ;
	END FOR ;
RETURN 0 ;
END FUNCTION ;