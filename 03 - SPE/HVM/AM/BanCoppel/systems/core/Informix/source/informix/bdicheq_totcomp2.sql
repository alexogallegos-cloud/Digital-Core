CREATE PROCEDURE "informix".totcomp2(pempresa CHAR(3),
                                    pusuario CHAR(8),
                                    psucursal CHAR(4),
                                    pnum_total SMALLINT)


RETURNING CHAR(5),CHAR(2),MONEY(16,2),MONEY(16,2),MONEY(16,2),
          MONEY(16,2),MONEY(16,2),MONEY(16,2),CHAR(40),INTEGER,INTEGER,
          INTEGER,INTEGER,INTEGER,INTEGER;

    DEFINE v_monto_cargo     MONEY(16,2);
	DEFINE v_monto_firme     MONEY(16,2);
	DEFINE v_monto_sbc       MONEY(16,2);
	DEFINE v_monto_rem       MONEY(16,2);
	DEFINE v_monto_serv      MONEY(16,2);
	DEFINE v_monto_cargoserv MONEY(16,2);
    DEFINE v_movto_cargo     INTEGER;
	DEFINE v_movto_firme     INTEGER;
	DEFINE v_movto_sbc       INTEGER;
	DEFINE v_movto_rem       INTEGER;
	DEFINE v_movto_serv      INTEGER;
	DEFINE v_movto_cargoserv INTEGER;
    DEFINE v_descripcion     CHAR(40);
    DEFINE v_contador        SMALLINT;
    DEFINE v_fecha           DATE;
    DEFINE v_row             INTEGER;
    DEFINE v_codret          CHAR(5);
    DEFINE v_producto        CHAR(4);
    DEFINE v_ciclo           SMALLINT;
    DEFINE v_moneda          CHAR(2);
    DEFINE v_cal_int_chq     CHAR(1);
    DEFINE sql_err           INTEGER;
    DEFINE vsuc_user         CHAR(4);
    DEFINE vfecha            DATE;
-- HOMOLOGACION GDF:
	DEFINE v_monto_cargo_cred MONEY(16,2);
	DEFINE v_movto_cargo_cred INTEGER;
	DEFINE v_transacc_suc 	CHAR(4);
	--	2013.08.09 FRG-I.
	DEFINE cTransaccSdoFav 	CHAR(4);
	--	2013.08.09 FRG-F.
	-- Transfer INI
	DEFINE v_movto_sbc_trans       INTEGER;
	DEFINE v_movto_firme_trans     INTEGER;
	DEFINE v_movto_serv_trans	   INTEGER; 
	DEFINE v_movto_cargo_trans	   INTEGER; 
	DEFINE v_movto_cargoserv_trans INTEGER;
	
	DEFINE v_monto_sbc_trans       MONEY(16,2); 
	DEFINE v_monto_firme_trans     MONEY(16,2);
	DEFINE v_monto_serv_trans      MONEY(16,2);
	DEFINE v_monto_cargo_trans     MONEY(16,2);
	DEFINE v_monto_cargoserv_trans MONEY(16,2);
	-- Transfer FIN

-- HOMOLOGACION CLUB DE PROTECCION:

	DEFINE v_transacc_suc_cp 	CHAR(4);	
	DEFINE cTransaccSdoFav_cp 	CHAR(4);

--2015-01-21 DSB 
-- HOMOLOGACION TIEMPO AIRE ELECTRONICO:
	DEFINE v_transacc_suc_tae 	CHAR(4);
	DEFINE cTransaccSdoFav_tae 	CHAR(4);
	
--2015-02-18 DSB 
-- HOMOLOGACION PAGO EDOMEX:
	DEFINE v_transacc_suc_edomex 	CHAR(4);
	DEFINE cTransaccSdoFav_edomex 	CHAR(4);
	
	
    LET v_contador = 0;
    LET v_ciclo = 0;
    LET v_moneda = 0;
    LET v_monto_cargo = 0;
    LET v_monto_firme = 0;
    LET v_monto_sbc = 0;
    LET v_monto_rem = 0;
    LET v_monto_serv = 0;
    LET v_monto_cargoserv = 0;
    LET v_movto_cargo = 0;
    LET v_movto_firme = 0;
    LET v_movto_sbc = 0;
    LET v_movto_rem = 0;
    LET v_movto_serv = 0;
    LET v_movto_cargoserv = 0;
    LET v_descripcion = " ";
    LET v_codret = "000";
    LET vsuc_user = "";
