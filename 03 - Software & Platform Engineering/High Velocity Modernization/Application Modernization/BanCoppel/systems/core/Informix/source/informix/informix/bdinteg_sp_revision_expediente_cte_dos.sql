CREATE PROCEDURE "informix".sp_revision_expediente_cte_dos(pEmpresa char(3), pNumcte CHAR(20),pNomCte CHAR(107), pRevision SMALLINT,pGerente CHAR(10), pNomGte CHAR (50), pEmpleadoAlta CHAR(10) ,pObservaciones CHAR(250),pSucursal CHAR(4))
RETURNING 	CHAR(5)  AS Cod_Retorno	;

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE iBandera       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);
DEFINE cNumcte			CHAR(20);
DEFINE cReviso			CHAR(10);
DEFINE cRevisoAux			CHAR(10);


---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET iBandera			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';
LET cNumcte				= ' ';
LET cReviso				= ' ';
LET cRevisoAux				= ' ';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN 	cCodRet	;
       END IF;
    END EXCEPTION;
	
	--SET LOCK MODE TO WAIT 3;
    --SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    
	
--SET DEBUG FILE TO "/informix/jesus/sp_revision_expediente_cte.out";
--TRACE ON;

   IF NVL(pNumcte,"") <> "" OR NVL(pEmpresa,"") <> "" THEN 
	
			
		FOREACH WITH HOLD
		SELECT  secuencia, numcte , NVL(reviso,"") 
		INTO iSecuencia,cNumcte, cReviso 
		FROM "informix".si_reporte_expediente 
		--WHERE empresa = pEmpresa AND numcte = pNumcte
		WHERE numcte = pNumcte
		ORDER BY secuencia DESC
			
			LET iBandera = iBandera+1;
			IF iBandera = 1 then 
				Let cRevisoAux = cReviso;
			end if
		END FOREACH
	
		IF pEmpleadoAlta = "" THEN
			SELECT user_insert
			INTO pEmpleadoAlta
			FROM bdinteg:"informix".si_cliente 			
			WHERE empresa =pEmpresa
			AND numcte = pNumcte
			AND tipo_cliente = 1;
			
		END IF;
		
		
		IF NVL(cNumcte,"") = ""  THEN
			INSERT 	INTO "informix".si_reporte_expediente(empresa ,numcte ,secuencia ,nombre_cte ,reviso ,nombre_reviso ,promotor_alta,gerente ,status_revision ,fecha_revision ,observaciones ,user_insert ,fecha_insert,sucursal )
			VALUES (pEmpresa,pNumcte,1,TRIM(pNomCte),pGerente,pNomGte,pEmpleadoAlta,pGerente,pRevision,TODAY,pObservaciones,pGerente,CURRENT,pSucursal);		
		ELSE		
			IF TRIM(cRevisoAux) = TRIM(pGerente) OR iBandera > 1 THEN 			
				UPDATE "informix".si_reporte_expediente
				SET observaciones = pObservaciones,
				status_revision = pRevision ,
				fecha_revision  = TODAY,
				fecha_insert = CURRENT,
				sucursal =pSucursal
				WHERE empresa = pEmpresa
				AND numcte =pNumcte
				AND reviso =pGerente;				
			ELSE			
			
			
				INSERT 	INTO "informix".si_reporte_expediente(empresa ,numcte ,secuencia ,nombre_cte ,reviso ,nombre_reviso ,promotor_alta,gerente ,status_revision ,fecha_revision ,observaciones ,user_insert ,fecha_insert,sucursal )
				VALUES (pEmpresa,pNumcte,2,TRIM(pNomCte),pGerente,pNomGte,pEmpleadoAlta,pGerente,pRevision,TODAY,pObservaciones,pGerente,CURRENT,pSucursal);		
			END IF;
		END IF;
	ELSE
		LET cCodRet ='00001';
	END IF;
	
	RETURN 	cCodRet;	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para consultar clientes para realizar la validaciones de expediente', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 06 mayo 2014',
