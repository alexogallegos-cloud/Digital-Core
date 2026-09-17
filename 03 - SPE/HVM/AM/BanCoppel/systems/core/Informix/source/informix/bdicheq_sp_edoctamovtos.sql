CREATE PROCEDURE "informix".sp_edoctamovtos(pEmpresa CHAR(3),
                                            pCuenta CHAR(20),
                                            pFechaInicial DATE,
                                            pFechaFinal DATE,
                                            pRegistro SMALLINT)

RETURNING CHAR(5), CHAR(10), CHAR(40), CHAR(200), CHAR(50),
          MONEY(14, 2), MONEY(14, 2), MONEY(14, 2);
		  
	--// ***************************************************************************
	--//Modificó: Alejandro Sanchez
	--//Fecha: Septiembre-2012
	--//Modificación: se agregó la consulta a la tabla tblhistpago para traer el concepto de los SPEI
	--// ***************************************************************************
 
		  
		  
    DEFINE vCodRet 					CHAR(5);
    DEFINE vSqlErr, vIsamErr, iAux 	INTEGER;
    DEFINE vCiclo 					SMALLINT;
    DEFINE dFechaMov1 				DATE;
    DEFINE dFechaMov 				CHAR(10);
    DEFINE dFechaTrn 				CHAR(10);
    DEFINE cReferencia 				CHAR(40);
    DEFINE cDescripcion 			CHAR(200);
	DEFINE cTransacc				CHAR(4);
	DEFINE cConcepto				CHAR(50);
    DEFINE mRetiro, mDeposito, mSaldo, mMonto 	MONEY(14, 2);
    DEFINE cNaturaleza 				CHAR(1);
    DEFINE cNumTarjeta 				CHAR(16);
    DEFINE vconsmovhis				CHAR(10);
    DEFINE vconsmovhisold			CHAR(10);
	DEFINE vConceptospei1			CHAR(40);
	DEFINE vConceptospei2           CHAR(33);
	DEFINE dFechaVal				DATE;
	DEFINE vConceptospei3			CHAR(32);
	DEFINE vConceptospei4			CHAR(28);
	DEFINE vConceptospei5			CHAR(52);
	DEFINE vConceptospei6			CHAR(13);
    DEFINE vTipoCta					CHAR(9);
	DEFINE vLeyOutBeneficiario		CHAR(41);

    LET vCodRet      = "000";
    LET dFechaMov    = "";
    LET creferencia  = "";
    LET cDescripcion = "";
	LET cTransacc 	 = "";
	LET cConcepto 	 = "";
    LET mRetiro      = 0;
    LET mDeposito    = 0;
    LET mSaldo       = 0;
    LET vCiclo       = 0;
    LET dFechaMov1   = "";
    LET pCuenta      = TRIM(pCuenta);
	LET vConceptospei1= "";
	LET vConceptospei2= "";
	LET dFechaVal= "";
	LET vConceptospei3= "";
	LET vConceptospei4= "";
	LET vConceptospei5= "";
	LET vConceptospei6= "";
    LET vTipoCta	 = "";
	LET vLeyOutBeneficiario = '(Dato no verificado por esta institución)';


    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
	IF vSqlErr != 0 THEN
	    LET vCodRet = vSqlErr;
	    RETURN vCodRet, dFechaMov, cReferencia, cDescripcion, cConcepto,
	           mRetiro, mDeposito, mSaldo;
	END IF;
    END EXCEPTION;

   --SET DEBUG FILE TO "/informix/Jess/sp_edoctamovtos.out";
   --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT valor
      INTO vconsmovhis
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO vconsmovhisold
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    FOREACH
        SELECT {+INDEX(sc_movhis idx_movhisnew4)}
               mm.num_serial, mm.fech_alt, mm.fech_val, mm.transacc,
               TRIM(tr.descripcion) AS descripcion,
               NVL(mm.referencia, '') AS referencia,
               NVL(mm.num_tarjeta, '') AS num_tarjeta,
               mm.monto_tot, tr.naturaleza, mm.sdo_cuenta
          INTO iAux, dFechaMov1, dFechaVal, cTransacc,cDescripcion, cReferencia,
               cNumTarjeta, mMonto, cNaturaleza, mSaldo
          FROM sc_movhis AS mm,
               bdinteg:si_transacc AS tr
         WHERE mm.empresa = pEmpresa
           AND mm.cuenta = pCuenta
           AND mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal
           AND mm.fech_alt >= vconsmovhis
           AND mm.cancelad <> "S"
           AND mm.transacc = tr.numero
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc
           AND tr.se_emite_edocta = "S"
		   AND tr.sistema = "01"

        UNION ALL

        SELECT {+INDEX(sc_movhis_old movhis1)}
               mm.num_serial, mm.fech_alt, mm.fech_val ,mm.transacc,
               TRIM(tr.descripcion) AS descripcion,
               NVL(mm.referencia, '') AS referencia,
               NVL(mm.num_tarjeta, '') AS num_tarjeta,
               mm.monto_tot, tr.naturaleza, mm.sdo_cuenta
          FROM sc_movhis_old AS mm,
               bdinteg:si_transacc AS tr
         WHERE mm.empresa = pEmpresa
           AND mm.cuenta = pCuenta
           AND mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal
           AND mm.fech_alt >= vconsmovhisold
           AND mm.fech_alt < vconsmovhis
           AND mm.cancelad <> "S"
           AND mm.transacc = tr.numero
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc
           AND tr.se_emite_edocta = "S"
		   AND tr.sistema = "01"

         ORDER BY mm.fech_alt DESC, mm.num_serial DESC, fech_alt DESC, num_serial DESC

        LET mRetiro = 0;
        LET mDeposito = 0;

        IF cNaturaleza = 'C' THEN
            LET mRetiro = mMonto;
        END IF;

        IF cNaturaleza = 'A' OR cNaturaleza = 'R' THEN
            LET mDeposito = mMonto;
        END IF;

        

		IF cTransacc = '0273' THEN
			SELECT vchrconceptopago, vchrnombrecorto, vchrcuentaord, vchrnombreord, intrefnumerica
			  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
			  FROM bdispei:tblhistpago pgo 
              INNER JOIN bdispei:tblbanco bco
                ON pgo.cvecesifbcoord=bco.cvecesif
			 WHERE vchrclaverastreo = cReferencia
			   AND dtfechavalor = dFechaVal
			   AND intcvetipopago <> 0;

            LET dFechaTrn = day(dFechaMov1)|| "/" ||							
						    Lpad(month(dFechaMov1),2,00)|| "/" ||
						    year(dFechaMov1);

            IF LENGTH(TRIM(vConceptospei4))=18 THEN
               LET vTipoCta='|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4))=16 THEN
			   LET vTipoCta='|DEBITO: ';
            ELSE
               LET vTipoCta='|CELULAR: ';
            END IF;
			
			LET vConceptospei1=TRIM(cDescripcion) || ' ' || cReferencia;
			LET cReferencia=vConceptospei1;
			
			LET cDescripcion="";
			
			LET vConceptospei2= 'BANCO ORIGEN: ' || TRIM(vConceptospei2);
			LET cDescripcion=TRIM(vConceptospei2);
			
			LET vConceptospei3='|FECHA TRANSFERENCIA: ' || dFechaTrn;
			LET cDescripcion=TRIM(cDescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4=TRIM(vTipoCta) || TRIM(vConceptospei4);
			LET cDescripcion=TRIM(cDescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5='|ORDENANTE: ' || TRIM(vConceptospei5);
			LET cDescripcion=TRIM(cDescripcion) || TRIM(vConceptospei5);
			
			LET vConceptospei6='|REF: ' || TRIM(vConceptospei6);
			LET cDescripcion=TRIM(cDescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto='CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			
			LET dFechaMov1= '';
			LET dFechaMov1= dFechaVal;
			
			   
		END IF;

	    IF cTransacc = '0274' THEN
            IF SUBSTR(cReferencia,1, 9) = 'BANCOPPEL' THEN
                SELECT vchrconceptopago, vchrnombrecorto, vchrcuentabenef, vchrnombrebenef, intrefnumerica
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				FROM bdispei:tblhistpago pgo 
				INNER JOIN bdispei:tblbanco bco
					ON pgo.cvecesifbcodest=bco.cvecesif
					WHERE vchrclaverastreo = cReferencia
					AND dtfechavalor = dFechaVal
					AND intcvetipopago <> 0;
            ELSE
                SELECT vchrconceptopago2, vchrnombrecorto, vchrcuentabenef, vchrnombrebenef, intrefnumerica
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				FROM bdispei:tblhistpago pgo 
				INNER JOIN bdispei:tblbanco bco
					ON pgo.cvecesifbcodest=bco.cvecesif
					WHERE vchrclaverastreo = cReferencia
					AND dtfechavalor = dFechaVal
					AND intcvetipopago <> 0;
            END IF;

			LET dFechaTrn = day(dFechaMov1)|| "/" ||
						    Lpad(month(dFechaMov1),2,00)|| "/" ||
						    year(dFechaMov1);

			IF LENGTH(TRIM(vConceptospei4))=18 THEN
               LET vTipoCta='|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4))=16 THEN
			   LET vTipoCta='|DEBITO: ';
            ELSE
               LET vTipoCta='|CELULAR: ';
            END IF;

			LET vConceptospei1=TRIM(cDescripcion) || ' ' || cReferencia;
			LET cReferencia=vConceptospei1;
			
			LET cDescripcion="";
			
			LET vConceptospei2= 'BANCO DESTINO: ' || TRIM(vConceptospei2);
			LET cDescripcion=TRIM(vConceptospei2);
			
			LET vConceptospei3='|FECHA TRANSFERENCIA: ' || dFechaTrn;
			LET cDescripcion=TRIM(cDescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4=TRIM(vTipoCta) || TRIM(vConceptospei4);
			LET cDescripcion=TRIM(cDescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5='|BENEFICIARIO: ' || TRIM(vConceptospei5);
			LET cDescripcion=TRIM(cDescripcion) || TRIM(vConceptospei5) || vLeyOutBeneficiario;
			
			LET vConceptospei6='|REF: ' || TRIM(vConceptospei6);
			LET cDescripcion=TRIM(cDescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto='CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			
			LET dFechaMov1= '';
			LET dFechaMov1= dFechaVal;
			
		END IF;

        LET vCiclo = vCiclo + 1;

        -- // PAGINACION
        IF vciclo <= pRegistro THEN
            CONTINUE FOREACH;
        END IF;

        LET dfechamov = SUBSTR(dFechaMov1, 7, 10) || "/" ||
                        SUBSTR(dFechaMov1, 1, 2)  || "/" ||
                        SUBSTR(dFechaMov1, 4, 5);

        RETURN vCodRet, dfechamov, cReferencia, cDescripcion, cConcepto,
               mRetiro, mDeposito, mSaldo WITH RESUME;

		LET cConcepto = "";

    END FOREACH;

    END;

END PROCEDURE;