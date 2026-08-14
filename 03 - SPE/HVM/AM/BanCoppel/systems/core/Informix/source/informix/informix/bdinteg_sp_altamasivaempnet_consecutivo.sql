CREATE PROCEDURE "informix".sp_altamasivaempnet_consecutivo( pCodEmpresa CHAR(3), pNombreArchivo CHAR(12))
RETURNING CHAR(5) as vCodRet1,
		  CHAR(100) as vMensaje,
		  CHAR(20) as vnombre_archivo,
		  CHAR(2) as vSecuencia;

    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2			CHAR(5);
	DEFINE vMensaje			CHAR(100);
	
	DEFINE vNomArchivo		CHAR(20);
	DEFINE vSecuencia		CHAR(2);
	DEFINE vSecAux			CHAR(2);
	DEFINE vNumEmp			CHAR(3);
	DEFINE vExiste			SMALLINT;
	       
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '000';
	LET vCodRet2 = '';
	LET vMensaje = '';

    LET vNomArchivo	= '';
	LET vSecuencia	= '';
	LET vSecAux		= '';
	LET vNumEmp		= '';
	LET vExiste		= 0;

    
  BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_consecutivo.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vMensaje = Desc_Err;
            RETURN vCodRet1, vMensaje, vNomArchivo, vSecuencia;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_carga.out";
    --- TRACE ON;
    
    SET LOCK MODE TO WAIT 5;
    
	    -- // VALIDA EL NUMERO DE EMPRESA
    LET vNumEmp  = SUBSTR(pNombreArchivo, 2, 3);
        
    IF pCodEmpresa <> vNumEmp THEN
        LET vCodRet1 = '00001';
		LET vMensaje = 'EL CODIGO DE EMPRESA NO COINCIDE CON EL NOMBRE DEL ARCHIVO';
		RETURN vCodRet1, vMensaje, vNomArchivo, vSecuencia;
    END IF;
	
	LET vNomArchivo = "%" || SUBSTR(pNombreArchivo,1,12) || "%";
	
	SELECT COUNT(*) INTO vExiste
	FROM bdinteg:"informix".si_altamasivaempnet_ctrl 
	WHERE cod_empresa = pCodEmpresa AND nombre_archivo like vNomArchivo;
	
	IF vExiste = 0 THEN 
		LET vSecuencia = '01';
		LET vCodRet1 = '00001';
		LET vNomArchivo =  pNombreArchivo || vSecuencia;
		LET vMensaje = 'NO EXISTE EL ARCHIVO, ASIGNAR SECUENCIA INICIAL';		
	ELIF vExiste < 10 OR (vExiste + 1) < 10 THEN
		IF vExiste = 9 THEN
			LET vSecuencia = vExiste + 1;
		ELSE
			LET vSecuencia = "0" || (vExiste + 1);
		END IF;
		LET vCodRet1 = '00002';
		LET vNomArchivo =  pNombreArchivo || vSecuencia;
		LET vMensaje = 'NUEVA SECUENCIA';	
	ELSE
		LET vSecuencia = vExiste + 1;
		LET vCodRet1 = '00003';
		LET vNomArchivo =  pNombreArchivo || vSecuencia;
		LET vMensaje = 'NUEVA SECUENCIA';
	END IF;	
	
	RETURN vCodRet1, vMensaje, vNomArchivo, vSecuencia;
	
  END;
    
END PROCEDURE;