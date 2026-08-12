CREATE PROCEDURE "informix".sp_reporte_banco_mexico_pba(pFecha DATE, pEmpresa char(3),pperiodos SMALLINT)
RETURNING CHAR(6)

    DEFINE GLOBAL cCodRet          CHAR(6)        DEFAULT '000000';
    DEFINE GLOBAL iSqlErr          INTEGER        DEFAULT 0;
    DEFINE GLOBAL iDias                                                 INTEGER        DEFAULT 0;
    DEFINE GLOBAL iMes                                                  INTEGER        DEFAULT 0;
    DEFINE GLOBAL iAnio                                                  INTEGER        DEFAULT 0;
    DEFINE GLOBAL dFechaIni                                             DATE           DEFAULT '';
    DEFINE GLOBAL dFechaFin                                             DATE           DEFAULT '';
    DEFINE cDiasIni                                                 char(02);
    DEFINE cMesIni                                                  char(02);
    DEFINE cAnioIni                                                 char(04);
    DEFINE cFechaIni                                             char(19);
    DEFINE cDiasFin                                                 char(02);
    DEFINE cMesFin                                                  char(02);
    DEFINE cAnioFin                                                 char(04);
    DEFINE cFechaFin                                             char(19);
    DEFINE deb1009,deb1010_f ,deb1010_m,deb1011_f                       INTEGER;
    DEFINE deb1011_m,deb1013_f,deb1013_m,deb1022_f                      INTEGER;
    DEFINE deb1022_m,deb1023_f,deb1023_m,deb1025_f                      INTEGER;
    DEFINE deb1025_m,nom1009_f,nom1010_f,nom1011_f                      INTEGER;
    DEFINE nom1013_f,nom1022_f,nom1023_f,nom1025_f                      INTEGER;
    DEFINE deb1009_m,deb1010_fm,deb1010_mm,deb1011_fm                   DECIMAL(18,2);
    DEFINE deb1011_mm,deb1013_fm,deb1013_mm,deb1022_fm                  DECIMAL(18,2);
    DEFINE deb1022_mm,deb1023_fm,deb1023_mm,deb1025_fm                  DECIMAL(18,2);
    DEFINE deb1025_mm,nom1009_fm,nom1010_fm,nom1011_fm                  DECIMAL(18,2);
    DEFINE nom1013_fm,nom1022_fm,nom1023_fm,nom1025_fm                  DECIMAL(18,2);
    DEFINE cred2400,cred2401                                            INTEGER;
    DEFINE cred2402,cred2403,cred2404,cred2406,cred2500                 DECIMAL(18,2);
    DEFINE cred2501,cred2502,cred2503,cred2504,cred2505                 DECIMAL(18,2);
    DEFINE ult_corte,prox_corte                                         DATE;       
    DEFINE caj2100,caj2101,caj2102,caj2103,caj2104,caj2105              INTEGER;
    DEFINE caj2106,caj2107,caj2108,caj2109,caj2110,caj2111              INTEGER;
    DEFINE caj2112,caj2113,caj2114,caj2115,caj2116,caj2117              INTEGER;
    DEFINE caj2118,caj2119,caj2120,caj2121,caj2122,caj2123              INTEGER;
    DEFINE caj2124,caj2125,caj2126,caj2127,caj2128,caj2129              INTEGER;
    DEFINE caj2130,caj2131                                              INTEGER;
    DEFINE deb1740,deb1741,deb1742,cred1745,cred1746,cred1747           INTEGER;
    DEFINE cant_sucur                                                   INTEGER;
    DEFINE num_estado                                                   CHAR(2);
    DEFINE cred1727,cred1728,cred1733,cred1726_bm,cred1728_bm           INTEGER;
    DEFINE deb1722,deb1724,deb1732,deb1722_bm,deb1724_bm                INTEGER;
    DEFINE deb7010,deb7012,deb7013,deb7015,deb1709                      INTEGER;
    DEFINE deb7010_m,deb7012_m,deb1709_m                                DECIMAL(18,2);
    DEFINE cred7010,cred7012,cred7013,cred7015,cred1709                 INTEGER;
    DEFINE cred7010_m,cred7012_m,cred1709_m                             DECIMAL(18,2);
    DEFINE nom7010,nom7012,nom7013,nom7015                              INTEGER;
    DEFINE nom7010_m,nom7012_m                                          DECIMAL(18,2);
    DEFINE vproceso                                                     SMALLINT;    
    DEFINE cred1707                                                     INTEGER;
    DEFINE a_deb7010,a_deb7012,a_deb7013,a_deb7015,a_deb1709            INTEGER;                 
    DEFINE a_deb7010_m,a_deb7012_m,a_deb1709_m                          DECIMAL(18,2);
    DEFINE a_numtarjeta                                                 VARCHAR(16);
    DEFINE a_cred7010,a_cred7012,a_cred7013,a_cred7015,
           a_cred1709,a_cred1707                                        INTEGER;
    DEFINE a_cred7010_m,a_cred7012_m,a_cred1709_m                       DECIMAL(18,2);
    DEFINE a_nom7010,a_nom7012,a_nom7013,a_nom7015                      INTEGER;
    DEFINE a_nom7010_m,a_nom7012_m                                      DECIMAL(18,2);
    DEFINE deb1701,cred1700,cuentas_aux                                 INTEGER;
    DEFINE bin_tarjeta                                                  CHAR(6);
    DEFINE deb_cant_reposicion,deb_monto_reposicion                     DECIMAL(18,2);
    DEFINE cobro_interes,cobro_reposicion,cantidad_reposicion           DECIMAL(18,2);
    DEFINE retiro_cpcp,retiro_cpca,transfer_otrobanco_fisica            DECIMAL(18,2);   
    DEFINE deb7011bm,deb7014,cred7011bm,cred7014                        INTEGER;
    DEFINE deb7011bm_m,deb7014_m,cred7011bm_m,cred7014_m                DECIMAL(18,2);

    let cDiasIni                                                 = '';
    let cMesIni                                                  = '';
    let cAnioIni                                                 = '';
    let cFechaIni                                             = '';
    let cDiasFin                                                 = '';
    let cMesFin                                                  = '';
    let cAnioFin                                                 = '';
    let cFechaFin                                             = '';

    BEGIN

        ON EXCEPTION SET iSqlErr
           IF iSqlErr != 0 THEN
              LET cCodRet=iSqlErr;
              RETURN cCodRet;
           END IF;
        END EXCEPTION;

--       SET DEBUG FILE TO "sp_reporte_banco_mexico.out";
--       TRACE ON;

    LET vproceso=0;
    LET iDias = DAY(pFecha);
    LET iMes  = MONTH(pFecha);
    LET iAnio = YEAR(pFecha);
    LET dFechaIni = MDY(iMes, 1, iAnio)- pperiodos UNITS MONTH;
    LET dFechaFin = MDY(iMes, 1, iAnio)- 1;

    LET cDiasIni = lpad(DAY(dFechaIni),2,'0');
    LET cMesIni  = lpad(MONTH(dFechaIni),2,'0');
    LET cAnioIni = lpad(YEAR(dFechaIni),4,'0');
    LET cFechaIni = cAnioIni || '-' || cMesIni || '-' || cDiasIni || ' 12:00:00';

    LET cDiasFin = lpad(DAY(dFechaFin),2,'0');
    LET cMesFin  = lpad(MONTH(dFechaFin),2,'0');
    LET cAnioFin = lpad(YEAR(dFechaFin),4,'0');
    LET cFechaFin = cAnioFin || '-' || cMesFin || '-' || cDiasFin || ' 23:59:59';

    IF (select count(*) from bdicred:sd_repor_bnmex where fecha_fin=dFechaFin)=0 THEN
        INSERT INTO bdicred:sd_repor_bnmex (fecha_fin,tproceso,fecha_insert) VALUES(dFechaFin,vproceso,today);
    END IF;

    SELECT tproceso INTO vproceso
    FROM bdicred:sd_repor_bnmex
    WHERE fecha_fin=dFechaFin;

    IF vproceso=0 THEN
        SET ISOLATION TO DIRTY READ;
