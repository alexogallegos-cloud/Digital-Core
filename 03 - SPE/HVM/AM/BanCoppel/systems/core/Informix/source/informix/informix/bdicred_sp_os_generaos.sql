create procedure "informix".sp_os_generaos()
returning char(5);


    define sNum_solicitud       char (20);
    define dFecha_solicitud     date;
    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    define x                Integer;
    DEFINE ERROR_INFO       VARCHAR(80);

    define P_COD_RET        char(5);
    define vCodRet          char(5);

--  Set debug file to '/pisa/pisabanco/pisa_ftes/credito/coronel/sp_os_GeneraOs.out';
--  trace on;

    Begin

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            LET P_COD_RET = SQL_ERR;
            RETURN P_COD_RET;
        END EXCEPTION;

        Let P_COD_RET = '00000';
	Let x = 0;

        ForEach with hold
        Select num_solicitud, fecha_solicitud
        into sNum_solicitud, dFecha_solicitud
        From ss_solicitud_os
        Where status = 'S'
            	execute procedure sp_os_integracion(sNum_solicitud, dFecha_solicitud)  Into vCodRet;
	    	Let x = x + 1;
        End ForEach;

	Return P_COD_RET;

    end;
end procedure
;