CREATE PROCEDURE "informix".sp_cons_detenvios_token2(pEmpresa char(3), pSolicitud char(10))
   returning char(5),char(16), char(20), date, char(4), money(16,2);

      --------------------------------------------------------------------------------------------
	-- Realizó: Pedro Enrique Zavala Valdez
	-- Actividad: Calcula el cargo total del token
	-- Solicitó: Mauricio León
	-- Fecha de Solicitud: 25/11/2009
	-- ------------------------------------------------------------------------------- --
	-- Modificación: 13/Sep/2012
	-- Se elimina la búsqueda del cargo del token, solo se comprueba que el folio_suc generado
	-- sea correcto según las cuentas del cliente.
	-- Realizó: Bibiana Gaxiola Verdugo.
	---------------------------------------------------------------------------------------------
	-- Fecha: 14/Ene/2013
	-- Se agrega validación para aquellos casos en que si hubo un cobro de envío aun cuando el cliente tiene cuentas básicas.
	-- Bibiana Gaxiola Verdugo.
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    DEFINE vCodRet char(5);
    DEFINE vFolioSuc char(16);
    DEFINE vCuenta char(20);
    DEFINE vCliente char(9);
    DEFINE vFecha date;
    --DEFINE vFechaHoy date;
    DEFINE vSucursal char(4);
    DEFINE vCargoTot money(16,2);
    DEFINE vValor money(16,2);
    --DEFINE vFechaReg datetime year to second;
    DEFINE sql_err integer;
  

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
    LET vCodRet = "00000";
    LET vFolioSuc = '';
    LET vCuenta  = '';
    LET vCliente  = '';
    LET vFecha  = '01/01/1900';
    --LET vFechaHoy  = '01/01/1900';
    LET vSucursal = '';
    LET vCargoTot = 0;
    LET vValor = 0;
	--LET vFechaReg  = '1900-01-01 00:00:00';
    --LET vFechaReg  = current;
    LET sql_err = 0;

    BEGIN
   	ON EXCEPTION SET sql_err
      		IF sql_err <> 0 THEN
            		let vCodRet = sql_err;
            		RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
      		END IF;
    	END exception;

    --Set Debug File To '/home/informix/bibiana/sp_cons_detenvios_token2.out';
    --Trace On;

    --SET ISOLATION DIRTY READ;
    --SET LOCK MODE TO WAIT 2;

    SELECT {+INDEX(bpi_tokensolicitud idx_tokensolicitud)} folio_suc, numcte, sucursal, date(f_solicitud)
    INTO vFolioSuc, vCliente,vSucursal,vFecha
    FROM bdibpi:bpi_tokensolicitud
    WHERE empresa = pEmpresa AND solicitud = pSolicitud;

	SELECT valor
    INTO vValor
    FROM bdibpi:bpi_param
    WHERE id_param = '01';

    IF NVL(vFolioSuc,'') <> "" THEN
        IF TRIM(SUBSTRING(vFolioSuc FROM 1 FOR 8)) = "SINCOMIS" THEN
               LET vCodRet = "00000";
               ---consulta cuenta de cliente
                select first 1 cuenta 
                into vCuenta
                from bdicheq:sc_maechq
                where empresa = '001'
                and num_cte = vCliente
                and producto in ('1400','1700','1300');
                
                IF NVL(vCuenta,'') = "" THEN  --buscar TDC Básica
                        select num_credito 
                        into vCuenta
                        from bdicred:sd_maecred
                        where empresa = '001'
                        and numcte = vCliente
                        and num_producto = '6600';
                        
                        IF NVL(vCuenta,'') = "" THEN
                          LET vCuenta = '';
                        END IF;
                END IF;
                LET vCargoTot = 0;
            RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
        ELSE
            LET vCargoTot = vValor;
           -- LET vSucursal = '';
           -- LET vFecha = '01/01/1900';
			
			---consulta cuenta de cliente
            select first 1 cuenta 
            into vCuenta
            from bdicheq:sc_maechq
            where empresa = '001'
            and num_cte = vCliente
            and producto not in ('1400','1700','1300');
			
			IF NVL(vCuenta,'') = "" THEN  --buscar TDC BanCoppel
                        select num_credito 
                        into vCuenta
                        from bdicred:sd_maecred
                        where empresa = '001'
                        and numcte = vCliente
                        and num_producto = '6001';
						
						IF NVL(vCuenta,'') = '' THEN  
						--Para aquellos casos en que si se hizo el cobro del token aun teniendo el cliente cuentas basicas, estos casos son del 2010 antes de liberarse
						-- el NO cargo de envío a clientes con cuentas básicas
							IF (SELECT YEAR(f_solicitud) FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte = vCliente AND solicitud = pSolicitud)  <= '2010' THEN
								select first 1 cuenta 
								into vCuenta
								from bdicheq:sc_maechq
								where empresa = '001'
								and num_cte = vCliente
								and producto in ('1400','1700','1300');
							
							ELSE		
								LET vCodRet = '003'; 
							END IF;
						--ELSE
							--LET vCodRet = '002'; --No existe registro de cargo
						END IF;
			END IF;	
		END IF;	
        
	ELSE
		LET vCodRet = '001'; --No tiene folio de sucursal asignado
	END IF;

     RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
END;
END PROCEDURE;