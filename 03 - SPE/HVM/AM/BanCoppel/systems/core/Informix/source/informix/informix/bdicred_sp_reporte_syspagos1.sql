CREATE PROCEDURE "informix".sp_reporte_syspagos1(pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(6)  AS codigo_retorno, 
          CHAR(80) AS mensaje_retorno;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6); 
DEFINE cMensajeRet   CHAR(80);
DEFINE iRegistros    INTEGER;
DEFINE dtHoraIni     DATETIME HOUR TO SECOND;
DEFINE dtHoraFin     DATETIME HOUR TO SECOND;

DEFINE dDeb1009i      DECIMAL(18,2);
DEFINE dDeb1009j      DECIMAL(18,2);
DEFINE dDeb1010i_f    DECIMAL(18,2);
DEFINE dDeb1010j_f    DECIMAL(18,2);
DEFINE dDeb1010i_m    DECIMAL(18,2);
DEFINE dDeb1010j_m    DECIMAL(18,2);
DEFINE dDeb1011i_f    DECIMAL(18,2);
DEFINE dDeb1011j_f    DECIMAL(18,2);
DEFINE dDeb1011i_m    DECIMAL(18,2);
DEFINE dDeb1011j_m    DECIMAL(18,2);
DEFINE dDeb1013i_f    DECIMAL(18,2);
DEFINE dDeb1013j_f    DECIMAL(18,2);
DEFINE dDeb1013i_m    DECIMAL(18,2);
DEFINE dDeb1013j_m    DECIMAL(18,2);
DEFINE dDeb1022i_f    DECIMAL(18,2);
DEFINE dDeb1022j_f    DECIMAL(18,2);
DEFINE dDeb1022i_m    DECIMAL(18,2);
DEFINE dDeb1022j_m    DECIMAL(18,2);
DEFINE dDeb1023i_f    DECIMAL(18,2);
DEFINE dDeb1023j_f    DECIMAL(18,2);
DEFINE dDeb1023i_m    DECIMAL(18,2);
DEFINE dDeb1023j_m    DECIMAL(18,2);
DEFINE dDeb1025i_f    DECIMAL(18,2);
DEFINE dDeb1025j_f    DECIMAL(18,2);
DEFINE dDeb1025i_m    DECIMAL(18,2);
DEFINE dDeb1025j_m    DECIMAL(18,2);
DEFINE dNom1009i_f    DECIMAL(18,2);
DEFINE dNom1009j_f    DECIMAL(18,2);
DEFINE dNom1010i_f    DECIMAL(18,2);
DEFINE dNom1010j_f    DECIMAL(18,2);
DEFINE dNom1011i_f    DECIMAL(18,2);
DEFINE dNom1011j_f    DECIMAL(18,2);
DEFINE dNom1022i_f_t  DECIMAL(18,2);
DEFINE dNom1022j_f_t  DECIMAL(18,2);
DEFINE dNom1023i_f_t  DECIMAL(18,2);
DEFINE dNom1023j_f_t  DECIMAL(18,2);
DEFINE dNom1025i_f_t  DECIMAL(18,2);
DEFINE dNom1025j_f_t  DECIMAL(18,2);

LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cMensajeRet    = "PROCESO EXITOSO";
LET iRegistros     = 0;

LET dDeb1009i      = 0;
LET dDeb1009j      = 0;
LET dDeb1010i_f    = 0;
LET dDeb1010j_f    = 0;
LET dDeb1010i_m    = 0;
LET dDeb1010j_m    = 0;
LET dDeb1011i_f    = 0;
LET dDeb1011j_f    = 0;
LET dDeb1011i_m    = 0;
LET dDeb1011j_m    = 0;
LET dDeb1013i_f    = 0;
LET dDeb1013j_f    = 0;
LET dDeb1013i_m    = 0;
LET dDeb1013j_m    = 0;
LET dDeb1022i_f    = 0;
LET dDeb1022j_f    = 0;
LET dDeb1022i_m    = 0;
LET dDeb1022j_m    = 0;
LET dDeb1023i_f    = 0;
LET dDeb1023j_f    = 0;
LET dDeb1023i_m    = 0;
LET dDeb1023j_m    = 0;
LET dDeb1025i_f    = 0;
LET dDeb1025j_f    = 0;
LET dDeb1025i_m    = 0;
LET dDeb1025j_m    = 0;
LET dNom1009i_f    = 0;
LET dNom1009j_f    = 0;
LET dNom1010i_f    = 0;
LET dNom1010j_f    = 0;
LET dNom1011i_f    = 0;
LET dNom1011j_f    = 0;
LET dNom1022i_f_t  = 0;
LET dNom1022j_f_t  = 0;
LET dNom1023i_f_t  = 0;
LET dNom1023j_f_t  = 0;
LET dNom1025i_f_t  = 0;
LET dNom1025j_f_t  = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_sispagos.out';
--TRACE OFF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraIni
FROM sysmaster:"informix".sysshmvals;

------------------------------
-- Cuentas de Débito
------------------------------

-- Cuentas básicas para el público en general (1)
select count(*),1
into dDeb1009i,dDeb1009j
from bdicheq:sc_maenoc a
INNER JOIN bdicheq:sc_maechq b on (a.empresa = b.empresa and b.cuenta=a.cuenta and b.producto IN ('1400','1700','1300'))
where a.empresa ='001' 
and b.status_cta <> '2'
and a.fecha_alta <= MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin));

