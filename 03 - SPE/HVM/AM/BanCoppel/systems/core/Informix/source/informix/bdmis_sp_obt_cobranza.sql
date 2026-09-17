create procedure "informix".sp_obt_cobranza()		
	RETURNING CHAR(005) as cod_ret,
		  char(180) as mensaje;


	/**********************************/
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  dFecha           Date;
	DEFINE  dFechafto        char(10);
	DEFINE  dFechaCorte      Date;
	DEFINE  dFechaAnt        Date;
	DEFINE  dFechaAnioAnt    Date;
	DEFINE  cFechaAnioAnt    char(06);
	DEFINE  dFechahoy        Date;
	DEFINE  dult_dia_mes     Date;
	DEFINE  dfechaantier     Date;
	DEFINE  iDiasMes         INTEGER;
	DEFINE  vpaso			 integer;	
--	DEFINE  Val2			 integer;
		 

	--variables 
	DEFINE cod_ret			char(04);
	DEFINE vmensaje			char(80);	
	
	DEFINE vct_conv	CHAR(006);
	DEFINE  pgminpago_minimo	      DECIMAL(18,2) ;
		/*********************************/
	 
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO || ' sp_obt_cobranza en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',P_COD_RET, P_MENSAJE  from "informix".mi_fechas;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;
   
--inicializacion
	let P_COD_RET = '000';
	let P_MENSAJE ='PROCESO EXITOSO';
