CREATE PROCEDURE "informix".sp_cambiaproductotrx(pNumProducto CHAR(5), pNumProductoNew CHAR(5))
	RETURNING CHAR(5)   AS codRet,
              CHAR(100) AS mensaje;

	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(5);
    DEFINE vMensaje CHAR (100);
    DEFINE vtransaccion SMALLINT;
	DEFINE vContador INTEGER;
	DEFINE vNumcte CHAR(9);

	--SET DEBUG FILE TO "/informix/mc/Fernandorb/carga_unificada.out";
	--TRACE ON;

    LET iSqlErr ='0';
    LET vCodRet ='00000';
    LET vMensaje ='CARGA EXITOSA';
    LET vtransaccion = 0;
	LET vContador = 0;
	LET vNumcte = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = '10000';
				LET vMensaje = 'ERROR AL CAMBIAR PRODUCTO: ' || iSqlErr;

				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
				END IF;

				RETURN vCodRet, vMensaje;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			LET vtransaccion = 1;
		END EXCEPTION WITH RESUME;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pNumProducto <> '' OR pNumProducto IS NOT NULL OR pNumProductoNew <> '' OR pNumProductoNew IS NOT NULL THEN 
			BEGIN WORK;
			FOREACH CUR_UPDATE WITH HOLD FOR SELECT numcte INTO vNumcte FROM "informix".sd_pre_aprobados_trx where num_producto = pNumProducto
				
				UPDATE {+INDEX(sd_pre_aprobados_trx idx_pre_aprobados_num_producto)} bdicred:"informix".sd_pre_aprobados_trx
				SET num_producto = pNumProductoNew
				WHERE CURRENT OF CUR_UPDATE;
				
				LET vContador = vContador + 1;

				IF vContador >= 5000 THEN
					COMMIT WORK;
					LET vContador = 0;
					BEGIN WORK;
				END IF;

			END FOREACH;

			IF vContador <= 5000 THEN
				COMMIT WORK;
				LET vContador = 0;
			END IF;
		ELSE
			LET vCodRet = '00001';
			LET vMensaje = 'PARAMETROS INCORRECTOS';
		END IF;

		RETURN vCodRet, vMensaje;
    END;
END PROCEDURE;