-- Cuentas básicas para el público en general
        select {+INDEX(bdicheq:sc_maenoc idx_sc_maenoc2)} count(*),nvl(sum(a.sdo_mes_ant),0)
        into deb1009,deb1009_m
        from bdicheq:sc_maenoc a
---     INNER JOIN bdicheq:sc_maechq b on (b.empresa = '001' and b.cuenta=a.cuenta and b.producto IN ('1400','1700','1300'))
        INNER JOIN bdicheq:sc_maechq b on {+INDEX(bdicheq:sc_maechq idx_sc_maechq)} (b.cuenta=a.cuenta and b.producto IN ('1400','1700','1300'))
        ---where a.empresa =pEmpresa and
        where 
        a.fecha_alta <= dFechaFin
        AND a.cuenta between '10000005016' and '99010000122';
--Total de cuentas con TDD (al último día del trimestre) Fisicas
        SET ISOLATION TO DIRTY READ;
        select {+INDEX(bdicheq:sc_maenoc idx_sc_maenoc2)} count(*),nvl(sum(a.sdo_mes_ant),0)
        into deb1010_f,deb1010_fm
        from bdicheq:sc_maenoc a
        join bdicheq:sc_maechq b on {+INDEX(bdicheq:sc_maechq idx_sc_maechq)} (b.cuenta=a.cuenta and b.producto <> '1100')
        ---join bdicheq:sc_tarjeta c on {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (c.empresa=pEmpresa and c.cuenta=a.cuenta and c.secuencia=1 and c.tipo_tarjeta='T')
        join bdicheq:sc_tarjeta c on {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (c.cuenta=a.cuenta and c.secuencia=1 and c.tipo_tarjeta='T')
        where a.fecha_alta <= dFechaFin
        AND a.cuenta between '10000005016' and '99010000122';
--Total de cuentas con TDD (al último día del trimestre) Morales
        SET ISOLATION TO DIRTY READ;
        select {+INDEX(bdicheq:sc_maenoc idx_sc_maenoc2)} count(*),nvl(sum(a.sdo_mes_ant),0)
        into deb1010_m,deb1010_mm
        from bdicheq:sc_maenoc a
        ---join bdicheq:sc_maechq b on {+INDEX(bdicheq:sc_maechq idx_sc_maechq)} (b.empresa = '001' and b.cuenta=a.cuenta and b.producto <> '1100')
        join bdicheq:sc_maechq b on {+INDEX(bdicheq:sc_maechq idx_sc_maechq)} (b.cuenta=a.cuenta and b.producto <> '1100')
        ---join bdicheq:sc_tarjeta c on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (c.empresa=pEmpresa and c.cuenta=a.cuenta and c.secuencia=1 and c.tipo_tarjeta='T'
        join bdicheq:sc_tarjeta c on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (c.cuenta=a.cuenta and c.secuencia=1 and c.tipo_tarjeta='T'
        ---AND c.numcte IN  (select {+INDEX(bdinteg:si_cliente idx_si_cliente)} numcte from bdinteg:si_cliente where tpo_persona<>'01') )
        AND c.numcte IN  (select {+INDEX(bdinteg:si_cliente idx_si_cliente)} numcte from bdinteg:si_cliente where tpo_persona!='01' and tipo_cliente between '1' and '3') )
        where a.fecha_alta <= dFechaFin
        AND a.cuenta between '10000005016' and '99010000122';

            IF deb1010_m>0 THEN
                LET deb1010_f = deb1010_f - deb1010_m;
                LET deb1010_fm = deb1010_fm - deb1010_mm;
                LET deb1010_fm = deb1010_fm/(deb1010_f*1000);
                LET deb1010_mm = deb1010_mm/(deb1010_m*1000);
            ELSE
                LET deb1010_fm = deb1010_fm/(deb1010_f*1000);
            END IF;
--Cuentas abiertas con TDD (durante el trimestre)
        SET ISOLATION TO DIRTY READ;
        select {+INDEX(bdicheq:sc_maenoc idx_sc_maenoc2)} count(*),nvl(sum(a.sdo_mes_ant),0)
        into deb1011_f,deb1011_fm
        from bdicheq:sc_maenoc a
        join bdicheq:sc_maechq b on {+INDEX(bdicheq:sc_maechq idx_sc_maechq)} (c.cuenta=b.cuenta and b.producto != '1100')
        join bdicheq:sc_tarjeta c on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (a.cuenta=c.cuenta  and c.secuencia=1 and c.tipo_tarjeta='T')
        where a.fecha_alta BETWEEN dFechaIni AND dFechaFin 
        AND a.cuenta between '10000005016' and '99010000122';
--Cuentas abiertas con TDD (durante el trimestre) Morales
        SET ISOLATION TO DIRTY READ;
        select {+INDEX(bdicheq:sc_maenoc idx_sc_maenoc2)} count(*),nvl(sum(a.sdo_mes_ant),0)
        into deb1011_m,deb1011_mm
        from bdicheq:sc_maenoc a
        join bdicheq:sc_maechq b on {+INDEX(bdicheq:sc_maechq idx_sc_maechq)} (a.cuenta=b.cuenta and b.producto <> '1100')
        join bdicheq:sc_tarjeta c on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (a.cuenta=c.cuenta and c.secuencia=1 and c.tipo_tarjeta='T'
        AND c.numcte IN  (select {+INDEX(bdinteg:si_cliente idx_si_cliente)} numcte from bdinteg:si_cliente where tpo_persona != '01' and tipo_cliente between '1' and '3') )
        where a.fecha_alta BETWEEN dFechaIni AND dFechaFin 
        AND a.cuenta between '10000005016' and '99010000122';
--canceladas con TDD (durante el trimestre) (fisicas)
        SET ISOLATION TO DIRTY READ;
        select {+INDEX(bdicheq:sc_maenoc noc1)} count(*),nvl(sum(a.sdo_mes_ant),0) 
        into deb1013_f,deb1013_fm
        from bdicheq:sc_maenoc a
        join bdicheq:sc_maechq b on {+INDEX(bdicheq:sc_maechq idx_sc_maechq1)} (a.cuenta=b.cuenta and b.producto <> '1100' and b.status_cta=2 
                                    and b.fec_ult_mov BETWEEN dFechaIni AND dFechaFin) 
        join bdicheq:sc_tarjeta c on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (a.cuenta=c.cuenta and c.tipo_tarjeta='T' and c.secuencia=1)
        ---where a.empresa=pEmpresa and a.cuenta=b.cuenta;
        where a.cuenta=b.cuenta;
--canceladas con TDD (durante el trimestre) (morales)
        SET ISOLATION TO DIRTY READ;
        select {+INDEX(bdicheq:sc_maenoc noc1)} count(*),nvl(sum(a.sdo_mes_ant),0) 
        into deb1013_m,deb1013_mm
        from bdicheq:sc_maenoc a
        join bdicheq:sc_maechq b on {+INDEX(bdicheq:sc_maechq idx_sc_maechq1)} (a.cuenta=b.cuenta and b.producto <> '1100' and b.status_cta=2 and b.fec_ult_mov BETWEEN dFechaIni AND dFechaFin) 
        join bdicheq:sc_tarjeta c on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (a.cuenta=c.cuenta and c.tipo_tarjeta='T' and c.secuencia=1)
        AND c.numcte IN  (select {+INDEX(bdinteg:si_cliente idx_si_cliente)} numcte from bdinteg:si_cliente where tpo_persona != '01' and tipo_cliente between '1' and '3') 
        ---where a.empresa=pEmpresa and a.cuenta=b.cuenta;
        where a.cuenta=b.cuenta;
--Cuentas básicas de nómina 
        SET ISOLATION TO DIRTY READ;
        select {+INDEX( bdicheq:sc_maenoc idx_sc_maenoc2)} count(*),nvl(sum(a.sdo_mes_ant),0) 
        into nom1009_f,nom1009_fm
        from bdicheq:sc_maenoc a
        join bdicheq:sc_maechq b on  {+INDEX(bdicheq:sc_maechq idx_sc_maechq1)} (a.cuenta=b.cuenta and b.producto in ('1300','1700') ) 
        where a.fecha_alta <= dFechaFin
        AND a.cuenta between '10000005016' and '99010000122';
--Total de cuentas con TDD (al último día del trimestre)
        SET ISOLATION TO DIRTY READ;
        select {+INDEX( bdicheq:sc_maenoc idx_sc_maenoc2)} count(*),nvl(sum(a.sdo_mes_ant),0) 
        into nom1010_f,nom1010_fm
        from bdicheq:sc_maenoc a
        join bdicheq:sc_maechq b on  {+INDEX(bdicheq:sc_maechq idx_sc_maechq)} (a.cuenta=b.cuenta and b.producto in ('1300','1700')) 
        join bdicheq:sc_tarjeta c on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (a.cuenta=c.cuenta and c.tipo_tarjeta='T' and c.secuencia=1)
        where a.fecha_alta < dFechaFin
        AND a.cuenta between '10000005016' and '99010000122';
--Cuentas abiertas con TDD (durante el trimestre)
        SET ISOLATION TO DIRTY READ;
        select {+INDEX( bdicheq:sc_maenoc idx_sc_maenoc2)} count(*),nvl(sum(a.sdo_mes_ant),0) 
        into nom1011_f,nom1011_fm
        from bdicheq:sc_maenoc a
        join bdicheq:sc_maechq b on (a.cuenta=b.cuenta and b.producto in ('1300','1700')) 
        join bdicheq:sc_tarjeta c on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (a.cuenta=c.cuenta and c.tipo_tarjeta='T' and c.secuencia=1 )
        where a.fecha_alta BETWEEN dFechaIni AND dFechaFin
        AND a.cuenta between '10000005016' and '99010000122';
--canceladas con TDD (durante el trimestre)
        SET ISOLATION TO DIRTY READ;
        select {+INDEX( bdicheq:sc_maenoc idx_sc_maenoc2)} count(*),nvl(sum(a.sdo_mes_ant),0) 
        into nom1013_f,nom1013_fm
        from bdicheq:sc_maenoc a
        join bdicheq:sc_maechq b on  {+INDEX(bdicheq:sc_maechq idx_sc_maechq)} (a.cuenta=b.cuenta and b.producto in ('1300','1700') and b.status_cta=2 
        and b.fec_ult_mov BETWEEN dFechaIni AND dFechaFin)
        join bdicheq:sc_tarjeta c on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (a.cuenta=c.cuenta and c.tipo_tarjeta='T' and c.secuencia=1)
        where a.empresa=pEmpresa and a.cuenta=b.cuenta
        AND a.cuenta between '10000005016' and '99010000122';

        LET deb1022_f= deb1010_f;
        LET deb1022_fm= deb1010_fm;
        LET deb1022_m= deb1010_m;
        LET deb1022_mm= deb1010_mm;
        LET deb1023_f= deb1011_f;
        LET deb1023_fm= deb1011_fm;
        LET deb1023_m= deb1011_m;
        LET deb1023_mm= deb1011_mm;
        LET deb1025_f= deb1013_f;
        LET deb1025_fm= deb1013_fm;
        LET deb1025_m= deb1013_m;
        LET deb1025_mm= deb1013_mm;
        LET nom1022_f= nom1010_f;
        LET nom1022_fm= nom1010_fm;
        LET nom1023_f= nom1011_f;
        LET nom1023_fm= nom1011_fm;
        LET nom1025_f= nom1013_f;
        LET nom1025_fm= nom1013_fm;

        LET vproceso=1;

        BEGIN WORK;

        UPDATE bdicred:sd_repor_bnmex
        SET  tdeb1009=deb1009, 
             tdeb1009_m=deb1009_m,
             tdeb1010_f=deb1010_f,
             tdeb1010_fm=deb1010_fm,
             tdeb1010_m=deb1010_m,
             tdeb1010_mm=deb1010_mm,
             tdeb1011_f=deb1011_f,
             tdeb1011_fm=deb1011_fm,
             tdeb1011_m=deb1011_m,
             tdeb1011_mm=deb1011_mm,
             tdeb1013_f=deb1013_f,
             tdeb1013_fm=deb1013_fm,
             tdeb1013_m=deb1013_m,
             tdeb1013_mm=deb1013_mm,
             tdeb1022_f=deb1022_f,
             tdeb1022_fm=deb1022_fm,
             tdeb1022_m=deb1022_m,
             tdeb1022_mm=deb1022_mm,
             tdeb1023_f=deb1023_f,
             tdeb1023_fm=deb1023_fm,
             tdeb1023_m=deb1023_m,
             tdeb1023_mm=deb1023_mm,
             tdeb1025_f=deb1025_f,
             tdeb1025_fm=deb1025_fm,
             tdeb1025_m=deb1025_m,
             tdeb1025_mm=deb1025_mm,
             tnom1009_f=nom1009_f,
             tnom1009_fm=nom1009_fm,
             tnom1010_f=nom1010_f,
             tnom1010_fm=nom1010_fm,
             tnom1011_f=nom1011_f,
             tnom1011_fm=nom1011_fm,
             tnom1013_f=nom1013_f,
             tnom1013_fm=nom1013_fm,
             tnom1022_f=nom1022_f,
             tnom1022_fm=nom1022_fm,
             tnom1023_f=nom1023_f,
             tnom1023_fm=nom1023_fm,
             tnom1025_f=nom1025_f,
             tnom1025_fm=nom1025_fm,
             tproceso=vproceso
        WHERE fecha_fin=dFechaFin;

        COMMIT WORK;
    END IF;
 
    IF vproceso=1 THEN

        SET ISOLATION TO DIRTY READ;
        select {+INDEX(intercard:tarjeta idx_tarjeta1)} COUNT(*) 
        into deb1740 
        from intercard:tarjeta 
        where numtarjeta matches '400819*' 
        and fechaasignacion < cFechaFin;
--Tarjetas de débito adicionales
        SET ISOLATION TO DIRTY READ;
        select  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} count(*) 
        into deb1741        
        from bdicheq:sc_tarjeta c
        join bdicheq:sc_maenoc a on {+index(bdicheq:sc_maenoc idx_sc_maenoc2)} (a.fecha_alta < dFechaFin)
        where c.cuenta=a.cuenta 
        and c.secuencia between 1 and 21
        and c.tipo_tarjeta='A';
--Tarjetas de débito Visa
        LET deb1742=deb1740;
--Tarjetas de crédito emitidas (en poder del público)
        SET ISOLATION TO DIRTY READ;
        select {+INDEX(intercard:tarjeta idx_tarjeta1)} COUNT(*)  
        into cred1745  
        from intercard:tarjeta 
        where numtarjeta matches '426807*' 
        and fechaasignacion < cFechaFin;
--Tarjetas de crédito adicionales
        SET ISOLATION TO DIRTY READ;
        SELECT {+INDEX(sd_tarjeta ix_tarjeta3)} count(*) 
        into cred1746  
        FROM sd_tarjeta a, bdicred:sd_maecred b 
        where a.numcte=b.numcte and b.fecha_apertura < dFechaFin
        and a.tipo_tarjeta='A' ;
--Tarjetas de credito Visa
        LET cred1747=cred1745;

        LET vproceso=2;

        BEGIN WORK;

        UPDATE bdicred:sd_repor_bnmex
        SET  tdeb1740=deb1740,
             tdeb1741=deb1741,
             tdeb1742=deb1742,
             tcred1745=cred1745,
             tcred1746=cred1746,
             tcred1747=cred1747,
             tproceso=vproceso
        WHERE fecha_fin=dFechaFin;

        COMMIT WORK;

    END IF; 

--Saldos de credito
-- Clientes que pagaron el saldo total (en el último mes o corte) 
--    LET iMes  = month(dFechaFin)-1;

--rss
    LET iMes  = month(dFechaFin) - 1;
    IF iMes = 0 THEN 
        LET iMes  = 12;
        LET iAnio = YEAR(pFecha) - 1; 
    elif iAnio <> year(dFechaFin) then
        LET iAnio = YEAR(pFecha) - 1; 
    END IF;

        LET ult_corte =mdy(iMes,'20',iAnio);
--rss

--        LET ult_corte =mdy(iMes,'20',YEAR(dFechaFin));
        LET prox_corte = mdy(month(dFechaFin),'20',year(dFechaFin));

    IF vproceso=2 THEN

--Clientes que pagaron el saldo total (en el último mes o corte)
SET ISOLATION TO DIRTY READ;
            select {+INDEX(bdicred:sd_maesdoshist idx_maesdishist1)} count(*)
            into cred2400
            from bdicred:sd_maesdoshist a
            where fecha = ult_corte
            and empresa = pEmpresa
            and num_credito between '600000005089' and '660000000001'
            and
            (
            select {+INDEX(sd_movhis inx_movhis)} sum(monto)
            from bdicred:sd_movhis
            where empresa = pEmpresa
            and a.num_credito = num_credito
            and fecha_mov >= ult_corte+1
            and fecha_mov <= prox_corte
            and codigo_fun in (select cod_fun
                from bdicred:sd_conceptospagomanual
                where codigo>"")
            and codigo_ref in (7,8,9,10)
            and reversado = 'N'
            ) >= sdo_cap_insoluto
            and sdo_cap_insoluto > 0;
--Clientes que pagaron el mínimo (en el último mes o corte)
        SET ISOLATION TO DIRTY READ;
            select {+INDEX(bdicred:sd_maesdoshist idx_maesdishist1)} count(*)
            into cred2401
            from bdicred:sd_maesdoshist a
            where fecha = ult_corte
            and empresa = pEmpresa
            and num_credito between '600000005089' and '660000000001'
            and
            (
            select {+INDEX(sd_movhis inx_movhis)} sum(monto) 
            from bdicred:sd_movhis 
            where empresa = pEmpresa 
            and a.num_credito = num_credito
            and fecha_mov >= ult_corte+1
            and fecha_mov <= prox_corte
            and codigo_fun in (select cod_fun 
                from bdicred:sd_conceptospagomanual 
                where codigo>"")
            and codigo_ref in (7,8,9,10)
            and reversado = 'N'
            ) < sdo_cap_insoluto 
            and sdo_cap_insoluto > 0
            and
            (
            select sum(monto) 
            from {+INDEX(sd_movhis inx_movhis)} bdicred:sd_movhis 
            where empresa = pEmpresa 
            and a.num_credito = num_credito
            and fecha_mov >= ult_corte+1
            and fecha_mov <= prox_corte
            and codigo_fun in (select cod_fun 
                from bdicred:sd_conceptospagomanual 
                where codigo>"")
            and codigo_ref in (7,8,9,10)
            and reversado = 'N'
            ) >= monto_financiado;

        LET vproceso=3;

        BEGIN WORK;

        UPDATE bdicred:sd_repor_bnmex
        SET  tcred2400=cred2400,
             tcred2401=cred2401,
             tproceso=vproceso
        WHERE fecha_fin=dFechaFin;

        COMMIT WORK;
    END IF; 

    IF vproceso=3 THEN
--Monto pagado por los clientes que liquidan el saldo total al último corte del trimestre (totaleros) CCR
        SET ISOLATION TO DIRTY READ;
            select {+INDEX(sd_movhis inx_movhis)} sum(monto) 
            into cred2402
            from bdicred:sd_movhis 
            where empresa = pEmpresa
            and fecha_mov >= ult_corte+1
            and fecha_mov <= prox_corte
            and codigo_fun in (select cod_fun 
                from bdicred:sd_conceptospagomanual 
                where codigo>"")
            and codigo_ref in (7,8,9,10,901)
            and reversado = 'N'
            and num_credito in (
            select {+INDEX(bdicred:sd_maesdoshist idx_maesdishist1)} num_credito
            from bdicred:sd_maesdoshist a
            where fecha = ult_corte
            and empresa = pEmpresa
            and num_credito between '600000005089' and '660000000001'
            and
            (
            select {+INDEX(sd_movhis inx_movhis)} sum(monto) 
            from bdicred:sd_movhis 
            where empresa = pEmpresa
            and a.num_credito = num_credito
            and fecha_mov >= ult_corte+1
            and fecha_mov <= prox_corte
            and codigo_fun in (select cod_fun 
                from bdicred:sd_conceptospagomanual 
                where codigo>"")
            and codigo_ref in (7,8,9,10,901)
            and reversado = 'N'
            ) >= sdo_cap_insoluto
            and sdo_cap_insoluto > 0);
--Monto pagado por los clientes que liquidan parcialmente el saldo al último corte del trimestre (revo
        SET ISOLATION TO DIRTY READ;
            select {+INDEX(sd_movhis inx_movhis)} sum(monto)
            into cred2403
            from bdicred:sd_movhis 
            where empresa = pEmpresa 
            and fecha_mov >= ult_corte+1
            and fecha_mov <= prox_corte
            and codigo_fun in (select cod_fun 
                from bdicred:sd_conceptospagomanual 
                where codigo>"")
            and codigo_ref in (7,8,9,10)
            and reversado = 'N'
            and num_credito in (
            select {+INDEX(bdicred:sd_maesdoshist idx_maesdishist1)} a.num_credito
            from bdicred:sd_maesdoshist a
            where fecha = ult_corte
            and empresa = pEmpresa
            and num_credito between '600000005089' and '660000000001'
            and
            (
            select {+INDEX(sd_movhis inx_movhis)} sum(monto) 
            from bdicred:sd_movhis 
            where empresa = pEmpresa 
            and a.num_credito = num_credito
            and fecha_mov >= ult_corte+1
            and fecha_mov <= prox_corte
            and codigo_fun in (select cod_fun 
                from bdicred:sd_conceptospagomanual 
                where codigo>"")
            and codigo_ref in (7,8,9,10)
            and reversado = 'N'
            ) < sdo_cap_insoluto 
            and sdo_cap_insoluto > 0
            and
            (
            select {+INDEX(sd_movhis inx_movhis)} sum(monto) 
            from bdicred:sd_movhis 
            where empresa = pEmpresa 
            and a.num_credito = num_credito
            and fecha_mov >= ult_corte+1
            and fecha_mov <= prox_corte
            and codigo_fun in (select cod_fun 
                from bdicred:sd_conceptospagomanual 
                where codigo>"")
            and codigo_ref in (7,8,9,10)
            and reversado = 'N'
            ) >= monto_financiado);
--Saldo impagado no vencido (en el último mes o corte)
        SET ISOLATION TO DIRTY READ;
            select {+INDEX(bdicred:sd_maesdoshist idx_maesdishist1)} sum(monto_financiado - monto_vencido - mto_venc_trasp)
            into cred2404
            from bdicred:sd_maesdoshist a
            where fecha = prox_corte
            and empresa = pEmpresa
            and num_credito between '600000005089' and '660000000001'
            and sdo_cap_insoluto > 0;
--Saldo impagado vencido (acumulado al último día del trimestre)
        SET ISOLATION TO DIRTY READ;
            select sum(monto_vencido + mto_venc_trasp)
            into cred2406
            from bdicred:sd_maesdoscont a
            where fecha = dFechaFin
            and empresa = pEmpresa
            and num_credito between '600000005089' and '660000000001'
            and sdo_cap_insoluto > 0;

        LET vproceso=4;

        BEGIN WORK;

        UPDATE bdicred:sd_repor_bnmex
        SET  tcred2402=cred2402,
             tcred2403=cred2403,
             tcred2404=cred2404,
             tcred2406=cred2406,
             tproceso=vproceso
        WHERE fecha_fin=dFechaFin;

        COMMIT WORK;
    END IF; 

    IF vproceso=4 THEN
-- Menor o igual a $3,000 , Mayor de $3,000 y menor o igual a $5,000, Mayor de $5,000 y menor o igual a $10,000, 
--Mayor de $10,000 y menor o igual a $20,000, Mayor de $20,000 y menor o igual a $50,000 , Mayor a $50,000 
        SET ISOLATION TO DIRTY READ;
            select {+INDEX(bdicred:sd_maecred idx_macred4), +INDEX(bdicred:sd_maesdos idx_sd_maesdos} sum(case when monto_otorgado <= 3000 then 1 else 0 end),
                   sum(case when monto_otorgado > 3000 and monto_otorgado <= 5000 then 1 else 0 end),
                   sum(case when monto_otorgado > 5000 and monto_otorgado <= 10000 then 1 else 0 end),
                   sum(case when monto_otorgado > 10000 and monto_otorgado <= 20000 then 1 else 0 end),
                   sum(case when monto_otorgado > 20000 and monto_otorgado <= 50000 then 1 else 0 end),
                   sum(case when monto_otorgado > 50000 then 1 else 0 end)
            into cred2500,cred2501,cred2502,cred2503,cred2504,cred2505
            from bdicred:sd_maecred a,
                 bdicred:sd_maesdos b
            where fecha_apertura <= dFechaFin
              and a.empresa = pEmpresa
              and a.empresa = b.empresa
              and a.num_credito = b.num_credito
              and status_cred not in ('CV','FF');

        LET vproceso=5;

        BEGIN WORK;

        UPDATE bdicred:sd_repor_bnmex
        SET  tcred2500=cred2500,
             tcred2501=cred2501,
             tcred2502=cred2502,
             tcred2503=cred2503,
             tcred2504=cred2504,
             tcred2505=cred2505,
             tproceso=vproceso
        WHERE fecha_fin=dFechaFin;

        COMMIT WORK;
    END IF; 
    IF vproceso=5 THEN
--Cajeros Automáticos en sucrsal
        SET ISOLATION TO DIRTY READ;
    FOREACH
        SELECT  count(b.tpo_sucursal),a.estado 
        into cant_sucur,num_estado
        FROM bdinteg:si_estados a 
        left outer join bdinteg:si_sucursales b on {+INDEX(bdinteg:si_sucursales ix_982)} (b.pais=a.pais and b.estado=a.estado and b.ciudad<>'000' and b.tpo_sucursal='C')
        ---where a.estado>0 group by a.estado 
        where a.estado between '01' and '32'
        group by a.estado 
        
        IF num_estado='01' THEN LET caj2100=cant_sucur; END IF;
        IF num_estado='02' THEN LET caj2101=cant_sucur; END IF;
        IF num_estado='03' THEN LET caj2102=cant_sucur; END IF;
        IF num_estado='04' THEN LET caj2103=cant_sucur; END IF;
        IF num_estado='05' THEN LET caj2104=cant_sucur; END IF;
        IF num_estado='06' THEN LET caj2105=cant_sucur; END IF;
        IF num_estado='07' THEN LET caj2106=cant_sucur; END IF;
        IF num_estado='08' THEN LET caj2107=cant_sucur; END IF;
        IF num_estado='09' THEN LET caj2108=cant_sucur; END IF;
        IF num_estado='10' THEN LET caj2109=cant_sucur; END IF;
        IF num_estado='11' THEN LET caj2110=cant_sucur; END IF;
        IF num_estado='12' THEN LET caj2111=cant_sucur; END IF;
        IF num_estado='13' THEN LET caj2112=cant_sucur; END IF;
        IF num_estado='14' THEN LET caj2113=cant_sucur; END IF;
        IF num_estado='15' THEN LET caj2114=cant_sucur; END IF;
        IF num_estado='16' THEN LET caj2115=cant_sucur; END IF;
        IF num_estado='17' THEN LET caj2116=cant_sucur; END IF;
        IF num_estado='18' THEN LET caj2117=cant_sucur; END IF;
        IF num_estado='19' THEN LET caj2118=cant_sucur; END IF;
        IF num_estado='20' THEN LET caj2119=cant_sucur; END IF;
        IF num_estado='21' THEN LET caj2120=cant_sucur; END IF;
        IF num_estado='22' THEN LET caj2121=cant_sucur; END IF;
        IF num_estado='23' THEN LET caj2122=cant_sucur; END IF;
        IF num_estado='24' THEN LET caj2123=cant_sucur; END IF;
        IF num_estado='25' THEN LET caj2124=cant_sucur; END IF;
        IF num_estado='26' THEN LET caj2125=cant_sucur; END IF;
        IF num_estado='27' THEN LET caj2126=cant_sucur; END IF;
        IF num_estado='28' THEN LET caj2127=cant_sucur; END IF;
        IF num_estado='29' THEN LET caj2128=cant_sucur; END IF;
        IF num_estado='30' THEN LET caj2129=cant_sucur; END IF;
        IF num_estado='31' THEN LET caj2130=cant_sucur; END IF;
        IF num_estado='32' THEN LET caj2131=cant_sucur; END IF;

    END FOREACH;

    LET vproceso=6;

    BEGIN WORK;

        UPDATE bdicred:sd_repor_bnmex
        SET tcaj2100=caj2100,
            tcaj2101=caj2101,
            tcaj2102=caj2102,
            tcaj2103=caj2103,
            tcaj2104=caj2104,
            tcaj2105=caj2105,
            tcaj2106=caj2106,
            tcaj2107=caj2107,
            tcaj2108=caj2108,
            tcaj2109=caj2109,
            tcaj2110=caj2110,
            tcaj2111=caj2111,
            tcaj2112=caj2112,
            tcaj2113=caj2113,
            tcaj2114=caj2114,
            tcaj2115=caj2115,
            tcaj2116=caj2116,
            tcaj2117=caj2117,
            tcaj2118=caj2118,
            tcaj2119=caj2119,
            tcaj2120=caj2120,
            tcaj2121=caj2121,
            tcaj2122=caj2122,
            tcaj2123=caj2123,
            tcaj2124=caj2124,
            tcaj2125=caj2125,
            tcaj2126=caj2126,
            tcaj2127=caj2127,
            tcaj2128=caj2128,
            tcaj2129=caj2129,
            tcaj2130=caj2130,
            tcaj2131=caj2131,
            tproceso=vproceso
        WHERE fecha_fin=dFechaFin;

    COMMIT WORK;
    END IF; 

        IF vproceso=6 THEN

    --Tarjetas utililzadas
    ---INICIALIZACION
                LET deb7010=0;
                LET deb7010_m=0;
                LET deb7012=0;
                LET deb7012_m=0;
                LET deb7013=0;
                LET deb7015=0;
                LET deb1709=0;
                LET deb1709_m=0;
                LET deb1722=0;
                LET deb1701=0;
    --intercard debito
            SET ISOLATION TO DIRTY READ;
        FOREACH
               SELECT  {+INDEX(intercard:movimientohistorico idx_movimiento3)} numtarjeta,
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros propios
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V'  and codtran='01' then monto else 0 end),
                       sum(case when trancajeropropio='F' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros de otros bancos
                       sum(case when trancajeropropio='F' and codtran='01' then monto else 0 end),
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' AND codtran='31' then 1 else 0 end),--Consultas de clientes propios en cajeros propios
                       sum(case when trancajeropropio='F' AND codtran='31' then 1 else 0 end),--Consultas de clientes propios en cajeros de otros bancos       
                       sum(case when prodind='02' and codtran='00' then 1 else 0 end),
                       sum(case when prodind='02' and codtran='00' then monto else 0 end)--De tarjetas de clientes del banco en tpvs de otros bancos
                into a_numtarjeta,a_deb7010,a_deb7010_m,a_deb7012,a_deb7012_m,a_deb7013,a_deb7015,a_deb1709,a_deb1709_m
                FROM intercard:movimientohistorico
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
--                AND fechahorainauth  BETWEEN dFechaIni AND dFechaFin 
                AND fechahorainauth  >= cFechaIni AND fechahorainauth <= cFechaFin 
                and numtarjeta matches '400819*'
                group by numtarjeta
                union
                SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} numtarjeta,
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros propios
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V'  and codtran='01' then monto else 0 end),
                       sum(case when trancajeropropio='F' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros de otros bancos
                       sum(case when trancajeropropio='F' and codtran='01' then monto else 0 end),
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' AND codtran='31' then 1 else 0 end),--Consultas de clientes propios en cajeros propios
                       sum(case when trancajeropropio='F' AND codtran='31' then 1 else 0 end),--Consultas de clientes propios en cajeros de otros bancos
                       sum(case when prodind='02' and codtran='00' then 1 else 0 end),
                       sum(case when prodind='02' and codtran='00' then monto else 0 end)--De tarjetas de clientes del banco en tpvs de otros bancos
                FROM intercard:movimiento
                where esnacional='V'
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
--                AND fechahorainauth  BETWEEN dFechaIni AND dFechaFin
                AND fechahorainauth  >= cFechaIni AND fechahorainauth <= cFechaFin 
                and numtarjeta matches '400819*'
                group by numtarjeta

                IF a_deb7010>0      THEN LET deb7010=deb7010+1;                 END IF;
                IF a_deb7010_m>0    THEN LET deb7010_m=deb7010_m+a_deb7010_m;   END IF;
                IF a_deb7012>0      THEN LET deb7012=deb7012+1;                 END IF;
                IF a_deb7012_m>0    THEN LET deb7012_m=deb7012_m+a_deb7012_m;   END IF;
                IF a_deb7013>0      THEN LET deb7013=deb7013+1;                 END IF;
                IF a_deb7015>0      THEN LET deb7015=deb7015+1;                 END IF;
                IF a_deb1709>0      THEN LET deb1709=deb1709+1;                 END IF;
                IF a_deb1709_m>0    THEN LET deb1709_m=deb1709_m+a_deb1709_m;   END IF;
                IF a_numtarjeta>0   THEN LET deb1722=deb1722+1;                 END IF;
           END FOREACH;

    --INICIALIZACION
            LET cred7010=0;
            LET cred7010_m=0;
            LET cred7012=0;
            LET cred7012_m=0;
            LET cred7013=0;
            LET cred7015=0;
            LET cred1709=0;
            LET cred1709_m=0;
            LET cred1707=0;
            LET cred1727=0;
            LET cred1700=0;
    --intercard credito
            SET ISOLATION TO DIRTY READ;
        FOREACH
                SELECT {+INDEX(intercard:movimientohistorico idx_movimiento3)} numtarjeta,
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros propios
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V'  and codtran='01' then monto else 0 end),
                       sum(case when trancajeropropio='F' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros de otros bancos
                       sum(case when trancajeropropio='F' and codtran='01' then monto else 0 end),
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' AND codtran='31' then 1 else 0 end),--Consultas de clientes propios en cajeros propios
                       sum(case when trancajeropropio='F' AND codtran='31' then 1 else 0 end),--Consultas de clientes propios en cajeros de otros bancos
                       sum(case when prodind='02' and codtran='00' and tipotransaccionposdigitada<>'CE' then 1 else 0 end),
                       sum(case when prodind='02' and codtran='00' and tipotransaccionposdigitada<>'CE' then monto else 0 end),--De tarjetas de clientes del banco en tpvs de otros bancos
                       sum(case when metodocaptura = '01' and tipotransaccionposdigitada='CE' then 1 else 0 end)--transsacciones en internett
                into a_numtarjeta,a_cred7010,a_cred7010_m,a_cred7012,a_cred7012_m,a_cred7013,a_cred7015,a_cred1709,a_cred1709_m,a_cred1707
                FROM intercard:movimientohistorico
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
--                AND fechahorainauth  BETWEEN dFechaIni AND dFechaFin
                AND fechahorainauth  >= cFechaIni AND fechahorainauth <= cFechaFin 
                and numtarjeta matches '426807*'
                group by numtarjeta
                union
                SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} numtarjeta,
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros propios
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V'  and codtran='01' then monto else 0 end),
                       sum(case when trancajeropropio='F' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros de otros bancos
                       sum(case when trancajeropropio='F' and codtran='01' then monto else 0 end),
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' AND codtran='31' then 1 else 0 end),--Consultas de clientes propios en cajeros propios
                       sum(case when trancajeropropio='F' AND codtran='31' then 1 else 0 end),--Consultas de clientes propios en cajeros de otros bancos
                       sum(case when prodind='02' and codtran='00' and tipotransaccionposdigitada<>'CE' then 1 else 0 end),
                       sum(case when prodind='02' and codtran='00' and tipotransaccionposdigitada<>'CE' then monto else 0 end),--De tarjetas de clientes del banco en tpvs de otros bancos
                       sum(case when metodocaptura = '01' and tipotransaccionposdigitada='CE' then 1 else 0 end)--transsacciones en internett
                FROM intercard:movimiento
                where esnacional='V'
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
--                AND fechahorainauth BETWEEN dFechaIni AND dFechaFin
                AND fechahorainauth  >= cFechaIni AND fechahorainauth <= cFechaFin 
                and numtarjeta matches '426807*'
                group by numtarjeta

                IF a_cred7010>0     THEN LET cred7010=cred7010+1;                  END IF;
                IF a_cred7010_m>0   THEN LET cred7010_m=cred7010_m+a_cred7010_m;   END IF;
                IF a_cred7012>0     THEN LET cred7012=cred7012+1;                  END IF;
                IF a_cred7012_m>0   THEN LET cred7012_m=cred7012_m+a_cred7012_m;   END IF;
                IF a_cred7013>0     THEN LET cred7013=cred7013+1;                  END IF;
                IF a_cred7015>0     THEN LET cred7015=cred7015+1;                  END IF;
                IF a_cred1709>0     THEN LET cred1709=cred1709+1;                  END IF;
                IF a_cred1709_m>0   THEN LET cred1709_m=cred1709_m+a_cred1709_m;   END IF;
                IF a_cred1707>0     THEN LET cred1707=cred1707+1;                  END IF;
                IF a_numtarjeta>0   THEN LET cred1727=cred1727+1;                  END IF;

           END FOREACH;

    ---SE INICIALIZAN
            LET nom7010=0;
            LET nom7010_m=0;
            LET nom7012=0;
            LET nom7012_m=0;
            LET nom7013=0;
            LET nom7015=0;

            SET ISOLATION TO DIRTY READ;
        FOREACH
                SELECT {+INDEX(intercard:movimientohistorico idx_movimiento3)} numtarjeta,
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros propios
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V'  and codtran='01' then monto else 0 end),
                       sum(case when trancajeropropio='F' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros de otros bancos
                       sum(case when trancajeropropio='F' and codtran='01' then monto else 0 end),
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' AND codtran='31' then 1 else 0 end),--Consultas de clientes propios en cajeros propios
                       sum(case when trancajeropropio='F' AND codtran='31' then 1 else 0 end)--Consultas de clientes propios en cajeros de otros bancos
                into a_numtarjeta,a_nom7010,a_nom7010_m,a_nom7012,a_nom7012_m,a_nom7013,a_nom7015
                FROM intercard:movimientohistorico
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind='01'
                AND codtran in ('01','31')
                AND formato='0200'
--                AND fechahorainauth BETWEEN dFechaIni AND dFechaFin
                AND fechahorainauth  >= cFechaIni AND fechahorainauth <= cFechaFin 
                and numtarjeta in (select  {+INDEX(bdicheq:sc_maechq idx_sc_maechq)} b.num_tarjeta from bdicheq:sc_maechq a 
                                   inner join bdicheq:sc_tarjeta b on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (b.empresa='001' 
                                   and b.cuenta=a.cuenta and b.secuencia=(select max(secuencia) 
                                                                          from bdicheq:sc_tarjeta 
                                                                          where cuenta=b.cuenta and numcte=a.num_cte 
                                                                          and tipo_tarjeta='T' and status_tar='A'))
                                    where a.producto in ('1300','1700'))
                group by numtarjeta
                union
                SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} numtarjeta,
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros propios
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V'  and codtran='01' then monto else 0 end),
                       sum(case when trancajeropropio='F' and codtran='01' then 1 else 0 end),--Retiros de clientes propios en cajeros de otros bancos
                       sum(case when trancajeropropio='F' and codtran='01' then monto else 0 end),
                       sum(case when trancajeroconvenio='F' AND trancajeropropio='V' AND codtran='31' then 1 else 0 end),--Consultas de clientes propios en cajeros propios
                       sum(case when trancajeropropio='F' AND codtran='31' then 1 else 0 end)--Consultas de clientes propios en cajeros de otros bancos
                FROM intercard:movimiento
                where esnacional='V'
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind='01'
                AND codtran in ('01','31')
                AND formato='0200'
--                AND fechahorainauth BETWEEN dFechaIni AND dFechaFin
                AND fechahorainauth  >= cFechaIni AND fechahorainauth <= cFechaFin 
                and numtarjeta in (select  {+INDEX(bdicheq:sc_maechq idx_sc_maechq)} b.num_tarjeta from bdicheq:sc_maechq a 
                                   inner join bdicheq:sc_tarjeta b on  {+INDEX(bdicheq:sc_tarjeta idx_sc_tarjeta)} (b.empresa='001' 
                                   and b.cuenta=a.cuenta and b.secuencia=(select max(secuencia) 
                                                                          from bdicheq:sc_tarjeta 
                                                                          where cuenta=b.cuenta and numcte=a.num_cte 
                                                                          and tipo_tarjeta='T' and status_tar='A'))
                                    where a.producto in ('1300','1700'))
                group by numtarjeta

                IF a_nom7010>0     THEN LET nom7010=nom7010+1;                 END IF;
                IF a_nom7010_m>0   THEN LET nom7010_m=nom7010_m+a_nom7010_m;   END IF;
                IF a_nom7012>0     THEN LET nom7012=nom7012+1;                 END IF;
                IF a_nom7012_m>0   THEN LET nom7012_m=nom7012_m+a_nom7012_m;   END IF;
                IF a_nom7013>0     THEN LET nom7013=nom7013+1;                 END IF;
                IF a_nom7015>0     THEN LET nom7015=nom7015+1;                 END IF;

           END FOREACH;

    --Total Crédito (utilizadas)
           LET cred1728=cred1727;
    --Total Crédito (utilizadas)
           LET cred1733=cred1727;
    --Crédito bm
           LET cred1726_bm=cred7010+cred7012+cred1709;
    --Total Crédito
           LET cred1728_bm=cred1726_bm;
    --Total Débito (utilizadas)
           LET deb1724=deb1722;
    --Total Débito (utilizadas)
           LET deb1732=deb1722;
    --Débito bm
           LET deb1722_bm=deb7010+deb7012+deb1709;
    --Total Débito
           LET deb1724_bm=deb1722_bm;

           LET vproceso=7;

           BEGIN WORK;

            UPDATE bdicred:sd_repor_bnmex
            SET tnom7010=nom7010,
                tnom7010_m=nom7010_m,
                tnom7012=nom7012,
                tnom7012_m=nom7012_m,
                tnom7013=nom7013,
                tnom7015=nom7015,
                tcred1707=cred1707,
                tcred1727=cred1727,
                tcred1728=cred1728,
                tcred1733=cred1733,
                tcred1726_bm=cred1726_bm,
                tcred1728_bm=cred1728_bm,
                tdeb1722=deb1722,
                tdeb1724=deb1724,
                tdeb1732=deb1732,
                tdeb1722_bm=deb1722_bm,
                tdeb1724_bm=deb1724_bm,
                tdeb7010=deb7010,
                tdeb7012=deb7012,
                tdeb7013=deb7013,
                tdeb7015=deb7015,
                tdeb1709=deb1709,
                tdeb7010_m=deb7010_m,
                tdeb7012_m=deb7012_m,
                tdeb1709_m=deb1709_m,
                tcred7010=cred7010,
                tcred7012=cred7012,
                tcred7013=cred7013,
                tcred7015=cred7015,
                tcred1709=cred1709, 
                tcred7010_m=cred7010_m,
                tcred7012_m=cred7012_m,
                tcred1709_m=cred1709_m,
                tproceso=vproceso
            WHERE fecha_fin=dFechaFin;
           COMMIT WORK;

       END IF;  

   IF vproceso=7 THEN
        
        select {+INDEX(intercard:conciliacion_atm_stat06 idx_cnc_atm_stat06_03)} sum(case when descripcion matches 'RETIR*CHEQU*' or descripcion matches 'RETIR*MAESTR*' THEN monto ELSE 0 END),
               sum(case when descripcion matches 'RETIR*CHEQU*' or descripcion matches 'RETIR*MAESTR*' THEN 1 ELSE 0 END),
               sum(case when descripcion matches 'CONSU*CHEQU*' or descripcion matches 'CONSU*MAESTR*' THEN monto ELSE 0 END),
               sum(case when descripcion matches 'CONSU*CHEQU*' or descripcion matches 'CONSU*MAESTR*' THEN 1 ELSE 0 END),
--               sum(case when descripcion NOT matches 'CONSU*CHEQU*' AND descripcion NOT matches 'RETIR*CHEQU*' THEN monto ELSE 0 END),
--               sum(case when descripcion NOT matches 'CONSU*CHEQU*' AND descripcion NOT matches 'RETIR*CHEQU*' THEN 1 ELSE 0 END),
               sum(case when descripcion matches 'RETIR*CREDI*' THEN monto ELSE 0 END),
               sum(case when descripcion matches 'RETIR*CREDI*' THEN 1 ELSE 0 END),
               sum(case when descripcion matches 'CONSU*CREDI*' THEN monto ELSE 0 END),
               sum(case when descripcion matches 'CONSU*CREDI*' THEN 1 ELSE 0 END)--,
--               sum(case when descripcion NOT matches 'CONSU*CREDI*' AND descripcion NOT matches 'RETIR*CREDI*' THEN monto ELSE 0 END),
--               sum(case when descripcion NOT matches 'CONSU*CREDI*' AND descripcion NOT matches 'RETIR*CREDI*' THEN 1 ELSE 0 END)
        into deb7011bm,deb7011bm_m,deb7014,deb7014_m,cred7011bm,cred7011bm_m,cred7014,cred7014_m
        from intercard:conciliacion_atm_stat06 
--        where keyx>0 and fechaconciliacion BETWEEN dFechaIni AND dFechaFin
        where keyx>0 and fechaconciliacion >= cFechaIni AND fechaconciliacion <= cFechaFin
        and archivoorigen in ('TMP','TMO') and substr(numtarjeta,1,6) not in ('400819','426807') and codigoiso='00';
        
        LET deb1701=0;
        LET cred1700=0;
        LET cuentas_aux=0;
        LET bin_tarjeta='';

        SET ISOLATION TO DIRTY READ;
        FOREACH
               SELECT {+INDEX(intercard:movimientohistorico idx_movimiento3), +INDEX(intercard:tarjetacuenta numtarjeta)} COUNT(distinct b.numcuenta),SUBSTR(a.numtarjeta,1,6) 
               into cuentas_aux,bin_tarjeta
                FROM intercard:movimientohistorico a, intercard:tarjetacuenta b
                where esnacional='V' 
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
--                AND fechahorainauth  BETWEEN dFechaIni AND dFechaFin
                AND fechahorainauth  >= cFechaIni AND fechahorainauth <= cFechaFin 
                and (a.numtarjeta matches '400819*' OR a.numtarjeta matches '426807*')
                and a.numtarjeta=b.numtarjeta
                group by 2
                union
                SELECT {+INDEX(intercard:movimiento idx_fechahorainauth) +INDEX(intercard:tarjetacuenta numtarjeta)} COUNT(distinct b.numcuenta),SUBSTR(a.numtarjeta,1,6)
                FROM intercard:movimiento a, intercard:tarjetacuenta b
                where esnacional='V'
                AND codigoiso='00' 
                and movreversado='F' 
                AND prodind in ('01','02')
                AND codtran in ('01','31','00')
                AND formato='0200'
--                AND fechahorainauth  BETWEEN dFechaIni AND dFechaFin
                AND fechahorainauth  >= cFechaIni AND fechahorainauth <= cFechaFin 
                and (a.numtarjeta matches '400819*' OR a.numtarjeta matches '426807*')
                and a.numtarjeta=b.numtarjeta
                group by 2

                IF bin_tarjeta='400819' THEN
                    IF cuentas_aux>0 THEN
                       LET deb1701=deb1701+cuentas_aux;
                    END IF;
                END IF;

                IF bin_tarjeta='426807' THEN
                    IF cuentas_aux>0 THEN
                       LET cred1700=cred1700+cuentas_aux;
                    END IF;
                END IF;

        END FOREACH;

       LET vproceso=8;

           BEGIN WORK;
                UPDATE bdicred:sd_repor_bnmex
                SET tdeb7011bm=deb7011bm,
                    tdeb7011bm_m=deb7011bm_m,
                    tdeb7014=deb7014,
                    tdeb7014_m=deb7014_m,
                    tcred7011bm=cred7011bm,
                    tcred7011bm_m=cred7011bm_m,
                    tcred7014=cred7014,
                    tcred7014_m=cred7014_m,
                    tdeb1701=deb1701,
                    tcred1700=cred1700,
                    tproceso=vproceso
                WHERE fecha_fin=dFechaFin;
           COMMIT WORK;     
    END IF;
-------genera reporte de sis_pagos comisiones
    IF (select {+INDEX(bdicred:sd_sispagos_comisiones idx_sispagos_comisiones)} count(*) from bdicred:sd_sispagos_comisiones where fecha_fin=dFechaFin)=0 THEN
        INSERT INTO bdicred:sd_sispagos_comisiones(fecha_fin,fecha_generacion) VALUES(dFechaFin,today); 
    
        ---- 8003	Ingresos por reposición de plástico
        set isolation to dirty read;
        select {+INDEX(bdicheq:sc_movhis idx_sc_movhis8)} count(*),sum(monto_tot) INTO deb_cant_reposicion,deb_monto_reposicion
        from bdicheq:sc_movhis where empresa=pEmpresa and cuenta>0
        and fech_alt BETWEEN dFechaIni AND dFechaFin
        and transacc='3220';

        ---- 8005 Ingresos por cobro de intereses,8003 Ingresos por reposición de plástico
        set isolation to dirty read;
        select {+INDEX(sd_movhis inx_movhis)} sum(case when ((codigo_fun='605' and codigo_ref =2) or (codigo_fun in ('033','334','335','336','337') and codigo_ref in (3,5,9))) 
                   then monto else 0 end),
               sum(case when (codigo_fun in ('033','334','335','336','337') and codigo_ref in (6212,6213))
                   then monto else 0 end),
               sum(case when (codigo_fun in ('033','334','335','336','337') and codigo_ref in (6212,6213))
                   then 1 else 0 end),
               sum(case when (codigo_fun ='339' and codigo_ref =50 and folio_suc=(select folio_suc from bdicred:sd_movhis 
                                                                                  where empresa=pEmpresa and num_credito=a.num_credito and
                                                                                  codigo_fun ='002' and codigo_ref =30 and reversado='N'
                                                                                  and fecha_mov=a.fecha_mov and folio_suc=a.folio_suc))
                   then monto else 0 end),
               sum(case when (codigo_fun ='339' and codigo_ref =50 and folio_suc=(select folio_suc from bdicred:sd_movhis 
                                                                                  where empresa=pEmpresa and num_credito=a.num_credito and
                                                                                  codigo_fun ='002' and codigo_ref in (40,41,42) and reversado='N'
                                                                                  and fecha_mov=a.fecha_mov and folio_suc=a.folio_suc))
                   then monto else 0 end)
        into cobro_interes,cobro_reposicion,cantidad_reposicion,retiro_cpcp,retiro_cpca
        from bdicred:sd_movhis a 
        where empresa=pEmpresa 
        and fecha_mov BETWEEN dFechaIni AND dFechaFin
        ---and num_credito>0 and 
        and num_credito between '600000005089' and '660000000001' and
        ((codigo_fun='605' and codigo_ref=2) or 
         (codigo_fun in ('033','334','335','336','337') and codigo_ref in (3,5,9)) or
         (codigo_fun in ('033','334','335','336','337') and codigo_ref in (6212,6213)) or
         (codigo_fun ='339' and codigo_ref =50))
        and reversado='N';

        ---- 8100	Transferencias a cuentas de otro banco personas físicas
        set isolation to dirty read;

        select {+INDEX(bdicheq:sc_movhis idx_sc_movhis8)} sum(monto_tot) into transfer_otrobanco_fisica
        from bdicheq:sc_movhis where empresa=pEmpresa and cuenta>0
        and fech_alt BETWEEN dFechaIni AND dFechaFin
        and transacc in ('3236','3237');

           BEGIN WORK;
                UPDATE {+INDEX(bdicred:sd_sispagos_comisiones idx_sispagos_comisiones)} bdicred:sd_sispagos_comisiones
                SET deb_reposicion_plas_c=deb_cant_reposicion,
                    deb_reposicion_plas_m=deb_monto_reposicion,
                    cred_cobro_interes=cobro_interes,
                    cred_reposicion_plas_m=cobro_reposicion,
                    cred_reposicion_plas_c=cantidad_reposicion,
                    cred_retiro_cpcp =retiro_cpcp,
                    cred_retiro_cpca=retiro_cpca,
                    spei_otrobanco_fisica=transfer_otrobanco_fisica
                WHERE fecha_fin=dFechaFin;
           COMMIT WORK;
    END IF;

     RETURN cCodRet;
END;
END PROCEDURE;