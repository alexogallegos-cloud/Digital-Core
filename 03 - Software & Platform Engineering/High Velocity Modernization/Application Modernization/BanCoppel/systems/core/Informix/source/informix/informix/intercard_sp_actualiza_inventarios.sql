create procedure "informix".sp_actualiza_inventarios(ptipo_opcion varchar(1),pclave_sucursal varchar(5),
pclave_tipotarjeta integer, pnumerolote integer, pexistencia integer, psolicitadas integer)
RETURNING varchar(6), varchar(80);

/* Definición de parametros de llamada
tipo_opcion: Caracter que identifica que tipo de actualización a base de datos se ejecutará
'E': Actualización de existencias de un tipo de tarjeta
   Ejemplo: execute procedure "informix".sp_actualiza_inventarios('E','00297',4,0,0,0);
'S': Actualización de solicitadas de un tipo de tarjeta
   Ejemplo: execute procedure "informix".sp_actualiza_inventarios('S','00297',4,0,0,-1250);
'C': Cancelación de tarjetas por lote de la sucursal (no disponible)
'R': Reporte de Existencias e Inventarios de sucursal
   Ejemplo: execute procedure "informix".sp_actualiza_inventarios('R','00297',4,0,0,0);
   Ejemplo: execute procedure "informix".sp_actualiza_inventarios('R','00297',0,0,0,0);
*/

----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vclave_sucursal         varchar(5);
DEFINE  vclave_tipotarjeta      integer;
DEFINE  vempleado               integer;
DEFINE  vnumerolote             integer;
DEFINE  vexistencia             integer;
DEFINE  vsolicitadas            integer;
DEFINE  vtipo_opcion            varchar(1);
DEFINE  vsql                    char(1550);
Define  vfecha_hoy              date;

------------- control de errores------
BEGIN 
 ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            END IF;
 END EXCEPTION;
	
LET vclave_sucursal = pclave_sucursal;
LET vclave_tipotarjeta = pclave_tipotarjeta;
LET vnumerolote= pnumerolote;
LET vtipo_opcion = ptipo_opcion;
LET vexistencia = pexistencia;
LET vsolicitadas = psolicitadas;

LET vcodret = '0000';
LET  p_mensaje  = '';

/*Set debug file to "/informix/resplogifx/sp_actualiza_inventarios.out";
Trace on;*/

set isolation to dirty read;
select fecha_hoy into vfecha_hoy from bdinteg:si_fechas;

--Limpieza de existencias de una sucursal
IF (vtipo_opcion = 'E' and vclave_sucursal <> '') THEN
      
   let vsql = '';
   let vsql = ' echo "Clave Sucursal|Tipo Tarjeta|Existencia|Solicitadas|">/resplogifx/log_existencia_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
   system vsql; 							
   let vsql = '';
   let vsql = '';
   let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_existencia_sucursal.unl select * from "informix".sucursal_tipotarjeta where clave_sucursal = ' || vclave_sucursal || ' and clave_tipotarjeta = ' || vclave_tipotarjeta|| ';">/resplogifx/log_existencia_sucursal.sql'; 
   system vsql;
   let vsql = '';
   let vsql= 'dbaccess intercard  /resplogifx/log_existencia_sucursal.sql';
   system vsql;
   let vsql ='';
   let vsql ='rm  /resplogifx/log_existencia_sucursal.sql';
   system vsql;
   let vsql ='';
   let vsql = "sed 's/|$//g' /resplogifx/log_existencia_sucursal.unl >>/resplogifx/log_existencia_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
   system vsql;
   let vsql ='rm  /resplogifx/log_existencia_sucursal.unl';
   system vsql;             		

   update "informix".sucursal_tipotarjeta
   set existencia = vexistencia
   where clave_sucursal = vclave_sucursal  and
         clave_tipotarjeta = vclave_tipotarjeta;
    
ELSE 
    IF (vtipo_opcion = 'S' and vclave_sucursal <> '') THEN
     
   let vsql = '';
   let vsql = ' echo "Clave Sucursal|Tipo Tarjeta|Existencia|Solicitadas|">/resplogifx/log_solicitadas_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
   system vsql; 							
   let vsql = '';
   let vsql = '';
   let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_solicitadas_sucursal.unl select * from "informix".sucursal_tipotarjeta where clave_sucursal = ' || vclave_sucursal || ' and clave_tipotarjeta = ' || vclave_tipotarjeta|| ';">/resplogifx/log_solicitadas_sucursal.sql'; 
   system vsql;
   let vsql = '';
   let vsql= 'dbaccess intercard  /resplogifx/log_solicitadas_sucursal.sql';
   system vsql;
   let vsql ='';
   let vsql ='rm  /resplogifx/log_solicitadas_sucursal.sql';
   system vsql;
   let vsql ='';
   let vsql = "sed 's/|$//g' /resplogifx/log_solicitadas_sucursal.unl >>/resplogifx/log_solicitadas_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
   system vsql;
   let vsql ='rm  /resplogifx/log_solicitadas_sucursal.unl';
   system vsql;             		

   update "informix".sucursal_tipotarjeta
   set solicitadas = solicitadas - vsolicitadas
   where clave_sucursal = vclave_sucursal and
         clave_tipotarjeta = vclave_tipotarjeta;

