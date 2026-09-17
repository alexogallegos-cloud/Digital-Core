CREATE PROCEDURE "informix".sp_migracionocupacion()
	RETURNING CHAR(6) AS codigo_retorno, CHAR(100) as Mensaje;
	
	DEFINE v_numcte 		CHAR(20);
	DEFINE v_Profesion      CHAR(3);
	DEFINE v_codigo_retorno	CHAR(3);
	DEFINE vsqlerr			INTEGER;
    DEFINE v_mensaje		CHAR(100);
	
	--*********************************************************--
	-- Creado por Héctor Manuel Bojórquez Ruelas	
	--19/Febrero/2009
	--Migración de Ocupación
	--*********************************************************--
	
	LET vsqlerr = 0;
	LET v_codigo_retorno = "000";
    LET v_mensaje = "Migración de profesion realizada con éxito";
	
		--SET DEBUG FILE TO '/tmp/sp_MigracionOcupacion.out';
		--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				let v_codigo_retorno = vsqlerr;
				RETURN v_codigo_retorno, v_mensaje;
			END IF;
		END EXCEPTION;

                SELECT {+  INDEX(bdinteg:"informix".si_ctepf inx_ocupacion) } LIMIT 1 profesion INTO v_Profesion FROM bdinteg:si_ctepf	 WHERE profesion IN('05', '06', '09', '11', '12', '13', '15');

                IF v_Profesion IS NULL THEN
                        FOREACH
                            SELECT TRIM(numcte), profesion  INTO v_numcte, v_Profesion FROM bdinteg:si_ctepf		

                            IF v_Profesion = '001' THEN  --ESTUDIANTE
                                    UPDATE bdinteg:si_ctepf SET Profesion = '15' WHERE numcte = v_numcte;
                            END IF;

                            IF v_Profesion = '002' THEN --AMA DE CASA
                                    UPDATE bdinteg:si_ctepf SET Profesion = '12' WHERE numcte = v_numcte;
                            END IF;

                            IF v_Profesion = '003' THEN --EMPLEADO
                                    UPDATE bdinteg:si_ctepf SET Profesion = '11' WHERE numcte = v_numcte;
                            END IF;

                            IF v_Profesion = '004' THEN --PENSIONADO / JUBILADO
                                    UPDATE bdinteg:si_ctepf SET Profesion = '11' WHERE numcte = v_numcte;
                            END IF;

                            IF v_Profesion = '005' THEN --INDEPENDIENTE / COMERCIANTE
                                    UPDATE bdinteg:si_ctepf SET Profesion = '09' WHERE numcte = v_numcte;
                            END IF;

                            IF v_Profesion = '006' THEN --MIGRANTE
                                    UPDATE bdinteg:si_ctepf SET Profesion = '05' WHERE numcte = v_numcte;
                            END IF;

                            IF v_Profesion = '007' THEN --DESEMPLEADO
                                    UPDATE bdinteg:si_ctepf SET Profesion = '06' WHERE numcte = v_numcte;
                            END IF;

                            IF v_Profesion = '008' THEN --EVENTUAL
                                    UPDATE bdinteg:si_ctepf SET Profesion = '13' WHERE numcte = v_numcte;
                            END IF;
                      END FOREACH;
                ELSE
                    	LET v_mensaje = "La migración de profesion solo se realiza una vez";
                END IF;
				
				RETURN v_codigo_retorno, v_mensaje;
				
	END;
END PROCEDURE;