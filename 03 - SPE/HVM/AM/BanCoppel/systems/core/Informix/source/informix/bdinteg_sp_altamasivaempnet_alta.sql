CREATE PROCEDURE "informix".sp_altamasivaempnet_alta( pCodEmpresa CHAR(3), pNombreArchivo CHAR(18), pRegistros INTEGER, pStatus CHAR(1))
RETURNING CHAR(5) as vCodRet1,
		  CHAR(100) as vMensaje,
		  CHAR(20) as vnombre_archivo,
		  CHAR(1) as vstatus;

    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2			CHAR(5);
	DEFINE vMensaje			CHAR(100);
	
	DEFINE vNomArchivo		CHAR(20);
	DEFINE vStatus			CHAR(1);
	DEFINE vNumEmp			CHAR(3);
	
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '000';
	LET vCodRet2 = '';
	LET vMensaje = '';

    LET vNomArchivo	= '';
	LET vStatus		= '';
	LET vNumEmp		= '';
    
  BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_consecutivo.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vMensaje = Desc_Err;
            RETURN vCodRet1, vMensaje, vNomArchivo,vstatus;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_carga.out";
    --- TRACE ON;
    
    SET LOCK MODE TO WAIT 5;
    
	---/// VALIDA QUE LOS CAMPOS NO VENGAN VACIOS
	IF TRIM(pCodEmpresa) = '' OR TRIM(pNombreArchivo) = '' OR NVL(pRegistros,0) = 0 OR TRIM(pStatus) = '' THEN
	    LET vCodRet1 = '00001';
		LET vMensaje = 'FALTAN DATOS DE ENTRADA';
		RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
	END IF;
	
	    -- // VALIDA EL NUMERO DE EMPRESA
    LET vNumEmp  = SUBSTR(pNombreArchivo, 2, 3);
        
    IF pCodEmpresa <> vNumEmp THEN
        LET vCodRet1 = '00002';
		LET vMensaje = 'EL CODIGO DE EMPRESA NO COINCIDE CON EL NOMBRE DEL ARCHIVO';
		RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
    END IF;
	
	---/// VALIDA LONGITUD DEL NOMBRE DEL ARCHIVO
	IF LENGTH( TRIM(pNombreArchivo) ) <> 18 THEN
        LET vCodRet1 = '00003';
		LET vMensaje = 'LA LONGITUD DEL NOMBRE DEL ARCHIVO ES INCORRECTA, DEBE SER DE 18 CARACTERES';
		RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
	END IF;
	
	--- /// VALIDA QUE EL ARCHIVO NO ESTE CARGADO
	--LET vNomArchivo = "%" || SUBSTR(pNombreArchivo,1,12) || "%";
	
	SELECT TRIM(NVL(nombre_archivo,'')), status INTO vNomArchivo, vStatus
	FROM bdinteg:"informix".si_altamasivaempnet_ctrl 
	WHERE cod_empresa = pCodEmpresa AND nombre_archivo = TRIM(pNombreArchivo);
	
	IF vNomArchivo <> '' THEN 
		LET vCodRet1 = '00004';
		LET vMensaje = 'EL ARCHIVO YA ESTA REGISTRADO';
	ELSE
		INSERT INTO bdinteg:"informix".si_altamasivaempnet_ctrl 
		(cod_empresa,nombre_archivo,fecha_genera,hora_genera,total_registros,status)
		VALUES(pCodEmpresa,pNombreArchivo,TODAY,CURRENT,pRegistros, pStatus);
		
		SELECT TRIM(NVL(nombre_archivo,'')), status INTO vNomArchivo, vStatus
		FROM bdinteg:"informix".si_altamasivaempnet_ctrl 
		WHERE cod_empresa = pCodEmpresa AND nombre_archivo = TRIM(pNombreArchivo);
		
		LET vCodRet1 = '00000';
		LET vMensaje = 'ARCHIVO REGISTRADO';
	END IF;	
	
	RETURN vCodRet1, vMensaje, vNomArchivo,vStatus;
	
  END;
    
END PROCEDURE;