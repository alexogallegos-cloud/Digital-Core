CREATE PROCEDURE "informix".clasifica_cartvend(eempresa      CHAR(3),
				  enum_credito  CHAR(20),
			 	  etp_venta     CHAR(1),
				  enum_producto CHAR(4),
				  eusuario      CHAR(8))
RETURNING CHAR(5), CHAR(80);

-- ****************************************************************************
-- *                         DEFINICION DE VARIABLES                          *
-- ****************************************************************************
DEFINE vcod_ret       CHAR(5);
DEFINE vsqlerr        INTEGER;
DEFINE vmensaje       CHAR(80);
DEFINE vfuncion       CHAR(3);
DEFINE v_vigente      MONEY(14,2);
DEFINE v_vencido      MONEY(14,2);
DEFINE v_venctrasp    MONEY(14,2);
DEFINE v_intnoexig    MONEY(14,2);
DEFINE v_int_venc     MONEY(14,2);
DEFINE v_intvenctrasp MONEY(14,2);
DEFINE vnum_producto  CHAR(4);
DEFINE vhoy           DATE;
DEFINE vfolio         CHAR(16);
DEFINE vsucursal      CHAR(4);
DEFINE vdivisa        CHAR(2);
-- ****************************************************************************
-- *                         ASIGNACION DE VARIABLES                          *
-- ****************************************************************************
LET vcod_ret = "00000";
LET vsqlerr  = 0;
LET vmensaje = "PROCESO CONCLUIDO EXITOSAMENTE";
SELECT eusuario || SUBSTR(current hour to fraction    ,1,2 ) ||
                   SUBSTR(current hour to fraction    ,4,2 ) ||
                   SUBSTR(current hour to fraction    ,7,2 ) ||
                   SUBSTR(enum_credito,8 ,2),
      fecha_hoy
 INTO vfolio, vhoy
 FROM sd_fechas;
-- ****************************************************************************
-- *                         CONTROL DE ERRORES                               *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcod_ret=vsqlerr;
      ROLLBACK WORK;
      LET vmensaje = " ";
      RETURN vcod_ret, vmensaje; 
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                         PROGRAMA PRINCIPAL                               *
-- ****************************************************************************
	IF etp_venta = "2" THEN
		IF enum_producto = " " OR enum_producto IS NULL THEN
			LET vcod_ret = "0020";
			LET vmensaje = "Debe Definir un Producto"; 
			RETURN vcod_ret, vmensaje;
		END IF
		LET vfuncion = "021";
	ELIF etp_venta = "1" THEN
		LET vfuncion = "020";
	ELSE 
		LET vfuncion = "036";
	END IF
	BEGIN WORK;

	SELECT sdo_capital, monto_vencido, mto_venc_trasp, sdo_no_exig,
	       mto_venc_int,mto_venc_tra_int, num_producto, sucursal,
	       divisa
	  INTO v_vigente  , v_vencido,     v_venctrasp,    v_intnoexig,
	       v_int_venc,  v_intvenctrasp,vnum_producto,  vsucursal,
	       vdivisa
	  FROM sd_maesdos a, sd_maecred b
	 WHERE b.num_credito = a.num_credito
	   AND b.empresa     = a.empresa
	   AND a.num_credito = enum_credito
	   AND a.empresa     = eempresa; 

	-- Liquida o Traspasa el Capital Vigente Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 1, 
				 vfuncion, vhoy, v_vigente, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Capital Vencido Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 2, 
				 vfuncion, vhoy, v_vencido, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Capital Vencido Traspasado Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 3, 
				 vfuncion, vhoy, v_venctrasp, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Interes Vigente Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 4, 
				 vfuncion, vhoy, v_intnoexig, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Interes Vencido Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 5, 
				 vfuncion, vhoy, v_int_venc, vfolio, 
				 vsucursal, vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Interes Vencido Traspasado Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 6, 
				 vfuncion, vhoy, v_intvenctrasp, vfolio, 
				 vsucursal, vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	IF etp_venta = "1" THEN
		-- Liquida o Traspasa el Interes Moratorios 
		EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto,
					 7, vfuncion, vhoy, v_intvenctrasp, 
					 vfolio, vsucursal, vdivisa, "0000")
		   INTO vcod_ret, vmensaje;
		IF vcod_ret <> "00000" THEN
      			ROLLBACK WORK;
			RETURN vcod_ret, vmensaje;
		END IF

		UPDATE sd_pagocapit SET monto_real_pag = saldo_cuota,
					status_cuota = "5"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa 
		   AND status_cuota <> "5";

		UPDATE sd_paginter SET monto_real_pag = monto_cuota,
					status_cuota = "5"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa 
		   AND status_cuota <> "5";

		UPDATE sd_detmora SET sdo_mora_ordi = 0
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;

		-- Se va a verificar pero de entrada el seguro se cancela

		UPDATE sd_detcomi SET estado_com = "C"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa 
		   AND estado_com = "P";

		UPDATE sd_maesdos SET sdo_no_exig      = 0,
				      sdo_exig_int     = 0,
				      sdo_moratorio    = 0,
				      sdo_capital      = 0,
				      sdo_cap_insoluto = 0,
				      monto_vencido    = 0,
				      mto_venc_trasp   = 0,
				      mto_venc_int     = 0,
				      mto_venc_tra_int = 0
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;


		UPDATE sd_maecred SET status_cred = "FE"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;

	ELIF etp_venta = "2" THEN
		UPDATE sd_maecred SET num_producto = enum_producto 
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;
	ELSE
		UPDATE sd_maecred SET status_cred = "CC"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;

                UPDATE sd_maesdos SET sdo_no_exig      = 0,
                                      sdo_exig_int     = 0,
                                      sdo_moratorio    = 0,
                                      mto_venc_int     = 0,
                                      mto_venc_tra_int = 0
                 WHERE num_credito = enum_credito
                   AND empresa = eempresa ;

		UPDATE sd_paginter SET monto_cuota = 0, status_cuota ="1"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa
		   AND monto_cuota > 0
		   AND status_cuota <> "5";

	END IF
	

	COMMIT WORK;
END
	RETURN vcod_ret, vmensaje;
END PROCEDURE;