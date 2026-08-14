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