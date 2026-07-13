CREATE PROCEDURE "informix".sp_bitacora_actividades_web( pcanal       CHAR(02),
                                                     ptransaccion CHAR(04),
                                                     psucursal    CHAR(04),
                                                     pusuario     CHAR(08),
                                                     pfolio_suc   CHAR(16),
                                                     pctataotro   CHAR(20) )
RETURNING CHAR(5);
    
	DEFINE vcodret1         	CHAR(5);
    DEFINE vcodret2         	CHAR(5);
    DEFINE vcodret3         	CHAR(50);
    DEFINE sql_err          	INTEGER;
    DEFINE isam_err         	INTEGER;
    DEFINE desc_err         	CHAR(50);
    DEFINE vcontador        	INTEGER;
    DEFINE ven_transacc     	SMALLINT; 
	DEFINE vsql             	CHAR(400);
    
	
    LET  vcodret1         		= '00000';
    LET  vcodret2         		= '000';
    LET  vcodret3         		= '';
    LET  sql_err	       		= 0 ;
    LET  isam_err         		= 0 ;
    LET  desc_err         		= '';
    LET  vcontador        		= 0 ;
    LET  ven_transacc     		= 0 ;
	LET  vsql             		= '';
    
	
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_bitacora_actividades.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
  
    --- SET DEBUG FILE TO "/informix/resplogifx/conciliachq/sp_bitacora_actividades.out";
    --- TRACE ON;
	
    IF ( ( SELECT COUNT(*) FROM si_bitacora_actividades WHERE folio_suc = pfolio_suc ) > 0 ) THEN
					SET ISOLATION TO DIRTY READ;
                   UPDATE si_bitacora_actividades 
                   SET valor = pctataotro ,
                   hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdinteg:si_fechas)
                   WHERE folio_suc = pfolio_suc;
        
        
    ELSE
					SET ISOLATION TO DIRTY READ; 
                   INSERT INTO si_bitacora_actividades  
				   VALUES (pcanal,ptransaccion,psucursal,pusuario,pfolio_suc,NULL, (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdinteg:si_fechas), NULL);
        
    END IF
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;