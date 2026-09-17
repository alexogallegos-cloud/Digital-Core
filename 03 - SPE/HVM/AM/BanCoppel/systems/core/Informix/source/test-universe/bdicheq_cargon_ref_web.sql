CREATE PROCEDURE "informix".cargon_ref_web(pempresa     char(3),
                                       psucursal    char(4),
                                       pusuario     char(8),
                                       ptransacc    char(4),
                                       ptransuc     char(4),
                                       pfolsuc      char(16),
                                       pcuenta      char(20),
                                       pcheque      integer,
                                       pmonto       money(14,2),
                                       pdivisa      char(2),
                                       preferencia  char(40),
                                       pnum_tarjeta char(16),
                                       pusuautoriza char(8))
returning char(5),char(4);

    define vfecha_hoy       date;
    define vfecha_proc      date;
    define vchrFechaValor   date;
    define vfechacalendario date;
    define vfecultmov       date;
    define vfechaccc        date;
    define vFechaDev        date;
    define vvaldoc          char(1);
    define vnaturaleza      char(1);
    define vval_chequeras   char(1);
    define vexiste          char(1);
    define vaceptab         char(1);
    define vstatus_cta      char(1);
    define vacepcargo       char(1);
    define vestado          char(1);
    define vcolat           char(1);
    define vsobregira       char(1);
    define vacepta_retpar   char(1);
    define vacepta_retiros  char(1);
    define vper_retiros     char(1);
    define vcancelacta      char(1);
    define vCobComChqExp    char(1);
    define vind_dispon      char(1);
    define vmoneda          char(2);
    define vmotivo          char(2);
    define vtipo_tran       char(2);
    define vsuccta          char(4);
    define vproducto        char(4);
    define vtrancancta      char(4);
    define vtrancomcan      char(4);
    define vtranretpar      char(4);
    define vtranret         char(4);
    define vtrandevobco     char(4);
    define vtrandevbcoop    char(4);
    define vComxChqExp      char(4);
    define vTrxCargoConcen  char(4);
    define vcodret          char(5);
    define vcodret2         char(5);
    define cCodRetIndicador	char(6);
    define vusuario         char(8); 
    define vctacol          char(20);
    define vdescerr         char(50);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vcheque          integer;
    define vultche          integer;
    define vchqexp          smallint;
    define vtotcol          smallint;
    define vdiasret         smallint;
    define vdiasultret      smallint;
    define vChqExpMes       smallint;
    define vChqsLibCom      smallint;
    define vIntChqDev       smallint;
    define vChqDev          smallint;
    define vexistlimsbg     smallint;
    define vmonto           money(14,2);
    define vimpsbg          money(14,2);
    define vimpccc          money(14,2);
    define vabono_eje       money(14,2);
    define vsaldo_fin       money(14,2);
    define vsaldo_col       money(14,2);
    define vsdorestar       money(14,2);
    define vsdo_actual      money(14,2);
    define vdisponible      money(14,2);
    define vretenido        money(14,2);
    define vcongelado       money(14,2);
    define vlimccc          money(14,2);
    define vdispccc         money(14,2);
    define vreqccc          money(14,2);
    define vutilccc         money(14,2);
    define vsdodisp         money(14,2);
    define vlimite_sbg      money(14,2);
    define vimp_acum_sbg    money(14,2);
    define vtasa_aplicada   decimal(9,6);
    define vfecha_operacion date; 
	define vcodret1         CHAR(5);
	define vfechaHabil		DATE;
    define vnum_cte         char(20);
    define vchrFechaVal     char(10);
    define vEsFisica        char(1);
    define iExiste          smallint;
    define vbitacora_dup    smallint;
    define vexist_reg       smallint;
    
    DEFINE cSucursal    CHAR(4);
    DEFINE cFechHora    CHAR(12);
    DEFINE cTransacc    CHAR(60);
    DEFINE cCalle       CHAR(100);
    DEFINE cNumExt      CHAR(6);
    DEFINE cCiudad      CHAR(60);
    DEFINE cEstado      CHAR(30);
    DEFINE cCuenta      VARCHAR(20);
    DEFINE cDirSucursal VARCHAR(200);
    DEFINE cHora        CHAR(8);
    DEFINE cTransaccion VARCHAR(60);
    DEFINE cMensaje     CHAR(150);
    DEFINE cCodRetMsj   CHAR(5);
    DEFINE cReferencia  CHAR(40);
    DEFINE cCajero      CHAR(6);
    DEFINE cCanal       CHAR(10);
    DEFINE cLatitud     VARCHAR(10);
    DEFINE cLongitud    VARCHAR(11);
    DEFINE cColonia     CHAR(35);
    DEFINE dtFechAlt    DATE;
    DEFINE cInfReceptor VARCHAR(40);
    DEFINE iMensaje     SMALLINT;
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    DEFINE mSaldoSbc       MONEY(14,2);
    
    let vfecha_hoy       = '';
    let vfecha_proc      = '';
    let vchrFechaValor   = '';
    let vfechacalendario = '';
    let vfecultmov       = '';
    let vfechaccc        = '';
    let vFechaDev        = '';
    let vvaldoc          = '';
    let vnaturaleza      = '';
    let vval_chequeras   = '';
    let vexiste          = '';
    let vaceptab         = '';
    let vstatus_cta      = '';
    let vacepcargo       = '';
    let vestado          = '';
    let vcolat           = '';
    let vsobregira       = '';
    let vacepta_retpar   = '';
    let vacepta_retiros  = '';
    let vper_retiros     = '';
    let vcancelacta      = '';
    let vCobComChqExp    = '';
    let vind_dispon      = '';
    let vmoneda          = '';
    let vmotivo          = '';
    let vtipo_tran       = '';
    let vsuccta          = '';
    let vproducto        = '';
    let vtrancancta      = '';
    let vtrancomcan      = '';
    let vtranretpar      = '';
    let vtranret         = '';
    let vtrandevobco     = '';
    let vtrandevbcoop    = '';
    let vComxChqExp      = '';
    let vTrxCargoConcen  = '';
    let vcodret          = '';
    let vcodret2         = '';
    let cCodRetIndicador = '';
    let vusuario         = '';
    let vctacol          = '';
    let vdescerr         = '';
    let vcodret3         = '';
    let vsqlerr          = 0;
    let visamerr         = 0;
    let vcheque          = 0;
    let vultche          = 0;
    let vchqexp          = 0;
    let vtotcol          = 0;
    let vdiasret         = 0;
    let vdiasultret      = 0;
    let vChqExpMes       = 0;
    let vChqsLibCom      = 0;
    let vIntChqDev       = 0;
    let vChqDev          = 0;
    let vexistlimsbg     = 0;
    let vmonto           = 0;
    let vimpsbg          = 0;
    let vimpccc          = 0;
    let vabono_eje       = 0;
    let vsaldo_fin       = 0;
    let vsaldo_col       = 0;
    let vsdorestar       = 0;
    let vsdo_actual      = 0;
    let vdisponible      = 0;
    let vretenido        = 0;
    let vcongelado       = 0;
    let vlimccc          = 0;
    let vdispccc         = 0;
    let vreqccc          = 0;
    let vutilccc         = 0;
    let vsdodisp         = 0;
    let vlimite_sbg      = 0;
    let vimp_acum_sbg    = 0;
    let vtasa_aplicada   = 0;
	let vfecha_operacion = TODAY;
    LET vcodret1         = "00000";
    let vnum_cte         = '';
    let vchrFechaVal     = '';
    let vEsFisica        = '';
    let iExiste          = 0;
    let vbitacora_dup    = 0;
    let vexist_reg    = 0;
    
    LET cSucursal    = '';
    LET cFechHora    = '';
    LET cTransacc    = '';
    LET cCalle       = '';
    LET cNumExt      = '';
    LET cCiudad      = '';
    LET cEstado      = '';
    LET cCuenta      = '';
    LET cDirSucursal = '';
    LET cHora        = '';
    LET cMensaje     = '';
    LET cCodRetMsj   = '';
    LET cReferencia  = '';
    LET cCajero      = '';
    LET cCanal       = '';
    LET cLatitud     = '';
    LET cLongitud    = '';
    LET cColonia     = '';
    LET dtFechAlt    = '';
    LET cInfReceptor = '';
    LET iMensaje     = 0;
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    LET mSaldoSbc           = 0;

    begin

    on exception set vsqlerr, visamerr, vdescerr
        --set debug file to "/tmp/cargon_ref.err";
        --trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret, vtranret;
        end if;
    end exception;
    
    --- set debug file to "/tmp/cargon_ref.out";
    --- trace on;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    let vreqccc          = 0;
    let vcodret          = '000';
    let vtranret         = ptransacc;
    let vtipo_tran       = '';
    let vind_dispon      = '0';
    let vtasa_aplicada   = 0.000000;
    let cCodRetIndicador = '000000';

    if ( ( psucursal is null or psucursal = " " ) or 
         ( pusuario  is null or pusuario  = " " ) or 
         ( ptransacc is null or ptransacc = " " ) or
         ( pcuenta   is null or pcuenta   = " " ) or 
         ( pfolsuc   is null or pfolsuc   = " " ) or 
         ( pcheque   is null or pcheque   < 0   ) or
         ( pmonto    is null or pmonto    = 0   ) ) then
        let vcodret = '110';
        return vcodret, vtranret;
    end if;
    
    if psucursal <> "5005" then --- SI LA SUCURSAL ES CORRESPONSALES NO VALIDA EL USUARIO
        select ejecutivo 
          into vusuario
          from bdinteg:si_ejecut
         where ejecutivo = pusuario;
   
        if vusuario <> pusuario or vusuario is null then
            let vcodret = "106";
            return vcodret,vtranret;
        end if
    end if

    select numero,naturaleza,valida_docto,sobregira, tipo_tran
      into vtranret,vnaturaleza,vvaldoc,vsobregira, vtipo_tran
      from bdinteg:si_transacc
     where empresa = pempresa 
       and numero = ptransacc
       and sistema = '01'
       and naturaleza = 'C';

    if ptransacc != vtranret or vtranret is null then
        let vcodret = "550";
        return vcodret,vtranret;
    end if;

    if vnaturaleza != "C" then
        let vcodret = "560";
        return vcodret,vtranret;
    end if;

    if vvaldoc = "S" and (pcheque is null or pcheque = 0) then
        let vcodret = "110";
        return vcodret,vtranret;
    end if;

    select valor 
      into vtranretpar
      from sc_param
     where empresa = pempresa 
       and codparam = "tranretpar";
   
    select valor
      into vTrxCargoConcen
      from sc_param
     where empresa = pempresa
       and codparam = 'TrxCgoCtaConcentrada';

    select fecha_hoy, ind_disponible 
      into vfechacalendario,  vind_dispon 
      from sc_fechas 
     where empresa = pempresa;
     
    if vind_dispon = '0' then
        let vcodret = "004";
        return vcodret,vtranret;
    end if;

    select fecha_proceso, status_cta, producto
      into vfecha_hoy, vstatus_cta, vproducto
      from sc_maechq
     where cuenta = pcuenta;
    
    if vproducto = "1300" or vproducto = "1400" or vproducto = "1700" or vproducto = "2700" then
        if (ptransacc = "3220" or ptransacc = "0260") and (pmonto is null or pmonto = 0) then
            let vcodret = "000";
            return vcodret,vtranret;
        end if;
    end if;  

    if vproducto in("1100", "2300") and ptransacc = "0223" then
        let vcodret = "962";
        return vcodret,vtranret;
    end if;
	
	if vproducto in("1100", "2300") and ptransacc = "0402" then
        let vcodret = "100";
        return vcodret,vtranret;
    end if;
  
   	if vproducto = '2300' and ptransacc = '0239' and ptransuc <> '0000' then
	   let vcodret = "962";
       return vcodret, vtranret;
    end if    
  
    if (vfecha_hoy is null or vstatus_cta = '4' or vstatus_cta = '8' or vstatus_cta = '5') then
        let vfecha_hoy = vfechacalendario;
    end if

    if (vfecha_hoy < vfechacalendario ) then
        let vcodret = "549";
        return  vcodret,vtranret;
    end if
  
    if vstatus_cta in ("2","6","7") then
        let vcodret = "200";
        return vcodret,vtranret;
    end if;
    
    -- // OBTIENE LA FECHA SPEI PARA TRANSACCION 0274 y 0447
    if ptransacc in('0274', '0447') then
		IF CURRENT HOUR TO fraction > '17:58:00' AND CURRENT HOUR TO fraction < '18:05:00' THEN
			CALL bdispei:"informix".sp_validafecha(pEmpresa, vfecha_hoy)
			RETURNING vcodret1, vfechaHabil;
			LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');
		ELSE
			SELECT vchrvalor
		      INTO vchrFechaVal
			  FROM bdispei:tblparametros
			WHERE vchrcveparametro = 'FECHA_OPERACION';
            
            LET vchrFechaValor = SUBSTR(vchrFechaVal,4,2)||'/'||SUBSTR(vchrFechaVal,1,2)||'/'||SUBSTR(vchrFechaVal,7,4);
		END IF;
    else
        LET vchrFechaValor= vfecha_hoy;
	end if;
   
    -- // VALIDACION PARA CUENTAS CON STATUS 8 - ART 61 LIC
    if ( vstatus_cta = '8' and ptransacc not in('0223','0320','0270', '0252','0402') ) then
        let vcodret = "200";
        return vcodret,vtranret;
    end if;
    
    foreach
        -- RQM 09 704. Se agrega la variable del saldo inmovilizado para el consumo del spl sp_cons_sdodisp_x_tpcalculo. DFTL
        select sucursal,producto,ult_chq,colateral,status_cta,motivo,sdo_actual,lim_sbg_ccc,imp_sbg_ccc,
               fech_venc_ccc,sdo_retenido,sdo_cong,fec_ult_mov, chq_exp_mes, fecha_proceso, num_cte, saldo_sbc
          into vsuccta,vproducto,vultche,vcolat,vstatus_cta,vmotivo,vsdo_actual,vlimccc,vutilccc,
               vfechaccc,vretenido,vcongelado,vfecultmov, vChqExpMes, vfecha_proc, vnum_cte, mSaldoSbc
          from sc_maechq
         where cuenta = pcuenta
         
        if vretenido < 0 then
            let vretenido = vretenido * -1;
        end if;
        
        if vcongelado < 0 then
            let vcongelado = vcongelado * -1;
        end if;
        
        if vsuccta is null then
            let vcodret = "100";
            return vcodret,vtranret;
        end if;

        if vstatus_cta in ("2","6","7") then
            let vcodret = "200";
            return vcodret,vtranret;
        elif vstatus_cta = '5' then
            SELECT cargo 
              INTO vacepcargo 
              FROM sc_bloqueo
             WHERE codigo = vmotivo;

            IF vacepcargo = "N" THEN
                LET vcodret = "300";
                RETURN vcodret,vtranret;
            END IF;
        else
            -- // Verifica el tipo de bloqueo de la cuenta.....
            IF vstatus_cta = "3" THEN
                IF ptransacc <> '0830' AND ptransacc <> '0887' THEN
                    SELECT "1" 
                      INTO vexiste
                      FROM sc_ctabloqueo 
                     WHERE cuenta = pcuenta;

                    IF vexiste = "1" THEN      
                        SELECT opcion 
                          INTO vaceptab
                          FROM sc_ctabloqueo 
                         WHERE cuenta = pcuenta;

                        IF vaceptab = 4 OR vaceptab = 3 THEN
                            LET vcodret = "300";
                            RETURN vcodret,vtranret;
                        END IF;
                    ELSE
                        SELECT cargo 
                          INTO vacepcargo 
                          FROM sc_bloqueo
                         WHERE codigo = vmotivo;

                        IF vacepcargo = "N" THEN
                            LET vcodret = "300";
                            RETURN vcodret,vtranret;
                        END IF;
                    END IF;
                END IF;
            END IF;
        end if;
        
        select divisa,val_chequeras,acepta_retiros,per_retiros[1,1],per_retiros[3,5],acepta_retpar, cancelacta
          into vmoneda,vval_chequeras,vacepta_retiros,vper_retiros,vdiasret, vacepta_retpar,vcancelacta
          from sc_producto
         where empresa = pempresa 
           and producto = vproducto;

        if vmoneda != pdivisa then
            let vcodret = "951";
            return vcodret,vtranret;
        end if;

        if vacepta_retiros = "N" then
            select valor 
              into vtrancancta
              from sc_param
             where empresa = pempresa 
               and codparam = "trancancta";           

            select valor 
              into vtrancomcan
              from sc_param
             where empresa = pempresa 
               and codparam = "trancomcan";
      
            select valor 
              into vtrandevobco
              from sc_param
             where empresa = pempresa 
               and codparam = "trandevobco";
             
            select valor 
              into vtrandevbcoop
              from sc_param
             where empresa = pempresa 
               and codparam = "trandevbcoop";
             
            if ( ( ptransacc <> vtranretpar   or vtranretpar   is null ) and
                 ( ptransacc <> vtrancancta   or vtrancancta   is null ) and
                 ( ptransacc <> vtrandevobco  or vtrandevobco  is null ) and
                 ( ptransacc <> vtrandevbcoop or vtrandevbcoop is null ) and
                 ( ptransacc <> vtrancomcan   or vtrancomcan   is null ) ) then
                let vcodret = '957';
                return vcodret, vtranret;
            end if
        else
            IF vper_retiros = "U" AND pmonto <> (vsdo_actual - vretenido - vcongelado - mSaldoSbc) then
                let vcodret = "420";
                return vcodret,vtranret;
            END IF
           
            if ( vstatus_cta = '8' and pmonto <> (vsdo_actual - vretenido - vcongelado - mSaldoSbc) ) then
                let vcodret = "420";
                return vcodret,vtranret;
            end if
         
            let vdiasultret = vfecha_hoy - vfecultmov;
          
            if vdiasultret < 0 then
                let vdiasultret = 0;
            end if
           
            if vdiasultret < vdiasret then
                let vcodret = "957";
                return vcodret,vtranret;
            end if
        end if

        if vval_chequeras = "S" and vvaldoc = "S" then
            if pcheque > vultche then
                let vcodret = "520";
                return vcodret,vtranret;
            end if;
        end if;
      
        -- Inicia Validaciones de Chequeras Gpo PISA 270110 --
        IF vvaldoc = "S" then
            SELECT valor 
              INTO vCobComChqExp 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "cobcomchqexp";

            select valor
              into vChqsLibCom
              from bdicntchq:sq_param
             where cod_param = 1; 

            SELECT valor 
              INTO vComxChqExp 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "comxchqexp";
             
            SELECT valor 
              INTO vIntChqDev 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "intentoschqdev";

            IF vCobComChqExp NOT IN ('S','N') OR vCobComChqExp IS NULL THEN
                LET vcodret = "705";
                LET vtranret = ptransacc;
                RETURN vcodret,vtranret;
            END IF

            SELECT {+INDEX(sc_contch idx_contch2)}
                   numero,estado
              INTO vcheque,vestado
              FROM sc_contch
             WHERE empresa = pempresa
               AND cuenta = pcuenta
               AND numero = pcheque;

            IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                LET vcodret = "500";
                LET vtranret = ptransacc;
                RETURN vcodret,vtranret;
            END IF
          
            IF ( vestado = 'P' ) then -- Pagado
                LET vcodret = '600';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'E' OR vestado = 'S' ) THEN -- Cheque No Activado
                LET vcodret = '500';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'R' ) THEN -- Revocado (Suspendido)
                LET vcodret = '700';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'J' ) THEN -- Bloqueado Judicial
                LET vcodret = '701';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'B' ) THEN -- Bloqueado Autoridades
                LET vcodret = '702';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'F' ) THEN -- Fraudulento
                LET vcodret = '703';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'C' ) THEN -- Cancelado
                LET vcodret = '704';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            END IF;
        END IF; -- Termina Validaciones para chequeras

        let vdispccc = vlimccc - vutilccc;
      
        if vfechaccc < vfecha_hoy or vdispccc is null then
            let vdispccc = 0;
        end if
       
        let vdisponible = vsdo_actual - vretenido - vcongelado - mSaldoSbc + vdispccc;
        
        if vdisponible < 0 then
            let vdisponible = 0.00;
        end if;

        if vsdo_actual = pmonto and ptransacc = vtranretpar then
            let vcodret = "002";
            let vtranret = ptransacc;
            return vcodret,vtranret;
        end if

        if vsobregira = "S"  and pmonto > vdisponible then
            select count(*)
              into vexistlimsbg
              from sc_limite_sbg
             where cuenta = pcuenta;
             
            if ( vexistlimsbg > 0 ) then
                select limite_sbg, imp_acum_sbg
                  into vlimite_sbg, vimp_acum_sbg
                  from sc_limite_sbg
                 where cuenta = pcuenta;
                 
                if ( ( pmonto + vimp_acum_sbg ) > ( vdisponible + vlimite_sbg ) ) then
                    let vcodret = '400';
                    let vtranret = ptransacc;
                    return vcodret, vtranret;
                end if;
            end if;
            
            let vreqccc = pmonto - (vsdo_actual - vretenido - vcongelado);          
            
            if vdispccc >= vreqccc then
                let vimpccc = vreqccc;
                let vimpsbg = 0;
            else
                let vimpccc = vdispccc;
                let vimpsbg = vreqccc - vdispccc;
            end if
          
            if vimpccc > 0 then
                insert into sc_movdia values
                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),"3240",vsuccta,vproducto,pempresa,pcuenta,"  ",
                 pcheque,vimpccc,vimpccc,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
				 
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3240",vimpccc,vfecha_hoy,"A")
				INTO cCodRetIndicador;
            end if
          
            if vimpsbg > 0 then
                insert into sc_movdia values
                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),"3357",vsuccta,vproducto,pempresa,pcuenta,"  ",
                 pcheque,vimpsbg,vimpsbg,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
                 
                update sc_limite_sbg
                   set imp_acum_sbg = imp_acum_sbg + vimpsbg
                 where cuenta = pcuenta;
				 
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3357",vimpsbg,vfecha_hoy,"A")
				INTO cCodRetIndicador;
            end if               

            insert into sc_movdia values
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),ptransacc,vsuccta,vproducto,pempresa,pcuenta,"  ",
             pcheque,pmonto,0,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
           
            if vvaldoc = "S" then
                update {+INDEX(sc_contch idx_contch2)} sc_contch
                   set estado = "P",
                       fecha_alta = vfecha_hoy,
                       importe = pmonto
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and numero = pcheque;
                 
                let vchqexp = 1;
            else
                let vchqexp = 0; 
            end if
            
            if (vtipo_tran in('00','30') and ptransacc <> vTrxCargoConcen) then
                update sc_maechq
                   set sdo_actual     = sdo_actual - vdisponible + vdispccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vimpccc,
                       imp_chq_sbg    = imp_chq_sbg + vimpsbg,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fec_ult_mov    = vfecha_hoy,
                       fecultret      = vfecha_hoy
                 where cuenta = pcuenta;
            else
                update sc_maechq
                   set sdo_actual     = sdo_actual - vdisponible + vdispccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vimpccc,
                       imp_chq_sbg    = imp_chq_sbg + vimpsbg,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fec_ult_mov    = vfecha_hoy
                 where cuenta = pcuenta;
            end if;
     
            -- // Actualiza Cuentas Inactivas e Informadas (Status 4 y 5)
            IF ( vstatus_cta IN('4','5') AND vtipo_tran in('00','30') ) THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE cuenta = pcuenta;
            END IF;

            -- Valida Comision por Cheque Expedido Gpo PISA 270110 --
            IF vvaldoc = "S" then
                IF vCobComChqExp = "S" THEN
                    IF vChqsLibCom < vChqExpMes + 1 THEN
                        CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                        RETURNING vcodret;
                       
                        IF vcodret <> "000" THEN
                            LET vtranret = ptransacc;
                            RETURN vcodret,vtranret;
                        END IF
                    END IF
                END IF
            END IF

            let vtranret = ptransacc;
            let vcodret = "000";
			
			-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
			EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
			INTO cCodRetIndicador;
			
            return vcodret,vtranret;
        end if

        if pmonto > vdisponible then        
           
            if vvaldoc = "S" then
                -- // Siempre se cobra la comision
                call gencomdev(pempresa,pcuenta,ptransacc,pcheque,pfolsuc,pmonto,"1",psucursal,pusuario,pdivisa)
                returning vcodret;

                IF vcodret = "000" THEN
                    LET vcodret = "400"; --//Debe retornar forndos insuficientes
                END IF

                -- // Valida Comision por Cheque Expedido Axl'10 270110 --
                IF vvaldoc = "S" then
                    IF vCobComChqExp = "S" THEN
                        IF vChqsLibCom < vChqExpMes + 1 THEN
                            CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                            RETURNING vcodret;
                            
                            IF vcodret <> "000" THEN
                                LET vtranret = ptransacc;
                                RETURN vcodret,vtranret;
                            END IF
                        END IF
                    END IF
                END IF
                      
                SELECT COUNT(*), MAX(fecha)
                  INTO vChqDev, vFechaDev
                  FROM sc_chequedev
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta
                   AND fecha <= vfecha_hoy
                   AND numerochq = pcheque;

                IF (vChqDev +1) > vIntChqDev THEN
                    LET vcodret = "400";
                    LET vtranret = ptransacc;
                    RETURN vcodret,vtranret;
                END IF

                IF vFechaDev = vfecha_hoy  THEN
                    LET vcodret = "400";
                    LET vtranret = ptransacc;
                    RETURN vcodret,vtranret;
                END IF
            end if

            IF vcodret = "000" THEN --//Fondos Insuficientes
                let vcodret = "400";
            END IF
               
            let vtranret = ptransacc;
            return vcodret,vtranret;
            
        else
            
			if ptransacc in ('0223')  then
				--//parametro bitacora TX duplicadas
				select valor
				into  vbitacora_dup
				from bdinteg:si_param  
				where  cod_param = 515;
            
				--//validar registro existente
				select {+index(idx_movdia2a)} 
                       count(*)
				into vexist_reg
				from sc_movdia
				where empresa = pempresa and folio_suc = pfolsuc and sucursal = psucursal and usuario = pusuario and transacc = ptransacc and suc_cuen = vsuccta 
				and cuenta = pcuenta and monto_tot = pmonto and transacc_suc = ptransacc and num_tarjeta = pnum_tarjeta;
            
				if vexist_reg = 0 then
					insert into sc_movdia values
					(0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),ptransacc,vsuccta,vproducto,pempresa,pcuenta," ",
					pcheque,pmonto,0,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
             
					if ptransacc = '0223' then                
						insert into sc_retirosefectivo values
						(vfecha_hoy, current hour to fraction(3), pfolsuc, ptransacc, vnum_cte, pcuenta, psucursal, vsuccta, pmonto);										   
                    end if
				else
					if vbitacora_dup = 1 then
						insert into bitacora_dup values 
						(pfolsuc,psucursal,pusuario,ptransacc,vsuccta,pcuenta,pmonto,ptransuc,vfecha_operacion, current hour to fraction(3));                    																																	 
					end if
					return vcodret, vtranret;
					
				end if
			
			
			else
			
				insert into sc_movdia values
                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),ptransacc,vsuccta,vproducto,pempresa,pcuenta," ",
                 pcheque,pmonto,0,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
             
                 if ptransacc = '0223' then                
                    insert into sc_retirosefectivo values
                    (vfecha_hoy, current hour to fraction(3), pfolsuc, ptransacc, vnum_cte, pcuenta, psucursal, vsuccta, pmonto);
                 end if            
            end if
			
            
            if vvaldoc = "S" then
                let vchqexp = 1;    
                    
                update {+INDEX(sc_contch idx_contch2)} sc_contch
                   set estado  = "P",
                       fecha_alta = vfecha_hoy,
                       importe = pmonto
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and numero = pcheque;
            else
                let vchqexp = 0;
            end if
           
            if (vtipo_tran in('00','30') and ptransacc <> vTrxCargoConcen) then
                update sc_maechq
                   set sdo_actual     = sdo_actual - pmonto + vreqccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vreqccc,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       fec_ult_mov    = vfecha_hoy,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fecultret      = vfecha_hoy
                 where cuenta = pcuenta;
            else
                update sc_maechq
                   set sdo_actual     = sdo_actual - pmonto + vreqccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vreqccc,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       fec_ult_mov    = vfecha_hoy,
                       chq_exp_mes    = chq_exp_mes + vchqexp
                 where cuenta = pcuenta;
            end if;
            
            -- // INSERTA EN TABLA PARA ENVIO DE MENSAJES (CUB)
            select tpo.es_fisica
              into vEsFisica
              from bdinteg:si_cliente cte,
                   bdinteg:si_tipper tpo
             where cte.numcte = vnum_cte
               and tpo.tpo_persona = cte.tpo_persona;
            
            if vEsFisica = 'S' then
                select {+index(sc_transacc_cub idx_transacc_cub_trx)}
                       count(*) 
                  into iExiste
                  from sc_transacc_cub
                 where transacc = ptransuc;
                 
                if iExiste > 0 then
                    insert into sc_notif_cub_vent
                    (sucursal, transacc, transacc_suc, numcte, cuenta, num_tarjeta, monto_tot, folio_suc, estatus)
                    values
                    (psucursal, ptransacc, ptransuc, vnum_cte, pcuenta, pnum_tarjeta, pmonto, pfolsuc, '0');
                end if;
            end if;
            
            -- // Actualiza Cuentas Inactivas e Informadas (Status 4 y 5)
            IF ( vstatus_cta IN('4','5') AND vtipo_tran in('00','30') ) THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE cuenta = pcuenta;
            END IF;

            -- Valida Comision por Cheque Expedido Axl'10 270110 --
            IF vvaldoc = "S" then
                IF vCobComChqExp = "S" THEN
                    IF vChqsLibCom < vChqExpMes + 1 THEN
                        CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                        RETURNING vcodret;
                    
                        IF vcodret <> "000" THEN
                            LET vtranret = ptransacc;
                            RETURN vcodret,vtranret;
                        END IF
                    END IF
                END IF
            END IF
            
        end if;

        -- // Para acumular en sc_tarjeta
        update sc_tarjeta
           set disp_mes = nvl(disp_mes,0) + pmonto
         where empresa = pempresa
           and cuenta  = pcuenta
           and num_tarjeta = pnum_tarjeta;

        -- // Cancela la cuenta al retiro del monto
        IF ( vper_retiros = 'U' AND vcancelacta = 'S' ) OR ( vstatus_cta  = '8' AND ptransacc IN('0223','0270', '0252', '0402') ) THEN
            UPDATE sc_maechq
               SET status_cta = '2', 
                   fec_cancelac = vfechacalendario, 
                   motivo = '02'
             WHERE cuenta = pcuenta;
        END IF
    end foreach
    
    let vcodret = "000";
    let vtranret = ptransacc;

	-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
	EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
	INTO cCodRetIndicador;
    
    /*
    IF pcuenta = '10057557465' THEN 
        SELECT mov.sucursal, mov.fech_hor, mov.transacc||' '||trx.descripcion, mov.referencia, mov.fech_alt
          INTO cSucursal, cFechHora, cTransacc, cReferencia, dtFechAlt
          FROM sc_movdia mov, 
               bdinteg:si_transacc trx
         WHERE mov.cuenta = pcuenta 
           AND mov.folio_suc = pfolsuc
           AND trx.numero = mov.transacc
           AND trx.sistema = '01';
           
        IF ptransacc IN('0223','0274','0239') THEN
            
            LET cCanal = 'SUC: '||cSucursal;
            LET iMensaje = 1;
            
        ELIF ptransacc = '0952' THEN
            
            LET cCajero = SUBSTR(cReferencia, 16, 6);
            
            SELECT sucursal
              INTO cSucursal
              FROM sc_cajeros
             WHERE id = cCajero;
             
            LET cCanal = 'ATM: '||cSucursal;
            LET iMensaje = 1;
            
        ELIF ptransacc IN('0249','0259','0402','0403','0405','0406') THEN
            
            LET cSucursal = SUBSTR(pfolsuc,1,4);
            LET cCanal = 'CPL: '||cSucursal;
            LET iMensaje = 1;
            
        ELIF ptransacc = '0801' THEN
            
            SELECT FIRST 1 mov2.infreceptor 
              INTO cInfReceptor
              FROM sc_movdia mov1, 
                   intercard:movimiento mov2
             WHERE mov1.cuenta = pcuenta
               AND mov1.folio_suc = pfolsuc
               AND mov2.numtarjeta = mov1.num_tarjeta
               AND mov2.secuenciaextendida = SUBSTR(mov1.folio_suc,2,15)
               AND mov2.prodind = '02'
               AND mov1.transacc = ptransacc
               AND ( ( DATE(mov2.fechahorainauth) = mov1.fech_oper ) OR DATE(mov2.fechahoraoutauth) = mov1.fech_oper )
               AND mov1.fech_alt = dtFechAlt;
        
            LET cCanal = 'POS';
            LET iMensaje = 2;
            
        ELIF ptransacc = '0871' THEN
            
            SELECT FIRST 1 mov2.infreceptor 
              INTO cInfReceptor
              FROM sc_movdia mov1, 
                   intercard:movimiento mov2
             WHERE mov1.cuenta = pcuenta
               AND mov1.folio_suc = pfolsuc
               AND mov2.numtarjeta = mov1.num_tarjeta
               AND mov2.secuenciaextendida = SUBSTR(mov1.folio_suc,2,15)
               AND mov2.prodind = '01'
               AND mov1.transacc = ptransacc
               AND ( ( DATE(mov2.fechahorainauth) = mov1.fech_oper ) OR DATE(mov2.fechahoraoutauth) = mov1.fech_oper )
               AND mov1.fech_alt = dtFechAlt;
            
            LET cCanal = 'ATE';
            LET iMensaje = 2;
            
        ELSE 
            
            LET cCanal = 'NOI';
            LET iMensaje = 3;
            
        END IF;
           
           
        IF iMensaje = 1 THEN
            
            SELECT FIRST 1 ptf.latitud, ptf.longitud, col.nombrezona, ciu.nombre, edo.nombre
              INTO cLatitud, cLongitud, cColonia, cCiudad, cEstado
              FROM bdinteg:si_ptf ptf,
                   bdinteg:si_catzonas col,
                   bdinteg:si_ciudades ciu,
                   bdinteg:si_estados edo
             WHERE ptf.id_ptf = cSucursal
               AND ( ptf.cve_ciudad is not null OR ptf.cve_ciudad <> '' )
               AND col.codigopostalzona = ptf.cp
               AND ciu.ciudad = ptf.cve_ciudad
               AND ciu.estado = ptf.cve_estado
               AND edo.estado = ciu.estado;
              
            LET cMensaje = 'GEO: '||TRIM(cLatitud)||', '||TRIM(cLongitud)||' '||'DOM: '||TRIM(cColonia)||', '||TRIM(cCiudad)||', '||TRIM(cEstado)||' '||TRIM(cCanal);
            
        ELIF iMensaje = 2 THEN
            
            LET cMensaje = TRIM(cInfReceptor)||', '||TRIM(cCanal);
            
        ELIF iMensaje = 3 THEN
        
            LET cMensaje = TRIM(cCanal);
        
        END IF;
        
        
        INSERT INTO sc_movs_verif VALUES(pcuenta, pfolsuc, cMensaje);
          
        
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','',cMensaje,'','','','','','','6672140698',1,0,0,0,0,'','') 
        INTO cCodRetMsj; 
        
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','',cMensaje,'','','','','','','5534666055',1,0,0,0,0,'','') 
        INTO cCodRetMsj; 
        
    END IF;
    */
	
    return vcodret, vtranret;

    end;

