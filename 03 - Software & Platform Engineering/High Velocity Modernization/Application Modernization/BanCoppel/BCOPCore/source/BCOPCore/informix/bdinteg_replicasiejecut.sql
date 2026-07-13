CREATE PROCEDURE "informix".replicasiejecut(pEmpleado CHAR(8), pCentro CHAR(10), pPuesto INTEGER, pSucursal CHAR(4), pApePat CHAR(26), pApeMat CHAR(26), pNom CHAR(26), pContrasena CHAR(40), pEstado integer)

        RETURNING
        CHAR(10);  -- Codigo de retorno

        DEFINE vCodRet          CHAR(5);
        DEFINE vNombre          CHAR(45);
        DEFINE vConsAc          CHAR(40);
        DEFINE vDepto           CHAR(3);
        DEFINE vPuesto          CHAR(3);
        DEFINE vNombramiento    CHAR(20);
        DEFINE vCanAfe          INTEGER;
		DEFINE vAnio            INTEGER;
        DEFINE vMesDia          CHAR(6);
        DEFINE vFecTemp         CHAR(10);
        DEFINE vFecha           DATE;
        DEFINE vAsistente       CHAR(8);
        DEFINE vNumero          CHAR(12);
        DEFINE vSucursal        CHAR(4);
        DEFINE vEmpleado        CHAR(8);
        DEFINE vCentroGenerico  CHAR(4);
        DEFINE vBaja            CHAR(10);
        DEFINE vCuenta          INTEGER;
        DEFINE vExiste          INTEGER;
        DEFINE dFechaVigencia   CHAR(10);
        DEFINE dFechaHoy        DATE;
		DEFINE vEjecutivo		CHAR(8);
		DEFINE vSucursal_ptf	CHAR(4);
		
		
        --*********************************************************************************************************
        -- Creado por Rodolfo Uriarte                                                                           --*
        -- Modificado Fabiola Corrales Tapia 16/May/2007                                                        --*
        -- Modificado Alfredo Avena (Para que no actualice el campo Password y pass_cod) 28/Jun/2007            --*
        -- Modificado Alfredo Avena (Para que en el campo departamento inserte por default el 999) 28/Jun/2007  --*
        -- Modificado por Fabiola Corrales Tapia 05/Nov/2007 Para que no se replique a co_auxiliar los          --*
        -- empleados con puesto 307                                                                             --*
        -- Modificado por Fabiola Corrales Tapia 06/Nov/2007 Para que inserte la mac solo empleados de sucursal --*
		-- Modificado por Pablo H. Lavalle C. 29/May/2018 Para que consulte la sucursal en la tabla si_ptf      --*
        --SET DEBUG FILE TO "/respaldosbd/cris/replicasiejecut.out";                                            --*
        --TRACE ON;                                                                                             --*
        --*********************************************************************************************************

        LET vNumero    = "";
        LET vSucursal  = "";
        LET vEmpleado  = "";
        LET vCodRet    = "000";
        LET vDepto     = "";
        LET vPuesto    = "";
        LET vCanAfe    = 0;
        LET vNombre    = TRIM(pNom) || " " || TRIM(pApePat) || " " || TRIM(pApeMat);
        LET vAnio      = 0;
        LET vMesDia    = "";
        LET vFecTemp   = "";
        LET vAsistente = "";
        LET vCuenta        = 0;
        LET dFechaVigencia = NULL;
        LET dFechaHoy = CURRENT::DATE;
		LET vEjecutivo = "";
		LET vSucursal_ptf = "";
		
		--SET DEBUG FILE TO "/tmp/replicasiejecut_prueba.out"; 
		--TRACE ON;
		
        BEGIN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
        IF nvl(pSucursal,0) > 999 THEN
            LET vDepto = "999";
		ELSE
			LET vDepto = "000";
        END IF

        SELECT puesto_bancoppel, nombramiento INTO vPuesto, vNombramiento FROM bdinteg:si_puestosrelacion
        WHERE empresa = '001' AND puesto_coppel = pPuesto;

		LET vSucursal = pSucursal;

        --Validamos si el registro lo modificamos, validamos el rango de fechas de vigencias
        Select count(*) into vCuenta from si_replicasp where ejecutivo=pEmpleado and today>=fecini and today<=fecfin;
        update si_replicasp set estatus = case when today>fecfin then 'F' else 'V' End where ejecutivo=pEmpleado;

		IF CAST(vSucursal AS INT) > 9000 THEN
			Let vPuesto = '001';
            Let vNombramiento = 'EMPLEADO CORPORATIVO';
        END IF
		
		SELECT ejecutivo INTO vEjecutivo FROM bdinteg:si_ejecut WHERE empresa = '001' AND ejecutivo = pEmpleado;
		SELECT id_ptf INTO vSucursal_ptf FROM bdinteg:si_ptf WHERE id_ptf = pSucursal AND tipo = 'S' AND clave_sit <> 'B';
		
		
		--IF NOT EXISTS(SELECT ejecutivo FROM bdinteg:si_ejecut WHERE empresa = '001' AND ejecutivo = pEmpleado) THEN
		IF vEjecutivo IS NULL THEN
            -- ALTA DEL EMPLEADO
            SELECT YEAR(fecha_hoy)+10, SUBSTRING(TO_CHAR(fecha_hoy, "%m/%d/%Y") FROM 1 FOR 6) INTO vAnio, vMesDia FROM bdinteg:si_fechas;
            -- DSB230162JERV1675
            -- Se corrige el problema del aÃÃÂ±o bisiesto
            IF(vMesDia = '02/29/') THEN
                LET vMesDia = '02/28/';
            END IF

            LET vFecha = CAST((vMesDia || CAST(vAnio AS CHAR(4))) AS DATE);

            --Inserta si_Ejecut
			/*ESTO YA EXISTÃA*/
			INSERT INTO bdinteg:si_ejecut
			VALUES ('001', pEmpleado, vNombre,pSucursal,vPuesto,'000','informix', NULL,vNombramiento,0,0,vFecha,NULL,'informix', 'informix', current);
			/*---------------*/
				
			-- Se inserta la Mac solo para empleados de sucursal
			/*ESTA CONDICION SE REEMPLAZA PHLC
			IF pSucursal <> '0000' AND pSucursal <> '0001' AND pSucursal < '2000' OR pSucursal BETWEEN '6500' and '6599' OR pSucursal BETWEEN '7600' and '7999'*/
			/*---INICIA REEMPLAZO CONDICION PHLC---*/
			--IF EXISTS(SELECT id_ptf FROM bdinteg:si_ptf WHERE id_ptf = pSucursal AND tipo = 'S' AND clave_sit <> 'B') THEN
			IF vSucursal_ptf IS NOT NULL THEN
			/*---TERMINA REEMPLAZO-----*/
				--Inserta MacEjecutivo
				INSERT INTO bdinteg:si_macejecutivo(empresa,mac,ejecutivo,status,user_insert, fecha_insert)	VALUES ('001',pSucursal,pEmpleado,'A','informix',CURRENT);
			END IF
        ELSE
            -- BAJA DEL EMPLEADO
			IF pEstado = 0 THEN
                --Se obtiene la fecha vigencia
                SELECT vigencia INTO dFechaVigencia FROM bdinteg:si_ejecut WHERE ejecutivo = pEmpleado AND password <> 'BAJA';
                --Se valida que la fecha vigencia no sea Null
                IF dFechaVigencia IS NOT NULL THEN
					UPDATE bdinteg:si_ejecut SET password = 'BAJA', asistente = 'BAJA', vigencia = CURRENT WHERE ejecutivo = pEmpleado;
					DELETE FROM bdinteg:si_macejecutivo WHERE ejecutivo = pEmpleado;
                END IF;
            ELSE
                -- ACTUALIZACION DEL EMPLEADO
                SELECT password INTO vBaja FROM bdinteg:si_ejecut WHERE ejecutivo = pEmpleado;
				
                IF vBaja = 'BAJA' THEN
                    SELECT YEAR(fecha_hoy)+10, SUBSTRING(TO_CHAR(fecha_hoy, "%m/%d/%Y") FROM 1 FOR 6) INTO vAnio, vMesDia FROM bdinteg:si_fechas;
					-- DSB230162JERV1675
					-- Se corrige el problema del aÃÃÂ±o bisiesto
					IF(vMesDia = '02/29/') THEN
						LET vMesDia = '02/28/';
					END IF

					LET vFecha = CAST((vMesDia || CAST(vAnio AS CHAR(4))) AS DATE);
					
					UPDATE bdinteg:si_ejecut SET puesto = vPuesto, nombramiento = vNombramiento,password='informix', asistente = 'informix',vigencia = vFecha WHERE ejecutivo = pEmpleado;
						
					-- Se inserta la Mac solo para empleados de sucursal
					/*ESTA CONDICION SE REEMPLAZA
					IF pSucursal <> '0000' AND pSucursal <> '0001' AND pSucursal < '2000' OR pSucursal BETWEEN '6500' and '6599' OR pSucursal BETWEEN '7600' and '7999' THEN
					*/                          
					/*---INICIA REEMPLAZO PHLC---*/
					--IF EXISTS(SELECT id_ptf FROM bdinteg:si_ptf WHERE id_ptf = pSucursal AND tipo = 'S' AND clave_sit <> 'B') THEN
					IF vSucursal_ptf IS NOT NULL THEN
					/*---TERMINA REEMPLAZO PHLC---*/     
						INSERT INTO bdinteg:si_macejecutivo(empresa,mac,ejecutivo,status,user_insert, fecha_insert) VALUES ('001',pSucursal,pEmpleado,'A','informix',current);
					END IF
                ELSE
                    --/*ESTA CONDICION SE REEMPLAZA
					--IF vCuenta<=0 and CAST(vSucursal AS INT) <= 9000 THEN
					--TERMINA SECCION*/
						
					/*---INICIA REEMPLAZO CONDICION PHLC*/
					--IF vCuenta<=0 AND EXISTS(SELECT id_ptf FROM bdinteg:si_ptf WHERE id_ptf = pSucursal AND tipo = 'S' AND clave_sit <> 'B') THEN
					IF vCuenta<=0 AND vSucursal_ptf IS NOT NULL THEN
					/*---TERMINA REEMPLAZO PHLC---*/
                       	
						--Cambio de Puesto y/o sucursal
						UPDATE bdinteg:si_ejecut SET sucursal = pSucursal, puesto = vPuesto, nombramiento = vNombramiento WHERE ejecutivo = pEmpleado;
						--Se actualiza la Mac solo para empleados de sucursal
							
						/*ESTA CONDICION SE REEMPLAZA PHLC
						IF pSucursal <> '0000' AND pSucursal <> '0001' AND pSucursal < '2000' OR pSucursal BETWEEN '6500' and '6599' OR pSucursal BETWEEN '7600' and '7999' THEN 
						TERMINA SERCCION*/
							
						/*INICIA  REEMPLAZO CONDICION PHLC*/
						--IF EXISTS(SELECT id_ptf FROM bdinteg:si_ptf WHERE id_ptf = pSucursal AND tipo = 'S' AND clave_sit <> 'B') THEN
						IF vSucursal_ptf IS NOT NULL THEN
						/*TERMINA REEMPLAZO CONDICION PHLC*/
							UPDATE bdinteg:si_macejecutivo SET mac = pSucursal WHERE ejecutivo = pEmpleado;
						END IF
					END IF
				END IF
            END IF;
        END IF
		
        --REPLICACION A LA TABLA COAUXILIAR CUANDO EL EMPLEADO CAMBIA DE CENTRO DE COSTOS
		/*SE REEMPLAZA CONDICION PHLC
		IF pPuesto <> '307' AND pSucursal <> '0000' AND pSucursal <> '0001' AND pSucursal < '2000' THEN
		
							
		/*INICIA REEMPLAZO CONDICION PHLC*/
		--IF pPuesto <> '307' AND EXISTS(SELECT id_ptf FROM bdinteg:si_ptf WHERE id_ptf = pSucursal AND tipo = 'S' AND clave_sit <> 'B') THEN
		IF pPuesto <> '307' AND vSucursal_ptf IS NOT NULL THEN
		/*TERMINA REEMPLAZO CONDICION PHLC*/
			EXECUTE PROCEDURE bdicont:ReplicaCoAuxiliar(pEmpleado, pSucursal, pApePat, pApeMat, pNom) INTO vCodRet;
		END IF;

        LET vCanAfe = DBINFO("sqlca.sqlerrd2");

        IF vCanAfe = 0 THEN
			LET vCodRet = "001";
		END IF
    END
    
	RETURN vCodRet;
END PROCEDURE;