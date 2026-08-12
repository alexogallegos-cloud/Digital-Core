CREATE PROCEDURE "informix".verificatarjetacancelada_transfer(pEmpresa CHAR(3), pNumTarjeta CHAR(16))
	--DATOS A REGRESAR---
	RETURNING
			CHAR(5) AS CodRet;
 
	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr          INTEGER;
    DEFINE sCantReg         SMALLINT;
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodStatusint    CHAR(3);
    DEFINE cCodStatuschq    CHAR(1);

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr        = 0;
	LET sCantReg       = 0;
	LET cCodRet        = "00000";
    LET cCodStatusint  = "";
    LET cCodStatuschq  = "";

--SET DEBUG FILE TO '/respaldosbd/felipe/Sps/verificatarjetacancelada_transfer.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pNumTarjeta,''))  <> ''  THEN
	
		SELECT inttar.codstatustarjeta, chqtar.status_tar
		INTO  cCodStatusint, cCodStatuschq
		FROM intercard:"informix".tarjeta inttar,
			bdicheq:"informix".sc_tarjeta chqtar
		WHERE inttar.numtarjeta = chqtar.num_tarjeta 
		AND chqtar.empresa = TRIM(pEmpresa)
		AND chqtar.num_tarjeta = TRIM(pNumTarjeta);
	 
		LET sCantReg = DBINFO("sqlca.sqlerrd2");
		
		IF sCantReg = 0 THEN
			LET cCodRet = "132";
		ELSE	
			IF cCodStatusint <> 'ACT' THEN
				IF cCodStatusint = 'BLT' OR cCodStatusint = 'BLO' OR cCodStatusint = 'NOA' THEN 
					LET cCodRet = "011";
				END IF
			END IF
		END IF
	ELSE
		LET cCodRet = "001";
	END IF

    RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'FOLIO: 1600',
'AUTOR : 94972834',
'FECHA : 30/06/2014',
'SOLICITA: Rodolfo Gomez',
'BD: bdicheq';

