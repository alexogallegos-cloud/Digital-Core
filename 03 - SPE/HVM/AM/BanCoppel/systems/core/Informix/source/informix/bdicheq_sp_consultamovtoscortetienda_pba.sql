CREATE PROCEDURE "informix".sp_consultamovtoscortetienda_pba( pTipo SMALLINT, 
                                                          pTienda SMALLINT, 
                                                          pTipoDeposito CHAR(1), 
                                                          pFechaParcialCoppel DATE, 
                                                          pFechaDeposito DATE, 
                                                          pFolioDeposito CHAR(16), 
                                                          pMontoDeposito INTEGER )
RETURNING INTEGER, INTEGER;

    --- #############################################################################################
    --- ## Modifico: Miguel Olivas                                                                 ##
    --- ## Fecha: 18/nov/2008                                                                      ##
    --- ## se modifica para que no haga la consulta a la tabla historica sc_movhis.                ##
    --- ##                                                                                         ##
    --- ## Modifico: Daniel Zambada                                                                ##
    --- ## Fecha: 21/nov/2008                                                                      ##
    --- ## se modifica para que valide  el retorno cuando no exista el registro con regreso 1 o 3. ##
    --- ##                                                                                         ##
    --- ## Modifico: Daniel Zambada                                                                ##
    --- ## Fecha: 21/may/2009                                                                      ##
    --- ## se modifica para que valide  el monto en la movdia por rango inferior  y superior.      ##
    --- #############################################################################################
    
    DEFINE vCodRet    CHAR(5);
    DEFINE vSqlErr    INTEGER;
    DEFINE vSucursal  CHAR(4);
    DEFINE vCSucursal CHAR(4);
    DEFINE vDeposito MONEY(14,2);
    
    LET vCodRet = '000';
    LET vSqlErr = 0;
    LET vSucursal = '0000';
    LET vCSucursal = '0000';
    LET vDeposito = pMontoDeposito/100;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/sp_consultamovtoscortetienda.out";
        TRACE ON;
        IF vSqlErr <> 0 THEN
            LET vCodRet = vSqlErr;
            RETURN vCodRet,vSucursal;
        END IF;
    END EXCEPTION;
	--SET DEBUG FILE TO "/respaldosbd/cris/sp_consultamovtoscortetienda.out";
	--TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pTipo = 1 THEN
    
        IF EXISTS (SELECT {+INDEX(bdicheq:"informix".sc_consultamovtoscortetienda ind_sc_consultamovtoscortetienda_01)} 
					fechadeposito,foliodeposito,montodeposito 
					FROM "informix".sc_consultamovtoscortetienda 
					WHERE fechadeposito = pFechaDeposito 
					AND foliodeposito = pFolioDeposito 
					AND montodeposito = vDeposito 
					AND estado = 1) THEN
                      
            INSERT INTO bdicheq:"informix".sc_consultamovtoscortetienda(fechadeposito,foliodeposito,montodeposito,tienda,tipodeposito,fechaparcialcoppel,estado,fechamov)
            VALUES(pFechaDeposito, pFolioDeposito, vDeposito, pTienda, pTipoDeposito, pFechaParcialCoppel, 2, CURRENT);

            LET vCodRet = '2';
            LET vSucursal = '0';
            
        ELSE
            
		/* ###############################################
		IF EXISTS (SELECT fech_alt, folio_suc, monto_tot 
				FROM sc_movdia 
				WHERE fech_alt = pFechaDeposito 
				AND folio_suc = pFolioDeposito 
				AND monto_tot = vDeposito) THEN 
		############################################### */
            
		IF EXISTS ( SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia7a)} 
					fech_alt, folio_suc, monto_tot 
					FROM "informix".sc_movdia 
					WHERE cuenta = '16000000012' 
					AND folio_suc = pFolioDeposito
					AND fech_alt = pFechaDeposito 
					AND monto_tot = vDeposito ) THEN 

				/* ################################
					SELECT nvl(sucursal,'') 
					INTO vCSucursal 
					FROM sc_movdia 
					WHERE fech_alt = pFechaDeposito 
					AND folio_suc = pFolioDeposito 
					AND monto_tot = vDeposito; 
				################################ */
			
				SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia7a)} 
				NVL(sucursal,'') 
				INTO vCSucursal 
				FROM "informix".sc_movdia 
				WHERE cuenta = '16000000012' 
				AND folio_suc = pFolioDeposito
				AND fech_alt = pFechaDeposito 
				AND monto_tot = vDeposito;                 
              

                INSERT INTO bdicheq:"informix".sc_consultamovtoscortetienda(fechadeposito,foliodeposito,montodeposito,tienda,tipodeposito,fechaparcialcoppel,estado,fechamov)
                VALUES(pFechaDeposito, pFolioDeposito, vDeposito, pTienda, pTipoDeposito, pFechaParcialCoppel, 1, CURRENT);

                LET vCodRet = '1';
                LET vSucursal = vCSucursal;
                
            ELSE

			-- // Se modifica para que no haga la consulta a la tabla historica sc_movhis.
			/* ############################################################################################################
			IF EXISTS (SELECT fech_alt, folio_suc, monto_tot 
				FROM sc_movhis 
				WHERE fech_alt = pFechaDeposito 
				AND folio_suc = pFolioDeposito 
				AND monto_tot = vDeposito) THEN

				SELECT nvl(sucursal,'') 
				INTO vCSucursal 
				FROM sc_movhis 
				WHERE fech_alt = pFechaDeposito 
				AND folio_suc = pFolioDeposito 
				AND monto_tot = vDeposito;        

				INSERT INTO sc_consultamovtoscortetienda(fechadeposito, foliodeposito, montodeposito, tienda, tipodeposito, fechaparcialcoppel, estado, fechamov)
				VALUES(pFechaDeposito, pFolioDeposito, vDeposito, pTienda, pTipoDeposito, pFechaParcialCoppel, 1, CURRENT);

				LET vCodRet = '1';
				LET vSucursal = vCSucursal;
			ELSE
			############################################################################################################ */
                
                INSERT INTO bdicheq:"informix".sc_consultamovtoscortetienda(fechadeposito,foliodeposito,montodeposito,tienda,tipodeposito,fechaparcialcoppel,estado,fechamov)
                VALUES(pFechaDeposito, pFolioDeposito, vDeposito, pTienda, pTipoDeposito, pFechaParcialCoppel, 3, CURRENT);
                
                /* ############################################################################
					IF pFechaDeposito::DATE < (select fecha_hoy::DATE from bdicheq:sc_fechas) THEN	     	
						LET vCodRet = '1';
					ELSE
						LET vCodRet = '3';
					END IF;
				############################################################################ */
                
                LET vCodRet = '3';
                LET vSucursal = '0';

               --- END IF; 
            END IF; 
        END IF;
    END IF;

    RETURN vCodRet, vSucursal;
    
    END;
    
