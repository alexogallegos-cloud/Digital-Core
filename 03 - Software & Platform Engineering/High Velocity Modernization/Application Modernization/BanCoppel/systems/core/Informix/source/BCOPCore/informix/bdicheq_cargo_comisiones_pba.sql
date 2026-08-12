CREATE PROCEDURE "informix".cargo_comisiones_pba(eEmpresa  CHAR(3),
                                             eCuenta   CHAR(20),
                                             eComision CHAR(4),
                                             eMonto    MONEY(14,2),
                                             eFolio    CHAR(16),
                                             eSucursal CHAR(4),
                                             eUsuario  CHAR(8),
                                             eCheque   INTEGER,
                                             eDivisa   CHAR(2),
                                             eHoy      DATE)
RETURNING CHAR(5);
    
    DEFINE eCodRet          CHAR(5);
    DEFINE eCodRet2         CHAR(5);
    DEFINE eCodRet3         CHAR(50);
    DEFINE sql_err          SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
    DEFINE vFormaAplic      CHAR(1);
    DEFINE vMtoAplic        MONEY(14,2);
    DEFINE vFactorAplic     DECIMAL(9,6);
    DEFINE vRangos          CHAR(1);
    DEFINE vRangoMin        DECIMAL(14,2);
    DEFINE vRangoMax        DECIMAL(14,2);
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
	DEFINE vNumTarjeta      CHAR(20);
	DEFINE pNumTarjeta      CHAR(20);
    DEFINE vMontoCom        MONEY(14,2);
    DEFINE vValIva          DECIMAL(9,6);
    DEFINE vDisponible      MONEY(14,2);
    DEFINE vMtoCom          MONEY(14,2);
    DEFINE vMontoPen        MONEY(14,2);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vexistecta       SMALLINT;
    DEFINE vexistecom       SMALLINT;
	DEFINE vproducto        CHAR(4);
	DEFINE vIVA             MONEY(14,2);
    DEFINE vSdoDisp         MONEY(14,2);

    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/tmp/cargo_comisiones_pba.err";
        TRACE ON;
        LET eCodRet = sql_err;
        LET eCodRet2 = isam_err;
        LET eCodRet3 = error_info;
        RETURN eCodRet;
    END EXCEPTION;

    LET eCodRet      = "000";
    LET eCodRet2     = "000";
    LET eCodRet3     = "000";
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = '';
    LET vFormaAplic  = '';
    LET vMtoAplic    = 0;
    LET vFactorAplic = 0;
    LET vRangos      = '';
    LET vRangoMin    = 0;
    LET vRangoMax    = 0;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vMontoCom    = 0;
    LET vValIva      = 0;
	LET vNumTarjeta  = '';
	LET pNumTarjeta  = '';
    LET vDisponible  = 0;
    LET vMtoCom      = 0;
    LET vMontoPen    = 0;
    LET vMontoDif    = 0;
    LET vexistecta   = 0;
    LET vexistecom   = 0;
	LET vproducto    = '';
	LET vIVA         = 0;
    LET vSdoDisp     = 0;
	
    SET DEBUG FILE TO "/tmp/cargo_comisiones_pba.out";
    TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA DATOS DE ENTRADA - EMPRESA
    IF eEmpresa is null OR eEmpresa = '' THEN
        LET eCodRet = '110';
        RETURN eCodRet;
    END IF;
    
    -- // VALIDA DATOS DE ENTRADA - CUENTA
    SELECT producto, sdo_actual - ( sdo_retenido + sdo_cong + imp_chq_sbg )
      INTO vproducto, vDisponible
      FROM sc_maechq
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta;

    IF vproducto in('1300', '1400', '1700') THEN
	   LET eCodRet = '000';
	   RETURN eCodRet;
	END IF;
	   
    --// Extrae instrumentacion de la Comision
    SELECT forma_aplica, monto_aplica, factor_aplica, rangos, rango_min, rango_max, genera_iva, transacc_com, transacc_iva
      INTO vFormaAplic, vMtoAplic, vFactorAplic, vRangos, vRangoMin, vRangoMax, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = eEmpresa
       AND comision = eComision;
	   
	IF vFormaAplic is null OR vFormaAplic = " " THEN
       LET eCodRet = '550';
       RETURN eCodRet;
    END IF; 
	
	-- // Valida la sucursal para transacciones de aclaraciones
	IF eComision = '0343' THEN
	   SELECT sucursal 
	     INTO eSucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = eSucursal;
	   IF eSucursal is null or eSucursal = "" THEN
	      SELECT sucursal
            INTO eSucursal		  
		    FROM bdinteg:si_ejecut 
		   WHERE ejecutivo in(SELECT num_empleado 
		                        FROM bdiaclaracion:acl_aclaracion 
							   WHERE folio_csuac = eFolio);
       END IF;
    END IF;	   
	
    SELECT valor 
      INTO vValIva 
      FROM bdinteg:si_param
     WHERE empresa = eEmpresa
       AND cod_param = 47;
		 
    -- // SE AGREGA UNA NUEVA FORMA DE APLICACION '3' VARIABLE 
    -- // Determina Forma de Aplicacion
    IF vFormaAplic = "1" THEN 
        LET vMontoCom = vMtoAplic; -- Monto Fijo de Comision
    ELIF vFormaAplic = "2" THEN  
        LET vMontoCom = eMOnto * vFactorAplic; -- Por Factor
    ELIF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
        LET vMontoDif = eMOnto - vDisponible;
        
        IF vMontoDif > vMtoAplic THEN
            LET vMontoCom = vMtoAplic;
        ELSE
            LET vMontoCom = vMontoDif;
        END IF;
    ELIF vFormaAplic = "4" THEN 
        LET vMontoCom = eMOnto; -- Aclaraciones
    END IF;

    -- // Valida los Rangos
    IF vRangos = "S" THEN
        IF vMontoCom < vRangoMin OR vMontoCom > vRangoMax THEN
            LET vMontoCom = vMtoAplic;
        END IF;
    END IF;

    IF vGenIva = "N" THEN 
        LET vValIva = 0;  
    END IF;

    IF vDisponible < (vMontoCom * (1 + vValIva)) THEN
        LET vMtoCom   = vMontoCom;
        LET vMontoCom = ROUND(vDisponible / (1 + vValIva),2);
        LET vMontoPen = vMtoCom - vMOntoCom;
		LET vIVA      = vDisponible - vMontoCom;
	ELSE
	    LET vIVA      = TRUNC((vMontoCom * vValIva),2);
    END IF;

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra comision por reposicion de TDD
	IF vDisponible > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;
	    -- // Aplica Cargo por Comision	 
		IF vDisponible > 0 THEN 
        CALL cargon_ref_pba(eEmpresa, eSucursal, eUsuario, vTranCom, "0000", eFolio, eCuenta, eCheque, vMontoCom, eDivisa, "", pNumTarjeta,"")
        RETURNING eCodRet, eComision;
        
        IF eCodRet <> "000" THEN
            RETURN eCodRet;
        END IF;
        
        -- // Valida Cobro de Iva
        IF vGenIva = "S" THEN
            SELECT sdo_actual - ( sdo_retenido + sdo_cong + imp_chq_sbg )
              INTO vSdoDisp
              FROM sc_maechq
             WHERE empresa = eEmpresa
               AND cuenta = eCuenta;
