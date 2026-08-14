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