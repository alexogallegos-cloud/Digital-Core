CREATE PROCEDURE "informix".sp_activa_insertos_fijos(pEmpresa CHAR(3),dtFechaCalculo DATE)
		RETURNING CHAR(5) AS resultado;
--          CHAR(80) AS mensaje;

DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(5); 
DEFINE vvcCod_ret            CHAR(5); 
DEFINE vvvCodRet             CHAR(5); 
--DEFINE cMensajeRet           CHAR(80);
DEFINE cmensaje              CHAR(80);
DEFINE vvvMensaje            CHAR(80);
DEFINE cNumCredito           CHAR(20);
DEFINE cInsertoFijo          CHAR(06);
DEFINE cInsertoTabla         CHAR(15);
DEFINE cInsertoNuevo         CHAR(15);
DEFINE cInsertoTemp          CHAR(09);
DEFINE iPagosVenc            INTEGER;
DEFINE icontador             integer;
DEFINE vsituacion            CHAR(1);
DEFINE cproceso              CHAR(4);
DEFINE vempresa              CHAR(3);
DEFINE ccod_ret              CHAR(5);
DEFINE vsitactualiza         CHAR(1);

LET vempresa = '001'; 
LET cproceso = '3001';   
LET iSqlErr=0;
LET iIsamErr=0;
LET cErrorInfo="";
LET cCodRet= '00000';
LET ccod_ret= '00000';
--LET cMensajeRet= 'Se realizó la consulta correctamente';
LET cMensaje = 'exitoso';
LET cNumCredito="";
LET cInsertoFijo='000000';
LET cInsertoTabla='0';
LET cInsertoNuevo='000000000000000';
LET cInsertoTemp='0';
LET iPagosVenc=0;
LET cInsertoTabla=0;
LET icontador = -1;
LET vsituacion = '';
LET vvvCodRet = '00000';
LET vvvMensaje = '';
LET vsitactualiza = '';

--SET DEBUG FILE TO "/home/informix/jtrujillo/sp_marcaclientes_inserto.out";
--TRACE ON; 

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
                RETURNING vvcCod_ret;
        END IF;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
    RETURNING vvcCod_ret;

    CALL bdicred:sp_marcaclientes_inserto(dtFechaCalculo)
    RETURNING vvvCodRet, vvvMensaje;

    -- Se obtienen los créditos que estan marcados con el grupo A, es decir marcados para enviar insertos.
    SET ISOLATION TO dirty READ;

    --AGREGAR FOREACH REQ 1 //   actualiza  sd_marcaje 5 = '000100' // 1 = '100000'
    FOREACH WITH HOLD
        SELECT mto_fin_ven_trasp, num_credito
            INTO iPagosVenc, cNumCredito
            FROM bdicred:sd_maesdoshist 
            WHERE fecha = dtFechaCalculo
            AND mto_fin_ven_trasp IN (1,5)  -- Codigo?? 1,5 ???
            
        IF iPagosVenc = 1 THEN 
            LET cInsertoFijo = '100000';
        ELIF iPagosVenc = 5 THEN 
            LET cInsertoFijo = '000100';
        END IF;

        SELECT insertos 
            INTO cInsertoTabla
            FROM bdicred:sd_marcaje 
            WHERE empresa = pEmpresa --mod cas
            AND num_credito = cNumCredito 
            AND fecha_emision = dtFechaCalculo;

        IF (icontador = -1) THEN BEGIN WORK; end if;

        IF cInsertoTabla IS NOT NULL THEN
            LET cInsertoTemp = SubStr(cInsertoTabla , 7 , 9);
            LET cInsertoNuevo = TRIM(cInsertoFijo) || TRIM(cInsertoTemp);

            UPDATE bdicred:sd_marcaje
                SET insertos = cInsertoNuevo 
                WHERE empresa=pEmpresa
                AND num_credito = cNumCredito 
                AND fecha_emision = dtFechaCalculo;

        ELSE
            LET cInsertoNuevo = TRIM(cInsertoFijo) || '000000000';
            INSERT INTO bdicred:sd_marcaje (empresa,num_credito,fecha_emision,posicion,insertos)
                VALUES (pEmpresa,cNumCredito,dtFechaCalculo,0,cInsertoNuevo); 
        END IF;
    
        LET icontador = icontador + 1;

        IF (icontador >= 60000) THEN
            COMMIT WORK;
            UPDATE statistics medium FOR TABLE sd_marcaje;
            LET icontador = 1;
            BEGIN WORK;
        END IF;

    END FOREACH;
    if (icontador > 0) then
        commit work;
    end if;

    LET icontador = -1;
    FOREACH WITH HOLD
        SELECT numcred, situacion, causa, cvesitesporigen  -- No_Cred, situacion(a,b), vcausa(Mora), inserto
            INTO cNumCredito, vsituacion, iPagosVenc, cInsertoFijo
            FROM bdisitesp:se_ctessitespcred
            WHERE situacion IN ('A','B')
             AND sucursal = situacion  -- Si no inserta o actualiza un grupo B en sd_marcaje, es correcto.
                                       
        SELECT insertos 
            INTO cInsertoTabla
            FROM bdicred:sd_marcaje 
            WHERE empresa     = pEmpresa --mod cas
            AND num_credito   = cNumCredito 
            AND fecha_emision = dtFechaCalculo;

        IF (icontador = -1) THEN BEGIN WORK; END IF;

        IF cInsertoTabla IS NOT NULL THEN   
            LET cInsertoTemp = SubStr(cInsertoTabla , 7 , 9); -- Insertos especiales del 7 en adelante
            LET cInsertoNuevo = TRIM(cInsertoFijo) || TRIM(cInsertoTemp);  

            UPDATE bdicred:sd_marcaje
                SET insertos = cInsertoNuevo 
                WHERE empresa     = pEmpresa --mod cas
                AND num_credito   = cNumCredito 
                AND fecha_emision = dtFechaCalculo;
        ELSE
            LET cInsertoNuevo = TRIM(cInsertoFijo) || '000000000';
            INSERT INTO bdicred:sd_marcaje (empresa,num_credito,fecha_emision,posicion,insertos)
                VALUES (pEmpresa,cNumCredito,dtFechaCalculo,0,cInsertoNuevo); 
        END IF;
			
        LET icontador = icontador + 1;

        IF (icontador >= 60000) THEN
            COMMIT WORK;
            UPDATE statistics medium FOR TABLE sd_marcaje;
            LET icontador = 1;
            BEGIN WORK;
        END IF;

    END FOREACH;

    IF (icontador > 0) THEN
        COMMIT WORK;
    END IF;

    UPDATE statistics medium FOR TABLE sd_marcaje;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje , '03')
        RETURNING vvcCod_ret;
    
    RETURN cCodRet;

