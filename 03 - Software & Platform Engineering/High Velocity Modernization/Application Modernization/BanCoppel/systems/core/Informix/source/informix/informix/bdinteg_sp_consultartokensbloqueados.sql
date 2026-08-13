CREATE PROCEDURE "informix".sp_consultartokensbloqueados(pCodPais CHAR(3),pStatus SMALLINT,pBloque SMALLINT,pRegistros SMALLINT,pUsuario CHAR(10),pCanal CHAR(2))
returning CHAR(5), CHAR (10), CHAR(10), CHAR (30), CHAR (30), CHAR (30), CHAR (30), CHAR(1);

    DEFINE vCod_ret 	CHAR(5);
	DEFINE sql_err 		INTEGER ;
	DEFINE iCont 		INTEGER;
	DEFINE vNumCte 		CHAR(10);
	DEFINE vNSToken 	CHAR(10);
	DEFINE vtipo_token   CHAR(1);
	DEFINE vNombre1 	CHAR(30);
	DEFINE vNombre2 	CHAR (30);
	DEFINE vApellidoPat	CHAR (30);
	DEFINE vApellidoMat CHAR (30);
	
	DEFINE vFechaStatus DATE;
	DEFINE vFechaMod DATE;
	DEFINE vFechaHoy DATE;
    
	LET vNumCte='';
	LET vNSToken='';
	LET vtipo_token='1';
	LET vNombre1 = '';
	LET vNombre2 = '';
	LET vApellidoPat = '';
	LET vApellidoMat = '';
	LET vCod_ret  = "00000";
	LET iCont=0;

	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE LOS CLIENTES Y TOKENS, PARA REALIZAR PROCESO DE CANCELACION EN TOKEN MANAGER, ASI COMO ACTUALIZACIONES DE TABLAS.
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 06/09/2011
	-- BD: bdinteg
	-- SOLICITO :Mauricio León
	--***************************************************************************************************
	-- MODIFICACIÓN:  OBTIENE EL NOMBRE DE LOS CLIENTES Y SE ACTUALIZA EL ESTATUS A 199 EN LA TABLA bdinteg:"informix".si_bpitoken.
	-- AUTOR : José de Jesús Nevarez
	-- FECHA : 13/10/2011
	-- BD: bdinteg
	-- SOLICITO :Mauricio León
	--***************************************************************************************************
	-- MODIFICACIÓN:  SOLO CONSULTA Y OBTIENE LOS CLIENTES Y TOKENS CANCELADOS EN LA TABLA bdinteg:si_bpitoken.
	-- AUTOR : José de Jesús Nevarez
	-- FECHA : 21/10/2011
	-- BD: bdinteg
	-- SOLICITO :Mauricio León
	--*******************************************************************************************************
	--Se agrega validación para token digital, retorna el tipo de token
	--Gabriela Aguilar
	--06/12/2018
	--***************************************************************************************************

	
	--set debug file to "/informix/gaby/ArchivosOut/sp_consultartokensbloqueados.out";
	--trace on;
    
BEGIN
	
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let vCod_ret = sql_err;
            RETURN vCod_ret, '', '', '', '', '','','';
      END IF ;
   END EXCEPTION ;
   
		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		LET vFechaHoy =DATE(current);
		
		SELECT COUNT(num_cliente)::INTEGER INTO iCont FROM  bdinteg:"informix".si_bpitoken 
		WHERE id_status_token = pStatus;
		
		IF(iCont>0) THEN
			FOREACH 
				SELECT SKIP pRegistros FIRST 10  num_cliente,ns_token,DATE(f_status),tipo_token  INTO  vNumCte, vNSToken,vFechaStatus,vtipo_token
					FROM  bdinteg:"informix".si_bpitoken 
					WHERE id_status_token = pStatus
				
					EXECUTE PROCEDURE bdinteg:"informix".splvalfecha(pCodPais,vFechaStatus,pBloque) INTO vCod_ret,vFechaMod;
					
					IF(vFechaMod <= vFechaHoy) THEN
						LET iCont=1;
						EXECUTE PROCEDURE bdinteg: "informix".sp_obtnombre_bpi(pCodPais,vNumCte) INTO vCod_ret, vNombre1, vNombre2, vApellidoPat, vApellidoMat;
						RETURN vCod_ret,vNumCte,vNSToken,vNombre1,vNombre2,vApellidoPat,vApellidoMat,vtipo_token WITH RESUME;
					ELSE
						CONTINUE FOREACH;
					END IF ;
					
			END FOREACH
		
		END IF;
		IF(iCont=0 AND pRegistros=0)THEN
			RETURN "00001",'','', '', '', '','','';
		END IF;
	END;
END PROCEDURE;