CREATE PROCEDURE "informix".sp_senet_actualizaestatusctepm( pEmpresa CHAR(3), pNumCte CHAR(20) , pEstatus CHAR(3), pFolioToken CHAR(12), pUsuario CHAR(8) ,pIP CHAR(15), pAdminTipo CHAR(30), pIdAdmin CHAR(30), pNombreuno CHAR(30), pNombredos CHAR(30), pApellidopaterno CHAR(30), poApellidomaterno CHAR(30))



	
	RETURNING CHAR(6) AS cCodRet,
	          SMALLINT AS Estatus,
			  CHAR(100) AS Mensaje,
	          CHAR (20) AS NUM_CLIENTE,
			  CHAR (12) AS FOLIO_TOKEN;
			  

  -- DEFINICIONES
	DEFINE cCodRet           CHAR(6);
	DEFINE iSql_Err          INTEGER;
	DEFINE cMensaje          CHAR(100);
	DEFINE sEstatusAnterior  SMALLINT;
	DEFINE sEstatus          SMALLINT;
	DEFINE cNumCte           CHAR(20);
	DEFINE cFolioToken       CHAR(12);
    DEFINE dtFechaHoy        DATE;
	DEFINE pUsuarioAutoriza  CHAR(30);
	DEFINE pNumIdentOficial  CHAR(30);
	DEFINE pCodIdentif       CHAR(30);
	DEFINE pNumAdmin         CHAR(5);
	DEFINE pIdServicio       CHAR(10);
	DEFINE pRepLegal         CHAR(60);
	DEFINE cServicioId       CHAR(30);
	DEFINE pUsuarioAut       CHAR(30);
	DEFINE pFolioContrato    CHAR(30);
	
	
	
	-- INICIALIZACIONES
	LET cCodRet           	= '000';
	LET iSql_Err          	= 0;
	LET cMensaje          	= '';
	LET sEstatusAnterior  	= 0;
	LET sEstatus          	= '';
	LET cNumCte           	= '';
	LET cFolioToken       	= '';
	LET dtFechaHoy         	= '01-01-2000';
	LET pRepLegal           = '';
	LET cServicioId         = '';
	LET pUsuarioAut			= '';
	LET pFolioContrato      = '';
	
	
	BEGIN
		
		ON EXCEPTION SET iSql_Err
			LET cCodRet = iSql_Err;
			LET cMensaje = '';
			--LET sEstatus = '0';
			RETURN cCodRet, sEstatus, cMensaje,pNumCte,pFolioToken;
		END EXCEPTION;
		

