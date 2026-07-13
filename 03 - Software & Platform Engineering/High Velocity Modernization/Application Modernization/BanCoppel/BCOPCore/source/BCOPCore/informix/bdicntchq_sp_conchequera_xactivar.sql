CREATE PROCEDURE "informix".sp_conchequera_xactivar( pempresa char(3),
												pcuenta  char(20),
												pRegistro integer)
       returning     char(5),   -- vcodret
                     char(20),  -- Reg_firmas, tipo de regimen
                     date,      -- Fecha de Recepcion
                     integer,   -- numero de cheque inicial
                     integer,   -- numero de cheque final
                     integer,   -- numero de cheques
                     char(10),  -- consecutivo
                     char(50);  -- Detalle de Estatus

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener las chequeras con estdado de entregadas
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 23/03/2010

   DEFINE vcodret         char(5);
   DEFINE vsqlerr         integer;
   DEFINE vstatus         char(13);
   DEFINE vdetstatus      char(50);
   DEFINE vfec_recep      date;
   DEFINE vchqini         integer;
   DEFINE vchqfin         integer;
   DEFINE vconsec         integer;
   DEFINE vimporte        money(14,2);
   DEFINE vfecha_mov      date;
   DEFINE vnumero         integer;
   DEFINE vreg_firmas     char(20);
   DEFINE vcuantos        integer;


   LET vcodret     = "000";
   LET vstatus     = " ";
   LET vdetstatus  = " ";
   LET vfec_recep  = " ";
   LET vchqini     = 0;
   LET vchqfin     = 0;
   LET vconsec     = 0;
   LET vnumero     = 0;
   LET vreg_firmas = " ";
   LET vcuantos    = 0;

BEGIN
    ON EXCEPTION SET vsqlerr
       IF vsqlerr <> 0 then
			LET vcodret = vsqlerr;
			RETURN vcodret,vreg_firmas,vfec_recep,vchqini,vchqfin,vcuantos,vconsec,vdetstatus;
       END IF;
    END EXCEPTION;
	
    SELECT descripcion
    INTO vreg_firmas
    FROM bdicheq:sc_maenoc m, bdicntchq:sq_catregimen c
    WHERE m.empresa = pempresa 
	AND m.cuenta = pcuenta
	AND m.reg_firmas = c.cve_regimen;

	FOREACH
		SELECT SKIP pRegistro FIRST 10 b.fecha_rec, b.status, b.inicial, b.final, b.consec
		INTO vfec_recep,vstatus,vchqini,vchqfin, vconsec
		FROM bdicntchq:sq_maechqra b
		WHERE b.empresa = pempresa
		AND b.cuenta = pcuenta 
		AND b.status = 'N'
		ORDER BY b.consec

		IF vconsec IS NOT NULL THEN
			EXECUTE PROCEDURE sp_ultimo_cheque(pempresa, pcuenta, vconsec, "E")
				INTO vcodret, vnumero, vfecha_mov, vimporte,vcuantos;
		END IF

		SELECT descripcion
		INTO vdetstatus
		FROM bdicntchq:sq_status_chequera
		WHERE clave = 1
		AND status = vstatus;

		RETURN vcodret,vreg_firmas,vfec_recep,vchqini,vchqfin,vcuantos,vconsec,vdetstatus WITH RESUME;
	END FOREACH

	IF vconsec IS NULL OR vconsec = 0 THEN
		LET vcodret = '001';
		RETURN vcodret,vreg_firmas,vfec_recep,vchqini,vchqfin,vcuantos,vconsec,vdetstatus;	
	END IF
END
END PROCEDURE;