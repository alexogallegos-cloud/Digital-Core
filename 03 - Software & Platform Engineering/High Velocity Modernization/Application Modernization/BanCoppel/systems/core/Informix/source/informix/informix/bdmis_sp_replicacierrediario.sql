CREATE PROCEDURE "informix".sp_replicacierrediario()
RETURNING VARCHAR(6),VARCHAR(80);

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
DEFINE  dult_dia_mes      Date;
DEFINE  iVal             INTEGER;
DEFINE  iVal2            INTEGER;
DEFINE  iPorCap          decimal;
DEFINE  iPorSdo          decimal;
DEFINE  iPorCol          decimal;
DEFINE  iPorTdc          decimal;
DEFINE  iDiasMes         INTEGER;
DEFINE  ibandmonto       SMALLINT;
DEFINE  dfechaantier     Date;
DEFINE  v_iAnio          INTEGER;
DEFINE  v_iMes           INTEGER;
DEFINE  v_idia           INTEGER;
DEFINE  v_iMesc          char(2);
DEFINE  v_idiac           char(2);
DEFINE  iFactor          decimal;
DEFINE  iFactorAcum          decimal;
DEFINE  iCuantos           INTEGER;
DEFINE  cVarDataErr        char(120);
DEFINE  cCodret            char(5);
-- ** HLA ** Variables para cambio de fecha sin afectación a campo diavisa (hasta que lgomez lo retire)
DEFINE	bempresa			char(3);
DEFINE	bfecha_hoy			date;
DEFINE	bfecha_ant			date;
DEFINE	bprox_fecha			date;
DEFINE	bpri_dia_mes		date;
DEFINE	bpri_hab_mes		date;
DEFINE	bult_dia_mes		date;
DEFINE	bult_hab_mes		date;
DEFINE  vsql             char(600);	
DEFINE  vstmt            char(300);
DEFINE 	vusuario            	CHAR(8);
DEFINE 	vtipo_reg           	INTEGER;
DEFINE 	vempresa            	CHAR(3);
DEFINE 	vsucursal           	CHAR(4);
DEFINE 	vejecutivo          	CHAR(8);
DEFINE 	vnombre             	CHAR(45);
DEFINE 	vproducto           	CHAR(4);
DEFINE 	vfechacierre        	CHAR(10);
DEFINE 	vnumtdc             	INTEGER;
DEFINE 	vmetanumtdc         	INTEGER;
DEFINE 	vcumpmetatdc        	MONEY;
DEFINE  vaniomes				char(06);
DEFINE  vmeta 					INTEGER;

BEGIN
ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
  LET P_COD_RET    = SQL_ERR;
  LET P_MENSAJE  = ERROR_INFO;
  insert into mi_rptcierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
  select fecha_ant,'F',P_COD_RET, P_MENSAJE  from bdmis:mi_fechas;
  RETURN P_COD_RET, P_MENSAJE;