end procedure
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/01',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2';

create procedure "informix".cargon_ref_pos(pempresa     char(3),
                                       psucursal    char(4),
                                       pusuario     char(8),
                                       ptransacc    char(4),
                                       ptransuc     char(4),
                                       pfolsuc      char(16),
                                       pcuenta      char(20),
                                       pcheque      integer,
                                       pmonto       money(14,2),
                                       pdivisa      char(2),
                                       preferencia  char(40),
                                       pnum_tarjeta char(16),
                                       pusuautoriza char(8),
									   preferencia23 CHAR(23))
returning char(5),char(4);

    define vsqlerr                      int;
    define vmoneda                      char(2);
    define vmonto,vimpsbg,
    vimpccc,vabono_eje                  money(14,2);
    define vvaldoc,vnaturaleza,
    vval_chequeras                      char(1);
    define vsuccta                      char(4);
    define vexiste                      char(1);
    define vaceptab                     char(1);
    define vproducto                    char(4);
    define vcodret                      char(5);
    define vhorax                       char(12);
    define vfecha_hoy, vfecha_proc      date;
    define vfechacalendario             date;
    define vchqexp                      smallint;
    define vtrancancta,vtrancomcan,
    vtranretpar,vtranret                char(4);
    define vcheque,vultche              int;
    define vctacol                      char(20);
    define vstatus_cta,vacepcargo,
    vestado,vcolat                      char(1);
    define vmotivo                      char(2);
    define vsaldo_fin,vsaldo_col,
    vsdorestar,vsdo_actual              money(14,2);
    define vlimccc,vdispccc,
    vretenido,vcongelado,
    vdisponible                         money(14,2);
    define vreqccc,vutilccc,vsdodisp    money(14,2);
    define vfecultmov                   date;
    define vfechaccc                    date;
    define vtotcol                      smallint;
    define vusuario                     char(8);
    define vtasa_aplicada               decimal(9,6);
    define vsobregira                   char(1);
    define vacepta_retpar,
    vacepta_retiros,vper_retiros        char(1);
    define vdiasret,vdiasultret,i       smallint;
    define vtrandevobco                 char(4);
    define vtrandevbcoop                char(4);
    define vcancelacta                  char(1);
    --- define vprod                        char(4);
    DEFINE vChqExpMes                   SMALLINT; -- Gpo PISA 270110
    DEFINE vCobComChqExp                CHAR(1);  -- Gpo PISA 270110
    DEFINE vChqsLibCom                  SMALLINT; -- Gpo PISA 270110
    DEFINE vComxChqExp                  CHAR(4);  -- Gpo PISA 270110
    DEFINE vIntChqDev                   SMALLINT; -- Gpo PISA 270110
    DEFINE vChqDev                      SMALLINT; -- Gpo PISA 270110
    DEFINE vFechaDev			        DATE;     -- Gpo PISA 270110
    DEFINE vtipo_tran                   CHAR(2);
    DEFINE vTrxCargoConcen              CHAR(4);
	
	DEFINE cCodRetIndicador				CHAR(6);
	DEFINE vFechaOperacion			    DATE;
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    DEFINE cCodRetConsSdo               CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo           CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    DEFINE mSaldoSbc                    MONEY(14,2);
    DEFINE mSdoDisponible               MONEY(14,2);

	
	LET cCodRetIndicador  = "000000";
	LET vFechaOperacion	= TODAY;
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';
    LET mSaldoSbc        =0;
    LET mSdoDisponible      = 0;
  
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

   --SET DEBUG FILE TO "/home/c90402536/Traza/cargon_ref_pos_modif_ori.out";
   --TRACE ON; 

    begin

    on exception set vsqlerr
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            return vcodret,vtranret;
        end if;
    end exception;

    let vtranret = ptransacc;
    let vtasa_aplicada = 0;
    let vcodret = "000";
    --- let vprod = substr(pcuenta, 1, 4);
    LET vreqccc = 0;
    LET vtipo_tran = '';

    if psucursal is null or pusuario is null or ptransacc is null or
       pcuenta is null or pfolsuc is null or pcheque is null or
       psucursal = " " or pusuario = " " or ptransacc = " " or
       pcuenta = " " or pfolsuc = " " or pmonto = 0 or pmonto is null then
        let vcodret = "110";
        return vcodret,vtranret;
    end if;

    select ejecutivo 
      into vusuario
      from bdinteg:si_ejecut
     where ejecutivo = pusuario;
   
    if vusuario <> pusuario or vusuario is null then
        let vcodret = "106";
        return vcodret,vtranret;
    end if

    select numero,naturaleza,valida_docto,sobregira, tipo_tran
      into vtranret,vnaturaleza,vvaldoc,vsobregira, vtipo_tran
      from bdinteg:si_transacc
     where empresa = pempresa 
       and numero = ptransacc;

    if ptransacc != vtranret or vtranret is null then
        let vcodret = "550";
        return vcodret,vtranret;
    end if;

    if vnaturaleza != "C" then
        let vcodret = "560";
        return vcodret,vtranret;
    end if;

    if vvaldoc = "S" and (pcheque is null or pcheque = 0) then
        let vcodret = "110";
        return vcodret,vtranret;
    end if;

    select valor 
      into vtranretpar
      from sc_param
     where empresa = pempresa 
       and codparam = "tranretpar";
   
    select valor
      into vTrxCargoConcen
      from sc_param
     where empresa = pempresa
       and codparam = 'TrxCgoCtaConcentrada';

    select {+INDEX(sc_fechas idx_fechas1)} 
           fecha_hoy 
      into vfechacalendario 
      from sc_fechas 
     where empresa = pempresa;

    select fecha_proceso, status_cta, producto
      into vfecha_hoy, vstatus_cta, vproducto
      from sc_maechq
     where empresa = pempresa
       and cuenta = pcuenta;
    
    if vproducto = "1300" or vproducto = "1400" or vproducto = "1700" then
        if (ptransacc = "3220" or ptransacc = "0260") and (pmonto is null or pmonto = 0) then
            let vcodret = "000";
            return vcodret,vtranret;
        end if;
    end if;  

    if vproducto in("1100", "2300") and ptransacc = "0223" then
        let vcodret = "962";
        return vcodret,vtranret;
    end if;
  
    if (vfecha_hoy is null or vstatus_cta = '4' or vstatus_cta = '8' or vstatus_cta = '5') then
        let vfecha_hoy = vfechacalendario;
    end if

    if (vfecha_hoy < vfechacalendario ) then
        let vcodret = "549";
        return  vcodret,vtranret;
    end if
  
    if vstatus_cta in ("2","6","7") then
        let vcodret = "200";
        return vcodret,vtranret;
    end if;
   
    -- // VALIDACION PARA CUENTAS CON STATUS 8 - ART 61 LIC

    if vstatus_cta = '8' and ( ptransacc <> "0223" and ptransacc <> "0320" ) then
        let vcodret = "200";
        return vcodret,vtranret;
    end if;
   
    foreach
        -- RQM 09 704. Se agrega la variable del saldo inmovilizado para el consumo del spl sp_cons_sdodisp_x_tpcalculo. DFTL
        select sucursal,producto,ult_chq,colateral,status_cta,motivo,sdo_actual,lim_sbg_ccc,imp_sbg_ccc,
               fech_venc_ccc,sdo_retenido,sdo_cong,fec_ult_mov, chq_exp_mes, fecha_proceso, saldo_sbc
          into vsuccta,vproducto,vultche,vcolat,vstatus_cta,vmotivo,vsdo_actual,vlimccc,vutilccc,
               vfechaccc,vretenido,vcongelado,vfecultmov, vChqExpMes, vfecha_proc, mSaldoSbc
          from sc_maechq
         where empresa = pempresa 
           and cuenta = pcuenta

        if vsuccta is null then
            let vcodret = "100";
            return vcodret,vtranret;
        end if;

        if vstatus_cta in ("2","6","7") then
            let vcodret = "200";
            return vcodret,vtranret;
        else
            -- // Verifica el tipo de bloqueo de la cuenta.....
            IF vstatus_cta = "3" THEN
                IF ptransacc <> '0830' AND ptransacc <> '0887' THEN
                    SELECT "1" 
                      INTO vexiste
                      FROM sc_ctabloqueo 
                     WHERE cuenta = pcuenta;

                    IF vexiste = "1" THEN      
                        SELECT opcion 
                          INTO vaceptab
                          FROM sc_ctabloqueo 
                         WHERE cuenta = pcuenta;

                        IF vaceptab = 4 THEN
                            LET vcodret = "300";
                            RETURN vcodret,vtranret;
                        END IF;

                        IF vaceptab = 3 THEN
                            LET vcodret = "300";
                            RETURN vcodret,vtranret;
                        END IF;
                    ELSE
                        SELECT cargo 
                          INTO vacepcargo 
                          FROM sc_bloqueo
                         WHERE codigo = vmotivo;

                        IF vacepcargo = "N" THEN
                            LET vcodret = "300";
                            RETURN vcodret,vtranret;
                        END IF;
                    END IF;
                END IF;
            END IF;
        end if;
        
        select divisa,val_chequeras,acepta_retiros,per_retiros[1,1],per_retiros[3,5],acepta_retpar, cancelacta
          into vmoneda,vval_chequeras,vacepta_retiros,vper_retiros,vdiasret, vacepta_retpar,vcancelacta
          from sc_producto
         where empresa = pempresa 
           and producto = vproducto;

        if vmoneda != pdivisa then
            let vcodret = "951";
            return vcodret,vtranret;
        end if;

        if vacepta_retiros = "N" then
            select valor 
              into vtrancancta
              from sc_param
             where empresa = pempresa 
               and codparam = "trancancta";           

            select valor 
              into vtrancomcan
              from sc_param
             where empresa = pempresa 
               and codparam = "trancomcan";
      
            select valor 
              into vtrandevobco
              from sc_param
             where empresa = pempresa 
               and codparam = "trandevobco";
             
            select valor 
              into vtrandevbcoop
              from sc_param
             where empresa = pempresa 
               and codparam = "trandevbcoop";
             
            if (ptransacc <> vtranretpar or vtranretpar is null) and
               (ptransacc <> vtrancancta or vtrancancta is null) and
               (ptransacc <> vtrandevobco or vtrandevobco is null) and
               (ptransacc <> vtrandevbcoop or vtrandevbcoop is null) and
               (ptransacc <> vtrancomcan or vtrancomcan is null) then
                let vcodret = "957";
                return vcodret,vtranret;
            end if
        else
            --RQM 09 704. Se executa el siguiente SP para el calculo del saldo disponible DFTL 
            EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vsdo_actual, vretenido, vcongelado, mSaldoSbc, null, null, null, 'F', '2') 
            INTO cCodRetConsSdo, cMensajeRetConsSdo, mSdoDisponible; 

            IF vper_retiros = "U" AND pmonto <> (mSdoDisponible) then
                let vcodret = "420";
                return vcodret,vtranret;
            END IF
           
            if ( vstatus_cta = '8' and pmonto <> mSdoDisponible ) then
                let vcodret = "420";
                return vcodret,vtranret;
            end if
         
            let vdiasultret = vfecha_hoy - vfecultmov;
          
            if vdiasultret < 0 then
                let vdiasultret = 0;
            end if
           
            if vdiasultret < vdiasret then
                let vcodret = "957";
                return vcodret,vtranret;
            end if
        end if

        if vval_chequeras = "S" and vvaldoc = "S" then
            if pcheque > vultche then
                let vcodret = "520";
                return vcodret,vtranret;
            end if;
        end if;
      
        -- Inicia Validaciones de Chequeras Gpo PISA 270110 --
        IF vvaldoc = "S" then
            SELECT valor 
              INTO vCobComChqExp 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "cobcomchqexp";
            
            /* ##############################
            SELECT valor 
              INTO vChqsLibCom 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "cheqslibcom";
            ############################## */

            select valor
              into vChqsLibCom
              from bdicntchq:sq_param
             where cod_param = 1; 

            SELECT valor 
              INTO vComxChqExp 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "comxchqexp";
             
            SELECT valor 
              INTO vIntChqDev 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "intentoschqdev";

            IF vCobComChqExp NOT IN ('S','N') OR vCobComChqExp IS NULL THEN
                LET vcodret = "705";
                LET vtranret = ptransacc;
                RETURN vcodret,vtranret;
            END IF

            SELECT {+INDEX(sc_contch idx_contch2)}
                   numero,estado
              INTO vcheque,vestado
              FROM sc_contch
             WHERE empresa = pempresa
               AND cuenta = pcuenta
               AND numero = pcheque;

            IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                LET vcodret = "500";
                LET vtranret = ptransacc;
                RETURN vcodret,vtranret;
            END IF
          
            IF vestado="P" then -- Pagado
                LET vcodret="600";
                LET vtranret=ptransacc;
                RETURN vcodret,vtranret;
            ELIF vestado = "E" OR vestado = "S" THEN -- Cheque No Activado
                LET vcodret="500";
                LET vtranret=ptransacc;
                RETURN vcodret,vtranret;
            ELIF vestado = "R" THEN -- Revocado (Suspendido)
                LET vcodret="700";
                LET vtranret=ptransacc;
                RETURN vcodret,vtranret;
            ELIF vestado = "J" THEN -- Bloqueado Judicial
                LET vcodret="701";
                LET vtranret=ptransacc;
                RETURN vcodret,vtranret;
            ELIF vestado = "B" THEN -- Bloqueado Autoridades
                LET vcodret="702";
                LET vtranret=ptransacc;
                RETURN vcodret,vtranret;
            ELIF vestado = "F" THEN -- Fraudulento
                LET vcodret="703";
                LET vtranret=ptransacc;
                RETURN vcodret,vtranret;
            ELIF vestado = "C" THEN -- Cancelado
                LET vcodret="704";
                LET vtranret=ptransacc;
                RETURN vcodret,vtranret;
            END IF;
        END IF; -- Termina Validaciones para chequeras

        let vdispccc = vlimccc - vutilccc;
      
        if vfechaccc < vfecha_hoy or vdispccc is null then
            let vdispccc = 0;
        end if
       
        --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
        EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vsdo_actual, vretenido, vcongelado, mSaldoSbc, null, vlimccc, vutilccc, 'F', '2') 
        INTO cCodRetConsSdo, cMensajeRetConsSdo, vdisponible; 

        let vdisponible = vdisponible + vdispccc;

        if vsdo_actual = pmonto and ptransacc = vtranretpar then
            let vcodret = "002";
            let vtranret = ptransacc;
            return vcodret,vtranret;
        end if

        if vsobregira = "S"  and pmonto > vdisponible then
            let vreqccc = pmonto - (vsdo_actual - vretenido - vcongelado);          
            if vdispccc >= vreqccc then
                let vimpccc = vreqccc;
                let vimpsbg = 0;
            else
                let vimpccc = vdispccc;
                let vimpsbg = vreqccc - vdispccc;
            end if
          
            if vimpccc > 0 then
                let vhorax = current hour to fraction(3);             
                insert into sc_movdia values
                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhorax,"3240",vsuccta,vproducto,pempresa,pcuenta,"  ",
                 pcheque,vimpccc,vimpccc,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,preferencia23,vFechaOperacion);
				 
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3240",vimpccc,vfecha_hoy,"C")
				INTO cCodRetIndicador;
            end if
          
            if vimpsbg > 0 then
                let vhorax = current hour to fraction(3);               
                insert into sc_movdia values
                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhorax,"3357",vsuccta,vproducto,pempresa,pcuenta,"  ",
                 pcheque,vimpsbg,vimpsbg,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,preferencia23,vFechaOperacion);
				 
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3357",vimpsbg,vfecha_hoy,"C")
				INTO cCodRetIndicador;
            end if           

            let vhorax = current hour to fraction(3);           

            insert into sc_movdia values
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhorax,ptransacc,vsuccta,vproducto,pempresa,pcuenta,"  ",
             pcheque,pmonto,0,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,preferencia23,vFechaOperacion);
           
            if vvaldoc = "S" then
                update {+INDEX(sc_contch idx_contch2)} sc_contch
                   set estado = "P",
                       fecha_alta = vfecha_hoy,
                       importe = pmonto
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and numero = pcheque;
                 
                let vchqexp = 1;
            else
                let vchqexp = 0; 
            end if
            
            --- if vtipo_tran in('00','30') then
            if (vtipo_tran in('00','30') and ptransacc <> vTrxCargoConcen) then
                update sc_maechq
                   set sdo_actual     = sdo_actual - vdisponible + vdispccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vimpccc,
                       imp_chq_sbg    = imp_chq_sbg + vimpsbg,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fec_ult_mov    = vfecha_hoy,
                       fecultret      = vfecha_hoy
                 where empresa = pempresa 
                   and cuenta = pcuenta;
            else
                update sc_maechq
                   set sdo_actual     = sdo_actual - vdisponible + vdispccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vimpccc,
                       imp_chq_sbg    = imp_chq_sbg + vimpsbg,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fec_ult_mov    = vfecha_hoy
                 where empresa = pempresa 
                   and cuenta = pcuenta;
            end if;
             
            /* #########################################################################################
            -- // Actualiza Cuentas Inactivas (Status 4)
            IF vstatus_cta = '4' AND vtipo_tran in('00','30') AND vfecha_proc = vfechacalendario THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
            END IF;
            ######################################################################################### */
     
            -- // Actualiza Cuentas Inactivas e Informadas (Status 4 y 5)
            IF ( vstatus_cta IN('4','5') AND vtipo_tran in('00','30') ) THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
            END IF;

            -- Valida Comision por Cheque Expedido Gpo PISA 270110 --
            IF vvaldoc = "S" then
                IF vCobComChqExp = "S" THEN
                    IF vChqsLibCom < vChqExpMes + 1 THEN
                        CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                        RETURNING vcodret;
                       
                        IF vcodret <> "000" THEN
                            LET vtranret = ptransacc;
                            RETURN vcodret,vtranret;
                        END IF
                    END IF
                END IF
            END IF

            let vtranret = ptransacc;
            let vcodret = "000";
			
			-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
			EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
			INTO cCodRetIndicador;
			
            return vcodret,vtranret;
        end if

        if pmonto > vdisponible then        
            /* -- inicio se inhibe codigo para permitir traspaso entre cuentas colaterales 10-FEB-2010 -- */
            /* #############################################################################################################################################
			if vcolat = "S" then
                call total_colateral(pempresa,pcuenta) 
                returning vsaldo_col,vtotcol;              
                let vsaldo_fin = vdisponible + vsaldo_col;              
                if pmonto > vsaldo_fin then
                    if vvaldoc = "S" then
                        SELECT COUNT(*), MAX(fecha)
                          INTO vChqDev, vFechaDev
                          FROM sc_chequedev
                         WHERE empresa = pempresa
                           AND cuenta = pcuenta
                           AND fecha <= vfecha_hoy
                           AND numerochq = pcheque;

                        IF (vChqDev +1) > vIntChqDev THEN
                            LET vcodret = "400";
                            LET vtranret = ptransacc;
                            RETURN vcodret,vtranret;
                        END IF

                        IF vFechaDev = vfecha_hoy  THEN
                            LET vcodret = "400";
                            LET vtranret = ptransacc;
                            RETURN vcodret,vtranret;
                        END IF

                        CALL gencomdev(pempresa,pcuenta,ptransacc,pcheque,pfolsuc,pmonto,"1",psucursal, pusuario, pdivisa)
                        RETURNING vcodret;
                    END IF
                   
                    IF vcodret <> "000" THEN -- Gpo PISA 270110
                        let vcodret = "400";
                    END IF
                   
                    let vtranret = ptransacc;
                    return vcodret,vtranret;
                else
                    let vsdorestar = pmonto - vdisponible;
                    let vabono_eje = vsdorestar;                 
                    for i= 1 to 10
                        call sdoind_col(pempresa,pcuenta,i)
                        returning vsaldo_col,vctacol;
                      
                        if vsaldo_col >0 then
                            if vsdorestar > vsaldo_col then
                                call cargon_ref(pempresa,psucursal,pusuario,"3325",ptransuc,pfolsuc,vctacol,0,vsaldo_col,pdivisa," ",pnum_tarjeta,pusuautoriza)
                                returning vcodret,vtranret;                             
                                let vhorax = current hour to fraction(3);                               
                                insert into sc_movdia values
                                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,current hour to fraction(3),"3278",vsuccta,vproducto,pempresa,pcuenta,"  ",
                                 pcheque,vsaldo_col, vsaldo_col,0,0,0," ","2",0,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,'',vFechaOperacion);                               
                                let vsdorestar = vsdorestar - vsaldo_col;
                            else
                                call cargon_ref(pempresa,psucursal,pusuario,"3325",ptransuc,pfolsuc,vctacol,0,vsdorestar,pdivisa," ",pnum_tarjeta,pusuautoriza)
                                returning vcodret,vtranret;                               
                                let vhorax = current hour to fraction(3);                               
                                insert into sc_movdia values
                                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,current hour to fraction(3),"3278",vsuccta,vproducto,pempresa,pcuenta," ",
                                 pcheque,vsdorestar,vsdorestar,0,0,0," ","2",0,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,'',vFechaOperacion);                               
                                exit for;
                            end if;
                        end if;
                    end for;
                   
                    let vhorax = current hour to fraction(3);
                  
                    if vdispccc > 0 then
                        let i = i + 1;
                        let vhorax = current hour to fraction(3);                      
                        insert into sc_movdia values
                        (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhorax,"3240",vsuccta,vproducto,pempresa,pcuenta,"  ",
                         pcheque,vdispccc,vdispccc,0,0,0," "," ",vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,'',vFechaOperacion);
                    end if;
                  
                    let vhorax = current hour to fraction(3);                   
                    insert into sc_movdia values
                    (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhorax,ptransacc,vsuccta,vproducto,pempresa,pcuenta,
                     "  ",pcheque,pmonto,0,0,0,0," "," ",vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,'',vFechaOperacion);
                    
                    if vvaldoc = "S" then
                        update sc_contch
                           set estado  = "P",
                               fecha_alta = vfecha_hoy,
                               importe = pmonto
                         where empresa = pempresa 
                           and cuenta = pcuenta 
                           and numero = pcheque;                          
                        let vchqexp = 1;
                    else
                        let vchqexp = 0;
                    end if
                    
                    update sc_maechq
                       set sdo_actual     = vretenido + vcongelado,
                           fec_ult_mov    = vfecha_hoy,
                           imp_sbg_ccc    = imp_sbg_ccc+vdispccc,
                           imp_cgos_mes   = imp_cgos_mes + pmonto,
                           num_cgos_mes   = num_cgos_mes + 1,
                           imp_abonos_mes = imp_abonos_mes+vabono_eje+vdispccc,
                           num_abonos_mes = num_abonos_mes + i,
                           chq_exp_mes    = chq_exp_mes + vchqexp
                     where empresa = pempresa 
                       and cuenta = pcuenta;

                    -- Valida Comision por Cheque Expedido Axl'10 270110 --
                    IF vvaldoc = "S" then
                        IF vCobComChqExp = "S" THEN
                            IF vChqsLibCom < vChqExpMes + 1 THEN
                                CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                                RETURNING vcodret;
                                
                                IF vcodret <> "000" THEN
                                    LET vtranret = ptransacc;
                                    RETURN vcodret,vtranret;
                                END IF
                            END IF
                        END IF
                    END IF
                      
                    let vcodret = "000";
                    let vtranret = ptransacc;
                    return vcodret,vtranret;
                end if;
            else
            ############################################################################################################################################# */
            /* -- fin se inhibe codigo para permitir traspaso entre cuentas colaterales 10-FEB-2010 -- */
           
                if vvaldoc = "S" then
                    -- // Siempre se cobra la comision
                    call gencomdev(pempresa,pcuenta,ptransacc,pcheque,pfolsuc,pmonto,"1",psucursal,pusuario,pdivisa)
                    returning vcodret;

                    IF vcodret = "000" THEN
                        LET vcodret = "400"; --//Debe retornar forndos insuficientes
                    END IF

                    -- // Valida Comision por Cheque Expedido Axl'10 270110 --
                    IF vvaldoc = "S" then
                        IF vCobComChqExp = "S" THEN
                            IF vChqsLibCom < vChqExpMes + 1 THEN
                                CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                                RETURNING vcodret;
                                
                                IF vcodret <> "000" THEN
                                    LET vtranret = ptransacc;
                                    RETURN vcodret,vtranret;
                                END IF
                            END IF
                        END IF
                    END IF
                          
                    SELECT COUNT(*), MAX(fecha)
                      INTO vChqDev, vFechaDev
                      FROM sc_chequedev
                     WHERE empresa = pempresa
                       AND cuenta = pcuenta
                       AND fecha <= vfecha_hoy
                       AND numerochq = pcheque;

                    IF (vChqDev +1) > vIntChqDev THEN
                        LET vcodret = "400";
                        LET vtranret = ptransacc;
                        RETURN vcodret,vtranret;
                    END IF

                    IF vFechaDev = vfecha_hoy  THEN
                        LET vcodret = "400";
                        LET vtranret = ptransacc;
                        RETURN vcodret,vtranret;
                    END IF
                    --- call gencomdev(pempresa,pcuenta,ptransacc,pcheque,pfolsuc,pmonto,"1",psucursal,pusuario,pdivisa)
                    --- returning vcodret;
                end if

                IF vcodret = "000" THEN --//Fondos Insuficientes
                    let vcodret = "400";
                END IF
                   
                let vtranret = ptransacc;
                return vcodret,vtranret;
        --- end if;  se inhibe codigo para permitir traspaso entre cuentas colaterales 21-01-2010
        else
            /* -- Codigo COmentado por Gpo PISA 270110 -- */
            /* ######################################################################################################################
            let vsdodisp = vsdo_actual - vretenido - vcongelado;
            let vreqccc = 0;
            if pmonto > vsdodisp then
                let vreqccc = pmonto - vsdodisp;
                let vhorax = current hour to fraction(3);               
                insert into sc_movdia values
                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhorax,"3240",vsuccta,vproducto,pempresa,pcuenta," ",
                 pcheque,vreqccc,vreqccc,0,0,0," "," ",vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,'',vFechaOperacion);
            end if;
            ###################################################################################################################### */
           
            let vhorax = current hour to fraction(3);           
            insert into sc_movdia values
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhorax,ptransacc,vsuccta,vproducto,pempresa,pcuenta," ",
             pcheque,pmonto,0,0,0,0, " ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,preferencia23,vFechaOperacion);
           
            if vvaldoc = "S" then
                let vchqexp = 1;               
                update {+INDEX(sc_contch idx_contch2)} sc_contch
                   set estado  = "P",
                       fecha_alta = vfecha_hoy,
                       importe = pmonto
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and numero = pcheque;
            else
                let vchqexp = 0;
            end if
           
            --- if vtipo_tran in('00','30') then
            if (vtipo_tran in('00','30') and ptransacc <> vTrxCargoConcen) then
                update sc_maechq
                   set sdo_actual     = sdo_actual - pmonto + vreqccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vreqccc,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       fec_ult_mov    = vfecha_hoy,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fecultret      = vfecha_hoy
                 where empresa = pempresa 
                   and cuenta = pcuenta;
            else
                update sc_maechq
                   set sdo_actual     = sdo_actual - pmonto + vreqccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vreqccc,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       fec_ult_mov    = vfecha_hoy,
                       chq_exp_mes    = chq_exp_mes + vchqexp
                 where empresa = pempresa 
                   and cuenta = pcuenta;
            end if;
               
            /* #########################################################################################
            -- // Actualiza Cuentas Inactivas (Status 4)
            IF vstatus_cta = '4' AND vtipo_tran in('00','30') AND vfecha_proc = vfechacalendario THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
            END IF;
            ######################################################################################### */
            
            -- // Actualiza Cuentas Inactivas e Informadas (Status 4 y 5)
            IF ( vstatus_cta IN('4','5') AND vtipo_tran in('00','30') ) THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
            END IF;

            -- Valida Comision por Cheque Expedido Axl'10 270110 --
            IF vvaldoc = "S" then
                IF vCobComChqExp = "S" THEN
                    IF vChqsLibCom < vChqExpMes + 1 THEN
                        CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                        RETURNING vcodret;
                    
                        IF vcodret <> "000" THEN
                            LET vtranret = ptransacc;
                            RETURN vcodret,vtranret;
                        END IF
                    END IF
                END IF
            END IF
            --- return vcodret,vtranret;
        end if;
        
        /* #############################################
        -- // Para acumular en sc_tarjeta
        update sc_tarjeta
           set disp_mes = nvl(disp_mes,0) + pmonto
         where empresa = pempresa
           and cuenta  = pcuenta
           and num_tarjeta = pnum_tarjeta;
        ############################################# */

        -- // Cancela la cuenta al retiro del monto
        IF ( vper_retiros = 'U' AND vcancelacta = 'S' ) OR ( vstatus_cta  = '8' AND ptransacc = '0223' ) THEN
            UPDATE sc_maechq
               SET status_cta = '2', fec_cancelac = vfechacalendario, motivo = '02'
             WHERE empresa = pempresa
               AND cuenta = pcuenta;
        END IF
    end foreach
   
    --- let vcodret = "100";
    let vcodret = "000";
    let vtranret = ptransacc;
	
	-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
	EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
	INTO cCodRetIndicador;

    return vcodret, vtranret;

    end;

end procedure
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/01',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2';

create procedure "informix".bajasaldos()
       returning char(5),char(20),char(1),char(4),money(14,2);

   define vcodret     char(5);
   define vsqlerr     integer;
   define vcuenta     char(20);
   define vsdodisp    money(14,2);
   define vstatus_cta char(1);
   define vproducto   char(4);
   define vempresa    char(3);
   define vmotivo     char(2);
   define rstatus_cta char(1);
   define vacepcargo  char(1);

   let vcodret    = "000";
   let vcuenta    = " ";
   let vstatus_cta = " ";
   let vproducto = " ";
   let vsdodisp   =  0;
   let vmotivo    = " ";
   let rstatus_cta = " ";

   begin
      on exception set vsqlerr
         if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vcuenta,vstatus_cta,vproducto,vsdodisp;
         end if
      end exception;


   select empresa into vempresa
      from bdinteg:si_ejecut
      where ejecutivo = user;

   foreach
      --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP
      select unique s.cuenta,s.status_cta,s.producto,s.sdo_actual-s.sdo_retenido-s.sdo_cong-s.saldo_sbc,motivo
         into vcuenta,vstatus_cta,vproducto,vsdodisp,vmotivo
         from sc_maechq as s, sc_tarjeta as t
         where s.empresa = vempresa
	 and t.cuenta = s.cuenta
      order by s.cuenta
      if vstatus_cta = "3" then
         select cargo into vacepcargo from sc_bloqueo
            where codigo = vmotivo;
         if vacepcargo = "N" then
--            let vcodret = "300";
--            return vcodret,vtranret;
	    let rstatus_cta = "3";
         else
	    let rstatus_cta = "1";
         end if;
      else
	 let rstatus_cta = vstatus_cta;
      end if;
      return vcodret,vcuenta,rstatus_cta,vproducto,vsdodisp with resume;
   end foreach
end
end procedure

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 10-06-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para considerar un nuevo campo',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

create procedure "informix".cierre_diarioqra(pempresa char(3),
                                             pdias integer,
                                             pcuenta char(20))

returning char(5);

-- ***********************************************************************
-- *                                                                     
-- * cierre_diarioqra                                                   
-- * Version              1.0.0                                        
-- * Obejtivo:            Calcula saldos acumulados para cierre diario producto 1900
-- * Creado por:                                                     
-- * ModIFicado por:      Alejandro Rueda Sanchez                   
-- * Ultima Modificacion: Junio 2010
-- *                     Creaciï¿½n de SPL                          
-- *                                                             
-- ***********************************************************************

--//DEFINICION DE VARIABLES 
DEFINE global vgrausuario         char(8)         default " ";
DEFINE global vgracuenta          char(20)        default " ";
DEFINE global vgrasucursal        char(4)         default " ";
DEFINE global vgrasdo_actual      money(14,2)     default 0;
DEFINE global vgraacum_sdo_pos    money(14,2)     default 0;
DEFINE global vgradia_sdo_pos     smallint        default 0;
DEFINE global vgraproducto        char(4)         default " ";
DEFINE global vgrastatus_cta      char(1)         default " ";
DEFINE global vgrapaga_interes    char(1)         default " ";
DEFINE global vgramto_pag_int     money(14,2)     default 0;
DEFINE global vgratasa            char(8)         default " ";
DEFINE global vgrasobretasa       decimal(9,6)    default 0;
DEFINE global vgratp_moneda       char(2)         default " ";
DEFINE global vgraes_fisica       char(1)         default " ";
DEFINE global vgraexento_isr      char(1)         default " ";
DEFINE global vgratipo_dias_calc  char(1)         default " ";
DEFINE global vgrapago_interes    char(1)         default " ";
DEFINE global vgratipo_anio_calc  char(1)         default " ";
DEFINE global vgrafecha_hoy       date            default " ";
DEFINE global vgrafecha_pago      date            default " ";
DEFINE global vgranum_cte         char(20)        default " ";
DEFINE global vgradias_acum_int   integer         default 0;
DEFINE global vgraacum_sdo_int    money(14,2)     default 0;
DEFINE global vgrafecha_alta      date            default "";
DEFINE GLOBAL vgraTasaVar         CHAR(1)         DEFAULT "";
DEFINE GLOBAL vgraFechaProc       DATE	        DEFAULT "";
DEFINE GLOBAL vgraProdCreciente   CHAR(4)         DEFAULT " ";
DEFINE GLOBAL vgraint_acum        DECIMAL(14,2)   DEFAULT 0;
DEFINE GLOBAL vgrasdo_disp        DECIMAL(14,2)   DEFAULT 0;
DEFINE GLOBAL vgrapri_hab_mes     DATE            DEFAULT " ";
    DEFINE GLOBAL vgrapri_dia_mes     DATE            DEFAULT " ";
DEFINE GLOBAL vgrafecha_mod       DATE            DEFAULT " ";
    DEFINE GLOBAL vgrasdo_retenido    DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgrasdo_cong        DECIMAL(14,2)   DEFAULT 0;

