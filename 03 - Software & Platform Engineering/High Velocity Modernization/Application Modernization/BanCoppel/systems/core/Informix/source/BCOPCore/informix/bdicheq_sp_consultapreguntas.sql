CREATE PROCEDURE "informix".sp_consultapreguntas()

   RETURNING CHAR(5), CHAR(300);
      
   DEFINE cCodRet   CHAR(5); 
   DEFINE cPregunta CHAR(300);
   
   LET cCodRet 		   = '00000';
   LET cPregunta 	   = "";  
   
   SET ISOLATION DIRTY READ;
   SET LOCK MODE TO WAIT 3;

  FOREACH
            select pregunta 
                    into  cPregunta
            FROM sc_cuestionario

                IF cPregunta <> "" THEN
					LET cCodRet = '00000';
				ELSE
					LET cCodRet = '00001';
				END IF;

            RETURN cCodRet, cPregunta WITH RESUME;
   END FOREACH;
    
BEGIN

END;
END PROCEDURE
DOCUMENT
'AUTOR: Abdon Obed Hernandez Cebreros',
'FECHA: 25/11/2019',
'BD: BDICHEQ',
'Proyecto Tarjetas Personalizadas',
'Objetivo: Se crea consulta para traer las preguntas de la encuesta';

CREATE PROCEDURE "informix".sp_inserta_solicitud_portabilidad_web(pEmpresa CHAR(3), 
													  pSucursal CHAR(4), 
													  pNumCte CHAR(20),
													  pBancoOrd CHAR(3),
													  pCtaOrd CHAR(20),													  
													  pTipoCtaOrd CHAR(2), 
													  pBancoRec CHAR(3), 
													  pCtaRec CHAR(20), 
													  pTipoCtaRec CHAR(2),
													  pRFCEmpresa CHAR(12),
													  pCodOperacion CHAR(2),
													  pEstatusCecoban CHAR(2),
													  pEstatusResp CHAR(2),
													  pEstatusPort CHAR(2),
													  pCveOrigen CHAR(1),
													  pCveSentido CHAR(1),
													  pNumIntentos INTEGER,
													  pFolioSol CHAR(30),
													  pUserInsert CHAR(8),
													  pComentario CHAR(60),
													  pTipo INTEGER)
--DATOS A REGRESAR---												 
	RETURNING
	CHAR(5) AS cCodRet;
	
---DECLARACIONES
DEFINE iSqlErr  	INTEGER;
DEFINE cCodRet  	CHAR(5);
DEFINE cCodRetSP  	CHAR(6);
DEFINE cCveBcoOrd   CHAR(5);
DEFINE cCveBcoRec   CHAR(5);
DEFINE cCtaRef  	CHAR(20);
DEFINE cTarjRef   	CHAR(20);
DEFINE cFecha		CHAR(10);
DEFINE dFecha		DATE;
DEFINE cCodigoError CHAR(5);
DEFINE sFuenteError SMALLINT;
DEFINE cMenRetSp    CHAR(110);
DEFINE cCuenta      CHAR(20);
DEFINE cProced_aper CHAR(2);

DEFINE vcuenta      CHAR(20);

---INICIALIZACIONES
LET iSqlErr      = 0;
LET cCodRet      = "00000";
LET cCodRetSP    = "00000";
LET cCveBcoOrd   = "";
LET cCveBcoRec   = "";
LET cCtaRef   	 = "";
LET cTarjRef   	 = "";
LET cFecha	 	 = '01/01/1990';
LET dFecha 		 = DATE(1);
LET cCodigoError = "";
LET sFuenteError = 0;
LET cProced_aper = '00';

LET vcuenta      = ''; 

BEGIN
    ON EXCEPTION SET iSqlErr	
	IF 	iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END IF
