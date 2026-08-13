CREATE PROCEDURE "informix".sp_rep_recuperacion_smsmail() 
RETURNING 
CHAR(6), 
CHAR(80);
--------------------------------------------------------------------------------------------------------------
--execute PROCEDURE "informix".sp_rep_recuperacion_smsmail();

DEFINE cCod_ret             CHAR(6);
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cMensaje1			CHAR(80);
DEFINE cproceso				CHAR(4);
DEFINE cSql          	  	CHAR(1000);
DEFINE vruta				CHAR(100);
DEFINE dFechaFin			DATE;
DEFINE dFechaIni			DATE;
DEFINE cNombre_Archivo		CHAR(100);
DEFINE iTotalDescarga       INTEGER;

--SET DEBUG FILE TO 'sp_rep_recuperacion_smsmail.out';
--TRACE ON;

LET cCod_ret        = '000000';
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = '';
LET cMensaje        = 'El proceso de REPORTE RECUPERACION SMSs Y MAILs se ejecutó correctamente.';
LET cMensaje1       = '';
LET cproceso        = '0121';
LET cSql            = '';
LET vruta			='';
LET dFechaFin		= date(1);
LET dFechaIni		= date(1);
LET cNombre_Archivo = '';
LET iTotalDescarga  = 0;
   
BEGIN        
ON EXCEPTION SET sql_err, isam_err, error_info
    LET cCod_ret = sql_err;
    LET cMensaje = error_info;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '02') RETURNING cCod_ret; 
    LET cCod_ret = sql_err;
    LET cMensaje = error_info;
    RETURN cCod_ret, cMensaje;
END EXCEPTION;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '01') RETURNING cCod_ret; 

IF cCod_ret != '000000' THEN
    LET cMensaje  = 'Error en el llamado al sp_inserta_bitacora_cob.';
    RETURN cCod_ret,cMensaje;
END IF;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO dirty READ;
		
SELECT TRIM(valor_alfabetico)
  INTO vruta
  FROM bdicobranza:cb_param_campania
 WHERE empresa = '001'
   AND tipo_campania = 1
   AND grupo_parametro = 'ARCHIVOS'
   AND num_parametro = 34;

LET dFechaFin = MDY(MONTH(TODAY),1,YEAR(TODAY)) - 1 UNITS DAY;
LET dFechaIni = MDY(MONTH(dFechaFin),1,YEAR(dFechaFin));

--temporal solo para pruebas
--let vruta = '/pisa/ricardo/campanas/';		

--LET dFechaFin = MDY('04','01','2016') - 1 UNITS DAY;
--LET dFechaIni = MDY(MONTH(dFechaFin),1,YEAR(dFechaFin));
--temporal solo para pruebas