-- Total de cuentas con TDD (al último día del trimestre) personas Fisica (2)
select count(*),1
into dDeb1010i_f,dDeb1010j_f
from bdicheq:sc_maenoc a
inner join bdicheq:sc_maechq b on (a.empresa=b.empresa and b.cuenta=a.cuenta and b.producto <> '1100')
where a.empresa='001'
and a.fecha_alta <= mdy(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and b.status_cta <> '2' 
and a.cuenta in (select cuenta from bdicheq:sc_tarjeta where a.empresa=empresa and a.cuenta=cuenta and status_tar = 'A');


-- Total de cuentas con TDD (al último día del trimestre) personas Morales (3)
select count(*),0
 INTO dDeb1010i_m, dDeb1010j_m
from bdicheq:sc_maenoc a
inner join bdicheq:sc_maechq b on (a.empresa=b.empresa and b.cuenta=a.cuenta and b.producto <> '1100')
where a.empresa='001'
and b.status_cta <> '2'
and a.fecha_alta <= mdy(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and a.cuenta in (select cuenta from bdicheq:sc_tarjeta where a.empresa=empresa and a.cuenta=cuenta and status_tar = 'A')
and b.num_cte in (select numcte from bdinteg:si_cliente where a.empresa=empresa and tpo_persona<>'01');
 
-- Cuentas abiertas con TDD (durante el trimestre) personas Fisicas (4)
select count(*),0
INTO dDeb1011i_f,dDeb1011j_f
from bdicheq:sc_maenoc a
inner join bdicheq:sc_maechq b on (a.empresa=b.empresa and b.cuenta=a.cuenta and b.producto <> '1100')
where a.empresa='001'
and b.status_cta <> '2'
and a.fecha_alta BETWEEN mdy(month(pFechaIni),day(pFechaIni),YEAR(pFechaIni)) and MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and a.cuenta in (select cuenta from bdicheq:sc_tarjeta where a.empresa=empresa and a.cuenta=cuenta and status_tar = 'A');
 
 
-- Cuentas abiertas con TDD (durante el trimestre) personas Morales (5)
select count(*),0
 INTO dDeb1011i_m, dDeb1011j_m
from bdicheq:sc_maenoc a
inner join bdicheq:sc_maechq b on (a.empresa=b.empresa and b.cuenta=a.cuenta and b.producto <> '1100')
where a.empresa='001'
and b.status_cta <> '2'
and a.fecha_alta BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and a.cuenta in (select cuenta from bdicheq:sc_tarjeta where a.empresa=empresa and a.cuenta=cuenta and status_tar = 'A')
and b.num_cte IN  (select numcte from bdinteg:si_cliente where a.empresa=empresa and tpo_persona<>'01');

-- Canceladas con TDD (durante el trimestre) personas Fisica (6)
select count(*),0
INTO dDeb1013i_f, dDeb1013j_f
from bdicheq:sc_maenoc a
inner join bdicheq:sc_maechq b on (a.empresa=b.empresa and b.cuenta=a.cuenta and b.producto <> '1100')
where a.empresa='001'
and b.status_cta = '2' 
and b.fec_cancelac BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and a.cuenta in (select cuenta from bdicheq:sc_tarjeta where a.empresa=empresa and a.cuenta=cuenta);

-- Canceladas con TDD (durante el trimestre) personas Morales (7)
select count(*),0
   INTO dDeb1013i_m, dDeb1013j_m
from bdicheq:sc_maenoc a
inner join bdicheq:sc_maechq b on (a.empresa=b.empresa and b.cuenta=a.cuenta and b.producto <> '1100')
where a.empresa='001'
and b.status_cta = '2' 
and b.fec_cancelac BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and a.cuenta in (select cuenta from bdicheq:sc_tarjeta where a.empresa=empresa and a.cuenta=cuenta) --and status_tar = 'A')
and b.num_cte IN  (select numcte from bdinteg:si_cliente where a.empresa=empresa and tpo_persona<>'01');
   
------------------------------
-- Totales cuentas de Débito
------------------------------

-- Total de cuentas personas Fisica
LET dDeb1022i_f = dDeb1010i_f; --(20)

IF dDeb1010i_f > 0 then 
  LET dDeb1022j_f = (dDeb1010i_f * dDeb1010j_f) / dDeb1010i_f;
END IF;

-- Total de cuentas personas Morales
LET dDeb1022i_m = dDeb1010i_m; --(21)
IF dDeb1010i_m > 0 THEN 
  LET dDeb1022j_m = (dDeb1010i_m * dDeb1010j_m) / dDeb1010i_m;
END IF;

-- Total de cuentas abiertas personas Fisica
LET dDeb1023i_f = dDeb1011i_f; --(22)
LET dDeb1023j_f = 0;

-- Total de cuentas abiertas personas Morales
LET dDeb1023i_m = dDeb1011i_m; --(23)
LET dDeb1023j_m = 0;

-- Total de cuentas canceladas personas Fisica
LET dDeb1025i_f = dDeb1013i_f; --(24)
LET dDeb1025j_f = 0;

-- Total de cuentas canceladas personas Morales
LET dDeb1025i_m = dDeb1013i_m; --(25)
LET dDeb1025j_m = 0;

------------------------------
-- Cuentas de Nomina
------------------------------

-- Cuentas básicas de nómina personas Fisicas (26)
select count(*),0
 INTO dNom1009i_f, dNom1009j_f
from bdicheq:sc_maenoc a
inner join bdicheq:sc_maechq b on (a.empresa=b.empresa and b.cuenta=a.cuenta and b.producto IN ('1700','1300'))
where a.fecha_alta <= MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and b.status_cta <> '2';
   
-- Total de cuentas con TDD (al último día del trimestre) personas Fisicas (27)
select count(*),0
INTO dNom1010i_f, dNom1010j_f
from bdicheq:sc_maenoc a
inner join bdicheq:sc_maechq b on (a.empresa=b.empresa and b.cuenta=a.cuenta and b.producto in ('1300','1700'))
where a.empresa='001'
and a.fecha_alta <= MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and b.status_cta <> '2' 
and a.cuenta in (select cuenta from bdicheq:sc_tarjeta where a.empresa=empresa and a.cuenta=cuenta and status_tar = 'A');
 

-- Cuentas abiertas con TDD (durante el trimestre) personas Fisicas (28)
select count(*),0
 INTO dNom1011i_f, dNom1011j_f
from bdicheq:sc_maenoc a
inner join bdicheq:sc_maechq b on (a.empresa=b.empresa and b.cuenta=a.cuenta and b.producto IN ('1700','1300'))
where a.empresa='001'
and a.fecha_alta BETWEEN MDY(MONTH(pFechaIni),01,YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and b.status_cta <> '2'
and a.cuenta in (select cuenta from bdicheq:sc_tarjeta where a.empresa=empresa and a.cuenta=cuenta and status_tar = 'A');
 
------------------------------
-- Totales cuentas de Nomina
------------------------------

-- Total de cuentas de Nomina
LET dNom1022i_f_t = dNom1010i_f; --(33)
IF dNom1010i_f > 0 THEN 
	LET dNom1022j_f_t = (dNom1010i_f * dNom1010j_f)/dNom1010i_f;
END IF;

-- Total de cuentas de Nomina abiertas
LET dNom1023i_f_t = dNom1011i_f; -- (34)
LET dNom1023j_f_t = 0;

-- Total de cuentas de Nomina canceladas
LET dNom1025i_f_t = 0; --(35)
LET dNom1025j_f_t = 0;

SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraFin 
FROM sysmaster:"informix".sysshmvals;

INSERT INTO bdicred:"informix".sd_reporte_sispagos_sec1
    VALUES (pFechaIni, pFechaFin, dDeb1009i, dDeb1009j, dDeb1010i_f, dDeb1010j_f, dDeb1010i_m, dDeb1010j_m, dDeb1011i_f, dDeb1011j_f, 
			dDeb1011i_m, dDeb1011j_m, dDeb1013i_f, dDeb1013j_f, dDeb1013i_m, dDeb1013j_m, dNom1009i_f, dNom1009j_f, dNom1010i_f,
			dNom1010j_f, dNom1011i_f, dNom1011j_f, dDeb1022i_f, dDeb1022j_f, dDeb1022i_m, dDeb1022j_m, dDeb1023i_f, dDeb1023j_f,
			dDeb1023i_m, dDeb1023j_m, dDeb1025i_f, dDeb1025j_f, dDeb1025i_m, dDeb1025j_m, dNom1022i_f_t, dNom1022j_f_t, dNom1023i_f_t,
			dNom1023j_f_t, dNom1025i_f_t, dNom1025j_f_t, dtHoraIni,dtHoraFin);

RETURN cCodRet, cMensajeRet;
 
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la',
'obtención de la información para el',
'reporte de sispagos',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 02/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_syspagos2(pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(6)  AS codigo_retorno, 
          CHAR(80) AS mensaje_retorno;
		  
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6); 
DEFINE cMensajeRet   CHAR(80);
DEFINE iRegistros    INTEGER;
DEFINE dtHoraIni     DATETIME HOUR TO SECOND;
DEFINE dtHoraFin     DATETIME HOUR TO SECOND;
DEFINE dCred1726i    DECIMAL(18,2);
DEFINE dCred1727i    DECIMAL(18,2);
DEFINE dCred1728i    DECIMAL(18,2);
DEFINE dCred1723i    DECIMAL(18,2);
DEFINE dCred1724i    DECIMAL(18,2);
DEFINE dCred1730i    DECIMAL(18,2);
DEFINE dCred1731i    DECIMAL(18,2);
DEFINE dCred1732i    DECIMAL(18,2);
DEFINE dCred1733i    DECIMAL(18,2);
DEFINE dCred1734i    DECIMAL(18,2);
DEFINE dCred1736i    DECIMAL(18,2);

DEFINE dCred1701i    DECIMAL(18,2);
DEFINE dCred1701j    DECIMAL(18,2);
DEFINE dDeb7013i    DECIMAL(18,2);
DEFINE dDeb7015i    DECIMAL(18,2);
DEFINE dDeb1709i    DECIMAL(18,2);
DEFINE dDeb1709j    DECIMAL(18,2);

DEFINE dCred7013i    DECIMAL(18,2);
DEFINE dCred7014i    DECIMAL(18,2);
DEFINE dCred1709i    DECIMAL(18,2);
DEFINE dCred1709j    DECIMAL(18,2);
DEFINE dcred1709i_c    DECIMAL(18,2);
DEFINE dcred1709j_c    DECIMAL(18,2);

DEFINE dCred1707i    DECIMAL(18,2);
DEFINE dCred1707j    DECIMAL(18,2);

DEFINE dDeb7013_276i    DECIMAL(18,2);
DEFINE dDeb7014_278i    DECIMAL(18,2);
DEFINE dDeb1709_414i    DECIMAL(18,2);
DEFINE dDeb1709_414j    DECIMAL(18,2);
DEFINE dDeb1709_420i    DECIMAL(18,2);
DEFINE dDeb1709_420j    DECIMAL(18,2);
DEFINE dDeb7011j    DECIMAL(18,2);
DEFINE dDeb7011i    DECIMAL(18,2);
DEFINE dDeb7014_253j    DECIMAL(18,2);
DEFINE dDeb7014_253i    DECIMAL(18,2);
DEFINE dCred7011j    DECIMAL(18,2);
DEFINE dCred7011i    DECIMAL(18,2);

DEFINE dCred7014_268j    DECIMAL(18,2);
DEFINE dCred7014_268i    DECIMAL(18,2);


DEFINE dtFechaCorteAnt  DATE;
DEFINE cFecha  CHAR(6);

LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cMensajeRet    = "PROCESO EXITOSO";
LET iRegistros     = 0;
LET  dCred1726i    = 0;
LET  dCred1727i    = 0;
LET  dCred1728i    = 0;
LET  dCred1723i    = 0;
LET  dCred1724i    = 0;
LET  dCred1730i    = 0;
LET  dCred1731i    = 0;
LET  dCred1732i    = 0;
LET  dCred1733i    = 0;
LET  dCred1734i    = 0;
LET  dCred1736i    = 0;



LET  dCred1701i    = 0;
LET  dCred1701j    = 0;
LET  dDeb7013i    = 0;
LET  dDeb7015i    = 0;
LET  dDeb1709i    = 0;
LET  dDeb1709j    = 0;

LET  dCred7013i    = 0;
LET  dCred7014i    = 0;
LET  dCred1709i    = 0;
LET  dCred1709j    = 0;
--agregada
LET dcred1709i_c		= 0;
LET dcred1709j_c		= 0;

LET  dCred1707i    = 0;
LET  dCred1707j    = 0;

LET  dDeb7013_276i    = 0;
LET  dDeb7014_278i    = 0;
LET  dDeb1709_414i    = 0;
LET  dDeb1709_414j    = 0;
LET  dDeb1709_420i    = 0;
LET  dDeb1709_420j    = 0;
LET  dDeb7011j    = 0;
LET  dDeb7011i    = 0;
LET  dDeb7014_253j    = 0;
LET  dDeb7014_253i    = 0;
LET  dCred7011j    = 0;
LET  dCred7011i    = 0;

LET  dCred7014_268j    = 0;
LET  dCred7014_268i    = 0;

LET dtFechaCorteAnt    = DATE(1);
LET cFecha    = "";


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/respaldos/pruebas/sispagos/sp_sispagos_x_25042013_janethe.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraIni
FROM sysmaster:"informix".sysshmvals;

select nro_tarjeta nro_tarjeta--,sum(monto) monto
    from bdicred:sd_movhis
   where empresa='001'
    and codigo_fun ='002'
	and codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64,65,37,57)
    and fecha_mov  
    between MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
     and reversado='N'
     --and ((nro_tarjeta matches '426807*') or (nro_tarjeta matches '554948*'))
--group by nro_tarjeta
into temp tarjetas_utilizadas_37 with no log;

create index inx_tarjetas_utilizadas_37 on tarjetas_utilizadas_37(nro_tarjeta);
update statistics medium for table tarjetas_utilizadas_37;

select count(distinct nro_tarjeta) 
INTO dCred1727i  -- (37)
from tarjetas_utilizadas_37;

select num_tarjeta num_tarjeta
from bdicheq:sc_movhis_old
where fech_alt between MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and transacc in ('0801','0830','0881','0887','0223','0800','0805','0832',
'0871','0872','0873','1101','1107','1110','1284','1289','1298','1310',
'1311','1315','1434','1437','1442')
and substr(num_tarjeta,1,6) in (select bin from intercard:bines where creditodebito='D')
and cancelad <> 'S' 
union all
select num_tarjeta num_tarjeta
from bdicheq:sc_movhis
where fech_alt between MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and transacc in ('0801','0830','0881','0887','0223','0800','0805','0832',
'0871','0872','0873','1101','1107','1110','1284','1289','1298','1310',
'1311','1315','1434','1437','1442')
and substr(num_tarjeta,1,6) in (select bin from intercard:bines where creditodebito='D')
and cancelad <> 'S' 
into temp tarjetas_utilizadas_deb_40 with no log;
create index inx_tarjetas_utilizadas_deb_40 on tarjetas_utilizadas_deb_40(num_tarjeta);
update statistics medium for table tarjetas_utilizadas_deb_40;

select count(distinct num_tarjeta) 
into dCred1723i --(40)
from tarjetas_utilizadas_deb_40;


LET dCred1728i = dCred1727i;
LET dCred1724i = dCred1723i;
LET dCred1732i = dCred1724i;
LET dCred1733i = dCred1728i;

select cuenta cuenta,sum(monto_tot) suma 
from bdicheq:sc_movhis_old
where fech_alt between MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and transacc in ('0223','0227','0231','0235','0239','0251','0252','0253',
'0262','0270','0274','0281','0290','0297','0298','0299','0800','0830','0871',
'0873','0887','1131','1133','1134','1137','1138','1139','1140','1141','1145',
'1146','1161','1164','1167','1191','1193','1194','1195','1302','3005','3220',
'3247','3259')
and cancelad <> 'S' 
group by cuenta
union all
select cuenta cuenta,sum(monto_tot) suma 
from bdicheq:sc_movhis
where fech_alt between MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and transacc in ('0223','0227','0231','0235','0239','0251','0252','0253',
'0262','0270','0274','0281','0290','0297','0298','0299','0800','0830','0871',
'0873','0887','1131','1133','1134','1137','1138','1139','1140','1141','1145',
'1146','1161','1164','1167','1191','1193','1194','1195','1302','3005','3220',
'3247','3259')
and cancelad <> 'S' 
group by cuenta
into temp cas_relacionadas_deb with no log;

create index inx_cas_relacionadas_deb on cas_relacionadas_deb(cuenta);
update statistics medium for table cas_relacionadas_deb;

LET cFecha = YEAR(pFechaFin)||LPAD(MONTH(pFechaFin),2,'0');
--resultado
IF DAY(pFechaFin) = 31 THEN
	set isolation to dirty read;
	select cas.cuenta cuenta1, sum(mas.capvig31) suma1
		from cas_relacionadas_deb cas  
		join bdicheq:sc_sdodiarioc mas on mas.cuenta=cas.cuenta and mas.aniomes = cFecha and mas.capvig31 > 0
	group by cas.cuenta
	into temp cas_relacionadas_deb_80 with no log;
else
	select cas.cuenta cuenta1, sum(mas.capvig30) suma1
		from cas_relacionadas_deb cas  
		join bdicheq:sc_sdodiarioc mas on mas.cuenta=cas.cuenta and mas.aniomes = cFecha and mas.capvig30 > 0
	group by cas.cuenta
	into temp cas_relacionadas_deb_80 with no log;
END IF;

create index inx_cas_relacionadas_deb_80 on cas_relacionadas_deb_80(cuenta1);
update statistics medium for table cas_relacionadas_deb_80;

set isolation to dirty read;
select count(distinct cuenta1), nvl(sum(suma1),0)  
into dCred1701i,dCred1701j --(80)
from cas_relacionadas_deb_80;
	
SELECT  numtarjeta numtarjeta,
        sum(case when trancajeroconvenio='F' AND trancajeropropio='V' AND codtran='31' then 1 else 0 end) datos1,
        sum(case when trancajeropropio='F' AND codtran='31' then 1 else 0 end) datos2
                FROM intercard:movimiento
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and substr(numtarjeta,1,6) in (select bin from intercard:bines where creditodebito='D')
                group by numtarjeta
union all
SELECT  numtarjeta numtarjeta,
        sum(case when trancajeroconvenio='F' AND trancajeropropio='V' AND codtran='31' then 1 else 0 end) datos1,
        sum(case when trancajeropropio='F' AND codtran='31' then 1 else 0 end) datos2
                FROM intercard:movimientohistorico
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and substr(numtarjeta,1,6) in (select bin from intercard:bines where creditodebito='D')
                group by numtarjeta
into temp cas_completo_252_254 with no log;
create index inx_cas_completo_252_254 on cas_completo_252_254(numtarjeta);
update statistics medium for table cas_completo_252_254;

select sum(datos1),sum(datos2) 
INTO dDeb7013i,dDeb7015i --(252,254)
from cas_completo_252_254;

--columnas 247, 253, 259 y 268

select sum(case when descripcion matches 'RETIR*CHEQU*' or descripcion matches 'RETIR*MAESTR*' THEN monto ELSE 0 END)deb7011bm,
       sum(case when descripcion matches 'RETIR*CHEQU*' or descripcion matches 'RETIR*MAESTR*' THEN 1 ELSE 0 END)deb7011bm_m,
       sum(case when descripcion matches 'CONSU*CHEQU*' or descripcion matches 'CONSU*MAESTR*' THEN monto ELSE 0 END)deb7014,
       sum(case when descripcion matches 'CONSU*CHEQU*' or descripcion matches 'CONSU*MAESTR*' THEN 1 ELSE 0 END)deb7014_m,
       sum(case when descripcion matches 'RETIR*CREDI*' THEN monto ELSE 0 END)cred7011bm,
       sum(case when descripcion matches 'RETIR*CREDI*' THEN 1 ELSE 0 END)cred7011bm_m,
       sum(case when descripcion matches 'CONSU*CREDI*' THEN monto ELSE 0 END)cred7014,
       sum(case when descripcion matches 'CONSU*CREDI*' THEN 1 ELSE 0 END)cred7014_m
   INTO dDeb7011j,dDeb7011i,dDeb7014_253j,dDeb7014_253i,dCred7011j,dCred7011i,dCred7014_268j,dCred7014_268i
   from intercard:conciliacion_atm_stat06 
   where keyx>0 
    and date(mdy(substr(fecha,4,2),substr(fecha,1,2),lpad(substr(fecha,7,2),4,'2000')))  BETWEEN mdy(month(pFechaIni),01,year(pFechaIni)) AND MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
    and archivoorigen in ('TMP','TMO') 
    and substr(numtarjeta,1,6) not in ('400819','426807','416916') and codigoiso='00';
 
SELECT  numtarjeta numtarjeta_423,
      sum(case when prodind='02' and codtran='00' then 1 else 0 end)datos3,
      sum(case when prodind='02' and codtran='00' then monto else 0 end) datos4
                FROM intercard:movimiento
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and substr(numtarjeta,1,6) in (select bin from intercard:bines where creditodebito='C')
                group by numtarjeta
union all
SELECT  numtarjeta numtarjeta_423,
         sum(case when prodind='02' and codtran='00' then 1 else 0 end)datos3,
        sum(case when prodind='02' and codtran='00' then monto else 0 end) datos4
                FROM intercard:movimientohistorico
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and substr(numtarjeta,1,6) in (select bin from intercard:bines where creditodebito='C')
                group by numtarjeta
into temp cas_cred_chip_423 with no log;  
create index inx_cas_cred_chip_423 on cas_cred_chip_423(numtarjeta_423);
update statistics medium for table cas_cred_chip_423;

set isolation to dirty read;
select sum(datos3),sum(datos4) 
into dCred1709i,dCred1709j --(423)
from cas_cred_chip_423;   

LET dcred1709i_c	= 	dCred1709i;
LET dcred1709j_c	= 	dCred1709j;

 SELECT numtarjeta numtarjeta443,
sum(case when metodocaptura = '01' and tipotransaccionposdigitada='CE' then 1 else 0 end) datosc5,
--transsacciones en internett
sum(case when metodocaptura = '01' and tipotransaccionposdigitada='CE' then monto else 0 end) datosc6
                FROM intercard:movimiento
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and substr(numtarjeta,1,6) in (select bin from intercard:bines where creditodebito='C')
                group by numtarjeta
union all
 SELECT numtarjeta numtarjeta443,
sum(case when metodocaptura = '01' and tipotransaccionposdigitada='CE' then 1 else 0 end) datosc5,
--transsacciones en internett
sum(case when metodocaptura = '01' and tipotransaccionposdigitada='CE' then monto else 0 end) datosc6
                FROM intercard:movimientohistorico
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and substr(numtarjeta,1,6) in (select bin from intercard:bines where creditodebito='C')
                group by numtarjeta
into temp cas_completo_443 with no log;
create index inx_cas_completo_443 on cas_completo_443(numtarjeta443);
update statistics medium for table cas_completo_443;

select sum(datosc5),sum(datosc6) 
into dCred1707i,dCred1707j --(443)
from cas_completo_443; 

 --COLUMNA 276 y COLUMNA 278.
set isolation to dirty read;
SELECT  a.numtarjeta numtarjeta276,
sum(case when a.trancajeroconvenio='F' AND a.trancajeropropio='V' AND a.codtran='31' then 1 else 0 end) datos1,
--Consultas de clientes propios en cajeros propios
sum(case when a.trancajeropropio='F' AND a.codtran='31' then 1 else 0 end) datos2 --Consultas de clientes propios en cajeros de otros bancos
                FROM intercard:movimientohistorico a,
                intercard:tarjeta b
                where a.esnacional='V' 
                AND a.codigoiso='00' 
                and a.movreversado='F' 
                AND a.prodind in ('01','02')
                AND a.codtran in ('01','31','00')
                AND a.formato='0200'
                AND DATE(a.fechahorainauth)  
                    BETWEEN  MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and substr(a.numtarjeta,1,6) in (select bin from intercard:bines where creditodebito='D')
                and a.numtarjeta=b.numtarjeta and b.codproductotarjeta='503'
                group by a.numtarjeta
union all
SELECT  a.numtarjeta numtarjeta276,
        sum(case when a.trancajeroconvenio='F' AND a.trancajeropropio='V' AND a.codtran='31' then 1 else 0 end) datos1,
--Consultas de clientes propios en cajeros propios
       sum(case when a.trancajeropropio='F' AND a.codtran='31' then 1 else 0 end) datos2--Consultas de clientes propios en cajeros de otros bancos
                FROM intercard:movimiento a,
                    intercard:tarjeta b
                where a.esnacional='V' 
                AND a.codigoiso='00' 
                and a.movreversado='F' 
                AND a.prodind in ('01','02')
                AND a.codtran in ('01','31','00')
                AND a.formato='0200'
                AND DATE(a.fechahorainauth)  
                    BETWEEN  MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                 and substr(a.numtarjeta,1,6) in (select bin from intercard:bines where creditodebito='D')
                and a.numtarjeta=b.numtarjeta 
                and b.codproductotarjeta='503'
                group by a.numtarjeta
into temp cas_276_278 with no log;
create index inx_cas_276_278 on cas_276_278(numtarjeta276);
update statistics medium for table cas_276_278;

select sum(datos1),sum(datos2) 
INTO dDeb7013_276i,dDeb7014_278i
from cas_276_278;
 
 --COLUMNA 267 Y COLUMNA 269
 SELECT numtarjeta numtarjeta267,
sum(case when trancajeroconvenio='F' AND trancajeropropio='V' AND codtran='31' then 1 else 0 end) datosc1,
--Consultas de clientes propios en cajeros propios
sum(case when trancajeropropio='F' AND codtran='31' then 1 else 0 end) datosc2
--Consultas de clientes propios en cajeros de otros bancos
                FROM intercard:movimiento
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and substr(numtarjeta,1,6) in (select bin from intercard:bines where creditodebito='C')
                group by numtarjeta
union all
 SELECT numtarjeta numtarjeta267,
sum(case when trancajeroconvenio='F' AND trancajeropropio='V' AND codtran='31' then 1 else 0 end) datosc1,
--Consultas de clientes propios en cajeros propios
sum(case when trancajeropropio='F' AND codtran='31' then 1 else 0 end) datosc2
--Consultas de clientes propios en cajeros de otros bancos
                FROM intercard:movimientohistorico
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and substr(numtarjeta,1,6) in (select bin from intercard:bines where creditodebito='C')
                group by numtarjeta
into temp cas_267_269 with no log;
create index inx_cas_267_269 on cas_267_269(numtarjeta267);
update statistics medium for table cas_267_269;


select sum(datosc1),sum(datosc2) 
into dCred7013i,dCred7014i --(267-269)
from cas_267_269;


--con chip 414
SELECT  numtarjeta tarjeta414,
      sum(case when prodind='02' and codtran='00' then 1 else 0 end)datos3,
      sum(case when prodind='02' and codtran='00' then monto else 0 end) datos4
                FROM intercard:movimiento
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and (numtarjeta matches '416916*' or (numtarjeta matches '559471*'))
                group by numtarjeta
union all
SELECT  numtarjeta tarjeta414,
         sum(case when prodind='02' and codtran='00' then 1 else 0 end)datos3,
        sum(case when prodind='02' and codtran='00' then monto else 0 end) datos4
                FROM intercard:movimientohistorico
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and (numtarjeta matches '416916*' or (numtarjeta matches '559471*'))
                group by numtarjeta
into temp cas_414 with no log;  
create index inx_cas_414 on cas_414(tarjeta414);
update statistics medium for table cas_414;

select sum(datos3),sum(datos4) 
INTO dDeb1709_414i,dDeb1709_414j --(414)
from cas_414;  


SELECT  numtarjeta numtarjeta417,
                       sum(case when prodind='02' and codtran='00' then 1 else 0 end)datos3,
                       sum(case when prodind='02' and codtran='00' then monto else 0 end) datos4
                FROM intercard:movimiento
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and numtarjeta matches '400819*'
                group by numtarjeta
union all
SELECT  numtarjeta numtarjeta417,
                       sum(case when prodind='02' and codtran='00' then 1 else 0 end)datos3,
                       sum(case when prodind='02' and codtran='00' then monto else 0 end) datos4
                FROM intercard:movimientohistorico
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
                AND DATE(fechahorainauth)  BETWEEN MDY(MONTH(pFechaIni),DAY(pFechaIni),YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
                and numtarjeta matches '400819*'
                group by numtarjeta
into temp cas_completo_417 with no log;
create index inx_cas_completo_417 on cas_completo_417(numtarjeta417);
update statistics medium for table cas_completo_417;

select sum(datos3),sum(datos4) 
into dDeb1709i,dDeb1709j --(417)
from cas_completo_417; 

LET dDeb1709_420i =  dDeb1709_414i + dDeb1709i;
LET dDeb1709_420j =  dDeb1709_414j + dDeb1709j;
	
	
SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraFin 
FROM sysmaster:"informix".sysshmvals;

INSERT INTO bdicred:"informix".sd_reporte_sispagos_sec2   VALUES 
(pFechaIni,pFechaFin ,dCred1726i ,dCred1727i ,dCred1728i  ,dCred1723i ,dCred1724i ,
dCred1730i ,dCred1731i ,dCred1732i ,dCred1733i ,dCred1734i ,dCred1736i,
dCred1701i ,dCred1701j ,dDeb7013i ,dDeb7015i ,dDeb1709i ,dDeb1709j ,dCred7013i ,
dCred7014i ,dCred1709i ,dCred1709j , dcred1709i_c, dcred1709j_c,
dCred1707i ,dCred1707j ,dDeb7013_276i ,dDeb7014_278i ,
dDeb1709_414i ,dDeb1709_414j ,dDeb1709_420i ,dDeb1709_420j,dDeb7011j ,dDeb7011i ,dDeb7014_253j ,dDeb7014_253i ,
dCred7011j ,dCred7011i ,dCred7014_268j ,dCred7014_268i ,dtHoraIni,dtHoraFin);
 
 
--LET cMensajeRet = dtHoraIni || "  " || dtHoraFin;
RETURN cCodRet, cMensajeRet;
 
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la',
'obtención de la información para la',
'2da parte que conforma el reporte',
'de sispagos',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 25/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_syspagos3(pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(6)  AS codigo_retorno, 
          CHAR(80) AS mensaje_retorno;
		  
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6); 
DEFINE cMensajeRet   CHAR(80);
DEFINE iRegistros    INTEGER;
DEFINE dtHoraIni     DATETIME HOUR TO SECOND;
DEFINE dtHoraFin     DATETIME HOUR TO SECOND;
DEFINE dCred2400i    DECIMAL(18,2);
DEFINE dCred2401i    DECIMAL(18,2);
DEFINE dCred2402i    DECIMAL(18,2);
DEFINE dCred2403i    DECIMAL(18,2);
DEFINE dCred2404i    DECIMAL(18,2);
DEFINE dCred2406i    DECIMAL(18,2);
DEFINE dCred2500i    DECIMAL(18,2);
DEFINE dCred2501i    DECIMAL(18,2);
DEFINE dCred2502i    DECIMAL(18,2);
DEFINE dCred2503i    DECIMAL(18,2);
DEFINE dCred2504i    DECIMAL(18,2);
DEFINE dCred2505i    DECIMAL(18,2);
DEFINE dCred1700i    DECIMAL(18,2);
DEFINE dCred1700j    DECIMAL(18,2);
DEFINE dCred1701i    DECIMAL(18,2);
DEFINE dCred1701j    DECIMAL(18,2);

DEFINE dCred1740i    DECIMAL(18,2);
DEFINE dCred1741i    DECIMAL(18,2);
DEFINE dCred1742i    DECIMAL(18,2);
DEFINE dCred1743i    DECIMAL(18,2);
DEFINE dCred1745i    DECIMAL(18,2);
DEFINE dCred1746i    DECIMAL(18,2);
DEFINE dCred1747i    DECIMAL(18,2);
DEFINE dCred1748i    DECIMAL(18,2);
DEFINE dCred7010i    DECIMAL(18,2);
DEFINE dCred7010j    DECIMAL(18,2);
DEFINE dCred7012i    DECIMAL(18,2);
DEFINE dCred7012j    DECIMAL(18,2);

DEFINE dtFechaCorteAnt  DATE;

LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cMensajeRet    = "PROCESO EXITOSO";
LET iRegistros     = 0;
LET dCred2400i    = 0 ;
LET dCred2401i    = 0 ;
LET dCred2402i    = 0 ;
LET dCred2403i    = 0 ;
LET dCred2404i    = 0 ;
LET dCred2406i    = 0 ;
LET dCred2500i    = 0 ;
LET dCred2501i    = 0 ;
LET dCred2502i    = 0 ;
LET dCred2503i    = 0 ;
LET dCred2504i    = 0 ;
LET dCred2505i    = 0 ;
LET dCred1700i    = 0 ;
LET dCred1700j    = 0 ;
LET dCred1701i    = 0 ;
LET dCred1701j    = 0 ;
LET dtFechaCorteAnt    = DATE(1);

LET dCred1740i    = 0;
LET dCred1741i    = 0;
LET dCred1742i    = 0;
LET dCred1743i    = 0;
LET dCred1745i    = 0;
LET dCred1746i    = 0;
LET dCred1747i    = 0;
LET dCred1748i    = 0;

LET dCred7010i    = 0;
LET dCred7010j    = 0;
LET dCred7012i    = 0;
LET dCred7012j    = 0;
 
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_sispagos_x_3_jesus.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraIni
FROM sysmaster:"informix".sysshmvals;

select COUNT(*) 
INTO dCred1740i --(49)
    from bdicheq:sc_tarjeta a
   where a.empresa='001'
    and a.status_tar <> 'C'
	and substr(a.num_tarjeta,1,6) in (select bin from intercard:bines where creditodebito='D') 
     and a.fecha_insert <= MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin));

