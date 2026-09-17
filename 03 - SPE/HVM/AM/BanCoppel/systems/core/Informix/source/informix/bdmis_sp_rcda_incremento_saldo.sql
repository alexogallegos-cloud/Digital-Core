create procedure "informix".sp_rcda_incremento_saldo()
	RETURNING char(08) as cod_ret,
			  char(180) as mensaje;
			  
--definicion de variables
	DEFINE  dFechaCorte      Date;
	DEFINE  dFechaAnt        Date;
	DEFINE  dFechaAnioAnt    Date;
	DEFINE  vpaso			 integer;
	DEFINE  dfecha			 date;
	DEFINE  cod_ret			 CHAR(08);
	DEFINE  mensaje			 CHAR(180);
	DEFINE  vmensaje			 CHAR(180);
	DEFINE  iCuantos         INTEGER;
	DEFINE  cVarDataErr      char(120);
	DEFINE  cCodret          char(5);	
--DEFINICION DE VARIABLES DE CONTROL DE ERRORES 
	DEFINE  SQL_ERR          INTEGER;   
	DEFINE  ERROR_INFO       VARCHAR(180);	
	DEFINE  ISAM_ERR         INTEGER;
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
--rango de periodos para meta acumulada anual
	DEFINE	vpini			 CHAR(06);
	DEFINE	vpfin			 CHAR(06);
	define	veje			 CHAR(01);
	
	
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
	
  
			  
			  let vpaso = 0; 
			   

			set isolation to dirty read;
			select fecha_ant into dfecha from mi_fechas;
			
			let dfecha_da = DATE(dfecha)-1;
			let vaniomes = trim( year (dFecha) || lpad(month(dFecha),2,'0'))::integer;
			--rango de periodos para meta acumulada anual
			
			IF MONTH(dfecha) ='1' or MONTH(dfecha) ='01' THEN
					let veje = 'F';
					let vpini = YEAR(dfecha) || '01';
					let vpfin = YEAR(dfecha) || '01';
				ELSE
					let vpini = YEAR(dfecha) || '01';
					let vpfin = YEAR(dfecha) || LPAD( MONTH(dfecha) -1 ,2,'0');
					let veje = 'V';			
			END IF			
			
			if lpad(month(dFecha),2,'0') = '01' THEN
			
					let vaniomes_mes_ant = year(dFecha)- 1 || 12;
			
				ELSE
				
					let vaniomes_mes_ant = trim( year (dFecha) || lpad(month(dFecha)-1,2,'0'))::integer;
			
			END IF
			
			let vpaso = 1; 
			
			if (SELECT count(codigo_error) FROM mi_rcda_cierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
			   return '001','fecha ya procesada';
			end if
			
			--se valida que exista informacion del sdo del ida anterior
			let vpaso = 2; 			
			if (SELECT COUNT(*) FROM mi_sdodia_anterior WHERE fecha = dFecha-1) = 0 then
				EXECUTE PROCEDURE "informix".sp_sdo_dia_ant()
				INTO cod_ret_aux, mensaje_aux;
				IF cod_ret_aux <> '00000000' THEN
					RETURN cod_ret_aux, mensaje_aux;
				END IF
			END IF
			
			let vpaso = 3; 
			/*execute procedure "informix".sp_bitacora_rcda('rcda_sdo_act', 1)
			into cod_ret, vmensaje;
			if trim(cod_ret) <> '000' then
				return cod_ret ,vmensaje;
			end if;	*/
			
			
			
			set isolation to dirty read;
			select empresa, aniomes, sucursal, sum(saldo_dia) as saldo_dia from table (multiset(
			SELECT   '001' as empresa, aniomes, sdo.sucursal, 
								sum(case
											When day(dFecha)  = '01'   then nvl(sdo.capvig1,0)	When day(dFecha)  = '17'   then nvl(sdo.capvig17,0)
											When day(dFecha)  = '02'   then nvl(sdo.capvig2,0)	When day(dFecha)  = '18'   then nvl(sdo.capvig18,0)
											When day(dFecha)  = '03'   then nvl(sdo.capvig3,0)	When day(dFecha)  = '19'   then nvl(sdo.capvig19,0)
											When day(dFecha)  = '04'   then nvl(sdo.capvig4,0)	When day(dFecha)  = '20'   then nvl(sdo.capvig20,0)
											When day(dFecha)  = '05'   then nvl(sdo.capvig5,0)	When day(dFecha)  = '21'   then nvl(sdo.capvig21,0)
											When day(dFecha)  = '06'   then nvl(sdo.capvig6,0)	When day(dFecha)  = '22'   then nvl(sdo.capvig22,0)
											When day(dFecha)  = '07'   then nvl(sdo.capvig7,0)	When day(dFecha)  = '23'   then nvl(sdo.capvig23,0)
											When day(dFecha)  = '08'   then nvl(sdo.capvig8,0)	When day(dFecha)  = '24'   then nvl(sdo.capvig24,0)
											When day(dFecha)  = '09'   then nvl(sdo.capvig9,0)	When day(dFecha)  = '25'   then nvl(sdo.capvig25,0)
											When day(dFecha)  = '10'   then nvl(sdo.capvig10,0)	When day(dFecha)  = '26'  then nvl(sdo.capvig26,0)
											When day(dFecha)  = '11'   then nvl(sdo.capvig11,0)	When day(dFecha)  = '27'  then nvl(sdo.capvig27,0)
											When day(dFecha)  = '12'   then nvl(sdo.capvig12,0)	When day(dFecha)  = '28'  then nvl(sdo.capvig28,0)
											When day(dFecha)  = '13'   then nvl(sdo.capvig13,0)	When day(dFecha)  = '29'  then nvl(sdo.capvig29,0)
											When day(dFecha)  = '14'   then nvl(sdo.capvig14,0)	When day(dFecha)  = '30'  then nvl(sdo.capvig30,0)
											When day(dFecha)  = '15'   then nvl(sdo.capvig15,0)	When day(dFecha)  = '31'  then nvl(sdo.capvig31,0)
											When day(dFecha)  = '16'   then nvl(sdo.capvig16,0)	Else 0 end) as saldo_dia	
						FROM bdicheq:sc_sdodiarioc sdo , bdicheq:sc_maechq mae
						WHERE sdo.aniomes = vaniomes and sdo.sucursal < 8000 and
							  mae.cuenta = sdo.cuenta and
							  mae.producto in ('1100','1400','1500','1700','1900','2000','2200','2300','2500')
							  group by 1,2,3
			union 
					   SELECT '001' as empresa,aniomes ,sucursal, 
											sum(case
											When day(dFecha) = '01'   then nvl(cv_dia1,0)	When day(dFecha) = '17'   then nvl(cv_dia17,0)
											When day(dFecha) = '02'   then nvl(cv_dia2,0)	When day(dFecha) = '18'   then nvl(cv_dia18,0)
											When day(dFecha) = '03'   then nvl(cv_dia3,0)	When day(dFecha) = '19'   then nvl(cv_dia19,0)
											When day(dFecha) = '04'   then nvl(cv_dia4,0)	When day(dFecha) = '20'   then nvl(cv_dia20,0)
											When day(dFecha) = '05'   then nvl(cv_dia5,0)	When day(dFecha) = '21'   then nvl(cv_dia21,0)
											When day(dFecha) = '06'   then nvl(cv_dia6,0)	When day(dFecha) = '22'   then nvl(cv_dia22,0)
											When day(dFecha) = '07'   then nvl(cv_dia7,0)	When day(dFecha) = '23'   then nvl(cv_dia23,0)
											When day(dFecha) = '08'   then nvl(cv_dia8,0)	When day(dFecha) = '24'   then nvl(cv_dia24,0)
											When day(dFecha) = '09'   then nvl(cv_dia9,0)	When day(dFecha) = '25'   then nvl(cv_dia25,0)
											When day(dFecha) = '10'   then nvl(cv_dia10,0)	When day(dFecha) = '26'  then nvl(cv_dia26,0)
											When day(dFecha) = '11'   then nvl(cv_dia11,0)	When day(dFecha) = '27'  then nvl(cv_dia27,0)
											When day(dFecha) = '12'   then nvl(cv_dia12,0)	When day(dFecha) = '28'  then nvl(cv_dia28,0)
											When day(dFecha) = '13'   then nvl(cv_dia13,0)	When day(dFecha) = '29'  then nvl(cv_dia29,0)
											When day(dFecha) = '14'   then nvl(cv_dia14,0)	When day(dFecha) = '30'  then nvl(cv_dia30,0)
											When day(dFecha) = '15'   then nvl(cv_dia15,0)	When day(dFecha) = '31'  then nvl(cv_dia31,0)
											When day(dFecha) = '16'   then nvl(cv_dia16,0)	Else 0 end) as saldo_dia	
					   FROM bdinvers:sv_provdia 
					   WHERE aniomes = vaniomes
					   group by 1,2,3
			)) group by 1,2,3
			into temp tmp_sdosactuales WITH NO LOG;
			
			/*execute procedure "informix".sp_bitacora_rcda('rcda_sdo_act', 2)
			into cod_ret, vmensaje;
			if trim(cod_ret) <> '000' then
				return cod_ret ,vmensaje;
			end if;	*/
		--meta de incremento en saldo anual 		
		

		
		 IF veje = 'V' THEN
			SELECT suc.num_sucursal as sucursal, sum( tp.meta_monto_cap) as meta_monto_cap
			FROM mi_sucursalesinfo suc , mi_tiposuc tp
			WHERE (aniomes between vpini and vpfin) and suc.tipo_suc = tp.id_tiposuc group by 1
			into temp tmp_meta_sdoanio WITH NO LOG;
		END IF	
			
			let vpaso = 4; 
		--meta de incremento en saldo mensual 
			SELECT suc.num_sucursal as sucursal, tp.meta_monto_cap
			FROM mi_sucursalesinfo suc , mi_tiposuc tp
			WHERE aniomes = vaniomes and  suc.tipo_suc = tp.id_tiposuc 
			into temp tmp_meta_sdomes WITH NO LOG;				
								
		--meta de incremento el saldo diario
			let vpaso = 5; 
			SELECT sucursal, (meta_monto_cap / 30.5 ) as meta_sdodia
			FROM tmp_meta_sdomes
			into temp tmp_meta_sdodia WITH NO LOG;		
			
			let vpaso = 6; 
		-- incremento de saldo del dia
		TRUNCATE TABLE mi_sdosuc;
		let vpaso = 7;
			foreach			 
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
				IF veje = 'V' THEN					
						SELECT 	meta_monto_cap
						INTO	vmeta_sdo_anio
						FROM	tmp_meta_sdoanio
						WHERE 	sucursal = vsucursal;	
						let vsucursal = vsucursal;	
						let vmeta_sdo_anio = vmeta_sdo_anio;
						
					ELSE
						let vmeta_sdo_anio = 0;
				END IF
				
				let vpaso = 12; 
				--saldo del mes inmediato anterior
				SELECT	saldo_mes
				INTO	vsaldo_mes_ant
				FROM	mi_acumsdo_mes
				WHERE	aniomes = vaniomes_mes_ant and Sucursal = vsucursal;
				

				let vpaso = 13; 
				--saldo del dia
				INSERT INTO mi_sdosuc (fecha,sucursal,tpo_reg,Incre_SdoDia,Meta_Incre_SdoDia,por_CumpDia, Incr_SdoAcumulado, Meta_IncrSdo_Acum,por_CumpAcum, Sdoafecha,sdo_metafecha)
					VALUES (dfecha,vsucursal,1, (vsaldo_dia - vsaldo_ant ),  vmeta_sdo_dia,  ((vsaldo_dia - vsaldo_ant ) / vmeta_sdo_dia ) * 100, 
							(vsaldo_dia - vsaldo_anio_ant), /*vmeta_sdo_mes*/ (vmeta_sdo_dia *  day(dFecha)) + vmeta_sdo_anio , ((vsaldo_dia - vsaldo_anio_ant) /  ((vmeta_sdo_dia *  day(dFecha)) + vmeta_sdo_anio)) * 100, vsaldo_dia , (vsaldo_anio_ant + vmeta_sdo_dia *  day(dFecha) ));
					
				let vpaso = 14; 	
				--saldo acumulado	
				INSERT INTO mi_sdosuc (fecha,sucursal,tpo_reg,Incre_SdoDia,Meta_Incre_SdoDia,por_CumpDia, Incr_SdoAcumulado, Meta_IncrSdo_Acum,por_CumpAcum, Sdoafecha,sdo_metafecha)
					VALUES (dfecha,vsucursal,2,(vsaldo_dia - vsaldo_mes_ant), vmeta_sdo_dia *  day(dFecha), ((vsaldo_dia - vsaldo_mes_ant) / (vmeta_sdo_dia *  day(dFecha))) * 100 ,  
					(vsaldo_dia - vsaldo_anio_ant), /*vmeta_sdo_mes*/ (vmeta_sdo_dia *  day(dFecha)) + vmeta_sdo_anio , ((vsaldo_dia - vsaldo_anio_ant) /  ((vmeta_sdo_dia *  day(dFecha)) + vmeta_sdo_anio)) * 100, vsaldo_dia , (vsaldo_anio_ant + vmeta_sdo_dia *  day(dFecha) ));
								
				
			END foreach;
			
			                    
			-- pasa info de saldos del dia a tabla del saldos del dia anterior para ser usada como el saldo del dia anterior en la siguiente fecha a procesar		
			--empresa, aniomes, sucursal, saldo_dia	
			let vpaso = 15; 
				if  (select  count (*) from mi_sdodia_anterior where fecha = dfecha ) = 0 THEN
					INSERT INTO mi_sdodia_anterior (Empresa,fecha,sucursal,saldo_ant )
					select empresa, dfecha, sucursal,saldo_dia 
					from tmp_sdosactuales;
				ELSE
				let vpaso = 16; 	
					delete from mi_sdodia_anterior where fecha = dfecha;
					
					INSERT INTO mi_sdodia_anterior (Empresa,fecha,sucursal,saldo_ant )
					select empresa, dfecha, sucursal,saldo_dia 
					from tmp_sdosactuales;
					
				end if	
				
				
			--paso a historico de saldos
			let vpaso = 17; 
			BEGIN WORK;
				
				DELETE FROM mi_his_sdo WHERE fecha = dfecha;
			
			COMMIT WORK;
			
			let vpaso = 18; 
			BEGIN WORK; 
				 insert into mi_his_sdo (fecha,sucursal,tpo_reg,Incre_SdoDia,Meta_Incre_SdoDia,por_CumpDia,Incr_SdoAcumulado,Meta_IncrSdo_Acum,por_CumpAcum,Sdoafecha,Sdo_MetaFecha)
				 select fecha,sucursal,tpo_reg,Incre_SdoDia,Meta_Incre_SdoDia,por_CumpDia,Incr_SdoAcumulado,Meta_IncrSdo_Acum,por_CumpAcum,Sdoafecha,Sdo_MetaFecha
				 from  mi_sdosuc;
			COMMIT WORK;
	 
			drop table tmp_sdosactuales;
				
		return cod_ret ,mensaje;
	end
end procedure
;