CREATE PROCEDURE "informix".cierrechqra(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --//*******************************************************************
    --
    --      Nombre:                cierrechqra
    --      Version:               1.0.1
    --      Objetivo:              Programa principal cierre cuentas de chequera producto "1900"
    --      Creado por:
    --      ModIFicado por:        Alejandro Rueda Sanchez
    --      Ultima Modificacion:   Junio 2010
    --
    --//*******************************************************************
    
    -- // Definicion de Variables Globales
    DEFINE GLOBAL vgrausuario                   CHAR(8)   DEFAULT " ";
    DEFINE GLOBAL vgraprox_fecha                DATE      DEFAULT " ";
    DEFINE GLOBAL vgrafecha_hoy                 DATE      DEFAULT " ";
    DEFINE GLOBAL vgrapri_hab_mes               DATE      DEFAULT " ";
    DEFINE GLOBAL vgrapri_dia_mes               DATE      DEFAULT " ";
    DEFINE GLOBAL vgrault_hab_mes               DATE      DEFAULT " ";
    DEFINE GLOBAL vgrault_dia_mes               DATE      DEFAULT " ";
    DEFINE GLOBAL vgratrans_pag_int             CHAR(4)   DEFAULT " ";
    DEFINE GLOBAL vgratransisr                  CHAR(4)   DEFAULT " ";
    DEFINE GLOBAL vgratranprov                  CHAR(4)   DEFAULT " ";
    DEFINE GLOBAL vgratranabotrasp              CHAR(4)   DEFAULT " ";
    DEFINE GLOBAL vgratranrevprov               CHAR(4)   DEFAULT " ";
    DEFINE GLOBAL vgraProdCreciente             CHAR(4)   DEFAULT " ";
    DEFINE GLOBAL vgrafecha_mod                 DATE      DEFAULT " ";
    DEFINE GLOBAL vgrafecha_alta                DATE      DEFAULT " ";
    DEFINE GLOBAL vgrastatus_cta                CHAR(1)   DEFAULT " ";
    DEFINE GLOBAL vgratranrecrece               CHAR(4)   DEFAULT " ";

    DEFINE vcuenta                            CHAR(20);
    DEFINE vfcuenta                           CHAR(20);
    DEFINE vtotsuc                            INTEGER;
    DEFINE vcontproc                          INTEGER;
    DEFINE vdiaspri                           INTEGER;
    DEFINE vdias                              INTEGER;
    DEFINE vcodret                            CHAR(5);
    DEFINE vcodret2                           CHAR(5);
    DEFINE vcodret3                           CHAR(50);
    DEFINE vsqlerr                            INTEGER;
    DEFINE vcontprocie                        CHAR(1);
    DEFINE vexiste                            CHAR(1);
    DEFINE vcierre_ejercicio                  SMALLINT;
    DEFINE vproddiv                           CHAR(4);
    DEFINE vfecinidiv                         DATETIME YEAR TO MONTH;
    DEFINE vfecfindiv                         DATETIME YEAR TO MONTH;
    DEFINE vstmt                              CHAR(800);
    DEFINE vfolio_suc                         CHAR(16);
    DEFINE vcontador                          INTEGER;
    DEFINE vregproc                           INTEGER;
    DEFINE vporcentajerror                    INTEGER;
    DEFINE vcontvalcie                        INTEGER;
    DEFINE vregistros                         INTEGER;
    DEFINE vexiste2                           INTEGER;
    DEFINE vexistefin                         INTEGER;
    DEFINE vsistema                           CHAR(2);
    DEFINE vproceso                           CHAR(20);
    DEFINE FechaProc                          DATE;
    DEFINE vProducto                          CHAR(4);
    DEFINE vSucursal                          CHAR(4);
    DEFINE vSdoActual                         DECIMAL(14,2);
    DEFINE isam_err                           SMALLINT;
    DEFINE error_info                         CHAR(40);
    DEFINE vmes                               CHAR(2);
    DEFINE vdia                               CHAR(2);
    DEFINE vanio                              CHAR(4);
    DEFINE vBandNva                           SMALLINT;
    DEFINE vaniomes                           CHAR(6);
    DEFINE vtfechaxxx                         DATE;
    DEFINE vsdo_cuenta                        MONEY(14,2);
    DEFINE vmto_pag_int                       MONEY(14,2);
    DEFINE vfecha_alta                        DATE;
    DEFINE vnumdias                           SMALLINT;
    DEFINE vsdo_actual                        MONEY(14,2);
    DEFINE vimp_chq_sbc						  MONEY(14,2);
    DEFINE vimp_abonos_mes					  MONEY(14,2);
    DEFINE vpago_interes                      CHAR(1);
    DEFINE vacum_sdo_pos                      MONEY(18,2);
    DEFINE vdia_sdo_pos                       SMALLINT;
    DEFINE vult_chq		                      INTEGER;
    DEFINE vfechafin                          DATE;
    DEFINE vfechaini                          DATE;
    DEFINE vfecha_pago                        DATE;
    DEFINE vstatuscierreinv                   CHAR(1);
    DEFINE vstatuscobroreestruc               CHAR(1);
    DEFINE vtprodtmp                          CHAR(4);

    DEFINE vProdEfeChq                        CHAR(4);
    DEFINE vdummy                             CHAR(100);
    DEFINE vProdEmpChq                        CHAR(4);
    DEFINE vProdEmpChqNostro                  CHAR(4);
	DEFINE vProdEfePla                        CHAR(4);
    DEFINE cNumcte							  CHAR(20);
    DEFINE cNumtarj							  CHAR(20);	
    DEFINE iExiste							SMALLINT;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, isam_err, error_info
        IF vsqlerr <> 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqra.err";
            TRACE ON;
            
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            
            UPDATE bdinteg:"informix".sx_contproc
               SET hora_fin = current hour to fraction,
                   ejecutivo = vgrausuario,
                   status_proc = "C",
                   codret      = vcodret
             WHERE empresa = pempresa
               AND proceso = vproceso
               AND fecha   = vgrafecha_hoy
               AND sistema = vsistema;
            
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/cierrechqra.out";
    --- TRACE ON;

    LET vgrausuario       = USER;
    LET vcodret           = "000";
    LET vsistema          = "01";
    LET vproceso          = "cierrechqra";
    LET vfcuenta          = '';
    LET vcuenta           = '';
    LET vProdEfeChq       = "1900";
	LET vProdEmpChq       = '2200';
	LET vProdEmpChqNostro = '2700';
	LET vProdEfePla       = '2400';
	LET cNumcte		      = '';
	LET cNumtarj	      = '';
	LET iExiste		      = 0;
    
    SET ISOLATION TO DIRTY READ;
    SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    --- SET PDQPRIORITY 10;
    
    SELECT fecha_hoy,pri_dia_mes,pri_hab_mes,
           ult_dia_mes,ult_hab_mes,prox_fecha
      INTO vgrafecha_hoy,vgrapri_dia_mes,vgrapri_hab_mes,
           vgrault_dia_mes,vgrault_hab_mes,vgraprox_fecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    SELECT valor
      INTO vgratrans_pag_int
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranpagint";
    
    SELECT valor
      INTO vgratransisr
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranisr";
    
    SELECT valor
      INTO vgratranprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranprov";
    
    SELECT valor
      INTO vgratranrevprov
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranrevprov";
    
    SELECT valor
      INTO vgratranabotrasp
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "tranabotrasp";
    
    SELECT valor
      INTO vcierre_ejercicio
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "cierre_ejercicio";
    
    SELECT valor
      INTO vgratranrecrece
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "trenocre";
       
    /* #####################################################################################################
    --// VALIDA QUE ESTE FINALIZADO CIERRE DE INVERSIONES
    SELECT status_proc
      INTO vstatuscierreinv
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'CierreInv'
       AND fecha   = vgrafecha_hoy
       AND sistema = '03';
    
    IF vstatuscierreinv is null OR vstatuscierreinv <> 'F' THEN
        LET vcodret = "959";
        
        UPDATE bdinteg:sx_contproc
           SET hora_fin     = current hour to fraction,
               ejecutivo    = vgrausuario,
               status_proc  = "C",
               codret       = vcodret
         WHERE empresa      = pempresa
           AND proceso      = vproceso
           AND fecha        = vgrafecha_hoy
           AND sistema      = vsistema;
           
        RETURN vcodret;
    END IF
    ##################################################################################################### */
        
    /* #####################################################################################################
    -- // VALIDA HAYA FINALIZADO COBRO DE REESTRUCTURA
    SELECT status_proc
      INTO vstatuscobroreestruc
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'CobroAutRe'
       AND fecha   = vgrafecha_hoy
       AND sistema = '06';
    
    IF vstatuscobroreestruc is null OR vstatuscobroreestruc <> 'F' THEN
        LET vcodret = "954";
        
        UPDATE bdinteg:sx_contproc
           SET hora_fin     = current hour to fraction,
               ejecutivo    = vgrausuario,
               status_proc  = "C",
               codret       = vcodret
         WHERE empresa      = pempresa
           AND proceso      = vproceso
           AND fecha        = vgrafecha_hoy
           AND sistema      = vsistema;
           
        RETURN vcodret;
    END IF
    ##################################################################################################### */
    
    -- // VALIDA HAYA FINALIZADO RESPALDO
    SELECT 1
      INTO vexiste
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "respacie"
       AND fecha = vgrafecha_hoy;
    
    IF vexiste is null THEN
        LET vcodret = "965";
    
        UPDATE bdinteg:sx_contproc
           SET hora_fin = current hour to fraction,
               ejecutivo = vgrausuario,
               status_proc = "C",
               codret      = vcodret
         WHERE empresa = pempresa
           AND proceso = vproceso
           AND fecha   = vgrafecha_hoy
           AND sistema = vsistema;
    
        RETURN vcodret;
    END IF
    
    SELECT count(*)
      INTO vexiste2
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = vproceso
       AND fecha   = vgrafecha_hoy
       AND sistema = vsistema;
    
    IF vexiste2 = 0 THEN
        INSERT INTO bdinteg:sx_contproc VALUES (
        pempresa,vproceso,vgrafecha_hoy,vsistema,"I",
        vgrausuario,current hour to fraction,null,null);
    ELSE
        SELECT count(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa = pempresa
           AND proceso = vproceso
           AND fecha   = vgrafecha_hoy
           AND sistema = vsistema
           AND status_proc = "F";
    
        IF vexistefin = 0 THEN
            UPDATE bdinteg:sx_contproc
               SET hora_ini = current hour to fraction,
                   ejecutivo = vgrausuario,
                   status_proc = "I",
                   codret      = vcodret
            WHERE  empresa = pempresa
               AND proceso = vproceso
               AND fecha   = vgrafecha_hoy
               AND sistema = vsistema;
        ELSE
            LET vcodret = "966";
        
            UPDATE bdinteg:sx_contproc
               SET hora_fin = current hour to fraction,
                   ejecutivo = vgrausuario,
                   status_proc = "C",
                   codret      = vcodret
             WHERE empresa = pempresa
               AND proceso = vproceso
               AND fecha   = vgrafecha_hoy
               AND sistema = vsistema;
        
            -- RETURN vcodret;
        END IF
    END IF;
    
    --// Valida no se halla realizado cierre
    SELECT 1
      INTO vexiste
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "cierreqra"
       AND fecha = vgrafecha_hoy;
    
    IF vexiste  = "1" THEN
        LET vcodret = "966";
        RETURN vcodret;
    END IF
    
    --//Guarda historial de valcierreqra y limpia la tabla
    SELECT count(*)
      INTO vcontvalcie
      FROM sc_valcierreqra
     WHERE empresa = pempresa
       AND cuenta <> '';
        
    IF vcontvalcie <> 0 THEN
        INSERT INTO sc_valcierre_his
        SELECT a.*, b.fecha_ant
          FROM sc_valcierreqra a,
               sc_fechas b
         WHERE a.empresa = pempresa
           AND a.cuenta <> ''
           AND b.empresa = a.empresa;

        DELETE FROM sc_valcierreqra
         WHERE empresa = pempresa
           AND cuenta <> '';
    END IF
    
    -- // Valida se halla efectuado el Pase Contable en Sucursales
    SELECT count(*) 
      INTO vtotsuc
      FROM bdinteg:si_sucursales su
     WHERE empresa = pempresa
       AND tpo_sucursal = "01"
       AND not exists (SELECT fecha 
                         FROM bdinteg:si_feriadsuc fs
                        WHERE fs.empresa = pempresa
                          AND fecha = vgrafecha_hoy
                          AND su.sucursal = fs.sucursal);
    
    SELECT count(*)
      INTO vcontproc
      FROM bdisuc:ss_contproc
     WHERE fecha = vgrafecha_hoy
       AND proceso = "pase";
       
    SET LOCK MODE TO WAIT 2;
    
    -- // Producto de chequeras
    SELECT valor
      INTO vProdEfeChq
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechq";
    
    -- // Producto de chequeras empresarial
    SELECT valor
      INTO vProdEmpChq
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodempchq";
       
	   -- // Producto de chequeras nostro
    SELECT valor
      INTO vProdEmpChqNostro
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefechqnostro";
	   
	   -- // Producto Cuenta Efectiva Platino con chequera
    SELECT valor
      INTO vProdEfePla
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "prodefepla";
	   
    /* ########################################################################################
    -- // Verfica cuentas con status 4 (Inactivas)
    LET vcuenta      = '';
    LET vsdo_cuenta  = 0.00;
    LET vmto_pag_int = 0.00;
    
    FOREACH
        SELECT mae.cuenta, mae.sdo_actual, pro.mto_pag_int
          INTO vcuenta, vsdo_cuenta, vmto_pag_int
          FROM sc_maechq mae,
               sc_producto pro
         WHERE mae.empresa = pempresa
           AND mae.status_cta = '4'
           AND mae.sdo_actual >= pro.mto_pag_int
           AND pro.empresa = mae.empresa
           AND pro.producto = mae.producto
           AND mae.producto IN(vProdEfeChq, vProdEmpChq, vProdEmpChqNostro, vProdEfePla)
           
        IF vsdo_cuenta >= vmto_pag_int THEN
            UPDATE sc_maechq
               SET status_cta = '1',
                   fecha_proceso = vgrafecha_hoy
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
            
            UPDATE sc_maenoc
               SET dia_sdo_pos = 0,
                   acum_sdo_pos = 0.00,
                   int_acum = 0.00,
                   dias_acum_int = 0,
                   acum_sdo_int = 0.00
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF;
    END FOREACH;
    ######################################################################################## */
    
    -- // Obtiene numero de dias a procesar
    IF vgrafecha_hoy = vgrault_hab_mes THEN
        LET vdias = vgrault_dia_mes - vgrafecha_hoy + 1;
    
        IF vgraprox_fecha > vgrault_dia_mes THEN
            LET vdias = vdias + ((vgraprox_fecha-1) - vgrault_dia_mes);
        END IF
    ELSE
        LET vdias = vgraprox_fecha - vgrafecha_hoy;
    END IF
    
    /* ########################################################
    SELECT control
      INTO vcontprocie
      FROM sc_folsuc
     WHERE empresa = pempresa
       AND control = "2";

    IF vcontprocie is null THEN
        INSERT INTO sc_folsuc values(pempresa,"2","1");
        LET vcontprocie = "1";
    END IF

    IF vcontprocie = "1" THEN
        UPDATE sc_folsuc
           SET control = "2"
         WHERE empresa = pempresa;
    END IF
    ######################################################## */
    
    -- // Obtiene registros a procesar
    SELECT count(*)
      INTO vregproc
      FROM sc_maechq
     WHERE empresa = pempresa
       AND producto IN(vProdEfeChq, vProdEmpChq, vProdEmpChqNostro, vProdEfePla)
       AND status_cta not in("2","6","7","8")
       AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgrafecha_hoy);
    
    -- // Obtiene parametro de porcentajes de error por proceso
    SELECT ROUND(valor)
      INTO vporcentajerror
      FROM sc_param
     WHERE empresa  = pempresa
       AND codparam = "porcentajerror";
    
    -- // Producto Inversion Creciente
    SELECT valor
      INTO vgraProdCreciente
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "PRODCREC";
        
    LET vfcuenta       = '';
    LET FechaProc      = '';
    LET vProducto      = '';
    LET vSdoActual     = 0.00;
    LET vgrastatus_cta = '';
    LET vSucursal      = '';
    
    -- //+++++++++++++++++++++++++++++++++++++++++++++++++
    -- //+ FOREACH PRINCIPAL DEL CIERRE PARA CHEQUERAS
    -- //+++++++++++++++++++++++++++++++++++++++++++++++++
    FOREACH principal WITH HOLD FOR
        SELECT cuenta, fecha_proceso, producto, sdo_actual, imp_chq_sbc, imp_abonos_mes, status_cta, sucursal, ult_chq
          INTO vfcuenta, FechaProc, vProducto, vSdoActual, vimp_chq_sbc, vimp_abonos_mes, vgrastatus_cta, vSucursal, vult_chq
          FROM sc_maechq
         WHERE empresa = pempresa
           AND producto IN(vProdEfeChq, vProdEmpChq, vProdEmpChqNostro, vProdEfePla)
           AND status_cta not in("2","6","7","8")
           AND (fecha_proceso is null OR fecha_proceso = " " OR fecha_proceso = vgrafecha_hoy)
                
        -- ****************************************************************
        -- Valida el saldo de Cta con Chequera al dia de la Apertura
        -- ****************************************************************
        --- IF vproducto = vProdEfeChq AND FechaProc IS NULL THEN
        IF vproducto = vProdEfeChq THEN
            IF vult_chq = 0 THEN
                -- // Cancela la cuenta, si el cliente no realizó el deposito de apertura
                IF vimp_abonos_mes = 0 and vSdoActual = 0 THEN 
                    UPDATE sc_maechq
                       SET status_cta = "2",
                           fec_cancelac = vgrafecha_hoy,
                           fecha_proceso = vgrafecha_hoy
                     WHERE empresa = pempresa
                       AND cuenta = vfcuenta;
                    
                    SELECT NVL(COUNT(*),0) 
                      INTO iExiste 
                      FROM sc_tarjeta 
                     WHERE empresa = pempresa 
                       AND cuenta = vfcuenta 
                       and status_tar='A'; 
                    
                    IF iExiste > 0 THEN
                        FOREACH
                            SELECT num_tarjeta, numcte 
                              INTO cNumtarj,cNumcte 
                              FROM sc_tarjeta
                             WHERE empresa = pempresa
                               AND cuenta = vfcuenta 
                               AND status_tar='A'
                            
                            UPDATE intercard:tarjeta 
                               SET codstatustarjeta='CAN',
                                   fechaultmodif=CURRENT,
                                   usuarioultmodif='informix'
                             WHERE numcliente=cNumcte 
                               AND numtarjeta=cNumtarj 
                               AND codstatustarjeta='ACT';
                        
                            INSERT INTO intercard:bitacoracancelaciontarjetas(tarjeta,codigoproductotarjeta,fecha,resultado,descripcion,usuario)
                            VALUES(cNumtarj,'501',CURRENT,0,'CANCELACION DE TARJETA','CIERRECH');
                        
                            UPDATE sc_tarjeta 
                               SET status_tar='C' 
                             WHERE empresa = pempresa 
                               AND cuenta = vfcuenta 
                               and status_tar='A';
                        END FOREACH;
                    END IF;	
                    
                    LET vcodret = "000";
                    CONTINUE FOREACH;
            --- ELIF vimp_chq_sbc = 0 and vSdoActual = 0 and vimp_abonos_mes > 0 and chq_dev_obco > 0 THEN
            ---     UPDATE sc_maechq
            ---        SET status_cta = "2",
            ---            fec_cancelac = vgrafecha_hoy,
            ---            fecha_proceso = vgrafecha_hoy
            ---      WHERE empresa = pempresa
            ---        AND cuenta = vfcuenta;
            ---
            ---     LET vcodret = "000";
            ---     CONTINUE FOREACH;
                ELIF (vimp_abonos_mes > 0 or vSdoActual > 0) and vimp_chq_sbc = 0 THEN --//Envia la solicitud de la Primera Chequera
                    CALL bdicntchq:sp_altachequeras(pempresa,vfcuenta,1, "01", vgrausuario)
                    RETURNING vdummy;
                    
                    LET vcodret = "000";
                END IF
            END IF
        ELSE
            CALL bdicntchq:sp_altachequeras(pempresa,vfcuenta,1, "03", vgrausuario)
            RETURNING vdummy;
            LET vcodret = "000";
        END IF
        
        CALL cierrechqra_reg (pempresa, vdias, vfcuenta, vProducto, vSdoActual, vSucursal)
        RETURNING vcodret;
        
        IF vcodret <> "000" THEN
            -- // Conteo de Errores generados por el cierre
            SELECT count(*)
              INTO vcontvalcie
              FROM sc_valcierreqra
             WHERE empresa = pempresa
               AND cuenta <> '';
                
            LET vregistros = round(vregproc * vporcentajerror / 100);
            
            IF vcontvalcie <= vregistros THEN
                CONTINUE FOREACH;
            ELSE
                LET vcodret = "997";
                
                UPDATE bdinteg:sx_contproc
                   SET hora_fin = current hour to fraction,
                       ejecutivo = vgrausuario,
                       status_proc = "C",
                       codret = vcodret
                 WHERE empresa = pempresa
                   AND proceso = vproceso
                   AND fecha = vgrafecha_hoy
                   AND sistema = vsistema;
                
                RETURN vcodret;
            END IF;
        END IF;
    END FOREACH;
        
    SET LOCK MODE TO WAIT 2;
    
    -- // Actualiza saldo y fecha de proceso de cuentas inactivas    
    FOREACH
        SELECT cuenta
          INTO vcuenta
          FROM sc_maechq
         WHERE status_cta = '4'
           AND fecha_proceso < vgrafecha_hoy
           AND producto IN(vProdEfeChq, vProdEmpChq, vProdEmpChqNostro, vProdEfePla)
        
        UPDATE sc_maechq
           SET sdo_dia_ant = sdo_actual
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
    END FOREACH
    
    -- // Actualiza saldo y fecha de proceso de cuentas desconcentradas ART 61 LIC
    FOREACH
        SELECT cuenta
          INTO vcuenta
          FROM sc_maechq
         WHERE status_cta = '8'
           AND fecha_proceso < vgrafecha_hoy
           AND producto IN(vProdEfeChq, vProdEmpChq, vProdEmpChqNostro, vProdEfePla)
        
        UPDATE sc_maechq
           SET sdo_dia_ant = sdo_actual
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
    END FOREACH
    
    --- SET LOCK MODE TO WAIT 2;
    
    -- // Registra fin de cierres
    UPDATE bdinteg:sx_contproc
       SET hora_fin = current hour to fraction,
           status_proc = "F",
           codret      = vcodret
     WHERE empresa = pempresa
       AND proceso = vproceso
       AND fecha   = vgrafecha_hoy
       AND sistema = vsistema;
    
    UPDATE sc_contproc
       SET fecha = vgrafecha_hoy
     WHERE empresa = pempresa
       AND proceso = "cierreqra";
    
    RETURN vcodret;
    
    END
    
END PROCEDURE;