CREATE PROCEDURE "informix".sp_cnsif_conmovfol(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMFOLIO CHAR(16),pNumRegistro INTEGER,pRecuperacion INTEGER)

				returning CHAR(5)  AS Cod_Retorno,
                          CHAR(4)  AS Cve_Transaccion,
                          CHAR(50) AS Desc_Transaccion,
                          CHAR(20) AS Numero_Cuenta,
                          MONEY(14,2) AS Importe,
                          CHAR(40) AS Referencias,
                          INT      AS Numero_Cheque,
                          MONEY(14,2) AS SBC,
                          MONEY(14,2) AS Saldo,
                          DECIMAL(14,2) AS Importe_Dolares,
                          CHAR(23) AS Referencia_23,
						  CHAR(02)    AS Sistema_Cuenta;

DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE cTransaccion		CHAR(4);
DEFINE cD_Transaccion	CHAR(50);
DEFINE cNumCta 	 	    CHAR(20);
DEFINE mImporte		    MONEY(14,2);
DEFINE cReferencias	 	CHAR(40);
DEFINE cNumCheque 		INT;
DEFINE cenSBC		    MONEY(14,2);
DEFINE mSaldo		    MONEY(14,2);
DEFINE mImporteDls      DECIMAL(14,2);
DEFINE mReferencia23    CHAR(23);
DEFINE cSistemaCuenta   CHAR(02);
DEFINE cNumSerial       INT8;
DEFINE cCodigo_fun      CHAR(3);
DEFINE cCodigo_ref      INTEGER;
DEFINE iCont            INT;
DEFINE iCont_insert     INT;

