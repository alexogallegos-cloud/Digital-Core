CREATE PROCEDURE "informix".sp_info_direccion_pyt( pnumcte           char(20),											  
                                                   psecuencia        integer,											  
                                                   ptipo_dir         char(1),
                                                   pcalle            char(40),
                                                   pcolonia          char(60),
                                                   pentre_calles     char(40),
                                                   ppais             char(3),
                                                   pestado           char(2),
                                                   pciudad           char(3),
                                                   pmunicipio        char(5),
                                                   pcod_postal       char(5),
                                                   papart_postal     char(11),
                                                   /*
                                                   ptipo_telef1      char(1),
                                                   ptelefono1        char(13),
                                                   ptipo_telef2      char(1),
                                                   ptelefono2        char(13),
                                                   ptipo_telef3      char(1),
                                                   ptelefono3        char(13),
                                                   pextension        char(5),
                                                   */
                                                   pestado_inegi     char(2),
                                                   pmunicipio_inegi  char(3),
                                                   plocalidad_inegi  char(4),
                                                   pnumerociudad     smallint,
                                                   pnumeroextcalle   char(10),
                                                   pnumerointcalle   char(10),
                                                   pdepartamento     char(6),
                                                   pnumerocalle      integer,
                                                   pnumerocolonia    integer,
                                                   ppuntocardinal    char(1),
                                                   punidadhabitac    char(1),
                                                   pmanzana          smallint,
                                                   potros            smallint,
                                                   pandador          smallint,
                                                   petapa            smallint,
                                                   plote             smallint,
                                                   pedificio         smallint,
                                                   pentrada          smallint,
                                                   pobservaciones    char(80),
                                                   puser_insert      char(8),
                                                   pfecha_insert     date,
                                                   pind_cofeteltel1  char(1),
                                                   pind_cofeteltel2  char(1),
                                                   pind_cofeteltel3  char(1) )