DEFINE vsdo_prom     money(14,2);
DEFINE vcodret       char(5);
DEFINE vsqlerr       integer;
DEFINE vcobraisr     char(1);
DEFINE vfecpagoint   datetime month to day;
DEFINE vultpagoint   date;
DEFINE isam_err      SMALLINT;
DEFINE error_info    CHAR(40);
DEFINE vsdo_cong     DECIMAL(14,2);
DEFINE vsdo_retenido DECIMAL(14,2);
DEFINE vmotivo       CHAR(2);
	--RQM 09 704. Se crea la siguiente variable . DHG
	DEFINE mSaldoSBC  			MONEY; 		--Obtiene el saldo_sbc de la maestra de cheques

    LET vcodret  = "000";
	--RQM 09 704. Se inicializa la siguiente variable generada. DHG
	LET mSaldoSBC				=0.00;

    begin

    on exception 
        set vsqlerr, isam_err, error_info
        	SET DEBUG FILE TO "cierrediarioqra.err";
        	TRACE ON;
        IF vsqlerr <> 0 then
            LET vcodret = vsqlerr;
            return vcodret;
        END if;
    END exception;

    set isolation to dirty read;
	--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc. DHG
	SELECT mc.cuenta,      mc.num_cte,    mc.sucursal,    acum_sdo_pos,
           dia_sdo_pos,    status_cta,    pr.paga_interes,tasa,
           sobretasa,      divisa,        es_fisica,      exento_isr,
           tipo_dias_calc, pago_interes,  tipo_anio_calc, mto_pag_int,
           mc.producto,    sdo_actual,    mc.cobraisr,    fecpagoint,
           ultpagoint,     mn.fecha_alta, pr.paga_dividENDo, mc.fecha_proceso,
           acum_sdo_int,   int_acum,      sdo_cong,        sdo_retenido,
           dias_acum_int,  mc.motivo, mc.sdo_cong, mc.sdo_retenido, mc.saldo_sbc
      INTO vgracuenta,        vgranum_cte,     vgrasucursal,      vgraacum_sdo_pos,
           vgradia_sdo_pos,   vgrastatus_cta,  vgrapaga_interes,  vgratasa,
           vgrasobretasa,     vgratp_moneda,   vgraes_fisica,     vgraexento_isr,
           vgratipo_dias_calc,vgrapago_interes,vgratipo_anio_calc,vgramto_pag_int,
           vgraproducto,      vgrasdo_actual,  vcobraisr,       vfecpagoint,
           vultpagoint,     vgrafecha_alta,  vgraTasaVar,       vgraFechaProc,
           vgraacum_sdo_int,  vgraint_acum,    vsdo_cong,       vsdo_retenido,
           vgradias_acum_int, vmotivo, vgrasdo_cong, vgrasdo_retenido, mSaldoSBC
      FROM sc_maechq mc,
           sc_maenoc mn,
           sc_producto pr,
           bdinteg:si_cliente cl,
           bdinteg:si_tipper tp
     WHERE mc.empresa = pempresa 
       AND mc.cuenta = pcuenta
       AND status_cta not in("0","2","8","9")
       AND mn.empresa = mc.empresa
       AND mn.cuenta = mc.cuenta
       AND pr.empresa = mc.empresa
       AND pr.producto = mc.producto
       AND cl.numcte = mc.num_cte
       AND tp.tpo_persona = cl.tpo_persona;

    IF vcobraisr <> "" then
        IF vcobraisr = "S" then
            LET vgraexento_isr = "N";
        ELSE
            LET vgraexento_isr = "S";
        END if
    END if

    IF vgrapaga_interes is null then
        LET vgrapaga_interes = "N";
    END if

    IF vgramto_pag_int is null then
        LET vgramto_pag_int = 0;
    END if

    -- // Verifica si es el primer dia del mes, inicializa saldo interes acumulado
--  IF ( DAY(vgrapri_hab_mes) = DAY(vgrafecha_hoy) ) AND ( vgrapri_hab_mes <> '01'||'02'||YEAR(vgrafecha_hoy) ) THEN
    IF DAY(vgrapri_hab_mes) = DAY(vgrafecha_hoy)   THEN
        LET vgradias_acum_int = pdias;
        LET vgraint_acum = vgraacum_sdo_int;
        LET vgraacum_sdo_int = 0;
        LET vgradia_sdo_pos = vgradia_sdo_pos + pdias;
        LET vgraacum_sdo_pos = vgraacum_sdo_pos + vgrasdo_actual * pdias;
--    ELIF ( DAY(vgrapri_hab_mes) = DAY(vgrafecha_hoy) ) AND ( vgrapri_hab_mes = '01'||'02'||YEAR(vgrafecha_hoy) ) THEN
--        LET vgradias_acum_int = vgradias_acum_int + pdias;
--        LET vgraint_acum = 0;
--        LET vgraacum_sdo_int = vgraacum_sdo_int;
--        LET vgradia_sdo_pos = vgradia_sdo_pos + pdias;
--        LET vgraacum_sdo_pos = vgraacum_sdo_pos + vgrasdo_actual * pdias;
    ELSE -- // Dias del acumulado de intereses
        LET vgradias_acum_int = vgradias_acum_int + pdias;
        LET vgradia_sdo_pos = vgradia_sdo_pos + pdias;
        LET vgraacum_sdo_pos = vgraacum_sdo_pos + vgrasdo_actual * pdias;
    END IF

    -- // Si la cuenta es empresarial especial, toma el saldo disponible compLETo
    IF vmotivo = '99' THEN
		--RQM 09 704. Se agrega la variable mSaldoSBC en el calculo de saldo disponible. DHG
        LET vgrasdo_disp = vgrasdo_actual - vgrasdo_retenido - mSaldoSBC;
    ELSE
		--RQM 09 704. Se agrega la variable mSaldoSBC en el calculo de saldo disponible. DHG
        LET vgrasdo_disp = vgrasdo_actual - vgrasdo_retenido - vgrasdo_cong - mSaldoSBC ;
    END IF

    -- LET vgrasdo_actual = vgrasdo_disp;
    LET vsdo_prom = vgraacum_sdo_pos/vgradia_sdo_pos;

    -- // Si el Promedio Cero le paso el Saldo Actual si son Ceros esta Bien MEL
    IF vsdo_prom = 0 THEN
        LET vsdo_prom = vgrasdo_actual;
    END IF;

    IF vgrapaga_interes = "S" then
        call calcula_intqra(pempresa,pdias,vsdo_prom) 
        returning vcodret;
        
        IF vcodret <> "000" then
            return vcodret;
        END if
    END if
    
    SET LOCK MODE TO WAIT 2;
    
    update sc_maenoc
       set (dia_sdo_pos,acum_sdo_pos,dias_acum_int,acum_sdo_int, int_acum) =
           (vgradia_sdo_pos,vgraacum_sdo_pos,vgradias_acum_int,vgraacum_sdo_int, vgraint_acum)
     WHERE empresa = pempresa
       AND cuenta = vgracuenta;
    
--    SET LOCK MODE TO WAIT 2;

    return vcodret;

    END

END procedure
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-06-2025',
'MODIFICACION: Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

create procedure "informix".cierre_mensualqra(pempresa char(3),
                                           pdias smallint,
                                           pcuenta char(20))
    returning char(5);

-- ************************************************************************************
-- *                                                                     
-- * cierre_mensualqra                                                  
-- * Version              1.0.1                                        
-- * Obejtivo:            Calcula saldos acumulados para cierre mensual producto 1900
-- * Creado por:                                                      
-- * ModIFicado por:      Alejandro Rueda Sanchez                    
-- * Ultima Modificacion: Junio 2010
-- *                     Creacion de SPL                           
-- *                                                              
-- ***********************************************************************

DEFINE global vgrafecha_hoy      date             default " ";
DEFINE global vgrafecha_pago     date             default " ";
DEFINE global vgrausuario        char(8)          default " ";
DEFINE global vgrapri_hab_mes    date             default " ";
DEFINE global vgrault_hab_mes    date             default " ";
DEFINE global vgracuenta         char(20)         default " ";
DEFINE global vgrasucursal       char(4)          default " ";
DEFINE global vgrasdo_actual     money(14,2)      default 0;
DEFINE global vgraacum_sdo_pos   money(14,2)      default 0;
DEFINE global vgradia_sdo_pos    smallint         default 0;
DEFINE global vgraproducto       char(4)          default " ";
DEFINE global vgrastatus_cta     char(1)          default " ";
DEFINE global vgrapaga_interes   char(1)          default " ";
DEFINE global vgramto_pag_int    money(14,2)      default 0;
DEFINE global vgratasa           char(8)          default " ";
DEFINE global vgrasobretasa      decimal(9,6)     default 0;
DEFINE global vgratp_moneda      char(2)          default " ";
DEFINE global vgraes_fisica      char(1)          default " ";
DEFINE global vgraexento_isr     char(1)          default " ";
DEFINE global vgratipo_dias_calc char(1)          default " ";
DEFINE global vgrapago_interes   char(1)          default " ";
DEFINE global vgratipo_anio_calc char(1)          default " ";
DEFINE global vgranum_cte        char(20)         default " ";
DEFINE global vgrafecha_alta     date             default "";
DEFINE GLOBAL vgraTasaVar        CHAR(1)          DEFAULT "";
DEFINE GLOBAL vgraFechaProc      DATE             DEFAULT "";
DEFINE GLOBAL vgraacum_sdo_int   MONEY(14,2)      DEFAULT 0;
DEFINE GLOBAL vgraProdCreciente  CHAR(4)          DEFAULT " ";
DEFINE GLOBAL vgraint_acum       DECIMAL(14,2)    DEFAULT 0;
DEFINE GLOBAL vgrasdo_disp       DECIMAL(14,2)    DEFAULT 0;
DEFINE GLOBAL vgradias_acum_int  INTEGER          DEFAULT 0;
DEFINE GLOBAL vgrafecha_mod      DATE             DEFAULT " ";
DEFINE GLOBAL vgranum_tarjeta    CHAR(20)     	DEFAULT " ";
DEFINE GLOBAL vgrasdo_retenido   DECIMAL(14,2)    DEFAULT 0;
DEFINE GLOBAL vgrasdo_cong       DECIMAL(14,2)    DEFAULT 0;

DEFINE vsdo_prom       MONEY(14,2);
DEFINE vsdo_cong       MONEY(14,2);
DEFINE vsdo_retenido   MONEY(14,2);
DEFINE vcodret         char(5);
DEFINE vsqlerr         integer;
DEFINE vregproc        smallint;
DEFINE vfecha          datetime year to month;
DEFINE vsecuencia      smallint;
DEFINE vcobraisr       CHAR(1);
DEFINE vexiste         CHAR(1);
DEFINE vclase_cta      char(1);
DEFINE viva            decimal(9,6);
DEFINE vultpagoint     date;
DEFINE vfolio_suc      char(16);
DEFINE vhora           datetime hour to fraction;
DEFINE vhoraw          char(15);
DEFINE vcom_pendiente  MONEY(14,2);
DEFINE vacum_ccc       MONEY(14,2);
DEFINE vacum_rem       MONEY(14,2);
DEFINE vacum_sbc       MONEY(14,2);
DEFINE vmonto_dev      money(14,2);
DEFINE vchq_exp_mes    SMALLINT;
DEFINE vdias_ccc       SMALLINT;
DEFINE vchq_dev        smallint;
DEFINE vcta_en_legal   char(1);
DEFINE vnum_cgos_mes   INTEGER;
DEFINE vnum_abonos_mes integer;
DEFINE vfecpagoint     datetime month to day;
DEFINE vcobrasegf      char(1);
DEFINE vcuenta         char(20);
DEFINE vstatus_cta     char(1);
DEFINE isam_err        SMALLINT;
DEFINE error_info      CHAR(40);
DEFINE vmotivo         char(2);
DEFINE vnumdias        SMALLINT;
DEFINE vcuantos        SMALLINT;
DEFINE vfechaux        date;
DEFINE vimp_sbg_ccc    DECIMAL(14,2);
--RQM 09 704 SE DEFINE LA VARIABLE DEL SALDO SBC  PARA EL CALCULO DEL SALDO DISPONIBLE OACM
DEFINE mSaldoSbc       MONEY(14,2);

    LET mSaldoSbc = 0;
    LET vcodret = "000";

    begin

    on exception
        set vsqlerr, isam_err, error_info
        	SET DEBUG FILE TO "cierremensualqra.err";
        	TRACE ON;
        IF vsqlerr <> 0 then
            LET vcodret = vsqlerr;
            return vcodret;
        END if;
    END exception;

    set isolation to dirty read;

    -- SET DEBUG FILE TO "/tmp/cierremensualqra.out";
    -- TRACE ON;

    LET vfecha = vgrafecha_hoy;
    LET vsecuencia = month(vgrafecha_hoy);
    LET vimp_sbg_ccc = 0;

	--RQM 09 704 Se extrae el saldo sbc en una nueva variable mSaldoSbc OACM
    SELECT mc.cuenta,       mc.num_cte,       mc.sucursal,
           acum_sdo_pos,    dia_sdo_pos,      status_cta,
           pr.paga_interes, tasa,             sobretasa,
           divisa,          es_fisica,        exento_isr,
           tipo_dias_calc,  pago_interes,     tipo_anio_calc,
           mto_pag_int,     mc.producto,      dias_ccc,
           acum_ccc,        sdo_actual,       sdo_cong,
           sdo_retenido,    acum_sbc,         acum_rem,
           chq_exp_mes,     chq_dev,          num_cgos_mes,
           num_abonos_mes,  mc.ultpagoint,    clase_cta,
           cta_en_legal,    monto_dev,        mc.cobraisr,
           fecpagoint,      mn.fecha_alta,    pr.paga_dividendo,
           mc.fecha_proceso, acum_sdo_int,    int_acum,
           mc.motivo,       dias_acum_int,    imp_sbg_ccc, 
	   mc.sdo_cong, mc.sdo_retenido, mc.saldo_sbc
      INTO vgracuenta,        vgranum_cte,        vgrasucursal,
           vgraacum_sdo_pos,  vgradia_sdo_pos,    vgrastatus_cta,
           vgrapaga_interes,  vgratasa,           vgrasobretasa,
           vgratp_moneda,     vgraes_fisica,      vgraexento_isr,
           vgratipo_dias_calc,vgrapago_interes,   vgratipo_anio_calc,
           vgramto_pag_int,   vgraproducto,       vdias_ccc,
           vacum_ccc,       vgrasdo_actual,     vsdo_cong,
           vsdo_retenido,   vacum_sbc,        vacum_rem,
           vchq_exp_mes,    vchq_dev,         vnum_cgos_mes,
           vnum_abonos_mes, vultpagoint,      vclase_cta,
           vcta_en_legal,   vmonto_dev,       vcobraisr,
           vfecpagoint,     vgrafecha_alta,     vgraTasaVar,
           vgraFechaProc,     vgraacum_sdo_int,   vgraint_acum,
           vmotivo,         vgradias_acum_int,  vimp_sbg_ccc,
	   vgrasdo_cong, vgrasdo_retenido, mSaldoSbc
      FROM sc_maechq mc,
           sc_maenoc mn,
           sc_producto pr,
           bdinteg:si_cliente cl,
           bdinteg:si_tipper tp
     WHERE mc.empresa = pempresa
       AND mc.cuenta = pcuenta
       AND status_cta not in("0","2","8","9","4")
       AND mc.empresa = mn.empresa
       AND mc.cuenta = mn.cuenta
       AND pr.empresa = mc.empresa
       AND pr.producto = mc.producto
       AND cl.numcte = mc.num_cte
       AND tp.tpo_persona = cl.tpo_persona;

    IF vcobraisr <> "" then
        IF vcobraisr = "S" then
            LET vgraexento_isr = "N";
        ELSE
            LET vgraexento_isr = "S";
        END if
    END if

    IF vgrapaga_interes is null then
        LET vgrapaga_interes = "N";
    END if

    IF vgramto_pag_int is null then
        LET vgramto_pag_int = 0;
    END if

    -- // Verifica si es el primer dia del mes, inicializa saldo interes acumulado
    IF DAY(vgrapri_hab_mes) = DAY(vgrafecha_hoy) THEN
        LET vgradias_acum_int = pdias;
        LET vgraint_acum = vgraacum_sdo_int;
        LET vgraacum_sdo_int = 0;
        LET vgradia_sdo_pos = vgradia_sdo_pos + pdias;
        LET vgraacum_sdo_pos = vgraacum_sdo_pos + vgrasdo_actual * pdias;
    ELSE -- // Dias del acumulado de intereses
        LET vgradias_acum_int = vgradias_acum_int + pdias;
        LET vgradia_sdo_pos = vgradia_sdo_pos + pdias;
        LET vgraacum_sdo_pos = vgraacum_sdo_pos + vgrasdo_actual * pdias;
    END IF

    LET vsdo_prom = vgraacum_sdo_pos / vgradia_sdo_pos;

	--RQM 09 704 SE AGREGA EL SALDO SBC EN AMBAS FORMULAS OACM
    -- // Si la cuenta es empresarial especial, toma el saldo disponible completo
    IF vmotivo = '99' THEN
        LET vgrasdo_disp = vgrasdo_actual - vgrasdo_retenido - mSaldoSbc;
    ELSE
        LET vgrasdo_disp = vgrasdo_actual - (vgrasdo_retenido + vgrasdo_cong + vimp_sbg_ccc + mSaldoSbc);
    END IF

    -- LET vgrasdo_actual = vgrasdo_disp;

    -- // Si el Promedio Cero le paso el Saldo Actual si son Ceros esta Bien MEL
    IF vsdo_prom = 0 THEN
        LET vsdo_prom = vgrasdo_actual;
    END IF;

    IF vgrapaga_interes = "S" then
        call calcula_intqra(pempresa,pdias,vsdo_prom)
        returning vcodret;

        IF vcodret <> "000" THEN
            return vcodret;
        END IF
    END if

    IF vgrasdo_disp < 0 then
        LET vgrasdo_disp = 0;
    END if

    -- // Cobro de comisiones a las cuentas que no son de cortesia
    IF vclase_cta = "1" then
        select iva
          into viva
          from bdinteg:si_sucursales
         where empresa = pempresa
           AND sucursal = vgrasucursal;

        IF viva is null then
            LET viva = 0;
        END if

        LET vhora = current hour to fraction;
        LET vhoraw = vhora;
        LET vhoraw = vhoraw[1,2] || vhoraw[4,5] || vhoraw[7,8] || vhoraw[10,11];
        LET vfolio_suc = vgrausuario || vhoraw[1,8];

        -- // Genera Comisiones por aniversario
        LET vcuantos = 12;

        WHILE vcuantos <= 120
            CALL sp_mes_siguiente(vgrafecha_alta, vcuantos, day(vgrafecha_alta))
            RETURNING vcodret, vfechaux, vnumdias;

            IF vfechaux = vgrafecha_hoy THEN
                call gencomanv(pempresa,vgracuenta) returning vcodret;
                IF vcodret <> "000" THEN
                    return vcodret;
                END if
                EXIT WHILE;
            ELIF vfechaux < vgrafecha_hoy THEN
                LET vcuantos = vcuantos + 12;
            ELSE
                EXIT WHILE;
            END IF
        END WHILE;

        -- // Genera Comisiones mensuales
        call gencommes(pempresa,vgracuenta) returning vcodret;

        IF vcodret <> "000" THEN
            return vcodret;
        END if
		--RQM 09 704 SE AGREGA EL  SALDO SBCB OACM
        select sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc), com_pendiente
          into vgrasdo_disp, vcom_pendiente
          from sc_maechq
         where empresa = pempresa
           AND cuenta = vgracuenta;

        IF vcom_pendiente > 0 AND vgrasdo_disp > 0 then
            call cobintcomsbg(pempresa,vgracuenta,vfolio_suc,vgrausuario,vgrasucursal)
            returning vcodret;

            IF vcodret <> "000" THEN
                return vcodret;
            END if
			--RQM 09 704 SE AGREGA EL  SALDO SBCB OACM
            select sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc +saldo_sbc )
              into vgrasdo_disp
              from sc_maechq
             where empresa = pempresa
               AND cuenta = vgracuenta;
        END if
    END if

    -- LET vgrasdo_actual = vgrasdo_disp;

    SET LOCK MODE TO WAIT 2;

    -- // Actualiza los acumulados del saldo e intereses
    UPDATE sc_maenoc
       SET (dia_sdo_pos,acum_sdo_pos,dias_acum_int,acum_sdo_int,capitalizacion, paga_interes) =
           (vgradia_sdo_pos,vgraacum_sdo_pos,vgradias_acum_int,vgraacum_sdo_int,vgrapago_interes,vgrapaga_interes)
     WHERE empresa = pempresa
       AND cuenta = vgracuenta;

    update sc_tarjeta
       set disp_mes = 0
     where empresa = pempresa
       AND cuenta  = vgracuenta
	   AND secuencia > 0
	   AND status_tar = "A";

--    SET LOCK MODE TO WAIT 2;

    return vcodret;

    end

END procedure

DOCUMENT 
'MODIFICO : Osiel Alfredo Camacho Menoza',
'FECHA : 19-06-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible en la cuenta empresarial.',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_cobrocomisionreposiciondebito ( pEmpresa CHAR(3))	
RETURNING CHAR(5);       -- Codigo de Retorno
		  
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cErrorsp   CHAR(1);
DEFINE cCodRet      CHAR(6);
DEFINE cCodRetAux   CHAR(6);
DEFINE cMen_ret CHAR(80);
DEFINE p_cod_ret CHAR(6);
DEFINE pcod_ret CHAR(5);
DEFINE cResultado		CHAR(1);
DEFINE cMensaje		CHAR(250);
DEFINE iSecuencia INTEGER;
DEFINE cNumcuenta CHAR(20);
DEFINE cMotivo CHAR(2);
DEFINE cNumtarjeta CHAR(20);
DEFINE cNumeroFolio CHAR(16);
DEFINE cEmpresa CHAR(3);
DEFINE cSucursal CHAR(4);
DEFINE cTransacc CHAR(4);
DEFINE cOperador CHAR(10);
DEFINE cMontoCom MONEY(16,2);
DEFINE mMonto MONEY(16,2);
DEFINE cIvaCom MONEY(16,2);
DEFINE mSdoDisponible MONEY(16,2);
DEFINE dtFechaSol DATE;
--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cErrorsp      = "";
LET cCodRet         = "00000";
LET cCodRetAux         = "000000";
LET p_cod_ret     = "00000";
LET pcod_ret     = "00000";
LET cMen_ret     = "Proceso Exitoso";
LET iSecuencia = 0;
LET cNumcuenta = "";
LET cMotivo = "";
LET cNumeroFolio = "";
LET cEmpresa = "001";
LET cTransacc = "";
LET cSucursal = "9290";
LET cOperador = "informix";
LET dtFechaSol = DATE(1);
LET cMontoCom =0.00;
LET mMonto =0.00;
LET cIvaCom =0.00;
LET mSdoDisponible =0.00;
LET cResultado		= '';
LET cMensaje		= '';
--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
LET cCodRetConsSdo		= '00000';
LET cMensajeRetConsSdo	= '';


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/Malena/sp_cobrocomisionreposiciondebito.out';
	--TRACE ON;
		
		--Pendientes de cobrar comision de tarjetas de debito por motivo robo,extravio y Maltrato (1,2,3)		
			SELECT empresa,num_credito,num_tarjeta,motivo
			FROM bdicred:"informix".sd_cobro_comision
			WHERE empresa=cEmpresa
			AND tipo_tarjeta ='D'
			AND resultado ='0'			
			INTO temp paso_sol WITH NO LOG;
			
			UPDATE statistics medium FOR TABLE paso_sol;

			--Valor de comision que se obtuvo de la funciÃ³n fnvalidacobrocomisionplasticos de postgres
			LET cMontoCom='25.86'; 
		
			   SELECT iva
				 INTO cIvaCom
			 FROM bdinteg:si_sucursales
			WHERE empresa = cEmpresa
			  AND sucursal = cSucursal;

			 LET cIvaCom = cMontoCom * cIvaCom;
			   LET mMonto = cMontoCom + cIvaCom;			

	FOREACH WITH HOLD
		
				SELECT num_credito,num_tarjeta,motivo
				INTO cNumcuenta, cNumtarjeta, cMotivo
				FROM "informix".paso_sol				
				
				--Transaccion de Cobro de Comision por ReposiciÃ³n para debito 
				LET cTransacc ='3261';

				--SE GENERA EL FOLIO
				 CALL bdicheq:"informix".sp_generafolionomina('informix') 
				 RETURNING cCodRetAux, cNumeroFolio;
				
				-- Obtiene el Monto de la Comision para Debito				
					--RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    				EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo(cNumcuenta, null, null, null, null, null, null, null, 'T', 3) 
    				INTO cCodRetConsSdo,cMensajeRetConsSdo,mSdoDisponible;

					   -- Valida si la cuenta tiene fondos suficientes
					   IF mMonto > NVL(mSdoDisponible,0) THEN
						  LET p_cod_ret = '001';
							--"El Cliente tiene Fondos Insuficientes"
							UPDATE bdicred:"informix".sd_cobro_comision 
							SET resultado ='0',mensaje = p_cod_ret || ' - El Cliente tiene Fondos Insuficientes'
							WHERE num_tarjeta =cNumtarjeta;	
							LET cCodRet = '00001';	
					   ELSE
							LET p_cod_ret='000';
					   END IF;				

				IF p_cod_ret::INTEGER = 0 THEN
					EXECUTE PROCEDURE bdicheq:"informix".cargo_comisiones (cEmpresa,cNumcuenta,cTransacc,cMontoCom,cNumeroFolio,cSucursal, 
					cOperador,0,'01',TODAY)
					INTO pcod_ret;
					
					IF pcod_ret::INTEGER = 0 THEN
						UPDATE bdicheq:"informix".sc_tarjeta 
						SET cobro_comision  ='S'
						WHERE num_tarjeta =cNumtarjeta;
						
						--Se actualiza el resultado del cargo de la comision
						UPDATE bdicred:"informix".sd_cobro_comision 
						SET resultado ='1',mensaje = 'Comision Aplicada con exito'
						WHERE num_tarjeta =cNumtarjeta;	
					ELIF pcod_ret::INTEGER = 300 THEN
						--La cuenta se encuentra bloqueada 
						UPDATE bdicred:"informix".sd_cobro_comision 
						SET resultado ='0',mensaje = pcod_ret || ' - La cuenta se encuentra bloqueada no es posible aplicar comision'
						WHERE num_tarjeta =cNumtarjeta;
						LET cCodRet = '00002';
					ELSE 
						--Se actualiza el resultado del cargo de la comision
						UPDATE bdicred:"informix".sd_cobro_comision 
						SET resultado ='0',mensaje = pcod_ret || ' - Ocurrio un Error al intentar aplicar la comision'
						WHERE num_tarjeta =cNumtarjeta;
						LET cCodRet = '00002';
					END IF;					
				END IF;			 
				
	END FOREACH;	
							
		RETURN cCodRet ;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para aplicar cobros de comisiones que no se aplicarÃ³n por ReposiciÃ³n de Tarjetas de Debito en el periodo de Junio y Julio ',
