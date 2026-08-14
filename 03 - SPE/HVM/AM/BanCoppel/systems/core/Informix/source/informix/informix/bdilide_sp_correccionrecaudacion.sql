CREATE PROCEDURE "informix".sp_correccionrecaudacion(pNumeroCliente CHAR(20), pAnoMes CHAR(6), pNumeroFolio CHAR(12), pTipoPendiente CHAR(1), pUsuario CHAR(8))

--*******************************************************************************************************
-- Realizo   : Aymme Osuna y Alejandro Osuna
-- Proyecto : Correción Recaudacion del LIDE
-- Actividad : Ejecuta el proceso de correción de movimientos que no se debieron de haberce cobrado al cliente en un periodo de
--                  tiempo.
-- Fecha     : Julio de 2008
--*******************************************************************************************************
--*******************************************************************************************************
-- Realizo   :Alejandro Osuna
-- Proyecto : Correción Recaudacion del LIDE
-- Actividad : Se modifico para tomar en cuenta a las diferente tipos de personas y grabar en la carta de devolucion..
-- Fecha     : Agosto de 2008
--*******************************************************************************************************
--*******************************************************************************************************
-- Realizo   :Alejandro Osuna
-- Proyecto : Correción Recaudacion del LIDE
-- Actividad : Se modifico para realizar el redondeo del calculo del IDE..
-- Fecha     : 06 Noviembre de 2008
--*******************************************************************************************************



RETURNING CHAR(5), CHAR(100);

--DEFINE VARIABLES

DEFINE cCodRet                    CHAR(5);
DEFINE sql_err                    SMALLINT;
DEFINE  cMensaje                  CHAR(100);
DEFINE cRfc                       CHAR(13);
DEFINE cNombre1                   CHAR(26);
DEFINE cNombre2                   CHAR(26);
DEFINE cApell_Paterno             CHAR(26);
DEFINE cApell_Materno             CHAR(26);
DEFINE cNombre                 CHAR(60);
DEFINE mImp_Acumulado     MONEY(16,2);
DEFINE mImp_Recaudado     MONEY(16,2);
DEFINE mImp_Exceso          MONEY(16,2);
DEFINE dFecha_Insert           DATE;
DEFINE mSumaGrid               MONEY(16,2);
DEFINE mSumaMov               MONEY(16,2);
DEFINE mPorciento               MONEY(16,2);
DEFINE mTotalDep                 MONEY(16,2);
DEFINE mLimiteLide             MONEY(16,2);
DEFINE mGravado                   MONEY(16,2);
DEFINE sNum_Serial              INTEGER;
DEFINE cRef_Ret                 CHAR(20);
DEFINE cTipo_Cta                CHAR(1);
DEFINE dFecha_Mov              DATE;
DEFINE mImp_Tot_Dep            MONEY(16,2);
DEFINE mImp_Ide                    MONEY(16,2);
DEFINE cNum_Cta                 CHAR(20);
DEFINE dFechaGrid                       DATE;
DEFINE sCuentaGrid                      CHAR(20);
DEFINE sSucursalGrid                    CHAR(4);
DEFINE mImporteGrid                     MONEY(16,2);
DEFINE mImp_Gravado                 MONEY(16, 2);
DEFINE mImp_Arecaudar               MONEY(16,2);
DEFINE cPendiete                        CHAR(1);
DEFINE mImp_Mesanterior             MONEY(16,2);
DEFINE iConsecutivo                     INTEGER;
DEFINE cCuenta_Ret                     CHAR(20);
DEFINE dFecha_Ret                       DATE;
DEFINE mPenRecau                    MONEY(16,2);
DEFINE iConDet                          INTEGER;
DEFINE cRfcDet                          CHAR(13);
DEFINE cRefRetDet                    CHAR(10);
DEFINE cCtaRetDet                   CHAR(20);
DEFINE mImpRecauDet             MONEY(16,2);
DEFINE dFechaDet                    DATE;
DEFINE mImpFi                           MONEY(16,2);
DEFINE mImpRecFI                    MONEY(16,2);
DEFINE  mImpAreFi                   MONEY(16,2);
DEFINE cImPend                      CHAR(1);
DEFINE mImpGraPo                MONEY(16,2);
DEFINE mGravaBan                MONEY(16,2);
DEFINE mImpPendFIn              MONEY(16,2);
DEFINE mImpAreFin               MONEY(16,2);
DEFINE mImpRecFin               MONEY(16,2);
DEFINE cPosit                        INTEGER;
DEFINE mImpDetConst                MONEY(16,2);
DEFINE mImpRecConst                 MONEY(16,2);
DEFINE mImpPenConst               MONEY(16,2);
DEFINE sTpoPersona              CHAR(2);
DEFINE sRazonSocial             CHAR(60);

