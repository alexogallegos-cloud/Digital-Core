CREATE PROCEDURE "informix".detdocret_web( pempresa  char(3),
                                       psucursal char(4),
                                       pusuario  char(8),
                                       pfolio    char(16),
                                       pimporte  money(14,2),
                                       pcuenta   char(20),
                                       pctabco   char(20),
                                       pdocto    integer,
                                       pbanco    char(4),
                                       ptransacc char(4),
                                       psiglas   char(2) )
returning char(5);

    DEFINE vcodret      char(5);
    DEFINE vrow         smallint;
    DEFINE vfechoy      date;
    DEFINE vfechacalc 	date;
    DEFINE vdias_ret 	smallint;
    DEFINE vreferencia 	char(40);
    DEFINE vpasado     	integer;
    DEFINE vhoraval    	CHAR(10);
    DEFINE vvalor       CHAR(10);
    DEFINE vdctabco     DECIMAL(20,0);
    DEFINE vcctabco     CHAR(20);

    LET vcodret  = "00000";
    LET vhoraval = "00:00";
    LET vdctabco = 0;
    LET vcctabco = '';

    --set debug file to "/tmp/detocret.out";
    --trace on;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT {+INDEX(sc_fechas idx_fechas1)}
           CURRENT HOUR TO MINUTE, fecha_hoy
      INTO vhoraval, vfechoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    SELECT {+INDEX(bditef:cce_param idx_param)}
           valor
      INTO vvalor
      FROM bditef:cce_param
     WHERE cod_param = 1;

    IF vhoraval >= vvalor THEN
        LET vcodret = "00015";
        RETURN vcodret;
    END IF

    if length(trim(pbanco)) < 4 then
        let pbanco = lpad(trim(pbanco),3,0);
    end if

    let vreferencia = pbanco||"-"||trim(pctabco)||"-"||pdocto;

    let vdctabco = pctabco::decimal(20,0);
    let vcctabco = vdctabco;
    let vcctabco = trim(vcctabco);

    if pempresa = "" or psucursal = "" or pusuario = "" or pfolio = "" or pimporte = 0 or pcuenta = "" or ptransacc = "" or ptransacc = "0000" or psiglas  = "" then
        let vcodret = "00110";
        return vcodret;
    end if

    select count(empresa)
      into vpasado
      from sc_docret_sbc  			--MOHA
     where siglas in('SC','SD')
       and fecha_alta = vfechoy
       and cancelado in("T", "D", "L")
       and banco = pbanco
       and numcuenta = vcctabco
       and num_chq = pdocto;

    if vpasado > 0 then
        let vcodret = "00666";
        return vcodret;
    end if

    select dias_ret
      into vdias_ret
      from bdinteg:si_transacc
     where empresa = pempresa
       and numero = ptransacc;

    if vdias_ret is null then
        let vdias_ret = 0;
    end if

    call bditef:cal_fecharet(vfechoy)
    returning vcodret,vfechacalc;

    if vcodret <> "000" then
        let vcodret = "00000";
        return vcodret;
    end if

    if vfechacalc <> vfechoy then
        let vdias_ret = 2;
    else
        let vdias_ret = 1;
    end if

	IF(select count(empresa) from sc_docret_sbc where banco = pbanco and numcuenta = vcctabco and num_chq = pdocto and cancelado in("T", "D", "L")) > 0 THEN --MOHA
		let vcodret = "00666";
		return vcodret;
	ELSE
		insert into sc_docret_sbc values     --MOHA
		( pempresa, psiglas, pcuenta, vdias_ret, pimporte, pfolio, pusuario, vfechoy, current hour to fraction(3),
		  "T", vreferencia, psucursal, pdocto, vdias_ret, ptransacc, pimporte, pbanco, vcctabco );
	
		let vcodret = "00000";
	
	END IF
    return vcodret;
END PROCEDURE
document "Version 1.00.000";

