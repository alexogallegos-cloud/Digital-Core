create procedure "informix".sp_conchequera_bpi( pempresa char(3),
                                            pcuenta  char(20),
                                            pnumcheq integer,
											iren integer	)
       returning     char(5) as  codret,     
                     char(20) as numcte,  
                     char(20) as cuenta, 
                     char(20) as reg_det,
                     date as fecha_recep,
                     char(1) as Cve_Estatus,
                     integer as chqini,   
                     integer as chqfin,  
                     integer as numcheques, 
                     char(10) as consec,  
                     char(50) as detstatus; 
					
   -- ********************************************************************
   -- Nombre:              sp_concheques_bpi
   -- Version              1.0.0
   -- Fecha:                 18/03/2010
   -- Objetivo:            Consulta de chequeras
   -- Creado por:          Manuel Osuna Valencia
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vsqlerr         integer;
   DEFINE vcuenta         char(20);
   DEFINE vnumcte         char(20);
   DEFINE vstatus         char(13);
   DEFINE vdetstatus      char(50);
   DEFINE vfec_recep      date;
   DEFINE vchqini         integer;
   DEFINE vchqfin         integer;
   DEFINE vconsec         integer;
   DEFINE vimporte        money(14,2);
   DEFINE vfecha_mov      date;
   DEFINE vnumero         integer;
   DEFINE vreg_firmas     integer;
   DEFINE vcuantos        integer;
   define iCont        integer;
   define iband        integer;
   define iTope           integer;
   define vreg_det        char(20);
   


   LET vcodret     = " ";
   LET vcuenta     = " ";
   LET vnumcte     = " ";
   LET vstatus     = " ";
   LET vdetstatus  = " ";
   LET vfec_recep  = " ";
   LET vchqini     = 0;
   LET vchqfin     = 0;
   LET vconsec     = 0;
   LET vnumero     = 0;
   LET vreg_firmas = 0;
   LET vcuantos    = 0;
   LET iCont =0;
   LET iband =0;
   LET iTope = iren + 10;
   LET vreg_det     = " ";

   --SET DEBUG FILE TO "/home/manuel/sp_conchequera.out";
   --TRACE ON;

begin
    on exception set vsqlerr
       IF vsqlerr <> 0 then
          LET vcodret = vsqlerr;
          return vcodret,vnumcte,vcuenta,vreg_firmas,vfec_recep,vstatus,vchqini,vchqfin,vcuantos,vconsec,vdetstatus;
       END IF;
    end exception;
	
	FOREACH  EXECUTE PROCEDURE bdicntchq:sp_conchequera( pempresa,pcuenta,pnumcheq)
		into vcodret,vnumcte,vcuenta,vreg_firmas,vfec_recep,vstatus,vchqini,vchqfin,vcuantos,vconsec,vdetstatus 
		
		
		IF (iCont >= iren and iCont < iTope ) THEN
			LET iband = 1;
			 SELECT descripcion INTO vreg_det FROM sq_catregimen where cve_regimen = vreg_firmas;
			 SELECT COUNT(*)
			 INTO vcuantos
			 FROM bdicheq:sc_contch
			WHERE empresa = pempresa
			  AND cuenta = pcuenta
			  AND consec = vconsec
			  AND (estado = "E"
			   OR estado = "A"
			   OR estado = "S");
			 return vcodret,vnumcte,vcuenta,vreg_det,vfec_recep,vstatus,vchqini,vchqfin,vcuantos,vconsec,vdetstatus WITH RESUME;			 
		ELIF (iCont > iTope) then			
			IF (iband == 1) THEN EXIT FOREACH ;	END IF;								
		END IF;
		LET iCont = iCont + 1;
    END FOREACH
		
	IF (iband == 0)	THEN
		return "005",0,0,0,NULL,0,NULL,NULL,0,0,0;	
	END IF;
    
end
end procedure ;