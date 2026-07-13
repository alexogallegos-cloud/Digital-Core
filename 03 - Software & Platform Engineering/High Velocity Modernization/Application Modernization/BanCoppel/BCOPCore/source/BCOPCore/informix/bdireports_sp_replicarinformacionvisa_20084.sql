CREATE PROCEDURE "informix".sp_replicarinformacionvisa_20084()

returning
char (3),
char(100);

--#################################################################################
--### Creado por: Jorge Nuñez
--##  Fecha: 08/07/2008
--##  Descripcion: Replica informacion mensualmente para el reporte trimestral de visa
--###################################################################################

DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;
DEFINE cVarDataErr      CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE dFechaHoy        DATETIME year to fraction(5);
DEFINE cDia             CHAR(2);
DEFINE cMes             CHAR(2);
DEFINE cDiaVisa         CHAR(2);
DEFINE iMes             INTEGER;
DEFINE dFecha1          CHAR(50);
DEFINE dFechaConvert1   DATETIME year to fraction(5);
DEFINE dFechaConvert2   DATETIME year to fraction(5);
DEFINE dFecha2          DATETIME year to fraction(5);
DEFINE iMes1            INTEGER;
DEFINE cVarDataErr1     CHAR(50);
DEFINE cCodret1         CHAR(5);
DEFINE cError           CHAR(50);
DEFINE cod_ret          CHAR(5);
DEFINE cTrimestre       CHAR(5);
DEFINE cAnio            INTEGER;
DEFINE cNumProducto     CHAR(4);
DEFINE cTrimestreVer    CHAR(5);

  ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
  END EXCEPTION;

 -- Set debug file to "/tmp/sp_Visainformacionvisa.out";
 -- trace on;

  LET cCodret = '000';
  LET cVarDataErr = '';

--Se obtiene la fecha a procesar

SELECT fecha_hoy,diavisa
INTO dFechaHoy,cDiaVisa
FROM bdmis:mi_fechas;

--Se verifica que se el dia valido para ejecutarse

IF cDiaVisa = DAY(dFechaHoy) THEN
	LET iMes = MONTH(dFechaHoy);
	LET cAnio = YEAR(dFechaHoy);
	IF iMes = 1 THEN
		LET cAnio = cANio -1;
		LET iMes1 = 12;
		LET dFecha1 = cAnio || '-' || iMes1 || '-' || '01' || ' 00:00:00.0';
		LET dFechaConvert1 = CAST (dFecha1 AS DATETIME year to fraction(5));
		LET dFecha2 = YEAR(dFechaHoy) || '-' || iMes || '-' || '01' || ' 00:00:00.0';
		LET dFechaConvert2 = CAST (dFecha2 AS DATETIME year to fraction(5));
	ELSE
    		LET iMes1 = iMes - 1;
		LET dFecha1 = YEAR(dFechaHoy) || '-' || iMes1 || '-' || '01' || ' 00:00:00.0';
		LET dFechaConvert1 = CAST (dFecha1 AS DATETIME year to fraction(5));
		LET dFecha2 = YEAR(dFechaHoy) || '-' || iMes || '-' || '01' || ' 00:00:00.0';
		LET dFechaConvert2 = CAST (dFecha2 AS DATETIME year to fraction(5));
	END IF

	--Saca el Trimestre

	IF iMes1 = 1 OR iMes1 = 2 OR iMes1 = 3 THEN
		LET cTrimestre = cAnio || '1';
	ELIF iMes1 = 4 OR iMes1 = 5 OR iMes1 = 6 THEN
		LET cTrimestre = cAnio || '2';
	ELIF iMes1 = 7 OR iMes1 = 8 OR iMes1 = 9 THEN
		LET cTrimestre = cAnio || '3';
	ELIF iMes1 = 10 OR iMes1 = 11 OR iMes1 = 12 THEN
		LET cTrimestre = cAnio || '4';
	END IF

--Verifica que sea el primer mes del trimestre para inicializar la tabla rpt_miembroprincipal

--	IF iMes1 = 1 OR iMes1 = 4 OR iMes1 = 7 OR iMes1 = 10 THEN
--		INSERT INTO bdireports:rpt_miembroprincipal(linea_ident,trimestre,num_identi,cod_pais,num_ofi,num_map,num_sucmap,num_atmplus,num_atmvisa,seg_rrcpcvisaemp,seg_rrcpc,prog_visaprem,
--							ser_conse,mes1_porcpar,mes2_porcpar,mes3_porcpar,mes1_porcparcom,mes2_porcparcom,mes3_porcparcom)
--		VALUES('MI',cTrimestre,'10061189','484',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
--	END IF

--Verifica que el proceso no se haya ejecutado antes

--	IF EXISTS (SELECT DISTINCT trimestre,mes FROM bdireports:rpt_volumetria WHERE mes = iMes1 AND trimestre = cTrimestre) THEN
		--LET cCodret = '003';
		--LET cVarDataErr = 'EL PROCESO PARA ESTE MES YA FUE EJECUTADO';
		--RETURN cCodret,cVarDataErr;
	--END IF

--llama al proceso de debito

	--EXECUTE PROCEDURE sp_replicainformacionvisadebito(dFechaConvert1,dFechaConvert2,cTrimestre,iMes1)
	--INTO cCodret,cVarDataErr;

--llama al proceso de credito

	EXECUTE PROCEDURE sp_replicainformacionvisacredito_20084(dFechaConvert1,dFechaConvert2,cTrimestre,iMes1)
	INTO cCodret1,cVarDataErr1;

--verifica errores

	IF cCodret = TRIM('000') AND cCodret1 = TRIM('000') THEN
		LET cod_ret = '000';
		LET cError = 'PROCESO EXITOSO';
		RETURN cod_ret,cError;
	ELIF cCodret <> '000' THEN
		LET cod_ret = '001';
		LET cError = 'FALLO REPLICACION DEBITO';
		RETURN cod_ret,cError WITH RESUME;
	ELIF cCodret1 <> '000' THEN
		LET cod_ret = '001';
		LET cError = 'FALLO REPLICACION CREDITO';
		RETURN cod_ret,cError WITH RESUME;
	END IF
ELSE
	LET cod_ret = '002';
	LET cError = 'EL DIA NO CORRESPONDE CON EL DÍA DE EJECUCIÓN';
	RETURN cod_ret,cError;
END IF
END PROCEDURE;