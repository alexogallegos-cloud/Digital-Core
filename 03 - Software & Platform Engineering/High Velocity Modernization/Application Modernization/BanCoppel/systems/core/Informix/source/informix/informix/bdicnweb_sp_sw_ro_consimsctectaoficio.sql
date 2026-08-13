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