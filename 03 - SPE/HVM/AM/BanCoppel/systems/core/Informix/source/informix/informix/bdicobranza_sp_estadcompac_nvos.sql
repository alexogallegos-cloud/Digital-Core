CREATE PROCEDURE "informix".sp_estadcompac_nvos( pEmpresa char(3), pTipo char(1), pFecha date, pOrigen char(1) )
RETURNING CHAR(5);

--Fecha de creación: 23/04/2009
--Programó: Alfonso Velazquez Capuleño
--Objetivo: Store Procedure que obtiene estadisticas de Compromisos y Acuerdos nuevos
-- pEmpresa  Numero de empresa --pTipo Fecha parametro o de tabla y si reprocesa
-- pFecha Dato de fecha a procesar -- pOrigen 1 Tienda , 2 Sucursal 3 CAT 

DEFINE vcCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE vdFechaHoy DATE;

DEFINE vcEmpresa CHAR(3);
DEFINE viOrigen INTEGER;
DEFINE vcSucursal CHAR(4);
DEFINE vcTipoCompAc CHAR(1);
DEFINE vcPlazo CHAR(2);
DEFINE viSumaTotCompAc INTEGER;
DEFINE vmSumaImporte MONEY(16,2);
DEFINE vcEsTransaccion  CHAR(1);

        ON EXCEPTION SET viSqlErr

            IF vcEsTransaccion = 'S' THEN
                ROLLBACK WORK;
            END IF;
            LET vcCodRet = viSqlErr;
            RETURN vcCodRet;
        END EXCEPTION;

        --SET DEBUG FILE TO "/home/informix/sp_estadcompac_nvos.out";
        --TRACE ON;

LET vdFechaHoy = CURRENT::DATE;
LET vcCodRet = '00000';
LET vcEmpresa = '';
LET viOrigen = 0;
LET vcSucursal = '';
LET vcTipoCompAc = '';
LET vcPlazo = '';
LET viSumaTotCompAc = 0;
LET vmSumaImporte = 0.0;
LET vcEsTransaccion = 'N';

  IF pEmpresa IS NULL OR pEmpresa = "" THEN
    LET vcCodRet = '00001';
  ELSE
    LET vcEmpresa = pEmpresa;
    IF pTipo = "0" OR pTipo = "" THEN
        SELECT fecha_hoy
        INTO vdFechaHoy
        FROM bdinteg:si_fechas
        WHERE empresa = pEmpresa;
    ELSE
        IF pFecha IS NULL OR pFecha = "" THEN
            LET vcCodRet = '00001';      --CÓDIGO DE ERROR PARÁMETRO INCORRECTO
        ELSE
            LET vdFechaHoy = pFecha;
        END IF;
    END IF;

    IF vcCodRet = '00000' THEN
        BEGIN WORK;
        LET vcEsTransaccion = 'S';
			
        FOREACH
			--Agrupados por Sucursal			
			
			SELECT empresa, origen, sucursal, tipo_compac, plazo, SUM(1), SUM(importe)
			INTO   vcEmpresa, viOrigen, vcSucursal, vcTipoCompAc, vcPlazo, viSumaTotCompAc, 
             vmSumaImporte 
			FROM bdicobranza:cb_compac
			WHERE empresa     = vcEmpresa 
        AND fecha_compac = vdFechaHoy
			  AND ( Origen  = pOrigen or pOrigen =0)
			GROUP BY empresa, origen, sucursal, tipo_compac, plazo
			ORDER BY origen, sucursal, tipo_compac, plazo

			
			-- Valida si se va a reprocesar la información MAJF Julio 2009
      IF pTipo = "2"  THEN
        DELETE FROM bdicobranza:mc_estadcompac_nvos
        WHERE empresa     = vcEmpresa 
          AND fecha_compac= vdFechaHoy 
          AND origen      = viOrigen 
          AND sucursal    = vcSucursal 
          AND tipo_compac = vcTipoCompAc 
          AND plazo       = vcPlazo;
      END IF;
      
      --Agrega la estadistica a la tabla correspondiente
	        INSERT INTO bdicobranza:mc_estadcompac_nvos(
                      fecha_compac, empresa, origen, sucursal, tipo_compac, plazo, 
                      num_compac, importe)
	        VALUES (vdFechaHoy, vcEmpresa, viOrigen, vcSucursal, vcTipoCompAc, vcPlazo, 
                  viSumaTotCompAc, vmSumaImporte);

        END FOREACH;

        COMMIT WORK;
        LET vcEsTransaccion = 'N';

    END IF;
END IF;
RETURN vcCodRet;

END PROCEDURE;