--,cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener',
'el calculo de la reserva',
'AUTOR : ',
'FECHA : 05/MARZO/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_marcaclientes_inserto(dtFechaCalculo DATE)
       RETURNING CHAR(6), CHAR(150);

DEFINE vCodRet                  CHAR(6);
DEFINE vvcCod_ret               CHAR(6);
DEFINE vmensaje                 CHAR(150);
DEFINE sql_err                  INTEGER;
DEFINE isam_err                 INTEGER;
DEFINE error_info               VARCHAR(150);
DEFINE vvencido                 INTEGER;
DEFINE vnumero_region           INTEGER;
DEFINE vnoventa_porciento       INTEGER;
DEFINE vdiez_porciento          INTEGER;
DEFINE vvnumero_region          INTEGER;
DEFINE vvvencido                INTEGER;
DEFINE vvnoventa_porciento      INTEGER;
DEFINE vvdiez_porciento         INTEGER;
DEFINE vempresa                 CHAR(3);
DEFINE cproceso                 CHAR(4);
DEFINE vcred_marcados           INTEGER;
DEFINE vvnoventa_porcientonvo   INTEGER;
DEFINE sParam_No_Mora           SMALLINT;

--SET DEBUG FILE TO "/ids10_uc9/jtrujillo/sp_marcaclientes_inserto.out";
--TRACE ON;

