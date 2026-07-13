create procedure "informix".sp_reenvia_os_ap()
RETURNING CHAR(6);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************


DEFINE cCodRet      CHAR(6); 
DEFINE vNumSol     	VARCHAR(20,1);
DEFINE vNumSolAux  	VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE fFecha       DATE;
DEFINE p_cod_ret	CHAR(6);

	-- **************************************************************************
	-- *                      ASIGNACION DE VARIABLES                           *
	-- **************************************************************************

	
LET cCodRet     	= '000000';
LET iSqlErr      	= 0;
LET iIsamErr    	= 0;
LET vNumSol     	= '';
LET vNumSolAux  	= '';
LET fFecha       	= date(1);
LET p_cod_ret		= '000000';


   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************   
   

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;


--  SET DEBUG FILE TO "/ifxsif01/Israel/sp_reenvia_os_ap.out";
--  TRACE ON;

	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************	

	set isolation to dirty read;
	set lock mode to wait 3;
	 
    SELECT num_credito
      INTO vNumSolAux
      FROM bdicred:"informix".sd_param_movhis_dep
     where proceso = 16;

    IF vNumSolAux IS NULL THEN 
       LET vNumSolAux = ""; 
       INSERT INTO bdicred:"informix".sd_param_movhis_dep VALUES(16,'');
    END IF;

    select fecha_hoy
      into fFecha
    from bdicred:sd_fechas
    where empresa = '001'; 

    FOREACH WITH HOLD

		SELECT first 5000 a.num_solicitud
			INTO vNumSol
		FROM bdisolic:ss_solicitudes a
			join bdisolic:ss_prospecteo_solicitudes b on (a.num_solicitud = b.num_solicitud)
			join bdisolic:ss_nuevo_parametrico c on (a.num_solicitud = c.num_solicitud)
		WHERE a.status_solicitud = 'PA'
			AND b.canal_sol = 0
			AND sts_prev_pa = 'EE'
			AND a.num_producto = '6500'
			AND a.fecha_insert <= mdy (07,16,2020)
			AND c.status_solicitud = 'S'
			AND b.estatus = 'A'
			AND a.num_solicitud > vNumSolAux
		order by a.num_solicitud
		
		
		EXECUTE PROCEDURE bdisolic:sp_actualiza_status_sol ('001', 'sistema',vNumSol, 'EE', '', '' )
			INTO p_cod_ret;
			
		IF p_cod_ret <> '000000' THEN
			LET cCodRet= '00001'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
				RETURN cCodRet;
		END IF;

        BEGIN WORK;
		
			UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
				set status_solicitud = 'EE', sts_prev_pa = 'PA'  
			where num_solicitud = vNumSol; 
		
			INSERT INTO bdisolic:"informix".ss_solicitud_os (empresa,   num_solicitud, fecha_solicitud, status, usuario_solicita, observacion1, motivo_os, secuenciaos)
				VALUES ('001', vNumSol, fFecha, "S", user, "PA", 1, 0);

            UPDATE bdicred:"informix".sd_param_movhis_dep
               SET num_credito = vNumSol
             where proceso = 16;

        COMMIT WORK;  

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE
