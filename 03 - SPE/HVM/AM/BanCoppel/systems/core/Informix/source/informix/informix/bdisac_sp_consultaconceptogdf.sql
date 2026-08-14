CREATE PROCEDURE "informix".sp_consultaconceptogdf(pClave CHAR(2))

--DATOS A REGRESAR---
RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(20)  AS Leyenda;

--DECLARACION DE VARIABLES			
DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cLeyenda     CHAR(20);

--ASIGNACION DE VALORES
LET iSqlerr = 0;
LET cCodRet = '00000';
LET cLeyenda = '';
 
   --SET DEBUG FILE TO "/respaldosbd/Martha/sp_consultaconceptogdf.out";
   --TRACE ON;   
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	IF NVL(pClave,'') = '' THEN		
		LET cCodRet = '00001';
	END IF;
	
	SELECT leyenda 
	INTO cLeyenda
	FROM bdisac:"informix".sac_catconceptosgdf
	WHERE clave = pClave;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
		LET cCodRet = '00002';
	END IF;  

	RETURN cCodRet, cLeyenda;
	
END
END PROCEDURE

DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 08/01/2013",
"Descripcion: Valida si la clave recibida es vÃ¡lida",
"	          consultando en el catalago de conceptos",
"             de pagos del gobierno del distrito federal",
"Ver.  : 1.0",
"BD    : bdisac",
'MODIFICACION : 11/02/2013',
'MODIFICO :Felipe Urias  ',
'DESCRIPCION: se agrega como retorno la leyenda de conceptos de sac_catconceptosgdf';

CREATE PROCEDURE "informix".sp_consultaempleadowu
(
	pSucursal CHAR(4), 	pEmpleado CHAR(8), pCategoria CHAR(2), 	pConvenio CHAR(3), pModo SMALLINT
)
--		pSucursal		CHAR(4);   Parámetro obligatorio.
--		pEmpleado		CHAR(8);   Parámetro obligatorio.
--		pCategoria		CHAR(2);   Parámetro Obligatorio para modalidad 2.
--		pConvenio 		CHAR(3);   Parámetro obligatorio para modalidad 2.
--		pModo			SMALLINT;  Parámetro obligatorio.
		
RETURNING
	CHAR(5)  AS cCodRet,	    	
	SMALLINT AS sValor,	
	CHAR(30) AS cDescripcion,
	CHAR(1)  AS cMsg;

DEFINE cCodRet		  CHAR(5);
DEFINE iSqlErr  	  INTEGER;
DEFINE sValor		  SMALLINT;
DEFINE cDescripcion   CHAR(30);
DEFINE cMsg			  CHAR(1);
DEFINE cEdoFronterizo CHAR(2); --Estado fronterizo.
DEFINE dFecha_hoy	  DATETIME YEAR TO FRACTION;

