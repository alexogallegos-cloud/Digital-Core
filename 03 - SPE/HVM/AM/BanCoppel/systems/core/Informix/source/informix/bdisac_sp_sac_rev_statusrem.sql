CREATE PROCEDURE "informix".sp_sac_rev_statusrem(pNumRemesa CHAR(15))
	RETURNING
    CHAR (4)    AS  cCodRet,
    CHAR (15)   AS  cNumRemesa,
    CHAR (9)    AS  cNumCliente,
    CHAR (30)   AS  cNom1,
    CHAR (30)   AS  cNom2,
    CHAR (30)   AS  cApelldoPat,
    CHAR (30)   AS  cApellMat,
    CHAR (5)    AS  cCod,
    CHAR (100)  AS  cDescCod,
    CHAR (5)    AS  cCodB,
    CHAR (100)  AS  cDescCodB,
    CHAR (10)   AS  cTipoOp,
    CHAR (8)    AS  cMontoOrigen,
    CHAR (8)    AS  cMontoDestino,
    CHAR (4)    AS  cSuc,
    CHAR (4)    AS  cCanal,
    CHAR (30)   AS  cFechaInsert,
    CHAR (1)    AS  cTransacc,
    CHAR (16)   AS  cFolioSuc,
    CHAR (8)    AS  cEjecut,
    CHAR (4)    AS  cCodStatusRem,
    CHAR (100)  AS  cDescStatus;

DEFINE cCodRet          CHAR(4);
DEFINE isqlerr          INTEGER;
DEFINE cNumRemesa       CHAR (15) ;
DEFINE cNumCliente      CHAR (9)  ;
DEFINE cNom1            CHAR (30) ;
DEFINE cNom2            CHAR (30) ;
DEFINE cApelldoPat      CHAR (30) ;
DEFINE cApellMat        CHAR (30) ;
DEFINE cCod             CHAR (5)  ;
DEFINE cDescCod         CHAR (100);
DEFINE cCodB            CHAR (5)  ;
DEFINE cDescCodB        CHAR (100);
DEFINE cTipoOp          CHAR (10) ;
DEFINE cMontoOrigen     CHAR (8)  ;
DEFINE cMontoDestino    CHAR (8)  ;    
DEFINE cSuc             CHAR (4)  ;
DEFINE cCanal           CHAR (4)  ;
DEFINE cFechaInsert     CHAR (30) ;
DEFINE cTransacc        CHAR (1)  ;
DEFINE cFolioSuc        CHAR (16) ;
DEFINE cEjecut          CHAR (8)  ;
DEFINE cCodStatusRem    CHAR (4)  ;    
DEFINE cDescStatus      CHAR (100);

DEFINE cremesa          INTEGER;
DEFINE ccontremesa          INTEGER;

LET isqlerr = 0;
LET cCodRet = '0000';      
LET cNumRemesa = '';   
LET cNumCliente = '';  
LET cNom1 = '';        
LET cNom2 = '';        
LET cApelldoPat = '';  
LET cApellMat = '';    
LET cCod = '';         
LET cDescCod = '';     
LET cCodB = '';        
LET cDescCodB = '';    
LET cTipoOp = 'Reverso';      
LET cMontoOrigen = ''; 
LET cMontoDestino = '';
LET cSuc = '';         
LET cCanal = '';       
LET cFechaInsert = ''; 
LET cTransacc = '';    
LET cFolioSuc = '';    
LET cEjecut = '';      
LET cCodStatusRem = '';
LET cDescStatus = '';  

