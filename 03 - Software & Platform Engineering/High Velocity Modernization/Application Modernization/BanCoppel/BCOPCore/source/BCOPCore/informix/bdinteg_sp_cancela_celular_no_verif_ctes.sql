CREATE PROCEDURE "informix".sp_cancela_celular_no_verif_ctes()
				RETURNING CHAR(5)     AS Cod_Retorno;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;	
DEFINE cNumCte 			CHAR(20);	
DEFINE iCont			SMALLINT;
--VARIABLES
DEFINE cTelefono		char(13);
DEFINE iSecuencia 		SMALLINT;
DEFINE iExisteTelAct	SMALLINT;
DEFINE iExisteProd		SMALLINT;
DEFINE iDuplicado		SMALLINT;
DEFINE iTipoCteTit		SMALLINT;
DEFINE iTipoTelCel		SMALLINT;
DEFINE cEstTelActivo	char(1);
DEFINE cTelVerif		char(1);
DEFINE iEstCtaCancel	SMALLINT;
DEFINE iMaxCommit		INTEGER;
DEFINE cEstTelCancel	char(1);
DEFINE dFechaAlta		DATE;



--INICIALIZA VARIABLES
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	
LET cNumCte 			= '';	
LET iCont 				= 0;
LET cTelefono			= '';
LET iSecuencia			= 0;
LET iExisteTelAct		= 0;
LET iExisteProd			= 0;
LET iDuplicado	 		= 0;
LET iTipoCteTit			= 1;
LET iTipoTelCel			= 2;
LET cEstTelActivo		= 'A';
LET cTelVerif			= 'V';
LET iEstCtaCancel		= 2;
LET iMaxCommit			= 5000;
LET cEstTelCancel		= 'C';
LET dFechaAlta			= TODAY-1;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_cancela_celular_no_verif_ctes.out";
	--SET DEBUG FILE TO "/ifxsif01/jagl/bdinteg/sp_cancela_celular_no_verif_ctes.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Cancela los celulares de los clientes tales que el día de ayer se volvieron clientes
	--Comienza foreach
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_telefonos)}
		tel.telefono
		INTO cTelefono
		FROM "informix".si_cliente cte
		INNER JOIN "informix".si_telefonos tel ON tel.numcte = cte.numcte
		WHERE 
		cte.fecha_alta = dFechaAlta
		AND tel.tipo_tel = iTipoTelCel
		AND tel.status_tel = cEstTelActivo
		AND (tel.verificado IS NULL OR tel.verificado != cTelVerif)

		
		--Se valida que el teléfono este duplicado, es decir, exista otro cliente que tenga asignado el mismo número teléfonico
		SELECT 
		{+AVOID_FULL ("informix".si_telefonos)}
		COUNT(*)
		INTO iDuplicado
		FROM "informix".si_cliente cte
		INNER JOIN "informix".si_telefonos tel ON tel.numcte = cte.numcte
		WHERE 
		cte.tipo_cliente = iTipoCteTit
		AND tel.telefono = cTelefono
		AND tel.tipo_tel = iTipoTelCel
		AND tel.status_tel = cEstTelActivo
		AND (tel.verificado IS NULL OR tel.verificado != cTelVerif)
		AND EXISTS
		(
			SELECT 
			{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_telefonos)}
			1 
			FROM "informix".si_cliente cte2
			INNER JOIN "informix".si_telefonos tel2 ON tel2.numcte=cte2.numcte 
			WHERE 
			tel2.telefono = cTelefono 
			AND tel2.tipo_tel = iTipoTelCel 
			AND tel2.status_tel = cEstTelActivo
			AND (tel2.verificado IS NULL OR tel2.verificado != cTelVerif)
			AND cte2.numcte != cte.numcte
		)
		;
		
		IF iDuplicado = 0 THEN
			CONTINUE FOREACH;
		END IF;
		
		FOREACH WITH HOLD
			SELECT 
			{+AVOID_FULL ("informix".si_telefonos)}
			tel.numcte, tel.telefono, tel.secuencia
			INTO cNumCte, cTelefono, iSecuencia
			FROM "informix".si_telefonos tel
			WHERE 
			tel.telefono = cTelefono
			AND tel.tipo_tel = iTipoTelCel
			AND tel.status_tel = cEstTelActivo
			AND (tel.verificado IS NULL OR tel.verificado != cTelVerif)

			--Se valida que el cliente no cuente con una cuenta de captación activa
			SELECT 
			{+AVOID_FULL(bdicheq:"informix".sc_maechq)}
			COUNT(*)
			INTO iExisteProd
			FROM bdicheq:"informix".sc_maechq cheq
			WHERE cheq.num_cte = cNumCte
			AND cheq.status_cta != iEstCtaCancel
			;
			
			IF iExisteProd > 0 THEN
				CONTINUE FOREACH;
			END IF;

			--Se valida que el cliente no cuente con una cuenta de inversión
			SELECT 
			{+AVOID_FULL(bdinvers:"informix".sv_maeinv)}
			COUNT(*)
			INTO iExisteProd
			FROM bdinvers:"informix".sv_maeinv inv
			WHERE inv.num_cte = cNumCte
			AND inv.status_cta != iEstCtaCancel
			;
			
			IF iExisteProd > 0 THEN
				CONTINUE FOREACH;
			END IF;

			--Se valida que el cliente no cuente con una cuenta de colocación
			SELECT 
			{+AVOID_FULL(bdicred:"informix".sd_maecred)}
			COUNT(*)
			INTO iExisteProd
			FROM bdicred:"informix".sd_maecred cred
			WHERE cred.numcte = cNumCte
			;

			IF iExisteProd > 0 THEN
				CONTINUE FOREACH;
			END IF;
			
			--Se valida que el cliente no cuente con una cuenta de colocación
			SELECT 
			{+AVOID_FULL(bdicred:"informix".sd_maecredcrd)}
			COUNT(*)
			INTO iExisteProd
			FROM bdicred:"informix".sd_maecredcrd cred
			WHERE cred.numcte = cNumCte
			;

			IF iExisteProd > 0 THEN
				CONTINUE FOREACH;
			END IF;

			--Se consulta el teléfono actual del cliente para eliminar dicho registro
			SELECT 
			{+AVOID_FULL ("informix".si_telefonos_actual)}
			count(*)
			INTO iExisteTelAct
			FROM "informix".si_telefonos_actual
			WHERE 
			numcte=cNumCte
			AND tipo_tel = iTipoTelCel
			AND telefono=cTelefono
			AND secuencia = iSecuencia
			;
			
			--Se elimina el celular de la tabla si_telefonos_actual para el prospecto
			IF iExisteTelAct > 0 THEN
				DELETE "informix".si_telefonos_actual
				WHERE 
				numcte=cNumCte
				AND tipo_tel = iTipoTelCel
				AND telefono=cTelefono
				AND secuencia = iSecuencia
				;
				LET iCont=iCont+1;
			END IF;
			
			--Se actualiza el estatus del celular como cancelado en la tabla si_telefonos para el cliente
			UPDATE "informix".si_telefonos
			SET status_tel = cEstTelCancel
			WHERE 
			numcte=cNumCte
			AND tipo_tel = iTipoTelCel
			AND telefono = cTelefono
			AND secuencia = iSecuencia
			;

			LET iCont=iCont+1;
						
			IF iCont >= iMaxCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END FOREACH;
	END FOREACH;	
	--Finaliza foreach
	COMMIT WORK;
	
	--Depura los registros de los clientes tales que su fecha de registro de su teléfono sea igual al día anterior
	--Comienza foreach
	LET iCont = 0;
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_telefonos)}
		tel.telefono
		INTO cTelefono
		FROM "informix".si_cliente cte
		INNER JOIN "informix".si_telefonos tel ON tel.numcte = cte.numcte
		WHERE 
		cte.fecha_alta != dFechaAlta
		AND tel.tipo_tel = iTipoTelCel
		AND tel.status_tel = cEstTelActivo
		AND (tel.verificado IS NULL OR tel.verificado != cTelVerif)
		AND tel.fecha_hora >= dFechaAlta
		
		--Se valida que el teléfono este duplicado, es decir, exista otro cliente que tenga asignado el mismo número teléfonico
		SELECT 
		{+AVOID_FULL ("informix".si_telefonos)}
		COUNT(*)
		INTO iDuplicado
		FROM "informix".si_cliente cte
		INNER JOIN "informix".si_telefonos tel ON tel.numcte = cte.numcte
		WHERE 
		cte.tipo_cliente = iTipoCteTit
		AND tel.telefono = cTelefono
		AND tel.tipo_tel = iTipoTelCel
		AND tel.status_tel = cEstTelActivo
		AND (tel.verificado IS NULL OR tel.verificado != cTelVerif)
		AND EXISTS
		(
			SELECT 
			{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_telefonos)}
			1 
			FROM "informix".si_cliente cte2
			INNER JOIN "informix".si_telefonos tel2 ON tel2.numcte=cte2.numcte 
			WHERE 
			tel2.telefono = cTelefono 
			AND tel2.tipo_tel = iTipoTelCel 
			AND tel2.status_tel = cEstTelActivo
			AND (tel2.verificado IS NULL OR tel2.verificado != cTelVerif)
			AND cte2.numcte != cte.numcte
		)
		;
		
		IF iDuplicado = 0 THEN
			CONTINUE FOREACH;
		END IF;
		
		FOREACH WITH HOLD
			SELECT 
			{+AVOID_FULL ("informix".si_telefonos)}
			tel.numcte, tel.telefono, tel.secuencia
			INTO cNumCte, cTelefono, iSecuencia
			FROM "informix".si_telefonos tel
			WHERE 
			tel.telefono = cTelefono
			AND tel.tipo_tel = iTipoTelCel
			AND tel.status_tel = cEstTelActivo
			AND (tel.verificado IS NULL OR tel.verificado != cTelVerif)

			--Se valida que el cliente no cuente con una cuenta de captación activa
			SELECT 
			{+AVOID_FULL(bdicheq:"informix".sc_maechq)}
			COUNT(*)
			INTO iExisteProd
			FROM bdicheq:"informix".sc_maechq cheq
			WHERE cheq.num_cte = cNumCte
			AND cheq.status_cta != iEstCtaCancel
			;
			
			IF iExisteProd > 0 THEN
				CONTINUE FOREACH;
			END IF;

			--Se valida que el cliente no cuente con una cuenta de inversión
			SELECT 
			{+AVOID_FULL(bdinvers:"informix".sv_maeinv)}
			COUNT(*)
			INTO iExisteProd
			FROM bdinvers:"informix".sv_maeinv inv
			WHERE inv.num_cte = cNumCte
			AND inv.status_cta != iEstCtaCancel
			;
			
			IF iExisteProd > 0 THEN
				CONTINUE FOREACH;
			END IF;

			--Se valida que el cliente no cuente con una cuenta de colocación
			SELECT 
			{+AVOID_FULL(bdicred:"informix".sd_maecred)}
			COUNT(*)
			INTO iExisteProd
			FROM bdicred:"informix".sd_maecred cred
			WHERE cred.numcte = cNumCte
			;

			IF iExisteProd > 0 THEN
				CONTINUE FOREACH;
			END IF;
			
			--Se valida que el cliente no cuente con una cuenta de colocación
			SELECT 
			{+AVOID_FULL(bdicred:"informix".sd_maecredcrd)}
			COUNT(*)
			INTO iExisteProd
			FROM bdicred:"informix".sd_maecredcrd cred
			WHERE cred.numcte = cNumCte
			;

			IF iExisteProd > 0 THEN
				CONTINUE FOREACH;
			END IF;

			--Se consulta el teléfono actual del cliente para eliminar dicho registro
			SELECT 
			{+AVOID_FULL ("informix".si_telefonos_actual)}
			count(*)
			INTO iExisteTelAct
			FROM "informix".si_telefonos_actual
			WHERE 
			numcte=cNumCte
			AND tipo_tel = iTipoTelCel
			AND telefono=cTelefono
			AND secuencia = iSecuencia
			;
			
			--Se elimina el celular de la tabla si_telefonos_actual para el prospecto
			IF iExisteTelAct > 0 THEN
				DELETE "informix".si_telefonos_actual
				WHERE 
				numcte=cNumCte
				AND tipo_tel = iTipoTelCel
				AND telefono=cTelefono
				AND secuencia = iSecuencia
				;
				LET iCont=iCont+1;
			END IF;
			
			--Se actualiza el estatus del celular como cancelado en la tabla si_telefonos para el cliente
			UPDATE "informix".si_telefonos
			SET status_tel = cEstTelCancel
			WHERE 
			numcte=cNumCte
			AND tipo_tel = iTipoTelCel
			AND telefono = cTelefono
			AND secuencia = iSecuencia
			;

			LET iCont=iCont+1;
						
			IF iCont >= iMaxCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END FOREACH;
	END FOREACH;	
	--Finaliza foreach
	COMMIT WORK;
	
	RETURN cCodRet;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 10/12/2020',
