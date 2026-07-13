CREATE PROCEDURE "informix".sp_pago_servicios(pEmpresa char(3), pSucursal char(4), pUsuario char(8), pTransCargo char(4), pTransAbono char(4), 
pTransSuc char(4), pFolioSuc char(16), pNumCtaOrigen char(12), pNumCtaDestino char(12), pCheque integer, pMonto money(14,2), pMoneda char(2), pReferencia char(40),
pNumTarjetaOrigen char(16), pNumTarjetaDestino char(16), pUsuAutoriza char(8), pMontoTotal money(14,2), pMontoFirme money(14,2), pMontoSBC money(14,2),
pMontoRem money(14,2), pDiasRet smallint, pDocto integer, pCategoria Char(2), pConvenio Char(3), cRefTelefono Char(40), cRefVerificador Char(20), cFormaPago Char(1),
cCuentaCargo CHAR (12), cTransacc_suc CHAR(4), dFechaPago DATE)
RETURNING char(5), char(5);

    -- Realizo   : Ramon Octavio Romero MascareÃÂ±o
    -- Actividad : Pago de Servicios
    -- SolicitÃÂ³  : Mauricio Leon
    -- Fecha     : 14/07/2009
	--****************************************
	-- Realizo   : Manuel Osuna Valencia
    -- Actividad : Se modifica el tipo de dato de las variables de comisiones
    -- SolicitÃÂ³  : Mauricio Leon
    -- Fecha     : 05/08/2009
	--****************************************
	--RealizÃÂ³    : Walber Castro
	--Actividad  : Se agrega validaciÃÂ³n de SKY para el cÃÂ¡lculo de vImporteCompuesto
	--SolicitÃÂ³   : Diana Castellanos
	--Fecha      : 11/08/2010
	--****************************************
	--RealizÃÂ³    : JosÃÂ© de JesÃÂºs Nevarez.
	--Actividad  : Se agrega validaciÃÂ³n de DISH y MASTV para el cÃÂ¡lculo de vImporteCompuesto.
	--SolicitÃÂ³   : Mauricio LeÃÂ³n
	--Fecha      : 31/08/2010
	--****************************************
	--RealizÃÂ³    : Ing. Cruz
	--Actividad  : Se agrega validacion ECI, Arabela para el cÃÂ¡lculo de vImporteCompuesto, se agrega el usuario "informix" a cada ejecuciÃÂ³n de SPL's
	--SolicitÃÂ³   : JosÃÂ© de Jesus Nevarez
	--Fecha      : 28/05/2012
	--****************************************
	--RealizÃÂ³    : Aaron QuiÃÂ±onez
	--Actividad  : Se agrega validacion CFE(cat:04,conv:001) para el cÃÂ¡lculo de vImporteCompuesto.
	--SolicitÃÂ³   : Alejandro Vazquez
	--Fecha      : 26/09/2017
	--**********************************************
	--Realiza    : Gabriela Aguilar
	--Actividad  : Se agrega validacion para Tiempo Aire
	--Solicita   : Alejandro Vazquez
	--Fecha      : 09/10/2019
	
	
       DEFINE vcodret   			char(5);
       DEFINE vcodretRev   			char(5);
	   DEFINE vcodretConv   		char(5);
       DEFINE sql_err   			integer;
       DEFINE vTrans    			char(4);
       DEFINE vFechaHoy 			date;
       DEFINE vSdoDisp  			money(14,2);
       DEFINE vMontoRet 			money(14,2);
       DEFINE vPasoCargo 			char(1);
	   Define vPasoAbono			char(1);
	   DEFINE vimpcomconvenio 		money(14,2);
	   DEFINE vIVAimpconvenio		money(14,2);
	   DEFINE vimpcomcte			money(14,2);
	   DEFINE vIVAimpcomcte			money(14,2);
	   DEFINE vImporteCompuesto		money(14,2);
	   DEFINE cTipoServ				integer;
	   DEFINE fechadia  			date;							 

	    LET vPasoCargo 				= '0';
		LET vcodret 				= '000';
		LET vcodretRev 				= '000';
	    LET vcodretConv   			= '000';
	    LET vimpcomconvenio 		= 0;
	    LET vIVAimpconvenio			= 0;
	    LET vimpcomcte				= 0;
	    LET vIVAimpcomcte			= 0;
		LET vImporteCompuesto		= 0;
		LET cTipoServ 				= 0;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	
		--SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_pago_servicios.out';
		--TRACE ON;

BEGIN
--si el sp falla checa si ya fue realizada la transaccion de Cargo y Abono, en caso de haber sido realizada una o ambas,
--se realiza la reversion de estas.
ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
				EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
													pSucursal,
													pUsuario,
													pFolioSuc,
													'A') INTO vcodretRev;
				IF vcodretRev = '000' THEN
					LET vcodretRev = '004'; --Error no Controlado de SQL.
				END IF;
        LET vcodret = sql_err;
        RETURN vcodret, vcodretRev;
       END IF;
