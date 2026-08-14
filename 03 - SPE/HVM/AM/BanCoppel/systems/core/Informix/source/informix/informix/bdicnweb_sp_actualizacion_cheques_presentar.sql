CREATE PROCEDURE "informix".sp_actualizacion_cheques_presentar(	pBandera			CHAR(2),
																pRegistros 			INTEGER, 
																pRecuperacion 		INTEGER,
																pUsuario 			CHAR(8), 
																pIdFuncion 			CHAR(10), 
																pFechaPresentacion  CHAR(10),
																pCtaDelCheque 		CHAR(20),
																pNumCheque 			CHAR(7),
																pMonto 				DECIMAL(14,2))


RETURNING
	CHAR(5)         AS cod_ret,
    CHAR(80)        AS desc_ret,
	CHAR(4)         AS sucursal,
	CHAR(40)        AS desc_sucursal,
	CHAR(10)        AS fecha_presentacion,
	CHAR(20)        AS cuenta_deposito,
	CHAR(3)         AS cve_banco,
	CHAR(40)        AS desc_banco,
	CHAR(20)        AS cuenta_cheque,
	INTEGER        	AS numero_cheque,
	MONEY(14,2)     AS importe,
	CHAR(10)		AS fecha_hoy,
	INTEGER			AS no_registros,
	DATE 			AS dia_feriado, 
	CHAR(30) 		AS desc_dia_feriado,
	CHAR(1) 		AS laborable;
		

 	DEFINE iSqlErr          INTEGER;
    DEFINE cDescRet         CHAR(80);
    DEFINE cCodRet          CHAR(5);
	DEFINE pEmpresa			CHAR(3);
	DEFINE cSucursal		CHAR(4);
	DEFINE cDescSucursal	CHAR(40);
	DEFINE cFechaPres		CHAR(10);
	DEFINE cCtaDeposito		CHAR(20);
	DEFINE cBanco           CHAR(3);
	DEFINE cDescBanco       CHAR(40);
	DEFINE cCtaDelCheque    CHAR(20);
	DEFINE iNumCheque    	INTEGER;
	DEFINE mImporte         MONEY(14,2);
	DEFINE cFechaHoy		CHAR(10);
	DEFINE cDescDiaFeriado 	CHAR(30);
	DEFINE cLaborable 		CHAR(1);
	DEFINE iNoRegistros 	INTEGER;
	DEFINE dDiaFeriado		CHAR(30);
	DEFINE icontador 		INTEGER;
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET pEmpresa			= '001';
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "00000";
	
	LET cSucursal			= "";
	LET cDescSucursal		= "";
	LET cFechaPres			= "";
	LET cCtaDeposito		= "";
	LET cBanco				= "";
	LET cDescBanco			= "";
	LET cCtaDelCheque		= "";
	LET iNumCheque    		= 0;
    LET mImporte		    = 0.0;
	LET cFechaHoy			= "";
	LET iNoRegistros		= 0;
	LET dDiaFeriado 		= '';
	LET cDescDiaFeriado 	= '';
	LET cLaborable 			= '';
	LET icontador 			= 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/Antonio/Contabilidad/sp_actualizacion_cheques_presentar.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		IF pBandera = '' THEN
			LET cCodRet = '00003';
			LET cDescRet = 'BANDERA SE ENCUENTRA VACIA';
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;

		ELIF pBandera = '3' THEN
				IF pUsuario = '' OR pIdFuncion = '' OR pFechaPresentacion = '' OR pCtaDelCheque = ''  THEN
					LET cCodRet = '00003';
					RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
						dDiaFeriado, cDescDiaFeriado, cLaborable;
				END IF;
		ELIF pBandera = '4' THEN
				IF pUsuario = '' OR pIdFuncion = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
						dDiaFeriado, cDescDiaFeriado, cLaborable;
				END IF;
		ELIF pBandera = '5' or pBandera = '6' THEN
				IF pUsuario = '' OR pIdFuncion = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
						dDiaFeriado, cDescDiaFeriado, cLaborable;
				END IF;
		END IF;
		
		IF pBandera = '1' THEN
			FOREACH
				EXECUTE PROCEDURE bdicheq:"informix".sp_cce_consultarchqsxpresentar2(pEmpresa, pRegistros, pRecuperacion)
				INTO cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy

				LET icontador = icontador + 1;

				RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable WITH RESUME;
			END FOREACH;

		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE bdicheq:"informix".sp_cce_consultarchqsxpresentar2_totales(pEmpresa)
			INTO cCodRet,iNoRegistros;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		ELIF pBandera = '3' THEN
			EXECUTE PROCEDURE "informix".sp_ope_actualizarfechacheques(pUsuario, pIdFuncion, pFechaPresentacion,pCtaDelCheque,pNumCheque,pMonto)
			INTO cCodRet;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		ELIF pBandera = '4' THEN
			FOREACH
				EXECUTE PROCEDURE "informix".sp_ope_consultacheqsxpresentar(pUsuario, pIdFuncion, pRegistros, pRecuperacion)
				INTO cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy

				LET icontador = icontador + 1;

				RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable with resume;
			END FOREACH
		ELIF pBandera = '5' THEN
			EXECUTE PROCEDURE 'informix'.sp_ope_consultacheqsxpresentar_totales(pUsuario, pIdFuncion)
			INTO cCodRet, iNoRegistros;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		ELIF pBandera = '6' THEN
			EXECUTE PROCEDURE 'informix'.sp_ope_validadiaferiado(pUsuario, pIdFuncion)
			INTO cCodRet, dDiaFeriado, cDescDiaFeriado, cLaborable;	
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0  THEN
			LET cCodRet= '00017';
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		END IF;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Avila Perez Tagle',
'FECHA: 03/03/2023',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIÃN DE CHEQUES SBC POR PRESENTAR', 
'DESCRIPCION: SPL principal de actualizacion de cheques por presentar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_actualizarfechacheques(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaPresentacion  CHAR(10),pCtaDelCheque CHAR(20),pNumCheque CHAR(7),pMonto DECIMAL(14,2))
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cDescRet   CHAR(80);
	DEFINE dtFechaHoy DATE;
	DEFINE iNumDia INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cDescRet = '';
	LET dtFechaHoy = '';
	LET iNumDia = 0;
	 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_actualizarfechacheques.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR cEmpresa = '' OR pFechaPresentacion = '' OR pCtaDelCheque = '' OR pNumCheque = '' OR  pMonto IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		SET ISOLATION TO DIRTY READ; 
		
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_fechas)} fecha_hoy
        INTO dtFechaHoy
        FROM bdicheq:'informix'.sc_fechas
        WHERE empresa = cEmpresa;
		
		IF pFechaPresentacion = dtFechaHoy THEN
			LET cCodRet = '00724';
			RETURN cCodRet;	
		END IF;
		
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_fechas)} WEEKDAY(dtFechaHoy)
		INTO iNumDia
		FROM bdicheq:'informix'.sc_fechas  
		WHERE empresa = cEmpresa;
		
		IF (iNumDia = 6 OR iNumDia = 0) THEN
			LET cCodRet = '00723';
			RETURN cCodRet;	
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_cce_actualizarfechacheques(cEmpresa,pFechaPresentacion,pCtaDelCheque,pNumCheque,pMonto)	
		INTO cCodRetSp, cDescRet;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_actualizarfechacheques';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00721';
		END IF;		
			RETURN cCodRet;	
		END ;
END PROCEDURE

DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 23/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIï¿½N DE CHEQUES',
'DESCRIPCION:SPL para la actualizacion de la fecha de presentacion del cheque para que sea tomado en cuenta por el proceso de la presentacion.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultacheqsxpresentar(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(4)         AS sucursal,
		CHAR(40)        AS desc_sucursal,
		CHAR(10)        AS fecha_presentacion,
		CHAR(20)        AS cuenta_deposito,
		CHAR(3)         AS cve_banco,
		CHAR(40)        AS desc_banco,
		CHAR(20)        AS cuenta_cheque,
		INTEGER        	AS numero_cheque,
		MONEY(18,2)     AS importe,
		CHAR(10)		AS fecha_hoy;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE cDescSucursal CHAR(40);
	DEFINE cFechaPres CHAR(10);
	DEFINE cCtaDeposito CHAR(20);
	DEFINE cBanco CHAR(3);
	DEFINE cDescBanco CHAR(40);
	DEFINE cCtaDelCheque CHAR(20);
	DEFINE iNumCheque INTEGER;
	DEFINE mImporte MONEY(14,2);
	DEFINE cFechaHoy CHAR(10);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cDescRet = '';
	LET cEmpresa = '001';
	LET cSucursal = '';
	LET cDescSucursal = '';
	LET cFechaPres = '';
	LET cCtaDeposito = '';
	LET cBanco = '';
	LET cDescBanco = '';
	LET cCtaDelCheque = '';
	LET iNumCheque = 0;
    LET mImporte = 0.0;
	LET cFechaHoy = '';	
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacheqsxpresentar.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
		EXECUTE PROCEDURE bdicheq:'informix'.sp_cce_consultarchqsxpresentar2(cEmpresa,pRegistros, pRecuperacion)
			INTO cCodRetSp,cDescRet,cSucursal,cDescSucursal,cFechaPres ,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque ,mImporte,cFechaHoy		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_consultarchqsxpresentar2';				
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003'; 
			END IF;
			IF  iRecuperacion = 0 AND pRegistros = 0 AND iCodRetSp = 2  THEN
				LET cCodRet = '00017';	
				RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
			ELIF  iRecuperacion = 0 AND pRegistros > 0  AND iCodRetSp = 2  THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
			END IF;	
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,cSucursal, UPPER(TRIM(cDescSucursal)),cFechaPres ,cCtaDeposito ,cBanco ,UPPER(TRIM(cDescBanco)),cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy WITH RESUME;	
		END FOREACH;
		
		--IF iRecuperacion = 0 AND pRegistros = 0 THEN 
		--		LET cCodRet ='00017';
		--		RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		--	ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
		--		LET cCodRet ='1001';
		--		RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		--	END IF;		
	END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 23/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIï¿½N DE CHEQUES',
'DESCRIPCION:SPL que consulta el detalle los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultacheqsxpresentar_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))	
		RETURNING CHAR(5) AS codret,                           
			INTEGER AS num_registros;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(100);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '000000';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacheqsxpresentar_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;	
		
		EXECUTE PROCEDURE bdicheq:'informix'.sp_cce_consultarchqsxpresentar2_totales('001')
		INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bdicheq:sp_cce_consultarchqsxpresentar2_totales';
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;

		RETURN cCodRet, iNumRegistros;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 23/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIï¿½N DE CHEQUES',
'DESCRIPCION:SPL que consulta el total los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_validadiaferiado(pUsuario CHAR(8), pIdFuncion CHAR(10))
		
		RETURNING CHAR(5) AS codret,
			DATE AS dia_feriado, 
			CHAR(30) AS desc_dia_feriado,
			CHAR(1) AS laborable;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE dFecha DATE;
		DEFINE dDiaFeriado DATE;
		DEFINE cDescDiaFeriado CHAR(30);
		DEFINE cLaborable CHAR(1);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET dFecha = DATE(CURRENT);
		LET dDiaFeriado = '';
		LET cDescDiaFeriado = '';
		LET cLaborable = '';
		LET iNoRegistros = 0;
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, dDiaFeriado, cDescDiaFeriado, cLaborable;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_validadiaferiado.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dDiaFeriado, cDescDiaFeriado, cLaborable;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dDiaFeriado, cDescDiaFeriado, cLaborable;
			END IF;
			
			EXECUTE PROCEDURE bdinteg:'informix'.sp_validardiaferiado(cEmpresa, dFecha)
			INTO cCodRetSp, dDiaFeriado, cDescDiaFeriado, cLaborable;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdinteg:sp_validardiaferiado';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00723'; --EL DÃA DE HOY NO ES UN DÃA LABORABLE
			END IF;
			
			RETURN cCodRet, dDiaFeriado, cDescDiaFeriado, cLaborable;
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIÃN DE CHEQUES SBC POR PRESENTAR', 
'DESCRIPCION: SPL que se encarga de validar si la fecha del dÃ­a actual pertenece a un dÃ­a feriado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_monitor_envio_cheques(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                CHAR(3)                                                 AS banco,
                CHAR(40)                                                AS descripcionBanco,
                CHAR(40)                                                AS cuenta,
                INTEGER                                                 AS numeroCheque,
                DECIMAL(14,2)                                  		    AS montoOrigen,
                DATE                                                    AS fechaAlta,
                DATETIME HOUR TO FRACTION(3)    						AS hora,
                CHAR(44)                                                AS sucursal,
                SMALLINT                                                AS diasRetorno,
                CHAR(16)                                                AS folioSucursal,
                CHAR(4)                                                 AS transcc,
                CHAR(4)                                                 AS claveSucursal,
                CHAR(25)                                                AS digitalizado,
                CHAR(2)                                                 AS pre,
                CHAR(2)                                                 AS estatusColor,
                INTEGER 												AS totalchequesenvio,
                INTEGER 												AS iTotalOperados,
                INTEGER 												AS iTotalDigitalizados,
                INTEGER 												AS iTotalPresentados,
                INTEGER 												AS iTotalPorPresentar,
                INTEGER 												AS iTotalPorRecibir;


        
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE iNoRegistros INTEGER;
        DEFINE cBanco CHAR(3);
        DEFINE cDescripcionBanco CHAR(40);
        DEFINE cReferencia CHAR(40);
        DEFINE cCuenta CHAR(40);
        DEFINE iNumeroCheque INTEGER;
        DEFINE dMontoOrigen DECIMAL(14,2);
        DEFINE dFechaAlta DATE;
        DEFINE dHora DATETIME HOUR TO FRACTION(3);
        DEFINE cSucursal CHAR(44);
        DEFINE sDiasRetorno SMALLINT;
        DEFINE cFolioSucursal CHAR(16);
        DEFINE cTranscc CHAR(4);
        DEFINE cClaveSucursal CHAR(4);
        DEFINE cDigitalizado CHAR(25);
        DEFINE cPre CHAR(2);
        DEFINE cEstatusColor CHAR(2);
        DEFINE bBanderaMovimientoCheques BOOLEAN;
        DEFINE bBanderaMovimientoCredito BOOLEAN;
        DEFINE cPresentado CHAR(1);
        DEFINE cFechahoracap CHAR(25);
        DEFINE dFechaIni DATE;
        DEFINE iCuenta BIGINT;
        DEFINE cTieneMovto CHAR(1);
		DEFINE iTotalOperados      INTEGER;
        DEFINE iTotalDigitalizados INTEGER;
        DEFINE iTotalPresentados   INTEGER;
        DEFINE iTotalPorPresentar  INTEGER;
        DEFINE iTotalPorRecibir    INTEGER;
        DEFINE iTotalRegistros INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET iNoRegistros = 0;
        LET cBanco = '';
        LET cDescripcionBanco = '';
        LET cReferencia = '';
        LET cCuenta = '';                                       
        LET iNumeroCheque = 0;
        LET dMontoOrigen = 0.0;
        LET dFechaAlta = '';
        LET dHora = '';
        LET cSucursal = '';
        LET sDiasRetorno = 0;
        LET cFolioSucursal = '';
        LET cTranscc = '';
        LET cClaveSucursal = '';
        LET cDigitalizado = "";
        LET cPre = "";
        LET cEstatusColor = "0";
        LET bBanderaMovimientoCheques = 'f';
        LET bBanderaMovimientoCredito = 'f';
        LET cPresentado = '';
        LET cFechahoracap = '';
        LET dFechaIni = CURRENT;        
        LET iCuenta = 0;        
        LET cTieneMovto = '';
		LET iTotalOperados      = 0;
        LET iTotalDigitalizados = 0;
        LET iTotalPresentados   = 0;
        LET iTotalPorPresentar  = 0;
        LET iTotalPorRecibir    = 0;
        LET iTotalRegistros = 0;

	BEGIN
		-- ****************************************************************************
		-- *                        CONTROL DE ERRORES                                *
		-- ****************************************************************************
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor, iTotalRegistros, 
									iTotalOperados, iTotalDigitalizados, iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        --SET DEBUG FILE TO "/tmp/mfinis/sp_monitor_envio_cheques.out";
	    --TRACE ON;

		-- ****************************************************************************
		-- *                   VALIDAR LOS PARAMETROS DE ENTRADA                      *
		-- ****************************************************************************
		IF pBandera = '1' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor, iTotalRegistros, 
									iTotalOperados, iTotalDigitalizados, iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
			END IF;
		ELIF pBandera = '2' THEN
			IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor, iTotalRegistros, 
									iTotalOperados, iTotalDigitalizados, iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
			END IF;
		END IF;


		IF pBandera = '1' THEN
			FOREACH
            EXECUTE PROCEDURE "informix".sp_monitorenviochequesope(pUsuario, pIdFuncion, pRegistros, pRecuperacion)
			INTO cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor
			RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor, iTotalRegistros, 
									iTotalOperados, iTotalDigitalizados, iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir WITH RESUME;
            END FOREACH
		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE "informix".sp_monitorenviochequesope_totales(pUsuario, pIdFuncion)
            INTO cCodRet, iTotalRegistros, iTotalOperados, iTotalDigitalizados, 
                           iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
			RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor, iTotalRegistros, 
									iTotalOperados, iTotalDigitalizados, iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
		END IF;
	END;
