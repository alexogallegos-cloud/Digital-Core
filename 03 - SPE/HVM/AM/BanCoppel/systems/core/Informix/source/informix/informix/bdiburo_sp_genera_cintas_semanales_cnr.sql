CREATE PROCEDURE "informix".sp_genera_cintas_semanales_cnr()
RETURNING CHAR(6),
          CHAR(100);

  DEFINE vcodret  CHAR(6);
  DEFINE vfecha_hoy, vPriDiaMes, vfecha_nac, vfecha_apertura, vfecha_ini, vpago_cap, vpago_int, dtFecha_ultimo_reporte      DATE;
  DEFINE vMES, vDIA, vmesup, vdiaup, vversion, vciclo, vmop, vStatusCred, vstatus_credAnt, vperio_ejecucion                 CHAR(2);
  DEFINE tb_nacionalidad, cEmpresa                                                                                          CHAR(3);               
  DEFINE vANIO, vanioup, vestado, vnum_producto, vtp_linea, vencabezado1,cProceso                                           CHAR(4);
  DEFINE vvcCod_ret                                                                                                         CHAR(6);
  DEFINE vlCodigoPOstalZona, vnum_pagos                                                                                     CHAR(5);
  DEFINE vfecha_reporte, vfechaup, tb_fecha_nac                                                                             CHAR(8);
  DEFINE vlCodigoReportar, vcod_postal, vclave_usu_bc, vuso_futuro,v_campo_trab3,vclave_usu                 	 			CHAR(10);
  DEFINE vrfc, tb_rfc                                                                                                       CHAR(13);
  DEFINE vnombre_usu                                                                                                        CHAR(16);
  DEFINE vnumcte                                                                                                            CHAR(20);
  DEFINE vnum_credito                                                                                                       CHAR(25);
  DEFINE varchivo, varchivo_des                                                                                             CHAR(60);
  DEFINE vinf_adicional                CHAR(98);
  DEFINE cMensajeFin                   CHAR(100);
  DEFINE vheader                       CHAR(150);
  DEFINE vruta_interfase               CHAR(200);   
  DEFINE vsql                          CHAR(2000);
  DEFINE vcredito_maximo, vcredito_maximo1, vmonto, vmontoinsoluto, vmontolutpago                 DECIMAL(18,2);
  DEFINE vmonto_otorgado, vsaldo_vig, vsaldo_venc, vsaldo_actual,v_interes, vsaldo_vencAnt        DECIMAL(18,2);
  DEFINE vrea_cal_cuota, vcuota_cap, vnumreg, contador_commit, vdiasatraso, iPeriodo, iTotalProcesados, isqlErr, iBanderaIndex, iCP                      INTEGER;
  DEFINE vcuotas_ven, vdiasvenc, existe, vsecuencia, vmanzana, vandador, vlote, vedificio, ventrada, vdiacuota, sCommit, sProceso, vcuotas_ven_maesdos   SMALLINT;
  DEFINE vFechaHoy		DATE;
  DEFINE vFechaReport	CHAR(8);
  DEFINE cEncabezadoCnr	INTEGER;
    
  LET iPeriodo = 0;         LET sProceso = 0;            LET sCommit = 0;              LET contador_commit = 0;            LET iBanderaIndex = 0; 
  LET vnum_credito = '';    LET vanioup = '';            LET vmesup = '';              LET vdiaup = '';                    LET vfechaup = ''; 
  LET cProceso = '0675';    LET vvcCod_ret = '';         LET cEmpresa = '001';         LET v_campo_trab3 = '';             LET vmop = ''; 
  LET vcuotas_ven_maesdos = 0;
  LET vclave_usu_bc = '';	LET vclave_usu = '';

  LET cMensajeFin = 'El proceso CINTAS PAGOS PARCIALES CTAS. A PLAZO se ejecutó exitosamente.';
  LET cEncabezadoCnr = 0;
  
BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
      LET vcodret = iSqlErr;

      LET cMensajeFin = 'Proceso CINTAS PAGOS PARCIALES CTAS. A PLAZO cancelado' || ' ' || vnum_credito;

      RETURN vcodret,cMensajeFin;

      ROLLBACK WORK;

   END IF;
