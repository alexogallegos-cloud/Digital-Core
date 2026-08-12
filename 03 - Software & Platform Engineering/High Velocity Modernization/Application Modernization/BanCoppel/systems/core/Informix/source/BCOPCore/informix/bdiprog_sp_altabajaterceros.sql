CREATE PROCEDURE "informix".sp_altabajaterceros(p_sTipoOperacion CHAR(2), p_sClaveCuenta CHAR(2), p_sNum_Cte CHAR(20), p_sCuenta CHAR(20), p_sCve_Banco CHAR(3), p_sDesc_cta CHAR(20), 
p_sNombre CHAR(60), p_sRfc CHAR(13), p_sEmail CHAR(100), p_sCve_Compania CHAR(2), p_sNo_Celular CHAR(10), p_sCanal_Alta CHAR(2), p_sCanal_Baja CHAR(2), p_sUser_Insert CHAR(8))
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
DEFINE v_iCuentasEfectivas INTEGER;
DEFINE v_iCuentasEfectivasActivas INTEGER;
DEFINE v_iContador INTEGER;
DEFINE vClaveCuenta CHAR(2);

-- **************************************************************************************************
-- Realizo: Marcos Cuevas                 
-- Actividad: Dar de alta y de baja       
-- Solicito:Aymme Osuna                    
--Fecha: 13/OCT/2008                    
-- Debug del Procedure                     
--Modifico: Alejandro Osuna Iza        	   
--Fecha: 26-Mayo-2009 					   
--Modificacion: se Agrego la validacion de la cuenta clabe y el banco, se agrego la validacion que almenso tenga una cuenta efectiva(2000,1300,1400,1600,1800,1500,1700)
--Modifico: Javier CalderÃÂ?n       		   
--Fecha: 12-MAyo-2010 					   
--Modificacion: Se agrego que actualice la hora de insercion al activar una cuenta frecuente cuando ÃÂ?sta ya exista
--
--Modifico: Francisco Rodriguez
--Fecha:16-Agosto-2010
--Modificacion: Se modifico para incluir la validacion de digito para cuenta frecuentes sky.
--
--Modifico: Javier CalderÃÂ?n
--Fecha:27-Agosto-2010
--Modificacion: Se modifico para incluir la validacion de digito para cuenta frecuentes Dish y MasTV.
--TRACE ON;                                      
--
--ModificÃÂ?: Mauricio LeÃÂ?n
--Fecha:28-Septiembre-2010
--Modificacion: Se agrega validaciÃÂ?n de claves de banco de Dish y MasTv en la validaciÃÂ?n de la referencia.
--
--ModificÃÂ?: Walber Castro
--Fecha:06-Septiembre-2011
--Modificacion: Se agregan a la validaciÃÂ?n de productos el 1200, 1600 y 2200 de EmpresaNET.

--ModificÃÂ?: Manuel Ramos
--Fecha:04-Junio-2012
--Modificacion: Se agregan a la validaciÃÂ?n de pago de servicios Arabela y ECI (clave banco 901 y 902)

--ModificÃÂ?: Berenice Noriega
--De: BanCoppel/Mantenimiento III/CoordinaciÃÂ?n Internet.
--Fecha:09-Diciembre-2013
--ModificaciÃÂ?n: Se agregan el producto 2700 en la validaciÃÂ?n "--Se valida que el cliente tenga por lo menos una cuenta efectiva"
-- y en "--Se valida que exista por lo menos una  cuenta del usuario si no existe manda el codigo de retorno 05 con su descripcion"

--ModificÃÂ?: Viridiana Paredes
--Folio: 216
--Fecha:29/03/2017
--ModificaciÃÂ?n: Se modifico parametro p_sEmail a char(100)"
-- **************************************************************************************************

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
LET v_iCuentasEfectivas=0;
LET v_iCuentasEfectivasActivas=0;
LET v_iContador=0;
LET vClaveCuenta ='';
--Inicio del procedimiento

	--SET DEBUG FILE TO "/informix/gaby/INC-frecuentesSPEI/isaac/sp_altabajaterceros.out";
	--TRACE ON;
	
SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

BEGIN

	IF p_sCanal_Alta = '01' AND p_sCanal_Baja = '00' THEN ----Se dio de alta este if para no permitir altas de pagos programadas desde ofi solamente para tarjetas de debito bancoppel
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '02';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	-- se valida el que el pClaveCuenta corresponda a  el pCuenta 
   -- IF (p_sTipoOperacion = '02') THEN
       SELECT cve_cuenta INTO vClaveCuenta FROM bdiprog:pp_ctasterceros WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco;
       --   IF (LENGTH(p_sCuenta) = 10 ) THEN
                  LET p_sClaveCuenta = vClaveCuenta;
        --   END IF;
    -- END IF;

	--Se valida que los parametros no este en blancos o en nulo
	LET p_sTipoOperacion=NVL(p_sTipoOperacion,'');
	IF (p_sTipoOperacion = '') THEN
		LET p_sTipoOperacion = '00';
	END IF;
	
	IF (p_sTipoOperacion <> '01') AND (p_sTipoOperacion <> '02') AND (p_sTipoOperacion <> '03') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '02';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	LET p_sClaveCuenta=NVL(p_sClaveCuenta,'');
	IF (p_sClaveCuenta = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '109';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	LET p_sNum_Cte=NVL(p_sNum_Cte,'');
	IF (p_sNum_Cte = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '104';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	LET p_sCuenta=NVL(p_sCuenta,'');
	IF (p_sCuenta = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '147';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	LET p_sCve_Banco=NVL(p_sCve_Banco,'');
	IF (p_sCve_Banco = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '111';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	LET p_sDesc_cta=NVL(p_sDesc_cta,'');
	IF (p_sDesc_cta = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '105';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	LET p_sNombre=NVL(p_sNombre,'');
	IF (p_sNombre = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '148';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	LET p_sCanal_Alta=NVL(p_sCanal_Alta,'');
	LET p_sCanal_Baja=NVL(p_sCanal_Baja,'');
	IF (p_sCanal_Alta = '') OR (p_sCanal_Baja = '')  THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '121';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF; 
	 
	LET p_sUser_Insert=NVL(p_sUser_Insert,'');
	IF (p_sUser_Insert = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '124';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	--Se valida Clave de Cuenta
	IF ((SELECT COUNT(cve_cuenta) FROM bdiprog:"informix".pp_tpcuenta WHERE cve_cuenta = p_sClaveCuenta) = 0) THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '03';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se valida Cliente 
	IF((SELECT COUNT(numcte) FROM bdinteg:"informix".si_cliente WHERE numcte = p_sNum_Cte) = 0) THEN 
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

	--Clave de Cuenta perteneciente a Coppel
	IF (p_sClaveCuenta = '01' AND p_sCve_Banco <> '137') OR (p_sClaveCuenta = '04' AND p_sCve_Banco <> '137') OR (p_sCve_Banco  = '137' AND p_sClaveCuenta <>  '01' AND p_sClaveCuenta <> '04') THEN
        SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '54';
        RETURN v_sCodRet, v_sMensajeRet;
    END IF;
  
	--Se valida Cta Efectiva que este activa  
	SELECT COUNT(*) 
	INTO v_iCuentasEfectivas
	FROM bdicheq:"informix".sc_maechq 
	WHERE num_cte = p_sNum_Cte 
	AND producto in (select producto from bdicheq:"informix".sc_producto where producto in('2000','1300','1400','1800','1500','1700','1900','2500','1200','1600','2200','2600','2700','2900'));
	
	IF(v_iCuentasEfectivas > 0) THEN
		SELECT COUNT(*) 
		INTO v_iCuentasEfectivasActivas
		FROM bdicheq:"informix".sc_maechq 
		WHERE num_cte = p_sNum_Cte
		AND producto  in (select producto from bdicheq:"informix".sc_producto where producto in('2000','1300','1400','1800','1500','1700','1900','2500','1200','1600','2200','2600','2700','2900'))
		AND  status_cta <> '2';
		
		IF(v_iCuentasEfectivasActivas = 0) THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '05';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELSE
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '217';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	  
	--Se valida que exista por lo menos una  cuenta del usuario si no existe manda el codigo de retorno 05 con su descripcion
	IF (p_sClaveCuenta = '01') OR (p_sClaveCuenta = '04') THEN 
		FOREACH
			SELECT {+INDEX (pp_producperm idx_pp_producperm)} producto INTO v_sProducto FROM bdiprog:"informix".pp_producperm WHERE permite_prog = 'S'
			IF v_iFlag = 0 THEN
			 	SELECT COUNT (cuenta) INTO v_iValoRCuenta FROM bdicheq:"informix".sc_maechq WHERE num_cte = p_sNum_Cte AND status_cta <> '2' AND  producto = v_sProducto;				 			
				
				IF v_iValoRCuenta <> 0 THEN
					LET v_iFlag = 1;
				END IF;
			END IF;
		END FOREACH;		
		IF v_iValoRCuenta = 0 THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '05';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	END IF;

	IF p_sClaveCuenta = '05' THEN 	-- ValidaciÃÂ?n temporal, en lo que se libera a Nivel Nacional y en Internet
		IF p_sCve_Banco = '000' THEN
			LET p_sCve_Banco='201';
		END IF; 
		
		LET v_Categoria = '0' || SUBSTR(p_sCve_Banco, 1,1);
		LET v_Convenio = '0' || SUBSTR(p_sCve_Banco, 2,2);
		SELECT statusconvenio INTO v_StatusConvenio FROM bdisac:"informix".sac_convenios WHERE numcategoria= v_Categoria AND numconvenio=v_Convenio;
		IF v_StatusConvenio <> 'A' THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '223';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELSE	 
		IF ((SELECT COUNT(banco) FROM bdinteg:"informix".si_bancos WHERE banco = p_sCve_Banco) = 0) THEN  --Se valida Clave de Banco
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '06';
			RETURN v_sCodRet, v_sMensajeRet;		 
		END IF;		 
	END IF;
	  
	--Se valida Clave de CompaÃÂ?ia
	LET p_sCve_Compania=NVL(p_sCve_Compania,'');
	IF (p_sCve_Compania <> '') OR ((SELECT COUNT(cve_compania) FROM bdiprog:"informix".pp_companias WHERE cve_compania = p_sCve_Compania) = 0) THEN
		SELECT cve_compania INTO v_sCveCompania FROM bdiprog:"informix".pp_companias WHERE cve_compania = p_sCve_Compania;
		IF (v_sCveCompania <> '00') THEN
			--Se valida el numero de celular y su longitud
			LET v_sFinCiclo = 'T';
			LET v_sValor = '';

			LET p_sNo_Celular=NVL(p_sNo_Celular,'');
			IF (p_sNo_Celular <> '') THEN 
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

	--Se valida Email
	LET p_sEmail=NVL(p_sEmail,'');
	IF (p_sEmail <> '') THEN
		EXECUTE PROCEDURE bdiprog:"informix".validaEmail(p_sEmail) INTO v_sCodRetEmail;
			IF v_sCodRetEmail <> '00000' THEN
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '212';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
	END IF;

	--Se valida Longitud CveBanco
	LET v_iTamCveBanco = LENGTH(p_sCve_Banco);
	IF (v_iTamCveBanco <> 3) THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '06';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
 
	--Se valida CveCta y Longitud
	IF (p_sClaveCuenta = '01') THEN
		LET v_iTamCuenta = LENGTH(p_sCuenta);
		IF (v_iTamCuenta <> 11) THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '15';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
 
		SELECT TRIM(cuenta),producto INTO v_sCuenta,v_sProductoPerm  FROM bdicheq:"informix".sc_maechq 	WHERE cuenta = p_sCuenta AND status_cta <> '2';		
		LET v_sCuenta=NVL(v_sCuenta,'');
		IF  v_sCuenta <> ''  THEN 
			IF ((SELECT {+INDEX (pp_producperm idx_pp_producperm)} COUNT(producto) FROM bdiprog:"informix".pp_producperm WHERE producto = v_sProductoPerm AND permite_prog = 'S') = 0) THEN
			 	SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '90'; --Producto de la Cta no existe como Producto Permitido
				RETURN v_sCodRet, v_sMensajeRet; 
			END IF;
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '89'; --Cuenta Inactiva o No existen cuentas
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
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes WHERE cve_mensaje = '15';
				RETURN v_sCodRet, v_sMensajeRet;
			ELSE				
				IF v_iFuenteError <> 1 THEN 
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '222'; --Digito Verificador de la Cuenta Invalido
				END IF;
			END IF;
		END IF;
		
	ELIF (p_sClaveCuenta = '03') THEN
		LET v_iTamCuenta = LENGTH(p_sCuenta);
        IF (v_iTamCuenta = 10) THEN
        ELIF (v_iTamCuenta = 16) THEN
        ELIF (v_iTamCuenta = 18) THEN
		ELIF (v_iTamCuenta <> 16) THEN
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
			ELSE
				SELECT num_credito,status_tar INTO v_sNumCredito,v_sStatusTarjeta FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = p_sCuenta;
				IF v_sStatusTarjeta = 'A' THEN			
					SELECT COUNT(*)
					INTO v_iContador
					FROM bdicred:"informix".sd_maecred mae
					INNER JOIN bdiprog:"informix".pp_producperm pro on mae.num_producto = pro.producto 
					WHERE num_credito = v_sNumCredito AND mae.status_cred <> 'CV' AND mae.num_producto = pro.producto AND pro.permite_prog = 'S';
					
						IF v_iContador = 0 THEN
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
 
	--Tipo de Operacion Alta('01')
	IF (p_sTipoOperacion = '01') THEN
		--Se valida el canal
		IF ((SELECT COUNT(cve_canal) FROM bdiprog:"informix".pp_tpcanal WHERE cve_canal = p_sCanal_Alta) = 0) THEN 
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '18';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
		
		LET p_sCanal_Baja=NVL(p_sCanal_Baja,'');
		IF ( p_sCanal_Baja = '') THEN
			LET p_sCanal_Baja = '00';
		END IF;
		
		--Se toma el valor de Bancoppel para compararlo con la CveBanco
		SELECT valor INTO v_sValorBanco FROM bdiprog:"informix".pp_parametros WHERE cve_param = '01';

		IF v_sValorBanco = p_sCve_Banco THEN
			--Se valida que exista alguna cuenta la cual nosea correspondiente al mismo cliente si existe manda el codigo de retorno 07 con su descripcion
			IF (p_sClaveCuenta = '04') THEN			
				SELECT COUNT(*) 
				INTO v_iContador
				FROM (SELECT cuenta,num_cte FROM bdicheq:"informix".sc_maechq WHERE cuenta = v_sNumCredito AND num_cte = p_sNum_Cte UNION
				SELECT num_credito,numcte FROM bdicred:"informix".sd_maecred WHERE num_credito = v_sNumCredito AND numcte = p_sNum_Cte);
					
				IF v_iContador > 0  THEN					
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '07';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;
			ELSE
				SELECT COUNT(*) 
				INTO v_iContador
				FROM (SELECT cuenta,num_cte FROM bdicheq:"informix".sc_maechq WHERE cuenta = p_sCuenta AND num_cte = p_sNum_Cte UNION
				SELECT num_credito,numcte FROM bdicred:"informix".sd_maecred WHERE num_credito = p_sCuenta AND numcte = p_sNum_Cte);
				
				IF v_iContador > 0  THEN
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '07';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;
			END IF;
		END IF; 
		
		--Se valida que exista el numCte, Cuenta, CveBanco
	 	SELECT cve_estado INTO v_sCveEstado FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = p_sNum_Cte 
		AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco;
			
		LET v_sCveEstado=NVL(v_sCveEstado,'');
		IF v_sCveEstado <> '' THEN
			IF (v_sCveEstado = '02') THEN
				UPDATE bdiprog:"informix".pp_ctasterceros SET descrip_cta = p_sDesc_cta,cve_cuenta = p_sClaveCuenta,
				nombre = p_sNombre,rfc = p_sRfc,direc_correo = p_sEmail,cve_compania = p_sCve_Compania,
				cve_estado = '01',no_celular = p_sNo_Celular,canal_alta = p_sCanal_Alta,canal_baja = p_sCanal_Baja,
				fecha_estado = current,user_insert = p_sUser_Insert,fecha_insert = current, hora_insert = current 
				WHERE num_cte = p_sNum_Cte AND 	cuenta = p_sCuenta AND cve_banco = p_sCve_Banco;

				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '00';
			ELSE
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '14';
			END IF;
		ELSE
			INSERT INTO bdiprog:"informix".pp_ctasterceros(num_cte,cuenta,cve_banco,descrip_cta,cve_cuenta,nombre,rfc,direc_correo,cve_compania,cve_estado,no_celular,canal_alta,canal_baja,fecha_estado,user_insert,fecha_insert)
			VALUES (p_sNum_Cte,p_sCuenta,p_sCve_Banco,p_sDesc_cta,p_sClaveCuenta,p_sNombre,p_sRfc,p_sEmail,p_sCve_Compania,'01',p_sNo_Celular,p_sCanal_Alta,p_sCanal_Baja,current,p_sUser_Insert,current);
			
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '00';
		END IF;
	ELIF (p_sTipoOperacion = '02') THEN --Tipo de Operacion Baja pp_ctasterceros('02')
	  
		IF ((SELECT COUNT(cve_canal) FROM bdiprog:"informix".pp_tpcanal WHERE cve_canal = p_sCanal_Baja) > 0) THEN 
			LET p_sCanal_Alta = '00';
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '18';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
		
		--Se valida que exista el numCte, Cuenta, CveBanco
		SELECT cve_estado INTO v_sCveEstado FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND
		cve_banco = p_sCve_Banco AND cve_cuenta = p_sClaveCuenta;
		IF (v_sCveEstado <> '') THEN
			IF v_sCveEstado = '01' THEN
				UPDATE bdiprog:"informix".pp_ctasterceros SET cve_estado = '02',canal_baja = p_sCanal_Baja,fecha_estado = current,
				user_insert = p_sUser_Insert WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco;
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '00';
			ELSE
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '10';
			END IF;   
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '09';
		END IF;
		
	ELSE   --Tipo de Operacion Baja pp_ctasterceros_bex('03')
		--Se valida el canal
		IF ((SELECT COUNT(cve_canal) FROM bdiprog:"informix".pp_tpcanal WHERE cve_canal = p_sCanal_Baja) > 0) THEN 
			LET p_sCanal_Alta = '00';
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '18';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
		
		IF ((SELECT COUNT(num_cte) FROM bdiprog:"informix".pp_ctasterceros_bex WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco ) > 0) THEN
			DELETE FROM bdiprog:"informix".pp_ctasterceros_bex WHERE num_cte = p_sNum_Cte AND cuenta = p_sCuenta AND cve_banco = p_sCve_Banco; 
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '00';
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '09'; --Cliente no Existe con Datos relacionados 
		END IF;	
	END IF;
	
    RETURN v_sCodRet, v_sMensajeRet;
END
END PROCEDURE;