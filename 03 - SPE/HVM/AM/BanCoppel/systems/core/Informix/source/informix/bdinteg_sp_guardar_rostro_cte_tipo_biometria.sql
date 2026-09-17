CREATE PROCEDURE "informix".sp_guardar_rostro_cte_tipo_biometria(pEmpresa CHAR(3), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS CodigoRetorno;
	
-- *	DEFINICION DE VARIABLES	
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(5);
-- *	ASIGNACION DE VARIABLES
	LET	iSqlErr 		= 0;
	LET cCodRet 		= '00000';	
-- *	CONTROL DE ERRORES
BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	LET pEmpresa = NVL(TRIM(pEmpresa),'');
	--- LET pNumCliente = NVL(TRIM(pNumCliente),'') = '';
	LET pNumCliente = LPAD(TRIM(pNumCliente),9,'0');	
	 
	IF pEmpresa = ''  OR pNumCliente = '000000000' THEN
		LET cCodRet = '00001';
	END IF;
	
	UPDATE 	"informix".si_cliente SET tpo_biometria = '1' 
	WHERE empresa = pEmpresa AND numcte = pNumCliente;					
			
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio.........: 513-Modificacion del monitorenvios para imagenes de Biometria',
'Autor.........: 98786903-Paul Garcia',
'Fecha.........: 18/12/2018',
'Descripcion...: se crea procedimiento para actualizar campo "tpo_biometria" a 1.',
'BD............: bdirostros',
'Folio.........: No aplica, incidencia productiva.',
'Autor.........: Cristian Valentina Aguilar ',
'Fecha.........: 2018-12-23',
'Descripcion...: Se optimiza prodecimiento.',
'BD............: bdirostros'
;

CREATE PROCEDURE "informix".sp_ws_consulta_cliente_coppel(pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id VARCHAR(30),
											  pcNumClienteCoppel CHAR(20),
											  pcRfc CHAR(13))

    RETURNING 
          CHAR(5)       as vcodret1,
		  CHAR(80)		as cDescr_completa_mensaje,
          CHAR(2)       as vEsClienteCoppel,
		  DATE 	 		as vFechaCliente,
		  CHAR(2)       as vEstatusSolicitud,
		  CHAR(3)       as vCausaSolicitud,
		  DATE 	 		as vFechaSolicitud,
		  CHAR(20)		as vNumClienteCoppel,
		  CHAR(1) 	    as vConsumICoppel;
         
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	DEFINE cDescr_completa_mensaje 	CHAR(80);
	DEFINE vConsumICoppel CHAR(1);
	
	DEFINE vNumClienteBancoppel CHAR(9);
	DEFINE vEsClienteCoppel 	CHAR(2);
    DEFINE vFechaCliente 		DATE;
	DEFINE vNumSolicitud 		CHAR(20);
	DEFINE vEstatusSolicitud 	CHAR(2);
	DEFINE vCausaSolicitud 		CHAR(3);
    DEFINE vFechaSolicitud 		DATE;
	DEFINE vNumClienteCoppel	CHAR(20);
	DEFINE vExisteCteCoppel		INTEGER;

	DEFINE dtFecha_dia		DATE;
	DEFINE cAgent_cd		CHAR(3);
	DEFINE cUsuario			CHAR(8);
	DEFINE cPassword		CHAR(8);
	DEFINE cIp_origen		CHAR(15);
	DEFINE cId_sesion_act	CHAR(30);
	
	DEFINE vTransaccion 		 CHAR(10);
	DEFINE vFechaMaxSolicitud 	 DATETIME YEAR TO SECOND;
	DEFINE vFechaMaxAutorizacion DATETIME YEAR TO SECOND;
	
    LET vcodret1 = '00000';
    LET vcodret2 = '00000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
	LET cDescr_completa_mensaje = 'EJECUCION EXITOSA';

	LET vNumClienteBancoppel = '0';
    LET vEsClienteCoppel = '00';
	LET vNumSolicitud = '';
	LET vEstatusSolicitud = '';
	LET vCausaSolicitud = '';
	LET vFechaCliente = EXTEND(MDY(01,01,1900));
	LET vFechaSolicitud = EXTEND(MDY(01,01,1900));
	
	LET dtFecha_dia   = CURRENT::DATE;	
	LET cAgent_cd = '';
	LET cUsuario = '';
	LET cPassword = '';
	LET cIp_origen = '';
	LET cId_sesion_act = '';
	
	LET vTransaccion = '';
	LET vFechaMaxSolicitud = EXTEND(MDY(01,01,1900), YEAR to SECOND) + 00 UNITS HOUR + 00 UNITS MINUTE + 00 UNITS SECOND;
	LET vFechaMaxAutorizacion = EXTEND(MDY(01,01,1900), YEAR to SECOND) + 00 UNITS HOUR + 00 UNITS MINUTE + 00 UNITS SECOND;
	LET vNumClienteCoppel = '';
	LET vExisteCteCoppel= 0;
	LET vConsumICoppel = '0';

	

    BEGIN
	
    ON EXCEPTION SET sql_err, isam_err, desc_err

        --SET DEBUG FILE TO "/informix/LIP/sp_ws_consulta_cliente_coppel.out";
        --TRACE ON;

        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
			LET cDescr_completa_mensaje = vcodret3;

            RETURN vcodret1, cDescr_completa_mensaje, vEsClienteCoppel, vFechaCliente, vEstatusSolicitud, vCausaSolicitud, vFechaSolicitud, vNumClienteCoppel, vConsumICoppel;
        END IF;
    END EXCEPTION;

		--SET DEBUG FILE TO "/informix/LIP/sp_ws_consulta_cliente_coppel.out";
        --TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


    --VALIDA PARAMETROS DE ENTRADA
	IF NVL(pcAgent_trans_type_code, '') = '' OR NVL(pcAgent_cd, '') = '' OR NVL(pcUsuario, '') = '' OR NVL(pcPassword, '') = '' OR NVL(pcIp_origen, '') = '' OR NVL(pcSession_id, '') = '' THEN
		LET vcodret1 = '0101';
    ELSE
	
		LET pcusuario = TRIM(pcusuario);
		
		SELECT transaccion
		INTO vTransaccion
		FROM bdisac:"informix".sac_ws_transacc_ctes
		WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND  usuario=pcusuario AND activa = 'S';
		
		IF (vTransaccion IS NOT NULL AND vTransaccion <> "") THEN
					--Se obtienen los valores de los campos, para la validacion de los parametros de entrada
					SELECT agent_cd,usuario,password,ip_origen,id_sesion_act::CHAR(30)
					INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
					FROM bdisac:"informix".sac_ws_clientes
					WHERE agent_cd = pcAgent_cd and usuario=pcusuario and fecha_insert = dtFecha_dia;
				   
					IF cAgent_cd = pcAgent_cd THEN
						IF cUsuario = pcUsuario THEN
							IF cPassword = pcPassword THEN
								IF cIp_origen = pcIp_origen THEN
									IF cId_sesion_act = pcSession_id THEN
										--OBTENCION DE DATOS
										IF vcodret1 = '00000' THEN
											--Numero de cliente
											SELECT LIMIT 1 numcte
											INTO vNumClienteBancoppel
											FROM bdinteg:"informix".si_cliente
											WHERE rfc = pcRfc;

											--Fecha mÃÂ¡xima de solicitud 
											SELECT MAX(fecha_hora)
											INTO vFechaMaxSolicitud
											FROM bdisolic:"informix".ss_solicitudes
											WHERE numcte = vNumClienteBancoppel
											AND num_producto = '6500';

											--Solicitud mas reciente
											SELECT LIMIT 1 num_solicitud, fecha_insert
											INTO vNumSolicitud, vFechaSolicitud
											FROM bdisolic:"informix".ss_solicitudes
											WHERE numcte = vNumClienteBancoppel
											AND fecha_hora = vFechaMaxSolicitud
											AND num_producto = '6500';
											
											--Fecha maxima de estatus de solicitud
											SELECT MAX(fecha_hora)
											INTO vFechaMaxAutorizacion
											FROM bdisolic:"informix".ss_autorizacion
											WHERE num_solicitud = vNumSolicitud;
											
											IF(vFechaMaxAutorizacion IS NULL) THEN
											
												--Fecha maxima de estatus de solicitud
												SELECT MAX(fecha_salida)
												INTO vFechaMaxAutorizacion
												FROM bdisolic:"informix".ss_autorizacion
												WHERE num_solicitud = vNumSolicitud;
												
												--Estatus de solicitud mas reciente
												SELECT LIMIT 1 status_solicitud, causa_solicitud
												INTO vEstatusSolicitud, vCausaSolicitud
												FROM bdisolic:"informix".ss_autorizacion
												WHERE num_solicitud = vNumSolicitud
												AND fecha_salida = vFechaMaxAutorizacion;
												
											ELSE

												--Estatus de solicitud mas reciente
												SELECT LIMIT 1 status_solicitud, causa_solicitud
												INTO vEstatusSolicitud, vCausaSolicitud
												FROM bdisolic:"informix".ss_autorizacion
												WHERE num_solicitud = vNumSolicitud
												AND fecha_hora = vFechaMaxAutorizacion;
											
											END IF;
											
											--Fecha en que se convirtiÃÂ³ en Cliente
											SELECT fecha_insert,cliente
											INTO vFechaCliente, vNumClienteCoppel
											FROM bdinteg:"informix".si_relacion_ctebcplcpl
											WHERE numcte_banco = vNumClienteBancoppel
											AND (cliente = pcNumClienteCoppel OR cliente = cliente);
											
											SELECT count(cliente)
											INTO vExisteCteCoppel
											FROM bdinteg:"informix".si_relacion_ctebcplcpl
											WHERE numcte_banco = vNumClienteBancoppel
											AND (cliente = pcNumClienteCoppel OR cliente = cliente);
											
											IF(vEstatusSolicitud IS NOT NULL AND vEstatusSolicitud <> '' AND vNumClienteBancoppel IS NOT NULL AND vNumClienteBancoppel <> '0'
											AND vExisteCteCoppel > 0) THEN
												LET vEsClienteCoppel = '01';
											ELSE 
												IF (pcNumClienteCoppel IS NOT NULL AND pcNumClienteCoppel <> '0' AND pcNumClienteCoppel <> '') THEN
													LET vEsClienteCoppel = '01';
													LET vNumClienteBancoppel = pcNumClienteCoppel;
													LET vEstatusSolicitud = '';
													LET vFechaCliente = NULL;
													LET vFechaSolicitud = NULL;
													LET vCausaSolicitud = '';
												ELSE
													IF(vEstatusSolicitud IS NULL) THEN
														LET vEstatusSolicitud = '';
													END IF;
													IF(vCausaSolicitud IS NULL) THEN
														LET vCausaSolicitud = '';
													END IF;
												END IF;
											END IF;
										
										END IF;
									
									ELSE
										LET vcodret1 = '9991';
									END IF;
								ELSE
									LET vcodret1 = '9997';
									END IF;
							ELSE
								LET vcodret1 = '9979';
								END IF;
						ELSE
							LET vcodret1 = '9980';
							END IF;
					ELSE
						LET vcodret1 = '9998';
						END IF;
		ELSE
			LET vcodret1 = '9999';
			END IF;
	END IF;
	
	IF vcodret1 <> '00000' THEN
	
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode_ds, '')
		INTO cDescr_completa_mensaje
		FROM bdisac:"informix".sac_ws_catmensajes
		WHERE agent_trans_type_code = pcAgent_trans_type_code
		AND opcode = vcodret1;
		
		LET vcodret1 = CONCAT('0',vcodret1);
		
	END IF;

	--Bitacora de Consultas 
	--INSERT INTO bdinteg:"informix".si_bitacora_cte_coppel(cod_ret, num_Cliente, es_cliente_coppel, fecha_cliente, estatus_solicitud, causa_estatus, fecha_solicitud, fecha_consulta)
    --VALUES (vcodret1, vNumClienteBancoppel, vEsClienteCoppel, vFechaCliente, vEstatusSolicitud, vCausaSolicitud, vFechaSolicitud, CURRENT);
	
	--Parametro consumo de interface Coppel
	SELECT valor INTO vConsumICoppel FROM si_param WHERE cod_param = '470';
	
	RETURN vcodret1, cDescr_completa_mensaje, vEsClienteCoppel, vFechaCliente, vEstatusSolicitud, vCausaSolicitud, vFechaSolicitud, vNumClienteCoppel, vConsumICoppel;
	
END;
END PROCEDURE;