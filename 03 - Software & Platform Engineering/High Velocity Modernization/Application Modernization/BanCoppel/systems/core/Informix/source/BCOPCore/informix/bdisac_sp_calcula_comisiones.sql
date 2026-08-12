CREATE PROCEDURE "informix".sp_calcula_comisiones(pcategoria CHAR(2),pconvenio CHAR(3),ppago MONEY(16,2), vcanal CHAR(2))
returning CHAR(5),MONEY(14,2), MONEY(14,2), MONEY(14,2),MONEY(14,2);
	--****************************************************************************--
		--**	Elaboró: Bibiana Gaxiola Verdugo    		   					**--
		--**	Actividad: Consulta las comisiones segun el canal				**--
		--**	Fecha: 29/08/13													**--
	--****************************************************************************--

DEFINE sql_err					INTEGER;
DEFINE cod_err					CHAR(5);
DEFINE vBanderaCom CHAR(1);
DEFINE vBanderaComCte CHAR(1);
DEFINE vimpcomconvenio MONEY(14,2);
DEFINE vIvaConvenio INTEGER;
DEFINE vIvaTotalconvenio MONEY(14,2);
DEFINE vimpcomcte MONEY(14,2);
DEFINE vIvaComcte INTEGER;
DEFINE vIvaTotalComcte MONEY(14,2);

LET cod_err					="000";
LET vBanderaCom				= "0";
LET vBanderaComCte			= "0";
LET vimpcomconvenio 		= 0;
LET vimpcomcte 				= 0;
LET vIvaTotalconvenio		= 0;
LET vIvaTotalComcte			= 0;

	--SET DEBUG FILE TO '/home/informix/bibiana/sp_calcula_comisiones.out';
	--TRACE ON;

 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
            RETURN cod_err, vimpcomconvenio, vIvaTotalconvenio, vimpcomcte, vIvaTotalComcte;
      END IF ;
END EXCEPTION ;

SET ISOLATION TO DIRTY READ;

	IF ((pcategoria IS NOT NULL) AND (pcategoria <> '')) AND ((pconvenio IS NOT NULL) AND (pconvenio <> '')) THEN

		SELECT flag_com, flag_comcte INTO vBanderaCom,vBanderaComCte
		FROM bdisac:"informix".sac_comisiones_x_canal
		WHERE numcategoria = pcategoria AND numconvenio = pconvenio AND cve_canal = vcanal ;

		IF (vBanderaCom = 1) THEN

			SELECT comision, iva_com INTO vimpcomconvenio, vIvaConvenio
			FROM bdisac:"informix".sac_comisiones_x_canal
			WHERE numcategoria = pcategoria AND numconvenio = pconvenio AND cve_canal = vcanal ;

			LET vIvaTotalconvenio = vimpcomconvenio * (vIvaConvenio/100);  --- Se calcula el IVA del convenio de acuerdo a la comisión

		ELIF (vBanderaComCte = 1) THEN

			SELECT comision_cte, iva_comcte INTO vimpcomcte, vIvaComcte
			FROM bdisac:"informix".sac_comisiones_x_canal
			WHERE numcategoria = pcategoria AND numconvenio = pconvenio AND cve_canal = vcanal ;

			LET vIvaTotalComcte = vimpcomcte * (vIvaComcte/100) ;    --- Se calcula el IVA del convenio de acuerdo a la comisión del cliente

		ELSE
			LET cod_err = '00002';  --- No hay comisiones ni para el convenio ni para el cliente
		END IF;

	ELSE
		LET cod_err = '00001'; --- Algún dato de entrada viene vacio
	END IF;

	RETURN cod_err, vimpcomconvenio, vIvaTotalconvenio, vimpcomcte, vIvaTotalComcte;
END;
END PROCEDURE;