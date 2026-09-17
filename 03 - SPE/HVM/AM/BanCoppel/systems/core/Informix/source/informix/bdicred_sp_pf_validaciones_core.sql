CREATE PROCEDURE "informix".sp_pf_validaciones_core(pEmpresa    CHAR(3),
                                                pSucursal       CHAR(4), 
                                                pEjecutivo      CHAR(8),
                                                pCanal          SMALLINT,
                                                pNumCredito     CHAR(20),
                                                pValidaCompleta SMALLINT
                                                )
RETURNING   CHAR(5)         AS cod_ret,
            CHAR(80)        AS desc_ret,
            CHAR(9)         AS num_cte,
            CHAR(12)        AS num_credito,
            CHAR(4)         AS num_producto,
            DECIMAL(18,2)   AS monto_minimo,
            DATE            AS fecha_corte,
            LVARCHAR        AS promo_disponibles,
            LVARCHAR        AS transacc_disposicion,
            LVARCHAR        AS transacc_compras,
            LVARCHAR        AS transacc_cte,
            DATE            AS fecha_hoy;



    /********** DECLARACION DE VARIABLES ************/
    DEFINE iSqlErr       	            INTEGER;			-- CODIGO DE ERROR
    DEFINE cCodRet     		            CHAR(5); 			-- CODIGO DE RETORNO DE ERROR
    DEFINE cMensajeRet                  CHAR(80);           -- DESCRIPCION DEL CODIGO DE ERROR
    DEFINE c_CodigoRet_pp               CHAR(5);
    DEFINE cNumCredito                  CHAR(20);
    DEFINE cNumcte                      CHAR(9);
    DEFINE cNumProducto                 CHAR(4);
    DEFINE cDisponCred			        CHAR(1);
    DEFINE dtFechaHoy                   DATE;
    DEFINE dtFechaCorte                 DATE;
    DEFINE iNumPromo                    SMALLINT;
    DEFINE iDisposicionEfectivoApp      SMALLINT;
    DEFINE iComprasApp                  SMALLINT;
    DEFINE iPlazo                       SMALLINT;
    DEFINE cTempLst                     LVARCHAR;
    DEFINE cTempLstTrans        	    LVARCHAR;
    DEFINE dLstNumPromo                 LIST(SMALLINT NOT NULL);
    DEFINE dLstTransac                  LIST(VARCHAR(4) NOT NULL);
    DEFINE dLstPromociones              LIST(SMALLINT NOT NULL);
    DEFINE dLstTransacPromo     	    LIST(VARCHAR(4) NOT NULL);
    DEFINE dLstTransacDispo      	    LIST(VARCHAR(4) NOT NULL);
    DEFINE dLstTransacCompras      	    LIST(VARCHAR(4) NOT NULL);
    DEFINE dValorMinDiferir             DECIMAL(18,2);
    DEFINE dTasa                        DECIMAL(18,2);

    /********** VARIABLES CANAL APP  ************/
    DEFINE cEmpresa                     CHAR(3);
    DEFINE iCanalApp                    SMALLINT;
    DEFINE cSucursalApp                 CHAR(4);
    DEFINE cEjecutivoApp                CHAR(8);

    /***** VARIABLES DE CIERRE DE CREDITO *****/
    DEFINE cCierreCred      CHAR(1);
    DEFINE cStatusCred      CHAR(1);
    DEFINE cStatusPres      CHAR(1);
    DEFINE cCodRet3         CHAR(3);
    DEFINE dFechaCierreCred DATE;
    DEFINE dFechaCierrePres DATE;
    DEFINE dFechaHabilAnt   DATE;

    

    /********** INICIALIZACION DE VARIABLES ************/
    LET iSqlErr                     = 0;
    LET cCodRet                     = '00000';
    LET c_CodigoRet_pp              = '';
    LET cMensajeRet                 = 'PROCESO EXITOSO';
    LET dtFechaHoy                  = '';
    LET dtFechaCorte                = '';
    LET cNumCredito                 = '';
    LET cNumcte                     = '';
    LET cNumProducto                = '';
    LET cTempLst                    = '';
    LET cDisponCred                 = '';
    LET dValorMinDiferir            = 0.0;
    LET iDisposicionEfectivoApp     = 7;  --VARIABLE PARA DISPOSICION EN EFECTIVO
    LET iComprasApp                 = 8;  --VARIABLE PARA COMPRAS APP
    LET iNumPromo                   = 0;
    LET dLstNumPromo                = 'LIST{' || cTempLst ||'}';
    LET dLstTransac                 = 'LIST{}';
    LET dLstPromociones             = 'LIST{' || iDisposicionEfectivoApp ||','|| iComprasApp || '}';  
	LET dLstTransacDispo     		= 'LIST{}';
	LET dLstTransacCompras     		= 'LIST{}';
	LET dLstTransacPromo    		= 'LIST{}';
    LET iPlazo                      = 0;
    LET dTasa                       = 0.0;

    /********** VARIABLES CANAL APP  ************/
    LET cEmpresa                    = '001';
    LET iCanalApp                   = 17;
    LET cSucursalApp                = '5011';
    LET cEjecutivoApp               = 'transBPI';

    /***** VARIABLES DE CIERRE DE CREDITO *****/
    LET cCierreCred                 = '';
    LET cStatusCred                 = '';
    LET cStatusPres                 = '';
    LET cCodRet3                    = '000';
    LET dFechaCierreCred            = '';
    LET dFechaCierrePres            = '';
    LET dFechaHabilAnt              = '';




    BEGIN
        ON EXCEPTION  SET iSqlErr
            IF iSqlErr <> 0  THEN
                LET  cCodRet  = '00003';
                LET  cMensajeRet = 'ERROR EN LA EJECUCION DE VALIDACIONES PF';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
            END IF;
        END  EXCEPTION

        --SET DEBUG FILE TO "/home/e99807882/Pagos_fijos/sp_pf_validaciones_core.out";
        --TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        IF LENGTH(pEjecutivo) != 8 THEN
            LET cCodRet = '00001';
            LET cMensajeRet = 'LA LONGITUD DEL EJECUTIVO ES INCORRECTA';
            LET cNumcte = '';
            LET cNumCredito = '';
            LET cNumProducto = '';
            LET dValorMinDiferir = null;
            LET dtFechaCorte = null;
            LET dLstNumPromo = null;
            LET dLstTransacDispo = null;
            LET dLstTransacCompras =null;
            LET dLstTransac = null;
            LET dtFechaHoy = null;
            RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
        END IF;

        IF LENGTH(pSucursal) != 4  THEN
            LET cCodRet = '00001';
            LET cMensajeRet = 'LA LONGITUD DE LA SUCURSAL ES INCORRECTA';
            LET cNumcte = '';
            LET cNumCredito = '';
            LET cNumProducto = '';
            LET dValorMinDiferir = null;
            LET dtFechaCorte = null;
            LET dLstNumPromo = null;
            LET dLstTransacDispo = null;
            LET dLstTransacCompras =null;
            LET dLstTransac = null;
            LET dtFechaHoy = null;
            RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
        END IF;

        IF pCanal = iCanalApp  THEN
            IF  (nvl(pEmpresa, '')  <> cEmpresa      )  OR 
                (nvl(pSucursal,'')  <> cSucursalApp  )  OR 
                (nvl(pEjecutivo,'') <> cEjecutivoApp ) THEN

                LET  cCodRet  = '00022';
                LET  cMensajeRet = 'DATOS INVALIDOS PARA CANAL APP';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;   

            END IF;
        ELSE 
            LET  cCodRet  = '00023';
            LET  cMensajeRet = 'EL CANAL POR EL MOMENTO NO ESTA ACTIVO';
            LET cNumcte = '';
            LET cNumCredito = '';
            LET cNumProducto = '';
            LET dValorMinDiferir = null;
            LET dtFechaCorte = null;
            LET dLstNumPromo = null;
            LET dLstTransacDispo = null;
            LET dLstTransacCompras =null;
            LET dLstTransac = null;
            LET dtFechaHoy = null;
            RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy ;  
        END IF;

        SELECT NVL(ind_disponible,'0'),NVL(ind_cierre,'0'), fecha_hoy
		INTO cDisponCred, cCierreCred, dtFechaHoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pEmpresa;

        -- Obtenemos las fechas Maximas de credito y prestamo
        SELECT 
            MAX(CASE WHEN proceso = 'CierreCred'  THEN fecha END) AS fecha_cierre_cred,
            MAX(CASE WHEN proceso = 'CierrePrest' THEN fecha END) AS fecha_cierre_prest
        INTO dFechaCierreCred, dFechaCierrePres
        FROM bdicred:"informix".sd_contproc 
        WHERE empresa = '001' 
        AND proceso IN ('CierreCred', 'CierrePrest');

        -- Consultamos sus estatus
        -- Credito
        SELECT status_proc INTO cStatusCred FROM bdicred:"informix".sd_contproc 
        WHERE empresa = '001' AND proceso = 'CierreCred' and fecha = dFechaCierreCred; -- fecha_cierre_cred

        --Prestamos
        SELECT status_proc INTO cStatusPres FROM bdicred:"informix".sd_contproc 
        WHERE empresa = '001' AND proceso ='CierrePrest' and fecha = dFechaCierrePres; -- fecha_cierre_prest

        -- Fecha habil
        EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil((dtFechaHoy - 1),'-') INTO cCodRet3, dFechaHabilAnt;

        IF (dFechaCierrePres IS NULL OR dFechaCierrePres = '') OR (dFechaCierreCred IS NULL OR dFechaCierrePres  = '') THEN
            	LET cDisponCred = '0';
				LET cCodRet = '00040';
				LET cMensajeRet = 'SE ESTA EJECUTANDO EL CIERRE DE CREDITOS, INTENTE MAS TARDE';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
				RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
        END IF

        IF NOT (cCierreCred = '1' AND (dFechaCierrePres = dFechaHabilAnt AND UPPER(cStatusPres) = 'F') 
                                  AND (dFechaCierreCred = dFechaHabilAnt AND UPPER(cStatusCred) = 'F')) THEN

            	LET cDisponCred = '0';
				LET cCodRet = '00040';
				LET cMensajeRet = 'SE ESTA EJECUTANDO EL CIERRE DE CREDITOS, INTENTE MAS TARDE';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
				RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
        END IF;

        IF NVL(pNumCredito,'') <> '' THEN

            IF LENGTH(pNumCredito) != 12  THEN
                LET cCodRet = '00001';
                LET cMensajeRet = 'LA LONGITUD DEL NUMERO DE CREDITO ES INCORRECTA';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
            END IF;
            
            --
            SELECT cr.num_credito, num_producto, numcte
            INTO cNumCredito, cNumProducto, cNumcte
            FROM bdicred:"informix".sd_maecred cr inner join  sd_maesdos sd ON (cr.num_credito = sd.num_credito)
            WHERE cr.empresa = pEmpresa AND cr.num_credito = pNumCredito
            AND status_cred ='E1'
            AND sd.monto_vencido = 0;

        ELSE
            LET cNumCredito = pNumCredito;
        END IF;

        IF NVL(cNumCredito,'') = '' THEN
            LET cCodRet = '00439';
            LET cMensajeRet = 'NUMERO DE CREDITO NO ESTA VIGENTE O NO ES VALIDO';
            LET cNumcte = '';
            LET cNumCredito = '';
            LET cNumProducto = '';
            LET dValorMinDiferir = null;
            LET dtFechaCorte = null;
            LET dLstNumPromo = null;
            LET dLstTransacDispo = null;
            LET dLstTransacCompras =null;
            LET dLstTransac = null;
            LET dtFechaHoy = null;
            RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
        END IF

        IF pValidaCompleta = 1 THEN

            --OBTENEMOS EL VALOR MINIMO A DIFERIR
            SELECT valor
            INTO dValorMinDiferir
            FROM bdicred:"informix".sd_param	
            WHERE cod_param  = '029';
                
                --SE VALIDA EL MONTO MINIMO DE COMPRA.
            IF NVL(dValorMinDiferir,0.01) = 0.01 THEN
                LET cCodRet = '00002';          
                LET cMensajeRet = "ERROR AL OBTENER EL PARAMETRO DEL VALOR MINIMO A DIFERIR";
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
            END IF;

            FOREACH 
                SELECT num_promo
                INTO  iNumPromo
                FROM "informix".sd_prospectos
                WHERE num_promo IN dLstPromociones
                AND num_credito = pNumCredito
                AND dtFechaHoy >= fecha_ini
                AND dtFechaHoy <= fecha_fin
                ORDER BY num_promo ASC

                -- OBTENEMOS EL NUMERO DE PROMOCIONES
                IF EXISTS (SELECT nvl(1,0) as existe 
                            FROM "informix".sd_promocion 
                            WHERE num_promo = iNumPromo 
                            AND activo = 1 
                            AND dtFechaHoy >= fechaini_promo 
                            AND dtFechaHoy <= fechafin_promo) THEN
                    
                    --LA PROMOCION EXISTE PERO SE VALIDA QUE TENGA UNA TASA
                    FOREACH
                        EXECUTE PROCEDURE "informix".sp_pf_consulta_tasa_plazo_preferenciales(3, pEmpresa, pCanal, cNumCredito, cNumProducto, iNumPromo, dValorMinDiferir, 1, dtFechaHoy)
                        INTO c_CodigoRet_pp, dTasa, iPlazo

                        IF c_CodigoRet_pp :: INTEGER = 0 THEN 
                            LET cTempLst = TRIM(cTempLst) || iNumPromo || ',';
                        END IF;
                    END FOREACH
                END IF;
            END FOREACH;

            --AGREGAMOS LAS PROMOCIONES A LA LISTA.
            LET cTempLst  = SUBSTRING(cTempLst FROM 1 FOR LENGTH(cTempLst) - 1);
            LET dLstNumPromo = 'LIST{' || TRIM(cTempLst) || '}';

            --VALIDAMOS EN LA LISTA DE PROMOCIONES ESTEN VIGENTES.
            IF (CARDINALITY(dLstNumPromo) == 0 OR dLstNumPromo IS NULL)THEN
                LET cCodRet = '00020';
                LET cMensajeRet = 'EL CANDIDATO NO CUENTA CON PROMOCIONES VIGENTES';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;

                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
            END IF;

            IF EXISTS (SELECT 1 FROM "informix".sd_promocion_credito WHERE num_promo IN (3,6,9) AND status IN (0,2) AND num_credito = pNumCredito) THEN
                LET cCodRet = '00006';
                LET cMensajeRet = 'EL CLIENTE YA CUENTA CON PAGOS FIJOS DE TIPO SALDO ACTIVOS.';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
            END IF;

            -- OBTENEMOS LAS TRANSACCIONES DE LAS PROMOCIONES DISPOCION EN EFECTIVO APP y COMPRAS EN APP. 
            SELECT transacc
            INTO dLstTransacDispo
            FROM "informix".sd_movimientos_promo_camp  
            WHERE num_promo = iDisposicionEfectivoApp;

            SELECT transacc
            INTO dLstTransacCompras
            FROM "informix".sd_movimientos_promo_camp  
            WHERE num_promo = iComprasApp;

            LET cTempLst = '';

            IF 	(CARDINALITY(dLstTransacDispo) == 0 OR dLstTransacDispo IS NULL) OR 
                (CARDINALITY(dLstTransacCompras) == 0 OR dLstTransacCompras IS NULL) THEN
                LET cCodRet = '00021';
                LET cMensajeRet = 'NO SE ENCONTRARON TRANSACCIONES DISPONIBLES';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  

            END IF;

            -- OBTENEMOS UNICAMENTE LAS TRANSACCIONES PERTENECIENTES AL CLIENTE
            FOREACH
                SELECT {+AVOID_FULL ("informix".sd_movimientos_promo_camp) } transacc
                INTO dLstTransacPromo
                FROM "informix".sd_movimientos_promo_camp  
                WHERE num_promo IN dLstNumPromo

                LET cTempLst = cTempLst || REPLACE(REPLACE(dLstTransacPromo::LVARCHAR, 'LIST{',''), '}','') || ',' ;

            END FOREACH
            LET cTempLstTrans = SUBSTRING(cTempLst FROM 1 FOR LENGTH(cTempLst) - 1);
            LET dLstTransac = 'LIST{' || TRIM(cTempLstTrans) || '}';
            LET cTempLst = '';

            --SE VALIDA QUE LA FECHA HOY SEA IGUAL O MENOR QUE LA FECHA CORTE PARA CALCULAR EL RENGO DE FECHAS.
            IF DAY(dtFechaHoy)< 21 THEN         
                --SE CALCULA FECHA CORTE.
                EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaHoy, -2) INTO dtFechaCorte;
                IF TRIM(NVL(dtFechaCorte,'')) = '' THEN         
                    LET cCodRet = '00003';
                    LET cMensajeRet = "ERROR EN LA EJECUCION DE BDICRED:MONTHADD";
                    LET cNumcte = '';
                    LET cNumCredito = '';
                    LET cNumProducto = '';
                    LET dValorMinDiferir = null;
                    LET dtFechaCorte = null;
                    LET dLstNumPromo = null;
                    LET dLstTransacDispo = null;
                    LET dLstTransacCompras =null;
                    LET dLstTransac = null;
                    LET dtFechaHoy = null;
                    RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
                END IF;
                LET dtFechaCorte = MDY(MONTH(dtFechaCorte),20,YEAR(dtFechaCorte));
            ELSE
                EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaHoy, -1)
                INTO dtFechaCorte;
            END IF;
        END IF;
        RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
    END
