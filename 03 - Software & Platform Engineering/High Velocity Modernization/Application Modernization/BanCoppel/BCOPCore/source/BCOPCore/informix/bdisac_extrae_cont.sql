CREATE PROCEDURE "informix".extrae_cont( pempresa     char(3),
                                         psecuencia   smallint,
                                         pmonto_tot   money(14,2),
                                         psucope      char(4),
                                         pproducto    char(4),
                                         pmoneda      char(2),
                                         ptransacc    char(4),
                                         psector      char(2),
                                         pcancelad    char(1),
                                         psuccta      char(4),
                                         pdescripcion char(30) )
returning char(5);
    
    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;

    define vcodret           char(5); 
    define vsqlerr           integer;
    define vp_num_cte        char(9);
    define v_tipo_cuenta     char(1);
    define v_auxiliar        char(9);
    define v_aux             integer;
    define w_secuencia       smallint;
    define vw_auxiliar       char(1);
    define v_sectoriza_cta   char(1);
    define vsuctmp           char(4);
    define vc_ccmayor        char(10);
    define vc_ccsub          char(10);
    define vc_ccsubsub       char(10);
    define vc_ccsssub        char(10);
    define vc_ccssssub       char(10);
    define vc_sector         char(10);
    define va_ccmayor        char(10);
    define va_ccsub          char(10);
    define va_ccsubsub       char(10);
    define va_ccsssub        char(10);
    define va_ccssssub       char(10);
    define va_sector         char(10);
    define viva_ccmayor      char(10);
    define viva_ccsub        char(10);
    define viva_ccsubsub     char(10);
    define viva_ccsssub      char(10);
    define viva_ccssssub     char(10);
    define viva_sector       char(10);
    define vitr_ccmayor      char(10);
    define vitr_ccsub        char(10);
    define vitr_ccsubsub     char(10);
    define vitr_ccsssub      char(10);
    define vitr_ccssssub     char(10);
    define vitr_sector       char(10);
	define vsc_contab_temp   BOOLEAN;  
    define vsuccta           char(4);

    let vcodret           = '000';
    let vsqlerr           = 0;
    let vp_num_cte        = ' ';
    let v_tipo_cuenta     = ' ';
    let v_auxiliar        = ' ';
    let v_aux             = 0;
    let w_secuencia       = 0;
    let vw_auxiliar       = ' ';
    let v_sectoriza_cta   = ' ';
    let vsuctmp           = ' ';
    let vc_ccmayor        = ' ';
    let vc_ccsub          = ' ';
    let vc_ccsubsub       = ' ';
    let vc_ccsssub        = ' ';
    let vc_ccssssub       = ' ';
    let vc_sector         = ' ';
    let va_ccmayor        = ' ';
    let va_ccsub          = ' ';
    let va_ccsubsub       = ' ';
    let va_ccsssub        = ' ';
    let va_ccssssub       = ' ';
    let va_sector         = ' ';
    let viva_ccmayor      = ' ';
    let viva_ccsub        = ' ';
    let viva_ccsubsub     = ' ';
    let viva_ccsssub      = ' ';
    let viva_ccssssub     = ' ';
    let viva_sector       = ' ';
    let vitr_ccmayor      = ' ';
    let vitr_ccsub        = ' ';
    let vitr_ccsubsub     = ' ';
    let vitr_ccsssub      = ' ';
    let vitr_ccssssub     = ' ';
    let vitr_sector       = ' ';
	let vsc_contab_temp   = 'F';
    let vsuccta           = psuccta;

    --- SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    --- SET ISOLATION COMMITTED READ;

    begin

    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
			
			IF vsc_contab_temp = 'T' THEN
				DROP TABLE sc_contab_temp;
			END IF
			
            return vcodret;
        end if;
    end exception;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    let viva_ccmayor  = substr(vgcta_iva, 1, 4);
    let viva_ccsub    = substr(vgcta_iva, 5, 2);
    let viva_ccsubsub = substr(vgcta_iva, 7, 2);
    let viva_ccsssub  = substr(vgcta_iva, 9, 2);
    let viva_ccssssub = substr(vgcta_iva, 11, 2);
    let viva_sector   = substr(vgcta_iva, 13, 2);

    let vitr_ccmayor  = substr(vgcta_itr, 1, 4);
    let vitr_ccsub    = substr(vgcta_itr, 5, 2);
    let vitr_ccsubsub = substr(vgcta_itr, 7, 2);
    let vitr_ccsssub  = substr(vgcta_itr, 9, 2);
    let vitr_ccssssub = substr(vgcta_itr, 11, 2);
    let vitr_sector   = substr(vgcta_itr, 13, 2);

    select c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector,
           a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
      into vc_ccmayor, vc_ccsub, vc_ccsubsub, vc_ccsssub, vc_ccssssub, vc_sector,
           va_ccmayor, va_ccsub, va_ccsubsub, va_ccsssub, va_ccssssub, va_sector
      from bdinteg:si_prodtran
     where empresa = pempresa 
       and producto = pproducto 
       and sistema = vg_sistema 
       and transaccion = ptransacc 
       and secuencia = psecuencia;

	IF (vc_ccmayor =' '  OR vc_ccmayor IS NULL) AND (va_ccmayor = ' ' OR va_ccmayor IS NULL) THEN

		CALL sp_suspenso(pempresa,'01',pmonto_tot,psecuencia,psucope,psuccta,pcancelad,pproducto,pmoneda,ptransacc,psector,
						 case when pdescripcion = 'ABSPEIWU' OR pdescripcion = 'ABSPEIBTS' OR pdescripcion = 'ABSPEIAPP' then 'ABSPEI' else pdescripcion end ,vfecha_hoy) 

        RETURNING vcodret,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,
                          va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector;
						  
	END IF 
  
	CREATE TEMP TABLE sc_contab_temp ( 
		empresa    	CHAR(3),
		secuencia  	SMALLINT,
		sucursal   	CHAR(4),
		succta     	CHAR(4),
		ccmayor    	CHAR(10),
		ccsub      	CHAR(10),
		ccsubsub   	CHAR(10),
		ccssubsub  	CHAR(10),
		ccsssubsub 	CHAR(10),
		sector     	CHAR(10),
		auxiliar   	CHAR(9),
		tot_cargo  	MONEY,
		tot_abono  	MONEY,
		moneda     	CHAR(2),
		descripcion	CHAR(30) 
    ) WITH NO LOG;


	LET vsc_contab_temp = 'T';
	
    -- / / / / / / / / / /    CUENTA CARGO   / / / / / / / / / /
    if vc_ccmayor is null then 
        let vc_ccmayor = " "; 
    end if;
    
    if vc_ccsub is null then 
        let vc_ccsub = " "; 
    end if;
    
    if vc_ccsubsub is null then 
        let vc_ccsubsub = " "; 
    end if;
    
    if vc_ccsssub is null then 
        let vc_ccsssub = " "; 
    end if;
    
    if vc_ccssssub is null then 
        let vc_ccssssub = " "; 
    end if;

    select tipo_cuenta, sectoriza_cta, auxiliar 
      into v_tipo_cuenta, v_sectoriza_cta, vw_auxiliar
      from bdinteg:si_catalog
     where empresa    = pempresa    
       and ccmayor    = vc_ccmayor    
       and ccsub      = vc_ccsub     
       and ccsubsub   = vc_ccsubsub   
       and ccssubsub  = vc_ccsssub   
       and ccsssubsub = vc_ccssssub   
       and sector     = vc_sector;
       
    if v_sectoriza_cta = "N" then  
        let vc_sector = "00"; -- // La cuenta NO se sectoriza
    else
        let vc_sector = psector;
    end if;
    
    -- // Se agrega la transacció® ¤e Pago de Cheque Propio por Cá­¡ra y TEF
    if ptransacc = vgtransacc_t1 or ptransacc = vgtransacc_t2 or ptransacc = '0231' or ptransacc = '1114' or ptransacc = '3300' then
        if vc_ccmayor = "1102" then
            let vc_sector = "21";
        end if;
    end if;

    if ptransacc = "1171" or ptransacc = "1143" then
        if vc_ccmayor = "2402" then
            let vc_sector = "31";
        end if;	 
    end if;

