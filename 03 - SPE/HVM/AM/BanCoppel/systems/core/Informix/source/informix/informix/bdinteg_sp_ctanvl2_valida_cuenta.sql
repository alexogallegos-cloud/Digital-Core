CREATE PROCEDURE "informix".sp_ctanvl2_valida_cuenta()
    RETURNING CHAR(5) AS codret, 
              CHAR(5) AS CodRet2, 
              CHAR(50) AS CodRet3, 
              INTEGER AS Contador1,
              INTEGER AS Contador2;
              


    DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
    DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2  CHAR(5);
    DEFINE cCodRet3  CHAR(50);
    DEFINE cNumCte CHAR(9);
    DEFINE cCuenta CHAR(20);
    DEFINE iContador1 INTEGER;
    DEFINE iContador2 INTEGER;
    DEFINE cNombreArchivoImg CHAR(200);
    DEFINE cRutaArchivo CHAR(100);
    DEFINE cRutaArchivoImg CHAR(200);

    DEFINE cFecha_proceso   DATE;


    DEFINE cCodImgLeSP CHAR(5);
    DEFINE cCodIntsImgSP CHAR(5);
    DEFINE cCodCarDoc CHAR(5);
    DEFINE cCodRetPDF   CHAR(5);

    LET iSqlErr    = 0;
    LET iSamErr    = 0;
    LET cDesErr    = 0;
    LET cCodRet    = '00000';
    LET cCodRet2   = '000';
    LET cCodRet3   = 'PROCESO FINALIZADO CORRECTAMENTE'; 
    LET cNumCte    = '';
    LET cCuenta    = '';
    LET iContador1 = 0;
    LET iContador2 = 0;

        LET cFecha_proceso = '';


    LET cRutaArchivo        = '/RESPALDOSNEW/DoctosCtaNvl2/';
    LET cNombreArchivoImg   = '';
    LET cRutaArchivoImg     = '';
    LET cCodImgLeSP         = '';
    LET cCodIntsImgSP       = '';
    LET cCodCarDoc          = '';
    LET cCodRetPDF          = '';

    BEGIN

        ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
                SET DEBUG FILE TO '/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_valida_cuenta.err';
                TRACE ON;
            IF iSqlerr <> 0 THEN
                LET cCodRet  = iSqlErr;
                LET cCodRet2 = iSamErr;
                LET cCodRet3 = cDesErr;
                RETURN cCodRet, cCodRet2, cCodRet3, iContador1, iContador2;
            END IF;
        END EXCEPTION;
	--- DESCOMENTAR CUANDO SE REALICEN PRUEBAS 
    --SET DEBUG FILE TO '/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_valida_cuenta.out';
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH WITH HOLD

        SELECT --{+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
        numcte, cuenta, fecha_proceso
        INTO cNumCte, cCuenta, cFecha_proceso
        FROM bdinteg:"informix".si_tab_control_n2
        WHERE estatus = '0'
        ORDER BY cuenta
        
        LET iContador1 = iContador1 + 1;

        LET cRutaArchivoImg = TRIM(cRutaArchivo)||'caratulasPDF/imagenes';
        LET cNombreArchivoImg = TRIM(cNumCte)||'_'|| TRIM(cCuenta)||'.txt';
        LET cNombreArchivoImg = TRIM(cNombreArchivoImg);

        
        ---------------------- SP GENERA DOCUMENTO Y ENVIA POR CORREO --------------------------------------------
        EXECUTE PROCEDURE bdinteg:sp_ctanvl2_generapdf(cNumCte, cCuenta)
        INTO cCodRetPDF;        
        IF cCodRetPDF = '000' THEN
            UPDATE {+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
              bdinteg:"informix".si_tab_control_n2
            SET estatus_documento = '1',
            cod_err_doc = cCodRetPDF
            WHERE cuenta = cCuenta;
        ELSE
          UPDATE {+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
            bdinteg:"informix".si_tab_control_n2
            SET estatus_documento = '0',
            estatus = '0',
            cod_err_doc = cCodRetPDF
            WHERE cuenta = cCuenta;
            LET iContador2 = iContador2 + 1;
            CONTINUE FOREACH;
        END IF;


        ---------- LEE LOS ARCHIVOS TXT DE LOS DOUMENTOS A PROCESAR  --------------------------------------------
       EXECUTE PROCEDURE bdinteg:"informix".sp_insertarimgleerarchivo(cRutaArchivoImg, cNombreArchivoImg) 
       INTO cCodImgLeSP;

        IF cCodImgLeSP = '00000'  THEN
          UPDATE {+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
            bdinteg:"informix".si_tab_control_n2
            SET estatus_leearimg = '1',
            cod_err_leearimg = cCodImgLeSP
            WHERE cuenta = cCuenta;
        ELSE 
          UPDATE {+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
            bdinteg:"informix".si_tab_control_n2
            SET estatus_leearimg = '0',
            estatus = '0',
            cod_err_leearimg = cCodImgLeSP
            WHERE cuenta = cCuenta;
            LET iContador2 = iContador2 + 1;
            CONTINUE FOREACH;
        END IF;
 

        --------------- GENERA LA ESTUCTURA EN LA TABLA GBEXPEDIENTE Y DGEXPEDIENTEIMG DE LA BASE DE DATOS BDIDIGITAL -----------
        EXECUTE PROCEDURE bdinteg:"informix".sp_insertarimg1(cNumCte, cCuenta, '2900') 
        INTO cCodIntsImgSP;

        IF cCodIntsImgSP = '00000' THEN
          UPDATE {+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
            bdinteg:"informix".si_tab_control_n2
            SET estatus_strimg = '1',
            cod_err_strimg = cCodIntsImgSP
            WHERE cuenta = cCuenta;
        ELSE 
          UPDATE {+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
            bdinteg:"informix".si_tab_control_n2
          SET estatus_strimg = '0',
          estatus = '0',
          cod_err_strimg = cCodIntsImgSP
          WHERE cuenta = cCuenta;
          LET iContador2 = iContador2 + 1;
          CONTINUE FOREACH;
        END IF;


        ------------------ LLAMA AL JAR QUE CONSUME AL BUS PARA PODER DIGITALIZAR ------------------------
        EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_carga_doc(cNumCte, cCuenta)
        INTO cCodCarDoc;
		
        IF cCodCarDoc = '000' THEN
          UPDATE {+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
            bdinteg:"informix".si_tab_control_n2
            SET estatus_digitalizacion = '1',
            cod_err_dig = cCodCarDoc
            WHERE cuenta = cCuenta;
        ELSE 
          UPDATE {+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
            bdinteg:"informix".si_tab_control_n2
          SET estatus_digitalizacion  = '0',
          estatus = '0',
          cod_err_dig = cCodCarDoc
          WHERE cuenta = cCuenta;
          LET iContador2 = iContador2 + 1;
          CONTINUE FOREACH;
        END IF;


        ------------- SE ENCARGA DE VALIDAR SI SE PROCESARON CORRECTAMENTE TODOSO LOS SPÂ´s ---------------------------
        IF cCodRetPDF = '000' AND cCodImgLeSP = '00000' AND cCodIntsImgSP = '00000' AND cCodCarDoc = '000' THEN

          UPDATE {+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
          bdinteg:"informix".si_tab_control_n2
          SET estatus = '1',
          fecha_proceso = cFecha_proceso,
          cod_err_doc = cCodRetPDF
          WHERE cuenta = cCuenta;

          DELETE FROM si_tab_con_cuentas_n2 WHERE cliente = cNumCte and cuenta = cCuenta;

        ELSE
            UPDATE {+INDEX (bdinteg:"informix".si_tab_control_n2 "informix".idx_tab_control_n2 )}
            bdinteg:"informix".si_tab_control_n2
            SET estatus = '0',
            fecha_proceso = cFecha_proceso
            WHERE cuenta = cCuenta;

            LET iContador2 = iContador2 + 1;
            CONTINUE FOREACH;
        END IF;
        

        LET cNumCte    = '';
        LET cCuenta    = '';
        LET cCodRetPDF = '';
        
    END FOREACH;

    RETURN cCodRet, cCodRet2, cCodRet3, iContador1, iContador2;

    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 29/05/2024',
'DESCRIPCION: Procedimiento almacenado encargado de volver a procesar las cuentas registradas en estatus 0 de la tabla de control',
'BD: bdinteg',
'AUTOR: JosÃ© Alfredo Rosete Mazahua',
'FECHA: 15/06/2024',
'DESCRIPCION: se mejora agregando CONTINUE FOREACH ',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_ctanvl2_valida_dig()
    RETURNING CHAR(5) as codret,
              CHAR(5) as codret2,
              CHAR(50)as cCodRet3;

    DEFINE iSqlErr            INTEGER;
    DEFINE iSamErr            INTEGER;
    DEFINE cDesErr            CHAR(50);
    DEFINE cCodRet            CHAR(5);
    DEFINE cCodRet2           CHAR(5);
    DEFINE cCodRet3           CHAR(50);
    DEFINE cNumcte            CHAR(20);
    DEFINE cCuenta            CHAR(20);
    DEFINE iSecuencia         INTEGER;
    DEFINE iNumExpedientes    INTEGER;
    DEFINE iNumExpedientes2   INTEGER;
    DEFINE bImagen BLOB;
    DEFINE cCoddocto          CHAR(5);
    DEFINE iCerrar            SMALLINT;
    DEFINE cRango_d_fecha     DATE;
    DEFINE dtFechaAnt         DATE;
    DEFINE pEmpresa           CHAR(3);
    DEFINE dtFechaHoy         DATE;


    DEFINE  vrango_fecha       INTEGER;
    LET     vrango_fecha       = 0;

    LET iSqlErr          = 0;
    LET iSamErr          = 0;
    LET cDesErr          = 0;
    LET cCodRet          = '00000';
    LET cCodRet2         = '000';
    LET cCodRet3         = 'PROCESO FINALIZADO CORRECTAMENTE'; 
    LET cNumCte          = '';
    LET cCuenta          = '';
    LET bImagen          = NULL;
    LET iNumExpedientes  = 0;
    LET iNumExpedientes2 = 0;
    LET iSecuencia       = 0;
    LET cCoddocto        = '';
    LET iCerrar          = 0;
    LET dtFechaAnt       = '';
    LET dtFechaHoy       = '';
    LET pEmpresa         = '001';


    BEGIN

        ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
                SET DEBUG FILE TO '/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_valida_dig.err';
                TRACE ON;
            IF iSqlerr <> 0 THEN
                LET cCodRet  = iSqlErr;
                LET cCodRet2 = iSamErr;
                LET cCodRet3 = cDesErr;
                RETURN cCodRet, cCodRet2, cCodRet3;
            END IF;
        END EXCEPTION;

    --SET DEBUG FILE TO '/RESPALDOSNEW/Alfredo/reingenieria/sp_ctanvl2_valida_dig.out';
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

    SELECT valor
    INTO vrango_fecha
    FROM  bdinteg:si_param
    WHERE cod_param = 543;

    SET EXPLAIN ON;
    SELECT fecha_hoy, fecha_ant
    INTO dtFechaHoy, dtFechaAnt
    FROM bdicheq:sc_fechas 
    WHERE empresa = pEmpresa;

    -- ESTA FECHA SE DESCOMENTA SOLO CUANDO SE HACEN PRUEBAS 
    --LET cRango_d_fecha = '07092024';

    LET cRango_d_fecha = dtFechaHoy-vrango_fecha;

    ---LET cRango_d_fecha = '07092024';
    
    FOREACH WITH HOLD

        SELECT numcte,cuenta
        INTO cNumcte, cCuenta
        FROM bdinteg:"informix".si_tab_control_n2
        WHERE fecha_proceso BETWEEN cRango_d_fecha and dtFechaHoy
        
        LET iCerrar = 0; 

        FOREACH
            --Se obtienen los cod_docto de la secuencia maxima
            SELECT cod_docto, MAX(secuencia)
            INTO  cCoddocto, iSecuencia 
            FROM bdidigital@coppelimg_crx:dg_expediente_img1
            WHERE cod_docto IN ('0166', '0167', '0168')
            AND empresa = '001'
            AND cliente = cNumCte 
            AND secuencia = (SELECT MAX(secuencia)
                            FROM bdidigital@coppelimg_crx:dg_expediente_img1
                            WHERE cod_docto IN ('0166', '0167', '0168')
                            AND empresa = '001'
                            AND cliente = cNumCte)
            GROUP BY cod_docto 

            --Y valida de la consulta anterior cuandos registros tiene esa secuencia maxima
            SELECT count(*)
            INTO iNumExpedientes
            FROM bdidigital@coppelimg_crx:dg_expediente_img1
            WHERE cod_docto IN ('0166', '0167', '0168')
            AND empresa = '001'
            AND cliente = cNumCte
            AND secuencia = iSecuencia;

            --Si son igual a tres registros '0166', '0167', '0168'
            IF iNumExpedientes = 3 AND iCerrar = 0  THEN 
                    SELECT imagen 
                    INTO bImagen
                    FROM bdidigital@coppelimg_crx:dg_expediente_img1
                    WHERE cod_docto = cCoddocto
                    AND secuencia = iSecuencia 
                    AND cliente = cNumCte;
                
                --Valida que la imagen de alguno de los 3 no venga en nulo
                IF bImagen IS NULL THEN 
                     --si viene la imagen en nulo de cualquiera de los codigo se borra la info relacionado a esa secuencia.
                     DELETE FROM bdidigital@coppelimg_crx:dg_expediente_img1 WHERE secuencia = iSecuencia  AND cod_docto IN ('0166', '0167', '0168') AND cliente = cNumCte;
                     DELETE FROM bdidigital@coppelimg_crx:dg_expediente WHERE secuencia = iSecuencia AND cod_docto IN ('0166', '0167', '0168') AND cliente = cNumcte AND producto = '2900';

                    UPDATE bdinteg:"informix".si_tab_control_n2 SET estatus = '0'
                    WHERE numcte = cNumCte and cuenta = cCuenta;

                    INSERT INTO bdinteg:si_tab_con_cuentas_n2 (cliente, cuenta, fecha_proceso)
                    VALUES (cNumCte, cCuenta, dtFechaHoy);

                    --Evitamos que entre nuevamente al eliminar ya que ya fueron eliminados todos de esa secuencia
                    LET iCerrar = 1;                    
                END IF;
            --Si son menores los registros '0166', '0167'
            ELIF iNumExpedientes < 3  AND iCerrar = 0 THEN 
                    --si alguno de los cod_docto no esta en automico borra todo
                    DELETE FROM bdidigital@coppelimg_crx:dg_expediente_img1 WHERE secuencia = iSecuencia  
                    AND cod_docto IN ('0166', '0167', '0168') AND cliente = cNumCte;

                    DELETE FROM bdidigital@coppelimg_crx:dg_expediente WHERE secuencia = iSecuencia 
                    AND cod_docto IN ('0166', '0167', '0168') AND cliente = cNumcte AND producto = '2900';

                    UPDATE bdinteg:"informix".si_tab_control_n2 SET estatus = '0'
                    WHERE numcte = cNumCte and cuenta = cCuenta;

                    INSERT INTO bdinteg:si_tab_con_cuentas_n2 (cliente, cuenta, fecha_proceso)
                    VALUES (cNumCte, cCuenta, dtFechaHoy);

                    LET iCerrar = 1;  
            --Si mayores a tres registros '0166', '0167', '0168' y las imagenes son nulas que se borren todos relacionados a esa secuencia
            ELIF iNumExpedientes > 3 THEN

                Select count(cod_docto) as num_doc
                INTO iNumExpedientes2
                from bdidigital@coppelimg_crx:dg_expediente_img1
                WHERE cod_docto in ( '0166','0167','0168')
                and imagen is null
                AND cliente = cNumCte
                AND secuencia = iSecuencia;

                    IF iNumExpedientes2 > 0 THEN 
                        DELETE FROM bdidigital@coppelimg_crx:dg_expediente_img1 WHERE cod_docto IN ('0166', '0167', '0168')  AND cliente = cNumcte AND secuencia = iSecuencia; 
                        DELETE FROM bdidigital@coppelimg_crx:dg_expediente WHERE cod_docto IN ('0166', '0167', '0168')  AND cliente = cNumcte AND secuencia = iSecuencia; 

                        UPDATE bdinteg:"informix".si_tab_control_n2 SET estatus = '0'
                        WHERE numcte = cNumCte and cuenta = cCuenta;

                        INSERT INTO bdinteg:si_tab_con_cuentas_n2 (cliente, cuenta, fecha_proceso)
                        VALUES (cNumCte, cCuenta, dtFechaHoy);

                    END IF;
            END IF;
        END FOREACH

    END FOREACH;

    RETURN cCodRet, cCodRet2, cCodRet3;

    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 29/05/2024',
'DESCRIPCION: Procedimiento almacenado encargado de validar que el dato en BLOB de la imagen no se encuentre nulo',
'en caso contrario eliminar los registros de la dg_expediente y dg_expediente_img1 para que la cuenta sea reprocesada', 
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_ctanvl2_validar_cuentas_duplicadas()
    RETURNING CHAR(5) AS codret, 
              CHAR(5) AS CodRet2, 
              CHAR(50) AS CodRet3, 
              INTEGER AS Contador1,
              INTEGER AS Contador2;

    DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
    DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
    DEFINE cNumCte CHAR(9);
    DEFINE cCuenta CHAR(20);
    DEFINE iContador1 INTEGER;
    DEFINE iContador2 INTEGER;
    DEFINE cCuentaDuplicada INTEGER;
    DEFINE dias_a_procesar INTEGER;

    LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = 0;
    LET cCodRet = '00000';   -- CÃ³digo de retorno en caso de Ã©xito
    LET cCodRet2 = '000';
    LET cCodRet3 = 'PROCESO FINALIZADO CORRECTAMENTE'; 
    LET iContador1 = 0;
    LET iContador2 = 0;
    LET cCuentaDuplicada = 0;
    LET dias_a_procesar = 5;

    BEGIN

        -- ConfiguraciÃ³n de excepciones para el manejo de errores
       ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
            SET DEBUG FILE TO '/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_validar_cuentas_duplicadas.err';
            TRACE ON;
        
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                LET cCodRet2 = iSamErr;
                LET cCodRet3 = cDesErr;
                RETURN cCodRet, cCodRet2, cCodRet3, iContador1, iContador2;
            END IF;
            
        END EXCEPTION;

        --SET DEBUG FILE TO '/RESPALDOSNEW/Alfredo/reingenieria/sp_ctanvl2_validar_cuentas_duplicadas.out';
        --TRACE ON;


        -- ConfiguraciÃ³n de la transacciÃ³n
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        -- Procedimiento para contar las cuentas duplicadas
        FOREACH WITH HOLD

            SELECT cuenta, COUNT(*) INTO cCuenta, cCuentaDuplicada
            FROM bdinteg:si_tab_con_cuentas_n2
            GROUP BY cuenta
            HAVING COUNT(*) >= dias_a_procesar -- Selecciona cuentas con 5 o mÃ¡s duplicados

            LET iContador1 = iContador1 + 1;

            -- Si se encuentra una cuenta duplicada mÃ¡s de 5 veces, se emite un cÃ³digo de error
            IF cCuentaDuplicada >= dias_a_procesar THEN
                LET cCodRet = '00001';  -- Error por cuentas duplicadas
                LET cCodRet2 = 'ERROR';
                LET cCodRet3 = 'Cuenta duplicada mÃ¡s de 5 veces: ' || cCuenta;
                RETURN cCodRet, cCodRet2, cCodRet3, iContador1, iContador2;
            END IF;

         END FOREACH;

        -- Si no se encontraron cuentas con 5 o mÃ¡s duplicados, se retorna cÃ³digo de Ã©xito
        LET cCodRet = '00000';  -- Todo estÃ¡ correcto
        LET cCodRet2 = 'EXITO';
        LET cCodRet3 = 'No se encontraron errores';

        -- Retornar el resultado
    RETURN cCodRet, cCodRet2, cCodRet3, iContador1, iContador2;

    END; 
END PROCEDURE;