--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_senet_actualizaestatusctepm_bdibei_grande.out";
--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	  --Valida los parametros de entrada.
		IF (pEmpresa = '' OR pEmpresa IS NULL) OR (pNumCte = '' OR pNumCte IS NULL)   THEN
		   LET cCodRet = '001';
		   LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCIÓN';
		   LET sEstatus = '0';
		   RETURN cCodRet, sEstatus, cMensaje,pNumCte,pFolioToken;
		END IF
		
	  -- Consultamos la fecha actual
		SELECT fecha_hoy INTO dtFechaHoy
		FROM bdicheq:"informix".sc_fechas;
		
	  --Valida si el estatus viene vacio inserta un registro en la tabla.
		IF pEstatus = '' THEN
		   
		  LET sEstatus = 0;
		  LET cFolioToken = pFolioToken;
		  
	
		-- Inserta un registro en las tablas.
		  
		INSERT INTO bdibei:"informix".bei_servicio (num_cliente, id_servicio, folio_contrato, folio_activa, id_status, codidentif,
		   identificacion_admin, f_status, f_registro, f_unico_reg, ns_token, status_manco, f_mod_manco, f_reg_manco, id_usuario, 
		   apell_paterno, apell_materno, nombre1, nombre2, es_replegal)
           VALUES  ( pNumCte   ,(SELECT LPAD(CAST(NVL(MAX((id_servicio) + 1),0000000001)  AS INTEGER), 10, '0') FROM bdibei:"informix".bei_servicio), '', pFolioToken, '10', pAdminTipo, '' , '', '', '', '' , '' , '' , '' , pIdAdmin,poApellidomaterno, pApellidopaterno, pNombreuno, pNombredos, pRepLegal);
		   
		 
		  
		  
		  -- Inserta en la tabla un registro del historial del estatus que lleva el cliente.
  		   
		    INSERT INTO bdibei:"informix".bei_contratacion (empresa, num_cliente ,folio_contrato , oper_no_token, rep_legal, f_registro,num_empleado, fecha_movto, usuario_atiende, usuario_aut, suc_registro, status_contrato)
           VALUES (pEmpresa, pNumCte,(SELECT LPAD(CAST(NVL(MAX((folio_contrato) + 1),0000000001)  AS INTEGER), 10, '0') FROM bdibei:"informix".bei_contratacion ),'1' ,pRepLegal,'','', '', '', pUsuarioAut,'5001','');
		   
		   INSERT INTO bdinteg:"informix".si_cambiostctepm  ( numcliente, id_statusanterior, id_statusactual  , ipusuario, fecha_cambio, suc_cambio, usuario_cambio )
           VALUES ( pNumCte,sEstatus, sEstatus , pIP, dtFechaHoy, '5001', pUsuario);
		  
		   
		   
		   
		   
		   
		   
		  LET cCodRet = '000';
		  LET cMensaje = 'INSERTO CORRECTAMENTE';
		   
		   RETURN cCodRet, sEstatus, cMensaje,pNumCte,pFolioToken;
		   
		ELSE
			
            LET sEstatusAnterior = pEstatus::SMALLINT;		
			
		  -- Valida el estatus que se va actualizar
			IF pEstatus = '0' THEN
			  LET sEstatus = 1;
			  LET cFolioToken = pFolioToken;
			  
			  UPDATE bdibei:"informix".bei_servicio SET id_status = sEstatus , folio_contrato = cFolioToken 
			  WHERE empresa = pEmpresa AND num_cliente =pNumCte;
		 
			  
			  
			ELIF pEstatus = '1' THEN
			  LET sEstatus = 2;
			  LET cFolioToken = pFolioToken;
			  
			 /* UPDATE bdibei:"informix".bei_servicio SET id_status = sEstatus , folio_contrato = cFolioToken 
			  WHERE empresa = pEmpresa AND num_cliente =pNumCte;*/
			ELIF pEstatus = '2' THEN
			  LET sEstatus = 10;
			  LET cFolioToken = pFolioToken;
			  
			  /*UPDATE bdibei:"informix".bei_servicio SET id_status = sEstatus , folio_contrato = cFolioToken , f_registro = dtFechaHoy
			  WHERE empresa = pEmpresa AND num_cliente =pNumCte;*/
			END IF 
			
		  
	        
		    LET cCodRet = '000';
		    LET cMensaje = 'ACTUALIZO CORRECTAMENTE';
			
			
			RETURN cCodRet, sEstatus, cMensaje,pNumCte,pFolioToken;
			
		END IF
        
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Actualiza e Inserta registros en la tabla si_bpiusuariospm en caso de que el estatus se encuentre vacio ',
'             y actualiza la tabla en el estatus que le sigue en el proceso',
'AUTOR:  Valentin Lopez',
'FECHA DE CREACION: 27 de Septiembre del 2011',
'DESCRIPCION MODIFICACION: Se modifico el número de identificación a char(30) y recibir como parametro el típo de identificación para su registro y',
'							se cambiaron todos los mensajes a mayuscula',
'FECHA MODIFICACION: 13 de Marzo del 2012',
'AUTOR MODIFICACION: Guadalupe Payan',
'VERSION: 20120313.1204',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_senet_actualizaestatusctepm( pEmpresa CHAR(3), pNumCte CHAR(20) , pEstatus CHAR(3), pFolioToken CHAR(12), pUsuario CHAR(8) ,pIP CHAR(15))



	
	RETURNING CHAR(6) AS cCodRet,
	          SMALLINT AS Estatus,
			  CHAR(100) AS Mensaje,
	          CHAR (20) AS NUM_CLIENTE,
			  CHAR (12) AS FOLIO_TOKEN;
			  

  -- DEFINICIONES
	DEFINE cCodRet           CHAR(6);
	DEFINE iSql_Err          INTEGER;
	DEFINE cMensaje          CHAR(100);
	DEFINE sEstatusAnterior  SMALLINT;
	DEFINE sEstatus          SMALLINT;
	DEFINE cNumCte           CHAR(20);
	DEFINE cFolioToken       CHAR(12);
    DEFINE dtFechaHoy        DATE;
	DEFINE pUsuarioAutoriza  CHAR(30);
	DEFINE pNumIdentOficial  CHAR(30);
	DEFINE pCodIdentif       CHAR(30);
	DEFINE pNumAdmin         CHAR(5);
	DEFINE pIdServicio       CHAR(10);
	DEFINE pRepLegal         CHAR(60);
	DEFINE cServicioId       CHAR(30);
	DEFINE pUsuarioAut       CHAR(30);
	DEFINE pFolioContrato    CHAR(30);
	
	
	
	-- INICIALIZACIONES
	LET cCodRet           	= '000';
	LET iSql_Err          	= 0;
	LET cMensaje          	= '';
	LET sEstatusAnterior  	= 0;
	LET sEstatus          	= '';
	LET cNumCte           	= '';
	LET cFolioToken       	= '';
	LET dtFechaHoy         	= '01-01-2000';
	LET pRepLegal           = '';
	LET cServicioId         = '';
	LET pUsuarioAut			= '';
	LET pFolioContrato      = '';
	
	
	BEGIN
		
		ON EXCEPTION SET iSql_Err
			LET cCodRet = iSql_Err;
			LET cMensaje = '';
			--LET sEstatus = '0';
			RETURN cCodRet, sEstatus, cMensaje,pNumCte,pFolioToken;
		END EXCEPTION;
		
