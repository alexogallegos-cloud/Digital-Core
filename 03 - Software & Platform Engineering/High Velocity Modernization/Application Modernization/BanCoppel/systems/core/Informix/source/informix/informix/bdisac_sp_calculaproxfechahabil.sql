CREATE PROCEDURE "informix".sp_calculaproxfechahabil(dfecha DATE)
RETURNING DATE;

   DEFINE cCodret           CHAR(5);
   DEFINE dProxFecHabil     DATE;
   DEFINE cEsFeriado        CHAR(1);
   DEFINE cFlag             CHAR(1);
   DEFINE dFechaAux         DATE;
   DEFINE iSql_err,iIsam_err INTEGER;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   --LET cCodret    = "00000";
   LET dProxFecHabil = " ";
   LET cEsFeriado = "0";

-- ****************************************************************************
-- valida datos de entrada
-- ****************************************************************************

    IF  dFecha IS NULL THEN
        -- datos de entrada incompletos
        --LET cCodret = 110;
        RETURN dProxFecHabil;
    END IF;


    BEGIN

        ON EXCEPTION SET iSql_err, iIsam_err
        IF iSql_err <> 0 or iIsam_err <> 0 then
            --LET cCodret = iSql_err;
            RETURN dProxFecHabil;
        END IF;
        END EXCEPTION;

        --SET DEBUG FILE TO "/tmp/exi.out";
        --TRACE ON;

        LET dFechaAux = dFecha;

        SELECT "1"
        INTO cEsFeriado
        FROM bdinteg:si_feriado
        WHERE fecha = dFechaAux;

        IF cEsFeriado IS NULL THEN
            LET cEsFeriado = "0";
        END IF

        IF cEsFeriado <>"1" AND TO_CHAR(dFechaAux,"%A") <> "Saturday" AND TO_CHAR(dFechaAux,"%A") <> "Sunday"  THEN
            LET dFechaAux = dFechaAux + 1;
        END IF


        IF cEsFeriado = "1"   THEN
            LET dFechaAux = dFechaAux + 1;
        END IF

        IF TO_CHAR(dFechaAux,"%A") = "Saturday" THEN
            LET dFechaAux = dFechaAux + 2;
        END IF

        IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
            LET dFechaAux = dFechaAux + 1;
        END IF

        -- barrer hasta obtener el sig. habil

        LET cFlag = "0";

        WHILE cFlag = "0"
            -- validar si la nueva fecha es feriado
            SELECT "1"
            INTO cEsFeriado
            FROM bdinteg:si_feriado
            WHERE fecha=dFechaAux;

            IF cEsFeriado is null THEN
                LET cEsFeriado = "0";
            END IF

            IF cEsFeriado <> "1" and TO_CHAR(dFechaAux,"%A") <> "Saturday" and TO_CHAR(dFechaAux,"%A") <> "Sunday" THEN
                -- salir
                LET cFlag = "1";
            ELSE
                LET dFechaAux = dFechaAux + 1;
            END IF

        END WHILE

        LET dProxFecHabil = dFechaAux;

    END;

    RETURN dProxFecHabil;

