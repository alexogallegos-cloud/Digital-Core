CREATE PROCEDURE "informix".sp_conscteing(cEmpresa CHAR(3),
                               cNumCte CHAR(20),
                               iNumIng SMALLINT)
    RETURNING CHAR(5) AS CodRetorno, SMALLINT AS SecIngresos, CHAR(1) AS TipoIngreso, CHAR(60) AS NombreEmpresa, CHAR(3) AS Puesto, CHAR(2) AS PuestoEspecial,
              DECIMAL(4,2) AS Antiguedad, CHAR(40) AS NombreDepto, CHAR(60) AS Jefe, MONEY(14,2) AS IngresoMensual, INTEGER AS ClavePto,
	      INTEGER AS ClaveOpcPto, INTEGER AS ClaveSubOpPto, INTEGER AS SistCotiza, INTEGER AS NumEmpleados, INTEGER AS Pereosidad, INTEGER AS TipoIngExt;

DEFINE cCodRet 		CHAR(5);
DEFINE sCiclo 		SMALLINT;
DEFINE iSqlErr 		INTEGER;

DEFINE sSecIngreso 	SMALLINT;
DEFINE cTipoIngreso    CHAR(1);
DEFINE cNomEmpresa 	CHAR(60);
DEFINE cPuesto 		CHAR(3);
DEFINE cPuestoEsp 	CHAR(2);
DEFINE dcAntiguedad     DECIMAL(4,2);
DEFINE cNombreDepto     CHAR(40);
DEFINE cJefeInmedto     CHAR(60);
DEFINE mIngMensual 	MONEY(14,2);
DEFINE iCvePto		INTEGER;
DEFINE iCveOpcPto	INTEGER;
DEFINE iCveSubOpPto     INTEGER;
DEFINE iSistCotiza      INTEGER;
DEFINE iNumEmpLab       INTEGER;
DEFINE iPeriosidad      INTEGER;
DEFINE iTipoIngExt      INTEGER;

LET sCiclo = 0;
LET cCodRet = "000";
LET iSqlErr = 0;

LET sSecIngreso = 0;
LET cTipoIngreso = "";
LET cNomEmpresa = "";
LET cPuesto = "";
LET cPuestoEsp = "";
LET dcAntiguedad = 0;
LET cNombreDepto = "";
LET cJefeInmedto = "";
LET mIngMensual = 0;
LET iCvePto		= 0;
LET iCveOpcPto	= 0;
LET iCveSubOpPto = 0;
LET iSistCotiza  = 0;
LET iNumEmpLab   = 0;
LET iPeriosidad  = 0;
LET iTipoIngExt  = 0;

--SET DEBUG FILE TO '/tmp/sp_conscteing.out';
--TRACE ON;

BEGIN
    ON EXCEPTION SET iSqlErr
      IF iSqlErr <> 0 THEN
         LET cCodRet = iSqlErr;
         RETURN cCodRet, sSecIngreso, cTipoIngreso, cNomEmpresa, cPuesto, cPuestoEsp,
                dcAntiguedad, cNombreDepto, cJefeInmedto, mIngMensual, iCvePto, iCveOpcPto,
				iCveSubOpPto, iSistCotiza, iNumEmpLab, iPeriosidad, iTipoIngExt;
      END IF;
    END EXCEPTION;

    FOREACH

		SELECT sec_ingreso, tipo_ingreso, nombre_empresa, puesto, puesto_esp,
               antiguedad, nombre_depto, jefe_inmediato, ingreso_mensual, clavepuesto, claveopcionpuesto,
			   clavesubopcionpuesto, sis_cotiza, num_emp_lab, periosidad, tipo_ingreso_ext
        INTO   sSecIngreso, cTipoIngreso, cNomEmpresa, cPuesto, cPuestoEsp,
               dcAntiguedad, cNombreDepto, cJefeInmedto, mIngMensual, iCvePto, iCveOpcPto,
			   iCveSubOpPto, iSistCotiza, iNumEmpLab, iPeriosidad, iTipoIngExt
        FROM si_ingresos
        WHERE numcte = cNumCte
        ORDER BY sec_ingreso

		LET sCiclo = sCiclo+1;

		IF sCiclo <= iNumIng THEN
			CONTINUE FOREACH;
		END IF

         RETURN cCodRet, NVL(sSecIngreso, 0), NVL(cTipoIngreso, ''), NVL(cNomEmpresa, ''), NVL(cPuesto, ''), NVL(cPuestoEsp, ''),
                NVL(dcAntiguedad, 0), NVL(cNombreDepto, ''), NVL(cJefeInmedto, ''), NVL(mIngMensual, 0), NVL(iCvePto, 0), NVL(iCveOpcPto, 0),
				NVL(iCveSubOpPto, 0), NVL(iSistCotiza, 0), NVL(iNumEmpLab, 0), NVL(iPeriosidad, 0), NVL(iTipoIngExt, 0) WITH RESUME;

    END FOREACH;

END

END PROCEDURE;