END PROCEDURE

DOCUMENT
"Consulta Movimientos de Cortes de Tienda ",
"AUTOR: Saul Ivanhoe",
"FECHA: 26/Febrero/2008",
"BD   : bdicheq",
"VER  : 1.1",
"MODIFICACION: Se igualan consulta a la sc_movdia filtradas por fecha, monto,folio y monto para corregir incidencia en la confirmacicón de los retiros parciales.",
"MODIFICO: Cristian Valentina Aguilar",
"FECHA: 20/Abril/2012",
"BD   : bdicheq",
"VER  : 20120420.1756";

CREATE PROCEDURE "informix".cierrechqinvcrecparam(pempresa CHAR(3))
RETURNING CHAR(5);
     
    --- ################################################################################
    --- ##  Nombre:              cierrechqinvcrecparam                                ##
    --- ##  Version:             1.0.1                                                ##
    --- ##  Objetivo:            Programa inicial del cierre diario de captacion      ##
    --- ##  Creado por:                                                               ##
    --- ##  ModIFicado por:      JICS                                                 ##
    --- ##  Ultima Modificacion: Diciembre 2011                                       ##
    --- ################################################################################

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(50);
    DEFINE vfecha_hoy       DATE;
    DEFINE vpromedio        INTEGER;
    DEFINE vcont            SMALLINT;
    DEFINE vbrinca          INTEGER;
    DEFINE vcuenta          CHAR(20);
    DEFINE vctamin          CHAR(20);
    DEFINE vctamax          CHAR(20);
    
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = " ";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vfecha_hoy = ' ';    
    LET vpromedio  = 0;
    LET vcont      = 0;
    LET vbrinca    = 0;
    LET vcuenta    = '';
    LET vctamin    = '';
    LET vctamax    = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcrecparam.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/cierrechqinvcrecparam.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    UPDATE sc_fechas
       SET ind_cierre = '0'
     WHERE empresa = pempresa;
     
    SELECT mae.cuenta
      FROM sc_maechq mae,
           sc_maeinstrucc ins
     WHERE mae.producto = '1100'
       AND mae.status_cta <> '2'
       AND ( mae.fecha_proceso is null OR mae.fecha_proceso = "" OR mae.fecha_proceso = vfecha_hoy )
       AND ins.empresa = mae.empresa
       AND ins.cuenta = mae.cuenta
       AND ins.capint = 'R'
       AND ins.instrucc = '01'
    INTO TEMP tmp_invscrec WITH NO LOG;
    CREATE INDEX idxtmp_invcrec ON tmp_invscrec(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_invscrec;
     
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vctamin, vctamax
      FROM tmp_invscrec
     WHERE cuenta >= '10000000000';
     
    LET vctamin = TRIM(vctamin);
    LET vctamax = TRIM(vctamax);
      
    SELECT ROUND(COUNT(*)/5)
      INTO vpromedio
      FROM tmp_invscrec
     WHERE cuenta BETWEEN vctamin AND vctamax;
       
    LET vcont = 1;  
    
    WHILE vcont <= 5 
        IF vcont = 1 THEN 
            LET vcuenta = vctamin;
               
            UPDATE sc_param
               SET valor = vcuenta
             WHERE empresa = pempresa
               AND codparam = 'CtaIniCieInvCreComp1';
        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta
                  FROM tmp_invscrec
                 WHERE cuenta BETWEEN vctamin AND vctamax
                 ORDER BY cuenta
             
                UPDATE sc_param
                   SET valor = vcuenta
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniCieInvCreComp2';
            END FOREACH;
        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 2;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta
                  FROM tmp_invscrec
                 WHERE cuenta BETWEEN vctamin AND vctamax
                 ORDER BY cuenta
                 
                UPDATE sc_param
                   SET valor = vcuenta
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniCieInvCreComp3';
            END FOREACH;
        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 3;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta
                  FROM tmp_invscrec
                 WHERE cuenta BETWEEN vctamin AND vctamax
                 ORDER BY cuenta
                 
                UPDATE sc_param
                   SET valor = vcuenta
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniCieInvCreComp4';
            END FOREACH;
        ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 4;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cuenta
                  INTO vcuenta
                  FROM tmp_invscrec
                 WHERE cuenta BETWEEN vctamin AND vctamax
                 ORDER BY cuenta
                 
                UPDATE sc_param
                   SET valor = vcuenta
                 WHERE empresa = pempresa
                   AND codparam = 'CtaIniCieInvCreComp5';
            END FOREACH;
        END IF;
        
        LET vcont = vcont + 1;  
        LET vcuenta = '';
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;