--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra IVA de comision por reposicion de TDD			   
       IF vSdoDisp > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;  
            IF vSdoDisp > 0 THEN
                CALL cargon_ref_pba(eEmpresa, eSucursal, eUsuario, vTranIva, "0000", eFolio, eCuenta, eCheque, vIVA, eDivisa, "",pNumTarjeta,"")
                RETURNING eCodRet, eComision;
            END IF;
                
            IF eCodRet <> "000" THEN
                RETURN eCodRet;
            END IF;
        END IF;
    END IF;

    -- // Registra comision pendiente si es el caso
    IF vMontoPen > 0 THEN
        INSERT INTO sc_detcomis 
        VALUES(eEmpresa, eCuenta, vTranCom, vMontoPen  , 0, eHoy, "", "P", eFolio);

        UPDATE sc_maechq
           SET com_pendiente =  com_pendiente + vMontoPen
         WHERE empresa = eEmpresa
           AND cuenta  = eCuenta;
    END IF;

    RETURN eCodRet;

END PROCEDURE

DOCUMENT
'Esta funcion se encarga de realizar los movimientos de cargo por ',
'concepto de comisiones e iva de las mismas',
'AUTOR : Procesaminto Interactivo S.A. Axl',
'FECHA : 28/01/2010',
'BD : bdicheq ',
'CLIENTE : Todos';

