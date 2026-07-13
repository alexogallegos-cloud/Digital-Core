CREATE PROCEDURE "informix".sp_validapagotdc_bpi(pCtaOrigen VARCHAR(20), pCtaDestino VARCHAR(20))
	returning char(5);


	-- Se modifica para Pago TDC terceros BanCoppel
	-- 10/12/2013
	-- Bibiana Gaxiola Verdugo.
	--Se agrega return para validaciÃ²n de las cuentas
	--04/08/2020
	--Alejandro Vazquez.

	--DEFINICION DE VARIABLES
	DEFINE cod_ret char(5);
	DEFINE sql_err integer;
	DEFINE com_err varchar(100);
	DEFINE vCteOrigen varchar(9);
	DEFINE vCteDestino varchar(9);
	DEFINE vStatusCtaOr varchar(2);

	--INICIALIZA VARIABLES
	LET cod_ret  = "000";
	LET com_err = "";
	LET vCteOrigen = "";

	--SET DEBUG FILE TO '/home/informix/bibiana/sp_validapagotdc_bpi.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret;
			END IF ;
		END EXCEPTION ;

    
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

		SELECT num_cte,status_cta           ---OBTENIENDO EL  NUMCTE
		INTO vCteOrigen,vStatusCtaOr
		FROM bdicheq:sc_maechq WHERE cuenta = pCtaOrigen;

		--IF NVL(vCteOrigen, "") <> "" AND vStatusCtaOr = 1 THEN
		IF NVL(vCteOrigen, "") <> "" AND vStatusCtaOr = 2 THEN
				LET cod_ret = '505';
				LET com_err = "La cuenta origen no existe o estÃ¡ inactiva " || pCtaOrigen;
				INSERT INTO bdinteg:si_bpinusuales(
				f_registro,
				id_operacion,
				cta_origen,
				cta_destino,
				cod_err,
				desc_err) VALUES (current,'1011',pCtaOrigen,pCtaDestino,cod_ret,com_err);
		END IF;
        RETURN cod_ret;
	END;
END PROCEDURE;