END PROCEDURE
DOCUMENT 
"AUTOR : Eduardo Ãvila PÃ©rez Tagle",
'MODULO: CÃ¡maras de compensaciÃ³n',
"FUNCIONAMIENTO:SP padre de camaras de compensaciÃ³n - monitor envÃ­o de cheques",
"FECHA : 03-03-2023",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_monitorenviochequesope(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5)             AS codret,
                CHAR(3)                       AS banco,
                CHAR(40)                      AS descripcionBanco,
                CHAR(40)                      AS cuenta,
                INTEGER                       AS numeroCheque,
                DECIMAL(14,2)                 AS montoOrigen,
                DATE                          AS fechaAlta,
                DATETIME HOUR TO FRACTION(3)  AS hora,
                CHAR(44)                      AS sucursal,
                SMALLINT                      AS diasRetorno,
                CHAR(16)                      AS folioSucursal,
                CHAR(4)                       AS transcc,
                CHAR(4)                       AS claveSucursal,
                CHAR(25)                      AS digitalizado,
                CHAR(2)                       AS pre,
                CHAR(2)                       AS estatusColor;
        
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE iNoRegistros INTEGER;
        DEFINE cBanco CHAR(3);
        DEFINE cDescripcionBanco CHAR(40);
        DEFINE cReferencia CHAR(40);
        DEFINE cCuenta CHAR(40);
        DEFINE iNumeroCheque INTEGER;
        DEFINE dMontoOrigen DECIMAL(14,2);
        DEFINE dFechaAlta DATE;
        DEFINE dHora DATETIME HOUR TO FRACTION(3);
        DEFINE cSucursal CHAR(44);
        DEFINE sDiasRetorno SMALLINT;
        DEFINE cFolioSucursal CHAR(16);
        DEFINE cTranscc CHAR(4);
        DEFINE cClaveSucursal CHAR(4);
        DEFINE cDigitalizado CHAR(25);
        DEFINE cPre CHAR(2);
        DEFINE cEstatusColor CHAR(2);
        DEFINE bBanderaMovimientoCheques BOOLEAN;
        DEFINE bBanderaMovimientoCredito BOOLEAN;
        DEFINE cPresentado CHAR(1);
        DEFINE cFechahoracap CHAR(25);
        DEFINE dFechaIni DATE;
        DEFINE iCuenta BIGINT;
        DEFINE cTieneMovto CHAR(1);
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET iNoRegistros = 0;
        LET cBanco = '';
        LET cDescripcionBanco = '';
        LET cReferencia = '';
        LET cCuenta = '';                                       
        LET iNumeroCheque = 0;
        LET dMontoOrigen = 0.0;
        LET dFechaAlta = '';
        LET dHora = '';
        LET cSucursal = '';
        LET sDiasRetorno = 0;
        LET cFolioSucursal = '';
        LET cTranscc = '';
        LET cClaveSucursal = '';
        LET cDigitalizado = "";
        LET cPre = "";
        LET cEstatusColor = "0";
        LET bBanderaMovimientoCheques = 'f';
        LET bBanderaMovimientoCredito = 'f';
        LET cPresentado = '';
        LET cFechahoracap = '';
        LET dFechaIni = CURRENT;     
        LET iCuenta = 0;        
        LET cTieneMovto = '';
        
        BEGIN
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor;  
                END EXCEPTION;
        
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_monitorenviochequesope.out';
                --TRACE ON;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor;  
                END IF;
                
                -- VALIDACION DE LA PAGINACION
                IF pRegistros < 0 OR pRecuperacion < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor;  
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor;  
                END IF;
                
                FOREACH SELECT SKIP pRegistros FIRST pRecuperacion *
                                INTO cCodRetSp, cBanco, cDescripcionBanco, cReferencia, iNumeroCheque, dMontoOrigen, dFechaAlta, 
                                        dHora, cSucursal, sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cTieneMovto
                                FROM 
                                (SELECT a.cod_ret
                                        , a.banco
                                        , a.desc_banco
                                        , a.referencia
                                        , a.num_cheque
                                        , a.monto_orig
                                        , a.fecha_alta
                                        , a.hora
                                        , a.sucursal
                                        , a.dias_ret
                                        , a.folio_suc
                                        , a.transcc
                                        , a.cve_suc
                                        , DECODE(transcc, '0250', (SELECT CASE WHEN COUNT(folio_suc) > 0 THEN '1' ELSE '0' END 
                                        FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' 
                                        AND folio_suc = a.folio_suc 
                                        AND sucursal = a.cve_suc 
                                        AND transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban) 
                                        AND cancelad <> 'S'), '6250', (SELECT CASE WHEN COUNT(folio_suc) > 0 THEN '1' ELSE '0' END 
                                        FROM bdicred:"informix".sd_movdia WHERE empresa = '001' AND folio_suc = a.folio_suc 
                                        AND sucursal = a.cve_suc AND reversado = 'N')) AS tiene_movto
										
                                FROM (TABLE (PROCEDURE bdicheq:"informix".sp_cce_consultarchequesmovs(cEmpresa, dFechaIni)) AS
                                a(cod_ret, banco, desc_banco, referencia, num_cheque, monto_orig, fecha_alta, hora, sucursal, dias_ret, folio_suc, transcc, cve_suc)))
                                WHERE tiene_movto <> '0'
                                
                                LET cReferencia = TRIM(SUBSTR(cReferencia,6,20));
                                LET iCuenta = cReferencia ::BIGINT;
                                LET cCuenta = iCuenta;
                                
                                SELECT {+AVOID_FULL(bditef:"informix".cce_cheques_det)} presentado, fechahoracap INTO cPresentado, cFechahoracap FROM bditef:"informix".cce_cheques_det 
                                WHERE empresa = '001' AND cvebanco = cBanco AND numcuenta = cCuenta  
                                AND numcheque = iNumeroCheque AND fecha_alta = dFechaAlta;
                                
                                IF cPresentado == "1" THEN
                                        LET cPre = "SI";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "1";
                                ELIF cPresentado == "0" AND cFechahoracap <> "" THEN
                                        LET cPre = "";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "2";
                                ELSE
                                        LET cPre = "";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "0";
                                END IF;

                                RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, sDiasRetorno, 
                                        cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor WITH RESUME;
                END FOREACH
				
                IF DBINFO("sqlca.sqlerrd2") = 0 THEN
                        LET cCodRet = "00017";
                        RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor;                  
                END IF;         
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando MartÃ­n',
'FECHA: 29/10/2014',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor EnvÃ­o Cheques',
'DESCRIPCIÃN: SPL que consulta los cheques en transito',
'cEstatusColor: 0 -> Rojo, cEstatusColor: 1 --Verde, cEstatusColor: 2 --> Amarillo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_monitorenviochequesope_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
                RETURNING CHAR(5) AS codret,
                INTEGER AS totalchequesenvio,
                INTEGER AS iTotalOperados,
                INTEGER AS iTotalDigitalizados,
                INTEGER AS iTotalPresentados,
                INTEGER AS iTotalPorPresentar,
                INTEGER AS iTotalPorRecibir;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE iNoRegistros INTEGER;
        DEFINE cBanco CHAR(3);
        DEFINE cDescripcionBanco CHAR(40);
        DEFINE cReferencia CHAR(40);
        DEFINE cCuenta CHAR(40);
        DEFINE iNumeroCheque INTEGER;
        DEFINE dMontoOrigen DECIMAL(14,2);
        DEFINE dFechaAlta DATE;
        DEFINE dHora DATETIME HOUR TO FRACTION(3);
        DEFINE cSucursal CHAR(44);
        DEFINE sDiasRetorno SMALLINT;
        DEFINE cFolioSucursal CHAR(16);
        DEFINE cTranscc CHAR(4);
        DEFINE cClaveSucursal CHAR(4);
        DEFINE cDigitalizado CHAR(25);
        DEFINE cPre CHAR(2);
        DEFINE cEstatusColor CHAR(2);
        DEFINE bBanderaMovimientoCheques BOOLEAN;
        DEFINE bBanderaMovimientoCredito BOOLEAN;
        DEFINE cPresentado CHAR(1);
        DEFINE cFechahoracap CHAR(25);
        DEFINE dFechaIni DATE;
        DEFINE iCuenta BIGINT;
        DEFINE iTotalOperados      INTEGER;
        DEFINE iTotalDigitalizados INTEGER;
        DEFINE iTotalPresentados   INTEGER;
        DEFINE iTotalPorPresentar  INTEGER;
        DEFINE iTotalPorRecibir    INTEGER;
        DEFINE cTieneMovto CHAR(1);
        DEFINE iTotalRegistros INTEGER;
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET iNoRegistros = 0;
        LET cBanco = '';
        LET cDescripcionBanco = '';
        LET cReferencia = '';
        LET cCuenta = '';                                       
        LET iNumeroCheque = 0;
        LET dMontoOrigen = 0.0;
        LET dFechaAlta = '';
        LET dHora = '';
        LET cSucursal = '';
        LET sDiasRetorno = 0;
        LET cFolioSucursal = '';
        LET cTranscc = '';
        LET cClaveSucursal = '';
        LET cDigitalizado = "";
        LET cPre = "";
        LET cEstatusColor = "0";
        LET bBanderaMovimientoCheques = 'f';
        LET bBanderaMovimientoCredito = 'f';
        LET cPresentado = '';
        LET cFechahoracap = '';
        LET dFechaIni = CURRENT;     
        LET iCuenta = 0;        
        LET iTotalOperados      = 0;
        LET iTotalDigitalizados = 0;
        LET iTotalPresentados   = 0;
        LET iTotalPorPresentar  = 0;
        LET iTotalPorRecibir    = 0;
        LET cTieneMovto = '';
        LET iTotalRegistros = 0;
        
        
        BEGIN
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iTotalRegistros, iTotalOperados, iTotalDigitalizados, 
                           iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
                END EXCEPTION;
                
                ON EXCEPTION IN (-206)
                END EXCEPTION WITH RESUME;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_monitorenviochequesope_totales.out';
                --TRACE ON;

               SET ISOLATION TO DIRTY READ;
               SET LOCK MODE TO WAIT 3;
                
                IF pUsuario = '' OR pIdFuncion = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iTotalRegistros, iTotalOperados, iTotalDigitalizados, 
                           iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iTotalRegistros, iTotalOperados, iTotalDigitalizados, 
                           iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
                END IF;
                
                
                DROP TABLE cep_monitorcheques_tmp;
                
                -- CREACION DE TABLA TEMPORAL
                CREATE TEMP TABLE cep_monitorcheques_tmp(
                        diasRetorno SMALLINT,
                        digitalizado CHAR(25),
                        pre CHAR(2),
                        estatusColor CHAR(2),
                        presentado CHAR(1)) WITH NO LOG;
                
                
                --FOREACH SELECT COUNT(*) INTO iTotalRegistros
                  FOREACH SELECT * INTO cCodRetSp, cBanco, cDescripcionBanco, cReferencia, iNumeroCheque, dMontoOrigen, dFechaAlta, 
                                dHora, cSucursal, sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cTieneMovto   
                        FROM            
                        (SELECT a.cod_ret
                                , a.banco
                                , a.desc_banco
                                , a.referencia
                                , a.num_cheque
                                , a.monto_orig
                                , a.fecha_alta
                                , a.hora
                                , a.sucursal
                                , a.dias_ret
                                , a.folio_suc
                                , a.transcc
                                , a.cve_suc
                                , DECODE(transcc, '0250', (SELECT CASE WHEN COUNT(folio_suc) > 0 THEN '1' ELSE '0' END
                                FROM bdicheq:"informix".sc_movdia WHERE empresa = cEmpresa AND folio_suc = a.folio_suc 
                                AND sucursal = a.cve_suc AND transacc IN (SELECT transacc FROM bditef:"informix".cce_mapeo_cecoban) 
                                AND cancelad <> 'S'), '6250', (SELECT CASE WHEN COUNT(folio_suc) > 0 THEN '1' ELSE '0' END 
                                FROM bdicred:"informix".sd_movdia WHERE empresa = cEmpresa AND folio_suc = a.folio_suc 
                                AND sucursal = a.cve_suc AND reversado = 'N')) AS tiene_movto
                                
                        FROM (TABLE (PROCEDURE bdicheq:"informix".sp_cce_consultarchequesmovs(cEmpresa, dFechaIni)) AS
                        a(cod_ret, banco, desc_banco, referencia, num_cheque, monto_orig, fecha_alta, hora, sucursal, dias_ret, folio_suc, transcc, cve_suc)))
                        WHERE tiene_movto <> '0'
                        
                        LET cReferencia = TRIM(SUBSTR(cReferencia,6,20));
                        LET iCuenta = cReferencia ::BIGINT;
                        LET cCuenta = iCuenta;
                        
                        SELECT {+AVOID_FULL(bditef:"informix".cce_cheques_det)} presentado, fechahoracap INTO cPresentado, cFechahoracap FROM bditef:"informix".cce_cheques_det 
                                                WHERE empresa = cEmpresa AND cvebanco = cBanco AND numcuenta = cCuenta  
                                                AND numcheque = iNumeroCheque AND fecha_alta = dFechaAlta;
                                                
                                IF cPresentado == "1" THEN
                                        LET cPre = "SI";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "1";
                                ELIF cPresentado == "0" AND cFechahoracap <> "" THEN
                                        LET cPre = "";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "2";
                                ELSE
                                        LET cPre = "";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "0";
                                END IF;
                        
                                INSERT INTO cep_monitorcheques_tmp(diasRetorno, digitalizado,  pre,  estatusColor, presentado)
                                VALUES (sDiasRetorno, cDigitalizado, cPre, cEstatusColor, cPresentado);
                        LET iTotalRegistros = iTotalRegistros + 1; 
                END FOREACH
                
                SELECT COUNT(*) INTO iTotalOperados FROM cep_monitorcheques_tmp;
                SELECT COUNT(digitalizado) INTO iTotalDigitalizados FROM cep_monitorcheques_tmp;
                SELECT COUNT(presentado) INTO iTotalPresentados FROM cep_monitorcheques_tmp WHERE presentado = '1';
                SELECT COUNT(*) INTO iTotalPorPresentar  FROM cep_monitorcheques_tmp WHERE pre = "" AND diasRetorno = '1';
                LET iTotalPorRecibir = iTotalOperados - iTotalDigitalizados;
                
                IF iTotalRegistros == 0 THEN 
                        LET cCodRet = '00017';
                END IF;

                RETURN cCodRet, iTotalRegistros, iTotalOperados, iTotalDigitalizados, 
                           iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando MartÃ­n',
'FECHA: 29/10/2014',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor EnvÃ­o Cheques',
'DESCRIPCIÃN: SPL que consulta los cheques en transito',
'cEstatusColor: 0 -> Rojo, cEstatusColor: 1 --Verde, cEstatusColor: 2 --> Amarillo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_libracionsalvobuencobro(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pDiaslib CHAR(6), pFechaReporte CHAR(10),  pPassword CHAR(40), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(6)       AS codRet,
              INTEGER       AS totalRegistros,
              CHAR(20)	    AS Cuenta,
			  CHAR(4)	    AS Sucursal,
			  DATE 		    AS FechaAlta,
			  CHAR(4)	    AS Transacc,
			  CHAR(40)	    AS Referencia,
			  INTEGER	    AS NumeroChque,
			  SMALLINT	    AS DiasOri,
			  MONEY(14,2)   AS MontoOri,
			  CHAR(2)	    AS Siglas,
			  CHAR (40)     AS Banco,
			  CHAR (10)     AS Fecharep;

-- DECLARACIÃN DE VARIABLES
    DEFINE iSqlErr          INTEGER;
    DEFINE cCodRet          CHAR(6);

    DEFINE iTotalRegistros  INTEGER;
    DEFINE cCuenta          CHAR(20);
    DEFINE cSucursal        CHAR(4);
    DEFINE dFechaAlta       DATE;
    DEFINE cTransaccion     CHAR(4);
    DEFINE cReferencia      CHAR(40);
    DEFINE iNumCheque       INTEGER;
    DEFINE sDiasOri         SMALLINT;
    DEFINE mMontoOri        MONEY(14,2);
    DEFINE cSiglas          CHAR (2);
    DEFINE cBanco           CHAR(40);
    DEFINE cFecharep        CHAR(10);
    DEFINE cStatus          CHAR(1);
    DEFINE cErrorProceso    CHAR(1);
    DEFINE cError           CHAR(5);

-- INICIALIZACIÃN DE VARIABLES
    LET iSqlErr = "";
    LET cCodRet = "00000";

    LET iTotalRegistros = 0;
    LET iTotalRegistros = 0;
    LET cCuenta         = "";
    LET cSucursal       = "";
    LET dFechaAlta      = "";
    LET cTransaccion    = "";
    LET cReferencia     = "";
    LET iNumCheque      = 0;
    LET sDiasOri        = 0;
    LET mMontoOri       = 0.0;
    LET cSiglas         = "";
    LET cBanco          = "";
    LET cFecharep       = "";
    LET cStatus         = '';
    LET cErrorProceso   = '';
    LET cError          = '';

    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
		END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cc_libracionsalvobuencobro.out';
		--TRACE ON;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003'; -- Bandera o usuario o id funcion vacia
			RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
        INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
		END IF;

        IF pBandera = '1' THEN
            EXECUTE PROCEDURE "informix".sp_ope_diasret(pUsuario , pIdFuncion, pDiaslib)
            INTO cCodRet;
            RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF

        IF pBandera = '2' THEN
            EXECUTE PROCEDURE "informix".sp_ope_liberasalret(pUsuario , pIdFuncion)
            INTO cCodRet;
            RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF

        IF pBandera = '3' THEN
            EXECUTE PROCEDURE "informix".sp_ope_reportesbc_totales(pUsuario, pIdFuncion , pFechaReporte )
            INTO cCodRet, iTotalRegistros;
            RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF

        IF pBandera = '4' THEN
            FOREACH
                EXECUTE PROCEDURE "informix".sp_ope_reportesbc(pUsuario , pIdFuncion, pFechaReporte, pRegistros, pRecuperacion)
                INTO cCodRet, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep
                
                RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep WITH RESUME;
            END FOREACH
        END IF

        IF pBandera = '5' THEN
            EXECUTE PROCEDURE "informix".sp_ope_validapassword(pUsuario, pIdFuncion , pPassword )
            INTO cCodRet;
            RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF 
        
        IF pBandera = '6' THEN
            EXECUTE PROCEDURE "informix".sp_verificastatusliberaret(pUsuario)
            INTO cCodRet, cSucursal, cSiglas, cReferencia;
            
            RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , TRIM(cReferencia), iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00017';
		RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF

    END

END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 05/05/2023',
'MODULO: CAMARAS',
'FUNCIONALIDAD: SALDO BUEN COBRO', 
'DESCRIPCION: SPL Maestro encargado de ejecutar los procedimientos alamacenado de la funcionalidad de liberaciÃ³n saldo buen cobro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_diasret(pUsuario CHAR(8), pIdFuncion CHAR(10), pDiaslib CHAR(6))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE bInTransaccion BOOLEAN;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET bInTransaccion = 'f';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaccion = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_diasret.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		BEGIN WORK;
		
		IF bInTransaccion = 'f' THEN
			COMMIT WORK;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:'informix'.dias_ret(cEmpresa, pDiaslib)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP dias_ret';
		ELIF iCodRetSp = 4 THEN
			LET cCodRet = '00452'; --SISTEMA TEMPORALMENTE FUERA DE SERVICIO
		ELIF iCodRetSp = 971 THEN
			LET cCodRet = '00760'; --PROCESO DE LIBERACION DE RETENIDOS YA EFECTUADO
		ELIF iCodRetSp <> 0 THEN
			LET cCodRet = cCodRetSp;
		END IF;

		IF cCodRet::INT > 0 THEN
			LET bInTransaccion = 'f';
			BEGIN WORK;
		END IF;
		
		IF bInTransaccion = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 03/03/2016',
'DESCRIPCION: spl para realizar la liberaciÃÂ³n salvo buen cobro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_liberasalret(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cIdDevolucion CHAR(2);
	DEFINE cDescipcionMotivo CHAR(70);
	DEFINE bInTransaccion BOOLEAN;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cIdDevolucion = '';
	LET cDescipcionMotivo = '';
	LET bInTransaccion = 'f';
	LET cEmpresa = '001';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaccion = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_liberasalret.out';
		--TRACE ON;

		DELETE FROM "informix".sw_verificastatusliberaret WHERE usuario_insert = pUsuario;
		INSERT INTO "informix".sw_verificastatusliberaret VALUES (0,pUsuario,'I','N','');
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;

			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;

			RETURN cCodRet;
		END IF;

		BEGIN WORK;
		
		IF bInTransaccion = 'f' THEN
			COMMIT WORK;
		END IF;


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdicheq:'informix'.liberasalret2(cEmpresa, pUsuario)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP liberasalret';
		ELIF iCodRetSp = 962 THEN
			LET cCodRet = '00455'; --CIERRE NO EFECTUADO
			
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;

		ELIF iCodRetSp = 971 THEN
			LET cCodRet = '00760'; --PROCESO DE LIBERACION DE RETENIDOS YA EFECTUADO

			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;

		ELIF iCodRetSp = 110 THEN
			LET cCodRet = '00003'; --FALTAN PARAMETROS DE ENTRADA
			
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;

		END IF;
		
		IF cCodRet::INT > 0 THEN
			LET bInTransaccion = 'f';
			BEGIN WORK;
		END IF;
		
		IF bInTransaccion = 't' THEN
			BEGIN WORK;
		END IF;

		IF cCodRet = '00000' THEN
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'T', error_proceso = 'N', error = cCodRet where usuario_insert = pUsuario;
		END IF;

		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 03/03/2016',
