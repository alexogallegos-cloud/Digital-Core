CREATE PROCEDURE "informix".sp_cnsif_consultamovtosdiarioscta3(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20), pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2), pNumRegistro INTEGER,pRecuperacion INTEGER)

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
LET iCont       = 0;
LET pEmpresa   = '001';
LET cCodfun               ='';
LET cCodref               =0;
LET  iExisteCta = 0;
LET iKiosko               =0;
LET iAbierto              =0;


BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
               RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
               cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF;
     END EXCEPTION;
                

	--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3; 

    --SET DEBUG FILE TO "/informix/CHVN/sp_cnsif_consultamovtosdiarioscta3.out";
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

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
          RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
          cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;                        
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
            cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
        END IF;
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
	
	IF cSISTEMACUENTA = 'CAPTACION' THEN
	IF pNumRegistro = 0 THEN
		DELETE FROM "informix".si_tempomovs WHERE ejecutivosif = cID_USUARIOC AND no_cuenta = cNUMCUENTA;
        SET ISOLATION TO DIRTY READ;
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

		SELECT valor
		INTO cconsmovhisold3
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'vfechconmovhisold3';
		
		SELECT valor
		INTO cconsmovhisold4
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechaIniMovhisOld4';
		
		LET iAbierto = 1;
		IF dPERIODOF = TODAY THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movdia MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt = dPERIODOF AND MO.empresa='001' AND MO.cuenta = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
						
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;

		IF (dPERIODOI < TODAY AND dPERIODOF >= cconsmovhis) THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movhis MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
						
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;
		
		IF (dPERIODOI < cconsmovhis AND dPERIODOF >= cconsmovhisold) THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movhis_old MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
						
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;
		
		IF (dPERIODOI < cconsmovhisold AND dPERIODOF >= cconsmovhisold2) THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movhis_old2 MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;

		SET ISOLATION TO DIRTY READ;
			SELECT {+INDEX (bdicheq:sc_maechq idx_sc_maechq)} NVL(COUNT(cuenta),0) 
			INTO iExisteCta
			FROM bdicheq:sc_maechq 
			WHERE cuenta  = cNUMCUENTA
			AND producto IN ('1200', '9901', '1600', '2200', '2600');
		
		IF iExisteCta = 0 THEN
			IF (dPERIODOI < cconsmovhisold2 AND dPERIODOF >= cconsmovhisold3) THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH WITH HOLD
				SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
				INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
				FROM bdicheq:"informix".sc_movhis_old3 MO
				LEFT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
				
				LET iCont=iCont+1;
				
				INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				END FOREACH;
			END IF;
			IF (dPERIODOI < cconsmovhisold3 AND dPERIODOF >= cconsmovhisold4) THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH WITH HOLD
				SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
				INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
				FROM bdicheq:"informix".sc_movhis_old4 MO
				LEFT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
				
				LET iCont=iCont+1;
				
				INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				END FOREACH;
			END IF;
		END IF;
		
		IF TRIM(SUBSTRING(cNUMCUENTA FROM 1 FOR 1)) = '8' THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fecha_alt as fech_alt,extend(MO.fech_hor_fin,HOUR to FRACTION(3)),MO.transacc,TR.descripcion,MO.monto,DECODE(MO.tpo_mov,"D","A","C","C"),
			MO.sdo_cuenta_origen,MO.referencia,'','',MO.secuencia,'','TRANSFER',''
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bditransfer:tf_success_transac  MO
			LEFT JOIN bditransfer:tf_cat_transac_mps TR
			ON MO.transacc = TR.transac
			WHERE MO.cuenta = cNUMCUENTA
			AND MO.fecha_alt BETWEEN dPERIODOI AND dPERIODOF
			AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
			AND MO.fecha_alt < to_date('20/03/2015','%d/%m/%Y')
			
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;
		
		IF iAbierto = 1 THEN
			LET iAbierto = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
		
		LET iCont = 0;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion codret, ejecutivosif, no_cuenta, fech_alt, 
			fech_hor, transacc, descripcion, monto_tot, naturaleza, sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_tarjeta, usuario, 
			referencia_23
			INTO cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
			FROM "informix".si_tempomovs
			WHERE ejecutivosif = cID_USUARIOC AND no_cuenta = cNUMCUENTA
			ORDER BY fech_alt DESC,fech_hor DESC
			
			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			
			
			LET iCont=iCont+1;
			
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH RESUME;
		END FOREACH;
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
	ELSE
		FOREACH
			SELECT {+INDEX (bdinteg:"informix".si_tempomovs idx_tempomovs)} SKIP pNumRegistro FIRST pRecuperacion codret, ejecutivosif, no_cuenta, fech_alt, 
			fech_hor, transacc, descripcion, monto_tot, naturaleza, sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_tarjeta, usuario, 
			referencia_23
			INTO cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
			FROM "informix".si_tempomovs
			WHERE ejecutivosif = cID_USUARIOC AND no_cuenta = cNUMCUENTA
			ORDER BY fech_alt DESC,fech_hor DESC
			
			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			
			
			LET iCont=iCont+1;
			
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
		END FOREACH;
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF
	END IF;
		
	ELIF cSISTEMACUENTA = 'CREDITO' THEN
		SET ISOLATION TO DIRTY READ;
		SELECT NVL(COUNT(num_credito),0) 
		INTO iExisteCta
		FROM bdicred:sd_maecred
		WHERE empresa = '001' AND num_credito = cNUMCUENTA;		

		IF iExisteCta > 0 THEN
			FOREACH
				SELECT SKIP pNumRegistro FIRST pRecuperacion {+INDEX (bdicred:sd_movdia mov4)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO          
				cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movdia MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			UNION
				SELECT {+INDEX (bdicred:sd_movhis inx_movhis4)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				FROM bdicred:sd_movhis  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END                    
			ORDER BY MO.secuencia DESC

			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			  
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
 

				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
			END IF;

			END FOREACH;
		ELSE
			FOREACH
				SELECT SKIP pNumRegistro FIRST pRecuperacion MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO          
				cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movdiacrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			UNION
				SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				FROM bdicred:sd_movhiscrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			ORDER BY MO.secuencia DESC

			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			  
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

				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
			END IF;

			END FOREACH;
		END IF;
						
		IF iCont = 0 AND pNumRegistro=0 THEN
		   LET cCodRet = '00039';
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
						cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		ELIF iCont = 0 THEN
		   LET cCodRet = '1001';
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
						cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF
	ELIF cSISTEMACUENTA = 'INVERSIONES' THEN
	 SET ISOLATION TO DIRTY READ;
	  FOREACH
		   SELECT SKIP pNumRegistro FIRST pRecuperacion     
		   MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,MO.usuario,MO.num_serial
		   INTO
		   dFecha,dHora,cFolio,cTransaccion,cD_Transaccion,mMonto,cReversados,dPeriodoI_1,dPeriodoF_1,sNumSecuencia,cSucursal,cUsuario,sNUMSERIAL
		   FROM bdinvers:sv_maeinv MC
		   LEFT JOIN bdinvers:sv_movdia MO
		   ON MC.cuenta = MO.cuenta
		   LEFT JOIN bdinteg:si_transacc TR
		   ON MO.transacc = TR.numero 
		   WHERE MO.cuenta = cNUMCUENTA
		   AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
		AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
		AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
		AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
		   UNION
		   SELECT MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,MO.usuario,MO.num_serial
		   FROM bdinvers:sv_maeinv MC
		   LEFT JOIN bdinvers:sv_movhis MO
		   ON MC.cuenta = MO.cuenta
		   LEFT JOIN bdinteg:si_transacc TR
		   ON MO.transacc = TR.numero 
		   WHERE MO.cuenta = cNUMCUENTA
		   AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
		AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
		AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
		AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
		ORDER BY MO.num_serial DESC

		LET iCont=iCont+1;    
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
			   
	  END FOREACH;

	  IF iCont = 0 THEN
	  LET cCodRet = '1001';
		   RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	  END IF
	END IF
END

END PROCEDURE

DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques, para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 09-02-2012",
"ACTUALIZO: Victor Hugo Sánchez M.",
"MODIFICACION: Se agregaron los parametros empleado,sucursal e importe para filtrar movimientos",
"FECHA: 04/07/2012",
"ACTUALIZO: Oscar Flores Conde (M-Finis Soluciones y Servicios Financieros)",
"MODIFICACION: Se agregaron el parametro de entrada para filtrar los movimientos reversados, se agrega en los parametros de salida la referencia a 23 posiciones",
"FECHA: 02/12/2013",
"BD    : bdinteg",
"VER   : 3.0";

CREATE PROCEDURE "informix".sp_obtienecorreos(pTipo CHAR(1),pRegistros INTEGER, pNumcte CHAR(20), pCorreo CHAR(100), pValida CHAR(3))
	RETURNING 	CHAR(5)  AS cCodRet,
				CHAR(20) AS cNumCte, 
				CHAR(100) AS cEmail;

				
--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cNumCte 		CHAR(20);
DEFINE cEmail 		CHAR(100);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cNumCte 		= '';
LET cEmail 			= '';

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','';
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/cristo/sp_obtienecorreos.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	
		
	IF 	pTipo = '1' THEN-- Obtener los correos a validar
		IF (pRegistros IS NULL OR pRegistros = 0) THEN
			LET cCodRet = '00001'; --Valor de parametros nulos o no valido
			RETURN cCodRet, cNumCte,cEmail;
		ELSE
			
			FOREACH
				 
				SELECT {+MULTI_INDEX("informix".si_correos)} FIRST pRegistros numcte, correo_elec INTO cNumCte, cEmail
				FROM "informix".si_correos
				WHERE status_correo ='A' AND valida_correo IS NULL
				ORDER BY fecha_hora DESC
				
				RETURN cCodret , TRIM(cNumCte), TRIM(cEmail) WITH RESUME;
				
			END FOREACH;	
			
		END IF;
	ELIF pTipo = '2' THEN  -- Actualizar registro de correo validado por webservice strikeiron
		IF ((pNumcte IS NULL OR pNumcte = '') OR (pValida IS NULL OR pValida = '')) THEN
			LET cCodRet = '00001'; --Valor de parametros nulos o no valido
		ELSE
			
			IF pValida IN ('200','210','220') THEN -- Se valida que el codigo de retorno indique correo valido
				UPDATE "informix".si_correos SET valida_correo = pValida, valido='1',fecha_valida = current WHERE numcte = pNumcte AND status_correo='A' AND TRIM(correo_elec)=TRIM(pCorreo);
			ELSE
				UPDATE "informix".si_correos SET valida_correo = pValida, valido='0',fecha_valida = current WHERE numcte = pNumcte AND status_correo='A' AND TRIM(correo_elec)=TRIM(pCorreo);
			END IF;
				
			
		END IF;
		
		RETURN cCodRet, cNumCte,cEmail; 
	ELSE
		LET cCodRet = '00002';	--Valor de parametro pTipo no valido
		RETURN cCodRet, cNumCte,cEmail;
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Obtiene los correo aun sin validar para ser evaluados por webservice strikeiron',
'permite realizar la actualizaciÃÂ³n de los campos valida_correo y valido',
'AUTOR : Cristo Lugo',
'FECHA : 27-05-2014',
'VERSION: 20140527.1000',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_detalle_boletos (pClaveSort CHAR(5), pFechaActual DATE)
RETURNING CHAR (5) AS Codigo, CHAR(5) AS Clave_Sorteo, CHAR (80) AS Mensaje;

--- DECLARACION DE VARIABLES

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
	DEFINE vconsecutivo 	INTEGER;
    DEFINE vCodret          CHAR(5);
    DEFINE vCveSorteo       CHAR(5);
    DEFINE vMensaje         CHAR(80);

    DEFINE vF_Proceso       DATE;
    DEFINE vEmpresa         CHAR(3);
    DEFINE vCve_Sorteo      CHAR(5);
    DEFINE vF_ini           DATE;
    DEFINE vF_Fin           DATE;

    DEFINE vNumcte          CHAR(10);
	  DEFINE iNumcte          INTEGER;

    DEFINE vCve_Sort        CHAR(5);
    DEFINE vBoleto_ini      INT8;
    DEFINE vBoleto_Fin      INT8;
    DEFINE vF_registro      DATETIME YEAR TO SECOND;
    DEFINE vNumCliente      CHAR(10);
    DEFINE vEstado          INTEGER;
    DEFINE vSucursal        CHAR(4);
    DEFINE vArea            CHAR(1);
    DEFINE vCaja            INTEGER;
    DEFINE vTipomov         CHAR(10);
    DEFINE vFoliosuc        CHAR(16);
    DEFINE vImporte         MONEY;
    DEFINE vTel1            CHAR(10);
    DEFINE vTel2            CHAR(13);
    DEFINE vNombre          CHAR(45);
    DEFINE vCiudad          CHAR(20);
    DEFINE vDomicilio       CHAR(50);
	DEFINE vEntfed		    CHAR(25);
    DEFINE vFecha           DATE;
    DEFINE vOrigen          CHAR(10);
    DEFINE vSecuencia       INTEGER;
    DEFINE vLimite          INTEGER;
    DEFINE vContador        INTEGER;
    DEFINE vContSecuencia   INTEGER;

    DEFINE cCodRet          CHAR(3);
    DEFINE v_Valor          CHAR(5);
	  --DEFINE vrowid       	  INTEGER;
	  DEFINE vCuentaBoletos   INTEGER;
	  DEFINE vCuentaEmpleados INTEGER;


--- INICIALIZACION DE VARIABLES

    LET sql_err         = 0;
    LET isam_err        = 0;
    LET vCodret         = '00000';
    LET vCveSorteo      = pClaveSort;
    LET vMensaje        = 'El proceso concluyÃ³ exitosamente';

    LET vF_Proceso      = '';
    LET vEmpresa        = '001';
    LET vCve_Sorteo     = '0';
    LET vF_ini          = '';
    LET vF_Fin          = '';

    LET vNumcte         = '';

    LET vCve_Sort       = '';
    LET vBoleto_ini     = '';
    LET vBoleto_Fin     = '';
    LET vF_registro     = '';
    LET vNumCliente     = '';
    LET vEstado         = '';
    LET vSucursal       = '';
    LET vArea           = '';
    LET vCaja           = '';
    LET vTipomov        = '';
    LET vFoliosuc       = '';
    LET vImporte        = 0.00;
    LET vTel1           = '';
    LET vTel2           = '';
    LET vNombre         = '';
    LET vCiudad         = '';
    LET vDomicilio      = '';
	LET vEntfed			= '';
    LET vFecha          = '';
    LET vOrigen         = '';
    LET vSecuencia      = '';
    LET vLimite         = 0;
    LET vContador       = 0;
    LET vContSecuencia  = 1;
	LET vconsecutivo 	= 1;

    LET cCodRet          = '';
    LET v_Valor          = '';
	  --LET vrowid      	   = 0;
	  LET iNumcte      	   = 0;
	  LET vCuentaBoletos   = 0;
	  LET vCuentaEmpleados = 0;



     --****************************************************************
     -- Creado por RaÃºl RamÃ­rez    01/Septiembre/2010
     -- Proceso para traducir rangos de boletos a un detalle de boletos
     --****************************************************************


BEGIN

    ON EXCEPTION SET sql_err

        IF sql_err <> 0  THEN
            LET vCodret   = sql_err;
            LET vCodret   = '00045';
            LET vMensaje  = 'ERROR EN LA EJECUCION';
            RETURN vCodret, vCveSorteo, vMensaje;        -- Termina proceso del SP
        END IF;
    END EXCEPTION;
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = vCveSorteo AND pFechaActual -1 BETWEEN  f_ini AND f_fin AND flag_sort = 2) THEN
        --SET DEBUG FILE TO "/ids10_uc9/raul/sorteo/sp_detalle_boletos.out";
        --TRACE ON;

				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				LET vF_Proceso = pFechaActual -1;

				SELECT {+INDEX(si_param ix_si_param)} valor
				INTO v_Valor
				FROM bdinteg:si_param
				WHERE empresa = vEmpresa
				AND cod_param = 118;

				SELECT {+INDEX (si_sorteo idx_si_sorteo2)} cve_sorteo, f_ini, f_fin
				INTO vCve_Sorteo, vF_ini, vF_Fin
				FROM bdinteg:si_sorteo
				WHERE cve_sorteo = v_Valor;


				IF (v_Valor IS NULL OR v_Valor = '') OR -- Valida clave sorteo vigente
				   (v_Valor <> pClaveSort) THEN
					 LET vCodret = '00040';
					 LET vMensaje = 'NO EXISTE SORTEO';
						RETURN vCodret, vCveSorteo, vMensaje;    -- Termina proceso del SP
				ELSE
					IF (vF_ini IS NULL OR vF_ini = '') OR      -- Valida fecha sorteo vigente
					   (vF_Fin IS NULL OR vF_Fin = '') OR
					   (vF_Proceso NOT BETWEEN vF_ini AND vF_Fin) THEN
						  LET vCodret = '00042';
						  LET vMensaje = 'SORTEO NO ESTA VIGENTE?';
						RETURN vCodret, vCveSorteo, vMensaje;    -- Termina proceso del SP
					END IF;
				END IF;

				-- BGM 11-Nov-2010: Se agrega depuraciÃ³n de tabla si_boleto_temp
				TRUNCATE si_boleto_temp;
				
				EXECUTE PROCEDURE "informix".sp_movtos_reversados ('001')
						INTO cCodRet;
				
				--FOREACH

					---SELECT {+INDEX (si_movreversados idx_si_movrever)} empresa, fecha_mov, folio_suc
				--	SELECT {+FULL} empresa, fecha_mov, folio_suc
				--	INTO vEmpresa, vFecha, vFoliosuc
				--	FROM bdinteg:si_movreversados
				--	WHERE empresa = vEmpresa
				--	AND folio_suc <> ''
					
				--	IF EXISTS (SELECT {+INDEX (bdinteg:si_boleto idx_si_boleto)} foliosuc 
				--	           FROM bdinteg:si_boleto 
				--		         WHERE cve_sorteo = vCve_Sorteo
				--          AND foliosuc = vFoliosuc
				--           AND fecha = vFecha) THEN
						
				--			UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist2)} bdinteg:si_boleto_hist
				--			SET estado = '101'
				--			WHERE cve_sorteo = vCveSorteo
				--			AND   foliosuc = vFoliosuc
				--			AND   fecha = vFecha;

							--DELETE {+INDEX (si_boleto idx_si_boleto)} FROM bdinteg:si_boleto
							--WHERE cve_sorteo = vCveSorteo
							--AND   foliosuc = vFoliosuc
							--AND   fecha = vFecha;
				--	END IF;
					
				--END FOREACH;
				
				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist2)} bdinteg:si_boleto_hist set estado = 101 
				WHERE foliosuc in (SELECT folio_suc FROM si_movreversados) 
				AND fecha = vF_Proceso;
					
				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist3)} bdinteg:si_boleto_hist set estado = 101 
				WHERE numcte in (SELECT numcte FROM si_syssorteo_emp)
				AND fecha = vF_Proceso;
				
				--SELECT {+FULL} COUNT(*) into vCuentaBoletos FROM si_boleto;
				--SELECT {+FULL} COUNT(*) into vCuentaEmpleados FROM si_syssorteo_emp;

				--IF vCuentaBoletos <= vCuentaEmpleados THEN
				
				--	FOREACH
					
				--		SELECT {+FULL} numcte
				--		INTO iNumcte
				--		FROM bdinteg:si_boleto
						
				--		IF EXISTS (SELECT {+INDEX (si_syssorteo_emp idx_si_syssorteo_emp)} numcte
				--				FROM si_syssorteo_emp
				--				WHERE tipo IN (2 , 4) 
				--                                    AND status = 'A'
				--                                    AND numcte = iNumcte) THEN
								
				--				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist4)} si_boleto_hist
				--				SET estado = '101'
								---WHERE numcte::INT = iNumcte;
				--				WHERE numcte = iNumcte;
				--		END IF;
					
				--	END FOREACH;
					
				--ELIF vCuentaBoletos > vCuentaEmpleados THEN
				
				--	FOREACH
				
				--		SELECT {+FULL} numcte
				--		INTO iNumcte  
				--		FROM si_syssorteo_emp
						
				--		IF EXISTS (SELECT {+INDEX (bdinteg:si_boleto idx_idx_si_boleto6)} numcte 
				--				FROM bdinteg:si_boleto 
								--WHERE numcte::INT = iNumcte) THEN
				--				WHERE numcte = iNumcte) THEN
							
				--				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist4)} bdinteg:si_boleto_hist
				--				SET estado = '101'
								---WHERE numcte::INT = iNumcte;
				--				WHERE numcte = iNumcte;
				--		END IF;
							
				--	END FOREACH;
					
				--END IF;
				
				FOREACH cursor_inserta WITH HOLD FOR
								
						SELECT {+INDEX (si_boleto_hist idx_si_boleto_hist2)}
								cve_sorteo, boleto_ini, boleto_fin, f_registro, numcte, estado, sucursal, area, caja, tipomov,
								foliosuc, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia, ent_fed
						INTO  vCve_Sort, vBoleto_Ini, vBoleto_Fin, vF_registro, vNumCliente, vEstado, vSucursal, vArea, vCaja, vTipomov,
						  vFoliosuc, vImporte, vTel1, vTel2, vNombre, vCiudad, vDomicilio, vFecha, vOrigen, vSecuencia, vEntfed
						FROM bdinteg:si_boleto_hist
						WHERE cve_sorteo =  vCveSorteo
						AND foliosuc <> ''
						AND fecha = vF_Proceso
						AND estado = 2
						
						LET vLimite = vBoleto_Fin;
						BEGIN WORK;
							FOR vContador = vBoleto_Ini TO vLimite
								INSERT INTO si_boleto_temp(cve_sorteo, boleto, f_registro, numcte, estado, sucursal, area, caja, tipomov,
											foliosuc, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia, ent_fed, consecutivo)
								VALUES (vCve_Sort, vContador, vF_registro, vNumCliente, vEstado, vSucursal, vArea, vCaja, vTipomov,
										vFoliosuc, vImporte, vTel1, vTel2, vNombre, vCiudad, vDomicilio, vFecha, vOrigen, vContSecuencia, vEntfed, vconsecutivo);
								LET vContSecuencia = vContSecuencia + 1;
								LET vconsecutivo = vconsecutivo +1;
							END FOR

							LET vContSecuencia = 1;
							COMMIT WORK;                           
						   
				END FOREACH;

			  -- BGM 11-Nov-2010: Se agrega depuraciÃ³n de tabla si_boleto;
				TRUNCATE si_boleto;
				TRUNCATE si_movreversados;
	
	ELSE
		LET vCodret = "22222";
        LET vMensaje = "Â¡EL SORTEO NAVIDEÃO NO ESTA ACTIVO!";
	END IF;	
		  
