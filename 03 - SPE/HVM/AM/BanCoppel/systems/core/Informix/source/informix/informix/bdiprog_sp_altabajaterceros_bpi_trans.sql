CREATE PROCEDURE "informix".sp_altabajaterceros_bpi_trans(p_sTipoOperacion CHAR(2), p_sClaveCuenta CHAR(2), p_sNum_Cte CHAR(20), 
p_sCuenta CHAR(20), p_sCve_Banco CHAR(3), p_sDesc_cta CHAR(20), p_sNombre CHAR(60), p_sRfc CHAR(13), p_sEmail CHAR(40), 
p_sCve_Compania CHAR(2), p_sNo_Celular CHAR(10), p_sCanal_Alta CHAR(2), p_sCanal_Baja CHAR(2), p_sUser_Insert CHAR(8),p_CveCaducidad CHAR(1))
RETURNING CHAR(5), CHAR(60);

--Declaracion de variables

DEFINE v_sCveCuenta CHAR(2);
DEFINE v_sValorBanco CHAR(10);
DEFINE v_sCveCompania CHAR(2);
DEFINE v_sCveEstado CHAR(2);
DEFINE v_sNumCte CHAR(20);
DEFINE v_sCodRet CHAR(5);
DEFINE v_sMensajeRet CHAR(60);
DEFINE v_sProducto CHAR(4);
DEFINE v_iFlag INTEGER;
DEFINE v_iValoRCuenta INTEGER;
DEFINE v_iCelular INTEGER;
DEFINE v_iRfc INTEGER;
DEFINE v_iTamCuenta INTEGER;
DEFINE v_sCodigoError CHAR(5);
DEFINE v_iFuenteError SMALLINT;
DEFINE v_sNumCredito CHAR(20);
DEFINE v_iTamCveBanco INTEGER;
DEFINE v_sCuenta CHAR(20);
DEFINE v_sProductoPerm CHAR(4);
DEFINE v_iCuenta INTEGER;
DEFINE v_iLongCuenta INTEGER;
DEFINE v_sFinCiclo CHAR(1);
DEFINE v_sValor CHAR(1);
DEFINE v_sCuentaCon CHAR(20);
DEFINE v_iLongCelular INTEGER;
DEFINE v_sCelular CHAR(10);
DEFINE v_sCodRetEmail CHAR(5);
DEFINE v_sCodRetRfc CHAR(5);
DEFINE v_sCodRetValidaRef CHAR(5);
DEFINE v_sStatusTarjeta CHAR(1);
DEFINE v_sProducEfecti CHAR(4);
DEFINE v_sClabeBanco CHAR(3);
DEFINE v_sClabeCuenta CHAR(3);
DEFINE v_StatusConvenio CHAR(1);
DEFINE v_Categoria CHAR(2);
DEFINE v_Convenio CHAR(3);
DEFINE vFechaCaducidad DATE;
DEFINE vCveBanco CHAR(3);
-- *******************************************************************************************

	-- Se clono el SP sp_altabajaterceros para agregar el parametro de salida el tipo de caducidad
	-- Bibiana Gaxiola Verdugo
	-- 20/12/2012

	--Modificó: Berenice Noriega
	--De: BanCoppel/Mantenimiento III/Coordinación Internet.
	--Fecha:09-Diciembre-2013
	--Modificación: Se agregan el producto 2700 en la validación "--Se valida que el cliente tenga por lo menos una cuenta efectiva"
	-- y en "--Se valida que exista por lo menos una  cuenta del usuario si no existe manda el codigo de retorno 05 con su descripcion"

	-- Se agrega validación para los teléfonos frecuentes que son dados de alta en sucursal sin digito verificador,
	-- si ese es el caso, se permite la actualización del registro cuando el usuario intenta darlo de alta desde el portal ya con dígito verificador.
	-- Bibiana Gaxiola Verdugo
	-- 06/03/2014

	-- Se cambia la forma en que se suman los meses a las cuentas frecuentes de tipo 2
	-- Bibiana Gaxiola Verdugo.
	-- 31/10/2014
	
	-- Se agrega validación para números moviles en SPEI, para que no se pueda agregar el mismo número con bancos distinto
	-- Bibiana Gaxiola Verdugo
	-- 05/11/2014
	
	-- Se Clona el spl sp_altabajaterceros_bpi_trans para consultar cuentas transfer 
	-- René Aldana Hernández
	-- 06/13/2016
	
	-- Se Clona el spl sp_altabajaterceros_bpi_trans para consultar cuentas transfer 
	-- Héctor Ramón Moreno Moreno
	-- 24/11/2016

