CREATE PROCEDURE "informix".sp_cnsif_consultamovtosdiarioscta3_2(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE,cSISTEMACUENTA CHAR(20),pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2), pClaveMov CHAR(50))
	returning CHAR(5)  AS Cod_Retorno,
				DATE     AS Fecha,
				DATETIME HOUR to FRACTION(3) AS Hora,
				CHAR(4)  AS CveTransaccion,
				CHAR(50) AS Desc_Transaccion,
				CHAR(16) AS Folio,
				DATE     AS Periodo_Inicial,
				MONEY(14,2) AS Monto,
				DATE     AS Periodo_Final,
				CHAR(20) AS Sistema_Cuenta,
				CHAR(1)  AS Naturaleza,
				CHAR(40) AS Referencia,
				CHAR(1)  AS Reversos,
				CHAR(4)  AS Sucursal,
				CHAR(20) AS CveProcedencia,
				CHAR(50) AS Desc_Procedencia,
				MONEY(14,2) AS Saldo,
				CHAR(20) AS Numero_Tarjeta,
				CHAR(1)  AS Reversados,
				CHAR(8)  AS Usuario,
				CHAR(23) AS Referencia23;

DEFINE iexiste                INT;
DEFINE cCodRet                CHAR(5);
DEFINE iSql_err           INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha               DATE;
DEFINE dHora                DATETIME HOUR to FRACTION(3);
DEFINE cTransaccion          CHAR(4);
DEFINE cD_Transaccion     CHAR(50);
DEFINE mMonto               MONEY(14,2);
DEFINE cNaturaleza          CHAR(1);
DEFINE mSaldo                MONEY(14,2);
DEFINE cReferencia           CHAR(40);
DEFINE cReversos          CHAR(1);
DEFINE cReversados          CHAR(1);
DEFINE cSucursal           CHAR(4);
DEFINE cFolio                CHAR(16);
DEFINE cProcedencia          CHAR(20);
DEFINE cD_Procedencia     CHAR(50);
DEFINE dPeriodoI_1          DATE;
DEFINE dPeriodoF_1          DATE;
DEFINE sNUMSERIAL       INT8;
DEFINE sNumSecuencia    INT8;
DEFINE cUsuario         CHAR(8);
DEFINE cReferencia23    CHAR(23);
--SISTEMA DE CUENTA 06 VARIABLES
DEFINE cNumtarjeta          CHAR(20);
--VARIABLES PARA FECHAS HISTORICAS
DEFINE cconsmovhis      CHAR(10);
DEFINE cconsmovhisold   CHAR(10);
DEFINE cconsmovhisold2  CHAR(10);
DEFINE cconsmovhisold3  CHAR(10);
DEFINE cconsmovhisold4  CHAR(10);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     CHAR(3);
DEFINE cCodfun          CHAR(3);
DEFINE cCodref          INTEGER;
DEFINE iExisteCta       INT;
DEFINE iKiosko			INT;
DEFINE iContReg INTEGER;
DEFINE vOrdenante       CHAR(40);
DEFINE dRef             DECIMAL(7,0);
DEFINE vConcepto        CHAR(210);
DEFINE iclienteNostro   INTEGER;
DEFINE iAbierto			INT;

--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;
LET dFecha               = "";
LET dHora                = "";
LET cTransaccion     = "";
LET cD_Transaccion     = "";
LET mMonto               = 0;
LET cNaturaleza          = "";
LET mSaldo                = 0;
LET cReferencia          = "";
LET cReversos          = "";
LET cReversados          = "";
LET cSucursal           = "";
LET cFolio                = "";
LET cProcedencia     = "";
LET cD_Procedencia     = "";
LET dPeriodoI_1          = "";
LET dPeriodoF_1          = "";
LET sNUMSERIAL      =  0;
LET sNumSecuencia     =  0;
LET cUsuario        = "";
LET cReferencia23   = "";
--SISTEMA DE CUENTA 06 VARIABLES
LET cNumtarjeta     = "";
--VARIABLES PARA FECHAS HISTORICAS
LET cconsmovhis     = '';
LET cconsmovhisold  = '';
LET cconsmovhisold2 = '';
LET cconsmovhisold3 = '';
LET cconsmovhisold4 = '';
--VARIABLES DE PAGINACION
LET iCont           = 0;
LET pEmpresa        = '001';
LET cCodfun         ='';
LET cCodref         = 0;
LET iExisteCta      = 0;
LET iKiosko         = 0;
LET iContReg        = 0;
LET vOrdenante      = '';
LET dRef            = '';
LET vConcepto       = '';
LET iclienteNostro  = 0;
LET iAbierto              =0;

