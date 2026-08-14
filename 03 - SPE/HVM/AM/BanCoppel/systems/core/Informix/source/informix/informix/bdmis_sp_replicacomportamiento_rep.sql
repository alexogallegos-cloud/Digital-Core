CREATE PROCEDURE "informix".sp_replicacomportamiento_rep(pFecha date)
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha1          char(8);
DEFINE  dFecha           Date;
DEFINE  iVal             INTEGER; 
DEFINE  iVal2            INTEGER; 

/*Variables para formateo de pFecha*/
DEFINE v_iAnio INTEGER;
DEFINE v_iMes INTEGER;
DEFINE v_idia CHAR(2);
DEFINE v_iMesc CHAR(2);
/***********************************/

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

--**************************************************************
-- Creado por Manuel Osuna                                   --*
-- Modificado por Fabiola Corrales 31/Ago/2007               --*
-- Modificado por Antonio Gómez 24/Nov/2009                  --*
-- Debug del Procedure                                       --*
 --SET DEBUG FILE TO "/tmp/manuel.out";                      --*
 --TRACE ON;                                                 --*
--**************************************************************

   LET iVal = 0;
   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

--SET DEBUG FILE TO "/home/informix/jydg/sp_replicacomportamiento_rep.out";
--TRACE ON;

   /*Formateo de pFecha*/
    set isolation to dirty read;
    LET v_iAnio = 0;
    LET v_iMes = 0;
    LET v_idia = 0;
    LET v_iMesc = '01';

    LET v_iAnio = YEAR(pFecha);
    LET v_iMes = LPAD(MONTH(pFecha),2,0);
    LET v_idia = LPAD(DAY(pFecha),2,0);

    if v_iMes < 10 then 
        LET v_iMesc= 0||v_iMes;
    else 
        LET v_iMesc= v_iMes;
    end if;

