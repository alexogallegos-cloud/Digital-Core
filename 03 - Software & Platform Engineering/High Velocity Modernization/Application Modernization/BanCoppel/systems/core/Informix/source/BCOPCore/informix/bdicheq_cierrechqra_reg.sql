CREATE PROCEDURE "informix".cierrechqra_reg(pempresa   CHAR(3),
                                          pdias      INTEGER,
                                          pcuenta    CHAR(20),
                                          pProducto  CHAR(4),
                                          pSdoActual MONEY(14,2),
                                          pSucursal  CHAR(4))

    RETURNING CHAR(5);

-- ***********************************************************************
-- * cierrechqra_reg                                                     *
-- * Version              1.0.1                                          *
-- * Obejtivo:            Identifica el tipo de cierre peroducto 1900    *
-- * Creado por:                                                         *
-- * ModIFicado por:      Alejandro Rueda Sanchez                        *
-- * Ultima Modificacion: Junio 2010                                     *
-- *                     Creación de SPL                                 *
-- *                                                                     *
-- ***********************************************************************

--//DEFINICION DE VARIABLES
DEFINE GLOBAL vgrausuario       CHAR(8)   DEFAULT " ";
DEFINE GLOBAL vgraprox_fecha    DATE      DEFAULT " ";
DEFINE GLOBAL vgrafecha_hoy     DATE      DEFAULT " ";
DEFINE GLOBAL vgrapri_hab_mes   DATE      DEFAULT " ";
DEFINE GLOBAL vgrapri_dia_mes   DATE      DEFAULT " ";
DEFINE GLOBAL vgrault_hab_mes   DATE      DEFAULT " ";
DEFINE GLOBAL vgrault_dia_mes   DATE      DEFAULT " ";
DEFINE GLOBAL vgratrans_pag_int CHAR(4)   DEFAULT " ";
DEFINE GLOBAL vgratransisr      CHAR(4)   DEFAULT " ";
DEFINE GLOBAL vgratranprov      CHAR(4)   DEFAULT " ";
DEFINE GLOBAL vgratranabotrasp  CHAR(4)   DEFAULT " ";
DEFINE GLOBAL vgratranrevprov   CHAR(4)   DEFAULT " ";
DEFINE GLOBAL vgrafecha_pago    DATE      DEFAULT " ";
DEFINE GLOBAL vgraProdCreciente CHAR(4)   DEFAULT " ";
DEFINE GLOBAL vgraint_acum      DECIMAL(14,2) DEFAULT 0;
DEFINE GLOBAL vgraacum_sdo_int  MONEY(14,2)   DEFAULT 0;
DEFINE GLOBAL vgrafecha_mod     DATE      DEFAULT " ";
DEFINE GLOBAL vgranum_cte       CHAR(20)  DEFAULT " ";
DEFINE GLOBAL vgrafecha_alta    DATE      DEFAULT " ";
DEFINE GLOBAL vgrastatus_cta    char(1)   DEFAULT " ";
DEFINE GLOBAL vgratranrecrece   char(4)   DEFAULT " ";

DEFINE vstatus_cta    CHAR(1);
DEFINE vtotsuc,vcontproc,vdiaspri,vdias INTEGER;
DEFINE vcodret        CHAR(5);
DEFINE vsqlerr        INTEGER;
DEFINE vexiste        CHAR(1);
DEFINE vcierre_ejercicio smallint;
DEFINE vfecinidiv     DATETIME YEAR TO MONTH;
DEFINE vfecfindiv     DATETIME YEAR TO MONTH;
DEFINE vfolio_suc     CHAR(16);
DEFINE vcontador      INTEGER;
DEFINE vaniomes       CHAR(6);
DEFINE vBandNva       SMALLINT;
DEFINE isam_err       SMALLINT;
DEFINE error_info     CHAR(40);
DEFINE vsdo_sbc       MONEY(14,2);
DEFINE vsdo_total     MONEY(14,2);
DEFINE vcta_efectiva  CHAR(20);
DEFINE vtranret       CHAR(4);
DEFINE vrenuevac      SMALLINT;
DEFINE vsdodisp       MONEY(14,2);
DEFINE vimpcar        MONEY(14,2);
DEFINE vaniomescre    CHAR(6);
DEFINE vfecha         DATE;
DEFINE vfecha_mod     DATE;

LET vcodret     = "000";
LET vaniomescre = "";
LET vrenuevac = 0;

BEGIN WORK;

BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        --	SET DEBUG FILE TO "cierrechqra_reg.err";
        --	TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            ROLLBACK WORK;
            INSERT INTO sc_valcierreqra values (pempresa, pcuenta,vcodret);
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;

    --//Verifica si es el ultimo dia habil del mes
    IF vgrafecha_hoy = vgrault_hab_mes THEN
        CALL cierre_mensualqra(pempresa,pdias,pcuenta) 
        RETURNING vcodret;

        IF vcodret <> "000" THEN
            ROLLBACK WORK;
            INSERT INTO sc_valcierreqra values (pempresa, pcuenta,vcodret);
            RETURN vcodret;
        END IF
    ELSE
        IF vgrafecha_hoy = vgrapri_hab_mes THEN
            IF vgrapri_dia_mes != vgrapri_hab_mes THEN
                LET vdiaspri = day(vgrapri_hab_mes) - 1;

                SELECT count(*) 
                  INTO vcontador
                  FROM sc_maechq a, 
                       sc_maenoc b, 
                       sc_producto c
                 WHERE a.empresa = pempresa
                   AND a.cuenta = pcuenta
                   AND a.status_cta <> "3"
                   AND b.empresa = a.empresa
                   AND b.cuenta = a.cuenta
                   AND b.fecha_alta < vgrapri_dia_mes
                   AND c.empresa = a.empresa
                   AND c.producto = a.producto
                   AND c.pago_interes NOT IN("V","F","D");

                IF vcontador > 0 THEN
                    UPDATE sc_maenoc
                       SET (dia_sdo_pos,acum_sdo_pos) = (vdiaspri,sdo_mes_ant * vdiaspri)
                    WHERE empresa = pempresa
                      AND cuenta = pcuenta;
                END IF
            END IF
        END IF

        CALL cierre_diarioqra(pempresa,pdias,pcuenta) 
        RETURNING vcodret;

        IF vcodret <> "000" THEN
            ROLLBACK WORK;
            INSERT INTO sc_valcierreqra VALUES(pempresa, pcuenta,vcodret);
            RETURN vcodret;
        END IF
    END IF

    SELECT count(*) 
      INTO vcontador
      FROM sc_maechq
     WHERE empresa = pempresa
       AND cuenta = pcuenta
       AND status_cta = "1"
       AND (imp_sbg_ccc > 0 OR 
            imp_chq_sbg > 0 OR 
            cuenta IN(SELECT distinct mv.cuenta 
                        FROM sc_movdia mv
                       WHERE mv.empresa = pempresa 
                         AND mv.cuenta = pcuenta
                         AND mv.cancelad != "S" 
                         AND mv.transacc IN("3240","3241","3242","3247","3357")));

    IF vcontador = 1 THEN
        CALL histsbg(pempresa,pcuenta) 
        RETURNING vcodret;

        IF vcodret <> "000" THEN
            ROLLBACK WORK;
            INSERT INTO sc_valcierreqra VALUES(pempresa, pcuenta,vcodret);
            RETURN vcodret;
        END IF
    END IF

    SELECT MAX(aniomes) 
      INTO vaniomes
      FROM sc_maehis
     WHERE cuenta = pcuenta
       AND empresa = pempresa;

    IF vaniomes IS NULL THEN
        SELECT YEAR(fecha_alta) || LPAD(month(fecha_alta),2,0)
          INTO vaniomes
          FROM sc_maenoc
         WHERE empresa = pempresa
           AND cuenta = pcuenta;
    ELSE
        IF vgrafecha_pago <> vgrafecha_hoy THEN
            LET vBandNva = SUBSTR(vaniomes,5);
            IF vBandNva = 12 THEN
                LET vBandNva = 1;
                LET vaniomes = SUBSTR(vaniomes,1,4) + 1;
            ELSE
                LET vBandNva = vBandNva + 1;
            END IF
            LET vaniomes = SUBSTR(vaniomes,1,4) || LPAD(vBandNva,2,0);
        END IF
    END IF

    LET vrenuevac = 0;

       
    LET vcodret = "000";
    LET vfecha = vgraprox_fecha;
    SET LOCK MODE TO WAIT 2;
    -- // Actualiza con la fecha como ya procesado..
    UPDATE sc_maechq
       SET fecha_proceso = vfecha,
           sdo_dia_ant = sdo_actual
     WHERE empresa = pempresa
       AND cuenta = pcuenta;
       
    SET LOCK MODE TO NOT WAIT;

    LET vBandNva = 0;

    COMMIT WORK;

    END

    RETURN vcodret;

END PROCEDURE;