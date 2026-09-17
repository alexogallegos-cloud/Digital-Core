CREATE PROCEDURE "informix".sp_conssdoticket_web(cEmpresa  CHAR (3),CNumCredito CHAR (20), dFechaHoy Date)
  RETURNING CHAR (5) AS CodRet,
  DECIMAL(14,2)  AS SusCompras,
  DECIMAL(14,2)  AS Disposiciones,
  DECIMAL(14,2)  AS SusComisiones,
  DECIMAL(14,2)  AS Iva,
  DECIMAL (14,2) AS SusAbonos,
  DECIMAL(14,2)  AS dmorapagados,
  DECIMAL (14,2) AS divamorapagados,
  DECIMAL (14,2) AS interespagototaltc;

 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr SMALLINT;
DEFINE cCodRet CHAR(5);
DEFINE cCodRetOtro CHAR(5);
DEFINE dSusAbonos DECIMAL(14,2);
DEFINE dmorapagados DECIMAL(14,2);
DEFINE divamorapagados DECIMAL(14,2);
DEFINE dSusCompras DECIMAL(14,2);
DEFINE dSusComisiones DECIMAL(14,2);
DEFINE dDisposiciones DECIMAL(14,2);
DEFINE dIvaComisiones DECIMAL(14,2);
DEFINE dComisionesSbc DECIMAL(14,2);
DEFINE dIvaComisionesSbc DECIMAL(14,2);
DEFINE dComisRepos DECIMAL(14,2);
DEFINE dIva DECIMAL(14,2);
DEFINE dPeriodoIni DATE;
DEFINE dPeriodoFin DATE;
DEFINE dFechaCentral DATE;
DEFINE dPeriodoAnterior DATE;
DEFINE iDiasPeriodo INTEGER;
DEFINE cNumCre CHAR (20);
DEFINE dintpagtaltc DECIMAL (14,2);
DEFINE iDia_corte INTEGER;
---RGH
DEFINE dSusAbonos2 DECIMAL(14,2);
DEFINE dmorapagados2 DECIMAL(14,2);
DEFINE divamorapagados2 DECIMAL(14,2);
DEFINE dSusCompras2 DECIMAL(14,2);
DEFINE dSusComisiones2 DECIMAL(14,2);
DEFINE dDisposiciones2 DECIMAL(14,2);
DEFINE dIvaComisiones2 DECIMAL(14,2);
DEFINE dComisionesSbc2 DECIMAL(14,2);
DEFINE dIvaComisionesSbc2 DECIMAL(14,2);
DEFINE dComisRepos2 DECIMAL(14,2);
DEFINE dCrediSoluciones DECIMAL(14,2);
DEFINE dCrediSoluciones2 DECIMAL(14,2);								  
 -- INICIALIZACION DE VARIABLES --
LET sSqlErr = 0;
LET cCodRet = '00000';
LET cCodRetOtro = '000';
LET dSusAbonos = 0;
LET dmorapagados = 0;
LET divamorapagados = 0;
LET dSusCompras = 0;
LET dSusComisiones = 0;
LET dDisposiciones = 0;
LET dIvaComisiones = 0;
LET dComisionesSbc = 0;
LET dIvaComisionesSbc = 0;
LET dComisRepos = 0;
LET dIva = 0;
LET dPeriodoIni = '';
LET dPeriodoFin = '';
LET dFechaCentral = '';
LET dPeriodoAnterior = '';
LET iDiasPeriodo = 0;
LET cNumCre = '';
LET dintpagtaltc = 0;
LEt iDia_corte = 0;

--RGH

LET dSusAbonos2 = 0;
LET dmorapagados2 = 0;
LET divamorapagados2 = 0;
LET dSusCompras2 = 0;
LET dSusComisiones2 = 0;
LET dDisposiciones2 = 0;
LET dIvaComisiones2 = 0;
LET dComisionesSbc2 = 0;
LET dIvaComisionesSbc2 = 0;
LET dComisRepos2 = 0;

LET dCrediSoluciones = 0;
LET dCrediSoluciones2 = 0;						 
BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, dSusCompras, dDisposiciones, dSusComisiones , dIva, dSusAbonos, dmorapagados, divamorapagados, dintpagtaltc;
        END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

   SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy
     INTO dFechaCentral
     FROM bdicred:sd_fechas
   WHERE empresa = cEmpresa;

    SELECT dia_corte
    INTO iDia_corte
    FROM bdicred:sd_maecredanexo
    WHERE empresa = cEmpresa
        AND num_credito = cNumCredito;

   if day(dFechaCentral) <= iDia_corte then
      let dPeriodoIni = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral)) - 1 units month;
   else
      let dPeriodoIni = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral));
   end if;
	--IFRS Cambio de formula para el calculo a restar para cuando el crÃ©dito se encuentre en orden(vencido traspasado)
    select sdo_cap_insoluto +
           int_tra_no_exig -
		   case when NVL(int_tra_no_exig,0) > 0 then NVL(sdo_int_anticip,0) else 0 end +
           --case when NVL(monto_vencido+mto_venc_trasp,0) > 0 then sdo_int_anticip else 0 end +
            nvl((select campo_trabajo1
                   from bdicred:sd_amortiza_credito
                  where a.empresa = empresa
                    and a.num_credito = num_credito
                    and a.fecha = fecha_cuota),0)
    INTO dintpagtaltc
    from bdicred:sd_maesdoshist a
    where empresa = cEmpresa
    and num_credito = cNumCredito
    and fecha = (SELECT max(fecha)
                   FROM bdicred:sd_maesdoshist
                  where a.empresa = empresa
                    and a.num_credito = num_credito);

	IF dintpagtaltc IS NULL THEN
	   LET dintpagtaltc = 0;
	END IF;
