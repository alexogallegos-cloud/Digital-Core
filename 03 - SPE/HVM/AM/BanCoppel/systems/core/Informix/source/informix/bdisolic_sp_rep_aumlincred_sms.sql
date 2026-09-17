CREATE PROCEDURE "informix".sp_rep_aumlincred_sms (pCel char(10),PARAM1 varchar(40))
-- execute procedure "informix".sp_rep_aumlincred_sms(pCel,PARAM1);
returning 
char (5);

------------------------------------------------------------------------------------

---- DECLARACION DE VARIABLES
DEFINE pEmpresa 		char(3);
DEFINE vNumCte 			char(20);
DEFINE pSolicitud 	char(20);
DEFINE vApellPaterno 	char(20);
DEFINE vCelular			char(13);
DEFINE vCorreo			char(100);
DEFINE vFecha 			date;
DEFINE vFechaProxima 	date;
DEFINE vFechaH 			date;
DEFINE vFechaU			date;
DEFINE vNumProducto		char(4);
DEFINE vFechaMin		date;
DEFINE vFechaA			date;
DEFINE vExcluidoEnv		integer;
DEFINE vTotalEnv		integer;
DEFINE vStatus			char (5);
DEFINE vLineaS			DECIMAL (18,2);
DEFINE vNumTar			char (4);
DEFINE vLinCred    		DECIMAL(18,2);
DEFINE cNumproducto		CHAR(4);
DEFINE vIncremento 		DECIMAL(18,2);
DEFINE cSucursal   		CHAR(4);
DEFINE vMen        		CHAR(80);
DEFINE cexiste 			CHAR(1);

DEFINE SQL_ERR			INTEGER;
DEFINE ISAM_ERR			INTEGER;
DEFINE ERROR_INFO		VARCHAR(80);
DEFINE P_COD_RET		CHAR(5);
DEFINE COD_RET			VARCHAR(6);
DEFINE P_MENSAJE		VARCHAR(80);
DEFINE vproceso			CHAR (4);
DEFINE cMensaje			CHAR(80);
DEFINE cSql				CHAR(2000);
LET cexiste	  			= '';

---INICIALIZACIONES DE VARIABLES
LET pEmpresa			= '';
LET vNumCte				= '';
LET pSolicitud		= '';
LET vApellPaterno		= '';
LET vCelular			= '';
LET vFecha				= '';
LET vFechaProxima		= '';
LET vFechaH				= '';
LET vFechaU				= '';
LET vNumProducto		= '';
LET vFechaMin			= '';
LET vFechaA				= 0;
LET vExcluidoEnv		= 0;
LET vTotalEnv			= 0;
LET vStatus				= '';
LET vLineaS				= 0;
LET vNumTar				= '';
LET vLinCred      		= 0;
LET cNumproducto   		= '';
LET vIncremento    		= 0;
LET cSucursal      		= '';
LET vMen           		= "El proceso se ejecuto correctamente";

LET SQL_ERR				= 0;
LET ISAM_ERR			= 0;
LET ERROR_INFO			= '';
LET P_COD_RET			= '00000';
LET COD_RET				= '00000';
LET P_MENSAJE			= 'El proceso de la campaï¿½a TC_AUMLIN se realizo correctamente.';
LET vproceso			= '0056';
LET cMensaje			= '';
LET cSql				= '';


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
--        LET P_MENSAJE = ERROR_INFO;
        LET P_MENSAJE = 'Error al ejecutar el proceso. '||pSolicitud;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '02') RETURNING COD_RET;	
		RETURN P_COD_RET;
	END EXCEPTION;

