CREATE PROCEDURE "informix".sp_guardar_bitacora_rostro(pEmpresa CHAR(3), pSucursal CHAR(4), pNumCliente CHAR(20), pPromotor CHAR(8), pFecha_insert DATETIME YEAR TO SECOND,pTiempo_inicio DATETIME HOUR TO FRACTION(3),pTiempo_fin DATETIME HOUR TO FRACTION(3), tipo_rostro CHAR(2), ptipo_proceso CHAR(1),pcodigo CHAR(6),pintentos INTEGER, ipMaquina CHAR(15))
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

CREATE PROCEDURE "informix".sp_grabaremail_bpi (pEmpresa CHAR(3), pNumCte CHAR(20), pEMail CHAR(100), pAlterEmail CHAR(100))
    RETURNING CHAR(6), CHAR(80);

	--pEmpresa: Empresa
	--pNumCte: Número de Cte
    --pEMail : Correo electrónico del cliente.
    --pAlterEmail : Correo electrónico alternativo.    
    --Autor: Walber Castro
    --Modificó: Jonathan A. Mata
    --fecha modificacion: 23-02-2017
    --20-05-2010
    --Guarda el email en la tabla si_ctepf.

    DEFINE sCodRet CHAR(6);			--CODIGO DE RETORNO PERSONALIZADO
    DEFINE iCodRet INTEGER;			--CODIGO DE RETORNO INTERNO
    DEFINE sErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
    DEFINE cErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
    DEFINE iIsamErr smallint;           --VARIABLE PARA CACHAR EL CODIGO DE ERROR
	DEFINE v_codret1 CHAR(5);
	DEFINE v_TipoCorreo SMALLINT;
	DEFINE v_Canal SMALLINT;
	DEFINE v_UserInsert CHAR(8);
    
    LET sCodRet = "000";
    LET cErrorInfo="EMAIL ACTUALIZADO EXITOSAMENTE";
    LET sErrorInfo="";
    LET	iCodRet=0;   
	LET v_codret1 = '00000';	
	LET v_TipoCorreo = '1';
	LET v_Canal = '3';
	LET v_UserInsert ='transBPI';

   --SET DEBUG FILE TO '/tmp/sp_grabaremail.out';
   --TRACE ON;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION SET iCodRet, iIsamErr, sErrorInfo
            LET sCodRet = iCodRet;
            LET cErrorInfo = sErrorInfo;
            RETURN sCodRet, cErrorInfo;
        END Exception;
		
		--Se valida la empresa
        IF NVL(pEmpresa,'') = '' THEN
                LET sCodRet='001';
                LET cErrorInfo='EMPRESA NO VALIDA';
                RETURN sCodRet, cErrorInfo;
        END IF;
		
		--Se valida el cliente
        IF NVL(pNumCte,'') = '' THEN
                LET sCodRet='001';
                LET cErrorInfo='CLIENTE NO VALIDO';
                RETURN sCodRet, cErrorInfo;
        END IF;
		
        --Se valida el email
        IF NVL(pEMail,'') = '' THEN
                LET sCodRet='001';
                LET cErrorInfo='EMAIL NO VALIDO';
                RETURN sCodRet, cErrorInfo;
        END IF;         
				
		IF (pEMail <> '') THEN
			
			CALL sp_registra_correos_bpi(pEmpresa,pNumCte,pEMail, v_TipoCorreo,v_Canal,v_UserInsert, pAlterEmail) RETURNING sCodRet;            
			
        END IF;
		
        RETURN sCodRet, cErrorInfo;

    END ;
END PROCEDURE ;