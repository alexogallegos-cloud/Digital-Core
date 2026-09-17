CREATE PROCEDURE "informix".sp_reporte_genera_indicadores()
RETURNING
   CHAR(6)        AS Cod_Ret
DEFINE v_fecha_hoy  DATE;
DEFINE v_fecha,d_fecha CHAR(6);
DEFINE v_fechacar CHAR(8);
DEFINE v_ctas_totales,v_ind1_cuentas,v_ind2_cuentas,v_ind3_cuentas,v_ind4_cuentas,v_totalero,v_ctas_spm,total_ctas_pagadas,v_ctas_trabajadas,v_cuentas_totales_spm, d_total_ctas_pagadas,d_ind1_cuentas,d_ind2_cuentas,d_ind3_cuentas,d_ind4_cuentas,d_ind_dif, d_ctas_trabajadas,d_cuentas_totales_spm,d_ctas_ind8,d_ctas_ind9,d_ctas_ind10,d_totalero,v_ind_dif,v_ctas_ind8,v_ctas_ind9,v_ctas_ind10 INTEGER;
DEFINE v_montos_tot,v_ind1_montos,v_ind2_montos,v_ind3_montos,v_ind4_montos,v_montos_tot_spm,v_montos_spm,total_mto_pagado,v_monto_a_pagar,d_total_mto_pagado,d_ind1_montos,d_ind2_montos,d_ind3_montos,d_ind4_montos,d_monto_a_pagar DECIMAL(18,2);
DEFINE d_porc_ind1,d_porc_ind2,d_porc_ind3,d_porc_ind4 DECIMAL(18,1);
DEFINE c_producto CHAR(4);
DEFINE d_producto CHAR(10);
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE v_sql		 CHAR(800);
DEFINE cRuta						char(100);
DEFINE v_sepa               		CHAR(2);
DEFINE pArchDescarga				CHAR(100);
DEFINE sFechaArch					CHAR(8);
DEFINE cBegin         CHAR(1);
DEFINE cCadena  CHAR (2000);
DEFINE dt_fecha_mes20_ant DATE; 
DEFINE dt_fecha_mes20_act DATE; 
DEFINE dt_fecha_mes18_ant DATE; 
DEFINE dt_fecha_mes18_act DATE; 
DEFINE dt_fecha_mes19_ant DATE;
DEFINE dt_fecha_mes21_ant DATE; 



