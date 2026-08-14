CREATE PROCEDURE "informix".sp_consulta_dispersion_poraplicar_canceladas(pIdEmp CHAR(3), pTipoOpe char(1),pRegistro smallint, pFechaIni date, pFechaFin date)
RETURNING   CHAR(5), CHAR(17), INTEGER, DATE, DATE, INTEGER, MONEY(16,2), MONEY(16,2),MONEY(16,2),CHAR(8),CHAR(100), DATE, CHAR(30), DATE, CHAR(20);

	--Declaracion 
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
    DEFINE v_dFecha_disp 		DATE;
    DEFINE v_Motivo_pago        CHAR(30);
    DEFINE v_Fecha_cancelacion  DATE;
    DEFINE v_Referencia_cancela CHAR(20);
	---Inicializacion 
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
    LET v_dFecha_disp 			=DATE(1);
    LET v_Motivo_pago           = '';
    LET v_Fecha_cancelacion     =DATE(1);
    LET v_Referencia_cancela    ='';
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
				NVL(cConcepto,''),
                NVL(v_dFecha_disp,DATE(1)),
                NVL(v_Motivo_pago,''),
                NVL(v_Fecha_cancelacion,DATE(1)),
                NVL(v_Referencia_cancela, '');
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
				NVL(cConcepto,''),
                NVL(v_dFecha_disp,DATE(1)),
                NVL(v_Motivo_pago,''),
                NVL(v_Fecha_cancelacion,DATE(1)),
                NVL(v_Referencia_cancela, '');
	   END IF;
	   
		IF(pTipoOpe="1")THEN --POR APLICAR
				  FOREACH

						SELECT dispersa.nombre_archivo, 
							nomenc.fecha_aplicacion, 
							nomenc.fecha_gen, 
							nomenc.total_registros, 
							nomenc.importe_tot, 
							nomenc.importe_aplicado, 
							nomenc.importe_no_aplicado,
							nomenc.hora_aplicado,
                            dispersa.f_dispersion,
                            dispersa.motivopago

						FROM bdicheq:"informix".sc_nominaencabezadosumariohist nomenc, 
						bdibpi:"informix".bpi_dispersarchivo dispersa,
                        bdibei:"informix".bei_archivos_eval archivos,
                        bdibei:"informix".bei_cat_estatus_eval catestatus

						WHERE dispersa.nombre_archivo = nomenc.nombre_archivo
						AND dispersa.f_dispersion BETWEEN pFechaIni AND pFechaFin
						AND dispersa.id_empresa = pIdEmp
                        
                        AND archivos.id_estatus_eval IN (5,6,7)
                        AND catestatus.id_estatus_eval = dispersa.status_dispersion
                        AND dispersa.status_dispersion IN (5,6,7)

                        UNION

						SELECT dispersa.nombre_archivo, 
							nomenc.fecha_aplicacion, 
							nomenc.fecha_gen, 
							nomenc.total_registros, 
							nomenc.importe_tot, 
							nomenc.importe_aplicado, 
							nomenc.importe_no_aplicado,
							nomenc.hora_aplicado,
                            dispersa.f_dispersion,
                            dispersa.motivopago
						INTO v_cNombre_archivo,
							v_dFecha_aplicacion,
							v_dFecha_gen,
							v_iTotal_registros,
							v_mImporte_tot,
							v_mImporte_aplicado,
							v_mImporte_no_aplicado,
							v_cHora,
                            v_dFecha_disp,
                            v_Motivo_pago

						FROM bdicheq:"informix".sc_nominaencabezadosumario_bpi nomenc, 
						bdibpi:"informix".bpi_dispersarchivo dispersa,
                        bdibei:"informix".bei_archivos_eval archivos

						WHERE dispersa.nombre_archivo = nomenc.nombre_archivo
						AND nomenc.fecha_aplicacion BETWEEN pFechaIni AND pFechaFin
						AND dispersa.id_empresa = pIdEmp
                        AND dispersa.tipo_dispersion IN (1,2)
                        AND dispersa.status_dispersion = 0
                        AND nomenc.status = 1 --estatus por aplicar

						ORDER BY dispersa.nombre_archivo
						
						--Se trae la descripcion del concepto.
                        SELECT FIRST 1 nc.descripcion
                        INTO cConcepto
                        FROM bdicheq:"informix".sc_nominaconceptos nc, bdicheq:"informix".sc_nominamovimientoshist nm
                        WHERE nc.codigoconcepto = nm.concepto
                        AND nm.nombre_archivo = v_cNombre_archivo;

                        IF NVL(cConcepto,'') == '' THEN
                            SELECT FIRST 1 nc.descripcion
                            INTO cConcepto
                            FROM bdicheq:"informix".sc_nominaconceptos nc, bdicheq:"informix".sc_nominamovimientos_bpi nm
                            WHERE nc.codigoconcepto = nm.concepto
                            AND nm.nombre_archivo = v_cNombre_archivo;
                        END IF;

                        --Se saca si fue programada o en linea con las fechas de aplicacion y de generacion
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
							NVL(v_cHora,'00:00:00'),
							NVL(cConcepto,''),
                            NVL(v_dFecha_disp,DATE(1)),
                            NVL(v_Motivo_pago,''),
                            NVL(v_Fecha_cancelacion,DATE(1)),
                            NVL(v_Referencia_cancela, '')
							WITH RESUME;

				  END FOREACH;
			ELIF(pTipoOpe="2")THEN --CANCELADAS
				  FOREACH

						SELECT dispersa.nombre_archivo, 
							nomenc.fecha_aplicacion, 
							nomenc.fecha_gen, 
							nomenc.total_registros, 
							nomenc.importe_tot, 
							nomenc.importe_aplicado, 
							nomenc.importe_no_aplicado,
							nomenc.hora_aplicado,
                            dispersa.f_dispersion,
                            dispersa.motivopago,
                            cancelacion.fecha_cancelacion,
                            cancelacion.referencia_operacion
						INTO v_cNombre_archivo,
							v_dFecha_aplicacion,
							v_dFecha_gen,
							v_iTotal_registros,
							v_mImporte_tot,
							v_mImporte_aplicado,
							v_mImporte_no_aplicado,
							v_cHora,
                            v_dFecha_disp,
                            v_Motivo_pago,
                            v_Fecha_cancelacion,
                            v_Referencia_cancela

						FROM bdicheq:"informix".sc_nominaencabezadosumariohist nomenc,
						bdibpi:"informix".bpi_dispersarchivo dispersa,
                        bdicheq:"informix".sc_referencia_cancelacion cancelacion

						WHERE dispersa.nombre_archivo = nomenc.nombre_archivo
                        AND cancelacion.nombre_archivo = nomenc.nombre_archivo
						AND cancelacion.fecha_cancelacion BETWEEN pFechaIni AND pFechaFin						
                        AND dispersa.id_empresa = pIdEmp
                        AND cancelacion.id_empresa = pIdEmp
                        AND nomenc.status = 5 --Estatus Canceladas

						ORDER BY dispersa.nombre_archivo
						
						--Se trae la descripcion del concepto.
                        SELECT FIRST 1 nc.descripcion
                        INTO cConcepto
                        FROM bdicheq:"informix".sc_nominaconceptos nc, bdicheq:"informix".sc_nominamovimientoshist nm
                        WHERE nc.codigoconcepto = nm.concepto
                        AND nm.nombre_archivo = v_cNombre_archivo;

                        --Se saca si fue programada o en linea con las fechas de aplicacion y de generacion
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
							NVL(cConcepto,''),
                            NVL(v_dFecha_disp,DATE(1)),
                            NVL(v_Motivo_pago,''),
                            NVL(v_Fecha_cancelacion,DATE(1)),
                            NVL(v_Referencia_cancela, '')
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
            LET v_dFecha_disp   =DATE(1);
            LET v_Motivo_pago   ='';
            LET v_Fecha_cancelacion     =DATE(1);
            LET v_Referencia_cancela    ='';
			
			
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
				NVL(cConcepto,''),
                NVL(v_dFecha_disp,DATE(1)),
                NVL(v_Motivo_pago,''),
                NVL(v_Fecha_cancelacion,DATE(1)),
                NVL(v_Referencia_cancela, '');
		END IF;

	END;
END PROCEDURE;