'AUTOR :  Maria Elena Angulo Aispuro',
'FECHA : 20/julio/2016',
'BD: bdicheq',
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros la cuenta del cliente y el tipo de calculo a realizar',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".sc_riesgoscaptacion()
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    -------------------------------------------------
    -- Recopila los datos de captacion del cliente, 
    -- como el saldo disponible hasta el dia de hoy 
    -- y los guarda en la tabla sc_riesgoscap.
    -------------------------------------------------
    
    DEFINE GLOBAL vgcuenta      CHAR(20)     DEFAULT " ";
    DEFINE GLOBAL vgfechahoy    DATE         DEFAULT " ";
    DEFINE GLOBAL vgtasavar     CHAR(1)      DEFAULT "";
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vdescerr         CHAR(50);
    DEFINE vcomienza        SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vpri_dia_mes     DATE;
    DEFINE vult_dia_mes_ant DATE;
    DEFINE vanio            CHAR(4);
    DEFINE vmes             CHAR(2);
    DEFINE vaniomes         CHAR(6);
    DEFINE vresiduo         SMALLINT;
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vrfc             CHAR(15);
    DEFINE vstatus_cta      CHAR(1);
    DEFINE vsucursal	    CHAR(4);
    DEFINE vplazo		    CHAR(3);
    DEFINE vproducto	    CHAR(4);
    DEFINE vedocivil		CHAR(2);
    DEFINE vsexo	  	    CHAR(1);
    DEFINE vocupacion       CHAR(30);
    DEFINE vciudad          CHAR(15);
    DEFINE vtasa			CHAR(8);
    DEFINE vdiaspos         SMALLINT;
    DEFINE vdiasposmes      SMALLINT;
    DEFINE vacumsdopos		MONEY(18,2);
    DEFINE vacumsdoposmes	MONEY(18,2);
    DEFINE vsdoprom		    MONEY(18,2);
    DEFINE vsdoprommes	    MONEY(18,2);
    DEFINE vsdoactual	    MONEY(18,2);
    DEFINE vsdoret		    MONEY(18,2);
    DEFINE vsdocong		    MONEY(18,2);
    DEFINE vsdo_sbg         MONEY(18,2);
    DEFINE vsdodisp         MONEY(18,2);
    DEFINE vfecha_aniv      DATE;
    DEFINE vfecha_altacte   DATE;
    DEFINE vfecha_primermov DATE;
    DEFINE vfecha_ultimomov DATE;
    DEFINE ves_fisica       CHAR(1);
    DEFINE vtipper          CHAR(1);
    DEFINE vvaltasa         DECIMAL(9,6);
    DEFINE vintinvcrec      DECIMAL(14,2);
    DEFINE vcapvig1         DECIMAL(14,2);
    DEFINE vcapvig2         DECIMAL(14,2);
    DEFINE vcapvig3         DECIMAL(14,2);
    DEFINE vcapvig4         DECIMAL(14,2);
    DEFINE vcapvig5         DECIMAL(14,2);
    DEFINE vcapvig6         DECIMAL(14,2);
    DEFINE vcapvig7         DECIMAL(14,2);
    DEFINE vcapvig8         DECIMAL(14,2);
    DEFINE vcapvig9         DECIMAL(14,2);
    DEFINE vcapvig10        DECIMAL(14,2);
    DEFINE vcapvig11        DECIMAL(14,2);
    DEFINE vcapvig12        DECIMAL(14,2);
    DEFINE vcapvig13        DECIMAL(14,2);
    DEFINE vcapvig14        DECIMAL(14,2);
    DEFINE vcapvig15        DECIMAL(14,2);
    DEFINE vcapvig16        DECIMAL(14,2);
    DEFINE vcapvig17        DECIMAL(14,2);
    DEFINE vcapvig18        DECIMAL(14,2);
    DEFINE vcapvig19        DECIMAL(14,2);
    DEFINE vcapvig20        DECIMAL(14,2);
    DEFINE vcapvig21        DECIMAL(14,2);
    DEFINE vcapvig22        DECIMAL(14,2);
    DEFINE vcapvig23        DECIMAL(14,2);
    DEFINE vcapvig24        DECIMAL(14,2);
    DEFINE vcapvig25        DECIMAL(14,2);
    DEFINE vcapvig26        DECIMAL(14,2);
    DEFINE vcapvig27        DECIMAL(14,2);
    DEFINE vcapvig28        DECIMAL(14,2);
    DEFINE vcapvig29        DECIMAL(14,2);
    DEFINE vcapvig30        DECIMAL(14,2);
    DEFINE vcapvig31        DECIMAL(14,2);
    DEFINE vfecha           CHAR(8);
    DEFINE vsql             CHAR(300);
	--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo.
	DEFINE cCodRetSpCons	CHAR(5);
	DEFINE cMensajeRet		CHAR(50);
	DEFINE mSdoSbc			MONEY(14,2);
    
    LET vcodret1        = '';
    LET vcodret2        = '';
    LET vcodret3        = '';
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
    LET vcomienza       = -1;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcontador3      = 0;
    LET ven_transacc    = 0; 
    
    LET vpri_dia_mes     = '';
    LET vult_dia_mes_ant = '';
    LET vanio            = '';
    LET vmes             = '';
    LET vaniomes         = '';
    LET vresiduo         = 0;
    
    LET vnumcte          = "";
    LET vrfc             = '';
    LET vstatus_cta      = '';
    LET vsucursal        = "";
    LET vplazo           = "";
    LET vproducto        = "";
    LET vedocivil        = "";
    LET vsexo            = "";
    LET vocupacion       = "";
    LET vciudad          = "";
    LET vtasa            = 0;
    LET vdiaspos         = 0;
    LET vdiasposmes      = 0;
    LET vacumsdopos      = 0;
    LET vacumsdoposmes   = 0;
    LET vsdoprom         = 0;
    LET vsdoprommes      = 0;
    LET vsdoactual       = 0;
    LET vsdoret		     = 0;
    LET vsdocong		 = 0;
    LET vsdo_sbg         = 0;
    LET vsdodisp         = 0;
    LET vfecha_aniv      = '';
    LET vfecha_altacte   = '';
    LET vfecha_primermov = '';
    LET vfecha_ultimomov = '';
    LET ves_fisica       = '';
    LET vtipper          = '';
    LET vvaltasa         = 0;
    LET vintinvcrec      = 0;
    LET vcapvig1         = 0;
    LET vcapvig2         = 0;
    LET vcapvig3         = 0;
    LET vcapvig4         = 0;
    LET vcapvig5         = 0;
    LET vcapvig6         = 0;
    LET vcapvig7         = 0;
    LET vcapvig8         = 0;
    LET vcapvig9         = 0;
    LET vcapvig10        = 0;
    LET vcapvig11        = 0;
    LET vcapvig12        = 0;
    LET vcapvig13        = 0;
    LET vcapvig14        = 0;
    LET vcapvig15        = 0;
    LET vcapvig16        = 0;
    LET vcapvig17        = 0;
    LET vcapvig18        = 0;
    LET vcapvig19        = 0;
    LET vcapvig20        = 0;
    LET vcapvig21        = 0;
    LET vcapvig22        = 0;
    LET vcapvig23        = 0;
    LET vcapvig24        = 0;
    LET vcapvig25        = 0;
    LET vcapvig26        = 0;
    LET vcapvig27        = 0;
    LET vcapvig28        = 0;
    LET vcapvig29        = 0;
    LET vcapvig30        = 0;
    LET vcapvig31        = 0;
    LET vfecha           = '';
    LET vsql             = '';
	--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo.
	LET cCodRetSpCons	= '00000';
	LET cMensajeRet		= '';
	LET mSdoSbc			= 0.0;

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET debug file to "/resplogifx/conciliachq/sc_riesgoscaptacion.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vnumcte = vnumcte;
            LET vgcuenta = vgcuenta;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET debug file to "/resplogifx/conciliachq/sc_riesgoscaptacion.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- Obtiene la fecha del dia de hoy
    SELECT fecha_ant, pri_dia_mes
      INTO vgfechahoy, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = '001';
     
    LET vult_dia_mes_ant = vpri_dia_mes - 1 units day;
    LET vanio = YEAR(vult_dia_mes_ant);
    LET vmes = LPAD(MONTH(vult_dia_mes_ant), 2, '0');
    LET vaniomes = YEAR(vult_dia_mes_ant) || LPAD(MONTH(vult_dia_mes_ant), 2, '0');
    LET vresiduo = MOD(vanio, 4);
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_riesgoscap') THEN
        DROP TABLE bdicheq:"informix".sc_riesgoscap;        
    END IF;
    
    CREATE TABLE sc_riesgoscap
        (
            numcte          char(20),
            cuenta          char(20),
            sucursal        char(4),
            plazo           char(3),
            producto        char(4),
            tasa            decimal(9,6),
            ocupacion       char(30),
            edocivil        char(2),
            sexo            char(1),
            ciudad          char(15),
            sdoprom         money(18,2),
            sdodisp         money(18,2),
            fecha_aniv      date,
            fecha_altacte   date,
            fecha_primermov date,
            fecha_ultimomov date,
            fecha           date,
            rfc             char(15),
            status_cta      char(1),
            sdo_prom_mesant money(18,2)
        ) 
    EXTENT SIZE 1000000 NEXT SIZE 500000 LOCK MODE ROW;
    
    --- CLIENTES  DEL  SISTEMA  DE  CAPTACION  (CHEQUES) 
    FOREACH WITH HOLD
        SELECT UNIQUE mae.num_cte
          INTO vnumcte
          FROM sc_maechq mae
         WHERE mae.status_cta NOT IN('2','6','7','8')
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        -- Obtiene los datos socioeconomicos del cliente 
        SELECT LIMIT 1 cli.fecha_alta, cli.rfc, cte.estado_civil, cte.sexo, pfs.descripcion, tip.es_fisica, ciu.nombreciudad
          INTO vfecha_altacte, vrfc, vedocivil, vsexo, vocupacion, ves_fisica, vciudad
          FROM bdinteg:si_cliente cli
         INNER JOIN bdinteg:si_tipper tip ON (tip.tpo_persona = cli.tpo_persona)
          LEFT OUTER JOIN bdinteg:si_ctepf cte ON (cli.numcte = cte.numcte AND cli.empresa = cte.empresa)
          LEFT OUTER JOIN bdinteg:si_direcciones_actual dir ON (dir.numcte = cli.numcte AND dir.tipo_dir = '1')
          LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:si_profesion pfs ON (cte.profesion = pfs.profesion)
         WHERE cli.numcte = vnumcte;
           
        -- ASIGNA TIPO DE PERSONA 
        IF ves_fisica = "S" THEN
            LET vtipper = "F";
        ELSE
            LET vtipper = "M";
        END IF;
        
        --- CUENTAS  DEL  SISTEMA  DE  CAPTACION  (CHEQUES) 
        FOREACH 
			-- RQM 09 704. Se agrega los campos a las variables y se onbtiene el saldo_sbc para calcular el saldo disponible con el SP.
            SELECT mae.cuenta, mae.status_cta, mae.sucursal, mae.producto, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.fec_ult_mov, 
                   noc.fecha_alta, noc.acum_sdo_pos, noc.dia_sdo_pos, pro.tasa, pro.paga_dividendo, mae.saldo_sbc
              INTO vgcuenta, vstatus_cta, vsucursal, vproducto, vsdoactual, vsdoret, vsdocong, vsdo_sbg, vfecha_ultimomov, 
                   vfecha_aniv, vacumsdopos, vdiaspos, vtasa, vgtasavar, mSdoSbc
              FROM bdicheq:sc_maechq mae,
                   bdicheq:sc_maenoc noc,
                   bdicheq:sc_producto pro
             WHERE mae.num_cte = vnumcte
               AND mae.status_cta NOT IN('2','6','7','8')
               AND noc.empresa = mae.empresa
               AND noc.cuenta = mae.cuenta
               AND pro.empresa = mae.empresa
               AND pro.producto = mae.producto
               
            -- Calcula el saldo promedio actual de la cuenta
            IF vdiaspos > 0 THEN
                LET vsdoprom = vacumsdopos / vdiaspos;
            ELSE
                LET vsdoprom = vsdoactual;
            END IF;
            
            -- Obtiene el valor de la tasa 
            CALL calc_tasa('001', vtasa, vtipper, vsdoprom)
            RETURNING vcodret1, vvaltasa, vintinvcrec;
        
            -- Calcula el saldo promedio del mes anterior de la cuenta
            SELECT LIMIT 1 capvig1, capvig2, capvig3, capvig4, capvig5, capvig6, capvig7, capvig8, 
                   capvig9, capvig10, capvig11, capvig12, capvig13, capvig14, capvig15, capvig16,  
                   capvig17, capvig18, capvig19, capvig20, capvig21, capvig22, capvig23, capvig24, 
                   capvig25, capvig26, capvig27, capvig28, capvig29, capvig30, capvig31
              INTO vcapvig1, vcapvig2, vcapvig3, vcapvig4, vcapvig5, vcapvig6, vcapvig7, vcapvig8, 
                   vcapvig9, vcapvig10, vcapvig11, vcapvig12, vcapvig13, vcapvig14, vcapvig15, vcapvig16,  
                   vcapvig17, vcapvig18, vcapvig19, vcapvig20, vcapvig21, vcapvig22, vcapvig23, vcapvig24, 
                   vcapvig25, vcapvig26, vcapvig27, vcapvig28, vcapvig29, vcapvig30, vcapvig31
              FROM sc_sdodiarioc
             WHERE aniomes = vaniomes
               AND cuenta = vgcuenta;
            
            IF vmes IN('01','03','05','07','08','10','12') THEN
                LET vdiasposmes = 31;
                LET vacumsdoposmes = vcapvig1 + vcapvig2 + vcapvig3 + vcapvig4 + vcapvig5 + vcapvig6 + vcapvig7 + vcapvig8 + 
                                     vcapvig9 + vcapvig10 + vcapvig11 + vcapvig12 + vcapvig13 + vcapvig14 + vcapvig15 + vcapvig16 + 
                                     vcapvig17 + vcapvig18 + vcapvig19 + vcapvig20 + vcapvig21 + vcapvig22 + vcapvig23 + vcapvig24 +            
                                     vcapvig25 + vcapvig26 + vcapvig27 + vcapvig28 + vcapvig29 + vcapvig30 + vcapvig31;
                LET vsdoprommes = vacumsdoposmes / vdiasposmes;
            ELIF vmes IN('04','06','09','11') THEN
                LET vdiasposmes = 30;
                LET vacumsdoposmes = vcapvig1 + vcapvig2 + vcapvig3 + vcapvig4 + vcapvig5 + vcapvig6 + vcapvig7 + vcapvig8 + 
                                     vcapvig9 + vcapvig10 + vcapvig11 + vcapvig12 + vcapvig13 + vcapvig14 + vcapvig15 + vcapvig16 + 
                                     vcapvig17 + vcapvig18 + vcapvig19 + vcapvig20 + vcapvig21 + vcapvig22 + vcapvig23 + vcapvig24 +            
                                     vcapvig25 + vcapvig26 + vcapvig27 + vcapvig28 + vcapvig29 + vcapvig30;
                LET vsdoprommes = vacumsdoposmes / vdiasposmes;
            ELIF vmes = '02' THEN
                IF vresiduo = 0 THEN
                    LET vdiasposmes = 29;
                    LET vacumsdoposmes = vcapvig1 + vcapvig2 + vcapvig3 + vcapvig4 + vcapvig5 + vcapvig6 + vcapvig7 + vcapvig8 + 
                                         vcapvig9 + vcapvig10 + vcapvig11 + vcapvig12 + vcapvig13 + vcapvig14 + vcapvig15 + vcapvig16 + 
                                         vcapvig17 + vcapvig18 + vcapvig19 + vcapvig20 + vcapvig21 + vcapvig22 + vcapvig23 + vcapvig24 +            
                                         vcapvig25 + vcapvig26 + vcapvig27 + vcapvig28 + vcapvig29;
                    LET vsdoprommes = vacumsdoposmes / vdiasposmes;
                ELSE
                    LET vdiasposmes = 28;
                    LET vacumsdoposmes = vcapvig1 + vcapvig2 + vcapvig3 + vcapvig4 + vcapvig5 + vcapvig6 + vcapvig7 + vcapvig8 + 
                                         vcapvig9 + vcapvig10 + vcapvig11 + vcapvig12 + vcapvig13 + vcapvig14 + vcapvig15 + vcapvig16 + 
                                         vcapvig17 + vcapvig18 + vcapvig19 + vcapvig20 + vcapvig21 + vcapvig22 + vcapvig23 + vcapvig24 +            
                                         vcapvig25 + vcapvig26 + vcapvig27 + vcapvig28;
                    LET vsdoprommes = vacumsdoposmes / vdiasposmes;
                END IF
            END IF;
            
            -- Calcula el saldo disponible del cliente 
            --LET vsdodisp = vsdoactual - (vsdoret + vsdocong + vsdo_sbg);
			
			-- RQM 09 704. Se agrega el SP para calcular el saldo disponible tomando en cuenta el saldo_sbc.
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
			('', vsdoactual, vsdoret, vsdocong, mSdoSbc, vsdo_sbg, NULL, NULL, 'F', '1') INTO cCodRetSpCons, cMensajeRet, vsdodisp;
            
            LET vplazo = ' ';
            LET vfecha_primermov = vfecha_aniv;

            -- Inserta datos en tabla sc_riesgoscap 
            INSERT INTO sc_riesgoscap 
            ( numcte, cuenta, sucursal, plazo, producto, tasa, ocupacion, edocivil, sexo, ciudad, 
              sdoprom, sdodisp, fecha_aniv, fecha_altacte, fecha_primermov, fecha_ultimomov, fecha,
              rfc, status_cta, sdo_prom_mesant )
            VALUES 
            ( vnumcte, vgcuenta, vsucursal, vplazo, vproducto, vvaltasa, vocupacion, vedocivil, vsexo, vciudad, 
              vsdoprom, vsdodisp, vfecha_aniv, vfecha_altacte, vfecha_primermov, vfecha_ultimomov, vgfechahoy,
              vrfc, vstatus_cta, vsdoprommes );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vgcuenta	     = "";
            LET vsucursal        = "";
            LET vplazo           = "";
            LET vproducto        = "";
            LET vtasa            = 0;
            LET vgtasavar        = "";
            LET vdiaspos         = 0;
            LET vacumsdopos      = 0;
            LET vsdoprom         = 0;
            LET vsdoactual       = 0;
            LET vsdoret		     = 0;
            LET vsdocong		 = 0;
            LET vsdo_sbg         = 0;
            LET vsdodisp         = 0;
            LET vfecha_aniv      = '';
            LET vfecha_primermov = '';
            LET vfecha_ultimomov = '';
            LET vvaltasa         = 0;
            LET vintinvcrec      = 0;
            LET vcapvig1         = 0;
            LET vcapvig2         = 0;
            LET vcapvig3         = 0;
            LET vcapvig4         = 0;
            LET vcapvig5         = 0;
            LET vcapvig6         = 0;
            LET vcapvig7         = 0;
            LET vcapvig8         = 0;
            LET vcapvig9         = 0;
            LET vcapvig10        = 0;
            LET vcapvig11        = 0;
            LET vcapvig12        = 0;
            LET vcapvig13        = 0;
            LET vcapvig14        = 0;
            LET vcapvig15        = 0;
            LET vcapvig16        = 0;
            LET vcapvig17        = 0;
            LET vcapvig18        = 0;
            LET vcapvig19        = 0;
            LET vcapvig20        = 0;
            LET vcapvig21        = 0;
            LET vcapvig22        = 0;
            LET vcapvig23        = 0;
            LET vcapvig24        = 0;
            LET vcapvig25        = 0;
            LET vcapvig26        = 0;
            LET vcapvig27        = 0;
            LET vcapvig28        = 0;
            LET vcapvig29        = 0;
            LET vcapvig30        = 0;
            LET vcapvig31        = 0;
        END FOREACH;
        
        --- CUENTAS  DEL  SISTEMA  DE  CAPTACION  (INVERSIONES) 
        FOREACH 
            SELECT mae.cuenta, mae.status_cta, mae.sucursal, mae.cod_instrum, mae.capital, mae.fec_ult_mov, mae.fecha_alta, mae.tasa, mae.plazo
              INTO vgcuenta, vstatus_cta, vsucursal, vproducto, vsdoactual, vfecha_ultimomov, vfecha_aniv, vvaltasa, vplazo
              FROM bdinvers:sv_maeinv mae
             WHERE mae.num_cte = vnumcte
               AND mae.status_cta = '1'
        
            -- Calcula el saldo promedio del cliente 
            LET vsdoprom = vsdoactual;
            LET vsdoprommes = vsdoactual;
            
            -- Calcula el saldo disponible del cliente 
            LET vsdodisp = vsdoactual;
            
            LET vfecha_primermov = vfecha_aniv;

            -- Inserta datos en tabla sc_riesgoscap 
            INSERT INTO sc_riesgoscap 
            ( numcte, cuenta, sucursal, plazo, producto, tasa, ocupacion, edocivil, sexo, ciudad, 
              sdoprom, sdodisp, fecha_aniv, fecha_altacte, fecha_primermov, fecha_ultimomov, fecha,
              rfc, status_cta, sdo_prom_mesant )
            VALUES 
            ( vnumcte, vgcuenta, vsucursal, vplazo, vproducto, vvaltasa, vocupacion, vedocivil, vsexo, vciudad, 
              vsdoprom, vsdodisp, vfecha_aniv, vfecha_altacte, vfecha_primermov, vfecha_ultimomov, vgfechahoy,
              vrfc, vstatus_cta, vsdoprommes );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vgcuenta	     = "";
            LET vsucursal        = "";
            LET vplazo           = "";
            LET vproducto        = "";
            LET vsdoprom         = 0;
            LET vsdoactual       = 0;
            LET vsdodisp         = 0;
            LET vfecha_aniv      = '';
            LET vfecha_primermov = '';
            LET vfecha_ultimomov = '';
            LET vvaltasa         = 0;
            LET vstatus_cta      = '';
            LET vsdoprommes      = 0;
        END FOREACH;
        
        LET vcontador1 = vcontador1 + 1;
        
        IF vcontador3 >= 1000 THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnumcte         = "";
        LET vedocivil       = "";
        LET vsexo           = "";
        LET vocupacion      = "";
        LET vciudad         = "";
        LET vfecha_altacte  = '';
        LET ves_fisica      = '';
        LET vtipper         = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    CREATE INDEX "informix".idx_riesgoscap ON bdicheq:"informix".sc_riesgoscap(numcte) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_riesgoscap;
    
    LET vfecha = TO_CHAR(vgfechahoy, '%d%m%Y');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/extriecap_'||vfecha||'.txt '||
               'SELECT * FROM sc_riesgoscap;" > /resplogifx/conciliachq/extriecap.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/extriecap.sql"; 
    SYSTEM vsql;
    LET vsql = '';
    
    LET vsql = '';
    LET vsql = '/usr/bin/gzip -9 /resplogifx/conciliachq/extriecap_'||vfecha||'.txt';
    SYSTEM vsql;
    
    LET vcodret1 = "000";
    LET vcodret2 = "000";
    LET vcodret3 = "EL PROCESO SE REALIZO SATISFACTORIAMENTE";

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    
    END;

END PROCEDURE
DOCUMENT
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		bdicheq',
'FECHA :        07-07-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      1.0.2';

