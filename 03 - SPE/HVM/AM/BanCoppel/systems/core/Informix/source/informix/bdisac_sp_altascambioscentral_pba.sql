CREATE PROCEDURE "informix".sp_altascambioscentral_pba(cNumcategoria CHAR(2), cNumconvenio CHAR(3), cNomconvenio CHAR(40), dFechaapertura DATE, dFechaclausura DATE,
                    cStatusconvenio CHAR(1), cTipo_Referencia CHAR(1), cNomlegalempresa CHAR(40), cRfcempresa CHAR(13), cNomcomercialempresa CHAR(40),
                    cDireccionempresa CHAR(80), cEstado CHAR(2), cCiudad CHAR(3), cCodpostal CHAR(5), cNumtelcorporativo CHAR(10), cNumfaxcorporativo CHAR(10),
                    cNomcontacto1 CHAR(40), cNumtelcontacto1 CHAR(10), cNumextcontacto1 CHAR(7), cEmailcontacto1 CHAR(40), cNomcontacto2 CHAR(40),
                    cNumtelcontacto2 CHAR(10), cNumextcontacto2 CHAR(7), cEmailcontacto2 CHAR(40), cNomcontacto3 CHAR(40), cNumtelcontacto3 CHAR(10),
                    cNumextcontacto3 CHAR(7), cEmailcontacto3 CHAR(40), cNumcuentaclabe CHAR(18), cTipopago CHAR(1), iFrecuenciapago INT, cFlgarchnotificacion CHAR(1),
                    iFrecnotificacion INT, cFlgporccomtrans_conv CHAR(1), dePorc_com_trans_conv DECIMAL, cFlgporccomtotal_conv CHAR(1),
                    dePorc_com_total_conv DECIMAL, cFlgimpcomtrans_conv CHAR(1), mImp_com_trans_conv MONEY(16,2), cFlgimpcomtotal_conv CHAR(1),
                    deImp_com_total_conv MONEY(16,2), cFlgivaincluido_conv CHAR(1), deIva_Convenio INT, cFlgPorcComTrans_Cte CHAR(1), dePorc_com_trans_cte DECIMAL,
                    cFlgImpComTrans_Cte CHAR(1), mImp_com_trans_cte MONEY(16,2), cFlg_Ref1 CHAR(1), iLongitudRef1  INT, cFlgcalculodv_ref1 CHAR(1), cNomrutinadv_ref1  CHAR(30),
                    cFlg_Ref2 CHAR(1), iLongitudRef2 INT, cFlgcalculodv_ref2 CHAR(1), cNomrutinadv_ref2 CHAR(30), cFlgreporte CHAR(1), cNomreporte CHAR(30), cUsuario CHAR(8))
    -- DATOS A REGRESAR
    RETURNING CHAR(5), CHAR(2), CHAR(3);  -- Codigo de Retorno
    -- DEFINICION DE VARIABLES
    DEFINE cCodRet              CHAR(5);
    DEFINE cFechaHoy            DATE;
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(200);
    DEFINE fecha_ultimo_pago    DATE;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET iIsamErr = 0;
    LET cInfoErr = "";
    LET fecha_ultimo_pago = '01-01-1900';

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        ROLLBACK WORK;
                        EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_AltasCambiosCentral");
                        RETURN cCodRet, '', '';
                END IF;
        END EXCEPTION;

        BEGIN WORK;
            SELECT fecha_hoy INTO cFechaHoy FROM bdisac:sac_fechas;

            IF EXISTS (SELECT {+INDEX (bdisac:sac_convenios 103_4)} * FROM sac_convenios WHERE  numcategoria = cNumcategoria AND numconvenio = cNumconvenio) THEN
                UPDATE {+INDEX (bdisac:sac_convenios 103_4)} sac_convenios
                SET nomconvenio = cNomconvenio, fechaapertura = dFechaapertura, fechaclausura = dFechaclausura, statusconvenio = cStatusconvenio,
                    tipo_referencia = cTipo_Referencia, nomlegalempresa = cNomlegalempresa, rfcempresa = cRfcempresa, nomcomercialempresa = cNomcomercialempresa,
                    direccionempresa = cDireccionempresa, ciudad = cCiudad, estado = cEstado, codpostal = cCodpostal, numtelcorporativo = cNumtelcorporativo,
                    numfaxcorporativo = cNumfaxcorporativo, nomcontacto1 = cNomcontacto1, numtelcontacto1 = cNumtelcontacto1, numextcontacto1 = cNumextcontacto1,
                    emailcontacto1 = cEmailcontacto1, nomcontacto2 = cNomcontacto2, numtelcontacto2 = cNumtelcontacto2, numextcontacto2 = cNumextcontacto2,
                    emailcontacto2 = cEmailcontacto2, nomcontacto3 = cNomcontacto3, numtelcontacto3 = cNumtelcontacto3, numextcontacto3 = cNumextcontacto3,
                    emailcontacto3 = cEmailcontacto3, numcuentaclabe = cNumcuentaclabe, tipopago = cTipopago, frecuenciapago = iFrecuenciapago, flgarchnotificacion = cFlgarchnotificacion,
                    frecnotificacion = iFrecnotificacion, flgporccomtrans_conv =cFlgporccomtrans_conv, porc_com_trans_conv = dePorc_com_trans_conv,
                    flgporccomtotal_conv = cFlgporccomtotal_conv, porc_com_total_conv = dePorc_com_total_conv, flgimpcomtrans_conv = cFlgimpcomtrans_conv,
                    imp_com_trans_conv = mImp_com_trans_conv, flgimpcomtotal_conv = cFlgimpcomtotal_conv, imp_com_total_conv = deImp_com_total_conv,
                    flgivaincluido_conv = cFlgivaincluido_conv, iva_convenio = deIva_Convenio, flgporccomtrans_cte = cFlgPorcComTrans_cte, porc_com_trans_cte = dePorc_com_trans_cte,
                    flgimpcomtrans_cte = cFlgImpComTrans_cte, imp_com_trans_cte = mImp_com_trans_cte, flg_ref1 = cFlg_Ref1, longitud_ref1 = iLongitudRef1,
                    flgcalculodv_ref1 = cFlgcalculodv_ref1, nomrutinadv_ref1 = cNomrutinadv_ref1, flg_ref2 = cFlg_Ref2, longitud_ref2  = iLongitudRef2,
                    flgcalculodv_ref2 = cFlgcalculodv_ref2, nomrutinadv_ref2 = cNomrutinadv_ref2, flgreporte = cFlgreporte, nomreporte  = cNomreporte,
                    fecha_ultimo_pago = fecha_ultimo_pago, usuario_actualiza = cUsuario, fechaactualizacion = cFechaHoy
                WHERE numcategoria = cNumcategoria
                AND numconvenio = cNumconvenio;
            ELSE

                SELECT {+INDEX (bdisac:sac_convenios 103_7)} MAX(numconvenio)
                INTO cNumconvenio
                FROM bdisac:sac_convenios
                WHERE numcategoria = cNumcategoria;

                IF cNumConvenio IS NULL THEN
                    LET cNumConvenio = '001';
                ELSE
                    LET cNumconvenio  = LPAD(CAST(cNumconvenio AS INTEGER) + 1, 3, '0');
                END IF;

                INSERT INTO sac_convenios (numcategoria, numconvenio, nomconvenio, fechaapertura, fechaclausura, fechaalta, statusconvenio,	tipo_referencia,
	                        nomlegalempresa, rfcempresa,nomcomercialempresa, direccionempresa, ciudad, estado, codpostal, numtelcorporativo, numfaxcorporativo, nomcontacto1, 
							numtelcontacto1, numextcontacto1, emailcontacto1, nomcontacto2, numtelcontacto2, numextcontacto2, emailcontacto2, nomcontacto3, 
							numtelcontacto3, numextcontacto3, emailcontacto3, numcuentaclabe, tipopago, frecuenciapago, flgarchnotificacion, frecnotificacion, 
							flgporccomtrans_conv, porc_com_trans_conv, flgporccomtotal_conv, porc_com_total_conv, flgimpcomtrans_conv, imp_com_trans_conv,	
							flgimpcomtotal_conv, imp_com_total_conv, flgivaincluido_conv, iva_convenio, flgporccomtrans_cte, porc_com_trans_cte, 
							flgimpcomtrans_cte, imp_com_trans_cte, flg_ref1, longitud_ref1, flgcalculodv_ref1, nomrutinadv_ref1, flg_ref2, longitud_ref2, 
							flgcalculodv_ref2, nomrutinadv_ref2, flgreporte, nomreporte, fecha_ultimo_pago, usuario_alta, usuario_actualiza, fechaactualizacion) 
                    VALUES( cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, cFechaHoy, cStatusconvenio, cTipo_Referencia, 
					    	cNomlegalempresa, cRfcempresa, cNomcomercialempresa, cDireccionempresa, cCiudad, cEstado, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1,
                            cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2, cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3,
                            cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago, cFlgarchnotificacion, iFrecnotificacion,
                            cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
                            cFlgimpcomtotal_conv, deImp_com_total_conv, cFlgivaincluido_conv, deIva_Convenio, cFlgPorcComTrans_cte, dePorc_com_trans_cte,
                            cFlgImpComTrans_cte, mImp_com_trans_cte, cFlg_Ref1, iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2,
                            cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte, fecha_ultimo_pago, cUsuario, cUsuario, cFechaHoy);

                INSERT INTO sac_controlarchivoscobranza (numcategoria, numconvenio, nom_rutina, fecha_ultimo_archivo)
                VALUES (cNumcategoria, cNumconvenio,'', fecha_ultimo_pago);

            END IF;
        COMMIT WORK;
        RETURN cCodret, cNumcategoria, cNumconvenio;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Hector Bojorquez',