END EXCEPTION;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values (''rcda_inicio_proceso'', (SELECT fecha_ant FROM bdinteg:si_fechas), '||
'(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

LET P_COD_RET = '00000';
LET P_MENSAJE = 'PROCESO EXITOSO';

set isolation to dirty read;
	
select empresa,fecha_hoy,fecha_ant,prox_fecha,pri_dia_mes,pri_hab_mes,ult_dia_mes,ult_hab_mes
into bempresa, bfecha_hoy, bfecha_ant, bprox_fecha, bpri_dia_mes, bpri_hab_mes, bult_dia_mes, bult_hab_mes
from bdinteg:si_fechas;

update bdmis:mi_fechas set empresa = bempresa, fecha_hoy = bfecha_hoy, fecha_ant = bfecha_ant,
prox_fecha = bprox_fecha, pri_dia_mes = bpri_dia_mes, pri_hab_mes = bpri_hab_mes,
ult_dia_mes = bult_dia_mes, ult_hab_mes = bult_hab_mes where empresa = '001';
--fecha del sistema --JYDG


select fecha_ant,day(ult_dia_mes)::int, (fecha_ant-1), fecha_hoy, ult_dia_mes into dFecha,iDiasMes, dfechaantier, dFechahoy, dult_dia_mes from bdmis:mi_fechas;

let vaniomes = year(dFecha)|| lpad(month(dFecha),2,'0');

if ( day(dFechahoy)::int) = 2 or ( day(dFechahoy)::int) = 02  then
	let iDiasMes = day(dFecha)::int;
	LET iFactor = iDiasMes;
	truncate table mi_rptsolic;
else
	let iDiasMes =iDiasMes;
	LET iFactor = iDiasMes;
end if;
let iDiasMes =iDiasMes;
-- A SOLICITUD DEL USUARIO SE QUEDA EL FACTOR COMO 30.5
LET iFactor = 30.5;
LET iFactorAcum = 0.8;
LET iFactor = iFactor;
LET iFactorAcum = iFactorAcum;
--JYDG
--// Busca si ya existen las Temporales
EXECUTE PROCEDURE sp_buscatemporal('solicis')
   INTO cCodret, cVarDataErr, iCuantos;
IF cCodret = '000' THEN
   DROP TABLE solicis;
END IF
EXECUTE PROCEDURE sp_buscatemporal('mi_rptsolic2')
   INTO cCodret, cVarDataErr, iCuantos;
IF cCodret = '000' THEN
   DROP TABLE mi_rptsolic2;
END IF
EXECUTE PROCEDURE sp_buscatemporal('tmpmi_cierresucacumtdc')
   INTO cCodret, cVarDataErr, iCuantos;
IF cCodret = '000' THEN
   DROP TABLE tmpmi_cierresucacumtdc;
END IF            
EXECUTE PROCEDURE sp_buscatemporal('tmp_saldo_act')
   INTO cCodret, cVarDataErr, iCuantos;
IF cCodret = '000' THEN
   DROP TABLE tmp_saldo_act;
END IF
EXECUTE PROCEDURE sp_buscatemporal('tmp_saldo_ant')
   INTO cCodret, cVarDataErr, iCuantos;
IF cCodret = '000' THEN
   DROP TABLE tmp_saldo_ant;
END IF
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

EXECUTE PROCEDURE sp_buscatemporal('metaprod')
   INTO cCodret, cVarDataErr, iCuantos;
IF cCodret = '000' THEN
   DROP TABLE metaprod;
END IF
-- Se agregan nuevas tablas temporales utilizadas en el cálculo nuevo de las ponderaciones - HLA - 02/03/2012
EXECUTE PROCEDURE sp_buscatemporal('metaprod_backup')
   INTO cCodret, cVarDataErr, iCuantos;
IF cCodret = '000' THEN
   DROP TABLE metaprod_backup;
END IF

EXECUTE PROCEDURE sp_buscatemporal('metaprod_backup2')
   INTO cCodret, cVarDataErr, iCuantos;
IF cCodret = '000' THEN
   DROP TABLE metaprod_backup2;
END IF
-- Se agregan nuevas tablas temporales utilizadas en el cálculo nuevo de las ponderaciones - HLA - 02/03/2012

IF NOT EXISTS(select ejecutivo from mi_rptcierresuc where fecha_cierre = dFecha) THEN

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values(''rcda_cheques_inversion'', (SELECT fecha_ant FROM bdinteg:si_fechas), '||
'(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
TRUNCATE table mi_tmpcierresuc;
insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
--Sustituye la anterior búsqueda de cuentas de cheques e inversión creciente - HLA - 16/05/2012		 
select 'APERD',chq.empresa,chq.sucursal,mae.ejecutivo,chq.producto,count(*),sum(chq.sdo_dia_ant) as monto
from bdicheq:sc_maenoc mae,bdicheq:sc_maechq chq, bdicheq:sc_producto prod
where mae.empresa = '001' and prod.empresa = chq.empresa and chq.cuenta = mae.cuenta and chq.producto not in ('1300','1800') 
and prod.producto = chq.producto and mae.fecha_alta = dFecha and chq.status_cta <> "2"
group by chq.empresa,chq.sucursal,mae.ejecutivo,chq.producto;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_cheques_inversion'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

-- CUENTAS PROAC
insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
select 'APERD', mae.empresa, proac.sucursal, mae.ejecutivo, '2300' as producto, count(*) , 0
from bdicheq:sc_proac proac, bdicheq:sc_maenoc mae
where mae.fecha_alta = dFecha and mae.empresa = '001' and cta_eje = mae.cuenta and  status_cta = 1 and        
not exists(select * from mi_tmpcierresuc mi where mi.empresa = mae.empresa and mi.sucursal = proac.sucursal and 
mi.ejecutivo = mae.ejecutivo and mi.producto = '2300')
group by 1, mae.empresa, proac.sucursal, mae.ejecutivo, 5;


LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
'(''rcda_apert_pagares'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
--Aperturas de Cuentas de Pagares
insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia,monto_ctasdia)
select 'APERP',empresa,sucursal,promotor,cod_instrum,count(*),sum(capital)
from bdinvers:sv_maeinv
where fecha_alta = dFecha
and empresa = '001' group by 1,2,3,4,5;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_apert_pagares'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
LET dFecha = dFecha;
LET v_iAnio = YEAR(dFecha);
LET v_iMes =  LPAD(MONTH(dFecha),2,0);
LET v_idia =  day(dFecha);

if v_idia < 10 then
	LET v_idiac = 0||v_idia;
else
	LET v_idiac= v_idia;
end if;

if v_iMes < 10 then
	LET v_iMesc= 0||v_iMes;
else
	LET v_iMesc= v_iMes;
end if;

LET dFechafto = v_iMesc||v_idiac||v_iAnio;
LET dFechafto = dFechafto;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
'(''rcda_solicitudes'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

BEGIN WORK;           
	 select empresa, sucursal, user_insert, num_solicitud, '6001' as num_producto, numcte, '' as num_referencia,fecha_insert
		from bdisolic:ss_solicitudes sol
		where fecha_insert = dFecha AND (num_producto not in ('6500') or user_insert = 'interact') AND
		 numcte not in (SELECT rpt.numcte FROM mi_rptsolic rpt
		 WHERE rpt.numcte = sol.numcte and rpt.sucursal = sol.sucursal)
		 and num_solicitud = ( Select min(num_solicitud) from bdisolic:ss_solicitudes soli2  
		 where fecha_insert = dFecha and soli2.numcte = sol.numcte 
		 and soli2.num_producto = sol.num_producto and soli2.status_solicitud = sol.status_solicitud and soli2.sucursal = sol.sucursal )			
	union all
	select empresa, sucursal, ejecutivo as user_insert, '' as num_solicitud, '6001' as num_producto,'' as numcte, num_referencia, fecha
	from bdisolic:ss_bitacora_precal precal
	where fecha  = dFecha AND (producto not in ('6500') or ejecutivo = 'interact' )  AND
		  num_referencia not in (SELECT rpt.num_referencia FROM mi_rptsolic rpt
								 WHERE rpt.num_referencia = precal.num_referencia and rpt.sucursal = precal.sucursal)
	and consecutivo = (SELECT min(consecutivo) FROM bdisolic:ss_bitacora_precal precali2 WHERE fecha  = dFecha AND precali2.num_referencia = precal.num_referencia
	and precali2.sucursal = precal.sucursal)
	into temp solicis with no log;
COMMIT WORK;

BEGIN WORK;
	select 'APERC' as tipo,empresa,sucursal,user_insert,num_producto, count(numcte) as num_ctasdia
		from bdmis:solicis
		where fecha_insert = dFecha and (numcte is not null or numcte <> '') and numcte > "000000000"
		group by 1,2,3,4,5
	union all
	select 'APERC' as tipo,empresa,sucursal,user_insert,num_producto,count(num_referencia) as num_ctasdia
		from bdmis:solicis
		where fecha_insert = dFecha and (num_referencia is not null or num_referencia <> '') and num_referencia > "0"
		group by 1,2,3,4,5
	into temp mi_rptsolic2 with no log;
COMMIT WORK;

BEGIN WORK;
	insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia)
	select tipo,empresa,sucursal,user_insert,num_producto, sum(num_ctasdia) as num_ctasdia
	from mi_rptsolic2 group by tipo,empresa,sucursal,user_insert,num_producto;
COMMIT WORK;

 insert into mi_rptsolic(empresa, sucursal, ejecutivo, num_producto, numcte, num_referencia, fecha_insert )
 select empresa, sucursal, user_insert, num_producto, numcte, 		 
  case when num_solicitud = '' then num_referencia  
	   when num_referencia = '' then num_solicitud
	   else '' end	as  num_referencia,		   
 fecha_insert FROM bdmis:solicis
 WHERE fecha_insert = dfecha;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_solicitudes'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;			
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
'(''rcda_tarj_entr'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
--cambia forma de obtener tarjetas entregadas - HLA - 01/03/2012
insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,num_ctasdia)
SELECT 'APERC' as tipo, empresa, sucursal, ejecutivo, '6666' as producto, sum (cantidad)  
FROM table (multiset(
select empresa,sucursal,ejecutivo ,count(*) as cantidad
from bdicred:sd_maecred where fecha_apertura = dFecha and empresa = '001'
group by 1,2,3
union all
select empresa,sucursal,ejecutivo,count(*) as cantidad
from bdicred:sd_maecredcrd where fecha_apertura = dFecha and empresa = '001' and num_producto= '6300'
group by 1,2,3)) group by empresa, sucursal, ejecutivo;
--cambia forma de obtener tarjetas entregadas - HLA - 01/03/2012		
LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_tarj_entr'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;			
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;		

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
'(''rcda_ab_re_cap'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;	
	--Abonos y retiros de  Captación
insert into mi_tmpcierresuc(tipo,producto,empresa,sucursal,ejecutivo,num_abonosctascap,monto_abonosctascap,num_retirocapta,monto_retirocapta)
select 'VENCA','9999',empresa,sucursal,usuario,sum(num_abonos),sum(sdo_abonos),sum(num_retiros),sum(sdo_retiros)
from table ( multiset(
	select empresa,sucursal,usuario,
	nvl(case when tipo = 'ABONO' then num end,0) as num_abonos,
		nvl(case when tipo = 'ABONO' then saldo end,0) as sdo_abonos,
	nvl(case when tipo = 'DISPO' then num end,0) as num_retiros,
		nvl(case when tipo = 'DISPO' then saldo end,0) as sdo_retiros
	from table ( multiset (
		 select mov.empresa,mov.sucursal,mov.usuario,count(*) as num,sum(mov.monto_tot) as saldo,
				case when mov.transacc = '0223' then 'DISPO'
					when mov.transacc = '0202' then 'ABONO'
				end as tipo
		 from bdicheq:sc_movdia_apert mov,bdicheq:sc_maechq mae
		 where mov.empresa = '001' and mov.cuenta = mae.cuenta and mov.fech_alt = dFecha and mov.producto = mov.producto and mov.empresa = mae.empresa
		 and mov.transacc in ( '0223','0202')
		 group by 1,2,3,6))
		))
