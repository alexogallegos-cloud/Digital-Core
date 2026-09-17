CREATE PROCEDURE "informix".sp_replicacomportamientosdoact()
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha           Date;
DEFINE  lSaldo           Money(14,2);
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

--**************************************************************
-- Creado por Manuel Osuna                                   --*
-- Modificado por Fabiola Corrales 31/Ago/2007               --*
-- Debug del Procedure                                       --*
 --SET DEBUG FILE TO "/tmp/manuel.out";                      --*
 --TRACE ON;                                                 --*
--**************************************************************

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
set isolation to dirty read;
   select sum(saldo_cap) into lSaldo  from bdmis:mi_comportamiento where producto not in (select num_producto from bdmis:mi_producto where num_sistema = '03');

   IF lSaldo == 0 THEN
   			--fecha del sistema
   			DELETE FROM bdmis:mi_fechas;

   			insert into bdmis:mi_fechas(empresa,fecha_hoy,fecha_ant,prox_fecha,pri_dia_mes,pri_hab_mes,ult_dia_mes,ult_hab_mes)
			select empresa,fecha_hoy,fecha_ant,prox_fecha,pri_dia_mes,pri_hab_mes,ult_dia_mes,ult_hab_mes
			from bdinteg:si_fechas;

   			select fecha_ant into dFecha  from bdmis:mi_fechas;

   			delete from mi_tmpcomportamiento;
			--tarjetas de Debito Aperturadas
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_cap,saldo_cap)
			select chq.sucursal,chq.producto,count(*),sum(chq.sdo_actual)
			from bdicheq:sc_maechq chq,bdicheq:sc_maenoc noc
			where chq.cuenta = noc.cuenta and noc.fecha_alta = dFecha
			and chq.producto  in (select num_producto from bdmis:mi_producto where num_sistema = '01')
			group by chq.sucursal,chq.producto;

			--Tarjetas de Debito Totales
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_cap,totsaldo_cap)
			select chq.sucursal,chq.producto,count(*),sum(chq.sdo_actual)
			from bdicheq:sc_maechq chq,bdicheq:sc_maenoc noc
			where chq.cuenta = noc.cuenta
			and chq.producto in (select num_producto from bdmis:mi_producto where num_sistema = '01')
			group by chq.sucursal,chq.producto;

			--Tarjetas de Credito Aperturadas
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,apertura_col,saldo_col)
			select cred.sucursal,cred.num_producto,count(*),sum (dos.sdo_cap_insoluto)
			from bdicred:sd_maecred cred, bdicred:sd_maesdos dos
			where cred.num_producto in (select num_producto from bdmis:mi_producto where num_sistema = '06')
					and cred.fecha_apertura = dFecha
			and dos.num_credito = cred.num_credito and  trim(cred.cod_caract_2[1,2]) != 'BC'
			group by cred.sucursal,cred.num_producto;

			--Tarjetas de Credito Totales
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,producto,totaper_col,totsaldo_col)
			select cred.sucursal,cred.num_producto,count(*),sum (dos.sdo_cap_insoluto)
			from bdicred:sd_maecred cred, bdicred:sd_maesdos dos
					where cred.num_producto in (select num_producto from bdmis:mi_producto where num_sistema = '06')
			and dos.num_credito = cred.num_credito and  trim(cred.cod_caract_2[1,2]) != 'BC'
			group by cred.sucursal,cred.num_producto;

			--Solicitudes Recibidas en el Dia
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,recibidas_sol,producto)
			select  sol.sucursal,count(*),'6001'
			from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
			where ane.num_solicitud = sol.num_solicitud and  ane.fecha_sol =dFecha
			group by sol.sucursal;


			--Autorizadas y Entregadas de Inmediato
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,autyent_sol,monto_autyent_sol,producto)
			select  sol.sucursal,count(*),sum(sol.monto_solicitado),'6001'
			from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
			where sol.status_solicitud = 'AP'
			and ane.num_solicitud = sol.num_solicitud and  ane.fecha_sol =dFecha
			group by sol.sucursal;

			--Autorizadas no Entregadas
			insert into bdmis:mi_tmpcomportamiento(num_sucursal,autnoent_sol,monto_autnoent_sol,producto)
			select  sol.sucursal,count(*),sum(sol.monto_solicitado),'6001'
			from bdisolic:ss_solicitudes sol, bdisolic:ss_anexosol ane
			where sol.status_solicitud = 'AT'
			and ane.num_solicitud = sol.num_solicitud and  ane.fecha_sol =dFecha
			group by sol.sucursal;

			delete from mi_comportamiento where producto not in (select num_producto from bdmis:mi_producto where num_sistema = '03');

			--Pasar la informacion de la tmpcomportamiento ala mi_comportamiento
			insert into bdmis:mi_comportamiento (num_sucursal,producto,apertura_cap,saldo_cap,totaper_cap,totsaldo_cap,
			apertura_col,saldo_col,totaper_col,totsaldo_col,recibidas_sol,autyent_sol,monto_autyent_sol,autnoent_sol,monto_autnoent_sol,fecha)
			select num_sucursal,producto,sum(apertura_cap),sum(saldo_cap),sum(totaper_cap),sum(totsaldo_cap),sum(apertura_col),sum(saldo_col),sum(totaper_col),sum(totsaldo_col),
			sum(recibidas_sol),sum(autyent_sol),
			sum(monto_autyent_sol),sum(autnoent_sol),sum(monto_autnoent_sol),dFecha
			from bdmis:mi_tmpcomportamiento
			group by num_sucursal,producto;

	ELSE
	    LET P_COD_RET = '000-1';
        LET P_MENSAJE = 'HAY SALDOS MAYOR DE CERO';

	END IF

   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;