LET cCodRet		   = '00002'; --Inicializado como código de error en caso de no entrar al cuerpo del sp.
LET iSqlErr  	   = 0;
LET sValor		   = 0;
LET cDescripcion   = '';
LET cMsg		   = '';	
LET cEdoFronterizo = '';
LET dFecha_hoy	   = CURRENT;

	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sValor, cDescripcion, cMsg;	
		END IF;
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1508/sp_consultaempleadowu.out';
		--TRACE ON;
			 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;  

		--Validamos parámetros obligatorios
		IF NVL(pSucursal, '') = '' OR NVL(pEmpleado, '') = '' OR NVL(pModo, '') = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet, sValor, cDescripcion, cMsg;			
		ELSE
			--Obtenemos la fecha de bdinteg:"informix".si_fechas (campo fecha_hoy) y la guardamos en la variable dFecha_hoy para uso posterior.
			SELECT fecha_hoy
			INTO dFecha_hoy
			FROM bdinteg:"informix".si_fechas;
			
			IF pModo = '1' THEN				
				--Validamos que la sucursal recibida como parámetro exista en bdinteg:"informix".si_sucursales.
				IF NOT EXISTS(SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal) THEN
					LET cCodRet = '00002';
					RETURN cCodRet, sValor, cDescripcion, cMsg;
				ELSE
					SELECT estado 
					INTO cEdoFronterizo
					FROM bdinteg:"informix".si_sucursales 
					WHERE sucursal = pSucursal;
								
					--Validamos si la sucursal está o no en un estado fronterizo
					------------------------------------------------------------------------------------------------------------------
					IF EXISTS 
					(SELECT descripcion FROM "informix".sac_param WHERE  TRIM(valor) LIKE '%' || TRIM(cEdoFronterizo) || '%' AND cod_param = '87084' ) THEN
						--Sí es estado fronterizo
						--Validamos si el empleado ha aceptado los términos de WU (Western Union) antes de la transacción actual.
						IF EXISTS( SELECT usuario FROM "informix".sac_registraempleadowu WHERE usuario = pEmpleado AND sucursal = pSucursal 
								   AND fecha = dFecha_hoy
								 ) THEN
							--Si ha aceptado los términos.
							LET cCodRet		 = '00000';
							LET sValor 		 = 1;
							LET cDescripcion = 'Sucursal fronteriza';
							LET cMsg 		 = 1;				
							RETURN cCodRet, sValor, cDescripcion, cMsg;					
						ELSE
							--No ha aceptado los términos (primer pago de remesa extranjera del empleado actual)
							LET cCodRet		 = '00000';
							LET sValor 		 = 1;
							LET cDescripcion = 'Sucursal fronteriza';
							LET cMsg 		 = 0;				
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						END IF;						
					ELSE
						--No es estado fronterizo
						LET cCodRet = '00000';
						LET sValor = 0;
						LET cDescripcion = 'Sucursal no fronteriza';
						LET cMsg = 0;				
						RETURN cCodRet, sValor, cDescripcion, cMsg;	
					END IF;
				END IF;
					------------------------------------------------------------------------------------------------------------------
			ELIF pModo = '2' THEN
				--En esta modalidad se registrará al empleado en la nueva tabla bdisac:"informix".sac_registraempleadowu.
				IF NVL(pCategoria,'') = '' OR NVL(pConvenio,'') = '' THEN
					LET cCodRet = '00001';
					RETURN cCodRet, sValor, cDescripcion, cMsg;
				ELSE					
					INSERT INTO "informix".sac_registraempleadowu (numcategoria, numconvenio, usuario, sucursal, fecha, fecha_hora, status)
					VALUES (pCategoria, pConvenio, pEmpleado, pSucursal, dFecha_hoy, CURRENT, 0);
						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
							LET cCodret = '00003'; --NO INSERTÓ EL REGISTRO.
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						ELSE
							LET cCodRet = '00000';
							LET sValor = 0;
							LET cDescripcion = 'Empleado Registrado correctamente.';
							LET cMsg = 0;
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						END IF;					
				END IF;
			ELSE
				LET cCodRet = '00001';
				RETURN cCodRet, sValor, cDescripcion, cMsg;
			END IF;
		END IF;		
	END
