CREATE PROCEDURE "informix".sp_cat_gen_info_prev()
       RETURNING CHAR(6), CHAR(150);
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: MAHR. Abril 2012 Se cambia a sp_inserta_bitacora_cob para insercion en la bitacora. Se valida que no exista registro previo asu inserción.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--MODIFICADO POR: Abrham Lopez L.
--FECHA: 17-07-2012.
--CAMBIO: SE MANDA LLAMAR EL sp_cat_ivr_gen_archbase PARA QUE GENERE EL ARCHIVO AL MOMENTO DE TERMINAR DE INSERTAR LOS DATOS EN LA TABLA CB_CAT_DIRECTORIO_CTE...
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE Bit_Cod_ret                  CHAR(6);
DEFINE vtFechaCorte                 DATE;
DEFINE vtFechaLimite                DATE;
DEFINE vtFechaCorteTGC 				DATE;
DEFINE vtFechaLimiteTGC 			DATE;
DEFINE monto_ini                    DECIMAL(18,2);
DEFINE monto_fin                    DECIMAL(18,2);
DEFINE cExito                       CHAR(6);
DEFINE cProceso                     CHAR(4);
DEFINE vlCodigo                     CHAR(5);
DEFINE vlDecCodigo                  CHAR(80);
DEFINE vempresa                     CHAR(3);
DEFINE vnumcte                      CHAR(20);
DEFINE vnum_credito                 CHAR(20);
--DEFINE vdia							DATE;
DEFINE vsituacion                   CHAR(1);
DEFINE vcausa                       SMALLINT;
DEFINE vinstruccion                 CHAR(1);
--ALL decalracion de variables
DEFINE pFecha                       DATE;
DEFINE pFechaTGC 					DATE; 
DEFINE pFecha_hoy                   DATE; 
DEFINE vVencidos                    SMALLINT;
DEFINE vMesesconsultar              SMALLINT;
DEFINE vVenc_mes_anterior           SMALLINT;
DEFINE pNumcte                      CHAR(20);
DEFINE vnum_producto                CHAR(4);
DEFINE vBandera 					CHAR(1);


--SET DEBUG FILE TO '/aplicacion/resplogifx/archivoscartera/CARGATELEFONOS.out';
--TRACE ON;

