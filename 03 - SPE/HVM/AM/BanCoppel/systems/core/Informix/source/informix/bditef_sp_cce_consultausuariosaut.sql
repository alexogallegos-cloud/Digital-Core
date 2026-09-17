CREATE PROCEDURE "informix".sp_cce_consultausuariosaut(pNumEjecut INTEGER)
RETURNING CHAR(5)	AS CodigoRetorno,
          INTEGER	AS Ejecutivo,
          CHAR(100)	AS NombreEjecut;

	DEFINE cCodRet        	CHAR(5);
	DEFINE iSql_Err       	INTEGER;
	DEFINE iSam_Err       	INTEGER;
	DEFINE cDesc_Err      	CHAR(60);
	DEFINE iEjecutivo     	INTEGER;
	DEFINE vNombreEjecut	VARCHAR(100);

	LET cCodRet         = "00000";
	LET iSql_Err        = 0;
	LET iSam_Err        = 0;
	LET cDesc_Err      	= "";
	LET iEjecutivo		= 0;
	LET vNombreEjecut   = "";

	--SET DEBUG FILE TO "/respaldosbd/IrmaUreta/sp_cce_controlusuariosaut.out";
	--TRACE ON;
	--SET ENVIRONMENT IFX_BATCHEDREAD_INDEX '1';

BEGIN

    ON EXCEPTION SET iSql_Err, iSam_Err, cDesc_Err
        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet, iEjecutivo, TRIM(vNombreEjecut);
        END IF;
    END EXCEPTION;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Consulta los ejecutivos que se encuentran en la tabla cce_usuarios_revisiÃ³n.
	FOREACH
		SELECT ejecutivo, nombre INTO iEjecutivo, vNombreEjecut
		FROM bditef:"informix".cce_usuarios_revision
		WHERE ejecutivo = DECODE(pNumEjecut,0,ejecutivo,pNumEjecut)

		RETURN cCodRet, iEjecutivo, TRIM(vNombreEjecut) WITH RESUME;
	END FOREACH;

    -- Se verifica si la consulta no encontro informacion.
    IF DBINFO("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = "00001";
		RETURN cCodRet, iEjecutivo, TRIM(vNombreEjecut);
    END IF;

END;
END PROCEDURE
DOCUMENT
"AUTOR: Irma Ureta",
"DB: bditef";

CREATE PROCEDURE "informix".cons_dev_coppel2(pempresa char(3), pfechadevo date, pcuenta1 char(20), pcuenta2 char(20), ptrandev char(4), ptrancom char(4), ptraniva char(4), pRegistros INTEGER, pRecuperacion INTEGER)
            RETURNING 
            char(5),        -- codret
            char(45),       -- sucursal
            char(100),      -- banco
            char(7),        -- nro cheque
            decimal(16,2),  -- importe
            decimal(8,2),   -- comision
            decimal(8,2),   -- iva
			char(45);       -- Motivodev
			

   DEFINE v_codret      char(5);
   DEFINE v_sucursal    char(45);   
   DEFINE v_banco       char(100);
   DEFINE v_numcheque   char(7);
   DEFINE v_importe     decimal(16,2);
   DEFINE v_com         decimal(8,2);   
   DEFINE v_iva         decimal(8,2);   
   DEFINE v_folio       char(16);   
   DEFINE v_motivodev   char(45);   
   DEFINE sql_err,isam_err  int;  

-- arma los datos para el reporte de las 
-- devoluciones cuenta coppel colateral
-- Grupo PISA - Eduardo Espinosa Sep 08
-- v1 version inicial

BEGIN
   on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            RETURN  v_codret,v_sucursal,v_banco,v_numcheque,
            v_importe,v_com,v_iva,v_motivodev;
            end if;
   end exception;

-- ****************************************************************************
-- cons_dev_coppel JYDG
-- ****************************************************************************

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
    let v_codret        = "000";
    let v_sucursal      = " ";      
    let v_banco         = " ";
    let v_numcheque     = " ";        
    let v_importe       = 0;
    let v_com           = 0;   
    let v_iva           = 0;    
	let v_motivodev = '';

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF      pempresa    is null or
            pfechadevo  is null or
            pcuenta1    is null or
            pcuenta2    is null or
            ptrandev    is null or
            ptrancom    is null or
            ptraniva    is null then
    
        -- datos de entrada incompletos     
        LET v_codret = 110; 
        
        RETURN  v_codret,v_sucursal,v_banco,v_numcheque,
                v_importe,v_com,v_iva,v_motivodev;
    END IF;

--	SET DEBUG FILE TO '/tmp/mfinis/cons_dev_coppel2.out';
--	TRACE ON;
-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

    FOREACH

        -- consulta principal

        SELECT SKIP pRegistros FIRST pRecuperacion c.sucursal || " " || s.nombre,
                c.cvebanco || ' ' || b.descripcion,
                c.numcheque,c.monto, c.motivo || ' ' || cdev.descripcion
        INTO    v_sucursal,v_banco,v_numcheque,v_importe, v_motivodev                 
        FROM    bditef:cce_cheques_dev c, bdinteg:si_bancos b,
                bdinteg:si_sucursales s, bdinteg:si_coddevcam cdev
        WHERE   c.empresa = pempresa
                and c.fecha_alta = pfechadevo 
                and c.cvebanco = b.banco
                and c.sucursal=s.sucursal
				and cdev.codigo=c.motivo 
                and c.cta_deposito = pcuenta2 --pcuenta1 lalo dic08
                order by 1

        let v_folio ="";

        -- las devoluciones quedan registradas en la cta2                
        -- buscar el folio de la dev en sc_movdia
      
        select  folio_suc
        into    v_folio
        from    bdicheq:sc_movdia
        where   empresa     = pempresa
        and     cuenta      = pcuenta2
        and     fech_alt    = pfechadevo
        and     monto_tot   = v_importe
        and     num_cheq    = v_numcheque
        and     transacc    = ptrandev;
        
        
        IF v_folio <> ""  THEN
        
            -- importe de la comision
            select  monto_tot
            into    v_com
            from    bdicheq:sc_movdia
            where   empresa     = pempresa
            and     folio_suc   = v_folio
            and     transacc    = ptrancom;
            
            -- importe del iva
            select  monto_tot
            into    v_iva
            from    bdicheq:sc_movdia
            where   empresa     = pempresa
            and     folio_suc   = v_folio
            and     transacc    = ptraniva;   
        
        ELSE
        
            -- buscar el folio de la dev en sc_movhis
            
            select  folio_suc
            into    v_folio
            from    bdicheq:sc_movhis
            where   empresa     = pempresa
            and     cuenta      = pcuenta2
            and     fech_alt    = pfechadevo
            and     monto_tot   = v_importe
            and     num_cheq    = v_numcheque
            and     transacc    = ptrandev;
        
        
            IF v_folio <> ""  THEN
            
                -- importe de la comision
                select  monto_tot
                into    v_com
                from    bdicheq:sc_movhis
                where   empresa     = pempresa
                and     folio_suc   = v_folio
                and     transacc    = ptrancom;
                
                -- importe del iva
                select  monto_tot
                into    v_iva
                from    bdicheq:sc_movhis
                where   empresa     = pempresa
                and     folio_suc   = v_folio
                and     transacc    = ptraniva;   
            
            END IF;    
            
        END IF; 


        RETURN  v_codret,v_sucursal,v_banco,v_numcheque,
                v_importe,v_com,v_iva, v_motivodev
                WITH RESUME;

    END FOREACH     

END;    
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 04/12/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Reporte Diario Devoluciones DepÃ³sitos Coppel', 
'DESCRIPCION: SPL clon de cons_dev_coppel, que hace el armado los datos para el reporte de las devoluciones cuenta coppel colateral.',
'BD: bditef';

CREATE PROCEDURE "informix".cons_dev_coppel2_totales(
            pempresa    char(3),
            pfechadevo  date,
            pcuenta1    char(20),
            pcuenta2    char(20),
            ptrandev    char(4),
            ptrancom    char(4),
            ptraniva    char(4))
            RETURNING 
            char(5),        -- codret
            INTEGER;
			

   DEFINE v_codret      char(5);
   DEFINE v_sucursal    char(45);   
   DEFINE v_banco       char(100);
   DEFINE v_numcheque   char(7);
   DEFINE v_importe     decimal(16,2);
   DEFINE v_com         decimal(8,2);   
   DEFINE v_iva         decimal(8,2);   
   DEFINE v_folio       char(16);   
   DEFINE v_motivodev   char(45);   
   DEFINE sql_err,isam_err  int;   
   DEFINE vnoregistros     INTEGER;

-- arma los datos para el reporte de las 
-- devoluciones cuenta coppel colateral
-- Grupo PISA - Eduardo Espinosa Sep 08
-- v1 version inicial

BEGIN
   on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            RETURN  v_codret,vnoregistros;
            end if;
   end exception;

-- ****************************************************************************
-- cons_dev_coppel JYDG
-- ****************************************************************************

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
    let v_codret        = "000";
    let v_sucursal      = " ";      
    let v_banco         = " ";
    let v_numcheque     = " ";        
    let v_importe       = 0;
    let v_com           = 0;   
    let v_iva           = 0;    
	LET vnoregistros    = 0;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF      pempresa    is null or
            pfechadevo  is null or
            pcuenta1    is null or
            pcuenta2    is null or
            ptrandev    is null or
            ptrancom    is null or
            ptraniva    is null then
    
        -- datos de entrada incompletos     
        LET v_codret = 110; 
        
        RETURN  v_codret,vnoregistros;
    END IF;

-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

    --FOREACH

        -- consulta principal

        SELECT COUNT(*)
		INTO vnoregistros              
        FROM    bditef:cce_cheques_dev c, bdinteg:si_bancos b,
                bdinteg:si_sucursales s, bdinteg:si_coddevcam cdev
        WHERE   c.empresa = pempresa
                and c.fecha_alta = pfechadevo 
                and c.cvebanco = b.banco
                and c.sucursal=s.sucursal
				and cdev.codigo=c.motivo 
                and c.cta_deposito = pcuenta2; --pcuenta1 lalo dic08
    --            order by 1
    --
    --    let v_folio			="";
    --
    --    -- las devoluciones quedan registradas en la cta2                
    --    -- buscar el folio de la dev en sc_movdia
    --
    --  
    --    select  folio_suc
    --    into    v_folio
    --    from    bdicheq:sc_movdia
    --    where   empresa     = pempresa
    --    and     cuenta      = pcuenta2
    --    and     fech_alt    = pfechadevo
    --    and     monto_tot   = v_importe
    --    and     num_cheq    = v_numcheque
    --    and     transacc    = ptrandev;
    --    
    --    
    --    IF v_folio <> ""  THEN
    --    
    --        -- importe de la comision
    --        select  monto_tot
    --        into    v_com
    --        from    bdicheq:sc_movdia
    --        where   empresa     = pempresa
    --        and     folio_suc   = v_folio
    --        and     transacc    = ptrancom;
    --        
    --        -- importe del iva
    --        select  monto_tot
    --        into    v_iva
    --        from    bdicheq:sc_movdia
    --        where   empresa     = pempresa
    --        and     folio_suc   = v_folio
    --        and     transacc    = ptraniva;   
    --    
    --    ELSE
    --    
    --        -- buscar el folio de la dev en sc_movhis
    --        
    --        select  folio_suc
    --        into    v_folio
    --        from    bdicheq:sc_movhis
    --        where   empresa     = pempresa
    --        and     cuenta      = pcuenta2
    --        and     fech_alt    = pfechadevo
    --        and     monto_tot   = v_importe
    --        and     num_cheq    = v_numcheque
    --        and     transacc    = ptrandev;
    --    
    --    
    --        IF v_folio <> ""  THEN
    --        
    --            -- importe de la comision
    --            select  monto_tot
    --            into    v_com
    --            from    bdicheq:sc_movhis
    --            where   empresa     = pempresa
    --            and     folio_suc   = v_folio
    --            and     transacc    = ptrancom;
    --            
    --            -- importe del iva
    --            select  monto_tot
    --            into    v_iva
    --            from    bdicheq:sc_movhis
    --            where   empresa     = pempresa
    --            and     folio_suc   = v_folio
    --            and     transacc    = ptraniva;   
    --        
    --        END IF;    
    --        
    --    END IF; 


        RETURN  v_codret,vnoregistros;

    --END FOREACH     

END;    
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 04/12/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Reporte Diario Devoluciones DepÃ³sitos Coppel', 
'DESCRIPCION: SPL que consulta el nÃºmero total de reportes de las devoluciones cuenta coppel colateral.',
'BD: bditef';

CREATE PROCEDURE "informix".sp_cce_consultar_chequesdev_devcoppel2(pEmpresa CHAR(3), pFecha CHAR(10), cCtaDev CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING
	CHAR(6) 		AS cod_ret,
    CHAR(3) 		AS banco,
	CHAR(20) 		AS num_cuenta,
	CHAR(7) 		AS num_cheque,
    DECIMAL(16,2) 	AS monto,
	CHAR(20) 		AS cta_deposito,
	CHAR(5) 		AS cod_ret_dev,
    CHAR(2) 		AS motivo,
	CHAR(35) 		AS desc_motivo,
	CHAR(4)			AS sucursal,
	CHAR(40)		AS nom_sucursal

	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);	
    DEFINE cBanco			CHAR(3);
	DEFINE cNumCuenta		CHAR(20);
	DEFINE cNumCheque		CHAR(7);
    DEFINE dMonto			DECIMAL(16,2);
	DEFINE cCta_Deposito	CHAR(20);
	DEFINE cCodigoRetDev	CHAR(5);
    DEFINE cMotivo			CHAR(2);
	DEFINE cDescMotivo		CHAR(35);
    DEFINE cSucursal		CHAR(4);
	DEFINE cNomSucursal		CHAR(40);

	

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
    LET cBanco				= "";
	LET cNumCuenta			= "";
	LET cNumCheque			= "";
    LET dMonto				= 0.0;
	LET cCta_Deposito		= "";
	LET cCodigoRetDev		= "";
    LET cMotivo				= "";
	LET cDescMotivo			= "";
    LET cSucursal			= "";
	LET cNomSucursal		= "";

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cSucursal, cNomSucursal WITH RESUME;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/tmp/mfinis/sp_cce_consultar_chequesdev_devcoppel.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" OR  NVL(cCtaDev,"") = "" THEN
        -- FALTA UNO O MAS PARAMETROS
        LET cCodRet = "000001";
        RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cSucursal, cNomSucursal WITH RESUME;
	ELSE
        FOREACH WITH HOLD			
			SELECT SKIP pRegistros FIRST pRecuperacion c.cvebanco,c.numcuenta,c.numcheque,c.monto,c.cta_deposito,c.codigo_retorno,c.motivo,cdev.descripcion, c.sucursal, s.nombre
			INTO cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cSucursal, cNomSucursal
			FROM bditef:cce_cheques_dev c, bdinteg:si_coddevcam cdev, bdinteg:si_sucursales s
			WHERE c.empresa = pEmpresa
			AND fecha_alta = pFecha
			AND cdev.codigo = c.motivo
			AND c.sucursal = s.sucursal
			AND cta_deposito = cCtaDev
			ORDER BY c.sucursal,c.cvebanco

            RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cSucursal, cNomSucursal WITH RESUME;
        END FOREACH 	
    
	END IF
END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 03/12/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Reporte Diario Devoluciones DepÃ³sitos Coppel', 
'DESCRIPCION: SPL clon de sp_cce_consultar_chequesdev_devcoppel que consulta los cheques devueltos de la cce en el aplicativo cce_devcoppel.exe',
'BD: bditef';

CREATE PROCEDURE "informix".sp_cce_consultar_chequesdev_devcoppel2_totales(pEmpresa CHAR(3), pFecha CHAR(10), cCtaDev CHAR(20))

RETURNING
	CHAR(6) 		AS cod_ret,
    INTEGER 		AS vnoregistros
	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);	
    DEFINE cBanco			CHAR(3);
	DEFINE cNumCuenta		CHAR(20);
	DEFINE cNumCheque		CHAR(7);
    DEFINE dMonto			DECIMAL(16,2);
	DEFINE cCta_Deposito	CHAR(20);
	DEFINE cCodigoRetDev	CHAR(5);
    DEFINE cMotivo			CHAR(2);
	DEFINE cDescMotivo		CHAR(35);
    DEFINE cSucursal		CHAR(4);
	DEFINE cNomSucursal		CHAR(40);
	DEFINE vnoregistros     INTEGER;
	

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
    LET cBanco				= "";
	LET cNumCuenta			= "";
	LET cNumCheque			= "";
    LET dMonto				= 0.0;
	LET cCta_Deposito		= "";
	LET cCodigoRetDev		= "";
    LET cMotivo				= "";
	LET cDescMotivo			= "";
    LET cSucursal			= "";
	LET cNomSucursal		= "";
	LET vnoregistros        = 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            RETURN  cCodRet,vnoregistros;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/tmp/mfinis/sp_cce_consultar_chequesdev_devcoppel2_totales.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" OR  NVL(cCtaDev,"") = "" THEN
        -- FALTA UNO O MAS PARAMETROS
        LET cCodRet = "000001";
        RETURN  cCodRet,vnoregistros;
	ELSE	
			SELECT COUNT(*)
			INTO vnoregistros
			FROM bditef:cce_cheques_dev c, bdinteg:si_coddevcam cdev, bdinteg:si_sucursales s
			WHERE c.empresa = pEmpresa
			AND fecha_alta = pFecha
			AND cdev.codigo = c.motivo
			AND c.sucursal = s.sucursal
			AND cta_deposito = cCtaDev;

            RETURN  cCodRet,vnoregistros;
    
	END IF
