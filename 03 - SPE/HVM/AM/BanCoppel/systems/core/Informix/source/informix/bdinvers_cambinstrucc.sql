create procedure "informix".cambinstrucc(pempresa    char(3),
                                         pcuenta     char(20),
                                         pinstcap    char(2),
                                         pinstint    char(2),
                                         pctacap     char(20),
                                         pctaint     char(20),
                                         pfechavenc  date,
                                         pusuariomod char(8),
                                         pejecuta    char(1))
              
returning char(5);

   define vcodret char(5);
   define vstatus,vrequiere_cuenta,vstachq,
          vaceabo,vper_acred_int char(1);
   define vsistcap,vsistint,vmonchq,vmoneda,
          vmotivo, vinstcapant, vinstintant char(2);
   define vproducto char(4);
   define vctacapant, vctaintant char(20);
   define sql_err integer;
   define isam_err integer;
   define vfecha_hoy,vfecha_venc, vfecvenccapant, vfecvencintant date;
   
   DEFINE vexiste, vaceptab CHAR(1);

   let vcodret  = "000";
   let vexiste  = '';
   let vaceptab = '';

    begin
    
    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let vcodret = sql_err;
            return vcodret;
        end if
    end exception

    --   Modificacion realizada por Mariecito !! OJO !!
    --   ATC if pempresa = " " or pcuenta = " " or pinstcap = " " or
    --   ATC   pinstint = " " or pctacap = " " or pctaint = " " then
    --   ATC   let vcodret = "110";
    --   ATC   return vcodret;
    --   ATC end if

    --- set debug file to "/respaldosbd/jc/cambinstrucc.out";
    --- trace on;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    if pempresa = " " or pinstcap = " " or
        pinstint = " " or pcuenta = " " then
        let vcodret = "110";
        return vcodret;
    end if

    select fecha_hoy
      into vfecha_hoy
      from sv_fechas
     where empresa = pempresa;

    select status_cta,fecha_venc,moneda,mv.per_acred_int
      into vstatus,vfecha_venc,vmoneda,vper_acred_int
      from sv_maeinv mv,
     outer sv_instrum pr
     where mv.empresa = pempresa 
       and cuenta = pcuenta 
       and status_cta not in("2", "4")
       and mv.cod_instrum = pr.cod_instrum;

    if vstatus is null then
        let vcodret = "100";
        return vcodret;
    end if

    if vfecha_venc <= vfecha_hoy then
        let vcodret = "361";
        return vcodret;
    end if

    if pfechavenc > vfecha_venc then
        let vcodret = "362";
        return vcodret;
    end if

    if pfechavenc = vfecha_hoy then
        let vcodret = "363";
        return vcodret;
    end if

    select sistema_relac,requiere_cuenta
      into vsistcap ,vrequiere_cuenta
      from sv_instrucc
     where codigo = pinstcap;

    --- if vrequiere_cuenta = "S" then
        --- if vsistcap = "01" then
    
    -- // Valida exista cuenta de cheques
    select producto, motivo, status_cta
      into vproducto, vmotivo, vstachq
      from bdicheq:sc_maechq
     where empresa = pempresa 
       and cuenta = pctacap;

    if vproducto is null then
        let vcodret = "153";
        return vcodret;
    end if
    
    if vproducto = "1100" then
        let vcodret = "154";
        return vcodret;
    end if
    
    if vstachq = "2" then
        let vcodret = "155";
        return vcodret;
    end if
	--//Valida que no permita hacer cambio de instruccion diferente a liquidacion para cuentas 1500 o 2500 Ligadas a la Inversion.
	IF pinstcap <> "02" THEN
		IF vproducto = "1500" THEN
			let vcodret = "156";
			return vcodret;
		END IF;
		
		IF vproducto = "2500" THEN
			let vcodret = "156";
			return vcodret;
		END IF;
	END IF;
    
    -- // Valida si la cuenta esta bloqueada y permite abonos
    if vstachq = "3" then
        --- select abono 
        ---   into vaceabo
        ---   from bdinteg:si_bloqueo
        ---  where cod_bloqueo = vmotivo;
         
        --- if vaceabo <> "S" then
        ---     let vcodret = "156";
        ---     return vcodret;
        --- end if
        
        SELECT "1" 
          INTO vexiste
          FROM bdicheq:sc_ctabloqueo 
         WHERE cuenta = pctacap;

        IF vexiste = "1" THEN 
            SELECT opcion 
              INTO vaceptab
              FROM bdicheq:sc_ctabloqueo 
             WHERE cuenta = pctacap;

            IF vaceptab = 4 THEN
                LET vcodret = "301";
                RETURN vcodret;
            ELSE
                IF vaceptab = 2 THEN
                    LET vcodret = "301";
                    RETURN vcodret;
                END IF;
            END IF;
        ELSE
            SELECT abono 
              INTO vaceptab
              FROM bdicheq:sc_bloqueo 
             WHERE codigo = vmotivo;

            IF vaceptab = "N" THEN
                LET vcodret = "301";
                RETURN vcodret;
            END IF;
        END IF;
        
    end if
    
    -- // Valida moneda
    select divisa
      into vmonchq
      from bdicheq:sc_producto
     where producto = vproducto ;

    if vmonchq <> vmoneda then
        let vcodret = "135";
        return vcodret;
    end if
    
    ---     end if
    --- else
    ---     let pctacap = " ";
    --- end if

    -- // Valida que no se reinviertan los intereses si se trata de CEDES
    if vper_acred_int = "M" and pinstint = "01" then
        let vcodret = "145";
        return vcodret;
    end if

    -- // Valida que no se reinviertan solo los intereses
    if pinstcap <> "01"  and pinstint = "01"then
        let vcodret = "311";
        return vcodret;
    end if

    select sistema_relac,requiere_cuenta
      into vsistint ,vrequiere_cuenta
      from sv_instrucc
     where codigo = pinstint;

    --- if vrequiere_cuenta = "S" then
    ---     if vsistint = "01" then
    
    -- // Valida exista cuenta de cheques
    
	IF pctacap <> pctaint THEN
		select producto, motivo, status_cta
		into vproducto, vmotivo, vstachq
		from bdicheq:sc_maechq
		where empresa = pempresa 
		and cuenta = pctaint;

		if vproducto is null then
			let vcodret = "153";
			return vcodret;
		end if

		if vproducto = "1100" then
			let vcodret = "154";
			return vcodret;
		end if

		if vstachq = "2" then
			let vcodret = "155";
			return vcodret;
		end if
		--//Valida que no permita hacer cambio de instruccion diferente a liquidacion para cuentas 1500 o 2500 Ligadas a la Inversion.
		IF pinstcap <> "02" THEN
			IF vproducto = "1500" THEN
				let vcodret = "156";
				return vcodret;
			END IF;
			
			IF vproducto = "2500" THEN
				let vcodret = "156";
				return vcodret;
			END IF;
		END IF;
	
       -- // Valida si la cuenta esta bloqueada y permite abonos
       if vstachq = "3" then
          --- select abono 
          ---   into vaceabo
          ---   from bdinteg:si_bloqueo
          ---  where cod_bloqueo = vmotivo;
         
          --- if vaceabo <> "S" then
          ---     let vcodret = "156";
          ---     return vcodret;
          --- end if
        
          SELECT "1" 
            INTO vexiste
            FROM bdicheq:sc_ctabloqueo 
           WHERE cuenta = pctacap;

          IF vexiste = "1" THEN 
             SELECT opcion 
               INTO vaceptab
               FROM bdicheq:sc_ctabloqueo 
              WHERE cuenta = pctacap;

             IF vaceptab = 4 THEN
                LET vcodret = "301";
                RETURN vcodret;
             ELSE
                IF vaceptab = 2 THEN
                   LET vcodret = "301";
                   RETURN vcodret;
                END IF;
             END IF;
          ELSE
              SELECT abono 
                INTO vaceptab
                FROM bdicheq:sc_bloqueo 
                WHERE codigo = vmotivo;

              IF vaceptab = "N" THEN
                 LET vcodret = "301";
                 RETURN vcodret;
              END IF;
          END IF;
        END IF;
    end if
    
    -- // Valida moneda
    select divisa 
      into vmonchq 
      from bdicheq:sc_producto
     where producto = vproducto ;

    if vmonchq <> vmoneda then
        let vcodret = "135";
        return vcodret;
    end if
    
    ---     end if
    --- else
    ---     let pctaint = " ";
    --- end if

    select inst_vento, cta_cheques, fecha_venc
      into vinstcapant, vctacapant, vfecvenccapant
      from sv_maeinstrucc
     where empresa = pempresa 
       and cuenta = pcuenta 
       and cap_int = "C";

    select inst_vento, cta_cheques, fecha_venc
      into vinstintant, vctaintant, vfecvencintant
      from sv_maeinstrucc
     where empresa = pempresa 
       and cuenta = pcuenta 
       and cap_int = "I";

    update sv_maeinstrucc
       set inst_vento = pinstcap, 
           sistema = vsistcap, 
           cta_cheques = pctacap, 
           fecha_venc = pfechavenc
     where empresa = pempresa 
        and cuenta = pcuenta 
        and cap_int = "C";

    update sv_maeinstrucc
       set inst_vento = pinstint, 
           sistema = vsistint, 
           cta_cheques = pctaint, 
           fecha_venc = pfechavenc
     where empresa = pempresa 
       and cuenta = pcuenta 
       and cap_int = "I";

    insert into sv_maeinstrucchis 
    (empresa,cuenta,cap_int,instvento_ant,instvento_nuevo,ctacheques_ant,ctacheques_nuevo,fechavenc_ant,fechavenc_nuevo,usuariomod,fecha_mod)
    values
    (pempresa, pcuenta, "C", vinstcapant, pinstcap, vctacapant, pctacap, vfecvenccapant, pfechavenc, pusuariomod, current);

    insert into sv_maeinstrucchis 
    (empresa,cuenta,cap_int,instvento_ant,instvento_nuevo,ctacheques_ant,ctacheques_nuevo,fechavenc_ant,fechavenc_nuevo,usuariomod,fecha_mod)
    values
    (pempresa, pcuenta, "I", vinstintant, pinstint, vctaintant, pctaint, vfecvencintant, pfechavenc, pusuariomod, current);
    
    -- // Si ejecuta central
    if pejecuta = "1" then
        update sv_maeinv
           set fecha_venc = pfechavenc, 
               cta_cheques = pctacap
         where empresa = pempresa 
           and cuenta = pcuenta 
           and status_cta = "1";
    end if

    end
    
    return vcodret;
    
end procedure

