CREATE PROCEDURE "informix".sp_regordenprom(
			pchrUsuario CHAR(8),
			--->pchrSucursal CHAR(3),
			pchrSucursal CHAR(4),
			pchrFolio_prom CHAR(16),
			pvchrCuentaOrd VARCHAR(20),
			pmnyImporteOP MONEY(18,2),
			pintBancoRec INTEGER,
			pvchrNombreBenef VARCHAR(40),
			pintTipoCtaBenef INTEGER,
			pvchrCtaBenef VARCHAR(20),
			pvchrRFCBenef VARCHAR(18),
			pvchrConceptoPago VARCHAR(40),
			pdecRefNum DECIMAL(7,0),
			pvchrRefCobranza1 VARCHAR(40),			
			pchrCuenta CHAR(11),
			pchrPlaza CHAR(5),
			pchrTrans CHAR(4),
			pchrvalconvenio CHAR(1))
RETURNING CHAR(5), CHAR(30);

{
CREADO POR : Alberto Lopez de Lara
FECHA DE CREACION : 22 de Diciembre del 2003	
FUNCIONALIDAD : Utilizado por promocion para registrar ordenes de pago de tipo CLIENTE-CLIENTE.
MODIFICACION: Daniel Chirinos Lopez
              M-19/sep/2006
              - Se modifico las lineas que direccionaban a bdicent por bdinteg
              - Se modifico la sucursal de char(3) a char(4)
Parametros de Entrada:
	pchrUsuario : Clave del usuario de promocion que registra la operacion
	pchrSucursal : Sucursal que registra el movimiento
	pchrFolio_prom : Folio generado por promocion al generar el movimiento
	pvchrCuentaOrd : Numero de cuenta del cliente. 
	pmnyImporteOP : Importe de la orden que se desea enviar.
	pintBancoRec : Clave CESIF del banco beneficiario de la orden.
	pintTipoCtaBenef : Clave del tipo de Cuenta del Beneficiario. Se obtiene por medio del SPL sp_obttposcta().
	pvchrCtaBenef : CLABE del beneficiario de la orden.
	pvchrRFCBenef : (opcional) RFC del beneficiario de la orden.
	pvchrConceptoPago : Instrucciones o referencia del pago para el cliente o banco beneficiario.
	pdecRefNum : Dato numerico que servira de referencia al beneficiario para indicar el concepto del pago.
	pvchrRefCobranza1 : Se usara obligatoriamente para cuentas concentradoras de cobranza.
	pchrTrans : Codigo de la transaccion que genera el movimiento.
	pchrvalconvenio : 	1 - El pago debe ser validado por algun convenio registrado para el cliente.
				0 - No validar la orden contra convenios del cliente.

Parametros de Salida:
	Codigo de Retorno : 	'000' - Si la orden pudo ser registrada correctamente.
				<> '000' - Indica el error ocurrido al tratar de registrar la orden de pago.
	Clave de Rastreo : Entrega la clave de rastreo generada para la orden de pago registrada.
}
			
--Definicion de variables
DEFINE vchrcodret 	CHAR(5);
DEFINE vintcodret	INTEGER;
DEFINE vvchrCveRastreo	VARCHAR(30);
DEFINE vdtfecha		DATE;
DEFINE vintPermiteCta11 INTEGER;
DEFINE vchrFuente CHAR(7);

ON EXCEPTION SET vintcodret
	IF vintcodret <> 0 THEN
		LET vchrcodret= vintcodret;
		RETURN vchrcodret, vvchrCveRastreo;
	END IF;
END EXCEPTION;

-- DEBUG FLAG
--SET debug file to "/tmp/bel/sp_regordenpago.out";
--TRACE ON;

--Inicializacion de variables
LET vchrcodret = '000';
LET vvchrCveRastreo = '';

-- Se extrae la fecha del Movimiento
--->select fecha_hoy into vdtfecha from bdicent:si_fechas;
    select fecha_hoy into vdtfecha from bdinteg:si_fechas;

--Si no se ha enviado CLABE se arma por medio del
--banco, plaza y cuenta.
IF TRIM(pvchrCtaBenef) = '' THEN
	--Verifica si se permite recibir cuenta a 11 digitos
	SELECT vchrValor 
	INTO vintPermiteCta11
	FROM tblparametros
	WHERE vchrcveparametro = 'PERMITIR_CTA11';
	
	IF vintpermitecta11 IS NULL THEN
  		LET vchrcodret = '021'; --Falta parametro de permite cuenta.
		RETURN vchrcodret, vvchrCveRastreo;
	END IF;

	IF vintPermiteCta11 = 0 THEN
		LET vchrcodret = '020'; --No se permite cuenta a 11 digitos.
		RETURN vchrcodret, vvchrCveRastreo;
	END IF;
	
	EXECUTE PROCEDURE bditef:spobtenerccc(LPAD(pintBancoRec, 3, '0'), pchrplaza, pchrCuenta)
		INTO vchrCodRet, vchrFuente, pvchrCtaBenef;

	IF vchrCodRet <> 0 THEN
		RETURN vchrcodret, vvchrCveRastreo;
	END IF;		

END IF;


--Registra la orden de pago en el sistema.
EXECUTE PROCEDURE sp_regordenpago(
			pchrUsuario,
			pchrSucursal,
			pchrFolio_prom,
			pintBancoRec,
			pchrvalconvenio,
			vdtfecha,
			'1', --Tipo de pago CLIENTE-CLIENTE.
			NULL,
			pmnyImporteOP,
			pvchrCuentaOrd,
			pvchrNombreBenef,
			pvchrCtaBenef,
			pvchrRFCBenef,
			0,
			pdecRefNum,
			pvchrRefCobranza1,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			pvchrConceptoPago,
			NULL, --pchrFolio_prom,
			pchrTrans) INTO vchrcodret, vvchrCveRastreo;

--Entrega el codigo de retorno y clave de rastreo.		
RETURN vchrcodret, vvchrCveRastreo;
	
END PROCEDURE;