CREATE PROCEDURE "informix".sp_cargoxcomision_pmcomp()
RETURNING
	CHAR(6)		AS cod_ret

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);

	DEFINE pNumcte			CHAR(20);
	DEFINE pCuenta			CHAR(20);
	DEFINE pProducto		CHAR(4);
	DEFINE pTransacc		CHAR(4);
	DEFINE dSdoPromMen		DECIMAL(18,2);
	DEFINE dMontoAplica		MONEY;
	DEFINE dMtoAplicComis	MONEY;
	DEFINE cAnioMesAnte		CHAR(6);
	DEFINE mValorSdoPos		MONEY;
	DEFINE mDisponible      MONEY(14,2);
	DEFINE cCodRetGF		CHAR(3);
	DEFINE cFolioGF			CHAR(16);
	DEFINE cCodRetCR		CHAR(5);
	DEFINE cComisionCR		CHAR(4);
	DEFINE mIva				MONEY(14,2);
	DEFINE dValIva			DECIMAL(9,6);
	DEFINE mMontoPen		MONEY(14,2);
	DEFINE mMtoCom			MONEY(14,2);
	DEFINE cTranCom         CHAR(4);
	DEFINE vTranIva         CHAR(4);
	DEFINE mSdoPromMM		MONEY;
	DEFINE mComCgoNoSMM		MONEY;
	DEFINE cTpoPersona		CHAR(1);
	DEFINE mComInacCta		MONEY;
	DEFINE dtFecUltDep		DATE;
	DEFINE dtFecUltRet		DATE;
	DEFINE dtFecUltMov		DATE;

	DEFINE iDifDias			INT8;
	DEFINE sBandCtaNva		SMALLINT;
	DEFINE sBandCargo		SMALLINT;
	DEFINE cDescTranRef		CHAR(40);
	DEFINE cDescIvaRef		CHAR(40);
	DEFINE sFecComision		DATE;
	DEFINE mAcumSdoPos		MONEY;
	DEFINE iDiaSdoPos		SMALLINT;
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaAlta		DATE;
	DEFINE mServAnualidad	MONEY;
	DEFINE mServAnualPrimCta	MONEY;
    DEFINE dtConsMovhis 	DATE;
    DEFINE dtConsMovhisold 	DATE;
    DEFINE dtConsMovhisold2 DATE;
	DEFINE sBandDetcomis	SMALLINT;
	DEFINE cTranSdoprommm	CHAR(4);
	DEFINE cTranInaccta		CHAR(4);
	DEFINE cTrananuaserv	CHAR(4);
	DEFINE cCtaCargoInaccta	CHAR(20);
	DEFINE cPrimerCta		CHAR(20);
	DEFINE mSaldoCta		MONEY;
	DEFINE iNumCtas			SMALLINT;
	DEFINE cBandCtaValida	CHAR(1);
	DEFINE cBandPrimCtaValida	CHAR(1);
	DEFINE sFecComBit		DATE;
	DEFINE sBandComBit		SMALLINT;
	DEFINE cCodRetCS		CHAR(5);
	DEFINE cStaCtaCS		CHAR(1);


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";

	LET pNumcte				= "";
	LET pCuenta				= "";
	LET pProducto			= "";
	LET pTransacc			= "";
	LET dSdoPromMen			= 0.0;
	LET dMontoAplica		= 0.0;
	let dMtoAplicComis		= 0.0;
	LET cAnioMesAnte		= "";
	LET mValorSdoPos		= 0.0;
	LET mDisponible  		= 0;
	LET cCodRetGF			= "000";
	LET cFolioGF			= "";
	LET cCodRetCR			= "000";
	LET cComisionCR			= "";
	LET	mIva				= 0.0;
	LET dValIva				= 0.0;
	LET mMontoPen			= 0.0;
	LET mMtoCom             = 0.0;
	LET cTranCom         	= "";
	LET vTranIva         	= 0.0;
	LET mSdoPromMM			= 0.0;
	LET mComCgoNoSMM		= 0.0;
	LET cTpoPersona			= "";
	LET mComInacCta			= 0.0;
	LET dtFecUltDep			= NULL;
	LET dtFecUltRet			= NULL;
	LET dtFecUltMov			= NULL;
	LET iDifDias			= 0;
	LET sBandCtaNva			= NULL;
	LET sBandCargo			= 0;
	LET cDescTranRef		= "";
	LET cDescIvaRef			= "";
	LET sFecComision		= NULL;
	LET mAcumSdoPos			= 0.0;
	LET iDiaSdoPos			= 0;
	LET dtFechaHoy			= DATE(1);
	LET dtFechaAlta			= DATE(1);
	LET mServAnualidad		= 0.0;
	LET mServAnualPrimCta	= 0.0;
    LET dtConsMovhis 		= DATE(1);
    LET dtConsMovhisold 	= DATE(1);
    LET dtConsMovhisold2 	= DATE(1);
	LET sBandDetcomis		= 0;
	LET cTranSdoprommm		= "";
	LET cTranInaccta		= "";
	LET cTrananuaserv		= "";
	LET cCtaCargoInaccta	= "";
	LET mSaldoCta			= 0.0;
	LET cPrimerCta			= "";
	LET iNumCtas			= 0;
	LET cBandCtaValida		= "0";
	LET cBandPrimCtaValida	= 0;
	LET sFecComBit			= DATE(1);
	LET sBandComBit			= 0;
	LET cCodRetCS			= "000";
	LET cStaCtaCS			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/moha/sp_cargoxcomision_pm.out';
	--TRACE ON;

	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sc_fechas
	WHERE empresa = "001";

	SELECT TRIM(valor)
	INTO cTranSdoprommm
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transdoprommm';

	SELECT TRIM(valor)
	INTO cTranInaccta
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transinaccta1';

	SELECT TRIM(valor)
	INTO cTrananuaserv
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transanuserven';

	--// OBTIENE EL VALOR DEL PARAMETRO DEL IVA
	SELECT TRIM(valor)
	INTO dValIva
	FROM bdinteg:"informix".si_param
	WHERE empresa = "001"
	AND cod_param = 47;

	-- CICLO DE LAS TRANSACCIONES
	FOREACH
		SELECT TRIM(valor)
		INTO pTransacc
		FROM "informix".sc_param
		WHERE empresa = "001"
		AND codparam IN ("transinaccta1","transanuserven")

		--// OBTIENE EL VALOR DE LA COMISION A COBRAR DE LA TABLA sc_comisiones
		SELECT monto_aplica, transacc_com, transacc_iva
		INTO dMtoAplicComis, cTranCom, vTranIva
		FROM "informix".sc_comisiones
		WHERE empresa = "001"
		AND comision = pTransacc;

		LET dMtoAplicComis = NVL(dMtoAplicComis,0);

		--// CICLO PRINCIPAL DONDE BARRE TODAS LAS CUENTAS DE PERSONA MORAL
		FOREACH
			SELECT mae.cuenta, mae.producto, mae.num_cte, fecultdep, fecultret, pro.sdoprommen, noc.fecha_alta
			INTO pCuenta, pProducto, pNumcte, dtFecUltDep, dtFecUltRet, dSdoPromMen, dtFechaAlta
			FROM "informix".sc_producto pro, "informix".sc_maechq mae, "informix".sc_maenoc noc
			WHERE pro.empresa = "001"
			AND pro.producto = mae.producto
			AND pro.pago_interes = 'M'
			AND mae.empresa = pro.empresa
			AND mae.producto = pro.producto
			AND pro.producto IN ("1600","1200","2200")
			AND mae.status_cta IN ("1","4","5")
			AND noc.empresa = mae.empresa
			AND noc.cuenta = mae.cuenta

			LET sBandCargo = 0;

			IF pTransacc = cTranSdoprommm THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION / CARGO POR NO TENER SALDO PROMEDIO MINIMO MENSUAL
				LET mSdoPromMM = 0.0;
				LET mComCgoNoSMM = 0.0;
				LET mAcumSdoPos	= 0.0;
				LET iDiaSdoPos = 0;

				--// OBTIENE EL SALDO PROMEDIO MENSUAL Y LA COMISION EN LA TABLA MAESTRA DE LAS COMISIONES DE LA CUENTAS DE PERSONAS MORALES
				SELECT sdo_prom_mm, com_cgo_no_smm
				INTO mSdoPromMM, mComCgoNoSMM
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mSdoPromMM IS NOT NULL THEN
					LET dSdoPromMen = mSdoPromMM;
				ELSE
					LET mSdoPromMM = 0;

				END IF

				IF mComCgoNoSMM IS NOT NULL THEN
					LET dMontoAplica = mComCgoNoSMM;
				ELSE
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- OBTIENE EL ANIO Y EL MES ANTERIOR
					LET cAnioMesAnte = YEAR(dtFechaHoy - 1 units MONTH) || LPAD(MONTH(dtFechaHoy - 1 units MONTH),2,"0");
					--// OBTIENE EL VALOR ACUMULADO Y EL DIA DEL SALDO POS DE LA CUENTA
					SELECT acum_sdo_pos, dia_sdo_pos
					INTO mAcumSdoPos, iDiaSdoPos
					FROM "informix".sc_maehis
					WHERE aniomes = cAnioMesAnte
					AND cuenta = pCuenta;

					LET mAcumSdoPos = NVL(mAcumSdoPos, 0);
					LET iDiaSdoPos = NVL(iDiaSdoPos, 0);

					IF iDiaSdoPos = 0 THEN
						LET mValorSdoPos = 0;
					ELSE
						LET mValorSdoPos = mAcumSdoPos / iDiaSdoPos;
					END IF

					--// VALIDA SI EL SALDO POS ES MENOR AL SALDO PROMEDIO DE LA sc_producto
					IF mValorSdoPos < dSdoPromMen THEN
						LET sBandCargo = 1;
						LET cDescTranRef = "COMISION X NO TENER SALDO PROMEDIO MENS";
						LET cDescIvaRef = "IVA COMISION X NO TENER SALDO PROM MENS";
					END IF
				END IF
			ELIF pTransacc = cTranInaccta THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR INACTIVIDAD DE LA CUENTA DURANTE 1 ANIO
				LET mComInacCta = 0;
				LET dtFecUltMov	= NULL;

				SELECT com_ina_cta
				INTO mComInacCta
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mComInacCta IS NOT NULL THEN
					LET dMontoAplica = mComInacCta;
				ELSE
					LET mComInacCta = 0;
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- VALIDA QUE LA CUENTA TENGA POR LO MENOS UN ANIO DE VIDA
					IF (dtFechaHoy - dtFechaAlta) > 360 THEN

						IF dtFecUltDep IS NULL AND dtFecUltRet IS NULL THEN
							LET sBandCargo = 1;
						ELSE
							IF dtFecUltDep IS NOT NULL THEN
								LET dtFecUltMov = dtFecUltDep;
							END IF

							IF dtFecUltRet IS NOT NULL THEN
								IF dtFecUltRet > dtFecUltMov THEN
									LET dtFecUltMov = dtFecUltRet;
								END IF
							END IF

							IF (dtFechaHoy - dtFecUltMov) < 361 THEN
								LET sBandCargo = 0;
							ELSE
								LET sBandCargo = 1;
								LET cDescTranRef = "COMISION X INACTIVIDAD DE LA CTA 1 ANIO";
								LET cDescIvaRef = "IVA COMISION X INACT DE LA CTA 1 ANIO";
							END IF
						END IF
					END IF
				END IF
			ELIF pTransacc = cTrananuaserv THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR ANUALIDAD DEL SERVICIO DE EMPRESANET
				LET iDifDias = 0;
				LET sBandCtaNva = NULL;
				LET iNumCtas = 0;
				LET cBandCtaValida = "0";
				LET sFecComBit = DATE(1);
				LET sBandComBit	= 0;
				LET cPrimerCta = "";
				LET mServAnualPrimCta = 0.0;
				LET mServAnualidad = 0.0;
				LET mSaldoCta = 0.0;
				LET cCtaCargoInaccta = "";

				--// OBTIENE EL NUMERO DE DIAS DE LA FECHA ACTUAL RESPECTO A SU FECHA DE REGISTRO
				SELECT dtFechaHoy - f_registro
				INTO iDifDias
				FROM bdibei: "informix".bei_contratacion
				WHERE empresa = "001"
				AND num_cliente = pNumcte
				AND status_contrato = '30';

				IF iDifDias IS NULL THEN
					LET sBandCargo = 0;
				ELSE
					IF iDifDias > 31 AND iDifDias < 361 THEN
						LET sBandCargo = 0;
					ELSE
						IF iDifDias < 32 THEN
							LET sBandCtaNva = 1;
						ELSE
							LET sBandCtaNva = 0;
						END IF

						LET iNumCtas = 0;
						LET cBandCtaValida = "0";
						LET iDifDias = 0;

						SELECT MAX(fecha_gencom)
						INTO sFecComBit
						FROM "informix".sc_bitacora_compm
						WHERE tpo_com = cTrananuaserv
						AND num_cte = pNumcte;

						LET sBandComBit = 0;

						IF sFecComBit IS NOT NULL THEN
							LET iDifDias = dtFechaHoy - sFecComBit;
							IF sBandCtaNva = 1 THEN
								LET sBandComBit = 1;
							ELIF sBandCtaNva = 0 THEN
								IF iDifDias < 361 THEN
									LET sBandComBit = 1;
								END IF
							END IF
						END IF

						IF sBandComBit = 0 THEN
							FOREACH
								SELECT LIMIT 1 cuenta
								INTO cPrimerCta
								FROM bdicheq:"informix".sc_maechq
								WHERE empresa = "001"
								AND num_cte = pNumcte
								ORDER BY cuenta
							END FOREACH

							SELECT serv_anualidad
							INTO mServAnualPrimCta
							FROM "informix".sc_maecomtasserv_pm
							WHERE cuenta = cPrimerCta;

							IF cPrimerCta IS NOT NULL THEN
								-- // OBTIENE EL SALDO DE LA CUENTA
								EXECUTE PROCEDURE "informix".cons_saldo(cPrimerCta)
								INTO cCodRetCS, mSaldoCta, cStaCtaCS;

								LET iNumCtas = 1;

								IF mServAnualPrimCta IS NOT NULL THEN
									LET dMontoAplica = mServAnualPrimCta;
								ELSE
									LET dMontoAplica = dMtoAplicComis;
								END IF

								IF mSaldoCta >= dMontoAplica THEN
									LET cBandPrimCtaValida = 1;
								END IF
							END IF

							IF cBandPrimCtaValida = 1 THEN
								LET pCuenta = cPrimerCta;
							ELSE
								--// SE BARREN LAS CUENTAS DE DEBITO DEL CTE
								FOREACH
									SELECT cuenta, saldo
									INTO cCtaCargoInaccta, mSaldoCta
									FROM
									(
										SELECT t1.cuenta, t1.sdo_actual - (t1.sdo_retenido + t1.sdo_cong + t1.imp_sbg_ccc + t1.saldo_sbc) AS saldo
										FROM "informix".sc_maechq t1, "informix".sc_maenoc t2
										WHERE t1.num_cte = pNumcte
										AND t1.cuenta = t2.cuenta
										AND t1.cuenta <> cPrimerCta
										AND t1.status_cta = "1"
										AND t1.producto IN ("1600","1200","2200")
										ORDER BY t2.fecha_alta
									)

									LET pCuenta = cCtaCargoInaccta;

									LET iNumCtas = iNumCtas + 1;

									IF iNumCtas = 1 THEN
										LET cPrimerCta = cCtaCargoInaccta;
									END IF

									SELECT serv_anualidad
									INTO mServAnualidad
									FROM "informix".sc_maecomtasserv_pm
									WHERE cuenta = pCuenta;

									IF mServAnualPrimCta IS NOT NULL THEN
										LET mServAnualidad = mServAnualPrimCta;
									ELSE
										LET mServAnualPrimCta = 0;
									END IF

									IF mServAnualidad IS NOT NULL THEN
										LET dMontoAplica = mServAnualidad;
									END IF

									IF dMontoAplica > mSaldoCta THEN
										CONTINUE FOREACH;
									ELSE
										LET cBandCtaValida = "1";
										EXIT FOREACH;
									END IF
								END FOREACH
							END IF

							-- VALIDA CUANDO NO HAY CUENTAS ACTIVAS PARA EL CLIENTE
							IF iNumCtas = 0 THEN
								LET sBandCargo = 0;
							ELSE
								IF dMontoAplica > 0 THEN
									LET sBandCargo = 1;
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF

			--// VALIDA SI SE CUMPLEN LAS CONDICIONES PARA SEGUIR CON EL CARGO
			IF sBandCargo = 1 THEN
				LET mDisponible = 0;
				LET mMtoCom = 0.0;
				LET mMontoPen = 0.0;
				LET	mIva = 0.0;
				LET cCodRetGF = "000";
				LET cFolioGF = "";
				LET cCodRetCR = "000";
				LET cComisionCR = "";

				let dMontoAplica = dMontoAplica;

				IF pTransacc = cTrananuaserv THEN
					INSERT INTO "informix".sc_bitacora_compm (tpo_com, num_cte, num_cta, fecha_gencom)
					VALUES (cTrananuaserv, pNumcte, pCuenta, dtFechaHoy);
					LET cDescTranRef = "COMISION X ANUALIDAD SERVICIO EMPRESANET";
					LET cDescIvaRef = "IVA COMISION X ANUALIDAD SERV EMPRESANET";
				END IF

				-- // OBTIENE EL SALDO DE LA CUENTA
				EXECUTE	PROCEDURE "informix".cons_saldo(pCuenta)
				INTO cCodRetCS, mDisponible, cStaCtaCS;

				-- // Aplica Cargo por Comision
				IF mDisponible > 0 THEN
					--// VALIDA SI EL SALDO DISPONIBLE ALCANZA PARA HACER EL COBRO SINO RECALCULA LA COMISION Y EL IVA
					IF mDisponible < (dMontoAplica * (1 + dValIva)) THEN
						LET mMtoCom   = dMontoAplica;
						LET dMontoAplica = ROUND(mDisponible / (1 + dValIva),2);
						LET mMontoPen = mMtoCom - dMontoAplica;
						LET mIva = mDisponible - dMontoAplica;
					ELSE
						LET mIva = TRUNC((dMontoAplica * dValIva),2);
					END IF;
					--// GENERA EL FOLIO DEL MOVIMIENTO
					EXECUTE PROCEDURE "informix".sp_generafolionomina ("informix")
					INTO cCodRetGF, cFolioGF;
					IF cCodRetGF::INTEGER <> 0 THEN
						LET cCodRet = cCodRetGF;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", cTranCom, "0000", cFolioGF, pCuenta, 0, dMontoAplica, "01", cDescTranRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DEL IVA DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", vTranIva, "0000", cFolioGF, pCuenta, 0, mIva, "01", cDescIvaRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					-- // Registra comision pendiente si es el caso
					IF mMontoPen > 0 THEN
						INSERT INTO "informix".sc_detcomis
						VALUES("001", pCuenta, cTranCom, mMontoPen  , 0, TODAY, "", "P", cFolioGF);

						UPDATE "informix".sc_maechq
						SET com_pendiente =  com_pendiente + mMontoPen
						WHERE empresa = "001"
						AND cuenta  = pCuenta;
					END IF;
				ELSE
					INSERT INTO "informix".sc_detcomis
					VALUES("001", pCuenta, cTranCom, dMontoAplica, 0, TODAY, "", "P", cFolioGF);

					UPDATE "informix".sc_maechq
					SET com_pendiente =  com_pendiente + dMontoAplica
					WHERE empresa = "001"
					AND cuenta  = pCuenta;
				END IF;
			END IF
		END FOREACH
	END FOREACH

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para el cargo parametrizado de comisiones para personas morales',
'BD: bdicheq',
'AUTOR: Mohamed Carreon',
'FECHA: Octubre 2014',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_cargoxcomision_pm_comp2()
RETURNING
	CHAR(6)		AS cod_ret

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);

	DEFINE pNumcte			CHAR(20);
	DEFINE pCuenta			CHAR(20);
	DEFINE pProducto		CHAR(4);
	DEFINE pTransacc		CHAR(4);
	DEFINE dSdoPromMen		DECIMAL(18,2);
	DEFINE dMontoAplica		MONEY;
	DEFINE dMtoAplicComis	MONEY;
	DEFINE cAnioMesAnte		CHAR(6);
	DEFINE mValorSdoPos		MONEY;
	DEFINE mDisponible      MONEY(14,2);
	DEFINE cCodRetGF		CHAR(3);
	DEFINE cFolioGF			CHAR(16);
	DEFINE cCodRetCR		CHAR(5);
	DEFINE cComisionCR		CHAR(4);
	DEFINE mIva				MONEY(14,2);
	DEFINE dValIva			DECIMAL(9,6);
	DEFINE mMontoPen		MONEY(14,2);
	DEFINE mMtoCom			MONEY(14,2);
	DEFINE cTranCom         CHAR(4);
	DEFINE vTranIva         CHAR(4);
	DEFINE mSdoPromMM		MONEY;
	DEFINE mComCgoNoSMM		MONEY;
	DEFINE cTpoPersona		CHAR(1);
	DEFINE mComInacCta		MONEY;
	DEFINE dtFecUltDep		DATE;
	DEFINE dtFecUltRet		DATE;
	DEFINE dtFecUltMov		DATE;

	DEFINE iDifDias			INT8;
	DEFINE sBandCtaNva		SMALLINT;
	DEFINE sBandCargo		SMALLINT;
	DEFINE cDescTranRef		CHAR(40);
	DEFINE cDescIvaRef		CHAR(40);
	DEFINE sFecComision		DATE;
	DEFINE mAcumSdoPos		MONEY;
	DEFINE iDiaSdoPos		SMALLINT;
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaAlta		DATE;
	DEFINE mServAnualidad	MONEY;
	DEFINE mServAnualPrimCta	MONEY;
    DEFINE dtConsMovhis 	DATE;
    DEFINE dtConsMovhisold 	DATE;
    DEFINE dtConsMovhisold2 DATE;
	DEFINE sBandDetcomis	SMALLINT;
	DEFINE cTranSdoprommm	CHAR(4);
	DEFINE cTranInaccta		CHAR(4);
	DEFINE cTrananuaserv	CHAR(4);
	DEFINE cCtaCargoInaccta	CHAR(20);
	DEFINE cPrimerCta		CHAR(20);
	DEFINE mSaldoCta		MONEY;
	DEFINE iNumCtas			SMALLINT;
	DEFINE cBandCtaValida	CHAR(1);
	DEFINE cBandPrimCtaValida	CHAR(1);
	DEFINE sFecComBit		DATE;
	DEFINE sBandComBit		SMALLINT;
	DEFINE cCodRetCS		CHAR(5);
	DEFINE cStaCtaCS		CHAR(1);




	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";

	LET pNumcte				= "";
	LET pCuenta				= "";
	LET pProducto			= "";
	LET pTransacc			= "";
	LET dSdoPromMen			= 0.0;
	LET dMontoAplica		= 0.0;
	let dMtoAplicComis		= 0.0;
	LET cAnioMesAnte		= "";
	LET mValorSdoPos		= 0.0;
	LET mDisponible  		= 0;
	LET cCodRetGF			= "000";
	LET cFolioGF			= "";
	LET cCodRetCR			= "000";
	LET cComisionCR			= "";
	LET	mIva				= 0.0;
	LET dValIva				= 0.0;
	LET mMontoPen			= 0.0;
	LET mMtoCom             = 0.0;
	LET cTranCom         	= "";
	LET vTranIva         	= 0.0;
	LET mSdoPromMM			= 0.0;
	LET mComCgoNoSMM		= 0.0;
	LET cTpoPersona			= "";
	LET mComInacCta			= 0.0;
	LET dtFecUltDep			= NULL;
	LET dtFecUltRet			= NULL;
	LET dtFecUltMov			= NULL;
	LET iDifDias			= 0;
	LET sBandCtaNva			= NULL;
	LET sBandCargo			= 0;
	LET cDescTranRef		= "";
	LET cDescIvaRef			= "";
	LET sFecComision		= NULL;
	LET mAcumSdoPos			= 0.0;
	LET iDiaSdoPos			= 0;
	LET dtFechaHoy			= DATE(1);
	LET dtFechaAlta			= DATE(1);
	LET mServAnualidad		= 0.0;
	LET mServAnualPrimCta	= 0.0;
    LET dtConsMovhis 		= DATE(1);
    LET dtConsMovhisold 	= DATE(1);
    LET dtConsMovhisold2 	= DATE(1);
	LET sBandDetcomis		= 0;
	LET cTranSdoprommm		= "";
	LET cTranInaccta		= "";
	LET cTrananuaserv		= "";
	LET cCtaCargoInaccta	= "";
	LET mSaldoCta			= 0.0;
	LET cPrimerCta			= "";
	LET iNumCtas			= 0;
	LET cBandCtaValida		= "0";
	LET cBandPrimCtaValida	= 0;
	LET sFecComBit			= DATE(1);
	LET sBandComBit			= 0;
	LET cCodRetCS			= "000";
	LET cStaCtaCS			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/moha/sp_cargoxcomision_pm.out';
	--TRACE ON;

	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sc_fechas
	WHERE empresa = "001";

	SELECT TRIM(valor)
	INTO cTranSdoprommm
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transdoprommm';

	SELECT TRIM(valor)
	INTO cTranInaccta
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transinaccta1';

	SELECT TRIM(valor)
	INTO cTrananuaserv
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transanuserven';

	--// OBTIENE EL VALOR DEL PARAMETRO DEL IVA
	SELECT TRIM(valor)
	INTO dValIva
	FROM bdinteg:"informix".si_param
	WHERE empresa = "001"
	AND cod_param = 47;

	-- CICLO DE LAS TRANSACCIONES
	FOREACH
		SELECT TRIM(valor)
		INTO pTransacc
		FROM "informix".sc_param
		WHERE empresa = "001"
		AND codparam IN ("transdoprommm","transinaccta1","transanuserven")

		--// OBTIENE EL VALOR DE LA COMISION A COBRAR DE LA TABLA sc_comisiones
		SELECT monto_aplica, transacc_com, transacc_iva
		INTO dMtoAplicComis, cTranCom, vTranIva
		FROM "informix".sc_comisiones
		WHERE empresa = "001"
		AND comision = pTransacc;

		LET dMtoAplicComis = NVL(dMtoAplicComis,0);

		--// CICLO PRINCIPAL DONDE BARRE TODAS LAS CUENTAS DE PERSONA MORAL
		FOREACH
			SELECT mae.cuenta, mae.producto, mae.num_cte, fecultdep, fecultret, pro.sdoprommen, noc.fecha_alta
			INTO pCuenta, pProducto, pNumcte, dtFecUltDep, dtFecUltRet, dSdoPromMen, dtFechaAlta
			FROM "informix".sc_producto pro, "informix".sc_maechq mae, "informix".sc_maenoc noc
			WHERE pro.empresa = "001"
			AND pro.producto = mae.producto
			AND pro.pago_interes = 'M'
			AND mae.empresa = pro.empresa
			AND mae.producto = pro.producto
			AND pro.producto IN ("1600","1200","2200")
			AND mae.status_cta IN ("1","4","5")
			AND noc.empresa = mae.empresa
			AND noc.cuenta = mae.cuenta

			LET sBandCargo = 0;

			IF pTransacc = cTranSdoprommm THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION / CARGO POR NO TENER SALDO PROMEDIO MINIMO MENSUAL
				LET mSdoPromMM = 0.0;
				LET mComCgoNoSMM = 0.0;
				LET mAcumSdoPos	= 0.0;
				LET iDiaSdoPos = 0;

				--// OBTIENE EL SALDO PROMEDIO MENSUAL Y LA COMISION EN LA TABLA MAESTRA DE LAS COMISIONES DE LA CUENTAS DE PERSONAS MORALES
				SELECT sdo_prom_mm, com_cgo_no_smm
				INTO mSdoPromMM, mComCgoNoSMM
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;
				
				IF mSdoPromMM IS NOT NULL THEN
					LET dSdoPromMen = mSdoPromMM;
				ELSE
					LET mSdoPromMM = 0;

				END IF

				IF mComCgoNoSMM IS NOT NULL THEN
					LET dMontoAplica = mComCgoNoSMM;
				ELSE
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- OBTIENE EL ANIO Y EL MES ANTERIOR
					LET cAnioMesAnte = YEAR(dtFechaHoy - 1 units MONTH) || LPAD(MONTH(dtFechaHoy - 1 units MONTH),2,"0");
					--// OBTIENE EL VALOR ACUMULADO Y EL DIA DEL SALDO POS DE LA CUENTA
					SELECT acum_sdo_pos, dia_sdo_pos
					INTO mAcumSdoPos, iDiaSdoPos
					FROM "informix".sc_maehis
					WHERE aniomes = cAnioMesAnte
					AND cuenta = pCuenta;

					LET mAcumSdoPos = NVL(mAcumSdoPos, 0);
					LET iDiaSdoPos = NVL(iDiaSdoPos, 0);

					IF iDiaSdoPos = 0 THEN
						LET mValorSdoPos = 0;
					ELSE
						LET mValorSdoPos = mAcumSdoPos / iDiaSdoPos;
					END IF

					--// VALIDA SI EL SALDO POS ES MENOR AL SALDO PROMEDIO DE LA sc_producto
					IF mValorSdoPos < dSdoPromMen AND pCuenta not in(SELECT cuenta FROM sc_detcomis where comision = "3290" AND fecha_alta = "01012016") THEN
						LET sBandCargo = 1;
						LET cDescTranRef = "COMISION X NO TENER SALDO PROMEDIO MENS";
						LET cDescIvaRef = "IVA COMISION X NO TENER SALDO PROM MENS";
					END IF
				END IF
			ELIF pTransacc = cTranInaccta THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR INACTIVIDAD DE LA CUENTA DURANTE 1 ANIO
				LET mComInacCta = 0;
				LET dtFecUltMov	= NULL;

				SELECT com_ina_cta
				INTO mComInacCta
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mComInacCta IS NOT NULL THEN
					LET dMontoAplica = mComInacCta;
				ELSE
					LET mComInacCta = 0;
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- VALIDA QUE LA CUENTA TENGA POR LO MENOS UN ANIO DE VIDA
					IF (dtFechaHoy - dtFechaAlta) > 360 THEN

						IF dtFecUltDep IS NULL AND dtFecUltRet IS NULL THEN
							LET sBandCargo = 1;
						ELSE
							IF dtFecUltDep IS NOT NULL THEN
								LET dtFecUltMov = dtFecUltDep;
							END IF

							IF dtFecUltRet IS NOT NULL THEN
								IF dtFecUltRet > dtFecUltMov THEN
									LET dtFecUltMov = dtFecUltRet;
								END IF
							END IF

							IF (dtFechaHoy - dtFecUltMov) < 361 THEN
								LET sBandCargo = 0;
							ELSE
								LET sBandCargo = 1;
								LET cDescTranRef = "COMISION X INACTIVIDAD DE LA CTA 1 ANIO";
								LET cDescIvaRef = "IVA COMISION X INACT DE LA CTA 1 ANIO";
							END IF
						END IF
					END IF
				END IF
			ELIF pTransacc = cTrananuaserv THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR ANUALIDAD DEL SERVICIO DE EMPRESANET
				LET iDifDias = 0;
				LET sBandCtaNva = NULL;
				LET iNumCtas = 0;
				LET cBandCtaValida = "0";
				LET sFecComBit = DATE(1);
				LET sBandComBit	= 0;
				LET cPrimerCta = "";
				LET mServAnualPrimCta = 0.0;
				LET mServAnualidad = 0.0;
				LET mSaldoCta = 0.0;
				LET cCtaCargoInaccta = "";

				--// OBTIENE EL NUMERO DE DIAS DE LA FECHA ACTUAL RESPECTO A SU FECHA DE REGISTRO
				SELECT dtFechaHoy - f_registro
				INTO iDifDias
				FROM bdibei: "informix".bei_contratacion
				WHERE empresa = "001"
				AND num_cliente = pNumcte
				AND status_contrato = '30';

				IF iDifDias IS NULL THEN
					LET sBandCargo = 0;
				ELSE
					IF iDifDias > 31 AND iDifDias < 361 THEN
						LET sBandCargo = 0;
					ELSE
						IF iDifDias < 32 THEN
							LET sBandCtaNva = 1;
						ELSE
							LET sBandCtaNva = 0;
						END IF

						LET iNumCtas = 0;
						LET cBandCtaValida = "0";
						LET iDifDias = 0;

						SELECT MAX(fecha_gencom)
						INTO sFecComBit
						FROM "informix".sc_bitacora_compm
						WHERE tpo_com = cTrananuaserv
						AND num_cte = pNumcte;

						LET sBandComBit = 0;

						IF sFecComBit IS NOT NULL THEN
							LET iDifDias = dtFechaHoy - sFecComBit;
							IF sBandCtaNva = 1 THEN
								LET sBandComBit = 1;
							ELIF sBandCtaNva = 0 THEN
								IF iDifDias < 361 THEN
									LET sBandComBit = 1;
								END IF
							END IF
						END IF

						IF sBandComBit = 0 THEN
							FOREACH
								SELECT LIMIT 1 cuenta
								INTO cPrimerCta
								FROM bdicheq:"informix".sc_maechq
								WHERE empresa = "001"
								AND num_cte = pNumcte
								ORDER BY cuenta
							END FOREACH

							SELECT serv_anualidad
							INTO mServAnualPrimCta
							FROM "informix".sc_maecomtasserv_pm
							WHERE cuenta = cPrimerCta;

							IF cPrimerCta IS NOT NULL THEN
								-- // OBTIENE EL SALDO DE LA CUENTA
								EXECUTE PROCEDURE "informix".cons_saldo(cPrimerCta)
								INTO cCodRetCS, mSaldoCta, cStaCtaCS;

								LET iNumCtas = 1;

								IF mServAnualPrimCta IS NOT NULL THEN
									LET dMontoAplica = mServAnualPrimCta;
								ELSE
									LET dMontoAplica = dMtoAplicComis;
								END IF

								IF mSaldoCta >= dMontoAplica THEN
									LET cBandPrimCtaValida = 1;
								END IF
							END IF

							IF cBandPrimCtaValida = 1 THEN
								LET pCuenta = cPrimerCta;
							ELSE
								--// SE BARREN LAS CUENTAS DE DEBITO DEL CTE
								FOREACH
									SELECT cuenta, saldo
									INTO cCtaCargoInaccta, mSaldoCta
									FROM
									(
										SELECT t1.cuenta, t1.sdo_actual - (t1.sdo_retenido + t1.sdo_cong + t1.imp_sbg_ccc + t1.saldo_sbc) AS saldo
										FROM "informix".sc_maechq t1, "informix".sc_maenoc t2
										WHERE t1.num_cte = pNumcte
										AND t1.cuenta = t2.cuenta
										AND t1.cuenta <> cPrimerCta
										AND t1.status_cta = "1"
										AND t1.producto IN ("1600","1200","2200")
										ORDER BY t2.fecha_alta
									)

									LET pCuenta = cCtaCargoInaccta;

									LET iNumCtas = iNumCtas + 1;

									IF iNumCtas = 1 THEN
										LET cPrimerCta = cCtaCargoInaccta;
									END IF

									SELECT serv_anualidad
									INTO mServAnualidad
									FROM "informix".sc_maecomtasserv_pm
									WHERE cuenta = pCuenta;

									IF mServAnualPrimCta IS NOT NULL THEN
										LET mServAnualidad = mServAnualPrimCta;
									ELSE
										LET mServAnualPrimCta = 0;
									END IF

									IF mServAnualidad IS NOT NULL THEN
										LET dMontoAplica = mServAnualidad;
									END IF

									IF dMontoAplica > mSaldoCta THEN
										CONTINUE FOREACH;
									ELSE
										LET cBandCtaValida = "1";
										EXIT FOREACH;
									END IF
								END FOREACH
							END IF

							-- VALIDA CUANDO NO HAY CUENTAS ACTIVAS PARA EL CLIENTE
							IF iNumCtas = 0 THEN
								LET sBandCargo = 0;
							ELSE
								IF dMontoAplica > 0 THEN
									LET sBandCargo = 1;
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF

			--// VALIDA SI SE CUMPLEN LAS CONDICIONES PARA SEGUIR CON EL CARGO
			IF sBandCargo = 1 THEN
				LET mDisponible = 0;
				LET mMtoCom = 0.0;
				LET mMontoPen = 0.0;
				LET	mIva = 0.0;
				LET cCodRetGF = "000";
				LET cFolioGF = "";
				LET cCodRetCR = "000";
				LET cComisionCR = "";

				let dMontoAplica = dMontoAplica;

				IF pTransacc = cTrananuaserv THEN
					INSERT INTO "informix".sc_bitacora_compm (tpo_com, num_cte, num_cta, fecha_gencom)
					VALUES (cTrananuaserv, pNumcte, pCuenta, dtFechaHoy);
					LET cDescTranRef = "COMISION X ANUALIDAD SERVICIO EMPRESANET";
					LET cDescIvaRef = "IVA COMISION X ANUALIDAD SERV EMPRESANET";
				END IF

				-- // OBTIENE EL SALDO DE LA CUENTA
				EXECUTE	PROCEDURE "informix".cons_saldo(pCuenta)
				INTO cCodRetCS, mDisponible, cStaCtaCS;

				-- // Aplica Cargo por Comision
				IF mDisponible > 1.00 THEN
					--// VALIDA SI EL SALDO DISPONIBLE ALCANZA PARA HACER EL COBRO SINO RECALCULA LA COMISION Y EL IVA
					IF mDisponible < (dMontoAplica * (1 + dValIva)) THEN
						LET mMtoCom   = dMontoAplica;
						LET dMontoAplica = ROUND(mDisponible / (1 + dValIva),2);
						LET mMontoPen = mMtoCom - dMontoAplica;
						LET mIva = mDisponible - dMontoAplica;
					ELSE
						LET mIva = TRUNC((dMontoAplica * dValIva),2);
					END IF;
					--// GENERA EL FOLIO DEL MOVIMIENTO
					EXECUTE PROCEDURE "informix".sp_generafolionomina ("informix")
					INTO cCodRetGF, cFolioGF;
					IF cCodRetGF::INTEGER <> 0 THEN
						LET cCodRet = cCodRetGF;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", cTranCom, "0000", cFolioGF, pCuenta, 0, dMontoAplica, "01", cDescTranRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DEL IVA DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", vTranIva, "0000", cFolioGF, pCuenta, 0, mIva, "01", cDescIvaRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					-- // Registra comision pendiente si es el caso
					IF mMontoPen > 0 THEN
						INSERT INTO "informix".sc_detcomis
						VALUES("001", pCuenta, cTranCom, mMontoPen  , 0, TODAY, "", "P", cFolioGF);

						UPDATE "informix".sc_maechq
						SET com_pendiente =  com_pendiente + mMontoPen
						WHERE empresa = "001"
						AND cuenta  = pCuenta;
					END IF;
				ELSE
					INSERT INTO "informix".sc_detcomis
					VALUES("001", pCuenta, cTranCom, dMontoAplica, 0, TODAY, "", "P", cFolioGF);

					UPDATE "informix".sc_maechq
					SET com_pendiente =  com_pendiente + dMontoAplica
					WHERE empresa = "001"
					AND cuenta  = pCuenta;
				END IF;
			END IF
		END FOREACH
	END FOREACH

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para el cargo parametrizado de comisiones para personas morales',
'BD: bdicheq',
'AUTOR: Mohamed Carreon',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2';

create procedure "informix".segurofun(pempresa char(3))
       returning char(5);

   define vcodret char(5);
   define vsqlerr integer;
   define vfecha_hoy date;
   define vusuario char(8);
   define vsdo_actual,vsdodisp,vsdo_actual2,vsdodisp2 money(14,2);
   define vhora datetime hour to fraction(3);
   define vfolio_suc,vhorax char(16);
   define vsdominacc,vimpsegurof money(14,2);
   define vedad,vedadmaxsegf smallint;
   define vtransegurof char(4);
   define vprodacciones char(4);
   define vprodahorros char(4);
   define vnumcte char(20);
   define vfecha_nac date;
   define vcuenta, vcuenta2 char(20);
   define vproducto, vproducto2 char(4);
   define vsucursal, vsucursal2 char(4);
   define vmonto_tot, vmonto_tot2 money(14,2);
   define vfecha_operacion date;


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;
   
	 --SET DEBUG FILE TO "/informix/moha/segurofun.out";
     --TRACE ON;

   let vcodret = "000";
   let vusuario = user;
   let vfecha_operacion = TODAY;
   
   select fecha_hoy into vfecha_hoy
      from sc_fechas
      where empresa = pempresa;

   select valor into vimpsegurof
      from sc_param
      where empresa = pempresa and codparam = "impsegurof";

   select valor into vsdominacc
      from sc_param
      where empresa = pempresa and codparam = "sdominacc";

   select valor into vedadmaxsegf
      from sc_param
      where empresa = pempresa and codparam = "edadmaxsegf";

   select valor into vtransegurof
      from sc_param
      where empresa = pempresa and codparam = "transegurof";

   select valor into vprodacciones
      from sc_param
      where empresa = pempresa and codparam = "prodacciones";

   select valor into vprodahorros
      from sc_param
      where empresa = pempresa and codparam = "prodahorros";

   foreach
      select numcte,fecha_nac into vnumcte,vfecha_nac
         from bdinteg:si_ctepf 
         where seguro_defunc = "1"
      let vedad = year(vfecha_hoy) - year(vfecha_nac);
      if vedad > vedadmaxsegf then
         continue foreach;
      end if
      
      --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
      select cuenta,producto,sucursal,sdo_actual,
             sdo_actual-sdo_retenido-sdo_cong-saldo_sbc
         into vcuenta2,vproducto2,vsucursal2,vsdo_actual2,vsdodisp2
         from sc_maechq
         where empresa = pempresa and num_cte = vnumcte and
               producto = vprodacciones;
      -- Valida saldo en acciones
      if vsdo_actual2 < vsdominacc or vsdo_actual2 is null then
         continue foreach;
      end if
    
    --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
      select cuenta,producto,sucursal,sdo_actual,
             sdo_actual-sdo_retenido-sdo_cong-saldo_sbc
         into vcuenta,vproducto,vsucursal,vsdo_actual,vsdodisp
         from sc_maechq
         where empresa = pempresa and num_cte = vnumcte and
               producto = vprodahorros;
      if vsdodisp is null then
         let vsdodisp = 0;
      end if
      if vsdodisp >= vimpsegurof then
         let vmonto_tot = vimpsegurof;
         let vmonto_tot2 = 0;
      else
         let vmonto_tot = vsdodisp;
         let vsdodisp2 = vsdodisp2 - vsdominacc;
         if vsdodisp2 >= vimpsegurof - vmonto_tot then
            let vmonto_tot2 = vimpsegurof - vmonto_tot;
         else
            continue foreach;
         end if
      end if
      let vhora = current hour to fraction(3);
      let vhorax = vhora;
      let vfolio_suc = vusuario||vhorax[1,2]||vhorax[4,5]||vhorax[7,8]||
                      vhorax[10,11];
      if vmonto_tot > 0 then
         insert into sc_movdia
            values(0,vfolio_suc,vsucursal,vusuario,vfecha_hoy,vfecha_hoy,
               vhora,vtransegurof,vsucursal,vproducto,pempresa,vcuenta," ",0,
               vmonto_tot,vmonto_tot,0,0,0," "," ",vsdo_actual,"0000"," ",0,"","","",vfecha_operacion);
         update sc_maechq
            set (sdo_actual,imp_cgos_mes,num_cgos_mes,fec_ult_mov) =
                (sdo_actual - vmonto_tot, imp_cgos_mes + vmonto_tot,
	        num_cgos_mes + 1, vfecha_hoy)
            where empresa = pempresa and cuenta = vcuenta;
      end if
      if vmonto_tot2 > 0 then
         let vhora = current hour to fraction(3);
         insert into sc_movdia
            values(0,vfolio_suc,vsucursal2,vusuario,vfecha_hoy,vfecha_hoy,
               vhora,vtransegurof,vsucursal2,vproducto2,pempresa,vcuenta2," ",0,
               vmonto_tot2,vmonto_tot2,0,0,0," "," ",vsdo_actual2,"0000"," ",0,"","","",vfecha_operacion);
         update sc_maechq
            set (sdo_actual,imp_cgos_mes,num_cgos_mes,fec_ult_mov) =
                (sdo_actual - vmonto_tot2, imp_cgos_mes + vmonto_tot2,
	         num_cgos_mes + 1, vfecha_hoy)
            where empresa = pempresa and cuenta = vcuenta2;
      end if
   end foreach
   return vcodret;
end
end procedure

DOCUMENT
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               el campo de saldo inmovilizado por motivo de cobranza automatica de credito (saldo_sbc)',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".sp_consinvercte(pEmpresa CHAR(3),pNumcte CHAR(20),pUltreg SMALLINT)
RETURNING 
	CHAR (6) AS CodRetorno,
	CHAR (20) AS NumeroInversion,
	MONEY (14,2) AS MontoInversion,
	CHAR (1) AS Status,
	DATE AS FechaApertura,
	DATE AS FechaVencimiento,
	SMALLINT AS AntiguedadMeses,
	CHAR (61) AS Autorizado,
	CHAR (20) AS NumcteAutorizado;
		

	DEFINE cCodRetorno CHAR(6);
	DEFINE cNumeroInversion CHAR(20);
	DEFINE mMontoInversion MONEY(14,2);
	DEFINE cStatus CHAR(1);
	DEFINE dFechaApertura DATE;
	DEFINE dFechaVencimiento DATE;
	DEFINE sAntiguedadMeses SMALLINT;
	DEFINE cAutorizado CHAR(61);
	DEFINE cNumcte CHAR(20);
	DEFINE iSqlErr INTEGER;
	DEFINE sConreg SMALLINT;
	DEFINE cExiste CHAR (1);

	LET cCodRetorno = '000000';
	LET cNumeroInversion = '';
	LET mMontoInversion = 0;
	LET cStatus = '';
	LET dFechaApertura = '';
	LET dFechaVencimiento = '';
	LET sAntiguedadMeses = 0;
	LET cAutorizado = '';
	LET cNumcte = '';
	LET iSqlErr = 0;
	LET sConreg = 0;
	LET cExiste = '';
	
	-- SET DEBUG FILE TO 'respaldosbd\mario\trace.sql';
	-- TRACE ON;		

    BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRetorno = iSqlErr;
			   RETURN cCodRetorno,cNumeroInversion,mMontoInversion,cStatus,dFechaApertura,dFechaVencimiento,sAntiguedadMeses,cAutorizado,cNumcte;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	
	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumcte,'') = '' THEN
		LET cCodRetorno = "000001";
	ELSE
		SELECT 1 
		INTO cExiste
		FROM  bdinteg:"informix".si_cliente
		WHERE  empresa = pEmpresa AND numcte = pNumcte;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRetorno = '000002';			
		ELSE		
			FOREACH
				--RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
				SELECT DISTINCT sc_mcq.cuenta,sc_mcq.sdo_actual-sc_mcq.sdo_cong-sc_mcq.sdo_retenido-sc_mcq.saldo_sbc AS montoInversion,'A',
				sc_mcq.fecultdep,sc_mnoc.fecha_mod,TRUNC(MONTHS_BETWEEN(CURRENT,sc_mcq.fecultdep))
			    INTO cNumeroInversion,mMontoInversion,cStatus,dFechaApertura,dFechaVencimiento,sAntiguedadMeses				
				FROM bdicheq:"informix".sc_firmantes as firmantes,
				bdicheq:"informix".sc_maechq AS sc_mcq,
				bdicheq:"informix".sc_maenoc AS sc_mnoc
				WHERE firmantes.numcte = pNumcte
			     AND sc_mcq.empresa = pEmpresa
				AND sc_mcq.producto = '1100'
				AND sc_mcq.status_cta = '1'
				AND firmantes.cuenta = sc_mcq.cuenta
				AND sc_mcq.cuenta = sc_mnoc.cuenta				
				ORDER BY sc_mcq.cuenta ASC
						
				LET sConreg = sConreg + 1;	
				
				IF sConreg <= pUltreg THEN 					
					CONTINUE FOREACH;
				END IF;	
				
				
				SELECT fir.numcte,TRIM(cte.nombre1) ||' '|| TRIM(cte.nombre2)||' '|| TRIM(cte.apell_paterno)||' '|| TRIM(cte.apell_materno) AS nombre
				INTO cNumcte,cAutorizado
				FROM bdicheq:"informix".sc_firmantes AS fir,
				bdinteg:"informix".si_cliente as cte
				WHERE fir.empresa =  pEmpresa
				AND fir.empresa = cte.empresa
				AND fir.numcte = cte.numcte
				AND fir.cuenta = cNumeroInversion
				AND fir.secuencia = 2;		
				
				IF NVL(cAutorizado,'') = '' THEN
					LET cAutorizado= '';
				END IF;
				IF NVL(cNumcte,'') = '' THEN
					LET cNumcte= '';
				END IF;
				
				RETURN cCodRetorno,cNumeroInversion,mMontoInversion,cStatus,dFechaApertura,dFechaVencimiento,sAntiguedadMeses,cAutorizado,cNumcte WITH RESUME;
		
			END FOREACH
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRetorno = '000003';			
			END IF;
		END IF;
	END IF;
END
END PROCEDURE
DOCUMENT
'Folio: 350',
'Autor: 97877352 Rubio Lugo Jesus Alberto',
'BD: bdicheq',
'Fecha: 06/12/2017',
'Descripcion: Se Modifica procedimiento para obtener todas las cuentas de inversion creciente activas del cliente y del adicional',
---------------------------------
'Folio: 180',
'Autor: 97247642 Alexis Ibarra',
'BD: bdicheq',
'Fecha: 14/03/2017',
'Descripcion: Se crea procedimiento para obtener todas las cuentas de inversion creciente activas del cliente',
---------------------------------
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               el campo de saldo inmovilizado por motivo de cobranza automatica de credito (saldo_sbc)',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".sp_consinvercte_web(pEmpresa CHAR(3),pNumcte CHAR(20),pUltreg SMALLINT)
RETURNING 
  CHAR (6) AS CodRetorno,
  CHAR (20) AS NumeroInversion,
  MONEY (14,2) AS MontoInversion,
  CHAR (1) AS Status,
  DATE AS FechaApertura,
  DATE AS FechaVencimiento,
  SMALLINT AS AntiguedadMeses,
  CHAR (61) AS Autorizado,
  CHAR (20) AS NumcteAutorizado;
    

  DEFINE cCodRetorno CHAR(6);
  DEFINE cNumeroInversion CHAR(20);
  DEFINE mMontoInversion MONEY(14,2);
  DEFINE cStatus CHAR(1);
  DEFINE dFechaApertura DATE;
  DEFINE dFechaVencimiento DATE;
  DEFINE sAntiguedadMeses SMALLINT;
  DEFINE cAutorizado CHAR(61);
  DEFINE cNumcte CHAR(20);
  DEFINE iSqlErr INTEGER;
  DEFINE sConreg SMALLINT;
  DEFINE cExiste CHAR (1);

  LET cCodRetorno = '00000';
  LET cNumeroInversion = '';
  LET mMontoInversion = 0;
  LET cStatus = '';
  LET dFechaApertura = '';
  LET dFechaVencimiento = '';
  LET sAntiguedadMeses = 0;
  LET cAutorizado = '';
  LET cNumcte = '';
  LET iSqlErr = 0;
  LET sConreg = 0;
  LET cExiste = '';
  
  -- SET DEBUG FILE TO 'respaldosbd\mario\trace.sql';
  -- TRACE ON;    

    BEGIN
    ON EXCEPTION SET iSqlErr
      IF iSqlErr <> 0 THEN
        LET cCodRetorno = iSqlErr;
         RETURN cCodRetorno,cNumeroInversion,mMontoInversion,cStatus,dFechaApertura,dFechaVencimiento,sAntiguedadMeses,cAutorizado,cNumcte;
      END IF;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
  
  
  IF NVL(pEmpresa,'') = '' OR NVL(pNumcte,'') = '' THEN
    LET cCodRetorno = "00001";
  ELSE
    SELECT 1 
    INTO cExiste
    FROM  bdinteg:"informix".si_cliente
    WHERE  empresa = pEmpresa AND numcte = pNumcte;

    IF DBINFO('sqlca.sqlerrd2') = 0 THEN
      LET cCodRetorno = '00002';     
    ELSE    
      FOREACH
        --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
        SELECT DISTINCT sc_mcq.cuenta,sc_mcq.sdo_actual-sc_mcq.sdo_cong-sc_mcq.sdo_retenido-sc_mcq.saldo_sbc AS montoInversion,'A',
        sc_mcq.fecultdep,sc_mnoc.fecha_mod,TRUNC(MONTHS_BETWEEN(CURRENT,sc_mcq.fecultdep))
          INTO cNumeroInversion,mMontoInversion,cStatus,dFechaApertura,dFechaVencimiento,sAntiguedadMeses       
        FROM bdicheq:"informix".sc_firmantes as firmantes,
        bdicheq:"informix".sc_maechq AS sc_mcq,
        bdicheq:"informix".sc_maenoc AS sc_mnoc
        WHERE firmantes.numcte = pNumcte
           AND sc_mcq.empresa = pEmpresa
        AND sc_mcq.producto = '1100'
        AND sc_mcq.status_cta = '1'
        AND firmantes.cuenta = sc_mcq.cuenta
        AND sc_mcq.cuenta = sc_mnoc.cuenta        
        ORDER BY sc_mcq.cuenta ASC
            
        LET sConreg = sConreg + 1;  
        
        IF sConreg <= pUltreg THEN          
          CONTINUE FOREACH;
        END IF; 
        
        
        SELECT fir.numcte,TRIM(cte.nombre1) ||' '|| TRIM(cte.nombre2)||' '|| TRIM(cte.apell_paterno)||' '|| TRIM(cte.apell_materno) AS nombre
        INTO cNumcte,cAutorizado
        FROM bdicheq:"informix".sc_firmantes AS fir,
        bdinteg:"informix".si_cliente as cte
        WHERE fir.empresa =  pEmpresa
        AND fir.empresa = cte.empresa
        AND fir.numcte = cte.numcte
        AND fir.cuenta = cNumeroInversion
        AND fir.secuencia = 2;    
        
        IF NVL(cAutorizado,'') = '' THEN
          LET cAutorizado= '';
        END IF;
        IF NVL(cNumcte,'') = '' THEN
          LET cNumcte= '';
        END IF;
        
        RETURN cCodRetorno,cNumeroInversion,mMontoInversion,cStatus,dFechaApertura,dFechaVencimiento,sAntiguedadMeses,cAutorizado,cNumcte WITH RESUME;
    
      END FOREACH
      IF DBINFO('sqlca.sqlerrd2') = 0 THEN
        LET cCodRetorno = '00003';     
      END IF;
    END IF;
  END IF;
