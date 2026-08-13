CREATE PROCEDURE "informix".sp_obtiene_productos_online(
pNumCliente         	CHAR(20)
)

    RETURNING 
           CHAR(4)       as vcodret1
		  ,CHAR(120)     as vdesc_msj
		  ,CHAR(4)       as vcod_prod
		  ,CHAR(120)     as vdesc_prod
		  ,CHAR(255)     as vcausa_rechazo_bcpl
		  ,CHAR(255)     as vcausa_rechazo_cpl;
         
    DEFINE vcodret1 	  CHAR(4);
	DEFINE vdesc_msj      CHAR(120);
	DEFINE vcod_prod      CHAR(4);
	DEFINE vdesc_prod     CHAR(120);
	DEFINE vcausa_rechazo_bcpl CHAR(255);
	DEFINE vcausa_rechazo_cpl CHAR(255);
	
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);

	
    LET vcodret1 = '0000';
	LET vdesc_msj = 'Consulta Exitosa';
	LET vcod_prod = '0000';
	LET vdesc_prod = 'Tarjeta departamental Coppel y tarjeta de credito BanCoppel';
	LET vcausa_rechazo_bcpl = 'Motivo Bancoppel';
	LET vcausa_rechazo_cpl = 'Motivo Coppel';
	
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';


    BEGIN
	
    ON EXCEPTION SET sql_err, isam_err, desc_err

        --SET DEBUG FILE TO "/informix/LIP/sp_obtiene_productos_online.out";
        --TRACE ON;

        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;

            RETURN vcodret1,vdesc_msj,vcod_prod,vdesc_prod,vcausa_rechazo_bcpl,vcausa_rechazo_cpl;
        END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/LIP/logs/sp_obtiene_productos_online.out";
    --TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	RETURN vcodret1,vdesc_msj,vcod_prod,vdesc_prod,vcausa_rechazo_bcpl,vcausa_rechazo_cpl;
	
END;
END PROCEDURE;