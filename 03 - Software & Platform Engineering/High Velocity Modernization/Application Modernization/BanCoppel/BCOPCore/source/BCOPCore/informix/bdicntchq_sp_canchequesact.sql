create procedure "informix".sp_canchequesact( pempresa char(3),   --Empresa
                                   pcuenta  char(20),   -- Cuenta
                                   pconsec  integer,    -- Cosecutivo de la chequera
                                   pusuario Char(8)     --Usuario
                                   )
 returning  char(5);     -- vcodret
   --- integer,     -- numero de cheque final
    --integer,     -- numero de cheque
   -- char(1),     -- Cve Estatus
   -- date,       -- Fecha de Movimiento
    --decimal(14,2), -- Importe
    --char(50);
      -- returning     char(5);   -- vcodret

   -- ********************************************************************
   -- Nombre:              sp_concheques_bpi
   -- Version              1.0.0
   -- Fecha:                 18/03/2010
   -- Objetivo:            Concelacion de Cheques
   -- Creado por:          Manuel Osuna Valencia
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

  --Variables de reterono del sp_concheque
  DEFINE r_vcodret    char(5);     -- vcodret
  DEFINE r_chqfinal   integer;     -- numero de cheque final
  DEFINE r_numchq     integer;     -- numero de cheque
  DEFINE r_cvestatus  char(1);     -- Cve Estatus
  DEFINE r_fechamov   date;        -- Fecha de Movimiento
  DEFINE r_importe    decimal(14,2); -- Importe
  DEFINE r_detstatus  char(50);    -- Detalle de Estatus


   LET vsqlerr      = 0;
   LET vstatus      = " ";
   LET vestado      = " ";
   LET vconsec      = 0;
   LET vconsec      = 0;
   LET vfecha1      = current hour to second;
   LET vhora        = vfecha1; --trim(vfecha1[1,2])|":"|trim(vfecha1[4,5]);
   LET vcodret = "000";

begin
    on exception set vsqlerr
       IF vsqlerr <> 0 THEN
          LET vcodret = vsqlerr;
          return vcodret;
       END IF;
    END exception;

   --- Selecciona la fecha del dia.
   SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;

    FOREACH  EXECUTE  PROCEDURE sp_concheques(pempresa,pcuenta,pconsec,'0')
	INTO r_vcodret,r_chqfinal,r_numchq,r_cvestatus,r_fechamov,r_importe,r_detstatus
		IF (trim(r_cvestatus) == "A") THEN

			EXECUTE PROCEDURE sp_actcanchequera(pempresa,pcuenta,'2',pconsec,r_numchq,pusuario)
			INTO r_vcodret;

		END IF;
		--return r_vcodret,r_chqfinal,r_numchq,r_cvestatus,r_fechamov,r_importe,r_detstatus with resume;

	END FOREACH

   RETURN vcodret;

END
END procedure;