select COUNT(*) 
	INTO dCred1741i --  (50) 
    from bdicheq:sc_tarjeta 
   where empresa='001'
	and tipo_tarjeta='A'
    and status_tar <> 'C'
    and substr(num_tarjeta,1,6) in (select bin from intercard:bines where creditodebito='D') 
     and fecha_insert <= MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin)); 
   
LET dCred1742i = dCred1740i;

select COUNT(*) 
into dCred1743i --(52)
    from bdicheq:sc_tarjeta 
   where empresa='001'
    and ((num_tarjeta matches '521595*')
		or (num_tarjeta matches '559471*')) 
     and fecha_insert <= MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin)); 
	 
select count(*) 
INTO dCred1745i --(54)
from bdicred:sd_tarjeta a
inner join  bdicred:sd_maecredcont b on (a.empresa=b.empresa and a.num_credito=b.num_credito and b.status_cred = 'AA' and b.fecha = MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin)))
where a.empresa = '001' 
and a.status_tar = 'A'
and a.num_tarjeta matches '426807*';

SELECT count(*) 
into dCred1746i --(55)  
FROM bdicred:sd_tarjeta a
inner join bdicred:sd_maecredcont b on (a.empresa=b.empresa and a.num_credito=b.num_credito and b.fecha = MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin)))
where a.empresa='001'
and a.tipo_tarjeta='A'
and a.status_tar='A'
and a.num_tarjeta matches '426807*';
  