group by 1,2,3,4,5;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_ab_re_cap'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
'(''rcda_ab_dis_cred'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
	--Calcular fecha del ultimo corte
select max(fecha_emision) into dFechaCorte  from bdicred:sd_encabezado2_edocta;

--Abonos y depositos de Credito
insert into mi_tmpcierresuc(tipo,producto,empresa,sucursal,ejecutivo,num_abonosctascred,monto_abonosctascred,num_retirocoloca,monto_retirocoloca, p_rec_vs_pagomin,p_rec_vs_vencido)
select  'VENCO','9999',empresa,sucursal,usuario,num_abonos,sdo_abonos,num_retiros,sdo_retiros,
  nvl(case when pagmin > 0 then ((pagvs / pagmin) * 100)::money end,0) as porce_pagmin,
  nvl(case when pagven > 0 then  ((pagvs / pagven) * 100)::money end,0) as porce_pagven
from table (multiset(
 select empresa,sucursal,usuario,
	nvl(sum(case when tipo = 'ABONO' then num end),0) as num_abonos,
	nvl(sum(case when tipo = 'ABONO' then saldo end),0) as sdo_abonos,
	nvl(sum(case when tipo = 'DISPO' then num end),0) as num_retiros,
	nvl(sum(case when tipo = 'DISPO' then saldo end),0) as sdo_retiros,
	sum(case when tipo = 'ABONO' and (edo.sdo_pagar > 0 or (capital_ven_tc + interes_ven_tc + iva_interes_ven_tc + moratorios_tc + iva_moratorios_tc) > 0 )
	then saldo else 0  end) as pagvs,
	sum(case when tipo = 'ABONO'  then edo.sdo_pagar else 0  end) as pagmin,
	sum(case when tipo = 'ABONO'  then (capital_ven_tc + interes_ven_tc + iva_interes_ven_tc + moratorios_tc + iva_moratorios_tc)
	else 0 end) as pagven
  from table( multiset(
		select  mov.empresa,mov.sucursal,mov.usuario,count(*) as num,num_credito,
		case when mov.codigo_fun = '033' and mov.codigo_ref = '1' then 'ABONO'
			 when mov.transacc_suc = '6900' then 'DISPO'
			  end as tipo,sum(mov.monto) as saldo
		from bdicred:sd_movhis mov
		where mov.fecha_mov = dFecha and mov.empresa = '001' and mov.reversado <> 'S' and mov.usuario <> 'interact'
		and ((mov.codigo_fun = '033' and mov.codigo_ref = '1') or  (mov.transacc_suc = '6900'))
		group by 1,2,3,5,6
		order by 1,2,3
	)) as mov,outer bdicred:sd_encabezado2_edocta edo
			   where  edo.num_credito = mov.num_credito and fecha_emision = dFechaCorte
				group by 1,2,3));

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_ab_dis_cred'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
'(''rcda_traspaso_his'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;	
	-- Traspaso de informacion historica
insert into mi_rptcierresuchis(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre, num_ctasdia,meta_ctasdia,p_cumpmetactas,monto_ctasdia,monto_incrementodia,meta_incremento,
p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,monto_abonosctascred, p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)
select empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre, num_ctasdia,meta_ctasdia,p_cumpmetactas,monto_ctasdia,monto_incrementodia,meta_incremento,
p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,monto_abonosctascred, p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca from mi_rptcierresuc;

--Limpia tabla para almacenar lo del dia
TRUNCATE table bdmis:mi_rptcierresuc;		
LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_traspaso_his'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

Let dFechaAnt = dFecha - Interval(1) day to day;
Let cFechaAnioAnt = TRIM((year(dFecha)-1) || '12');
Let dFechaAnioAnt = '12/31/2011';	

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
 '(''rcda_incre_saldo'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
--Nuevo Incremento de Saldo CAPTACION
--Se obtienen los saldos actuales
set isolation to dirty read;
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
into temp tmp_saldo_act WITH NO LOG;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_incre_saldo'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
 '(''rcda_saldos_2011'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

--Se obtienen los saldos del 2011
set isolation to dirty read;
select 'INCRE' as Id,empresa as empresa,sucursal as sucursal, ejecutivo as ejecutivo, producto as producto, saldo_ant::money as saldo_ant
from table ( multiset ( 
select {+INDEX(bdicheq:sc_sdodiarioc_2011 isdodiario_2011)}
	   mae.empresa, mae.sucursal,mae.producto,noc.ejecutivo,
sum(case
When day(dFechaAnioAnt)  = '31'  then nvl(sdo2.capvig31,0) Else 0 end) as saldo_ant                        
from bdicheq:sc_sdodiarioc_2011 sdo2, bdicheq:sc_maechq mae,bdicheq:sc_maenoc noc
where sdo2.cuenta >= '10000000000' and sdo2.aniomes = trim( year (dFechaAnioAnt) || lpad(month(dFechaAnioAnt),2,'0'))::integer and --sdo2.sucursal = mae.sucursal and 
mae.empresa = '001' and  mae.cuenta = sdo2.cuenta and  noc.cuenta =sdo2.cuenta and mae.empresa = noc.empresa  and mae.producto not in ('1300','1800')
group by mae.empresa, mae.sucursal,mae.producto,noc.ejecutivo))
	 into temp tmp_saldo_ant WITH NO LOG;

--Se actualizan saldos actuales con saldos del 2011
update tmp_saldo_act
set saldo_ant = (select tmp_saldo_ant.saldo_ant
   from  tmp_saldo_ant 
   where tmp_saldo_ant.empresa = tmp_saldo_act.empresa and tmp_saldo_ant.sucursal = tmp_saldo_act.sucursal and
		 tmp_saldo_ant.ejecutivo = tmp_saldo_act.ejecutivo and tmp_saldo_ant.producto = tmp_saldo_act.producto)::money
where exists (select tmp_saldo_ant.saldo_ant
   from  tmp_saldo_ant 
   where tmp_saldo_ant.empresa = tmp_saldo_act.empresa and tmp_saldo_ant.sucursal = tmp_saldo_act.sucursal and
		 tmp_saldo_ant.ejecutivo = tmp_saldo_act.ejecutivo and tmp_saldo_ant.producto = tmp_saldo_act.producto);

--Se Integra al saldo actual los promotores que están en el incremento de la sucursal en el año anterior y no en el actual para el acumulado del incremento por sucursal
insert into tmp_saldo_act (id,empresa,sucursal,ejecutivo,producto,saldo_act,saldo_ant)
select id,empresa,sucursal,ejecutivo,producto,0,saldo_ant
from tmp_saldo_ant  where not exists(select tmp_saldo_act.saldo_ant
	 from  tmp_saldo_act 
	 where tmp_saldo_ant.empresa = tmp_saldo_act.empresa and tmp_saldo_ant.sucursal = tmp_saldo_act.sucursal and
	 tmp_saldo_ant.ejecutivo = tmp_saldo_act.ejecutivo and tmp_saldo_ant.producto = tmp_saldo_act.producto);

