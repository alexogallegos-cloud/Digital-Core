create procedure "informix".detdocret( pempresa  char(3),
                                       psucursal char(4),
                                       pusuario  char(8),
                                       pfolio    char(16),
                                       pimporte  money(14,2),
                                       pcuenta   char(20),
                                       pctabco   char(20),
                                       pdocto    integer,
                                       pbanco    char(4),
                                       ptransacc char(4),
                                       psiglas   char(2) )
returning char(5);

    define vcodret      char(5);
    define vrow         smallint;
    define vfechoy      date;
    define vfechacalc 	date;
    define vdias_ret 	smallint;
    define vreferencia 	char(40);
    define vpasado     	integer;
    DEFINE vhoraval    	CHAR(10);
    DEFINE vvalor       CHAR(10);
    DEFINE vdctabco     DECIMAL(20,0);
    DEFINE vcctabco     CHAR(20);

    LET vcodret  = "000";
    LET vhoraval = "00:00";
    LET vdctabco = 0;
    LET vcctabco = '';

    --- set debug file to "detocret.out";
    --- trace on;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 4;

    SELECT {+INDEX(sc_fechas idx_fechas1)}
           CURRENT HOUR TO MINUTE, fecha_hoy
      INTO vhoraval, vfechoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    SELECT {+INDEX(bditef:cce_param idx_param)}
           valor
      INTO vvalor
      FROM bditef:cce_param
     WHERE cod_param = 1;

    IF vhoraval >= vvalor THEN
        LET vcodret = "015";
        RETURN vcodret;
    END IF

    if length(trim(pbanco)) < 4 then
        let pbanco = lpad(trim(pbanco),3,0);
    end if

    let vreferencia = pbanco||"-"||trim(pctabco)||"-"||pdocto;
    
    let vdctabco = pctabco::decimal(20,0);
    let vcctabco = vdctabco;
    let vcctabco = trim(vcctabco);

    if pempresa = "" or psucursal = "" or pusuario = "" or pfolio = "" or pimporte = 0 or pcuenta = "" or ptransacc = "" or ptransacc = "0000" or psiglas  = "" then
        let vcodret = "110";
        return vcodret;
    end if

    select count(empresa) 
      into vpasado 
      from sc_docret_sbc  			--MOHA	
     where siglas in('SC','SD')
       and fecha_alta = vfechoy
       and cancelado in("T", "D", "L")
       and banco = pbanco
       and numcuenta = vcctabco
       and num_chq = pdocto;
    -- and trim(referencia) = trim(vreferencia);

    if vpasado > 0 then
        let vcodret = "666";
        return vcodret;   
    end if

    select dias_ret 
      into vdias_ret
      from bdinteg:si_transacc
     where empresa = pempresa 
       and numero = ptransacc;

    if vdias_ret is null then
        let vdias_ret = 0;
    end if

    call bditef:cal_fecharet(vfechoy)
    returning vcodret,vfechacalc;

    if vcodret <> "000" then
        return vcodret;
    end if

    if vfechacalc <> vfechoy then 
        let vdias_ret = 2;
    else
        let vdias_ret = 1;
    end if

	IF EXISTS (select empresa from sc_docret_sbc where banco = pbanco and numcuenta = vcctabco and num_chq = pdocto and cancelado in("T", "D", "L")) THEN --MOHA
		let vcodret = "666";
		return vcodret;   
	ELSE
		insert into sc_docret_sbc values     --MOHA
		( pempresa, psiglas, pcuenta, vdias_ret, pimporte, pfolio, pusuario, vfechoy, current hour to fraction(3),
		  "T", vreferencia, psucursal, pdocto, vdias_ret, ptransacc, pimporte, pbanco, vcctabco );	  
	END IF

    /* ###################################################################################
    call bditef:cal_fechapre(pempresa,pbanco,lpad(trim(pctabco),20,"0"),pdocto,vfechoy)
    returning vcodret,vfechacalc;

    if vcodret <> "000" then
        delete from sc_docret 
         where empresa = pempresa
           and cuenta = pcuenta
           and folio_suc = pfolio
           and monto = pimporte
           and cancelado ="T";

        return vcodret;
    end if

    if vfechacalc <> vfechoy then 
        let vdias_ret = 2;
    else
        let vdias_ret = 1;
    end if

    update sc_docret 
       set dias_ret = vdias_ret, 
           dias_ori= vdias_ret
     where empresa = pempresa
       and cuenta = pcuenta
       and folio_suc = pfolio
       and monto = pimporte
       and cancelado ="T";
    ################################################################################### */

    return vcodret;

end procedure 

document "Version 1.00.000";

CREATE PROCEDURE "informix".act_datosfirmas_web(pempresa CHAR(3),
                                        pcuenta char(20),
					preg_firmas char(1))
RETURNING CHAR(5);

DEFINE vsqlerr INTEGER;
DEFINE vcodret        CHAR(5);
DEFINE vctaclabe      CHAR(18);
DEFINE psucursal      CHAR(4);
DEFINE pproducto      CHAR(4);
DEFINE pnum_cte       CHAR(20);
DEFINE pclase_cta     CHAR(1);
--DEFINE preg_firmas    CHAR(1);
DEFINE pejecutivo     CHAR(8);
DEFINE penvio_direcc  CHAR(1);
DEFINE pdirecc_envio  SMALLINT;
DEFINE pnofirmas      SMALLINT;
DEFINE vexiste        SMALLINT;
DEFINE vcombinacion   CHAR(100);
DEFINE vfecha_alta    CHAR(100);

begin
   on exception set vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END exception;

     --SET DEBUG FILE TO "/tmp/act_datosfirmas.out";
     --TRACE ON;


-- Inicializa variables
LET vcodret        = "00000";
LET vctaclabe      = "";
LET psucursal      = "";
LET pproducto      = "";
LET pnum_cte       = "";
LET pclase_cta     = "";
--LET preg_firmas    = "";
LET pejecutivo     = "";
LET penvio_direcc  = "";
LET pdirecc_envio  = 0;
LET vexiste        = 0;
LET pnofirmas      = 0;
LET vcombinacion   = "";
LET vfecha_alta    = "";

-- Valida la informacion de entrada
   IF pempresa       = "" OR
      pcuenta      = ""  THEN
      LET vcodret = "110";
      RETURN vcodret;
   END IF;

   SELECT 1 INTO vexiste
      FROM sc_maechq WHERE empresa = pempresa AND cuenta = pcuenta;
   IF vexiste IS NULL THEN
      LET vcodret = "405";
      RETURN vcodret;
   END IF;

let pempresa = pempresa;
let pcuenta = pcuenta;
let preg_firmas = preg_firmas;


   update bdicheq:sc_maenoc set reg_firmas = preg_firmas
    WHERE empresa = pempresa
      AND cuenta = pcuenta;


   RETURN vcodret;

END
END procedure
;