LET dCred1747i = dCred1745i;

select count(*)
into dCred1748i --(57) 
from bdicred:sd_tarjeta a
inner join bdicred:sd_maecredcont b on (a.empresa = b.empresa and a.num_credito=b.num_credito and b.status_cred = 'AA' and b.fecha = MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin)))
where a.empresa = '001' 
and a.status_tar = 'A'
and ((a.num_tarjeta matches '554948*')   or (a.num_tarjeta matches '510148*'));

select count(*)
	into dCred2400i --(66)
	from bdicred:sd_indicador_cred
	where empresa='001'
	and comportamiento=1
	and date(fechaultimocambio) >= MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin));
		
select count(*) 
into dCred2401i --(67)
from bdicred@pld_tcp:sd_encabezado2_edocta a
where a.fecha_emision = MDY(MONTH(pFechaFin),DAY(20),YEAR(pFechaFin))
and a.menos_abonos >= (select sdo_pagar 
                    from bdicred@pld_tcp:sd_encabezado2_edocta
                     where num_credito=a.num_credito
                        and fecha_emision = MDY(MONTH(pFechaFin)-1,DAY(20),YEAR(pFechaFin)))
and a.menos_abonos < a.saldo_corte;		

set isolation to dirty read;
select num_credito
from bdicred:sd_indicador_cred
where empresa='001'
and comportamiento=1
and date(fechaultimocambio) >= MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
into temp tem_totaleros with no log;
create index inx_tem_totaleros on tem_totaleros(num_credito);
update statistics medium for table tem_totaleros;

set isolation to dirty read;
select nvl(sum(a.menos_abonos),0)
into dCred2402i --(68)
from bdicred@pld_tcp:sd_encabezado2_edocta a
where a.fecha_emision = MDY(MONTH(pFechaFin),DAY(20),YEAR(pFechaFin))
and a.num_credito in (select num_credito from tem_totaleros);

set isolation to dirty reaD;
select nvl(sum(menos_abonos),0) 
into dCred2403i --(69)
from bdicred@pld_tcp:sd_encabezado2_edocta a
where a.fecha_emision = MDY(MONTH(pFechaFin),DAY(20),YEAR(pFechaFin))
and a.menos_abonos >= (select sdo_pagar 
                    from bdicred@pld_tcp:sd_encabezado2_edocta
                     where num_credito=a.num_credito
                        and fecha_emision = MDY(MONTH(pFechaFin)-1,DAY(20),YEAR(pFechaFin)))
and a.menos_abonos < a.saldo_corte;

select sum(monto_financiado - monto_vencido - mto_venc_trasp)
into dCred2404i --(70)
    from bdicred:sd_maesdoshist a
    where fecha = MDY(MONTH(pFechaFin),20,YEAR(pFechaFin))
    and empresa = '001'
    and sdo_cap_insoluto > 0;

select sum(monto_vencido + mto_venc_trasp)
into dCred2406i --(71)
    from bdicred:sd_maesdoscont a
    where fecha = MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
    and empresa = '001'
    and sdo_cap_insoluto > 0;

select sum(case when monto_otorgado <= 3000 then 1 else 0 end),
   sum(case when monto_otorgado > 3000 and monto_otorgado <= 5000 then 1 else 0 end),
   sum(case when monto_otorgado > 5000 and monto_otorgado <= 10000 then 1 else 0 end),
   sum(case when monto_otorgado > 10000 and monto_otorgado <= 20000 then 1 else 0 end),
   sum(case when monto_otorgado > 20000 and monto_otorgado <= 50000 then 1 else 0 end),
   sum(case when monto_otorgado > 50000 then 1 else 0 end)
into dCred2500i,dCred2501i,dCred2502i,dCred2503i,dCred2504i,dCred2505i --(73 a la 78)
from bdicred:sd_maecredcont a
 inner join bdicred:sd_maesdoscont b on (a.empresa = b.empresa and a.num_credito = b.num_credito and a.fecha=b.fecha)
 inner join bdicred:sd_tarjeta c on (a.empresa = c.empresa and a.num_credito = c.num_credito and c.status_tar='A')
where  a.empresa = '001'
and a.fecha = MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin));

 set isolation to dirty read;
select num_credito num_credito
    from bdicred:sd_movhis
   where empresa='001'
    and codigo_fun ='002'
	and codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64,65,37,57)
    and fecha_mov  
    between pFechaIni AND pFechaFin
     and reversado='N'
     --and ((nro_tarjeta matches '426807*') or (nro_tarjeta matches '554948*'))
into temp tarjetas_utilizadas with no log;

create index inx_tarjetas_utilizadas on tarjetas_utilizadas(num_credito);
update statistics medium for table tarjetas_utilizadas;

 set isolation to dirty read;
select a.num_credito numcredito, sum(a.sdo_cap_insoluto) saldo
    from bdicred:sd_maesdoscont a 
    join tarjetas_utilizadas b on (a.num_credito = b.num_credito) 
    where a.empresa='001' 
    and a.fecha = MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
    and a.sdo_cap_insoluto > 0
    group by a.num_credito 
into temp tarjetas_utilizadas1 with no log;
create index inx_tarjetas_utilizadas1 on tarjetas_utilizadas1(numcredito);
update statistics medium for table tarjetas_utilizadas1;

select count( distinct numcredito), SUM(saldo) 
INTO dCred1700i,dCred1700j --(79)
from tarjetas_utilizadas1;

select count(distinct nro_tarjeta), sum(monto)
into dCred7010i,dCred7010j --(258)
from bdicred:sd_movhis
where empresa = '001'
and fecha_mov BETWEEN pFechaIni AND pFechaFin
and reversado= 'N'
and codigo_fun = '002'
and codigo_ref = 30;

select count(*), sum(monto) 
into dCred7012i,dCred7012j --(260)
from bdicred:sd_movhis where empresa='001' 
and num_credito > 0 
and fecha_mov BETWEEN pFechaIni AND pFechaFin
and codigo_fun='002' 
and codigo_ref in (40,41,42) 
and reversado='N';
	
SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraFin 
FROM sysmaster:"informix".sysshmvals;


INSERT INTO bdicred:"informix".sd_reporte_sispagos_sec3   VALUES 
(pFechaIni,pFechaFin,dCred2400i,dCred2401i,dCred2402i,dCred2403i,dCred2404i,dCred2406i,dCred2500i,dCred2501i, 
 dCred2502i,dCred2503i,dCred2504i,dCred2505i,dCred1700i,dCred1700j,dCred1701i,dCred1701j,dCred1740i, 
 dCred1741i,dCred1742i,dCred1743i,dCred1745i,dCred1746i,dCred1747i,dCred1748i,dCred7010i, dCred7010j,
 dCred7012i,dCred7012j,dtHoraIni,dtHoraFin);

 
 --LET cMensajeRet = dtHoraIni || "  " || dtHoraFin;
RETURN cCodRet, cMensajeRet;
 
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la',
'obtención de la información para la',
'2da parte que conforma el reporte',
'de sispagos',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 25/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_syspagos4(pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(6)  AS codigo_retorno, 
          CHAR(80) AS mensaje_retorno;
		  
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6); 
DEFINE cMensajeRet   CHAR(80);
DEFINE iRegistros    INTEGER;
DEFINE dtHoraIni     DATETIME HOUR TO SECOND;
DEFINE dtHoraFin     DATETIME HOUR TO SECOND;

DEFINE dDeb7010i    DECIMAL(18,2);
DEFINE dDeb7010j    DECIMAL(18,2);
DEFINE dDeb7012i    DECIMAL(18,2);
DEFINE dDeb7012j    DECIMAL(18,2);
DEFINE dDeb7010_246i    DECIMAL(18,2);
DEFINE dDeb7010_246j    DECIMAL(18,2);
DEFINE dDeb7012_248i    DECIMAL(18,2);
DEFINE dDeb7012_248j    DECIMAL(18,2);
DEFINE dDeb7010_273i    DECIMAL(18,2);
DEFINE dDeb7010_273j    DECIMAL(18,2);
DEFINE dDeb7012_275i    DECIMAL(18,2);
DEFINE dDeb7012_275j    DECIMAL(18,2);
DEFINE dCheGir1401i    DECIMAL(18,2);
DEFINE dCheGir1401j    DECIMAL(18,2);
DEFINE dCheGir1403i    DECIMAL(18,2);


DEFINE dtFechaCorteAnt  DATE;


LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cMensajeRet    = "PROCESO EXITOSO";
LET iRegistros     = 0;

LET dDeb7010i    = 0;
LET dDeb7010j    = 0;
LET dDeb7012i    = 0;
LET dDeb7012j    = 0;
LET dDeb7010_246i    = 0;
LET dDeb7010_246j    = 0;
LET dDeb7012_248i    = 0;
LET dDeb7012_248j    = 0;
LET dDeb7010_273i    = 0;
LET dDeb7010_273j    = 0;
LET dDeb7012_275i    = 0;
LET dDeb7012_275j    = 0;
LET dCheGir1401i    = 0;
LET dCheGir1401j    = 0;
LET dCheGir1403i    = 0;


LET dtFechaCorteAnt    = DATE(1);


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/respaldos/pruebas/sispagos/sp_sispagos_x_4_jesus.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraIni
FROM sysmaster:"informix".sysshmvals;