END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	 --SET DEBUG FILE TO "/home/sysifx/moises/bdicheq/sp_inserta_solicitud_portabilidad.out";
	 --TRACE ON;
	
	IF NVL(pEmpresa,'') = "" OR NVL(pSucursal,'') = "" OR (NVL(pTipo,0) <> 1 AND NVL(pTipo,0) <> 2) THEN	
		LET cCodRet = "00001"; --PARAMETROS VACIOS
		RETURN cCodRet;			
	ELSE			
		
		SELECT fecha_hoy
		INTO dFecha
		FROM bdicheq:"informix".sc_fechas 
		WHERE empresa = pEmpresa;
			
		LET cFecha = TO_CHAR(dFecha, '%Y%m%d');
		
		SELECT cvecesif
		INTO cCveBcoOrd
		FROM bdinteg:"informix".si_bancos
		WHERE banco = pBancoOrd;			   
   
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = "01289";
			RETURN cCodRet;	
		END IF;
		
		SELECT cvecesif
		INTO cCveBcoRec
		FROM bdinteg:"informix".si_bancos
		WHERE banco = pBancoRec;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = "01289";
			RETURN cCodRet;	
		END IF;
		
		IF NVL(pTipoCtaOrd,"") = "40" THEN
		
				EXECUTE PROCEDURE bdispei:"informix".sp_validadv(pCtaOrd)
				INTO cCodigoError,sFuenteError;				
				
				IF NVL(cCodigoError,"") = "0" AND NVL(sFuenteError,0) = 1 THEN
				
				ELSE
					LET cCodRet = "01283";
					RETURN cCodRet;	
				END IF;
		
		ELIF NVL(pTipoCtaOrd,"") = "3" THEN
			
		ELIF NVL(pTipoCtaOrd,"") <> "3" OR NVL(pTipoCtaOrd,"") <> "40" THEN
			LET cCodRet = "01292";
			RETURN cCodRet;
		END IF;
		
		
		IF NVL(pTipoCtaRec,"") = "40" THEN
	 
				LET cCtaRef = pCtaRec;
		
				EXECUTE PROCEDURE bdispei:"informix".sp_validadv(pCtaRec)
				INTO cCodigoError,sFuenteError;
				
				IF NVL(cCodigoError,"") = "0" AND NVL(sFuenteError,0) = 1 THEN
				
				ELSE
					LET cCodRet = "01283";
					RETURN cCodRet;	
				END IF;
		
		ELIF NVL(pTipoCtaRec,"") = "3" THEN
		
				LET cTarjRef = pCtaRec;
				
		ELIF NVL(pTipoCtaRec,"") <> "3" OR NVL(pTipoCtaRec,"") <> "40" THEN
			LET cCodRet = "01293";
			RETURN cCodRet;			
		END IF;
		
		INSERT INTO bdicheq:"informix".sc_portacec_solicitud (empresa,folio_solicitud,sucursal,num_cte,bco_ordenante,cta_ordenante,tipo_cta_ordenante,bco_receptor,cta_receptora,tipo_cta_receptora,fecha_solicitud,rfc_empresa,cod_operacion,fecha_presentacion,estatus_cecoban,fecha_estatus_cecoban,estatus_respuesta,fecha_respuesta,estatus_portabilidad,fecha_estatus_portabilidad,clave_origen,clave_sentido,num_intentos,user_insert,fecha_solca_portabilidad,comentario) 
		VALUES (pEmpresa,pFolioSol,pSucursal,pNumCte,cCveBcoOrd,pCtaOrd,pTipoCtaOrd,cCveBcoRec,pCtaRec,pTipoCtaRec,cFecha,pRFCEmpresa,pCodOperacion,'',pEstatusCecoban,'',pEstatusResp,'',pEstatusPort,'',pCveOrigen,pCveSentido,pNumIntentos,pUserInsert,'',pComentario);

		IF NVL(pTipo,0) = 1 THEN
		
			RETURN cCodRet;
			
		ELIF NVL(pTipo,0) = 2 THEN 
			---Se agrega actualizacion del origen de recursos en la cuenta BCPL 		
			SELECT proced_aperturacta 
			INTO cProced_aper
			FROM bdicheq:"informix".sc_maechq
			WHERE cuenta_clabe = pCtaOrd;
			
			IF cProced_aper <> '02' THEN
				UPDATE bdicheq:"informix".sc_maechq 
				SET proced_aperturacta ='02' 
				WHERE cuenta_clabe = pCtaOrd;
			END IF;
			--- Termina actualizacion del origen de recursos en la cuenta BCPL
				LET vcuenta = substr(pCtaOrd, 7, 11);
						
                SELECT cuenta
                INTO cCuenta
                FROM bdicheq:"informix".sc_maechq
                WHERE empresa = pEmpresa
				AND cuenta = vcuenta;

			IF (pSucursal = '5003') THEN --DESB 11022016
				EXECUTE PROCEDURE bdicheq:"informix".sp_portabprocesaalta ('WEB',pSucursal,pNumCte,cCuenta,pBancoRec,cCtaRef,cTarjRef,pComentario,pUserInsert)
				INTO cCodRetSP, cMenRetSp;
			ELSE
				EXECUTE PROCEDURE bdicheq:"informix".sp_portabprocesaalta ('OFI',pSucursal,pNumCte,cCuenta,pBancoRec,cCtaRef,cTarjRef,pComentario,pUserInsert)
				INTO cCodRetSP, cMenRetSp;
			END IF;
			
              IF cCodRetSP <> '00000' THEN
                   DELETE bdicheq:"informix".sc_portacec_solicitud 
                   WHERE empresa = pEmpresa
                    AND num_cte = pNumCte 
                    AND cta_ordenante = pCtaOrd
                    AND cta_receptora = pCtaRec;
                    
                    LET cCodRetSP = '01272';
					LET cCodRet = cCodRetSP;
              
              END IF;
            --BCPL 2210215

				RETURN cCodRet;		
		END IF;
	
	END IF;
