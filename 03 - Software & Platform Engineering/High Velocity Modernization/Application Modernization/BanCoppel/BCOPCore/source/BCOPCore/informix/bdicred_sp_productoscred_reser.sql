CREATE PROCEDURE "informix".sp_productoscred_reser (pEmpresa CHAR(3), p_num_producto VARCHAR(4) )
RETURNING 	CHAR(6) AS Codigo,       --Codigo de Retorno
			CHAR(4) AS NumProducto,  --Número de Producto
			CHAR(40) AS Descripcion, --Descripción del Producto
			CHAR(4) AS AnioMin; -- Año minimo de la Fecha de cierre
						
--Declaracion de variables
------------------------------------------------------------
DEFINE cCodRet      CHAR(6); 
DEFINE iSqlErr 		INTEGER;
DEFINE cNumProducto CHAR(4);
DEFINE cNomProducto CHAR(40);
DEFINE cActivaCalif CHAR(1);
DEFINE nRows 		INTEGER;
DEFINE cAnioMin     CHAR(4);

--Incialización de variables
------------------------------------------------------------

LET cCodRet='000000';
LET iSqlErr=0;
LET cNumProducto =0;
LET cNomProducto ='';
LET cActivaCalif=0;
LET nRows=0;
LET cAnioMin='';

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cNomProducto='Error de Informix';
			RETURN cCodRet,cNumProducto,cNomProducto,cAnioMin;
		END EXCEPTION;	
		
		--SET DEBUG FILE TO "/respaldosbd/Malena/sp_productoscred_reser.out";
		--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet='000001';
			LET cNomProducto='Debe proporcionar una empresa';
		ELSE	
			SELECT LPAD(YEAR(MIN(fecha_cierre)),4,0)
			INTO cAnioMin
			FROM bdicred:"informix".sd_reporte_calificacion;			
				FOREACH
						SELECT NVL(num_producto,''), NVL(nombre_prod,''), NVL(activa_calif,'') 
						INTO cNumProducto, cNomProducto, cActivaCalif
						FROM bdicred:"informix".sd_definicion 
						WHERE empresa=pEmpresa					
						AND num_producto = (CASE WHEN p_num_producto ='' THEN num_producto ELSE p_num_producto END)
						ORDER BY num_producto
							IF cActivaCalif<>1 AND p_num_producto <> "" THEN 
								LET cCodRet='000002';
								LET cNomProducto='Este producto no esta disponible';
							ELSE 
								RETURN cCodRet,cNumProducto,cNomProducto,cAnioMin WITH RESUME;
							END IF													
				END FOREACH;	
			LET nRows = DBINFO("sqlca.sqlerrd2");
			IF nRows=0 THEN
				LET cCodRet='000003';
				LET cNomProducto='No se obtuvo información de productos';							
			END IF;	
		END IF;
		IF cCodRet <> '000000' THEN 
			RETURN cCodRet,cNumProducto,cNomProducto,cAnioMin;
		END IF;
END;
END PROCEDURE

DOCUMENT
'AUTOR: MARIA ELENA ANGULO AISPURO',
'DESCRIPCION: Se realiza procedimiento para obtener los productos de crédito ordenados que se mostrarán en la pantalla de histórico de reservas, además de  validar si un producto', 
'recibido se encuentre disponible para consultarle su histórico de reservas, ademas se anexa un retorno para obtener el año minimo de la fecha de cierre.',
'BD: BDICRED',
'VERSION: 20110406.0950';

CREATE PROCEDURE "informix".sp_consulta_reporte_calificacion(pEmpresa  	CHAR(3),
																   pProducto   	CHAR(4),
																   pMes         INTEGER,
																   pAnio        INTEGER)

RETURNING   CHAR(6)			 AS cod_ret,
			CHAR(100)      	 AS mensaje_ret,
			CHAR(20)       	 AS grado_riesgo ,
			CHAR(20)       	 AS total_creditos_grado,
			DECIMAL(18,2)   AS saldo_cierre,
			DECIMAL(18,2)   AS reserva_calificacion,
			DECIMAL(18,2)   AS reserva_calif_gradual,
			DECIMAL(18,2)   AS reserva_buro,
			DECIMAL(18,2)   AS reserva_interes,
			DECIMAL(18,2)   AS total_reserva,
			DECIMAL(18,2)   AS sdo_interes_cred_vdos,
			CHAR(20)       	 AS total_ctes_sdo_favor,
			DECIMAL(18,2)  	 AS sdo_cierre_ctes_saldo_favor,
			DECIMAL(18,2)   AS reserva_ctes_sdo_favor,
			CHAR(20)        AS total_ctes_inactivos,
			DECIMAL(18,2)   AS saldo_cierre_ctes_inactivos,
			DECIMAL(18,2)   AS reserva_ctes_inactivos,
			CHAR(20)        AS total_ctes_totaleros,
			DECIMAL(18,2)   AS saldo_cierre_ctes_totaleros


