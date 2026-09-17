CREATE PROCEDURE "informix".calc_tasaqra(pempresa CHAR(3),
                           ptasa    CHAR(8),
                           ptip_per CHAR(2),
                           pmonto   MONEY(14,2))

RETURNING CHAR(5), DECIMAL(9,6), DECIMAL(14,2);

-- ***************************************************************************
-- calc_tasaqra
-- Version              1.0.1
-- Obejtivo:            Calcula la tasa a aplicar producto 1900
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima ModIFicacion: Junio 2010
--                      Creación de SPL
-- ****************************

--//Definicion de Variables
DEFINE GLOBAL vgraTasaVar        CHAR(1)      DEFAULT "";
DEFINE GLOBAL vgracuenta         CHAR(20)     DEFAULT " ";
DEFINE GLOBAL vgrafecha_hoy      DATE         DEFAULT " ";
 
 
DEFINE valor_pond   DECIMAL(9,6);
DEFINE vcodigo      CHAR(8);
DEFINE vtasareferen CHAR(8);
DEFINE vrangofecha  CHAR(1);
DEFINE vcodret      CHAR(5);
DEFINE vfecha_rec   DATE;
DEFINE vfecha_refer DATE;
DEFINE valor_tasa   DECIMAL(9,6);
DEFINE vvalor       DECIMAL(9,6);
DEFINE porcentaje   DECIMAL(9,6);
DEFINE puntos       DECIMAL(9,6);
DEFINE vrangomin    DECIMAL(14,2);
DEFINE vrangomax    DECIMAL(14,2);
DEFINE sql_err      INTEGER;
DEFINE vfecha_hoy   DATE;
DEFINE vMtoInt      DECIMAL(14,2);

BEGIN
ON EXCEPTION SET sql_err
   IF sql_err <> 0 THEN
      LET vcodret = sql_err;
      RETURN vcodret,valor_pond, vMtoInt;
   END IF;
END EXCEPTION;

   LET vcodret    = "000";
   LET valor_pond = 0;
   LET porcentaje = 0;
   LET puntos     = 0;
   LET vMtoInt    = 0;


   -- set debug file to "/tmp/tasaqra.out";
   -- trace on;

   SET ISOLATION TO DIRTY READ;

   SELECT fecha_hoy
     INTO vfecha_hoy
     FROM sc_fechas
    WHERE empresa = pempresa;
   
   SELECT tasa, rangofecha, tasareferen
     INTO vcodigo, vrangofecha, vtasareferen
     FROM bdinteg:si_tiptasa
    WHERE empresa = pempresa
      AND tasa = ptasa;
   
   IF vcodigo IS NULL THEN
      LET vcodret = "901";
      RETURN vcodret, valor_pond, vMtoInt;
   END IF
   
   IF vgraTasaVar = "N" THEN
   
      IF vrangofecha = "F" THEN
         SELECT max(fecha) INTO vfecha_rec
           FROM bdinteg:si_fechavalor
          WHERE empresa = pempresa
     	    AND tasa = vcodigo
   	    AND fecha <= vfecha_hoy;
   
         SELECT valor INTO valor_tasa
           FROM bdinteg:si_fechavalor
          WHERE empresa = pempresa
   	    AND tasa = vcodigo
   	    AND fecha = vfecha_rec;
   
         LET valor_pond = valor_tasa;
   
      ELIF vrangofecha = "R" THEN
         SELECT max(fecha) INTO vfecha_refer
           FROM bdinteg:si_fechavalor
          WHERE empresa = pempresa
   	    AND tasa = vtasareferen;
   
         SELECT valor INTO vvalor
           FROM bdinteg:si_fechavalor
          WHERE empresa = pempresa
   	    AND tasa = vtasareferen
   	    AND fecha = vfecha_refer;
   
         IF ptip_per = "F" THEN
            SELECT rangomin, rangomax, valorperfis, sobretasafis
              INTO vrangomin, vrangomax, porcentaje, puntos
              FROM bdinteg:si_tasavlor
             WHERE empresa = pempresa
   	       AND tasa = ptasa
   	       AND rangomin <= pmonto
   	       AND rangomax >= pmonto;
         ELSE
            SELECT rangomin, rangomax, valorpermor, sobretasamor
              INTO vrangomin, vrangomax, porcentaje, puntos
              FROM bdinteg:si_tasavlor
             WHERE empresa = pempresa
   	       AND tasa = ptasa
   	       AND rangomin <= pmonto
   	       AND rangomax >= pmonto;
         END IF
         LET valor_pond = porcentaje + puntos;
      END IF
   
      IF valor_pond IS NULL THEN
         LET valor_pond = 0;
      END IF
   ELSE
      LET vgracuenta = vgracuenta;
      --//Busca el valor de la tasa, tomando como periodo base la fecha inicio de proceso
      SELECT NVL(a.valor_tasa,0), int_acum 
        INTO valor_pond, vMtoInt
        FROM sc_tasa_variable a
       WHERE empresa = pempresa
         AND cuenta = vgracuenta
         AND vgrafecha_hoy between inicio_periodo AND fin_periodo -1
         AND tipo_tasa = "M";

      --//Si no existe el valor de la tasa, se incluye la fecha final de ultimo periodo
      IF valor_pond is null or valor_pond = 0 THEN
         SELECT NVL(a.valor_tasa,0), int_acum 
           INTO valor_pond, vMtoInt
           FROM sc_tasa_variable a
          WHERE empresa = pempresa
            AND cuenta = vgracuenta
            AND vgrafecha_hoy between inicio_periodo AND fin_periodo
            AND tipo_tasa = "M";
      END IF

      IF valor_pond is null THEN
         LET valor_pond = 0;
      END IF      
   
   END IF

   RETURN vcodret, valor_pond, vMtoInt;
END
END PROCEDURE;