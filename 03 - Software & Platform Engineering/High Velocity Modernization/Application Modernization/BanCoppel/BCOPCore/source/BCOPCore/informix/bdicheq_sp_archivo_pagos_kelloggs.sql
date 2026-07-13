CREATE PROCEDURE "informix".sp_archivo_pagos_kelloggs(pEmpresa CHAR(3))
RETURNING CHAR(5);	

DEFINE cCodret            CHAR(5);
DEFINE cRutaArchivo	      CHAR(60);
DEFINE cNombreArchivo     CHAR(60);
DEFINE cDia				  CHAR(2);
DEFINE cMes				  CHAR(2);
DEFINE cAnio              CHAR(4);
DEFINE cFecha    		  CHAR(10);
DEFINE cFechaAnt		  CHAR(10);
DEFINE cFechaIni		  CHAR(60);
DEFINE cFechaFin		  CHAR(60);
DEFINE cEmpresa			  CHAR(3);
DEFINE cFolio			  CHAR(7);
DEFINE cCuenta 			  CHAR(11);
DEFINE cSucursal		  CHAR(4);
DEFINE cfechaEntrega      CHAR(19);
DEFINE cFechaApertura	  CHAR(10);
DEFINE cNombre1           CHAR(26);
DEFINE cNombre2           CHAR(26);
DEFINE cApellido1         CHAR(26);
DEFINE cApellido2         CHAR(26);
DEFINE cNombreSuc		  CHAR(40);	
DEFINE cNombreCompleto    CHAR(104);
DEFINE vsql 			  CHAR(1000);
DEFINE dFecha             DATE;
DEFINE dFechaIni          DATE;
DEFINE dFechaFin          DATE;
DEFINE dFechaAnt          DATE;
DEFINE iSql_err           INTEGER;

LET cCodret               = '00000';	
LET cRutaArchivo	      = '';
LET cNombreArchivo	      = '';
LET cDia	              = '';
LET cMes	              = '';
LET cAnio	              = '';
LET cFecha 				  = '';
LET cFechaAnt	          = '';
LET cFechaIni	          = '';
LET cFechaFin	          = '';
LET cEmpresa	          = '';
LET cFolio	              = '';
LET cCuenta 	          = '';
LET cSucursal	          = '';
LET cfechaEntrega	      = '';
LET cFechaApertura	      = '';
LET cNombre1	          = '';
LET cNombre2	          = '';
LET cApellido1	          = '';
LET cApellido2	          = '';	      
LET cNombreSuc	          = '';
LET cNombreCompleto	      = '';
LET vsql           	      = '';		      
LET iSql_err		      = 0;
LET dFecha                = DATE(1);
LET dFechaFin             = DATE(1);
LET dFechaIni             = DATE(1);
LET dFechaAnt             = DATE(1);

