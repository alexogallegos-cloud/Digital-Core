CREATE PROCEDURE "informix".sp_obtieneinstrucvencimiento(pEmpresa CHAR(3), pMonto money(14,2) ,pRegistros SMALLINT)
RETURNING CHAR(5), CHAR(2), CHAR (40);

    -- // DEFINICION DE VARIABLES //
    define iSqlErr      INTEGER;
    define cCodigo 		char(2);
    define cDescripcion char(40);
    define cCodRet 		char(5);
    define iCiclo		integer;

    define mMontoparam money (14,2);

    -- // INICIALIZACION DE VARIABLES //
    let iSqlErr			= 0;
    let cCodigo 		= "";
    let cDescripcion 	= "";
    let cCodRet 		=  "00000";
    let iCiclo      	= 0;
    let mMontoparam     = 0.00;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtieneinstrucvencimiento.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet,cCodigo, cDescripcion;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	

    IF pEmpresa IS NULL OR pEmpresa = "" OR pMonto IS NULL OR pMonto = "" THEN
        LET cCodRet = "00001";
        RETURN cCodRet,cCodigo, cDescripcion;
    END IF;	

    SELECT CAST (valor AS money (14,2))
      INTO mMontoparam
      FROM bdicheq:"informix".sc_param 
     WHERE empresa = pEmpresa 
       AND codparam = 'INSVTOINVCRE'; 

    IF mMontoparam IS NULL THEN
        LET cCodRet = "00002";
        RETURN cCodRet,cCodigo, cDescripcion;
    END IF;

    IF pMonto >= mMontoparam OR pMonto = 0.00 THEN
        FOREACH
            SELECT instrucc,descripcion 
              INTO cCodigo, cDescripcion
              FROM  bdicheq:"informix".sc_instrucc
             WHERE empresa = pEmpresa 
               AND instrucc <> ""
             ORDER BY instrucc

            LET iCiclo = iCiclo + 1;

            IF iCiclo <= pRegistros THEN
                CONTINUE FOREACH;
            END IF;

            RETURN cCodRet ,cCodigo ,cDescripcion WITH RESUME;
        END FOREACH;
    ELSE
        FOREACH
            SELECT instrucc,descripcion 
              INTO cCodigo, cDescripcion
              FROM  bdicheq:"informix".sc_instrucc
             WHERE empresa = pEmpresa 
               AND instrucc NOT IN ("03","04")
             ORDER BY instrucc

            LET iCiclo = iCiclo + 1;

            IF iCiclo <= pRegistros THEN
                CONTINUE FOREACH;
            END IF;

            RETURN cCodRet ,cCodigo ,cDescripcion WITH RESUME;
        END FOREACH;
    END IF;
    
    END;
    
END PROCEDURE

DOCUMENT
    'AUTOR : Felipe Urias',
    'DESCRIPCION: Se encarga de obtener las intrucciones al vencimiento de la invercion creciente',
    'EJECUTADO O LLAMADO POR: BCOFI0010201.dll',
    'FECHA : MAYO 2011',
    'VERSION: 20110602',
    'BD    : bdicheq';

CREATE PROCEDURE "informix".sp_proyeccionsc( pempresa CHAR(3),
                                             psucursal CHAR(4),
                                             pusuario CHAR(8),
                                             pproducto CHAR(4),
                                             pmonto MONEY(14,2),
                                             pInstruc CHAR(2) )
