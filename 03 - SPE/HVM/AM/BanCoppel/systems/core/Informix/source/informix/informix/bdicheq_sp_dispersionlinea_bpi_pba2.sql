CREATE PROCEDURE "informix".sp_dispersionlinea_bpi_pba2(pidempresa CHAR(3),pnumcte CHAR(9),pnombrearchivo CHAR(20),pSucursal CHAR(10),pUsuario CHAR(10),pTransaccionIva CHAR(5),pTransaccionCargo CHAR(5),pFolioSuc CHAR(20),pCuenta CHAR(20),pIvaDisp MONEY(14,2),pCargoDisp MONEY(14,2))
returning char(5);

--Realizó: Jose Ruben Lopez Hernadez
--Fecha: 26/03/2013
--Actividad:Se unifico la ejecucion de los sp de cargo de iva y de comision 
--BD:bdicheq.

    DEFINE vsqlerr          INTEGER;
    DEFINE vcodret          CHAR(5);
	DEFINE vcodret2         CHAR(5);
	DEFINE vcodret3         CHAR(5);
	DEFINE vcodret4         CHAR(5);
	DEFINE vcodret5         CHAR(5);
	DEFINE vcodret6         CHAR(5);
	DEFINE cFolio 			CHAR(16);
	DEFINE cMensaje 		CHAR(50);
	DEFINE cTransacCargo    CHAR(4);
	DEFINE dFechacargo      DATE;
	DEFINE mSaldoEje        MONEY(14,2);
	DEFINE mRedondeo        MONEY(18,5);
	DEFINE mDispLinea		MONEY;
	DEFINE mMontoTransIvaDisp	MONEY(16,2);
	DEFINE cProducto	 CHAR(4);
	DEFINE cTpoPersona	 CHAR(1);
	
	LET vsqlerr = 0;
    LET vcodret = "00000";
	LET vcodret2 = "00000";
	LET vcodret3="00000";
	LET vcodret4="00000";
	LET vcodret5="00000";
	LET vcodret6="00000";
	LET cFolio = '';
	LET cMensaje = " ";
	LET cTransacCargo='';
	LET dFechacargo='';
	LET mSaldoEje=0;
	LET mRedondeo=0;
	LET mDispLinea = 0.0;
	LET mMontoTransIvaDisp = 0;
	LET cProducto	 = "";
	LET cTpoPersona	 = "";
	
	SET debug FILE TO "/tmp/sp_dispersionlinea_bpi.out";
	Trace ON;
	

    BEGIN

    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
			INSERT INTO bdibpi:"informix".tmp_disp_err(id_empresa ,num_cte ,nom_arch,codret,mensaje,f_registro)VALUES(pidempresa,pnumcte,pnombrearchivo,vcodret,cMensaje,CURRENT);
            RETURN vcodret;
        END IF;
    END EXCEPTION;

	--SET debug FILE TO "/informix/moha/sp_dispersionlinea_bpi.out";
	--Trace ON;

	
    CALL "informix".sp_cargadividearchivonomina_bpi(pnombrearchivo)
		RETURNING vcodret, cFolio, cMensaje;

    IF 	vcodret <> "00000" THEN		
		LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_cargadividearchivonomina_bpi)';
	ELSE
		SELECT producto
		INTO cProducto
		FROM "informix".sc_maechq
		WHERE empresa = "001"
		AND cuenta = pCuenta;
		   
		SELECT tpper_valida
		INTO cTpoPersona
		FROM bdicheq:"informix".sc_producto
		WHERE empresa = "001" 
		AND producto = cProducto;
		
		IF cTpoPersona IN ("2","4","5") AND cProducto <> "2600" THEN
			-- OBTIENE EL IVA
			SELECT valor
			INTO mMontoTransIvaDisp
			FROM bdinteg:"informix".si_param
			WHERE cod_param = 47
			AND empresa = "001";
			--// OBTIENE EL VALOR DE LA COMISION POR DISPERSION EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
			SELECT disp_linea
			INTO mDispLinea
			FROM "informix".sc_maecomtasserv_pm
			WHERE cuenta = pCuenta;
			
			IF mDispLinea IS NOT NULL THEN
				LET pCargoDisp = mDispLinea;
				LET pIvaDisp = pCargoDisp * mMontoTransIvaDisp;
				LET pTransaccionIva = "0260";
				LET pTransaccionCargo = "3255";
			END IF
		END IF
	
		IF pCargoDisp <> 0 THEN--bandera ejecutar los cargos					
					EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001',pSucursal,pUsuario,pTransaccionIva,'',pFolioSuc,pCuenta,0,pIvaDisp,'01','','','')
					INTO vcodret4,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo;
					IF vcodret4="000" THEN
							EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001',pSucursal,pUsuario,pTransaccionCargo,'',pFolioSuc,pCuenta,0,pCargoDisp,'01','','','')	
							INTO vcodret5,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo;
							IF vcodret5="000" THEN
								CALL bdicheq:"informix".sp_dispercionnomina_bpi() returning vcodret2;
								IF vcodret2 = "000" THEN 
									LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE CC';
								ELSE
									EXECUTE PROCEDURE bdicheq:"informix".reversion('001',pSucursal,pUsuario,pFolioSuc, 'A')
									INTO vcodret6;	
									LET vcodret = vcodret2;
									LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_dispercionnomina_bpi)';
								END IF
							ELSE
								EXECUTE PROCEDURE bdicheq:"informix".reversion('001',pSucursal,pUsuario,pFolioSuc, 'A')
								INTO vcodret6;	
								LET vcodret = vcodret5;
								LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(cargo_ref CARGO)';	
							END IF
					ELSE
						LET vcodret = vcodret4;
						LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(cargo_ref IVA)';	
					END IF
		ELSE--No se ejecutan los cargos
			CALL "informix".sp_dispercionnomina_bpi() returning vcodret2;
					IF vcodret2 = "000" THEN 
						LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE SC';
					ELSE
						LET vcodret = vcodret2;
						LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_dispercionnomina_bpi)';
					END IF

		END IF
	END IF;

	INSERT INTO bdibpi:"informix".tmp_disp_err(id_empresa ,num_cte ,nom_arch,codret,mensaje,f_registro)VALUES(pidempresa,pnumcte,pnombrearchivo,vcodret,cMensaje,current);
    RETURN vcodret;
    END;

END PROCEDURE;