DEFINE iSqlErr      	     		INTEGER;
DEFINE iIsamErr            			INTEGER;
DEFINE cErrorInfo          			CHAR(80);
DEFINE cCodRet            			CHAR(6);
DEFINE cMensajeRet    				CHAR(80);

DEFINE cGradoRiesgo                 CHAR(20);
DEFINE dPorcReserMin                DECIMAL(5,2);
DEFINE dPorcReserMax                DECIMAL(5,2);
DEFINE cNumCreditos                 CHAR(20);
DEFINE dSaldoCierre                 DECIMAL(18,2);

DEFINE dReserCalif                  DECIMAL(18,2);
DEFINE dReserCalifGrad              DECIMAL(18,2);
DEFINE dReserBuro                   DECIMAL(18,2);
DEFINE dReserInt                    DECIMAL(18,2);
DEFINE dTotalReser                  DECIMAL(18,2);

DEFINE dSdoIntsCredVdos             DECIMAL(18,2);
DEFINE cTotalCtesSdoFavor           CHAR(20);
DEFINE dSdoCierreCtesSdoFavor     	DECIMAL(18,2);
DEFINE dReserCtesSdoFavor           DECIMAL(18,2);
DEFINE cCtesInactivos               CHAR(20);

DEFINE dSdoCierreCtesInactivos      DECIMAL(18,2);
DEFINE dReserCtesInactivos          DECIMAL(18,2);
DEFINE cCtesTotaleros               CHAR(20);
DEFINE dSdoCierreCtesTotaleros      DECIMAL(18,2);
DEFINE cMesPeriodo                  CHAR(2);

DEFINE cAnioPeriodo                 CHAR(4);
DEFINE cRiesgoAux                   CHAR(2);
DEFINE sBandTemp                    SMALLINT;
DEFINE sBand_totales				SMALLINT;


LET iSqlErr                 = 0;
LET iIsamErr              	= 0;
LET cErrorInfo            	= "";
LET cCodRet              	= "000000";
LET cMensajeRet      		= "Proceso realizado correctamente.";

LET cGradoRiesgo            = "";
LET dPorcReserMin           = 0;
LET dPorcReserMax           = 0;
LET cNumCreditos            = "";
LET dSaldoCierre            = 0;

LET dReserCalif             = 0;
LET dReserCalifGrad         = 0;
LET dReserBuro              = 0;
LET dReserInt               = 0;
LET dTotalReser             = 0;

LET dSdoIntsCredVdos        = 0;
LET cTotalCtesSdoFavor      = 0;
LET dSdoCierreCtesSdoFavor  = 0;
LET dReserCtesSdoFavor      = 0;
LET cCtesInactivos          = 0;

LET dSdoCierreCtesInactivos = 0;
LET dReserCtesInactivos     = 0;
LET cCtesTotaleros          = 0;
LET dSdoCierreCtesTotaleros = 0;
LET cMesPeriodo             = "";

LET cAnioPeriodo            = "";
LET cRiesgoAux              = "";
LET sBandTemp               = 0;
LET sBand_totales			= 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      IF sBandTemp = 1 THEN
            DROP TABLE tmp_sdo_ret_totales;
      END IF;
      RETURN cCodRet, cMensajeRet, cGradoRiesgo, cNumCreditos,dSaldoCierre, dReserCalif, dReserCalifGrad, dReserBuro, dReserInt, dTotalReser,
                        dSdoIntsCredVdos, cTotalCtesSdoFavor, dSdoCierreCtesSdoFavor, dReserCtesSdoFavor, cCtesInactivos, dSdoCierreCtesInactivos,
                        dReserCtesInactivos, cCtesTotaleros, dSdoCierreCtesTotaleros;