END
    RETURN vCodret, vCveSorteo, vMensaje;

END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACIÃN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_respaldo_boletos (pClaveSort CHAR(5), pdFechaRespaldo DATE)

    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,
              CHAR(1)  AS Reverso,
              CHAR(25) AS StorePro;              


   DEFINE v_codigo_retorno	CHAR(5);
   DEFINE v_mensaje	  	    CHAR(80);
   DEFINE v_reverso         CHAR(1);
   DEFINE v_store_pro       CHAR(25);

   DEFINE vi_valor      CHAR (50);

   DEFINE vsqlerr      INTEGER; 
   DEFINE pdrepositorio CHAR (60);
   

    DEFINE vsArchTemporal CHAR (15);
	DEFINE vsNomArchivo CHAR (40);
	DEFINE vsSQL CHAR (1100);
	DEFINE vsSQL1 CHAR (200);
	DEFINE vsSQL2 CHAR (700);
	DEFINE vsSQL3 CHAR (200);


       -- SET debug file TO "/ids10_1uc5/fmartinez_2/sorteo/batch_30nov/pba1/respalda_boletos.out";
       -- TRACE ON;

	
	LET vsArchTemporal = '';
	LET vsNomArchivo = '';
	LET vsSQL = '';
	LET vsSQL1 = '';
	LET vsSQL2 = '';
	LET vsSQL3 = '';



