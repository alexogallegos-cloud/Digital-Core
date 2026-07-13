CREATE PROCEDURE "informix".sp_localiza_actualizacteoa ()
-- execute procedure "informix".sp_localiza_actualizacteoa();
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
DEFINE vvalor 			smallint;
DEFINE vSecuencia		smallint;
DEFINE vFechaDir		date;
DEFINE vEnvios			smallint;
DEFINE vSmsEnviadosCop	integer;
DEFINE vSmsEnviadosMix	integer;
DEFINE vSmsEnviadosMan	integer;
DEFINE vCeEnviadosCop	integer;
DEFINE vCeEnviadosMix	integer;
DEFINE vCeEnviadosMan	integer;
DEFINE vFechaMin		date;
DEFINE vFechaA			date;
DEFINE vExcluidoEnv		integer;
DEFINE vTotalEnv		integer;
DEFINE vTipoMov			char(1);
DEFINE vSmsEnviadosTot	integer;
DEFINE vCeEnviadosTot	integer;


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
LET vCorreo				= '';
LET vFecha				= '';
LET vFechaProxima		= '';
LET vFechaH				= '';
LET vFechaU				= '';
LET vNumProducto		= '';
LET vvalor				= 0;
LET vSecuencia			= 0;
LET vFechaDir			= '';
LET vEnvios				= 0;
LET vSmsEnviadosCop		= 0;
LET vSmsEnviadosMix		= 0;
LET vSmsEnviadosMan		= 0;
LET vCeEnviadosCop		= 0;
LET vCeEnviadosMix		= 0;
LET vCeEnviadosMan		= 0;
LET vFechaMin			= mdy(03,06,2018);
LET vFechaA				= 0;
LET vExcluidoEnv		= 0;
LET vTotalEnv			= 0;
LET vTipoMov			= '';
LET vSmsEnviadosTot		= 0;
LET vCeEnviadosTot		= 0;


LET SQL_ERR				= 0;
LET ISAM_ERR			= 0;
LET ERROR_INFO			= '';
LET P_COD_RET			= '000000';
LET COD_RET				= '000000';
LET P_MENSAJE			= 'El proceso de la campaña CPL_SNLCTE se realizo correctamente.';
LET vproceso			= '2016';
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


  --Set debug file to "/informix/jorger/localiza/sp_localiza_actualizacteoa.out";
  --trace on;
  
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	select fecha_hoy, fecha_ant,ult_dia_mes into vFechaH, vFechaA, vFechaU from bdicred:sd_fechas where empresa = '001';
	--LET vFechaH = mdy(01,22,2018);
	LET vFechaProxima = vFechaH + 10;

	set lock mode to wait 3;		
    set isolation to dirty read;

	--
	
		SELECT sol.empresa, sol.numcte num_cte, sol.num_solicitud, sol.num_producto, nvl(tel.telefono,'') num_telefono,trim(nvl(cor.correo_elec,'')) nom_correo, os.fecha_insert fecha_envio1, tipo_movimiento
		FROM bdisolic:ss_solicitudes sol
		join bdisolic:"informix".ss_autorizacion os on (sol.empresa = os.empresa and sol.num_solicitud = os.num_solicitud and sol.status_solicitud = os.status_solicitud)
		left outer join bdinteg:si_telefonos_actual tel on (sol.numcte = tel.numcte and tel.tipo_tel = 2 and tel.movil_fijo = 0)
		left outer join bdinteg:si_correos cor on (sol.numcte = cor.numcte and cor.status_correo= 'A')
		join bdisolic:ss_resum_scor_fin scor on (sol.num_solicitud = scor.num_solicitud)
		where sol.num_producto = '6500'
		and sol.status_solicitud = 'OA'
		AND os.fecha_insert = vFechaA
		and (tel.telefono is not null or cor.correo_elec is not null)
		into temp localizacte with no log;
		
		CREATE INDEX "informix".ind_fecha_empresa_numcte_tmp 
			ON "informix".localizacte(fecha_envio1, empresa, num_cte);

		UPDATE STATISTICS HIGH FOR TABLE localizacte;		
		
	FOREACH WITH HOLD
	
