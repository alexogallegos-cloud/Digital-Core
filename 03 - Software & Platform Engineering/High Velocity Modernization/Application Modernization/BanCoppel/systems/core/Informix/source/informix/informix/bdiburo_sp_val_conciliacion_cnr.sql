create procedure "informix".sp_val_conciliacion_cnr()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);

DEFINE v_fechaproceso       DATE;
DEFINE v_primero_mes        DATE;
DEFINE v_fechaproceso_ant    DATE;
DEFINE vano                 CHAR(04);
DEFINE vmes                 CHAR(02);
DEFINE vdia                 CHAR(02);
DEFINE vfecha_reporte        CHAR(08); 

DEFINE cnum_credito		CHAR(12);
DEFINE cNumProducto         CHAR(04);
DEFINE v_tipocred           CHAR(02);
DEFINE vclave_obs           CHAR(02);
DEFINE vstatus_cred         CHAR(02);
DEFINE cNumProducto_app     CHAR(04);
DEFINE vclave_obs_app       CHAR(02);
DEFINE vstatus_cred_app     CHAR(02);
DEFINE cNumProducto_d     CHAR(04);
DEFINE vclave_obs_d       CHAR(02);
DEFINE vstatus_cred_d     CHAR(02);


DEFINE vsaldo_actual_en      DECIMAL(18,2);
DEFINE vsaldo_venc_en        DECIMAL(18,2);
DEFINE vmonto_insoluto_en    DECIMAL(18,2);
DEFINE vtotal_en             integer;
DEFINE vsaldo_actual_ex      DECIMAL(18,2);
DEFINE vsaldo_venc_ex        DECIMAL(18,2);
DEFINE vmonto_insoluto_ex    DECIMAL(18,2);
DEFINE vtotal_ex             integer;
DEFINE vsaldo_actual_app      DECIMAL(18,2);
DEFINE vsaldo_venc_app        DECIMAL(18,2);
DEFINE vsaldo_venc_app_cv     DECIMAL(18,2);
DEFINE vmonto_insoluto_app    DECIMAL(18,2);
DEFINE vtotal_app             integer;
DEFINE vcred_diferencia		integer;	
DEFINE vsdo_actual_dif     DECIMAL(18,2);
DEFINE vsdo_vencido_dif    DECIMAL(18,2);
DEFINE vsdo_insoluto_dif    DECIMAL(18,2);
DEFINE v_valfecha            SMALLINT;
DEFINE v_valcinta            SMALLINT;

DEFINE vflag                 CHAR(1);
DEFINE b_diferencia		     CHAR(1); 

LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET v_valfecha           = 0;
LET v_valcinta           = 0;
LET vtotal_en  = 0;
LET vtotal_ex  = 0;
LET vtotal_app  = 0;
LET vcred_diferencia = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
END EXCEPTION;


--SET DEBUG FILE TO "sp_val_conciliacion_cnr.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

select pri_dia_mes -1, pri_dia_mes -  1 units month
into v_fechaproceso,v_primero_mes
from bdicred:sd_fechas
where empresa = '001';

--temporal para pruebas
   --let v_fechaproceso = mdy('07','31','2021');
   --let v_primero_mes  = mdy('07','01','2021');
--temporal para pruebas

let v_fechaproceso_ant = v_primero_mes - 1;

SELECT valor 
INTO vflag
FROM bdiburo:br_param
WHERE cod_param = 132;


   let vano = year(v_fechaproceso);
   let vmes = lpad(month(v_fechaproceso),2,"0");
   let vdia = lpad(day(v_fechaproceso),2,"0");
   let vfecha_reporte = vdia||vmes||vano;

--Valida existencia
select count(*) INTO v_valcinta from  br_concil_consolidado_cnr where fecha_proceso = v_fechaproceso;

