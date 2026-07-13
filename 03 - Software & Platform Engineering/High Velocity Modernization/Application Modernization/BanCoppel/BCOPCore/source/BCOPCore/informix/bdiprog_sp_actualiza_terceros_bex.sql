CREATE PROCEDURE "informix".sp_actualiza_terceros_bex(pNumCte char(20), pCuenta char (20), pCveBanco char(3), pClaveCuenta char (2), pAlias char(20), pNombreTitular char(60), pRfc char(13),pCelular char (10), pCompaniaCel char (2), pCorreoE char (40))
returning char(5), char(60);

--Declara variables
DEFINE v_sCveEstado char (2);
DEFINE vCodRet char(5);
DEFINE vMensajeRet char(60);
DEFINE vSqlErr integer;
DEFINE vFechaCaducidad DATE;
--Asignacion de variables
LET v_sCveEstado = '';
LET vCodRet = '';
LET vMensajeRet = '';
LET vFechaCaducidad = '';

--SET DEBUG FILE TO "/home/informix/bibiana/sp_actualiza_terceros_bpi.out";
--TRACE ON;

  BEGIN
        ON EXCEPTION SET vSqlErr
            IF vSqlErr != 0 THEN
                LET vCodRet = vSqlErr;
		LET vMensajeRet = 'Error Interno';
                RETURN vCodRet, vMensajeRet;
            END IF;
        END EXCEPTION;

--Se verifica que exista el cliente tenga relacion con los datos proporcionados

		IF EXISTS(SELECT cve_estado FROM bdiprog:pp_ctasterceros_bex WHERE num_cte = pNumCte AND cuenta = pCuenta AND
			cve_banco = pCveBanco AND cve_cuenta = pClaveCuenta)THEN

--Se toma el valor del estado para comparar y poder hacer la actualizacion

				SELECT cve_estado INTO v_sCveEstado FROM bdiprog:pp_ctasterceros_bex WHERE num_cte = pNumCte AND cuenta = pCuenta AND
					cve_banco = pCveBanco AND cve_cuenta = pClaveCuenta;

					IF v_sCveEstado = '01' THEN
					
						UPDATE bdiprog:pp_ctasterceros_bex SET nombre = pNombreTitular, descrip_cta = pAlias, rfc =  pRfc, no_celular = pCelular,
								cve_compania = pCompaniaCel, direc_correo = pCorreoE,  fecha_movtos = today
								WHERE num_cte = pNumCte and cuenta = pCuenta and cve_banco = pCveBanco AND cve_cuenta = pClaveCuenta;
						
						SELECT cod_ret,desc_mensaje INTO vCodRet, vMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '00';
					ELSE
						SELECT cod_ret,desc_mensaje INTO vCodRet, vMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '10';
					END IF;
		ELSE
			SELECT cod_ret,desc_mensaje INTO vCodRet, vMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '09';
		END IF ;

		RETURN vCodRet, vMensajeRet;

	END;
END PROCEDURE;