select num_tarjeta tarjetas, sum(monto_tot) suma1 
from bdicheq:sc_movhis
where fech_alt between MDY(MONTH(pFechaIni),01,YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and transacc='0800' and cancelad<>'S'
and (num_tarjeta matches '416916*' 	or (num_tarjeta matches '559471*')) 
group by num_tarjeta
union all
select num_tarjeta tarjetas, sum(monto_tot) suma1 
from bdicheq:sc_movhis_old
where fech_alt between MDY(MONTH(pFechaIni),01,YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and transacc='0800' and cancelad<>'S'
and (num_tarjeta matches '416916*' 	or (num_tarjeta matches '559471*'))
group by num_tarjeta
into temp total_tarjetas_chip_caj with no log;

create index inx_total_tarjetas_chip_caj on total_tarjetas_chip_caj(tarjetas);
update statistics medium for table total_tarjetas_chip_caj;

set isolation to dirty read;
 select count(distinct tarjetas),sum(suma1)
 INTO dDeb7010i,dDeb7010j --(243)
 from total_tarjetas_chip_caj;



select num_tarjeta tarjetas, sum(monto_tot) suma1 from bdicheq:sc_movhis
where fech_alt between MDY(MONTH(pFechaIni),01,YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and transacc in ('0871','0872','0873')  and cancelad<>'S'
and (num_tarjeta matches '416916*'
	or (num_tarjeta matches '559471*'))
group by num_tarjeta
union all
select num_tarjeta tarjetas, sum(monto_tot) suma1 from bdicheq:sc_movhis_old
where fech_alt between MDY(MONTH(pFechaIni),01,YEAR(pFechaIni)) AND MDY(MONTH(pFechaFin),DAY(pFechaFin),YEAR(pFechaFin))
and transacc in ('0871','0872','0873')  and cancelad<>'S'
and (num_tarjeta matches '416916*'
	or (num_tarjeta matches '559471*'))
group by num_tarjeta
into temp total_tarjetas_chip with no log;

create index inx_total_tarjetas_chip on total_tarjetas_chip(tarjetas);
update statistics medium for table total_tarjetas_chip;

set isolation to dirty read;
 select count(distinct tarjetas),sum(suma1) 
 INTO dDeb7012i,dDeb7012j --(245)
 from total_tarjetas_chip;
 
 
select num_tarjeta tarjetas, sum(monto_tot) suma1 from bdicheq:sc_movhis
where fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and transacc='0800' and cancelad<>'S'
and num_tarjeta matches '400819*'
group by num_tarjeta
union all
select num_tarjeta tarjetas, sum(monto_tot) suma1 from bdicheq:sc_movhis_old
where fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) AND MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and transacc='0800' and cancelad<>'S'
and num_tarjeta matches '400819*'
group by num_tarjeta
into temp total_tarjetas_bm with no log;
create index inx_total_tarjetas_bm on total_tarjetas_bm(tarjetas);
update statistics medium for table total_tarjetas_bm;

set isolation to dirty read;
 select count(distinct tarjetas),sum(suma1)
 INTO dDeb7010_246i,dDeb7010_246j --(246)
 from total_tarjetas_bm;	

select num_tarjeta tarjetas, sum(monto_tot) suma1 from bdicheq:sc_movhis
where fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) AND MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and transacc in ('0871','0872','0873')  and cancelad<>'S'
and num_tarjeta matches '400819*'
group by num_tarjeta
union all
select num_tarjeta tarjetas, sum(monto_tot) suma1 from bdicheq:sc_movhis_old
where fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) AND MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and transacc in ('0871','0872','0873')  and cancelad<>'S'
and num_tarjeta matches '400819*'
group by num_tarjeta
into temp total_tarjetas_bmm with no log;

create index inx_total_tarjetas_bmm on total_tarjetas_bmm(tarjetas);
update statistics medium for table total_tarjetas_bmm;

set isolation to dirty read;
 select count(distinct tarjetas),sum(suma1)
  INTO dDeb7012_248i,dDeb7012_248j --(248)
  from total_tarjetas_bmm;

select num_tarjeta,monto_tot 
from bdicheq:sc_movhis
where empresa='001'
and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) AND MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and cancelad<>'S' AND producto in ('1300','1700')
and transacc='0800' 
union all
select num_tarjeta,monto_tot 
from bdicheq:sc_movhis_old
where empresa='001'
and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) AND MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and cancelad<>'S' AND producto in ('1300','1700')
and transacc='0800' 
into temp cas_pruebaeneromarzo12 with no log;

create index inx_cas_pruebaeneromarzo12 on cas_pruebaeneromarzo12(num_tarjeta);
update statistics medium for table cas_pruebaeneromarzo12;

set isolation to dirty read;
select count(distinct num_tarjeta),sum(monto_tot)
 INTO dDeb7010_273i,dDeb7010_273j --(273)
from cas_pruebaeneromarzo12;

 
--columna 275 (este es el bueno)
select num_tarjeta,monto_tot 
from bdicheq:sc_movhis
where empresa='001'
and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) AND MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and cancelad<>'S' AND producto in ('1300','1700')
and transacc in ('0817','0818','0819','0871','0872','0873') 
union all
select num_tarjeta,monto_tot 
from bdicheq:sc_movhis_old
where empresa='001'
and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) AND MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and cancelad<>'S' AND producto in ('1300','1700')
and transacc in ('0817','0818','0819','0871','0872','0873') 
into temp cas_eneromarzo with no log;

select count(distinct num_tarjeta),sum(monto_tot)
INTO dDeb7012_275i,dDeb7012_275j --(275)
from cas_eneromarzo;
 

select count(*),SUM(monto),sum(case when cancelado='D' then 1 else 0 end)
INTO dCheGir1401i,dCheGir1401j,dCheGir1403i --(554,556)
from bdicheq:sc_docret_sbc 
where siglas in ('SC','SD')
  and fecha_alta  BETWEEN mdy(month(pFechaIni),01,year(pFechaIni)) AND MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin));

SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraFin 
FROM sysmaster:"informix".sysshmvals;


INSERT INTO bdicred:"informix".sd_reporte_sispagos_sec4   VALUES 
(pFechaIni,pFechaFin,dDeb7010i ,	dDeb7010j ,	dDeb7012i ,	
dDeb7012j ,	dDeb7010_246i ,	dDeb7010_246j ,	dDeb7012_248i ,	dDeb7012_248j ,	dDeb7010_273i ,	dDeb7010_273j ,	dDeb7012_275i ,
dDeb7012_275j ,dCheGir1401i,dCheGir1401j,dCheGir1403i,dtHoraIni,dtHoraFin);

 
 
--LET cMensajeRet = dtHoraIni || "  " || dtHoraFin;
RETURN cCodRet, cMensajeRet;
 
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la',
'obtención de la información para la',
'2da parte que conforma el reporte',
'de sispagos',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 25/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_syspagos5(pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(6)  AS codigo_retorno, 
          CHAR(80) AS mensaje_retorno;
		  
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6); 
DEFINE cMensajeRet   CHAR(80);
DEFINE iRegistros    INTEGER;
DEFINE dtHoraIni     DATETIME HOUR TO SECOND;
DEFINE dtHoraFin     DATETIME HOUR TO SECOND;

LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cMensajeRet    = "PROCESO EXITOSO";
LET iRegistros     = 0;



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_sispagos_x_4_jesus.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraIni
FROM sysmaster:"informix".sysshmvals;

--columna 115 a 146

INSERT  INTO "informix".sd_reporte_sispagos_sec5 (fecha_ini_periodo,fecha_fin_periodo,Deb1701i,Estado)
SELECT pFechaIni , pFechaFin,  count(b.tpo_sucursal),a.estado 
FROM bdinteg:si_estados a 
left outer join bdinteg:si_sucursales b on (b.pais=a.pais and b.estado=a.estado and b.ciudad<>'000' and b.tpo_sucursal='C')
where a.estado>0 group by a.estado;


SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraFin 
FROM sysmaster:"informix".sysshmvals;

UPDATE "informix".sd_reporte_sispagos_sec5 
SET hora_ini = dtHoraIni ,hora_fin = dtHoraFin
WHERE fecha_ini_periodo = pFechaIni 
AND fecha_fin_periodo = pFechaFin;

			
RETURN cCodRet, cMensajeRet;
 
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la',
'obtención de la información para la',
'2da parte que conforma el reporte',
'de sispagos',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 25/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_syspagos6(pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(6)  AS codigo_retorno, 
          CHAR(80) AS mensaje_retorno;
		  
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6); 
DEFINE cMensajeRet   CHAR(80);
DEFINE vdeb2737i   	DECIMAL(18,2);
DEFINE vdeb2737j  	DECIMAL(18,2);
DEFINE vdeb2739i  	DECIMAL(18,2);
DEFINE vdeb2739j  	DECIMAL(18,2);
DEFINE vdeb2629i  	DECIMAL(18,2);
DEFINE vdeb2629j 	DECIMAL(18,2);
DEFINE vdeb2631i 	DECIMAL(18,2);
DEFINE vdeb2631j	DECIMAL(18,2);
DEFINE vdeb2632i	DECIMAL(18,2);
DEFINE vdeb2632j	DECIMAL(18,2);
DEFINE vdeb2633i	DECIMAL(18,2);
DEFINE vdeb2633j	DECIMAL(18,2);
DEFINE vdeb2636i	DECIMAL(18,2);
DEFINE vdeb2636j	DECIMAL(18,2);
DEFINE vdeb2637i	DECIMAL(18,2);
DEFINE vdeb2637j	DECIMAL(18,2);
DEFINE vdeb2638i	DECIMAL(18,2);
DEFINE vdeb2638j	DECIMAL(18,2);
DEFINE vdeb2639i	DECIMAL(18,2);
DEFINE vdeb2639j	DECIMAL(18,2);
DEFINE iRegistros    INTEGER;
DEFINE dtHoraIni     DATETIME HOUR TO SECOND;
DEFINE dtHoraFin     DATETIME HOUR TO SECOND;

LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cMensajeRet    = "PROCESO EXITOSO";
LET iRegistros     = 0;


LET vdeb2737i  = 0;
LET vdeb2737j  = 0;
LET vdeb2739i  = 0;
LET vdeb2739j  = 0;
LET vdeb2629i  = 0;
LET vdeb2629j  = 0;
LET vdeb2631i 	= 0;
LET vdeb2631j	= 0;
LET vdeb2632i	= 0;
LET vdeb2632j	= 0;
LET vdeb2633i	= 0;
LET vdeb2633j	= 0;
LET vdeb2636i	= 0;
LET vdeb2636j	= 0;
LET vdeb2637i	= 0;
LET vdeb2637j	= 0;
LET vdeb2638i	= 0;
LET vdeb2638j	= 0;
LET vdeb2639i	= 0;
LET vdeb2639j	= 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_sispagos_x_4_jesus.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraIni
FROM sysmaster:"informix".sysshmvals;

--CORRESPONSALES
select num_tarjeta trans, sum(monto_tot) suma
  from bdicheq:sc_movhis a
 where a.transacc= '0282'
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
group by 1
union all
select num_tarjeta trans, sum(monto_tot) suma
  from bdicheq:sc_movhis_old   a
 where a.transacc= '0282'
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
group by 1
into temp total_trans_corresponsales with no log;

create index inx_total_trans_corresponsales on total_trans_corresponsales(trans);
update statistics medium for table total_trans_corresponsales;

 select count(distinct trans),sum(suma) 
 into vdeb2737i,vdeb2737j 
 from total_trans_corresponsales;
 
 --PAGO CORRESPONSAL COPPEL
select a.num_credito trans, sum(a.monto) suma
from bdicred:sd_movhis a
where  a.empresa='001'
  and a.reversado = 'N'
  and a.transacc_suc= '6282'
  and a.fecha_mov between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
group by 1
into temp total_pago_corresponsales with no log;

create index inx_total_pago_corresponsales on total_pago_corresponsales(trans);
update statistics medium for table total_pago_corresponsales;

 select count(distinct trans),sum(suma) 
 into vdeb2739i,vdeb2739j
 from total_pago_corresponsales;
 
 select num_tarjeta trans, sum(monto_tot) suma
  from bdicheq:sc_movhis_old   a
 where a.transacc= '0223'
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
group by 1
union all
select num_tarjeta trans, sum(monto_tot) suma
  from bdicheq:sc_movhis   a
 where a.transacc= '0223'
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
group by 1
into temp total_retiros_debito with no log;
create index inx_total_retiros_debito on total_retiros_debito(trans);
update statistics medium for table total_retiros_debito;

