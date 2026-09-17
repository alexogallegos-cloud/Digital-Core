CREATE PROCEDURE "informix".sp_cnsif_consultamovtosdiarioscta4(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20), pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2), pNumRegistro INTEGER,pRecuperacion INTEGER)
				returning 	CHAR(5)  AS Cod_Retorno,
							DATE     AS Fecha,
							DATETIME HOUR to FRACTION(3) AS Hora,
							CHAR(4)  AS CveTransaccion,
							CHAR(120) AS Desc_Transaccion,
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
DEFINE cD_Transaccion     CHAR(120);
DEFINE mMonto               MONEY(14,2);
DEFINE cNaturaleza          CHAR(1);
DEFINE mSaldo                MONEY(14,2);
DEFINE cReferencia           CHAR(40);
DEFINE cRfcComer           CHAR(10);
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
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     CHAR(3);
DEFINE cCodfun          CHAR(3);
DEFINE cCodref          INTEGER;
DEFINE iExisteCta       INT;
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
--VARIABLES DE PAGINACION
LET iCont       = 0;
LET pEmpresa   = '001';
LET cCodfun               ='';
LET cCodref               =0;
LET  iExisteCta = 0;
LET  cRfcComer = '';

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
	END EXCEPTION;
                
     --SET DEBUG FILE TO "/informix/CHVN/sp_cnsif_consultamovtosdiarioscta4.out";
     --TRACE ON;
              
	IF cID_USUARIOC = '' OR cID_FUNCIONC = '' OR cNUMCUENTA  = '' OR dPERIODOI IS NULL OR dPERIODOF IS NULL OR cSISTEMACUENTA = '' THEN
		LET cCodRet = "00036";
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF;

    IF pNumRegistro<0 THEN
		LET cCodRet='00098';
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;                        
    ELSE
        IF pRecuperacion<=0 THEN
			LET cCodRet='00098';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
        END IF;
    END IF; 
	IF cSISTEMACUENTA <> 'CAPTACION' AND cSISTEMACUENTA <> 'CREDITO'  AND cSISTEMACUENTA <> 'INVERSIONES' THEN
		LET cCodRet = "00037";
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
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
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF;
    -- TERMINA VALIDACION
     IF cSISTEMACUENTA = 'CAPTACION' THEN
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
	
		SET ISOLATION TO DIRTY READ;
		FOREACH               
			SELECT SKIP pNumRegistro FIRST pRecuperacion MO.fech_alt,MO.fech_hor,MO.transacc,TRIM(NVL(TR.descripcion,""))||" "||TRIM(NVL(MO.referencia,"")) AS descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,
			MO.referencia,MO.cancelad, MO.sucursal,MO.folio_suc, dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:sc_movdia MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = 'S'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' 
			AND MO.cuenta = cNUMCUENTA
		UNION
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TRIM(NVL(TR.descripcion,""))||" "||TRIM(NVL(MO.referencia,"")) AS descripcion ,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
			FROM bdicheq:sc_movhis MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = 'S'
			WHERE MO.fech_alt >= cconsmovhis
			AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
			AND MO.empresa = TR.empresa
			AND MO.cuenta = cNUMCUENTA
		UNION
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TRIM(NVL(TR.descripcion,""))||" "||TRIM(NVL(MO.referencia,"")) AS descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
					MO.sucursal,MO.folio_suc,dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
			FROM bdicheq:sc_movhis_old  MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = 'S'
			WHERE MO.fech_alt >= cconsmovhisold
			AND MO.fech_alt < cconsmovhis
			AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
			AND MO.empresa='001'
			AND MO.cuenta = cNUMCUENTA
		ORDER BY MO.num_serial, MO.fech_alt DESC

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
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
		END FOREACH;

		IF iCont = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
			
     ELIF cSISTEMACUENTA = 'CREDITO' THEN
	 
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion {+INDEX (bdicred:sd_movdia mov4)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,
			MO.nro_tarjeta,MO.folio_suc,MO.transacc_suc,TR.descripcion,MO.rfc_comer,
			MO.referencia, MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
			INTO          
			cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cRfcComer,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
			dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
			FROM bdicred:sd_movdia MO
			LEFT JOIN bdicred:sd_transfun TR
			ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
			RIGHT JOIN bdinteg:si_transacc TS
			ON TS.empresa = '001'
			AND TS.numero = TR.transacc
			AND TS.se_emite_edocta = 'S'
			WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
		UNION
			SELECT {+INDEX(bdicred:"informix".sd_movhis inx_movhis4)}
			MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,MO.transacc_suc,TR.descripcion,MO.rfc_comer,
			MO.referencia,MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
			FROM bdicred:sd_movhis MO
			LEFT JOIN bdicred:sd_transfun TR
			ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
			RIGHT JOIN bdinteg:si_transacc TS
			ON TS.empresa = '001'
			AND TS.numero = TR.transacc
			AND TS.se_emite_edocta = 'S'
			WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
/*			UNION
			   SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
			MO.transacc_suc,TR.descripcion,MO.rfc_comer,
			MO.referencia,MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
			   FROM bdicred:sd_maecredcrd MC
			   LEFT JOIN bdicred:sd_movdiacrd  MO
			   ON MC.num_credito = MO.num_credito
			   LEFT JOIN bdicred:sd_transfun TR
			   ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			   LEFT JOIN bdinteg:si_transacc TS
			   ON TR.transacc = TS.numero
			   WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA
			   AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
			   AND TS.se_emite_edocta = 'S'
			UNION
			   SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
			MO.transacc_suc,TR.descripcion,MO.rfc_comer,
			MO.referencia,MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
			   FROM bdicred:sd_maecredcrd MC
			   LEFT JOIN bdicred:sd_movhiscrd  MO
			   ON MC.num_credito = MO.num_credito
			   LEFT JOIN bdicred:sd_transfun TR
			   ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			   LEFT JOIN bdinteg:si_transacc TS
			   ON TR.transacc = TS.numero
			   WHERE MO.num_credito = cNUMCUENTA
			   AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
			   AND TS.se_emite_edocta = 'S'*/
		ORDER BY MO.secuencia DESC
			
			IF cReferencia is NULL THEN
				 if trim(cD_Transaccion) = "SU PAGO CON CHEQUE" then
                    LET cD_Transaccion = NVL(TRIM(cD_Transaccion),'') || " " || trim(cReferencia23);
                else
    				LET cD_Transaccion = NVL(TRIM(cD_Transaccion),'');
                end if;
			ELSE
				IF cReferencia[1,1] = "i" THEN
                   IF (cTransaccion in ('6800','6871','6873')) THEN
                       LET cD_Transaccion = TRIM(SUBSTRING(cReferencia FROM 18))||NVL(TRIM(cReferencia23),'');
				   ELIF (cTransaccion = '6901') THEN
							  LET cD_Transaccion =  NVL(TRIM(cD_Transaccion),'');	   							  	   							  							  	   
                   ELSE
                       LET cD_Transaccion = NVL(TRIM(SUBSTRING(cReferencia FROM 18)),'')
                                        || "  " ||
                                        NVL(TRIM(cRfcComer),'')
                                        || "  " ||
                                        NVL(TRIM(cReferencia23),'');
                   END IF

                   IF cD_Transaccion[1,1] = "i" THEN
                        LET cD_Transaccion = TRIM(SUBSTRING(cD_Transaccion FROM 18));
                   END IF

				ELSE
                    IF TRIM(cD_Transaccion) = "PAGO CORRESPONSAL COPPEL" THEN
                        LET cD_Transaccion = NVL(TRIM(cD_Transaccion),'')|| "  " ||TRIM(cReferencia);
                    ELSE
                        LET cD_Transaccion = NVL(TRIM(cD_Transaccion),'')|| "  " ||TRIM(cReferencia[1,16]);
                    END IF
				END IF
			END IF
			
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
                        
		IF iCont = 0 AND pNumRegistro=0 THEN
			LET cCodRet = '00039';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		ELIF iCont = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF
     END IF
END

END PROCEDURE

DOCUMENT
"AUTOR : CESAR HORACIO VELAZQUEZ NERIA",
"FUNCIONAMIENTO:Este sp realizara la busqueda de movimientos por cuenta para el kiosko de informacion",
"FECHA : 27-11-2014",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_depura_telefonos( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), INTEGER, INTEGER; 
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cDescErr     CHAR(50);
    DEFINE iTransacc    SMALLINT;
    DEFINE iContador    INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE cNumCte      CHAR(20);
    DEFINE iTipoTel     SMALLINT;
    DEFINE iMaxSec      SMALLINT;
    DEFINE iCuantos     SMALLINT;
    DEFINE cTelefono    CHAR(13);
    DEFINE iSecuencia   SMALLINT;
    DEFINE cExtension   CHAR(5);
    DEFINE iCarrier     SMALLINT;
    DEFINE iCanal       SMALLINT;
    DEFINE iContacto    SMALLINT;
    DEFINE cCofetel     CHAR(1);
    DEFINE dFecha       DATETIME YEAR TO SECOND;
    DEFINE cUser        CHAR(8);
    DEFINE cMovil       CHAR(1);
    DEFINE cStatus      CHAR(1);
    
    LET cCodRet    = '000';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr	   = 0;
    LET iIsamErr   = 0;
    LET cDescErr   = '';
    LET iTransacc  = 0;
    LET iContador  = 0;
    LET iContador2 = 0;
    LET cNumCte    = '';
    LET iTipoTel   = 0;
    LET iMaxSec    = 0;
    LET iCuantos   = 0;
    LET cTelefono  = '';
    LET iSecuencia = 0;
    LET cExtension = '';
    LET iCarrier   = 0;
    LET iCanal     = 0;
    LET iContacto  = 0;
    LET cCofetel   = '';
    LET dFecha     = '';
    LET cUser      = '';
    LET cMovil     = '';
    LET cStatus    = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/informix/jivan/sp_depura_telefonos.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, iContador, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/jivan/sp_depura_telefonos.out";
    --- TRACE ON;
    
    UPDATE STATISTICS MEDIUM FOR TABLE si_ctesdepurados;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTIENE CLIENTES A PROCESAR
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO cNumCte
          FROM si_telefonos
         WHERE numcte NOT IN( SELECT numcte FROM si_ctesdepurados )
           AND tipo_tel IN( 1, 2, 3, 4 ) 
           AND status_tel = 'A'
         
        -- // ABRE TRANSACCION
        BEGIN WORK;
        LET iTransacc = 1;
        
        -- // TIPOS DE TELEFONO POR CLIENTE
        FOREACH WITH HOLD
            SELECT UNIQUE tipo_tel
              INTO iTipoTel
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND status_tel = 'A'
        
            SELECT MAX(secuencia)
              INTO iMaxSec
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND status_tel = 'A';
               
            -- // VALIDACIONES EN TABLA DE TELEFONOS
            SELECT COUNT(*)
              INTO iCuantos
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND secuencia < iMaxSec
               AND status_tel = 'A';
           
            IF iCuantos > 0 THEN               
                UPDATE si_telefonos
                   SET status_tel = 'C'
                 WHERE numcte = cNumCte
                   AND tipo_tel = iTipoTel
                   AND secuencia < iMaxSec
                   AND status_tel = 'A';
            END IF;
            
            -- // VALIDACIONES EN TABLA DE TELEFONOS ACTUALES
            SELECT telefono, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel
              INTO cTelefono, cExtension, iCarrier, iCanal, iContacto, cCofetel, dFecha, cUser, cMovil, cStatus
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND secuencia = iMaxSec;
            
            SELECT COUNT(*)
              INTO iCuantos
              FROM si_telefonos_actual
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND secuencia = iMaxSec
               AND status_tel = 'A'
               AND telefono = cTelefono
               AND extension = cExtension
               AND carrier = iCarrier
               AND canal = iCanal
               AND contacto = iContacto
               AND cofetel = cCofetel
               AND fecha_hora = dFecha
               AND user_insert = cUser
               AND movil_fijo = cMovil
               AND status_stel = cStatus;
           
            IF iCuantos = 0 THEN 
                SELECT COUNT(*)
                  INTO iCuantos
                  FROM si_telefonos_actual
                 WHERE numcte = cNumCte
                   AND tipo_tel = iTipoTel;
                   
                IF iCuantos > 0 THEN 
                    UPDATE si_telefonos_actual
                       SET secuencia = iMaxSec,
                           status_tel = 'A',
                           telefono = cTelefono,
                           extension = cExtension,
                           carrier = iCarrier,
                           canal = iCanal,
                           contacto = iContacto,
                           cofetel = cCofetel,
                           fecha_hora = dFecha,
                           user_insert = cUser,
                           movil_fijo = cMovil,
                           status_stel = cStatus
                     WHERE numcte = cNumCte
                       AND tipo_tel = iTipoTel;
                ELSE
                    INSERT INTO si_telefonos_actual VALUES
                    ( pEmpresa, cNumCte, cTelefono, iTipoTel, 'A', iMaxSec, cExtension, iCarrier, iCanal, iContacto, cCofetel, dFecha, cUser, cMovil, cStatus );
                END IF;
                
                LET iContador2 = iContador2 + 1;
            END IF;
            
            LET iCuantos   = 0;
            LET iTipoTel   = 0;
            LET iMaxSec    = 0;
            LET cTelefono  = '';
            LET iSecuencia = 0;
            LET cExtension = '';
            LET iCarrier   = 0;
            LET iCanal     = 0;
            LET iContacto  = 0;
            LET cCofetel   = '';
            LET dFecha     = '';
            LET cUser      = '';
            LET cMovil     = '';
            LET cStatus    = '';
        END FOREACH;
        
        -- // REGISTRA CLIENTE PROCESADO
        INSERT INTO si_ctesdepurados VALUES(cNumCte);
        
        LET iContador = iContador + 1;
        
        -- // CIERRA TRANSACCION
        COMMIT WORK;
        LET iTransacc = 0;
        
        LET cNumCte = '';
    END FOREACH;
    
    END;
    
    RETURN cCodRet, iContador, iContador2;
    
END PROCEDURE;