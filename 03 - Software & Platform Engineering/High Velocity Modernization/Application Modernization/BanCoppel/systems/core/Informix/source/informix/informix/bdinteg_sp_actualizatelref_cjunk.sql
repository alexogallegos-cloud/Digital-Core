CREATE PROCEDURE "informix".sp_actualizatelref_cjunk(
                             pempresa char(3),
                             pnumcte char(20),
                             psecuencia integer,
                             ptipotel1 char(1),
                             ptelefono1 char(13),
                             ptipotel2 char(1),
                             ptelefono2 char(13),
                             ptipotel3 char(1),
                             ptelefono3 char(13),
                             pextension char(5))
 RETURNing char(5);

-- Se definen variables
DEFINE cCodRet          CHAR(5);
DEFINE iSqlErr          INTEGER;
DEFINE cResulFijoMovil  CHAR(5);
DEFINE cDescFijoMovil   CHAR(5);
DEFINE iFijoMovil1      INTEGER;
DEFINE iFijoMovil2      INTEGER;
DEFINE iFijoMovil3      INTEGER;


LET cCodRet         = '00000';
LET iSqlErr         = 0;
LET cResulFijoMovil = '';
LET cDescFijoMovil  = '';
LET iFijoMovil1     = 0;
LET iFijoMovil2     = 0;
LET iFijoMovil3     = 0;


--DOCUMENTACION:
--Realizó: Daniela Ramirez
--Fecha: 10/06/2011
--Funcionalidad: Actualiza los telefonos de la referencia

   --SET DEBUG FILE TO "/tmp/sp_actualizatelref_cjunk";
    --TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    IF ptelefono1 <> '' THEN
        -- // VERIFICA SI ES MOVIL O FIJO   
        EXECUTE PROCEDURE "informix".sp_tipored (pempresa, ptelefono1) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil1;
        LET ptipotel1 = 'P';
        IF cDescFijoMovil = 'FIJO' THEN
            LET iFijoMovil1 = 0;
        ELIF cDescFijoMovil = 'MOVIL' THEN
            LET iFijoMovil1 = 1;
        ELSE
            LET iFijoMovil1 = 0;
        END IF;
    END IF;
    
    IF ptelefono2 <> '' THEN
        -- // VERIFICA SI ES MOVIL O FIJO   
        EXECUTE PROCEDURE "informix".sp_tipored (pempresa, ptelefono2) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil2;
        LET ptipotel2 = 'C';
        IF cDescFijoMovil = 'FIJO' THEN
            LET iFijoMovil2 = 0;
        ELIF cDescFijoMovil = 'MOVIL' THEN
            LET iFijoMovil2 = 1;
        ELSE
            LET iFijoMovil2 = 0;
        END IF;
    END IF;
    
    IF ptelefono3 <> '' THEN
        -- // VERIFICA SI ES MOVIL O FIJO   
        EXECUTE PROCEDURE "informix".sp_tipored (pempresa, ptelefono3) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil3;
        LET ptipotel3 = 'O';
        IF cDescFijoMovil = 'FIJO' THEN
            LET iFijoMovil3 = 0;
        ELIF cDescFijoMovil = 'MOVIL' THEN
            LET iFijoMovil3 = 1;
        ELSE
            LET iFijoMovil3 = 0;
        END IF;
    END IF;
    
    UPDATE "informix".si_refdirecciones 
            SET (tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, movil_fijo1, movil_fijo2, movil_fijo3) =
                (ptipotel1, ptelefono1, ptipotel2, ptelefono2, ptipotel3, ptelefono3, pextension, iFijoMovil1, iFijoMovil2, iFijoMovil3)
    WHERE numcte = pnumcte  AND secuencia = psecuencia;
    
    RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'Modifico: Rodolfo Tortolero Varela',
'Fecha: 23/06/2013',
'BDD: bdinteg',
'Descripcion: Se agrega validación para validar de acuerdo a la descripción obtenida: ',
'             Si cDescFijoMovil es "FIJO"  - iFijoMovil1, iFijoMovil2, iFijoMovil3 = 0 ',
'             Si cDescFijoMovil es "MOVIL" - iFijoMovil1, iFijoMovil2, iFijoMovil3 = 1 ';

CREATE PROCEDURE "informix".sp_consultarstatusbpi(psEmpresa CHAR(3),psNumCte CHAR(20))
    RETURNING CHAR(5), INTEGER, CHAR(60);

--Declaracion de variables

DEFINE vsNumCte CHAR(20);
DEFINE vsCodRet CHAR(5);
DEFINE vsEdoRet SMALLINT;
DEFINE vsMensajeRet CHAR(60);
DEFINE vsEdoCte SMALLINT;
DEFINE vsEdoCambiar SMALLINT;
DEFINE vsDescEdoCambiar CHAR(60);
DEFINE viSqlErr INTEGER;

--SET DEBUG FILE TO "/tmp/sp_ConsultarStatusBPI.out";
--TRACE ON;

--Asignacion de variables

LET vsNumCte = '';
LET vsCodRet = '00000';
LET vsEdoRet = 0;
LET vsMensajeRet = '';
LET vsEdoCte = 0;
LET vsEdoCambiar = 0;
LET vsDescEdoCambiar = '';
LET viSqlErr = 0;