BEGIN

     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
               RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
               cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF;
     END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_consultamovtosdiarioscta3_2.out";
    --TRACE ON;

     IF cID_USUARIOC = ''      OR
        cID_FUNCIONC = ''      OR
        cNUMCUENTA  = ''     OR
        dPERIODOI   IS NULL OR
        dPERIODOF      IS NULL     OR
        cSISTEMACUENTA = '' THEN
        LET cCodRet = "00036";
        RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
        cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
     END IF;

     IF cSISTEMACUENTA <> 'CAPTACION' AND cSISTEMACUENTA <> 'CREDITO'  AND cSISTEMACUENTA <> 'INVERSIONES' THEN
          LET cCodRet = "00037";
          RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
          cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
     END IF;

     --VALIDACION
	IF cSISTEMACUENTA = 'CAPTACION' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
		INTO cCodRet;
	END IF;

	IF cSISTEMACUENTA = 'CREDITO' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
		INTO cCodRet;
	END IF;

	IF cSISTEMACUENTA = 'INVERSIONES' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
		INTO cCodRet;
	END IF;

	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
			  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF;
     -- TERMINA VALIDACION
	
	--VALIDAMOS QUE SEAN CUENTA NOSTRO
	SELECT COUNT(cuenta_nostro)
	INTO iclienteNostro
	FROM bdicred:sd_ce_ctas_nostro
	WHERE cuenta_nostro = cNUMCUENTA
	AND status = 1;
		
	IF cSISTEMACUENTA = 'CAPTACION' THEN

		SELECT valor
		INTO cconsmovhis
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'fechcon_movhis';

		SELECT valor
		INTO cconsmovhisold
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechIniCon_movhis_ol';

		SELECT valor
		INTO cconsmovhisold2
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechaIniMovhisOld2';
		
		LET iAbierto = 1;
		IF dPERIODOF = TODAY THEN
			let iCont = 0;
			FOREACH WITH HOLD
				SELECT
				MO.fech_alt,MO.fech_hor,MO.transacc,MO.monto_tot,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
				INTO dFecha,dHora,cTransaccion,mMonto,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
				FROM bdicheq:"informix".sc_movdia MO
				WHERE MO.fech_alt = dPERIODOF
				  AND MO.cuenta = cNUMCUENTA

				IF (mImporte <> 0 AND mImporte <> mMonto) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (cSuc <> "" AND cSuc <> cSucursal) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (pUsuario <> "" AND pUsuario <> cUsuario) THEN
					CONTINUE FOREACH;
				END IF;

				SELECT
						TR.descripcion, TR.naturaleza
				   INTO cD_Transaccion, cNaturaleza
				   FROM bdinteg:si_transacc TR
				  WHERE TR.numero = cTransaccion
				    AND TR.sistema = '01'
					AND TR.empresa = '001';

				LET iCont=iCont+1;

				INSERT INTO "informix".si_tempomovs_2 (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza,
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23,fecha_insert,clave_mov)
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23,CURRENT,pClaveMov);

				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;

		END IF;

		IF (dPERIODOI < TODAY AND dPERIODOF >= cconsmovhis) THEN

			let iCont = 0;
			FOREACH WITH HOLD
				SELECT 
				MO.fech_alt,MO.fech_hor,MO.transacc,MO.monto_tot,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
				INTO dFecha,dHora,cTransaccion,mMonto,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
				FROM bdicheq:"informix".sc_movhis MO
				WHERE MO.empresa='001'
				  AND MO.cuenta = cNUMCUENTA
				  AND MO.fech_alt >= dPERIODOI 
				  AND MO.fech_alt <= dPERIODOF
				  AND MO.fech_alt >= cconsmovhis

				IF (mImporte <> 0 AND mImporte <> mMonto) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (cSuc <> "" AND cSuc <> cSucursal) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (pUsuario <> "" AND pUsuario <> cUsuario) THEN
					CONTINUE FOREACH;
				END IF;

				SELECT
						TR.descripcion, TR.naturaleza
				   INTO cD_Transaccion, cNaturaleza
				   FROM bdinteg:si_transacc TR
				  WHERE TR.numero = cTransaccion
				    AND TR.sistema = '01'
					AND TR.empresa = '001';

				LET iCont=iCont+1;

				INSERT INTO "informix".si_tempomovs_2 (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza,
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23,fecha_insert,clave_mov)
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23,CURRENT,pClaveMov);

				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;

		END IF;

		IF (dPERIODOI < cconsmovhis AND dPERIODOF >= cconsmovhisold) THEN
			let iCont = 0;
			
			FOREACH WITH HOLD
			SELECT
				MO.fech_alt,MO.fech_hor,MO.transacc,MO.monto_tot,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
				INTO dFecha,dHora,cTransaccion,mMonto,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
				FROM bdicheq:"informix".sc_movhis_old MO
				WHERE MO.empresa='001'
				  AND MO.cuenta = cNUMCUENTA
				  AND MO.fech_alt >= dPERIODOI 
				  AND MO.fech_alt <= dPERIODOF
				  AND MO.fech_alt >= cconsmovhisold
				  AND MO.fech_alt < cconsmovhis

				IF (mImporte <> 0 AND mImporte <> mMonto) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (cSuc <> "" AND cSuc <> cSucursal) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (pUsuario <> "" AND pUsuario <> cUsuario) THEN
					CONTINUE FOREACH;
				END IF;

				SELECT
						TR.descripcion, TR.naturaleza
				   INTO cD_Transaccion, cNaturaleza
				   FROM bdinteg:si_transacc TR
				  WHERE TR.numero = cTransaccion
				    AND TR.sistema = '01'
					AND TR.empresa = '001';

				LET iCont=iCont+1;

				INSERT INTO "informix".si_tempomovs_2 (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza,
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23,fecha_insert,clave_mov)
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23,CURRENT,pClaveMov);

				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;

			IF (dPERIODOI < cconsmovhisold AND dPERIODOF >= cconsmovhisold2) THEN
				let iCont = 0;
				
				FOREACH WITH HOLD
				SELECT MO.fech_alt,MO.fech_hor,MO.transacc,MO.monto_tot,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
				INTO dFecha,dHora,cTransaccion,mMonto,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
				FROM bdicheq:"informix".sc_movhis_old2 MO
				WHERE MO.empresa='001'
				  AND MO.cuenta = cNUMCUENTA
				  AND MO.fech_alt >= dPERIODOI 
				  AND MO.fech_alt <= dPERIODOF
				  AND MO.fech_alt >= cconsmovhisold2
				  AND MO.fech_alt < cconsmovhisold

				IF (mImporte <> 0 AND mImporte <> mMonto) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (cSuc <> "" AND cSuc <> cSucursal) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (pUsuario <> "" AND pUsuario <> cUsuario) THEN
					CONTINUE FOREACH;
				END IF;

				SELECT
						TR.descripcion, TR.naturaleza
				   INTO cD_Transaccion, cNaturaleza
				   FROM bdinteg:si_transacc TR
				  WHERE TR.numero = cTransaccion
				    AND TR.sistema = '01'
					AND TR.empresa = '001';
				
				LET iCont=iCont+1;
				
				INSERT INTO "informix".si_tempomovs_2 (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23,fecha_insert,clave_mov) 
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23,CURRENT,pClaveMov);
					
				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				END FOREACH;
			END IF;
		END IF;

		update statistics medium for table si_tempomovs_2;

		LET iCont = 0;
		
		FOREACH WITH HOLD
			SELECT 
				codret, ejecutivosif, no_cuenta, fech_alt,
				fech_hor, transacc, descripcion, monto_tot, naturaleza, sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_tarjeta, usuario,
				referencia_23
			 INTO
				cCodRet, cID_USUARIOC, cNUMCUENTA, dFecha,
				dHora, cTransaccion, cD_Transaccion, mMonto, cNaturaleza, mSaldo, cReferencia, cReversos, cSucursal, cFolio, cNumtarjeta, cUsuario,
				cReferencia23
			 FROM "informix".si_tempomovs_2
			WHERE ejecutivosif = cID_USUARIOC
			  AND no_cuenta = cNUMCUENTA
			  AND clave_mov = pClaveMov
			ORDER BY fech_alt DESC,
					 fech_hor DESC

			SELECT COUNT(*) INTO iexiste FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';

			IF NVL(iexiste,0)> 0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			ELSE
				SELECT COUNT(*) INTO iexiste FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
				
				IF NVL(iexiste,0)> 0 THEN
					SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
				ELSE
					LET cProcedencia="";
					LET cD_Procedencia="";
				END IF;
			END IF;

			LET iCont=iCont+1;
			LET iContReg = iContReg + 1;

			--Â¡Cuidado! si estÃ¡ tabla crece y no se depura, los costos de inserciÃ³n serÃ¡n muy grandes
			INSERT INTO bdicnweb:"informix".sw_cons_movimientos(id_registro,fechahora_insert,fecha,hora,cve_transacc,desc_transacc,folio,periodo_inicial,monto,periodo_final,sis_cuenta,naturaleza,referencia,reversos,sucursal,cve_proc,desc_proc,saldo,num_tarjeta,reversados,usuario,referencia23,clave_mov)
			VALUES(iContReg,CURRENT,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,cReferencia,cReversos,cSucursal,
			cProcedencia,cD_Procedencia,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23,pClaveMov);

			-- Se llena la tabla sw_cons_movimientos2 con los datos de la cuanta NOSTRO (en caso de aplicar)
			LET vOrdenante = '';
            LET dRef = "";
            LET vConcepto = '';

            IF iclienteNostro > 0 THEN
                SELECT vchrnombreord as ordenante, intrefnumerica as ref, vchrconceptopago as concepto
                INTO vOrdenante, dRef, vConcepto
                FROM bdispei:tblhistpago
                WHERE dtfechacaptura = dFecha
					AND vchrclaverastreo = cReferencia
					AND mnyimporte = mMonto;
            END IF

			--INSERTAMOS AL REPORTE
            INSERT INTO bdicnweb:"informix".sw_cons_movimientos2
            (id_registro,fecha, numcuenta, hora, cve_transaccion, desc_transaccion, folio, periodo_inicial, monto, periodo_final,
             sistema_cuenta, naturaleza, referencia, reversos, sucursal, cve_procedencia, desc_procedencia, saldo, numero_tarjeta,
			 reversados, usuario_mov, referencia23, ordenante, refe, concepto, clave_mov, usuario)
            VALUES(iContReg,dFecha,cNUMCUENTA, dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,
                   cNaturaleza,cReferencia,CReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumTarjeta,cReversados,cUsuario,
				   cReferencia23, vOrdenante, dRef, vConcepto, pClaveMov, cID_USUARIOC);

			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END FOREACH;

		IF iContReg = 0 THEN
			LET cCodRet = '00039';
		END IF;

		update statistics medium for table bdicnweb:sw_cons_movimientos;
		update statistics medium for table bdicnweb:sw_cons_movimientos2;

		IF iAbierto = 1 THEN
			LET iAbierto = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;

		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;

	ELIF cSISTEMACUENTA = 'CREDITO' THEN

		SELECT 
		  COUNT(num_credito)
		  INTO iExisteCta
		  FROM bdicred:sd_maecred
		 WHERE empresa = '001'
		   AND num_credito = cNUMCUENTA;

		IF NVL(iExisteCta,0) > 0 THEN
			let iCont = 0;
			
			FOREACH WITH HOLD
				SELECT
					MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,
					MO.transacc_suc,MO.referencia,MO.monto,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO
					cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cReferencia,mMonto,cReversos,cSucursal,
					dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movdia MO
				WHERE MO.empresa='001'
				  AND MO.num_credito = cNUMCUENTA
				  AND MO.fecha_mov >= dPERIODOI 
				  AND MO.fecha_mov <= dPERIODOF
				ORDER BY MO.secuencia DESC

				IF (mImporte <> 0 AND mImporte <> mMonto) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (cSuc <> "" AND cSuc <> cSucursal) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (pUsuario <> "" AND pUsuario <> cUsuario) THEN
					CONTINUE FOREACH;
				END IF;

				SELECT
						TR.descripcion, TR.sentido
				   INTO cD_Transaccion, cNaturaleza
				   FROM bdicred:sd_transfun TR
				  WHERE TR.codigo_fun = cCodfun
				    AND TR.codigo_ref = cCodref
					AND TR.empresa = '001';

				LET iCont=iCont+1;

				IF cCodfun ='001' AND cCodref in (1,2,3) THEN
					IF iCont>0 THEN
						 LET iCont=iCont - 1;
					END IF;
				ELIF cCodfun ='002' AND cCodref =1 THEN
					IF iCont>0 THEN
						 LET iCont=iCont - 1;
					END IF;
				ELSE

					SELECT transacc INTO cTransaccion FROM bdicred:sd_transfun WHERE codigo_fun=cCodfun AND codigo_ref=cCodref;
					SELECT descripcion,naturaleza INTO cD_Transaccion,cNaturaleza FROM bdinteg:si_transacc WHERE numero=cTransaccion AND sistema='06';
				END IF;

				INSERT INTO "informix".si_tempomovs_2 (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza,
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23,fecha_insert,clave_mov)
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23,CURRENT,pClaveMov);

				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;
			
			let iCont = 0;
			
			FOREACH WITH HOLD
				SELECT 
					MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,
					MO.transacc_suc,MO.referencia,MO.monto,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				 INTO
					cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cReferencia,mMonto,cReversos,cSucursal,
					dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				 FROM bdicred:sd_movhis  MO
				WHERE MO.empresa='001'
				  AND MO.num_credito = cNUMCUENTA
				  AND MO.fecha_mov >= dPERIODOI 
				  AND MO.fecha_mov <= dPERIODOF
				ORDER BY MO.secuencia DESC

				IF (mImporte <> 0 AND mImporte <> mMonto) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (cSuc <> "" AND cSuc <> cSucursal) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (pUsuario <> "" AND pUsuario <> cUsuario) THEN
					CONTINUE FOREACH;
				END IF;

				SELECT
						TR.descripcion, TR.sentido
				   INTO cD_Transaccion, cNaturaleza
				   FROM bdicred:sd_transfun TR
				  WHERE TR.codigo_fun = cCodfun
				    AND TR.codigo_ref = cCodref
					AND TR.empresa = '001';

				LET iCont=iCont+1;

				IF cCodfun ='001' AND cCodref in (1,2,3) THEN
					IF iCont>0 THEN
						 LET iCont=iCont - 1;
					END IF;
				ELIF cCodfun ='002' AND cCodref =1 THEN
					IF iCont>0 THEN
						 LET iCont=iCont - 1;
					END IF;
				ELSE

					SELECT transacc INTO cTransaccion FROM bdicred:sd_transfun WHERE codigo_fun=cCodfun AND codigo_ref=cCodref;
					SELECT descripcion,naturaleza INTO cD_Transaccion,cNaturaleza FROM bdinteg:si_transacc WHERE numero=cTransaccion AND sistema='06';
				END IF;

				INSERT INTO "informix".si_tempomovs_2 (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza,
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23,fecha_insert,clave_mov)
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23,CURRENT,pClaveMov);

				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;
		ELSE
			let iCont = 0;
			
			FOREACH WITH HOLD
				SELECT 
					MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,
					MO.transacc_suc,MO.referencia,
					MO.monto,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO
					cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,
					cTransaccion,cReferencia,
					mMonto,cReversos,cSucursal,dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movdiacrd  MO
			  WHERE MO.empresa='001'
			    AND MO.num_credito = cNUMCUENTA
				AND MO.fecha_mov >= dPERIODOI 
				AND MO.fecha_mov <= dPERIODOF
				ORDER BY MO.secuencia DESC

				IF (mImporte <> 0 AND mImporte <> mMonto) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (cSuc <> "" AND cSuc <> cSucursal) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (pUsuario <> "" AND pUsuario <> cUsuario) THEN
					CONTINUE FOREACH;
				END IF;

				SELECT
						TR.descripcion, TR.sentido
				   INTO cD_Transaccion, cNaturaleza
				   FROM bdicred:sd_transfun TR
				  WHERE TR.codigo_fun = cCodfun
				    AND TR.codigo_ref = cCodref
					AND TR.empresa = '001';

				LET iCont=iCont+1;

				IF cCodfun ='001' AND cCodref in (1,2,3) THEN
					IF iCont>0 THEN
						 LET iCont=iCont - 1;
					END IF;
				ELIF cCodfun ='002' AND cCodref =1 THEN
					IF iCont>0 THEN
						 LET iCont=iCont - 1;
					END IF;
				ELSE
					SELECT transacc INTO cTransaccion FROM bdicred:sd_transfun WHERE codigo_fun=cCodfun AND codigo_ref=cCodref;
					SELECT descripcion,naturaleza INTO cD_Transaccion,cNaturaleza FROM bdinteg:si_transacc WHERE numero=cTransaccion AND sistema='06';
				END IF;

				INSERT INTO "informix".si_tempomovs_2 (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza,
						sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23,fecha_insert,clave_mov)
					VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
						mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23,CURRENT,pClaveMov);

					IF iCont >= 1000 THEN
						LET iCont = 0;
						COMMIT WORK;
						BEGIN WORK;
					END IF;
			END FOREACH;
			
			let iCont = 0;
			
			FOREACH WITH HOLD
				SELECT 
					MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,
					MO.transacc_suc,MO.referencia,MO.monto,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO
					cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cReferencia,mMonto,cReversos,cSucursal,
					dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movhiscrd  MO
			   WHERE MO.empresa='001'
			     AND MO.fecha_mov >= dPERIODOI 
				 AND MO.fecha_mov <= dPERIODOF
				 AND MO.num_credito = cNUMCUENTA
			   ORDER BY MO.secuencia DESC

				IF (mImporte <> 0 AND mImporte <> mMonto) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (cSuc <> "" AND cSuc <> cSucursal) THEN
					CONTINUE FOREACH;
				END IF;
				
				IF (pUsuario <> "" AND pUsuario <> cUsuario) THEN
					CONTINUE FOREACH;
				END IF;

				SELECT
						TR.descripcion, TR.sentido
				   INTO cD_Transaccion, cNaturaleza
				   FROM bdicred:sd_transfun TR
				  WHERE TR.codigo_fun = cCodfun
				    AND TR.codigo_ref = cCodref
					AND TR.empresa = '001';

				LET iCont=iCont+1;

				IF cCodfun ='001' AND cCodref in (1,2,3) THEN
					IF iCont>0 THEN
						 LET iCont=iCont - 1;
					END IF;
				ELIF cCodfun ='002' AND cCodref =1 THEN
					IF iCont>0 THEN
						 LET iCont=iCont - 1;
					END IF;
				ELSE
					SELECT transacc INTO cTransaccion FROM bdicred:sd_transfun WHERE codigo_fun=cCodfun AND codigo_ref=cCodref;
					SELECT descripcion,naturaleza INTO cD_Transaccion,cNaturaleza FROM bdinteg:si_transacc WHERE numero=cTransaccion AND sistema='06';
				END IF;

				INSERT INTO "informix".si_tempomovs_2 (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza,
						sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23,fecha_insert,clave_mov)
					VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
						mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23,CURRENT,pClaveMov);

				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;
		END IF;

		update statistics medium for table si_tempomovs_2;
		
		LET iCont = 0;
		
		FOREACH WITH HOLD
			SELECT {+INDEX (bdinteg:si_tempomovs_2 idx_tempo_movs_2)}
				codret, ejecutivosif, no_cuenta, fech_alt,
				fech_hor, transacc, descripcion, monto_tot, naturaleza, sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_tarjeta, usuario,
				referencia_23
			INTO cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				 cNumtarjeta,cUsuario,cReferencia23
			FROM "informix".si_tempomovs_2
		   WHERE ejecutivosif = cID_USUARIOC
		     AND no_cuenta = cNUMCUENTA
			 AND clave_mov = pClaveMov
		ORDER BY fech_alt DESC,fech_hor DESC
			
			SELECT COUNT(*) INTO iexiste FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			
			IF NVL(iexiste,0)> 0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			ELSE
				SELECT COUNT(*) INTO iexiste FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
				
				IF NVL(iexiste,0)> 0 THEN
					SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
				ELSE
					LET cProcedencia="";
					LET cD_Procedencia="";
				END IF;
			END IF;

			LET iCont=iCont+1;

			LET iContReg = iContReg + 1;

			--Â¡Cuidado! si estÃ¡ tabla crece y no se depura, los costos de inserciÃ³n serÃ¡n muy grandes
			INSERT INTO bdicnweb:"informix".sw_cons_movimientos(id_registro,fechahora_insert,fecha,hora,cve_transacc,desc_transacc,folio,periodo_inicial,monto,periodo_final,sis_cuenta,naturaleza,referencia,reversos,sucursal,cve_proc,desc_proc,saldo,num_tarjeta,reversados,usuario,referencia23,clave_mov)
			VALUES(iContReg,CURRENT,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,cReferencia,cReversos,cSucursal,
			cProcedencia,cD_Procedencia,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23,pClaveMov);

			-- Se llena la tabla sw_cons_movimientos2 con los datos de la cuanta NOSTRO (en caso de aplicar)
			LET vOrdenante = '';
            LET dRef = "";
            LET vConcepto = '';

            IF iclienteNostro > 0 THEN
                SELECT vchrnombreord as ordenante, intrefnumerica as ref, vchrconceptopago as concepto
                INTO vOrdenante, dRef, vConcepto
                FROM bdispei:tblhistpago
                WHERE dtfechacaptura = dFecha
					AND vchrclaverastreo = cReferencia
					AND mnyimporte = mMonto;
            END IF

			--INSERTAMOS AL REPORTE
            INSERT INTO bdicnweb:"informix".sw_cons_movimientos2
            (id_registro,fecha, numcuenta, hora, cve_transaccion, desc_transaccion, folio, periodo_inicial, monto, periodo_final,
             sistema_cuenta, naturaleza, referencia, reversos, sucursal, cve_procedencia, desc_procedencia, saldo, numero_tarjeta,
			 reversados, usuario_mov, referencia23, ordenante, refe, concepto, clave_mov, usuario)
            VALUES(iContReg,dFecha,cNUMCUENTA, dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,
                   cNaturaleza,cReferencia,CReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumTarjeta,cReversados,cUsuario,
				   cReferencia23, vOrdenante, dRef, vConcepto, pClaveMov, cID_USUARIOC);

			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END FOREACH;

		update statistics medium for table bdicnweb:sw_cons_movimientos;
		update statistics medium for table bdicnweb:sw_cons_movimientos2;

		IF iAbierto = 1 THEN
			LET iAbierto = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;

		IF iContReg = 0 THEN
			LET cCodRet = '00039';
		END IF;

		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		
	ELIF cSISTEMACUENTA = 'INVERSIONES' THEN
		  LET iCont = 0;
		  
		  FOREACH WITH HOLD
			SELECT
				MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,
				MO.usuario,MO.num_serial
			INTO 
				dFecha,dHora,cFolio,cTransaccion,mMonto,cReversados,dPeriodoI_1,dPeriodoF_1,sNumSecuencia,cSucursal,
				cUsuario,sNUMSERIAL
			FROM bdinvers:sv_maeinv MC
			LEFT JOIN bdinvers:sv_movdia MO
				 ON MC.cuenta = MO.cuenta
			WHERE MO.cuenta = cNUMCUENTA
				AND MO.fech_alt >= dPERIODOI AND MO.fech_alt <= dPERIODOF
			ORDER BY MO.num_serial DESC

			IF (mImporte <> 0 AND mImporte <> mMonto) THEN
				CONTINUE FOREACH;
			END IF;
			
			IF (cSuc <> "" AND cSuc <> cSucursal) THEN
				CONTINUE FOREACH;
			END IF;
			
			IF (pUsuario <> "" AND pUsuario <> cUsuario) THEN
				CONTINUE FOREACH;
			END IF;

			SELECT
					TR.descripcion
			  INTO cD_Transaccion
			  FROM bdinteg:si_transacc TR
			 WHERE TR.numero = cTransaccion
			   AND TR.sistema = '03'
			   AND TR.empresa = '001';

			LET iCont=iCont+1;

			INSERT INTO "informix".si_tempomovs_2 (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza,
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23,fecha_insert,clave_mov)
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23,CURRENT,pClaveMov);

				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
		  END FOREACH;
		  
		  LET iCont = 0;
		  
		  FOREACH WITH HOLD
			SELECT 
				MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,MO.usuario,MO.num_serial
			INTO 
				dFecha,dHora,cFolio,cTransaccion,mMonto,cReversados,dPeriodoI_1,dPeriodoF_1,sNumSecuencia,cSucursal,cUsuario,sNUMSERIAL
			FROM bdinvers:sv_movhis MO
			WHERE MO.empresa = "001"
				AND MO.cuenta = cNUMCUENTA
				AND MO.fech_alt >= dPERIODOI AND MO.fech_alt <= dPERIODOF
			ORDER BY MO.num_serial DESC

			IF (mImporte <> 0 AND mImporte <> mMonto) THEN
				CONTINUE FOREACH;
			END IF;
			
			IF (cSuc <> "" AND cSuc <> cSucursal) THEN
				CONTINUE FOREACH;
			END IF;
			
			IF (pUsuario <> "" AND pUsuario <> cUsuario) THEN
				CONTINUE FOREACH;
			END IF;

			SELECT 
					TR.descripcion
			  INTO cD_Transaccion
			  FROM bdinteg:si_transacc TR
			 WHERE TR.numero = cTransaccion
			   AND TR.sistema = '03'
			   AND TR.empresa = '001';

			LET iCont=iCont+1;

			INSERT INTO "informix".si_tempomovs_2 (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza,
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23,fecha_insert,clave_mov)
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23,CURRENT,pClaveMov);

			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		  END FOREACH;

		update statistics medium for table si_tempomovs_2;

		LET iCont = 0;
		
		FOREACH WITH HOLD
			SELECT {+INDEX (bdinteg:si_tempomovs_2 idx_tempo_movs_2)}
				codret, ejecutivosif, no_cuenta, fech_alt,
				fech_hor, transacc, descripcion, monto_tot, naturaleza, sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_tarjeta, usuario,
				referencia_23
			INTO 
				cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
			FROM "informix".si_tempomovs_2
			WHERE ejecutivosif = cID_USUARIOC AND no_cuenta = cNUMCUENTA AND clave_mov = pClaveMov
			ORDER BY fech_alt DESC,fech_hor DESC
			
			SELECT COUNT(*) INTO iexiste FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			
			IF NVL(iexiste,0)> 0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			ELSE
				SELECT COUNT(*) INTO iexiste FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
			
				IF NVL(iexiste,0)> 0 THEN
					SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
				ELSE
					LET cProcedencia="";
					LET cD_Procedencia="";
				END IF;
			END IF;

			LET iCont=iCont+1;

			LET iContReg = iContReg + 1;

			--Â¡Cuidado! si estÃ¡ tabla crece y no se depura, los costos de inserciÃ³n serÃ¡n muy grandes
			INSERT INTO bdicnweb:"informix".sw_cons_movimientos(id_registro,fechahora_insert,fecha,hora,cve_transacc,desc_transacc,folio,periodo_inicial,monto,periodo_final,sis_cuenta,naturaleza,referencia,reversos,sucursal,cve_proc,desc_proc,saldo,num_tarjeta,reversados,usuario,referencia23,clave_mov)
			VALUES(iContReg,CURRENT,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,cReferencia,cReversos,cSucursal,
			cProcedencia,cD_Procedencia,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23,pClaveMov);

			-- Se llena la tabla sw_cons_movimientos2 con los datos de la cuanta NOSTRO (en caso de aplicar)
			LET vOrdenante = '';
            LET dRef = "";
            LET vConcepto = '';

            IF iclienteNostro > 0 THEN
                SELECT vchrnombreord as ordenante, intrefnumerica as ref, vchrconceptopago as concepto
                INTO vOrdenante, dRef, vConcepto
                FROM bdispei:tblhistpago
                WHERE dtfechacaptura = dFecha
					AND vchrclaverastreo = cReferencia
					AND mnyimporte = mMonto;
            END IF

			--INSERTAMOS AL REPORTE
            INSERT INTO bdicnweb:"informix".sw_cons_movimientos2
            (id_registro,fecha, numcuenta, hora, cve_transaccion, desc_transaccion, folio, periodo_inicial, monto, periodo_final,
             sistema_cuenta, naturaleza, referencia, reversos, sucursal, cve_procedencia, desc_procedencia, saldo, numero_tarjeta,
			 reversados, usuario_mov, referencia23, ordenante, refe, concepto, clave_mov, usuario)
            VALUES(iContReg,dFecha,cNUMCUENTA, dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,
                   cNaturaleza,cReferencia,CReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumTarjeta,cReversados,cUsuario,
				   cReferencia23, vOrdenante, dRef, vConcepto, pClaveMov, cID_USUARIOC);

			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END FOREACH;

		update statistics medium for table bdicnweb:sw_cons_movimientos;
		update statistics medium for table bdicnweb:sw_cons_movimientos;

		IF iAbierto = 1 THEN
			LET iAbierto = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;

		IF iContReg = 0 THEN
			LET cCodRet = '00039';
		END IF;

		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF
