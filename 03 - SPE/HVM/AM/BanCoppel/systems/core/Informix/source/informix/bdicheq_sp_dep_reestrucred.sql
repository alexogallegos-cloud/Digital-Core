CREATE PROCEDURE "informix".sp_dep_reestrucred(pempresa       CHAR(3),
                                               pcuenta        CHAR(20),
                                               ptransabono    CHAR(4),
                                               pmto_abono     DECIMAL(14,2),
                                               ptranscargo    CHAR(4),
                                               pmto_cargo     DECIMAL(14,2),
                                               pmto_anticipo   DECIMAL(14,2),
                                               pejecutivo      CHAR(20))

RETURNING CHAR(5);
-- ***************************************************************************
-- sp_dep_reestrucred
-- Version              1.0.0
-- Obejtivo:            Medio para acceder a un prestamo para reestructuras de Tarjeta Credito.
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima ModIFicacion: Junio-2009
--                      Creación de SPL
-- ***************************************************************************

--//Definicion de Variables
 DEFINE vsqlerr          INTEGER;
 DEFINE vCodRet          CHAR(5);

 DEFINE vt_ide_cobrado   DECIMAL(14,2);
 DEFINE vt_ide_xcobrar   DECIMAL(14,2);
 DEFINE vt_ide_aplicant  DECIMAL(14,2);
 DEFINE vt_sdocta        DECIMAL(14,2);
 DEFINE vt_dummy         CHAR(100);
 DEFINE vt_dummy1        CHAR(100);
 DEFINE vt_siglas        CHAR(2);
 DEFINE vt_disponible    DECIMAL(14,2);
 DEFINE vt_sucursal      CHAR(4);
 DEFINE vt_transuc       CHAR(4);
 DEFINE vt_cptopago      CHAR(40);
 DEFINE vt_codigo_mn     CHAR(2);
 DEFINE vt_hora          CHAR(15);
 DEFINE vt_folioliq      CHAR(16);
 DEFINE vt_fechahoy      DATE;
 DEFINE vt_ult_hab_mes   DATE;
 DEFINE vt_usuario       CHAR(8);
 DEFINE vt_aniomes       CHAR(6);
 DEFINE vt_numcte        CHAR(20);
 DEFINE bcargo           CHAR(1);
 DEFINE brecaudo         CHAR(1);

 --//Inicializa variables
 LET vCodRet = '000';
 LET vsqlerr = 0;
 LET vt_transuc  = "0000";
 LET vt_usuario = pejecutivo;
 LET vt_sdocta = 0;


 -- CONTROL DE ERRORES
BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr != 0 THEN
         LET vCodRet=vsqlerr;
         RETURN vCodRet;
      END IF;
    END EXCEPTION;

 --   SET DEBUG FILE TO "/tmp/sp_dep_reestrucred.out";
 --   TRACE ON;

    --SET ISOLATION TO DIRTY READ;

    --// ************************************************************************
    --// Obtiene parametros generales
    --// ************************************************************************
    --//Sucursal 
    SELECT sucursal
      INTO vt_sucursal
      FROM sc_maechq
     WHERE empresa = pempresa
       AND cuenta = pcuenta;

    --//Tipo de Moneda
    SELECT valor
      INTO vt_codigo_mn
      FROM bdinteg:si_param
     WHERE empresa = pempresa
       AND descripcion ="codigo mn";

    --//Fecha de Proceso
    SELECT fecha_hoy,ult_hab_mes
      INTO vt_fechahoy, vt_ult_hab_mes
      FROM sc_fechas
     WHERE empresa = pempresa;


    --//Valida Saldo de la Cuenta
    EXECUTE PROCEDURE cons_saldo(pcuenta)
       INTO vCodRet, vt_sdocta, vt_dummy;
    IF vCodRet = "000" AND vt_sdocta >= pmto_anticipo THEN
       --//Genera FolioLiquidacion
       SELECT CURRENT HOUR TO FRACTION(2)
         INTO vt_hora
         FROM bdinteg:dual;

       LET vt_folioliq = trim(vt_usuario)||vt_hora[1,2]||vt_hora[4,5]||vt_hora[7,8]||pcuenta[10,11];
                     
       --//Aplicar el Abono del prestamo
       EXECUTE PROCEDURE bdicheq:abono_ref(pempresa, vt_sucursal, vt_usuario,
	                                  ptransabono, vt_transuc, vt_folioliq,
	  	    		          pcuenta, 0,pmto_abono - pmto_anticipo, pmto_abono - pmto_anticipo,
	                    		  0,0,0,vt_codigo_mn, 'REESTRUCTURA CREDITO','', vt_usuario)
	           INTO vCodRet;
       --//Verifica si el abono fue exitoso 
       IF trim(vCodRet) = "000" THEN
          --//Ejecutar cargo total de la reestructura
          EXECUTE PROCEDURE cargo_ref(pempresa,vt_sucursal,vt_usuario,ptranscargo,
                                      vt_transuc,vt_folioliq,pcuenta,0,pmto_cargo,
                                      vt_codigo_mn,'REESTRUCTURA CREDITO',"",vt_usuario)
                       INTO vCodRet, vt_dummy,vt_dummy1,vt_dummy,vt_sdocta;
 
          --//Verifica si el cargo fue exitoso 
          IF trim(vCodRet) <> "000" THEN
             RETURN vCodRet;
          END IF;
       ELSE --//error en el abono
          RETURN vCodRet;
       END IF;
    ELSE --//No tiene saldo para el anticipo
       LET vCodRet = "400";
       RETURN vCodRet;
    END IF
  
    --//Fin del Proceso
    RETURN vCodRet;

END
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_buscatemporal(pTabla Char(50))

RETURNING
          CHAR (5) ,   
	  CHAR(20) ,
          INTEGER  ;


--##############################################################################
--## Procedimiento       : sp_buscatemporal
--## Version             : 1.0.0
--## Objetivo            : Valida si existe una temporal
--## Base Datos          : bicheq
--## Supuestos           :
--## Valores Entrada     : pTabla -->   Nombre de la tabla
--## Valores Retorno     : CodRet -->   Código de Retorno.
--##                       Desc   -->   Descricpion del Error
--##                       Registros->  Cantidad de Registros
--## Creado por          : Alejandro Rueda Sanchez
--## Fecha creacion      : Enero de 2007
--##############################################################################


    DEFINE cod_ret                char(5);
    DEFINE iSqlErr                integer;

    DEFINE cCodErr                CHAR(5);
    DEFINE vDesErr                VARCHAR(60);

    --Variables de retorno
    DEFINE v_registros             INTEGER;

    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cod_ret = iSqlErr;
        END IF;
        RETURN cod_ret, vDesErr, NULL;

    END EXCEPTION;



    LET cod_ret = "000";
    LET vDesErr = "";
    LET v_registros = 0;

    --// ********************************************************************
    --// Obtiene Registros de la tabla 
    --// ********************************************************************

    IF pTabla = 'temp_sc_movhis' THEN --//Conciliacion de saldos.
       SELECT  count(*) INTO v_registros  FROM temp_sc_movhis;
    END IF
    IF pTabla = 'his1' THEN --//Pase contabilidad.
       SELECT  count(*) INTO v_registros  FROM his1;
    END IF
    IF pTabla = 'temp_sconcilia' THEN --//Conciliacion ctas enlace.
       SELECT  count(*) INTO v_registros  FROM temp_sconcilia;
    END IF
 
    IF pTabla = 'tmp_concilia_chq' THEN --//Conciliacion cta contable.
       SELECT  count(*) INTO v_registros  FROM tmp_concilia_chq;
    END IF

    IF pTabla = 'tmp_rconciliacentral' THEN --//Conciliacion cta contable.
       SELECT  count(*) INTO v_registros  FROM tmp_rconciliacentral;
    END IF

    IF pTabla = 'tmp_rconciliasucursal' THEN --//Conciliacion cta contable.
       SELECT  count(*) INTO v_registros  FROM tmp_rconciliasucursal;
    END IF

    RETURN cod_ret, vDesErr, v_registros;
