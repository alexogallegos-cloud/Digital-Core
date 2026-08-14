Create procedure "informix".sp_consultacheque_bpi( pempresa char(3),
                                            pcuenta  char(20),
                                            pnumcheq integer)
        returning    char(5),     -- vcodret
                     integer,     -- numero de cheque final
                     integer,     -- numero de cheque
                     char(1),     -- Cve Estatus
                     date,        -- Fecha de Movimiento
                     decimal(14,2), -- Importe
                     char(50);    -- Detalle de Estatus
					
   -- ********************************************************************
   -- Nombre:              sp_concheques_bpi
   -- Version              1.0.0
   -- Objetivo:            Consulta de chequeras.........................
   -- Creado por:          Manuel Osuna Valencia
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vsqlerr         integer;
   DEFINE vcuenta         char(20);
   DEFINE vcodret         char(5);   
   DEFINE vstatus         char(13);
   DEFINE vdetstatus      char(50);
   DEFINE vimporte        decimal(14,2);   
   DEFINE vfecha_mov      date;
   DEFINE vnumero         integer;
   DEFINE vultcheq        integer;
   DEFINE vconse          integer;
   DEFINE r_fecha         date;
   DEFINE r_monto         date;
   DEFINE vultcheq2        integer;
      

   LET vcodret     = " ";   
   LET vstatus     = " ";
   LET vdetstatus  = " ";
   LET vfecha_mov  = " ";
   LET vnumero     = 0;
   LET vultcheq    = 0;   
   LET vimporte = 0.00;
   LET vcuenta     = " ";
   LET vconse    = 0; 
   --SET DEBUG FILE TO "/home/manuel/sp_conchequera.out";
   --TRACE ON;

begin
   on exception set vsqlerr
      IF vsqlerr <> 0 then
         LET vcodret = vsqlerr;
         return vcodret,0,0,"",null,0,vdetstatus;
      END IF;
   end exception;
	
	SELECT sc.cuenta,sc.consec,sc.numero,sc.estado,trim(st.descripcion)  
	INTO vcuenta,vconse,vnumero,vstatus,vdetstatus
	from bdicheq:sc_contch sc,sq_status_chequera st
	where sc.empresa = pempresa and sc.cuenta = pcuenta and sc.numero = pnumcheq
	and st.status  = sc.estado and st.clave = '2';
		
	EXECUTE PROCEDURE sp_ultimo_cheque(pempresa, pcuenta, vconse, "") INTO vcodret,vultcheq,r_fecha,r_monto,vultcheq2;
	
	return vcodret,vultcheq,vnumero,vstatus,r_fecha,vconse::decimal(14,2),vdetstatus;
    
	
end
end procedure ;