--Se guardan los resultados en mi_tmpcierresuc
insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,monto_incrementodia)
select 'INCRE',empresa,sucursal,ejecutivo,producto,(saldo_act  - saldo_ant)::money as saldo from tmp_saldo_act;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_saldos_2011'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
 '(''rcda_saldos_PAGARES'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
--Nuevo Incremento saldo PAGARES  -- Se obtienen los saldos actuales
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
	
--Se obtienen los saldos del 2011
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

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_saldos_PAGARES'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
 '(''rcda_saldos_actualizacion'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
--Se actualizan saldos actuales con saldos del 2011
update tmp_saldo_pagare_act
set saldo_ant = (select tmp_saldo_pagare_ant.saldo_ant
   from  tmp_saldo_pagare_ant 
   where tmp_saldo_pagare_ant.empresa = tmp_saldo_pagare_act.empresa and tmp_saldo_pagare_ant.sucursal = tmp_saldo_pagare_act.sucursal and
		 tmp_saldo_pagare_ant.ejecutivo = tmp_saldo_pagare_act.ejecutivo and tmp_saldo_pagare_ant.producto = tmp_saldo_pagare_act.producto)::money
where exists (select tmp_saldo_pagare_ant.saldo_ant
   from  tmp_saldo_pagare_ant 
   where tmp_saldo_pagare_ant.empresa = tmp_saldo_pagare_act.empresa and tmp_saldo_pagare_ant.sucursal = tmp_saldo_pagare_act.sucursal and
		 tmp_saldo_pagare_ant.ejecutivo = tmp_saldo_pagare_act.ejecutivo and tmp_saldo_pagare_ant.producto = tmp_saldo_pagare_act.producto);

--Se Integra al saldo actual los promotores que están en el incremento de la sucursal en el año anterior y no en el actual para el acumulado del incremento por sucursal
insert into tmp_saldo_pagare_act (id,empresa,sucursal,ejecutivo,producto,saldo_act,saldo_ant)
select id,empresa,sucursal,ejecutivo,producto,0,saldo_ant
from tmp_saldo_pagare_ant 
where not exists(select tmp_saldo_pagare_act.saldo_ant from  tmp_saldo_pagare_act 
	 where tmp_saldo_pagare_ant.empresa = tmp_saldo_pagare_act.empresa and tmp_saldo_pagare_ant.sucursal = tmp_saldo_pagare_act.sucursal and
		 tmp_saldo_pagare_ant.ejecutivo = tmp_saldo_pagare_act.ejecutivo and tmp_saldo_pagare_ant.producto = tmp_saldo_pagare_act.producto);

--Se guardan los resultados en mi_tmpcierresuc
insert into mi_tmpcierresuc(tipo,empresa,sucursal,ejecutivo,producto,monto_incrementodia)
select 'INCRE',empresa,sucursal,ejecutivo,producto,(saldo_act  - saldo_ant)::money as saldo
from tmp_saldo_pagare_act;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_saldos_actualizacion'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

--ACTUALIZA METAS A LOS GERENTES PARA QUE SEA CERO
BEGIN WORK;
update mi_tmpcierresuc set meta_ctasdia = 0, meta_incremento = 0
where ejecutivo in (select ejecutivo from bdinteg:si_ejecut where puesto = '001');
COMMIT WORK;

--Nuevo calculo de porcentaje obteniendo las metas divididas entre numero de promotores por sucursal LAGS - 17/01/2012
LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
'(''rcda_insert_rptcierresuc'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

set isolation to dirty read;
select num_sucursal,
(meta_acu_cap +  ((metasuc.meta_men_cap / 30.5) * day(dfecha)))::money / nvl (num,1) as metacapdia,     
(meta_acu_col +  ((meta_men_col / 30.5) * day(dfecha)))::money   as metacoldia
from table ( multiset (
select metasuc1.num_sucursal , metasuc1.id_tiposuc, ejec.num, meta_acu_cap, meta_acu_col, meta_men_cap, meta_men_col                    
from table ( multiset (
select li.num_sucursal,tpo.id_tiposuc,
sum(case when tpo.aniomes[5,6] < MONTH(dfecha) then meta_monto_cap else 0 end) as meta_acu_cap,
sum(case when tpo.aniomes[5,6] < MONTH(dfecha) then meta_monto_col else 0 end) as meta_acu_col,
sum(case when tpo.aniomes[5,6] = MONTH(dfecha) then meta_monto_cap else 0 end) as meta_men_cap,
sum(case when tpo.aniomes[5,6] = MONTH(dfecha) then meta_monto_col else 0 end) as meta_men_col
from mi_sucursalesinfo li,mi_tiposuc tpo
where tpo.id_tiposuc = tipo_suc and tpo.aniomes[1,4] = YEAR(dfecha)  and  tpo.aniomes[5,6] <= MONTH(dfecha)                            
 group by 1,2
)) as metasuc1, table ( multiset ( 
select sucursal , count(ejecutivo) as num from bdinteg:si_ejecut where password <> 'BAJA' and puesto = '003' GROUP BY sucursal)) 							
as ejec where metasuc1.num_sucursal = ejec.sucursal))as metasuc
into temp metaprod WITH NO LOG;

