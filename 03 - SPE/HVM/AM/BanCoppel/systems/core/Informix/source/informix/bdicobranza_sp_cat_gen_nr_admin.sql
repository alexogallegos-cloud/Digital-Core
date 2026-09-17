CREATE PROCEDURE "informix".sp_cat_gen_nr_admin(pfechacorte date)
RETURNING char(6), char(150);

-- Modificado por: MAHR
-- Fecha: Noviembre 2011
-- Modificacion: Se agrega el producto para que se ejecuten Reestructura y Prestamo Personal en el proceso. 
-- Fecha de Modificacion: Ene 2012. Se agrega el producto credinomina al tipo cobranza = R

--execute PROCEDURE "informix".sp_cat_gen_nr_admin(mdy('11','01','2014'))

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(150);
DEFINE cMensaje             CHAR(150);
DEFINE cMensajeTel          CHAR(150);
DEFINE cCod_ret             CHAR(6);
DEFINE vvccod_ret           CHAR(6);
DEFINE cExito               CHAR(6);
DEFINE cProceso             CHAR(30);
------------------------------------------------------------
DEFINE  vlCodigo            CHAR(5);
DEFINE  vlDecCodigo         CHAR(150);
------------------------------------------------------------
------------------------------------------------------------
DEFINE vempresa             CHAR(3);
DEFINE vnumcte              CHAR(20);
DEFINE vnum_credito         CHAR(20);
DEFINE vsituacion_car       CHAR(10);
-------------------------------------------------------------
DEFINE vkeys                INTEGER;
-------------------------------------------------------------
DEFINE vtcCod_ret           CHAR(5);
DEFINE vmto_fin_ven_trasp   SMALLINT;
DEFINE pFecha               DATE;
DEFINE cNum_producto        CHAR(4);
DEFINE cNum_ProdCampa       CHAR(4);
DEFINE iCuentasExcluidasXSaldos INTEGER;
DEFINE iCuentasCobranzaR    INTEGER;
DEFINE iCuentasRegistradas  INTEGER;
DEFINE dSaldoVencido        DECIMAL(18,2);
DEFINE icuentasprocesadas   INTEGER;
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
DEFINE pfechacorteAnt       DATE;
DEFINE iTotalAProcesar		INTEGER;
DEFINE cDigitos_selec       CHAR(2);
DEFINE vNumcte_existe       CHAR(20);

--SET DEBUG FILE TO 'sp_cat_gen_nr_admin.out';
--TRACE ON;

LET cCod_ret      = '000000';
LET sql_err       = 0;
LET isam_err      = 0;
LET error_info    = '';
LET cMensaje      = 'PROCESO EXITOSO';
LET cProceso      = '0030';
LET cExito        = '000000';
LET vempresa      = '001';
LET vkeys         = 0;
LET vtcCod_ret	  = '00000';
LET cMensajeTel   = '';
LET cNum_ProdCampa = '';
LET iCuentasExcluidasXSaldos = 0;
LET iCuentasCobranzaR = 0;
LET iCuentasRegistradas = 0;
LET icuentasprocesadas = 0;
LET dSaldoVencido       = 0;
LET P_COD_RET   = '000000';
LET P_MENSAJE   = 'El proceso carga CAT CUENTAS PLAZO Y REEST. campaÃÂ±a ADMIN. se realizÃÂ³ correctamente.';
LET iTotalAProcesar = 0;
LET cDigitos_selec = '';
LET vNumcte_existe = '';

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
                RETURNING vvcCod_ret;
        RETURN cCod_ret, cMensaje;
    END EXCEPTION;

/*    SELECT Fecha_Hoy INTO pFecha
        FROM bdinteg:si_fechas WHERE empresa = vempresa;*/
		
/*    SELECT valor_numerico INTO vsituacion_car
        FROM bdicobranza:cb_param_campania
        WHERE empresa = vempresa
            AND grupo_parametro= 'REESTRUCTU' AND num_parametro= 1 AND tipo_campania= 1;
*/
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
            RETURNING vvcCod_ret;

    if vvcCod_ret != '000000' then
       let P_COD_RET = vvcCod_ret;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

    LET pfechacorteAnt = pfechacorte - 1 UNITS DAY;

    ----------------------------------- DATOS del CLIENTE --------------------------------------------
    SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
    FOREACH     -- Ejecuta para cada producto de la campaÃÂ±a Cobranza = R : '6011', '6300','6400'
        SELECT valor_numerico::integer INTO cNum_ProdCampa
            FROM bdicobranza:cb_param_campania WHERE empresa = vempresa AND tipo_campania = 1
            AND grupo_parametro = 'TIPOCOBCAT' AND valor_alfabetico = 'R'

