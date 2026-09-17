create procedure "informix".sc_consdatosctacentral( pempresa char(3), pnumcta char(20) )
returning char(5), char(4), char(4), char(20), char(1), char(2), date, char(8), char(2), char(1), 
          char(2), char(2), char(2), char(2), char(2), char(2), char(2), char(18), integer, integer;

    -- // Definicion de Variables
    define chrcodret			char(5);
    define chrcodret2			char(5);
    define chrcodret3			char(50);
    define intcodret			integer;
    define intisamerr           integer;
    define chrdescerr		    char(50);
    
    define chrsucursal		    char(4);
    define chrproducto		    char(4);
    define chrnumcte			char(20);
    define chrenviodirecc		char(1);
    define chrnumcot			char(2);
    define dtefecultmov		    date;
    define chrejecutivo		    char(8);
    define chrdireccenvio		char(2);
    define chrregfirmas		    char(1);
    define chrprocedaperacta	char(2);
    define chrprocedmantcta		char(2);
    define chrmontomensual		char(2);
    define chrdepositoscant		char(2);
    define chrdepositosmonto	char(2);
    define chrretiroscant		char(2);
    define chrretirosmonto		char(2);
    define chrcuentaclabe		char(18);
    define intempresa			integer;
    define intnomina			integer;
    
    -- // Inicializa variables
    let chrcodret			= "000";
    let chrcodret2			= "";
    let chrcodret3			= "";
    let intcodret			= 0;
    let intisamerr			= 0;
    let chrdescerr			= 0;
    
    let chrsucursal			= "";
    let chrproducto			= "";
    let chrnumcte			= "";
    let chrenviodirecc		= "";
    let chrnumcot			= "";
    let dtefecultmov        = "";
    let chrejecutivo		= "";
    let chrdireccenvio		= "";
    let chrregfirmas		= "";
    let chrprocedaperacta	= "";
    let chrprocedmantcta	= "";
    let chrmontomensual		= "";
    let chrdepositoscant	= "";
    let chrdepositosmonto	= "";
    let chrretiroscant		= "";
    let chrretirosmonto		= "";
    let chrcuentaclabe		= "";
    let intempresa			= 0;
    let intnomina			= 0;

    --- debug flag
    --- set debug file to "/tmp/sc_consdatosctacentral.out";
    --- trace on;

    begin

    on exception set intcodret, intisamerr, chrdescerr
        set debug file to "/tmp/sc_consdatosctacentral.err";
        trace on;
        if intcodret <> 0 then
            let chrcodret  = intcodret;
            let chrcodret2 = intisamerr;
            let chrcodret3 = chrdescerr;
            return chrcodret, chrsucursal, chrproducto, chrnumcte, chrenviodirecc, chrnumcot, dtefecultmov, 
                   chrejecutivo, chrdireccenvio, chrregfirmas, chrprocedaperacta, chrprocedmantcta, chrmontomensual, 
                   chrdepositoscant, chrdepositosmonto, chrretiroscant, chrretirosmonto, chrcuentaclabe, intempresa, intnomina;
        end if;
    end exception;
    
    if ( pempresa is null or pempresa = '' ) or
       ( pnumcta is null or pnumcta = '' ) then
       let chrcodret  = '110';
       return chrcodret, chrsucursal, chrproducto, chrnumcte, chrenviodirecc, chrnumcot, dtefecultmov, 
                   chrejecutivo, chrdireccenvio, chrregfirmas, chrprocedaperacta, chrprocedmantcta, chrmontomensual, 
                   chrdepositoscant, chrdepositosmonto, chrretiroscant, chrretirosmonto, chrcuentaclabe, intempresa, intnomina;
    end if;

    set isolation to dirty read;
    set lock mode to wait 3;

    select nvl(chq.sucursal, "0000"), 
           nvl(chq.producto, "0000"), 
           nvl(chq.num_cte, " "), 
           nvl(noc.envio_direcc, " "),
           nvl(noc.num_cot, " "),
           nvl(chq.fec_ult_mov, "1900-01-01"),
           nvl(noc.ejecutivo, " "),
           nvl(chq.direcc_envio, 0),
           nvl(noc.reg_firmas, " "),
           nvl(chq.proced_aperturacta, " "),
           nvl(chq.proced_mantenercta, " "),
           nvl(chq.monto_mensual, " "),
           nvl(chq.depositos_cantidad, " "),
           nvl(chq.depositos_monto, " "),
           nvl(chq.retiros_cantidad, " "),
           nvl(chq.retiros_monto, " "),
           nvl(chq.cuenta_clabe, " ")
      into chrsucursal, chrproducto, chrnumcte, chrenviodirecc, chrnumcot, dtefecultmov,
           chrejecutivo, chrdireccenvio, chrregfirmas, chrprocedaperacta, chrprocedmantcta, chrmontomensual,
           chrdepositoscant, chrdepositosmonto, chrretiroscant, chrretirosmonto, chrcuentaclabe
      from bdicheq:sc_maechq chq, 
           bdicheq:sc_maenoc noc
     where chq.cuenta = noc.cuenta 
       and chq.empresa = noc.empresa 
       and chq.empresa = pempresa 
       and chq.cuenta = pnumcta;

    -- // Extrae los datos de Empresa y No. de Nomina para Consulta
    if chrnumcte != "" or chrnumcte != " " or chrnumcte is not null then
        select nvl(numeric1, 0),
               nvl(numeric2, 0)
          into intempresa, intnomina
          from bdinteg:si_ctepf 
         where empresa = pempresa 
           and numcte = chrnumcte; 
    else
        let intempresa = 0;
        let intnomina = 0;
    end if        

    return chrcodret, chrsucursal, chrproducto, chrnumcte, chrenviodirecc, chrnumcot, dtefecultmov, 
           chrejecutivo, chrdireccenvio, chrregfirmas, chrprocedaperacta, chrprocedmantcta, chrmontomensual, 
           chrdepositoscant, chrdepositosmonto, chrretiroscant, chrretirosmonto, chrcuentaclabe, intempresa, intnomina;

    end;

end procedure;