'DESCRIPCION: spl para realizar la liberaciÃÂ³n salvo buen cobro',
'FECHA: 20/11/2024',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'DESCRIPCION: Se aÃ±aden hilo de espera para la funcionalidad de liberaciÃ³n de saldo retenido',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_reportesbc(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaReporte CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20)	AS Cuenta,
				  CHAR(4)	AS Sucursal,
				  DATE 		AS FechaAlta,
				  CHAR(4)	AS Transacc,
				  CHAR(40)	AS Referencia,
				  INTEGER	AS NumeroChque,
				  SMALLINT	AS DiasOri,
				  MONEY(14,2) AS MontoOri,
				  CHAR(2)	AS Siglas,
				  CHAR (40) AS Banco,
				  CHAR (10) AS Fecharep;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCuenta         CHAR(20);
	DEFINE cSucursal       CHAR(4);
	DEFINE cFechaAlta      DATE;
	DEFINE cTransacc       CHAR(4);
	DEFINE cReferencia     CHAR(40);
	DEFINE iNumeroChque    INTEGER;
	DEFINE sDiasOri        SMALLINT;
	DEFINE mMontoOri       MONEY(14,2);
	DEFINE cSiglas         CHAR(2);
	DEFINE cBanco          CHAR (40);
	DEFINE cFecharep       CHAR (10);
	DEFINE iRecuperacion   INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cCuenta         = '';
	LET cSucursal       = '';
	LET cFechaAlta      = '';
	LET cTransacc       = '';
	LET cReferencia     = '';
	LET iNumeroChque    = '';
	LET sDiasOri        = '';
	LET mMontoOri       = 0;
	LET cSiglas         = '';
	LET cBanco          = '';
	LET cFecharep       = '';
	LET iRecuperacion   = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cSucursal, cFechaAlta, cTransacc, cReferencia, iNumeroChque, sDiasOri, mMontoOri,
			cSiglas, cBanco, cFecharep;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_reportesbc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cSucursal, cFechaAlta, cTransacc, cReferencia, iNumeroChque, sDiasOri, mMontoOri,
			cSiglas, cBanco, cFecharep;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, cSucursal, cFechaAlta, cTransacc, cReferencia, iNumeroChque, sDiasOri, mMontoOri,
			cSiglas, cBanco, cFecharep;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicheq:'informix'.sp_reportesbc2(cEmpresa, pFechaReporte, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCuenta, cSucursal, cFechaAlta, cTransacc, cReferencia, iNumeroChque, sDiasOri, mMontoOri,
			cSiglas, cBanco, cFecharep
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_reportesbc';
			ELSE
				RETURN cCodRet, cCuenta, cSucursal, cFechaAlta, cTransacc, cReferencia, iNumeroChque, sDiasOri, mMontoOri,
				cSiglas, cBanco, cFecharep WITH RESUME;
			END IF;
		END FOREACH;
	END;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00017';
		RETURN cCodRet, '', '', '', '', '', 0, '', 0, '', '', '';
	ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
		LET cCodRet = '01001';
		RETURN cCodRet, '', '', '', '', '', 0, '', 0, '', '', '';
	END IF;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 04/03/2016',
'DESCRIPCION: spl el cual regresa datos informaciÃÂ³n de los movimientos liberados SBC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_reportesbc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaReporte CHAR(10))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS TotalRegistros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotalRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iTotalRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_reportesbc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegistros;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistros;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:'informix'.sp_reportesbc2_totales(cEmpresa, pFechaReporte)
		INTO cCodRetSp, iTotalRegistros;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_reportesbc';
		ELSE
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, 0;
			ELSE 
				RETURN cCodRet, iTotalRegistros;
			END IF;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 04/03/2016',
'DESCRIPCION: spl el cual regresa datos informaciÃÂ³n de los movimientos liberados SBC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_validapassword(pUsuario CHAR(8), pIdFuncion CHAR(10), pPassword CHAR(40))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE cPassword CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET cPassword = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_validapassword.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pPassword = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT password INTO cPassword FROM bdinteg:si_ejecut WHERE ejecutivo = pUsuario;
		IF pPassword <> cPassword  THEN
			LET cCodRet = '00106'; --EL USUARIO NO TIENE REGISTRADA SU CONTRASEÃÂA O ES INCORRECTA
			RETURN cCodRet;
		ELSE
			RETURN cCodRet;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 03/03/2016',
'DESCRIPCION: spl que comprueba la constraseÃÂ±a del usuario',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusliberaret(pUsuario CHAR(8))
	RETURNING CHAR(5) AS codret,
              CHAR(1)       AS Status,
              CHAR(1)       AS error_proceso,  
              CHAR(5)       AS error;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE cStatus CHAR(1);
    DEFINE cErrorProceso CHAR(1);
    DEFINE cError   CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cStatus = '';
    LET cErrorProceso = '';
    LET cError = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cErrorProceso, cError;
		END EXCEPTION;
		
		
		IF pUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cErrorProceso, cError;
		END IF;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusliberaret.out';
		--TRACE ON;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF (SELECT count(*) FROM "informix".sw_verificastatusliberaret WHERE usuario_insert = pUsuario) > 0 THEN

            SELECT status, error_proceso, error
            INTO cStatus, cErrorProceso, cError
            FROM "informix".sw_verificastatusliberaret
            WHERE usuario_insert = pUsuario;

        ELSE
            LET cCodRet = '00017';
            RETURN cCodRet, cStatus, cErrorProceso, cError;
        END IF;

		RETURN cCodRet, cStatus, cErrorProceso, cError;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 20/11/2024',
'DESCRIPCION: Se aÃ±aden hilo de espera para la funcionalidad de liberaciÃ³n de saldo retenido',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sac_reportesdiario(pUsuario CHAR(8), pIdFuncion CHAR(10), pPeriodo DATE, pConvenio CHAR(5),pRutaDescarga CHAR(100),pIdPlantilla CHAR(25),pTituloPlantilla CHAR(255))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(35);
	DEFINE cBanDetError CHAR(1); 
    DEFINE cCodRetSp CHAR(5);
	
	DEFINE cTipo CHAR(50);
	DEFINE dDia DATE;
	DEFINE cNum_confirmacion CHAR(16);
	DEFINE mImporte MONEY(16,2);
	DEFINE cForma_pago CHAR (20);
	DEFINE cFolio_op CHAR (16);
	DEFINE cSucursal CHAR (5);
	DEFINE cCajero CHAR (8);
	DEFINE cNom_benef CHAR (120);
	DEFINE iTotal INTEGER;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cNombre CHAR(30);	
	DEFINE pIdMensaje CHAR(10);
	DEFINE cCategoria CHAR(2);
	DEFINE cConvenio CHAR(3);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE cNombreReporteLey CHAR(100);
	
	--variable para commit consulta de REGISTROS
	DEFINE vCuenta INTEGER;

		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dFechaHoy = '';
	LET cFechaHoraArchivo = '';
	LET cBanDetError = 'f';
	LET cCodRetSp='00000';

	LET cTipo ='';
	LET dDia = NULL;
	LET cNum_confirmacion = '';
	LET mImporte = 0.0;
	LET cForma_pago = '';
	LET cFolio_op = '';
	LET cSucursal = '';
	LET cCajero = '';
	LET cNom_benef = '';	
	LET iTotal = 0;
	LET dHoraHoy = '';
	LET cNombre ='';
	LET pIdMensaje='WEB_PLAROF'; --VARIABLE MENSAJE NOTIFICACION 
	LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
	LET cConvenio  = SUBSTRING(pConvenio FROM 3 FOR 3);
	LET cNombreReporteHist = '';
	LET cNombreReporteLey = '';
	
	
	
	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
						
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','','1','no exitoso','','','','',cTipo,'','','','','','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp;
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;
		
		IF pConvenio ='07006' THEN 
		LET cTipo ='REPORTE DIARIO REMESAS WU';
		ELIF pConvenio ='07007' THEN 		
		LET cTipo ='REPORTE DIARIO REMESAS OV';
		ELIF pConvenio = '07008' THEN 
		LET cTipo='REPORTE DIARIO REMESAS VIGO';
		ELIF pConvenio = '07004' THEN 
		LET cTipo='REPORTE DIARIO REMESAS BTS';
		ELIF pConvenio = '07009' THEN 
		LET cTipo='REPORTE DIARIO REMESAS APPRIZA';
		END IF;

		--SET DEBUG FILE TO '/ifxsif01/emm/sp_reportediario.out';
		--TRACE ON;


		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = ''  OR pPeriodo ='' OR pConvenio ='' OR  pIdPlantilla ='' OR pTituloPlantilla ='' THEN
			LET cCodRet = '00003';				
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','','1','no exitoso','','','','',cTipo,'','','','','','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp;
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN		
		    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','','1','no exitoso','','','','',cTipo,'','','','','','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp;
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pConvenio ='07006' THEN 
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM "informix".sw_cb_reportesacdiariowutmp WHERE usuario = pUsuario;

		ELIF pConvenio ='07007' THEN 
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM "informix".sw_cb_reportesacdiarioovtmp WHERE usuario = pUsuario;
	
		ELIF pConvenio = '07008' THEN 
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM "informix".sw_cb_reportesacdiariovgtmp WHERE usuario = pUsuario;
			
		ELIF pConvenio ='07004' THEN 
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM "informix".sw_cb_reportesacdiariobtstmp WHERE usuario = pUsuario;
	
		ELIF pConvenio = '07009' THEN 
			-- SE LIMPIA TABLA POR USUARIO			
            DELETE FROM "informix".sw_cb_reportesacdiarioapptmp WHERE usuario = pUsuario;
		END IF;
		
		-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
			
		FOREACH 
			
			SELECT nombre_reporte
			INTO cNombreReporteHist
			FROM bdicnweb:"informix".sw_ctrlgenreportesac 
			WHERE usuario_insert = pUsuario
			AND fecha_reporte <= TODAY-1
			
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
			SYSTEM TRIM(cSql);
			
			LET cNombreReporteHist = TRIM(cNombreReporteHist);
				
			---DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND nombre_reporte = TRIM(cNombreReporteHist);
		    DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND nombre_reporte =cNombreReporteHist;
		
		END FOREACH;
		
		
		IF pConvenio IN ('07006','07007','07008') THEN 
		
		-----consultar los registros  de remesas WU
		LET vCuenta = 0;
		
		BEGIN WORK;
		FOREACH WITH HOLD		   
			
		SELECT 
			DISTINCT fecha_pago,mtcn,importe_pago,forma_pago,folio_suc,id_sucursal,usuario,nom_benef 
			INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
		FROM(
			SELECT 
				--{+INDEX(bdisac:"informix".sac_movimientoshistorial idxsac_movhisfe)}
				--, +INDEX(bdisac:"informix".sac_wu_pay idx_sac_wu_pay_rep)} --STK 092024
				movhis.fecha_pago, wu.mtcn, movhis.importe_pago,
				(DECODE(movhis.origen, 'CPL', 'EFECTIVO-CLP', DECODE(movhis.forma_pago, '1', 'EFECTIVO', DECODE(movhis.forma_pago, '2', 'CARGO EN CUENTA', DECODE(movhis.forma_pago, '3', 'MIXTO', DECODE(movhis.forma_pago, '4', 'ABONO CTA', movhis.forma_pago)))))) AS forma_pago,
				--case when movhis.forma_pago='1' and movhis.origen ='CPL' then 'EFECTIVO-CPL' 
					--when movhis.forma_pago='1' and movhis.origen <>'CPL' then 'EFECTIVO'
					--when movhis.forma_pago='2' and movhis.origen <>'CPL' then 'CARGO EN CUENTA'
					--when movhis.forma_pago='3' and movhis.origen <>'CPL' then 'MIXTO'
					--when movhis.forma_pago='4' and movhis.origen <>'CPL' then 'ABONO CTA'
				--end forma_pago,
				movhis.folio_suc, movhis.id_sucursal, movhis.usuario,
				(TRIM(wu.benef_nombre1) || ' ' || TRIM(wu.benef_appaterno) || ' ' || TRIM(wu.benef_apmaterno)) nom_benef
			FROM 
				bdisac:"informix".sac_movimientoshistorial AS movhis
			INNER JOIN 
				bdisac:"informix".sac_wu_pay AS wu ON wu.mtcn = movhis.referencia1
			WHERE 
				movhis.fecha_pago = pPeriodo
				AND movhis.numcategoria = cCategoria 
				AND movhis.numconvenio = cConvenio 
				AND movhis.folio_suc IN (wu.foreign_rs_refnum_rq, wu.foreign_rs_refnum_rp)
				AND movhis.status_cancelado = 'N'
				AND wu.txn_status = 'A'
				AND wu.conf_pago='P' 
				AND wu.retcode = '00000'
				AND wu.fecha_insert::date = pPeriodo
			)
						
			
			IF pConvenio ='07006' THEN 
			
			INSERT INTO "informix".sw_cb_reportesacdiariowutmp(usuario, dia, num_confirmacion, importe, forma_pago, folio_op, sucursal, cajero,nom_benef) 
			VALUES(pUsuario,dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef);
	
			ELIF pConvenio ='07007' THEN 
									
			INSERT INTO "informix".sw_cb_reportesacdiarioovtmp(usuario, dia, num_confirmacion, importe, forma_pago, folio_op, sucursal, cajero,nom_benef) 
			VALUES(pUsuario,dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef);
			
			ELIF pConvenio = '07008' THEN 
			
			INSERT INTO "informix".sw_cb_reportesacdiariovgtmp(usuario, dia, num_confirmacion, importe, forma_pago, folio_op, sucursal, cajero,nom_benef) 
			VALUES(pUsuario,dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef);
	
			END IF;
			
				--Hago commit y vuelvo a iniciar
				LET vCuenta = vCuenta + 1;
						
		        	IF vCuenta = 1000 THEN
							COMMIT WORK;
							LET vCuenta = 0;
							BEGIN WORK;
						END IF;
						
	
			END FOREACH; 
			
			
				--Hago commit work de ser necesario
					IF vCuenta < 1000 and vCuenta >= 0 THEN
						COMMIT WORK;
					END IF;
			
			
	    ELIF pConvenio = '07004' THEN 
		
		-----consultar los registros  de remesas WU
		LET vCuenta = 0;
		
		BEGIN WORK;
		
			FOREACH WITH HOLD	
			
			SELECT --{+INDEX(bdisac:"informix".sac_movimientoshistorial  idxsac_movhis235), --STK 092024
			--+INDEX(bdisac:"informix".Sac_BTS_Payi idx_sac_bts_pay_new)} --STK 092024
			MOV.Fecha_Pago AS DIA, 
			BTS.CONFIRMATION_NM AS Num_confirmacion,
			MOV.Importe_Pago AS Importe,
			(DECODE(MOV.origen, 'CPL', 'EFECTIVO-CLP', DECODE(MOV.Forma_Pago, '1', 'EFECTIVO', DECODE(MOV.Forma_Pago, '2', 'CARGO EN CUENTA', DECODE(MOV.Forma_Pago, '3', 'MIXTO', DECODE(MOV.Forma_Pago, '4', 'ABONO CTA', MOV.Forma_Pago)))))) AS Forma_pago, 
            --case when MOV.Forma_Pago='1' and MOV.origen ='CPL' then 'EFECTIVO-CPL' 
                 --when MOV.Forma_Pago='1' and MOV.origen <>'CPL' then 'EFECTIVO'
                 --when MOV.Forma_Pago='2' and MOV.origen <>'CPL' then 'CARGO EN CUENTA'
                 --when MOV.Forma_Pago='3' and MOV.origen <>'CPL' then 'MIXTO'
                 --when MOV.Forma_Pago='4' and MOV.origen <>'CPL' then 'ABONO CTA'
            --end Forma_pago,
			MOV.Folio_Suc AS Folio_op, 
			MOV.Id_Sucursal AS Sucursal,
			MOV.Usuario AS Cajero,
			(TRIM(BTS.R_First_Name) || ' ' || TRIM(BTS.R_Middle_Name) || ' ' || TRIM(BTS.R_Last_Name)) AS Nom_benef
			INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
			FROM BdiSac:Sac_MovimientosHistorial AS MOV INNER JOIN BdiSac:Sac_BTS_Payi AS BTS
			ON MOV.Fecha_Pago = pPeriodo
			AND MOV.Folio_Suc =  BTS.Bank_Ref_Nm
			AND MOV.Referencia1 = BTS.Confirmation_Nm
			AND MOV.status_cancelado = 'N'
			
		
			
			INSERT INTO "informix".sw_cb_reportesacdiariobtstmp(usuario, dia, num_confirmacion, importe, forma_pago, folio_op, sucursal, cajero,nom_benef) 
			VALUES(pUsuario,dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef);
	
		
				--Hago commit y vuelvo a iniciar
				LET vCuenta = vCuenta + 1;
						
		        	IF vCuenta = 1000 THEN
							COMMIT WORK;
							LET vCuenta = 0;
							BEGIN WORK;
						END IF;
	
	
		END FOREACH;
		
			--Hago commit work de ser necesario
					IF vCuenta < 1000 and vCuenta >= 0 THEN
						COMMIT WORK;
					END IF;

		ELIF pConvenio = '07009' THEN 
		
			-----consultar los registros  de remesas WU
		LET vCuenta = 0;
		
		BEGIN WORK;
		 
			FOREACH WITH HOLD	
			
			SELECT ---{+INDEX(bdisac:"informix".sac_movimientoshistorial  idxsac_movhis235)} 
			--+INDEX(bdisac:"informix".Sac_BTS_Payi idx_sac_bts_pay_new)} --STK 092024
			MOV.Fecha_Pago AS DIA, 
            APP.r_uniquerefnum AS Num_confirmacion,
            MOV.Importe_Pago AS Importe,
		   (DECODE(MOV.origen, 'CPL', 'EFECTIVO-CLP', DECODE(MOV.Forma_Pago, '1', 'EFECTIVO', DECODE(MOV.Forma_Pago, '2', 'CARGO EN CUENTA', DECODE(MOV.Forma_Pago, '3', 'MIXTO', DECODE(MOV.Forma_Pago, '4', 'ABONO CTA', MOV.Forma_Pago)))))) AS Forma_pago, 
            --case when MOV.Forma_Pago='1' and MOV.origen ='CPL' then 'EFECTIVO-CPL' 
                 --when MOV.Forma_Pago='1' and MOV.origen <>'CPL' then 'EFECTIVO'
                 --when MOV.Forma_Pago='2' and MOV.origen <>'CPL' then 'CARGO EN CUENTA'
                 --when MOV.Forma_Pago='3' and MOV.origen <>'CPL' then 'MIXTO'
                 --when MOV.Forma_Pago='4' and MOV.origen <>'CPL' then 'ABONO CTA'
            --end Forma_pago,
            MOV.Folio_Suc AS Folio_op, 
            MOV.Id_Sucursal AS Sucursal,
            MOV.Usuario AS Cajero,
			(TRIM(APP.firstname) || ' ' || TRIM(APP.middlename) || ' ' || TRIM(APP.lastname)) AS Nom_benef                     
			INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
			FROM BdiSac:Sac_MovimientosHistorial AS MOV INNER JOIN bdisac:sac_app_payi AS APP
			ON MOV.Fecha_Pago = pPeriodo
			AND MOV.Folio_Suc =  APP.refnum
            AND MOV.Referencia1 = APP.unirefnum
            AND MOV.status_cancelado = 'N'
			
		
			INSERT INTO "informix".sw_cb_reportesacdiarioapptmp(usuario, dia, num_confirmacion, importe, forma_pago, folio_op, sucursal, cajero,nom_benef) 
			VALUES(pUsuario,dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef);
			
				--Hago commit y vuelvo a iniciar
				LET vCuenta = vCuenta + 1;
						
		        	IF vCuenta = 1000 THEN
							COMMIT WORK;
							LET vCuenta = 0;
							BEGIN WORK;
						END IF;
		
		END FOREACH;	
		
		--Hago commit work de ser necesario
					IF vCuenta < 1000 and vCuenta >= 0 THEN
						COMMIT WORK;
					END IF;
	
		END IF;	
			
		IF pConvenio ='07006' THEN 
			SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportesacdiariowutmp WHERE usuario = pUsuario;
		ELIF pConvenio ='07007' THEN 
			SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportesacdiarioovtmp WHERE usuario = pUsuario;
		ELIF pConvenio = '07008' THEN 
			SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportesacdiariovgtmp WHERE usuario = pUsuario;
		ELIF pConvenio = '07004' THEN 
			SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportesacdiariobtstmp WHERE usuario = pUsuario;
		ELIF pConvenio = '07009' THEN 
            SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportesacdiarioapptmp WHERE usuario = pUsuario;
		END IF;		
	
		
		IF iTotal = 0 THEN			
			LET cCodRet ='00017';			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','','1','no exitoso','','','','',cTipo,'','','','','','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp;
		END IF;
		
		
        IF cCodRet='00000' THEN 
		--GENERACION DE REPORTE	
		LET cCmd1 ="";
		LET cCmd1 ="SELECT ' ',' ','SISTEMA DE ADMINISTRACION DE CONVENIOS ',' ',' ',' ','FECHA:','"||TO_CHAR(dFechaHoy, '%d/%m/%Y') ||"' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
		IF pConvenio ='07006' THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT ' ',' ','CONCILIACION DE PAGOS DE REMESAS WU DIARIO',' ',' ',' ','HORA:','"||TO_CHAR(dHoraHoy, '%H:%M:%S')||"' FROM systables  WHERE tabid = 1 ";
		ELIF pConvenio ='07007' THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT ' ',' ','CONCILIACION DE PAGOS DE REMESAS OV DIARIO ',' ',' ',' ','HORA:','"||TO_CHAR(dHoraHoy, '%H:%M:%S')||"' FROM systables  WHERE tabid = 1 ";
		ELIF pConvenio = '07008' THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT ' ',' ','CONCILIACION DE PAGOS DE REMESAS VIGO DIARIO ',' ',' ',' ','HORA:','"||TO_CHAR(dHoraHoy, '%H:%M:%S')||"' FROM systables  WHERE tabid = 1 ";
		ELIF pConvenio = '07004' THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT ' ',' ','CONCILIACION DE PAGOS DE REMESAS BTS DIARIO ',' ',' ',' ','HORA:','"||TO_CHAR(dHoraHoy, '%H:%M:%S')||"' FROM systables  WHERE tabid = 1 ";
		ELIF pConvenio = '07009' THEN 
            LET cCmd1 =""||TRIM(cCmd1)||" SELECT ' ',' ','CONCILIACION DE PAGOS DE REMESAS APPRIZA DIARIO ',' ',' ',' ','HORA:','"||TO_CHAR(dHoraHoy, '%H:%M:%S')||"' FROM systables  WHERE tabid = 1 ";
		END IF;		
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'CONVENIO:','''"||pConvenio||"','SUCURSAL:TODAS',' ','RANGO DE FECHAS DEL:','"||TO_CHAR(pPeriodo, '%d/%m/%Y')||"','AL:','"||TO_CHAR(pPeriodo, '%d/%m/%Y')||"' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'DIA','NUMERO CONFIRMACION','IMPORTE','FORMA DE PAGO','FOLIO OPERACION','NUMERO SUCURSAL','CAJERO','NOMBRE BENEFICIARIO' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        
     	IF pConvenio ='07006' THEN 
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(dia),2,0)||'/'||LPAD(MONTH(dia),2,0)||'/'||YEAR(dia), num_confirmacion::CHAR(20),importe::CHAR(20),forma_pago::CHAR(20),folio_op::CHAR(20),''''||sucursal::CHAR(5),cajero::CHAR(8),nom_benef::CHAR(120) FROM ""informix"".sw_cb_reportesacdiariowutmp WHERE usuario ='"||pUsuario||"'"; 
		ELIF pConvenio ='07007' THEN 
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(dia),2,0)||'/'||LPAD(MONTH(dia),2,0)||'/'||YEAR(dia), num_confirmacion::CHAR(20),importe::CHAR(20),forma_pago::CHAR(20),folio_op::CHAR(20),''''||sucursal::CHAR(5),cajero::CHAR(8),nom_benef::CHAR(120) FROM ""informix"".sw_cb_reportesacdiarioovtmp WHERE usuario ='"||pUsuario||"'"; 
		ELIF pConvenio = '07008' THEN 
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(dia),2,0)||'/'||LPAD(MONTH(dia),2,0)||'/'||YEAR(dia), num_confirmacion::CHAR(20),importe::CHAR(20),forma_pago::CHAR(20),folio_op::CHAR(20),''''||sucursal::CHAR(5),cajero::CHAR(8),nom_benef::CHAR(120) FROM ""informix"".sw_cb_reportesacdiariovgtmp WHERE usuario ='"||pUsuario||"'"; 
		ELIF pConvenio = '07004' THEN 
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(dia),2,0)||'/'||LPAD(MONTH(dia),2,0)||'/'||YEAR(dia), num_confirmacion::CHAR(20),importe::CHAR(20),forma_pago::CHAR(20),folio_op::CHAR(20),''''||sucursal::CHAR(5),cajero::CHAR(8),nom_benef::CHAR(120) FROM ""informix"".sw_cb_reportesacdiariobtstmp WHERE usuario ='"||pUsuario||"'"; 
		ELIF pConvenio = '07009' THEN 
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(dia),2,0)||'/'||LPAD(MONTH(dia),2,0)||'/'||YEAR(dia), num_confirmacion::CHAR(20),importe::CHAR(20),forma_pago::CHAR(20),folio_op::CHAR(20),''''||sucursal::CHAR(5),cajero::CHAR(8),nom_benef::CHAR(120) FROM ""informix"".sw_cb_reportesacdiarioapptmp WHERE usuario ='"||pUsuario||"'"; 
		END IF;
		
		LET cFechaHoraArchivo = TO_CHAR(dFechaHoy, '%d%m%Y')||"_"||TO_CHAR(dHoraHoy, '%H%M%S')||"_"||pUsuario;
		 
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR	
		
		IF pConvenio ='07006' THEN 
		LET cNombreArchivo = 'REPORTE_DIARIO_REMESAS_WU_'||TRIM(cFechaHoraArchivo)||'.csv';
		LET cTipo ='REPORTE DIARIO REMESAS WU';
		ELIF pConvenio ='07007' THEN 
		LET cNombreArchivo = 'REPORTE_DIARIO_REMESAS_OV_'||TRIM(cFechaHoraArchivo)||'.csv';
		LET cTipo ='REPORTE DIARIO REMESAS OV';
		ELIF pConvenio = '07008' THEN 
		LET cNombreArchivo = 'REPORTE_DIARIO_REMESAS_VIGO_'||TRIM(cFechaHoraArchivo)||'.csv';
		LET cTipo='REPORTE DIARIO REMESAS VIGO';
		ELIF pConvenio = '07004' THEN 
		LET cNombreArchivo = 'REPORTE_DIARIO_REMESAS_BTS_'||TRIM(cFechaHoraArchivo)||'.csv';
		LET cTipo='REPORTE DIARIO REMESAS BTS';
		ELIF pConvenio = '07009' THEN 
		LET cNombreArchivo = 'REPORTE_DIARIO_REMESAS_APP_'||TRIM(cFechaHoraArchivo)||'.csv';
		LET cTipo='REPORTE DIARIO REMESAS APPRIZA';
		END IF;
		
        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
                      
                        LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '','' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||TRIM(cFechaHoraArchivo)||'.sql';
                        
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||TRIM(cFechaHoraArchivo)||'.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        --RUTA PRUEBAS
						--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||TRIM(cFechaHoraArchivo)||'.sql';
						--RUTA PRODUCTIVA
						LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||TRIM(cFechaHoraArchivo)||'.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cFechaHoraArchivo)||'.sql';
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de linea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el archivo original
                        LET cSql = '';
                        LET cSql = "rm -rf "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el caracter delimitador ';' al final de la linea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de linea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);
						
						
			     IF pConvenio ='07006' THEN 
		         LET cNombreReporteLey = TRIM('REPORTE_DIARIO_REMESAS_WU_%');
		         ELIF pConvenio ='07007' THEN 
		         LET cNombreReporteLey = TRIM('REPORTE_DIARIO_REMESAS_OV_%');
		         ELIF pConvenio = '07008' THEN 
		         LET cNombreReporteLey = TRIM('REPORTE_DIARIO_REMESAS_VIGO_%');
		         ELIF pConvenio = '07004' THEN 
		         LET cNombreReporteLey = TRIM('REPORTE_DIARIO_REMESAS_BTS_%');
		         ELIF pConvenio = '07009' THEN 
		         LET cNombreReporteLey = TRIM('REPORTE_DIARIO_REMESAS_APP_%');
		         END IF;		
						
						
			    LET cNombreArchivo = TRIM(cNombreArchivo);
						
				IF pConvenio ='07006' THEN 				
				--DELETE FROM "informix".sw_ctrlgenreportesac WHERE TRIM(tipo) = TRIM(cTipo) AND usuario_insert = pUsuario AND TRIM(nombre_reporte) LIKE TRIM('REPORTE_DIARIO_REMESAS_WU_%');
				DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND tipo='REPORTE DIARIO REMESAS WU' AND nombre_reporte LIKE cNombreReporteLey;
				ELIF pConvenio ='07007' THEN 
				--DELETE FROM "informix".sw_ctrlgenreportesac WHERE TRIM(tipo) = TRIM(cTipo) AND usuario_insert = pUsuario AND TRIM(nombre_reporte) LIKE TRIM('REPORTE_DIARIO_REMESAS_OV_%');
				DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND tipo='REPORTE DIARIO REMESAS OV' AND nombre_reporte LIKE cNombreReporteLey;
				ELIF pConvenio = '07008' THEN 
				--DELETE FROM "informix".sw_ctrlgenreportesac WHERE TRIM(tipo) = TRIM(cTipo) AND usuario_insert = pUsuario AND TRIM(nombre_reporte) LIKE TRIM('REPORTE_DIARIO_REMESAS_VIGO_%');
				DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND tipo='REPORTE DIARIO REMESAS VIGO' AND nombre_reporte LIKE cNombreReporteLey;
				ELIF pConvenio = '07004' THEN 
				--DELETE FROM "informix".sw_ctrlgenreportesac WHERE TRIM(tipo) = TRIM(cTipo) AND usuario_insert = pUsuario AND TRIM(nombre_reporte) LIKE TRIM('REPORTE_DIARIO_REMESAS_BTS_%');
				DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND tipo='REPORTE DIARIO REMESAS BTS' AND nombre_reporte LIKE cNombreReporteLey;
				ELIF pConvenio = '07009' THEN 
				--DELETE FROM "informix".sw_ctrlgenreportesac WHERE TRIM(tipo) = TRIM(cTipo) AND usuario_insert = pUsuario AND TRIM(nombre_reporte) LIKE TRIM('REPORTE_DIARIO_REMESAS_APP_%');
				DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND tipo='REPORTE DIARIO REMESAS APPRIZA' AND nombre_reporte LIKE cNombreReporteLey;
				END IF;
			    
			  --INSERT INTO "informix".sw_ctrlgenreportesac(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert,tipo)
			  --VALUES(TRIM(cNombreArchivo),dFechaHoy,dHoraHoy,pUsuario,cTipo);
			   	   
				INSERT INTO "informix".sw_ctrlgenreportesac(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert,tipo)
			    VALUES(cNombreArchivo,dFechaHoy,dHoraHoy,pUsuario,cTipo);
                     
        LET cBanDetError = 't';

				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
			   
			    
                
        -- SE ENVIA LA NOTIFICACION DE CORREO ELECTRONICO
        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','','1','con Ã©xito','','','','',cTipo,'','','','','','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp;
	    END IF;
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT  
'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/11/2021',
'DESCRIPCION: SPL que genera los reportes de conciliacion remesas',
'BD: bdicnweb',
'AUTOR: Zahide Tellez Ramirez',
'FECHA: 03/08/2023',
'DESCRIPCION: Se realizan optimizaciones a SPL para bajar los costos altos y sequential',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaestatuspoliza(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS poliza;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError  CHAR(5);
	DEFINE cPoliza INTEGER;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	LET cPoliza= '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cPoliza;	
		END EXCEPTION;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cPoliza;	
		END IF;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_validaestatuspoliza.out';
		-- TRACE ON;
		
		IF pUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cPoliza;	
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,total_registros,error_proceso,error,poliza
		INTO cStatus,iNumRegistros,cErrorProceso,cError, cPoliza
		FROM bdicnweb:"informix".sw_verificastatuspoliza
        WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';	
			RETURN cCodRet,'E','','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cPoliza;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 08/01/2024',
'MODULO: OFI',
'DESCRIPCION: VERIFICA EL ESTATUS DEL PROCESO DE RECUPERACIÃN DE POLIZA',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_ofi_generarpolizanomina(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaActual DATE, pFechaQuincena DATE, pUsuarioSistema CHAR(8))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS NumeroPoliza
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNumeroPoliza INTEGER;
	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNumeroPoliza=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 

			RETURN cCodRet,iNumeroPoliza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgenerarpolizanomina.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaActual ='' OR pFechaQuincena = '' OR pUsuarioSistema = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumeroPoliza;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		DELETE FROM "informix".sw_verificastatuspoliza WHERE usuario_insert = pUsuario; 
		INSERT INTO "informix".sw_verificastatuspoliza(usuario_insert, status, total_registros, error_proceso, error, poliza)
		VALUES (pUsuario, 'I', 0, '', '', 0);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN

			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;
		END IF;

		EXECUTE PROCEDURE bdirech:"informix".spgenerarpolizanomina(pFechaActual,pFechaQuincena,pUsuarioSistema)
		INTO  cCodRet,iNumeroPoliza;
        
          IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;
		  END IF;

       IF cCodRet ='000' THEN
			LET cCodRet ='00000';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'T', error_proceso ='N', error = cCodRet, poliza = iNumeroPoliza
			WHERE usuario_insert = pUsuario; 		
		END IF;
        IF cCodRet ='00001' THEN
			LET cCodRet ='00003';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;		
		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01245';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;         
		END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01246';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;		
		END IF;
        IF cCodRet ='00004' THEN
			LET cCodRet ='01241';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;      
		END IF;
 
		RETURN cCodRet,iNumeroPoliza;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgenerarpolizanomina',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA MODIFICACIÃN: 21/11/2024',
'DESCRIPCION: Se anexa la secciÃ³n de hilo de espera para la actualizaciÃ³n de estatus a la estructuras sw_verificastatuspoliza.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_admintasas_bitacoraerror(pUsuario CHAR(9), 
                                                        pIdFuncion CHAR(8), 
                                                        pBandera SMALLINT, 
                                                        pNombreHoja CHAR(120), 
                                                        pNombreCampo CHAR(50), 
                                                        pNumeroFila INTEGER, 
                                                        pDescripcion CHAR(250), 
                                                        pRegistros INTEGER, 
                                                        pRecuperacion INTEGER)