END PROCEDURE DOCUMENT "Version: 1.00.000";

CREATE PROCEDURE "informix".extrae_cont_det(pempresa   char(3),
                                        psecuencia smallint,
                                        pmonto_tot money(14,2),
                                        psucope_ref    char(4),
                                        pproducto  char(4),
                                        pmoneda    char(2),
                                        ptransacc  char(4),
                                        psector    char(2),
                                        pcancelad  char(1),
                                        psuccta    char(4),
                                        pdescripcion char(50),
                                        pcuenta    char(20),
                                        pfolio_suc char(16),
                                        pfecha_hoy date,
                                        pfech_hor  datetime hour to minute,
                                        pcodigo_mn char(2),
                                        ptransacc_t1 char(4),
                                        psistema   char(2),
                                        pnaturaleza char(1))
RETURNING char(5);

-- ***********************************************************************************************
-- extrae_cont_det
-- Version              1.0.0
-- Objetivo:            Genera Pre-poliza Contable1
-- Supuestos:           Ninguno
-- Creado por:
-- Modificado por:      Alejandro Rueda Sanchez
-- Ultima Modificacion: Abril - 2009
--                      Reingenieria de SPL
-- *************************************************************************************************

--//Definicion de variables
   DEFINE GLOBAL vg_secuencia INTEGER   DEFAULT 0;
   DEFINE vcodret         char(5);
   DEFINE vsqlerr         integer;
   DEFINE vp_num_cte      char(9);
   DEFINE v_tipo_cuenta   char(1);
   DEFINE vc_ccsub,vc_ccsubsub,vc_ccsssub,
          vc_ccssssub,vc_sector char(10);
   DEFINE va_ccsub,va_ccsubsub,va_ccsssub,
          va_ccssssub,va_sector char(10);
   DEFINE vc_ccmayor      char(10);
   DEFINE va_ccmayor      char(10);
   DEFINE v_auxiliar      char(9);
   DEFINE v_aux           integer;
   DEFINE vw_auxiliar     char(1);
   DEFINE v_sectoriza_cta char(1);
   DEFINE vsuctmp         char(4);
   DEFINE vt_naturaleza   char(1);
   DEFINE vt_usuario      char(8);

   LET vcodret = "000";
   LET v_auxiliar = " ";
   LET vsuctmp = "";
   LET vt_usuario = USER;
   LET vt_usuario = "chqinfor";