END PROCEDURE
DOCUMENT
'AUTOR : José Angel López Adams',
'DESCRIPCION: Se encarga obtener la fecha del proximo dia habil',
'EJECUTADO O LLAMADO POR: sp_generaArchivoCobranzaTelmex()',
'FECHA : Septiembre de 2008',
'VERSION: 20080930',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacconsultascentral (cInput CHAR (5))

    -- DATOS A REGRESAR
    RETURNING
    CHAR(5)  AS retorno, --Codigo de Retorno
    CHAR(2) AS numcategoria, CHAR(3)  AS numconvenio, CHAR(40) AS nomconvenio, DATE AS fechaapertura, DATE AS fechaclausura, DATE AS fechaalta,
    CHAR(1) AS statusconvenio, CHAR(1) AS tipo_referencia, CHAR(40) AS nomlegalempresa, CHAR(13) AS rfcempresa, CHAR(40) AS nomcomercialempresa,
    CHAR(80) AS direccionempresa, CHAR(30) AS estado, CHAR(30) AS ciudad, CHAR(5)  AS codpostal, CHAR(10) AS numtelcorporativo, CHAR(10) AS numfaxcorporativo,
    CHAR(40) AS nomcontacto1, CHAR(10) AS numtelcontacto1, CHAR(7) AS numextcontacto1, CHAR(40) AS emailcontacto1, CHAR(40) AS nomcontacto2,
    CHAR(10) AS numtelcontacto2, CHAR(7) AS numextcontacto2, CHAR(40) AS emailcontacto2, CHAR(40) AS nomcontacto3, CHAR(10) AS numtelcontacto3,
    CHAR(7) AS numextcontacto3, CHAR(40) AS emailcontacto3, CHAR(18) AS numcuentaclabe, CHAR(1) AS tipopago, INTEGER AS frecuenciapago,
    CHAR(1) AS flgarchnotificacion, INTEGER AS frecnotificacion, CHAR(1) AS flgporccomtrans_conv, DECIMAL AS porc_com_trans_conv, CHAR(1) AS flgporccomtotal_conv,
    DECIMAL AS porc_com_total_conv, CHAR(1) AS flgimpcomtrans_conv, MONEY(16,2) AS imp_com_trans_conv, CHAR(1) AS flgimpcomtotal_conv, MONEY(16,2)AS imp_com_total_conv,
    CHAR(1) AS flgivaincluido_conv, INTEGER  AS iva_convenio, CHAR(1) AS flgporccomtrans_cte, DECIMAL  AS porc_com_trans_cte, CHAR(1) AS flgimpcomtrans_cte,
    MONEY(16,2)AS imp_com_trans_cte, CHAR(1) AS flg_ref1, INTEGER AS longitud_ref1, CHAR(1) AS flgcalculodv_ref1, CHAR(30)  AS nomrutinadv_ref1, CHAR(1) AS flg_ref2,
    INTEGER AS longitud_ref2, CHAR(1) AS flgcalculodv_ref2, CHAR(30) AS nomrutinadv_ref2, CHAR(1) AS flgreporte, CHAR(30) AS nomreporte;


    -- DEFINICION DE VARIABLES
    DEFINE cCodRet              CHAR(5);
    DEFINE cNumcategoria        CHAR(2);
    DEFINE cNumconvenio         CHAR(3);
    DEFINE cNomconvenio         CHAR(40);
    DEFINE dFechaapertura       DATE;
    DEFINE dFechaclausura       DATE;
    DEFINE dFecha_alta          DATE;
    DEFINE cStatusconvenio      CHAR(1);
    DEFINE cTipo_Referencia     CHAR(1);
    DEFINE cNomlegalempresa     CHAR(40);
    DEFINE cRfcempresa          CHAR(13);
    DEFINE cNomcomercialempresa CHAR(40);
    DEFINE cDireccionempresa    CHAR(80);
    DEFINE cEstado              CHAR(30);
    DEFINE cCiudad              CHAR(30);
    DEFINE cCodpostal           CHAR(5);
    DEFINE cNumtelcorporativo   CHAR(10);
    DEFINE cNumfaxcorporativo   CHAR(10);
    DEFINE cNomcontacto1        CHAR(40);
    DEFINE cNumtelcontacto1     CHAR(10);
    DEFINE cNumextcontacto1     CHAR(7);
    DEFINE cEmailcontacto1      CHAR(40);
    DEFINE cNomcontacto2        CHAR(40);
    DEFINE cNumtelcontacto2     CHAR(10);
    DEFINE cNumextcontacto2     CHAR(7);
    DEFINE cEmailcontacto2      CHAR(40);
    DEFINE cNomcontacto3        CHAR(40);
    DEFINE cNumtelcontacto3     CHAR(10);
    DEFINE cNumextcontacto3     CHAR(7);
    DEFINE cEmailcontacto3      CHAR(40);
    DEFINE cNumcuentaclabe      CHAR(18);
    DEFINE cTipopago            CHAR(1);
    DEFINE iFrecuenciapago      INTEGER;
    DEFINE cFlgarchnotificacion CHAR(1);
    DEFINE iFrecnotificacion    INTEGER;
    DEFINE cFlgporccomtrans_conv CHAR(1);
    DEFINE dePorc_com_trans_conv DECIMAL;
    DEFINE cFlgporccomtotal_conv CHAR(1);
    DEFINE dePorc_com_total_conv DECIMAL;
    DEFINE cFlgimpcomtrans_conv  CHAR(1);
    DEFINE mImp_com_trans_conv   MONEY;
    DEFINE cFlgimpcomtotal_conv  CHAR(1);
    DEFINE mImp_com_total_conv   MONEY;
    DEFINE cFlgivaincluido_conv  CHAR(1);
    DEFINE iIva_Convenio         INTEGER;
    DEFINE cFlgPorcComTransCte   CHAR(1);
    DEFINE dePorc_com_trans_cte  DECIMAL;
    DEFINE cFlgImpComTransCte    CHAR(1);
    DEFINE mImp_com_trans_cte   MONEY;
    DEFINE cFlg_Ref1            CHAR(1);
    DEFINE iLongitudRef1        INTEGER;
    DEFINE cFlgcalculodv_ref1   CHAR(1);
    DEFINE cNomrutinadv_ref1    CHAR(30);
    DEFINE cFlg_Ref2            CHAR(1);
    DEFINE iLongitudRef2        INTEGER;
    DEFINE cFlgcalculodv_ref2   CHAR(1);
    DEFINE cNomrutinadv_ref2    CHAR(30);
    DEFINE cFlgreporte          CHAR(1);
    DEFINE cNomreporte          CHAR(30);
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(200);


    --SET DEBUG FILE TO "/home/informix/exi.out";
    --TRACE ON;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet              = "00000";
    LET cNumcategoria        = SUBSTRING(cInput FROM 1 FOR 2);
    LET cNumconvenio         = SUBSTRING(cInput FROM 3 FOR 3);
    LET cNomconvenio         = "";
    LET dFechaapertura       = '01-01-1900';
    LET dFechaclausura       = '01-01-1900';
    LET dFecha_alta          = '01-01-1900';
    LET cStatusconvenio      = "";
    LET cTipo_Referencia     = "";
    LET cNomlegalempresa     = "";
    LET cRfcempresa          = "";
    LET cNomcomercialempresa = "";
    LET cDireccionempresa    = "";
    LET cEstado              = "";
    LET cCiudad              = "";
    LET cCodpostal           = "";
    LET cNumtelcorporativo   = "";
    LET cNumfaxcorporativo   = "";
    LET cNomcontacto1        = "";
    LET cNumtelcontacto1     = "";
    LET cNumextcontacto1     = "";
    LET cEmailcontacto1      = "";
    LET cNomcontacto2        = "";
    LET cNumtelcontacto2     = "";
    LET cNumextcontacto2     = "";
    LET cEmailcontacto2      = "";
    LET cNomcontacto3        = "";
    LET cNumtelcontacto3     = "";
    LET cNumextcontacto3     = "";
    LET cEmailcontacto3      = "";
    LET cNumcuentaclabe      = "" ;
    LET cTipopago            = "";
    LET iFrecuenciapago      = 0;
    LET cFlgarchnotificacion = "";
    LET iFrecnotificacion    = 0;
    LET cFlgporccomtrans_conv= '0';
    LET dePorc_com_trans_conv= 0;
    LET cFlgporccomtotal_conv= '0';
    LET dePorc_com_total_conv= 0;
    LET cFlgimpcomtrans_conv = '0';
    LET mImp_com_trans_conv = 0;
    LET cFlgimpcomtotal_conv = '0';
    LET mImp_com_total_conv = 0;
    LET cFlgivaincluido_conv = '0';
    LET iIva_Convenio        = 0;
    LET cFlgPorcComTransCte  = '0';
    LET dePorc_com_trans_cte = 0;
    LET cFlgImpComTransCte   = '0';
    LET mImp_com_trans_cte  = 0;
    LET cFlg_Ref1            = '0';
    LET iLongitudRef1        = 0;
    LET cFlgcalculodv_ref1   = '0';
    LET cNomrutinadv_ref1    = "";
    LET cFlg_Ref2            = "";
    LET iLongitudRef2        = 0;
    LET cFlgcalculodv_ref2   = '0';
    LET cNomrutinadv_ref2    = "";
    LET cFlgreporte          = '0';
    LET cNomreporte          = "";
    LET iSqlErr              = 0;
    LET iIsamErr             = 0;
    LET cInfoErr             = "";
    BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_SacConsultascentral");
                        RETURN cCodRet, cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, dFecha_alta, cStatusconvenio, cTipo_Referencia, cNomlegalempresa, cRfcempresa, cNomcomercialempresa,
                        cDireccionempresa, cEstado, cCiudad, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1, cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2,
                        cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3, cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago,
                        cFlgarchnotificacion, iFrecnotificacion, cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
                        cFlgimpcomtotal_conv, mImp_com_total_conv, cFlgivaincluido_conv, iIva_Convenio, cFlgPorcComTransCte, dePorc_com_trans_cte, cFlgImpComTransCte, mImp_com_trans_cte, cFlg_Ref1,
                        iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2, cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte;
                END IF;
        END EXCEPTION;

        IF cNumconvenio <> "" OR cNumconvenio IS NOT NULL THEN

            SELECT numcategoria, numconvenio, nomconvenio, fechaapertura, fechaclausura, fechaalta, statusconvenio, nomlegalempresa, rfcempresa, nomcomercialempresa,
                direccionempresa, codpostal, numtelcorporativo, numfaxcorporativo, nomcontacto1, numtelcontacto1, numextcontacto1, emailcontacto1, nomcontacto2,
                numtelcontacto2, numextcontacto2, emailcontacto2, nomcontacto3, numtelcontacto3, numextcontacto3, emailcontacto3, numcuentaclabe, tipopago, frecuenciapago,
                flgarchnotificacion, frecnotificacion, flgporccomtrans_conv, porc_com_trans_conv, flgporccomtotal_conv, porc_com_total_conv, flgimpcomtrans_conv, imp_com_trans_conv,
                flgimpcomtotal_conv, imp_com_total_conv, flgivaincluido_conv, iva_convenio, flgporccomtrans_cte, porc_com_trans_cte, flgimpcomtrans_cte, imp_com_trans_cte, flg_ref1,
                longitud_ref1, flgcalculodv_ref1, nomrutinadv_ref1, flg_ref2, longitud_ref2, flgcalculodv_ref2, nomrutinadv_ref2, flgreporte, nomreporte
            INTO cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, dFecha_alta, cStatusconvenio, cNomlegalempresa, cRfcempresa, cNomcomercialempresa,
                cDireccionempresa, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1, cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2,
                cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3, cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago,
                cFlgarchnotificacion, iFrecnotificacion, cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
                cFlgimpcomtotal_conv, mImp_com_total_conv, cFlgivaincluido_conv, iIva_Convenio, cFlgPorcComTransCte, dePorc_com_trans_cte, cFlgImpComTransCte, mImp_com_trans_cte, cFlg_Ref1,
                iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2, cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte
            FROM bdisac:sac_convenios
            WHERE numcategoria = cNumCategoria
            AND numconvenio = cNumConvenio;


            SELECT a.descripcion
            INTO cTipo_Referencia
            FROM bdisac:sac_tiporeferencia a, bdisac:sac_convenios b
            WHERE a.tipo_referencia = b.tipo_referencia
            AND b.numcategoria = cNumCategoria
            AND b.numconvenio = cNumConvenio;

            SELECT a.nombre, b.nombre
            INTO cEstado, cCiudad
            FROM bdinteg:si_estados a,bdinteg:si_ciudades b, bdisac:sac_convenios c
            WHERE a.estado = c.estado
            AND b.estado = a.estado
            AND b.ciudad = c.ciudad
            AND c.numcategoria = cNumCategoria
            AND c.numconvenio = cNumConvenio;

        ELSE

            LET cCodRet = "00001";

        END IF;


        RETURN cCodRet, cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, dFecha_alta, cStatusconvenio, cTipo_Referencia,
               cNomlegalempresa, cRfcempresa, cNomcomercialempresa, cDireccionempresa, cEstado, cCiudad, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo,
               cNomcontacto1, cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2, cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2,
               cNomcontacto3, cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago, cFlgarchnotificacion,
               iFrecnotificacion, cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv,
               mImp_com_trans_conv, cFlgimpcomtotal_conv, mImp_com_total_conv, cFlgivaincluido_conv, iIva_Convenio, cFlgPorcComTransCte, dePorc_com_trans_cte,
               cFlgImpComTransCte, mImp_com_trans_cte, cFlg_Ref1, iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2,
               cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Jesus Montoya',
