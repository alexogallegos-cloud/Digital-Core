CREATE PROCEDURE "informix".sp_edoctamovtos_central( pEmpresa  CHAR(3),  
                                                     pCuenta   CHAR(20), 
                                                     pFechaIni DATE,     
                                                     pFechaFin DATE,     
                                                     pRegistro SMALLINT, 
                                                     pUsuario  CHAR(10), 
                                                     iConsMax  INTEGER ) 
RETURNING CHAR(5)      AS cCodRet,      
          CHAR(10)     AS cFechaMov,    
          CHAR(40)     AS cReferencia,  
          CHAR(50)     AS cDescripcion, 
          MONEY(14, 2) AS mRetiro,      
          MONEY(14, 2) AS mDeposito,    
          MONEY(14, 2) AS mSaldo,       
          CHAR(50)     AS cSucursal,    
          CHAR(4)      AS cTransacc,
          CHAR(16)     AS cNumTarjeta;    
    
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE iAux             INTEGER;
    DEFINE iCiclo           INTEGER;
    DEFINE dFechaMov1       DATE;
    DEFINE cFechaMov        CHAR(10);
    DEFINE cReferencia      CHAR(40);
    DEFINE cDescripcion     CHAR(50);
    DEFINE mRetiro          MONEY(14,2);
    DEFINE mDeposito        MONEY(14,2); 
    DEFINE mSaldo           MONEY(14,2); 
    DEFINE mMonto           MONEY(14,2);
    DEFINE cNaturaleza      CHAR(1);
    DEFINE cSucursal        CHAR(50);
    DEFINE cProducto        CHAR(4);
    DEFINE cconsmovhis      CHAR(10);
    DEFINE cconsmovhisold   CHAR(10);
    DEFINE cconsmovhisold2  CHAR(10);
    DEFINE cconsmovhisold3  CHAR(10);
	DEFINE cTransacc        CHAR(4);
    DEFINE cNumTarjeta      CHAR(16);
    DEFINE cConcepto        CHAR(40);

    LET cCodRet         = "000";
	LET iSqlErr		    = 0;
    LET iIsamErr	    = 0; 
    LET iAux            = 0;
    LET iCiclo          = 0;
    LET dFechaMov1      = "";
    LET cFechaMov       = "";
    LET creferencia     = "";
    LET cDescripcion    = "";
    LET mRetiro         = 0;
    LET mDeposito       = 0;
    LET mSaldo          = 0;
	LET mMonto          = 0;
	LET cNaturaleza     = '';
    LET cSucursal       = "";
    LET cProducto       = '';
    LET cconsmovhis     = '';
	LET cconsmovhisold  = '';
    LET cconsmovhisold2 = '';
    LET cconsmovhisold3 = '';
	LET cTransacc       = '';
    LET cNumTarjeta     = '';
    LET cConcepto       = '';
    
    LET pCuenta = TRIM(pCuenta);
    
   --- SET DEBUG FILE TO "/respaldosbd/hectorb/sp_edoctamovtos_central.out";
   --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION 
        SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cFechaMov, cReferencia, cDescripcion, mRetiro, mDeposito, mSaldo,cSucursal, cTransacc, cNumTarjeta;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTENGO EL NUMERO DE PRODUCTO 
    SELECT producto 
      INTO cProducto
      FROM bdicheq:"informix".sc_maechq
     WHERE empresa = pEmpresa
       AND cuenta = pCuenta;
    
    LET pUsuario = pUsuario;
    
    -- // LIMPIO TBABLA PARA REGISTROS NUEVOS 
    -- // Se quita delete para evitar tardanza en la respuesta del SP - 01/06/2010 
    /* ##############################
    DELETE FROM vedoctamov
     WHERE cod_usuario = pUsuario;
    ############################## */

    SELECT valor
      INTO cconsmovhis
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO cconsmovhisold
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    SELECT valor
      INTO cconsmovhisold2
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechaIniMovhisOld2';
       
    SELECT valor
      INTO cconsmovhisold3
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'vfechconmovhisold3';

    -- // SE OBTIENEN TODOS LAS TRANSACCIONES DE LAS TABLAS HISTORICAS DE MOVIMIENTOS DEL RANGO DE FECHAS SOLICITADAS
    FOREACH
        SELECT {+INDEX(sc_movhis idx_movhisnew4)}
               mm.num_serial, mm.fech_alt, TRIM(tr.descripcion) AS descripcion, NVL(mm.referencia, '') AS referencia, mm.monto_tot, tr.naturaleza, mm.sdo_cuenta,
               CASE WHEN tr.numero in (0202,0223) THEN mm.sucursal||'-'||NVL(TRIM(su.nombre),'')||'-'||fech_hor ELSE '' END AS Sucursal, mm.transacc, NVL(mm.num_tarjeta,' ')
          INTO iAux, dFechaMov1, cDescripcion, cReferencia, mMonto, cNaturaleza, mSaldo, cSucursal, cTransacc, cNumTarjeta
          FROM bdicheq:"informix".sc_movhis AS mm,
               bdinteg:"informix".si_transacc AS tr,
         OUTER bdinteg:"informix".si_sucursales su
         WHERE mm.empresa = pEmpresa
           AND mm.cuenta = pCuenta
           AND mm.fech_alt BETWEEN pFechaIni AND pFechaFin
           AND mm.fech_alt >= cconsmovhis
           AND mm.cancelad <> "S"
           AND mm.transacc = tr.numero
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc
           AND tr.se_emite_edocta = "S"
           AND su.sucursal = mm.sucursal
           AND su.empresa = tr.empresa
         UNION ALL
        SELECT {+INDEX(sc_movhis_old movhis1)}
               mm.num_serial, mm.fech_alt, TRIM(tr.descripcion) AS descripcion, NVL(mm.referencia, '') AS referencia, mm.monto_tot, tr.naturaleza, mm.sdo_cuenta,
               CASE WHEN tr.numero in (0202,0223) THEN mm.sucursal||'-'||NVL(TRIM(su.nombre),'')||'-'||fech_hor ELSE '' END AS Sucursal, mm.transacc, NVL(mm.num_tarjeta,' ')
		  FROM bdicheq:"informix".sc_movhis_old AS mm,
               bdinteg:"informix".si_transacc AS tr,
         OUTER bdinteg:"informix".si_sucursales su
         WHERE mm.empresa = pEmpresa
           AND mm.cuenta = pCuenta
           AND mm.fech_alt BETWEEN pFechaIni AND pFechaFin
           AND mm.fech_alt >= cconsmovhisold
           AND mm.fech_alt < cconsmovhis
           AND mm.cancelad <> "S"
           AND mm.transacc = tr.numero
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc
           AND tr.se_emite_edocta = "S"
           AND su.sucursal = mm.sucursal
           AND su.empresa = tr.empresa
		UNION ALL
        SELECT {+INDEX(sc_movhis_old2 movhis1_old2)}
               mm.num_serial, mm.fech_alt, TRIM(tr.descripcion) AS descripcion, NVL(mm.referencia, '') AS referencia, mm.monto_tot, tr.naturaleza, mm.sdo_cuenta,
               CASE WHEN tr.numero in (0202,0223) THEN mm.sucursal||'-'||NVL(TRIM(su.nombre),'')||'-'||fech_hor ELSE '' END AS Sucursal, mm.transacc, NVL(mm.num_tarjeta,' ')
          FROM bdicheq:"informix".sc_movhis_old2 AS mm,
               bdinteg:"informix".si_transacc AS tr,
         OUTER bdinteg:"informix".si_sucursales su
         WHERE mm.empresa = pEmpresa
           AND mm.cuenta = pCuenta
           AND mm.fech_alt BETWEEN pFechaIni AND pFechaFin
           AND mm.fech_alt >= cconsmovhisold2
           AND mm.fech_alt < cconsmovhisold
           AND mm.cancelad <> "S"
           AND mm.transacc = tr.numero
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc
           AND tr.se_emite_edocta = "S"
           AND su.sucursal = mm.sucursal
           AND su.empresa = tr.empresa
        UNION ALL
        SELECT {+INDEX(sc_movhis_old3 movhis1_old3)}
               mm.num_serial, mm.fech_alt, TRIM(tr.descripcion) AS descripcion, NVL(mm.referencia, '') AS referencia, mm.monto_tot, tr.naturaleza, mm.sdo_cuenta,
               CASE WHEN tr.numero in (0202,0223) THEN mm.sucursal||'-'||NVL(TRIM(su.nombre),'')||'-'||fech_hor ELSE '' END AS Sucursal, mm.transacc, NVL(mm.num_tarjeta,' ')
          FROM bdicheq:"informix".sc_movhis_old3 AS mm,
               bdinteg:"informix".si_transacc AS tr,
         OUTER bdinteg:"informix".si_sucursales su
         WHERE mm.empresa = pEmpresa
           AND mm.cuenta = pCuenta
           AND mm.fech_alt BETWEEN pFechaIni AND pFechaFin
           AND mm.fech_alt >= cconsmovhisold3
           AND mm.fech_alt < cconsmovhisold2
           AND mm.cancelad <> "S"
           AND mm.transacc = tr.numero
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc
           AND tr.se_emite_edocta = "S"
           AND su.sucursal = mm.sucursal
           AND su.empresa = tr.empresa
         ORDER BY mm.fech_alt DESC, mm.num_serial DESC, fech_alt DESC, num_serial DESC
         
        IF cTransacc = '0273' THEN
			SELECT FIRST 1 vchrconceptopago
			  INTO cConcepto
			  FROM bdispei:tblhistpago
			 WHERE vchrclaverastreo = cReferencia
			   AND dtfechavalor = dFechaMov1
			   AND intcvetipopago <> 0;
               
            IF cConcepto is null OR cConcepto = '' THEN
                LET cDescripcion = TRIM(cDescripcion);
            ELSE
                LET cDescripcion = TRIM(cDescripcion) ||' '|| TRIM(cConcepto);
            END IF;
		END IF;

	    IF cTransacc = '0274' THEN
            IF SUBSTR(cReferencia,1, 9) = 'BANCOPPEL' THEN
                SELECT FIRST 1 vchrconceptopago
                  INTO cConcepto
                  FROM bdispei:tblhistpago
                 WHERE vchrclaverastreo = cReferencia
                   AND dtfechavalor = dFechaMov1
                   AND intcvetipopago <> 0;
            ELSE
                SELECT FIRST 1 vchrconceptopago2
                  INTO cConcepto
                  FROM bdispei:tblhistpago
                 WHERE vchrclaverastreo = cReferencia
                   AND dtfechavalor = dFechaMov1
                   AND intcvetipopago <> 0;
            END IF;
            
            IF cConcepto is null OR cConcepto = '' THEN
                LET cDescripcion = TRIM(cDescripcion);
            ELSE
                LET cDescripcion = TRIM(cDescripcion) ||' '|| TRIM(cConcepto);
            END IF;
		END IF;
			   
        LET mRetiro = 0;
        LET mDeposito = 0;

        IF cNaturaleza = 'C' THEN
            LET mRetiro = mMonto;
        END IF;

        IF cNaturaleza = 'A' OR cNaturaleza = 'R' THEN
            LET mDeposito = mMonto;
        END IF;

        LET iCiclo = iCiclo + 1;
        
        -- // PAGINACION
        IF iCiclo <= pRegistro THEN 
            CONTINUE FOREACH;
        END IF;
        
        LET cFechaMov = SUBSTR(dFechaMov1, 7, 10) || "/" || SUBSTR(dFechaMov1, 1, 2)  || "/" || SUBSTR(dFechaMov1, 4, 5);
        
        IF cProducto = '1600' THEN
            INSERT INTO bdicheq:"informix".vedoctamov 
            (empresa,cod_usuario,secuencia,cuenta,fechamov,referencia,descripcion,retiro,deposito,saldo,generico_1,generico_2,generico_3,generico_4,generico_5,generico_6,consulta)
            VALUES 
            (pEmpresa, pUsuario, iCiclo, pCuenta, dFechaMov1, '', '', mRetiro, mDeposito, mSaldo, cDescripcion, cReferencia, cSucursal, '', '', '', iConsMax);
        ELSE
            RETURN TRIM(cCodRet), cFechaMov, cReferencia, cDescripcion, mRetiro, mDeposito, mSaldo, cSucursal, cTransacc, cNumTarjeta WITH RESUME;
        END IF;
    END FOREACH;
    
    LET cCodRet = '100'; 
    
    RETURN TRIM(cCodRet), cFechaMov, cReferencia, cDescripcion, mRetiro, mDeposito, mSaldo, cSucursal, cTransacc, cNumTarjeta WITH RESUME;

    END;