RETURNING CHAR(5)       AS codret,
          CHAR(120)     AS nombreHoja,
          CHAR(50)      AS nombreCampo,
          INTEGER       AS numerofila,
          CHAR(250)     AS descripcion, 
          CHAR(9)       AS usuario,    
          DATE          AS fecha_insert,
          INTEGER       AS total_registros;


    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iRegistro        INTEGER; 
    DEFINE cNombreHoja      CHAR(120);
    DEFINE cNombreCampo     CHAR(50);
    DEFINE iNumerofila      INTEGER;
    DEFINE cDescripcion     CHAR(250);
    DEFINE cUsuario         CHAR(9);
    DEFINE cFecha_insert    DATE;

    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET iRegistro        = 0; 
    LET cNombreHoja      = '';
    LET cnombreCampo     = '';
    LET iNumerofila      = 0;
    LET cDescripcion     = '';
    LET cUsuario         = '';
    LET cFecha_insert    = '';

    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/RESPALDOSNEW/admintasas/Antonio/sp_admintasas_bitacoraerror.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR pBandera IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
		END IF;

         IF pBandera = '1' AND  (pNombreHoja = ''  OR pNombreCampo = '' OR pNumeroFila IS NULL OR pNumeroFila = '' OR pDescripcion = '') THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
        
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
		END IF;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        IF pBandera = 1 THEN

            -- Se insertan los registros en la bitacora
            INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
            VALUES (pNombreHoja, pNombreCampo, pNumeroFila, pDescripcion, pUsuario);

            RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;

        ELIF pBandera = 2 THEN
            FOREACH
                SELECT SKIP pRegistros FIRST pRecuperacion nombreHoja, nombreCampo, numerofila, descripcion, usuario, fecha_insert 
                INTO   cNombreHoja, cnombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert
                FROM bdinvers:"informix".sv_admintasas_bitacoraerror
                WHERE usuario= pUsuario
                ORDER BY nombreHoja, numerofila

                LET iRegistro = iRegistro + 1;
                 RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro WITH RESUME;
            END FOREACH

            IF iRegistro = 0 AND pRegistros = 0 THEN
                LET cCodRet = '00017';
                RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;

            ELIF iRegistro = 0 AND pRegistros > 0 THEN
                LET cCodRet = '1001';
                RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
            END IF;

        ELIF pBandera = 3 THEN
            IF EXISTS (SELECT 1 FROM bdinvers:"informix".sv_admintasas_bitacoraerror WHERE usuario = pUsuario) THEN
                
                DELETE FROM bdinvers:"informix".sv_admintasas_bitacoraerror 
                WHERE usuario = pUsuario;
            END IF;

            LET cNombreHoja = 'Eliminacion Exitosa';
            RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;

        ELIF pBandera = 4 THEN
            SELECT COUNT(*)
            INTO   iRegistro
            FROM bdinvers:"informix".sv_admintasas_bitacoraerror
            WHERE usuario= pUsuario;

            IF iRegistro = 0 THEN
                LET cCodRet = '00017';
            END IF;
            RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
        END IF;

    END
END PROCEDURE    
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 02/09/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: CARGA DE CAMPAÃAS',
'DESCRIPCION: Procedimiento que se encarga de realizar lo siguiente:', 
'             Bandera 1: Agrega un registro a la bitacora de errores bdinvers:sv_admintasas_bitacoraerror',
'             Bandera 2: consulta todos los registro a la bitacora de errores bdinvers:sv_admintasas_bitacoraerror por medio de un usuario',
'             Bandera 3: Se depura la bitacora de errores por medio de un usuario.',
'             Bandera 4: Consulta el total de registros de la bitacora de errores.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_admintasas_consultabitacora(pUsuario CHAR(9), pIdFuncion CHAR(8), pBandera INTEGER, pFuncionalidad CHAR(1), pFechaDel DATE, pFechaAl DATE, pUsuario_insert CHAR(9), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5)                      AS codret,
          DATE                         AS fecha,
          CHAR(12)                     AS hora,
          CHAR(9)                      AS usuario_insert,
          CHAR(20)                     AS funcionalidad,
          CHAR(20)                     AS campo_anterior,
          CHAR(20)                     AS campo_nuevo,
          CHAR(200)                    AS descripcion,
          CHAR(4)                      AS producto,
          CHAR(9)                      AS usuario_modifica,
          INTEGER                      AS total_reg;



    
    DEFINE cCodRet       CHAR(5);
    DEFINE iSqlErr       INTEGER;
    DEFINE dFecha        DATE;
    DEFINE dHora         CHAR(12);
    DEFINE cUsuario      CHAR(9);
    DEFINE cFuncionalidad CHAR(20);
    DEFINE cCampAnterior  CHAR(20);
    DEFINE cCampNuevo    CHAR(20);
    DEFINE cDescripcion   CHAR(200);
    DEFINE cProducto      CHAR(4);
    DEFINE cUsuarioMod    CHAR(9);
    DEFINE iRegistro      INTEGER;

    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET dFecha           = '';
    LET dHora            = '';
    LET cUsuario         = '';
    LET cFuncionalidad   = '';
    LET cCampAnterior    = '';
    LET cCampNuevo       = '';
    LET cDescripcion     = '';
    LET cProducto        = '';
    LET cUsuarioMod      = '';
    LET iRegistro        = 0;

    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/RESPALDOSNEW/admintasas/Antonio/sp_admintasas_consultabitacora.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pRecuperacion IS NULL OR pRegistros IS NULL OR pFechaAl = '' OR pFechaDel = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
		END IF;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
		END IF;

        IF pBandera = 1 THEN
            
            FOREACH 

                SELECT {+INDEX (bdinvers:"informix".sv_camp_bitacora idx_sv_camp_bitacora)}
				SKIP pRegistros FIRST pRecuperacion fecha, TO_CHAR(hora, '%I:%M:%S %p'), usuario_insert, usuario_mod, funcionalidad, campoAnterior, campoNuevo, descripcion, producto
                INTO dFecha, dHora, cUsuario, cUsuarioMod, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto
                FROM bdinvers:"informix".sv_camp_bitacora
                WHERE fecha BETWEEN pFechaDel AND pFechaAl
                AND usuario_insert = (CASE WHEN pUsuario_insert = '' THEN TRIM(usuario_insert) ELSE TRIM(pUsuario_insert) END)
                AND tipOperacion = (CASE WHEN pFuncionalidad = '' THEN tipOperacion ELSE TRIM(pFuncionalidad) END)
                ORDER BY hora DESC
                
                LET iRegistro = iRegistro + 1;

                RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro WITH RESUME;

            END FOREACH

            IF iRegistro = 0 AND pRegistros = 0 THEN
                LET cCodRet = '00017';
                RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;

            ELIF iRegistro = 0 AND pRegistros > 0 THEN
                LET cCodRet = '1001';
                RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
            END IF;
        ELIF pBandera = 2 THEN
            --Registrar la descarga del layout 
            INSERT INTO {+INDEX (bdinvers:"informix".sv_camp_bitacora idx_sv_camp_bitacora)} bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto)
            VALUES (TODAY, CURRENT, pUsuario, 'CARGA DE CAMPAÃAS', 1, "SE HA REALIZADO LA DESCARGA DE LA PLANTILLA", 3000);

            RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;

        ELIF pBandera = 3 THEN
            --Registrar la cancelacion  
            INSERT INTO {+INDEX (bdinvers:"informix".sv_camp_bitacora idx_sv_camp_bitacora)} bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto)
            VALUES (TODAY, CURRENT, pUsuario, 'CARGA DE CAMPAÃAS', 1, "SE HA CANCELADO LA CARGA DE ARCHIVO", 3000);

            RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
        
        ELIF pBandera = 4 THEN

                SELECT {+INDEX (bdinvers:"informix".sv_camp_bitacora idx_sv_camp_bitacora)} 
				count(idRegistro)
                INTO iRegistro
                FROM bdinvers:"informix".sv_camp_bitacora
                WHERE fecha BETWEEN pFechaDel AND pFechaAl
                AND usuario_insert = (CASE WHEN pUsuario = '' THEN usuario_insert ELSE TRIM(pUsuario) END)
                AND tipOperacion = (CASE WHEN pFuncionalidad = '' THEN tipOperacion ELSE pFuncionalidad END);
                
                IF iRegistro = 0 THEN
                    LET cCodRet = '00017';
                END IF;
                RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
        END IF;
    END
END PROCEDURE    
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 02/09/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: BITACORA DE MOVIMIENTOS',
'DESCRIPCION: Procedimiento que se encarga de consultar los registros de la bitacora los cuales pueden ser por usuario, funcionalidad o un periodo de tiempo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogocalle_2(pUsuario CHAR(8), pIdFuncion CHAR(10), pConsulta CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		INTEGER AS numero_calle,
		CHAR(30) AS nombre_calle;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNumeroCalle INTEGER;
	DEFINE cNombreCalle CHAR(30);
	DEFINE iTotalReg INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iRegistros = 0;
	LET iNumeroCalle = 0;
	LET cNombreCalle = '';
	LET iTotalReg = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocalle_2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros >= 0 AND pRegistros < 100 THEN
			IF pRecuperacion = pRegistros THEN
				LET iTotalReg = 100 - pRecuperacion;
				IF iTotalReg < pRecuperacion THEN
					LET pRecuperacion = iTotalReg;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catcalles;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF LENGTH(TRIM(pConsulta)) < 4 THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle
			INTO iNumeroCalle, cNombreCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle = TRIM(pConsulta)
			ORDER BY nombrecalle ASC
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
			END FOREACH;
		ELSE
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle
			INTO iNumeroCalle, cNombreCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle LIKE '%' || TRIM(pConsulta) || '%' 
			ORDER BY nombrecalle ASC
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
			END FOREACH;
		END IF;
		
		IF iRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		ELIF iRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las calles",