--- RETURNING CHAR(5);
    
	--****************************************************************************************************
	-- DESCRIPCION: Realiza la insercción a la tabla bdinteg:info_direccion_pyt de los datos cuando un registro 
	--	            en la tabla bdinte:si_direcciones es insertado. 
	-- AUTOR : René Aldana 
	-- FECHA : 09/13/2012
	-- BD: Bdinteg
	-- SISTEMA : OFI al actualizar dirección de cliente.
	--***************************************************************************************************
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
	DEFINE vid_address_type INTEGER;
	DEFINE vTelefono_loc  VARCHAR(32);
	DEFINE vTelefono_cel  VARCHAR(32);
	DEFINE vTipoTel          SMALLINT;
	DEFINE vSecuencia        SMALLINT;
	DEFINE vStatus_Tel       CHAR(1); 
	DEFINE vExtension        CHAR(5); 
	DEFINE vCarrier          SMALLINT;
	DEFINE vNombreCarrier    CHAR(20);
	DEFINE StatusValidacion	 SMALLINT;
        
    DEFINE vexiste_cte INTEGER;
    
    LET vid_address_type = '';			
	LET vTelefono_loc  = '';
	LET vTelefono_cel  = '';
	LET vTipoTel    	  = 0;    
	LET vSecuencia  	  = 0;     
	LET vStatus_Tel 	  = 0;     
	LET vExtension  	  = 0;      
	LET vCarrier    	  = 0;     
	LET vNombreCarrier    = 0; 
	LET StatusValidacion  = 0;	
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET sql_err	 = 0;
    LET isam_err = 0;
    
    LET vexiste_cte = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/tmp/sp_info_direccion_pytl.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            --- RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
	-- SET DEBUG FILE TO "/tmp/sp_info_direccion_pyt.out";
	-- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    IF ptipo_dir = 2 THEN 
    
        EXECUTE PROCEDURE bdinteg:sp_consulta_telefonos('001', pnumcte, 1, '0')
        INTO vcodret1,vTelefono_loc,vTipoTel,vSecuencia,vStatus_Tel,vExtension,vCarrier,vNombreCarrier,StatusValidacion;
                                
        EXECUTE PROCEDURE bdinteg:sp_consulta_telefonos('001', pnumcte, 2, '0')
        INTO vcodret1,vTelefono_cel,vTipoTel,vSecuencia,vStatus_Tel,vExtension,vCarrier,vNombreCarrier,StatusValidacion;
        
        IF (vTelefono_loc IS NULL ) THEN
            LET vTelefono_loc = '';
        END IF; 
    
        IF ( vTelefono_cel IS NULL ) THEN
            LET vTelefono_cel = '';
        END IF; 
                    
        IF EXISTS( select numcte from bdinteg:info_direccion_pyt WHERE numcte = pnumcte AND secuencia = psecuencia AND tipo_dir = ptipo_dir ) THEN 
        
            UPDATE bdinteg:info_direccion_pyt					     		
               SET pais           = ppais ,				
                   estado         = pestado ,			
                   ciudad         = pciudad ,				
                   cod_postal     = pcod_postal ,				
                   telefono1      = vTelefono_loc ,				
                   telefono2      = vTelefono_cel ,				
                   numerociudad   = pnumerociudad ,				
                   numeroextcalle = pnumeroextcalle ,				
                   numerocalle    = pnumerocalle ,			
                   numerocolonia  = pnumerocolonia ,				
                   observaciones  = pobservaciones ,			
                   fecha_insert   = pfecha_insert ,				
                   fecha_ctrl     = CURRENT year to fraction(3)				
             WHERE numcte      = pnumcte  
               AND secuencia   = psecuencia	
               AND tipo_dir    = ptipo_dir;
        
        ELSE 	
        
            INSERT INTO bdinteg:info_direccion_pyt 
            (numcte,secuencia,tipo_dir,pais,estado,ciudad,cod_postal,telefono1,telefono2,numerociudad,numeroextcalle,numerocalle,numerocolonia,observaciones,fecha_insert,fecha_ctrl)  
            values 
            (pnumcte ,psecuencia ,ptipo_dir ,ppais ,pestado ,pciudad ,pcod_postal ,vTelefono_loc ,vTelefono_cel ,pnumerociudad ,pnumeroextcalle ,pnumerocalle ,pnumerocolonia ,pobservaciones ,pfecha_insert ,CURRENT year to fraction(3) );						
        
        END IF;
        
    ELIF ptipo_dir = 1 THEN 
    
        EXECUTE PROCEDURE bdinteg:sp_consulta_telefonos('001', pnumcte, 3, '0')
        INTO vcodret1,vTelefono_loc,vTipoTel,vSecuencia,vStatus_Tel,vExtension,vCarrier,vNombreCarrier,StatusValidacion;
        
        EXECUTE PROCEDURE bdinteg:sp_consulta_telefonos('001', pnumcte, 4, '0')
        INTO vcodret1,vTelefono_cel,vTipoTel,vSecuencia,vStatus_Tel,vExtension,vCarrier,vNombreCarrier,StatusValidacion;
        
        IF ( vTelefono_loc IS NULL ) THEN
            LET vTelefono_loc = '';
        END IF; 
    
        IF ( vTelefono_cel IS NULL ) THEN
            LET vTelefono_cel = '';
        END IF; 
        
        IF EXISTS ( select numcte from bdinteg:info_direccion_pyt WHERE numcte = pnumcte AND secuencia = psecuencia AND tipo_dir = ptipo_dir ) THEN 
        
            UPDATE bdinteg:info_direccion_pyt					     		
               SET pais           = ppais,				
                   estado         = pestado,			
                   ciudad         = pciudad,				
                   cod_postal     = pcod_postal,				
                   telefono1      = vTelefono_loc,				
                   telefono2      =  vTelefono_cel,				
                   numerociudad   = pnumerociudad,				
                   numeroextcalle = pnumeroextcalle,				
                   numerocalle    = pnumerocalle,			
                   numerocolonia  = pnumerocolonia,				
                   observaciones  = pobservaciones,			
                   fecha_insert   = pfecha_insert,				
                   fecha_ctrl     = CURRENT year to fraction(3)				
                WHERE numcte      = pnumcte  
                  AND secuencia   = psecuencia	
                  AND tipo_dir    = ptipo_dir;
    
        ELSE 	
        
            INSERT INTO bdinteg:info_direccion_pyt 
            (numcte,secuencia,tipo_dir,pais,estado,ciudad,cod_postal,telefono1,telefono2,numerociudad,numeroextcalle,numerocalle,numerocolonia,observaciones,fecha_insert,fecha_ctrl)  
            values 
            (pnumcte ,psecuencia ,ptipo_dir ,ppais ,pestado ,pciudad ,pcod_postal ,vTelefono_loc ,vTelefono_cel ,pnumerociudad ,pnumeroextcalle ,pnumerocalle ,pnumerocolonia ,pobservaciones ,pfecha_insert ,CURRENT year to fraction(3) );						
        
        END IF;
        
    END IF;			
    
    --- RETURN vcodret1;	
    
	END;	
    
END PROCEDURE;