CREATE PROCEDURE "informix".sp_conchequesuc( pempresa  CHAR(3),
                                             psucursal CHAR(4),
                                             pfecha       DATE,
                                             pcontador INTEGER)

       RETURNING     char(5),     -- vcodret
                     char(20),    -- Numero de cuenta
                     char(10),     -- numero de cheque
                     char(10),     -- secuencia
                     decimal(14,2), -- Importe
                     char(1),     -- Cve Estatus
                     char(50);    -- Detalle de Estatus

   -- ********************************************************************
   --
   -- Nombre:              sp_conchequesuc
   --
   -- Version              1.0.0
   -- Objetivo:            Consulta de cheques operados por sucursal.......
   -- Supuestos:           Ninguno
   -- ModIFicado por:      Alejandro Rueda Sanchez
   -- Ultima Modificacion: Marzo  - 2010
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************


   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vsqlerr         integer;
   DEFINE vcuenta         char(20);
   DEFINE vstatus         char(13);
   DEFINE vdetstatus      char(50);
   DEFINE vimporte        decimal(14,2);
   DEFINE vnumero         integer;
   DEFINE vsecuencia      integer;
   DEFINE vcontador       integer;


   LET vcodret     = "000";
   LET vcuenta     = " ";
   LET vstatus     = " ";
   LET vdetstatus  = " ";
   LET vnumero     = 0;
   LET vsecuencia    = 0;
   LET vimporte = 0.00;

   --SET DEBUG FILE TO "/tmp/sp_conchequesuc.out";
   --TRACE ON;

BEGIN
   on exception set vsqlerr
      IF vsqlerr <> 0 then
         LET vcodret = vsqlerr;
         RETURN vcodret,"",0,0,"","", "";
      END IF;
   end exception;

   LET vcontador = 0;
   FOREACH
       SELECT cuenta, status,  monto, numchq, secuencia
         INTO vcuenta, vstatus, vimporte, vnumero, vsecuencia
         FROM bdicheq:sc_contch_hist
        WHERE empresa = pempresa
          AND sucursal  = psucursal
          AND fecha_alta = pfecha

       SELECT descripcion
         INTO vdetstatus
         FROM bdicntchq:sq_status_chequera
        WHERE clave = 2
          AND status = vstatus;
       LET vcontador = vcontador +1;
       IF vcontador <= pcontador THEN
          CONTINUE FOREACH;
       ELSE
         RETURN vcodret,vcuenta,vnumero,vsecuencia, vimporte,  vstatus,vdetstatus with resume;
      END IF
   END FOREACH
END
END PROCEDURE;