END

END PROCEDURE

DOCUMENT
"AutOR : ARTURO CERVANTES PENA",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques, para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 09-02-2012",
"ACTUALIZO: Victor Hugo SÃ¡nchez M.",
"MODIFICACION: Se agregaron los parametros empleado,sucursal e importe para filtrar movimientos",
"FECHA: 04/07/2012",
"ACTUALIZO: Oscar Flores Conde (M-Finis Soluciones y Servicios Financieros)",
"MODIFICACION: Se agregaron el parametro de entrada para filtrar los movimientos reversados, se agrega en los parametros de salida la referencia a 23 posiciones",
"FECHA: 02/12/2013",
"AUTOR: L. Montserrat LeÃ³n Amador",
"FECHA: 24/10/2017",
"MODIFICACION: Se crea SPL CLON de: sp_cnsif_consultamovtosdiarioscta3, para eliminar parÃ¡metros de paginaciÃ³n.",
"AUTOR: Rodolfo Conde Flores",
"FECHA: 08/01/2018",
"MODIFICACION: Se implementa nueva estructura de paso si_tempomovs_2.",
"AUTOR: L. Montserrat LeÃ³n Amador",
"FECHA 25/01/2019",
"DESCRIPCION MODIFICACION: Se modifica implementaciÃ³n de ejecuciÃ³n COMMIT cada 1000 registros sobre la tabla sw_cons_movimientos.",
"ACTUALIZO : URIEL AMADOR ISLAS",
"FECHA : 12-07-2023",
"MODIFICACION:OptimizaciÃ³n a solicitud de base de datos por altos costos, se limita la bÃºsqueda a cuentas captaciÃ³n a tablas sc_movdia y sc_movhis",
"ACTUALIZO : URIEL AMADOR ISLAS",
"FECHA : 09-08-2023",
"MODIFICACION:Se agrega a la bÃºsqueda de cuentas captaciÃ³n la tabla sc_movhis_old",
"BD    : bdinteg",
"VER   : 3.0",
"OPTIMIZACION STK202404",
"Modificado: Softtek / A.Canseco 04,07.2024",
"OPTIMIZACION STK202404",
"ACTUALIZO : JosÃ© Antonio RamÃ­rez Franco",
"FECHA : 04-09-2024",
"MODIFICACION:Se agrega a la bÃºsqueda de cuentas captaciÃ³n la tabla sc_movhis_old2",
"BD    : bdinteg",
"VER   : 3.1",
"ACTUALIZO : URIEL AMADOR ISLAS",
"FECHA : 30-10-2024",
"MODIFICACION: Se quita la limpieza de la tabla si_tempomovs, dado que se depurara en el JOB 1109 junto con la tabla sw_cons_movimientos, y se separa la validaciÃ³n de importe, usuario y sucursal",
"BD    : bdinteg",
"VER   : 3.2";

CREATE PROCEDURE "informix".sp_cnsif_consnumcte(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cTCONSULTA char(1),cTDOMICILIO char(1),cTBUSQUEDA CHAR(1),cNUMCTE char(20),cNUMCUENTA CHAR(20),cNUMTARJETA CHAR(20))
       returning 	CHAR(5)  AS Cod_Retorno,
					CHAR(20) AS Numero_Cliente,
					CHAR(26) AS Nombre_1,
					CHAR(26) AS Nombre_2,
					CHAR(26) AS Apellido_Paterno,
					CHAR(26) AS Apellido_Materno,
					CHAR(60) AS Razon_Social,
					CHAR(13) AS RFC,
					CHAR(1)  AS Tipo_Cliente,
					CHAR(40) AS Desc_Tipo_Cliente,
					DATE     AS Fecha_Nacimiento,
					CHAR(1)  AS Cve_Sexo,
					CHAR(2)  AS Cve_Tipo_Persona,
					CHAR(20) AS Desc_Tipo_Persona,
					DATE     AS Fecha_Alta,
					CHAR(4)  AS Sucursal,
					CHAR(3)  AS Plaza,
					CHAR(5)  AS Cve_Situacion,
					CHAR(75) AS Desc_Situacion,
					INTEGER  AS Secuencia,
					CHAR(40) AS Calle, 
					CHAR(10) AS Numero_Exterior_Calle,
					CHAR(10) AS Numero_Interior_Calle,
					CHAR(6)  AS Departamento,
					CHAR(60) AS Colonia,
					CHAR(60) AS Municipio,
					CHAR(60) AS Ciudad,
					CHAR(30) AS Estado,
					CHAR(20) AS Pais,
					CHAR(5)  AS Codigo_Postal,
					CHAR(13) AS Telefono_1,
					CHAR(13) AS Telefono_2,
					CHAR(13) AS Telefono_3,
					CHAR (5) AS Extension,
					INTEGER  AS Nivel_Consulta,
					CHAR(60) AS Desc_Nivel_Consulta;
 
			
define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;
DEFINE iexiste_situacion INTEGER;



DEFINE cNumcliente 		CHAR(20);
DEFINE cNombre1 		CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApell_paterno 	CHAR(26);
DEFINE cApell_materno 	CHAR(26);
DEFINE cRazon_social	CHAR(60);
DEFINE cRfc 			CHAR(13);
DEFINE cTipo_cliente	CHAR(1);
DEFINE cDtipoCliente	CHAR(40);
DEFINE dfecha_nac		DATE;
DEFINE cSexo 			CHAR(1);
DEFINE ctpo_persona 	CHAR(2);
DEFINE cDtipo_persona	CHAR(20);
DEFINE dfecha_alta		DATE;
DEFINE csucursal		CHAR(4);
DEFINE dPlaza_cte		CHAR(3);
DEFINE cClave_situ		CHAR(5);
DEFINE cD_situacion		CHAR(75);
DEFINE cNivel_consulta	INTEGER;
DEFINE cDesc_Nivel_consulta	CHAR(60);

