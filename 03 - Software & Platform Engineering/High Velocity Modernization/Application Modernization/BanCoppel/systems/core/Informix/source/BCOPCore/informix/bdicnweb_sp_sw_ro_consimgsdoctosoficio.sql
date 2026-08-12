CREATE PROCEDURE "informix".sp_sw_ro_consimgsdoctosoficio(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT, pIdCliente INT, 
                                                                                                pNumCuenta CHAR(20), pTipoBusqueda INT)
        RETURNING CHAR(5) AS codret,
                CHAR(40) AS desc_documento
        DEFINE cCodRet CHAR(5);
        DEFINE cDescDocto CHAR(40);
        DEFINE iSqlErr INT;
        DEFINE iNoRegs INT;
        DEFINE cNumCuenta CHAR(20);
        LET cCodRet = '00000';
        LET cDescDocto = '';
        LET iSqlErr = 0;
        LET iNoRegs = 0;
        LET cNumCuenta = '99999999999';

        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, cDescDocto;
                        END IF;
                END EXCEPTION;
                IF pUsuario = ''OR pIdFunciON = ''OR pIdOficio = ''OR pTipoBusqueda = ''OR pIdCliente = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cDescDocto;
                END IF;
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cDescDocto;
                END IF;
                IF pTipoBusqueda NOT IN(1, 2) THEN
                        LET cCodRet = '00005';
                        RETURN cCodRet, cDescDocto;
                END IF;
                IF pTipoBusqueda = 1 THEN -- Busqueda de documentos del cliente
                        SET ISOLATION TO DIRTY READ;    
                        FOREACH SELECT DISTINCT b.descripcion_documento
                                        INTO cDescDocto
                                        FROM sw_ro_resulcte a, sw_ro_cteexp b
                                        WHERE a.id_oficio = pIdOficio
                                                AND a.id_resulcte = pIdCliente
                                                AND (b.cuenta = cNumCuenta OR b.grupo IN ('007'))
                                                AND a.ind_expdig = '1'
                                                AND b.id_resulcte = a.id_resulcte
                                                AND b.id_resulcte = a.id_resulcte
                                                AND b.ind_omitido = '0'
                                LET iNoRegs = iNoRegs + 1;
                                RETURN cCodRet, cDescDocto WITH resume;
                        END FOREACH;
                        IF iNoRegs = 0 THEN
                                LET cCodRet = '01001';
                                RETURN cCodRet, cDescDocto;
                        END IF;
                ELIF pTipoBusqueda = 2 THEN -- Busqueda de documentos de la cuenta cliente
                        IF pNumCuenta = '' THEN
                                LET cCodRet = '00003';
                                RETURN cCodRet, cDescDocto;
                        END IF;
                        LET cNumCuenta = pNumCuenta;
                        SET ISOLATION TO DIRTY READ;                    
                        FOREACH SELECT DISTINCT b.descripcion_documento
                                        INTO cDescDocto
                                        FROM sw_ro_resulcte a, sw_ro_cteexp b
                                        WHERE a.id_oficio = pIdOficio
                                                AND a.id_resulcte = pIdCliente
                                                AND b.cuenta = cNumCuenta
                                                AND a.certifica_imagenes = '1'
                                                AND b.id_resulcte = a.id_resulcte
                                                AND b.id_resulcte = a.id_resulcte
                                                AND b.ind_omitido = '0'
                                LET iNoRegs = iNoRegs + 1;
                                RETURN cCodRet, cDescDocto WITH resume;
                        END FOREACH;
                        IF iNoRegs = 0 THEN
                                LET cCodRet = '01001';
                                RETURN cCodRet, cDescDocto;
                        END IF;
                END IF;
        END
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 22/10/2014',
'DESCRIPCION: Consulta las imÃ¡genes del expediente del cliente/cuenta';

CREATE PROCEDURE "informix".sp_sw_ro_consimsctectaoficio(pUsuarioC CHAR(8), pIdFuncionC CHAR(10), pIdOficio INT, pIdBusqueda INT, 
                                                                                                pIdCte INT,     pNumCliente CHAR(20), pRegistros INT, pRecuperaciON INT)
        RETURNING CHAR(5) AS codret,
                CHAR(4) AS cve_docto,
                INT AS secuencia,
                CHAR(2) AS sistema_cuenta,
				CHAR(3) AS cod_grupo;
				
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE cCveDocto CHAR(4);
        DEFINE iSecuencia INT;
        DEFINE cSistemaCuenta CHAR(2);
        DEFINE iNoRegistros INT;
		DEFINE cGrupoDocto CHAR(3);
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCveDocto = '';
        LET iSecuencia = 0;
        LET cSistemaCuenta = '';
        LET iNoRegistros = 0;
		LET cGrupoDocto = '';
        
        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, cCveDocto, iSecuencia, cSistemaCuenta, cGrupoDocto;
                        END IF;
                END EXCEPTION;
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFuncionC) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cCveDocto, iSecuencia, cSistemaCuenta, cGrupoDocto;
                END IF;
                -- ValidaciÃ³n de campos requeridos
                IF pUsuarioC = ''OR pIdFuncionC = ''OR pIdOficio = ''OR pIdBusqueda = ''OR pIdCte = ''OR 
                        pNumCliente = ''OR pRegistros = ''OR pRecuperaciON = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cCveDocto, iSecuencia, cSistemaCuenta, cGrupoDocto;
                END IF;
                SET ISOLATION TO DIRTY READ;
                FOREACH SELECT skip pRegistros FIRST pRecuperaciON cod_documento, secuencia, tipo_cuenta, grupo
                                INTO cCveDocto, iSecuencia, cSistemaCuenta, cGrupoDocto
                                FROM sw_ro_cteexp
                                WHERE id_oficio = pIdOficio
                                        AND id_busqueda = pIdBusqueda
                                        AND id_resulcte = pIdCte
                                        AND numcte = pNumCliente
                                        AND ind_omitido = '0'
										
                                ORDER BY id_cteexp
                        LET iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, cCveDocto, iSecuencia, cSistemaCuenta, cGrupoDocto WITH resume;
                END FOREACH;
                IF iNoRegistros = 0 THEN
                        LET cCodRet = '01001';
                        RETURN cCodRet, cCveDocto, iSecuencia, cSistemaCuenta, cGrupoDocto;
                END IF;
        END
END PROCEDURE;