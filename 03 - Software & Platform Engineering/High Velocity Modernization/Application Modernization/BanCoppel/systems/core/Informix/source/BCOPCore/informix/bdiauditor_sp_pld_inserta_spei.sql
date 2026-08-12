CREATE PROCEDURE "informix".sp_pld_inserta_spei (
                                                    sppld_insertaspei_e_opcion               INTEGER
                                                  , sppld_insertaspei_e_dtfechaproceso       CHAR    (10)
                                                  , sppld_insertaspei_e_chrproceso           CHAR    (20)
                                                  , sppld_insertaspei_e_chrproducto          CHAR    (20)
                                                  , sppld_insertaspei_e_ctl_chrstatus        CHAR    (01)
                                                  , sppld_insertaspei_e_ctl_intregprocesados INTEGER
                                                  , sppld_insertaspei_e_ctl_vchrultregcommit CHAR    (50)
                                                  , sppld_insertaspei_e_ctl_dtinicio         CHAR    (30)
                                                  , sppld_insertaspei_e_ctl_intsecuencia     INTEGER
                                                  , sppld_insertaspei_e_ctl_dtfin            CHAR    (30)
                                                  , sppld_insertaspei_e_ctl_inttransefe      INTEGER
                                                  , sppld_insertaspei_e_ctl_inttransale      INTEGER
                                                  , sppld_insertaspei_e_ctl_mnytransefe      DECIMAL (19,2)
                                                  , sppld_insertaspei_e_ctl_mnytransale      DECIMAL (19,2)
                                                  , sppld_insertaspei_e_prm_chrperiodicidad  CHAR    (01)
                                                  , sppld_insertaspei_e_prm_intdiaejec       INTEGER
                                                  , sppld_insertaspei_e_prm_intregcommit     INTEGER
                                                  , sppld_insertaspei_e_prm_chrparam         CHAR    (80)
                                                  )
       RETURNING
                                                    INTEGER        AS sppld_insertaspei_s_returncode
                                                  , CHAR    (99)   AS sppld_insertaspei_s_mensaje
                                                  , INTEGER        AS sppld_insertaspei_s_ctl_intregprocesados
                                                  , INTEGER        AS sppld_insertaspei_s_ctl_inttransefe
                                                  , INTEGER        AS sppld_insertaspei_s_ctl_inttransale
                                                  , DECIMAL (19,2) AS sppld_insertaspei_s_ctl_mnytransefe
                                                  , DECIMAL (19,2) AS sppld_insertaspei_s_ctl_mnytransale
                                                  ;


-- Declaracion de Excepciones
    define sql_err      integer;
    DEFINE sppld_insertaspei_s_returncode          INTEGER         ;
    DEFINE sppld_insertaspei_s_mensaje             CHAR    (99)    ;
    DEFINE sppld_insertaspei_s_ctl_intregprocesados INTEGER        ;
    DEFINE sppld_insertaspei_s_ctl_inttransefe      INTEGER        ;
    DEFINE sppld_insertaspei_s_ctl_inttransale      INTEGER        ;
    DEFINE sppld_insertaspei_s_ctl_mnytransefe      DECIMAL (19,2) ;
    DEFINE sppld_insertaspei_s_ctl_mnytransale      DECIMAL (19,2) ;

-- Declaracin de Variables para el cursor principal

    define c_dtfechavalor      date;    
    define c_intpkpago         integer;
    define c_cvecesifbcoord    integer;
    define c_cvecesifbcodest   integer;
    define c_vchrnombreord     char(40);
    define c_vchrcuentaord     char(20);
    define c_vchrnombrebenef   char(40);
    define c_vchrcuentabenef   char(20);
    define c_mnyimporte        decimal(19,2);
    define c_vchrconceptopago2  char(210);
    define c_intcvetipopago    integer;
    define c_chrestatusenvio   char(01);  
	define c_chrsentidopago    char(01); -- variables agregadas para detectar confirmacion CEP



