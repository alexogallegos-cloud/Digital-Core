CREATE PROCEDURE "informix".sp_sorteobancoppel(p_canal INT,
												p_tpoper INT,
												p_producto INT,
												p_numcte CHAR(9),
												p_sucursal CHAR(4),
												p_foliosuc CHAR(16),
												p_importe MONEY(16,2),
												p_fecha DATE)
RETURNING CHAR(6) AS cod_Ret,CHAR(80) AS mensaje,INTEGER AS rango_ini,INTEGER AS rango_fin;

DEFINE  SQL_ERR			INTEGER;
DEFINE  ISAM_ERR		INTEGER;
DEFINE  ERROR_INFO		VARCHAR(80);
DEFINE  P_COD_RET		VARCHAR(6);
DEFINE  P_MENSAJE		VARCHAR(80);
DEFINE  v_RangoIni		INTEGER;
DEFINE  v_RangoFin		INTEGER;
DEFINE  v_cvesorteo		VARCHAR(6);
DEFINE  v_part1			INTEGER;
DEFINE  v_part2			INTEGER;
DEFINE  v_part3			INTEGER;
DEFINE  v_part4			INTEGER;
DEFINE  v_numbol		INTEGER;
DEFINE  v_persona		INTEGER;
DEFINE  ciclo			INTEGER;
DEFINE  boleto			INTEGER;
DEFINE  boleto_ini		INTEGER;  	 --FMV 24-AGO-10
DEFINE  boleto_fin		INTEGER;
DEFINE v_cltemoral		VARCHAR(10); --FMV 25-AGO-10
DEFINE v_param			CHAR(5);  	 --BGM 14-Sep: se incorpora uso de parÃ¡metro para traer clave de sorteo normal 2010.
DEFINE Vnumcte			CHAR(10);    --RRG
DEFINE Vtpo_persona		CHAR(2);     --RRG
--dsb-10/10/2012
DEFINE cFolio			CHAR(16);
DEFINE cFolio_cupon		CHAR(20);
DEFINE cTicket			CHAR(2);
DEFINE cFecha			CHAR(19);
DEFINE vNumcteParticipa	INTEGER;     --IREB 26-JUL-19 CAMBIO DE TIPO DE CHAR(20) A INTEGER PARA EL CAMBIO DE LA CONSULTA
DEFINE vProd 			INTEGER;

--*********************************************************--

-- Modificado por: Francisco Martinez Viveros	
-- Fecha Modifica: 24/SEPTIEMBRE/2010 
-- Objetivo: Asignacion del Rango de boletos por transaccion mayor a $650
-- MODIFICADO POR: RaÃºl RamÃ­rez Galindo
-- Fecha ModificaciÃ³n: 05/Diciembre/2011
-- Objetivo:Agilizar la Consulta en Corresponsales.

--*********************************************************--

LET P_COD_RET 		 = '00000';
LET P_MENSAJE 		 = 'PROCESO EXITOSO';
LET v_RangoIni 		 = 0;
LET v_RangoFin 		 = 0;
LET v_part1 		 = 0;
LET v_part2			 = 0;
LET v_part3			 = 0;
LET v_part4			 = 0;
LET v_persona		 = 1;  --FMV 18-AGO-10: Todas los clientes son fisicos 01, se controla a los morales en si_cltenoparticipa
LET v_cvesorteo		 = '';
LET SQL_ERR          = 0;
LET ISAM_ERR         = 0;
LET ERROR_INFO       = '';
LET v_numbol         = 0;
LET ciclo            = 1;
LET boleto           = 0;
LET boleto_ini       = 0;  	--FMV 24-AGO-10
LET boleto_fin       = 0;
LET v_cltemoral      = ''; 	--FMV 25-AGO-10
LET Vnumcte          = '';  --RRG
LET Vtpo_persona     = '';  --RRG
--dsb-10/10/2012
LET cFolio			 = '';
LET cFolio_cupon	 = '';
LET cTicket			 = '';
LET cFecha			 = YEAR(p_fecha)||'-'||MONTH(p_fecha)||"-"||DAY(p_fecha)||" "||CURRENT HOUR TO SECOND;
LET vNumcteParticipa = 0;
LET vProd			 = 0;