'DESCRIPCION: Se encarga de insertar o actualizar el registro de un convenio en la tabla',
'             bdisac:sac_convenios de Central',
'EJECUTADO O LLAMADO POR: alcsac.exe, cacsac.exe del sistema de administracion de convenios',
'FECHA : Agosto de 2008',
'AUTOR MODIFICACION: Dulce Ramirez',
'DESCRIPCION MODIFICACION: Se especifican los campos de la tabla sac_convenios en el insert,',
'FECHA : Septiembre de 2010',
'VERSION: 20100920',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_actualizastatusconvenio_pba(cStatus CHAR(1), cNumConvenio CHAR(3), cNumCategoria CHAR(2))

    RETURNING
    CHAR(5);

    --Definicion de Variables
    DEFINE cCodRet      CHAR(5);
    DEFINE dFecha_hoy   DATE;
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cInfoErr     CHAR(200);

    -- Inicializa variables
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET iIsamErr = 0;
    LET cInfoErr = "";
    LET dFecha_hoy = '01-01-1900';

    --debug flag
    --SET DEBUG FILE TO "/tmp/sc_consdatosctacentral.out";
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizastatusconvenio");
                        RETURN cCodRet;
                END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_hoy FROM bdisac:sac_fechas;

            UPDATE sac_convenios
            SET statusconvenio = cStatus,  fechaactualizacion = dFecha_hoy, fecha_ultimo_pago = dFecha_hoy
            WHERE numcategoria = cNumCategoria
            AND numconvenio = cNumConvenio;

            IF cStatus = 'A' THEN
                UPDATE sac_controlarchivoscobranza
                SET fecha_ultimo_archivo = dFecha_hoy
                WHERE numcategoria = cNumCategoria
                AND numconvenio = cNumConvenio;
            END IF;

        RETURN cCodRet;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Jose Angel Lopez Adams',
