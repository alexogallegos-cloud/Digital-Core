CREATE PROCEDURE "informix".sp_generarchivoportab_cancelaciones(pfecha_reg date,pnombrearchivo CHAR(30))
RETURNING 	CHAR(5),   --COT_RET
			INTEGER,   --TOTAL SOLICITUDES
			CHAR(80);  -- RUTA ARCHIVO


DEFINE sql_err		INTEGER;
DEFINE vcodret1     CHAR(5);
DEFINE vcodret2     CHAR(5);

DEFINE vtotalSol	INTEGER;
DEFINE vruta		CHAR(80);
DEFINE vsSQL 		CHAR(1700);
DEFINE vsSQL1 		CHAR(400);
DEFINE vsSQL2 		CHAR(1700);
DEFINE vsSQL3 		CHAR(350);
DEFINE vsSQL4 		CHAR(350);
DEFINE vsumario		CHAR(500);
DEFINE vfiltra		CHAR(200);
DEFINE vencabezado	CHAR(100);
DEFINE vsumFuturo	CHAR(285);
DEFINE vRegistros	INTEGER; --CHAR(7);
DEFINE vfecha_reg	CHAR(8);
DEFINE vsecuencia	INTEGER; --CHAR(7);
DEFINE vRegisTot	SMALLINT;
DEFINE v_fecha_can  CHAR(8);
DEFINE v_fecha_can_fin  DATE;
DEFINE v_fecha_fin  DATE;
DEFINE v_fecha_hoy  DATE;
DEFINE v_ult_dia_mes DATE;
DEFINE v_FechaultDiaHab DATE;

DEFINE cFolio_cancelacion CHAR(30);
DEFINE cFecha_solca_portabilidad CHAR(8);
DEFINE cCta_receptora CHAR(20);
DEFINE cTipo_cta_receptora CHAR(2);
DEFINE cBco_receptor CHAR(5);
DEFINE cCta_ordenante CHAR(20);
DEFINE cTipo_cta_ordenante CHAR(2);
DEFINE cBco_ordenante CHAR(5);
DEFINE cFolio_solicitud CHAR(30);
DEFINE cFecha_proceso CHAR(8);
DEFINE iContador INTEGER;
DEFINE iExiste INTEGER;
DEFINE iContadorBit INTEGER;

DEFINE cSecuencia CHAR(7);
DEFINE cRegistros CHAR(7);

LET vcodret1 = "00001";
LET vcodret2 = "00000";
LET sql_err  = 0;

LET vtotalSol 	= "";
LET vruta 		= "";
LET vsSQL 		= "";
LET vsSQL1 		= "";
LET vsSQL2 		= "";
LET vsSQL3 		= "";
LET vsSQL4 		= "";
LET vsumario	= "";
LET vfiltra	    = "";
LET vencabezado	= "";
LET vRegistros	= "";
LET vfecha_reg	= "";
LET vsecuencia  = "";
LET vRegisTot   = 0;
LET vsumFuturo  = LPAD('',255);

LET cFolio_cancelacion = "";
LET cFecha_solca_portabilidad = "";
LET cCta_receptora = "";
LET cTipo_cta_receptora = "";
LET cBco_receptor = "";
LET cCta_ordenante = "";
LET cTipo_cta_ordenante = "";
LET cBco_ordenante = "";
LET cFolio_solicitud = "";
LET cFecha_proceso = "";
LET iContador = 0;
LET iExiste = 0;
LET iContadorBit = 0;

LET cSecuencia = '';
LET cRegistros = '';

