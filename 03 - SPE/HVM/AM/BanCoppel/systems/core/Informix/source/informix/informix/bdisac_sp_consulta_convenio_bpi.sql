CREATE PROCEDURE "informix".sp_consulta_convenio_bpi(pCategoria VARCHAR(2),pConvenio VARCHAR(3))
returning CHAR(5),CHAR(20),CHAR(4),CHAR(4), CHAR(4);
	--***************************************************************************--
	--**	Elaboró: Javier Calderón                                           **--
	--**	Actividad: Obtiene parametros para pago de servicios (DISH y MASTV)**--
	--**	Solicito: Mauricio León						                       **--
	--**	Fecha: 06/12/10								                       **--
	--***************************************************************************--
	DEFINE sql_err			INTEGER;
	DEFINE vCodRet			CHAR(5);
	DEFINE vCtaConv			CHAR(20);
	DEFINE vTransCargo		CHAR(4);
	DEFINE vTransAbono		CHAR(4);
	DEFINE vStatusConv		CHAR(1);
	DEFINE vTransCargoSuc	CHAR(4);

	LET vCodRet				= "00000";
	LET vCtaConv			= "";
	LET vTransCargo			= "";
	LET vTransAbono			= "";
	LET vStatusConv			= "";
	LET vTransCargoSuc		= "";

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet, vCtaConv, vTransCargo, vTransAbono, vTransCargoSuc;
			END IF ;
		END EXCEPTION;


		SELECT cuenta_prestadora, trans_cen_cargo_cliente, trans_cen_abono_convenio, statusconvenio, trans_suc_cargo
		INTO vCtaConv, vTransCargo, vTransAbono, vStatusConv, vTransCargoSuc
		FROM bdisac:sac_convenios
		WHERE numcategoria = pCategoria 
		AND numconvenio = pConvenio;
	
		IF NVL(vStatusConv, '') = '' OR vStatusConv <> 'A' THEN
			LET vCodRet = '00001'; /*00001 = el convenio no está activo*/
		END IF;

		RETURN vCodRet, vCtaConv, vTransCargo, vTransAbono, vTransCargoSuc;
	 END;
END PROCEDURE;