-- declaracion de variables de trabajo
    define wk_num_cte    char(20);
    define wk_transacc_efectuadas integer;
    define wk_monto_total_efectuado decimal(18,2);
    define wk_periodo        char(6);
    define wk_periodo_num    integer;
    define wk_intpkpago      integer;
    define wk_dtfechavalor   char(10);
    define wk_monto_tot      decimal(19,2);
    define wk_tipo_per       char(10);
    define wk_alertado       char(10);
    define s1_num_serial integer;
    define s1_folio_suc  char(16);
    define s1_fech_alt   date;
    define s1_cuenta     char(20);
    define s1_monto_tot  decimal(18,2);
    define s1_referencia char(40);
    define s1_transacc   char(04);
    define s1_cancelad   char(01);
    define s1_usuautoriza   char(08);
    define s2_num_cte    char(20);
    define s2_sucursal   char(04);
    define s3_num_cte    char(20);
    define s4_monto_acumulado decimal(18,2);
    define s4_transaccion_total integer;
    define s5_numcte    char(20);
    define s6_monto_acumulado decimal(19,2);
-- RFV - I 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
    DEFINE wk_cuenta                     CHAR (20)               ;
-- RFV - F 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
    DEFINE wk_dtfechaproceso             DATE                    ;
    DEFINE wk_intregcommit               INTEGER                 ;
    DEFINE err_excepcion                 INTEGER                 ;
    DEFINE err_referencia                CHAR (99)               ;

-- Inicializamos el codigo de retorno con valor de OK para que en caso de que no ocurra ningun error este permanezca con el valor de OK

LET sppld_insertaspei_s_returncode   = 0   ;
LET sppld_insertaspei_s_mensaje      = "OK";

-- Validar que los parametros que necesita no vengan nulos o sin informacion (vacios segun su naturaleza)

IF sppld_insertaspei_e_opcion IS NULL THEN
   LET sppld_insertaspei_s_returncode = 1;
   LET sppld_insertaspei_s_mensaje = "Campo opcion viene nulo";
   RETURN   sppld_insertaspei_s_returncode
          , sppld_insertaspei_s_mensaje
          , 0
          , 0
          , 0
          , 0
          , 0
          ;
ELSE
   IF NOT sppld_insertaspei_e_opcion = 1 THEN
      LET sppld_insertaspei_s_returncode = 2;
      LET sppld_insertaspei_s_mensaje    = "Campo opcion valor invalido";
      RETURN   sppld_insertaspei_s_returncode
             , sppld_insertaspei_s_mensaje
             , 0
             , 0
             , 0
             , 0
             , 0
             ;
   END IF;
END IF;
IF sppld_insertaspei_e_dtfechaproceso IS NULL THEN
   LET sppld_insertaspei_s_returncode = 1;
   LET sppld_insertaspei_s_mensaje = "Campo fecha de inicio viene nulo";
   RETURN   sppld_insertaspei_s_returncode
          , sppld_insertaspei_s_mensaje
          , 0
          , 0
          , 0
          , 0
          , 0
          ;
ELSE
   IF sppld_insertaspei_e_dtfechaproceso = "" THEN
      LET sppld_insertaspei_s_returncode = 2;
      LET sppld_insertaspei_s_mensaje    = "Campo fecha de inicio tiene un valor invalido";
      RETURN   sppld_insertaspei_s_returncode
             , sppld_insertaspei_s_mensaje
             , 0
             , 0
             , 0
             , 0
             , 0
             ;
   END IF;
END IF;

-- Inicializar todos los campos que regresa segun su naturaleza para evitar una respuesta nula

LET sppld_insertaspei_s_ctl_intregprocesados = 0   ;
LET sppld_insertaspei_s_ctl_inttransefe      = 0   ;
LET sppld_insertaspei_s_ctl_inttransale      = 0   ;
LET sppld_insertaspei_s_ctl_mnytransefe      = 0   ;
LET sppld_insertaspei_s_ctl_mnytransale      = 0   ;

-- Inicializar los campos de trabajo segun su naturaleza o su valor inicial para evitar nulos

LET wk_intregcommit      = 0   ;
LET err_excepcion        = 0   ;
LET err_referencia       = " " ;

BEGIN