IF v_valcinta > 0 and vflag = 0 then
  LET cCodRet     = "007777";
  LET cMensajeRet = "CONCILIACIÓN CNR YA PROCESADA "||vfecha_reporte;
  RETURN cCodRet, cMensajeRet; 

ELSE

 IF  vflag = 8 then
  DROP TABLE tot_creditos_cintas_cnr;
  DELETE br_concil_consolidado_cnr where fecha_proceso = v_fechaproceso;
  DELETE br_fechas_Concil  where fecha_proceso = v_fechaproceso and num_producto in ('6300','6400');
  UPDATE bdiburo:br_param  SET valor = '0'  WHERE cod_param = 132;
  LET vflag = '0';
 END IF;

IF vflag = 0 then
--Informcación Cinta
SELECT num_producto, clave_obs, status_cred,NVL(count(*),0) total, 'EN' ETIQUETA,
NVL(sum(saldo_actual),0) saldo_actual,  NVL(sum(saldo_venc),0) saldo_venc,  NVL(sum(monto_insoluto),0)  monto_insoluto
FROM bdiburo:br_burofisicas_describe_cnr 
WHERE fecha_reporte = vfecha_reporte
and num_producto in ('6300','6400')
GROUP BY  1,2,3
union all
SELECT num_producto, clave_obs, status_cred,NVL(count(*),0) total, 'EX' ETIQUETA,
NVL(sum(saldo_actual),0) saldo_actual,  NVL(sum(saldo_venc),0) saldo_venc,  NVL(sum(monto_insoluto),0)  monto_insoluto
FROM bdiburo:br_burofisicas_concilia_cnr 
where fecha_cinta = v_fechaproceso
and motivo = 'CSS'
and num_producto in ('6300','6400')
GROUP BY  1,2,3
INTO temp tot_creditos_cintas_cnr WITH NO LOG;

  begin;
  UPDATE bdiburo:br_param
  SET valor = '8'
  WHERE cod_param = 132;
  commit;

 foreach with hold

    select a.num_producto,a.clave_obs,a.status_cred,NVL(a.saldo_actual,0) sa_Env,NVL(a.saldo_venc,0)sv_env,NVL(a.monto_insoluto,0) mi_env
           ,NVL(b.saldo_actual,0) sa_Exc, NVL(b.saldo_venc,0) sv_exc,NVL(b.monto_insoluto,0) mi_exc,NVL(a.total,0) cred_env, NVL(b.total,0) cred_exc
      INTO cNumProducto,vclave_obs,vstatus_cred,vsaldo_actual_en,vsaldo_venc_en,vmonto_insoluto_en,
            vsaldo_actual_ex,vsaldo_venc_ex,vmonto_insoluto_ex,vtotal_en, vtotal_ex
      from tot_creditos_cintas_cnr a left join tot_creditos_cintas_cnr b
        on a.num_producto = b.num_producto and a.clave_obs = b.clave_obs
        and a.status_Cred = b.status_Cred
        and a.etiqueta <> b.etiqueta
      where a.Etiqueta = 'EN'

    --IF vclave_obs in ('','EL','PC') and vstatus_cred in ('AA','BA','BT','VP') THEN
	IF vclave_obs in ('','EL','PC') and vstatus_cred in ('AA','BA','BT','VP','E1','E2','E3') THEN   -- IFRS
      LET v_tipocred  = 'AC';
    ELIF vclave_obs = 'CC' and vstatus_cred = 'FF' THEN
      LET v_tipocred  = 'CA';
    ELIF vclave_obs = 'CV' and vstatus_cred = 'CV' THEN
      LET v_tipocred  = 'VE';
    ELSE
      LET v_tipocred  = 'XX';
    END IF;
   
   begin;
    INSERT INTO br_concil_consolidado_cnr (fecha_proceso,num_producto,tipo_cred,clave_obs,status_cred,sdo_actual_sicenv, sdo_vencido_sicenv,sdo_insoluto_sicenv,
                                       sdo_actual_sicexc, sdo_vencido_sicexc,sdo_insoluto_sicexc,cred_enviados,cred_excluidos)
	VALUES (v_fechaproceso,cNumProducto,v_tipocred,vclave_obs,vstatus_cred,vsaldo_actual_en,vsaldo_venc_en,vmonto_insoluto_en,
            vsaldo_actual_ex,vsaldo_venc_ex,vmonto_insoluto_ex,vtotal_en, vtotal_ex);
   commit;				

    select count(*) INTO v_valfecha
    from bdiburo:br_fechas_Concil
    where fecha_proceso = v_fechaproceso
    and num_producto = cNumProducto;

    IF v_valfecha = 0 then
	   begin;
        INSERT INTO br_fechas_concil (empresa,fecha_proceso,num_producto)
        VALUES ('001',v_fechaproceso,cNumProducto);
	   commit;	
    END IF;

 end foreach

 begin;
  UPDATE bdiburo:br_param
  SET valor = '1'
  WHERE cod_param = 132;
 commit;

