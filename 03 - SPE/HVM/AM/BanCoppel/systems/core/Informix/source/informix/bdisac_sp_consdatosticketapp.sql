CREATE PROCEDURE "informix".sp_consdatosticketapp (pFoli_suc CHAR(20))
RETURNING 
CHAR(6)  AS  Cod_Ret,
CHAR(16) AS Num_Ref,
CHAR(40) AS Nombre1,
CHAR(40) AS Nombre2,
CHAR(40) AS Apell_pat,
CHAR(40) AS Apell_mat,
CHAR(3)  AS  Ident,
CHAR(20) AS Num_ident,
CHAR(1)  AS  tp_pago;

--DECLARACIÓN DE VARIABLES
DEFINE cCod_Ret		CHAR(6) ;
DEFINE cNum_Ref     CHAR(16);
DEFINE cNombre1     CHAR(40);
DEFINE cNombre2     CHAR(40);
DEFINE cApell_pat   CHAR(40);
DEFINE cApell_mat   CHAR(40);
DEFINE cIdent       CHAR(3) ;
DEFINE cNum_ident   CHAR(20);
DEFINE ctp_pago     CHAR(1) ;
DEFINE cStatus     CHAR(1) ;
DEFINE iSqlErr     INTEGER;

--INICIALIZA VARIABLES
LET cCod_Ret	='000000';
LET cNum_Ref    ='';
LET cNombre1    ='';
LET cNombre2    ='';
LET cApell_pat  ='';
LET cApell_mat  ='';
LET cIdent      ='';
LET cNum_ident  ='';
LET ctp_pago    ='';
LET cStatus    ='';
LET iSqlErr     =0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_consdatosticketapp.out";
--TRACE ON; 
	BEGIN
	-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCod_Ret = iSqlErr;
				RETURN cCod_Ret,TRIM(cNum_Ref),TRIM(cNombre1),TRIM(cNombre2),TRIM(cApell_pat),TRIM(cApell_mat),TRIM(cIdent),TRIM(cNum_ident),TRIM(ctp_pago);
			END IF
		END EXCEPTION;

		
		IF NVL(pFoli_suc,'')='' THEN
			LET cCod_Ret = '000001';
			RETURN cCod_Ret,TRIM(cNum_Ref),TRIM(cNombre1),TRIM(cNombre2),TRIM(cApell_pat),TRIM(cApell_mat),TRIM(cIdent),TRIM(cNum_ident),TRIM(ctp_pago);
		END IF
		
		SELECT  TRIM(payi.unirefnum),TRIM(payi.firstname),TRIM(payi.middlename),TRIM(payi.lastname),TRIM(payi.mommaidenname),TRIM(payi.typecodeci),TRIM(payi.numberci),mov.forma_pago,mov.status_cancelado
		INTO cNum_Ref,cNombre1,cNombre2,cApell_pat,cApell_mat,cIdent,cNum_ident,ctp_pago,cStatus
		FROM "informix".sac_app_payi as payi,
			"informix".sac_movimientos as mov
		WHERE mov.folio_suc = pFoli_suc
		AND payi.unirefnum = mov.referencia1
		AND payi.refnum = mov.folio_suc;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCod_Ret = '000002';
		ELIF cStatus = 'S' THEN
			LET cCod_Ret = '000003';
			LET cNum_Ref    ='';
			LET cNombre1    ='';
			LET cNombre2    ='';
			LET cApell_pat  ='';
			LET cApell_mat  ='';
			LET cIdent      ='';
			LET cNum_ident  ='';
			LET ctp_pago    ='';
		END IF
		
		RETURN cCod_Ret,NVL(TRIM(cNum_Ref),''),NVL(TRIM(cNombre1),''),NVL(TRIM(cNombre2),''),NVL(TRIM(cApell_pat),''),NVL(TRIM(cApell_mat),''),NVL(TRIM(cIdent),''),NVL(TRIM(cNum_ident),''),NVL(TRIM(ctp_pago),'');
		
	END
