CREATE PROCEDURE "informix".con_canc_audi() RETURNING
		 char(5),
         char(3),
         char(30),
         char(20),
         char(20),
         char(20),
         money(17,2),
         char(60),
         char(100);
{

MODIFICACION: Daniel Chirinos Lopez
              M-19/sep/2006
              - Se modifico las lineas que direccionaban a bdicent por bdinteg
              - Se modifico la sucursal de char(3) a char(4)
}
	DEFINE cod_ret				char(5);
	--->DEFINE vsucursal			char(3);
	DEFINE vsucursal			char(4);
	DEFINE vfolio				char(30);
	DEFINE vcuenta            	char(20);
	DEFINE vcliente           	char(20);
	DEFINE vnombre            	char(60);
	DEFINE vmonto             	money(17,2);
	DEFINE vtransaccion       	char(60);
	DEFINE vmotivo_modulo     	char(100);
	DEFINE sql_err            	integer;

	DEFINE iCveTipoPago	     	integer;
	DEFINE iCveTipoOperacion  	integer;

	DEFINE vapell_paterno     	char(15);
	DEFINE vapell_materno     	char(15);
	DEFINE vnombre1           	char(15);
	DEFINE vnombre2           	char(15);
	DEFINE v_ctaord         	char(20);
	DEFINE contador           	smallint;
	DEFINE vrazon_social      	char(40);

	LET cod_ret = "000";
	LET vsucursal = " ";
	LET vfolio = " ";
	LET vcuenta = " ";
	LET vcliente = " ";
	LET vnombre = " ";
	LET vmonto = 0;
	LET vtransaccion = " ";
	LET vmotivo_modulo = " ";
	LET contador = 0;

	--SET DEBUG FILE TO "con_canc_audi.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
		 IF sql_err <> 0 THEN
		    LET cod_ret = sql_err;
		    RETURN cod_ret, vsucursal, vfolio, vcuenta,
		            vcliente,vnombre, vmonto, vtransaccion,
		            vmotivo_modulo;
		 END IF;
		END EXCEPTION;

		FOREACH
			SELECT 	p.vchrclaverastreo, p.vchrcuentaord, p.mnyimporte,
					p.intcvetipopago, tp.vchrdescripcion, p.vchrcuentaord,
					p.intcvetpooperacion
			INTO   	vfolio, vcuenta, vmonto, iCveTipoPago, vnombre,
					v_ctaord, iCveTipoOperacion
			FROM 	bdispei:tblpago p, bdispei:tbltipopago tp
			WHERE 	chrestatusenvio = "X"
			AND 	p.intcvetipopago = tp.intcvetipopago
			AND 	(
					p.intcvetipopago = 1 OR -- Op. T-T
					(p.intcvetipopago = 5 AND v_ctaord = '060320022770006074') OR -- Op. Bco-T Cambios
					(p.intcvetipopago = 7 AND p.intcvetpooperacion = 6) -- Op. Bco-Bco Cambios
			 		)

			LET contador = contador + 1;
			LET vtransaccion = iCveTipoPago ||" "||TRIM(vnombre);

			IF iCveTipoPago = 1 THEN
				SELECT	apell_paterno,apell_materno,nombre1,nombre2,razon_social
				INTO   	vapell_paterno,  vapell_materno, vnombre1, vnombre2,
						vrazon_social
				--->FROM 	bdicent:si_cliente
				FROM 	bdinteg:si_cliente
				WHERE 	numcte = vcliente;

				IF vapell_paterno IS NULL OR TRIM(vapell_paterno) = "" THEN
					LET vnombre = vrazon_social;
				ELSE
					LET vnombre = TRIM(vapell_paterno)||" "||
									TRIM(vapell_materno)||" "||
									TRIM(vnombre1)||" "||TRIM(vnombre2);
				END IF;
			END IF;

			RETURN cod_ret, vsucursal, vfolio, vcuenta,
				vcliente, vnombre,vmonto, vtransaccion,
				vmotivo_modulo with resume;

		END FOREACH;

		-- dar de alta el codigo de retorno 001 con descripcion sin datos
		IF contador = 0 THEN
		 LET cod_ret = "001";
		 RETURN cod_ret, vsucursal, vfolio, vcuenta,
		        vcliente, vnombre,vmonto, vtransaccion,
		        vmotivo_modulo;
		END IF;

	END
END PROCEDURE;