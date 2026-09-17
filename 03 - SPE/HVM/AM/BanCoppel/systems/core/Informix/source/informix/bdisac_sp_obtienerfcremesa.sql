CREATE PROCEDURE "informix".sp_obtienerfcremesa(p_categoria CHAR(2), p_convenio CHAR(5), p_referencia CHAR(40), p_folio_suc CHAR(16))
RETURNING CHAR(5), CHAR(13);

	--Definicion de Variables
    DEFINE cCodRet          CHAR(5);
	DEFINE vRfc				CHAR(13);
    DEFINE iSqlErr			INTEGER;
	DEFINE vCuenta			INTEGER;

	-- Inicializa variables
	LET iSqlErr				= 0;
	LET cCodRet            	= "00000";
	LET vRfc				= '';
	LET vCuenta				= 0;
	
	--SET DEBUG FILE TO '/tmp/sp_obtienerfcremesa.out';
	--TRACE ON;

    BEGIN
	
        ON EXCEPTION SET iSqlErr
			--Manejo de errores, en caso de error, envío codigo de error
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, vRfc;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF p_referencia != '' AND p_folio_suc != '' THEN
		
			--Busco el RFC con la referencia enviada
			SELECT COUNT(*)
			INTO   vCuenta
			FROM   sac_remesas_estadistica
			WHERE  referencia   = p_referencia
			AND    folio_suc    = p_folio_suc
			AND    numcategoria = p_categoria
			AND    numconvenio  = p_convenio;
		
			--Busco el RFC con la referencia enviada
			SELECT rfc
			INTO   vRfc
			FROM   sac_remesas_estadistica
			WHERE  referencia   = p_referencia
			AND    folio_suc    = p_folio_suc
			AND    numcategoria = p_categoria
			AND    numconvenio  = p_convenio;
			
			IF vCuenta = 0 THEN --SI LA BUSQUEDA NO ARROJA RESULTADOS
				LET cCodRet = "00001";
				LET vRfc    = '';
			END IF;
			
		ELSE
		
			LET cCodRet = "00002";	--Viene vacio el parametro
			LET vRfc    = '';
		
		END IF;
		
		RETURN cCodRet, vRfc;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de obtener el RFC del beneficiario cargado en la tabla sac_remesas_estadistica',
'FECHA CREACION : 4 de Junio de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_pay 
(
	pEmpresa												CHAR(3), 
	pMarca             									 CHAR(2),
	pUsuario												CHAR(8),  
	pBenefNameType 										CHAR(1), 
	pBenefNombreUno										CHAR(40), 
	pBenefNombreDos										CHAR(40), 
	pBenefApaterno										CHAR(40), 
	pBenefAmaterno										CHAR(40), 
	pBenefCiudad 											CHAR(24), 
	pBenefEdo  											CHAR(40), 
	pBeneCP												CHAR(9),
	pBenefIdType  										CHAR(1), 
	pBenefIdPaisExpedi									CHAR(45), 
	pBenefIdNumber  									CHAR(20), 
	pBenefTieneFechVenc									CHAR(1), 
	pBenefFechaVenc  									CHAR(8),
	pBenefFechNac  										CHAR(8), 
	pBenefOcupacion  									CHAR(30), 
	pBenefCalleNum  										CHAR(40), 
	pBenefColDelMun  									CHAR(40), 
	pBenefPais  											CHAR(45), 
	pBenefTelPart 										CHAR(20), 
	pBenefTelCel  										CHAR(20), 
	pBenefEmail  											CHAR(40), 
	pBenefPaisNac  										CHAR(2), 
	pBenefNacionalidad 									CHAR(15), 
	pBenefSexo  											CHAR(1), 
	pBenefCiudadNac										CHAR(20), 
	pBenefEdoNac											CHAR(20), 
	pBenefCodPais											CHAR(3), 
	pBenefCodMoneda										CHAR(3), 
	pMontoOrigen											CHAR(10), 
	pMontoDestino											CHAR(10), 
	pMoneyTransferKey									CHAR(10), 
	pNewMtcn												CHAR(16), 
	pMtcn													CHAR(10), 
	pConfPago												CHAR(1), 
	pForeignRefNumRq									CHAR(16), 
	pFechaHrRq											DATETIME YEAR TO SECOND, 
	pRetCode												CHAR(5), 
	pDatosBufer											CHAR(500), 
	pMtcnRp												CHAR(10), 
	pPuntosGanados										CHAR(4), 
	pWuFechaPago											CHAR(16), 
	pForeignSystemIdRp									CHAR(11), 
	pForeingRefNumRp									CHAR(16), 
	pForeignRsCantIdRp									CHAR(11), 
	pDesError												CHAR(250), 
	pPartnerIdErr											CHAR(10), 
	pFechaHoraRp											DATETIME YEAR TO SECOND, 
	pUserInsert											CHAR(8), 
	pFechaInsert											DATETIME YEAR TO SECOND,
	pSecondIdType										CHAR(1),  
	pSecondPaisExp										CHAR(44),
	pSecondIDNumber   									CHAR(30), 
	pNumCte												CHAR(20)	
)

