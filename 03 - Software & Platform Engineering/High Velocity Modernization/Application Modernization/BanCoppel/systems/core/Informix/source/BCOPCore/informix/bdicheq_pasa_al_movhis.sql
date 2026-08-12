CREATE PROCEDURE "informix".pasa_al_movhis(pEmpresa char(3))

RETURNING CHAR(5), integer;
-- ***********************************************************************************************
-- pasa_al_movhis
-- Version              1.0.0
-- Objetivo:            SPL de prueba
-- Supuestos:           Ninguno
-- Creado por:
-- ModIFicado por:      Alejandro Rueda Sanchez
-- Ultima Modificacion: ENERO - 2009
--                      Creación de SPL
-- *************************************************************************************************

--//Definicion de variables
   DEFINE vcodret     CHAR(5);
   DEFINE vcodret1    CHAR(5);
   DEFINE vt_cuenta   CHAR(20);
   DEFINE sql_err     INTEGER;
   DEFINE vt_cuantos  INTEGER;

   LET vcodret    = "000";

   LET vt_cuenta = 0;
   LET sql_err = 0;
   LET vt_cuantos = -1;

   BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err > 0 THEN
         LET vcodret = sql_err;
         IF vt_cuantos <> 0 THEN
            ROLLBACK WORK;
         END IF
         RETURN vcodret, 0;
      END IF;
   END EXCEPTION;


   set debug file to "./pasa_al_movhis.out";
   trace on;


   SET ISOLATION TO DIRTY READ;

   if (vt_cuantos = -1) then
       begin work;
      let vt_cuantos = 0;
   end if;


   --// **********************
   --// FOREACH PRINCIPAL
   --// **********************
   FOREACH with hold
       SELECT distinct cuenta
         INTO vt_cuenta
         FROM sc_movdia
        WHERE empresa = pEmpresa
          --AND cuenta = '10011664020'
          AND transacc in('3276', '3277', '3381')


{
        INSERT INTO sc_movhis
        SELECT '200901', a.*
          FROM sc_movdia a
         WHERE a.empresa = pempresa
           AND cuenta  = vt_cuenta
           AND transacc in('3276', '3277', '3381');
}
        DELETE FROM sc_movdia
         WHERE empresa = pempresa
           AND cuenta = vt_cuenta
           AND transacc in('3276', '3277', '3381');


      LET vt_cuantos = vt_cuantos + 1;

     if (vt_cuantos  >= 30000) then
        let vt_cuantos = 0;
        commit work;
           update statistics medium for table sc_movdia;
        begin work;
     end if;


END FOREACH

if (vt_cuantos  >= 0) then
    commit work;
    update statistics medium for table sc_movdia;
end if;

RETURN vcodret, vt_cuantos ;
END
END PROCEDURE;