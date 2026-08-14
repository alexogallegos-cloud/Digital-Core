CREATE PROCEDURE "informix".sp_registraoperacion( pNumCte CHAR(20), pIdUsuario INTEGER, pIdOper CHAR(4), pFoliOperacion CHAR(20), pStatus CHAR(1), 
pNumCtaOri CHAR(20), pProdCtaOri CHAR(4), pCveCtaDest CHAR(2), pNumCtaDest CHAR(20), pBancoDest CHAR(3), pBeneficiario CHAR(100),
pCveNotifica CHAR(2), pBenEmail CHAR(40), pBenCveCompania CHAR(2), pBenCelular CHAR(10), pImporte Money(16,2), pImporteComis MONEY(16,2),
pRefOri CHAR(40), pRefDes CHAR(40), pRefNumSpei CHAR(8), pNomArchivo CHAR (20), pFechaOper DATE, pFechaAplica DATE )

RETURNING CHAR(5),CHAR(100);

DEFINE sql_err INTEGER;
DEFINE vcCodRet CHAR(6);
--DEFINE vcCodRet1 CHAR(5);
--DEFINE vcMensaje CHAR(250);

DEFINE vdFechaHoy DATE;
DEFINE v_sProducto CHAR(5);
DEFINE vcEsNumerico CHAR(1);


LET sql_err = 0;
LET vcCodRet = '00000';

LET v_sProducto = '';
LET vcEsNumerico = '';

--****************************************************************************************************
-- DESCRIPCION:  Gearda la operacion en la tabla bei_autorizaoperacion
-- AUTOR : SOLSER
-- FECHA : 
-- BD: bdibei
-- SOLICITO : BanCoppel.
-- LIBERADO A PRODUCCION: Mayo 2014
--***************************************************************************************************


 BEGIN
        ON EXCEPTION SET sql_err
            LET vcCodRet = sql_err;
            RETURN vcCodRet,'';
        END EXCEPTION;
		
	--Validaciones generales..
	--valida clave de operación
	IF (NVL(pIdOper,'') = '')  THEN
		RETURN '00001', "La Operacion no puede ser un valor nulo o vacio";
	END IF;
	
	--valida usuario
	IF (NVL(pIdUsuario,0) = 0)  THEN
		RETURN '00001', "La Operacion no puede ser un valor nulo o vacio";
	ELSE
		IF NOT EXISTS( SELECT id_usuario FROM bdibei:bei_usuario a WHERE a.numcte = pNumCte AND a.id_usuario = pIdUsuario AND a.id_status = 30 AND a.id_tipo_usuario = 2) THEN
			RETURN '00002', "El Usuario no existe o no tiene su servicio activo o no es operador";
		END IF;	
	END IF;	
	
	--se valida el numero de cliente
	IF (NVL(pNumCte,'') = '')  THEN
		RETURN '00003', "El NumCte no puede ser un valor nulo o vacio";
		---se valida que el cliente exista
	ELSE
		IF NOT EXISTS( SELECT a.numcte FROM bdinteg:si_cliente as a, bdibei:bei_contratacion as b WHERE a.numcte = pNumCte AND b.num_cliente = a.numcte) THEN
			-- CLIENTE NO EXISTE.
			RETURN '00004',"Cliente no existe o no tiene servicio EmpresaNet";
		END IF;
	END IF;
	
	--se valida que la cuenta origen no sea igual a la cuenta destino
	IF TRIM(pNumCtaDest) = TRIM(pNumCtaOri) THEN
		RETURN '00006', "la cuenta origen y destino no pueden ser la misma";
	END IF;
	  
	--se valida la cuenta origen
	IF (NVL(pNumCtaOri,'') = '')  THEN
		RETURN '00005', "la cuenta origen no puede venir vacia";
	ELSE
		--se valida que la cuenta origen exista y no esté cancelada
		SET ISOLATION TO DIRTY READ;
		SELECT NVL(TRIM(producto),'') INTO v_sProducto FROM bdicheq:sc_maechq  WHERE cuenta = pNumCtaOri and num_cte = pNumCte and status_cta <> '2'; 
		IF v_sProducto = '' THEN
			RETURN '00007', "La cuenta no pertence al cliente o está cancelada";
		ELSE	
			--Validar producto permitido.
			SET ISOLATION TO DIRTY READ;
			IF NOT EXISTS( SELECT producto FROM bdibpi:bpi_pprod WHERE id_oper = TRIM(pIdOper) AND producto = pProdCtaOri) THEN
				RETURN '00008',"El producto no está permitido para la operación";
			END IF;
		END IF;
	END IF;	
	
	---graba operación en tabla
	INSERT INTO bdibei:bei_autorizaoperacion (num_cte,id_usuario,id_operacion,folio_operacion,status_oper,cuenta_origen,prod_ctaorigen,cve_cuenta_dest,cuenta_destino,banco_destino,
	                                          nombre_beneficiario,cve_notifica,email_beneficiario,telefono_beneficiario,cia_tel_beneficiario,importe,importe_comision ,
											  ref_origen,ref_destino,ref_numerica_spei,f_operacion ,f_aplicacion,nombre_archivo,f_registro)
	 VALUES (pNumCte,pIdUsuario,pIdOper,pFoliOperacion,pStatus,pNumCtaOri,pProdCtaOri,pCveCtaDest,pNumCtaDest,pBancoDest,pBeneficiario,pCveNotifica,pBenEmail,pBenCelular,
	          pBenCveCompania,pImporte,pImporteComis,pRefOri,pRefDes,pRefNumSpei,pFechaOper,pFechaAplica,pNomArchivo,CURRENT);
	
	RETURN '00000',"Se registró correctamente la operación";
	
	--aqui va la validación del resto de los campos dependiendo del tipo de operación a registrar

 END

END PROCEDURE;