create procedure "informix".sp_update_saldos_rcda_pba()
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
			  LET  mensaje  = 	ERROR_INFO || ' sp_update_saldos_rcda en paso ' || vpaso;	  
			  insert into mi_rptcierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
			  select fecha_ant,'F',cod_ret, TRIM(mensaje)  from bdmis:mi_fechas;
			  RETURN cod_ret, mensaje;
		   END EXCEPTION;
		   
			EXECUTE PROCEDURE sp_buscatemporal('tmp_saldo_pagare_act')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmp_saldo_pagare_act;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmp_saldo_pagare_ant')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmp_saldo_pagare_ant;
            END IF
			
			truncate table mi_incremento_saldo;	
			
			--obtener fechas
	Let dFechaAnioAnt = '12/31/2011';
	select fecha_ant into dfecha from bdinteg:si_fechas;	
	
			if (SELECT count(codigo_error) FROM mi_rptcierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
			   return '001','fecha ya procesada';
			end if	
	
	--Se actualizan saldos actuales con saldos del año anterior
	
		execute procedure "informix".sp_bitacora_rcda('rcda_actualiza_sdo_actual', 1)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if
	
        update tmp_saldo_act
        set saldo_ant = (select tmp_saldo_ant.saldo_ant
                       from  tmp_saldo_ant 
                       where tmp_saldo_ant.empresa = tmp_saldo_act.empresa and tmp_saldo_ant.sucursal = tmp_saldo_act.sucursal and
                             tmp_saldo_ant.ejecutivo = tmp_saldo_act.ejecutivo and tmp_saldo_ant.producto = tmp_saldo_act.producto)::money
        where exists (select tmp_saldo_ant.saldo_ant
                       from  tmp_saldo_ant 
                       where tmp_saldo_ant.empresa = tmp_saldo_act.empresa and tmp_saldo_ant.sucursal = tmp_saldo_act.sucursal and
                             tmp_saldo_ant.ejecutivo = tmp_saldo_act.ejecutivo and tmp_saldo_ant.producto = tmp_saldo_act.producto);
		let vpaso = 3;					 
			
		execute procedure "informix".sp_bitacora_rcda('rcda_actualiza_sdo_actual', 2)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if			
	--Se Integra al saldo actual los promotores que están en el incremento de la sucursal en el año anterior y no en el actual para el acumulado del incremento por sucursal
       
		execute procedure "informix".sp_bitacora_rcda('rcda_integra_sdoprom', 1)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if	
	   
	   insert into tmp_saldo_act (id,empresa,sucursal,ejecutivo,producto,saldo_act,saldo_ant)
        select id,empresa,sucursal,ejecutivo,producto,0,saldo_ant
        from tmp_saldo_ant  where not exists(select tmp_saldo_act.saldo_ant
                         from  tmp_saldo_act 
                         where tmp_saldo_ant.empresa = tmp_saldo_act.empresa and tmp_saldo_ant.sucursal = tmp_saldo_act.sucursal and
                             tmp_saldo_ant.ejecutivo = tmp_saldo_act.ejecutivo and tmp_saldo_ant.producto = tmp_saldo_act.producto);
	let vpaso = 4;
	
		execute procedure "informix".sp_bitacora_rcda('rcda_integra_sdoprom', 2)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if
	--Se guardan los resultados en mi_incremento_saldo
        insert into mi_incremento_saldo(tipo,empresa,sucursal,ejecutivo,producto,monto_incrementodia)
        select 'INCRE',empresa,sucursal,ejecutivo,producto,(saldo_act  - saldo_ant)::money as saldo from tmp_saldo_act;
	
	let vpaso = 5;
	--Nuevo Incremento saldo PAGARES  -- Se obtienen los saldos actuales
		execute procedure "informix".sp_bitacora_rcda('rcda_incre_pagares', 1)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if
		
            set isolation to dirty read;
            select 'INCRE' as Id,empresa as empresa,sucursal as sucursal, promotor as ejecutivo,
                   cod_instrum as producto, saldo_dia::money as saldo_act, (0.0)::money as saldo_ant
            from table ( multiset ( 
					    select {+INDEX(bdinvers:sv_provdia idx_provdia)}
                               mae.empresa, mae.sucursal,mae.cod_instrum,mae.promotor,
						sum(case
								When day(dFecha)  = '01'   then nvl(sdo.cv_dia1,0)	When day(dFecha)  = '17'   then nvl(sdo.cv_dia17,0)
								When day(dFecha)  = '02'   then nvl(sdo.cv_dia2,0)	When day(dFecha)  = '18'   then nvl(sdo.cv_dia18,0)
								When day(dFecha)  = '03'   then nvl(sdo.cv_dia3,0)	When day(dFecha)  = '19'   then nvl(sdo.cv_dia19,0)
								When day(dFecha)  = '04'   then nvl(sdo.cv_dia4,0)	When day(dFecha)  = '20'   then nvl(sdo.cv_dia20,0)
								When day(dFecha)  = '05'   then nvl(sdo.cv_dia5,0)	When day(dFecha)  = '21'   then nvl(sdo.cv_dia21,0)
								When day(dFecha)  = '06'   then nvl(sdo.cv_dia6,0)	When day(dFecha)  = '22'   then nvl(sdo.cv_dia22,0)
								When day(dFecha)  = '07'   then nvl(sdo.cv_dia7,0)	When day(dFecha)  = '23'   then nvl(sdo.cv_dia23,0)
								When day(dFecha)  = '08'   then nvl(sdo.cv_dia8,0)	When day(dFecha)  = '24'   then nvl(sdo.cv_dia24,0)
								When day(dFecha)  = '09'   then nvl(sdo.cv_dia9,0)	When day(dFecha)  = '25'   then nvl(sdo.cv_dia25,0)
								When day(dFecha)  = '10'   then nvl(sdo.cv_dia10,0)	When day(dFecha)  = '26'  then nvl(sdo.cv_dia26,0)
								When day(dFecha)  = '11'   then nvl(sdo.cv_dia11,0)	When day(dFecha)  = '27'  then nvl(sdo.cv_dia27,0)
								When day(dFecha)  = '12'   then nvl(sdo.cv_dia12,0)	When day(dFecha)  = '28'  then nvl(sdo.cv_dia28,0)
								When day(dFecha)  = '13'   then nvl(sdo.cv_dia13,0)	When day(dFecha)  = '29'  then nvl(sdo.cv_dia29,0)
								When day(dFecha)  = '14'   then nvl(sdo.cv_dia14,0)	When day(dFecha)  = '30'  then nvl(sdo.cv_dia30,0)
								When day(dFecha)  = '15'   then nvl(sdo.cv_dia15,0)	When day(dFecha)  = '31'  then nvl(sdo.cv_dia31,0)
								When day(dFecha)  = '16'   then nvl(sdo.cv_dia16,0)	Else 0 end) as saldo_dia                        
								from bdinvers:sv_provdia sdo, bdinvers:sv_maeinv mae
								where sdo.cuenta >= '30000000000' and sdo.aniomes = trim( year(dFecha) || lpad(month(dFecha),2,'0'))::integer and -- sdo.sucursal = mae.sucursal and                                         
                                      mae.empresa = '001' and mae.cuenta = sdo.cuenta and mae.secuencia = sdo.secuencia and                               
                                      mae.cod_instrum = '3000' group by mae.empresa, mae.sucursal,mae.cod_instrum,mae.promotor))                    
                    into temp tmp_saldo_pagare_act WITH NO LOG;
			
			let vpaso = 6;	

		execute procedure "informix".sp_bitacora_rcda('rcda_incre_pagares', 2)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if
			
	--Se obtienen los saldos del año anterir
	
		execute procedure "informix".sp_bitacora_rcda('rcda_incre_pagares_ant', 1)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if	
		
            set isolation to dirty read;
            select 'INCRE' as Id,empresa as empresa,sucursal as sucursal, promotor as ejecutivo, cod_instrum as producto, saldo_ant::money as saldo_ant            
            from table ( multiset ( 
					    select {+INDEX(bdinvers:sv_provdia idx_provdia)}
                                mae.empresa, mae.sucursal,mae.cod_instrum,mae.promotor,
						sum(case
								When day(dFechaAnioAnt) = '31'  then nvl(sdo2.cv_dia31,0) Else 0 end) as saldo_ant                        
								from bdinvers:sv_provdia sdo2, bdinvers:sv_maeinv mae
								where sdo2.cuenta >= '30000000000' and sdo2.aniomes = trim( year(dFechaAnioAnt) || lpad(month(dFechaAnioAnt),2,'0'))::integer and --sdo2.sucursal = mae.sucursal and 
   mae.empresa = '001' and  mae.cuenta = sdo2.cuenta and mae.secuencia = sdo2.secuencia and mae.cod_instrum = '3000' group by mae.empresa, mae.sucursal,mae.cod_instrum,mae.promotor)) 
   into temp tmp_saldo_pagare_ant WITH NO LOG;	
   let vpaso = 7;

		execute procedure "informix".sp_bitacora_rcda('rcda_incre_pagares_ant', 2)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if	   
   
--Se actualizan saldos actuales con saldos del 2011

		execute procedure "informix".sp_bitacora_rcda('rcda_actualiza_pagares', 1)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if	

        update tmp_saldo_pagare_act
        set saldo_ant = (select tmp_saldo_pagare_ant.saldo_ant
                       from  tmp_saldo_pagare_ant 
                       where tmp_saldo_pagare_ant.empresa = tmp_saldo_pagare_act.empresa and tmp_saldo_pagare_ant.sucursal = tmp_saldo_pagare_act.sucursal and
                             tmp_saldo_pagare_ant.ejecutivo = tmp_saldo_pagare_act.ejecutivo and tmp_saldo_pagare_ant.producto = tmp_saldo_pagare_act.producto)::money
        where exists (select tmp_saldo_pagare_ant.saldo_ant
                       from  tmp_saldo_pagare_ant 
                       where tmp_saldo_pagare_ant.empresa = tmp_saldo_pagare_act.empresa and tmp_saldo_pagare_ant.sucursal = tmp_saldo_pagare_act.sucursal and
                             tmp_saldo_pagare_ant.ejecutivo = tmp_saldo_pagare_act.ejecutivo and tmp_saldo_pagare_ant.producto = tmp_saldo_pagare_act.producto);
		let vpaso = 8;

		execute procedure "informix".sp_bitacora_rcda('rcda_actualiza_pagares', 2)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if		
		
--Se Integra al saldo actual los promotores que están en el incremento de la sucursal en el año anterior y no en el actual para el acumulado del incremento por sucursal
		execute procedure "informix".sp_bitacora_rcda('rcda_integra_sdoprom_paga', 1)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if	

        insert into tmp_saldo_pagare_act (id,empresa,sucursal,ejecutivo,producto,saldo_act,saldo_ant)
        select id,empresa,sucursal,ejecutivo,producto,0,saldo_ant
        from tmp_saldo_pagare_ant 
        where not exists(select tmp_saldo_pagare_act.saldo_ant from  tmp_saldo_pagare_act 
                         where tmp_saldo_pagare_ant.empresa = tmp_saldo_pagare_act.empresa and tmp_saldo_pagare_ant.sucursal = tmp_saldo_pagare_act.sucursal and
                             tmp_saldo_pagare_ant.ejecutivo = tmp_saldo_pagare_act.ejecutivo and tmp_saldo_pagare_ant.producto = tmp_saldo_pagare_act.producto);
        let vpaso = 9;

		execute procedure "informix".sp_bitacora_rcda('rcda_integra_sdoprom_paga', 2)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if	
		
  --Se guardan los resultados en mi_incremento_saldo
  
		execute procedure "informix".sp_bitacora_rcda('rcda_guarda_incre_saldo', 1)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if  
  
        insert into mi_incremento_saldo(tipo,empresa,sucursal,ejecutivo,producto,monto_incrementodia)
        select 'INCRE',empresa,sucursal,ejecutivo,producto,(saldo_act  - saldo_ant)::money as saldo
        from tmp_saldo_pagare_act;			
			
		execute procedure "informix".sp_bitacora_rcda('rcda_guarda_incre_saldo', 2)
		into cod_ret, mensaje;
		if trim(cod_ret) <> '000' then
			return cod_ret ,mensaje;
		end if 
			
   
			return cod_ret ,mensaje;
end 
end procedure
;