--SET DEBUG FILE TO '/tmp/sp_archivo_pagos_kelloggs.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		LET cCodret = CAST(iSql_err AS CHAR);    
		RETURN cCodret;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF TRIM(NVL(pEmpresa,'')) <> '' THEN
		SELECT fecha_hoy INTO cFecha FROM "informix".sc_fechas WHERE empresa = pEmpresa;

		LET cDia = LPAD(DAY(cFecha),2,'0');
		IF TRIM(NVL(cDia,'')) <> '' THEN
			IF CAST(cDia AS INTEGER) >= 16 THEN 
				LET cDia = '16';
			ELSE
				LET cDia = '01';
			END IF;
		END IF;

		IF CAST(cDia AS INTEGER) = 1 OR CAST(cDia AS INTEGER) = 16 THEN
			LET cMes = LPAD(MONTH(cFecha),2,'0');
			LET cAnio = YEAR(cFecha);
			LET cFecha = cMes|| '/' || cDia ||'/' || cAnio;

			IF CAST(cDia AS INTEGER) = 1 THEN
				IF CAST(cMes AS INTEGER) = 1 THEN
					LET cFechaAnt =  '12/16/' || CAST(CAST(cAnio AS INTEGER) -1 AS CHAR);
				ELSE
					LET cFechaAnt =  LPAD(CAST(CAST(cMes AS INTEGER) -1 AS CHAR),2,'0') || '/16'|| '/' || cAnio ;
				END IF;	
			ELSE
				LET cFechaAnt = cMes || '/01' || '/' || cAnio ;
			END IF;
			LET dFechaAnt = cFechaAnt;

			SELECT TRIM(valor) INTO cRutaArchivo FROM "informix".sc_param WHERE empresa = pEmpresa AND codparam = 'ruta_rpt_kelloggs';
			SELECT TRIM(valor) INTO cNombreArchivo FROM "informix".sc_param WHERE empresa = pEmpresa AND codparam = 'nombre_rpt_kelloggs';
			SELECT TRIM(valor) INTO cFechaIni FROM "informix".sc_param WHERE empresa = pEmpresa AND codparam = 'Fecha_InicioKelloggs';
			SELECT TRIM(valor) INTO cFechaFin FROM "informix".sc_param WHERE empresa = pEmpresa AND codparam = 'Fecha_Fin_kelloggs';

			LET cDia = LPAD(SUBSTR(cFechaIni,9,2), 2, '0');
			LET cMEs = LPAD(SUBSTR(cFechaIni,6,2), 2, '0');
			LET cAnio = SUBSTR(cFechaIni,1,4); 
			LET cFechaIni = cMes|| '/' || cDia ||'/' || cAnio;

			LET cDia = LPAD(SUBSTR(cFechaFin,9,2), 2, '0');
			LET cMEs = LPAD(SUBSTR(cFechaFin,6,2), 2, '0');
			LET cAnio = SUBSTR(cFechaFin,1,4); 
			LET cFechaFin = cMes || '/' || cDia ||'/' || cAnio;

			LET dFecha = TRIM(cFecha);
			LET dFechaIni = TRIM(cFechaIni);
			LET dFechaFin = TRIM(cFechaFin);

			IF TRIM(NVL(cRutaArchivo,'')) <> '' AND TRIM(NVL(cNombreArchivo,'')) <> '' AND TRIM(NVL(cFechaIni ,'')) <> ''AND TRIM(NVL(cFechaFin,'')) <> '' THEN
				IF dFecha >= dFechaIni AND dFecha <= dFechaFin THEN
					LET cDia = LPAD(SUBSTR(cFecha,4,2), 2, '0');
					LET cMEs = LPAD(SUBSTR(cFecha,1,2), 2, '0');
					LET cAnio = SUBSTR(cFecha,7,4); 

					LET cNombreArchivo = REPLACE(cNombreArchivo,'aaaa',cAnio);
					LET cNombreArchivo = REPLACE(cNombreArchivo,'mm',cMes);
					LET cNombreArchivo = REPLACE(cNombreArchivo,'dd',cDia);

					LET vsql   = 'rm -f ' || TRIM(cRutaArchivo) ||  TRIM(cNombreArchivo);
					SYSTEM vsql;

					FOREACH
						SELECT empresa, folio, cuenta_abono, sucursal,fecha_entrega
						INTO cEmpresa, cFolio, cCuenta, cSucursal, cfechaEntrega
						FROM bdiprem:sc_promocion_kelloggs
						WHERE empresa =  pEmpresa AND entregado = '1' 
						AND fecha_entrega >= dFechaAnt AND fecha_entrega < dFecha

						LET cfechaEntrega= SUBSTR(cfechaEntrega,1,4) || LPAD(SUBSTR(cfechaEntrega,6,2),2,'0') || LPAD(SUBSTR(cfechaEntrega,9,2),2,'0') || SUBSTR(cfechaEntrega,11,9);

						IF TRIM(NVL(cEmpresa,'')) <> '' AND TRIM(NVL(cCuenta,'')) <> '' AND  TRIM(NVL(cCuenta,'')) <> '' THEN
							SELECT fecha_alta INTO cFechaApertura FROM "informix".sc_maenoc WHERE empresa = cEmpresa AND cuenta = cCuenta;

							LET cFechaApertura = YEAR(cFechaApertura) || LPAD(MONTH(cFechaApertura),2,'0') || LPAD(DAY(cFechaApertura),2,'0');

							SELECT nombre1, nombre2, apell_paterno, apell_materno 
							INTO cNombre1, cNombre2, cApellido1, cApellido2
							FROM bdinteg:"informix".si_cliente 
							WHERE empresa = cEmpresa 
							AND numcte = (SELECT num_cte FROM "informix".sc_maechq WHERE empresa = cEmpresa AND cuenta = cCuenta);

							SELECT nombre INTO cNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = cEmpresa AND sucursal = cSucursal;

							IF TRIM(NVL(cNombre1,'')) <> '' AND TRIM(NVL(cApellido1,'')) <> '' AND TRIM(NVL(cNombreSuc,'')) <> '' THEN
								LET cNombreCompleto = TRIM(TRIM (cNombre1) ||' '|| TRIM(cNombre2)) ||' '|| TRIM(TRIM(cApellido1) || ' ' || TRIM(cApellido2));

								LET vsql = 'echo "' || '|' || TRIM(cFolio) || '|' || TRIM(cfechaEntrega) || '|' || TRIM(cCuenta) || '|' || TRIM(cNombreCompleto) || '|' || TRIM(cFechaApertura) || '|' || TRIM(cSucursal) || '|' || TRIM(cNombreSuc) || '|' || '" >> ' || TRIM(cRutaArchivo) || TRIM(cNombreArchivo);
								SYSTEM vsql;

								LET cCodret = '00000';
							ELSE
								LET cCodret = '00001';
							END IF;	
						ELSE
							LET cCodret = '00001';
						END IF;
					END FOREACH;

					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET vsql = 'echo "" >> ' || TRIM(cRutaArchivo) || TRIM(cNombreArchivo);
						SYSTEM vsql;	
					END IF;
				ELSE
					LET cCodret = '00001';
				END IF;
			ELSE
				LET cCodret = '00001';
			END IF;
		ELSE
			LET cCodret = '00001';
		END IF;
	ELSE
		LET cCodret = '00001';
	END IF;
	RETURN cCodret;	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: se creo para realizar un reporte con los folios kelloggs pemiados ya cobrados',