LET vflag = '1';
DROP TABLE tot_creditos_cintas_cnr;
END IF;

--Información Operativa
IF vflag = 1 then
  --Creditos a plazo - Activas
select a.num_producto,a.num_credito, a.status_cred ,nvl(dias_atraso,0) vdiasatraso, NVL(monto_vencido + mto_venc_trasp,0) cMtoVen
FROM bdicred:sd_maecredcontcrd a 
INNER JOIN bdicred:sd_indicador_cred_crd b ON a.empresa = b.empresa and a.num_credito = b.num_credito
INNER JOIN bdicred:sd_maesdoscontcrd c ON a.empresa = c.empresa and a.num_credito = c.num_credito and a.fecha = c.fecha
WHERE a.fecha =   v_fechaproceso
AND a.empresa = '001'
AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_concil_diferencias_cnr where fecha_proceso =  v_fechaproceso)
AND a.num_producto in ('6300','6400')
--Suc para pruebas
	--AND (sucursal in (SELECT sucursal from bdiburo:suc_pro where des_suc = 'CNR'))-- OR a.num_credito  in (SELECT num_credito from creditos_err))
into temp crds_central_cnr1 WITH NO LOG; 

SELECT a.*,b.status_cred  vstatus_credAnt,
CASE WHEN (vdiasatraso >=  1 ) THEN 'PC'
--WHEN b.status_cred IN ('BT','BA') AND a.status_cred ='AA' THEN 'EL'
 WHEN (b.status_cred IN ('BT','BA','E1','E2','E3') AND NVL(c.monto_vencido + c.mto_venc_trasp,0) > 0) AND (a.status_cred  IN ('AA','E1') AND cMtoVen = 0) THEN 'EL'  --IFRS MACF
ELSE '' END clave_obs
FROM crds_central_cnr1 a 
LEFT JOIN  bdicred:sd_maecredcontcrd b ON empresa = '001' AND a.num_credito = b.num_credito  AND b.fecha = v_fechaproceso_ant
INNER JOIN bdicred:sd_maesdoscontcrd c ON b.empresa = c.empresa and b.num_credito = c.num_credito and b.fecha = c.fecha
into temp crds_central_cnr  WITH NO LOG; 

DROP TABLE crds_central_cnr1;

   foreach with hold
SELECT num_producto, status_cred,clave_obs, count(b.num_credito) total,
 sum(case 
     when ((nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0))+ 
case
when nvl(sdo_no_exig,0) is null then 0
when nvl(sdo_no_exig,0) <= 0 then 0 
else nvl(sdo_no_exig,0) end) >0 
      and (nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0)+ 
case
when nvl(sdo_no_exig,0) is null then 0
when nvl(sdo_no_exig,0) <= 0 then 0 
else nvl(sdo_no_exig,0) end) <1 then 1
     else round ((nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0))+ 