BEGIN
		
	    -- Control de Errores no Controlados
		ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            Let vcodret1 = sql_err;    
            RETURN vcodret1, vtotalSol, vruta;
        END IF;
		END EXCEPTION;
		
		
		--SET DEBUG FILE TO "/RESPALDOSNEW/rsv/portabilidad/TASF/bdicheq/V2/sp_generarchivoportab_cancelaciones.out";
		--SET DEBUG FILE TO "/resplogifx/conciliachq/portabilidad/22E/sp_generarchivoportab_cancelaciones.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        IF LENGTH(NVL(pfecha_reg,'')) = 0 OR LENGTH(NVL(pnombrearchivo,'')) = 0 THEN
			LET vcodret1='00001';
			RETURN vcodret1, vtotalSol, vruta;
		END IF;
		
        LET vfecha_reg = TRIM(YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0));
		
        SELECT valor
		INTO vruta 
		FROM "informix".sc_param 
		WHERE empresa = "001" 
		AND codparam = 'rta_canpor';
		
		SELECT fecha_hoy, ult_dia_mes
		INTO  v_fecha_hoy,v_ult_dia_mes
		FROM "informix".sc_fechas;
		
        SELECT count(*)
        INTO vRegistros
		FROM "informix".sc_portacec_archivotemp_cancelaciones;
		
        -- PROCESO DE GENERACION DE ARCHIVO
        LET vsecuencia= vRegistros + 2;
        LET cRegistros = LPAD(vRegistros,7,'0');
		LET cSecuencia = LPAD(vsecuencia,7,'0');
		
		LET vsSQL1 = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vruta) ||  'Solicitudes.txt';
        LET vsSQL2 = "SELECT a.encabezado FROM (SELECT FIRST 1 '0100000012240137E" || vfecha_reg || "'||LPAD('',278) AS encabezado FROM sc_portacec_archivotemp_cancelaciones) AS a UNION ALL " ||
        "SELECT '02'||LPAD(secuencia+1,7,'0')||'22'||folio_cancelacion||fecha_solca_portabilidad||nombre_cte||" ||
        "CASE WHEN rfc_cte is null or rfc_cte = '' or (length(rfc_cte) < 13) then 'ND' ||LPAD('',11) else rfc_cte end||CASE WHEN(length(cta_receptora) < 18) then '00'||TRIM(cta_receptora) else TRIM(cta_receptora) end||" ||
        "CASE WHEN (length(TRIM(tipo_cta_receptora)) < 2) then '0'||TRIM(tipo_cta_receptora) else tipo_cta_receptora end ||bco_receptor||CASE WHEN(length(cta_ordenante) < 18) then '00'||TRIM(cta_ordenante) else TRIM(cta_ordenante) end||" ||
        "CASE WHEN (length(TRIM(tipo_cta_ordenante)) < 2) then '0'||TRIM(tipo_cta_ordenante) else tipo_cta_ordenante end||bco_ordenante||fecha_nacimiento||" ||
        "CASE WHEN rfc_empresa is null or rfc_empresa = '' or (length(rfc_empresa) < 13) or valrfcemp_cecoban(rfc_empresa) = '1' then 'ND' ||LPAD('',11) else rfc_empresa end||estatus_respuesta||" ||
        "fecha_respuesta||CASE WHEN (curp_cte is null or curp_cte = '') or (length(curp_cte) < 18) then 'ND'||LPAD('',16) else curp_cte end ||folio_solicitud||" || 
        "LPAD('',13) FROM sc_portacec_archivotemp_cancelaciones";
		
		LET vsSQL3 = '" > ' || TRIM(vruta) || 'queryTem.sql';
		LET vsSQL = TRIM(vsSQL1) || ' ' || TRIM(vsSQL2) || ' ' || TRIM(vsSQL3);
		
        LET vfiltra= "sed 's/|$//g;/^$/d' " ||  TRIM(vruta) ||  "Solicitudes.txt " || " > " || TRIM(vruta) || TRIM(pnombrearchivo)||'.txt';
	    LET vsumario = "echo '09"|| cSecuencia || "22" || cRegistros || vsumFuturo || "' >> " || TRIM(vruta) ||  TRIM(pnombrearchivo)||'.txt';
		
	  	IF LENGTH(NVL(vsSQL,'')) > 0 THEN
			SYSTEM vsSQL;
			LET vsSQL4 = '';
		    LET vsSQL4 = '/ifxsif01/bin/dbaccess bdicheq ' || TRIM(vruta) || 'queryTem.sql'; 
		  --LET vsSQL4 = '/informix/bin/dbaccess bdicheq ' || TRIM(vruta) || 'queryTem.sql';
			SYSTEM vsSQL4;
			LET vcodret1='00000';
        END IF
		
        SYSTEM vfiltra;
        SYSTEM vsumario;
		
        -- PROCESO DE ACTUALIZACION DE SOLICITUDES
        IF vcodret1='00000' THEN
			
			FOREACH
				
				SELECT folio_cancelacion,fecha_solca_portabilidad,cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,folio_solicitud,vfecha_reg 
				INTO cFolio_cancelacion,cFecha_solca_portabilidad,cCta_receptora,cTipo_cta_receptora,cBco_receptor,cCta_ordenante,cTipo_cta_ordenante,cBco_ordenante,cFolio_solicitud,cFecha_proceso
				FROM "informix".sc_portacec_archivotemp_cancelaciones
				
				LET iContador = iContador + 1;

				LET iContadorBit = iContadorBit + 1;
				INSERT INTO "informix".sc_portacec_bitacora_cancelaciones(empresa,folio_cancelacion,fecha_solca_portabilidad,cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,folio_solicitud,fecha_proceso)
				VALUES ('001',cFolio_cancelacion,cFecha_solca_portabilidad,cCta_receptora,cTipo_cta_receptora,cBco_receptor,cCta_ordenante,cTipo_cta_ordenante,cBco_ordenante,cFolio_solicitud,cFecha_proceso);

			END FOREACH;

			LET vcodret1='00000';
			LET vtotalSol=vRegistros;
			LET vruta=TRIM(vruta) ||  TRIM(pnombrearchivo)||'.txt';

        END IF;
				
	    --OBTIENE EL ULTIMO DIA HABIL DEL MES PARA CECOBAN
		EXECUTE PROCEDURE bdicheq:sp_porta_cal_ult_dia_hab('001',v_ult_dia_mes)
		INTO vcodret1,v_FechaultDiaHab;  

		-- NOTIFIACION DE CANCELACION DE PORTABILIDAD 
        IF  vcodret1='00000' THEN 
            IF  v_fecha_hoy = v_FechaultDiaHab THEN 
		        EXECUTE PROCEDURE sp_porta_notifica_ca('001')
		        INTO vcodret1;
		    END IF;
		END IF; 

        -- CANCELACION DE PORTABILIDADES 
        IF vcodret1='00000' THEN 
			SELECT FIRST 1 fecha_cancela
			INTO v_fecha_can
			FROM "informix".sc_porta_cancel_auto;
			
			IF v_fecha_can  IS NOT NULL THEN 
			   LET v_fecha_can_fin = SUBSTR(v_fecha_can,5,2)||SUBSTR(v_fecha_can,7,2)||SUBSTR(v_fecha_can,0,4);
		       IF v_fecha_can_fin = v_fecha_hoy THEN 
			      --REALIZA LA CANCELACION DE LAS PORTABILIDADES
				  EXECUTE PROCEDURE "informix".sp_porta_cancel_auto ('001')
		          INTO vcodret1;
				
				  IF vcodret1 <> '00000' THEN
					 RETURN vcodret1, vtotalSol, vruta;
			      END IF;
		       END IF;
			END IF;
		END IF;

        RETURN vcodret1, vtotalSol, vruta;
		
