CREATE PROCEDURE "informix".rep_usuario_poliza(pempresa CHAR(3),
                                    pfecha_valida DATE)
  RETURNING CHAR(5),CHAR(3),CHAR(3),CHAR(4),CHAR(8),CHAR(2),
            INTEGER,MONEY(12,7),DATE,DATE,MONEY(20,2),MONEY(20,2);

  DEFINE codret             CHAR(5);
  DEFINE sql_err            INTEGER;
  DEFINE isam_err           INTEGER;
  DEFINE error_info         CHAR(40);
  DEFINE vusuario           CHAR(8);
  DEFINE vcontrol_poliza    INTEGER;
  DEFINE vfecha_captura     DATE;
  DEFINE vciudad            CHAR(3);
  DEFINE vmonto             MONEY(18,2);
  DEFINE vfecha_valida      DATE;
  DEFINE vmoneda            CHAR(2);
  DEFINE vvalor_cambio      MONEY(12,7);
  DEFINE vvalor_div_cambio  MONEY(12,7);
  DEFINE vccosto_orig       CHAR(4);
  DEFINE sumaCargos         MONEY(20,2);
  DEFINE sumaAbonos          MONEY(20,2);


      ON EXCEPTION SET sql_err,isam_err,error_info
         IF sql_err <> 0 or isam_err <> 0 THEN
            LET codret = sql_err;
            RETURN codret,"000","000","0000","0000","00",0,
                   0,NULL,NULL,0,0;
         END IF;
      END EXCEPTION;
   LET codret = "000";
   LET vciudad = "000";
   LET vccosto_orig = "0000";
   LET vusuario = "0000";
   LET vmoneda = "0";
   LET vcontrol_poliza = 0;
   LET vvalor_cambio = 0;

    FOREACH
       SELECT ciudad,ccosto_orig,usuario,moneda,control_poliza
       INTO  vciudad,vccosto_orig,vusuario,vmoneda,vcontrol_poliza
       FROM co_detpol
       WHERE empresa = pempresa
           AND fecha_valida = pfecha_valida
       GROUP BY  ciudad,ccosto_orig,usuario,moneda,control_poliza
       ORDER BY  ciudad,ccosto_orig,usuario,moneda,control_poliza

        FOREACH
          SELECT fecha_captura,valor_cambio
          INTO vfecha_captura,vvalor_cambio
          FROM co_detpol
          WHERE empresa = pempresa
             AND fecha_valida = pfecha_valida
             AND ciudad = vciudad
             AND ccosto_orig = vccosto_orig
             AND usuario = vusuario
             AND moneda = vmoneda
             AND control_poliza = vcontrol_poliza
        END FOREACH

           SELECT SUM(monto)
           INTO sumaAbonos
           FROM co_detpol
           WHERE empresa = pempresa
             AND fecha_valida = pfecha_valida
             AND ciudad = vciudad
             AND ccosto_orig = vccosto_orig
             AND usuario = vusuario
             AND moneda = vmoneda
             AND control_poliza = vcontrol_poliza
             AND naturaleza = "D";

        SELECT SUM(monto)
        INTO sumaCargos
        FROM co_detpol
        WHERE empresa = pempresa
          AND fecha_valida = pfecha_valida
          AND ciudad = vciudad
          AND ccosto_orig = vccosto_orig
          AND usuario = vusuario
          AND moneda = vmoneda
          AND control_poliza = vcontrol_poliza
          AND naturaleza = "C";


        RETURN codret,pempresa,vciudad,vccosto_orig,vusuario,vmoneda,
               vcontrol_poliza,vvalor_cambio,vfecha_captura,
               pfecha_valida,sumaCargos,sumaAbonos
       WITH RESUME;
    END FOREACH

END PROCEDURE;