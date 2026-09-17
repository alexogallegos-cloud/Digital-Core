CREATE PROCEDURE "informix".sp_bts_recuperapayc(pRegs_Recup INTEGER,
											    pUsuario CHAR(8),
											    pFecha_Peticion CHAR(8),
											    pHora_Peticion CHAR(6))
	RETURNING CHAR(5)  AS CodRetorno,
			  CHAR(80) AS Desc_Error,
			  CHAR(11) AS Confirmacion_nm,
			  CHAR(4)  AS Process_type_code,
			  CHAR(20) AS Bank_ref_nm,
			  CHAR(40) AS Bank_concept1,
			  CHAR(15) AS Agnt_region_sd,
			  CHAR(15) AS Agnt_branch_sd,
			  CHAR(3)  AS Agnt_state_cd,
			  CHAR(3)  AS Agnt_country_cd,
			  CHAR(20) AS Agnt_user_name,
			  CHAR(15) AS Agnt_terminal,
			  CHAR(8)  AS Agent_dt,
			  CHAR(6)  AS Agent_tm,
			  CHAR(3)  AS R_type_cd,
			  CHAR(3)  AS R_issuer_cd,
			  CHAR(3)  AS R_issuer_state_cd,
			  CHAR(3)  AS R_issuer_country_cd,
			  CHAR(20) AS R_identif_nm,
			  CHAR(8)  AS R_expiration_dt,
			  CHAR(8)  AS R_benef_fecnac,
			  CHAR(80) AS Dir_remitente,
			  CHAR(40) AS Cd_remitente,
			  CHAR(3)  AS Rem_state_cd,
			  CHAR(3)  AS Rem_country_cd,
			  CHAR(10) AS Rem_zip_code,
			  CHAR(15) AS Rem_phone,
			  CHAR(8)  AS Fecha_proceso,
			  CHAR(6)  AS Hora_proceso;

--Definicion de Variables
DEFINE iSqlErr 				INTEGER;
DEFINE iIsamErr 			INTEGER;
DEFINE cCodRet 				CHAR(4);
DEFINE cCodRet2             CHAR(5);
DEFINE cOpCode				CHAR(4);
DEFINE cDescError			CHAR(80);
DEFINE cNombreSPL   		CHAR(30);
DEFINE cFechaInsert    		CHAR(8);
DEFINE cHoraInsert	   		CHAR(6);
DEFINE cDato        		CHAR(1);
DEFINE cValor       		CHAR(100);
DEFINE cConfirmacion_nm 	CHAR(11);
DEFINE cProcess_Type_code	CHAR(4);
DEFINE cBank_ref_nm			CHAR(20);
DEFINE cBank_concept1		CHAR(40);
DEFINE cAgnt_regin_sd		CHAR(15);
DEFINE cAgnt_branch_sd		CHAR(15);
DEFINE cAgnt_state_cd		CHAR(3);
DEFINE cAgnt_country_cd  	CHAR(3);
DEFINE cAgnt_user_name		CHAR(20);
DEFINE cAgnt_termina		CHAR(15);
DEFINE cAgnt_dt				CHAR(8);
DEFINE cAgnt_tm  			CHAR(6);
DEFINE cR_type_cd			CHAR(3);
DEFINE cR_issuer_cd     	CHAR(3);
DEFINE cR_issuer_state_cd	CHAR(3);
DEFINE cR_issuer_country_cd	CHAR(3);
DEFINE cR_identif_nm		CHAR(20);
DEFINE cR_expiration_dt		CHAR(8);
DEFINE cR_benef_fecnac		CHAR(8);
DEFINE cDir_remitente   	CHAR(80);
DEFINE cCd_remitente		CHAR(40);
DEFINE cRem_state_cd		CHAR(3);
DEFINE cRem_country_cd		CHAR(3);
DEFINE cRem_zip_code		CHAR(10);
DEFINE cRem_phone			CHAR(15);
DEFINE cAnio                CHAR(4);
DEFINE cMes                 CHAR(2);
DEFINE cDia                 CHAR(2);
DEFINE cFecha               CHAR(8);
DEFINE cCadena_ent          CHAR(100);
DEFINE dFechaHoy            DATE;
DEFINE iIntentos 			INTEGER;
DEFINE cParam				CHAR(100);
--Inicializacion de Variables
LET iSqlErr 			 = 0;
LET iIsamErr			 = 0;
LET cCodRet		 		 = '0000';
LET cCodRet2	 		 = '00000';
LET cOpCode				 = '0000';
LET cDescError	 		 = '';
LET cNombreSPL   		 = 'sp_bts_recuperapayc';
LET cFechaInsert    	 = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHoraInsert    		 = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cDato        		 = '';
LET cValor       		 = '';
LET cConfirmacion_nm 	 = '';
LET cProcess_Type_code	 = '';
LET cBank_ref_nm		 = '';
LET cBank_concept1		 = '';
LET cAgnt_regin_sd		 = '';
LET cAgnt_branch_sd		 = '';
LET cAgnt_state_cd		 = '';
LET cAgnt_country_cd  	 = '';
LET cAgnt_user_name		 = '';
LET cAgnt_termina		 = '';
LET cAgnt_dt			 = '';
LET cAgnt_tm  			 = '';
LET cR_type_cd			 = '';
LET cR_issuer_cd     	 = '';
LET cR_issuer_state_cd	 = '';
LET cR_issuer_country_cd = '';
LET cR_identif_nm		 = '';
LET cR_expiration_dt	 = '';
LET cR_benef_fecnac		 = '';
LET cDir_remitente   	 = '';
LET cCd_remitente		 = '';
LET cRem_state_cd		 = '';
LET cRem_country_cd		 = '';
LET cRem_zip_code		 = '';
LET cRem_phone			 = '';
LET cAnio                = '';
LET cMes                 = '';
LET cDia                 = '';
LET cFecha               = '';
LET dFechaHoy			 = DATE(1);
LET iIntentos            = 0;
LET cCadena_ent			 = TRIM(NVL(pRegs_Recup,'NULL'))||'|'||TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pFecha_Peticion,'NULL'))||'|'||TRIM(NVL(pHora_Peticion,'NULL'));
LET cParam				 = '';

