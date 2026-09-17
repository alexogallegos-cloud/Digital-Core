CREATE PROCEDURE "informix".sp_guardadatosempcoppelbancoppel(pEmpleado CHAR(8), pCentro CHAR(10), pPuesto INTEGER, pSucursal CHAR(4), pApePat CHAR(26), pApeMat CHAR(26), pNom CHAR(26), pContrasena CHAR(40), pEstado integer)

	RETURNING
	CHAR(5);  -- Codigo de retorno

	DEFINE cCodRet          CHAR(5);
	DEFINE cNombre          CHAR(45);
	DEFINE cDepto           CHAR(3);
	DEFINE cPuesto          CHAR(3);
	DEFINE cNombramiento    CHAR(20);
    DEFINE iAnio            INTEGER;
	DEFINE cMesDia          CHAR(6);
	DEFINE dFecha           DATE;
	DEFINE cSucursal        CHAR(4);
	DEFINE cBaja            CHAR(10);
	DEFINE iCuenta			INTEGER;
	DEFINE cFechaVigencia	CHAR(10);
	DEFINE dFechaHoy		DATE;
	DEFINE vSucursal800		CHAR(4);
	DEFINE vCancelado800	CHAR(1);
	DEFINE vEjecutivo		CHAR(8);
	
	--*********************************************************************************************************
	-- Creado por Jose Raul  Pacheco Ortiz                                                                  --*
	--SET DEBUG FILE TO "/respaldosbd/mc/sp_guardadatos"||trim(pEmpleado) ||".out";    
	--TRACE ON;                                                                                             --*
	--*********************************************************************************************************

	LET cSucursal  = "";
	LET cCodRet    = "00001";
	LET cDepto     = "";
	LET cPuesto    = "";
	LET cNombre    = TRIM(pNom) || " " || TRIM(pApePat) || " " || TRIM(pApeMat);
	LET iAnio      = 0;
	LET cMesDia    = "";
	LET iCuenta	   = 0;
	LET cFechaVigencia = NULL;
	LET dFechaHoy = CURRENT::DATE;
	LET vSucursal800 = "";
	LET vCancelado800 = "";
	LET vEjecutivo = "";

	--SET DEBUG FILE TO "/tmp/replicasiejecut_prueba.out"; 
	--TRACE ON;
	
	BEGIN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		LET pSucursal = SUBSTRING(LPAD(TRIM(pCentro),6,'0')FROM 1 FOR 4);		 
        IF NVL(pSucursal,0) > 999 THEN
            LET cDepto = "999";
		ELSE
		    LET cDepto = "000";
        END IF
		

        SELECT puesto_bancoppel, nombramiento INTO cPuesto, cNombramiento FROM bdinteg:'informix'.si_puestosrelacion
         WHERE empresa = '001' AND puesto_coppel = pPuesto;
		
		LET cSucursal = pSucursal;
		
		IF CAST(cSucursal AS INT) > 9000 THEN
			Let cPuesto = '001';
			Let cNombramiento = 'EMPLEADO CORPORATIVO';
		END IF
		
		/*MODIFICADO POR: PABLO H. LAVALLE CAMBRANIS
		  FECHA MODIFICACION: 05/06/2018
		  ESTA SECCION SE AGREGO*/
		Select sucursal800,cancelado INTO vsucursal800, vCancelado800 FROM bdinteg:si_cargacentros800 where sucursal800 = pSucursal and cancelado = '0';
		
		IF vsucursal800 IS NOT NULL THEN
			LET vsucursal800 = '0800';
		ELSE
			LET vsucursal800 = '';
		END IF
		/*---------AQUI TERMINA SECCION AGREGADA--------*/
		
		SELECT ejecutivo INTO vEjecutivo FROM bdinteg:si_ejecut WHERE empresa = '001' AND ejecutivo = pEmpleado;
		
        --IF NOT EXISTS(SELECT ejecutivo FROM bdinteg:'informix'.si_ejecut WHERE empresa = '001' AND ejecutivo = pEmpleado) THEN
		IF vEjecutivo IS NULL THEN
            -- ALTA DEL EMPLEADO
            SELECT YEAR(fecha_hoy)+10, SUBSTRING(TO_CHAR(fecha_hoy, "%m/%d/%Y") FROM 1 FOR 6)
              INTO iAnio, cMesDia
              FROM bdinteg:'informix'.si_fechas;
			 
			-- DSB230162JERV1675
			-- Se corrige el problema del aÃÂ±o bisiesto
			IF(cMesDia = '02/29/') THEN
				LET cMesDia = '02/28/';
			END IF

			LET dFecha = CAST((cMesDia || CAST(iAnio AS CHAR(4))) AS DATE);

            --Inserta si_Ejecuta
			IF pEstado <> 0 THEN
				/*AGREGAR CONDICION PHLC*/
				IF vsucursal800 = '0800'  THEN
					IF vCancelado800 = '0' THEN
				/*TERMINA AGREGAR PHLC*/
						LET vSucursal800 = '0800';
						INSERT INTO bdinteg:si_ejecut
						VALUES ('001', pEmpleado, cNombre,vSucursal800,cPuesto,'000','informix', NULL,cNombramiento,0,0,dFecha,NULL,'informix', 'informix', current);
					
						--Inserta MacEjecutivo
						INSERT INTO bdinteg:si_macejecutivo(empresa,mac,ejecutivo,status,user_insert, fecha_insert)
						VALUES ('001',vSucursal800,pEmpleado,'A','informix',CURRENT);
						
						LET cCodRet  = "00000";
						--RETURN cCodRet;
					ELSE
						LET cCodRet  = "00001";
						--RETURN cCodRet;
					END IF
				ELSE
					INSERT INTO bdinteg:si_ejecut
					VALUES ('001', pEmpleado, cNombre,pSucursal,cPuesto,'000','informix', NULL,cNombramiento,0,0,dFecha,NULL,'informix', 'informix', current);
				
					--Inserta MacEjecutivo
					INSERT INTO bdinteg:si_macejecutivo(empresa,mac,ejecutivo,status,user_insert, fecha_insert)
					VALUES ('001',pSucursal,pEmpleado,'A','informix',CURRENT);
					
					LET cCodRet  = "00000";
				END IF
			ELSE--Cuando es baja desde origen 
				IF vsucursal800 = '0800'  THEN
					IF vCancelado800 = '0' THEN
						LET vSucursal800 = '0800';
						INSERT INTO bdinteg:'informix'.si_ejecut
						VALUES ('001', pEmpleado, cNombre,vsucursal800,cPuesto,'000','BAJA', NULL,cNombramiento,0,0,dFecha,NULL,'informix', 'informix', current);

						LET cCodRet  = "00001";
					ELSE
						LET cCodRet = '00001';
						--RETURN vCodRet;
					END IF
				ELSE
					INSERT INTO bdinteg:'informix'.si_ejecut
					VALUES ('001', pEmpleado, cNombre,pSucursal,cPuesto,'000','BAJA', NULL,cNombramiento,0,0,dFecha,NULL,'informix', 'informix', current);

					LET cCodRet  = "00001";	
				END IF
			END IF;
			
		ELSE
			IF pEstado = 0 OR pEstado = 2 THEN
				-- BAJA DEL EMPLEADO
				--Se obtiene la fecha vigencia
				--SELECT vigencia INTO cFechaVigencia FROM bdinteg:'informix'.si_ejecut WHERE ejecutivo = pEmpleado AND password <> 'BAJA' AND sucursal  NOT IN ('1325','1326');
				SELECT vigencia INTO cFechaVigencia FROM bdinteg:'informix'.si_ejecut WHERE ejecutivo = pEmpleado AND password <> 'BAJA';
				--Se valida que la fecha vigencia no sea Null
				IF cFechaVigencia IS NOT NULL THEN
					IF vsucursal800 = '0800'  THEN
						IF vCancelado800 = '0' THEN
							LET vSucursal800 = '0800';
							
							UPDATE bdinteg:'informix'.si_ejecut SET password = 'BAJA', asistente = 'BAJA', vigencia = CURRENT, sucursal = vSucursal800 WHERE ejecutivo = pEmpleado;

							DELETE FROM bdinteg:'informix'.si_macejecutivo WHERE ejecutivo = pEmpleado;
					
							IF pEstado = 2 THEN
								LET cCodRet    = "00002";
							ELSE
								LET cCodRet    = "00001";
							END IF; 
						ELSE
							LET cCodRet = '00001';
							--RETURN vCodRet;
						END IF
					ELSE
						UPDATE bdinteg:'informix'.si_ejecut SET password = 'BAJA', asistente = 'BAJA', vigencia = CURRENT, sucursal = pSucursal WHERE ejecutivo = pEmpleado;

						DELETE FROM bdinteg:'informix'.si_macejecutivo WHERE ejecutivo = pEmpleado;
					
						IF pEstado = 2 THEN
							LET cCodRet    = "00002";
						ELSE
							LET cCodRet    = "00001";
						END IF; 
					END IF
				END IF;
			ELSE
				-- ACTUALIZACION DEL EMPLEADO
                SELECT password INTO cBaja FROM bdinteg:'informix'.si_ejecut WHERE ejecutivo = pEmpleado;

                IF cBaja = 'BAJA' THEN
                    SELECT YEAR(fecha_hoy)+10, SUBSTRING(TO_CHAR(fecha_hoy, "%m/%d/%Y") FROM 1 FOR 6) INTO iAnio, cMesDia                      FROM bdinteg:'informix'.si_fechas;

					-- DSB230162JERV1675
					-- Se corrige el problema del aÃÂ±o bisiesto
					IF(cMesDia = '02/29/') THEN
						LET cMesDia = '02/28/';
					END IF
					
                    LET dFecha = CAST((cMesDia || CAST(iAnio AS CHAR(4))) AS DATE);
					
					/*SE AGREGA CONDICION PHLC*/
					IF vsucursal800 = '0800'  THEN
						IF vCancelado800 = '0' THEN
							LET vSucursal800 = '0800';
					/*TERMINA CONDICION PHLC*/		
							UPDATE bdinteg:'informix'.si_ejecut SET puesto = cPuesto, nombramiento = cNombramiento, password='informix', asistente = 'informix', vigencia = dFecha ,sucursal = vsucursal800 WHERE ejecutivo = pEmpleado;

							-- Se inserta la Mac solo para empleados de sucursal
							--IF pSucursal <> '0000' AND pSucursal <> '0001' AND pSucursal < '2000' THEN
							INSERT INTO bdinteg:'informix'.si_macejecutivo(empresa,mac,ejecutivo,status,user_insert, fecha_insert) VALUES ('001',vsucursal800,pEmpleado,'A','informix',current);
							--END IF
							LET cCodRet = "00000";
						ELSE
							LET cCodRet = '00001';
							--RETURN vCodRet;
						END IF
					ELSE
						UPDATE bdinteg:'informix'.si_ejecut SET puesto = cPuesto, nombramiento = cNombramiento, password='informix', asistente = 'informix', vigencia = dFecha ,sucursal = pSucursal WHERE ejecutivo = pEmpleado;

						-- Se inserta la Mac solo para empleados de sucursal
						--IF pSucursal <> '0000' AND pSucursal <> '0001' AND pSucursal < '2000' THEN
						INSERT INTO bdinteg:'informix'.si_macejecutivo(empresa,mac,ejecutivo,status,user_insert, fecha_insert) VALUES ('001',pSucursal,pEmpleado,'A','informix',current);
						--END IF
						LET cCodRet = "00000";
					END IF
                ELSE
					/*SE AGREGA CONDICION PHLC*/
					IF vsucursal800 = '0800'  THEN
						IF vCancelado800 = '0' THEN
							LET vSucursal800 = '0800';
							/*TERMINA CONDICION PHLC*/
							
							UPDATE bdinteg:'informix'.si_ejecut SET sucursal = vsucursal800, puesto = cPuesto, nombramiento = cNombramiento WHERE ejecutivo = pEmpleado;
							UPDATE bdinteg:'informix'.si_macejecutivo SET mac = vsucursal800 WHERE ejecutivo = pEmpleado;
							LET cCodRet  = "00000";
						ELSE
							LET cCodRet = '00001';
							--RETURN vCodRet;
						END IF
					ELSE
						UPDATE bdinteg:'informix'.si_ejecut SET sucursal = pSucursal, puesto = cPuesto, nombramiento = cNombramiento WHERE ejecutivo = pEmpleado;
						UPDATE bdinteg:'informix'.si_macejecutivo SET mac = pSucursal WHERE ejecutivo = pEmpleado;
						LET cCodRet  = "00000";
					END IF
                END IF;
			END IF
		END IF
    END

	RETURN cCodRet;

END PROCEDURE;