-- Se declara las instrucciones para las excepciones

   ON EXCEPTION SET err_excepcion
      IF err_excepcion <> 0 THEN
         IF (err_excepcion = -1204) OR (err_excepcion = -1205) OR (err_excepcion = -1206) OR (err_excepcion = -1218) THEN
            LET sppld_insertaspei_s_returncode = 3;
            LET sppld_insertaspei_s_mensaje    = "Formato invalido en fecha de operador";
            ROLLBACK WORK;
            RETURN   sppld_insertaspei_s_returncode
                   , sppld_insertaspei_s_mensaje
                   , 0
                   , 0
                   , 0
                   , 0
                   , 0
                   ;
         ELSE
            LET sppld_insertaspei_s_returncode = 99;
            LET sppld_insertaspei_s_mensaje    = "Error " || err_excepcion || " " || err_referencia;
           ROLLBACK WORK;
            RETURN   sppld_insertaspei_s_returncode
                   , sppld_insertaspei_s_mensaje
                   , 0
                   , 0
                   , 0
                   , 0
                   , 0
                   ;
         END IF;
      END IF;
   END EXCEPTION;

   BEGIN WORK;

-- Validamos que la fecha que nos envio el operador sea valida asignandola a un campo declarado como tipo fecha

      LET wk_dtfechaproceso = sppld_insertaspei_e_dtfechaproceso;

LET wk_periodo = YEAR(DATE(sppld_insertaspei_e_dtfechaproceso)) || MONTH(DATE(sppld_insertaspei_e_dtfechaproceso)); 
LET wk_periodo_num = wk_periodo;
 

LET wk_transacc_efectuadas = 0;

LET wk_intpkpago = sppld_insertaspei_e_ctl_vchrultregcommit;


LET s2_num_cte = ' ';
LET s3_num_cte = ' ';


FOREACH cur1 WITH HOLD FOR SELECT
                           {+INDEX(bdispei:tblhistpago idx_hfv)}
                             dtfechavalor                           
                           , intpkpago
                           , cvecesifbcoord
                           , cvecesifbcodest
                           , vchrnombreord
                           , vchrcuentaord
                           , vchrnombrebenef
                           , vchrcuentabenef
                           , mnyimporte
                           , vchrconceptopago2
                           , intcvetipopago
                           , chrestatusenvio
						   , chrsentidopago  --CJACO modificacion 03/07/2012  se agrego la extraccion de este campo para identificar si es recibido por partes de 3eros
                       INTO  c_dtfechavalor                           
                           , c_intpkpago
                           , c_cvecesifbcoord
                           , c_cvecesifbcodest
                           , c_vchrnombreord
                           , c_vchrcuentaord
                           , c_vchrnombrebenef
                           , c_vchrcuentabenef
                           , c_mnyimporte
                           , c_vchrconceptopago2
                           , c_intcvetipopago
                           , c_chrestatusenvio
						   , c_chrsentidopago --CJACO modificacion 03/07/2012  se agrego una variable para identificar si es recibido por parte 3eros
                   FROM bdispei:tblhistpago
                   WHERE dtfechavalor = wk_dtfechaproceso
                     AND intpkpago > wk_intpkpago
					group by 1,3,4,5,6,7,8,9,10,11,12,13,intpkpago having count(*) = 1
                   ORDER BY intpkpago ASC

LET err_referencia = "bdispei:tblhistpago " || "SELECT " || c_intpkpago ;

---CJACO Modificacion 03/07/2012  
if c_chrsentidopago = 'R' then 
	if c_chrestatusenvio = 'C' then
	 let c_chrestatusenvio ='L';
	end if;
end if;

--CJACO fin modificacion  03/07/2012 


IF (c_intcvetipopago in (1,7,5) AND (c_chrestatusenvio = "A" OR c_chrestatusenvio = "L")) THEN   
 

    IF c_vchrconceptopago2 is null THEN
       LET c_vchrconceptopago2 = " ";
    END IF;
-- RFV - I 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
-- En esta condicion procesamos cuando el banco ordenante es BanCoppel

    IF c_cvecesifbcoord = 40137 THEN
       IF SUBSTR(c_vchrcuentaord,1,3) = '137' AND SUBSTR(c_vchrcuentaord,18,1) <> ' ' THEN
          LET err_referencia = "bdicheq:sc_maechq " || "cuenta_clabe" || "SELECT " || c_vchrcuentaord ; 
