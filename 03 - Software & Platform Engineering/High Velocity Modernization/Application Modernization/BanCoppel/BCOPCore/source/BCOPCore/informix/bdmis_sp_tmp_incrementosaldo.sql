create PROCEDURE "informix".sp_tmp_incrementosaldo()
RETURNING	CHAR(06) as cod_ret,
			CHAR(80) as mensaje;
			
--variables de retorno
	DEFINE	cod_ret		CHAR(06);
	DEFINE	mensaje		CHAR(80);
	
--DEFINICION DE VARIABLES DE CONTROL DE ERRORES 
	DEFINE  SQL_ERR          INTEGER;   
	DEFINE  ERROR_INFO       VARCHAR(180);	
	DEFINE  ISAM_ERR         INTEGER;
	
--variables de proceso
	DEFINE	vpaso			 INTEGER;
	DEFINE	vfecha			 DATE;
	DEFINE	vsucursal		 CHAR(04);
	DEFINE	vsaldo_dia		 money (18,2);
	DEFINE	vsaldo_ant		 money (18,2);
	DEFINE	vmeta_sdo_dia	 money (18,2);
	DEFINE	vsaldo_anio_ant	 money (18,2);
	DEFINE	vmeta_sdo_mes	 money (18,2);
	DEFINE	vsaldo_mes_ant	 money (18,2);
	DEFINE	vfechamax		 DATE;

--inicializacion
	let cod_ret = '00000';
	let mensaje = 'PROCESO EXITOSO';
	let vpaso 	= 0;	
	
begin			  
		  ON EXCEPTION SET SQL_ERR, ISAM_ERR,ERROR_INFO
			  LET  cod_ret      = 	SQL_ERR;
			  LET  mensaje  = 	ERROR_INFO || ' sp_rcda_incremento_saldo en paso ' || vpaso;	  
			  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
			  select fecha_ant,'F',cod_ret, TRIM(mensaje)  from bdmis:mi_fechas;
			  RETURN cod_ret, mensaje;
		   END EXCEPTION;		

	set isolation to dirty read;
		let vpaso = 1; 
		--meta de incremento en saldo mensual 
			SELECT tp.aniomes ,suc.num_sucursal as sucursal, tp.meta_monto_cap
			FROM mi_sucursalesinfo suc , mi_tiposuc tp
			WHERE tp.aniomes in ('201406','201407') and  suc.tipo_suc = tp.id_tiposuc 
			into temp tmp_meta_sdomes WITH NO LOG;	
								
		--meta de incremento el saldo diario
			let vpaso = 2; 
			SELECT aniomes ,sucursal, (meta_monto_cap / 30.5 ) as meta_sdodia
			FROM tmp_meta_sdomes
			into temp tmp_meta_sdodia WITH NO LOG;	
		let vpaso = 3; 
		--fecha maxima
		SELECT DATE(MAX(fecha))-1 
		into vfechamax
		FROM mi_his_sdo;
		
	let vpaso = 4;	
	foreach
		SELECT	fecha, sucursal, saldo_ant 
		INTO 	vfecha,vsucursal, vsaldo_dia
		FROM mi_sdodia_anterior  
		WHERE fecha  BETWEEN  DATE('06/22/2014') and vfechamax
		
		let vpaso = 5; 
				--saldo del dia anterior
				SELECT saldo_ant
				INTO   vsaldo_ant	
				FROM mi_sdodia_anterior
				WHERE fecha = DATE(vfecha)-1 and sucursal = vsucursal;
				
				-- meta de incremento en saldo diario
				let vpaso = 6; 
				SELECT 	meta_sdodia
				INTO	vmeta_sdo_dia
				FROM	tmp_meta_sdodia
				WHERE 	sucursal = vsucursal AND
						aniomes = year(vfecha)|| lpad(MONTH(vfecha),2,'0') ;
				
				--saldo del año anterior
				let vpaso = 7; 
				SELECT	saldo_ant
				INTO	vsaldo_anio_ant
				FROM	mi_sdoanterior
				WHERE	anio = year(vfecha)- 1 and Sucursal = vsucursal;
				
				--meta de incremento en saldo acumulado				
				let vpaso = 8; 
				SELECT 	meta_monto_cap
				INTO	vmeta_sdo_mes
				FROM	tmp_meta_sdomes
				WHERE 	sucursal = vsucursal AND
						aniomes = year(vfecha)|| lpad(MONTH(vfecha),2,'0') 
					;
				
				--saldo del mes inmediato anterior
				let vpaso = 9; 
				SELECT	saldo_mes
				INTO	vsaldo_mes_ant
				FROM	mi_acumsdo_mes
				WHERE	aniomes = year(vfecha)|| lpad(MONTH(vfecha),2,'0') and Sucursal = vsucursal;
				
				
				--saldo del dia
				let vpaso = 10; 
				INSERT INTO mi_his_sdo (fecha,sucursal,tpo_reg,Incre_SdoDia,Meta_Incre_SdoDia,por_CumpDia, Incr_SdoAcumulado, Meta_IncrSdo_Acum,por_CumpAcum, Sdoafecha,sdo_metafecha)
					VALUES (vfecha,vsucursal,1, (vsaldo_dia - vsaldo_ant ),  vmeta_sdo_dia,  ((vsaldo_dia - vsaldo_ant ) / vmeta_sdo_dia ) * 100, 
							(vsaldo_dia - vsaldo_anio_ant), /*vmeta_sdo_mes*/ vmeta_sdo_dia *  day(vfecha) , ((vsaldo_dia - vsaldo_anio_ant) /  vmeta_sdo_dia *  day(vfecha)) * 100, vsaldo_dia , (vsaldo_anio_ant + vmeta_sdo_dia *  day(vfecha) ));
					
				--saldo acumulado	
				let vpaso = 11; 
				INSERT INTO mi_his_sdo (fecha,sucursal,tpo_reg,Incre_SdoDia,Meta_Incre_SdoDia,por_CumpDia, Incr_SdoAcumulado, Meta_IncrSdo_Acum,por_CumpAcum, Sdoafecha,sdo_metafecha)
					VALUES (vfecha,vsucursal,2,(vsaldo_dia - vsaldo_mes_ant), vmeta_sdo_dia *  day(vfecha), ((vsaldo_dia - vsaldo_mes_ant) / vmeta_sdo_dia *  day(vfecha)	) * 100 ,  
					(vsaldo_dia - vsaldo_anio_ant), /*vmeta_sdo_mes*/ vmeta_sdo_dia *  day(vfecha) , ((vsaldo_dia - vsaldo_anio_ant) /  vmeta_sdo_dia *  day(vfecha)) * 100, vsaldo_dia , (vsaldo_anio_ant + vmeta_sdo_dia *  day(vfecha) ));
								


	
		   
	end foreach   
		   
	RETURN cod_ret, mensaje;	   
		   
END
End PROCEDURE ;