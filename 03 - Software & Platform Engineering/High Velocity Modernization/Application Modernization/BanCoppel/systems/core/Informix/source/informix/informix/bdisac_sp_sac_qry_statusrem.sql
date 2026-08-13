CREATE PROCEDURE "informix".sp_sac_qry_statusrem(pNumRemesa CHAR(15))

	RETURNING
 CHAR(4)    AS  cCodRet,
 CHAR(1)    AS  cTransacc,      
 CHAR(12)   AS  cNumRemesa,    
 CHAR(16)   AS  cFolioSuc,    
 CHAR(8)    AS  cTipoOp,
 CHAR(20)   AS  cCodB,
 CHAR(100)  AS  cDescCodB,
 CHAR(5)    AS  cCodStatusRem,   
 CHAR(100)  AS  cDescStatus,
 CHAR(4)    AS  cSuc,
 CHAR(5)    AS  cCod,
 CHAR(100)  AS  cDescCod,
 CHAR (5)   AS  cCanal,
 CHAR(30)   AS  cNom1,
 CHAR(30)   AS  cNom2, 
 CHAR(30)   AS  cApelldoPat,
 CHAR(30)   AS  cApellMat,   
 CHAR(4)    AS  cPais,  
 CHAR(4)    AS  cEdo,
 CHAR(30)   AS  cCd,
 CHAR(5)    AS  cCP,
 CHAR(10)   AS  cTel, 
 CHAR(10)   AS  cCel,  
 CHAR(50)   AS  cDom,  
 CHAR(2)    AS  cTipoID,
 CHAR(20)   AS  cNumID,
 CHAR(10)   AS  cFechaVencID,   
 CHAR(30)   AS  cEmail,
 CHAR(6)    AS  cTipoCambio, 
 CHAR(4)    AS  cMonedaOrigen, 
 CHAR(4)    AS  cMonedaDestino,
 CHAR(8)    AS  cMontoOrigen,
 CHAR(8)    AS  cMontoDestino,
 CHAR(30)   AS  cNom1Emisor,
 CHAR(30)   AS  cNom2Emisor,
 CHAR(30)   AS  cApellPatEmisor,
 CHAR(30)   AS  cApellMatEmisor,
 CHAR(4)    AS  cPaisEmisor,
 CHAR(4)    AS  cEdoEmisor,
 CHAR(20)   AS  cCdEmisor,
 CHAR(5)    AS  cCpEmisor,  
 CHAR(50)   AS  cDomEmisor,
 CHAR(9)    AS  cEjecut,
 CHAR(25)   AS  cFechaInsert;       

DEFINE cCodRet CHAR(4);
DEFINE isqlerr INTEGER;
DEFINE cTransacc CHAR(1);
DEFINE cNumRemesa CHAR(12);
DEFINE cFolioSuc CHAR(16);


DEFINE cCodStatusRem CHAR(5);
DEFINE cDescStatus CHAR(100);
DEFINE cTipoOp CHAR(8);    
DEFINE cCodB CHAR(20);
DEFINE cDescCodB CHAR(100);
DEFINE cSuc CHAR(4);
DEFINE cCod CHAR(4);
DEFINE cDescCod CHAR(100);
DEFINE cCanal CHAR(5);
DEFINE cNom1 CHAR(30);
DEFINE cNom2 CHAR(30);
DEFINE cApelldoPat CHAR(30);
DEFINE cApellMat CHAR(30);
DEFINE cPais CHAR(4);
DEFINE cEdo CHAR(4);
DEFINE cCd CHAR(30);
DEFINE cCP CHAR(5);
DEFINE cTel CHAR(10);
DEFINE cCel CHAR(10);
DEFINE cDom CHAR(50);
DEFINE cTipoID CHAR(2);
DEFINE cNumID CHAR(20);
DEFINE cFechaVencID CHAR(10);
DEFINE cEmail CHAR(30);
DEFINE cTipoCambio CHAR(6);
DEFINE cMonedaOrigen CHAR(4);
DEFINE cMonedaDestino CHAR(4);
DEFINE cMontoOrigen CHAR(8);
DEFINE cMontoDestino CHAR(8);
DEFINE cNom1Emisor CHAR(30);
DEFINE cNom2Emisor CHAR(30);
DEFINE cApellPatEmisor CHAR(30);
DEFINE cApellMatEmisor CHAR(30);
DEFINE cPaisEmisor CHAR(4);
DEFINE cEdoEmisor CHAR(4);
DEFINE cCdEmisor CHAR(20);
DEFINE cCpEmisor CHAR(5);
DEFINE cDomEmisor CHAR(50);
DEFINE cEjecut CHAR(9);
DEFINE cFechaInsert CHAR(25);

