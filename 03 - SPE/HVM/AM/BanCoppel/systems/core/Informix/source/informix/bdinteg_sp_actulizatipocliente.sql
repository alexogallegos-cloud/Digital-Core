CREATE PROCEDURE "informix".sp_actulizatipocliente (psEmpresa CHAR(3), 
													psNumCliente CHAR(20), 
													piTipoEjecucion INTEGER, 
													pSucursal CHAR(4)) --Sucursal para insertar registro en si_sucmatriz  --DSB 22/05/2020
RETURNING	 CHAR(5) AS Retorno

	DEFINE iSqlErr            INTEGER;
	DEFINE cCodRet            CHAR(5);
	DEFINE cCodIdentifi       CHAR(2);
	DEFINE cNumIdentifi       CHAR(30);
	DEFINE iIdentOficial      INTEGER;
	DEFINE iComDomicilio      INTEGER;
	DEFINE dFecha             DATE;
	DEFINE dFechaNacimiento   DATE;
	DEFINE cCodRetFecha       CHAR(5);
	DEFINE iEdad              INTEGER;
	DEFINE iBandera           INTEGER;
	
	----Varibles Mensaje Afore
	DEFINE cNumEmpleado		  CHAR(8);
	DEFINE cSucursal		  CHAR(4);		  
	DEFINE cCurp		 	  CHAR(18);
	DEFINE cApellPaterno	  CHAR(26);
	DEFINE cApellMaterno	  CHAR(26);
	DEFINE cNombre1	 		  CHAR(26);
	DEFINE cNombre2	  		  CHAR(26);
	DEFINE dFechaNac		  DATE;	
	DEFINE cEntidadNac		  CHAR(2);	
	DEFINE cSexo			  CHAR(1);
	DEFINE cAvisoCte		  CHAR(1);
	DEFINE cSucursalEjecut	  CHAR(4);
	DEFINE iSolicitud		  SMALLINT;  --DSB 22/05/2020
	DEFINE cTipoCliente       CHAR(20);  --DSB 22/05/2020
	DEFINE cSucOrigen      	  CHAR(4);   --DSB 22/05/2020
	DEFINE iCteMatriz      	  SMALLINT;  --DSB 22/05/2020
	
	
	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Felipe Urias
	-- FECHA: 14/08/2012
	-- DESCRIPCION: Realiza la validaciones necesarias para que un cliente sea considerado titulas y de 
	--              cumplir con estas realiza la actualizacion del tipo de cliente.
	------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	-- MODIFICO:    Felipe Urias
	-- FECHA:       02/01/2013
	-- DESCRIPCION: se agrega consultas de fecha de nacimiento del cliente y consulta de la fecha actual
	--              se agrega validacion de edad  para que los menores no validen identificacion.
	------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	-- MODIFICO:    Rodolfo Tortolero
	-- FECHA:       22/02/2013
	-- DESCRIPCION: se agrega la misma funcionalidad que se utiliza en el sp_valida_aviso_privacidad
	--              para validar si el cliente tiene el aviso de privacidad. 
	--              Se modifica para que consulte los documentos digitalizados en la tabla 
	--              bdidigital@coppelimg_tcp:dg_expediente_img.
	--              Se agrega validaciÃÂ³n para clientes menores de edad no sea abligatorio el campo 
	--              nÃÂ¹mero identificaciÃÂ³n.
	------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	-- MODIFICO:Jonathan Medina
	-- FECHA:22/05/2020
	-- DESCRIPCION: Se agrega parametro pSucursal para insertar en la tabla si_sucmatriz la sucursal en donde se digitaliza documentos del cliente, que traiga una solicitud web.
	-- SOLICITO: ABRAHAM NARVAEZ
	-- FOLIO: 675  Adendum Solicitud Web Tarjeta de CrÃ©dito Bancoppel y Tarjeta Departamental Coppel
	-- DSB 22/05/2020
		------------------------------------------------------------------------------------------------------
	LET iSqlErr          = 0;
	LET cCodRet          = '00001';
	LET cCodIdentifi     = '';
	LET cNumIdentifi     = '';
	LET iIdentOficial    = 0;
	LET iComDomicilio    = 0;
	LET dFecha           = '';
	LET dFechaNacimiento = '';
	LET cCodRetFecha     = '00000';
	LET iEdad            = 0;
	LET iBandera         = 0;
	
	LET cNumEmpleado  = '';
	LET cSucursal	  = '';
	LET cCurp		  = '';
	LET cApellPaterno = '';
	LET cApellMaterno = ''; 
	LET cNombre1	  = '';
	LET cNombre2	  = '';
	LET dFechaNac	  = DATE(1);
	LET cEntidadNac	  = '';
	LET cSexo		  = '';
	LET cAvisoCte	  = '';
	LET cSucursalEjecut = '';
	LET iSolicitud    = 0;  --DSB 22/05/2020
	LET cTipoCliente  = ''; --DSB 22/05/2020
	LET cSucOrigen    = ''; --DSB 22/05/2020
	LET iCteMatriz    = 0;  --DSB 22/05/2020
	
	--SET DEBUG FILE TO "/tmp/sp_actulizatipocliente.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = CAST(iSqlErr AS CHAR(5));
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--Validar cliente Titular --DSB 22/05/2020
		SELECT tipo_cliente, sucursal
		INTO cTipoCliente, cSucOrigen
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = psNumCliente;
		
		
        IF  EXISTS(SELECT 1 FROM  bdinteg:"informix".si_direcciones_actual WHERE numcte = psNumCliente AND tipo_dir = 1 AND secuencia = (SELECT MAX(secuencia) FROM si_direcciones_actual WHERE numcte = psNumCliente AND tipo_dir = 1))THEN

			SELECT codidentifi, numidentifi, fecha_nac
			INTO cCodIdentifi, cNumIdentifi, dFechaNacimiento
			FROM bdinteg:"informix".si_ctepf
			WHERE empresa = psEmpresa
			AND numcte = psNumCliente;

            SELECT fecha_hoy 
            INTO dFecha
            FROM bdinteg:"informix".si_fechas
			WHERE empresa = psEmpresa;
			
			EXECUTE PROCEDURE sp_ObtenerEdadPersona(dFecha, NVL(dFechaNacimiento, '1900/01/01') )
			INTO cCodRetFecha, iEdad;
			
		    IF TRIM(cCodRetFecha) = '000' THEN
			    IF iEdad >=18 THEN
				    IF TRIM (NVL(cCodIdentifi,'')) <> '' AND TRIM (NVL(cNumIdentifi, '')) <> '' THEN
					    LET iBandera = 1;
				    END IF;
			    ELSE
			        IF TRIM (NVL(cCodIdentifi,'')) <> '' THEN
					    LET iBandera = 1;
				    END IF;
			    END IF;
			END IF;
			
			IF iBandera = 1 THEN

				IF EXISTS(SELECT 1 FROM bdinteg:"informix".si_cte_huella WHERE numcte = psNumCliente AND estado = 'A' AND secuencia = (SELECT MAX(secuencia)	FROM bdinteg:"informix".si_cte_huella WHERE numcte = psNumCliente AND estado = 'A')) THEN

					--IF  EXISTS(SELECT 1 FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente)THEN
					IF  EXISTS(SELECT 1 FROM bdinteg:"informix".si_cliente
						WHERE numcte IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq  WHERE empresa = psEmpresa AND num_cte = psNumCliente)
						   OR numcte IN (SELECT num_cte FROM bdinvers:"informix".sv_maeinv WHERE empresa = psEmpresa AND num_cte = psNumCliente)
						   OR numcte IN (SELECT numcte  FROM bdicred:"informix".sd_maecred WHERE empresa = psEmpresa AND numcte  = psNumCliente)
						   OR numcte IN (SELECT numcte  FROM bdisolic:"informix".ss_solicitudes WHERE empresa = psEmpresa AND numcte  = psNumCliente)
						   OR numcte IN (SELECT numcte  FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente AND respuesta = '1'))THEN
		
						IF piTipoEjecucion = 2 THEN
						
							/*IF EXISTS(SELECT 1 FROM bdidigital:"informix".dg_expediente_envio WHERE cliente = psNumCliente AND cod_docto IN('0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')) THEN
								LET iIdentOficial = 1;
							END IF;
							IF EXISTS(SELECT 1 FROM bdidigital:"informix".dg_expediente_envio WHERE cliente = psNumCliente AND cod_docto IN('0012','0015','0016','0017','0018','0031','0032','0033')) THEN
								LET iComDomicilio = 1;
							END IF;*/
							
							/*IF EXISTS(SELECT 1 FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img WHERE cliente = psNumCliente AND cod_docto IN('0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')) THEN*/
							IF EXISTS(SELECT 1 FROM bdidigital@coppelimg_crx:"informix".dg_expediente WHERE cliente = psNumCliente AND cod_docto IN('0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')) THEN
								LET iIdentOficial = 1;
							END IF;
							
							/*IF EXISTS(SELECT 1 FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img WHERE cliente = psNumCliente AND cod_docto IN('0012','0015','0016','0017','0018','0031','0032','0033')) THEN*/
							IF EXISTS(SELECT 1 FROM bdidigital@coppelimg_crx:"informix".dg_expediente WHERE cliente = psNumCliente AND cod_docto IN('0012','0015','0016','0017','0018','0031','0032','0033')) THEN
								LET iComDomicilio = 1;
							END IF;
							
							IF iIdentOficial = 1 AND iComDomicilio = 1 THEN
								
								UPDATE bdinteg:"informix".si_cliente 
								SET tipo_cliente = '1' 
								WHERE empresa = psEmpresa
								AND numcte = psNumCliente;
								
								LET cCodRet = '00000';
							
							END IF;
							
						ELIF piTipoEjecucion = 1 THEN
						
							UPDATE bdinteg:"informix".si_cliente 
							SET tipo_cliente = '1' 
							WHERE empresa = psEmpresa
							AND numcte = psNumCliente;
							
							LET cCodRet = '00000';
							
						END IF;	
					END IF;
				END IF;
			END IF;
		END IF;
		
		IF cCodRet = '00000' THEN 
		
			IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente AND respuesta = '1') THEN
				
				IF NOT EXISTS(SELECT numcte FROM bdinteg:"informix".si_ws_mensajeafore WHERE numcte = psNumCliente) THEN
					
					--Obtenemos los datos del cliente 
					SELECT  FIRST 1 c.ejecutivo,c.sucursal,c.apell_paterno,c.apell_materno,c.nombre1,c.nombre2,
						   f.curp,f.fecha_nac,f.lugar_nac,f.sexo
					INTO cNumEmpleado,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,
						 cCurp,dFechaNac,cEntidadNac,cSexo
					FROM  bdinteg:"informix".si_cliente c,
						  bdinteg:"informix".si_ctepf f
					WHERE c.numcte =  psNumCliente
					AND c.empresa =  psEmpresa
					AND c.numcte = f.numcte;
					
					SELECT FIRST 1 sucursal INTO cSucursal 
					FROM bdinteg:"informix".si_ejecut WHERE empresa=psEmpresa AND ejecutivo=cNumEmpleado;
					
					-- Notifica a afore
					INSERT INTO "informix".si_ws_mensajeafore(numcte,ejecutivo,sucursal,apell_paterno,apell_materno,nombre1,nombre2,curp,fecha_nac,lugar_nac,sexo,fecha_insert) 
					VALUES(psNumCliente,cNumEmpleado,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cCurp,dFechaNac,cEntidadNac,cSexo,CURRENT);
				END IF;
			END IF;	
		END IF;
		
		--DSB 22/05/2020 INICIO		
		SELECT COUNT(numcte)
		INTO iCteMatriz
		FROM bdinteg:"informix".si_sucmatriz
		WHERE numcte = psNumCliente;
				
		IF (cTipoCliente = '2' AND iCteMatriz = 0) THEN --Valida que el cliente no sea titular y no se encuentre en la tabla si_sucmatriz
			SELECT COUNT(DISTINCT(s.num_solicitud)) 	
			INTO iSolicitud
			FROM bdisolic:"informix".ss_solicitudes s, 
				 bdisolic:"informix".ss_prospecteo_solicitudes o
			WHERE s.numcte = o.numcte
			AND s.numcte = psNumCliente
			AND s.sucursal = '8503'
			AND s.user_insert = '70000001'
			AND o.canal_sol = 4
			AND o.estatus = 'A';
						
			IF iSolicitud > 0 THEN			
				INSERT INTO bdinteg:"informix".si_sucmatriz(numcte,suc_ori,suc_matriz)
				VALUES (psNumCliente,cSucOrigen,pSucursal);			
			END IF; --DSB 22/05/2020 FIN
		END IF;
		
		RETURN cCodRet;				
		
	END
END PROCEDURE;