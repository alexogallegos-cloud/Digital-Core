create procedure "informix".sp_rcda_acumsdo_mes()
	RETURNING char(05) as cod_ret,
			  char(180) as mensaje;
			  
--declaracion de variables
	DEFINE  dFechaCorte      Date;
	DEFINE  dFechaAnt        Date;
	DEFINE  vpaso			 integer;
	DEFINE  dfecha			 date;
	DEFINE  cod_ret			 CHAR(05);
	DEFINE  mensaje			 CHAR(180);
	DEFINE  iCuantos         INTEGER;
	DEFINE  cVarDataErr      char(120);
	DEFINE  cCodret          char(05);	
	DEFINE	vaniomes		 INTEGER;
	DEFINE	vmes			 INTEGER;
	DEFINE	vdia			 CHAR(02);
	
--DEFINICION DE VARIABLES DE CONTROL DE ERRORES 
	DEFINE  SQL_ERR          INTEGER;   
	DEFINE  ERROR_INFO       VARCHAR(180);	
	DEFINE  ISAM_ERR         INTEGER;
	--inicializacion
	let cod_ret = '00000';
	let mensaje = 'PROCESO EXITOSO';
	let vpaso 	= 0;
	
begin
		  ON EXCEPTION SET SQL_ERR, ISAM_ERR,ERROR_INFO
			  LET  cod_ret      = 	SQL_ERR;
			  LET  mensaje  = 	ERROR_INFO || ' sp_acumsdo_mes en paso ' || vpaso;	  
			  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
			  select fecha_ant,'F',cod_ret, TRIM(mensaje)  from bdmis:mi_fechas;
			  RETURN cod_ret, mensaje;
		   END EXCEPTION;			   
		

		
			select fecha_ant into dfecha from bdmis:mi_fechas;   
			
						
			if (SELECT count(codigo_error) FROM mi_rcda_cierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
			   return '001','fecha ya procesada';
			end if
			
			if DAY(dfecha) = '1' or  DAY(dfecha) = '01' then  
					
							
					let vaniomes = YEAR(DATE(dFecha)-1) || lpad(MONTH (DATE(dFecha)-1),2,'0');
					let vdia = lpad(day (DATE(dFecha)-1),2,'0');
						
					
				   
					/*execute procedure "informix".sp_bitacora_rcda('rcda_acumsdo_mes', 1)
					into cod_ret, mensaje;
					if trim(cod_ret) <> '000' then
						return cod_ret ,mensaje;
					end if;*/
				
				IF (select count(*) FROM mi_acumsdo_mes where aniomes = vaniomes ) = 0 THEN
					
					set isolation to dirty read;
					INSERT INTO mi_acumsdo_mes (Empresa, aniomes, sucursal, saldo_mes)	 
					select empresa, aniomes	,sucursal, sum (saldo) FROM TABLE(MULTISET(
						SELECT   '001' as empresa, sdo.aniomes, sdo.sucursal, 
						sum (case when vdia = '28' then nvl(sdo.capvig28,0) 
							 when vdia = '29' then nvl(sdo.capvig29,0) 
							 when vdia = '30' then nvl(sdo.capvig30,0) 
							 when vdia = '31' then nvl(sdo.capvig31,0) end )
						 as saldo 
						FROM bdicheq:sc_sdodiarioc sdo , bdicheq:sc_maechq mae
						WHERE sdo.aniomes = vaniomes and sdo.sucursal < 2000 and
						mae.cuenta = sdo.cuenta and
						 mae.producto in ('1100','1400','1500','1700','1900','2000','2200','2300','2500')
						group by 1,2,3
						UNION
						SELECT '001' as empresa,  aniomes ,sucursal,
						sum (case when vdia = '28' then nvl(cv_dia28,0) 
							 when vdia = '29' then nvl(cv_dia29,0) 
							 when vdia = '30' then nvl(cv_dia30,0) 
							 when vdia = '31' then nvl(cv_dia31,0)  end)
						 as saldo 
						FROM bdinvers:sv_provdia WHERE aniomes = vaniomes
						group by 1,2,3
					)) 	group by 1,2,3;
					
					/*execute procedure "informix".sp_bitacora_rcda('rcda_acumsdo_mes', 2)
					into cod_ret, mensaje;
					if trim(cod_ret) <> '000' then
						return cod_ret ,mensaje;
					end if	*/
				end if 
			end if			
			return cod_ret ,mensaje;
end
end procedure
;