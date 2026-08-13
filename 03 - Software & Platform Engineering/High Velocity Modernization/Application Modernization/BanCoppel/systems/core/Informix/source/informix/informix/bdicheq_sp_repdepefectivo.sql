CREATE PROCEDURE "informix".sp_repdepefectivo( pEmpresa VARCHAR(3))
RETURNING VARCHAR(5);

    DEFINE cCodRet1     VARCHAR(5);
    DEFINE cCodRet2     VARCHAR(5);
    DEFINE cCodRet3     VARCHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE iDesErr      VARCHAR(50);
    DEFINE iTransacc    SMALLINT;
    DEFINE vsql         LVARCHAR(1200);
    DEFINE vstmt        VARCHAR(250);
    DEFINE vfecha       VARCHAR(8);
    DEFINE vfecha_ant   DATE;
    DEFINE v_ctenombre1 VARCHAR(26);
    DEFINE v_ctenombre2 VARCHAR(26);
    DEFINE v_cteapepat  VARCHAR(26);
    DEFINE v_cteapemat  VARCHAR(26);
    DEFINE v_fech_alt   DATE;
    DEFINE v_cuenta     VARCHAR(20);
    DEFINE v_monto_tot  MONEY(14,2);
    DEFINE v_sucursal   VARCHAR(04);
    DEFINE v_num_cte    VARCHAR(20);
    DEFINE v_monto      MONEY(14,2);
	DEFINE vContador    INTEGER;
	DEFINE vContador1   INTEGER;
	DEFINE vComienza    SMALLINT;
    DEFINE vEnTransacc  SMALLINT;
    DEFINE vComienza1   SMALLINT;
    DEFINE vEnTransacc1 SMALLINT;
	DEFINE v_fechamin   DATE;
	DEFINE v_fechamax   DATE;

    --Inicializacion de variables
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr      = 0;
    LET iSamErr      = 0;
    LET iDesErr      = 0;
    LET iTransacc    = 0;
    LET vsql         = '';
    LET vstmt        = '';
    LET vfecha       = '';
    LET vfecha_ant   = '';
    LET v_ctenombre1 = '';
    LET v_ctenombre2 = '';
    LET v_cteapepat  = '';
    LET v_cteapemat  = '';
    LET v_fech_alt   = '';
    LET v_cuenta     = '';
    LET v_monto_tot  = 0;
    LET v_sucursal   = '';
    LET v_num_cte    = '';
    LET v_monto      = 0;
	LET vContador    = 0;
	LET vContador1   = 0;
	
	LET vComienza     = -1;
    LET vEnTransacc   = 0;
    LET vComienza1    = -1;
    LET vEnTransacc1  = 0;
	LET v_fechamin    = '';
	LET v_fechamax    = '';

    BEGIN

       ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
           IF iSqlErr <> 0 THEN
              LET cCodRet1 = iSqlErr;
              LET cCodRet2 = iSamErr;
              LET cCodRet3 = iDesErr;
			  
			  SET DEBUG FILE TO "/resplogifx/conciliachq/sp_repdepefectivo.err";
              TRACE ON;

              IF iTransacc = 1 THEN
                 ROLLBACK WORK;
              END IF;
              RETURN cCodRet1;
           END IF;
       END EXCEPTION;

       SET ISOLATION TO DIRTY READ;
       SET LOCK MODE TO WAIT 3;

	 --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_repdepefectivo.out';
     --TRACE ON; 


	   -- // OBTIENE LA FECHA DEL SISTEMA EN BASE A LA EMPRESA
       SELECT fecha_ant
	   INTO vfecha_ant
	   FROM bdicheq:sc_fechas
       WHERE empresa = pempresa;

       LET vfecha = TO_CHAR(vfecha_ant, '%d%m%Y');

        -- // DESCARGA ARCHIVO DE MOVIMIENTOS DIARIOS DE DEPOSITOS EN EFECTIVO
       IF EXISTS(SELECT dbsname, tabname
                    FROM sysmaster:systabnames
                    WHERE partnum > 0
	                AND tabname = 'paso_movi') THEN

         TRUNCATE TABLE bdicheq:paso_movi;
       ELSE
          CREATE TABLE bdicheq:paso_movi (fech_alt  DATE,
                                          cuenta    VARCHAR(20),
                                          monto_tot MONEY(14,2),
                                          sucursal  VARCHAR(04)) in dbs_movhisold08;
								  
          CREATE INDEX idx_pasomov_cuenta ON bdicheq:paso_movi (cuenta) in idx_info06 ONLINE;
       END IF;
	   
       FOREACH cur_ini WITH HOLD FOR
          SELECT mov.fech_alt, mov.cuenta, mov.monto_tot, mov.sucursal
          INTO   v_fech_alt, v_cuenta, v_monto_tot, v_sucursal
          FROM  bdicheq:sc_movhis mov
          WHERE mov.fech_alt = vfecha_ant
          AND mov.transacc IN ("0202","0325","0282","0318","0482","0491")
          AND mov.cancelad <> "S"
		  
		  IF (vComienza = -1) THEN
             LET vComienza = 0;
             LET vEnTransacc = 1;
             BEGIN WORK;
          END IF;

          INSERT INTO bdicheq:paso_movi (fech_alt, cuenta, monto_tot, sucursal)
                         VALUES (v_fech_alt,v_cuenta,v_monto_tot,v_sucursal);
		  
		  LET vContador = vContador + 1;
            
          IF vContador >= 1000 THEN
             LET vContador = 0;
             COMMIT WORK;
             BEGIN WORK;
          END IF;

       END FOREACH
	   
	  IF (vEnTransacc = 1) THEN
         LET vEnTransacc = 0;
         COMMIT WORK;
      END IF;

       LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                  'UNLOAD TO /resplogifx/conciliachq/depositos_efectivo_diario_'||vfecha||'.txt '||
                  'SELECT mov.fech_alt, trim(mae.num_cte), trim(mov.cuenta), '||
	              'nvl(trim(cte.nombre1),'''')||'' ''||nvl(trim(cte.nombre2),'''')||'' ''||nvl(trim(cte.apell_paterno),'''')||'' ''||nvl(trim(cte.apell_materno),''''), '||
	              'mov.monto_tot, mov.sucursal '||
                  'FROM paso_movi mov, '||
	              'bdicheq:sc_maechq mae, '||
	              'bdinteg:si_cliente cte, '||
	              'bdinteg:si_tipper tip '||
                  'WHERE mov.cuenta = mae.cuenta '||
	              'AND cte.numcte = mae.num_cte '||
	              'AND tip.tpo_persona = cte.tpo_persona '||
	              'AND tip.es_fisica = ''"S"'';" > /resplogifx/conciliachq/depefecdia.sql';
        SYSTEM vsql;

        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/depefecdia.sql";
        SYSTEM vstmt;

        -- // DESCARGA ARCHIVO DE MOVIMIENTOS DIARIOS ACUMULDOS DE DEPOSITOS EN EFECTIVO
        
		IF EXISTS(SELECT dbsname, tabname
                    FROM sysmaster:systabnames
                    WHERE partnum > 0
	                AND tabname = 'paso_movi1') THEN

            TRUNCATE TABLE bdicheq:paso_movi1;
		ELSE
           CREATE TABLE bdicheq:paso_movi1 (num_cte VARCHAR(20),
                                    monto   MONEY(14,2)) in dbs_movhisold08;
									
           CREATE INDEX idx_pasomov_cte ON bdicheq:paso_movi1 (num_cte) in idx_info06 ONLINE;
		END IF;

	    --REALIZAR DESDE QUE LA FECHA MININA HASTA LA FECHA MAXIMA
		SELECT MIN(mov.fecha), MAX(mov.fecha)
	    INTO v_fechamin, v_fechamax
        FROM bdicheq:sc_depositosefectivo mov;
		      
		WHILE v_fechamin <= vfecha_ant
		   
		   FOREACH cur_dos WITH HOLD FOR
		      SELECT mov.num_cte, mov.monto
	          INTO   v_num_cte, v_monto
	          FROM   bdicheq:sc_depositosefectivo mov
	          WHERE  mov.fecha = v_fechamin
              AND    mov.transacc IN ("0202","0325","0282","0318","0482","0491")
		   
		      IF (vComienza1 = -1) THEN
                 LET vComienza1 = 0;
                 LET vEnTransacc1 = 1;
                 BEGIN WORK;
              END IF;
		  
	          INSERT INTO bdicheq:paso_movi1 (num_cte, monto)
	                                  VALUES (v_num_cte, v_monto);
						  
		      LET vContador1 = vContador1 + 1;
            
              IF vContador1 >= 1000 THEN
                 LET vContador1 = 0;
                 COMMIT WORK;
                 BEGIN WORK;
              END IF;
           
		   END FOREACH;
        
		   LET v_fechamin = v_fechamin + 1;
		END WHILE;
		
        IF (vEnTransacc1 = 1) THEN
           LET vEnTransacc1 = 0;
           COMMIT WORK;
        END IF;

        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                   'UNLOAD TO /resplogifx/conciliachq/depositos_efectivo_acumulado_'||vfecha||'.txt '||
                   'SELECT  trim(mov.num_cte), '||
	               'nvl(trim(cte.nombre1),'''')||'' ''||nvl(trim(cte.nombre2),'''')||'' ''||nvl(trim(cte.apell_paterno),'''')||'' ''||nvl(trim(cte.apell_materno),''''), '||
	               'SUM(mov.monto) '||
                   'FROM bdicheq:paso_movi1 mov, '||
		           'bdinteg:si_cliente cte '||
                   'WHERE mov.num_cte = cte.numcte '||
		           'GROUP BY 1, 2;" > /resplogifx/conciliachq/depefecacum.sql';
        SYSTEM vsql;

        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/depefecacum.sql";
        SYSTEM vstmt;
		
		LET vsql = '';
        LET vsql = 'rm /resplogifx/conciliachq/depefecacum.sql';
        SYSTEM vsql;
        LET vsql = '';
		
		LET vsql = '';
        LET vsql = 'rm /resplogifx/conciliachq/depefecdia.sql';
        SYSTEM vsql;
        LET vsql = '';
	END;

    RETURN cCodRet1;

END PROCEDURE;