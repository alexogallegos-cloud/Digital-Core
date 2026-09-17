create procedure "informix".reg_cheque_doc( pempresa   char(3),  -- Empresa
                                            pcuenta    char(20), -- Cuenta
                                            psucursal  char(4), -- Sucursal
                                            pnumcheq   integer, -- No. Cheque
                                            pcodigo    char(2), -- codigo devolucion
                                            pmonto     decimal(12,2), -- importe
                                            pfolio_suc char(16), -- folio sucursal
                                            ptransacc  char(4), -- transaccion
                                            pejecutivo char(8)    --Usuario
                                            )
RETURNING     CHAR(5);   -- vcodret

   -- ********************************************************************
   --
   -- Nombre:              reg_cheque_doc
   --
   -- Version              1.0.1
   -- Objetivo:            Registro detalle de movimientos de chequeras.........................
   -- Supuestos:           Ninguno
   -- Creado por:          Alejandro Rueda Sanchez
   -- ModIFicado por:      
   -- Ultima ModIFicacion: Junio  - 2010
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vcodreterr      char(5);
   DEFINE vsqlerr         integer;
   DEFINE vconsec         smallint;
   DEFINE vdummy          char(100);
   DEFINE vfecha_hoy   	  DATE;
   DEFINE vhora           char(15);
   DEFINE vfecha_alta 	  DATE;
   DEFINE vt_estado 	  CHAR(1);

   LET vcodret      = " ";
   LET vsqlerr      = 0;
   LET vconsec      = 0;
   LET vdummy       = " ";
   LET vt_estado    = " ";

--   SET DEBUG FILE TO "/tmp/reg_cheque_doc.out";
--   TRACE ON;

begin
    on exception set vsqlerr
       IF vsqlerr <> 0 then
          LET vcodret = vsqlerr;
          RETURN vcodret;
       END IF;
    END exception;

   --// Selecciona la fecha del dia.
   SELECT fecha_hoy 
     INTO vfecha_hoy 
     FROM bdicheq:sc_fechas;

   SELECT CURRENT HOUR TO second
     INTO vhora
     FROM bdinteg:dual;

   --//Validaciones de nulos en parametros de entrada
   IF pempresa = " " or pcuenta = " " or psucursal = " " or pnumcheq = 0 or pcodigo = " "  or pejecutivo = " " then
      LET vcodret = "110";
      RETURN vcodret;
   END IF

let pempresa = pempresa;
let pcuenta = pcuenta;
let pnumcheq = pnumcheq;

   --// Selecciona el numero maximo de cheques.
   SELECT max(secuencia)
     INTO vconsec
     FROM bdicheq:sc_contch_hist
    WHERE empresa = pempresa
      AND cuenta = pcuenta
      AND numchq = pnumcheq;

   IF vconsec IS NOT NULL THEN
      LET vconsec = vconsec + 1;
   ELSE
      LET vconsec = 1;
   END IF


   --// SI fue pagado en sucursal, regisstra el cambio del documento
   If pcodigo = "00" then
      --//Inserta el detalle
-- METER ACTUALIZACION POR SEPARADO PARA CHEQUES POR CAMARA'
    if ptransacc = '0231' then
      INSERT INTO sc_contch_hist(empresa, cuenta, numchq, secuencia, sucursal, monto, fecha_alta, hora_alta, folio_suc, transaccion, status, motivo_dev, usuario)
       VALUES(pempresa, pcuenta, pnumcheq,vconsec, psucursal, pmonto, vfecha_hoy, vhora , pfolio_suc, ptransacc, "M", "", pejecutivo);
    else
      INSERT INTO sc_contch_hist(empresa, cuenta, numchq, secuencia, sucursal, monto, fecha_alta, hora_alta, folio_suc, transaccion, status, motivo_dev, usuario)
       VALUES(pempresa, pcuenta, pnumcheq,vconsec, psucursal, pmonto, vfecha_hoy, vhora , pfolio_suc, ptransacc, "P", "", pejecutivo);

       UPDATE sc_contch SET estado = "P", fecha_alta = vfecha_hoy, importe = pmonto 
        WHERE empresa = pempresa
          AND cuenta = pcuenta
          AND numero = pnumcheq;
    end if
   ELSE --//No fue pagado
      --//Verifica el estatus actual del cheque
      SELECT estado 
        INTO vt_estado 
        FROM bdicheq:sc_contch
       WHERE empresa = pempresa
         AND cuenta = pcuenta
         AND numero = pnumcheq;
  
      IF vt_estado = "P" THEN
         LET vcodret = "600";
         RETURN vcodret;
      END IF  

      --//Inserta el detalle
     IF ptransacc in ('3314','3313','3228','0260') THEN -- PRESENTADO POR CAMARA Y DEVUELTO
      INSERT INTO sc_contch_hist(empresa, cuenta, numchq, secuencia, sucursal, monto, fecha_alta, hora_alta, folio_suc, transaccion, status, motivo_dev, usuario)
       VALUES(pempresa, pcuenta, pnumcheq, vconsec, psucursal, pmonto, vfecha_hoy, vhora , pfolio_suc, ptransacc, "N", pcodigo, pejecutivo);
     ELSE
      INSERT INTO sc_contch_hist(empresa, cuenta, numchq, secuencia, sucursal, monto, fecha_alta, hora_alta, folio_suc, transaccion, status, motivo_dev, usuario)
       VALUES(pempresa, pcuenta, pnumcheq, vconsec, psucursal, pmonto, vfecha_hoy, vhora , pfolio_suc, ptransacc, "U", pcodigo, pejecutivo);
     IF vt_estado = "A" or vt_estado = "U" THEN
       UPDATE sc_contch SET estado = "U", fecha_alta = vfecha_hoy, importe = pmonto
        WHERE empresa = pempresa
          AND cuenta = pcuenta
          AND numero = pnumcheq;
     END IF  
     END IF	 
   END IF

   LET vcodret = "000";
   RETURN vcodret;
end
END procedure;