CREATE PROCEDURE "informix".sp_cargarreversarcuentatoken_bpi_web(pTipo CHAR(1), pSistema CHAR(1), pEmpresa CHAR(3), pNumCte CHAR(20), pSucursal CHAR(4),
															pSecDomicilio SMALLINT, pNumEmpleado CHAR(9), pFolio_Suc CHAR (16), pCuenta CHAR(12),
															pMonto MONEY, pIp CHAR(15), pTransac CHAR(4), pTransacIva CHAR(4), pStatusToken SMALLINT)
RETURNING CHAR(5), CHAR(10);

----------------------------------------------------------------------------------------------------------------------------------------
-- Realizo: Manuel Ramos Figueroa
-- Actividad: Se clona SP sp_cargarreversarcuentatoken para hacer el cargo y generar solicitud de Reposicion de token por Vencimiento 
--				desde Portal BPI
-- Solicito: Walber Castro
-- Fecha de Solicitud: 23/12/2013
----------------------------------------------------------------------------------------------------------------------------------------
-- Realizo: 95419888 Elmer Lopez Valenzuela
-- Actividad: Se modifica para agregar un insert al final para el registro de la conciliacion
-- Solicito: Alejandro Vazquez
-- Fecha: 26/08/2015
----------------------------------------------------------------------------------------------------------------------------------------

--Declaracion de variables
DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE viEdoCte SMALLINT;
DEFINE vsSolicitud CHAR(10);
DEFINE sDivisa CHAR(2);
DEFINE sNumTarjeta CHAR(20);
DEFINE vsTipoSer CHAR(2);
DEFINE vTrans  CHAR(4);
DEFINE dFecha  DATE;
DEFINE sSaldo  MONEY(14,2);
DEFINE vTransaccion INTEGER;
DEFINE iCargo INTEGER;
DEFINE vCodRet CHAR(10);
DEFINE vParam  CHAR(2);
DEFINE vsNumSolicitud CHAR(10);
DEFINE mIva MONEY(16,2);
DEFINE cTipoPersona	CHAR(2);
DEFINE pMontoSinIva MONEY(12,2);

  --SET DEBUG FILE TO "/informix/JesusBueno/sp_cargarreversarcuentatoken_bpi.out";
  --TRACE ON;

--Asignacion de variables
LET vsCodRet = '00000';
LET viSqlErr = 0;
LET vsSolicitud = '';
LET sNumTarjeta = '';
LET vsTipoSer = '';
LET vTransaccion = 0;
LET iCargo = 0;
LET vParam = '';
LET vCodRet = '00000';
LET vsNumSolicitud = '0000000000';
LET mIva = 0;
LET cTipoPersona = '';
LET pMontoSinIva = 0.00;

--Inicio del procedimiento

