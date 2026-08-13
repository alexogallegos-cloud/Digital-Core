CREATE PROCEDURE "informix".sp_reimprimeboleto(pfoliosuc CHAR (20))

RETURNING
 	CHAR(6) AS cCodret,
 	CHAR (4) AS cProducto,
	CHAR (4) AS cNumTran,
	MONEY(14,2) AS cMonto,
	CHAR (20) AS cNumCte,
	CHAR(50) AS cDescripcion,
	INTEGER  AS iNumBolMin,
	INTEGER AS iNumBolMax,
	INTEGER AS iNumerodeBoletos,
	CHAR(4) AS cSucursal;

--definicion de variables
	DEFINE sql_err 		INTEGER;
	DEFINE cCodret 		CHAR(6);
	DEFINE cProducto 	CHAR (4);
	DEFINE cNumTran		CHAR (4);
	DEFINE cMonto		MONEY(14,2);
	DEFINE cNumCte		CHAR (20);
	DEFINE cDescripcion CHAR(50);
	DEFINE iNumerodeBoletos SMALLINT;
	DEFINE cCuenta 		CHAR(20);
	DEFINE iNumBolMin   INTEGER;
	DEFINE iNumBolMax	INTEGER;
	DEFINE iTipoMovto	INTEGER;
	DEFINE cSucursal 	CHAR(4);
	DEFINE iMovtosCredito	INTEGER;
	DEFINE cCodFun		CHAR(3);
	DEFINE cCodRef		CHAR(4);
	DEFINE dFecha		DATE;


