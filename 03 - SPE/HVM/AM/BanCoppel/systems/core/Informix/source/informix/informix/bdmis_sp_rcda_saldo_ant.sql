create procedure "informix".sp_rcda_saldo_ant()
	RETURNING char(05) as cod_ret,
			  char(180) as mensaje;
			  
--declaracion de variables
	DEFINE  dFechaCorte      Date;
	DEFINE  dFechaAnt        Date;
	DEFINE  dFechaAnioAnt    Date;
	DEFINE  vpaso			 integer;
	DEFINE  dfecha			 date;
	DEFINE  cod_ret			 CHAR(05);
	DEFINE  mensaje			 CHAR(180);
	DEFINE  iCuantos         INTEGER;
	DEFINE  cVarDataErr      char(120);
	DEFINE  cCodret          char(05);	
	DEFINE	vaniomes		 INTEGER;
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
			  LET  mensaje  = 	ERROR_INFO || ' sp_rcda_saldo_ant en paso ' || vpaso;	  
			  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
			  select fecha_ant,'F',cod_ret, TRIM(mensaje)  from bdmis:mi_fechas;
			  RETURN cod_ret, mensaje;
		   END EXCEPTION;	

   

			select fecha_ant into dfecha from bdmis:mi_fechas; 			
						
			if (SELECT count(codigo_error) FROM mi_rcda_cierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
			   return '001','fecha ya procesada';
			end if
			
			let vaniomes = YEAR(dfecha) - 1|| 12 ;
			
			if (select count (*) from mi_sdoanterior where anio = YEAR(dfecha) -1 ) = 0  THEN
		   
					/*execute procedure "informix".sp_bitacora_rcda('rcda_sdoanioaterior', 1)
					into cod_ret, mensaje;
					if trim(cod_ret) <> '000' then
						return cod_ret ,mensaje;
					end if;*/
					
					set isolation to dirty read;
					INSERT INTO mi_sdoanterior (Empresa, anio, sucursal, saldo_ant)	 
					select empresa, anio, sucursal, sum(saldo) from table (multiset(
						SELECT '001' as empresa ,SUBSTR (sdo.aniomes,1,4) as anio, sdo.sucursal, sum(sdo.capvig31) as saldo 
						FROM bdicheq:sc_sdodiarioc sdo , bdicheq:sc_maechq mae
						WHERE sdo.aniomes = vaniomes and sdo.sucursal < 8000 and
						mae.cuenta = sdo.cuenta and
						 mae.producto in ('1100','1400','1500','1700','1900','2000','2200','2300','2500')
						group by 1,2,3
						union 
						SELECT '001' as empresa, SUBSTR (aniomes,1,4) as anio ,sucursal,  sum(cv_dia31) as saldo 
						FROM bdinvers:sv_provdia WHERE aniomes = vaniomes
						group by 1,2,3
					))group by 1,2,3;
					
					/*execute procedure "informix".sp_bitacora_rcda('rcda_sdoanioaterior', 2)
					into cod_ret, mensaje;
					if trim(cod_ret) <> '000' then
						return cod_ret ,mensaje;
					end if		*/	
					
					
			END IF 	

			
			
			if month(dfecha) = '1' or  month(dfecha) = '01' then  
			
					let vaniomes = YEAR(dfecha) - 1|| 12 ;
				
				else 
					let vaniomes = YEAR(dfecha) || LPAD(MONTH (dfecha) -1,2,0);
			end if
			
			IF (select count (*) from mi_acumsdo_mes where aniomes =  vaniomes ) = 0 THEN
			
					EXECUTE PROCEDURE "informix".sp_rcda_acumsdo_mes()
					INTO cod_ret, mensaje;
					IF cod_ret <> '00000' THEN
					
						RETURN cod_ret, mensaje;
					
					END IF
					
			END IF
			
	return cod_ret ,mensaje;
	
end
end procedure
;