define vtipo_dir 		CHAR(1);
define vsecuencia 		INTEGER;
define vcalle 			CHAR(40);
define vnumeroextcalle  CHAR(10);
define vnumerointcalle  CHAR(10);
define vdepartamento  	CHAR(6);
define vcolonia 		CHAR(60);
define vmunicipio 		CHAR(60);
define vciudad 			CHAR(60);
define vestado 			CHAR(30);
define vpais 			CHAR(20);
define vcod_postal 		CHAR(5);
define vtelefono1 		CHAR(13);
define vtelefono2  		CHAR(13);
define vtelefono3  		CHAR(13);
define vextension 		CHAR(5);
define vpuntocardinal  	CHAR(1);
define vunidadhabitac  	CHAR(1);
define vmanzana 		CHAR(30);
define votros  			CHAR(30);
define vandador 		CHAR(30);
define vetapa 			CHAR(30);
define vlote  			CHAR(30);
define ventrada  		CHAR(30);
define vedificio  		CHAR(30);
define ventre_calles 	CHAR(80);
define vobservaciones 	CHAR(40);
DEFINE cNumcliente2		CHAR(20);
define errorSQL			CHAR(5);
DEFINE cCSitua_esp		CHAR(5);
DEFINE cSituacion_esp	CHAR(75);
DEFINE cSubcta          CHAR(1);
DEFINE cTipo_Dom        CHAR(15);
DEFINE dfecha_insert 	DATE;
DEFINE iKiosko			INT;

DEFINE iexiste INTEGER;
DEFINE  cNumero_cliente CHAR(20);
DEFINE cNumCtePrincipal CHAR(20);
DEFINE iTpo_cliente			INT;
DEFINE cQuery CHAR(1500);
DEFINE cStatus CHAR(50);
DEFINE cProdDebito CHAR(200);
DEFINE cProdCredito CHAR(200);

let vciclo = 0;
let vcodret = "00000";
let  vsqlerr = 0;
LET iexiste = 0;
LET iexiste_situacion = 0;
LET  cNumero_cliente = "";

LET vtipo_dir = "";
LET vsecuencia = 0 ;
LET vcalle = "";
LET vnumeroextcalle  = "";
LET vnumerointcalle  = "";
LET vdepartamento  = "";
LET vcolonia = "";
LET vmunicipio = "";
LET vciudad = "";
LET vestado = "";
LET vpais = "";
LET vcod_postal  = "";
LET vtelefono1  = "";
LET vtelefono2   = "";
LET vtelefono3   = "";
LET vextension  = "";
LET vpuntocardinal   = "";
LET vunidadhabitac   = "";
LET vmanzana = "";
LET votros  = "";
LET vandador = "";
LET vetapa = "";
LET vlote  = "";
LET ventrada  = "";
LET vedificio  = "";
LET ventre_calles = "";
LET vobservaciones = "";
LET cNumcliente = ""; 	
LET cNombre1 = "";
LET cNombre2 = "";
LET cApell_paterno = "";
LET cApell_materno = "";
LET cRazon_social  = "";
LET cRfc 			= "";
LET cTipo_cliente	= "";
LET cDtipoCliente	= "";
LET dfecha_nac		= "";
LET cSexo 			= "";
LET ctpo_persona 	= "";
LET cDtipo_persona	= "";
LET dfecha_alta		= "";
LET csucursal		= "";
LET dPlaza_cte		= "";
LET cClave_situ		= "";
LET cD_situacion	= "";
LET cNivel_consulta	= "";
LET cDesc_Nivel_consulta="";
LET cNumcliente2 = "";
LET cCSitua_esp	 = "";	
LET cSituacion_esp = "";
LET cSubcta         ="";
LET cTipo_Dom="";
LET dfecha_insert=TODAY;
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";
LET iKiosko =0;
LET cQuery = '';
LET cStatus = "";
LET cProdDebito = "";
LET cProdCredito = "";


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
		cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
		
			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;

      end if;
   end exception;
	--SET DEBUG FILE TO "/informix/VH/movil/sp_cnsif_consnumcte.out";
	--TRACE ON;
		
	IF 	cID_USUARIOC = ''	OR
		cID_FUNCIONC = ''	OR
		cTCONSULTA  = '' 	OR 
		cTDOMICILIO = ''	OR
		cTBUSQUEDA = ''		THEN
		LET vcodret = "00054";
		RETURN vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
		cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
		
			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
	END IF;	
    IF cTCONSULTA NOT IN ('1','2','3') THEN
			LET vcodret = "00052";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
		
			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;    
    END IF
	
	--VALIDACION
	IF cNUMCUENTA != '' THEN
        LET cSubcta=SUBSTR(TRIM(cNUMCUENTA),1,1);
        IF cSubcta in ('6','7') THEN
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'06','1')
            INTO
            vcodret;
        ELIF cSubcta='3' THEN
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'03','1')
            INTO
            vcodret;
		ELIF cSubcta='8' THEN
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'01','1')
            INTO
            vcodret;
        ELSE
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'11','1')
            INTO
            vcodret;
        END IF;

	END IF;

	IF cNUMCTE != '' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCTE,'11','2')
		INTO
		vcodret;
	END IF;

	IF cNUMTARJETA != '' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMTARJETA,'11','3')
		INTO
		vcodret;
	END IF;

	IF (vcodret != '00000') THEN
		RETURN vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			   cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 			
			   vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			   vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
	END IF;
	-- TERMINA VALIDACION	

	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO vcodret,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;
	
	IF cID_FUNCIONC = 'SKI002' THEN
		LET iKiosko = 1;
	 END IF;
	 
	
	SELECT valor
	INTO cStatus
	FROM si_param
	WHERE cod_param = 338;
	
	SELECT valor
	INTO cProdDebito
	FROM si_param
	WHERE cod_param = 339;
	
	SELECT valor
	INTO cProdCredito
	FROM si_param
	WHERE cod_param = 340;
	
	
	IF cTCONSULTA  = '1' THEN 
		IF cNUMCTE = '' OR  cNUMCTE IS NULL THEN    
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
		
			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF  cNUMCTE <> '' OR NOT cNUMCTE IS NULL THEN  
			LET cNumero_cliente  = cNUMCTE;
		END IF 	
	ELIF cTCONSULTA  = '2' THEN 
		IF cNUMCUENTA = '' OR  cNUMCUENTA IS NULL THEN
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
		
			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF cNUMCUENTA  <> '' OR  NOT cNUMCUENTA IS NULL THEN
            IF LENGTH(TRIM(cNUMCUENTA))>11 THEN
				IF cID_FUNCIONC = 'SKI002' THEN
					LET cQuery = "SELECT LIMIT 1 numcte FROM bdicred:sd_maecred WHERE num_credito = '"||TRIM(cNUMCUENTA)||"' AND num_producto IN ("||TRIM(cProdCredito)||")";
					LET cQuery = TRIM(cQuery)||" AND empresa = '001' UNION SELECT numcte FROM bdicred:sd_maecredcrd WHERE num_credito = '"||TRIM(cNUMCUENTA)||"' AND";
					LET cQuery = TRIM(cQuery)||" num_producto IN ("||TRIM(cProdCredito)||") AND empresa = '001'";
					PREPARE stmtId FROM TRIM(cQuery);
					DECLARE custCur CURSOR FOR stmtId;
					OPEN custCur;
					FETCH custCur INTO cNumero_cliente;
					CLOSE custCur;
					FREE custCur;
					FREE stmtId;
					IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN 
						LET vcodret = "00361";
						RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
						cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
					
						vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
						vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
					END IF;
				ELSE
					FOREACH
						SELECT LIMIT 1 numcte INTO cNumero_cliente 
						FROM bdicred:sd_maecred
						WHERE num_credito = cNUMCUENTA AND empresa = '001'
						UNION
						SELECT numcte
						FROM bdicred:sd_maecredcrd
						WHERE num_credito = cNUMCUENTA AND empresa = '001'
				   END FOREACH;
				END IF;
            ELSE
                IF cSubcta='3' THEN
                    SELECT LIMIT 1 num_cte INTO cNumero_cliente 
                    FROM bdinvers:sv_maeinv
                    WHERE cuenta = cNUMCUENTA AND empresa = '001';
                ELSE
					IF cID_FUNCIONC = 'SKI002' THEN
						LET cQuery = "SELECT LIMIT 1 num_cte FROM bdicheq:sc_maechq WHERE cuenta = '"||TRIM(cNUMCUENTA)||"' AND producto IN ("||TRIM(cProdDebito)||")";
						LET cQuery = TRIM(cQuery)||" AND status_cta NOT IN ("||TRIM(cStatus)||") AND empresa = '001'";
						PREPARE stmtId FROM TRIM(cQuery);
						DECLARE custCur CURSOR FOR stmtId;
						OPEN custCur;
						FETCH custCur INTO cNumero_cliente;
						CLOSE custCur;
						FREE custCur;
						FREE stmtId;
						IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN 
							LET vcodret = "00361";
							RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
							cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
						
							vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
							vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
						END IF;
					ELSE
						FOREACH
						SELECT num_cte INTO  cNumero_cliente 
						FROM bdicheq:sc_maechq
						WHERE cuenta = cNUMCUENTA AND empresa = '001'
						UNION
						SELECT CASE WHEN iTpo_cliente = 2 THEN numcte_tf ELSE numcte END
						FROM bditransfer:tf_maecte
						WHERE cuenta_tf = cNUMCUENTA AND empresa = '001'
						END FOREACH;
					END IF;
                END IF;
			end if;
		END IF	
	ELIF cTCONSULTA = '3' THEN 
		IF cNUMTARJETA = '' OR  cNUMTARJETA IS NULL THEN		
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
		
			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF cNUMTARJETA <> '' OR  NOT cNUMTARJETA IS NULL  THEN 
			IF cID_FUNCIONC = 'SKI002' THEN
				FOREACH
				SELECT NVL(numcte,0) INTO  cNumero_cliente 
                FROM bdicred:sd_tarjeta 
                WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001'
				AND status_tar = 'A'
				UNION
				SELECT NVL(numcte,0)
                FROM bdicheq:sc_tarjeta 
                WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001'
				AND status_tar = 'A'
				END FOREACH;
				IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN 
					LET vcodret = "00362";
					RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
					cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
				
					vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
					vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
				END IF;
			ELSE
		        SELECT NVL(numcte,0) INTO  cNumero_cliente 
                FROM bdicred:sd_tarjeta 
                WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001' ;
                
                IF cNumero_cliente='0' OR cNumero_cliente IS NULL THEN
                    SELECT NVL(numcte,0) INTO  cNumero_cliente 
                    FROM bdicheq:sc_tarjeta 
                    WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001' ;	
                END IF;
			END IF;
		END IF
	ELIF cNUMCTE = '' OR  cNUMCTE IS NULL AND cNUMTARJETA  = '' OR cNUMTARJETA IS NULL AND cNUMTARJETA = ''  OR cNUMTARJETA IS NULL THEN 
		LET vcodret = "00054";
		RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
		cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
	
		vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
		vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
	END IF 				
	
	FOREACH
	select first 1 nvl(count(numcte),0) into iexiste from si_cliente where numcte = cNumero_cliente AND empresa = '001'
	UNION
	select nvl(count(numcte_tf),0) from bditransfer:tf_maecte where numcte_tf = cNumero_cliente
	ORDER BY 1 desc
	END FOREACH;
	IF iexiste = 0 THEN
		IF cID_FUNCIONC = 'CLI352' THEN
			SELECT NVL(COUNT(numcte),0) INTO iexiste_situacion  FROM bdinteg:si_fusctessitespcte WHERE numcte = cNumero_cliente;
			
			IF iexiste_situacion >= 1 THEN
				SELECT SC.situacion||SC.causa,CS.descripcion 
				INTO cCSitua_esp, cSituacion_esp
				FROM bdinteg:si_fusctessitespcte SC
				LEFT JOIN bdisitesp:se_catsitesp CS
				ON CS.situacion = SC.situacion and CS.causa = SC.causa
				WHERE SC.numcte = cNumero_cliente and idmovto=(select max(idmovto) FROM bdinteg:si_fusctessitespcte WHERE numcte = cNumero_cliente);
		
			ELIF (SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred) 
			NVL(COUNT(numcte),0)  FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente) >= 1 THEN 
				
				SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred) 
				SC.situacion||SC.causa,CS.descripcion 
				INTO cCSitua_esp, cSituacion_esp
				FROM bdisitesp:se_ctessitespcred SC
				LEFT JOIN bdisitesp:se_catsitesp CS
				ON CS.situacion = SC.situacion and CS.causa = SC.causa
				WHERE SC.numcte = cNumero_cliente and idmvto=(select--+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
				max(idmvto) FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente);
			END IF;
			FOREACH
				SELECT  CL.numcte, CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social, CL.tipo_cliente,
				TP.descripcion AS D_tipoCliente,PF.fecha_nac,PF.sexo,CL.tpo_persona,TE.descripcion,CL.fecha_alta,CL.sucursal,SU.plaza, cCSitua_esp, 
				cSituacion_esp
				INTO cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
					cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion
				FROM si_fuscliente CL 
				LEFT JOIN si_tipocte TP
				ON TP.tipo_cliente = CL.tipo_cliente
				LEFT JOIN si_fusctepf PF
				ON PF.numcte = CL.numcte
				LEFT JOIN bdinteg:si_fusctessitespcte SC
				ON SC.numcte = CL.numcte
				LEFT JOIN si_sucursales SU
				ON SU.sucursal = CL.sucursal
				LEFT JOIN si_tipper TE
				ON TE.tpo_persona = CL.tpo_persona
				WHERE CL.numcte = cNumero_cliente AND CL.empresa = '001'
				
				SELECT NVL(nivel,0) INTO cNivel_consulta FROM si_cliente_nivel
				WHERE numcte=cNumero_cliente;

				IF cNivel_consulta IS NULL THEN
					LET cNivel_consulta=9;
				END IF;

				LET cDesc_Nivel_consulta='NIVEL '||cNivel_consulta;	
				
				SELECT rfc_alterno
				INTO cRfc 
				FROM si_cliente 
				WHERE numcte = cNumero_cliente AND empresa = '001';
				
				LET cRfc = NVL(cRfc,'');
				IF cRfc = '' THEN
					SELECT rfc INTO cRfc FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
					LET cRfc = NVL(cRfc,'');
					IF cRfc = '' THEN 
						SELECT rfc INTO cRfc FROM si_fuscliente WHERE numcte = cNumero_cliente AND empresa = '001';
					END IF;
				END IF;
				
				RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
				cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta WITH resume;
			END FOREACH;

			/*FOREACH
				EXECUTE PROCEDURE  "informix".sp_cnsif_consdirec(cID_USUARIOC ,cID_FUNCIONC,cNumero_cliente,cTBUSQUEDA,cTDOMICILIO,0,1) 
				INTO errorSQL,cNumcliente2,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
					vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
					votros,vandador,vetapa,vlote,ventrada,vedificio,ventre_calles,vobservaciones,cTipo_Dom,dfecha_insert

				RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
				cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta WITH resume;
			END FOREACH;*/
		ELSE
			LET vcodret = "00055";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 
		
			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		END IF;
	END IF;	
	SELECT NVL(COUNT(numcte),0) INTO iexiste_situacion  FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumero_cliente;
	
	
	IF iexiste_situacion >= 1 THEN
		SELECT SC.situacion||SC.causa,CS.descripcion 
		INTO cCSitua_esp, cSituacion_esp
		FROM bdisitesp:se_ctessitespcte SC
		LEFT JOIN bdisitesp:se_catsitesp CS
		ON CS.situacion = SC.situacion and CS.causa = SC.causa
		WHERE SC.numcte = cNumero_cliente and idmovto=(select max(idmovto) FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumero_cliente);
	
	ELIF (SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
	NVL(COUNT(numcte),0)  FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente) >= 1 THEN 
		
		SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
		SC.situacion||SC.causa,CS.descripcion 
		INTO cCSitua_esp, cSituacion_esp
		FROM bdisitesp:se_ctessitespcred SC
		LEFT JOIN bdisitesp:se_catsitesp CS
		ON CS.situacion = SC.situacion and CS.causa = SC.causa
		WHERE SC.numcte = cNumero_cliente and idmvto=(select --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
		max(idmvto) FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente);
	END IF 
	
	FOREACH
	SELECT FIRST 1 CL.numcte, CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno, CL.tipo_cliente,
	TP.descripcion AS D_tipoCliente,PF.fecha_nac,PF.sexo,CL.tpo_persona,TE.descripcion,CL.fecha_alta,CL.sucursal,SU.plaza, cCSitua_esp, 
	cSituacion_esp
	INTO 
	cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
	cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion
	FROM si_cliente CL 
	LEFT JOIN si_tipocte TP
	ON TP.tipo_cliente = CL.tipo_cliente
	LEFT JOIN si_ctepf PF
	ON PF.numcte = CL.numcte
	LEFT JOIN bdisitesp:se_ctessitespcte SC
	ON SC.numcte = CL.numcte
	LEFT JOIN si_sucursales SU
	ON SU.sucursal = CL.sucursal
	LEFT JOIN si_tipper TE
	ON TE.tpo_persona = CL.tpo_persona
	WHERE CL.numcte = cNumero_cliente AND CL.empresa = '001'
	UNION
	SELECT TF.numcte_tf, TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,'',TF.rfc,'1',
	'CLIENTE', TF.fecha_nac,'','01','FISICA',TF.fec_alta,'','',cCSitua_esp,
	cSituacion_esp
	FROM bditransfer:tf_maecte TF
	WHERE TF.numcte_tf = cNumero_cliente AND TF.empresa = '001'
	END FOREACH;

    SELECT NVL(nivel,0) INTO cNivel_consulta FROM si_cliente_nivel
    WHERE numcte=cNumero_cliente;

    IF cNivel_consulta IS NULL THEN
        LET cNivel_consulta=9;
    END IF;

    LET cDesc_Nivel_consulta='NIVEL '||cNivel_consulta;

	LET cRfc = NVL(cRfc,'');
    IF cRfc = '' THEN
        SELECT rfc INTO cRfc FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
    END IF;

	SET ISOLATION TO DIRTY READ;
	FOREACH
	execute PROCEDURE  "informix".sp_cnsif_consdirec(cID_USUARIOC ,cID_FUNCIONC,cNumero_cliente,cTBUSQUEDA,cTDOMICILIO,0,1) 
	INTO 
	errorSQL,cNumcliente2,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
	vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
	votros,vandador,vetapa,vlote,ventrada,vedificio,ventre_calles,vobservaciones,cTipo_Dom,dfecha_insert


	RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
	cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, 


	vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
	vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta with resume;
	END FOREACH;
