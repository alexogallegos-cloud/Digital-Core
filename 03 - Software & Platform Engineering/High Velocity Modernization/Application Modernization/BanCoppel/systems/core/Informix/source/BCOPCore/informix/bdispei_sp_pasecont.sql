CREATE PROCEDURE "informix".sp_pasecont(pfecha_hoy DATE) returning CHAR(5), INTEGER;
{
  CREADO POR: Arturo Salinas
  FECHA DE CREACION: 09 de Septiembre del 2003
  FUNCIONALIDAD: Generar pase contable
  MODIFICACION: Alejandro Rueda Sanchez
                --04/dic/2007
}
   DEFINE v_codret         CHAR(5);
   DEFINE v_cargo_abono,
          v_mca_aplic      CHAR(1);
   DEFINE v_ccsub,
          v_ccsubsub,
          v_ccssubsub,
          v_ccsssubsub,
          v_sector,
          v_moneda         CHAR(2);
   DEFINE v_ciudad,
          v_empresa        CHAR(3);
   DEFINE v_sucursal       CHAR(4);
   DEFINE v_ccmayor        CHAR(4);
   DEFINE v_usuario        CHAR(20);
   DEFINE v_usuar          CHAR(8);
   DEFINE v_auxiliar       CHAR(9);

   DEFINE v_monto,
          v_valor_cambio,
          v_valor_div,
          v_capt_cargo,
          v_capt_abono,
          v_cifra_control   MONEY(14,2);
   DEFINE v_valor           MONEY(14,7);
   DEFINE v_control_poliza,
          v_secuencia       SMALLINT;
   DEFINE sql_err           INTEGER;
   DEFINE v_plaza           CHAR(3);
   DEFINE v_pendientes      SMALLINT;
   DEFINE v_fecha           CHAR(10);
   DEFINE v_cantmovs        INTEGER;
   DEFINE v_Size            SMALLINT;

   -- **************************************************************************
   -- Inicializa variables
   -- **************************************************************************
   LET v_codret       = "000";
   LET v_secuencia    =  0;
   LET v_auxiliar     = "0";
   LET v_valor_cambio =  0;
   LET v_valor_div    =  0;
   LET v_mca_aplic    = "0";
   LET v_pendientes   = "0";
   LET v_fecha        = "";
   LET v_cantmovs     =  0;
   LET v_Size         =  0;

   -- SET DEBUG FILE TO "/tmp/sp_pasecont.out";
   -- TRACE ON;

   BEGIN
      ON EXCEPTION SET sql_err
         IF sql_err <> 0 THEN
	    LET v_codret = sql_err;
--	    ROLLBACK WORK;
            RETURN v_codret,v_cantmovs;
         END IF
      END EXCEPTION;

--      BEGIN WORK;


      --Actualiza la informacion de la tabla de tblpasecont
      EXECUTE PROCEDURE sp_generaconta(pfecha_hoy) INTO v_codret;
      IF (v_codret * 1) <> 0 THEN
 --     	ROLLBACK WORK;
        RETURN v_codret,v_cantmovs;
      END IF;

     SELECT count(*) INTO v_cantmovs
        FROM tblpasecont;
 
      LET v_fecha = pfecha_hoy;
      LET v_fecha = SUBSTR(v_fecha,4,2) || SUBSTR(v_fecha,0,2) || SUBSTR(v_fecha,7,4);
      -- ***********************************************************************
      -- *** Verifica no exista ordenes STATUS L, D, A y C efectuar pase cont.
      -- ***********************************************************************
      SELECT COUNT(*) INTO v_pendientes FROM tblpago
      WHERE dtfechavalor = pfecha_hoy
      AND chrestatusenvio NOT IN ('L','E','D','A','C','I','Q');

      IF v_pendientes > 0 THEN
         LET v_codret = '051';   -- Existen Ordenes STATUS 'L','D','A','C'
  --       ROLLBACK WORK;
         RETURN v_codret,v_cantmovs;
      END IF;

      --//Extrae el Usuario a 8 posiciones
      LET v_Size = LENGTH(user);
      LET v_usuario = SUBSTR(user,v_size-7, v_size);

      --//Extrae el Nombre de la Empresa
      SELECT empresa INTO v_empresa
      FROM bdinteg:si_ejecut
      WHERE ejecutivo = v_usuario;

      -- ***********************************************************************
      -- Llama el Spl estandar para generar el pase contable
      -- ***********************************************************************
      EXECUTE PROCEDURE sp_pasecontab(v_empresa, pfecha_hoy) INTO v_codret;
      IF (v_codret * 1) <> 0 THEN
   --   	ROLLBACK WORK;
        RETURN v_codret,v_cantmovs;
      END IF;


    --  COMMIT WORK;
      RETURN v_codret,v_cantmovs;
   END
END PROCEDURE;