END EXCEPTION;

 LET vcodret = "000000";
 LET vsql = "";

 --SET DEBUG FILE TO "sp_genera_cintas_semanales_cnr.out";
 --TRACE ON; 
 
	SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 3;

   SELECT UPPER(valor) 
     INTO vclave_usu
     FROM br_param
    WHERE cod_param = 1;

   SELECT UPPER(valor) 
     INTO vencabezado1
     FROM br_param
    WHERE cod_param = 3;

   SELECT UPPER(valor) 
     INTO vversion
     FROM br_param
    WHERE cod_param = 4;  -- En manual técnico indica INTF Version 10,11 y 12

   SELECT UPPER(valor) 
     INTO vnombre_usu
     FROM br_param
    WHERE cod_param = 6;

   SELECT UPPER(valor) 
     INTO vciclo
     FROM br_param
    WHERE cod_param = 7;

    SELECT UPPER(valor) 
      INTO vuso_futuro
      FROM br_param
     WHERE cod_param = 8;

    SELECT UPPER(valor) 
      INTO vclave_usu_bc
      FROM br_param
     WHERE cod_param = 128;   

     LET vinf_adicional = "&";
	 LET vnumreg = 1;

     SELECT fecha_hoy,pri_dia_mes
       INTO vFechaHoy,vPriDiaMes
       FROM bdicred:sd_fechas
      WHERE empresa='001';
	  
	LET vDIA = LPAD(DAY(vFechaHoy),2,'0');
	LET vMES = LPAD(MONTH(vFechaHoy),2,'0');
	LET vANIO = YEAR(vFechaHoy);
	
	----- VALIDA DIAS INHABILES DE DICIEMBRE Y ENERO E INSERTA ENCABEZADO
	IF vMES = '12' AND vDIA = '26' THEN
		LET vDIA = '25';
		LET vFechaReport = vDIA||vMES||vANIO;
		
		SELECT count(*) INTO cEncabezadoCnr FROM bdiburo:br_burofisicas_cortos_cnr WHERE numreg = '1';
		
		IF NVL(cEncabezadoCnr,0) = 0 OR cEncabezadoCnr is null THEN
			LET vheader = vencabezado1||vversion||vclave_usu_bc||vnombre_usu||vciclo||vFechaReport||vuso_futuro||rpad(trim(vinf_adicional),98,"&");
			INSERT INTO bdiburo:br_burofisicas_cortos_cnr VALUES(vnumreg,vheader);
		END IF;
		
	ELIF vMES = '01' AND vDIA = '02' THEN
		LET vDIA = '01';
		LET vFechaReport = vDIA||vMES||vANIO;
		
		SELECT count(*) INTO cEncabezadoCnr FROM bdiburo:br_burofisicas_cortos_cnr WHERE numreg = '1';
		
		IF NVL(cEncabezadoCnr,0) = 0 OR cEncabezadoCnr is null THEN
			LET vheader = vencabezado1||vversion||vclave_usu_bc||vnombre_usu||vciclo||vFechaReport||vuso_futuro||rpad(trim(vinf_adicional),98,"&");
			INSERT INTO bdiburo:br_burofisicas_cortos_cnr VALUES(vnumreg,vheader);
		END IF;
	
	END IF;

	SELECT substr(registro,35,8) INTO vfecha_reporte
	FROM bdiburo:br_burofisicas_cortos_cnr
	WHERE numreg=1;
	IF vfecha_reporte IS NULL OR vfecha_reporte = '' THEN
		LET vcodret = '000001';
		LET cMensajeFin = 'Proceso CINTAS PAGOS PARCIALES CTAS. A PLAZO sin información.';
		RETURN vcodret,cMensajeFin;
	END IF;

-- Extracción Círculo de Crédito	
    LET vsql = '';
    LET vsql = 'echo " UNLOAD TO  /resplogifx/burodecredito/enviodepagos/xburofiscortos_cnr.unl' ||
--                    ' SELECT registro FROM bdiburo:br_burofisicas_cortos_cnr WHERE numreg=1 ' ||
					' SELECT replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||''') FROM bdiburo:br_burofisicas_cortos_cnr where numreg=1' ||			 
                    ' UNION ' ||
                    ' SELECT ' ||  
                    ' trim((select registro from bdiburo:br_burofisicas_cortos_cnr where numreg=a.numreg-3))::lvarchar||' ||					
                    ' trim((select registro from bdiburo:br_burofisicas_cortos_cnr where numreg=a.numreg-2))::lvarchar||' ||
                    ' trim((select registro from bdiburo:br_burofisicas_cortos_cnr where numreg=a.numreg-1))::lvarchar||' ||
					' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar ' ||  
--                    ' trim(registro)::lvarchar ' ||  
                    ' FROM bdiburo:br_burofisicas_cortos_cnr a where substr(a.registro,1,2)='||'''TL'''||' '||  
                    ' UNION ' ||  
                    ' SELECT '||'''TRLR'''||'||lpad(sum(saldo_actual)::DEC(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::DEC(14,0),14,'||'''0'''||')' ||  
                    ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
                    ' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
                    ' FROM bdiburo:br_burofisicas_describe_cortos_cnr;' ||
                    ' " > /resplogifx/burodecredito/enviodepagos/genburofiscortos_cnr.sql';
    SYSTEM vsql;

    LET vsql = '';
    LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/enviodepagos/genburofiscortos_cnr.sql';
    SYSTEM vsql;

    LET vsql = "sed 's/&/ /g' /resplogifx/burodecredito/enviodepagos/xburofiscortos_cnr.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos_cnr.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/enviodepagos/xburofis1cortos_cnr.unl > /resplogifx/burodecredito/enviodepagos/xburofis2cortos_cnr.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/|//g' /resplogifx/burodecredito/enviodepagos/xburofis2cortos_cnr.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos_cnr.unl ";
    SYSTEM vsql;

    LET vsql = "cat /resplogifx/burodecredito/enviodepagos/xburofis1cortos_cnr.unl | tr -d '\n' > /resplogifx/burodecredito/enviodepagos/cintafispagos_circulocnr"||vfecha_reporte||"_PARCIAL.txt ";
    SYSTEM vsql;

    LET vsql = "rm /resplogifx/burodecredito/enviodepagos/xburofis*.unl /resplogifx/burodecredito/enviodepagos/genburofiscortos_cnr.sql";
    SYSTEM vsql;

    LET vsql = "gzip /resplogifx/burodecredito/enviodepagos/cintafispagos_circulocnr"||vfecha_reporte||"_PARCIAL.txt ";
    SYSTEM vsql;