END PROCEDURE 
DOCUMENT 'AUTOR: Jose Antonio RamiÂ­rez Franco',
'FECHA: 03/09/2025',
'DESCRIPCION:Este proceso se encarga de validar los pagos fijos para Credisoluciones con promociones de compra y disposicion de efectivo a traves del canal de la aplicacion movil (APP).',
'   1.Validacion de parametros: Se valida la longitud de los parametros de entrada.',
'   2.Validacion del canal: Se valida que el canal sea el 17 (canal de la APP).',
'   3.Verificacion de cierre: Se asegura que no haya un proceso de cierre de creditos en curso.',
'   4.Validacion de credito: Se verifica la existencia y vigencia del numero de credito.',
'   5.Validacion de promociones: Se comprueba si el credito tiene promociones vigentes.',
'   6.Validacion de valor minimo: Se valida el valor minimo de sd_param.',
'   7.Validacion de transacciones: Se verifica si existen transacciones registradas en sd_movimientos_promo_camp para las promociones de disposicion en efectivo y compras.',
'   8.Obtencion de fecha de corte: Se obtiene la fecha de corte y, en caso de error, se muestra un mensaje correspondiente.',
'FECHA: 28/01/2026',
'AUTOR: Jose Antonio Ramirez Franco',
'MODIFICACION: Actualizacion a la validacion de credito se anexa a la consulta que se valide los atrasos del cliente para dictaminar si es candidato a pagos fijos.',
'FECHA: 17/02/2026',
'AUTOR: Jose Antonio Ramirez Franco',
'MODIFICACION: Se anexa validacion en el proceso de cierre tanto de credito como prestamos.',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_sv_aprovisionamiento_oltp()
--EXECUTE PROCEDURE "informix".sp_sv_aprovisionamiento_oltp();
RETURNING VARCHAR (5) as rCODIGO_RETORNO, 
          VARCHAR (255) as rMENSAJE_RESPUESTA;

