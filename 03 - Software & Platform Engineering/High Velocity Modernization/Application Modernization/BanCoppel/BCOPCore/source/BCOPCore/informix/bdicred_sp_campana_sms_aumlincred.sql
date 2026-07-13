CREATE PROCEDURE "informix".sp_campana_sms_aumlincred ()
-- execute procedure "informix".sp_campana_sms_aumlincred();
returning 
char (06),
VARCHAR(80);

------------------------------------------------------------------------------------

---- DECLARACION DE VARIABLES
DEFINE vEmpresa 		char(3);
DEFINE vNumCte 			char(20);
DEFINE vNumSolicitud 	char(20);
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
DEFINE vFechaMax		date;
DEFINE vFechaDia		date;
DEFINE vTotal_Envios	smallint;

DEFINE SQL_ERR			INTEGER;
DEFINE ISAM_ERR			INTEGER;
DEFINE ERROR_INFO		VARCHAR(80);
DEFINE P_COD_RET		VARCHAR(6);
DEFINE COD_RET			VARCHAR(6);
DEFINE P_MENSAJE		VARCHAR(80);
DEFINE vproceso			CHAR (4);
DEFINE cMensaje			CHAR(80);
DEFINE cSql				CHAR(2000);


---INICIALIZACIONES DE VARIABLES
LET vEmpresa			= '';
LET vNumCte				= '';
LET vNumSolicitud		= '';
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
LET vFechaMax			= '';
LET vFechaDia			= '';
LET vTotal_Envios		= 0;

LET SQL_ERR				= 0;
LET ISAM_ERR			= 0;
LET ERROR_INFO			= '';
LET P_COD_RET			= '000000';
LET COD_RET				= '000000';
LET P_MENSAJE			= 'Proceso campaña TC_AUMLINS exitoso.';
LET vproceso			= '0055';
LET cMensaje			= '';
LET cSql				= '';


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
--        LET P_MENSAJE = ERROR_INFO;
        LET P_MENSAJE = 'Error al ejecutar el proceso. '||vNumSolicitud;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '02') RETURNING COD_RET;	
		RETURN P_COD_RET,P_MENSAJE;
	END EXCEPTION;

  --Set debug file to "/informix/jorger/sp_campana_sms_aumlincred.out";
  --trace on;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	SELECT MIN(fecha_insert), MAX(fecha_insert) INTO vFechaMin, vFechaMax
	FROM bdicred:"informix".sd_bitacora_aumlincred WHERE origen = 'C' AND status = 'AT';
	
	select day(fecha_hoy) 
	into vFechaDia
	from bdicred:"informix".sd_fechas;
	
	LET vFechaH = today;

	set lock mode to wait 3;		
    set isolation to dirty read;
	
	if vFechaDia = 13 then

		SELECT distinct sol.num_solicitud, sol.numcte num_cte, nvl(tel.telefono,'') num_telefono, sol.fecha_insert, sol.status, sol.lincred_sugerida, SUBSTR(tar.num_tarjeta,13,4) num_tarjeta, total_envios 
		FROM bdicred:"informix".sd_bitacora_aumlincred sol
		inner join bdinteg:"informix".si_telefonos_actual tel on (sol.numcte = tel.numcte and tel.tipo_tel = 2 and tel.movil_fijo = 0 and tel.telefono is not null)
		inner join bdicred:"informix".sd_tarjeta tar on (sol.numcte = tar.numcte and sol.num_solicitud = tar.num_credito and tar.status_tar = 'A')
		where sol.fecha_insert = vFechaMax
		and origen = 'C' and sol.status = 'AT'
		into temp smsaumlincred with no log;
		
	else	
		
		select distinct sol.num_solicitud, sol.numcte num_cte, nvl(tel.telefono,'') num_telefono, sol.fecha_insert, sol.status, sol.lincred_sugerida, SUBSTR(tar.num_tarjeta,13,4) num_tarjeta, total_envios 
		from bdicred:"informix".sd_bitacora_aumlincred sol
		inner join bdinteg:"informix".si_telefonos_actual tel on (sol.numcte = tel.numcte and tel.tipo_tel = 2 and tel.movil_fijo = 0 and tel.telefono is not null)
		inner join bdicred:"informix".sd_tarjeta tar on (sol.numcte = tar.numcte and sol.num_solicitud = tar.num_credito and tar.status_tar = 'A')
		where sol.fecha_insert >= vFechaMin
		and origen = 'C' and sol.status = 'AT'
		and (today-sol.fecha_insert) in (16,32,48,64,80)		
		into temp smsaumlincred with no log;
		
	end if;	

		CREATE INDEX "informix".ind_fecha_numcte_tmp 
			ON "informix".smsaumlincred(fecha_insert, num_cte) using btree in dbs_movhis_idx5 ONLINE;

		UPDATE STATISTICS MEDIUM FOR TABLE smsaumlincred;		

	FOREACH WITH HOLD

