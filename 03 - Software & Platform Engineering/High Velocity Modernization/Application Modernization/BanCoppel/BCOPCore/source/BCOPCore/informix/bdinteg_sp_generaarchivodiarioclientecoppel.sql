CREATE PROCEDURE "informix".sp_generaarchivodiarioclientecoppel( pdFecha DATE )
RETURNING CHAR(5) AS CodRetorno;

    -- ****************************************************************************************************
    -- DESCRIPCION: Genera un archivo de intercambio que contiene  el número de tarjeta Bancoppel, 
    --              número de cliente Coppel, número de cliente Bancoppel,
    --			    fecha de generación del dato y estatus de la tarjeta bancoppel de las tarjetas bancoppel
    --			    cuyo estatus fue modificado en el periodo de fechas indicado.
    -- AUTOR : Casanova Edeza Hector Juan
    -- FECHA : 18/02/2009
    -- BD: BdInteg
    -- SISTEMA : Inventario de Tarjetas Caja Unica.
    -- ****************************************************************************************************
    
    DEFINE vsRepositorio CHAR (200);
    DEFINE viDiasposteriores INTEGER;
    DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
    DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);
    DEFINE vsNumTarjetaBanco CHAR (25);
    DEFINE vsNumClienteCoppel CHAR (20);
    DEFINE vsNumClienteBanco CHAR (20);
    DEFINE vsEstatusTarjeta CHAR (1);
    DEFINE vdFecha DATE;
    DEFINE vsNomArchivo CHAR (25);
    DEFINE vsNomArchivoF CHAR (25);
    DEFINE vsSQL CHAR (1050) ;
    DEFINE vsSQL1 CHAR (150);
    DEFINE vsSQL2 CHAR (750) ;
    DEFINE vsSQL3 CHAR (150) ;
    DEFINE vsFlagSystem CHAR (1);
    DEFINE viContadorRegistros INTEGER;
    DEFINE vsFlagEnTransaccion CHAR (1);
    DEFINE vsCodRetorno CHAR (5);
    DEFINE viSqlError INTEGER;

    LET vsRepositorio = '';
    LET viDiasposteriores = 0;
    LET vdtFechaIni = CURRENT;
    LET vdtFechaFin = CURRENT;
    LET vsNumTarjetaBanco = '';
    LET vsNumClienteCoppel = '';
    LET vsNumClienteBanco = '';
    LET vsEstatusTarjeta = '';
    LET vdFecha = CURRENT;
    LET vsNomArchivo = '';
    LET vsNomArchivoF = '';
    LET vsSQL = '' ;
    LET vsSQL1 = '' ;
    LET vsSQL2 = '' ;
    LET vsSQL3 = '' ;
    LET vsFlagSystem = '';
    LET viContadorRegistros = 0;
    LET vsFlagEnTransaccion = 'F';
    LET vsCodRetorno = '00000';
    LET viSqlError = 0;

    --- SET DEBUG FILE TO '/tmp/sp_GeneraArchivoDiarioClienteCoppel.out';
    --- TRACE ON;
    
    BEGIN

    ON EXCEPTION SET viSqlError    --cacha el error en caso de que exista y regresa un valor predeterminado
        -- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
            ROLLBACK WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;

        -- ELIMINA LA TABLA TEMPORAL DE REPORTE
        SET ISOLATION TO DIRTY READ;
        IF EXISTS ( SELECT dbsname, tabname 
                      FROM sysmaster:SysTabNames  
                     WHERE partnum > 0 
                       and tabname = 'tmpreportearchclientecoppel' 
                       AND dbsname= 'bdinteg') THEN
            DROP TABLE BdInteg:TmpReporteArchClienteCoppel;
        END IF;

        LET vsCodRetorno = viSqlError;

        IF (vsFlagSystem = '1') THEN -- ERROR DE GENERACION DEL ARCHIVO
            LET vsCodRetorno = '00105';
        END IF;

        RETURN vsCodRetorno ;
    END EXCEPTION;

    -- SET DEBUG FILE TO "/tmp/conciliacion/trace.txt";
    -- TRACE ON;

    IF ( pdFecha IS NULL ) THEN -- // LA FECHA ES NULO
        LET vsCodRetorno = '00100';
    ELIF NOT EXISTS (SELECT Comentario FROM BdInteg:si_vbParam WHERE Desc_Campo = "ruta_archivo" ) THEN -- // NO EXISTE EL PARAMETRO DEL REPOSITORIO DEL ARCHIVO DE INTERCAMBIO
        LET vsCodRetorno = '00101';
    ELIF NOT EXISTS (SELECT Valor FROM BdInteg:si_vbParam WHERE Desc_Campo = "dias_archivo" ) THEN -- // NO EXISTE EL PARAMETRO DEL ALCANCE EN DIAS DE LA CONSULTA
        LET vsCodRetorno = '00102';
    ELSE
        -- // OBTIENE LA RUTA DEL REPOSITORIO DONDE SE DEJA EL ARCHIVO DE INTERCAMBIO.
        SET ISOLATION TO DIRTY READ;
        SELECT FIRST 1 Comentario 
          INTO vsRepositorio 
          FROM BdInteg:si_vbParam 
         WHERE Desc_Campo = "ruta_archivo";

        -- // OBTIENE EL NUMERO DE DIAS CON EL QUE SE GENERA EL ARCHIVO
        SET ISOLATION TO DIRTY READ;
        SELECT FIRST 1 Valor 
          INTO viDiasposteriores 
          FROM BdInteg:si_vbParam 
         WHERE Desc_Campo = "dias_archivo";

        -- // ESTABLECE EL RANGO DE FECHA DE LA BUSQUEDA DE REGISTROS.
        LET vdtFechaFin = YEAR (pdFecha) || '-' || MONTH (pdFecha) || '-' || DAY (pdFecha) || ' 23:59:59';
        LET vdtFechaIni = YEAR (pdFecha - viDiasposteriores) || '-' || MONTH (pdFecha - viDiasposteriores) || '-' || DAY (pdFecha - viDiasposteriores) || ' 00:00:00';


        -- // VALIDA SI EXISTE LA TABLA DEL REPORTE
        SET ISOLATION TO DIRTY READ;
        IF EXISTS ( SELECT dbsname, tabname 
                      FROM sysmaster:SysTabNames  
                     WHERE partnum > 0
                       and tabname = 'tmpreportearchclientecoppel' 
                       AND dbsname= 'bdinteg') THEN
            DROP TABLE BdInteg:TmpReporteArchClienteCoppel;
        END IF;

        -- // CREA LA TABLA DEL REPORTE
        CREATE TABLE TmpReporteArchClienteCoppel
        (
            NumTarjetaBanco CHAR (25),
            NumClienteCoppel CHAR (20),
            NumClienteBanco CHAR (20),
            EstatusTarjeta CHAR (1),
            Fecha DATE
        );

        -- // OBTIENE LOS DATOS DE LAS TARJETAS CUYO ESTATUS FUE MODIFICADO DENTRO DEL RANGO DE FECHAS INDICADO.
        SET ISOLATION TO DIRTY READ;
        FOREACH WITH HOLD 
            SELECT {+INDEX (bdinteg:si_clienteconfirmado idx_clienteconfirmado)}
                   LPAD(TRIM(CteCon.NumCteBanCoppel), 9, '0'), 
                   CteCon.NumCteCoppel, Tar.NumTarjeta, Tar.FechaUltModif, 
                   DECODE (Tar.CodStatusTarjeta,'ACT','A','I') AS EstatusTarjeta
              INTO vsNumClienteBanco, vsNumClienteCoppel, vsNumTarjetaBanco, vdFecha, vsEstatusTarjeta
              FROM BdInteg:Si_ClienteConfirmado AS CteCon, 
                   Intercard:Tarjeta AS Tar
             WHERE CteCon.NumCteBanCoppelformat = Tar.NumCliente 
               AND Tar.FechaUltModif BETWEEN vdtFechaIni AND vdtFechaFin

            -- // ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (vsFlagEnTransaccion = 'F') THEN
                BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

            INSERT INTO BdInteg:TmpReporteArchClienteCoppel ( NumTarjetaBanco, NumClienteCoppel, NumClienteBanco, EstatusTarjeta, Fecha)
            VALUES (vsNumTarjetaBanco, vsNumClienteCoppel, vsNumClienteBanco, vsEstatusTarjeta, vdFecha);

            LET viContadorRegistros = viContadorRegistros + 1;

            -- // TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (viContadorRegistros = 100) THEN -- // VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
                LET viContadorRegistros = 0;
                CONTINUE FOREACH;
            END IF;
        END FOREACH ;

        -- // TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN -- // VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;

        LET viContadorRegistros = 0;

        -- // GENERA EL NOMBRE DEL ARCHIVO DE INTERCAMBIO  CLICOPBANAAAAMMDD##.DAT
        LET vsNomArchivo = 'CLICOPBAN' || REPLACE (SUBSTRING (CURRENT FROM 1 FOR 10), '-', '' ) || '.txt';
        LET vsNomArchivoF = 'CLICOPBAN' || REPLACE (SUBSTRING (CURRENT FROM 1 FOR 10), '-', '' ) || '.dat';

        LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) || '/originales/' || TRIM (vsNomArchivo) || ' DELIMITER ' || '''|''';
        LET vsSQL2 = "SELECT NumTarjetaBanco, NumClienteCoppel, NumClienteBanco, EstatusTarjeta, Fecha FROM BdInteg:TmpReporteArchClienteCoppel;" ;
        LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || '/originales/control_reporte.sql';

        LET vsSQL1 = TRIM(vsSQL1);
        LET vsSQL3 = TRIM(vsSQL3);
        LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

        -- // CHECA QUE NO ESTE VACIA LA CONSULTA
        IF ( vsSQL <> '' ) THEN
            LET vsFlagSystem = '1';

            -- // CREA ARCHIVO DE CONTROL
            SYSTEM vsSQL ;

            let vsSQL = '' ;
            LET vsSQL = 'dbaccess BdInteg ' || TRIM(vsRepositorio) || '/originales/control_reporte.sql' ;
            SYSTEM vsSQL ;

            LET vsSQL = "sed 's/|$//g' "|| TRIM(vsRepositorio) ||'/originales/'|| TRIM (vsNomArchivo) || " > " || TRIM(vsRepositorio) ||'/originales/'|| TRIM (vsNomArchivoF);
            SYSTEM vsSQL;

            LET vsSQL = 'rm ' || TRIM(vsRepositorio) ||'/originales/'|| TRIM (vsNomArchivo)  ;
            SYSTEM vsSQL ;
            
            -- // BORRA EL ARCHIVO DE CONTROL
            let vsSQL = '' ;
            LET vsSQL = 'rm ' || TRIM(vsRepositorio) || '/originales/control_reporte.sql' ;
            SYSTEM vsSQL ;

            LET vsFlagSystem = '';
        ELSE 
            -- // CONSULTA VACIA
            LET vsCodRetorno = '00104';
        END IF ;

        -- // ELIMINA LA TABLA TEMPORAL DE REPORTE
        SET ISOLATION TO DIRTY READ;
        IF EXISTS ( SELECT dbsname, tabname 
                      FROM sysmaster:SysTabNames  
                     WHERE partnum > 0 
                       and tabname = 'tmpreportearchclientecoppel' 
                       AND dbsname= 'bdinteg') THEN
            DROP TABLE BdInteg:TmpReporteArchClienteCoppel;
        END IF;

    END IF;

    RETURN vsCodRetorno ;

    END

END PROCEDURE;