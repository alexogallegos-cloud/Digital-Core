CREATE PROCEDURE "informix".sp_campana_redlincred()
-- execute procedure "informix".sp_campana_redlincred();
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
DEFINE vCelInvalido		integer;
DEFINE vStatus			char (5);
DEFINE vLineaS			DECIMAL (18,2);
DEFINE vNumTar			char (4);
DEFINE vFechaMax		date;
DEFINE vFechaDia		date;

DEFINE SQL_ERR			INTEGER;
DEFINE ISAM_ERR			INTEGER;
DEFINE ERROR_INFO		VARCHAR(80);
DEFINE P_COD_RET		VARCHAR(6);
DEFINE COD_RET			VARCHAR(6);
DEFINE P_MENSAJE		VARCHAR(80);
DEFINE vproceso			CHAR (4);
DEFINE cMensaje			CHAR(80);
DEFINE cSql				CHAR(2000);
DEFINE vContadorCred	INTEGER;
DEFINE vTotalProc		INTEGER;


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
LET vCelInvalido		= 0;
LET vStatus				= '';
LET vLineaS				= 0;
LET vNumTar				= '';
LET vFechaMax			= '';
LET vFechaDia			= '';

LET SQL_ERR				= 0;
LET ISAM_ERR			= 0;
LET ERROR_INFO			= '';
LET P_COD_RET			= '000000';
LET COD_RET				= '000000';
LET P_MENSAJE			= 'Proceso campaÃ±a TC_REDLIN exitoso.';
LET vproceso			= '0060';
LET cMensaje			= '';
LET cSql				= '';
LET vContadorCred		= 0;
LET vTotalProc			= 0;


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
--        LET P_MENSAJE = ERROR_INFO;
        LET P_MENSAJE = 'Error al ejecutar el proceso. '||vNumSolicitud;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, P_MENSAJE, '02') RETURNING COD_RET;	
		RETURN P_COD_RET,P_MENSAJE;
	END EXCEPTION;

  --Set debug file to "sp_campana_redlincred .out";
  --trace on;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;


	SELECT fecha_hoy
	INTO vFechaH
	FROM bdicred:"informix".sd_fechas;
	
	select max(fecha_insert) FechaMax
		into vFechaMax
	from bdicred:sd_bitacora_redlincred_dirty;	
	
	set lock mode to wait 3;		
    set isolation to dirty read;
	

	FOREACH WITH HOLD

---------- SMS
		SELECT distinct  a.numcte, a.num_credito, cte.apell_paterno, a.fecha_insert
			INTO vNumCte, vNumSolicitud, vApellPaterno, vFecha
		FROM bdicred:"informix".sd_bitacora_redlincred_dirty a
        INNER JOIN bdinteg:"informix".si_cliente cte ON (a.numcte = cte.numcte)
		WHERE a.fecha_insert = vFechaMax
		
		LET vTotalProc = vTotalProc + 1;
		
		SELECT COUNT (*), nvl(telefono,'') num_telefono
			INTO vContadorCred, vCelular
		FROM bdinteg:"informix".si_telefonos_actual 
		WHERE numcte = vNumCte
        AND tipo_tel = 2 AND status_tel = 'A' AND telefono IS NOT NULL
        GROUP BY num_telefono;
		
		IF vContadorCred < 1 THEN
			LET vCelInvalido = vCelInvalido + 1;
			CONTINUE FOREACH;
		END IF;
		
		BEGIN WORK; 
		
		     CALL bdimnsj:"informix".sp_registra_evento('2','PROD_SMS','TC_REDLIN',vNumCte,vNumSolicitud,'','2',vApellPaterno,'','','','','','','','','','',vCelular,'',0,0,0,0,vFechaH,'')RETURNING COD_RET;
			 --CALL bdimnsj:"informix".sp_registra_evento('2','PROD_SMS','TC_REDLIN','000000000',vNumSolicitud,'','1',vApellPaterno,'','','','','','','','',vNumTar,'',vCelular,vLineaS,0,0,0,0,vFechaH,'')RETURNING COD_RET;
			 
			 LET vTotalEnv = vTotalEnv + 1;
			 
		COMMIT WORK;
			 
	END FOREACH;	
	
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/cobranza/Reduccion_Dirty' ||to_char(vFechaH,'%m%Y')|| '.txt'|| ' DELIMITER ' || '''|'''  ||
		' SELECT num_credito, saldo_corte, monto_otorgado_actual, score, monto_reducido, monto_otorgado_nuevo, mensaje FROM bdicred:sd_bitacora_redlincred_dirty where fecha_insert = '|| ''''|| vFechaMax || ''''||' ' ||
		' " >/resplogifx/archivoscartera/cobranza/GeneraReporte_sp_campana_redlincred.sql';
		SYSTEM cSql;
		
        LET cSql='chmod a+rwx /resplogifx/archivoscartera/cobranza/GeneraReporte_sp_campana_redlincred.sql';
        System cSql;		

		LET cSql = '';
		LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/cobranza/GeneraReporte_sp_campana_redlincred.sql';
		SYSTEM cSql;		
		
		LET cSql = cSql;
        LET cSql ='rm /resplogifx/archivoscartera/cobranza/GeneraReporte_sp_campana_redlincred.sql';
		SYSTEM cSql;
		
	
	   LET cMensaje = 'Total de creditos procesados: ' || vTotalProc;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
	   
	   LET cMensaje = 'Total de envÃ­os realizados: ' || vTotalEnv;
	   LET cMensaje = trim(cMensaje) ||' Mensajes no enviados por celular invalido: ' || vCelInvalido;
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
	 
	let P_MENSAJE = trim(P_MENSAJE) || ' Cuentas procesadas: '|| vTotalProc;

    RETURN P_COD_RET,P_MENSAJE;

end;
end procedure;