RETURNING CHAR(5), DATE, DATE, DECIMAL(4,2), MONEY(14,2), 
          DECIMAL(4,2), MONEY(14,2), MONEY(14,2), DECIMAL(9,6);

    -- ############################################################################################################################################################
    -- sp_proyeccionsc
    -- Version              1.0.0
    -- Objetivo:            Obtener la proyeccion de una cuenta de cheques tasa variable
    -- Supuestos:           Ninguno
    -- Creado por:
    -- Modificado por:      Alejandro Rueda Sanchez
    -- Ultima Modificacion: Enero - 2009
    -- Modificado por:      Jesús Manuel Aguilar Heredia
    -- Descripcion del cambio: Se agrego paarametro de entrada al procedimiento con el cual se recibira la instruccion de proyeccion, 
    --                         para los casos 01,02 se deja la misma funcionalidad del procedimiento y Se valida que cuando 
    --                         sea el tipo de instruccion sea 03 ó  04 no se sume el interes al capital, y validar que para estas dos opciones 
    --                         el monto sea mayor a 50,000, monto obtendido de un prametro.
    --                         Ademas se le realiza la adecuacion al procedimiento para que cumpla las reglas de informix, 
    --                         por lo cual se le eliminaron algunas variables que no se utilizan, tales como:vferiado,vfecha_tmp1,vfecha_tmp2,vdia_sig,vacumulado
    --                         y se corrigio el nombrado de las variables para cumplir con el standar de programacion.
    -- Fecha de modificacion: 24-Mayo-2011
    -- ############################################################################################################################################################
    
    DEFINE cCodret     CHAR(5);
    DEFINE iSqlerr     INTEGER;
    DEFINE dtFecha_ini  DATE;
    DEFINE dtFecha_fin  DATE;
    DEFINE dtFecha_tmp  DATE;
    DEFINE dtFecha_hoy  DATE;
    DEFINE cMes        CHAR(2);
    DEFINE dTasa       DECIMAL(4,2);
    DEFINE mMonto_int  MONEY(14,2);
    DEFINE dTasa_tot   DECIMAL(4,2);
    DEFINE mMonto_tot  MONEY(14,2);
    DEFINE icontador   SMALLINT;
    DEFINE sDias       SMALLINT;
    DEFINE cTipo_calc  CHAR(1);
    DEFINE cTasa_nom   CHAR(8);
    DEFINE sDia_aper   SMALLINT;
    DEFINE cTipo_tasa  CHAR(1);
    DEFINE mIsr        MONEY(14,2);
    DEFINE dTisr       DECIMAL(9,6);
    DEFINE sNumdias    SMALLINT;
    DEFINE mAnualisr   MONEY(14,2);
    DEFINE dValor      DECIMAL(14,2);

    ON EXCEPTION SET iSqlerr
        IF iSqlerr <> 0 THEN
            LET cCodret = iSqlerr;
            RETURN cCodret,NULL,NULL,0,0,0,0, 0, 0;
        END IF
    END EXCEPTION;
    
    --- set debug file to "/tmp/sp_proyeccionsc.out";
    --- trace on;
    
    LET cCodret    = "000";
    LET dtFecha_ini = "";
    LET dtFecha_fin = "";
    LET cMes       = "";
    LET dTasa      = 0;
    LET mMonto_int = 0;
    LET dTasa_tot  = 0;
    LET mMonto_tot = pmonto;
    LET dtFecha_tmp = "";
    LET dtFecha_hoy = "";
    LET sDias      = 0;
    LET cTipo_calc = "";
    LET dTasa      = "";
    LET cTasa_nom  = "";
    LET sDia_aper  = 0;
    LET cTipo_tasa = "";
    LET mIsr       = 0;
    LET dTisr      = 0;
    LET sNumdias   = 0;
    LET mAnualisr  = 0;
    LET dValor     = 0;
    LET icontador = 1;
    
    IF Trim(pproducto) = "" OR pmonto = 0 OR NVL(pInstruc,"") = "" THEN
        LET cCodret = "110";
        RETURN cCodret,dtFecha_ini,dtFecha_fin,dTasa,mMonto_int,dTasa_tot,mMonto_tot,mIsr, dTisr;
    END IF;
    
    IF pInstruc IN("03","04") THEN
        SELECT valor
          INTO dValor
          FROM bdicheq:"informix".sc_param
         WHERE empresa = pempresa
           AND codparam = "INSVTOINVCRE";

        IF pmonto < dValor THEN
            LET cCodret = "111";
            RETURN cCodret,dtFecha_ini,dtFecha_fin,dTasa,mMonto_int,dTasa_tot,mMonto_tot,mIsr, dTisr;
        END IF;  
    END IF;

    -- // Extrae las Caracteristicas del Producto
    SELECT tipo_anio_calc,tasa
      INTO cTipo_calc,cTasa_nom
      FROM bdicheq:"informix".sc_producto
     WHERE producto = pproducto
       AND empresa = pempresa;

    -- // Obtiene la fecha del Sistema de Captacion
    SELECT fecha_hoy 
      INTO dtFecha_hoy 
      FROM bdicheq:"informix".sc_fechas;

    LET sDia_aper = DAY(dtFecha_hoy);

    SELECT MAX(fecha)
      INTO dtFecha_tmp
      FROM bdinteg:"informix".si_tasa_mes;

    LET dtFecha_ini = dtFecha_hoy;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT mes,valor_tasa,tipo_tasa
          INTO cMes,dTasa,cTipo_tasa
          FROM bdinteg:"informix".si_tasa_mes
         WHERE fecha = dtFecha_tmp
           AND tasa = cTasa_nom
         ORDER BY mes::SMALLINT

        LET icontador = cMes::SMALLINT;

        IF icontador = 13  THEN
            CALL "informix".sp_mes_siguiente(dtFecha_hoy, icontador - 1  ,sDia_aper) RETURNING cCodret, dtFecha_fin, sNumdias;
        ELSE
            CALL "informix".sp_mes_siguiente(dtFecha_ini, 1 ,sDia_aper) RETURNING cCodret, dtFecha_fin, sNumdias;
            
            IF sNumdias > 40 THEN
                CALL "informix".sp_mes_siguiente(dtFecha_ini, 0 ,sDia_aper) RETURNING cCodret, dtFecha_fin, sNumdias;
            END IF
        END IF

        LET sDias = sNumdias;
        
        -- // Aqui esta la Modificacion del Calculo de Intereses
        IF pInstruc IN("03","04") THEN --- se agrega validacion para que cuando sean estos tipos de instruccion, el interes no se sume al capital.
            LET pmonto = pmonto-mIsr;
        ELSE
            LET pmonto = pmonto + mMonto_int - mIsr;
        END IF;

        -- // Aqui Termina la Modificacin ALE Realizada por MEL 17 Enero 2009
        CALL "informix".calc_isr_proy(pempresa, "0000000", dtFecha_hoy, sDias, mMonto_int, pmonto, sDias, "S")
        RETURNING cCodret, mIsr, dTisr;

        -- // Calcula los Intereses
        IF cTipo_calc = "1" THEN
            LET mMonto_int = pmonto * (dTasa/100) / 360 * sDias;
        ELSE
            LET mMonto_int = pmonto * (dTasa/100) / 365 * sDias;
        END IF

        -- // Calcula los Intereses META
        IF cTipo_tasa = "P" THEN
            LET dtFecha_ini = dtFecha_hoy;

            IF cTipo_calc = "1" THEN
                LET mMonto_int = mMonto_tot * (dTasa/100) / 360 * sDias;
                LET dTasa_tot = dTasa;
            ELSE
                LET mMonto_int = mMonto_tot * (dTasa/100) / 365 * sDias;
                LET dTasa_tot = dTasa;
            END  IF

            LET mIsr = mAnualisr;
        ELSE  -- // Calcula Intereses Acumulados
            LET mAnualisr = mAnualisr + mIsr;
        END IF;

        RETURN cCodret,dtFecha_ini,dtFecha_fin,dTasa,mMonto_int,dTasa_tot,mMonto_tot, mIsr, dTisr WITH RESUME;
        
        LET dtFecha_ini = dtFecha_fin;
    END FOREACH
    
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_geninfmovscorresp_201106(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50);

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    
    DEFINE vfecha_ini       DATE;
    DEFINE vfecha_fin       DATE;
    
    DEFINE vsucursal        CHAR(4);
    DEFINE vfecha           DATE;
    DEFINE vno_transacc     INTEGER;
    DEFINE vmonto_tot       DECIMAL(18,2);
    DEFINE vcuantos         INTEGER;
    DEFINE vmonto           DECIMAL(18,2);
    DEFINE vlocalidad       CHAR(12);
    DEFINE vciudad          CHAR(60);
    
    DEFINE vexiste_suc      INTEGER;
    DEFINE vaniomes         CHAR(6);
    DEFINE vsql             CHAR(500);
    
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    
    LET vfecha_ini   = '';
    LET vfecha_fin   = '';
    
    LET vsucursal    = '';
    LET vfecha       = '';
    LET vno_transacc = 0;
    LET vmonto_tot   = 0.00;
    LET vcuantos     = 0;
    LET vmonto       = 0.00;
    LET vlocalidad   = '';
    LET vciudad      = '';
    
    LET vexiste_suc = 0;
    LET vaniomes    = '';
    LET vsql        = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_geninfmovscorresp_201106.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_geninfmovscorresp_201106.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET vfecha_ini = '06/01/2011';
    LET vfecha_fin = '06/30/2011';
    
    -- // MOVIMIENTOS DE CRÉDITO
    CREATE TEMP TABLE sc_movs_cred_corresp(
        sucursal        char(4),
        no_movs_cred    integer,
        monto_cred      decimal(18,2),
        fecha           char(10) ) 
    EXTENT SIZE 1024 NEXT SIZE 512 LOCK MODE ROW;
