CREATE PROCEDURE "informix".totcomp(pempresa CHAR(3),
                                    pusuario CHAR(8),
                                    psucursal CHAR(4),
                                    pnum_total SMALLINT)
RETURNING CHAR(5),CHAR(2),MONEY(16,2),MONEY(16,2),MONEY(16,2),
          MONEY(16,2),CHAR(40),INTEGER,INTEGER,INTEGER,INTEGER;

    DEFINE v_monto_cargo,v_monto_firme,v_monto_sbc,v_monto_rem  MONEY(16,2);
    DEFINE v_movto_cargo,v_movto_firme,v_movto_sbc,v_movto_rem  INTEGER;
    DEFINE v_descripcion    CHAR(40);
    DEFINE v_contador       SMALLINT;
    DEFINE v_fecha          DATE;
    DEFINE v_row            INTEGER;
    DEFINE v_codret         CHAR(5);
    DEFINE v_producto       CHAR(4);
    DEFINE v_ciclo          SMALLINT;
    DEFINE v_moneda         CHAR(2);
    DEFINE v_cal_int_chq    CHAR(1);
    DEFINE sql_err          INTEGER;
    DEFINE vsuc_user        CHAR(4);
    DEFINE vfecha           DATE;
--HOMOLOGACION GDF
	DEFINE v_transacc_suc		CHAR(4);
	DEFINE v_monto_cargo_cred   MONEY(16,2);
	DEFINE v_movto_cargo_cred   INTEGER;
--	2013.08.09 FRG-I.
	DEFINE cTransaccSdoFav 	CHAR(4);
--2013.08.09 FRG-F.
-- HOMOLOGACION CLUB DE PROTECCION:
	DEFINE v_transacc_suc_cp 	CHAR(4);
	DEFINE cTransaccSdoFav_cp 	CHAR(4);

--2015-01-21 DSB 
-- HOMOLOGACION TIEMPO AIRE ELECTRONICO:
	DEFINE v_transacc_suc_tae 	CHAR(4);
	DEFINE cTransaccSdoFav_tae 	CHAR(4);
	
--2015-02-18 DSB 
-- HOMOLOGACION PAGO EDOMEX:
	DEFINE v_transacc_suc_edomex	CHAR(4);
	DEFINE cTransaccSdoFav_edomex	CHAR(4);
	
--  2014.10.01 Transfer
    DEFINE  v_movto_sbc_tf   INTEGER;
    DEFINE  v_monto_sbc_tf   MONEY(16,2);
    DEFINE  v_movto_firme_tf INTEGER;
    DEFINE  v_monto_firme_tf MONEY(16,2);
    DEFINE  v_movto_cargo_tf INTEGER;
    DEFINE  v_monto_cargo_tf MONEY(16,2);

--	2013.08.09 FRG-F.

    LET v_contador = 0;
    LET v_ciclo = 0;
    LET v_moneda = 0;
    LET v_monto_cargo = 0;
    LET v_monto_firme = 0;
    LET v_monto_sbc = 0;
    LET v_monto_rem = 0;
    LET v_movto_cargo = 0;
    LET v_movto_firme = 0;
    LET v_movto_sbc = 0;
    LET v_movto_rem = 0;
    LET v_descripcion = " ";
    LET v_codret = "000";
    LET vsuc_user = "";
--HOMOLOGACION GDF
	LET v_transacc_suc 		= "";
	LET v_monto_cargo_cred  = 0;
	LET v_movto_cargo_cred  = 0;
--	2013.08.09 FRG-I.
	LET cTransaccSdoFav 	= "";
--	2013.08.09 FRG-F.
	-- HOMOLOGACION CLUB DE PROTECCION:
	LET v_transacc_suc_cp	= "";
	LET cTransaccSdoFav_cp	= "";

--2014.10.01 Inicialicacion Var Transfer
    LET    v_movto_sbc_tf = 0;
    LET    v_monto_sbc_tf = 0; 
    LET    v_movto_firme_tf = 0;
    LET    v_monto_firme_tf = 0;
    LET    v_movto_cargo_tf = 0;
    LET    v_monto_cargo_tf = 0;

