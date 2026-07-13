CREATE PROCEDURE "informix".sp_marca_reporte_web ( Pfecha Date,Psucursal Char (04),Pejecutivo Char (08))
RETURNING	CHAR (5) AS cod_ret,
			CHAR (80) AS mensaje;
			
--declaracion de variables de retorno

	DEFINE	cod_ret			CHAR (05);
	DEFINE	mensaje			CHAR (80);
	DEFINE	vsqlerr      	INTEGER;
	
	LET	cod_ret = '00000';
	LET	mensaje = 'MARCADO ACTIVO';
		
BEGIN	
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            let cod_ret = vsqlerr;
            RETURN  cod_ret, 'ERROR EN CENTRAL AL MARCAR REPORTE ACTIVO';
        END IF;
    END EXCEPTION;
			
			SET LOCK MODE TO WAIT 3;
			UPDATE bdmis:mi_rptcierresucestatus
			SET ejecutivo = Pejecutivo, estatus = 'C', hora = CURRENT HOUR TO MINUTE
			WHERE sucursal = Psucursal
			AND fecha_rptcierre = Pfecha ;
						
	RETURN 	cod_ret, mensaje;		
						
END;
END PROCEDURE;