{--08/08/2017
    -- // Pago de Remesas BTS
    if ptransacc = '1110' or ptransacc = '1140' then
        if vc_ccmayor = '2101' then
            let vc_sector = '42';
        end if;	 
    end if;
	
    -- // Pago de Remesas WU - ORLANDI - VIGO
    if ptransacc IN ('1121','1122','1123','1151','1152','1153') then
        if vc_ccmayor = '2101' then
            let vc_sector = '31';
        end if;	 
    end if;
	
	-- // Pago de Remesas APPRIZA PAY
    if ptransacc = '1325' or ptransacc = '1355' then
        if vc_ccmayor = '2101' then
            let vc_sector = '42';
        end if;	 
    end if;
}
--//TRANSACCION CFE

    if ptransacc IN ('1437','1436','1321','1435') then
        if vc_ccmayor = '2402' then
            let vc_sector = '14';
        end if;	 
    end if;

    if ptransacc = vgtransacc_corresp then
        if vc_ccmayor = "1402" then
            let vc_sector = "31";
        end if;
    end if;

	if ptransacc in("0283", "0305", "0308", "0410") then
        if vc_ccmayor = "1402" then
            let vc_sector = "31";
        end if;
    end if;
	
    if ptransacc = "0326" then
        if vc_ccmayor = "1402" then
            let vc_sector = "11";
        end if;	 
    end if;
	
	if ptransacc = "0205" and pproducto = "8000" then
        if vc_ccmayor = "2101" then
            let vc_sector = "32";
        end if;	 
    end if;
	
	if pproducto = "8000" THEN
	   IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '210101030201' THEN
        LET vc_sector = '31';
	   END IF;
	end if;
	
    if pcancelad = "V" then
        let pmoneda = vgcodigo_mn;
    end if;

    if vc_ccmayor  = viva_ccmayor  AND 
       vc_ccsub    = viva_ccsub    AND 
       vc_ccsubsub = viva_ccsubsub AND 
       vc_ccsssub  = viva_ccsssub  AND 
       vc_ccssssub = viva_ccssssub THEN
        let vc_sector = viva_sector;
    end if;

    if vc_ccmayor  = vitr_ccmayor   AND
       vc_ccsub    = vitr_ccsub     AND
       vc_ccsubsub = vitr_ccsubsub  AND
       vc_ccsssub  = vitr_ccsssub   AND
       vc_ccssssub = vitr_ccssssub  THEN
        let vc_sector = vitr_sector;
    end if;

    let vc_ccmayor  = trim(vc_ccmayor);
    let vc_ccsub    = trim(vc_ccsub);
    let vc_ccsubsub = trim(vc_ccsubsub);
    let vc_ccsssub  = trim(vc_ccsssub);
    let vc_ccssssub = trim(vc_ccssssub);
    
    if (ptransacc = '0273' OR ptransacc = '0277') AND trim(vc_ccmayor)||trim(vc_ccsub) = '951207' THEN
        let psucope = '9201';
    end if;
    
    if (ptransacc = '0276') AND trim(vc_ccmayor)||trim(vc_ccsub) = '951102' THEN
        let psucope = '9201';
    end if;
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '240290200201' THEN
        LET vc_sector = '31';
    END IF;
	
	IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '240290240000' THEN
        LET vc_sector = '31';
    END IF;
	
	IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '140290141101' THEN
        LET vc_sector = '31';
    END IF;

	IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '240293030400' THEN
        LET vc_sector = '31';
    END IF;	
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '240208040303' THEN
        LET vc_sector = '11';
    END IF;
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub)||trim(vc_sector) = '14029025000000' THEN
        LET psuccta = '9201';
    END IF;
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '140295040100' THEN
        LET psuccta = '5001';
    END IF;
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '140290140101' THEN
        LET psuccta = '5005';
    END IF;
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '140290141101' THEN
        LET psuccta = '5005';
    END IF;
	
	insert into aux_auditerr values
    (pempresa,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,v_auxiliar,pproducto,ptransacc,pmonto_tot);

    -- // Para cuentas de enlace..
    IF vc_ccmayor[1,2] = "95" THEN 
        insert into sc_contab_temp values
        (pempresa, w_secuencia, psucope, psucope, vc_ccmayor, vc_ccsub, vc_ccsubsub, 
         vc_ccsssub, vc_ccssssub, vc_sector, v_auxiliar, pmonto_tot, 0, pmoneda, 
		 case when pdescripcion = 'ABSPEIWU' OR pdescripcion = 'ABSPEIBTS' OR pdescripcion = 'ABSPEIAPP' then 'ABSPEI' else pdescripcion end );
    ELSE -- // Para el resto de las cuentas...
        insert into sc_contab_temp values
        (pempresa, w_secuencia, psucope, psuccta, vc_ccmayor, vc_ccsub, vc_ccsubsub,
         vc_ccsssub, vc_ccssssub, vc_sector, v_auxiliar, pmonto_tot, 0, pmoneda, 
		 case when pdescripcion = 'ABSPEIWU' OR pdescripcion = 'ABSPEIBTS' OR pdescripcion = 'ABSPEIAPP' then 'ABSPEI' else pdescripcion end );
    END IF;
    
    -- / / / / / / / / / /   CUENTA ABONO   / / / / / / / / / / 
    if va_ccmayor is null then 
        let va_ccmayor = " "; 
    end if;
    
    if va_ccsub is null then 
        let va_ccsub = " "; 
    end if;
    
    if va_ccsubsub is null then 
        let va_ccsubsub = " "; 
    end if;
    
    if va_ccsssub is null then 
        let va_ccsssub = " "; 
    end if;
    
    if va_ccssssub is null then 
        let va_ccssssub = " "; 
    end if;
    
    if va_sector is null then 
        let va_sector = " "; 
    end if;

    select tipo_cuenta, sectoriza_cta, auxiliar 
      into v_tipo_cuenta, v_sectoriza_cta, vw_auxiliar
      from bdinteg:si_catalog
     where empresa    = pempresa    
       and ccmayor    = va_ccmayor    
       and ccsub      = va_ccsub     
       and ccsubsub   = va_ccsubsub   
       and ccssubsub  = va_ccsssub   
       and ccsssubsub = va_ccssssub   
       and sector     = va_sector;
       
    if v_sectoriza_cta = "N" then 
        let va_sector = "00";    -- // La cuenta NO se sectoriza
    else
        let va_sector = psector; -- // Se respeta el sector del cliente
    end if;
    
    -- // Se agrega la transacció® ¤e Pago de Cheque Propio por Cá­¡ra
    if ptransacc = vgtransacc_t1 or ptransacc = vgtransacc_t2 or ptransacc = '0231' or ptransacc = '3300'then
        if va_ccmayor = "1102" then
            let va_sector = "21";
        end if;
    end if;

	if ptransacc IN ("3387", "3393") then
        if va_ccmayor = "5390" then
            let va_sector = "31";
        end if;	 
    end if;
	
	if ptransacc IN ("3388", "3394") then
        if va_ccmayor = "2402" then
            let va_sector = "11";
        end if;	 
    end if;

    --if ptransacc = "1141" or ptransacc = "1113" or ptransacc = "1144"   then
	if ptransacc IN ("1141", "1113", "1144", "3396","3398","3399","4000" ) then
        if va_ccmayor = "2402" then
            let va_sector = "31";
        end if;	 
    end if;
	
{--08/08/2017
    if ptransacc = "1119" or ptransacc = "1179" or ptransacc = "1180" then
        if va_ccmayor = "2101" then
            let va_sector = "12";
        end if;	 
    end if;
}	
	--TRANSACCION CFE
    if ptransacc = "1311" or ptransacc = "1371" or ptransacc = "1438" then
        if va_ccmayor = "2402" then
            let va_sector = "14";
        end if;	 
    end if;
    if ptransacc = vgtransacc_corresp then
        if va_ccmayor = "1402" then
            let va_sector = "31";
        end if;
    end if;

	if ptransacc in("0283", "0305", "0308", "0410") then
       if va_ccmayor = "1402" then
          let vc_sector = "31";
       end if;
	end if;
	
    if ptransacc = "1204" then
        if va_ccmayor = "5309" then
            let va_sector = "32";
        end if;	 
    end if;

	if ptransacc = "0326" then
        if va_ccmayor = "1402" then
            let va_sector = "11";
        end if;	 
    end if;

    -- // Pagos Referenciados SOLFI ABONO / CONTIGO
	if ptransacc IN ("1127","1187","1604","1694") then
        if va_ccmayor = "2402" then
            let va_sector = "26";
        end if;	 
    end if;

{--08/08/2017	
    -- // Pagos Referenciados CREDIAVANCE ABONO
	if ptransacc IN ("1328","1388") then
        if va_ccmayor = "2101" then
            let va_sector = "26";
        end if;	 
    end if;	
	
 
 -- // Pago de Remesas BTS
    if ptransacc = '0273' and psecuencia = '2' and pproducto = '1600' and pdescripcion = 'ABSPEIBTS' then
        if va_ccmayor = '2101' then
            let va_sector = '42';
            let pdescripcion = 'ABSPEI';            
        end if;	 
    end if;

	
    -- // Pago de Remesas WU
    if ptransacc = '0273' and psecuencia = '2' and pproducto = '2200' and pdescripcion = 'ABSPEIWU' then
        if va_ccmayor = '2101' then
            let va_sector = '31';
            let pdescripcion = 'ABSPEI';
        end if;	 
    end if;
	
	-- // Pago de Remesas APPRIZA PAY
    if ptransacc = '0273' and psecuencia = '2' and pproducto = '1600' and pdescripcion = 'ABSPEIAPP' then
        if va_ccmayor = '2101' then
            let va_sector = '42';
            let pdescripcion = 'ABSPEI';            
        end if;	 
    end if;
}	

    if ptransacc = "0205" and pproducto = "8000" then
        if va_ccmayor = "2101" then
            let va_sector = "32";
        end if;	 
    end if;
	
	if pproducto = "8000" THEN
	   IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '210101030201' THEN
        LET va_sector = '31';
	   END IF;
	end if;
	   
	
	if pcancelad = "V" then
        let pmoneda = vgcodigo_mn;
    end if;

    if va_ccmayor  = viva_ccmayor   AND
       va_ccsub    = viva_ccsub     AND
       va_ccsubsub = viva_ccsubsub  AND
       va_ccsssub  = viva_ccsssub   AND
       va_ccssssub = viva_ccssssub  THEN
        let va_sector = viva_sector;
    end if;

    if va_ccmayor  = vitr_ccmayor   AND
       va_ccsub    = vitr_ccsub     AND
       va_ccsubsub = vitr_ccsubsub  AND
       va_ccsssub  = vitr_ccsssub   AND
       va_ccssssub = vitr_ccssssub  THEN
        let va_sector = vitr_sector;
    end if;

    let va_ccmayor  = trim(va_ccmayor);
    let va_ccsub    = trim(va_ccsub);
    let va_ccsubsub = trim(va_ccsubsub);
    let va_ccsssub  = trim(va_ccsssub);
    let va_ccssssub = trim(va_ccssssub);
    
    if ptransacc = '0274' AND trim(va_ccmayor)||trim(va_ccsub) = '951102' THEN
        let psucope = '9201';
    end if;
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '240290200201' THEN
        LET va_sector = '31';
    END IF;
	
	IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '240290240000' THEN
        LET va_sector = '31';
    END IF;
	
	IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '140290141101' THEN
        LET va_sector = '31';
    END IF;

	IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '240293030400' THEN
        LET va_sector = '31';
    END IF;		
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '240208040303' THEN
        LET va_sector = '11';
    END IF;
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub)||trim(va_sector) = '14029025000000' THEN
        LET psuccta = '9201';
    END IF;
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '140295040100' THEN
        LET psuccta = '5001';
    END IF;
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '140290140101' THEN
        LET psuccta = '5005';
    END IF;
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '140290141101' THEN
        LET psuccta = '5005';
    END IF;
	
	IF ptransacc IN('0273', '0276', '0277') AND va_ccmayor = '2101' THEN
	   --- LET psucope = vsuccta;
       LET psuccta = vsuccta;
	END IF;

    insert into aux_auditerr values
    (pempresa,va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector,v_auxiliar,pproducto,ptransacc,pmonto_tot);	
	
    -- // Para cuentas de enlace..
    IF va_ccmayor[1,2] = "95" THEN 
        insert into sc_contab_temp values
        (pempresa, w_secuencia, psucope, psucope, va_ccmayor, va_ccsub, va_ccsubsub, 
         va_ccsssub, va_ccssssub, va_sector, v_auxiliar, 0, pmonto_tot, pmoneda, pdescripcion);
    ELSE -- // Para el resto de las cuentas...
        insert into sc_contab_temp values
        (pempresa, w_secuencia, psucope, psuccta, va_ccmayor, va_ccsub, va_ccsubsub,
         va_ccsssub, va_ccssssub, va_sector, v_auxiliar, 0, pmonto_tot, pmoneda, pdescripcion);
    END IF;

    end;

	IF ( ((SELECT COUNT(*) FROM tmp_si_catalog 
	                    WHERE empresa = pempresa 
						  AND ccmayor = va_ccmayor 
						  AND ccsub = va_ccsub
						  AND ccsubsub = va_ccsubsub
						  AND ccssubsub = va_ccsssub
						  AND ccsssubsub = va_ccssssub
						  AND sector = va_sector ) > 0) 
		AND
		  ((SELECT COUNT(*) FROM tmp_si_catalog 
	                    WHERE empresa = pempresa 
						  AND ccmayor = vc_ccmayor 
						  AND ccsub = vc_ccsub
						  AND ccsubsub = vc_ccsubsub
						  AND ccssubsub = vc_ccsssub
						  AND ccsssubsub = vc_ccssssub
						  AND sector = vc_sector ) > 0)						  
						  ) THEN
	
		INSERT INTO bdicheq:sc_contab		
		SELECT empresa,secuencia,sucursal,succta,ccmayor,ccsub,ccsubsub,     
					ccssubsub,ccsssubsub,sector,auxiliar,tot_cargo,tot_abono,moneda,descripcion 
			   FROM sc_contab_temp;
		
	ELSE
	
        IF vsc_contab_temp = 'T' THEN
	
			DROP TABLE sc_contab_temp;
			LET vsc_contab_temp = 'F';
		
		END IF
		
		CALL sp_suspenso(pempresa,'01',pmonto_tot,psecuencia,psucope,psuccta,pcancelad,pproducto,pmoneda,ptransacc,psector,
		                 case when pdescripcion = 'ABSPEIWU' OR pdescripcion = 'ABSPEIBTS' OR pdescripcion = 'ABSPEIAPP' then 'ABSPEI' else pdescripcion end ,vfecha_hoy) 

        RETURNING vcodret,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,
                          va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector;

		INSERT INTO bdicheq:sc_contab 
		     VALUES (pempresa, w_secuencia, psucope, psuccta, vc_ccmayor, vc_ccsub, vc_ccsubsub,
                     vc_ccsssub, vc_ccssssub, vc_sector, v_auxiliar, pmonto_tot, 0, pmoneda, pdescripcion );
		
		INSERT INTO bdicheq:sc_contab 
			 VALUES (pempresa, w_secuencia, psucope, psuccta, va_ccmayor, va_ccsub, va_ccsubsub,
					va_ccsssub, va_ccssssub, va_sector, v_auxiliar, 0, pmonto_tot, pmoneda, pdescripcion);
		
	END IF;
	
	IF vsc_contab_temp = 'T' THEN
	
		DROP TABLE sc_contab_temp;
		LET vsc_contab_temp = 'F';
		
	END IF
	
    return vcodret;

end procedure;