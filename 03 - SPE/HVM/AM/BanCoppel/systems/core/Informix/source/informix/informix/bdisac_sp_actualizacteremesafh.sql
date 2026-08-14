CREATE PROCEDURE "informix".sp_actualizacteremesafh(FechaIns DATE,FechaBusqueda DATE)

	RETURNING CHAR(5) AS iCodRet, char(50) as iMensaje;

		DEFINE vnumcte 		CHAR(20);
		DEFINE vcont 		INTEGER;
		DEFINE vcontc 		INTEGER;
		DEFINE vFhins		DATE;
		DEFINE vFhbusqueda	DATE;
		DEFINE iCodRet 		CHAR(5);
		DEFINE iMensaje		CHAR(50);
		DEFINE iSqlErr 		INTEGER;
		DEFINE vtransaccion		SMALLINT;
		
		
		
		--SET DEBUG FILE TO '/informix/HMLG/sp_actualizacteremesafh.out';
		--TRACE ON; 
		
		LET iSqlErr = 0;
		LET vnumcte = '';
		LET vcont = 0;
		let vcontc = 0;
		LET vtransaccion = 0;
		LET iCodRet = '00000';
		LET iMensaje = 'PROCESO EXITOSO';
		
		BEGIN
		
		
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			LET iMensaje = "Proceso NO Exitoso Error BD.";
			
			
			RETURN iCodRet,iMensaje;
			
		END IF;
		END EXCEPTION;
		
		--Manejo de transacciones
		ON EXCEPTION IN (-535)
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH resume;
		ON EXCEPTION IN (-255)
			BEGIN WORK;
		END EXCEPTION WITH resume;
	
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		IF FechaIns IS NULL OR FechaIns = '' OR FechaBusqueda IS NULL OR FechaBusqueda = '' THEN 
			LET iCodRet = '00001';
			LET iMensaje = 'PARAMETROS DE ENTRADA SP INVALIDOS';
		
		ELSE 
			LET vFhins = FechaIns;
			LET vFhbusqueda = FechaBusqueda;
		END IF;
		
		DROP TABLE IF EXISTS TBL_CLIENTES_TMP;
		
		SELECT numcte 
			FROM sac_cte_remesas 
			WHERE fecha_vencimiento = vFhbusqueda
			INTO TEMP TBL_CLIENTES_TMP WITH NO LOG;
				
		SELECT COUNT(*) INTO vcontc FROM TBL_CLIENTES_TMP;
				
		IF iCodRet = '00000' and vcontc > 0 THEN
		
			BEGIN WORK;

			FOREACH WITH HOLD
						
				SELECT numcte 
				INTO vnumcte 
				FROM TBL_CLIENTES_TMP
				
				let vnumcte = vnumcte;
				
					--update sac_cte_remesas set fecha_vencimiento = vFhins where numcte = '041485212' and fecha_vencimiento = mdy('12','31','2021');
						
					UPDATE sac_cte_remesas SET fecha_vencimiento = vFhins WHERE numcte = vnumcte AND fecha_vencimiento = vFhbusqueda;
						
					LET vcont = vcont + 1;
						
					IF vcont = 500 THEN 
						COMMIT WORK;
						LET vcont = 0;
						BEGIN WORK;	
					END IF;
						
			END FOREACH;
		
			LET iCodRet = '00000';
			LET iMensaje = 'P EXITOSO REGMOD:'||vcontc ||'-'|| vFhbusqueda ||'-FHINS '|| vFhins;
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
				VALUES ('sac_cte_remesas_fechas',today,'1','informix',CURRENT,'1','sp_actualizacteremesafh','sp_actualizacteremesafh fh vencimiento REGMOD:'||vcontc ||'FHBUS '|| vFhbusqueda ||' - FHINS '|| vFhins );
		
			IF vcont < 500 THEN
				COMMIT WORK;		
			END IF;
			
		END IF;
		
		DROP TABLE IF EXISTS TBL_CLIENTES_TMP;

		RETURN iCodRet, iMensaje;
		
	END;
END PROCEDURE;