--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;
LET cTransaccion	= "";
LET cD_Transaccion	= "";
LET cNumCta 	 	= "";
LET mImporte	    = 0;	
LET cReferencias	= "";
LET cNumCheque 		= 0;
LET cenSBC		    = 0;
LET mSaldo	        = 0;
LET mImporteDls     = 0;
LET mReferencia23   = "";
LET cSistemaCuenta  = '';
LET cNumSerial      = 0;
LET cCodigo_fun     = '';
LET cCodigo_ref     = 0;
LET iCont           = 0;
LET iCont_insert    = 0;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,
				mSaldo,mImporteDls,mReferencia23,cSistemaCuenta;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_conmovfol.out";
	--TRACE ON;

	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMFOLIO  = ''	 THEN 
		LET cCodRet = "00045";
		RETURN
		cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,
		mSaldo,mImporteDls,mReferencia23,cSistemaCuenta;
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN
		cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,
		mSaldo,mImporteDls,mReferencia23,cSistemaCuenta;					
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN
            cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,
            mSaldo,mImporteDls,mReferencia23,cSistemaCuenta;
        END IF;
    END IF;   
	
	EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	INTO cCodRet;

	IF cCodRet = '00028' THEN
		RETURN
		cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,
		mSaldo,mImporteDls,mReferencia23,cSistemaCuenta;
	END IF;
	IF pNumRegistro = 0 THEN
		DELETE {+INDEX (bdinteg:si_tempoconmovfol idx_tempoconmovfo)} FROM si_tempoconmovfol WHERE ejecutivosif= cID_USUARIOC;
		SET ISOLATION TO DIRTY READ;
		--*********** INICIA CAPTACION ***********************
			SELECT NVL(COUNT(folio_suc),0)  
			into iexiste
			FROM bdicheq:"informix".sc_movdia 
			WHERE folio_suc  = cNUMFOLIO AND empresa='001';
			IF iexiste  = 0 THEN 
				SELECT NVL(COUNT(folio_suc),0)  
				into iexiste
				FROM bdicheq:"informix".sc_movhis 
				WHERE folio_suc  = cNUMFOLIO AND empresa='001';
			END IF;
		
			IF iexiste  > 0 THEN	
				LET cSistemaCuenta = '01';
				FOREACH			
					SELECT {+INDEX (bdicheq:"informix".sc_movdia informix.idx_movdia2a)} 
						   mm.transacc,mm.cuenta,mm.monto_tot,mm.referencia,mm.num_cheq,mm.en_sbc,
						   mm.sdo_cuenta,mm.num_serial
					INTO 		
					cTransaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,
					mSaldo,cNumSerial					
					FROM  bdicheq:"informix".sc_movdia  mm
					WHERE  mm.folio_suc = cNUMFOLIO AND mm.empresa='001'
				UNION
					SELECT {+INDEX (bdicheq:"informix".sc_movhis idx_movhisnew7)}
						   mm.transacc,mm.cuenta,mm.monto_tot,mm.referencia,mm.num_cheq,mm.en_sbc,
						   mm.sdo_cuenta,mm.num_serial
					FROM bdicheq:"informix".sc_movhis AS mm
					WHERE  mm.folio_suc = cNUMFOLIO AND mm.empresa='001'
					ORDER BY mm.num_serial 
					
					SELECT {+INDEX (bdinteg:"informix".si_transacc informix.idx_transacc2)} tr.descripcion
					INTO cD_Transaccion
					FROM bdinteg:si_transacc tr
					WHERE tr.numero = cTransaccion and tr.sistema = cSistemaCuenta;
					
					LET iCont_insert = iCont_insert + 1;
					
					IF iCont_insert > 100 THEN
						EXIT FOREACH;
					END IF;

					INSERT INTO si_tempoconmovfol(codret,transacc,desc_transacc,cuenta,importe,referencia,num_cheque,sbc,saldo,importe_dls,referencia23,sistema,folio,ejecutivosif)
					VALUES(cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,mSaldo,mImporteDls,mReferencia23,cSistemaCuenta,cNUMFOLIO,cID_USUARIOC);

				END FOREACH;
			END IF;

	--*********** INICIA CREDITO ***********************
		SELECT NVL(COUNT(folio_suc),0)  
		into iexiste
		FROM bdicred:sd_movdia 
		WHERE folio_suc = cNUMFOLIO AND empresa='001';
		IF iexiste  = 0 THEN 
			SELECT NVL(COUNT(folio_suc),0)  
			into iexiste
			FROM bdicred:sd_movhis 
			WHERE folio_suc = cNUMFOLIO AND empresa='001';
			IF iexiste  = 0 THEN 
				SELECT NVL(COUNT(folio_suc),0)  
				into iexiste
				FROM bdicred:sd_movdiacrd 
				WHERE folio_suc = cNUMFOLIO AND empresa='001';
				IF iexiste  = 0 THEN 
					SELECT {+AVOID_FULL (bdicred:"informix".sd_movhiscrd)} NVL(COUNT(folio_suc),0)  
					into iexiste
					FROM bdicred:sd_movhiscrd 
					WHERE folio_suc = cNUMFOLIO AND empresa='001';					
				END IF;	
			END IF;
		END IF;
		IF iexiste  > 0 THEN
			LET cSistemaCuenta = '06';
			LET iCont_insert    = 0;
			
			FOREACH
				SELECT 
					   mm.transacc_suc,mm.num_credito,
					   mm.monto,mm.referencia,monto_dls,referencia23,mm.codigo_fun,mm.codigo_ref		
				INTO 		
					cTransaccion,cNumCta,mImporte,cReferencias,mImporteDls,mReferencia23,cCodigo_fun,cCodigo_ref
				FROM bdicred:sd_movdia  as mm
				WHERE  mm.folio_suc  = cNUMFOLIO AND mm.empresa='001'		
			UNION 
				SELECT 
					   mm.transacc_suc,mm.num_credito,
					   mm.monto,mm.referencia,monto_dls,referencia23,mm.codigo_fun,mm.codigo_ref
				FROM bdicred:sd_movhis  as mm
				WHERE  mm.folio_suc  = cNUMFOLIO AND mm.empresa='001'			
			UNION  	
				SELECT 
					   mm.transacc_suc,mm.num_credito,
					   mm.monto,mm.referencia,monto_dls,referencia23,mm.codigo_fun,mm.codigo_ref
				FROM   bdicred:sd_movdiacrd    as mm
				WHERE  mm.folio_suc  = cNUMFOLIO AND mm.empresa='001'
			UNION 
				SELECT 
						mm.transacc_suc,tr.descripcion,mm.num_credito,
					    mm.monto,mm.referencia,monto_dls,referencia23
				FROM bdicred:sd_movhiscrd as mm
				WHERE  mm.folio_suc  = cNUMFOLIO AND mm.empresa='001'	
					
				SELECT tr.descripcion
				INTO cD_Transaccion
				FROM bdicred:sd_transfun tr
				WHERE tr.codigo_fun = cCodigo_fun and tr.codigo_ref = cCodigo_ref;
				
				LET iCont_insert = iCont_insert + 1;
				
				IF iCont_insert > 100 THEN
					EXIT FOREACH;
				END IF;

				INSERT INTO si_tempoconmovfol(codret,transacc,desc_transacc,cuenta,importe,referencia,num_cheque,sbc,saldo,importe_dls,referencia23,sistema,folio,ejecutivosif)
				VALUES(cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,mSaldo,mImporteDls,mReferencia23,cSistemaCuenta,cNUMFOLIO,cID_USUARIOC);

			END FOREACH;
		END IF;	

		--*********** INICIA INVERSIONES ***********************
			SELECT {+INDEX (bdinvers:sv_movdia ix161_2)} NVL(COUNT(folio_suc),0)  
			INTO iexiste
			FROM bdinvers:sv_movdia 
			WHERE folio_suc  = cNUMFOLIO AND empresa='001';
			IF iexiste  = 0 THEN 
				SELECT {+INDEX (bdinvers:sv_movhis idx_svfolsuc)} NVL(COUNT(folio_suc),0)  
				INTO iexiste
				FROM bdinvers:sv_movhis 
				WHERE folio_suc  = cNUMFOLIO AND empresa='001';
			END IF

			IF iexiste  > 0 THEN
				LET cSistemaCuenta = '03';
				LET iCont_insert    = 0;
			
				FOREACH			
					SELECT {+INDEX (bdinvers:sv_movdia ix161_2)} 
						   mm.transacc,mm.cuenta,mm.monto_tot,mm.en_sbc,
						   mm.sdo_cuenta,mm.num_serial
					INTO 		
					cTransaccion,cNumCta,mImporte,cenSBC,
					mSaldo,cNumSerial		
					FROM bdinvers:sv_movdia	AS mm
					WHERE  mm.folio_suc = cNUMFOLIO AND mm.empresa='001' AND mm.transacc = '0500'
				UNION
					SELECT {+INDEX (bdinvers:sv_movhis idx_svfolsuc)} 
						   mm.transacc,mm.cuenta,mm.monto_tot,mm.en_sbc,
						   mm.sdo_cuenta,mm.num_serial
					FROM bdinvers:sv_movhis AS mm
					WHERE  mm.folio_suc = cNUMFOLIO AND mm.empresa='001' AND mm.transacc = '0500'
				ORDER BY mm.num_serial 
					
					SELECT tr.descripcion
					INTO cD_Transaccion
					FROM bdinteg:si_transacc tr
					WHERE tr.numero = cTransaccion and tr.sistema = cSistemaCuenta;
						
					LET iCont_insert = iCont_insert + 1;
					
					IF iCont_insert > 100 THEN
						EXIT FOREACH;
					END IF;
					
					INSERT INTO si_tempoconmovfol(codret,transacc,desc_transacc,cuenta,importe,referencia,num_cheque,sbc,saldo,importe_dls,referencia23,sistema,folio,ejecutivosif)
					VALUES(cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,mSaldo,mImporteDls,mReferencia23,cSistemaCuenta,cNUMFOLIO,cID_USUARIOC);

				END FOREACH;

			END IF;

			
		SELECT NVL(COUNT(codret),0) into iexiste FROM si_tempoconmovfol WHERE folio = cNUMFOLIO AND ejecutivosif= cID_USUARIOC;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00092";
			RETURN 	cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,mSaldo,mImporteDls,mReferencia23,cSistemaCuenta; 
		END IF;		
	END IF;

	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT {+INDEX (bdinteg:si_tempoconmovfol idx_tempoconmovfo)} SKIP pNumRegistro FIRST pRecuperacion
		codret,transacc,desc_transacc,cuenta,importe,referencia,num_cheque,sbc,saldo,importe_dls,referencia23,sistema
		INTO
		cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,mSaldo,mImporteDls,mReferencia23,cSistemaCuenta
		FROM si_tempoconmovfol
		WHERE folio = cNUMFOLIO AND ejecutivosif= cID_USUARIOC
		IF LENGTH(cCodRet) = 3 THEN
			LET  cCodRet = '00' || cCodRet;
		END IF
		IF cCodRet !='00000' THEN
			RETURN 	cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,mSaldo,mImporteDls,mReferencia23,cSistemaCuenta;
		END IF;

		LET iCont=iCont + 1;
		RETURN 	cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,mSaldo,mImporteDls,mReferencia23,cSistemaCuenta WITH Resume;
	END FOREACH;

	IF iCont = 0 THEN
		DELETE {+INDEX (bdinteg:si_tempoconmovfol idx_tempoconmovfo)} FROM si_tempoconmovfol WHERE ejecutivosif= cID_USUARIOC;
		LET cCodRet = '1001'; 
		RETURN 	cCodRet,cTransaccion,cD_Transaccion,cNumCta,mImporte,cReferencias,cNumCheque,cenSBC,mSaldo,mImporteDls,mReferencia23,cSistemaCuenta;
	END IF; 