END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 03/12/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Reporte Diario Devoluciones DepÃ³sitos Coppel', 
'DESCRIPCION: SPL que consulta el numero total de los cheques devueltos de la cce en el aplicativo cce_devcoppel.exe',
'BD: bditef';

CREATE PROCEDURE "informix".sp_cce_chequesrevisados(pTipoOperacion CHAR(1),
                        pTipoSubOperacion   CHAR(1),
                        pEmpresa            CHAR(3),
                        pCveBanco           CHAR(3),
                        pNumCuenta          CHAR(20),
                        pNumCheque          CHAR(7),
                        pFechaPresenta      DATE,
                        pNumCte             CHAR(20),
                        pCtaDeposito        CHAR(20),
                        pMonto              DECIMAL(16,2),
                        pSucursal           CHAR(4),
                        pMotivo             CHAR(2),
                        pEjecutivoReviso    CHAR(8),
                        pFechaRevision      DATE,
                        pTiempoIniRev       DATETIME HOUR TO SECOND,
                        pTiempoFinRev       DATETIME HOUR TO SECOND,
                        pDevuelto           CHAR(1),
                        pRevisado           CHAR(1))
RETURNING CHAR(6)   AS cCodRet;


    DEFINE cCodRet          CHAR(6);
    DEFINE cCodRet2         CHAR(6);
    DEFINE cCodRet3         CHAR(60);
    DEFINE iSql_Err         INTEGER;
    DEFINE iSam_Err         INTEGER;
    DEFINE iDesc_Err        CHAR(60);
    DEFINE dtTiempoTotalRev    DATETIME HOUR TO SECOND;
    DEFINE dFechaHoy        DATE;
    DEFINE cRevisados        CHAR(1);
    DEFINE cCheques            CHAR(7);
    DEFINE cDevueltos       CHAR(1);
    DEFINE cMotivos         CHAR(2);

    LET cCodRet         = '00000';
    LET cCodRet2        = '00000';
    LET cCodRet3        = '';
    LET iSql_Err        = 0;
    LET iSam_Err        = 0;
    LET iDesc_Err       = '';
    LET dtTiempoTotalRev    = '00:00:00';
    LET    dFechaHoy        = '';
    LET cRevisados         = '';
    LET cCheques        = '';
    LET cDevueltos      = '';
    LET cMotivos        = '';

    SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;

SET ENVIRONMENT IFX_BATCHEDREAD_INDEX '1';

    --SET DEBUG FILE TO "/tmp/mfinis/sp_cce_chequesrevisados.out";
    --TRACE ON;
    BEGIN

    ON EXCEPTION SET iSql_Err, iSam_Err, iDesc_Err
        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            LET cCodRet2 = iSam_Err;
            LET cCodRet3 = iDesc_Err;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    -- // Si los parametros vienen vacios '' se convierten a nulos.
    IF pTipoOperacion = '' THEN
        LET pTipoOperacion = NULL;
    END IF;

    -- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(pTipoOperacion,'0') NOT IN ('1','2','3') THEN
        LET cCodRet = '00003';
    END IF;

    -- // OpciÃ³n Insertar
    IF pTipoOperacion = '1' THEN

            SELECT NVL(fecha_hoy,'')
            INSERT INTO  dFechaHoy
            FROM  bdinteg: "informix".si_fechas;


        IF dFechaHoy = pFechaPresenta THEN
            -- // Validar si no existe para insertar
            IF NOT EXISTS (SELECT numcheque FROM "informix".cce_cheques_revisados WHERE numcheque = pNumCheque AND numcuenta = pNumCuenta AND numcte = pNumCte AND fechapresenta = pFechaPresenta) THEN
                LET pTiempoFinRev = '00:00:00';

                INSERT INTO "informix".cce_cheques_revisados (empresa,
                                    cvebanco,
                                    numcuenta,
                                    numcheque,
                                    fechapresenta,
                                    numcte,
                                    cta_deposito,
                                    monto,
                                    sucursal,
                                    motivo,
                                    ejecutivo_reviso,
                                    fecha_revision,
                                    tiempo_inicio_revision,
                                    tiempo_fin_revision,
                                    tiempo_total_revision,
                                    devuelto,
                                    revisado
                                    )
                VALUES (pEmpresa,pCveBanco,pNumCuenta,pNumCheque,pFechaPresenta,pNumCte,pCtaDeposito,pMonto,pSucursal,null,null,null,pTiempoIniRev,pTiempoFinRev, dtTiempoTotalRev, pDevuelto, pRevisado);
            ELSE
                LET cCodRet = '00001';

            END IF;

        END IF;
    ELSE
        -- // Opcion Revisar
        IF pTipoOperacion = '2' THEN

            SELECT revisado, numcheque
            INSERT INTO cRevisados, cCheques
            FROM bditef: "informix".cce_cheques_revisados
            WHERE numcheque = pNumCheque AND numcuenta = pNumCuenta AND numcte = pNumCte AND fechapresenta = pFechaPresenta;
                LET dtTiempoTotalRev = (pTiempoFinRev - pTiempoIniRev)::CHAR(10);

            IF dbinfo("sqlca.sqlerrd2")<>0 THEN

                IF NVL(cRevisados,'') <> '1'THEN
                    UPDATE "informix".cce_cheques_revisados
                    SET     motivo = pMotivo,
                        ejecutivo_reviso = pEjecutivoReviso,
                        fecha_revision = pFechaRevision,
                        tiempo_inicio_revision = pTiempoIniRev,
                        tiempo_fin_revision = pTiempoFinRev,
                        tiempo_total_revision = dtTiempoTotalRev,
                        devuelto = pDevuelto,
                        revisado = pRevisado
                    WHERE numcheque = pNumCheque AND numcuenta = pNumCuenta AND numcte = pNumCte AND fechapresenta = pFechaPresenta;

                END IF;
            END IF;

        ELSE
            -- // OpciÃ³n Devolver
            IF pTipoOperacion = '3' AND pTipoSubOperacion = '0' THEN
                        LET dtTiempoTotalRev = (pTiempoFinRev - pTiempoIniRev)::CHAR(10);

                    SELECT revisado,devuelto,motivo
                    INSERT INTO cRevisados,cDevueltos,cMotivos
                    FROM bditef: "informix".cce_cheques_revisados
                    WHERE numcheque = pNumCheque AND numcuenta = pNumCuenta AND numcte = pNumCte AND fechapresenta = pFechaPresenta;

                    IF dbinfo("sqlca.sqlerrd2")<>0 THEN
                        IF NVL(cRevisados,'') <> '1'THEN
                            UPDATE "informix".cce_cheques_revisados
                            SET     motivo = pMotivo,
                                ejecutivo_reviso = pEjecutivoReviso,
                                fecha_revision = pFechaRevision,
                                tiempo_inicio_revision = pTiempoIniRev,
                                tiempo_fin_revision = pTiempoFinRev,
                                tiempo_total_revision = dtTiempoTotalRev,
                                devuelto = pDevuelto,
                                revisado = pRevisado
                            WHERE numcheque = pNumCheque AND numcuenta = pNumCuenta AND numcte = pNumCte AND fechapresenta = pFechaPresenta;
                        END IF;
                    IF NVL(cRevisados,'') = '1' AND NVL(cDevueltos,'') ='0' OR NVL(cRevisados,'') = '1' AND NVL(cDevueltos,'') ='1' AND NVL(cMotivos,'') <> pMotivo THEN
                            UPDATE "informix".cce_cheques_revisados
                            SET       motivo = pMotivo,
                                      devuelto = pDevuelto
                            WHERE numcheque = pNumCheque AND numcuenta = pNumCuenta AND numcte = pNumCte AND fechapresenta = pFechaPresenta;
                        END IF;
                    END IF;

            END IF;
            -- Actualizar cheque a Devuelto = 0 - Viene de la aplicacion cce_cam.exe
            IF pTipoOperacion = '3' AND pTipoSubOperacion = '1' THEN
                IF EXISTS(SELECT numcuenta FROM 'informix'.cce_cheques_revisados WHERE cvebanco = pCveBanco AND numcuenta = pNumCuenta
                                        AND numcheque = pNumCheque AND monto = pMonto) THEN
                    -- Actualizar el cheque a devuelto = 0
                    UPDATE "informix".cce_cheques_revisados
                    SET devuelto = pDevuelto
                    WHERE cvebanco = pCveBanco AND numcuenta = pNumCuenta AND numcheque = pNumCheque AND monto = pMonto;
                END IF;
            END IF;
        END IF;
    END IF;

    RETURN cCodRet;

    END;
END PROCEDURE
DOCUMENT
'AUTOR: Daniel Lazalde',
'FECHA CREACION: 26 de Diciembre del 2014',
'DESCRIPCION: Se ejecutan tres acciones, da de alta, marca como revisado o marca como devuelto el cheque',
'VERSION: 20141226.0001',
'AUTOR: Carolina Verdugo ',
'FECHA MODIFICACION: 22 de Septiembre de 2015',
'DESCRIPCION: Se agrega condiciÃ³n en la operaciÃ³n 1 para comparar fecha presenta con la fecha actual, en la operaciÃ³n 2 se borra la condiciÃ³n IF EXIST y se agrega la condiciÃ³n si el campo revisados es diferente a 1  ',
'              Al igual que en la operaciÃ³n 3 ',
'BD: BDITEF',
'AUTOR: Jesus Caamal',
'FECHA DE MODIFICACION: 05 de Noviembre de 2015 ',
'DESCRIPCION: Se agrega condiciÃ³n en la operaciÃ³n 3 esta validaciÃ³n cambia los estatus de un cheque de revisado a devuelto y tambien permite cambiar el motivo de devoluciÃ³n de un cheque siempre y cuando el motivo sea diferente al establecido',
'BD: BDITEF';

