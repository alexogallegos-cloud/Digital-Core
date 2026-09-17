CREATE PROCEDURE "informix".sp_guardar_bitacora_rostro_prue(pEmpresa CHAR(3), pSucursal CHAR(4), pNumCliente CHAR(20), pPromotor CHAR(8), pFecha_insert DATETIME YEAR TO SECOND,pTiempo_inicio DATETIME HOUR TO FRACTION(3),pTiempo_fin DATETIME HOUR TO FRACTION(3), tipo_rostro CHAR(2), ptipo_proceso CHAR(1),pcodigo CHAR(6),pintentos INTEGER, ipMaquina CHAR(15))
RETURNING CHAR(5) AS CodigoRetorno;
		
-- *	DEFINICION DE VARIABLES		  
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet            CHAR(5);
	
-- *	ASIGNACION DE VARIABLES
	LET	iSqlErr 		= 0;
	LET cCodRet 	= '00001';
	
-- *	CONTROL DE ERRORES
	BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
--	SET DEBUG FILE TO '/home/JA/CoppelFace/sp_guardar_bitacora_rostro.out';
--	TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	LET pEmpresa 		= TRIM(pEmpresa);
	LET pSucursal 		= TRIM(pSucursal);
	LET pNumCliente 	= TRIM(pNumCliente);
	LET pPromotor 		= TRIM(pPromotor);
	LET tipo_rostro 	= TRIM(tipo_rostro);
	LET ptipo_proceso 	= TRIM(ptipo_proceso);
	LET ipMaquina 		= TRIM(ipMaquina);
	
	--VALIDAR PARAMETROS VACIOS O NULOS
	IF NVL(pEmpresa,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pNumCliente,'') = '' OR NVL(pPromotor,'') = '' OR NVL(pFecha_insert,'') = ''
		OR NVL(pTiempo_inicio,'') = '' OR NVL(pTiempo_fin,'') = '' OR NVL(tipo_rostro,'') = '' OR NVL(ptipo_proceso,'') = ''  OR NVL(ipMaquina,'') = '' THEN
		LET cCodRet = '00002';
	ELSE

		INSERT INTO bdinteg:"informix".si_bitacora_rostro(empresa, sucursal, numcte, promotor, fecha_inserta, tiempo_inicio, tiempo_fin, tipo_rostro, tipo_proceso, codigo,hora_inicio_ms, hora_fin_ms, intentos, ip)
		VALUES(pEmpresa, pSucursal, pNumCliente, pPromotor, pFecha_insert, pTiempo_inicio, pTiempo_fin, tipo_rostro, ptipo_proceso, pcodigo,pTiempo_inicio, pTiempo_fin, pintentos, ipMaquina);
	
		LET cCodRet = '00000';
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio.........: 1433-Reconocimiento_Facial',
'Autor.........: 94565457 - Jose Angel Gaxiola Gaxiola',
'Fecha.........: 20/06/2014',
'Descripcion...: Se crea procedimiento para guardar bitacora de tiempos de coppel face en la tabla "si_bitacora_rostro".',
'Solicita......: Daniel Zambada',
'BD............: bdinteg',
'Folio: 1680 - SoporteBiometricoFacial',
'------------------------------------------------------------------------------------------',
'Autor: 95142134 Mario Gallardo',
'Fecha: 27/11/2014',
'Modificació®º Se agrega Parâ®¥tro de entrada y se agregan nuevos campos para la tabla si_bitacora_rostro ',
'Sustento: RQI 23 008 Biometria Facial.pdf',
'Solicita: Rodolfo Gomez',
'------------------------------------------------------------------------------------------',
'Autor: 97915041 RocÃ­o Vidales',
'Fecha: 17/07/2017',
'ModificaciÃ³n: Se agrega Parametro de entrada Ip para insertarlo en la tabla si_bitacora_rostro',
'Sustento: RQI 271.1 - Solicitud de Ip en Bitacora',
'Solicita: Abraham  Narvaez Jacinto',
'------------------------------------------------------------------------------------------',
'Autor: 95281495-Ernesto Aguilera',
'Fecha: 10/10/2018',
'ModificaciÃ³n: Se agrega Parametro de entrada Ip para insertarlo en la tabla si_bitacora_rostro',
'Sustento: Actualmente este procedimeinto existe en produccion, cuando se libero se comento el insert',
'al campo ip, ya que la tabla no estaba lista con ese campo. Se solicita que ya empiece a guardar la ip',
'Solicita: Abraham  Narvaez Jacinto',
'------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_ctanvl2_generadocs_pba( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER; 
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cDescErr     CHAR(50);
    DEFINE iAbierto     SMALLINT;
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE dtFechaHoy   DATE;
    DEFINE cCuenta      CHAR(20);
    DEFINE cNumCte      CHAR(20);
    DEFINE cCodRetPDF   CHAR(5);
    
    LET cCodRet1   = '000';
    LET cCodRet2   = '000';
    LET cCodRet3   = 'PROCESO FINALIZADO CORRECTAMENTE'; 
    LET iSqlErr	   = 0;
    LET iIsamErr   = 0;
    LET cDescErr   = '';
    LET iAbierto   = 0;    
    LET iContador1 = 0;
    LET iContador2 = 0;
    LET dtFechaHoy = '';
    LET cCuenta    = '';
    LET cNumCte    = '';
    LET cCodRetPDF = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctanvl2_generadocs_pba.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1   = iSqlErr;
            LET cCodRet2   = iIsamErr;
            LET cCodRet3   = cDescErr;
            LET cCuenta    = cCuenta;
            LET cNumCte    = cNumCte;
            LET cCodRetPDF = cCodRetPDF;
            IF iAbierto = 1 THEN
                ROLLBACK WORK;
                LET iAbierto = 0;
            END IF;
            RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctanvl2_generadocs_pba.out";
    TRACE ON;
    
    SELECT fecha_hoy
      INTO dtFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
     
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.num_cte
          INTO cCuenta, cNumCte
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE mae.cuenta = noc.cuenta
           AND mae.producto = '2900'
           --- AND noc.fecha_alta = dtFechaHoy
           AND mae.cuenta IN('29000000004','29004742417')
        
        BEGIN WORK;
        LET iAbierto = 1;
        
        LET iContador1 = iContador1 + 1;
        
        EXECUTE PROCEDURE bdinteg:sp_ctanvl2_generapdf(cCuenta, cNumCte)
        INTO cCodRetPDF;
        
        IF cCodRetPDF = '000' THEN
            LET iContador2 = iContador2 + 1;
        END IF;
        
        COMMIT WORK;
        LET iAbierto = 0;
        
        LET cCuenta    = '';
        LET cNumCte    = '';
        LET cCodRetPDF = '';
    END FOREACH;
    
    END; 
    
    RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
    
END PROCEDURE;