CREATE PROCEDURE "informix".sp_consulta_usuarios_bmovil_prosa( pRegistros INTEGER)

RETURNING CHAR(5)  AS vcodret1,
		  CHAR(20) AS vNumCte,
		  CHAR(30) AS vNombre1,
		  CHAR(30) AS vNombre2,
		  CHAR(30) AS vApellPat,
		  CHAR(30) AS vApellMat,
          CHAR(100) AS vCorreo, 
		  SMALLINT AS vIdStatus,
		  CHAR(10) AS vFechRegistro,
		  CHAR(15) AS vCelServicio,
          CHAR(13) AS vTelefono1,
		  CHAR(13) AS vTelefono2,
		  CHAR(13) AS vTelefono3,
		  CHAR(13) AS vTelefono4,
          CHAR(5)  AS vExtension;
         
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	DEFINE vNumCte	CHAR(20);
	DEFINE vCelServicio	CHAR(15);
	DEFINE vIdStatus	SMALLINT;
	DEFINE vFechRegistro	CHAR(10);
	DEFINE vCorreo		CHAR(100);
    DEFINE vExtension       CHAR(5);
	DEFINE vExtAux	CHAR(5);
	DEFINE vNombre1	CHAR(30);
	DEFINE vNombre2 CHAR(30);
	DEFINE vApellPat CHAR(30);
	DEFINE vApellMat CHAR(30);
	DEFINE vTelefono1 CHAR(13);
	DEFINE vTelefono2 CHAR(13);
	DEFINE vTelefono3 CHAR(13);
	DEFINE vTelefono4 CHAR(13);
	
    
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
	LET vNumCte = '';
	LET vCelServicio = '';
	LET vIdStatus = 0;
	LET vCorreo = '';
    LET vExtension  = '';
	LET vExtAux = '';
	LET vNombre1	='';
	LET vNombre2 	='';
	LET vApellPat 	='';
	LET vApellMat 	='';
	LET vTelefono1 	='';
	LET vTelefono2 	='';
	LET vTelefono3 	='';
	LET vTelefono4 	='';
	LET vFechRegistro = '';

    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_usuarios_sinavatar.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vNumCte, vNombre1, vNombre2, vApellPat, vApellMat, vCorreo, vIdStatus, vFechRegistro, vCelServicio, vTelefono1, vTelefono2, vTelefono3, vTelefono4, vExtension;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_telefonos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	FOREACH 
	  SELECT SKIP pRegistros FIRST 5000 numcte,TRIM(numcel),id_status, DAY(fech_registro)||"/"||MONTH(fech_registro)||"/"||YEAR(fech_registro)
	    INTO vNumCte, vCelServicio, vIdStatus, vFechRegistro
	  FROM bdinteg:"informix".si_bm_usuarios
	  
	  SELECT TRIM(apell_paterno), TRIM(apell_materno), TRIM(nombre1), TRIM(nombre2)
	    INTO vApellPat, vApellMat, vNombre1, vNombre2
	  FROM bdinteg:"informix".si_cliente
	  WHERE numcte = vNumCte;
	  
	  SELECT TRIM(NVL(correo_elec,'')) INTO vCorreo
	  FROM bdinteg:"informix".si_correos
	  WHERE numcte = vNumCte
	  AND status_correo = "A";
	  
	  SELECT TRIM(NVL(telefono,'')), TRIM(NVL(extension,'')) INTO vTelefono1, vExtAux
	  FROM bdinteg:"informix".si_telefonos_actual
	  WHERE numcte = vNumCte
	  AND tipo_tel = 1
	  AND status_tel = 'A';
	  
	  IF vExtension <> '' THEN
		LET vExtension = vExtAux;
	  END IF;
	  
	  SELECT TRIM(NVL(telefono,'')), TRIM(NVL(extension,'')) INTO vTelefono2, vExtAux
	  FROM bdinteg:"informix".si_telefonos_actual
	  WHERE numcte = vNumCte
	  AND tipo_tel = 2
	  AND status_tel = 'A';
	  
	  IF vExtension <> '' THEN
		LET vExtension = vExtAux;
	  END IF;
	  
	  SELECT TRIM(NVL(telefono,'')), TRIM(NVL(extension,'')) INTO vTelefono3, vExtAux
	  FROM bdinteg:"informix".si_telefonos_actual
	  WHERE numcte = vNumCte
	  AND tipo_tel = 3
	  AND status_tel = 'A';
	  
	  IF vExtension <> '' THEN
		LET vExtension = vExtAux;
	  END IF;
	  
	  SELECT TRIM(NVL(telefono,'')), TRIM(NVL(extension,'')) INTO vTelefono4, vExtAux
	  FROM bdinteg:"informix".si_telefonos_actual
	  WHERE numcte = vNumCte
	  AND tipo_tel = 4
	  AND status_tel = 'A';
	  
	  IF vExtension <> '' THEN
		LET vExtension = vExtAux;
	  END IF;
	  
	  RETURN vcodret1, vNumCte, vNombre1, vNombre2, vApellPat, vApellMat, vCorreo, vIdStatus, vFechRegistro, vCelServicio, vTelefono1, vTelefono2, vTelefono3, vTelefono4, vExtension WITH RESUME;
	  --CONTINUE FOREACH;
	  
	END FOREACH;
	
  END;

END PROCEDURE;