CREATE PROCEDURE "informix".sp_consultarfacturacionos (pEmpresa CHAR(3),
                                            pSucursal CHAR(4),
                                            pNumCte CHAR(9),
                                            cFechaIni CHAR(10),
                                            cFechaFin CHAR(10),
                                            pTipoFecha SMALLINT,
                                            pTipoConsulta SMALLINT)
RETURNING  CHAR(6), CHAR(4),INTEGER,
            INTEGER, DECIMAL(5,2),
            INTEGER, DECIMAL(5,2),
            INTEGER, DECIMAL(5,2),
            INTEGER, DECIMAL(5,2),
            INTEGER, DECIMAL(5,2),
            INTEGER, DECIMAL(5,2);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);

DEFINE cSucursal                        CHAR (4);
DEFINE iTotalEnviadas                   INTEGER;
DEFINE iImpresas                        INTEGER;
DEFINE dImpresasPor                     DECIMAL(5,2);
DEFINE iNoImpresas                      INTEGER;
DEFINE dNoImpresasPor                   DECIMAL(5,2);
DEFINE iStatusA                         INTEGER;
DEFINE dStatusAPor                      DECIMAL(5,2);
DEFINE iStatusR                         INTEGER;
DEFINE dStatusRPor                      DECIMAL(5,2);
DEFINE iStatusD                         INTEGER;
DEFINE dStatusDPor                      DECIMAL(5,2);
DEFINE iStatusS                         INTEGER;
DEFINE dStatusSPor                      DECIMAL(5,2);
DEFINE pFechaIni                        DATE;
DEFINE pFechaFin                        DATE;
DEFINE iRegistros						INTEGER;
---------------

LET sql_err 			                = 0;
LET error_info		                    = "";
LET cCod_ret                            = "";

LET cSucursal                           = "";
LET iTotalEnviadas                      = 0;
LET iImpresas                           = 0;
LET dImpresasPor                        = 0;
LET iNoImpresas                         = 0;
LET dNoImpresasPor                      = 0;
LET iStatusA                            = 0;
LET dStatusAPor                         = 0;
LET iStatusR                            = 0;
LET dStatusRPor                         = 0;
LET iStatusD                            = 0;
LET dStatusDPor                         = 0;
LET iStatusS                            = 0;
LET dStatusSPor                         = 0;
LET pFechaIni                           = DATE(1);
LET pFechaFin                           = DATE(1);
LET iRegistros						    = 0;

-- Creado: Bernardo Carlos Báez González
-- Fecha: 11 de  enero de 2010
-- Se crea con el objetivo de obtener El total y el detalle de las ordenes de supervicion
-- modifico: Jesús Manuel Aguilar Heredia
-- Fecha: 02 de junio de 2010
-- se modifico  para que los tipos de consulta  1 y 2  se maneje por rango de fechas

LET cCod_ret = '00000';
LET sql_err = 0;


      BEGIN

        ON EXCEPTION SET sql_err
	        LET cCod_ret = sql_err;

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0);
	    END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/paulq/sp_ConsultarFacturacionOS.out";
--TRACE ON;

LET pFechaIni      = MDY (SUBSTR(cFechaIni,6,2),SUBSTR(cFechaIni,9,2),SUBSTR(cFechaIni,1,4));
LET pFechaFin      = MDY (SUBSTR(cFechaFin,6,2),SUBSTR(cFechaFin,9,2),SUBSTR(cFechaFin,1,4));

IF pTipoConsulta NOT IN (1, 2, 3) THEN

	LET cCod_ret = '00001';

    RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
		NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0);