--HOMOLOGACION GDF	
	LET v_movto_cargo_cred = 0;
	LET v_monto_cargo_cred = 0;
	LET v_transacc_suc ="";
	--	2013.08.09 FRG-I.
	LET cTransaccSdoFav ="";
	--	2013.08.09 FRG-F.

	-- HOMOLOGACION CLUB DE PROTECCION:
	LET v_transacc_suc_cp ="";
	LET cTransaccSdoFav_cp ="";
--2015-01-21 DSB 
-- HOMOLOGACION TIEMPO AIRE ELECTRONICO:
	LET v_transacc_suc_tae	= "";
	LET cTransaccSdoFav_tae = "";
	
-- HOMOLOGACION PAGO EDOMEX:
	LET v_transacc_suc_edomex	= "";
	LET cTransaccSdoFav_edomex	= "";
	
	-- Transfer INI
	LET v_movto_sbc_trans       = 0;
	LET v_movto_firme_trans     = 0;
	LET v_movto_serv_trans	    = 0; 
	LET v_movto_cargo_trans	    = 0; 
	LET v_movto_cargoserv_trans = 0;
	
	LET v_monto_sbc_trans       = 0; 
	LET v_monto_firme_trans     = 0;
	LET v_monto_serv_trans      = 0;
	LET v_monto_cargo_trans     = 0;
	LET v_monto_cargoserv_trans = 0;
	
	-- Transfer FIN

	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_codret = sql_err;
            RETURN v_codret,v_moneda,v_monto_cargo,v_monto_firme,
                   v_monto_sbc,v_monto_rem,v_monto_serv, v_monto_cargoserv , v_descripcion,v_movto_cargo,
                   v_movto_firme,v_movto_sbc,v_movto_rem, v_movto_serv,v_movto_cargoserv WITH RESUME;
        END IF
    END EXCEPTION;

   	--SET DEBUG FILE TO "/tmp/totcomp2.out";
   	--TRACE ON;

    SELECT fecha_hoy {+INDEX(bdicheq:"informix".sc_fechas idx_fechas1)}
    INTO vfecha
    FROM bdicheq:"informix".sc_fechas
    WHERE empresa = pempresa;
	
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' and cod_param='87033';
--	2013.08.09 FRG-I.
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' and cod_param='87041';
--	2013.08.09 FRG-F.

--HOMOLOGACION CLUB DE PROTECCION:
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc_cp
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 80;
	-- 2014.08.27 RGLL
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav_cp
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 81;
	-- 2014.08.27 RGLL

--2015-01-21 DSB 
--HOMOLOGACION TIEMPO AIRE ELECTRONICO:
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc_tae
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 20;
	
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav_tae
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 22;