END PROCEDURE
DOCUMENT
'AUTOR:95358919 - Mario Olivo',
'FOLIO:230142-1542',
'DESCRIPCION: Su funcionalidad es para obtener los datos para la reimpresión del ticket',
'FECHA:2016/04/18',
'SOLICITA:Leonardo Hernandez',
'RQM: APPRIZA.DOC',
'VERSION:20160418.1050',
'BD:bdisac.';

CREATE PROCEDURE "informix".sp_dinya_pagaenvios
	(pNumeroControl CHAR(12),
	 pSucursal CHAR(4),
	 pFolioSuc CHAR(16),
	 pIdConvenio CHAR(5))

RETURNING  CHAR(5),CHAR(5), CHAR(16);

DEFINE cCodRet 			 		CHAR(5);
DEFINE iSqlErr			 		INTEGER;
DEFINE cCuentaPrestadora 		CHAR(20);
--DEFINE pImporte					MONEY (16,2); 	-- DSB-TH-20/06/2016- Variable sin utilizar
DEFINE cTransaccCargoPago 		CHAR(4);
DEFINE ctranret					CHAR(4);
DEFINE dfechoy					DATE;
DEFINE msdodisp					MONEY (14,2);
DEFINE mmontoret				MONEY (14,2);
DEFINE cEjecutivo				CHAR(11);
DEFINE mImportePago				MONEY(16,2);
DEFINE dFechaHoy				DATE;
DEFINE cTransaccSuc				CHAR(4);
DEFINE iCargo                   INTEGER;
DEFINE cCodRet2					CHAR(5);
DEFINE cMensaje					CHAR(200);
DEFINE isam_error				INTEGER;
--	2013.11.01 FRG-i
DEFINE iIsamErr    				INTEGER;
DEFINE cInfoErr    				CHAR(100);

DEFINE CdRetVerSis 				CHAR (5);
DEFINE IndCrreCred 				CHAR (1);
DEFINE IndDispCred 				CHAR (1);
DEFINE IndCrreChqs 				CHAR (1);
DEFINE IndDispChqs 				CHAR (1);
DEFINE IndCrreInvs 				CHAR (1);
DEFINE IndDispInvs 				CHAR (1);
DEFINE IndCrreSrvs 				CHAR (1);
--	2013.11.01 FRG-f

	--SET DEBUG FILE TO "/home/sysifx/Trinidad/homo_APP/sp_dinya_pagaenvios.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,isam_error,cMensaje
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			If iCargo = 1 THEN
				CALL  bdicheq: "informix".reversion('001',pSucursal,cEjecutivo,pFolioSuc,'A') RETURNING cCodRet2;
				INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (iSqlErr,isam_error,cMensaje,'sp_dinya_pagaenvios',dfechoy,CURRENT );
			END IF;
			RETURN '00000',cCodRet, pFolioSuc;
		END IF;
	END EXCEPTION;

	LET cCodRet 			   = '00000';
	LET iSqlErr			 	   = 0;
	LET cCuentaPrestadora 	   = '';
	LET cTransaccCargoPago	   = '';
	LET ctranret			   = '';
	LET dfechoy				   = '';
	LET msdodisp			   = '';
	LET mmontoret			   = '';
	LET mImportePago		   = '';
	LET dFechaHoy			   = '';
	LET cEjecutivo = SUBSTR(pFolioSuc,1,8);
	LET cTransaccSuc		   = '';
	LET iCargo                 = 0;
	LET cCodRet2			   = '';
	LET cMensaje			   = '';
	LET isam_error			   = '';

--	2013.11.01 FRG-i
     LET iIsamErr    		   = 0;
	 LET cInfoErr    		   = '';

	 LET CdRetVerSis		   = '';
	 LET IndCrreCred 		   = '';
	 LET IndDispCred 	       = '';
	 LET IndCrreChqs 	       = '';
	 LET IndDispChqs 	       = '';
	 LET IndCrreInvs 	       = '';
	 LET IndDispInvs 	       = '';
	 LET IndCrreSrvs 	       = '';
--	2013.11.01 FRG-f

	SET ISOLATION TO CURSOR STABILITY;
	SET LOCK MODE TO WAIT 10;

