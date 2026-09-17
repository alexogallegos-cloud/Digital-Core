CREATE PROCEDURE "informix".sp_genera_reporte_credenciales_p109()
    RETURNING CHAR(9);

    DEFINE vc_CodRet                CHAR(5);
    DEFINE vi_SqlErr                INT;
    DEFINE iContador                INTEGER;
    DEFINE sCommit                  SMALLINT;

    DEFINE fecha_operacion			DATE;
	DEFINE sucursal				    CHAR(5);
    DEFINE nombre_sucursal 		    CHAR(40);
	DEFINE nombre1					CHAR(26);
	DEFINE nombre2					CHAR(26);
	DEFINE apell_paterno			CHAR(26);
	DEFINE apell_materno			CHAR(26);
	DEFINE fecha_nac				DATE;
	DEFINE ocr						CHAR(13);
	DEFINE situacion				CHAR(1);
	DEFINE test_uv_reflec_anv		CHAR(20);
	DEFINE test_uv_shape_anv		CHAR(20);
	DEFINE test_ir_ink_anv			CHAR(20);
	DEFINE test_uv_reflectance_rev	CHAR(20);
	DEFINE test_ir_ink_rev			CHAR(20);

    --INICIALIZACION DE VARIABLES
    LET vc_CodRet = "00000";
    LET vi_SqlErr = 0;
    LET iContador = 0;
    LET sCommit = 0;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN

		ON EXCEPTION SET vi_SqlErr 
			IF vi_SqlErr <> 0 THEN
		
				IF sCommit = -1 THEN
				ROLLBACK WORK;
				END IF;
		
				LET vc_CodRet = vi_SqlErr;
				RETURN vc_CodRet;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/LIP/sp_genera_reporte_credenciales_p109.out";
		--TRACE ON;
	
	
		---CREACION DE TABLA TEMPORAL
		CREATE TEMP TABLE si_rpt_credenciales_p109_temp ( 
		id           	SERIAL NOT NULL,
		fecha_operacion			DATE,
		sucursal				CHAR(5),
		nombre_sucursal 		CHAR(40),
		nombre1					CHAR(26),
		nombre2					CHAR(26),
		apell_paterno			CHAR(26),
		apell_materno			CHAR(26),
		fecha_nac				DATE,
		ocr						CHAR(13),
		situacion				CHAR(1),
		test_uv_reflec_anv		CHAR(20),
		test_uv_shape_anv		CHAR(20),
		test_ir_ink_anv			CHAR(20),
		test_uv_reflectance_rev	CHAR(20),
		test_ir_ink_rev			CHAR(20),
		primary key (id)
		)WITH NO LOG EXTENT SIZE 57617 NEXT SIZE 5762 LOCK MODE ROW;
	
		--set pdqpriority 5;
		begin;
			CREATE INDEX "informix".idx_rpt_credenciales_p109 ON "informix".si_rpt_credenciales_p109_temp(sucursal)
			online;
		commit;

		---set pdqpriority 0;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_rpt_credenciales_p109_temp;
	
		
		--OBTENCION DE DATOS
        SET ISOLATION TO DIRTY READ;
        FOREACH WITH HOLD
						
            SELECT sit.fchalta::date, btc.sucursal, suc.nombre, cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, ctepf.fecha_nac,
            SUBSTR(btc.cadena_reverso, INSTR(btc.cadena_reverso,'CRC_SECTION: ',0) + 13, 13),
			sit.situacion, btc.test_uv_reflec_anv, btc.test_uv_shape_anv, btc.test_ir_ink_anv, btc.test_uv_reflectance_rev, btc.test_ir_ink_rev
            INTO fecha_operacion,sucursal,nombre_sucursal,nombre1,nombre2,apell_paterno,apell_materno,fecha_nac,ocr,situacion,test_uv_reflec_anv,test_uv_shape_anv,test_ir_ink_anv,test_uv_reflectance_rev,test_ir_ink_rev
            FROM bdinteg:"informix".si_bitacora_ife btc
            INNER JOIN bdisitesp:"informix".se_ctessitespcte sit
                    ON btc.numcte = sit.numcte
                    AND btc.fecha::date = sit.fchalta::date
					AND btc.fecha = (SELECT MAX (fecha) FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = sit.numcte AND fecha::date = sit.fchalta::date)
            INNER JOIN bdinteg:"informix".si_sucursales suc
                    ON btc.sucursal = suc.sucursal
            INNER JOIN bdinteg:"informix".si_cliente cte
                    ON btc.numcte = cte.numcte
                       INNER JOIN bdinteg:"informix".si_ctepf ctepf
                               ON cte.numcte = ctepf.numcte
            WHERE sit.situacion='P' AND sit.causa='109'
			AND UPPER(SUBSTR(btc.cadena_reverso, INSTR(btc.cadena_reverso,'CRC_SECTION: ',0) + 13, 13)) == LOWER(SUBSTR(btc.cadena_reverso, INSTR(btc.cadena_reverso,'CRC_SECTION: ',0) + 13, 13))
			AND TRIM(btc.test_uv_reflec_anv) != '0' AND TRIM(btc.test_uv_shape_anv) != '0' AND TRIM(btc.test_ir_ink_anv) != '0' AND TRIM(btc.test_uv_reflectance_rev) != '0' AND TRIM(btc.test_ir_ink_rev) != '0'
			AND LENGTH(cte.nombre1) > 0 AND LENGTH(cte.apell_paterno) > 0 AND LENGTH(cte.apell_materno) > 0
            AND sit.fchalta::date BETWEEN TO_DATE('01/01/2016', '%d/%m/%Y') AND TO_DATE('28/02/2017', '%d/%m/%Y')
			ORDER BY btc.sucursal, sit.fchalta
							
                IF (sCommit = 0) THEN
                    BEGIN WORK;
                    LET iContador = 0;
                    LET sCommit = -1;
                END IF;

				
				INSERT INTO si_rpt_credenciales_p109_temp(fecha_operacion,sucursal,nombre_sucursal,nombre1,nombre2,apell_paterno,apell_materno,fecha_nac,ocr,situacion,test_uv_reflec_anv,test_uv_shape_anv,test_ir_ink_anv,test_uv_reflectance_rev,test_ir_ink_rev) 
				VALUES (fecha_operacion,sucursal,nombre_sucursal,nombre1,nombre2,apell_paterno,apell_materno,fecha_nac,ocr,situacion,test_uv_reflec_anv,test_uv_shape_anv,test_ir_ink_anv,test_uv_reflectance_rev,test_ir_ink_rev);
				
							
                LET iContador = iContador  + 1;		
				
                --Ejecutar un commit cada 5000 registros.
                IF (iContador >= 5000) THEN
                    COMMIT WORK;	
                    LET iContador = 0;
                    BEGIN WORK;
                END IF;										
        END FOREACH;
					
		IF sCommit = -1 THEN
		COMMIT WORK;
		END IF;
		LET sCommit = 0;
    
    RETURN vc_CodRet;

    END;
END PROCEDURE;