BEGIN

   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;

   --SET debug file to "/tmp/extrae_cont_det.out";
   --trace on;

   SELECT c_ccmayor,c_ccsub,c_ccsubsub,c_ccsssub,c_ccssssub,c_sector,
          a_ccmayor,a_ccsub,a_ccsubsub,a_ccsssub,a_ccssssub,a_sector
          INTO vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,
          vc_sector,va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,
          va_ccssssub,va_sector
     FROM bdinteg:si_prodtran
    WHERE empresa = pempresa AND producto = pproducto AND
          sistema = psistema AND transaccion = ptransacc AND
          secuencia = psecuencia;

   IF vc_ccmayor   IS NULL THEN LET vc_ccmayor   = " "; END IF
   IF vc_ccsub     IS NULL THEN LET vc_ccsub     = " "; END IF
   IF vc_ccsubsub  IS NULL THEN LET vc_ccsubsub  = " "; END IF
   IF vc_ccsssub   IS NULL THEN LET vc_ccsssub   = " "; END IF
   IF vc_ccssssub  IS NULL THEN LET vc_ccssssub  = " "; END IF

   SELECT tipo_cuenta,sectoriza_cta,auxiliar,naturaleza_cta 
     INTO v_tipo_cuenta,v_sectoriza_cta,vw_auxiliar,vt_naturaleza
     FROM bdinteg:si_catalog
    WHERE empresa    = pempresa AND ccmayor = vc_ccmayor
      AND ccsub      = vc_ccsub AND ccsubsub = vc_ccsubsub 
      AND ccssubsub  = vc_ccsssub AND ccsssubsub = vc_ccssssub  
      AND sector     = vc_sector;
   IF v_sectoriza_cta = "N" THEN  -- La cuenta NO se sectoriza
      LET vc_sector = "00";
   ELSE
      LET vc_sector = psector;
   END IF

   if ptransacc = ptransacc_t1 then
      if vc_ccmayor = "1102" then
         LET vc_sector = "21";
      end if
   end if


   IF pcancelad = "V" THEN
      LET pmoneda = pcodigo_mn;
   END IF

   --//Verifica si es una cuenta de Orden
   IF TRIM(vc_ccmayor) >= "9000" AND TRIM(vc_ccmayor) <= "9999" THEN
      LET vg_secuencia = vg_secuencia +1;
      INSERT INTO sc_contab_prep
           VALUES(vt_usuario,pfecha_hoy,pfech_hor,vg_secuencia,pempresa,
   	          vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,
                  vc_sector,psucope_ref,v_auxiliar,"D",pmoneda,psuccta,
                  pproducto,ptransacc,pmonto_tot,0,pdescripcion,
                  pcuenta, pfolio_suc,pcancelad);
   ELSE
      LET vg_secuencia = vg_secuencia +1;
      INSERT INTO sc_contab_prep
           VALUES(vt_usuario,pfecha_hoy,pfech_hor,vg_secuencia,pempresa,
   	          vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,
                  vc_sector,psuccta,v_auxiliar,"D",pmoneda,psucope_ref,
                  pproducto,ptransacc,pmonto_tot,0,pdescripcion,
                  pcuenta, pfolio_suc,pcancelad);
   END IF


   IF va_ccmayor  IS NULL THEN LET va_ccmayor   = " "; END IF
   IF va_ccsub    IS NULL THEN LET va_ccsub     = " "; END IF
   IF va_ccsubsub IS NULL THEN LET va_ccsubsub  = " "; END IF
   IF va_ccsssub  IS NULL THEN LET va_ccsssub   = " "; END IF
   IF va_ccssssub IS NULL THEN LET va_ccssssub  = " "; END IF
   IF va_sector   IS NULL THEN LET va_sector    = " "; END IF

   SELECT tipo_cuenta,sectoriza_cta,auxiliar 
     INTO v_tipo_cuenta, v_sectoriza_cta,vw_auxiliar
     FROM bdinteg:si_catalog
    WHERE empresa    = pempresa AND ccmayor = va_ccmayor
      AND ccsub      = va_ccsub AND ccsubsub = va_ccsubsub
      AND ccssubsub  = va_ccsssub AND ccsssubsub = va_ccssssub
      AND sector     = va_sector;
   IF v_sectoriza_cta = "N" THEN -- La cuenta NO se sectoriza
      LET va_sector = "00";
   ELSE
      LET va_sector = psector;   -- Se respeta el sector del cliente
   END IF

   IF ptransacc = ptransacc_t1 THEN
      IF va_ccmayor = "1102" THEN
         LET va_sector = "21";
      END IF
   END IF


   --//Verifica si es una cuenta de Orden
   IF TRIM(va_ccmayor) >= "9000" AND TRIM(va_ccmayor) <= "9999" THEN
      LET vg_secuencia = vg_secuencia +1;
      INSERT INTO sc_contab_prep
           VALUES(vt_usuario,pfecha_hoy,pfech_hor,vg_secuencia,pempresa,
   	          va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,
                  va_sector,psucope_ref,v_auxiliar,"C",pmoneda,psuccta,
                  pproducto,ptransacc,0,pmonto_tot,pdescripcion,
                  pcuenta, pfolio_suc,pcancelad);
   ELSE
      LET vg_secuencia = vg_secuencia +1;
      INSERT INTO sc_contab_prep
           values(vt_usuario,pfecha_hoy,pfech_hor,vg_secuencia,pempresa,
   	          va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,
                  va_sector,psuccta,v_auxiliar,"C",pmoneda,psucope_ref,
                  pproducto,ptransacc,0,pmonto_tot,pdescripcion,
                  pcuenta, pfolio_suc,pcancelad);
   END IF

   RETURN vcodret;

   END
END PROCEDURE;