--	2013.11.01 FRG-i
	-- Validación Disponibilidad Servicio:
	EXECUTE FUNCTION bdinteg:  "informix".verifica_sistemas() -- Se validan cierres de los sistemas antes de iniciar proceso de PGPROG:
	INTO CdRetVerSis, IndCrreCred, IndDispCred, IndCrreChqs, IndDispChqs, IndCrreInvs, IndDispInvs, IndCrreSrvs;
		
		if IndCrreSrvs <> '1'
			then
				LET cCodRet = '00060';
				LET iSqlErr = 0;
				LET iIsamErr = 0;
				LET cInfoErr = 'Sistema Servicios No Disponible.';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_dinya_pagaenvios");
--				EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
				RETURN '00000',cCodRet, pFolioSuc;
			else
					if IndCrreChqs <> '1'
						then
							LET cCodRet = '00061';
							LET iSqlErr = 0;
							LET iIsamErr = 0;
							LET cInfoErr = 'Sistema Cheques No Disponible.';
							EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_dinya_pagaenvios");
--							EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
							RETURN '00000',cCodRet, pFolioSuc;
						else
							if IndDispChqs <> '1'
								then
									LET cCodRet = '00062';
									LET iSqlErr = 0;
									LET iIsamErr = 0;
									LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
									EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_dinya_pagaenvios");
--									EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
									RETURN '00000',cCodRet, pFolioSuc;
								else
							end if;
					end if;
		end if;
