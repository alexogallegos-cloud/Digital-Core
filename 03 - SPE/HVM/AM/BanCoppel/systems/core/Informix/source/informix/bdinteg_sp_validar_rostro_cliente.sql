CREATE PROCEDURE "informix".sp_validar_rostro_cliente(pEmpresa CHAR(3),pIdCte CHAR(9),pOpcion SMALLINT)
	RETURNING CHAR(5) AS CodigoRetorno, CHAR(1) AS Tipo_biometria, CHAR(1) AS Sexo;

-- *	DEFINICION DE VARIABLES
	DEFINE iSqlErr			INTEGER;
	DEFINE cCodRet			CHAR(5);
	DEFINE cTpo_biometria 	CHAR(1);
	DEFINE cSexo 			CHAR(1);

-- *	ASIGNACION DE VARIABLES
	LET	iSqlErr			= 0;
	LET cCodRet			= '00001';
	LET cTpo_biometria	= '';
	LET cSexo 			= '';

-- *	CONTROL DE ERRORES
BEGIN
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet, cTpo_biometria,cSexo;
	    END IF;
	END EXCEPTION;

--SET DEBUG FILE TO '/respaldosbd/cris/coppelface/sp_validar_rostro_cliente.out';
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--VALIDAR PARÁMETROS VACÍOS O NULOS
	IF NVL(TRIM(pEmpresa),'') = '' OR NVL(TRIM(pIdCte),'') = '' OR pOpcion IS NULL THEN
		LET cCodRet = '00002';
	ELSE
		IF pOpcion = 1 THEN
			SELECT NVL(tpo_biometria,'0')
			INTO cTpo_biometria
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa
			AND numcte = pIdCte;

			IF dbinfo("sqlca.sqlerrd2") > 0 THEN
				LET cCodRet = '00000';
				SELECT NVL(sexo,'')
				INTO cSexo
				FROM bdinteg:"informix".si_ctepf
				WHERE empresa = pEmpresa
				AND numcte = pIdCte;
			ELSE
				LET cTpo_biometria	= '';
			END IF;
		END IF;
	END IF;
	RETURN cCodRet, cTpo_biometria,cSexo;
END;
END PROCEDURE
DOCUMENT
'Folio.........: 1433-Reconocimiento_Facial',
'Autor.........: 94565457 - Jose Angel Gaxiola Gaxiola',
'Fecha.........: 15/05/2014',
'Descripcion...: Se crea procedimiento para Validar si el cliente tiene Biometria',
'Solicita......: Daniel Zambada',
'BD............: bdinteg';

CREATE PROCEDURE "informix".sp_consulsolicporenviarcteprospecto(pEmpresa CHAR(3))

	RETURNING CHAR(5),    --Código Retorno
	          CHAR(20),   --Número de Cliente 
              CHAR(20),   --Número de Solicitud
              CHAR(1050); --Trama de envió de cliente 
	
	--Declaracion de variables
	DEFINE iSqlErr          INTEGER;
	DEFINE vCodRet          CHAR(5);    --Código Retorno
	DEFINE vNumCte          CHAR(20);   --Número Cliente
	DEFINE vNumSolicitud    CHAR(20);   --Número Solicitud
	DEFINE vTrama           CHAR(1050); --Trama Alta Cliente
	DEFINE vCodRet2         CHAR(5);    --Código Retorno 2
	DEFINE iClave       	SMALLINT;   --Clave
	DEFINE cSubClave    	CHAR(5);    --SubClave
	DEFINE cIP          	CHAR(1);    --IP
	DEFINE cMac    	        CHAR(1);    --MAC
	DEFINE cOperador  	    CHAR(8);    --Operador
	
	--Inicializacion de variables
	LET vCodRet         = '00000'; --CONSULTA REGISTROS POR ENVIAR.
	LET vNumCte         = '';
	LET vNumSolicitud   = '';
	LET vTrama          = '';
	LET vCodRet2        = '00000';
	LET iClave          = 90;
	LET cSubClave       = "0030";
	LET cIP    	        = " ";
	LET cMac            = " ";
	LET cOperador       = "informix";
	
	SET ISOLATION TO DIRTY READ;
	
	--SET debug FILE TO '/tmp/sp_consulsolicporenviarcteprospecto.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
				LET vCodret = iSqlErr;
				RETURN vCodret, vNumCte, vNumSolicitud, vTrama;
		   END IF;
		END EXCEPTION;
		
		IF pEmpresa = '' OR pEmpresa IS NULL THEN
			LET vCodRet = '00001'; --PARAMETRO DE ENTRADA VACIO.
			RETURN vCodret, vNumCte, vNumSolicitud, vTrama;
		ELSE
			IF EXISTS (SELECT 1 FROM bdinteg: "informix".si_clientescoppelporenviar WHERE empresa = pEmpresa AND status = 0) THEN
				FOREACH
					
					SELECT	numcte, num_solicitud 
					INTO	vNumCte, vNumSolicitud
					FROM	bdinteg: "informix".si_clientescoppelporenviar
					WHERE	empresa = pEmpresa
					AND		status = 0
					
					EXECUTE PROCEDURE "informix".sp_altactecoppelnuevoparametricocteprospecto(pEmpresa, vNumCte, vNumSolicitud)
					INTO vCodRet2, vTrama;
					
					LET vCodRet = '00000';
					
					IF vCodRet2 <> '00000' THEN
						LET vCodRet = '00003'; --ERROR EN EL TRAMA DE ENVIO DEL CLIENTE.
					END IF;
					
					LET vTrama = iClave ||"|"|| TRIM(cSubClave) ||"|"|| TRIM(vTrama) ||"|"|| cIP ||"|"|| cMac ||"|"|| cOperador ||"|";
					
					RETURN vCodret, vNumCte, vNumSolicitud, vTrama WITH RESUME;
					
				END FOREACH;
			ELSE
				LET vCodRet = '00002'; --NO HAY REGISTROS PARA ENVIAR A COPPEL.
				RETURN vCodret, vNumCte, vNumSolicitud, vTrama;
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT
"CREO  : Selene Campos",
"FECHA : 24/10/2014",
'Solicita:	Rodolfo Gomez',
'Descripción:	Se crea clon de sp_consulsolicporenviar.sql y se le modificó para que regresará el número de cliente prospecto coppel',
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_calcula_rfc()
    RETURNING CHAR(5) AS codret;

