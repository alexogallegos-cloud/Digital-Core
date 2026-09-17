CREATE PROCEDURE "informix".sp_reportenomina_bei(pIdEmp CHAR(3), pFecDisp date,pTipoOpe char(1),pRegistro smallint)
RETURNING   CHAR(5), CHAR(17), INTEGER, DATE, DATE, INTEGER, MONEY(16,2), MONEY(16,2),MONEY(16,2),CHAR(8),CHAR(100);


	--****************************************************************************************************
	-- DESCRIPCION:  Obtiene los archivos de dispersión para reporte de nómina
	-- AUTOR : ING. ALFONSO CRUZ
	-- FECHA : 03/01/2013
	-- BD: bdicheq
	-- SOLICITO : Jose de Jesus Nevarez
	--***************************************************************************************************
   	-- MODIFICACIÓN: Se modificó para asignar a la variable  ?v_iTipo_dispersion? si la dispersión fue 
  	--   programada o en linea basándose en las fechas de aplicación y de generación del archivo.
	--	 Se cambio la manera en la que se consulta cuando va por los no aplicados.
	--   Va por la descripción del concepto a la tabla sc_nominaConceptos.
  	-- MODIFICÓ: Berenice Noriega
  	-- FECHA: 16/01/2013
	-- MODIFICACIÓN: Se comento que se filtre por campo status_dispersion de la tabla bdibpi:bpi_dispersarchivo
	-- FECHA: 20/02/2013
	--***************************************************************************************************
	-- MODIFICÓ: Berenice Noriega
  	-- FECHA: 2015-Enero-12
	-- MODIFICACIÓN: modifica condicion para que enviar codigo 00002 cuando ya no encuentra ningun registro.
	-- asi como regresar datos inicializados.
     	--***************************************************************************************************

	--Declaración 
	DEFINE v_iSqlErr         	INTEGER;
	DEFINE v_cCodRet        	CHAR(5);
	DEFINE iCont  				INTEGER;
	DEFINE vciclo				SMALLINT;
	
	DEFINE v_cNombre_archivo 	CHAR(17);
	DEFINE v_iTipo_dispersion 	INTEGER;
	DEFINE v_dFecha_aplicacion 	DATE;
	DEFINE v_dFecha_gen 		DATE;
	DEFINE v_iTotal_registros 	INTEGER;
	DEFINE v_mImporte_tot 		MONEY(16,2);
	DEFINE v_mImporte_aplicado 	MONEY(16,2);
    DEFINE v_mImporte_no_aplicado 	MONEY(16,2);
	DEFINE v_cHora				CHAR(8);
	DEFINE cConcepto         	CHAR(100);
	---Inicialización 
	LET v_iSqlErr				=0;
	LET v_cCodRet = "00000";
	LET iCont=0;
	LET vciclo					= 0;
	
	LET v_cNombre_archivo 		='';
	LET v_iTipo_dispersion 		= 0;
	LET v_dFecha_aplicacion 	=DATE(1);
	LET v_dFecha_gen 			=DATE(1);
	LET v_iTotal_registros 		=0;
	LET v_mImporte_tot 			=0.00;
	LET v_mImporte_aplicado 	=0.00;
    LET v_mImporte_no_aplicado 	= 0.00;
	LET v_cHora 				='';
	LET cConcepto 				= '';
	BEGIN
    ON EXCEPTION SET v_iSqlErr
        IF v_iSqlErr <> 0 THEN
            LET v_cCodRet  = v_iSqlErr;
			RETURN  v_cCodRet, 
				NVL(v_cNombre_archivo,''),
				NVL(v_iTipo_dispersion,0),
				NVL(v_dFecha_aplicacion,DATE(1)),
				NVL(v_dFecha_gen,DATE(1)),
				NVL(v_iTotal_registros,0),
				NVL(v_mImporte_tot,0.00),
				NVL(v_mImporte_aplicado,0.00),
				NVL(v_mImporte_no_aplicado,0.00),
				NVL(v_cHora,''),
				NVL(cConcepto,'');
        END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO '/home/informix/BereniceOut/sp_reportenomina_bei.sql';
	--TRACE ON;
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;

	   IF pIdEmp = "" OR pTipoOpe = "" THEN
	        LET  v_cCodRet  = "00001";
			
			RETURN  v_cCodRet, 
				NVL(v_cNombre_archivo,''),
				NVL(v_iTipo_dispersion,0),
				NVL(v_dFecha_aplicacion,DATE(1)),
				NVL(v_dFecha_gen,DATE(1)),
				NVL(v_iTotal_registros,0),
				NVL(v_mImporte_tot,0.00),
				NVL(v_mImporte_aplicado,0.00),
				NVL(v_mImporte_no_aplicado,0.00),
				NVL(v_cHora,''),
				NVL(cConcepto,'');
	   END IF;
	   
		IF(pTipoOpe="1")THEN --APLICADOS
	
			  FOREACH

					SELECT dispersa.nombre_archivo, 
						nomenc.fecha_aplicacion, 
						nomenc.fecha_gen, 
						nomenc.total_registros, 
						nomenc.importe_tot, 
						nomenc.importe_aplicado, 
						nomenc.importe_no_aplicado,
						nomenc.hora_aplicado
					INTO v_cNombre_archivo,
						v_dFecha_aplicacion,
						v_dFecha_gen,
						v_iTotal_registros,
						v_mImporte_tot,
						v_mImporte_aplicado,
						v_mImporte_no_aplicado,
						v_cHora
					FROM bdicheq:"informix".sc_nominaencabezadosumariohist nomenc, 
					bdibpi:"informix".bpi_dispersarchivo dispersa
					WHERE dispersa.nombre_archivo = nomenc.nombre_archivo
					AND dispersa.f_dispersion = pFecDisp 
					AND dispersa.id_empresa = pIdEmp
					--AND dispersa.status_dispersion = 1 --Atendido
					AND nomenc.status IN (2, 3) --Procesado o Procesado Parcialmente
					ORDER BY dispersa.nombre_archivo
				
                    --Se trae la descripción del concepto.
                    SELECT FIRST 1 nc.descripcion
                	INTO cConcepto
                    FROM bdicheq:"informix".sc_nominaconceptos nc, bdicheq:"informix".sc_nominamovimientoshist nm
                    WHERE nc.codigoconcepto = nm.concepto
                    AND nm.nombre_archivo = v_cNombre_archivo;

					--Se saca si fue programada o en linea con las fechas de aplicación y de generación
                    IF v_dFecha_aplicacion > v_dFecha_gen THEN
                    LET v_iTipo_dispersion=1; --Programada
                    ELIF v_dFecha_aplicacion = v_dFecha_gen  THEN
                    LET v_iTipo_dispersion=2; --En Linea
                    END IF;
					
					LET iCont=1;
					
					LET vCiclo = vCiclo + 1;

					--Paginacion
					IF vciclo <= pRegistro THEN
						CONTINUE FOREACH;
					END IF; 
					
					RETURN  v_cCodRet, 
						NVL(v_cNombre_archivo,''),
						NVL(v_iTipo_dispersion,0),
						NVL(v_dFecha_aplicacion,DATE(1)),
						NVL(v_dFecha_gen,DATE(1)),
						NVL(v_iTotal_registros,0),
						NVL(v_mImporte_tot,0.00),
						NVL(v_mImporte_aplicado,0.00),
						NVL(v_mImporte_no_aplicado,0.00),
						NVL(v_cHora,''),
						NVL(cConcepto,'')
						WITH RESUME;

			  END FOREACH;
			ELIF(pTipoOpe="2")THEN --NO APLICADOS
				  FOREACH

						SELECT dispersa.nombre_archivo, 
							nomenc.fecha_aplicacion, 
							nomenc.fecha_gen, 
							nomenc.total_registros, 
							nomenc.importe_tot, 
							nomenc.importe_aplicado, 
							nomenc.importe_no_aplicado,
							nomenc.hora_aplicado
						INTO v_cNombre_archivo,
							v_dFecha_aplicacion,
							v_dFecha_gen,
							v_iTotal_registros,
							v_mImporte_tot,
							v_mImporte_aplicado,
							v_mImporte_no_aplicado,
							v_cHora
						FROM bdicheq:"informix".sc_nominaencabezadosumariohist nomenc, 
						bdibpi:"informix".bpi_dispersarchivo dispersa
						WHERE dispersa.nombre_archivo = nomenc.nombre_archivo
						AND dispersa.f_dispersion = pFecDisp 
						AND dispersa.id_empresa = pIdEmp
						--AND dispersa.status_dispersion = 1 --Atendido
						AND nomenc.status >= 3 --Procesado parcialmente, Error, No hay saldo en la cuenta .
						ORDER BY dispersa.nombre_archivo
						
						--Se trae la descripción del concepto.
                        SELECT FIRST 1 nc.descripcion
                        INTO cConcepto
                        FROM bdicheq:"informix".sc_nominaconceptos nc, bdicheq:"informix".sc_nominamovimientoshist nm
                        WHERE nc.codigoconcepto = nm.concepto
                        AND nm.nombre_archivo = v_cNombre_archivo;

                        --Se saca si fue programada o en linea con las fechas de aplicación y de generación
						IF v_dFecha_aplicacion > v_dFecha_gen THEN
						LET v_iTipo_dispersion=1; --Programada
						ELIF v_dFecha_aplicacion = v_dFecha_gen  THEN
						LET v_iTipo_dispersion=2; --En Linea
						END IF;
	
						LET iCont=1;
						
						LET vCiclo = vCiclo + 1;

						--Paginacion
						IF vciclo <= pRegistro THEN
							CONTINUE FOREACH;
						END IF; 
						
						RETURN  v_cCodRet, 
							NVL(v_cNombre_archivo,''),
							NVL(v_iTipo_dispersion,0),
							NVL(v_dFecha_aplicacion,DATE(1)),
							NVL(v_dFecha_gen,DATE(1)),
							NVL(v_iTotal_registros,0),
							NVL(v_mImporte_tot,0.00),
							NVL(v_mImporte_aplicado,0.00),
							NVL(v_mImporte_no_aplicado,0.00),
							NVL(v_cHora,''),
							NVL(cConcepto,'')
							WITH RESUME;

				  END FOREACH;
			END IF;
		IF(v_cNombre_archivo<>" ") and (vciclo <= pRegistro) THEN
			LET v_cCodRet		='00002';
			LET v_cNombre_archivo 	='';
			LET v_iTipo_dispersion 	= 0;
			LET v_dFecha_aplicacion =DATE(1);
			LET v_dFecha_gen 	=DATE(1);
			LET v_iTotal_registros 	=0;
			LET v_mImporte_tot	=0.00;
			LET v_mImporte_aplicado =0.00;
		    	LET v_mImporte_no_aplicado = 0.00;
			LET v_cHora 		='';
			LET cConcepto 		= '';
			
			
			RETURN  v_cCodRet, 
				NVL(v_cNombre_archivo,''),
				NVL(v_iTipo_dispersion,0),
				NVL(v_dFecha_aplicacion,DATE(1)),
				NVL(v_dFecha_gen,DATE(1)),
				NVL(v_iTotal_registros,0),
				NVL(v_mImporte_tot,0.00),
				NVL(v_mImporte_aplicado,0.00),
				NVL(v_mImporte_no_aplicado,0.00),
				NVL(v_cHora,''),
				NVL(cConcepto,'');
		END IF;

	END;
END PROCEDURE;