--2015-01-21 DSB 
--HOMOLOGACION PAGO EDOMEX:
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc_edomex
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 23;
	
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav_edomex
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 24;
	
	FOREACH
	  SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia4a)} pr.divisa,
               NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN 1 END),0),
               NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN md.en_sbc END),0),
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN (md.monto_tot - md.en_sbc) END),0),
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} trans_suc_efectivo FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '') THEN (md.monto_tot - md.en_sbc) END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN md.monto_tot END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '') THEN md.monto_tot END),0),
			   (SELECT descripcion FROM bdinteg:"informix".si_divisas WHERE pr.divisa = divisa  AND empresa = pempresa)
          INTO v_moneda,
               v_movto_sbc,
               v_monto_sbc,
               v_movto_firme,
               v_monto_firme,
               v_movto_serv,
               v_monto_serv,
               v_movto_cargo,
               v_monto_cargo,
               v_movto_cargoserv,
               v_monto_cargoserv,
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
		   AND tr.numero NOT IN('0247')
		   AND tr.sistema = "01"		
         GROUP BY pr.divisa
			
			 -- Se agrega monto de transfer
			  SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia4a)} 
					   NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN 1 END),0),
					   NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN md.en_sbc END),0),
					   NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix"."I".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
					   NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN (md.monto_tot - md.en_sbc) END),0),
					   NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
					   NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} trans_suc_efectivo FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '') THEN (md.monto_tot - md.en_sbc) END),0),
					   NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
					   NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN md.monto_tot END),0),
					   NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
					   NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '') THEN md.monto_tot END),0)
				  INTO v_movto_sbc_trans,
					   v_monto_sbc_trans,
					   v_movto_firme_trans,
					   v_monto_firme_trans,
					   v_movto_serv_trans,
					   v_monto_serv_trans,
					   v_movto_cargo_trans,
					   v_monto_cargo_trans,
					   v_movto_cargoserv_trans,
					   v_monto_cargoserv_trans
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
				   AND tr.sistema = "01"
				   AND pr.divisa = v_moneda;
		 
			 LET v_movto_sbc = v_movto_sbc + v_movto_sbc_trans;
             LET v_monto_sbc = v_monto_sbc + v_monto_sbc_trans;
             LET v_movto_firme = v_movto_firme + v_movto_firme_trans;
             LET v_monto_firme = v_monto_firme + v_monto_firme_trans;
             LET v_movto_serv = v_movto_serv + v_movto_serv_trans;
             LET v_monto_serv =  v_monto_serv + v_monto_serv_trans;
             LET v_movto_cargo = v_movto_cargo + v_movto_cargo_trans;
             LET v_monto_cargo = v_monto_cargo + v_monto_cargo_trans;
             LET v_movto_cargoserv = v_movto_cargoserv + v_movto_cargoserv_trans;
             LET v_monto_cargoserv = v_monto_cargoserv + v_monto_cargoserv_trans;
		    

		 
--HOMOLOGACION GDF		 
		 SELECT 
			NVL(SUM( monto), 0),
			NVL(SUM(CASE WHEN monto <> '0' THEN 1 END), 0)
			INTO v_monto_cargo_cred,
				 v_movto_cargo_cred
			FROM bdicred:"informix".sd_movdia a
			WHERE usuario = pusuario
			AND sucursal = psucursal
--	2013.08.09 FRG-F.
			--	AND transacc_suc = v_transacc_suc
			AND transacc_suc in (v_transacc_suc, cTransaccSdoFav, v_transacc_suc_cp, cTransaccSdoFav_cp,v_transacc_suc_tae,cTransaccSdoFav_tae,v_transacc_suc_edomex,cTransaccSdoFav_edomex)
--	2013.08.09 FRG-F.
			AND reversado <> "S"
			AND fecha_mov = vfecha
			AND empresa = pempresa
			AND divisa = v_moneda;

			
			
        RETURN v_codret,v_moneda,v_monto_cargo,v_monto_firme,
               v_monto_sbc,v_monto_rem,v_monto_serv,v_monto_cargoserv + v_monto_cargo_cred ,v_descripcion,v_movto_cargo,
               v_movto_firme,v_movto_sbc,v_movto_rem, v_movto_serv,v_movto_cargoserv + v_movto_cargo_cred WITH RESUME;

		   
    END FOREACH;

 END

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener por separado las totales de captacion y servicios de totales computador de sucursal..',
'AUTOR : Dulce Ramirez',
'FECHA : 25/Marzo/2010',
'Ver.  : 1.1',
'BD    : bdicheq',
'VER   : 1.1',
'DESCRIPCION: Se modifica procedimiento para obtener la suma de los totales de captacion y servicios de totales computador de sucursal..',
'MODIFICO: Eduardo López',
'FECHA : 28/Diciembre/2012',
'Ver.  : 1.2',
'DESCRIPCION: Se modifica procedimiento para incluir en la conciliación la transacción para TDC con saldo a favor.',
'MODIFICO: FRG',
'FECHA : 09/Agosto/2013',
'BD    : bdicheq',
'Ver.  : 1.3',
'Fecha  20/10/2014', 
'Se modifica procedimiento para incluir las cuenta Transfer',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 21/01/2014',
'Ver.  : 1.4',
'BD    : bdicheq',
'Se modifica procedimiento para obtener la transaccón de TAE',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 18/02/2015',
'Ver.  : 1.5',
'BD    : bdicheq',
'Se modifica procedimiento para incluir la cuenta de credito de la transaccón de EDOMEX',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 18/03/2015',
'Ver.  : 1.6',
'BD    : bdicheq',
'Se modifica procedimiento para homologar la cuenta de credito de la transaccón de EDOMEX y TAE, para saldo a favor.';

