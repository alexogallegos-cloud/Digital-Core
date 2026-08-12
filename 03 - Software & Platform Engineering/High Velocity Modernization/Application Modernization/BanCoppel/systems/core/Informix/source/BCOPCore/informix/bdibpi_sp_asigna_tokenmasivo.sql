CREATE PROCEDURE "informix".sp_asigna_tokenmasivo(pUsrAtiende CHAR(9), pSolicitud varchar(10),pNumcte varchar(9),pToken varchar(10))
RETURNING CHAR(5) as P_COD_RET;

-- Realizó: Ilse Gómez
-- Modificación: Se crea procedimiento para realizar la asignación masiva de token
-- Solicitó: José de Jesus Nevarez
-- Fecha de Solicitud: 08-08-2014
-------------------------------------------------------------------------------------
-- Realizó: Ilse Gómez
-- Modificación: Se modifica sp para que inserte registro en la tabla bdibpi:tkn_guias
-- Solicitó: José de Jesus Nevarez
-- Fecha de Solicitud: 08-09-2014
-------------------------------------------------------------------------------------
-- Realizó: José de Jesus Nevarez
-- Modificación: Se modifica sp para que actualize el campo f_status de la tabla si_bpitoken
-- Solicitó: Gabriela Aguilar (BanCoppel)
-- Fecha de Solicitud: 11-11-2014
-------------------------------------------------------------------------------------

	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(5);
	
	DEFINE vEstatusSol		varchar(1);
	DEFINE vTipo			varchar(1);
	
	--Guias
	DEFINE vCteBco		CHAR(15);
	DEFINE vCtePred		CHAR(15);
	DEFINE vPeso		CHAR(5);
	DEFINE vContenido	CHAR(20);
	DEFINE vTipo2		CHAR(10);
	DEFINE vSecuencia	SMALLINT;
	DEFINE vValor		INTEGER;
	DEFINE vCcBco		CHAR(10);
	DEFINE vFlg			CHAR(1);

	LET vCteBco		= '';
   LET vCtePred		= '';
   LET vPeso		= '';
   LET vContenido	= '';
   LET vTipo2		= '';
   LET vSecuencia	= 0;
   LET vValor		= 0;
   LET vCcBco		= '';
   LET vFlg			= '';

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN

	    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			LET P_COD_RET    = SQL_ERR;
			RETURN P_COD_RET;
	    END EXCEPTION;

	    LET P_COD_RET = '00000';
   
		LET vEstatusSol = '';
		LET vTipo = '';
		
		--SET DEBUG FILE TO "/home/sysifx/ilse/sp_asigna_tokenMasivo.out";
		--TRACE ON;

		--Seleccionar el estatus de la solicitud
		SELECT estatus_sol 
		INTO vEstatusSol
		FROM bdibpi:"informix".tkn_solprocesadas
		WHERE solicitud = TRIM(pSolicitud)
		AND cliente = TRIM(pNumcte)
		AND dispositivo = TRIM(pToken);
		
		IF (vEstatusSol = '0') THEN 

			--Selecciona el tipo de solicitud
			SELECT tipo
			INTO vTipo
			FROM bdibpi:"informix".bpi_tokensolicitud
			WHERE solicitud = TRIM(pSolicitud)
			AND numcte = TRIM(pNumcte);
			
			--Cambia estatus de token	
			UPDATE bdibpi:"informix".tkn_nseries 
			SET id_status = '110', f_status = CURRENT ,canal='04' 
			WHERE ns_token = pToken;	
			
			--Registra el cambio de estatus del token
			INSERT INTO bdibpi:"informix".tkn_status_token (ns_token,actual,anterior,f_cambio_status, usr_cambio_status,canal) 
			VALUES(pToken, '110', '105', CURRENT, pUsrAtiende, '04');				

			--Actualiza el token asignado
			UPDATE bdibpi:"informix".bpi_tokensolicitud 
			SET ns_token = pToken, guia = 'F', proceso = '2'
			WHERE solicitud = TRIM(pSolicitud)
			AND numcte = TRIM(pNumcte);
		
			IF (vTipo!='6') THEN --Validar que sea distinto a tipo 6 porque no se actualiza token y estatus en si_bpitoken para solicitudes renovadas
				
				--Actualiza número de token al cliente para el uso de la banca 
				UPDATE bdinteg:"informix".si_bpitoken
				SET ns_token = pToken, id_status_token = '110', f_status = CURRENT
				WHERE num_cliente = TRIM(pNumcte);
				
				--Registra el cambio de estatus de la solicitud
				INSERT INTO bdibpi:"informix".tkn_stasolicitud (solicitud,anterior,actual,f_registro) 
				VALUES (pSolicitud,'100','110',CURRENT);
				
			ELSE 
				--Registra el cambio de estatus de la solicitud
				INSERT INTO bdibpi:"informix".tkn_stasolicitud (solicitud,anterior,actual,f_registro) 
				VALUES (pSolicitud,'200','110',CURRENT);
			END IF;
			
			--Formación de Guias
			SELECT TRIM(valor) INTO vCteBco FROM bdibpi:"informix".tkn_parametros WHERE id_param = '26';
			SELECT TRIM(valor) INTO vCtePred FROM bdibpi:"informix".tkn_parametros WHERE id_param = '27';
			SELECT TRIM(valor) INTO vPeso FROM bdibpi:"informix".tkn_parametros WHERE id_param = '28';
			SELECT TRIM(valor) INTO vContenido FROM bdibpi:"informix".tkn_parametros WHERE id_param = '29';
			SELECT TRIM(valor) INTO vTipo2 FROM bdibpi:"informix".tkn_parametros WHERE id_param = '30';
			SELECT TRIM(valor) INTO vSecuencia FROM bdibpi:"informix".tkn_parametros WHERE id_param = '31';
			SELECT TRIM(valor) INTO vValor FROM bdibpi:"informix".tkn_parametros WHERE id_param = '32';
			SELECT TRIM(valor) INTO vCcBco FROM bdibpi:"informix".tkn_parametros WHERE id_param = '33';
			SELECT TRIM(valor) INTO vFlg FROM bdibpi:"informix".tkn_parametros WHERE id_param = '34';
			
			INSERT INTO bdibpi:"informix".tkn_guias (cte_bco, cte_pred, cte_destino, peso, factura, comentario, 
			contenido, tipo, secuencia, valor, cc_bco, flg_retorno, f_registro)
			SELECT vCteBco,vCtePred,tk.numcte,vPeso,tk.token_asig || '-' || TRIM(tk.sucursal),tk.token_asig,
			vContenido, vTipo2,vSecuencia, vValor,vCcBco, vFlg,   CURRENT
			FROM bdibpi:"informix".tkn_tmpsolproceso tk
			WHERE ID = '2'
			AND numcte = pNumcte
			AND solicitud = pSolicitud;
			
		END IF;
		
		RETURN P_COD_RET;
	END;
END PROCEDURE;