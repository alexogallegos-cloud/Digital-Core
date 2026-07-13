CREATE PROCEDURE "informix".sp_intentos_ctas_frec(id_usuariosp Integer)

	--****************************************************************************************************
	-- DESCRIPCION: Guarda hasta 20 intentos por dÃ­a al realizar la consulta a alta de cuentas frecuentes,
    --              recibiendo como parametro : id_usuario
	-- AUTOR : Mariela Cabrera DÃ­az - SOLSER
	-- FECHA : 03/12/2018
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	
	-- Liberar producciÃ³n: 
	--***************************************************************************************************

RETURNING char(5);

DEFINE iSqlErr INTEGER;
DEFINE iExist INTEGER;
DEFINE contIntento INTEGER;
DEFINE primerIntento INTEGER;
DEFINE cCodSp CHAR(5);

LET iExist = 0;
LET contIntento = 0;
LET primerIntento = 1;
LET cCodSp = '00000'; 

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
        SELECT numintento INTO contIntento FROM "informix".bei_intentos_alta_cta_frec 
		WHERE id_usuario=id_usuariosp  and EXTEND(fecha, YEAR TO DAY) = EXTEND(current, YEAR TO DAY);

        IF NVL(contIntento,0) = 0 THEN
            DELETE FROM "informix".bei_intentos_alta_cta_frec WHERE id_usuario=id_usuariosp;
			INSERT INTO "informix".bei_intentos_alta_cta_frec(id_usuario, fecha, numintento) VALUES(id_usuariosp, current YEAR TO DAY, primerIntento);
		ELSE 
			IF(contIntento < 20) THEN
				LET contIntento = contIntento + 1 ;
				UPDATE "informix".bei_intentos_alta_cta_frec SET numintento=contIntento 
				WHERE id_usuario=id_usuariosp and EXTEND(fecha, YEAR TO DAY) = EXTEND(current, YEAR TO DAY);
			ELSE 
				LET cCodSp = '00001';
				Return cCodSp;
			END IF;
        END IF;
RETURN cCodSp;
END;
END PROCEDURE;