-- DECLARACION DE VARIABLES
             LET v_codigo_retorno = "00000";
             LET v_mensaje = "Proceso Inicia Correctamente...";
             LET v_reverso = '0';
             LET v_store_pro = 'sp_respaldo_boletos';
     
        	 LET vsNomArchivo = 'RESPALDOSORTEO_' || SUBSTRING (pdFechaRespaldo FROM 9 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 1 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 4 FOR 2) || '.unl' ;


            SET ISOLATION TO dirty READ;
            SET LOCK MODE TO wait 3;

 BEGIN
   ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exception, Verifique Datos SQL!";
            LET v_reverso = '1';         
            LET v_store_pro = 'sp_respalda_boletos';
         RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
        END IF;
   END EXCEPTION;
   
   /*VALIDA QUE LA BANDERA DEL CONCURSO 00002 SEA 2 Y ESTE ACTIVO EL SORTEO*/
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = pClaveSort AND pdFechaRespaldo BETWEEN  f_ini AND f_fin AND flag_sort = 2) THEN
        
		-- FMV 16-DIC-2010: La ruta del archivo serÃ¡ la misma
				 SELECT {+index (si_param 194_429)}  
						   valor
				   INTO vi_valor
				   FROM si_param
				   WHERE empresa = '001'
					 AND cod_param = '112';
					IF NOT EXISTS (SELECT {+index (si_param 194_429)} valor
									 FROM si_param
									WHERE empresa = '001' AND cod_param = '112')
					  THEN
							LET v_codigo_retorno = "00042";
							LET v_mensaje = "Error: No Existe ruta de deposito!";
						RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
					END IF;
					LET pdrepositorio = vi_valor;


		 
			LET vsArchTemporal = 'temporal.txt';
					LET vsNomArchivo = 'BACKUPSORTEO_' || SUBSTRING (pdFechaRespaldo FROM 9 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 1 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 4 FOR 2) || '.txt' ;

					--GENERA EL ARCHIVO DE INTERCAMBIO
					LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(pdrepositorio) || '/' || TRIM(vsArchTemporal) || ' DELIMITER ' || '''|''';



					LET vsSQL2 = "SELECT {+ INDEX (bdinteg:si_boleto)idx_si_boleto_clte} * FROM bdinteg:si_boleto;";


					LET vsSQL3 = ' " > '|| TRIM(pdrepositorio) || '/control_reporte.sql';
					LET vsSQL1 = TRIM(vsSQL1);
					LET vsSQL3 = TRIM(vsSQL3);
					LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

				   IF ( vsSQL <> '' ) THEN
						SYSTEM vsSQL ;
					--Permiso para la creacion de archivo.
						LET vsSQL = '' ;
						LET vsSQL = 'chmod 666 ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
						LET vsSQL = '' ;

						LET vsSQL = 'dbaccess BdInteg ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
						SYSTEM vsSQL ;
						--Borra el archivo de control.
						LET vsSQL = '' ;
						LET vsSQL = 'rm ' || TRIM(pdrepositorio) || '/control_reporte.sql';
						SYSTEM vsSQL ;

						--Elimina el caracter delimitador '?'.
						LET vsSQL = '' ;
						LET vsSQL =  "sed 's/|$//g' " || TRIM(pdrepositorio) || '/' || TRIM (vsArchTemporal) || " > " || TRIM(pdrepositorio) || '/' ||
						TRIM (vsNomArchivo);
						SYSTEM vsSQL;

						--Borra el archivo de control.
						LET vsSQL = '' ;
						LET vsSQL = 'rm ' || TRIM(pdrepositorio) || '/' || TRIM (vsArchTemporal);
						SYSTEM vsSQL ;

					LET v_codigo_retorno = "00000";
					LET v_mensaje = 'RESPALDO EN ' || TRIM (vsNomArchivo) || ' FINALIZADA OK';					LET v_reverso = '1';         
					LET v_store_pro = 'sp_respalda_boletos';
				   RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;

					END IF;
	ELSE
		LET v_codigo_retorno = "22222";
        LET v_mensaje = "Â¡EL SORTEO NAVIDEÃO NO ESTA ACTIVO!";
        LET v_reverso = '1';
        LET v_store_pro = v_store_pro;     
	
    END IF;
 END;   --begin        
      RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACIÃN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG',
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACIÃN: 10 NOVIEMBRE 2016',
'OBJETIVO: EN LA LINEA 135 SE CAMBIA EL MENSAJES DE SALIDA',
'          PARA CUANDO SEA EXITOSA QUE CONTROL TOME LA ',
'          LINEA CORRECTA Y NO SE MUEVA CUANDO ESTE EL',
'          SORTEO ACTIVO Ã INACTIVO',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_actualiza_aprcf()
				returning CHAR(5) AS Cod_Retorno,INTEGER as Idreg;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE sRetCod          CHAR(5);
