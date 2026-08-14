CREATE PROCEDURE "informix".sp_sac_pay_statusrem(pNumRemesa CHAR(15))
	RETURNING
CHAR (5)    AS cCodRet,
CHAR (8)    AS cTipoOp,
CHAR (1)    AS cTransacc,
CHAR (14)   AS cNumRemesa,
CHAR (16)   AS cFolioSuc,

CHAR (4)    AS cSuc,
CHAR (3)    AS cCanal,
CHAR (5)    AS cCod,
CHAR (100)  AS cDescCod ,
CHAR (20)    AS cCodB ,
CHAR(100)   AS cDescCodB,
CHAR (9)    AS cNumCliente,
CHAR (30)   AS cNom1,
CHAR (30)   AS cNom2,
CHAR (30)   AS cApellPat ,
CHAR (30)   AS cApellMat,
CHAR (8)    AS cMontoOrigen,
CHAR (8)    AS cMontoDestino,
CHAR (8)    AS cEjecut,
CHAR (30)   AS cFechaInsert;



DEFINE iSqlErr        INTEGER;	
DEFINE cCodRet        CHAR (4);   
DEFINE cTipoOp        CHAR(8);
DEFINE cTransacc      CHAR(1);
DEFINE cNumRemesa     CHAR(14);
DEFINE cFolioSuc      CHAR(16);

DEFINE cSuc           CHAR(4);
DEFINE cCanal         CHAR(3);
DEFINE cCod           CHAR(5);
DEFINE cDescCod       CHAR(100);
DEFINE cCodB          CHAR(20);
DEFINE cDescCodB      CHAR(100);
DEFINE cNumCliente    CHAR(9);
DEFINE cNom1          CHAR(30);
DEFINE cNom2          CHAR(30);
DEFINE cApellPat    CHAR(30);
DEFINE cApellMat      CHAR(30);
DEFINE cMontoOrigen   CHAR(8);
DEFINE cMontoDestino  CHAR(8);
DEFINE cEjecut        CHAR(8);
DEFINE cFechaInsert   CHAR(30);

DEFINE ccontremesa  INTEGER;
DEFINE cremesa      INTEGER;
DEFINE cremesaBts   INTEGER;

LET iSqlErr =        0;      
LET cCodRet =   '0000';      
LET cTipoOp =       'Payi';      
LET cTransacc =     '';    
LET cNumRemesa =    '';   
LET cFolioSuc =     '';    

LET cSuc =          '';         
LET cCanal =        '';       
LET cCod =          '';         
LET cDescCod =      '';     
LET cCodB =         '';        
LET cDescCodB =     '';     
LET cNumCliente =   '';  
LET cNom1 =         '';        
LET cNom2 =         '';        
LET cApellPat =     '';  
LET cApellMat =     '';    
LET cMontoOrigen =  ''; 
LET cMontoDestino = '';
LET cEjecut =       '';      
LET cFechaInsert =  ''; 