END PROCEDURE
DOCUMENT
'AUTOR: 96273763, Antonio Cebreros Perez',
'FOLIO: 230202 - 1508 - MttoRemWUyOVoVFrontNte',
'DESCRIPCION: Verifica si el estado es fronterizo, de ser así verificará si el empleado ya ha aceptado los términos impuestos por WU, en caso de no haber aceptado aún, registrará al empleado en la nueva tabla bdisac:sac_registraempleadowu.',
'FECHA: 31/10/2015',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_pay 
(
	pEmpresa			CHAR(3), 
	pMarca              CHAR(2),
	pUsuario			CHAR(8),  
	pBenefNameType 		CHAR(1), 
	pBenefNombreUno		CHAR(40), 
	pBenefNombreDos		CHAR(40), 
	pBenefApaterno		CHAR(40), 
	pBenefAmaterno		CHAR(40), 
	pBenefCiudad 		CHAR(24),-- se adapta a la longitud del campo benef_ciudad  
	pBenefEdo  			CHAR(40), 
	pBeneCP				CHAR(9),-- se adapta a la longitud del campo benef_cp
	pBenefIdType  		CHAR(1), 
	pBenefIdPaisExpedi	CHAR(45), 
	pBenefIdNumber  	CHAR(20), 
	pBenefTieneFechVenc	CHAR(1), 
	pBenefFechaVenc  	CHAR(8),
	pBenefFechNac  		CHAR(8), 
	pBenefOcupacion  	CHAR(30), 
	pBenefCalleNum  	CHAR(40), 
	pBenefColDelMun  	CHAR(40), 
	pBenefPais  		CHAR(45), 
	pBenefTelPart 		CHAR(20), -- se adapta a la longitud del campo benef_tel_particular 
	pBenefTelCel  		CHAR(20), -- se adapta a la longitud del campo benef_tel_celular 
	pBenefEmail  		CHAR(40), 
	pBenefPaisNac  		CHAR(2), 
	pBenefNacionalidad 	CHAR(15), 
	pBenefSexo  		CHAR(1), 
	pBenefCiudadNac		CHAR(20), 
	pBenefEdoNac		CHAR(20), 
	pBenefCodPais		CHAR(3), 
	pBenefCodMoneda		CHAR(3), 
	pMontoOrigen		CHAR(10), 
	pMontoDestino		CHAR(10), 
	pMoneyTransferKey	CHAR(10), 
	pNewMtcn			CHAR(16), 
	pMtcn				CHAR(10), 
	pConfPago			CHAR(1), 
	pForeignRefNumRq	CHAR(16), 
	pFechaHrRq			DATETIME YEAR TO SECOND, 
	pRetCode			CHAR(5), 
	pDatosBufer			CHAR(500), 
	pMtcnRp				CHAR(10), 
	pPuntosGanados		CHAR(4), 
	pWuFechaPago		CHAR(16), 
	pForeignSystemIdRp	CHAR(11), 
	pForeingRefNumRp	CHAR(16), 
	pForeignRsCantIdRp	CHAR(11), 
	pDesError			CHAR(250), 
	pPartnerIdErr		CHAR(10), 
	pFechaHoraRp		DATETIME YEAR TO SECOND, 
	pUserInsert			CHAR(8), 
	pFechaInsert		DATETIME YEAR TO SECOND,
	pSecondIdType		CHAR(1),  --DSB: 03/11/2015 (1508) Antonio Cebreros Pérez.
	pSecondPaisExp		CHAR(44), --DSB: 03/11/2015 (1508) Antonio Cebreros Pérez.
	pSecondIDNumber   	CHAR(30)  --DSB: 03/11/2015 (1508) Antonio Cebreros Pérez.
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
					(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1,    benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type, benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago, foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp, puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert, benef_second_id_type, benef_second_pais_expedicion, benef_second_id_number)
			
			VALUES
					(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun, pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac,  pBenefNacionalidad, pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey, pNewMtcn, pMtcn, pConfPago, cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, pRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago,pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp, pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current, pSecondIdType, pSecondPaisExp, pSecondIDNumber);

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
			LET	cCodRet = '00003'; --- Marca Inválida
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
				(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1, benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type,benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago,foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp,puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err,fecha_hora_rp, user_insert, fecha_insert, benef_second_id_type, benef_second_pais_expedicion, benef_second_id_number)
						
		VALUES
				(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun,pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac, pBenefNacionalidad,pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey,pNewMtcn, pMtcn, pConfPago,cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, cRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago, pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp,pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current, pSecondIdType, pSecondPaisExp, pSecondIDNumber);
					   
		IF  cCodRet <> '00000' THEN
			
			IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
				RETURN cCodRet,cError_Desc;	
			END IF;
		  
            RETURN cCodRet,cError_Desc;		
	    ELSE	
			
			IF cCodRet = '00000' THEN
				LET cError_Desc = "Ejecucion SP exitosa";
			END IF;	
			
           RETURN cCodRet,cError_Desc;
	    END IF;	
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje  <receive-money-pay> (request-reply) en la tabla bdisac:sac_wu_pay',  
'AUTOR: Christian Echavarria',			
'FECHA: 17/Jul/2013',
'DESCRIPCION: Se modifica para que consulte los campos counter_id y  fsid de sac_wu_identificadores',  
'AUTOR: Mario Gallardo',			
'FECHA: 03/10/2013',
'DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
'AUTOR: FRG',
'FECHA: 30/Jul/2014',
'BD: bdisac',
'AUTOR: Mario Olivo',
'Empleado: 95358919',
'Folio: 1457',
'Centro: 230202',
'Descripcion: Se aumenta la longitud del parametro pBenefPais por que se aumento la longitud en la tabla sac_wu_pay para',
'			  guardar el nombre completo del pais.',
'Fecha:10/SEP/2014',
'Version: 20140910.1627',
'AUTOR: Pedro Jimenez',
'Empleado: 95689966',
'Folio: 1485',
'Centro: 230202',
'Descripcion: Se aumenta la longitud de los parametro pBenefCiudad,pBeneCP,pBenefTelPart,pBenefTelCel  por que se aumento la longitud en la tabla sac_wu_pay',
'Fecha:26/02/2015',
'Version: 20150226.1651',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------',
'AUTOR: Antonio Cebreros',
'Empleado: 96273763',
'Folio: 1508 - MttoRemWUyOVoVFrontNte',
'Centro: 230202',
'Descripcion: Se agregan 3 parámetros de entrada al sp debido a que tales parámetros representan 3 nuevas columnas para la tabla sac_wu_pay. En tal caso también se modificaron los insert del sp agregando las columnas correspondientes. Se cambia prefijo de variable productiva cFechaProceso por dFechaProceso.',
'Fecha:04/11/2015',
'Version: 20151104.1200';

CREATE PROCEDURE "informix".sac_bts_movspaso (vempresa char (3))

RETURNING CHAR (5), CHAR (100), CHAR (1), CHAR (1), CHAR (1), CHAR (1), CHAR (1), INTEGER, INTEGER, INTEGER;

--****************************************************************************************************
-- DESCRIPCION:  Proceso de movimientos histórico a tablas _paso para Conciliación Remesas BTS.
-- AUTOR : FRG
-- FECHA : 21/Ene/2014
-- BD: BDISAC
-- SISTEMA : BTS
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE ccodret 				CHAR (5);
DEFINE itot_movssac 		INTEGER;
DEFINE itot_movschqs 		INTEGER;
DEFINE itot_movsbts 		INTEGER;
DEFINE isqlerr      		INTEGER;
DEFINE iisamerr     		INTEGER;
DEFINE cinfoerr     		CHAR (100);
DEFINE cstatussac			CHAR (1);
DEFINE cstatmvhst			CHAR (1);
DEFINE ccuenta_bts			CHAR (20);
DEFINE ctrns_ctrl_efecte	CHAR (4);
DEFINE ctrns_ctrl_crgocte 	CHAR (4);
DEFINE imovsbts_payi		INTEGER;
DEFINE imovsbts_payc		INTEGER;
DEFINE cflg_sac				CHAR (1);
DEFINE cflg_chqs			CHAR (1);
DEFINE cflg_btscj			CHAR (1);
DEFINE cflg_btsab			CHAR (1);
DEFINE cflg_btsrev			CHAR (1);
DEFINE cproceso				CHAR (8);
DEFINE dfechamovs			DATE;
DEFINE iprocsac				INTEGER;
DEFINE cdiamovs				CHAR (2);
DEFINE cmesmovs				CHAR (2);
DEFINE cstmovsbts			CHAR (1);
-- 2014.02.11 FRG-i
DEFINE caniomovs			CHAR (4);
DEFINE cbts_dt				CHAR (8);
-- 2014.02.11 FRG-f

--2014.05.06 EPG
DEFINE cReferencia1         CHAR(20);	
DEFINE iFlagCen             INTEGER;
DEFINE iFlagSuc             INTEGER;
DEFINE cFolio               CHAR(16);
DEFINE dFecha_Pago           DATE;
DEFINE iCuantos             INTEGER;
DEFINE cDescripcionSPJ	 	CHAR(100);
	
	--SET DEBUG FILE TO  '/informix/adrian/sac_bts_movspaso.out';
	--TRACE ON;

/* INICIALIZACION DE VARIABLES */
LET ccodret 				= '00000';
LET itot_movssac 			= 0;
LET itot_movschqs 			= 0;
LET itot_movsbts  			= 0;
LET isqlerr  				= 0;
LET iisamerr  				= 0;
LET cinfoerr 				= "";
LET cstatussac				= "";
LET cstatmvhst				= "";
LET ccuenta_bts				= "";
LET ctrns_ctrl_efecte		= "";
LET ctrns_ctrl_crgocte 		= "";
LET imovsbts_payi			= 0;
LET imovsbts_payc			= 0;
LET cflg_sac				= "0";
LET cflg_chqs				= "0";
LET cflg_btscj				= "0";
LET cflg_btsab				= "0";
LET cflg_btsrev				= "0";
LET cproceso				= "MOVS_BTS";
LET dfechamovs				= CURRENT;
LET iprocsac				= 0;
LET cdiamovs				= "";
LET cmesmovs				= "";
LET cstmovsbts				= "";
-- 2014.02.11 FRG-i
LET caniomovs				= "";
LET cbts_dt			    	= "";
-- 2014.02.11 FRG-i

--2014.05.06 EPG
LET cReferencia1  		    = '';
LET iFlagCen      		    = 0;                 
LET iFlagSuc      		    = 0; 
LET cFolio        		    = ''; 
LET dFecha_Pago             = DATE(1);	
LET	iCuantos      		    = 0;
LET cDescripcionSPJ	 		= 'Inserta movimientos historicos (T-1) BTS a tablas de paso';

	BEGIN
    ON EXCEPTION SET isqlerr, iisamerr, cinfoerr
        IF isqlerr <> 0 THEN
            LET ccodret = isqlerr;
            EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
            RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
        END IF;
    END EXCEPTION;

/*
	Obtención fecha-SAC:
*/
	set isolation to dirty read;
	select {+INDEX(bdisac:sac_fechas 105_11)}
	fecha_hoy 
	into dfechamovs
	from bdisac:sac_fechas
	where empresa = vempresa;
	
	LET dfechamovs = dfechamovs-1;
	
	let cdiamovs = SUBSTR (dfechamovs, 4, 2);
	let cmesmovs = SUBSTR (dfechamovs, 1, 2);
	let caniomovs = SUBSTR (dfechamovs, 7, 4);
	let cbts_dt = caniomovs||cmesmovs||cdiamovs;	
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_BTS_MP', dfechamovs, '0', 'informix', 'sac_bts_movspaso', cDescripcionSPJ);

	if	cmesmovs = '01' AND cdiamovs = '01'
		then
			LET dfechamovs = dfechamovs-1;
		else
			if	cmesmovs = '12' AND cdiamovs = '25'
				then
					LET dfechamovs = dfechamovs-1;
			end if;
	end if;

/*
	Validación término exitoso en proceso de pase movimientos SAC al histórico:
*/
	set isolation to dirty read;
	select count (*) into iprocsac
	from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
	if iprocsac > 0
		then
			select status into cstatussac
			from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
			if cstatussac <> "1"
				then
					update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';					
				else
			end if;
		else
			INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			values (cproceso, dfechamovs, '0', 'informix', current);
	end if;
/*
	Obtención valores parametrizados de transacciones BTS:
*/
	set isolation to dirty read;
	select {+INDEX(bdisac:sac_convenios 103_4)}
	cuenta_prestadora, trans_cen_efectivo_cliente, trans_cen_cargo_cliente
	into ccuenta_bts, ctrns_ctrl_efecte, ctrns_ctrl_crgocte
	from bdisac:sac_convenios
	where numcategoria = '07' and numconvenio = '004';

/*
	Validación termino exitoso en proceso de pase movimientos Cheques al histórico:
*/
	set isolation to dirty read;
	select {+INDEX(bdinteg:sx_contproc 255_612)}
	status_proc into cstatmvhst
	from bdinteg:sx_contproc where fecha = dfechamovs and proceso = 'PasaMovsHist' and sistema = '01';
	
	select status into cstatussac
		from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
	if	cstatussac <> "1" or cstatussac is null
		then
			LET ccodret = "00001";
			LET isqlerr = 0;
			LET iisamerr = 0;
			LET cinfoerr = "Pase de Movimientos Servicios del día a Histórico no ha concluido.";
            EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
            RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
		else
		if	cstatmvhst <> "F" or cstatmvhst is null
			then
				set isolation to dirty read;
				select count (*) into iprocsac
				from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
				if iprocsac > 0
					then
						select status into cstatussac
						from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
						if cstatussac <> "1" or cstatussac is null
							then
								update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';								
							else
								INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
								values (cproceso, dfechamovs, '0', 'informix', current);
						end if;
					else
						INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
						values (cproceso, dfechamovs, '0', 'informix', current);
				end if;
			LET ccodret = "00002";
			LET isqlerr = 0;
			LET iisamerr = 0;
			LET cinfoerr = "Pase de Movimientos Dia a Histórico no ha concluido.";
			EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
			RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
			else
			
			select status into cstmovsbts
			from bdisac:sac_Procesos where proceso = cproceso and fecha_proceso = dfechamovs;
			if cstmovsbts = '1'
				then
					LET ccodret = "00003";
					LET isqlerr = 0;
					LET iisamerr = 0;
					LET cinfoerr = "Pase de Movimientos a tablas _paso ya ha sido ejecutado exitosamente el dia de hoy.";
					EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
				else
					if cstmovsbts = '0'
						then
							update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = cproceso;							
						else
							INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
							values (cproceso, dfechamovs, '0', 'informix', current);
					end if;
			end if;
			
/*
	se confirma flag_confirmacion_sucursal='1' si la remesa esta en cheques y servicios
*/
    FOREACH
        SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1,flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
			INTO  cReferencia1, iFlagCen, iFlagSuc, cFolio, dFecha_Pago
        FROM bdisac:sac_movimientoshistorial
        WHERE numcategoria = '07'
            AND numconvenio = '004'
            AND fecha_pago = dfechamovs
            AND status_cancelado <> 'S'
            AND flag_confirmacion_sucursal = 0

        IF iFlagCen = 0 or iFlagSuc =0 THEN
            SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
            IF iCuantos = 0 THEN
                SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago;   
                IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                END IF;
            END IF;
            IF iCuantos > 0 THEN            
                UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
                WHERE numcategoria = '07'
                    AND numconvenio = '004'
                    AND fecha_pago = dFecha_Pago
                    AND folio_suc = cFolio
                    AND referencia1 = cReferencia1
                    AND status_cancelado <> 'S'
                    AND flag_confirmacion_sucursal = 0;             
            END IF;
        END IF;
	END FOREACH;			
			
/*
	Conteo de registros BTS-SAC del día T-1:
*/
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
			count (*) into itot_movssac		
			from bdisac:sac_movimientoshistorial 
			where 
			numcategoria = '07' and numconvenio = '004'
			and fecha_pago = dfechamovs;

/*
	Conteo de registros BTS-Cheques del día T-1:
*/		
			set isolation to dirty read;
			select {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
			count (*) into itot_movschqs
			from bdicheq:sc_movhis
			where 
			empresa = vempresa and 
			fech_alt = dfechamovs
			and cuenta = ccuenta_bts
			and transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte);

/*
	Conteo de registros BTS-Payi del día T-1:
*/			
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_bts_payi idx_sac_bts_payi3)}
			count (*) into imovsbts_payi
			from "informix".sac_bts_payi
			where 
