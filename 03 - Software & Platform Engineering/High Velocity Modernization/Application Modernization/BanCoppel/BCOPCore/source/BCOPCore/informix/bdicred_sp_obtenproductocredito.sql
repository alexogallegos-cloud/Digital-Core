CREATE PROCEDURE  "informix".sp_obtenproductocredito()

RETURNING CHAR(6) AS Codigo_de_Retorno,
		  CHAR(6) AS Numero_de_Producto,
		  CHAR(50) AS Nombre_Producto,
		  CHAR(1) AS Tp_Solicitud

--definicion de variables
	DEFINE sql_err 			INTEGER;
	DEFINE cCodret 			CHAR(6);
	DEFINE cNum_Producto	CHAR(6);
	DEFINE cNombre_Producto	CHAR(50);
	DEFINE cTipo 			CHAR(1);
--Asignacion de variables
    LET sql_err 			= 0;
	LET cCodret				= "000000";
	LET cNum_Producto		= "";
	LET cNombre_Producto	= "";
	LET cTipo 				= "";
	BEGIN
			--Manejo de excepciones (errores)
			ON EXCEPTION SET sql_err
				IF sql_err <> 0 THEN
					let cCodret = sql_err;
					RETURN cCodret, "","","";
				END IF;
			END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

			--SET DEBUG FILE TO "/tmp/sp_ObtenProductoCredito.out";
			--TRACE ON;
			--Este Procedimiento se utiliza en CARATARJ.exe para Obtener los productos de crédito que se podrá imprimir la reimpresion
			FOREACH
				SELECT a.num_producto,a.nombre_prod,b.tp_solicitud  
				INTO cNum_Producto, cNombre_Producto, cTipo
				FROM bdicred:sd_definicion a 
				LEFT JOIN  bdisolic:ss_solic_producto b ON(a.num_producto = b.num_producto) 
				WHERE a.maneja_pago_sost = 'N'
				RETURN cCodret,cNum_Producto,cNombre_Producto,cTipo WITH RESUME;
			END FOREACH;
	END;

END PROCEDURE
DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Es procedimiento obtiene los productos de credito manejados por el banco',
'FECHA      : 12-10-2009',
'VERSION    : 20091012.1745',
'BD         : BDICRED',
'AUTOR      : Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Modificación se agrego el retorno del tipo de producto para la reeimpresion de caratula',
'FECHA      : 08-12-2009',
'VERSION    : 20091208.1617',
'BD         : BDICRED';

CREATE PROCEDURE "informix".libera_retenido_forzado()
RETURNING CHAR(5);       -- Codigo de Retorno

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

   DEFINE CodRet        CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE vFOlio	CHAR(16);
   DEFINE vFecha	DATE;
   DEFINE vDiasRet	SMALLINT;
   DEFINE vMonto	DECIMAL(14,2);
   DEFINE vMontoLib     DECIMAL(14,2);
   DEFINE vDIas		SMALLINT;
   DEFINE vNumCredito char(20);
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   ON EXCEPTION SET sql_err
      LET CodRet = sql_err;
      ROLLBACK WORK;
      RETURN CodRet;
   END EXCEPTION

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET CodRet    = '000';
   LET vFolio    = "??????";
   LET vFecha    = " ";
   LET vDiasRet  = 0;
   LET vMonto    = 0;
   LET vMontoLib = 0;
   LET vDias     = 0;
   LEt vNumCredito = '';

 -- **************************************************************************
 -- *                      PROGRAMA PRINCIPAL                                *
 -- **************************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--SET DEBUG FILE TO "/informix/miguel/libera_retenido_forzado.out";
	--TRACE ON;
	
	FOREACH WITH HOLD
        SELECT a.folio_suc, a.fecha_hora, a.num_credito, a.monto
          into vFolio, vFecha, vNumCredito, vMontoLib
		  FROM bdicred:sd_retenidolibera a,
               bdicred:sd_maeretenido b
		 WHERE empresa = '001'
		   AND estatus in ("P","S")
           AND a.num_credito = b.num_credito
           AND a.folio_suc = b.folio_suc
       
		SELECT sdo_retenido INTO vMonto FROM bdicred:sd_maesdos WHERE num_credito = vNumCredito;
		
		IF vMontoLib<= vMonto THEN
           begin work;

                UPDATE bdicred:sd_maeretenido
                   SET estatus = "S"
                 WHERE empresa = '001'
                   AND num_credito = vNumCredito
                   AND folio_suc = vFolio
                   AND fecha = vFecha;
				
                UPDATE sd_maesdos 
					SET sdo_retenido  = sdo_retenido - vMontoLib 
				WHERE num_credito = vNumCredito;

            commit work;
		END IF;

	END FOREACH


	RETURN CodRet;

END PROCEDURE;