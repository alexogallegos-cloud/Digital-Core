CREATE PROCEDURE "informix".sp_concheques_bpi( pempresa char(3),
											   pcuenta  char(20),
                                               pconsec  char(10),
                                               pnumcheq integer,
											   iren integer
											   )

       returning     char(5) AS codret,     -- vcodret
                     integer AS   chqfin,  -- numero de cheque final
                     integer AS   numchq, -- numero de cheque
                     char(1) AS cvestatus,  -- Cve Estatus
                     date AS      fechamov,  -- Fecha de Movimiento
                     decimal(14,2) AS importe, -- Importe
                     char(50) AS    detstatus;


   -- ********************************************************************
   -- Nombre:              sp_concheques_bpi
   -- Version              1.0.0
   -- Fecha:                 18/03/2010
   -- Objetivo:            Consulta de cheques
   -- Creado por:          Manuel Osuna Valencia
   -- ********************************************************************


   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vsqlerr         integer;
   DEFINE vcuantos        integer;
   DEFINE vcuenta         char(20);
   DEFINE vstatus         char(13);
   DEFINE vdetstatus      char(50);
   DEFINE vimporte        decimal(14,2);
   DEFINE vimp_2          decimal(14,2);
   DEFINE vfecha_mov      date;
   DEFINE vnumero         integer;
   define vultcheq        integer;
   define iCont        integer;
   define iband        integer;
   define iTope        integer;

   LET vcodret     = "00000";
   LET vcuenta     = " ";
   LET vstatus     = " ";
   LET vdetstatus  = " ";
   LET vfecha_mov  = " ";
   LET vnumero     = 0;
   LET vultcheq    = 0;
   LET vcuantos    = 0;
   LET vimporte = 0.00;
   LET vimp_2   = 0.00;
   LET iCont =0;
   LET iband =0;
   LET iTope = iren + 10;
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

	FOREACH  EXECUTE PROCEDURE bdicntchq:sp_concheques( pempresa,pcuenta,pconsec,pnumcheq )
			into vcodret,vultcheq,vnumero,vstatus,vfecha_mov,vimporte,vdetstatus


			IF (iCont >= iren and iCont < iTope ) THEN
				LET iband = 1;
				return vcodret,vultcheq,vnumero,vstatus,vfecha_mov,vimporte,vdetstatus with resume;
		    ELIF (iCont > iTope) then
				IF (iband == 1) THEN EXIT FOREACH ;	END IF;
			END IF;
			LET iCont = iCont + 1;
			--return vcodret,vultcheq,vnumero,vstatus,vfecha_mov,vimporte,vdetstatus with resume;

    END FOREACH

	IF (iband == 0)	THEN
		return "005",0,0,null,NULL,0.0,null;
	END IF;

END

END PROCEDURE;