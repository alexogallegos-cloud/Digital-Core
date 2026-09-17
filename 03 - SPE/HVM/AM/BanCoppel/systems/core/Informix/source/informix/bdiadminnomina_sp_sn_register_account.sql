CREATE PROCEDURE "informix".sp_sn_register_account(pNumCte CHAR(20),pNumCta CHAR(20),pEstatus SMALLINT,pCuentaNomina SMALLINT,pEstatusCuentaNomina SMALLINT,pEmpresagc SMALLINT,pGrupoBenef SMALLINT,pPeriodicidad SMALLINT,pTipoCliente SMALLINT,pEstatusPeticionCliente SMALLINT,pProceso VARCHAR(6), pOpcion SMALLINT)
	RETURNING CHAR(5)
	
    DEFINE vCodRet				CHAR(5);
    DEFINE vCodRetInt			CHAR(5);
    DEFINE sqlErr				INTEGER;
    DEFINE iCantidadCuentas 	SMALLINT;
    DEFINE iCuentasMaxActivas 	SMALLINT;
	DEFINE iEnviaNotificaciones	SMALLINT;

    DEFINE cIdPlantilla 		CHAR(10);
    DEFINE cIdPlantillaPush 	CHAR(11);
    DEFINE cIdPlantillaSms  	CHAR(11);   
    DEFINE cNumCte 				CHAR(20);
	DEFINE iTiempoReactivacion  INTEGER; 
	DEFINE iTiempoTranscurrido  INTEGER; 
	
	DEFINE vCuentaInactiva		CHAR(20);
	DEFINE iClienteCN			SMALLINT;
	DEFINE iCuentasMae			SMALLINT;

    LET vCodRet 		    	= "00001";
    LET vCodRetInt 		    	= "00000";    
    LET sqlErr 			    	= 0; 
    LET iCantidadCuentas    	= 0;
	LET iCuentasMaxActivas		= 0;
	LET iEnviaNotificaciones	= 0;
    LET cIdPlantilla        	= "";
    LET cIdPlantillaPush    	= "";
    LET cIdPlantillaSms     	= "";
    LET cNumCte     			= "";
	LET iTiempoReactivacion 	= 0; 
	LET iTiempoTranscurrido 	= 0;
	
	LET vCuentaInactiva			= "";
	LET iClienteCN				= 0;
	LET iCuentasMae				= 0;
	

