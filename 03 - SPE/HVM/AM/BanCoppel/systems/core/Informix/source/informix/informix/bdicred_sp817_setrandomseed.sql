CREATE PROCEDURE "informix".sp817_setrandomseed(n DECIMAL(10) DEFAULT NULL)
   DEFINE GLOBAL seed DECIMAL(10) DEFAULT NULL;
   DEFINE hora integer;
   DEFINE minuto integer;
   DEFINE segundo integer;
   IF n IS NULL THEN
      let hora = current::datetime HOUR TO HOUR::char(2)::int;
      let minuto = current::datetime MINUTE TO MINUTE::char(2)::int;
      let segundo = current::datetime SECOND TO SECOND::char(2)::int;
      IF minuto>segundo THEN
         LET n = hora*minuto/(segundo+1);
      ELSE
         LET n = hora*segundo/(minuto+1);
      END IF;
   END IF;
   LET seed = n;
END PROCEDURE;