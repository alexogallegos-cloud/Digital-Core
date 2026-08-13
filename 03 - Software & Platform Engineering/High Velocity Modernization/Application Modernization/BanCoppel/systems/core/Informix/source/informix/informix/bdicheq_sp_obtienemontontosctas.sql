CREATE PROCEDURE "informix".sp_obtienemontontosctas (pEmpresa CHAR(3),	pCuenta CHAR(20),pTipoConsulta CHAR(1))
RETURNING  CHAR(5),VARCHAR(63),VARCHAR(63),VARCHAR(63);

DEFINE cCodRet 			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE iBandera			INTEGER;
DEFINE cAperturacta		VARCHAR(63);
DEFINE cMantenercta		VARCHAR(63);
DEFINE cMensual			VARCHAR(63);
DEFINE cDepositos		VARCHAR(63);
DEFINE cMontodeposito	VARCHAR(63);
DEFINE cRetiros			VARCHAR(63);
DEFINE cMontoretiro		VARCHAR(63);
DEFINE cNoAplica		VARCHAR(63);

LET cCodRet 			 = '00000';
LET iSqlErr				 = 0;
LET iBandera			 = 0;
LET cAperturacta		 = '';
LET cMantenercta		 = '';
LET cMensual			 = '';
LET cDepositos		 	 = '';
LET cMontodeposito	 	 = '';
LET cRetiros			 = '';
LET cMontoretiro		 = '';
LET cNoAplica		 	 = '';


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet,cAperturacta,cMantenercta,cMensual;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/Antonio/sp_ObtieneMontontosCtAS.out";
	--TRACE ON;

	set isolation to dirty read;

	IF pEmpresa = '' OR pCuenta = '' OR pTipoConsulta = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet,cAperturacta,cMantenercta,cMensual;
	END IF;

	IF pTipoConsulta = 'A' THEN

	  	SELECT  1,
				TRIM(d.proced_aperturacta)||' '|| TRIM(n.descripcion) AS aperturacta ,
				TRIM(d.proced_mantenercta)||' '||(n.descripcion) AS mantenercta,
				TRIM(d.monto_mensual)||' '||TRIM(k.descripcion) AS mensual
		INTO iBandera,cAperturacta,cMantenercta,cMensual
	    FROM  bdicheq:sc_maechq d, bdinteg:si_tipo_procedencia n, bdinteg:si_tipo_montomes k
		WHERE d.empresa = pEmpresa
			AND d.cuenta = pCuenta
			AND d.proced_aperturacta=n.procedencia
			AND d.proced_mantenercta=n.procedencia
			AND k.codigo=d.monto_mensual;

		IF iBandera = 0 THEN
			LET cCodRet = '00002';
		END IF;

		RETURN cCodRet,cAperturacta,cMantenercta,cMensual;

	END IF;

	IF pTipoConsulta = 'D' THEN

		SELECT {+INDEX(sc_maechq idx_maechq1), +INDEX(bdinteg:si_tipo_nummov idx_nummov), +INDEX(bdinteg:si_tipo_montomov idx_montomov)} 1,
				TRIM(m.depositos_cantidad)||' '||TRIM(t.descripcion) AS depositos,
				TRIM(m.depositos_monto)||' '||TRIM(r.descripcion)AS montodeposito,
				''
		INTO iBandera,cDepositos,cMontodeposito,cNoAplica
	    FROM bdicheq:sc_maechq m, bdinteg:si_tipo_nummov t, bdinteg:si_tipo_montomov r
	    WHERE m.empresa = pEmpresa
			AND m.cuenta = pCuenta
			AND m.depositos_cantidad = t.codnummo
			AND m.depositos_monto = r.codnummonto;

		IF iBandera = 0 THEN
			LET cCodRet = '00003';
		END IF;

		RETURN cCodRet,cDepositos,cMontodeposito,cNoAplica;

	END IF;

	IF pTipoConsulta = 'R' THEN

		SELECT  {+INDEX(sc_maechq idx_maechq1), +INDEX(bdinteg:si_tipo_nummov idx_nummov), +INDEX(bdinteg:si_tipo_montomov idx_montomov)} 1,
				TRIM(m.retiros_cantidad)||' '||TRIM(t.descripcion) AS retiros,
				TRIM(m.retiros_monto)||' '||TRIM(r.descripcion)AS montoretiro,
				''
		INTO iBandera,cRetiros,cMontoretiro,cNoAplica
		FROM bdicheq:sc_maechq m, bdinteg:si_tipo_nummov t, bdinteg:si_tipo_montomov r
		WHERE m.empresa = pEmpresa AND m.cuenta = pCuenta
			AND m.retiros_cantidad = t.codnummo
			AND m.retiros_monto = r.codnummonto;

		IF iBandera = 0 THEN
			LET cCodRet = '00004';
		END IF;

		RETURN cCodRet,cRetiros,cMontoretiro,cNoAplica;

	END IF;
END
END PROCEDURE
Document
'DESCRIPCION: Procedimiento que consulta las descripciones apropiadas para la cuenta',
'AUTOR: Antonio Bastidas',
'FECHA: 06 de Enero de 2010',
'VERSION: 20090106.0935',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_altas_maenoc(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcodret_abono    CHAR(5);
    
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vcuenta          CHAR(20);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcomienza     = -1;
    LET ven_transacc  = 0;
    LET vcodret_abono = '';
    
    LET vsql         = '';
    LET vstmt        = '';
    LET vcuenta      = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_altas_maenoc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_altas_maenoc.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctassinmaenoc') THEN
        DROP TABLE "informix".ctassinmaenoc;
    END IF;
    
    CREATE RAW TABLE "informix".ctassinmaenoc
      (
        cuenta      char(20)    not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasinnoc ON "informix".ctassinmaenoc(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentas_sin_maenoc.unl DELIMITER ''","'' INSERT INTO ctassinmaenoc" > /resplogifx/conciliachq/ctassinnoc.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctassinnoc.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctassinmaenoc;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM ctassinmaenoc
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        IF EXISTS( SELECT cuenta FROM sc_maenoc WHERE empresa = pempresa AND cuenta = vcuenta ) THEN
            CONTINUE FOREACH;
        END IF;
        
        INSERT INTO sc_maenoc VALUES
        ( pempresa, vcuenta, "00", '1', '1', '001', ' ', '1', 0, 0, " ", 
          0, " ", " ", 0, 0, 0, 0, 0, 0, 0, 0, ' ', '05/03/2011', " ", " ", 0, 0, 'M', " ", 0, 0, 0, 0);
        
        LET vcontador2 = vcontador2 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta       = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;