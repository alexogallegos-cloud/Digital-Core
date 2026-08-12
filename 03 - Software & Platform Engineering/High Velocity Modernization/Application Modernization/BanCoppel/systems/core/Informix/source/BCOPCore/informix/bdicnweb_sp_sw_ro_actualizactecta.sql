CREATE PROCEDURE "informix".sp_sw_ro_actualizactecta(pUsuario CHAR(8), 
										pIdFunciON CHAR(10),
										pIdCtecta INT, 
										pIndicadores CHAR(14),
										pIp CHAR(15), 
										pMacAddress CHAR(12))
 RETURNING CHAR(5) AS CodRet,
 INT AS registrosAfectados
        DEFINE cCodRet					CHAR(5);
        DEFINE iSqlErr 					INT;
		DEFINE cctayabloque    			CHAR(1);
		DEFINE cfchaApertura       		CHAR(1);
		DEFINE csucApertura     		CHAR(1);
		DEFINE cdomiSuc     			CHAR(1);
		DEFINE csaldo                  	CHAR(1);
		DEFINE creportarStatus         	CHAR(1);
		DEFINE cbeneficiarios          	CHAR(1);
		DEFINE cfacultados             	CHAR(1);
		DEFINE cdatosTitular   	       	CHAR(1);
		DEFINE cterminado              	CHAR(1);
		DEFINE ccertificaImg	        CHAR(1);
		DEFINE ccertificaEdocta    	  	CHAR(1);
		DEFINE cdetMov			       	CHAR(1);
		DEFINE cbloqueoCtaPorSistema	CHAR(1);
		DEFINE iResulCte                INT;
		LET cCodRet = '00000';
        LET iSqlErr = 0;
		LET cctayabloque    		= '';
		LET cfchaApertura       	= '';
		LET csucApertura     		= '';
		LET cdomiSuc     			= '';
		LET csaldo                 	= '';
		LET creportarStatus        	= '';
		LET cbeneficiarios         	= '';
		LET cfacultados            	= '';
		LET cdatosTitular   	   	= '';
		LET cterminado             	= '';
		LET ccertificaImg	        = '';
		LET ccertificaEdocta      	= '';
		LET cdetMov			       	= '';
		LET cbloqueoCtaPorSistema	= '';
		
		BEGIN
			ON EXCEPTION SET  iSqlErr
				IF iSqlErr <> 0 THEN
					LET cCodRet= iSqlErr;
					RETURN cCodRet, -1;
				END IF;				
			END EXCEPTION;
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
			INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet,-1;
			END IF;
			-- VALIDACIONES DE ENTRADA
			IF  pUsuario = ''OR 
				pIdFunciON = ''OR 
				pIdCtecta = ''OR 
				pIndicadores = ''OR 
				pIp = ''OR 
				pMacAddress =  '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet, -1;
			END IF;
			-- SEPARAR CADA VALOR CORRESPONDIENTE DE LA  CADENA Indicadorse
			LET cctayabloque    		=  SUBSTRING(pIndicadores FROM 1 for 1);
			LET cfchaApertura       	=  SUBSTRING(pIndicadores FROM 2 for 1);
			LET csucApertura     		=  SUBSTRING(pIndicadores FROM 3 for 1);
			LET cdomiSuc     			=  SUBSTRING(pIndicadores FROM 4 for 1);
			LET csaldo                 	=  SUBSTRING(pIndicadores FROM 5 for 1);
			LET creportarStatus        	=  SUBSTRING(pIndicadores FROM 6 for 1);
			LET cbeneficiarios         	=  SUBSTRING(pIndicadores FROM 7 for 1);
			LET cfacultados            	=  SUBSTRING(pIndicadores FROM 8 for 1);
			LET cdatosTitular   	   	=  SUBSTRING(pIndicadores FROM 9 for 1);
			LET cterminado             	=  SUBSTRING(pIndicadores FROM 10 for 1);
			LET ccertificaImg	        =  SUBSTRING(pIndicadores FROM 11 for 1);
			LET ccertificaEdocta      	=  SUBSTRING(pIndicadores FROM 12 for 1);
			LET cdetMov			       	=  SUBSTRING(pIndicadores FROM 13 for 1);
			LET cbloqueoCtaPorSistema	=  SUBSTRING(pIndicadores FROM 14 for 1);
			UPDATE sw_ro_ctecta 
            SET ind_fecha_apertura  = cfchaApertura,
				ind_sucursal_apertura = csucApertura,
				ind_domicilio_sucursal = cdomiSuc,
				ind_saldo = csaldo,
				ind_reportar_status = creportarStatus,
				ind_beneficiarios = cbeneficiarios,
				ind_facultados = cfacultados,
				ind_datos_titular = cdatosTitular,
				ind_terminado = '1'
			WHERE id_ctacte = pIdCtecta;
			SET ISOLATION TO DIRTY READ;
			SELECT id_resulcte
			INTO iResulCte
			FROM sw_ro_ctecta
			WHERE id_ctacte = pIdCtecta;
			--ACTUALIZACION DEL STATUS DEL CLIENTE
			UPDATE {+INDEX (bdicnweb:sw_ro_resulcte idx_resulcte_numcte)} sw_ro_resulcte
			SET ind_terminado = '1'
			WHERE id_resulcte = iResulCte;
			LET iSqlErr = dbinfo('sqlca.sqlerrd2');
			RETURN cCodRet, isqlerr;
		END		
END PROCEDURE;