'AUTOR : Felipe Urias',
'FECHA : 11/07/2013',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_portabregistrapagoprogramado_pba (pUsuario CHAR(8))
RETURNING  CHAR(5);
    
    DEFINE cCodRet 							CHAR(5);
    DEFINE cCodRet2							CHAR(5);
    DEFINE iSqlErr							INTEGER;
    DEFINE cEmpresaEmpleado					CHAR(5);
    DEFINE cNumCliente						CHAR(20);
    DEFINE cCuentaOrigen					CHAR(20);
    DEFINE iSecuencia						INTEGER;
    DEFINE cBancoDestino					CHAR(3);
    DEFINE cCuentaDestino					CHAR(20);
    DEFINE cTarjetaDestino					CHAR(20);
    DEFINE cFechaDeposito					CHAR(60);
    DEFINE cEstatus							CHAR(2);
    DEFINE mMontoTotal						MONEY (16,2);
    DEFINE cFolioSuc						CHAR(16);
    DEFINE mSdoDisponible					MONEY (16,2);
    DEFINE dFechaHoy						DATE;
    DEFINE dFechaHoyMov						DATE;
    DEFINE dFechaHoyAnt						DATE;
    DEFINE cConsecutivoCentral				CHAR(8);
    DEFINE cFolioPortabilidad				CHAR(18);
    DEFINE cTransaccUsada					CHAR(4);
    DEFINE cMensaje							CHAR(100);
    DEFINE iCantidadFallos					INTEGER;
    DEFINE iCantidadTomados					INTEGER;
    DEFINE cHoraCierreSPEI					DATETIME HOUR TO SECOND;
    DEFINE cHoraActualServidor				DATETIME HOUR TO SECOND;
    DEFINE cMensajeProcesos					CHAR(250);
    DEFINE cIDClabeOTarjeta					CHAR(2);
    DEFINE cTelefonoCelCte					CHAR(13);
    
    LET cCodRet 			= '00000';
    LET cCodRet2 			= '00000';
    LET iSqlErr				= 0;
    LET cEmpresaEmpleado	= '';
    LET cNumCliente			= '';
    LET cCuentaOrigen		= '';
    LET iSecuencia			= 0;
    LET cBancoDestino		= '';
    LET cIDClabeOTarjeta	= '';
    LET cCuentaDestino		= '';
    LET cTarjetaDestino		= '';
    LET cFechaDeposito		= '';
    LET cEstatus			= '';
    LET mMontoTotal			= 0.00;
    LET cFolioSuc			= '';
    LET mSdoDisponible		= 0.00;
    LET dFechaHoy			= '';
    LET dFechaHoyMov		= '';
    LET dFechaHoyAnt		= '';
    LET cConsecutivoCentral	= '';
    LET cFolioPortabilidad	= '';
    LET cTransaccUsada		= '';
    LET cMensaje			= '';
    LET iCantidadFallos		= 0;
    LET iCantidadTomados	= 0;
    LET cHoraCierreSPEI		= '';
    LET cHoraActualServidor	= '';
    LET cMensajeProcesos	= '';
    LET cTelefonoCelCte		= '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;
            LET cMensaje = 'OCURRIO UN ERROR INESPERADO';
            IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                LET cConsecutivoCentral = '0';
            END IF;
            CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
            RETURNING cCodRet2,cMensajeProcesos;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET DEBUG FILE TO "./sp_PortabRegistraPagoProgramado.trc";
    TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- Obtiene la fecha del sistema de cheques.
    SELECT fecha_hoy 
      INTO dFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';

    LET dFechaHoyMov = dFechaHoy;

    -- Valida que exista el usuario.
    IF NOT EXISTS (SELECT 1 FROM bdinteg:si_ejecut WHERE ejecutivo = pUsuario)  THEN
        LET cCodRet = '00001';
        LET cMensaje = 'EL USUARIO NO SE ENCUENTRA REGISTRADO';
        IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
            LET cConsecutivoCentral = '0';
        END IF;
        CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
        RETURNING cCodRet2,cMensajeProcesos;
        RETURN cCodRet;
    END IF;

    -- Valida si la fecha hoy es hábil
    CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,0,'S') 
    RETURNING cCodRet2,dFechaHoyAnt;

    IF cCodRet2 <> 0 THEN
        -- Si no es hábil asigna la siguiente fecha hábil.
        CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,1,'S') 
        RETURNING cCodRet2,dFechaHoyAnt;

        IF cCodRet2 = 0 THEN
            LET dFechaHoy = dFechaHoyAnt;
        ELSE
            LET cCodRet = '00002';
            LET cMensaje = 'SE TUVO PROBLEMAS AL INTENTAR OBTENER LA FECHA PROXIMA';
            IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                LET cConsecutivoCentral = '0';
            END IF;
            CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
            RETURNING cCodRet2,cMensajeProcesos;
            RETURN cCodRet;
        END IF;
    END IF;

    --Consulta la hora de cierre para SPEI.
    SELECT TRIM(valor) 
      INTO cHoraCierreSPEI
      FROM bdicheq:sc_param
     WHERE codparam = 'PORTAHORACIERRE';

    LET cHoraActualServidor = CURRENT HOUR TO SECOND;

    -- Si la hora es mayor a la parametrizada, se programa el pago al siguiente día hábil de lunes a viernes.
    IF cHoraActualServidor >= cHoraCierreSPEI THEN
        -- Si no es hábil asigna la siguiente fecha hábil.
        CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,1,'S') 
        RETURNING cCodRet2,dFechaHoyAnt;

        IF cCodRet2 = 0 THEN
            LET dFechaHoy = dFechaHoyAnt;
        ELSE
            LET cCodRet = '00002';
            LET cMensaje = 'SE TUVO PROBLEMAS AL INTENTAR OBTENER LA FECHA PROXIMA';
            IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                LET cConsecutivoCentral = '0';
            END IF;
            CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
            RETURNING cCodRet2,cMensajeProcesos;
            RETURN cCodRet;
        END IF;
    END IF;

    -- Consulta si el proceso ya se ejecutó ya que este es diario y si no existe ejecución registrada se inicializará.
    IF EXISTS (SELECT 1 FROM bdicheq:sc_portabitacora WHERE proceso = 'sp_PortabRegistraPagoProgramado' AND  fecha_ejec = dFechaHoyMov ) THEN
        -- Asigna una referencia o clave.
        SELECT (TRIM(valor) + 1)::INTEGER
          INTO cConsecutivoCentral
          FROM bdicheq:sc_param
         WHERE codparam = 'PORTACONSEC';
         
        LET cConsecutivoCentral = LPAD(NVL(TRIM(cConsecutivoCentral),'0'),8,'0');
    ELSE
        -- Asigna una referencia o clave.
        LET cConsecutivoCentral = '00000001';	
        
        UPDATE bdicheq:sc_param 
           SET valor = cConsecutivoCentral
         WHERE codparam = 'PORTACONSEC';
    END IF;

    FOREACH WITH HOLD
        -- Consulta que existan cuentas con su portabilidad activa y Consulta el movimiento diario.
        SELECT PN.empresa, PN.cliente, PN.cuenta_abono, PN.secuencia, PN.banco_ref, PN.cuenta_ref, 
               PN.tarjeta_ref, PN.fecha_deposito, PN.estatus,MV.monto_tot, MV.folio_suc, MV.transacc
          INTO cEmpresaEmpleado, cNumCliente, cCuentaOrigen, iSecuencia, cBancoDestino, cCuentaDestino, 
               cTarjetaDestino, cFechaDeposito, cEstatus,mMontoTotal, cFolioSuc, cTransaccUsada
          FROM bdicheq:sc_portabilidadnomina AS PN
         INNER JOIN bdicheq:sc_portaestatus AS PE ON (PN.estatus = PE.estatus)
         INNER JOIN bdicheq:sc_movdia AS MV ON (PN.cuenta_abono = MV.cuenta) AND (fech_alt = dFechaHoyMov)
         INNER JOIN bdicheq:sc_portatransacc AS PT ON (MV.transacc = PT.transacc)
         WHERE PN.estatus =  '01'

        LET iCantidadTomados = iCantidadTomados + 1;

        -- Si no se obtuvo el movimiento.
        IF  mMontoTotal IS NULL OR  cFolioSuc IS NULL OR cFolioSuc = '' OR cTransaccUsada IS NULL OR cTransaccUsada = '' THEN
            LET cMensaje = 'NO SE OBTUVO INFORMACIÓN DE LOS MOVIMIENTOS DIARIOS';
            LET iCantidadFallos = iCantidadFallos + 1;
            CONTINUE FOREACH;
        END IF;

        -- Consulta el saldo de la cuenta origen.
        SELECT sdo_actual-(sdo_cong + sdo_retenido)
          INTO mSdoDisponible
          FROM bdicheq:sc_maechq 
         WHERE empresa = '001'
           AND cuenta = cCuentaOrigen;

        IF mMontoTotal < mSdoDisponible THEN
            LET mSdoDisponible = mMontoTotal;
        END IF;

        -- Obtiene la fecha del sistema de cheques.
        SELECT fecha_hoy 
          INTO dFechaHoy
          FROM bdicheq:sc_fechas
         WHERE empresa = '001';

        LET cHoraActualServidor = CURRENT HOUR TO SECOND;

        -- Si la hora es mayor a la parametrizada, se programa el pago al siguiente día hábil de lunes a viernes.
        IF cHoraActualServidor >= cHoraCierreSPEI THEN
            -- Si no es hábil asigna la siguiente fecha hábil.
            CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,1,'S') 
            RETURNING cCodRet2,dFechaHoyAnt;

            IF cCodRet2 = 0 THEN
                LET dFechaHoy = dFechaHoyAnt;
            ELSE
                LET cCodRet = '00002';
                LET cMensaje = 'SE TUVO PROBLEMAS AL INTENTAR OBTENER LA FECHA PROXIMA';
                IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                    LET cConsecutivoCentral = '0';
                END IF;
                CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
                RETURNING cCodRet2,cMensajeProcesos;
                RETURN cCodRet;
            END IF;
        END IF;

        -- Asignación de referencia o fólio.
        LET cFolioPortabilidad = 'PN' || LPAD(YEAR(dFechaHoy),4,'0')||LPAD(MONTH(dFechaHoy),2,'0')|| LPAD(DAY(dFechaHoy),2,'0')||cConsecutivoCentral;

        IF cCuentaDestino <> '' AND LENGTH(cCuentaDestino) = 18 AND  SUBSTR(cCuentaDestino,1,3) = cBancoDestino THEN
            LET cIDClabeOTarjeta = '02';
        ELIF cTarjetaDestino <> '' THEN
            LET cIDClabeOTarjeta = '03';
            LET cCuentaDestino = cTarjetaDestino;
        END IF;

        -- Obtiene el teléfono celular del cliente.
        SELECT telefono 
          INTO cTelefonoCelCte 
          FROM bdinteg:si_telefonos_actual
         WHERE numcte = cNumCliente 
           AND tipo_tel = '2';

        -- Valida si el teléfono se obtuvo si no se obtiene se envía un 0
        IF cTelefonoCelCte IS NULL OR cTelefonoCelCte = '' THEN
            LET cTelefonoCelCte = '0';
        END IF;

        -- Consulta que el movimiento no exista.
        IF EXISTS ( SELECT 1 FROM bdicheq:sc_portamovtos WHERE cliente = cNumCliente AND cuenta_cargo = cCuentaOrigen 
                    AND banco_ref = cBancoDestino AND transaccion = cTransaccUsada AND fecha_envio = dFechaHoy AND estatus = '01' AND folio_suc = cFolioSuc ) THEN
            LET iCantidadFallos = iCantidadFallos + 1; 
            CONTINUE FOREACH;   
        END IF;

        -- Reliza la programación de los pagos.
        CALL bdiprog:sp_altaprogramacion(cNumCliente, cFolioPortabilidad, '07', '01', cCuentaOrigen, cIDClabeOTarjeta, cCuentaDestino, cBancoDestino, cFolioPortabilidad,
                                         cConsecutivoCentral::INTEGER, '0', mSdoDisponible, '', '0.00', '01', 'PORTABILIDAD DE NÓMINA', dFechaHoy, '02', 1, dFechaHoy,
                                         '04', '00', '0', '0', '0', '0', '0', '0', '0', '0', '05', '00', '', '0', cTelefonoCelCte, '00', '', '0', '', '', '0', pUsuario)
        RETURNING cCodRet2,cMensajeProcesos;

        IF cCodRet2 = 0 THEN
            -- Registra el movimiento de portabilidad.		
            INSERT INTO bdicheq:sc_portamovtos 
            (referencia1,empresa,cliente,cuenta_cargo,banco_ref,cuenta_ref,tarjeta_ref,monto_enviar,
             monto_nomina,transaccion,fecha_envio,fecha_recibido,estatus,folio_suc,user_insert,fecha_insert)
            VALUES 	
            (cFolioPortabilidad,cEmpresaEmpleado,cNumCliente,cCuentaOrigen,cBancoDestino,cCuentaDestino,cTarjetaDestino,mSdoDisponible,
             mMontoTotal,cTransaccUsada,dFechaHoy,dFechaHoyMov,'01',cFolioSuc,pUsuario,dFechaHoyMov);

            -- Actualiza el parámetro que utilizó
            UPDATE bdicheq:sc_param 
               SET valor = cConsecutivoCentral::INTEGER 
             WHERE codparam = 'PORTACONSEC';

            -- Obtiene el parámetro.
            SELECT TRIM(valor) :: INTEGER + 1
              INTO cConsecutivoCentral
              FROM bdicheq:sc_param
             WHERE codparam = 'PORTACONSEC';
             
            LET cConsecutivoCentral = LPAD(NVL(TRIM(cConsecutivoCentral),'0'),8,'0');
            LET cMensaje = 'PROCESO EXITOSO';

        -- Consulta si se obtuvo el saldo y si es menor a cero no se procesa la cuenta o si el proceso generó un error.
        ELIF cCodRet2 <> 0 OR mSdoDisponible IS NULL OR mSdoDisponible <= 0.00 THEN
            LET cMensaje = 'EN AL MENOS UNA CUENTA NO SE REALIZO SU PROGRAMACIÓN DE PAGOS';
            LET iCantidadFallos = iCantidadFallos + 1;

            -- Registra el movimiento de portabilidad.	
            INSERT INTO bdicheq:sc_portamovtos 
            (referencia1,empresa,cliente,cuenta_cargo,banco_ref,cuenta_ref,tarjeta_ref,monto_enviar,
             monto_nomina,transaccion,fecha_envio,fecha_recibido,estatus,folio_suc,user_insert,fecha_insert)
            VALUES 	
            (cFolioPortabilidad,cEmpresaEmpleado,cNumCliente,cCuentaOrigen,cBancoDestino,cCuentaDestino,cTarjetaDestino,mSdoDisponible,
             mMontoTotal,cTransaccUsada,dFechaHoy,dFechaHoyMov,'01',cFolioSuc,pUsuario,dFechaHoyMov);

            -- Actualiza el parámetro que utilizó
            UPDATE bdicheq:sc_param 
               SET valor = cConsecutivoCentral::INTEGER 
             WHERE codparam = 'PORTACONSEC';

            -- Obtiene el parámetro.
            SELECT TRIM(valor) :: INTEGER + 1
              INTO cConsecutivoCentral
              FROM bdicheq:sc_param
             WHERE codparam = 'PORTACONSEC';
             
            LET cConsecutivoCentral = LPAD(NVL(TRIM(cConsecutivoCentral),'0'),8,'0');
            
            IF mSdoDisponible IS NULL OR mSdoDisponible <= 0.00 THEN
                LET cMensaje =  'EN AL MENOS UNA CUENTA TUVO PROBLEMAS EN SU SALDO';
            END IF;
            
            CONTINUE FOREACH;
        END IF;	
    END FOREACH
    
    IF iCantidadTomados - iCantidadFallos = 0 THEN
        LET cMensaje = 'NO SE ENCONTRO INFORMACIÓN POR PROCESAR';
        LET cConsecutivoCentral = 1;
    END IF;
    
    IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
        LET cConsecutivoCentral = '1';
    END IF;
    
    CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral - 1) 
    RETURNING cCodRet2,cMensajeProcesos;		
    
    RETURN cCodRet;
    
    END
    