---------- SMS

		select sol.empresa,sol.num_cte, sol.num_solicitud, sol.num_producto, cte.apell_paterno, sol.num_telefono, sol.nom_correo, sol.fecha_envio1, tipo_movimiento 
			into  vEmpresa, vNumCte, vNumSolicitud, vNumProducto, vApellPaterno, vCelular, vCorreo,vFecha, vTipoMov 
		FROM localizacte sol, bdinteg:si_cliente cte
		where sol.empresa = cte.empresa
		AND sol.fecha_envio1 = vFechaA
		AND sol.num_cte = cte.numcte
		
		
	IF EXISTS(select cliente from bdimnsj:mnsjr_trx_batch where id_mensaje IN ('SMS_COPPEL','EM_COPPEL') and cliente = vNumCte /*and date(fecha_hora_registro) = vFechaH*/) THEN
		
		LET vExcluidoEnv = vExcluidoEnv + 1;
		CONTINUE FOREACH;		
		
	ELSE
	
	BEGIN WORK;
		IF NVL(vCelular,'') <> '' /*AND NVL(vCorreo,'') = ''*/ THEN
		
		   --let cMensaje = 'Proceso campaña SMS_COPPEL: ' || vvalor;
		   --CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
		   --CALL bdimnsj:"informix".sp_registra_evento (2, 'SMS_COPPEL' , vNumCte, vNumSolicitud,'', 2, vApellPaterno,'','','','',0.0,0.0,0.0,0.0,0.0, vFecha, vFechaProxima  )RETURNING P_COD_RET;
		     CALL bdimnsj:"informix".sp_registra_evento('2','SMS_COPPEL','CPL_SNLCTES',vNumCte,vNumSolicitud,'','2',vApellPaterno,'','','','','','','','','','','',0,0,0,0,0,vFecha,vFechaProxima)RETURNING COD_RET;
		   --CALL "informix".sp_inserta_info_rep_envios (vEmpresa,'SMS',25, vNumSolicitud, vNumCte, vNumProducto, vFecha, vCelular, '','','') returning P_COD_RET;
		
		IF nvl(vTipoMov,'') = 'M' THEN
			LET vSmsEnviadosMix = vSmsEnviadosMix + 1;
			LET vTotalEnv = vTotalEnv + 1;
		ELSE
			LET vSmsEnviadosCop = vSmsEnviadosCop + 1;
			LET vTotalEnv = vTotalEnv + 1;
		END IF	
		--Genera cifras de control
		
		--ELSE 
	---------- CE
		
		ELIF NVL(vCorreo,'') <> '' THEN
		
		   --let cMensaje = 'Proceso campaña EM_COPPEL: ' || vvalor;
		   --CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
		   --CALL bdimnsj:"informix".sp_registra_evento (1, 'EM_COPPEL' , vNumCte, vNumSolicitud,'', 2, vApellPaterno,'','','','',0.0,0.0,0.0,0.0,0.0, vFecha, vFechaProxima  )RETURNING P_COD_RET;
		     CALL bdimnsj:"informix".sp_registra_evento('1','EM_COPPEL','CPL_SNLCTEE',vNumCte,vNumSolicitud,'','2',vApellPaterno,'','','','','','','','','','','',0,0,0,0,0,vFecha,vFechaProxima)RETURNING COD_RET;
		   --CALL "informix".sp_inserta_info_rep_envios (vEmpresa,'EMAIL',1021, vNumSolicitud, vNumCte, vNumProducto, vFecha,  vCorreo, '','','') returning P_COD_RET;
			
		--Genera cifras de control
		IF nvl(vTipoMov,'') = 'M' THEN
			LET vCeEnviadosMix = vCeEnviadosMix + 1;
			LET vTotalEnv = vTotalEnv + 1;
		ELSE
			LET vCeEnviadosCop = vCeEnviadosCop + 1;
			LET vTotalEnv = vTotalEnv + 1;
		END IF	
			
		ELSE
		
		LET vExcluidoEnv = vExcluidoEnv + 1;
		
		END IF
	
	COMMIT WORK;
	
	END IF;
	
	END FOREACH	
	
		/*select date(min(fecha_hora_registro)) 
		into vFechaMin
		from bdimnsj:mnsjr_trx_batch oa where oa.id_mensaje IN ('SMS_COPPEL','EM_COPPEL');*/


