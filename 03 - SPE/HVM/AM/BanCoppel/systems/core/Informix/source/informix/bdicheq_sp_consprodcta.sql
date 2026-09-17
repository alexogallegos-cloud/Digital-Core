CREATE PROCEDURE "informix".sp_consprodcta(pEmpresa CHAR(3), pNumCuenta CHAR(20), pTipo CHAR(1))

	--DATOS A REGRESAR--
	RETURNING CHAR(5) AS CodigoRetorno, 
			  CHAR(4) AS Producto;
			  
	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cProducto CHAR(4);
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr   = 0;
	LET cCodRet   = '00000';
	LET cProducto = '0';

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consprodcta.out";
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cProducto;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;

		IF(pEmpresa is NULL) OR (pNumCuenta IS NULL) OR (pTipo IS NULL) THEN
			RETURN "00001", 'Err';
		END IF;
		
		--Se obtiene el producto al que pertenece la cuenta
		
		IF pTipo = "1" THEN --Productos de Débito
		
			IF LENGTH(pNumCuenta) = 11 THEN
				SELECT producto INTO cProducto FROM bdicheq:"informix".sc_maechq WHERE cuenta = pNumCuenta;
			ELSE
				SELECT b.producto INTO cProducto FROM bdicheq:"informix".sc_tarjeta a, bdicheq:"informix".sc_maechq b
				WHERE a.num_tarjeta = pNumCuenta AND a.cuenta = b.cuenta;
			END IF;
			
		ELIF pTipo = "2" THEN --Productos de Inversión
		
			SELECT cod_instrum INTO cProducto FROM bdinvers:"informix".sv_maeinv WHERE cuenta = pNumCuenta;
			
		ELIF pTipo = "3" THEN --Productos de Crédito Bancoppel
		
			SELECT b.num_producto INTO cProducto FROM bdicred:"informix".sd_tarjeta a, bdicred:"informix".sd_maecred b
			WHERE a.num_tarjeta = pNumCuenta AND a.num_credito = b.num_credito;
			
		ELIF pTipo = "4" THEN --Producto de Crédito Coppel
		
			LET cProducto = "6500";
			
		END IF;

		
		RETURN cCodRet, cProducto;

	END
	
END PROCEDURE

DOCUMENT
'Conocer el tipo de producto al que pertenece la cuenta del cliente',
'Autor : Daniela Ramírez',
'FECHA : 22/05/2012',
'BD:     bdicheq';

