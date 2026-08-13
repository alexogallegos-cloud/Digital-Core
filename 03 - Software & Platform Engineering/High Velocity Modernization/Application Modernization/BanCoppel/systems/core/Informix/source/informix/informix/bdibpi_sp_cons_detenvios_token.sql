CREATE PROCEDURE "informix".sp_cons_detenvios_token(pEmpresa char(3), pSolicitud char(10))
   returning char(5),char(16), char(20), date, char(4), money(16,2);

      --------------------------------------------------------------------------------------------
	-- Realizó: Pedro Enrique Zavala Valdez
	-- Actividad: Calcula el cargo total del token
	-- Solicitó: Mauricio León
	-- Fecha de Solicitud: 25/11/2009
	---------------------------------------------------------------------------------------------
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    DEFINE vCodRet char(5);
    DEFINE vFolioSuc char(16);
    DEFINE vCuenta char(20);
    DEFINE vCliente char(9);
    DEFINE vFecha date;
    DEFINE vFechaHoy date;
    DEFINE vSucursal char(4);
    DEFINE vCargoTot money(16,2);
    DEFINE vMonto money(16,2);
    DEFINE vFechaReg datetime year to second;
    DEFINE sql_err integer;
    DEFINE cFech_param      	date;
    DEFINE cFech_param_ini  	date;
	DEFINE cFech_param_ini_old2 date;
	DEFINE cFech_param_ini_old3 date;
	DEFINE vTipo smallint;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
    LET vCodRet = "00000";
    LET vFolioSuc = '';
    LET vCuenta  = '';
    LET vCliente  = '';
    LET vFecha  = '01/01/1900';
    LET vFechaHoy  = '01/01/1900';
    LET vSucursal = '';
    LET vCargoTot = 0;
    LET vMonto = 0;
  --LET vFechaReg  = '1900-01-01 00:00:00';
    LET vFechaReg  = current;
    LET sql_err = 0;
	LET vTipo=0;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

    BEGIN
   	ON EXCEPTION SET sql_err
      		IF sql_err <> 0 THEN
            		let vCodRet = sql_err;
            		RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
      		END IF;
    	END exception;

    --Set Debug File To '/tmp/sp_cons_detenvios_token.out';
    --Trace On;

    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 2;

    SELECT {+INDEX(bpi_tokensolicitud idx_tokensolicitud)} folio_suc, numcte, sucursal, date(f_solicitud), tipo
    INTO vFolioSuc, vCliente,vSucursal,vFecha, vTipo
    FROM bdibpi:bpi_tokensolicitud
    WHERE empresa = pEmpresa AND solicitud = pSolicitud;

    IF (vTipo=1 or vTipo=2) then
		SELECT {+INDEX(bdinteg:si_bpitoken idx_bpitoken)} LIMIT 1 f_registro
		INTO vFechaReg
		FROM bdinteg:si_bpitoken
		WHERE empresa = pEmpresa AND num_cliente = vCliente;
	ELSE
		LET vFechaReg=vFecha;
	END IF

    LET vFechaReg = EXTEND(vFechaReg, YEAR TO DAY);

    SELECT valor
    INTO cFech_param
    FROM bdicheq:sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'fechcon_movhis';
    
    SELECT valor
    INTO cFech_param_ini
    FROM bdicheq:sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'FechIniCon_movhis_ol';    
	
	SELECT valor
    INTO cFech_param_ini_old2
    FROM bdicheq:sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'FechaIniMovhisOld2'; 
	
	SELECT valor
    INTO cFech_param_ini_old3
    FROM bdicheq:sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'vfechconmovhisold3';
	  

    SELECT fecha_hoy
    INTO vFechaHoy
    FROM bdicheq:sc_fechas;

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
            LET vCargoTot = 0;
            LET vSucursal = '';
            LET vFecha = '01/01/1900';
                IF  vFechaReg = vFechaHoy THEN

                    SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
                    INTO vCuenta, vFecha, vSucursal, vMonto
                    FROM bdicheq:sc_movdia
                    WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
                    AND fech_alt = vFechaReg AND cancelad <> "S"
                    AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
                    GROUP BY cuenta, fech_alt, sucursal;


                ELIF  vFechaReg >= cFech_param_ini_old3 THEN	
                    IF  vFechaReg >= cFech_param THEN
                        SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
                        INTO vCuenta, vFecha, vSucursal, vMonto
                            FROM bdicheq:sc_movhis
                            WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
                            AND fech_alt = vFechaReg AND cancelad <> "S"
                            AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
                            GROUP BY cuenta, fech_alt, sucursal;   
                    ELIF vFechaReg >= cFech_param_ini THEN
								SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
								INTO vCuenta, vFecha, vSucursal, vMonto
                                FROM bdicheq:sc_movhis_old
                                WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
                                AND fech_alt = vFechaReg AND cancelad <> "S"
                                AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
                                GROUP BY cuenta, fech_alt, sucursal; 
					ELIF  vFechaReg >= cFech_param_ini_old2 THEN				
						 
						 -- se modifica para ver valores de variables
                            SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
                            INTO vCuenta, vFecha, vSucursal, vMonto
                                FROM bdicheq:sc_movhis_old2
                                WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
                                AND fech_alt = vFechaReg AND cancelad <> "S"
                                AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
                                GROUP BY cuenta, fech_alt, sucursal;  
					ELIF  vFechaReg >= cFech_param_ini_old3 THEN								
						    SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
                            INTO vCuenta, vFecha, vSucursal, vMonto
                                FROM bdicheq:sc_movhis_old3
                                WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
                                AND fech_alt = vFechaReg AND cancelad <> "S"
                                AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
                                GROUP BY cuenta, fech_alt, sucursal; 
                    END IF;
                END IF;

                IF NVL(vCuenta,'') = '' THEN
                    SELECT fecha_hoy
                    INTO vFechaHoy
                    FROM bdicred:sd_fechas;

                    IF vFechaHoy = vFechaReg THEN
                        SELECT num_credito, fecha_mov, sucursal, SUM(monto)
                        INTO vCuenta, vFecha, vSucursal, vMonto
                        FROM bdicred:sd_movdia
                        WHERE codigo_fun in ('039','340') AND codigo_ref in ('28','29','1')  AND folio_suc = vFolioSuc
                        AND num_credito IN ( SELECT num_credito FROM bdicred:sd_maecred WHERE numcte = vCliente )
                        GROUP BY num_credito, fecha_mov, sucursal;
                    ELSE
                        SELECT num_credito, fecha_mov, sucursal, SUM(monto)
                        INTO vCuenta, vFecha, vSucursal, vMonto
                        FROM bdicred:sd_movhis
                        WHERE codigo_fun in ('039','340') AND codigo_ref in ('28','29','1')  AND folio_suc = vFolioSuc
                        AND fecha_mov = vFechaReg
			AND num_credito IN ( SELECT num_credito FROM bdicred:sd_maecred WHERE numcte = vCliente )
                        GROUP BY num_credito, fecha_mov, sucursal;
                    END IF;
                END IF;

                LET vCargoTot = vMonto;

                IF NVL(vCuenta,'') = '' THEN
                    LET vCodRet = '002'; --No existe registro de cargo
            --- quitar
                   LET vFecha=vFechaHoy;
                    LET vCuenta=vFechaReg;
                END IF;
         END IF;
     ELSE
        LET vCodRet = '001'; --No tiene folio de sucursal asignado
     END IF;

     RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
END;
END PROCEDURE;