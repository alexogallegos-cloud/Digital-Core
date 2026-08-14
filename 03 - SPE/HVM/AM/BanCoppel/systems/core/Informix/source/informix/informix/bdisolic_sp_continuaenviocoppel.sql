CREATE PROCEDURE "informix".sp_continuaenviocoppel(pEmpresa CHAR(3),pNumSol CHAR(20),pStatus CHAR(1))
	------------------------------------------------------------------------------------
	-- Autor: Leonardo Daniel Figueroa Lara
	-- Modifica: Se modifica flujo para producto 6001, insercion en nueva tabla para motor de evaluaciÃ³n
	-- Proyecto: Iniciativa Motor evaluaciÃ³n FSF
	------------------------------------------------------------------------------------
	--ModificaciÃ³n: Se agrega bifurcaciÃ³n para productos de motor que no son canal web para insertar en tabla pivote
	--Fecha:21/09/2023
	------------------------------------------------------------------------------------
---DECLARACIONES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cErrorInfo      	CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE cMensajeRet     	CHAR(80);
DEFINE cStatus     		CHAR(2);
DEFINE cCausa_sol     	CHAR(3);
DEFINE cMensaje     	CHAR(80);
DEFINE cHit     		CHAR(1);
DEFINE cStatusSol     	CHAR(2);
DEFINE cStatus_act     	CHAR(2);
-- INC 27 069 AAME 
DEFINE cTipoSol 		CHAR(2); 
DEFINE cDescMttoBCyCC 	CHAR(50); 

DEFINE cTpsolic CHAR(1);
DEFINE cTpsol CHAR(1);
DEFINE cInstitucion CHAR(2);
DEFINE cSolMixta CHAR(20);
DEFINE cEnvioparametrico CHAR(1);

DEFINE cNumCte CHAR(20);
DEFINE cProdMixto CHAR(4);
DEFINE cProducto CHAR(4);
DEFINE cSucursal       CHAR(4);
DEFINE cCanal CHAR(1);
---INICIALIZACIONES
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET cErrorInfo   = "";
LET cCodRet      = "00000";
LET cMensajeRet  = "PROCESO EXITOSO";   
LET cHit   		 = "";
LET cStatusSol   = "";
LET cStatus_act  = "";
LET cTipoSol 	 = "1"; 
LET cDescMttoBCyCC = "";

LET cStatus = "RT";
LET cCausa_sol = "RDO";
LET cMensaje= "Rechazado por estar fuera de politicas";

LET cTpsolic = '';
LET cTpsol = '';
LET cInstitucion = '';
LET cSolMixta  = '';
LET cEnvioparametrico = '';

LET cNumCte = '';
LET cProdMixto = '';
LET cProducto = '';
LET cCanal = '';

BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN ;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/e10000315/EC/sps/mod/sp_continuaenviocoppel"||TRIM(pNumSol)||".out"; 
	--TRACE ON;
	
	-- VALIDA LOS PARAMETROS DE ENTRADA
	IF NVL(pEmpresa,"") =  "" OR NVL(pNumSol,"") = ""  THEN
		LET cCodRet = '00361';
		LET cMensajeRet = 'PARAMETROS DE ENTRADA ESTAN VACIOS';
		RETURN;
	END IF 
	
	--SE CONSULTA PARA VER QUE TIPO DE SOLICITUD ESTA REGRESANDO
	
		 SELECT tipo_solicitud, sucursal, canal_sol
		 INTO cTpsolic, cSucursal, cCanal
		 FROM bdisolic:"informix".ss_solicitudes  
		 WHERE empresa = pempresa
		 AND num_solicitud = pNumSol;	
		 
		--APOLO
		 IF NVL(cCanal,'') =  '9' THEN -- Si la solicitud que llega es de Canal 9 "Apolo" sale del flujo puesto que la logica serÃ¡ tomada por una API.
			RETURN;		 
		 END IF;

