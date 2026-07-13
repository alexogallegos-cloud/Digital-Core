CREATE PROCEDURE "informix".sp_altamasivaempnet_registra_pba( pEmpresa CHAR(3), pNumCteMoral CHAR(20), pEjecutivo CHAR(8), pNomArchivo CHAR(30) )
RETURNING CHAR(5), CHAR(100);
    
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE iDescErr				CHAR(50);
    DEFINE cCodRet 				CHAR(5);
    DEFINE cCodRet2				CHAR(5);
    DEFINE cCodRet3				CHAR(50);
    DEFINE cCodRetRfc	        CHAR(6);
    DEFINE cCodRetCte	        CHAR(5);
    DEFINE cCodRetDir	        CHAR(5);
    DEFINE cCodRetCta	        CHAR(5);
    DEFINE cMensaje				VARCHAR(100);
    DEFINE iBegin				INTEGER;
    
    DEFINE dFechaHoy 			DATE;
    DEFINE iExiste				INTEGER;
    DEFINE cProducto 			CHAR(4);
    DEFINE cTipoPersona			CHAR(2);
    DEFINE cTipoCliente			CHAR(1);
    DEFINE cSucursal            CHAR(4);
    DEFINE cNumEmpresa			CHAR(3);
    DEFINE cNumEmpleado			CHAR(30);
    DEFINE cNombre1				CHAR(30);
    DEFINE cNombre2				CHAR(30);
    DEFINE cApellPatern			CHAR(30);
    DEFINE cApellMatern			CHAR(30);
    DEFINE cFecNac 				CHAR(8);
    DEFINE cRFC 				CHAR(13);
    DEFINE cSexo 				CHAR(1);
    DEFINE cTipoId              CHAR(1);
    DEFINE cNumId               CHAR(30);
    DEFINE cCalle               CHAR(30);
    DEFINE iNoExt               INTEGER;
    DEFINE iNoInt               INTEGER;
    DEFINE cColonia             CHAR(30);
    DEFINE cDelMun              CHAR(30);
    DEFINE cCiudad              CHAR(30);
    DEFINE cEstado              CHAR(30);
    DEFINE cCodPos              CHAR(10);
    DEFINE cPais                CHAR(4);
    DEFINE cRFCGenerado			CHAR(13);
    DEFINE cNumCliente			CHAR(20);
    DEFINE sSecuencia           SMALLINT;
    DEFINE vcCalle              CHAR(40);
    DEFINE vcColonia            CHAR(60);
    DEFINE vcMunicipio          CHAR(5);
    DEFINE vcEntreCalles        CHAR(40);
    DEFINE vcPais               CHAR(3);
    DEFINE vcEstado             CHAR(2);
    DEFINE vcCiudad             CHAR(3);
    DEFINE vcCod_post           CHAR(5);
    DEFINE vcTipoTel1           CHAR(1);
    DEFINE vcTel1               CHAR(13);
    DEFINE vcTipoTel2           CHAR(1);
    DEFINE vcTel2               CHAR(13);
    DEFINE vcTipoTel3           CHAR(1);
    DEFINE vcTel3               CHAR(13);
    DEFINE vcExtension          CHAR(5);
    DEFINE vcEdo_inegi          CHAR(2);
    DEFINE vcMuni_iegi          CHAR(3);
    DEFINE vcLocal_inegi        CHAR(4);
    DEFINE vsNumCiudad          SMALLINT;
    DEFINE vcNumExtCalle        CHAR(10);
    DEFINE vcNumIntCalle        CHAR(10);
    DEFINE vcDepto              CHAR(6);
    DEFINE viNumCalle           INTEGER;
    DEFINE viNumColonia         INTEGER;
    DEFINE vcPtoCardinal        CHAR(1);
    DEFINE vcUnidad_habit       CHAR(1);
    DEFINE vsManzana            SMALLINT;
    DEFINE vsOtros              SMALLINT;
    DEFINE vsAndador            SMALLINT;
    DEFINE vsEtapa              SMALLINT;
    DEFINE vsLote               SMALLINT;
    DEFINE vsEdificio           SMALLINT;
    DEFINE vsEntrada            SMALLINT;
    DEFINE vcObserva            CHAR(80);
    DEFINE cNumCuenta			CHAR(20);
    DEFINE cCtaClaBe 			CHAR(20);
    DEFINE viRegProcesados      INTEGER;
    DEFINE viRegxProcesar       INTEGER;
    DEFINE dFecNac              DATE;
    DEFINE cCuentaMoral         CHAR(20);
        
    LET iSqlErr		= 0;
    LET iIsamErr	= 0;
    LET iDescErr	= '';
    LET cCodRet 	= '00000';
    LET cCodRet2 	= '';
    LET cCodRet3 	= '';
    LET cCodRetRfc	= '';
    LET cCodRetCte	= '';
    LET cCodRetDir	= '';
    LET cCodRetCta	= '';
    LET cMensaje    = '';
    LET iBegin      = 0;
    
    LET dFechaHoy       = '';
    LET iExiste	        = 0;
    LET cProducto       = '';
    LET cTipoPersona    = '';
    LET cTipoCliente    = '';
    LET cSucursal       = '';
    LET cNumEmpresa     = '';
    LET cNumEmpleado    = '';
    LET cNombre1        = '';
    LET cNombre2        = '';
    LET cApellPatern    = '';
    LET cApellMatern    = '';
    LET cFecNac         = '';
    LET cRFC            = '';
    LET cSexo           = '';
    LET cTipoId         = '';
    LET cNumId          = '';
    LET cCalle          = '';
    LET iNoExt          = 0;
    LET iNoInt          = 0;
    LET cColonia        = '';
    LET cDelMun         = '';
    LET cCiudad         = '';
    LET cEstado         = '';
    LET cCodPos         = '';
    LET cPais           = '';
    LET cRFCGenerado    = '';
    LET cNumCliente     = '';
    LET sSecuencia      = 0;
    LET vcCalle         = '';
    LET vcColonia       = '';
    LET vcMunicipio     = '';
    LET vcEntreCalles   = '';
    LET vcPais          = '';
    LET vcEstado        = '';
    LET vcCiudad        = '';
    LET vcCod_post      = '';
    LET vcTipoTel1      = '';
    LET vcTel1          = '';
    LET vcTipoTel2      = '';
    LET vcTel2          = '';
    LET vcTipoTel3      = '';
    LET vcTel3          = '';
    LET vcExtension     = '';
    LET vcEdo_inegi     = '';
    LET vcMuni_iegi     = '';
    LET vcLocal_inegi   = '';
    LET vsNumCiudad     = 0;
    LET vcNumExtCalle   = '';
    LET vcNumIntCalle   = '';
    LET vcDepto         = '';
    LET viNumCalle      = 0;
    LET viNumColonia    = 0;
    LET vcPtoCardinal   = '';
    LET vcUnidad_habit  = '';
    LET vsManzana       = 0;
    LET vsOtros         = 0;
    LET vsAndador       = 0;
    LET vsEtapa         = 0;
    LET vsLote          = 0;
    LET vsEdificio      = 0;
    LET vsEntrada       = 0;
    LET vcObserva       = '';
    LET cNumCuenta      = '';
    LET cCtaClaBe       = '';
    LET viRegProcesados = 0;
    LET viRegxProcesar  = 0;
    LET dFecNac         = '';
    LET cCuentaMoral    = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, iDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_registra.err";
        TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = iDescErr;
            LET cMensaje = 'OCURRIO UN ERROR NO CONTROLADO';
            IF iBegin = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, cMensaje;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_registra.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5; 
    
    -- // OBTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy 
      INTO dFechaHoy 
      FROM bdinteg:si_fechas 
     WHERE empresa = '001';
     
    -- // VALIDA REGISTROS A PROCESAR
    SELECT COUNT(*)
      INTO iExiste 
      FROM bdinteg:si_altamasivaempnet_ctrl 
     WHERE cod_empresa = pEmpresa
       AND nombre_archivo = pNomArchivo
       AND status = '1'; 

    IF iExiste IS NULL OR iExiste = '' OR iExiste = 0 THEN
        LET cCodRet = '00001';
        LET cMensaje = 'NO EXISTEN REGISTROS A PROCESAR';
        RETURN cCodRet, cMensaje;
    END IF;
    
    -- // VALIDA LA PERSONA MORAL
    SELECT COUNT(cte.numcte)
      INTO iExiste
      FROM bdinteg:si_cliente cte
     INNER JOIN bdinteg:si_tipper tpo ON cte.tpo_persona = tpo.tpo_persona
     WHERE cte.empresa = '001'
       AND cte.numcte = pNumCteMoral
       AND tpo.es_fisica = "N";
    
    IF iExiste = 0 THEN
        LET cCodRet = "00002";
        RETURN cCodRet, cMensaje;
    END IF;
    
    -- // OBTIENE PARAMETROS PARA EL ALTA
    SELECT TRIM(acepta_producto), cuenta
      INTO cProducto, cCuentaMoral
      FROM bdicheq:sc_nominaempresas 
     WHERE codigo = pEmpresa;
     
    SELECT tpo_persona 
      INTO cTipoPersona 
      FROM bdinteg:si_tipper 
     WHERE tpo_persona = '01';
     
    SELECT tipo_cliente 
      INTO cTipoCliente 
      FROM bdinteg:si_tipocte 
     WHERE empresa = '001' 
       AND tipo_cliente = 2;
       
    SELECT sucursal
      INTO cSucursal
      FROM bdicheq:sc_maechq
     WHERE empresa = '001'
       AND cuenta = cCuentaMoral;
       
    IF cSucursal is null OR cSucursal = '' THEN
        SELECT TRIM(valor) 
          INTO cSucursal 
          FROM bdicheq:sc_param 
         WHERE codparam = 'AMSUCURSAL' 
           AND empresa = '001';
    END IF;

    -- // VALIDA PARAMETROS ENCONTRADOS PARA EL ALTA
    IF cProducto IS NULL OR cTipoPersona IS NULL OR cTipoCliente IS NULL OR cSucursal IS NULL THEN
        LET cCodRet = '00002';
        LET cMensaje = 'NO SE OBTUVIERON LOS PARÁMETROS NECESARIOS';
        RETURN cCodRet, cMensaje;
    END IF;
    
    SELECT COUNT(*)
      INTO viRegxProcesar
      FROM bdinteg:si_altamasivaempnet_det
     WHERE cod_empresa = pEmpresa
       AND nombre_archivo = pNomArchivo
       AND status = '0';
    
    -- // CONSULTA LAS PETICIONES DE APERTURAS DE NÓMINA PARA QUE SEAN PROCESADAS
    FOREACH WITH HOLD
        SELECT cod_empresa, cve_cte, nombre1, nombre2, ape_pat, ape_mat, fecha_nac, rfc, genero, 
               tipo_id, num_id, calle, no_ext, no_int, colonia, del_mun, ciudad, estado, cod_pos, pais 
          INTO cNumEmpresa, cNumEmpleado, cNombre1, cNombre2, cApellPatern, cApellMatern, cFecNac, cRFC, cSexo, 
               cTipoId, cNumId, cCalle, iNoExt, iNoInt, cColonia, cDelMun, cCiudad, cEstado, cCodPos, cPais 
          FROM bdinteg:si_altamasivaempnet_det
         WHERE cod_empresa = pEmpresa
           AND nombre_archivo = pNomArchivo
           AND status = '0'

        BEGIN WORK;
        LET iBegin = 1;
        
        LET dFecNac = SUBSTR(cFecNac,3,2)||SUBSTR(cFecNac,1,2)||SUBSTR(cFecNac,5,4);
        
        IF cNombre2 is null THEN
            LET cNombre2 = '';
        END IF;
        
        IF cApellMatern is null THEN
            LET cApellMatern = '';
        END IF;
        
        -- // CALCULA EL RFC
        CALL bdinteg:sp_calcularfc( '001', cApellPatern, cApellMatern, cNombre1, cNombre2, dFecNac ) 
        RETURNING cCodRetRfc, cMensaje, cRFCGenerado;
        
        IF cCodRetRfc <> '000000' THEN
            LET cCodRet = '00003';
            LET cMensaje = 'FALLÓ EN EL PROCESO AL INTENTAR LA GENERACIÓN DE RFC';
            ROLLBACK WORK;
            LET iBegin = 0;
            CONTINUE FOREACH;
        END IF;
        
        -- // VALIDA QUE EL GENERADO SEA IGUAL AL QUE RECIBIMOS POR EL CLIENTE, SI NO SE TOMA EL QUE NOSOTROS GENERAMOS
        IF TRIM(cRFC) <> TRIM(cRFCGenerado) THEN
            LET cRFC = cRFCGenerado;
        END IF;
        
        -- // ALTA DEL CLIENTE
        EXECUTE PROCEDURE ctefisico( '001',         --- empresa
                                     'A',           --- tipo de funcion
                                     '',            --- no. cliente
                                     cSucursal,     --- sucursal
                                     pEjecutivo,    --- ejecutivo
                                     cTipoPersona,  --- tpo. persona
                                     cTipoCliente,  --- tpo. cliente
                                     cApellPatern,  --- apell. paterno
                                     cApellMatern,  --- apell. materno
                                     cNombre1,      --- nombre 1
                                     cNombre2,      --- nombre 2
                                     cRfc,          --- rfc
                                     '32',          --- sector
                                     '000',         --- segmento
                                     '',            --- actividad
                                     '000',         --- grupo
                                     '000',         --- subgrupo
                                     '1',           --- residencia
                                     '',            --- apell casada
                                     '',            --- no. cte ref
                                     '01',          --- distrito
                                     '',            --- puesto pol exp
                                     '',            --- familiar pol exp
                                     '00000000000', --- actividad esp
                                     dFecNac,       --- fecha nac
                                     '',            --- lugar nac
                                     '001',         --- nacionalidad
                                     '',            --- fm3
                                     '',            --- edo civil
                                     '',            --- regimen mat
                                     '11',          --- profesion
                                     cSexo,         --- sexo
                                     '',            --- curp
                                     cTipoId,       --- cod identificacion
                                     cNumId,        --- no. identificacion
                                     '',            --- no imss
                                     0,             --- dependientes
                                     '',            --- tutor
                                     '',            --- email
                                     '',            --- nom conyuge
                                     '0',           --- seguro def
                                     '',            --- escolaridad
                                     'P',           --- habita en
                                     0,             --- anios hanita
                                     '',            --- nombre prop
                                     0,             --- imp hip renta
                                     '',            --- no. ife
                                     '',            --- no. tutor
                                     '',            --- no. conyuge
                                     USER,          --- autoriza
                                     '',            --- promocion
                                     '' )           --- no. habitantes
        INTO cCodRetCte, cNumCliente;

        IF cCodRetCte <> '000' THEN
            LET cCodRet = "00005";
            LET cMensaje = "Error al dar de alta al cliente.";
            ROLLBACK WORK;
            LET iBegin = 0;
            CONTINUE FOREACH;
        END IF;
        
        -- // GUARDA DIRECCION DEL CLIENTE (TRABAJO)
        SELECT MAX(secuencia)
          INTO sSecuencia
          FROM bdinteg:si_direcciones_actual
         WHERE numcte = pNumCteMoral;
        
        IF sSecuencia IS NULL THEN
            LET cCodRet = "00004";
            LET cMensaje = "No existe dirección para el cliente moral indicado.";
            ROLLBACK WORK;
            LET iBegin = 0;
            CONTINUE FOREACH;
        END IF;
        
        SELECT dir.calle, dir.colonia, dir.municipio, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.cod_postal,
               tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono, tel3.tipo_tel, tel3.telefono, tel3.extension,
               dir.estado_inegi, dir.municipio_inegi, dir.localidad_inegi, dir.numerociudad, dir.numeroextcalle, dir.numerointcalle,
               dir.departamento, dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana,
               dir.otros, dir.andador, dir.etapa, dir.lote, dir.edificio, dir.entrada, dir.observaciones
          INTO vcCalle, vcColonia, vcMunicipio, vcEntreCalles, vcPais, vcEstado, vcCiudad, vcCod_post,
               vcTipoTel1, vcTel1, vcTipoTel2, vcTel2, vcTipoTel3, vcTel3, vcExtension,
               vcEdo_inegi, vcMuni_iegi, vcLocal_inegi, vsNumCiudad, vcNumExtCalle, vcNumIntCalle,
               vcDepto, viNumCalle, viNumColonia, vcPtoCardinal, vcUnidad_habit, vsManzana,
               vsOtros, vsAndador, vsEtapa, vsLote, vsEdificio, vsEntrada, vcObserva
          FROM bdinteg:si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
         WHERE dir.numcte = pNumCteMoral
           AND dir.secuencia = sSecuencia;
        
        EXECUTE PROCEDURE direcciones( '001',           --- empresa
                                       'A',             --- tpo funcion
                                       cNumCliente,     --- no. cliente
                                       0,               --- secuencia
                                       "3",             --- tipo dir
                                       vcCalle,         --- calle
                                       vcColonia,       --- colonia
                                       vcMunicipio,     --- municipio
                                       vcEntreCalles,   --- entre calles
                                       vcPais,          --- pais
                                       vcEstado,        --- entidad
                                       vcCiudad,        --- localidad
                                       vcCod_post,      --- cod postal
                                       vcTipoTel1,      --- tipo tel 1
                                       vcTel1,          --- telefono 1
                                       vcTipoTel2,      --- tipo tel 2
                                       vcTel2,          --- telefono 2
                                       vcTipoTel3,      --- tipo tel 3
                                       vcTel3,          --- telefono 3
                                       vcExtension,     --- extension
                                       vcEdo_inegi,     --- edo inegi
                                       vcMuni_iegi,     --- munic imegi
                                       vcLocal_inegi,   --- localid inegi
                                       vsNumCiudad,     --- no ciudad
                                       vcNumExtCalle,   --- no ext calle
                                       vcNumIntCalle,   --- no int calle
                                       vcDepto,         --- depto
                                       viNumCalle,      --- no calle
                                       viNumColonia,    --- no colonia
                                       vcPtoCardinal,   --- pto cardinal
                                       vcUnidad_habit,  --- unidad hab
                                       vsManzana,       --- manzana
                                       vsOtros,         --- otros
                                       vsAndador,       --- andador
                                       vsEtapa,         --- etapa
                                       vsLote,          --- lote
                                       vsEdificio,      --- edificio
                                       vsEntrada,       --- entrada
                                       vcObserva,       --- observaciones
                                       pejecutivo,      --- ejecutivo
                                       dFechaHoy,       --- fecha alta
                                       cSucursal )      --- sucursal
        INTO cCodRetDir;
        
        IF cCodRetDir <> '000' THEN
            LET cCodRet = "00006";
            LET cMensaje = "Error al registrar la dirección del cliente.";
            ROLLBACK WORK;
            LET iBegin = 0;
            CONTINUE FOREACH;
        END IF;
        
        -- // GUARDA DIRECCION DEL CLIENTE (PERSONAL)
        INSERT INTO bdinteg:si_altamasivaempnet_dircte
        (numcte, calle, no_ext, no_int, colonia, del_mun, ciudad, estado, cod_pos, pais)
        VALUES
        (cNumCliente, cCalle, iNoExt, iNoInt, cColonia, cDelMun, cCiudad, cEstado, cCodPos, cPais);
        
        -- // ALTA DE LA CUENTA DEL CLIENTE
        CALL bdicheq:cuenta2( '001',         --- empresa
                              pEjecutivo,    --- usuario
                              cSucursal,     --- sucursal
                              cProducto,     --- producto
                              cNumCliente,   --- no cliente
                              '02',          --- no cotitular
                              '1',           --- clase cta
                              '3',           --- reg firmas
                              '001',         --- tipo banca
                              pEjecutivo,    --- ejecutivo
                              '1',           --- envio direcc
                              '',            --- cuenta
                              0,             --- direcc envio
                              '',            --- cliente 2
                              '',            --- nombre 
                              '',            --- instrucc cap
                              '',            --- cuenta cap
                              '',            --- instrucc int
                              '',            --- cuenta int
                              0,             --- plazo
                              'N',           --- cobra isr
                              '02',          --- proc apert cta
                              '02',          --- proce mant cta
                              '01',          --- monto mensual
                              '01',          --- cantidad dep
                              '01',          --- monto dep
                              '01',          --- cantidad ret
                              '01',          --- monto ret
                              '',            --- forma apert
                              0.00,          --- monto apert
                              cNumEmpresa,   --- no. empleado 
                              cNumEmpleado ) --- no. nomina
        RETURNING cCodRetCta, cNumCuenta, cCtaClaBe;
        
        IF cCodRetCta = '000' THEN
            UPDATE bdinteg:si_altamasivaempnet_det
               SET numcte = cNumCliente, 
                   cuenta = cNumCuenta,
                   status = '1'
             WHERE cod_empresa = pEmpresa
               AND cve_cte = cNumEmpleado
               AND nombre_archivo = pNomArchivo;
               
            UPDATE bdinteg:si_cliente
               SET string1 = "2"
             WHERE empresa = pempresa
               AND numcte = cNumCliente;
               
            UPDATE bdicheq:sc_maechq
               SET marca_ret = '1'
             WHERE num_cte = cNumCliente
               AND cuenta = cNumCuenta;
               
            COMMIT WORK;
            LET iBegin = 0;
        ELSE
            ROLLBACK WORK;
            LET iBegin = 0;
            CONTINUE FOREACH;
        END IF;
    END FOREACH;
    
    SELECT COUNT(*)
      INTO viRegProcesados
      FROM bdinteg:si_altamasivaempnet_det
     WHERE cod_empresa = pEmpresa
       AND nombre_archivo = pNomArchivo
       AND status = '1';
       
    IF viRegProcesados = 0 THEN
        UPDATE bdinteg:si_altamasivaempnet_ctrl
           SET status = '2', --- NO SE PROCESO NINGUN CLIENTE
               fecha_aplicado = dFechaHoy,
               hora_aplicado = CURRENT HOUR TO SECOND,
               registros_aplic = 0
         WHERE cod_empresa = pEmpresa
           AND nombre_archivo = pNomArchivo;
    ELIF viRegProcesados < viRegxProcesar THEN
        UPDATE bdinteg:si_altamasivaempnet_ctrl
           SET status = '3', --- SE PROCESARON MENOS CLIENTES DEL TOTAL DEL ARCHIVO
               fecha_aplicado = dFechaHoy,
               hora_aplicado = CURRENT HOUR TO SECOND,
               registros_aplic = viRegProcesados
         WHERE cod_empresa = pEmpresa
           AND nombre_archivo = pNomArchivo;
    ELIF viRegProcesados = viRegxProcesar THEN
        UPDATE bdinteg:si_altamasivaempnet_ctrl
           SET status = '4', --- SE PROCESARON TODOS LOS CLIENTES DEL ARCHIVO
               fecha_aplicado = dFechaHoy,
               hora_aplicado = CURRENT HOUR TO SECOND,
               registros_aplic = viRegxProcesar
         WHERE cod_empresa = pEmpresa
           AND nombre_archivo = pNomArchivo;
    END IF;
    
    RETURN cCodRet, cMensaje;
    
    END;
    
END PROCEDURE;