'MODULO: Integral',
'BD: bdinteg',
'FUNCIONALIDAD: Cancelación de teléfonos celulares no verificados de clientes',
'DESCRIPCION: SPL encargado de cancelar los teléfonos celulares no verificados de los clientes, tales que no cuentan con un producto de BanCoppel actalmente'
;

CREATE PROCEDURE "informix".sp_agregarbitacora_bpi(
pFechaOper datetime year to second,
pNumTrans char(4),
pNumSuc char(4),
pIdUsuario integer,
pIpUsuario char(15),
pFechaApli date,
pCtaOrigen char(12),
pCtaDesti char(20),  --CAMBIA
pMonto money,
pSecTrans char(16),
pCgen1 char(100),  --CAMBIA
pCgen2 char(200),  --CAMBIA
pCgen3 char(60),  --CAMBIA
pCgen4 char(60),  --CAMBIA
pCgen5 char(60),  --NUEVO
pCgen6 char(100),  --NUEVO
pReferencia char(100),  --NUEVO
pFolio char(16),
tipo_token char(1)  --NUEVO
)
 returning char(5);

    -- Realizo   : Javier Alonso ChÃÂ¡vez Trujillo
    -- Actividad : Agrega Bitacora
    -- SolicitÃÂ³  : Mauricio Leon
    -- Fecha     : 25/11/2008
	--//////////////////////////////////////////
	-- Realizo   : Walber Castro
	-- Actividad : se modifica el tipo de dato del parametro de entrada Monto ya que redondeaba las cifras grandes.
	-- SolicitÃÂ³  : Mauricio Leon
	-- Fecha     : 23/08/2010
	-- ////////////////////////////////////////
	-- Bibiana Gaxiola Verdugo
	-- Se agrega la actualizaciÃÂ³n del movimiento en la tabla de cuentas frecuentes para la caducidad de las mismas.
	-- 21/01/2013
	-- ING. ALFONSO CRUZ
	-- Modificacion en la bitacora en la que se agregaron parametros a la misma.
	-- 08/07/2013
	-- ////////////////////////////////////////
	-- Realizo	 : L.I. Manuel Ramos Figueroa
	-- Actividad : Se aumento a 100 el tamaÃÂ±o del parametro pCgen6
	-- SolicitÃÂ³  : Bibiana Gaxiola Verdugo
	-- Fecha	 : 16/01/2014
	--//////////////////////////////////////////
	-- Realizo	 : L.I. Manuel Ramos Figueroa
	-- Actividad : Se aumento a 200 el tamaÃÂ±o del parametro pCgen2
	-- SolicitÃÂ³  : Bibiana Gaxiola Verdugo
	-- Fecha	 : 06/02/2014
	--//////////////////////////////////////////
	-- Realizo	 : Solser
	-- Actividad : Se agregÃ³ tipo_token como parÃ¡metro de entrada y nuevo parÃ¡metro de tabla bpi_bitacora
	-- Solicita  : Gabriela Aguilar
	-- Fecha	 : 07/01/2021

 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE vCtasFrec CHAR(1);
