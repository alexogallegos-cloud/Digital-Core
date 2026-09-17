CREATE PROCEDURE "informix".sp_grabacompromisosacuerdos_pba(pEmpresa char(3), pSucursal char(4), pOrigen smallint,
pEmpleadoCaptura integer, pNumCliente char(20), pNumCuenta char(20),pPlazo char(2), pImporte integer, pTipo char(1),
pEmpleadoSup integer, pNombreSup char(40), pFechaCompac date)

RETURNING CHAR(6);


    DEFINE cVarDataErr      VARCHAR(64);
    DEFINE iSqlErr                INTEGER;
    DEFINE iSamErr             INTEGER;

    DEFINE vCodRet            CHAR(6);
    DEFINE vNumcliente     CHAR(20);
    DEFINE vNumCuenta    CHAR(20);
    DEFINE vActivo                CHAR(1);
    DEFINE vTipoCompac   CHAR(1);
    DEFINE dtefecha             DATE;
    DEFINE chrplazo	    	CHAR(2);
    DEFINE intactivo		  SMALLINT;
    DEFINE intdiasplazo	      SMALLINT;
    DEFINE intdiasfecha	      SMALLINT;    
    define v_codret char(5);

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET vCodRet=iSqlErr;
            Rollback;
            RETURN vCodRet;
        END IF;
    END EXCEPTION;


    --SET DEBUG FILE TO "/tmp/grabacompromisosacuerdos.out";
    --TRACE ON;

    --INICIALIZACION DE VARIABLES--
    LET vCodRet        	     = "000";
    LET dtefecha       	      = '01-01-1900';
    LET chrplazo	      = '';
    LET intactivo	        = 0;
    LET intdiasplazo	   = 0;
    LET intdiasfecha	   = 0;
    LET v_codret = '000';

BEGIN WORK;

IF pEmpresa IS NOT NULL AND pSucursal IS NOT NULL AND pOrigen <> 0 AND pEmpleadoCaptura <> 0
    AND pNumCliente IS NOT NULL AND pNumCuenta IS NOT NULL AND pPlazo IS NOT NULL AND pImporte <> 0
    AND pTipo IS NOT NULL AND pEmpleadoSup <> 0 AND pNombreSup IS NOT NULL AND pFechaCompac IS NOT NULL THEN

      --while (length(pPlazo) < 2)
      --    LET pPlazo= "0" || pPlazo;
      --end while;
      if (substr(pPlazo,1,1) = '0') then
          let pPlazo = substr(pPlazo,2,1);
      end if;

      if pOrigen = '1' then
        let pImporte = pImporte / 100;
      end if;

       IF NOT EXISTS(select {+INDEX(bdicobranza:cb_compac idx_compac2)} numcliente 
            from bdicobranza:cb_compac 
            where empresa = pEmpresa and numcliente = pNumCliente and numcuenta = pNumCuenta) then

            insert into bdicobranza:cb_compac (empresa, sucursal, origen, empleado_captura, numcliente, numcuenta, plazo, importe, tipo_compac,
            activo, flag_pago, efectuo_compac, nombre_efectuo, fecha_compac, fecha_insert, hora_insert)
            values (pEmpresa, pSucursal, pOrigen, pEmpleadoCaptura, pNumCliente, pNumCuenta, pPlazo, pImporte, pTipo, '1', '0', pEmpleadoSup, pNombreSup, pFechaCompac, current, current);

            
            LET vCodRet        = "000";   --Insercion Correcta

       ELSE

            Select {+INDEX(bdicobranza:cb_compac idx_compac2)} numcliente, numcuenta, activo, tipo_compac, fecha_compac, plazo
            into vNumcliente, vNumCuenta, vActivo, vTipoCompac, dtefecha, chrplazo
            From bdicobranza:cb_compac
            where empresa = pEmpresa and numcliente = pNumCliente and numcuenta = pNumCuenta;

            IF vTipoCompac = '1' and pTipo = '2'  THEN

                    Update bdicobranza:cb_compac
                    set empresa = pEmpresa, sucursal = pSucursal, origen = pOrigen, empleado_captura = pEmpleadoCaptura, plazo = pPlazo,
                    importe=pImporte, tipo_compac = '2', activo = '1', flag_pago = '0', efectuo_compac = pEmpleadoSup, nombre_efectuo = pNombreSup,
                    fecha_compac = pFechaCompac
                    where empresa = pEmpresa and numcliente = pNumCliente and numcuenta = pNumCuenta;

                    
                    LET vCodRet        = "001";   --Acuerdo Actualizado por un Compromiso

            ELSE
					LET intactivo = 0;
					LET intdiasplazo = NVL(chrplazo,0) * 7;
                    LET intdiasfecha = CURRENT::DATE - dtefecha;
                    IF intdiasfecha <= intdiasplazo THEN
                        LET intactivo = 1;
                    END IF;

                    IF pTipo = '1' and vTipoCompac = '1' then

                         IF intactivo = 0 then                             
							           Update bdicobranza:cb_compac
                    	    set empresa = pEmpresa, sucursal = pSucursal, origen = pOrigen, empleado_captura = pEmpleadoCaptura, plazo = pPlazo,
                            importe=pImporte, tipo_compac = '1', activo = '1', flag_pago = '0', efectuo_compac = pEmpleadoSup, nombre_efectuo = pNombreSup,
                            fecha_compac = pFechaCompac
                    	    where empresa = pEmpresa and numcliente = pNumCliente and numcuenta = pNumCuenta;

							
                            LET vCodRet        = "001";   --Acuerdo Actualizado por un Compromiso

                         ELSE
                             LET vCodRet        = "002";   --Compromiso o Acuerdo de Pago Activo
                         END IF;

					ELSE
						IF pTipo = '2' and vTipoCompac = '2' AND intactivo = 0 then
						    Update bdicobranza:cb_compac
                    	    set empresa = pEmpresa, sucursal = pSucursal, origen = pOrigen, empleado_captura = pEmpleadoCaptura, plazo = pPlazo,
                            importe=pImporte, tipo_compac = '2', activo = '1', flag_pago = '0', efectuo_compac = pEmpleadoSup, nombre_efectuo = pNombreSup,
                            fecha_compac = pFechaCompac
                    	    where empresa = pEmpresa and numcliente = pNumCliente and numcuenta = pNumCuenta;							
						else
						    LET vCodRet        = "002";   --Compromiso o Acuerdo de Pago Activo
						end if;
                    END IF;

            END IF;

       END IF;
ELSE
    LET vCodRet        = "003";   --Falta algun parametro
END IF;

COMMIT WORK;
  if v_codret = '000' then  
    execute procedure bdicred:sp_graba_indicador(pempresa, pNumCuenta,pImporte,'' , current, 5) into v_codret;
  end if;
    RETURN vCodRet;

END;
END PROCEDURE;