{            SELECT d.numcte, d.num_credito, a.mto_fin_ven_trasp, d.num_producto
                INTO vnumcte, vnum_credito, vmto_fin_ven_trasp, cNum_producto
                FROM bdicred:sd_maecredcrd d, bdicred:sd_maesdoscrd a, bdicred:sd_maecredanexocrd c
                WHERE d.empresa = a.empresa
                    AND d.num_credito = a.num_credito
                    AND d.empresa = c.empresa
                    AND d.num_credito = c.num_credito
                    AND d.status_cred IN ('BT','BA','VP','E1','E2','E3')
                    AND a.monto_vencido + a.mto_venc_trasp > 5
                    AND d.num_producto = cNum_ProdCampa -- IN ('6011','6300','6400')
                    --AND c.dia_corte  + 1 = day(pfechacorte)
                    AND c.dia_corte = day(pfechacorte - 1 units day)}

		SELECT count(*) INTO iTotalAProcesar
		FROM bdicred:sd_maecredcrd d
		INNER JOIN bdicred:sd_maecredanexocrd c on c.empresa=d.empresa and c.num_credito=d.num_credito and c.dia_corte = DAY(pfechacorteAnt)
		INNER JOIN bdicred:sd_maesdoscrd e on e.num_credito=d.num_credito 
		--WHERE d.empresa     = vempresa
		WHERE d.fecha_apertura > mdy(01,01,1900)
		AND d.num_credito >= ''
		AND d.status_cred IN ('BT','BA','VP','E1','E2','E3')
		AND (e.monto_vencido + e.mto_venc_trasp) > 0
		AND d.num_producto= cNum_ProdCampa; -- IN ('6011','6300','6400')


        LET cMensaje = 'TOTAL Cuentas a procesar ' ||cNum_ProdCampa || ' : ' ||iTotalAProcesar;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING vvcCod_ret;
					
        FOREACH
            SELECT {+AVOID_FULL(bdicred:sd_maecredcrd)} d.numcte, d.num_credito, a.mto_fin_ven_trasp, d.num_producto ,a.monto_vencido + a.mto_venc_trasp saldo_vencido
                INTO vnumcte, vnum_credito, vmto_fin_ven_trasp, cNum_producto, dSaldoVencido
                FROM bdicred:sd_maecredcrd d, bdicred:sd_maesdoscrd a, bdicred:sd_maecredanexocrd c
                WHERE d.empresa     = vempresa
--                  AND d.num_credito >= ''
                  AND a.empresa     = d.empresa
                  AND a.num_credito = d.num_credito
                  AND c.empresa     = d.empresa
                  AND c.num_credito = d.num_credito
				  AND d.status_cred IN ('BT','BA','VP','E1','E2','E3')
				  AND (a.monto_vencido + a.mto_venc_trasp) > 0				  
				  AND d.num_producto= cNum_ProdCampa -- IN ('6011','6300','6400')
--                  AND c.dia_corte   = day(pfechacorte)
                  AND c.dia_corte >= case when pfechacorteAnt - 1 units day in (select fecha from bdinteg:si_feriado where empresa = vempresa and laborable = 'N')  then day(pfechacorteAnt - 1 units day) else day(pfechacorteAnt) end
                  AND c.dia_corte < case when month(pfechacorteAnt) <> month(pfechacorte) then 32 else day(pfechacorte) end

            LET iCuentasProcesadas = iCuentasProcesadas + 1;

            IF dSaldoVencido <= 5 THEN
               LET iCuentasExcluidasXSaldos = iCuentasExcluidasXSaldos + 1;
               CONTINUE foreach;
            END IF;

			SELECT numcte INTO vNumcte_existe 
			FROM bdicobranza:cb_cat_directorio_cte 
            WHERE numcte = vnumcte -- AND d.num_credito = vnum_credito
            AND fecha_insert = pfechacorte AND tipo_cobranza = 'R';
			
			IF nvl(vNumcte_existe,'') = '' THEN
            --IF NOT EXISTS (SELECT d.numcte, d.num_credito FROM bdicobranza:cb_cat_directorio_cte d
            --                        WHERE d.numcte = vnumcte -- AND d.num_credito = vnum_credito
            --                        AND fecha_insert = pfechacorte AND tipo_cobranza = 'R') THEN