'VERSION: 201405061209',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultarclientebm(pEmpresa CHAR(3), pNumCte CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(15), -- Numero de celular
	CHAR(12), -- Folio Contrato
	CHAR(70), -- Email
	INTEGER,  -- ID Status
	CHAR(50), -- Usuario
	CHAR(50), -- Password
	CHAR(50), -- Password1
	CHAR(50), -- Password2
	CHAR(50), -- Password3
	INTEGER,  --  Servicio
	INTEGER,  -- Numero de Accesos
	DATE,     -- Fecha ultimo acceso
	INTEGER,  -- Numero de Intentos de Acceso
	CHAR(10), -- Fecha de Nacimiento
	CHAR(20), -- Num Cliente
	CHAR(26), -- A.Paterno
	CHAR(26), -- A.Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(40); -- Descripción Status BM
	
	--DEFINICION DE VARIABLES--
	DEFINE sql_err INT;
	DEFINE vCodRet CHAR(5);
	DEFINE vNumcel CHAR(15);
	DEFINE vFolio_contrato CHAR(55);
	DEFINE vE_mail CHAR(70);
	DEFINE vId_status INTEGER;
	DEFINE vUsuario CHAR(50);
	DEFINE vPassword CHAR(50);
	DEFINE vPassword1 CHAR(50);
	DEFINE vPassword2 CHAR(50);
	DEFINE vPassword3 CHAR(50);
	DEFINE vServicio INTEGER;
	DEFINE vNumaccesos INTEGER;
	DEFINE vFech_ultacces DATE;
	DEFINE vNumintacce INTEGER;
	DEFINE vFechaNac CHAR(10);
	DEFINE vNumCte CHAR(20);
	DEFINE vApePat CHAR(26);
	DEFINE vApeMat CHAR(26);
	DEFINE vNombre1 CHAR(26);
	DEFINE vNombre2 CHAR(26);
	DEFINE vDescStatus CHAR(40);
	DEFINE vcCondDesEnc char(55);
	DEFINE cod_ret char(5);


	--INICIALIZACION DE VARIABLES--
	LET sql_err = 0;
	LET vCodRet = '00000';
	LET vNumcel = '';
	LET vFolio_contrato = '';
	LET vE_mail = '';
	LET vId_status = 0;
	LET vUsuario = '';
	LET vPassword = '';
	LET vPassword1 = '';
	LET vPassword2 = '';
	LET vPassword3 = '';
	LET vServicio = 0;
	LET vNumaccesos = 0;
	LET vFech_ultacces = '';
	LET vNumintacce = 0;
	LET vFechaNac = '01/01/1900';
	LET vNumCte = '';
	LET vApePat = '';
	LET vApeMat = '';
	LET vNombre1 = '';
	LET vNombre2 = '';
	LET vDescStatus = '';
	LET vcCondDesEnc = '';
	LET cod_ret = '';

--	SET DEBUG FILE TO "/informix/JuanRivera/Traces/SP_ConsultarClienteBM.out";
--	TRACE ON;

	BEGIN
	
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN  vCodRet, vNumcel, vFolio_contrato, vE_mail, vId_status, vUsuario, vPassword, 
						vPassword1, vPassword2, vPassword3, vServicio, vNumaccesos, vFech_ultacces,
						vNumintacce,vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2,
						vDescStatus;
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		
		
		
		IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_bm_usuarios WHERE numcte = pNumCte) THEN
									
			SELECT  numcel, folio_contrato,e_mail, id_status, usuario, password, password1, 
					password2, password3, servicio, numaccesos, fech_ultacces, numintacce
			  INTO	vNumcel, vFolio_contrato, vE_mail, vId_status, vUsuario, vPassword, vPassword1, 
					vPassword2, vPassword3, vServicio, vNumaccesos, vFech_ultacces, vNumintacce
			  FROM	bdinteg:"informix".si_bm_usuarios
			 WHERE	empresa = pEmpresa
			   AND	numcte = pNumCte;
			   
			SELECT bdi_sictepf.fecha_nac, bdi_sicte.numcte, bdi_sicte.apell_paterno,
				   bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2,bdi_sista.desc_status
			INTO vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2,vDescStatus
			FROM bdinteg:"informix".si_cliente bdi_sicte, 
				 bdinteg:"informix".si_ctepf bdi_sictepf,
				 bdinteg:"informix".si_bpistatus bdi_sista
			WHERE bdi_sicte.numcte = pNumCte
			AND bdi_sicte.empresa = pEmpresa
			AND bdi_sicte.tpo_persona = '01'
			AND bdi_sicte.numcte = bdi_sictepf.numcte
			AND bdi_sista.id_status = vId_status;
			
		ELSE
			
			SELECT NVL(folio_contrato,'') INTO vFolio_contrato
			FROM bdinteg:"informix".si_bpiusuarios
			WHERE empresa = pEmpresa AND numcte = pNumcte AND id_status not in (99, 0, 1, 2, 3, 4);
		
			SELECT bdi_sictepf.fecha_nac, bdi_sicte.numcte, bdi_sicte.apell_paterno,
				   bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2
			INTO vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2
			FROM bdinteg:"informix".si_cliente bdi_sicte, 
				 bdinteg:"informix".si_ctepf bdi_sictepf
			WHERE bdi_sicte.numcte = pNumCte
			AND bdi_sicte.empresa = pEmpresa
			AND bdi_sicte.tpo_persona = '01'
			AND bdi_sicte.numcte = bdi_sictepf.numcte;

			LET vCodRet = '00001'; -- Cliente no tiene servicio de BM
			
			
			IF LENGTH(vFolio_contrato) >12 THEN
		
				-- Entra a Desencripta folio solo cuando el folio esta encriptado
				EXECUTE PROCEDURE bdibpi:"informix".sp_desencripta_folio_contrato_bpi(vFolio_contrato) INTO cod_ret, vcCondDesEnc;	
				LET vFolio_contrato = vcCondDesEnc;
				
			END IF;
			
		END IF;
		
		RETURN  vCodRet, vNumcel, vFolio_contrato, vE_mail, vId_status, vUsuario, vPassword, vPassword1, 
				vPassword2, vPassword3, vServicio, vNumaccesos, vFech_ultacces, vNumintacce,vFechaNac, 
				vNumCte, vApePat, vApeMat, vNombre1, vNombre2,vDescStatus;
	END
	