-----------REPORTES SMS
		--Número de mensajes para productos coppel:
		/*SELECT count(*)
		INTO vSmsEnviadosCop
		FROM localizacte
		WHERE num_producto = '6500'
		AND fecha_envio1 = vFechaH and num_telefono <> '';*/

		--Número de mensajes para productos mixtas:
		/*SELECT count(*)
		INTO vSmsEnviadosMix
		FROM localizacte
		WHERE num_producto in ('6500')
		--AND fecha_envio1 = vFechaH 
		and num_telefono <> '';*/
		
		--Numero de mantenimientos realizados:
		/*select count(*) 
		INTO vSmsEnviadosMan
		from bdimnsj:mnsjr_trx_batch oa where oa.id_mensaje IN ('SMS_COPPEL')
		and oa.cliente in 
		(select numcte from bdinteg:si_direcciones_actual dir where 
		oa.cliente = dir.numcte and tipo_dir = '1' and vFechaMin <= date(fecha_insert));*/
		
		select count(*) 
			INTO vSmsEnviadosMan
		from bdimnsj:mnsjr_trx_batch oa 
		left outer join bdinteg:si_direcciones_actual dir on (oa.cliente = dir.numcte  and tipo_dir = '1') 
		where oa.id_mensaje IN ('SMS_COPPEL')
		and vFechaMin <= date(fecha_insert);
		
	/*	   let cMensaje = 'Proceso campaña SMS_COPPEL: ' || vSmsEnviadosMix;
		   CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
		   
	 if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if; */
		
		--- TXT
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO /respaldos/' ||to_char(vFechaH,'%Y%m%d')|| '_SMS_OS.txt'|| ' DELIMITER ' || '''|'''  ||
		' select ''Número de SMS para productos coppel'''|| ',' || vSmsEnviadosCop ||' from bdicred:sd_fechas union all ' ||
		' select ''Numero de SMS para productos mixtas''' || ',' || vSmsEnviadosMix ||' from bdicred:sd_fechas union all ' ||
		' select ''Numero de mantenimientos SMS realizados'''|| ',' || vSmsEnviadosMan ||' from bdicred:sd_fechas;' ||
		' " >/respaldos/GeneraReporteSMS_sp_localiza_actualizacteoa.sql';
		SYSTEM cSql;

        LET cSql='chmod a+rwx /respaldos/GeneraReporteSMS_sp_localiza_actualizacteoa.sql';
        System cSql;		

		LET cSql = '';
		LET cSql = 'dbaccess bdicobranza /respaldos/GeneraReporteSMS_sp_localiza_actualizacteoa.sql';
		SYSTEM cSql;		
		
		LET cSql = cSql;
        LET cSql ='rm /respaldos/GeneraReporteSMS_sp_localiza_actualizacteoa.sql';
		
		--- XLS
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO /respaldos/' ||to_char(vFechaH,'%Y%m%d')|| '_SMS_OS.xls'|| ' DELIMITER ' || '''|'''  ||
		' select ''Número de SMS para productos coppel'''|| ',' || vSmsEnviadosCop ||' from bdicred:sd_fechas union all ' ||
		' select ''Numero de SMS para productos mixtas''' || ',' || vSmsEnviadosMix ||' from bdicred:sd_fechas union all ' ||
		' select ''Numero de mantenimientos SMS realizados'''|| ',' || vSmsEnviadosMan ||' from bdicred:sd_fechas;' ||
		' " >/respaldos/GeneraReporteSMS_sp_localiza_actualizacteoaxls.sql';
		SYSTEM cSql;

        LET cSql='chmod a+rwx /respaldos/GeneraReporteSMS_sp_localiza_actualizacteoaxls.sql';
        System cSql;		

		LET cSql = '';
		LET cSql = 'dbaccess bdicobranza /respaldos/GeneraReporteSMS_sp_localiza_actualizacteoaxls.sql';
		SYSTEM cSql;		
		
		LET cSql = cSql;
        LET cSql ='rm /respaldos/GeneraReporteSMS_sp_localiza_actualizacteoaxls.sql';
		
		