'DESCRIPCION: Se encarga de consultar la informaciÃ³e un convenio de la tabla ',
'             bdisac:sac_convenios de Central',
'EJECUTADO O LLAMADO POR: cocsac.exe, cacsac.exe del sistema de administracion de convenios',
'FECHA : Agosto de 2008',
'VERSION: 20080905',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_consulta_convenio(pcategoria CHAR(2),pconvenio CHAR(3))
returning CHAR(5),CHAR(40),CHAR(1),CHAR(1),INTEGER,CHAR(1),CHAR(1),INTEGER,CHAR(1);
	--************************************************************--
	--**	Elaboró: Ramon Octavio Romero Mascareño       **--
	--**	Actividad: Consulta Convenio                                   **--
	--**	Solicito: Mauricio León						       **--
	--**	Fecha: 10/07/09								   **--
	--************************************************************--
	DEFINE sql_err			INTEGER;
	DEFINE cod_err			CHAR(5);
	DEFINE vflg_ref1		CHAR(1);
	DEFINE vflg_ref2		CHAR(1);
	DEFINE vlong_ref1		INTEGER;
	DEFINE vlong_ref2		INTEGER;
	DEFINE vflg_calculoref1	CHAR(1);
	DEFINE vflg_calculoref2	CHAR(1);
	DEFINE vNom_convenio		CHAR(40);
	DEFINE vstatus_convenio	CHAR(1);

	LET cod_err				="000";
	LET vflg_ref1			="";
	LET vflg_ref2			="";
	LET vlong_ref1			= 0;
	LET vlong_ref2			= 0;
	LET vflg_calculoref1	="";
	LET vflg_calculoref2	="";
	LET vNom_convenio		="";
	LET vstatus_convenio	="";

 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
            RETURN cod_err,vNom_convenio,vstatus_convenio,vflg_ref1,vlong_ref1,vflg_calculoref1,vflg_ref2,vlong_ref2,vflg_calculoref2;
      END IF ;
END EXCEPTION ;


    SELECT nomconvenio, statusconvenio,
		   flg_ref1, longitud_ref1, flgcalculodv_ref1,    	/*si tiene una referencia, obtiene longitud y rutina para validar dv*/
           flg_ref2, longitud_ref2, flgcalculodv_ref2    	/*si tiene una segunda referencia, obtiene longitud y rutina para validar dv*/
	INTO 	vNom_convenio, vstatus_convenio, vflg_ref1, vlong_ref1, vflg_calculoref1,
			vflg_ref2, vlong_ref2, vflg_calculoref2
    FROM BDISAC:sac_convenios
    WHERE numcategoria = pcategoria --02
    AND numconvenio = pconvenio;   --001

    IF vstatus_convenio = 'A' THEN
        LET cod_err = '000';
    ELSE
        LET cod_err = '001'; /*001 = el convenio no está activo*/
    END IF;

    RETURN cod_err,vNom_convenio,vstatus_convenio,vflg_ref1,vlong_ref1,vflg_calculoref1,vflg_ref2,vlong_ref2,vflg_calculoref2;
 END;
END PROCEDURE;