-- HOMOLOGACION TIEMPO AIRE ELECTRONICO:
	LET v_transacc_suc_tae	= "";
	LET cTransaccSdoFav_tae	= "";
	
-- HOMOLOGACION EDOMEX:
	LET v_transacc_suc_edomex	= "";
	LET cTransaccSdoFav_edomex	= "";
	
--	2013.08.09 FRG-F.

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_codret = sql_err;
            RETURN v_codret,v_moneda,v_monto_cargo,v_monto_firme,
                   v_monto_sbc,v_monto_rem,v_descripcion,v_movto_cargo,
                   v_movto_firme,v_movto_sbc,v_movto_rem WITH RESUME;
        END IF
    END EXCEPTION;
    
	--SET DEBUG FILE TO "/respaldosbd/eduardo/totcomp.out";
	--TRACE ON;
	
    SELECT {+INDEX(bdicheq:"informix".sc_fechas idx_fechas1)} 
           fecha_hoy
      INTO vfecha
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pempresa;
	 
--HOMOLOGACION GDF
	SELECT valor 
	INTO v_transacc_suc
	FROM bdisac:"informix".sac_param 
	WHERE cod_param='87033';
--	2013.08.09 FRG-I.
	SELECT valor 
	INTO cTransaccSdoFav
	FROM bdisac:"informix".sac_param 
	WHERE cod_param='87041';
--	2013.08.09 FRG-F.

--HOMOLOGACION CLUB DE PROTECCION:
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc_cp
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 80;
	-- 2014.09.02 RGLL
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav_cp
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 81;
	-- 2014.09.02 RGLL
	
	--HOMOLOGACION TIEMPO AIRE ELECTRONICO:
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc_tae
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 20;
	
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav_tae
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 22;
	-- 2015-01-21 
		
	--HOMOLOGACION EDOMEX:
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc_edomex
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 23;
	
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav_edomex
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 24;
	-- 2015-02-18
	
    FOREACH
        SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia4a)} pr.divisa, 
               NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN 1 END),0), 
               NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN md.en_sbc END),0), 
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" THEN 1 END),0), 
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" THEN (md.monto_tot - md.en_sbc) END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" THEN 1 END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" THEN md.monto_tot END),0),
               (SELECT descripcion FROM bdinteg:"informix".si_divisas WHERE pr.divisa = divisa  AND empresa = pempresa)
          INTO v_moneda,
               v_movto_sbc,
               v_monto_sbc,
               v_movto_firme,
               v_monto_firme,
               v_movto_cargo,
               v_monto_cargo,
               v_descripcion 
          FROM bdicheq:"informix".sc_movdia md,
               bdicheq:"informix".sc_maechq mc,
               bdicheq:"informix".sc_producto pr,
               bdinteg:"informix".si_transacc tr
         WHERE md.empresa = pempresa 
           AND md.usuario = pusuario 
           AND md.cancelad <> "S" 
           AND (md.en_sbc > 0 OR md.monto_tot <> md.en_sbc) 
           AND md.fech_alt = vfecha
           AND md.sucursal = psucursal
           AND mc.empresa = md.empresa 
           AND mc.cuenta = md.cuenta 
           AND pr.empresa = md.empresa 
           AND pr.producto = md.producto 
           AND tr.empresa = md.empresa 
           AND tr.numero = md.transacc 
           AND tr.naturaleza IN ("A","C") 
           AND tr.realizada_por = "1"
		   AND tr.sistema = "01"	
