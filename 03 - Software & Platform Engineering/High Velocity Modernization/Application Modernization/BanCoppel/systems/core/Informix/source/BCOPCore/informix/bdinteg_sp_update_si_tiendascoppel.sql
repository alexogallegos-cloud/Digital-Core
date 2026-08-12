CREATE PROCEDURE "informix".sp_update_si_tiendascoppel(ptienda CHAR(10),pdesc_tienda CHAR(40), pcausa_baja INTEGER)
--RETURNING CHAR(5);

	DEFINE vcodret1         	CHAR(5);
    DEFINE vcodret2         	CHAR(5);
    DEFINE vcodret3         	CHAR(50);
    DEFINE sql_err          	INTEGER;
    DEFINE isam_err         	INTEGER;
    DEFINE desc_err         	CHAR(50);
    DEFINE vcontador        	INTEGER;
    DEFINE ven_transacc     	SMALLINT; 
	DEFINE vsql             	CHAR(400);
    DEFINE vstmt            	CHAR(200);
	

	DEFINE vtienda				CHAR(10);
    DEFINE vdesc_tienda			CHAR(40);
    DEFINE vcausa_baja	 		INTEGER;

    LET  vcodret1         		= '000';
    LET  vcodret2         		= '000';
    LET  vcodret3         		= '';
    LET  sql_err	       		= 0 ;
    LET  isam_err         		= 0 ;
    LET  desc_err         		= '';
    LET  vcontador        		= 0 ;
    LET  ven_transacc     		= 0 ;
	LET  vsql             		= '';
    LET  vstmt            		= '';
	
	LET  vtienda  	 			= '';
    LET  vdesc_tienda 			= '';
	LET  vcausa_baja			= 0;
	
    BEGIN

     ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_update_si_tiendascoppel.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            --RETURN vcodret1;
        END IF;
     END EXCEPTION;
    
     -- SET DEBUG FILE TO "/informix/resplogifx/conciliachq/sp_update_si_tiendascoppel.out";
     --TRACE ON;
	 
	 LET  vtienda 		= ptienda;
	 LET  vdesc_tienda	= pdesc_tienda;
	 LET  vcausa_baja	= pcausa_baja;
	 
	 SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;
	 
	 IF vcausa_baja = 1	 THEN
	 
		DELETE FROM "informix".si_tiendascoppel WHERE tienda = vtienda ;
		
		ELIF (vcausa_baja IN(0,3) AND (SELECT COUNT(*) FROM "informix".si_tiendascoppel WHERE tienda = vtienda) = 0) THEN
	 
		INSERT INTO "informix".si_tiendascoppel (tienda,descripcion) VALUES (vtienda, vdesc_tienda);
	 
	 END IF
    
     END;
    
     -- RETURN vcodret1;
    
    END PROCEDURE;