CREATE PROCEDURE "informix".sp_set_guias_admtoken(pNumSolicitud char(10), pNumCliente char(9), pToken char(9), pProceso char(1))
	returning char(5) as codRet;

--------------------------------------------------------------------------------------------
-- Realizó: Nubia Janeth Montoya Medina
-- Actividad: Registra los datos de las guías en el AdmToken
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 08/04/2010
-- Modifico: Javier Calderón
-- Actividad: Se convirtió la variable 'vPeso' a char(5)
-- Fecha de modificación: 11/01/2011
-- Solicitó: Mauricio León
--------------------------------------------------------------------------------------------
-- Realizó:José Rubén López
-- Actividad:Se modifican las banderas guia y proceso para la generacion de guia
-- Fecha de modificación: 01-10-2014
-- Solicitó:José de Jesus Nevarez
--------------------------------------------------------------------------------------------
-- Realizó:José Rubén López
-- Actividad:Se valida existencia de registro antes de hacer el insert en la tabla bdibpi:"informix".tkn_guias
-- Fecha de modificación: 17-10-2014
-- Solicitó:José de Jesus Nevarez
--------------------------------------------------------------------------------------------
-- Realizó:José de Jesús Nevarez
-- Actividad: Se modifica sp para que no actualize el campo proceso en la tabla bpi_tokensolicitud para el proceso masivo.
-- Fecha de modificación: 17-10-2014
-- Solicitó:Gabriela Aguilar (BanCoppel)
--------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
	DEFINE cod_ret      char(5);
	DEFINE sql_err      integer;
	DEFINE vCteBco		char(15);
	DEFINE vCtePred		char(15);
	DEFINE vPeso		char(5);
	DEFINE vContenido	char(20);
	DEFINE vTipo		char(10);
	DEFINE vSecuencia	smallint;
	DEFINE vValor		integer;
	DEFINE vCcBco		char(10);
	DEFINE vFlg			char(1);
	DEFINE vSuc			char(4);		
	DEFINE vFactura		char(14);
    	
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret      = '00000';
   LET vCteBco		= '';
   LET vCtePred		= '';
   LET vPeso		= '';
   LET vContenido	= '';
   LET vTipo		= '';
   LET vSecuencia	= 0;
   LET vValor		= 0;
   LET vCcBco		= '';
   LET vFlg			= '';
   LET vSuc			= '';
   LET vFactura		= '';
   
   	--SET DEBUG FILE TO "/home/nubia/sp_set_guias_admtoken.out";
    --TRACE ON;
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	SELECT TRIM(valor) INTO vCteBco FROM bdibpi:"informix".tkn_parametros WHERE id_param = '26';

	SELECT TRIM(valor) INTO vCtePred FROM bdibpi:"informix".tkn_parametros WHERE id_param = '27';

	SELECT TRIM(valor) INTO vPeso FROM bdibpi:"informix".tkn_parametros WHERE id_param = '28';

	SELECT TRIM(valor) INTO vContenido FROM bdibpi:"informix".tkn_parametros WHERE id_param = '29';

	SELECT TRIM(valor) INTO vTipo FROM bdibpi:"informix".tkn_parametros WHERE id_param = '30';

	SELECT TRIM(valor) INTO vSecuencia FROM bdibpi:"informix".tkn_parametros WHERE id_param = '31';

	SELECT TRIM(valor) INTO vValor FROM bdibpi:"informix".tkn_parametros WHERE id_param = '32';

	SELECT TRIM(valor) INTO vCcBco FROM bdibpi:"informix".tkn_parametros WHERE id_param = '33';

	SELECT TRIM(valor) INTO vFlg FROM bdibpi:"informix".tkn_parametros WHERE id_param = '34';
	
	SELECT TRIM(sucursal) INTO vSuc FROM bdibpi:"informix".bpi_tokensolicitud WHERE solicitud = pNumSolicitud;
	
	LET vFactura = pToken||'-'||TRIM(vSuc);
	--SE VALIDA QUE NO EXISTA EL REGISTRO ANTES DE INSERTAR 
	IF NOT EXISTS(SELECT cte_destino FROM bdibpi:"informix".tkn_guias WHERE cte_destino=pNumCliente AND comentario=pToken )THEN
		INSERT INTO bdibpi:"informix".tkn_guias (cte_bco, cte_pred, cte_destino, peso, factura, comentario, contenido, tipo, secuencia, valor, cc_bco, flg_retorno, f_registro)
		VALUES (vCteBco, vCtePred, pNumCliente, vPeso, vFactura, pToken, vContenido, vTipo, vSecuencia, vValor, vCcBco, vFlg, CURRENT);    
	END IF;
	
	--SE ACTUALIZA LAS BANDERAS DE GUIA Y PROCESO DE LA SOLICITUD
	IF (pProceso <> "0") THEN --CERO SOLO PARA PROCESO DE ASIGNACIÓN DE GUÍA MASIVO.
		UPDATE bdibpi:"informix".bpi_tokensolicitud SET guia='f', proceso=pProceso WHERE solicitud= pNumSolicitud AND numcte=pNumCliente;
	ELSE
		UPDATE bdibpi:"informix".bpi_tokensolicitud SET guia='f' WHERE solicitud= pNumSolicitud AND numcte=pNumCliente;
	END IF;
	
    RETURN cod_ret;

END

END PROCEDURE;