end
end procedure
DOCUMENT
"Autor : Antonio Flores",
"FECHA : 2/enero/2012",
"FUNCIONAMIENTO:Dependiento del tipo de busqueda y del numero de usuario hara una busqueda los datos del cliente",
"haciendo un llamado el SP sp_cnsif_consdirec traera los datos de domicilio de dicho cliente",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"AUTOR: VERONICA SANCHEZ",
"FECHA: 05/06/2025",
"DESCRIPCION: SE AGREGA VALIDACION PARA LA RECUPERACION DEL VALOR DEL RFC SI NO SE RECUPERA EL RFC_ALTERNO",
"VERSION: 1.2";

CREATE PROCEDURE "informix".sp_cnsif_consnumcte(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cTCONSULTA char(1),cTDOMICILIO char(1),cTBUSQUEDA CHAR(1),cNUMCTE char(20),cNUMCUENTA CHAR(20),cNUMTARJETA CHAR(20), cNUMTELEFONO CHAR(10))
       returning 	CHAR(5)  AS Cod_Retorno,
					CHAR(20) AS Numero_Cliente,
					CHAR(26) AS Nombre_1,
					CHAR(26) AS Nombre_2,
					CHAR(26) AS Apellido_Paterno,
					CHAR(26) AS Apellido_Materno,
					CHAR(60) AS Razon_Social,
					CHAR(13) AS RFC,
					CHAR(1)  AS Tipo_Cliente,
					CHAR(40) AS Desc_Tipo_Cliente,
					DATE     AS Fecha_Nacimiento,
					CHAR(1)  AS Cve_Sexo,
					CHAR(2)  AS Cve_Tipo_Persona,
					CHAR(20) AS Desc_Tipo_Persona,
					DATE     AS Fecha_Alta,
					CHAR(4)  AS Sucursal,
					CHAR(3)  AS Plaza,
					CHAR(5)  AS Cve_Situacion,
					CHAR(75) AS Desc_Situacion,
					INTEGER  AS Secuencia,
					CHAR(40) AS Calle,
					CHAR(10) AS Numero_Exterior_Calle,
					CHAR(10) AS Numero_Interior_Calle,
					CHAR(6)  AS Departamento,
					CHAR(60) AS Colonia,
					CHAR(60) AS Municipio,
					CHAR(60) AS Ciudad,
					CHAR(30) AS Estado,
					CHAR(20) AS Pais,
					CHAR(5)  AS Codigo_Postal,
					CHAR(13) AS Telefono_1,
					CHAR(13) AS Telefono_2,
					CHAR(13) AS Telefono_3,
					CHAR (5) AS Extension,
					INTEGER  AS Nivel_Consulta,
					CHAR(60) AS Desc_Nivel_Consulta;


define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;
DEFINE iexiste_situacion INTEGER;



DEFINE cNumcliente 		CHAR(20);
DEFINE cNombre1 		CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApell_paterno 	CHAR(26);
DEFINE cApell_materno 	CHAR(26);
DEFINE cRazon_social	CHAR(60);
DEFINE cRfc 			CHAR(13);
DEFINE cTipo_cliente	CHAR(1);
DEFINE cDtipoCliente	CHAR(40);
DEFINE dfecha_nac		DATE;
DEFINE cSexo 			CHAR(1);
DEFINE ctpo_persona 	CHAR(2);
DEFINE cDtipo_persona	CHAR(20);
DEFINE dfecha_alta		DATE;
DEFINE csucursal		CHAR(4);
DEFINE dPlaza_cte		CHAR(3);
DEFINE cClave_situ		CHAR(5);
DEFINE cD_situacion		CHAR(75);
DEFINE cNivel_consulta	INTEGER;
DEFINE cDesc_Nivel_consulta	CHAR(60);

define vtipo_dir 		CHAR(1);
define vsecuencia 		INTEGER;
define vcalle 			CHAR(40);
define vnumeroextcalle  CHAR(10);
define vnumerointcalle  CHAR(10);
define vdepartamento  	CHAR(6);
define vcolonia 		CHAR(60);
define vmunicipio 		CHAR(60);
define vciudad 			CHAR(60);
define vestado 			CHAR(30);
define vpais 			CHAR(20);
define vcod_postal 		CHAR(5);
define vtelefono1 		CHAR(13);
define vtelefono2  		CHAR(13);
define vtelefono3  		CHAR(13);
define vextension 		CHAR(5);
define vpuntocardinal  	CHAR(1);
define vunidadhabitac  	CHAR(1);
define vmanzana 		CHAR(30);
define votros  			CHAR(30);
define vandador 		CHAR(30);
define vetapa 			CHAR(30);
define vlote  			CHAR(30);
define ventrada  		CHAR(30);
define vedificio  		CHAR(30);
define ventre_calles 	CHAR(80);
define vobservaciones 	CHAR(40);
DEFINE cNumcliente2		CHAR(20);
define errorSQL			CHAR(5);
DEFINE cCSitua_esp		CHAR(5);
DEFINE cSituacion_esp	CHAR(75);
DEFINE cSubcta          CHAR(1);
DEFINE cTipo_Dom        CHAR(15);
DEFINE dfecha_insert 	DATE;
DEFINE iKiosko			INT;

DEFINE iexiste INTEGER;
DEFINE  cNumero_cliente CHAR(20);
DEFINE cNumCtePrincipal CHAR(20);
DEFINE iTpo_cliente			INT;
DEFINE cQuery CHAR(1500);
DEFINE cStatus CHAR(50);
DEFINE cProdDebito CHAR(200);
DEFINE cProdCredito CHAR(200);
DEFINE iCuentalong	INT;

let vciclo = 0;
let vcodret = "00000";
let  vsqlerr = 0;
LET iexiste = 0;
LET iexiste_situacion = 0;
LET  cNumero_cliente = "";

