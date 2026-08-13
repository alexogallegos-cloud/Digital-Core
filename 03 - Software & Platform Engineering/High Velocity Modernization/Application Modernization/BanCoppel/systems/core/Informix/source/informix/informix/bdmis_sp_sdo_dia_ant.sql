CREATE PROCEDURE "informix".sp_sdo_dia_ant()
RETURNING CHAR (08)  as cod_ret,
		  CHAR (180) as mensaje;

--definicion de variables de retorno		  
	DEFINE  cod_ret			 CHAR(08);
	DEFINE  mensaje			 CHAR(180);		  
--definicion de variables de saldo del dia anterior
	DEFINE	vaniomes_da		 CHAR(06);
	DEFINE	vdia_da			 CHAR(02);		
--
	DEFINE  vpaso			 integer;
	DEFINE  dfecha			 date;
	
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(180);	

BEGIN
		  ON EXCEPTION SET SQL_ERR, ISAM_ERR,ERROR_INFO
			  LET  cod_ret      = 	SQL_ERR;
			  LET  mensaje  = 	ERROR_INFO || ' sp_sdo_dia_ant en paso ' || vpaso;	  
			  insert into mi_rptcierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
			  select fecha_ant,'F',cod_ret, TRIM(mensaje)  from bdmis:mi_fechas;
			  RETURN cod_ret, mensaje;
		   END EXCEPTION;
	
	let cod_ret = '00000000';
	let mensaje = 'OK';
	
	let vpaso = 0;
	
	--set debug file TO "saldo_dia_ant.out";
	--trace on;
	
		set isolation to dirty read;
		select fecha_ant into dfecha from mi_fechas;	

--se calcula el dia anterior
			let vaniomes_da = trim( year (DATE(dFecha)-1) || lpad(month(DATE(dFecha)-1),2,'0'))::integer;
			let vdia_da = lpad(day (DATE(dFecha)-1),2,'0');
			
			-- extraccion de sdo del dia anterior
			INSERT INTO mi_sdodia_anterior (empresa, fecha, sucursal, saldo_ant )
				select empresa, fecha, sucursal, sum(saldo_dia) from table (multiset(
						SELECT   '001' as empresa, DATE(dFecha)-1 as fecha, sdo.sucursal, 
								sum(case
											When vdia_da  = '01'   then nvl(sdo.capvig1,0)	When vdia_da  = '17'   then nvl(sdo.capvig17,0)
											When vdia_da  = '02'   then nvl(sdo.capvig2,0)	When vdia_da  = '18'   then nvl(sdo.capvig18,0)
											When vdia_da  = '03'   then nvl(sdo.capvig3,0)	When vdia_da  = '19'   then nvl(sdo.capvig19,0)
											When vdia_da  = '04'   then nvl(sdo.capvig4,0)	When vdia_da  = '20'   then nvl(sdo.capvig20,0)
											When vdia_da  = '05'   then nvl(sdo.capvig5,0)	When vdia_da  = '21'   then nvl(sdo.capvig21,0)
											When vdia_da  = '06'   then nvl(sdo.capvig6,0)	When vdia_da  = '22'   then nvl(sdo.capvig22,0)
											When vdia_da  = '07'   then nvl(sdo.capvig7,0)	When vdia_da  = '23'   then nvl(sdo.capvig23,0)
											When vdia_da  = '08'   then nvl(sdo.capvig8,0)	When vdia_da  = '24'   then nvl(sdo.capvig24,0)
											When vdia_da  = '09'   then nvl(sdo.capvig9,0)	When vdia_da  = '25'   then nvl(sdo.capvig25,0)
											When vdia_da  = '10'   then nvl(sdo.capvig10,0)	When vdia_da  = '26'  then nvl(sdo.capvig26,0)
											When vdia_da  = '11'   then nvl(sdo.capvig11,0)	When vdia_da  = '27'  then nvl(sdo.capvig27,0)
											When vdia_da  = '12'   then nvl(sdo.capvig12,0)	When vdia_da  = '28'  then nvl(sdo.capvig28,0)
											When vdia_da  = '13'   then nvl(sdo.capvig13,0)	When vdia_da  = '29'  then nvl(sdo.capvig29,0)
											When vdia_da  = '14'   then nvl(sdo.capvig14,0)	When vdia_da  = '30'  then nvl(sdo.capvig30,0)
											When vdia_da  = '15'   then nvl(sdo.capvig15,0)	When vdia_da  = '31'  then nvl(sdo.capvig31,0)
											When vdia_da  = '16'   then nvl(sdo.capvig16,0)	Else 0 end) as saldo_dia	
						FROM bdicheq:sc_sdodiarioc sdo , bdicheq:sc_maechq mae
						WHERE sdo.aniomes = vaniomes_da and sdo.sucursal < 2000 and
							  mae.cuenta = sdo.cuenta and
							  mae.producto in ('1100','1400','1500','1700','1900','2000','2200','2300','2500')
							  group by 1,2,3
					   union 
					   SELECT '001' as empresa, DATE(dFecha)-1 as fecha ,sucursal, 
											sum(case
											When vdia_da  = '01'   then nvl(cv_dia1,0)	When vdia_da  = '17'   then nvl(cv_dia17,0)
											When vdia_da  = '02'   then nvl(cv_dia2,0)	When vdia_da  = '18'   then nvl(cv_dia18,0)
											When vdia_da  = '03'   then nvl(cv_dia3,0)	When vdia_da  = '19'   then nvl(cv_dia19,0)
											When vdia_da  = '04'   then nvl(cv_dia4,0)	When vdia_da  = '20'   then nvl(cv_dia20,0)
											When vdia_da  = '05'   then nvl(cv_dia5,0)	When vdia_da  = '21'   then nvl(cv_dia21,0)
											When vdia_da  = '06'   then nvl(cv_dia6,0)	When vdia_da  = '22'   then nvl(cv_dia22,0)
											When vdia_da  = '07'   then nvl(cv_dia7,0)	When vdia_da  = '23'   then nvl(cv_dia23,0)
											When vdia_da  = '08'   then nvl(cv_dia8,0)	When vdia_da  = '24'   then nvl(cv_dia24,0)
											When vdia_da  = '09'   then nvl(cv_dia9,0)	When vdia_da  = '25'   then nvl(cv_dia25,0)
											When vdia_da  = '10'   then nvl(cv_dia10,0)	When vdia_da  = '26'  then nvl(cv_dia26,0)
											When vdia_da  = '11'   then nvl(cv_dia11,0)	When vdia_da  = '27'  then nvl(cv_dia27,0)
											When vdia_da  = '12'   then nvl(cv_dia12,0)	When vdia_da  = '28'  then nvl(cv_dia28,0)
											When vdia_da  = '13'   then nvl(cv_dia13,0)	When vdia_da  = '29'  then nvl(cv_dia29,0)
											When vdia_da  = '14'   then nvl(cv_dia14,0)	When vdia_da  = '30'  then nvl(cv_dia30,0)
											When vdia_da  = '15'   then nvl(cv_dia15,0)	When vdia_da  = '31'  then nvl(cv_dia31,0)
											When vdia_da  = '16'   then nvl(cv_dia16,0)	Else 0 end) as saldo_dia	
					   FROM bdinvers:sv_provdia 
					   WHERE aniomes = vaniomes_da
					   group by 1,2,3
				)) group by 1,2,3;
			
			
	RETURN  cod_ret, mensaje;
END;			
END PROCEDURE;