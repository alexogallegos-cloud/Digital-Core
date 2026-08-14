CREATE PROCEDURE "informix".sp_consulta_pagos_recibidos_general(pEmpresa CHAR(3),
                                                                pNumcred CHAR(20))
RETURNING
          CHAR(6)       AS resultado,
          CHAR(80)      AS mensaje,
          CHAR(20)      AS numero_credito,
          DATE          AS fecha_movimiento,
          DECIMAL(18,2) AS capital_vigente,
          DECIMAL(18,2) AS capital_vencido,
          DECIMAL(18,2) AS interes_vigente,
          DECIMAL(18,2) AS iva_interes_vigente,
          DECIMAL(18,2) AS interes_orden_abono,
          DECIMAL(18,2) AS iva_orden_abono,
          DECIMAL(18,2) AS interes_mora,
          DECIMAL(18,2) AS iva_mora,
          DECIMAL(18,2) AS total_pagado,
          CHAR(16)      AS folio_sucursal;
		  
--Autor: Roque Enrique Solis C.
-- Fecha: 06/10/2009
-- Modificacion: Se agrego la consulta para prestamos personales

--Autor: Roque Enrique Solis C.
-- Fecha: 01/18/2010
-- Modificacion: Se quito la disminucion de los canceptos dIvaMora y dInteresVigente dentro de prestamos personales.

DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6);
DEFINE cMensajeRet           CHAR(80);
DEFINE iRegistros            INTEGER;

DEFINE cNumCred              CHAR(20);
DEFINE cNumProd              CHAR(4);
DEFINE dFechaMov             DATE;
DEFINE cFolioSuc             CHAR(16);
DEFINE dCapitalVigente       DECIMAL(18,2);
DEFINE dCapitalVencido       DECIMAL(18,2);
DEFINE dInteresOrdenAbono    DECIMAL(18,2);
DEFINE dIvaOrdenAbono        DECIMAL(18,2);
DEFINE dInteresMora          DECIMAL(18,2);
DEFINE dIvaMora              DECIMAL(18,2);
DEFINE dInteresVigente       DECIMAL(18,2);
DEFINE dIvaInteresVigente    DECIMAL(18,2);
DEFINE dTotalPago            DECIMAL(18,2);
DEFINE cTipCred              CHAR(2);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet, cNumCred, dFechaMov, dCapitalVigente,
             dCapitalVencido, dInteresVigente, dIvaInteresVigente, dInteresOrdenAbono,
             dIvaOrdenAbono, dInteresMora, dIvaMora, dTotalPago, cFolioSuc;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


--SET DEBUG FILE TO '/tmp/resc/sp_consulta_pagos_recibidos_general.out';
--TRACE ON;

--Fecha: 29/06/2009
--Modificacion: Se optimizo la consulta de la movdia
--Autor: Roque Enrique Solis C.

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = '';
LET cCodRet                  = '000000';
LET cMensajeRet              = 'Se realizo la consulta correctamente';
LET iRegistros               = 0;

LET cNumCred                 = '';
LET cNumProd                 = '';
LET dFechaMov                = DATE(0);
LET cFolioSuc                = '';
LET dCapitalVigente          = 0;
LET dCapitalVencido          = 0;
LET dInteresOrdenAbono       = 0;
LET dIvaOrdenAbono           = 0;
LET dInteresMora             = 0;
LET dIvaMora                 = 0;
LET dInteresVigente          = 0;
LET dIvaInteresVigente       = 0;
LET dTotalPago               = 0;
LET cTipCred                 = 0;

LET pEmpresa = NVL(pEmpresa,'');
LET pNumcred = NVL(pNumcred,'');

IF pEmpresa = '' OR pNumcred = '' THEN
    LET cCodRet     = '000001';
    LET cMensajeRet = "Faltan parametros para ejecucion";
    RETURN cCodRet, cMensajeRet, NVL(cNumCred,''), NVL(dFechaMov,DATE(1)), NVL(dCapitalVigente,0),
           NVL(dCapitalVencido,0), NVL(dInteresVigente,0), NVL(dIvaInteresVigente,0), NVL(dInteresOrdenAbono,0),
           NVL(dIvaOrdenAbono,0), NVL(dInteresMora,0), NVL(dIvaMora,0), NVL(dTotalPago,0), NVL(cFolioSuc,'');