"FECHA: 04/02/2025",
"AUTOR: Veronica Sanchez",
"DESCRIPCION: Se clona procedimiento almacenado para limitar la consulta a 100 registros",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_catalogozona_2(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdCiudadCoppel SMALLINT, pTipoConsulta SMALLINT, pConsulta CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		SMALLINT AS numero_colonia,
		CHAR(32) AS nombre_zona,
		CHAR(27) AS nombre_municipio_zona;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdNumeroColonia SMALLINT;
	DEFINE cNombreZona CHAR(32);
	DEFINE cNombreMunicipio CHAR(27);
	DEFINE iTotalReg INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iNoRegistros = 0;
	LET iIdNumeroColonia = 0;
	LET cNombreZona = '';
	LET cNombreMunicipio = '';
	LET iTotalReg = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogozona_2.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pIdCiudadCoppel IS NULL OR pTipoConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		-- VALIDACIÃN DE LOS PARAMETROS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta NOT IN (1,2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta = 2 AND pConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pRegistros >= 0 AND pRegistros < 100 THEN
			IF pRecuperacion = pRegistros THEN
				LET iTotalReg = 100 - pRecuperacion;
				IF iTotalReg < pRecuperacion THEN
					LET pRecuperacion = iTotalReg;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '1001';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- VALIDAMOS QUE LA TABLA TENGA DATOS
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catzonas;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta = 1 THEN -- Tipo de consulta general
			FOREACH					
					SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona,a.municipiozona
                    INTO iIdNumeroColonia, cNombreZona, cNombreMunicipio
                    FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
                    WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
					 and lpad(a.codigopostalzona,5,'0') = b.d_codigo
                     and TRIM(a.nomzona_spmx) = b.d_asenta
                     and TRIM(a.mnpio_spmx) = b.d_mnpio
                    GROUP BY  a.numerocolonia, a.nombrezona,a.municipiozona ORDER BY a.nombrezona ASC
					
					LET iNoRegistros = iNoRegistros + 1;
					
					RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
		ELIF pTipoConsulta = 2 THEN
			FOREACH					
					SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona,a.municipiozona
                    INTO iIdNumeroColonia, cNombreZona, cNombreMunicipio
                    FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
                    WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
					 and lpad(a.codigopostalzona,5,'0') = b.d_codigo
					 and nombrezona LIKE '%' || TRIM(pConsulta) || '%'
                     and TRIM(a.nomzona_spmx) = b.d_asenta
                     and TRIM(a.mnpio_spmx) = b.d_mnpio
                    GROUP BY  a.numerocolonia, a.nombrezona,a.municipiozona ORDER BY a.nombrezona ASC
					
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
		END IF;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las ciudades",
"FECHA: 04/02/2025",
"AUTOR: Veronica Sanchez",
"DESCRIPCION: Se clona procedimiento almacenado para limitar la consulta a 100 registros",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_cli_busquedacalle(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcion CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		INTEGER AS numero_calle,
		CHAR(30) AS nombre_calle;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNumeroCalle INTEGER;
	DEFINE cNombreCalle CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iRegistros = 0;
	LET iNumeroCalle = 0;
	LET cNombreCalle = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cli_busquedacalle.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
            RETURN cCodRet, iNumeroCalle, cNombreCalle;
        END IF;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle
			INTO iNumeroCalle, cNombreCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle LIKE '%' || TRIM(UPPER(pDescripcion)) || '%' 
			ORDER BY nombrecalle ASC
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
		END FOREACH;
			
		IF iRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		ELIF iRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Veronica Sanchez",
"FECHA: 04/02/2025",
"DESCRIPCION: Se crea procedimiento almacenado para recuperar las calles de acuerdo a la descripcion",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_cli_busquedacalle_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcion CHAR(30))
	RETURNING CHAR(5) AS codret,
		INTEGER AS totalRegistros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cli_busquedacalle.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegistros;
		END IF;

		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
            RETURN cCodRet, iRegistros;
        END IF;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iRegistros
		FROM bdinteg:"informix".si_catcalles
		WHERE nombrecalle LIKE '%' || TRIM(UPPER(pDescripcion)) || '%';
			
		IF NVL(iRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iRegistros;
		END IF;
		
		RETURN cCodRet, iRegistros;
		
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Veronica Sanchez",
"FECHA: 04/02/2025",
"DESCRIPCION: Se crea procedimiento almacenado para recuperar las calles de acuerdo a la descripcion",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_cli_busquedazona(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdCiudadCoppel SMALLINT, pDescripcion CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		SMALLINT AS numero_colonia,
		CHAR(32) AS nombre_zona;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdNumeroColonia SMALLINT;
	DEFINE cNombreZona CHAR(32);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iNoRegistros = 0;
	LET iIdNumeroColonia = 0;
	LET cNombreZona = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdNumeroColonia, cNombreZona;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cli_busquedazona.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pDescripcion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona;
		END IF;
		
		-- VALIDACIÃN DE LOS PARAMETROS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
            RETURN cCodRet, iIdNumeroColonia, cNombreZona;
        END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH					
			SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona
            INTO iIdNumeroColonia, cNombreZona
            FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
            WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
			and lpad(a.codigopostalzona,5,'0') = b.d_codigo
	        and nombrezona LIKE '%' || TRIM(UPPER(pDescripcion)) || '%'
            and TRIM(a.nomzona_spmx) = b.d_asenta
            and TRIM(a.mnpio_spmx) = b.d_mnpio
            GROUP BY  a.numerocolonia, a.nombrezona ORDER BY a.nombrezona ASC
				
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdNumeroColonia, cNombreZona WITH RESUME;
		END FOREACH;
			
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona;
		END IF;
		
		IF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona;
		END IF;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Veronica Sanchez",
"FECHA: 04/02/2025",
"DESCRIPCION: Procedimiento almacenado encargado de recuperar las zonas",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_cli_busquedazona_totales(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdCiudadCoppel SMALLINT, pDescripcion CHAR(30))
	RETURNING CHAR(5) AS codret,
		SMALLINT AS totalRegistro;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cli_busquedazona.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pDescripcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
            RETURN cCodRet, iNoRegistros;
        END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
						
		SELECT COUNT(*) 
        INTO iNoRegistros
        FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
        WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
		and lpad(a.codigopostalzona,5,'0') = b.d_codigo
	    and nombrezona LIKE '%' || TRIM(UPPER(pDescripcion)) || '%'
        and TRIM(a.nomzona_spmx) = b.d_asenta
        and TRIM(a.mnpio_spmx) = b.d_mnpio;
			
		IF NVL(iNoRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Veronica Sanchez",
"FECHA: 04/02/2025",
"DESCRIPCION: Procedimiento almacenado encargado de recuperar las zonas",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_totalesarqueosucucaja(pUsuario CHAR(8),
                                                     pIdFuncion CHAR(10),
                                                     pIdPlaza CHAR(3),
                                                     pIdSucursal CHAR(4),
													 pFechaInicial DATE,
                                                     pFechaFinal DATE)

		RETURNING CHAR(5) AS codret,
				  INTEGER AS totalRegistros;

		DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
		DEFINE iTotalRegistros INTEGER;
		DEFINE cSucursal CHAR(4);
		DEFINE cNombreSuc CHAR(40);
	    DEFINE cDescPlazaCajaGeneralArq CHAR(40); 
		DEFINE fCantidad_1 FLOAT;
		DEFINE fCantidad_2 FLOAT;
		DEFINE fCantidad_3 FLOAT;
		DEFINE fCantidad_4 FLOAT;
		DEFINE fCantidad_5 FLOAT;
		DEFINE fCantidad_6 FLOAT;
		DEFINE fCantidad_7 FLOAT;
		DEFINE mSaldoTotalArq MONEY(14,2); 
		DEFINE dFechaArq DATE; 
		DEFINE cIdCajeroPrincArq CHAR(8);	
		DEFINE iTotSucursales INTEGER;
		DEFINE iSucAbrieron INTEGER;
		DEFINE iSucNoAbrio INTEGER; 
		DEFINE iSucCerraron INTEGER;
		DEFINE iSucPenCerrar INTEGER; 	
		DEFINE mSaldoTotal MONEY(14,2);
		DEFINE mTotalDotaciones MONEY(14,2); 
		DEFINE cIdDivisaArq CHAR(2); 
		DEFINE cDescDivisaArq CHAR(30);	
		DEFINE cNombreCajeroArq CHAR(45);

		LET cCodRet = '00000';
        LET iSqlErr = 0;
		LET iTotalRegistros =0;	
		LET cSucursal = '';
		LET cNombreSuc = '';
		LET cDescPlazaCajaGeneralArq = '';
	    LET fCantidad_1 =0;
		LET fCantidad_2 =0;
		LET fCantidad_3 =0;
		LET fCantidad_4 =0;
		LET fCantidad_5 =0;
		LET fCantidad_6 =0;
		LET fCantidad_7 =0;
		LET mSaldoTotalArq = 0.00; 
		LET dFechaArq = ''; 
		LET cIdCajeroPrincArq = '';
		LET iTotSucursales = 0;
		LET iSucAbrieron = 0;
		LET iSucNoAbrio = 0; 
		LET iSucCerraron = 0;
		LET iSucPenCerrar = 0;
		LET iTotalRegistros = 0;
		LET	mSaldoTotal = 0.00; 
		LET mTotalDotaciones = 0.00;
		LET cIdDivisaArq='';
		LET cDescDivisaArq ='';
		LET cNombreCajeroArq ='';
		
		BEGIN

			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				UPDATE bdicnweb:"informix".sw_verificastatusarqueosucaja
				SET status = 'E', total_registros = iTotalRegistros, error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                RETURN cCodRet, iTotalRegistros;
			END EXCEPTION;

			--SET DEBUG FILE TO '/tmp/mfinis/sp_totalesarqueosucucaja.out';
            --TRACE ON;

            IF pUsuario = '' OR pIdFuncion = '' OR pIdPlaza = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL THEN
				LET cCodRet = '00003';
				UPDATE bdicnweb:"informix".sw_verificastatusarqueosucaja
				SET status = 'E', total_registros = iTotalRegistros, error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iTotalRegistros;
            END IF;

            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				UPDATE bdicnweb:"informix".sw_verificastatusarqueosucaja
				SET status = 'E', total_registros = iTotalRegistros, error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iTotalRegistros;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;
								
			-- TRATAMIENTO POR VOLUMETRIA 
			DELETE FROM bdicnweb:"informix".sw_verificastatusarqueosucaja WHERE usuario_insert = pUsuario;
			INSERT INTO bdicnweb:"informix".sw_verificastatusarqueosucaja(usuario_insert,total_registros,status,error_proceso,error)
			VALUES(pUsuario, iTotalRegistros,'I','', ''); 
			
			--BORRA DATOS TABLA TEMPORAL 
			DELETE FROM "informix".sw_cg_arqueosucajatmp WHERE usuario = pUsuario;
			
			-- OBTIENE TOTALES SUCURSALES
			SELECT COUNT(*) INTO iTotSucursales
			FROM bdinteg:'informix'.si_sucursales WHERE tpo_sucursal = 'S';	
			
			SELECT COUNT(*) INTO iSucAbrieron 
			FROM bdisuc:'informix'.ss_pase_sucursal WHERE suc_abrio = 1 AND fecha_pase BETWEEN pFechaInicial AND pFechaFinal;			
			
			SELECT COUNT(*) INTO iSucCerraron 
			FROM bdisuc:'informix'.ss_pase_sucursal WHERE suc_cerro = 1 AND fecha_pase BETWEEN pFechaInicial AND pFechaFinal;
			
			LET iSucNoAbrio = iTotSucursales - iSucAbrieron;
			LET iSucPenCerrar = iSucAbrieron - iSucCerraron;
			
			-- OBTIENE SALDOS (TOTAL Y DOTACIONES)
			IF pIdPlaza = '000' THEN
				SELECT NVL(SUM(saldo_total),0) AS saldo_total INTO mSaldoTotal
				FROM bdisuc:'informix'.ss_saldossuc WHERE fecha >= pFechaInicial AND fecha <= pFechaFinal;
			ELSE
				SELECT NVL(SUM(sal.saldo_total),0) AS saldo_total INTO mSaldoTotal
				FROM bdisuc:'informix'.ss_saldossuc AS sal INNER JOIN bdinteg:'informix'.si_sucursales AS suc ON suc.sucursal = sal.sucursal
				INNER JOIN bdinteg:'informix'.si_plazas_cajagen AS pla ON suc.plaza_cajagen = pla.codigo_plaza AND pla.codigo_plaza = pIdPlaza
				AND sal.sucursal = CASE WHEN pIdSucursal = '0000' OR pIdSucursal = '' THEN sal.sucursal ELSE pIdSucursal END
				AND sal.fecha BETWEEN pFechaInicial AND pFechaFinal;
			END IF;
			
			LET mTotalDotaciones = mTotalDotaciones + mSaldoTotal;
							
			-- DETALLE CONSULTA
			IF pIdPlaza <> '000' AND pIdPlaza <> ''  AND pIdSucursal <> '0000' AND pIdSucursal <> ''  THEN
		
                	FOREACH
						    SELECT a.fecha,b.sucursal,b.nombre,c.descripcion,a.cantidad_1,a.cantidad_2, a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.saldo_total,NVL(a.cajero_principal,''),NVL(a.divisa,'') 
							INTO dFechaArq, cSucursal, cNombreSuc,cDescPlazaCajaGeneralArq, fCantidad_1,fCantidad_2,fCantidad_3,fCantidad_4,fCantidad_5,fCantidad_6, fCantidad_7,mSaldoTotalArq, cIdCajeroPrincArq,cIdDivisaArq
							FROM bdisuc:ss_saldossuc a
							INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal
							INNER JOIN bdinteg:si_plazas_cajagen c ON   b.plaza_cajagen = c.codigo_plaza
							WHERE a.sucursal IN (SELECT sucursal FROM bdinteg:'informix'.si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S' AND plaza_cajagen =pIdPlaza ) AND a.sucursal = pIdSucursal AND a.fecha >= pFechaInicial  AND a.fecha <= pFechaFinal 
							ORDER BY a.fecha
							-- OBTIENE DESCRIPCIN DIVISA
							IF cIdDivisaArq IS NOT NULL OR cIdDivisaArq <> '' THEN
								SELECT NVL(descripcion,'') INTO cDescDivisaArq 
								FROM bdinteg:'informix'.si_divisas WHERE divisa = cIdDivisaArq;
							END IF;
					
							-- OBTIENE NOMBRE CAJERO
							IF cIdCajeroPrincArq IS NOT NULL OR cIdCajeroPrincArq <> '' THEN
								SELECT NVL(nombre,'') INTO cNombreCajeroArq 
								FROM bdinteg:'informix'.si_ejecut 
								WHERE ejecutivo = cIdCajeroPrincArq; 				
							END IF;	
							
							INSERT INTO informix.sw_cg_arqueosucajatmp(usuario, fecha, idsuc, nomsuc, descplazagen, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, saldototal, idcajeroprinc,totsucursales, sucabrieron, sucnoabrio, succerraron, sucpencerrar,TotalDotaciones,SaldoTotalD,descdivisa,nomcajero)  
							VALUES(pUsuario, dFechaArq, cSucursal, cNombreSuc, cDescPlazaCajaGeneralArq, fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6, fCantidad_7, mSaldoTotalArq, cIdCajeroPrincArq, iTotSucursales, iSucAbrieron, iSucNoAbrio, iSucCerraron, iSucPenCerrar,mTotalDotaciones,mSaldoTotal,cDescDivisaArq,cNombreCajeroArq);
	 
                      END FOREACH;
            
			ELSE
				
				IF pIdPlaza <> '000' AND pIdPlaza <> ''  THEN
			 
                	FOREACH
							SELECT a.fecha,b.sucursal,b.nombre,c.descripcion,a.cantidad_1,a.cantidad_2, a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.saldo_total,NVL(a.cajero_principal,''),NVL(a.divisa,'')  
							INTO dFechaArq, cSucursal, cNombreSuc,cDescPlazaCajaGeneralArq, fCantidad_1,fCantidad_2,fCantidad_3,fCantidad_4,fCantidad_5,fCantidad_6, fCantidad_7,mSaldoTotalArq, cIdCajeroPrincArq,cIdDivisaArq
							FROM bdisuc:ss_saldossuc a
							INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal
							INNER JOIN bdinteg:si_plazas_cajagen c ON   b.plaza_cajagen = c.codigo_plaza
							AND a.sucursal IN (SELECT sucursal FROM bdinteg:'informix'.si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S'  AND plaza_cajagen =pIdPlaza ) AND a.fecha >= pFechaInicial  AND a.fecha <= pFechaFinal
						    ORDER BY a.fecha
							-- OBTIENE DESCRIPCIN DIVISA
							IF cIdDivisaArq IS NOT NULL OR cIdDivisaArq <> '' THEN
								SELECT NVL(descripcion,'') INTO cDescDivisaArq 
								FROM bdinteg:'informix'.si_divisas WHERE divisa = cIdDivisaArq;
							END IF;
					
							-- OBTIENE NOMBRE CAJERO
							IF cIdCajeroPrincArq IS NOT NULL OR cIdCajeroPrincArq <> '' THEN
								SELECT NVL(nombre,'') INTO cNombreCajeroArq 
								FROM bdinteg:'informix'.si_ejecut 
								WHERE ejecutivo = cIdCajeroPrincArq; 				
							END IF;	
							
							INSERT INTO informix.sw_cg_arqueosucajatmp(usuario, fecha, idsuc, nomsuc, descplazagen, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, saldototal, idcajeroprinc,totsucursales, sucabrieron, sucnoabrio, succerraron, sucpencerrar,TotalDotaciones,SaldoTotalD,descdivisa,nomcajero)  
							VALUES(pUsuario, dFechaArq, cSucursal, cNombreSuc, cDescPlazaCajaGeneralArq, fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6, fCantidad_7, mSaldoTotalArq, cIdCajeroPrincArq, iTotSucursales, iSucAbrieron, iSucNoAbrio, iSucCerraron, iSucPenCerrar,mTotalDotaciones,mSaldoTotal,cDescDivisaArq,cNombreCajeroArq); 
							
                      END FOREACH;
	
				ELSE 
    				IF pIdSucursal <> '0000' AND pIdSucursal <> '' THEN
				 
                	FOREACH
							SELECT a.fecha,b.sucursal,b.nombre,c.descripcion,a.cantidad_1,a.cantidad_2, a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.saldo_total,NVL(a.cajero_principal,''),NVL(a.divisa,'')  
							INTO dFechaArq, cSucursal, cNombreSuc,cDescPlazaCajaGeneralArq, fCantidad_1,fCantidad_2,fCantidad_3,fCantidad_4,fCantidad_5,fCantidad_6, fCantidad_7,mSaldoTotalArq, cIdCajeroPrincArq,cIdDivisaArq
							FROM bdisuc:ss_saldossuc a
							INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal
							INNER JOIN bdinteg:si_plazas_cajagen c ON   b.plaza_cajagen = c.codigo_plaza
							AND a.sucursal IN (SELECT sucursal FROM bdinteg:'informix'.si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S') AND a.sucursal = pIdSucursal AND a.fecha >= pFechaInicial  AND a.fecha <= pFechaFinal
							ORDER BY a.fecha
							-- OBTIENE DESCRIPCIN DIVISA
							IF cIdDivisaArq IS NOT NULL OR cIdDivisaArq <> '' THEN
								SELECT NVL(descripcion,'') INTO cDescDivisaArq 
								FROM bdinteg:'informix'.si_divisas WHERE divisa = cIdDivisaArq;
							END IF;
					
							-- OBTIENE NOMBRE CAJERO
							IF cIdCajeroPrincArq IS NOT NULL OR cIdCajeroPrincArq <> '' THEN
								SELECT NVL(nombre,'') INTO cNombreCajeroArq 
								FROM bdinteg:'informix'.si_ejecut 
								WHERE ejecutivo = cIdCajeroPrincArq; 				
							END IF;	
							
							INSERT INTO informix.sw_cg_arqueosucajatmp(usuario, fecha, idsuc, nomsuc, descplazagen, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, saldototal, idcajeroprinc,totsucursales, sucabrieron, sucnoabrio, succerraron, sucpencerrar,TotalDotaciones,SaldoTotalD,descdivisa,nomcajero)  
							VALUES(pUsuario, dFechaArq, cSucursal, cNombreSuc, cDescPlazaCajaGeneralArq, fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6, fCantidad_7, mSaldoTotalArq, cIdCajeroPrincArq, iTotSucursales, iSucAbrieron, iSucNoAbrio, iSucCerraron, iSucPenCerrar,mTotalDotaciones,mSaldoTotal,cDescDivisaArq,cNombreCajeroArq);
							
                      END FOREACH;

					ELSE
                          
					FOREACH
						    SELECT a.fecha,b.sucursal,b.nombre,c.descripcion,a.cantidad_1,a.cantidad_2, a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.saldo_total,NVL(a.cajero_principal,''),NVL(a.divisa,'')  
							INTO dFechaArq, cSucursal, cNombreSuc,cDescPlazaCajaGeneralArq, fCantidad_1,fCantidad_2,fCantidad_3,fCantidad_4,fCantidad_5,fCantidad_6, fCantidad_7,mSaldoTotalArq, cIdCajeroPrincArq,cIdDivisaArq
							FROM bdisuc:ss_saldossuc a
							INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal
							INNER JOIN bdinteg:si_plazas_cajagen c ON   b.plaza_cajagen = c.codigo_plaza
							AND a.sucursal IN (SELECT sucursal FROM bdinteg:'informix'.si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S') AND a.fecha >= pFechaInicial  AND a.fecha <= pFechaFinal
							ORDER BY a.fecha
							-- OBTIENE DESCRIPCIN DIVISA
							IF cIdDivisaArq IS NOT NULL OR cIdDivisaArq <> '' THEN
								SELECT NVL(descripcion,'') INTO cDescDivisaArq 
								FROM bdinteg:'informix'.si_divisas WHERE divisa = cIdDivisaArq;
							END IF;
					
							-- OBTIENE NOMBRE CAJERO
							IF cIdCajeroPrincArq IS NOT NULL OR cIdCajeroPrincArq <> '' THEN
								SELECT NVL(nombre,'') INTO cNombreCajeroArq 
								FROM bdinteg:'informix'.si_ejecut 
								WHERE ejecutivo = cIdCajeroPrincArq; 				
							END IF;	
							
							INSERT INTO informix.sw_cg_arqueosucajatmp(usuario, fecha, idsuc, nomsuc, descplazagen, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, saldototal, idcajeroprinc,totsucursales, sucabrieron, sucnoabrio, succerraron, sucpencerrar,TotalDotaciones,SaldoTotalD,descdivisa,nomcajero)  
							VALUES(pUsuario, dFechaArq, cSucursal, cNombreSuc, cDescPlazaCajaGeneralArq, fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6, fCantidad_7, mSaldoTotalArq, cIdCajeroPrincArq, iTotSucursales, iSucAbrieron, iSucNoAbrio, iSucCerraron, iSucPenCerrar,mTotalDotaciones,mSaldoTotal,cDescDivisaArq,cNombreCajeroArq);
						    
                      END FOREACH;
					END IF;
				END IF;
			END IF;

			
		SELECT COUNT(*) 
		INTO iTotalRegistros
		FROM "informix".sw_cg_arqueosucajatmp
		WHERE usuario = pUsuario;
	
        
		IF NVL(iTotalRegistros,0) = 0 THEN
		LET cCodRet = '00017';
		UPDATE bdicnweb:"informix".sw_verificastatusarqueosucaja
		SET status = 'T', total_registros = iTotalRegistros, error_proceso = 'N', error = cCodRet WHERE usuario_insert = pUsuario;
		RETURN cCodRet, iTotalRegistros;
		END IF;
		
		UPDATE bdicnweb:"informix".sw_verificastatusarqueosucaja
        SET status = 'T', total_registros = iTotalRegistros, error_proceso = 'N', error = cCodRet WHERE usuario_insert = pUsuario;
		RETURN cCodRet, iTotalRegistros;
			

		END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'DESCRIPCION: SPL que consulta el no total de registros para el llenado del Listado Arqueo Sucursales.',
'MODULO: Caja General',
'FUNCIONALIDAD: Arqueo de Sucursales Caja General',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 23/07/2021',
'DESCRIPCION: Se aplica tratamiento por volumetria y ajuste de campos',
'BD: bdicnweb',
'AUTOR: Gilberto Fco. Naranjo Valles',
'FECHA: 08/04/2025',
'DESCRIPCION: Se eliminan las directivas y se crean nuevos index en la bdisuc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_desbloqueocuentacre(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pTipo SMALLINT, pAreaPersonaSolicita CHAR(150), pMotivoBloqueo CHAR(150))
        RETURNING CHAR(5) AS codret;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp SMALLINT;
        DEFINE cMensajeRet CHAR(80);
        DEFINE cEmpresa CHAR(3);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cMensajeRet = '';
        LET cEmpresa = '001';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_desbloqueocuentacre.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pTipo IS NULL OR pAreaPersonaSolicita = '' OR pMotivoBloqueo = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuenta, '06', '1') INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                IF pTipo NOT IN (1, 2) THEN
                        LET cCodRet = '00249';
                        RETURN cCodRet;
                END IF;
                
                --EXECUTE PROCEDURE bdicred:'informix'.sp_desbloqueocuenta(cEmpresa, pCuenta, pUsuario, pTipo) INTO cCodRetSp, cMensajeRet;
				EXECUTE PROCEDURE bdicred:'informix'.sp_desbloqueocuenta(cEmpresa, pCuenta, pUsuario, pTipo, pAreaPersonaSolicita, pMotivoBloqueo) INTO cCodRetSp, cMensajeRet;
                LET iCodRetSp = cCodRetSp::INTEGER;
                
                IF iCodRetSp < 0 THEN
                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_desbloqueocuenta';
                ELIF iCodRetSp = 5 THEN -- EL CREDITO NO EXISTE EN LA BASE DE DATOS
                        LET cCodRet = '00009';
                ELIF iCodRetSp = 6 THEN -- LA CUENTA YA ESTA DESBLOQUEADA
                        LET cCodRet = '00032';
                ELIF iCodRetSp = 11 THEN -- LA CUENTA SE ENCUENTRA SALDADA
                        LET cCodRet = '00250';
                ELIF iCodRetSp = 7 THEN -- LA CUENTA SE ENCUENTRA EN CARTERA VENDIDA
                        LET cCodRet = '00033';
                ELIF iCodRetSp = 8 THEN -- CREDITO BLOQUEADO MANUALMENTE
                    LET cCodRet = '00018';
                ELIF iCodRetSp = 9 THEN -- 'NO ES POSIBLE DESBLOQUEAR, EL CRÃDITO HA SIDO BLOQUEADO MANUALMENTE'
                    LET cCodRet = '01128';
                ELIF iCodRetSp = 10 THEN -- BLOQUEO ACTUAL NO ES VALIDO, FAVOR DE VERIFICAR
                        LET cCodRet = '00251';
                END IF;
                
                RETURN cCodRet;
        
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 18/03/2014',
'DESCRIPCION: Desbloquea una cuenta de credito',
'AUTOR: Oscar Flores Conde',
'FECHA: 12/02/2015',
'DESCRIPCION: Se agregan los campos de area y justificacion',
'AUTOR: Carlos Macias',
'FECHA: 07/04/2025',
'DESCRIPCION: Se separan flags 8 y 9 con cÃ³digos diferentes, flag 9 ahora usa 01128',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_consultatotalmovtosdiarioscta_2(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20),pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2))
				returning CHAR(5)  AS Cod_Retorno,
						  INTEGER AS numero_registros;

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
DEFINE iTotal INTEGER; 
DEFINE iResta1 INTEGER;
DEFINE iResta2 INTEGER;
DEFINE iRegTotal INTEGER;
DEFINE iRegResta INTEGER;

--inicializando variables
LET  iexiste = 0;
LET  iExisteCta = 0;
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
LET iKiosko               =0;
LET iTotal = 0; 
LET iResta1 = 0;
LET iResta2 = 0;
LET iRegTotal = 0;
LET iRegResta = 0;

BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
               RETURN cCodRet, iCont;
          END IF;
     END EXCEPTION;
                
	--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_consultatotalmovtosdiarioscta_2.out";
	--TRACE ON;
                  
	IF cID_FUNCIONC = 'SKI002' THEN
		LET iKiosko = 1;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
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
		
		IF dPERIODOF = TODAY THEN
			SELECT COUNT(MO.cuenta)
			INTO iexiste
			FROM bdicheq:"informix".sc_movdia MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TR.se_emite_edocta END
			WHERE MO.fech_alt = dPERIODOF AND MO.empresa='001' AND MO.cuenta = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
			LET iCont = NVL(iexiste,0);
		END IF;

		IF (dPERIODOI < TODAY AND dPERIODOF >= cconsmovhis) THEN
			SELECT COUNT(MO.cuenta) 
			INTO iexiste
			FROM bdicheq:"informix".sc_movhis MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TR.se_emite_edocta END
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF 
			AND MO.fech_alt >= cconsmovhis AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
  
			LET iCont = iCont + NVL(iexiste,0);
		END IF;
		
		IF (dPERIODOI < cconsmovhis AND dPERIODOF >= cconsmovhisold) THEN
			SELECT COUNT(MO.cuenta) 
			INTO iexiste
			FROM bdicheq:"informix".sc_movhis_old MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TR.se_emite_edocta END
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF 
			AND MO.fech_alt >= cconsmovhisold AND MO.fech_alt < cconsmovhis 
			AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
			LET iCont = iCont + NVL(iexiste,0);
		END IF;
		IF (dPERIODOI < cconsmovhisold AND dPERIODOF >= cconsmovhisold2) THEN
			SELECT {+INDEX (bdicheq:sc_movhis_old2 idx_movhis_old2)} COUNT(MO.cuenta)
			INTO iexiste
			FROM bdicheq:"informix".sc_movhis_old2 MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF 
			AND MO.fech_alt >= cconsmovhisold2
			AND MO.fech_alt < cconsmovhisold AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END; 

			LET iCont = iCont + NVL(iexiste,0);
		END IF;
		
			SELECT COUNT(cuenta)
			INTO iExisteCta
			FROM bdicheq:sc_maechq 
			WHERE cuenta  = cNUMCUENTA
			AND producto IN ('1200', '9901', '1600', '2200', '2600');
		IF iExisteCta = 0 OR cID_FUNCIONC = 'ROA200' THEN
			IF (dPERIODOI < cconsmovhisold2 AND dPERIODOF >= cconsmovhisold3) THEN
				SELECT {+INDEX (bdicheq:sc_movhis_old3 idx_movhis_old3)} COUNT(MO.cuenta) 
				INTO iexiste
				FROM bdicheq:"informix".sc_movhis_old3 MO
				RIGHT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF 
				AND MO.fech_alt >= cconsmovhisold3 AND MO.fech_alt < cconsmovhisold2 
				AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END; 

				LET iCont = iCont + NVL(iexiste,0);

			END IF;

			IF  (dPERIODOI < cconsmovhisold3 AND dPERIODOF >= cconsmovhisold4) THEN
				SELECT COUNT(MO.cuenta)
				INTO iexiste
				FROM bdicheq:"informix".sc_movhis_old4 MO
				RIGHT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF 
				AND MO.fech_alt >= cconsmovhisold4 AND MO.fech_alt < cconsmovhisold3
				AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END; 
			
				LET iCont = iCont + NVL(iexiste,0);
			END IF;
		END IF;
		
		IF TRIM(SUBSTRING(cNUMCUENTA FROM 1 FOR 1)) = '8' THEN
			SELECT COUNT(cuenta)
			INTO iexiste
			FROM bditransfer:"informix".tf_success_transac
			WHERE fecha_alt < to_date('20/03/2015','%d/%m/%Y') 
			AND fecha_alt BETWEEN dPERIODOI AND dPERIODOF AND cuenta  = cNUMCUENTA 
			AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END; 

			LET iCont = iCont + NVL(iexiste,0);
		END IF;
		
		IF iCont  = 0 THEN
			LET cCodRet = "00039";
			RETURN cCodRet, iCont;
		END IF;

		IF (iCont>=1001 AND cID_FUNCIONC = 'ROA200')  THEN
			RETURN "00958", 0;
		ELSE 
			RETURN cCodRet, iCont;
		END IF;

	ELIF cSISTEMACUENTA = 'CREDITO' THEN
		SELECT COUNT(num_credito)
		INTO iExisteCta
		FROM bdicred:sd_maecred
		WHERE empresa = '001' AND num_credito = cNUMCUENTA;
		
		IF NVL(iExisteCta,0) > 0 THEN
			SELECT {+INDEX (bdicred:sd_movdia mov4)} COUNT(num_credito)
			INTO iexiste
			FROM bdicred:sd_movdia MO
			LEFT JOIN bdicred:sd_transfun TR
			ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
			RIGHT JOIN bdinteg:si_transacc TS
			ON TS.empresa = '001'
			AND TS.numero = TR.transacc
			AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
			WHERE MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA
			AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			IF iexiste  = 0 THEN
				SELECT {+INDEX (bdicred:sd_movhis inx_movhis4)} COUNT(num_credito)
				INTO iexiste
				FROM bdicred:sd_movhis MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
				IF NVL(iexiste,0)  = 0 THEN
					SELECT {+INDEX (bdicred:sd_movhis_new inx_movhis4_new)} COUNT(num_credito)
					INTO iexiste
					FROM bdicred:sd_movhis_new MO
					LEFT JOIN bdicred:sd_transfun TR
					ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
					RIGHT JOIN bdinteg:si_transacc TS
					ON TS.empresa = '001'
					AND TS.numero = TR.transacc
					AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
					WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
					AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
					AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
					AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
				END IF;
			END IF;
		ELSE
			SELECT COUNT(num_credito)
			INTO iexiste
			FROM bdicred:sd_movdiacrd
			WHERE empresa='001' AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND num_credito = cNUMCUENTA 
			AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
			AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
			AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END;
			IF NVL(iexiste,0)  = 0 THEN
				SELECT COUNT(num_credito)
				INTO iexiste
				FROM bdicred:sd_movhiscrd
				WHERE empresa='001' AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND num_credito = cNUMCUENTA 
				AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
				AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
				AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END;     
			END IF;
		END IF;
		
		IF NVL(iexiste,0)  = 0 THEN
		   LET cCodRet = "00039";
		   RETURN cCodRet, iCont;
		END IF;
		
		--LET iCont = iexiste;
		
		--RETURN cCodRet, iCont;
		
		/*-INICIO-*/
		
		IF NVL(iExisteCta,0) > 0 THEN
			--FOREACH
				SELECT COUNT(*) AS total,
				SUM(CASE WHEN (MO.codigo_fun = '001' AND MO.codigo_ref IN (1,2,3)) THEN 1 ELSE 0 END) AS resta1,
				SUM(CASE WHEN (MO.codigo_fun = '002' AND MO.codigo_ref = 1) THEN 1 ELSE 0 END) AS resta2
				INTO iTotal, iResta1, iResta2
				FROM bdicred:sd_movdia MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
				
				LET iRegTotal = iRegTotal + NVL(iTotal,0); 
				LET iRegResta = iRegResta + NVL(iResta1,0) + NVL(iResta2,0);
				
			--UNION
				SELECT COUNT(*) AS total,
				SUM(CASE WHEN (MO.codigo_fun = '001' AND MO.codigo_ref IN (1,2,3)) THEN 1 ELSE 0 END) AS resta1,
				SUM(CASE WHEN (MO.codigo_fun = '002' AND MO.codigo_ref = 1) THEN 1 ELSE 0 END) AS resta2
				INTO iTotal, iResta1, iResta2
				FROM bdicred:sd_movhis  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
				
				LET iRegTotal = iRegTotal + NVL(iTotal,0); 
				LET iRegResta = iRegResta + NVL(iResta1,0) + NVL(iResta2,0);
			--UNION 
				SELECT COUNT(*) AS total,
				SUM(CASE WHEN (MO.codigo_fun = '001' AND MO.codigo_ref IN (1,2,3)) THEN 1 ELSE 0 END) AS resta1,
				SUM(CASE WHEN (MO.codigo_fun = '002' AND MO.codigo_ref = 1) THEN 1 ELSE 0 END) AS resta2
				INTO iTotal, iResta1, iResta2
				FROM bdicred:sd_movhis_new  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
				LET iRegTotal = iRegTotal + NVL(iTotal,0); 
				LET iRegResta = iRegResta + NVL(iResta1,0) + NVL(iResta2,0);
			
			--END FOREACH;

			LET iCont = iRegTotal - iRegResta;
			RETURN cCodRet, iCont;
			
			
		
		ELSE
			--FOREACH
				SELECT COUNT(*) AS total,
				SUM(CASE WHEN (MO.codigo_fun = '001' AND MO.codigo_ref IN (1,2,3)) THEN 1 ELSE 0 END) AS resta1,
				SUM(CASE WHEN (MO.codigo_fun = '002' AND MO.codigo_ref = 1) THEN 1 ELSE 0 END) AS resta2
				INTO iTotal, iResta1, iResta2
				FROM bdicred:sd_movdiacrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
				LET iRegTotal = iRegTotal + NVL(iTotal,0); 
				LET iRegResta = iRegResta + NVL(iResta1,0) + NVL(iResta2,0);				
			--UNION
				SELECT COUNT(*) AS total,
				SUM(CASE WHEN (MO.codigo_fun = '001' AND MO.codigo_ref IN (1,2,3)) THEN 1 ELSE 0 END) AS resta1,
				SUM(CASE WHEN (MO.codigo_fun = '002' AND MO.codigo_ref = 1) THEN 1 ELSE 0 END) AS resta2
				INTO iTotal, iResta1, iResta2
				FROM bdicred:sd_movhiscrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;

				LET iRegTotal = iRegTotal + NVL(iTotal,0); 
				LET iRegResta = iRegResta + NVL(iResta1,0) + NVL(iResta2,0);
			
			--END FOREACH;

			LET iCont = iRegTotal - iRegResta;
			RETURN cCodRet, iCont;
			
			
		END IF;
		
		/*-FIN-*/
		
	ELIF cSISTEMACUENTA = 'INVERSIONES' THEN
		
		  SELECT COUNT(*) INTO iexiste
			   FROM bdinvers:sv_maeinv MC
			   LEFT JOIN bdinvers:sv_movdia MO
					ON MC.cuenta = MO.cuenta
			   LEFT JOIN bdinteg:si_transacc TR
					ON MO.transacc = TR.numero 
			   WHERE MO.cuenta = cNUMCUENTA
				   AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
				   AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				   AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				   AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
			LET iCont = NVL(iexiste,0);				
			
			   SELECT COUNT(*) INTO iexiste
			   FROM bdinvers:sv_maeinv MC
			   LEFT JOIN bdinvers:sv_movhis MO
					ON MC.cuenta = MO.cuenta
			   LEFT JOIN bdinteg:si_transacc TR
					ON MO.transacc = TR.numero 
			   WHERE MO.cuenta = cNUMCUENTA
				   AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
				   AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				   AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				   AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;

			LET iCont = NVL(iCont,0) + NVL(iexiste,0);

		IF iCont  = 0 THEN
			LET cCodRet = "00039";
			RETURN cCodRet, iCont;
		END IF;

		RETURN cCodRet, iCont;
		
		
	END IF
END
END PROCEDURE
DOCUMENT
"AutOR : Oscar Flores Conde",
"FUNCIONAMIENTO: Este sp realizara la consulta de numero de registros que regresara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques, para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 0-0-2012",
"Autor : Martha Salgado Mendoza",
"Descripciï¿½n: Se agrega parametro de entrada pMaxNumeroRegistros, validaciï¿½n total de registros > pMaxNumeroRegistros, modificaciï¿½n al sql que obtiene el total de reg para inversiones",
"Fecha :24/10/2017",
"Autor : L. Montserrat Leï¿½n Amador",
"Descripciï¿½n: Se realiza clon de spl para eliminar variables pMaxNumeroRegistros y pReversado ya que dichos parï¿½metros no son necesarios para obtener el nï¿½mero total de registros.",
"Fecha : 11/12/2017",
"Autor : L. Montserrat Leï¿½n Amador",
"Descripciï¿½n: Se modifica spl para optimizar el cï¿½lculo del nï¿½mero total de registros.",
"Fecha : 08/01/2018",
"BD    : bdicnweb",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_catalogocalle_2(pUsuario CHAR(8), pIdFuncion CHAR(10), pConsulta CHAR(30), pCliente CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		INTEGER AS numero_calle,
		CHAR(30) AS nombre_calle;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNumeroCalle INTEGER;
	DEFINE cNombreCalle CHAR(30);
	DEFINE iTotalReg INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iRegistros = 0;
	LET iNumeroCalle = 0;
	LET cNombreCalle = '';
	LET iTotalReg = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocalle_2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros >= 0 AND pRegistros < 100 THEN
			IF pRecuperacion = pRegistros THEN
				LET iTotalReg = 100 - pRecuperacion;
				IF iTotalReg < pRecuperacion THEN
					LET pRecuperacion = iTotalReg;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catcalles;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;	
		
		
		IF LENGTH(TRIM(pConsulta)) < 4 THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle
			INTO iNumeroCalle, cNombreCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle = TRIM(pConsulta)
			ORDER BY nombrecalle ASC
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
			END FOREACH;
		ELSE
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH
			
			SELECT a.numerocalle, a.nombrecalle 
			INTO iNumeroCalle, cNombreCalle 
			FROM(
			SELECT numerocalle, nombrecalle
			FROM bdinteg:"informix".si_catcalles
			WHERE numerocalle = (SELECT numerocalle FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pCliente AND secuencia = 
			                     (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pCliente AND tipo_dir = '1'))
			ORDER BY nombrecalle ASC )a
			UNION ALL
			SELECT b.numerocalle, b.nombrecalle 
			FROM (
			SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle 
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle LIKE '%' || TRIM(pConsulta) || '%' 
			ORDER BY nombrecalle ASC ) b
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
			END FOREACH;
		END IF;
		
		IF iRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		ELIF iRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las calles",
"FECHA: 04/02/2025",
"AUTOR: Veronica Sanchez",
"DESCRIPCION: Se clona procedimiento almacenado para limitar la consulta a 100 registros",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_catalogozona_2(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdCiudadCoppel SMALLINT, pTipoConsulta SMALLINT, pConsulta CHAR(30), pCliente CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		SMALLINT AS numero_colonia,
		CHAR(32) AS nombre_zona,
		CHAR(27) AS nombre_municipio_zona;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdNumeroColonia SMALLINT;
	DEFINE cNombreZona CHAR(32);
	DEFINE cNombreMunicipio CHAR(27);
	DEFINE iTotalReg INTEGER;
	DEFINE cCiudad INTEGER; 
	DEFINE cNumColonia INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iNoRegistros = 0;
	LET iIdNumeroColonia = 0;
	LET cNombreZona = '';
	LET cNombreMunicipio = '';
	LET iTotalReg = 0;
	LET cCiudad = 0; 
	LET cNumColonia = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogozona_2.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pIdCiudadCoppel IS NULL OR pTipoConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		-- VALIDACIÃN DE LOS PARAMETROS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta NOT IN (1,2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta = 2 AND pConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pRegistros >= 0 AND pRegistros < 100 THEN
			IF pRecuperacion = pRegistros THEN
				LET iTotalReg = 100 - pRecuperacion;
				IF iTotalReg < pRecuperacion THEN
					LET pRecuperacion = iTotalReg;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '1001';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- VALIDAMOS QUE LA TABLA TENGA DATOS
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catzonas;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		--CONSULTA CIUDAD Y COLONIA
		SELECT numerociudad, numerocolonia 
		INTO  cCiudad, cNumColonia
		FROM bdinteg:"informix".si_direcciones_actual
		WHERE numcte = pCliente
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pCliente AND tipo_dir = '1');
		
		IF pTipoConsulta = 1 THEN -- Tipo de consulta general
			FOREACH	
			
                    SELECT  a.numerocolonia, a.nombrezona,a.municipiozona 
                     INTO iIdNumeroColonia, cNombreZona, cNombreMunicipio
                      FROM (
					   SELECT numerocolonia, nombrezona,municipiozona
                       FROM bdinteg:"informix".si_catzonas
                       WHERE numerociudad = cCiudad 
                       AND numerocolonia = cNumColonia) a
				     UNION ALL
					  SELECT   b.numerocolonia, b.nombrezona,b.municipiozona 
					  FROM (
					   SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona,a.municipiozona
                       FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
                       WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
					   and lpad(a.codigopostalzona,5,'0') = b.d_codigo
                       and TRIM(a.nomzona_spmx) = b.d_asenta
                       and TRIM(a.mnpio_spmx) = b.d_mnpio
                       GROUP BY  a.numerocolonia, a.nombrezona,a.municipiozona ORDER BY a.nombrezona ASC ) b
					
					LET iNoRegistros = iNoRegistros + 1;
					
					RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
		ELIF pTipoConsulta = 2 THEN
			FOREACH					
					SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona,a.municipiozona
                    INTO iIdNumeroColonia, cNombreZona, cNombreMunicipio
                    FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
                    WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
					 and lpad(a.codigopostalzona,5,'0') = b.d_codigo
					 and nombrezona LIKE '%' || TRIM(pConsulta) || '%'
                     and TRIM(a.nomzona_spmx) = b.d_asenta
                     and TRIM(a.mnpio_spmx) = b.d_mnpio
                    GROUP BY  a.numerocolonia, a.nombrezona,a.municipiozona ORDER BY a.nombrezona ASC
					
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
		END IF;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las ciudades",
"FECHA: 04/02/2025",
"AUTOR: Veronica Sanchez",
"DESCRIPCION: Se clona procedimiento almacenado para limitar la consulta a 100 registros",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_consaldodisp(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pSistemaCuenta CHAR(2))
        RETURNING 
                CHAR(5) AS codret,
                DECIMAL(14,2) AS saldo_disponible;
        
        DEFINE cCodRet CHAR(5);
        DEFINE dSaldoDisponible DECIMAL(14,2);
        DEFINE iSqlErr INTEGER;
        DEFINE cNumProductoCred CHAR(4);
        DEFINE cCodTipoCred CHAR(2);
        
        LET dSaldoDisponible = 0;
        LET iSqlErr = 0;
        LET cCodRet = '00000';
        LET cNumProductoCred = '';
        LET cCodTipoCred = '';
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN
                
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, dSaldoDisponible;
                        
                        END IF;
                END EXCEPTION;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, dSaldoDisponible;
                END IF;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pSistemaCuenta = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, dSaldoDisponible;
                END IF;
                
                IF pSistemaCuenta NOT IN ('01', '03', '06') THEN
                        LET cCodRet = '00037';
                END IF;
                
                IF pSistemaCuenta = '01' THEN
                        
                        --SET ISOLATION TO DIRTY READ;
                        --RQM 09 704. Se agrega el valor del campo saldo_sbc al calculo de saldo disponible. DHG
                        SELECT  sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc) AS saldo_disponible
                        INTO dSaldoDisponible
                        FROM  bdicheq:"informix".sc_maechq
                        WHERE cuenta = pCuenta AND empresa='001';
                        
                        RETURN cCodRet, dSaldoDisponible;
                        
                ELIF pSistemaCuenta = '03' THEN
                        
                        --SET ISOLATION TO DIRTY READ;
                        
                        SELECT NVL(mi.capital, 0)
                        INTO dSaldoDisponible
                        FROM bdinvers:sv_maeinv mi
                        WHERE mi.cuenta = pCuenta
                                AND mi.secuencia = (SELECT NVL(MAX(secuencia),0) FROM bdinvers:sv_maeinv WHERE empresa = mi.empresa and cuenta = mi.cuenta);
                
                        RETURN cCodRet, dSaldoDisponible;
                ELIF pSistemaCuenta = '06' THEN
                        
                        --SET ISOLATION TO DIRTY READ;
                        
                        SELECT d.num_producto, d.cod_tipcred
                        INTO cNumProductoCred, cCodTipoCred
                        FROM bdicred:"informix".sd_maecred c, bdicred:"informix".sd_definicion d
                        WHERE c.empresa ='001'  
								AND c.num_credito = pCuenta
                                AND d.empresa = c.empresa
                                AND d.num_producto = c.num_producto;
                                
                        
                        IF cNumProductoCred IN ('6001','8100','7000','8500', '5400') THEN -- Tarjeta de Credito Bancoppel Visa, ORO Y PLATINO , Se agrega TDC GC
                                --SET ISOLATION TO DIRTY READ;
                                
                                --SELECT (NVL(m2.monto_otorgado,0) - NVL(m2.sdo_cap_insoluto,0) - NVL(m2.sdo_retenido,0))
								SELECT NVL(m2.sdo_capital,0)
                                INTO dSaldoDisponible
                                FROM bdicred:"informix".sd_maesdos m2
                                WHERE num_credito = pCuenta AND empresa='001';
                        ELIF cCodTipoCred = '05' THEN -- Prestamo Personal
                                --SET ISOLATION TO DIRTY READ;
                                
                                SELECT m2c.sdo_capital
                                INTO dSaldoDisponible
                                FROM bdicred:"informix".sd_maesdoscrd m2c
                                WHERE m2c.num_credito = pCuenta;
                        END IF;
                        
                        RETURN cCodRet, dSaldoDisponible;
                END IF;
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 14/04/2014',
'DESCRIPCION: Consulta el saldo disponible de una cuenta de captacion/inversion/credito',
'BD: bdicnweb',
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 05-06-2025',
'MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible',
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicnweb',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_ope_cons_ticketabonoapp_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pFolioSuc CHAR(16), pHuella CHAR(1), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
				CHAR(5) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(15) AS origen,  
				CHAR(20) AS numCuenta,
				CHAR(16) AS numTarjeta,
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(10) AS telefono, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(100) AS retorno2,
				CHAR(150) AS retorno3;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(5);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(15);  
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cNumcuenta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cRetorno2 CHAR(100);
	DEFINE cRetorno3 CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cOrigen = ''; 
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cTelefono = ''; 
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cNumcuenta = '';
	LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cRetorno2 = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketAbonoApp_web.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' OR pFolioSuc = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END IF;

		IF ((SELECT COUNT(referencia1) FROM bdisac:"informix".sac_movimientoshistorial WHERE referencia1 = pReferencia AND numconvenio IN ('004','006','007','008','009')) <> 0) THEN

			SELECT  FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis AS c ON c.folio_suc =  a.folio_suc AND c.sucursal = '5011'
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte   
			INNER JOIN bdinteg:"informix".si_telefonos_actual as g ON g.numcte = f.numcte
			WHERE a.referencia1 = pReferencia 
			  AND a.folio_suc = pFolioSuc 
			  AND a.forma_pago = '4'			 
			  AND a.status_cancelado <> 'S';

		ELSE
			--REMESAS DE MAS DE 3 MESES
			SELECT  FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial_old AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis_old AS c ON c.folio_suc =  a.folio_suc AND c.sucursal = '5011'
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte   
			INNER JOIN bdinteg:"informix".si_telefonos as g ON g.numcte = f.numcte
			WHERE a.referencia1 = pReferencia 
			  AND a.folio_suc = pFolioSuc 
			  AND a.forma_pago = '4' 
			  AND a.status_cancelado <> 'S';
		END IF;

		IF LEN(cOrigen) = 0 THEN
				LET cOrigen = 'BCL';
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00029';
			LET cRetorno3 = 'B6 - No se encontro informacion del cliente';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		ELSE
			IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas WHERE num_confirmacion = pReferencia) <> 0) THEN 

				SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
				TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
				INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
				FROM bdisac:"informix".sac_pld_remesas
				WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
			ELSE
				IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas_old WHERE num_confirmacion = pReferencia) <> 0 ) THEN  

					SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
					TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
					INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
					FROM bdisac:"informix".sac_pld_remesas_old
					WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
				ELSE
					LET cCodRet= '00034';
					LET cRetorno3 = 'B6 - No se encontro informacion relacionada';
					RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
						cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
				END IF;			
			END IF;
		
			SELECT MAX(secuencia) 
				INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND estado = 'A';

			SELECT dmapa 
				INTO cCadenaTran
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND secuencia = cSecuenciaMax;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCadenaTran = '';
			END IF;
			
			SELECT nombre, plaza 
				INTO cNomSucursal, cPlaza 
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = cSucursal;
			
			SELECT nombre 
				INTO cNomPlaza 
			FROM bdinteg:"informix".si_plazas
			WHERE plaza = cPlaza;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cNomPlaza = '';
			END IF;
		
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
				INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
				cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;
				
				LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
					
			END IF;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'MODIFICACION: FG',
'FECHA: 28/09/2025',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informacion para formato Abono App',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cons_ticketabonovent_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pHuella CHAR(1), pNumCliente CHAR(20))
	RETURNING   CHAR(5) AS codret,
				CHAR(3) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc,
				CHAR(15) AS origen, 
				CHAR(20) AS numCuenta,
				CHAR(16) AS numTarjeta,
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(10) AS telefono, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(100) AS retorno2,
				CHAR(150) AS retorno3;
				
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(3);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(15); 
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cNumcuenta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cRetorno2 CHAR(100); 
	DEFINE cRetorno3 CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cOrigen = ''; 

	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cTelefono = ''; 
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cNumcuenta = '';
	LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cRetorno2 = '';  
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketAbonoVent_web.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END IF;
		
		IF ((SELECT COUNT(referencia1) FROM bdisac:"informix".sac_movimientoshistorial WHERE referencia1 = pReferencia AND numconvenio IN ('004','006','007','008','009')) <> 0 ) THEN

			SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, 
			CASE WHEN c.sucursal = '5011' THEN a.sucursal_cpl ELSE a.id_sucursal END, 
			TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis AS c ON c.folio_suc =  a.folio_suc AND c.sucursal NOT IN ('9250','9764') 
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
			INNER JOIN bdinteg:"informix".si_telefonos_actual as g ON g.numcte = f.numcte
			WHERE a.referencia1 = pReferencia 
			  AND a.forma_pago = '4';

		ELSE 
			--REMESAS DE MAS DE 3 MESES
			SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, 
			CASE WHEN c.sucursal = '5011' THEN a.sucursal_cpl ELSE a.id_sucursal END, 
			TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial_old AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND  b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis_old AS c ON c.folio_suc =  a.folio_suc AND c.sucursal NOT IN ('9250','9764')
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
			INNER JOIN bdinteg:"informix".si_telefonos_actual as g ON g.numcte = f.numcte 
			WHERE a.referencia1 = pReferencia 
			AND a.forma_pago = '4';
		END IF;

		IF LEN(cOrigen) = 0 THEN
			LET cOrigen = 'BCL';
		END IF;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00021';
			LET cRetorno3 = 'B4 - No se encontro informacion del cliente';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		ELSE

			IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas WHERE num_confirmacion = pReferencia) <> 0) THEN 

				SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
				TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
				INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
				FROM bdisac:"informix".sac_pld_remesas
				WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
			ELSE
				IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas_old WHERE num_confirmacion = pReferencia) <> 0 ) THEN 

					SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
					TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
					INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
					FROM bdisac:"informix".sac_pld_remesas_old  
					WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
				ELSE
					LET cCodRet= '00033';
					LET cRetorno3 = 'B4 - No se encontro informacion relacionada';
					RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
				END IF;			
			END IF;	
					
			SELECT MAX(secuencia) 
				INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella 
			WHERE numcte = cNumcliente
			AND estado = 'A';

			SELECT dmapa 
				INTO cCadenaTran
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND secuencia = cSecuenciaMax;
				
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCadenaTran = '';
			END IF;

			SELECT nombre, plaza 
				INTO cNomSucursal, cPlaza 
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = cSucursal;
			
			SELECT nombre 
				INTO cNomPlaza 
			FROM bdinteg:"informix".si_plazas
			WHERE plaza = cPlaza;
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cNomPlaza = '';
			END IF;
				
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				
				EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
				INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
				cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;
					
				LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
							
			END IF;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
				   cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'MODIFICACION: FG',
