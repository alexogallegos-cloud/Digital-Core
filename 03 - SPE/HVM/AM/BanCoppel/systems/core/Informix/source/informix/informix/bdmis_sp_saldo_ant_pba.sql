create procedure "informix".sp_saldo_ant_pba()
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
	DEFINE  cCodret          char(5);	
--DEFINICION DE VARIABLES DE CONTROL DE ERRORES 
	DEFINE  SQL_ERR          INTEGER;   
	DEFINE  ERROR_INFO       VARCHAR(180);	
	DEFINE  ISAM_ERR         INTEGER;
	--inicializacion
	let cod_ret = '000';
	let mensaje = 'OK';
	let vpaso 	= 0;
begin
		  ON EXCEPTION SET SQL_ERR, ISAM_ERR,ERROR_INFO
			  LET  cod_ret      = 	SQL_ERR;
			  LET  mensaje  = 	ERROR_INFO || ' sp_saldo_ant en paso ' || vpaso;	  
			  insert into mi_rptcierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
			  select fecha_ant,'F',cod_ret, TRIM(mensaje)  from bdmis:mi_fechas;
			  RETURN cod_ret, mensaje;
		   END EXCEPTION;
		   
            EXECUTE PROCEDURE sp_buscatemporal('tmp_saldo_ant')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmp_saldo_ant;
            END IF		   
		   
			{ TABLE "informix".tmp_saldo_ant row size = 33 number of columns = 6 index size = 
						  0 }
			create table "informix".tmp_saldo_ant 
			  (
				id char(5),
				empresa char(3),
				sucursal char(4),
				ejecutivo char(8),
				producto char(4),
				saldo_ant money(16,2)
			  ) extent size 32 next size 32 lock mode page;
				set pdqpriority 0;
				UPDATE STATISTICS MEDIUM FOR TABLE "informix".tmp_saldo_ant;  			  
			  
		   
			Let dFechaAnioAnt = '12/31/2012';
			select fecha_ant into dfecha from bdinteg:si_fechas;   
			
						
			if (SELECT count(codigo_error) FROM mi_rptcierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
			   return '001','fecha ya procesada';
			end if
		   
		   	execute procedure "informix".sp_bitacora_rcda('rcda_saldos_2012', 1)
			into cod_ret, mensaje;
			if trim(cod_ret) <> '000' then
				return cod_ret ,mensaje;
			end if
		   
		    set isolation to dirty read;
			insert into tmp_saldo_ant (id,empresa,sucursal,ejecutivo,producto,saldo_ant)
            select 'INCRE' as Id,empresa as empresa,sucursal as sucursal, ejecutivo as ejecutivo, producto as producto, saldo_ant::money as saldo_ant
            from table ( multiset ( 
					    select {+INDEX(bdicheq:sc_sdodiarioc_2012 isdodiario_2012)}
                               mae.empresa, mae.sucursal,mae.producto,noc.ejecutivo,
						sum(case
								When day(dFechaAnioAnt)  = '31'  then nvl(sdo2.capvig31,0) Else 0 end) as saldo_ant                        
								from bdicheq:sc_sdodiarioc_2012 sdo2, bdicheq:sc_maechq mae,bdicheq:sc_maenoc noc
								where sdo2.cuenta >= '10000000000' and sdo2.aniomes = trim( year (dFechaAnioAnt) || lpad(month(dFechaAnioAnt),2,'0'))::integer and --sdo2.sucursal = mae.sucursal and 
                                mae.empresa = '001' and  mae.cuenta = sdo2.cuenta and  noc.cuenta =sdo2.cuenta and mae.empresa = noc.empresa  and mae.producto not in ('1300','1800')
								group by mae.empresa, mae.sucursal,mae.producto,noc.ejecutivo))
                    ;

			execute procedure "informix".sp_bitacora_rcda('rcda_saldos_2012', 2)
			into cod_ret, mensaje;
			if trim(cod_ret) <> '000' then
				return cod_ret ,mensaje;
			end if			
			return cod_ret ,mensaje;
end
end procedure
;