-- Extracción Buró de Crédito	
    LET vsql = '';
    LET vsql = 'echo " UNLOAD TO  /resplogifx/burodecredito/enviodepagos/xburofiscortos_bc_cnr.unl' ||
                    ' SELECT registro FROM bdiburo:br_burofisicas_cortos_cnr WHERE numreg=1 ' ||
                    ' UNION ' ||
                    ' SELECT ' ||  
                    ' trim((select registro from bdiburo:br_burofisicas_cortos_cnr where numreg=a.numreg-3))::lvarchar||' ||					
                    ' trim((select registro from bdiburo:br_burofisicas_cortos_cnr where numreg=a.numreg-2))::lvarchar||' ||
                    ' trim((select registro from bdiburo:br_burofisicas_cortos_cnr where numreg=a.numreg-1))::lvarchar||' ||
                    ' trim(registro)::lvarchar ' ||  
                    ' FROM bdiburo:br_burofisicas_cortos_cnr a where substr(a.registro,1,2)='||'''TL'''||' '||  
                    ' UNION ' ||  
                    ' SELECT '||'''TRLR'''||'||lpad(sum(saldo_actual)::DEC(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::DEC(14,0),14,'||'''0'''||')' ||  
                    ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
                    ' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
                    ' FROM bdiburo:br_burofisicas_describe_cortos_cnr;' ||
                    ' " > /resplogifx/burodecredito/enviodepagos/genburofiscortos_bc_cnr.sql';
    SYSTEM vsql;

    LET vsql = '';
    LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/enviodepagos/genburofiscortos_bc_cnr.sql';
    SYSTEM vsql;

    LET vsql = "sed 's/&/ /g' /resplogifx/burodecredito/enviodepagos/xburofiscortos_bc_cnr.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos_bc_cnr.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/enviodepagos/xburofis1cortos_bc_cnr.unl > /resplogifx/burodecredito/enviodepagos/xburofis2cortos_bc_cnr.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/|//g' /resplogifx/burodecredito/enviodepagos/xburofis2cortos_bc_cnr.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos_bc_cnr.unl ";
    SYSTEM vsql;

    LET vsql = "cat /resplogifx/burodecredito/enviodepagos/xburofis1cortos_bc_cnr.unl | tr -d '\n' > /resplogifx/burodecredito/enviodepagos/cintafispagos_burocnr"||vfecha_reporte||".txt ";
    SYSTEM vsql;

    LET vsql = "rm /resplogifx/burodecredito/enviodepagos/xburofis*.unl /resplogifx/burodecredito/enviodepagos/genburofiscortos_bc_cnr.sql";
    SYSTEM vsql;

    LET vsql = "gzip /resplogifx/burodecredito/enviodepagos/cintafispagos_burocnr"||vfecha_reporte||".txt ";
    SYSTEM vsql;
 
 RETURN vcodret, cMensajeFin;

END;
END PROCEDURE
DOCUMENT
'Procedimiento para reportar a las',
'Sociedades Crediticias por entregas parciales los',
'clientes que pagan y se ponen al corriente durante',
'la semana',
'AUTOR : MACF',
'FECHA INI: 2015/04/17',
'BD    : BDIBURO';

create procedure "informix".sp_val_conciliacion()
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

DEFINE cnum_credito			CHAR(12);
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

DEFINE vflag                 CHAR(2);
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


--SET DEBUG FILE TO "sp_val_conciliacion.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

select pri_dia_mes -1, pri_dia_mes -  1 units month
into v_fechaproceso,v_primero_mes
from bdicred:sd_fechas
where empresa = '001';

--temporal para pruebas
--   let v_fechaproceso = mdy('07','31','2021');
--   let v_primero_mes  = mdy('07','01','2021');
--temporal para pruebas

let v_fechaproceso_ant = v_primero_mes - 1;

SELECT valor 
INTO vflag
FROM bdiburo:br_param
WHERE cod_param = 131;


   let vano = year(v_fechaproceso);
   let vmes = lpad(month(v_fechaproceso),2,"0");
   let vdia = lpad(day(v_fechaproceso),2,"0");
   let vfecha_reporte = vdia||vmes||vano;