-----------REPORTES CE
		--Número de mensajes para productos coppel:
		/*SELECT count(*)
		INTO vCeEnviadosCop
		FROM localizacte
		WHERE num_producto = '6500'
		AND fecha_envio1 = vFechaH and nom_correo <> '';*/

		--Número de mensajes para productos mixtas:
		/*SELECT count(*)
		INTO vCeEnviadosMix
		FROM localizacte
		WHERE num_producto in ('6500')
		--AND fecha_envio1 = vFechaH 
		and nom_correo <> '';*/

		--Número de mantenimientos realizados:		
		/*select count(*) 
		INTO vCeEnviadosMan
		from bdimnsj:mnsjr_trx_batch oa where oa.id_mensaje IN ('EM_COPPEL')
		and oa.cliente in 
		(select numcte from bdinteg:si_direcciones_actual dir where 
		oa.cliente = dir.numcte and tipo_dir = '1' and vFechaMin <= date(fecha_insert));*/
		
		select count(*) 
			INTO vCeEnviadosMan
		from bdimnsj:mnsjr_trx_batch oa 
		left outer join bdinteg:si_direcciones_actual dir on (oa.cliente = dir.numcte  and tipo_dir = '1') 
		where oa.id_mensaje IN ('EM_COPPEL')
		and vFechaMin <= date(fecha_insert);
		
		LET vSmsEnviadosTot = vSmsEnviadosMix + vSmsEnviadosCop;
		LET vCeEnviadosTot  = vCeEnviadosMix  + vCeEnviadosCop;
		
		   let cMensaje = 'Proceso campaña SMS_COPPEL: ' || vSmsEnviadosTot;
		   let cMensaje = trim(cMensaje) ||'   Proceso campaña EM_COPPEL: ' || vCeEnviadosTot;
		   CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
		   
	 if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;		   
	 
		   let cMensaje = 'Total de clientes excluidos: ' || vExcluidoEnv;
		   let cMensaje = trim(cMensaje) ||'   Total de envíos realizados: ' || vTotalEnv;
		   CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
		   
	 if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;
		
		
		--- TXT
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO /respaldos/' ||to_char(vFechaH,'%Y%m%d')|| '_CE_OS.txt'|| ' DELIMITER ' || '''|'''  ||
		' select ''Número de CE para productos coppel'''|| ',' || vCeEnviadosCop ||' from bdicred:sd_fechas union all ' ||
		' select ''Numero de CE para productos mixtas'''|| ',' || vCeEnviadosMix ||' from bdicred:sd_fechas union all ' ||
		' select ''Numero de mantenimientos CE realizados'''|| ',' || vCeEnviadosMan ||' from bdicred:sd_fechas;' ||
		' " >/respaldos/GeneraReporteCE_sp_localiza_actualizacteoa.sql';
		SYSTEM cSql;
		
        LET cSql='chmod a+rwx /respaldos/GeneraReporteCE_sp_localiza_actualizacteoa.sql';
        System cSql;		

		LET cSql = '';
		LET cSql = 'dbaccess bdicobranza /respaldos/GeneraReporteCE_sp_localiza_actualizacteoa.sql';
		SYSTEM cSql;		
		
		LET cSql = cSql;
        LET cSql ='rm /respaldos/GeneraReporteCE_sp_localiza_actualizacteoa.sql';
		
		--- XLS
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO /respaldos/' ||to_char(vFechaH,'%Y%m%d')|| '_CE_OS.xls'|| ' DELIMITER ' || '''|'''  ||
		' select ''Número de CE para productos coppel'''|| ',' || vCeEnviadosCop ||' from bdicred:sd_fechas union all ' ||
		' select ''Numero de CE para productos mixtas'''|| ',' || vCeEnviadosMix ||' from bdicred:sd_fechas union all ' ||
		' select ''Numero de mantenimientos CE realizados'''|| ',' || vCeEnviadosMan ||' from bdicred:sd_fechas;' ||
		' " >/respaldos/GeneraReporteCE_sp_localiza_actualizacteoaxls.sql';
		SYSTEM cSql;
		
        LET cSql='chmod a+rwx /respaldos/GeneraReporteCE_sp_localiza_actualizacteoaxls.sql';
        System cSql;		

		LET cSql = '';
		LET cSql = 'dbaccess bdicobranza /respaldos/GeneraReporteCE_sp_localiza_actualizacteoaxls.sql';
		SYSTEM cSql;		
		
		LET cSql = cSql;
        LET cSql ='rm /respaldos/GeneraReporteCE_sp_localiza_actualizacteoaxls.sql';

--------------
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

    RETURN P_COD_RET,P_MENSAJE;

end;
end procedure;