DEFINE vNumCte CHAR(10);
DEFINE vCveCaducidad CHAR(1);
DEFINE vClaveBanco CHAR(60);

--INICIALIZA VARIABLES
LET cod_ret  = "000";
LET vClaveBanco = pCgen4;

--SET DEBUG FILE TO "/informix/gaby/INC-Activacion_bitacoraTKNPass/sp_agregarbitacora_bpi.out";
--TRACE ON;

BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	IF(pNumTrans IN ('1011','1015','2015','2100') ) THEN
		SELECT FIRST 1 vchrnombrecorto
		INTO pCgen4
		FROM BDINTEG:"informix".si_bancos
		WHERE banco = vClaveBanco;
	END IF;

	INSERT INTO bdibpi:"informix".bpi_bitacora(fecha_oper,
			     id_operacion,
			     sucursal,
			     id_usuario,
			     ipusuario,
			     fecha_aplic,
			     cuenta_origen,
			     destino,
			     monto_oper,
			     sec_transaccion,
			     cgenerico1,
			     cgenerico2,
			     cgenerico3,
			     cgenerico4,
				 cgenerico5,
				 cgenerico6,
				 referencia,
				 folio,
                 tipo_token) VALUES (pFechaOper,
						  pNumTrans,
						  pNumSuc,
						  pIdUsuario,
						  pIpUsuario,
						  pFechaApli,
						  pCtaOrigen,
						  pCtaDesti,
						  pMonto,
						  pSecTrans,
						  pCgen1,
						  pCgen2,
						  pCgen3,
						  pCgen4,
						  pCgen5,
						  pCgen6,
						  pReferencia,
						  pFolio,
                          tipo_token);
	


		SELECT ctas_frec INTO vCtasFrec FROM bdibpi:"informix".bpi_cat_operaciones WHERE id_oper = pNumTrans;

		IF (vCtasFrec = '1') THEN --- Significa que son operaciones que involucran cuentas frecuentes

			SELECT numcliente INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo';

			SELECT cve_caducidad INTO vCveCaducidad FROM bdiprog:"informix".pp_ctasterceros WHERE cuenta = pCtaDesti AND num_cte = vNumCte;

			IF (vCveCaducidad = '3') THEN
				UPDATE bdiprog:"informix".pp_ctasterceros SET fecha_movtos = today WHERE cuenta = pCtaDesti AND num_ctE = vNumCte;
				RETURN cod_ret;
			ELSE
				RETURN cod_ret;
			END IF;

		END IF;
		
	
	RETURN cod_ret;
END;
END PROCEDURE;