--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_senet_actualizaestatusctepm_bdibei_chico.out";
--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	  --Valida los parametros de entrada.
		IF (pEmpresa = '' OR pEmpresa IS NULL) OR (pNumCte = '' OR pNumCte IS NULL)   THEN
		   LET cCodRet = '001';
		   LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCIÓN';
		   LET sEstatus = '0';
		   RETURN cCodRet, sEstatus, cMensaje,pNumCte,pFolioToken;
		END IF
		
	  -- Consultamos la fecha actual
		SELECT fecha_hoy INTO dtFechaHoy
		FROM bdicheq:"informix".sc_fechas;
		
	  --Valida si el estatus viene vacio inserta un registro en la tabla.
		IF pEstatus = '' THEN
		   
		  LET sEstatus = 0;
		  LET cFolioToken = pFolioToken;
		  
	
		-- Inserta un registro en las tablas.
		 
		  
		   
		/*INSERT INTO bdibei:"informix".bei_servicio (num_cliente, id_servicio, folio_contrato, folio_activa, id_status, codidentif,
		   identificacion_admin, f_status, f_registro, f_unico_reg, ns_token, status_manco, f_mod_manco, f_reg_manco, id_usuario, 
		   apell_paterno, apell_materno, nombre1, nombre2, es_replegal)
           VALUES  ( pNumCte   ,(SELECT LPAD(CAST(NVL(MAX((id_servicio) + 1),0000000001)  AS INTEGER), 10, '0') FROM bdibei:"informix".bei_servicio), '', pFolioToken, '10', pAdminTipo, '' , '', '', '', '' , '' , '' , '' , pIdAdmin, 'HERAS', 'CASTRO', 'BIVIAN', pNombredos, 'MARICELA CASTRO');
		   
		   LET cServicioId = (SELECT LPAD(CAST(MAX((id_servicio)) AS INTEGER), 10, '0') FROM bdibei:"informix".bei_servicio WHERE num_cliente = pNumCte);*/

		   
		  
		  -- Inserta en la tabla un registro del historial del estatus que lleva el cliente.
  		   
		    /*INSERT INTO bdibei:"informix".bei_contratacion (empresa, num_cliente ,folio_contrato , oper_no_token, rep_legal, f_registro,num_empleado, fecha_movto, usuario_atiende, usuario_aut, suc_registro, status_contrato)
           VALUES (pEmpresa, pNumCte,(SELECT LPAD(CAST(NVL(MAX((folio_contrato) + 1),0000000001)  AS INTEGER), 10, '0') FROM bdibei:"informix".bei_contratacion ),'1' ,pRepLegal,'','', '', '', pUsuarioAut,'5001','');
		   
		   LET pFolioContrato = (SELECT LPAD(CAST(MAX((folio_contrato)) AS INTEGER), 10, '0') FROM bdibei:"informix".bei_contratacion WHERE num_cliente = pNumCte);
		   */
		   
		   
		   
		   INSERT INTO bdinteg:"informix".si_cambiostctepm  ( numcliente, id_statusanterior, id_statusactual  , ipusuario, fecha_cambio, suc_cambio, usuario_cambio )
           VALUES ( pNumCte,sEstatus, sEstatus , pIP, dtFechaHoy, '5001', pUsuario);
		  
		   
		   
		   
		   
		   
		   
		  LET cCodRet = '000';
		  LET cMensaje = 'INSERTO CORRECTAMENTE';
		   
		   RETURN cCodRet, sEstatus, cMensaje,pNumCte,pFolioToken;
		   
		ELSE
			
            LET sEstatusAnterior = pEstatus::SMALLINT;		
			
		  -- Valida el estatus que se va actualizar
			IF pEstatus = '0' THEN
			  LET sEstatus = 1;
			  LET cFolioToken = pFolioToken;
			  
			  UPDATE bdibei:"informix".bei_servicio SET id_status = sEstatus , folio_contrato = cFolioToken 
			  WHERE empresa = pEmpresa AND num_cliente =pNumCte;
		 
			  
			  
			ELIF pEstatus = '1' THEN
			  LET sEstatus = 2;
			  LET cFolioToken = pFolioToken;
			  
			 /* UPDATE bdibei:"informix".bei_servicio SET id_status = sEstatus , folio_contrato = cFolioToken 
			  WHERE empresa = pEmpresa AND num_cliente =pNumCte;*/
			ELIF pEstatus = '2' THEN
			  LET sEstatus = 10;
			  LET cFolioToken = pFolioToken;
			  
			  /*UPDATE bdibei:"informix".bei_servicio SET id_status = sEstatus , folio_contrato = cFolioToken , f_registro = dtFechaHoy
			  WHERE empresa = pEmpresa AND num_cliente =pNumCte;*/
			END IF 
			
		  
	        
		    LET cCodRet = '000';
		    LET cMensaje = 'ACTUALIZO CORRECTAMENTE';
			
			
			RETURN cCodRet, sEstatus, cMensaje,pNumCte,pFolioToken;
			
		END IF
        
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Actualiza e Inserta registros en la tabla si_bpiusuariospm en caso de que el estatus se encuentre vacio ',
'             y actualiza la tabla en el estatus que le sigue en el proceso',
'AUTOR:  Valentin Lopez',
'FECHA DE CREACION: 27 de Septiembre del 2011',
'DESCRIPCION MODIFICACION: Se modifico el número de identificación a char(30) y recibir como parametro el típo de identificación para su registro y',
'							se cambiaron todos los mensajes a mayuscula',
'FECHA MODIFICACION: 13 de Marzo del 2012',
'AUTOR MODIFICACION: Guadalupe Payan',
'VERSION: 20120313.1204',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_senet_consultaestatusctepm( pNumCte CHAR(20) , pCuenta CHAR(20) )
	
	RETURNING CHAR(6) 		AS CodRet,
		      CHAR(100) 	AS Mensaje,
			  CHAR(3) 		AS Estatus,			  
			  CHAR(50) 		AS UsuarioAutorizado,
			  CHAR(2) 		AS CodIdentif,
			  CHAR(50) 		AS DescripIdenfOficial,
			  CHAR(30) 		AS Identificacion,
			  CHAR(12) 		AS FoliosolicitudToken;
    
	--DEFINICIONES DE VARIABLES.
	DEFINE cCodRet         			CHAR(6);
	DEFINE iSqlErr        			INTEGER;
	DEFINE iIsamErr        			INTEGER;
	DEFINE cDescErr        			CHAR(100);
	DEFINE cMensaje        			CHAR(100);
	DEFINE cEstatus        			CHAR(3);
	DEFINE cNumCte	       			CHAR(20);
	DEFINE cUsuarioAut	   			CHAR(50);
	DEFINE cDescripIdenfOficial  	CHAR(55);
	DEFINE cCodIdentif  			CHAR(2);
	DEFINE cIdentificacion 			CHAR(30);
	DEFINE cFolioSolToken  			CHAR(12);
	DEFINE v_conta					CHAR(12);
	DEFINE cEmpresa					CHAR(12);
	DEFINE cRazonsocial				CHAR(12);
	DEFINE cReplegal				CHAR(12);
	
	    	
	--INICIALIZACIONES DE VARIABLES.
	LET cCodRet         			= '000';
	LET iSqlErr         			= 0;
	LET iIsamErr         			= 0;
	LET cDescErr        			= '';
	LET cMensaje        			= 'VALIDACION TERMINADA';
	LET cEstatus        			= '';
	LET cNumCte         			= '';
	LET cUsuarioAut     			= '';	
	LET cCodIdentif  				= '';
	LET cDescripIdenfOficial		= '';
	LET cIdentificacion 			= '';
	LET cFolioSolToken  			= '';		
	LET v_conta   					= '';
	BEGIN
		ON EXCEPTION SET iSqlErr,iIsamErr,cDescErr
			LET cCodRet = iSqlErr;
			LET cMensaje = cDescErr;
			RETURN cCodRet,TRIM(cMensaje),TRIM(NVL(cEstatus,'')),TRIM(NVL(cUsuarioAut,'')),TRIM(NVL(cCodIdentif,'')),TRIM(NVL(cDescripIdenfOficial,'')),TRIM(NVL(cIdentificacion,'')),TRIM(NVL(cFolioSolToken,''));
		END EXCEPTION;