--          --                          AND fecha_insert = pfecha AND tipo_cobranza = 'R') THEN
                INSERT INTO bdicobranza:cb_cat_directorio_cte
                                 (empresa, tipo_cobranza, numcte, fecha_insert, num_credito, puntualidad, eficiencia, calificacion, pago_venc, prioridad,
                                  tipo_logica, /*keys, */num_vuelta, usuario_insert, status_cliente, tipo_movto, num_producto, digitos_selec)
                      VALUES(vempresa, 'R', vnumcte, pfechacorte, vnum_credito, '0', 0,0, vmto_fin_ven_trasp, 0, 0,/* vkeys,*/ 0, USER, 'AC', 0, cNum_producto, SUBSTR(vnumcte,8,2));
--                      VALUES(vempresa, 'R', vnumcte, pFecha, vnum_credito, '0', 0,0, vmto_fin_ven_trasp, 0, 0,/* vkeys,*/ 0, USER, 'AC', 0, cNum_producto);
               LET iCuentasRegistradas = iCuentasRegistradas + 1;
            ELSE
               LET iCuentasCobranzaR = iCuentasCobranzaR + 1;
            END IF;
        END FOREACH;

--Genera cifras de control
        if iCuentasProcesadas > 0 then
           let cMensaje = 'TOTAL Cuentas procesadas ' ||cNum_ProdCampa || ' : ' ||iCuentasProcesadas;
           let cMensaje = trim(cMensaje) ||'    Cuentas enviadas CAT : ' ||iCuentasRegistradas;
           CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING vvcCod_ret;
           let cMensaje = '    Cuentas excluidas por saldo vencido <= 5 : ' ||iCuentasExcluidasXSaldos;
           let cMensaje = trim(cMensaje) ||'    Cuentas en cobranza R : ' ||iCuentasCobranzaR;
           CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING vvcCod_ret;
        end if;
--Genera cifras de control

        LET iCuentasProcesadas          = 0;
        LET iCuentasRegistradas         = 0;
        LET iCuentasExcluidasXSaldos    = 0;
        LET iCuentasCobranzaR           = 0;
		LET iTotalAProcesar 			= 0;
    END FOREACH;        
/* MACF
    CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso,'000000', 'INICIA PROCESO TIPO LOGICA','02' )
    RETURNING vvcCod_ret;

    CALL bdicobranza:sp_cat_tipologicacte(vempresa,'R') returning vlCodigo, vlDecCodigo ;

    CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso,vlCodigo, 'FINALIZA PROCESO TIPO LOGICA','02' )
    RETURNING vvcCod_ret;


    CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso,'000000', 'INICIA PROCESO PRIORIDAD','02' )
    RETURNING vvcCod_ret;

    call bdicobranza:sp_cat_prioridadcte('R') returning vlCodigo, vlDecCodigo;

    CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso,vlCodigo, 'FINALIZA PROCESO PRIORIDAD','02' )
    RETURNING vvcCod_ret;

	CALL sp_inserta_bitacora_cob(vempresa, cProceso, '00000', 'INICIA PROCESO GENERACION DE TESTIGO','02')
	RETURNING vvcCod_ret;
	CALL "informix".sp_cat_genera_testigo('R') RETURNING vlCodigo;
	CALL sp_inserta_bitacora_cob(vempresa, cProceso, vlCodigo, 'FINALIZA PROCESO GENERACION DE TESTIGO','02')
	RETURNING vvcCod_ret;
	
    IF cCod_ret =cExito THEN

        CALL bdicobranza:sp_carga_telefonos('R') RETURNING vvcCod_ret, cMensajeTel;

        CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso,'', '','03' )
            RETURNING vvcCod_ret;

    ELSE
        CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso,cCod_ret, cMensaje,'02' )
            RETURNING vvcCod_ret;
    END IF;
*/ --MACF

    if vvcCod_ret != '000000' then
       let P_COD_RET = vvcCod_ret;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;
--    RETURN cCod_ret, cMensaje;

END;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.

END PROCEDURE;