BEGIN

	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET    = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO;
		RETURN P_COD_RET, P_MENSAJE,v_RangoIni,v_RangoFin;
	END EXCEPTION;

  --SET DEBUG FILE TO "/home/JA/JA-Sorteo-Clases-2013/sorteobancoppel.out";
  --TRACE ON;   

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

	-- BGM 14-Sep: se incorpora uso de parÃ¡metro para traer clave de sorteo normal 2010.
	SELECT valor INTO v_param 
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 118;

-- jom	FOREACH
	SELECT {+INDEX (si_sorteo idx_si_sorteo)}
	cve_sorteo
	INTO v_cvesorteo
	FROM bdinteg:"informix".si_sorteo
	WHERE  p_fecha  BETWEEN f_ini AND f_fin
	AND cve_sorteo = v_param; 	-- BGM 14-Sep: se incorpora uso de parÃ¡metro para traer clave de sorteo normal 2010.

	IF v_cvesorteo = '' OR v_cvesorteo IS NULL THEN
		LET P_COD_RET = '116';   -- FMV 24sep10 Se adiciona codigo
		LET P_MENSAJE = 'NO EXISTE SORTEOS ACTIVOS EN ESTA FECHA';
	ELSE                
		IF p_tpoper = 12 THEN  
			LET v_persona = 1;
			LET p_producto = 9999;
		ELSE
				----- SE MODIFICA PARA AGILIZAR LA CONSULTA EN CORRESPONSALES
			   SELECT {+INDEX (si_cltenoparticipa idx_si_cltenoparticipa)}numcte, tpo_persona
				 INTO Vnumcte, Vtpo_persona
				 FROM bdinteg:"informix".si_cltenoparticipa 
				WHERE numcte = p_numcte;
					
				IF Vnumcte <> '' THEN
				   IF Vnumcte IS NOT NULL THEN						
					  LET v_persona  = 0;                      
					  LET v_cltemoral = p_numcte;
				   END IF;
			   END IF;
		END IF;
		
		IF (p_tpoper = 10 OR  p_tpoper = 11) AND v_cltemoral = p_numcte
										  THEN -- FMV 19-AGO-10: SE ADICIONA CANDADO
			LET v_persona = 0;                                     
		END IF;
		IF (p_tpoper = 10 OR  p_tpoper = 11) AND v_cltemoral <> p_numcte
										  THEN -- FMV 19-AGO-10: SE ADICIONA CANDADO
			LET v_persona = 1;                                     
		END IF;
		
		SELECT {+INDEX (si_participa idx_si_participa)}
		SUM(CASE WHEN tipo_participa = '1' AND id_elemento = p_producto THEN 1 ELSE 0 END) prod,
		SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper THEN 1 ELSE 0 END) trans,
		SUM(CASE WHEN tipo_participa = '3' AND id_elemento = p_canal THEN 1 ELSE 0 END) canal,
		SUM(CASE WHEN tipo_participa = '4' AND id_elemento = v_persona THEN 1 ELSE 0 END) tpo_per,
		SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper  THEN (p_importe / val_min)::INT  ELSE 0 END) numbol
		--SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper AND p_importe  >= val_min THEN 1 ELSE 0 END) numbol --cumple con el minimo para entregarle boleto
		INTO v_part1,v_part2,v_part3,v_part4,v_numbol
		FROM bdinteg:"informix".si_participa
		WHERE cve_sorteo = v_cvesorteo;

		IF v_part1 = 1 AND v_part2 = 1 AND v_part3 = 1 AND v_part4 = 1 AND v_numbol > 0 THEN
			
			----- SE AGREGA PARA CONSULTAR EN TABLA DE CLIENTES Y EMPLEADOS.
			
			
			--SELECT {+INDEX (bdinteg:"informix".si_empleado_cliente_coppel idx_cte_emp2)} numcte
			--INTO vNumcteParticipa
			--FROM bdinteg:"informix".si_empleado_cliente_coppel
			--WHERE numcte = p_numcte
			--AND status = '1';
			
			--IF vNumcteParticipa <> '' OR vNumcteParticipa IS NOT NULL THEN
			
			
			SELECT COUNT(numcte)
			INTO vNumcteParticipa
			FROM bdinteg:"informix".si_empleado_cliente_coppel
			WHERE numcte = p_numcte
			AND status = '1';
			
			IF vNumcteParticipa > '0' THEN
				LET P_MENSAJE  = 'CLIENTE NO PARTICIPA';
			ELSE			
				-- SORTEO DF 
				
				
				SELECT COUNT(producto)
				INTO vProd
				FROM bdicheq:"informix".sc_maechq 
				WHERE num_cte = p_numcte AND producto = '1300' AND empresa = '001';
				
				IF vProd > 0 THEN 
				--IF EXISTS(SELECT producto FROM bdicheq:"informix".sc_maechq WHERE num_cte = p_numcte AND producto = '1300' AND empresa = '001') THEN
					--'ES EMPLEADO';
				ELSE
					--PIDE BOLETOS
					EXECUTE PROCEDURE bdinteg:"informix".sp_asigna_boletos(v_cvesorteo, v_numbol, p_fecha)
					INTO P_COD_RET,P_MENSAJE, v_RangoIni, v_RangoFin;

					/*--INSERTA BOLETOS*/
					IF P_COD_RET = '00000' THEN
						--LET boleto_ini = v_RangoIni;
						--LET boleto_fin = v_RangoFin;
						--for   FMV: 24-AGO-10
							LET boleto_ini = v_RangoIni;  
							LET boleto_fin = v_RangoFin;
						INSERT INTO {+INDEX (si_boleto idx_si_boleto_cte)}
						bdinteg:"informix".si_boleto VALUES(v_cvesorteo,boleto_ini, boleto_fin, CURRENT,p_numcte,'2',p_sucursal,'B','1',p_tpoper,
						p_foliosuc,p_importe,'','','','','',p_fecha,'0200000',ciclo, '');
						  --  LET ciclo = ciclo + 1; FMV:31-AGO-10
						--END for; FMV: 24-AGO-10

						--dsb-10/10/2012
						--Se manda a llamar sp_premios_instantaneos en caso de canal = 4
						IF p_canal = 4 THEN
							--MARCAR LOS BOLETOS EN CASO DE QUE HAYA
							EXECUTE PROCEDURE bdinteg:"informix".sp_premios_instantaneos(p_canal, p_tpoper, p_producto,p_numcte,p_sucursal, p_foliosuc, p_importe, cFecha,boleto_ini,boleto_fin)
							INTO P_COD_RET, cFolio, cFolio_cupon, cTicket;
							LET P_COD_RET = '00000';
						END IF
					ELSE
						LET v_RangoIni = 0;
						LET v_RangoFin = 0;
						LET ciclo = 1;
						LET P_COD_RET = '00000';
					END IF;
				END IF;
			END IF;
		ELSE
			LET v_RangoIni = 0;
			LET v_RangoFin = 0;
			LET P_COD_RET = '117';  -- FMV 24sep10 Se adiciona codigo
			LET P_MENSAJE = 'NO CUMPLE CON PARAMETROS';
		END IF;
	END IF;
	
		RETURN P_COD_RET, P_MENSAJE, v_RangoIni, v_RangoFin;
	
