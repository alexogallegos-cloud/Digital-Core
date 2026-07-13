CREATE PROCEDURE "informix".sp_regordenbcocte(
			pchrUsuario CHAR(8),
			--->pchrSucursal CHAR(3),
			pchrSucursal CHAR(4),
			pchrFolio CHAR(16),
			pmnyImporteOP MONEY(18,2),
			pintBancoRec INTEGER,
			pvchrNombreBenef VARCHAR(40),
			pintTipoCtaBenef INTEGER,
			pvchrCtaBenef VARCHAR(20),
			pvchrRFCBenef VARCHAR(18),
			pdtFechaValor DATE, 
			pvchrConceptoPago VARCHAR(40),
			pdecRefNum DECIMAL(7,0),
			pchrTrans CHAR(4))
RETURNING CHAR(5), CHAR(30);

{
CREADO POR : Alberto Lopez de Lara
FECHA DE CREACION : 22 de Diciembre del 2003	
FUNCIONALIDAD : Utilizado por la aplicaciones del BANCO que registren ordenes de pago de tipo BANCO-CLIENTE,
				El pago queda liquidado y pendiente de enviar.
MODIFICACION: Daniel Chirinos Lopez
              M-19/sep/2006
              - Se modifico la sucursal de char(3) a char(4)

Parametros de Entrada:
	pchrUsuario : Clave del usuario de promocion que registra la operacion
	pchrSucursal : Sucursal que registra el movimiento
	pchrFolio : Folio generado identificar el movimiento generar el movimiento
	pmnyImporteOP : Importe de la orden que se desea enviar.
	pintBancoRec : Clave CESIF del banco beneficiario de la orden.
	pintTipoCtaBenef : Clave del tipo de Cuenta del Beneficiario. Se obtiene por medio del SPL sp_obttposcta().
	pvchrCtaBenef : CLABE del beneficiario de la orden.
	pvchrRFCBenef : (opcional) RFC del beneficiario de la orden.
	pvchrConceptoPago : Instrucciones o referencia del pago para el cliente o banco beneficiario.
	pdecRefNum : Dato numerico que servira de referencia al beneficiario para indicar el concepto del pago.
	pchrTrans : Codigo de la transaccion que genera el movimiento.

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

ON EXCEPTION SET vintcodret
	IF vintcodret <> 0 THEN
		LET vchrcodret= vintcodret;
		RETURN vchrcodret, vvchrCveRastreo;
	END IF;
END EXCEPTION;

-- DEBUG FLAG
--SET debug file to "/tmp/sp_regordenpago.out";
--TRACE ON;

--Inicializacion de variables
LET vchrcodret = '000';
LET vvchrCveRastreo = '';

if (pdtFechaValor is null) or (pdtFechaValor = '') then
	SELECT to_date(vchrValor, '%d/%m/%Y') INTO pdtFechaValor
	FROM tblParametros
	WHERE vchrCveParametro = 'FECHA_OPERACION';
end if;

-- Se extrae la fecha del Movimiento
--select fecha_hoy into vdtfecha from bdicent:si_fechas;

--Registra la orden de pago en el sistema.
EXECUTE PROCEDURE sp_regordenpago(
			pchrUsuario,
			pchrSucursal,
			pchrFolio,
			pintBancoRec,
			'N',
			pdtFechaValor,
			'5', --Tipo de pago BANCO-TERCERO
			NULL,
			pmnyImporteOP,
			NULL,
			pvchrNombreBenef,
			pvchrCtaBenef,
			pvchrRFCBenef,
			0,
			pdecRefNum,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			pvchrConceptoPago,
			NULL,
			pchrTrans) INTO vchrcodret, vvchrCveRastreo;

--Marca el pago como Listo para enviar
UPDATE tblpago 
SET chrestatusenvio = 'N',
	chrusuariovent = pchrUsuario,
	chrfolioliqu = pchrFolio
WHERE vchrclaverastreo = vvchrCveRastreo
AND dtfechavalor = pdtFechaValor
AND chrestatusenvio = 'P';

--Entrega el codigo de retorno y clave de rastreo.		
RETURN vchrcodret, vvchrCveRastreo;
	
END PROCEDURE;