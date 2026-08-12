CREATE PROCEDURE "informix".cons_refbancarias(p_numcte        CHAR(20),
                                              renglon         INTEGER)
 RETURNING INTEGER, CHAR(4), CHAR(3), CHAR(20), CHAR(20), CHAR(20),
             CHAR(5), CHAR(60);

-- **************************************************************************
--  variables
-- **************************************************************************
DEFINE cod_ret                       CHAR(5);
DEFINE sql_err                       INTEGER;
DEFINE isam_err                      INTEGER;
DEFINE error_info                    CHAR(40);
DEFINE vsec_refbancarias             INTEGER;
DEFINE vbanco                        CHAR(4);
DEFINE vtp_cta                       CHAR(3);
DEFINE vno_cta                       CHAR(20);
DEFINE vnombre_plaza                 CHAR(20);
DEFINE vnombre_sucursal              CHAR(20);
DEFINE codret                        CHAR(20);
DEFINE p_mensaje                     CHAR(60);
DEFINE existe                        INTEGER;
DEFINE vnumcte                       CHAR(20);

ON EXCEPTION SET sql_err, isam_err, error_info
   LET cod_ret = sql_err;
   SET DEBUG FILE TO "cons_refbancarias.err";
   TRACE sql_err||" * "||isam_err|| " * "||error_info;
   ROLLBACK WORK;
   RETURN vsec_refbancarias, vbanco, vtp_cta, vno_cta, vnombre_plaza, vnombre_sucursal,
          cod_ret, p_mensaje with resume;
END EXCEPTION;


-- **************************************************************************
-- verifica parametros de entrada
-- **************************************************************************
LET cod_ret                        = "000";
LET sql_err                        = 0;
LET isam_err                       = 0;
LET error_info                     = " ";
LET vsec_refbancarias              = " ";
LET vbanco                         = " ";
LET vtp_cta                        = " ";
LET vno_cta                        = " ";
LET vnombre_plaza                  = " ";
LET vnombre_sucursal               = " ";
LET codret                         = " ";
LET p_mensaje                      = " ";
LET existe                         = 0;
LET vnumcte                        = " ";

 SET ISOLATION TO DIRTY READ;
 SELECT longitud_cte INTO existe FROM bdinteg:si_param;

 while length(p_numcte) < existe
   let p_numcte = "0"||p_numcte;
 end while;

 let existe = 0;

    FOREACH

         SELECT sec_refban,banco,tp_cta,no_cta,nombre_plaza,nombre_sucursal
         INTO vsec_refbancarias,vbanco,vtp_cta,vno_cta,vnombre_plaza,vnombre_sucursal
         FROM bdinteg:si_refbancarias
         WHERE bdinteg:si_refbancarias.numcte = p_numcte
         ORDER BY 1

         let existe = existe + 1;
         IF renglon > existe THEN
            CONTINUE FOREACH;
         END IF;

         IF vsec_refbancarias IS NULL THEN
            LET vsec_refbancarias = 0;
         END if;

         IF vbanco IS NULL THEN
            LET vbanco = ' ';
         END if;

         IF vtp_cta IS NULL THEN
            LET vtp_cta = ' ';
         END if;

         IF vno_cta IS NULL THEN
            LET vno_cta = ' ';
         END if;

         IF vnombre_sucursal IS NULL THEN
            LET vnombre_sucursal = ' ';
         END if;

         IF vnombre_plaza IS null THEN
            LET vnombre_plaza = ' ';
         END if;



       RETURN vsec_refbancarias, vbanco, vtp_cta, vno_cta, vnombre_plaza, vnombre_sucursal,
              cod_ret, p_mensaje with resume;


    END FOREACH;
END PROCEDURE
