CREATE PROCEDURE "informix".sp_regordenspei(
			pchrUsuario CHAR(8),
			pchrSucursal CHAR(4),
			pchrFolio CHAR(16),
			pmnyImporteOP MONEY(18,2),
			pintBancoRec INTEGER,
			pvchrNombreBenef VARCHAR(40),
			pvchrCtaBenef VARCHAR(20),
			pvchrRFCBenef VARCHAR(18),
			pvchrNombreBenef2 VARCHAR(40),
			pvchrCtaBenef2 VARCHAR(20),
			pvchrRFCBenef2 VARCHAR(18),
			pdtFechaValor DATE, 
			pvchrConceptoPago VARCHAR(210),
			pdecRefNum DECIMAL(7,0),
			pchrTrans CHAR(4),
                        pintTipoPago INTEGER,
			pintTipoOper INTEGER,
                        pchrCtaOrd VARCHAR(20),
                        pvchrRefCobranza1 VARCHAR(40),
                        pchrClavePago VARCHAR(10),
                        pchrNumCte VARCHAR(20))
RETURNING CHAR(5), CHAR(60), CHAR(30);

{
CREADO POR : Alejandro Rueda Sanchez.
FECHA DE CREACION : 20 de Octubre del 2006	
FUNCIONALIDAD : Utilizado por la aplicaciones del BANCO que registren ordenes de pago en SPEI
				El pago queda liquidado y pendiente de enviar.

Parametros de Entrada:
	pchrUsuario   : Clave del usuario de promocion que registra la operacion
	pchrSucursal  : Sucursal que registra el movimiento
	pchrFolio     : Folio generado al generar el movimiento
	pmnyImporteOP : Importe de la orden que se desea enviar.
	pintBancoRec  : Clave CESIF del banco beneficiario de la orden.
	pvchrNombreBenef : Nombre del Beneficiario.
	pvchrCtaBenef : CLABE del beneficiario de la orden.
	pvchrRFCBenef : (opcional) RFC del beneficiario de la orden.
	pvchrNombreBenef2 : Nombre del Beneficiario Vostro. (Tipo Pago 3)
	pvchrCtaBenef2 : CLABE del beneficiario de la orden Vostro. (Tipo Pago 3)
	pvchrRFCBenef2 :  RFC del beneficiario de la orden Vostro. (Tipo Pago 3)
	pvchrConceptoPago : Instrucciones o referencia del pago para el cliente o banco beneficiario.
	pdecRefNum    : Dato numerico que servira de referencia al beneficiario para indicar el concepto del pago.
	pchrTrans     : Codigo de la transaccion que genera el movimiento.
        pintTipoPago  : Tipo de Pago. 1=Cliente a Cliente, 2=Cliente a Ventanilla,
                                      3=Cliente a Cliente Vostro, 4=Cliente a Banco, 5=Banco a Cliente
                                      6=Banco a Cliente Vostro, 7=Banco a Banco
        pintTipoOper  : Tipo de Operacion.
        pchrCtaOrd    : No. de Cuenta del Cliente.
        pvchrRefCobranza1 : Referencia solo para cuentas concentradoras de cobranza.
        pvchrConceptoPago : Instrucciones o referencia del pago para el cliente o banco beneficiario.
        pchrClavePago : Clave de Pago (Tipo 2).
        pchrNumCte : Numero de Cliente.

Parametros de Salida:
	Codigo de Retorno : 	'000' - Si la orden pudo ser registrada correctamente.
        Descripcion del Error : <> '000' - Indica el error ocurrido al tratar de registrar la orden de pago.
	Clave de Rastreo : Entrega la clave de rastreo generada para la orden de pago registrada.
}
			
--Definicion de variables
DEFINE vchrcodret 	CHAR(5);
DEFINE vintcodret	INTEGER;
DEFINE vvchrCveRastreo	VARCHAR(30);
DEFINE vdtfecha		DATE;
DEFINE cVarDataErr      CHAR(60);


ON EXCEPTION SET vintcodret
	IF vintcodret <> 0 THEN
		LET vchrcodret= vintcodret;
		RETURN vchrcodret,'', '';
	END IF;
END EXCEPTION;

-- DEBUG FLAG
--SET debug file to "/tmp/sp_regordenspei.out";
--TRACE ON;

--Inicializacion de variables
LET vchrcodret = '000';
LET vvchrCveRastreo = '';
LET cVarDataErr ='';


-- Valida la Fecha de captura
if (pdtFechaValor is null) or (pdtFechaValor = '') then
    SELECT to_date(vchrValor, '%d/%m/%Y') INTO pdtFechaValor
    FROM tblParametros
    WHERE vchrCveParametro = 'FECHA_OPERACION';
    IF (pdtFechaValor is null) or (pdtFechaValor = '') then
        LET vchrcodret = '001'; --Falta parametro Fecha de Operacion
        EXECUTE PROCEDURE bdinteg:sp_desc_ret('21', vchrcodret)
        INTO vchrcodret, cVarDataErr;
        RETURN vchrcodret, cVarDataErr, '';
   end if;
end if;

--Registra la orden de pago en el sistema.
EXECUTE PROCEDURE sp_regordenpago(
			pchrUsuario,
			pchrSucursal,
			pchrFolio,
			pintBancoRec,
			'N',
			pdtFechaValor,
			pintTipoPago, --Tipo de pago 
			pintTipoOper,
			pmnyImporteOP,
			pchrCtaOrd,
			pvchrNombreBenef,
			pvchrCtaBenef,
			pvchrRFCBenef,
			0,
			pdecRefNum,
			pvchrRefCobranza1,
			pvchrConceptoPago,
                        pchrClavePago,
			pvchrNombreBenef2,
			pvchrRFCBenef2,
			pvchrCtaBenef2,
			pvchrConceptoPago,
			NULL,
			pchrTrans,
                        pchrNumCte) INTO vchrcodret, vvchrCveRastreo;

--Marca el pago como Listo para enviar
UPDATE tblpago 
SET chrestatusenvio = 'A',
--SET chrestatusenvio = 'N',
	chrusuariovent = pchrUsuario,
	chrfolioliqu = pchrFolio
WHERE vchrclaverastreo = vvchrCveRastreo
AND dtfechavalor = pdtFechaValor
AND chrestatusenvio = 'P';

--Entrega el codigo de retorno y clave de rastreo.		
  IF vchrcodret <> '000' then
     LET vvchrCveRastreo = '';
     EXECUTE PROCEDURE bdinteg:sp_desc_ret('21', vchrcodret)
     INTO vchrcodret, cVarDataErr;
  END IF;
RETURN vchrcodret, cVarDataErr, vvchrCveRastreo;
	
END PROCEDURE;