--INICIALIZAMOS VARIABLES
LET cCodRet = "000";
LET cMensaje = "";
LET cRfc = "";
LET cNombre = "";
LET mImp_Acumulado = 0.00;
LET mImp_Recaudado = 0.00;
LET mImp_Exceso  = 0.00;
LET mSumaGrid = 0.00;
LET mSumaMov = 0.00;
LET mPorciento = 0.00;
LET mLimiteLide = 0.00;
LET dFecha_Insert = "";
LET mGravado = 0.00;
LET sNum_Serial= 0;
LET cRef_Ret = "";
LET cTipo_Cta = "";
LET dFecha_Mov = "";
LET mImp_Tot_Dep = 0.00;
LET mImp_Ide = 0.00;
LET cNum_Cta = "";
LET dFechaGrid = "";
LET sCuentaGrid  = "";
LET sSucursalGrid = "";
LET mImporteGrid = 0.00;
LET mImp_Gravado = 0.00;
LET mImp_Arecaudar = 0.00;
LET cPendiete ="";
LET mImp_Mesanterior  = 0.00;
LET iConsecutivo = 0;
LET cCuenta_Ret  = "";
LET dFecha_Ret = "";
LET mPenRecau = 0;
LET iConDet = 0;
LET cRfcDet = "";
LET cRefRetDet = "";
LET cCtaRetDet = "";
LET mImpRecauDet = 0.00;
LET dFechaDet = "";
LET mImpFi = 0.00;
 LET mImpAreFi = 0.00;
LET mImpRecFI = 0.00;
LET cImPend = "";
LET mImpGraPo = 0.00;
LET mGravaBan = 0.00;
LET mImpPendFIn = 0.00;
LET mImpAreFin = 0.00;
LET cPosit  = -1;
LET mImpDetConst = 0.00;
LET mImpRecConst = 0.00;
LET mImpPenConst = 0.00;
 LET sTpoPersona = "";
LET  sRazonSocial = "";

BEGIN

 ON EXCEPTION SET  sql_err
                    IF sql_err <> 0 THEN
                        LET cCodRet  =  sql_err;
                        LET cMensaje  =  "Corrección de Recaudación no Realizada";
                         ROLLBACK WORK;
                        RETURN cCodRet,  cMensaje;
                   END IF
                 END EXCEPTION

--SET DEBUG FILE TO "/tmp/sp_CorreccionRecaudacion.out";
--TRACE ON;

IF (pNumeroCliente = "") OR (pNumeroCliente is NULL) THEN
    LET cCodRet = "001";
    RETURN cCodRet,  cMensaje;
ELIF (pAnoMes = "") OR (pAnoMes is NULL) THEN
    LET cCodRet = "002";
    RETURN cCodRet,  cMensaje;
ELIF (pNumeroFolio = "") OR (pNumeroFolio is NULL) THEN
    LET cCodRet = "003";
    RETURN cCodRet,  cMensaje;
ELIF (pTipoPendiente = "") OR (pTipoPendiente  is NULL) THEN
    LET cCodRet = "004";
   RETURN cCodRet,  cMensaje;
ELIF (pUsuario = "") OR (pUsuario  is NULL) THEN
    LET cCodRet = "005";
   RETURN cCodRet,  cMensaje;
END IF;

IF EXISTS ( SELECT  aniomes FROM   bdilide:sl_cartadev WHERE folio_acl = pNumeroFolio ) THEN
    LET cCodRet = '007';
    LET cMensaje = 'Numero de folio existente';
    RETURN cCodRet, cMensaje;
END IF;

