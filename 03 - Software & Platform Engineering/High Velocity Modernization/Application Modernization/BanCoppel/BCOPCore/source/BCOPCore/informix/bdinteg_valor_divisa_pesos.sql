CREATE PROCEDURE "informix".valor_divisa_pesos(pEmpresa CHAR(3), pFecha   DATE, tipo_div char(2), vClaseDiv CHAR(1),vTipoCons CHAR(1))
RETURNING CHAR(5), DECIMAL(14,6);


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret       CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE isam_err      SMALLINT;
   DEFINE error_info    CHAR(40);
   DEFINE vValor1	    DECIMAL(14,6);
   DEFINE vDivisaCorr   INTEGER;
   DEFINE vMaxFecha     DATE;
 
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret, vValor1;
   END EXCEPTION;

-- SET DEBUG FILE TO "valor_udi.out";
-- TRACE ON;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "00000";
   LET vValor1	  = 0;
   LET vDivisaCorr= 0;



-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

      -- ******************************************
      --   Valida Parametro de Codigo de Divisa   *
      -- ******************************************
      SELECT count(*) 
        INTO vDivisaCorr
	    FROM bdinteg:si_divisas
       WHERE empresa = pEmpresa
	     AND divisa = tipo_div;

        IF vDivisaCorr=0 THEN
           LET cod_ret = "901";
           RETURN cod_ret, vValor1;
        END IF;

      -- *****************************************
      --      Valida Clase de Tipo de Cmabio     *
      -- *****************************************

      SELECT count(*) 
        INTO vDivisaCorr
	    FROM bdinteg:si_clase_tc
       WHERE clase_tpcambio = vClaseDiv;

        IF vDivisaCorr=0 THEN
           LET cod_ret = "902";
           RETURN cod_ret, vValor1;
        END IF;


      -- **************
      -- Precio Inicio*
      -- **************

      
      SELECT precio_compra INTO vValor1
       	FROM bdinteg:si_tpcambio
        WHERE empresa = pEmpresa
       	 AND divisa = tipo_div
       	 AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = pEmpresa
                       	   	      AND divisa = tipo_div
                                  AND fecha_tpcambio = pFecha
								  AND clase_tpcambio = vClaseDiv)
         AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = pEmpresa
                       	   	  AND divisa = tipo_div
                              AND fecha_tpcambio = pFecha
							  AND clase_tpcambio = vClaseDiv)
         AND clase_tpcambio = vClaseDiv;

	  IF vValor1 IS NULL and vTipoCons<>'1' THEN
		SELECT precio_compra INTO vValor1
		  FROM bdinteg:si_histdiv
		 WHERE empresa = pEmpresa
		   AND divisa = tipo_div
		   AND fecha_tc = pFecha
		   AND hora_tc =(SELECT MAX(hora_tc)
					       FROM bdinteg:si_histdiv
						  WHERE empresa = pEmpresa
							AND divisa = tipo_div
							AND fecha_tc = pFecha
							AND clase_tpcambio = vClaseDiv)                 
		AND clase_tpcambio = vClaseDiv;

		IF vValor1 IS NULL THEN
			LET cod_ret = "900";
			RETURN cod_ret, vValor1;
		END IF;
      END IF;

      IF vValor1 IS NULL and vTipoCons='1' THEN
		SELECT MAX(fecha_tc)
		  INTO vMaxFecha
		  FROM bdinteg:si_histdiv
		 WHERE empresa = pEmpresa
		   AND divisa = tipo_div
		   AND fecha_tc <= pFecha
		   AND clase_tpcambio = vClaseDiv;

	    SELECT precio_compra INTO vValor1
		  FROM bdinteg:si_histdiv
		 WHERE empresa = pEmpresa
		   AND divisa = tipo_div
		   AND fecha_tc = vMaxFecha
		   AND hora_tc=(SELECT MAX(hora_tc)
			   		      FROM bdinteg:si_histdiv
					     WHERE empresa = pEmpresa
					       AND divisa = tipo_div
					       AND fecha_tc = vMaxFecha
					       AND clase_tpcambio = vClaseDiv)                 
		   AND clase_tpcambio = vClaseDiv;

		 IF vValor1 IS NULL THEN
			LET cod_ret = "900";
			RETURN cod_ret, vValor1;
		 END IF;
      END IF;
END
RETURN cod_ret, vValor1;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_cifra_archivo_chq_2( pCodigo CHAR(20) ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3	        CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr	        CHAR(150);
    DEFINE vUsuario         CHAR(20);
    DEFINE vLLave           CHAR(200);
    DEFINE vNomarch         CHAR(100);
    DEFINE vRutaOrigen      CHAR(100);
    DEFINE vRutaDestino     CHAR(100);
    DEFINE vNomarchSalida   CHAR(100);
    DEFINE vRutaOriginales  CHAR(100);
    DEFINE vNomarch_salida  CHAR(100);
    
    
    LET cCodRet         = '';
    LET cCodRet2        = 0;
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET vUsuario        = '';
    LET vLLave          = '';
    LET vNomarch        = '';
    LET vRutaOrigen     = '';
    LET vRutaDestino    = '';
    LET vNomarchSalida  = '';
    LET vRutaOriginales = '';
    LET vNomarch_salida = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_chq.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_chq.out";
    TRACE ON;
    
    FOREACH
        SELECT TRIM(usuario), TRIM(llave), TRIM(nomarch), TRIM(ruta_origen), TRIM(nomarch_salida), TRIM(ruta_destino), TRIM(ruta_originales)
          INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales    
          FROM bdinteg:si_configura_pgp_chq
         WHERE codigo = pCodigo
         ORDER BY secuencia
        
        IF vUsuario <> user THEN
            LET cCodRet = '200';
            RETURN cCodRet;
        END IF;
        
        SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/'||TRIM(vUsuario)||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin" > '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM 'echo "export HOME=/home/'||TRIM(vUsuario)||'" >> '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM 'echo "/opt/pgp/bin/pgp --encrypt -i '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' -r '||''''||TRIM(vLLave)||''''||" --armor --compression --output "||TRIM(vRutaDestino)||TRIM(vNomarch_salida)||'" >> '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM '/usr/bin/chmod 777 '||TRIM(vRutaOrigen)||'blinda_archivo.sh';   
        SYSTEM '/usr/bin/sh '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM '/usr/bin/mv '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' '||vRutaOriginales; 
    END FOREACH;
    
    LET cCodRet = '000';
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;