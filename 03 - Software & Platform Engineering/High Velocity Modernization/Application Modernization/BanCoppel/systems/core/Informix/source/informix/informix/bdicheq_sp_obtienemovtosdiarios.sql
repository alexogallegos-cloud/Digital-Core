CREATE PROCEDURE "informix".sp_obtienemovtosdiarios( pEmpresa  CHAR(3),
                                                     pCuenta   CHAR(20),
                                                     pFechaIni DATE,
                                                     pFechaFin DATE)
RETURNING CHAR(6)      AS cCodRet,
          INTEGER      AS Serial,
		  DATE         AS FechaAlt,
		  VARCHAR(55)  AS Transsac,
		  CHAR(4)	   AS CodigoSucursal,
		  CHAR(40)	   AS NombreSucursal,
		  CHAR(40)     AS Referencia,
		  CHAR(16)     AS NumTarjeta,
		  MONEY(14,02) AS Monto, 
		  MONEY(14,02) AS SaldoCta,
		  CHAR(1)      AS Naturaleza;
		  
    DEFINE cCodRet             CHAR(6);
    DEFINE iSql_Err            INTEGER;
    DEFINE iSam_Err            INTEGER;
    DEFINE sNumSerial          INTEGER;
    DEFINE dFechaAlt           DATE;
    DEFINE vTransacc		   VARCHAR(55);
	DEFINE cCodSuc			   CHAR(4);
    DEFINE cSucursal		   CHAR(40);
	DEFINE cReferencia         CHAR(40);
    DEFINE cNumTarjeta		   CHAR(16);
    DEFINE mMonto			   MONEY(14,02);
    DEFINE mSaldoCta		   MONEY(14,02);
    DEFINE cNaturaleza 		   CHAR(1);
    DEFINE dFechaCierre        DATE;
    DEFINE iCont               INTEGER;
    DEFINE vfechaconmovhis     CHAR(10);
    DEFINE vfechaconmovhisold  CHAR(10);

    LET cCodRet      = '000000';
    LET iSql_Err     = '000000';
    LET iSam_Err     = '000000';
    LET sNumSerial   = 0;
    LET dFechaAlt    = '01-01-2000';
    LET vTransacc    = '';
	LET cCodSuc		 ='0000';
	LET cSucursal	 = '';	
    LET cReferencia  = '';
    LET cNumTarjeta  = ''; 
    LET mMonto       = 0; 
    LET mSaldoCta    = 0;
    LET cNaturaleza  = '';
    LET dFechaCierre = NULL;
    LET iCont        = 0;
    LET vfechaconmovhis = '';
    LET vfechaconmovhisold = '';

    SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;

    ---SET DEBUG FILE TO "/home/sysifx/vlv/sp_obtienemovtosdiarios.out";
    ---TRACE ON;

    BEGIN

    ON EXCEPTION SET iSql_Err, iSam_Err
        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet, sNumSerial ,dFechaAlt ,vTransacc ,cCodSuc ,cSucursal, cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza;
        END IF;
    END EXCEPTION;

    IF pEmpresa IS NULL OR pEmpresa = '' OR pCuenta IS NULL OR pCuenta = '' OR pFechaIni IS NULL OR pFechaIni = '' OR pFechaFin IS NULL OR pFechaFin = '' THEN
        LET cCodRet = '110';  --Faltan parametros para su ejecucion.
        RETURN cCodRet, sNumSerial ,dFechaAlt ,vTransacc ,cCodSuc ,cSucursal, cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza;
    END IF

    IF pFechaIni > pFechaFin THEN
        LET cCodRet = '120';  --Fecha inicio no deve ser mayor a fecha fin
        RETURN cCodRet, sNumSerial ,dFechaAlt ,vTransacc ,cCodSuc ,cSucursal ,cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza;
    END IF

    SELECT (fechafin + DAY(1))
      INTO dFechaCierre
      FROM bdicheq:"informix".sc_maehis 
     WHERE cuenta = pCuenta
       AND aniomes = (SELECT MAX(aniomes) FROM bdicheq:"informix".sc_maehis WHERE empresa = pEmpresa AND cuenta = pCuenta);

    IF dFechaCierre IS NOT NULL THEN
        LET pFechaIni = dFechaCierre;
    END IF
    
    SELECT valor
      INTO vfechaconmovhis
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO vfechaconmovhisold
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    FOREACH --- Se consultan los movimientos que se registraron en determienadas fechas de la cuenta.
        SELECT md.num_serial, md.fech_alt, TRIM(md.transacc)||' '||trim(tr.descripcion) transaccion, TRIM(md.sucursal), TRIM(suc.nombre) sucursal, 
               nvl(md.referencia,' ') referencia, nvl(md.num_tarjeta,' ') num_tarjeta, md.monto_tot, md.sdo_cuenta, tr.naturaleza  
          INTO sNumSerial ,dFechaAlt ,vTransacc ,cCodSuc ,cSucursal ,cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza
          FROM bdicheq:"informix".sc_movdia md,
               bdinteg:"informix".si_transacc tr,
			   bdinteg: "informix".si_sucursales suc	
         WHERE md.empresa = pEmpresa
           AND md.cuenta = pCuenta
           AND md.fech_alt BETWEEN pFechaIni AND pFechaFin
           AND md.cancelad NOT IN('S','V') 
           AND tr.empresa = md.empresa
           AND tr.numero = md.transacc
		   AND md.sucursal = suc.sucursal
           AND tr.se_emite_edocta = 'S' 
        UNION ALL 
        SELECT mm.num_serial, mm.fech_alt, TRIM(mm.transacc)||' '||trim(tr.descripcion),TRIM(mm.sucursal),TRIM(suc.nombre) sucursal, 
               nvl(mm.referencia,' '), nvl(mm.num_tarjeta,' '), mm.monto_tot, mm.sdo_cuenta, tr.naturaleza  
          FROM bdicheq:"informix".sc_movhis mm, 
               bdinteg:"informix".si_transacc tr,
			   bdinteg:"informix".si_sucursales suc
         WHERE mm.empresa = pEmpresa
           AND mm.cuenta = pCuenta
           AND mm.fech_alt >= vfechaconmovhis
           AND mm.fech_alt BETWEEN pFechaIni AND pFechaFin
           AND mm.cancelad NOT IN('S','V') 
           AND mm.transacc = tr.numero 
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc
		   AND mm.sucursal = suc.sucursal
           AND tr.se_emite_edocta = 'S'
        UNION ALL 
        SELECT mm.num_serial, mm.fech_alt, TRIM(mm.transacc)||' '||trim(tr.descripcion),TRIM(mm.sucursal),TRIM(suc.nombre) sucursal, 
               nvl(mm.referencia,' '), nvl(mm.num_tarjeta,' '), mm.monto_tot, mm.sdo_cuenta, tr.naturaleza  
          FROM bdicheq:"informix".sc_movhis_old mm, 
               bdinteg:"informix".si_transacc tr,
			   bdinteg:"informix".si_sucursales suc
         WHERE mm.empresa = pEmpresa
           AND mm.cuenta = pCuenta
           AND mm.fech_alt >= vfechaconmovhisold
           AND mm.fech_alt < vfechaconmovhis
           AND mm.fech_alt BETWEEN pFechaIni AND pFechaFin
           AND mm.cancelad NOT IN('S','V') 
           AND mm.transacc = tr.numero 
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc
		   AND mm.sucursal = suc.sucursal
           AND tr.se_emite_edocta = 'S'
         ORDER BY 2 DESC, 1 DESC		 

        LET iCont = 1;

        RETURN cCodRet, sNumSerial, dFechaAlt ,vTransacc,cCodSuc , cSucursal, cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza WITH RESUME;
    END FOREACH;

    IF iCont = 0 THEN
        LET cCodRet = '000002'; -- No se encuentran registros.
        RETURN cCodRet, sNumSerial ,dFechaAlt ,vTransacc ,cCodSuc ,cSucursal ,cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza;
    END IF;

    END;
    