--SET DEBUG FILE TO '/tmp/RMBTS/sp_bts_recuperapayc.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr,iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombreSPL, cCodRet, '',iSqlErr,iIsamErr, cCadena_ent,pUsuario,pFecha_Peticion,pHora_Peticion)
			INTO cCodRet2;
			RETURN LPAD(cCodRet,5,'0'),'','','','','','','','','','','','','','','','','','','','','','','','','','','','';
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdisac:"informix".sac_fechas
	WHERE empresa = '001';

	LET cAnio = SUBSTR(dFechaHoy,7,9);
	LET cMes = SUBSTR(dFechaHoy,4,2);
	LET cDia = SUBSTR(dFechaHoy,0,2);
	LET cFecha  = cAnio||cMes||cDia;

	INSERT INTO bdisac:"informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES (cNombreSPL,pFecha_Peticion,pHora_Peticion,'0',cCodRet,pUsuario,current::date,cHoraInsert);

	IF pRegs_Recup <> 0 THEN

				SELECT NVL(valor,'0')
				INTO cValor
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87013';

				SELECT NVL(valor,'0')
				INTO cParam
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87018';

				IF pHora_Peticion > '210000' THEN
					IF NOT EXISTS (SELECT fecha_proceso FROM bdisac:"informix".sac_ws_procesos WHERE proceso = 'recupera_findedia' AND fecha_insert = current::date) THEN
						INSERT INTO bdisac:"informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
							VALUES ('recupera_findedia',pFecha_Peticion,pHora_Peticion,'0',cCodRet,pUsuario,current::date,cHoraInsert);
						LET cValor = '100'; -- Para recuperar todas las remesas pendientes de enviar
					END IF;
				END IF;

				LET cAgnt_regin_sd = '001';
				LET cAgnt_state_cd = 'DF';
				LET cAgnt_country_cd = 'MEX';
				LET cAgnt_user_name = 'OP.CENTRAL BANCOPPEL';

				SELECT valor
					INTO cAgnt_branch_sd
					FROM bdisac:"informix".sac_param
					WHERE cod_param = '87015';

				SELECT valor
					INTO cAgnt_termina
					FROM bdisac:"informix".sac_param
					WHERE cod_param = '87016';

				FOREACH
					SELECT  LIMIT pRegs_Recup
					a.num_confirmacion, DECODE(estatus_sdep,'03','PAYC','04','PAYJ') AS Estatus_dsp ,a.fecha_peticion,a.hora_peticion,a.intentos_envio
					INTO cConfirmacion_nm,cProcess_Type_code, cAgnt_dt,cAgnt_tm,iIntentos
					FROM bdisac:"informix".sac_bts_sdep a
					WHERE a.estatus_sdep IN('03','04')
					AND a.intentos_envio <= cValor

					SELECT  b.folio_suc INTO cBank_ref_nm
					FROM bdisac:"informix".sac_movimientos b
					WHERE b.referencia1 = cConfirmacion_nm
					AND b.numcategoria = SUBSTR(TRIM(cParam),0,2)
					AND b.numconvenio = SUBSTR(TRIM(cParam),3,3)
					AND b.flag_confirmacion_central = '1'
					AND b.flag_confirmacion_sucursal = '1'
					AND b.status_cancelado = 'N';

					LET cCadena_ent = TRIM(NVL(pRegs_Recup,'NULL'))||'|'||TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(cConfirmacion_nm,'NULL'))||'|'||TRIM(NVL(pFecha_Peticion,'NULL'))||'|'||TRIM(NVL(pHora_Peticion,'NULL'));

					IF TRIM(cBank_ref_nm)='' OR cBank_ref_nm IS NULL THEN
						LET cBank_ref_nm = '0000000000000000';
						LET cBank_concept1 = 'Remesa Rechazada: ' || cConfirmacion_nm;
					ELSE
						LET cBank_concept1 = 'Pago de Remesa: ' || cConfirmacion_nm;
					END IF;

					LET iIntentos = iIntentos + 1;

					UPDATE bdisac:"informix".sac_bts_sdep
					SET intentos_envio = iIntentos
					WHERE num_confirmacion = cConfirmacion_nm and estatus_sdep IN('03','04');

					LET cDescError = 'Recuperación PAYC exitosa';

					RETURN LPAD(cCodRet,5,'0'),cDescError,cConfirmacion_nm,cProcess_Type_code,cBank_ref_nm,cBank_concept1,cAgnt_regin_sd,cAgnt_branch_sd,cAgnt_state_cd,cAgnt_country_cd,cAgnt_user_name,
						   cAgnt_termina,cAgnt_dt,cAgnt_tm,cR_type_cd,cR_issuer_cd,cR_issuer_state_cd,cR_issuer_country_cd,cR_identif_nm,cR_expiration_dt,cR_benef_fecnac,cDir_remitente,cCd_remitente,cRem_state_cd,cRem_country_cd,cRem_zip_code,cRem_phone,cFechaInsert,cHoraInsert WITH RESUME;

				END FOREACH;

				IF  DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '9978';
				END IF;
	ELSE
		LET cCodRet = '9985';
	END IF;

	IF cCodRet = '0000' THEN
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombreSPL, LPAD(cCodRet,5,'0'), cDescError,'','', cCadena_ent,pUsuario,pFecha_Peticion,pHora_Peticion)
		INTO cCodRet2;
	ELSE
		SELECT NVL(opcode, ''),NVL(opcode_ds,'')
		INTO cOpCode,cDescError
		FROM bdisac:"informix".sac_bts_catmensajes
		WHERE agent_trans_type_code = 'PAYC'
		AND opcode = cCodRet;

		IF cOpCode IS NULL THEN
			LET cDescError = 'Código no registrado en catálogo.';
		END IF;

		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombreSPL, LPAD(cCodRet,5,'0'), cDescError,'','', cCadena_ent,pUsuario,pFecha_Peticion,pHora_Peticion)
		INTO cCodRet2;

		IF cCodRet2 <> '00000' THEN
			LET cCodRet = cCodRet2;
		END IF
		RETURN LPAD(cCodRet,5,'0'),NVL(cDescError,''),'','','','','','','','','','','','','','','','','','','','','','','','','','','';
	END IF;
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para registrar movimientos que ya hayan sido',
'			  confirmados por BTS y que no hayan sido confirmados por BTS en varios intentos.',
'AUTOR : Martín Eduardo Miranda',
'FECHA : 25 Octubre 2012',
'VERSION: 20121025.0955',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_saccobranzasucursalhis(cSucursal VARCHAR(4), dFechaIni DATE, siRegistros SMALLINT)
    -- DATOS A REGRESAR
    RETURNING
    VARCHAR(5)  AS retorno,         --Codigo de Retorno
    VARCHAR(40) AS nombre,          --Nombre convenio
    VARCHAR(5)  AS IdConvenio,
    VARCHAR(16) AS folio_suc,       --Folio de sucursal
    VARCHAR(20) AS referencia1,     --Num telefono (Telmex), Num cliente(Coppel)
    VARCHAR(20) AS referencia2,     --DV (Telmex), Recibo(Coppel)
    VARCHAR(30) AS IdReferencia1,   --Nombre Referencia 1
    VARCHAR(30) AS IdReferencia2,   --Nombre Referencia 2
    MONEY(14,2) AS montoCargo,      --Monto de cargo a cuenta
    MONEY(14,2) AS montoEfectivo,   --Monto de pago en efectivo
    VARCHAR(1)  AS forma_pago,
    VARCHAR(40) AS region,          --Region de la sucursal
    VARCHAR(4)  AS sucursal,        --Numero de la sucursal
    MONEY(14,2) AS montoTotal,      --Monto total de la transaccion
    VARCHAR(10) AS operador,        --Operador que realiza la transaccion
    VARCHAR(20) AS cuentacargo,     --Cuenta a la que se realizo el cargo
    SMALLINT    AS ciclo;

    -- DEFINICION DE VARIABLES
    DEFINE cCodRet                    VARCHAR(5);
    DEFINE iSqlErr                    INTEGER;
    DEFINE iIsamErr                   INTEGER;
    DEFINE cTransCargoTelmex          VARCHAR(4);
    DEFINE cTransCargoCoppel          VARCHAR(4);
    DEFINE cInfoErr                   VARCHAR(100);
    DEFINE cIdConvenio                VARCHAR(5);
    DEFINE cFormaPago                 VARCHAR(3);
    DEFINE cIdReferencia1             VARCHAR(100);
    DEFINE cIdReferencia2             VARCHAR(100);
    DEFINE cRegion                    VARCHAR(40);
    DEFINE cFolioSuc                  VARCHAR(16);
    DEFINE cReferencia1               VARCHAR(20);
    DEFINE cReferencia2               VARCHAR(20);
    DEFINE cNomconvenio               VARCHAR(40);
    DEFINE mCargoCuenta               MONEY(14,2);
    DEFINE mCargoEfectivo             MONEY(14,2);
    DEFINE siCiclo                    SMALLINT;
    DEFINE cFecha_Hoy                 VARCHAR(10);
    DEFINE mImporteTotal              MONEY(14,2);
    DEFINE cOperador                  VARCHAR(10);
    DEFINE cCuentaCargo               VARCHAR(20);
    DEFINE cTransEfecTelmex           VARCHAR(4);
    DEFINE cTransEfecCoppel           VARCHAR(4);
    DEFINE ctransEfecEnvioOrden       VARCHAR(4);
    DEFINE ctransEfecEnvioComision    VARCHAR(4);
    DEFINE ctransEfecEnvioIVA         VARCHAR(4);
    DEFINE ctransCargoEnvioOrden      VARCHAR(4);
    DEFINE ctransCargoEnvioComision   VARCHAR(4);
    DEFINE ctransCargoEnvioIVA        VARCHAR(4);
    DEFINE ctransEfecPagoOrden        VARCHAR(4);
    DEFINE ctransEfecCancelacionOrden VARCHAR(4);
    DEFINE cTransCargoSky             VARCHAR(4);
    DEFINE cTransEfecSky              VARCHAR(4);
    DEFINE cTransCargo                VARCHAR(4);
    DEFINE cTransEfec                 VARCHAR(4);
    DEFINE siProcesoAutomatico        SMALLINT;
    --HOMOLOGACION GDF
    DEFINE cTranCredPGDF              VARCHAR(100);
	
    DEFINE cCconsmovhis               VARCHAR(10);	
    --INICIALIZACION DE VARIABLES--
    LET cCodRet                       = "00000";
    LET cIdConvenio                   = "";
    LET cIdReferencia1                = "";
    LET cIdReferencia2                = "";
    LET cFolioSuc                     = "";
    LET cReferencia1                  = "";
    LET cReferencia2                  = "";
    LET cNomconvenio                  = "";
    LET cFormaPago                    = "";
    LET cRegion                       = "";
    LET cTransCargoTelmex             = "";
    LET cTransCargoCoppel             = "";
    LET mCargoCuenta                  = 0;
    LET mCargoEfectivo                = 0;
    LET siCiclo                       = 0;
    LET cFecha_Hoy                    = "";
    LET mImporteTotal                 = 0;
    LET cOperador                     = '';
    LET cCuentaCargo                  = '';
    LET cTransEfecTelmex              = '';
    LET cTransEfecCoppel              = '';
    LET ctransEfecEnvioOrden          = "";
    LET ctransEfecEnvioComision       = "";
    LET ctransEfecEnvioIVA            = "";
    LET ctransCargoEnvioOrden         = "";
    LET ctransCargoEnvioComision      = "";
    LET ctransCargoEnvioIVA           = "";
    LET ctransEfecPagoOrden           = "";
    LET ctransEfecCancelacionOrden    = "";
    LET cTransCargoSky                = "";
    LET cTransEfecSky                 = "";
    LET cTransCargo                   = "";
    LET cTransEfec                    = "";
    LET siProcesoAutomatico           = 0;
    --HOMOLOGACION GDF	
    LET cTranCredPGDF                 = '';
    LET iSqlErr                       = 0; 
    LET iIsamErr                      = 0;
    LET cInfoErr                      = '';
    LET cCconsmovhis                  = '';

    BEGIN
       ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
          --SET DEBUG FILE TO  "/respaldosbd/Martha/sacreportehis_suc.out";
          --TRACE ON;
          IF iSqlErr <> 0 THEN
             LET cCodRet = iSqlErr;
             EXECUTE PROCEDURE bdisac:sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportecobranzasucursal");
             RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
          END IF;
       END EXCEPTION;
       --SET DEBUG FILE TO  "/respaldosbd/Martha/sacreportehis_suc.out";
       --TRACE ON;
	
       SET LOCK MODE TO WAIT 3;
       SET ISOLATION TO DIRTY READ;

       IF cSucursal = "" OR LENGTH(cSucursal) <> 4 THEN
          LET cCodRet = "00001";
          RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
    
       ELIF siRegistros IS NULL THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal,   mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
       ELSE
           SELECT fecha_hoy
             INTO cFecha_hoy
             FROM bdisac:sac_fechas
            WHERE empresa='001';

           SELECT valor
             INTO cCconsmovhis
             FROM bdicheq:sc_param
            WHERE codparam = 'fechcon_movhis' 
              AND empresa = '001';
           /* Se quito el trim y el LPAD y se de el tratamiento despuÃ©s, se agrega WHERE */
           SELECT CAST(NVL(SUM(CAST(transCargoTelmex AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoTelmex,
                  CAST(NVL(SUM(CAST(transCargoCoppel AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoCoppel,
                  CAST(NVL(SUM(CAST(transEfecCoppel AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecCoppel,
                  CAST(NVL(SUM(CAST(transEfecTelmex AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecTelmex,
                  CAST(NVL(SUM(CAST(transEfecEnvioOrden AS INTEGER)), 0)AS VARCHAR(4)) AS transEfecEnvioOrden,
                  CAST(NVL(SUM(CAST(transEfecEnvioComision AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecEnvioComision,
                  CAST(NVL(SUM(CAST(transEfecEnvioIVA AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecEnvioIVA,
                  CAST(NVL(SUM(CAST(transCargoEnvioOrden AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoEnvioOrden,
                  CAST(NVL(SUM(CAST(transCargoEnvioComision AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoEnvioComision,
                  CAST(NVL(SUM(CAST(transCargoEnvioIVA AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoEnvioIVA,
                  CAST(NVL(SUM(CAST(transEfecPagoOrden AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecPagoOrden,
                  CAST(NVL(SUM(CAST(transEfecCancelacionOrden AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecCancelacionOrden,
                  CAST(NVL(SUM(CAST(transCargoSky AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoSky,
                  CAST(NVL(SUM(CAST(transEfecSky AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecSky
             INTO cTransCargoTelmex,    
                  cTransCargoCoppel,       
                  cTransEfecCoppel, 
                  cTransEfecTelmex,
                  ctransEfecEnvioOrden, 
                  ctransEfecEnvioComision, 
                  ctransEfecEnvioIVA,
                  ctransCargoEnvioOrden,
                  ctransCargoEnvioComision,
                  ctransCargoEnvioIVA,
                  ctransEfecPagoOrden,
                  ctransEfecCancelacionOrden,
                  cTransCargoSky,
                  cTransEfecSky
             FROM TABLE(MULTISET(
                        SELECT CASE WHEN cod_param = 80001 THEN TRIM(VALOR) END AS transCargoTelmex,
                               CASE WHEN cod_param = 80002 THEN TRIM(VALOR) END AS transCargoCoppel,
                               CASE WHEN cod_param = 901001 THEN TRIM(VALOR) END AS transEfecCoppel,
                               CASE WHEN cod_param = 902001 THEN TRIM(VALOR) END AS transEfecTelmex,
                               CASE WHEN cod_param = 5070011 THEN TRIM(VALOR) END AS transEfecEnvioOrden,
                               CASE WHEN cod_param = 511070011 THEN TRIM(VALOR) END AS transEfecEnvioComision,
                               CASE WHEN cod_param = 510070011 THEN TRIM(VALOR) END AS transEfecEnvioIVA,
                               CASE WHEN cod_param = 5070012 THEN TRIM(VALOR) END AS transCargoEnvioOrden,
                               CASE WHEN cod_param = 511070012 THEN TRIM(VALOR) END AS transCargoEnvioComision,
                               CASE WHEN cod_param = 510070012 THEN TRIM(VALOR) END AS transCargoEnvioIVA,
                               CASE WHEN cod_param = 41407002 THEN TRIM(VALOR) END AS transEfecPagoOrden,
                               CASE WHEN cod_param = 41507003 THEN TRIM(VALOR) END AS transEfecCancelacionOrden,
                               CASE WHEN cod_param = 80006 THEN TRIM(VALOR) END AS transCargoSky,
                               CASE WHEN cod_param = 906001 THEN TRIM(VALOR) END AS transEfecSky
                          FROM bdisac:sac_param
                         WHERE empresa = '001'
                           AND cod_param > 0 ));
           
           LET cTransCargoTelmex          = LPAD(TRIM(cTransCargoTelmex), 4, '0');     
           LET cTransCargoCoppel          = LPAD(TRIM(cTransCargoCoppel), 4, '0');         
           LET cTransEfecCoppel           = LPAD(TRIM(cTransEfecCoppel), 4, '0');
           LET cTransEfecTelmex           = LPAD(TRIM(cTransEfecTelmex), 4, '0');
           LET ctransEfecEnvioOrden       = LPAD(TRIM(ctransEfecEnvioOrden), 4, '0');
           LET ctransEfecEnvioComision    = LPAD(TRIM(ctransEfecEnvioComision), 4, '0'); 
           LET ctransEfecEnvioIVA         = LPAD(TRIM(ctransEfecEnvioIVA), 4, '0');
           LET ctransCargoEnvioOrden      = LPAD(TRIM(ctransCargoEnvioOrden), 4, '0');
           LET ctransCargoEnvioComision   = LPAD(TRIM(ctransCargoEnvioComision), 4, '0');
           LET ctransCargoEnvioIVA        = LPAD(TRIM(ctransCargoEnvioIVA), 4, '0');  
           LET ctransEfecPagoOrden        = LPAD(TRIM(ctransEfecPagoOrden), 4, '0');
           LET ctransEfecCancelacionOrden = LPAD(TRIM(ctransEfecCancelacionOrden), 4, '0');
           LET cTransCargoSky             = LPAD(TRIM(cTransCargoSky), 4, '0');
           LET cTransEfecSky              = LPAD(TRIM(cTransEfecSky), 4, '0');

           IF dFechaIni > cFecha_hoy THEN
              LET cCodRet = "00001";
              RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
      
           ELSE
               /* Se agrega nombre al Foreach, se acomodan los filtros y se agrega un d.empresa = '001', que faltaba*/
               FOREACH Curini FOR
                     SELECT b.folio_suc, f.numcategoria||f.numconvenio AS numconvenio,f.nomconvenio, b.referencia1, b.referencia2, b.forma_pago, e.nombre, b.importe_pago, b.usuario, 
                            b.cuenta_cargo, f.trans_cen_cargo_cliente, f.trans_cen_efectivo_cliente, f.proceso_automatico,
                            f.nombre_referencia1, f.nombre_referencia2
                       INTO cFolioSuc, cIdConvenio, cNomconvenio,cReferencia1, cReferencia2, cFormaPago, cRegion, mImporteTotal, cOperador, cCuentaCargo, cTransCargo, cTransEfec, 
                            siProcesoAutomatico, cIdReferencia1, cIdReferencia2
                       FROM bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e, bdisac:sac_convenios f
                      WHERE b.numcategoria = f.numcategoria
                        AND b.numconvenio = f.numconvenio
                        AND b.id_sucursal = cSucursal     
                        AND b.fecha_pago  = dFechaIni  
                        AND b.status_cancelado <> 'S'
                        AND c.sucursal = b.id_sucursal
                        AND d.plaza = c.plaza
                        AND d.empresa = '001'  
                        AND e.regional = d.regional
                        AND e.empresa = '001'
                      ORDER BY folio_suc

	             IF siProcesoAutomatico = 1 THEN
                        
                        IF cFormaPago = '1' THEN
                           LET mCargoEfectivo = mImporteTotal;
                           LET mCargoCuenta = 0;

                        ELIF cFormaPago = '2' OR cFormaPago = '4' THEN
                           LET mCargoCuenta = mImporteTotal;
                           LET mCargoEfectivo = 0;
                        --HOMOLOGACION GDF
                        ELIF cFormaPago = '3' OR cFormaPago = '5' THEN
                             IF dFechaIni >= cCconsmovhis THEN
                                /*Se unificaron queries(3) en 1*/ 
                                SELECT NVL(SUM(CASE WHEN transacc = cTransEfec  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                       NVL(SUM(CASE WHEN transacc = cTransCargo THEN monto_tot ELSE 0 END), 0) AS totCargo
                                  INTO mCargoEfectivo, mCargoCuenta
                                  FROM bdicheq:sc_movhis
                                 WHERE empresa   = '001'
                                   AND fech_alt  = dFechaIni
                                   AND sucursal  = cSucursal
                                   AND folio_suc = cFolioSuc
                                   AND transacc IN (cTransEfec, cTransCargo);

                             ELSE                       
                                /*Se unificaron queries(4) en 1*/
                                SELECT 
                                       NVL(SUM(CASE WHEN transacc = cTransEfec  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                       NVL(SUM(CASE WHEN transacc = cTransCargo THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                  INTO mCargoEfectivo, mCargoCuenta
                                  FROM bdicheq:sc_movhis_old
                                 WHERE empresa = '001'
                                   AND fech_alt = dFechaIni
                                   AND sucursal = cSucursal
                                   AND folio_suc = cFolioSuc
                                   AND transacc in (cTransEfec, cTransCargo);  
                                 
                             END IF;
                    
                             IF cIdConvenio = '08001' THEN
                                SELECT NVL(TRIM(valor),'')
                                  INTO cTranCredPGDF 
                                  FROM bdisac:sac_param 
                                 WHERE cod_param = '87033';
 
                               /* Se quito el multiset porque es inecesario*/
                                SELECT NVL(SUM(monto), 0) AS totCargo
                                  INTO mCargoCuenta
                                  FROM bdicred:sd_movhis
                                 WHERE fecha_mov    = dFechaIni
                                   AND sucursal     = cSucursal
                                   AND folio_suc    = cFolioSuc
                                   AND transacc_suc = cTranCredPGDF;
                             END IF;
                        END IF;
                 ELSE		
                        SELECT valor
                          INTO cIdReferencia1
                          FROM bdisac:sac_param
                         WHERE empresa='001' AND cod_param= '6' || cIdConvenio || '1';
                        
                        SELECT valor
                          INTO cIdReferencia2
                          FROM bdisac:sac_param
                         WHERE empresa='001' 
                           AND cod_param= '6' || cIdConvenio || '2';  
                
                        IF cFormaPago = '1' AND cIdConvenio <> '07001' THEN
                           LET mCargoEfectivo = mImporteTotal;
                           LET mCargoCuenta = 0;
                        ELIF cFormaPago = '2' AND cIdConvenio <> '07001' THEN
                             LET mCargoCuenta = mImporteTotal;
                             LET mCargoEfectivo = 0;
                        ELIF cFormaPago = '3' OR cIdConvenio = '07001' THEN
                             IF dFechaIni >= cCconsmovhis THEN
                                IF cIdConvenio = '01001' THEN

                                 /*Se unificaron queries(5) en 1*/
                                   SELECT NVL(SUM(CASE WHEN transacc = cTransEfecCoppel  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                          NVL(SUM(CASE WHEN transacc = cTransCargoCoppel THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                     INTO mCargoEfectivo, mCargoCuenta
                                     FROM bdicheq:sc_movhis
                                    WHERE empresa = '001'
                                      AND fech_alt = dFechaIni
                                      AND sucursal = cSucursal
                                      AND folio_suc = cFolioSuc
                                      AND transacc in (cTransEfecCoppel, cTransCargoCoppel);  

                                ELIF cIdConvenio = '02001' THEN

                                     /*Se unificaron queries(6) en 1*/      
                                     SELECT NVL(SUM(CASE WHEN transacc = cTransEfecTelmex  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                            NVL(SUM(CASE WHEN transacc = cTransCargoTelmex THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                       INTO mCargoEfectivo, mCargoCuenta
                                       FROM bdicheq:sc_movhis
                                      WHERE empresa = '001'
                                        AND fech_alt = dFechaIni
                                        AND sucursal = cSucursal
                                        AND folio_suc = cFolioSuc
                                        AND transacc in (cTransEfecTelmex, cTransCargoTelmex);   

                                ELIF cIdConvenio = '06001' THEN
 
                                     /*Se unificaron queries(7) en 1*/ 
                                     SELECT NVL(SUM(CASE WHEN transacc = cTransEfecSky  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                            NVL(SUM(CASE WHEN transacc = cTransCargoSky THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                       INTO mCargoEfectivo, mCargoCuenta
                                       FROM bdicheq:sc_movhis
                                      WHERE empresa = '001'
                                        AND fech_alt = dFechaIni
                                        AND sucursal = cSucursal
                                        AND folio_suc = cFolioSuc
                                        AND transacc in (cTransEfecSky, cTransCargoSky);   
 
                                ELIF cIdConvenio = '07001' THEN
                                     LET mImporteTotal = 0;

                                     FOREACH CurDet FOR
                                           SELECT NVL(SUM(importe_total),0) 
                                             INTO mImporteTotal 
                                             FROM bdisac:sac_enviosdineroya
                                            WHERE no_control = cReferencia1 AND estatus IS NOT NULL
                                          UNION ALL
                                           SELECT NVL(SUM(importe_total),0)
                                             FROM bdisac:sac_enviosdineroyahis
                                            WHERE no_control = cReferencia1 AND estatus IS NOT NULL 
                                            ORDER BY 0
 	
                                           IF cFormaPago = '1' THEN
                                              LET mCargoEfectivo = mImporteTotal;
                                              LET mCargoCuenta = 0;
                                           ELIF cFormaPago = '2' THEN
 	                                          LET mCargoCuenta = mImporteTotal;
 	                                          LET mCargoEfectivo = 0;
                                           ELIF cFormaPago = '3' THEN
 
                                              SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                                INTO mCargoEfectivo
                                                FROM bdicheq:sc_movhis
                                               WHERE empresa = '001'
                                                 AND fech_alt = dFechaIni
                                                 AND transacc IN (ctransEfecEnvioOrden, ctransEfecEnvioComision, ctransEfecEnvioIVA)
                                                 AND sucursal = cSucursal
                                                 AND folio_suc = cFolioSuc;

                                              SELECT NVL(SUM(monto_tot), 0) AS totCargo
                                                INTO mCargoCuenta
                                                FROM bdicheq:sc_movhis
                                               WHERE empresa = '001'
                                                AND fech_alt = dFechaIni
                                                AND transacc IN (ctransCargoEnvioOrden, ctransCargoEnvioComision, ctransCargoEnvioIVA)
                                                AND sucursal = cSucursal
                                                AND folio_suc = cFolioSuc;

                                           END IF;
                                     END FOREACH;

                                     LET cReferencia1='********'||SUBSTRING (cReferencia1 FROM 9 FOR 4);

                                ELIF cIdConvenio = '07002' THEN
 	                                 LET mCargoCuenta = 0;
                   
                                     SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                       INTO mCargoEfectivo
                                       FROM bdicheq:sc_movhis
                                      WHERE empresa = '001'
                                        AND fech_alt = dFechaIni
                                        AND transacc = ctransEfecPagoOrden
                                        AND sucursal = cSucursal
                                        AND folio_suc = cFolioSuc;

                                ELIF cIdConvenio = '07003' THEN
                                     LET mCargoCuenta = 0;
            
                                     SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                       INTO mCargoEfectivo
                                       FROM bdicheq:sc_movhis
                                      WHERE empresa = '001'
                                        AND fech_alt = dFechaIni
                                        AND transacc = ctransEfecCancelacionOrden
                                        AND sucursal = cSucursal
                                        AND folio_suc = cFolioSuc;
                                END IF;
                             ELSE
                                 IF cIdConvenio = '01001' THEN

                                    /*Se unificaron queries(8) en 1*/ 
                                    SELECT NVL(SUM(CASE WHEN transacc = cTransEfecCoppel  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                           NVL(SUM(CASE WHEN transacc = cTransCargoCoppel THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                      INTO mCargoEfectivo, mCargoCuenta
                                      FROM bdicheq:sc_movhis_old
                                     WHERE empresa = '001'
                                       AND fech_alt = dFechaIni
                                       AND sucursal = cSucursal
                                       AND folio_suc = cFolioSuc
                                       AND transacc in (cTransEfecCoppel, cTransCargoCoppel);   

                                 ELIF cIdConvenio = '02001' THEN

                                    /*Se unificaron queries(9) en 1*/ 
                                    SELECT NVL(SUM(CASE WHEN transacc = cTransEfecTelmex  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                           NVL(SUM(CASE WHEN transacc = cTransCargoTelmex THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                      INTO mCargoEfectivo, mCargoCuenta
                                      FROM bdicheq:sc_movhis_old
                                     WHERE empresa = '001'
                                       AND fech_alt = dFechaIni
                                       AND sucursal = cSucursal
                                       AND folio_suc = cFolioSuc
                                       AND transacc in (cTransEfecTelmex, cTransCargoTelmex); 

                                 ELIF cIdConvenio = '06001' THEN

                                      /*Se unificaron queries(10) en 1*/  
                                      SELECT NVL(SUM(CASE WHEN transacc = cTransEfecSky  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                             NVL(SUM(CASE WHEN transacc = cTransCargoSky THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                        INTO mCargoEfectivo, mCargoCuenta
                                        FROM bdicheq:sc_movhis_old
                                       WHERE empresa = '001'
                                         AND fech_alt = dFechaIni
                                         AND sucursal = cSucursal
                                         AND folio_suc = cFolioSuc
                                         AND transacc in (cTransEfecSky, cTransCargoSky);  

                                 ELIF cIdConvenio = '07001' THEN
                                      LET mImporteTotal = 0;

                                      FOREACH CurDet FOR

                                            SELECT NVL(SUM(importe_total),0) 
                                              INTO mImporteTotal 
                                              FROM bdisac:sac_enviosdineroya
                                             WHERE no_control = cReferencia1 AND estatus IS NOT NULL
                                            UNION ALL
                                            SELECT NVL(SUM(importe_total),0)
                                              FROM bdisac:sac_enviosdineroyahis
                                             WHERE no_control = cReferencia1 AND estatus IS NOT NULL 
                                             ORDER BY 0
 	
                                            IF cFormaPago = '1' THEN
                                               LET mCargoEfectivo = mImporteTotal;
                                               LET mCargoCuenta = 0;
                                            ELIF cFormaPago = '2' OR cFormaPago = '4' THEN
                                               LET mCargoCuenta = mImporteTotal;
                                               LET mCargoEfectivo = 0;
                                            ELIF cFormaPago = '3' THEN

                                               SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                                 INTO mCargoEfectivo
                                                 FROM bdicheq:sc_movhis_old
                                                WHERE empresa = '001'
                                                  AND fech_alt = dFechaIni
                                                  AND transacc IN (ctransEfecEnvioOrden, ctransEfecEnvioComision, ctransEfecEnvioIVA)
                                                  AND sucursal = cSucursal
                                                  AND folio_suc = cFolioSuc;

                                               SELECT NVL(SUM(monto_tot), 0) AS totCargo
                                                 INTO mCargoCuenta
                                                 FROM bdicheq:sc_movhis_old
                                                WHERE empresa = '001'
                                                  AND fech_alt = dFechaIni
                                                  AND transacc IN (ctransCargoEnvioOrden, ctransCargoEnvioComision, ctransCargoEnvioIVA)
                                                  AND sucursal = cSucursal
                                                  AND folio_suc = cFolioSuc;

                                            END IF;
                                      END FOREACH;

                                      LET cReferencia1='********'||SUBSTRING (cReferencia1 FROM 9 FOR 4);

                                 ELIF cIdConvenio = '07002' THEN
                                      LET mCargoCuenta = 0;

                                      SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                        INTO mCargoEfectivo
                                        FROM bdicheq:sc_movhis_old
                                       WHERE empresa = '001'
                                         AND fech_alt = dFechaIni
                                         AND transacc = ctransEfecPagoOrden
                                         AND sucursal = cSucursal
                                         AND folio_suc = cFolioSuc;

                                 ELIF cIdConvenio = '07003' THEN
                                      LET mCargoCuenta = 0;
                         	
                                      SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                        INTO mCargoEfectivo
                                        FROM bdicheq:sc_movhis_old
                                       WHERE empresa = '001'
                                         AND fech_alt = dFechaIni
                                         AND transacc = ctransEfecCancelacionOrden
                                         AND sucursal = cSucursal
                                         AND folio_suc = cFolioSuc;
                        
                                 END IF;
                             END IF;
                             --------
                            /* Se comenta porque realmente no hace nada*/  
                            /* IF cIdConvenio = '07001' THEN

                             END IF*/
                        END IF;
                 END IF;
                 LET siCiclo = siCiclo + 1;
                 -- PAGINACION
                 IF siCiclo <= siRegistros THEN
                    CONTINUE FOREACH;
                 END IF;

                 RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo
                 WITH RESUME;
               END FOREACH;
           END IF
       END IF;
    END;	
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener lo movimientos de la cobranza de pago de servicios para una fecha especifica',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Noviembre 2009',
'VERSION: 20091207.1305',
'BD    : bdisac',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Se agregan validaciones para que contemple los movimientos para ordenes de pago',
'VERSION DE CAMBIO: 20100420.1659',
'MODIFICA : Dulce Ramirez',
'DESCRIPCION: Se agrega SUM al campo importe_total, para que no regrese valor nulo en caso de no encontrar registro',
'VERSION DE CAMBIO: 20100507.1245',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Se corrige para que obtenga correctamente los totales de los historicos',
'VERSION DE CAMBIO: 20100512.0838',
'MODIFICA : Dulce Ramirez',
'DESCRIPCION: Se agregan validaciones para que contemple los movimientos para pagos sky',
'VERSION DE CAMBIO: 20100521.1719',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Junto con la integracion de Pagos MVS se integra la modificacion para los convenios en proceso automatico para su funcionamiento dinamico',
'VERSION DE CAMBIO: 20100923.1843',
'MODIFICA : Dulce RamÃÂ­rez',
'DESCRIPCION: Se modifica para incluir la forma de pago 4 "Abono en cuenta" para pago de remesas BTS',
'VERSION DE CAMBIO: 20100923.1843',
'                                    ',
'MODIFICA : MartÃÂ­n Eduardo Miranda',
'DESCRIPCION: Se agrega nuevo retorno "cIdConvenio" para ordenar el reporte diario de Servicios por sucursal',
'VERSION DE CAMBIO: 20120830.1629',

'MODIFICA : Martha Aguirre',
'DESCRIPCION: Se agrega bÃÂºsqueda de monto para el movimiento de cargo en cuenta de crÃÂ©dito para el cIdConvenio 8001',
'             "Pago de Servicios del Gobierno del Distrito Federal',
'VERSION DE CAMBIO: 20130109.1030';

CREATE PROCEDURE "informix".sp_saccobranzasucursalhis(cSucursal VARCHAR(4), dFechaIni DATE, siRegistros SMALLINT,stipo SMALLINT)

    -- DATOS A REGRESAR
    RETURNING
    VARCHAR(5)  AS retorno,            --Codigo de Retorno
    VARCHAR(40) AS nombre,             --Nombre convenio
    VARCHAR(5)  AS IdConvenio,
    VARCHAR(16) AS folio_suc,          --Folio de sucursal
    VARCHAR(40) AS referencia1,        --Num telefono (Telmex), Num cliente(Coppel)
    VARCHAR(40) AS referencia2,        --DV (Telmex), Recibo(Coppel)
    VARCHAR(30) AS IdReferencia1,      --Nombre Referencia 1
    VARCHAR(30) AS IdReferencia2,      --Nombre Referencia 2
    MONEY(14,2) AS montoCargo,         --Monto de cargo a cuenta
    MONEY(14,2) AS montoEfectivo,      --Monto de pago en efectivo
    VARCHAR(1) AS forma_pago,
    VARCHAR(40) AS region,             --Region de la sucursal
    VARCHAR(4) AS sucursal,            --Numero de la sucursal
    MONEY(14,2) AS montoTotal,         --Monto total de la transaccion
    VARCHAR(10) AS operador,           --Operador que realiza la transaccion
    VARCHAR(20) AS cuentacargo,        --Cuenta a la que se realizo el cargo
    SMALLINT AS ciclo;

    -- DEFINICION DE VARIABLES
    DEFINE cCodRet                      VARCHAR(5);
    DEFINE iSqlErr                      INTEGER;
    DEFINE iIsamErr                     INTEGER;
    DEFINE cTransCargoTelmex            VARCHAR(4);
    DEFINE cTransCargoCoppel            VARCHAR(4);
    DEFINE cInfoErr                     VARCHAR(100);
    DEFINE cIdConvenio                  VARCHAR(5);
    DEFINE cFormaPago                   VARCHAR(3);
    DEFINE cIdReferencia1               VARCHAR(100);
    DEFINE cIdReferencia2               VARCHAR(100);
    DEFINE cRegion                      VARCHAR(40);
    DEFINE cFolioSuc                    VARCHAR(16);
    DEFINE cReferencia1                 VARCHAR(40);
    DEFINE cReferencia2                 VARCHAR(40);
    DEFINE cNomconvenio                 VARCHAR(40);
    DEFINE mCargoCuenta                 MONEY(14,2);
    DEFINE mCargoEfectivo               MONEY(14,2);
    DEFINE siCiclo                      SMALLINT;
    DEFINE cFecha_Hoy                   VARCHAR(10);
    DEFINE mImporteTotal                MONEY(16,2);
    DEFINE cOperador                    VARCHAR(10);
    DEFINE cCuentaCargo                 VARCHAR(20);
    DEFINE cTransEfecTelmex             VARCHAR(4);
    DEFINE cTransEfecCoppel             VARCHAR(4);
    DEFINE ctransEfecEnvioOrden         VARCHAR(4);
    DEFINE ctransEfecEnvioComision      VARCHAR(4);
    DEFINE ctransEfecEnvioIVA           VARCHAR(4);
    DEFINE ctransCargoEnvioOrden        VARCHAR(4);
    DEFINE ctransCargoEnvioComision     VARCHAR(4);
    DEFINE ctransCargoEnvioIVA          VARCHAR(4);
    DEFINE ctransEfecPagoOrden          VARCHAR(4);
    DEFINE ctransEfecCancelacionOrden	VARCHAR(4);
    DEFINE cTransCargoSky               VARCHAR(4);
    DEFINE cTransEfecSky            	VARCHAR(4);
    DEFINE cTransCargo                  VARCHAR(4);
    DEFINE cTransEfec                   VARCHAR(4);
    DEFINE siProcesoAutomatico          SMALLINT;
    DEFINE cTranCredPGDF                VARCHAR(100);
    --HOMOLOGACION CLUB DE PROTECCION COPPEL
    DEFINE cTranCredPCP                 VARCHAR(100);
    --HOMOLOGACION TAE
    DEFINE cTranCredPTAE                VARCHAR(100);
    --HOMOLOGACION EDOMEX
    DEFINE cTranCredEDOMEX              VARCHAR(100);
	
    DEFINE cCconsmovhis                 VARCHAR(10);	
    --INICIALIZACION DE VARIABLES--
    LET cCodRet                     = "00000";
    LET cIdConvenio                 = "";
    LET cIdReferencia1              = "";
    LET cIdReferencia2              = "";
    LET cFolioSuc                   = "";
    LET cReferencia1                = "";
    LET cReferencia2                = "";
    LET cNomconvenio                = "";
    LET cFormaPago                  = "";
    LET cRegion                     = "";
    LET cTransCargoTelmex           = "";
    LET cTransCargoCoppel           = "";
    LET mCargoCuenta                = 0;
    LET mCargoEfectivo              = 0;
    LET siCiclo                     = 0;
    LET cFecha_Hoy                  = "";
    LET mImporteTotal               = 0;
    LET cOperador                   = '';
    LET cCuentaCargo                = '';
    LET cTransEfecTelmex            = '';
    LET cTransEfecCoppel            = '';
    LET ctransEfecEnvioOrden        = "";
    LET ctransEfecEnvioComision     = "";
    LET ctransEfecEnvioIVA          = "";
    LET ctransCargoEnvioOrden       = "";
    LET ctransCargoEnvioComision    = "";
    LET ctransCargoEnvioIVA         = "";
    LET ctransEfecPagoOrden         = "";
    LET ctransEfecCancelacionOrden  = "";
    LET cTransCargoSky              = "";
    LET cTransEfecSky               = "";
    LET cTransCargo                 = "";
    LET cTransEfec                  = "";
    LET siProcesoAutomatico         = 0;
    LET cTranCredPGDF               = '';
    --HOMOLOGACION CLUB DE PROTECCION COPPEL	
    LET cTranCredPCP                = '';
    --HOMOLOGACION TAE
    LET cTranCredPTAE               = "";
    --HOMOLOGACION EDOMEX
    LET cTranCredEDOMEX             = "";	
    LET cTranCredPGDF                 = '';
    LET iSqlErr                       = 0; 
    LET iIsamErr                      = 0;
    LET cInfoErr                      = '';
    LET cCconsmovhis                  = '';

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            --SET DEBUG FILE TO  "/home/sysifx/JesusBueno/sacreportehis_suc.out";
            --TRACE ON;
            IF iSqlErr <> 0 THEN
               LET cCodRet = iSqlErr;
                   EXECUTE PROCEDURE bdisac:sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportecobranzasucursal");
               RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
            END IF;

        END EXCEPTION;
        --SET DEBUG FILE TO  "/home/sysifx/JesusBueno/sacreportehis_suc.out";
        --TRACE ON;
	
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;

        IF cSucursal = "" OR LENGTH(cSucursal) <> 4 THEN
           LET cCodRet = "00001";
           RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
        ELIF siRegistros IS NULL THEN
             LET cCodRet = "00001";
             RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
    
        ELSE
            SELECT  fecha_hoy
              INTO cFecha_hoy
              FROM bdisac:sac_fechas
             WHERE empresa='001';

            SELECT valor
              INTO cCconsmovhis
              FROM bdicheq:sc_param
             WHERE codparam = 'fechcon_movhis' AND empresa = '001';
            /* Se quito el trim y el LPAD y se de el tratamiento despuÃ©s, se agrega WHERE */  
            SELECT CAST(NVL(SUM(CAST(transCargoTelmex AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoTelmex,
                   CAST(NVL(SUM(CAST(transCargoCoppel AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoCoppel,
                   CAST(NVL(SUM(CAST(transEfecCoppel AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecCoppel,
                   CAST(NVL(SUM(CAST(transEfecTelmex AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecTelmex,
                   CAST(NVL(SUM(CAST(transEfecEnvioOrden AS INTEGER)), 0)AS VARCHAR(4)) AS transEfecEnvioOrden,
                   CAST(NVL(SUM(CAST(transEfecEnvioComision AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecEnvioComision,
                   CAST(NVL(SUM(CAST(transEfecEnvioIVA AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecEnvioIVA,
                   CAST(NVL(SUM(CAST(transCargoEnvioOrden AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoEnvioOrden,
                   CAST(NVL(SUM(CAST(transCargoEnvioComision AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoEnvioComision,
                   CAST(NVL(SUM(CAST(transCargoEnvioIVA AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoEnvioIVA,
                   CAST(NVL(SUM(CAST(transEfecPagoOrden AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecPagoOrden,
                   CAST(NVL(SUM(CAST(transEfecCancelacionOrden AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecCancelacionOrden,
                   CAST(NVL(SUM(CAST(transCargoSky AS INTEGER)), 0) AS VARCHAR(4)) AS transCargoSky,
                   CAST(NVL(SUM(CAST(transEfecSky AS INTEGER)), 0) AS VARCHAR(4)) AS transEfecSky
              INTO cTransCargoTelmex,
                   cTransCargoCoppel,
                   cTransEfecCoppel,
                   cTransEfecTelmex,
                   ctransEfecEnvioOrden,
                   ctransEfecEnvioComision,
                   ctransEfecEnvioIVA,
                   ctransCargoEnvioOrden,
                   ctransCargoEnvioComision,
                   ctransCargoEnvioIVA,
                   ctransEfecPagoOrden,
                   ctransEfecCancelacionOrden,
                   cTransCargoSky,
                   cTransEfecSky
              FROM TABLE(MULTISET(SELECT CASE WHEN cod_param = 80001 THEN TRIM(VALOR) END AS transCargoTelmex,
                                         CASE WHEN cod_param = 80002 THEN TRIM(VALOR) END AS transCargoCoppel,
                                         CASE WHEN cod_param = 901001 THEN TRIM(VALOR) END AS transEfecCoppel,
                                         CASE WHEN cod_param = 902001 THEN TRIM(VALOR) END AS transEfecTelmex,
                                         CASE WHEN cod_param = 5070011 THEN TRIM(VALOR) END AS transEfecEnvioOrden,
                                         CASE WHEN cod_param = 511070011 THEN TRIM(VALOR) END AS transEfecEnvioComision,
                                         CASE WHEN cod_param = 510070011 THEN TRIM(VALOR) END AS transEfecEnvioIVA,
                                         CASE WHEN cod_param = 5070012 THEN TRIM(VALOR) END AS transCargoEnvioOrden,
                                         CASE WHEN cod_param = 511070012 THEN TRIM(VALOR) END AS transCargoEnvioComision,
                                         CASE WHEN cod_param = 510070012 THEN TRIM(VALOR) END AS transCargoEnvioIVA,
                                         CASE WHEN cod_param = 41407002 THEN TRIM(VALOR) END AS transEfecPagoOrden,
                                         CASE WHEN cod_param = 41507003 THEN TRIM(VALOR) END AS transEfecCancelacionOrden,
                                         CASE WHEN cod_param = 80006 THEN TRIM(VALOR) END AS transCargoSky,
                                         CASE WHEN cod_param = 906001 THEN TRIM(VALOR) END AS transEfecSky
                                    FROM bdisac:sac_param
                                   WHERE empresa = '001'
                                     AND cod_param > 0 ));
            
            LET cTransCargoTelmex          = LPAD(TRIM(cTransCargoTelmex), 4, '0');     
            LET cTransCargoCoppel          = LPAD(TRIM(cTransCargoCoppel), 4, '0');         
            LET cTransEfecCoppel           = LPAD(TRIM(cTransEfecCoppel), 4, '0');
            LET cTransEfecTelmex           = LPAD(TRIM(cTransEfecTelmex), 4, '0');
            LET ctransEfecEnvioOrden       = LPAD(TRIM(ctransEfecEnvioOrden), 4, '0');
            LET ctransEfecEnvioComision    = LPAD(TRIM(ctransEfecEnvioComision), 4, '0'); 
            LET ctransEfecEnvioIVA         = LPAD(TRIM(ctransEfecEnvioIVA), 4, '0');
            LET ctransCargoEnvioOrden      = LPAD(TRIM(ctransCargoEnvioOrden), 4, '0');
            LET ctransCargoEnvioComision   = LPAD(TRIM(ctransCargoEnvioComision), 4, '0');
            LET ctransCargoEnvioIVA        = LPAD(TRIM(ctransCargoEnvioIVA), 4, '0');  
            LET ctransEfecPagoOrden        = LPAD(TRIM(ctransEfecPagoOrden), 4, '0');
            LET ctransEfecCancelacionOrden = LPAD(TRIM(ctransEfecCancelacionOrden), 4, '0');
            LET cTransCargoSky             = LPAD(TRIM(cTransCargoSky), 4, '0');
            LET cTransEfecSky              = LPAD(TRIM(cTransEfecSky), 4, '0');   
            IF dFechaIni > cFecha_hoy THEN
               LET cCodRet = "00001";
               RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
            ELSE
              
                FOREACH Curini FOR
                     /* Se agrega nombre al Foreach, se acomodan los filtros y se agrega un d.empresa = '001', que faltaba*/
                     SELECT b.folio_suc, f.numcategoria||f.numconvenio AS numconvenio,f.nomconvenio, b.referencia1, b.referencia2, b.forma_pago, e.nombre, b.importe_pago, b.usuario, b.cuenta_cargo, f.trans_cen_cargo_cliente, f.trans_cen_efectivo_cliente, f.proceso_automatico,
                           f.nombre_referencia1, f.nombre_referencia2
                      INTO cFolioSuc, cIdConvenio, cNomconvenio,cReferencia1, cReferencia2, cFormaPago, cRegion, mImporteTotal, cOperador, cCuentaCargo, cTransCargo, cTransEfec, 
                           siProcesoAutomatico, cIdReferencia1, cIdReferencia2
                      FROM bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e, bdisac:sac_convenios f
                     WHERE b.numcategoria = f.numcategoria
                       AND b.numconvenio = f.numconvenio
                       AND b.id_sucursal = cSucursal 
                       AND b.status_cancelado <> 'S'
                       AND b.fecha_pago  = dFechaIni
                       AND c.sucursal = b.id_sucursal
                       AND d.plaza = c.plaza
                       AND d.empresa = '001'  
                       AND e.regional = d.regional
                       AND e.empresa = '001'
                     ORDER BY folio_suc

                     IF siProcesoAutomatico = 1 THEN
                        IF cFormaPago = '1' THEN
                           LET mCargoEfectivo = mImporteTotal;
                           LET mCargoCuenta = 0;

                        ELIF cFormaPago = '2' OR cFormaPago = '4' THEN
                             LET mCargoCuenta = mImporteTotal;
                             LET mCargoEfectivo = 0;

                        ELIF cFormaPago = '3' OR cFormaPago = '5' THEN
                             IF dFechaIni >= cCconsmovhis THEN

                                /*Se unificaron queries(3) en 1*/ 
                                SELECT NVL(SUM(CASE WHEN transacc = cTransEfec  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                       NVL(SUM(CASE WHEN transacc = cTransCargo THEN monto_tot ELSE 0 END), 0) AS totCargo
                                  INTO mCargoEfectivo, mCargoCuenta
                                  FROM bdicheq:sc_movhis
                                 WHERE empresa   = '001'
                                   AND fech_alt  = dFechaIni
                                   AND sucursal  = cSucursal
                                   AND folio_suc = cFolioSuc
                                   AND transacc IN (cTransEfec, cTransCargo);
  
                             ELSE
                                /*Se unificaron queries(4) en 1*/ 
                                SELECT NVL(SUM(CASE WHEN transacc = cTransEfec  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                       NVL(SUM(CASE WHEN transacc = cTransCargo THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                  INTO mCargoEfectivo, mCargoCuenta
                                  FROM bdicheq:sc_movhis_old
                                 WHERE empresa = '001'
                                   AND fech_alt = dFechaIni
                                   AND sucursal = cSucursal
                                   AND folio_suc = cFolioSuc
                                   AND transacc in (cTransEfec,cTransCargo);  

                             END IF;
                             IF cIdConvenio = '08001' THEN

                                SELECT NVL(TRIM(valor),'')
                                  INTO cTranCredPGDF 
                                  FROM bdisac:sac_param 
                                 WHERE cod_param = '87033';
 
                                /*Se quito MULTISET porque es inecesario*/
                                SELECT NVL(SUM(monto), 0) AS totCargo
                                  INTO mCargoCuenta
                                  FROM bdicred:sd_movhis
                                 WHERE fecha_mov    = dFechaIni
                                   AND sucursal     = cSucursal
                                   AND folio_suc    = cFolioSuc
                                   AND transacc_suc = cTranCredPGDF;   
                             END IF;
 		
 		                     --HOMOLOGACION CLUB DE PROTECCION
                             IF cIdConvenio = '01002' THEN
                                SELECT NVL(TRIM(valor),'')
                                  INTO cTranCredPCP 
                                  FROM bdisac:sac_param 
                                 WHERE cod_param = 80;

                                SELECT NVL(SUM(monto), 0) AS totCargo
                                  INTO mCargoCuenta
                                  FROM bdicred:sd_movhis
                                 WHERE fecha_mov= dFechaIni AND sucursal = cSucursal AND folio_suc = cFolioSuc;
                             END IF;
                             IF	cIdConvenio = '03001' THEN

                                SELECT NVL(TRIM(valor),'')
                                  INTO cTranCredPTAE 
                                  FROM bdisac:sac_param 
                                 WHERE cod_param = 20;

                                SELECT NVL(SUM(monto), 0) AS totCargo
                                  INTO mCargoCuenta
                                  FROM bdicred:sd_movdia
                                 WHERE folio_suc = cFolioSuc AND empresa='001';
                             END IF;
 	
                             IF	cIdConvenio = '08002' THEN

                                SELECT NVL(TRIM(valor),'')
                                  INTO cTranCredEDOMEX 
                                  FROM bdisac:sac_param 
                                 WHERE cod_param = 23;

                                SELECT NVL(SUM(monto), 0) AS totCargo
                                  INTO mCargoCuenta
                                  FROM bdicred:sd_movdia
                                 WHERE folio_suc = cFolioSuc AND empresa='001';
                             END IF;
 		
                        END IF;
 	
                     ELSE		
                        SELECT valor
                          INTO cIdReferencia1
                          FROM bdisac:sac_param
                         WHERE empresa='001' AND cod_param= '6' || cIdConvenio || '1';

                        SELECT valor
                          INTO cIdReferencia2
                          FROM bdisac:sac_param
                         WHERE empresa='001' AND cod_param= '6' || cIdConvenio || '2'; 

                        IF cFormaPago = '1' AND cIdConvenio <> '07001' THEN
                           LET mCargoEfectivo = mImporteTotal;
                           LET mCargoCuenta = 0;

                        ELIF cFormaPago = '2' AND cIdConvenio <> '07001' THEN
                           LET mCargoCuenta = mImporteTotal;
                           LET mCargoEfectivo = 0;

                        ELIF cFormaPago = '3' OR cIdConvenio = '07001' THEN
                            IF dFechaIni >= cCconsmovhis THEN
                               IF cIdConvenio = '01001' THEN 
                                  
                                  /*Se unificaron queries(5) en 1*/ 
                                  SELECT NVL(SUM(CASE WHEN transacc = cTransEfecCoppel  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                         NVL(SUM(CASE WHEN transacc = cTransCargoCoppel THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                    INTO mCargoEfectivo, mCargoCuenta
                                    FROM bdicheq:sc_movhis
                                   WHERE empresa = '001'
                                     AND fech_alt = dFechaIni
                                     AND sucursal = cSucursal
                                     AND folio_suc = cFolioSuc
                                     AND transacc in (cTransEfecCoppel, cTransCargoCoppel);  

                               ELIF cIdConvenio = '02001' THEN

                                    /*Se unificaron queries(6) en 1*/ 
 	                                SELECT NVL(SUM(CASE WHEN transacc = cTransEfecTelmex  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                           NVL(SUM(CASE WHEN transacc = cTransCargoTelmex THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                      INTO mCargoEfectivo, mCargoCuenta
                                      FROM bdicheq:sc_movhis
                                     WHERE empresa = '001'
                                       AND fech_alt = dFechaIni
                                       AND sucursal = cSucursal
                                       AND folio_suc = cFolioSuc
                                       AND transacc in (cTransEfecTelmex, cTransCargoTelmex); 

                               ELIF cIdConvenio = '06001' THEN

                                    /*Se unificaron queries(7) en 1*/ 
                                    SELECT NVL(SUM(CASE WHEN transacc = cTransEfecSky  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                           NVL(SUM(CASE WHEN transacc = cTransCargoSky THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                      INTO mCargoEfectivo, mCargoCuenta
                                      FROM bdicheq:sc_movhis
                                     WHERE empresa = '001'
                                       AND fech_alt = dFechaIni
                                       AND sucursal = cSucursal
                                       AND folio_suc = cFolioSuc
                                       AND transacc in (cTransEfecSky, cTransCargoSky);   

                               ELIF cIdConvenio = '07001' THEN
                                    LET mImporteTotal = 0;

                                    FOREACH CurD FOR
                                         SELECT NVL(SUM(importe_total),0) 
                                           INTO mImporteTotal 
                                           FROM bdisac:sac_enviosdineroya
                                          WHERE no_control = cReferencia1 AND estatus IS NOT NULL
                                         UNION ALL
                                         SELECT NVL(SUM(importe_total),0)
                                           FROM bdisac:sac_enviosdineroyahis
                                          WHERE no_control = cReferencia1 AND estatus IS NOT NULL 
                                          ORDER BY 0
 	
                                         IF cFormaPago = '1' THEN
                                            LET mCargoEfectivo = mImporteTotal;
                                            LET mCargoCuenta = 0;

                                         ELIF cFormaPago = '2' THEN
                                              LET mCargoCuenta = mImporteTotal;
                                              LET mCargoEfectivo = 0;

                                         ELIF cFormaPago = '3' THEN
                                              SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                                INTO mCargoEfectivo
                                                FROM bdicheq:sc_movhis
                                               WHERE empresa = '001'
                                                 AND fech_alt = dFechaIni
                                                 AND transacc IN (ctransEfecEnvioOrden, ctransEfecEnvioComision, ctransEfecEnvioIVA)
                                                 AND sucursal = cSucursal
                                                 AND folio_suc = cFolioSuc;

                                              SELECT NVL(SUM(monto_tot), 0) AS totCargo
                                                INTO mCargoCuenta
                                                FROM bdicheq:sc_movhis
                                               WHERE empresa = '001'
                                                 AND fech_alt = dFechaIni
                                                 AND transacc IN (ctransCargoEnvioOrden, ctransCargoEnvioComision, ctransCargoEnvioIVA)
                                                 AND sucursal = cSucursal
                                                 AND folio_suc = cFolioSuc;

                                         END IF;
                                    END FOREACH;
				                    LET cReferencia1='********'||SUBSTRING (cReferencia1 FROM 9 FOR 4);

                               ELIF cIdConvenio = '07002' THEN
                                    LET mCargoCuenta = 0;

                                    SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                      INTO mCargoEfectivo
                                      FROM bdicheq:sc_movhis
                                     WHERE empresa = '001'
                                       AND fech_alt = dFechaIni
                                       AND transacc = ctransEfecPagoOrden
                                       AND sucursal = cSucursal
                                       AND folio_suc = cFolioSuc;

                               ELIF cIdConvenio = '07003' THEN
                                    LET mCargoCuenta = 0;

                                    SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                      INTO mCargoEfectivo
                                      FROM bdicheq:sc_movhis
                                     WHERE empresa = '001'
                                       AND fech_alt = dFechaIni
                                       AND transacc = ctransEfecCancelacionOrden
                                       AND sucursal = cSucursal
                                       AND folio_suc = cFolioSuc;
                               END IF;
                            ELSE
                               IF cIdConvenio = '01001' THEN

                                 /*Se unificaron queries(8) en 1*/ 
                                  SELECT NVL(SUM(CASE WHEN transacc = cTransEfecCoppel  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                         NVL(SUM(CASE WHEN transacc = cTransCargoCoppel THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                    INTO mCargoEfectivo, mCargoCuenta
                                    FROM bdicheq:sc_movhis_old
                                   WHERE empresa = '001'
                                     AND fech_alt = dFechaIni
                                     AND sucursal = cSucursal
                                     AND folio_suc = cFolioSuc
                                     AND transacc in (cTransEfecCoppel, cTransCargoCoppel);   

                               ELIF cIdConvenio = '02001' THEN

                                   /*Se unificaron queries(9) en 1*/ 
                                    SELECT NVL(SUM(CASE WHEN transacc = cTransEfecTelmex  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                           NVL(SUM(CASE WHEN transacc = cTransCargoTelmex THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                      INTO mCargoEfectivo, mCargoCuenta
                                      FROM bdicheq:sc_movhis_old
                                     WHERE empresa = '001'
                                       AND fech_alt = dFechaIni
                                       AND sucursal = cSucursal
                                       AND folio_suc = cFolioSuc
                                       AND transacc in (cTransEfecTelmex, cTransCargoTelmex); 

                               ELIF cIdConvenio = '06001' THEN
                                 
                                    /*Se unificaron queries(10) en 1*/ 
                                    SELECT NVL(SUM(CASE WHEN transacc = cTransEfecSky  THEN monto_tot ELSE 0 END), 0) AS totEfectivo,
                                           NVL(SUM(CASE WHEN transacc = cTransCargoSky THEN monto_tot ELSE 0 END), 0) AS totCargo  
                                      INTO mCargoEfectivo, mCargoCuenta
                                      FROM bdicheq:sc_movhis_old
                                     WHERE empresa = '001'
                                       AND fech_alt = dFechaIni
                                       AND sucursal = cSucursal
                                       AND folio_suc = cFolioSuc
                                       AND transacc in (cTransEfecSky, cTransCargoSky);    
                               ELIF cIdConvenio = '07001' THEN
                                    LET mImporteTotal = 0;

                                    FOREACH CurDet FOR
                                          SELECT NVL(SUM(importe_total),0) 
                                            INTO mImporteTotal 
                                            FROM bdisac:sac_enviosdineroya
                                           WHERE no_control = cReferencia1 AND estatus IS NOT NULL
                                           UNION ALL
                                          SELECT NVL(SUM(importe_total),0)
                                            FROM bdisac:sac_enviosdineroyahis
                                           WHERE no_control = cReferencia1 AND estatus IS NOT NULL 
                                           ORDER BY 0
 	
                                          IF cFormaPago = '1' THEN
                                             LET mCargoEfectivo = mImporteTotal;
                                             LET mCargoCuenta = 0;
                                          ELIF cFormaPago = '2' OR cFormaPago = '4' THEN
                                             LET mCargoCuenta = mImporteTotal;
 	                                         LET mCargoEfectivo = 0;
                                          ELIF cFormaPago = '3' THEN

                                             SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                               INTO mCargoEfectivo
                                               FROM bdicheq:sc_movhis_old
                                              WHERE empresa = '001'
                                                AND fech_alt = dFechaIni
                                                AND transacc IN (ctransEfecEnvioOrden, ctransEfecEnvioComision, ctransEfecEnvioIVA)
                                                AND sucursal = cSucursal
                                                AND folio_suc = cFolioSuc;

                                             SELECT NVL(SUM(monto_tot), 0) AS totCargo
                                               INTO mCargoCuenta
                                               FROM bdicheq:sc_movhis_old
                                              WHERE empresa = '001'
                                                AND fech_alt = dFechaIni
                                                AND transacc IN (ctransCargoEnvioOrden, ctransCargoEnvioComision, ctransCargoEnvioIVA)
                                                AND sucursal = cSucursal
                                                AND folio_suc = cFolioSuc;

 		                                  END IF;
 	                                END FOREACH;
                                    LET cReferencia1='********'||SUBSTRING (cReferencia1 FROM 9 FOR 4);

                               ELIF cIdConvenio = '07002' THEN
                                    LET mCargoCuenta = 0;
                       
                                    SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                      INTO mCargoEfectivo
                                      FROM bdicheq:sc_movhis_old
                                     WHERE empresa = '001'
                                       AND fech_alt = dFechaIni
                                       AND transacc = ctransEfecPagoOrden
                                       AND sucursal = cSucursal
                                       AND folio_suc = cFolioSuc;

                               ELIF cIdConvenio = '07003' THEN
                                    LET mCargoCuenta = 0;

                                    SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                      INTO mCargoEfectivo
                                      FROM bdicheq:sc_movhis_old
                                     WHERE empresa = '001'
                                       AND fech_alt = dFechaIni
                                       AND transacc = ctransEfecCancelacionOrden
                                       AND sucursal = cSucursal
                                       AND folio_suc = cFolioSuc;
                        
                               END IF;
                            END IF;
                 /* Se comenta porque realmente no hace nada*/  
                 /*   IF cIdConvenio = '07001' THEN

                    END IF*/
			      END IF;
                END IF;
                LET siCiclo = siCiclo + 1;

                -- PAGINACION
                IF siCiclo <= siRegistros THEN
                   CONTINUE FOREACH;
                END IF;

                RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo
                WITH RESUME;
                END FOREACH;

            END IF
        END IF;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener lo movimientos de la cobranza de pago de servicios para una fecha especifica',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Noviembre 2009',
'VERSION: 20091207.1305',
'BD    : bdisac',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Se agregan validaciones para que contemple los movimientos para ordenes de pago',
'VERSION DE CAMBIO: 20100420.1659',
'MODIFICA : Dulce Ramirez',
'DESCRIPCION: Se agrega SUM al campo importe_total, para que no regrese valor nulo en caso de no encontrar registro',
'VERSION DE CAMBIO: 20100507.1245',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Se corrige para que obtenga correctamente los totales de los historicos',
'VERSION DE CAMBIO: 20100512.0838',
'MODIFICA : Dulce Ramirez',
'DESCRIPCION: Se agregan validaciones para que contemple los movimientos para pagos sky',
'VERSION DE CAMBIO: 20100521.1719',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Junto con la integracion de Pagos MVS se integra la modificacion para los convenios en proceso automatico para su funcionamiento dinamico',
'VERSION DE CAMBIO: 20100923.1843',
'MODIFICA : Dulce RamÃ­rez',
'DESCRIPCION: Se modifica para incluir la forma de pago 4 "Abono en cuenta" para pago de remesas BTS',
'VERSION DE CAMBIO: 20100923.1843',
'                                    ',
'MODIFICA : MartÃ­n Eduardo Miranda',
'DESCRIPCION: Se agrega nuevo retorno "cIdConvenio" para ordenar el reporte diario de Servicios por sucursal',
'VERSION DE CAMBIO: 20120830.1629',

'MODIFICA : Martha Aguirre',
'DESCRIPCION: Se agrega bÃºsqueda de monto para el movimiento de cargo en cuenta de crÃ©dito para el cIdConvenio 8001',
'             "Pago de Servicios del Gobierno del Distrito Federal',
'VERSION DE CAMBIO: 20130109.1030',
'Folio:1570',
'Autor:95142134 Mario Gallardo',
'Fecha:24/01/2014',
'ModificaciÃ³n: Se modifica referencia1 y referencia2 a 40 carcateres.',
'Sustento: RQI 62 064-ReingenierÃ­a_PagoServicios -  (Pagina 2 a 36)',
'Solicita: Jaime Gonzalez',
'BD: bdisac',
'MODIFICA : Rigoberto Gonzalez Llanes',
'DESCRIPCION: Se agrega bÃºsqueda de monto para el movimiento de cargo en cuenta de crÃ©dito para el cIdConvenio 01002',
'             "Pago de Servicios del club de proteccion coppel',
'VERSION DE CAMBIO: 20140902.1358',
'MODIFICA : Jesus Isaias Bueno',
'DESCRIPCION: Se agrega bÃºsqueda de monto para el movimiento de cargo en cuenta de crÃ©dito para el cIdConvenio 03001',
'             para el pago de TAE',
'VERSION DE CAMBIO: 20150123.1120',
'MODIFICA : Jesus Isaias Bueno',
'DESCRIPCION: Se agrega bÃºsqueda de monto para el movimiento de cargo en cuenta de crÃ©dito para el cIdConvenio 08002',
'             para el pago se servicios EDOMEX',
'VERSION DE CAMBIO: 20150217.1204';

CREATE PROCEDURE "informix".sp_busquedacteremesa_identificacion(pNumIdentificacion CHAR(30))
RETURNING
CHAR(5)  AS  cCodRet,
CHAR(20) AS  cNumcte,
CHAR(1)  AS  iTipoCliente,
CHAR(5)  AS	 cValIne,
CHAR(5)  AS	 cListaNegra,
CHAR(5)	 AS	 cSespecial;

DEFINE cCodRet 		CHAR(5);
DEFINE cNumcte		CHAR(20);
DEFINE iTipoCliente	CHAR(1);
DEFINE cValIne		CHAR(5);
DEFINE cResultINE	CHAR(50);
DEFINE cListaNegra	CHAR(5);
DEFINE cSespecial	CHAR(5);
DEFINE cStatuscte	CHAR(1);

DEFINE iSqlErr      INTEGER; 
DEFINE iIsamErr    	INTEGER; 
DEFINE cInfoErr 	CHAR(10); 

DEFINE icontEsp 	INTEGER;
DEFINE iContList	INTEGER;

--EPG
DEFINE cSituacion   CHAR(5);
DEFINE cCausa       CHAR(5);
DEFINE cRfc			CHAR(13);
DEFINE iContListRfc	INTEGER;

LET cCodRet	= "00000";
LET cNumcte = "0";
LET iTipoCliente = "0";
LET cValIne = "False";
LET cListaNegra = "False";
LET cSespecial = "False";
LET cStatuscte = "";
LET icontEsp 	 = 0;
LET iContList 	 = 0;

LET pNumIdentificacion = TRIM(pNumIdentificacion);

--EPG
LET cSituacion  = '';
LET cCausa      = '';
LET cRfc 		= '';
LET iContListRfc = 0;


--SET DEBUG FILE TO '/home/c90303528/sp_busquedacteremesa_identificacion.log';
--TRACE ON;	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
		END IF;
	END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT FIRST 1  cterem.numcte, "1", cterem.status_cte, cte.rfc
	INTO cNumcte, iTipoCliente, cStatuscte, cRfc
	FROM bdinteg:"informix".si_cliente cte INNER JOIN
	bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte INNER JOIN
	bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
	WHERE ctepf.numidentifi = pNumIdentificacion;
			
	IF NVL(cNumcte,"") = "" THEN
		SELECT FIRST 1 cte.numcte, "2", cte.rfc
		INTO cNumcte, iTipoCliente, cRfc
		FROM bdinteg:"informix".si_cliente cte INNER JOIN
		bdinteg:"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte 
		WHERE ctepf.numidentifi = pNumIdentificacion AND cte.tipo_cliente in("1","2");
		
		IF NVL(cNumcte,"") = "" THEN
			LET cNumcte = "000000000";
			LET iTipoCliente = "3";
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
		END IF;
	ELSE
		IF TRIM(cStatuscte) <> "A" THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
		END IF;
	END IF;
	
	SELECT resultado 
	INTO cResultINE
	FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = cNumcte AND fecha = (SELECT MAX(fecha) FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = cNumcte);
	
	IF (TRIM(NVL(cResultINE,"")) = "") OR (UPPER(TRIM(cResultINE)) = "VERDADERO") OR (UPPER(TRIM(cResultINE)) = "TRUE") THEN
		LET cValIne = "True";
	ELIF (UPPER(TRIM(cResultINE)) = "FALSO") OR (UPPER(TRIM(cResultINE)) = "FALSE") THEN
		LET cValIne = "False";
	END IF;
	
  --IF EXISTS(SELECT * FROM bdiauditor:"informix".tbl_listainterna WHERE numcte = pNumCte) THEN
	SELECT COUNT(*) INTO iContList FROM bdiauditor:"informix".tbl_listainterna  WHERE numcte = cNumCte;
	SELECT COUNT(*) INTO iContListRfc FROM bdiauditor:"informix".tbl_listainterna  WHERE rfc = cRfc;
	LET iContList = iContList + iContListRfc;
	IF iContList > 0 THEN
		LET cListaNegra = "True";
	ELSE
		LET cListaNegra = "False";
	END IF;
	
  --IF EXISTS(SELECT * FROM bdisitesp:"informix".se_ctessitespcte where numcte = pNumCte) THEN
	SELECT COUNT(*) INTO icontEsp FROM bdisitesp:"informix".se_ctessitespcte where numcte = cNumCte;
	IF icontEsp > 0 THEN
		SELECT situacion, causa INTO cSituacion, cCausa FROM bdisitesp:"informix".se_ctessitespcte where numcte = cNumCte;
		LET cSituacion = TRIM(cSituacion)||TRIM(cCausa);
		IF 	cSituacion IN ('F42','P72','P108','U60') THEN
			LET cSespecial = "True";
		ELSE
			LET cSespecial = "False";
		END IF;
	ELSE
		LET cSespecial = "False";
	END IF;
	
	
	RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
	
END;
END PROCEDURE
DOCUMENT
'Folio: 433 REQ. Base de datos para el alta de usuarios de remesas',
'Autor: 98243217 Marco Rivera ',
'Fecha: 16/08/2018',
'Descripcion: Verifica e identifica el tipo de cliente realizando la busqueda por numero de identificacion.',
'Solicita: Leonardo Hernandez',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------',
'Folio: 496',
'Autor: 98243217 Marco Rivera ',
'Fecha: 23/10/2018',
'Descripcion: Se agrega validacion para la busqueda en si_bitacora_ife.',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_pago_remesas_cpl(
	pSucursal   		CHAR (4),
	pCategoria      	CHAR (2),
	pConvenio      		CHAR (5),
	pRefUno        		CHAR (20),
	pRefDos        		CHAR (20),
	pFormaPago     		CHAR (1),
	pMontoTotal    		DECIMAL (10,2),
	pImpComConv     	DECIMAL (6,2),
	pIvaComConv    		DECIMAL (6,2),
	pImpComCte     		DECIMAL (6,2),
	pIvaComCte     		DECIMAL (6,2),
	pNumEmp        		CHAR (8),
	pFolsuc        		CHAR (16),
	pTransSuc      		CHAR (4),
	pFechaPag      		DATE,
	pEmpresa     		CHAR (3),
	pNumcte				CHAR (9),
	pNombre1 			CHAR (40),
	pNombre2 			CHAR (40),
	pApellidoPat		CHAR (40),
	pApellidoMat		CHAR (40),
	pFechaNac			CHAR (8),
	pFechaHoy		 	CHAR (8),
	pMontoAPagar	 	CHAR (20),
	pMoneda 			CHAR (3),
	pMontoMoneda		MONEY (14,2),
	pTelefonoCasa 		CHAR (10),
	pTelefonoCel		CHAR (10),
	pAdress				VARCHAR(80),
	pCity				VARCHAR(40),
	pStateCodeAdr		VARCHAR(3),
	pZipCode 			VARCHAR(10),
	pCanalOrigen		CHAR(4),
	pCajaOrigen			CHAR(2),
	pSucursalOrigen		CHAR(4),
	pFolioOrigen		CHAR(16),
	pCodigoEstadoSuc	CHAR(20),
	pOcupacion        	CHAR(3),
	pParentesco       	CHAR(3),
	pRazonEnvio       	CHAR(3)
	)

	RETURNING CHAR (5) AS RetCode, CHAR (2) AS IdentificadorProceso, CHAR (5) AS RetCode2, CHAR(5) AS TransaccInt, CHAR(5) AS TransServicio, CHAR(2) AS NumIntentos, CHAR(3) AS ApprizaCode, CHAR(3) AS ChannelId, CHAR(15) AS LocationUnit, CHAR(3) AS TypeCode, CHAR(3) AS StateCode, CHAR(3) AS CountryCode, CHAR(3) AS Nacionalidad,CHAR(9) AS Numcte,CHAR(3) AS EstadoBenef , CHAR(20) AS TaxIdentificationNumber, CHAR(8) AS SupervisorId, CHAR(3) AS ProofOfDomicileTypeCode, CHAR(40) AS ProofOfDomicileDescription, CHAR(40) AS ProofOfDomicileReferenceNumber ,
	CHAR(300) AS BiometricAuthentication, CHAR(1) AS Genero, CHAR(20) AS UniqueResidentNumber ;

	-- Definicion de variables --
	DEFINE cTaxIdentificationNumber			CHAR(20);		--Datos nuevos para TN
	DEFINE cSupervisorId					CHAR(8);		--Datos nuevos para TN
	DEFINE cProofOfDomicileTypeCode			CHAR(3);		--Datos nuevos para TN
	DEFINE cProofOfDomicileDescription		CHAR(40);		--Datos nuevos para TN
	DEFINE cProofOfDomicileReferenceNumber	CHAR(40);		--Datos nuevos para TN
	DEFINE cBiometricAuthentication			CHAR(300);		--Datos nuevos para TN
	DEFINE cGenero							CHAR(1);		--Datos nuevos para TN
	DEFINE cUniqueResidentNumber			CHAR(20);		--Datos nuevos para TN

	DEFINE cNacionalidad		CHAR(3);	--campos nuevos
	DEFINE cEstadoBenef			CHAR(3);	--campos nuevos
	DEFINE cIdEstadoBenef		CHAR(3);
	DEFINE cYear					CHAR(4);
	DEFINE cDay				CHAR(4);
	DEFINE cMonth					CHAR(4);
	DEFINE cDoB DATE;
	DEFINE cIdNacionalidad		CHAR(3);
	DEFINE cTipoCliente			CHAR(2);
	DEFINE cValIne				CHAR(5);
	DEFINE cListaNegra			CHAR(5);
	DEFINE cSespecial			CHAR(5);

	DEFINE cCodErr 				 CHAR (5);
	DEFINE cIdentificadorProceso CHAR (2);
	DEFINE cRetCode2			 CHAR (5);
	DEFINE cFlagTelCel			 CHAR (1);
	DEFINE cFlagTelCasa			 CHAR (1);
	DEFINE cFlagTelOficina		 CHAR (1);
	DEFINE cCuenta				 CHAR(20);
	DEFINE cNoCte				 CHAR(20);
	DEFINE cApellPaterno		 CHAR(26);
	DEFINE cApellMaterno		 CHAR(26);
	DEFINE cNombre1				 CHAR(26);
	DEFINE cNombre2				 CHAR(26);
	DEFINE cRazonSocial		 	 CHAR(60);
	DEFINE cStatusCuenta	 	 CHAR(1);
	DEFINE mSdoDisponible	 	 MONEY(14,2);
	DEFINE mSdoRetenido		 	 MONEY(14,2);
	DEFINE mSdoCCC			 	 MONEY(14,2);
	DEFINE mSdoCCCDisp		 	 MONEY(14,2);
	DEFINE mSdoCuenta		 	 MONEY(14,2);
	DEFINE cTipoLinea		 	 CHAR(1);
	DEFINE cDescripcion1	 	 CHAR(40);
	DEFINE cDescripcion2	 	 CHAR(40);
	DEFINE mSaldoT1			 	 MONEY(14,2);
	DEFINE mSdoCongelado	 	 MONEY(14,2);
	DEFINE mSdoSBC			 	 MONEY(14,2);
	DEFINE cUsuarioBloqueo	 	 CHAR(8);
	DEFINE dFechaBloqueo	 	 DATE;
	DEFINE cCuentaClave		 	 CHAR(18);
	DEFINE dFechaExpTarjeta	 	 DATE;
	DEFINE cTranret			 	 CHAR(4);
	DEFINE dFechahoy			 DATE;
	DEFINE mSdodisp				 MONEY(14,2);
	DEFINE mMontoret			 MONEY(14,2);
	DEFINE cDescripcion			 CHAR(200);
	DEFINE iSqlErr               INTEGER;
	DEFINE cNoTarjeta			 CHAR(16);
	DEFINE dFecha			 	 DATE;
	DEFINE cTransaccInt			 CHAR(5);
	DEFINE cTransServicio		 CHAR(5);
	DEFINE cNumIntentos			 CHAR(2);
	DEFINE cApprizaCode			 CHAR(3);
	DEFINE cChannelId		     CHAR(3);
	DEFINE cLocationUnit	     CHAR(15);
	DEFINE cTypeCode			 CHAR(3);
	DEFINE cStateCode		     CHAR(3);
	DEFINE cCountryCode	         CHAR(3);
	DEFINE cFechaHoy			 CHAR(8);
	DEFINE cFechaNac			 CHAR(8);
	DEFINE vtransaccion			 SMALLINT;
	DEFINE v_fecha_nac 			 DATE;
	DEFINE vCuenta				 INTEGER;
	DEFINE cCodErrAux			 CHAR(6);
	DEFINE vCentroCostosHrem     CHAR(4);
	DEFINE cMes 				 CHAR(2);
	DEFINE cDia 				 CHAR(2);
	DEFINE cAnio				 CHAR(4);
	DEFINE cRfc 				 CHAR(13);
	DEFINE cValidaPLDteldom 	 INTEGER;
	DEFINE pHoraOrigen      	 CHAR(6);
	DEFINE cDesc_error        	 CHAR(150);
	DEFINE cPaisOrigen          CHAR(3);
	DEFINE iCodPais             CHAR(3);
	DEFINE iValPais             INTEGER;




	-- Inicializacion de variables --
	LET cTaxIdentificationNumber = 'BSI061110963';			--Datos nuevos para TN
	LET cSupervisorId = '';						--Datos nuevos para TN
	LET cProofOfDomicileTypeCode = '';			--Datos nuevos para TN
	LET cProofOfDomicileDescription = '';		--Datos nuevos para TN
	LET cProofOfDomicileReferenceNumber = '';	--Datos nuevos para TN
	LET cBiometricAuthentication = '';			--Datos nuevos para TN
	LET cGenero = '';							--Datos nuevos para TN
	LET cUniqueResidentNumber='';				--Datos nuevos para TN
	
	
	LET cNacionalidad				= "";		--campos nuevos
	LET cEstadoBenef				= "";		--campos nuevos
	LET cIdNacionalidad				= "";
	LET cIdEstadoBenef				= "";
	LET cYear= "";
	LET cDay = "";
	LET cMonth  ="";
	LET cDoB = "";

	LET cTipoCliente				= "";
	LET cValIne						= "";
	LET cListaNegra					= "";
	LET cSespecial					= "";

	LET cCodErr 					= "00000";
	LET cIdentificadorProceso		= "00";
  	LET cRetCode2 					= "00000";
	LET cFlagTelCel					= "1";
	LET cFlagTelCasa				= "1";
	LET cFlagTelOficina				= "1";
	LET cDescripcion  				= "";
	LET iSqlErr						= 0;
	LET cNoTarjeta 					= "";
	LET cNoCte						= "";
	LET	cTransaccInt				= "";
	LET	cTransServicio	        	= "";
	LET	cNumIntentos		    	= "";
	LET	cApprizaCode		    	= "";
	LET	cChannelId		        	= "";
	LET	cLocationUnit	        	= "";
	LET	cTypeCode		        	= "";
	LET	cStateCode		        	= "";
	LET	cCountryCode		    	= "";
	LET cFechaHoy					= "";
	LET cFechaNac					= "";
	LET vtransaccion				= 0;
	LET cCodErrAux					= "000000";

	-- Validar que ningun parametro obligatorio este vacio --
	LET pSucursal   		= NVL(pSucursal, "");
	LET pCategoria      	= NVL(pCategoria, "");
	LET pConvenio      		= NVL(pConvenio, "");
	LET pRefUno        		= NVL(pRefUno, "");
	LET pRefDos        		= NVL(pRefDos, "");
	LET pFormaPago     		= NVL(pFormaPago, "");
	LET pMontoTotal    		= NVL(pMontoTotal, 0);
	LET pImpComConv     	= NVL(pImpComConv, 0);
	LET pIvaComConv    		= NVL(pIvaComConv, 0);
	LET pImpComCte     		= NVL(pImpComCte, 0);
	LET pIvaComCte     		= NVL(pIvaComCte, 0);
	LET pNumEmp        		= NVL(pNumEmp, "");
	LET pFolsuc        		= NVL(pFolsuc, "");
	LET pTransSuc      		= NVL(pTransSuc, "");
	LET pFechaPag      		= NVL(pFechaPag, "");
	LET pEmpresa     		= NVL(pEmpresa, "");
	LET pNombre1 			= NVL(pNombre1, "");
	LET pNombre2 			= NVL(pNombre2, "");
	LET pApellidoPat		= NVL(pApellidoPat, "");
	LET pApellidoMat		= NVL(pApellidoMat, "");
	LET pFechaNac			= NVL(pFechaNac, "");
	LET pFechaHoy 			= NVL(pFechaHoy, "");
	LET pMontoAPagar 		= NVL(pMontoAPagar, "");
	LET pMoneda 			= NVL(pMoneda, "");
	LET pMontoMoneda		= NVL(pMontoMoneda, 0);
	LET pTelefonoCasa 		= NVL(pTelefonoCasa, "");
	LET pTelefonoCel 		= NVL(pTelefonoCel, "");
	LET pAdress				= NVL(pAdress, "");
	LET pCity				= NVL(pCity, "");
	LET pStateCodeAdr		= NVL(pStateCodeAdr, "");
	LET pZipCode 			= NVL(pZipCode, "");
	LET vCentroCostosHrem = (SELECT trim(valor) FROM "informix".sac_param WHERE cod_param =87119);
	LET cDia	= '';
  	LET cMes	= '';
  	LET cAnio	= '';
	LET cRfc	= '';
	LET cValidaPLDteldom	= 0;
	LET cDesc_error 			 = '';
	LET cPaisOrigen              = '';
	LET iCodPais                 = '';
	LET iValPais                 = 0;
	LET dFecha=CURRENT;



	LET pHoraOrigen =(SELECT replace(substr(current,12,8),':','') FROM bdisac:sac_fechas);

  --SET DEBUG FILE TO "/home/c90307738/cpl/sp_pago_remesas_cpl.log";
  --TRACE ON;

  SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodErr = iSqlErr;
				RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode,cNacionalidad, pNumcte, cEstadoBenef, cTaxIdentificationNumber, cSupervisorId,  cProofOfDomicileTypeCode, cProofOfDomicileDescription, cProofOfDomicileReferenceNumber ,  cBiometricAuthentication, cGenero, cUniqueResidentNumber;
				LET cDesc_error = 'Error no controlado';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
				RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode,cNacionalidad, pNumcte, cEstadoBenef, cTaxIdentificationNumber, cSupervisorId,  cProofOfDomicileTypeCode, cProofOfDomicileDescription, cProofOfDomicileReferenceNumber ,  cBiometricAuthentication, cGenero, cUniqueResidentNumber;
			END IF;
		END EXCEPTION;

		ON exception in (-535)
			let vtransaccion = 1;
		END exception with resume;
		IF vtransaccion = 1 then
			COMMIT WORK;
		END IF;

   BEGIN WORK;
			--Validacion Paises Permitidos
		SELECT LIMIT 1 r_countrycode INTO cPaisOrigen FROM sac_app_qryi WHERE fecha >= today AND txn_status = 'A' AND r_countrycode <> '' AND r_code = '0000' AND unirefnum = pRefUno;
		IF cPaisOrigen = '' OR cPaisOrigen IS NULL THEN
			LET cCodErr = "00001";
			LET cIdentificadorProceso = "11";
			LET cRetCode2 = "00222";
			LET cDesc_error = 'No cuenta con registros en la sac_app_qryi';
		
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
		
			RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode,cNacionalidad, pNumcte, cEstadoBenef, cTaxIdentificationNumber, cSupervisorId,  cProofOfDomicileTypeCode, cProofOfDomicileDescription, cProofOfDomicileReferenceNumber ,  cBiometricAuthentication, cGenero, cUniqueResidentNumber;
		END IF;
		
		SELECT pais INTO iCodPais FROM sac_paises_permitidos WHERE appbts = cPaisOrigen;
		
		SELECT COUNT(*) INTO iValPais FROM bdinteg:si_paises_remesadoras WHERE id_remesadora = '1' AND id_pais = iCodPais;
		
		IF iValPais = 0 THEN
		
					LET cCodErr = "00001";
					LET cIdentificadorProceso = "10";
					LET cRetCode2 = "00222";
					LET cDesc_error = 'Pais restringido';
		
					INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
					VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);

					RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode,cNacionalidad, pNumcte, cEstadoBenef, cTaxIdentificationNumber, cSupervisorId,  cProofOfDomicileTypeCode, cProofOfDomicileDescription, cProofOfDomicileReferenceNumber ,  cBiometricAuthentication, cGenero, cUniqueResidentNumber;
		
		END IF;

		--Se valida que ninguna variable de entrada este vacia
		IF pSucursal = "" OR pCategoria = "" OR pConvenio = "" OR pRefUno = "" OR pFormaPago = "" OR pMontoTotal = 0  OR pNumEmp = "" OR pFolsuc = "" OR pTransSuc = "" OR pFechaPag = "" OR pEmpresa = "" OR pNombre1 = "" OR pApellidoPat = "" OR pFechaNac = "" OR pFechaHoy = "" OR pMontoAPagar = "" OR pMoneda = "" OR pMontoMoneda = 0 OR pTelefonoCasa = ""  OR pCodigoEstadoSuc = "" THEN
				LET cCodErr = "00001";
		ELSE

			--consultas para obtener los campos nuevos (nacionalidad,numero de cliente y estado beneficiario)
			--LET cYear= SUBSTRING(pFechaNac FROM 1 FOR 4);
			--LET cMonth = LPAD(SUBSTRING(pFechaNac FROM 5 FOR 6),2,'0');
			--LET cDay = LPAD(SUBSTRING(pFechaNac FROM 7 FOR 8),2,'0');
--
			--LET cDoB = MDY(cMonth,cDay,cYear);

			--CALL bdisac:"informix".sp_validausuarioremesa(pNombre1,pNombre2,pApellidoPat,pApellidoMat,cDoB)
			--RETURNING cRetCode2,pNumcte,cTipoCliente,cValIne,cListaNegra,cSespecial,cRFC; -- Se obtiene el numero de cliente

			--IF cRetCode2 ='00000' THEN
				SELECT  a.nacionalidad, a.sexo, b.rfc
				INTO	cIdNacionalidad, cGenero, cUniqueResidentNumber
				FROM	bdinteg:si_ctepf a
				INNER JOIN bdinteg:si_cliente b ON a.numcte=b.numcte
				WHERE 	a.numcte = pNumcte; --Se obtiene id de nacionalidad y genero del cliente

				SELECT	cve_pais
				INTO	cNacionalidad
				FROM	bdisac:sac_app_nacionalidad
				WHERE	cod_nacionalidad = cIdNacionalidad; -- Se obtiene la nacionalidad del beneficiario

				SELECT  FIRST 1 estado
				INTO	cIdEstadoBenef
				FROM	bdinteg:si_direcciones_actual
				WHERE	numcte = pNumcte
				AND 	tipo_dir='1';

				SELECT state_cd
				INTO	cEstadoBenef
				FROM 	bdisac:sac_app_catestados
				WHERE	cve_estado = cIdEstadoBenef; --Se obtiene el estado del beneficiario

				SELECT	NVL(dmapa,imapa)
				INTO	cBiometricAuthentication
				FROM	bdinteg:si_cte_huella
				WHERE	numcte=pNumcte
				AND 	estado='A';	--Se obtiene la huella del cliente
			--END IF;


			--Se validan los numeros de telefono
			--CALL bdinteg:"informix".sp_validatelefono(pEmpresa, pTelefonoCasa, pTelefonoCel, "")
			--RETURNING cRetCode2, cFlagTelCasa, cFlagTelCel, cFlagTelOficina;
			IF cFlagTelCasa <> "1" THEN
				LET cRetCode2 = "00001";
				LET cIdentificadorProceso = "08";
				LET cDesc_error = 'Telefono de casa no valido';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
			ELIF cFlagTelCel <> "1" and pTelefonoCel <> "" THEN
				LET cRetCode2 = "00002";
				LET cIdentificadorProceso = "08";
				LET cDesc_error = 'Telefono movil no valido';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
			ELSE
				--Validacion solicitada por PLD para limites de Direcciones y Telefonos ingresados en el cobro de remesas sp_sac_pldlim_teldom_cpl

				LET cDia = LPAD(SUBSTRING(pFechaHoy FROM 7 FOR 2), 2, '0');
				LET cMEs = LPAD(SUBSTRING(pFechaHoy FROM 5 FOR 2), 2, '0');
				LET cAnio = LPAD(SUBSTRING(pFechaHoy FROM 1 FOR 4), 4, '0');



					EXECUTE PROCEDURE bdisac:"informix".sp_sac_pldlim_teldom_cpl('APP',pAdress,pCity,pStateCodeAdr,pZipCode,cAnio||cMEs,pNumEmp,pTelefonoCasa,pTelefonoCel,pFolsuc,pSucursal,pRefUno,'NORMAL') INTO cRetCode2;

				IF cRetCode2 <> '00000' THEN
					--MENSAJE EN CAJA "Remesa excede limite, 1245" REMESA EXCEDE LIMITE DE DOMICILIO O TELEFONO PLD
					LET cRetCode2 = "01245";
					LET cIdentificadorProceso = "02";
					LET cCodErrAux = '999999';
					LET cDesc_error = 'Error al validar limites por telefono y domicilio';
					INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
					VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
				ELSE
					--cValidaPLDteldom es un flag qe comprueba si se ejecuto sp_sac_pldlim_teldom_cpl en caso de reversion de la operacion
					LET cValidaPLDteldom = 1;
					--Se validan los montos
					LET pFechaHoy = cMEs||cDia||cAnio;

					CALL bdisac:"informix".sp_app_valmonto_cpl(pEmpresa, pNombre1, pNombre2, pApellidoPat, pApellidoMat, pFechaNac, pFechaHoy, pMontoAPagar, pSucursal, pMoneda, pMontoMoneda, pRefUno, pCodigoEstadoSuc)
					RETURNING cCodErrAux;

					IF cCodErrAux <> "00000" THEN
						LET cRetCode2 = SUBSTRING(cCodErrAux FROM 2 FOR 5);
					ELSE
						LET cRetCode2 = cCodErrAux;
					END IF;

					IF cRetCode2 <> "00000" THEN
						LET cIdentificadorProceso = "02";
						LET cDesc_error = 'Error al validar montos / sp_app_valmonto_cpl';
						INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
						VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
					ELSE
						CALL bdisac:"informix".sp_grabapagoservicio_hs(vCentroCostosHrem, pCategoria, pConvenio, pRefUno, pRefDos, pFormapago, pMontoTotal, pImpComConv, pIvaComConv, pImpComCte, pIvaComCte, '', pNumEmp, pFolsuc, pTransSuc, pFechaPag, pCanalOrigen, pSucursalOrigen, pCajaOrigen, pTransSuc, pHoraOrigen, pFolioOrigen, pCodigoEstadoSuc, '')
						RETURNING cRetCode2;

						IF vtransaccion = 1 then
							COMMIT WORK;
							BEGIN WORK;
						ELSE
							BEGIN WORK;
						END IF;

						IF cRetCode2 <> "00000" THEN
							LET cIdentificadorProceso = "03";
							LET cDesc_error = 'Error al grabar el registro en BD / sp_grabapagoservicio_hs';
							INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
							VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
						ELSE
							LET v_fecha_nac = MDY(SUBSTRING(pFechaNac FROM 5 FOR 2), SUBSTRING(pFechaNac FROM 7 FOR 2), SUBSTRING(pFechaNac FROM 1 FOR 4));
							--Llamado a sp para actualizar datos
							IF EXISTS (SELECT * FROM sac_remesas_estadistica WHERE referencia = pRefUno AND numcategoria = pCategoria AND numconvenio  = pConvenio) THEN

								--Calculo el RFC del beneficiario
								EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(pApellidoPat, pApellidoMat, pNombre1, v_fecha_nac)
								INTO cRetCode2, cRfc;



								  UPDATE sac_remesas_estadistica
								  SET
									  nombre1        = pNombre1,
									  nombre2        = pNombre2,
									  appaterno      = pApellidoPat,
									  apmaterno      = pApellidoMat,
									  fecha_nac      = v_fecha_nac,
									  rfc            = cRfc,
									  moneda_origen  = pMoneda,
									  importe_origen = pMontoMoneda
								  WHERE  		referencia     = pRefUno
								  AND    		numcategoria = pCategoria
								  AND    		numconvenio  = pConvenio;

				        COMMIT;

								CALL bdisac:"informix".sp_confpagoservicio(vCentroCostosHrem, pCategoria, pConvenio, pRefUno, pRefDos, pFolsuc)
								RETURNING cRetCode2, cDescripcion;

							ELSE

								LET cRetCode2 = "90001";
								LET cIdentificadorProceso = "09";

							END IF;
							IF cRetCode2 <> "00000" THEN
								LET cIdentificadorProceso = "04";
							ELSE
								--Llamado para obtener parametros para el servicio de pago
								CALL bdisac:"informix".sp_param_remesas_cpl(pCodigoEstadoSuc, "2")
								RETURNING cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
								LET cTransServicio = NVL(cTransServicio, "");
								IF cTransServicio <> "20068" THEN
									LET cIdentificadorProceso = "06";
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;

		IF cIdentificadorProceso != '00' THEN
			IF cCodErrAux != '999999' THEN
				IF cValidaPLDteldom = 1 THEN
						EXECUTE PROCEDURE "informix".sp_sac_pldlim_teldom_cpl('APP',pAdress,pCity,pStateCodeAdr,pZipCode,cAnio||cMEs,pNumEmp,pTelefonoCasa,pTelefonoCel,pFolsuc,pSucursal,pRefUno,'REVERSO') INTO cCodErrAux;
				END IF;
			END IF;
		END IF;

		RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode,NVL(cNacionalidad,''), NVL(pNumcte,''), NVL(cEstadoBenef,''), cTaxIdentificationNumber, cSupervisorId,  cProofOfDomicileTypeCode, cProofOfDomicileDescription, cProofOfDomicileReferenceNumber ,  NVL(cBiometricAuthentication,''), NVL(cGenero,''), NVL(cUniqueResidentNumber,'') ;
	END
END PROCEDURE;