DEFINE cremesaApp CHAR(12);
DEFINE cremesaBts CHAR(12);
DEFINE cremesaWu  CHAR(12);

LET cCodRet = '0000';
LET isqlerr = 0;
LET cTransacc = '';
LET cNumRemesa = '';
LET cFolioSuc = '';

LET cTipoOp = 'Qryi';
LET cCodB = '';
LET cDescCodB = '';
LET cCodStatusRem = '';
LET cDescStatus = '';
LET cSuc = '';
LET cCod = '';
LET cDescCod = '';
LET cCanal = '';
LET cNom1 = '';
LET cNom2 = '';
LET cApelldoPat = '';
LET cApellMat = '';
LET cPais = '';
LET cEdo = '';
LET cCd = '';
LET cCP = '';
LET cTel = '';
LET cCel = '';
LET cDom = '';
LET cTipoID = '';
LET cNumID = '';
LET cFechaVencID = '';
LET cEmail = '';
LET cTipoCambio = '';
LET cMonedaOrigen = '';
LET cMonedaDestino = '';
LET cMontoOrigen = '';
LET cMontoDestino = '';
LET cNom1Emisor = '';
LET cNom2Emisor = '';
LET cApellPatEmisor = '';
LET cApellMatEmisor = '';
LET cPaisEmisor = '';
LET cEdoEmisor = '';
LET cCdEmisor = '';
LET cCpEmisor = '';
LET cDomEmisor = '';
LET cEjecut = '';
LET cFechaInsert = '';