-- *******************************************************************************************

--Asignacion de variables



LET v_sCveCuenta = '';
LET v_sValorBanco = '';
LET v_sCveCompania = '';
LET v_sCveEstado = '';
LET v_sNumCte = '';
LET v_sCodRet = '';
LET v_sMensajeRet = '';
LET v_sProducto = '';
LET v_iFlag = 0;
LET v_iValoRCuenta = 0;
LET v_iCelular = 0;
LET v_iRfc = 0;
LET v_iTamCuenta = 0;
LET v_iTamCveBanco = 0;
LET v_sCuenta = '';
LET v_sProductoPerm = '';
LET v_iCuenta = 0;
LET v_iLongCuenta = 1;
LET v_sFinCiclo = 'T';
LET v_sValor = '';
LET v_sCuentaCon = '';
LET v_iLongCuenta = 1;
LET v_iLongCelular = 1;
LET v_sCelular = '';
LET v_sCodRetEmail = '';
LET v_sCodRetRfc = '';
LET v_sStatusTarjeta = '';
LET v_sProducEfecti = '';
LET v_sClabeBanco  = '';
LET v_sClabeCuenta = '';
LET v_StatusConvenio='';
LET v_sCodRetValidaRef='';
LET vFechaCaducidad = '';
LET vCveBanco = '';

--Inicio del procedimiento

	--SET DEBUG FILE TO "/home/informix/raldana/RQI10664TranfBanc/bdiprogsp_altabajaterceros_bpi_trns.out";
	--TRACE ON;
	
SET LOCK MODE TO WAIT 10;