END
END PROCEDURE

DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Movimientos a detalle de las Cuentas de Captación o Crédito. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetros el Folio",
"FECHA : 14-02-2012",
"ACTUALIZO : URIEL AMADOR ISLAS",
"FECHA : 12-07-2023",
"MODIFICACION:Optimización a solicitud de base de datos por altos costos, se limita la búsqueda a cuentas captación a tablas sc_movdia y sc_movhis, y se agrega filtro por sistema",
"BD    : bdinteg",
"VER   : 2.0";

CREATE PROCEDURE "informix".sp_cnsif_consultamovtosdiarioscta(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)

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
						  CHAR(1)  AS Reversados;

DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha	 		DATE;
DEFINE dHora 			DATETIME HOUR to FRACTION(3);
DEFINE cTransaccion		CHAR(4);
DEFINE cD_Transaccion	CHAR(50);
DEFINE mMonto			MONEY(14,2);
DEFINE cNaturaleza		CHAR(1);
DEFINE mSaldo 			MONEY(14,2);
DEFINE cReferencia 		CHAR(40);
DEFINE cReversos		CHAR(1);
DEFINE cReversados		CHAR(1);
DEFINE cSucursal 	 	CHAR(4);
DEFINE cFolio 			CHAR(16);
DEFINE cProcedencia		CHAR(20);
DEFINE cD_Procedencia	CHAR(50);
DEFINE dPeriodoI_1		DATE;
DEFINE dPeriodoF_1		DATE;
DEFINE sNUMSERIAL       INT8;
--SISTEMA DE CUENTA 06 VARIABLES
DEFINE cNumtarjeta		CHAR(20);
--VARIABLES PARA FECHAS HISTORICAS
DEFINE cconsmovhis      CHAR(10);
DEFINE cconsmovhisold   CHAR(10);
DEFINE cconsmovhisold2  CHAR(10);
DEFINE cconsmovhisold3  CHAR(10);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     CHAR(3);
DEFINE iConMov			INT;
DEFINE cProd		CHAR(4);
DEFINE iNumRows			INTEGER;
DEFINE cCuenta2		CHAR(11);
--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;	
LET dFecha	 		= "";
LET dHora 			= "";
LET cTransaccion	= "";
LET cD_Transaccion	= "";
LET mMonto			= 0;
LET cNaturaleza		= "";
LET mSaldo 			= 0;
LET cReferencia		= "";
LET cReversos		= "";
LET cReversados		= "";
LET cSucursal 	 	= "";
LET cFolio 			= "";
LET cProcedencia	= "";
LET cD_Procedencia	= "";
LET dPeriodoI_1		= "";
LET dPeriodoF_1		= "";
LET sNUMSERIAL      =  0;
--SISTEMA DE CUENTA 06 VARIABLES
LET cNumtarjeta	= "";
--VARIABLES PARA FECHAS HISTORICAS
LET cconsmovhis     = '';
LET cconsmovhisold  = '';
LET cconsmovhisold2 = '';
LET cconsmovhisold3 = '';
--VARIABLES DE PAGINACION 
LET iCont       = 0;
LET pEmpresa   = '001';
let iConMov		=0;
LET cProd ='';		
LET iNumRows= 0;
LET cCuenta2='';

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;
	END EXCEPTION;
		  	--SET DEBUG FILE TO "/informix/CHVN/sp_cnsif_consultamovtosdiarioscta.out";
		  	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	OR 
		dPERIODOI   IS NULL OR 
		dPERIODOF 	IS NULL	OR 
		cSISTEMACUENTA = '' THEN 
		LET cCodRet = "00036";
		RETURN
		cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN
		cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;					
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN
            cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
            cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
        END IF;
    END IF;  
	IF cSISTEMACUENTA <> 'CAPTACION' AND cSISTEMACUENTA <> 'CREDITO'  AND cSISTEMACUENTA <> 'INVERSIONES' THEN 
		LET cCodRet = "00037";
		RETURN 
		cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
	END IF;


	-- TERMINA VALIDACION

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
	
	IF cSISTEMACUENTA = 'CAPTACION' THEN 
		FOREACH
		SELECT FIRST 1 NVL(COUNT(cuenta),0) into iexiste FROM bdicheq:sc_maechq WHERE cuenta  = cNUMCUENTA
		UNION
		SELECT NVL(COUNT(cuenta_tf),0) FROM bditransfer:tf_maecte WHERE cuenta_tf  = cNUMCUENTA
		ORDER BY 1 DESC
		END FOREACH;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00009";
			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;
		
		LET cProd=SUBSTR(cNUMCUENTA,1,4);
		IF cProd NOT IN('1200','1600','2200','2600','2700','2800') THEN
			SET ISOLATION TO DIRTY READ;
			SELECT FIRST 1 cuenta  
				INTO cCuenta2
				FROM bdicheq:"informix".sc_movdia 
				WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF;
				LET iNumRows = dbinfo("sqlca.sqlerrd2");
				IF iNumRows  = 0 THEN
					SET ISOLATION TO DIRTY READ;				
					SELECT FIRST 1 cuenta   
					INTO cCuenta2
					FROM bdicheq:"informix".sc_movhis 
					WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF;
					LET iNumRows = dbinfo("sqlca.sqlerrd2");
					IF iNumRows  = 0 THEN
						SET ISOLATION TO DIRTY READ;
						SELECT FIRST 1 cuenta   
						INTO cCuenta2
						FROM bdicheq:"informix".sc_movhis_old 
						WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF;
						LET iNumRows = dbinfo("sqlca.sqlerrd2");
					END IF;
				END IF;

				IF iNumRows  = 0 THEN 
					LET cCodRet = "00039";
					RETURN 
					cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
					cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
				END IF;				
		END IF;

		IF SUBSTR(cNUMCUENTA,1,4)="1200" OR SUBSTR(cNUMCUENTA,1,4)="1600" OR
			SUBSTR(cNUMCUENTA,1,4)="2200" OR SUBSTR(cNUMCUENTA,1,4)="2600" OR 
			SUBSTR(cNUMCUENTA,1,4)="2700" OR SUBSTR(cNUMCUENTA,1,4)="2800" THEN
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados WITH resume;	
		ELSE
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT first 1 count(cuenta) as cant INTO iConMov
				FROM bdicheq:sc_movdia  MO 
				LEFT JOIN bdinteg:si_transacc TR 
				ON MO.transacc = TR.numero
				AND TR.sistema = '01'
				WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA 
				AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF	AND MO.producto NOT IN ('1200','1600','2200','2600','2700','2800')
			UNION
				SELECT 	count(cuenta) as cant
			FROM bdicheq:sc_movhis  MO 
				LEFT JOIN bdinteg:si_transacc TR 
				ON MO.transacc = TR.numero 
				AND TR.sistema = '01'
				WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
				AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF	AND MO.producto NOT IN ('1200','1600','2200','2600','2700','2800')
				AND MO.fech_alt >= cconsmovhis
			UNION
				SELECT  count(cuenta) as cant
				FROM bdicheq:sc_movhis_old  MO 
				LEFT JOIN bdinteg:si_transacc TR 
				ON MO.transacc = TR.numero
				AND TR.sistema = '01'
				WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
				AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.producto NOT IN ('1200','1600','2200','2600','2700','2800')
				AND MO.fech_alt >= cconsmovhisold
				AND MO.fech_alt < cconsmovhis	
				ORDER BY cant DESC 
			END FOREACH;
			IF iConMov>=50 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH 			
					SELECT  FIRST 5 MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
							MO.sucursal,MO.folio_suc,   
							dPERIODOI,dPERIODOF,MO.num_serial
					INTO 		
					dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
					dPeriodoI_1,dPeriodoF_1,sNUMSERIAL
					FROM bdicheq:sc_maechq MC
					LEFT JOIN bdicheq:sc_movdia  MO 
					ON MC.cuenta = MO.cuenta
					LEFT JOIN bdinteg:si_transacc TR 
					ON MO.transacc = TR.numero 
					AND TR.sistema = '01'
					WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA 
					AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF	AND MO.producto NOT IN ('1200','1600','2200','2600','2700','2800')								
				UNION
					SELECT 	MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
						MO.sucursal,MO.folio_suc,   
						dPERIODOI,dPERIODOF,MO.num_serial
				FROM bdicheq:sc_maechq MC
					LEFT JOIN bdicheq:sc_movhis  MO 
					ON MC.cuenta = MO.cuenta
					LEFT JOIN bdinteg:si_transacc TR 
					ON MO.transacc = TR.numero 
					AND TR.sistema = '01'
					WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
					AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF	AND MO.producto NOT IN ('1200','1600','2200','2600','2700','2800')
					AND MO.fech_alt >= cconsmovhis
				UNION
					SELECT  MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
							MO.sucursal,MO.folio_suc,   
							dPERIODOI,dPERIODOF,MO.num_serial
					FROM bdicheq:sc_maechq MC
					LEFT JOIN bdicheq:sc_movhis_old  MO 
					ON MC.cuenta = MO.cuenta
					LEFT JOIN bdinteg:si_transacc TR 
					ON MO.transacc = TR.numero
					AND TR.sistema = '01'
					WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
					AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.producto NOT IN ('1200','1600','2200','2600','2700','2800')
					AND MO.fech_alt >= cconsmovhisold
					AND MO.fech_alt < cconsmovhis
					ORDER BY MO.fech_alt DESC,MO.fech_hor DESC

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
				RETURN 
				cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados WITH resume;						
				END FOREACH;

				LET cCodRet = '1001'; 
					RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
						   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;

			END IF;		   
			
			SET ISOLATION TO DIRTY READ;
			FOREACH 			
				SELECT SKIP pNumRegistro FIRST pRecuperacion MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
						MO.sucursal,MO.folio_suc,   
						dPERIODOI,dPERIODOF,MO.num_serial
				INTO 		
				dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL
				FROM bdicheq:sc_movdia  MO 
				LEFT JOIN bdinteg:si_transacc TR 
				ON MO.transacc = TR.numero 
				AND TR.sistema = '01'
				WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA 
				AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF	AND MO.producto NOT IN ('1200','1600','2200','2600','2700','2800')							
			UNION
				SELECT 	MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
					MO.sucursal,MO.folio_suc,   
					dPERIODOI,dPERIODOF,MO.num_serial
			FROM bdicheq:sc_movhis  MO 
				LEFT JOIN bdinteg:si_transacc TR 
				ON MO.transacc = TR.numero 
				AND TR.sistema = '01'
				WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
			AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF	AND MO.producto NOT IN ('1200','1600','2200','2600','2700','2800')
			AND MO.fech_alt >= cconsmovhis
		UNION
			SELECT  MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
					MO.sucursal,MO.folio_suc,   
					dPERIODOI,dPERIODOF,MO.num_serial
			FROM bdicheq:sc_movhis_old  MO 
			LEFT JOIN bdinteg:si_transacc TR 
			ON MO.transacc = TR.numero
			AND TR.sistema = '01'
			WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
			AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.producto NOT IN ('1200','1600','2200','2600','2700','2800')
			AND MO.fech_alt >= cconsmovhisold
			AND MO.fech_alt < cconsmovhis
			ORDER BY MO.fech_alt DESC,MO.fech_hor DESC

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
			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados WITH resume;						
			END FOREACH;

			IF iCont = 0 THEN
			LET cCodRet = '1001'; 
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
					   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
			END IF
		END IF;	
	ELIF cSISTEMACUENTA = 'CREDITO' THEN 
        FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE num_credito = cNUMCUENTA
            UNION
            SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE num_credito = cNUMCUENTA ORDER BY CONT DESC
        END FOREACH;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00009";
			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;

		SELECT NVL(COUNT(num_credito),0)  
		into iexiste
		FROM bdicred:sd_movdia 
		WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF;
		IF iexiste  = 0 THEN 
			SELECT NVL(COUNT(num_credito),0)  
			into iexiste
			FROM bdicred:sd_movhis 
			WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF;
			IF iexiste  = 0 THEN 
				SELECT NVL(COUNT(num_credito),0)  
				into iexiste
				FROM bdicred:sd_movdiacrd 
				WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF;
				IF iexiste  = 0 THEN 
					SELECT NVL(COUNT(num_credito),0)  
					into iexiste
					FROM bdicred:sd_movhiscrd 
					WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF;					
				END IF;
			END IF;
		END IF;

		IF iexiste  = 0 THEN 
			LET cCodRet = "00039";
			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;

		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT SKIP pNumRegistro FIRST pRecuperacion  MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,   
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia
			INTO 		
			dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
			dPeriodoI_1,dPeriodoF_1,sNUMSERIAL
			FROM bdicred:sd_maecred MC
			LEFT JOIN bdicred:sd_movdia  MO
			ON MC.num_credito = MO.num_credito
			LEFT JOIN bdicred:sd_transfun TR
			ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			WHERE  MO.num_credito = cNUMCUENTA
			AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
		UNION
			SELECT  MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,   
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia
			FROM bdicred:sd_maecred MC
			LEFT JOIN bdicred:sd_movhis  MO
			ON MC.num_credito = MO.num_credito
			LEFT JOIN bdicred:sd_transfun TR
			ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			WHERE  MO.num_credito = cNUMCUENTA
			AND    MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF			
		UNION  	
			SELECT  MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,   
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia
			FROM bdicred:sd_maecredcrd MC
			LEFT JOIN bdicred:sd_movdiacrd  MO
			ON MC.num_credito = MO.num_credito
			LEFT JOIN bdicred:sd_transfun TR
			ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA
			AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
		UNION 
			SELECT 	MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,   
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia
			FROM bdicred:sd_maecredcrd MC
			LEFT JOIN bdicred:sd_movhiscrd  MO
			ON MC.num_credito = MO.num_credito
			LEFT JOIN bdicred:sd_transfun TR
			ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			WHERE MO.num_credito = cNUMCUENTA
			AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
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
			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados WITH resume;
		END FOREACH;

					
    	IF iCont = 0 THEN
		LET cCodRet = '1001'; 
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF
	ELIF cSISTEMACUENTA = 'INVERSIONES' THEN 
		SELECT NVL(COUNT(cuenta),0) into iexiste FROM bdinvers:sv_maeinv WHERE cuenta  = cNUMCUENTA;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00009";
			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;
        
        FOREACH
		SELECT LIMIT 1 NVL(COUNT(cuenta),0)  AS CONT
		into iexiste
		FROM bdinvers:sv_movdia 
		WHERE cuenta = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
        UNION
		SELECT NVL(COUNT(cuenta),0) AS CONT  
		FROM bdinvers:sv_movhis 
		WHERE cuenta = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF ORDER BY CONT DESC
        END FOREACH;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00039";
			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF;

    	SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT SKIP pNumRegistro FIRST pRecuperacion 	
			MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia
			INTO 
			dFecha,dHora,cFolio,cTransaccion,cD_Transaccion,mMonto,cReversados,dPeriodoI_1,dPeriodoF_1,sNUMSERIAL
			FROM bdinvers:sv_maeinv MC
			LEFT JOIN bdinvers:sv_movdia MO 
			ON MC.cuenta = MO.cuenta
			LEFT JOIN bdinteg:si_transacc TR 
			ON MO.transacc = TR.numero  
			WHERE MO.cuenta = cNUMCUENTA
			AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
			UNION
			SELECT	
			MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia
			FROM bdinvers:sv_maeinv MC
			LEFT JOIN bdinvers:sv_movhis MO 
			ON MC.cuenta = MO.cuenta
			LEFT JOIN bdinteg:si_transacc TR 
			ON MO.transacc = TR.numero  
			WHERE MO.cuenta = cNUMCUENTA
			AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
            ORDER BY MO.fech_alt DESC,MO.fech_hor DESC

			LET iCont=iCont+1;	

			RETURN 
			cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados WITH resume;
		END FOREACH;

		IF iCont = 0 THEN
		LET cCodRet = '1001'; 
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados;
		END IF
	END IF