END PROCEDURE

Document
'DESCRIPCION: Proceso que registra la programación de los pagos con base a un movimiento diario,', 
'			  registra el pago programado y genera el movimiento de portabilidad.',
'AUTOR: Antonio Bastidas',
'FECHA: 08/06/2010',
'VERSION: 20100618.1855',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_cce_consultar_chequespresentados_pba
(
pEmpresa    CHAR(3),
pFecha      CHAR(8),
pNomArchivo CHAR(22)
)
RETURNING
	CHAR(6) 		AS cod_ret,
	CHAR(3) 		AS banco,
	CHAR(40) 		AS nom_banco,
	CHAR(40) 		AS referencia,
	INTEGER 		AS num_cheque,
	DECIMAL(14,2) 	AS monto_orig,
	CHAR(20) 		AS cuenta,
	CHAR(44) 		AS sucursal,
	CHAR(4) 		AS transacc
	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

	
	DEFINE cBanco			CHAR(3);
	DEFINE cNomBanco		CHAR(40);
	DEFINE cReferencia		CHAR(40);
	DEFINE iNumCheque		INTEGER;
	DEFINE dMontoOrig		DECIMAL(14,2);
	DEFINE cCuenta			CHAR(20);
	DEFINE cSucursal		CHAR(44);
	DEFINE cTransacc		CHAR(4);



	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo			= "";
	LET cCodRet             = "000000";
	
	LET cBanco				= "";
	LET cNomBanco			= "";
	LET cReferencia			= "";
	LET iNumCheque			= 0;
	LET dMontoOrig			= 0.0;
	LET cCuenta				= "";
	LET cSucursal			= "";
	LET cTransacc			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc WITH RESUME;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultar_chequespresentados.out';