----- SMSs Moras    nombre del archivo rep_recuperado_sms_morasmmaaaa.txt
LET cNombre_Archivo = 'rep_recuperado_sms_moras'||to_char(dFechaFin,'%m%Y')||'.txt';
LET cSql = '';
LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || trim(vruta) || cNombre_Archivo || ' DELIMITER ' || '''|'''|| 
		   ' SELECT (select a.id_mensaje from bdicobranza:cb_cat_campania a where a.empresa="001" and a.num_campania = num_campana), numcte,num_credito,ciudad,estado,num_celular,nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo,pago_ven, '||
		   '    pago_req_sms,costo,fecha_envio,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5,pago_ndias,pago_dia1+pago_dia2+pago_dia3+pago_dia4+pago_dia5+pago_ndias '||
		   ' FROM bdicobranza:cb_rep_resultado_sms_hist '|| 
		   ' WHERE empresa = ''001'' '|| 
		   '   AND num_campana IN (15,18,5,6,14,19,21,22,23,11,20) '|| 
		   '   AND fecha_envio >= '''|| dFechaIni || '''  '||
		   '   AND fecha_envio <= '''|| dFechaFin || ''' ; '||
		   ' " > '|| trim(vruta) || 'Reporte_cobranza_recuperado_smsmoras.sql';
SYSTEM cSql;

LET cSql = '';
LET cSql = 'dbaccess bdicobranza ' || trim(vruta) || 'Reporte_cobranza_recuperado_smsmoras.sql';
SYSTEM cSql;

LET cSql = '';
LET cSQL = 'rm ' || trim(vruta) || 'Reporte_cobranza_recuperado_smsmoras.sql ';
SYSTEM cSql;

SELECT count(*)
  INTO iTotalDescarga
  FROM bdicobranza:cb_rep_resultado_sms_hist 
 WHERE empresa = '001'
   AND num_campana IN (15,18,5,6,14,19,21,22,23,11,20) 
   AND fecha_envio >= DATE(dFechaIni)
   AND fecha_envio <= DATE(dFechaFin) ;

LET cMensaje1 = '    Archivo ' || cNombre_Archivo ;
LET cMensaje1 = trim(cMensaje1) || ' generado con ' || iTotalDescarga ;
LET cMensaje1 = trim(cMensaje1) || ' registros ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje1, '02') RETURNING cCod_ret;

----- SMSs Primer Consumo       nombre del archivo rep_recuperado_sms_pconsumommaaaa.txt
LET cNombre_Archivo = 'rep_recuperado_sms_pconsumo'||to_char(dFechaFin,'%m%Y')||'.txt';
LET cSql = '';
LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || trim(vruta) || cNombre_Archivo || ' DELIMITER ' || '''|'''|| 
		   ' SELECT (select a.id_mensaje from bdicobranza:cb_cat_campania a where a.empresa="001" and a.num_campania = num_campana), numcte,num_credito,ciudad,estado,num_celular,nombre1,nombre2,apell_paterno,apell_materno,costo,fecha_envio, '||
		   '    resultado_entrega,resultado_mora,fecha_apertura,fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso '||
		   ' FROM bdicobranza:cb_rep_resultado_sms_hist '|| 
		   ' WHERE empresa = ''001'' '|| 
		   '   AND num_campana = 16 '|| 
		   '   AND fecha_envio >= '''|| dFechaIni || ''' '||
		   '   AND fecha_envio <= '''|| dFechaFin || ''' ; '||
		   ' " > '|| trim(vruta) || 'Reporte_cobranza_recuperado_smspconsumo.sql';
SYSTEM cSql;

LET cSql = '';
LET cSql = 'dbaccess bdicobranza ' || trim(vruta) || 'Reporte_cobranza_recuperado_smspconsumo.sql';
SYSTEM cSql;

LET cSql = '';
LET cSQL = 'rm ' || trim(vruta) || 'Reporte_cobranza_recuperado_smspconsumo.sql ';
SYSTEM cSql;

SELECT count(*)
  INTO iTotalDescarga
  FROM bdicobranza:cb_rep_resultado_sms_hist 
 WHERE empresa = '001'
   AND num_campana = 16 
   AND fecha_envio >= DATE(dFechaIni)
   AND fecha_envio <= DATE(dFechaFin) ;

LET cMensaje1 = '    Archivo ' || cNombre_Archivo ;
LET cMensaje1 = trim(cMensaje1) || ' generado con ' || iTotalDescarga ;
LET cMensaje1 = trim(cMensaje1) || ' registros ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje1, '02') RETURNING cCod_ret;

----- EMAILs Moras  nombre del archivo rep_recuperado_mail_morasmmaaaa.txt
LET cNombre_Archivo = 'rep_recuperado_mail_moras'||to_char(dFechaFin,'%m%Y')||'.txt';
LET cSql = '';
LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || trim(vruta) || cNombre_Archivo || ' DELIMITER ' || '''|'''|| 
		   ' SELECT (select a.id_mensaje from bdicobranza:cb_cat_campania a where a.empresa="001" and a.num_campania = num_campana), numcte,num_credito,ciudad,estado,correo_elec,nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo,pago_ven, '||
		   '    pago_req_email,costo,fecha_envio,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5,pago_ndias,pago_dia1+pago_dia2+pago_dia3+pago_dia4+pago_dia5+pago_ndias '||
		   ' FROM bdicobranza:cb_rep_resultado_mail_hist '|| 
		   ' WHERE empresa = ''001'' '|| 
		   '   AND num_campana IN (1000,1001,1002,1003,1004,1005,1006,1007,1008,1010,1011,1012,1013,1014,1015,1017,1018,1019) '|| 
		   '   AND fecha_envio >= '''|| dFechaIni || '''  '||
		   '   AND fecha_envio <= '''|| dFechaFin || ''' ; '||
		   ' " > '|| trim(vruta) || 'Reporte_cobranza_recuperado_mailmoras.sql';
SYSTEM cSql;

LET cSql = '';
LET cSql = 'dbaccess bdicobranza ' || trim(vruta) || 'Reporte_cobranza_recuperado_mailmoras.sql';
SYSTEM cSql;

LET cSql = '';
LET cSQL = 'rm ' || trim(vruta) || 'Reporte_cobranza_recuperado_mailmoras.sql ';
SYSTEM cSql;

SELECT count(*)
  INTO iTotalDescarga
  FROM bdicobranza:cb_rep_resultado_mail_hist 
 WHERE empresa = '001'
   AND num_campana IN (1000,1001,1002,1003,1004,1005,1006,1007,1008,1010,1015,1011,1012,1013,1014) 
   AND fecha_envio >= DATE(dFechaIni)
   AND fecha_envio <= DATE(dFechaFin) ;

LET cMensaje1 = '    Archivo ' || cNombre_Archivo ;
LET cMensaje1 = trim(cMensaje1) || ' generado con ' || iTotalDescarga ;
LET cMensaje1 = trim(cMensaje1) || ' registros ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje1, '02') RETURNING cCod_ret;
	
----- EMAILs Primer Consumo nombre del archivo rep_recuperado_mail_pconsumommaaaa.txt
LET cNombre_Archivo = 'rep_recuperado_mail_pconsumo'||to_char(dFechaFin,'%m%Y')||'.txt';
LET cSql = '';
LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || trim(vruta) || cNombre_Archivo || ' DELIMITER ' || '''|'''|| 
		   ' SELECT (select a.id_mensaje from bdicobranza:cb_cat_campania a where a.empresa="001" and a.num_campania = num_campana), numcte,num_credito,ciudad,estado,correo_elec,nombre1,nombre2,apell_paterno,apell_materno,costo,fecha_envio, '||
		   '    resultado_entrega,resultado_mora,fecha_apertura,fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso '||
		   ' FROM bdicobranza:cb_rep_resultado_mail_hist '|| 
		   ' WHERE empresa = ''001'' '|| 
		   '   AND num_campana = 1009 '|| 
		   '   AND fecha_envio >= '''|| dFechaIni || '''  '||
		   '   AND fecha_envio <= '''|| dFechaFin || '''; '||
		   ' " > '|| trim(vruta) || 'Reporte_cobranza_recuperado_mailpconsumo.sql';
SYSTEM cSql;

LET cSql = '';
LET cSql = 'dbaccess bdicobranza ' || trim(vruta) || 'Reporte_cobranza_recuperado_mailpconsumo.sql';
SYSTEM cSql;

LET cSql = '';
LET cSQL = 'rm ' || trim(vruta) || 'Reporte_cobranza_recuperado_mailpconsumo.sql ';
SYSTEM cSql;

SELECT count(*)
  INTO iTotalDescarga
  FROM bdicobranza:cb_rep_resultado_mail_hist
 WHERE empresa = '001'
   AND num_campana = 1009
   AND fecha_envio >= DATE(dFechaIni)
   AND fecha_envio <= DATE(dFechaFin) ;

LET cMensaje1 = '    Archivo ' || cNombre_Archivo ;
LET cMensaje1 = trim(cMensaje1) || ' generado con ' || iTotalDescarga ;
LET cMensaje1 = trim(cMensaje1) || ' registros ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje1, '02') RETURNING cCod_ret;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '03') RETURNING cCod_ret; 

IF cCod_ret != '000000' THEN
   LET cMensaje  = 'Error en el llamado al sp_inserta_bitacora_cob.';
   RETURN cCod_ret,cMensaje;
END IF;

RETURN cCod_ret, cMensaje;
END
END PROCEDURE
;