END

END PROCEDURE

DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques, para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 09-02-2012",
"ACTUALIZO : URIEL AMADOR ISLAS",
"FECHA : 12-07-2023",
"MODIFICACION:Optimización a solicitud de base de datos por altos costos, se limita la búsqueda a cuentas captación a tablas sc_movdia y sc_movhis, y se agrega al filtro por producto los siguientes primeros 4 digitos de las cuentas de captación '2200','2600','2700','2800'",
"ACTUALIZO : URIEL AMADOR ISLAS",
"FECHA : 09-08-2023",
"MODIFICACION:Se agrega a la búsqueda de cuentas captación la tabla sc_movhis_old",
"BD    : bdinteg",
"VER   : 3.0";

CREATE PROCEDURE "informix".sp_obtenerctas_iccat(pEmpresa CHAR(3), 
									 pNumCte CHAR(9),
									 pRegistros SMALLINT)
--DATOS A REGRESAR---
RETURNING CHAR(9)   AS codRet, 
		  CHAR(104) AS nombre, 
		  CHAR(20)  AS tarjeta,
		  CHAR(60)  AS producto,  
		  CHAR(1)  	AS estatus_Envio,
		  CHAR(20)  AS cuenta,
		  CHAR(60)  AS estatus_Cuenta,		  
		  CHAR(10)  AS telefonoCel,
		  CHAR(100) AS correo;

		  
	-- DEFINICION DE VARIABLES
	DEFINE cCod_ret      	 CHAR(9);	
    DEFINE cNumCte      	 CHAR(9);
    DEFINE cProducto    	 CHAR(60);
    DEFINE cEstatus     	 CHAR(20);
	DEFINE cTarjeta      	 CHAR(20);
	DEFINE sTipo 			 SMALLINT;
	DEFINE iSqlErr      	 INTEGER;
	DEFINE iLimit 			 INTEGER;
	DEFINE iCantReg 		 INTEGER;
	DEFINE iSistema     	 INTEGER;
	DEFINE iSkip			 INTEGER;
	DEFINE cEstatusCFDI		CHAR(1);
	DEFINE cCuenta      	 CHAR(20);
	DEFINE cTelefono		CHAR(10);
	DEFINE cCorreo			CHAR(100);
	DEFINE cNombre1     	 CHAR(26);
	DEFINE cNombre2			 CHAR(26);
	DEFINE cMaterno			 CHAR(26);
	DEFINE cPaterno			 CHAR(26);
	DEFINE cRazon       	 CHAR(36);
	DEFINE cNomCompleto    	 CHAR(36);
	DEFINE sContReg			 SMALLINT;

	
	--INICIALIZACION DE VARIABLES
	LET cCod_ret     	  = "000000000";		
	LET cNumCte    	 	  = "";	
    LET cProducto    	  = "";
	LET cEstatus     	  = "";	
	LET cTarjeta     	  = "";
	LET sTipo        	  = 0;
	LET iSqlErr      	  = 0;
	LET iLimit       	  = 0;
	LET iCantReg 	 	  = 0;
	LET iSistema     	  = 0;
	LET iSkip        	  = 0;
	LET cEstatusCFDI	  = "";
	LET cCuenta      	  = "";
	LET cTelefono		  = "";
	LET cCorreo			  = "";
	LET cNombre1     	  = "";
	LET cNombre2     	  = "";
	LET cMaterno     	  = "";
	LET cPaterno     	  = "";
	LET cRazon    	 	  = "";
	LET cNomCompleto   	  = "";
	LET sContReg		  = 0;

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCod_ret = iSqlErr;
				
				RETURN cCod_ret,cNomCompleto,cTarjeta,cProducto,cEstatusCFDI,cCuenta,cEstatus,cTelefono,cCorreo;	
			END IF;
		END EXCEPTION;
		
	--SET DEBUG FILE TO '/informix/tmp/sp_obtenerctas_iccat.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	IF NVL(pEmpresa,'') = '' THEN
			LET cCod_ret = '000000001';
			RETURN cCod_ret,cNomCompleto,cTarjeta,cProducto,
				cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo;
		ELIF NVL(pNumCte,'') = '' THEN
			LET cCod_ret = '000000001';
			RETURN cCod_ret,cNomCompleto,cTarjeta,cProducto,
				cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo;
		ELIF NVL(pRegistros,'') = '' THEN
			LET cCod_ret = '000000001';
			RETURN cCod_ret,cNomCompleto,cTarjeta,cProducto,
				cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo;
	ELSE
			
			LET cNumCte = pNumCte;
			
			SELECT numcte
			INTO cNumCte
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = cNumCte;

			IF cNumCte IS NULL THEN
				LET cCod_ret = "000000003";
				RETURN cCod_ret,cNomCompleto,cTarjeta,cProducto,
				cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo;
			END IF;
			
			
			SELECT a.telefono
			INTO cTelefono
			FROM bdinteg:"informix".si_telefonos_actual a,  bdinteg:"informix".si_carriers b
			WHERE a.empresa = pEmpresa
			AND a.numcte =  cNumCte 
			AND a.tipo_tel = '2'
			AND a.status_tel = 'A'
			AND a.cofetel = 'V'
			AND a.secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual 
			WHERE numcte =  cNumCte 
			AND empresa = pEmpresa
			AND tipo_tel = '2'
			AND status_tel = 'A'
			AND cofetel = 'V')
			AND  a.carrier = b.cve_carrier;
			
			SELECT correo_elec 
			INTO cCorreo
			FROM  bdinteg:"informix".si_correos
			WHERE empresa = pEmpresa AND numcte = cNumCte
			AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos 
			WHERE empresa = pEmpresa  AND numcte = cNumCte);
			
			SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social
			INTO cNumCte,cPaterno,cMaterno,cNombre1,cNombre2,cRazon
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = cNumCte;
			
			LET cNomCompleto = TRIM(cNombre1) || " " || TRIM(cNombre2) || " " || TRIM(cPaterno) ||" " || TRIM(cMaterno);

			LET iLimit = 10;
			LET sTipo = pRegistros;
				-- *****************************************************************
				-- Extrae la informacion del Sistema de Cheques
				-- *****************************************************************
				IF pNumCte <> '' OR iSistema = 1 THEN
				
					SELECT COUNT(*)							
					INTO sContReg
					FROM bdicheq:"informix".sc_maechq mc,
						 bdicheq:"informix".sc_producto pr,
						 bdicheq: sc_mae_estatus mas
					WHERE num_cte = cNumCte 
					AND mc.empresa = pEmpresa
					AND mc.cuenta = mc.cuenta
					AND mc.producto IN ('1300','1400','1500','1700','1800','1900','2000','2400','2500','8000')
					AND mc.status_cta IN ('1','3','4','5','8')
					AND mc.producto = pr.producto
					AND mc.status_cta = mas.cod_estatus;
				
					FOREACH
						SELECT skip sTipo LIMIT iLimit
						mc.cuenta,mc.producto||" "||pr.nombre,mas.descripcion
							
						INTO cCuenta,cProducto,cEstatus
						FROM bdicheq:"informix".sc_maechq mc,
							 bdicheq:"informix".sc_producto pr,
							 bdicheq: sc_mae_estatus mas
						WHERE num_cte = cNumCte 
						AND mc.empresa = pEmpresa
						AND mc.cuenta = mc.cuenta
						AND mc.producto IN ('1300','1400','1500','1700','1800','1900','2000','2400','2500','8000')
						AND mc.status_cta IN ('1','3','4','5','8')
						AND mc.producto = pr.producto
						AND mc.status_cta = mas.cod_estatus
						ORDER BY cuenta 

						SELECT num_tarjeta
						INTO  cTarjeta
						FROM bdicheq:"informix".sc_tarjeta
						WHERE numcte = cNumCte
						AND empresa = pEmpresa
						AND cuenta = cCuenta 
						AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_tarjeta WHERE numcte = cNumCte AND cuenta = cCuenta);

						IF EXISTS (SELECT cuenta
						FROM bdinteg:"informix".si_altaserv_edoctamov
						WHERE empresa = pEmpresa				
						AND numcte = cNumCte
						AND cuenta = cCuenta) THEN
						LET cEstatusCFDI = "T";
						ELSE
						LET cEstatusCFDI = "F";
						END IF;

						LET iCantReg = iCantReg + 1;
						LET iSkip = iCantReg;
						RETURN cCod_ret,NVL(cNomCompleto,""),NVL(cTarjeta,""),NVL(cProducto,""),cEstatusCFDI,NVL(cCuenta,""),NVL(cEstatus,""),cTelefono,cCorreo WITH RESUME;
						
					END FOREACH;
				END IF;	
			
			IF iCantReg < iLimit  THEN
			
					IF sTipo > sContReg THEN
						LET sTipo = sTipo - sContReg;
					ELSE
						LET sTipo = 0;
					END IF;
			
				LET iLimit = iLimit - iCantReg;
				LET iCantReg = 0;

					-- *********************************************************************
					-- Extrae la informacion del Sistema de Credito
					-- *********************************************************************
					IF pNumCte <> '' OR iSistema = 6 THEN
						--IFRS Se contempla nuevo estatus vigente por Etapas	
						SELECT COUNT(*)	
							INTO sContReg
							FROM bdicred:"informix".sd_maecred mc,
							bdicred:"informix".sd_definicion pr,
							bdicred:"informix".sd_tipocartera tc
							WHERE numcte = cNumCte 
							AND mc.num_credito = mc.num_credito
							AND mc.num_producto = pr.num_producto
							AND pr.num_producto IN('6001','6600','8100','7000', '5400')
							AND mc.status_cred = tc.status_cred 
							AND mc.status_cred IN ('AA','BA','BT','FF','E1','E2','E3');
							--AND mcd.status_cred IN ('AA','BA','BT','FF');
						--IFRS Se contempla nuevo estatus vigente por Etapas	
						FOREACH
							SELECT skip sTipo LIMIT iLimit
							mc.num_credito,mc.num_producto||" "||pr.nombre_prod,tc.descripcion
							INTO cCuenta,cProducto,cEstatus
							FROM bdicred:"informix".sd_maecred mc,
							bdicred:"informix".sd_definicion pr,
							bdicred:"informix".sd_tipocartera tc
							WHERE numcte = cNumCte 
							AND mc.num_credito = mc.num_credito
							AND mc.num_producto = pr.num_producto
							AND pr.num_producto IN('6001','6600','8100','7000', '5400')
							AND mc.status_cred = tc.status_cred 
							AND mc.status_cred IN ('AA','BA','BT','FF','E1','E2','E3')
							--AND mcd.status_cred IN ('AA','BA','BT','FF')							
							ORDER BY 1
							
							SELECT num_tarjeta
							INTO cTarjeta
							FROM bdicred:"informix".sd_tarjeta
							WHERE numcte = cNumCte
							AND num_credito = cCuenta
							AND secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE numcte = cNumCte AND num_credito = cCuenta);  
							

							IF EXISTS (SELECT cuenta
							FROM bdinteg:"informix".si_altaserv_edoctamov
							WHERE empresa = pEmpresa				
							AND numcte = cNumCte
							AND cuenta = cCuenta) THEN
							LET cEstatusCFDI = "T";
							ELSE
							LET cEstatusCFDI = "F";
							END IF;

							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							
							RETURN cCod_ret,NVL(cNomCompleto,""),NVL(cTarjeta,""),NVL(cProducto,""),
							cEstatusCFDI,NVL(cCuenta,""),NVL(cEstatus,""),cTelefono,cCorreo WITH RESUME;
						END FOREACH;
					END IF;	
					
				IF iCantReg < iLimit THEN
					LET iLimit = iLimit - iCantReg;
					LET iCantReg = 0;
					LET cTarjeta = "";
					
					IF sTipo > sContReg THEN
						LET sTipo = sTipo - sContReg;
					ELSE
						LET sTipo = 0;
					END IF;

					-- **********************************************************************************
					-- Extrae la informacion del Sistema de Prestamo personal, credinomina y reestructura
					-- **********************************************************************************
					IF pNumCte <> '' OR iSistema = 7 THEN
					--IFRS Se contempla nuevo estatus vigente por Etapas	
						FOREACH
							SELECT skip sTipo LIMIT iLimit
							   mcd.num_credito,mcd.num_producto||" "||df.nombre_prod, tc.descripcion
							INTO cCuenta,cProducto,cEstatus
							FROM bdicred:"informix".sd_maecredcrd mcd,
							   bdicred:"informix".sd_definicion df,
							   bdicred:"informix".sd_tipocartera tc
							WHERE numcte = cNumCte 
							AND mcd.num_producto = df.num_producto
							AND df.num_producto IN ('6300','6400','7600','7700','7800')
							AND mcd.status_cred = tc.status_cred
							AND mcd.status_cred IN ('AA','BA','BT','FF','E1','E2','E3')
							--AND mcd.status_cred IN ('AA','BA','BT','FF')
							ORDER BY 1				

							IF EXISTS (SELECT cuenta
							FROM bdinteg:"informix".si_altaserv_edoctamov
							WHERE empresa = pEmpresa				
							AND numcte = cNumCte
							AND cuenta = cCuenta) THEN
							LET cEstatusCFDI = "T";
							ELSE
							LET cEstatusCFDI = "F";
							END IF;
				
							LET iCantReg = iCantReg + 1;
							LET iSkip = iCantReg;
							RETURN cCod_ret,cNomCompleto,NVL(cTarjeta,""),cProducto,
							cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo WITH RESUME;
						END FOREACH;
					END IF;
				END IF;
			END IF;
			
			IF iSkip = 0 THEN
				LET cCod_ret = "000000001";
				
				RETURN cCod_ret,cNomCompleto,NVL(cTarjeta,""),cProducto,
				cEstatusCFDI,NVL(cCuenta,""),cEstatus,cTelefono,cCorreo;
			END IF;
		END IF;	
	
	END
END PROCEDURE;