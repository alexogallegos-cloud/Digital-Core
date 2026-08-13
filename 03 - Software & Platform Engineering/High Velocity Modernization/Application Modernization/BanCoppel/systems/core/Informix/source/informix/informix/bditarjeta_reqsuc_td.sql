CREATE PROCEDURE "informix".reqsuc_td(pempresa char(3),
                           psucursal     CHAR(3), 
                           poperador     CHAR(8),
                           pfolio        CHAR(16), 
                           ptipotarjeta  CHAR(2),
                           pnotarjeta    INTEGER)

   RETURNING CHAR(5), CHAR(10);

-- Requisicion de Tarjeta  --

   DEFINE v_codret        CHAR(5);
   DEFINE v_folio         CHAR(10);
   DEFINE v_sucursal      CHAR(3);
   DEFINE v_ejecutivo     CHAR(8);
   DEFINE v_tipotarjeta   CHAR(8);
   DEFINE v_sqlerr        SMALLINT;
   DEFINE v_consecutivo   SMALLINT;
   DEFINE v_reqsuc        SMALLINT;
   DEFINE v_fechahoy      DATE;
   DEFINE conchar         char(5);
   DEFINE tam             int;     

   LET v_codret       = "000";
   LET v_folio        = "";
   LET v_ejecutivo    = "";
   LET v_sqlerr       = 0;
   LET v_consecutivo  = 0;
   LET v_reqsuc       = 0;
   LET v_fechahoy     = "";

   BEGIN
       ON EXCEPTION SET v_sqlerr
	       IF v_sqlerr <> 0 THEN
	          LET v_codret = v_sqlerr;
             RETURN v_codret, v_folio;
          END IF;
       END EXCEPTION;

  

      -- Selecciona la fecha de hoy
      SELECT fecha_hoy INTO v_fechahoy
         FROM bdinteg:si_fechas where empresa = pempresa;

      -- Valida si los parametros recibidos no son nulos
      IF psucursal IS NULL  OR 
         psucursal = ""     OR 
         poperador IS NULL  OR
         poperador = ""     OR 
         pfolio IS NULL     OR 
         pfolio = ""        OR
         pnotarjeta IS NULL OR 
         pnotarjeta = ""    OR
         ptipotarjeta IS NULL OR
         ptipotarjeta = "" THEN

         LET v_codret = "110";    -- datos incompletos
         RETURN v_codret, v_folio;
      ELSE
         SELECT sucursal INTO v_sucursal FROM bdinteg:si_sucursales
         WHERE empresa = pempresa and sucursal = psucursal;
         IF v_sucursal IS NULL OR v_sucursal = "" THEN
            LET v_codret = "120";
            RETURN v_codret, v_folio;
         ELSE
            SELECT ejecutivo INTO v_ejecutivo FROM bdinteg:si_ejecut
            WHERE ejecutivo = poperador;
            IF v_ejecutivo IS NULL OR v_ejecutivo = "" THEN
               LET v_codret = "130";
               RETURN v_codret, v_folio;
            ELSE
               SELECT tipo_tarjeta INTO v_tipotarjeta FROM td_tipo_tarjeta
               WHERE tipo_tarjeta = ptipotarjeta;
               IF v_tipotarjeta IS NULL OR v_tipotarjeta = "" THEN
                  LET v_codret = "520";    -- tipo de tarjeta no existe
                  RETURN v_codret, v_folio;
               END IF;
            END IF;
         END IF;
      END IF;
   END
   SELECT COUNT(*) INTO v_consecutivo FROM td_req_suc
   WHERE tipo_tarjeta  = ptipotarjeta
   AND   sucursal      = v_sucursal;

   LET v_consecutivo = v_consecutivo + 1;
   LET conchar       = v_consecutivo;
   LET tam=length(conchar);
   if  tam=1   then
       let conchar="0000"||conchar; 
   end if;
   if  tam=2   then
       let conchar="000"||conchar; 
   end if;
   if  tam=3   then
       let conchar="00"||conchar; 
   end if;
   if  tam=4   then
       let conchar="0"||conchar; 
   end if;

   LET v_folio = ptipotarjeta||psucursal||conchar;

   SELECT COUNT(*) INTO v_reqsuc FROM td_req_suc
   WHERE tipo_tarjeta  = ptipotarjeta
   AND   sucursal      = psucursal;

 --  IF v_reqsuc IS NULL OR v_reqsuc = "" OR v_reqsuc =0 THEN
      INSERT INTO td_req_suc VALUES(ptipotarjeta, psucursal,
                                    v_folio,      pnotarjeta,
                                    "","",        v_fechahoy,
                                    "","S");
      LET v_codret = "000";
 --  END IF;
   RETURN v_codret, v_folio;
END PROCEDURE;