END PROCEDURE

DOCUMENT
'Consulta datos del cliente para la Banca Movil',
'Autor :Daniela Ramírez',
'FECHA : 12/Septiembre/2011',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_validafolio_suc_bpi(pEmpresa char(3),pFolio char(55),pSucursal char(4), pNumCte char (16), pFecha DATE)
		RETURNING char(5), char(9);

--Define variables
define sql_err integer;
define cod_ret char (5);
define vNumcte char(9);
define vFolio char(12);
define vSuc char(4);
define vTipo char (1);
define vNumcteTar char (9);

define vcCondDesEnc char(12);
define vc_folioact  char(55);
define vn_tamanio  smallint;
define vc_folio_contrato char(55);
define vc_folio_contrato_alterno char(55);

--Inicializa Variables
LET sql_err = 0;
LET cod_ret = '000';
LET vNumcte = '';
LET vFolio = '';
LET vSuc = '';
LET vTipo = '';
LET vNumcteTar = '';

LET vcCondDesEnc = '';
LET vc_folioact = '';
LET vn_tamanio = 0;
LET vc_folio_contrato = '';
LET vc_folio_contrato_alterno = '';

--RealizÃ?: Javier A. ChÃÂ¡vez Trujillo
--Fecha: 22/12/08
--SolicitÃ?: Mauricio LeÃ?n
--Actividad: Valida el folio y numero de sucursal, y obtiene el numero del cliente
---------------------------------------
--ModificÃ?: Javier A. ChÃÂ¡vez Trujillo
--Fecha: 19/08/09
--Actividad: Se agregÃ? la fecha de nac como parÃÂ¡metro para validarla.
---------------------------------------
--ModificÃ?: Javier A. ChÃÂ¡vez Trujillo
--Fecha: 24/09/09
--Actividad: Se agregÃ? validaciÃ?n de tipo de tarjeta.
-----------------------------------------------------------
-- Se agrega cÃ?digo de retorno de error cuando se captura nÃÂºmero de tarjeta y algun otro dato capturado es incorrecto.
-- Fecha: 15/01/2016
-- Bibiana Gaxiola Verdugo
--------------------------------------------------------

    --SET DEBUG FILE TO '/informix/JuanRivera/Traces/sp_validafolio_suc_bpi.out';
    --TRACE ON;