--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_senet_consultaestatusctepm_bdibei_Gr.out";
--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	  --Valida los parametros de entrada.		
		IF NVL(pNumCte, '') = '' AND NVL(pCuenta, '') = '' THEN
		   LET cCodRet = '002';
		   LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCIÓN';
		   RETURN cCodRet,cMensaje,TRIM(cEstatus),TRIM(cUsuarioAut),TRIM(cCodIdentif),TRIM(cDescripIdenfOficial),TRIM(cIdentificacion),TRIM(cFolioSolToken);
		   
		ELIF NVL(pNumCte,'' ) <> '' AND NVL(pCuenta,'') <> '' THEN		
		   LET cCodRet = '003';
		   LET cMensaje = 'SOLAMENTE DEBE INGRESAR UN PARAMETRO';
		   RETURN cCodRet,cMensaje,TRIM(cEstatus),TRIM(cUsuarioAut),TRIM(cCodIdentif),TRIM(cDescripIdenfOficial),TRIM(cIdentificacion),TRIM(cFolioSolToken);
		   
		END IF
		
	  --Si el cliente viene vacio consulta el cliente por el numero de cuenta		
		IF NVL(pNumCte,'') = '' THEN
		  SELECT num_cte 
		  INTO cNumCte
		  FROM bdicheq: "informix".sc_maechq
		  WHERE empresa = '001'
		    AND cuenta = pCuenta;
		  		  
		  IF NVL(cNumCte,'') = ''THEN            
			LET cCodRet = '004';
		    LET cMensaje = 'NO EXISTE LA CUENTA EN LA BASE DE DATOS';
		    RETURN cCodRet,cMensaje,TRIM(cEstatus),TRIM(cUsuarioAut),TRIM(cCodIdentif),TRIM(cDescripIdenfOficial),TRIM(cIdentificacion),TRIM(cFolioSolToken);
			
		  END IF
		  
		  LET pNumCte = cNumCte;
		   
		END IF
		
		---SE OBTIENEN LOS DATOS DE LA EMPRESA, LA CANTIDAD DE ADMINISTRADORES Y OPERADORES
	
	 SELECT TRIM(NVL(c.empresa,'')),TRIM(NVL(b.razon_social,'')),TRIM(NVL(b.rep_legal,''))
		INTO cEmpresa,cRazonsocial,cReplegal,cUsuarioAut
	    FROM bdinteg:"informix".si_cliente  a 
		INNER JOIN bdinteg:"informix".si_bpiusuariospm b ON (a.numcte = b.num_cliente)
		WHERE a.numcte = pNumcte
		AND a.empresa = '001'
		AND b.empresa = '001'
		AND b.numcte = pNumcte;
		
	FOREACH   SELECT TRIM(NVL(usuario_aut,''))
		INTO cUsuarioAut
		FROM bdibei: "informix".bei_contratacion 
		WHERE empresa = '001'
		
		LET v_conta = v_conta+1;

   END FOREACH;

		
	  -- Consulta el estatus que tiene asignado el cliente.
		SELECT id_status,codidentif,identificacion_admin,folio_contrato 
		INTO cEstatus,cCodIdentif,cIdentificacion,cFolioSolToken
		FROM bdibei: "informix".bei_servicio 
		WHERE num_cliente = pNumCte;
		
		
		 

		
		 
	  -- Valida si el estatus es NULL o Vacio.		
		IF NVL(cEstatus,'') = '' THEN
		   LET cCodRet = '000';
		   LET cEstatus = '';
		   LET cMensaje = 'EMPRESA NO A SIDO DADA DE ALTA EN EL SERVICIO DE EMPRESA NET';		   
		   RETURN cCodRet,cMensaje,TRIM(cEstatus),TRIM(NVL(cUsuarioAut,'')),TRIM(NVL(cCodIdentif,'')),TRIM(cDescripIdenfOficial),TRIM(NVL(cIdentificacion,'')),TRIM(NVL(cFolioSolToken,''));
		   
		END IF
						
		--Consulta la descripcion y el codigo identificacion oficial.
		SELECT TRIM(descripcion)
		INTO cDescripIdenfOficial
		FROM bdinteg: "informix".si_tipoidentifpm
		WHERE empresa = '001'
		  AND codigo = TRIM(cCodIdentif);		
		
	  -- Valida el estatus obtenido en la consulta.
		IF cEstatus = '0' THEN
  		  LET cCodRet = '000';
 		  LET cMensaje = 'EL PROCESO DE ALTA SE DETUVO EN LA GENERACIÓN DEL CODIGO DE SOLICITUD DEL TOKEN';
		ELIF cEstatus = '1' THEN
	      LET cCodRet = '000';
		  LET cMensaje = 'EL PROCESO DE ALTA SE DETUVO POR PROBLEMAS EN LA DIGITALIZACIÓN';
		ELIF cEstatus = '2' THEN
		  LET cCodRet = '000';
		  LET cMensaje = 'EL PROCESO DE ALTA SE DETUVO POR PROBLEMAS EN LAS AFECTACIONES A TABLAS';
		ELIF cEstatus = '10' THEN		
		  LET cCodRet = '000';
		  LET cMensaje = 'EL CLIENTE MORAL YA CUENTA CON EL SERVICIO DE EMPRESANET ACTIVO EN CENTRAL';
		ELIF cEstatus = '30' THEN
		  LET cCodRet = '000';
		  LET cMensaje = 'EL CLIENTE MORAL YA CUENTA CON EL SERVICIO DE EMPRESANET ACTIVO EN EL PORTAL';
		ELSE
		  LET cCodRet = '001';
		  LET cMensaje = 'ESTATUS NO VALIDO PARA EL PROCESO DE ALTA DE EMPRESA NET';
		END IF 
		
		RETURN cCodRet,cMensaje,TRIM(cEstatus),TRIM(NVL(cUsuarioAut,'')),TRIM(NVL(cCodIdentif,'')),TRIM(NVL(cDescripIdenfOficial,'')),TRIM(NVL(cIdentificacion,'')),TRIM(NVL(cFolioSolToken,''));
	END;
	
END PROCEDURE;