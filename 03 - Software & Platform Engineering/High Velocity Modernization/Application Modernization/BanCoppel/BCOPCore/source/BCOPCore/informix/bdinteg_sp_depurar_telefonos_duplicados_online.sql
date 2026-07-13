CREATE PROCEDURE "informix".sp_depurar_telefonos_duplicados_online(cNumCtePropietario CHAR(20), cTelefono CHAR(13), iTipoTel SMALLINT, cUser_insert CHAR(8))
	RETURNING CHAR(6), CHAR(100);

	--DEFINE VARIABLES
	DEFINE vCodRet			CHAR(6);
	DEFINE cEstado			CHAR(100);
	
	DEFINE cDescErr			CHAR(100);
	DEFINE iNomErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	
	DEFINE iEnTransaccion	SMALLINT;
	DEFINE iTipoDepuracion 	SMALLINT;
	DEFINE iSecuencia		SMALLINT;	
	DEFINE iId				INTEGER;
	DEFINE iError			INTEGER;
	
	DEFINE cProceso			CHAR(100);
	DEFINE cEvento			CHAR(100);
	DEFINE cNumCteDepurar	CHAR(20);
	DEFINE vIndTelefono		CHAR(1);
	DEFINE vIndCorreo		CHAR(1);
	DEFINE vCodRetRev		CHAR(5);

	DEFINE dFechahoy		DATE;

	--INICIALIZACION DE VARIABLES
	LET vCodRet 				= '000000';
	LET cEstado 				= 'DEPURACION DE TELEFONOS DUPLICADOS EJECUTADO CORRECTAMENTE';
	
	LET cDescErr				= '';
	
	LET iEnTransaccion 			= 0;
	LET iTipoDepuracion 		= 4;
	LET iSecuencia				= 0;
	LET iId 					= 0;
	LET iError					= 0;
	
	LET cProceso 				= 'sp_depurar_telefonos_duplicados_online';
	LET cEvento					= 'INICIO DEL PROCEDIMIENTO';

	LET cNumCteDepurar			= '';
	LET vIndTelefono     		= '';
	LET vIndCorreo      		= '';
	LET vCodRetRev       		= '';
	
	--SET DEBUG FILE TO "/tmp/josea/64139/sp_depurar_telefonos_duplicados_online.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iNomErr, iIsamErr, cDescErr
			IF iEnTransaccion = 1 THEN
				ROLLBACK WORK;
				
				LET vCodRet = iNomErr;			
				LET cEstado = 'OCURRIO UN ERROR DURANTE LA DEPURACION DE TELEFONOS DUPLICADOS';
					
				INSERT INTO bdinteg: si_log_depuracion_telefonos (fecha, telefono, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
				VALUES (CURRENT, cTelefono, cProceso, cEvento, vCodRet, cDescErr||': '|| iTipoDepuracion, cUser_insert, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));
								
				BEGIN WORK;
			END IF;
			
			RETURN vCodRet, cEstado;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET iEnTransaccion = 1;
			COMMIT WORK;
			BEGIN WORK;			
		END EXCEPTION WITH RESUME;
		
		SELECT fecha_hoy
		INTO dFechahoy
		FROM bdinteg:si_fechas;
		
		IF iEnTransaccion = 0 THEN
			BEGIN WORK;
			LET iEnTransaccion = 1;
		END IF;

		LET cEvento = 'REGISTRA SOLICITUD DE DEPURACION';
		SET LOCK MODE TO WAIT 3;
		INSERT INTO informix.si_telefonos_duplicados(telefono, tipo_tel, estatus, proceso, cod_retorno, tipo_depuracion, fecha_proceso, fecha_depuracion, user_insert, fecha_insert) 
		VALUES(cTelefono, iTipoTel , '0', '', '', iTipoDepuracion, '', '', cUser_insert, dFechahoy);

		LET cEvento = 'OBTIENE ID DE SOLICITUD DE DEPURACION';
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		SELECT {+INDEX (bdinteg: si_telefonos_duplicados  idx_si_telefonos_duplicados_03)} MAX(id)
		INTO iId
		FROM bdinteg:si_telefonos_duplicados
		WHERE telefono = cTelefono
		AND tipo_tel = iTipoTel
		AND estatus = '0'
		AND tipo_depuracion = iTipoDepuracion
		AND user_insert = cUser_insert		
		AND fecha_insert = dFechahoy;		
		
		LET cEvento = 'INICIA DEPURACION DE INFORMACION';		
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX (bdinteg: si_telefonos_actual  idx_telact_tel)} numcte, secuencia
			INTO cNumCteDepurar, iSecuencia
			FROM si_telefonos_actual 
			WHERE telefono = cTelefono
				AND tipo_tel = iTipoTel 
			
			IF TRIM(cNumCteDepurar) <> cNumCtePropietario THEN				
				INSERT INTO bdinteg:si_telefonos_actual_resp (id, empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado)
				SELECT {+INDEX (bdinteg: si_telefonos_actual  5950_2841)}
					iId, empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado
				FROM bdinteg: si_telefonos_actual 
				WHERE numcte = cNumCteDepurar 
					AND secuencia = iSecuencia;
				
				LET cEvento = 'ELIMINA TELEFONOS DE CLIENTES NO PROPIETARIOS';
				DELETE FROM bdinteg:si_telefonos_actual 
				WHERE numcte = cNumCteDepurar 
					AND secuencia = iSecuencia;
				
				LET cEvento = 'CANCELA TELEFONOS DE CLIENTES NO PROPIETARIOS';
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				UPDATE {+INDEX(bdinteg:si_telefonos 5949_2833)} bdinteg: si_telefonos 
				SET status_tel = 'C' 
				WHERE numcte = cNumCteDepurar 
					AND secuencia = iSecuencia;
				
				LET cEvento = 'sp_valrevtelefonos: MARCA CLIENTES PARA ACTUALIZAR TELEFONOS';
				EXECUTE PROCEDURE bdinteg:sp_valrevtelefonos(cNumCteDepurar)
				INTO vCodRetRev, vIndTelefono, vIndCorreo;
				
				IF TRIM(vCodRetRev) <> '000' THEN
					LET iError = 1;
					LET cEvento = 'REVERSO DE DEPURACION DE TELEFONO';														

					IF iEnTransaccion = 1 THEN
						ROLLBACK WORK;
						BEGIN WORK;
					END IF;
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 5;
					UPDATE si_telefonos_duplicados
					SET estatus = '2', cod_retorno = vCodRetRev, proceso = 'sp_valrevtelefonos', fecha_proceso = CURRENT::DATE
					WHERE id = iId;
					
					SET LOCK MODE TO WAIT 5;
					INSERT INTO bdinteg: si_log_depuracion_telefonos (fecha, telefono, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
					VALUES (CURRENT, cTelefono, cProceso, cEvento, vCodRetRev, 'sp_valrevtelefonos', cUser_insert, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));
					
					LET vCodRet = vCodRetRev;
					LET cEstado = 'OCURRIO UN ERROR AL MARCAR CLIENTES PARA ACTUALIZACION DE TELEFONO';
					
					EXIT FOREACH;
				END IF;																								
			END IF;
		END FOREACH;
		
		IF iError = 0 THEN		
			LET cEvento = 'MARCA TELEFONO COMO DEPURADO';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 5;
			UPDATE si_telefonos_duplicados
			SET estatus = '1', cod_retorno = '000000', proceso = 'TELEFONO DEPURADO', tipo_depuracion = iTipoDepuracion,fecha_proceso = CURRENT::DATE, fecha_depuracion = CURRENT::DATE
			WHERE id = iId;

			IF iEnTransaccion = 1 THEN
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END IF;
		
		RETURN vCodRet, cEstado;
	END
END PROCEDURE
DOCUMENT
'FECHA: 21/01/2016',
'RQI 64 139 DEPURACION ONLINE DE TELEFONOS DUPLICADOS',
'DESCRIPCION: PROCEDIMIENTO PARA DEPURAR ONLINE LOS NUMEROS DE TELEFONOS DUPLICADOS. ESTE SERA UTILIZADO DESDE OFI',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_elimina_cel_repetido(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))
RETURNING CHAR(5) as Cod_Ret;

DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;

LEt sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet;
        END IF;
    END EXCEPTION; 	
    
    --SET DEBUG FILE TO '/tmp/anj/sp_elimina_cel_repetido.sql';
	--TRACE ON;
    IF EXISTS(SELECT * FROM si_sucvalidasms WHERE sucursal=pSucursal AND activo='1') THEN
        DELETE FROM si_telefonos_actual WHERE numcte=pNumCte AND tipo_tel='2' AND telefono=pNumCel;

        UPDATE si_telefonos SET status_tel='C', verificado='F', fecha_actualiza=CURRENT 
            WHERE numcte=pNumCte AND tipo_tel='2' AND telefono=pNumCel AND status_tel='A';
   END IF;

RETURN NVL(sCodRet,'00000');

END
END PROCEDURE
;