END PROCEDURE

DOCUMENT
'MODIFICO: Valentin Lopez Valenzuela',
'FECHA: 07 de Julio del 2011',
'DESCRIPCION: Consulta los movimientos de las cuentas en un rango de fechas determinado.',
'VERSION: 20110707.1146',
'BD: BDICHEQ',
'MODIFICO: Armando Morales',
'FECHA: 30 de Enero del 2012',
'DESCRIPCION: Se agrega consulta de sucursales y numero de sucursal',
'VERSION: 20120130.1146',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".reversa_pos_dup()

  RETURNING CHAR(5), INTEGER;

    -- // DECLARACION DE VARIABLES

    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vcontador		INTEGER;
    DEFINE vcuantos  		INTEGER;

    DEFINE vcuenta		    CHAR(20);
	DEFINE vfolio_suc       CHAR(16);
	DEFINE vimporte         MONEY(14,2);
	DEFINE vsdo_actual      MONEY(14,2);
	DEFINE vimp_chq_sbg     MONEY(14,2);
	DEFINE vsaldo           MONEY(14,2);
	DEFINE vsbg             MONEY(14,2);
	
        -- // INICIALIZACION DE VARIABLES

    LET vcodret	  = "000";
    LET sql_err	  = 0;
    LET vcontador = -1;
    LET vcuantos  = 0;

    BEGIN

    ON EXCEPTION
	SET sql_err
	IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
        RETURN vcodret, vcuantos;
	END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "./reversa_pos_dup.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

     -- ********************* FOREACH PRINCIPAL ***********************

    FOREACH WITH HOLD
	  SELECT cuenta, folio_suc, importe
        INTO vcuenta, vfolio_suc, vimporte	
	    FROM bdicheq:mov_reversar_pos  
	
      IF (vcontador = -1) THEN
         BEGIN WORK;
         LET vcontador = 0;
      END IF;

	  UPDATE bdicheq:sc_movdia SET cancelad = "S"
	   WHERE cuenta = vcuenta
	     AND folio_suc = vfolio_suc;
		 
	  SELECT sdo_actual, imp_chq_sbg
        INTO vsdo_actual, vimp_chq_sbg	  
	    FROM bdicheq:sc_maechq
	   WHERE cuenta = vcuenta;
	   
	  LET vsaldo = 0;
      LET vsbg   = 0;
	  
	  IF vimp_chq_sbg > 0 THEN
         LET vsaldo = (vsdo_actual + vimporte) - vimp_chq_sbg;
	 	 LET vsbg = 0;
 	  ELSE
		 LET vsaldo = vsdo_actual + vimporte;
	  END IF;
	  
	  UPDATE bdicheq:sc_maechq 
	     SET sdo_actual = vsaldo, imp_chq_sbg = vsbg
	   WHERE cuenta = vcuenta;
            		 
	  LET vcontador = vcontador + 1;

      IF (vcontador >= 5000) THEN
         LET vcuantos = vcuantos + vcontador;
	     LET vcontador = 0;
         COMMIT WORK;
         BEGIN WORK;
      END IF;

    END FOREACH;

    -- ************************* FOREACH PRINCIPAL *************************

    LET vcuantos = vcuantos + vcontador;

    IF (vcontador > 0) THEN
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret, vcuantos;

END PROCEDURE;