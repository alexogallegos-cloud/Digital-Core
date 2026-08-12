CREATE PROCEDURE "informix".fecha_habil(
   pfecha_cuota       DATE     ,
   pfecha_vencim      DATE     ,
   pajuste_venc_int   VARCHAR(3) )
RETURNING DATE

DEFINE respuesta INTEGER;
DEFINE V_FECHA_CUOTA DATE;

BEGIN

   LET respuesta = 0;
   LET V_FECHA_CUOTA = PFECHA_CUOTA;

   IF WEEKDAY(V_FECHA_CUOTA) = 0 THEN
      IF PAJUSTE_VENC_INT = 'S' THEN
          LET V_FECHA_CUOTA = V_FECHA_CUOTA + 1;
      ELSE
          LET V_FECHA_CUOTA = V_FECHA_CUOTA - 2;
      END IF;
   ELIF WEEKDAY(V_FECHA_CUOTA) = 6 THEN
      IF PAJUSTE_VENC_INT = 'S' THEN
--          LET V_FECHA_CUOTA = V_FECHA_CUOTA + 2;
         LET V_FECHA_CUOTA = V_FECHA_CUOTA;
      ELSE
--          LET V_FECHA_CUOTA = V_FECHA_CUOTA - 1;
          LET V_FECHA_CUOTA = V_FECHA_CUOTA;
      END IF;
   END IF;
			
   IF respuesta = 0 THEN
      SELECT COUNT(*)
      INTO   respuesta
      FROM   BDINTEG:si_feriado
      WHERE  fecha = v_fecha_cuota;
   END IF;

   IF respuesta > 0 THEN
      IF pajuste_venc_int = 'S' THEN -- AJUSTA AL DIA SIGUIENTE
         LET V_Fecha_cuota = V_fecha_cuota + 1 ;
      END IF;
      IF pajuste_venc_int = 'P' THEN -- AJUSTA AL DIA ANTERIOR
         LET V_fecha_cuota = V_fecha_cuota - 1 ;
      END IF;

      IF v_fecha_cuota >= pfecha_vencim THEN
         LET V_fecha_cuota = pfecha_vencim;
         RETURN V_FECHA_CUOTA;
      END IF;
   ELSE
      RETURN V_FECHA_CUOTA;
   END IF;

--   if pajuste_venc_int <> '3' then
--      EXECUTE PROCEDURE fecha_habil(V_fecha_cuota,pfecha_vencim,pajuste_venc_int)INTO V_FECHA_CUOTA;
--   end if;
   RETURN V_FECHA_CUOTA;

END;
END PROCEDURE;