END IF;
 
   SELECT a.num_producto, cod_tipcred
     INTO cNumProd, cTipCred
     FROM "informix".sd_maecred a, "informix".sd_definicion b
    WHERE num_credito=pNumcred
	  AND a.num_producto= b.num_producto;
 
 IF cNumProd IS NOT NULL THEN
		
		-- AAME RQM 10 679 Se modificar para contemplar las cuentas contables para TDC Oro
		FOREACH
		    SELECT a.num_credito,
		           fecha_mov,
		           folio_suc,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13110101010032','13110103010032','13110104010032','13110105010032',--No contempla grupo coppel
				                                                                                                                         '13120101010132','13120101030132','13120101040132','13120101050132',--13120101060132 nva, GC , E1 No exigible		
																																		 '13120101060132','13120103010132','13120101120132') OR   		     --E1 No exigible RISTRAS NUEVAS TDC INFINITE                                                                                                                   
					  TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('24029014000032','24029018000032','24029022000032') THEN -- RQM 10 679 Esta cuenta no viene definida para TDC Oro // Saldo a Favor
					  monto ELSE 0 END) capital_vigente,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13110101030032','13110103030032','13110104030032','13110105030032', --capital_transitorio 
				                                                                                                                         '13120101010332','13120101030332','13120101050332','13120101040332', --E1 Exigible  (13120101060332 GC)	
																																		 '13120101060332','13120103010332','13120101120332') OR 			  --E1 Exigible RISTRAS NUEVAS TDC INFINITE
					  TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)  in ('13610101010132', '13610103010132','13610104010132','13610105010132', 		  --capital_exigible
					                                                                                                           '13120201010332','13120201030332','13120201050332','13120201040332',  		  --capital_exigible_e2  ('13120201060332' GC)
																															   '13120201060332','13120203010332','13120201120332',							  --capital_exigible_e2 RISTRAS NUEVAS TDC INFINITE
					                                                                                                           '13120301010332','13120301030332','13120301050332','13120301040332',			  --capital_exigible_e3--(,'13120301060332' GC)
																															   '13120301060332','13120303010332','13120301120332') or  						  --capital_exigible_e3 RISTRAS NUEVAS TDC INFINITE
					  TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13610101010232','13610103010232','13610104010232','13610105010232', 			  --capital_no_exigible 
					                                                                                                          '13120201010132','13120201030132','13120201050132','13120201040132', 			  --capital_noexigible_e2   '13120201060132' GC
																															  '13120201060132','13120203010132','13120201120132',			                  --capital_noexigible_e2 RISTRAS NUEVAS TDC INFINITE
					                                                                                                          '13120301010132','13120301030132','13120301050132','13120301040132',			  --capital_noexigible_e3 ,'13120301060132'  GC)
																															  '13120301060132','13120303010132','13120301120132') THEN  	  				  --capital_noexigible_e3 RISTRAS NUEVAS TDC INFINITE
					  monto ELSE 0 END) capital_vencido,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('51056101010132', '51056101030132','51056101040132','51056101050132') or
								 TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13120101010232','13120101030232','13120101050232','13120101040232','13120101060232','13120103010232','13120101120232') or --interes_vigente_abono_e1
					             TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13120201010232','13120201030232','13120201050232','13120201040232','13120201060232','13120201120232' ) or 				--interes_vigente_abono_e2
								 TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13120301010232','13120303010432','13120301120432') THEN 																	--interes_vigente_abono_e3	    
					   monto ELSE 0 END) interes_vigente,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('77106101010132','77106101030132','77106101040132','77106101050132',
																																		 '77106101060132','77106103010132','77106101120132') THEN
					  monto ELSE 0 END) interes_ORDEN_abono,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('78376101010132','78376101030132','78376101040132','78376101050332',
																																		 '14020305110132','14020305110532','14020305111032','14020305110932','14020305111532','14020305111332',
																																		 '78376101060132','78376103010132','78376101120132') THEN
					   monto ELSE 0 END) IVA_ORDEN_abono,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('77106101010232','77106101030232','77106101040232','77106101050232') THEN
					   monto ELSE 0 END) interes_mora,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('24020804010111','24020804010411','24020804010611')  THEN  --RQM 10 679 Misma cuenta contable de 6001 para 8100
					   monto ELSE 0 END) IVA_Omora
		      INTO cNumCred, dFechaMov, cFolioSuc, dCapitalVigente, dCapitalVencido, dInteresVigente, dInteresOrdenAbono, dIvaOrdenAbono, dInteresMora, dIvaMora
		      FROM bdicred:"informix".sd_movhis a
		      LEFT OUTER JOIN bdicred:"informix".sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
		      LEFT OUTER JOIN bdinteg:"informix".si_transacc c ON (b.empresa = c.empresa AND b.transacc_ifrs = c.numero and c.sistema ='06')
		      LEFT OUTER JOIN bdinteg:"informix".si_prodtran d ON (b.empresa = d.empresa AND b.transacc_ifrs = d.transaccion and d.producto=a.num_producto)
		     WHERE a.empresa       = pEmpresa
		       AND num_credito     = pNumcred
		       AND reversado       = 'N'
		       AND se_contabiliza  ='S'
		       AND a.codigo_fun in (select {+INDEX(sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:"informix".sd_conceptospagomanual)
		       AND TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector)  not in ('13110101010032','13110103010032','13110104010032','13110105010032',
		                                                                                                                        '13120101010132','13120101030132','13120101040132','13120101050132',
																																'13120101060132','13120103010132','13120101120132', 					--E1 No exigible																																
																																'13120101010332','13120101030332','13120101050332','13120101040332',
																																'13120101060332','13120103010332','13120101120332',						--E1 Exigible
																																'13120201010332','13120201030332','13120201050332','13120201040332',
																																'13120201060332','13120203010332','13120201120332',						--capital_exigible_e2 
																																'13120301010332','13120301030332','13120301050332','13120301040332',
																																'13120301060332','13120303010332','13120301120332',    				    --capital_exigible_e3
																																'13120201010132','13120201030132','13120201050132','13120201040132',
																																'13120201060132','13120203010132','13120201120132',                     --capital_no_exigible_e2
																																'13120301010132','13120301030132','13120301050132','13120301040132',
																																'13120301060132','13120303010132','13120301120132') --capital_no_exigible_e3 ---> Agregar las de capitales exigibles y no exigibles
		     GROUP BY 1,2,3
		UNION ALL
		    SELECT a.num_credito,
		           fecha_mov,
		           folio_suc,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13110101010032','13110103010032','13110104010032','13110105010032',
				                                                                                                                         '13120101010132','13120101030132','13120101040132','13120101050132',
																																		 '13120101060132','13120103010132','13120101120132') OR
					  TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('24029014000032','24029018000032','24029022000032') THEN -- RQM 10 679 Esta cuenta no viene definida para TDC Oro
					  monto ELSE 0 END) capital_vigente,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13110101030032','13110103030032','13110104030032','13110105030032',
				                                                                                                                         '13120101010332','13120101030332','13120101050332','13120101040332',
																																		 '13120101060332','13120103010332','13120101120332') OR
					  TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)  in ('13610101010132', '13610103010132','13610104010132','13610105010132',
					                                                                                                           '13120201010332','13120201030332','13120201050332','13120201040332',    --capital_exigible_e2  ('13120201060332' GC)
																															   '13120201060332','13120203010332','13120201120332',
					                                                                                                           '13120301010332','13120301030332','13120301050332','13120301040332',
																															   '13120301060332','13120303010332','13120301120332') or
					  TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13610101010232','13610103010232','13610104010232','13610105010232',
					                                                                                                          '13120201010132','13120201030132','13120201050132','13120201040132',
																															  '13120201060132','13120203010132','13120201120132',-- capital_noexigible_e2   '13120201060132' GC
					                                                                                                          '13120301010132','13120301030132','13120301050132','13120301040132',
																															  '13120301060132','13120303010132','13120301120132') THEN
					  monto ELSE 0 END) capital_vencido,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('51056101010132', '51056101030132','51056101040132','51056101050132') or
								 TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13120101010232','13120101030232','13120101050232','13120101040232','13120101060232','13120103010232','13120101120232') or --interes_vigente_abono_e1
					             TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13120201010232','13120201030232','13120201050232','13120201040232','13120201060232','13120201120232' ) or 				--interes_vigente_abono_e2
								 TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13120301010232','13120303010432','13120301120432')				   THEN
					   monto ELSE 0 END) interes_vigente,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('77106101010132','77106101030132','77106101040132','77106101050132',
																																		 '77106101060132','77106103010132','77106101120132') THEN
					  monto ELSE 0 END) interes_ORDEN_abono,																			 
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('78376101010132','78376101030132','78376101050132','78376101040132','78376101050332',
																																	     '78376101060132','78376103010132','78376101120132') THEN
					   monto ELSE 0 END) IVA_ORDEN_abono,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('77106101010232','77106101030232','77106101040232','77106101050232') THEN
					   monto ELSE 0 END) interes_mora,
				   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('24020804010111','24020804010411','24020804010611')  THEN  --RQM 10 679 Misma cuenta contable de 6001 para 8100
					   monto ELSE 0 END) IVA_Omora
		      FROM bdicred:"informix".sd_movdia a
		      LEFT OUTER JOIN bdicred:"informix".sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
		      LEFT OUTER JOIN bdinteg:"informix".si_transacc c ON (a.empresa = c.empresa AND b.transacc_ifrs = c.numero AND c.se_contabiliza  ='S' and c.sistema ='06')
		      LEFT OUTER JOIN bdinteg:"informix".si_prodtran d ON (a.empresa = d.empresa AND b.transacc_ifrs = d.transaccion and d.producto=a.num_producto)
		     WHERE a.empresa         = pEmpresa
		       AND a.num_credito     = pNumcred
		       AND a.reversado       = 'N'
		       AND a.codigo_fun in (select {+INDEX(sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:"informix".sd_conceptospagomanual)
		       AND TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) not in ('13110101010032','13110103010032','13110104010032','13110105010032',
		                                                                                                                        '13120101010132','13120101030132','13120101040132','13120101050132',
																																'13120101060132','13120103010132','13120101120132', 					--E1 No exigible																																
																																'13120101010332','13120101030332','13120101050332','13120101040332',
																																'13120101060332','13120103010332','13120101120332',						--E1 Exigible
																																'13120201010332','13120201030332','13120201050332','13120201040332',
																																'13120201060332','13120203010332','13120201120332',						--capital_exigible_e2 
																																'13120301010332','13120301030332','13120301050332','13120301040332',
																																'13120301060332','13120303010332','13120301120332',  					--capital_exigible_e3
																																'13120201010132','13120201030132','13120201050132','13120201040132',
																																'13120201060132','13120203010132','13120201120132',                     --capital_no_exigible_e2
																																'13120301010132','13120301030132','13120301050132','13120301040132',
																																'13120301060132','13120303010132','13120301120132') --capital_no_exigible_e3 ---> Agregar las de capitales exigibles y no exigibles
		  GROUP BY 1,2,3
		  ORDER BY fecha_mov DESC

		    LET dIvaMora = dIvaMora - dIvaOrdenAbono;
		    LET dInteresVigente = dInteresVigente - dInteresOrdenAbono;
		    LET dTotalPago =dCapitalVigente + dCapitalVencido + dInteresVigente + dIvaInteresVigente + dInteresOrdenAbono + dIvaOrdenAbono + dInteresMora + dIvaMora;

		    RETURN cCodRet, cMensajeRet, NVL(cNumCred,''), NVL(dFechaMov,DATE(1)), NVL(dCapitalVigente,0),
		           NVL(dCapitalVencido,0), NVL(dInteresVigente,0), NVL(dIvaInteresVigente,0), NVL(dInteresOrdenAbono,0),
		           NVL(dIvaOrdenAbono,0), NVL(dInteresMora,0), NVL(dIvaMora,0), NVL(dTotalPago,0), NVL(cFolioSuc,'') WITH RESUME;

		END FOREACH;
		LET iRegistros = DBINFO("sqlca.sqlerrd2");
ELSE
    
   SELECT a.num_producto, cod_tipcred
     INTO cNumProd, cTipCred
     FROM "informix".sd_maecredcrd a, "informix".sd_definicion b
    WHERE num_credito=pNumcred
	  AND a.num_producto= b.num_producto;
		
        IF cTipCred ='05' THEN
		    FOREACH
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700) y sus cuentas contables 
				SELECT a.num_credito,
                       fecha_mov,
                       folio_suc,
                   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in ('13110202010032','13110203010032','13110205010032','13110206010032','13110208010032','13110501010032','13110209010032',      
                                                                                                                                        '13120102020132','13120102080132','13120102030132','13120102050132','13120102060132','13120102090132',  --capital_no_exigible_e1
																																		'13120202020132','13120202080132','13120202030132','13120202050132','13120202060132','13120202090132', --capital_no_exigible_e2
																																		'13120302020132','13120302080132','13120302030132','13120302050132','13120302060132','13120302090132')  THEN --capital_noexigible_e3 --Agregar los no exig de e2 y e3
                          monto ELSE 0 END) capital_vigente,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in('13110202030032','13110203030032','13110205030032','13110206030032','13110208030032','13110501030032', '13110209030032',
                                                                                                                                            '13120102020332','13120102080332','13120102030332','13120102050332','13120102060332','13120102090332'  ) OR  --capital_exigible_e1
                          TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in('13610202010132','13610203010132','13610205010132','13610206010132','13610208010132','13610501010132','13610209010132',
                                                                                                                                 '13120202020332','13120202080332','13120202030332','13120202050332','13120202060332','13120202090332', --capital_exigible_e2
                                                                                                                                 '13120302020332','13120302080332','13120302030332','13120302050332','13120302060332','13120302090332') THEN  --capital_exigible_e3
                          monto ELSE 0 END) capital_vencido,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in('13110202020032','13110203020032','13110205020032','13110206020032','13110208020032','13110501020032','13110209020032',
                                                                                                                                           '13120102020232','13120102080232','13120102030232','13120102050232','13120102060232','13120102090232',  --interes_vigente_e1
                                                                                                                                            '13120202020232','13120202080232','13120202030232','13120202050232','13120202060232','13120202090232') THEN  --interes_vigente_e2
                           monto ELSE 0 END) interes_vigente,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in('14020305110232','14020305110332','14020305111432','14020305111632') AND a.codigo_ref in (8,9)  THEN
                           monto ELSE 0 END) iva_interes_vigente,
                        SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13610202020132','51056102020132','13610203020132','51056102030132','13110205040032','13110206040032','13110208020032','13110501020032','13110209020032','51056102080132','51056102090132','51056105010132') THEN	-- 6800,9300,9100
                           monto ELSE 0 END) interes_ORDEN_abono,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('14020305110232','24020804010211','14020305110332','24020804030311','14020305111432','14020305111632','24020804010911','24020804011111') AND a.codigo_ref in (10,11,12,13,18,19) THEN
                           monto ELSE 0 END) IVA_ORDEN_abono,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in('77106102020232', '77106102030232','77106102050232','77106102060232','77106102080232','77106105010232','77106102090232')  THEN   -- 9100 , 9300, 6800
                           monto ELSE 0 END) interes_mora,                                                                                  
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in('24020804010211','24020804030311','24020804010911','24020804011111')  AND a.codigo_ref not in (10,11,12,13,18,19) THEN --6800,9100  
                           monto ELSE 0 END) IVA_Omora
			      INTO cNumCred, dFechaMov, cFolioSuc, dCapitalVigente, dCapitalVencido, dInteresVigente,dIvaInteresVigente, dInteresOrdenAbono, dIvaOrdenAbono, dInteresMora, dIvaMora
			      FROM bdicred:"informix".sd_movhiscrd a
			      LEFT OUTER JOIN bdicred:"informix".sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			      LEFT OUTER JOIN bdinteg:"informix".si_transacc c ON (b.empresa = c.empresa AND b.transacc_ifrs = c.numero and c.sistema ='06')
			      LEFT OUTER JOIN bdinteg:"informix".si_prodtran d ON (b.empresa = d.empresa AND b.transacc_ifrs = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa       = pEmpresa
			       AND num_credito     = pNumcred
			       AND reversado       = 'N'
			       AND se_contabiliza  ='S'
                   AND a.codigo_fun in (select cod_fun from bdicred:"informix".sd_conceptospagomanualcrd where num_producto IN ('6300','7600','7700','6800','9100','9300'))
--			       AND a.codigo_fun in ('020', '021', '022', '023','024','025')
			       AND TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) not in ('13110202010032','13110203010032','13110208010032','13110501010032','13110209010032',
			                                                                                                                       '13120102020132','13120102080132','13120102030132','13120102050132','13120102060132','13120102090132',  --capital_no_exigible_e1
																																	'13120202020132','13120202080132','13120202030132','13120202050132','13120202060132','13120202090132', --capital_no_exigible_e2
																																	'13120302020132','13120302080132','13120302030132','13120302050132','13120302060132','13120302090132')  --capital_no_exigible_e3
			     GROUP BY 1,2,3
			     UNION ALL 
				SELECT a.num_credito,
                       fecha_mov,
                       folio_suc,
                   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in ('13110202010032','13110203010032','13110205010032','13110206010032','13110208010032','13110501010032','13110209010032',
                                                                                                                                       '13120102020132','13120102080132','13120102030132','13120102050132','13120102060132','13120102090132',  --capital_no_exigible_e1
																																	'13120202020132','13120202080132','13120202030132','13120202050132','13120202060132','13120202090132', --capital_no_exigible_e2
																																	'13120302020132','13120302080132','13120302030132','13120302050132','13120302060132','13120302090132')  THEN--capital_no_exigible_e3
                          monto ELSE 0 END) capital_vigente,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in('13110202030032','13110203030032','13110205030032','13110206030032','13110208030032','13110501030032', '13110209030032',
                                                                                                                                           '13120102020332','13120102080332','13120102030332','13120102050332','13120102060332','13120102090332'  ) OR
                          TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in('13610202010132','13610203010132','13610205010132','13610206010132','13610208010132','13610501010132','13610209010132',
                                                                                                                                 '13120202020332','13120202080332','13120202030332','13120202050332','13120202060332','13120202090332', --capital_exigible_e2
                                                                                                                                 '13120302020332','13120302080332','13120302030332','13120302050332','13120302060332','13120302090332') THEN
                          monto ELSE 0 END) capital_vencido,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in('13110202020032','13110203020032','13110205020032','13110206020032','13110208020032','13110501020032','13110209020032',
                                                                                                                                            '13120102020232','13120102080232','13120102030232','13120102050232','13120102060232','13120102090232',  --interes_vigente_e1
                                                                                                                                            '13120202020232','13120202080232','13120202030232','13120202050232','13120202060232','13120202090232') THEN
                           monto ELSE 0 END) interes_vigente,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in('14020305110232','14020305110332','14020305111432','14020305111632') AND a.codigo_ref in (8,9)  THEN
                           monto ELSE 0 END) iva_interes_vigente,
                        SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('13610202020132','51056102020132','13610203020132','51056102030132','13110205040032','13110206040032','13110208020032','13110501020032','13110209020032','51056102080132','51056102090132','51056105010132') THEN	-- 6800,9300,9100
                           monto ELSE 0 END) interes_ORDEN_abono,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ('14020305110232','24020804010211','14020305110332','24020804030311','14020305111432','14020305111632','24020804010911','24020804011111') AND a.codigo_ref in (10,11,12,13,18,19) THEN
                           monto ELSE 0 END) IVA_ORDEN_abono,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in('77106102020232', '77106102030232','77106102050232','77106102060232','77106102080232','77106105010232','77106102090232')  THEN   -- 9100 , 9300, 6800
                           monto ELSE 0 END) interes_mora,
                       SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in('24020804010211','24020804030311','24020804010911','24020804011111')  AND a.codigo_ref not in (10,11,12,13,18,19) THEN --6800,9100  
                           monto ELSE 0 END) IVA_Omora
			      FROM bdicred:"informix".sd_movdiacrd a
			      LEFT OUTER JOIN bdicred:"informix".sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			      LEFT OUTER JOIN bdinteg:"informix".si_transacc c ON (a.empresa = c.empresa AND b.transacc_ifrs = c.numero AND c.se_contabiliza  ='S' and c.sistema ='06')
			      LEFT OUTER JOIN bdinteg:"informix".si_prodtran d ON (a.empresa = d.empresa AND b.transacc_ifrs = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa         = pEmpresa
			       AND a.num_credito     = pNumcred
			       AND a.reversado       = 'N'
                   AND a.codigo_fun in (select cod_fun from bdicred:"informix".sd_conceptospagomanualcrd where num_producto IN ('6300','7600','7700','6800','9100','9300'))
--			       AND a.codigo_fun in ('020', '021', '022', '023','024','025')
			       AND TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) not in ('13110202010032','13110203010032','13110208010032','13110501010032','13110209010032',
																																	'13120102020132','13120102080132','13120102030132','13120102050132','13120102060132','13120102090132',  --capital_no_exigible_e1
																																	'13120202020132','13120202080132','13120202030132','13120202050132','13120202060132','13120202090132', --capital_no_exigible_e2
																																	'13120302020132','13120302080132','13120302030132','13120302050132','13120302060132','13120302090132')
			  GROUP BY 1,2,3
			  ORDER BY fecha_mov DESC

		    --LET dIvaMora = dIvaMora - dIvaOrdenAbono;
		    --LET dInteresVigente = dInteresVigente - dInteresOrdenAbono;
		    LET dTotalPago = dCapitalVigente + dCapitalVencido + dInteresVigente + dIvaInteresVigente + dInteresOrdenAbono + dIvaOrdenAbono + dInteresMora + dIvaMora;

		    RETURN cCodRet, cMensajeRet, NVL(cNumCred,''), NVL(dFechaMov,DATE(1)), NVL(dCapitalVigente,0),
		           NVL(dCapitalVencido,0), NVL(dInteresVigente,0), NVL(dIvaInteresVigente,0), NVL(dInteresOrdenAbono,0),
		           NVL(dIvaOrdenAbono,0), NVL(dInteresMora,0), NVL(dIvaMora,0), NVL(dTotalPago,0), NVL(cFolioSuc,'') WITH RESUME;

		END FOREACH;
		LET iRegistros = DBINFO("sqlca.sqlerrd2");
	END IF;

        IF cTipCred ='03' THEN
		    FOREACH
			    SELECT a.num_credito,
			           fecha_mov,
			           folio_suc,
			           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in ( '13110102010032','13120101020132','13120201020132','13120301020132') THEN  --no exig de 1 2 3 
			              monto ELSE 0 END) capital_vigente,
			           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in ('13110102030032','13120101020332') OR --Exig 1
			              TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ( '13610102010132','13610102010232' ,  --Exig 2,3
			                                                                                                                        '13120201020332','13120301020332' )  THEN
			              monto ELSE 0 END) capital_vencido,
			           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in ('13110102020032','13120101020232','13120201020232') THEN
			               monto ELSE 0 END) interes_vigente,
					   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '14020305110432' THEN 
					       monto ELSE 0 END) iva_interes_vigente,
			           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '51056101020132' THEN 
					       monto ELSE 0 END) interes_ORDEN_abono,
			           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '24020804010332' THEN 
					       monto ELSE 0 END) IVA_ORDEN_abono--,
			         --  SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '77106102020232'  THEN
			         --      monto ELSE 0 END) interes_mora,
			         --  SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '24020804010211'  THEN
			          --     monto ELSE 0 END) IVA_Omora
			      INTO cNumCred, dFechaMov, cFolioSuc, dCapitalVigente, dCapitalVencido, dInteresVigente,dIvaInteresVigente, dInteresOrdenAbono, dIvaOrdenAbono--, dInteresMora, dIvaMora
			      FROM bdicred:"informix".sd_movhiscrd a
			      LEFT OUTER JOIN bdicred:"informix".sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			      LEFT OUTER JOIN bdinteg:"informix".si_transacc c ON (b.empresa = c.empresa AND b.transacc = c.numero and c.sistema ='06')
			      LEFT OUTER JOIN bdinteg:"informix".si_prodtran d ON (b.empresa = d.empresa AND b.transacc = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa       = pEmpresa
			       AND num_credito     = pNumcred
			       AND reversado       = 'N'
			       AND se_contabiliza  ='S'
                   AND a.codigo_fun in (select cod_fun from bdicred:"informix".sd_conceptospagomanualcrd where num_producto = '6011')
			      -- AND TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) <> '13110202010032'
			     GROUP BY 1,2,3
			     UNION ALL 
			    SELECT a.num_credito,
			           fecha_mov,
			           folio_suc,
			           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in ( '13110102010032','13120201020132','13120201020132','13120301020132') THEN
			              monto ELSE 0 END) capital_vigente,
			           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in ('13110102030032','13120101020332') OR
			              TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) in ( '13610102010132','13610102010232' ,
			                                                                                                                        '13120201020332','13120301020332' )  THEN
			              monto ELSE 0 END) capital_vencido,
			           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)in ('13110102020032','13120101020232','13120201020232')THEN
			               monto ELSE 0 END) interes_vigente,
					   SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '14020305110432' THEN 
					       monto ELSE 0 END) iva_interes_vigente,
			           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '51056101020132' THEN 
					       monto ELSE 0 END) interes_ORDEN_abono,
			           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '24020804010332' THEN 
					       monto ELSE 0 END) IVA_ORDEN_abono--,
			     --      SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '77106102020232'  THEN
			     --          monto ELSE 0 END) interes_mora,
			     --      SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '24020804010211'  THEN
			     --          monto ELSE 0 END) IVA_Omora
			      FROM bdicred:"informix".sd_movdiacrd a
			      LEFT OUTER JOIN bdicred:"informix".sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			      LEFT OUTER JOIN bdinteg:"informix".si_transacc c ON (a.empresa = c.empresa AND b.transacc_ifrs = c.numero AND c.se_contabiliza  ='S' and c.sistema ='06')
			      LEFT OUTER JOIN bdinteg:"informix".si_prodtran d ON (a.empresa = d.empresa AND b.transacc_ifrs = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa         = pEmpresa
			       AND a.num_credito     = pNumcred
			       AND a.reversado       = 'N'
                   AND a.codigo_fun in (select cod_fun from bdicred:"informix".sd_conceptospagomanualcrd where num_producto = '6011')
			     --  AND TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) <> '13110202010032'
			  GROUP BY 1,2,3
			  ORDER BY fecha_mov DESC

              LET dInteresMora=0; LET dIvaMora=0;

		    --LET dIvaMora = dIvaMora - dIvaOrdenAbono;
		    --LET dInteresVigente = dInteresVigente - dInteresOrdenAbono;
		    LET dTotalPago = dCapitalVigente + dCapitalVencido + dInteresVigente + dIvaInteresVigente + dInteresOrdenAbono + dIvaOrdenAbono + dInteresMora + dIvaMora;

		    RETURN cCodRet, cMensajeRet, NVL(cNumCred,''), NVL(dFechaMov,DATE(1)), NVL(dCapitalVigente,0),
		           NVL(dCapitalVencido,0), NVL(dInteresVigente,0), NVL(dIvaInteresVigente,0), NVL(dInteresOrdenAbono,0),
		           NVL(dIvaOrdenAbono,0), NVL(dInteresMora,0), NVL(dIvaMora,0), NVL(dTotalPago,0), NVL(cFolioSuc,'') WITH RESUME;

		END FOREACH;
		LET iRegistros = DBINFO("sqlca.sqlerrd2");
	END IF;