ELIF pTipoConsulta = 1 THEN
	IF pSucursal <> "" AND pSucursal IS NOT NULL THEN

		FOREACH
	        SELECT a.sucursal,
	            COUNT(*),
	            SUM(CASE WHEN b.fechaimpresion <> DATE(1) THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.fechaimpresion = DATE(1) THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'A' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'R' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'D' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = '' THEN 1 ELSE 0 END)
	            INTO cSucursal, iTotalEnviadas, iImpresas, iNoImpresas, iStatusA, iStatusR, iStatusD, iStatusS
	            FROM bdisolic:ss_solicitudes a, bdisolic:ss_osclientesupervisar b
	            WHERE a.num_solicitud = b.num_solicitud
	            AND a.sucursal = pSucursal
				AND (DATE(b.fechamovto) BETWEEN pFechaIni AND pFechaFin
	                    OR fechaimpresion BETWEEN pFechaIni AND pFechaFin
	                    OR fecharespuesta BETWEEN pFechaIni AND pFechaFin)
	            GROUP BY 1

	            LET dImpresasPor = iImpresas / iTotalEnviadas * 100;
	            LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;
	            LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
	            LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
	            LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
	            LET dStatusSPor = iStatusS / iTotalEnviadas * 100;

	            RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
					NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0) WITH RESUME;
	    END FOREACH;
	ELSE
		LET cCod_ret = '00002';

	    RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
			NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0);
	END IF;
ELIF pTipoConsulta = 2 THEN
	IF pNumCte <> "" AND pNumCte IS NOT NULL THEN
	    FOREACH
	        SELECT a.sucursal, COUNT(*),
	            SUM(CASE WHEN b.fechaimpresion <> '01-01-1900' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.fechaimpresion = '01-01-1900' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'A' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'R' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'D' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = '' THEN 1 ELSE 0 END)
	            INTO cSucursal, iTotalEnviadas, iImpresas, iNoImpresas, iStatusA, iStatusR, iStatusD, iStatusS
	            FROM bdisolic:ss_solicitudes a, bdisolic:ss_osclientesupervisar b
	            WHERE a.num_solicitud = b.num_solicitud
	            AND a.numcte = pNumCte
				AND (DATE(b.fechamovto) BETWEEN pFechaIni AND pFechaFin
	                    OR fechaimpresion BETWEEN pFechaIni AND pFechaFin
	                    OR fecharespuesta BETWEEN pFechaIni AND pFechaFin)
	            GROUP BY 1

	            LET dImpresasPor = iImpresas / iTotalEnviadas * 100;
	            LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;
	            LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
	            LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
	            LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
	            LET dStatusSPor = iStatusS / iTotalEnviadas * 100;

	            RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
					NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0) WITH RESUME;
	    END FOREACH;
	ELSE
		LET cCod_ret = '00003';

	    RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
			NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0);
	END IF;