--	TRACE ON;



	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" OR NVL(pNomArchivo,"") = "" THEN
        -- FALTAN UNO O MAS PARAMETROS
        LET cCodRet = "000001";
		RETURN cCodRet, cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc WITH RESUME;
	ELSE
        FOREACH WITH HOLD
			SELECT ba.banco, ba.descripcion, doc.referencia, doc.num_chq, doc.monto_ori, doc.cuenta, suc.sucursal || " " || suc.nombre,doc.transacc  
			INTO cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc
			FROM bdicheq:sc_docret_sbc doc, 
                 bdinteg:si_bancos ba, 
                 bdinteg:si_sucursales suc, 
                 bditef:cce_detalle cce
			WHERE doc.empresa = pEmpresa
			AND doc.banco = ba.banco  
			AND doc.sucursal = suc.sucursal  
			AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban)  
			AND doc.cancelado = "T"
			AND doc.banco = cce.bco_receptor
			AND doc.numcuenta::INT8 = cce.num_cuenta::INT8
			AND doc.num_chq = cce.num_cheque::INTEGER
            AND doc.cuenta = cce.cuenta_dep
			AND cce.fecha_transfer = pFecha  
			AND cce.cod_operacion = "40"
			AND cce.nombrearchivo= pNomArchivo
		
            RETURN cCodRet, cBanco, cNomBanco, cReferencia, iNumCheque, dMontoOrig, cCuenta, cSucursal, cTransacc WITH RESUME;
        END FOREACH 	
    
	END IF
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que consulta los cheques presentados a la cámara de compensación eletrónica',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".reverso_atm( psucursal CHAR(4),   --- Sucursal
                                         pfolio    CHAR(16) ) --- Folio Operacion
