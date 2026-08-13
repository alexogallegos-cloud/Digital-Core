CREATE PROCEDURE "informix".spsctransctaspropias_pr(pEmpresa char(3),
                                                pSucursal char(4),
                                                pUsuario char(8),
                                                pTransCargo char(4),
                                                pTransAbono char(4),
                                                pTransSuc char(4),
                                                pFolioSuc char(16),
                                                pNumCtaOrigen char(12),
                                                pNumCtaDestino char(12),
                                                pCheque integer,
                                                pMonto money(14,2),
                                                pMoneda char(2),
                                                pReferencia char(40),
												pReferenciaBe char(40),
                                                pNumTarjetaOrigen char(16),
                                                pNumTarjetaDestino char(16),
                                                pUsuAutoriza char(8),
                                                pMontoTotal money(14,2),
                                                pMontoFirme money(14,2),
                                                pMontoSBC money(14,2),
                                                pMontoRem money(14,2),
                                                pDiasRet smallint,
                                                pDocto integer)
        RETURNING char(5), char(5);

	DEFINE vcodret   char(5);
	DEFINE vcodretRev   char(5);
	DEFINE sql_err   integer;
	DEFINE vTrans    char(4);
	DEFINE vFechaHoy date;
	DEFINE vSdoDisp  money(14,2);
	DEFINE vMontoRet money(14,2);
	DEFINE vPasoCargo char(1);
	DEFINE vMensajeRet char(100);
	DEFINE vReferencia	char(40);
	DEFINE vTransCargo char(4);
	DEFINE vCliente1 CHAR(20);
	DEFINE vCuenta1 char(12);
	DEFINE vTransAbono CHAR(4);
    DEFINE cReferencia varchar(40);
    DEFINE aReferencia varchar(40);
	   
	LET vReferencia ='' ;
   	LET vTransCargo ='';
	  
	LET vCliente1 ='';
	LET vCuenta1 ='';
	LET vTransAbono='';
	
	--SET DEBUG FILE TO "/tmp/spsctransctaspropias_pr.out";
	--TRACE ON;
	
BEGIN
ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        IF vPasoCargo = '1' THEN
            EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        pFolioSuc,
                                        'A') INTO vcodretRev;
        END IF;
        IF vcodretRev = '000' THEN
            LET vcodretRev = '001';
        END IF;

        LET vcodret = sql_err;
        RETURN vcodret, vcodretRev;
       END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

LET vPasoCargo = '0';
LET vcodret = '000';
LET vcodretRev = '000';
LET vMensajeRet = '';

LET cReferencia = '';
LET aReferencia = '';

---Asignación y concatenación de Cuenta del Cargo/Abono y la Referencia para el Estado de Cuenta
LET cReferencia = TRIM(pNumCtaDestino) || ' ' || pReferencia; --cargo y la Referencia 
LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferenciaBe; --abono y la Referencia del Beneficiario

	--*********************************************************************--
	--IF pTransCargo='0239' THEN DSB SE ELIMINA POR TRANSACCION RAYO
			
		select count(distinct num_cte), count(cuenta)
        into vCliente1, vCuenta1
        from bdicheq:"informix".sc_maechq
        where ( cuenta=pNumCtaOrigen  or cuenta=pNumCtaDestino)
        and empresa ='001';
		
	    IF vCliente1 = 1 AND vCuenta1 = 2 THEN
         	LET vTransCargo='0309';
			--**Cambia ID de Abono a **********--
				LET vTransAbono='0313';
                LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferencia;			--*********************************--
		ELSE	
			LET vTransCargo=pTransCargo;
			LET vTransAbono=pTransAbono;		

	    END IF
	
		
	--END IF
	--*********************************************************************--
		
		EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
									pSucursal,
									pUsuario,
									vTransCargo, --Envia 0309 si es entre cuentas del mismo cliente sino envia el de entrada 0239.
									pTransSuc,
									pFolioSuc,
									pNumCtaOrigen,
									pCheque,
									pMonto,
									pMoneda,
									cReferencia,
									pNumTarjetaOrigen,
									pUsuAutoriza) INTO vcodret,
													   vTrans,
													   vFechaHoy,
													   vSdoDisp,
													   vMontoRet;

		IF vcodret <> '000' THEN
			RETURN vcodret, vcodretRev;
		ELSE
			LET vPasoCargo = '1';
		END IF;

		EXECUTE PROCEDURE bdicheq:"informix".abono_ref(pEmpresa,
									pSucursal,
									pUsuario,
									vTransAbono, --Envia 0313 si es entre cuentas del mismo cliente sino envia el de entrada 0205.
									pTransSuc,
									pFolioSuc,
									pNumCtaDestino,
									pDocto,
									pMontoTotal,
									pMontoFirme,
									pMontoSBC,
									pMontoRem,
									pDiasRet,
									pMoneda,
									aReferencia,
									pNumTarjetaDestino,
									pUsuAutoriza) INTO vcodret;

		IF vcodret <> '000' THEN
			EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
										pSucursal,
										pUsuario,
										pFolioSuc,
										'A') INTO vcodretRev;
			IF vcodretRev = '000' THEN
				LET vcodretRev = '001';
			END IF;
			RETURN vcodret, vcodretRev;
		END IF;

