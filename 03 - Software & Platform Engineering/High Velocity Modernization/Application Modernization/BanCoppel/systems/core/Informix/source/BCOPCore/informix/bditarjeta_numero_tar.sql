CREATE PROCEDURE "informix".numero_tar()

       RETURNING INT;

-- ======================================================== --
-- ==  Proyecto:    Tarjeta de Acceso                    == --
-- ==  Banco :      Cavendes, Venezuela                  == --
-- ==  Autor :      Grupo Pisa, S.A. de C.V.             == --
-- ==  Fecha :      20 de Octubre de 1999                == --
-- ==  Version:     1.0                                  == --
-- ==  Base de Datos: bditarjeta                         == --
-- ==  Programa :   numero_tar.sql                       == --
-- ==  Descripcion: SPL Geneacion de Numeros de Tarjeta  == --
-- ======================================================== --

 DEFINE vsucursal          CHAR(3);
 DEFINE vnumerolote        CHAR(10);
 DEFINE vnumerotarjetas    INT;
 DEFINE vfeCHAReq          DATE;
 DEFINE I                  INT;
 DEFINE key3               CHAR(2);
 DEFINE key4               CHAR(5);
 DEFINE key5               CHAR(1);
 DEFINE x                  INT;
 DEFINE vnumero_tarjeta    CHAR(16);
 DEFINE suma               SMALLINT;
 DEFINE result_multi       SMALLINT;
 DEFINE cociente           SMALLINT;
 DEFINE residuo            SMALLINT;
 DEFINE t1                 SMALLINT;
 DEFINE t2                 SMALLINT;
 DEFINE t3                 SMALLINT;
 DEFINE t4                 SMALLINT;
 DEFINE t5                 INTEGER;
 DEFINE vfecha_alta        DATE;
 DEFINE vfecha_vencimiento CHAR(4);
 DEFINE vfecha_ini_vigenci DATE;
 DEFINE vfecha_rep_tarjeta DATE;
 DEFINE vfecha_calculada   DATETIME YEAR TO MONTH;
 DEFINE anio               CHAR(4);
 DEFINE mes                CHAR(2);
 DEFINE v_nivel            INT;
 DEFINE vtipo_cta_base     CHAR(1);
 DEFINE vcod_prod_tar      CHAR(4);
 DEFINE vcod_ret           INT;

 DEFINE v_tipo_tarjeta  char(2);
 DEFINE v_limite_min    integer;
 DEFINE v_limite_max    integer;
 DEFINE v_pto_reorden   integer;
 DEFINE v_ult_tar_sol   char(16);
 DEFINE v_ult_tar_asig  char(16);
 DEFINE v_existencia_tar integer;
 DEFINE v_fec_ult_sol   date;


   ON EXCEPTION SET vcod_ret
   
      INSERT INTO bditarjeta:td_errores
      VALUES (vcod_ret, "Generacion Numeros de Tarjeta numero_tar.sql", 
              CURRENT);
      RETURN vcod_ret;
   END EXCEPTION;





   -- INICIALIZA VARIABLES
   LET vcod_ret       = 0;
   LET vcod_prod_tar =  100;  -- producto tarjeta generada
   LET vnumerotarjetas = 0;


   SELECT *
     INTO v_tipo_tarjeta  ,  v_limite_min    , v_limite_max    ,
          v_pto_reorden   ,  v_ult_tar_sol   , v_ult_tar_asig  ,
          v_existencia_tar , v_fec_ult_sol
   FROM bditarjeta:td_stock_tarjeta;

   IF  v_limite_max IS NULL  THEN
      LET v_limite_max     = 0;
   END IF;

   IF  v_existencia_tar IS NULL THEN
      LET v_existencia_tar = 0;
   END IF;

   LET vnumerotarjetas = v_limite_max   - v_existencia_tar;

   LET key3 = v_tipo_tarjeta;

   SELECT fecha_hoy INTO vfecha_alta
   FROM bdicheq:sc_fechas;

   -- #######################################################################
   -- ####     CLICLO PRINCIPAL PARA GENERAR LOS NUMEROS DE TARJETA     #####
   -- #######################################################################
   FOR I = 1 to vnumerotarjetas

       -- GENERA EL NUEVO NUMERO DE TARJETA
       -- constante    CHAR(6)  '603121' 'key1' id de cavendes
       -- reservado    CHAR(2)  '00'     'key2'
       -- tipo_tarjeta CHAR(2)  '01'     'key3' cuenta comercial (chqs)
       --                       '02'            cuenta fal (ahos)
       -- consecutivo  CHAR(5)           'key4'
       -- DV           CHAR(1)           'key5' mod 10 peso alterno (1,2 D a I)

        SELECT valor1
          INTO key4
          FROM bditarjeta:td_parametro
         WHERE clave = 'consec';

        -- DA FORMATO AL CONSECUTIVO. 0'S A LA IZQUIERDA
        FOR x = 1 to (5 - LENGTH(key4))
            LET key4 = '0' || key4;
        END FOR
        LET vnumero_tarjeta = '603121' || '00' || key3 || key4 ;

        -- CALCULA DIGITO VERIFICADOR

        LET suma = 0;
        LET result_multi = vnumero_tarjeta[1,1] * 2;
        IF result_multi >= 10 THEN
        	  LET t1 = result_multi / 10;
        	  LET t2 = t1 * 10;
        	  LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
            LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[2,2] * 1;
        IF result_multi >= 10 THEN
        	  LET t1 = result_multi / 10;
        	  LET t2 = t1 * 10;
        	  LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[3,3] * 2;
        IF result_multi >= 10 THEN
        	  LET t1 = result_multi / 10;
        	  LET t2 = t1 * 10;
        	  LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[4,4] * 1;
        IF result_multi >= 10 THEN
        	  LET t1 = result_multi / 10;
        	  LET t2 = t1 * 10;
        	  LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[5,5] * 2;
        IF result_multi >= 10 THEN
           LET t1 = result_multi / 10;
           LET t2 = t1 * 10;
           LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[6,6] * 1;
        IF result_multi >= 10 THEN
            LET t1 = result_multi / 10;
            LET t2 = t1 * 10;
            LET residuo = result_multi - t2;
            LET suma = suma + 1 + residuo;
        ELSE
            LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[7,7] * 2;
        IF result_multi >= 10 THEN
           LET t1 = result_multi / 10;
           LET t2 = t1 * 10;
           LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[8,8] * 1;
        IF result_multi >= 10 THEN
           LET t1 = result_multi / 10;
           LET t2 = t1 * 10;
           LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[9,9] * 2;
        IF result_multi >= 10 THEN
           LET t1 = result_multi / 10;
           LET t2 = t1 * 10;
           LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[10,10] * 1;
        IF result_multi >= 10 THEN
           LET t1 = result_multi / 10;
           LET t2 = t1 * 10;
           LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[11,11] * 2;
        IF result_multi >= 10 THEN
            LET t1 = result_multi / 10;
            LET t2 = t1 * 10;
            LET residuo = result_multi - t2;
            LET suma = suma + 1 + residuo;
        ELSE
            LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[12,12] * 1;
        IF result_multi >= 10 THEN
           LET t1 = result_multi / 10;
           LET t2 = t1 * 10;
           LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[13,13] * 2;
        IF result_multi >= 10 THEN
           LET t1 = result_multi / 10;
           LET t2 = t1 * 10;
           LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[14,14] * 1;
        IF result_multi >= 10 THEN
           LET t1 = result_multi / 10;
           LET t2 = t1 * 10;
           LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET result_multi = vnumero_tarjeta[15,15] * 2;
        IF result_multi >= 10 THEN
           LET t1 = result_multi / 10;
           LET t2 = t1 * 10;
           LET residuo = result_multi - t2;
           LET suma = suma + 1 + residuo;
        ELSE
           LET suma = suma + result_multi;
        END IF
        LET t1 = suma / 10;
        LET t2 = t1 * 10;
        LET t3 = suma - t2;


      -- ##################################################################
      -- RUTINA POR EL CALCULO DE LA SIGUIENTE DECENA DEL RESULTADO
      -- PARA SACAR EL DIGITO VERIFICADOR
      -- ##################################################################

      IF t3 > 0 THEN

      IF t3  < 10 THEN
         LET t5 = 10 - t3;
      ELSE
	   IF t3 < 20 THEN
              LET t5 = 20 - t3;
	   ELSE
	      IF t3 < 30 THEN
                 LET t5 = 30 - t3;
	      ELSE
	         IF t3 < 40 THEN
                    LET t5 = 40 - t3;
	         ELSE
	            IF t3 < 50 THEN
                       LET t5 = 50 - t3;
	            ELSE
	               IF t3 < 60 THEN
                          LET t5 = 60 - t3;
	               ELSE
	                  IF t3 < 70 THEN
                             LET t5 = 70 - t3;
	                  ELSE
	                     IF t3 < 80 THEN
                                LET t5 = 80 - t3;
	                     ELSE
	                        IF t3 < 90 THEN
                                   LET t5 = 90 - t3;
                                END IF
                             END IF
                          END IF
                       END IF
                    END IF
                 END IF
              END IF
	   END IF
      END IF


      LET key5 = t5;

      ELSE
         LET key5 = t3;
      END IF;

      LET vnumero_tarjeta[16,16] = key5;

      -- ##############################################################
      --                     INICIALIZA FECHAS
      -- ##############################################################
      LET vfecha_calculada = YEAR(vfecha_alta)||'-'||MONTH(vfecha_alta);
      LET vfecha_calculada = vfecha_calculada + 2 UNITS YEAR;
      LET anio             = YEAR(vfecha_calculada);
      LET mes              = MONTH(vfecha_calculada);

      IF mes < 10 THEN
         LET mes = '0'||mes;
      END IF

      LET vfecha_vencimiento = anio[3,4] || mes;
      LET vfecha_ini_vigenci = vfecha_alta;
      LET vfecha_rep_tarjeta = vfecha_calculada - 2 UNITS MONTH;

      -- CREA REGISTRO NUEVA TARJETA
      INSERT INTO bditarjeta:td_tarjeta_acceso
      VALUES( vnumero_tarjeta, "G",
              vcod_prod_tar, '10',  key3,
              "",              "",  "",
              "",              "",  NULL,
              vfecha_alta,     vfecha_vencimiento, "",
              "",            0.00,  0.00,
              0.00,          0.00,  0.00,
              0.00,            "",  "",
              "",              "",  "",
              "",              "");

      UPDATE bditarjeta:td_parametro
         SET valor1=key4+1
       WHERE clave="consec";

   END FOR;

   UPDATE bditarjeta:td_stock_tarjeta
      SET existencia_tar = existencia_tar +  vnumerotarjetas;

   RETURN vcod_ret;

END PROCEDURE;