CREATE PROCEDURE "informix".totcomp2_web(pempresa CHAR(3),
                                    pusuario CHAR(8),
                                    psucursal CHAR(4),
                                    pnum_total SMALLINT)


RETURNING CHAR(5),CHAR(2),MONEY(16,2),MONEY(16,2),MONEY(16,2),
          MONEY(16,2),MONEY(16,2),MONEY(16,2),CHAR(40),INTEGER,INTEGER,
          INTEGER,INTEGER,INTEGER,INTEGER;

    DEFINE v_monto_cargo     MONEY(16,2);
	DEFINE v_monto_firme     MONEY(16,2);
	DEFINE v_monto_sbc       MONEY(16,2);
	DEFINE v_monto_rem       MONEY(16,2);
	DEFINE v_monto_serv      MONEY(16,2);
	DEFINE v_monto_cargoserv MONEY(16,2);
    DEFINE v_movto_cargo     INTEGER;
	DEFINE v_movto_firme     INTEGER;
	DEFINE v_movto_sbc       INTEGER;
	DEFINE v_movto_rem       INTEGER;
	DEFINE v_movto_serv      INTEGER;
	DEFINE v_movto_cargoserv INTEGER;
    DEFINE v_descripcion     CHAR(40);
    DEFINE v_contador        SMALLINT;
    DEFINE v_fecha           DATE;
    DEFINE v_row             INTEGER;
    DEFINE v_codret          CHAR(5);
    DEFINE v_producto        CHAR(4);
    DEFINE v_ciclo           SMALLINT;
    DEFINE v_moneda          CHAR(2);
    DEFINE v_cal_int_chq     CHAR(1);
    DEFINE sql_err           INTEGER;
    DEFINE vsuc_user         CHAR(4);
    DEFINE vfecha            DATE;
-- HOMOLOGACION GDF:
	DEFINE v_monto_cargo_cred MONEY(16,2);
	DEFINE v_movto_cargo_cred INTEGER;
	DEFINE v_transacc_suc 	CHAR(4);
	--	2013.08.09 FRG-I.
	DEFINE cTransaccSdoFav 	CHAR(4);
	--	2013.08.09 FRG-F.
	-- Transfer INI
	DEFINE v_movto_sbc_trans       INTEGER;
	DEFINE v_movto_firme_trans     INTEGER;
	DEFINE v_movto_serv_trans	   INTEGER; 
	DEFINE v_movto_cargo_trans	   INTEGER; 
	DEFINE v_movto_cargoserv_trans INTEGER;
	
	DEFINE v_monto_sbc_trans       MONEY(16,2); 
	DEFINE v_monto_firme_trans     MONEY(16,2);
	DEFINE v_monto_serv_trans      MONEY(16,2);
	DEFINE v_monto_cargo_trans     MONEY(16,2);
	DEFINE v_monto_cargoserv_trans MONEY(16,2);
	-- Transfer FIN

-- HOMOLOGACION CLUB DE PROTECCION:

	DEFINE v_transacc_suc_cp 	CHAR(4);	
	DEFINE cTransaccSdoFav_cp 	CHAR(4);

--2015-01-21 DSB 
-- HOMOLOGACION TIEMPO AIRE ELECTRONICO:
	DEFINE v_transacc_suc_tae 	CHAR(4);
	DEFINE cTransaccSdoFav_tae 	CHAR(4);
	
