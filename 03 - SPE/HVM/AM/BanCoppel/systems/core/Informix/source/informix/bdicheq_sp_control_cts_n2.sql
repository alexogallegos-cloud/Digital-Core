CREATE PROCEDURE "informix".sp_control_cts_n2()
RETURNING CHAR(5);

    DEFINE vcodret1                         CHAR(5);
    DEFINE vcodret2                         CHAR(5);
    DEFINE vcodret3                         CHAR(50);
    DEFINE sql_err                          INTEGER;
    DEFINE isam_err                         INTEGER;
    DEFINE desc_err                         CHAR(50);
    DEFINE vfec_alta_cuenta                 CHAR(10);
    DEFINE vnum_cte                         CHAR(20);
    DEFINE vtipo_cliente                    CHAR(10);
    DEFINE vfec_alta_cliente                CHAR(10);
    DEFINE vsql                             CHAR(400);
    DEFINE vstmt                            CHAR(200);
    DEFINE vcontador                        INTEGER;
    DEFINE vacumulado                       INTEGER;
    DEFINE vsdo_dia_ant                     MONEY (18,2);
    DEFINE vsaldo_actual                    MONEY (18,2);
    DEFINE vfecha_ant                       DATE;
    DEFINE vfecha_antier                    DATE;
    DEFINE vfechades                        CHAR(8);
    DEFINE vdia                             CHAR(2);
    DEFINE vmes                             CHAR(2);
    DEFINE vanio                            CHAR(4);
    DEFINE valt_ctes_nuevos_dia             SMALLINT;
    DEFINE valt_ctes_exist_dia              SMALLINT;
    DEFINE valtas_del_dia                   SMALLINT;
    DEFINE vsaldo_dia                       MONEY (18,2);
    DEFINE vacum_ctes_exist                 INTEGER;
    DEFINE vacum_ctes_nuevo                 INTEGER;
    DEFINE vacum_altas                      INTEGER;
    DEFINE vmonto_acum                      MONEY (18,2);
	DEFINE vfech_proc                       DATE;
	DEFINE vExiTable                        INTEGER;
	
	
    LET vcodret1                             = '00000';
    LET vcodret2                             = '000';
    LET vcodret3                             = '';
    LET sql_err                              = 0;
    LET isam_err                             = 0;
    LET desc_err                             = '';
    LET vfec_alta_cuenta                     = '';
    LET vnum_cte                             = '';
    LET vtipo_cliente                        = '';
    LET vfec_alta_cliente                    = '';
    LET vacumulado                           = 0;
    LET vsdo_dia_ant                         = 0.00;
    LET vsaldo_actual                        = 0.00;
    LET vfecha_antier                        = '';
    LET vfecha_ant                           = '';
    LET vstmt                                = '';
    LET vsql                          	     = '';
    LET vcontador                            = 0;
    LET vfechades                            = '';
    LET vdia                                 = '';
    LET vmes                                 = '';
    LET vanio                                = '';
    LET valt_ctes_nuevos_dia                 = '';
    LET valt_ctes_exist_dia                  = '';
    LET vsaldo_dia                           = 0.00;
    LET vacum_ctes_exist                     = '';
    LET vacum_ctes_nuevo                     = '';
    LET vacum_altas                          = '';
    LET vmonto_acum                          = 0.00;
    LET valtas_del_dia                       = '';
	LET vfech_proc                           = TODAY-1;
	LET vExiTable                            = 0;
	
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_control_cts_n2.err";
        TRACE ON;
        IF  sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/informix/rsv/n2/sp_control_cts_n2.out';
    --TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(*)
	INTO   vExiTable
	FROM   sysmaster:systabnames 
	WHERE  partnum > 0 AND tabname = 'altas_cuenta_n2';
	
	IF  vExiTable = 1 THEN 
	    TRUNCATE TABLE altas_cuenta_n2; 
	END IF; 
	 	
    SELECT fecha_ant 
	INTO   vfecha_ant
    FROM   bdicheq:sc_fechas;
		
    FOREACH WITH HOLD
            SELECT a.num_cte, b.fecha_alta,     d.fecha_insert,    a.sdo_dia_ant
            INTO   vnum_cte,  vfec_alta_cuenta, vfec_alta_cliente, vsdo_dia_ant
            FROM   bdicheq:sc_maenoc b,
                   bdicheq:sc_maechq a,
                   bdinteg:si_cliente d,
                   bdicheq:sc_fechas c
            WHERE  b.cuenta = a.cuenta
            AND    a.num_cte = d.numcte
            AND    a.producto="2900"
            AND    a.status_cta <> '2'
            AND    c.fecha_ant = b.fecha_alta        
            
            IF  vfec_alta_cliente = vfecha_ant THEN
                LET vtipo_cliente = 'NUEVO';	
            ELSE
                LET vtipo_cliente = 'EXISTENTE';
            END IF;
	        
			--DETALLE DE LOS CLIENTES CON PRODUCTO 2900
            INSERT INTO altas_cuenta_n2 VALUES(vnum_cte, vfec_alta_cliente, vfec_alta_cuenta, vtipo_cliente, vsdo_dia_ant,vfech_proc);
    END FOREACH;

    -- ACUMULADO DE CLIENTES NUEVOS DEL DIA ANTERIOR 
    SELECT COUNT(*) 
    INTO   valt_ctes_nuevos_dia
    FROM   altas_cuenta_n2
    WHERE  tipo_cte = "NUEVO"
	AND    fech_pro = vfech_proc;

	-- ACUMULADO DE CLIENTES EXISTENTES DEL DIA ANTERIOR
    SELECT COUNT(*) 
    INTO   valt_ctes_exist_dia
    FROM   altas_cuenta_n2
    WHERE  tipo_cte = "EXISTENTE"
	AND    fech_pro = vfech_proc;
	 
	-- TOTAL DE ALTAS DEL DIA Y TOTAL DE SALDO DEL DIA 
    SELECT COUNT (*), NVL(sum(saldos), 0)  
    INTO   valtas_del_dia, vsaldo_dia
    FROM   altas_cuenta_n2
	WHERE  fech_pro = vfech_proc;
		
  	
	-- SE ACTUALIZA VALORES ACUMULADOS Y POR DIA. 
	UPDATE control_altas_cta_n2
	SET    alt_ctes_nuevos_dia = valt_ctes_nuevos_dia,
	       alt_ctes_exist_dia  = valt_ctes_exist_dia,
		   altas_del_dia       = valtas_del_dia,
		   saldo_dia           = vsaldo_dia,
		   acum_ctes_exist     = acum_ctes_exist     + valt_ctes_exist_dia,
		   acum_ctes_nuevo     = acum_ctes_nuevo     + valt_ctes_nuevos_dia,
		   acum_altas          = acum_altas          + valtas_del_dia,
		   monto_acum          = monto_acum          + vsaldo_dia
    WHERE  monto_acum > 0; 
	
	LET vfecha_ant = vfecha_ant;
    LET vdia  = SUBSTR(vfecha_ant, 4, 2);
    LET vmes  = SUBSTR(vfecha_ant, 1, 2);
    LET vanio = SUBSTR(vfecha_ant, 7, 4);
    LET vdia  = TRIM(vdia);
    LET vmes  = TRIM(vmes);
    LET vanio = TRIM(vanio);
    LET vfechades = vmes||vdia||vanio;

    LET vsql = 'echo "set isolation to dirty read; unload to /RESPALDOSNEW/altas_cuenta_n2_'||vfechades||'.txt '||
               'select num_cte, fecha_alta_cliente, fecha_alta_cuenta, tipo_cte, saldos FROM altas_cuenta_n2 WHERE fecha_alta_cuenta = ''' ||vfecha_ant||''' " >/RESPALDOSNEW/altas_cuenta_n2.sql';
    SYSTEM vsql;
    LET vsql = '';

    LET vstmt = "dbaccess bdicheq /RESPALDOSNEW/altas_cuenta_n2.sql";
    SYSTEM vstmt;
    LET vstmt = '';
	
	
    LET vsql = 'echo "set isolation to dirty read; unload to /RESPALDOSNEW/control_altas_cta_n2_'||vfechades||'.txt '||
               'select alt_ctes_nuevos_dia, alt_ctes_exist_dia, altas_del_dia, saldo_dia, acum_ctes_nuevo,acum_ctes_exist, acum_altas, monto_acum  FROM control_altas_cta_n2 "  >/RESPALDOSNEW/control_altas_cta_n2.sql';
    SYSTEM vsql;
    LET vsql = '';
	
    LET vstmt = "dbaccess bdicheq /RESPALDOSNEW/control_altas_cta_n2.sql";
    SYSTEM vstmt;
    LET vstmt = '';
	
    END;

    RETURN vcodret1;
END PROCEDURE;