BEGIN

	    ON EXCEPTION SET viSqlErr --Manejador de Errores
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        IF viSqlErr <> 0 THEN
            LET vsCodRet = viSqlErr;
            IF vTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;

            IF iCargo = 1 THEN
                IF pSistema = '1' THEN
                    EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa, pSucursal, pNumEmpleado, pFolio_Suc,'M')
                    INTO vCodRet;
                ELSE
                   EXECUTE PROCEDURE bdicred:"informix".reversion(pEmpresa, pSucursal, pNumEmpleado, pFolio_Suc,'M')
                   INTO vCodRet;
                END IF;
            END IF;			
            RETURN vsCodRet, vsNumSolicitud;			
        END IF;		
		END EXCEPTION;
	
    ON EXCEPTION IN (-535)
        LET vTransaccion = 1;
    END EXCEPTION WITH RESUME;
	
    IF vTransaccion = 1 THEN
         COMMIT WORK;
         BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
	
	LET pMontoSinIva = pMonto;

    IF NVL(pTipo, '') = '' OR  NVL(pEmpresa, '') = '' OR NVL(pNumCte, '') = ''  OR  NVL(pStatusToken, '') = '' OR NVL(pSucursal, '') = '' OR pSecDomicilio IS NULL THEN --Valida que  no sean nulo o espacio en blanco
        LET vsCodRet = '00001';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vsCodRet, vsNumSolicitud;
    END IF;

    LET vsCodRet = '00000';

    IF vsCodRet = '00000' THEN
     
        IF pTipo = '1' OR pTipo = '2' THEN        ---1er Renovacion  1 o cambio 2
		
        	IF pMonto <> 0 THEN   --valida monto por producto basico
			
				EXECUTE PROCEDURE bdibpi:"informix".sp_cons_tar_divisa(pEmpresa, pSistema, pCuenta) INTO vsCodRet, sNumTarjeta, sDivisa;
			   
				IF vsCodRet <> 0 THEN
			   
					IF vtransaccion = 1 THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						ROLLBACK WORK;
					END IF;
					RETURN '00'||vsCodRet, vsNumSolicitud;
				END IF;
         	  
				IF pSistema = '1' THEN   --4142
         	
					EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pNumEmpleado, pTransac, '0000', pFolio_Suc, pCuenta, 0, pMonto, sDivisa, 'Comision por Token', sNumTarjeta, pNumEmpleado)
					INTO vsCodRet, vTrans, dFecha, sSaldo, pMonto;
					
					IF vsCodRet <> 0 THEN
						IF vTransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
					ELSE
						LET iCargo = 1;

						SELECT {+ INDEX (si_param ix_si_param)} valor INTO mIva FROM bdinteg:"informix".si_param WHERE empresa = pEmpresa AND cod_param = '47';
         	
						LET mIva = pMonto * mIva;
         	
						EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pNumEmpleado, pTransacIva, '0000', pFolio_Suc, pCuenta, 0, mIva, sDivisa, 'Comision por Token', sNumTarjeta, pNumEmpleado)
						INTO vsCodRet, vTrans, dFecha, sSaldo, pMonto;
						
						IF vsCodRet <> 0 THEN
						
							IF vTransaccion = 1 THEN
								ROLLBACK WORK;
								BEGIN WORK;
							ELSE
								ROLLBACK WORK;
							END IF;
							
							EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa, pSucursal, pNumEmpleado, pFolio_Suc,'M') INTO vCodRet;
						END IF;						
					END IF;
         	
				ELIF pSistema = '6' THEN  --4141
				
					EXECUTE PROCEDURE bdicred:"informix".cargoref_tc_ofi(pEmpresa, pSucursal, pNumEmpleado, sNumTarjeta, pMonto, pFolio_Suc, pTransac)
					INTO vsCodRet, sSaldo, sSaldo, mIva, mIva;
					
					IF vsCodRet <> 0 THEN
						IF vTransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
					ELSE
						LET iCargo = 1;
					END IF;
					
				END IF;
				
			ELSE   --monto <> 0 no aplica cargo
        	   LET pFolio_suc = "SINCOMIS" || TRIM(SUBSTRING(pFolio_suc FROM 9 FOR 16));
        	END IF; 

			IF CAST(vsCodRet AS INTEGER) = 0 THEN

				INSERT INTO bdibpi:"informix".bpi_tokensolicitud (solicitud, numcte, id_status, sucursal, f_solicitud, sec_domicilio, f_atencion, usr_solicita, empresa, tipo, folio_suc)
					 VALUES ((SELECT LPAD(CAST(NVL(MAX(Trim(solicitud) + 1),0000000001)  AS INTEGER), 10, '0') FROM bdibpi:"informix".bpi_tokensolicitud), pNumCte, pStatusToken, pSucursal, CURRENT, pSecDomicilio, CURRENT, pNumEmpleado, pEmpresa, '6',pFolio_suc);

				LET vsNumSolicitud = (SELECT {+ INDEX (bpi_tokensolicitud idx_statustoken)} LPAD(CAST(MAX(Trim(solicitud)) AS INTEGER), 10, '0') FROM bdibpi:"informix".bpi_tokensolicitud  WHERE numcte = pNumCte);

				UPDATE bdibpi:"informix".tkn_tokenexpira 
				SET id_status_solicitud = 'T' 
				WHERE numcte = pNumCte;

				IF vtransaccion = 1 THEN
					COMMIT WORK;
					BEGIN WORK;
				ELSE
					COMMIT WORK;
				END IF;
				
			END IF;
			
			IF CAST(vsCodRet AS INTEGER) = 0 THEN
				-- Obtiene datos faltantes para el registro de conciliacion	
				IF SUBSTR(pFolio_Suc,1,8) == 'SINCOMIS' THEN
					LET pMontoSinIva = 0.00;
				END IF;
				
				SELECT {+ INDEX (si_cliente 224_479)} tpo_persona INTO cTipoPersona FROM bdinteg: "informix".si_cliente WHERE numcte = pNumCte;
				
				-- Inserta el registro de conciliacion
				INSERT INTO bdibpi: "informix".tkn_solcobranza 
				( solicitud, Numcte, id_status, f_solicitud, folio_suc, f_cobro, cuenta, monto_tot, T_Persona )
				VALUES (vsNumSolicitud, pNumCte, pStatusToken, CURRENT, pFolio_Suc,CURRENT,pCuenta,pMontoSinIva,cTipoPersona);	

			END IF;
		ELSE
			LET vsCodRet = '00002';
        END IF;
	END IF;
	
	RETURN '00'||vsCodRet, vsNumSolicitud;
END
END PROCEDURE;