END IF; 
IF iRegistros  = 0 THEN
    LET cCodRet     = '000002';
    LET cMensajeRet = 'NO SE OBTUVIERON RESULTADOS';
 RETURN cCodRet, cMensajeRet, NVL(cNumCred,''), NVL(dFechaMov,DATE(0)), NVL(dCapitalVigente,0),
           NVL(dCapitalVencido,0), NVL(dinteresVigente,0), NVL(dIVAinteresVigente,0), NVL(dinteresOrdenAbono,0),
           NVL(dIVAOrdenAbono,0), NVL(dInteresMora,0), NVL(dIVAMora,0), NVL(dTotalPago,0), NVL(cFolioSuc,'');
END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'La consulta de pagos recibidos general',
'AUTOR : Roque Enrique Solis C.',
'FECHA : 22/JUNIO/2009',
'VALIDACION FUNCIONALIDAD POR: MARCELA PEREZ-GM3',
'VALIDACION FUNCIONALIDAD POR:JUAN OLIVAREZ-GM2',
'FECHA DE MODIFICACION: 26 DE DICIEMBRE DE 2018',
'OBJETIVO:OPTIMIZACION Y AGREGAR INDICES',
'MODIFICADO POR: COPPEL Y PATRICIA DEL RAZO-GM3',
'VoBo POR: ALEJANDRO SANCHEZ-GM1',
'VoBo POR: JUAN OLIVAREZ-GM2',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obt_fec_edo_cta_cred_bpi(pCuenta char(20), pDiasTimbrado integer)
        RETURNING char(5), date;

	-- Realizp: Hector Ramon Moreno Moreno
	-- Actividad: Obtener los ÃÂÃÂºltimos 3 periodos de estado de cuenta activos
	-- Fecha:  16/12/2016

	-- DefiniciÃÂÃÂ³n de variables
       DEFINE vcodret       char(5);
       DEFINE vFechaEmision date;
	   
	   DEFINE vFechaEmision_Hist DATE;
	   DEFINE vFechaTimbrado_Hist DATE;
	   DEFINE iContador_Hist	int;
	   DEFINE vProducto_Hist char(4);
       
	   DEFINE sql_err       integer;
       DEFINE ffin          DATE;
	   DEFINE fini          DATE;
	   DEFINE fechaParam    char(7);
	   DEFINE indicador     char(1);
	   DEFINE fechaActual	DATE;
	   DEFINE iDiaActual	int;
	   DEFINE iMesActual	int;
	   DEFINE iAnioActual   int;
	   DEFINE iMesBloq		int;
	   DEFINE fecha1		DATE;
	   DEFINE fecha2		DATE;
	   DEFINE fecha3		DATE;
	   DEFINE fecha4		DATE;
	   DEFINE vFechaTimbrado DATE;
	   DEFINE fechaServidor	DATE;
	   DEFINE iContador		int;
	   DEFINE vProducto	   char(4);
	   DEFINE vEsQuince	char(4);

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vFechaEmision;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vFechaEmision = '01/01/1900';
let ffin = " ";
LET fini = " ";
LET fechaParam = " ";
LET indicador = " ";
LET iContador = 0;
LET vProducto = "";