CREATE PROCEDURE "informix".totcomp_web(pempresa CHAR(3),
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
    LET v_codret = "00001";
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

		LET v_codret = "00000";
        RETURN v_codret,v_moneda,v_monto_cargo + v_monto_cargo_cred,v_monto_firme,
               v_monto_sbc,v_monto_rem,v_descripcion,v_movto_cargo + v_movto_cargo_cred,
               v_movto_firme,v_movto_sbc,v_movto_rem WITH RESUME;
    END FOREACH;
    
	IF (v_codret = "00001") THEN
        RETURN v_codret,v_moneda,v_monto_cargo + v_monto_cargo_cred,v_monto_firme,
               v_monto_sbc,v_monto_rem,v_descripcion,v_movto_cargo + v_movto_cargo_cred,
               v_movto_firme,v_movto_sbc,v_movto_rem;	
	END IF;
    END
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica procedimiento para obtener la sumatoria del monto en la tabla sd_movdia y sumarselo a monto de sc_movdia',
'MODIFICO: Eduardo LÃ³pez',
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
'Se modifica procedimientp para obtener la transaccÃ³n de TAE',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 18/02/2014',
'Ver.  : 1.4',
'BD    : bdicheq',
'Se modifica procedimientp para incluir la cuenta de credito de pagos EDOMEX',
'MODIFICO: Jesus Isaias Bueno',
'FECHA : 18/03/2015',
'Ver.  : 1.5',
'BD    : bdicheq',
'Se modifica procedimiento para homologar la cuenta de credito de la transaccÃ³n de EDOMEX y TAE, para saldo a favor.';

CREATE PROCEDURE "informix".sp_aplica_abonos_atm()
	   RETURNING char(5);

DEFINE psucursal   char(4);
DEFINE pusuario    char(8);
DEFINE pserial     integer;
DEFINE ptransacc   char(4);
DEFINE pfolio_suc  char(16);
DEFINE pcuenta     char(20);     
DEFINE pmto_tot    decimal(16,2);
DEFINE preferencia char(30);
DEFINE pnum_tarjeta char(16);
DEFINE vcodret     char(5);
DEFINE vcodret2    char(5);
DEFINE vsqlerr     integer;
DEFINE visamerr     integer;
DEFINE v_hora      CHAR(15);
DEFINE v_fecha     date;
DEFINE v_hora2      char(8);
DEFINE vexiste     smallint;

LET vcodret = "000";
LET v_hora = current hour to second;

BEGIN
on exception SET vsqlerr,visamerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 =visamerr;
            return vcodret;
        END IF
end exception;

set isolation to dirty read;
set lock mode to wait 3;

--Set debug file to "/DBA/spei_julio/sp_aplica_abonos_atm.out";
--trace on;

FOREACH WITH HOLD 
        SELECT num_serial, sucursal, usuario, transaccion, cuenta, num_tarjeta, monto_tot, referencia
		INTO pserial, psucursal, pusuario, ptransacc, pcuenta, pnum_tarjeta, pmto_tot, preferencia
		FROM sc_abonos_atm
		WHERE aplicado NOT IN('N', 'S')

        SELECT COUNT(*)
		  INTO vexiste
		  FROM sc_movdia
		 WHERE cuenta = pcuenta
           AND transacc = '0952'
           AND cancelad = 'S'
           AND monto_tot = pmto_tot;

        IF vexiste = 0 THEN		   

			BEGIN WORK;		
        
			LET v_hora = CURRENT HOUR TO FRACTION;
			LET pfolio_suc = 'ATM'||v_hora[1,2]||v_hora[4,5]||v_hora[7,8];
			LET psucursal = psucursal;
			LET pfolio_suc = pfolio_suc;
			LET pcuenta = pcuenta;
			LET pmto_tot = pmto_tot;
			LET pnum_tarjeta = pnum_tarjeta;
		
			call abono_ref('001',psucursal,pusuario,ptransacc,'0000',pfolio_suc,pcuenta,0,pmto_tot,pmto_tot,0.0,0.0,0,'01',preferencia,pnum_tarjeta,' ')
				returning vcodret;
        
			IF vcodret = '000' THEN
				UPDATE sc_abonos_atm SET aplicado = 'S', fecha_abono = CURRENT
				 WHERE num_serial = pserial;
				COMMIT WORK;
			ELSE
				ROLLBACK WORK;
			END IF;

		ELSE 

			UPDATE sc_abonos_atm SET aplicado = 'N', fecha_abono = CURRENT
			 WHERE num_serial = pserial;
			COMMIT WORK;
		
		END IF;
				
END FOREACH ;
RETURN vcodret;
END;
END PROCEDURE;