set isolation to dirty read;
 select count(distinct trans),sum(suma) 
 into vdeb2629i,vdeb2629j
 from total_retiros_debito;
 --ORDENES DE PAGO
 select count(*) trans, sum(monto_tot) suma
  from bdicheq:sc_movhis_old   a
 where a.transacc IN ('1191','1192','1204','1234','1104','1105','1106','1134','1135','1136','1164','1165','1166')
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
UNION ALL
select count(*) trans, sum(monto_tot) suma
  from bdicheq:sc_movhis   a
 where a.transacc IN ('1191','1192','1204','1234','1104','1105','1106','1134','1135','1136','1164','1165','1166')
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
into temp total_ordenes_pago with no log;

set isolation to dirty read;
 select sum(trans),sum(suma) 
 into vdeb2631i,vdeb2631j
 from total_ordenes_pago;
--pago remesas
 select count(*) trans, sum(monto_tot) suma
  from bdicheq:sc_movhis_old   a
 where a.transacc in ('1110','1140','1170')
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
union all
select count(*) trans, sum(monto_tot) suma
  from bdicheq:sc_movhis   a
 where a.transacc in ('1110','1140','1170')
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
into temp total_remesas_BTS with no log;

set isolation to dirty read;
 select sum(trans),sum(suma) 
 into vdeb2632i,vdeb2632j
 from total_remesas_BTS;
 
 --cambio de cheques normativos
 select count(*) trans, sum(monto_tot) suma
  from bdicheq:sc_movhis_old   a
 where a.transacc in ('3333')
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
union all
select count(*) trans, sum(monto_tot) suma
  from bdicheq:sc_movhis   a
 where a.transacc in ('3333')
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
into temp total_cheques with no log;
set isolation to dirty read;
 select sum(trans),sum(suma) 
 into vdeb2633i,vdeb2633j
 from total_cheques;
 
  --2636	En cuenta a la vista
set isolation to dirty read;
select num_tarjeta trans, sum(monto_tot) suma
  from bdicheq:sc_movhis_old   a
 where a.transacc= '0202'
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
group by 1
union all
select num_tarjeta trans, sum(monto_tot) suma
  from bdicheq:sc_movhis   a
 where a.transacc= '0202'
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
group by 1
into temp total_deposito_debito with no log;
create index inx_total_deposito_debito on total_deposito_debito(trans);
update statistics medium for table total_deposito_debito;

 select count(distinct trans),sum(suma) 
 into vdeb2636i,vdeb2636j
 from total_deposito_debito;
 
  --2637	Pago de tarjetas de crédito
select count(distinct nro_tarjeta), sum(monto)
into vdeb2637i,vdeb2637j
from bdicred:sd_movhis
where empresa = '001'
and fecha_mov between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and reversado= 'N'
and codigo_fun = '033'
and codigo_ref = 1;

--2638	Pago de otros créditos (hipotecarios, automotriz)
select count(*), sum(monto)
into vdeb2638i,vdeb2638j
from bdicred:sd_movhiscrd
where empresa = '001'
and fecha_mov between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
and reversado= 'N'
and codigo_fun in ('225','027','028')
and codigo_ref = 1;

--2639	Pago de servicios (Luz, Agua, Teléfono, Gas, etc.)
select count(*) trans, sum(monto_tot) suma
  from bdicheq:sc_movhis_old   a
 where a.transacc in 
 ('1102','1132','1162','1303','1333','1363','1101','1131','1161',
 '1310','1340','1370','1107','1137','1167','1108','1138','1168',
 '1312','1342','1372','1104','1134','1164','1191','1192','1110',
 '1140','1170','1121','1151','1181','1122','1152','1182','1123',
 '1153','1183','1119','1149','1179','1115','1145','1175','1116',
 '1146','1176','1117','1147','1177','1124','1154','1184','1125',
 '1155','1185','1127','1157','1187','1128','1158','1188','1129',
 '1159','1189','1130','1160','1190')
 and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
union all
select count(*) trans, sum(monto_tot) suma
  from bdicheq:sc_movhis   a
 where a.transacc in 
 ('1102','1132','1162','1303','1333','1363','1101','1131','1161',
 '1310','1340','1370','1107','1137','1167','1108','1138','1168',
 '1312','1342','1372','1104','1134','1164','1191','1192','1110',
 '1140','1170','1121','1151','1181','1122','1152','1182','1123',
 '1153','1183','1119','1149','1179','1115','1145','1175','1116',
 '1146','1176','1117','1147','1177','1124','1154','1184','1125',
 '1155','1185','1127','1157','1187','1128','1158','1188','1129',
 '1159','1189','1130','1160','1190')
   and cancelad <> 'S' 
   and fech_alt between mdy(month(pFechaIni),01,year(pFechaIni)) and MDY(month(pFechaFin),day(pFechaFin),year(pFechaFin))
into temp total_pago_servicios with no log;

set isolation to dirty read;
 select sum(trans),sum(suma) 
 into vdeb2639i,vdeb2639j
 from total_pago_servicios;

--LET cMensajeRet = dtHoraIni || "  " || dtHoraFin;
SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraFin 
FROM sysmaster:"informix".sysshmvals;
 
INSERT INTO bdicred:"informix".sd_reporte_sispagos_sec6
    VALUES (pFechaIni, pFechaFin,vdeb2737i,vdeb2737j,vdeb2739i,vdeb2739j,
		vdeb2629i,vdeb2629j,vdeb2631i,vdeb2631j,
		vdeb2632i,vdeb2632j,vdeb2633i,vdeb2633j,vdeb2636i,vdeb2636j,vdeb2637i,
		vdeb2637j,vdeb2638i,vdeb2638j,vdeb2639i,vdeb2639j,dtHoraIni,dtHoraFin);
			
RETURN cCodRet, cMensajeRet;
 
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la',
'obtención de la información para la',
'2da parte que conforma el reporte',
'de sispagos',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 25/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultartarjetascred_iccat(pNumCliente CHAR(9))
--DATOS A REGRESAR---
RETURNING CHAR(5),CHAR(20),CHAR(20),CHAR(1),CHAR(4),CHAR(100),CHAR(1),DATE,CHAR(3), CHAR(60);
--DEFINICION DE VARIABLES--
DEFINE  cCodRet    	CHAR(5);
DEFINE  cCodRetCred    	CHAR(5);
DEFINE cNumCredito 	CHAR(20);
DEFINE cNumTarjeta 	CHAR(20);
DEFINE sEstatus    	CHAR(1);
DEFINE cFechaExp   	CHAR(4);
DEFINE cNomCompleto CHAR(100);
DEFINE cTitular    	CHAR(1);
DEFINE dFechaNacimiento DATE;
DEFINE cEstatusTarjeta CHAR(3);
DEFINE cDescripcion CHAR(60);
DEFINE  iSqlErr		INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 	= '00000';
LET cCodRetCred='00000';
LET cNumCredito='';
LET cNumTarjeta='';
LET sEstatus='';
LET cFechaExp='';
LET cNomCompleto='';
LET cTitular='';
LET dFechaNacimiento='01-01-1900';
LET cEstatusTarjeta='';
LET cDescripcion = '';
LET iSqlErr		= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cNumCredito,cNumTarjeta,sEstatus,cFechaExp,cNomCompleto,cTitular,dFechaNacimiento,cEstatusTarjeta, cDescripcion;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/tmp/sp_consultartarjetascred_iccat.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	EXECUTE PROCEDURE bdinteg:"informix".sp_obtenercredito_iccat(pNumCliente)
	INTO cCodRetCred,cNumCredito,cNumTarjeta;
	
	IF cCodRetCred='000' THEN
		--SE OBTIENE EL ESTATUS
		SELECT  indicador 
		INTO sEstatus
		FROM bdicred:"informix".sd_disminucion_linea_precan
		WHERE num_credito=cNumCredito;
		
		--SE OBTIENE FECHA EXPIRACION,TITULAR,NOMBRE Y FECHA NAC
		SELECT fechaexp,nombre,titular,fechanacimiento,codstatustarjeta 
		INTO cFechaExp,cNomCompleto,cTitular,dFechaNacimiento,cEstatusTarjeta
		FROM intercard:"informix".tarjeta 
		WHERE numtarjeta=cNumTarjeta;

		SELECT sdTipoC.descripcion
		INTO cDescripcion
		FROM BDICRED: "informix".sd_tipocartera sdTipoC, BDICRED: "informix".sd_maecred sdmaecred
		WHERE sdmaecred.num_credito  = cNumCredito
		AND sdmaecred.status_cred = sdTipoC.status_cred;
	
	ELSE
		LET cCodRet='00001';
	END IF;

	RETURN cCodRet,cNumCredito,cNumTarjeta,NVL(sEstatus,''),NVL(cFechaExp,''),NVL(cNomCompleto,''),NVL(cTitular,''),NVL(dFechaNacimiento,'01-01-1900'),NVL(cEstatusTarjeta,''), cDescripcion;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea sp para la obtencion de las tarjetas de credito del cliente prospecto a reactivacion',
'AUTOR : Jose Ruben Lopez',
'Folio:1591',
'Solicita:Jose de Jesus Nevarez',
'FECHA : 31/08/2015',
'BD: bdicred',
'DESCRIPCION: Se modifica SP para que retorne el valor del campo codstatustarjeta de la tabla intercard:"informix".tarjeta',
'AUTOR : José Magdiel Martínez López',
'Folio:1637',
'Solicita:Walber Castro',
'FECHA : 18/02/2016',
'BD: bdicred',
'DESCRIPCION: Se modifica SP para que retorne el estatus del número de crédito de la tarjeta del cliente',
'AUTOR : Leidy Lizeth Quevedo Peñuelas',
'Folio:71',
'Solicita:José de Jesús Nevarez',
'FECHA : 13/06/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_adn_disposicion (pEmpresa CHAR (3))	
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80);      -- Mensaje de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMensajeRet CHAR(80);

DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(150);
DEFINE cNombreArchivo1  CHAR(150);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(600);
DEFINE cRuta 			CHAR(80);
DEFINE iContador 		INTEGER;


DEFINE	dtFechaHoy	DATE;
DEFINE	dtFechaFinMes	DATE;
DEFINE	dTFechaSD	DATE;

DEFINE mMontoDisp	DECIMAL(18,2);
DEFINE mMontoDispAux	DECIMAL(18,2);
DEFINE cNumCte  	 CHAR(20);
DEFINE cNumCredito  	 CHAR(20);
DEFINE cFrecuenciaPago     CHAR(20);
DEFINE dLineaCred	DECIMAL(18,2);
DEFINE dMonto	DECIMAL(18,2);
DEFINE dtFechaMov    DATE;
DEFINE dtFechaMovCobro    DATE;
DEFINE cStatus     CHAR(2);
DEFINE cStatusDesc     CHAR(50);
DEFINE cStatusAp     CHAR(10);


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMensajeRet     = "Proceso Exitoso";

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";
LET iContador	= 0;


LET dtFechaFinMes   =DATE(1) ;
LET dtFechaHoy   =DATE(1) ;
LET dTFechaSD    =  DATE(1);
LET mMontoDisp = 0;
LET mMontoDispAux = 0;
LET cNumCte			= '';
LET cNumCredito  = '';
LET cFrecuenciaPago  = '';
LET dLineaCred  = 0;
LET dMonto  = 0;
LET dtFechaMov    =  DATE(1);
LET dtFechaMovCobro    =  DATE(1);
LET cStatus			= '';
LET cStatusDesc  = '';
LET cStatusAp	= "APROBADO";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN cCodRet,cErrorInfo ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/RQM10617/sp_adn_disposicion.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = ''  THEN
		RETURN  '00001','PARAMETROS DE ENTRADA INVALIDOS' ;
	ELSE
	
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 
	
	SELECT a.fecha_hoy
	INTO dtFechaHoy	
	FROM "informix".sd_fechas a
	WHERE a.empresa = pEmpresa;

	--LET dtFechaHoy = mdy(05,05,2016);
	--LET dtFechaHoy = mdy(06,05,2016);
	--LET dtFechaHoy = mdy(07,05,2016);
			 
	--GENERA EL NOMBRE DEL ARCHIVO
	LET cNombreArchivo = TRIM('Disposición_ADN_xcliente_Mes_')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('Disposición_ADN_xcliente_Mes_aux')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	
	LET dtFechaFinMes = mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)) - 1 units day;
	LET dTFechaSD = bdicred:MONTHADD(mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)), - 1);
	
