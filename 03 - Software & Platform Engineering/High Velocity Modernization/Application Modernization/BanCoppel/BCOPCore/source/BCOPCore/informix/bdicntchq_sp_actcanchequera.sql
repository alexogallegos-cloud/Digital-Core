create procedure "informix".sp_actcanchequera( pempresa char(3),   --Empresa
                                   pcuenta  char(20),   -- Cuenta
                                   ptipo    smallint,   -- Tipo 1 Activacion, Tipo 2 Cancelacion, Tipo 3 Cancelacion cheques y chequera
                                   pconsec  integer,    -- Cosecutivo de la chequera
                                   pnumero  integer,
                                   pusuario Char(8)     --Usuario
                                   )
       returning     char(5);   -- vcodret

   -- ********************************************************************
   --
   -- Nombre:              sp_actcanchequera
   --
   -- Version              1.0.0
   -- Objetivo:            Activacion y Cancelacion de chequeras y cheques.........................
   -- Supuestos:           Ninguno
   -- Creado por:          Jorge Arango
   -- Ultima ModIF icacion: Octubre  - 2009
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vcodreterr      char(5);
   DEFINE vsqlerr         integer;
   DEFINE vconsec         integer;
   DEFINE vstatus         char(1);
   DEFINE vestado         char(1);
   define vfecha1   	  DATETIME hour TO second;
   define vhora           char(10);
   define v_hoy           date;

   LET vcodret      = " ";
   LET vsqlerr      = 0;
   LET vstatus      = " ";
   LET vestado      = " ";
   LET vconsec      = 0;
   LET vconsec      = 0;
   LET vfecha1      = current hour to second;
   LET vhora        = vfecha1; --trim(vfecha1[1,2])|":"|trim(vfecha1[4,5]);


   --SET DEBUG FILE TO "/tmp/sp_actcanchequera.out";
   --TRACE ON;

begin
    on exception set vsqlerr
       IF vsqlerr <> 0 THEN
          LET vcodret = vsqlerr;
          return vcodret;
       END IF;
    END exception;

   --- Selecciona la fecha del dia.
   SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;

   --Validaciones de nulos en parametros de entrada
   IF  pempresa = " " or pcuenta = " " or ptipo = 0 THEN
      LET vcodret = "110";
      call sp_errores( v_hoy, vhora, pcuenta, "110","sp_actcanchequera","Error en Parametros de Entrada Nulos",pusuario);
      return vcodret;
   END IF 

   IF  ptipo = 1 THEN
   
      --- Validacion de Chequeras
      SELECT status
        INTO vstatus
        FROM bdicntchq:sq_maechqra
       WHERE empresa = pempresa
         AND cuenta = pcuenta
         AND consec = pconsec;
   
      IF  vstatus <> "N" THEN
         LET vcodret = "992";
         call sp_errores( v_hoy, vhora, pcuenta, "992","sp_actcanchequera","Error en estatus de Chequera",pusuario);
         return vcodret;
      END IF 
   
      --- Validacion de Cheques
      SELECT first 1 (estado)
        INTO vestado
        FROM bdicheq:sc_contch
       WHERE empresa = pempresa
         AND cuenta = pcuenta
         AND consec = pconsec
         AND estado = "E";
   
   
      IF  (vestado is null or vestado <> "E") THEN
         LET vcodret = "993";
         call sp_errores( v_hoy, vhora, pcuenta, "993","sp_actcanchequera","Error en estatus de Cheques",pusuario);
         return vcodret;
      END IF 
   
   --- Actualizacion de Status de Chequera a Activa
           UPDATE bdicntchq:sq_maechqra
           SET status= 'A',fecha_act=today
           WHERE empresa = pempresa
           AND cuenta = pcuenta
           AND consec = pconsec
           AND status = "N";
   
   
   --- Actualizacion de Status de Cheques a Activo
           UPDATE bdicheq:sc_contch
           SET estado= 'A',fecha_alta=today
           WHERE empresa = pempresa
           AND cuenta = pcuenta
           AND consec = pconsec
           AND estado = "E";
   END IF 

   IF  ptipo = 2 THEN
   
      --- Validacion de Chequeras
       SELECT status
        INTO vstatus
        FROM bdicntchq:sq_maechqra
       WHERE empresa = pempresa
         AND cuenta = pcuenta
         AND consec = pconsec;
   
       IF  vstatus <> "A" THEN
         LET vcodret = "992";
         call sp_errores( v_hoy, vhora, pcuenta, "992","sp_actcanchequera","Error en estatus de Chequera para Cancelar",pusuario);
         return vcodret;
       END IF 
   
      --- Validacion de Cheques
       SELECT first 1 (estado)
        INTO vestado
        FROM bdicheq:sc_contch
       WHERE empresa = pempresa
         AND cuenta = pcuenta
         AND consec = pconsec
         AND estado = "A";
   
       IF  (vestado is null or vestado <> "A") THEN
         LET vcodret = "993";
         call sp_errores( v_hoy, vhora, pcuenta, "993","sp_actcanchequera","Error en estatus de Cheques para Cancelar",pusuario);
         return vcodret;
       END IF 
   
      If pnumero = 0 THEN
      
      --- Actualizacion de Status de Chequera a Activa
          UPDATE bdicntchq:sq_maechqra
          SET status= 'C'
          WHERE empresa = pempresa
            AND cuenta = pcuenta
            AND consec = pconsec
            AND status = "A";
      
      --- Actualizacion de Status de Cheques a Activo
          UPDATE bdicheq:sc_contch
          SET estado= 'C', fecha_alta=today
          WHERE empresa = pempresa
            AND cuenta = pcuenta
            AND consec = pconsec
            AND estado = "A";
      
      ELSE
      
      --- Actualizacion de Status de Cheques a Activo
          UPDATE bdicheq:sc_contch
          SET estado= 'C', fecha_alta=today
          WHERE empresa = pempresa
            AND cuenta = pcuenta
            AND consec = pconsec
            AND estado = "A"
            AND numero = pnumero;
      END IF 
   END IF 
--    LET vcodret = "000";
--    return vcodret;

   IF  ptipo = 3 THEN

      --// Actualizacion de Status de Chequera Activa-Cancelada
      UPDATE bdicntchq:sq_maechqra
         SET status= 'C'
       WHERE empresa = pempresa
         AND cuenta = pcuenta
         AND status = "A";
  
      --// Actualizacion de Status de Cheques  Activo-Cancelado
      UPDATE bdicheq:sc_contch
         SET estado= 'C', fecha_alta=today
       WHERE empresa = pempresa
         AND cuenta = pcuenta
         AND estado = "A";
  
   END IF 
   LET vcodret = "000";
   RETURN vcodret;

END
END procedure;