BEGIN

	--Se valida que los parametros no este en blancos o en nulo

	IF (NVL(p_sTipoOperacion,'') = '') THEN
		LET p_sTipoOperacion = '00';
	END IF;

	IF (p_sTipoOperacion <> '01') AND (p_sTipoOperacion <> '02')THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '02';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	IF (NVL(p_sClaveCuenta,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '109';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	IF (NVL(p_sNum_Cte,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '104';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	IF (NVL(p_sCuenta,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '147';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	IF (NVL(p_sCve_Banco,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '111';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	IF (NVL(p_sDesc_cta,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '105';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	IF (NVL(p_sNombre,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '148';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	IF (NVL(p_sCanal_Alta,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '121';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	IF (NVL(p_sCanal_Baja,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '121';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	IF (NVL(p_sUser_Insert,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '124';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	--Se valida que exista la clave de la cuenta si no existe manda el codigo de retorno 03 con su descripcion
	IF NOT EXISTS (SELECT cve_cuenta FROM bdiprog:"informix".pp_tpcuenta WHERE cve_cuenta = p_sClaveCuenta) THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '03';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se valida que exista el cliente si no existe manda el codigo de retorno 04 con su descripcion
	IF NOT EXISTS (SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = p_sNum_Cte) THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '04';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se valida que no tenga letras la cuenta

	LET v_iCuenta = LENGTH(p_sCuenta);

	WHILE (v_iLongCuenta <= v_iCuenta) AND (v_sFinCiclo = 'T')
		LET v_sCuentaCon = SUBSTR(p_sCuenta,v_iLongCuenta,1);
		IF ((v_sCuentaCon >= '0') AND (v_sCuentaCon <= '9')) THEN
			LET v_sValor = 'A';
		ELSE
			LET v_sValor = 'B';
			LET v_sFinCiclo = 'F';
		END IF;
		LET v_iLongCuenta = ( v_iLongCuenta + 1);
	END WHILE;
	IF (v_sValor = 'B') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '206';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se valida que la clave de cuenta pertenesca a bancoppel

	IF (p_sClaveCuenta = '01' AND p_sCve_Banco <> '137') OR (p_sClaveCuenta = '04' AND p_sCve_Banco <> '137') OR(p_sClaveCuenta = '08' AND p_sCve_Banco <> '137') OR(p_sClaveCuenta = '09' AND p_sCve_Banco <> '137') OR (p_sCve_Banco  = '137' AND p_sClaveCuenta <>  '01' AND p_sClaveCuenta <> '04' AND p_sClaveCuenta <> '08' AND p_sClaveCuenta <> '09')THEN
        SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '54';
        RETURN v_sCodRet, v_sMensajeRet;
    END IF;

	--Se valida que el cliente tenga por lo menos una cuenta efectiva.
--	SELECT producto INTO v_sProducEfecti FROM bdicheq:sc_producto WHERE nombre  = 'CUENTA EFECTIVA';
 --Se quita la validación por k esta mal hecha JGP - 15/05/2009---Solucionado el dia 25-mayo-2009
	IF  EXISTS(Select cuenta,num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte = p_sNum_Cte
				AND producto in (select producto from bdicheq:"informix".sc_producto where producto in('2000','1300','1400','1600','1800','1500','1700','1900','2500','1200','1600','2200','2600','2700'))) THEN
		IF  EXISTS(Select cuenta FROM bdicheq:"informix".sc_maechq WHERE num_cte = p_sNum_Cte
					AND producto  in (select producto from bdicheq:"informix".sc_producto where producto in('2000','1300','1400','1600','1800','1500','1700','1900','2500','1200','1600','2200','2600','2700'))
--					AND  status_cta = '1') THEN
					AND  status_cta <> '2') THEN
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '05';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELSE
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '217';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	--Se valida que exista por lo menos una  cuenta del usuario si no existe manda el codigo de retorno 05 con su descripcion
	IF (p_sClaveCuenta = '01') OR (p_sClaveCuenta = '04') THEN
		IF p_sTipoOperacion = '01' THEN
			--SELECT producto INTO v_sProducEfecti FROM bdicheq:sc_producto WHERE nombre  = 'CUENTA EFECTIVA';
			IF  EXISTS(Select cuenta,num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte = p_sNum_Cte
						AND producto in (select producto from bdicheq:"informix".sc_producto where producto in('2000','1300','1400','1600','1800','1500','1700','1900','2500','1200','1600','2200', '2600','2700'))) THEN
			ELSE
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '217';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
		END IF;
		FOREACH
			SELECT producto INTO v_sProducto FROM bdiprog:"informix".pp_producperm WHERE permite_prog = 'S'
			IF v_iFlag = 0 THEN
				IF (p_sClaveCuenta = '01') OR (p_sClaveCuenta = '04') THEN
--					SELECT COUNT (cuenta) INTO v_iValoRCuenta FROM bdicheq:sc_maechq WHERE num_cte = p_sNum_Cte AND status_cta = '1' AND
					SELECT COUNT (cuenta) INTO v_iValoRCuenta FROM bdicheq:"informix".sc_maechq WHERE num_cte = p_sNum_Cte AND status_cta <> '2' AND
					producto = v_sProducto;
				END IF;

				IF v_iValoRCuenta <> 0 THEN
					LET v_iFlag = 1;
				END IF;
			END IF;
		END FOREACH;
			IF v_iValoRCuenta = 0 THEN
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '05';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
	END IF

	IF p_sClaveCuenta = '05' THEN
-- Validación temporal, en lo que se libera a Nivel Nacional y en Internet
       IF p_sCve_Banco = '000' THEN
          LET p_sCve_Banco='201';
       END IF;
--
		LET v_Categoria = '0' || SUBSTR(p_sCve_Banco, 1,1);
		LET v_Convenio = '0' || SUBSTR(p_sCve_Banco, 2,2);
		SELECT statusconvenio INTO v_StatusConvenio FROM bdisac:"informix".sac_convenios WHERE numcategoria= v_Categoria AND numconvenio=v_Convenio;
		IF v_StatusConvenio <> 'A' THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '223';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELSE
	--Se valida que exista la clave del banco si no existe manda el codigo de retorno 06 con su descripcion
		IF NOT EXISTS (SELECT banco FROM bdinteg:"informix".si_bancos WHERE banco = p_sCve_Banco) THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '06';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	END IF;
	--Se valida que exista la clave del banco si no existe manda el codigo de retorno 06 con su descripcion
	--IF NOT EXISTS (SELECT banco FROM bdinteg:si_bancos WHERE banco = p_sCve_Banco) THEN
	--	SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '06';
	--	RETURN v_sCodRet, v_sMensajeRet;
	--END IF;
	--Se valida que la clave de la compañia no este en blanco o en nulo

	IF (NVL(p_sCve_Compania,'') <> '') THEN
		--Se valida que exista la clave de la compañia si no existe manda el codigo de retorno 08 con su descripcion
		IF EXISTS ( SELECT cve_compania FROM bdiprog:"informix".pp_companias WHERE cve_compania = p_sCve_Compania) THEN
			SELECT cve_compania INTO v_sCveCompania FROM bdiprog:"informix".pp_companias WHERE cve_compania = p_sCve_Compania;
			IF (v_sCveCompania <> '00') THEN

				--Se valida el numero de celular y su longitud
				LET v_sFinCiclo = 'T';
				LET v_sValor = '';
				IF (NVL(p_sNo_Celular,'') <> '') THEN
					LET v_iCelular = LENGTH(p_sNo_Celular);
						IF (v_iCelular <> 10) THEN
							SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '16';
							RETURN v_sCodRet, v_sMensajeRet;
						END IF;
					WHILE (v_iLongCelular <= v_iCelular) AND (v_sFinCiclo = 'T')
						LET v_sCelular = SUBSTR(p_sNo_Celular,v_iLongCelular,1);
						IF ((v_sCelular >= '0') AND (v_sCelular <= '9')) THEN
							LET v_sValor = 'A';
						ELSE
							LET v_sValor = 'B';
							LET v_sFinCiclo = 'F';
						END IF;
						LET v_iLongCelular = ( v_iLongCelular + 1);
					END WHILE;
					IF (v_sValor = 'B') THEN
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '207';
						RETURN v_sCodRet, v_sMensajeRet;
					END IF;
				ELSE
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '16';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;
			ELSE
				LET p_sNo_Celular = '';
			END IF;
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '08';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELSE
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '08';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se valida la longitud del rfc
	IF (NVL(p_sRfc,'') <> '') THEN
		LET v_iRfc = LENGTH(p_sRfc);

--		IF (v_iRfc <> 13) THEN
--			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '211';
--			RETURN v_sCodRet, v_sMensajeRet;
--		ELSE
--			EXECUTE PROCEDURE bdiprog:sp_validaRFC(p_sRfc) INTO v_sCodRetRfc;
--			IF v_sCodRetRfc <> '000' THEN
--				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '211';
--				RETURN v_sCodRet, v_sMensajeRet;
--			END IF;
--		END IF;
	END IF;

	--Se valida Email
	IF (NVL(p_sEmail,'') <> '') THEN
		EXECUTE PROCEDURE bdiprog:"informix".validaEmail(p_sEmail) INTO v_sCodRetEmail;
			IF v_sCodRetEmail <> '00000' THEN
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '212';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
	END IF;

	--Se valida la longitud de la clave de banco
	LET v_iTamCveBanco = LENGTH(p_sCve_Banco);
	IF (v_iTamCveBanco <> 3) THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '06';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se valida la clave de la cuenta y su longitud
	IF (p_sClaveCuenta = '01') THEN
		LET v_iTamCuenta = LENGTH(p_sCuenta);
		IF (v_iTamCuenta <> 11) THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '15';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
--		IF EXISTS (SELECT cuenta,producto FROM bdicheq:sc_maechq WHERE cuenta = p_sCuenta AND status_cta = '1') THEN
		IF EXISTS (SELECT cuenta,producto FROM bdicheq:"informix".sc_maechq WHERE cuenta = p_sCuenta AND status_cta <> '2') THEN
--			SELECT cuenta,producto INTO v_sCuenta,v_sProductoPerm  FROM bdicheq:sc_maechq WHERE cuenta = p_sCuenta AND status_cta = '1';
			SELECT cuenta,producto INTO v_sCuenta,v_sProductoPerm  FROM bdicheq:"informix".sc_maechq WHERE cuenta = p_sCuenta AND status_cta <> '2';
			IF NOT EXISTS (SELECT producto FROM bdiprog:"informix".pp_producperm WHERE producto = v_sProductoPerm AND permite_prog = 'S') THEN
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '90';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '89';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELIF (p_sClaveCuenta = '02') THEN
		--Se valida que la clave de banco asociada a una cuenta de cheques, corresponda al banco de la cuenta clave.
		LET v_sClabeBanco  = substr(p_sCve_Banco,1,3);
		LET v_sClabeCuenta = substr(p_sCuenta,1,3);
		IF NOT v_sClabeBanco = v_sClabeCuenta THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '231';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
		LET v_iTamCuenta = LENGTH(p_sCuenta);
		IF (v_iTamCuenta <> 18) THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '15';
			RETURN v_sCodRet, v_sMensajeRet;
		ELSE
			EXECUTE PROCEDURE bdispei:"informix".sp_validadv(p_sCuenta) INTO v_sCodigoError,v_iFuenteError;
			IF v_sCodigoError <> 0 THEN
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '15';
				RETURN v_sCodRet, v_sMensajeRet;
			ELSE
				IF v_iFuenteError = 1 THEN
				ELSE
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '222';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF
			END IF;
		END IF;
	ELIF (p_sClaveCuenta = '03') THEN
		LET v_iTamCuenta = LENGTH(p_sCuenta);
		IF (v_iTamCuenta <> 16) THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '15';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELIF (p_sClaveCuenta = '06') THEN
		LET v_iTamCuenta = LENGTH(p_sCuenta);
		IF (v_iTamCuenta < 15 OR v_iTamCuenta > 16)  THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '15';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELIF (p_sClaveCuenta = '05') THEN
		IF (p_sCve_Banco = '601') THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_validasky(p_sCuenta) INTO v_sCodRetValidaRef;
			IF v_sCodRetValidaRef <>"00000" THEN
				RETURN "00002", '';
			END IF;
		ELIF (p_sCve_Banco = '602')  OR (p_sCve_Banco = '603') THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_valida_dv_dish(p_sCuenta) INTO v_sCodRetValidaRef; -- Valida DV para DISH y MasTV
			IF v_sCodRetValidaRef <>"00000" THEN
				RETURN "00002", '';
			END IF;
		ELIF (p_sCve_Banco = '901') THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_valida_dv_ref(p_sCuenta, 10) INTO v_sCodRetValidaRef; -- Valida DV para ECI
			IF v_sCodRetValidaRef <>"00000" THEN
				RETURN "00002", '';
			END IF;
		ELIF (p_sCve_Banco = '902') THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_valida_dv_ref(p_sCuenta, 8) INTO v_sCodRetValidaRef; -- Valida DV para ARABELA
			IF v_sCodRetValidaRef <>"00000" THEN
				RETURN "00002", '';
			END IF;
		END IF;
	ELSE
		IF (p_sClaveCuenta = '04') THEN
			LET v_iTamCuenta = LENGTH(p_sCuenta);
			IF (v_iTamCuenta <> 16) THEN
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '15';
				RETURN v_sCodRet, v_sMensajeRet;
			ELIF p_sTipoOperacion = '01' THEN 
				SELECT num_credito,status_tar INTO v_sNumCredito,v_sStatusTarjeta FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = p_sCuenta;
				IF v_sStatusTarjeta = 'A' THEN
					IF NOT EXISTS (SELECT DISTINCT num_credito FROM bdicred:"informix".sd_maecred mae,bdiprog:"informix".pp_producperm pro WHERE num_credito = v_sNumCredito AND
					mae.status_cred <> 'CV' AND mae.num_producto = pro.producto AND pro.permite_prog = 'S') THEN
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '17';
						RETURN v_sCodRet, v_sMensajeRet;
					END IF;
				ELSE
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '17';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;						
			END IF;
		END IF;
	END IF;

	--Se valida si el tipo de operacion es una alta ('01')

	IF (p_sTipoOperacion = '01') then
		--Se valida el canal
		IF NOT EXISTS(SELECT cve_canal FROM bdiprog:"informix".pp_tpcanal WHERE cve_canal = p_sCanal_Alta)THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '18';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
		IF (NVL(p_sCanal_Baja,'') = '') THEN
			LET p_sCanal_Baja = '00';
		END IF;

		--Se toma el valor de bancoppel para compararlo con la clave del banco haber si es la misma
		SELECT valor INTO v_sValorBanco FROM bdiprog:"informix".pp_parametros WHERE cve_param = '01';

		IF v_sValorBanco = p_sCve_Banco THEN
			--Se valida que exista alguna cuenta la cual nosea correspondiente al mismo cliente si existe manda el codigo de retorno 07 con su descripcion
			IF (p_sClaveCuenta = '04') THEN
				IF EXISTS(SELECT cuenta,num_cte FROM bdicheq:"informix".sc_maechq WHERE cuenta = v_sNumCredito AND num_cte = p_sNum_Cte UNION
				SELECT num_credito,numcte FROM bdicred:"informix".sd_maecred WHERE num_credito = v_sNumCredito AND numcte = p_sNum_Cte) THEN
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '07';
				RETURN v_sCodRet, v_sMensajeRet;
				END IF;
			ELIF EXISTS(SELECT cuenta,num_cte FROM bdicheq:"informix".sc_maechq WHERE cuenta = p_sCuenta AND num_cte = p_sNum_Cte UNION
				SELECT num_credito,numcte FROM bdicred:"informix".sd_maecred WHERE num_credito = p_sCuenta AND numcte = p_sNum_Cte) THEN
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '07';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
		END IF;
		--Se valida que exista el numero de cliente, la cuenta y la clave del banco sino se agrega y se manda el codigo de retorno '00' con su descripcion
		IF EXISTS(SELECT num_cte,cuenta,cve_banco FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco) THEN
			
			--Se toma el valor del estado y se valida que el estado sea 02 si el estado es 02 se actualiza y se manda el codigo de retorno '00' con su descripcion sino se manda el codigo de retorno '14' con su descripcion
			SELECT cve_estado INTO v_sCveEstado FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco;
		
			IF (v_sCveEstado = '02') THEN
								
				IF (p_CveCaducidad = '1') THEN -- Caducidad 48 horas (2 días)
					LET vFechaCaducidad = TODAY + 2 UNITS DAY;
				
				UPDATE bdiprog:"informix".pp_ctasterceros SET descrip_cta = p_sDesc_cta,cve_cuenta = p_sClaveCuenta,
				nombre = p_sNombre,rfc = p_sRfc,direc_correo = p_sEmail,cve_compania = p_sCve_Compania,
				cve_estado = '01',no_celular = p_sNo_Celular,canal_alta = p_sCanal_Alta,canal_baja = p_sCanal_Baja,
				fecha_estado = current,user_insert = p_sUser_Insert,fecha_insert = current, hora_insert = current ,
				cve_caducidad = p_CveCaducidad, fecha_caducidad = vFechaCaducidad
				WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco AND cve_cuenta = p_sClaveCuenta;
			
				ELIF (p_CveCaducidad = '2') THEN -- Caducidad 6 meses
					--LET vFechaCaducidad = TODAY + 6 UNITS MONTH;
					--LET vFechaCaducidad = TODAY + 180 UNITS DAY;
					-- Se utiliza la funcipon monthadd para generar la fecha de caducidad de las cuentas frec tipo 2
					SELECT bdicred:monthadd(fecha_hoy,6) INTO vFechaCaducidad FROM bdinteg:"informix".si_fechas;
					
					UPDATE bdiprog:"informix".pp_ctasterceros SET descrip_cta = p_sDesc_cta,cve_cuenta = p_sClaveCuenta,
				nombre = p_sNombre,rfc = p_sRfc,direc_correo = p_sEmail,cve_compania = p_sCve_Compania,
				cve_estado = '01',no_celular = p_sNo_Celular,canal_alta = p_sCanal_Alta,canal_baja = p_sCanal_Baja,
				fecha_estado = current,user_insert = p_sUser_Insert,fecha_insert = current, hora_insert = current ,
				cve_caducidad = p_CveCaducidad, fecha_caducidad = vFechaCaducidad
				WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco AND cve_cuenta = p_sClaveCuenta;
	
				ELIF (p_CveCaducidad = '3') THEN -- Caducidad indefinida - 1 año
					LET vFechaCaducidad = TODAY + 1 UNITS YEAR;
					
						
					UPDATE bdiprog:"informix".pp_ctasterceros SET descrip_cta = p_sDesc_cta,cve_cuenta = p_sClaveCuenta,
				nombre = p_sNombre,rfc = p_sRfc,direc_correo = p_sEmail,cve_compania = p_sCve_Compania,
				cve_estado = '01',no_celular = p_sNo_Celular,canal_alta = p_sCanal_Alta,canal_baja = p_sCanal_Baja,
				fecha_estado = current,user_insert = p_sUser_Insert,fecha_insert = current, hora_insert = current ,
				cve_caducidad = p_CveCaducidad, fecha_caducidad = vFechaCaducidad
				WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco AND cve_cuenta = p_sClaveCuenta;
				
				ELSE
					LET v_sCodRet = '00002';
					LET v_sMensajeRet = 'Caducidad inválida';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;

					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '00';
			
			ELIF (v_sCveEstado = '01') THEN --- Para cuentas Transfer
				IF (p_sClaveCuenta = '08' AND p_sCve_Banco = '137') THEN
					IF (p_CveCaducidad = '1') THEN -- Caducidad 48 horas (2 días)
						LET vFechaCaducidad = TODAY + 2 UNITS DAY;
					ELIF (p_CveCaducidad = '2') THEN -- Caducidad 6 meses
						--LET vFechaCaducidad = TODAY + 180 UNITS DAY;
						-- Se utiliza la funcipon monthadd para generar la fecha de caducidad de las cuentas frec tipo 2
						SELECT bdicred:monthadd(fecha_hoy,6) INTO vFechaCaducidad FROM bdinteg:"informix".si_fechas;
					ELIF (p_CveCaducidad = '3') THEN -- Caducidad Indefinida
						LET vFechaCaducidad = TODAY + 1 UNITS YEAR;
					END IF;
					
				SELECT cuenta INTO p_sCuenta FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco;
				IF ((p_sCuenta <> "" AND p_sCuenta IS NOT NULL) AND (p_sCanal_Baja <> '03')) THEN
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '14';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;
				
					UPDATE bdiprog:"informix".pp_ctasterceros SET descrip_cta = p_sDesc_cta,cve_cuenta = p_sClaveCuenta, nombre = p_sNombre,rfc = p_sRfc,direc_correo = p_sEmail,
					cve_compania = p_sCve_Compania,cve_estado = '01',no_celular = p_sNo_Celular,canal_alta = p_sCanal_Alta,canal_baja = p_sCanal_Baja,fecha_estado = current,
					user_insert = p_sUser_Insert,cve_caducidad = p_CveCaducidad, fecha_caducidad = vFechaCaducidad
					WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco AND cve_cuenta = p_sClaveCuenta;
				
				END IF;
				LET v_sCodRet = '00000';
				LET v_sMensajeRet = '';
				RETURN v_sCodRet, v_sMensajeRet;
			ELSE
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '14';
				
			END IF;
		ELSE
		
			IF (p_sClaveCuenta = '07') THEN --- Para números moviles en transferencias SPEI 
				-- Se valida que ya exista el número movil para el cliente
				IF (SELECT count(cuenta) FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta) = 1 THEN
					-- Se obtiene el banco del movil frecuente para compararse con el que se quiere registrar
					SELECT cve_banco INTO vCveBanco FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta;
					--Si es el mismo movil para el cliente pero con diferente banco se envía mensaje de que la cuenta ya existe
					IF (p_sCve_Banco = vCveBanco) THEN 
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '14';
						RETURN v_sCodRet, v_sMensajeRet;
					END IF;
				END IF;
			END IF;		
			
			IF (p_CveCaducidad = '1') THEN -- Caducidad 48 horas (2 días)
				LET vFechaCaducidad = TODAY + 2 UNITS DAY;

				INSERT INTO bdiprog:"informix".pp_ctasterceros(num_cte,cuenta,cve_banco,descrip_cta,cve_cuenta,nombre,rfc,direc_correo,cve_compania,cve_estado,no_celular,canal_alta,canal_baja,fecha_estado,user_insert,fecha_insert,cve_caducidad,fecha_caducidad,fecha_movtos)
				VALUES (p_sNum_Cte,p_sCuenta,p_sCve_Banco,p_sDesc_cta,p_sClaveCuenta,p_sNombre,p_sRfc,p_sEmail,p_sCve_Compania,'01',p_sNo_Celular,p_sCanal_Alta,p_sCanal_Baja,current,p_sUser_Insert,current,p_CveCaducidad, vFechaCaducidad, TODAY);

			ELIF (p_CveCaducidad = '2') THEN -- Caducidad 6 meses
				-- Se utiliza la funcipon monthadd para generar la fecha de caducidad de las cuentas frec tipo 2
				SELECT bdicred:monthadd(fecha_hoy,6) INTO vFechaCaducidad FROM bdinteg:"informix".si_fechas;
					
				INSERT INTO bdiprog:"informix".pp_ctasterceros(num_cte,cuenta,cve_banco,descrip_cta,cve_cuenta,nombre,rfc,direc_correo,cve_compania,cve_estado,no_celular,canal_alta,canal_baja,fecha_estado,user_insert,fecha_insert,cve_caducidad,fecha_caducidad,fecha_movtos)
				VALUES (p_sNum_Cte,p_sCuenta,p_sCve_Banco,p_sDesc_cta,p_sClaveCuenta,p_sNombre,p_sRfc,p_sEmail,p_sCve_Compania,'01',p_sNo_Celular,p_sCanal_Alta,p_sCanal_Baja,current,p_sUser_Insert,current,p_CveCaducidad, vFechaCaducidad, TODAY);
				
			ELIF (p_CveCaducidad = '3') THEN -- Caducidad indefinida - 1 año
				LET vFechaCaducidad = TODAY + 1 UNITS YEAR;
					
				INSERT INTO bdiprog:"informix".pp_ctasterceros(num_cte,cuenta,cve_banco,descrip_cta,cve_cuenta,nombre,rfc,direc_correo,cve_compania,cve_estado,no_celular,canal_alta,canal_baja,fecha_estado,user_insert,fecha_insert,cve_caducidad,fecha_caducidad,fecha_movtos)
				VALUES (p_sNum_Cte,p_sCuenta,p_sCve_Banco,p_sDesc_cta,p_sClaveCuenta,p_sNombre,p_sRfc,p_sEmail,p_sCve_Compania,'01',p_sNo_Celular,p_sCanal_Alta,p_sCanal_Baja,current,p_sUser_Insert,current,p_CveCaducidad, vFechaCaducidad, TODAY);
			
			ELIF (p_CveCaducidad is null) OR (TRIM(p_CveCaducidad) = '') THEN -- Cuando la clave caducidad es nula se registra la cuenta con caducidad indefinida automaticamente
				LET p_CveCaducidad = '3';
				LET vFechaCaducidad = TODAY + 1 UNITS YEAR;
					
				INSERT INTO bdiprog:"informix".pp_ctasterceros(num_cte,cuenta,cve_banco,descrip_cta,cve_cuenta,nombre,rfc,direc_correo,cve_compania,cve_estado,no_celular,canal_alta,canal_baja,fecha_estado,user_insert,fecha_insert,cve_caducidad,fecha_caducidad,fecha_movtos)
				VALUES (p_sNum_Cte,p_sCuenta,p_sCve_Banco,p_sDesc_cta,p_sClaveCuenta,p_sNombre,p_sRfc,p_sEmail,p_sCve_Compania,'01',p_sNo_Celular,p_sCanal_Alta,p_sCanal_Baja,current,p_sUser_Insert,current,p_CveCaducidad, vFechaCaducidad, TODAY);
						
			ELSE
					LET v_sCodRet = '00002';
					LET v_sMensajeRet = 'Caducidad inválida';
					RETURN v_sCodRet, v_sMensajeRet;
			END IF;
			
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '00';
		END IF;
	ELSE
		--Se valida el canal
		IF EXISTS(SELECT cve_canal FROM bdiprog:"informix".pp_tpcanal WHERE cve_canal = p_sCanal_Baja)THEN
			LET p_sCanal_Alta = '00';
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '18';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
		--Se valida que exista el estdo del cliente y se manda el codigo de retorno '09' con su descripcion
		IF EXISTS(SELECT cve_estado FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND
		cve_banco = p_sCve_Banco AND cve_cuenta = p_sClaveCuenta)THEN
			--Se toma el valor del estado y se valida que el estado sea 01 si el estado es 01 se actualiza y se manda el codigo de retorno '00' con su descripcion sino se manda el codigo de retorno '10' con su descripcion
			SELECT cve_estado INTO v_sCveEstado FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND
			cve_banco = p_sCve_Banco AND cve_cuenta = p_sClaveCuenta;
			IF v_sCveEstado = '01' THEN
				UPDATE bdiprog:"informix".pp_ctasterceros SET cve_estado = '02',canal_baja = p_sCanal_Baja,fecha_estado = current,
				user_insert = p_sUser_Insert WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco ;
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '00';
			ELSE
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '10';
			END IF;
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '09';
		END IF;
	END IF;
    RETURN v_sCodRet, v_sMensajeRet;
END
END PROCEDURE;