CREATE PROCEDURE "informix".pasamovshistold1( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE info_err         CHAR(40);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha           DATE;
    DEFINE vdias            INTEGER;
    DEFINE vfecha2          CHAR(10);
    DEFINE vexiste          SMALLINT;
    DEFINE vexiste_fecha    SMALLINT;
    DEFINE vstatus_proc     CHAR(1);
    DEFINE vcuenta          CHAR(20);
    DEFINE veliminados      INTEGER;
    DEFINE vproceso         CHAR(20);
    DEFINE vsistema         CHAR(2);
    DEFINE vusuario         CHAR(8);
    DEFINE vsql             CHAR(600);
    DEFINE vstmt            CHAR(250);
    DEFINE vborrado         CHAR(1);
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET info_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET ven_transacc = 0; 
    
    LET vfecha_hoy    = '';
    LET vfecha        = ''; 
    LET vdias         = 0;
    LET vfecha2       = '';
    LET vexiste       = 0;
    LET vexiste_fecha = 0;
    LET vstatus_proc  = '';
    LET vcuenta       = ''; 
    LET veliminados   = 0;
    LET vproceso      = 'PasaMovsHistOld1';  
    LET vsistema      = '01';
    LET vusuario      = 'informix';
    LET vsql          = '';
    LET vstmt         = '';
    LET vborrado      = '0';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, info_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistold1.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = info_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistold1.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // OBTIENE LA FECHA DE LOS MOVIMIENTOS A TRASPASAR
    SELECT valor 
      INTO vfecha
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'PasoMovhis_MovhisOld';
       
    -- // VALIDA CUANTOS DIAS TIENE EL HISTORICO DE MOVIMIENTOS
    LET vdias = vfecha_hoy - vfecha;
    
    IF vdias <= 32 THEN
        LET vcodret1 = '111'; -- // EL HISTORICO NO TIENE MAS DE 31 DIAS
        LET vcodret2 = '111';
        RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
    END IF;
     
    -- // Guarda inicio de proceso     
    SELECT COUNT(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'PasaMovsHistOld1'
       AND fecha   = vfecha
       AND sistema = '01';

    IF vexiste = 0 THEN    
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''', '||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horaspasamovsold.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
        SYSTEM vstmt;
    ELSE
        SELECT status_proc
          INTO vstatus_proc
          FROM bdinteg:sx_contproc
         WHERE empresa = pempresa
           AND proceso = 'PasaMovsHistOld1'
           AND fecha   = vfecha
           AND sistema = '01';
           
        IF vstatus_proc = 'I' THEN
            LET vcodret1 = '953';
            LET vcodret2 = '953';
            RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
        ELIF vstatus_proc = 'F' THEN
            LET vcodret1 = '958';
            LET vcodret2 = '958';
            RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
        ELSE
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
            SYSTEM vsql;            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
            SYSTEM vstmt;
        END IF;
    END IF;
    
    -- // OBTIENE NUMERO DE REGISTROS A TRASPASAR
    SELECT COUNT(*)
      INTO vexiste_fecha
      FROM sc_trasp_movhis_movhisold
     WHERE fecha = vfecha;
     
    IF vexiste_fecha = 0 THEN
        SELECT {+INDEX(sc_movhis idx_movhisnew6)} 
               COUNT(*)
          INTO vcontador1
          FROM sc_movhis
         WHERE fech_alt = vfecha; 
         
        INSERT INTO sc_trasp_movhis_movhisold(fecha, no_regs)
        VALUES(vfecha, vcontador1);
    ELSE
        SELECT no_regs
          INTO vcontador1
          FROM sc_trasp_movhis_movhisold
         WHERE fecha = vfecha;
    END IF;
       
    -- // TRASPASA MOVIMIENTOS 
    FOREACH WITH HOLD 
        SELECT {+INDEX(sc_movhis idx_movhisnew6)} 
               UNIQUE cuenta
          INTO vcuenta
          FROM sc_movhis
         WHERE fech_alt = vfecha
           AND producto NOT IN('1200','1600','9900','9901')
           
        BEGIN WORK;
        LET ven_transacc = 1; 
        
        INSERT INTO sc_movhis_old
        SELECT {+INDEX(sc_movhis idx_movhisnew1)} 
               mov.*
          FROM sc_movhis mov
         WHERE mov.empresa = pempresa
           AND mov.cuenta = vcuenta
           AND mov.fech_alt = vfecha;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            DELETE {+INDEX(sc_movhis idx_movhisnew1)} 
              FROM sc_movhis
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND fech_alt = vfecha;
               
            IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                COMMIT WORK;
                LET ven_transacc = 0; 
            ELSE
                ROLLBACK WORK;
                LET ven_transacc = 0; 
            END IF;
        ELSE
            ROLLBACK WORK;
            LET ven_transacc = 0; 
        END IF;
    END FOREACH;
    
    -- // TRASPASA MOVIMIENTOS 
    FOREACH WITH HOLD 
        SELECT {+INDEX(sc_movhis idx_movhisnew6)} 
               UNIQUE cuenta
          INTO vcuenta
          FROM sc_movhis
         WHERE fech_alt = vfecha
           
        BEGIN WORK;
        LET ven_transacc = 1; 
           
        INSERT INTO sc_movhis_old
        SELECT {+INDEX(sc_movhis idx_movhisnew1)} 
               mov.*
          FROM sc_movhis mov
         WHERE mov.empresa = pempresa
           AND mov.cuenta = vcuenta
           AND mov.fech_alt = vfecha;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            DELETE {+INDEX(sc_movhis idx_movhisnew1)}
              FROM sc_movhis
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND fech_alt = vfecha;
               
            IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                COMMIT WORK;
                LET ven_transacc = 0; 
            ELSE
                ROLLBACK WORK;
                LET ven_transacc = 0; 
            END IF;
        ELSE
            ROLLBACK WORK;
            LET ven_transacc = 0; 
        END IF;
    END FOREACH;
    
    -- // NUMERO DE REGISTROS TRASPASADOS
    SELECT {+INDEX(sc_movhis_old idx_movhisnew6_old)} 
           COUNT(*)
      INTO vcontador2
      FROM sc_movhis_old
     WHERE fech_alt = vfecha; 
     
    SELECT {+INDEX(sc_movhis idx_movhisnew6)} 
           COUNT(*)
      INTO vcontador3
      FROM sc_movhis
     WHERE fech_alt = vfecha; 
         
    -- // ACTUALIZA PARAMETROS FINALES
    IF vcontador1 = vcontador2 THEN
        LET vfecha2 = to_char(vfecha + 1 UNITS DAY, '%m/%d/%Y');
    
        UPDATE sc_param
           SET valor = vfecha2
         WHERE empresa = pempresa
           AND codparam = 'fechcon_movhis';
           
        UPDATE sc_param
           SET valor = vfecha2
         WHERE empresa = pempresa
           AND codparam = 'PasoMovhis_MovhisOld';
           
        LET vcodret1 = '000'; -- // PROCESO CONCLUIDO SATISFACTORIAMENTE
        LET vcodret2 = '000';
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET status_proc   = '''||'F'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
        SYSTEM vstmt;
    ELSE
        LET vcodret1 = '999'; -- // LOS MOVIMIENTOS TRASPASADOS NO COINCIDEN CON LOS MOVIMIENTOS A TRASAPASAR
        LET vcodret2 = '999';
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
        SYSTEM vstmt;
    END IF;
       
    END;
    
    RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
    
END PROCEDURE;