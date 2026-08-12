CREATE PROCEDURE "informix".sp_reproceso_mensual_stock (pFecha DATE)
    RETURNING VARCHAR(5) AS CodRetorno, VARCHAR(60) AS DescRetorno;

    /*VARIABLES PARA RETORNO*/
    DEFINE CodRetorno               	 VARCHAR(5);
    DEFINE DescRetorno              	 VARCHAR(60);

    /*VARIABLES PARA CONTROL DE ERRORES*/
    DEFINE viSqlErr                 	 INTEGER;
    DEFINE viSamErr                      INTEGER;

    /*VARIABLES PARA EL CONTROL DE CONTADORES*/
    DEFINE  vsflagentransaccion     	 CHAR(1);

    /*VARIABLES PARA OPERACIÓN DE FECHAS*/
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

	 /*   SET DEBUG FILE TO "/informix/yuliette/sp_reproceso_mensual_stock.out";
    TRACE ON;*/
	
    /*INICIALIZACION VARIABLES*/

    LET 	CodRetorno = '00000';
    LET 	DescRetorno = 'Ejecución de proceso exitosa.';
    LET     viSqlErr = 0;
    LET 	viSamErr = 0;
    LET 	vsflagentransaccion = 'F';
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

    /*OBTENER EL ULTIMO DÍA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÓN*/  
    LET vultimo_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_ante_anterior_hora = SUBSTRING(vultimo_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
         
    /*OBTENER EL PRIMER DÍA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÓN*/
    LET vprimer_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
    LET vprimer_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
    LET vprimer_dia_mes_ante_anterior_hora= SUBSTRING(vprimer_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

    /*OBTENER EL ULTIMO DÍA DEL MES ANTERIOR A LA EJECUCIÓN*/  
    LET vultimo_dia_mes_anterior = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_anterior_hora = SUBSTRING(vultimo_dia_mes_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
         
    /*OBTENER EL PRIMER DÍA DEL MES ANTERIOR A LA EJECUCIÓN*/
    LET vprimer_dia_mes_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
    LET vprimer_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
    LET vprimer_dia_mes_anterior_hora= SUBSTRING(vprimer_dia_mes_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

    /*OBTENER EL ULTIMO DÍA DEL MES ACTUAL*/ 
    LET vultimo_dia_mes_actual = extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_hora_actual= extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_hora_actual= SUBSTRING(vultimo_dia_mes_hora_actual FROM  1 FOR 10) || ' 23:59:59'; 

    /*OBTENER EL PRIMER DÍA DEL MES ACTUAL*/ 
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
        LET vsql = ' rm -f /RESPALDOS/suc_tipo_tarjeta.unl';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f /resplogifx/script_suc_tipo_tarjeta.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f err_carga.log';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f reg_stock_vta.txt';
        SYSTEM vsql;
        
        
		LET CodRetorno = viSqlErr;
		LET DescRetorno = viSamErr;
		RETURN CodRetorno, DescRetorno;
	END EXCEPTION;
	
	
       /*Elimina el Periodo a Reprocesar*/		
        Delete "informix".rpt_stock_venta_tp
	where clave_tipotarjeta = '14' and
              periodo = vPeriodoAnterior;		
	
	
	
	
	
	--Ingresa los registros para las sucursales con existencias de los tipos de tarjetas 14 y 15
    LET vsql  = '';    
    LET vsql  = 'echo "UNLOAD TO /RESPALDOS/suc_tipo_tarjeta.unl ' ||
        " SELECT '"||vPeriodoAnterior||"', tpo.clave_tipotarjeta , suc.clave_sucursal, suc.nombre_sucursal, img.id_diseno, img.descripcion_diseno, 0, 0, 0, 0, 0, 0" ||
        ' FROM intercard:"informix".sucursal_tipotarjeta tpo, intercard:"informix".cat_imagenespredisenadas img, intercard:"informix".sucursal suc ' ||
        ' where tpo.clave_tipotarjeta  = "14" and ' ||
        ' tpo.clave_sucursal = suc.clave_sucursal and  ' ||
        ' (tpo.existencia > 0 or tpo.solicitadas > 0) and img.activa = "1" ' ||
        ' order by tpo.clave_sucursal, img.id_diseno; ' ||
        ' "> /resplogifx/script_suc_tipo_tarjeta.sql';
    SYSTEM vsql;
                
    LET vsql = '';
    LET vsql = ' dbaccess bditarjeta /resplogifx/script_suc_tipo_tarjeta.sql';
    SYSTEM vsql;
        
    LET vsql = '';
    LET vsql = "echo "||'"'|| "file '"||'/RESPALDOS/'||
                          'suc_tipo_tarjeta.unl' || "' delimiter '|' "|| '12'||
                          "; INSERT INTO rpt_stock_venta_tp" || ";"||'"'||' > reg_stock_vta.txt';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "dbload -d bditarjeta -c reg_stock_vta.txt -l err_carga.log -n 1000 -k";
    SYSTEM vsql;

    
    LET vsql = '';
    LET vsql = ' rm -f /RESPALDOS/suc_tipo_tarjeta.unl';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f /resplogifx/script_suc_tipo_tarjeta.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f err_carga.log';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f reg_stock_vta.txt';
    SYSTEM vsql;
    
	-- *** PROCEDIMIENTO PARA LLENADO DE REPORTE DE TARJETAS TIPO 14 PERSONALIZAS STOCK ***
	--Descarga los Stock Nuevos de Tarjetas que se recibieron en sucursal durante el mes

    select (year(flt.fecha)|| LPAD(month(flt.fecha),2,0)) as periodo,        
         lte.clave_sucursal as sucursal, suc.nombre_sucursal as nombre_sucursal, 
         det.id_diseno as imagen, img.descripcion_diseno as descripcion, count(det.numtarjeta) as nuevo
    from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, intercard:"informix".cat_imagenespredisenadas img,
         intercard:"informix".flujolote flt
    where lte.numerolote = det.numlote and
         lte.clave_sucursal = suc.clave_sucursal and
         img.id_diseno = det.id_diseno and
         flt.numerolote = lte.numerolote and
         flt.codflujo = 'RES' and 
         flt.fecha >= vprimer_dia_mes_anterior_hora and
         flt.fecha <= vultimo_dia_mes_anterior_hora and
         lte.clave_tipotarjeta = '14'       
    group by 1,2,3,4,5
	into temp tt_stock_nuevo with no log;
	
	---Creación de índices en periodo, sucursal e imagen.
    CREATE INDEX "informix".idx_tt_stock_nuevo_periodo
        ON "informix".tt_stock_nuevo(periodo) ONLINE;
    CREATE INDEX "informix".idx_tt_stock_nuevo_sucursal
        ON "informix".tt_stock_nuevo(sucursal) ONLINE;
    CREATE INDEX "informix".idx_tt_stock_nuevo_imagen
        ON "informix".tt_stock_nuevo(imagen) ONLINE;

	--Integración de Registros de Stock Nuevo a reporte rpt_stock_venta_tp
	update rpt_stock_venta_tp inv
    set inv.stock_nuevo  = (
        select stk.nuevo from tt_stock_nuevo stk
        where inv.periodo = stk.periodo and
              inv.clave_sucursal = stk.sucursal and
              inv.id_diseno = stk.imagen)
    where inv.periodo = (select stk.periodo from tt_stock_nuevo stk
                         where inv.periodo = stk.periodo and
                               inv.clave_sucursal = stk.sucursal and
                               inv.id_diseno = stk.imagen) and
          inv.clave_sucursal = (select stk.sucursal from tt_stock_nuevo stk
                         where inv.periodo = stk.periodo and
                               inv.clave_sucursal = stk.sucursal and
                               inv.id_diseno = stk.imagen) and
          inv.id_diseno = (select stk.imagen from tt_stock_nuevo stk
                         where inv.periodo = stk.periodo and
                               inv.clave_sucursal = stk.sucursal and
                               inv.id_diseno = stk.imagen) and
          inv.clave_tipotarjeta = '14' and
	      inv.periodo = vPeriodoAnterior;
	  
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
            lte.clave_tipotarjeta = '14' and            
            tjt.fechaasignacion  >= vprimer_dia_mes_anterior_hora and
            tjt.fechaasignacion  <= vultimo_dia_mes_anterior_hora
            group by 1,2,3,4,5
            order by 1,2,3,4,5
    INTO temp tt_asignacion with no log;
    
    ---Creación de índices en periodo, sucursal e imagen.
    CREATE INDEX "informix".idx_tt_asignacion_periodo
        ON "informix".tt_asignacion(periodo) ONLINE;
    CREATE INDEX "informix".idx_tt_asignacion_sucursal
        ON "informix".tt_asignacion(sucursal) ONLINE;
    CREATE INDEX "informix".idx_tt_asignacion_imagen
        ON "informix".tt_asignacion(imagen) ONLINE;
    
	--Integracion de Registros de Asignación de Tarjetas a Estructura rpt_stock_venta_tp
	update rpt_stock_venta_tp inv
    set inv.asignacion = (
    select asg.asignacion from tt_asignacion asg
    where inv.periodo = asg.periodo and
          inv.clave_sucursal = asg.sucursal and
          inv.id_diseno = asg.imagen)
                    where inv.periodo = (
                    select asg.periodo from tt_asignacion asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
          inv.clave_sucursal = (select asg.sucursal from tt_asignacion asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
          inv.id_diseno = (select asg.imagen from tt_asignacion asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
         inv.clave_tipotarjeta = '14' and
	     inv.periodo = vPeriodoAnterior;
		  
    --8) Descarga de Reposiciones de Tarjetas (que fueron sustitución)
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
            lte.clave_tipotarjeta = '14' and
            tjt.numtarjeta in(	
								select tjt1.numtarjetasustituta
								from intercard:"informix".tarjeta tjt1
								where tjt1.numtarjetasustituta is not null and                    --*************************************************
								  tjt1.fechaasignacion  >= vprimer_dia_mes_anterior_hora and      --*************************************************
								  tjt1.fechaasignacion  <= vultimo_dia_mes_anterior_hora and
								  tjt1.numtarjetasustituta in(
								  select tjt.numtarjeta
										from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, 
										     intercard:"informix".cat_imagenespredisenadas img,	intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt
										where lte.numerolote = det.numlote and
											tjt.numerolote = det.numlote and
											tjt.numerolote = lte.numerolote and
											flt.numerolote = lte.numerolote and
											lte.clave_sucursal = suc.clave_sucursal and            
											tjt.numtarjeta = det.numtarjeta and
											img.id_diseno = det.id_diseno and
											lte.clave_tipotarjeta = '14'))  
	group by 1,2,3,4,5
    order by 1,2,3,4,5
    into temp tt_reposicion with no log;

    
    CREATE INDEX "informix".idx_tt_reposicion_periodo
        ON "informix".tt_reposicion(periodo) ONLINE;
    CREATE INDEX "informix".idx_tt_reposicion_cve_sucursal
        ON "informix".tt_reposicion(clave_sucursal) ONLINE;    
    CREATE INDEX "informix".idx_tt_reposicion_imagen
        ON "informix".tt_reposicion(imagen) ONLINE;
        
	--Integración de Registros de Reposicion de Tarjetas a Estructura rpt_stock_venta_tp

    update rpt_stock_venta_tp inv
    set inv.reposicion = (
    select rep.reposicion from tt_reposicion rep
         where inv.periodo = rep.periodo and
               inv.clave_sucursal = rep.clave_sucursal and
               inv.id_diseno = rep.imagen)
    where inv.periodo = (
                    select rep.periodo from tt_reposicion rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                 inv.clave_sucursal = (select rep.clave_sucursal from tt_reposicion rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                 inv.id_diseno = (select rep.imagen from tt_reposicion rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                 inv.clave_tipotarjeta = '14' and
	             inv.periodo = vPeriodoAnterior;
			
    --Creamos una copia de rpt_stock_venta_tp para actualizacion de reposiciones / asignaciones para el tipo tarjeta y periodo requerido

    select * from rpt_stock_venta_tp
	         where periodo = vPeriodoAnterior and
			       clave_tipotarjeta = '14' and
				   periodo = vPeriodoAnterior
    into temp tt_reposicion_asignacion with no log;	

    
    CREATE INDEX "informix".idx_tt_reposicion_asig_cve_tipotarjeta
        ON "informix".tt_reposicion_asignacion(clave_tipotarjeta) ONLINE;
    CREATE INDEX "informix".idx_tt_reposicion_asig_cve_sucursal
        ON "informix".tt_reposicion_asignacion(clave_sucursal) ONLINE;    
    CREATE INDEX "informix".idx_tt_reposicion_asig_id_diseno
        ON "informix".tt_reposicion_asignacion(id_diseno) ONLINE;
    
	--Ajuste de Registros de Reposicion  = Asignacion = Asignacion - Reposicion

    update rpt_stock_venta_tp inv
    set inv.asignacion = 
                (select rep.asignacion - rep.reposicion  from tt_reposicion_asignacion rep
                 where inv.periodo = rep.periodo and
                       inv.clave_sucursal = rep.clave_sucursal and
                       inv.id_diseno = rep.id_diseno and
                       inv.clave_tipotarjeta = rep.clave_tipotarjeta and
                       inv.clave_tipotarjeta = '14')    
    where inv.periodo = (select rep.periodo from tt_reposicion_asignacion rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '14' ) and
          inv.clave_sucursal = (select rep.clave_sucursal from tt_reposicion_asignacion rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '14') and
          inv.id_diseno = (select rep.id_diseno from tt_reposicion_asignacion rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '14') and
          inv.clave_tipotarjeta = '14' and
		  inv.periodo = vPeriodoAnterior;

   --Ajuste de Registros de Venta  = Asignacion + Reposicion

    update rpt_stock_venta_tp inv
    set inv.venta = inv.asignacion + inv.reposicion
    where  inv.clave_tipotarjeta = '14' and
	       inv.periodo = vPeriodoAnterior;
		   
    --Se actualiza el inventario inicial del periodo en ejecución VPeriodoAnterior
	select * from rpt_stock_venta_tp
	where periodo = vPeriodoAnteAnterior and
	      clave_tipotarjeta = '14'
    into temp tt_inventario_personalizadas2 with no log;

    update rpt_stock_venta_tp inv
    set inv.stock_inicio = (
    select fin.stock_final from tt_inventario_personalizadas2 fin
           where fin.periodo = vPeriodoAnteAnterior and  --Periodo Anterior        
                 fin.clave_tipotarjeta = '14' and
                 inv.clave_sucursal = fin.clave_sucursal and
	             inv.id_diseno = fin.id_diseno)
    where inv.clave_tipotarjeta = '14' and
          inv.periodo = vPeriodoAnterior and 
          inv.clave_sucursal = (select fin.clave_sucursal from tt_inventario_personalizadas2 fin
                        where fin.periodo = vPeriodoAnteAnterior and --Periodo Anterior
                              inv.clave_sucursal = fin.clave_sucursal and
                              inv.id_diseno = fin.id_diseno and
                              fin.clave_tipotarjeta = '14') and
          inv.id_diseno = (select fin.id_diseno from tt_inventario_personalizadas2 fin
                        where fin.periodo = vPeriodoAnteAnterior and  --Periodo Anterior   ***********************************************
                              inv.clave_sucursal = fin.clave_sucursal and
                              inv.id_diseno = fin.id_diseno and
                              fin.clave_tipotarjeta = '14');
      
    update rpt_stock_venta_tp inv
    set inv.stock_final = inv.stock_inicio + inv.stock_nuevo - inv.venta
    where inv.periodo = vPeriodoAnterior and inv.clave_tipotarjeta = '14'; --Periodo en Ejecución vPeriodoAnterior

    UPDATE STATISTICS MEDIUM FOR TABLE "informix".rpt_stock_venta_tp;  
	 				
		let vsql = ''; 	   
		let vsql = 'echo "Periodo|TipoTarjeta|Sucursal|Nombre de Sucursal|Imagen|Nombre de la Imagen|Stock Inicio|Stock Nuevo|Venta|Asignacion|Reposicion|Stock Final">/RESPALDOS/REPstockimagen_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
		system vsql;
		let vsql = '';
		let vsql = '';
	    let vsql=  'echo "UNLOAD TO /RESPALDOS/REPstockimagen.unl select * from rpt_stock_venta_tp where clave_tipotarjeta = 14 and periodo = ' 
			|| vPeriodoAnterior || ';">/RESPALDOS/REPstockimagen.sql'; 
		system vsql;
		let vsql ='';
		let vsql= 'chmod 777 /RESPALDOS/REPstockimagen.sql';
		system vsql;
		let vsql ='';
		let vsql= 'dbaccess bditarjeta /RESPALDOS/REPstockimagen.sql';
		system vsql;
		let vsql = '';
		let vsql ='rm /RESPALDOS/REPstockimagen.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' /RESPALDOS/REPstockimagen.unl >>/RESPALDOS/REPstockimagen_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
		system vsql;
		let vsql ='rm /RESPALDOS/REPstockimagen.unl';
		system vsql;		
									 	
		RETURN CodRetorno, DescRetorno;
END;

END PROCEDURE
--****************************************************************************************************
--DESCRIPCION: REPORTES MENSUALES STOCK TARJETAS PERSONALIZADAS:
--AUTOR : LUIS ANTONIO GOMEZ SANTIAGO / YULIETTE PEREZ LOPEZ
--FECHA : 14/06/2018
--BD: BDITARJETA
--****************************************************************************************************
;

CREATE PROCEDURE "informix".sp_reportes_mensuales_tp_pbajj()
RETURNING VARCHAR(5) AS CodRetorno, VARCHAR(60) AS DescRetorno;

--****************************************************************************************************
--DESCRIPCION: REPORTES MENSUALES TARJETAS PERSONALIZADAS:
--AUTOR : LUIS ANTONIO GOMEZ SANTIAGO
--MODIFICADO POR: KITZIA MIRLETH IRIBE CASTAÑEDA
--FECHA : 19/06/2018
--FECHA MODIFICACION: 06/08/2019
--BD: BDITARJETA
--****************************************************************************************************


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

/*VARIABLES PARA OPERACIÃ?N DE FECHAS*/
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

DEFINE v_clave_sucursal   varchar(5);			
DEFINE v_nombre_sucursal  varchar(50);
DEFINE v_subbin       	  char(2);
DEFINE v_descripcion      varchar(28);
DEFINE v_no_tarjetas      integer;
DEFINE v_no_txns          integer;
DEFINE v_impote_total     decimal(19,4);
DEFINE v_txns_promedio    decimal(19,4);
DEFINE v_importe_promedio decimal(19,4);

/*
SET DEBUG FILE TO "/resplogifx/sp_reportes_mensuales_tp.out";
TRACE ON;
*/

/*INICIALIZACION VARIABLES*/

LET 	CodRetorno = '00000';
LET 	DescRetorno = 'Ejecucion de proceso exitoso.';
LET     viSqlErr = 0;
LET 	viSamErr = 0;
LET 	vsflagentransaccion = 'F';
LET		vicontadorregistros = 0;
LET     vicontadorregistros2 = 0;	

LET v_clave_sucursal   = '';
LET v_nombre_sucursal  = '';
LET v_subbin       	   = '';
LET v_descripcion      = '';
LET v_no_tarjetas      = 0;
LET v_no_txns          = 0;
LET v_impote_total     = 0.0;
LET v_txns_promedio    = 0.0;
LET v_importe_promedio = 0.0;

LET     vPeriodoActual = '';
LET     vPeriodoAnterior = '';
LET     vPeriodoAnteAnterior = '';
LET     v_ultimo_Periodo = '';  

/*OBTENER FECHA ACTUAL*/

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas WHERE empresa='001';	

/*OBTENER EL ULTIMO DÃA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÃ?N*/  
LET vultimo_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_ante_anterior_hora = SUBSTRING(vultimo_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
	 
/*OBTENER EL PRIMER DÃA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÃ?N*/
LET vprimer_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
LET vprimer_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
LET vprimer_dia_mes_ante_anterior_hora= SUBSTRING(vprimer_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

/*OBTENER EL ULTIMO DÃA DEL MES ANTERIOR A LA EJECUCIÃ?N*/  
LET vultimo_dia_mes_anterior = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_anterior_hora = SUBSTRING(vultimo_dia_mes_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
	 
/*OBTENER EL PRIMER DÃA DEL MES ANTERIOR A LA EJECUCIÃ?N*/
LET vprimer_dia_mes_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
LET vprimer_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
LET vprimer_dia_mes_anterior_hora= SUBSTRING(vprimer_dia_mes_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

/*OBTENER EL ULTIMO DÃA DEL MES ACTUAL*/ 
LET vultimo_dia_mes_actual = extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_hora_actual= extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_hora_actual= SUBSTRING(vultimo_dia_mes_hora_actual FROM  1 FOR 10) || ' 23:59:59'; 

/*OBTENER EL PRIMER DÃA DEL MES ACTUAL*/ 
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
		LET CodRetorno = viSqlErr;
		LET DescRetorno = viSamErr;
		RETURN CodRetorno, DescRetorno;
	END EXCEPTION;	

	--Reporte Stock tipo '14'  
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_stock_venta_tp
	where clave_tipotarjeta = '14';	
	
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00002';
		LET DescRetorno = 'El Reporte Tarjetas Stock ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_reporte_mensual_stock() INTO CodRetorno, DescRetorno;		
	END IF;
	
	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('02', current, CodRetorno, DescRetorno);

	--Reporte Stock tipo '15'  
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_stock_venta_tp
	where clave_tipotarjeta = '15';		
		
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00003';
		LET DescRetorno = 'El Reporte Tarjetas Personalizadas ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_reporte_mensual_personalizadas() INTO CodRetorno, DescRetorno;	 
	END IF;
	
	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('03', current, CodRetorno, DescRetorno);	
	
	--Reporte PenetraciÃ³n Mercado 
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_penetracion_mercado_tp;
		
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00004';
		LET DescRetorno = 'El Reporte PenetraciÃ³n Mercado ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_penetracion_mercado() INTO CodRetorno, DescRetorno;	 
	END IF;
	
	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('04', current, CodRetorno, DescRetorno);	
	
	--Reporte Frecuencia de Uso 
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_frecuencia_uso_tp;
		
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00005';
		LET DescRetorno = 'El Reporte Frecuencia de Uso ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_frecuencia_uso() INTO CodRetorno, DescRetorno; 
	END IF;		

	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('05', current, CodRetorno, DescRetorno);		
			
	RETURN CodRetorno, DescRetorno;
END;
END PROCEDURE;