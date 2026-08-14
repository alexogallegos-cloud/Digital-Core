CREATE PROCEDURE "informix".sp_replicarinformacionvisa()

returning
char (5),
char (50),
char(100);

--#################################################################################
--### Creado por: Jorge Nuñez
--##  Fecha: 08/07/2008
--##  Descripcion: Replica informacion mensualmente para el reporte trimestral de visa
--###################################################################################
--## Fecha: 05/08/2009
--## Modificó: Javier Chávez García
--## Modificación: Se incluye dia de ejecución en mi_param
--## Se incluye la consulta de número de sucursales activas.
--##################################################################################

DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;
DEFINE cVarDataErr      CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE dFechaHoy        DATETIME year to fraction(5);
DEFINE cDia             CHAR(2);
DEFINE cMes             CHAR(2);
DEFINE cDiaVisa         INTEGER;
DEFINE iMes             INTEGER;
DEFINE dFecha1          CHAR(50);
DEFINE dFechaConvert1   DATETIME year to fraction(5);
DEFINE dFechaConvert2   DATETIME year to fraction(5);
DEFINE dFecha2          DATETIME year to fraction(5);
DEFINE iMes1            INTEGER;
DEFINE cVarDataErr1     CHAR(100);
DEFINE cCodret1         CHAR(5);
DEFINE cError           CHAR(50);
DEFINE cod_ret          CHAR(5);
DEFINE cTrimestre       CHAR(5);
DEFINE cAnio            INTEGER;
DEFINE cNumProducto     CHAR(4);
DEFINE cTrimestreVer    CHAR(5);
DEFINE vNum_ofi         INTEGER;

DEFINE vsNumTarjeta CHAR (16);
DEFINE vsSecuencia CHAR (7);
DEFINE vmMonto MONEY (14,2);
DEFINE vsCodigoIso CHAR (2);
DEFINE vsCodtran CHAR (2);
DEFINE vsFormato CHAR (4);
DEFINE vsProdind CHAR (2);
DEFINE vsTrancajeropropio CHAR (1);
DEFINE vsEsNacional CHAR (1);
DEFINE dtFechaHoraInAuth DATETIME YEAR TO FRACTION (5);
DEFINE vsMesmov CHAR(2);
DEFINE vsBintar CHAR(1);
DEFINE vsDias CHAR(2);
DEFINE vsDias1 CHAR(2);
DEFINE viDia INTEGER;

DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;


  ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;

            RETURN cCodret, 'ERROR EN PROCESO', cVarDataErr;

        END IF;
  END EXCEPTION;

--Set debug file to "/ids_fc5/perifericos/visa1.txt";
--trace on;

LET vsNumTarjeta = '';
LET vsSecuencia = '';
LET vmMonto = 0.0;
LET vsCodigoIso = '';
LET vsCodtran = '';
LET vsFormato= '';
LET vsProdind = '';
LET vsTrancajeropropio = '';
LET vsEsNacional = '';
LET dtFechaHoraInAuth = CURRENT;
LET vsMesmov = '';
LET vsBintar = '';
LET vsDias = '';
LET vsDias1 = '';
LET viDia = 0;

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;
  
LET cCodret = '000';
LET cVarDataErr = '';
LET cCodret1 = '000';
LET cVarDataErr1 = '';
LET cError='PROCESO EXITOSO';

--Se obtiene la fecha a procesar
SELECT fecha_hoy
INTO dFechaHoy
FROM bdmis:mi_fechas
WHERE empresa='001';

SELECT parametro
INTO cDiaVisa
FROM bdmis:mi_param
WHERE descripcion='DIA VISA'
AND estatus='V';

--Se verifica que se el dia valido para ejecutarse
IF cDiaVisa = cast(DAY(dFechaHoy) as integer) THEN

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

	--Verifica que sea el tercer mes del trimestre para inicializar la tabla rpt_miembroprincipal
	IF iMes1 = 3 OR iMes1 = 6 OR iMes1 = 9 OR iMes1 = 12 THEN
        -- Obtiene el número de oficinas (sucursales)
        select count(a.sucursal) INTO vNum_ofi
        from bdinteg:si_sucursales a, intercard:sucursal b
        where empresa='001'
        AND a.sucursal =substr (b.clave_sucursal,2,4)
        AND b.enoperacion <> 'F';
		INSERT INTO bdireports:rpt_miembroprincipal(linea_ident,trimestre,num_identi,cod_pais,num_ofi,num_map,num_sucmap,num_atmplus,num_atmvisa,seg_rrcpcvisaemp,seg_rrcpc,prog_visaprem,
							ser_conse,mes1_porcpar,mes2_porcpar,mes3_porcpar,mes1_porcparcom,mes2_porcparcom,mes3_porcparcom)
		VALUES('MI',cTrimestre,'10061189','484',vNum_ofi,0,0,0,0,0,0,0,0,100,100,100,0,0,0);
	END IF
	--Verifica que el proceso no se haya ejecutado antes

	IF EXISTS (SELECT DISTINCT trimestre,mes FROM bdireports:rpt_volumetria WHERE mes = iMes1 AND trimestre = cTrimestre) THEN
		LET cCodret = '003';
		LET cVarDataErr = 'EL PROCESO PARA ESTE MES YA FUE EJECUTADO';
		RETURN cCodret,'',cVarDataErr;
	END IF

	--llama al proceso de debito
	EXECUTE PROCEDURE sp_replicainformacionvisadebito(dFechaConvert1,dFechaConvert2,cTrimestre,iMes1)
	INTO cCodret,cVarDataErr;
	
	IF cCodret = TRIM('000')  THEN
		LET cError = 'PROCESO EXITOSO';
	ELIF cCodret <> '000' THEN
		LET cError = 'FALLO REPLICACION DEBITO';
		RETURN cCodret,cError,cVarDataErr;
	END IF
	
	--llama al proceso de credito
	EXECUTE PROCEDURE sp_replicainformacionvisacredito(dFechaConvert1,dFechaConvert2,cTrimestre,iMes1)
	INTO cCodret1,cVarDataErr1;

	IF cCodret1 = TRIM('000')  THEN
		LET cError = 'PROCESO EXITOSO';
	ELIF cCodret1 <> '000' THEN
		LET cError = 'FALLO REPLICACION CREDITO';
		RETURN cCodret1,cError,cVarDataErr1;
	END IF
	


ELSE
	LET cod_ret = '002';
	LET cError = 'EL DIA NO CORRESPONDE CON EL DÍA DE EJECUCIÓN';
	RETURN cod_ret,'',cError;
END IF

RETURN cCodret1,cError,cVarDataErr1;

END PROCEDURE;