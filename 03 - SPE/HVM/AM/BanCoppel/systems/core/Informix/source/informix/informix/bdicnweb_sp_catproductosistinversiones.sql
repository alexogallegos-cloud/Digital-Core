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