END EXCEPTION;

            --SET DEBUG FILE TO "/respaldosbd/viridiana/sp_consulta_reporte_calificacion.out";
            --TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF NVL(pempresa,"") = "" OR NVL(pMes,0) = 0  OR NVL(pAnio,0) = 0 THEN
    LET cCodRet = "000001";
    LET cMensajeRet = "No se han proporcionado correctamente los datos de entrada.";
	RETURN NVL(cCodRet,""), NVL(cMensajeRet,""),NVL( cGradoRiesgo,""), NVL(cNumCreditos,""),NVL(dSaldoCierre,0),
					NVL(dReserCalif,0), NVL(dReserCalifGrad,0), NVL(dReserBuro,0), NVL(dReserInt,0), NVL(dTotalReser,0),
					NVL(dSdoIntsCredVdos,0), NVL(cTotalCtesSdoFavor,""), NVL(dSdoCierreCtesSdoFavor,0), NVL(dReserCtesSdoFavor,0),
					NVL(cCtesInactivos,""), NVL(dSdoCierreCtesInactivos,0), NVL(dReserCtesInactivos,0), NVL(cCtesTotaleros,""),
					NVL(dSdoCierreCtesTotaleros,0);
END IF;

IF NOT EXISTS(SELECT empresa FROM bdinteg:si_empresas WHERE empresa = pEmpresa) THEN
        LET cCodRet = "000002";
        LET cMensajeRet = "La empresa proporcionada no existe.";
        RETURN NVL(cCodRet,""), NVL(cMensajeRet,""),NVL( cGradoRiesgo,""), NVL(cNumCreditos,""),NVL(dSaldoCierre,0),
                        NVL(dReserCalif,0), NVL(dReserCalifGrad,0), NVL(dReserBuro,0), NVL(dReserInt,0), NVL(dTotalReser,0),
                        NVL(dSdoIntsCredVdos,0), NVL(cTotalCtesSdoFavor,""), NVL(dSdoCierreCtesSdoFavor,0), NVL(dReserCtesSdoFavor,0),
                        NVL(cCtesInactivos,""), NVL(dSdoCierreCtesInactivos,0), NVL(dReserCtesInactivos,0), NVL(cCtesTotaleros,""),
                        NVL(dSdoCierreCtesTotaleros,0);
END IF;

LET cMesPeriodo    = LPAD(pMes, 2, 0);
LET cAnioPeriodo   = LPAD(pAnio, 4,0);

IF EXISTS(SELECT tabname FROM sysmaster:systabnames where tabname = 'tmpConsMonitor') THEN
        DROP TABLE tmp_sdo_ret_totales;
END IF;

                CREATE temp table tmp_sdo_ret_totales
                (
					grado_riesgo					CHAR(20),
					num_creditos                    INTEGER,
					saldo_cierre                    DECIMAL(18,2),
					reserva_calif                   DECIMAL(18,2),
					reserva_calif_gradual           DECIMAL(18,2),
					reserva_buro                    DECIMAL(18,2),
					reserva_interes                 DECIMAL(18,2),
					total_reserva                   DECIMAL(18,2),
					saldo_ints_cred_vdos            DECIMAL(18,2),
					num_clientes_saldo_favor        INTEGER,
					saldo_cierre_ctes_saldo_favor   DECIMAL(18,2),
					reserva_ctes_sdo_favor          DECIMAL(18,2),
					num_clientes_inactivos          INTEGER,
					saldo_cierre_ctes_inactivos     DECIMAL(18,2),
					reserva_ctes_inactivos          DECIMAL(18,2),
					numero_clientes_totaleros       INTEGER,
					saldo_cierre_ctes_totaleros     DECIMAL(18,2),
					bandera_totales					SMALLINT
                );