--Valida existencia
select count(*) INTO v_valcinta from  br_concil_consolidado where fecha_proceso = v_fechaproceso;

IF v_valcinta > 0 and vflag = 0 then
  LET cCodRet     = "007777";
  LET cMensajeRet = "CONCILIACIÃ?N YA PROCESADA "||vfecha_reporte;
  RETURN cCodRet, cMensajeRet; 

ELSE

 IF  vflag = 8 then
  DROP TABLE tot_creditos_cintas;
  DELETE br_concil_consolidado where fecha_proceso = v_fechaproceso;
  DELETE  br_fechas_Concil  where fecha_proceso = v_fechaproceso and num_producto in ('6001','6600','6011');
  UPDATE bdiburo:br_param  SET valor = '0'  WHERE cod_param = 131;
  LET vflag = '0';
 END IF;

IF vflag = 0 then
--InformcaciÃÂ³n Cinta
SELECT {+INDEX(br_burofisicas_describe idx_br_burofisicas_describe)} num_producto, clave_obs, status_cred,NVL(count(*),0) total, 'EN' ETIQUETA,
NVL(sum(saldo_actual),0) saldo_actual,  NVL(sum(saldo_venc),0) saldo_venc,  NVL(sum(monto_insoluto),0)  monto_insoluto
FROM bdiburo:br_burofisicas_describe 
WHERE fecha_reporte = vfecha_reporte
and num_credito >= '' and clave_obs <> 'LS' --  INC 21 398 se adiciona filtro
GROUP BY  1,2,3
union all
SELECT num_producto, clave_obs, status_cred,NVL(count(*),0) total, 'EX' ETIQUETA,
NVL(sum(saldo_actual),0) saldo_actual,  NVL(sum(saldo_venc),0) saldo_venc,  NVL(sum(monto_insoluto),0)  monto_insoluto
FROM bdiburo:br_burofisicas_concilia 
where fecha_cinta = v_fechaproceso
and motivo = 'CSS'
and num_producto <> ''
and num_credito >= ''
and empresa = '001'
GROUP BY  1,2,3
INTO temp tot_creditos_cintas WITH NO LOG;

  begin;
  UPDATE bdiburo:br_param
  SET valor = '8'
  WHERE cod_param = 131;
  commit;

 foreach with hold

    select a.num_producto,a.clave_obs,a.status_cred,NVL(a.saldo_actual,0) sa_Env,NVL(a.saldo_venc,0)sv_env,NVL(a.monto_insoluto,0) mi_env
           ,NVL(b.saldo_actual,0) sa_Exc, NVL(b.saldo_venc,0) sv_exc,NVL(b.monto_insoluto,0) mi_exc,NVL(a.total,0) cred_env, NVL(b.total,0) cred_exc
      INTO cNumProducto,vclave_obs,vstatus_cred,vsaldo_actual_en,vsaldo_venc_en,vmonto_insoluto_en,
            vsaldo_actual_ex,vsaldo_venc_ex,vmonto_insoluto_ex,vtotal_en, vtotal_ex
      from tot_creditos_cintas a left join tot_creditos_cintas b
        on a.num_producto = b.num_producto and a.clave_obs = b.clave_obs
        and a.status_Cred = b.status_Cred
        and a.etiqueta <> b.etiqueta
      where a.Etiqueta = 'EN'

    --IF vclave_obs in ('','EL','PC') and vstatus_cred in ('AA','BA','BT','VP') THEN
	IF vclave_obs in ('','EL','PC') and vstatus_cred in ('AA','BA','BT','VP','E1','E2','E3') THEN  -- IFRS MACF
      LET v_tipocred  = 'AC';
    ELIF vclave_obs = 'CC' and vstatus_cred = 'FF' THEN
      LET v_tipocred  = 'CA';
    ELIF vclave_obs = 'CV' and vstatus_cred = 'CV' THEN
      LET v_tipocred  = 'VE';
    ELIF vclave_obs = 'RV' and vstatus_cred = 'FC' THEN
      LET v_tipocred  = 'RE';
    ELSE
      LET v_tipocred  = 'XX';
    END IF;
   
   begin;
    INSERT INTO br_concil_consolidado (fecha_proceso,num_producto,tipo_cred,clave_obs,status_cred,sdo_actual_sicenv, sdo_vencido_sicenv,sdo_insoluto_sicenv,
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
  WHERE cod_param = 131;
 commit;

LET vflag = '1';
DROP TABLE tot_creditos_cintas;
END IF;

--InformaciÃÂ³n Operativa
IF vflag = 1 then
    --Tarjetas de CrÃÂ©dito - Activas
SELECT a.num_producto,a.num_credito, a.status_cred, 
nvl(dias_atraso,0) vdiasatraso, nvl(monto_vencido + mto_venc_trasp,0) cMtoVen 
FROM bdicred:sd_maecredcont a inner join bdicred:sd_indicador_cred b on a.empresa = b.empresa and a.num_credito = b.num_credito
inner join bdicred:sd_maesdoscont c on a.empresa = c.empresa and a.num_credito = c.num_credito and a.fecha = c.fecha  -- IFRS MACF
WHERE a.fecha = v_fechaproceso
AND a.empresa = '001'
AND a.num_credito >= ''
--Suc para pruebas
  --AND substr(sucursal,1,4) in (select sucursal from bdiburo:suc_pro where des_suc = 'TDC')		
into temp cred_act_op1 WITH NO LOG; 

set isolation to dirty read; --40409
select a.*, b.status_cred  vstatus_credAnt,
CASE 
    WHEN (vdiasatraso >=   1 ) then 'PC'
    --WHEN b.status_cred  in ('BT','BA') and a.status_cred ='AA' then 'EL'
	WHEN (b.status_cred in ('BT','BA','E1','E2','E3') AND nvl(c.monto_vencido + c.mto_venc_trasp,0) > 0) and (a.status_cred IN ('AA','E1') and a.cMtoVen = 0 ) then 'EL' -- IFRS MACF
    ELSE '' END clave_obs
from cred_act_op1 a left join  bdicred:sd_maecredcont b on empresa = '001'and a.num_credito = b.num_credito and b.fecha = v_fechaproceso_ant --v_fechaproceso --(Se cambia fecha "variable" debido a que se obtenia info del mes anterior).
inner join bdicred:sd_maesdoscont c on b.empresa = c.empresa and b.num_credito = c.num_credito and b.fecha = c.fecha -- IFRS MACF
into temp cred_act_op  WITH NO LOG; 

DROP TABLE cred_act_op1;

 if day(v_fechaproceso) = 28 then 
   foreach with hold
    select b.num_producto, status_cred, clave_obs, count(b.num_credito) total,
     sum(case 
      when (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0)) >0 
      and (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0)) <1 then 1
      else round (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0))end) saldo_actual,
  sum(case 
      when (nvl(captrans28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0)) >0 
       and (nvl(captrans28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0)) <1 then 1 
      else round(nvl(captrans28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0),0) end) 
  saldo_venc,
     sum(case 
      when (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28,0)) >0 
       and (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28,0)) <1 then 1
	  when (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28,0)) <0 then 0
      else round (nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28,0))end)saldo_insol
    INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app
    from bdicred:sd_sdodiario a inner join cred_act_op b
    on a.num_credito = b.num_credito
	where a.fecha = v_primero_mes
    and a.num_credito >= ''
    group by 1,2,3
	
   begin;	
    UPDATE br_concil_consolidado set 
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
   
 elif day(v_fechaproceso) = 29 then 
   foreach with hold
    select b.num_producto, status_cred, clave_obs, count(b.num_credito) total,
     sum(case 
      when (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0)) >0 
      and (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0)) <1 then 1
      else round (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0))end) saldo_actual,
  sum(case 
      when (nvl(captrans29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0)) >0 
       and (nvl(captrans29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0)) <1 then 1 
      else round(nvl(captrans29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0),0) end) 
  saldo_venc,
     sum(case 
      when (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29,0)) >0 
       and (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29,0)) <1 then 1
	  when (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29,0)) <0 then 0
      else round (nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29,0))end)saldo_insol
	INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app
    from bdicred:sd_sdodiario a inner join cred_act_op b
    on a.num_credito = b.num_credito
	where a.fecha = v_primero_mes
    and a.num_credito >= ''
    group by 1,2,3

   begin;    
    UPDATE br_concil_consolidado set 
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
   
 elif day(v_fechaproceso) = 30 then 
   foreach with hold
    select b.num_producto, status_cred, clave_obs, count(b.num_credito) total,
     sum(case 
      when (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0)) >0 
       and (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0)) <1 then 1
      else round (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0))end) saldo_actual,
  sum(case 
      when (nvl(captrans30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0)) >0 
       and (nvl(captrans30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0)) <1 then 1 
      else round(nvl(captrans30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0),0) end) 
  saldo_venc,
     sum(case 
      when (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30,0)) >0 
       and (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30,0)) <1 then 1
	  when (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30,0)) <0 then 0
      else round (nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30,0))end)saldo_insol
	INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app
    from bdicred:sd_sdodiario a inner join cred_act_op b
    on a.num_credito = b.num_credito
	where a.fecha = v_primero_mes
    and a.num_credito >= ''
    group by 1,2,3

   begin;    
	UPDATE br_concil_consolidado set 
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
   
 else
   foreach with hold
    select b.num_producto, status_cred, clave_obs, count(b.num_credito) total,
    sum(case 
      when (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0)) >0 
       and (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0)) <1 then 1
      else round (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0))end)
    saldo_actual,
  sum(case 
      when (nvl(captrans31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0)) >0 
       and (nvl(captrans31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0)) <1 then 1 
      else round(nvl(captrans31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0),0) end) 
  saldo_venc,
    sum(case 
      when (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31,0)) >0 
       and (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31,0)) <1 then 1
	  when (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31,0)) <0 then 0
      else round (nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31,0))end)saldo_insol
	  INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app
    from bdicred:sd_sdodiario a inner join cred_act_op b
    on a.num_credito = b.num_credito
	where a.fecha = v_primero_mes
    and a.num_credito >= ''
    group by 1,2,3
    
   begin;
    UPDATE br_concil_consolidado set 
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
 end if;

 begin;
  UPDATE bdiburo:br_param
  SET valor = '2'
  WHERE cod_param = 131;
 commit;

