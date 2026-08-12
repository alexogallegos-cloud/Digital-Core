Create procedure "informix".sp_proyeccionsc(pempresa char(3),
                               psucursal char(4),
                               pusuario char(8),
                               pproducto char(4),
                               pmonto money(14,2))
RETURNING char(5),      date,        date,
          decimal(4,2), money(14,2), decimal(4,2),
          money(14,2), money(14,2), decimal(9,6);

-- ***********************************************************************************************
-- sp_proyeccionsc
-- Version              1.0.0
-- Objetivo:            Obtener la proyeccion de una cuenta de cheques tasa variable
-- Supuestos:           Ninguno
-- Creado por:
-- ModIFicado por:      Alejandro Rueda Sanchez
-- Ultima Modificacion: Enero - 2009
--                      Creación de SPL
-- *************************************************************************************************

--//Definicion de variables
DEFINE vcodret     char(5);
DEFINE vsqlerr     integer;
DEFINE vfecha_ini  date;
DEFINE vfecha_fin  date;
DEFINE vfecha_tmp1 date;
DEFINE vfecha_tmp2 date;
DEFINE vfecha_tmp  date;
DEFINE vfecha_hoy  date;
DEFINE vmes        char(2);
DEFINE vtasa       decimal(4,2);
DEFINE vmonto_int  money(14,2);
DEFINE vtasa_tot   decimal(4,2);
DEFINE vmonto_tot  money(14,2);
DEFINE i           smallint;
DEFINE vdias       smallint;
DEFINE vtipo_calc  char(1);
DEFINE vtasa_nom   char(8);
DEFINE vdia_aper   smallint;
DEFINE vdia_sig    smallint;
DEFINE vtipo_tasa  char(1);
DEFINE visr        MONEY(14,2);
DEFINE vtisr       DECIMAL(9,6);
DEFINE vferiado    date;
DEFINE vnumdias    smallint;
DEFINE vacumulado  MONEY(14,2);
DEFINE vanualisr   MONEY(14,2);

   on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
           RETURN vcodret,null,null,0,
                  0,0,0, 0, 0;
	end if
   end exception;

   SET ISOLATION TO DIRTY READ;

   --set debug file to "/tmp/sp_proyeccionsc.out";
   --trace on;

   --//Inicializacion de variables
   LET vcodret    = "000";
   LET vfecha_ini = "";
   LET vfecha_fin = "";
   LET vmes       = "";
   LET vtasa      = 0;
   LET vmonto_int = 0;
   LET vtasa_tot  = 0;
   LET vmonto_tot = pmonto;
   LET vfecha_tmp1= "";
   LET vfecha_tmp2= "";
   LET vfecha_tmp = "";
   LET vfecha_hoy = "";
   LET vdias      = 0;
   LET vtipo_calc = "";
   LET vtasa      = "";
   LET vtasa_nom  = "";
   LET vdia_aper  = 0;
   LET vdia_sig   = 0;
   LET vtipo_tasa = "";
   LET visr       = 0;
   LET vtisr      = 0;
   LET vferiado   = "";
   LET vnumdias   = 0;
   LET vacumulado = 0;
   LET vanualisr  = 0;

   IF Trim(pproducto) = "" or pmonto = 0 THEN
      LET vcodret = "110";
      RETURN vcodret,vfecha_ini,vfecha_fin,vtasa,vmonto_int,vtasa_tot,vmonto_tot,
             visr, vtisr;
   END IF

   --//Extrae las Caracteristicas del Producto
   SELECT tipo_anio_calc,tasa
     INTO vtipo_calc,vtasa_nom
     FROM sc_producto
    WHERE producto = pproducto
      AND empresa = pempresa;

   --//Obtiene la fecha del Sistema de Captacion
   SELECT pri_dia_mes, fecha_hoy , ult_dia_mes
     INTO vfecha_tmp1,vfecha_hoy , vfecha_tmp2
     FROM sc_fechas;

   LET vdia_aper = day(vfecha_hoy);

   SELECT max(fecha)
     INTO vfecha_tmp
     FROM bdinteg:si_tasa_mes;

   LET i = 1;
   LET vfecha_ini = vfecha_hoy;

   FOREACH
       SELECT mes,valor_tasa,tipo_tasa
         INTO vmes,vtasa,vtipo_tasa
         FROM bdinteg:si_tasa_mes
        WHERE fecha = vfecha_tmp
          AND tasa = vtasa_nom
        order by mes::smallint

       LET i = vmes::smallint;

       IF i = 13  THEN
          CALL sp_mes_siguiente(vfecha_hoy, i - 1  ,vdia_aper) RETURNING vcodret, vfecha_fin, vnumdias;
       ELSE
          CALL sp_mes_siguiente(vfecha_ini, 1 ,vdia_aper) RETURNING vcodret, vfecha_fin, vnumdias;
          IF vnumdias > 40 THEN
             CALL sp_mes_siguiente(vfecha_ini, 0 ,vdia_aper) RETURNING vcodret, vfecha_fin, vnumdias;
          END IF
       END IF

       LET vdias = vnumdias;
       -- Aqui esta la Modificacion del Calculo de Intereses
       LET pmonto = pmonto + vmonto_int - visr;
       -- Aqui Termina la Modificacin ALE Realizada por MEL 17 Enero 2009
       CALL calc_isr_proy(pempresa,
                          "0000000",
                           vfecha_hoy,
                           vdias,
                           vmonto_int,
                           pmonto,
                           vdias,
                           "S")
       RETURNING vcodret, visr, vtisr;



       -- Calcula los Intereses
       IF vtipo_calc = "1" THEN
          let vmonto_int = pmonto * (vtasa/100) / 360 * vdias;
       ELSE
          let vmonto_int = pmonto * (vtasa/100) / 365 * vdias;
       END IF


       -- Calcula los Intereses META
       IF vtipo_tasa = "P" THEN
          LET vfecha_ini = vfecha_hoy;
          --LET vdias = vdias -1;
          IF vtipo_calc = "1" THEN
             let vmonto_int = vmonto_tot * (vtasa/100) / 360 * vdias;
             let vtasa_tot = vtasa;
          ELSE
             let vmonto_int = vmonto_tot * (vtasa/100) / 365 * vdias;
             let vtasa_tot = vtasa;
          END  IF

          LET visr = vanualisr;
       ELSE
          -- Calcula Intereses Acumulados
          LET vacumulado = vacumulado + vmonto_int;
          LET vanualisr = vanualisr + visr;
       END IF

       RETURN vcodret,vfecha_ini,vfecha_fin,vtasa,
              vmonto_int,vtasa_tot,vmonto_tot, visr, vtisr with resume;
       LET vfecha_ini = vfecha_fin;
   END FOREACH
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".elimina_movshistduplicados( pempresa CHAR(3), pFecha DATE )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vempieza         SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vSerialDuplicado INTEGER;
    DEFINE vmin_serial      INTEGER;
    DEFINE vmax_serial      INTEGER;
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vempieza     = -1;
    LET ven_transacc = 0; 
    
    LET vSerialDuplicado = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/elimina_movshistduplicados.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/elimina_movshistduplicados.out";
    --- TRACE ON;
    
    set optimization high;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    /* #########################################################################
    SELECT {+INDEX(bdicheq:"informix".sc_movhis_old idx_movhisnew6_old)} 
           num_serial, COUNT(*) cuantos
      FROM bdicheq:"informix".sc_movhis_old
     WHERE fech_alt = pFecha
     GROUP BY 1
      INTO TEMP tmp_seriales WITH NO LOG;
    CREATE INDEX idx_tmpser ON tmp_seriales(cuantos) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_seriales;
      
    SELECT num_serial  
      FROM tmp_seriales 
     WHERE cuantos > 1
      INTO TEMP tmp_duplicados WITH NO LOG;
    CREATE INDEX idx_tmpdupl ON tmp_duplicados(num_serial) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_duplicados;
      
    SELECT {+INDEX(bdicheq:"informix".sc_movhis_old idx_movhisnew6_old)} 
           UNIQUE mov.*
      FROM bdicheq:"informix".sc_movhis_old mov,
           tmp_duplicados tmp
     WHERE mov.fech_alt = pFecha
       AND tmp.num_serial = mov.num_serial
      INTO TEMP tmp_movs WITH NO LOG;
    CREATE INDEX idx_tmpmovs ON tmp_movs(num_serial) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movs;
    ######################################################################### */

    FOREACH WITH HOLD 
        SELECT num_serial
          INTO vSerialDuplicado
          FROM seriales_duplicados
           
        IF vempieza = -1 THEN
            LET vempieza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        DELETE {+INDEX(bdicheq:"informix".sc_movhis_old idx_movhisnew6_old)} 
               bdicheq:"informix".sc_movhis_old
         WHERE fech_alt = pfecha
           AND num_serial = vSerialDuplicado;
         
        /* ############################################
        INSERT INTO bdicheq:"informix".sc_movhis_old
        SELECT *
          FROM tmp_movs
         WHERE num_serial = vSerialDuplicado;
        ############################################ */
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET vcontador2 = 0;
        LET ven_transacc = 0;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;