END
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 09/10/2019',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: SOLICITUDES PORTABILIDAD', 
'DESCRIPCION: Se modifica SPL para realizar los ajustes de casteo [CHAR(6)] e implementar mejoras en querys ya existentes.',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_portabregistrapagoprogramado_pb1 (pUsuario CHAR(8))
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

   
    SET DEBUG FILE TO "/tmp/sp_portabregistrapagoprogramado.out";
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

			-- ##########################################################---
			 -- Registra el movimiento de portabilidad con error.	
           
		     INSERT INTO bdicheq:sc_portamovtos_error 
            (referencia1,empresa,cliente,cuenta_cargo,banco_ref,cuenta_ref,tarjeta_ref,monto_enviar,
             monto_nomina,transaccion,fecha_envio,fecha_recibido,estatus,folio_suc,user_insert,fecha_insert,error)
            VALUES 	
            (cFolioPortabilidad,cEmpresaEmpleado,cNumCliente,cCuentaOrigen,cBancoDestino,cCuentaDestino,cTarjetaDestino,mSdoDisponible,
             mMontoTotal,cTransaccUsada,dFechaHoy,dFechaHoyMov,'01',cFolioSuc,pUsuario,dFechaHoyMov,cCodRet2);
			
			
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

CREATE PROCEDURE "informix".sp_porta_notifica_ca_pba(p_empresa char(3))
    RETURNING   CHAR(5);
    
    DEFINE v_c_vcomienza    SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE v_c_vcontador    INTEGER;
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vcodret          CHAR(5);
	DEFINE v_num_cliente    CHAR(20);
	DEFINE v_valida_noti    INT;
    DEFINE v_fecha_can      CHAR(8);
    DEFINE vSp_CodRet       CHAR(5);
    DEFINE v_fecha_noti     CHAR(8);
	  
    LET v_c_vcomienza       = -1;	
    LET ven_transacc        = 0;
    LET v_c_vcontador       = 0;
    LET vsqlerr             = 0; 
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";   
	LET vErrorInfo          = "INICIO DEL PROCESO";
    LET vcodret             = "00000";
	LET v_num_cliente       = '';
	LET v_valida_noti       = 0;
	LET vSp_CodRet          = '00000';
	
	
    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/notifica_ca.err";
	 	    TRACE ON;
			LET vcodret     = vsqlerr;
            LET vErrorInfo  = cErrorInfo;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
		
    ---SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/portabilidad/notifica_ca.txt';
	---TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;    
		   

	FOREACH WITH HOLD
	        SELECT num_cliente  , fecha_cancela
			INTO   v_num_cliente, v_fecha_can 
			FROM   bdicheq:sc_porta_cancel_auto
			
            -- ABRE LA TRANSACCION 
	        IF  (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;
		  	
            LET  v_fecha_noti = SUBSTR(v_fecha_can,7,2)||SUBSTR(v_fecha_can,5,2)||SUBSTR(v_fecha_can,0,4);
				
		    SELECT COUNT(*)
            INTO   v_valida_noti
			FROM   bdinteg:si_correos           
            WHERE  tipo_correo = 1 
            AND    status_correo = 'A'
            AND    numcte = v_num_cliente;
		  	
            -- NOTIFICACION POR CORREO 			
			IF  v_valida_noti > 0 THEN 
			    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
                '1',
                'PORTACEC',
                'CAN_AUT_EM',
                v_num_cliente,
                '',
                '',
                '2',
                v_fecha_noti,
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                1,
                0,
                0,
                0,
                0,
                '',
                '')
			    INTO vSp_CodRet; 
				
			ELSE  
			    -- NOTIFICACION POR SMS
			    SELECT COUNT(*)
				INTO   v_valida_noti
				FROM   bdinteg:si_telefonos_actual 
                WHERE  numcte = v_num_cliente
				AND    tipo_tel = '2'
				AND    cofetel = 'V';
			    
				IF v_valida_noti > 0 THEN 
				   EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
                   ('2',
                   'PORTACECSM',
                   'CAN_AUT_SM',
                   v_num_cliente,
                   '',
                   '',
                   '2',
                   v_fecha_noti,
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   1,
                   0,
                   0,
                   0,
                   0,
                   '',
                   '')
				   INTO vSp_CodRet;
			    END IF; 
			END IF; 
			
			LET  v_c_vcontador = v_c_vcontador + 1;
			IF  (v_c_vcontador >= 1000) THEN
                LET v_c_vcontador = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
    END FOREACH;
   
	--SI LA TRANSACCION ESTA ABIERTA REALIZA EL COMMIT
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	 
    RETURN  vcodret;
END; 
END PROCEDURE;