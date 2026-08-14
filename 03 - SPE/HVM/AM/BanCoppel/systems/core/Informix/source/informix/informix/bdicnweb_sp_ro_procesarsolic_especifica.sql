CREATE PROCEDURE "informix".sp_ro_procesarsolic_especifica(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER)
                RETURNING CHAR(5) AS codret;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE iIdSolicitudEspecifica INTEGER;
        DEFINE iIdRowMinEspecifica INTEGER;
        DEFINE iIdRowMaxEspecifica INTEGER;
        DEFINE iIdRowMin INTEGER;
        DEFINE iIdRowMax INTEGER;
        DEFINE iIdRow INTEGER;
        DEFINE iIdMinRowInstruccionesXConocer INTEGER;
        DEFINE iIdMaxRowInstruccionesXConocer INTEGER;
        DEFINE iPersonaId INTEGER;
        DEFINE cCaracter CHAR(30);
        DEFINE cDescTipoPersona CHAR(10);
        DEFINE cApellidoPaterno CHAR(26);
        DEFINE cApellidoMaterno CHAR(26);
        DEFINE cNombre CHAR(150);
        DEFINE cRfc CHAR(15);
        DEFINE cRelacion CHAR(50);
        DEFINE cDomicilio CHAR(150);
        DEFINE cComplementarios CHAR(50);
        DEFINE cInstruccionesCuentasPorConocer LVARCHAR(2000);
        
        DEFINE cEntidad CHAR(50);
        DEFINE cCuenta CHAR(20);
        DEFINE cInstrucciones LVARCHAR(2500);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET iIdSolicitudEspecifica = 0;
        LET iIdRowMinEspecifica = 0;
        LET iIdRowMaxEspecifica = 0;
        LET iIdRowMin = 0;
        LET iIdRowMax = 0;
        LET iIdRow = 0;
        LET iIdMinRowInstruccionesXConocer = 0;
        LET iIdMaxRowInstruccionesXConocer = 0;
        
        LET cInstruccionesCuentasPorConocer = '';
        LET iPersonaId = 0;
        LET cCaracter = '';
        LET cDescTipoPersona = '';
        LET cApellidoPaterno = '';
        LET cApellidoMaterno = '';
        LET cNombre = '';
        LET cRfc = '';
        LET cRelacion = '';
        LET cDomicilio = '';
        LET cComplementarios = '';
        
        LET cEntidad = '';
        LET cCuenta = '';
        LET cInstrucciones = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ro_procesarsolic_especifica.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                
                FOREACH SELECT id_registro
                        INTO iIdRowMinEspecifica
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<SolicitudEspecifica>%'
                        
                        SELECT first 1 id_registro
                        INTO iIdRowMaxEspecifica
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '</SolicitudEspecifica>%'
                        AND id_registro > iIdRowMin;
                                
                        -- Id. solicitud
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<SolicitudEspecificaId>%'
                        AND id_registro > iIdRowMinEspecifica AND id_registro < iIdRowMaxEspecifica;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'SolicitudEspecificaId') INTO cCodRetSp, iIdSolicitudEspecifica;
                        
                        -- Instrucciones cuentas por conocer
                        SELECT id_registro
                        INTO iIdMinRowInstruccionesXConocer
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<InstruccionesCuentasPorConocer>%'
                        AND id_registro > iIdRowMinEspecifica AND id_registro < iIdRowMaxEspecifica;
                                
                        SELECT FIRST 1 id_registro
                        INTO iIdMaxRowInstruccionesXConocer
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '%</InstruccionesCuentasPorConocer>%'
                        AND id_registro >= iIdMinRowInstruccionesXConocer;
                                
                        
                        FOREACH SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE id_registro BETWEEN iIdMinRowInstruccionesXConocer AND iIdMaxRowInstruccionesXConocer
                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'InstruccionesCuentasPorConocer') INTO cCodRetSp, cInstruccionesCuentasPorConocer;
                                
                                INSERT INTO bdicnweb:"informix".sw_ro_solicitudespecifica(id_expediente, id_solicitud_especifica, instrucciones_cuentas_x_conocer)
                                VALUES (pIdExpediente, iIdSolicitudEspecifica, TRIM(cInstruccionesCuentasPorConocer));
                        
                        END FOREACH;
                        
                        -- Esta parte de abajo ya funciona
                        FOREACH SELECT id_registro
                                INTO iIdRowMin
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<PersonasSolicitud>%'
                                AND id_registro > iIdRowMinEspecifica AND id_registro < iIdRowMaxEspecifica
                                
                                SELECT first 1 id_registro
                                INTO iIdRowMax
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '</PersonasSolicitud>%'
                                AND id_registro > iIdRowMin;
                                        
                                --      Id. Persona
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<PersonaId>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'PersonaId') INTO cCodRetSp, iPersonaId;
                                
                                --      Caracter
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Caracter>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Caracter') INTO cCodRetSp, cCaracter;
                                
                                --      Persona
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Persona>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Persona') INTO cCodRetSp, cDescTipoPersona;
                                
                                --      Paterno
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Paterno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Paterno') INTO cCodRetSp, cApellidoPaterno;
                                
                                --      Materno
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Materno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Materno') INTO cCodRetSp, cApellidoMaterno;
                                
                                --      Nombre
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Nombre>%'
								AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Nombre') INTO cCodRetSp, cNombre;
                                
                                --      RFC
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Rfc>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Rfc') INTO cCodRetSp, cRfc;
                                
                                --      Relacion
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Relacion>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Relacion') INTO cCodRetSp, cRelacion;
                                
                                --      Domicilio
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Domicilio>%'
								AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Domicilio') INTO cCodRetSp, cDomicilio;
                                
                                --      Complementarios
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Complementarios>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Complementarios') INTO cCodRetSp, cComplementarios;
                                
                                -- INSERCIÃN EN TABLA
                                INSERT INTO bdicnweb:"informix".sw_ro_personassolicitud(id_expediente, id_solicitud_especifica, id_persona, caracter, des_tipo_persona, 
                                        ap_paterno, ap_materno, nombre, rfc, relacion, domicilio, complementarios)
                                VALUES (pIdExpediente, iIdSolicitudEspecifica, iPersonaId, cCaracter, cDescTipoPersona, cApellidoPaterno, cApellidoMaterno, cNombre, cRfc, 
                                                cRelacion, cDomicilio, cComplementarios);
                                
                                -- CUENTAS CONOCIDAS
                                FOREACH SELECT id_registro
                                        INTO iIdRowMin
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<CuentasConocidas>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax
                                        
                                        SELECT first 1 id_registro
                                        INTO iIdRowMax
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '</CuentasConocidas>%'
                                        AND id_registro > iIdRowMin;
                                
                                        --      Entidad
                                        SELECT id_registro
                                        INTO iIdRow
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Entidad>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                                
                                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Entidad') INTO cCodRetSp, cEntidad;
                                        
                                        --      Cuenta
                                        SELECT id_registro
                                        INTO iIdRow
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Cuenta>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                                
                                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Cuenta') INTO cCodRetSp, cCuenta;
                                        
                                        --Instrucciones
                                        SELECT id_registro
                                        INTO iIdRow
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Instrucciones>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                                
                                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Instrucciones') INTO cCodRetSp, cInstrucciones;
                                        
                                        -- INSERCIÃN EN TABLA
                                        INSERT INTO bdicnweb:"informix".sw_ro_cuentasconocidas(id_expediente, id_solicitud_especifica, id_persona, entidad, cuenta, intrucciones)
                                        VALUES (pIdExpediente, iIdSolicitudEspecifica, iPersonaId, cEntidad, cCuenta, cInstrucciones);
                                
                                END FOREACH;
                                
                        END FOREACH;
                END FOREACH;
                
                RETURN cCodRet;
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 24/11/2015',
'MODULO: Oficios',
'FUNCIONALIDAD: Carga de archivos XML de oficios',
'DESCRIPCION: Prodcesa la parte de solicitudes especificas del archivo xml cargado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_procesarsolic_partes(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER)
                RETURNING CHAR(5) AS codret;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE iIdSolicitudEspecifica INTEGER;
        DEFINE iIdRowMin INTEGER;
        DEFINE iIdRowMax INTEGER;
        DEFINE iIdRow INTEGER;
        DEFINE iParteId INTEGER;
        DEFINE cCaracter CHAR(30);
        DEFINE cDescTipoPersona CHAR(10);
        DEFINE cApellidoPaterno CHAR(26);
        DEFINE cApellidoMaterno CHAR(26);
        DEFINE cNombre CHAR(150);
        DEFINE cRfc CHAR(15);
        DEFINE cRelacion CHAR(50);
        DEFINE cDomicilio CHAR(150);
        DEFINE cComplementarios CHAR(50);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET iIdSolicitudEspecifica = 0;
        LET iIdRowMin = 0;
        LET iIdRowMax = 0;
        LET iIdRow = 0;
        
        
        LET iParteId = 0;
        LET cCaracter = '';
        LET cDescTipoPersona = '';
        LET cApellidoPaterno = '';
        LET cApellidoMaterno = '';
        LET cNombre = '';
        LET cRfc = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ro_procesarsolic_partes.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                FOREACH SELECT id_registro
                        INTO iIdRowMin
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<SolicitudPartes>%'
                        
                        SELECT first 1 id_registro
                        INTO iIdRowMax
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '</SolicitudPartes>%'
                                AND id_registro > iIdRowMin;
                        
                        --      Id. Parte
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<ParteId>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'ParteId') INTO cCodRetSp, iParteId;
                        
                        --      Caracter
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Caracter>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Caracter') INTO cCodRetSp, cCaracter;
                        
                        --      Persona
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Persona>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Persona') INTO cCodRetSp, cDescTipoPersona;
                        
                        --      Paterno
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Paterno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Paterno') INTO cCodRetSp, cApellidoPaterno;
                        
                        --      Materno
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Materno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Materno') INTO cCodRetSp, cApellidoMaterno;
                        
                        --      Nombre
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Nombre>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Nombre') INTO cCodRetSp, cNombre;
                        
                        --      RFC
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Rfc>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Rfc') INTO cCodRetSp, cRfc;
                        
                        -- INSERCIÓN EN TABLA
                        INSERT INTO bdicnweb:"informix".sw_ro_solicitudpartes(id_expediente, id_persona, caracter, des_tipo_persona, ap_paterno, ap_materno, nombre, rfc)
                        VALUES (pIdExpediente, iParteId, cCaracter, cDescTipoPersona, cApellidoPaterno, cApellidoMaterno, cNombre, cRfc);
                        
                END FOREACH;
                
                RETURN cCodRet;
        END;
        
END PROCEDURE;