--	2013.11.01 FRG-f

	IF NOT EXISTS (SELECT {+INDEX (bdisac: "informix".sac_enviosdineroya idxsac_envdinya13_1)} no_control FROM bdisac: "informix".sac_enviosdineroya WHERE no_control = pNumeroControl AND estatus = '01') THEN
		LET cCodRet = '00002';
		RETURN '00000',cCodRet, pFolioSuc;
	END IF;

	SELECT {+INDEX (bdisac:  "informix".sac_enviosdineroya idxsac_envdinya13_1)} importe_pago
	INTO mImportePago
	FROM Bdisac: "informix".sac_enviosdineroya
	WHERE no_control = pNumeroControl and estatus is not null;

	--Obtiene parametros
	SELECT valor INTO cCuentaPrestadora
	FROM Bdisac: "informix".sac_param
	WHERE cod_param='75';

	IF pIdConvenio = '07002' THEN

		SELECT valor INTO cTransaccCargoPago
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='41407002';

		SELECT valor INTO cTransaccSuc
		FROM Bdisac: "informix".sac_param
		WHERE cod_param = '807002';

		let pNumeroControl = pNumeroControl;
		
		--Cargo a la cuenta del cte por el monto cargo.
		CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoPago, cTransaccSuc, pFolioSuc,
		cCuentaPrestadora, 0, mImportePago,"01", pNumeroControl, '', cEjecutivo)
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
			LET cCodRet = '00001'; --Error en el cargo para el pago del envio
			RETURN '00000',cCodRet,pFolioSuc;
		ELSE
			--Bandera para reversar en caso de que el procedimiento no se termine exitosamente
			LET iCargo = 1;
		END IF;

		SELECT fecha_hoy INTO dFechaHoy FROM sac_fechas;

		CALL bdisac: "informix".sp_grabapagoservicio (pSucursal,'07','002', pNumeroControl,
		SUBSTR(LPAD(pNumeroControl,12,'0'),12,1),'1', mImportePago,'0.00','0.00','0.00','0.00',
		cCuentaPrestadora,cEjecutivo,pFolioSuc, cTransaccSuc,dFechaHoy)
		RETURNING cCodRet;

		IF cCodRet <> '00000' THEN
			CALL  bdicheq: "informix".reversion('001',pSucursal,cEjecutivo,pFolioSuc,'A') RETURNING cCodRet2;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cCodRet,isam_error,cMensaje,'sp_dinya_pagaenvios',dfechoy,CURRENT );
			RETURN '00000', cCodRet,pFolioSuc;
		END IF;

		UPDATE {+INDEX (bdisac: "informix".sac_enviosdineroya idxsac_envdinya13_1)} bdisac: "informix".sac_enviosdineroya SET estatus = '04',suc_cobropago = pSucursal, fecha_pago = dFechaHoy,
				hora_pago = CURRENT HOUR TO SECOND, usua_pago = cEjecutivo WHERE no_control = pNumeroControl and estatus is not null;


	ELIF pIdConvenio = '07003' THEN

		SELECT valor INTO cTransaccCargoPago
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='41507003';

		SELECT valor INTO cTransaccSuc
		FROM Bdisac: "informix".sac_param
		WHERE cod_param = '807003';

		--Cargo a la cuenta del cte por el monto cargo.
		CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoPago, cTransaccSuc, pFolioSuc,
		cCuentaPrestadora, 0, mImportePago,"01", pNumeroControl, '', cEjecutivo)
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
			LET cCodRet = '00001'; --Error en el cargo para el pago del envio
			RETURN '00000', cCodRet,pFolioSuc;
		ELSE
			LET iCargo = 1;
		END IF;

		SELECT fecha_hoy INTO dFechaHoy FROM sac_fechas;

		CALL bdisac: "informix".sp_grabapagoservicio (pSucursal,'07','003', pNumeroControl,
		SUBSTR(LPAD(pNumeroControl,12,'0'),12,1),'1', mImportePago,'0.00','0.00','0.00','0.00',
		cCuentaPrestadora,cEjecutivo,pFolioSuc, cTransaccSuc,dFechaHoy)
		RETURNING cCodRet;

		IF cCodRet <> '00000' THEN
			CALL  bdicheq: "informix".reversion('001',pSucursal,cEjecutivo,pFolioSuc,'A') RETURNING cCodRet2;
			INSERT INTO bdisac: "informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cCodRet,isam_error,cMensaje,'sp_dinya_pagaenvios',dfechoy,CURRENT );
			RETURN '00000', cCodRet,pFolioSuc;
		END IF;

		UPDATE {+INDEX (bdisac: "informix".sac_enviosdineroya idxsac_envdinya13_1)}  "informix".sac_enviosdineroya SET estatus = '02',suc_cance = pSucursal, fecha_cance = dFechaHoy,
			   hora_cance = CURRENT HOUR TO SECOND, usua_cance = cEjecutivo WHERE no_control = pNumeroControl and estatus is not null;

	END IF;

	RETURN '00000', cCodRet,pFolioSuc;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: GENERA LA TRANSACCION DE PAGO DE UN ENVIO ACTIVO O CANCELACION Y CAMBIA EL ESTATUS DEL ENVIO A PAGADO O CANCELADO',
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'FECHA: DICIEMBRE 2009',
'VERSION: 20091203.1153',
'AUTOR : FRG',
'DESCRIPCION: Se agrega validación de cierre procesos centrales por Proy. Indep. Sistemas',
'FECHA : Nov. 2013',
'VERSION: 20131105',
'BD: BDISAC',
'AUTOR : Viridiana PR',
'DESCRIPCION: se envia el valor del numero de control pNumeroControl al procedimiento cargo_ref en la parte del parámetro pReferencia',
'FECHA : MAYO 2015',
'VERSION: 20150528',
'BD    : bdisac',
'MODIFICACION',
'MODIFICO: Trinidad Hernández',
'folio: 73',
'DESCRIPCION: "Homologación de caja appriza con RQM 10-239-5 Y RQM 10-495 y cambio BTS_parametro sucursal"; Homologación con Vers. Prod., Pago de remesas Appriza',
'FECHA : 20/06/2016',
'VERSION: 20160620.1019',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_consflag_respuesta (pMensaje CHAR(5),pCod_interact CHAR(5),pCod_WS CHAR(4),pCod_detail CHAR(4))
RETURNING CHAR(6) AS Cod_ret, CHAR(1) AS flag