--2015-02-18 DSB 
-- HOMOLOGACION PAGO EDOMEX:
	DEFINE v_transacc_suc_edomex 	CHAR(4);
	DEFINE cTransaccSdoFav_edomex 	CHAR(4);
	
	
    LET v_contador = 0;
    LET v_ciclo = 0;
    LET v_moneda = 0;
    LET v_monto_cargo = 0;
    LET v_monto_firme = 0;
    LET v_monto_sbc = 0;
    LET v_monto_rem = 0;
    LET v_monto_serv = 0;
    LET v_monto_cargoserv = 0;
    LET v_movto_cargo = 0;
    LET v_movto_firme = 0;
    LET v_movto_sbc = 0;
    LET v_movto_rem = 0;
    LET v_movto_serv = 0;
    LET v_movto_cargoserv = 0;
    LET v_descripcion = " ";
    LET v_codret = "00001";
    LET vsuc_user = "";
--HOMOLOGACION GDF	
	LET v_movto_cargo_cred = 0;
	LET v_monto_cargo_cred = 0;
	LET v_transacc_suc ="";
	--	2013.08.09 FRG-I.
	LET cTransaccSdoFav ="";
	--	2013.08.09 FRG-F.

	-- HOMOLOGACION CLUB DE PROTECCION:
	LET v_transacc_suc_cp ="";
	LET cTransaccSdoFav_cp ="";
--2015-01-21 DSB 
-- HOMOLOGACION TIEMPO AIRE ELECTRONICO:
	LET v_transacc_suc_tae	= "";
	LET cTransaccSdoFav_tae = "";
	
-- HOMOLOGACION PAGO EDOMEX:
	LET v_transacc_suc_edomex	= "";
	LET cTransaccSdoFav_edomex	= "";
	
	-- Transfer INI
	LET v_movto_sbc_trans       = 0;
	LET v_movto_firme_trans     = 0;
	LET v_movto_serv_trans	    = 0; 
	LET v_movto_cargo_trans	    = 0; 
	LET v_movto_cargoserv_trans = 0;
	
	LET v_monto_sbc_trans       = 0; 
	LET v_monto_firme_trans     = 0;
	LET v_monto_serv_trans      = 0;
	LET v_monto_cargo_trans     = 0;
	LET v_monto_cargoserv_trans = 0;
	
	-- Transfer FIN

	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_codret = sql_err;
            RETURN v_codret,v_moneda,v_monto_cargo,v_monto_firme,
                   v_monto_sbc,v_monto_rem,v_monto_serv, v_monto_cargoserv , v_descripcion,v_movto_cargo,
                   v_movto_firme,v_movto_sbc,v_movto_rem, v_movto_serv,v_movto_cargoserv WITH RESUME;
        END IF
    END EXCEPTION;

   	--SET DEBUG FILE TO "/tmp/totcomp2.out";
   	--TRACE ON;

    SELECT fecha_hoy {+INDEX(bdicheq:"informix".sc_fechas idx_fechas1)}
    INTO vfecha
    FROM bdicheq:"informix".sc_fechas
    WHERE empresa = pempresa;
	
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' and cod_param='87033';
--	2013.08.09 FRG-I.
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' and cod_param='87041';
--	2013.08.09 FRG-F.

--HOMOLOGACION CLUB DE PROTECCION:
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc_cp
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 80;
	-- 2014.08.27 RGLL
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav_cp
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 81;
	-- 2014.08.27 RGLL

--2015-01-21 DSB 
--HOMOLOGACION TIEMPO AIRE ELECTRONICO:
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc_tae
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 20;
	
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav_tae
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 22;