LET vtipo_dir = "";
LET vsecuencia = 0 ;
LET vcalle = "";
LET vnumeroextcalle  = "";
LET vnumerointcalle  = "";
LET vdepartamento  = "";
LET vcolonia = "";
LET vmunicipio = "";
LET vciudad = "";
LET vestado = "";
LET vpais = "";
LET vcod_postal  = "";
LET vtelefono1  = "";
LET vtelefono2   = "";
LET vtelefono3   = "";
LET vextension  = "";
LET vpuntocardinal   = "";
LET vunidadhabitac   = "";
LET vmanzana = "";
LET votros  = "";
LET vandador = "";
LET vetapa = "";
LET vlote  = "";
LET ventrada  = "";
LET vedificio  = "";
LET ventre_calles = "";
LET vobservaciones = "";
LET cNumcliente = "";
LET cNombre1 = "";
LET cNombre2 = "";
LET cApell_paterno = "";
LET cApell_materno = "";
LET cRazon_social  = "";
LET cRfc 			= "";
LET cTipo_cliente	= "";
LET cDtipoCliente	= "";
LET dfecha_nac		= "";
LET cSexo 			= "";
LET ctpo_persona 	= "";
LET cDtipo_persona	= "";
LET dfecha_alta		= "";
LET csucursal		= "";
LET dPlaza_cte		= "";
LET cClave_situ		= "";
LET cD_situacion	= "";
LET cNivel_consulta	= "";
LET cDesc_Nivel_consulta="";
LET cNumcliente2 = "";
LET cCSitua_esp	 = "";
LET cSituacion_esp = "";
LET cSubcta         ="";
LET cTipo_Dom="";
LET dfecha_insert=TODAY;
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";
LET iKiosko =0;
LET cQuery = '';
LET cStatus = "";
LET cProdDebito = "";
LET cProdCredito = "";
LET iCuentalong=0;


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
		cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;

      end if;
   end exception;
	--SET DEBUG FILE TO "/informix/VH/cnsif/sp_cnsif_consnumcte.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF 	cID_USUARIOC = ''	OR
		cID_FUNCIONC = ''	OR
		cTCONSULTA  = '' 	OR
		cTDOMICILIO = ''	OR
		cTBUSQUEDA = ''		THEN
		LET vcodret = "00054";
		RETURN vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
		cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
	END IF;
    IF cTCONSULTA NOT IN ('1','2','3','4') THEN
			LET vcodret = "00052";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
    END IF

	--VALIDACION
	IF cNUMCUENTA != '' THEN
        LET cSubcta=SUBSTR(TRIM(cNUMCUENTA),1,1);
		LET iCuentalong=LENGTH(cNUMCUENTA);
        IF iCuentalong=12 THEN
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'06','1')
            INTO
            vcodret;
		ELSE	
			IF cSubcta='3' THEN
				EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'03','1')
				INTO
				vcodret;
			ELIF cSubcta='8' THEN
				EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'01','1')
				INTO
				vcodret;
			ELSE
				EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCUENTA,'11','1')
				INTO
				vcodret;
			END IF;
		END IF;	
	END IF;

	IF cNUMCTE != '' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMCTE,'11','2')
		INTO
		vcodret;
	END IF;

	IF cNUMTARJETA != '' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC,cNUMTARJETA,'11','3')
		INTO
		vcodret;
	END IF;
	
	IF (vcodret != '00000') THEN
		RETURN vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			   cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,
			   vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			   vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
	END IF;
	-- TERMINA VALIDACION

	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO vcodret,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;

	IF cID_FUNCIONC = 'SKI002' THEN
		LET iKiosko = 1;
	 END IF;


	SELECT valor
	INTO cStatus
	FROM si_param
	WHERE cod_param = 338;

	SELECT valor
	INTO cProdDebito
	FROM si_param
	WHERE cod_param = 339;

	SELECT valor
	INTO cProdCredito
	FROM si_param
	WHERE cod_param = 340;


	IF cTCONSULTA  = '1' THEN
		IF cNUMCTE = '' OR  cNUMCTE IS NULL THEN
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF  cNUMCTE <> '' OR NOT cNUMCTE IS NULL THEN
			LET cNumero_cliente  = cNUMCTE;
		END IF
	ELIF cTCONSULTA  = '2' THEN
		IF cNUMCUENTA = '' OR  cNUMCUENTA IS NULL THEN
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF cNUMCUENTA  <> '' OR  NOT cNUMCUENTA IS NULL THEN
            IF LENGTH(TRIM(cNUMCUENTA))>11 THEN
				IF cID_FUNCIONC = 'SKI002' THEN
					LET cQuery = "SELECT LIMIT 1 numcte FROM bdicred:sd_maecred WHERE num_credito = '"||TRIM(cNUMCUENTA)||"' AND num_producto IN ("||TRIM(cProdCredito)||")";
					LET cQuery = TRIM(cQuery)||" AND empresa = '001' UNION SELECT numcte FROM bdicred:sd_maecredcrd WHERE num_credito = '"||TRIM(cNUMCUENTA)||"' AND";
					LET cQuery = TRIM(cQuery)||" num_producto IN ("||TRIM(cProdCredito)||") AND empresa = '001'";
					PREPARE stmtId FROM TRIM(cQuery);
					DECLARE custCur CURSOR FOR stmtId;
					OPEN custCur;
					FETCH custCur INTO cNumero_cliente;
					CLOSE custCur;
					FREE custCur;
					FREE stmtId;
					IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN
						LET vcodret = "00361";
						RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
						cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

						vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
						vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
					END IF;
				ELSE
					FOREACH
						SELECT LIMIT 1 numcte INTO cNumero_cliente
						FROM bdicred:sd_maecred
						WHERE num_credito = cNUMCUENTA AND empresa = '001'
						UNION
						SELECT numcte
						FROM bdicred:sd_maecredcrd
						WHERE num_credito = cNUMCUENTA AND empresa = '001'
				   END FOREACH;
				END IF;
            ELSE
                IF cSubcta='3' THEN
                    SELECT LIMIT 1 num_cte INTO cNumero_cliente
                    FROM bdinvers:sv_maeinv
                    WHERE cuenta = cNUMCUENTA AND empresa = '001';
                ELSE
					IF cID_FUNCIONC = 'SKI002' THEN
						LET cQuery = "SELECT LIMIT 1 num_cte FROM bdicheq:sc_maechq WHERE cuenta = '"||TRIM(cNUMCUENTA)||"' AND producto IN ("||TRIM(cProdDebito)||")";
						LET cQuery = TRIM(cQuery)||" AND status_cta NOT IN ("||TRIM(cStatus)||") AND empresa = '001'";
						PREPARE stmtId FROM TRIM(cQuery);
						DECLARE custCur CURSOR FOR stmtId;
						OPEN custCur;
						FETCH custCur INTO cNumero_cliente;
						CLOSE custCur;
						FREE custCur;
						FREE stmtId;
						IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN
							LET vcodret = "00361";
							RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
							cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

							vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
							vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
						END IF;
					ELSE
						FOREACH
						SELECT num_cte INTO  cNumero_cliente
						FROM bdicheq:sc_maechq
						WHERE cuenta = cNUMCUENTA AND empresa = '001'
						UNION
						SELECT CASE WHEN iTpo_cliente = 2 THEN numcte_tf ELSE numcte END
						FROM bditransfer:tf_maecte
						WHERE cuenta_tf = cNUMCUENTA AND empresa = '001'
						END FOREACH;
					END IF;
                END IF;
			end if;
		END IF
	ELIF cTCONSULTA = '3' THEN
		IF cNUMTARJETA = '' OR  cNUMTARJETA IS NULL THEN
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF cNUMTARJETA <> '' OR  NOT cNUMTARJETA IS NULL  THEN
			IF cID_FUNCIONC = 'SKI002' THEN
				FOREACH
				SELECT NVL(numcte,0) INTO  cNumero_cliente
                FROM bdicred:sd_tarjeta
                WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001'
				AND status_tar = 'A'
				UNION
				SELECT NVL(numcte,0)
                FROM bdicheq:sc_tarjeta
                WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001'
				AND status_tar = 'A'
				END FOREACH;
				IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN
					LET vcodret = "00362";
					RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
					cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

					vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
					vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
				END IF;
			ELSE
		        SELECT NVL(numcte,0) INTO  cNumero_cliente
                FROM bdicred:sd_tarjeta
                WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001' ;

                IF cNumero_cliente='0' OR cNumero_cliente IS NULL THEN
                    SELECT NVL(numcte,0) INTO  cNumero_cliente
                    FROM bdicheq:sc_tarjeta
                    WHERE num_tarjeta  = cNUMTARJETA AND empresa = '001' ;
                END IF;
			END IF;
		END IF
	ELIF cTCONSULTA = '4' THEN  -- Consulta por numero de telefono
		IF cNUMTELEFONO = '' OR  cNUMTELEFONO IS NULL THEN
			LET vcodret = "00054";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		ELIF  cNUMTELEFONO <> '' OR NOT cNUMTELEFONO IS NULL THEN
			SELECT num_cte
			INTO cNumero_cliente
			FROM bdicheq:'informix'.sc_cuenta_telefono
			WHERE telefono = cNUMTELEFONO;
			
			IF cNumero_cliente IS NULL OR cNumero_cliente = '' THEN
				LET vcodret = "00318";
				RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
				cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

				vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
			END IF;
		END IF
	ELIF cNUMCTE = '' OR  cNUMCTE IS NULL AND cNUMTARJETA  = '' OR cNUMTARJETA IS NULL AND cNUMTARJETA = ''  OR cNUMTARJETA IS NULL AND cNUMTELEFONO = ''  OR cNUMTELEFONO IS NULL THEN
		LET vcodret = "00054";
		RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
		cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

		vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
		vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
	END IF

	FOREACH
	select first 1 nvl(count(numcte),0) into iexiste from si_cliente where numcte = cNumero_cliente AND empresa = '001'
	UNION
	select nvl(count(numcte_tf),0) from bditransfer:tf_maecte where numcte_tf = cNumero_cliente
	ORDER BY 1 desc
	END FOREACH;
	IF iexiste = 0 THEN
		IF cID_FUNCIONC = 'CLI352' THEN
			SELECT NVL(COUNT(numcte),0) INTO iexiste_situacion  FROM bdinteg:si_fusctessitespcte WHERE numcte = cNumero_cliente;

			IF iexiste_situacion >= 1 THEN
				SELECT SC.situacion||SC.causa,CS.descripcion
				INTO cCSitua_esp, cSituacion_esp
				FROM bdinteg:si_fusctessitespcte SC
				LEFT JOIN bdisitesp:se_catsitesp CS
				ON CS.situacion = SC.situacion and CS.causa = SC.causa
				WHERE SC.numcte = cNumero_cliente and idmovto=(select max(idmovto) FROM bdinteg:si_fusctessitespcte WHERE numcte = cNumero_cliente);

			ELIF (SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
			NVL(COUNT(numcte),0)  FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente) >= 1 THEN

				SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
				SC.situacion||SC.causa,CS.descripcion
				INTO cCSitua_esp, cSituacion_esp
				FROM bdisitesp:se_ctessitespcred SC
				LEFT JOIN bdisitesp:se_catsitesp CS
				ON CS.situacion = SC.situacion and CS.causa = SC.causa
				WHERE SC.numcte = cNumero_cliente and idmvto=(select--+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
				max(idmvto) FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente);
			END IF;
			FOREACH
				SELECT  CL.numcte, CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.tipo_cliente,
				TP.descripcion AS D_tipoCliente,PF.fecha_nac,PF.sexo,CL.tpo_persona,TE.descripcion,CL.fecha_alta,CL.sucursal,SU.plaza, cCSitua_esp,
				cSituacion_esp
				INTO cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
					cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion
				FROM si_fuscliente CL
				LEFT JOIN si_tipocte TP
				ON TP.tipo_cliente = CL.tipo_cliente
				LEFT JOIN si_fusctepf PF
				ON PF.numcte = CL.numcte
				LEFT JOIN bdinteg:si_fusctessitespcte SC
				ON SC.numcte = CL.numcte
				LEFT JOIN si_sucursales SU
				ON SU.sucursal = CL.sucursal
				LEFT JOIN si_tipper TE
				ON TE.tpo_persona = CL.tpo_persona
				WHERE CL.numcte = cNumero_cliente AND CL.empresa = '001'

				SELECT NVL(nivel,0) INTO cNivel_consulta FROM si_cliente_nivel
				WHERE numcte=cNumero_cliente;

				IF cNivel_consulta IS NULL THEN
					LET cNivel_consulta=9;
				END IF;

				LET cDesc_Nivel_consulta='NIVEL '||cNivel_consulta;
				
				SELECT rfc_alterno 
				INTO cRfc 
				FROM si_cliente 
				WHERE numcte = cNumero_cliente AND empresa = '001';
				
				LET cRfc = NVL(cRfc,'');
				IF cRfc = '' THEN
					SELECT rfc INTO cRfc FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
					LET cRfc = NVL(cRfc,'');
					IF cRfc = '' THEN 
						SELECT rfc INTO cRfc FROM si_fuscliente WHERE numcte = cNumero_cliente AND empresa = '001';
					END IF;
				END IF;

				RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
				cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta WITH resume;
			END FOREACH;

			/*FOREACH
				EXECUTE PROCEDURE  "informix".sp_cnsif_consdirec(cID_USUARIOC ,cID_FUNCIONC,cNumero_cliente,cTBUSQUEDA,cTDOMICILIO,0,1)
				INTO errorSQL,cNumcliente2,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
					vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana,
					votros,vandador,vetapa,vlote,ventrada,vedificio,ventre_calles,vobservaciones,cTipo_Dom,dfecha_insert

				RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
				cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion, vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta WITH resume;
			END FOREACH;*/
		ELSE
			LET vcodret = "00055";
			RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
			cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,

			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta;
		END IF;
	END IF;
	SELECT NVL(COUNT(numcte),0) INTO iexiste_situacion  FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumero_cliente;


	IF iexiste_situacion >= 1 THEN
		SELECT SC.situacion||SC.causa,CS.descripcion
		INTO cCSitua_esp, cSituacion_esp
		FROM bdisitesp:se_ctessitespcte SC
		LEFT JOIN bdisitesp:se_catsitesp CS
		ON CS.situacion = SC.situacion and CS.causa = SC.causa
		WHERE SC.numcte = cNumero_cliente and idmovto=(select max(idmovto) FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumero_cliente);

	ELIF (SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
	NVL(COUNT(numcte),0)  FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente) >= 1 THEN

		SELECT --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
		SC.situacion||SC.causa,CS.descripcion
		INTO cCSitua_esp, cSituacion_esp
		FROM bdisitesp:se_ctessitespcred SC
		LEFT JOIN bdisitesp:se_catsitesp CS
		ON CS.situacion = SC.situacion and CS.causa = SC.causa
		WHERE SC.numcte = cNumero_cliente and idmvto=(select --+AVOID_FULL (bdisitesp:"informix".se_ctessitespcred)
		max(idmvto) FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumero_cliente);
	END IF

	FOREACH
	SELECT FIRST 1 CL.numcte, CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno, CL.tipo_cliente,
	TP.descripcion AS D_tipoCliente,PF.fecha_nac,PF.sexo,CL.tpo_persona,TE.descripcion,CL.fecha_insert,CL.sucursal,SU.plaza, cCSitua_esp,
	cSituacion_esp
	INTO
	cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
	cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion
	FROM si_cliente CL
	LEFT JOIN si_tipocte TP
	ON TP.tipo_cliente = CL.tipo_cliente
	LEFT JOIN si_ctepf PF
	ON PF.numcte = CL.numcte
	LEFT JOIN bdisitesp:se_ctessitespcte SC
	ON SC.numcte = CL.numcte
	LEFT JOIN si_sucursales SU
	ON SU.sucursal = CL.sucursal
	LEFT JOIN si_tipper TE
	ON TE.tpo_persona = CL.tpo_persona
	WHERE CL.numcte = cNumero_cliente AND CL.empresa = '001'
	UNION
	SELECT TF.numcte_tf, TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,'',TF.rfc,'1',
	'CLIENTE', TF.fecha_nac,'','01','FISICA',TF.fec_alta,'','',cCSitua_esp,
	cSituacion_esp
	FROM bditransfer:tf_maecte TF
	WHERE TF.numcte_tf = cNumero_cliente AND TF.empresa = '001'
	END FOREACH;

    SELECT NVL(nivel,0) INTO cNivel_consulta FROM si_cliente_nivel
    WHERE numcte=cNumero_cliente;

    IF cNivel_consulta IS NULL THEN
        LET cNivel_consulta=9;
    END IF;

    LET cDesc_Nivel_consulta='NIVEL '||cNivel_consulta;
	
	LET cRfc = NVL(cRfc,'');
    IF cRfc = '' THEN
        SELECT rfc INTO cRfc FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
    END IF;

	
	FOREACH
	execute PROCEDURE  "informix".sp_cnsif_consdirec(cID_USUARIOC ,cID_FUNCIONC,cNumero_cliente,cTBUSQUEDA,cTDOMICILIO,0,1)
	INTO
	errorSQL,cNumcliente2,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
	vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana,
	votros,vandador,vetapa,vlote,ventrada,vedificio,ventre_calles,vobservaciones,cTipo_Dom,dfecha_insert


	RETURN 	vcodret,cNumcliente,cNombre1,cNombre2,cApell_paterno,cApell_materno,cRazon_social,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
	cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cClave_situ, cD_situacion,


	vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
	vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,cNivel_consulta,cDesc_Nivel_consulta with resume;
	END FOREACH;