END
END PROCEDURE
DOCUMENT
'Folio: 350',
'Autor: 97877352 Rubio Lugo Jesus Alberto',
'BD: bdicheq',
'Fecha: 06/12/2017',
'Descripcion: Se Modifica procedimiento para obtener todas las cuentas de inversion creciente activas del cliente y del adicional',
---------------------------------
'Folio: 180',
'Autor: 97247642 Alexis Ibarra',
'BD: bdicheq',
'Fecha: 14/03/2017',
'Descripcion: Se crea procedimiento para obtener todas las cuentas de inversion creciente activas del cliente',
---------------------------------
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               el campo de saldo inmovilizado por motivo de cobranza automatica de credito (saldo_sbc)',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".cargo_retenido_comp(pempresa char(3))
RETURNING CHAR(5), INTEGER;

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vfecha           DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vsql             CHAR(200);
    DEFINE vfolio           CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vstatus          CHAR(1);
    DEFINE vimporte         MONEY(14,2);
    DEFINE vimport          MONEY(14,2);
    DEFINE vdisp            MONEY(14,2);
    DEFINE vsucursal        CHAR(4);
    DEFINE vtransacc        CHAR(4);
    DEFINE vfecha_cargo     DATE;
    DEFINE vdispo           MONEY(14,2);
    DEFINE vcargo           MONEY(14,2);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vexiste          INTEGER;
    DEFINE nComit           INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE vfechades        CHAR(10);
    DEFINE vfechadescarga   CHAR(6);
    DEFINE vdia             CHAR(2);
    DEFINE vmes             CHAR(2);
    DEFINE vanio            CHAR(2);
    DEFINE vnombre          VARCHAR(40);
    DEFINE vcargado         MONEY(14,2);
    DEFINE whora1           CHAR(5);
    DEFINE whora2           CHAR(2);
    DEFINE whora3           CHAR(2);
    DEFINE whora            CHAR(4);
    DEFINE vnumcte          CHAR(20);
    DEFINE vctacte          CHAR(20);
    DEFINE vsuc_cta         CHAR(4);
    DEFINE vexiste_cta      CHAR(1);
    DEFINE vaceptab         CHAR(1);
    DEFINE vacepcargo       CHAR(1);
    DEFINE vimporte_cargo   MONEY(14,2);
    DEFINE vcargados        MONEY(14,2);
    DEFINE vdisponible      MONEY(14,2);
    DEFINE vcargo_cta       MONEY(14,2);
    DEFINE vfecha_oper      DATE;
    DEFINE vbloqueada       SMALLINT;
	--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE mSdoActual		MONEY(14,2); --Monto del saldo actual de la cuenta.
	DEFINE mSdoRetenido     MONEY(14,2); --Monto del saldo retenido de la cuenta.
	DEFINE mSdoCong	        MONEY(14,2); --Monto del saldo congelado de la cuenta.
	DEFINE mSaldoSBC        MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET vcodret = "000";
    LET vcodret2 = "";
    LET vcodret3 = '';
    LET sql_err = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vfecha = '';
    LET vhora = '';
    LET vsql = '';
    LET vfolio = '';
    LET vcuenta = '';
    LET vstatus = '';
    LET vimporte = 0.00;
    LET vimport = 0.00;
    LET vdisp = 0.00;
    LET vsucursal = '';
    LET vtransacc = '';
    LET vfecha_cargo = '';
    LET vdispo = 0.00;
    LET vcargo = 0.00;
    LET vdescripcion = '';
    LET vexiste = 0;
    LET nComit = 0;
    LET vcontador = 0;
    LET vfechades = '';
    LET vfechadescarga = '';
    LET vdia = '';
    LET vmes = '';
    LET vanio = '';
    LET vnombre = '';
    LET vcargado = 0.00;
    LET whora1 = '';
    LET whora2 = '';
    LET whora3 = '';
    LET whora = '';
    LET vnumcte = '';
    LET vctacte = '';
    LET vsuc_cta = '';
    LET vexiste_cta = '';
    LET vaceptab = '';
    LET vacepcargo = '';
    LET vimporte_cargo = 0.00;
    LET vcargados = 0.00;
    LET vdisponible = 0.00;
    LET vcargo_cta = 0.00;
    LET vfecha_oper = '';
    LET vbloqueada = 0;
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSdoActual			=0.00;	
	LET mSdoRetenido		=0.00;
	LET mSdoCong			=0.00;
	LET mSaldoSBC   		=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/cargo_retenido_comp.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcontador;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/cargo_retenido_comp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
      INTO vfecha
      FROM sc_fechas
     WHERE empresa = pempresa;

    LET vhora  = CURRENT HOUR TO FRACTION;
    LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    TRUNCATE TABLE cargos;

    FOREACH WITH HOLD
        SELECT cuenta, importe, descripcion, fecha
          INTO vcuenta, vimporte, vdescripcion, vfecha_oper
          FROM cuentas
          
        BEGIN WORK;
        LET nComit = 1;

        --RQM 09 704.Se agregan las variables de saldo a la consulta para realizar posteriormente el calculo de saldo disponible.DHG
		SELECT sdo_actual,sdo_cong,sdo_retenido,saldo_sbc, sucursal, status_cta, num_cte
          INTO mSdoActual,mSdoCong,mSdoRetenido,mSaldoSBC, vsucursal, vstatus, vnumcte
          FROM sc_maechq
         WHERE cuenta = vcuenta;
         
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
		EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vdisp;        
		
		 
        LET vbloqueada = 0;
           
        IF vdisp > 0.00 THEN
            IF vstatus = 3 THEN
                UPDATE sc_maechq
                   SET status_cta = "1",
                       motivo = "00"
                 WHERE cuenta = vcuenta;

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste <> 0 THEN
                    DELETE FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;
                END IF

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_histbloq
                 WHERE cuenta = vcuenta
                   AND status_blo = "B"
                   AND tipo_mov = "B"
                   AND empresa = pempresa;

                IF vexiste <> 0 THEN
                    INSERT INTO sc_histbloq VALUES(pempresa, vcuenta, "D", "00", " ", 0.00, "informix", vfecha, current hour to fraction, "1111", "D", vfolio, " ", '', '', '', '');
                END IF
                
                LET vbloqueada = 0;
            END IF

            IF vdisp >= vimporte THEN
                CALL cargo_ref(pempresa, vsucursal, "informix", "0252", "0252", vfolio, vcuenta, 0, vimporte, "01", vdescripcion, '', "informix")
                RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo;

                IF vcodret = "000" THEN
                    LET vcargo = vcargo;
                    LET vbloqueada = 0;
                ELSE
                    LET vcargo = 0;
                    
                    UPDATE sc_maechq
                       SET status_cta = "3",
                           motivo = "09"
                     WHERE cuenta = vcuenta;

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;

                    IF vexiste = 0 THEN
                        INSERT INTO sc_ctabloqueo VALUES(vcuenta, "09", "3", '', '', '', '');
                    ELSE
                        UPDATE sc_ctabloqueo
                           SET clave = "09",
                               opcion = "3"
                         WHERE cuenta = vcuenta;
                    END IF

                    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");
                    INSERT INTO sc_histbloq VALUES(pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha,current hour to fraction,"1111","B",vfolio," ", '', '', '', '');
                    
                    LET vbloqueada = 1;
                END IF

                INSERT INTO cargos VALUES(vcuenta, vimporte, vcargo, vdescripcion, 'X', vfecha_oper);
            ELSE
                LET vimport = vdisp;

                CALL cargo_ref(pempresa, vsucursal, "informix", "0252", "0252", vfolio, vcuenta, 0, vimport, "01", vdescripcion, '', "informix")
                RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo;

                IF vcodret = "000" THEN
                    LET vcargo = vcargo;
                ELSE
                    LET vcargo = 0;
                END IF
                
                UPDATE sc_maechq
                   SET status_cta = "3",
                       motivo = "09"
                 WHERE cuenta = vcuenta;

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste = 0 THEN
                    INSERT INTO sc_ctabloqueo VALUES(vcuenta, "09", "3", '', '', '', '');
                ELSE 
                    UPDATE sc_ctabloqueo
                       SET clave = "09",
                           opcion = "3"
                     WHERE cuenta = vcuenta;
                END IF

                INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");
                INSERT INTO sc_histbloq VALUES(pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha, current hour to fraction,"1111","B",vfolio," ", '', '', '', '');
                
                INSERT INTO cargos VALUES(vcuenta, vimporte, vcargo, vdescripcion, 'X', vfecha_oper);
                
                LET vbloqueada = 1;
            END IF
        ELSE
            LET vcargo = 0;
            
            IF vstatus <> 3 THEN
                UPDATE sc_maechq
                   SET status_cta = "3",
                       motivo = "09"
                 WHERE cuenta = vcuenta;

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste = 0 THEN
                    INSERT INTO sc_ctabloqueo VALUES (vcuenta, "09", "3", '', '', '', '');
                ELSE 
                    UPDATE sc_ctabloqueo
                       SET clave = "09",
                           opcion = "3"
                     WHERE cuenta = vcuenta;
                END IF

                INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");
                INSERT INTO sc_histbloq VALUES(pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha, current hour to fraction,"1111","B",vfolio," ", '', '', '', '');
            END IF
            
            INSERT INTO cargos VALUES(vcuenta,vimporte,vcargo,vdescripcion, 'X', vfecha_oper);
            
            LET vbloqueada = 1;
        END IF;
        
        -- // CARGO A CUENTAS RELACIONADAS DEL CLIENTE
        IF vimporte > vcargo THEN
            LET vimporte_cargo = vimporte - vcargo;
            
            FOREACH WITH HOLD
                --RQM 09 704.Se agregan las variables de saldo a la consulta para realizar posteriormente el calculo de saldo disponible.DHG
				SELECT cuenta, sucursal, sdo_actual,sdo_cong,sdo_retenido,saldo_sbc
                  INTO vctacte, vsuc_cta, mSdoActual,mSdoCong,mSdoRetenido,mSaldoSBC
                  FROM sc_maechq
                 WHERE num_cte = vnumcte
                   AND cuenta <> vcuenta
                   AND status_cta IN('1','4','5')
                   AND producto <> '1100'
                
				--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
				EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vdisponible;        
		
				
                IF vdisponible > 0 THEN
                    IF vdisponible >= vimporte_cargo THEN
                        CALL cargo_ref(pempresa, vsuc_cta, "informix", "0252", "0252", vfolio, vctacte, 0, vimporte_cargo, "01", vdescripcion, '', "informix")
                        RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo_cta;
                        
                        IF vcodret = '000' THEN
                            IF vimporte_cargo = vcargo_cta THEN
                                INSERT INTO cargos VALUES(vcuenta, vimporte_cargo, vcargo_cta, vdescripcion, vctacte, vfecha_oper);
                                
                                IF vbloqueada = 1 THEN
                                    UPDATE sc_maechq
                                       SET status_cta = '1',
                                           motivo = '00'
                                     WHERE cuenta = vcuenta;
                                     
                                    DELETE FROM sc_ctabloqueo
                                     WHERE cuenta = vcuenta;
                                     
                                    INSERT INTO sc_histbloq VALUES(pempresa, vcuenta, "D", "00", " ", 0.00, "informix", vfecha, current hour to fraction, "1111", "D", vfolio, " ", '', '', '', '');
                                END IF;                                 
                                
                                EXIT FOREACH;
                            ELIF vimporte_cargo > vcargo_cta THEN
                                INSERT INTO cargos VALUES(vcuenta, vimporte_cargo, vcargo_cta, vdescripcion, vctacte, vfecha_oper);
                                LET vimporte_cargo = vimporte_cargo - vcargo_cta;
                                CONTINUE FOREACH;
                            END IF
                        ELSE
                            CONTINUE FOREACH;
                        END IF
                    ELSE
                        CALL cargo_ref(pempresa, vsuc_cta, "informix", "0252", "0252", vfolio, vctacte, 0, vdisponible, "01", vdescripcion, '', "informix")
                        RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo_cta;
                        
                        IF vcodret = '000' THEN
                            INSERT INTO cargos VALUES(vcuenta, vimporte_cargo, vcargo_cta, vdescripcion, vctacte, vfecha_oper);
                            LET vimporte_cargo = vimporte_cargo - vcargo_cta;
                            CONTINUE FOREACH;
                        ELSE
                            CONTINUE FOREACH;
                        END IF
                    END IF
                ELSE
                    CONTINUE FOREACH;
                END IF
            END FOREACH
        END IF
        
        LET vcontador = vcontador + 1;
        COMMIT WORK;
        LET nComit = 0;
    END FOREACH

    UPDATE STATISTICS MEDIUM FOR TABLE cuentas;
    UPDATE STATISTICS MEDIUM FOR TABLE cargos;

    LET whora1         = CURRENT HOUR TO MINUTE;
    LET whora2         = whora1[1,2];
    LET whora3         = whora1[4,5];
    LET whora          = whora2||whora3;
    LET vfechades      = TO_CHAR(vfecha, '%Y/%m/%d');
    LET vdia           = vfechades[9,10];
    LET vmes           = vfechades[6,7];
    LET vanio          = vfechades[3,4];
    LET vfechadescarga = vdia||vmes||vanio;
    LET vnombre        = 'aplicados_'||vfechadescarga||'_'||whora||'.txt';

    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/'||vnombre||' SELECT * FROM cargos" > /resplogifx/conciliachq/cargos.sql';
    SYSTEM vsql;
    
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargos.sql";
    SYSTEM vsql;
    
    TRUNCATE TABLE cuentas;
    
    FOREACH WITH HOLD
        SELECT cuenta, cargo, descripcion, fecha
          INTO vcuenta, vcargo, vdescripcion, vfecha_oper
          FROM cargos
         WHERE cuenta_rel = 'X'
        
        BEGIN WORK;
        
        SELECT SUM(cargado)
          INTO vcargado
          FROM cargos
         WHERE cuenta = vcuenta;
        
        LET vcargo = vcargo - vcargado;
          
        IF vcargo > 0 THEN
            INSERT INTO cuentas VALUES(vcuenta, vcargo, vdescripcion, vfecha_oper);
        END IF;
        
        COMMIT WORK;
    END FOREACH;

    END;

    RETURN vcodret, vcontador;

END PROCEDURE
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.1';

CREATE PROCEDURE "informix".sp_cargoxcomision_pm()
RETURNING CHAR(6) AS cod_ret
    
	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);

	DEFINE pNumcte			CHAR(20);
	DEFINE pCuenta			CHAR(20);
	DEFINE pProducto		CHAR(4);
	DEFINE pTransacc		CHAR(4);
	DEFINE dSdoPromMen		DECIMAL(18,2);
	DEFINE dMontoAplica		MONEY;
	DEFINE dMtoAplicComis	MONEY;
	DEFINE cAnioMesAnte		CHAR(6);
	DEFINE mValorSdoPos		MONEY;
	DEFINE mDisponible      MONEY(14,2);
	DEFINE cCodRetGF		CHAR(3);
	DEFINE cFolioGF			CHAR(16);
	DEFINE cCodRetCR		CHAR(5);
	DEFINE cComisionCR		CHAR(4);
	DEFINE mIva				MONEY(14,2);
	DEFINE dValIva			DECIMAL(9,6);
	DEFINE mMontoPen		MONEY(14,2);
	DEFINE mMtoCom			MONEY(14,2);
	DEFINE cTranCom         CHAR(4);
	DEFINE vTranIva         CHAR(4);
	DEFINE mSdoPromMM		MONEY;
	DEFINE mComCgoNoSMM		MONEY;
	DEFINE cTpoPersona		CHAR(1);
	DEFINE mComInacCta		MONEY;
	DEFINE dtFecUltDep		DATE;
	DEFINE dtFecUltRet		DATE;
	DEFINE dtFecUltMov		DATE;

	DEFINE iDifDias			INT8;
	DEFINE sBandCtaNva		SMALLINT;
	DEFINE sBandCargo		SMALLINT;
	DEFINE cDescTranRef		CHAR(40);
	DEFINE cDescIvaRef		CHAR(40);
	DEFINE sFecComision		DATE;
	DEFINE mAcumSdoPos		MONEY;
	DEFINE iDiaSdoPos		SMALLINT;
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaAlta		DATE;
	DEFINE mServAnualidad	MONEY;
	DEFINE mServAnualPrimCta	MONEY;
    DEFINE dtConsMovhis 	DATE;
    DEFINE dtConsMovhisold 	DATE;
    DEFINE dtConsMovhisold2 DATE;
	DEFINE sBandDetcomis	SMALLINT;
	DEFINE cTranSdoprommm	CHAR(4);
	DEFINE cTranInaccta		CHAR(4);
	DEFINE cTrananuaserv	CHAR(4);
	DEFINE cCtaCargoInaccta	CHAR(20);
	DEFINE cPrimerCta		CHAR(20);
	DEFINE mSaldoCta		MONEY;
	DEFINE iNumCtas			SMALLINT;
	DEFINE cBandCtaValida	CHAR(1);
	DEFINE cBandPrimCtaValida	CHAR(1);
	DEFINE sFecComBit		DATE;
	DEFINE sBandComBit		SMALLINT;
	DEFINE cCodRetCS		CHAR(5);
	DEFINE cStaCtaCS		CHAR(1);
    DEFINE iTransacc        SMALLINT;
    --RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE mSdoActual		MONEY(14,2); --Monto del saldo actual de la cuenta.
	DEFINE mSdoRetenido     MONEY(14,2); --Monto del saldo retenido de la cuenta.
	DEFINE mSdoCong	        MONEY(14,2); --Monto del saldo congelado de la cuenta.
	DEFINE mSaldoSBC        MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
	
	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";

	LET pNumcte				= "";
	LET pCuenta				= "";
	LET pProducto			= "";
	LET pTransacc			= "";
	LET dSdoPromMen			= 0.0;
	LET dMontoAplica		= 0.0;
	let dMtoAplicComis		= 0.0;
	LET cAnioMesAnte		= "";
	LET mValorSdoPos		= 0.0;
	LET mDisponible  		= 0;
	LET cCodRetGF			= "000";
	LET cFolioGF			= "";
	LET cCodRetCR			= "000";
	LET cComisionCR			= "";
	LET	mIva				= 0.0;
	LET dValIva				= 0.0;
	LET mMontoPen			= 0.0;
	LET mMtoCom             = 0.0;
	LET cTranCom         	= "";
	LET vTranIva         	= 0.0;
	LET mSdoPromMM			= 0.0;
	LET mComCgoNoSMM		= 0.0;
	LET cTpoPersona			= "";
	LET mComInacCta			= 0.0;
	LET dtFecUltDep			= NULL;
	LET dtFecUltRet			= NULL;
	LET dtFecUltMov			= NULL;
	LET iDifDias			= 0;
	LET sBandCtaNva			= NULL;
	LET sBandCargo			= 0;
	LET cDescTranRef		= "";
	LET cDescIvaRef			= "";
	LET sFecComision		= NULL;
	LET mAcumSdoPos			= 0.0;
	LET iDiaSdoPos			= 0;
	LET dtFechaHoy			= DATE(1);
	LET dtFechaAlta			= DATE(1);
	LET mServAnualidad		= 0.0;
	LET mServAnualPrimCta	= 0.0;
    LET dtConsMovhis 		= DATE(1);
    LET dtConsMovhisold 	= DATE(1);
    LET dtConsMovhisold2 	= DATE(1);
	LET sBandDetcomis		= 0;
	LET cTranSdoprommm		= "";
	LET cTranInaccta		= "";
	LET cTrananuaserv		= "";
	LET cCtaCargoInaccta	= "";
	LET mSaldoCta			= 0.0;
	LET cPrimerCta			= "";
	LET iNumCtas			= 0;
	LET cBandCtaValida		= "0";
	LET cBandPrimCtaValida	= 0;
	LET sFecComBit			= DATE(1);
	LET sBandComBit			= 0;
	LET cCodRetCS			= "000";
	LET cStaCtaCS			= "";
    LET iTransacc           = 0;
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSdoActual			=0.00;	
	LET mSdoRetenido		=0.00;
	LET mSdoCong			=0.00;
	LET mSaldoSBC   		=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';

    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--- SET DEBUG FILE TO '/informix/moha/sp_cargoxcomision_pm.out';
	--- TRACE ON;
    
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sc_fechas
	WHERE empresa = "001";
    
	SELECT TRIM(valor)
	INTO cTranSdoprommm
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transdoprommm';
    
	SELECT TRIM(valor)
	INTO cTranInaccta
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transinaccta1';
    
	SELECT TRIM(valor)
	INTO cTrananuaserv
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transanuserven';
    
	--// OBTIENE EL VALOR DEL PARAMETRO DEL IVA
	SELECT TRIM(valor)
	INTO dValIva
	FROM bdinteg:"informix".si_param
	WHERE empresa = "001"
	AND cod_param = 47;
    
	-- CICLO DE LAS TRANSACCIONES
	FOREACH
		SELECT TRIM(valor)
		INTO pTransacc
		FROM "informix".sc_param
		WHERE empresa = "001"
		AND codparam IN ("transdoprommm","transinaccta1","transanuserven")

		--// OBTIENE EL VALOR DE LA COMISION A COBRAR DE LA TABLA sc_comisiones
		SELECT monto_aplica, transacc_com, transacc_iva
		INTO dMtoAplicComis, cTranCom, vTranIva
		FROM "informix".sc_comisiones
		WHERE empresa = "001"
		AND comision = pTransacc;

		LET dMtoAplicComis = NVL(dMtoAplicComis,0);
        LET iTransacc = 0;

		--// CICLO PRINCIPAL DONDE BARRE TODAS LAS CUENTAS DE PERSONA MORAL
		FOREACH
			SELECT mae.cuenta, mae.producto, mae.num_cte, fecultdep, fecultret, pro.sdoprommen, noc.fecha_alta
			INTO pCuenta, pProducto, pNumcte, dtFecUltDep, dtFecUltRet, dSdoPromMen, dtFechaAlta
			FROM "informix".sc_producto pro, "informix".sc_maechq mae, "informix".sc_maenoc noc
			WHERE pro.empresa = "001"
			AND pro.producto = mae.producto
			AND pro.pago_interes = 'M'
			AND mae.empresa = pro.empresa
			AND mae.producto = pro.producto
			AND pro.producto IN ("1200","2200")
			AND mae.status_cta IN ("1","4","5")
			AND noc.empresa = mae.empresa
			AND noc.cuenta = mae.cuenta
            
            -- // VALIDA SI YA SE APLICO LA TRANSACCION DE COMISION
            SELECT COUNT(*)
              INTO iTransacc
              FROM sc_movdia
             WHERE cuenta = pCuenta
               AND transacc = pTransacc
               AND cancelad <> 'S';
               
            IF iTransacc > 0 THEN
                CONTINUE FOREACH;
            END IF;

			LET sBandCargo = 0;

			IF pTransacc = cTranSdoprommm THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION / CARGO POR NO TENER SALDO PROMEDIO MINIMO MENSUAL
				LET mSdoPromMM = 0.0;
				LET mComCgoNoSMM = 0.0;
				LET mAcumSdoPos	= 0.0;
				LET iDiaSdoPos = 0;

				--// OBTIENE EL SALDO PROMEDIO MENSUAL Y LA COMISION EN LA TABLA MAESTRA DE LAS COMISIONES DE LA CUENTAS DE PERSONAS MORALES
				SELECT FIRST 1 sdo_prom_mm, com_cgo_no_smm
				INTO mSdoPromMM, mComCgoNoSMM
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mSdoPromMM IS NOT NULL THEN
					LET dSdoPromMen = mSdoPromMM;
				ELSE
					LET mSdoPromMM = 0;

				END IF

				IF mComCgoNoSMM IS NOT NULL THEN
					LET dMontoAplica = mComCgoNoSMM;
				ELSE
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- OBTIENE EL AÃO Y EL MES ANTERIOR
					LET cAnioMesAnte = YEAR(dtFechaHoy - 1 units MONTH) || LPAD(MONTH(dtFechaHoy - 1 units MONTH),2,"0");
					
                    --// OBTIENE EL VALOR ACUMULADO Y EL DIA DEL SALDO POS DE LA CUENTA
					SELECT acum_sdo_pos, dia_sdo_pos
					INTO mAcumSdoPos, iDiaSdoPos
					FROM "informix".sc_maehis
					WHERE aniomes = cAnioMesAnte
					AND cuenta = pCuenta;

					LET mAcumSdoPos = NVL(mAcumSdoPos, 0);
					LET iDiaSdoPos = NVL(iDiaSdoPos, 0);

					IF iDiaSdoPos = 0 THEN
						LET mValorSdoPos = 0;
					ELSE
						LET mValorSdoPos = mAcumSdoPos / iDiaSdoPos;
					END IF

					--// VALIDA SI EL SALDO POS ES MENOR AL SALDO PROMEDIO DE LA sc_producto
					IF mValorSdoPos < dSdoPromMen THEN
						LET sBandCargo = 1;
						LET cDescTranRef = "COMISION X NO TENER SALDO PROMEDIO MENS";
						LET cDescIvaRef = "IVA COMISION X NO TENER SALDO PROM MENS";
					END IF
				END IF
			ELIF pTransacc = cTranInaccta THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR INACTIVIDAD DE LA CUENTA DURANTE 1 AÃO
				LET mComInacCta = 0;
				LET dtFecUltMov	= NULL;

				SELECT FIRST 1 com_ina_cta
				INTO mComInacCta
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mComInacCta IS NOT NULL THEN
					LET dMontoAplica = mComInacCta;
				ELSE
					LET mComInacCta = 0;
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- VALIDA QUE LA CUENTA TENGA POR LO MENOS UN AÃO DE VIDA
					IF (dtFechaHoy - dtFechaAlta) > 360 THEN

						IF dtFecUltDep IS NULL AND dtFecUltRet IS NULL THEN
							LET sBandCargo = 1;
						ELSE
							IF dtFecUltDep IS NOT NULL THEN
								LET dtFecUltMov = dtFecUltDep;
							END IF

							IF dtFecUltRet IS NOT NULL THEN
								IF dtFecUltRet > dtFecUltMov THEN
									LET dtFecUltMov = dtFecUltRet;
								END IF
							END IF

							IF (dtFechaHoy - dtFecUltMov) < 361 THEN
								LET sBandCargo = 0;
							ELSE
								LET sBandCargo = 1;
								LET cDescTranRef = "COMISION X INACTIVIDAD DE LA CTA 1 AÃO";
								LET cDescIvaRef = "IVA COMISION X INACT DE LA CTA 1 AÃO";
							END IF
						END IF
					END IF
				END IF
			ELIF pTransacc = cTrananuaserv THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR ANUALIDAD DEL SERVICIO DE EMPRESANET
				LET iDifDias = 0;
				LET sBandCtaNva = NULL;
				LET iNumCtas = 0;
				LET cBandCtaValida = "0";
				LET sFecComBit = DATE(1);
				LET sBandComBit	= 0;
				LET cPrimerCta = "";
				LET mServAnualPrimCta = 0.0;
				LET mServAnualidad = 0.0;
				LET mSaldoCta = 0.0;
				LET cCtaCargoInaccta = "";

				--// OBTIENE EL NUMERO DE DIAS DE LA FECHA ACTUAL RESPECTO A SU FECHA DE REGISTRO
				SELECT FIRST 1 dtFechaHoy - f_registro
				INTO iDifDias
				FROM bdibei: "informix".bei_contratacion
				WHERE empresa = "001"
				AND num_cliente = pNumcte
				AND status_contrato = '30';

				IF iDifDias IS NULL THEN
					LET sBandCargo = 0;
				ELSE
					IF iDifDias > 31 AND iDifDias < 361 THEN
						LET sBandCargo = 0;
					ELSE
						IF iDifDias < 32 THEN
							LET sBandCtaNva = 1;
						ELSE
							LET sBandCtaNva = 0;
						END IF

						LET iNumCtas = 0;
						LET cBandCtaValida = "0";
						LET iDifDias = 0;

						SELECT FIRST 1 MAX(fecha_gencom)
						INTO sFecComBit
						FROM "informix".sc_bitacora_compm
						WHERE tpo_com = cTrananuaserv
						AND num_cte = pNumcte;

						LET sBandComBit = 0;

						IF sFecComBit IS NOT NULL THEN
							LET iDifDias = dtFechaHoy - sFecComBit;
							IF sBandCtaNva = 1 THEN
								LET sBandComBit = 1;
							ELIF sBandCtaNva = 0 THEN
								IF iDifDias < 361 THEN
									LET sBandComBit = 1;
								END IF
							END IF
						END IF

						IF sBandComBit = 0 THEN
							FOREACH
								SELECT cuenta
								INTO cPrimerCta
								FROM bdicheq:"informix".sc_maechq
								WHERE empresa = "001"
								AND num_cte = pNumcte
								ORDER BY cuenta
							END FOREACH

							SELECT FIRST 1 serv_anualidad
							INTO mServAnualPrimCta
							FROM "informix".sc_maecomtasserv_pm
							WHERE cuenta = cPrimerCta;

							IF cPrimerCta IS NOT NULL THEN
								-- // OBTIENE EL SALDO DE LA CUENTA
								EXECUTE PROCEDURE "informix".cons_saldo(cPrimerCta)
								INTO cCodRetCS, mSaldoCta, cStaCtaCS;

								LET iNumCtas = 1;

								IF mServAnualPrimCta IS NOT NULL THEN
									LET dMontoAplica = mServAnualPrimCta;
								ELSE
									LET dMontoAplica = dMtoAplicComis;
								END IF

								IF mSaldoCta >= dMontoAplica THEN
									LET cBandPrimCtaValida = 1;
								END IF
							END IF

							IF cBandPrimCtaValida = 1 THEN
								LET pCuenta = cPrimerCta;
							ELSE
								--// SE BARREN LAS CUENTAS DE DEBITO DEL CTE
								FOREACH
									SELECT cuenta, saldo
									INTO cCtaCargoInaccta, mSaldoCta
									FROM
									(
										--RQM 09 704.Se agrega las variable de saldo inmovilizado al calculo de saldo disponible.DHG
										SELECT t1.cuenta, t1.sdo_actual - (t1.sdo_retenido + t1.sdo_cong + t1.imp_sbg_ccc + t1.saldo_sbc) AS saldo
										FROM "informix".sc_maechq t1, "informix".sc_maenoc t2
										WHERE t1.num_cte = pNumcte
										AND t1.cuenta = t2.cuenta
										AND t1.cuenta <> cPrimerCta
										AND t1.status_cta = "1"
										AND t1.producto IN ("1200","2200")
										ORDER BY t2.fecha_alta
									)

									LET pCuenta = cCtaCargoInaccta;

									LET iNumCtas = iNumCtas + 1;

									IF iNumCtas = 1 THEN
										LET cPrimerCta = cCtaCargoInaccta;
									END IF

									SELECT FIRST 1 serv_anualidad
									INTO mServAnualidad
									FROM "informix".sc_maecomtasserv_pm
									WHERE cuenta = pCuenta;

									IF mServAnualPrimCta IS NOT NULL THEN
										LET mServAnualidad = mServAnualPrimCta;
									ELSE
										LET mServAnualPrimCta = 0;
									END IF

									IF mServAnualidad IS NOT NULL THEN
										LET dMontoAplica = mServAnualidad;
									END IF

									IF dMontoAplica > mSaldoCta THEN
										CONTINUE FOREACH;
									ELSE
										LET cBandCtaValida = "1";
										EXIT FOREACH;
									END IF
								END FOREACH
							END IF

							-- VALIDA CUANDO NO HAY CUENTAS ACTIVAS PARA EL CLIENTE
							IF iNumCtas = 0 THEN
								LET sBandCargo = 0;
							ELSE
								IF dMontoAplica > 0 THEN
									LET sBandCargo = 1;
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF

			--// VALIDA SI SE CUMPLEN LAS CONDICIONES PARA SEGUIR CON EL CARGO
			IF sBandCargo = 1 THEN
				LET mDisponible = 0;
				LET mMtoCom = 0.0;
				LET mMontoPen = 0.0;
				LET	mIva = 0.0;
				LET cCodRetGF = "000";
				LET cFolioGF = "";
				LET cCodRetCR = "000";
				LET cComisionCR = "";

				let dMontoAplica = dMontoAplica;

				IF pTransacc = cTrananuaserv THEN
					INSERT INTO "informix".sc_bitacora_compm (tpo_com, num_cte, num_cta, fecha_gencom)
					VALUES (cTrananuaserv, pNumcte, pCuenta, dtFechaHoy);
					LET cDescTranRef = "COMISION X ANUALIDAD SERVICIO EMPRESANET";
					LET cDescIvaRef = "IVA COMISION X ANUALIDAD SERV EMPRESANET";
				END IF

				-- // OBTIENE EL SALDO DE LA CUENTA
				EXECUTE	PROCEDURE "informix".cons_saldo(pCuenta)
				INTO cCodRetCS, mDisponible, cStaCtaCS;

				-- // Aplica Cargo por Comision
				IF mDisponible > 5 THEN
					--// VALIDA SI EL SALDO DISPONIBLE ALCANZA PARA HACER EL COBRO SINO RECALCULA LA COMISION Y EL IVA
					IF mDisponible < (dMontoAplica * (1 + dValIva)) THEN
						LET mMtoCom   = dMontoAplica;
						LET dMontoAplica = ROUND(mDisponible / (1 + dValIva),2);
						LET mMontoPen = mMtoCom - dMontoAplica;
						LET mIva = mDisponible - dMontoAplica;
					ELSE
						LET mIva = TRUNC((dMontoAplica * dValIva),2);
					END IF;
					--// GENERA EL FOLIO DEL MOVIMIENTO
					EXECUTE PROCEDURE "informix".sp_generafolionomina ("informix")
					INTO cCodRetGF, cFolioGF;
					IF cCodRetGF::INTEGER <> 0 THEN
						LET cCodRet = cCodRetGF;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", cTranCom, "0000", cFolioGF, pCuenta, 0, dMontoAplica, "01", cDescTranRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DEL IVA DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", vTranIva, "0000", cFolioGF, pCuenta, 0, mIva, "01", cDescIvaRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					-- // Registra comision pendiente si es el caso
					IF mMontoPen > 0 THEN
						INSERT INTO "informix".sc_detcomis
						VALUES("001", pCuenta, cTranCom, mMontoPen  , 0, TODAY, "", "P", cFolioGF);

						UPDATE "informix".sc_maechq
						SET com_pendiente =  com_pendiente + mMontoPen
						WHERE empresa = "001"
						AND cuenta  = pCuenta;
					END IF;
				ELSE
					INSERT INTO "informix".sc_detcomis
					VALUES("001", pCuenta, cTranCom, dMontoAplica, 0, TODAY, "", "P", cFolioGF);

					UPDATE "informix".sc_maechq
					SET com_pendiente =  com_pendiente + dMontoAplica
					WHERE empresa = "001"
					AND cuenta  = pCuenta;
				END IF;
			END IF
		END FOREACH
	END FOREACH

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para el cargo parametrizado de comisiones para personas morales',
'BD: bdicheq',
'AUTOR: Mohamed CarreÃ³n ',
'FECHA: Octubre 2014',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