LET cBegin           = "N";
LET  cCodRet='00000';
LET pArchDescarga				= "";
LET v_sql						= "";
LET cRuta		 				= "/RESPALDOSNEW/";
LET v_sepa                 		= '\|';
LET sFechaArch					= "";
LET cCadena  ="";
LET v_fechacar="";
LET dt_fecha_mes20_ant = date(1); 
LET dt_fecha_mes20_act = date(1); 
LET dt_fecha_mes18_ant = date(1); 
LET dt_fecha_mes18_act = date(1);
LET dt_fecha_mes19_ant = date(1);
LET dt_fecha_mes21_ant = date(1);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
         -- LET cMensajeRet= cNumCredito ||cErrorInfo;
    
          IF cBegin = "S" THEN
              ROLLBACK WORK;
           END IF;    
          --IF cBanTemp ='S' THEN
          --   DROP TABLE tmp_sucursales_pp;
          --END IF;
    
       RETURN cCodRet;
       END IF;
    END EXCEPTION;
    
   -- SET DEBUG FILE TO "/ifxsif01/ind_crd/reporte_indicadores.out";
   -- TRACE ON;
    select fecha_hoy
	into v_fecha_hoy
    from sd_fechas
	where empresa='001';
	
	LET v_fechacar= to_char(v_fecha_hoy ,'%Y%m%d');
	LET dt_fecha_mes21_ant= mdy(month(v_fecha_hoy),'21', year(v_fecha_hoy))-1 units month;
	LET dt_fecha_mes20_ant= mdy(month(v_fecha_hoy),'20', year(v_fecha_hoy))-1 units month;
	LET dt_fecha_mes19_ant= mdy(month(v_fecha_hoy),'19', year(v_fecha_hoy))-1 units month;
	LET dt_fecha_mes18_ant= mdy(month(v_fecha_hoy),'18', year(v_fecha_hoy))-1 units month;
	LET dt_fecha_mes20_act= mdy(month(v_fecha_hoy),'20', year(v_fecha_hoy));
	LET dt_fecha_mes18_act= mdy(month(v_fecha_hoy),'18', year(v_fecha_hoy));
    
    --LET v_fecha_hoy='04212020';
    
    LET sFechaArch = v_fechacar;
	
    
    select a.num_credito, a.sdo_cap_insoluto, a.monto_financiado, b.num_producto
    from sd_maesdoshist a, sd_maecred b where a.num_credito=b.num_credito 
    and monto_financiado>0 
	and fecha= dt_fecha_mes20_ant --mdy(month(v_fecha_hoy),'20', year(v_fecha_hoy))-1 units month  --'03202020'
    and b.num_producto in('6001')
    into temp creditos_cpm with no log; --1910395
  
    INSERT INTO creditos_cpm
    select a.num_credito, a.sdo_cap_insoluto, a.monto_financiado, b.num_producto
    from sd_maesdoshist a, sd_maecred b where a.num_credito=b.num_credito 
    and monto_financiado>0 
	and fecha= dt_fecha_mes18_ant  --mdy(month(v_fecha_hoy),'18', year(v_fecha_hoy))-1 units month --'03182020'
    and b.num_producto in('7000','8100','8500');
    ---into temp creditos_cpm_18 with no log;
	
	create index inx_creditos_cpm on creditos_cpm(num_credito,num_producto);
	update statistics medium for table creditos_cpm;
    
    FOREACH WITH HOLD
        SELECT DISTINCT (num_producto) INTO c_producto 
		FROM creditos_cpm
		WHERE num_credito is not null
    
        --select count(*),sum(monto_financiado) INTO v_ctas_totales, v_montos_tot
        --from creditos_cpm where num_producto= c_producto;
    
        IF c_producto='6001' THEN
            select num_credito, sum(monto)as monto from sd_movhis 
            where fecha_mov between dt_fecha_mes21_ant and dt_fecha_mes20_act-- '03212020' and '04202020'
            and codigo_fun in(select cod_fun from sd_conceptospagomanual) and codigo_ref in(7,8,10,901,907,908,909)
            and reversado='N'
            and num_credito in(select num_credito from creditos_cpm where num_producto=c_producto)
            group by 1
            into temp movhis_creditos_sum with no log; 
        ELSE
            select num_credito, sum(monto)as monto from sd_movhis 
            where fecha_mov between dt_fecha_mes19_ant and dt_fecha_mes18_act--'03192020' and '04182020'
            and codigo_fun in(select cod_fun from sd_conceptospagomanual) and codigo_ref in(7,8,10,901,907,908,909)
            and reversado='N'
            and num_credito in(select num_credito from creditos_cpm  where num_producto=c_producto)
            group by 1
            into temp movhis_creditos_sum with no log; 
        END IF;
		create index inx_movhis_creditos_sum on movhis_creditos_sum(num_credito);
		update statistics medium for table movhis_creditos_sum;
    
        select a.num_credito, a.sdo_cap_insoluto, a.monto_financiado, b.monto as monto_pagado, a.num_producto from creditos_cpm a, 
        movhis_creditos_sum b 
        where a.num_credito=b.num_credito
        and a.num_producto=c_producto
        into temp cuentas_con_pago with no log;
		create index inx_cuentas_con_pago on cuentas_con_pago(num_producto);
		update statistics medium for table cuentas_con_pago;
    
        select count(*),sum(monto_pagado) into v_ind1_cuentas, v_ind1_montos 
        from cuentas_con_pago
        where num_producto=c_producto
        and monto_pagado>monto_financiado; 
    
        select count(*),sum(monto_pagado) into v_ind2_cuentas, v_ind2_montos 
        from cuentas_con_pago
        where num_producto=c_producto
        and monto_pagado<monto_financiado; 
    
        select count(*),sum(monto_pagado) into v_ind3_cuentas, v_ind3_montos 
        from cuentas_con_pago
        where num_producto=c_producto
        and monto_pagado=monto_financiado; 
    
        IF c_producto='6001' THEN
            select a.num_credito, a.sdo_cap_insoluto, a.monto_financiado, b.num_producto
            from sd_maesdoshist a, sd_maecred b where a.num_credito=b.num_credito 
            and monto_financiado<=0 
			and fecha= dt_fecha_mes20_ant  --'03202020'
            and b.num_producto=c_producto
            into temp creditos_sin_pagomin with no log; --2507490
        ELSE    
            select a.num_credito, a.sdo_cap_insoluto, a.monto_financiado, b.num_producto
            from sd_maesdoshist a, sd_maecred b where a.num_credito=b.num_credito 
            and monto_financiado<=0 
			and fecha= dt_fecha_mes18_ant  --'03182020'
            and b.num_producto=c_producto
            into temp creditos_sin_pagomin with no log; --3189
        END IF;
		create index inx_creditos_sin_pagomin on creditos_sin_pagomin(num_producto);
		update statistics medium for table creditos_sin_pagomin;
		
		create index inx_cred_sin_pagomin on creditos_sin_pagomin(num_credito);
		update statistics medium for table creditos_sin_pagomin;
        
       -- select count(*), sum(monto_financiado) into v_cuentas_totales_spm , v_montos_tot_spm
       -- from creditos_sin_pagomin;
    
        IF c_producto='6001' THEN
            select num_credito, sum(monto)as monto from sd_movhis 
            where fecha_mov between dt_fecha_mes21_ant and dt_fecha_mes20_act--'03212020' and '04202020'
            and codigo_fun in(select cod_fun from sd_conceptospagomanual) and codigo_ref in(7,8,10,901,907,908,909)
            and reversado='N'
            and num_credito in(select num_credito from creditos_sin_pagomin where num_producto=c_producto)
            group by 1
            into temp movhis_creditos_sum_sin_pagomin with no log; --97309
        ELSE
            select num_credito, sum(monto)as monto from sd_movhis 
            where fecha_mov between dt_fecha_mes19_ant and dt_fecha_mes18_act--'03192020' and '04182020'
            and codigo_fun in(select cod_fun from sd_conceptospagomanual) and codigo_ref in(7,8,10,901,907,908,909)
            and reversado='N'
            and num_credito in(select num_credito from creditos_sin_pagomin where num_producto=c_producto)
            group by 1
            into temp movhis_creditos_sum_sin_pagomin with no log; --200
        END IF;
		create index inx_movhis_creditos_sum_sin_pagomin on movhis_creditos_sum_sin_pagomin(num_credito);
		update statistics medium for table movhis_creditos_sum_sin_pagomin;
		
        select a.num_credito, a.sdo_cap_insoluto, a.monto_financiado, b.monto as monto_pagado, a.num_producto 
        from creditos_sin_pagomin a, 
        movhis_creditos_sum_sin_pagomin b 
        where a.num_credito=b.num_credito
        into temp cuentas_pagadas_sin_pagomin with no log; --97309
		create index inx_cuentas_pagadas_sin_pagomin on cuentas_pagadas_sin_pagomin(num_credito);
		update statistics medium for table cuentas_pagadas_sin_pagomin;
		
        select count(*),sum(monto_pagado) 
        INTO v_ind4_cuentas,v_ind4_montos
        from cuentas_pagadas_sin_pagomin
		where num_credito is not null;
    
        select * from cuentas_con_pago
        into temp cuentas_totales_con_pago with no log;
    
        insert into cuentas_totales_con_pago 
        select * from cuentas_pagadas_sin_pagomin;

		create index inx_cuentas_totales_con_pago on cuentas_totales_con_pago(num_producto);
		update statistics medium for table cuentas_totales_con_pago;
		
		
    
        select count(*)into v_totalero
        from cuentas_totales_con_pago
        where num_producto=c_producto
        and monto_pagado>=sdo_cap_insoluto;
    
        select count(*), sum(monto_pagado) into v_ctas_spm,v_montos_spm
        from cuentas_pagadas_sin_pagomin
        WHERE NUM_PRODUCTO=c_producto;
    
        select count(*) ,sum(monto_pagado) INTO total_ctas_pagadas,total_mto_pagado
        from cuentas_totales_con_pago
        WHERE num_producto=c_producto;
    
        select count(*),sum(monto_financiado)
        into v_ctas_totales,v_montos_tot
        from creditos_cpm 
        where num_producto=c_producto;
        
        select count(*),sum(monto_financiado)
        into v_cuentas_totales_spm,v_montos_tot_spm
        from creditos_sin_pagomin 
        where num_producto=c_producto;
      
        
        LET v_ctas_trabajadas=v_ctas_totales+v_cuentas_totales_spm;
        LET v_monto_a_pagar=v_montos_tot+v_montos_tot_spm;
    
        LET v_ind_dif=(total_ctas_pagadas-v_ind1_cuentas-v_ind2_cuentas-v_ind3_cuentas-v_ind4_cuentas);
        LET v_ctas_ind8=(v_ctas_trabajadas-v_cuentas_totales_spm);
        LET v_ctas_ind9=(v_ctas_ind8-total_ctas_pagadas);
        LET v_ctas_ind10=(total_ctas_pagadas-v_ind4_cuentas);
        --LET v_fecha= year(v_fecha_hoy)||month(v_fecha_hoy);
        LET v_fecha= Substr(v_fechacar, 1, 6);
   
        insert into sd_reporte_indicadores
        values(v_fecha,c_producto,total_ctas_pagadas,total_mto_pagado,v_ind1_cuentas,v_ind1_montos,v_ind2_cuentas,v_ind2_montos,
        v_ind3_cuentas,v_ind3_montos,v_ind4_cuentas,v_ind4_montos,v_ind_dif, v_ctas_trabajadas,v_monto_a_pagar,v_cuentas_totales_spm,
        v_ctas_ind8,v_ctas_ind9,v_ctas_ind10,v_totalero);
    
        DROP TABLE movhis_creditos_sum;
        DROP TABLE cuentas_con_pago;
        DROP TABLE creditos_sin_pagomin;
        DROP TABLE movhis_creditos_sum_sin_pagomin;
        DROP TABLE cuentas_pagadas_sin_pagomin;
        DROP TABLE cuentas_totales_con_pago;
    END FOREACH;
    /*
    LET cCadena ='echo '||'Fecha AAAAMM'||v_sepa||'Producto TDC'||v_sepa||'Total Cuentas Pagadas'||v_sepa||'Total Monto Pagado'||v_sepa||'Indicador 1: Cuentas'||v_sepa||'Indicador 1: MontoPagado mayor PagoMinimo'||v_sepa||'Indicador 2: Cuentas'||v_sepa||'Indicador 2: MontoPagado menor PagoMinimo'||v_sepa||'Indicador 3: Cuentas'||v_sepa||'Indicador 3: MontoPagado = PagoMinimo'||v_sepa||'Indicador 4: Cuentas sin Pago Min'||v_sepa||'Indicador 4: MontoPagado'||v_sepa||'Diferencia'||v_sepa||'Cuentas Trabajadas'||v_sepa||'Monto a Pagar'||v_sepa||'Cuentas NO necesitaban pagar'||v_sepa||'Cuentas SI necesitaban pagar'||v_sepa||'Diferencia Ctas Pagadas y Ctas SI necesitaban pago'||v_sepa||'Ctas Pagadas que SI necesitaban pago'||v_sepa||'Cuentas Totaleras'||v_sepa||'Indicador 1'||v_sepa||'Indicador 2'||v_sepa||'Indicador 3'||v_sepa||'Indicador 4'||' >>'||TRIM(cRuta)||'reporte_indicadores_'||TRIM(sFechaArch)||'.txt';
	SYSTEM cCadena;
	LET cCadena='chmod 777 '||TRIM(cRuta)||'reporte_indicadores_'||TRIM(sFechaArch)||'.txt';
	System cCadena;
		
	FOREACH WITH HOLD
        SELECT fecha, CASE when num_producto='6001' then 'CLASICA'
						   when num_producto='7000' then 'PLATINO'
						   when num_producto='8100' then 'ORO'
						   when num_producto='8500' then 'GPO COPPEL' END Producto, tot_ctas_pagadas,tot_mto_pagado,ind1_cuentas,ind1_montos,ind2_cuentas,ind2_montos,
        ind3_cuentas,ind3_montos,ind4_cuentas,ind4_montos,ind_diferencia,ctas_trabajadas,monto_a_pagar,ctas_tot_sin_pagmin,ctas_indicador8,
        ctas_indicador9, ctas_indicador10, ctas_totaleras, ROUND(((ind1_cuentas/tot_ctas_pagadas)*100),1),ROUND(((ind2_cuentas/tot_ctas_pagadas)*100),1),
        ROUND(((ind3_cuentas/tot_ctas_pagadas)*100),1),ROUND(((ind4_cuentas/tot_ctas_pagadas)*100),1)
        INTO d_fecha,d_producto,d_total_ctas_pagadas,d_total_mto_pagado,d_ind1_cuentas,d_ind1_montos,d_ind2_cuentas,d_ind2_montos,
        d_ind3_cuentas,d_ind3_montos,d_ind4_cuentas,d_ind4_montos,d_ind_dif, d_ctas_trabajadas,d_monto_a_pagar,d_cuentas_totales_spm,
        d_ctas_ind8,d_ctas_ind9,d_ctas_ind10,d_totalero,d_porc_ind1,d_porc_ind2,d_porc_ind3,d_porc_ind4
        FROM sd_reporte_indicadores
        WHERE FECHA=v_fecha
        
        LET v_sql =	'echo '||d_fecha||v_sepa||d_producto||v_sepa||d_total_ctas_pagadas||v_sepa||d_total_mto_pagado||v_sepa||d_ind1_cuentas||v_sepa||d_ind1_montos||v_sepa||d_ind2_cuentas||v_sepa||d_ind2_montos||v_sepa||d_ind3_cuentas||v_sepa||d_ind3_montos||v_sepa||d_ind4_cuentas||v_sepa||d_ind4_montos||v_sepa||d_ind_dif||v_sepa||d_ctas_trabajadas||v_sepa||d_monto_a_pagar||v_sepa||d_cuentas_totales_spm||v_sepa||d_ctas_ind8||v_sepa||d_ctas_ind9||v_sepa||d_ctas_ind10||v_sepa||d_totalero||v_sepa||d_porc_ind1||'%'||v_sepa||d_porc_ind2||'%'||v_sepa||d_porc_ind3||'%'||v_sepa||d_porc_ind4||'%'||' >> '||TRIM(cRuta)||'reporte_indicadores_'||TRIM(sFechaArch)||'.txt';
	    SYSTEM v_sql;
		
    END FOREACH;
	
    */
    DROP TABLE creditos_cpm;
        
    RETURN cCodRet;

END;
END PROCEDURE;