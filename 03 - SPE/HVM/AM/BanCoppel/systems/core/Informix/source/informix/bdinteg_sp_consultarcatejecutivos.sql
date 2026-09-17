CREATE PROCEDURE "informix".sp_consultarcatejecutivos(p_sEmpresa CHAR(3), p_sEjecutivo CHAR(8), p_sSucursal CHAR(4), p_sPuesto CHAR(3), 
p_sDepartamento CHAR(3))
RETURNING CHAR(5) AS CodigoRetorno, CHAR(8) AS NumEmpleado, CHAR(45) AS NomEmpleado 

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sCodRet		CHAR(5);
	
    DEFINE v_sEjecutivo 	CHAR(8); 
    DEFINE v_sNombre 		CHAR(45); 
    DEFINE v_sSucursal 		CHAR(4); 
    DEFINE v_sPuesto 		CHAR(3); 
    DEFINE v_sDepartamento 	CHAR(3);              
    DEFINE v_sNombramiento 	CHAR(20); 
    DEFINE v_dVigencia 		DATE; 
    DEFINE v_iPerfil 		INTEGER;    
    DEFINE v_sUserInsert 	CHAR(30); 
    DEFINE v_dFechaInsert 	DATE; 

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet, '', '';
			END IF;
		END EXCEPTION;

	   --set debug file to "/tmp/sp_consultarcatejecutivos.out";
	    --trace on;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
			
		IF NVL(p_sEmpresa, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet, '', '';
		END IF;	 
		
		IF NVL(p_sEjecutivo, '') = '' THEN
			LET p_sEjecutivo = NULL;			
		END IF;
		
		IF NVL(p_sSucursal, '') = '' THEN
			LET p_sSucursal = NULL;			
		END IF;
		
		IF NVL(p_sPuesto, '') = '' THEN
			LET p_sPuesto = NULL;			
		END IF;
		
		IF NVL(p_sDepartamento, '') = '' THEN
			LET p_sDepartamento = NULL;			
		END IF;

		FOREACH
		SELECT ejecutivo,nombre,sucursal,puesto,departamento,nombramiento,vigencia,perfil,user_insert,fecha_insert
		INTO v_sEjecutivo,v_sNombre,v_sSucursal,v_sPuesto,v_sDepartamento,v_sNombramiento,v_dVigencia,v_iPerfil,v_sUserInsert,v_dFechaInsert
		FROM bdinteg:si_ejecut
		WHERE 	ejecutivo between '90000001' and '99999999'
				and vigencia >= today - 400
				and nombramiento not in ('PROMOTOR','CAJERO PRINCIPAL', 'CAJERO MIXTO')
				AND ejecutivo = NVL(p_sEjecutivo,ejecutivo) 
				AND sucursal = NVL(p_sSucursal,sucursal) 
				AND puesto = NVL(p_sPuesto,puesto) 
				AND departamento = NVL(p_sDepartamento,departamento) 
        ORDER BY ejecutivo
		
			LET v_sCodRet = '00000';
			RETURN v_sCodRet, v_sEjecutivo,v_sNombre WITH RESUME;			
		END FOREACH;
	END
END PROCEDURE;