RETURNING  CHAR(5) AS cod_err, CHAR(30) AS error_desc;

	--DEFINICION DE VARIABLES--
    DEFINE	iSqlErr				INTEGER;
	DEFINE 	iIsamErr			INTEGER;
    DEFINE	cCodRet				CHAR(5);
	DEFINE  cRetCode			CHAR(5);
	DEFINE  cDesc_Error         CHAR(250);
	DEFINE	cCodRetAux			CHAR(5);
	DEFINE	cTxnStatus			CHAR(1);
	DEFINE	cNombreSP			CHAR(45);
	DEFINE 	cCadena_ent			CHAR(100);
	DEFINE cError_Desc  		CHAR(30);
	DEFINE dFechaProceso    	DATETIME YEAR TO SECOND;
	DEFINE cChannelType 		CHAR(3);
    DEFINE cChannelName 		CHAR(3); 
    DEFINE cChannelVersion		CHAR(4);
	DEFINE cForeignSystemId		CHAR(11); 
	DEFINE cForeignRsCntRq  	CHAR(11);
	DEFINE cTemplateId          CHAR(10);
	DEFINE cSucursal		CHAR(4);
	DEFINE vfec_nac				DATE;
	DEFINE vCodRet				CHAR(5);
	DEFINE vcuenta				INTEGER;
	DEFINE p_moneda_origen 		CHAR(3);
	DEFINE p_importe_origen 	MONEY;
	DEFINE vCategoria			CHAR(2);
	DEFINE vConvenio			CHAR(5);

	
	--INICIALIZACION DE VARIABLES--
    LET	iSqlErr				= 0;
	LET	iIsamErr 			= 0;
    LET cCodRet				= '00000';
	LET cRetCode			= '00000';
	LET cDesc_Error			= "";
	LET cCodRetAux			= '00000';
	LET cTxnStatus			= 'C';
	LET	cNombreSP			= 'sp_sac_wu_guardarespuesta_pay';
	LET cCadena_ent			= TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pMoneyTransferKey,'NULL'))||'|'||TRIM(NVL(pNewMtcn,'NULL'));
    LET cError_Desc 		= "Error en el proceso";
	LET dFechaProceso		=  CURRENT::DATETIME YEAR TO SECOND;
	LET cChannelType 	 	= "";	
    LET cChannelName 	 	= "";	 
    LET cChannelVersion	 	= "";
	LET cForeignSystemId 	= ""; 
	LET cForeignRsCntRq  	= "" ;
	LET cTemplateId			= "";
	LET cSucursal 			= "";
	LET vcuenta					= 0;
	LET vCodRet					= '00000';
	LET p_moneda_origen			= '';
	LET p_importe_origen		= 0;
	LET vCategoria				= '07';
	LET vConvenio				= '';
	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;

			EXECUTE PROCEDURE "informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSqlErr,iIsamErr,cCadena_ent,pUsuario,dFechaProceso) 
			INTO cCodRetAux;

			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
			--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
				LET cTxnStatus		 = 'C';
			--	2014.11.11 FRG-f

			INSERT INTO "informix".sac_wu_pay
					(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1,    benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type, benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago, foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp, puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert, benef_second_id_type, benef_second_pais_expedicion, benef_second_id_number,numcte)
			
			VALUES
					(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun, pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac,  pBenefNacionalidad, pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey, pNewMtcn, pMtcn, pConfPago, cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, pRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago,pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp, pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current, pSecondIdType, pSecondPaisExp, pSecondIDNumber,pNumCte);

			RETURN cCodRet, cError_Desc;
		END IF;

	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_pay.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF pRetCode = '504' THEN
	    LET cRetCode = '99999';
		LET pDesError = 'Aplicativo WU no activo, validar';
		
	END  IF;

	IF pRetCode <>  '504' AND pRetCode <> '00000' AND pRetCode <> '66666' THEN		
        IF pRetCode <> '20001' then
            LET cRetCode = '99998';
            LET pDesError = 'Sin respuesta del aplicativo, validar';
        ELIF pRetCode = '20001' then
            LET cRetCode = '20001';
            LET pDesError = 'Caracter invalido en la cadena';
        END IF;
	END IF;

	IF pRetCode = '66666' THEN
		LET cDesc_Error = pDesError;
		LET cRetCode = pRetCode;
	END IF
	
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
		IF (SELECT valor FROM "informix".sac_param WHERE cod_param ='87054') = pMarca
		OR (SELECT valor FROM "informix".sac_param WHERE cod_param ='87055') = pMarca
		OR (SELECT valor FROM "informix".sac_param WHERE cod_param ='87056') = pMarca THEN
			IF pUsuario = "sys_wu" THEN
				LET cSucursal = '9250';
			ELSE
				SELECT sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
			END IF;
			IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN
			
				SELECT fsid ,counter_id
				INTO cForeignSystemId ,cForeignRsCntRq
				FROM "informix".sac_wu_identificadores
				WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = cSucursal;

				IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
					LET cCodRet = '00027';
					LET cError_Desc	= 'Usuario no tiene Id. Asignado';
				END IF;
			ELSE
				LET	cCodRet = '00026'; --- Usuario no se encuentra
				LET cError_Desc	= 'NO EXISTE USUARIO';
		   END IF;
		ELSE
			LET	cCodRet = '00003'; --- Marca InvÃ¡lida
			LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';
		END IF;
		
		SELECT valor
		INTO cChannelType
		FROM "informix".sac_param 
		WHERE cod_param = '87050';  
		 
		SELECT valor
		INTO cChannelName
		FROM "informix".sac_param 
		WHERE cod_param = '87051'; 
		 
		SELECT valor
		INTO cChannelVersion
		FROM "informix".sac_param 
		WHERE cod_param = '87052'; 
		
		SELECT valor
		INTO cTemplateId
		FROM "informix".sac_param 
		WHERE cod_param = '87063';

		--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
			LET	cTxnStatus	= 'A';
		--	2014.11.11 FRG-f
	
		INSERT INTO "informix".sac_wu_pay	
				(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1, benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type,benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago,foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp,puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err,fecha_hora_rp, user_insert, fecha_insert, benef_second_id_type, benef_second_pais_expedicion, benef_second_id_number,numcte)
						
		VALUES
				(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun,pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac, pBenefNacionalidad,pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey,pNewMtcn, pMtcn, pConfPago,cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, cRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago, pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp,pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current, pSecondIdType, pSecondPaisExp, pSecondIDNumber,pNumCte);
					   
		IF  cCodRet <> '00000' THEN
			
			IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
				RETURN cCodRet,cError_Desc;	
			END IF;
		  
            RETURN cCodRet,cError_Desc;		
	    ELSE
		
			--Busco datos de query
			EXECUTE PROCEDURE bdisac:"informix".sp_obtieneremadic(vCategoria, '999', pMtcn)
			INTO vCodRet, p_moneda_origen, p_importe_origen;
			
			--Obtengo el convenio de la familia de WU
			SELECT FIRST 1 numconvenio
			INTO   vConvenio
			FROM   sac_remesas_estadistica
			WHERE  referencia   = pMtcn
			AND    numcategoria = vCategoria;
			
			--Actualizo tabla de datos para limites de remesas mensuales
			LET vfec_nac = MDY(SUBSTRING(pBenefFechNac FROM 3 FOR 2), SUBSTRING(pBenefFechNac FROM 1 FOR 2), SUBSTRING(pBenefFechNac FROM 5 FOR 4));
			EXECUTE PROCEDURE bdisac:"informix".sp_actualizaremesa(vCategoria, vConvenio, pMtcn, pBenefNombreUno, pBenefNombreDos, pBenefApaterno, pBenefAmaterno, vfec_nac, p_moneda_origen, p_importe_origen)
			INTO vCodRet, vcuenta;
			
			IF cCodRet = '00000' THEN
				LET cError_Desc = "Ejecucion SP exitosa";
			END IF;	
			
           RETURN cCodRet,cError_Desc;
	    END IF;	
END;
END PROCEDURE;