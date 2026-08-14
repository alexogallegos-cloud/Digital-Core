CREATE PROCEDURE "informix".consultmovs_web_pbajlh(pempresa   CHAR(3),
                                        pcuenta    CHAR(20),
                                        psecuencia SMALLINT)

RETURNING CHAR(5),DATE,CHAR(40),MONEY(14,2),MONEY(14,2),MONEY(14,2), CHAR(200);

    DEFINE vtransacc        CHAR(40);
    DEFINE vfecha           DATE;
    DEFINE vmonto           MONEY(14,2);
    DEFINE vsdoactual       MONEY(14,2);
    DEFINE vsdodisp         MONEY(14,2);
    DEFINE vserial          INTEGER;
    DEFINE vconta           SMALLINT;
    DEFINE vciclo           SMALLINT;
    DEFINE vcodret          CHAR(5);
    DEFINE vsqlerr          INTEGER;
    DEFINE vnaturaleza      CHAR(1);
    DEFINE vultmovto        SMALLINT;
    DEFINE cFech_param      CHAR(10);
    DEFINE cFech_param_ini  CHAR(10);
	DEFINE vdescripcion     CHAR(200);
	DEFINE vConceptospei1	CHAR(40);
	DEFINE vConceptospei2   CHAR(33);
	DEFINE dFechaVal		DATE;
	DEFINE vConceptospei3	CHAR(32);
	DEFINE vConceptospei4   CHAR(28);
	DEFINE vConceptospei5	CHAR(52);
	DEFINE vConceptospei6	CHAR(13);
	DEFINE cReferen         CHAR(40);
	DEFINE cTransacc		CHAR(4);
	DEFINE cConcepto        CHAR(50);
	DEFINE cReferencia      CHAR(40);
    DEFINE cFechaTrn		CHAR(10);
    DEFINE vTipoCta		    CHAR(9);
	DEFINE vLeyOutBeneficiario		CHAR(41);

    LET vcodret    		= "00000";
    LET vtransacc  		= " ";
    LET vfecha     		= " ";
    LET vmonto     		= 0;
    LET vsdoactual 		= 0;
    LET vsdodisp   		= 0;
    LET vciclo     		= 0;
    LET vultmovto  		= 5;
	LET vConceptospei1	= "";
	LET vConceptospei2	= "";
	LET dFechaVal		= "";
	LET vConceptospei3	= "";
	LET vConceptospei4	= "";
	LET vConceptospei5	= "";
	LET vConceptospei6	= "";
	LET cReferen		= "";
	LET cTransacc		="";
	LET cConcepto		="";
	LET cReferencia		="";
	LET vdescripcion	="";
	LET cFechaTrn		="";
    LET vTipoCta		= "";
	let vLeyOutBeneficiario = '(Dato no verificado por esta instituciÃÂ³n)';

    BEGIN
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp, vdescripcion;
        end if;
    end exception;
	
	--Set Debug File To 'consultmovs.out';
    --Trace On;
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;

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
    FOREACH
        select md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza,  md.referencia
          into vfecha, vserial, vmonto, vtransacc, vnaturaleza, cReferen
          from sc_movdia md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.cancelad <> "S"
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
		   and tr.sistema = "01"
         order by fech_alt desc, num_serial desc
		 
		 IF trim(substr(vtransacc,1,4)) = '0274' THEN

			IF SUBSTR(cReferen,1, 9) = 'BANCOPPEL' THEN
                SELECT {+INDEX(bdispei:tblbanco xak1tblbanco2)}
                       NVL(vchrconceptopago,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				  FROM bdispei:tblpago pgo 
				 INNER JOIN bdispei:tblbanco bco ON ( pgo.cvecesifbcodest = bco.cvecesif AND bco.intindice = bco.intindice )
				 WHERE vchrclaverastreo = cReferen
				   AND dtfechavalor = vfecha
				   AND intcvetipopago <> 0;
            ELSE
                SELECT {+INDEX(bdispei:tblbanco xak1tblbanco2)}
                       NVL(vchrconceptopago2,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				  FROM bdispei:tblpago pgo 
				 INNER JOIN bdispei:tblbanco bco ON ( pgo.cvecesifbcodest = bco.cvecesif AND bco.intindice = bco.intindice )
				 WHERE vchrclaverastreo = cReferen
				   AND dtfechavalor = vfecha
				   AND intcvetipopago <> 0;
            END IF;

            LET cFechaTrn = TO_CHAR(vfecha, '%d/%m/%Y');
  
            IF LENGTH(TRIM(vConceptospei4)) = 18 THEN
               LET vTipoCta = '|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4)) = 16 THEN
			   LET vTipoCta = '|DEBITO: ';
            ELSE
               LET vTipoCta = '|CELULAR: ';
            END IF;
			
			LET vConceptospei1 = TRIM(vdescripcion) || ' ' || cReferen;
			LET cReferen = vConceptospei1;
			
			LET vdescripcion = "";
			
			LET vConceptospei2 = 'BANCO DESTINO: ' || TRIM(vConceptospei2);
			LET vdescripcion = TRIM(vConceptospei2);
			
			LET vConceptospei3 = '|FECHA TRANSFERENCIA: ' || cFechaTrn;
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4 = vTipoCta || TRIM(vConceptospei4);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5 = '|BENEFICIARIO: ' || TRIM(vConceptospei5);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei5) || vLeyOutBeneficiario;
			
			LET vConceptospei6 = '|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto = '|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(cConcepto);
			
			--LET vfecha = '';
			--LET vfecha = dFechaVal;
			
		END IF;
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit FOREACH;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp , vdescripcion with resume;
    end FOREACH;
    
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
    
    FOREACH
	    
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
		   and tr.sistema = "01"
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
		   and tr.sistema = "01"
         order by md.fech_alt desc, md.num_serial desc
		 
		 
		 ---  INFORMACION PARA OPERACIONES SPEI
		 let vdescripcion="";
		 let cTransacc=SUBSTR(TRIM(vtransacc),1,4);
		 
		 IF cTransacc = '0273' THEN

			 SELECT {+INDEX(bdispei:tblbanco xak1tblbanco2)}
                   NVL(vchrconceptopago,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
			  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
			  FROM bdispei:tblhistpago pgo 
              INNER JOIN bdispei:tblbanco bco ON ( pgo.cvecesifbcoord = bco.cvecesif AND bco.intindice = bco.intindice )
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
                SELECT {+INDEX(bdispei:tblbanco xak1tblbanco2)} NVL(vchrconceptopago,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				FROM bdispei:tblhistpago pgo 
				INNER JOIN bdispei:tblbanco bco
					ON ( pgo.cvecesifbcodest = bco.cvecesif AND bco.intindice = bco.intindice )
					WHERE vchrclaverastreo = cReferen
					AND dtfechavalor = dFechaVal
					AND intcvetipopago <> 0;
            ELSE
                SELECT {+INDEX(bdispei:tblbanco xak1tblbanco2)} NVL(vchrconceptopago2,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				FROM bdispei:tblhistpago pgo 
				INNER JOIN bdispei:tblbanco bco
					ON ( pgo.cvecesifbcodest = bco.cvecesif AND bco.intindice = bco.intindice )
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
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei5)|| vLeyOutBeneficiario;
			
			LET vConceptospei6='|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto='|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			LET vdescripcion=TRIM(vdescripcion) || TRIM(cConcepto);
			
			LET vfecha= '';
			LET vfecha= dFechaVal;
			
		END IF;
		 
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit FOREACH;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp ,  NVL(vdescripcion,'|||||') with resume;
    end FOREACH;
    
    END;   
END PROCEDURE;