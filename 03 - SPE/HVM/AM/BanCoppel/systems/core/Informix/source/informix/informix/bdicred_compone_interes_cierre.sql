CREATE PROCEDURE "informix".compone_interes_cierre(o_empresa CHAR(3))

RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret             CHAR(5);
DEFINE vsqlerr              INTEGER;
DEFINE s_numcredito         VARCHAR(20);

DEFINE s_amorinteres        DECIMAL(14,2);

DEFINE sql_err              SMALLINT;
DEFINE isam_err             SMALLINT;
DEFINE error_info           CHAR(100);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;

LET s_numcredito = '';

       -- SET DEBUG FILE TO "/pisa/compone_interes_cierre.out";
       -- TRACE ON;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

    BEGIN
       ON EXCEPTION SET sql_err, isam_err, error_info
          SET DEBUG FILE TO "compone_interes_cierr.err";
       --   TRACE sql_err||" * "||isam_err||" * "||error_info;
          LET scod_ret = sql_err;
          RETURN scod_ret;
       END EXCEPTION;

       SET ISOLATION TO DIRTY READ;
       SET LOCK MODE TO WAIT 3;

           FOREACH WITH HOLD

                select a.num_credito
                into s_numcredito
                from bdicred:sd_maecred a,
                     bdicred:sd_maesdos b
                where a.empresa = o_empresa
                and a.num_credito = b.num_credito
                and status_cred in  ('BA','AA')
--                and sucursal='0002'
                and
                (
                select count(*) 
                from bdicred:sd_amortiza_credito 
                where empresa = o_empresa
                and a.num_credito = num_credito
                and capital_status = '5' 
                and interes_debe - interes_pagado > 0
                and fecha_cuota< mdy('03','20','2009')) > 0

            
                 BEGIN WORK;

                    UPDATE bdicred:sd_amortiza_credito
                    SET campo_trabajo3=interes_debe-interes_pagado,
                        campo_trabajo4=iva_debe-iva_pagado,
                        interes_pagado=0,
                        iva_pagado=0,
                        interes_debe=0,
                        iva_debe=0
                    where empresa = o_empresa 
                    and num_credito=s_numcredito
                    and capital_status = '5' 
                    and interes_debe - interes_pagado > 0
                    and fecha_cuota< mdy('03','20','2009');


--                    select SUM(interes_debe-interes_pagado)
--                    into s_amorinteres
--                    from bdicred:sd_amortiza_credito 
--                    where empresa = o_empresa 
--                    and num_credito=s_numcredito
--                    and capital_status <> '5';
                    
--                    UPDATE bdicred:sd_maesdos
--                    SET int_tra_no_exig=s_amorinteres
--                    where empresa = o_empresa 
--                    and num_credito=s_numcredito; 

                  COMMIT WORK;


           END FOREACH;

END
	RETURN scod_ret;

END PROCEDURE;