IF pTipoPendiente = "N" THEN --Proceso que se ejecuta cuando el cliente NO TIENE PENDIENTE
    Begin WORK;
     --Obtiene el nombre del cliente
    SELECT nombre1, nombre2, apell_paterno, apell_materno, tpo_persona, razon_social
    INTO cNombre1, cNombre2, cApell_Paterno, cApell_Materno,sTpoPersona, sRazonSocial
    FROM bdinteg:si_cliente
    WHERE numcte = pNumeroCliente;

    IF sTpoPersona = '01' then
		--concatena el nombre del cliente
         LET cNombre  =  TRIM(cNombre1)|| ' ' ||TRIM(cNombre2)|| ' ' ||TRIM(cApell_Paterno)|| ' ' ||TRIM(cApell_Materno);
    END IF

    IF sTpoPersona = '02' then
         LET cNombre  =  sRazonSocial;
    END IF


     --Obtiene los datos del rfc, total acumulado, importe recaudado
    SELECT rfc, imp_acumulado, imp_recaudado
    INTO cRfc, mImp_Acumulado, mImp_Recaudado
    FROM bdilide:sl_retlide
    WHERE num_cte = pNumeroCliente
    AND aniomes = pAnoMes;
    --Obtiene la suma de los movimientos que se seleccionaron en la aplicacion de correccion
    SELECT SUM (importe) INTO mSumaGrid FROM bdilide:sl_movgrid;
    --Obtiene la suma de los depositos originales
    SELECT SUM (imp_ide) INTO mSumaMov FROM bdilide:sl_movefec
    WHERE num_cte = pNumeroCliente
    AND aniomes = pAnoMes;
    --obtiene el valor minimo del IDE
    SELECT valor INTO mLimiteLide FROM bdilide:sl_parametros
    WHERE cve_param = '01';
    --calcula el monto total que debio tomarse en un inicio
    LET mTotalDep = mSumaMov - mSumaGrid;
    --calcula el monto exedente que debio tomarse en un inicio
    LET mGravado = mTotalDep - mLimiteLide;
    --valido si el importe es menor a cero
    IF mGravado <= 0 THEN
       LET mImp_Exceso =  mImp_Recaudado;
    ELSE
       --calculo el porcentaje real de IDE a cobrar
       LET mPorciento = (mGravado) * (0.02);
       LET mPorciento = ( mPorciento) - (.01);
	   LET mPorciento = Round(mPorciento);
       --calculo el exdente
       LET mImp_Exceso = mImp_Recaudado - mPorciento;
    END IF;

    INSERT INTO sl_cartadev(aniomes, num_cte, folio_acl, rfc, nombre, imp_acumulado, imp_recaudado, imp_exceso, user_insert, fecha_insert)
    VALUES( pAnoMes, pNumeroCliente, pNumeroFolio, cRfc, cNombre, mImp_Acumulado, mImp_Recaudado, mImp_Exceso, pUsuario, current hour to fraction(3));

END IF;

