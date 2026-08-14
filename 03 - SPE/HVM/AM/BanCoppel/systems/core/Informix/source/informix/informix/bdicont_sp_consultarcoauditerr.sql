CREATE PROCEDURE "informix".sp_consultarcoauditerr(p_sEmpresa CHAR(3), p_sSistema CHAR(2), p_sUsuario CHAR(8), p_dFechaCaptura DATE)
	RETURNING CHAR(8) AS usuario, INTEGER AS control_poliza, DATE AS fecha_captura, INTEGER AS secuencia, CHAR (3) AS empresa, CHAR (10) AS ccmayor, 
	CHAR (10) AS ccsub, CHAR (10) AS ccsubsub, CHAR (10) AS ccssubsub, CHAR (10) AS ccsssubsub, CHAR (10) AS sector, CHAR (12) AS auxiliar, 
	CHAR (3)  AS cod_ret, CHAR(50) AS descripcion;
  
	--DEFINICION DE VARIABLES	
	DEFINE v_sUsuario			CHAR(8);
	DEFINE v_iControlPoliza		INTEGER;
	DEFINE v_dFechaCaptura		DATE;
	DEFINE v_iSecuencia			INTEGER;
	DEFINE v_sEmpresa			CHAR(3);
	DEFINE v_sCcmayor			CHAR(10);
	DEFINE v_sCcsub				CHAR(10);
	DEFINE v_sCcsubsub			CHAR(10);
	DEFINE v_sCcssubsub			CHAR(10);
	DEFINE v_sCcsssubsub		CHAR(10);
	DEFINE v_sSector			CHAR(10);	
	DEFINE v_sAuxiliar			CHAR(12);
	DEFINE v_sCodRet			CHAR (3);
	DEFINE v_sDescripcion		CHAR(50);
	
	--Sp para consultar la tabla co_auditerr que contiene los errores de las polizas a procesar.
	--SET DEBUG FILE TO "/tmp/sp_consultarcoauditer.out";
	--TRACE ON;

	LET p_sEmpresa = p_sEmpresa;
	LET p_sSistema = p_sSistema;
	LET p_sUsuario = p_sUsuario;
	LET p_dFechaCaptura = p_dFechaCaptura;
	
	BEGIN		
		IF p_sEmpresa = '' OR p_sUsuario = '' THEN			
			RETURN '', '', '', '', '', '', '', '', '', '', '', '', '', '';
		END IF;	
		
		IF NVL(p_dFechaCaptura,'') = '' THEN
			LET p_dFechaCaptura = NULL;
		END IF;				
		
		IF NVL(p_sSistema,'') = '' THEN
			LET p_sSistema = NULL;
		END IF;				
		

		FOREACH			
			SELECT a.usuario, a.control_poliza, a.fecha_captura, a.secuencia, a.empresa, a.ccmayor, a.ccsub, a.ccsubsub, a.ccssubsub, 
			       a.ccsssubsub, a.sector, a.auxiliar, a.cod_ret, b.descripcion
			  INTO v_sUsuario, v_iControlPoliza, v_dFechaCaptura, v_iSecuencia, v_sEmpresa, v_sCcmayor, v_sCcsub, v_sCcsubsub, v_sCcssubsub,
	               v_sCcsssubsub, v_sSector, v_sAuxiliar, v_sCodRet, v_sDescripcion
			  FROM bdicont:co_auditerr a, bdinteg:si_codret b
			 WHERE a.fecha_captura = NVL(p_dFechaCaptura, a.fecha_captura) 
			   AND a.usuario = p_sUsuario 
			   AND a.cod_ret = b.codigo_retorno 
			   AND b.codigo_retorno = a.cod_ret
			   AND b.sistema = NVL(p_sSistema, b.sistema)
			
			RETURN v_sUsuario, v_iControlPoliza, v_dFechaCaptura, v_iSecuencia, v_sEmpresa, v_sCcmayor, v_sCcsub, v_sCcsubsub, v_sCcssubsub,
	        v_sCcsssubsub, v_sSector, v_sAuxiliar, v_sCodRet, v_sDescripcion WITH RESUME;	

		END FOREACH;	 
	END;	
END PROCEDURE;