DEFINE vCODIGO_RETORNO VARCHAR(5);
DEFINE vMENSAJE_RETORNO VARCHAR(120);
DEFINE vsql             LVARCHAR(5000);
DEFINE vIndicadorProceso CHAR(10);	
DEFINE RUTA_ARCHIVOS     VARCHAR(100);
DEFINE RUTA_CARPETA      VARCHAR(100); 
DEFINE RUTA_LOGS         VARCHAR(100); 

DEFINE v_periodo_tc_ini   	DATE;	  		--periodo_tc_ini
DEFINE v_periodo_tc_fin   	DATE;	  		--periodo_tc_fin
DEFINE v_periodo_anterior   DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 	INTEGER;		--dias_periodo_tc
DEFINE  v_periodo             DATE;

DEFINE SQLERR		INTEGER;
DEFINE ISAM_ERR		INTEGER;
DEFINE ERROR_INFO	VARCHAR(80); 
DEFINE v_cod_ret_otro	 CHAR(5);
 
LET vCODIGO_RETORNO = '00000';
LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
LET RUTA_ARCHIVOS = '/Interfaces_SmartVista/INTFZ_TDC_008';
--LET RUTA_ARCHIVOS = '/RESPALDOSNEW/Interfaces_SmartVista/INTFZ_TDC_008';
LET RUTA_CARPETA = '/Envio';
LET RUTA_LOGS = '/Logs';

  LET SQLERR = '';
  LET ISAM_ERR = '';
  LET ERROR_INFO = '';

LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc
LET v_periodo_tc_ini   		  = " ";	--periodo_tc_ini
LET v_periodo_tc_fin   		  = " ";	--periodo_tc_fin
LET v_periodo=mdy(month(current),20, year(current));
LET v_cod_ret_otro = "000";

    --SET DEBUG FILE TO TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_LOGS)||"/debug_sp_sv_aprovisionamiento_oltp.out";
    --TRACE ON;

    BEGIN

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO   TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_LOGS)|| "/excep_sp_sv_aprovisionamiento_oltp.err.out" WITH APPEND;
            TRACE ON;
            
            IF  SQLERR <> 0  THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||current ||' '||' Proceso =>'||vIndicadorProceso;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;

    
----------------------------------------------------------------------------------

    -- Obtener el nombre completo del cliente
    LET vIndicadorProceso =  '1.0.0.0.#';
    LET vsql= '';
    --LET vsql= 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||   
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/si_cliente_sv.unl' ||
                 ' SELECT a.numcte,' ||
                 ' TRIM(NVL(a.nombre1, '' '')) || '' '' || TRIM(NVL(a.nombre2, '' '')) || '' '' || TRIM(NVL(a.apell_paterno, '' '')) || '' '' || TRIM(NVL(a.apell_materno, '' '')) nombre,'||
                 ' NVL(a.rfc, a.rfc_alterno) rfc,'||
                 ' NVL(SUBSTR(YEAR(a.fecha_alta), 3, 2), '' '') fecha_alta,' ||
                 ' a.fecha_alta,'||
                 ' a.sucursal '||       
                 ' FROM bdinteg:si_cliente a '||
                 ' INNER JOIN '||
                 ' bdinteg:si_credito_sv s ' ||
                 ' ON ( s.num_producto = ''4900'' '||
                 ' and a.numcte=s.numcte); "> '|| TRIM(RUTA_ARCHIVOS) ||'/si_cliente_sv.sql';
    system vsql;   

   LET vIndicadorProceso =  '1.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/si_cliente_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '1.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/si_cliente_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '1.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/si_cliente_sv.unl';
        system vsql;
      
	end if	

    -- Obtener la direcciÃ³n (Ãºltima direcciÃ³n activa tipo 1)
	LET vIndicadorProceso =  '1.0.3.#';
    LET vsql= '';
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/si_direcciones_sv.unl' ||  
              ' WITH maxsec AS ( '|| 
              ' SELECT a.numcte, MAX(a.secuencia) AS secuencia '||   
              ' FROM bdinteg:si_direcciones_actual a '||  
              ' INNER JOIN '|| 
              ' bdinteg:si_credito_sv s '|| 
              ' ON ( s.num_producto =  ''4900'' '||  
              ' and a.numcte=s.numcte) '||  
              ' WHERE  a.tipo_dir =  ''1'' '||
              ' GROUP BY a.numcte ) '||  	  
              ' SELECT b.numcte, '||  
              ' NVL(b.numeroextcalle,  ''0'') numeroextcalle, '|| 
              ' NVL(b.numerointcalle,  ''0'') numerointcalle, '|| 
              ' NVL(b.departamento,  ''0'') departamento, '|| 
              ' NVL(b.cod_postal,  ''0'') cod_postal, '|| 
              ' NVL(b.entre_calles,  '' '') entre_calles, '|| 
              ' NVL(b.observaciones,  '' '') observaciones, '|| 
              ' NVL(b.numerociudad, '' '') numerociudad, '|| 
              ' NVL(b.numerocolonia,  '' '') numerocolonia, '|| 
              ' NVL(b.numerocalle,  '' '') numerocalle, '|| 
              ' NVL(b.estado, '' '') estado, '||
              ' TRIM(NVL(c.nombrecalle,'' '')) nombrecalle, '||
              ' TRIM(NVL(e.nombre,'' '')) nombreciudad, '||
              ' TRIM(NVL(f.nombre,'' '')) estado, '||
              ' d.nombrezona, '||			
              ' d.centro, '|| 
              ' d.jefegrupozona, '||			
              ' d.supervisorzona, '||
			  ' d.numerociudadcoppel, '||     
              ' d.numerocolonia, '||
              ' LPAD(p.num_region,2,0) num_region ,'||
              ' LPAD(p.num_ciudad_banco,4,0) num_ciudad_banco,'||
              ' LPAD(p.num_ciudad_coppel,3,0) num_ciudad_coppel'||
              ' FROM bdinteg:si_direcciones_actual b '||  
              ' INNER JOIN maxsec s '||   
              ' ON (b.numcte = s.numcte '||   
              ' AND b.secuencia = s.secuencia) '||
			  ' left join '||
              ' bdinteg:si_estados f '||
              ' on (f.estado=b.estado )'||
			  ' LEFT join '||               
			  ' bdinteg:si_ciudades e '||
              ' on( e.pais=b.pais '||
              ' and e.estado=b.estado '||
              ' and e.ciudad_coppel=b.numerociudad ) '|| 			  
              ' LEFT join '|| 
              ' bdinteg:si_catcalles c '||
              ' on (c.numerocalle=b.numerocalle) '||       
              ' left join'||
              ' bdinteg:si_catzonas d'||
              ' on( d.numerociudad=b.numerociudad '||
              ' and d.numerocolonia=b.numerocolonia )'||
              ' inner join'||
              ' bdicred:sd_centrosimpresion_coppel p'||
              ' on(p.num_ciudad_banco =b.numerociudad);"> '|| TRIM(RUTA_ARCHIVOS) ||'/si_direcciones_sv.sql';
    system vsql;   

    LET vIndicadorProceso =  '2.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/si_direcciones_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '2.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/si_direcciones_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '2.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/si_direcciones_sv.unl';
        system vsql;

	end if	  

    -- Obtener el correo electrÃ³nico mÃ¡s reciente
    LET vIndicadorProceso =  '3.0.0.0.#';    
    LET vsql= '';
    --LET vsql= 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||  
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/si_correos_sv.unl' ||  
              ' with correo(numcte,secuencia) as( ' || 
              ' select a.numcte, NVL(MAX(a.secuencia), 0) ' || 
              ' FROM bdinteg:si_correos a ' || 
              ' inner join ' || 
              ' bdinteg:si_credito_sv s ' || 
              ' ON ( s.num_producto = ''4900'' ' ||  
              ' and a.numcte=s.numcte' || 
              ' and a.status_correo = ''A'') ' ||  
              ' group by  a.numcte) ' ||            
              ' SELECT c.numcte,NVL(c.correo_elec, '' '') ' ||  
              ' FROM bdinteg:si_correos c ' || 
              ' inner join ' || 
              ' correo o' || 
              ' on (c.numcte=o.numcte ' || 
              ' and c.secuencia=o.secuencia ' || 
              ' and c.status_correo = ''A'' ); "> '|| TRIM(RUTA_ARCHIVOS) ||'/si_correos_sv.sql';  
    system vsql;   

    LET vIndicadorProceso =  '3.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/si_correos_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '3.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/si_correos_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '3.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/si_correos_sv.unl';
        system vsql;

	end if	      

    LET vIndicadorProceso =  '4.0.0.0.#';
    LET vsql= '';
    --LET vsql= 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||  
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/sucursales_sv.unl' ||  
              ' with cliente(numcte, sucursal ) as( ' || 
              ' select  a.numcte, a.sucursal ' ||         
              ' FROM bdinteg:si_cliente a ' ||   
              ' INNER JOIN ' ||   
              ' bdinteg:si_credito_sv s ' ||   
              ' ON ( s.num_producto = ''4900'' ' || 
              ' and a.numcte=s.numcte) ' ||              
              ' ) SELECT c.numcte,'||
              ' d.sucursal,'||
              ' d.nombre,'||
              ' d.gerente,'||
              ' d.iva,'||
              ' nvl(t.tel1,'' '') tel1 ' ||       
              ' FROM bdinteg:si_sucursales d ' || 
              ' inner join ' || 
              ' cliente c ' || 
              ' on (d.sucursal=c.sucursal) ' || 
              ' left join ' || 
              ' bdinteg:si_ptf t ' || 
              ' on ( t.id_ptf=c.sucursal ' || 
              ' and t.tipo=''S''); "> '|| TRIM(RUTA_ARCHIVOS) ||'/sucursales_sv.sql';
    system vsql;   

    LET vIndicadorProceso =  '4.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/sucursales_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '4.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/sucursales_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '4.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/sucursales_sv.unl';
        system vsql;

	end if	  


    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   
	
	--......................................
  
    LET vIndicadorProceso =  '6.0.0.0.#';
    let vsql='';
    let vsql ='rm -f '|| TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_CARPETA) || '/aprovisionamiento_oltp_sv.tar';    
    system vsql;  

    --......................................

    LET vIndicadorProceso =  '6.0.0.1.#';
    LET vsql = '';
	LET vsql = ' tar -cf ' ||  TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_CARPETA) || '/aprovisionamiento_oltp_sv.tar ' ||  TRIM(RUTA_ARCHIVOS)|| '/*_sv.unl ';
    SYSTEM vsql;

    --......................................

    LET vIndicadorProceso =  '6.0.0.2.#';  
	let vsql='';
    let vsql ='rm  -f '|| TRIM(RUTA_ARCHIVOS) || '/*_sv.sql';
    system vsql;

    --......................................

    --LET vIndicadorProceso =  '6.0.0.3.#';
    let vsql='';
    let vsql ='rm -f '|| TRIM(RUTA_ARCHIVOS) || '/*_sv.unl';    
    system vsql;

    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>		
    		
    
    End;
      RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
END PROCEDURE;