--IFRS Se contemplan nuevos codigos Ref para identificar las nuevas transacciones creadas para IFRS
FOREACH	WITH HOLD

SELECT SUM(CASE WHEN codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END
	ELSE 0 END), --MENOS SUS ABONOS
	SUM(CASE WHEN codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref = 2 THEN monto ELSE 0 END
	ELSE 0 END), --Moratorios pagados
    	SUM(CASE WHEN codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref in (6616,6617) THEN monto ELSE 0 END
	ELSE 0 END), --Iva moratorios pagados
	SUM(CASE WHEN codigo_fun = '002' THEN
	CASE WHEN codigo_ref in(37,57,937,938) THEN monto ELSE 0 END
	ELSE 0 END),  --MAS SUS COMPRAS
	
	SUM(CASE WHEN codigo_fun in ('061','081') THEN
	CASE WHEN codigo_ref in(5,8,16) THEN monto ELSE 0 END
	ELSE 0 END),  --SUS CREDISOLUCIONES CARGADAS
	
	SUM(CASE WHEN codigo_fun = '339' THEN
		--CASE WHEN codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101) THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101,993,994,995,996) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END),  --MAS COMISIONES
	SUM(CASE WHEN codigo_fun = '002' THEN
		CASE WHEN codigo_ref IN (30,50,40,41,42,60,61,62,63,64,65) THEN monto ELSE 0 END 
	ELSE 0 END),   --MAS DISPOSICIONES EN EFECTIVO
	SUM(CASE WHEN codigo_fun = '340' THEN
		--CASE WHEN codigo_ref IN (1,2,27,30,31) THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref IN (1,2,27,30,31,901,902,903,904) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END),  --MAS IVA COMISIONES
	SUM(CASE WHEN codigo_fun = '336' THEN
	CASE WHEN codigo_ref = 23 THEN monto ELSE 0 END
	ELSE 0 END),  --MAS COMISIONES SBC
	SUM(CASE WHEN codigo_fun = '336' THEN
	CASE WHEN codigo_ref = 24 THEN monto ELSE 0 END
	ELSE 0 END),  --MAS IVA SBC
	SUM(CASE WHEN codigo_fun = '033' THEN
		--CASE WHEN codigo_ref = 6212 THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref in (6212,9090) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END)  --COMISION REPOSICION
	INTO dSusAbonos2,
	dmorapagados2,
	divamorapagados2,
	dSusCompras2,
	dCrediSoluciones2,
	dSusComisiones2,
	dDisposiciones2,
	dIvaComisiones2,
	dComisionesSbc2,
	dIvaComisionesSbc2,
	dComisRepos2
	FROM bdicred:sd_movdia
	WHERE empresa = cEmpresa
	AND num_credito = cNumCredito
	AND fecha_mov > dPeriodoIni
--	AND fecha_mov <= dPeriodoFin
	AND reversado = "N"

if dSusAbonos2 is null then let dSusAbonos2 = 0; end if;
if dmorapagados2 is null then let dmorapagados2 = 0; end if;
if divamorapagados2 is null then let divamorapagados2 = 0; end if;
if dSusCompras2 is null then let dSusCompras2 = 0; end if;
if dCrediSoluciones2 is null then let dCrediSoluciones2 = 0; end if;																
if dSusComisiones2 is null then let dSusComisiones2 = 0; end if;
if dDisposiciones2 is null then let dDisposiciones2 = 0; end if;
if dIvaComisiones2 is null then let dIvaComisiones2 = 0; end if;
if dComisionesSbc2 is null then let dComisionesSbc2 = 0; end if;
if dIvaComisionesSbc2 is null then let dIvaComisionesSbc2 = 0; end if;
if dComisRepos2 is null then let dComisRepos2 = 0; end if;

