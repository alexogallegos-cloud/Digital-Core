create procedure "informix".sp_actualiza_monto_lineas(pempresa char(3))
returning char(6);

--Martha Aguirre
--08-Sep-09
--Se agrega filtro por tipo de ingreso en la búsqueda de tabla si_ingresos

Define sNumSolic       char(20);
Define sStatus         char(2);
Define mMonto          Money(14,2);
Define mNuevoMonto     Money(14,2);
Define mNuevoMontodif  Money(14,2);
Define mIngreso        Money(14,2);
Define sNumCte         char(20);
Define mCompromisos    Money(14,2);
Define mAuxCompromisos Money(14,2);
Define mLineaTienda    Money(14,2);
Define mAuxLineaTienda Money(14,2);
Define fFactor         DECIMAL(21,10);
Define mMontoPiso      Money(14,2);
Define mMontoTecho     Money(14,2);
Define vSecuencia      Smallint;
Define vSecuencia_aut  Smallint;
Define iTrans          Smallint;

Define sProducto       CHAR(4);
Define iReferencia     Integer;
Define sFuncion        Char(3);
Define dFecha          Date;
DEFINE sFolio          CHAR(16);
Define sSucursal       char(4);
Define sDivisa         char(2);
Define sTransac        char(4);
Define mVencido        Money(14,2);
Define mOtorgado       Money(14,2);

Define sFuente         Char(1);
DEFINE iComproboIngreso SMALLINT;
Define iMeses_Hist     SmallInt;
Define iMesesMinimo    SmallInt;
Define sComentario     like ss_autorizacion_especial.comentario; 
define sMarcaStatus    char(2);
define iEdad           integer;
define iEdadMax        integer;
define iEdadTopada      integer;

    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    DEFINE ERROR_INFO       VARCHAR(80);
    DEFINE P_COD_RET        VARCHAR(6);
    DEFINE MENSERROR        VARCHAR(100);

--Set debug file to 'sp_actualiza_monto_lineas.out';
--trace on;	
    --Set debug file to '/pisa/pisabanco/pisa_ftes/credito/coronel/solic/sp_actualiza_monto_lineas.out';
    --trace on;

Begin

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        ROLLBACK WORK;
        BEGIN WORK;
        LET MENSERROR = 'SQL ERR: ' || SQL_ERR|| ' ISAM: '||ISAM_ERR;
        Insert INTO AX_PASO(nom_spl, error, info )
        Values('sp_actualiza_monto_lineas', SQL_ERR, MENSERROR ||' ' ||TRIM(sNumSolic) || ' '||current);
        COMMIT WORK;
        RETURN P_COD_RET;
    END EXCEPTION; --WITH RESUME;

    LET P_COD_RET = '000000';
    LET sProducto = '6001';
    LET sTransac  = '0000';
    LET sNumSolic = '';
    LET iEdadTopada = 75;

    SELECT fecha_hoy
    INTO dFecha
    FROM bdicred:sd_fechas
    WHERE empresa = pempresa;

    SELECT valor 
    INTO iMesesMinimo -- Meses de Historia base
    FROM ss_param
    WHERE empresa = pempresa
    And secuencia = 308;

    IF iMesesMinimo IS NULL THEN
        LET P_COD_RET = '452';
        RETURN P_COD_RET;
    END IF;

    SELECT valor
    INTO iEdadMax
    FROM bdisolic:ss_param
    WHERE empresa = pempresa
    and secuencia = 311;

    IF iEdadMax is null then
        LET P_COD_RET = '452';
        RETURN P_COD_RET;
    END IF;

    Begin Work;

    ForEach with hold
    SELECT num_solicitud, status_solicitud, NVL(monto_solicitado,0), numcte
    INTO sNumSolic, sStatus, mMonto, sNumCte
    FROM bdisolic:ss_solicitudes
    WHERE empresa = pempresa
    and num_producto = sProducto
    and status_solicitud in ('EE', 'OA', 'OS', 'AT', 'AP')
    and fecha_insert <= '11052007'::date
--    and num_solicitud = '600000005220'

        --Set debug file to '/pisa/pisabanco/pisa_ftes/credito/coronel/solic/sp_actualiza_monto_lineas ' || TRIM(sNumSolic) ||'.out';
        --trace on;
        LET sNumSolic = sNumSolic;
        LET sStatus   = sStatus;
        LET mMonto    = mMonto;
        LET sNumCte   = sNumCte;
        LET mNuevoMontodif = 0;


        IF sStatus = 'AP' then
            LET mVencido  = 0;
            LET mOtorgado = 0;
            SELECT NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(mto_venc_int,0) + NVL(mto_venc_tra_int,0) as vencido, 
                NVL(monto_otorgado,0)
            INTO mVencido, mOtorgado
            FROM bdicred:sd_maesdos
            WHERE empresa = pempresa
            and num_credito = sNumSolic;

            IF NVL(mVencido,0) > 0 or NVL(mOtorgado,0) >= 21000 then
                Continue ForEach;
            END IF;
            LET mMonto = NVL(mOtorgado,0);
        Else
            IF mMonto >= 21000 then
                Continue ForEach;
            END IF;
        END IF;

        IF mMonto = 1400 then
            LET mNuevoMonto = 2100;
        Else
            LET iEdad = 0;

            SELECT bdisolic:anioscumplidos(dFecha, fecha_nac)
            INTO iEdad
            FROM bdinteg:si_ctepf
            WHERE empresa = pempresa
            and numcte = sNumCte;

            IF iEdad is null then
                LET iEdad = 0;
            END IF;

            IF iEdad > iEdadMax then
                Insert INTO AX_PASO(nom_spl, error, info )
                Values('sp_actualiza_monto_lineas', '00001', TRIM(sNumSolic) || ' ' ||current ||' Cliente con edad de '|| iEdad || 'años');
                Continue ForEach;
            END IF;

            LET mIngreso         = 0;
            LET mCompromisos     = 0;
            LET mAuxCompromisos  = 0;
            LET mLineaTienda     = 0;
            LET mAuxLineaTienda  = 0;
            LET iTrans           = 0;
            LET sFuente          = '';
            LET iComproboIngreso = 0;
            LET iMeses_Hist      = 0;

            SELECT NVL(ingreso_mensual,0), NVL(pago_minimo,0), NVL(linea_tienda,0), TRIM(NVL(fuente, ' ')), NVL(meses_historia,0)
            INTO mIngreso, mCompromisos, mLineaTienda, sFuente, iMeses_Hist
            FROM ss_resum_scor_fin 
            WHERE empresa = pempresa
            and num_solicitud = sNumSolic;

            IF mIngreso is null then
                LET mIngreso = 0;
                SELECT max(ingreso_mensual)
                INTO mIngreso
                FROM bdinteg:si_ingresos
                WHERE numcte = sNumCte
				AND tipo_ingreso= 'T'
				AND sec_ingreso=(SELECT max(sec_ingreso) 
								FROM bdinteg:si_ingresos 
								WHERE numcte=sNumCte 
								AND tipo_ingreso = 'T');
            END IF;
            IF mCompromisos is Null then 
                LET mCompromisos = 0;
            END IF;
            IF mLineaTienda is Null then
                LET mLineaTienda = 0;
            END IF;
            IF sFuente is null then
                LET sFuente = '';
            END IF;

            SELECT Count(*) 
            INTO iComproboIngreso
            FROM ss_detalle_scoring
            WHERE empresa = pempresa
            And num_solicitud = sNumSolic
            And seccion = 2
            And grupo = 14
            And elemento = 1;

            IF sFuente = 'T' and iMeses_Hist >= iMesesMinimo and iEdad < iEdadTopada then  
                LET fFactor     =     1.77;
                LET mMontoPiso  =  2800.00;
                LET mMontoTecho = 21000.00;
                LET mAuxCompromisos = mCompromisos; 
                LET mAuxLineaTienda = mLineaTienda;
            Else
                IF iComproboIngreso > 0 and iEdad < iEdadTopada then --Comprobando Ingresos
                    LET fFactor     =     1.33;
                    LET mMontoPiso  =  5600.00;
                    LET mMontoTecho =  8400.00;
                Else    --Linea Original de 2800
                    LET fFactor     =     1.33 * .50 ;
                    LET mMontoPiso  =  2800.00;
                    LET mMontoTecho =  6400.00;
                END IF;
            END IF;

            LET mNuevoMonto = (mIngreso * fFactor) - mAuxCompromisos;
            LET mNuevoMonto = Round(mNuevoMonto, -2);
            IF mAuxLineaTienda > 0 and mNuevoMonto > Round(mAuxLineaTienda, -2) then
                LET mNuevoMonto = Round(mAuxLineaTienda, -2);
            END IF;

            IF mNuevoMonto < mMontoPiso then
                LET mNuevoMonto = mMontoPiso;
            Elif mNuevoMonto > mMontoTecho then
                LET mNuevoMonto = mMontoTecho;
            END IF;
            IF mNuevoMonto <= mMonto then
                Continue ForEach;
            END IF;
        END IF;

        IF sStatus <> 'AP' then
            LET sComentario = '001 Actualizacion de línea por sistema a solicitud';
            LET sMarcaStatus = '-';

            Update ss_solicitudes 
            Set monto_solicitado = mNuevoMonto
            WHERE empresa = pempresa
            and num_solicitud = sNumSolic;

        Elif sStatus = 'AP' then
            LET sComentario = '001 Actualizacion de línea por sistema a credito';
            LET sMarcaStatus = '--';

            LET iReferencia = 1;
            LET sFuncion    = '008';

            Update bdicred:sd_maesdos
            Set monto_otorgado = mNuevoMonto
            WHERE empresa = pempresa
            and num_credito = TRIM(sNumSolic);

            SELECT first 1 secuencia 
            INTO vSecuencia
            FROM bdicred:sd_tarjeta a 
            WHERE empresa = pempresa
            and num_credito = TRIM(sNumSolic)
            and status_tar = 'A'
            and tipo_tarjeta = 'T'
            and secuencia = 
                (
                    SELECT max(secuencia) 
                    FROM bdicred:sd_tarjeta b 
                    WHERE a.empresa = pempresa
                    and a.num_credito = b.num_credito
                    and a.tipo_tarjeta = b.tipo_tarjeta 
                    and a.status_tar = b.status_tar
                );

            Update bdicred:sd_tarjeta
            Set limite_aut = mNuevoMonto
            WHERE empresa = pEmpresa
            and num_credito = TRIM(sNumSolic)
            and secuencia = vSecuencia;

            SELECT USER||lpad(DAY(CURRENT), 2, '0')||lpad(MONTH(CURRENT), 2, '0')||SUBSTR(current,3,2)||
                   SUBSTR(CURRENT,12,2)||substr(current,15,2)
                   ||SUBSTR(current,18,2)
            INTO sFolio
            FROM dual;

            SELECT sucursal, divisa 
            INTO sSucursal, sDivisa
            FROM bdicred:sd_maecred
            WHERE empresa = pempresa
            and num_credito = sNumSolic;

            LET mNuevoMontodif = mNuevoMonto - mMonto;

            Call bdicred:GenMov(pempresa, sNumSolic, sProducto, iReferencia,
                           sFuncion, dFecha, mNuevoMontodif, sFolio,
                           sSucursal, sDivisa, sTransac) 
                           Returning P_COD_RET, ERROR_INFO;

            IF P_COD_RET = '00000' then
                LET P_COD_RET = '000000';
            Else
                Exit ForEach;
            END IF;
        END IF;

        SELECT NVL(max(secuencia),0)
        INTO vSecuencia_aut
        FROM ss_autorizacion_especial
        WHERE empresa = pempresa
        and num_solicitud = sNumSolic;

        LET vSecuencia_aut = vSecuencia_aut + 1;

        Insert INTO ss_autorizacion_especial
            (empresa, num_solicitud, numcte, secuencia, comentario, montolinea_ant, montolinea_nvo, status_ant, status_nvo, usuario_modif, fecha_modif)
        Values
            (pempresa, sNumSolic, sNumCte, vSecuencia_aut, sComentario, mMonto, mNuevoMonto, sMarcaStatus, sMarcaStatus, 'sistema', current);

    END ForEach;

    IF P_COD_RET = '000000' THEN
        Commit Work;
    Else
        RollBack Work;
        Begin Work;
        Insert INTO AX_PASO(nom_spl, error, info )
        Values('sp_actualiza_monto_lineas', P_COD_RET, TRIM(sNumSolic) || ' ' ||current);
        Commit Work;
    END IF;
    RETURN P_COD_RET;
END;
END procedure;