--Se agrega	nueva tabla temporal para guardar datos de la meta de incremento en cálculo de ponderaciones - HLA - 01/03/2012						
select num_sucursal, metacapdia from metaprod
into temp metaprod_backup;



		insert into mi_rptcierresuc(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia,
	monto_ctasdia,p_cumpmetactas,meta_ctasdia,
	monto_incrementodia,meta_incremento,p_cumpsaldo,num_abonosctascap,monto_abonosctascap,num_abonosctascred,
	monto_abonosctascred,p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,num_acuerdopago,num_cons_edocta,
	num_retirocapta,monto_retirocapta,num_retirocoloca,monto_retirocoloca)
		select  tmp.empresa,tmp.sucursal,tmp.ejecutivo,si.nombre,tmp.producto,dfecha,num_ctasdia,monto_ctasdia,
		nvl((case when num_ctasdia > 0 and mp.metanum > 0 then ((num_ctasdia / mp.metanum) * 100) else 0 end)::money,0) as p_cumpmetactas,
		nvl(MP.METANUM,0) as meta_numero,nvl((monto_incrementodia )::money,0) as  monto_incrementodia,
		nvl(CASE WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 1) THEN metacapdia
				 WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 3) THEN metacapdia
				 WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 6) THEN metacoldia END,0) AS meta_monto,
		nvl((case when monto_incrementodia > 0  and (CASE WHEN tmp.producto IN (select producto  from bdicheq: sc_producto) THEN meta_monto_cap
			 WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 3) THEN metacapdia
			 WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 6) THEN metacoldia END) > 0 then (((monto_incrementodia ) / (CASE WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 1) THEN meta_monto_cap
			 WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 3) THEN metacapdia
			 WHEN tmp.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 6) THEN metacoldia END)) * 100) else 0 end)::money,0)  as    p_cumpsaldo,
		num_abonosctascap, monto_abonosctascap,num_abonosctascred,monto_abonosctascred, p_rec_vs_pagomin,p_rec_vs_vencido,num_clientel_act,num_compago,
		num_acuerdopago,num_cons_edocta,num_retirocapta,monto_retirocapta, num_retirocoloca,monto_retirocoloca
	from table (multiset(
		select tmp.empresa, tmp.sucursal,tmp.ejecutivo,tmp.producto,
			sum(tmp.num_ctasdia) as num_ctasdia ,sum(tmp.meta_ctasdia) as meta_ctasdia ,sum(tmp.monto_ctasdia) as monto_ctasdia,
			sum(tmp.monto_incrementodia) as monto_incrementodia ,sum(tmp.p_cumpsaldo) as p_cumpsaldo,sum(tmp.num_abonosctascap) as num_abonosctascap,
			sum(tmp.monto_abonosctascap) as monto_abonosctascap,sum(tmp.num_abonosctascred) as num_abonosctascred,sum(tmp.monto_abonosctascred) as monto_abonosctascred,
			sum(tmp.p_rec_vs_pagomin) as p_rec_vs_pagomin,sum(tmp.p_rec_vs_vencido) as p_rec_vs_vencido,sum(tmp.num_clientel_act) as num_clientel_act,sum(tmp.num_compago) as num_compago,
			sum(tmp.num_acuerdopago) as num_acuerdopago,sum(tmp.num_cons_edocta) as num_cons_edocta ,
			sum(tmp.num_retirocapta) as num_retirocapta,sum(tmp.monto_retirocapta) as monto_retirocapta,sum(tmp.num_retirocoloca) as num_retirocoloca,sum(tmp.monto_retirocoloca) as monto_retirocoloca
			from mi_tmpcierresuc tmp
			group by  1,2,3,4
				)) tmp,
	bdinteg:si_ejecut si, bdmis:mi_sucursalesinfo suc,  outer bdmis:mi_metasprod mp, outer bdmis:mi_tiposuc ts, metaprod
	where si.ejecutivo = tmp.ejecutivo 
	and si.empresa ='001'
	AND TMP.SUCURSAL = SUC.NUM_SUCURSAL AND SUC.TIPO_SUC = MP.ID_TIPOSUC AND TMP.PRODUCTO = MP.PRODUCTO AND TS.ID_TIPOSUC = SUC.TIPO_SUC AND
	MP.ANIOMES = YEAR(dfecha) ||  LPAD( MONTH(dfecha),2,'00') AND TS.ANIOMES = YEAR(dfecha) ||  LPAD(MONTH(dfecha),2,'00') and  metaprod.num_sucursal = tmp.sucursal;
	
-- borrar interact de mi_rptcierresuc		
delete from mi_rptcierresuc where ejecutivo ='interact';

--incluir  solicitudes de usuario interact  en tabla mi_rptcierresuc		
--incluir  solicitudes de usuario interact  en tabla mi_rptcierresuc
insert into mi_rptcierresuc(empresa,sucursal,ejecutivo,nombre,producto,fecha_cierre,num_ctasdia)
			select empresa, sucursal, ejecutivo, nombre, producto,dfecha , num_ctasdia 
			from mi_tmpcierresuc where ejecutivo = 'interact';	

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_insert_rptcierresuc'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
  '(''rcda_acumule_mensual'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
--Calcular la tabla de acumulado mensual --Modifico MANUEL OSUNA 05/05/2011
truncate table mi_rptcierresucacumulejecut;

insert into mi_rptcierresucacumulejecut(empresa,sucursal,ejecutivo,nombre,producto,aniomes,num_ctasmes,monto_ctasmes,p_cumpmetactasmes,
meta_ctasmes,monto_incrementomes,meta_incrementomes,p_cumpsaldomes,num_abonosctascapmes,monto_abonosctascapmes,num_abonosctascredmes,
monto_abonosctascredmes,num_retirocaptames,monto_retirocaptames,num_retirocolocames,monto_retirocolocames)
select tmp.empresa,tmp.sucursal,tmp.ejecutivo,si.nombre,tmp.producto,
trim( year (dFecha) || lpad(month(dFecha),2,'0'))::integer   as fecha_cierre, num_ctasdia,monto_ctasdia,
case when num_ctasdia > 0  and producto <> '9999'  and meta_numero > 0
		then ((num_ctasdia / meta_numero) * 100)::money
 else 0
end as p_cumpmetactasmes, meta_numero,monto_incrementomes,meta_monto,
case when monto_incrementomes >  0  and producto <> '9999'  and meta_monto > 0
		then ((monto_incrementomes /  meta_monto) * 100)::money
 else 0
end as p_cumpsaldomes, num_abonosctascap,monto_abonosctascap,num_abonosctascred,monto_abonosctascred,num_retirocapta,monto_retirocapta, num_retirocoloca,monto_retirocoloca
from table(multiset(
	select  metahis.empresa, metahis.sucursal, metahis.ejecutivo, metahis.producto, metahis.num_ctasdia,
metahis.monto_ctasdia,round(nvl((((mp.metanum * 24) / 30 ) * day(dFecha)),0)) as meta_numero,
nvl((CASE WHEN METAHIS.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 1) THEN metacapmes
							 WHEN METAHIS.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 3) THEN metacapmes
							 WHEN METAHIS.producto IN (select num_producto from bdmis:mi_producto where num_sistema = 6) THEN metacolmes END),0) as meta_monto
,metahis.num_abonosctascap, metahis.monto_abonosctascap, metahis.num_abonosctascred, metahis.monto_abonosctascred,metahis.num_retirocapta,metahis.monto_retirocapta,
metahis.num_retirocoloca, metahis.monto_retirocoloca, metahis.monto_incrementomes
FROM TABLE (MULTISET(                select empresa, sucursal, ejecutivo, producto,
	sum(num_ctasdia) as num_ctasdia,sum(monto_ctasdia) as monto_ctasdia,
	sum(num_abonosctascap) as num_abonosctascap,sum(monto_abonosctascap) as monto_abonosctascap,
	sum(num_abonosctascred) as num_abonosctascred,sum(monto_abonosctascred) as monto_abonosctascred,
	sum(num_retirocapta) as num_retirocapta,sum(monto_retirocapta) as monto_retirocapta,
	sum(num_retirocoloca) as num_retirocoloca,sum(monto_retirocoloca) as monto_retirocoloca,
   sum(monto_incrementomes)  as monto_incrementomes 								   
   from table (multiset(		
select    his.empresa,his.sucursal,his.ejecutivo,his.producto,
	sum(his.num_ctasdia) as num_ctasdia,sum(his.monto_ctasdia) as monto_ctasdia,
	sum(num_abonosctascap) as num_abonosctascap,sum(monto_abonosctascap) as monto_abonosctascap,
	sum(num_abonosctascred) as num_abonosctascred,sum(monto_abonosctascred) as monto_abonosctascred,
	sum(num_retirocapta) as num_retirocapta,sum(monto_retirocapta) as monto_retirocapta,
	sum(num_retirocoloca) as num_retirocoloca,sum(monto_retirocoloca) as monto_retirocoloca,
   sum(monto_incrementodia)  as monto_incrementomes
from mi_rptcierresuchis his
where month(his.fecha_cierre) = month (dFecha) and year(his.fecha_cierre) = year(dFecha)
group by his.empresa,his.sucursal,his.ejecutivo,his.producto    
union all 
select    his.empresa,his.sucursal,his.ejecutivo,his.producto,
	sum(his.num_ctasdia) as num_ctasdia,sum(his.monto_ctasdia) as monto_ctasdia,
	sum(num_abonosctascap) as num_abonosctascap,sum(monto_abonosctascap) as monto_abonosctascap,
	sum(num_abonosctascred) as num_abonosctascred,sum(monto_abonosctascred) as monto_abonosctascred,
	sum(num_retirocapta) as num_retirocapta,sum(monto_retirocapta) as monto_retirocapta,
	sum(num_retirocoloca) as num_retirocoloca,sum(monto_retirocoloca) as monto_retirocoloca,
   sum(monto_incrementodia)  as monto_incrementomes
from mi_rptcierresuc his
where month(his.fecha_cierre) = month (dFecha) and year(his.fecha_cierre) = year(dFecha)
group by his.empresa,his.sucursal,his.ejecutivo,his.producto ))
group by empresa, sucursal, ejecutivo, producto)) AS METAHIS,
outer table ( multiset ( select num_sucursal as sucursal, metacapdia as metacapmes ,metacoldia as metacolmes from metaprod)) as metaprod ,
		outer BDMIS: MI_METASPROD MP,BDMIS: MI_SUCURSALESINFO SUC, BDMIS: MI_TIPOSUC TS
