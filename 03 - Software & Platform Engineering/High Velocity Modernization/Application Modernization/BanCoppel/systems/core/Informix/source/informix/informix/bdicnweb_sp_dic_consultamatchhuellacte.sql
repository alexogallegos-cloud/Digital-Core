CREATE PROCEDURE "informix".sp_dic_consultamatchhuellacte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNvoCteBco CHAR(20))
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS numcte_match,
			CHAR(4) AS empresa,
			CHAR(25) AS descripcion,
			CHAR(4) AS sucursal,
			SMALLINT AS bandera;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cClienteMatch CHAR(20);
	DEFINE cEmpresa CHAR(4);
	DEFINE cDescripcion CHAR(25);
	DEFINE sCteExiste SMALLINT;
	DEFINE cSucursal CHAR(4);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cClienteMatch = '';
	LET cEmpresa = '';
	LET cDescripcion = '';
	LET sCteExiste = 0;
	LET cSucursal = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultamatchhuellacte.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pNvoCteBco = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_matcheshuellacte(pNvoCteBco)
			INTO cCodRetSp, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consulta_matcheshuellacte';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '1001'; --NO HAY RESPUESTA DE LA COMPARACION DE HUELLAS
			--ELIF iCodRetSp = 2 THEN
			--	LET cCodRet = '00017'; --OCURRIO UN PROBLEMA DE AMBIENTACION
			END IF;
			
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal WITH RESUME;
		END FOREACH;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: Verifica si ha habido respuesta de la comparacion de huellas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultaparamdigitalizacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpresa CHAR(3), pCodParam SMALLINT)
		RETURNING CHAR(5) AS codret,
			CHAR(100) AS valor_param,
			CHAR(50) AS des_param;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cValorParam CHAR(100);
	DEFINE cDesParam CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cValorParam = '';
	LET cDesParam = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValorParam, cDesParam;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultaparamdigitalizacion.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa = '' OR pCodParam = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValorParam, cDesParam;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValorParam, cDesParam;
		END IF;
		
		EXECUTE PROCEDURE bdidigital:"informix".sp_dgconsultaparametrosdigitalizacion(pEmpresa, pCodParam)
		INTO cCodRetSp, cValorParam, cDesParam;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital:"informix".sp_dgconsultaparametrosdigitalizacion';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';			
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00367';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '01071';
		ELIF iCodRetSp = 4 THEN
			LET cCodRet = '00017';
		END IF;
		RETURN cCodRet, cValorParam, cDesParam;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta los parametros IP y Puerto del servidor de imagenes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultarcatsucursales(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpresa CHAR(3), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,
			CHAR(3) AS empresa, 
			CHAR(4) AS sucursal, 
			CHAR(40) AS nombre, 
			CHAR(40) AS direccion1, 
			CHAR(40) AS direccion2, 
			CHAR(14) AS telefono,
			CHAR(40) AS gerente, 
			CHAR(40) AS subgerente, 
			CHAR(2) AS tpo_sucursal;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cSucursal CHAR(4);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombre CHAR(40);
	DEFINE cDireccion1 CHAR(40);
	DEFINE cDireccion2 CHAR(40);
	DEFINE cTelefono1 CHAR(14);
	DEFINE cGerente CHAR(40);
	DEFINE cSubgerente CHAR(40);
	DEFINE cTipoSucursal CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '';
	LET cSucursal = '';
	LET cNombre = '';
	LET cDireccion1 = '';
	LET cDireccion2 = '';
	LET cTelefono1 = '';
	LET cGerente = '';
	LET cSubgerente = '';
	LET cTipoSucursal = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultarcatsucursales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa= '' OR pSucursal= '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultarcatsucursales(pEmpresa, pSucursal)
			INTO cCodRetSp, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultarcatsucursales';
			END IF;
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
			END IF;
	
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta los datos de la sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultasucursales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
    RETURNING CHAR(5) AS codRet,
		CHAR(40) AS nombre_suc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreSuc CHAR(40);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cNombreSuc = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNombreSuc;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultasucursales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreSuc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreSuc;
		END IF;
		
		SELECT nombre 
		INTO cNombreSuc 
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = cEmpresa AND sucursal = pSucursal;
		
		IF NVL(cNombreSuc,'') = '' THEN
			LET cCodRet = '00833'; --EL NÚMERO DE SUCURSAL NO EXISTE
		END IF;
		
		RETURN cCodRet,TRIM(UPPER(cNombreSuc));
		
	END;
	
END PROCEDURE

DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 12/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: Spl que consulta el nombre de la sucursales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_correciondatoscte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pTipoSol CHAR(20), pNombreInc CHAR (104), pFechaNacInc DATE, 
									pNumCteCorr CHAR(20), pNombreCorr CHAR(104), pFechaNacCorr DATE, pSucursal CHAR(4), pOrigen CHAR(1))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_correciondatoscte.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pTipoSol = '' OR pNombreInc = '' OR pFechaNacInc IS NULL 
		  OR pNumCteCorr = '' OR pNombreCorr = '' OR pFechaNacCorr IS NULL OR pSucursal = '' OR pOrigen = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_bit_solicitudessos_sif(pNumCte, pTipoSol, pNombreInc, pFechaNacInc, pNumCteCorr, pNombreCorr, pFechaNacCorr, pSucursal, pUsuario, pOrigen)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_bit_solicitudessos_sif';
		--ELIF iCodRetSp =  THEN
		--	LET cCodRet = '';
		END IF;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que realiza la correción de los datos de clientes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_enviarmonitoralertas(pUsuario CHAR(8), pIdFuncion CHAR(10),pTramaEnvios CHAR(250))
		RETURNING CHAR(5) AS codRet;
   
   DEFINE cCodRet CHAR(5);
   DEFINE iSqlErr INTEGER;
   DEFINE cNumCte CHAR(9); 
   DEFINE iNoRegistros INTEGER;   
   
   LET cCodRet = '00000';
   LET iSqlErr = 0;
   LET cNumCte = '';
   LET iNoRegistros = 0;   
   
   BEGIN

	  ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
	  		RETURN cCodRet;
	  	END IF;
	  END EXCEPTION;
		
	  --SET DEBUG FILE TO '/tmp/mfinis/sp_dic_enviarmonitoralertas.out';
	  --TRACE ON;
	  
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
		
	  IF pUsuario = '' OR pIdFuncion = '' OR pTramaEnvios = '' THEN
		LET cCodRet = '00003';	
		UPDATE bdicnweb:"informix".sw_dic_statusbuzonenvmonitor
        SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
		RETURN cCodRet;
	  END IF;
		
	  EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
	  IF cCodRet <> '00000' THEN
		UPDATE bdicnweb:"informix".sw_dic_statusbuzonenvmonitor
        SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
	  	RETURN cCodRet;
	  END IF;

	  DELETE FROM bdicnweb:"informix".sw_dic_statusbuzonenvmonitor WHERE usuario = pUsuario;
		
	  INSERT INTO bdicnweb:"informix".sw_dic_statusbuzonenvmonitor(usuario,total_registros,status,error_proceso,error_code)
      VALUES(pUsuario, iNoRegistros,'I','', ''); 
	  
	  FOREACH
	  
		EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaEnvios, '|')
		INTO cNumCte
		--ACTUALIZA ES ESTATUS DE 5 A 1
		update bdinteg:'informix'.si_bitacora_comparaciones 
	    set status_alerta = '1' 
	    where numcte = cNumCte 
	    and status_alerta = '5';
		
		 LET iNoRegistros = iNoRegistros + 1;
		 
	  END FOREACH;
	  
	  UPDATE bdicnweb:"informix".sw_dic_statusbuzonenvmonitor
      SET status = 'T', total_registros = iNoRegistros, error_proceso = 'N', error_code = cCodRet WHERE usuario = pUsuario;
	  
	  RETURN cCodRet;
   END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 13/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SP que se encarga de regersar las alertas del buzon de pendientes al monitor de alertas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_reevdparam(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5)  AS codret,
			      CHAR(8)  AS  cTotalRegEncon,
			      CHAR(8)  AS cTotalRegenDep,
			      CHAR(8)  AS  cTotalRegPen;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTotalRegEncon CHAR(8);
	DEFINE cTotalRegenDep CHAR(8);
	DEFINE cTotalRegPen CHAR(8);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTotalRegEncon = '';
	LET cTotalRegenDep = '';
	LET cTotalRegPen = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_reevdparam.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		END IF;				
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_reevdparam()
		INTO cCodRetSp, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_dicta_reevdparam';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que realiza el proceso de revaluación de los registros ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusbuzonenvmonitor(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS total_registros,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusbuzonenvmonitor.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusbuzonenvmonitor WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',iTotalReg,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 13/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de regresar registros del buzon de pendientes al monitor de alertas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusconsctesdichawk(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS total_registros,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusconsctesdichawk.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusconsctesdichawk WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',iTotalReg,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 11/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar la Evaluacion de Resultados Hawk de Comparación de Huellas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusconsultahuellas(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS total_registros,
			  CHAR(1) AS status,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cError = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusconsultahuellas.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cError = '00003';
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cError;
		IF cError <> '00000' THEN
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusconsultahuellas WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN				
			RETURN cCodRet,iTotalReg,'I',cErrorProceso,cError;		
		ELSE 			
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 07/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTA HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar la Evaluacion de Resultados de Comparación de Huellas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusenviobuzon(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS total_registros,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusenviobuzon.out';
		--TRACE ON;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusenviobuzon WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',iTotalReg,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 13/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de regresar registros del Monitor de Alertas al Buzon de pendientes.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_buscapersona_pba(pId_UsuarioC CHAR(8), 
									pId_FuncionC CHAR(10), 
									pTipoBusqueda SMALLINT, 
									pIdOficio INT, 
									pNombre1 CHAR(60), 
									pNombre2 CHAR(26), 
									pApPaterno CHAR(26), 
									pApMaterno CHAR(26), 
									pPagina SMALLINT, 
									pRegistros SMALLINT, 
									pIp CHAR(15), 
									pMacAddress CHAR(12))

RETURNING CHAR(5) AS codRet, 
	CHAR(20) AS numeroCliente, 
	CHAR(15) AS rfc,
	CHAR(26) AS nombre1, 
	CHAR(26) AS nombre2, 
	CHAR(26) AS apPaterno, 
	CHAR(26) AS apMaterno, 
	CHAR(60) AS razonSocial,
	CHAR(20) AS noCuenta,
	CHAR(20) AS noTarjeta,
	CHAR(2) AS tipoPersona, 
	CHAR(1) AS tipoCliente, 
	INT AS status, 
	CHAR(20) AS descStatusBusqueda,
	CHAR(1) AS ind_omitido,
	CHAR(1) AS ind_bloqueocta,
	CHAR(1) AS ind_terminado,
	INT AS id_busqueda,
	INT AS id_resulcte,
	CHAR(2) AS tipoCuenta,
	CHAR(1) AS ind_rfc,
	CHAR(1) AS ind_dir_empleo,
	CHAR(1) AS ind_domicilio,
	CHAR(1) AS ind_nacionalidad
-- Definición de variables
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cNumeroCliente CHAR(20);
	DEFINE cNumeroCuenta CHAR(20);
	DEFINE cNumeroTarjeta CHAR(20);
	DEFINE cRfc CHAR(13);
	DEFINE iIdNumConsulta INT;
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApPaterno CHAR(26);
	DEFINE cApMaterno CHAR(26);
	DEFINE cRazonSocial CHAR(60);
	DEFINE iSqlErr INT;
	DEFINE iNoRows INT;
	DEFINE iExiste INT;
	DEFINE cCriterio CHAR(60);
	DEFINE iIdBusqueda INT;
	DEFINE cTipoBusquedaPersona CHAR(1);
	DEFINE cTipoPersona CHAR(2);
	DEFINE cTipoCliente CHAR(1);
	DEFINE cIdEncontrado INT;
	DEFINE iStatusBusqueda INT;
	DEFINE cDescStatusBusqueda CHAR(20);
	DEFINE iRegsProc INT;
	DEFINE cOmitido CHAR(1);
	DEFINE cBloqueado CHAR(1);
	DEFINE cTerminado CHAR(1);
	DEFINE cTipoCuenta CHAR(2);
	DEFINE cIndRfc CHAR(1);
	DEFINE cIndEmpleo CHAR(1);
	DEFINE cIndDomicilio CHAR(1);
	DEFINE cIndNacionalidad CHAR(1);
	-- ETIQUETAS
	DEFINE cHomonimo CHAR(15);
	DEFINE cEncontrado CHAR(15);
	DEFINE cNoEncontrado CHAR(15);
	--Inicialización de variables
	LET cCodRet	= '00000';
	LET cCodRetSp = '00000';
	LET cNumeroCliente = '';
	LET cRfc = '';
	LET iIdNumConsulta = 0;
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApPaterno = '';
	LET cApMaterno = '';
	LET cRazonSocial = '';
	LET iSqlErr = 0;
	LET cHomonimo = 'HOMONIMO';
	LET cEncontrado = 'LOCALIZADO';
	LET cNoEncontrado = 'NO LOCALIZADO';
	LET iExiste = 0;
	LET cCriterio = '';
	LET iIdBusqueda = 0;
	LET cTipoPersona = '';
	LET cTipoCliente = '';
	LET iStatusBusqueda = 0;
	LET cDescStatusBusqueda = '';
	LET cIdEncontrado = 0;
	LET iRegsProc = 0;
	LET cNumeroCuenta = '';
	LET cNumeroTarjeta = '';
	LET cOmitido = '0';
	LET cBloqueado = '0';
	LET cTerminado = '0';
	LET cTipoCuenta = '';
	LET cIndRfc = '0';
	LET cIndEmpleo = '0';
	LET cIndDomicilio = '0';
	LET cIndNacionalidad = '0';
	
	BEGIN
		-- Validaciones
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumeroCliente, cRfc, 
						cNombre1, cNombre2, cApPaterno, 
						cApMaterno, cRazonSocial, cNumeroCuenta, 
						cNumeroTarjeta, cTipoPersona, cTipoCliente, 
						iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
						cBloqueado, cTerminado, cIdEncontrado, 
						0, cTipoCuenta, cIndRfc, 
						cIndEmpleo, cIndDomicilio, cIndNacionalidad;
			END IF;
		END EXCEPTION;

	  --SET DEBUG FILE TO "/RESPALDOS/sp_sw_ro_buscapersona.out";
	  --TRACE ON;

		-- Validación del numero de oficio
		IF pIdOficio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumeroCliente, cRfc, 
					cNombre1, cNombre2, cApPaterno, 
					cApMaterno, cRazonSocial, cNumeroCuenta, 
					cNumeroTarjeta, cTipoPersona, cTipoCliente, 
					iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
					cBloqueado, cTerminado, cIdEncontrado,
					0, cTipoCuenta, cIndRfc, 
					cIndEmpleo, cIndDomicilio, cIndNacionalidad;
		END IF;
		-- Busqueda del numero de oficio
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_oficio) 
		INTO iExiste 
		FROM sw_ro_maeoficios 
		WHERE id_oficio = pIdOficio;
		IF iExiste = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet, cNumeroCliente, cRfc, 
				cNombre1, cNombre2, cApPaterno, 
				cApMaterno, cRazonSocial, cNumeroCuenta, 
				cNumeroTarjeta, cTipoPersona, cTipoCliente, 
				iStatusBusqueda, cDescStatusBusqueda, cOmitido,
				cBloqueado, cTerminado, cIdEncontrado,
				0, cTipoCuenta, cIndRfc, 
				cIndEmpleo, cIndDomicilio, cIndNacionalidad;
		END IF;
		IF pTipoBusqueda NOT IN (1,2,3,4,5,6) THEN
			LET cCodRet = '00087';
			RETURN cCodRet, cNumeroCliente, cRfc, 
				cNombre1, cNombre2, cApPaterno, 
				cApMaterno, cRazonSocial, cNumeroCuenta, 
				cNumeroTarjeta, cTipoPersona, cTipoCliente, 
				iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
				cBloqueado, cTerminado, cIdEncontrado,
				0, cTipoCuenta, cIndRfc,
				cIndEmpleo, cIndDomicilio, cIndNacionalidad;
		ELSE
			-- Se INSERTa el criterio de busqueda en la tabla sw_ro_buscaper
			-- Criterio de busqueda por Nombre
			IF pTipoBusqueda = 1 THEN
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																'', '', '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno,
																pApMaterno, pNombre1, pNombre2,
																'', '', '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				-- Se realiza la consulta de la persona
				LET cTipoBusquedaPersona = '1';
				SET ISOLATION TO DIRTY READ;
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscaxnombre(pId_UsuarioC, pId_FuncionC, iIdBusqueda, 
															pIdOficio, cTipoBusquedaPersona, pNombre1, 
															pNombre2, pApPaterno, pApMaterno, 
															'', cTipoCuenta, pIp, 
															pMacAddress, pPagina, pRegistros)
					INTO cCodRet, cNumeroCliente, cRfc, 
						iIdNumConsulta, cNombre1, cNombre2, 
						cApPaterno, cApMaterno, cRazonSocial, 
						cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cDescStatusBusqueda, cIdEncontrado
					RETURN cCodRet, cNumeroCliente, cRfc, 
						cNombre1, cNombre2, cApPaterno, 
						cApMaterno, cRazonSocial, cNumeroCuenta, 
						cNumeroTarjeta, cTipoPersona, cTipoCliente, 
						iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
						cBloqueado, cTerminado, iIdBusqueda, 
						cIdEncontrado, cTipoCuenta, cIndRfc, 
						cIndEmpleo, cIndDomicilio, cIndNacionalidad
						WITH resume;
				END FOREACH;
			END IF;
			-- Criterio de busqueda por Razón Social
			IF pTipoBusqueda = 2 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																cCriterio, '', '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																	pApMaterno, pNombre1, pNombre2, 
																	cCriterio, '', '', 
																	'', '', pId_UsuarioC, 
																	pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				-- Se realiza la consulta de la persona
				LET cTipoBusquedaPersona = '2';
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscaxnombre(pId_UsuarioC, pId_FuncionC, iIdBusqueda,
															pIdOficio, cTipoBusquedaPersona, pNombre1, 
															pNombre2, pApPaterno, pApMaterno, 
															cCriterio, cTipoCuenta, pIp, 
															pMacAddress, pPagina, pRegistros)
					INTO cCodRet, cNumeroCliente, cRfc, 
						iIdNumConsulta, cNombre1, cNombre2, 
						cApPaterno, cApMaterno, cRazonSocial, 
						cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cDescStatusBusqueda, cIdEncontrado
					RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad WITH resume;
				END FOREACH;
			END IF;
			-- Busqueda por RFC
			IF pTipoBusqueda = 3 THEN
				LET cCriterio = TRIM(pNombre1);
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																'', cCriterio, '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																'', cCriterio, '',
																'', '', pId_UsuarioC,
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} COUNT(*)
				INTO iRegsProc
				FROM bdinteg:si_cliente WHERE rfc like trim(cCriterio)||"%";
				--FROM bdinteg:si_cliente WHERE rfc_alterno = cCriterio;
				IF iRegsProc = 0 THEN
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)}  COUNT(*)
					INTO iRegsProc
					FROM bdinteg:si_cliente WHERE rfc_alterno like trim(cCriterio)||"%";
					--FROM bdinteg:si_cliente WHERE rfc = cCriterio;
				END IF;
				IF iRegsProc = 0 THEN
					LET cRfc = cCriterio;
					LET cDescStatusBusqueda = 'NO LOCALIZADO';
					LET cRazonSocial = '';
					-- Registro del resultado obtenido
					EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, 
																	'', '', '', '', 
																	'', cRfc, 
																	cNumeroCliente, '', '', '',
																	cTipoCliente, iStatusBusqueda, pIp, pMacAddress)
																	INTO cCodRetSp, iRegsProc;					
					RETURN cCodRet, cNumeroCliente, cRfc, 
							cNombre1, cNombre2, cApPaterno, 
							cApMaterno, cRazonSocial, cNumeroCuenta, 
							cNumeroTarjeta, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
							cBloqueado, cTerminado, iIdBusqueda, 
							cIdEncontrado, cTipoCuenta, cIndRfc, 
							cIndEmpleo, cIndDomicilio, cIndNacionalidad;
				ELSE
					LET iRegsProc = 0;
					FOREACH 
						EXECUTE PROCEDURE sp_sw_ro_buscaxrfc2(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda, 
																cCriterio, pPagina, pRegistros, pIp, 
																pMacAddress)
						INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
								cNombre1, cNombre2, cApPaterno, cApMaterno, 
								cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda,
								cDescStatusBusqueda, cIdEncontrado
						RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad WITH resume;
					END FOREACH;
				END IF;
			END IF;
			-- Busqueda por numero de cliente
			IF pTipoBusqueda = 4 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																pNombre1, pNombre2, '', '', 
																cCriterio, '', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																pNombre1, pNombre2, '', '', 
																cCriterio, '', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				SELECT SUBSTRING(tpo_persona FROM 2) AS tpo_persona, apell_paterno, apell_materno, nombre1, 
														nombre2, razon_social
				INTO cTipoBusquedaPersona, pApPaterno, pApMaterno, pNombre1, 
						pNombre2, cRazonSocial
				FROM bdinteg:si_cliente 
				WHERE numcte = cCriterio;
				IF cTipoBusquedaPersona is null THEN
					LET cDescStatusBusqueda = 'NO LOCALIZADO';
					LET cNumeroCliente = cCriterio;
					LET cRazonSocial = '';
				-- Registro del resultado obtenido
					EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, '', 
																	'', '', '', '', 
																	'', cNumeroCliente, '', '', 
																	'', cTipoCliente, iStatusBusqueda, pIp,
																	pMacAddress)
					INTO cCodRetSp, iRegsProc;
					RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
							cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
							cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
							cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
							cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad;
				ELSE
					SET ISOLATION TO DIRTY READ;
					FOREACH 
						EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda,
																	1, cCriterio, pRegistros, pIp, 
																	pMacAddress)
						INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
								cNombre1, cNombre2, cApPaterno, cApMaterno, 
								cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
								cDescStatusBusqueda, cIdEncontrado
						RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
								cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
								cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
								iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado,
								cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
								cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
								WITH resume;
					END FOREACH;
				END IF;
			END IF;
			-- Busqueda por numero de cuenta
			IF pTipoBusqueda = 5 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																pNombre1, pNombre2, '', '', 
																'', cCriterio, '', pId_UsuarioC,
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																pNombre1, pNombre2, '', '', 
																'', cCriterio, '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscacte_ctatar(1, cCriterio)
					INTO cCodRetSp, cTipoBusquedaPersona, pApPaterno, pApMaterno, 
							pNombre1, pNombre2, cRazonSocial, cTipoCuenta
					IF cTipoBusquedaPersona is null THEN
						LET cDescStatusBusqueda = 'NO LOCALIZADO';
						LET cRazonSocial = '';
						-- Registro del resultado obtenido
						EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, 
																		'', '', '', '', 
																		'', '', '', cCriterio, 
																		'', '', cTipoCliente, iStatusBusqueda, 
																		pIp, pMacAddress)
						INTO cCodRetSp, iRegsProc;
						RETURN cCodRetSp, cNumeroCliente, cRfc, cNombre1, 
								cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
								cCriterio, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
								iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
								cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
								cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
								WITH resume;
					ELSE
						SET ISOLATION TO DIRTY READ;
						FOREACH 
							EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda, 
																		2, cCriterio, pRegistros, pIp, 
																		pMacAddress)
							INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
									cNombre1, cNombre2, cApPaterno, cApMaterno, 
									cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
									cDescStatusBusqueda, cIdEncontrado
							-- Se actualiza el numero de cuenta
							UPDATE sw_ro_resulper
							SET cuenta = cCriterio
							WHERE id_busqueda = iIdBusqueda 
									AND id_oficio = pIdOficio;
							RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
									cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
									cCriterio, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
									iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
									cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
									cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
									WITH resume;
						END FOREACH;
					END IF;
				END FOREACH;
			END IF;
			-- Busqueda por numero de cuenta
			IF pTipoBusqueda = 6 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																pNombre1, pNombre2, '', '', 
																'', '', cCriterio, pId_UsuarioC,
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																	pNombre1, pNombre2, '', '', 
																	'', '', cCriterio, pId_UsuarioC, 
																	pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscacte_ctatar(2, cCriterio)
					INTO cCodRetSp, cTipoBusquedaPersona, pApPaterno, pApMaterno,
							pNombre1, pNombre2, cRazonSocial, cTipoCuenta
					IF cTipoBusquedaPersona is null THEN
						LET cDescStatusBusqueda = 'NO LOCALIZADO';
						LET cRazonSocial = '';
						-- Registro del resultado obtenido
						EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio,'',
																		'', '', '', '',
																		'', '', '', cCriterio,
																		'',	cTipoCliente, iStatusBusqueda, pIp, 
																		pMacAddress)
						INTO cCodRetSp, iRegsProc;
						RETURN cCodRetSp, cNumeroCliente, cRfc, cNombre1, 
								cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
								cNumeroCuenta, cCriterio, cTipoPersona, cTipoCliente, 
								iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
								cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta,
								cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad  
								WITH resume;
					ELSE
						SET ISOLATION TO DIRTY READ;
						FOREACH 
							EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda,
																		3, cCriterio, pRegistros, pIp, 
																		pMacAddress)
							INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
									cNombre1, cNombre2, cApPaterno, cApMaterno, 
									cRazonSocial, cTipoPersona, cTipoCliente, 
									iStatusBusqueda, cDescStatusBusqueda, cIdEncontrado
							-- Se actualiza el numero de cuenta
							UPDATE sw_ro_resulper
							SET num_tarjeta = cCriterio
							WHERE id_busqueda = iIdBusqueda AND id_oficio = pIdOficio;
							RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
							cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
							cNumeroCuenta, cCriterio, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
							cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
							cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
							WITH resume;
						END FOREACH;
					END IF;
				END FOREACH;
			END IF;
		END IF;
	END
END PROCEDURE;