'FECHA: 28/09/2025',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para el formato Abono por Ventanilla',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cons_ticketefectivovent_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pHuella CHAR(1))
	RETURNING CHAR(5) AS codret,
				CHAR(5) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(15) AS origen,  
				CHAR(4) AS sucursal,  
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(10) AS telefono,  
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(20) AS cuenta,
				CHAR(16) AS tarjeta,
				CHAR(100) AS retorno2,
				CHAR(150) AS retorno3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(5);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(15); 
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	DEFINE cRetorno2 CHAR(100);
	DEFINE cRetorno3 CHAR(150);

	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cCuenta VARCHAR(20);
	DEFINE cTarjeta VARCHAR(16);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cOrigen = ''; 
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cTelefono = ''; 
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cCuenta = '';
	LET cTarjeta = '';
	LET cRetorno2 = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketEfectivoVent_web.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
			END IF;

			IF ((SELECT COUNT(referencia1) FROM bdisac:"informix".sac_movimientoshistorial WHERE referencia1 = pReferencia AND numconvenio IN ('004','006','007','008','009')) <> 0) THEN 

				SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen
				INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen
				FROM bdisac:"informix".sac_movimientoshistorial AS a
				INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio
				WHERE b.numcategoria = '07' 
				  AND a.referencia1 = pReferencia;

			ELSE 
				--REMESAS DE MAS DE 3 MESES
				SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen
				INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen
				FROM bdisac:"informix".sac_movimientoshistorial_old AS a
				INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio
				WHERE b.numcategoria = '07' 
				  AND a.referencia1 = pReferencia;

			END IF; 

			IF LEN(cOrigen) = 0 THEN
				LET cOrigen = 'BCL';
			END IF;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN 
				LET cCodRet= '00022';
				LET cRetorno3 = 'B5 - No se encontro informacion del cliente';
				RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
			ELSE
				--/////////WESTERN UNION/////////
				IF cNumConvenio = '006' OR cNumConvenio = '007' OR cNumConvenio = '008'  THEN 

					IF ((SELECT COUNT(mtcn) FROM bdisac:"informix".sac_wu_pay WHERE mtcn = cReferencia) <> 0 ) THEN 

						SELECT
							wu.benef_nombre1,
							wu.benef_nombre2,
							wu.benef_appaterno,
							wu.benef_apmaterno,
							wu.benef_id_number,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno)
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
						FROM bdisac:"informix".sac_wu_pay AS wu 
						INNER JOIN bdisac:"informix".sac_pld_remesas AS pld ON wu.mtcn = pld.num_confirmacion AND wu.foreign_rs_refnum_rp= pld.folio_sucursal 
						WHERE wu.mtcn = cReferencia 
						  AND wu.foreign_rs_refnum_rp = cFolioSuc;

						--/////////si los datos vienen vacios se consulta los datos en las tablas QRY--
						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
								
							SELECT
								wu.benef_nombre1,
								wu.benef_nombre2,
								wu.benef_appaterno,
								wu.benef_apmaterno,
								wu.benef_id_number,
								TRIM(s.emisor_nombre1) || ' ' || TRIM(s.emisor_nombre2) || ' ' || 
								TRIM(s.emisor_appaterno) || ' ' || TRIM(s.emisor_apmaterno)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_wu_pay AS wu 
							INNER JOIN bdisac:"informix".sac_wu_search AS s ON wu.mtcn = s.mtcn 	
							WHERE s.mtcn = cReferencia 
							  AND s.foreign_rs_refnum_rp = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00023';
								LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					ELSE 
						--REMESAS DE MAS DE 3 MESES
						IF ((SELECT COUNT(mtcn) FROM bdisac:"informix".sac_wu_pay_old WHERE mtcn = cReferencia) <> 0 ) THEN
							
							SELECT
									wu.benef_nombre1,
									wu.benef_nombre2,
									wu.benef_appaterno,
									wu.benef_apmaterno,
									wu.benef_id_number,
									TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
									TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno)
								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
								FROM bdisac:"informix".sac_wu_pay_old AS wu 
								INNER JOIN bdisac:"informix".sac_pld_remesas_old AS pld ON wu.mtcn = pld.num_confirmacion AND wu.foreign_rs_refnum_rp= pld.folio_sucursal  
								WHERE wu.mtcn = cReferencia 
								  AND wu.foreign_rs_refnum_rp = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
										
								SELECT
									wu.benef_nombre1,
									wu.benef_nombre2,
									wu.benef_appaterno,
									wu.benef_apmaterno,
									wu.benef_id_number,
									TRIM(s.emisor_nombre1) || ' ' || TRIM(s.emisor_nombre2) || ' ' || 
									TRIM(s.emisor_appaterno) || ' ' || TRIM(s.emisor_apmaterno)
								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
								FROM bdisac:"informix".sac_wu_pay_old AS wu 
								INNER JOIN bdisac:"informix".sac_wu_search_old AS s ON wu.mtcn = s.mtcn 
								WHERE s.mtcn = cReferencia 
								  AND s.foreign_rs_refnum_rp = cFolioSuc;

								IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
									TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

									LET cCodRet= '00024';
									LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
									RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
										cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
								END IF;
							END IF;
						END IF;
					END IF;

				--/////////BTS/////////
				ELIF cNumConvenio = '004' THEN

					IF ((SELECT COUNT(confirmation_nm) FROM bdisac:"informix".sac_bts_payi WHERE confirmation_nm = cReferencia) <>0) THEN

						SELECT
							bts.r_first_name,
							bts.r_middle_name,
							bts.r_last_name,
							bts.r_mother_m_name,
							bts.r_identif_nm,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
						FROM bdisac:"informix".sac_bts_payi AS bts 
						INNER JOIN bdisac:"informix".sac_pld_remesas AS pld ON bts.confirmation_nm = pld.num_confirmacion AND bts.bank_ref_nm = pld.folio_sucursal 
						WHERE bts.confirmation_nm = cReferencia 
						  AND bts.bank_ref_nm = cFolioSuc;

						-- /////////si los datos vienen vacios se consulta los datos en las tablas QRY--
						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
				
							SELECT
								bts.r_first_name,
								bts.r_middle_name,
								bts.r_last_name,
								bts.r_mother_m_name,
								bts.r_identif_nm,
								TRIM(s.s_first_name) || ' ' || TRIM(s.s_middle_name) || ' ' || 
								TRIM(s.s_last_name) || ' ' || TRIM(s.s_mother_m_name)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_bts_payi AS bts 
							INNER JOIN bdisac:"informix".sac_bts_qryi AS s ON bts.confirmation_nm = s.confirmation_nm 	
							WHERE bts.confirmation_nm = cReferencia 
							  AND bts.bank_ref_nm = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00025';
								LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					ELSE 
						--REMESAS DE MAS DE 3 MESES
						IF ((SELECT COUNT(confirmation_nm) FROM bdisac:"informix".sac_bts_payi_old WHERE confirmation_nm = cReferencia) <>0) THEN

							SELECT
								bts.r_first_name,
								bts.r_middle_name,
								bts.r_last_name,
								bts.r_mother_m_name,
								bts.r_identif_nm,
								TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
								TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
							FROM bdisac:"informix".sac_bts_payi_old AS bts 
							INNER JOIN bdisac:"informix".sac_pld_remesas_old AS pld ON bts.confirmation_nm = pld.num_confirmacion AND bts.bank_ref_nm = pld.folio_sucursal 
							WHERE bts.confirmation_nm = cReferencia 
							  AND bts.bank_ref_nm = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
				
								SELECT
									bts.r_first_name,
									bts.r_middle_name,
									bts.r_last_name,
									bts.r_mother_m_name,
									bts.r_identif_nm,
									TRIM(s.s_first_name) || ' ' || TRIM(s.s_middle_name) || ' ' || 
									TRIM(s.s_last_name) || ' ' || TRIM(s.s_mother_m_name)
								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
								FROM bdisac:"informix".sac_bts_payi_old AS bts 
								INNER JOIN bdisac:"informix".sac_bts_qryi_old AS s ON bts.confirmation_nm = s.confirmation_nm	
								WHERE bts.confirmation_nm = cReferencia 
								  AND bts.bank_ref_nm = cFolioSuc;

								IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
									TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

									LET cCodRet= '00026';
									LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
									RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
										cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
								END IF;
							END IF;
						END IF;
					END IF;

				--/////////APP/////////
				ELIF cNumConvenio = '009' THEN

					IF ((SELECT COUNT(unirefnum) FROM bdisac:"informix".sac_app_payi WHERE unirefnum = cReferencia) <> 0) THEN
	
						SELECT FIRST 1
							app.firstname,
							app.middlename,
							app.lastname,
							app.mommaidenname,
							app.numberci,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
						FROM bdisac:"informix".sac_app_payi AS app 
						INNER JOIN bdisac:"informix".sac_pld_remesas AS pld 
						ON app.unirefnum = pld.num_confirmacion AND
						app.refnum = pld.folio_sucursal 
						WHERE app.unirefnum = cReferencia AND
						app.refnum=cFolioSuc;

					-- /////////si los datos vienen vacios se consulta los datos en las tablas QRY--
						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
							
							SELECT FIRST 1
								app.firstname,
								app.middlename,
								app.lastname,
								app.mommaidenname,
								app.numberci,
								TRIM(s.r_firstname) || ' ' || TRIM(s.r_middlename) || ' ' || 
								TRIM(s.r_lastname) || ' ' || TRIM(s.r_mommaidenname)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_app_payi AS app 
							INNER JOIN bdisac:"informix".sac_app_qryi AS s ON app.unirefnum = s.unirefnum 
							WHERE s.unirefnum = cReferencia 
							  AND app.refnum = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00027';
								LET cRetorno3 = 'No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					ELSE 
					--REMESAS DE MAS DE 3 MESES
					IF ((SELECT COUNT(unirefnum) FROM bdisac:"informix".sac_app_payi_old WHERE unirefnum = cReferencia) <> 0) THEN

						SELECT
							app.firstname,
							app.middlename,
							app.lastname,
							app.mommaidenname,
							app.numberci,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
						FROM bdisac:"informix".sac_app_payi_old AS app 
						INNER JOIN bdisac:"informix".sac_pld_remesas_old AS pld ON app.unirefnum = pld.num_confirmacion AND app.refnum = pld.folio_sucursal 
						WHERE app.unirefnum = cReferencia 
						  AND app.refnum = cFolioSuc;

						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
				
							SELECT
								app.firstname,
								app.middlename,
								app.lastname,
								app.mommaidenname,
								app.numberci,
								TRIM(s.r_firstname) || ' ' || TRIM(s.r_middlename) || ' ' || 
								TRIM(s.r_lastname) || ' ' || TRIM(s.r_mommaidenname)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_app_payi_old AS app 
							INNER JOIN bdisac:"informix".sac_app_qryi_old AS s ON app.unirefnum = s.unirefnum 
							WHERE s.unirefnum = cReferencia 
							  AND app.refnum = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00028';
								LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					END IF;
				END IF; 
			END IF;  


			SELECT numcte
			INTO cNumcliente 
			FROM bdinteg:"informix".si_cliente 
			WHERE apell_paterno	= cApPaternoBen
			  AND apell_materno = cApMaternoBen
			  AND nombre1 = cNombre1Ben
			  AND nombre2 = cNombre2Ben;


			SELECT FIRST 1 telefono
			INTO cTelefono 
			FROM bdinteg:"informix".si_telefonos_actual
			WHERE numcte = cNumcliente
			  AND status_tel = 'A';
			

			SELECT MAX(secuencia) 
			INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND estado = 'A';

			SELECT dmapa 
			INTO cCadenaTran
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND secuencia = cSecuenciaMax;
						
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCadenaTran = '';
					END IF;

						SELECT nombre, plaza 
						INTO cNomSucursal, cPlaza 
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = cSucursal;
							
						SELECT nombre 
						INTO cNomPlaza 
						FROM bdinteg:"informix".si_plazas
						WHERE plaza = cPlaza;
				
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cNomPlaza = '';
						END IF;
					
							IF DBINFO('sqlca.sqlerrd2') > 0 THEN
								EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
								INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
								cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;	
								LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
							END IF;

							RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					               cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
				END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: FG',
