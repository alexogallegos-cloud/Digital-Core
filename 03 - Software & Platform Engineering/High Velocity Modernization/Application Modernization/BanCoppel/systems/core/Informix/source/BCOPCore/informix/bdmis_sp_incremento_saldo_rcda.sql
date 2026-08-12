create procedure "informix".sp_incremento_saldo_rcda()
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
			  LET  mensaje  = 	ERROR_INFO || ' sp_incremento_saldo_rcda en paso ' || vpaso;	  
			  insert into mi_rptcierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
			  select fecha_ant,'F',cod_ret, TRIM(mensaje)  from bdmis:mi_fechas;
			  RETURN cod_ret, mensaje;
		   END EXCEPTION;
			
			
			
			
			EXECUTE PROCEDURE sp_buscatemporal('tmp_saldo_act')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmp_saldo_act;
            END IF
			  
			  let vpaso = 0;
			  { TABLE "informix".tmp_saldo_act row size = 42 number of columns = 7 index size = 0 }
				create table "informix".tmp_saldo_act 
				  (
					id char(5),
					empresa char(3),
					sucursal char(4),
					ejecutivo char(8),
					producto char(4),
					saldo_act money(16,2),
					saldo_ant money(16,2)
				  ) extent size 32 next size 32 lock mode page;
				set pdqpriority 0;
				UPDATE STATISTICS MEDIUM FOR TABLE "informix".tmp_saldo_act;  
				  
			set isolation to dirty read;
			select fecha_ant into dfecha from bdinteg:si_fechas;
			
			if (SELECT count(codigo_error) FROM mi_rptcierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
			   return '001','fecha ya procesada';
			end if
						
            set isolation to dirty read;
			insert into tmp_saldo_act (id,empresa,sucursal,ejecutivo,producto,saldo_act,saldo_ant)
            select 'INCRE' as Id,empresa as empresa,sucursal as sucursal, ejecutivo as ejecutivo, producto as producto, saldo_dia::money as saldo_act, (0.0)::money as saldo_ant
            from table ( multiset ( 
					    select {+INDEX(bdicheq:sc_sdodiarioc isdodiario)}
                               mae.empresa, mae.sucursal,mae.producto,noc.ejecutivo,
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
								from bdicheq:sc_sdodiarioc sdo, bdicheq:sc_maechq mae,bdicheq:sc_maenoc noc
								where sdo.cuenta >= '10000000000' and sdo.aniomes = trim( year (dFecha) || lpad(month(dFecha),2,'0'))::integer and --sdo.sucursal = mae.sucursal and 
                                      mae.empresa = '001' and mae.cuenta = sdo.cuenta and  noc.cuenta = sdo.cuenta and mae.empresa = noc.empresa  and 								
                                      mae.producto not in ('1300','1800') group by mae.empresa, mae.sucursal,mae.producto,noc.ejecutivo))                    
                    ;
					let vpaso = 1;
		return cod_ret ,mensaje;
	end
end procedure
;