CREATE PROCEDURE "informix".sp_saldopromedioafecha(pCuenta Char(20), pFechaIni Date, pFechaFin Date, pDias integer)
RETURNING Char(10), Decimal(14,2);

    DEFINE cCodret          Char(5);
    DEFINE cCodret2         Char(5);
    DEFINE cCodret3         Char(50);
    DEFINE cSQL_ERR         Integer;   
    DEFINE cISAM_ERR        Integer;
    DEFINE cDESC_ERR        Char(50);
    DEFINE dFecha           Date;
    DEFINE dSaldoDia        Decimal(14,2);
    DEFINE dSaldoPromedio   Decimal(14,2);
     
    LET cCodret        = '000';
    LET cCodret2       = '000';
    LET cCodret3       = '';
    LET cSQL_ERR       = 0; 
    LET cISAM_ERR      = 0;
    LET cDESC_ERR      = '';
    LET dFecha         = pFechaIni;
    LET dSaldoDia      = 0;        
    LET dSaldoPromedio = 0;

    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_SaldoPromedioaFecha.out';
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET cSQL_ERR, cISAM_ERR, cDESC_ERR
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_SaldoPromedioaFecha.err';
        TRACE ON;
        LET cCodret = cSQL_ERR;
        LET cCodret2 = cISAM_ERR;
        LET cCodret3 = cDESC_ERR;
        RETURN cCodret, dSaldoPromedio;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    WHILE dFecha <= pFechaFin
        EXECUTE PROCEDURE bdicheq:"informix".sp_saldoafecha(pCuenta, dFecha) 
        INTO cCodret, dSaldoDia;

        LET dSaldoPromedio = dSaldoPromedio + dSaldoDia;
        LET dFecha = dFecha + 1;
    END WHILE;

    LET dSaldoPromedio = dSaldoPromedio / pDias;

    IF dSaldoPromedio = '' OR dSaldoPromedio IS NULL THEN 
        LET cCodret = '100'; --- CUENTA NO EXISTE EN FECHA
    END IF;

    RETURN cCodret, dSaldoPromedio;  

    END;

END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa para obtener el saldo promedio a una', 
'             fecha determinada de una cuenta de cheques Captacion',
'EJECUTADO O LLAMADO POR: IPAB, etc',
'AUTOR : Armando Mercado',
'FECHA : Octubre/2008',
'VERSION: 1.00.0000',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_consultamovtoscortetienda( pTipo SMALLINT, 
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

CREATE PROCEDURE "informix".borramovshistold1(pempresa CHAR(3), pcuenta CHAR(20), pfecha DATE)
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcontador1   INTEGER;
    DEFINE vnum_serial  INTEGER;
    
    LET vcodret1    = '000';
    LET vcodret2    = '000';
    LET vcodret3    = '';
    LET sql_err	    = 0;
    LET isam_err    = 0;
    LET desc_err    = '';
    LET vcontador1  = -1;
    LET vnum_serial = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/borramovshistold1.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/borramovshistold1.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 10;
    
    FOREACH cursor_borra FOR
        SELECT {+INDEX(sc_movhis idx_movhisnew1)} num_serial
          INTO vnum_serial
          FROM sc_movhis
         WHERE empresa = pempresa
           AND cuenta = pcuenta
           AND fech_alt = pfecha
           
        IF vcontador1 = -1 THEN
            LET vcontador1 = 0;
        END IF;
        
        DELETE FROM sc_movhis 
         WHERE CURRENT OF cursor_borra;
         
        LET vcontador1 = vcontador1 + 1;
    END FOREACH;

    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;