CREATE PROCEDURE "informix".sp_obtienecheques2(pEmpresa CHAR(3), pBanco CHAR(3), pCuenta CHAR(20), pNumCheque CHAR(7), pFechaPresenta DATE, pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(6)   AS cCodRet,
          CHAR(3)   AS CveBanco,
          CHAR(40)  AS Descripcion,
          CHAR(20)  AS Cuenta,
          CHAR(7)   AS NumCheque,
          DATE      AS FechaALta,
          DATE      AS FechaPresenta,
          CHAR(8)   AS Usuario,
          CHAR(4)   AS Producto,
          CHAR(20)  AS Cliente,
          CHAR(104) AS NombreCliente,
          CHAR(40)  AS NombreProducto,
          CHAR(20)  AS CuentaDep,
          CHAR(1)   AS Revisado,
		      CHAR(8)   AS EjecutivoReviso,
	        DECIMAL(16,2) AS Monto,
       	  CHAR(4) AS Sucursal;
		  
    DEFINE cCodRet          CHAR(6);
    DEFINE cCodRet2         CHAR(6);
    DEFINE cCodRet3         CHAR(60);
    DEFINE iSql_Err         INTEGER;
    DEFINE iSam_Err         INTEGER;
    DEFINE iDesc_Err        CHAR(60);
    DEFINE cCveBanco        CHAR(3);  
    DEFINE cDescripcion     CHAR(40);
    DEFINE iCuenta		    INT8;
    DEFINE iNumCheque       INT8;
    DEFINE dFechaAlta		DATE;
    DEFINE dFechaPresenta   DATE;
    DEFINE cUsuarioAlta		CHAR(8);
    DEFINE cProducto        CHAR(4);
    DEFINE cCliente         CHAR(20);
    DEFINE cNombreCte       CHAR(104);
    DEFINE cNomProducto     CHAR(40);
    DEFINE cCuentaDep       CHAR(20);  
    DEFINE dMonto           DECIMAL(18,2);
    DEFINE cRevisado        CHAR(1);  
    DEFINE cEjecutivoReviso CHAR(8);  
    DEFINE dMontoRet		DECIMAL(16,2);
	  DEFINE cSucursal		CHAR(4);
	
    LET cCodRet         = '00000';
    LET cCodRet2        = '00000';
    LET cCodRet3        = '';
    LET iSql_Err        = 0;
    LET iSam_Err        = 0;
    LET iDesc_Err       = '';
    LET cCveBanco       = '';
    LET cDescripcion    = '';
    LET iCuenta         = 0; 
    LET iNumCheque      = 0;
    LET dFechaAlta      = '01-01-2000';
    LET dFechaPresenta  = '01-01-2000';
    LET cUsuarioAlta    = '';
    LET cProducto       = '';
    LET cCliente        = '';
    LET cNombreCte      = '';
    LET cNomProducto    = '';
    LET cCuentaDep      = '';
    LET dMonto          = 0.00;
	  LET cRevisado       = '';  
    LET cEjecutivoReviso = '';  
	  LET dMontoRet 		= 0.00;
	  LET cSucursal		= '';

    SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;

    SET ENVIRONMENT IFX_BATCHEDREAD_INDEX '1';

    --SET DEBUG FILE TO "/tmp/mfinis/sp_obtienecheques2.out";
    --TRACE ON;

    BEGIN

    ON EXCEPTION SET iSql_Err, iSam_Err, iDesc_Err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtienecheques2.err";
        --TRACE ON;
        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            LET cCodRet2 = iSam_Err;
            LET cCodRet3 = iDesc_Err;
            RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
                   cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
                   NVL(cRevisado,''), NVL(cEjecutivoReviso,''), NVL(dMontoRet,0), NVL(cSucursal,'');	   
        END IF;
    END EXCEPTION;

    -- // Si los parametros vienen vacios '' se convierten a nulos. 
    IF pBanco = '' THEN 
        LET pBanco = NULL;
    END IF;

    IF pCuenta = '' THEN 
        LET pCuenta = NULL;
    END IF;

    IF pNumCheque = '' THEN 
        LET pNumCheque = NULL;
    END IF;

    IF pFechaPresenta = '' THEN 
        LET pFechaPresenta = NULL;
    END IF;

    -- // Valida que al menos traiga valor en un parametro.
    IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NULL THEN  
      LET cCodRet = '00001'; 
      LET cDescripcion = 'Debe mandar al menos un parametro';
      RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
      cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
      NVL(cRevisado,''), NVL(cEjecutivoReviso,''), NVL(dMontoRet,0), NVL(cSucursal,'');
	  END IF
    
    IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NOT NULL THEN  
    
        FOREACH
          SELECT {+INDEX(bditef:cce_cheques_img idx_chequesimg_fecha)} SKIP pRegistros FIRST pRecuperacion 
          DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, 
          img.fechapresenta, img.usuario_alta, det.monto
          INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
          cUsuarioAlta,dMonto
          FROM bditef:cce_cheques_img img
          INNER JOIN (Select {+INDEX(bdinteg:si_bancos idx_ban_flg_nomi)} * From bdinteg:si_bancos) si 
          ON (img.cvebanco = si.banco)
          LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa 
          AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta 
          AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
          WHERE img.fechapresenta = pFechaPresenta

          IF dMonto is null THEN
            LET cCuentaDep = iCuenta;
          ELSE
            -- // Obtiene la cuenta de deposito.
            SELECT UNIQUE doc.cuenta, doc.monto_ori, doc.sucursal --doc.monto
            INTO cCuentaDep, dMontoRet, cSucursal
            FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
            WHERE doc.empresa = pEmpresa
            AND doc.fecha_alta = dFechaAlta
            AND doc.num_chq = iNumCheque
            AND doc.monto_ori = dMonto 
            AND doc.banco = cCveBanco
            --AND doc.numcuenta::INT8 = iCuenta
            AND doc.numcuenta = iCuenta
            AND doc.cancelado <> 'S';
          END IF;
          -- // Consulta el producto y el cliente de la cuenta.
          SELECT UNIQUE producto, num_cte
          INTO cProducto, cCliente
          FROM bdicheq:"informix".sc_maechq 
          WHERE empresa = pEmpresa
          AND cuenta = cCuentaDep;
			   
			    IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
				    --Consulta el nÃ¯Â¿Â½mero de cliente 
				    SELECT mae.numcte 
				    INSERT INTO cCliente
				    FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
				    WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
				
				    --Consulta Nombre de cliente 				
				    SELECT nombre
				    INTO cNombreCte				
				    FROM bdicred: "informix".sd_tarjeta 
				    WHERE num_tarjeta = cCuentaDep;
				
				    --Consulta el nÃ¯Â¿Â½mero y nombre del producto 
						SELECT mae.num_producto, def.nombre_prod 
				    INSERT INTO cProducto, cNomProducto
				    FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
				    WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta = cCuentaDep;
          ELSE 
            -- // Consulta el nombre del cliente.
				    SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
				    INTO cNombreCte
				    FROM bdinteg:"informix".si_cliente  
				    WHERE numcte = cCliente;
  				
            LET cNombreCte = TRIM(cNombreCte);

				    -- // Consulta el nombre del producto.
				    SELECT TRIM(nombre)
				    INTO cNomProducto
				    FROM bdicheq:"informix".sc_producto 
				    WHERE producto = cProducto;
				
			    END IF;

          -- // Consulta revisado y ejecutivo quien reviso --LCJD
			    SELECT revisado, ejecutivo_reviso 
          INTO cRevisado, cEjecutivoReviso
			    FROM bditef:'informix'.cce_cheques_revisados 
			    WHERE numcheque = iNumCheque 
          AND numcuenta = iCuenta 
          AND numcte = cCliente 
          AND fechapresenta = dFechaPresenta;
        
			    IF TRIM(NVL(cRevisado,'')) = '' THEN
          LET cRevisado = '0';
          END IF;
        
          IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
            LET cEjecutivoReviso = '0';
          END IF;			 
            
          RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
          cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
          NVL(cRevisado,''), NVL(cEjecutivoReviso,''), NVL(dMontoRet,0), NVL(cSucursal,'') WITH RESUME;
        END FOREACH;				   
        
    ELIF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NOT NULL AND pFechaPresenta IS NOT NULL THEN  
        
        FOREACH
          SELECT SKIP pRegistros FIRST pRecuperacion {+INDEX(cce_cheques_img idx_cce_cheques_img3)} 
          DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
          INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
          FROM bditef:cce_cheques_img img
          INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
          LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
          WHERE img.fechapresenta = pFechaPresenta
          AND img.numcheque = pNumCheque
			   			   			   
          IF dMonto is null THEN
            LET cCuentaDep = iCuenta;
          ELSE
            -- // Obtiene la cuenta de deposito.
            SELECT UNIQUE doc.cuenta, doc.monto_ori, doc.sucursal --doc.monto
            INTO cCuentaDep, dMontoRet, cSucursal
            FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
            WHERE doc.empresa = pEmpresa
            AND doc.fecha_alta = dFechaAlta
            AND doc.num_chq = iNumCheque
            AND doc.monto_ori = dMonto 
            AND doc.banco = cCveBanco
            --AND doc.numcuenta::INT8 = iCuenta
            AND doc.numcuenta = iCuenta
            AND doc.cancelado <> 'S';
          END IF;

          -- // Consulta el producto y el cliente de la cuenta.
          SELECT UNIQUE producto, num_cte
          INTO cProducto, cCliente
          FROM bdicheq:"informix".sc_maechq 
          WHERE empresa = pEmpresa
          AND cuenta = cCuentaDep;

			    IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
				    --Consulta el nÃ¯Â¿Â½mero de cliente 
				    SELECT mae.numcte 
				    INSERT INTO cCliente
				    FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
				    WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
				
				    --Consulta Nombre de cliente 				
				    SELECT nombre
				    INTO cNombreCte				
				    FROM bdicred: "informix".sd_tarjeta 
				    WHERE num_tarjeta = cCuentaDep;
				
				    --Consulta el nÃ¯Â¿Â½mero y nombre del producto 
						SELECT mae.num_producto, def.nombre_prod 
				    INSERT INTO cProducto, cNomProducto
				    FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
				    WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta =  cCuentaDep;
					ELSE
  				  -- // Consulta el nombre del cliente.
				    SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
            INTO cNombreCte
				    FROM bdinteg:"informix".si_cliente  
				    WHERE numcte = cCliente;

				    LET cNombreCte = TRIM(cNombreCte);

				    -- // Consulta el nombre del producto.
				    SELECT TRIM(nombre)
				    INTO cNomProducto
				    FROM bdicheq:"informix".sc_producto 
				    WHERE producto = cProducto;
          END IF;
			    -- // Consulta revisado y ejecutivo quien reviso --LCJD
          SELECT revisado, ejecutivo_reviso 
          INTO cRevisado, cEjecutivoReviso
          FROM bditef:'informix'.cce_cheques_revisados 
          WHERE numcheque = iNumCheque 
          AND numcuenta = iCuenta 
          AND numcte = cCliente 
          AND fechapresenta = dFechaPresenta;
        
          IF TRIM(NVL(cRevisado,'')) = '' THEN
            LET cRevisado = '0';
          END IF;
        
          IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
            LET cEjecutivoReviso = '0';
          END IF;
			 
          RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
          cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
          NVL(cRevisado,''), NVL(cEjecutivoReviso,''), NVL(dMontoRet,0), NVL(cSucursal,'') WITH RESUME;
        END FOREACH;

    ELIF pBanco IS NOT NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NOT NULL THEN  
    
        FOREACH
          SELECT SKIP pRegistros FIRST pRecuperacion {+INDEX(cce_cheques_img idx_chequesimg_fechbco)} 
          DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
          INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
          FROM bditef:cce_cheques_img img
          INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
          LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
          WHERE img.fechapresenta = pFechaPresenta
          AND img.cvebanco = pBanco

          IF dMonto is null THEN
            LET cCuentaDep = iCuenta;
          ELSE
            -- // Obtiene la cuenta de deposito.
            SELECT UNIQUE doc.cuenta, doc.monto_ori, doc.sucursal --doc.monto
            INTO cCuentaDep, dMontoRet, cSucursal
            FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
            WHERE doc.empresa = pEmpresa
            AND doc.fecha_alta = dFechaAlta
            AND doc.num_chq = iNumCheque
            AND doc.monto_ori = dMonto 
            AND doc.banco = cCveBanco
            --AND doc.numcuenta::INT8 = iCuenta
            AND doc.numcuenta = iCuenta
            AND doc.cancelado <> 'S';
          END IF;
          -- // Consulta el producto y el cliente de la cuenta.
          SELECT UNIQUE producto, num_cte
          INTO cProducto, cCliente
          FROM bdicheq:"informix".sc_maechq 
          WHERE empresa = pEmpresa
          AND cuenta = cCuentaDep;
			   			      
			    IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
				    --Consulta el nÃ¯Â¿Â½mero de cliente 
				    SELECT mae.numcte 
				    INSERT INTO cCliente
				    FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
				    WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
				
				    --Consulta Nombre de cliente 				
				    SELECT nombre
				    INTO cNombreCte				
				    FROM bdicred: "informix".sd_tarjeta 
				    WHERE num_tarjeta = cCuentaDep;
						--Consulta el nÃ¯Â¿Â½mero y nombre del producto 
						SELECT mae.num_producto, def.nombre_prod 
				    INSERT INTO cProducto, cNomProducto
				    FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
				    WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta =  cCuentaDep;			
					ELSE 
			      -- // Consulta el nombre del cliente.
				    SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
				    INTO cNombreCte
				    FROM bdinteg:"informix".si_cliente  
				    WHERE numcte = cCliente;

				    LET cNombreCte = TRIM(cNombreCte);
				    -- // Consulta el nombre del producto.
				    SELECT TRIM(nombre)
				    INTO cNomProducto
				    FROM bdicheq:"informix".sc_producto 
				    WHERE producto = cProducto;
			    END IF;
          -- // Consulta revisado y ejecutivo quien reviso --LCJD
          SELECT revisado, ejecutivo_reviso 
          INTO cRevisado, cEjecutivoReviso
          FROM bditef:'informix'.cce_cheques_revisados 
          WHERE numcheque = iNumCheque 
          AND numcuenta = iCuenta 
          AND numcte = cCliente 
          AND fechapresenta = dFechaPresenta;
            
          IF TRIM(NVL(cRevisado,'')) = '' THEN
            LET cRevisado = '0';
          END IF;
            
          IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
            LET cEjecutivoReviso = '0';
          END IF;
			 
          RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
          cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
          NVL(cRevisado,''), NVL(cEjecutivoReviso,''), NVL(dMontoRet,0), NVL(cSucursal,'') WITH RESUME;
        END FOREACH;
				        
    ELIF pBanco IS NOT NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NULL THEN  
    
        FOREACH
          SELECT SKIP pRegistros FIRST pRecuperacion {+INDEX(cce_cheques_img idx_chequesimg_banco)} 
          DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
          INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
          FROM bditef:cce_cheques_img img
          INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
          LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
          WHERE img.cvebanco = pBanco

          IF dMonto is null THEN
            LET cCuentaDep = iCuenta;
          ELSE
            -- // Obtiene la cuenta de deposito.
            SELECT UNIQUE doc.cuenta, doc.monto_ori, doc.sucursal --doc.monto
            INTO cCuentaDep, dMontoRet, cSucursal
            FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
            WHERE doc.empresa = pEmpresa
            AND doc.fecha_alta = dFechaAlta
            AND doc.num_chq = iNumCheque
            AND doc.monto_ori = dMonto 
            AND doc.banco = cCveBanco
            --AND doc.numcuenta::INT8 = iCuenta
            AND doc.numcuenta = iCuenta
            AND doc.cancelado <> 'S';
          END IF;
          -- // Consulta el producto y el cliente de la cuenta.
          SELECT UNIQUE producto, num_cte
          INTO cProducto, cCliente
          FROM bdicheq:"informix".sc_maechq 
          WHERE empresa = pEmpresa
          AND cuenta = cCuentaDep;
			   			      
          IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
				    --Consulta el nÃ¯Â¿Â½mero de cliente 
				    SELECT mae.numcte 
            INSERT INTO cCliente
				    FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
				    WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
            --Consulta Nombre de cliente 				
            SELECT nombre
				    INTO cNombreCte				
				    FROM bdicred: "informix".sd_tarjeta 
				    WHERE num_tarjeta = cCuentaDep;
						--Consulta el nÃ¯Â¿Â½mero y nombre del producto 
						SELECT mae.num_producto, def.nombre_prod
				    INSERT INTO cProducto, cNomProducto				
				    FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
				    WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta =  cCuentaDep;		
          ELSE 
				    -- // Consulta el nombre del cliente.
				    SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
				    INTO cNombreCte
				    FROM bdinteg:"informix".si_cliente  
				    WHERE numcte = cCliente;

            LET cNombreCte = TRIM(cNombreCte);
				    -- // Consulta el nombre del producto.
				    SELECT TRIM(nombre)
				    INTO cNomProducto
				    FROM bdicheq:"informix".sc_producto 
				    WHERE producto = cProducto;
			    END IF;
          -- // Consulta revisado y ejecutivo quien reviso --LCJD
          SELECT revisado, ejecutivo_reviso 
          INTO cRevisado, cEjecutivoReviso
          FROM bditef:'informix'.cce_cheques_revisados 
          WHERE numcheque = iNumCheque 
          AND numcuenta = iCuenta 
          AND numcte = cCliente 
          AND fechapresenta = dFechaPresenta;
            
          IF TRIM(NVL(cRevisado,'')) = '' THEN
            LET cRevisado = '0';
          END IF;
            
          IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
            LET cEjecutivoReviso = '0';
          END IF;
                  
          RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
          cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
          NVL(cRevisado,''), NVL(cEjecutivoReviso,''), NVL(dMontoRet,0), NVL(cSucursal,'') WITH RESUME;
        END FOREACH;
		
    ELIF pBanco IS NOT NULL AND pCuenta IS NOT NULL AND pNumCheque IS NOT NULL AND pFechaPresenta IS NOT NULL THEN  
    
        FOREACH 
          SELECT SKIP pRegistros FIRST pRecuperacion {+INDEX(cce_cheques_img idx_cce_cheques_img2)} 
          DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
          INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
          FROM bditef:cce_cheques_img img
          INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
          LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
          WHERE img.fechapresenta = pFechaPresenta
          AND img.cvebanco = pBanco
          AND img.numcuenta = pCuenta
          AND img.numcheque = pNumCheque

          IF dMonto is null THEN
            LET cCuentaDep = iCuenta;
          ELSE
            -- // Obtiene la cuenta de deposito.
            SELECT UNIQUE doc.cuenta, doc.monto_ori, doc.sucursal --doc.monto
            INTO cCuentaDep, dMontoRet, cSucursal
            FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
            WHERE doc.empresa = pEmpresa
            AND doc.fecha_alta = dFechaAlta
            AND doc.num_chq = iNumCheque
            AND doc.monto_ori = dMonto 
            AND doc.banco = cCveBanco
            --AND doc.numcuenta::INT8 = iCuenta
            AND doc.numcuenta = iCuenta
            AND doc.cancelado <> 'S';
          END IF;
          -- // Consulta el producto y el cliente de la cuenta.
          SELECT UNIQUE producto, num_cte
          INTO cProducto, cCliente
          FROM bdicheq:"informix".sc_maechq 
          WHERE empresa = pEmpresa
          AND cuenta = cCuentaDep;

          IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
            --Consulta el nÃ¯Â¿Â½mero de cliente 
            SELECT mae.numcte 
            INSERT INTO cCliente
            FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
            WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
            --Consulta Nombre de cliente 				
            SELECT nombre
            INTO cNombreCte				
            FROM bdicred: "informix".sd_tarjeta 
            WHERE num_tarjeta = cCuentaDep;
            --Consulta el nÃ¯Â¿Â½mero y nombre del producto 
            SELECT mae.num_producto, def.nombre_prod 
            INSERT INTO cProducto, cNomProducto
            FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
            WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta =  cCuentaDep;
          ELSE 
            -- // Consulta el nombre del cliente.
            SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
            INTO cNombreCte
            FROM bdinteg:"informix".si_cliente  
            WHERE numcte = cCliente;

            LET cNombreCte = TRIM(cNombreCte);
            -- // Consulta el nombre del producto.
            SELECT TRIM(nombre)
            INTO cNomProducto
            FROM bdicheq:"informix".sc_producto 
            WHERE producto = cProducto;
          END IF;
          -- // Consulta revisado y ejecutivo quien reviso --LCJD
          SELECT revisado, ejecutivo_reviso 
          INTO cRevisado, cEjecutivoReviso
          FROM bditef:'informix'.cce_cheques_revisados 
          WHERE numcheque = iNumCheque 
          AND numcuenta = iCuenta 
          AND numcte = cCliente 
          AND fechapresenta = dFechaPresenta;

          IF TRIM(NVL(cRevisado,'')) = '' THEN
            LET cRevisado = '0';
          END IF;

          IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
            LET cEjecutivoReviso = '0';
          END IF;

          RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
          cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
          NVL(cRevisado,''), NVL(cEjecutivoReviso,''),NVL(dMontoRet,0), NVL(cSucursal,'') WITH RESUME;
		    END FOREACH;				   
	ELSE
    -- // Consulta los cheques que se encuentren en el archivo electronico.
    FOREACH
      SELECT SKIP pRegistros FIRST pRecuperacion {+INDEX(cce_cheques_img idx_cce_cheques_img)} 
      DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
      INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
      FROM bditef:cce_cheques_img img
      INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
      LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
      WHERE ((((((img.numcuenta = CASE WHEN (pCuenta != '' )  THEN pCuenta  ELSE img.numcuenta  END )
      AND (img.cvebanco = CASE WHEN (pBanco != '' )  THEN pBanco  ELSE img.cvebanco  END ) )
      AND (img.numcheque = CASE WHEN (pNumCheque != '' )  THEN pNumCheque  ELSE img.numcheque  END ) )
      AND (img.imagen_formato IN ('jpg' ,'tif' )) ) 
      AND (img.empresa = pEmpresa ) )
      AND (img.fechapresenta = CASE WHEN (NVL (pFechaPresenta,'' )!= '' )  THEN pFechaPresenta  ELSE img.fechapresenta  END ) )

      IF dMonto is null THEN
        LET cCuentaDep = iCuenta;
      ELSE
        -- // Obtiene la cuenta de deposito.
        SELECT UNIQUE doc.cuenta, doc.monto_ori, doc.sucursal --doc.monto
        INTO cCuentaDep, dMontoRet, cSucursal
        FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
        WHERE doc.empresa = pEmpresa
        AND doc.fecha_alta = dFechaAlta
        AND doc.num_chq = iNumCheque
        AND doc.monto_ori = dMonto 
        AND doc.banco = cCveBanco
        --AND doc.numcuenta::INT8 = iCuenta
        AND doc.numcuenta = iCuenta
        AND doc.cancelado <> 'S';
      END IF;
      -- // Consulta el producto y el cliente de la cuenta.
      SELECT UNIQUE producto, num_cte
      INTO cProducto, cCliente
      FROM bdicheq:"informix".sc_maechq 
      WHERE empresa = pEmpresa
      AND cuenta = cCuentaDep;

      IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
        --Consulta el nÃ¯Â¿Â½mero de cliente 
        SELECT mae.numcte 
        INSERT INTO cCliente
        FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
        WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
        --Consulta Nombre de cliente 				
        SELECT nombre
        INTO cNombreCte				
        FROM bdicred: "informix".sd_tarjeta 
        WHERE num_tarjeta = cCuentaDep;
        --Consulta el nÃ¯Â¿Â½mero y nombre del producto 
        SELECT mae.num_producto, def.nombre_prod 
        INSERT INTO cProducto, cNomProducto
        FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
        WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta =  cCuentaDep;		
      ELSE
        -- // Consulta el nombre del cliente.
        SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
        INTO cNombreCte
        FROM bdinteg:"informix".si_cliente  
        WHERE numcte = cCliente;

        LET cNombreCte = TRIM(cNombreCte);
        -- // Consulta el nombre del producto.
        SELECT TRIM(nombre)
        INTO cNomProducto
        FROM bdicheq:"informix".sc_producto 
        WHERE producto = cProducto;
      END IF;
      -- // Consulta revisado y ejecutivo quien reviso --LCJD
      SELECT revisado, ejecutivo_reviso 
      INTO cRevisado, cEjecutivoReviso
      FROM 'informix'.cce_cheques_revisados 
      WHERE numcheque = iNumCheque 
      AND numcuenta = iCuenta 
      AND numcte = cCliente 
      AND fechapresenta = dFechaPresenta;

      IF TRIM(NVL(cRevisado,'')) = '' THEN
        LET cRevisado = '0';
      END IF;

      IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
        LET cEjecutivoReviso = '0';
      END IF;

      RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
      cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
      NVL(cRevisado,''), NVL(cEjecutivoReviso,''), NVL(dMontoRet,0), NVL(cSucursal,'') WITH RESUME;
    END FOREACH;
	   
  END IF;
    
  -- // Se verifica si la consulta regreso informacion.
  IF DBINFO("sqlca.sqlerrd2") = 0 THEN
    LET cCodRet = '000002';
    LET cDescripcion = 'No se encuentran registros';
    RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
    cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
    NVL(cRevisado,''), NVL(cEjecutivoReviso,''), NVL(dMontoRet,0), NVL(cSucursal,'');
  END IF;

END;
END PROCEDURE

DOCUMENT
'AUTOR: Valentin Lopez Valenzuela',
'FECHA CREACION: 15 de Julio del 2011',
'DESCRIPCION: Regresa los cheques que se encuentren en el archivo electronico.',

'MODIFICO: Guadalupe Payan',
'FECHA MODIFICACION: 15 de Agosto del 2011',
'DESCRIPCION: Se cambio la longitud de la variable iNumCheque a un char de 7 ya que asi esta en la tabla productiva',
'se cambio la longitud de la variable cDescripcion a char 40,se cambio la longitud de la variable cNombreCte a',
'char 104, se elimino la bandera iCont se sustituyo por el comando DBINFO',

'MODIFICO: Carolina Verdugo ',
'FECHA MODIFICACION: 23 de Septiembre del 2015',
'DESCRIPCION: Se realiza cambio en caso de que no se haya encontrado informaciÃ¯Â¿Â½n en la maechq se agregan nuevos query para obtenerla ',
'VERSION: 20110815.1117',

'FECHA MODIFICACION: 11 de Noviembre del 2024',
'DESCRIPCION: Se realiza ajuste para que se tome el monto_ori del cheque',
'BD:bditef';

CREATE PROCEDURE "informix".sp_obtienecheques2_totales(pEmpresa       CHAR(3), 
                                               pBanco         CHAR(3), 
                                               pCuenta        CHAR(20), 
                                               pNumCheque     CHAR(7),
                                               pFechaPresenta DATE)
RETURNING CHAR(6)   AS cCodRet,
		  INTEGER AS totalRegistrosRevisados,
		  INTEGER AS totalRegistros;
		  
    DEFINE cCodRet          CHAR(6);
    DEFINE cCodRet2         CHAR(6);
    DEFINE cCodRet3         CHAR(60);
    DEFINE iSql_Err         INTEGER;
    DEFINE iSam_Err         INTEGER;
    DEFINE iDesc_Err        CHAR(60);
    DEFINE cCveBanco        CHAR(3);  
    DEFINE cDescripcion     CHAR(40);
    DEFINE iCuenta		    INT8;
    DEFINE iNumCheque       INT8;
    DEFINE dFechaAlta		DATE;
    DEFINE dFechaPresenta   DATE;
    DEFINE cUsuarioAlta		CHAR(8);
    DEFINE cProducto        CHAR(4);
    DEFINE cCliente         CHAR(20);
    DEFINE cNombreCte       CHAR(104);
    DEFINE cNomProducto     CHAR(40);
    DEFINE cCuentaDep       CHAR(20);  
    DEFINE dMonto           DECIMAL(18,2);
    DEFINE cRevisado        CHAR(1);  
    DEFINE cEjecutivoReviso CHAR(8);  
    DEFINE dMontoRet		DECIMAL(16,2);
	DEFINE cSucursal		CHAR(4);
	DEFINE iTotalRegistrosRevisados INTEGER;
    DEFINE iTotalRegistros	INTEGER;
	
		
    LET cCodRet         = '00000';
    LET cCodRet2        = '00000';
    LET cCodRet3        = '';
    LET iSql_Err        = 0;
    LET iSam_Err        = 0;
    LET iDesc_Err       = '';
    LET cCveBanco       = '';
    LET cDescripcion    = '';
    LET iCuenta         = 0; 
    LET iNumCheque      = 0;
    LET dFechaAlta      = '01-01-2000';
    LET dFechaPresenta  = '01-01-2000';
    LET cUsuarioAlta    = '';
    LET cProducto       = '';
    LET cCliente        = '';
    LET cNombreCte      = '';
    LET cNomProducto    = '';
    LET cCuentaDep      = '';
    LET dMonto          = 0.00;
	LET cRevisado       = '';  
    LET cEjecutivoReviso = '';  
	LET dMontoRet 		= 0.00;
	LET cSucursal		= '';
	LET iTotalRegistrosRevisados = 0;
	LET iTotalRegistros = 0;

    SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;

    SET ENVIRONMENT IFX_BATCHEDREAD_INDEX '1';

    --SET DEBUG FILE TO "/tmp/mfinis/sp_obtienecheques2_totales.out";
    --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET iSql_Err, iSam_Err, iDesc_Err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtienecheques2_totales.err";
        --TRACE ON;
        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            LET cCodRet2 = iSam_Err;
            LET cCodRet3 = iDesc_Err;
            RETURN cCodRet, iTotalRegistrosRevisados, iTotalRegistros;
        END IF;
    END EXCEPTION;

    -- // Si los parametros vienen vacios '' se convierten a nulos. 
    IF pBanco = '' THEN 
        LET pBanco = NULL;
    END IF;

    IF pCuenta = '' THEN 
        LET pCuenta = NULL;
    END IF;

    IF pNumCheque = '' THEN 
        LET pNumCheque = NULL;
    END IF;

    IF pFechaPresenta = '' THEN 
        LET pFechaPresenta = NULL;
    END IF;

    -- // Valida que al menos traiga valor en un parametro.
    IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NULL THEN  
        LET cCodRet = '00001'; 
        LET cDescripcion = 'Debe mandar al menos un parametro';
        RETURN cCodRet, iTotalRegistrosRevisados, iTotalRegistros;
	END IF
    
    IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NOT NULL THEN  
		
		FOREACH
			SELECT DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
			INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto			
              FROM bditef:cce_cheques_img img
             INNER JOIN (select * from bdinteg:si_bancos) si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE img.fechapresenta = pFechaPresenta
			 			 
            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   --AND doc.numcuenta::INT8 = iCuenta
                   AND doc.numcuenta = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT UNIQUE producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;
			   
			 IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
				--Consulta el nÃÂºmero de cliente 
				SELECT mae.numcte 
				INSERT INTO cCliente
				FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
				WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
				
				--Consulta Nombre de cliente 				
				SELECT nombre
				INTO cNombreCte				
				FROM bdicred: "informix".sd_tarjeta 
				WHERE num_tarjeta = cCuentaDep;
				
				--Consulta el nÃÂºmero y nombre del producto 
								
				SELECT mae.num_producto, def.nombre_prod 
				INSERT INTO cProducto, cNomProducto
				FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
		  	WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta = cCuentaDep;
							 
			ELSE 
            -- // Consulta el nombre del cliente.
				SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
				  INTO cNombreCte
				  FROM bdinteg:"informix".si_cliente  
				 WHERE numcte = cCliente;

				LET cNombreCte = TRIM(cNombreCte);

				-- // Consulta el nombre del producto.
				SELECT TRIM(nombre)
				INTO cNomProducto
				FROM bdicheq:"informix".sc_producto 
				WHERE producto = cProducto;
				
			END IF;
            -- // Consulta revisado y ejecutivo quien reviso --LCJD
			SELECT revisado, ejecutivo_reviso
              INTO cRevisado, cEjecutivoReviso
			  FROM bditef:'informix'.cce_cheques_revisados 
			 WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
			
			IF cRevisado == 1 THEN
				LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;
			END IF;
			
			IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
			END IF;
        
			IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
			END IF;			 
            
			LET iTotalRegistros = iTotalRegistros + 1;
		END FOREACH;
		
		RETURN cCodRet, iTotalRegistrosRevisados, iTotalRegistros;
        			   
        
    ELIF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NOT NULL AND pFechaPresenta IS NOT NULL THEN  
        
		FOREACH 
            SELECT DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM bditef:cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE img.fechapresenta = pFechaPresenta
               AND img.numcheque = pNumCheque
			   			   			   
            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   --AND doc.numcuenta::INT8 = iCuenta
                   AND doc.numcuenta = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT UNIQUE producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;
			   

			 IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
				--Consulta el nÃÂºmero de cliente 
				SELECT mae.numcte 
				INSERT INTO cCliente
				FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
				WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
				
				--Consulta Nombre de cliente 				
				SELECT nombre
				INTO cNombreCte				
				FROM bdicred: "informix".sd_tarjeta 
				WHERE num_tarjeta = cCuentaDep;
				
				--Consulta el nÃÂºmero y nombre del producto 
								
				SELECT mae.num_producto, def.nombre_prod 
				INSERT INTO cProducto, cNomProducto
				FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
				WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta =  cCuentaDep;
			 
			ELSE 

				-- // Consulta el nombre del cliente.
				SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
				  INTO cNombreCte
				  FROM bdinteg:"informix".si_cliente  
				 WHERE numcte = cCliente;

				LET cNombreCte = TRIM(cNombreCte);

				-- // Consulta el nombre del producto.
				SELECT TRIM(nombre)
				  INTO cNomProducto
				  FROM bdicheq:"informix".sc_producto 
				 WHERE producto = cProducto;
				 
			 END IF;
			-- // Consulta revisado y ejecutivo quien reviso --LCJD
            SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
              FROM bditef:'informix'.cce_cheques_revisados 
             WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
			   
			
			IF cRevisado == 1 THEN
				LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;
			END IF;
			
            IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
            END IF;
        
            IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
            END IF;
			 
			LET iTotalRegistros = iTotalRegistros + 1;
		END FOREACH;	
		RETURN cCodRet, iTotalRegistrosRevisados, iTotalRegistros;
        

    ELIF pBanco IS NOT NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NOT NULL THEN  
     
        FOREACH 
            SELECT DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM bditef:cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE img.fechapresenta = pFechaPresenta
               AND img.cvebanco = pBanco

            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   --AND doc.numcuenta::INT8 = iCuenta
                   AND doc.numcuenta = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT UNIQUE producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;
			   
			      
			 IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
				--Consulta el nÃÂºmero de cliente 
				SELECT mae.numcte 
				INSERT INTO cCliente
				FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
				WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
				
				--Consulta Nombre de cliente 				
				SELECT nombre
				INTO cNombreCte				
				FROM bdicred: "informix".sd_tarjeta 
				WHERE num_tarjeta = cCuentaDep;
				
				--Consulta el nÃÂºmero y nombre del producto 
								
				SELECT mae.num_producto, def.nombre_prod 
				INSERT INTO cProducto, cNomProducto
				FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
				WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta =  cCuentaDep;			
							 
			ELSE 
			-- // Consulta el nombre del cliente.
				SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
				  INTO cNombreCte
				  FROM bdinteg:"informix".si_cliente  
				 WHERE numcte = cCliente;

				LET cNombreCte = TRIM(cNombreCte);

				-- // Consulta el nombre del producto.
				SELECT TRIM(nombre)
				  INTO cNomProducto
				  FROM bdicheq:"informix".sc_producto 
				 WHERE producto = cProducto;
			END IF;
            -- // Consulta revisado y ejecutivo quien reviso --LCJD
            SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
              FROM bditef:'informix'.cce_cheques_revisados 
             WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;

			IF cRevisado == 1 THEN
				LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;
			END IF;
			   
            IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
            END IF;
            
            IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
            END IF;
			 
			LET iTotalRegistros = iTotalRegistros + 1;
		END FOREACH;	
		RETURN cCodRet, iTotalRegistrosRevisados, iTotalRegistros;
				        
    ELIF pBanco IS NOT NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NULL THEN  
    
        FOREACH 
            SELECT DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM bditef:cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE img.cvebanco = pBanco

            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   --AND doc.numcuenta::INT8 = iCuenta
                   AND doc.numcuenta = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT UNIQUE producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;
			   
			      
			 IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
				--Consulta el nÃÂºmero de cliente 
				SELECT mae.numcte 
				INSERT INTO cCliente
				FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
				WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
				
				--Consulta Nombre de cliente 				
				SELECT nombre
				INTO cNombreCte				
				FROM bdicred: "informix".sd_tarjeta 
				WHERE num_tarjeta = cCuentaDep;
				
				--Consulta el nÃÂºmero y nombre del producto 
								
				SELECT mae.num_producto, def.nombre_prod
				INSERT INTO cProducto, cNomProducto				
				FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
				WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta =  cCuentaDep;		
				
							 
			ELSE 
				-- // Consulta el nombre del cliente.
				SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
				  INTO cNombreCte
				  FROM bdinteg:"informix".si_cliente  
				 WHERE numcte = cCliente;

				LET cNombreCte = TRIM(cNombreCte);

				-- // Consulta el nombre del producto.
				SELECT TRIM(nombre)
				  INTO cNomProducto
				  FROM bdicheq:"informix".sc_producto 
				 WHERE producto = cProducto;
			END IF;
            -- // Consulta revisado y ejecutivo quien reviso --LCJD
            SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
              FROM bditef:'informix'.cce_cheques_revisados 
             WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
            
			IF cRevisado == 1 THEN
				LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;
			END IF;
			
            IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
            END IF;
            
            IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
            END IF;
                  
			LET iTotalRegistros = iTotalRegistros + 1;
		END FOREACH;	
		RETURN cCodRet, iTotalRegistrosRevisados, iTotalRegistros;
		
    ELIF pBanco IS NOT NULL AND pCuenta IS NOT NULL AND pNumCheque IS NOT NULL AND pFechaPresenta IS NOT NULL THEN  
     
        FOREACH 
            SELECT DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM bditef:cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE img.fechapresenta = pFechaPresenta
               AND img.cvebanco = pBanco
               AND img.numcuenta = pCuenta
               AND img.numcheque = pNumCheque

            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   --AND doc.numcuenta::INT8 = iCuenta
                   AND doc.numcuenta = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT UNIQUE producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;
			   
			      
			 IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
				--Consulta el nÃÂºmero de cliente 
				SELECT mae.numcte 
				INSERT INTO cCliente
				FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
				WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
				
				--Consulta Nombre de cliente 				
				SELECT nombre
				INTO cNombreCte				
				FROM bdicred: "informix".sd_tarjeta 
				WHERE num_tarjeta = cCuentaDep;
				
				--Consulta el nÃÂºmero y nombre del producto 
								
				SELECT mae.num_producto, def.nombre_prod 
				INSERT INTO cProducto, cNomProducto
				FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
				WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta =  cCuentaDep;
				
				
							 
			ELSE 

				-- // Consulta el nombre del cliente.
				SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
				  INTO cNombreCte
				  FROM bdinteg:"informix".si_cliente  
				 WHERE numcte = cCliente;

				LET cNombreCte = TRIM(cNombreCte);

				-- // Consulta el nombre del producto.
				SELECT TRIM(nombre)
				  INTO cNomProducto
				  FROM bdicheq:"informix".sc_producto 
				 WHERE producto = cProducto;
			END IF;
			-- // Consulta revisado y ejecutivo quien reviso --LCJD
			SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
			  FROM bditef:'informix'.cce_cheques_revisados 
			 WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
        
			IF cRevisado == 1 THEN
				LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;
			END IF;
			
			IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
			END IF;
        
			IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
			END IF;
			 
			LET iTotalRegistros = iTotalRegistros + 1;
		END FOREACH;	
		RETURN cCodRet, iTotalRegistrosRevisados, iTotalRegistros;
				   
	ELSE
    
        -- // Consulta los cheques que se encuentren en el archivo electronico.
        FOREACH 
            SELECT DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM bditef:cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN bditef:cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE ((((((img.numcuenta = CASE WHEN (pCuenta != '' )  THEN pCuenta  ELSE img.numcuenta  END )
               AND (img.cvebanco = CASE WHEN (pBanco != '' )  THEN pBanco  ELSE img.cvebanco  END ) )
               AND (img.numcheque = CASE WHEN (pNumCheque != '' )  THEN pNumCheque  ELSE img.numcheque  END ) )
               AND (img.imagen_formato IN ('jpg' ,'tif' )) ) 
               AND (img.empresa = pEmpresa ) )
               AND (img.fechapresenta = CASE WHEN (NVL (pFechaPresenta,'' )!= '' )  THEN pFechaPresenta  ELSE img.fechapresenta  END ) )

            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   --AND doc.numcuenta::INT8 = iCuenta
                   AND doc.numcuenta = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT UNIQUE producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;
			   
			      
			 IF dbinfo("sqlca.sqlerrd2")= 0 THEN 
				--Consulta el nÃÂºmero de cliente 
				SELECT mae.numcte 
				INSERT INTO cCliente
				FROM bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar
				WHERE mae.num_credito = tar.num_credito AND tar.num_tarjeta = cCuentaDep;
				
				--Consulta Nombre de cliente 				
				SELECT nombre
				INTO cNombreCte				
				FROM bdicred: "informix".sd_tarjeta 
				WHERE num_tarjeta = cCuentaDep;
				
				--Consulta el nÃÂºmero y nombre del producto 
								
				SELECT mae.num_producto, def.nombre_prod 
				INSERT INTO cProducto, cNomProducto
				FROM  bdicred: "informix".sd_maecred mae, bdicred: "informix".sd_tarjeta tar, bdicred: "informix".sd_definicion def
				WHERE mae.num_credito = tar.num_credito AND mae.num_producto = def.num_producto AND tar.num_tarjeta =  cCuentaDep;		
				
							 
			ELSE 

            -- // Consulta el nombre del cliente.
				SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
				  INTO cNombreCte
				  FROM bdinteg:"informix".si_cliente  
				 WHERE numcte = cCliente;

				LET cNombreCte = TRIM(cNombreCte);

				-- // Consulta el nombre del producto.
				SELECT TRIM(nombre)
				  INTO cNomProducto
				  FROM bdicheq:"informix".sc_producto 
				 WHERE producto = cProducto;
			END IF;
			
			-- // Consulta revisado y ejecutivo quien reviso --LCJD
			SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
			  FROM bditef:'informix'.cce_cheques_revisados 
			 WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
        
			IF cRevisado == 1 THEN
				LET iTotalRegistrosRevisados = iTotalRegistrosRevisados + 1;
			END IF;
			
			IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
			END IF;
        
			IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
			END IF;
			 
			LET iTotalRegistros = iTotalRegistros + 1;
		END FOREACH;	
		RETURN cCodRet, iTotalRegistrosRevisados, iTotalRegistros;
	   
    END IF;
    
    -- // Se verifica si la consulta regreso informacion.
    IF DBINFO("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = '00002';
        LET cDescripcion = 'No se encuentran registros';
        RETURN cCodRet, iTotalRegistrosRevisados, iTotalRegistros;
    END IF;

    END;
    
END PROCEDURE

DOCUMENT
'AUTOR: Valentin Lopez Valenzuela',
'FECHA CREACION: 15 de Julio del 2011',
'DESCRIPCION: Regresa los cheques que se encuentren en el archivo electronico.',

'MODIFICO: Guadalupe Payan',
'FECHA MODIFICACION: 15 de Agosto del 2011',
'DESCRIPCION: Se cambio la longitud de la variable iNumCheque a un char de 7 ya que asi esta en la tabla productiva',
'se cambio la longitud de la variable cDescripcion a char 40,se cambio la longitud de la variable cNombreCte a',
'char 104, se elimino la bandera iCont se sustituyo por el comando DBINFO',

'MODIFICO: Carolina Verdugo ',
'FECHA MODIFICACION: 23 de Septiembre del 2015',
'DESCRIPCION: Se realiza cambio en caso de que no se haya encontrado informaciÃÂ³n en la maechq se agregan nuevos query para obtenerla ',
'VERSION: 20110815.1117',
'BD: BDITEF';

CREATE PROCEDURE "informix".sp_validaimagenescheques(pCveBanco CHAR(3), pCuenta CHAR(20),pNumCheque CHAR(7))
RETURNING  CHAR(5) ,CHAR(50), CHAR(3);

    DEFINE cCodRet 			CHAR(5);
    DEFINE iSqlErr 			INTEGER;
    DEFINE cMensaje         CHAR(50);
    DEFINE cImagen	        BLOB;
    DEFINE iTamImg          INTEGER;
    DEFINE cImgFormato 			CHAR(3);


    LET cCodRet 			= '00000';
    LET cMensaje            = 'Ejecucion Exitosa';
    LET iTamImg			    = 0;
    LET cImgFormato 		= '';

    BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;
            RETURN cCodRet,cMensaje,cImgFormato;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/RRM/sp_validaimagenescheques.out";
    --- SET DEBUG FILE TO "/respaldosbd/VLV/sp_validaimagenescheques.out";
    --TRACE ON;

    IF pCuenta = '' OR pNumCheque = '' OR pCveBanco = '' THEN
        LET cCodRet = '00001';
        LET cMensaje = 'Faltan Parametros para su ejecucion';
        LET cImgFormato 		= '';
        RETURN cCodRet,cMensaje,cImgFormato;
    END IF;

    SELECT FIRST 1 Imagen, imagen_tam, imagen_formato
      INTO cImagen, iTamImg, cImgFormato
      FROM  bditef:cce_cheques_img
     WHERE numcuenta = pCuenta
       AND cvebanco= pCveBanco
       AND numcheque = pNumCheque
       AND empresa='001';

    IF cImagen IS NULL THEN
        LET cCodRet = '00002';
        LET cMensaje = 'No existe la imagen del cheque';
        LET cImgFormato 		= '';
        RETURN cCodRet,cMensaje,cImgFormato;
    END IF;

    RETURN cCodRet,cMensaje,cImgFormato;

    END

END PROCEDURE
DOCUMENT
'DESCRIPCION: Verifica si existe la imagen del cheque en la tabla cce_cheques_img',
'AUTOR: Valentin Lopez',
'FECHA: 15 de Febrero del 2011',
'VERSION: 20110215.1745',
'BD: BDITEF';

CREATE PROCEDURE "informix".sp_cce_consultar_chequesdev_consdev2_totales(pEmpresa CHAR(3), pFecha CHAR(10))
RETURNING
	CHAR(6) 		AS cod_ret,
    INTEGER 		AS no_registros


	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

    DEFINE cBanco			CHAR(3);
	DEFINE cNumCuenta		CHAR(20);
	DEFINE cNumCheque		CHAR(7);
    DEFINE dMonto			DECIMAL(16,2);
	DEFINE cCta_Deposito	CHAR(20);
	DEFINE cCodigoRetDev	CHAR(5);
    DEFINE cMotivo			CHAR(2);
	DEFINE cDescMotivo		CHAR(35);
	DEFINE iNoRegistros     INTEGER;


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";

    LET cBanco				= "";
	LET cNumCuenta			= "";
	LET cNumCheque			= "";
    LET dMonto				= 0.0;
	LET cCta_Deposito		= "";
	LET cCodigoRetDev		= "";
    LET cMotivo				= "";
	LET cDescMotivo			= "";
	LET iNoRegistros 		= 0;



BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultar_chequesdev_consdev.out';
--	TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" THEN
        --FALTAN EMPRESA O FECHA
        LET cCodRet = "000001";
		RETURN cCodRet, iNoRegistros;
	ELSE
	
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bditef:cce_cheques_dev c,bdinteg:si_coddevcam cdev
		WHERE empresa = pEmpresa
		AND fechapresenta = pFecha
		AND cdev.codigo = c.motivo;

		RETURN cCodRet, iNoRegistros;

	END IF
END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 11/12/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Reportes Resultado de la AplicaciÃ³n', 
'DESCRIPCION: SPL clon que consulta el numero total de los cheques devueltos de la cce en el aplicativo cce_consdev.exe',
'BD: bditef';

CREATE PROCEDURE "informix".sp_cce_consultar_chequesdev_consdev2(pEmpresa CHAR(3),pFecha CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING
	CHAR(6) 		AS cod_ret,
    CHAR(3) 		AS banco,
	CHAR(20) 		AS num_cuenta,
	CHAR(7) 		AS num_cheque,
    DECIMAL(16,2) 	AS monto,
	CHAR(20) 		AS cta_deposito,
	CHAR(5) 		AS cod_ret_dev,
    CHAR(2) 		AS motivo,
	CHAR(35) 		AS desc_motivo


	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cBanco			CHAR(3);
	DEFINE cNumCuenta		CHAR(20);
	DEFINE cNumCheque		CHAR(7);
    DEFINE dMonto			DECIMAL(16,2);
	DEFINE cCta_Deposito	CHAR(20);
	DEFINE cCodigoRetDev	CHAR(5);
    DEFINE cMotivo			CHAR(2);
	DEFINE cDescMotivo		CHAR(35);


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
    LET cBanco				= "";
	LET cNumCuenta			= "";
	LET cNumCheque			= "";
    LET dMonto				= 0.0;
	LET cCta_Deposito		= "";
	LET cCodigoRetDev		= "";
    LET cMotivo				= "";
	LET cDescMotivo			= "";

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo WITH RESUME;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultar_chequesdev_consdev2.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pFecha,"") = "" THEN
        --FALTAN EMPRESA O FECHA
        LET cCodRet = "000001";
		RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo WITH RESUME;
	ELSE
        FOREACH WITH HOLD
			SELECT SKIP pRegistros FIRST pRecuperacion c.cvebanco,c.numcuenta,c.numcheque,c.monto,c.cta_deposito,c.codigo_retorno,c.motivo,cdev.descripcion
			INTO cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo
			FROM bditef:cce_cheques_dev c,bdinteg:si_coddevcam cdev
			WHERE empresa = pEmpresa
			AND fechapresenta = pFecha
			AND cdev.codigo = c.motivo

            RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo WITH RESUME;
        END FOREACH

	END IF
END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 11/12/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Reportes Resultado de la AplicaciÃ³n', 
'DESCRIPCION: SPL clon que consulta los cheques devueltos de la cce en el aplicativo cce_consdev.exe',
'BD: bditef';

CREATE PROCEDURE "informix".sp_tef_procesararchivo60(cNombreArchivo CHAR(20), cNombreArchivo61 CHAR(20), cUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  PROCESA  LOS DATOS DE LAS CUENTAS DEL ARCHIVO 60.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 25/04/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
-----
-- DESCRIPCION:  SE AGREGAN VALIDACIONES PARA CUENTAS DE CREDITO Y DEBITO
-- LLAMADO AL PRINCIPAL Y REVERSION
-- AUTOR : Alfonso Antonio Cruz Alvarez.
-- FECHA : 10/08/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos

--****************************************************************************************************

--DEFINICION DE VARIABLES.
DEFINE dFechaHoy				DATE;
DEFINE dFechaManana				DATE;
--DEFINE vdFechaEnvioProveedor DATE;--27/04/2012
DEFINE cFechaManana				CHAR (8);

DEFINE cFechaPresentacion_Gen	CHAR(8);

DEFINE cCodRet					CHAR(5);
DEFINE cCodRet2					CHAR(5);
DEFINE cCodRet3					CHAR(5);
DEFINE cStatusTar				CHAR(2);
DEFINE cPrefijoTarjeta			CHAR(6);

DEFINE cCuenta					CHAR(12);
DEFINE cStatusCta				CHAR (1);
DEFINE cProducto				CHAR (4);

DEFINE cNombreArch				CHAR(20);
DEFINE cFechaPresentacion		CHAR(8);
DEFINE cTipoRegistro			CHAR(2);
DEFINE cNumSecuencia			CHAR(7);
DEFINE cCodOperacion			CHAR(2);
DEFINE cCodDivisa				CHAR(2);
DEFINE cFechaTrans				CHAR(8);
DEFINE cBancoPresentador		CHAR(3);
DEFINE cBancoReceptor			CHAR(3);
DEFINE cImporte					CHAR(15);
DEFINE cUsoFuturoCcen			CHAR(16);
DEFINE cTipoOperacion			CHAR(2);
DEFINE cFechaAplica				CHAR(8);
DEFINE cTipoCtaOrd				CHAR(2);
DEFINE cNumCtaOrd				CHAR(20);
DEFINE cNombreOrd				CHAR(40);
DEFINE cRfcOrd					CHAR(18);
DEFINE cTipoCtaRec				CHAR(2);
DEFINE cNumCtaRec				CHAR(20);
DEFINE cNombreRec				CHAR(40);
DEFINE cRfcRec					CHAR(18);
DEFINE cRefServicio				CHAR(40);
DEFINE cNombreTitularServ		CHAR(40);
DEFINE cImporteIva				CHAR(15);
DEFINE cRefNumerica				CHAR(7);
DEFINE cRefLeyenda				CHAR(40);
DEFINE cClaveRastreo			CHAR(30);
DEFINE cMotivoDev				CHAR(2);
DEFINE cFechaPresIni			CHAR(8);
DEFINE cSolicitudConfirmacion	CHAR(1);
DEFINE cUsoFuturoBanco			CHAR(11);
DEFINE cRefConfirmacion			CHAR(30);
DEFINE cUsoFuturoCce			CHAR(1);
DEFINE cTasaTiieProm			CHAR(7);
DEFINE cDiasRetraso				CHAR(3);
DEFINE cImpTotInt				CHAR(15);
DEFINE cCveEstatus				CHAR(11);
DEFINE cFolioSuc				CHAR(30);
DEFINE cMotivoBloqueo			CHAR(2);
DEFINE cPermiteAbono			CHAR(1);

--DEFINE cNumSecuenciaS CHAR(7); --dsb-27/04/2012
DEFINE cNum_Operaciones_S		CHAR(18);

DEFINE cClaveBancaria			CHAR(3);
DEFINE cPrefijoTarjetaDebito	CHAR(100);
DEFINE cProductosNoPermitidos	CHAR(90);
DEFINE cSucursalContable		CHAR(4);
DEFINE cNumeroFolioAbono		CHAR (16);
DEFINE cTransaccAbono			CHAR(4);
--DEFINE cReferenciaAbono CHAR(50);
DEFINE mSaldoAPagar				MONEY(16,2);
DEFINE cTransacAbonoCred		CHAR(4);

DEFINE iContadorSecuencia61		INTEGER;
DEFINE iImporteTotalArchivo61	INT8;

--DEFINE viContadorSecuencia62 INTEGER; --dsb-27/04/2012
--DEFINE viImporteTotalArchivo62 INTEGER;--dsb-27/04/2012

--*
DEFINE cNumCte 					CHAR(20);
DEFINE sCanal					SMALLINT;
DEFINE cEsTransfer				CHAR(1);
DEFINE cUserInsert				CHAR(8);
DEFINE dtFechaHoraInsert		DATETIME YEAR TO SECOND;
--*

--ENCABEZADO
DEFINE cCveBancoE				CHAR(3);
DEFINE cServicioE				CHAR(1);
DEFINE cNumBloqueE				CHAR(7);
DEFINE cCodDivisaE				CHAR(2);
DEFINE cCveRechazoBlE			CHAR(2);
DEFINE cModalidadE				CHAR(1);
DEFINE cUsoFuturoCcenE			CHAR(41);
DEFINE cUsoFuturoBancoE			CHAR(370);

--SUMARIO
DEFINE cNum_BloqueS				CHAR (7);
DEFINE cUsoFuturoCcenS			CHAR (40);
DEFINE cUsoFuturoBancoS			CHAR (364);


DEFINE cNombreArchivoAUX		CHAR(20);
DEFINE iContadorSecuenciaAUX	INTEGER;

--REVERSOS
DEFINE cTransaccCargo			CHAR(4);
DEFINE cTranRet					CHAR(4);
DEFINE mSaldoDisponible			MONEY(16,2);
DEFINE mMontoRetenido			MONEY(16,2);

--TRANSACCIONES
DEFINE cFlagEnTransaccion		CHAR (1);
DEFINE iContadorRegistros		INTEGER;

DEFINE iSQLErr					INTEGER;

--RETORNO DEL PRINCIPAL
DEFINE mRemanente				MONEY(14,2);
DEFINE mIntMoraCob				MONEY(14,2);
DEFINE mIntVencCob				MONEY(14,2);
DEFINE mCapVencCob				MONEY(14,2);
DEFINE mIntVigCob				MONEY(14,2);
DEFINE mCapVigCob				MONEY(14,2);
DEFINE mImpuesto				MONEY(14,2);
DEFINE mComision				MONEY(14,2);
DEFINE mSeguro					MONEY(14,2);

--INICIALIZACION DE VARIABLES.
LET cCodRet					= '';
LET cCodRet2				= '';
LET cCodRet3				= '';

LET cPrefijoTarjeta			= '';

LET cCuenta					= '';
LET cStatusCta				= '';
LET cProducto				= '';
LET dFechaHoy				= CURRENT;
LET dFechaManana			= CURRENT;
LET cFechaManana			= '';
LET cStatusTar				= '';
LET cFechaPresentacion_Gen	= '';

LET cNombreArch				= '';
LET cFechaPresentacion		= '';
LET cTipoRegistro			= '';
LET cNumSecuencia			= '';
LET cCodOperacion			= '';
LET cCodDivisa				= '';
LET cFechaTrans				= '';
LET cBancoPresentador		= '';
LET cBancoReceptor			= '';
LET cImporte				= '';
LET cUsoFuturoCcen			= '';
LET cTipoOperacion			= '';
LET cFechaAplica			= '';
LET cTipoCtaOrd				= '';
LET cNumCtaOrd				= '';
LET cNombreOrd				= '';
LET cRfcOrd					= '';
LET cTipoCtaRec				= '';
LET cNumCtaRec				= '';
LET cNombreRec				= '';
LET cRfcRec					= '';
LET cRefServicio			= '';
LET cNombreTitularServ		= '';
LET cImporteIva				= '';
LET cRefNumerica			= '';
LET cRefLeyenda				= '';
LET cClaveRastreo			= '';
LET cMotivoDev				= '';
LET cFechaPresIni			= '';
LET cSolicitudConfirmacion	= '';
LET cUsoFuturoBanco			= '';
LET cRefConfirmacion		= '';
LET cUsoFuturoCce			= '';
LET cTasaTiieProm			= '';
LET cDiasRetraso			= '';
LET cImpTotInt				= '';
LET cCveEstatus				= '';
LET cFolioSuc				= '';

--LET cNumSecuenciaS = '';--dsb-27/04/2012
LET cNum_Operaciones_S		= '';


LET cClaveBancaria			= '';
LET cPrefijoTarjetaDebito	= '';
LET cProductosNoPermitidos	= '';
LET cSucursalContable		= '';
LET cNumeroFolioAbono		= '';
LET cTransaccAbono			= '';
--LET cReferenciaAbono = '';
LET mSaldoAPagar			= 0.0;
LET cTransacAbonoCred		= '';

LET iContadorSecuencia61	= 0;
LET iImporteTotalArchivo61	= 0;

--LET viContadorSecuencia62 = 0;--dsb-27/04/2012
--LET viImporteTotalArchivo62 = 0;--dsb-27/04/2012

--*
LET cNumCte 				= "";
LET sCanal					= 0;
LET cEsTransfer				= "";
LET cUserInsert				= "";
LET dtFechaHoraInsert		= DATE(1);
--*

--ENCABEZADO
LET cCveBancoE				= '';
LET cServicioE				= '';
LET cNumBloqueE				= '';
LET cCodDivisaE				= '';
LET cCveRechazoBlE			= '';
LET cModalidadE				= '';
LET cUsoFuturoCcenE			= '';
LET cUsoFuturoBancoE		= '';
LET cMotivoBloqueo			= '';
LET cPermiteAbono			= '';

--SUMARIO
LET cNum_BloqueS			= '';
LET cUsoFuturoCcenS			= '';
LET cUsoFuturoBancoS		= '';

LET cNombreArchivoAUX		= '';
LET iContadorSecuenciaAUX	= '';

--REVERSOS
LET cTransaccCargo			= '';
LET cTranRet				= '';
LET dFechaHoy				= CURRENT;
LET mSaldoDisponible		= 0.0;
LET mMontoRetenido			= 0.0;

--RETORNO DEL PRINCIPAL
LET mRemanente				=0;
LET mIntMoraCob				=0;
LET mIntVencCob				=0;
LET mCapVencCob				=0;
LET mIntVigCob				=0;
LET mCapVigCob				=0;
LET mImpuesto				=0;
LET mComision				=0;
LET mSeguro					=0;


--TRANSACCIONES
LET cFlagEnTransaccion		= 'F';
LET iContadorRegistros		= 0;

LET iSQLErr					= 0;

  --SET DEBUG FILE TO '/RESPALDOSNEW/depuraremesas/sp_procesararchivo60.out';
  --TRACE ON;

BEGIN
ON EXCEPTION SET iSQLErr
	IF iSQLErr <> 0 THEN

		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((iContadorRegistros > 0) OR (cFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET cFlagEnTransaccion = 'F';
		END IF;

		LET cFlagEnTransaccion = 'F';
		LET iContadorRegistros = 0;

		--EN CASO DE ERROR NO CONTROLADO SE REVERSAN LOS ABONOS
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--DSB-27/04/2012
		
		LET cCodRet = iSQLErr;

		RETURN cCodRet;
	END IF;
END EXCEPTION;



	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;

	-------SE OBTIENEN LOS PARAMETROS----
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT FIRST 1 Valor INTO cClaveBancaria FROM BdiTef:"informix".Tef_Parametros WHERE cod_param = '75';

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cPrefijoTarjetaDebito FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76'; -- PREFIJO TARJETA DEBITO

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cSucursalContable FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77'; --SUCURSAL CONTABLE

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cTransaccCargo FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '78'; --TRANSACCION CARGO TEF
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cTransaccAbono FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '79'; --TRANSACCION ABONO TEF
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--EXTRAE LA FECHA HOY EN EL SISTEMA
	SELECT FIRST 1 Fecha_hoy INTO dFechaHoy FROM BdiCheq:"informix".sc_fechas;

	
	--MODIFICADO A SOLICITUD DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN
	--PERMITIR EL PROCESO DE ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
	--2011/09/29
	--AUMENTA UN DIA LA FECHA ACTUAL (PRESENTACION) PARA SER LA FECHA CARGO/PROGRAMACION
	LET dFechaManana = dFechaHoy + 1;
	
	--ASIGNA UN FORMATO DE FECHA PARA FUTURA FECHA DE PRESENTACION
	LET cFechaPresentacion_Gen = YEAR(dFechaHoy)|| LPAD(MONTH (dFechaHoy),2,'0') || LPAD(DAY (dFechaHoy),2,'0');

	--VALIDA/PROPORCIONA LA FECHA T+1
	EXECUTE PROCEDURE BdInteg:"informix".sp_Valfecha_Banca('001', dFechaManana, 0 ) INTO cCodRet2,dFechaManana;
	--VALIDA LA FECHA ACTUAL
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(cFechaPresentacion_Gen) INTO cCodRet3;

	--ASIGNA UN FORMATO DE FECHA
	LET cFechaManana = YEAR(dFechaManana )|| LPAD(MONTH (dFechaManana ),2,'0') || LPAD(DAY (dFechaManana ),2,'0');

	--VALIDA LA FECHA MANANA
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(cFechaManana) INTO cCodRet;



	IF (NOT EXISTS (SELECT Sucursal FROM BdInteg:"informix".Si_Sucursales WHERE Sucursal = cSucursalContable)) THEN --VALIDAR SI EXISTE EN EL CATÃÂÃÂLOGO LA SUCURSAL CONTABLE.
		LET cCodRet = '02300';
	ELIF (cCodRet <> '00000') THEN -- VALIDA KE LA FECHA MANANA SEA VALIDA
		LET cCodRet = '02301';
	ELIF (cCodRet2 <> '000') THEN -- VALIDA KE LA FECHA MANANA SEA UN DIA HABIL
		LET cCodRet = '02302';
	ELIF (cCodRet3 <> '00000') THEN -- VALIDA KE LA FECHA HOY SEA VALIDA
		LET cCodRet = '02303';
	ELSE

		LET cFlagEnTransaccion = 'F';
		LET iContadorRegistros = 0;

		LET iContadorSecuencia61 = 1; --A PARTIR DE 2 ES PARA EL DETALLE
		LET iImporteTotalArchivo61 = 0;


		--DSB-27/04/2012
		--LET viContadorSecuencia62 = 1; --A PARTIR DE 2 ES PARA EL DETALLE
		--LET viImporteTotalArchivo62 = 0;



		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS REGISTROS VALIDOS DEL ARCHIVO 60 PARA PROCESAR
		FOREACH WITH HOLD
			SELECT
			Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans,
			Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord,
			Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio,
			Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini,
			Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso,
			Imp_Tot_Int, Cve_Status, Folio_Suc
			INTO
			cNombreArch, cFechaPresentacion, cTipoRegistro, cNumSecuencia, cCodOperacion, cCodDivisa, cFechaTrans,
			cBancoPresentador, cBancoReceptor, cImporte, cUsoFuturoCcen, cTipoOperacion, cFechaAplica, cTipoCtaOrd,
			cNumCtaOrd, cNombreOrd, cRfcOrd, cTipoCtaRec, cNumCtaRec, cNombreRec, cRfcRec, cRefServicio,
			cNombreTitularServ, cImporteIva, cRefNumerica, cRefLeyenda, cClaveRastreo, cMotivoDev, cFechaPresIni,
			cSolicitudConfirmacion, cUsoFuturoBanco, cRefConfirmacion, cUsoFuturoCce, cTasaTiieProm, cDiasRetraso,
			cImpTotInt, cCveEstatus, cFolioSuc
			FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
			WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60'
			AND Cve_Status = '00'
			ORDER BY Num_Secuencia ASC


				
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (cFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET cFlagEnTransaccion = 'V';
			END IF;

			LET cMotivoDev = '00';
			LET cStatusCta = '';
            LET cMotivoBloqueo			= '';
            LET cPermiteAbono			= '';

			LET cCodRet = '00000';
			LET cNombreArchivoAUX = "";
				---------------------------------------------------------------------------------
				--VALIDACION DE CUENTAS
				-- 1.- Motivo 06 "CUENTA NO PERTENECE AL BANCO RECEPTOR" --
				
			IF ( TRIM(cTipoCtaRec) IN ('11','12','13') ) THEN    --VALIDACION PARA CONOCER SI ES CREDITO O DEBITO 
				--LA CUENTA ES DE CREDITO
				--IF ( TRIM(cTipoCtaRec)='11') THEN   --VALIDACION PARA SABER SI ES CREDITO, SE OBTIENE EL NUMERO DE CREDITO
				LET cCuenta = SUBSTR(cNumCtaRec,9,12);
				--IF  ( SUBSTR(cNumCtaRec,3,3) = TRIM( cClaveBancaria ) ) THEN --VALIDA BANCO - CUENTA
					IF ( EXISTS ( SELECT Num_Credito FROM BdiCred:Sd_MaeCred
						WHERE Empresa = '001' AND Num_Credito = cCuenta ) )  THEN --VALIDA NUMERO DE CREDITO
						IF ( EXISTS ( SELECT NUM_CREDITO FROM BDICRED:"informix".Sd_MaeCred
							WHERE EMPRESA = '001' AND NUM_CREDITO = cCuenta AND status_cred IN ('AA','BT','BA') ) ) THEN

							
						ELSE
							LET cMotivoDev = '02'; --LA CUENTA DE CREDITO NO ESTA ACTIVA
						END IF;
					ELSE
						LET cMotivoDev = '01'; --LA CUENTA DE CREDITO NO EXISTE
					END IF;
				--ELSE
				--	LET cMotivoDev = '06'; --CUENTA NO PERTENECE AL BANCO RECEPTOR
				--END IF;
				IF (EXISTS (SELECT num_cta_ord FROM bditef:tef_cte_lista_negra WHERE num_cta_ord = LPAD(cNumCtaOrd,20,'0'))) THEN --SE VALIDA QUE NO ESTE EN LISTA NEGRA SI NO SE RECHAZA
					LET cMotivoDev = '02';
				END IF;
			ELSE
				--*
				IF (TRIM(NVL(cTipoCtaRec, '')) = '10') THEN -- VALIDAMOS TIPO CUENTA MOVIL
					-- EJECUTAMOS EL PROCEDIMIENTO NUEVO 
					EXECUTE PROCEDURE bdicheq:"informix".sp_tef_constelctacte (SUBSTR(cNumCtaRec, 11,10)) -- OBTENEMOS LA CUENTA DEL NUMERO MOVIL 
					INTO  cCodRet, cNumCte, cCuenta, sCanal, cEsTransfer, cUserInsert, dtFechaHoraInsert; -- REGRESA CUENTA DEL TELEFONO MOVIL
					
					-- SI NO HAY CUENTA PARA EL  MOVIL, ASIGNAMOS MOTIVO DEVOLUCIÃÂÃÂN.
					IF NVL(cCuenta, '') = '' THEN	
						LET cMotivoDev = '01'; -- CUENTA INEXISTENTE.
					END IF;
				--*
			
				ELIF ( TRIM(cTipoCtaRec) = '40') THEN    --ES UNA NUEVA CLABE
					LET cCuenta = SUBSTR(cNumCtaRec,9,11);
				ELIF ( TRIM(cTipoCtaRec) = '03') THEN  --
					SELECT FIRST 1 NVL(Cuenta,''), status_tar INTO cCuenta, cStatusTar FROM BdiCheq:"informix".Sc_Tarjeta WHERE Empresa = '001' AND Num_Tarjeta = SUBSTR(TRIM(cNumCtaRec),5,16);
				ELSE
					LET cMotivoDev = '06'; --CUENTA NO PERTENECE AL BANCO RECEPTOR
				END IF;

						-----------------ModificaciÃÂÃÂ³n
				IF (cStatusTar = 'C') THEN
					LET cMotivoDev = '03';
				END IF;
				LET cStatusTar = ' ';                        
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				
				--OBTIENE DATOS DE LA CUENTA
				SELECT FIRST 1 NVL(Status_Cta, ''), NVL(Producto, ''), motivo INTO cStatusCta, cProducto, cMotivoBloqueo
                FROM BdiCheq:"informix".Sc_MaeChq WHERE Empresa = '001' AND Cuenta = cCuenta;
				
				
				
				
				--IF (NVL(cProducto, '') LIKE '%' || TRIM(cProductosNoPermitidos) || '%' ) THEN --VALIDA QUE SEA UN PRODUCTO NO PERMITIDO
				IF (NOT EXISTS (SELECT Cve_Producto FROM BdiTef:"informix".Tef_Prod_Permitidos WHERE Cve_Producto = cProducto) ) THEN --VALIDA QUE SEA UN PRODUCTO PERMITIDO
					LET cMotivoDev = '06'; --CLIENTE NO TIENE AUTORIZADO EL SERVICIO
				ELIF (NVL(cStatusCta, '') = '') THEN --VALIDA KE EXISTA LA CUENTA
					LET cMotivoDev = '01'; --CUENTA INEXISTENTE
				ELIF (cStatusCta = '3') THEN --VALIDA KE  LA CUENTA NO ESTE BLOQUEADA
                    SELECT  abono INTO cPermiteAbono from bdicheq:sc_bloqueo where codigo = cMotivoBloqueo;
                    IF cPermiteAbono <> 'S' THEN
                       LET cMotivoDev = '02';
                    END IF;
				ELIF (cStatusCta IN ('3','5','6','7','8')) THEN --VALIDA KE  LA CUENTA NO ESTE CANCELADA
					LET cMotivoDev = '03';
				ELIF (NOT EXISTS (SELECT Divisa FROM BdiCheq:"informix".Sc_Producto WHERE Empresa = '001' AND Producto = cProducto AND Divisa = '01')) THEN
					LET cMotivoDev = '05';
			    END IF;
					--END IF;
				IF (EXISTS (SELECT num_cta_ord FROM bditef:tef_cte_lista_negra WHERE num_cta_ord = LPAD(cNumCtaOrd,20,'0'))) THEN --SE VALIDA QUE NO ESTE EN LISTA NEGRA SI NO SE RECHAZA
					LET cMotivoDev = '02';
				END IF;	
			
				IF ((cMotivoDev = '00') AND --VALIDA SI NO HA SIDO RECHAZADO POR ALGUN MOTIVO
					(EXISTS (SELECT Num_Secuencia
					FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
					WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60'
					AND Banco_Presentador = cBancoPresentador
					AND Banco_Receptor = cBancoReceptor
					AND Importe = cImporte
					AND Fecha_Aplica = cFechaAplica
					AND Num_Cta_Ord = cNumCtaOrd
					AND Rfc_Ord = cRfcOrd
					AND Tipo_Cta_Rec = cTipoCtaRec
					AND nombre_ord = cNombreOrd
					AND Ref_Leyenda = cRefLeyenda
					AND Ref_Numerica = cRefNumerica
					AND num_cta_rec = cNumCtaRec
					AND clave_rastreo = cClaveRastreo
					AND Num_Secuencia::INTEGER < cNumSecuencia::INTEGER))) THEN --VALIDA KE NO SE REPITA EL REGISTRO
						LET cMotivoDev = '07';
				END IF;

				
			END IF;
			
			IF ((cCodRet::INTEGER <> 0) OR (cMotivoDev <> '00')) THEN -- ERROR AL REALIZAR EL ABONO  / REGISTRO RECHAZADO 61

				--GUARDA EL REGISTRO CON ERROR DE APLICACION DE ABONO EN EL ARCHIVO 61
				LET iContadorSecuencia61 = iContadorSecuencia61 + 1;
				LET iImporteTotalArchivo61 = iImporteTotalArchivo61 + NVL(cImporte,0)::BIGINT;
				LET cMotivoDev = DECODE (cCodRet::INTEGER, 0, cMotivoDev, '06') ;

				LET cNombreArchivoAUX = cNombreArchivo61;
				LET iContadorSecuenciaAUX = iContadorSecuencia61;
			
			END IF;
			

			
			IF (((cCodRet::INTEGER <> 0) OR (cMotivoDev <> '00')))THEN
				--INSERTA EL REGISTRO RECHAZADO EN EL ARCHIVO 61
				INSERT INTO BdiTef:"informix".Tef_Cce_Detalle_Paso
				(
					Nombre_Arch,
					Fecha_Presentacion,
					Tipo_Registro,
					Num_Secuencia,
					Cod_Operacion,
					Cod_Divisa,
					Fecha_Trans,
					Banco_Presentador,
					Banco_Receptor,
					Importe,
					Uso_Futuro_Ccen,
					Tipo_Operacion,
					Fecha_Aplica,
					Tipo_Cta_Ord,
					Num_Cta_Ord,
					Nombre_Ord,
					Rfc_Ord,
					Tipo_Cta_Rec,
					Num_Cta_Rec,
					Nombre_Rec,
					Rfc_Rec,
					Ref_Servicio,
					Nombre_Titular_Serv,
					Importe_Iva,
					Ref_Numerica,
					Ref_Leyenda,
					Clave_Rastreo,
					Motivo_Dev,
					Fecha_Pres_Ini,
					Solicitud_Confirmacion,
					Uso_Futuro_Banco,
					Ref_Confirmacion,
					Uso_Futuro_Cce,
					Tasa_Tiie_Prom,
					Dias_Retraso,
					Imp_Tot_Int,
					Cve_Status,
					Folio_Suc,
					User_Insert,
					Fecha_Insert
				)
				VALUES
				(
					NVL(cNombreArchivoAUX,''), --E13718052012.6101    
					NVL(cFechaManana,''), -- FECHA PRESENTACION -- T+1
					NVL(cTipoRegistro,''),
					NVL(LPAD(iContadorSecuenciaAUX,7,'0'),''),--NUM_SECUENCIA
					--NVL(DECODE (cNombreArchivoAUX, cNombreArchivo61, '62', '61'),''), --CODIGO DE OPERACION / ARCHIVO
					NVL('61',''), --CODIGO DE OPERACION / ARCHIVO
					NVL(cCodDivisa,''),
					NVL(cFechaTrans,''),
					NVL(cBancoReceptor,''),  --BANCO PRESENTADOR
					NVL(cBancoPresentador,''),  --BANCO RECEPTOR
					NVL(cImporte,''),
					NVL(cUsoFuturoCcen,''),
					NVL(cTipoOperacion,''),
					NVL(cFechaAplica,''),
					NVL(cTipoCtaOrd,''),
					NVL(cNumCtaOrd,''),
					NVL(cNombreOrd,''),
					NVL(cRfcOrd,''),
					NVL(cTipoCtaRec,''),
					NVL(cNumCtaRec,''),
					NVL(cNombreRec,''),
					NVL(cRfcRec,''),
					NVL(cRefServicio,''),
					NVL(cNombreTitularServ,''),
					NVL(cImporteIva,''),
					NVL(cRefNumerica,''),
					NVL(cRefLeyenda,''),
					NVL(cClaveRastreo,''),
					NVL(cMotivoDev,''), --MOTIVO DEVOLUCION
					NVL(cFechaPresIni,''),
					NVL(cSolicitudConfirmacion,''),
					NVL(cUsoFuturoBanco,''),
					NVL(DECODE (cNombreArchivoAUX, cNombreArchivo61, (DECODE(cSolicitudConfirmacion,'1',cNumeroFolioAbono,cRefConfirmacion)), cRefConfirmacion),''),--REF_CONFIRMACION
					NVL(cUsoFuturoCce,''),
					NVL(cTasaTiieProm,''),
					NVL(cDiasRetraso,''),
					NVL(cImpTotInt,''),
					NVL(cCveEstatus,''),
					NVL(DECODE (cNombreArchivoAUX, cNombreArchivo61, cNumeroFolioAbono, cFolioSuc),''), -- FOLIO_SUC
					cUsuario, --USUARIO_INSERT
					CURRENT::DATE --FECHA_INSERT
				);
			END IF;

			--ACTUALIZA EL REGISTRO DEL  ARCHIVO 60
			UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso
--	2012.08.06 I
--				SET Cve_Status = DECODE (cNombreArchivoAUX, cNombreArchivo61, '01'/*OK*/, '00'/*ERROR*/),
			SET Cve_Status = DECODE (cNombreArchivoAUX, cNombreArchivo61, '02'/*Error*/, '00'/*Ok*/),
--	2012.08.06 F
			Folio_Suc = DECODE (cNombreArchivoAUX, cNombreArchivo61, cNumeroFolioAbono, cFolioSuc),
			motivo_dev = cMotivoDev
			WHERE Nombre_Arch = cNombreArchivo
			AND Cod_operacion = '60'
			AND Banco_Presentador = cBancoPresentador
			AND Banco_Receptor = cBancoReceptor
			AND Importe = cImporte
			AND Fecha_Aplica = cFechaAplica
			AND Num_Cta_Ord = cNumCtaOrd
			AND Rfc_Ord = cRfcOrd
			AND Tipo_Cta_Rec = cTipoCtaRec
			AND Ref_Leyenda = cRefLeyenda
			AND Num_Secuencia = cNumSecuencia;

			
			LET iContadorRegistros = iContadorRegistros + 1;

			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			--IF (iContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				--COMMIT WORK;--prueba
				--LET cFlagEnTransaccion = 'F';
				--LET iContadorRegistros = 0;
				--CONTINUE FOREACH;
			--END IF;*/
		END FOREACH;

		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((iContadorRegistros > 0) OR (cFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET cFlagEnTransaccion = 'F';
		END IF;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS DATOS DEL REGISTRO DE ENCABEZADO ORIGINAL 60
		SELECT FIRST 1 Cve_Banco, Servicio, Num_Bloque, Cod_Divisa, Cve_Rechazo_bl,
		Modalidad, Uso_Futuro_Ccen, Uso_Futuro_Banco
		INTO cCveBancoE, cServicioE, cNumBloqueE, cCodDivisaE, cCveRechazoBlE,
		cModalidadE, cUsoFuturoCcenE, cUsoFuturoBancoE
		FROM BdiTef:"informix".Tef_Cce_Encabezado_Paso
		WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60';

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS DATOS DEL REGISTRO DE SUMARIO ORIGINAL 60
		SELECT FIRST 1 Num_Bloque, Uso_Futuro_ccen, Uso_Futuro_banco
		INTO cNum_BloqueS, cUsoFuturoCcenS, cUsoFuturoBancoS
		FROM BdiTef:"informix".Tef_Cce_Sumario_Paso
		WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60';

		
		IF (iContadorSecuencia61 > 1) THEN --VALIDA SI EXISTEN REGISTROS PARA EL ARCHIVO 61

			--FORMA EL REGISTRO DE ENCABEZADO
			--ENCABEZADO
			INSERT INTO BdiTef:"informix".Tef_Cce_Encabezado_Paso
			(
				Nombre_Arch,
				Fecha_Presentacion,
				Tpo_Registro,
				Num_Secuencia,
				Cod_Operacion,
				Cve_Banco,
				Sentido,
				Servicio,
				Num_Bloque,
				Cod_Divisa,
				Cve_Rechazo_bl,
				Modalidad,
				Uso_Futuro_Ccen,
				Uso_Futuro_Banco,
				User_Insert,
				Fecha_Insert
			)
			VALUES
			(
				--cNombreArchivo61,
				--cFechaManana, -- FECHA PRESENTACION -- T+1
				NVL(cNombreArchivo61,''),
				NVL(cFechaManana,''),
				'01', --TIPO REGISTRO
				NVL(LPAD('1',7,'0'),''), --'0000001', --SECUENCIA
				'61', --ARCHIVO
				NVL(cCveBancoE,''), --BANCOPEL 137
				'E', --SENTIDO
				NVL(cServicioE,''), --SERVICIO
				--NVL(cNumBloqueE,''), --NUM BLOQUE
				--NVL(LPAD(DAY(cFechaManana),2,'0') || LPAD((SUBSTR(cNombreArchivo61,(LENGTH(TRIM(cNombreArchivo61)) - 1), 2)),5,'0'),''), --NUM BLOQUE
				NVL(SUBSTR(cFechaManana, 7, 2) || LPAD((SUBSTR(cNombreArchivo61,(LENGTH(TRIM(cNombreArchivo61)) - 1), 2)),5,'0'),''), --NUM BLOQUE
				NVL(cCodDivisaE,''), --DIVISA
				NVL(cCveRechazoBlE,''),--CVE_RECHAZO_BL
				NVL(cModalidadE,''),--MODALIDAD
				NVL(cUsoFuturoCcenE,''), --USO_FUTURO_CCEN
				NVL(cUsoFuturoBancoE,''),--USO_FUTURO_BANCO
				cUsuario,
				CURRENT::DATE
			);
			
			--FORMA EL REGISTRO DE SUMARIO
			--SUMARIO
			INSERT INTO BdiTef:"informix".Tef_Cce_Sumario_Paso
			(
				Nombre_Arch,
				Fecha_Presentacion,
				Tipo_Registro,
				Num_Secuencia,
				Cod_Operacion,
				Num_Bloque,
				Num_Operaciones,
				Imp_Operaciones,
				Uso_Futuro_ccen,
				Uso_Futuro_banco,
				User_Insert,
				Fecha_Insert
			)
			VALUES
			(
				NVL(cNombreArchivo61,''), --NOMBRE_ARCH
				NVL(cFechaManana,''), --FECHA_PRESENTACION
				'09', --TIPO_REGISTRO
				NVL(LPAD((iContadorSecuencia61+1),7,'0'),''), --SECUENCIA
				'61', --COD_OPERACION
				--NVL(cNum_BloqueS,''),--NUM BLOQUE
				--NVL(LPAD(DAY(cFechaManana),2,'0') || LPAD((SUBSTR(cNombreArchivo61,(LENGTH(TRIM(cNombreArchivo61)) - 1), 2)),5,'0'),''), --NUM BLOQUE
				NVL(SUBSTR(cFechaManana, 7, 2) || LPAD((SUBSTR(cNombreArchivo61,(LENGTH(TRIM(cNombreArchivo61)) - 1), 2)),5,'0'),''), --NUM BLOQUE
				NVL(LPAD((iContadorSecuencia61-1),7,'0'),''),--NUM_OPERACIONES -- REGISTROS EN EL DETALLE
				NVL(LPAD(iImporteTotalArchivo61,18,'0'),''),--IMPORTE TOTAL DE OPERACIONES
				NVL(cUsoFuturoCcenS,''),--USO_FUTURO_CCEN
				NVL(cUsoFuturoBancoS,''),--USO_FUTURO_BANCO
				cUsuario, --USUARIO_INSERT
				CURRENT::DATE --FECHA_INSERT
			);

		END IF;


		/*
		--IF (viContadorSecuencia62 > 1) THEN --VALIDA SI EXISTEN REGISTROS PARA EL ARCHIVO 62

			--FORMA EL REGISTRO DE ENCABEZADO
			--ENCABEZADO
			INSERT INTO BdiTef:"informix".Tef_Cce_Encabezado_Paso
			(
				Nombre_Arch,
				Fecha_Presentacion,
				Tpo_Registro,
				Num_Secuencia,
				Cod_Operacion,
				Cve_Banco,
				Sentido,
				Servicio,
				Num_Bloque,
				Cod_Divisa,
				Cve_Rechazo_bl,
				Modalidad,
				Uso_Futuro_Ccen,
				Uso_Futuro_Banco,
				User_Insert,
				Fecha_Insert
			)
			VALUES
			(
				--cNombreArchivo61,
				--cFechaManana, -- FECHA PRESENTACION -- T+1
				NVL(cNombreArchivo62,'') ,
				NVL(cFechaManana,''),
				'01', --TIPO REGISTRO
				NVL(LPAD('1',7,'0'),''), --'0000001', --SECUENCIA
				--'61', --ARCHIVO
				'62', --ARCHIVO
				NVL(cCveBancoE,''), --BANCOPEL 137
				'E', --SENTIDO
				NVL(cServicioE,''), --SERVICIO
				--NVL(cNumBloqueE,''), --NUM BLOQUE
				--NVL(LPAD(DAY(cFechaManana),2,'0') || LPAD((SUBSTR(cNombreArchivo62,(LENGTH(TRIM(cNombreArchivo62)) - 1), 2)),5,'0'),''), --NUM BLOQUE
				NVL(SUBSTR(cFechaManana, 7, 2) || LPAD((SUBSTR(cNombreArchivo62,(LENGTH(TRIM(cNombreArchivo62)) - 1), 2)),5,'0'),''), --NUM BLOQUE
				NVL(cCodDivisaE,''), --DIVISA
				NVL(cCveRechazoBlE,''),--CVE_RECHAZO_BL
				NVL(cModalidadE,''),--MODALIDAD
				NVL(cUsoFuturoCcenE,''), --USO_FUTURO_CCEN
				NVL(cUsoFuturoBancoE,''),--USO_FUTURO_BANCO
				cUsuario,
				CURRENT::DATE
			);



			--FORMA EL REGISTRO DE SUMARIO
			--SUMARIO
			INSERT INTO BdiTef:"informix".Tef_Cce_Sumario_Paso
			(
				Nombre_Arch,
				Fecha_Presentacion,
				Tipo_Registro,
				Num_Secuencia,
				Cod_Operacion,
				Num_Bloque,
				Num_Operaciones,
				Imp_Operaciones,
				Uso_Futuro_ccen,
				Uso_Futuro_banco,
				User_Insert,
				Fecha_Insert
			)
			VALUES
			(
				NVL(cNombreArchivo62,''), --NOMBRE_ARCH
				NVL(cFechaManana,''), --FECHA_PRESENTACION
				'09', --TIPO_REGISTRO
				NVL(LPAD((viContadorSecuencia62+1),7,'0'),''), --SECUENCIA
				--'61', --COD_OPERACION
				'62', --COD_OPERACION
				--NVL(cNum_BloqueS,''),--NUM BLOQUE
				--NVL(LPAD(DAY(cFechaManana),2,'0') || LPAD((SUBSTR(cNombreArchivo62,(LENGTH(TRIM(cNombreArchivo62)) - 1), 2)),5,'0'),''), --NUM BLOQUE
				NVL(SUBSTR(cFechaManana, 7, 2) || LPAD((SUBSTR(cNombreArchivo62,(LENGTH(TRIM(cNombreArchivo62)) - 1), 2)),5,'0'),''), --NUM BLOQUE
				NVL(LPAD((viContadorSecuencia62-1),7,'0'),''),--NUM_OPERACIONES -- REGISTROS EN EL DETALLE
				NVL(LPAD(viImporteTotalArchivo62,18,'0'),''),--IMPORTE TOTAL DE OPERACIONES
				NVL(cUsoFuturoCcenS,''),--USO_FUTURO_CCEN
				NVL(cUsoFuturoBancoS,''),--USO_FUTURO_BANCO
				cUsuario, --USUARIO_INSERT
				CURRENT::DATE --FECHA_INSERT
			);

		--END IF;
		*/


		LET cCodRet = '00000';

	END IF;
	
	RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCESA  LOS DATOS DE LAS CUENTAS DEL ARCHIVO 60.',
'Fecha: 2011/04/25',
'Version: 20110425.1450',
'BD: BdiTef',
'',
'Modificado: Casanova Edeza HÃÂÃÂ©ctor Juan',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: MODIFICADO A PETICION DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN.',
'Fecha: 2011/09/29',
'Version: 20110929.1800',
'BD: BdiTef',
'Modificado: Victor Hugo NuÃÂÃÂ±ez',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Javier Vazquez',
'Descripcion: Se elimina la generacion del archivo 62 y los abonos a cuenta.',
'Fecha: 27/04/2012',
'Version: 20120427.1340',
'Modificado: Victor Hugo NuÃÂÃÂ±ez',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Javier Vazquez',
'Descripcion: Se habilita la generacion del archivo 61',
'Fecha: 27/04/2012',
'Version: 20120427.1340',
'Modificado: Victor Hugo NuÃÂÃÂ±ez',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Javier Vazquez',
'Descripcion: Se habilita la generacion del archivo 61',
'Fecha: 27/04/2012',
'',
'Modificado: FRG',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Javier Vazquez',
'Descripcion: Se actualiza el valor del campo "cve_status" a "02"',
'		para los rechazos de registros del archivo Cod. 60', 
'Fecha: 06/08/2012',
'Version: 20120806.1644',
'',
'Modificado: Francisco Eduardo Benitez Baez',
'Proyecto: NÃÂÃÂºmero mÃÂÃÂ³vil en transferencias TEF',
'Solicito: MartÃÂÃÂ­n Pineda',
'Descripcion: Se agrega nuevo procedimiento de busqueda de telefono',
'		y se valida en caso de que no haya despliega mensaje', 
'Fecha: 22/09/2014',
'Version: 20140922.1654';

CREATE PROCEDURE "informix".cons_dev_suc_web2(pempresa CHAR(3), psucursal CHAR(4), pfechapre DATE, pnum_regs SMALLINT)
	RETURNING CHAR(5), CHAR(45), CHAR(20), CHAR(11), CHAR(16), CHAR(20), CHAR(100), CHAR(50), CHAR(13);


   DEFINE v_codret      CHAR(5);
   DEFINE v_banco		CHAR(45);
   DEFINE v_cuenta      CHAR(20);
   DEFINE v_numcheque   CHAR(11);
   DEFINE v_monto       CHAR(16);
   DEFINE v_ctadeposito CHAR(20);
   DEFINE v_cliente     CHAR(20);
   DEFINE v_motdevol    CHAR(50);
   DEFINE v_contador    SMALLINT;
   DEFINE v_nombrecte   CHAR(100);
   DEFINE v_rfc         CHAR(1);
   DEFINE v_curp  		CHAR(1);
   DEFINE sql_err,isam_err  INT; 

   DEFINE v_codret2 CHAR(5);
   DEFINE vtel1   CHAR(13);
   DEFINE vtel2   CHAR(13);   


  --SET debug file to "cons_suc.out";
  --trace on;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "00000";
   LET v_codret2    = "00001";


BEGIN
   ON EXCEPTION SET sql_err,isam_err
       IF sql_err <> 0 or isam_err <> 0 THEN
			LET v_codret = sql_err;
			RETURN  v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_ctadeposito, v_cliente || ' ' || v_nombrecte, v_motdevol, vtel1;
       END IF;
   END EXCEPTION;


-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

	IF  pempresa is null or
	 	psucursal is null or
		pnum_regs is null then
	
		   -- datos de entrada incompletos	   
		LET v_codret = '00110'; 
		RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
			v_monto,v_ctadeposito,
			v_cliente || ' ' || v_nombrecte,
			v_motdevol, vtel1;
	END IF;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
    
        LET v_banco       = " ";
        LET v_cuenta      = " ";
        LET v_numcheque   = " ";        
        LET v_monto       = 0;
        LET v_ctadeposito = " ";        
        LET v_motdevol    = " ";
        LET v_contador    = 0;


-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

	FOREACH

		-- consulta principal
		
		SELECT 	c.cvebanco || ' ' || b.descripcion,c.numcuenta, c.numcheque,c.numcte,c.cta_deposito,c.monto, c.motivo || ' ' || dev.descripcion
			INTO	v_banco,v_cuenta,v_numcheque,v_cliente, v_ctadeposito,v_monto,v_motdevol
		FROM	cce_cheques_dev c, bdinteg:si_bancos b,
			bdinteg:si_coddevcam dev
		WHERE	c.empresa = pempresa
			and c.fechapresenta = pfechapre
			and c.sucursal = psucursal	
			and c.cvebanco = b.banco
			and c.motivo = dev.codigo

		-- obtener el nombre o razon social del cliente
		
		call consnomcte(pempresa,v_cliente)
              		returning v_codret,v_nombrecte,v_rfc,v_curp;	

--------------------------------------------------------------------------------------------------------------------------					
		-- obtener el telefono del cliente

		call cons_tels_web(v_cliente)
              		returning v_codret2,vtel1,vtel2;
--------------------------------------------------------------------------------------------------------------------------			

		LET v_contador = v_contador +1;
        
        IF v_codret = '000' then
        LET v_codret = '00000';
        END IF;  

        IF v_codret = '800' then
        LET v_codret = '00001';
        END IF;     

		IF v_contador < pnum_regs then
			CONTINUE FOREACH;
		END IF;    


		RETURN  v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_ctadeposito, trim(v_cliente) || ' ' || v_nombrecte, v_motdevol, vtel1
			WITH resume;

	END FOREACH		

	IF v_contador = 0 THEN
		
		LET v_codret = '00001';
		LET v_banco  = " ";
        LET v_cuenta = " ";
        LET v_numcheque = " ";        
        LET v_monto  = 0;
        LET v_ctadeposito = " ";        
        LET v_cliente = " ";
		LET v_nombrecte = "";
        LET v_motdevol = 0;
		LET vtel1 = " ";
		
		RETURN v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_ctadeposito, trim(v_cliente) || ' ' || v_nombrecte, v_motdevol, vtel1 WITH resume;		
	END IF;
	
END;    
END PROCEDURE;