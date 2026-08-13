CREATE PROCEDURE "informix".sp_efectividad_invitaciones_clientes_a()
returning 
          CHAR(6) as resultado,
          CHAR(100) as mensaje;
		  
	DEFINE cMensajeRet      CHAR(100);
	DEFINE iCodRet          INTEGER;
	DEFINE SCodRet          CHAR(6);
	DEFINE  dtFechaHoy     	DATE;
	DEFINE  dtFechaAnt     	DATE;
	DEFINE  dtFechaRep     	CHAR(8);
	DEFINE  dtFechaIni      DATE;
	DEFINE  cRuta			CHAR(100);
	DEFINE  cNomArchOri 	CHAR(50);
	DEFINE  cNomArchRep 	CHAR(50);
	DEFINE  cSQL            CHAR(4000);
	
	--SET DEBUG FILE TO "/informix/marcov/sp_efectividad_invitaciones_clientes_a.out";
    --TRACE ON; 
	
	
--Inicialización de variables
	LET cMensajeRet = 'El Reporte Efectividad de invitaciones a Clientes A+ en Coppel se realizó correctamente';
	LET iCodRet     = 0;
	LET SCodRet     ='000000';
	LET dtFechaHoy  = DATE(1);
	LET dtFechaAnt  = DATE(1);
	LET dtFechaRep  = '';
	LET dtFechaIni  = DATE(1);
	LET cRuta       = '';
	LET cNomArchOri = '';
	LET cNomArchRep = '';
	LET cSQL        = '';

	
	--BEGIN
	BEGIN
	ON EXCEPTION SET iCodRet
	IF iCodRet != 0 THEN
		LET SCodRet = iCodRet;
		LET cMensajeRet = 'Error en la ejecución del Reporte Efectividad de invitaciones a Clientes A+ en Coppel';
	END IF;
	RETURN SCodRet,cMensajeRet;
	END EXCEPTION;
	
	--Seleccionamos la ruta de donde se tomará el archivo asi como donde se guardará el reporte una vez generado
	SELECT TRIM(valor_alfabetico) INTO cRuta 
	FROM bdicobranza:"informix".cb_param_campania WHERE empresa = '001' and tipo_campania = 50 and grupo_parametro = 'CAT_PROMOS'
	and num_parametro = 2;
	
	--let cRuta = '/informix/marcov/';----PRUEBA	
	
	--Seleccionamos Fecha de hoy
	SELECT NVL(fecha_hoy ,today) 
	INTO dtFechaHoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';	
	
	--Seleccionamos Fecha del cierre mes anterior
	LET dtFechaAnt = mdy(month(dtFechaHoy),1,year(dtFechaHoy)) - 1 units day;
	
	--Seleccionamos Fecha inicial del cierre mes anterior
	LET dtFechaIni = mdy(month(dtFechaHoy),1,year(dtFechaHoy)) - 2 units month;
	
	--Obtenemos Fecha para nombre de archivos
	LET dtFechaRep = year(dtFechaAnt) || lpad(month(dtFechaAnt),2,0) || lpad(day(dtFechaAnt),2,0);
	
	--Armar el nombre del archivo que contiene Archivo Origen que manda Coppel
    LET cNomArchOri = 'ClientesPreAutorizados'|| dtFechaRep ||'.txt';
	    
    --Armar el nombre del archivo que contiene reporte Final
    LET cNomArchRep = 'ClientesEncontradosCoppel'||dtFechaRep ||'.txt';
	
	
    --cargar los datos del archivo a la tabla temporal
    Let  cSQL = 'echo "create temp table creditoscoppel'
				                ||'(numcteref char(20),'
								||'nombre char(60),'
								||'paterno char(60),'
								||'materno char(60),'
								||'fecha char(30),'
								||'sucursal char(40),'
								||'fecha2 char(30)'
								||') WITH NO LOG;'
	||' load from '||TRIM(cRuta) || TRIM(cNomArchOri) ||
     ' insert into creditoscoppel;'
	--Se genera informacion para Reporte efectividad comparando la info de Coppel con la de Bancoppel
	||'set isolation to dirty read;'
	||' UNLOAD TO '||TRIM(cRuta)||'Coppel_Clientes_ATRT.unl' 
	||' select lpad(trim(c.sucursal),4,''0'') sucursal   ,count( num_solicitud),0,0,0'
    ||' from bdinteg:si_cliente a , bdisolic:ss_solicitudes b, creditoscoppel c'
    ||' where a.empresa = ''001'''
    ||' and a.numcte = b.numcte and a.numcte_ref = c.numcteref'
    ||' and b.status_solicitud in ( ''AT'')'
	||' and b.num_producto = ''6001'''
    ||' and b.fecha_insert >= '|| dtFechaIni 
    ||' group by c.sucursal'
    ||' union all'
    ||' select lpad(trim(c.sucursal),4,''0'') sucursal,  0,count( num_solicitud),0,0'
    ||' from bdinteg:si_cliente a , bdisolic:ss_solicitudes b, creditoscoppel c'
    ||' where a.empresa = ''001'''
    ||' and a.numcte = b.numcte and a.numcte_ref = c.numcteref'
    ||' and b.status_solicitud in ( ''RT'')'
    ||' and b.num_producto = ''6001'''
	||' and b.fecha_insert >= ' || dtFechaIni 
    ||' group by c.sucursal'
    ||' union all'
    ||' select lpad(trim(c.sucursal),4,''0'') sucursal, 0, 0,count( num_solicitud),0'
    ||' from bdinteg:si_cliente a , bdisolic:ss_solicitudes b, creditoscoppel c'
    ||' where a.empresa = ''001'''
    ||' and a.numcte = b.numcte and a.numcte_ref = c.numcteref'
    ||' and b.status_solicitud in ( ''AP'')'
    ||' and b.num_producto = ''6001'''
	||' and b.fecha_insert >= '|| dtFechaIni
    ||' group by c.sucursal;'

