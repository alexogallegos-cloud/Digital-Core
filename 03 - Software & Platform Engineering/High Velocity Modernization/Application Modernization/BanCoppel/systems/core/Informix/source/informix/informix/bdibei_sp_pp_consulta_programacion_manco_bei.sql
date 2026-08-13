CREATE PROCEDURE "informix".sp_pp_consulta_programacion_manco_bei(p_snum_cte CHAR(20), p_sid_operacion INTEGER)
    
    RETURNING CHAR(5),      --Código Retorno
              CHAR(250),    --Mensaje Retorno
              INTEGER,      --Id Operacion
              INTEGER,      --Id Usuario Solicita
              CHAR(20),     --Numero Cliente
              CHAR(30),     --Descripcion
              CHAR(2),      --Clave Pago
              CHAR(2),      --Clave Cuenta Origen
              CHAR(20),     --Numero Cuenta Origen
              CHAR(2),      --Clave Cuenta Destino
              CHAR(20),     --Numero Cuenta Destino
              CHAR(3),      --Banco Destino
              CHAR(40),     --Referencia 1
              CHAR(20),     --Referencia 2
              CHAR(5),      --Convenio
              MONEY(16,2),  --Importe
              CHAR(40),     --Referencia Cobranza
              MONEY(16,2),  --Importe IVA
              INTEGER,      --Tipo SPEI
              CHAR(60),     --Concepto
              DATE,         --Fecha Inicio
              CHAR(2),      --Clave Final
              INTEGER,      --Numero Repeticiones
              DATE,         --Fecha Fin
              CHAR(2),      --Clave Programa
              CHAR(2),      --Tipo Diaria
              INTEGER,      --Cada X Dia
              INTEGER,      --Cada X Semana
              CHAR(7),      --Dias Semana
              CHAR(2),      --Tipo Mensual
              INTEGER,      --Dia X Mes
              INTEGER,      --Cada X Meses
              CHAR(2),      --Clave Ocurre
              CHAR(2),      --Clave Dia
              CHAR(2),      --Clave Canal
              CHAR(2),      --Clave Notifica
              CHAR(40),     --Beneficiario Email
              CHAR(2),      --Beneficiario Clave Compania
              CHAR(10),     --Beneficiario Celular
              CHAR(2),      --Clave Notifica Emisor
              CHAR(40),     --Emisor Email
              CHAR(2),      --Emisor Clave Compania
              CHAR(10),     --Emisor Celular
              CHAR(100),    --Mensaje
              CHAR(2),      --Clave Estado
              CHAR(8),      --Usuario Inserta
              CHAR(60),     --Nombre beneficiario    
              INTEGER,      --Id Cat Operacion
              VARCHAR(100)  --Banco Receptor

    --Definicion de variables
    DEFINE v_sCodRet            CHAR(5);
    DEFINE v_sMensajeRet        CHAR(250);
    DEFINE v_sid_operacion      INTEGER;
    DEFINE v_sidusuariosol      INTEGER;
    DEFINE v_snumcte            CHAR(20);
    DEFINE v_sdescripcion       CHAR(30);
    DEFINE v_scvepago           CHAR(2);
    DEFINE v_scvectaori         CHAR(2);
    DEFINE v_snumctaori         CHAR(20);
    DEFINE v_scvectadest        CHAR(2);
    DEFINE v_snumctadest        CHAR(20);
    DEFINE v_sbancodest         CHAR(3);
    DEFINE v_sref1              CHAR(40);
    DEFINE v_sref2              CHAR(20);
    DEFINE v_sconvenio          CHAR(5);
    DEFINE v_simporte           MONEY(16,2);
    DEFINE v_srefcobranza       CHAR(40);
    DEFINE v_simporteiva        MONEY(16,2);
    DEFINE v_stipospei          INTEGER;
    DEFINE v_sconcepto          CHAR(60);
    DEFINE v_sfechainicio       DATE;
    DEFINE v_scvefinal          CHAR(2);
    DEFINE v_snumrepeteciones   INTEGER;
    DEFINE v_sfechafin          DATE;
    DEFINE v_scveprograma       CHAR(2);
    DEFINE v_stipodiaria        CHAR(2);
    DEFINE v_scadaxdia          INTEGER;
    DEFINE v_scadaxsemana       INTEGER;
    DEFINE v_sdiassemana        CHAR(7);
    DEFINE v_stipomensual       CHAR(2);
    DEFINE v_sdiaxmes           INTEGER;
    DEFINE v_scadaxmeses        INTEGER;
    DEFINE v_scveocurre         CHAR(2);
    DEFINE v_scvedia            CHAR(2);
    DEFINE v_scvecanal          CHAR(2);
    DEFINE v_scvenotifica       CHAR(2);
    DEFINE v_sbenemail          CHAR(40);
    DEFINE v_sbencvecompania    CHAR(2);
    DEFINE v_sbencelular        CHAR(10);
    DEFINE v_scvenotificaemi    CHAR(2);
    DEFINE v_semiemail          CHAR(40);
    DEFINE v_semicvecompania    CHAR(2);
    DEFINE v_semicelular        CHAR(10);
    DEFINE v_smensaje           CHAR(100);
    DEFINE v_scveestado         CHAR(2);
    DEFINE v_suserinsert        CHAR(8);
    DEFINE v_sbennombre         CHAR(60);
    DEFINE v_scatoperacion      INTEGER;
    DEFINE v_banco_receptor     VARCHAR(100);

    --Inicializacion de variables
    LET v_sCodRet = '';
    LET v_sMensajeRet = '';         
    LET v_sid_operacion = 0;
    LET v_sidusuariosol = 0;
    LET v_snumcte = '';
    LET v_sdescripcion = '';
    LET v_scvepago = '';
    LET v_scvectaori = '';
    LET v_snumctaori = '';
    LET v_scvectadest = '';
    LET v_snumctadest = '';
    LET v_sbancodest = '';
    LET v_sref1 = '';
    LET v_sref2 = '';
    LET v_sconvenio = '';
    LET v_simporte = 0.00;
    LET v_srefcobranza = '';
    LET v_simporteiva = 0.00;
    LET v_stipospei = 0;
    LET v_sconcepto = '';
    LET v_sfechainicio = '';
    LET v_scvefinal = '';
    LET v_snumrepeteciones = 0;
    LET v_sfechafin = '';
    LET v_scveprograma = '';
    LET v_stipodiaria = '';
    LET v_scadaxdia = 0;
    LET v_scadaxsemana = 0;
    LET v_sdiassemana = '';
    LET v_stipomensual = '';
    LET v_sdiaxmes = 0;
    LET v_scadaxmeses = 0;
    LET v_scveocurre = '';
    LET v_scvedia = '';
    LET v_scvecanal = '';
    LET v_scvenotifica = '';
    LET v_sbenemail = '';
    LET v_sbencvecompania = '';
    LET v_sbencelular = '';
    LET v_scvenotificaemi = '';
    LET v_semiemail = '';
    LET v_semicvecompania = '';
    LET v_semicelular = '';
    LET v_smensaje = '';
    LET v_scveestado = '';
    LET v_suserinsert = '';
    LET v_sbennombre = '';
    LET v_scatoperacion = 0;
    LET v_banco_receptor = '';

    --****************************************************************************************************
    -- DESCRIPCION: Se genera procedimiento de consulta de programacion de pago mancomunada por medio del 
    -- id de operacion y el numero de cliente.
    -- AUTOR : Jose Angel Hernandez Gonzalez - Solsersistem
    -- FECHA : 31/10/2016
    -- BD: bdibei
    -- SOLICITO :BanCoppel

    --SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET ISOLATION TO DIRTY READ;
      
    BEGIN
        SET LOCK MODE TO WAIT 10;
        
        --Se valida si el cliente existe
        IF EXISTS(SELECT empresa  FROM bdinteg:"informix".si_cliente WHERE numcte =  p_snum_cte) THEN
            
            IF EXISTS(
                        SELECT progmanco.idopermanco
                        FROM bdibei:"informix".bei_pp_progmanco AS progmanco
                        WHERE progmanco.idopermanco = p_sid_operacion 
                        AND progmanco.numcte = p_snum_cte
                    ) THEN

                SELECT 
                    NVL(progmanco.idopermanco,0), NVL(progmanco.idusuariosol,0), progmanco.numcte,
                    progmanco.descripcion, progmanco.cvepago, progmanco.cvectaori,
                    progmanco.numctaori, progmanco.cvectadest, progmanco.numctadest,
                    progmanco.bancodest, progmanco.ref1, progmanco.ref2,
                    progmanco.convenio, progmanco.importe, progmanco.refcobranza,
                    progmanco.importeiva, NVL(progmanco.tipospei,0), progmanco.concepto,
                    NVL(progmanco.fechainicio,''), progmanco.cvefinal, NVL(progmanco.numrepeteciones,0),
                    NVL(progmanco.fechafin,progmanco.fechainicio), progmanco.cveprograma, progmanco.tipodiaria,
                    NVL(progmanco.cadaxdia,0), NVL(progmanco.cadaxsemana,0), progmanco.diassemana,
                    progmanco.tipomensual, progmanco.diaxmes, progmanco.cadaxmeses,
                    progmanco.cveocurre, progmanco.cvedia, progmanco.cvecanal,
                    progmanco.cvenotifica, progmanco.benemail, progmanco.bencvecompania,
                    progmanco.bencelular, progmanco.cvenotificaemi, progmanco.emiemail,
                    progmanco.emicvecompania, progmanco.emicelular, progmanco.mensaje,
                    progmanco.cveestado, progmanco.userinsert, opermanco.nombre_beneficiario,opermanco.id_cat_operacion, 
                    NVL(opermanco.banco_receptor,'')
                INTO 
                    v_sid_operacion, v_sidusuariosol, v_snumcte,
                    v_sdescripcion, v_scvepago, v_scvectaori,
                    v_snumctaori, v_scvectadest, v_snumctadest,
                    v_sbancodest, v_sref1, v_sref2,
                    v_sconvenio, v_simporte, v_srefcobranza,
                    v_simporteiva, v_stipospei, v_sconcepto,
                    v_sfechainicio, v_scvefinal, v_snumrepeteciones,
                    v_sfechafin, v_scveprograma, v_stipodiaria,
                    v_scadaxdia, v_scadaxsemana, v_sdiassemana,
                    v_stipomensual, v_sdiaxmes, v_scadaxmeses,
                    v_scveocurre, v_scvedia, v_scvecanal,
                    v_scvenotifica, v_sbenemail, v_sbencvecompania,
                    v_sbencelular, v_scvenotificaemi, v_semiemail,
                    v_semicvecompania, v_semicelular, v_smensaje,
                    v_scveestado, v_suserinsert, v_sbennombre, v_scatoperacion, v_banco_receptor
                FROM bdibei:"informix".bei_pp_progmanco AS progmanco
                INNER JOIN  bdibei:"informix".bei_operacionesmancomunadasoperador AS opermanco
                    ON opermanco.id_operacion = p_sid_operacion
                WHERE progmanco.idopermanco = p_sid_operacion 
                AND progmanco.numcte = p_snum_cte;
                
                SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '00';
            ELSE
                SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '94';
            END IF;
        ELSE
            --Se informa que el cliente no existe
            SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '04';
            
        END IF;
        RETURN 
                v_sCodRet, v_sMensajeRet, v_sid_operacion,
                v_sidusuariosol, v_snumcte, v_sdescripcion, 
                v_scvepago, v_scvectaori, v_snumctaori, 
                v_scvectadest, v_snumctadest, v_sbancodest, 
                v_sref1, v_sref2, v_sconvenio, v_simporte, 
                v_srefcobranza, v_simporteiva, v_stipospei, 
                v_sconcepto, v_sfechainicio, v_scvefinal, 
                v_snumrepeteciones, v_sfechafin, v_scveprograma, 
                v_stipodiaria, v_scadaxdia, v_scadaxsemana, 
                v_sdiassemana, v_stipomensual, v_sdiaxmes, 
                v_scadaxmeses, v_scveocurre, v_scvedia, v_scvecanal,
                v_scvenotifica, v_sbenemail, v_sbencvecompania,
                v_sbencelular, v_scvenotificaemi, v_semiemail,
                v_semicvecompania, v_semicelular, v_smensaje,
                v_scveestado, v_suserinsert, v_sbennombre, v_scatoperacion, v_banco_receptor WITH RESUME;
    END;
END PROCEDURE;