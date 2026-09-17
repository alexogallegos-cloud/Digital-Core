CREATE PROCEDURE "informix".sp_obtenerinfctesbpi()
RETURNING VARCHAR(6),VARCHAR(80)

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha           Date;
DEFINE  dFechaAnt        Date;
DEFINE  dFechaIni        Date;
DEFINE  dFechaFin        Date;
DEFINE  cTipo            char;
DEFINE  vtipo            char;
DEFINE vsSQL CHAR(900);
DEFINE vsSQL1 CHAR(200);
DEFINE vsSQL2 CHAR(200);
DEFINE vsSQL3 CHAR(300);
DEFINE vsRepositorio VARCHAR(255);
DEFINE vsNombreDeArchivo VARCHAR(255);
DEFINE vdtFechaHoraActual DATETIME YEAR TO FRACTION (5);
DEFINE vid_operacion CHAR(4) ;

DEFINE vnumcliente CHAR(9); 
DEFINE vservicio SMALLINT;
DEFINE vnum_tran INTEGER;
DEFINE vmonto DECIMAL (14,2);
DEFINE vcuenta_origen CHAR(12);
DEFINE vproducto CHAR(4);
DEFINE vid_operacion2 CHAR (4);
DEFINE vempresa CHAR (3);

DEFINE vcomienza  SMALLINT;
DEFINE vregistros SMALLINT;
DEFINE vcontador SMALLINT;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  insert into bdibpi:bpidocsbitacora values('1002',current,P_COD_RET || ' ' || P_MENSAJE);	   
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

--***************************************************************************/
/* Fecha: 24/Diciembre/2010                                                 */
/* Actividad: Extraer InformaciÃ³n de los registros de los clientes de la    */
/* banca para le generacion de un archivo plano de transacciones            */   
/* Solicito: Ismael Hernandez                                               */
/* Realizado por: Manuel Osuna Valencia                                     */
--***************************************************************************/

   
    LET P_COD_RET = '00000';
    LET P_MENSAJE = 'PROCESO EXITOSO';
	LET vsSQL = '';
	LET vsSQL1 = '';
	LET vsSQL2 = '';
	LET vsSQL3 = '';
	LET vsRepositorio = '';
	LET cTipo = '';
	LET vtipo = '';
	LET vsNombreDeArchivo = '';
	LET vid_operacion='';
	LET vempresa='001';
   
	LET vnumcliente='' ; 
	LET vservicio=0 ;
	LET vnum_tran=0 ;
	LET vmonto='' ;
	LET vcuenta_origen='' ;
	LET vproducto='' ;
	LET vid_operacion2='' ;
	
	LET vcontador = -1;
	LET vcomienza   = -1;
	LET vregistros = 1000;	
	