END;
END PROCEDURE
DOCUMENT
"Descripcion: Se crea procedimiento para insertar la solicitud de alta de portabilidad de nomina para los casos de BanCoppel a .",
"			  otro banco Ã³ de otro banco a BanCoppel.",
"Codigos de Error: ",
"",
"			cCodRet = 000001 Parametros Vacios.",
"			cCodRet = 001283 La cuenta CLABE es incorrecta; ultimo numero (digito verificador) invalido.",
"			cCodRet = 001289 No existe informacion. Favor de verificar.",
"			cCodRet = 001292 El tipo de Cuenta Ordenante es distinta, verifique.",
"			cCodRet = 001293 El tipo de Cuenta Receptora es distinta, verifique.",
"",
"Autor  : Jairo Valdez Gonzalez",
"Solicito: Ivan Castillo Montalvo",
"Folio: 1748",
"Sustento: RQM 10 610 Cambios en el Servicio de Portabilidad",
"Fecha  : 28/08/2015",
"BD     : bdicheq",
"****************************************************************************************************************************",
"Modificacion: Se modifica para agregar el origen de alta 'WEB' al procesar el alta.",
"ModificÃ³  : MoisÃ©s Soriano",
"SolicitÃ³: Alejandro Vazquez",
"Folio: 1636",
"Fecha  : 11/02/2015";

CREATE PROCEDURE "informix".sp_obt_banderaadn_web()
RETURNING CHAR(5) AS CodigoRetrono, CHAR(2)    AS  Activo;

    DEFINE cCodRet    CHAR(5);
    DEFINE cCodRet2   CHAR(5); 
    DEFINE cActivo    CHAR(2);
    
    LET cCodRet	  = '00000';
    LET cCodRet2  = '00000';
    LET cActivo   ='0';

    BEGIN    
        --- SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtienectascancel.out";
        --- TRACE ON; 
		
		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        SELECT valor 
        INTO cActivo
        FROM  bdicred:"informix".sd_param
        WHERE empresa='001' and cod_param='090';

        RETURN cCodRet,NVL(cActivo,"0");
    END
END PROCEDURE;