WHERE metahis.sucursal = suc.num_sucursal and suc.tipo_suc = mp.id_tiposuc and metahis.producto = mp.producto and ts.id_tiposuc = suc.tipo_suc
AND MP.ANIOMES = YEAR(dFecha) ||  LPAD( MONTH(dFecha),2,'00') AND TS.ANIOMES = YEAR(dFecha) ||  LPAD(MONTH(dFecha),2,'00') and  metaprod.sucursal = metahis.sucursal
)) tmp,
outer bdinteg:si_ejecut si where tmp.ejecutivo = si.ejecutivo;

-- borrar interact de mi_rptcierresucacumulejecut		
delete from mi_rptcierresucacumulejecut where ejecutivo ='interact';

--incluir  solicitudes de usuario interact  en tabla mi_rptcierresucacumulejecut
insert into mi_rptcierresucacumulejecut(empresa,sucursal,ejecutivo,nombre,producto,aniomes,num_ctasmes)
	select empresa, sucursal, ejecutivo, nombre, producto,year(dfecha)||lpad(month(dfecha),2,'0') , num_ctasdia 
	from mi_tmpcierresuc where ejecutivo = 'interact';
			
LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_acumule_mensual'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
	
--Se agrega	nueva tabla temporal para guardar datos de la meta de incremento mensual en cálculo de ponderaciones - HLA - 01/03/2012		
select num_sucursal,
( meta_acu_cap +  ((meta_men_cap / 30.5) * day(dFecha)))::money as metacapmes
from table ( multiset (
select li.num_sucursal,tpo.id_tiposuc,
sum(case when tpo.aniomes[5,6] < MONTH(dFecha) then meta_monto_cap else 0 end) as meta_acu_cap ,
sum(case when tpo.aniomes[5,6] = MONTH(dFecha) then meta_monto_cap else 0 end) as meta_men_cap
from mi_sucursalesinfo li,mi_tiposuc tpo
where tpo.id_tiposuc = tipo_suc and tpo.aniomes[1,4] = YEAR(dFecha)  and  tpo.aniomes[5,6] <= MONTH(dFecha)
group by 1,2))
into temp metaprod_backup2;
--Se agrega	nueva tabla temporal para guardar datos de la meta de incremento mensual en cálculo de ponderaciones - HLA - 01/03/2012		

-- CALCULO DE PONDERACIONES(PARAMETROS)
select sum(case when parametro = 1 then valor end) as capt,
sum(case when parametro = 2 then valor end) as saldo,
sum(case when parametro = 3 then valor end) as col,
sum(case when parametro = 4 then valor end) as tdc
into iPorCap,iPorSdo,iPorCol, iPorTdc from mi_paramcump;

LET iPorCap = iPorCap;
LET iPorSdo = iPorSdo;
LET iPorCol = iPorCol;
LET iPorTdc = iPorTdc;

TRUNCATE table mi_rptcierresucpgeneral;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
 '(''rcda_sucgeneral'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

insert into mi_rptcierresucpgeneral(empresa,sucursal,ejecutivo,nombre,fecha_cierre,p_cumdia_capta,
p_cumdia_saldo,p_cumdia_coloca,p_cumdia_tdc,p_cumdia_general,p_cummes_capta,p_cummes_saldo,p_cummes_coloca,p_cummes_tdc, p_cummes_general)
select empresa,sucursal,ejecutivo,nombre,dFecha,cump_cap_dia,cump_sdo_dia,cump_col_dia,cump_tdc_dia,
(cump_cap_dia + cump_sdo_dia + cump_col_dia + cump_tdc_dia) as cump_gral_dia, cump_cap_mes,cump_sdo_mes,cump_col_mes,cump_tdc_mes,
(cump_cap_mes +cump_sdo_mes + cump_col_mes + cump_tdc_mes ) as cum_gral_mes
from table (multiset(
select empresa,sucursal,ejecutivo,nombre,
nvl(sum(
		case when meta_ctasdia_cap > 0 and tipo = '1'  and  (((num_ctasdia_cap / meta_ctasdia_cap ) * 100)::money  > 120 )  then  ((120 * iPorCap)::money)
			 when meta_ctasdia_cap > 0 and tipo = '1'  and  (((num_ctasdia_cap / meta_ctasdia_cap ) * 100)::money  < 120 )  then (((num_ctasdia_cap / meta_ctasdia_cap ) * 100) * iPorCap)::money end),0) as cump_cap_dia,
nvl(sum(case when meta_incremento_sdo > 0 and tipo = '1'  and  (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100)::money  > 120 )  then  ((120 * iPorSdo)::money)
			 when meta_incremento_sdo > 0 and tipo = '1'  and  (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100)::money  < 120 )  then (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100) * iPorSdo)::money  end),0) as cump_sdo_dia,
nvl(sum(case when meta_ctasdia_col > 0 and tipo = '1'  and  (((num_ctasdia_col / meta_ctasdia_col ) * 100)::money  > 120 )  then  ((120 * iPorCol)::money)
			 when meta_ctasdia_col > 0 and tipo = '1'  and  (((num_ctasdia_col / meta_ctasdia_col ) * 100)::money  < 120 )  then (((num_ctasdia_col / meta_ctasdia_col ) * 100) * iPorCol)::money end),0) as cump_col_dia,
nvl(sum(case when meta_ctasdia_TDC > 0 and tipo = '1'  and  (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100)::money  > 120 )  then  ((120 * iPorTdc)::money)
			 when meta_ctasdia_TDC > 0 and tipo = '1'  and  (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100)::money  < 120 )  then (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100) * iPorTdc)::money end),0) as cump_tdc_dia,

nvl(sum(case when meta_ctasdia_cap > 0 and tipo = '2'  and  (((num_ctasdia_cap / meta_ctasdia_cap ) * 100)::money  > 120 )  then  ((120 * iPorCap)::money)
			 when meta_ctasdia_cap > 0 and tipo = '2'  and  (((num_ctasdia_cap / meta_ctasdia_cap ) * 100)::money  < 120 )  then (((num_ctasdia_cap / meta_ctasdia_cap ) * 100) * iPorCap)::money end),0) as cump_cap_mes,