--IFRS Se contemplan nuevos codigos Ref para identificar las nuevas transacciones creadas para IFRS
SELECT SUM(CASE WHEN codigo_fun IN (select {+ INDEX (sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END
	ELSE 0 END), --MENOS SUS ABONOS
	SUM(CASE WHEN codigo_fun IN (select {+ INDEX (sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref = 2 THEN monto ELSE 0 END
	ELSE 0 END),--Moratorios pagados
    	SUM(CASE WHEN codigo_fun IN (select {+ INDEX (sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref in (6616,6617) THEN monto ELSE 0 END
	ELSE 0 END), --Iva moratorios pagados
	SUM(CASE WHEN codigo_fun = '002' THEN
	CASE WHEN codigo_ref in(37,57,937,938) THEN monto ELSE 0 END
	ELSE 0 END),  --MAS SUS COMPRAS
	
	SUM(CASE WHEN codigo_fun in ('061','081') THEN
	CASE WHEN codigo_ref in(5,8,16) THEN monto ELSE 0 END
	ELSE 0 END),  --SUS CREDISOLUCIONES CARGADAS
	
	SUM(CASE WHEN codigo_fun = '339' THEN
		--CASE WHEN codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101) THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101,993,994,995,996) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END),  --MAS COMISIONES
	SUM(CASE WHEN codigo_fun = '002' THEN
		CASE WHEN codigo_ref IN (30,50,40,41,42,60,61,62,63,64,65) THEN monto ELSE 0 END 
	ELSE 0 END),   --MAS DISPOSICIONES EN EFECTIVO
	SUM(CASE WHEN codigo_fun = '340' THEN
		--CASE WHEN codigo_ref IN (1,2,27,30,31) THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref IN (1,2,27,30,31,901,902,903,904) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END),  --MAS IVA COMISIONES
	SUM(CASE WHEN codigo_fun = '336' THEN
	CASE WHEN codigo_ref = 23 THEN monto ELSE 0 END
	ELSE 0 END),  --MAS COMISIONES SBC
	SUM(CASE WHEN codigo_fun = '336' THEN
	CASE WHEN codigo_ref = 24 THEN monto ELSE 0 END
	ELSE 0 END),  --MAS IVA SBC
	SUM(CASE WHEN codigo_fun = '033' THEN
		--CASE WHEN codigo_ref = 6212 THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref in (6212,9090) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END)  --COMISION REPOSICION
INTO 	dSusAbonos,
	dmorapagados,
	divamorapagados,
	dSusCompras,
	dCrediSoluciones,			  
	dSusComisiones,
	dDisposiciones,
	dIvaComisiones,
	dComisionesSbc,
	dIvaComisionesSbc,
	dComisRepos
FROM bdicred:sd_movhis
WHERE empresa = cEmpresa
	AND num_credito = cNumCredito
	AND fecha_mov > dPeriodoIni
--	AND fecha_mov <= dPeriodoFin
	AND reversado = "N";

if dSusAbonos is null then let dSusAbonos = 0; end if;
if dmorapagados is null then let dmorapagados = 0; end if;
if divamorapagados is null then let divamorapagados = 0; end if;
if dSusCompras is null then let dSusCompras = 0; end if;
if dCrediSoluciones is null then let dCrediSoluciones = 0; end if;																  
if dSusComisiones is null then let dSusComisiones = 0; end if;
if dDisposiciones is null then let dDisposiciones = 0; end if;
if dIvaComisiones is null then let dIvaComisiones = 0; end if;
if dComisionesSbc is null then let dComisionesSbc = 0; end if;
if dIvaComisionesSbc is null then let dIvaComisionesSbc = 0; end if;
if dComisRepos is null then let dComisRepos = 0; end if;

	LET dSusAbonos = dSusAbonos + dSusAbonos2;
	LET dmorapagados = dmorapagados + dmorapagados2;
	LET divamorapagados = divamorapagados + divamorapagados2;
	--	LET dSusCompras = dSusCompras + dSusCompras2;

	LET dSusCompras = dSusCompras + dSusCompras2 + dCrediSoluciones + dCrediSoluciones2;
	LET dSusComisiones = dSusComisiones + dSusComisiones2;
	LET dDisposiciones = dDisposiciones + dDisposiciones2;
	LET dIvaComisiones = dIvaComisiones + dIvaComisiones2;
	LET dComisionesSbc = dComisionesSbc + dComisionesSbc2;
	LET dIvaComisionesSbc = dIvaComisionesSbc + dIvaComisionesSbc2;
	LET dComisRepos = dComisRepos + dComisRepos2;

	LET dSusComisiones = NVL(dSusComisiones, 0) + NVL(dComisionesSbc, 0) + NVL(dComisRepos, 0);
	LET dIva = NVL(dIvaComisiones, 0) + NVL(dIvaComisionesSbc, 0);

IF dSusCompras IS NULL AND dDisposiciones IS NULL AND dSusAbonos IS NULL THEN
	LET dSusAbonos = 0;
	LET dSusCompras = 0;
	LET dDisposiciones = 0;
END IF;

RETURN cCodRet, dSusCompras, dDisposiciones, dSusComisiones , dIva, dSusAbonos, dmorapagados,
	divamorapagados, dintpagtaltc WITH RESUME;

End FOREACH;

END;
END PROCEDURE;