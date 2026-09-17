CREATE PROCEDURE "informix".sp_concheques( pempresa char(3),
                                           pcuenta  char(20),
                                           pconsec  char(10),
                                           pnumcheq integer)

       returning     char(5),     -- vcodret
                     integer,     -- numero de cheque final
                     integer,     -- numero de cheque
                     char(1),     -- Cve Estatus
                     date,        -- Fecha de Movimiento
                     decimal(14,2), -- Importe
                     char(50);    -- Detalle de Estatus

   -- ********************************************************************
   --
   -- Nombre:              sp_concheques
   --
   -- Version              1.0.0
   -- Objetivo:            Consulta de cheques.........................
   -- Supuestos:           Ninguno
   -- Creado por:          Jorge Arango
   -- ModIFicado por:      Alejandro Rueda Sanchez
   -- ModIFicado por:      Mario Escobar --Lectra especifica y Secuencia por todos
   -- Ultima Modificacion: Octubre  - 2009
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
   DEFINE vimp_2          decimal(14,2);
   DEFINE vfecha_mov      date;
   DEFINE vfecha_mov2     date;   
   DEFINE vnumero         integer;
   DEFINE vcuantos        integer;
   define vultcheq        integer;


   LET vcodret     = " ";
   LET vcuenta     = " ";
   LET vstatus     = " ";
   LET vdetstatus  = " ";
   LET vfecha_mov  = " ";
   LET vfecha_mov2 = " ";
   LET vnumero     = 0;
   LET vultcheq    = 0;
   LET vcuantos    = 0;
   LET vimporte = 0.00;
   LET vimp_2   = 0.00;

   --SET DEBUG FILE TO "/tmp/sp_concheques.out";
   --TRACE ON;

BEGIN
   on exception set vsqlerr
      IF vsqlerr <> 0 then
         LET vcodret = vsqlerr;
         return vcodret,0,0,"",null,0,
         vdetstatus;
      END IF;
   end exception;

   IF pnumcheq = 0 THEN
      FOREACH
          SELECT estado, fecha_alta, importe, numero
            INTO vstatus, vfecha_mov, vimporte, vnumero
            FROM bdicheq:sc_contch
           WHERE empresa = pempresa
             AND cuenta  = pcuenta
             AND consec = pconsec
   
          EXECUTE PROCEDURE sp_ultimo_cheque(pempresa, pcuenta, pconsec, "")
                    INTO vcodret, vultcheq, vfecha_mov2, vimp_2,vcuantos;
   
          SELECT descripcion
            INTO vdetstatus
            FROM bdicntchq:sq_status_chequera
           WHERE clave = 2
             AND status = vstatus;
   
          return vcodret,vultcheq,vnumero,vstatus,vfecha_mov,vimporte,vdetstatus with resume;
      END FOREACH
   ELSE
      FOREACH
          SELECT estado, fecha_alta, importe, numero
            INTO vstatus, vfecha_mov, vimporte, vnumero
            FROM bdicheq:sc_contch
           WHERE empresa = pempresa
             AND cuenta  = pcuenta
             AND consec = pconsec
             AND numero = pnumcheq 
   
          EXECUTE PROCEDURE sp_ultimo_cheque(pempresa, pcuenta, pconsec, "")
                    INTO vcodret, vultcheq, vfecha_mov2, vimp_2,vcuantos;
   
          SELECT descripcion
            INTO vdetstatus
            FROM bdicntchq:sq_status_chequera
           WHERE clave = 2
             AND status = vstatus;
   
          return vcodret,vultcheq,vnumero,vstatus,vfecha_mov,vimporte,vdetstatus with resume;
      END FOREACH
   END IF;
END

END PROCEDURE;