--Contador Remesa PLD
LET cremesa = 0;
--Contador bitacora payi
LET ccontremesa = '';
LET cremesaBts= 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN  cCodRet, cTipoOp, cTransacc, cNumRemesa, cFolioSuc, cSuc, cCanal, 
                    cCod, cDescCod , cCodB , cDescCodB, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cMontoOrigen, 
                    cMontoDestino, cEjecut, cFechaInsert;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/home/c90307738/herramienta/sp_sac_pay_statusrem.log';
        --TRACE ON;

		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;

        DROP TABLE IF EXISTS TablaTemporal;
        CREATE TABLE TablaTemporal (tCodRet CHAR (5)  ,tTipoOp CHAR (8)  ,tTransacc   CHAR (1)  ,tNumRemesa  CHAR (14) ,tFolioSuc   CHAR (16) ,tFchTransacc    CHAR (10) ,
                                tHrTransacc CHAR (10) ,tSuc    CHAR (4)  ,tCanal  CHAR (3)  ,tCod    CHAR (5)  ,tDescCod    CHAR (100), tCodB  CHAR (20) ,
                                tDescCodB   CHAR(100) ,tNumCliente CHAR (9)  ,tNom1   CHAR (30) ,tNom2   CHAR (30) ,tApellPat   CHAR (30) ,tApellMat   CHAR (30) ,
                                tMontoOrigen    CHAR (8)  ,tMontoDestino   CHAR (8)  ,tEjecut CHAR (8)  ,tFechaInsert    CHAR (20));

        FOREACH
        SELECT referencia, retcode2, descripcion_error, sucursal, user_insert, fecha_insert  
        INTO   cNumRemesa, cCodB ,  cDescCodB,  cSuc, cEjecut, cFechaInsert
        FROM   sac_bitacora_errores_remesas
        WHERE referencia = pNumRemesa  
        AND     tipo_proceso= cTipoOp
        AND     retcode2 NOT IN ('00160','00164','00165','00166','00167','00168','00161','00158','00159','00162')
        ORDER BY fecha_insert DESC

        IF cDescCodB ='Error en abono_ref' OR cDescCodB ='Error en sp abono_ref' OR cDescCodB='Error al aplicar el abono_ref' OR cDescCodB='Error en sp abono_ref' THEN
            LET cDescCodB= 'Error en proceso de abono';
        ELIF cDescCodB='No cuenta con registros en la sac_app_qryi' OR cDescCodB='No cuenta con registros en la sac_bts_qryi' OR cDescCodB='No cuenta con registros en la sac_wu_search' THEN
            LET cDescCodB= 'No se encontro registro de consulta';
        ELIF cDescCodB ='Error al aplicar el cargo_ref' OR cDescCodB='Error en cargo_ref'  OR cDescCodB='Error en aplicar cargo_ref' OR cDescCodB='Error en sp cargo_ref' THEN
            LET cDescCodB='Error en proceso de cargo';
        ELIF cCodB = '01245' THEN
            LET cDescCodB= 'Error al exceder limite de domicilio o telefono PLD';
        ELIF cDescCodB = 'Error en sp sp_grabapagoservicio' OR cDescCodB ='Error en sp sp_grabapagoservicio_hs'  OR cDescCodB='Error en sp_grabapagoservicio' OR cDescCodB='Error en sp_actualizaremesa' OR cDescCodB='Error en sp_grabapagoservicio_hs' OR cDescCodB='Error a grabar pago servicios' THEN
            LET cDescCodB='Error al grabar o actualizar registro en tablas';
        ELIF cDescCodB='Error en sp_consultasucursalAppriza' OR cDescCodB='Error en sp sp_wu_obtparamsgenerales' THEN
            LET cDescCodB='Error al obtener los parametros del servicio';
        END IF;
        
        
        INSERT INTO TablaTemporal (tCodRet, tTipoOp, tTransacc, tNumRemesa, tFolioSuc, tSuc, tCanal, 
               tCod, tDescCod , tCodB , tDescCodB, tNumCliente, tNom1, tNom2, tApellPat , tApellMat, tMontoOrigen, 
               tMontoDestino, tEjecut, tFechaInsert) VALUES (cCodRet, cTipoOp, cTransacc, cNumRemesa, cFolioSuc, cSuc, cCanal, 
               cCod, cDescCod , cCodB , cDescCodB, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cMontoOrigen, 
               cMontoDestino, cEjecut, cFechaInsert) ;
        
        END FOREACH;
        LET cNumRemesa= '';
        LET cCodB = '';
        LET cDescCodB= '';
        LET cSuc= '';
        LET cEjecut= '';
        LET cFechaInsert = '';
        --------------APPRIZA----------------------------------------------
        IF LENGTH(TRIM(pNumRemesa))= 12 OR LENGTH(TRIM(pNumRemesa))= 8 THEN 
            SELECT COUNT(numconfirmacion) 
            INTO cremesa 
            from sac_remesaslimitepld_app 
            WHERE numconfirmacion = pNumRemesa;
            IF cremesa > 0 THEN 
                CREATE SYNONYM IF NOT EXISTS bitacoraPld FOR bdisac:"informix".sac_remesaslimitepld_app;
            ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraPld FOR bdisac:"informix".sac_remesaslimitepld_app_old;
            END IF;

            SELECT COUNT(unirefnum)
            INTO ccontremesa
            FROM bdisac:sac_app_payi
            WHERE unirefnum = pNumRemesa ;
            IF ccontremesa > 0 THEN
                CREATE SYNONYM IF NOT EXISTS bitacoraAppriza FOR bdisac:"informix".sac_app_payi;
            ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraAppriza FOR bdisac:"informix".sac_app_payi_old;
            END IF;
            FOREACH
            SELECT 
                unirefnum,code, numcte, firstname, middlename, lastname, mommaidenname, r_code_d, r_message_d, 
                r_originamount, r_destinamount, nnumber,  fecha, txn_status, refnum, 
                user_insert
            INTO   
                cNumRemesa,cCanal, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cCod, cDescCod,
                cMontoOrigen, cMontoDestino, cSuc, cFechaInsert, cTransacc, cFolioSuc,  
                cEjecut
            FROM 
                bitacoraAppriza
            WHERE 
                unirefnum = pNumRemesa 
            ORDER BY
                fecha desc
            
            INSERT INTO TablaTemporal (tCodRet, tTipoOp, tTransacc, tNumRemesa, tFolioSuc, tSuc, tCanal, 
            tCod, tDescCod , tCodB , tDescCodB, tNumCliente, tNom1, tNom2, tApellPat , tApellMat, tMontoOrigen, 
            tMontoDestino, tEjecut, tFechaInsert) VALUES (cCodRet, cTipoOp, cTransacc, cNumRemesa, cFolioSuc, cSuc, cCanal, 
            cCod, cDescCod , cCodB , cDescCodB, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cMontoOrigen, 
            cMontoDestino, cEjecut, cFechaInsert) ;
            
            END FOREACH;

            DROP SYNONYM IF EXISTS bitacoraAppriza;
            LET cNumRemesa = '';
            LET cNumCliente = '';
            LET cNom1 = '';
            LET cNom2 = '';
            LET cApellPat = ''; 
            LET cApellMat = '';
            LET cCod = '';
            LET cDescCod = '';
            LET cMontoOrigen = '';
            LET cMontoDestino = '';
            LET cSuc = '';
            LET cFechaInsert = '';
            LET cTransacc = '';
            LET cFolioSuc = '';
            LET cEjecut = '';


                ------------------BTS

        ELIF  LENGTH(TRIM(pNumRemesa))= 11 THEN
           
            CREATE SYNONYM IF NOT EXISTS bitacoraPld FOR bdisac:"informix".sac_remesaslimitepld_bts;

            SELECT COUNT(confirmation_nm)
            INTO cremesaBts
            FROM bdisac:sac_bts_qryi
            WHERE confirmation_nm = pNumRemesa ;

            IF cremesaBts > 0 THEN
                CREATE SYNONYM IF NOT EXISTS bitacoraBtsqry FOR bdisac:"informix".sac_bts_qryi;
            ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraBtsqry FOR bdisac:"informix".sac_bts_qryi_old;
            END IF;

            SELECT COUNT(confirmation_nm)
            INTO ccontremesa
            FROM bdisac:sac_bts_payi
            WHERE confirmation_nm = pNumRemesa ;

            IF ccontremesa > 0 THEN
                CREATE SYNONYM IF NOT EXISTS bitacoraBts FOR bdisac:"informix".sac_bts_payi;
            ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraBts FOR bdisac:"informix".sac_bts_payi_old;
            END IF;


            SELECT first 1 origin_am, destination_am
            INTO    cMontoOrigen, cMontoDestino
            FROM    bitacoraBtsqry
            WHERE confirmation_nm = pNumRemesa 
            AND     opcode='1000';

            FOREACH
            SELECT 
                agent_cd, confirmation_nm, numcte, r_first_name, r_middle_name, r_last_name, r_mother_m_name, opcode, process_msg, 
                sucursal, fecha_insert, txn_status, bank_ref_nm, 
                user_insert
            INTO   
                cCanal, cNumRemesa, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cCod, cDescCod,
                cSuc, cFechaInsert, cTransacc, cFolioSuc,  
                cEjecut
            FROM 
                bitacoraBts
            WHERE 
                confirmation_nm = pNumRemesa
            ORDER BY    
                fecha_insert desc

            INSERT INTO TablaTemporal (tCodRet, tTipoOp, tTransacc, tNumRemesa, tFolioSuc, tSuc, tCanal, 
               tCod, tDescCod , tCodB , tDescCodB, tNumCliente, tNom1, tNom2, tApellPat , tApellMat, tMontoOrigen, 
               tMontoDestino, tEjecut, tFechaInsert) VALUES (cCodRet, cTipoOp, cTransacc, cNumRemesa, cFolioSuc, cSuc, cCanal, 
               cCod, cDescCod , cCodB , cDescCodB, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cMontoOrigen, 
               cMontoDestino, cEjecut, cFechaInsert) ;
            END FOREACH;

            DROP SYNONYM IF EXISTS bitacoraBts;
            DROP SYNONYM IF EXISTS bitacoraBtsqry;
            LET cNumRemesa = '';
            LET cNumCliente = '';
            LET cNom1 = '';
            LET cNom2 = '';
            LET cApellPat = ''; 
            LET cApellMat = '';
            LET cCod = '';
            LET cDescCod = '';
            LET cMontoOrigen = '';
            LET cMontoDestino = '';
            LET cSuc = '';
            LET cFechaInsert = '';
            LET cTransacc = '';
            LET cFolioSuc = '';
            LET cEjecut = '';