LET sBandTemp = 1;

            FOREACH
					SELECT grado_riesgo,
							porcentaje_reserva_min,
							porcentaje_reserva_max,
							num_creditos,
							saldo_cierre,
							reserva_calif,
							reserva_calif_gradual,
							reserva_buro,
							reserva_interes,
							total_reserva,
							saldo_ints_cred_vdos,
							num_clientes_saldo_favor,
							saldo_cierre_ctes_saldo_favor,
							reserva_ctes_sdo_favor,
							num_clientes_inactivos,
							saldo_cierre_ctes_inactivos,
							reserva_ctes_inactivos,
							numero_clientes_totaleros,
							saldo_cierre_ctes_totaleros
					  INTO cGradoRiesgo,
							dPorcReserMin,
							dPorcReserMax,
							cNumCreditos,
							dSaldoCierre,
							dReserCalif,
							dReserCalifGrad,
							dReserBuro,
							dReserInt,
							dTotalReser,
							dSdoIntsCredVdos,
							cTotalCtesSdoFavor,
							dSdoCierreCtesSdoFavor,
							dReserCtesSdoFavor,
							cCtesInactivos,
							dSdoCierreCtesInactivos,
							dReserCtesInactivos,
							cCtesTotaleros,
							dSdoCierreCtesTotaleros
					 FROM bdicred:sd_reporte_calificacion
				   WHERE producto = pProducto
					  AND month(fecha_cierre) = cMesPeriodo
					  AND year(fecha_cierre)   = cAnioPeriodo
				ORDER BY grado_riesgo, porcentaje_reserva_min

                   IF cRiesgoAux <> cGradoRiesgo THEN
                       LET cRiesgoAux = cGradoRiesgo;
					   LET sBand_totales=1;
					   
						 INSERT INTO tmp_sdo_ret_totales
							   SELECT grado_riesgo, sum(num_creditos::int), sum(saldo_cierre), sum(reserva_calif), sum(reserva_calif_gradual), sum(reserva_buro),
										sum(reserva_interes), sum(total_reserva), sum(saldo_ints_cred_vdos), sum(num_clientes_saldo_favor::int),sum(saldo_cierre_ctes_saldo_favor),
										sum(reserva_ctes_sdo_favor), sum(num_clientes_inactivos::int), sum(saldo_cierre_ctes_inactivos),sum(reserva_ctes_inactivos),
										sum(numero_clientes_totaleros::int), sum(saldo_cierre_ctes_totaleros),sBand_totales
								FROM bdicred:sd_reporte_calificacion 
							  WHERE grado_riesgo=cGradoRiesgo 
								 AND month(fecha_cierre) = cMesPeriodo
								 AND year(fecha_cierre)  = cAnioPeriodo
							   GROUP BY grado_riesgo;
								
							LET sBand_totales=0;
                   END IF;
				   
				   IF cGradoRiesgo='B1' AND dPorcReserMin='2.68' AND dPorcReserMax='2.68' THEN
						LET cGradoRiesgo = "INACT-B1";
				   ELSE
						LET cGradoRiesgo = "De" ||" "|| dPorcReserMin ||" "|| "A" ||" "||dPorcReserMax;
				   END IF;
				   
                   INSERT INTO tmp_sdo_ret_totales
                        VALUES (cGradoRiesgo,cNumCreditos,dSaldoCierre, dReserCalif, dReserCalifGrad, dReserBuro, dReserInt, dTotalReser,
                                 dSdoIntsCredVdos, cTotalCtesSdoFavor, dSdoCierreCtesSdoFavor, dReserCtesSdoFavor, cCtesInactivos, dSdoCierreCtesInactivos,
                                 dReserCtesInactivos, cCtesTotaleros, dSdoCierreCtesTotaleros,sBand_totales);
            END FOREACH;

IF dbinfo("sqlca.sqlerrd2") = 0 THEN

        LET cCodRet = "000003";
        LET cMensajeRet = "No existe información de calificación para el período indicado.";

        DROP TABLE tmp_sdo_ret_totales;

        RETURN NVL(cCodRet,""), NVL(cMensajeRet,""),NVL( cGradoRiesgo,""), NVL(cNumCreditos,""),NVL(dSaldoCierre,0),
                        NVL(dReserCalif,0), NVL(dReserCalifGrad,0), NVL(dReserBuro,0), NVL(dReserInt,0), NVL(dTotalReser,0),
                        NVL(dSdoIntsCredVdos,0), NVL(cTotalCtesSdoFavor,""), NVL(dSdoCierreCtesSdoFavor,0), NVL(dReserCtesSdoFavor,0),
                        NVL(cCtesInactivos,""), NVL(dSdoCierreCtesInactivos,0), NVL(dReserCtesInactivos,0), NVL(cCtesTotaleros,""),
                        NVL(dSdoCierreCtesTotaleros,0);