--se genera información para Reporte efectividad obteniendo el conteo de las invitaciones realizadas por Coppel a los clientes A+	
    ||' select  lpad(trim(sucursal), 4,''0'') sucursal, 0 Solicitudes,0 Rechazadas,0 Autorizadas,count(sucursal) Enviadas'
    ||' from creditosCoppel'
    ||' group by sucursal order by sucursal'
    ||' into temp CtesCoppel WITH NO LOG;'

--guardar la información en la ultima tabla temporal de la que se genererará reporte final
--crear la tabla de temporal de donde se descarga archivo
	||' create temp table Coppel_Clientes ('
								||'sucursal char(4),'
								||'Solicitudes Integer,'
								||'Rechazadas Integer,'
								||'Autorizadas Integer,'
								||'Enviadas Integer ) WITH NO LOG;'

--Insertando información de los totales de las solicitudes aprobadas, canceladas y TDC Entregadas									
    ||' load from '||TRIM(cRuta)||'Coppel_Clientes_ATRT.unl'
    ||' insert into Coppel_Clientes;'
	
--Insertando información del total de invitaciones realizadas por Coppel a Clientes A+								
    ||' insert into Coppel_Clientes'
    ||' select * from  CtesCoppel;'

--Creando tabla temporal ya agrupando la información								
    ||' select  sucursal, sum(Solicitudes) Solicitudes, sum(Rechazadas) Rechazadas, sum(Autorizadas) Autorizadas, sum(Enviadas) Enviadas'
    ||' from Coppel_Clientes'
    ||' group by sucursal order by sucursal'
    ||' into temp Coppel_Clientes_Final WITH NO LOG;'
	
--Actualizando Las Invitaciones no encontradas restando al total de invitaciones por sucursal las solicitudes autorizadas y rechazadas y las TDC entregadas
    ||' update  Coppel_Clientes_Final set Enviadas = Enviadas - ( Solicitudes + Rechazadas + Autorizadas );'

--Actualizando la sucursal rellenando con ceros para que queden de 4 caracteres
    ||' update  Coppel_Clientes_Final set sucursal = lpad(trim(sucursal), 4,''0'');'

--Generando Archivo que contiene reporte de Efectividad
    ||' unload to ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'clientes_a.unl' || ' DELIMITER ' || '''|''' 
	||' select sucursal, Solicitudes::INTEGER, Rechazadas::INTEGER, Autorizadas::INTEGER, case when Enviadas >= 0 then Enviadas else 0 end ::INTEGER'
	||' from  Coppel_Clientes_Final'
	||' order by sucursal;'
	|| '" > ' ||TRIM(cRuta) ||'query.sql';
	System cSQL;
	LET cSQL = "dbaccess bdisolic "||TRIM(cRuta) ||"query.sql";
	System cSQL;
	--quitar el ultimo pipe "|" del archivo MAVL 2015-03-19
	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) ||'clientes_a.unl > '|| TRIM(cruta) || trim(cNomArchRep);
	SYSTEM cSql;
	--borrar archivo .sql
	let cSQL = '';
    let cSQL = "rm " || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'query.sql';
    System cSQL;
	--borrar archivo .unl
	LET cSQL = '';
    LET cSQL = "rm " ||TRIM(cRuta)||'Coppel_Clientes_ATRT.unl ' || TRIM(cRuta) ||'clientes_a.unl';
    SYSTEM cSQL;
	
	 RETURN SCodRet,cMensajeRet;
	 END;
				
END PROCEDURE 
