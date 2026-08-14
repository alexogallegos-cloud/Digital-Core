CREATE PROCEDURE "informix".sp_actualizactecoppel (pEmpresa CHAR(3), pNumCteBanco CHAR(20), pNumCteCoppel CHAR(20))
        RETURNING CHAR(5);

-- Creado: Rodolfo Tortolero
-- Fecha: 23/03/2009
-- Actividad: Actualiza el campo numcte_ref de la tabla si_cliente con el número de cliente coppel seleccionado en la dll consulta cliente.

-- Se definen variables
        DEFINE vCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE sNumCteRef CHAR(20);

        DEFINE n_clientes_ref   integer;

-- Se inicializan variables
        LET vCodRet = "000"; -- Actualizo el Número de Cliente Coppel
        LET iSqlErr = 0;

        LET n_clientes_ref = 0;

        BEGIN

            ON EXCEPTION SET iSqlErr
                    IF iSqlErr !=0 THEN
                            LET vCodRet = iSqlErr;
                            RETURN vCodRet;
                    END IF;
            END EXCEPTION;

            IF pNumCteBanco <> "" THEN
                IF pNumCteCoppel <> "" THEN
                    IF pNumCteBanco = pNumCteCoppel THEN
                            LET vCodRet = "003"; -- Número de cliente Banco es igual al Número de cliente Coppel
                            RETURN vCodRet;
                    ELSE

                        -- Ya existe el cliente con una referencia repetida
                            SELECT COUNT(*) 
                              INTO n_clientes_ref
                              FROM bdinteg:"informix".si_cliente
                             WHERE numcte_ref = pNumCteCoppel
                               AND numcte <> pNumCteBanco;

                            IF ( n_clientes_ref > 0 ) THEN
                                INSERT INTO bdinteg:si_bitacora_refcop(empresa, numcte, numcte_ref, rfc, sucursal, usuario, apell_paterno, apell_materno, nombre1, nombre2, fecha_insert)
                                    VALUES(pEmpresa,pNumCteBanco,pNumCteCoppel,'','', user,'','','','', CURRENT);

                                RETURN vCodRet;
                            ELSE
                                UPDATE si_cliente
                                SET numcte_ref = pNumCteCoppel
                                WHERE numcte = pNumCteBanco;

                                SELECT numcte_ref INTO sNumCteRef
                                FROM si_cliente
                                WHERE numcte = pNumCteBanco;

                                IF sNumCteRef = pNumCteCoppel THEN
                                        RETURN vCodRet;
                                ELSE
                                        LET vCodRet = "001"; -- No Actualizo el Número de cliente Coppel
                                        RETURN vCodRet;
                                END IF;
                            END IF;
                    END IF;
                ELSE
                    LET vCodRet = "002"; -- No recibio el Número de cliente Coppel
                    RETURN vCodRet;
                END IF;
            ELSE
                LET vCodRet = "004"; -- No recibio el Número de cliente Banco
                RETURN vCodRet;
            END IF;
        END;

END PROCEDURE;