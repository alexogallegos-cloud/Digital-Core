CREATE PROCEDURE "informix".sp_obtener_10dias
(
pFecha	DATE
)
RETURNING
	CHAR(6)		AS cod_ret,
	DATE		AS fecha_10dias
	
	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);
	DEFINE dtFecha10		DATE;
	DEFINE iContador		SMALLINT;
	
	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";
	LET dtFecha10			= NULL;
	LET iContador			= 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dtFecha10;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--  SET DEBUG FILE TO "/informix/PORTABILIDAD_NOMINA/sp_obtener_10dias.out";
	--  TRACE ON;
	
	WHILE dtFecha10 IS NULL
	
		LET pFecha = pFecha + 1 UNITS DAY;
		
		IF NOT EXISTS(SELECT fecha FROM bdinteg:"informix".si_feriado 
						WHERE fecha = pFecha AND empresa = '001'AND laborable = 'N') THEN
			
			IF WEEKDAY(pFecha) IN (1,2,3,4,5) THEN
				LET iContador = iContador + 1;
			END IF
			
		END IF
		
		IF iContador = 10 THEN
			LET dtFecha10 = pFecha;
			EXIT WHILE;
		END IF
		
	
	END WHILE
	
	
	RETURN cCodRet, dtFecha10;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: ',
'BD: bdinteg', 
'AUTOR: Alex Villela ',
'FECHA: septiembre 2015';

CREATE PROCEDURE "informix".sp_cnsif_consultamovtosdiarioscta3_pba(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20), pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2), pNumRegistro INTEGER,pRecuperacion INTEGER)

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
                

	SET ISOLATION TO COMMITTED READ LAST COMMITTED;

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

CREATE PROCEDURE "informix".sp_altamasivaempnet_busca_pba()
RETURNING CHAR(5);
    
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    
    DEFINE vcCodEmpresa     CHAR(3);
    DEFINE vcNombreArchivo  CHAR(30);
    DEFINE vcNumCte         CHAR(9);
    DEFINE vcCodRetAlta     CHAR(5);
    
    LET viSqlErr    = 0;
    LET viIsamErr   = 0;
    LET vcDescErr   = '';
    LET vcCodRet    = '000';
    LET vcCodRet2   = '';
    LET vcCodRet3   = '';
    
    LET vcCodEmpresa    = '';
    LET vcNombreArchivo = '';
    LET vcNumCte        = '';
    LET vcCodRetAlta    = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_busca.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_busca.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            RETURN vcCodRet;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // PROCESA LOS ARCHIVOS QUE ESTEN PENDIENTES
    FOREACH WITH HOLD 
        SELECT alta.cod_empresa, alta.nombre_archivo, emp.numcte
          INTO vcCodEmpresa, vcNombreArchivo, vcNumCte
          FROM bdinteg:si_altamasivaempnet_ctrl alta,
               bdicheq:sc_nominaempresas emp
         WHERE alta.cod_empresa = emp.codigo
           AND alta.status = '0'
           
        CALL sp_altamasivaempnet_procesa( vcCodEmpresa, vcNumCte, vcNombreArchivo )
        RETURNING vcCodRetAlta;
    END FOREACH;
    
    RETURN vcCodRet;
    
    END;
    
END PROCEDURE;