CREATE PROCEDURE "informix".sp_acumuladocheques(pindica VARCHAR(1))
--Parametro "B" indica que es reporte mensual de tarjetas de banda
RETURNING CHAR(5), CHAR(100)

	DEFINE sql_err				INTEGER;
	DEFINE isam_err				INTEGER;
	DEFINE error_info			CHAR(100);
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensajeRetorno		CHAR(100);
	DEFINE vfecha_inicio		DATETIME YEAR to FRACTION(5);
	DEFINE vfecha_fin		    DATETIME YEAR to FRACTION(5);

	DEFINE vDiaActual			CHAR(2);	
	DEFINE vEsLunes				INTEGER;

	DEFINE vProducto		CHAR(4);
	DEFINE vTransacc		CHAR(4);
	DEFINE vMonto			MONEY;
	DEFINE vCantidad		INTEGER;
	DEFINE vDescripcion		CHAR(50);
	DEFINE vPeriodo			CHAR(6);

	LET sql_err			= 0;
	LET isam_err		= 0;
	LET error_info		= '';
	LET vCodigoRetorno	= '0000';
	LET vMensajeRetorno = 'Proceso Exitoso';

	LET vProducto		= '';
	LET vTransacc		= '';
	LET vMonto			= 0;
	LET vCantidad		= 0;
	LET vDescripcion	= '';
	LET vPeriodo		= '';

BEGIN

	-- MANEJO DEL ERROR
	ON EXCEPTION SET sql_err, isam_err, error_info

		--SET DEBUG FILE TO "/resplogifx/sp_acumuladocheques_err_" || YEAR(CURRENT) || MONTH(CURRENT) || DAY(CURRENT) || ".out" WITH APPEND;
		--TRACE ON;

		RETURN sql_err, isam_err || ' ' || error_info;

	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;  
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/resplogifx/sp_acumuladocheques_err_" || YEAR(CURRENT) || MONTH(CURRENT) || DAY(CURRENT) || ".out" WITH APPEND;
	--TRACE ON;

	IF ((
		NOT EXISTS (
			SELECT fecha 
			FROM bdicheq:sc_contproc 
			WHERE proceso = 'pasomovshist' 
			AND Fecha = TODAY - 1 
		)
	)) THEN 
		-- Se valida el estatus del pase de movimientos historico de cheques
		LET vCodigoRetorno = '0001';
		LET vMensajeRetorno = 'No se ha realizado el pase de movimientos historicos de debito';
		RETURN vCodigoRetorno, vMensajeRetorno;	
	END IF;

	IF pindica = 'B' THEN

		LET vDiaActual = LPAD(DAY(CURRENT),2,'0');
					--PARA PRUEBAS SE IGUALA EL IF
					  --IF '02' = '02' THEN
					--IF vDiaActual = '02' THEN	

		--	IF vDiaActual = '02' OR '01' = '01' THEN	  /*Prueba desarrollo*/
		 IF vDiaActual = '02' OR vDiaActual = '01' THEN	  

						SELECT fecha_inicio::DATE,fecha_final::DATE
						INTO vfecha_inicio,vfecha_fin
						FROM intercard:tb_control_reporteria_general 
						WHERE nombre_reporte ='AcumuladoChequesM';

								IF vfecha_fin < CURRENT THEN
									UPDATE intercard:tb_control_reporteria_general	
									SET fecha_inicio_creacion_reporte = CURRENT
									WHERE nombre_reporte = 'AcumuladoChequesM';
									EXECUTE PROCEDURE bditarjeta:sp_acumuladocheques_mensual (vfecha_inicio,vfecha_fin) INTO vCodigoRetorno, vMensajeRetorno;
										IF vCodigoRetorno = '0000' THEN 
											UPDATE intercard:tb_control_reporteria_general 
											SET fecha_inicio = ADD_MONTHS(fecha_inicio,+1),
											fecha_final = ADD_MONTHS(fecha_final,+1),
											reporte_creado = 'T',codigo_devuelto_spl = vCodigoRetorno
											WHERE nombre_reporte = 'AcumuladoChequesM';
											INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_mensual',vCodigoRetorno ||' '||  vMensajeRetorno);

										ELSE
											LET vCodigoRetorno	= '0004';
											LET vMensajeRetorno = 'Fallo en SPL acumuladocheques_mensual';	
											INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_mensual',vCodigoRetorno ||' '||  vMensajeRetorno);
		END IF;
								ELSE
									LET vCodigoRetorno	= '0003';
									LET vMensajeRetorno = 'El reporte mensual se creo con anterioridad';

									INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_mensual',vCodigoRetorno ||' '||  vMensajeRetorno);

		END IF;
		ELSE 
					
						SELECT fecha_inicio,fecha_final
						INTO vfecha_inicio,vfecha_fin
						FROM intercard:tb_control_reporteria_general 
						WHERE nombre_reporte = 'AcumuladoChequesS';

						IF vfecha_fin <= CURRENT THEN 
									UPDATE intercard:tb_control_reporteria_general	
									SET fecha_inicio_creacion_reporte = CURRENT
									WHERE nombre_reporte = 'AcumuladoChequesS';
									EXECUTE PROCEDURE bditarjeta:sp_acumuladocheques_semanal (vfecha_inicio,vfecha_fin) INTO vCodigoRetorno, vMensajeRetorno;
									IF vCodigoRetorno = '0000' THEN 
										UPDATE intercard:tb_control_reporteria_general 
										SET fecha_inicio = DATE(vfecha_inicio) + 7 UNITS DAY,
										fecha_final=DATE(vfecha_inicio) + 14 UNITS DAY,
										reporte_creado = 'T',codigo_devuelto_spl = vCodigoRetorno
										WHERE nombre_reporte = 'AcumuladoChequesS';
										 INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_semanal',vCodigoRetorno ||' '||  vMensajeRetorno);
									ELSE
										LET vCodigoRetorno	= '0004';
										LET vMensajeRetorno = 'Error Controlado';	
                                        INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_semanal',vCodigoRetorno ||' '||  vMensajeRetorno);
									END IF;
						ELSE
									LET vCodigoRetorno	= '0003';
									LET vMensajeRetorno = 'Error Controlado fecha final es mayor que la fecha actual';		

                                    INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_semanal',vCodigoRetorno ||' '|| vMensajeRetorno);

			END IF;

		END IF;

	ELSE 

		LET vCodigoRetorno	= '0002';
		LET vMensajeRetorno = 'El paremetro de ejecucion no es el correcto, valor diferente de B';

		  INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques',vCodigoRetorno || vMensajeRetorno);
		RETURN vCodigoRetorno, vMensajeRetorno;

	END IF;

	RETURN vCodigoRetorno, vMensajeRetorno;
END;

END PROCEDURE;