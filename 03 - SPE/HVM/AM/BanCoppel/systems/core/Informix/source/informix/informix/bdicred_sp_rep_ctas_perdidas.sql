CREATE PROCEDURE "informix".sp_rep_ctas_perdidas()
RETURNING  CHAR(6), CHAR(80);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cMensaje 		                CHAR(80); 
DEFINE cCod_ret                         CHAR(6);
DEFINE cSql                             CHAR(2000);
DEFINE iAnio                            smallint;
DEFINE iMes                             smallint;
DEFINE dFechaUltVenta                   DATE;
DEFINE dfejecucion                      DATE;
DEFINE iNum_dia                         CHAR(02);
DEFINE iNum_mes                         CHAR(02);
DEFINE iNum_anio                        CHAR(04);
DEFINE cfecha                           CHAR(08);

---------------

-- Creado: Bernardo Carlos Báez González
-- Fecha: 30 de septiembre de 2009
-- Crear en BDICRED
-- Se crea con el objetivo de obtener los clientes con 6 o mas 0 pagos Vencidos

-- modificado: Bernardo Carlos Báez González
-- Fecha: 12 de octubre de 2009
-- Crear en BDICRED
-- Se agrega validacion de fecha, ahora se obtendra la fecha de sd_fechas y se obtendran los creditos vendidos el mes anterior a la fecha_hoy de cuando se ejecute el procedimiento


LET cCod_ret = '00000';
LET cMensaje = 'PROCESO EXITOSO';
LET sql_err = 0;
LET dFechaUltVenta = DATE(0);     
LET iNum_dia  ='';
LET iNum_mes  ='';
LET iNum_anio ='';
LET cfecha ='';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

--SET DEBUG FILE TO "/pisa/leo/cuentas_perdidas/sp_rep_ctas_perdidas.out";
--TRACE ON;

--/home/informix/
/*
select year(fecha_hoy), month(fecha_hoy)
into iAnio, iMes
from sd_fechas;
*/

select fecha_hoy
into dfejecucion
from bdicred:sd_fechas;

select max(fecha) 
into dFechaUltVenta
from bdicred:sd_maecred_vendida where num_credito in
(select num_credito from sd_maecred where empresa='001' and num_credito >='600000000000' and status_cred ='CV');
/*
if iMes = 1 then
    LET iMes = 12;
    LET iAnio = iAnio - 1;
ELSE
    LET iMes = iMes - 1;
END IF;
*/

LET iNum_dia  = lpad(day(dfejecucion),2,'0');
LET iNum_mes  = month(dfejecucion);
LET iNum_anio = lpad(year(dfejecucion),4,'0');

let cfecha = iNum_dia || lpad(trim(iNum_mes),2,'0') || iNum_anio;


Let cSql = 'echo "unload to /resplogifx/archivoscartera/Creditos_Vendidos' || cfecha || '.txt select a.fecha, a.num_credito, a.numcte, b.sdo_cap_insoluto, b.mto_venc_trasp + b.monto_vencido, b.cap_tras_no_venci + b.sdo_capital ' ||
--Let cSql = 'echo "unload to /pisa/leo/cuentas_perdidas/Creditos_Vendidos' || cfecha || '.txt select a.fecha, a.num_credito, a.numcte, b.sdo_cap_insoluto, b.mto_venc_trasp, b.cap_tras_no_venci ' ||
' ,(SELECT SUM(NVL(interes_debe,0)-NVL(interes_pagado,0)) FROM  sd_amortiza_credito_vendida WHERE empresa = a.empresa AND num_credito = a.num_credito AND capital_status IN (''' || '2''' || ',''' || '7''' || ',''' ||'6''' || ')) ' ||
' ,(SELECT SUM(NVL(iva_debe,0)-NVL(iva_pagado,0)) FROM  sd_amortiza_credito_vendida WHERE empresa = a.empresa AND num_credito = a.num_credito AND capital_status IN (''' || '2''' || ',''' || '7''' || ',''' ||'6''' || ')) ' ||
' ,(SELECT COUNT(*) FROM  sd_amortiza_credito_vendida WHERE empresa = a.empresa AND num_credito = a.num_credito AND capital_status IN (''' || '2''' || ',''' || '7''' || ',''' ||'6''' || ')) ' ||
' from  sd_maecred_vendida a, sd_maesdos_vendida b ' ||
' where a.empresa = b.empresa and a.num_credito = b.num_credito and a.fecha=b.fecha ' ||
' and a.fecha = '''|| dFechaUltVenta || '''' || 
' and a.empresa = ''001''' ||
' and a.num_credito >= ''600000000000''' ||
--' and a.num_credito in (select num_credito from sd_maecred where empresa=''001'' and num_credito >=''600000000000'' and status_cred =''CV''' ||
' and (SELECT COUNT(*) FROM  sd_amortiza_credito_vendida WHERE empresa = a.empresa AND num_credito = a.num_credito AND capital_status IN (''' || '2''' || ',''' || '7''' || ',''' ||'6''' || ')) >= 6 " > /resplogifx/archivoscartera/corre_vencidos.sql';
--' and (SELECT COUNT(*) FROM  sd_amortiza_credito_vendida WHERE empresa = a.empresa AND num_credito = a.num_credito AND capital_status IN (''' || '2''' || ',''' || '7''' || ')) >= 6 " > /pisa/leo/cuentas_perdidas/corre_vencidos.sql';
SYSTEM SUBSTR(cSql,1,LENGTH(cSql));  


LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/corre_vencidos.sql';
--LET cSql = 'dbaccess bdicred /pisa/leo/cuentas_perdidas/corre_vencidos.sql';
SYSTEM SUBSTR(cSql,1,LENGTH(cSql));  

LET cSql = 'rm /resplogifx/archivoscartera/corre_vencidos.sql';
--LET cSql = 'rm /pisa/leo/cuentas_perdidas/corre_vencidos.sql';
SYSTEM SUBSTR(cSql,1,LENGTH(cSql));  


RETURN cCod_ret, cMensaje;
END;
END PROCEDURE;