--    LET dFecha1 = v_iMesc||'/'||v_idia||'/'||v_iAnio;
      LET dFecha1 = v_iMesc||v_idia||v_iAnio;
      LET dFecha = dFecha1::date;
      LET dFecha = dFecha;
    /********************/
   
        --select fecha_ant into dFecha  from bdmis:mi_fechas;
		
	    Select sum(apertura_cap)into iVal from bdmis:mi_comportamientohis where fecha = dFecha;
		Select sum(apertura_cap)into iVal2 from bdmis:mi_comportamiento where fecha = dFecha;
		
		IF iVal is Null and iVal2 is Null  then		
	        --delete from mi_tmpcomportamiento;
			
            --Tarjetas de Debito Aperturadas a dFecha
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap,fecha)
	        select chq.sucursal,chq.producto,count(*),sum(chq.sdo_dia_ant),dFecha
	        from bdicheq:sc_maechq chq,bdicheq:sc_maenoc noc
	        where chq.cuenta = noc.cuenta and noc.fecha_alta = dFecha
	        and chq.producto  in (select num_producto from bdmis:mi_producto where num_sistema = '01')
	        group by chq.sucursal,chq.producto;

			--Tarjetas de Debito Totales a dFecha
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_cap,totsaldo_cap,fecha)
	        select chq.sucursal,chq.producto,count(*),sum(chq.sdo_dia_ant),dFecha
	        from bdicheq:sc_maechq chq,bdicheq:sc_maenoc noc
		    where chq.cuenta = noc.cuenta and noc.fecha_alta <= dFecha
            and chq.status_cta in(1, 3)
	        and chq.producto in (select num_producto from bdmis:mi_producto where num_sistema = '01')
	        group by chq.sucursal,chq.producto;
	        
	        --Productos de Inversion Por Dia a dFecha
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap,fecha)
			select inv.sucursal,inv.cod_instrum,count(*),sum (inv.capital),dFecha
	        from bdinvers:sv_maeinv inv
	        where inv.cod_instrum in (select num_producto from bdmis:mi_producto where num_sistema = '03')
			and inv.fecha_alta = dFecha or inv.fec_reinversion = dFecha
	        group by inv.sucursal,inv.cod_instrum;
	        
	        --Productos de Inversion Totales Por Dia a dFecha
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_cap,totsaldo_cap,fecha)
	        select inv.sucursal,inv.cod_instrum,count(*),sum (inv.capital),dFecha
	        from bdinvers:sv_maeinv inv
	        where inv.cod_instrum in (select num_producto from bdmis:mi_producto where num_sistema = '03')
	        and inv.status_cta = '1'
            and fecha_alta <= dFecha
	        group by inv.sucursal,inv.cod_instrum;       
	        
			--Tarjetas de Credito Aperturadas a dFecha
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_col,saldo_col,fecha)
	        select cred.sucursal,cred.num_producto,count(*),sum (dos.sdo_cap_insoluto),dFecha
	        from bdicred:sd_maecred cred, bdicred:sd_maesdos dos
	        where cred.num_producto in (select num_producto from bdmis:mi_producto where num_sistema = '06')
	               and cred.fecha_apertura = dFecha
	        and dos.num_credito = cred.num_credito 
                and (cred.cod_caract_2 not like "BC%" or cred.cod_caract_2 is null)
	        group by cred.sucursal,cred.num_producto;

			--Tarjetas de Credito Totales a dFecha
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_col,totsaldo_col,fecha)
	        select cred.sucursal,cred.num_producto,count(*),sum (dos.sdo_cap_insoluto),dFecha
	        from bdicred:sd_maecred cred, bdicred:sd_maesdos dos
	            where cred.num_producto in (select num_producto from bdmis:mi_producto where num_sistema = '06')
                and cred.fecha_apertura <= dFecha
                and dos.num_credito = cred.num_credito 
                and (cred.cod_caract_2 not like "BC%" or cred.cod_caract_2 is null)
                and cred.status_cred <> "CV"
	        group by cred.sucursal,cred.num_producto;

	        --Solicitudes Recibidas en el Dia a dFecha
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,recibidas_sol,producto,fecha)
	        select  sol.sucursal,count(*),'6001',dFecha
	        from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	        where ane.num_solicitud = sol.num_solicitud and  ane.fecha_sol = dFecha
            and sol.fecha_insert = dFecha
	        group by sol.sucursal;

	        --Autorizadas y Entregadas de Inmediato a dFecha
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,autyent_sol,monto_autyent_sol,producto,fecha)
	        select  sol.sucursal,count(*),sum(sol.monto_solicitado),'6001',dFecha
	        from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	        where sol.status_solicitud = 'AP'
	        and ane.num_solicitud = sol.num_solicitud and  ane.fecha_sol = dFecha
            and sol.fecha_insert = dFecha
	        group by sol.sucursal;

	        --Autorizadas no Entregadas a dFecha
	        insert into bdmis:mi_tmpcomportamiento(num_sucursal,autnoent_sol,monto_autnoent_sol,producto,fecha)
	        select  sol.sucursal,count(*),sum(sol.monto_solicitado),'6001',dFecha
	        from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
	        where sol.status_solicitud = 'AT'
	        and ane.num_solicitud = sol.num_solicitud and  ane.fecha_sol = dFecha
            and sol.fecha_insert = dFecha
	        group by sol.sucursal;	    
		
		  --Pasar la informacion de la tmpcomportamiento a la mi_comportamientohis
			insert into bdmis:mi_comportamientohis (num_sucursal,producto,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
		    apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha)
			select num_sucursal,producto,sum(apertura_cap),sum(saldo_cap),sum(totaper_cap),sum(totsaldo_cap),sum(apertura_col),sum(saldo_col),sum(totaper_col),sum(totsaldo_col),
			sum(recibidas_sol),sum(autyent_sol),
			sum(monto_autyent_sol),sum(autnoent_sol),sum(monto_autnoent_sol),dFecha
			from bdmis:mi_tmpcomportamiento
            where fecha = dFecha
			group by num_sucursal,producto;

         --Borra los registros cargados de dFecha para dejar solo los actuales
           delete from mi_tmpcomportamiento where fecha = dFecha;
       else
			LET P_COD_RET = '00050';
			LET P_MENSAJE = 'ERROR: ESTE DIA YA SE PROCESO';
       end if;


   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;