--	DECLARA VARIABLES
DEFINE cCod_ret CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE cFlag CHAR(1);
DEFINE cFlagint CHAR(1);
DEFINE cFlagrev CHAR(1);
--	INICIALIZA VARIABLES
LET iSqlErr = 0;
LET cCod_ret = '000000';
LET cFlag = '0';
LET cFlagint = '0';
LET cFlagrev = '0';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_consflag_respuesta.out";
--TRACE ON; 
BEGIN
-- ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		LET cCod_ret = iSqlErr;
		LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	END EXCEPTION;

	-- VALIDACIÓN DE PARÁMETROS
	
	IF NVL(pMensaje,'') = ''THEN
			LET cCod_ret = '000001';
			LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	END IF
	
	IF ( NVL(pCod_interact,'') = ''  OR pCod_interact::INT= 0) AND NVL(pCod_WS,'') = '' OR NVL(pCod_detail,'') = ''  THEN
		LET cCod_ret = '000000';
		LET cFlag = '1';
		RETURN cCod_ret,cFlag;
	ELIF pCod_interact::INT <> 0 then
		LET cCod_ret = '000002';
		LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	
	END IF
	
	LET pMensaje = UPPER(pMensaje);
	
	SELECT flag_rev,flag_intento
	INTO cFlagint,cFlagrev
	FROM bdisac:"informix".sac_app_cat_mensajesdetail
	WHERE agent_trans_type_code = TRIM(pMensaje)
	AND opcode= TRIM (pCod_WS)
	AND opcode_detail = TRIM (pCod_detail);
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCod_ret = '000003';
		LET cFlag = '1';
		RETURN cCod_ret,cFlag;
	END IF
	
	IF cFlagint::INT = 1 or cFlagrev::INT = 1 THEN
		LET cFlag = '1';
	END IF
	
	RETURN cCod_ret,cFlag;
	
END
END PROCEDURE
DOCUMENT
'AUTOR:95358919 - MARIO OLIVO',
'FOLIO:95',
'DESCRIPCION: el SP regresa el flag ya sea para mandar a reversar o bien intentar el reverso.',
'FECHA:2016/07/26',
'SOLICITA:Leonardo Hernandez',
'RQM: Adendum',
'VERSION:20160726.1752',
'BD:bdisac';