'FECHA: 28/09/2025',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para el formato Efectivo Ventanilla',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consmovimientos_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pRemesadora CHAR(10), pFechaInicio DATE, pFechaFin DATE, pCveRemesa CHAR(20),
													pNumCliente CHAR(9), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			  CHAR(3) AS numconvenio,
			  CHAR(40) AS nomconvenio,
			  CHAR(20) AS num_cte,
			  DATE AS fech_oper,
			  CHAR(4) AS sucursal,
			  CHAR(16) AS folio_suc,
			  CHAR(40) AS referencia1,
			  CHAR(100) AS nomCliente,
			  CHAR(150) AS retorno3,
			  CHAR(1) AS formaPago,
			  CHAR(8) AS usuario;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumconvenio CHAR(3);
	DEFINE cNomconvenio CHAR(40);
	DEFINE cNum_cte CHAR(20);
	DEFINE dFech_oper DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cFolio_suc CHAR(16);
	DEFINE iTotRegistros INTEGER;
	DEFINE iTotRegistros2 INTEGER;
	DEFINE cReferencia1 CHAR(40);
	DEFINE cNomCliente CHAR(100);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cAppPaterno CHAR(26);
	DEFINE cAppMaterno CHAR(26);
	DEFINE cRetorno3 CHAR(150);
	DEFINE cFormaPago CHAR(1);
	DEFINE cUsuario CHAR(8);


	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumconvenio = '';
	LET cNomconvenio = '';
	LET cNum_cte = '';
	LET dFech_oper = '';
	LET cSucursal = '';
	LET cFolio_suc = '';
	LET iTotRegistros = 0;
	LET iTotRegistros2 = 0;
	LET cReferencia1 = '';
	LET cNomCliente = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cAppPaterno = '';
	LET cAppMaterno = '';
	LET cRetorno3 = '';
	LET cFormaPago = '';
	LET cUsuario = '';


	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END EXCEPTION;
	 
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consmovimientos_web.out';
		-- TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCveRemesa = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END IF;		
		
		--VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END IF;


		IF ((SELECT COUNT(referencia1) FROM bdisac:sac_movimientoshistorial WHERE referencia1 = pCveRemesa) <> 0) THEN   
								
			IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial AS a INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN 
									
				SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
				INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
				FROM bdisac:sac_movimientoshistorial AS a
				INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc 
				INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
				INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
				LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
				WHERE a.forma_pago IN (4 , 1) 
				AND b.sucursal NOT IN ('9250','9764','9251') 
				AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
				AND c.numcategoria = '07' 
				AND b.cancelad <> 'S' 
				AND a.status_cancelado <> 'S'
				AND a.numconvenio IN ('004','006','007','008','009') 
				AND a.referencia1 = pCveRemesa; 

					IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
						TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

							LET cCodRet= '00017';
							LET cRetorno3 = 'No se encontro informacion del cliente';
							RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
					END IF; 
				RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
			ELSE
				IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial AS a INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN
			
					SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
					INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
					FROM bdisac:sac_movimientoshistorial AS a
					INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc 
					INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
					INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
					LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
					WHERE a.forma_pago IN (4 , 1) 
					AND b.sucursal NOT IN ('9250','9764','9251') 
					AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
					AND c.numcategoria = '07' 
					AND b.cancelad <> 'S' 
					AND a.status_cancelado <> 'S'
					AND a.numconvenio IN ('004','006','007','008','009') 
					AND a.referencia1 = pCveRemesa; 

						IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
							TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

								LET cCodRet= '00017';
								LET cRetorno3 = 'No se encontro informacion del cliente';
								RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
						END IF; 	
					RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
				ELSE 	
					LET cCodRet= '00018';
					LET cRetorno3 = 'No se encontro informacion relacionada';
					RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;			
				END IF;
			END IF;
		ELSE	
			IF ((SELECT COUNT(referencia1) FROM bdisac:sac_movimientoshistorial_old WHERE referencia1 = pCveRemesa) <> 0) THEN		

				IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial_old AS a INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN

					SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
					INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
					FROM bdisac:sac_movimientoshistorial_old AS a
					INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc 
					INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
					INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
					LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
					WHERE a.forma_pago IN (4 , 1) 
					AND b.sucursal NOT IN ('9250','9764','9251') 
					AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
					AND c.numcategoria = '07' 
					AND b.cancelad <> 'S' 
					AND a.status_cancelado <> 'S'
					AND a.numconvenio IN ('004','006','007','008','009') 
					AND a.referencia1 = pCveRemesa; 

						IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
							TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

								LET cCodRet= '00017';
								LET cRetorno3 = 'No se encontro informacion del cliente';
								RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
						END IF; 	
					RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
				ELSE 
					IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial_old AS a INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN

						SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
						INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
						FROM bdisac:sac_movimientoshistorial_old AS a
						INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc 
						INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
						INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
						LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
						WHERE a.forma_pago IN (4 , 1) 
						AND b.sucursal NOT IN ('9250','9764','9251') 
						AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
						AND c.numcategoria = '07' 
						AND b.cancelad <> 'S' 
						AND a.status_cancelado <> 'S'
						AND a.numconvenio IN ('004','006','007','008','009') 
						AND a.referencia1 = pCveRemesa; 

							IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
								TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

									LET cCodRet= '00017';
									LET cRetorno3 = 'No se encontro informacion del cliente';
									RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
							END IF; 	
						RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
					ELSE 	
						LET cCodRet= '00018';
						LET cRetorno3 = 'No se encontro informacion relacionada';
						RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
					END IF;
				END IF;	
			END IF;
		END IF; 												
	END