--	LET Val2 = 0;
--se obtienen las fechas de proceso   
   let vpaso = 0;
	SET LOCK MODE TO WAIT 3;
  set isolation to dirty read;
   select fecha_ant,day(ult_dia_mes)::int, (fecha_ant-1), fecha_hoy, ult_dia_mes 
   into dFecha,iDiasMes, dfechaantier, dFechahoy, dult_dia_mes 
   from "informix".mi_fechas;

	let vpaso = 1;

	execute procedure "informix".sp_bitacora_rcda('rcda_cobranza', 1)
	into cod_ret, vmensaje;
	if trim(cod_ret) <> '000' then
		return cod_ret ,vmensaje;
	end if;	
	
	let pgminpago_minimo  = 0;
	let vct_conv = '000000';
	
	truncate table "informix".mi_cobranza;	
	
	let vpaso = 2;
	
	--convenios
	/*merge into mi_cobranza a
	USING (select fecha_compac,sucursal,efectuo_compac::char(8) as cajero,
			count(*) as num, sum(importe) as monto_convenio, sum(imp_pagado) as monto_pago
			from bdicobranza:"informix".cb_compac_his where origen = 2 and 
			fecha_compac = dfecha group by 1,2,3 order by 2,3) b
	on a.sucursal = b.sucursal and a.cajero = b.cajero
	WHEN NOT MATCHED THEN
		INSERT (a.fecha,a.sucursal,a.tpo_reg,a.cajero,a.num_conv,num_ctes_cvdo,a.tot_mont_conv,a.tot_mont_pag)
		VALUES  (dfecha,b.sucursal,1,b.cajero,b.num,b.num,b.monto_convenio,b.monto_pago) ;*/
	
	--SECCION CONVENIOS 
	--1.- Lista de clientes que se presentaron en ventanilla que tienen saldo vencido y no tienen un convenio activo
		insert into "informix".mi_cobranza(fecha,sucursal,tpo_reg,cajero,num_ctes_cvdo)
		SELECT {+INDEX(bdicobranza:cb_compac_bit_realiza idx_compacbitrealiza_fh)} 
		date(cbc.fh_movimiento) as fecha, cbc.sucursal,1,cbc.usr_captura, count(*)  
		FROM bdicobranza:cb_compac_bit_realiza cbc, bdicred:sd_sdos_cartera_linea sds
		where date(cbc.fh_movimiento) = dfecha
		and cbc.origen= 2
		and cbc.numcliente not in (select {+INDEX(bdicobranza:cb_compac idx_compac3)} numcliente from bdicobranza:cb_compac 
		where empresa='001' and fecha_compac < dfecha and activo='1' and origen= 2 ) --Subquery: clientes que tienen un convenio activo de fechas anteriores 
		and date(cbc.fh_movimiento)=sds.fecha
		and cbc.numcuenta=sds.num_credito
		and cbc.numcliente=sds.numcte
		group by 1,2,3,4;
	
			
		let vpaso = 3;
		
		--2.- Total de clientes atendidos por el cajero a los cuales se les realizó un convenio.
		merge into "informix".mi_cobranza a
		USING (select  fecha_compac, sucursal,efectuo_compac,sum(num) as num 
		from table( multiset (
            SELECT {+INDEX(bdicobranza:cb_compac idx_compac3)}
			fecha_compac, sucursal, efectuo_compac, count(*) as num
            FROM bdicobranza:cb_compac 
            WHERE empresa='001' 
			and fecha_compac = dfecha 
			and activo='1'
			and origen =2
            group by 1,2,3
            )) group by 1,2,3) b
         on a.sucursal = b.sucursal and a.cajero = b.efectuo_compac
         WHEN NOT MATCHED THEN
         insert (a.fecha,a.sucursal,a.tpo_reg,a.cajero,a.num_conv)
         values (b.fecha_compac,b.sucursal,1,b.efectuo_compac,b.num)
         WHEN  MATCHED THEN UPDATE
         set    a.num_conv = b.num;

	 
		
	let vpaso = 4;
	--3.- Monto en pesos del total de convenios que se finiquitaron o vencieron en el día. 
	--4.- Cantidad total en pesos que se recuperó de los convenios realizados en sucursal y que se finiquitaron o vencieron en el día.
	--Se descartan los convenios "Mismo día".  fecha_compac= fecha_insert and flag_pago=0  
	
		merge into "informix".mi_cobranza a
		USING (select  fecha_compac, sucursal,efectuo_compac,sum(monto_conv) as monto_conv,sum(imp_pagado) as imp_pagado
		from table( multiset (
            SELECT {+INDEX(bdicobranza:cb_compac_his idx_compachis_emp_ori_fi)}
			fecha_insert as fecha_compac, sucursal, efectuo_compac, importe as monto_conv, 
			case when imp_pagado > importe then importe else imp_pagado end as imp_pagado, numcuenta  --Cuando el pago realizado sea mayor al monto del convenio entonces el pago realizado deberá mostrar solo el total del convenio. --Rocio 10/05/2016
            FROM bdicobranza:cb_compac_his 
            WHERE empresa='001'
			and origen =2
			and fecha_insert = dfecha 
			and fecha_compac!=fecha_insert  
            group by 1,2,3,4,5,6
			union 
			SELECT {+INDEX(bdicobranza:cb_compac_his idx_compachis_emp_ori_fi)}
			fecha_insert as fecha_compac, sucursal, efectuo_compac, importe as monto_conv,
			case when imp_pagado > importe then importe else imp_pagado end as imp_pagado,numcuenta   --Cuando el pago realizado sea mayor al monto del convenio entonces el pago realizado deberá mostrar solo el total del convenio. --Rocio 10/05/2016
            FROM bdicobranza:cb_compac_his 
            WHERE empresa='001'
			and origen =2
			and fecha_insert = dfecha 
			and fecha_compac=fecha_insert
			and flag_pago=1
            group by 1,2,3,4,5,6
            )) group by 1,2,3) b
         on a.sucursal = b.sucursal and a.cajero = b.efectuo_compac
         WHEN NOT MATCHED THEN
         insert (a.fecha,a.sucursal,a.tpo_reg,a.cajero,a.tot_mont_conv,a.tot_mont_pag)
         values (b.fecha_compac,b.sucursal,1,b.efectuo_compac,b.monto_conv,b.imp_pagado)
         WHEN  MATCHED THEN UPDATE
         set   a.tot_mont_conv = b.monto_conv,
               a.tot_mont_pag = b.imp_pagado;
	
	
	let vpaso = 5;
	
	--SECCIÓN PAGO MÍNIMO
	--1.- Total en pesos de los pagos minimos a recuperar por el cajero en el día. pago_min
	--2.- Total de pesos recuperados del pago minimo, que pagaron los clientes al cajero en ventanillas durante el día.  pago_realizado
	--3.- Total de clientes atendidos por el cajero durante el día a los cuales el sistema solicita pago mínimo. count(pago_min)
	merge into "informix".mi_cobranza a
	USING (select  tbl1.sucursal, tbl1.ejecutivo,tbl1.fecha, sum (pago_min) as tot_pago_min,sum (pago_realizado) as tot_pagado,sum(tbl1.num) as num 
		from table (multiset(
			SELECT {+INDEX(bdicobranza:cb_evaluacion_objetiva_his idx_evaluacion_objetiva_his_1)}
			sucursal,usuario::char(08) as ejecutivo,date(fecha_insert) as fecha, pago_min,
			case when pago_realizado > pago_min then pago_min else pago_realizado end as pago_realizado, num_credito, ----Cuando el pago realizado sea mayor al monto del pago minimo entonces el pago realizado deberá mostrar solo el total del pago minimo. --Rocio 11/05/2016
			count(pago_min) as num  
			FROM bdicobranza:cb_evaluacion_objetiva_his 
			where empresa='001'
			and (sucursal between '0001' and '8000')
			and sucursal IN (SELECT sucursal FROM bdinteg:si_sucursales WHERE tipo = 'S')
			 and fecha_insert = dFecha 
			and reversado='N' and pago_min >0    
			group by 1,2,3,4,5,6)) tbl1 group by 1,2,3 order by sucursal, ejecutivo) b
	on a.sucursal = b.sucursal and a.cajero = b.ejecutivo and a.fecha = b.fecha
	WHEN NOT MATCHED THEN 
		insert ( a.fecha, a.sucursal,a.tpo_reg,a.cajero,a.pag_min_a_recup,a.pag_min_recup,a.num_pm)
		values ( b.fecha,b.sucursal,1,b.ejecutivo,b.tot_pago_min,b.tot_pagado,b.num)
	WHEN MATCHED THEN UPDATE
		set a.pag_min_a_recup = b.tot_pago_min, 
			a.pag_min_recup =b.tot_pagado, 
			a.num_pm = b.num ;

	let vpaso = 6;

	--4.- Total de clientes que se atendieron durante el día y saldaron pago mínimo
	
	merge into "informix".mi_cobranza a
	USING (	select  tbl1.sucursal, tbl1.ejecutivo,tbl1.fecha, sum(tbl1.num) as num_sinpm 
		from table (multiset(
			SELECT {+INDEX(bdicobranza:cb_evaluacion_objetiva_his idx_evaluacion_objetiva_his_1)}
			sucursal,usuario::char(08) as ejecutivo,date(fecha_insert) as fecha, count(*) as num  
			FROM bdicobranza:cb_evaluacion_objetiva_his 
			where empresa='001'
			and (sucursal between '0001' and '8000')
			and sucursal IN (SELECT sucursal FROM bdinteg:si_sucursales WHERE tipo = 'S')
			and fecha_insert = dFecha 
			and reversado='N' and pago_min>0
			and pago_realizado >= pago_min 
			group by 1,2,3)) tbl1 group by 1,2,3 order by sucursal, ejecutivo) b
	on a.sucursal = b.sucursal and a.cajero = b.ejecutivo and a.fecha = b.fecha
	WHEN MATCHED THEN UPDATE
		set a.num_sin_pm = b.num_sinpm;
	
	let vpaso = 7;
	
	--SECCIÓN VENCIDO
	--1.- Total en pesos de los pagos vencidos a recuperar por el cajero durante el día.  saldo_vencido
	--2.- Total de pesos recuperados por el cajero del saldo vencido que pagaron los cliente en sucursal durante el día. pago_realizado
	--3.- Total de clientes que se atendieron por el cajero durante el día a los cuales el sistema solicita recuperar un saldo vencido.  count(saldo_vencido)
			
	merge into "informix".mi_cobranza a
	USING (select  tbl1.sucursal, tbl1.ejecutivo,tbl1.fecha, sum (saldo_vencido) as tot_sdo_vencido, sum (pago_realizado) as tot_rec_sdovencido,sum(tbl1.num) as num 
		from table (multiset(
			SELECT {+INDEX(bdicobranza:cb_evaluacion_objetiva_his idx_evaluacion_objetiva_his_1)} 
			sucursal,usuario::char(08) as ejecutivo,date(fecha_insert) as fecha, saldo_vencido,
			case when pago_realizado > saldo_vencido then saldo_vencido else pago_realizado end as pago_realizado, num_credito, ----Cuando el pago realizado sea mayor al monto del saldo vencido entonces el pago realizado deberá mostrar solo el total del saldo vencido. --Rocio 11/05/2016
			count(saldo_vencido) as num  
			FROM bdicobranza:cb_evaluacion_objetiva_his 
			where empresa='001'
			and (sucursal between '0001' and '8000')
			and sucursal IN (SELECT sucursal FROM bdinteg:si_sucursales WHERE tipo = 'S')
			and fecha_insert = dFecha 
			and reversado='N' and saldo_vencido > 0
			group by 1,2,3,4,5,6)) tbl1 group by 1,2,3 order by sucursal, ejecutivo) b
	on a.sucursal = b.sucursal and a.cajero = b.ejecutivo and a.fecha = b.fecha
	WHEN NOT MATCHED THEN 
		insert ( a.fecha, a.sucursal,a.tpo_reg,a.cajero,a.venc_a_recup,a.venc_recup,a.num_vencidos/*,num_ctes_cvdo*/)
		values ( b.fecha,b.sucursal,1,b.ejecutivo,b.tot_sdo_vencido,b.tot_rec_sdovencido,b.num/*, b.num*/)
	WHEN MATCHED THEN UPDATE
		set a.venc_a_recup = b.tot_sdo_vencido, a.venc_recup =b.tot_rec_sdovencido, a.num_vencidos = b.num/*,num_ctes_cvdo = b.num*/;		
		
	let vpaso = 8;
	
	-- 4.- Total de clientes atendidos por el cajero durante el día y que pagaron su saldo vencido
			
	merge into "informix".mi_cobranza a
	USING (select  tbl1.sucursal, tbl1.ejecutivo,tbl1.fecha, sum (num_1) as num
		from table (multiset(
			SELECT sucursal,usuario::char(08) as ejecutivo,date(fecha_insert) as fecha,count(*) as num_1  
			FROM bdicobranza:cb_evaluacion_objetiva_his 
			where empresa='001'
			and (sucursal between '0001' and '8000')
			and sucursal IN (SELECT sucursal FROM bdinteg:si_sucursales WHERE tipo = 'S')
			and fecha_insert = dFecha 
			and reversado='N' and saldo_vencido > 0
			 and pago_realizado >= saldo_vencido  
			group by 1,2,3))tbl1 group by 1,2,3 order by sucursal,ejecutivo) b
	on a.sucursal = b.sucursal and a.cajero = b.ejecutivo and a.fecha = b.fecha
	WHEN MATCHED THEN UPDATE
		set num_sin_vencidos = b.num;
	
let vpaso = 9;

	--poner nombre 
	merge into "informix".mi_cobranza a	
		USING bdinteg:si_ejecut b
			on  a.cajero = b.ejecutivo 
		WHEN  MATCHED THEN UPDATE
			set a.nombre = b.nombre;
			
	let vpaso = 9;
	Delete FROM "informix".mi_cobranza WHERE nombre is null;		

	RETURN P_COD_RET, P_MENSAJE;	
END
end procedure;