LET vflag = '2';
DROP TABLE cred_act_op;
END IF;

IF vflag = 2 then    
    --Reestructuras - Activas
select a.num_producto,a.num_credito, a.status_cred ,
nvl(nvl(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
                     nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
                     nvl(mto_venc_int,0),0)    vsaldo_venc,
nvl(dias_atraso,0) vdiasatraso
from bdicred:sd_maecredcontcrd a inner join  bdicred:sd_maesdoscontcrd b
on a.fecha = b.fecha and a.empresa = b.empresa and a.num_credito = b.num_credito
inner join bdicred:sd_indicador_cred_crd c
on a.empresa = c.empresa and a.num_credito = c.num_credito
where a.fecha = v_fechaproceso
and a.empresa = '001'
and a.num_credito >= ''
and a.num_producto = '6011'
--Suc para pruebas
	--and substr(sucursal,1,4) in (select sucursal from bdiburo:suc_pro where des_suc = 'REEST') 
into temp crds_central1 WITH NO LOG; 

select a.*,nvl(nvl(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
                     nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
                     nvl(mto_venc_int,0),0)    vsaldo_vencAnt,
c.status_cred  vstatus_credAnt ,
CASE 
    WHEN (vdiasatraso >=   1 ) then 'PC'
	--WHEN ((c.status_cred  in ('BT','BA') and a.status_cred ='AA')
	WHEN (c.status_cred in ('BT','BA','VP','E1','E2','E3') and nvl(b.monto_vencido + b.mto_venc_trasp,0) > 0) AND (c.status_cred IN ('AA','VP','E1') and vsaldo_venc = 0 ) THEN 'EL'		
    ELSE '' END clave_obs  
from crds_central1 a left join  bdicred:sd_maesdoscontcrd b 
on a.num_credito = b.num_credito and b.fecha = v_fechaproceso_ant
left join bdicred:sd_maecredcontcrd c 
on c.empresa = '001' and a.num_credito = c.num_credito and c.fecha = v_fechaproceso_ant
into temp crds_central  WITH NO LOG; 

DROP TABLE crds_central1;

   foreach with hold
SELECT num_producto, status_cred, clave_obs, count(b.num_credito) total,
 sum(case 
     when (nvl(nvl(sdo_cap_insoluto,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) +nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(provision_normal,0) + nvl(sdo_global_int,0),0)) >0 
      and (nvl(nvl(sdo_cap_insoluto,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) +nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(provision_normal,0) + nvl(sdo_global_int,0),0)) <1 then 1
     else round (nvl(nvl(sdo_cap_insoluto,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) +nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(provision_normal,0) + nvl(sdo_global_int,0),0))end) saldo_actual,
 sum(case 
     when (nvl(vsaldo_venc,0)) >0 
      and (nvl(vsaldo_venc,0)) <1 then 1
     else round (nvl(vsaldo_venc,0))end) saldo_venc,
 sum(case 
     when (sdo_cap_insoluto) >0 
      and (sdo_cap_insoluto) <1 then 1
     else round (sdo_cap_insoluto)end)saldo_insoluto
INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app
from bdicred:sd_maesdoscontcrd a inner join crds_central b
on  a.num_credito = b.num_credito
where  a.fecha =  v_fechaproceso
and a.num_credito >= ''
and b.num_producto = '6011'
group by 1,2,3

   begin;
    UPDATE br_concil_consolidado set 
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
  WHERE cod_param = 131;
 commit;

LET vflag = '3';
DROP TABLE crds_central;
END IF;
     
IF vflag = 3 then
    --Tarjetas de CrÃÂ©dito - Canceladas
SELECT a.num_producto,a.STATUS_CRED, 'CC' clave_obs,count(unique b.NUM_CREDITO) can_total,  0 saldo_actual, 0 saldo_vencido, 0 saldo_insoluto		
  FROM bdicred:sd_maecred a inner join bdicred:sd_cred_can b
    ON a.num_credito = b.num_credito  AND fecha_can BETWEEN v_primero_mes AND v_fechaproceso 
 WHERE a.empresa = '001'
   AND a.num_credito >= ''
   AND a.status_cred = 'FF'
   AND a.num_producto = '6001'
   AND b.folio_cancelacion <> ''
--Suc para pruebas
  --AND a.sucursal in (select sucursal from bdiburo:suc_pro where des_suc = 'TDC')   
group by 1,2
INTO TEMP tmp_cred_can WITH NO LOG;
SELECT num_producto,STATUS_CRED, clave_obs, can_total, saldo_actual,saldo_vencido,  saldo_insoluto		
	INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app
	FROM tmp_cred_can;

--Suc para pruebas
  --AND a.sucursal in (select sucursal from bdiburo:suc_pro where des_suc = 'TDC') 

   begin;
    UPDATE br_concil_consolidado set 
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

 begin;
  UPDATE bdiburo:br_param
  SET valor = '4'
  WHERE cod_param = 131;
 commit;

LET vflag = '4';
END IF;

IF vflag = 4 then
    --Reestructuras - Canceladas
select num_producto, a.status_cred,'CC' clave_obs,count(a.NUM_CREDITO),  0 saldo_actual, 0 saldo_vencido, 0 saldo_insoluto	
INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	
from bdicred:sd_maecredcrd a inner join bdicred:sd_maecredanexocrd b
on b.empresa = a.empresa and a.num_credito = b.num_credito  and fecha_proceso  between  v_primero_mes and v_fechaproceso
where a.empresa = '001'
and a.num_Credito >= ''
and num_producto = '6011'
and status_cred = 'FF'
--Suc para pruebas
	--and substr(sucursal,1,4) in (select sucursal from bdiburo:suc_pro where des_suc = 'REEST') 
group by 1,2;

   begin;	  
	UPDATE br_concil_consolidado set 
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

 begin;
  UPDATE bdiburo:br_param
  SET valor = '5'
  WHERE cod_param = 131;
 commit;

LET vflag = '5';
END IF;
IF vflag = 5 then
select num_producto, a.STATUS_CRED,'RV' clave_obs , count(a.NUM_CREDITO) total,  0 saldo_actual, 
0 saldo_vencido,  0 saldo_insoluto
INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	
from bdicred:sd_maecred a inner join bdicred:sd_maesdos_vendida b
on  fecha  between  v_primero_mes and v_fechaproceso and b.empresa =  a.empresa and a.num_credito = b.num_credito
where a.empresa = '001'
and a.num_Credito >= ''
and status_cred = 'FC'
AND a.num_producto = '6001'
--Suc para pruebas
	--AND substr(sucursal,1,4) in (select sucursal from bdiburo:suc_pro where des_suc = 'TDC')  
group by 1,2;

   begin;		  
	UPDATE br_concil_consolidado set 
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

 begin;
  UPDATE bdiburo:br_param
  SET valor = '6'
  WHERE cod_param = 131;
 commit;

LET vflag = '6';
END IF;

IF vflag = 6 then
	      --Tarjetas de CrÃÂ©dito - Vendidas 
--Cambio Redondeo saldos vencidos IPCB/Enero2015
select a.num_credito,num_producto,
case 
    when (nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
       (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) from bdicred:sd_amortiza_credito_vendida
 where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')),0))  between 0.0000001 and 1 then 1   -- IFRS
    else 
    nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
       (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) from bdicred:sd_amortiza_credito_vendida
 where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')),0)   -- IFRS
    end saldo_vencido
from bdicred:sd_maecred a inner join bdicred:sd_maesdos_vendida b
on  fecha  
between  v_primero_mes and v_fechaproceso 
--between  mdy('12','01','2014') and  mdy('12','31','2014') 
and b.empresa =  a.empresa and a.num_credito = b.num_credito
where a.empresa = '001'
and a.num_Credito >= ''
and status_cred = 'CV'
--Suc para pruebas
	--AND substr(sucursal,1,4) in (select sucursal from bdiburo:suc_pro where des_suc = 'TDC')  
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
	UPDATE br_concil_consolidado set 
    sdo_actual_app = 0,
    sdo_vencido_app= vsaldo_venc_app,
    sdo_insoluto_app = 0,
    cred_central = vtotal_app
    WHERE fecha_proceso = v_fechaproceso
      and num_producto = '6001'
      and status_cred = 'CV'
      and clave_obs = 'CV'
      and (sdo_actual_app is null);
   commit;	  
--Cambio Redondeo saldos vencidos IPCB/Enero2015


 begin;
  UPDATE bdiburo:br_param
  SET valor = '7'
  WHERE cod_param = 131;
 commit;

LET vflag = '7';
END IF;



IF vflag = 7 then
	      --Reestrucrturas - Vendidas 
select num_producto, a.STATUS_CRED,a.STATUS_CRED  clave_obs, count(a.NUM_CREDITO) total,  0 saldo_actual, 
sum(case 
    when (nvl(nvl(monto_vencido + mto_venc_trasp,0) + nvl(int_tra_no_exig,0) +nvl(mto_venc_int,0),0))  between 0.0000001 and 1 then 1 
    else 
    round(nvl(nvl(monto_vencido + mto_venc_trasp,0) + nvl(int_tra_no_exig,0) +nvl(mto_venc_int,0),0))
    end )saldo_vencido,  0 saldo_insoluto
INTO cNumProducto_app,vstatus_cred_app,vclave_obs_app,vtotal_app,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app	
from bdicred:sd_maecredcrd a inner join bdicred:sd_maesdoscrd_vendida b
on  fecha  between v_primero_mes and v_fechaproceso and b.empresa = a.empresa and a.num_credito = b.num_credito  
where a.empresa = '001'
and a.num_Credito >= ''
AND NUM_PRODUCTO = '6011'
and status_cred = 'CV'
--Suc para pruebas
	--and substr(sucursal,1,4) in (select sucursal from bdiburo:suc_pro where des_suc = 'REEST') 
group by 1,2;		  
	
   begin;	
	UPDATE br_concil_consolidado set 
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

 begin;
  UPDATE bdiburo:br_param
  SET valor = '9'
  WHERE cod_param = 131;
 commit;

LET vflag = '9';
END IF;

IF vflag = 9 then
--Valores null los cambia por 0
 foreach with hold 
 	select num_producto,status_cred,clave_obs,NVL(sdo_actual_app,0), NVL(sdo_vencido_app,0),NVL(sdo_insoluto_app,0),cred_central 
	INTO cNumProducto_d,vstatus_cred_d,vclave_obs_d,vsaldo_actual_app,vsaldo_venc_app,vmonto_insoluto_app, vtotal_app
    FROM br_concil_consolidado	
	where fecha_proceso = v_fechaproceso 
    and cred_central is null

	IF vtotal_app is null THEN
		LET vtotal_app =  0;
		begin;	
			UPDATE br_concil_consolidado set 
			sdo_actual_app =vsaldo_actual_app,       
			sdo_vencido_app = vsaldo_venc_app, 
			sdo_insoluto_app  = vmonto_insoluto_app, 
			cred_central =  vtotal_app--,
			--cred_diferencia = ((cred_enviados+cred_excluidos)-vtotal_app)
			WHERE fecha_proceso = v_fechaproceso
			and num_producto = cNumProducto_d
			and status_cred = vstatus_cred_d
			and clave_obs = vclave_obs_d;
			--and cred_central is null ;
		commit;	
	END IF
  end foreach 
 begin;
  UPDATE bdiburo:br_param
  SET valor = '10'
  WHERE cod_param = 131;
 commit;
 
 LET vflag = '10'; 
END IF;


IF vflag = '10' then
  --CÃÂ¡lculo de diferencias.
 foreach with hold 
 
 	select num_producto,status_cred,clave_obs,
     NVL((sdo_actual_sicenv + sdo_actual_sicexc) - sdo_actual_app,0),
	  NVL ((sdo_vencido_sicenv + sdo_vencido_sicexc) - sdo_vencido_app,0),
	   NVL((sdo_insoluto_sicenv + sdo_insoluto_sicexc) - sdo_insoluto_app ,0),
	   NVL((cred_enviados + cred_excluidos) - cred_central ,0)
	INTO cNumProducto_d,vstatus_cred_d,vclave_obs_d,vsdo_actual_dif,vsdo_vencido_dif,vsdo_insoluto_dif,vcred_diferencia 
    FROM br_concil_consolidado	
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
	UPDATE br_concil_consolidado set 
    sdo_actual_dif = vsdo_actual_dif,
	sdo_vencido_dif = vsdo_vencido_dif,
	sdo_insoluto_dif  = vsdo_insoluto_dif,
	cred_diferencia =  vcred_diferencia
	WHERE fecha_proceso = v_fechaproceso
      and num_producto = cNumProducto_d
      and status_cred = vstatus_cred_d
      and clave_obs = vclave_obs_d;
   commit;	

   select diferencia
   Into b_diferencia
   from  br_fechas_concil
   where fecha_proceso = v_fechaproceso
   and num_producto = cNumProducto_d ;
   
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
   End If
   If (vsdo_actual_dif > 0 or vsdo_vencido_dif > 0 or vsdo_insoluto_dif  > 0 or vcred_diferencia >0) then
    begin;	
	UPDATE br_concil_consolidado set b_difprocesa ='D'       
	WHERE fecha_proceso = v_fechaproceso
	and num_producto = cNumProducto_d
	and status_cred = vstatus_cred_d
	and clave_obs = vclave_obs_d;
	commit;
   ELSE
    begin;
	UPDATE br_concil_consolidado set b_difprocesa =''       
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
  WHERE cod_param = 131;
 commit;

END IF;
  
LET cCodRet     = "000000";
LET cMensajeRet = "CONCILIACION "||vfecha_reporte|| " Ok.";

	RETURN cCodRet, cMensajeRet; 
END IF;
END;
END PROCEDURE;