CREATE PROCEDURE "informix".sp_portabregistrapagoprogramado(pUsuario CHAR(8))
RETURNING  CHAR(5);
    
    DEFINE cCodRet 							CHAR(5);
    DEFINE cCodRet2							CHAR(5);
    DEFINE iSqlErr							INTEGER;
    DEFINE cEmpresaEmpleado					CHAR(5);
    DEFINE cNumCliente						CHAR(20);
    DEFINE cCuentaOrigen					CHAR(20);
    DEFINE iSecuencia						INTEGER;
    DEFINE cBancoDestino					CHAR(3);
    DEFINE cCuentaDestino					CHAR(20);
    DEFINE cTarjetaDestino					CHAR(20);
    DEFINE cFechaDeposito					CHAR(60);
    DEFINE cEstatus							CHAR(2);
    DEFINE mMontoTotal						MONEY (16,2);
    DEFINE cFolioSuc						CHAR(16);
    DEFINE mSdoDisponible					MONEY (16,2);
    DEFINE dFechaHoy						DATE;
    DEFINE dFechaHoyMov						DATE;
    DEFINE dFechaHoyAnt						DATE;
    DEFINE cConsecutivoCentral				CHAR(8);
    DEFINE cFolioPortabilidad				CHAR(18);
    DEFINE cTransaccUsada					CHAR(4);
    DEFINE cMensaje							CHAR(100);
    DEFINE iCantidadFallos					INTEGER;
    DEFINE iCantidadTomados					INTEGER;
    DEFINE cHoraCierreSPEI					DATETIME HOUR TO SECOND;
    DEFINE cHoraActualServidor				DATETIME HOUR TO SECOND;
    DEFINE cMensajeProcesos					CHAR(250);
    DEFINE cIDClabeOTarjeta					CHAR(2);
    DEFINE cTelefonoCelCte					CHAR(13);
    DEFINE v_valida                         INTEGER;
    DEFINE v_estatus_portabilidad           CHAR (2);
    DEFINE v_fecha_estatus_portabilidad     CHAR(8);
    DEFINE v_clave_origen                   CHAR(1);
    DEFINE v_clave_sentido                  CHAR(1);
    DEFINE v_bco_ordenante                  CHAR(5);
    DEFINE v_total                          CHAR(2);
    DEFINE cCodRet3                         CHAR(3);
    DEFINE cCodRet_fech_lim 				DATE;
    DEFINE v_fecha_estatus_portabilidad_fin DATE;
    DEFINE v_fecha_insert                   VARCHAR(12);
    DEFINE v_fecha_insert_fin               VARCHAR(12);  
    DEFINE v_fecha_solicitud	            CHAR(8);
    DEFINE v_num_tarjeta                    CHAR(20);  
    DEFINE v_cuenta_clabe	                CHAR(18);
    DEFINE v_total_tajeta                   CHAR (2);
    DEFINE v_total_cveinter                 CHAR (2);
    DEFINE dFechaActual                     DATE;
	DEFINE v_folio_solicitud				CHAR (30); 		--Se agrega variable para el Folio de solicitud de la portabilidad de nomina 
	DEFINE v_bco_recep_solicitud			CHAR (5);		--Se agrega variable para la Clave CASFIN del banco donde se realiza la solicitud de portabilidad de nomina. 
	DEFINE cClaveBanCoppel					CHAR (5);		--Se agrega variable para la Clave CASFIN de Bancoppel.
	--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET cCodRet 			= '00000';
    LET cCodRet2 			= '00000';
    LET iSqlErr				= 0;
    LET cEmpresaEmpleado	= '';
    LET cNumCliente			= '';
    LET cCuentaOrigen		= '';
    LET iSecuencia			= 0;
    LET cBancoDestino		= '';
    LET cIDClabeOTarjeta	= '';
    LET cCuentaDestino		= '';
    LET cTarjetaDestino		= '';
    LET cFechaDeposito		= '';
    LET cEstatus			= '';
    LET mMontoTotal			= 0.00;
    LET cFolioSuc			= '';
    LET mSdoDisponible		= 0.00;
    LET dFechaHoy			= '';
    LET dFechaHoyMov		= '';
    LET dFechaHoyAnt		= '';
    LET cConsecutivoCentral	= '';
    LET cFolioPortabilidad	= '';
    LET cTransaccUsada		= '';
    LET cMensaje			= '';
    LET iCantidadFallos		= 0;
    LET iCantidadTomados	= 0;
    LET cHoraCierreSPEI		= '';
    LET cHoraActualServidor	= '';
    LET cMensajeProcesos	= '';
    LET cTelefonoCelCte		= '';
    LET v_valida            = 0;
    LET v_estatus_portabilidad       = '';
    LET v_fecha_estatus_portabilidad = '';
    LET v_clave_origen      = '';
    LET v_clave_sentido     = '';
    LET v_bco_ordenante     = '';
    LET v_total             = '';
    LET cCodRet3            = '';
    LET cCodRet_fech_lim    = '';
    LET v_fecha_estatus_portabilidad_fin = '';
    LET v_fecha_insert      = ''; 
    LET v_fecha_insert_fin  ='';
    LET v_num_tarjeta       = '';
    LET v_cuenta_clabe      ='';
    LET v_total_tajeta      = '';
    LET v_total_cveinter    = '';
    LET dFechaActual        = '';
	LET v_folio_solicitud		= '';		
	LET v_bco_recep_solicitud	= '';
	LET cClaveBanCoppel		= '40137';
    --RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
	
    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;
            LET cMensaje = 'OCURRIO UN ERROR INESPERADO';
            IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                LET cConsecutivoCentral = '0';
            END IF;
            CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
            RETURNING cCodRet2,cMensajeProcesos;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/ifxsif01/dhg/Ejecuciones/sp_portabregistrapagoprogramado.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- Obtiene la fecha del sistema de cheques.
    SELECT fecha_hoy 
      INTO dFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';
    
    LET dFechaHoyMov = dFechaHoy;
    LET dFechaActual = dFechaHoy;
    
    -- Valida que exista el usuario.
    IF NOT EXISTS (SELECT 1 FROM bdinteg:si_ejecut WHERE ejecutivo = pUsuario) THEN
        LET cCodRet = '00001';
        LET cMensaje = 'EL USUARIO NO SE ENCUENTRA REGISTRADO';
        IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
            LET cConsecutivoCentral = '0';
        END IF;
        CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
        RETURNING cCodRet2,cMensajeProcesos;
        RETURN cCodRet;
    END IF;

	--RQI 61 1241.Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion del proceso de revision de fecha habil con relacion a dias feriados, por ser innecesaria, debido a que ya se valida en otros lados.
    -- Valida si la fecha hoy es habil
	/* CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,0,'S') 
    RETURNING cCodRet2,dFechaHoyAnt;

    IF cCodRet2 <> 0 THEN
        Si no es habil asigna la siguiente fecha habil.
        CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,1,'S') --16/09/2023
        RETURNING cCodRet2,dFechaHoyAnt;
        
        IF cCodRet2 = 0 THEN
            LET dFechaHoy = dFechaHoyAnt;
        ELSE
            LET cCodRet = '00002';
            LET cMensaje = 'SE TUVO PROBLEMAS AL INTENTAR OBTENER LA FECHA PROXIMA';
            IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                LET cConsecutivoCentral = '0';
            END IF;
            CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
            RETURNING cCodRet2,cMensajeProcesos;
            RETURN cCodRet;
        END IF;
    END IF; */
    
	--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion del proceso de validacion de la hora de cierre del SPEI, ya que actualmente la validacion no aporta nada al proceso.
    --Consulta la hora de cierre para SPEI.
    /*SELECT TRIM(valor)
      INTO cHoraCierreSPEI
      FROM bdicheq:sc_param
     WHERE codparam = 'PORTAHORACIERRE';
    
    LET cHoraActualServidor = CURRENT HOUR TO SECOND; 
    
    Si la hora es mayor a la parametrizada, se programa el pago al siguiente dia habil de lunes a viernes.
    IF cHoraActualServidor >= cHoraCierreSPEI THEN
        Si no es habil asigna la siguiente fecha habil.
        CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,1,'S') 
        RETURNING cCodRet2,dFechaHoyAnt;
        
        IF cCodRet2 = 0 THEN
            LET dFechaHoy = dFechaHoyAnt;
        ELSE
            LET cCodRet = '00002';
            LET cMensaje = 'SE TUVO PROBLEMAS AL INTENTAR OBTENER LA FECHA PROXIMA';
            IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                LET cConsecutivoCentral = '0';
            END IF;
            CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
            RETURNING cCodRet2,cMensajeProcesos;
            RETURN cCodRet;
        END IF;
    END IF; */

	--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Se elimino la condicion "proceso = 'sp_PortabRegistraPagoProgramado'" dentro del SELECT a sc_portabitacora ya que este valor es constante en todos los registros de la tabla por lo que especificar este campo no es necesario. DHG
    -- Consulta si el proceso ya se ejecuto ya que este es diario y si no existe ejecucion registrada se inicializara.
	IF EXISTS (SELECT 1 FROM bdicheq:sc_portabitacora WHERE fecha_ejec = dFechaHoyMov ) THEN --MODIFICACIoN DHG 
        -- Asigna una referencia o clave.
        SELECT (TRIM(valor) + 1)::INTEGER
          INTO cConsecutivoCentral
          FROM bdicheq:sc_param
         WHERE codparam = 'PORTACONSEC';
        
        LET cConsecutivoCentral = LPAD(NVL(TRIM(cConsecutivoCentral),'0'),8,'0');
    ELSE
        -- Asigna una referencia o clave.
        LET cConsecutivoCentral = '00000001';	

        UPDATE bdicheq:sc_param 
           SET valor = cConsecutivoCentral
         WHERE codparam = 'PORTACONSEC';
    END IF;
    
    FOREACH WITH HOLD
        -- Consulta que existan cuentas con su portabilidad activa y Consulta el movimiento diario.
        SELECT {+AVOID_FULL("informix".sc_portabilidadnomina), AVOID_FULL("informix".sc_portaestatus), AVOID_FULL("informix".sc_movdia), AVOID_FULL("informix".sc_portatransacc)}
				PN.empresa, PN.cliente, PN.cuenta_abono, PN.secuencia, PN.banco_ref, PN.cuenta_ref, 
               PN.tarjeta_ref, PN.fecha_deposito, PN.estatus,MV.monto_tot, MV.folio_suc, MV.transacc, PN.fecha_insert
          INTO cEmpresaEmpleado, cNumCliente, cCuentaOrigen, iSecuencia, cBancoDestino, cCuentaDestino, 
               cTarjetaDestino, cFechaDeposito, cEstatus,mMontoTotal, cFolioSuc, cTransaccUsada,v_fecha_insert
          FROM bdicheq:sc_portabilidadnomina AS PN
         INNER JOIN bdicheq:sc_portaestatus AS PE ON (PN.estatus = PE.estatus)
         INNER JOIN bdicheq:sc_movdia AS MV ON (PN.cuenta_abono = MV.cuenta) AND (fech_alt = dFechaHoyMov)
         INNER JOIN bdicheq:sc_portatransacc AS PT ON (MV.transacc = PT.transacc)
         WHERE PN.estatus =  '01'
        
        LET iCantidadTomados = iCantidadTomados + 1;
        
        -- Si no se obtuvo el movimiento.
        IF  mMontoTotal IS NULL OR  cFolioSuc IS NULL OR cFolioSuc = '' OR cTransaccUsada IS NULL OR cTransaccUsada = '' THEN
            LET cMensaje = 'NO SE OBTUVO INFORMACIÃN DE LOS MOVIMIENTOS DIARIOS';
            LET iCantidadFallos = iCantidadFallos + 1;
            CONTINUE FOREACH;
        END IF;
        
        -- Consulta el saldo de la cuenta origen.
        /*SELECT sdo_actual - (sdo_cong + sdo_retenido)
          INTO mSdoDisponible
          FROM bdicheq:sc_maechq 
         WHERE cuenta = cCuentaOrigen;*/
		 
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
			EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo(cCuentaOrigen,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'T',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSdoDisponible;        		
        
        IF mMontoTotal < mSdoDisponible THEN
            LET mSdoDisponible = mMontoTotal;
        END IF;
        
        -- Obtiene la fecha del sistema de cheques.
        /* ##########################
        SELECT fecha_hoy 
          INTO dFechaHoy
          FROM bdicheq:sc_fechas
         WHERE empresa = '001';
        ########################## */
        
        LET dFechaHoy = dFechaActual;
		--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion del proceso de validacion de la hora de cierre del SPEI, ya que actualmente la validacion no aporta nada al proceso.
        /*LET cHoraActualServidor = CURRENT HOUR TO SECOND;
         
		--Si la hora es mayor a la parametrizada, se programa el pago al siguiente dia habil de lunes a viernes.
        
		IF cHoraActualServidor >= cHoraCierreSPEI THEN
            Si no es habil asigna la siguiente fecha habil.
            CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHoy,1,'S') 
            RETURNING cCodRet2,dFechaHoyAnt;

            IF cCodRet2 = 0 THEN
                LET dFechaHoy = dFechaHoyAnt;
            ELSE
                LET cCodRet = '00002';
                LET cMensaje = 'SE TUVO PROBLEMAS AL INTENTAR OBTENER LA FECHA PROXIMA';
                IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
                    LET cConsecutivoCentral = '0';
                END IF;
                CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral) 
                RETURNING cCodRet2,cMensajeProcesos;
                RETURN cCodRet;
            END IF;
        END IF;*/
		
        --RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se agrega la columna 'folio_solicitud' y se elimina la columna 'clave_sentido'.
        --SELECT FIRST 1 b.estatus_portabilidad, b.fecha_estatus_portabilidad, b.clave_origen, b.clave_sentido, b.bco_ordenante, b.fecha_solicitud
          --INTO v_estatus_portabilidad, v_fecha_estatus_portabilidad, v_clave_origen, v_clave_sentido, v_bco_ordenante, v_fecha_solicitud
		SELECT FIRST 1 b.folio_solicitud,b.estatus_portabilidad, b.fecha_estatus_portabilidad, b.clave_origen, b.bco_ordenante, b.fecha_solicitud
          INTO v_folio_solicitud,v_estatus_portabilidad, v_fecha_estatus_portabilidad, v_clave_origen, v_bco_ordenante, v_fecha_solicitud
          FROM sc_portabilidadnomina AS a, 
               sc_portacec_solicitud AS b,  
               sc_movdia AS c
         WHERE a.cliente = b.num_cte
           AND a.cuenta_abono = c.cuenta  
           AND c.fech_alt = dFechaHoyMov 
           AND c.transacc IN('0287','0293')
           AND ( a.cuenta_ref = b.cta_receptora OR a.tarjeta_ref = b.cta_receptora )
           AND a.estatus = '01' 
           AND b.bco_ordenante = cClaveBanCoppel
           AND b.estatus_portabilidad = '1'
           AND a.cliente = cNumCliente;
        ---ORDER BY b.fecha_estatus_portabilidad DESC;
        
		----RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se extrae la Clave CASFIN del banco donde se recepciono la solicitud.
		LET v_bco_recep_solicitud = SUBSTR(v_folio_solicitud,15,5);
		
        -- SE VALIDA QUE EL REGISTRO DE PORTABILIDAD TENGA UNA FECHA DE ESTATUS  
        IF v_fecha_estatus_portabilidad IS NULL OR v_fecha_estatus_portabilidad = ""  THEN 
            --SI LA FECHA DEL ESTATUS DE LA PORTABILIDAD ESTA EN NULLO O EN BLANCO CONSIDERAMOS LA FECHAS DE LA SOLICITUD
            LET v_fecha_estatus_portabilidad_fin = SUBSTR(v_fecha_solicitud,5,2)|| SUBSTR(v_fecha_solicitud,7,2)||SUBSTR(v_fecha_solicitud,0,4);
            
			--RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se genera una nueva validacion para determinar si deben cumplirse 5 o 10 dÃ­as para la transferencia de fondos
			-- dependiendo del banco donde se recepciono la solicitud.
			--SI LA SOLICITUD SE REALIZO A TRAVES DE BANCOPPEL.
			IF v_bco_recep_solicitud = cClaveBanCoppel THEN 
                EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '5') 
                INTO  cCodRet3, cCodRet_fech_lim;
            ELSE 
				--SI LA SOLICITUD SE REALIZO DE OTRO BANCO A BANCOPPEL.
				EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '10') 
				INTO  cCodRet3, cCodRet_fech_lim;              
            END IF;
			
            --RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se comenta la validacion anterior.
			--SI LA SOLICITUD ES DIRECTAMENTE EN BANCOPPEL
            /*IF v_clave_sentido = '1' THEN 
                EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '5') 
                INTO  cCodRet3, cCodRet_fech_lim;
            ELSE 
                -- SI LA SOLICITUD ES DE OTRO BANCO A BANCOPPEL
                IF  v_clave_sentido = '2' THEN 
                    EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '10') 
                    INTO  cCodRet3, cCodRet_fech_lim;
                END IF;
            END IF;*/
            
            -- SE VALIDA SI CUMPLE LAS REGLAS DEPENDIENDO EL SENTIDO 
            IF cCodRet_fech_lim >= dFechaHoy THEN 	 
                CONTINUE FOREACH;
            END IF;			
        ELSE 
            --EL CAMPO DE ESTATUS PORTABILIDAD SI TIENE FECHA ASIGNADA
            LET v_fecha_estatus_portabilidad_fin = SUBSTR(v_fecha_estatus_portabilidad,5,2)|| SUBSTR(v_fecha_estatus_portabilidad,7,2)||SUBSTR(v_fecha_estatus_portabilidad,0,4);
			
			--RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se genera una nueva validacion para determinar si deben cumplirse 5 o 10 dÃ­as para la transferencia de fondos
			-- dependiendo del banco donde se recepciono la solicitud.
			--SI LA SOLICITUD SE REALIZO A TRAVES DE BANCOPPEL.
			IF v_bco_recep_solicitud = cClaveBanCoppel THEN 
                EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '5') 
                INTO  cCodRet3, cCodRet_fech_lim;
            ELSE 
				--SI LA SOLICITUD SE REALIZO DE OTRO BANCO A BANCOPPEL.
				EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '10') 
				INTO  cCodRet3, cCodRet_fech_lim;              
            END IF;
			
			--RQM 10 1642. Daniel Hernandez Garcia. Modificacion realizada: Se comenta la validacion anterior.
            --SI LA SOLICITUD ES DIRECTAMENTE EN BANCOPPEL
            /* IF   v_clave_sentido = '1' THEN 
                EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '5') 
                INTO  cCodRet3, cCodRet_fech_lim;
            ELSE 
                -- SI LA SOLICITUD ES DE OTRO BANCO A BANCOPPEL
                IF  v_clave_sentido  =  '2' THEN 
                    EXECUTE PROCEDURE sp_calFechAbil( v_fecha_estatus_portabilidad_fin, '10') 
                    INTO  cCodRet3, cCodRet_fech_lim;
                END IF;
            END IF; */
            
            -- SE VALIDA SI CUMPLE LAS REGLAS DEPENDIENDO EL SENTIDO 
            IF cCodRet_fech_lim >= dFechaHoy THEN 	 
                CONTINUE FOREACH;
            END IF; 
        END IF;
        
        -- Asignacion de referencia o folio.
        LET cFolioPortabilidad = 'PN' || LPAD(YEAR(dFechaHoy),4,'0')||LPAD(MONTH(dFechaHoy),2,'0')|| LPAD(DAY(dFechaHoy),2,'0')||cConsecutivoCentral;
        
        IF cCuentaDestino <> '' AND LENGTH(cCuentaDestino) = 18 AND  SUBSTR(cCuentaDestino,1,3) = cBancoDestino THEN
            LET cIDClabeOTarjeta = '02';
        ELIF cTarjetaDestino <> '' THEN
            LET cIDClabeOTarjeta = '03';
            LET cCuentaDestino = cTarjetaDestino;
        END IF;
        
        -- Obtiene el telefono celular del cliente.
        SELECT telefono 
          INTO cTelefonoCelCte 
          FROM bdinteg:si_telefonos_actual
         WHERE numcte = cNumCliente 
           AND tipo_tel = '2';
        
        -- Valida si el telefono se obtuvo si no se obtiene se envia un 0
        IF cTelefonoCelCte IS NULL OR cTelefonoCelCte = '' THEN
            LET cTelefonoCelCte = '0';
        END IF;
        
        /*
        -- Consulta que el movimiento no exista.
        IF EXISTS ( SELECT 1 FROM bdicheq:sc_portamovtos WHERE cliente = cNumCliente AND cuenta_cargo = cCuentaOrigen AND banco_ref = cBancoDestino AND transaccion = cTransaccUsada AND fecha_envio = dFechaHoy AND folio_suc = cFolioSuc ) THEN
            LET iCantidadFallos = iCantidadFallos + 1; 
            CONTINUE FOREACH;   
        END IF;
        */
        
        LET v_valida = 0;
        
        SELECT COUNT(*) 
          INTO v_valida
          FROM bdicheq:sc_portamovtos 
         WHERE cliente = cNumCliente 
           AND cuenta_cargo = cCuentaOrigen 
           AND banco_ref = cBancoDestino 
           AND transaccion = cTransaccUsada 
           AND fecha_envio = dFechaHoy 
           AND folio_suc = cFolioSuc;
        
        IF v_valida > 0 THEN 
            -- Consulta que el movimiento no exista.
            LET iCantidadFallos = iCantidadFallos + 1; 
            CONTINUE FOREACH; 
        END IF;
        
        -- Reliza la programacion de los pagos.
        CALL bdiprog:sp_altaprogramacion( cNumCliente, cFolioPortabilidad, '07', '01', cCuentaOrigen, cIDClabeOTarjeta, cCuentaDestino, cBancoDestino, cFolioPortabilidad,
                                          cConsecutivoCentral::INTEGER, '0', mSdoDisponible, '', '0.00', '01', 'PORTABILIDAD DE NÃMINA', dFechaHoy, '02', 1, dFechaHoy,
                                          '04', '00', '0', '0', '0', '0', '0', '0', '0', '0', '05', '00', '', '0', cTelefonoCelCte, '00', '', '0', '', '', '0', pUsuario )
        RETURNING cCodRet2,cMensajeProcesos;
        
        IF cCodRet2 = 0 THEN
            -- Registra el movimiento de portabilidad.		
            INSERT INTO bdicheq:sc_portamovtos 
            (referencia1,empresa,cliente,cuenta_cargo,banco_ref,cuenta_ref,tarjeta_ref,monto_enviar,monto_nomina,transaccion,fecha_envio,fecha_recibido,estatus,folio_suc,user_insert,fecha_insert)
            VALUES 	
            (cFolioPortabilidad,cEmpresaEmpleado,cNumCliente,cCuentaOrigen,cBancoDestino,cCuentaDestino,cTarjetaDestino,mSdoDisponible,mMontoTotal,cTransaccUsada,dFechaHoy,dFechaHoyMov,'01',cFolioSuc,pUsuario,dFechaHoyMov);
            
            -- Actualiza el parametro que utilizo
			UPDATE bdicheq:sc_param 
               SET valor = cConsecutivoCentral::INTEGER 
             WHERE codparam = 'PORTACONSEC';
           
		   --RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion del siguiente proceso ya que es innecesario.
            -- Obtiene el parametro.
            /*SELECT TRIM(valor) :: INTEGER + 1
              INTO cConsecutivoCentral
              FROM bdicheq:sc_param
            WHERE codparam = 'PORTACONSEC';
			*/
			
			--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Modificacion de la siguiente linea con el fin de sustituir la consulta anterior.
			LET cConsecutivoCentral = LPAD(NVL(TRIM(cConsecutivoCentral),'0')::INTEGER + 1,8,'0'); --Adicion de '+ 1'
            LET cMensaje = 'PROCESO EXITOSO';
            
        -- Consulta si se obtuvo el saldo y si es menor a cero no se procesa la cuenta o si el proceso genero un error.
        ELIF cCodRet2 <> 0 OR mSdoDisponible IS NULL OR mSdoDisponible <= 0.00 THEN
            
            LET cMensaje = 'EN AL MENOS UNA CUENTA NO SE REALIZO SU PROGRAMACIÃN DE PAGOS';
            LET iCantidadFallos = iCantidadFallos + 1;
            
            -- ##########################################################---
            -- Registra el movimiento de portabilidad con error.	
            INSERT INTO bdicheq:sc_portamovtos_error 
            (referencia1,empresa,cliente,cuenta_cargo,banco_ref,cuenta_ref,tarjeta_ref,monto_enviar,monto_nomina,transaccion,fecha_envio,fecha_recibido,estatus,folio_suc,user_insert,fecha_insert,error)
            VALUES 	
            (cFolioPortabilidad,cEmpresaEmpleado,cNumCliente,cCuentaOrigen,cBancoDestino,cCuentaDestino,cTarjetaDestino,mSdoDisponible,mMontoTotal,cTransaccUsada,dFechaHoy,dFechaHoyMov,'01',cFolioSuc,pUsuario,dFechaHoyMov,cCodRet2);
            
            -- Registra el movimiento de portabilidad.	
            INSERT INTO bdicheq:sc_portamovtos 
            (referencia1,empresa,cliente,cuenta_cargo,banco_ref,cuenta_ref,tarjeta_ref,monto_enviar,monto_nomina,transaccion,fecha_envio,fecha_recibido,estatus,folio_suc,user_insert,fecha_insert)
            VALUES 	
            (cFolioPortabilidad,cEmpresaEmpleado,cNumCliente,cCuentaOrigen,cBancoDestino,cCuentaDestino,cTarjetaDestino,mSdoDisponible,mMontoTotal,cTransaccUsada,dFechaHoy,dFechaHoyMov,'01',cFolioSuc,pUsuario,dFechaHoyMov);
            
            -- Actualiza el parametro que utilizo
            UPDATE bdicheq:sc_param 
               SET valor = cConsecutivoCentral::INTEGER 
             WHERE codparam = 'PORTACONSEC';
            
		   --RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Comentarizacion del siguiente proceso ya que es innecesario.
            -- Obtiene el parametro.
			/* SELECT TRIM(valor) :: INTEGER + 1
              INTO cConsecutivoCentral
              FROM bdicheq:sc_param
             WHERE codparam = 'PORTACONSEC';*/
            
			--RQI 61 1241. Daniel Hernandez Garcia. Modificacion realizada: Modificacion de la siguiente linea con el fin de sustituir la consulta anterior.
			LET cConsecutivoCentral = LPAD(NVL(TRIM(cConsecutivoCentral),'0')::INTEGER + 1,8,'0');
            
            IF mSdoDisponible IS NULL OR mSdoDisponible <= 0.00 THEN
                LET cMensaje =  'EN AL MENOS UNA CUENTA TUVO PROBLEMAS EN SU SALDO';
            END IF;
            
            CONTINUE FOREACH;
        END IF;	
    END FOREACH
    
    IF iCantidadTomados - iCantidadFallos = 0 THEN
        LET cMensaje = 'NO SE ENCONTRO INFORMACIÃN POR PROCESAR';
        LET cConsecutivoCentral = 1;
    END IF;
    
    IF cConsecutivoCentral IS NULL OR cConsecutivoCentral = '' THEN
        LET cConsecutivoCentral = '1';
    END IF;
    
    CALL bdicheq:sp_PortabRegistraEjecucion('sp_PortabRegistraPagoProgramado', dFechaHoyMov, cCodRet, cMensaje ,cConsecutivoCentral - 1) 
    RETURNING cCodRet2,cMensajeProcesos;		
    
    RETURN cCodRet;
    
    END
    
END PROCEDURE
Document
'DESCRIPCION: Proceso que registra la programacion de los pagos con base a un movimiento diario,', 
'			  registra el pago programado y genera el movimiento de portabilidad.',
'AUTOR: Antonio Bastidas',
'FECHA: 08/06/2010',
'VERSION: 20100618.1855',
'BD: BDICHEQ',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 19-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