LET vmensaje                = 'PROCESO EXITOSO';
LET vCodRet                 = '000000';
LET vvcCod_ret              = '000000';
LET vvencido                = 0;
LET vnoventa_porciento      = 0;
LET vdiez_porciento         = 0;
LET vnumero_region          = 0;
LET vvnumero_region         = 0;
LET vvvencido               = 0;
LET vvnoventa_porciento     = 0;
LET vvdiez_porciento        = 0;
LEt vempresa                = '001';
LET cproceso                = '0075';  
LET vcred_marcados          = 0;
LEt vvnoventa_porcientonvo  = 0;
LET sParam_No_Mora          = '';

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET vcodret  = sql_err;
        LET vmensaje  = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, vCodRet, vMensaje, '02')
            RETURNING vvcCod_ret;
        RETURN vCodRet, vMensaje;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, vCodRet, vMensaje, '01')
        RETURNING vvcCod_ret;

    FOREACH
        SELECT causa INTO sParam_No_Mora 
                FROM bdisitesp:se_ctessitespcred WHERE situacion IN ('A','B')  GROUP BY causa

        INSERT INTO bdisitesp:se_ctessitespcred_his
            SELECT 0, tipomovto, numcte, numcred, empresa, situacion, causa, cvesitesporigen, sucursal
                    ,nombreefectuo ,usralta, fchalta, usrmodifica, fchmodifica
            FROM bdisitesp:se_ctessitespcred
            WHERE situacion IN ('A', 'B')
            AND causa = sParam_No_Mora;
  
        DELETE bdisitesp:se_ctessitespcred WHERE situacion IN ('A', 'B') AND causa = sParam_No_Mora;
  
    END FOREACH;
  
    SET ISOLATION TO dirty READ;

    SELECT a.numcte, a.num_credito, b.mto_fin_ven_trasp::integer vencido, e.numero_region::integer numero_region, ins.inserto, ins.sitactualiza
        FROM bdicred:sd_maecred a,
            bdicred:sd_maesdoshist b,
            bdinteg:si_direcciones_actual d,
            bdinteg:si_catciudades e, 
            bdicred:sd_parametros_insertos ins
        WHERE a.empresa = b.empresa
        AND a.num_credito = b.num_credito
        AND b.fecha = dtFechaCalculo
        AND b.mto_fin_ven_trasp = ins.no_mora
        AND d.numcte = a.numcte
        AND d.tipo_dir = 1
        AND e.numerociudad = d.numerociudad
        AND e.numero_region  = ins.region
        --AND ins.inserto <> '000000'  --' ???
      INTO TEMP tmp_dir_cte WITH NO LOG;

    TRUNCATE bdicred:sd_insertoregion;

    SET ISOLATION TO DIRTY READ;

    FOREACH
        SELECT dir.numero_region, dir.vencido, ROUND((COUNT(dir.vencido) * (ins.Porc_Si * 0.01))), ROUND((COUNT(dir.vencido) * ((100 - ins.Porc_Si) * 0.01)))
            INTO vnumero_region, vvencido, vnoventa_porciento, vdiez_porciento
            FROM tmp_dir_cte dir, bdicred:sd_parametros_insertos ins
            WHERE dir.numero_region = ins.region
              AND dir.vencido = ins.No_Mora
            GROUP BY dir.vencido, dir.numero_region, ins.Porc_Si

        /*  SELECT numero_region, vencido, ROUND((COUNT(vencido) * .90)), ROUND((COUNT(vencido) * .10))
        INTO vnumero_region, vvencido, vnoventa_porciento, vdiez_porciento
        FROM tmp_dir_cte
        GROUP BY vencido, numero_region  */

        INSERT INTO bdicred:sd_insertoregion(numero_region, vencido, noventa_porciento, diez_porciento)
            VALUES(vnumero_region, vvencido, vnoventa_porciento, vdiez_porciento);

    END FOREACH;

    SET ISOLATION TO DIRTY READ;

    FOREACH WITH HOLD    
        SELECT numero_region, vencido, noventa_porciento, diez_porciento
            INTO vvnumero_region, vvvencido, vvnoventa_porciento, vvdiez_porciento
            FROM bdicred:sd_insertoregion

        BEGIN WORK;
                                        -- bdisitesp:se_ctessitespcred.cvesitesporigen (contiene el inserto), sucursal el dato a actualizar
        INSERT INTO bdisitesp:se_ctessitespcred
            SELECT first vvnoventa_porciento 0, numcte, '001', num_credito, 'A', vvvencido, inserto, sitactualiza, 'M', USER, USER, TODAY, '', ''
            FROM tmp_dir_cte
            WHERE vencido = vvvencido
            AND numero_region = vvnumero_region
            AND num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred_his  where situacion = 'A' and causa = vvvencido);

        LET vcred_marcados = 0;

        SELECT count(numcte) 
            INTO vcred_marcados
            FROM tmp_dir_cte
            WHERE vencido = vvvencido
            AND numero_region = vvnumero_region
            AND num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred  where situacion = 'A' and causa = vvvencido);

        LET vvnoventa_porcientonvo = 0;
        LEt vvnoventa_porcientonvo = vvnoventa_porciento - vcred_marcados;
            
        IF vvnoventa_porcientonvo > 0 THEN

            SELECT 0 idmvto, numcte, '001' empresa, num_credito numcred, 'A' situacion, vvvencido causa, inserto inserto, sitactualiza sucursal, 'M' tipomovto, USER nombreefectuo, USER usralta, TODAY fchalta, '' usrmodifica, '' fchmodifica
                FROM tmp_dir_cte
                WHERE vencido = vvvencido
                AND numero_region = vvnumero_region
                AND num_credito NOT IN (SELECT numcred FROM bdisitesp:se_ctessitespcred where situacion = 'A' and causa = vvvencido)
                INTO temp paso2 with no log;

            INSERT INTO bdisitesp:se_ctessitespcred select limit vvnoventa_porcientonvo * from  paso2;
                DROP TABLE paso2;
        END IF;

        INSERT INTO bdisitesp:se_ctessitespcred
            SELECT 0, numcte, '001', num_credito, 'B', vvvencido, '000000', sitactualiza, 'M', USER, USER, TODAY, '', ''
            FROM tmp_dir_cte
            WHERE vencido = vvvencido
            AND numero_region = vvnumero_region
            AND num_credito NOT IN (SELECT numcred FROM bdisitesp:se_ctessitespcred  where situacion = 'A' and causa = vvvencido);

        COMMIT WORK;
        UPDATE statistics medium FOR TABLE bdisitesp:se_ctessitespcred;

    END FOREACH;
END

    DROP TABLE tmp_dir_cte;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, vCodRet, vMensaje, '03')
        RETURNING vvcCod_ret;

    RETURN vCodRet, vMensaje;

END PROCEDURE;