LET cCod_ret        = '000000';
LET Bit_Cod_ret     = '000000';
LET sql_err         = 0;
LET cMensaje        = '';
LET vnumcte         = '';
LET vnum_credito    = '';
LET vtFechaLimite   = MDY(MONTH(CURRENT),16,YEAR(CURRENT));
LET vtFechaCorte    = (vtFechaLimite - 1 UNITS MONTH)::DATE;
LET vtFechaCorte    = MDY(MONTH(vtFechaCorte),20,YEAR(vtFechaCorte));
LET vtFechaCorte    = vtFechaCorte;
LET vtFechaLimite   = vtFechaLimite;
LET vtFechaLimiteTGC = MDY(MONTH(CURRENT),14,YEAR(CURRENT));
LET vtFechaCorteTGC = (vtFechaLimiteTGC - 1 UNITS MONTH)::DATE;
LET vtFechaCorteTGC = MDY(MONTH(vtFechaCorteTGC),18,YEAR(vtFechaCorteTGC));
LET cMensaje        = 'PROCESO EXITOSO';
LET cProceso        = '0003';
LET cExito          = '000000';
LET vempresa        = '001';
LET pNumcte         = '';
LET vnum_producto   = '';
LET pFechaTGC 		= DATE(1);
LET vBandera 		= '';
	  

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
	    LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02') RETURNING Bit_Cod_ret;
		RETURN cCod_ret, cMensaje;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01') RETURNING Bit_Cod_ret;

    SELECT valor_numerico
        INTO monto_ini
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = vempresa
        AND grupo_parametro= 'ARCHIVOS'
        AND num_parametro= 1
        AND tipo_campania= 2;

    SELECT valor_numerico
        INTO monto_fin
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = vempresa
        AND grupo_parametro= 'ARCHIVOS'
        AND num_parametro= 2
        AND tipo_campania= 2;

    -----------Si existe se elimina la los datos en tabla-------------------------------

	--SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:"informix".sysshmvals;
    ---------------------------------------------------------------------------------
    ---ALL Modificado 19 de mayo 2011
        --ALL  sacar la fecha del dia de hoy
    Select Fecha_Hoy
        Into pFecha
        From bdicred:"informix".sd_fechas
        Where empresa = '001';
    LET pFecha_hoy = TODAY;  -- Inserta en tabla con today.
		
        --ALL esta consulta saca los meses a consultar con un numero de parametro para no dejar la fecha fija        
    select valor_numerico 
        into vMesesconsultar
        from bdicobranza:"informix".cb_param_campania
        where grupo_parametro = 'MESVENCIDO'
        and num_parametro = 1
        and tipo_campania = 1;
        
    --ALL se arma la fecha a partir de la cual se van a consultar los 3 meses atras       
    let pFecha = date (vtFechaCorte)  - (vMesesconsultar) units month;
	let pFechaTGC = DATE(vtFechaCorteTGC)  - (vMesesconsultar) UNITS MONTH;
    ----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------

	SET ISOLATION TO dirty READ;
	FOREACH WITH HOLD
        SELECT {+INDEX (bdicred:sd_maecred maecred3)} a.numcte, a.num_credito, a.num_producto
	        INTO vnumcte, vnum_credito, vnum_producto
	        FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_maesdos b
	        WHERE a.empresa = b.empresa  
            AND a.empresa = vempresa
	        AND b.num_credito = a.num_credito
	        AND a.status_cred IN ('AA','E1')
			AND (b.monto_vencido + b.mto_venc_trasp) = 0
            --AND a.num_producto = '6001'
			AND a.num_producto IN ('6001','8100','8500') --a.L.L.sE AGREGA NUMERO PRODUCTO ORO RQI 27 019 TDC Oro 
	        AND b.monto_financiado BETWEEN monto_ini AND monto_fin
            AND a.numcte NOT IN (select numcte from bdicobranza:cb_excepcion_cte where empresa ='001' and cve_excepcion = 'GPO50M' )

        -- Valida que no exista el registro en la tabla cb_cat_directorio_cte 
        /*IF NOT EXISTS (SELECT d.numcte, d.num_credito FROM bdicobranza:cb_cat_directorio_cte d WHERE d.empresa = vempresa 
                            AND d.tipo_cobranza = 'P' AND d.numcte = vnumcte AND fecha_insert = pFecha_hoy ) THEN*/

		SELECT LIMIT 1 '1' INTO vBandera FROM bdicobranza:"informix".cb_cat_directorio_cte d WHERE d.empresa = vempresa AND d.tipo_cobranza = 'P' AND d.numcte = vnumcte AND fecha_insert = pFecha_hoy;

		IF (vBandera IS NULL OR vBandera = '' ) THEN

        ------------------------------------------------------------------------------------------------------------------------------------------------------  
            --ALL se le ingreso la consulta para validar el campo mto_fin_vig_trasp >=1 el cual indica que si tiene vencidos en ese mes                                     
            LET vVencidos = 0;
            LET vVenc_mes_anterior = 0;

			IF (vnum_producto = '8500') THEN
				SELECT COUNT(mto_fin_ven_trasp) INTO vVencidos
					FROM bdicred:"informix".sd_maesdoshist 
					WHERE fecha >= pFechaTGC 
					AND empresa = '001'
					AND num_credito = vnum_credito
					AND mto_fin_ven_trasp >= 1;
			ELSE
				select count(mto_fin_ven_trasp)into vVencidos
					from bdicred:"informix".sd_maesdoshist 
					where fecha >= pFecha 
					and empresa = '001'
					and num_credito = vnum_credito
					and mto_fin_ven_trasp >=1;
			END IF
        --------------------------------------------------------------------------------------------------------------------------------------------------
            LET vsituacion = NULL;
            LET vcausa     = NULL;

            SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 situacion,  causa
                INTO   vsituacion, vcausa
                FROM bdisitesp:"informix".se_ctessitespcte
                WHERE numcte = vnumcte;		

            LET vinstruccion = 1;
            --No se tomaran en cuenta los clientes con situacion T y causa 1. RQM 09 217
            IF vsituacion='T' AND vcausa=1 THEN
                CONTINUE FOREACH;
            ELSE
                IF ((vsituacion IS NOT NULL) AND (vcausa IS NOT NULL)) THEN
                    SELECT FIRST 1 instruccion
                        INTO vinstruccion
                        FROM bdisitesp:"informix".se_situacionaccion
    					WHERE situacion= vsituacion
        				AND causa= vcausa
            			AND idaccion = 9
                		AND empresa = vempresa;
                END IF;
                IF (vinstruccion = 1) THEN
                --ALL, se inserta el valor que tome la variable
                    IF  nvl(vVencidos,0) > 0 then
                        LET vVenc_mes_anterior = 1;
                    END IF;
  
                    --ALL Valida que los clientes tengan una linea de credito mayor o igual a 50 mil
                    INSERT INTO bdicobranza:"informix".cb_cat_directorio_cte 
                         (empresa, tipo_cobranza, numcte, fecha_insert, num_credito, puntualidad, eficiencia, calificacion, pago_venc, prioridad,
                          tipo_logica, keys, num_vuelta, usuario_insert, status_cliente, tipo_movto, venc_mes_anterior, num_producto)
                		VALUES(vempresa, 'P', vnumcte, TODAY, vnum_credito, '', 0, 0, 0, 0, 0, 0, 0, user, 'AC', 0, vVenc_mes_anterior, vnum_producto);
                END IF;
            END IF;
        END IF;
		LET vBandera = '';
    END FOREACH;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob (vempresa,cProceso,'000000', 'INICIA PROCESO TIPO LOGICA', '02' ) RETURNING Bit_Cod_ret;
    CALL bdicobranza:"informix".sp_cat_tipologicacte(vempresa,'P') returning vlCodigo, vlDecCodigo ;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob (vempresa,cProceso,vlCodigo, 'FINALIZA PROCESO TIPO LOGICA', '02' ) RETURNING Bit_Cod_ret;  

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob (vempresa,cProceso,'000000', 'INICIA PROCESO PRIORIDAD','02' ) RETURNING Bit_Cod_ret;  
    CALL bdicobranza:"informix".sp_cat_prioridadcte('P') returning vlCodigo, vlDecCodigo;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob (vempresa,cProceso,vlCodigo, 'FINALIZA PROCESO PRIORIDAD','02' ) RETURNING Bit_Cod_ret;  

    IF cCod_ret =cExito THEN
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob (vempresa,cProceso,'', '','03' ) RETURNING Bit_Cod_ret;  

        CALL bdicobranza:"informix".sp_carga_telefonos ('P') --A.L.L. Manda llamar el sp para cargar los telefonos de la ptipo_campania.
            RETURNING cCod_ret, cMensaje;  
    ELSE
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob (vempresa,cProceso,cCod_ret, cMensaje,'02' ) RETURNING Bit_Cod_ret;  
    END IF;
--A.L.L.SE MANDA LLAMAR EL sp_cat_ivr_gen_archbase
		-- Separar llamado a este proceso. MACF
    --CALL bdicobranza:"informix".sp_cat_ivr_gen_archbase(vempresa, pFecha_hoy,'P')
		--	RETURNING cCod_ret;
    RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE
DOCUMENT
'MODIFICA    : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se actualiza para excluir los clientes que se encuentren con una situacion especial T y causa 1',
'FECHA       : 08 de junio de 2010',
'VERSION     : 20110608.1852',
'BD          : BDICOBRANZA';

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