CREATE PROCEDURE "informix".sp_rcda_repro_cobranza()
RETURNING 	CHAR(06) AS cod_ret,
			CHAR(80) as mensaje;
			
--VARIABLES DE EETORNO
	DEFINE	cod_ret			 CHAR(06);
	DEFINE	mensaje			 CHAR(80);
	
--DEFINICION DE VARIABLES DE CONTROL DE ERRORES 
	DEFINE  SQL_ERR          INTEGER;   
	DEFINE  ERROR_INFO       VARCHAR(180);	
	DEFINE  ISAM_ERR         INTEGER;
--DEFINICION DE VARIABLES DE PROCESO
	DEFINE	vpaso			 INTEGER;
	DEFINE	dfecha			 DATE;			
			
BEGIN			
  ON EXCEPTION SET SQL_ERR, ISAM_ERR,ERROR_INFO
	  LET  cod_ret      = 	SQL_ERR;
	  LET  mensaje  = 	ERROR_INFO || ' sp_rcda_repro_cobranza en paso ' || vpaso;	  
	  RETURN cod_ret, mensaje;
   END EXCEPTION;	
   
   
   	foreach cursor1 WITH HOLD FOR
	SELECT	distinct(fecha)  
	INTO	dfecha
	FROM mi_sdodia_anterior 
	where fecha between '01/02/2015' and '01/07/2015'
	
				insert into mi_his_cobranza(fecha,sucursal,tpo_reg,cajero,num_ctes_cvdo)
					SELECT  date(fh_movimiento) as fecha, sucursal,1,usr_captura, count(*)  
					FROM bdicobranza:cb_compac_bit_realiza where date(fh_movimiento) = dfecha
					group by 1,2,3,4;

					
					let vpaso = 3;
					
					merge into mi_his_cobranza a
					USING (select  fecha_compac, sucursal,efectuo_compac,sum(num) as num,sum(monto_conv) as monto_conv,sum(imp_pagado) as imp_pagado from table( multiset (
						SELECT fecha_compac, sucursal, efectuo_compac, count(*) as num, sum(nvl(importe,0)) as monto_conv, sum(nvl(imp_pagado,0)) as imp_pagado 
						FROM bdicobranza:"informix".cb_compac 
						WHERE fecha_compac = dfecha
						group by 1,2,3
						union 
						SELECT fecha_compac, sucursal, efectuo_compac, count(*), sum(importe), sum(nvl(imp_pagado,0)) 
						FROM bdicobranza:"informix".cb_compac_his 
						WHERE fecha_compac = dfecha
						group by 1,2,3
						)) group by 1,2,3) b
					 on a.sucursal = b.sucursal and a.cajero = b.efectuo_compac
					 WHEN NOT MATCHED THEN
					 insert (a.fecha,a.sucursal,a.tpo_reg,a.cajero,a.num_conv,a.tot_mont_conv,a.tot_mont_pag)
					 values (b.fecha_compac,b.sucursal,1,b.efectuo_compac,b.num,b.monto_conv,b.imp_pagado)
					 WHEN  MATCHED THEN UPDATE
					 set    a.num_conv = b.num,
							a.tot_mont_conv = b.monto_conv,
							a.tot_mont_pag = b.imp_pagado;
				 
					
					
				let vpaso = 4;
				
				--Pago mínimo
				
				merge into bdmis:mi_his_cobranza a
				USING (select  tbl1.sucursal, tbl1.ejecutivo,tbl1.fecha, sum (pago_min) as tot_pago_min, sum (pago_realizado) as tot_pagado,sum(tbl1.num) as num 
					from table (multiset(
						SELECT sucursal,usuario::char(08) as ejecutivo,date(fecha_insert) as fecha, pago_min,pago_realizado,count(pago_min) as num  
						FROM bdicobranza:"informix".cb_evaluacion_objetiva_his 
						where fecha_insert = dFecha and (sucursal between '0001' and '2000')
						and reversado='N' and pago_min >=0
						group by 1,2,3,4,5)) tbl1 group by 1,2,3 order by sucursal, ejecutivo) b
				on a.sucursal = b.sucursal and a.cajero = b.ejecutivo and a.fecha = b.fecha
				WHEN NOT MATCHED THEN 
					insert ( a.fecha, a.sucursal,a.tpo_reg,a.cajero,a.pag_min_a_recup,a.pag_min_recup,a.num_pm)
					values ( b.fecha,b.sucursal,1,b.ejecutivo,b.tot_pago_min,b.tot_pagado,b.num)
				WHEN MATCHED THEN UPDATE
					set a.pag_min_a_recup = b.tot_pago_min, a.pag_min_recup =b.tot_pagado, a.num_pm = b.num ;

				let vpaso = 5;

				--clientes saldaron pago mínimo
				
				merge into bdmis:mi_his_cobranza a
				USING (	select  tbl1.sucursal, tbl1.ejecutivo,tbl1.fecha, sum(tbl1.num) as num_sinpm 
					from table (multiset(
						SELECT sucursal,usuario::char(08) as ejecutivo,date(fecha_insert) as fecha, count(*) as num  
						FROM bdicobranza:"informix".cb_evaluacion_objetiva_his 
						where fecha_insert = dFecha 
						and (sucursal between '0001' and '2000')
						and reversado='N' and pago_realizado >= pago_min 
						group by 1,2,3)) tbl1 group by 1,2,3 order by sucursal, ejecutivo) b
				on a.sucursal = b.sucursal and a.cajero = b.ejecutivo and a.fecha = b.fecha
				WHEN MATCHED THEN UPDATE
					set a.num_sin_pm = b.num_sinpm;
				
				let vpaso = 6;
				
				--Vencido
						
				merge into bdmis:mi_his_cobranza a
				USING (select  tbl1.sucursal, tbl1.ejecutivo,tbl1.fecha, sum (saldo_vencido) as tot_sdo_vencido, sum (pago_realizado) as tot_rec_sdovencido,sum(tbl1.num) as num 
					from table (multiset(
						SELECT sucursal,usuario::char(08) as ejecutivo,date(fecha_insert) as fecha, saldo_vencido,pago_realizado,count(saldo_vencido) as num  
						FROM bdicobranza:"informix".cb_evaluacion_objetiva_his 
						where fecha_insert = dFecha and (sucursal between '0001' and '2000')
						and reversado='N' and saldo_vencido > 0
						group by 1,2,3,4,5)) tbl1 group by 1,2,3 order by sucursal, ejecutivo) b
				on a.sucursal = b.sucursal and a.cajero = b.ejecutivo and a.fecha = b.fecha
				WHEN NOT MATCHED THEN 
					insert ( a.fecha, a.sucursal,a.tpo_reg,a.cajero,a.venc_a_recup,a.venc_recup,a.num_vencidos,num_ctes_cvdo)
					values ( b.fecha,b.sucursal,1,b.ejecutivo,b.tot_sdo_vencido,b.tot_rec_sdovencido,b.num, b.num)
				WHEN MATCHED THEN UPDATE
					set a.venc_a_recup = b.tot_sdo_vencido, a.venc_recup =b.tot_rec_sdovencido, a.num_vencidos = b.num, num_ctes_cvdo = b.num;		
					
				let vpaso = 7;
				
				--clientes pagaron vencido
						
				merge into bdmis:mi_his_cobranza a
				USING (select  tbl1.sucursal, tbl1.ejecutivo,tbl1.fecha, sum (num_1) as num
					from table (multiset(
						SELECT sucursal,usuario::char(08) as ejecutivo,date(fecha_insert) as fecha,count(saldo_vencido) as num_1  
						FROM bdicobranza:"informix".cb_evaluacion_objetiva_his 
						where fecha_insert = dFecha and (sucursal between '0001' and '2000')
						and saldo_vencido > 0 and pago_realizado >= saldo_vencido and reversado='N' 
						group by 1,2,3))tbl1 group by 1,2,3 order by sucursal,ejecutivo) b
				on a.sucursal = b.sucursal and a.cajero = b.ejecutivo and a.fecha = b.fecha
				WHEN MATCHED THEN UPDATE
					set num_sin_vencidos = b.num;
				
			let vpaso = 8;

				--poner nombre 
				merge into mi_his_cobranza a	
					USING bdinteg:si_ejecut b
						on  a.cajero = b.ejecutivo 
					WHEN  MATCHED THEN UPDATE
						set a.nombre = b.nombre;
				

				
	
	
	
	
	END foreach;
	
	RETURN '000000','PROCESO EXITOSO';
	

END
END PROCEDURE;