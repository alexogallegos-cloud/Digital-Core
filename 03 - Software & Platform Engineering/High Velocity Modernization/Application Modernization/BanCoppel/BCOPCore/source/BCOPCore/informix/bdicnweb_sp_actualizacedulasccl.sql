CREATE PROCEDURE "informix".sp_actualizacedulasccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaCcl DATE, pCtaContable CHAR(14), pObservaciones CHAR(255))
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;	
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_actualizacedulasccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaCcl = '' OR  pCtaContable = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE bdicnweb:'informix'.sp_actualizacedulas( pFechaCcl, pCtaContable, pObservaciones )
			INTO cCodRetSp 		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_actualizacedulas ";
			ELIF cCodRetSp::INTEGER = 110  THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 100  THEN
				LET cCodRet = '00017';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 05/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONCILIACIÓN SALDOS CAPTACIÓN',
'DESCRIPCION:SPL que actualiza la administracion de  pantallas de cedulas contables',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_busquedausuarioscedulasccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pRol SMALLINT, pCedula SMALLINT)
		RETURNING CHAR(5) AS codret,
		CHAR(8) AS adm_usuario, 
		CHAR(104) AS nombre, 
		SMALLINT AS funcion, 
		SMALLINT AS cedula; 
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cAdm_Usuario CHAR (8);
	DEFINE cNombre CHAR (104);
	DEFINE cFuncion SMALLINT;
	DEFINE cCedula SMALLINT;
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cAdm_Usuario = '';
	LET cNombre = '';
	LET cFuncion = 0;
	LET cCedula = 0;
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cAdm_Usuario,cNombre,cFuncion,cCedula;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_busquedausuarioscedulasccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRol IS NULL OR pCedula IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cAdm_Usuario,cNombre,cFuncion,cCedula;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cAdm_Usuario,cNombre,cFuncion,cCedula;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE bdicnweb:'informix'.sp_usuariocedulacons(pRol, pCedula)
		INTO cCodRetSp, cAdm_Usuario,cNombre,cFuncion,cCedula;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_usuariocedulacons";
		ELIF cCodRetSp::INTEGER = 110  THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 100  THEN
			LET cCodRet = '00017';
		END IF;
		LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, UPPER(TRIM(cAdm_Usuario)),UPPER(TRIM(cNombre)),cFuncion,cCedula;		
		---- END;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cAdm_Usuario,cNombre,cFuncion,cCedula;
		END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 08/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CATALOGO FIRMAS CEDULA CONTABLE',
'DESCRIPCION:SPL que consulta la busqueda de los usuarios autorizados para la revisión de las Cedulas Contables',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catcedulacontableccl(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		 CHAR(1) AS status,
		 CHAR(10) AS nombre;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cStatus      CHAR(1);
    DEFINE cNombre      CHAR(10);  
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cStatus    = '';
    LET cNombre    = ''; 
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cNombre;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_catcedulacontableccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE bdicnweb:'informix'.sp_cedulacontablestatus(cEmpresa)
			INTO cCodRetSp, cStatus, cNombre		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_cedulacontablestatus ";
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cStatus,UPPER(TRIM(cNombre)) WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cStatus, cNombre;
		END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 30/09/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CATALOGO FIRMAS CEDULA CONTABLE   ',
'DESCRIPCION:SPL que consulta el catalogo firmas cedula contable',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catcedulacontablerolesccl(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		 SMALLINT AS tipo_rol,
		 CHAR(10) AS nombre;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE sTipoRol  SMALLINT;
    DEFINE cNombre  CHAR(10);  
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET sTipoRol	= 0;
	LET cNombre	= '' ;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sTipoRol, cNombre;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_catcedulacontablerolesccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sTipoRol, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sTipoRol, cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE bdicnweb:'informix'.sp_cedulacontableroles(cEmpresa)
			INTO cCodRetSp, sTipoRol, cNombre		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_cedulacontableroles ";
			ELIF cCodRetSp::INTEGER = 110  THEN
				LET cCodRet = '00582';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, sTipoRol,UPPER(TRIM(cNombre)) WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, sTipoRol, cNombre;
		END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 01/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CATALOGO FIRMAS CEDULA CONTABLE',
'DESCRIPCION:SPL que consulta el catalogo de roles de las cedulas contables',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catproductosistinversiones(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR (4) AS id_instrum,
		CHAR (40) AS des_instrum;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdInstrum CHAR (4);
	DEFINE cDesInstrum CHAR (40);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdInstrum = '';
	LET cDesInstrum = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdInstrum, cDesInstrum;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catproductosistinversiones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdInstrum, cDesInstrum;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdInstrum, cDesInstrum;
		END IF;
		
		FOREACH SELECT cod_instrum, nombre 
				INTO cIdInstrum, cDesInstrum
				FROM bdinvers:"informix".sv_instrum 
				
			LET  iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cIdInstrum, UPPER(cDesInstrum) WITH RESUME;		
		END FOREACH;
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdInstrum, cDesInstrum;
		END IF;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 26/08/2015',
'MODULO: CONCILIACIONES ',
'FUNCIONALIDAD: PRODUCTOS DEL SISTEMA PAGARÉ  ',
'DESCRIPCION: SPL que consulta el Catálogo de Productos del Sistema Inversiones',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cedulacontableroles( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), SMALLINT, CHAR(10);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE iTipoRol     SMALLINT;
    DEFINE cNombre      CHAR(10);    
    
    LET cCodRet1   = '000';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr	   = 0;
    LET iSamErr    = 0;
    LET cDesErr    = '';
    LET iExiste    = 0;
    LET iTipoRol   = 0;
    LET cNombre    = '';    
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_cedulacontableroles.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, iTipoRol, cNombre;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_cedulacontableroles.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pEmpresa is null OR pEmpresa <> '001' ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, iTipoRol, cNombre;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM bdicheq:sc_cedulacontableroles;
      
    IF iExiste = 0 THEN
        LET cCodRet1 = '100';
        RETURN cCodRet1, iTipoRol, cNombre;
    END IF;
    
    FOREACH
        SELECT rol_usuario, descripcion_rol
          INTO iTipoRol, cNombre
          FROM bdicheq:sc_cedulacontableroles
          
        RETURN cCodRet1, iTipoRol, cNombre WITH RESUME;
    END FOREACH;
    
    END;
    
END PROCEDURE;