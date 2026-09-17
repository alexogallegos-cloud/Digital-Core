create procedure "informix".consultmovs_pba(pempresa   char(3),
                                        pcuenta    char(20),
                                        psecuencia smallint)

returning char(5),date,char(40),money(14,2),money(14,2),money(14,2), char(200);

    define vtransacc        char(40);
    define vfecha           date;
    define vmonto           money(14,2);
    define vsdoactual       money(14,2);
    define vsdodisp         money(14,2);
    define vserial          integer;
    define vconta           smallint;
    define vciclo           smallint;
    define vcodret          char(5);
    define vsqlerr          integer;
    define vnaturaleza      char(1);
    define vultmovto        smallint;
    define cFech_param      CHAR(10);
    define cFech_param_ini  CHAR(10);
	define vdescripcion     CHAR(200);
	define vConceptospei1	CHAR(40);
	define vConceptospei2   CHAR(33);
	define dFechaVal		DATE;
	define vConceptospei3	CHAR(32);
	define vConceptospei4   CHAR(28);
	define vConceptospei5	CHAR(52);
	define vConceptospei6	CHAR(13);
	define cReferen         CHAR(40);
	define cTransacc		CHAR(4);
	define cConcepto        CHAR(50);
	define cReferencia      CHAR(40);
    define cFechaTrn		CHAR(10);
    define vTipoCta		    CHAR(9);
	define vLeyOutBeneficiario		CHAR(41);

    let vcodret    		= "000";
    let vtransacc  		= " ";
    let vfecha     		= " ";
    let vmonto     		= 0;
    let vsdoactual 		= 0;
    let vsdodisp   		= 0;
    let vciclo     		= 0;
    let vultmovto  		= 5;
	let vConceptospei1	= "";
	let vConceptospei2	= "";
	let dFechaVal		= "";
	let vConceptospei3	= "";
	let vConceptospei4	= "";
	let vConceptospei5	= "";
	let vConceptospei6	= "";
	let cReferen		= "";
	let cTransacc		="";
	let cConcepto		="";
	let cReferencia		="";
	let vdescripcion	="";
	let cFechaTrn		="";
    let vTipoCta		= "";
	let vLeyOutBeneficiario = '(Dato no verificado por esta institución)';

	--Set Debug File To '/informix/Jess/consultmovs.out';
    --Trace On;

    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp, vdescripcion;
        end if;
    end exception;
	

    
    SET ISOLATION TO DIRTY READ;

    select mc.sdo_actual, (mc.sdo_actual - mc.sdo_retenido - mc.sdo_cong)
      into vsdoactual, vsdodisp
      from sc_maechq mc
     where mc.empresa = pempresa 
       and mc.cuenta = pcuenta;
       
    if vsdoactual is null then
        let vsdoactual = 0;
        let vsdodisp = 0;
        let vcodret = "100";
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp, vdescripcion;
    end if;
    
    -- // Extrae los ultimos 5 movimientos
    foreach
        select md.fech_val, md.num_serial, md.monto_tot, md.transacc||" "||trim(tr.descripcion), tr.naturaleza,  md.referencia
          into vfecha, vserial, vmonto, vtransacc, vnaturaleza, cReferen
          from sc_movdia md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.cancelad not in("V","S") 
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
         order by fech_alt desc, num_serial desc

		  IF trim(substr(vtransacc,1,4)) = '0274' THEN

			IF SUBSTR(cReferen,1, 9) = 'BANCOPPEL' THEN
                SELECT NVL(vchrconceptopago,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				FROM bdispei:tblpago pgo 
				INNER JOIN bdispei:tblbanco bco
					ON pgo.cvecesifbcodest=bco.cvecesif
					WHERE vchrclaverastreo = cReferen
					AND dtfechavalor = vfecha
					AND intcvetipopago <> 0;
            ELSE
                SELECT NVL(vchrconceptopago2,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				FROM bdispei:tblpago pgo 
				INNER JOIN bdispei:tblbanco bco
					ON pgo.cvecesifbcodest=bco.cvecesif
					WHERE vchrclaverastreo = cReferen
					AND dtfechavalor = vfecha
					AND intcvetipopago <> 0;
            END IF;

            LET cFechaTrn=TO_CHAR(vfecha, '%d/%m/%Y');
  
            IF LENGTH(TRIM(vConceptospei4))=18 THEN
               LET vTipoCta='|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4))=16 THEN
			   LET vTipoCta='|DEBITO: ';
            ELSE
               LET vTipoCta='|CELULAR: ';
            END IF;
			
			LET vConceptospei1=TRIM(vdescripcion) || ' ' || cReferen;
			LET cReferen=vConceptospei1;
			
			LET vdescripcion="";
			
			LET vConceptospei2= 'BANCO DESTINO: ' || TRIM(vConceptospei2);
			LET vdescripcion=TRIM(vConceptospei2);
			
			LET vConceptospei3='|FECHA TRANSFERENCIA: ' || cFechaTrn;
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4=vTipoCta || TRIM(vConceptospei4);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5='|BENEFICIARIO: ' || TRIM(vConceptospei5);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei5) || vLeyOutBeneficiario;
			
			LET vConceptospei6='|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto='|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(cConcepto);
			
			LET vfecha= '';
			LET vfecha= dFechaVal;
			
		END IF;
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit foreach;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp , vdescripcion with resume;
    end foreach;
    
    SELECT valor
      INTO cFech_param
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO cFech_param_ini
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
    
    foreach
	    
        select {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
               md.fech_alt, md.fech_val, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza, md.referencia
          into vfecha,dFechaVal,vserial,vmonto,vtransacc,vnaturaleza,cReferen
          from sc_movhis md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.fech_alt >= cFech_param
           and md.cancelad not in("V","S") 
           and md.transacc = tr.numero
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
        union all
        select {+INDEX(bdicheq:sc_movhis_old movhis1)}
               md.fech_alt, md.fech_val, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza, md.referencia
          from sc_movhis_old md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.fech_alt >= cFech_param_ini
           and md.fech_alt < cFech_param
           and md.cancelad not in("V","S") 
           and md.transacc = tr.numero
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
         order by md.fech_alt desc, md.num_serial desc
		 
		 
		 ---  INFORMACION PARA OPERACIONES SPEI
		 let vdescripcion="";
		 let cTransacc=SUBSTR(TRIM(vtransacc),1,4);
		 
		 IF cTransacc = '0273' THEN

			 SELECT NVL(vchrconceptopago,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
			  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
			  FROM bdispei:tblhistpago pgo 
              INNER JOIN bdispei:tblbanco bco
                ON pgo.cvecesifbcoord=bco.cvecesif
			 WHERE vchrclaverastreo = cReferen
			   AND dtfechavalor = dFechaVal
			   AND intcvetipopago <> 0;

			LET cFechaTrn=TO_CHAR(vfecha, '%d/%m/%Y');

            IF LENGTH(TRIM(vConceptospei4))=18 THEN
               LET vTipoCta='|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4))=16 THEN
			   LET vTipoCta='|DEBITO: ';
            ELSE
               LET vTipoCta='|CELULAR: ';
            END IF;

			LET vConceptospei1=SUBSTR(TRIM(vtransacc),5,11) || ' ' || cReferen;
			LET cReferencia=vConceptospei1;
			
			LET vdescripcion="";
			
			LET vConceptospei2= 'BANCO ORIGEN: ' || TRIM(vConceptospei2);
			LET vdescripcion=TRIM(vConceptospei2);
			
			LET vConceptospei3='|FECHA TRANSFERENCIA: ' || cFechaTrn;
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4=vTipoCta || TRIM(vConceptospei4);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5='|ORDENANTE: ' || TRIM(vConceptospei5);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei5);
			
			LET vConceptospei6='|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto='|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(cConcepto);
			
			LET vfecha= '';
			LET vfecha= dFechaVal;
			
		END IF;

	    IF cTransacc = '0274' THEN

			IF SUBSTR(cReferen,1, 9) = 'BANCOPPEL' THEN
                SELECT NVL(vchrconceptopago,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				FROM bdispei:tblhistpago pgo 
				INNER JOIN bdispei:tblbanco bco
					ON pgo.cvecesifbcodest=bco.cvecesif
					WHERE vchrclaverastreo = cReferen
					AND dtfechavalor = dFechaVal
					AND intcvetipopago <> 0;
            ELSE
                SELECT NVL(vchrconceptopago2,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				FROM bdispei:tblhistpago pgo 
				INNER JOIN bdispei:tblbanco bco
					ON pgo.cvecesifbcodest=bco.cvecesif
					WHERE vchrclaverastreo = cReferen
					AND dtfechavalor = dFechaVal
					AND intcvetipopago <> 0;
            END IF;

            LET cFechaTrn=TO_CHAR(vfecha, '%d/%m/%Y');
  
            IF LENGTH(TRIM(vConceptospei4))=18 THEN
               LET vTipoCta='|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4))=16 THEN
			   LET vTipoCta='|DEBITO: ';
            ELSE
               LET vTipoCta='|CELULAR: ';
            END IF;
			
			LET vConceptospei1=TRIM(vdescripcion) || ' ' || cReferen;
			LET cReferen=vConceptospei1;
			
			LET vdescripcion="";
			
			LET vConceptospei2= 'BANCO DESTINO: ' || TRIM(vConceptospei2);
			LET vdescripcion=TRIM(vConceptospei2);
			
			LET vConceptospei3='|FECHA TRANSFERENCIA: ' || cFechaTrn;
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4=vTipoCta || TRIM(vConceptospei4);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5='|BENEFICIARIO: ' || TRIM(vConceptospei5);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei5) || vLeyOutBeneficiario;
			
			LET vConceptospei6='|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto='|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(cConcepto);
			
			LET vfecha= '';
			LET vfecha= dFechaVal;
			
		END IF;
		 
		 
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit foreach;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        if (vdescripcion is null) then let vdescripcion = ''; end if;

        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp , vdescripcion with resume;
    end foreach;
    
    end;
    
end procedure;