begin;
    CREATE INDEX idx_movscrecorr ON sc_movs_cred_corresp(sucursal) ONLINE;
commit;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_cred_corresp;
    
    LET vsucursal = '';
    LET vfecha = '';
    LET vno_transacc = 0;
    LET vmonto_tot = 0.00;
    
    FOREACH
        SELECT SUBSTR(folio_suc,1,4), fecha_mov, COUNT(*), SUM(monto)
          INTO vsucursal, vfecha, vno_transacc, vmonto_tot
          FROM bdicred:sd_movhis
         WHERE codigo_fun = '700'
           AND codigo_ref = 1
           AND fecha_mov BETWEEN vfecha_ini AND vfecha_fin
           AND reversado = 'N'
           AND transacc_suc = '6282'
         GROUP BY 1, 2
           
        INSERT INTO sc_movs_cred_corresp(sucursal, no_movs_cred, monto_cred, fecha)
        VALUES(vsucursal, vno_transacc, vmonto_tot, vfecha);
        
        LET vsucursal = '';
        LET vfecha = '';
        LET vno_transacc = 0;
        LET vmonto_tot = 0.00;
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_cred_corresp;
    
    -- // INSERTA MOVIMIENTOS DE CRÉDITO
    LET vsucursal = '';
    LET vcuantos = 0;
    LET vmonto = 0.00;
    LET vfecha = '';
    LET vexiste_suc = 0;
    
    FOREACH
        SELECT sucursal, no_movs_cred, monto_cred, fecha
          INTO vsucursal, vcuantos, vmonto, vfecha
          FROM sc_movs_cred_corresp
          
        SELECT COUNT(*)
          INTO vexiste_suc
          FROM sc_movs_corresp
         WHERE fecha = vfecha
           AND sucursal = vsucursal;
         
        IF vexiste_suc = 0 THEN
            INSERT INTO sc_movs_corresp(sucursal, no_movs_capt, monto_capt, no_movs_cred, monto_cred, fecha)
            VALUES(vsucursal, 0, 0.00, vcuantos, vmonto, vfecha);
        ELSE
            UPDATE sc_movs_corresp
               SET no_movs_cred = vcuantos,
                   monto_cred = vmonto
             WHERE fecha = vfecha
               AND sucursal = vsucursal;
        END IF;
        
        LET vsucursal = '';
        LET vcuantos = 0;
        LET vmonto = 0.00;
        LET vfecha = '';
        LET vexiste_suc = 0;
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_corresp;
    
    -- // INSERTA LAS CIUDADES DE LAS SUCURSALES
    FOREACH
        SELECT UNIQUE sucursal
          INTO vsucursal
          FROM sc_movs_corresp
          
        SELECT localidad_inegi
          INTO vlocalidad
          FROM bdirepaut:sp_r026_establecimiento
         WHERE clave = vsucursal;
           
        SELECT LIMIT 1 ciudad||' '||TRIM(nombre)
          INTO vciudad
          FROM bdinteg:si_ciudades
         WHERE localidad_inegi = vlocalidad;
          
        UPDATE sc_movs_corresp
           SET ciudad = vciudad
         WHERE sucursal = vsucursal;
         
        LET vsucursal = '';
        LET vlocalidad = '';
        LET vciudad = '';
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_corresp;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vaniomes = TO_CHAR(vfecha_fin, '%Y%m');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/movscorrespxfechasuc_'||vaniomes||'.txt '||
               ' SELECT ciudad, sucursal, no_movs_capt, monto_capt, no_movs_cred, monto_cred, fecha[4,5]||fecha[1,2]||fecha[9,10]'||
               ' FROM sc_movs_corresp WHERE fecha BETWEEN '''||vfecha_ini||''' AND '''||vfecha_fin||''' ORDER BY fecha, sucursal" > /resplogifx/conciliachq/movtoscorresp.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movtoscorresp.sql"; 
    SYSTEM vsql;
       
    LET vcodret3 = 'EL PROCESO SE REALIZO SATISFACTORIAMENTE';

    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;