IF pTipoPendiente = "S" THEN
    Begin WORK;
        ForEach
            --obtener los movimientos originales que causaron IDE
            SELECT num_serial, rfc, ref_ret, tipo_cta,num_cta, fecha_mov, imp_tot_dep, imp_ide
            INTO sNum_Serial, cRfc, cRef_Ret, cTipo_Cta, cNum_Cta, dFecha_Mov, mImp_Tot_Dep, mImp_Ide
            FROM bdilide:sl_movefec
            WHERE aniomes =  pAnoMes
            AND num_cte = pNumeroCliente
             --Se insertan el la tabla de historico los movimientos originales
            INSERT INTO sl_histmov(aniomes, num_cte, num_serial, folio_acl, rfc, ref_ret, tipo_cta, num_cta, fecha_mov, imp_tot_dep, imp_ide, user_insert, fecha_insert)
            VALUES(pAnoMes, pNumeroCliente, sNum_Serial, pNumeroFolio, cRfc, cRef_Ret, cTipo_Cta,  cNum_Cta, dFecha_Mov,mImp_Tot_Dep, mImp_Ide, pUsuario, current hour to fraction(3));
        END FOREACH

        --Proceso que graba en el historico de recaudaciones
       IF EXISTS( SELECT num_cte FROM bdilide:sl_retlide WHERE num_cte = pNumeroCliente and aniomes = pAnoMes) THEN
            SELECT rfc, ref_ret, imp_acumulado, imp_gravado, imp_arecaudar, imp_recaudado, pendiente, imp_mesanterior
            INTO cRfc, cRef_Ret, mImp_Acumulado, mImp_Gravado, mImp_Arecaudar, mImp_Recaudado, cPendiete, mImp_Mesanterior
            FROM bdilide:sl_retlide
            WHERE num_cte = pNumeroCliente
            AND aniomes = pAnoMes;

            INSERT INTO sl_histret(aniomes, num_cte, folio_acl, rfc, ref_ret, imp_acumulado, imp_gravado, imp_arecaudar, imp_recaudado, pendiente, imp_mesanterior, user_insert, fecha_insert)
            VALUES(pAnoMes, pNumeroCliente, pNumeroFolio, cRfc, cRef_Ret, mImp_Acumulado, mImp_Gravado, mImp_Arecaudar, mImp_Recaudado, cPendiete, mImp_Mesanterior, pUsuario, current hour to fraction(3));
            --Compara si el importe a recaudar es mayor a cero
            IF mImp_Arecaudar > 0.00 THEN
                --obtengo la suma de los movimientos que no se debieron contabilizar
                SELECT SUM (importe) INTO mSumaGrid FROM bdilide:sl_movgrid;
                --Obtengo la suma de los movimientos inicialmente se contabilizaron
                SELECT SUM (imp_ide) INTO mSumaMov FROM bdilide:sl_movefec
                WHERE num_cte = pNumeroCliente
                AND aniomes = pAnoMes;
                ForEach
                    --obtiene los movimientos que NO debieron contabilizarse
                    SELECT fecha, cuenta, sucursal, importe
                    INTO dFechaGrid, sCuentaGrid, sSucursalGrid, mImporteGrid
                    FROM bdilide:sl_movgrid
                    --Se eliminan los movimientos que NO debieron contabilizarse
                    DELETE sl_movefec
                    WHERE aniomes = pAnoMes
                    AND num_cte = pNumeroCliente
                    AND sucursal = sSucursalGrid
                    AND fecha_mov = dFechaGrid
                    AND num_cta = sCuentaGrid
                    AND imp_ide = mImporteGrid;
                END FOREACH

                --Obtengo el importe minimo para aplicar IDE
                SELECT valor INTO mLimiteLide FROM bdilide:sl_parametros
                WHERE cve_param = '01';
                --Calculo el total de Dépositos
                LET mTotalDep = mSumaMov - mSumaGrid;
                --Calculo el total a Grabar
                LET mGravado = mTotalDep - mLimiteLide;
                --Verifico si el importe a grabar es menor a cero
                IF mGravado <=  0 THEN
                    LET mGravaBan = 0.00;
                    LET mPorciento =  0.00;
                    LET mImp_Exceso =  mImp_Recaudado;

                   --Obtener los datos del detalle de las recaudaciones
                 ForEach
                        SELECT  consecutivo, rfc, ref_ret, cuenta_ret, fecha_ret, imp_recaudado
                        INTO  iConDet, cRfcDet, cRefRetDet, cCtaRetDet, dFechaDet, mImpRecauDet
                        FROM bdilide:sl_detlide
                        WHERE aniomes = pAnoMes
                        AND num_cte = pNumeroCliente
                        --Insertar en la tabla de historico de detalle
                        INSERT INTO sl_histdet(aniomes, num_cte, folio_acl, consecutivo, rfc, ref_ret, cuenta_ret, fecha_ret, imp_recaudado, user_insert, fecha_insert)
                        VALUES (pAnoMes, pNumeroCliente , pNumeroFolio, iConDet, cRfcDet, cRefRetDet, cCtaRetDet, dFechaDet, mImpRecauDet,  pUsuario, current hour to fraction(3));
                   END ForEach;
                    --Actualizo mis recaudaciones
                    UPDATE bdilide:sl_retlide SET imp_acumulado = mTotalDep, imp_gravado = mGravaBan, imp_arecaudar = mPorciento
                    WHERE aniomes = pAnoMes
                    AND num_cte = pNumeroCliente;
                    --Así como también actualizar el campo PENDIENTE
                    UPDATE bdilide:sl_retlide SET pendiente = "N" WHERE num_cte = pNumeroCliente AND aniomes = pAnoMes;
                    --Grabar en el historico de constancia, la constancia original
                    INSERT INTO bdilide:sl_histcons(aniomes,num_cte,tipo_cons,folio_acl,rfc,imp_excedente,imp_arecaudar,imp_recaudado,imp_pendiente,imp_anterior,tipo_cambio,user_insert,fecha_insert)
                    SELECT aniomes,num_cte,tipo_cons,pNumeroFolio,rfc,imp_excedente,imp_arecaudar,imp_recaudado,imp_pendiente,imp_anterior,tipo_cambio,user_insert,fecha_insert
                    FROM bdilide:sl_constancias
                    WHERE num_cte = pNumeroCliente AND aniomes = pAnoMes;
                    --elimino la constancia original
                    DELETE bdilide:sl_constancias
                    WHERE num_cte = pNumeroCliente AND aniomes = pAnoMes;
                    -- obtengo datos y grabo la carta
                    IF mGravado < 0 then
                           SELECT nombre1, nombre2, apell_paterno, apell_materno, tpo_persona, razon_social
                            INTO cNombre1, cNombre2, cApell_Paterno, cApell_Materno,sTpoPersona, sRazonSocial
                            FROM bdinteg:si_cliente
                             WHERE numcte = pNumeroCliente;

                            IF sTpoPersona = '01' then
                                --concatena el nombre del cliente
                                LET cNombre  =  TRIM(cNombre1)|| ' ' ||TRIM(cNombre2)|| ' ' ||TRIM(cApell_Paterno)|| ' ' ||TRIM(cApell_Materno);
                            END IF

                          IF sTpoPersona = '02' then
                                LET cNombre  =  sRazonSocial;
                          END IF

                        INSERT INTO sl_cartadev(aniomes, num_cte, folio_acl, rfc, nombre, imp_acumulado, imp_recaudado, imp_exceso, user_insert, fecha_insert)
                        VALUES( pAnoMes, pNumeroCliente , pNumeroFolio, cRfc, cNombre, mImp_Acumulado, mImp_Recaudado, mImp_Exceso, pUsuario, current hour to fraction(3));
                    END IF;

                 ELSE
                     --Aplico el porcentaje al importe grabado
                    LET mPorciento = (mGravado) * (0.02);
                    LET mPorciento = (mPorciento) - (.01);
		    LET mPorciento = Round(mPorciento);
                    --calculo el excedente
                    LET mImp_Exceso = mImp_Recaudado - mPorciento;
                    --Actualizo mis recaudaciones
                    UPDATE bdilide:sl_retlide SET imp_acumulado = mTotalDep, imp_gravado = mGravado, imp_arecaudar = mPorciento
                    WHERE aniomes = pAnoMes
                    AND num_cte = pNumeroCliente;
                    --Así como también actualizar el campo PENDIENTE
                    IF (SELECT (imp_arecaudar - imp_recaudado) FROM bdilide:sl_retlide WHERE num_cte = pNumeroCliente AND aniomes = pAnoMes)  <= 0 THEN
                        UPDATE bdilide:sl_retlide SET pendiente = "N" WHERE num_cte = pNumeroCliente AND aniomes = pAnoMes;
                    ELSE
                        UPDATE bdilide:sl_retlide SET pendiente = "S" WHERE num_cte = pNumeroCliente AND aniomes = pAnoMes;
                    END IF;
                    --Validar cuando el ide a recaudar es igual a cero
                    IF mPorciento >= 0 THEN
                      ForEach
                          --Obtener los datos del detalle de las recaudaciones
                        SELECT  consecutivo, rfc, ref_ret, cuenta_ret, fecha_ret, imp_recaudado
                        INTO  iConDet, cRfcDet, cRefRetDet, cCtaRetDet, dFechaDet, mImpRecauDet
                        FROM bdilide:sl_detlide
                        WHERE aniomes = pAnoMes
                        AND num_cte = pNumeroCliente
                        --Insertar en la tabla de historico de detalle
                        INSERT INTO sl_histdet(aniomes, num_cte, folio_acl, consecutivo, rfc, ref_ret, cuenta_ret, fecha_ret, imp_recaudado, user_insert, fecha_insert)
                        VALUES (pAnoMes, pNumeroCliente , pNumeroFolio, iConDet, cRfcDet, cRefRetDet, cCtaRetDet, dFechaDet, mImpRecauDet,  pUsuario, current hour to fraction(3));
                        END ForEach;

                        --Grabar en el historico de constancia, la constancia original
                        INSERT INTO bdilide:sl_histcons(aniomes,num_cte,tipo_cons,folio_acl,rfc,imp_excedente,imp_arecaudar,imp_recaudado,imp_pendiente,imp_anterior,tipo_cambio,user_insert,fecha_insert)
                        SELECT aniomes,num_cte,tipo_cons,pNumeroFolio,rfc,imp_excedente,imp_arecaudar,imp_recaudado,imp_pendiente,imp_anterior,tipo_cambio,user_insert,fecha_insert
                        FROM bdilide:sl_constancias
                        WHERE num_cte = pNumeroCliente AND aniomes = pAnoMes;
                    --Obtengo los datos necesarioes para actualizar la constancia original
                    SELECT imp_arecaudar, imp_recaudado
                    INTO mImpAreFin, mImpRecFin
                    FROM bdilide:sl_retlide
                    WHERE num_cte = pNumeroCliente AND aniomes = pAnoMes;

                    ---- Obtengo el impuesto pendiente final
                    LET mImpPendFIn = mImpAreFin - mImpRecFin;
                   IF  mImpPendFIn  < 0 THEN
                            SELECT nombre1, nombre2, apell_paterno, apell_materno, tpo_persona, razon_social
                            INTO cNombre1, cNombre2, cApell_Paterno, cApell_Materno,sTpoPersona, sRazonSocial
                            FROM bdinteg:si_cliente
                             WHERE numcte = pNumeroCliente;

                            IF sTpoPersona = '01' then
                                --concatena el nombre del cliente
                                 LET cNombre  =  TRIM(cNombre1)|| ' ' ||TRIM(cNombre2)|| ' ' ||TRIM(cApell_Paterno)|| ' ' ||TRIM(cApell_Materno);
                            END IF

                            IF sTpoPersona = '02' then
                                LET cNombre  =  sRazonSocial;
                             END IF
                        INSERT INTO sl_cartadev(aniomes, num_cte, folio_acl, rfc, nombre, imp_acumulado, imp_recaudado, imp_exceso, user_insert, fecha_insert)
                        VALUES( pAnoMes, pNumeroCliente , pNumeroFolio, cRfc, cNombre, mImp_Acumulado, mImp_Recaudado, mImp_Exceso, pUsuario, current hour to fraction(3));
                        ---Actualizo la constnacia original
                        UPDATE bdilide:sl_constancias SET imp_excedente = mGravado, imp_arecaudar = mPorciento, imp_pendiente = mGravaBan
                        WHERE aniomes = pAnoMes
                        AND num_cte = pNumeroCliente;

                 ELSE
                     ---Actualizo la constnacia original
                     UPDATE bdilide:sl_constancias SET imp_excedente = mGravado, imp_arecaudar = mPorciento
                     WHERE aniomes = pAnoMes
                     AND num_cte = pNumeroCliente;

                    Select imp_arecaudar, imp_recaudado
                    INTO mImpDetConst, mImpRecConst
                    FROM bdilide:sl_constancias
                    WHERE aniomes = pAnoMes
                    AND num_cte = pNumeroCliente;

                    LET    mImpPenConst = mImpDetConst - mImpRecConst;

                     UPDATE bdilide:sl_constancias SET imp_pendiente = mImpPenConst
                     WHERE aniomes = pAnoMes
                     AND num_cte = pNumeroCliente;

                END IF;

                   END IF;
                 END IF;
	 END IF;

       ELSE
             LET cCodRet  = '008';
             LET cMensaje = 'El Cliente no existe en sl_retlide';
             ROLLBACK WORK;
            RETURN  cCodRet, cMensaje;
      END IF;
END IF;
    COMMIT WORK;
    RETURN cCodRet,  cMensaje;
END;
End Procedure;