--Set debug file to "sp_rep_aumlincred_sms.out";
--trace on;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET;
     end if;

	select fecha_hoy into vFechaH
	from bdicred:sd_fechas;
	
	--LET vFechaH = today;

	set lock mode to wait 3;		
    set isolation to dirty read;

		SELECT distinct cte.empresa, sol.num_solicitud, cte.numcte, nvl(tel.telefono,'') num_telefono, cte.apell_paterno
		INTO pEmpresa, pSolicitud, vNumCte, vCelular, vApellPaterno
		FROM bdicred:"informix".sd_bitacora_aumlincred sol
		JOIN bdinteg:"informix".si_cliente cte on (cte.numcte = sol.numcte)
		JOIN bdinteg:"informix".si_telefonos_actual tel on (cte.numcte = tel.numcte and tel.tipo_tel = 2 and tel.movil_fijo = 0)
		WHERE tel.telefono = pCel
		AND cte.numcte = tel.numcte
		AND sol.status IN ('AT', 'IN'); --Validacion incremento especial
		--into temp respaumlincred with no log;
			UPDATE bdicred:"informix".sd_bitacora_aumlincred 
			SET status = "AP", resp_cte = 1, fecha_status = today, hora_status = current, medio_res = "V"
			WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status in ('AT', 'IN');

	--FOREACH WITH HOLD

---------- SMS

		EXECUTE PROCEDURE bdicred:sp_grabarincrementolincred(pEmpresa , pSolicitud )
															INTO cod_ret, vMen;



		--Validacion incremento especial
		IF cod_ret = '00000' THEN
			
			SELECT count(*)
			INTO cexiste
			FROM bdicred:"informix".sd_bitacora_aumlincred A 
			INNER JOIN bdicred:"informix".sd_bitacora_incremento_especial B ON A.num_solicitud = B.num_credito
			WHERE A.num_solicitud = pSolicitud AND A.flag_incremento_especial = "1" AND B.validacion = "0"; 
			
			IF cexiste > 0 THEN
				UPDATE bdicred:"informix".sd_bitacora_incremento_especial
				SET validacion = "1", validacion_sms = "1"
				WHERE num_credito = pSolicitud AND validacion = "0";
			END IF;
        
		END IF;


/*
		SELECT lincred_sugerida, num_producto, lincred_sugerida - lincred_actual,sucursal
		INTO vLinCred,cNumproducto,vIncremento,cSucursal 
		FROM bdicred:sd_bitacora_aumlincred
		WHERE empresa = pEmpresa 
		AND num_solicitud = pSolicitud 
		AND status = 'AT'  
		AND fecha_insert = ( SELECT MAX(fecha_insert)
							FROM bdicred:sd_bitacora_aumlincred
							WHERE empresa = pEmpresa 
							AND num_solicitud = pSolicitud 
							AND status = 'AT' );
*/
		--BEGIN WORK; 
/*		
			UPDATE bdicred:sd_maesdos 
			SET monto_otorgado = vLinCred, 
			fecha_ult_mov = vFechaH 
			WHERE empresa = pEmpresa
			AND num_credito = pSolicitud;
			
			     EXECUTE PROCEDURE bdicred:GENMOV( pEmpresa, pSolicitud
                                     , cNumproducto , 1
                                     ,'008' , vFechaH
                                     , vIncremento , 'Act LineaCredito'
                                     , cSucursal, '01'
                                     , '0000'
                                     ) INTO cod_ret, vMen;
*/									 
			CALL bdimnsj:"informix".sp_registra_evento('2','SMS_BCPL','TC_AUMLIN',vNumCte,pSolicitud,'','1',vApellPaterno,'','','','','','','','',PARAM1,'',pCel,vLinCred,0,0,0,0,vFechaH,'')RETURNING COD_RET;
			 --CALL bdimnsj:"informix".sp_registra_evento('2','SMS_BCPL','TC_AUMLIN','000000000',pSolicitud,'','1',vApellPaterno,'','','','','','','','',PARAM1,'',vCelular,vLinCred,0,0,0,0,vFechaH,'')RETURNING COD_RET;
			 
			 UPDATE bdicred:"informix".sd_bitacora_aumlincred
				SET respuesta = PARAM1,
				fecha_respuesta = vFechaH
			 WHERE num_solicitud = pSolicitud;
			 
			 --LET vTotalEnv = vTotalEnv + 1;
			 
		--COMMIT WORK;
			 
	--END FOREACH	
	
		   --let cMensaje = 'Actualizacion de incremento a solicitud: ' || pSolicitud ;
		   --CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
/*		   
	 if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET;
     end if;	 
*/	 
--------------

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET;
     end if;

	 LET P_COD_RET = '00000';
	 
    RETURN P_COD_RET;

end;
end procedure;