-- 2014.02.11 FRG-i
			--	fecha_insert::DATE = dfechamovs
			agent_dt = cbts_dt
-- 2014.02.11 FRG-f
			and opcode = '1100';

/*
	Conteo de registros BTS-Payc del día T-1:
*/			
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_bts_payc idx_sac_bts_payc)}
			count (*) into imovsbts_payc
			from "informix".sac_bts_payc
			where 
-- 2014.02.11 FRG-i
			--fecha_insert::DATE = dfechamovs
			agent_dt = cbts_dt
-- 2014.02.11 FRG-f
			and opcode = '1100';
			
			LET itot_movsbts = imovsbts_payi + imovsbts_payc;
			
/*
	Proceso de Inserción de registros del día T-1 en tablas _paso:
*/
			set isolation to dirty read;
			INSERT INTO bdisac:"informix".sac_cheques_paso
				SELECT {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
				folio_suc, fech_alt
				FROM bdicheq:"informix".sc_movhis
				WHERE cuenta = ccuenta_bts
				AND fech_alt = dfechamovs 
				AND transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte)
				and cancelad <> 'S';
				
			set isolation to dirty read;
			INSERT INTO bdisac:"informix".sac_chequesrev_paso
				SELECT {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
				folio_suc, fech_alt
				FROM bdicheq:"informix".sc_movhis
				WHERE cuenta = ccuenta_bts
				AND fech_alt = dfechamovs 
				AND transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte)
				and cancelad = 'S'
				and referencia = 'REV';
			
			LET cflg_chqs = "1";
			
			INSERT INTO bdisac:"informix".sac_servicios_paso
				SELECT {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
				folio_suc, referencia1, status_cancelado, flag_confirmacion_sucursal, fecha_pago, fecha_insert
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria= '07'  
				AND numconvenio='004'
				AND fecha_pago= dfechamovs;
				
			INSERT INTO bdisac:"informix".sac_serviciosrev_paso
				SELECT {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
				folio_suc, referencia1, status_cancelado, fecha_pago
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria= '07'  
				AND numconvenio='004'
				AND fecha_pago= dfechamovs
				AND status_cancelado = 'S';
			
			LET cflg_sac = "1";
			
			INSERT INTO bdisac:"informix".sac_abono_paso
				SELECT {+INDEX(bdisac:sac_bts_payc idx_sac_bts_payc)}
				confirmation_nm, bank_ref_nm, 
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_payc
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1100'
				and process_type_code = 'PAYC';
			
			LET cflg_btsab = "1";
			
			INSERT INTO bdisac:"informix".sac_btscaja_paso
-- 2014.02.11 FRG-i
				--	SELECT confirmation_nm, bank_ref_nm, fecha_insert
				SELECT confirmation_nm, bank_ref_nm, --agent_dt::date
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_payi
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1100';
			
			LET cflg_btscj = "1";
			
			INSERT INTO bdisac:"informix".sac_btsrevi_paso
				SELECT confirmation_nm, bank_ref_nm, --fecha_insert
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_revi
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1200';
			
			LET cflg_btsrev = "1";
			
			if	cflg_chqs = "1" and cflg_sac = "1" and cflg_btsab = "1" and cflg_btscj = "1" and cflg_btsrev = "1"
				then
					LET cinfoerr = 'Inserción en tablas _paso exitoso.';
					update bdisac:sac_procesos set status = '1' where proceso = cproceso and fecha_proceso::date = dfechamovs;
					--ACTUALIZA STATUS EN BITACORA
					EXECUTE PROCEDURE "informix".sp_bitacoraspj (1, 'IND_BTS_MP', dfechamovs, '1', 'informix', 'sac_bts_movspaso', cDescripcionSPJ);
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
				else
					LET ccodret = "00002";
					LET cinfoerr = 'Error en proceso inserción en tablas _paso. Validar Tabla sac_MensajeError.';
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
			end if;
		end if;
	end if;
	END;	
END PROCEDURE;