case
when nvl(sdo_no_exig,0) is null then 0
when nvl(sdo_no_exig,0) <= 0 then 0 
else nvl(sdo_no_exig,0) end
)end) saldo_actual,
 sum(case 
     when (nvl(monto_vencido + mto_venc_trasp,0)) >0 
      and (nvl(monto_vencido + mto_venc_trasp,0)) <1 then 1
     else round (nvl(monto_vencido + mto_venc_trasp,0))end)
saldo_vencido,
 sum(case 
     when (nvl(sdo_cap_insoluto,0)) >0 
      and (nvl(sdo_cap_insoluto,0)) <1 then 1
     else round (nvl(sdo_cap_insoluto,0))end)
saldo_insoluto
INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app
from bdicred:sd_maesdoscontcrd a inner join crds_central_cnr  b
on  a.num_credito = b.num_credito
where  a.fecha =  v_fechaproceso --mdy('02','28','2014')
and a.num_credito >= ''
and b.num_producto  in ('6300','6400')
group by 1,2,3

   begin;
    UPDATE br_concil_consolidado_cnr set 
    sdo_actual_app = vsaldo_actual_app,
    sdo_vencido_app= vsaldo_venc_app,
    sdo_insoluto_app = vmonto_insoluto_app,
	cred_central = vtotal_app
	WHERE fecha_proceso = v_fechaproceso
      and num_producto = cNumProducto_app
      and status_cred = vstatus_cred_app
      and clave_obs = vclave_obs_app
      and (sdo_actual_app is null);
   commit;	  
   end foreach  

  begin;
  UPDATE bdiburo:br_param
  SET valor = '2'
  WHERE cod_param = 132;
 commit;

LET vflag = '2';
DROP TABLE crds_central_cnr;
END IF;

IF vflag = 2 then    

 --Créditos a Plazo - Canceladas
foreach with hold  
select num_producto, a.status_cred,'CC' clave_obs,count(a.NUM_CREDITO),  0 saldo_actual, 0 saldo_vencido, 0 saldo_insoluto	
INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	
from bdicred:sd_maecredcrd a inner join bdicred:sd_maecredanexocrd b
on b.empresa = '001' and a.num_credito = b.num_credito  and fecha_proceso  between  v_primero_mes and v_fechaproceso
where a.empresa = '001'
and a.num_Credito >= ''
and num_producto  in ('6300','6400')
and status_cred = 'FF'
--Suc para pruebas
	--AND (sucursal IN (SELECT sucursal FROM bdiburo:suc_pro WHERE des_suc = 'CNR'))-- OR a.num_credito  in (SELECT num_credito FROM creditos_err))
group by 1,2

   begin;	  
	UPDATE br_concil_consolidado_cnr set 
    sdo_actual_app = vsaldo_actual_app,
    sdo_vencido_app= vsaldo_venc_app,
    sdo_insoluto_app = vmonto_insoluto_app,
    cred_central = vtotal_app
    WHERE fecha_proceso = v_fechaproceso
      and num_producto = cNumProducto_app
      and status_cred = vstatus_cred_app
      and clave_obs = vclave_obs_app
      and (sdo_actual_app is null);
   commit;	  

  end foreach 
  
 begin;
  UPDATE bdiburo:br_param
  SET valor = '3'
  WHERE cod_param = 132;
 commit;

LET vflag = '3';
END IF;

IF vflag = 3 then
--Cambio Redondeo saldos vencidos IPCB 23 enero 2015 PP 
 --Creditos a Plazo- Prestamo Personal- Vendidas /separación de PP y CN enero2015
