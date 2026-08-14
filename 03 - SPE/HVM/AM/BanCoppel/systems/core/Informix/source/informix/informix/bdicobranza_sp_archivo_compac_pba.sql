CREATE PROCEDURE "informix".sp_archivo_compac_pba(p_FechaIni DATE, p_FechaFin DATE)
    RETURNING CHAR(6),CHAR(6),CHAR(80);
/*______________________________________________________________________________________________________________________________________________________________________________________	
--Modificado por: Abrham Lopez L.
--Fecha: 08/12/2011
--Descripcion:Consulta para sacar convenios que se realizan el día de hoy y hoy mismo el cliente realiza un pago estos convenios se califican hoy mismo y se van a la cb_compac_his.
--Base de Datos: BDCOBRANZA
_______________________________________________________________________________________________________________________________________________________________________________________*/
 
--Declaración de variables 
	DEFINE cCodRet 			CHAR(6);
	DEFINE isam_cCodRet 	CHAR(6);
	DEFINE cMensaje 		CHAR(80);
	DEFINE sql_err 			INTEGER;
	DEFINE isam_err 		INTEGER;
	DEFINE var_rga 			CHAR(05);
	DEFINE cNombreArchivo 	CHAR(100);
	DEFINE cMesAnio 		CHAR(4);
	DEFINE cEmpresa 		CHAR(3);		
	DEFINE cSql 			CHAR(1024);
	DEFINE p_FechaIni1 		DATE;
	--Inicialización de variables
	LET  var_rga= "";
  BEGIN
    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      LET isam_cCodRet = isam_err;
      RETURN cCodRet,isam_cCodRet,cMensaje;
   END EXCEPTION;
 SET DEBUG FILE TO '/RESPALDOSNEW/sfsalgado/sps/compromisos.out';
 TRACE ON;

   LET cCodRet = "000000";
   LET isam_cCodRet = "000000";
   LET cEmpresa = "";
   LET cMensaje = "EXITO";

   LET cMesAnio = LPAD(TRIM(DAY(p_FechaIni::DATE)::CHAR(2)),2,'0')||LPAD(TRIM(MONTH(p_FechaIni::DATE)::CHAR(2)),2,'0');

   truncate bdicobranza:cb_paso_compac;

   IF p_FechaIni = date(1) AND p_FechaFin = date(1) THEN
      LET cCodRet = "000001";
      LET cMensaje = "AMBAS FECHAS SON INVALIDAS";
   ELSE
      IF p_FechaIni = date(1) THEN
          LET cCodRet = "000002";
          LET cMensaje = "FECHA INVALIDA";
      ELSE
          IF p_FechaIni != date(1) AND p_FechaFin != date(1) THEN
          
            INSERT INTO bdicobranza:cb_paso_compac
            SELECT a.numcliente, d.sucursal,b.num_tarjeta,b.num_credito, a.fecha_compac, a.efectuo_compac,
            a.importe::INTEGER, a.plazo, a.tipo_compac,a.origen,a.sucursal,a.empleado_captura, cr.num_producto
            FROM bdicobranza:cb_compac a 
            INNER JOIN bdicred:sd_maecred cr
            ON  a.empresa = cr.empresa and a.numcuenta = cr.num_credito  
            INNER JOIN bdicred:sd_tarjeta b 
            ON a.empresa = b.empresa AND a.numcliente = b.numcte AND a.numcuenta = b.num_credito and b.tipo_tarjeta = 'T' and status_tar = 'A'
			AND b.secuencia = ( select max(tar.secuencia) from bdicred:sd_tarjeta tar where tar.empresa = b.empresa 
			                      AND tar.numcte = b.numcte AND tar.num_credito = b.num_credito and tar.tipo_tarjeta = 'T' and tar.status_tar = 'A'  )
            INNER JOIN bdinteg:si_cliente c 
            ON  a.numcliente = c.numcte 
            LEFT JOIN bdicred:sd_movhis d 
            ON a.empresa = d.empresa AND a.numcuenta = d.num_credito AND codigo_fun=  "001" AND codigo_ref= 1 
               And d.secuencia In (Select Max(m.secuencia) 
               From bdicred:sd_movhis m 
               Where m.empresa = d.empresa 
               AND m.codigo_fun= "001"
               And m.codigo_ref= 1 
               And m.num_credito= d.num_credito) 
            WHERE a.empresa =  "001" 
			AND a.origen <> 4
              and a.fecha_compac >=  p_FechaIni AND a.fecha_compac <=  p_FechaFin
			  group by 1,2,3,4,5,6,7,8,9,10,11,12,13 ;
			  
	--Sacar convenios que se realizan el día de hoy y hoy mismo el cliente realiza un pago estos convenios se califican hoy mismo y se van a la cb_compac_his.
			INSERT INTO bdicobranza:cb_paso_compac
			SELECT a.numcliente, d.sucursal,b.num_tarjeta,b.num_credito, a.fecha_compac, a.efectuo_compac,
            a.importe::INTEGER, a.plazo, a.tipo_compac,a.origen,a.sucursal,a.empleado_captura, cr.num_producto
            FROM bdicobranza:cb_compac_his a 
            INNER JOIN bdicred:sd_maecred cr
            ON  a.empresa = cr.empresa and a.numcuenta = cr.num_credito  
            INNER JOIN bdicred:sd_tarjeta b 
            ON a.empresa = b.empresa AND a.numcliente = b.numcte AND a.numcuenta = b.num_credito  and b.tipo_tarjeta = 'T' and status_tar = 'A'
			AND b.secuencia = ( select max(tar.secuencia) from bdicred:sd_tarjeta tar where tar.empresa = b.empresa 
			                      AND tar.numcte = b.numcte AND tar.num_credito = b.num_credito and tar.tipo_tarjeta = 'T' and tar.status_tar = 'A'  )
            INNER JOIN bdinteg:si_cliente c 
            ON  a.numcliente = c.numcte 
            LEFT JOIN bdicred:sd_movhis d 
            ON a.empresa = d.empresa AND a.numcuenta = d.num_credito AND codigo_fun=  "001" AND codigo_ref= 1 
               And d.secuencia In (Select Max(m.secuencia) 
               From bdicred:sd_movhis m 
               Where m.empresa = d.empresa 
               AND m.codigo_fun= "001"
               And m.codigo_ref= 1 
               And m.num_credito= d.num_credito) 
            WHERE a.empresa =  "001"  AND a.origen <> 4
              and a.fecha_compac =  a.fecha_insert 
              and a.fecha_compac >=  p_FechaIni AND a.fecha_compac <=  p_FechaFin
			  group by 1,2,3,4,5,6,7,8,9,10,11,12 ,13;
              
            let cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/prueba01.unl''' || ' DELIMITER ' || '''|'''  || 
                       ' SELECT * from bdicobranza:cb_paso_compac;'||
                       ' " > /resplogifx/archivoscartera/ArchivoCompAc.sql';     
             SYSTEM cSql;
             let cSql = '';
             let cSql = 'dbaccess bdinteg /resplogifx/archivoscartera/ArchivoCompAc.sql';
             SYSTEM cSql;
             let cSql = '';
             let cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/prueba02.unl''' || ' DELIMITER ' || '''|'''  || 
                       '  SELECT count(*)::INTEGER, sum(importe::INTEGER) ' ||
                       '  FROM bdicobranza:cb_paso_compac ;'||
                       ' " > /resplogifx/archivoscartera/CifrasCompAc.sql';
     
             SYSTEM cSql;
             let cSql = '';
             let cSql = 'dbaccess bdinteg /resplogifx/archivoscartera/CifrasCompAc.sql';
             SYSTEM cSql;             
          ELSE
            INSERT INTO bdicobranza:cb_paso_compac
            SELECT a.numcliente, d.sucursal,b.num_tarjeta,b.num_credito, a.fecha_compac, a.efectuo_compac,
            a.importe::INTEGER, a.plazo, a.tipo_compac,a.origen,a.sucursal,a.empleado_captura, cr.num_producto
            FROM bdicobranza:cb_compac a 
            INNER JOIN bdicred:sd_maecred cr
            ON  a.empresa = cr.empresa and a.numcuenta = cr.num_credito  
            INNER JOIN bdicred:sd_tarjeta b 
            ON a.empresa = b.empresa AND a.numcliente = b.numcte AND a.numcuenta = b.num_credito and b.tipo_tarjeta = 'T' and b.status_tar = 'A' 
			AND b.secuencia = ( select max(tar.secuencia) from bdicred:sd_tarjeta tar where tar.empresa = b.empresa 
			                      AND tar.numcte = b.numcte AND tar.num_credito = b.num_credito and tar.tipo_tarjeta = 'T' and tar.status_tar = 'A'  )
            INNER JOIN bdinteg:si_cliente c 
            ON  a.numcliente = c.numcte 
            LEFT JOIN bdicred:sd_movhis d 
            ON a.empresa = d.empresa AND a.numcuenta = d.num_credito AND codigo_fun=  "001" AND codigo_ref= 1 
               And d.secuencia In (Select Max(m.secuencia) 
               From bdicred:sd_movhis m 
               Where m.empresa = d.empresa 
               AND m.codigo_fun= "001"
               And m.codigo_ref= 1 
               And m.num_credito= d.num_credito) 
            WHERE a.empresa =  "001" 
			AND a.origen <> 4
              and a.fecha_compac = p_FechaIni
			  group by 1,2,3,4,5,6,7,8,9,10,11,12 ,13;
			  
	--Sacar convenios que se realizan el día de hoy y hoy mismo el cliente realiza un pago estos convenios se califican hoy mismo y se van a la cb_compac_his.  
			INSERT INTO bdicobranza:cb_paso_compac
			SELECT a.numcliente, d.sucursal,b.num_tarjeta,b.num_credito, a.fecha_compac, a.efectuo_compac,
            a.importe::INTEGER, a.plazo, a.tipo_compac,a.origen,a.sucursal,a.empleado_captura, cr.num_producto
            FROM bdicobranza:cb_compac_his a 
            INNER JOIN bdicred:sd_maecred cr
            ON  a.empresa = cr.empresa and a.numcuenta = cr.num_credito  
            INNER JOIN bdicred:sd_tarjeta b 
            ON a.empresa = b.empresa AND a.numcliente = b.numcte AND a.numcuenta = b.num_credito and b.tipo_tarjeta = 'T' and b.status_tar = 'A'  
			AND b.secuencia = ( select max(tar.secuencia) from bdicred:sd_tarjeta tar where tar.empresa = b.empresa 
			                      AND tar.numcte = b.numcte AND tar.num_credito = b.num_credito and tar.tipo_tarjeta = 'T' and tar.status_tar = 'A'  )
            INNER JOIN bdinteg:si_cliente c 
            ON  a.numcliente = c.numcte 
            LEFT JOIN bdicred:sd_movhis d 
            ON a.empresa = d.empresa AND a.numcuenta = d.num_credito AND codigo_fun=  "001" AND codigo_ref= 1 
               And d.secuencia In (Select Max(m.secuencia) 
               From bdicred:sd_movhis m 
               Where m.empresa = d.empresa 
               AND m.codigo_fun= "001"
               And m.codigo_ref= 1 
               And m.num_credito= d.num_credito) 
            WHERE a.empresa =  "001" 
			  AND a.origen <> 4
              and a.fecha_compac =  a.fecha_insert 
              and a.fecha_compac >=  p_FechaIni AND a.fecha_compac <=  p_FechaFin
			  group by 1,2,3,4,5,6,7,8,9,10,11,12,13 ;
              
            let cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/prueba01.unl''' || ' DELIMITER ' || '''|'''  || 
                       ' SELECT * from bdicobranza:cb_paso_compac;'||
                       ' " > /resplogifx/archivoscartera/ArchivoCompAc.sql';     
             SYSTEM cSql;
            let cSql = '';
            let cSql = 'dbaccess bdicobranza /resplogifx/archivoscartera/ArchivoCompAc.sql';
            SYSTEM cSql;
            let cSql = '';
            let cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/prueba02.unl''' || ' DELIMITER ' || '''|'''  || 
                       '  SELECT count(*)::INTEGER, sum(importe::INTEGER) ' ||
                       '  FROM bdicobranza:cb_paso_compac ;'||
                       ' " > /resplogifx/archivoscartera/CifrasCompAc.sql';     
            SYSTEM cSql;
            let cSql = '';
            let cSql = 'dbaccess bdicobranza /resplogifx/archivoscartera/CifrasCompAc.sql';
            SYSTEM cSql;
          END IF;

      END IF;
   END IF;


   LET cNombreArchivo = "";
   let cSql = '';
   LET cNombreArchivo = '/resplogifx/archivoscartera/CompromisosyAcuerdos' ||  cMesAnio ||  YEAR(p_FechaIni::DATE)|| '.txt';
   LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/prueba01.unl > " || cNombreArchivo;
   SYSTEM cSql;

   LET cNombreArchivo = "";
   let cSql = '';
   LET cNombreArchivo = '/resplogifx/archivoscartera/CompromisosyAcuerdosCifras' || cMesAnio || YEAR(p_FechaIni::DATE) || '.txt';
   LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/prueba02.unl > " || cNombreArchivo;
   SYSTEM cSql;

   let cSql = '';
   LET cSql = "rm /resplogifx/archivoscartera/prueba01.unl /resplogifx/archivoscartera/prueba02.unl /resplogifx/archivoscartera/ArchivoCompAc.sql /resplogifx/archivoscartera/CifrasCompAc.sql ";
   SYSTEM cSql;

   RETURN cCodRet,isam_cCodRet,cMensaje;

  END;
END PROCEDURE;