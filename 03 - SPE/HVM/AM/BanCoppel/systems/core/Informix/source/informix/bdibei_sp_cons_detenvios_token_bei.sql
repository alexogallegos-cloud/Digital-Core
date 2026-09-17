CREATE PROCEDURE "informix".sp_cons_detenvios_token_bei(pEmpresa char(3), pSolicitud char(10))   
RETURNING char(5),char(16), char(20), date, char(4), money(16,2);

    --*************************************************************
	--Objetivo: Calcula el cargo total del token.
	--Solicitó: José de Jesús Nevarez.
	--Elaboró Jose Ruben Lopez.
	--Fecha: 2013-08-14.
	--BD:bdibei.
	--*************************************************************
	--Se modifica para obtener la fecha correcta del cobro de la tabla bei_solicitudtoken, se actualizan los productos
	--de empresas y se omiten las tablas de credito
	--Elaboro: Gabriela Aguilar
	--Fecha: 31-08-2015
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
    LET vFechaReg  = current;
    LET sql_err = 0;

	--SET DEBUG FILE TO '/tmp/sp_cons_detenvios_token.out';
    --TRACE ON;
	
    BEGIN
   	ON EXCEPTION SET sql_err
      		IF sql_err <> 0 THEN
            		let vCodRet = sql_err;
            		RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
      		END IF;
    	END EXCEPTION;

    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 2;

	SELECT {+INDEX("informix".idx_tokensolicitud)} folio_suc, numcte, sucursal, date(f_solicitud), date(f_solicitud)
    INTO vFolioSuc, vCliente,vSucursal,vFecha, vFechaReg
    FROM "informix".bei_solicitudtoken
    WHERE solicitud = pSolicitud;

		
    LET vFechaReg = EXTEND(vFechaReg, YEAR TO DAY);

    SELECT valor
    INTO cFech_param
    FROM bdicheq:"informix".sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'fechcon_movhis';
    
    SELECT valor
    INTO cFech_param_ini
    FROM bdicheq:"informix".sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'FechIniCon_movhis_ol';    
	
	SELECT valor
    INTO cFech_param_ini_old2
    FROM bdicheq:"informix".sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'FechaIniMovhisOld2'; 
	
	SELECT valor
    INTO cFech_param_ini_old3
    FROM bdicheq:"informix".sc_param
    WHERE empresa = pEmpresa
    AND codparam = 'vfechconmovhisold3';
	  

    SELECT fecha_hoy
    INTO vFechaHoy
    FROM bdicheq:"informix".sc_fechas;

    IF NVL(vFolioSuc,'') <> "" THEN
        IF TRIM(SUBSTRING(vFolioSuc FROM 1 FOR 8)) = "SINCOMIS" THEN
               LET vCodRet = "00000";
               ---consulta cuenta de cliente
                select first 1 cuenta 
                into vCuenta
                from bdicheq:"informix".sc_maechq
                where empresa = '001'
                and num_cte = vCliente
                and producto in ('1200','1600','2200');
                
                LET vCargoTot = 0;
            RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
        ELSE
            LET vCargoTot = 0;
            LET vSucursal = '';
            LET vFecha = '01/01/1900';
                IF  vFechaReg = vFechaHoy THEN

                    SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
                    INTO vCuenta, vFecha, vSucursal, vMonto
                    FROM bdicheq:"informix".sc_movdia
                    WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
                    AND fech_alt = vFechaReg AND cancelad <> "S"
                    AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
                    GROUP BY cuenta, fech_alt, sucursal;


                ELIF  vFechaReg >= cFech_param_ini_old3 THEN	
                    IF  vFechaReg >= cFech_param THEN
                        SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
                        INTO vCuenta, vFecha, vSucursal, vMonto
                            FROM bdicheq:"informix".sc_movhis
                            WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
                            AND fech_alt = vFechaReg AND cancelad <> "S"
                            AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
                            GROUP BY cuenta, fech_alt, sucursal;   
                    ELIF vFechaReg >= cFech_param_ini THEN
								SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
								INTO vCuenta, vFecha, vSucursal, vMonto
                                FROM bdicheq:"informix".sc_movhis_old
                                WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
                                AND fech_alt = vFechaReg AND cancelad <> "S"
                                AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
                                GROUP BY cuenta, fech_alt, sucursal; 
					ELIF  vFechaReg >= cFech_param_ini_old2 THEN				
						 
						 -- se modifica para ver valores de variables
                            SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
                            INTO vCuenta, vFecha, vSucursal, vMonto
                                FROM bdicheq:"informix".sc_movhis_old2
                                WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
                                AND fech_alt = vFechaReg AND cancelad <> "S"
                                AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
                                GROUP BY cuenta, fech_alt, sucursal;  
					ELIF  vFechaReg >= cFech_param_ini_old3 THEN								
						    SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
                            INTO vCuenta, vFecha, vSucursal, vMonto
                                FROM bdicheq:"informix".sc_movhis_old3
                                WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
                                AND fech_alt = vFechaReg AND cancelad <> "S"
                                AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
                                GROUP BY cuenta, fech_alt, sucursal; 
                    END IF;
                END IF;
          
                LET vCargoTot = vMonto;

                IF NVL(vCuenta,'') = '' THEN
                    LET vCodRet = '002'; --No existe registro de cargo
                END IF;
         END IF;
     ELSE
        LET vCodRet = '001'; --No tiene folio de sucursal asignado
     END IF;

     RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
END;
END PROCEDURE;