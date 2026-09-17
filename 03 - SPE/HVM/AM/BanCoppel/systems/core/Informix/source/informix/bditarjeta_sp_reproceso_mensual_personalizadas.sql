CREATE PROCEDURE "informix".sp_reproceso_mensual_personalizadas(pFecha DATE)
    RETURNING VARCHAR(5) AS CodRetorno, VARCHAR(60) AS DescRetorno;

    /*VARIABLES PARA RETORNO*/
    DEFINE CodRetorno               	 VARCHAR(5);
    DEFINE DescRetorno              	 VARCHAR(60);

    /*VARIABLES PARA CONTROL DE ERRORES*/
    DEFINE viSqlErr                 	 INTEGER;
    DEFINE viSamErr                      INTEGER;

    /*VARIABLES PARA EL CONTROL DE CONTADORES*/
    DEFINE  vsflagentransaccion     	 CHAR(1);
    DEFINE 	vicontadorregistros 		 INTEGER;
    DEFINE  vicontadorregistros2 		 INTEGER;

    /*VARIABLES PARA OPERACIÃÂN DE FECHAS*/
    DEFINE vfecha_hoy               	 DATE;
    DEFINE vultimo_dia_mes_ante_anterior DATE;
    DEFINE vprimer_dia_mes_ante_anterior DATE; 
    DEFINE vultimo_dia_mes_anterior      DATE;
    DEFINE vprimer_dia_mes_anterior      DATE;
    DEFINE vultimo_dia_mes_actual 		 DATE;
    DEFINE vprimer_dia_mes_actual	     DATE;

    DEFINE vultimo_dia_mes_ante_anterior_hora DATETIME YEAR TO FRACTION(5);
    DEFINE vprimer_dia_mes_ante_anterior_hora DATETIME YEAR TO FRACTION(5);
    DEFINE vultimo_dia_mes_anterior_hora      DATETIME YEAR TO FRACTION(5);
    DEFINE vprimer_dia_mes_anterior_hora      DATETIME YEAR TO FRACTION(5);
    DEFINE vultimo_dia_mes_hora_actual 	      DATETIME YEAR TO FRACTION(5);
    DEFINE vprimer_dia_mes_hora_actual 	      DATETIME YEAR TO FRACTION(5);
    DEFINE vPeriodoActual 			          VARCHAR(6);
    DEFINE vPeriodoAnterior			          VARCHAR(6);
    DEFINE vPeriodoAnteAnterior		          VARCHAR(6);
    DEFINE v_ultimo_Periodo			          VARCHAR(6);
    DEFINE vsql                               char(1150);

    /*VARIABLES PARA FUNCIONALIDAD DE QUERY */
    DEFINE  vsucursal               	INTEGER;
    DEFINE  vdiseno                		INTEGER;
    DEFINE  vtotal                  	INTEGER;
    define  vmaxnumregistros        	INTEGER;
	


    
   /* SET DEBUG FILE TO "/informix/yuliette/sp_reproceso_mensual_personalizadas.out";
    TRACE ON;*/
    

    /*INICIALIZACION VARIABLES*/

    LET 	CodRetorno = '00000';
    LET 	DescRetorno = 'Ejecucion de proceso exitosa.';
    LET     viSqlErr = 0;
    LET 	viSamErr = 0;
    LET 	vsflagentransaccion = 'F';
    LET		vicontadorregistros = 0;
    LET     vicontadorregistros2 = 0;
    LET  	vsucursal = 0;
    LET  	vdiseno    = 0;
    LET  	vtotal     = 0;
    LET     vmaxnumregistros=0;

    LET     vPeriodoActual = '';
    LET     vPeriodoAnterior = '';
    LET     vPeriodoAnteAnterior = '';
    LET     v_ultimo_Periodo = '';  

    