'DESCRIPCION: Se encarga de actualizar el status de un convenio previamente dado de alta en la tabla',
'             bdisac:sac_convenios de Central',
'EJECUTADO O LLAMADO POR: bacsac.exe del sistema de administracion de convenios',
'FECHA : Agosto de 2008',
'VERSION: 20080905',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_calcula_comisiones_pba(pcategoria CHAR(2),pconvenio CHAR(3),ppago MONEY(16,2))
returning CHAR(5),MONEY(14,2), MONEY(14,2), MONEY(14,2),MONEY(14,2);
	--************************************************************--
		--**	Elaboró: Ramon Octavio Romero Mascareño		**--
		--**	Actividad: Calcula Comisiones				**--
		--**	Solicito: Mauricio León						**--
		--**	Fecha: 10/07/09								**--
	--************************************************************--
		--**	Modificó: Manuel Osuna Valencia                 				**--
		--**	Actividad: Se modifica el tipo de dato de las variables de salida	**--
		--**	Solicito: Mauricio León								**--
		--**	Fecha: 05/08/09									**--
	--************************************************************--
DEFINE sql_err					INTEGER;
DEFINE cod_err					CHAR(5);
DEFINE vimpcomconvenio			MONEY(14,2);
DEFINE vIVAimpconvenio			MONEY(14,2);
DEFINE vimpcomcte				MONEY(14,2);
DEFINE vIVAimpcomcte			MONEY(14,2);
DEFINE vFlgporccomtrans_conv	CHAR(1);
DEFINE vPorc_com_trans_conv		MONEY(16,2);
DEFINE vFlgporccomtotal_conv	CHAR(1);
DEFINE vPorc_com_total_conv		MONEY(16,2);
DEFINE vFlgimpcomtrans_conv		CHAR(1);
DEFINE vImp_com_trans_conv		MONEY(16,2);
DEFINE vFlgimpcomtotal_conv		CHAR(1);
DEFINE vImp_com_total_conv		MONEY(16,2);
DEFINE vFlgivaincluido_conv		CHAR(1);
DEFINE vIva_convenio			INTEGER;
DEFINE vFlgporccomtrans_cte		CHAR(1);
DEFINE vPorc_com_trans_cte		MONEY(16,2);
DEFINE vFlgimpcomtrans_cte		CHAR(1);
DEFINE vImp_com_trans_cte		MONEY(16,2);