-- Se comentariza este acceso por que cuenta_clabe no es indice por lo cual extraemos la cuenta de cuenta_clabe
--          SELECT   num_cte
--                 , cuenta
--            INTO   s2_num_cte
--                 , wk_cuenta
--            FROM bdicheq:sc_maechq
--           WHERE cuenta_clabe = c_vchrcuentaord;
          LET wk_cuenta = SUBSTR(c_vchrcuentaord,7,11);
          SELECT
               {+INDEX(bdicheq:sc_maechq idx_maechq1)}
                 num_cte
            INTO s2_num_cte
            FROM bdicheq:sc_maechq
           WHERE empresa = '001'
             AND cuenta = wk_cuenta;
          IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
             LET s2_num_cte = "no encontrado mod 1";
          ELSE
             LET c_vchrcuentaord = wk_cuenta;
          END IF; 
       ELSE
          IF SUBSTR(c_vchrcuentaord,1,6) = '400819' AND SUBSTR(c_vchrcuentaord,1,16) <> ' ' THEN
             LET err_referencia = "bdicheq:sc_tarjeta " || "SELECT " || c_vchrcuentaord ; 
             SELECT
                    {+INDEX(bdicheq:sc_tarjeta ix_tarjeta2)}
                      numcte
                    , cuenta
               INTO   s2_num_cte
                    , wk_cuenta
               FROM bdicheq:sc_tarjeta
              WHERE empresa = '001'
                AND num_tarjeta = c_vchrcuentaord;
             IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
                LET s2_num_cte = "no encontrado mod 2";
             ELSE
                LET c_vchrcuentaord = wk_cuenta;
             END IF; 
          ELSE
             LET err_referencia = "bdicheq:sc_maechq " || "SELECT " || c_vchrcuentaord ; 
             SELECT
                  {+INDEX(bdicheq:sc_maechq idx_maechq1)}
                    num_cte
               INTO s2_num_cte
               FROM bdicheq:sc_maechq
              WHERE empresa = '001'
                AND cuenta = c_vchrcuentaord;
             IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
                LET s2_num_cte = "no encontrado mod 3";
             END IF; 
          END IF;
       END IF;
    END IF;
-- En esta condicion procesamos cuando el banco beneficiaro es BanCoppel
    IF c_cvecesifbcodest = 40137 THEN
       IF SUBSTR(c_vchrcuentabenef,1,3) = '137' AND SUBSTR(c_vchrcuentabenef,18,1) <> ' ' THEN
          LET err_referencia = "bdicheq:sc_maechq " || "cuenta_clabe" || "SELECT " || c_vchrcuentabenef ; 
-- Se comentariza este acceso por que cuenta_clabe no es indice por lo cual extraemos la cuenta de cuenta_clabe
--          SELECT   num_cte
--                 , cuenta
--            INTO   s2_num_cte
--                 , wk_cuenta
--            FROM bdicheq:sc_maechq
--           WHERE cuenta_clabe = c_vchrcuentabenef;
          LET wk_cuenta = SUBSTR(c_vchrcuentabenef,7,11);
          SELECT
               {+INDEX(bdicheq:sc_maechq idx_maechq1)}
                 num_cte
            INTO s2_num_cte
            FROM bdicheq:sc_maechq
           WHERE empresa = '001'
             AND cuenta = wk_cuenta;
         IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
             LET s2_num_cte = "no encontrado mod 4";
         ELSE
            LET c_vchrcuentabenef = wk_cuenta;
         END IF; 
       ELSE
          IF SUBSTR(c_vchrcuentabenef,1,6) = '400819' AND SUBSTR(c_vchrcuentabenef,1,16) <> ' ' THEN
             LET err_referencia = "bdicheq:sc_tarjeta " || "SELECT " || c_vchrcuentabenef ; 
             SELECT
                    {+INDEX(bdicheq:sc_tarjeta ix_tarjeta2)}
                      numcte
                    , cuenta
               INTO   s2_num_cte
                    , wk_cuenta
               FROM bdicheq:sc_tarjeta
              WHERE empresa = '001'
                AND num_tarjeta = c_vchrcuentabenef;
             IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
                LET s2_num_cte = "no encontrado mod 5";
             ELSE
                LET c_vchrcuentabenef = wk_cuenta;
             END IF; 
          ELSE
             LET err_referencia = "bdicheq:sc_maechq " || "SELECT " || c_vchrcuentabenef ; 
             SELECT
                  {+INDEX(sc_maechq idx_maechq1)}
                    num_cte
               INTO s2_num_cte
               FROM bdicheq:sc_maechq
              WHERE empresa = '001'
                AND cuenta = c_vchrcuentabenef;
             IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
                LET s2_num_cte = "no encontrado mod 6";
             END IF; 
          END IF;
       END IF;
    END IF;