ELSE IF (vtipo_opcion = 'R' and vclave_sucursal <> '') THEN

   IF (vclave_tipotarjeta = 0) THEN
   
      let vsql = '';
      let vsql = ' echo "Clave Sucursal|Tipo Tarjeta|Existencia|Solicitadas|">/resplogifx/log_reporte_tarjetas_resumen_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
      system vsql; 							
      let vsql = '';
      let vsql = '';
      let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl select * from "informix".sucursal_tipotarjeta where clave_sucursal = ' || vclave_sucursal || ';">/resplogifx/log_reporte_tarjetas_resumen_sucursal.sql'; 
      system vsql;
      let vsql = '';
      let vsql= 'dbaccess intercard  /resplogifx/log_reporte_tarjetas_resumen_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_resumen_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql = "sed 's/|$//g' /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl >>/resplogifx/log_reporte_tarjetas_resumen_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
      system vsql;
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl';
      system vsql;             		

      let vsql = '';
      let vsql = ' echo "Tarjeta|Estatus Tarjeta|Producto|FechaExp|Lote|EstatusAsiganda|Guia|FechaGenenracion|Tipo Tarjeta|">/resplogifx/log_reporte_tarjetas_detalle_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
      system vsql; 							
      let vsql = '';
      let vsql = '';
      let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl select tjt.numtarjeta,	tjt.codstatustarjeta,	tjt.codproductotarjeta, tjt.fechaexp, tjt.numerolote, tjt.codstatusasignada, tjt.numeroguia, lte.fechageneracion, lte.clave_tipotarjeta from "informix".lote lte, "informix".tarjeta tjt where lte.clave_sucursal = ' || vclave_sucursal || ' and lte.numerolote = tjt.numerolote and tjt.codstatustarjeta = \"INA\" and tjt.codstatusasignada = \"NOA\" order by lte.clave_tipotarjeta, tjt.numerolote, tjt.numtarjeta;">/resplogifx/log_reporte_tarjetas_detalle_sucursal.sql'; 
      system vsql;
      let vsql = '';
      let vsql= 'dbaccess intercard  /resplogifx/log_reporte_tarjetas_detalle_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_detalle_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql = "sed 's/|$//g' /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl >>/resplogifx/log_reporte_tarjetas_detalle_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
      system vsql;
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl';
      system vsql;   

   ELSE

      let vsql = '';
      let vsql = ' echo "Clave Sucursal|Tipo Tarjeta|Existencia|Solicitadas|">/resplogifx/log_reporte_tarjetas_resumen_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
      system vsql; 							
      let vsql = '';
      let vsql = '';
      let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl select * from "informix".sucursal_tipotarjeta where clave_sucursal = ' || vclave_sucursal || ' and clave_tipotarjeta = ' || vclave_tipotarjeta|| ';">/resplogifx/log_reporte_tarjetas_resumen_sucursal.sql'; 
      system vsql;
      let vsql = '';
      let vsql= 'dbaccess intercard  /resplogifx/log_reporte_tarjetas_resumen_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_resumen_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql = "sed 's/|$//g' /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl >>/resplogifx/log_reporte_tarjetas_resumen_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
      system vsql;
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl';
      system vsql;   
    
      let vsql = '';
      let vsql = ' echo "Tarjeta|Estatus Tarjeta|Producto|FechaExp|Lote|EstatusAsiganda|Guia|FechaGenenracion|Tipo Tarjeta|">/resplogifx/log_reporte_tarjetas_detalle_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
      system vsql; 							
      let vsql = '';
      let vsql = '';
      let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl select tjt.numtarjeta,	tjt.codstatustarjeta,	tjt.codproductotarjeta, tjt.fechaexp, tjt.numerolote, tjt.codstatusasignada, tjt.numeroguia, lte.fechageneracion, lte.clave_tipotarjeta from "informix".lote lte, "informix".tarjeta tjt where lte.clave_sucursal = ' || vclave_sucursal || ' and lte.numerolote = tjt.numerolote and tjt.codstatustarjeta = \"INA\" and tjt.codstatusasignada = \"NOA\" and lte.clave_tipotarjeta = ' || vclave_tipotarjeta || ' order by lte.clave_tipotarjeta, tjt.numerolote, tjt.numtarjeta;">/resplogifx/log_reporte_tarjetas_detalle_sucursal.sql'; 
      system vsql;
      let vsql = '';
      let vsql= 'dbaccess intercard  /resplogifx/log_reporte_tarjetas_detalle_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_detalle_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql = "sed 's/|$//g' /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl >>/resplogifx/log_reporte_tarjetas_detalle_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
      system vsql;
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl';
      system vsql; 

     END IF;

   ELSE IF (vtipo_opcion = '' or vclave_sucursal = '') THEN
           LET vcodret = '0001';
           LET  p_mensaje  = '¡¡¡¡¡Error/La sucursal no puede ser CERO!!!!!!!! ';
           return vcodret, p_mensaje;
         END IF;
    END IF;
  END IF;
END IF;
return vcodret, p_mensaje;
END
END PROCEDURE;