LET cod_err					="000";	
LET vimpcomconvenio 		= 0;
LET vIVAimpconvenio	 		= 0;
LET vimpcomcte 				= 0;
LET vIVAimpcomcte 			= 0;
LET vFlgporccomtrans_conv	="";
LET vPorc_com_trans_conv	= 0;
LET vFlgporccomtotal_conv	="";
LET vPorc_com_total_conv	= 0;
LET vFlgimpcomtrans_conv	="";
LET vImp_com_trans_conv		= 0;
LET vFlgimpcomtotal_conv	="";
LET vImp_com_total_conv		= 0;
LET vFlgivaincluido_conv	="";
LET vIva_convenio			= 0;
LET vFlgporccomtrans_cte	="";
LET vPorc_com_trans_cte		= 0;
LET vFlgimpcomtrans_cte		="";
LET vImp_com_trans_cte		= 0;


 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
            RETURN cod_err, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;
      END IF ;
END EXCEPTION ;


SELECT 
    flgporccomtrans_conv,porc_com_trans_conv,   
    flgporccomtotal_conv,porc_com_total_conv,   /* comisiones por % o por monto pero total por día*/
    flgimpcomtrans_conv, imp_com_trans_conv,    
    flgimpcomtotal_conv, imp_com_total_conv,    /* comisiones por % o por monto pero total por día*/
    flgivaincluido_conv, iva_convenio,  		/* = 1 incluye IVA la comision (quitar el IVA del monto de comisión)*/
												/* = 0 calcular IVA de la comision (no se altera el monto de comisión)*/
												/* y el valor para cálculo del IVA esta en el campo iva_convenio */
    flgporccomtrans_cte, porc_com_trans_cte,    /*comisión al cliente en % por transacción*/
                                                /*se toma el monto del pago y se calcula la comisión*/
    flgimpcomtrans_cte, imp_com_trans_cte       /*comisión al cliente en monto fijo por transacción*/
INTO vFlgporccomtrans_conv,vPorc_com_trans_conv,   
    vFlgporccomtotal_conv,vPorc_com_total_conv, vFlgimpcomtrans_conv, vImp_com_trans_conv,    
    vFlgimpcomtotal_conv, vImp_com_total_conv, vFlgivaincluido_conv, vIva_convenio, 
    vFlgporccomtrans_cte, vPorc_com_trans_cte, vFlgimpcomtrans_cte, vImp_com_trans_cte  	
FROM BDISAC:sac_convenios
where numcategoria = pcategoria
and numconvenio = pconvenio;

    /*comisión del convenio*/
    IF vFlgporccomtotal_conv = 1 OR vFlgimpcomtotal_conv = 1 THEN 		/* comisiones por % o por monto pero total por día*/
        LET vimpcomconvenio = 0;                                        /* no debe grabar nada en linea (ceros)*/
    ELIF vFlgporccomtrans_conv = 1 THEN                       			/*comision es % por monto de transacción*/
        LET vimpcomconvenio = ppago * (vPorc_com_trans_conv/100);
    ELIF vFlgimpcomtrans_conv = 1 THEN                        			/*comision en monto por transacción*/ 
        LET vimpcomconvenio = vImp_com_trans_conv;
    ELSE 
        LET vimpcomconvenio = 0 ;                                      	/*no debe grabar nada en linea (ceros)*/
    END IF;
          
    /*comisíón a cliente QUE SE DEBE SUMAR AL IMPORTE DE CARGO POR PAGO ADEMAS DE REGISTRARSE EN SAC_MOVIMIENTOS*/
    IF vFlgporccomtrans_cte = 1 THEN                         			/*comisión al cliente en % por transacción*/
        LET vimpcomcte = ppago * (vPorc_com_trans_cte/100);
    ELIF vFlgimpcomtrans_cte = vImp_com_trans_cte THEN     				/*comisión al cliente en monto fijo por transacción*/
        LET vimpcomcte = vImp_com_trans_cte;
    ELSE
        LET vimpcomcte = 0;
    END IF;

    /*CALCULA IVA DE COMISIONES*/
    LET vIVAimpconvenio = vimpcomconvenio * (vIva_convenio/100);    	/*calculo iva de convenio*/
    LET vIVAimpcomcte = vimpcomcte * (vIva_convenio/100);        		/*calculo iva de cliente*/

    IF vFlgivaincluido_conv = 1 THEN     /*SE EXTRAE IVA DE LA COMISION*/      
        LET vimpcomconvenio = vimpcomconvenio - vIVAimpconvenio;
        LET vimpcomcte = vimpcomcte - vIVAimpcomcte;
    END IF;

	RETURN cod_err, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;
END;
END PROCEDURE;