-- RFV - F 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
    LET err_referencia = "bdiauditor:tblpldtranspei " || "INSERT " || c_dtfechavalor || " " || c_intpkpago || " " || c_cvecesifbcoord || " " || c_cvecesifbcodest || " " || c_vchrnombreord || " " || c_vchrcuentaord || " " || c_vchrnombrebenef || " " || c_vchrcuentabenef || " " || c_mnyimporte || " " || c_vchrconceptopago2;
    INSERT INTO bdiauditor:tblpldtranspei
         (  dtfechavalor          
          , intpkpago
          , cvecesifbcoord
          , cvecesifbcodest
          , vchrnombreord
          , vchrcuentaord
          , vchrnombrebenef
          , vchrcuentabenef
          , mnyimporte
          , vchrconceptopago   )
          VALUES
         (  c_dtfechavalor          
          , c_intpkpago
          , c_cvecesifbcoord
          , c_cvecesifbcodest
          , nvl(c_vchrnombreord,' ')
          , nvl(c_vchrcuentaord,' ')
          , nvl(c_vchrnombrebenef,' ')
          , nvl(c_vchrcuentabenef,' ')
          , c_mnyimporte
          , c_vchrconceptopago2   )
          ;
          LET sppld_insertaspei_e_ctl_intregprocesados = sppld_insertaspei_e_ctl_intregprocesados + 1 ;
          LET wk_intregcommit = wk_intregcommit + 1 ;
          IF (dbinfo('sqlca.sqlerrd2') <> 1)  THEN
                LET sppld_insertaspei_s_returncode = 1;
                LET sppld_insertaspei_s_mensaje = "error al insertar en tblpldtranspei";
-- NOTA: Se debe de ejecutar ROLLBACK cada vez que hacemos un RETURN despues de un BEGIN WORK ya que de no
--       hacerlo se queda abierta la transaccion y cuando se reinicie el proceso madara el error de que la
--       transaccion ya esta abierta
                ROLLBACK WORK;
                RETURN   sppld_insertaspei_s_returncode
                       , sppld_insertaspei_s_mensaje
                       , 0
                       , 0
                       , 0
                       , 0
                       , 0
                       ;
          END IF;
-- RFV - I 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
-- Solo se graban en totales cuando la cuenta beneficiaria es de BanCoppel
       IF c_cvecesifbcodest = 40137 THEN
-- RFV - F 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
          IF (dbinfo('sqlca.sqlerrd2')=1)  THEN
             LET err_referencia = "bdiauditor:tblpldtotspei " || "SELECT " || c_vchrcuentabenef ;
             SELECT
                  {+INDEX(bdiauditor:tblpldtotspei indpldtotspei)}
                    monto_acumulado
                   ,transaccion_total
               INTO s4_monto_acumulado 
                   ,s4_transaccion_total
               FROM bdiauditor:tblpldtotspei
              WHERE periodo = wk_periodo_num  AND
                    cuenta = c_vchrcuentabenef;
             IF (dbinfo('sqlca.sqlerrd2')=1)  THEN
                LET err_referencia = "bdiauditor:tblpldtotspei " || "UPDATE " || c_vchrcuentabenef || " " || s4_monto_acumulado || " " || c_mnyimporte || " " || s4_transaccion_total;
                UPDATE
                     {+INDEX(bdiauditor:tblpldtotspei indpldtotspei)}
                       bdiauditor:tblpldtotspei 
                   SET monto_acumulado = s4_monto_acumulado + c_mnyimporte
                      ,transaccion_total = s4_transaccion_total + 1
                 WHERE periodo = wk_periodo_num  AND
                       cuenta = c_vchrcuentabenef;
                IF (dbinfo('sqlca.sqlerrd2')<>1) THEN
                  LET sppld_insertaspei_s_returncode = 1;
                  LET sppld_insertaspei_s_mensaje = "error al insertar en tblpldtotspai";