--2015-01-21 DSB 
--HOMOLOGACION PAGO EDOMEX:
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO v_transacc_suc_edomex
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 23;
	
	SELECT valor {+INDEX(bdisac:"informix".sac_param 117_25)}
	INTO cTransaccSdoFav_edomex
	FROM bdisac:"informix".sac_param 
	WHERE empresa = '001' AND cod_param = 24;
	
	FOREACH
	  SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia4a)} pr.divisa,
               NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN 1 END),0),
               NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN md.en_sbc END),0),
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN (md.monto_tot - md.en_sbc) END),0),
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
               NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} trans_suc_efectivo FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '') THEN (md.monto_tot - md.en_sbc) END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN md.monto_tot END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
               NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '') THEN md.monto_tot END),0),
			   (SELECT descripcion FROM bdinteg:"informix".si_divisas WHERE pr.divisa = divisa  AND empresa = pempresa)
          INTO v_moneda,
               v_movto_sbc,
               v_monto_sbc,
               v_movto_firme,
               v_monto_firme,
               v_movto_serv,
               v_monto_serv,
               v_movto_cargo,
               v_monto_cargo,
               v_movto_cargoserv,
               v_monto_cargoserv,
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
		   AND tr.numero NOT IN('0247')
		   AND tr.sistema = "01"		
         GROUP BY pr.divisa
			
			 -- Se agrega monto de transfer
			  SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia4a)} 
					   NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN 1 END),0),
					   NVL(SUM(CASE WHEN md.en_sbc > 0 AND tr.naturaleza = "A" THEN md.en_sbc END),0),
					   NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix"."I".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
					   NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN (md.monto_tot - md.en_sbc) END),0),
					   NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
					   NVL(SUM(CASE WHEN md.monto_tot <> md.en_sbc AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} trans_suc_efectivo FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '') THEN (md.monto_tot - md.en_sbc) END),0),
					   NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
					   NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc NOT IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN md.monto_tot END),0),
					   NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '') THEN 1 END),0),
					   NVL(SUM(CASE WHEN tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE  nomconvenio <> '' UNION SELECT {+INDEX(bdisac:"informix".sac_convenios idxsac_conv3)} NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios WHERE  nomconvenio <> '') THEN md.monto_tot END),0)
				  INTO v_movto_sbc_trans,
					   v_monto_sbc_trans,
					   v_movto_firme_trans,
					   v_monto_firme_trans,
					   v_movto_serv_trans,
					   v_monto_serv_trans,
					   v_movto_cargo_trans,
					   v_monto_cargo_trans,
					   v_movto_cargoserv_trans,
					   v_monto_cargoserv_trans
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
				   AND tr.sistema = "01"
				   AND pr.divisa = v_moneda;
		 
			 LET v_movto_sbc = v_movto_sbc + v_movto_sbc_trans;
             LET v_monto_sbc = v_monto_sbc + v_monto_sbc_trans;
             LET v_movto_firme = v_movto_firme + v_movto_firme_trans;
             LET v_monto_firme = v_monto_firme + v_monto_firme_trans;
             LET v_movto_serv = v_movto_serv + v_movto_serv_trans;
             LET v_monto_serv =  v_monto_serv + v_monto_serv_trans;
             LET v_movto_cargo = v_movto_cargo + v_movto_cargo_trans;
             LET v_monto_cargo = v_monto_cargo + v_monto_cargo_trans;
             LET v_movto_cargoserv = v_movto_cargoserv + v_movto_cargoserv_trans;
             LET v_monto_cargoserv = v_monto_cargoserv + v_monto_cargoserv_trans;
		    

		 
--HOMOLOGACION GDF		 
		 SELECT 
			NVL(SUM( monto), 0),
			NVL(SUM(CASE WHEN monto <> '0' THEN 1 END), 0)
			INTO v_monto_cargo_cred,
				 v_movto_cargo_cred
			FROM bdicred:"informix".sd_movdia a
			WHERE usuario = pusuario
			AND sucursal = psucursal
--	2013.08.09 FRG-F.
			--	AND transacc_suc = v_transacc_suc
			AND transacc_suc in (v_transacc_suc, cTransaccSdoFav, v_transacc_suc_cp, cTransaccSdoFav_cp,v_transacc_suc_tae,cTransaccSdoFav_tae,v_transacc_suc_edomex,cTransaccSdoFav_edomex)