IF cTpsolic = 'C' THEN

	IF pStatus = "R" THEN --en caso de estar rechazado se actualiza el status de la solicitud
		--se consulta el status de la solicitud 
			SELECT  status_solicitud
				INTO cStatusSol
			FROM bdisolic:"informix".ss_solicitudes 
			WHERE num_solicitud = pNumSol
			AND empresa = pEmpresa; 
		
		
		--se obtiene la causa con la que se rechazara la solicitud, y su descripcion
		FOREACH		
			SELECT b.causa_rechazo,trim(c.descripcion),b.status,b.condicion
				INTO cCausa_sol,cMensaje,cStatus_act,cHit
			FROM bdisolic:"informix".ss_nuevo_parametrico a
			INNER JOIN bdisolic:"informix".ss_catalogo_rechazosenviocoppel b ON (b.situacion_especial = a.situacion_especial 
																				 AND b.causa_sitesp=a.causa_sitesp)												
			INNER JOIN bdisolic:"informix".ss_causas_sol c ON (c.status_solicitud = "RT" AND c.causa_solicitud = b.causa_rechazo)
			WHERE a.num_solicitud = pNumSol
			AND a.empresa = pEmpresa
			
			IF NVL(cHit,"") = "X" THEN
				IF cStatus_act = cStatusSol THEN
					EXIT FOREACH;
				END IF;
			END IF;
			
		END FOREACH;
		
		EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol
		(pEmpresa, 'sistema',pNumSol, cStatus,cCausa_sol, cMensaje )
		INTO cCodRet;
			---------------------------------------------------------------------------------------------------
			---------------------- ICM FINALIZA PROSPECTEO CUANDO LA RESPUESTA COPPEL ES R  -------------------
			---------------------------------------------------------------------------------------------------
		  UPDATE bdisolic:"informix".ss_prospecteo_solicitudes
		  SET estatus = 'F', status_solicitud = 'RT'
		  WHERE num_solicitud = pNumSol;
			---------------------------------------------------------------------------------------------------
			---------------------- ICM FINALIZA PROSPECTEO CUANDO LA RESPUESTA COPPEL ES R  -------------------
			---------------------------------------------------------------------------------------------------		
					
			--       Actualiza datos de resumen ini
        IF NVL(cHit,"") = "X" THEN
            update bdisolic:"informix".ss_resum_scor_fin
              set evalua_cc = '1',
                  motivo_cc = cMensaje
            where num_solicitud  = pNumSol
              AND empresa       = pEmpresa;
        END IF;
		--       Actualiza datos de resumen fin

	ELSE --en caso de exito o error se continua con el proceso de la solicitud de crÃ©dito
		EXECUTE PROCEDURE bdisolic:"informix".califica_scoring2_cjunk(pEmpresa,pNumSol) INTO cCodRet;
	END IF;
	---   
	--Se agrega la ejecucion de Actualizacion del estatus de la solicitud para las solicitudes de Credito Coppel 
	--para que se contemplen en la reporteria del Monitor de Buro.
	--  INC 27 053, Obtener el estatus actual de la solicitud y actualizar la bandera del reenvÃ­o a exitoso.
	EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_statusmttobcycc( pempresa, pNumSol, cTipoSol )
	INTO cCodRet, cDescMttoBCyCC;

ELSE
	   -- SI ES SOLICITUD BANCO ENTRA SOLO A EVALUACION

		SELECT numcte, num_producto INTO cNumCte, cProducto FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pNumSol;
		IF  EXISTS(SELECT numproducto from bdicred:"informix".sd_productos_motor WHERE numproducto=cProducto) THEN
			IF cCanal <>'4' THEN
				INSERT INTO  bdisolic:"informix".ss_enviossolicitudesmotor
				(empresa, num_solicitud, num_cte, status_consumo, fecha_insert, status_respuesta)
				VALUES  (pEmpresa,pNumSol, cNumCte , 0, current, '');
			ELSE
				INSERT INTO  bdisolic:"informix".ss_enviossolicitudesmotor
				(empresa, num_solicitud, num_cte, status_consumo, fecha_insert, status_respuesta)
				VALUES  (pEmpresa,pNumSol, cNumCte , 1, current, '');
			END IF;
		ELSE
			EXECUTE PROCEDURE bdisolic:"informix".califica_scoring2_cjunk(pEmpresa,pNumSol) INTO cCodRet;
		END IF;
END IF;	



			-------------------------------------------------------------------------------------------------------------
			------------------------SI ES SOLICITUD MIXTA CON PRODUCTO 6001 SE EVALUA------------------------------------
	      SELECT A.num_solicitud_ref, B.envio_parametrico, B.numcte
		  INTO cSolMixta,cEnvioparametrico, cNumCte
		  FROM bdisolic:"informix".ss_resum_scor_fin A
          INNER JOIN bdisolic:"informix".ss_solicitudes B ON B.num_solicitud = A.num_solicitud_ref AND B.empresa = '001'
	      WHERE A.empresa = pempresa
	      AND A.num_solicitud = pNumSol;
		  
		IF cSolMixta IS NULL OR cSolMixta='' THEN LET cSolMixta=''; END IF;
		
		IF cSolMixta <> '' AND cEnvioparametrico = '5' THEN
				LET cCanal='';
				SELECT num_producto, canal_sol INTO cProdMixto, cCanal FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = cSolMixta;
				IF EXISTS(SELECT numproducto from bdicred:"informix".sd_productos_motor WHERE numproducto=cProdMixto) THEN 
					IF cCanal <>'4' THEN
							INSERT INTO  bdisolic:"informix".ss_enviossolicitudesmotor
							(empresa, num_solicitud, num_cte, status_consumo, fecha_insert, status_respuesta)
							VALUES  (pEmpresa,cSolMixta, cNumCte , 0, current, '');
					ELSE
							INSERT INTO  bdisolic:"informix".ss_enviossolicitudesmotor
							(empresa, num_solicitud, num_cte, status_consumo, fecha_insert, status_respuesta)
							VALUES  (pEmpresa,cSolMixta, cNumCte , 1, current, '');
					END IF;
				ELSE
					EXECUTE PROCEDURE bdisolic:"informix".califica_scoring2_cjunk(pEmpresa,cSolMixta) INTO cCodRet;
				END IF;
		END IF;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
	
END;
END PROCEDURE