CREATE PROCEDURE "informix".sp_cargoxcomision_pm_esp()
RETURNING
	CHAR(6)		AS cod_ret

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);

	DEFINE pNumcte			CHAR(20);
	DEFINE pCuenta			CHAR(20);
	DEFINE pProducto		CHAR(4);
	DEFINE pTransacc		CHAR(4);
	DEFINE dSdoPromMen		DECIMAL(18,2);
	DEFINE dMontoAplica		MONEY;
	DEFINE dMtoAplicComis	MONEY;
	DEFINE cAnioMesAnte		CHAR(6);
	DEFINE mValorSdoPos		MONEY;
	DEFINE mDisponible      MONEY(14,2);
	DEFINE cCodRetGF		CHAR(3);
	DEFINE cFolioGF			CHAR(16);
	DEFINE cCodRetCR		CHAR(5);
	DEFINE cComisionCR		CHAR(4);
	DEFINE mIva				MONEY(14,2);
	DEFINE dValIva			DECIMAL(9,6);
	DEFINE mMontoPen		MONEY(14,2);
	DEFINE mMtoCom			MONEY(14,2);
	DEFINE cTranCom         CHAR(4);
	DEFINE vTranIva         CHAR(4);
	DEFINE mSdoPromMM		MONEY;
	DEFINE mComCgoNoSMM		MONEY;
	DEFINE cTpoPersona		CHAR(1);
	DEFINE mComInacCta		MONEY;
	DEFINE dtFecUltDep		DATE;
	DEFINE dtFecUltRet		DATE;
	DEFINE dtFecUltMov		DATE;

	DEFINE iDifDias			INT8;
	DEFINE sBandCtaNva		SMALLINT;
	DEFINE sBandCargo		SMALLINT;
	DEFINE cDescTranRef		CHAR(40);
	DEFINE cDescIvaRef		CHAR(40);
	DEFINE sFecComision		DATE;
	DEFINE mAcumSdoPos		MONEY;
	DEFINE iDiaSdoPos		SMALLINT;
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaAlta		DATE;
	DEFINE mServAnualidad	MONEY;
	DEFINE mServAnualPrimCta	MONEY;
    DEFINE dtConsMovhis 	DATE;
    DEFINE dtConsMovhisold 	DATE;
    DEFINE dtConsMovhisold2 DATE;
	DEFINE sBandDetcomis	SMALLINT;
	DEFINE cTranSdoprommm	CHAR(4);
	DEFINE cTranInaccta		CHAR(4);
	DEFINE cTrananuaserv	CHAR(4);
	DEFINE cCtaCargoInaccta	CHAR(20);
	DEFINE cPrimerCta		CHAR(20);
	DEFINE mSaldoCta		MONEY;
	DEFINE iNumCtas			SMALLINT;
	DEFINE cBandCtaValida	CHAR(1);
	DEFINE cBandPrimCtaValida	CHAR(1);
	DEFINE sFecComBit		DATE;
	DEFINE sBandComBit		SMALLINT;
	DEFINE cCodRetCS		CHAR(5);
	DEFINE cStaCtaCS		CHAR(1);




	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";

	LET pNumcte				= "";
	LET pCuenta				= "";
	LET pProducto			= "";
	LET pTransacc			= "";
	LET dSdoPromMen			= 0.0;
	LET dMontoAplica		= 0.0;
	let dMtoAplicComis		= 0.0;
	LET cAnioMesAnte		= "";
	LET mValorSdoPos		= 0.0;
	LET mDisponible  		= 0;
	LET cCodRetGF			= "000";
	LET cFolioGF			= "";
	LET cCodRetCR			= "000";
	LET cComisionCR			= "";
	LET	mIva				= 0.0;
	LET dValIva				= 0.0;
	LET mMontoPen			= 0.0;
	LET mMtoCom             = 0.0;
	LET cTranCom         	= "";
	LET vTranIva         	= 0.0;
	LET mSdoPromMM			= 0.0;
	LET mComCgoNoSMM		= 0.0;
	LET cTpoPersona			= "";
	LET mComInacCta			= 0.0;
	LET dtFecUltDep			= NULL;
	LET dtFecUltRet			= NULL;
	LET dtFecUltMov			= NULL;
	LET iDifDias			= 0;
	LET sBandCtaNva			= NULL;
	LET sBandCargo			= 0;
	LET cDescTranRef		= "";
	LET cDescIvaRef			= "";
	LET sFecComision		= NULL;
	LET mAcumSdoPos			= 0.0;
	LET iDiaSdoPos			= 0;
	LET dtFechaHoy			= DATE(1);
	LET dtFechaAlta			= DATE(1);
	LET mServAnualidad		= 0.0;
	LET mServAnualPrimCta	= 0.0;
    LET dtConsMovhis 		= DATE(1);
    LET dtConsMovhisold 	= DATE(1);
    LET dtConsMovhisold2 	= DATE(1);
	LET sBandDetcomis		= 0;
	LET cTranSdoprommm		= "";
	LET cTranInaccta		= "";
	LET cTrananuaserv		= "";
	LET cCtaCargoInaccta	= "";
	LET mSaldoCta			= 0.0;
	LET cPrimerCta			= "";
	LET iNumCtas			= 0;
	LET cBandCtaValida		= "0";
	LET cBandPrimCtaValida	= 0;
	LET sFecComBit			= DATE(1);
	LET sBandComBit			= 0;
	LET cCodRetCS			= "000";
	LET cStaCtaCS			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/moha/sp_cargoxcomision_pm_esp.out';
	--TRACE ON;

	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sc_fechas
	WHERE empresa = "001";

	SELECT TRIM(valor)
	INTO cTranSdoprommm
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transdoprommm';

	SELECT TRIM(valor)
	INTO cTranInaccta
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transinaccta1';

	SELECT TRIM(valor)
	INTO cTrananuaserv
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transanuserven';

	--// OBTIENE EL VALOR DEL PARAMETRO DEL IVA
	SELECT TRIM(valor)
	INTO dValIva
	FROM bdinteg:"informix".si_param
	WHERE empresa = "001"
	AND cod_param = 47;

	-- CICLO DE LAS TRANSACCIONES
	FOREACH
		SELECT TRIM(valor)
		INTO pTransacc
		FROM "informix".sc_param
		WHERE empresa = "001"
		AND codparam IN ("transdoprommm","transinaccta1","transanuserven")

		--// OBTIENE EL VALOR DE LA COMISION A COBRAR DE LA TABLA sc_comisiones
		SELECT monto_aplica, transacc_com, transacc_iva
		INTO dMtoAplicComis, cTranCom, vTranIva
		FROM "informix".sc_comisiones
		WHERE empresa = "001"
		AND comision = pTransacc;

		LET dMtoAplicComis = NVL(dMtoAplicComis,0);

		--// CICLO PRINCIPAL DONDE BARRE TODAS LAS CUENTAS DE PERSONA MORAL
		FOREACH
			SELECT mae.cuenta, mae.producto, mae.num_cte, fecultdep, fecultret, pro.sdoprommen, noc.fecha_alta
			INTO pCuenta, pProducto, pNumcte, dtFecUltDep, dtFecUltRet, dSdoPromMen, dtFechaAlta
			FROM "informix".sc_producto pro, "informix".sc_maechq mae, "informix".sc_maenoc noc
			WHERE pro.empresa = "001"
			AND pro.producto = mae.producto
			AND pro.pago_interes = 'M'
			AND mae.empresa = pro.empresa
			AND mae.producto = pro.producto
			AND pro.producto IN ("1600","1200","2200")
			AND mae.status_cta IN ("1","4","5")
			AND noc.empresa = mae.empresa
			AND noc.cuenta = mae.cuenta

			LET sBandCargo = 0;

			IF pTransacc = cTranSdoprommm THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION / CARGO POR NO TENER SALDO PROMEDIO MINIMO MENSUAL
				LET mSdoPromMM = 0.0;
				LET mComCgoNoSMM = 0.0;
				LET mAcumSdoPos	= 0.0;
				LET iDiaSdoPos = 0;

				--// OBTIENE EL SALDO PROMEDIO MENSUAL Y LA COMISION EN LA TABLA MAESTRA DE LAS COMISIONES DE LA CUENTAS DE PERSONAS MORALES
				SELECT sdo_prom_mm, com_cgo_no_smm
				INTO mSdoPromMM, mComCgoNoSMM
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mSdoPromMM IS NOT NULL THEN
					LET dSdoPromMen = mSdoPromMM;
				ELSE
					LET mSdoPromMM = 0;

				END IF

				IF mComCgoNoSMM IS NOT NULL THEN
					LET dMontoAplica = mComCgoNoSMM;
				ELSE
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 OR pCuenta IN ("12000000602","12000001102","12000000270","12000000963") THEN
					LET sBandCargo = 0;
				ELSE
					-- OBTIENE EL AÃO Y EL MES ANTERIOR
					LET cAnioMesAnte = YEAR(dtFechaHoy - 1 units MONTH) || LPAD(MONTH(dtFechaHoy - 1 units MONTH),2,"0");
					--// OBTIENE EL VALOR ACUMULADO Y EL DIA DEL SALDO POS DE LA CUENTA
					SELECT acum_sdo_pos, dia_sdo_pos
					INTO mAcumSdoPos, iDiaSdoPos
					FROM "informix".sc_maehis
					WHERE aniomes = cAnioMesAnte
					AND cuenta = pCuenta;

					LET mAcumSdoPos = NVL(mAcumSdoPos, 0);
					LET iDiaSdoPos = NVL(iDiaSdoPos, 0);

					IF iDiaSdoPos = 0 THEN
						LET mValorSdoPos = 0;
					ELSE
						LET mValorSdoPos = mAcumSdoPos / iDiaSdoPos;
					END IF

					--// VALIDA SI EL SALDO POS ES MENOR AL SALDO PROMEDIO DE LA sc_producto
					IF mValorSdoPos < dSdoPromMen THEN
						LET sBandCargo = 1;
						LET cDescTranRef = "COMISION X NO TENER SALDO PROMEDIO MENS";
						LET cDescIvaRef = "IVA COMISION X NO TENER SALDO PROM MENS";
					END IF
				END IF
			ELIF pTransacc = cTranInaccta THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR INACTIVIDAD DE LA CUENTA DURANTE 1 AÃO
				LET mComInacCta = 0;
				LET dtFecUltMov	= NULL;

				SELECT com_ina_cta
				INTO mComInacCta
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mComInacCta IS NOT NULL THEN
					LET dMontoAplica = mComInacCta;
				ELSE
					LET mComInacCta = 0;
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- VALIDA QUE LA CUENTA TENGA POR LO MENOS UN AÃO DE VIDA
					IF (dtFechaHoy - dtFechaAlta) > 360 THEN

						IF dtFecUltDep IS NULL AND dtFecUltRet IS NULL THEN
							LET sBandCargo = 1;
						ELSE
							IF dtFecUltDep IS NOT NULL THEN
								LET dtFecUltMov = dtFecUltDep;
							END IF

							IF dtFecUltRet IS NOT NULL THEN
								IF dtFecUltRet > dtFecUltMov THEN
									LET dtFecUltMov = dtFecUltRet;
								END IF
							END IF

							IF (dtFechaHoy - dtFecUltMov) < 361 THEN
								LET sBandCargo = 0;
							ELSE
								LET sBandCargo = 1;
								LET cDescTranRef = "COMISION X INACTIVIDAD DE LA CTA 1 AÃO";
								LET cDescIvaRef = "IVA COMISION X INACT DE LA CTA 1 AÃO";
							END IF
						END IF
					END IF
				END IF
			ELIF pTransacc = cTrananuaserv THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR ANUALIDAD DEL SERVICIO DE EMPRESANET
				LET iDifDias = 0;
				LET sBandCtaNva = NULL;
				LET iNumCtas = 0;
				LET cBandCtaValida = "0";
				LET sFecComBit = DATE(1);
				LET sBandComBit	= 0;
				LET cPrimerCta = "";
				LET mServAnualPrimCta = 0.0;
				LET mServAnualidad = 0.0;
				LET mSaldoCta = 0.0;
				LET cCtaCargoInaccta = "";

				--// OBTIENE EL NUMERO DE DIAS DE LA FECHA ACTUAL RESPECTO A SU FECHA DE REGISTRO
				SELECT dtFechaHoy - f_registro
				INTO iDifDias
				FROM bdibei: "informix".bei_contratacion
				WHERE empresa = "001"
				AND num_cliente = pNumcte
				AND status_contrato = '30';

				IF iDifDias IS NULL THEN
					LET sBandCargo = 0;
				ELSE
					IF iDifDias > 31 AND iDifDias < 361 THEN
						LET sBandCargo = 0;
					ELSE
						IF iDifDias < 32 THEN
							LET sBandCtaNva = 1;
						ELSE
							LET sBandCtaNva = 0;
						END IF

						LET iNumCtas = 0;
						LET cBandCtaValida = "0";
						LET iDifDias = 0;

						SELECT MAX(fecha_gencom)
						INTO sFecComBit
						FROM "informix".sc_bitacora_compm
						WHERE tpo_com = cTrananuaserv
						AND num_cte = pNumcte;

						LET sBandComBit = 0;

						IF sFecComBit IS NOT NULL THEN
							LET iDifDias = dtFechaHoy - sFecComBit;
							IF sBandCtaNva = 1 THEN
								LET sBandComBit = 1;
							ELIF sBandCtaNva = 0 THEN
								IF iDifDias < 361 THEN
									LET sBandComBit = 1;
								END IF
							END IF
						END IF

						IF sBandComBit = 0 THEN
							FOREACH
								SELECT LIMIT 1 cuenta
								INTO cPrimerCta
								FROM bdicheq:"informix".sc_maechq
								WHERE empresa = "001"
								AND num_cte = pNumcte
								ORDER BY cuenta
							END FOREACH

							SELECT serv_anualidad
							INTO mServAnualPrimCta
							FROM "informix".sc_maecomtasserv_pm
							WHERE cuenta = cPrimerCta;

							IF cPrimerCta IS NOT NULL THEN
								-- // OBTIENE EL SALDO DE LA CUENTA
								EXECUTE PROCEDURE "informix".cons_saldo(cPrimerCta)
								INTO cCodRetCS, mSaldoCta, cStaCtaCS;

								LET iNumCtas = 1;

								IF mServAnualPrimCta IS NOT NULL THEN
									LET dMontoAplica = mServAnualPrimCta;
								ELSE
									LET dMontoAplica = dMtoAplicComis;
								END IF

								IF mSaldoCta >= dMontoAplica THEN
									LET cBandPrimCtaValida = 1;
								END IF
							END IF

							IF cBandPrimCtaValida = 1 THEN
								LET pCuenta = cPrimerCta;
							ELSE
								--// SE BARREN LAS CUENTAS DE DEBITO DEL CTE
								FOREACH
									SELECT cuenta, saldo
									INTO cCtaCargoInaccta, mSaldoCta
									FROM
									(
										--RQM 09 704. Se agrega el campo de saldo inmovilizado en el calculo de saldo disponible.DHG
										SELECT t1.cuenta, t1.sdo_actual - (t1.sdo_retenido + t1.sdo_cong + t1.imp_sbg_ccc + t1.saldo_sbc) AS saldo
										FROM "informix".sc_maechq t1, "informix".sc_maenoc t2
										WHERE t1.num_cte = pNumcte
										AND t1.cuenta = t2.cuenta
										AND t1.cuenta <> cPrimerCta
										AND t1.status_cta = "1"
										AND t1.producto IN ("1600","1200","2200")
										ORDER BY t2.fecha_alta
									)

									LET pCuenta = cCtaCargoInaccta;

									LET iNumCtas = iNumCtas + 1;

									IF iNumCtas = 1 THEN
										LET cPrimerCta = cCtaCargoInaccta;
									END IF

									SELECT serv_anualidad
									INTO mServAnualidad
									FROM "informix".sc_maecomtasserv_pm
									WHERE cuenta = pCuenta;

									IF mServAnualPrimCta IS NOT NULL THEN
										LET mServAnualidad = mServAnualPrimCta;
									ELSE
										LET mServAnualPrimCta = 0;
									END IF

									IF mServAnualidad IS NOT NULL THEN
										LET dMontoAplica = mServAnualidad;
									END IF

									IF dMontoAplica > mSaldoCta THEN
										CONTINUE FOREACH;
									ELSE
										LET cBandCtaValida = "1";
										EXIT FOREACH;
									END IF
								END FOREACH
							END IF

							-- VALIDA CUANDO NO HAY CUENTAS ACTIVAS PARA EL CLIENTE
							IF iNumCtas = 0 THEN
								LET sBandCargo = 0;
							ELSE
								IF dMontoAplica > 0 THEN
									LET sBandCargo = 1;
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF

			--// VALIDA SI SE CUMPLEN LAS CONDICIONES PARA SEGUIR CON EL CARGO
			IF sBandCargo = 1 THEN
				LET mDisponible = 0;
				LET mMtoCom = 0.0;
				LET mMontoPen = 0.0;
				LET	mIva = 0.0;
				LET cCodRetGF = "000";
				LET cFolioGF = "";
				LET cCodRetCR = "000";
				LET cComisionCR = "";

				let dMontoAplica = dMontoAplica;

				IF pTransacc = cTrananuaserv THEN
					INSERT INTO "informix".sc_bitacora_compm (tpo_com, num_cte, num_cta, fecha_gencom)
					VALUES (cTrananuaserv, pNumcte, pCuenta, dtFechaHoy);
					LET cDescTranRef = "COMISION X ANUALIDAD SERVICIO EMPRESANET";
					LET cDescIvaRef = "IVA COMISION X ANUALIDAD SERV EMPRESANET";
				END IF

				-- // OBTIENE EL SALDO DE LA CUENTA
				EXECUTE	PROCEDURE "informix".cons_saldo(pCuenta)
				INTO cCodRetCS, mDisponible, cStaCtaCS;

				-- // Aplica Cargo por Comision
				IF mDisponible > 5 THEN
					--// VALIDA SI EL SALDO DISPONIBLE ALCANZA PARA HACER EL COBRO SINO RECALCULA LA COMISION Y EL IVA
					IF mDisponible < (dMontoAplica * (1 + dValIva)) THEN
						LET mMtoCom   = dMontoAplica;
						LET dMontoAplica = ROUND(mDisponible / (1 + dValIva),2);
						LET mMontoPen = mMtoCom - dMontoAplica;
						LET mIva = mDisponible - dMontoAplica;
					ELSE
						LET mIva = TRUNC((dMontoAplica * dValIva),2);
					END IF;
					--// GENERA EL FOLIO DEL MOVIMIENTO
					EXECUTE PROCEDURE "informix".sp_generafolionomina ("informix")
					INTO cCodRetGF, cFolioGF;
					IF cCodRetGF::INTEGER <> 0 THEN
						LET cCodRet = cCodRetGF;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", cTranCom, "0000", cFolioGF, pCuenta, 0, dMontoAplica, "01", cDescTranRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DEL IVA DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", vTranIva, "0000", cFolioGF, pCuenta, 0, mIva, "01", cDescIvaRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					-- // Registra comision pendiente si es el caso
					IF mMontoPen > 0 THEN
						INSERT INTO "informix".sc_detcomis
						VALUES("001", pCuenta, cTranCom, mMontoPen  , 0, TODAY, "", "P", cFolioGF);

						UPDATE "informix".sc_maechq
						SET com_pendiente =  com_pendiente + mMontoPen
						WHERE empresa = "001"
						AND cuenta  = pCuenta;
					END IF;
				ELSE
					INSERT INTO "informix".sc_detcomis
					VALUES("001", pCuenta, cTranCom, dMontoAplica, 0, TODAY, "", "P", cFolioGF);

					UPDATE "informix".sc_maechq
					SET com_pendiente =  com_pendiente + dMontoAplica
					WHERE empresa = "001"
					AND cuenta  = pCuenta;
				END IF;
			END IF
		END FOREACH
	END FOREACH

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para el cargo parametrizado de comisiones para personas morales',
'BD: bdicheq',
'AUTOR: Mohamed CarreÃ³n ',
'FECHA: Octubre 2014',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 26-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.0.1';

CREATE PROCEDURE "informix".reverprov(pempresa  char(3),
                                      psucursal char(4),
                                      pusuario  char(8),
                                      pfolio    char(16),
                                      ptiporev  char(1),
				      pcuenta   char(20))

   RETURNING char(5);

   DEFINE sql_err             integer;
   DEFINE isam_err            integer;
   DEFINE cod_ret             char(5);
   DEFINE contador            smallint;
   DEFINE wcompend            money(14,2);
   DEFINE wtiptran            char(2);
   DEFINE wnum_serial         integer;
   DEFINE wtransacc           char(4);
   DEFINE wcuenta             char(20);
   DEFINE wmonto_tot          money(14,2);
   DEFINE wmonto_tot1         money(14,2);
   DEFINE montoaux            money(14,2);
   DEFINE wfirme              money(14,2);
   DEFINE wen_sbc             money(14,2);
   DEFINE wremesas            money(14,2);
   DEFINE wdias_ret           smallint;
   DEFINE wnum_cheq           integer;
   DEFINE wimp_sbg_ccc        money(14,2);
   DEFINE wimp_chq_sbg        money(14,2);
   DEFINE wimp_int_ccc        money(14,2);
   DEFINE wimp_int_sbg        money(14,2);
   DEFINE wchq_exp_mes        smallint;
   DEFINE wnaturaleza         char(1);
   DEFINE wvalida_docto       char(1);
   DEFINE wtipo               char(1);
   DEFINE wsaldo_cuenta       money(14,2);
   DEFINE wsdo_actual         money(14,2);
   DEFINE wsdo_retenido       money(14,2);
   DEFINE wsdo_cong           money(14,2);
   DEFINE wmontoaux           money(14,2);
   DEFINE wlim_chq_sbc        money(14,2);
   DEFINE wimp_chq_sbc        money(14,2);
   DEFINE wlim_chq_rem        money(14,2);
   DEFINE wimp_chq_rem        money(14,2);
   DEFINE wreferencia         char(40);
   DEFINE wstatus_envio       char(1);
   DEFINE wrowid              integer;
   DEFINE wfechoy             date;
   DEFINE pfolio1             char(16);
   DEFINE wtpcheque           char(2);
   DEFINE wfechahora          datetime hour to fraction(3);
   DEFINE vtranusoccc         char(4);
   DEFINE vtrancancta         char(4);
   DEFINE vtranintccc         char(4);
   DEFINE vtranusosbg         char(4);
   DEFINE vtranintsbg         char(4);
   DEFINE wcomision           char(4);
   DEFINE wsuc_cuen           char(4);
   DEFINE wproducto           char(4);
   define vnum_tarjeta        char(16);
   define vmaxsec             smallint;
   DEFINE vProdCrec           CHAR(4);
   define vanio               char(6);
   --RQM 09 704. Se agregan las siguientes variable DFTL 
   define mSaldoSbc       MONEY(14,2);
   define cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
   define cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
   

   LET sql_err = 0;
   LET cod_ret = "000";
   --RQM 09 704. Se agregan las siguientes variable DFTL
   LET mSaldoSbc           = 0;
   LET cCodRetConsSdo      = '00000';
   LET cMensajeRetConsSdo  = '';


   BEGIN
      ON EXCEPTION
         SET sql_err, isam_err
         IF (sql_err <> 0) THEN
            SET DEBUG FILE TO "reversionch.err";
            TRACE sql_err || " * " || isam_err;
            LET cod_ret = sql_err;
            RETURN cod_ret;
         END IF;
      END EXCEPTION;

      SELECT fecha_hoy into wfechoy
         FROM sc_fechas where empresa = pempresa;

      SELECT TRIM(valor)
        INTO vProdCrec
        FROM sc_param
       WHERE empresa = pempresa
         AND codparam ="PRODCREC";


      SELECT COUNT(*) INTO contador
         FROM sc_movhis m, bdinteg:si_transacc t
         WHERE m.empresa = pempresa and m.cuenta = pcuenta
	       and fech_alt ="01/02/2008"
	       and folio_suc = pfolio and
	       m.cuenta = pcuenta and
               m.empresa = t.empresa and m.transacc = t.numero and
               reversable = "S" and cancelad <> "S";

      IF (contador = 0) THEN
         SELECT COUNT(*) INTO contador
            FROM  sc_docret
            WHERE empresa = pempresa and folio_suc = pfolio and
                  fecha_alta = wfechoy;
         IF (contador = 0) THEN
            RETURN cod_ret;
         ELSE
            update sc_docret
               set cancelado = "S"
               WHERE empresa = pempresa and folio_suc = pfolio and
                     fecha_alta = wfechoy;
            RETURN cod_ret;
         end if
      end if

      select valor into vtrancancta
         from sc_param
         where empresa = pempresa and codparam = "trancancta";

      select valor into vtranusoccc
         from sc_param
         where empresa = pempresa and codparam = "tranusoccc";

      select valor into vtranintccc
         from sc_param
         where empresa = pempresa and codparam = "tranintccc";

      select valor into vtranusosbg
         from sc_param
         where empresa = pempresa and codparam = "tranusosbg";

      select valor into vtranintsbg
         from sc_param
         where empresa = pempresa and codparam = "tranintsbg";

      FOREACH
         select num_serial,transacc,cuenta,monto_tot,firme,en_sbc,remesas,
                md.dias_ret,num_cheq,naturaleza,valida_docto,tr.tipo_tran,
                referencia,suc_cuen,producto, aniomes
            into wnum_serial,wtransacc,wcuenta,wmonto_tot,wfirme,wen_sbc,
                 wremesas,wdias_ret,wnum_cheq,wnaturaleza,wvalida_docto,
                 wtiptran,wreferencia,wsuc_cuen,wproducto, vanio
            FROM sc_movhis md, bdinteg:si_transacc tr
            WHERE md.empresa = pempresa and folio_suc = pfolio and
		  md.cuenta = pcuenta
                  AND cancelad <> "S" and reversable = "S"
                  AND md.empresa = tr.empresa and numero = transacc
	--	  and transacc in ("3276", "3381")
            ORDER BY naturaleza desc
         select max(secuencia) into vmaxsec
            from sc_tarjeta
            where empresa = pempresa and cuenta = wcuenta and
                  tipo_tarjeta = "T";
         select num_tarjeta into vnum_tarjeta
            from sc_tarjeta
            where empresa = pempresa and cuenta = wcuenta and
                  secuencia = vmaxsec;
         LET wimp_sbg_ccc = 0;
         LET wimp_chq_sbg = 0;
         LET wimp_int_ccc = 0;
         LET wimp_int_sbg = 0;
         LET wchq_exp_mes = 0;
         let wcompend = 0;

         IF wtiptran = "01" THEN
            LET wchq_exp_mes  = 1;
         ELIF wtransacc = vtranusoccc THEN
            LET wimp_sbg_ccc = wmonto_tot;
         ELIF wtransacc = vtranusosbg THEN
            LET wimp_chq_sbg = wmonto_tot;
         ELIF wtransacc = vtranintccc THEN
            LET wimp_int_ccc = wmonto_tot;
         ELIF wtransacc = vtranintsbg THEN
            LET wimp_int_sbg = wmonto_tot;
         ELIF wtiptran = "05" THEN
            LET wcompend = wmonto_tot;
            let wcomision = trim(wreferencia);
         END IF;
         select sdo_actual into wsdo_actual
            from sc_maechq
            where empresa = pempresa and cuenta = wcuenta;

         IF wnaturaleza = "C" THEN
            UPDATE sc_maechq
               SET sdo_actual = sdo_actual + wmonto_tot,
                   imp_cgos_mes = imp_cgos_mes - wmonto_tot,
                   num_cgos_mes = num_cgos_mes - 1,
                   chq_exp_mes = chq_exp_mes - wchq_exp_mes,
                   imp_sbg_ccc = imp_sbg_ccc + wimp_sbg_ccc,
                   imp_int_ccc = imp_int_ccc + wimp_int_ccc,
                   imp_chq_sbg = imp_chq_sbg + wimp_chq_sbg,
                   imp_int_sbg = imp_int_sbg + wimp_int_sbg,
                   com_pendiente = com_pendiente + wcompend
               WHERE empresa = pempresa and cuenta = wcuenta;
            if wtransacc = vtrancancta then
               update sc_maechq
                  set status_cta = "1",
                      fec_cancelac = "",
                      motivo = " "
                  WHERE empresa = pempresa and cuenta = wcuenta;
            end if
            if wtiptran = "05" then
               update sc_detcomis
                  set pago_com = pago_com - wmonto_tot,
                      estado_com = "P"
                  where empresa = pempresa and cuenta = wcuenta and
                        comision = wcomision and fecult_pago = wfechoy;
            end if;
            if ptiporev = "A" then
               delete from sc_movhis
                  where num_serial = wnum_serial;
            else
               UPDATE sc_movhis
                  SET cancelad = "S"
                  WHERE num_serial = wnum_serial;
               INSERT INTO sc_movhis
                  VALUES(0,pfolio,psucursal,pusuario,wfechoy,wfechoy,
                      current hour to fraction(3),wtransacc,wsuc_cuen,
                      wproducto,pempresa,wcuenta," ",wnum_cheq,
                      wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                      "REV",0,vnum_tarjeta,"","");
            end if
            IF wtiptran = "01" THEN
               UPDATE sc_contch
                  SET estado = "N",
                      importe = 0
                  WHERE empresa = pempresa and cuenta = wcuenta AND
                        numero = wnum_cheq;
               UPDATE sc_histch
                  SET estado = "N",
                      importe = 0
                  WHERE empresa = pempresa and cuenta = wcuenta AND
                        numero = wnum_cheq;
            END IF;
         ELSE
            IF (wnaturaleza = "A") THEN
               LET wsaldo_cuenta       = 0;
               LET wsdo_actual         = 0;
               LET wsdo_retenido       = 0;
               LET wsdo_cong           = 0;

               SELECT sdo_actual, sdo_retenido, sdo_cong, saldo_sbc
                  INTO wsdo_actual,wsdo_retenido,wsdo_cong, mSaldoSbc
                  FROM sc_maechq
                  WHERE empresa = pempresa and cuenta = wcuenta;

               --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
               EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', wsdo_actual, wsdo_retenido, null, mSaldoSbc, null, null, null, 'F', 3)     
               INTO cCodRetConsSdo, cMensajeRetConsSdo, wsaldo_cuenta;

               IF wsaldo_cuenta < wfirme THEN
                  LET cod_ret = "413";
                  RETURN cod_ret;
               END IF;
               UPDATE sc_maechq
                  SET sdo_actual = sdo_actual - wmonto_tot,
                      sdo_retenido= sdo_retenido - wen_sbc,
                      imp_sbg_ccc = imp_sbg_ccc - wimp_sbg_ccc,
                      imp_chq_sbg = imp_chq_sbg - wimp_chq_sbg,
                      num_abonos_mes = num_abonos_mes - 1,
                      imp_abonos_mes = imp_abonos_mes - wmonto_tot
                  WHERE  empresa = pempresa and cuenta = wcuenta;
               if wen_sbc > 0 then
                  update sc_docret
                     set cancelado = "S"
                     where empresa = pempresa and cuenta = wcuenta
                           and folio_suc = pfolio
                           and fecha_alta = wfechoy;
               end if;

	       IF vProdCrec = wproducto THEN
		 UPDATE sc_maechq
		    SET marca_ret = "0"
		  WHERE empresa = pempresa
		    AND cuenta = wcuenta;
	       END IF

               IF (cod_ret = "000") THEN
                  if ptiporev = "A" then
                     delete from sc_movhis
                        where num_serial = wnum_serial;
                  else
                     {UPDATE sc_movhis
                        SET cancelad = "S"
			WHERE cuenta = pcuenta
			  AND fech_alt = "01/02/2008"
                          AND num_serial = wnum_serial;}
                     INSERT INTO sc_movhistmp
                        VALUES(vanio, 0,pfolio,psucursal,pusuario,wfechoy,
			       wfechoy,
                           current hour to fraction(3),wtransacc,wsuc_cuen,
                           wproducto,pempresa,wcuenta," ",wnum_cheq,
                           wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                           "REV",0,vnum_tarjeta,"");
                  end if
               END IF;
            END IF;
         END IF;
      END FOREACH;
   END;
   RETURN cod_ret;
END PROCEDURE DOCUMENT "Version 1.00.000",
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_prog_cierre()
    RETURNING CHAR(5) AS vCodRet1, CHAR(1000) AS vCodRet2, CHAR(1000) AS vCodRet3;

    DEFINE Sql_Err         INTEGER;
    DEFINE Isam_Err        INTEGER;
    DEFINE vCodRet1        CHAR(5);
    DEFINE vCodRet2        CHAR(1000);
    DEFINE vCodRet3        CHAR(1000);
    DEFINE vFechaHoy       DATE;
    DEFINE vTotal          INTEGER;
    DEFINE vOrigen         CHAR(4);
    DEFINE vDestino        CHAR(4);
	DEFINE vOrigen_c       CHAR(4);
    DEFINE vDestino_c      CHAR(4);
    DEFINE vestatus1       INTEGER;
    DEFINE vestatus0       INTEGER;
    DEFINE v_contador      INT;
    DEFINE v_contador2      INT;
    DEFINE iIsamErr        SMALLINT;
    DEFINE cDescErr        CHAR(80);
    DEFINE vsqlerr         INTEGER;
	DEFINE vErrorInfo      CHAR(80);
	DEFINE vstatus		   INTEGER;

    -- Retorno de SP interno
    DEFINE vRetCod         CHAR(5);
    DEFINE vRetMsg         CHAR(1000);
    DEFINE vRetDetalle     CHAR(1000);
    DEFINE vLog            CHAR(1000);
    DEFINE cErrorInfo      CHAR(80);
	DEFINE vstatus_maximo  CHAR(1);

    -- Acumulador de mensajes
    LET Sql_Err    = 0;
    LET Isam_Err   = 0;
    LET vCodRet1   = '00000';
    LET vCodRet2   = 'OPERACION EXITOSA';
    LET vCodRet3   = '';
    LET vLog       = 'No hay sucursales por procesar No hay registros con estatus 0 ni 1.';
    LET vestatus0  = 0;
    LET vestatus1  = 1;
    LET v_contador = 0;
    LET v_contador2 = 0;
    LET iIsamErr   = 0; 
    LET vsqlerr    = 0; 
    LET vErrorInfo = "INICIO DEL PROCESO";
    LET cErrorInfo = "";   


    BEGIN


        ON EXCEPTION SET vsqlerr, iIsamErr, cDescErr
            SET DEBUG FILE TO "/RESPALDOSNEW/sp_control_cierre_sucursal.err";
            TRACE ON;
            IF vsqlerr <> 0 THEN
                LET vCodRet1   = vsqlerr;
                LET vErrorInfo = cErrorInfo;
             RETURN vCodRet1, vCodRet2, vCodRet3;
            END IF;
        END EXCEPTION;

		--SET DEBUG FILE TO "/RESPALDOSNEW/sp_cierre_reproceso.out";
		--TRACE ON;

   
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy INTO vFechaHoy
        FROM informix.sc_fechas
        WHERE empresa = '001';
		
		--LET vFechaHoy = '07082025';

        -- Validar si hay registros con estatus 0 o 1
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus IN (0,1);

        IF vTotal = 0 THEN
            LET vCodRet3 = vLog;
			RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;

        -- Procesar estatus 0 y fecha = hoy
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus = 0 AND fecha_proceso = vFechaHoy;

        IF vTotal > 0 THEN
            FOREACH c0 WITH HOLD FOR
                SELECT origen, destino
                INTO vOrigen, vDestino
                FROM sc_prog_cierre
                WHERE estatus = 0 AND fecha_proceso = vFechaHoy

                CALL sp_control_cierre_sucursal(vOrigen, vDestino)
                RETURNING vRetCod,vRetDetalle;
                
                --LET vRetCod = '00000';

                IF vRetCod <> '00000' THEN
					
					IF  vRetCod = -668 THEN
					    
						UPDATE sc_prog_cierre
						SET estatus = '0'
						WHERE origen = vOrigen
						AND destino = vDestino 
						AND fecha_proceso = vFechaHoy;
						
						
						UPDATE bdicheq:sc_ctrl_cierre_suc
						SET 
						extrae_cuentas = '0'  -- Nuevo valor para el campo extrae_cuentas
						WHERE sucursal_origen = vOrigen
						AND sucursal_destino = vDestino;
					
					END  IF;
				
				
					LET vCodRet1 =  vRetCod;
                    LET vCodRet2 = 'DESCRIPCION  cierres con estatus 0 ' || vRetDetalle;
					
                    RETURN vCodRet1, vCodRet2, vCodRet3;
					
                END IF;
                 LET v_contador = v_contador + 1;
            END FOREACH;
            LET vLog =   'Procesados cierres con estatus 0. ' || v_contador;
			
			UPDATE bdicheq:sc_prog_cierre
			SET 
			estatus = '2'  -- se cambia el estatus a 2 si el proceso corrio exitosamente
			WHERE origen = vOrigen
			AND destino = vDestino
			AND fecha_proceso = vFechaHoy;
			
        END IF;

        -- Procesar estatus 1 y fecha = hoy (reproceso)
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus = 1 AND fecha_proceso = vFechaHoy;

        IF vTotal > 0 THEN
 
			SELECT origen, destino
            INTO vOrigen, vDestino
            FROM sc_prog_cierre
            WHERE estatus = 1 AND fecha_proceso = vFechaHoy;
				
			SELECT 
				MAX(GREATEST(
					NVL(extrae_cuentas, 0),
					NVL(ejecuta_bdicheq, 0),
					NVL(ejecuta_bdibpi, 0),
					NVL(ejecuta_bdicred, 0),
					NVL(ejecuta_bdicred_crd, 0),
					NVL(ejecuta_bdinteg, 0),
					NVL(ejecuta_bdinvers, 0),
					NVL(ejecuta_bdisolic, 0),
					NVL(ejecuta_bdicheq_comp, 0)
				))  AS status_maximo
			INTO vstatus_maximo
			FROM sc_ctrl_cierre_suc
			WHERE sucursal_origen = vOrigen 
    		AND sucursal_destino = vDestino;

			
            LET v_contador = 0;
			
            FOREACH c1 WITH HOLD FOR
                SELECT origen, destino
                INTO vOrigen, vDestino
                FROM sc_prog_cierre
                WHERE estatus = 1 AND fecha_proceso = vFechaHoy
				
                CALL sp_cierre_reproceso(vOrigen, vDestino,vstatus_maximo)
                RETURNING vRetCod, vRetMsg, vRetDetalle, vstatus;

                --LET vRetCod = '00000';

                IF vRetCod <> '00000' THEN

					IF  vRetCod = -668 THEN
					    
						UPDATE sc_prog_cierre
						SET estatus = '0'
						WHERE origen = vOrigen
						AND destino = vDestino 
						AND fecha_proceso = vFechaHoy;

						UPDATE bdicheq:sc_ctrl_cierre_suc
						SET 
						extrae_cuentas = '0'  -- Nuevo valor para el campo extrae_cuentas
						WHERE sucursal_origen = vOrigen
						AND sucursal_destino = vDestino;
					
					END  IF;
					
                    LET vCodRet1 =  vRetCod;
                    LET vCodRet2 = 'DESCRIPCION Reprocesados cierres con estatus 1' || vRetDetalle;
                    LET vCodRet3 = 'Error en el bloque: ' || vstatus;
					
                    RETURN vCodRet1, vCodRet2, vCodRet3;
                END IF;
                LET v_contador = v_contador + 1;
            END FOREACH;
			
			UPDATE bdicheq:sc_prog_cierre
			SET 
			estatus = '2'  -- se cambia el estatus a 2 si el proceso corrio exitosamente 
			WHERE origen = vOrigen
			AND destino = vDestino
			AND fecha_proceso = vFechaHoy;
			
            LET vLog =  'Reprocesados cierres con estatus 1 : ' || v_contador;
        END IF;

        
        -- Resultado final
        LET vCodRet1 = '00000';
        LET vCodRet2 = 'EJECUCION COMPLETA';
        LET vCodRet3 = vLog;

        RETURN vCodRet1, vCodRet2, vCodRet3;

    END;

END PROCEDURE;