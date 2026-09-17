CREATE PROCEDURE "informix".sp_sw_ro_borraimagenes(pUsuarioC CHAR(8),
                                                                                pIdFuncionC CHAR(10), 
                                                                                pIdOficio INT,
                                                                                pIdBusqueda INT,
                                                                                pIdCte INT, 
                                                                                pNumCliente CHAR(20), 
                                                                                pTipoCuenta CHAR(2),
                                                                                pNumCuenta CHAR(20))
        RETURNING CHAR(5) AS codret,
                INT AS regs_borrados
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iNoRegistros INT;
        DEFINE cStatus CHAR(1);
        DEFINE cStatus2 CHAR(1);
		DEFINE cNumCtaAux CHAR(20);
		DEFINE iNoRegistrosAux INT;
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = -1;
		LET cNumCtaAux = '';
		LET iNoRegistrosAux = -1;
		
        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, iNoRegistros;
                        END IF;
                END EXCEPTION;
				
				--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_ro_borraimagenes.sql';
				--TRACE ON;
				
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFuncionC) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iNoRegistros;
                END IF;
                --VALIDACION DE CAMPOS REQUERIDOS
                IF pUsuarioC = ''OR 
                        pIdFuncionC = ''OR 
                        pIdOficio = ''OR 
                        pIdBusqueda = ''OR 
                        pIdCte = ''OR 
                        pTipoCuenta = ''OR 
                        pNumCliente = ''OR 
                        pNumCuenta = '' 
                        then LET cCodRet = '00003';
                                RETURN cCodRet, iNoRegistros;
                END IF;
				
                IF pTipoCuenta NOT IN('01', '03', '06', '00') THEN
                        LET cCodRet = '00048'; -- El tipo de sistema busqueda es incorrecto
                        RETURN cCodRet, iNoRegistros;
                END IF;
				
				DELETE FROM sw_ro_cteexp
				WHERE id_oficio = pIdOficio
					AND id_busqueda = pIdBusqueda
					AND id_resulcte = pIdCte
					AND tipo_cuenta = pTipoCuenta
					AND numcte = pNumCliente
					AND cuenta = pNumCuenta;
						
                IF pNumCuenta = '99999999999' THEN
					UPDATE sw_ro_resulcte SET ind_expdig = '0' 
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio;
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' end
					INTO cStatus
					FROM sw_ro_ctecta
					WHERE id_oficio = pIdOficio 
							AND id_busqueda = pIdBusqueda 
							AND id_resulcte = pIdCte 
							AND certifica_imagenes = '1';
				   
					-- Se actualiza en estatus en la tabla de clientes
					UPDATE sw_ro_resulcte SET certifica_imagenes = cStatus
					WHERE id_resulcte = pIdCte 
							AND id_busqueda = pIdBusqueda 
							AND id_oficio = pIdOficio;              
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(ind_expdig) > 0 THEN '1' ELSE '0' end
					INTO cStatus2
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio 
							AND ind_expdig = '1';
					LET cStatus = cStatus + cStatus2;
					IF cStatus > 0 THEN
							LET cStatus = '1';
					END IF;
					
					-- ActualizaciÃ³n en maeoficios
					UPDATE sw_ro_maeoficios
					SET certifica_imagenes = cStatus
					WHERE id_oficio = pIdOficio;
                ELSE
					-- Se actualiza en estatus en la tabla de cuentas
					UPDATE sw_ro_ctecta SET certifica_imagenes = '0' 
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio AND cuenta = pNumCuenta;
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' end
					INTO cStatus
					FROM sw_ro_ctecta
					WHERE id_oficio = pIdOficio AND id_busqueda = pIdBusqueda AND id_resulcte = pIdCte AND certifica_imagenes = '1';
					
					-- Se actualiza en estatus en la tabla de clientes
					UPDATE sw_ro_resulcte SET certifica_imagenes = cStatus
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio;             
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' END 
					INTO cStatus
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio AND certifica_imagenes = '1';
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(ind_expdig) > 0 THEN '1' ELSE '0' end
					INTO cStatus2
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio AND ind_expdig = '1';
					LET cStatus = cStatus + cStatus2;
					IF cStatus > 0 THEN
							LET cStatus = '1';
					END IF;
					
					-- ActualizaciÃ³n en maeoficios
					UPDATE sw_ro_maeoficios
					SET certifica_imagenes = cStatus
					WHERE id_oficio = pIdOficio;
                END IF;
                LET iNoRegistros = dbinfo('sqlca.sqlerrd2');
                RETURN cCodRet, iNoRegistros;
        END
END PROCEDURE;