nvl(sum(case when meta_incremento_sdo > 0 and tipo = '2'  and  (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100)::money  > 120 )  then  ((120 * iPorSdo)::money)
			 when meta_incremento_sdo > 0 and tipo = '2'  and  (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100)::money  < 120 )  then (((monto_incrementodia_sdo / meta_incremento_sdo ) * 100) * iPorSdo)::money end),0) as cump_sdo_mes,
nvl(sum(case when meta_ctasdia_col > 0 and tipo = '2'  and  (((num_ctasdia_col / meta_ctasdia_col ) * 100)::money  > 120 )  then  ((120 * iPorCol)::money)
			 when meta_ctasdia_col > 0 and tipo = '2'  and  (((num_ctasdia_col / meta_ctasdia_col ) * 100)::money  < 120 )  then (((num_ctasdia_col / meta_ctasdia_col ) * 100) * iPorCol)::money end),0) as cump_col_mes,
nvl(sum(case when meta_ctasdia_TDC > 0 and tipo = '2'  and  (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100)::money  > 120 )  then  ((120 * iPorTdc)::money)
			 when meta_ctasdia_TDC > 0 and tipo = '2'  and  (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100)::money  < 120 )  then (((num_ctasdia_TDC / meta_ctasdia_TDC ) * 100) * iPorTdc)::money end),0) as cump_tdc_mes

from table(multiset (
	select  '1' as tipo,suc.empresa,suc.sucursal,suc.ejecutivo,suc.nombre,
	nvl(sum(case when pro.num_sistema in ('1','3')  then num_ctasdia end),0) as num_ctasdia_cap,
	nvl(sum(case when pro.num_sistema in ('1','3') then meta_ctasdia end),0) as meta_ctasdia_cap,
	nvl(sum(case when pro.num_sistema in ('1','3') then monto_incrementodia end),0) as monto_incrementodia_sdo,
	(select metacapdia from metaprod_backup where num_sucursal = suc.sucursal) as meta_incremento_sdo,
	nvl(sum(case when pro.num_sistema = '6' and suc.producto <> '6666' then num_ctasdia end),0) as num_ctasdia_col,
	nvl(sum(case when pro.num_sistema = '6' and suc.producto <> '6666' then meta_ctasdia end),0) as meta_ctasdia_col,
	nvl(sum(case when pro.num_sistema = '6' and suc.producto = '6666' then num_ctasdia end),0) as num_ctasdia_TDC,
	nvl(sum(case when pro.num_sistema = '6' and suc.producto = '6666' then meta_ctasdia end),0) as meta_ctasdia_TDC
	from bdmis:mi_rptcierresuc suc,bdmis:mi_producto pro
	where pro.num_producto = suc.producto and suc.producto <> '9999'
	group by suc.empresa,suc.sucursal,suc.ejecutivo,suc.nombre
	union
	select  '2' as tipo,eje.empresa,eje.sucursal,eje.ejecutivo,eje.nombre,
	nvl(sum(case when pro.num_sistema in ('1','3') then eje.num_ctasmes end),0) as num_ctasmes_cap,
	nvl(sum(case when pro.num_sistema in ('1','3') then eje.meta_ctasmes end),0) as meta_ctasmes_cap,
	nvl(sum(case when pro.num_sistema in ('1','3') then eje.monto_incrementomes end),0) as monto_incrementomes_sdo,(select metacapmes from metaprod_backup2 where num_sucursal = eje.sucursal) as meta_incrementomes_sdo,									
	nvl(sum(case when pro.num_sistema = '6' and eje.producto <> '6666' then eje.num_ctasmes end),0) as num_ctasmes_col,
	nvl(sum(case when pro.num_sistema = '6' and eje.producto <> '6666' then eje.meta_ctasmes end),0) as meta_ctasmes_col,
	nvl(sum(case when pro.num_sistema = '6' and eje.producto = '6666' then num_ctasmes end),0) as num_ctasmes_TDC,
	nvl(sum(case when pro.num_sistema = '6' and eje.producto = '6666' then meta_ctasmes end),0) as meta_ctasmes_TDC
	from bdmis:mi_rptcierresucacumulejecut  eje,bdmis:mi_producto pro
	where pro.num_producto = eje.producto and eje.producto <> '9999' and ejecutivo <> 'interact'
	group by eje.empresa,eje.sucursal,eje.ejecutivo,eje.nombre))
	   group by empresa,sucursal,ejecutivo,nombre));

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_sucgeneral'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
			   
TRUNCATE table bdmis:mi_rptcierresucestatus;

insert into mi_rptcierresucestatus(sucursal,fecha_rptcierre)
select sucinf.num_sucursal,dFecha 
			from "informix".mi_sucursalesinfo sucinf, bdinteg:si_sucursales suc
			where sucinf.num_sucursal = suc.sucursal and sucinf.num_sucursal < 8000 and suc.tpo_sucursal = 'S'; -- Carlos F. Flores Verdugo 23/10/2017 Se cambia num. de sucursal hasta 8000 y se agrega tipo sucursal igual a S

--Calcular el Acumulado mensual
insert into mi_rptcierresucerror values (dFecha,'V',P_COD_RET,P_MENSAJE );

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
'(''rcda_intprom_virtual'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
	
execute PROCEDURE sp_integrapromotorvirtualdia()
	INTO P_COD_RET, P_MENSAJE;
IF P_COD_RET <> '000' THEN
	RETURN P_COD_RET, P_MENSAJE;
END IF;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_intprom_virtual'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;	

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
 '(''rcda_obt_info_dia'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

execute PROCEDURE sp_obtieneinfocierrediariosucDia(dFecha)
	INTO P_COD_RET, P_MENSAJE;
IF P_COD_RET <> '00000' THEN
	RETURN P_COD_RET, P_MENSAJE;
END IF;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_obt_info_dia'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;		

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
 '(''rcda_int_solic'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
--Actualización de tmp_cifrascierresuc para presentación de Metas LAGS.
--1)Inserción de Solicitudes de TDC para ejecutivos que solo tienen TDC entregadas
insert into tmp_cifrascierresuc(usuario,tipo_reg,empresa,sucursal,ejecutivo,nombre,producto,fechacierre,numtdc,metanumtdc,cumpmetatdc, metactasdia)
 select cf.usuario,'2',cf.empresa,cf.sucursal,cf.ejecutivo,cf.nombre,'6001',cf.fechacierre,cf.numtdc,cf.metanumtdc,cf.cumpmetatdc,
(SELECT mt.metanum FROM mi_metasprod mt, mi_sucursalesinfo si
				where  mt.aniomes = vaniomes and mt.id_tiposuc = si.tipo_suc and mt.producto  = '6001' 
				and si.num_sucursal = cf.sucursal  )
from tmp_cifrascierresuc cf
where producto = '6666'
and not cf.ejecutivo in (select ejecutivo from tmp_cifrascierresuc where producto = '6001' and tipo_reg = '2' ) and length(cf.fechacierre) = 10;