--comision por disposicion
	SELECT monto
	INTO mMontoDisp 
	FROM  bdicred:"informix".sd_tpcomis 
	WHERE empresa = '001'  
	AND cod_comis = '8172';
			
		
			
	FOREACH WITH HOLD 	
		SELECT a.numcte,a.num_solicitud, DECODE(frecuencia_pgo,'1','MENSUAL','2','QUINCENAL','3','SEMANAL','MENSUAL'),
		a.linea ,c.monto,c.fecha_mov, b.status_cred
		INTO cNumCte,cNumCredito, cFrecuenciaPago,dLineaCred,dMonto,dtFechaMov,cStatus
		FROM bdisolic:"informix".ss_adn_solicitudcuenta a,	
		"informix".sd_maecred b,"informix".sd_movhis c
		WHERE a.empresa =b.empresa 
		and a.num_solicitud =b.num_credito
		AND a.empresa = c.empresa
		and a.num_solicitud =c.num_credito
		AND b.num_producto  = '7800'
		AND b.fecha_apertura <= dtFechaFinMes
		and c.transacc_suc ='8174' 
		AND c.codigo_fun = '002'
		and c.codigo_ref =111
		AND c.fecha_mov BETWEEN dTFechaSD AND dtFechaFinMes
		
		
		
		LET mMontoDispAux  =  dMonto * (mMontoDisp/100) ;
		
		SELECT first  1 fecha_mov 
			INTO dtFechaMovCobro
		FROM bdicred:sd_movhis 
		WHERE empresa =pEmpresa
		and num_credito = cNumCredito
		and transacc_suc ='8175'
		AND codigo_fun ='074'
		AND codigo_ref = 1
		AND fecha_mov >= dtFechaMov;

		IF NVL(dtFechaMovCobro,DATE(1)) = DATE(1) THEN
		
			SELECT descripcion
			INTO cStatusDesc
			FROM "informix".sd_tipocartera  
			WHERE status_cred = cStatus;
		ELSE
			LET  cStatusDesc = 'PAGADO';
		END IF;	
		
		LET cConsulta = TRIM(NVL(cNumCte,''))||'|'|| TRIM(NVL(cFrecuenciaPago,''))||'|'||  NVL(dLineaCred,0)||'|'|| NVL(dMonto,0)||'|'|| TRIM(NVL(cStatusAp,''))||'|'|| TRIM(NVL(dtFechaMov,''))||'|'|| NVL(mMontoDispAux,0)||'|'|| TRIM(NVL(dtFechaMovCobro,''))||'|'||NVL(cStatusDesc,'');

		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;		
		
	LET iContador	=  1; 
    END FOREACH;

		IF iContador  > 0 THEN 	

		---se ejecuta para ponerle el encabezado 
			LET cEncabezado = 'echo "Número de Cliente BanCoppel'||'|'||'Periodo de pago'||'|'||'Línea de Crédito'||'|'||'Anticipo solicitado en el periodo'||'|'||'Estatus'||'|'||'Fecha de disposición'||'|'||'Comisión Disposición'||'|'||'Fecha de cargo a cuenta de nómina'||'|'||'Estatus'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
			SYSTEM cEncabezado;

			LET cSql = cSql;
			LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
			SYSTEM cSql;


			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
			SYSTEM cSQL;   	

			RETURN cCodRet,cMensajeRet;

		ELSE
			LET cCodRet			= '00000';
			LET cMensajeRet			= 'No se encontro información';
			RETURN cCodRet,cMensajeRet;
		END IF;			
	END IF;		
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para validacion de los resultados del Anticipo de Nómina de forma general',
'AUTOR :  Jesus Manuel Aguilar',
'FECHA : 24/abril/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_adn_sms (pEmpresa CHAR (3))	
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80);      -- Mensaje de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMensajeRet CHAR(80);


DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(150);
DEFINE cNombreArchivo1  CHAR(150);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(600);
DEFINE cRuta 			CHAR(80);
DEFINE iContador 		INTEGER;

DEFINE	dtFechaHoy	DATE;
DEFINE	dtFechaFinMes	DATE;
DEFINE	dTFechaSD	DATE;
DEFINE	cGrupo	CHAR(20);
DEFINE	cPlant	CHAR(20);
DEFINE	cPlantSub	CHAR(1);
DEFINE	cDescripcion	CHAR(80);
DEFINE	dTotal	INTEGER;
DEFINE	dTotal1	INTEGER;
DEFINE	dTotal2	INTEGER;


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMensajeRet     = "Proceso Exitoso";

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";
LET iContador	= 0;

LET	dtFechaHoy	= DATE(1);
LET	dtFechaFinMes	= DATE(1);
LET	dTFechaSD	 =DATE(1);
LET cGrupo    = "";
LET cPlant    =  "";
LET cPlantSub    =  "";
LET cDescripcion    =  "";
LET dTotal    = 0;
LET dTotal1    = 0;
LET dTotal2    = 0;



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN cCodRet,iIsamErr ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/RQM10617/sp_adn_sms.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = ''  THEN
		RETURN  '00001','PARAMETROS DE ENTRADA INVALIDOS' ;
	ELSE
	
	
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 
	
	SELECT a.fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sd_fechas a
	WHERE a.empresa = pEmpresa;
			 
	--LET dtFechaHoy = mdy(05,05,2016);
	--LET dtFechaHoy = mdy(06,05,2016);
	--LET dtFechaHoy = mdy(07,05,2016); 
	
	--GENERA EL NOMBRE DEL ARCHIVO
	LET cNombreArchivo = TRIM('Sol_SMS_ADN_Mes_')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('Sol_SMS_ADN_Mes_aux_')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	
	LET dtFechaFinMes = mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)) - 1 units day;
	LET dTFechaSD = bdicred:MONTHADD(mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)), - 1);
	
	
	FOREACH WITH HOLD 
		SELECT grupo ,plantillasub ,descripcion  
		INTO cGrupo,cPlantSub, cDescripcion
		FROM "informix".sd_adn_plantillas 
		where plantilla = ''
		
		
		FOREACH WITH HOLD
			SELECT grupo ,plantilla ,descripcion
			INTO cGrupo,cPlant, cDescripcion
			FROM "informix".sd_adn_plantillas 
			where plantillasub = cPlantSub
						
			IF TRIM(cPlant) = ""  AND  TRIM(cPlantSub) <> "2" THEN
				CONTINUE FOREACH;
			END IF
			
				SELECT COUNT(id_plantilla)
				INTO dTotal1 
				FROM bdimnsj:mnsjr_trx_online 
				WHERE tipo_mensaje =1 
				AND id_mensaje ='ADN_SMS' 				
				AND fecha_hora_registro BETWEEN dTFechaSD AND dtFechaFinMes
				AND id_plantilla = cPlant;

				SELECT COUNT(id_plantilla)
				INTO dTotal2 
				FROM bdimnsj:mnsjr_trx_online_his
				WHERE tipo_mensaje =1 
				AND id_mensaje ='ADN_SMS' 				
				AND fecha_hora_registro BETWEEN dTFechaSD AND dtFechaFinMes
				AND id_plantilla = cPlant;

				LET dTotal= dTotal1 +dTotal2;
				
				LET cConsulta = NVL(cGrupo,'')||'|'|| NVL(cDescripcion,'')||'|'||NVL(dTotal,0);

				---se ejecuta para ponerle el encabezado 
				LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
				SYSTEM cEncabezado;	
		
		END FOREACH;
	
		
	LET iContador	=  1; 
    END FOREACH;

		IF iContador  > 0 THEN 	

			---se ejecuta para ponerle el encabezado 
			LET cEncabezado = 'echo "SOLICITUDES SMS DE ANTICIPO DE NOMINA'||'|'||' '||'|'||'TOTAL'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
			SYSTEM cEncabezado;

			LET cSql = cSql;
			LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
			SYSTEM cSql;


			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
			SYSTEM cSQL;   	

			RETURN cCodRet,cMensajeRet;

		ELSE
			LET cCodRet			= '00000';
			LET cMensajeRet			= 'No se encontro información';
			RETURN cCodRet,cMensajeRet;
		END IF;			
	END IF;		
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para validacion de los resultados del Anticipo de Nómina de forma general',
'AUTOR :  Jesus Manuel Aguilar',
'FECHA : 24/abril/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_validarpermisousuariocac2(p_Ejecutivo CHAR(8))
RETURNING
        CHAR(5); ---cod_ret
        ---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE cEmpleado CHAR (20);
        ---INICIALIZACIONES
        LET v_cod_ret = '00000';
		LET cEmpleado = '';
	BEGIN
		ON EXCEPTION
		SET iSqlErr, iSamErr
		IF iSqlErr <> 0 THEN
			LET v_cod_ret = iSqlErr;
		END IF;
				
		RETURN v_cod_ret;
		END EXCEPTION;
        
        ---SET DEBUG FILE TO "/tmp/has/sp_validarpermisousuariocac2.out";
        ---TRACE ON;
        IF p_Ejecutivo = "" OR p_Ejecutivo IS NULL THEN
                LET v_cod_ret = "00001";
                RETURN v_cod_ret;
        END IF
        
        IF NOT EXISTS(SELECT ejecutivo FROM bdinteg: si_perfil_ejecut WHERE ejecutivo = p_Ejecutivo AND sistema = "06")  THEN
                LET v_cod_ret = "00002";
                RETURN v_cod_ret;
        END IF
        
        IF NOT EXISTS(SELECT empleado FROM bdicred: sd_super_cancred WHERE empleado = p_Ejecutivo AND status = 1 AND aplicativo = "CCONCAC.EXE") THEN
			LET v_cod_ret = "00003";
            RETURN v_cod_ret;     			
        END IF
		
        RETURN v_cod_ret;
END;
END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para validar los permisos de usuarios',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan',
'DESCRIPCION:Se agrega otro tipo de aplicativo para validar los permisos del usuario a la afuncionalidad de credito grupo coppel',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 03/05/2016';

CREATE PROCEDURE "informix".sp_cobrocomisionreposicioncredito ( pEmpresa CHAR(3))	
RETURNING CHAR(5);       -- Codigo de Retorno
		  

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cErrorsp   CHAR(1);
DEFINE cCodRet      CHAR(6);
DEFINE cCodRetAux   CHAR(6);
DEFINE cMen_ret CHAR(80);
DEFINE p_cod_ret CHAR(6);
DEFINE pcod_ret CHAR(5);
DEFINE cResultado		CHAR(1);
DEFINE cMensaje		CHAR(250);

DEFINE iSecuencia INTEGER;
DEFINE cNumcred CHAR(20);
DEFINE cMotivo CHAR(2);
DEFINE cNumtarjeta CHAR(20);
DEFINE cNumeroFolio CHAR(16);
DEFINE cEmpresa CHAR(3);
DEFINE cSucursal CHAR(4);
DEFINE cTransacc CHAR(4);
DEFINE cOperador CHAR(10);
DEFINE cMontoCom MONEY(16,2);
DEFINE cIvaCom MONEY(16,2);
DEFINE dtFechaSol DATE;
DEFINE dtfecha_ini DATE;
DEFINE dtfecha_fin DATE;


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cErrorsp      = "";
LET cCodRet         = "00000";
LET cCodRetAux         = "000000";
LET p_cod_ret     = "00000";
LET pcod_ret     = "00000";
LET cMen_ret     = "Proceso Exitoso";