--HOMOLOGACION MTY
           AND tr.numero NOT IN('0342', '0343', '0340', '0345', '0247')		   
         GROUP BY pr.divisa
                
            --Se agrega Transfer
				SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia4a)}
               NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN 1 END),0), 
               NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN md.en_sbc END),0), 
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" THEN 1 END),0), 
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" THEN (md.monto_tot - md.en_sbc) END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" THEN 1 END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" THEN md.monto_tot END),0)
         INTO v_movto_sbc_tf,
               v_monto_sbc_tf,
               v_movto_firme_tf,
               v_monto_firme_tf,
               v_movto_cargo_tf,
               v_monto_cargo_tf
          FROM bdicheq:"informix".sc_movdia md,
               bditransfer:"informix".tf_maecte mc,
               bdicheq:"informix".sc_producto pr,
               bdinteg:"informix".si_transacc tr
         WHERE md.empresa = pempresa 
           AND md.usuario = pusuario 
           AND md.cancelad <> "S" 
           AND (md.en_sbc > 0 OR md.monto_tot <> md.en_sbc) 
           AND md.fech_alt = vfecha
           AND md.sucursal = psucursal
           AND mc.empresa = md.empresa 
           AND mc.cuenta_tf = md.cuenta 
           AND pr.empresa = md.empresa 
           AND pr.producto = md.producto 
           AND tr.empresa = md.empresa 
           AND tr.numero = md.transacc 
           AND tr.naturaleza IN ("A","C") 
           AND tr.realizada_por = "1" 
           AND pr.divisa = v_moneda
		   AND tr.sistema = "01"
--HOMOLOGACION MTY
           AND tr.numero NOT IN('0342', '0343', '0340', '0345', '0247');	   
		--Union de Datos
                 LET v_movto_sbc = v_movto_sbc + v_movto_sbc_tf;
                 LET v_monto_sbc = v_monto_sbc + v_monto_sbc_tf;
                 LET v_movto_firme = v_movto_firme + v_movto_firme_tf;
                 LET v_monto_firme= v_monto_firme + v_monto_firme_tf;
                 LET v_movto_cargo = v_movto_cargo + v_movto_cargo_tf ;
                 LET v_monto_cargo= v_monto_cargo + v_monto_cargo_tf;
     
		 --HOMOLOGACION GDF
			 SELECT 
			NVL(SUM( monto), 0),
			NVL(SUM(CASE WHEN monto <> '0' THEN 1 END), 0)
			INTO v_monto_cargo_cred,
				 v_movto_cargo_cred
			FROM bdicred:"informix".sd_movdia a
			WHERE usuario = pusuario
			AND sucursal = psucursal
--	2013.08.09 FRG-I.
			--	AND transacc_suc = v_transacc_suc
			AND transacc_suc in (v_transacc_suc, cTransaccSdoFav, v_transacc_suc_cp, cTransaccSdoFav_cp,v_transacc_suc_tae,cTransaccSdoFav_tae,v_transacc_suc_edomex,cTransaccSdoFav_edomex)
--	2013.08.09 FRG-F.
			AND reversado <> "S"
			AND fecha_mov = vfecha
			AND empresa = pempresa
			AND divisa = v_moneda;

        RETURN v_codret,v_moneda,v_monto_cargo + v_monto_cargo_cred,v_monto_firme,
               v_monto_sbc,v_monto_rem,v_descripcion,v_movto_cargo + v_movto_cargo_cred,
               v_movto_firme,v_movto_sbc,v_movto_rem WITH RESUME;
    END FOREACH;
    
    END
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica procedimiento para obtener la sumatoria del monto en la tabla sd_movdia y sumarselo a monto de sc_movdia',
'MODIFICO: Eduardo López',
'FECHA : 08/Marzo/2013',
'Ver.  : 1.1',
'DESCRIPCION: Se modifica procedimiento para incluir las transacciones del club de proteccion coppel',
'MODIFICO: Rigoberto Gonzalez Llanes',
'FECHA : 02/Septiembre/2014',
'Ver.  : 1.2',
'BD    : bdicheq',
'Fecha: 20/10/2014',
'Se modifica procedimientp para obtener la sumatoria de los depositos y retiro de cuentas Transfer',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 21/01/2014',
'Ver.  : 1.3',
'BD    : bdicheq',
'Se modifica procedimientp para obtener la transaccón de TAE',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 18/02/2014',
'Ver.  : 1.4',
'BD    : bdicheq',
'Se modifica procedimientp para incluir la cuenta de credito de pagos EDOMEX',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 18/03/2015',
'Ver.  : 1.5',
'BD    : bdicheq',
'Se modifica procedimiento para homologar la cuenta de credito de la transaccón de EDOMEX y TAE, para saldo a favor.';

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