---------- SMS

		select sol.num_cte, sol.num_solicitud, cte.apell_paterno, sol.num_telefono, sol.fecha_insert, sol.status, sol.lincred_sugerida, sol.num_tarjeta, total_envios
			into vNumCte, vNumSolicitud, vApellPaterno, vCelular, vFecha, vStatus, vLineaS, vNumTar, vTotal_Envios
		from smsaumlincred sol  
		inner join bdinteg:"informix".si_cliente cte on (sol.num_cte = cte.numcte)
		--WHERE (today-sol.fecha_insert) in (16,32,48,64,80);
		/*
		SELECT distinct total_envios
		INTO vTotal_Envios
		FROM bdicred:"informix".sd_bitacora_aumlincred
		WHERE num_solicitud = vNumSolicitud
		AND origen = 'C' AND status = 'AT';
		
		IF(vTotal_Envios IS NULL) THEN
			BEGIN WORK;
				UPDATE bdicred:"informix".sd_bitacora_aumlincred
					SET total_envios = 0
				 WHERE num_solicitud = vNumSolicitud
				 AND origen = 'C' AND status = 'AT';
			COMMIT WORK;
		END IF; 
		*/
		IF(vTotal_Envios IS NULL) THEN

			LET vTotal_Envios = 0;
		
		END IF; 
		
	BEGIN WORK; 
		
			CALL bdimnsj@stag_ids1170:"informix".sp_registra_evento('2','PROD_SMS','TC_AUMLINS',vNumCte,vNumSolicitud,'','1',vApellPaterno,'','','','','','','','',vNumTar,'',vCelular,vLineaS,0,0,0,0,vFechaH,'')RETURNING COD_RET;
		     --CALL bdimnsj:"informix".sp_registra_evento('2','PROD_SMS','TC_AUMLINS',vNumCte,vNumSolicitud,'','1',vApellPaterno,'','','','','','','','',vNumTar,'',vCelular,vLineaS,0,0,0,0,vFechaH,'')RETURNING COD_RET;
			 --CALL bdimnsj:"informix".sp_registra_evento('2','PROD_SMS','TC_AUMLINS','000000000',vNumSolicitud,'','1',vApellPaterno,'','','','','','','','',vNumTar,'',vCelular,vLineaS,0,0,0,0,vFechaH,'')RETURNING COD_RET;
			 
			 UPDATE bdicred:"informix".sd_bitacora_aumlincred
				SET total_envios = vTotal_Envios + 1,
				fecha_envio_sms = vFechaH
			 WHERE num_solicitud = vNumSolicitud
			 AND origen = 'C' AND status = 'AT';
			 
			 LET vTotalEnv = vTotalEnv + 1;
			 
		COMMIT WORK;
			 
	END FOREACH	
	
		   let cMensaje = 'Total de envíos realizados: ' || vTotalEnv;
		   CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
		   
	 if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;
	 
	 
--------------

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;
	 
	let P_MENSAJE = trim(P_MENSAJE) || ' Cuentas procesadas: '|| vTotalEnv;

    RETURN P_COD_RET,P_MENSAJE;

end;
end procedure;