DEFINE cCodRet      CHAR(5);
DEFINE iSqlErr	    INTEGER;
DEFINE cNumcte      CHAR(20);
DEFINE cApell_Pat   CHAR(26);
DEFINE cApell_Mat   CHAR(26);
DEFINE cNombre      CHAR(55);
DEFINE cFecNac      CHAR(10);
DEFINE cRFCOrig     CHAR(13);
DEFINE cRFCNuevo    CHAR(13);
DEFINE cNombre1		CHAR(26);
DEFINE cNombre2		CHAR(26);
DEFINE cCteDup		CHAR(13);

LET cCodRet      ='00000';
LET iSqlErr		 =0;
LET cNumcte      ='';
LET cApell_Pat   ='';
LET cApell_Mat   ='';
LET cNombre      ='';
LET cFecNac      ='';
LET cRFCOrig     ='';
LET cRFCNuevo    ='';
LET cNombre1	 ='';
LET cNombre2	 ='';
LET cCteDup	     ='';

BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

        --SET DEBUG FILE TO '/informix/VH/soc_fase3/calculo_rfc.out';
		--TRACE ON;
        
        set isolation to dirty read;
        FOREACH  
                
				SELECT numcte
					INTO cNumcte
					from si_rfc_calculados
				
				SELECT c.rfc,trim(c.apell_paterno),trim(c.apell_materno),trim(c.nombre1),trim(c.nombre2),f.fecha_nac,trim(c.nombre1)||' '||trim(c.nombre2)
					INTO cRFCOrig,	cApell_Pat,	cApell_Mat,	cNombre1,cNombre2,cFecNac,cNombre
					from si_cliente c inner join si_ctepf f on c.numcte=f.numcte
					WHERE C.numcte=cNumcte;

				
             EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(cApell_Pat, cApell_Mat, cNombre, cFecNac)
                INTO cCodRet, cRFCNuevo;
       			   	
					
					SELECT numcte--TRAE EL CLIENTE
					INTO cCteDup
					FROM si_cliente
					WHERE rfc=cRFCNuevo--SE VA A TRAER EL CLIENTE DONDE EL RFC=RFC_NUEVO
					AND	numcte <> cNumcte;
																   

				update bdinteg:si_rfc_calculados
				 set rfc_original=cRFCOrig,
					rfc_calculado=cRFCNuevo,
					apell_paterno=cApell_Pat,
					apell_materno=cApell_Mat,
					nombre1=cNombre1,
					nombre2=cNombre2,
					fecha_nac=cFecNac,
					duplicado=cCteDup
				where numcte=cNumcte;
            							
        END FOREACH;
				
       set isolation to dirty read;
        FOREACH 
				SELECT numcte,rfc_calculado
				INTO cNumcte, cRFCNuevo
				from si_rfc_calculados where duplicado is null --trae el cliente donde se hata encontrado un cliente con el mismo rfc
				update  bdinteg:si_cliente set rfc=cRFCNuevo where numcte=cNumcte;
					
        END FOREACH;		
		
		
		RETURN cCodRet;
	END;
			
END PROCEDURE;