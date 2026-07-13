CREATE PROCEDURE "informix".sp_rcda_repro_saldos()
RETURNING 	CHAR(06) AS cod_ret ,
			CHAR(80) AS mensaje;

			
--VARIABLES DE EETORNO
	DEFINE	cod_ret			 CHAR(06);
	DEFINE	mensaje			 CHAR(80);
	
--DEFINICION DE VARIABLES DE CONTROL DE ERRORES 
	DEFINE  SQL_ERR          INTEGER;   
	DEFINE  ERROR_INFO       VARCHAR(180);	
	DEFINE  ISAM_ERR         INTEGER;
--DEFINICION DE VARIABLES DE PROCESO
	DEFINE	vpaso			 INTEGER;
	DEFINE	dfecha			 DATE;
--definicion de variables de saldo del dia 
	DEFINE	vempresa		 CHAR(03);
	DEFINE	vaniomes		 CHAR(06);
	DEFINE  vaniomes2		 CHAR(06);
	DEFINE	vaniomes_mes_ant CHAR(06);
	DEFINE	vsucursal		 CHAR(04);
	DEFINE	vsaldo_dia		 money(18,2);
--definicion de variables de saldo del dia anterior
	DEFINE  dfecha_da		 DATE;
	DEFINE	vsaldo_ant		 money (18,2);
	DEFINE	vsaldo_anio_ant	 money (18,2);
--definicion de variables de metas de sdos	
	DEFINE	vmeta_sdo_mes	 money (18,2);
	DEFINE	vmeta_sdo_dia	 money (18,2);
	DEFINE	vsaldo_mes_ant	 money (18,2);
	DEFINE	vmeta_sdo_anio	 money (18,2);	
--definicion de variables de retorno de sp mi_sdodia_anterior
	DEFINE  cod_ret_aux		 CHAR(08);
	DEFINE  mensaje_aux		 CHAR(180);	
			
BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR,ERROR_INFO
	  LET  cod_ret      = 	SQL_ERR;
	  LET  mensaje  = 	ERROR_INFO || ' sp_rcda_repro_saldos en paso ' || vpaso;	  
	  RETURN cod_ret, mensaje;
   END EXCEPTION;			
		
	SET ISOLATION TO dirty read;
	let vpaso = 1;
		--meta de incremento en saldo mensual 
			SELECT suc.num_sucursal as sucursal, tp.meta_monto_cap
			FROM mi_sucursalesinfo suc , mi_tiposuc tp
			WHERE aniomes = '201501' and  suc.tipo_suc = tp.id_tiposuc 
			into temp tmp_meta_sdomes WITH NO LOG;	
	
	 LET vaniomes ='201501';
	 let vaniomes_mes_ant ='201412';
	 let vpaso = 2;
	foreach cursor1 WITH HOLD FOR
	SELECT	distinct(fecha)  
	INTO	dfecha
	FROM mi_sdodia_anterior 
	where fecha between '01/01/2015' and '01/04/2015'
	
	let vpaso = 3;
    select empresa ,'201501' as aniomes,sucursal,saldo_ant as saldo_dia
	FROM mi_sdodia_anterior WHERE fecha = dfecha
	into temp tmp_sdosactuales WITH NO LOG;
	
	let dfecha_da = DATE(dfecha)-1;
	------------------------
			
		let vpaso = 4;						
		--meta de incremento el saldo diario
			let vpaso = 5; 
			SELECT sucursal, (meta_monto_cap / 30.5 ) as meta_sdodia
			FROM tmp_meta_sdomes
			into temp tmp_meta_sdodia WITH NO LOG;		
			
			let vpaso = 6; 
		
		-- incremento de saldo del dia
		TRUNCATE TABLE mi_sdosuc;
		let vpaso = 7;
			foreach	cursor1 WITH HOLD FOR		 
				SELECT empresa, aniomes, sucursal, saldo_dia
				INTO   vempresa, vaniomes2, vsucursal, vsaldo_dia	
				FROM	tmp_sdosactuales
				WHERE	aniomes = vaniomes				
				
				let vpaso = 8; 
				--saldo del dia anterior
				SELECT saldo_ant
				INTO   vsaldo_ant	
				FROM mi_sdodia_anterior
				WHERE fecha = dfecha_da and sucursal = vsucursal;		
				
				-- meta de incremento en saldo diario
				let vpaso = 9; 
				SELECT 	meta_sdodia
				INTO	vmeta_sdo_dia
				FROM	tmp_meta_sdodia
				WHERE 	sucursal = vsucursal;
				
				let vpaso = 10; 
				--saldo del año anterior
				SELECT	saldo_ant
				INTO	vsaldo_anio_ant
				FROM	mi_sdoanterior
				WHERE	anio = year(dFecha)- 1 and Sucursal = vsucursal;
				
				--meta de incremento en saldo acumulado				
				/*SELECT 	meta_monto_cap
				INTO	vmeta_sdo_mes
				FROM	tmp_meta_sdomes
				WHERE 	sucursal = vsucursal;*/
				
				let vpaso = 11; 
				--saldo acumulado del anual
				
						let vmeta_sdo_anio = 0;
				
				let vpaso = 12; 
				--saldo del mes inmediato anterior
				SELECT	saldo_mes
				INTO	vsaldo_mes_ant
				FROM	mi_acumsdo_mes
				WHERE	aniomes = vaniomes_mes_ant and Sucursal = vsucursal;
				

				let vpaso = 13; 
				--saldo del dia
				INSERT INTO mi_his_sdo (fecha,sucursal,tpo_reg,Incre_SdoDia,Meta_Incre_SdoDia,por_CumpDia, Incr_SdoAcumulado, Meta_IncrSdo_Acum,por_CumpAcum, Sdoafecha,sdo_metafecha)
					VALUES (dfecha,vsucursal,1, (vsaldo_dia - vsaldo_ant ),  vmeta_sdo_dia,  ((vsaldo_dia - vsaldo_ant ) / vmeta_sdo_dia ) * 100, 
							(vsaldo_dia - vsaldo_anio_ant), /*vmeta_sdo_mes*/ (vmeta_sdo_dia *  day(dFecha)) + vmeta_sdo_anio , ((vsaldo_dia - vsaldo_anio_ant) /  ((vmeta_sdo_dia *  day(dFecha)) + vmeta_sdo_anio)) * 100, vsaldo_dia , (vsaldo_anio_ant + vmeta_sdo_dia *  day(dFecha) ));
					
				let vpaso = 14; 	
				--saldo acumulado	
				INSERT INTO mi_his_sdo (fecha,sucursal,tpo_reg,Incre_SdoDia,Meta_Incre_SdoDia,por_CumpDia, Incr_SdoAcumulado, Meta_IncrSdo_Acum,por_CumpAcum, Sdoafecha,sdo_metafecha)
					VALUES (dfecha,vsucursal,2,(vsaldo_dia - vsaldo_mes_ant), vmeta_sdo_dia *  day(dFecha), ((vsaldo_dia - vsaldo_mes_ant) / (vmeta_sdo_dia *  day(dFecha))) * 100 ,  
					(vsaldo_dia - vsaldo_anio_ant), /*vmeta_sdo_mes*/ (vmeta_sdo_dia *  day(dFecha)) + vmeta_sdo_anio , ((vsaldo_dia - vsaldo_anio_ant) /  ((vmeta_sdo_dia *  day(dFecha)) + vmeta_sdo_anio)) * 100, vsaldo_dia , (vsaldo_anio_ant + vmeta_sdo_dia *  day(dFecha) ));
								
				
			END foreach;
			
		DROP TABLE tmp_sdosactuales;
		DROP TABLE tmp_meta_sdodia;
		
		END foreach;
		
		RETURN '000000','PROCESO EXITOSO';
	
END			
END PROCEDURE;