BEGIN
	
	ON EXCEPTION SET sqlErr
		LET vCodRet = sqlErr;
		RETURN vCodRet;
	END EXCEPTION;

    --SET DEBUG FILE TO "/home/sysifx/JoseZetina/sp_sn_register_account.trc";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF (TRIM(NVL(pNumCta,'')) = '' OR TRIM(NVL(pNumCte,'')) = '') AND pOpcion <> 3 THEN
		RETURN vCodRet;
	END IF;
	
	SELECT count(status_cta)
	INTO iCantidadCuentas
	FROM bdicheq:"informix".sc_maechq m join sn_cte_cta_nomina n on (n.numcte = m.num_cte and n.numcta = m.cuenta)
	where num_cte = pNumCte and producto = '2100' and status_cta='1';

	SELECT CAST(NVL(valor, '2')::CHAR(255) AS SMALLINT)
	INTO iCuentasMaxActivas
	FROM "informix".sn_parametros
	WHERE id = "MAX_CTAS_SN"; 
	
	--Elimina las cuentas de la tabla sn_cte_cta_nomina que no se encuenten activas en bdicheq:"informix".sc_maechq
	select count(cuenta) INTO iCuentasMae FROM bdicheq:"informix".sc_maechq where num_cte = pNumCte and producto = '2100' and status_cta = '2';
	if iCuentasMae > 0 then
		FOREACH
			select cuenta INTO vCuentaInactiva FROM bdicheq:"informix".sc_maechq where num_cte = pNumCte and producto = '2100' and status_cta = '2'
			
			delete from sn_cte_cta_nomina where numcte = pNumCte and numcta = vCuentaInactiva;
		END FOREACH
	end if;
	
	IF pOpcion = 1 THEN
		
		IF iCantidadCuentas = 0 THEN

			INSERT INTO "informix".sn_cte_cta_nomina(numcte, numcta, estatus,cuentaNomina,
			fechaAltaDeNomina,estatusCuentaNomina,fechaBajaDeNomina, empresagc, grupoBeneficios,
			periodicidad, fechaUltimaModificacion, tipoCliente, estatusPeticionCliente,proceso,fechaCreacion) 
			VALUES(pNumCte,pNumCta,pEstatus,pCuentaNomina,DATE(TODAY),pEstatusCuentaNomina,NULL,pEmpresagc,pGrupoBenef,
				pPeriodicidad,DATE(TODAY),pTipoCliente,pEstatusPeticionCliente,pProceso,DATE(TODAY));
			
			--Cueta cuantas veces existe el cliente para validar si se inserta o actualiza
			select count(numcte) into iClienteCN from "informix".sn_clientes_cuenta_nomina where numcte = pNumCte;
			let iCantidadCuentas = iCantidadCuentas + 1;
			
			if iClienteCN = 0 THEN
				INSERT INTO "informix".sn_clientes_cuenta_nomina(numcte,cantidadCuentas) 
				VALUES (pNumCte, iCantidadCuentas);
			ELSE
				UPDATE "informix".sn_clientes_cuenta_nomina
				SET cantidadCuentas = iCantidadCuentas
				WHERE numcte = pNumCte;
			END IF
			
			IF TRIM(pProceso) = 'OFI-T' THEN
				UPDATE bdicheq: "informix".sc_maechq
					SET marca_ret = 1
					WHERE cuenta = pNumCta
					AND num_cte = pNumCte;

					LET cIdPlantillaSms = "SUC_SNABCN";
					LET cIdPlantilla = "SUC_ENABCN";
					LET cIdPlantillaPush = "SUC_PNABCN";

					LET iEnviaNotificaciones = 1;
			END IF;

		ELIF iCantidadCuentas < iCuentasMaxActivas THEN
			
			SELECT numcte 
			INTO cNumCte
			FROM "informix".sn_cte_cta_nomina
			WHERE numcte = pNumCte
			AND numcta = pNumCta;

			IF cNumCte IS NULL THEN

				INSERT INTO "informix".sn_cte_cta_nomina(numcte, numcta, estatus,cuentaNomina,
				fechaAltaDeNomina,estatusCuentaNomina,fechaBajaDeNomina, empresagc, grupoBeneficios,
				periodicidad, fechaUltimaModificacion, tipoCliente, estatusPeticionCliente,proceso,fechaCreacion) 
				VALUES(pNumCte,pNumCta,pEstatus,pCuentaNomina,DATE(TODAY),pEstatusCuentaNomina,NULL,pEmpresagc,pGrupoBenef,
					pPeriodicidad,DATE(TODAY),pTipoCliente,pEstatusPeticionCliente,pProceso,DATE(TODAY));

				LET iCantidadCuentas = iCantidadCuentas + 1;

				UPDATE "informix".sn_clientes_cuenta_nomina
				SET cantidadCuentas = iCantidadCuentas
				WHERE numcte = pNumCte;

				IF TRIM(pProceso) = 'OFI-T' THEN
					UPDATE bdicheq:"informix".sc_maechq
						SET marca_ret = 1
						WHERE cuenta = pNumCta
						AND num_cte = pNumCte;

					LET cIdPlantillaSms = "SUC_SNABCN";
					LET cIdPlantilla = "SUC_ENABCN";
					LET cIdPlantillaPush = "SUC_PNABCN";

					LET iEnviaNotificaciones = 1;
				END IF;

			ELSE
				LET vCodRet = "00003"; ---No hay nada que registrar
				RETURN vCodRet;
			END IF;
		ELSE
			LET vCodRet = "00002"; --Cliente esta al limite de cuentas nomina activas permitidas
			RETURN vCodRet;
		END IF;

	ELIF pOpcion = 2 THEN
		IF pEstatusPeticionCliente = 0 THEN --Desactivacion
			
			
			--cliente decide dar de baja los beneficios
			UPDATE "informix".sn_cte_cta_nomina
			SET estatus = '0', fechaUltimaModificacion = DATE(TODAY),
				estatusPeticionCliente =  pEstatusPeticionCliente
			WHERE numcte = pNumCte AND numcta = pNumCta;

			LET iCantidadCuentas = iCantidadCuentas - 1;

			LET cIdPlantillaSms = "SUC_SNPBCN";
			LET cIdPlantilla = "SUC_ENPBCN";
			LET cIdPlantillaPush = "SUC_PNPBCN";

			LET iEnviaNotificaciones = 1;

			--definir plantilla
		ELIF pEstatusPeticionCliente = 1 THEN --Activacion
			IF iCantidadCuentas <= iCuentasMaxActivas THEN
			
				SELECT valor INTO iTiempoReactivacion FROM bdiadminnomina:"informix".sn_parametros WHERE id = 'TMP_REACT_BENEFICIOS';
				
				SELECT today - fechaUltimaModificacion INTO iTiempoTranscurrido
				FROM bdiadminnomina: "informix".sn_cte_cta_nomina
				WHERE numcte = pNumCte AND numcta = pNumCta;
				
					IF (iTiempoTranscurrido >= iTiempoReactivacion) THEN
						--cliente da de alta los beneficios
						UPDATE "informix".sn_cte_cta_nomina
						SET estatus = '0', fechaUltimaModificacion = DATE(TODAY),
							estatusPeticionCliente = pEstatusPeticionCliente
						WHERE numcte = pNumCte AND numcta = pNumCta;

						LET iCantidadCuentas = iCantidadCuentas + 1;
					ELSE
						LET vCodRet = "00004"; ---No se cumple el periodo para poder reactivar la cuenta
						RETURN vCodRet;
					END IF;
			
			ELIF iCantidadCuentas IS NULL THEN
				LET vCodRet = "00003"; ---No hay nada que actualizar
				RETURN vCodRet;
			ELSE
				LET vCodRet = "00002"; --Cliente esta al limite de cuentas nomina activas permitidas
				RETURN vCodRet;
			END IF;
			
		END IF;

		IF DBINFO('sqlca.sqlerrd2') > 0 THEN
			UPDATE "informix".sn_clientes_cuenta_nomina
			SET cantidadCuentas = iCantidadCuentas
			WHERE numcte = pNumCte;
		END IF;

	ELIF pOpcion = 3 THEN
		IF iCantidadCuentas >= iCuentasMaxActivas THEN
			LET vCodRet = "00004";
			RETURN vCodRet;
		END IF;
	END IF;

	IF iEnviaNotificaciones = 1 THEN
		--EnvÃ­a SMS
		EXECUTE PROCEDURE bdimnsj: "informix".sp_registra_evento(1,'PORTAL_SMS', cIdPlantillaSms,pNumCte, pNumCta,'', '1', '', '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0, 0, 0,current,current)
		INTO vCodRetInt;
		--Envia EMAIL
		EXECUTE PROCEDURE bdimnsj: "informix".sp_registra_evento(1,'PORTAL_BPI', cIdPlantilla,pNumCte, pNumCta,'', '1', '', '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0, 0, 0,current,current)
		INTO vCodRetInt;
		--Envia PUSH
		EXECUTE PROCEDURE bdimnsj: "informix".sp_registra_evento(1,'PNS_BEX', cIdPlantillaPush,pNumCte, pNumCta,'', '1', '', '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0, 0, 0,current,current)
		INTO vCodRetInt;
	END IF;

	IF DBINFO('sqlca.sqlerrd2') = 0 THEN
		LET vcodret = "00002";
	ELSE
		LET vcodret = "00000";
	END IF;
        
	RETURN vCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Este procedimiento almacenado registra la informaciÃ³n del cliente, como numero de cuenta, estatus, periodicidad de los pagos de nomina, etc.',
'PETICION: Iniciativa cuenta Nomina',
'AUTOR: Jorge Arturo Astorga',
'FECHA DE CREACION: JULIO 2022',
'MOFIFICO: 99805528 - Alejandra Barranco',
'FECHA MODIFICACION: SEPTIEMBRE 2022',
'BD: bdiadminnomina';


grant  execute on function "informix".sp_sn_retrieve_account_benefit (char,smallint) to "syssyweb" as "informix";
grant  execute on function "informix".sp_sn_retrieve_account_benefit (char,smallint) to "syssiweb" as "informix";
grant  execute on function "informix".sp_sn_insert_log_playroll_account (char,char,char,char) to "syssiweb" as "informix";
grant  execute on function "informix".sp_sn_insert_log_playroll_account (char,char,char,char) to "syssyweb" as "informix";
grant  execute on function "informix".sp_cargar_informacion_procesada_central () to "syssyweb" as "informix";
grant  execute on function "informix".sp_cargar_informacion_procesada_central () to "syssiweb" as "informix";
grant  execute on function "informix".sp_generar_archivos_nom_spei () to "syssiweb" as "informix";
grant  execute on function "informix".sp_generar_archivos_nom_spei () to "syssyweb" as "informix";
grant  execute on function "informix".sp_sn_benefit_tracking () to "syssiweb" as "informix";
grant  execute on function "informix".sp_sn_benefit_tracking () to "syssyweb" as "informix";
grant  execute on function "informix".sp_cargar_info_procesada_cta_nom () to "syssiweb" as "informix";
grant  execute on function "informix".sp_cargar_info_procesada_cta_nom () to "syssyweb" as "informix";
grant  execute on function "informix".sp_cargar_notificaciones () to "syssiweb" as "informix";
grant  execute on function "informix".sp_cargar_notificaciones () to "syssyweb" as "informix";
grant  execute on function "informix".sp_generar_arch_cta_nom () to "syssiweb" as "informix";
grant  execute on function "informix".sp_generar_arch_cta_nom () to "syssyweb" as "informix";
grant  execute on function "informix".sp_generar_arch_mov_spei () to "syssyweb" as "informix";
grant  execute on function "informix".sp_generar_arch_mov_spei () to "syssiweb" as "informix";
grant  execute on function "informix".sp_sn_retrieve_client_status (char,char,smallint) to "syssyweb" as "informix";
grant  execute on function "informix".sp_sn_retrieve_client_status (char,char,smallint) to "syssiweb" as "informix";
grant  execute on function "informix".sp_consulta_parametros_cuenta_nomina (char,char,char) to "syssiweb" as "informix";
grant  execute on function "informix".sp_consulta_parametros_cuenta_nomina (char,char,char) to "syssyweb" as "informix";
grant  execute on function "informix".sp_sn_register_account (char,char,smallint,smallint,smallint,smallint,smallint,smallint,smallint,smallint,varchar,smallint) to "syscuentanomina" as "informix";
grant  execute on function "informix".sp_sn_register_account (char,char,smallint,smallint,smallint,smallint,smallint,smallint,smallint,smallint,varchar,smallint) to "syssiweb" as "informix";
grant  execute on function "informix".sp_sn_register_account (char,char,smallint,smallint,smallint,smallint,smallint,smallint,smallint,smallint,varchar,smallint) to "syssyweb" as "informix";
revoke  execute on function "informix".sp_sn_retrieve_account_benefit (char,smallint) from public as "informix";
revoke  execute on function "informix".sp_sn_insert_log_playroll_account (char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_cargar_informacion_procesada_central () from public as "informix";
revoke  execute on function "informix".sp_generar_archivos_nom_spei () from public as "informix";
revoke  execute on function "informix".sp_sn_benefit_tracking () from public as "informix";
revoke  execute on function "informix".sp_cargar_info_procesada_cta_nom () from public as "informix";
revoke  execute on function "informix".sp_cargar_notificaciones () from public as "informix";
revoke  execute on function "informix".sp_generar_arch_cta_nom () from public as "informix";
revoke  execute on function "informix".sp_generar_arch_mov_spei () from public as "informix";
revoke  execute on function "informix".sp_sn_retrieve_client_status (char,char,smallint) from public as "informix";
revoke  execute on function "informix".sp_consulta_parametros_cuenta_nomina (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_sn_register_account (char,char,smallint,smallint,smallint,smallint,smallint,smallint,smallint,smallint,varchar,smallint) from public as "informix";

revoke usage on language SPL from public ;

grant usage on language SPL to public ;

grant usage on language SPL to ifxcons ;

grant usage on language SPL to ifxdesaa ;

grant usage on language SPL to ifxprod ;

grant usage on language SPL to ifxconsacc ;

grant usage on language SPL to ifxsopsuc ;


create index "informix".idx_cuentas_acumuladas on "informix".sn_clientes_cuenta_nomina 
    (numcte) using btree  in dbs_movhis_idx4;
create index "informix".idx_cte_cta_nomina on "informix".sn_cte_cta_nomina 
    (numcte,numcta) using btree  in dbs_movhis_idx4;
create index "informix".idx_cte_cta_nomina_cliente on "informix"
    .sn_cte_cta_nomina (numcte) using btree  in dbs_movhis_idx4;
    
create index "informix".idx_cte_cta_nomina_cuenta on "informix"
    .sn_cte_cta_nomina (numcta) using btree  in dbs_movhis_idx4;
    
create index "informix".idx_log_playroll_account on "informix"
    .sn_log_playroll_account (cuenta,tarjeta) using btree  in 
    dbs_movhis_idx4;
create index "informix".idx_sn_parametros on "informix".sn_parametros 
    (id) using btree  in dbs_movhis_idx4;
create index "informix".idx_sn_cte_nomemp_numcte on "informix"
    .sn_cte_nomemp (numcte) using btree  in dbs_movhis_idx4;