--Asignacion de variables
    LET  sql_err 	= 0;
	LET  cCodret	= '000000';
	LET  cProducto 	= '';
	LET  cNumTran	= '';
	LET  cCodFun = '';
	LET  cCodRef = '';
	LET  cNumCte	= '';
	LET  cDescripcion = '';
	LET  cSucursal  = '';
	LET  cMonto		= 0.00;
	LET  iNumerodeBoletos = 0;
	LET  cCuenta 	= '';
	LET  iNumBolMin = 0;
	LET  iNumBolMax = 0;
	LET  iTipoMovto = 0;
	LET  iMovtosCredito = 0;
	LET  dFecha = '01-01-1900';


	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let cCodret = sql_err;
				RETURN cCodret,'','',0,00,'',0, 0, 0,'';
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_reimprimeboleto.out";
		--TRACE ON;
		SELECT fecha_hoy
		INTO dFecha
		FROM bdinteg:si_fechas;

		SET ISOLATION TO DIRTY READ;

		IF EXISTS (	SELECT transacc FROM bdicheq:sc_movdia WHERE empresa = '001'
					AND folio_suc = pfoliosuc  AND cancelad <> 'S' AND fech_val = dFecha) THEN
			LET iTipoMovto = 1; --DEBITO
		ELIF EXISTS (	SELECT transacc_suc FROM bdicred:sd_movdia WHERE folio_suc = pfoliosuc
						AND reversado <> 'S' AND fecha_mov = dFecha) THEN
			LET iTipoMovto = 2; --CREDITO
		END IF;

		IF iTipoMovto > 0 THEN

            SELECT {+INDEX(si_boleto inx3_si_boleto)}
                   NVL(COUNT(*),0) AS Numero, NVL(min(boleto),0), NVL(max(boleto),0)
            INTO iNumerodeBoletos, iNumBolMin, iNumBolMax
			FROM bdinteg:si_boleto
            WHERE cve_sorteo = '00001'
            AND fecha = dFecha
            AND foliosuc = pfoliosuc;

			IF iTipoMovto = 1 THEN
				IF iNumerodeBoletos = 0  THEN
					Let cCodret = '000002'; --No tiene boletos
				ELSE
					Let cCodret = '000001'; -- Tiene Boletos
				END IF;
				--Obtine los datos necesarios para imprimir los boletos
					SET ISOLATION TO DIRTY READ;

					SELECT a.producto, a.transacc_suc,a.monto_tot, b.num_cte ,a.sucursal
					INTO cProducto, cNumTran, cMonto, cNumCte, cSucursal
					FROM bdicheq:sc_movdia as a, bdicheq:sc_maechq  as b
					WHERe a.empresa = '001'
					AND a.folio_suc = pfoliosuc
					AND a.cancelad <> 'S'
					AND a.cuenta = b.cuenta	;

			ELIF iTipoMovto = 2 THEN
				IF iNumerodeBoletos = 0  THEN
					Let cCodret = '000002'; --No tiene boletos
				ELSE
					Let cCodret = '000001'; -- Tiene Boletos
				END IF;
				--Trae los datos necesarios para generar los boletos e imprimirlos
					SET ISOLATION TO DIRTY READ;

					SELECT COUNT(*)
					INTO iMovtosCredito
					FROM bdicred:sd_movdia
					WHERE folio_suc = pfoliosuc
					AND sucursal IS NOT NULL;
					IF iMovtosCredito > 1 THEN
						SELECT a.num_producto, a.transacc_suc,a.monto,b.numcte,a.sucursal
						INTO cProducto, cNumTran, cMonto, cNumCte,cSucursal
						FROM bdicred:sd_movdia as a, bdicred:sd_maecred  as b
						WHERE a.folio_suc = pfoliosuc
						AND a.reversado <> 'S'
						AND a.num_credito = b.num_credito
                        AND a.codigo_fun IN ('033','336')
                        AND a.codigo_ref = '1';
					ELIF iMovtosCredito = 1 THEN
						SELECT a.num_producto, a.transacc_suc,a.monto,b.numcte,a.sucursal, a.codigo_fun, codigo_ref
						INTO cProducto, cNumTran, cMonto, cNumCte,cSucursal, cCodFun, cCodRef
						FROM bdicred:sd_movdia as a, bdicred:sd_maecred  as b
						WHERE a.folio_suc = pfoliosuc
						AND a.reversado <> 'S'
						AND a.num_credito = b.num_credito;

						IF cCodFun = '336' AND cCodRef = '20' THEN
							LET cNumTran = '608';
						END IF;
					END IF;
			END IF;
		ELSE
			LET cCodret = '000100';
		END IF;
		RETURN cCodret,cProducto,cNumTran,cMonto,cNumCte,cDescripcion,iNumBolMin, iNumBolMax, iNumerodeBoletos,cSucursal WITH RESUME;
	END;
END PROCEDURE
DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Procedimiento que busca, los boletos que tenga el número de folio ingresado como Parametro de entrada',
'FECHA      : 20/11/2009',
'VERSION    : 20091120.1630',
'BD         : BDINTEG',
'MODIFICO   : Julio Cesar Polanco',
'DESCRIPCION: Se modifica para que la consulta a la tabla si_boleto use el indice inx3_si_boleto',
'FECHA      : 15/12/2009',
'VERSION    : 20091215.1300',
'MODIFICO   : Jose Angel Lopez Adams',
'DESCRIPCION: Se modifica para buscar solo los movimientos del codigo_fun 033 y 336 de credito',
'FECHA      : 18/12/2009',
'VERSION    : 20091218.1300';

CREATE PROCEDURE "informix".sp_consemp( pEmpresa char (3),pNumEmp char(8))
RETURNING char (5), char (5), char (45);

--Define variables
define sql_err integer;
define cod_ret char (5);
define cod_ret2 char (5);
define pNombre char(45);


--Inicializa variables
LET sql_err = 0;
LET cod_ret = '00000';
LET cod_ret2 = '00000';
LET pNombre = '';


BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret,cod_ret2,pNombre;
   END EXCEPTION;

   EXECUTE PROCEDURE sp_consulta_empleado_iccat(pEmpresa,pNumEmp)
	INTO cod_ret2, pNombre;

	RETURN cod_ret,cod_ret2,pNombre;

END;

END PROCEDURE;