-- NOTA: Se debe de ejecutar ROLLBACK cada vez que hacemos un RETURN despues de un BEGIN WORK ya que de no
--       hacerlo se queda abierta la transaccion y cuando se reinicie el proceso madara el error de que la
--       transaccion ya esta abierta
                  ROLLBACK WORK;
                  RETURN   sppld_insertaspei_s_returncode
                         , sppld_insertaspei_s_mensaje
                         , 0
                         , 0
                         , 0
                         , 0
                         , 0
                         ;   
                  END IF;
             ELSE 
-- RFV - I 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
--               LET err_referencia = "bdicheq:sc_maechq " || "SELECT " || c_vchrcuentabenef ; 
--               SELECT num_cte
--                 INTO s2_num_ctE
--                 FROM bdicheq:sc_maechq
--                WHERE cuenta = c_vchrcuentabenef;
--               IF (dbinfo('sqlca.sqlerrd2')<>1)  THEN 
--                  LET s2_num_ctE = "no encontrado mod 7";
--               END IF; 
-- RFV - F 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
                  LET err_referencia = "bdiauditor:tblpldtotspei " || "INSERT " || wk_periodo_num || " " || c_vchrcuentabenef || " " || s2_num_cte || " " || c_mnyimporte || " " || "N" || " " || "1";                                  
                 if c_intcvetipopago <> 7 then
				  INSERT INTO bdiauditor:tblpldtotspei
                       (  periodo
                        , cuenta 
                        , num_cte
                        , monto_acumulado
                        , alertado
                        , transaccion_total)
                   VALUES
                        ( wk_periodo_num
                        , c_vchrcuentabenef
                        , s2_num_cte
                        , c_mnyimporte
                        , "N"
                        ,  1)
                        ;
               IF (dbinfo('sqlca.sqlerrd2')<>1) THEN
                LET sppld_insertaspei_s_returncode = 1;
                LET sppld_insertaspei_s_mensaje = "error al insertar en tblpldtotspai";
-- NOTA: Se debe de ejecutar ROLLBACK cada vez que hacemos un RETURN despues de un BEGIN WORK ya que de no
--       hacerlo se queda abierta la transaccion y cuando se reinicie el proceso madara el error de que la
--       transaccion ya esta abierta
                ROLLBACK WORK;
                RETURN   sppld_insertaspei_s_returncode
                       , sppld_insertaspei_s_mensaje
                       , 0
                       , 0
                       , 0
                       , 0
                       , 0
                       ;  
               END IF;
			   end if;
             END IF;  
          END IF;
-- RFV - I 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
       END IF;
-- RFV - F 2010/06/28 Validacion de Cuentas CLABE y Numero de tarjeta
END IF;

-- validamos si es momento de hacer COMMMIT de acuerdo a los parametros

         IF wk_intregcommit >= sppld_insertaspei_e_prm_intregcommit THEN
            LET err_referencia = "bdiauditor:tblpldcontrol " || "UPDATE CICLO " || sppld_insertaspei_e_chrproceso || " " || sppld_insertaspei_e_chrproducto ;
            UPDATE
                   {+INDEX(bdiauditor:tblpldcontrol indpldcontrol)}
                     bdiauditor:tblpldcontrol
               SET   intregprocesados = sppld_insertaspei_e_ctl_intregprocesados
-- NOTA: Aqui debemos de guardar la clave por la que esta ordenada el cursor para poder tener el punto de reinicio
                   , vchrultregcommit = c_intpkpago