select a.num_credito,num_producto, 
case 
    when (nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
       (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) from bdicred:sd_amortiza_creditocrd_vendida 
 where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')),0))  between 0.0000001 and 1 then 1 
    else 
    nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
       (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) from bdicred:sd_amortiza_creditocrd_vendida 
 where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')),0)
    end saldo_vencido
--INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	
from bdicred:sd_maecredcrd a inner join bdicred:sd_maesdoscrd_vendida b
--on fecha  between mdy('12','01','2014') and  mdy('12','31','2014') 
on fecha  between v_primero_mes and v_fechaproceso
and a.empresa = b.empresa and a.num_credito = b.num_credito
where a.empresa = '001'
and a.num_credito >= ''
and num_producto  in ('6300')

into temp creds_cv with no log;

LET vtotal_app = 0;
LET vsaldo_venc_app = 0;

 foreach with hold 		
   select  num_credito,saldo_vencido
      into cnum_credito,vsaldo_venc_app_cv
      from creds_cv

   LET vtotal_app = vtotal_app+1;	
   LET vsaldo_venc_app_cv = round(vsaldo_venc_app_cv,0); 	  
   LET vsaldo_venc_app = vsaldo_venc_app +vsaldo_venc_app_cv;

   LET vsaldo_venc_app_cv = 0;
 end foreach  

   begin;	
	UPDATE br_concil_consolidado_cnr set 
    sdo_actual_app = 0,
    sdo_vencido_app= vsaldo_venc_app,
    sdo_insoluto_app = 0,
    cred_central = vtotal_app
    WHERE fecha_proceso = v_fechaproceso
      and num_producto = '6300'
      and status_cred = 'CV'
      and clave_obs = 'CV'
      and (sdo_actual_app is null);
   commit; 
 --Cambio Redondeo saldos vencidos IPCB 23 enero 2015

 begin;
  UPDATE bdiburo:br_param
  SET valor = '4'
  WHERE cod_param = 132;
 commit;

drop table creds_cv;

LET vflag = '4';
END IF;

IF vflag = 4 then
  --Creditos a Plazo-Credinomina - Vendidas  /separación de PP y CN enero2015
select a.num_credito,num_producto, 
case 
    when (nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
       (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) from bdicred:sd_amortiza_creditocrd_vendida 
 where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')),0))  between 0.0000001 and 1 then 1 
    else 
    nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
       (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) from bdicred:sd_amortiza_creditocrd_vendida 
 where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')),0)
    end saldo_vencido
--INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	
from bdicred:sd_maecredcrd a inner join bdicred:sd_maesdoscrd_vendida b
--on fecha  between mdy('12','01','2014') and  mdy('12','31','2014') 
on fecha  between v_primero_mes and v_fechaproceso
and a.empresa = b.empresa and a.num_credito = b.num_credito
where a.empresa = '001'
and a.num_credito >= ''
and num_producto  in ('6400')

into temp creds_cv with no log;

LET vtotal_app = 0;
LET vsaldo_venc_app = 0;

 foreach with hold 		
   select  num_credito,saldo_vencido
      into cnum_credito,vsaldo_venc_app_cv
      from creds_cv

   LET vtotal_app = vtotal_app+1;	
   LET vsaldo_venc_app_cv = round(vsaldo_venc_app_cv,0); 	  
   LET vsaldo_venc_app = vsaldo_venc_app +vsaldo_venc_app_cv;

   LET vsaldo_venc_app_cv = 0;
 end foreach  

   begin;	
	UPDATE br_concil_consolidado_cnr set 
    sdo_actual_app = 0,
    sdo_vencido_app= vsaldo_venc_app,
    sdo_insoluto_app = 0,
    cred_central = vtotal_app
    WHERE fecha_proceso = v_fechaproceso
      and num_producto = '6400'
      and status_cred = 'CV'
      and clave_obs = 'CV'
      and (sdo_actual_app is null);
   commit; 

 begin;
  UPDATE bdiburo:br_param
  SET valor = '5'
  WHERE cod_param = 132;
 commit;

LET vflag = '5';
END IF;
  
IF vflag = 5 then
 --Cálculo de diferencias.
 foreach with hold 
 
 	select num_producto,status_cred,clave_obs,
     NVL((sdo_actual_sicenv + sdo_actual_sicexc) - sdo_actual_app,0),
	  NVL ((sdo_vencido_sicenv + sdo_vencido_sicexc) - sdo_vencido_app,0),
	   NVL((sdo_insoluto_sicenv + sdo_insoluto_sicexc) - sdo_insoluto_app ,0),
	   NVL((cred_enviados + cred_excluidos) - cred_central ,0)
	INTO cNumProducto_d,vstatus_cred_d,vclave_obs_d,vsdo_actual_dif,vsdo_vencido_dif,vsdo_insoluto_dif,vcred_diferencia 
    FROM br_concil_consolidado_cnr	
	where fecha_proceso = v_fechaproceso
	
	IF vsdo_actual_dif < 0 then
	LET vsdo_actual_dif = vsdo_actual_dif * (-1);
	end if;
	
	IF vsdo_vencido_dif < 0 then
	LET vsdo_vencido_dif = vsdo_vencido_dif * (-1);
	end if;
	
	IF vsdo_insoluto_dif < 0 then
	LET vsdo_insoluto_dif = vsdo_insoluto_dif * (-1);
	end if;
	
	IF vcred_diferencia < 0 then
	LET vcred_diferencia = vcred_diferencia * (-1);
	end if;

   begin;	
	UPDATE br_concil_consolidado_cnr set 
    sdo_actual_dif = vsdo_actual_dif,
	sdo_vencido_dif = vsdo_vencido_dif,
	sdo_insoluto_dif  = vsdo_insoluto_dif,
	cred_diferencia =  vcred_diferencia
	WHERE fecha_proceso = v_fechaproceso
      and num_producto = cNumProducto_d
      and status_cred = vstatus_cred_d
      and clave_obs = vclave_obs_d
      and sdo_actual_dif is null ;
   commit;	
 
   select diferencia
   Into b_diferencia
   from  br_fechas_concil
   where fecha_proceso = v_fechaproceso
   and num_producto = cNumProducto_d;
   
   If (vsdo_actual_dif > 0 or vsdo_vencido_dif > 0 or vsdo_insoluto_dif  > 0 or vcred_diferencia >0) and b_diferencia is null then
    begin;
	update bdiburo:br_fechas_concil set diferencia = 'D'
    where fecha_proceso = v_fechaproceso
    and num_producto = cNumProducto_d;
	commit;
   ELIF (vsdo_actual_dif = 0 and vsdo_vencido_dif = 0 and vsdo_insoluto_dif  = 0 and vcred_diferencia =0) then
    begin;
	update bdiburo:br_fechas_concil set diferencia = ''
    where fecha_proceso = v_fechaproceso
    and num_producto = cNumProducto_d;
	commit;
   End if;
  If (vsdo_actual_dif > 0 or vsdo_vencido_dif > 0 or vsdo_insoluto_dif  > 0 or vcred_diferencia >0) then
    begin;	
	UPDATE br_concil_consolidado_cnr set b_difprocesa ='D'       
	WHERE fecha_proceso = v_fechaproceso
	and num_producto = cNumProducto_d
	and status_cred = vstatus_cred_d
	and clave_obs = vclave_obs_d;
	commit;
   ELSE
    begin;
	UPDATE br_concil_consolidado_cnr set b_difprocesa =''       
	WHERE fecha_proceso = v_fechaproceso
	and num_producto = cNumProducto_d
	and status_cred = vstatus_cred_d
	and clave_obs = vclave_obs_d;
	commit;
   End If
   
 end foreach 	  

 begin;
  UPDATE bdiburo:br_param
  SET valor = '0'
  WHERE cod_param = 132;
 commit;

END IF;

LET cCodRet     = "000000";
LET cMensajeRet = "CONCILIACIÓN CNR "||vfecha_reporte|| " Ok.";

	RETURN cCodRet, cMensajeRet; 
END IF;
END;
END PROCEDURE;