------------------------------------------WU--------------------------------------
        ELIF LENGTH(TRIM(pNumRemesa))= 10 THEN
            SELECT COUNT(numconfirmacion) 
            INTO cremesa 
            from sac_remesaslimitepld_wu 
            WHERE   numconfirmacion = pNumRemesa;
            
            IF cremesa > 0 THEN
                CREATE SYNONYM IF NOT EXISTS bitacoraPld FOR bdisac:"informix".sac_remesaslimitepld_wu;
            ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraPld FOR bdisac:"informix".sac_remesaslimitepld_wu_old;
            END IF;
            SELECT COUNT(mtcn)
            INTO ccontremesa
            FROM bdisac:sac_wu_pay
            WHERE mtcn = pNumRemesa ;
            IF ccontremesa > 0 THEN
                CREATE SYNONYM IF NOT EXISTS bitacoraWu FOR bdisac:"informix".sac_wu_pay;
            ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraWu FOR bdisac:"informix".sac_wu_pay_old;
            END IF;
            FOREACH
            SELECT 
                mtcn, numcte, benef_nombre1, benef_nombre2, benef_appaterno, benef_apmaterno, retcode, desc_error, 
                monto_origen, monto_destino, fecha_insert, txn_status, 
                user_insert
            INTO   
                cNumRemesa, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cCod, cDescCod,
                cMontoOrigen, cMontoDestino, cFechaInsert, cTransacc,  
                cEjecut
            FROM 
                bitacoraWu
            WHERE 
                mtcn = pNumRemesa
            ORDER BY
                fecha_insert desc

            SELECT sucursal
            INTO cSuc
            from bdinteg:si_ejecut
            where ejecutivo = cEjecut;

            INSERT INTO TablaTemporal (tCodRet, tTipoOp, tTransacc, tNumRemesa, tFolioSuc, tSuc, tCanal, 
            tCod, tDescCod , tCodB , tDescCodB, tNumCliente, tNom1, tNom2, tApellPat , tApellMat, tMontoOrigen, 
            tMontoDestino, tEjecut, tFechaInsert) VALUES (cCodRet, cTipoOp, cTransacc, cNumRemesa, cFolioSuc, cSuc, cCanal, 
            cCod, cDescCod , cCodB , cDescCodB, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cMontoOrigen, 
            cMontoDestino, cEjecut, cFechaInsert) ;

            
            END FOREACH;

            DROP SYNONYM IF EXISTS bitacoraWu;
            LET cNumRemesa = '';
            LET cNumCliente = '';
            LET cNom1 = '';
            LET cNom2 = '';
            LET cApellPat = ''; 
            LET cApellMat = '';
            LET cCod = '';
            LET cDescCod = '';
            LET cMontoOrigen = '';
            LET cMontoDestino = '';
            LET cFechaInsert = '';
            LET cTransacc = '';
            LET cEjecut = '';

    END IF;

    FOREACH 
    SELECT  fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, sucursal, montopagar, codigo, numconfirmacion
    INTO    cFechaInsert, cNom1, cNom2, cApellPat, cApellMat, cSuc, cMontoDestino, cCodB, cNumRemesa
    FROM    bitacoraPld
    WHERE   numconfirmacion = pNumRemesa
    IF TRIM(cCodB) = 'WU_MES_OPE' OR TRIM(cCodB) = 'APP_MES_OPE' OR TRIM(cCodB) = 'BTS_MES_OPE' THEN
        LET cDescCodB ='Numero de Operaciones Mensuales Superado';
    ELIF TRIM(cCodB) = 'WU_DIA_SUC_USD' OR TRIM(cCodB) = 'APP_DIA_SUC_USD' OR TRIM(cCodB) = 'BTS_DIA_SUC_USD' OR TRIM(cCodB) = 'APP_DIA_SUC_MN' OR TRIM(cCodB) = 'BTS_DIA_SUC_MN' OR TRIM(cCodB) = 'WU_DIA_SUC_MN' THEN 
        LET cDescCodB ='Limite Diario por Sucursal Superado';
    ELIF TRIM(cCodB) = 'WU_DIA_EDO_USD' OR TRIM(cCodB) = 'APP_DIA_EDO_USD' OR TRIM(cCodB) = 'BTS_DIA_EDO_USD' OR TRIM(cCodB) = 'APP_DIA_EDO_MN' OR TRIM(cCodB) = 'BTS_DIA_EDO_MN' OR TRIM(cCodB) = 'WU_DIA_EDO_MN' THEN 
        LET cDescCodB ='Limite por Estado Superado';
    ELIF TRIM(cCodB) = 'WU_LISTA' OR TRIM(cCodB) = 'APP_LISTA' OR TRIM(cCodB) = 'BTS_LISTA' THEN 
        LET cDescCodB ='Restriccion de Listas Negras';
    ELIF TRIM(cCodB) = 'WU_DIA_USD' OR TRIM(cCodB) = 'APP_DIA_USD' OR TRIM(cCodB) = 'BTS_DIA_USD' OR TRIM(cCodB) = 'APP_DIA_MN' OR TRIM(cCodB) = 'BTS_DIA_MN' OR TRIM(cCodB) = 'WU_DIA_MN'THEN 
        LET cDescCodB ='Limite Diario Superado';
    ELIF TRIM(cCodB) = 'WU_MES_USD' OR TRIM(cCodB) = 'APP_MES_USD' OR TRIM(cCodB) = 'BTS_MES_USD' OR TRIM(cCodB) = 'APP_MES_MN' OR TRIM(cCodB) = 'BTS_MES_MN' OR TRIM(cCodB) = 'WU_MES_MN'THEN 
        LET cDescCodB ='Limite Mensual Superado';
    ELSE 
        LET cDescCodB ='Limite superado';
    END IF;
    INSERT INTO TablaTemporal (tCodRet, tTipoOp, tTransacc, tNumRemesa, tFolioSuc, tSuc, tCanal, 
    tCod, tDescCod , tCodB , tDescCodB, tNumCliente, tNom1, tNom2, tApellPat , tApellMat, tMontoOrigen, 
    tMontoDestino, tEjecut, tFechaInsert) VALUES (cCodRet, cTipoOp, cTransacc, cNumRemesa, cFolioSuc, cSuc, cCanal, 
    cCod, cDescCod , cCodB , cDescCodB, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cMontoOrigen, 
    cMontoDestino, cEjecut, cFechaInsert) ;

    
    END FOREACH;
    DROP SYNONYM IF EXISTS bitacoraPld;
    
    FOREACH
    SELECT tCodRet, tTipoOp, tTransacc, tNumRemesa, tFolioSuc, tSuc, tCanal, 
            tCod, tDescCod , tCodB , tDescCodB, tNumCliente, tNom1, tNom2, tApellPat , tApellMat, tMontoOrigen, 
            tMontoDestino, tEjecut, tFechaInsert
    INTO    cCodRet, cTipoOp, cTransacc, cNumRemesa, cFolioSuc, cSuc, cCanal, 
            cCod, cDescCod , cCodB , cDescCodB, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cMontoOrigen, 
            cMontoDestino, cEjecut, cFechaInsert
    FROM TablaTemporal
    ORDER BY cFechaInsert DESC

    RETURN  cCodRet, cTipoOp, cTransacc, cNumRemesa, cFolioSuc, cSuc, cCanal, 
       cCod, cDescCod , cCodB , cDescCodB, cNumCliente, cNom1, cNom2, cApellPat , cApellMat, cMontoOrigen, 
       cMontoDestino, cEjecut, cFechaInsert WITH RESUME;
    END FOREACH;

    DROP SYNONYM IF EXISTS bitacoraPld;
    DROP SYNONYM IF EXISTS bitacoraBts;
    DROP SYNONYM IF EXISTS bitacoraWu;
    DROP SYNONYM IF EXISTS bitacoraAppriza;
    END;
END PROCEDURE
		;