END PROCEDURE

DOCUMENT
'CAMBIO     : Abigail Vasavilbazo, Armando Mercado',
'DESCRIPCION: Se modifico para validar si el producto es 1600 y en dado caso se insertan los reg. directo en la tabla si retornar los movimientos',
'FECHA      : Febrero 2009',
'VERSION    : 200902',
'BD         : BDICHEQ',
'CAMBIO     : Hector Bojorquez',
'DESCRIPCION: Se modifico para que recibiera el folio de la ultima consulta.',
'             Se quito delete para evitar tardanza en la respuesta del sp, se agrego en el insert de la tabla vedoctamov que tambien se inserte el folio de la consulta recibido',
'FECHA      : Junio 2010',
'VERSION    : 201006',
'BD         : BDICHEQ',
'CAMBIO     : Héctor Bojórquez',
'DESCRIPCION: Se modificó para que regrese el número de transacción de cada movimento',
'FECHA      : Agosto 2011',
'VERSION    : 201108',
'BD         : BDICHEQ';

CREATE PROCEDURE "informix".sp_desc_archivos_conc(pEmpresa CHAR(3), pFechaInicio DATE, pFechaFin DATE)
RETURNING CHAR(5);
    
    
    DEFINE vcodret                  CHAR(5);
	DEFINE vfechafin                DATE;
    DEFINE vsqlerr 					INTEGER;
	DEFINE vfecha1					CHAR(8);
	DEFINE vfecha2					CHAR(2);
    DEFINE vcSql                    CHAR(600);
	DEFINE vcStmt                   CHAR(250);
	DEFINE vruta_descarga           CHAR(60);
	
	
    LET vcodret   = "00000";                                                                                  
	LET vsqlerr   = 0; 
	LET vfecha1   = "";
	LET vfecha2   = "";
	LET vcSql     = "";
	LET vcStmt    = "";
	LET vruta_descarga = '';
	
    
    
     --SET DEBUG FILE TO "/tmp/sp_desc_archivos_conc.out";
     --TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "/tmp/sp_desc_archivos_conc.err";
            TRACE ON;
            LET vcodret = vsqlerr;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pEmpresa IS NULL OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
        LET vcodret = '001';
        RETURN vcodret;
    END IF; 
    
	SELECT valor
      INTO vruta_descarga
      FROM sc_param
      WHERE empresa = pEmpresa
		AND codparam = 'RutaDescargaFED';
	

	LET vfecha1 = TO_CHAR(pFechaFin, '%d%m%Y');
	LET vfecha2 = SUBSTR(pFechaInicio,4,2);
	    
    -- // GENERA EL ARCHIVO DE LA TABLA sc_encabezado_edocta_factelect
    LET vcSql = '';
    LET vcSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'con_captacion_'||vfecha2||'-'||vfecha1||'.txt'||
                '  SELECT num_cuenta,fechafinal,substr(mensajeproducto,0,4),rfc FROM sc_encabezado_edocta_factelect_old WHERE fechafinal BETWEEN '''|| pFechaInicio ||''' AND '''|| pFechaFin ||'''" > '|| TRIM(vruta_descarga) ||'descarga_con.sql';
    SYSTEM vcSql;
	
    
    LET vcStmt = '';
    
	LET vcStmt = 'dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/descarga_con.sql'; 
    SYSTEM vcStmt;
    
    	
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE;