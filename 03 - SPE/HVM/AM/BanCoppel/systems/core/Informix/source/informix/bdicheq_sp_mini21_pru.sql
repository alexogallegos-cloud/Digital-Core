CREATE PROCEDURE "informix".sp_mini21_pru(pEmpresa CHAR(3), pUsuario CHAR(8),pSucursal CHAR(4), pFoliosuc CHAR(16))

		  
RETURNING CHAR(5) 	  AS Cod_Ret,
		  CHAR(2) 	  AS Moneda,
		  MONEY(16,2) AS Monto_Serv,
		  MONEY(16,2) AS Monto_cargoserv,
		  CHAR(40)    AS Descripcion,
          INTEGER	  AS Movto_serv,
		  INTEGER	  AS Movto_cargoserv;
	
	DEFINE mMontoServ       MONEY(16,2);
	DEFINE mMontoCargoServ  MONEY(16,2);	
	DEFINE iMovtoServ       INTEGER;
	DEFINE iMovtoCargoServ  INTEGER;
    DEFINE cDescripcion     CHAR(40); 
    DEFINE cCodRet          CHAR(5);  	
    DEFINE cMoneda          CHAR(2);   
    DEFINE iSqlErr          INTEGER;  	
    DEFINE dFecha           DATE;
	DEFINE mMontoCargoCred  MONEY(16,2);	
	DEFINE iMovtoCargoCred  INTEGER;
	DEFINE cTransaccSuc 	CHAR(4);
	--2013.08.09 FRG-I.
	DEFINE cTransaccSdoFav 	CHAR(4);
	--2013.08.09 FRG-F.
	DEFINE mMontoAbonoSer   MONEY(16,2);
	--20130529 
	DEFINE cNumCategoria 	CHAR(2);
	DEFINE cNumConvenio		CHAR(3);
	DEFINE cFormaPago		CHAR(1);
	
    LET mMontoServ = 0;
	LET mMontoCargoServ =0;
	LET iMovtoServ=0;
	LET iMovtoCargoServ=0;
	LET cDescripcion="";
	LET cCodRet= "00000";
	LET cMoneda= "";
	LET iSqlErr=0;
	LET dFecha= DATE(1);
	LET mMontoCargoCred=0;
	LET iMovtoCargoCred=0;
	LET cTransaccSuc="";
	--2013.08.09 FRG-I.
	LET cTransaccSdoFav="";
	--2013.08.09 FRG-F.
	LET mMontoAbonoSer=0;
	--20130529 
	LET cNumCategoria = '';
	LET cNumConvenio = '';
	LET cFormaPago = '';


    BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ,iMovtoCargoServ;
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/respaldosbd/rigoberto/sp_mini21.out";
		--TRACE ON;
			
		IF NVL(pEmpresa,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pFoliosuc,'') <> '' THEN
		
			SELECT fecha_hoy {+INDEX(sc_fechas idx_fechas1)}
			INTO dFecha
			FROM bdicheq:"informix".sc_fechas
			WHERE empresa = pEmpresa;
			
			--20130529 -->
			SELECT numcategoria, numconvenio, forma_pago
			INTO cNumCategoria, cNumConvenio, cFormaPago
			FROM bdisac:"informix".sac_movimientos
			WHERE id_sucursal = pSucursal
            AND folio_suc = pFoliosuc;
			
			IF ((NVL(cNumCategoria,'') ='' OR (cNumCategoria IS NULL )) OR (NVL(cNumConvenio,'') ='' OR (cNumConvenio IS NULL )) OR (NVL(cFormaPago,'') ='' OR (cFormaPago IS NULL ))) THEN
				LET cCodRet ='00003';
				RETURN cCodRet, cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ, iMovtoCargoServ;
			ELSE 
			--20130529 <--				
				
				-- Para cuando se trata del convenio pagos GDF
				SELECT TRIM(valor)
				INTO cTransaccSuc
				FROM bdisac:"informix".sac_param
				WHERE cod_param='87033';
				
				IF NVL(cTransaccSuc,'') = '' THEN
					LET cCodRet ='00002';
					RETURN cCodRet, cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ, iMovtoCargoServ;
				ELSE 
					FOREACH
						SELECT {+INDEX(sc_movdia idx_movdia4a)} pr.divisa,
							   NVL(SUM(CASE WHEN md.monto_tot <> '0.0' AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio) THEN 1 END),0),
							   NVL(SUM(CASE WHEN md.monto_tot <> '0.0' AND tr.naturaleza = "A" AND md.transacc_suc  IN(SELECT NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios  WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio) THEN md.monto_tot END),0), --v_monto_serv
							   NVL(SUM(CASE WHEN md.monto_tot <> '0.0' AND tr.naturaleza = "A" AND md.transacc_suc IN(SELECT NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios WHERE  numcategoria = cNumCategoria AND numconvenio = cNumConvenio) THEN (md.monto_tot ) END),0),
							   NVL(SUM(CASE WHEN md.monto_tot <> '0.0' AND tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio
																													UNION SELECT NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio) THEN 1 END),0), --v_movto_cargoserv
							   NVL(SUM(CASE WHEN md.monto_tot <> '0.0' AND tr.naturaleza = "C" AND md.transacc_suc  IN(SELECT NVL(trans_suc_cargo,'') FROM bdisac:"informix".sac_convenios  WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio
																													UNION SELECT NVL(trans_suc_efectivo,'') FROM bdisac:"informix".sac_convenios WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio) THEN md.monto_tot END),0),-- v_monto_cargoserv 
							   (SELECT descripcion FROM bdinteg:"informix".si_divisas WHERE pr.divisa = divisa  AND empresa = pEmpresa)
						INTO  cMoneda,
							   iMovtoServ,
							   mMontoServ,
							   mMontoAbonoSer,
							   iMovtoCargoServ,
							   mMontoCargoServ,
							   cDescripcion
						  FROM bdicheq:"informix".sc_movdia md,
							   bdicheq:"informix".sc_maechq mc,
							   bdicheq:"informix".sc_producto pr,
							   bdinteg:"informix".si_transacc tr
						   WHERE md.folio_suc = pFoliosuc
						   and md.empresa = pEmpresa
						   AND md.usuario = pUsuario
						   AND md.cancelad <> "S"
						   AND md.fech_alt = dFecha
						   AND md.sucursal = pSucursal
						   AND mc.empresa = md.empresa
						   AND mc.cuenta = md.cuenta
						   AND pr.empresa = md.empresa
						   AND pr.producto = md.producto
						   AND tr.empresa = md.empresa
						   AND tr.numero = md.transacc
						   AND tr.naturaleza IN ("A","C")
						   AND tr.realizada_por = "1"
						 GROUP BY pr.divisa
						 
						--20130529						 
							IF TRIM(cFormaPago) = '5' THEN 
								--	2013.08.09 FRG-I.
								
								IF cNumCategoria = '01' AND cNumConvenio = '002' THEN
									-- Transaccion del saldo a favor TDC en pagos Club de proteccion coppel, Para cuando se trata del convenio club de proteccion coppel
									LET cTransaccSuc = "";
									
									SELECT TRIM(valor)
									INTO cTransaccSuc
									FROM bdisac:"informix".sac_param
									WHERE cod_param=80;								
									
									SELECT TRIM(valor) 
									INTO cTransaccSdoFav
									FROM bdisac:"informix".sac_param 
									WHERE cod_param=81;
								
								-- Transacción para el EDOMEX 
								ELIF cNumCategoria = '08' AND cNumConvenio = '002' THEN
									-- Transaccion del saldo a favor TDC en pagos de servicio EDOMEX.
									SELECT TRIM(valor)
									INTO cTransaccSuc
									FROM bdisac:"informix".sac_param
									WHERE cod_param=23;
									
									SELECT TRIM(valor) 
									INTO cTransaccSdoFav
									FROM bdisac:"informix".sac_param 
									WHERE cod_param=24;		
								ELSE
									-- Transacción para pago TAE (Homologación TEA-EdoMex)
									IF cNumCategoria = '03' AND cNumConvenio = '001' THEN
										SELECT TRIM(valor)
										INTO cTransaccSuc
										FROM bdisac:"informix".sac_param
										WHERE cod_param=20;
										
										SELECT TRIM(valor) 
										INTO cTransaccSdoFav
										FROM bdisac:"informix".sac_param 
										WHERE cod_param=22;
									ELSE
										-- Flujo normal, transaccion del saldo a favor TDC en pagos GDF
										SELECT TRIM(valor) 
										INTO cTransaccSdoFav
										FROM bdisac:"informix".sac_param 
										WHERE cod_param='87041';
									END IF;
							END IF;
							
						IF NVL(cTransaccSdoFav,'') = '' THEN 
							LET cCodRet ='00002';
							RETURN cCodRet,cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ, iMovtoCargoServ;
						ELSE 
						--	2013.08.09 FRG-F.
						  SELECT 
							NVL(SUM( monto), 0),
							NVL(SUM(CASE WHEN monto <> '0' THEN 1 END), 0)
							INTO mMontoCargoCred, iMovtoCargoCred
							FROM bdicred:"informix".sd_movdia a
							WHERE folio_suc = pFoliosuc		 
							--	2013.08.09 FRG-I.
								--	AND transacc_suc = cTransaccSuc 
							AND transacc_suc in (cTransaccSuc, cTransaccSdoFav)
							--	2013.08.09 FRG-F.
							AND usuario = pUsuario
							AND sucursal = pSucursal
							AND reversado <> "S"
							AND fecha_mov = dFecha
							AND divisa = cMoneda
							AND empresa = pEmpresa;
							
						END IF;
					
							SELECT 
							NVL(SUM( monto), 0),
							NVL(SUM(CASE WHEN monto <> '0' THEN 1 END), 0)
							INTO mMontoCargoCred, iMovtoCargoCred
							FROM bdicred:"informix".sd_movdia a
							WHERE folio_suc = pFoliosuc		 
							--	2013.08.09 FRG-I.
								--	AND transacc_suc = cTransaccSuc 
							AND transacc_suc in (cTransaccSuc, cTransaccSdoFav)
							--	2013.08.09 FRG-F.
							AND usuario = pUsuario
							AND sucursal = pSucursal
							AND reversado <> "S"
							AND fecha_mov = dFecha
							AND divisa = cMoneda
							AND empresa = pEmpresa;
					
						END IF;

						RETURN 	cCodRet,
								cMoneda,
								mMontoServ + mMontoAbonoSer,
								mMontoCargoServ + mMontoCargoCred,
								cDescripcion,
								iMovtoServ,
								iMovtoCargoServ + iMovtoCargoCred WITH RESUME;
								
								--20130529
								LET mMontoCargoCred = 0;
								LET iMovtoCargoCred = 0;
					END FOREACH;				
				END IF;
			END IF;			
		ELSE 
			LET cCodRet ='00001';
			RETURN 	cCodRet,cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ,iMovtoCargoServ;
		END IF;	
    END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener el total de la transaccion base al folio suc',