END IF;

             INSERT INTO tmp_sdo_ret_totales
                SELECT "Total General", sum(num_creditos), sum(saldo_cierre), sum(reserva_calif), sum(reserva_calif_gradual), sum(reserva_buro),
                                sum(reserva_interes), sum(total_reserva), sum(saldo_ints_cred_vdos), sum(num_clientes_saldo_favor),sum(saldo_cierre_ctes_saldo_favor),
                                sum(reserva_ctes_sdo_favor), sum(num_clientes_inactivos), sum(saldo_cierre_ctes_inactivos),sum(reserva_ctes_inactivos),
                                sum(numero_clientes_totaleros), sum(saldo_cierre_ctes_totaleros),sBand_totales
                  FROM tmp_sdo_ret_totales WHERE bandera_totales=1;

FOREACH

        SELECT grado_riesgo, num_creditos, saldo_cierre, reserva_calif, reserva_calif_gradual, reserva_buro, reserva_interes, total_reserva,
                        saldo_ints_cred_vdos, num_clientes_saldo_favor,saldo_cierre_ctes_saldo_favor, reserva_ctes_sdo_favor,num_clientes_inactivos,
                        saldo_cierre_ctes_inactivos,reserva_ctes_inactivos,numero_clientes_totaleros, saldo_cierre_ctes_totaleros
             INTO cGradoRiesgo, cNumCreditos,dSaldoCierre, dReserCalif, dReserCalifGrad, dReserBuro, dReserInt, dTotalReser,
                       dSdoIntsCredVdos, cTotalCtesSdoFavor, dSdoCierreCtesSdoFavor, dReserCtesSdoFavor, cCtesInactivos, dSdoCierreCtesInactivos,
                       dReserCtesInactivos, cCtesTotaleros, dSdoCierreCtesTotaleros
           FROM tmp_sdo_ret_totales


        RETURN NVL(cCodRet,""), NVL(cMensajeRet,""),NVL( cGradoRiesgo,""), NVL(cNumCreditos,""),NVL(dSaldoCierre,0),
                        NVL(dReserCalif,0), NVL(dReserCalifGrad,0), NVL(dReserBuro,0), NVL(dReserInt,0), NVL(dTotalReser,0),
                        NVL(dSdoIntsCredVdos,0), NVL(cTotalCtesSdoFavor,""), NVL(dSdoCierreCtesSdoFavor,0), NVL(dReserCtesSdoFavor,0),
                        NVL(cCtesInactivos,""), NVL(dSdoCierreCtesInactivos,0), NVL(dReserCtesInactivos,0), NVL(cCtesTotaleros,""),
                        NVL(dSdoCierreCtesTotaleros,0) WITH RESUME;

END FOREACH;


DROP TABLE tmp_sdo_ret_totales;

END

END PROCEDURE
DOCUMENT
"Descripción: Procedimiento que obtiene la información de calificación de reserva procesada al día de cierre, en base a un mes y año proporcionado.",
"Autor: Viridiana Osobampo A.",
"BD: bdicred",
"Fecha: 01-04-2011";

CREATE PROCEDURE "informix".sp_mueve_amortiza_fecha(pEmpresa char(3), pfecha date)
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE cnumcredito  char(20);
    DEFINE ccontador    integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    define pmovtos      integer;
    DEFINE vrowid       integer;
--    DEFINE pfecha	date;    

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      LET cMensaje="Error informix";
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   let vrowid       = 0;
   LET ccontador=0;
   LET cMensaje="Proceso Exitoso";
   LET cCodRet='000';
   let pmovtos = 0;

-- SET DEBUG FILE TO "/pisa/cas/sp_mueve_movdia.out";
-- TRACE ON;

   LET cCodRet='000';
   set isolation to dirty read;
   set lock mode to wait 3;

--set pdqpriority 15;

   FOREACH cursor_borra WITH HOLD FOR
        select rowid
         into vrowid
        from bdicred:Sd_amortiza_credito
        where empresa = pEmpresa
        and capital_status = '5' 
        and (capital_fecha_pago is null or capital_fecha_pago <= pfecha)
        and fecha_cuota <= pfecha

           BEGIN WORK;
              DELETE FROM bdicred:Sd_amortiza_credito WHERE CURRENT OF cursor_borra;
           COMMIT WORK;
        
           let ccontador = ccontador + 1;


   END FOREACH;
   
   let cMensaje = 'Proceso terminado, registros borrados : '|| ccontador;
  END;
 RETURN cCodRet,cMensaje;

END PROCEDURE;