--	2013.08.09 FRG-F.
			AND reversado <> "S"
			AND fecha_mov = vfecha
			AND empresa = pempresa
			AND divisa = v_moneda;

			
		LET v_codret = "00000";
		
        RETURN v_codret,v_moneda,v_monto_cargo,v_monto_firme,
               v_monto_sbc,v_monto_rem,v_monto_serv,v_monto_cargoserv + v_monto_cargo_cred ,v_descripcion,v_movto_cargo,
               v_movto_firme,v_movto_sbc,v_movto_rem, v_movto_serv,v_movto_cargoserv + v_movto_cargo_cred WITH RESUME;
	   
    END FOREACH;

	IF (v_codret = "00001") THEN 
		
        RETURN v_codret,v_moneda,v_monto_cargo,v_monto_firme,
               v_monto_sbc,v_monto_rem,v_monto_serv,v_monto_cargoserv + v_monto_cargo_cred ,v_descripcion,v_movto_cargo,
               v_movto_firme,v_movto_sbc,v_movto_rem, v_movto_serv,v_movto_cargoserv + v_movto_cargo_cred;
	END IF;
	
 END

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener por separado las totales de captacion y servicios de totales computador de sucursal..',
'AUTOR : Dulce Ramirez',
'FECHA : 25/Marzo/2010',
'Ver.  : 1.1',
'BD    : bdicheq',
'VER   : 1.1',
'DESCRIPCION: Se modifica procedimiento para obtener la suma de los totales de captacion y servicios de totales computador de sucursal..',
'MODIFICO: Eduardo LÃ³pez',
'FECHA : 28/Diciembre/2012',
'Ver.  : 1.2',
'DESCRIPCION: Se modifica procedimiento para incluir en la conciliaciÃ³n la transacciÃ³n para TDC con saldo a favor.',
'MODIFICO: FRG',
'FECHA : 09/Agosto/2013',
'BD    : bdicheq',
'Ver.  : 1.3',
'Fecha  20/10/2014', 
'Se modifica procedimiento para incluir las cuenta Transfer',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 21/01/2014',
'Ver.  : 1.4',
'BD    : bdicheq',
'Se modifica procedimiento para obtener la transaccÃ³n de TAE',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 18/02/2015',
'Ver.  : 1.5',
'BD    : bdicheq',
'Se modifica procedimiento para incluir la cuenta de credito de la transaccÃ³n de EDOMEX',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 18/03/2015',
'Ver.  : 1.6',
'BD    : bdicheq',
'Se modifica procedimiento para homologar la cuenta de credito de la transaccÃ³n de EDOMEX y TAE, para saldo a favor.';

CREATE PROCEDURE "informix".sp_consulta_nominaplantilla_bpi(pNumCliente CHAR(9), numPosicion SMALLINT)
	returning char(5),INTEGER, CHAR(10) ;

	--Declaracion de variables
	DEFINE vCodRet char(5);
	DEFINE sql_err INTEGER;

  
    DEFINE sNombre               CHAR(10);
    DEFINE sClave               INTEGER;

	--Inicializar variables
	LET vCodRet  = "00000";
    LET sNombre  = "";
    LET sClave      = 0;

	--****************************************************************************************************
	-- DESCRIPCION: Consulta lista  de plantillas 
	-- AUTOR: Solser
	-- BD: bdicheq
	-- SOLICITO: BanCoppel
	-- Fecha: Enero 2022
	--***************************************************************************************************

	BEGIN
	   	ON EXCEPTION SET sql_err
	    	IF sql_err <> 0 THEN
	        	let vCodRet = sql_err;
                RETURN vCodRet, sClave,sNombre;
	      	END IF ;
	   	END EXCEPTION ;


	    IF(LENGTH(TRIM(NVL(pNumCliente,''))) = 0) THEN
	        LET vCodRet="00001";
             RETURN vCodRet, sClave,sNombre;
	    END IF;
     

	   	SET LOCK MODE TO WAIT 4;
           

    FOREACH
        SELECT skip numPosicion limit 10 cve_plantilla,nombre
        INTO  sClave,sNombre
        FROM bdicheq:sc_nominaplantilla_bpi
        WHERE num_cte=pNumCliente
       

	  RETURN vCodRet,sClave,sNombre WITH RESUME;
    END FOREACH;
	END
END PROCEDURE;