-- Fin de NOTA
                   , dtfin            = CURRENT
                   , inttransefe      = sppld_insertaspei_e_ctl_inttransefe
                   , inttransale      = sppld_insertaspei_e_ctl_inttransale
                   , mnytransefe      = sppld_insertaspei_e_ctl_mnytransefe
                   , mnytransale      = sppld_insertaspei_e_ctl_mnytransale
             WHERE   chrproceso       = sppld_insertaspei_e_chrproceso
               AND   chrproducto      = sppld_insertaspei_e_chrproducto
                   ;
            COMMIT WORK;
            BEGIN WORK;
            LET wk_intregcommit = 0;
         END IF;

END FOREACH;

--Se modifica proceso para reemplazar datos con caracteres extraÃÂ±os que vengan de la bdspei. GLI 21/02/2013

		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã?Ã?%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, 'Ã?Ã?','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã?Ã?%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã?Ã?%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, 'Ã?Ã?','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã?Ã?%';
		
		end if 
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã¿%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, 'Ã¿','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã¿%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã¿%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, 'Ã¿','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã¿%';
		
		end if 
		
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%ÃÂ­%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, 'ÃÂ­','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%ÃÂ­%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%ÃÂ­%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, 'ÃÂ­','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%ÃÂ­%';
		
		end if 
		
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, 'Ã','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%Ã%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, 'Ã','Ã') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%Ã%';
		
		end if 
				
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%?%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, '?',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%?%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%?%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, '?',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%?%';
		
		end if 
		
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%#%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, '#',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%#%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%#%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, '#',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%#%';
		
		end if 
		
		-------------------
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%"%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, '"',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%"%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%"%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, '"',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%"%';
		
		end if 
		-------------------
		
				if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%/%') > 0 then
			
				UPDATE bdiauditor:tblpldtranspei SET vchrnombreord = replace(vchrnombreord, '/',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombreord LIKE '%/%';		
		
		end if 
		
		if ( select count(*) from bdiauditor:tblpldtranspei WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%/%') > 0 then
		
				UPDATE bdiauditor:tblpldtranspei  SET vchrnombrebenef = replace(vchrnombrebenef, '/',' ') WHERE dtfechavalor=wk_dtfechaproceso and vchrnombrebenef LIKE '%/%';
		
		end if 

		
-- Ejecutamos ultimo COMMIT

      IF wk_intregcommit > 0 THEN
         LET err_referencia = "bdiauditor:tblpldcontrol " || "UPDATE FINAL " || sppld_insertaspei_e_chrproceso || " " || sppld_insertaspei_e_chrproducto ;
         UPDATE
                {+INDEX(bdiauditor:tblpldcontrol indpldcontrol)} 
                  bdiauditor:tblpldcontrol
            SET   intregprocesados = sppld_insertaspei_e_ctl_intregprocesados
-- NOTA: Aqui debemos de guardar la clave por la que esta ordenada el cursor para poder tener el punto de reinicio
                , vchrultregcommit = c_intpkpago
-- Fin de NOTA
                , dtfin            = CURRENT
                , inttransefe      = sppld_insertaspei_e_ctl_inttransefe
                , inttransale      = sppld_insertaspei_e_ctl_inttransale
                , mnytransefe      = sppld_insertaspei_e_ctl_mnytransefe
                , mnytransale      = sppld_insertaspei_e_ctl_mnytransale
          WHERE   chrproceso       = sppld_insertaspei_e_chrproceso
            AND   chrproducto      = sppld_insertaspei_e_chrproducto
                ;
      END IF;
      COMMIT WORK;

END;

-- Regresamos el control con el codigo de retorno
RETURN   sppld_insertaspei_s_returncode
       , sppld_insertaspei_s_mensaje
       , sppld_insertaspei_s_ctl_intregprocesados
       , sppld_insertaspei_s_ctl_inttransefe
       , sppld_insertaspei_s_ctl_inttransale
       , sppld_insertaspei_s_ctl_mnytransefe
       , sppld_insertaspei_s_ctl_mnytransale
       ;

END PROCEDURE;