LET cremesaApp ='';
LET cremesaBts ='';
LET cremesaWu ='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN  cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1, cNom2, cApelldoPat, cApellMat, 
                    cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                    cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert;       

		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/home/c90307738/herramienta/sp_sac_qry_statusrem.log';
       --TRACE ON;

		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;

        DROP SYNONYM IF EXISTS bitacoraAppriza;
        DROP SYNONYM IF EXISTS bitacoraBts;
        DROP SYNONYM IF EXISTS bitacoraWu;

        DROP TABLE IF EXISTS tablaTemporal;
        CREATE TEMP TABLE tablaTemporal (tCodRet  CHAR(4), tTransacc   CHAR(1), tNumRemesa  CHAR(12),tFolioSuc   CHAR(16),tTipoOp   CHAR(8), tCodB     CHAR(20),tDescCodB    CHAR(100),tCodStatusRem  CHAR(5), 
        tDescStatus CHAR(100) ,tSuc     CHAR(4), tCod     CHAR(5), tDescCod CHAR(100),tCanal   CHAR (5),tNom1    CHAR(30),tNom2    CHAR(30),tApelldoPat CHAR(30),tApellMat   CHAR(30),
        tPais    CHAR(4), tEdo     CHAR(4), tCd   CHAR(30),tCP   CHAR(5), tTel     CHAR(10),tCel     CHAR(10),tDom     CHAR(50),tTipoID  CHAR(2), tNumID   CHAR(20),tFechaVencID   CHAR(10),
        tEmail   CHAR(30),tTipoCambio CHAR(6), tMonedaOrigen  CHAR(4), tMonedaDestino CHAR(4), tMontoOrigen   CHAR(8), tMontoDestino  CHAR(8), tNom1Emisor CHAR(30),tNom2Emisor CHAR(30),tApellPatEmisor CHAR(30),
        tApellMatEmisor CHAR(30),tPaisEmisor CHAR(4), tEdoEmisor  CHAR(4), tCdEmisor   CHAR(20),tCpEmisor   CHAR(5), tDomEmisor  CHAR(50),tEjecut  CHAR(9), tFechaInsert   CHAR(25));

        FOREACH
        SELECT referencia, retcode2, descripcion_error, sucursal, fecha_insert 
        INTO   cNumRemesa, cCod ,  cDescCod,  cSuc, cFechaInsert
        FROM   sac_bitacora_errores_remesas
        WHERE referencia = pNumRemesa  
        AND     tipo_proceso= cTipoOp
        INSERT INTO tablaTemporal (tCodRet, tTransacc, tNumRemesa,tFolioSuc,tTipoOp, tCodB,tDescCodB,tCodStatusRem, tDescStatus,tSuc, tCod, tDescCod,tCanal,tNom1,tNom2,tApelldoPat,tApellMat,tPais, tEdo, 
                                    tCd,tCP, tTel,tCel,tDom,tTipoID, tNumID,tFechaVencID, tEmail,tTipoCambio, tMonedaOrigen, tMonedaDestino, tMontoOrigen, tMontoDestino, tNom1Emisor,tNom2Emisor,tApellPatEmisor,
                                    tApellMatEmisor,tPaisEmisor, tEdoEmisor, tCdEmisor,tCpEmisor, tDomEmisor,tEjecut, tFechaInsert) VALUES 
                                    (cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1,cNom2, cApelldoPat, cApellMat, 
                                    cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                                    cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert);
        END FOREACH;
        LET cNumRemesa= '';
        LET cCodB = '';
        LET cDescCodB= '';
        LET cSuc= '';
        LET cEjecut= '';
        LET cFechaInsert = '';
                        -----------------------------APPRIZA - MONEYGRAM---------------------------------------------------------------
        IF LENGTH(TRIM(pNumRemesa))= 12 OR LENGTH(TRIM(pNumRemesa))= 8 THEN 

            SELECT COUNT(unirefnum)
            INTO cremesaApp
            FROM bdisac:sac_app_qryi
            WHERE unirefnum = pNumRemesa ;

            IF cremesaApp > 0 THEN
                CREATE SYNONYM IF NOT EXISTS bitacoraAppriza FOR bdisac:"informix".sac_app_qryi;
            ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraAppriza FOR bdisac:"informix".sac_app_qryi_old;
            END IF;

            FOREACH
            SELECT
                txn_status, unirefnum,code,r_ordstatuscode,nnumber,
                r_code_d, r_message_d,r_firstname_b,r_middlename_b,r_lastname_b,r_mommaidenna_b,r_countrycode_b,r_statecode_b,r_city_b,r_zipcode_b,r_homephonenum,
                r_number_cl,r_address_b, r_email,r_rexchangerate,r_originamount,r_currencycode, r_destinamount, r_currencycod_d,
                r_firstname,r_middlename,r_lastname,r_mommaidenname,r_countrycode_a,r_statecode,r_city,r_zipcode,r_address,user_insert,fecha
            INTO
                cTransacc,cNumRemesa,cCanal, cCodStatusRem,cSuc,
                cCod,cDescCod,cNom1,cNom2,cApelldoPat,cApellMat,cPais,cEdo,cCd,cCP,cTel,
                cCel,cDom,cEmail,cTipoCambio,cMontoOrigen,cMonedaOrigen, cMontoDestino, cMonedaDestino,
                cNom1Emisor,cNom2Emisor,cApellPatEmisor,cApellMatEmisor,cPaisEmisor,cEdoEmisor,cCdEmisor,cCpEmisor,cDomEmisor,cEjecut,cFechaInsert
            FROM
                bitacoraAppriza 
            WHERE
                unirefnum = pNumRemesa 
            
            IF cCodStatusRem <> '' THEN
                SELECT description INTO cDescStatus FROM bdisac:sac_app_estatusrem WHERE status = cCodStatusRem;
            END IF;
            
            
            INSERT INTO tablaTemporal (tCodRet, tTransacc, tNumRemesa,tFolioSuc,tTipoOp, tCodB,tDescCodB,tCodStatusRem, tDescStatus,tSuc, tCod, tDescCod,tCanal,tNom1,tNom2,tApelldoPat,tApellMat,tPais, tEdo, 
                                    tCd,tCP, tTel,tCel,tDom,tTipoID, tNumID,tFechaVencID, tEmail,tTipoCambio, tMonedaOrigen, tMonedaDestino, tMontoOrigen, tMontoDestino, tNom1Emisor,tNom2Emisor,tApellPatEmisor,
                                    tApellMatEmisor,tPaisEmisor, tEdoEmisor, tCdEmisor,tCpEmisor, tDomEmisor,tEjecut, tFechaInsert) VALUES 
                                    (cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1,cNom2, cApelldoPat, cApellMat, 
                                    cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen, cMonedaDestino,cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                                    cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert);
            END FOREACH;
            DROP SYNONYM IF EXISTS bitacoraAppriza;

                     ------ -----------------------BTS --------------------------------------------------------------------------  
        ELIF LENGTH(TRIM(pNumRemesa))= 11 THEN 

            SELECT COUNT(confirmation_nm)
            INTO cremesaBts
            FROM bdisac:sac_bts_qryi
            WHERE confirmation_nm = pNumRemesa ;

            IF cremesaBts > 0 THEN
                CREATE SYNONYM IF NOT EXISTS bitacoraBts FOR bdisac:"informix".sac_bts_qryi;
            ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraBts FOR bdisac:"informix".sac_bts_qryi_old;
            END IF;

            FOREACH
            SELECT
            txn_status ,agent_cd ,confirmation_nm , trans_status_cd , branch_sd ,
            opcode , process_msg , r_first_name , r_middle_name , r_last_name , r_mother_m_name , r_country_cd , r_state_cd , r_city , r_zip_code ,
            r_phone , r_address , r_identif_type_cd , r_identif_nm , r_expiration_dt , exch_rate_fx , orig_currency_cd , dest_currency_cd , origin_am , destination_am , 
            s_first_name , s_middle_name , s_last_name , s_mother_m_name , s_country_cd , s_state_cd , s_city , s_zip_code , s_address , user_insert , fecha_insert 
            INTO
            cTransacc,cCanal, cNumRemesa,cCodStatusRem,cSuc,
            cCod,cDescCod,cNom1,cNom2,cApelldoPat,cApellMat,cPais,cEdo,cCd,cCP,
            cCel,cDom,cTipoID,cNumID,cFechaVencID,cTipoCambio,cMonedaOrigen,cMonedaDestino,
            cMontoOrigen,cMontoDestino,cNom1Emisor,cNom2Emisor,cApellPatEmisor,cApellMatEmisor,cPaisEmisor,cEdoEmisor,cCdEmisor,cCpEmisor,cDomEmisor,cEjecut,cFechaInsert
            FROM
            bitacoraBts
            WHERE
            confirmation_nm = pNumRemesa 

            IF cCodStatusRem <> '' THEN
                SELECT dans_status_code_sd INTO cDescStatus FROM bdisac:sac_bts_catstatusremesas WHERE dans_status_code = cCodStatusRem;
            END IF;

            

            INSERT INTO tablaTemporal (tCodRet, tTransacc, tNumRemesa,tFolioSuc,tTipoOp, tCodB,tDescCodB,tCodStatusRem, tDescStatus,tSuc, tCod, tDescCod,tCanal,tNom1,tNom2,tApelldoPat,tApellMat,tPais, tEdo, 
                                    tCd,tCP, tTel,tCel,tDom,tTipoID, tNumID,tFechaVencID, tEmail,tTipoCambio, tMonedaOrigen, tMonedaDestino, tMontoOrigen, tMontoDestino, tNom1Emisor,tNom2Emisor,tApellPatEmisor,
                                    tApellMatEmisor,tPaisEmisor, tEdoEmisor, tCdEmisor,tCpEmisor, tDomEmisor,tEjecut, tFechaInsert) VALUES 
                                    (cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1,cNom2, cApelldoPat, cApellMat, 
                                    cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                                    cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert);
      
            END FOREACH;
            DROP SYNONYM IF EXISTS bitacoraBts;
                        -------- ---------------------------------WESTERN UNION --------------------------------------------------------  
        ELSE 
            SELECT COUNT(mtcn)
            INTO cremesaWu
            FROM bdisac:sac_wu_search
            WHERE mtcn = pNumRemesa ;

            IF cremesaWu > 0 THEN
            CREATE SYNONYM IF NOT EXISTS bitacoraWu FOR bdisac:"informix".sac_wu_search;
            ELSE 
            CREATE SYNONYM IF NOT EXISTS bitacoraWu FOR bdisac:"informix".sac_wu_search_old;
            END IF;

            FOREACH
            SELECT
                txn_status,mtcn,foreign_rs_refnum_rp,estatus_remesa,
                retcode,desc_error,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,benef_cod_pais,benef_edo,benef_ciudad,benef_cp,benef_tel_part,
                benef_tel_celular,benef_calle,tipo_cambio,emisor_cod_moneda,benef_cod_moneda,monto_total_origen,monto_total_destino,
                emisor_nombre1,emisor_nombre2,emisor_appaterno,emisor_apmaterno,emisor_cod_pais,emisor_edo,emisor_ciudad,emisor_cp,emisor_calle,user_insert,fecha_insert
            INTO
                cTransacc,cNumRemesa,cFolioSuc,cCodStatusRem,
                cCod,cDescCod,cNom1,cNom2,cApelldoPat,cApellMat,cPais,cEdo,cCd,cCP,cTel,
                cCel,cDom,cTipoCambio,cMonedaOrigen,cMonedaDestino,cMontoOrigen,cMontoDestino,
                cNom1Emisor,cNom2Emisor,cApellPatEmisor,cApellMatEmisor,cPaisEmisor,cEdoEmisor,cCdEmisor,cCpEmisor,cDomEmisor,cEjecut,cFechaInsert
            FROM 
                bitacoraWu
            WHERE
                mtcn = pNumRemesa 


            SELECT sucursal
            INTO cSuc
            from bdinteg:"informix".si_ejecut
            where ejecutivo = cEjecut;

            IF cCodStatusRem <> ''  AND cCodStatusRem IS NOT NULL THEN
                SELECT descripcion_bcp INTO cDescStatus FROM bdisac:"informix".sac_wu_estatusrems WHERE estatus_remesa = cCodStatusRem;
            END IF;

            INSERT INTO tablaTemporal (tCodRet, tTransacc, tNumRemesa,tFolioSuc,tTipoOp, tCodB,tDescCodB,tCodStatusRem, tDescStatus,tSuc, tCod, tDescCod,tCanal,tNom1,tNom2,tApelldoPat,tApellMat,tPais, tEdo, 
                                    tCd,tCP, tTel,tCel,tDom,tTipoID, tNumID,tFechaVencID, tEmail,tTipoCambio, tMonedaOrigen, tMonedaDestino, tMontoOrigen, tMontoDestino, tNom1Emisor,tNom2Emisor,tApellPatEmisor,
                                    tApellMatEmisor,tPaisEmisor, tEdoEmisor, tCdEmisor,tCpEmisor, tDomEmisor,tEjecut, tFechaInsert) VALUES 
                                    (cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1,cNom2, cApelldoPat, cApellMat, 
                                    cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                                    cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert);

            END FOREACH;
            DROP SYNONYM IF EXISTS bitacoraWu;
        END IF;

        FOREACH
        SELECT  tCodRet, tTransacc, tNumRemesa,tFolioSuc,tTipoOp, tCodB,tDescCodB,tCodStatusRem, tDescStatus,tSuc, tCod, tDescCod,tCanal,tNom1,tNom2,tApelldoPat,tApellMat,tPais, tEdo, 
                tCd,tCP, tTel,tCel,tDom,tTipoID, tNumID,tFechaVencID, tEmail,tTipoCambio, tMonedaOrigen, tMonedaDestino, tMontoOrigen, tMontoDestino, tNom1Emisor,tNom2Emisor,tApellPatEmisor,
                tApellMatEmisor,tPaisEmisor, tEdoEmisor, tCdEmisor,tCpEmisor, tDomEmisor,tEjecut, tFechaInsert
        INTO    cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1,cNom2, cApelldoPat, cApellMat, 
                cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert
        FROM tablaTemporal
        ORDER BY cFechaInsert DESC

        RETURN  cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1, cNom2, cApelldoPat, cApellMat, 
                cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert WITH RESUME;
        END FOREACH;
        DROP TABLE IF EXISTS tablaTemporal;
    END;
END PROCEDURE
		;