end
end procedure
DOCUMENT
"Autor : Antonio Flores",
"FECHA : 2/enero/2012",
"FUNCIONAMIENTO:Dependiento del tipo de busqueda y del numero de usuario hara una busqueda los datos del cliente",
"haciendo un llamado el SP sp_cnsif_consdirec traera los datos de domicilio de dicho cliente",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"Autor : Oscar Flores Conde",
"FECHA : 26/noviembre/2015",
"FUNCIONAMIENTO: Se agrega busqueda por numero movil",
"Ver.  : 1.2",
"BD    : bdinteg",
"VER   : 1.2",
"AUTOR: VERONICA SANCHEZ",
"FECHA: 05/06/2025",
"DESCRIPCION: SE AGREGA VALIDACION PARA LA RECUPERACION DEL VALOR DEL RFC SI NO SE RECUPERA EL RFC_ALTERNO",
"VERSION: 1.3";

CREATE PROCEDURE "informix".sp_limite_max_pruebajj(pNumcte CHAR(10),
                                          pCuenta CHAR(16),
                                          pOperacion CHAR(2),
                                          pCanal CHAR(2),         -- 01 - ATM, 02 - POS, 03 - PORTAL, 15 - EMPRESANET, 17 - BANCOPPEL MOVIL ONLINE.
                                          pFecha DATE,
                                          pMto_tot DECIMAL(16,2),
                                          pnumtarjeta CHAR (20))
RETURNING CHAR(5), CHAR (80), CHAR(1);

-- Declaracion de variables

    DEFINE sql_err      	    INTEGER;
    DEFINE isam_err     	    INTEGER;
    DEFINE vCodret1     	    CHAR(5);

    DEFINE vMtoacumcta          DECIMAL(16,2);
    DEFINE vLim_canal_pesos     DECIMAL(16,2);
    DEFINE vExiste              INTEGER;
    DEFINE vTipo_mensaje        CHAR(2);
    DEFINE vRestriccion         CHAR(2);
    DEFINE vMax_pesos           DECIMAL(16,2);
    DEFINE vMensaje1            CHAR (80);
    DEFINE vEnviar              CHAR(1);
    DEFINE vEmpresa             CHAR(3);
    DEFINE vEmail               CHAR(80);
    DEFINE vCorreoElec          CHAR(100); -- se agrega por la reingenieria
    DEFINE vNombre              CHAR(104);
    DEFINE vIndicador           CHAR(1);
    DEFINE vImporte             DECIMAL(16,2);
    DEFINE vEnviarMensaje       CHAR(60);
	DEFINE vOperacion           CHAR(2);   -- BGM SE DECLARA VARIABLE DE VOPERACION
    DEFINE Vtipo_tarjeta        CHAR(20);  -- RRG TIPO DE TARJETA TITULAR O ADICIONAL
	DEFINE vImporte2            CHAR(16);
	DEFINE vMontoTotal			CHAR(16);

	DEFINE vActivar_Limite      CHAR(100);
	DEFINE vCod_param           SMALLINT;
	DEFINE vMensaje2            CHAR (80);

	DEFINE v_fecha1             CHAR(200);
	DEFINE v_fecha              CHAR(06);
	DEFINE v_ano_wk             CHAR(04);
	DEFINE v_longitud           INTEGER;  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_cuenta				INTEGER;  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_subcadena			CHAR(1);  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_mail_incorrecto	CHAR(1);  -- BGM 31-08-2010 Variable para validacion de correo electronico

    DEFINE vExisteCta           SMALLINT;
    DEFINE vSistema             CHAR(2);
    DEFINE vSist                CHAR(2);

    DEFINE vTipoCorreo      	SMALLINT;
    DEFINE vStatusCorreo    	CHAR(1);
	
    DEFINE vsidmensaje 			CHAR(10);

	DEFINE vMax_pesos1 			DECIMAL(16,2);
	DEFINE vMax_pesos2 			DECIMAL(16,2);
	DEFINE vlimite_personalizado_rest1 SMALLINT;
	DEFINE vlimite_personalizado_rest2 SMALLINT;
	
	DEFINE vMax_pesosAC         DECIMAL(16,2);
	DEFINE vEnviarMensajeAC     CHAR(60);
	DEFINE vTipo_mensajeAC      CHAR(2);
	DEFINE vsidmensajeAC		CHAR(10);
	DEFINE vCambioPlantilla  	CHAR(1);
	DEFINE cRet					CHAR(5);
	DEFINE vValorUdi			DECIMAL(14,6);
	DEFINE vfecha				DATE;
	