LET cremesa = 0;
LET ccontremesa = 0;

	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
		    RETURN  cCodRet, cNumRemesa, cNumCliente, cNom1, cNom2, cApelldoPat, cApellMat, cCod, cDescCod, cCodB, 
            cDescCodB, cTipoOp, cMontoOrigen, cMontoDestino, cSuc, cCanal, cFechaInsert, cTransacc, cFolioSuc, 
            cEjecut, cCodStatusRem, cDescStatus WITH RESUME;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/home/c90307738/herramienta/sp_sac_rev_statusrem.log';
        --TRACE ON;

		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;


            --------------------APPRIZA ----------------
            IF LENGTH(TRIM(pNumRemesa))= 12 OR LENGTH(TRIM(pNumRemesa))= 8 THEN 
                SELECT COUNT(unirefnum) 
                INTO cremesa 
                from sac_app_revi 
                WHERE unirefnum = pNumRemesa;
                
                IF cremesa > 0 THEN 
                    CREATE SYNONYM IF NOT EXISTS bitacoraAppriza FOR bdisac:"informix".sac_app_revi;
                ELSE 
                    CREATE SYNONYM IF NOT EXISTS bitacoraAppriza FOR bdisac:"informix".sac_app_revi_old;
                END IF;

                SELECT COUNT(unirefnum)
                INTO ccontremesa
                FROM bdisac:sac_app_qryi
                WHERE unirefnum = pNumRemesa ;
                
                IF ccontremesa > 0 THEN
                CREATE SYNONYM IF NOT EXISTS bitacoraApprizaPay FOR bdisac:"informix".sac_app_payi;
                ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraApprizaPay FOR bdisac:"informix".sac_app_payi_old;
                END IF;

                FOREACH
                SELECT
                    unirefnum , r_code_d, r_message_d, nnumber, fecha, txn_status, refnum, user_insert, r_ordstatuscode
                INTO
                    cNumRemesa, cCod, cDescCod, cSuc, cFechaInsert, cTransacc, cFolioSuc, cEjecut, cCodStatusRem
                FROM
                    bitacoraAppriza 
                WHERE
                    unirefnum = pNumRemesa 

                SELECT  firstname, middlename, lastname, mommaidenname, customernumber, r_originamount, r_destinamount
                INTO    cNom1, cNom2, cApelldoPat, cApellMat, cNumCliente, cMontoOrigen, cMontoDestino
                FROM    bitacoraApprizaPay
                WHERE   unirefnum = cNumRemesa
                AND     r_code_d = 'P000';

                IF cCodStatusRem <> '' THEN
                    SELECT description INTO cDescStatus FROM bdisac:sac_app_estatusrem WHERE status = cCodStatusRem;
                END IF;


                RETURN  cCodRet, cNumRemesa, cNumCliente, cNom1, cNom2, cApelldoPat, cApellMat, cCod, cDescCod, cCodB, 
                        cDescCodB, cTipoOp, cMontoOrigen, cMontoDestino, cSuc, cCanal, cFechaInsert, cTransacc, cFolioSuc, 
                        cEjecut, cCodStatusRem, cDescStatus WITH RESUME;
                END FOREACH;

                DROP SYNONYM IF EXISTS bitacoraApprizaPay;
                DROP SYNONYM IF EXISTS bitacoraAppriza;

                -------------------BTS 
            ELIF  LENGTH(TRIM(pNumRemesa))= 11 THEN
                SELECT COUNT(confirmation_nm) 
                INTO    cremesa 
                from    sac_bts_revi 
                WHERE   confirmation_nm = pNumRemesa;
                
                IF cremesa > 0 THEN
                    FOREACH
                    SELECT  a.confirmation_nm, a.trans_status_cd, a.process_msg, a.branch_sd, a.fecha_insert, a.txn_status, a.bank_ref_nm,
                            a.user_insert, a.trans_status_dt,b.numcte, b.r_first_name, b.r_middle_name, b.r_last_name, b.r_mother_m_name
                    INTO    cNumRemesa, cCod, cDescCod, cSuc, cFechaInsert,cTransacc, cFolioSuc, 
                            cEjecut, cCodStatusRem, cNumCliente, cNom1, cNom2, cApelldoPat, cApellMat
                    FROM    sac_bts_revi as a 
                    LEFT JOIN sac_bts_payi as b 
                    ON      a.bank_ref_nm = b.bank_ref_nm
                    WHERE   a.confirmation_nm = pNumRemesa

                    RETURN  cCodRet, cNumRemesa, cNumCliente, cNom1, cNom2, cApelldoPat, cApellMat, cCod, cDescCod, cCodB, 
                        cDescCodB, cTipoOp, cMontoOrigen, cMontoDestino, cSuc, cCanal, cFechaInsert, cTransacc, cFolioSuc, 
                        cEjecut, cCodStatusRem, cDescStatus WITH RESUME;
                    END FOREACH; 
                END IF;
            --------------------WESTERN 
            ELSE 
                SELECT COUNT(mtcn)
                INTO cremesa
                FROM bdisac:sac_wu_cancelpay
                WHERE mtcn = pNumRemesa ;

                IF cremesa > 0 THEN
                    CREATE SYNONYM IF NOT EXISTS bitacoraWu FOR bdisac:"informix".sac_wu_cancelpay;
                ELSE 
                    CREATE SYNONYM IF NOT EXISTS bitacoraWu FOR bdisac:"informix".sac_wu_cancelpay_old;
                END IF;

                SELECT COUNT(mtcn)
                INTO ccontremesa
                FROM bdisac:sac_wu_pay
                WHERE mtcn = pNumRemesa ;
                IF ccontremesa > 0 THEN
                    CREATE SYNONYM IF NOT EXISTS bitacoraWuPay FOR bdisac:"informix".sac_wu_pay;
                ELSE 
                    CREATE SYNONYM IF NOT EXISTS bitacoraWuPay FOR bdisac:"informix".sac_wu_pay_old;
                END IF;

                FOREACH
                SELECT  a.mtcn, a.retcode, a.descretcode, a.fecha_insert, a.bandera_reversion, a.referencia_sistema_externo, a.usuario_insert, a.error,
                        b.benef_nombre1, b.benef_nombre2, b.benef_appaterno, b.benef_apmaterno, b.numcte, b.monto_origen, b.monto_destino
                INTO    cNumRemesa,  cCod, cDescCod, cFechaInsert, cTransacc, cFolioSuc, cEjecut, cCodStatusRem,
                        cNom1, cNom2, cApelldoPat, cApellMat, cNumCliente, cMontoOrigen, cMontoDestino
                FROM    bitacoraWu AS a 
                LEFT JOIN bitacoraWuPay AS b
                ON      a.referencia_sistema_externo = b.foreign_rs_refnum_rp
                WHERE   a.mtcn = pNumRemesa

                IF cCodStatusRem <> ''  AND cCodStatusRem IS NOT NULL THEN
                    SELECT descripcion_bcp INTO cDescStatus FROM bdisac:"informix".sac_wu_estatusrems WHERE estatus_remesa = cCodStatusRem;
                END IF;


                RETURN  cCodRet, cNumRemesa, cNumCliente, cNom1, cNom2, cApelldoPat, cApellMat, cCod, cDescCod, cCodB, 
                        cDescCodB, cTipoOp, cMontoOrigen, cMontoDestino, cSuc, cCanal, cFechaInsert, cTransacc, cFolioSuc, 
                        cEjecut, cCodStatusRem, cDescStatus WITH RESUME;
                END FOREACH;
                DROP SYNONYM IF EXISTS bitacoraWu;
            END IF;
    END;                
END PROCEDURE
		;