LET vEsQuince = 'false';
LET iContador_Hist = 1;
LET vFechaEmision_Hist = '01/01/1900';
LET vProducto_Hist = "";

BEGIN

--SET DEBUG FILE TO "/home/sysifx/hector/sp_obt_fec_edo_cta_cred_bpi.out";
--TRACE ON;

--SET DEBUG FILE TO "/ifxsif01/phlc/incidencia_edo_cta_app/sp_obt_fec_edo_cta_cred_bpi.out";
--TRACE ON;

set isolation to dirty read;
set lock mode to wait 3;

	LET iDiaActual = DAY(current);
	LET iMesActual = MONTH(current);
	LET iAnioActual = YEAR(current);
	
	-------------------------------------
	LET fechaServidor = iMesActual || "/" || iDiaActual || "/" || iAnioActual;
	
	IF iDiaActual < 21 THEN
		if iMesActual == 1 THEN
			LET iMesActual = 12;
			LET iAnioActual = iAnioActual - 1;
		ELSE 
			LET iMesActual = iMesActual - 1;
		END IF;
		
	END IF;

	LET fechaActual = iMesActual || "/20/" || iAnioActual;

	SELECT valor INTO fechaParam FROM bdicred@pld_tcp:sd_param WHERE empresa = '001' AND cod_param = '80';
	LET indicador = SUBSTR(fechaParam,1,1);

	IF indicador = "1" THEN
		LET iMesBloq = SUBSTR(fechaParam,6,2):: int;
		LET fecha1 = fechaActual;
		LET fecha2 = fechaActual - 1 UNITS MONTH;
		LET fecha3 = fechaActual - 2 UNITS MONTH;
		LET fecha4 = fechaActual - 3 UNITS MONTH;

		IF MONTH(fecha1) = iMesBloq THEN
			LET fecha1 = fecha1 - 1 UNITS MONTH;
			LET fecha2 = fecha2 - 1 UNITS MONTH;
			LET fecha3 = fecha3 - 1 UNITS MONTH;
			LET fecha4 = fecha4 - 1 UNITS MONTH;
		ELIF MONTH(fecha2) = iMesBloq THEN
			LET fecha2 = fecha2 - 1 UNITS MONTH;
			LET fecha3 = fecha3 - 1 UNITS MONTH;
			LET fecha4 = fecha4 - 1 UNITS MONTH;
		ELIF MONTH(fecha3) = iMesBloq THEN
			LET fecha3 = fecha3 - 1 UNITS MONTH;
			LET fecha4 = fecha4 - 1 UNITS MONTH;
		ELIF MONTH(fecha4) = iMesBloq THEN
			LET fecha4 = fecha4 - 1 UNITS MONTH;
		END IF;
		
		IF iDiaActual >= 15 OR iDiaActual = 22 THEN
			LET vEsQuince = 'true';
		END IF;

		FOREACH
			SELECT fecha_emision, DATE(fecha_emision + pDiasTimbrado UNITS DAY), num_producto
			INTO vFechaEmision, vFechaTimbrado, vProducto
			FROM bdicred@pld_tcp:sd_encabezado_edocta
			WHERE fecha_emision in (fecha1,fecha2,fecha3,fecha4)
			AND num_credito = pCuenta
			ORDER BY fecha_emision DESC
			
			IF (YEAR(vFechaTimbrado) >= YEAR(vFechaEmision)) AND(MONTH(vFechaTimbrado) >= MONTH(vFechaEmision)) THEN
				IF fechaServidor >= vFechaTimbrado THEN
				
					IF vProducto = "7000" OR vProducto = "8100" OR vProducto = "8500" THEN
						LET vFechaEmision = vFechaEmision - 2 UNITS DAY;
					ELIF vProducto = "5400" THEN --JRVT 12/01/2024
						LET vFechaEmision = vFechaEmision - 1 UNITS DAY;
					END IF;
					
					IF iContador < 3 THEN
						LET iContador = iContador + 1;
						RETURN vcodret, vFechaEmision WITH RESUME;
					END IF;
				END IF;
			ELSE
				IF vProducto = "7000" OR vProducto = "8100" OR vProducto = "8500" THEN					
					LET vFechaEmision = vFechaEmision - 2 UNITS DAY;
				ELIF vProducto = "5400" THEN --JRVT 12/01/2024
						LET vFechaEmision = vFechaEmision - 1 UNITS DAY;
				END IF;
				IF iContador < 3 THEN
					LET iContador = iContador + 1;
					RETURN vcodret, vFechaEmision WITH RESUME;
				END IF;
			END IF;
			
			--------------------LO NUEVO-------------------
			IF vEsQuince = 'true' AND iContador_Hist = 1 AND iContador = 2 THEN
			
				FOREACH			
					SELECT fecha_emision, DATE(fecha_emision + pDiasTimbrado UNITS DAY), num_producto
					INTO vFechaEmision_Hist, vFechaTimbrado_Hist, vProducto_Hist
					FROM bdicred@pld_tcp:sd_encabezado_edocta_hist
					WHERE fecha_emision in (fecha1,fecha2,fecha3,fecha4)
					AND num_credito = pCuenta
					ORDER BY fecha_emision DESC
					
					--IF iContador_Hist = 1 THEN
						IF (YEAR(vFechaTimbrado_Hist) >= YEAR(vFechaEmision_Hist)) AND(MONTH(vFechaTimbrado_Hist) >= MONTH(vFechaEmision_Hist)) THEN
							IF fechaServidor >= vFechaTimbrado_Hist THEN
							
								IF vProducto_Hist = "7000" OR vProducto_Hist = "8100" OR vProducto_Hist = "8500" THEN					
									LET vFechaEmision_Hist = vFechaEmision_Hist - 2 UNITS DAY;
								ELIF vProducto_Hist = "5400" THEN --JRVT 12/01/2024
									LET vFechaEmision_Hist = vFechaEmision_Hist - 1 UNITS DAY;
								END IF;
								
								IF iContador_Hist = 1 THEN
									LET iContador_Hist = iContador_Hist + 1;
									LET vEsQuince = 'false';
									RETURN vcodret, vFechaEmision_Hist WITH RESUME;
								END IF;
							END IF;
						ELSE
							IF vProducto_Hist = "7000" OR vProducto_Hist = "8100" OR vProducto_Hist = "8500" THEN					
								LET vFechaEmision_Hist = vFechaEmision_Hist - 2 UNITS DAY;
							ELIF vProducto_Hist = "5400" THEN --JRVT 12/01/2024
								LET vFechaEmision_Hist = vFechaEmision_Hist - 1 UNITS DAY;
							END IF;
							IF iContador_Hist = 1 THEN
								LET iContador_Hist = iContador_Hist + 1;
								LET vEsQuince = 'false';
								RETURN vcodret, vFechaEmision_Hist WITH RESUME;
							END IF;
						END IF;
					--END IF;
				END FOREACH;
			END IF;
			--------------------------
			
        --IF vAnioMes IS NULL THEN
        --  LET vcodret = '100';
          --RETURN vcodret, vAnioMes, vFechaIni, vFechaFin;
        --END IF;

			--RETURN vcodret, vFechaEmision WITH RESUME;
		END FOREACH;

	ELSE