--    set debug file to "/ifxsif01/scripts/sp_obtenerinfctesbpi.out";
--    Trace on;

     SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;

   
	SELECT valor,date(f_inicio),date(f_fin) into cTipo,dFechaIni,dFechaFin from  bdibpi:bpi_param  where id_param = '15';		
	
	LET cTipo=TRIM(cTipo);	
    IF (cTipo = '1') THEN
	
		select fecha_hoy,pri_dia_mes into dFecha,dFechaAnt  from bdinteg:si_fechas where empresa = vempresa;
	
		Let dFechaIni = DATE(dFechaAnt - Interval(1) month to month);
		Let dFechaFin = DATE(dFechaAnt - Interval(1) day to day);
		
	END IF;	
	
	
	select id_operacion into vid_operacion
	from bdibpi:bpidocsbitacora 
	where date(fecha) = date(current) and id_operacion = '1002' 
	and descripcion like 'FIN DE  PROCESO%'; --
					
   
	IF (vid_operacion='') OR (vid_operacion is NULL) THEN

		
		DELETE FROM bdibpi:bpidocsbitacora where id_operacion = '1002' and date(fecha) = date(current);
		
		FOREACH
	    select rep.id_oper into vservicio
			from bdibpi:bpi_cat_operaciones rep
			WHERE rep.id_oper not in ('1000','1001','1009','1010','1013','1014')			
			
				
			BEGIN WORK;
			
				DELETE FROM bdibpi:bpi_opereportesif WHERE id_operacion=vservicio;
		
			COMMIT WORK;
				
		
		END FOREACH;
		
		BEGIN WORK;
			SELECT FIRST 1 DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO FRACTION(5) INTO vdtFechaHoraActual FROM sysmaster:sysshmvals;
			insert into bdibpi:bpidocsbitacora values('1002',vdtFechaHoraActual,'INICIA PROCESO');
		COMMIT WORK;	
		

		
	   
	   FOREACH
	    select usu.numcliente, bit.id_operacion, count(*), sum(bit.monto_oper), cuenta_origen			
			into vnumcliente, vservicio, vnum_tran, vmonto, vcuenta_origen
		from bdibpi:bpi_bitacora_historial bit,bdibpi:bpi_usuario usu, bdibpi:bpi_cat_operaciones rep
		where usu.id_usuario = bit.id_usuario
		and bit.id_operacion = rep.id_oper
		and DATE(fecha_oper) >= dFechaIni and DATE(fecha_oper) <= dFechaFin			
		and bit.id_operacion not in ('1000','1001','1009','1010','1013','1014')			
		group by 1,2,5

				IF vcomienza = -1 THEN
							BEGIN WORK;
							LET vcontador = 1;
							LET vcomienza = 0;
				END IF;		

			LET vproducto='' ;
			
			IF( vcuenta_origen <> "" AND vcuenta_origen IS NOT NULL) THEN
				
				LET vtipo = vcuenta_origen[1];
				
				IF vtipo = '1' THEN		
					--Buscando el numero de producto en cheques
					select producto into vproducto from bdicheq:sc_maechq sc 
						where sc.empresa = vempresa and sc.cuenta=vcuenta_origen;
				END IF;
				
				IF vtipo = '6' THEN		
					--Buscando el numero de producto en credito
					select num_producto into vproducto from bdicred:sd_maecred sd 
						where sd.empresa = vempresa and  sd.num_credito=vcuenta_origen;
				END IF;
				
			END IF;
					 								
			--Obteniendo informacion a procesar
			insert into bpi_opereportesif (numcliente,id_operacion,num_tran,monto,cuenta_origen, producto) 
			VALUES (vnumcliente, vservicio, vnum_tran, vmonto, vcuenta_origen, vproducto);
			
				IF (vcontador = vregistros) THEN
						COMMIT WORK;
						LET vcontador = 0;							
						LET vcomienza = -1;
				ELSE
						LET vcontador = vcontador + 1 ;						
				END IF;	
		
		END FOREACH;
		
		
		IF (vcontador > 1) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;							
		END IF;		
			
			
			
		--Contabilizar estatus 2007 y 2008
		FOREACH
			select {+INDEX(bdinteg:"informix".si_bpiusuarios idx_freg)}
				servicio, count(*)
			into vservicio, vnum_tran
			from bdinteg:si_bpiusuarios
			where  DATE(f_registro) >= dFechaIni and DATE(f_registro) <= dFechaFin								
			group by 1
			
			IF( vnum_tran = "" OR vnum_tran IS NULL) THEN
				LET vnum_tran = 0;
			END IF;
			
			IF vservicio = '1' THEN
					insert into bdibpi:"informix".bpi_opereportesif (numcliente,id_operacion,num_tran,monto,cuenta_origen) 
					values('','2007',vnum_tran,'','');		
			END IF;	
			IF vservicio = '2' THEN
					insert into bdibpi:"informix".bpi_opereportesif (numcliente,id_operacion,num_tran,monto,cuenta_origen) 
					values('','2008',vnum_tran,'','');		
			END IF;	
		
		
		END FOREACH;
				
		--Contabilizar estatus 2009
		insert into bpi_opereportesif (numcliente,id_operacion,num_tran,monto,cuenta_origen) 
		select '','2009',count(*),'',''
		from bdinteg:si_bpiusuarios
		where DATE(f_registro) >= dFechaIni and DATE(f_registro) <= dFechaFin		
		and id_status = '99';
		
		

		--Bajando la informacion al archivo..
		select valor  into vsRepositorio from  bdibpi:bpi_param  where id_param = '14';	
		LET vsRepositorio=trim(vsRepositorio);
		
	    	LET vsNombreDeArchivo = 'bpi' || CAST(TO_CHAR(dFechaIni, '%m%Y') AS CHAR(6)) || '.txt'; 
        
        IF (cTipo = '1') THEN
	
            LET vsNombreDeArchivo = 'bpi' || CAST(TO_CHAR(CURRENT - 1 units month, '%m%Y') AS CHAR(6)) || '.txt';   
                   	
	END IF;	
		
		--LET vsNombreDeArchivo = 'bpi' || CAST(TO_CHAR(CURRENT, '%m%Y') AS CHAR(6)) || '.txt';   

	    LET vsSQL1 = 'echo " UNLOAD TO ' || vsRepositorio || vsNombreDeArchivo || ' DELIMITER ' || '''|'' '   ;		
		LET vsSQL2 = 'select numcliente,id_operacion,sum(num_tran)::int,sum(monto),nvl(producto,0) from bdibpi:bpi_opereportesif  group by 1,2,5';                       
		LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || '/BajaInfoBpi.sql';             
			
		LET vsSQL1 = TRIM(vsSQL1);
		LET vsSQL2 = TRIM(vsSQL2);
		LET vsSQL3 = TRIM(vsSQL3);
		
		LET vsSQL  = vsSQL1 || vsSQL2 || vsSQL3 ;
					
		IF ( vsSQL <> '' ) THEN 
			SYSTEM vsSQL ;
			LET vsSQL = '' ;
			LET vsSQL = 'dbaccess bdibpi ' || TRIM(vsRepositorio) || '/BajaInfoBpi.sql' ;          					
			SYSTEM vsSQL ;
		END IF ;
				
		
		BEGIN WORK;
			SELECT FIRST 1 DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO FRACTION(5) INTO vdtFechaHoraActual FROM sysmaster:sysshmvals;
			insert into bdibpi:bpidocsbitacora values('1002',vdtFechaHoraActual,'FIN DE  PROCESO');
		COMMIT WORK;	
		
	ELSE 
	
		LET P_COD_RET = '000-1';
		LET P_MENSAJE = 'ESTE PROCESO YA SE EJECUTO EN ESTE DIA';
		
	END IF;
		   
		   
   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;