'AUTOR :Eduardo López',
'FECHA : 08/01/2013',
'Ver.  : 1.0',
'BD    : bdicheq',
'MODIFICACION:Se modifica para que obtenga los totales de pagos referenciados (CAMINEMOS)',
'MODIFICÓ:Eduardo lópez ',
'FECHA:29/05/2013',
'BD    : bdicheq',
'MODIFICACION:Se modifica para pagos de WU/OV/VG para que se consultan las transacciones de abono a cuenta',
'MODIFICO:Eduardo Lopez Cuevas',
'FECHA:08/0/2013',
'BD: bdicheq',
'MODIFICACION:Se modifica para que busque la transacción de pago con TDC cuando hay saldo a favor.',
'MODIFICÓ: FRG',
'FECHA:09/Ago/2013',
'BD    : bdicheq',
'MODIFICACION:Se homologa para pagos de WU/OV/VG',
'MODIFICO:Christian Echavarria',
'FECHA:12/09/2013',
'BD: bdicheq',
'MODIFICACION:Se actualiza para que en base al convenio del folio sucursal, se consulte la transaccion parametro para el saldo a favor en pagos con tarjeta de credito.',
'SUSTENTO: 230202-1448-RQI 62 038 VentaClubdeProteccionCppl-BCP_Ver1 2.doc',
'MODIFICO:Rigoberto Gonzalez Llanes',
'FECHA:29/07/2014',
'BD: bdicheq',
'MODIFICACION:Se actualiza para que tome los totales de pago con TDC de la transaccion de pago de servicio EDOMEX.',
'MODIFICO:Jesus Isaias Bueno ',
'FECHA:17/02/2015',
'BD: bdicheq',
'MODIFICACION: Se actualiza para que tome los totales del saldo a favor del pago con TDC para EDOMEX .',
'MODIFICO:Jesus Isaias Bueno ',
'FECHA:09/03/2015',
'BD: bdicheq',
'MODIFICACION: Se actualiza para Homologación TEA-EdoMex.',
'MODIFICO: Trinidad Hernández ',
'FECHA:11/08/2015',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_geninfsociodemo_pba(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vdesccodret      CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vfechahoy        DATE; 
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    DEFINE vfecha           CHAR(8);
    DEFINE vsql             CHAR(500);
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vsucursal	    CHAR(4);
    DEFINE vproducto	    CHAR(4);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsexo	  	    CHAR(1);
    DEFINE vedocivil		CHAR(2);
    DEFINE vfecha_nac       DATE;
    DEFINE vsdo_dia_ant     DECIMAL(14,2);
    DEFINE vfecha_alta      DATE;
    DEFINE vfechultimomov   DATE;
    
    LET vcodret1        = "000";
    LET vcodret2        = "000";
    LET vdesccodret     = " ";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vcomienza       = -1;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcontador3      = 0;
    LET ven_transacc    = 0; 
    
    LET vfechahoy        = "";
    LET vmincta          = '';
    LET vmaxcta          = '';
    LET vfecha           = '';
    LET vsql             = '';
    
    LET vnumcte         = "";
    LET vcuenta         = "";
    LET vsucursal       = "";
    LET vproducto       = "";
    LET vedocivil       = "";
    LET vsexo           = "";
    LET vfecha_nac      = '';
    LET vsdo_dia_ant    = 0;
    LET vfecha_alta     = '';
    LET vfechultimomov  = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr
        SET debug file to "/resplogifx/conciliachq/sp_geninfsociodemo.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vdesccodret, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET debug file to "/resplogifx/conciliachq/sp_geninfsociodemo.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfechahoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum > 0 AND tabname = 'sc_infsociodemocap') THEN
        DROP TABLE bdicheq:"informix".sc_infsociodemocap;        
    END IF;
    
    CREATE RAW TABLE "informix".sc_infsociodemocap
        (
            numcte       CHAR(20)     NOT NULL, 
            sucursal     CHAR(4)      NOT NULL, 
            producto     CHAR(4)      NOT NULL, 
            cuenta       CHAR(20)     NOT NULL, 
            sdo_fin_mes  MONEY(18,2)  NOT NULL, 
            fecha_alta   DATE         NOT NULL, 
            fech_ult_mov DATE, 
            sexo         CHAR(1), 
            edocivil     CHAR(1), 
            fecha_nac    DATE 
        )
    EXTENT SIZE 351562 NEXT SIZE 35156 LOCK MODE ROW;
    CREATE INDEX "informix".idx_socdemcap ON "informix".sc_infsociodemocap(numcte) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_infsociodemocap;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_maechq;
    
    /* -- CLIENTES -- */
    FOREACH WITH HOLD
        SELECT UNIQUE num_cte
          INTO vnumcte
          FROM bdicheq:sc_maechq
         WHERE empresa = pempresa 
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND status_cta <> '2' 
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        /* -- Obtiene los datos socioeconomicos del cliente -- */
        SELECT sexo, estado_civil, fecha_nac
          INTO vsexo, vedocivil, vfecha_nac
          FROM bdinteg:si_ctepf
         WHERE numcte = vnumcte;
           
        /* -- CUENTAS -- */
        FOREACH 
            SELECT mae.sucursal, mae.producto, mae.cuenta, mae.fec_ult_mov, mae.sdo_dia_ant, noc.fecha_alta 
              INTO vsucursal, vproducto, vcuenta, vfechultimomov, vsdo_dia_ant, vfecha_alta 
              FROM bdicheq:sc_maechq mae,
                   bdicheq:sc_maenoc noc
             WHERE mae.num_cte = vnumcte
               AND mae.status_cta <> '2'
               AND noc.empresa = mae.empresa
               AND noc.cuenta = mae.cuenta       

            -- // Inserta datos en tabla sc_infsociodemocap
            INSERT INTO sc_infsociodemocap 
            ( numcte, sucursal, producto, cuenta, sdo_fin_mes, fecha_alta, fech_ult_mov, sexo, edocivil, fecha_nac ) 
            VALUES 
            ( vnumcte, vsucursal, vproducto, vcuenta, vsdo_dia_ant, vfecha_alta, vfechultimomov, vsexo, vedocivil, vfecha_nac );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vsucursal       = "";
            LET vproducto       = "";
            LET vcuenta	        = "";
            LET vsdo_dia_ant    = 0;
            LET vfecha_alta     = "";
            LET vfechultimomov  = '';
        END FOREACH;
        
        /* -- PAGARES -- */
        FOREACH 
            SELECT mae.sucursal, mae.cod_instrum, mae.cuenta, mae.fec_ult_mov, mae.capital, mae.fecha_alta 
              INTO vsucursal, vproducto, vcuenta, vfechultimomov, vsdo_dia_ant, vfecha_alta 
              FROM bdinvers:sv_maeinv mae
             WHERE mae.num_cte = vnumcte
               AND mae.status_cta = '1'      

            /* -- Inserta datos en tabla sc_infsociodemocap -- */
            INSERT INTO sc_infsociodemocap 
            ( numcte, sucursal, producto, cuenta, sdo_fin_mes, fecha_alta, fech_ult_mov, sexo, edocivil, fecha_nac ) 
            VALUES 
            ( vnumcte, vsucursal, vproducto, vcuenta, vsdo_dia_ant, vfecha_alta, vfechultimomov, vsexo, vedocivil, vfecha_nac );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vsucursal       = "";
            LET vproducto       = "";
            LET vcuenta	        = "";
            LET vsdo_dia_ant    = 0;
            LET vfecha_alta     = "";
            LET vfechultimomov  = '';
        END FOREACH;
        
        LET vcontador1 = vcontador1 + 1;
        
        IF vcontador3 >= 7500 THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnumcte         = "";
        LET vsexo           = "";
        LET vedocivil       = "";
        LET vfecha_nac      = "";
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_infsociodemocap;
    
    LET vfecha = TO_CHAR(vfechahoy, '%d%m%Y');
    
    LET vsql = '';
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/infosociodemograficacaptacion_'||vfecha||'.txt'||
               ' SELECT numcte, sucursal, producto, cuenta, sdo_fin_mes, fecha_alta, fech_ult_mov, sexo, edocivil, fecha_nac'||
               ' FROM sc_infsociodemocap ORDER BY numcte;" > /resplogifx/conciliachq/infsociodemocap.sql';
    SYSTEM vsql;
    LET vsql = '';
    --- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/infsociodemocap.sql"; 
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/infsociodemocap.sql"; 
    SYSTEM vsql;
    LET vsql = '';
    
    LET vdesccodret = "EL PROCESO SE REALIZO SATISFACTORIAMENTE";
    
    RETURN vcodret1, vcodret2, vdesccodret, vcontador1, vcontador2;
    
    END;

END PROCEDURE;