END PROCEDURE
DOCUMENT 'AUTOR: FG ',
'FECHA: 29/07/2024',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃÂ³n para grid de datos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogocajageneral(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING 	CHAR(5) AS codret,
					CHAR(4) AS cIdProvCaja,
            		CHAR(30) AS cDescCaja;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdProvCaja CHAR(4);
    DEFINE cDescCaja CHAR(30);
	DEFINE cPlazaCaja CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdProvCaja = '';
	LET cDescCaja = '';
	LET cPlazaCaja = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocajageneral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;
		
		--SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		
		-- COMBOBOX CAJA GENERAL 
		IF pTipo = '1' THEN --Por codigo
		
			FOREACH		
				SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor, descripcion, plaza 
				INTO cIdProvCaja, cDescCaja, cPlazaCaja FROM bdisuc:'informix'.ss_proveedores ORDER BY descripcion
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		ELIF pTipo = '2' THEN --Por descripcion
		
			FOREACH	 
				SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor, descripcion, plaza
				INTO cIdProvCaja, cDescCaja, cPlazaCaja FROM bdisuc:'informix'.ss_proveedores ORDER BY descripcion
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		END IF;

		IF pRegistros = 0 AND iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, cIdProvCaja, UPPER(cDescCaja);

		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja);
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, cIdProvCaja, UPPER(cDescCaja);
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ¯Â¿Â½n Amador',
'FECHA: 07/01/2015',
'DESCRIPCION: SPL, que hace la consulta para el llenado del combobox caja general, Monitor de Operaciones Caja General',
'AUTOR: Jose Antonio Ramirez Franco',
'FECHA MODIFICACION: 17/07/2023',
'DESCRIPCION: Se aÃÂ±adio paginado para cada una de las opciones del SP',
'AUTOR: Veronica Sanchez Tlacomulco TASF',
'FECHA MODIFICACION: 28/08/2025',
'DESCRIPCION: Se realizo un mantenimiento para aplicar de forma correcta el tratamiento del paginado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cargacod41_ccep(pUsuario CHAR(8), pIdFuncion CHAR(10),pnombrearchivo CHAR(30), pRutaArchivo CHAR(60), pDireccionMac CHAR(15))
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS bBanDetalle,
				  DECIMAL(20,2) AS	importeTotal; 
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE cNumSecuencia CHAR(7); 
	DEFINE cCodOperacion  CHAR(2);
	DEFINE cFechatrasnfer  CHAR(8);
	DEFINE cBancoCedente  CHAR(3);
	DEFINE cBancoLibrado  CHAR(3);
	DEFINE cImporte  CHAR(15);
	DEFINE cLoteEntrada  CHAR(7);
	DEFINE cSecEntrada  CHAR(4);
	DEFINE cLoteSAlida  CHAR(7);
	DEFINE cSecSalida  CHAR(4);
	DEFINE cTransaccion  CHAR(2);
	DEFINE cChqCompensacion CHAR(3);
	DEFINE cCuentaReferencia CHAR(13);
	DEFINE cNumCheque CHAR(10);
	DEFINE cChqDigVerInter CHAR(1);
	DEFINE cChqDigVerPre CHAR(1);
	DEFINE cChqCodSeguridad CHAR(3);
	DEFINE cUbicFis CHAR(8);
	DEFINE cTruncado CHAR(1);
	DEFINE cMotivoDevol CHAR(2);
	DEFINE cFechaInicial CHAR(8);
	DEFINE cPlazaIntercam CHAR(2);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(18);
	DEFINE cTipoCuentaDep CHAR(2);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cNombreCte CHAR(40);
	DEFINE cCtaAlertamiento CHAR(2);
	DEFINE cFolioSeguro CHAR(12);
	DEFINE cUsoFuturo CHAR(120);	
	DEFINE dImporte DECIMAL(16,2);
	DEFINE dImporte2 DECIMAL(16,2);
	DEFINE cMonto CHAR(12);
	DEFINE cCents CHAR(2);
	DEFINE mImporte CHAR(15);
	DEFINE importeTotal DECIMAL(20,2);	
	DEFINE cDescbancoLibrado CHAR(30);
	DEFINE cMotivoDevolucion CHAR(30);
	DEFINE cObservaciones CHAR(50);
	DEFINE bBanderaError CHAR(1);
	DEFINE cMiBanco CHAR(4);
	DEFINE cprocesar CHAR(2);
	DEFINE cFechaformat CHAR(8);
	DEFINE cValidaPresentado CHAR(50);
	DEFINE cFechaDevol CHAR(10);
	DEFINE cFechaHoy CHAR(10);
	DEFINE iNoPresentado INTEGER;
	DEFINE cValidaProceso CHAR(30);
	DEFINE bBanDet CHAR(1);
	DEFINE ven_transacc SMALLINT;
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cSQL CHAR(250);
	DEFINE iNoProcesado INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE cPathdbaccess CHAR(20);
	DEFINE cMotivoDevCompleto CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET cNumSecuencia = '';
	LET cCodOperacion  = '';
	LET cFechatrasnfer  = '';
	LET cBancoCedente  = '';
	LET cBancoLibrado  = '';
	LET cImporte  = '';
	LET cLoteEntrada  = '';
	LET cSecEntrada  = '';
	LET cLoteSAlida  = '';
	LET cSecSalida  = '';
	LET cTransaccion  = '';
	LET cChqCompensacion = '';
	LET cCuentaReferencia = '';
	LET cNumCheque = '';
	LET cChqDigVerInter = '';
	LET cChqDigVerPre = '';
	LET cChqCodSeguridad = '';
	LET cUbicFis = '';
	LET cTruncado = '';
	LET cMotivoDevol = '';
	LET cFechaInicial = '';
	LET cPlazaIntercam = '';
	LET cRfcCte = '';
	LET cCurpCte = '';
	LET cTipoCuentaDep = '';
	LET cCuentaDeposito = '';
	LET cNombreCte = '';
	LET cCtaAlertamiento = '';
	LET cFolioSeguro = '';
	LET cUsoFuturo = '';
	LET dImporte= 0.00;
	LET dImporte2= 0.00;
	LET cMonto = '';
	LET cCents = '';
	LET mImporte = '';
	LET importeTotal = 0.00;
	LET cDescbancoLibrado = '';
	LET cMotivoDevolucion = '';
	LET cObservaciones = '';
	LET bBanderaError = 'f';
	LET cMiBanco = '';
	LET cprocesar = '';
	LET cFechaformat = '';
	LET cValidaPresentado = '';
	LET cFechaDevol = '';
	LET cFechaHoy ='';
	LET iNoPresentado = 0;
	LET cValidaProceso = '';
	LET bBanDet = '';
	LET ven_transacc = 0;
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';	
	LET cSQL = '';
	LET iNoProcesado = '';
	LET bInTransaction = 'f';
	LET cPathdbaccess = '/ifxsif01/bin/';
	LET cMotivoDevCompleto = '';
	
	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				Let cCodret = cSqlerr;      
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;			
				END IF;
			   RETURN cCodRet,bBanDet,importeTotal; 
			END IF;
		END EXCEPTION;		
		ON EXCEPTION IN (-535,-255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cargacod41_ccep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pnombrearchivo = '' OR pRutaArchivo = '' OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,bBanDet,importeTotal; 
		END IF;
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,bBanDet,importeTotal; 
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			--- CREAR LA TABLA DE TEMPORAL
			DELETE FROM bdicnweb:"informix".ccep_generacioncod41_tmp;
			
			DELETE FROM bdicnweb:"informix".ccep_procesacod41detalle_tmp;																	
			
			LET cSQL = '';
			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
			LET cSQL = 'echo "SET ISOLATION TO DIRTY READ; LOAD FROM '  ||trim(pRutaArchivo) || pnombrearchivo || ' INSERT INTO bdicnweb:"informix".ccep_generacioncod41_tmp(linea)" > '|| trim(pRutaArchivo) || 'Temporal.sql';
			SYSTEM cSQL;

			LET cSQL = '';
			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
			Let cSQL = TRIM(cPathdbaccess)||'dbaccess bdicnweb ' ||trim(pRutaArchivo)|| 'Temporal.sql'; --Se activa para desarrollo 
			COMMIT WORK;
			SYSTEM cSQL;
			BEGIN WORK;
			
			-- fecha habil actual
			SELECT fecha_hoy INTO cFechaHoy FROM bdicheq:sc_fechas WHERE empresa = cEmpresa;
			
			--03/04/2016 calcula fecha de devolucion habilm ant
			EXECUTE PROCEDURE bditef:cal_habil_ant(cFechaHoy) INTO cCodRetsp, cFechaDevol;
			LET iCodRetSp = cCodRetSp::INTEGER;
	
			IF  iCodRetSp <> '000' THEN													  
				ROLLBACK WORK;
				LET ven_transacc = 0;
				let cCodret = '666';
				RETURN cCodRet,bBanDet,importeTotal;
			END IF;
			
		COMMIT WORK;
		
		BEGIN WORK;
			--consulta banco propietario
			SELECT valor INTO cMiBanco FROM bdinteg:si_param WHERE empresa = cEmpresa AND cod_param = '5';
			
			FOREACH SELECT linea INTO cRenglon FROM bdicnweb:"informix".ccep_generacioncod41_tmp ORDER BY(id_serial)
				IF SUBSTR(cRenglon,1,2) = "02" THEN
					LET cNumSecuencia = SUBSTR(cRenglon,3,7);
					LET cCodOperacion = SUBSTR(cRenglon,10,2);
					LET cFechatrasnfer =SUBSTR(cRenglon,12,8); 
					LET cBancoCedente = SUBSTR(cRenglon,20,3);
					LET cBancoLibrado = SUBSTR(cRenglon,23,3);
					LET cImporte = SUBSTR(cRenglon,26,15);
					LET cLoteEntrada = SUBSTR(cRenglon,41,7);
					LET cSecEntrada = SUBSTR(cRenglon,48,4);
					LET cLoteSAlida = SUBSTR(cRenglon,52,7);
					LET cSecSalida = SUBSTR(cRenglon,59,4);
					LET cTransaccion = SUBSTR(cRenglon,63,2);
					LET cChqCompensacion = SUBSTR(cRenglon,65,3);
					LET cCuentaReferencia = SUBSTR(cRenglon,68,13);
					LET cNumCheque = SUBSTR(cRenglon,81,10);
					LET cChqDigVerInter = SUBSTR(cRenglon,91,1);
					LET cChqDigVerPre = SUBSTR(cRenglon,92,1);
					LET cChqCodSeguridad = SUBSTR(cRenglon,93,3);
					LET cUbicFis = SUBSTR(cRenglon,96,8);
					LET cTruncado = SUBSTR(cRenglon,104,1);
					LET cMotivoDevol = SUBSTR(cRenglon,105,2);
					LET cFechaInicial = SUBSTR(cRenglon,107,8);
					LET cPlazaIntercam = SUBSTR(cRenglon,115,2);
					LET cRfcCte = SUBSTR(cRenglon,117,13);
					LET cCurpCte = SUBSTR(cRenglon,130,18);
					LET cTipoCuentaDep = SUBSTR(cRenglon,148,2);
					LET cCuentaDeposito = SUBSTR(cRenglon,150,20);
					LET cNombreCte = SUBSTR(cRenglon,170,40);
					LEt cCtaAlertamiento = SUBSTR(cRenglon,210,2);
					LET cFolioSeguro = SUBSTR(cRenglon,212,12);
					LET cUsoFuturo = SUBSTR(cRenglon,224,120);
					LET mImporte = TO_CHAR(cImporte);
					LET mimporte = substr(mImporte, 1, 13) || '.' || substr(mImporte, 14, 2) ;
					LET dImporte = substr(cImporte, 1, 13) :: DECIMAL(16,2);
					LET dImporte2 = ('0.' || substr(cImporte, 14, 2)):: DECIMAL(16,2);
					LET dImporte = dImporte + dImporte2;
					LET importeTotal = importeTotal + dImporte;
					--obtiene descricion de banco
					LET cDescbancoLibrado = 'No Existe en el catalogo';						
					SELECT descripcion INTO cDescbancoLibrado FROM bdinteg:si_bancos WHERE banco = cBancoLibrado;
					
					LET cCuentaDeposito = LTRIM(cCuentaDeposito,'0');
					
					--obtiene motivo de devolucion
					LET cMotivoDevolucion = 'No Existe en el catalogo';
					SELECT descripcion INTO cMotivoDevolucion FROM bdinteg:si_coddevcam WHERE codigo = cMotivoDevol;
					LET cMotivoDevCompleto = TRIM(cMotivoDevol)||' '||TRIM(cMotivoDevolucion);
					LET cprocesar = 'f';
					
					--valida si existe alguna observacion a gregar
					LET cObservaciones = '';
					LET bBanderaError = 'f';
					
					IF cCodOperacion <> '41'THEN
						LET cObservaciones = 'Registro no en fase de devolucion';
						LET bBanderaError = 't';
					END IF;
					
					-- valida banco
					IF 	bBanderaError= 'f' THEN
						IF cBancoCedente <> cMiBanco THEN
								LET cObservaciones = 'Documento no compensado por el banco';
								LET bBanderaError = 't';
						END IF;
					END IF;
					
					--03/07/2016 validacion de fecha habil
					IF 	bBanderaError= 'f' THEN							
						LET cFechaformat = SUBSTR(cFechaDevol, 7, 4) || SUBSTR(cFechaDevol, 1, 2) || SUBSTR(cFechaDevol, 4, 2);
						IF cFechaInicial <> cFechaformat THEN
								LET cObservaciones = 'La fecha de presentacion inicial no corresponde';
								LET bBanderaError = 't';
						END IF;
					END IF;
					
					--validacion si el cheque ya fue presentado
					IF 	bBanderaError= 'f' THEN	
						LET cValidaPresentado = 'Este documento no esta registrado como presentado';
						
						SELECT COUNT(*) INTO iNoPresentado FROM bditef:cce_detalle	
						WHERE bco_receptor = cBancoLibrado AND
						LPAD(TRIM(num_cuenta) , 13, '0') = cCuentaReferencia AND
						num_cheque = cNumCheque AND
						importe = dImporte AND
						fecha_presini = cFechaInicial AND
						cod_operacion = '40';
						
						IF iNoPresentado <> 0 THEN
							LET cValidaPresentado = '';
						ELSE
							LET bBanderaError = 't';
						END IF;
					
						LET cObservaciones = cValidaPresentado;
						END IF;
					
					--valida si el cheque ya fue procesado
					IF 	bBanderaError= 'f' THEN	
						LET cValidaProceso = '';
						
						SELECT COUNT(*) INTO iNoProcesado from bditef:cce_cheques_dev
						where cvebanco = cBancoLibrado AND
						LPAD(TRIM(numcuenta) , 13, 0) = cCuentaReferencia AND
						LPAD(TRIM(numcheque) , 10, 0) = cNumCheque AND
						fechapresenta = cFechaDevol;
						
						IF iNoProcesado <> 0 THEN
							LET cValidaProceso = 'este documento ya fue procesado';
							LET bBanderaError = 't';
						END IF;
						
						LET cObservaciones = cValidaProceso;
					END IF;
					
					IF 	bBanderaError= 'f' THEN	
						LET cprocesar = 't'; --SI
					END IF;
					
					INSERT INTO bdicnweb:"informix".ccep_procesacod41detalle_tmp
					(usuario,direccionMac,bancoLibrado,descbancoLibrado,importe,cuentaReferencia,numCheque,CuentaDeposito,observaciones,motivoDevolucion,procesar)
					VALUES
					(pUsuario,pDireccionMac,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevCompleto,cprocesar);
					
				END IF;
			END FOREACH;	
			
		COMMIT WORK;
		
		LET bBanDet  = 't';
		LET ven_transacc = 0;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet,bBanDet,importeTotal; 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 07/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos',
'DESCRIPCION: Carga datos del archivo de devoluciones a tablas temporales  y se valida la informacion.',
'AUTOR: JOSÃ ANTONIO RAMIREZ FRANCO',
'FECHA MODIFICACION: 06/05/2024',
'MODIFICACION: Se ajusta el importe para los centavos y se aÃ±aden los ceros a las numeros de cuentas.',
'AUTOR: VERONICA SANCHEZ',
'FECHA MODIFICACION: 26/08/2025',
'MODIFICACION: Se ajusta SPS para contatenar el cdigo y descripcion de la devolucion, variable cMotivoDevCompleto.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_valida_correo_ob(pRFC CHAR(13) 
                                    ,pCorreoElec CHAR(100))
RETURNING CHAR(5) AS vcodret1,
		  CHAR(100) AS vMensaje;
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vExisteCorreo    SMALLINT;
	DEFINE vExisteCteCorreo INTEGER;
	DEFINE vCorreoNoValido  INTEGER;
	DEFINE vNumCte			CHAR(20);
	DEFINE vMensaje         CHAR(50);
	DEFINE vRfc		        CHAR(50);
    
    LET vcodret1 = '00000';
    LET vcodret2 = '00000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte    = 0;
    LET vExisteCorreo = 0;
	LET vExisteCteCorreo = 0;
    LET vCorreoNoValido  = 0;
	LET vNumCte = '0';
    LET vMensaje = 'SE EJECUTO CORRECTAMENTE';
    LET vRfc = '';
	
	BEGIN
		
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET sql_err, isam_err, desc_err
			--SET DEBUG FILE TO "/tmp/IFR/sp_valida_correo_ob.out";
			--TRACE ON;
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcodret2 = isam_err;
				LET vcodret3 = desc_err;
				LET vMensaje = 'ERROR AL EJECUTAR EL SP';
				RETURN vcodret1, vMensaje;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/IFR/sp_valida_correo_ob.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- // VALIDA PARAMETROS DE ENTRADA
		IF (pRFC is null OR pRFC = '') OR
		   (pCorreoElec is null OR pCorreoElec = '') THEN
			LET vcodret1 = '00003';
			LET vMensaje = 'FALTAN PARÃMETROS DE ENTRADA.';
			RETURN vcodret1, vMensaje;
		END IF;
		
		-- // VALIDA QUE EL CORREO POR INSERTAR NO SE ENCUENTRE EN LA LISTA DE CORREOS NO VALIDOS
		SELECT COUNT(id)
		  INTO vCorreoNoValido
		  FROM bdinteg:"informix".si_cat_correos_novalidos
		 WHERE correo = TRIM(pCorreoElec);
		
		IF vCorreoNoValido > 0 THEN
			LET vcodret1 = '00120';
			LET vMensaje = 'EL CORREO SE ENCUENTRA EN LA LISTA DE CORREOS NO VÃLIDOS';
			RETURN vcodret1, vMensaje;
		END IF;
		
		-- // VALIDA SI EL CORREO YA ESTA REGISTRADO		
		SELECT COUNT(*)
		  INTO vExisteCorreo
		  FROM bdinteg:"informix".si_correos
		 WHERE UPPER(correo_elec) = UPPER(pCorreoElec)
		   AND status_correo = 'A';
		   
		IF vExisteCorreo > 1 THEN
			LET vcodret1 = '00999';
			LET vMensaje = 'EL CORREO YA EXISTE, VERIFIQUE.';
			RETURN vcodret1, vMensaje;
		END IF;
		
		IF vExisteCorreo = 0 THEN
			RETURN vcodret1, vMensaje;
		END IF;
		
		IF vExisteCorreo = 1 THEN
			SELECT numcte
			INTO vNumCte
			FROM bdinteg:"informix".si_correos
			WHERE UPPER(correo_elec) = UPPER(pCorreoElec)
				AND status_correo = 'A';
		
			SELECT rfc
			INTO vRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = vNumCte;
			
			IF vRfc != pRFC THEN
				LET vcodret1 = '00999';
				LET vMensaje = 'EL CORREO YA EXISTE, VERIFIQUE.';
				RETURN vcodret1, vMensaje;
			END IF;
		END IF;
   END;

   RETURN vcodret1, vMensaje;
END PROCEDURE;