CREATE PROCEDURE "informix".sp_insertaconciliaciontotalporconvenio()
RETURNING
CHAR(5)         AS retorno;

    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
	DEFINE cCodRet              CHAR(5);
	DEFINE vconsmovhis          CHAR(10);
	DEFINE cTranCredPGDF   	    CHAR(5);	
	DEFINE cTranCredPEDOF   	    CHAR(5);	
	DEFINE cTranCredPCP   	    CHAR(5);
    DEFINE cNomConvenio         CHAR(40);	
	DEFINE cConvenio         	CHAR(5);
	DEFINE cConv 		        CHAR(3);
    DEFINE cCateg       	    CHAR(2);
	DEFINE cCuenta_contable     CHAR(30);
	DEFINE cCuenta_cheques      CHAR(30);
	DEFINE iProceso_automatico  INTEGER;
	DEFINE iTransCargoCuenta    INTEGER;
	DEFINE cNumTransaccEfec     CHAR(4);
    DEFINE cNumTransaccEfec_cpl CHAR(4);
	DEFINE cNumCargoClien		CHAR(4);
	DEFINE deImporte_archivo    DECIMAL(16,2);
	DEFINE dFecha_pago          DATE;
	DEFINE mCargoCuenta         MONEY(16,2);
	DEFINE deImporte_conta      DECIMAL(16,2);
	DEFINE cIdSucursal			CHAR(4);
	DEFINE iNumPagos            INTEGER;
	DEFINE mImpComisionConvenio    MONEY(16,2);
	DEFINE mIVAComisionConvenio    MONEY(16,2);
	DEFINE mImpComisionCte         MONEY(16,2);
	DEFINE mIVAComisionCte         MONEY(16,2);
	DEFINE iConfirmacionCentral     INTEGER;
	DEFINE iConfirmacionSucursal    INTEGER;
	DEFINE dFechaTransfer			DATE;
	DEFINE vmax_fechaold            DATE;	
	DEFINE cDescripcionSPJ	 CHAR(100);
	DEFINE cConvenTransfer	CHAR (120);
	DEFINE cConvenTransfer2 CHAR (120);
			
	LET cCodRet  =   "00000";	
	LET cTranCredPGDF       = '';
    LET cTranCredPEDOF      = '';
	LET cTranCredPCP		= '';
	LET cNomConvenio  = "";
	LET cConvenio  = "";
	LET cConv   = "";
    LET cCateg  = "";
	LET cCuenta_contable  = "";
	LET cCuenta_cheques   = "";
	LET iProceso_automatico  = 0;
	LET iTransCargoCuenta = 0;
	LET cNumTransaccEfec  = '';
	LET cNumTransaccEfec_cpl  = '';
	LET cNumCargoClien	  = '';
	LET deImporte_archivo = 0;	
	LET dFecha_pago  = "01-01-1990";	
	LET mCargoCuenta      = 0;
	LET deImporte_conta   = 0;
	LET cIdSucursal           = "";
	LET iNumPagos             = 0;
	LET mImpComisionConvenio = 0;
	LET mIVAComisionConvenio = 0;
	LET mImpComisionCte      = 0;
	LET mIVAComisionCte      = 0;
	LET iConfirmacionCentral  = 0;
	LET iConfirmacionSucursal = 0;
	LET dFechaTransfer		= '01-01-1990';
	LET vmax_fechaold    = '';	
	LET cDescripcionSPJ	 = 'Inserta totales para reporte de SOC conciliacion total por convenio';	
	LET cConvenTransfer = '';
	LET cConvenTransfer2 = '';

	--SET DEBUG FILE TO  '/informix/yuri/convenios/sp_insertaconciliaciontotalporconvenioyu.out';
	--TRACE ON;
		
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_insertaconciliaciontotalporconvenio");
                RETURN cCodRet;
            END IF;
        END EXCEPTION;	

		SELECT fecha_hoy-1
		INTO dFecha_pago
		FROM bdisac:"informix".sac_fechas
		WHERE empresa = "001";			
		
		SELECT valor INTO vconsmovhis FROM bdicheq:"informix".sc_param WHERE codparam = 'fechcon_movhis' AND  empresa = '001';
		SELECT valor INTO cTranCredPGDF FROM bdisac:"informix".sac_param WHERE cod_param = '87040';
		SELECT valor INTO cTranCredPEDOF FROM bdisac:"informix".sac_param WHERE cod_param = '25';
		
		--INSERTA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_CTC_S', dFecha_pago, '0', 'informix', 'sp_insertaconciliaciontotalporconvenio', cDescripcionSPJ);

		--HOMOLOGACION CLUB DE PROTECCION COPPEL
		SELECT valor INTO cTranCredPCP FROM bdisac:"informix".sac_param WHERE cod_param = 82;
        FOREACH			
            SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
                   NVL(cuenta_prestadora,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), 
                   NVL(trans_cen_efectivo_cliente,''),NVL(trans_cen_efectivo_cliente_cpl,''), NVL(trans_cen_cargo_cliente,'')
              INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable, cCuenta_cheques, 
				   iProceso_automatico, iTransCargoCuenta, cNumTransaccEfec,cNumTransaccEfec_cpl, cNumCargoClien 
              FROM bdisac:"informix".sac_convenios
             WHERE numcategoria || numconvenio <> '08002'
             UNION 
            SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
                   NVL(valor,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), 
                   NVL(trans_cen_efectivo_cliente,''), NVL(trans_cen_efectivo_cliente_cpl,''), NVL(trans_cen_cargo_cliente,'')
              FROM bdisac:"informix".sac_convenios, bdisac:sac_param
             WHERE numcategoria || numconvenio = '08002'
               AND cod_param IN ('30','31','32','33','34')
             ORDER BY nomconvenio	
				
								
				IF cCateg = '10' THEN				
					FOREACH
						SELECT SUM(importe_pago), id_sucursal, COUNT(referencia1), SUM(importe_comision_convenio), SUM(iva_comision_convenio),
							SUM(importe_comision_cte), SUM(iva_comision_cte), SUM(flag_confirmacion_central), SUM(flag_confirmacion_sucursal)
						INTO deImporte_archivo, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
							iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_movimientoshistorial
						WHERE fecha_pago = dFecha_pago-1
						AND numcategoria = cCateg 
						AND numconvenio = cConv			
						AND status_cancelado = 'N'
						AND flag_confirmacion_central = 1
						AND flag_confirmacion_sucursal = 1
						GROUP BY id_sucursal
						ORDER BY id_sucursal	
					
						SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis
						WHERE fech_alt = dFecha_pago-1
						AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec)
						AND cuenta = cCuenta_cheques
						AND usuario = 'systrans';
						
						IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_conciliaciontotalporconvenio where numcategoria=cCateg and numconvenio=cConv and fecha_pago=dFecha_pago-1 and id_sucursal=cIdSucursal) THEN
							INSERT INTO bdisac:"informix".sac_conciliaciontotalporconvenio (retorno, numcategoria, numconvenio, nomconvenio, fecha_pago, importe_archivo, cuenta_cheques, importe_cheq, cuenta_contable, importe_conta, id_sucursal, numpagos, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, flag_confirmacion_central, flag_confirmacion_sucursal)
							VALUES (cCodRet, cCateg, cConv, cNomConvenio, dFecha_pago-1, deImporte_archivo, cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal);									
						END IF;	
					END FOREACH;
				ELSE			
					FOREACH
						--Se calcula el total de los movimientos por sucursal
						SELECT SUM(importe_pago), id_sucursal, COUNT(referencia1), SUM(importe_comision_convenio), SUM(iva_comision_convenio),
							SUM(importe_comision_cte), SUM(iva_comision_cte), SUM(flag_confirmacion_central), SUM(flag_confirmacion_sucursal)
						INTO deImporte_archivo, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
							iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_movimientoshistorial
						WHERE fecha_pago = dFecha_pago
						AND numcategoria = cCateg 
						AND numconvenio = cConv			
						AND status_cancelado = 'N'
						AND flag_confirmacion_central = 1
						AND flag_confirmacion_sucursal = 1
						GROUP BY id_sucursal
						ORDER BY id_sucursal	

						IF cCateg = '08' AND cConv = '002' THEN
							LET deImporte_archivo = 0;
							LET deImporte_archivo = ( SELECT  SUM(importe_pago)
													  FROM bdisac:"informix".sac_movimientoshistorial a, bdisac:sac_edomex_cuentas b
													 WHERE a.fecha_pago = dFecha_pago
													   AND a.numcategoria = cCateg 
													   AND a.numconvenio = cConv			
													   AND a.status_cancelado = 'N'
													   AND a.flag_confirmacion_central = 1 
													   AND a.flag_confirmacion_sucursal = 1
													   AND substr(referencia1,1,6) = prefijo
													   AND cuenta = cCuenta_cheques
													   group by cuenta);                                       
												 
					   END IF;
						--Se calcula el Total de Cheques por sucursal
						--Pago de Remesas
						IF(cConvenio = "07004" OR cConvenio = "07006" OR cConvenio = "07007" OR cConvenio = "07008")THEN
							SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
							FROM bdicheq:"informix".sc_movhis
							WHERE fech_alt = dFecha_pago
							AND cancelad <> 'S' AND transacc IN(cNumCargoClien, cNumTransaccEfec)
							AND cuenta = cCuenta_cheques
							AND sucursal = cIdSucursal;					
						ELSE --Club de Proteccion
							IF cConvenio = "01002" THEN
								SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
								FROM bdicheq:"informix".sc_movhis
								WHERE fech_alt = dFecha_pago
								AND cancelad <> 'S' AND transacc IN (cTranCredPCP, iTransCargoCuenta, cNumTransaccEfec)
								AND cuenta = cCuenta_cheques
								AND sucursal = cIdSucursal;					
							ELSE --GDF
								IF cConvenio = "08001" THEN
									SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' AND transacc IN(cTranCredPGDF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;	
								ELIF cConvenio = "08002" THEN
									SELECT NVL(SUM(monto_tot), 0) 
									INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' 
									AND transacc IN(cTranCredPEDOF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;								
								ELSE --Todos los demas convenios que no sean Orden de Pago y Transfer									
									IF cConvenio NOT IN ("07001" ,"07002", "07003") AND cCateg <> '10' THEN
										SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
										FROM bdicheq:"informix".sc_movhis
										WHERE fech_alt = dFecha_pago
										AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec, cNumTransaccEfec_cpl)
										AND cuenta = cCuenta_cheques
										AND sucursal = cIdSucursal;
									ELSE --Es un Envio, Cobro o Cancelacion de Orden de Pago
										LET mCargoCuenta = 0;
									END IF;								
								END IF;
							END IF;			
						END IF;			

					INSERT INTO bdisac:"informix".sac_conciliaciontotalporconvenio (retorno, numcategoria, numconvenio, nomconvenio, fecha_pago, importe_archivo, cuenta_cheques, importe_cheq, cuenta_contable, importe_conta, id_sucursal, numpagos, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, flag_confirmacion_central, flag_confirmacion_sucursal)
					VALUES (cCodRet, cCateg, cConv, cNomConvenio, dFecha_pago, deImporte_archivo, cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal);									
						
					END FOREACH;			
					--Sumar al total de cheques los que en movimientos tienen algun flag en 0
					FOREACH
						SELECT SUM(importe_pago), id_sucursal, COUNT(referencia1), SUM(importe_comision_convenio), SUM(iva_comision_convenio),
							SUM(importe_comision_cte), SUM(iva_comision_cte), SUM(flag_confirmacion_central), SUM(flag_confirmacion_sucursal)
						INTO deImporte_archivo, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
							iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_movimientoshistorial
						WHERE fecha_pago = dFecha_pago
						AND numcategoria = cCateg AND numconvenio = cConv			
						AND status_cancelado = 'N'
						AND (flag_confirmacion_central = 0
						OR flag_confirmacion_sucursal = 0)
						GROUP BY id_sucursal
						ORDER BY id_sucursal	
						IF(cConvenio = "07004" OR cConvenio = "07006" OR cConvenio = "07007" OR cConvenio = "07008")THEN
							SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
							FROM bdicheq:"informix".sc_movhis
							WHERE fech_alt = dFecha_pago
							AND cancelad <> 'S' AND transacc IN(cNumCargoClien, cNumTransaccEfec)
							AND cuenta = cCuenta_cheques
							AND sucursal = cIdSucursal;					
						ELSE --Club de Proteccion
							IF cConvenio = "01002" THEN
								SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
								FROM bdicheq:"informix".sc_movhis
								WHERE fech_alt = dFecha_pago
								AND cancelad <> 'S' AND transacc IN (cTranCredPCP, iTransCargoCuenta, cNumTransaccEfec)
								AND cuenta = cCuenta_cheques
								AND sucursal = cIdSucursal;					
							ELSE --GDF
								IF cConvenio = "08001" THEN
									SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' AND transacc IN(cTranCredPGDF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;	
								 ELIF cConvenio = "08002" THEN
									SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' 
									AND transacc IN(cTranCredPEDOF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;								
								ELSE --Todos los demas convenios que no sean Orden de Pago y Transfer
									IF cConvenio NOT IN ("07001" ,"07002", "07003") AND cCateg <> '10' THEN
										SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
										FROM bdicheq:"informix".sc_movhis
										WHERE fech_alt = dFecha_pago
										AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec,cNumTransaccEfec_cpl)
										AND cuenta = cCuenta_cheques
										AND sucursal = cIdSucursal;
									ELSE --Es un Envio, Cobro o Cancelacion de Orden de Pago
										LET mCargoCuenta = 0;
									END IF;
								END IF;
							END IF;			
						END IF;
						
						IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_conciliaciontotalporconvenio where numcategoria=cCateg and numconvenio=cConv and fecha_pago=dFecha_pago and id_sucursal=cIdSucursal) THEN
							INSERT INTO bdisac:"informix".sac_conciliaciontotalporconvenio (retorno, numcategoria, numconvenio, nomconvenio, fecha_pago, importe_archivo, cuenta_cheques, importe_cheq, cuenta_contable, importe_conta, id_sucursal, numpagos, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, flag_confirmacion_central, flag_confirmacion_sucursal)
							VALUES (cCodRet, cCateg, cConv, cNomConvenio, dFecha_pago, 0, cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta, cIdSucursal, iNumPagos, 0, 0, 0, 0, iConfirmacionCentral, iConfirmacionSucursal);												
						END IF;					
					END FOREACH;
				END IF;
		END FOREACH;		
		--INSERTA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_CTC_S', dFecha_pago, '1', 'informix', 'sp_insertaconciliaciontotalporconvenio', cDescripcionSPJ);
		RETURN cCodRet;
	END;		
END PROCEDURE;