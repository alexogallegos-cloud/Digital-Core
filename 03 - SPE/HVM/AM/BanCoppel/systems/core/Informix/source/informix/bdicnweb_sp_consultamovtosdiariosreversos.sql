CREATE PROCEDURE "informix".sp_consultamovtosdiariosreversos(cID_USUARIOC char(8),
							   cID_FUNCIONC CHAR(10),
							   cNUMCUENTA CHAR(20),
							   dPERIODOI DATE,
							   dPERIODOF DATE, 
							   cSISTEMACUENTA CHAR(20),
							   cUsuario CHAR(8),
							   cSuc CHAR(4),
							   mImporte MONEY(14,2),
							   pFolio CHAR(20),
							   pNumRegistro INTEGER,
							   pRecuperacion INTEGER)
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
		  CHAR(1)  AS Tpsuc;
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha	 		DATE;
DEFINE dHora 			DATETIME HOUR to FRACTION(3);
DEFINE cTransaccion		CHAR(4);
DEFINE cD_Transaccion		CHAR(50);
DEFINE mMonto			MONEY(14,2);
DEFINE cNaturaleza		CHAR(1);
DEFINE mSaldo 			MONEY(14,2);
DEFINE cReferencia 		CHAR(40);
DEFINE cReversos		CHAR(1);
DEFINE cReversados		CHAR(1);
DEFINE cSucursal 	 	CHAR(4);
DEFINE cTpsuc			CHAR(1);
DEFINE cFolio 			CHAR(16);
DEFINE cProcedencia		CHAR(20);
DEFINE cD_Procedencia		CHAR(50);
DEFINE dPeriodoI_1		DATE;
DEFINE dPeriodoF_1		DATE;
DEFINE sNUMSERIAL       	INT8;
--DEFINE cUsuario         	CHAR(8);
--SISTEMA DE CUENTA 06 VARIABLES
DEFINE cNumtarjeta		CHAR(20);
--VARIABLES DE PAGINACION
DEFINE iCont            	INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     		CHAR(3);
DEFINE cCodfun			CHAR(3);
DEFINE cCodref			INTEGER;
--inicializando variables
LET  iexiste 		= 0;
LET cCodRet 		= "00000";
LET iSql_err 		= 0 ;	
LET dFecha	 	= "";
LET dHora 		= "";
LET cTransaccion	= "";
LET cD_Transaccion	= "";
LET mMonto		= 0;
LET cNaturaleza		= "";
LET mSaldo 		= 0;
LET cReferencia		= "";
LET cReversos		= "";
LET cReversados		= "";
LET cSucursal 	  	= "";
LET cTpsuc		= "";
LET cFolio 		= "";
LET cProcedencia	= "";
LET cD_Procedencia	= "";
LET dPeriodoI_1		= "";
LET dPeriodoF_1		= "";
LET sNUMSERIAL      	=  0;
--LET cUsuario        	= "";
--SISTEMA DE CUENTA 06 VARIABLES
LET cNumtarjeta		= "";
--VARIABLES DE PAGINACION 
LET iCont       	= 0;
LET pEmpresa   		= '001';
LET cCodfun		='';
LET cCodref		=0;
BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/mfinis/sp_consultamovtosdiariosreversos.out";
	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	OR
		dPERIODOI IS NULL 	OR 
		dPERIODOF IS NULL	OR
		cSISTEMACUENTA = ''	THEN 
		LET cCodRet = "00036";
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
			dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
			mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
	END IF;	
	IF pNumRegistro<0 THEN
		LET cCodRet='00098';
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
			dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
			mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;					
	ELSE
		IF pRecuperacion<=0 THEN
			LET cCodRet='00098';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
        	END IF;
	END IF;  
	IF cSISTEMACUENTA <> 'CAPTACION' AND 
	   cSISTEMACUENTA <> 'CREDITO'  AND 
	   cSISTEMACUENTA <> 'INVERSIONES' THEN 
		LET cCodRet = "00037";
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
			dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
			mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
	END IF;
	--VALIDACION
	IF cSISTEMACUENTA = 'CAPTACION' THEN
		EXECUTE PROCEDURE 
		bdinteg:"informix".sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
		INTO cCodRet;
	END IF;
	IF cSISTEMACUENTA = 'CREDITO' THEN
		EXECUTE PROCEDURE 
		bdinteg:"informix".sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
		INTO cCodRet;
	END IF;
	IF cSISTEMACUENTA = 'INVERSIONES' THEN
		EXECUTE PROCEDURE 
		bdinteg:"informix".sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
		INTO cCodRet;
	END IF;
	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
			dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
			mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
	END IF;
	-- TERMINA VALIDACION

	IF cSISTEMACUENTA = 'CAPTACION' THEN 
		SELECT NVL(COUNT(cuenta),0) INTO iexiste 
		  FROM bdicheq:"informix".sc_maechq WHERE cuenta  = cNUMCUENTA;
		
		IF iexiste  = 0 THEN 
			LET cCodRet = "00009";
			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
			dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
			mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
		END IF;
		
		SELECT NVL(COUNT(cuenta),0)  
		INTO iexiste
		FROM bdicheq:"informix".sc_movdia 
		WHERE empresa='001' AND cuenta  = cNUMCUENTA 
		  AND fech_alt BETWEEN dPERIODOI AND dPERIODOF 
       		  AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
       		  AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
       		  AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END
		  AND folio_suc = CASE WHEN pFolio = "" THEN folio_suc ELSE pFolio END;
		
		IF iexiste  = 0 THEN 
                	LET cCodRet = "00039";
                	RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
		END IF;
        SET ISOLATION TO DIRTY READ;
        FOREACH 			
                    SELECT SKIP pNumRegistro FIRST pRecuperacion 
			MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,
			MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                        MO.sucursal,MO.folio_suc,   
                        dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,
			SU.Tpo_sucursal
                    INTO dFecha,dHora,cTransaccion,cD_Transaccion,
			mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,
			cSucursal,cFolio,
                        dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cNumtarjeta,cUsuario,
			cTpsuc
                    FROM bdicheq:"informix".sc_maechq MC
                         LEFT JOIN bdicheq:"informix".sc_movdia MO 
                           ON MC.cuenta = MO.cuenta
                         LEFT JOIN bdinteg:"informix".si_transacc TR 
                           ON MO.transacc = TR.numero
			 LEFT JOIN bdinteg:"informix".si_sucursales SU
			   ON SU.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END 
                    WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
                      AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
                      AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
                      AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
                      AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END
	              AND MO.folio_suc = CASE WHEN pFolio = "" THEN MO.folio_suc ELSE pFolio END
				  ORDER BY MO.fech_alt DESC,MO.fech_hor DESC

		  IF (SELECT NVL(COUNT(*),0) FROM bdinteg:"informix".si_procedencia 
			WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
                        SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia 
			FROM bdinteg:"informix".si_procedencia 
			WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
                    ELIF (SELECT NVL(COUNT(*),0) FROM bdinteg:"informix".si_procedencia 
			   WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
                        SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia 
			FROM bdinteg:"informix".si_procedencia 
			WHERE transacc=cTransaccion AND transacc<>'';
                    ELIF (SELECT NVL(COUNT(*),0) FROM bdinteg:"informix".si_procedencia 
			   WHERE sucursal=cSucursal AND transacc='')>0 THEN
                        SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia 
			FROM bdinteg:"informix".si_procedencia 
			WHERE sucursal=cSucursal AND transacc='';
                    ELSE
                        LET cProcedencia="";
                        LET cD_Procedencia="";
                    END IF;
                    LET iCont=iCont+1;
					LET cTpsuc = 'N';
                    RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario, cTpsuc WITH resume;
                END FOREACH;
                IF iCont = 0 THEN
                	LET cCodRet = '1001';
					LET cTpsuc = 'N';
                	RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
                END IF;
				
	ELIF cSISTEMACUENTA = 'CREDITO' THEN 
	        FOREACH
			SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste 
			FROM bdicred:"informix".sd_maecred 
			WHERE num_credito = cNUMCUENTA
            	UNION
            		SELECT NVL(COUNT(num_credito),0) AS CONT 
			FROM bdicred:"informix".sd_maecredcrd 
			WHERE num_credito = cNUMCUENTA ORDER BY CONT DESC
        	END FOREACH;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00009";
			LET cTpsuc = 'N';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
		END IF;
		
		SELECT NVL(COUNT(num_credito),0)  
		INTO iexiste
		FROM bdicred:"informix".sd_movdia 
		WHERE empresa='001' AND num_credito = cNUMCUENTA
		AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
		AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
        	AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
        	AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END
	        AND folio_suc = CASE WHEN pFolio = "" THEN folio_suc ELSE pFolio END;

			IF iexiste  = 0 THEN 
				SELECT NVL(COUNT(num_credito),0)  
				INTO iexiste
				FROM bdicred:"informix".sd_movdiacrd 
				WHERE empresa='001' AND num_credito = cNUMCUENTA
				AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
                		AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
                		AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                		AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END
	        		AND folio_suc = CASE WHEN pFolio = "" THEN folio_suc ELSE pFolio END;
			END IF;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00039";
			LET cTpsuc = 'N';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
		END IF;
		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT SKIP pNumRegistro FIRST pRecuperacion  
				MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,
				MO.nro_tarjeta,MO.folio_suc,   
            			MO.transacc_suc,TR.descripcion,MO.referencia,
            			MO.monto,TR.sentido,MO.reversado,MO.sucursal,
				dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,SU.Tpo_sucursal
			INTO 		
				cCodfun,cCodref,dFecha,dHora,
				cNumtarjeta,cFolio,
				cTransaccion,cD_Transaccion,cReferencia,
				mMonto,cNaturaleza,cReversos,cSucursal,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cTpsuc
			FROM bdicred:"informix".sd_maecred MC
			 LEFT JOIN bdicred:"informix".sd_movdia MO
			   ON MC.num_credito = MO.num_credito
			 LEFT JOIN bdicred:"informix".sd_transfun TR
			   ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			 LEFT JOIN bdinteg:"informix".si_sucursales SU
			   ON SU.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			WHERE MO.num_credito = cNUMCUENTA
			  AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            		  AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            		  AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            		  AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 	
	        	  AND MO.folio_suc = CASE WHEN pFolio = "" THEN MO.folio_suc ELSE pFolio END
		    UNION  	
			SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,
				MO.nro_tarjeta,MO.folio_suc,   
            			MO.transacc_suc,TR.descripcion,MO.referencia,
            			MO.monto,TR.sentido,MO.reversado,MO.sucursal,
				dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,SU.Tpo_sucursal
			FROM bdicred:"informix".sd_maecredcrd MC
			 LEFT JOIN bdicred:"informix".sd_movdiacrd  MO
			   ON MC.num_credito = MO.num_credito
			 LEFT JOIN bdicred:"informix".sd_transfun TR
			   ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			 LEFT JOIN bdinteg:"informix".si_sucursales SU
			   ON SU.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA
			  AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            		  AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            		  AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            		  AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 	
	        	  AND MO.folio_suc = CASE WHEN pFolio = "" THEN MO.folio_suc ELSE pFolio END
            		ORDER BY MO.fecha_mov DESC,MO.hora_mov DESC

       		IF (SELECT NVL(COUNT(*),0) FROM bdinteg:"informix".si_procedencia 
			    WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
                		SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia 
				FROM bdinteg:"informix".si_procedencia 
				WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
            		ELIF (SELECT NVL(COUNT(*),0) FROM bdinteg:"informix".si_procedencia 
			      WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
                		SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia 
				FROM bdinteg:"informix".si_procedencia 
				WHERE transacc=cTransaccion AND transacc<>'';
            		ELIF (SELECT NVL(COUNT(*),0) FROM bdinteg:"informix".si_procedencia 
			      WHERE sucursal=cSucursal AND transacc='')>0 THEN
                		SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia 
				FROM bdinteg:"informix".si_procedencia 
				WHERE sucursal=cSucursal AND transacc='';
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
				LET cTpsuc = 'N';
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
					dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
					cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
					mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc WITH resume;
			END IF;
		END FOREACH;
					
    		IF iCont = 0 AND pNumRegistro=0 THEN
			LET cCodRet = '00039'; 
			LET cTpsuc = 'N';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
		ELIF iCont = 0 THEN
			LET cCodRet = '1001';
			LET cTpsuc = 'N';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
		END IF;
	ELIF cSISTEMACUENTA = 'INVERSIONES' THEN 
		SELECT NVL(COUNT(cuenta),0) INTO iexiste 
		FROM bdinvers:"informix".sv_maeinv WHERE cuenta  = cNUMCUENTA;
		
		IF iexiste  = 0 THEN 
			LET cCodRet = "00009";
			LET cTpsuc = 'N';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
		END IF;
        
        	FOREACH
			SELECT LIMIT 1 NVL(COUNT(cuenta),0)  AS CONT
			INTO iexiste
			FROM bdinvers:"informix".sv_movdia 
			WHERE cuenta = cNUMCUENTA
			  AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
        		  AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
        		  AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
        		  AND usuario = CASE WHEN cUsuario = "" THEN usuario ELSE cUsuario END
	        	  AND folio_suc = CASE WHEN pFolio = "" THEN folio_suc ELSE pFolio END
        		ORDER BY CONT DESC
        	END FOREACH;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00039";
			LET cTpsuc = 'N';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
		END IF;
    		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT SKIP pNumRegistro FIRST pRecuperacion 	
				MO.fech_alt,MO.fech_hor,MO.folio_suc,
				MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,
				dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,MO.usuario,
				SU.Tpo_sucursal
			INTO 
				dFecha,dHora,cFolio,
				cTransaccion,cD_Transaccion,mMonto,cReversados,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cSucursal,cUsuario,
				cTpsuc
			FROM bdinvers:"informix".sv_maeinv MC
			 LEFT JOIN bdinvers:"informix".sv_movdia MO 
			   ON MC.cuenta = MO.cuenta
			 LEFT JOIN bdinteg:"informix".si_transacc TR 
			   ON MO.transacc = TR.numero
			 LEFT JOIN bdinteg:"informix".si_sucursales SU
			   ON SU.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END  
			WHERE MO.cuenta = cNUMCUENTA
			  AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
            		  AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
            		  AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            		  AND MO.usuario = CASE WHEN cUsuario = "" THEN MO.usuario ELSE cUsuario END 	
	        	  AND MO.folio_suc = CASE WHEN pFolio = "" THEN MO.folio_suc ELSE pFolio END
       		ORDER BY MO.fech_alt DESC,MO.fech_hor DESC

			LET iCont=iCont+1;
			LET cTpsuc = 'N';			

			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc WITH resume;
		END FOREACH;
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			LET cTpsuc = 'N';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,
				dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,
				mSaldo,cNumtarjeta,cReversados,cUsuario,cTpsuc;
		END IF;
	END IF;
END;
END PROCEDURE;