create procedure "informix".sp_cargo_val_pba(pcuenta    char(20))
    returning char(5);

    define vcodret 		char(5);
    define vsqlerr 		integer;
    define vfecha_hoy    date;
    define vfecha_ant    date;
    define vfecha_proceso date;
    define vstatus_cta   char(1);
    define vretiros 		money(14,2);
    define vabonos		money(14,2);
    define vsdoactual	money(14,2);
    define vsdoinicial   money(14,2);
    define vsdoretenido  money(14,2);
    define vsdodisp      money(14,2);
    define vsdocalculado money(14,2);
    define vdiferencia   money(14,2);
    define vreferencia 	char(40);
    define vcuantos      smallint;
    define vproducto		char(4);

    set isolation to cursor stability;
    set lock mode to wait 10;

    let vcodret = "000";
    let vabonos = 0;
    let vretiros = 0;
    let vdiferencia = 0;

    begin

    on exception set vsqlerr
        set debug file to "/tmp/sp_cargo_val_pba.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret;
        end if
    end exception;

    SET DEBUG FILE TO "/tmp/sp_cargo_val_pba.out";
    TRACE ON;

    -- // Valida la informacion de entrada
    if pcuenta = '' then
        let vcodret = 110;
        return vcodret;
    end if;

    set isolation to dirty read;

    if pcuenta in('16000000080','16000000322','16000000012') or 
       pcuenta in('10014594944','10029763610','10096982955','10101302909','10112587964','10121425535','10152230708','10290633686','10331870680',
                  '10349349235','13005759646','10426086994','10426817026','10430000557','10441560350','10442816048','10449170151','10449445150') then
        let vcodret = '00000';
        return vcodret;
    end if;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    select fecha_hoy, fecha_ant
      into vfecha_hoy, vfecha_ant
      from sc_fechas;

    select sdo_dia_ant, sdo_actual, sdo_retenido, status_cta, fecha_proceso, producto 
      into vsdoinicial, vsdoactual, vsdoretenido, vstatus_cta, vfecha_proceso, vproducto
      from sc_maechq
     where cuenta = pcuenta;

    /* ############################
    if vproducto = '2900' then
        let vcodret = '00000';
        return vcodret;
    end if;	
    ############################ */

    if vstatus_cta IN('2', '6') then
        let vcodret = '00000';
        return vcodret;
    end if; 

    if vstatus_cta in('1', '3', '5') then
        if vfecha_proceso is null or vfecha_proceso = "" then
            let vfecha_hoy = vfecha_hoy;
        else
            let vfecha_hoy = vfecha_proceso;
        end if;
    end if;

    select nvl(count(*), 0)
      into vcuantos
      from sc_movdia
     where transacc in('0415', '0416', '3232')
       and cancelad <> 'S'
       and cuenta = pcuenta;

    if vcuantos > 0 then
        let vcodret = '00000';
        return vcodret;
    end if;   

    select nvl(sum(monto_tot), 0) into vretiros
      from sc_movdia, bdinteg:si_transacc
     where cuenta = pcuenta
       and naturaleza = 'C'
       and se_contabiliza = 'S'
    -- and se_emite_edocta = 'S'
       and transacc = numero
       and sistema = '01'
       and fech_alt = vfecha_hoy
       and cancelad <> 'S'
       and transacc <> '0232';

    select nvl(sum(monto_tot), 0) into vabonos
      from sc_movdia, bdinteg:si_transacc
     where cuenta = pcuenta
       and naturaleza = 'A'
       and se_contabiliza = 'S'
    -- and se_emite_edocta = 'S'
       and transacc = numero
       and sistema = '01'
       and fech_alt = vfecha_hoy
       and cancelad <> 'S';   

    -- let vsdodisp = vsdoactual - vsdoretenido;
    let vsdodisp = vsdoactual;
    let vsdocalculado = vsdoinicial + vabonos - vretiros;

    if pcuenta in('22000001574', '99010000030') then
        let vdiferencia = vsdodisp - vsdocalculado;
        
        if vdiferencia < 0.00 then
            let vdiferencia = vdiferencia * -1;
        end if;
        
        if vdiferencia > 100000.00 then
            let vcodret = 110;
            insert into sc_cuentas_retiro values(pcuenta, vfecha_hoy, vsdocalculado, vsdodisp);
        else
            let vcodret = '00000';
        end if;
    else
        if vsdocalculado <> vsdodisp then
            let vcodret = 110;
            insert into sc_cuentas_retiro values(pcuenta, vfecha_hoy, vsdocalculado, vsdodisp);
        else
            let vcodret = '00000';
        end if;
    end if;

    select nvl(referencia, ''), nvl(count(*), 0)
      into vreferencia, vcuantos
      from sc_movdia
     where transacc = '0273'
       and cancelad <> 'S'
       and cuenta = pcuenta
     group by 1
    having count(*) > 1;

    if vcuantos > 1 then
        let vcodret = 110;
        insert into sc_cuentas_retiro values(pcuenta, vfecha_hoy, vsdocalculado, vsdodisp);
    end if;

    return vcodret;

    end;

end procedure;