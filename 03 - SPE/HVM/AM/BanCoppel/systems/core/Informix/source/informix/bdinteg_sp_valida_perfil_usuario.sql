CREATE PROCEDURE "informix".sp_valida_perfil_usuario(pEmpresa CHAR(3), pUsuario CHAR(10))
	RETURNING CHAR(6)  AS codigo_retorno,
			CHAR(80) AS mensaje_retorno,
			SMALLINT AS tipo_perfil;
		
	---DECLARACIONES
	DEFINE cCodRet 		CHAR(6); 
	DEFINE cMensajeRet 	CHAR(80);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iIsamErr 	INTEGER;
	DEFINE cErrorInfo 	CHAR(80);
	DEFINE cPerfil 		CHAR(11);
	DEFINE iMuestra 	INTEGER;
	
	---INICIALIZACIONES
	
	LET iSqlErr 		= 0;
	LET iIsamErr 		= 0;
	LET cErrorInfo 		= "";
	LET cCodRet 		= "000000";
	LET cMensajeRet 	= "Se realizÃ³ la consulta correctamente";
	LET cPerfil 		= "";
	Let iMuestra 		= 0 ;
	
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = cErrorInfo;	 
				RETURN cCodRet, cMensajeRet, 0;
			END IF;
		END EXCEPTION;
	
		-- SET DEBUG FILE TO "/informix/jesus/sp_valida_perfil_usuario.out";
		-- TRACE ON;
	
		IF NVL(pEmpresa,"") = "" OR NVL(pUsuario,"")="" THEN
			LET cCodRet = "000001";
			LET cMensajeRet = "Falta un parÃ¡metro de fecha requerido para realizar  la consulta";
			RETURN cCodRet, cMensajeRet, 0;
		END IF;
	
	
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH WITH HOLD
			SELECT perfil
			INTO cPerfil
			FROM si_perfil_ejecut
			WHERE cod_emp = pEmpresa
			AND ejecutivo= pUsuario 
			AND perfil IN ("602","707","109","2001") 
			ORDER BY perfil desc
			IF cPerfil =   "2001" THEN
				Let iMuestra = 0 ;
				EXIT FOREACH;
			ELIF cPerfil <>  "2001" THEN
				Let iMuestra = 1 ;
			ELSE
				Let iMuestra = 0 ;
			END IF;
		END FOREACH
		
		--si es uno se levantara el nuevo reporte
		--si es 0 se levantara el  reporte anterior
		RETURN cCodRet, cMensajeRet, iMuestra;	
			
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para validar que reporte se levantara en el aplicativo GENEREPORCRED',
'AUTOR: JesÃºs Manuel Aguilar Heredia',
'FECHA: ENERO 2014',
'VERSION: 20140214.1735',
'BD: bdinteg',
'DESCRIPCION: Se realiza ajuste al procedimiento para extender el tamaÃ±o de la vaiable cPerfil',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 19/01/2020',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_adm_cons_ejecutivo(e_ejecut CHAR(8),e_mac CHAR(12),e_suc CHAR(4))  
returning char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    DEFINE s_status 		CHAR(1);

	DEFINE s_ejecutivo 		CHAR(8);
	
	DEFINE s_esZona 		INTEGER;
	

    LET cod_ret  = "00000";

    LET s_ejecutivo= "";
	
	LET s_esZona = 0;
  

BEGIN
ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;

         	RETURN  cod_ret;
      END IF ;
   END EXCEPTION ;

SET LOCK MODE TO WAIT 4;
	

	IF NVL(e_mac,'') =='' THEN 
	 	  LET cod_ret = '02000'; -- No contiene Dato de MAC
     	RETURN  cod_ret;
    END IF;

	IF NVL(e_ejecut,'') =='' THEN 
	 	  LET cod_ret = '02002'; -- No contiene Dato de Ejecutivo
    	RETURN  cod_ret;
    END IF;

	IF NVL(e_suc,'') =='' THEN 
	 	  LET cod_ret = '02003'; -- No contiene Dato de Sucursal
     	RETURN  cod_ret;
    END IF;
	
	
	SELECT COUNT(ejecutivo)
		    INTO  s_esZona
    FROM si_ejecut   
	WHERE ejecutivo = e_ejecut
	AND puesto = '005' 
	AND password <> 'BAJA';

	IF s_esZona = 1 THEN
       LET s_status = 'A';
	ELSE
		SELECT status INTO s_status
        FROM si_macejecutivo        
        WHERE ejecutivo = e_ejecut AND MAC = e_suc;
	END IF;
	
	IF NVL(s_status,'') =='' THEN 
	 	  LET cod_ret = '02004'; -- Usuario no Autorizado en esta Sucursal
       	RETURN  cod_ret;
    END IF;
    
    IF NVL(s_status,'') <>'A' THEN 
	 	  LET cod_ret = '02005'; -- Usuario no Activo
     	RETURN  cod_ret;
    END IF;

	IF s_esZona = 1 THEN
      SELECT ejecutivo   
			INTO  s_ejecutivo
		FROM si_ejecut   
		WHERE ejecutivo = e_ejecut;
	ELSE
		SELECT ejecutivo   
		INTO  s_ejecutivo
		FROM si_ejecut   
		WHERE ejecutivo = e_ejecut AND sucursal = e_suc;
	END IF;
    

    IF NVL(s_ejecutivo,'') =='' THEN 
	 	  LET cod_ret = '02006'; -- No se encontro registro de el Ejecutivo
       	RETURN  cod_ret;
    ELSE

    END IF;

     	RETURN  cod_ret;
END
END PROCEDURE

;