RETURNING CHAR(5); --- Codigo de Retorno

    DEFINE vcCodRet1    CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE viDescErr    CHAR(50);
    DEFINE viEnTransac  SMALLINT;
    DEFINE viReversado  SMALLINT;
    DEFINE vcCodRetRev  CHAR(5);
    
    LET vcCodRet1   = '00000';
    LET vcCodRet2   = '';
    LET vcCodRet3   = '';
    LET viSqlErr    = 0;
    LET viIsamErr   = 0;
    LET viDescErr   = 0;
    LET viEnTransac = 0;
    LET viReversado = 0;
    LET vcCodRetRev = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/reverso_atm.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, viDescErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/reverso_atm.err';
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1  = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = viDescErr;
            IF viEnTransac = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            LET vcCodRet1 = '00999';
            RETURN vcCodRet1;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET viEnTransac = 1;
    END EXCEPTION WITH resume;

    IF viEnTransac = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;    
    
    IF ( psucursal is null OR psucursal = '' OR LENGTH(psucursal) <> 4 ) OR
       ( pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16 ) THEN
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcCodRet1 = '00110';
        RETURN vcCodRet1;
    END IF;
    
    SELECT COUNT(*)
      INTO viReversado
      FROM bdicheq:"informix".sc_movdia
     WHERE cancelad = 'S'
       AND folio_suc = pfolio;
       
    IF viReversado > 0 THEN
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcCodRet1 = '00005';
        RETURN vcCodRet1;
    END IF;
    
    EXECUTE PROCEDURE bdicheq:reversion('001', psucursal, 'informix', pfolio, 'A')
    INTO vcCodRetRev;
    
    IF vcCodRetRev <> '000' THEN
        IF vcCodRetRev = '413' THEN
            LET vcCodRet1 = '00413';
        END IF;
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcCodRet1;
    END IF;
    
    IF viEnTransac = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK; 
    END IF;
    
    END;
    
    RETURN vcCodRet1;

END PROCEDURE;