LET iSecuencia = 0;
LET cNumcred = "";
LET cMotivo = "";
LET cNumeroFolio = "";
LET cEmpresa = "";
LET cTransacc = "";
LET cSucursal = "9290";
LET cOperador = "informix";
LET dtFechaSol = DATE(1);
LET dtfecha_ini = mdy(06,01,2016);
LET dtfecha_fin = mdy(07,19,2016);
LET cMontoCom =0.00;
LET cIvaCom =0.00;
LET cResultado		= '';
LET cMensaje		= '';



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/Malena/sp_cobrocomisionreposicioncredito.out';
	--TRACE ON;
		
		--Pendientes de cobrar comision de tarjetas de credito por motivo robo,extravio y Maltrato (1,2,3)					  

			SELECT empresa,num_credito,num_tarjeta,motivo
			FROM bdicred:"informix".sd_cobro_comision
			WHERE resultado ='0'
			INTO temp paso_sol2 WITH NO LOG;
			
			update statistics high for table paso_sol2;
	
	FOREACH WITH HOLD
				--Se obtiene la información de los Creditos que Repusieron tarjeta
				SELECT empresa,num_credito,num_tarjeta,motivo
				INTO cEmpresa,cNumcred, cNumtarjeta, cMotivo
				FROM "informix".paso_sol2

				 --SE GENERA EL FOLIO
				 CALL bdicheq:"informix".sp_generafolionomina('informix') 
				 RETURNING cCodRetAux, cNumeroFolio;
				 
				 --6218	COM POR ROBO 15%       				 
				 --6219	COM POR EXTRAVIO 15%            				 
				 --6220	COM POR DAÑO o MALTRATO 15%             
				 
				 IF cMotivo='01' THEN
					LET cTransacc ='6218';
				 ELIF cMotivo ='02' THEN
					LET cTransacc ='6219';
				 ELIF cMotivo ='03' THEN
					LET cTransacc ='6220';
				 END IF;
				 
				EXECUTE PROCEDURE bdinteg:"informix".sp_ComisionReposicion (cEmpresa,cSucursal,'2',cNumcred,cTransacc)				 
				INTO p_cod_ret,cMontoCom,cIvaCom;
				
				IF p_cod_ret::INTEGER = 0 THEN
				 --Si es credito se ejecuta el siguiente procedimiento 
				 EXECUTE Procedure "informix".cargo_cred (cEmpresa,cNumcred,cSucursal,cOperador,cTransacc,cMontoCom ,cNumeroFolio,
				 cNumtarjeta,0,0,TODAY,'Comision por reposicion de tarjeta','Cargo por Cobro No aplicado','')	
				 INTO pcod_ret;

					IF pcod_ret::INTEGER = 0 THEN
						--Se actualiza el resultado del cargo de la comision
						UPDATE bdicred:"informix".sd_tarjeta 
						SET cobro_comision  ='S'
						WHERE num_tarjeta =cNumtarjeta;
						--Se actualiza el resultado del cargo de la comision
						UPDATE bdicred:"informix".sd_cobro_comision 
						SET resultado ='1',mensaje = 'Comision Aplicada con exito'
						WHERE num_tarjeta =cNumtarjeta;					
					ELSE 
						--Se actualiza el resultado del cargo de la comision
						UPDATE bdicred:"informix".sd_cobro_comision 
						SET resultado ='0',mensaje = pcod_ret || ' - Ocurrio un Error al intentar aplicar la comision'
						WHERE num_tarjeta =cNumtarjeta;
						LET cCodRet = '00001';
					END IF;				
				ELIF p_cod_ret::INTEGER = 1 THEN										
					-- "La Cuenta del Cliente tiene un Estatus de Crédito Vencido"
					UPDATE bdicred:"informix".sd_cobro_comision 
					SET resultado ='0',mensaje = p_cod_ret || ' - La Cuenta del Cliente tiene un Estatus de Crédito Vencido'
					WHERE num_tarjeta =cNumtarjeta;					
					LET cCodRet = '00002';				
				ELIF p_cod_ret::INTEGER = 2 THEN
					--"La Cuenta del Cliente Ésta Bloqueada Para la Disposición de Saldo"
					UPDATE bdicred:"informix".sd_cobro_comision 
					SET resultado ='0',mensaje = p_cod_ret || ' - La Cuenta del Cliente Ésta Bloqueada Para la Disposición de Saldo'
					WHERE num_tarjeta =cNumtarjeta;										
					LET cCodRet = '00003';				
				ELSE 
					--"Ocurrio un Error al intentar aplicar la comision"				
					UPDATE bdicred:"informix".sd_cobro_comision 
					SET resultado ='0',mensaje = p_cod_ret || ' - Ocurrio un Error al intentar aplicar la comision'
					WHERE num_tarjeta =cNumtarjeta;					
					LET cCodRet = '00004';	
				END IF;				 
    		
	END FOREACH;		
					
		RETURN cCodRet ;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para aplicar cobros de comisiones que no se aplicarón por Reposición de Tarjeta en el periodo de Junio y Julio ',
'AUTOR :  Maria Elena Angulo Aispuro',
'FECHA : 20/julio/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_depura_cred_his()
RETURNING 
CHAR(6),     -- código de retorno
CHAR(150);    -- mensaje


DEFINE cCodRet      CHAR(6); 
DEFINE cMensaje     CHAR(150); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE Error_Info   VARCHAR(80);
DEFINE dFechaDepura DATE;
--Pruebas IPCB
DEFINE vFecha DATE;
DEFINE dFechaAProcesar DATE;
DEFINE vnum_credito CHAR(20);
DEFINE vfecha_corte DATE;
DEFINE cFechaDepura char(10);
DEFINE iDepura		integer;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sHoraFinal		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;


DEFINE sHorasProceso	SMALLINT;
DEFINE cTerminaProceso	CHAR(1);
DEFINE iCuentasProcesadas			INTEGER;
DEFINE iCount_sd_maesdoshist_old	INTEGER;
DEFINE iCount_sd_maecredcont_old	INTEGER;
DEFINE iCount_sd_maesdoscont_old	INTEGER;
DEFINE iCount_sd_hist_reserva_old	INTEGER;
DEFINE iCount_sd_movhis_calif_old	INTEGER;
DEFINE cProceso		CHAR(04);
DEFINE P_COD_RET    VARCHAR(6);
DEFINE P_MENSAJE    VARCHAR(150);

LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
LET dFechaDepura = DATE(1);
--Pruebas IPCB
LET vFecha 			= date(1);
LET dFechaAProcesar = date(1);
LET vnum_credito	= '';
LET vfecha_corte	= DATE(1);
LET cFechaDepura	= '';
LET iDepura			= 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sHoraInicial	= 0;
LET sHoraFinal		= 0;
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;

LET sHorasProceso	= 0;
LET cTerminaProceso = '0';
LET iCuentasProcesadas			= 0;
LET iCount_sd_maesdoshist_old	= 0;
LET iCount_sd_maecredcont_old	= 0;
LET iCount_sd_maesdoscont_old	= 0;
LET iCount_sd_hist_reserva_old	= 0;
LET iCount_sd_movhis_calif_old	= 0;
LET cProceso		= '0001';
LET P_COD_RET   	= '000000';
LET P_MENSAJE		= 'El proceso MUEVE A TABLAS HISTORICAS terminó exitosamente. Cuentas procesadas ';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
			LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoshist_old : ' ||iCount_sd_maesdoshist_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			LET cMensaje = 'Cuentas respaldadas sd_maecredcont_old : ' ||iCount_sd_maecredcont_old;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			LET cMensaje = 'Cuentas respaldadas sd_hist_reserva_old : ' ||iCount_sd_hist_reserva_old;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_movhis_calif_old : ' ||iCount_sd_movhis_calif_old;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

		LET cCodRet = iSqlErr;		
            LET cMensaje = 'Error --> '||Error_Info||'	'||vNumCred;

			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;

            RETURN cCodRet,cMensaje;
        END IF;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
--SET DEBUG FILE TO 'sp_depura_cred_his.out';
--TRACE ON;

    select fecha_hoy into vFecha
    from bdicred:sd_fechas;

--temporal solo para pruebas
--LET vFecha = today; --mdy ('11','10','2013');
--temporal solo para pruebas

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);
	
    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     WHERE proceso = 3;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(3,'');
    END IF;

--Pruebas IPCB

    SELECT valor::date
      INTO dFechaDepura
      FROM bdicred:sd_param
     WHERE cod_param = '048';

    IF dFechaDepura IS NULL THEN 
        LET cCodRet = '100100';
        LET P_MENSAJE = 'No existe parámetro de fecha a depurar.';
        RETURN cCodRet,P_MENSAJE;
    END IF;

	SELECT valor::smallint
      INTO sHorasProceso
      FROM bdicred:sd_param
     WHERE cod_param = '053';

	 IF sHorasProceso IS NULL THEN 
        LET cCodRet = '100200';
        LET P_MENSAJE = 'No existe parámetro de horas a procesar.';
        RETURN cCodRet,P_MENSAJE;
    END IF;
	 
    if vNumCredAux = '' then
        execute PROCEDURE bdicred:monthadd(vFecha, -18) into dFechaDepura;

        let dFechaDepura = mdy(month(dFechaDepura),1,year(dFechaDepura)) - 1;

        UPDATE bdicred:sd_param
           SET valor = dFechaDepura
         WHERE cod_param = '048';

    end if;

    FOREACH WITH HOLD

       SELECT TRIM(num_credito)
           INTO vNumCred 
           FROM bdicred:"informix".sd_maecred
          WHERE empresa     = '001' 
            AND num_credito > vNumCredAux
       ORDER BY num_credito ASC

	   LET iCuentasProcesadas = iCuentasProcesadas + 1;
	   
        BEGIN WORK;
--maesdoshist
            insert into bdicred:sd_maesdoshist_old
            select * from bdicred:sd_maesdoshist
            where empresa = '001'
            and fecha    <= mdy(month(dFechaDepura),20,year(dFechaDepura))
            and num_credito = vNumCred;

            delete from bdicred:sd_maesdoshist
            where empresa = '001'
            and fecha    <= mdy(month(dFechaDepura),20,year(dFechaDepura))
            and num_credito = vNumCred;

			LET iCount_sd_maesdoshist_old	= iCount_sd_maesdoshist_old + 1;
			
--maecredcont
            insert into bdicred:sd_maecredcont_old
            select * from bdicred:sd_maecredcont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;

            delete from bdicred:sd_maecredcont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;
--            and num_credito <= vNumCred;
			
			LET iCount_sd_maecredcont_old	= iCount_sd_maecredcont_old + 1;
			
--maesdoscont
            insert into bdicred:sd_maesdoscont_old
            select * from bdicred:sd_maesdoscont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;

            delete from bdicred:sd_maesdoscont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;

			LET iCount_sd_maesdoscont_old	= iCount_sd_maesdoscont_old + 1;

--hist_reserva
--Pruebas IPCB

         insert into bdicred:sd_hist_reserva_old
            select *  
              from bdicred:sd_hist_reserva
             where empresa = '001'
               and fecha_corte <= dFechaDepura
               and fecha_corte not in (mdy('05','20','2011'),mdy('06','20','2011'),mdy('07','20','2011'),mdy('08','20','2011'),mdy('09','20','2011'),mdy('03','20','2012'),mdy('03','31','2012'),mdy('04','20','2012'),mdy('04','30','2012'),mdy('05','20','2012'),mdy('05','31','2012'),mdy('06','20','2012'),mdy('07','20','2012'),mdy('08','20','2012'))
               and num_credito = vNumCred;

             delete from bdicred:sd_hist_reserva
              where empresa = '001'
                and fecha_corte <= dFechaDepura
                and num_credito = vNumCred;

		LET iCount_sd_hist_reserva_old	= iCount_sd_hist_reserva_old + 1;
				
--sd_movhis_calif
            insert into bdicred:sd_movhis_calif_old
--            select {+INDEX(sd_movhis_calif inx_movhis_calif_1)} * from bdicred:sd_movhis_calif
            select * from bdicred:sd_movhis_calif
            where empresa = '001'
             and fecha_mov = dFechaDepura
/*            and fecha_mov in (
                mdy('06','30','2012'),
                mdy('07','31','2012'),
                mdy('08','31','2012'),
                mdy('09','30','2012'),
                mdy('10','31','2012'),
                mdy('11','30','2012'),
                mdy('12','31','2012'))*/
            and num_credito = vNumCred;

            delete from bdicred:sd_movhis_calif
            where empresa = '001'
            and fecha_mov = dFechaDepura
/*            and fecha_mov in (
                mdy('06','30','2012'),
                mdy('07','31','2012'),
                mdy('08','31','2012'),
                mdy('09','30','2012'),
                mdy('10','31','2012'),
                mdy('11','30','2012'),
                mdy('12','31','2012'))*/
            and num_credito = vNumCred;

			LET iCount_sd_movhis_calif_old	= iCount_sd_movhis_calif_old + 1;
			
            UPDATE "informix".sd_param_movhis_dep
               SET num_credito = vNumCred
             WHERE proceso = 3;
        COMMIT WORK;  
        let iDepura = 0;

		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
			LET cTerminaProceso = '1';
			EXIT FOREACH;
		END IF;
	END FOREACH;

	IF cTerminaProceso = '0' THEN
		UPDATE "informix".sd_param_movhis_dep
		SET num_credito = ''
		WHERE proceso = 3;
	END IF;

	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoshist_old : ' ||iCount_sd_maesdoshist_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = 'Cuentas respaldadas sd_maecredcont_old : ' ||iCount_sd_maecredcont_old;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = 'Cuentas respaldadas sd_hist_reserva_old : ' ||iCount_sd_hist_reserva_old;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_movhis_calif_old : ' ||iCount_sd_movhis_calif_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	
    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;

	LET P_MENSAJE = P_MENSAJE || ' ' || iCuentasProcesadas;
	
    RETURN cCodRet,P_MENSAJE;

    END
END PROCEDURE;