--		LET fini =  fechaActual - 2 UNITS MONTH;
		LET fecha1 = fechaActual;
		LET fecha2 = fechaActual - 1 UNITS MONTH;
		LET fecha3 = fechaActual - 2 UNITS MONTH;      
		LET fecha4 = fechaActual - 3 UNITS MONTH;
		
		IF iDiaActual >= 15 OR iDiaActual = 22 THEN
			LET vEsQuince = 'true';
		END IF;

		FOREACH
			SELECT fecha_emision, DATE(fecha_emision + pDiasTimbrado UNITS DAY), num_producto
			INTO vFechaEmision, vFechaTimbrado, vProducto
			FROM bdicred@pld_tcp:sd_encabezado_edocta
			WHERE fecha_emision in (fecha1,fecha2,fecha3,fecha4)
	--		WHERE fecha_emision >= fini and  fecha_emision <= fechaActual
			AND num_credito = pCuenta
			ORDER BY fecha_emision DESC
			
			IF (YEAR(vFechaTimbrado) >= YEAR(vFechaEmision)) AND(MONTH(vFechaTimbrado) >= MONTH(vFechaEmision)) THEN
				IF fechaServidor >= vFechaTimbrado THEN
					IF vProducto = "7000" OR vProducto = "8100" OR vProducto = "8500" THEN					
						LET vFechaEmision = vFechaEmision - 2 UNITS DAY;
					ELIF vProducto = "5400" THEN --JRVT 12/01/2024
						LET vFechaEmision = vFechaEmision - 1 UNITS DAY;
					END IF;
					IF iContador < 3 THEN
						LET iContador = iContador + 1;
						RETURN vcodret, vFechaEmision WITH RESUME;
					END IF;
				END IF;
			ELSE
				IF vProducto = "7000" OR vProducto = "8100" OR vProducto = "8500" THEN					
						LET vFechaEmision = vFechaEmision - 2 UNITS DAY;
				ELIF vProducto = "5400" THEN --JRVT 12/01/2024
						LET vFechaEmision = vFechaEmision - 1 UNITS DAY;
				END IF;
				IF iContador < 3 THEN
					LET iContador = iContador + 1;
					RETURN vcodret, vFechaEmision WITH RESUME;
				END IF;
			END IF; 

			--------------------LO NUEVO-------------------
			IF vEsQuince = 'true' AND iContador_Hist = 1 AND iContador = 2 THEN
				FOREACH			
					SELECT fecha_emision, DATE(fecha_emision + pDiasTimbrado UNITS DAY), num_producto
					INTO vFechaEmision_Hist, vFechaTimbrado_Hist, vProducto_Hist
					FROM bdicred@pld_tcp:sd_encabezado_edocta_hist
					WHERE fecha_emision in (fecha1,fecha2,fecha3,fecha4)
					AND num_credito = pCuenta
					ORDER BY fecha_emision DESC
					
						IF (YEAR(vFechaTimbrado_Hist) >= YEAR(vFechaEmision_Hist)) AND(MONTH(vFechaTimbrado_Hist) >= MONTH(vFechaEmision_Hist)) THEN
							IF fechaServidor >= vFechaTimbrado_Hist THEN
							
								IF vProducto_Hist = "7000" OR vProducto_Hist = "8100" OR vProducto_Hist = "8500" THEN					
									LET vFechaEmision_Hist = vFechaEmision_Hist - 2 UNITS DAY;
								ELIF vProducto_Hist = "5400" THEN --JRVT 12/01/2024
									LET vFechaEmision_Hist = vFechaEmision_Hist - 1 UNITS DAY;
								END IF;
								
								IF iContador_Hist = 1 THEN
									LET iContador_Hist = iContador_Hist + 1;
									LET vEsQuince = 'false';
									RETURN vcodret, vFechaEmision_Hist WITH RESUME;
								END IF;
							END IF;
						ELSE
							IF vProducto_Hist = "7000" OR vProducto_Hist = "8100" OR vProducto_Hist = "8500" THEN					
								LET vFechaEmision_Hist = vFechaEmision_Hist - 2 UNITS DAY;
							ELIF vProducto_Hist = "5400" THEN --JRVT 12/01/2024
									LET vFechaEmision_Hist = vFechaEmision_Hist - 1 UNITS DAY;
							END IF;
							IF iContador_Hist = 1 THEN
								LET iContador_Hist = iContador_Hist + 1;
								LET vEsQuince = 'false';
								RETURN vcodret, vFechaEmision_Hist WITH RESUME;
							END IF;
						END IF;
				END FOREACH;
			END IF;
			--------------------------
			
			
			--RETURN vcodret, vFechaEmision WITH RESUME;
		END FOREACH;
	END IF;
END;

END PROCEDURE;