--jom	END FOREACH;

END;
END PROCEDURE
DOCUMENT
'Modifico: Victor Hugo NuÃ±ez',
'FECHA: 10/10/2012',
'Modificacion: Se agrega llamado a sp_premios_instantaneos para marcar los boletos si viene desde corresponsales',
'Objetivo: Sorteo Instantaneo Navidad Millonaria',
'MODIFICO: JOSE ANGEL GAXIOLA GAXIOLA',
'FECHA: 10/07/2013',
'Modificacion: Se agraga condicion para que valide y solo entregue un boleto del sorteo si el importe de la transaccion es mayor o igual a 650.',
'BD: bdinteg',
'Autor: 94565457',
'Fecha: 03/10/2013',
'ModificaciÃ³n: Se adecua sp agregando condicion para que se entreguen rangos de boletos por cada 650 pesos, tambien se agrego validacion para verificar  ', 
'              si el cliente es empleado(Que se encuentre en la tabla:si_empleado_cliente_coppel).',
'              si se cumple dicha condicion no se le asigna boleto para el sorteo. ',
'Sustento:    ',
'Solicita: Israel Flores GonzÃ¡lez',
'Autor: IREB',
'Fecha: 26/07/2019',
'ModificaciÃ³n: Se realiza el ajuste de la consulta de la tabla de empleados',
'BD: BDINTEG';

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