DEFINE Iid				INTEGER;
DEFINE IidErr			INTEGER;

--SISTEMA DE CUENTA 01 VARIABLES
DEFINE sAP_paterno     CHAR(26);
DEFINE sAP_materno     CHAR(26);
DEFINE sAP_nombre1     CHAR(26);
DEFINE sAP_nombre2     CHAR(26);
DEFINE sAP_fecha_nac   CHAR(10);
DEFINE sAP_rfc         CHAR(13);
DEFINE sAP_dia          CHAR(2);
DEFINE sAP_mes          CHAR(2);
DEFINE sAP_year         CHAR(4);
DEFINE sAP_fecnac       CHAR(10);

LET sAP_paterno        = '';
LET sAP_materno        = '';
LET sAP_nombre1        = '';
LET sAP_nombre2        = '';
LET sAP_fecha_nac      = '';
LET sAP_rfc            = '';
LET sAP_dia            = '';
LET sAP_mes            = '';
LET sAP_year           = '';
LET sAP_fecnac         = '';
LET Iid				   =0;
LET sRetCod          	="99999";
LET cCodRet 			= "00000";
LET IidErr				=0;




BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,IidErr;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/VH/PM/sp_cnsif_consnumcte.out";
	--TRACE ON;
		

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	FOREACH
		SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_status_valua)} id,ap_apell_paterno,ap_apell_materno,ap_nombre1,ap_nombre2,ap_fecha_nac INTO Iid,sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,sAP_fecnac FROM si_solicitud_movil
		WHERE status_valua IS NOT NULL AND ap_rfc IS NULL AND ap_fecha_nac IS NOT NULL and length(ap_fecha_nac)=10

		 LET IidErr=Iid;
		 LET sAP_dia = "";
		 LET sAP_mes = "";
		 LET sAP_year = "";
		 LET sAP_dia = sAP_fecnac[1,2];
		 LET sAP_mes = sAP_fecnac[4,5];
		 LET sAP_year = sAP_fecnac[7,10];

		 IF LENGTH(sAP_year)<=2 THEN
			LET sAP_year="19"||sAP_year;
		 END IF;
		 LET sAP_fecnac ="";
		 LET sAP_rfc="";
		 LET sAP_fecnac = TRIM(sAP_mes)||''||TRIM(sAP_dia)||''||TRIM(sAP_year);

		 CALL sp_calcularrfc(sAP_paterno,sAP_materno,sAP_nombre1||' '||sAP_nombre2,sAP_fecnac)
		 RETURNING sRetCod, sAP_rfc;
		 IF sRetCod = '00000' THEN
			UPDATE "informix".si_solicitud_movil set ap_rfc=sAP_rfc where id=Iid;
		 END IF;
		LET sAP_paterno        = '';
		LET sAP_materno        = '';
		LET sAP_nombre1        = '';
		LET sAP_nombre2        = '';
		LET sAP_fecnac      = '';
	END FOREACH;


	RETURN cCodRet,IidErr;
END
END PROCEDURE;