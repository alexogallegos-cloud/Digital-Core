CREATE PROCEDURE "informix".sp_sw_ro_consimagenes(pUsuarioC CHAR(8), pIdFuncionC CHAR(10), pIdOficio INT, pIdBusqueda INT, 
												pIdCte INT, pNumCliente CHAR(20), pTipoCuenta CHAR(2), pNumeroCuenta CHAR(20), 
												pRegistros INT, pRecuperaciON INT)
        RETURNING CHAR(5) AS codret,
                CHAR(3) AS grupo,
                CHAR(30) AS desc_grupo,
                CHAR(4) AS cve_docto,
                CHAR(35) AS desc_docto,
                SMALLINT AS secuencia,
                CHAR(20) AS cuenta,
                CHAR(4) AS producto,
                CHAR(40) AS desc_producto,
                CHAR(10) AS fecha_registro,
                CHAR(2) AS sistema_cuenta,
                CHAR(1) AS omitido;
				
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE cGrupo CHAR(3);
        DEFINE cDescGrupo CHAR(30);
        DEFINE cCveDocto CHAR(4);
        DEFINE cDescDocto CHAR(35);
        DEFINE iSecuencia SMALLINT;
        DEFINE cCuenta CHAR(20);
        DEFINE cProducto CHAR(4);
        DEFINE cDescProducto CHAR(40);
        DEFINE dFechaRegistro DATE;
        DEFINE cSistemaCuenta CHAR(2);
        DEFINE cOmitido CHAR(1);
        DEFINE iNoRegistros INT;
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cGrupo = '';
        LET cDescGrupo = '';
        LET cCveDocto = '';
        LET cDescDocto = '';
        LET iSecuencia = 0;
        LET cCuenta = '';
        LET cProducto = '';
        LET cDescProducto = '';
        LET dFechaRegistro = NULL;
        LET cSistemaCuenta = '';
        LET cOmitido = '';
        LET iNoRegistros = 0;
        
        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, cGrupo, cDescGrupo, cCveDocto, 
                                                cDescDocto, iSecuencia, cCuenta, cProducto, 
                                                cDescProducto, dFechaRegistro, cSistemaCuenta, cOmitido;
                        END IF;
                END EXCEPTION;
				
				--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_ro_consimagenes.out';
				--TRACE ON;
				
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFuncionC) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cGrupo, cDescGrupo, cCveDocto, 
                                        cDescDocto, iSecuencia, cCuenta, cProducto, 
                                        cDescProducto, dFechaRegistro, cSistemaCuenta, cOmitido;
                END IF;
                -- ValidaciÃ³n de campos requeridos
                IF pUsuarioC = ''OR pIdFuncionC = '' 
                                                or pIdOficio = ''OR pIdBusqueda = '' 
                                                or pIdCte = ''OR pTipoCuenta = '' 
                                                or pNumCliente = ''OR pRegistros = '' 
                                                or pRecuperaciON = ''OR pNumeroCuenta = '' THEN 
                                                        LET cCodRet = '00003';
                                                        RETURN cCodRet, cGrupo, cDescGrupo, cCveDocto, 
                                                                        cDescDocto, iSecuencia, cCuenta, cProducto, 
                                                                        cDescProducto, dFechaRegistro, cSistemaCuenta, cOmitido;
                END IF;
                IF pTipoCuenta NOT IN('01', '03', '06', '00') THEN
                        LET cCodRet = '00048'; -- El tipo de sistema busqueda es incorrecto
                        RETURN cCodRet, cGrupo, cDescGrupo, cCveDocto, 
                                        cDescDocto, iSecuencia, cCuenta, cProducto, 
                                        cDescProducto, dFechaRegistro, cSistemaCuenta, cOmitido;
                END IF;
                
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT skip pRegistros FIRST pRecuperaciON grupo, descripcion_grupo, cod_documento, descripcion_documento, secuencia,
																																cuenta, producto, descripcion_producto, fecha_registro, 
																																tipo_cuenta, ind_omitido
								INTO cGrupo, cDescGrupo, cCveDocto, cDescDocto, 
												iSecuencia, cCuenta, cProducto, cDescProducto,
												dFechaRegistro, cSistemaCuenta, cOmitido
								FROM sw_ro_cteexp
								WHERE id_oficio = pIdOficio
										AND id_busqueda = pIdBusqueda
										AND id_resulcte = pIdCte
										AND tipo_cuenta = pTipoCuenta
										AND numcte = pNumCliente
										AND cuenta = pNumeroCuenta
								ORDER BY id_cteexp
								
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, cGrupo, cDescGrupo, cCveDocto, 
										cDescDocto, iSecuencia, cCuenta, cProducto, 
										cDescProducto, dFechaRegistro, cSistemaCuenta, cOmitido 
								WITH resume;
				END FOREACH;
				
                IF iNoRegistros = 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, cGrupo, cDescGrupo, cCveDocto, 
                                        cDescDocto, iSecuencia, cCuenta, cProducto, 
                                        cDescProducto, dFechaRegistro, cSistemaCuenta, cOmitido;
                END IF;
        END
END PROCEDURE;