ELIF pTipoConsulta = 3 THEN

    IF pTipoFecha NOT IN (1,2,3,4) THEN

		LET cCod_ret = '00004';

		RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
			NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0);

    ELIF pTipoFecha = 1 THEN
		IF pFechaIni <= pFechaFin AND pFechaIni IS NOT NULL AND pFechaFin IS NOT NULL THEN
	        FOREACH
	        SELECT a.sucursal, COUNT(*),
	            SUM(CASE WHEN b.fechaimpresion <> DATE(1) THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.fechaimpresion = DATE(1) THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'A' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'R' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'D' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = '' THEN 1 ELSE 0 END)
	            INTO cSucursal, iTotalEnviadas, iImpresas, iNoImpresas, iStatusA, iStatusR, iStatusD, iStatusS
	            FROM bdisolic:ss_solicitudes a, bdisolic:ss_osclientesupervisar b
	            WHERE a.num_solicitud = b.num_solicitud
	            AND DATE(b.fechamovto) BETWEEN pFechaIni AND pFechaFin
	            GROUP BY 1

	            LET dImpresasPor = iImpresas / iTotalEnviadas * 100;
	            LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;
	            LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
	            LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
	            LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
	            LET dStatusSPor = iStatusS / iTotalEnviadas * 100;

	            RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
					NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0) WITH RESUME;
	        END FOREACH;
		ELSE
			LET cCod_ret = '00005';

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0);
		END IF;

    ELIF pTipoFecha = 2 THEN
		IF pFechaIni <= pFechaFin AND pFechaIni IS NOT NULL AND pFechaFin IS NOT NULL THEN
        FOREACH
	        SELECT a.sucursal, COUNT(*),
	            SUM(CASE WHEN b.clave = 'A' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'R' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'D' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = '' THEN 1 ELSE 0 END)
	            INTO cSucursal, iTotalEnviadas, iStatusA, iStatusR, iStatusD, iStatusS
	            FROM bdisolic:ss_solicitudes a, bdisolic:ss_osclientesupervisar b
	            WHERE a.num_solicitud = b.num_solicitud
	            AND fechaimpresion BETWEEN pFechaIni AND pFechaFin
	            GROUP BY 1

	            LET iImpresas = iTotalEnviadas;
	            LET dImpresasPor = iImpresas / iTotalEnviadas * 100;

	            LET iNoImpresas = 0;
	            LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;

	            LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
	            LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
	            LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
	            LET dStatusSPor = iStatusS / iTotalEnviadas * 100;

	            RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
					NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0) WITH RESUME;
	        END FOREACH;
		ELSE
			LET cCod_ret = '00005';

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0);
		END IF;
    ELIF pTipoFecha = 3 THEN
		IF pFechaIni <= pFechaFin AND pFechaIni IS NOT NULL AND pFechaFin IS NOT NULL THEN
	        FOREACH
	        SELECT a.sucursal, COUNT(*),
	            SUM(CASE WHEN b.clave = 'A' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'R' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'D' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = '' THEN 1 ELSE 0 END)
	            INTO cSucursal, iTotalEnviadas, iStatusA, iStatusR, iStatusD, iStatusS
	            FROM bdisolic:ss_solicitudes a, bdisolic:ss_osclientesupervisar b
	            WHERE a.num_solicitud = b.num_solicitud
	            AND fecharespuesta BETWEEN pFechaIni AND pFechaFin
	            GROUP BY 1

	            LET iImpresas = iTotalEnviadas;
	            LET dImpresasPor = iImpresas / iTotalEnviadas * 100;

	            LET iNoImpresas = 0;
	            LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;

	            LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
	            LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
	            LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
	            LET dStatusSPor = iStatusS / iTotalEnviadas * 100;

	            RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
					NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0) WITH RESUME;
	        END FOREACH;
		ELSE
			LET cCod_ret = '00005';

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0);
		END IF;
    ELIF pTipoFecha = 4 THEN
		IF pFechaIni <= pFechaFin AND pFechaIni IS NOT NULL AND pFechaFin IS NOT NULL THEN
	        FOREACH
	        SELECT a.sucursal, COUNT(*),
	            SUM(CASE WHEN b.fechaimpresion <> DATE(1) THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.fechaimpresion = DATE(1)THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'A' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'R' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = 'D' THEN 1 ELSE 0 END),
	            SUM(CASE WHEN b.clave = '' THEN 1 ELSE 0 END)
	            INTO cSucursal, iTotalEnviadas, iImpresas, iNoImpresas, iStatusA, iStatusR, iStatusD, iStatusS
	            FROM bdisolic:ss_solicitudes a, bdisolic:ss_osclientesupervisar b
	            WHERE a.num_solicitud = b.num_solicitud
	            AND (DATE(b.fechamovto) BETWEEN pFechaIni AND pFechaFin
	                    OR fechaimpresion BETWEEN pFechaIni AND pFechaFin
	                    OR fecharespuesta BETWEEN pFechaIni AND pFechaFin)
	            GROUP BY 1


	            LET dImpresasPor = iImpresas / iTotalEnviadas * 100;
	            LET dNoImpresasPor = iNoImpresas / iTotalEnviadas * 100;
	            LET dStatusAPor = iStatusA / iTotalEnviadas * 100;
	            LET dStatusRPor = iStatusR / iTotalEnviadas * 100;
	            LET dStatusDPor = iStatusD / iTotalEnviadas * 100;
	            LET dStatusSPor = iStatusS / iTotalEnviadas * 100;

	            RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
					NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0) WITH RESUME;
	        END FOREACH;
		ELSE
			LET cCod_ret = '00005';

			RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
				NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0);
		END IF;
    END IF;
END IF;
	LET iRegistros = DBINFO("sqlca.sqlerrd2");
	IF iRegistros = 0 THEN
		LET cCod_ret = '00006';

	    RETURN cCod_ret, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), NVL(iStatusR,0), NVL(dStatusRPor,0),
			NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0);
	END IF;

END;
END PROCEDURE;