-- Inicializacion de variables

    LET sql_err   = 0;
    LET isam_err  = 0;
    LET vCodret1  = '00000';

    LET vMtoacumcta         = 0.00;
    LET vLim_canal_pesos    = 0.00;
    LET vExiste             = 0;
    LET vTipo_mensaje       = '';
    LET vRestriccion        = '';
    LET vMax_pesos          = 0.00;
    LET vMensaje1           = 'El proceso concluyo exitosamente';
    LET vEnviar             = '';
    LET vEmpresa            = '001';
    LET vEmail              = '';
    LET vCorreoElec         = '';   -- se agrega por la reingenieria
    LET vNombre             = '';
    LET vIndicador          = '0';
    LET vImporte            = 0.00;
    LET vEnviarMensaje      = '';
	LET vImporte2			= '';
	LET vMontoTotal			= '';

    LET vActivar_Limite     = '';
    LET vCod_param          = 110;
    LET vMensaje2           = 'Validacion Inactiva';

    LET v_ano_wk            = YEAR(TODAY);
    LET v_ano_wk            = v_ano_wk[3,4];

    LET v_fecha             = LPAD(DAY(TODAY -1),2,0)||LPAD(MONTH(TODAY),2,0)||v_ano_wk;
	LET v_longitud          = 0;    -- BGM 31-08-2010 Variable para validacion de correo electronico
	LET v_cuenta            = 1;    -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET v_subcadena         = '';   -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET v_mail_incorrecto   = 'F';  -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET Vtipo_tarjeta       = '';   -- RRG 07-11-2011 Variable para tipo de tarjeta Titular o Adicional

    LET vExisteCta          = 0;
    LET vSistema            = '';

    LET vTipoCorreo = 0;
    LET vStatusCorreo = '';
	
	LET vMax_pesos1=0.00; --Variable para limites EmpresaNetPlus restriccion 01
	LET vMax_pesos2=0.00; --Variable para limites EmpresaNetPlus restriccion 02
	LET vlimite_personalizado_rest1=0;
	LET vlimite_personalizado_rest2=0;
	
	LET vMax_pesosAC        = 0.00;
	LET vEnviarMensajeAC    = '';
	LET vTipo_mensajeAC     = '';
    LET vsidmensajeAC	    = '';
	LET vCambioPlantilla	= 'F';
	LET cRet				= '';
	LET vValorUdi			= 0.00;
	LET vfecha				= DATE(1);

    --**************************************************************
     -- Creado por Raul Ramirez    01/Jul/2010
     -- Capitulo X Acumulado Diario y Preparacion para el envio de Mensaje
     -- Modificado el 03/03/2011, Se modifica el sp para envio de mensaje
     -- con informacion en particular para credito y debito, de transacciones
     -- realizadas en ATM y POS.
     -- Modificado el 17/01/2011, Se agrega el numero de tarjeta y el tipo
     -- para el armado del envio de mensaje.
     -- Se modifica el proceso por la reigenieria del Correo Electronico 26/03/12
	 
	 --Modificacion: para que consulte la tabla nueva de limites por empresa.
	 -- se agregan dos nuevas restricciones para EmpresaNetPlus.
	 --Fecha: 18 Agosto 2014
	 --Por: Berenice Noriega
	 --Liberado a produccion: 30-Enero-2015 	 
     --**************************************************************

    	--SET DEBUG FILE TO "/tmp/cristo/sp_limite_max.out";
    	--TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err  --, isam_err
		--- GENERA BITACORA DIARIA DE ERROR SIN INTERRUMPIR EL PROCESO DE JOM
		SET DEBUG FILE TO 'log'||to_char(today, '%Y%m%d')||'.err' WITH APPEND;
		TRACE ON;

		IF sql_err <> 0 THEN
			LET vCodret1 = sql_err;
		END IF;

		LET vMensaje1 = 'Se produjo un error inesperado';  ---- 21/07/2010
		LET vIndicador = '0';                              ---- 21/07/2010

		RETURN vcodret1,vMensaje1,vIndicador;   -- Termina proceso del SP 21/07/2010

	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
            --------    AGREGAR LA VALIDACION DEL NUMETO DE TARJETA
    IF (pNumcte is null OR pNumcte = '') OR --LENGTH(pNumcte) <> 10) OR
       (pCuenta is null OR pCuenta = '') OR --LENGTH(pCuenta) <> 16) OR
       (pOperacion is null OR pOperacion = '' OR pOperacion = '00' OR LENGTH(pOperacion) <> 2) OR
       (pCanal is null OR pCanal = '' OR pCanal <= '00' OR LENGTH(pCanal) <> 2) OR
       (pFecha is null OR pFecha = '') AND
       (pMto_tot is null OR pMto_tot <= 0.00) THEN


        LET vcodret1 = '00030';
        LET vMensaje1 = 'Se genero algÃÂºn error en la ejecucion';

        RETURN vcodret1,vMensaje1,vIndicador;
    END IF;

	-- Obtiene el Parametro para su Validacion y asignar el valor indicado en VACTIVAR_LIMITES
	SELECT valor
	INTO vActivar_Limite
	FROM bdinteg:"informix".si_param
	WHERE empresa = vEmpresa
	AND cod_param = vCod_param;

    IF vActivar_Limite = 'F' THEN              -- Validacion del Parametro de la tabla si_param
       RETURN vcodret1,vMensaje2,vIndicador;   -- Termina proceso del SP
    END IF;

	-- Verifica si ya existe un registro en la tabla si_limite_diario, para esa combinacion de cuenta / canal.
	-- En caso de que no exista, lo inserta.

	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACIÃÂN DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
		LET vOperacion = pOperacion;
	ELSE
		LET vOperacion = '00';
	END IF;

	SELECT {+index (si_limite_diario idx_limite_dia)} count (*)
	INTO vExiste
	FROM bdinteg:si_limite_diario
	WHERE f_operacion = pFecha
	AND cuenta = pCuenta
	AND numcte = pNumcte
	AND id_canal = pCanal
	AND id_operacion = vOperacion;  -- BGM SE CAMBIA VARIABLE A VOPERACION


	IF vExiste = 0 THEN
		INSERT INTO bdinteg:si_limite_diario VALUES
		(pFecha, pCuenta, pNumcte, pCanal, vOperacion, 0.00);  -- BGM SE MODIFICA VARIABLE PARA PARAMETRO DE ID OPERACION
	END IF;

	-- Si ya existe un registro en si_limite_diario, se asegura que el campo importe_dia tenga un valor vÃÂ¡lido.

	IF vExiste >= 1 THEN
		SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
		INTO vImporte
		FROM bdinteg:si_limite_diario
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION

		IF vImporte is null or vImporte = '' THEN
			UPDATE {+index (si_limite_diario idx_limite_dia)} bdinteg:si_limite_diario SET importe_dia = 0.00
			WHERE f_operacion = pFecha
			AND cuenta = pCuenta
			AND numcte = pNumcte
			AND id_canal = pCanal
			AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION
			
			LET vImporte = 0.00;
		END IF
	END IF;
	
	    --- Validacion para indentificar la cuenta, para el envio de mensaje correspondiente debito o credito.
	SELECT {+index (bdicheq:sc_maechq idx_maechq1)} COUNT(*)
	INTO vExisteCta
	FROM bdicheq:sc_maechq
	WHERE empresa = vEmpresa
	AND cuenta = pCuenta;

    IF vExisteCta > 0 THEN
        LET vSist = '01';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en debito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicheq:sc_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    ELSE
		LET vSist = '06';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en credito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicred:sd_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    END IF;

	---- VALIDACION DE MONTO POR CANAL
	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACIÃÂN DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
		 LET vOperacion = pOperacion;

		--******************************************************************************************************************--
		---INICIA PRIMERA PARTE DE LA MODIFICACION PARA LIMITES PERSONALIZADOS EMPRESANETPLUS--------------------------------
		--******************************************************************************************************************--
		IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_plimites_empresas 
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente=pNumcte
			AND num_cta= pcuenta
			AND id_restriccion='01'	) THEN
			
			SELECT tope_max_pesos
			INTO vMax_pesos1
			FROM bdinteg:"informix".si_plimites_empresas
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente = pNumcte
			AND num_cta= pcuenta
			AND id_restriccion = '01'; --En la tabla si_plimites_empresas la restruccion 01 es por el ACUMULADO por cuenta-operacion-cliente
			
			LET vlimite_personalizado_rest1=1;		
			
		END IF;	
		
		IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_plimites_empresas 
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente=pNumcte
			AND id_restriccion='02'	) THEN
			
			SELECT tope_max_pesos
			INTO vMax_pesos2
			FROM bdinteg:"informix".si_plimites_empresas
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente = pNumcte
			AND id_restriccion = '02'; --En la tabla si_plimites_empresas la restriccion 02 es por CADA OPERACION.
			
			LET vlimite_personalizado_rest2=1;					
		END IF;	

		IF vlimite_personalizado_rest1= 0 THEN --
			--**TERMINA PRIMERA PARTE DE MODIFICACION***************************************************************************--			 
			SELECT {+index (si_plimites idx_plimites)} tope_max_pesos
			INTO vMax_pesos
			FROM bdinteg:si_plimites
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND id_restriccion = '02'
			AND sistema = vSist;

		END IF;
	ELSE --Else, si no se trata de canal pCanal = '03' OR pCanal = '15' OR pCanal = '17' 
		LET vOperacion = '00';
		SELECT {+index (si_canales idx_canal)} limite_canal_pesos
		INTO vMax_pesos
		FROM bdinteg:si_canales
		WHERE id_canal = pCanal;
	END IF

	IF vlimite_personalizado_rest2=1 and pMto_tot > vMax_pesos2 THEN --si existe un limite por operacion,vMax_pesos es de si_plimites_empresas
		LET vcodret1 = '00035'; --00036
		LET vMensaje1 = 'Importe de la operacion excede el lÃÂ­mite diario permitido para el transaccion';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;
		
	ELIF vlimite_personalizado_rest1=1 and (pMto_tot + vImporte) > vMax_pesos1 THEN --Si existe limite por cuenta-operacion, 
		LET vcodret1 = '00035'; --00037
		LET vMensaje1 = 'Importe de la operacion excede el lÃÂ­mite diario permitido para el cuenta';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;

	ELIF vlimite_personalizado_rest1=0 and (pMto_tot + vImporte) > vMax_pesos   THEN --se agrega el if vlimite_personalizado=0
		LET vcodret1 = '00035';
		LET vMensaje1 = 'Importe de la transaccion excede el lÃÂ­mite diario permitido para el canal';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador; -- Termina proceso del SP
	ELSE
		--  SELECCIONA EL IMPORTE QUE TIENE PARA PROCEDER CON LA ACTUALIZACION
		SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
		INTO vImporte
		FROM bdinteg:si_limite_diario
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;	-- BGM SE MODIFICA VALOR DE ID OPERACION

		--  ACTUALIZA ACUMULADO
		UPDATE {+index (si_limite_diario idx_limite_dia)} bdinteg:si_limite_diario
		SET importe_dia = vImporte + pMto_tot
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION
		LET vIndicador = '0';
		--END IF;
		--RETURN vCodret1, vMensaje1, vIndicador WITH RESUME;  --------*****************
	END IF;

    LET venviar = 'F';

    --- Validacion para indentificar la cuenta, para el envio de mensaje correspondiente debito o credito.
	SELECT {+index (bdicheq:sc_maechq idx_maechq1)} COUNT(*)
	INTO vExisteCta
	FROM bdicheq:sc_maechq
	WHERE empresa = vEmpresa
	AND cuenta = pCuenta;

    IF vExisteCta > 0 THEN
        LET vSist = '01';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en debito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicheq:sc_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    ELSE
		LET vSist = '06';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en credito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicred:sd_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    END IF
	

	--******************************************************************************************************************--
	--INICIA SEGUNDA PARTE DE LA MODIFICACION PARA LIMITES PERSONALIZADOS EMPRESANETPLUS--------------------------------
	--******************************************************************************************************************--
	IF vlimite_personalizado_rest1=0 THEN --Si no se encontro en la tabla de limites entonces entra a validar los limites generales
		--**TERMINA SEGUNDA PARTE DE LA MODIFICACION************************************************************************--

		FOREACH

			SELECT {+index (si_plimites idx_plimites)} id_restriccion, tope_max_pesos, envio_mensaje, id_tipo_mensaje,sistema, id_mensaje
			INTO vRestriccion, vMax_pesos, vEnviarMensaje, vTipo_mensaje, vSistema, vsidmensaje
			FROM bdinteg:si_plimites
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND sistema = vSist


			IF vRestriccion = '01' THEN  -- OBTIENE IMPORTE DEL CAMPO IMPORTE_DIA y lo asigna en variable vImporte
				IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACIÃÂN DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
					LET vOperacion = pOperacion;
				ELSE
					LET vOperacion = '00';
				END IF

				SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
				INTO vImporte
				FROM bdinteg:si_limite_diario
				WHERE f_operacion = pFecha
				AND cuenta = pCuenta
				AND numcte = pNumcte
				AND id_canal = pCanal
				AND id_operacion = vOperacion;	-- BGM se usara la variable vOperacion en lugar del parametro pOperacion

				IF vImporte > vMax_pesos THEN
					LET vEnviar = 'V';              -- ACTUALIZA VARIABLE vEnviar
				END IF;
				
			END IF;

			IF vlimite_personalizado_rest2=0 THEN --Si la empresa no tiene personalisado para cada operacion
				IF vRestriccion = '02' THEN  --  Se valida que el monto de la transaccion sea mayor al limite en pesos
					
					EXECUTE PROCEDURE intercard:"informix".sp_obtener_udi('001',today)
					INTO cRet,vValorUdi,vfecha;
					
					-- Se obtiene valor del tope de acumulado para transaccion POS DEB y CRED 600 UDIS
					SELECT {+index (si_plimites idx_plimites)} (tope_max_udis*vValorUdi), envio_mensaje, id_tipo_mensaje,id_mensaje
					INTO vMax_pesosAC, vEnviarMensajeAC, vTipo_mensajeAC,  vsidmensajeAC
					FROM bdinteg:si_plimites
					WHERE id_operacion = '09'
					AND id_canal = pCanal
					AND sistema = vSist
					AND id_restriccion = '02';
					

					
					IF (vImporte+pMto_tot) > vMax_pesosAC AND NVL(vMax_pesosAC,0) > 0 THEN
						LET vImporte = vImporte+pMto_tot;
						LET vEnviar = 'V';
						
						IF vImporte > vMax_pesosAC AND vEnviarMensajeAC = 'V' THEN
							LET vCambioPlantilla= 'V';
							LET vEnviarMensaje = vEnviarMensajeAC;
							LET vTipo_mensaje = vTipo_mensajeAC;
							LET vsidmensaje = vsidmensajeAC;
						END IF;
					
					ELIF pMto_tot > vMax_pesos THEN
						LET vImporte = pMto_tot;
						LET vEnviar = 'V';

					END IF;
				END IF;
			END IF;

			IF vEnviar = 'V' and vEnviarMensaje = 'V' THEN -- VALIDA EL VALOR DE LA VARIABLE vEnviar y vEnviarMensaje, si es V

				--Divide el importe en millares para alertas de mensajeria
				LET vImporte2 = trim (to_char(vImporte,"###,###,###,###.##"));
				LET vMontoTotal = trim (to_char(pMto_tot,"###,###,###,###.##"));				

				IF vCambioPlantilla = 'F' THEN--Envio acumulado de 600 UDIS CLS 17/05/2016
					-- *** Registro de Evento por sms	  -- Graba en la nueva tabla de eventos 20/07/2012 ENVÃÂO SMS => TIPO '2'
					EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('2' , TRIM(SUBSTR(vsidmensaje,1,9))||'S', pNumcte, pCuenta, pnumtarjeta, '1', 
					Vtipo_tarjeta, vImporte2, '', '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
				ELSE
					-- Se envia alerta con plantilla distinta
					EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('2' , TRIM(SUBSTR(vsidmensajeAC,1,9))||'S',TRIM(SUBSTR(vsidmensaje,1,9))||'S2', pNumcte, pCuenta, pnumtarjeta, '1', 
					Vtipo_tarjeta, vImporte2, vMontoTotal, '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
				END IF;
				
				-- se obtiene nombre del cliente
				SELECT (TRIM(apell_paterno)||' '||TRIM(apell_materno)||' '||TRIM(nombre1)||' '||TRIM(nombre2))
				INTO vNombre
				FROM bdinteg:si_cliente
				WHERE numcte = pNumcte
				AND empresa = vEmpresa;
				
				-- se obtiene correo del cliente
				EXECUTE PROCEDURE "informix".sp_consulta_correos('001', pNumcte, 1, '0')   -- se agrega por la reingenieria
				INTO vcodret1, vCorreoElec, vTipoCorreo, vStatusCorreo;
				   
				LET vEmail = vCorreoElec;
			  
				-- *** Registro de Evento por Email
				-- Valida si el cliente tiene email para inserta en la tabla si_mensajes_enviar
				IF vCorreoElec is null or vCorreoElec = '' THEN
				--             CONTINUE FOREACH;
				ELSE
					--LET v_longitud = length(vEmail);    -- se comenta por la reingenieria
					LET v_longitud = length(vCorreoElec);
					
					FOR v_cuenta = 1 to v_longitud
						--LET v_subcadena = SUBSTR(vEmail,v_cuenta,1);    -- se comenta por la reingenieria
						LET v_subcadena = SUBSTR(vCorreoElec,v_cuenta,1);
						IF v_subcadena not in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
									 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
									 '1','2','3','4','5','6','7','8','9','0','@','_','-','.') THEN
							
							LET v_mail_incorrecto = 'T';

							-- Se dejan de grabar mensajes de ATM Y POS en esta tabla, todo se va por Latinia. JGP 16-08-2012
							IF vTipo_mensaje not in ('01', '04','05','06') THEN
								INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta, num_tarjeta, tipo_tarjeta, nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado,f_enviado,observaciones)
								VALUES(CURRENT, pNumcte, pCuenta, pnumtarjeta, Vtipo_tarjeta, vNombre, vEmail, vImporte, vTipo_mensaje, 'V',current,'DIRECCION DE CORREO INCORRECTA');
							END IF;
							
							IF vCambioPlantilla = 'F' THEN--Envio acumulado de 600 UDIS CLS 17/05/2016
								-- Graba en la nueva tabla de eventos 20/07/2012 con un ID inexistente para ser descartado.
								EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1' , TRIM(SUBSTR(vsidmensaje,1,9))||'*', pNumcte, pCuenta, pnumtarjeta, '1', 
								Vtipo_tarjeta, vImporte2, '', '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
							ELSE
								-- Se envia alerta con plantilla distinta
								EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1' , TRIM(SUBSTR(vsidmensaje,1,9))||'*',TRIM(SUBSTR(vsidmensaje,1,9))||'*2', pNumcte, pCuenta, pnumtarjeta, '1', 
								Vtipo_tarjeta, vImporte2, vMontoTotal, '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
							END IF;
							
							EXIT FOR;
							
						ELSE
							CONTINUE FOR;
						END IF;
					END FOR
					
					IF v_mail_incorrecto = 'F' THEN
						-- Se dejan de grabar mensajes de ATM Y POS en esta tabla, todo se va por Latinia. JGP 16-08-2012
						IF vTipo_mensaje not in ('01', '04','05','06') THEN	
						   INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta, num_tarjeta, tipo_tarjeta, nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado)
						   VALUES(CURRENT, pNumcte, pCuenta, pnumtarjeta, Vtipo_tarjeta, vNombre, vEmail, vImporte, vTipo_mensaje, 'F');
						END IF;  
						
						IF vCambioPlantilla = 'F' THEN--Envio acumulado de 600 UDIS CLS 17/05/2016
							-- Graba en la nueva tabla de eventos 20/07/2012 ENVÃÂO EMAIL => TIPO '1'
							EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1' , TRIM(SUBSTR(vsidmensaje,1,9))||'E', pNumcte, pCuenta, pnumtarjeta, '1', 
							Vtipo_tarjeta, vImporte2, '', '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
						ELSE
							-- Se envia alerta con plantilla distinta
							EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1' , TRIM(SUBSTR(vsidmensaje,1,9))||'E',TRIM(SUBSTR(vsidmensaje,1,9))||'E2', pNumcte, pCuenta, pnumtarjeta, '1', 
							Vtipo_tarjeta, vImporte2, vMontoTotal, '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
						END IF;

					END IF;
				END IF;
			  
			ELSE
				  LET vEnviar = 'F';

			END IF;

		END FOREACH;
	END IF;
END
    RETURN vCodret1, vMensaje1, vIndicador;

END PROCEDURE;