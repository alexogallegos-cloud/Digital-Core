CREATE PROCEDURE "informix".cierrechq_reg( pempresa   CHAR(3),
                                           pdias      INTEGER,
                                           pcuenta    CHAR(20),
                                           pProducto  CHAR(4),
                                           pSdoActual MONEY(14,2),
                                           pSucursal  CHAR(4) )
RETURNING CHAR(5);
    
    -- ***********************************************************************
    -- *                                                                     *
    -- * cierrechq_reg                                                       *
    -- * Version              1.0.0                                          *
    -- * Obejtivo:            Obtiene Informacion e identifica tipo de cierre*
    -- * Creado por:                                                         *
    -- * ModIFicado por:      Alejandro Rueda Sanchez                        *
    -- * Ultima Modificacion: Septiembre 2009                                *
    -- *                     Creación de SPL                                 *
    -- *                                                                     *
    -- ***********************************************************************
    
    DEFINE GLOBAL vgusuario       CHAR(8)       DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha    DATE          DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy     DATE          DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes   DATE          DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes   DATE          DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes   DATE          DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes   DATE          DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgtransisr      CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgtranprov      CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp  CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov   CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgfecha_pago    DATE          DEFAULT " ";
    DEFINE GLOBAL vgProdCreciente CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgint_acum      DECIMAL(14,2) DEFAULT 0;
    DEFINE GLOBAL vgacum_sdo_int  MONEY(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgfecha_mod     DATE          DEFAULT " ";
    DEFINE GLOBAL vgnum_cte       CHAR(20)      DEFAULT " ";
    DEFINE GLOBAL vgfecha_alta    DATE          DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta    char(1)       DEFAULT " ";
    DEFINE GLOBAL vgtranrecrece   char(4)       DEFAULT " ";
    DEFINE GLOBAL vginstrucc      CHAR(2)       DEFAULT " ";
    DEFINE GLOBAL vgcuentadep     CHAR(20)      DEFAULT " ";
    
    DEFINE vdiaspri       INTEGER;
    DEFINE vcodret        CHAR(5);
    DEFINE vcodret2       CHAR(5);
    DEFINE vcodret3       CHAR(40);
    DEFINE vsqlerr        INTEGER;
    DEFINE isam_err       INTEGER;
    DEFINE error_info     CHAR(40);
    DEFINE vfolio_suc     CHAR(16);
    DEFINE vcontador      INTEGER;
    DEFINE vsdo_total     MONEY(14,2);
    DEFINE vrenuevac      SMALLINT;
    DEFINE vaniomescre    CHAR(6);
    DEFINE vfecha         DATE;
    DEFINE vfecha_mod     DATE;
    DEFINE vfechahora     CHAR(40);
	DEFINE vfecha_operacion DATE;
    
    LET vcodret     = "000";
    LET vcodret2    = "000";
    LET vcodret3    = "000";
    LET vaniomescre = "";
    LET vrenuevac   = 0;
    LET vfechahora  = " ";
	LET vfecha_operacion = TODAY;
    
    BEGIN WORK;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "cierrechq_reg.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            LET vfechahora = CURRENT;
            ROLLBACK WORK;
            INSERT INTO sc_valcierre VALUES(pempresa, pcuenta,vcodret);
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
    IF vgfecha_hoy = vgult_hab_mes THEN
        CALL cierre_mensual(pempresa,pdias,pcuenta) 
        RETURNING vcodret;
        
        IF vcodret <> "000" THEN
            ROLLBACK WORK;
            INSERT INTO sc_valcierre values (pempresa, pcuenta,vcodret);
            RETURN vcodret;
        END IF
    ELSE
        IF vgfecha_hoy = vgpri_hab_mes THEN
            IF vgpri_dia_mes != vgpri_hab_mes THEN
                LET vdiaspri = day(vgpri_hab_mes) - 1;
                
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
                   AND b.fecha_alta < vgpri_dia_mes
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
        
        CALL cierre_diario(pempresa,pdias,pcuenta) 
        RETURNING vcodret;
        
        IF vcodret <> "000" THEN
            ROLLBACK WORK;
            INSERT INTO sc_valcierre VALUES(pempresa, pcuenta,vcodret);
            RETURN vcodret;
        END IF
    END IF
    
    SELECT count(*) 
      INTO vcontador
      FROM sc_maechq
     WHERE empresa = pempresa
       AND cuenta = pcuenta
       AND status_cta = "1"
       AND ( imp_sbg_ccc > 0 OR imp_chq_sbg > 0 OR cuenta IN(SELECT distinct mv.cuenta 
                                                               FROM sc_movdia mv
                                                              WHERE mv.empresa = pempresa 
                                                                AND mv.cuenta = pcuenta
                                                                AND mv.cancelad != "S" 
                                                                AND mv.transacc IN("3240","3241","3242","3247","3357")) );
    
    IF vcontador = 1 THEN
        CALL histsbg(pempresa,pcuenta) 
        RETURNING vcodret;
        
        IF vcodret <> "000" THEN
            ROLLBACK WORK;
            INSERT INTO sc_valcierre VALUES(pempresa, pcuenta, vcodret);
            RETURN vcodret;
        END IF
    END IF
    
    LET vrenuevac = 0;
    
    -- // ################################################## //
    -- // #  VERIFICA SI LA INVERSION CRECIENTE YA VENCIO  # //
    -- // ################################################## //
    IF pProducto = vgProdCreciente THEN
        LET vfecha_mod = vgfecha_mod;
        LET vfecha_mod = vfecha_mod - 1 UNITS DAY;
        
        EXECUTE PROCEDURE "informix".sp_valfechabil(vfecha_mod, '-') 
        INTO vcodret, vfecha_mod;
        
        IF (vfecha_mod = vgfecha_hoy) THEN
            IF vginstrucc IN('01','03') THEN
                -- // ######################################## //
                -- // # Obtiene el Saldo Actual de la Cuenta # //
                -- // ######################################## //
                SELECT sdo_actual
                  INTO vsdo_total
                  FROM sc_maechq
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                
                LET vfolio_suc = current hour TO fraction(3);
                LET vfolio_suc = vgusuario||vfolio_suc[1,2]||vfolio_suc[4,5]||vfolio_suc[7,8]||vfolio_suc[10,11];
                
                -- // ######################################################## //
                -- // # REALIZA EL MOVIMIENTO DE RENOVACION (ES REFERENCIAL) # //
                -- // ######################################################## //
                INSERT INTO sc_movdia VALUES
                ( 0, vfolio_suc, psucursal, USER, vgfecha_hoy, vgfecha_hoy, current hour TO fraction(3), 
                  vgtranrecrece, psucursal, pProducto, pempresa, pcuenta, " ", 0, vsdo_total, vsdo_total, 
                  0, 0, 0, " ", vgstatus_cta, vsdo_total, "0000", "RENOVACION DE INVERSION CRECIENTE", 0, "", "", "", vfecha_operacion);
                
                -- // ################################################# //
                -- // # Respalda la proyeccion actual en el historico # //
                -- // ################################################# //
                LET vaniomescre = YEAR(vgfecha_hoy)||LPAD(month(vgfecha_hoy),2,0);
                
                INSERT INTO sc_tasa_var_hist
                SELECT vaniomescre, a.*
                  FROM sc_tasa_variable a
                 WHERE a.empresa = pempresa
                   AND a.cuenta  = pcuenta;
                
                -- // ################################ //
                -- // # ELIMINA LA PROYECCION ACTUAL # //
                -- // ################################ //
                DELETE FROM sc_tasa_variable
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                
                -- // ################################################################ //
                -- // # REALIZA LAS ACTUALIZACIONES PARA GENERAR LA NUEVA PROYECCION # //
                -- // ################################################################ //
                UPDATE sc_maenoc
                   SET fecha_mod = NULL,
                       fecha_alta = vgprox_fecha,
                       dia_sdo_pos = 0,
                       acum_sdo_pos = 0
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                   
                UPDATE sc_maechq
                   SET imp_chq_rem = vsdo_total,
                       fec_ult_mov = vgfecha_hoy
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                
                LET vrenuevac = 1;
                
            ELIF vginstrucc IN('02','04') THEN
            
                -- // ################################################# //
                -- // # Respalda la proyeccion actual en el historico # //
                -- // ################################################# //
                LET vaniomescre = YEAR(vgfecha_hoy)||LPAD(month(vgfecha_hoy),2,0);
                
                INSERT INTO sc_tasa_var_hist
                SELECT vaniomescre, a.*
                  FROM sc_tasa_variable a
                 WHERE a.empresa = pempresa
                   AND a.cuenta  = pcuenta;
                
                -- // ################################ //
                -- // # ELIMINA LA PROYECCION ACTUAL # //
                -- // ################################ //
                DELETE FROM sc_tasa_variable
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                   
                LET vrenuevac = -1;
            END IF
        END IF
    END IF
    
    LET vcontador = dbinfo("sqlca.sqlerrd2");
    LET vcodret = "000";
    LET vfecha = vgprox_fecha;
    
    -- // ###################################################################### //
    -- // # Si es renovacion, pone la fecha_proceso a una fecha especifica.... # //
    -- // ###################################################################### //
    IF vrenuevac = 1 THEN
        LET vfecha = "01/01/1900"; 
    ELIF vrenuevac = -1 THEN
        LET vfecha = vgfecha_hoy; 
    END IF
    
    SET LOCK MODE TO WAIT 2;
    
    -- // ############################################## //
    -- // # Actualiza con la fecha como ya procesado.. # //
    -- // ############################################## //
    UPDATE sc_maechq
       SET fecha_proceso = vfecha,
           sdo_dia_ant = sdo_actual
     WHERE empresa = pempresa
       AND cuenta = pcuenta;
       
    SET LOCK MODE TO NOT WAIT;
    
    COMMIT WORK;
    
    END;
    
    RETURN vcodret;
    
END PROCEDURE;