insert into tmp_cifrascierresuc(usuario,tipo_reg,empresa,sucursal,ejecutivo,nombre,producto,fechacierre,numtdc,metanumtdc,cumpmetatdc,metactasdia)
select cf.usuario,'6',cf.empresa,cf.sucursal,cf.ejecutivo,cf.nombre,'6001',cf.fechacierre,cf.numtdc,cf.metanumtdc,cf.cumpmetatdc, 
(SELECT nvl(round(((mt.metanum * 24) / 30) * day(dFecha)),0)
		FROM mi_metasprod mt, mi_sucursalesinfo si
		where  mt.aniomes = vaniomes and mt.id_tiposuc = si.tipo_suc and mt.producto  = '6001' 
		and si.num_sucursal = cf.sucursal  )
from tmp_cifrascierresuc cf
where producto = '6666'
and not cf.ejecutivo in (select ejecutivo from tmp_cifrascierresuc where producto = '6001' and tipo_reg = '6' ) and length(cf.fechacierre) = 6;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_int_solic'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
--2)Actualización de metas de solicitudes de TDC

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
   '(''rcda_act_metas'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

	begin work;
	update bdmis:tmp_cifrascierresuc set numtdc = 0, cumpmetatdc = 0, metanumtdc = 0 where tipo_reg in ('2','6') and producto = '6001';
	commit work;

LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_act_metas'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
--3)Actualización de TDC entregadas que trae el producto 6666 sobre los registros del producto 6001

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values'||
'(''rcda_act_tdc'', (SELECT fecha_ant FROM bdinteg:si_fechas), (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;

select sucursal,ejecutivo,numtdc,metanumtdc,cumpmetatdc from tmp_cifrascierresuc where producto = '6666' AND length(fechacierre) = 10  INTO TEMP tmpmi_cierresuctdc;

begin work;
update tmp_cifrascierresuc set (numtdc,metanumtdc,cumpmetatdc) =
((select numtdc,metanumtdc,cumpmetatdc from tmpmi_cierresuctdc
where ejecutivo = tmp_cifrascierresuc.ejecutivo AND sucursal = tmp_cifrascierresuc.sucursal
))where producto  = '6001' and tipo_reg = '2';
commit work;

select sucursal,ejecutivo,numtdc,metanumtdc,cumpmetatdc from tmp_cifrascierresuc where producto = '6666' AND length(fechacierre) = 6   INTO TEMP tmpmi_cierresucacumtdc;

begin work;
update tmp_cifrascierresuc set (numtdc,metanumtdc,cumpmetatdc) =
((select numtdc,metanumtdc,cumpmetatdc from tmpmi_cierresucacumtdc
where ejecutivo = tmp_cifrascierresuc.ejecutivo AND sucursal = tmp_cifrascierresuc.sucursal
))where producto  = '6001' and tipo_reg = '6';
commit work;
	
LET vsql = 'echo "UPDATE bdmis:mi_bitacora_rcda SET hora_fin  = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
'WHERE proceso   =''rcda_act_tdc'' AND fecha = (SELECT fecha_ant FROM bdinteg:si_fechas)   ;" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
--4)Borrado de registros del producto 6666 para evitar presentación en el reporte
	delete from bdmis:tmp_cifrascierresuc where tipo_reg in ('2','6') and producto = '6666';

--5)Actualización de metas de ejecutivos que están en nulo o ceros

begin work;
update tmp_cifrascierresuc  set tmp_cifrascierresuc.metactasdia = (select nvl(round(((metanum * 24) / 30) * day(dFecha)),0) from mi_metasprod where producto = '6001' and id_tiposuc = (select tipo_suc from mi_sucursalesinfo 
where num_sucursal = tmp_cifrascierresuc.sucursal) and aniomes = tmp_cifrascierresuc.fechacierre)
where tmp_cifrascierresuc.producto = '6001' and tmp_cifrascierresuc.tipo_reg = '6' and length(tmp_cifrascierresuc.fechacierre) = 6 and
	(tmp_cifrascierresuc.metactasdia = 0 or tmp_cifrascierresuc.metactasdia is null);
	commit work;

begin work;
update tmp_cifrascierresuc set tmp_cifrascierresuc.metactasdia = (select metanum from mi_metasprod where producto = '6666' and id_tiposuc = (select tipo_suc from mi_sucursalesinfo 
where num_sucursal = tmp_cifrascierresuc.sucursal) and aniomes = (substring(tmp_cifrascierresuc.fechacierre FROM 7 FOR 10) || substring(tmp_cifrascierresuc.fechacierre FROM 1 FOR 2)))
where tmp_cifrascierresuc.producto = '6001' and tmp_cifrascierresuc.tipo_reg = '2' and length(tmp_cifrascierresuc.fechacierre) = 10 and
(tmp_cifrascierresuc.metactasdia = 0 or tmp_cifrascierresuc.metactasdia is null);
	commit work;

begin work;
update tmp_cifrascierresuc set tmp_cifrascierresuc.metanumtdc  = (select nvl(round(((metanum * 24) / 30) * day(dFecha)),0) from mi_metasprod where producto = '6666' and id_tiposuc = (select tipo_suc from mi_sucursalesinfo 
where num_sucursal = tmp_cifrascierresuc.sucursal) and aniomes = tmp_cifrascierresuc.fechacierre)
where tmp_cifrascierresuc.producto = '6001' and tmp_cifrascierresuc.tipo_reg = '6' and length(tmp_cifrascierresuc.fechacierre) = 6 and
	(tmp_cifrascierresuc.metanumtdc  = 0 or tmp_cifrascierresuc.metanumtdc  is null);
	commit work;

begin work;
update tmp_cifrascierresuc set tmp_cifrascierresuc.metanumtdc  = (select metanum from mi_metasprod where producto = '6666' and id_tiposuc = (select tipo_suc from mi_sucursalesinfo 
where num_sucursal = tmp_cifrascierresuc.sucursal) and aniomes = (substring(tmp_cifrascierresuc.fechacierre FROM 7 FOR 10) || substring(tmp_cifrascierresuc.fechacierre FROM 1 FOR 2)))
where tmp_cifrascierresuc.producto = '6001' and tmp_cifrascierresuc.tipo_reg = '2' and length(tmp_cifrascierresuc.fechacierre) = 10 and
	(tmp_cifrascierresuc.metanumtdc = 0 or tmp_cifrascierresuc.metanumtdc is null);
	commit work;
--6)Actualiza metas para los gerentes en 0
	begin work;
	update tmp_cifrascierresuc set metactasdia = 0, metanumtdc = 0, metaincremento = 0, cumpmetactas = 0, cumpmetatdc = 0
	where ejecutivo in (select ejecutivo from bdinteg:si_ejecut where puesto = '001');
	commit work;
-- 7) actualiza las metas para los promores virtuales GLI - 24/02/2012
	 begin work; 
		update tmp_cifrascierresuc set metactasdia = 0, metanumtdc = 0, metaincremento = 0 where nombre = 'PROMOTOR VIRTUAL';
	commit work;			
ELSE
	LET P_COD_RET = '001';
	LET P_MENSAJE = 'Fecha ya Procesada ';
	insert into mi_rptcierresucerror values (dFecha,'F',P_COD_RET,P_MENSAJE );
END IF;

LET vsql = 'echo "INSERT INTO bdmis:mi_bitacora_rcda(proceso,fecha,hora_ini,hora_fin,codret) values (''rcda_fin_proceso'', (SELECT fecha_ant FROM bdinteg:si_fechas), '||
'(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > insert_mi_bitacora.sql';
SYSTEM vsql;
LET vstmt = 'dbaccess bdmis insert_mi_bitacora.sql';
SYSTEM vstmt;
RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;