END;
RETURN vcodret, vcodretRev;
END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - ProyectoRayo',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 19/06/2015',
'MODIFICACIÓN..: Se crea stored procedure espejo al spsctransctaspropias quitando solamente el llamado al sp_validatransferencias_bpi ',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_reimprimeqr_pr( pNumCelular CHAR(10))
   returning CHAR(5),CHAR(20),CHAR(20),INTEGER,CHAR(80),CHAR(12);


    DEFINE sql_err INTEGER ;
    DEFINE cCodRet CHAR(5);
	DEFINE iIdUsuario INTEGER;
	DEFINE cBean  CHAR(20);
	DEFINE cAlias  CHAR(80);
	DEFINE cPrefijo CHAR(20);
	DEFINE cFolioAct CHAR(12);
	
	LET cCodRet  = '00000';
	LET iIdUsuario=0;
	LET cBean='';
	LET cAlias='';
	LET cPrefijo='';
	LET cFolioAct='';
	
	
  --SET DEBUG FILE TO "/tmp/sp_reimprimeqr_pr.out";
  --TRACE ON;
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
            RETURN cCodRet,cBean,cPrefijo,iIdUsuario,cAlias,cFolioAct;
	  END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pNumCelular,'')='')THEN
		LET cCodRet = '00001';
		RETURN cCodRet,cBean,cPrefijo,iIdUsuario,cAlias,cFolioAct;
	END IF;
	
	SELECT id_usuario,alias,folio_activacion 
	INTO iIdUsuario,cAlias,cFolioAct
	FROM bdibpi:"informix".pr_registro_app
	WHERE celular=pNumCelular;
	
	IF(iIdUsuario<>0 AND cAlias<>'')THEN
			SELECT valor 
			INTO cBean
			FROM bdibpi:"informix".pr_param_mensajes 
			WHERE id_param='001' AND tipo_param='1';
			
			SELECT valor 
			INTO cPrefijo
			FROM bdibpi:"informix".pr_param_mensajes 
			WHERE id_param='002' AND tipo_param='1';
	ELSE
		LET cCodRet='00002';
	END IF;
	
    RETURN cCodRet,cBean,cPrefijo,iIdUsuario,cAlias,cFolioAct;
   
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - ProyectoRayo',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 16/06/2015',
'MODIFICACIÓN..: Se crea stored procedure, obtiene datos para reimpresion de QR en sucursales',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_registra_acceso_pr( pRegistro CHAR(20),pIdSesion CHAR(200))
   returning CHAR(5),CHAR(200),CHAR(150);

    DEFINE sql_err INTEGER ;
    DEFINE cCod_ret CHAR(5);
	DEFINE cIdSesion CHAR(200);
	DEFINE iIdUsuario INTEGER;
	DEFINE iIdUsuarioSesion INTEGER;
	DEFINE cCelular CHAR(10);
	DEFINE cNumRnd CHAR(5);
	DEFINE cMensajeRet CHAR(150);
	
	LET cCod_ret='00000';
	LET cIdSesion='';
	LET iIdUsuario =0;
	LET cCelular='';
	LET cMensajeRet='';
	LET iIdUsuarioSesion=0;
	LET cNumRnd=0;
	
  --SET DEBUG FILE TO "/tmp/sp_registra_acceso_pr.out";
  --TRACE ON;
  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCod_ret = sql_err;
            RETURN cCod_ret,cIdSesion,cMensajeRet;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pRegistro,'')='' OR NVL(pIdSesion,'')='')THEN
		LET cCod_ret = '00001';
		RETURN cCod_ret,cIdSesion,cMensajeRet;
	END IF;
	
	SELECT id_usuario,celular 
	INTO iIdUsuario,cCelular
	FROM bdibpi:"informix".pr_registro_app 
	WHERE celular=pRegistro OR folio_activacion=pRegistro;
	
	IF NVL(iIdUsuario,'')='' OR NVL(cCelular,'')='' THEN
		LET cCod_ret = '00002';		IF LENGTH(pRegistro)=10 THEN
			SELECT valor 
			INTO cMensajeRet
			FROM bdibpi:"informix".pr_param_mensajes 
			WHERE id_param='009' AND tipo_param='2';	
		ELSE
			SELECT valor 
			INTO cMensajeRet
			FROM bdibpi:"informix".pr_param_mensajes 
			WHERE id_param='001' AND tipo_param='2';
		END IF;
		RETURN cCod_ret,cIdSesion,cMensajeRet;
		
	END IF;
	
	SELECT id_usuario
	INTO iIdUsuarioSesion
	FROM bdibpi:"informix".pr_sesiones_activas 
	WHERE id_usuario=iIdUsuario;
	
	IF NVL(iIdUsuarioSesion,'')<>'' THEN
		--LET cCod_ret = '00003';--USUARIO CON SESION ABIERTA Y BORRA LA SESION
		DELETE bdibpi:"informix".pr_sesiones_activas WHERE id_usuario=iIdUsuarioSesion OR num_celular=cCelular;
	END IF;
	--INSERTA LA SESION DEL CLIENTE
	EXECUTE PROCEDURE bdibpi:"informix".sp_random(1000, 9999) INTO cNumRnd;
	LET cIdSesion=TRIM(pIdSesion)||cNumRnd;
	INSERT INTO bdibpi:"informix".pr_sesiones_activas (id_usuario,num_celular,id_sesion,fecha)
	VALUES(iIdUsuario,cCelular,cIdSesion,current);
	RETURN cCod_ret,cIdSesion,cMensajeRet;
	
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - ProyectoRayo',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 21-05-2015',
'MODIFICACIÓN..: Se crea stored procedure, registra sesion para acceso ala api pago rayo',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_obtiene_parametros_pr( pTipoParam CHAR(1))
   returning CHAR(5),CHAR(3),CHAR(100);
-- Realizó: José Rubén López
-- Actividad: obtiene parametros a utilizar en la app pago rayo
-- Solicitó: Jesus Montoya
-- Fecha de Solicitud: 21-05-2015

    DEFINE sql_err INTEGER ;
    DEFINE cCod_ret CHAR(5);
	DEFINE cIdParametro CHAR(3);
	DEFINE cValorParametro CHAR(100);
	
	LET cCod_ret='00000';
	LET cIdParametro='';
	LET cValorParametro='';
	
  --SET DEBUG FILE TO "/tmp/sp_obtiene_parametros_pr.out";
  --TRACE ON;
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCod_ret = sql_err;
            RETURN cCod_ret,cIdParametro,cValorParametro;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pTipoParam,'')='')THEN
		LET cCod_ret = '00001';
		RETURN cCod_ret,cIdParametro,cValorParametro;
	END IF;
	
	FOREACH
		SELECT id_param,valor 
		INTO cIdParametro,cValorParametro
		FROM bdibpi:"informix".pr_param_mensajes WHERE tipo_param=pTipoParam
		    RETURN cCod_ret,cIdParametro,cValorParametro WITH RESUME;
	END FOREACH;   
END

END PROCEDURE;