/*OBTENER FECHA PERIODO A REPROCESAR*/
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
let vfecha_hoy = pFecha;

    /*OBTENER EL ULTIMO DÃÂA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÃÂN*/  
    LET vultimo_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_ante_anterior_hora = SUBSTRING(vultimo_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
        
        
    /*OBTENER EL PRIMER DÃÂA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÃÂN*/
    LET vprimer_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
    LET vprimer_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
    LET vprimer_dia_mes_ante_anterior_hora= SUBSTRING(vprimer_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

    /*OBTENER EL ULTIMO DÃÂA DEL MES ANTERIOR A LA EJECUCIÃÂN*/  
    LET vultimo_dia_mes_anterior = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_anterior_hora = SUBSTRING(vultimo_dia_mes_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
         
    /*OBTENER EL PRIMER DÃÂA DEL MES ANTERIOR A LA EJECUCIÃÂN*/
    LET vprimer_dia_mes_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
    LET vprimer_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
    LET vprimer_dia_mes_anterior_hora= SUBSTRING(vprimer_dia_mes_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

    /*OBTENER EL ULTIMO DÃÂA DEL MES ACTUAL*/ 
    LET vultimo_dia_mes_actual = extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_hora_actual= extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_hora_actual= SUBSTRING(vultimo_dia_mes_hora_actual FROM  1 FOR 10) || ' 23:59:59'; 

    /*OBTENER EL PRIMER DÃÂA DEL MES ACTUAL*/ 
    LET vprimer_dia_mes_actual = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY; 
    LET vprimer_dia_mes_hora_actual= extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
    LET vprimer_dia_mes_hora_actual = SUBSTRING(vprimer_dia_mes_hora_actual FROM  1 FOR 10) || ' 00:00:00'; 

    --Periodo a ejecutar debe ser el periodo del mes anterior al mes actual
    LET vPeriodoActual       =  YEAR(vfecha_hoy)|| LPAD(MONTH(vfecha_hoy),2,0);
    LET vPeriodoAnterior     =  YEAR(vprimer_dia_mes_anterior)|| LPAD(MONTH(vprimer_dia_mes_anterior),2,0);
    LET vPeriodoAnteAnterior =  YEAR(vprimer_dia_mes_ante_anterior)|| LPAD(MONTH(vprimer_dia_mes_ante_anterior),2,0);
	
	

BEGIN

	ON EXCEPTION
		SET viSqlErr, viSamErr

       
        LET vsql = '';
        LET vsql = ' rm -f /RESPALDOS/suc_tipo_tarjeta_15.unl';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f /ifxsif01/_reportes/mensual_pers/script_suc_tipo_tarjeta_15.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f err_carga_15.log';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f reg_stock_vta_15.txt';
        SYSTEM vsql;
        
		LET CodRetorno = viSqlErr;
		LET DescRetorno = viSamErr;
		RETURN CodRetorno, DescRetorno;
	END EXCEPTION;
	
	
	
	        /*Elimina el Periodo a Reprocesar*/		
        
		DELETE from "informix".rpt_stock_venta_tp
			WHERE clave_tipotarjeta = '15' 
		AND periodo = vPeriodoAnterior;	
		
	
	
	--Ingresa los registros para las sucursales con existencias de los tipos de tarjetas 15
    LET vsql  = '';
    LET vsql  = 'echo "UNLOAD TO /RESPALDOS/suc_tipo_tarjeta_15.unl ' ||
        " SELECT '"||vPeriodoAnterior||"', tpo.clave_tipotarjeta , suc.clave_sucursal, suc.nombre_sucursal, img.id_diseno, img.descripcion_diseno, 0, 0, 0, 0, 0, 0" ||
        ' FROM intercard:"informix".sucursal_tipotarjeta tpo, intercard:"informix".cat_imagenespredisenadas img, intercard:"informix".sucursal suc ' ||
        ' where tpo.clave_tipotarjeta  = "15" and ' ||
        ' tpo.clave_sucursal = suc.clave_sucursal and  ' ||
        ' (tpo.existencia > 0 or tpo.solicitadas > 0) and img.activa = "1" ' ||
        ' order by tpo.clave_sucursal, img.id_diseno; ' ||
        ' "> /resplogifx/script_suc_tipo_tarjeta_15.sql';
    SYSTEM vsql;
                
    LET vsql = '';
    LET vsql = ' dbaccess bditarjeta /resplogifx/script_suc_tipo_tarjeta_15.sql';
    SYSTEM vsql;
        
    LET vsql = '';
    LET vsql = "echo "||'"'|| "file '"||'/RESPALDOS/'||
                          'suc_tipo_tarjeta_15.unl' || "' delimiter '|' "|| '12'||
                          "; INSERT INTO rpt_stock_venta_tp" || ";"||'"'||' > reg_stock_vta_15.txt';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "dbload -d bditarjeta -c reg_stock_vta_15.txt -l err_carga_15.log -n 1000 -k";
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = ' rm -f /RESPALDOS/suc_tipo_tarjeta_15.unl';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f /resplogifx/script_suc_tipo_tarjeta_15.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f err_carga_15.log';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f reg_stock_vta_15.txt';
    SYSTEM vsql;
    
            
	--*** PROCEDIMIENTO PARA LLENADO DE REPORTE DE TARJETAS TIPO 15 PERSONALIZAS ***
	--Descarga de Asignaciones de Tarjetas 
    select  (year(tjt.fechaasignacion)|| LPAD(month(tjt.fechaasignacion),2,0)) as periodo, lte.clave_sucursal as sucursal, suc.nombre_sucursal as nombre_sucursal, 
       det.id_diseno as imagen, img.descripcion_diseno as descripcion, count(distinct(det.numtarjeta)) as asignacion
       from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, intercard:"informix".cat_imagenespredisenadas img,
            intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt
       where lte.numerolote = det.numlote and
            tjt.numerolote = det.numlote and
            tjt.numerolote = lte.numerolote and
            flt.numerolote = lte.numerolote and
            lte.clave_sucursal = suc.clave_sucursal and
            tjt.numtarjeta = det.numtarjeta and
            img.id_diseno = det.id_diseno and
            lte.clave_tipotarjeta = '15' and
            tjt.fechaasignacion  >= vprimer_dia_mes_anterior_hora and -- MAYO  05/05/2018
            tjt.fechaasignacion  <= vultimo_dia_mes_anterior_hora     -- JUNIO
            group by 1,2,3,4,5
            order by 1,2,3,4,5
    into temp tt_asignacion_15 with no log;
	
	---CreaciÃÂ³n de ÃÂ­ndices en periodo, sucursal e imagen.
    CREATE INDEX "informix".idx_tt_asignacion_15_periodo
        ON "informix".tt_asignacion_15(periodo) ONLINE;
    CREATE INDEX "informix".idx_tt_asignacion_15_sucursal
        ON "informix".tt_asignacion_15(sucursal) ONLINE;
    CREATE INDEX "informix".idx_tt_asignacion_15_imagen
        ON "informix".tt_asignacion_15(imagen) ONLINE;
        
	--IntegraciÃÂ³n de Registros de AsignaciÃÂ³n de Tarjetas a Estructura rpt_stock_venta_tp
    update rpt_stock_venta_tp inv
    set inv.asignacion = (
    select asg.asignacion from tt_asignacion_15 asg
    where inv.periodo = asg.periodo and
          inv.clave_sucursal = asg.sucursal and
          inv.id_diseno = asg.imagen)
          where inv.periodo = (
                    select asg.periodo from tt_asignacion_15 asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
                inv.clave_sucursal = (select asg.sucursal from tt_asignacion_15 asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
                inv.id_diseno = (select asg.imagen from tt_asignacion_15 asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
        inv.clave_tipotarjeta = '15' and
	    inv.periodo = vPeriodoAnterior;
			  
    --8) Descarga de Reposiciones de Tarjetas (que fueron sustituciÃÂ³n)
	--Se busca primero las tarjetas que corresponden a reposiciones

    select (year(tjt.fechaasignacion)|| LPAD(month(tjt.fechaasignacion),2,0)) as periodo, lte.clave_sucursal as clave_sucursal, suc.nombre_sucursal as nombre_sucursal, 
       det.id_diseno as imagen, img.descripcion_diseno as descripcion, count(distinct(det.numtarjeta)) as reposicion
       from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, intercard:"informix".cat_imagenespredisenadas img,
            intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt
       where lte.numerolote = det.numlote and
            tjt.numerolote = det.numlote and
            tjt.numerolote = lte.numerolote and
            flt.numerolote = lte.numerolote and
            lte.clave_sucursal = suc.clave_sucursal and            
            tjt.numtarjeta = det.numtarjeta and
            img.id_diseno = det.id_diseno and
            lte.clave_tipotarjeta = '15' and
            tjt.numtarjeta in(
            select tjt1.numtarjetasustituta
             from intercard:"informix".tarjeta tjt1
             where tjt1.numtarjetasustituta is not null and
                   tjt1.fechaasignacion  >= vprimer_dia_mes_anterior_hora and
	               tjt1.fechaasignacion  <= vultimo_dia_mes_anterior_hora and
                   tjt1.numtarjetasustituta in(
                                   select tjt.numtarjeta
                                   from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, 
								        intercard:"informix".cat_imagenespredisenadas img, intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt
                                   where lte.numerolote = det.numlote and
                                         tjt.numerolote = det.numlote and
										 tjt.numerolote = lte.numerolote and
										 flt.numerolote = lte.numerolote and
										 lte.clave_sucursal = suc.clave_sucursal and            
										 tjt.numtarjeta = det.numtarjeta and
										 img.id_diseno = det.id_diseno and
										 lte.clave_tipotarjeta = '15'))
						 
        group by 1,2,3,4,5
        order by 1,2,3,4,5
        into temp tt_reposicion_15 with no log;
	
    ---CreaciÃÂ³n de ÃÂ­ndices en periodo, sucursal e imagen.
    CREATE INDEX "informix".idx_tt_reposicion_15_periodo
        ON "informix".tt_reposicion_15(periodo) ONLINE;
    CREATE INDEX "informix".idx_tt_reposicion_15_cve_sucursal
        ON "informix".tt_reposicion_15(clave_sucursal) ONLINE;
    CREATE INDEX "informix".idx_tt_reposicion_15_imagen
        ON "informix".tt_reposicion_15(imagen) ONLINE;
    
	--9) IntegraciÃÂ³n de Registros de Reposicion de Tarjetas a Estructura Base

    update rpt_stock_venta_tp inv
    set inv.reposicion = (
    select rep.reposicion from tt_reposicion_15 rep
           where inv.periodo = rep.periodo and
                 inv.clave_sucursal = rep.clave_sucursal and
                 inv.id_diseno = rep.imagen and
		         inv.clave_tipotarjeta = '15')
    where inv.periodo = (
                    select rep.periodo from tt_reposicion_15 rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                    inv.clave_sucursal = (select rep.clave_sucursal from tt_reposicion_15 rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                    inv.id_diseno = (select rep.imagen from tt_reposicion_15 rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                    inv.clave_tipotarjeta = '15'and
	             inv.periodo = vPeriodoAnterior;
	
    --Creamos una copia de rpt_stock_venta_tp para actualizacion de reposiciones / asignaciones para el tipo tarjeta y periodo requerido

    select * from rpt_stock_venta_tp
	         where periodo = vPeriodoAnterior and
			       clave_tipotarjeta = '15'
    into temp tt_reposicion_asignacion_15 with no log;	

    
    CREATE INDEX "informix".idx_tt_repo_asignacion_15_cve_sucursal
        ON "informix".tt_reposicion_asignacion_15(clave_sucursal) ONLINE;
        CREATE INDEX "informix".idx_tt_repo_asignacion_15_id_diseno
        ON "informix".tt_reposicion_asignacion_15(id_diseno) ONLINE;
    CREATE INDEX "informix".idx_tt_repo_asignacion_15_cve_tipotarjeta
        ON "informix".tt_reposicion_asignacion_15(clave_tipotarjeta) ONLINE;
    
	--Ajuste de Registros de Reposicion  = Asignacion = Asignacion - Reposicion

    update rpt_stock_venta_tp inv
    set inv.asignacion = 
                (select rep.asignacion - rep.reposicion  from tt_reposicion_asignacion_15 rep
                 where inv.periodo = rep.periodo and
                       inv.clave_sucursal = rep.clave_sucursal and
                       inv.id_diseno = rep.id_diseno and
                       inv.clave_tipotarjeta = rep.clave_tipotarjeta and
                       inv.clave_tipotarjeta = '15')    
    where inv.periodo = (select rep.periodo from tt_reposicion_asignacion_15 rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '15' ) and
          inv.clave_sucursal = (select rep.clave_sucursal from tt_reposicion_asignacion_15 rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '15') and
          inv.id_diseno = (select rep.id_diseno from tt_reposicion_asignacion_15 rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '15') and
          inv.clave_tipotarjeta = '15' and
		  inv.periodo = vPeriodoAnterior;
		  
        -- Descarga de Ventas de Tarjetas Personalizadas
        select  (year(sol.fechasolicitud)|| LPAD(month(sol.fechasolicitud),2,0)) as periodo, lte.clave_sucursal as sucursal, suc.nombre_sucursal as nombre_sucursal, 
                det.id_diseno as imagen, img.descripcion_diseno as descripcion, count(distinct(det.numtarjeta)) as venta
        from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, intercard:"informix".cat_imagenespredisenadas img,
             intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt, intercard:"informix".solicitudtarjeta sol
        where sol.idsolicitud = det.idsolicitud and
              lte.numerolote = det.numlote and
              tjt.numerolote = det.numlote and
              tjt.numerolote = lte.numerolote and
              flt.numerolote = lte.numerolote and
              lte.clave_sucursal = suc.clave_sucursal and
              tjt.numtarjeta = det.numtarjeta and
              img.id_diseno = det.id_diseno and
			  sol.fechasolicitud >= vprimer_dia_mes_anterior_hora and
			  sol.fechasolicitud <= vultimo_dia_mes_anterior_hora and
              lte.clave_tipotarjeta = '15'
              group by 1,2,3,4,5
              order by 1,2,3,4,5
        into temp tt_venta_15 with no log;

        CREATE INDEX "informix".idx_tt_venta_15_periodo
            ON "informix".tt_venta_15(periodo) ONLINE;
        CREATE INDEX "informix".idx_tt_venta_15_sucursal
            ON "informix".tt_venta_15(sucursal) ONLINE;
        CREATE INDEX "informix".idx_tt_venta_15_imagen
            ON "informix".tt_venta_15(imagen) ONLINE;

        -- Ajuste de Registros de Reposicion  = Asignacion = Asignacion - Reposicion
		update rpt_stock_venta_tp inv
		set inv.venta = 
		   (select vta.venta from tt_venta_15 vta
			where inv.periodo = vta.periodo and
				  inv.clave_sucursal = vta.sucursal and
				  inv.id_diseno = vta.imagen)    
		where inv.periodo = (select vta.periodo from tt_venta_15 vta
								where inv.periodo = vta.periodo and
									  inv.clave_sucursal = vta.sucursal and
									  inv.id_diseno = vta.imagen) and
			  inv.clave_sucursal = (select vta.sucursal from tt_venta_15 vta
								where inv.periodo = vta.periodo and
									  inv.clave_sucursal = vta.sucursal and
									  inv.id_diseno = vta.imagen) and
			  inv.id_diseno = (select vta.imagen from tt_venta_15 vta
								where inv.periodo = vta.periodo and
									  inv.clave_sucursal = vta.sucursal and
									  inv.id_diseno = vta.imagen) and
		inv.clave_tipotarjeta = '15' and
		inv.periodo = vPeriodoAnterior;
		
	SET pdqpriority 0;
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".rpt_stock_venta_tp;  
	 		
		let vsql = ''; 	   
	    let vsql = 'echo "Periodo|TipoTarjeta|Sucursal|Nombre de Sucursal|Imagen|Nombre de la Imagen|Venta|Asignacion|Reposicion">/RESPALDOS/REPpersonalizada_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
		system vsql;
		let vsql = '';
		let vsql = '';
		let vsql=  'echo "UNLOAD TO /RESPALDOS/REPpersonalizada.unl select periodo,clave_tipotarjeta,clave_sucursal,nombre_sucursal,id_diseno,descripcion_diseno,venta,asignacion,reposicion from rpt_stock_venta_tp where clave_tipotarjeta = 15 and periodo = ' 
					|| vPeriodoAnterior || ';">/RESPALDOS/REPpersonalizada.sql'; 
		system vsql;
		let vsql ='';
		let vsql= 'chmod 777 /RESPALDOS/REPpersonalizada.sql';
		system vsql;
		let vsql ='';
		let vsql= 'dbaccess bditarjeta /RESPALDOS/REPpersonalizada.sql';
		system vsql;
		let vsql = '';
		let vsql ='rm /RESPALDOS/REPpersonalizada.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' /RESPALDOS/REPpersonalizada.unl >>/RESPALDOS/REPpersonalizada_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
		system vsql;
		let vsql ='rm /RESPALDOS/REPpersonalizada.unl';
		system vsql;
													 
		RETURN CodRetorno, DescRetorno;
END;
END PROCEDURE

--****************************************************************************************************
--DESCRIPCION: REPORTES MENSUALES STOCK TARJETAS PERSONALIZADAS:
--AUTOR :  YULIETTE PEREZ LOPEZ
--FECHA : 01/08/2018
--BD: BDITARJETA
--****************************************************************************************************
;

CREATE PROCEDURE "informix".sp_guardabitacora_mc(
	psElemento INTEGER,
	psActividad CHAR(150),
	psCve_usuario CHAR(10)
)

	RETURNING CHAR(5) AS Retorno;

	/*
    *****************************************************************************************************
     -- DESCRIPCION:  GUARDA BITACORA  -------------------------------------------------------------------
	-- AUTOR : Victoria QuiÃ±ones  -----------------------------------------------------------------------
	-- FECHA : 01/06/2018  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Conciliacion de MasterCard - Oxxo  --------------------------------
	*****************************************************************************************************
	*/

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE RETORNO*/
	
	DEFINE visqlerr INTEGER ;
	DEFINE vssqlerr CHAR(5);
	DEFINE vsFechaHora DATETIME YEAR TO FRACTION(5);

	/*INICIALIZACION DE VARIABLES*/

	LET visqlerr = 0;
	LET vssqlerr = '00000';
	LET vsFechaHora = CURRENT;

	BEGIN

		ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = visqlerr;
				RETURN vssqlerr;

		END EXCEPTION;

		
		--SET DEBUG FILE TO '/informix/LVRQ/CNC_MC_OXXO/DEBUG/TraceGUARDABITACORA.txt';
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;


		INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_mc (elemento, fecha_hora, actividad, cve_usuario)
		VALUES (psElemento,vsFechaHora,psActividad,psCve_usuario);

		LET vssqlerr = '00000';

	RETURN vssqlerr;


	END

END PROCEDURE
DOCUMENT
'AUTOR: Victoria QuiÃ±ones',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: GUARDA BITACORA.',
'Fecha: 2011/07/01',
'Version: 20110701.1616',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_nombre_archivo_mc ()

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				CHAR (6);
			DEFINE MENSAJE_RPTA			CHAR (80);
			DEFINE vRUTA_OXXO			CHAR (35);
			DEFINE vListArchivo			CHAR (20);
			DEFINE vArchiBat			CHAR (20);
			DEFINE vExecuteSQL 			CHAR (300);
			DEFINE vsNombreArchivo 		CHAR (30);
			DEFINE dsFechaArchivo 		CHAR (10);
			
			

			
			
		BEGIN	
			
			ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			
			  LET CODIGO    = SQL_ERR;
			  LET MENSAJE_RPTA  = ERROR_INFO;

			  
				DELETE FROM BdiTarjeta:"informix".td_cga_nombre_archivo_mc;

			  
			  RETURN CODIGO, MENSAJE_RPTA;
			  
			END EXCEPTION;
			
			--SET DEBUG FILE TO "/ifxsif01/LVRQ/debug/nombre_archivo_mc.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vRUTA_OXXO				= '';
				LET vListArchivo			= 'listado_archivos.txt';
				LET vArchiBat				= 'ls_bat.bat';
				LET vExecuteSQL				= '';
				LET vsNombreArchivo			= '';
				LET dsFechaArchivo			= '';
				
				
			SET ISOLATION TO dirty READ;
			SET LOCK MODE TO WAIT 3;
			
			-- ELIMINA LOS RESGISTROS DE LA TABLA CARGADOS ANTERIORMENTE
				DELETE FROM BdiTarjeta:"informix".td_cga_nombre_archivo_mc;
				
				SELECT rep_aix
				INTO vRUTA_OXXO
				FROM BdiTarjeta:"informix".td_archivo_origentmp_mc
				WHERE archivo_origen='MCO';
				 
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "ls '|| vRUTA_OXXO || '| grep BCPL.T464.D " > ' || vRUTA_OXXO||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL ='';
				LET vExecuteSQL= 'chmod 777 ' || vRUTA_OXXO||'/'||vArchiBat;
				system vExecuteSQL;
				
				
				LET vExecuteSQL = ''; 
                LET vExecuteSQL =  vRUTA_OXXO||'/'||vArchiBat ||'>'|| vRUTA_OXXO||'/'||vListArchivo; 
				SYSTEM vExecuteSQL; 
				 
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm '||vRUTA_OXXO||'/'||vArchiBat;
				system vExecuteSQL;
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "LOAD FROM '|| TRIM(vRUTA_OXXO) || '/' || TRIM(vListArchivo) ||
								 ' INSERT INTO BdiTarjeta:td_cga_nombre_archivo_mc;" > ' || TRIM(vRUTA_OXXO) ||  '/load_nombre_archivo.sql';
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess bditarjeta ' || TRIM(vRUTA_OXXO) ||  '/load_nombre_archivo.sql';
				SYSTEM vExecuteSQL;
			
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm '||vRUTA_OXXO||'/'||vListArchivo;
				system vExecuteSQL;
			
				 
				 
			FOREACH cursor_archivo FOR	
			
				SELECT nom_archivo_mc
					INTO vsNombreArchivo
				FROM BdiTarjeta:"informix".td_cga_nombre_archivo_mc
				
				LET dsFechaArchivo = TRIM(SUBSTR (vsNombreArchivo,12,6));
				LET dsFechaArchivo = SUBSTR(dsFechaArchivo,3,2)||'/'||SUBSTR(dsFechaArchivo,5,2)||'/'||SUBSTR(dsFechaArchivo,1,2);
				LET dsFechaArchivo = dsFechaArchivo::DATE;
				
				--TRACE 'SOY FECHA ARCHIVO '||dsFechaArchivo;
				
				INSERT INTO bditarjeta:"informix".td_archivos_conciliacion_mc(nombrearchivo, archivo_origen, fecha_archivo, num_registros325, monto325,
							fecha_proceso, fecha_hora_transferencia, fecha_hora_ini_proceso, fecha_hora_carga_archivo, fecha_hora_carga_tabla,
							fecha_hora_ini_concilia_reg, fecha_hora_fin_concilia_reg, fecha_hora_fin_proceso, fecha_hora_gen_conadmin, transferencia,
							carga, conadmin, traspaso_historico, num_cargo, monto_cargo, num_abono, monto_abono, proceso) 
				VALUES( vsNombreArchivo, 'MCO', dsFechaArchivo, 0, 0, CURRENT, '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0',
						'1900-01-01 00:00:00.0','1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', 'V', 'F', '', 'F', 0, 0, 0, 0, 'P');
				

			END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO DE MASTER CARD
			
		
			RETURN CODIGO, MENSAJE_RPTA;
		END
	END PROCEDURE;