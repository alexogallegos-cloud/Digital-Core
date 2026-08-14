CREATE PROCEDURE "informix".sp_grabatiemposmov(pEmpresa CHAR(3),
											   pNumCte CHAR(9),
											   pSucursal CHAR(4),
											   pEjecutivo CHAR(8),
											   pProducto CHAR(4),
											   pTipo CHAR(1))

RETURNING CHAR(5);

DEFINE sCodRet CHAR(5);
DEFINE iSqlErr INTEGER;

LET sCodRet = "";
LET iSqlErr = 0;

BEGIN
ON EXCEPTION SET iSqlErr
   IF iSqlErr <> 0 THEN
      LET sCodRet = iSqlErr;
      RETURN sCodRet;
   END IF;
END EXCEPTION;

   LET sCodRet = "00000";
   
   -- SET DEBUG FILE TO "/home/tmp/jairo/sp_grabatiemposmov.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
	IF pTipo = "1" THEN
		--TIEMPOS PLD
		INSERT INTO bdinteg:"informix".si_bit_tiempoymovimientos(empresa,num_cte,sucursal,ejecutivo,producto,tiempo_pld_ini,fecha_insert) 
		VALUES(pEmpresa,pNumCte,pSucursal,pEjecutivo,'9000',CURRENT,CURRENT);
	ELIF pTipo = "2" THEN
		--TIEMPOS APERTURA
		INSERT INTO bdinteg:"informix".si_bit_tiempoymovimientos(empresa,num_cte,sucursal,ejecutivo,producto,tiempo_apertura_ini,fecha_insert) 
		VALUES(pEmpresa,pNumCte,pSucursal,pEjecutivo,pProducto,CURRENT,CURRENT);
	END IF;

   RETURN sCodRet;
   
END;
END PROCEDURE
DOCUMENT
'Folio:347',
'Autor:95975071 Jairo Valdez Gonzalez',
'Fecha:11/12/2017',
'Descripcion: Se crea sp para insertar los tiempos de inicio de cuestionario PLD y tiempos de Apertura de cuentas de Captacion.',
'Sustento: RQM 18 113 Reporte de tiempos y movimientos de los proceso de apertura y asignaciÃ³n de crÃ©dito, captaciÃ³n y servicios. - AnÃ¡lisis TÃ©cnico',
'Solicita: Abraham Narvaez/Christian Rojas.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_tiempos_movimientos()

RETURNING CHAR(5) AS sCodRet, CHAR(5) AS cCodRetCredCop, CHAR(5) AS cCodRetCap, CHAR(5) AS cCodRetServ, CHAR(5) AS cCodRetCredBan;

DEFINE sCodRet 			CHAR(5);
DEFINE iSqlErr 			INTEGER;
DEFINE cCapturaTiempo 	CHAR(1);
DEFINE cCodRetCredCop 	CHAR(5);
DEFINE cCodRetCap 		CHAR(5);
DEFINE cCodRetServ 	    CHAR(5);
DEFINE cCodRetCredBan 	CHAR(5);

LET sCodRet = '00000';
LET iSqlErr = 0;
LET cCapturaTiempo = '';
LET cCodRetCredCop = '00001'; --Credito Coppel Deshabilitado, innecesario generar reporte.
LET cCodRetCap = '00002';     --No se ejecuto sp.
LET cCodRetServ = '00002';    --No se ejecuto sp.
LET cCodRetCredBan = '00001'; --No se ejecuto sp.

BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr <> 0 THEN
      LET sCodRet = iSqlErr;
      RETURN sCodRet,cCodRetCredCop,cCodRetCap,cCodRetServ,cCodRetCredBan;
   END IF;
END EXCEPTION;
   
    --SET DEBUG FILE TO "/respaldos/FERNANDO/sp_tiempos_movimientos.out";
    --TRACE ON;
   
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Ejecuta Reporte de Servicios
	EXECUTE PROCEDURE bdinteg:"informix".Sp_GenReporteServicios()
	INTO cCodRetServ;
	
	--Ejecuta Reporte de Captación
	EXECUTE PROCEDURE bdinteg:"informix".sp_GenReporteCaptacion()
	INTO cCodRetCap;	
	
	SELECT captura_tiempo
	INTO cCapturaTiempo
	FROM bdicred:"informix".sd_productotiempomov
	WHERE id_producto = '6500';
	
	--Ejecuta Reporte Coppel (6500)
	IF cCapturaTiempo::int = 1 THEN
		EXECUTE PROCEDURE bdinteg:"informix".Sp_GenReporteCredCoppel()
		INTO cCodRetCredCop;					
	END IF;							
	
	--Ejecuta Reporte Productos Crédito Banco
	EXECUTE PROCEDURE bdinteg:"informix".Sp_GenReporteCredBanco()
	INTO cCodRetCredBan;

	RETURN sCodRet,cCodRetCredCop,cCodRetCap,cCodRetServ,cCodRetCredBan;

END;
END PROCEDURE
DOCUMENT
'Folio: 347',
'Autor: 97460729 Fernando Ortega Prieto',
'Fecha: 27/12/2017',
'Descripcion: Se crea sp para ejecutar 4 sps y generar los reportes de tiempos para los productos de Captación, Crédito Coppel, Crédito Bancoppel y Servicios.',
'Sustento: RQM 18 113 Reporte de tiempos y movimientos de los proceso de apertura y asignación de crédito, captación y servicios. - Analisis Técnico',
'Solicita: Abraham Narvaez/Christian Rojas.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_valida_confirmacion_movil(pNumCte CHAR(9), pUsuario CHAR(8),pTelefono CHAR(10))
RETURNING CHAR(6) As cCodRet;

--DefiniciÃÂ³n de Variables 
DEFINE cCodRet			CHAR (6);
DEFINE cBandera         BOOLEAN;
DEFINE iSqlErr          INTEGER;
--InicializaciÃÂ³n de Variables

LET cCodRet      = '000000';
LET cBandera     = 'F';
LET iSqlErr      = 0;

BEGIN	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			let cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/Braulio/sp_valida_confirmacion_movil.out";
	--TRACE ON; 
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pNumCte,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pTelefono,'') <> '' THEN

			SELECT bandera 
			INTO cBandera
			FROM bdinteg:"informix".si_bitsmstels
			WHERE numcte = pNumCte 
			AND telefono = pTelefono 
			AND ejecutivo = pUsuario
			AND fecha IN (SELECT MAX(FECHA) FROM bdinteg:"informix".si_bitsmstels 
						  WHERE numcte = pNumCte
						  AND telefono = pTelefono
						  AND ejecutivo = pUsuario);

			IF dbinfo ("sqlca.sqlerrd2") = 0 then-- No hay informacion
				LET cCodRet = '001289';
				RETURN cCodRet;
			END IF;

			IF cBandera = 'F' THEN
				LET cCodRet = '001386';
			ELIF cBandera = 'T' THEN
				LET cCodRet = '000000';
			END IF;
	ELSE
		LET cCodRet = '000001';
	END IF; 

RETURN cCodRet;
END;
END PROCEDURE;