IF NVL(psNumCte, '') = '' THEN --Valida que el Numero de Cliente nosea nulo o espacio en blanco
	LET vsCodRet = '00001';
	LET vsEdoRet = '';
	LET vsMensajeRet = 'El Numero de Cliente es Requerido.';
ELIF NVL(psEmpresa, '') = '' THEN --Valida que el Numero de Cliente nosea nulo o espacio en blanco
		LET vsCodRet = '00002';
		LET vsEdoRet = '';
		LET vsMensajeRet = 'La Empresa es Requerida.';
ELSE
	IF NOT EXISTS(SELECT numcte FROM bdinteg:si_cliente WHERE numcte = TRIM(psNumCte) AND empresa = TRIM(psEmpresa)) THEN  --Valida que el Numero de Cliente exista
		LET vsCodRet = '00003';
		LET vsEdoRet = '';
		LET vsMensajeRet = 'El Numero de Cliente No Existe.';
	END IF;
END IF;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--Inicio del procedimiento

BEGIN

	ON EXCEPTION SET viSqlErr --Manejador de Errores
		IF viSqlErr <> 0 then
			LET vsCodRet = viSqlErr;
			RETURN vsCodRet,vsEdoRet,vsMensajeRet;
		END IF;
	END EXCEPTION;

	IF vsCodRet = '00000' THEN --Obtiene el estado del Cliente y alos estados que puede cambiar
		SELECT id_status INTO vsEdoCte FROM bdinteg:si_bpiusuarios WHERE numcte = TRIM(psNumCte) AND empresa = TRIM(psEmpresa);
		FOREACH
			SELECT status_destino INTO vsEdoCambiar FROM bdinteg:si_bpicatcambiostatus WHERE status_origen = vsEdoCte 
				AND proceso = '02' ORDER BY status_destino
			SELECT desc_status INTO vsDescEdoCambiar FROM bdinteg:si_bpistatus WHERE id_status = vsEdoCambiar;
			LET vsEdoRet = vsEdoCambiar;
			LET vsMensajeRet = TRIM(vsDescEdoCambiar);
			RETURN vsCodRet,vsEdoRet,vsMensajeRet WITH RESUME;
		END FOREACH;
	ELSE
		RETURN vsCodRet,vsEdoRet,vsMensajeRet;
	END IF
END
END PROCEDURE
DOCUMENT
"Consulta el estatus del cliente de la Banca por Internet e Informa los Estados Posibles a Cambio",
"Autor : Marcos Cuevas",
"FECHA : 20/mayo/2009",
"Ver.  : 1.0",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_guardaresppagosky
(
	pFolioSuc char(16), pIdRespuesta char(3), pAutorizacion char (10), pMeplId char (15), pFechaHoraAutorizacion datetime year to second, pUsoFuturo1 CHAR(256), pUsoFuturo2 CHAR(256),pUsoFuturo3 CHAR(256)
)
	--RETORNOS
	RETURNING
	CHAR(5)  AS cCodigoRet;
	
	--Definicion de Variables
	DEFINE cFolioSuc  CHAR(16);
	DEFINE cCodigoRet CHAR(5);
	DEFINE cFechaDep CHAR(10);
	DEFINE ccaja CHAR(4);
	DEFINE iSqlErr INTEGER;
	DEFINE cFechaFuturo1 CHAR(19);
	DEFINE ctxn_status CHAR(1);
	DEFINE cIdRespuesta CHAR(3);
	DEFINE iIdRespuesta INTEGER;
	
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET iSqlErr = 0;
	LET cFolioSuc = '0';
	LET cFechaDep = '1900-01-01';
	LET ccaja = '0000';
	LET cFechaFuturo1= '';
	LET ctxn_status = '';
	LET cIdRespuesta = '';
	LET iIdRespuesta = 0;
	
	
	--SET DEBUG FILE TO '/home/sysifx/Geovani'; 
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN  TRIM( NVL(cCodigoRet,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		LET cIdRespuesta = pIdRespuesta;
		
		LET iIdRespuesta = TO_NUMBER(cIdRespuesta);
		
		
		IF iIdRespuesta IS NOT NULL THEN
			LET ctxn_status = 'A';
		ELSE
			LET ctxn_status = 'C';
		END IF;
		
		IF NVL(pFolioSuc, '') = '' OR NVL(pIdRespuesta, '') = '' THEN
			 LET cCodigoRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodigoRet;
			 
		ELSE

			
     		LET cFechaFuturo1 = SUBSTR(CURRENT::CHAR(23),1,19);
				
			LET cFechaDep =
			  SUBSTR(cFechaDep, 7,  4)     ||'-'|| -- AAAA
			  SUBSTR(cFechaDep, 1,  2)     ||'-'|| -- MM  
			  SUBSTR(cFechaDep, 4,  2);
				UPDATE "informix".sac_sky_wsgpago SET txn_status = ctxn_status, id_respuesta= pIdRespuesta, autorizacion = pAutorizacion, mpel_id=pMeplId ,fechahoraautorizacion=pFechaHoraAutorizacion,uso_futuro1=pUsoFuturo1,uso_futuro2= pUsoFuturo2 ,uso_futuro3= pUsoFuturo3 WHERE folio_suc = pFolioSuc;

				IF dbinfo('sqlca.sqlerrd2') = 0 THEN
					LET cCodigoRet = '00003';
				END IF;
				
		END IF;			
		
		RETURN  TRIM( NVL(cCodigoRet,""));
		
	END;
END PROCEDURE;