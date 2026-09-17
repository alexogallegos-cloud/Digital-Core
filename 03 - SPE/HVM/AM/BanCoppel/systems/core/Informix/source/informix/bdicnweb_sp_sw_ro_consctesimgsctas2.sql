CREATE PROCEDURE "informix".sp_sw_ro_consctesimgsctas2(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT, pIdCliente INT)
        RETURNING CHAR(5) AS codret,
                        CHAR(2) AS tipo_cuenta,
                        CHAR(10) AS desc_tipo_cuenta,
                        CHAR(20) AS cuenta,
						CHAR(40) AS producto;
						
        DEFINE iSqlErr INT;
        DEFINE iNoRows INT;
        DEFINE cCodRet CHAR(5);
        DEFINE cTipoCuenta CHAR(2);
        DEFINE cDescTipoCuenta CHAR(10);
        DEFINE cNumCuenta CHAR(20);
		
		DEFINE cCodRetSp CHAR(5);
		DEFINE cProducto CHAR(4);
		DEFINE cDescripcionProducto CHAR(40);
		DEFINE cNumCliente CHAR(20);
		
        LET iSqlErr = 0;
        LET cCodRet = '00000';
        LET cTipoCuenta = 0;
        LET cDescTipoCuenta = '';
        LET cNumCuenta = '';
        LET iNoRows = 0;
		
		LET cCodRetSp = '';
		LET cProducto = '';
		LET cDescripcionProducto = '';
		LET cNumCliente = '';
        
        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, cTipoCuenta, cDescTipoCuenta, cNumCuenta, cDescripcionProducto;
                        END IF;
                END EXCEPTION;
                IF pUsuario = ''OR pIdFunciON = ''OR pIdOficio = ''OR pIdCliente = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cTipoCuenta, cDescTipoCuenta, cNumCuenta, cDescripcionProducto;
                END IF;
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cTipoCuenta, cDescTipoCuenta, cNumCuenta, cDescripcionProducto;
                END IF;
                SET ISOLATION TO DIRTY READ;
                SELECT COUNT(*)
                INTO iNoRows
                FROM sw_ro_ctecta
                WHERE certifica_imagenes = '1' AND status = '1'
                AND id_resulcte = pIdCliente AND id_oficio = pIdOficio;
                IF iNoRows = 0 THEN
                        LET cCodRet = '00111';
                        RETURN cCodRet, cTipoCuenta, cDescTipoCuenta, cNumCuenta, cDescripcionProducto;
                END IF;
                LET iNoRows = 0; 
                SET ISOLATION TO DIRTY READ;
                FOREACH 
                        SELECT tipo_cuenta, decode(tipo_cuenta, '01', 'DEBITO', '03', 'INVERSION', '06', 'CREDITO'), cuenta
						INTO cTipoCuenta, cDescTipoCuenta, cNumCuenta
						FROM sw_ro_ctecta
						WHERE certifica_imagenes = '1' 
								AND status = '1'
								AND id_resulcte = pIdCliente 
								AND id_oficio = pIdOficio
								
					SELECT numcte
					INTO cNumCliente
					FROM bdicnweb:sw_ro_ctecta
					WHERE id_resulcte = pIdCliente AND id_oficio = pIdOficio AND cuenta = cNumCuenta;
					
					EXECUTE PROCEDURE "informix".sp_sw_ro_consultanombreproducto(pUsuario, pIdFuncion, cNumCliente, cNumCuenta, cTipoCuenta)
					INTO cCodRetSp, cProducto, cDescripcionProducto;
										
					LET iNoRows = iNoRows + 1;
					RETURN cCodRet, cTipoCuenta, cDescTipoCuenta, cNumCuenta, NVL(cDescripcionProducto, '') WITH resume;
                END FOREACH;
                
				IF iNoRows = 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, cTipoCuenta, cDescTipoCuenta, cNumCuenta, cDescripcionProducto;
                END IF;
        END
END PROCEDURE;