BEGIN

     ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                    LET cod_ret = sql_err;
                    RETURN cod_ret, vNumcte;
            END IF;
     END EXCEPTION;
     
     Select folio_contrato into vc_folio_contrato 
       from bdinteg:si_bpiusuarios a
      Where a.numcte = pNumCte;
      
      -- Buscar folio contrato por TDC o TDD
      IF length(vc_folio_contrato) = 0 OR NVL(vc_folio_contrato,'') = '' OR vc_folio_contrato IS NULL THEN
        -- Busca numero de cliente a partir de TDC
        SELECT numcte INTO vNumcteTar FROM bdicheq:sc_tarjeta 
         WHERE num_tarjeta = pNumCte;
         
        IF length(vNumcteTar) = 0 OR NVL(vNumcteTar,'') = '' OR vNumcteTar IS NULL THEN
            -- Busca numero de cliente a partir de TDC
            SELECT numcte INTO vNumcteTar FROM bdicred:sd_tarjeta 
            WHERE num_tarjeta = pNumCte; 
                                                      
        END IF;
        
        LET pNumCte = vNumcteTar;
        
        -- Se obtiene el numero de contrato encriptado del cliente 
        Select folio_contrato into vc_folio_contrato from bdinteg:si_bpiusuarios a
         Where a.numcte = vNumcteTar;  
               
      END IF;
       
     LET vn_tamanio = length(TRIM(vc_folio_contrato));
      
     IF  vn_tamanio > 12 THEN
         Select folio_contrato into vc_folioact 
           from bdinteg:si_bpiusuarios a
          Where a.numcte = pNumCte;
      
         -- Desencripta el folio
         EXECUTE PROCEDURE bdibpi:"informix".sp_desencripta_folio_contrato_bpi(vc_folioact) INTO cod_ret, vcCondDesEnc;

        IF pFolio = vcCondDesEnc THEN
            LET pFolio = TRIM(vc_folioact);
            LET cod_ret = '000';
        ELSE
            SELECT folio_contrato_suc, folio_contrato_alterno  INTO vc_folioact, vc_folio_contrato_alterno  FROM bdinteg:si_bpiusuarios_folioalterno a WHERE a.numcte = pNumCte;
             -- Desencripta el folio
             EXECUTE PROCEDURE bdibpi:"informix".sp_desencripta_folio_contrato_bpi(vc_folioact) INTO cod_ret, vcCondDesEnc;
             IF pFolio = vcCondDesEnc THEN
                LET pFolio = TRIM(vc_folio_contrato_alterno);
                LET cod_ret = '000';
             ELSE
                LET cod_ret = '002';
             END IF;
        END IF;
        
     END IF;

     IF(LENGTH(TRIM(pNumCte)) = 9 ) THEN
     
			SELECT a.numcte INTO vNumcte
            FROM bdinteg:si_bpiusuarios a
			INNER JOIN  bdinteg:si_ctepf f ON a.numcte = f.numcte
            WHERE a.empresa = pEmpresa 
			  AND a.folio_contrato = pFolio
			  AND a.suc_registro = pSucursal 
			  AND a.numcte = pNumCte 
			  AND f.fecha_nac = pFecha;

			IF NVL(vNumcte,'') = '' THEN
				LET cod_ret = '002'; --El cliente no existe
			END IF;

	ELIF (LENGTH(TRIM(pNumCte)) = 16 ) THEN

		SELECT creditodebito INTO vTipo FROM intercard:bines  where bin = substring(pNumCte FROM 1 FOR 6);

		IF(vTipo=='D') THEN
			SELECT numcte INTO vNumcteTar FROM bdicheq:sc_tarjeta WHERE num_tarjeta = pNumCte;

			IF NVL(vNumcteTar,'') = '' THEN
				LET cod_ret = '002'; --El Cliente no existe con esa tarjeta
			ELSE
				SELECT a.numcte INTO vNumcte
				FROM bdinteg:si_bpiusuarios a
				INNER JOIN  bdinteg:si_ctepf f ON a.numcte = f.numcte
				WHERE a.empresa = pEmpresa 
				  AND a.folio_contrato = pFolio 
				  AND a.suc_registro = pSucursal 
				  AND a.numcte = vNumcteTar 
				  AND f.fecha_nac = pFecha;

				IF NVL(vNumcte,'') = '' THEN
					LET cod_ret = '002'; --El Cliente no existe con los datos capturados
				END IF;

			END IF;

		ELIF (vTipo == 'C') THEN

			SELECT numcte INTO vNumcteTar FROM bdicred:sd_tarjeta WHERE num_tarjeta = pNumCte;

			IF NVL(vNumcteTar,'') = '' THEN
				LET cod_ret = '002'; --El Cliente no existe con esa tarjeta
			ELSE
				SELECT a.numcte INTO vNumcte
				FROM bdinteg:si_bpiusuarios a
				INNER JOIN  bdinteg:si_ctepf f ON a.numcte = f.numcte
				WHERE a.empresa = pEmpresa 
				AND a.folio_contrato = pFolio 
				AND a.suc_registro = pSucursal 
				AND a.numcte = vNumcteTar 
				AND f.fecha_nac = pFecha;

				IF NVL(vNumcte,'') = '' THEN
					LET cod_ret = '002'; --El Cliente no existe con los datos capturados
				END IF;

			END IF;

		ELSE
			LET cod_ret = '003'; --El tipo de tarjeta no existe
		END IF;

	 ELSE
        LET cod_ret = '001'; --El nÃ?mero introducido es incorrecto
     END IF ;


    RETURN cod_ret, vNumcte;

END;
END PROCEDURE;