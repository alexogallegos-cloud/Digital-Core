create procedure "informix".sp_rep_numsol_bc()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);

DEFINE v_ultimo_mes       DATE;
DEFINE v_primero_mes        DATE;
DEFINE vano                 CHAR(04);
DEFINE vmes                 CHAR(02);
DEFINE vdia                 CHAR(02);
DEFINE vfecha_reporte        CHAR(08); 

DEFINE vsql                 CHAR(1500);

DEFINE cruta                CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE vtipo                CHAR(4);
DEFINE vdescripcion         CHAR(40);
DEFINE vtotal               INTEGER;
DEFINE total 			INTEGER;

LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET cruta                   = "";
LET cnomarchivo             = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
END EXCEPTION;

--SET DEBUG FILE TO "sp_rep_numsol_bc.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

select pri_dia_mes -1, pri_dia_mes -  1 units month
into v_ultimo_mes,v_primero_mes
from bdicred:sd_fechas
where empresa = '001';

--temporal para pruebas
   --let v_ultimo_mes = mdy('07','31','2014');
   --let v_primero_mes  = mdy('07','01','2014');
--temporal para pruebas

   let vano = year(v_ultimo_mes);
   let vmes = lpad(month(v_ultimo_mes),2,"0");
   let vdia = lpad(day(v_ultimo_mes),2,"0");
   let vfecha_reporte = vdia||vmes||vano;

select valor
INTO cruta
from bdiburo:br_param
where cod_param = 139;

select valor||vfecha_reporte||'.txt'
INTO cnomarchivo
from bdiburo:br_param
where cod_param = 140;


SELECT unique a.num_solicitud,a.numcte,a.fecha_insert,fecha_hora,status_solicitud,b.num_solicitud_sic
FROM bdisolic:ss_solicitudes a inner join bdisolic:ss_solicitudes_sic b
  on a.numcte = b.numcte
 and a.num_solicitud = b.num_solicitud 
 and b.fecha_insert >= v_primero_mes  and b.fecha_insert <= v_ultimo_mes
WHERE a.fecha_insert >= v_primero_mes and a.fecha_insert <= v_ultimo_mes
into temp sol_sics with no log;  

begin;
CREATE INDEX idx_sol_sics ON sol_sics(num_solicitud_sic) ONLINE;
commit;

select case when substr (num_solicitud,1,2) = '60' then substr (num_solicitud,1,2)||'01'
            else  substr (num_solicitud,1,2)||'00' end tipo, count(*) tot_consultas
from bdiburo:sb_regreso
where num_solicitud in (select num_solicitud_sic from sol_sics )--where substr(num_solicitud_sic,1,2) in('60','63','64','70'))
and substr (regreso,1,4) = 'INTL'
group by 1
into temp numero_solicitudes_previo with no log; 

--IPCB Mayo2016 Reingenieria de Demonios.
insert into  numero_solicitudes_previo
select case when substr (num_solicitud,1,2) = '60' then substr (num_solicitud,1,2)||'01'
            else  substr (num_solicitud,1,2)||'00' end tipo, count(*) tot_consultas
from bdiburo:br_respuesta
where num_solicitud in (select num_solicitud_sic from sol_sics )--where substr(num_solicitud_sic,1,2) in('60','63','64','70'))
and secuencia = 1 
and substr (regreso,1,4) = 'INTL'
group by 1;

select tipo,sum( tot_consultas) tot_consultas
from numero_solicitudes_previo
group by 1
into temp numero_solicitudes with no log; 
--IPCB Mayo2016 Reingenieria de Demonios.

  --Ejecuta para poner Titulo al archivo.
  LET vsql='';
   LET vsql = 'echo "             REPORTE DE SOLICITUDES DE CRÉDITO" >'||TRIM(cruta)|| cnomarchivo;
  SYSTEM vsql; 

    --Ejecuta para poner periodo.
	LET vsql='';
        LET vsql = 'echo "PERIODO: '||v_primero_mes||' al '||v_ultimo_mes||'" >> '||TRIM(cruta)|| cnomarchivo;
   SYSTEM vsql; 
  --Ejecuta para poner encabezados.
	LET vsql='';
                LET vsql = 'echo "CLAVE'||' '||'             PRODUCTO                 '||' '||'# DE CONSULTAS'||'" >>'||TRIM(cruta)|| cnomarchivo;
   SYSTEM vsql; 

 let total =0;
foreach with hold
  select tipo,descrip_prod,tot_consultas 
INTO vtipo,vdescripcion,vtotal
    from numero_solicitudes a inner join bdicred:sd_tipprod b
      on abrevia_prod = tipo

	LET vsql='';
    LET vsql = 'echo "  '||vtipo||'    '||vdescripcion||vtotal||'" >> '||TRIM(cruta)|| cnomarchivo;	
  system vsql;

 let total = total +vtotal;
end foreach

 --Ejecuta para poner total de solicitudes
	LET vsql='';
        LET vsql = 'echo "			                   TOTAL   '||total||'" >> '||TRIM(cruta)|| cnomarchivo;
   SYSTEM vsql; 

LET cCodRet     = "000000";
LET cMensajeRet = "Reporte de solicitudes a BC "||vfecha_reporte|| " Ok.";

	RETURN cCodRet, cMensajeRet; 

END;
end procedure;