END EXCEPTION;

	    EXECUTE PROCEDURE bdisac:sp_calcula_comisiones(pCategoria,
														pConvenio,
														pMonto)
		INTO vcodretConv, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;

		--Validacion para checar que el sp_calcula_comisiones se ejecuto correctament y
		--despues valida el convenio , ejemplo si el pCategoria = 02 y el pConvenio = 001
		--es un pago telmex y se asignan las comisiones correspondientes.
	    if vcodretConv <> 0 THEN
				LET vcodretConv = '002'; --Error al ejecutar sp_calcula_comisiones
			RETURN vcodretConv, vcodretRev;
		ELSE
		/* 
			IF ( pCategoria IN ('02','04','06','09')) AND (pConvenio IN ('001','002','003' )) THEN--TELMEX(02) y SKY,DISH,MASTV(06), ECI Y ARABELA (09, 001 Y 002)
				LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
			END IF;
		*/
			IF pCategoria = ('02') THEN
				IF pConvenio IN ('001','003') THEN --TELMEX--AXTEL
					LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
				END IF;
			ELIF pCategoria = ('04') THEN
				IF pConvenio = '001' THEN --CFE
					LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
				END IF;
			ELIF pCategoria = ('06') THEN
				IF pConvenio IN  ('001','002','004') THEN --SKY--DISH--CABLEMAS
					LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
				END IF;
			ELIF pCategoria = ('09') THEN
				IF pConvenio IN ('001','002','003') THEN --EDICIONES CULTURALES INTERNACIONALES--ARABELA--AVON
					LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
				END IF;
			
			
			ELIF pCategoria = ('03') THEN
				IF pConvenio IN ('001') THEN --Tiempo Aire
					LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
				END IF;
			END IF;
				
		END IF;
		
		IF ( pSucursal IN ('5002','5003','5007','5011')) THEN -----Sucursales moviles --> otros canales
			SELECT fecha_hoy INTO fechadia FROM sac_fechas;
			IF (fechadia <> dfechapago) THEN 
				LET vcodret = '004';
				RETURN vcodret, vcodretRev;
			END IF;
		END IF;


    EXECUTE PROCEDURE bdicheq:cargo_ref(pEmpresa,
										pSucursal,
										pUsuario,
										pTransCargo,
										pTransSuc,
										pFolioSuc,
										pNumCtaOrigen,
										pCheque,
										vImporteCompuesto,
										pMoneda,
										pReferencia,
										pNumTarjetaOrigen,
										pUsuAutoriza)
	INTO vcodret,vTrans, vFechaHoy, vSdoDisp,vMontoRet;

    IF vcodret <> '000' THEN
		EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
											pSucursal,
											pUsuario,
											pFolioSuc,
											'A') INTO vcodretRev;
		IF vcodretRev = '000' THEN
            LET vcodretRev = '001';
        END IF;
        RETURN vcodret, vcodretRev;

    END IF;

    EXECUTE PROCEDURE bdicheq:abono_ref(pEmpresa,
										pSucursal,
										pUsuario,
										pTransAbono,
										pTransSuc,
										pFolioSuc,
										pNumCtaDestino,
										pDocto,
										vImporteCompuesto,
										vImporteCompuesto,
										pMontoSBC,
										pMontoRem,
										pDiasRet,
										pMoneda,
										pReferencia,
										pNumTarjetaDestino,
										pUsuAutoriza)
	INTO vcodret;

    IF vcodret <> '000' THEN
        EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
											pSucursal,
											pUsuario,
											pFolioSuc,
											'A') INTO vcodretRev;
        IF vcodretRev = '000' THEN
            LET vcodretRev = '002';
        END IF;
        RETURN vcodret, vcodretRev;
    END IF;

	SELECT numrephompag 
	INTO cTipoServ
	FROM sac_servicios_cpl
	WHERE numcategoria = pCategoria
	AND numconvenio = pConvenio;
	
	IF cTipoServ = 1 then
		EXECUTE PROCEDURE bdisac:sp_grabapgserv_dina(pSucursal,
												   pCategoria,
												   pConvenio,
												   cRefTelefono,
												   cRefVerificador,
												   cFormaPago,
												   pMonto,
												   vimpcomconvenio,
												   vIVAimpconvenio,
												   vimpcomcte,
												   vIVAimpcomcte,
												   cCuentaCargo,
												   pUsuario,
												   pFolioSuc,
												   cTransacc_suc,
												   dFechaPago)
		INTO vcodret;
	ELSE 
		EXECUTE PROCEDURE bdisac:sp_grabapagoservicio(pSucursal,
												   pCategoria,
												   pConvenio,
												   cRefTelefono,
												   cRefVerificador,
												   cFormaPago,
												   pMonto,
												   vimpcomconvenio,
												   vIVAimpconvenio,
												   vimpcomcte,
												   vIVAimpcomcte,
												   cCuentaCargo,
												   pUsuario,
												   pFolioSuc,
												   cTransacc_suc,
												   dFechaPago)
		INTO vcodret;
	END IF;

	IF vcodret <> '00000' THEN
			EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
												pSucursal,
												pUsuario,
												pFolioSuc,
												'A') INTO vcodretRev;
			IF vcodretRev = '000' THEN
				LET vcodretRev = '003';
			END IF;
        RETURN vcodret, vcodretRev;
    END IF;

	RETURN vcodret, vcodretRev;

END;
END PROCEDURE;