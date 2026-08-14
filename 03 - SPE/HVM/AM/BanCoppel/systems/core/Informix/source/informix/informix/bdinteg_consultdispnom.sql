CREATE PROCEDURE "informix".consultdispnom(pempresa char(3), pcuenta char(20))

RETURNING char(5), char(20), char(2), DATE, DATE;

    DEFINE vdispersiones    char(2);
    DEFINE vcodret          char(5);
    DEFINE vsqlerr          integer;
	DEFINE vproducto 		char(4);
    DEFINE vPrimerDisp      DATE;
    DEFINE vUltimDisp       DATE;

    LET vcodret    		= "00000";
    LET vsqlerr			= 0;
    LET vdispersiones	= "";
	LET vproducto  		= "";
    LET vPrimerDisp     = DATE(1);
    LET vUltimDisp      = DATE(1);

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret, pcuenta, vdispersiones, vPrimerDisp, vUltimDisp;
        END IF;
    END EXCEPTION;	

    --SET DEBUG FILE TO "/informix/tmp/consultdispnom.out";
    --TRACE ON;
   
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

      SELECT producto
      INTO vproducto
      FROM bdicheq:sc_maechq mc
      WHERE mc.empresa = pempresa 
      AND mc.cuenta = pcuenta;   

    -- 
           SELECT count (*) INTO vdispersiones
           FROM
           (SELECT num_serial
            FROM bdicheq:sc_movhis mh 
            WHERE mh.cuenta = pcuenta
            AND mh.transacc in ('0293','0287','0273', '0274')
            AND mh.fech_alt >= today - 90 
            union all
            SELECT num_serial
            FROM bdicheq:sc_movhis_old mo 
            WHERE mo.cuenta = pcuenta  
            AND mo.transacc in ('0293','0287','0273', '0274')
            AND mo.fech_alt >= today - 90
            ORDER BY num_serial);

            IF vdispersiones >= 1 THEN
                SELECT NVL(min(fech_alt),'')
                INTO vPrimerDisp 
                FROM
                (SELECT fech_alt
                FROM bdicheq:sc_movhis_old mo 
                WHERE mo.cuenta = pcuenta 
                AND mo.transacc in ('0293','0287','0273', '0274')
                AND mo.fech_alt <= today - 90
				UNION
                SELECT fech_alt
                FROM bdicheq:sc_movhis mo 
                WHERE mo.cuenta = pcuenta 
                AND mo.transacc in ('0293','0287','0273', '0274')
                AND mo.fech_alt <= today - 90);

                SELECT NVL(max(fech_alt),'')
                INTO vUltimDisp 
                FROM
                (SELECT fech_alt
                FROM bdicheq:sc_movhis mh
                WHERE mh.cuenta = pcuenta  
                AND mh.transacc in ('0293','0287','0273', '0274')
                AND mh.fech_alt >= today - 31
				UNION
                SELECT fech_alt
                FROM bdicheq:sc_movhis_old mh
                WHERE mh.cuenta = pcuenta  
                AND mh.transacc in ('0293','0287','0273', '0274')
                AND mh.fech_alt >= today - 31);
            END IF;

			-- IF vdispersiones <= 1 THEN
            IF vdispersiones < 1 THEN
                LET vcodret = '00002';
            END IF;

			IF NVL(vPrimerDisp,'') = NVL(vUltimDisp,'') THEN 
                LET vPrimerDisp='';
            END IF
			
            RETURN vcodret, pcuenta, vdispersiones, NVL(vPrimerDisp,''), NVL(vUltimDisp,'');        


END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifico para agregar el tipo de transacciÃ³n 0274 y que el minimo de movimientos sea 1 en lugar de 3',
'FECHA: 01/Noviembre/2022',
'BD: bdinteg',
'AUTOR: Joel Morales Acosta';

CREATE PROCEDURE "informix".sp_consclientenumcte(
						pEmpresa   CHAR(3),
						pNumero    CHAR(20),
						pNombre1   CHAR(26),
						pNombre2   CHAR(26),
                        pPaterno   CHAR(26),
                        pMaterno   CHAR(26),
						pFechaNac  DATE,
						pNo_Rfc    CHAR(13),
						pRazon     CHAR(60),
						pCuenta    CHAR(20),
						pTarjeta   CHAR(20),
						pTelefono  CHAR(20),
						pTipoBusq  SMALLINT,
                        pSecuencia SMALLINT)

RETURNING CHAR(5) AS cod_error,
		  CHAR(60) AS nombre_completo,
		  CHAR(20) AS num_cliente,
		  CHAR(13) AS rfc,
		  DATE AS fecha_nac,
		  CHAR(26) AS nombre1,
		  CHAR(26) AS nombre2,
		  CHAR(26) AS paterno,
		  CHAR(26) AS materno,
		  CHAR(14) AS num_cuenta,
		  CHAR(16) AS num_tarjeta,
		  SMALLINT AS tipo;
--RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo
DEFINE sql_err 				INTEGER;
DEFINE v_longitud,v_ciclo 	SMALLINT;
DEFINE v_nombre_completo 	CHAR(63);
DEFINE v_nombre1 			CHAR(26);
DEFINE v_nombre2 			CHAR(26);
DEFINE v_paterno 			CHAR(26);
DEFINE v_materno 			CHAR(26);
DEFINE v_numcte 			CHAR(20);
DEFINE v_cod_ret 			CHAR(5);
DEFINE v_razon_soc 			CHAR(60);
DEFINE v_rfc 				CHAR(13);
DEFINE v_rfc_alterno        CHAR(13);
DEFINE v_fecha_nac			DATE;
DEFINE v_numcta				CHAR(20);
DEFINE v_numtarj	        CHAR(20);
DEFINE v_iTipo			 	SMALLINT;
DEFINE v_cta				INTEGER;
DEFINE cBinTar				CHAR(6);
DEFINE cIdentificaCuenta 	CHAR(2);

--set debug file to "sp_consclientenumcte.out";
--trace on;

LET v_cod_ret = "00000";
LET v_ciclo   = 0;
LET v_nombre_completo = "";
LET v_nombre1 = "";
LET v_nombre2 = "";
LET v_paterno = "";
LET v_materno = "";
LET v_numcte  = "000000000";
LET v_rfc     = "";
LET v_rfc_alterno = "";
LET v_numcta  = "";
LET v_numtarj = "";
LET v_iTipo   = 0;
LET v_fecha_nac = null;
LET v_cta     = 0;
LET cBinTar = '0';
LET cIdentificaCuenta = '0';

BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
   	     LET v_cod_ret = sql_err;
	     RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
     END IF;
   END EXCEPTION;

	IF NVL(pEmpresa,'') = ''  THEN
		LET v_cod_ret = "00001";
		LET v_iTipo = 20; 
		LET v_nombre_completo = 'Parámetros incompletos';
		RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
	END IF;
	IF pTipoBusq = 0 THEN
		LET v_cod_ret = "00001";
		LET v_iTipo = 20;
		LET v_nombre_completo = 'No se ha indicado el tipo de busqueda';
		RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
	END IF;
	
	-- TDC coppel pey inicio
	LET cBinTar = SUBSTR(pTarjeta,1,6);
		
	IF TRIM(cBinTar) = '514014' THEN
		LET	pTipoBusq = 9;
	END IF;
	
	LET cIdentificaCuenta = SUBSTR(pCuenta,1,2);
	IF TRIM(cIdentificaCuenta) = '65' THEN
		LET	pTipoBusq = 10;
	END IF;	
	-- TDC coppel pey fin
	
	--IF pTipoBusq = 5 THEN
	--	LET v_cod_ret = "00001";
	--	LET v_iTipo = 20;
	--	LET v_nombre_completo = 'No se ha indicado el tipo de busqueda';
	--	RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
	--ELSE 

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pTipoBusq = 1 THEN
	-- BUSQUEDA POR CLIENTE
		IF pNumero IS NOT NULL AND pNumero !="" THEN
			FOREACH
				SELECT skip pSecuencia limit 21
					 case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
				FROM si_cliente cl LEFT JOIN si_ctepf pf ON cl.numcte = pf.numcte
				WHERE cl.numcte=pNumero
				ORDER BY cl.numcte

				IF v_fecha_nac is null THEN
					LET v_nombre_completo = TRIM(v_nombre1);
				ELSE
					LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
							|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
				END IF;
						
				IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
				   LET v_rfc = v_rfc_alterno;
				END IF;
			END FOREACH;
			IF v_numcte IS NULL OR v_numcte='' OR v_numcte='0000000000' THEN
				LET v_cod_ret = '00137';
				LET v_iTipo = 11;
			END IF;
			IF v_cod_ret = '' THEN
				let v_cod_ret = '00001';
				let v_nombre_completo = 'No se encontro informacion relacionada';
			END IF;
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
		ELSE
			LET v_cod_ret = '00001';
			LET v_iTipo = 20;
			LET v_nombre_completo = 'Debe capturar el número de cliente';
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
		END IF;
	ELIF pTipoBusq = 2 THEN
	--BUSQUEDA POR NUMERO DE CUENTA
		IF pCuenta IS NOT NULL AND pCuenta !="" THEN
			SELECT num_cte,cuenta 
			INTO v_numcte,v_numcta 
			FROM bdicheq:"informix".sc_maechq 
			WHERE cuenta = pCuenta;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				SELECT numcte,num_credito  
				INTO v_numcte,v_numcta 
				FROM bdicred:"informix".sd_maecred 
				WHERE num_credito = pCuenta;
				
				SELECT numcte,num_credito,num_tarjeta
				INTO v_numcte,v_numcta,v_numtarj
				FROM bdicred:"informix".sd_tarjeta
				WHERE num_credito = v_numcta
				AND numcte = v_numcte
				AND secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta  
					WHERE empresa = pEmpresa
					AND num_credito = v_numcta
					AND numcte = v_numcte);   
				
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT num_cte,cuenta
					INTO v_numcte,v_numcta 
					FROM bdinvers:"informix".sv_maeinv 
					WHERE empresa = pEmpresa
					AND cuenta = pCuenta
					AND secuencia IS NOT NULL;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						SELECT numcte,num_credito 
						INTO v_numcte,v_numcta 
						FROM bdicred:"informix".sd_maecredcrd 
						WHERE num_credito = pCuenta;
						
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							LET v_cod_ret = '00100';
							LET v_iTipo = 12;
							IF v_cod_ret = '' THEN
								let v_cod_ret = '00001';
								let v_nombre_completo = 'No se encontro informacion relacionada';
							END IF;
							RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
						END IF;
					END IF;
				END IF;
			END IF;
			IF v_numcte IS NOT NULL AND v_numcte<>'' AND v_numcte<>'0000000000' THEN
				FOREACH 
					SELECT case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
					INTO v_nombre1 ,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
					FROM si_cliente cl LEFT JOIN si_ctepf pf ON cl.numcte = pf.numcte
					WHERE cl.numcte=v_numcte
					ORDER BY cl.numcte

					IF v_fecha_nac is null THEN
						LET v_nombre_completo = TRIM(v_nombre1);
					ELSE
						LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
								|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
					END IF;

					IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
					   LET v_rfc = v_rfc_alterno;
					END IF;
				END FOREACH;
			ELSE
				LET v_cod_ret = '00137';
				LET v_iTipo = 11;
			END IF;
			IF v_cod_ret = '' THEN
				let v_cod_ret = '00001';
				let v_nombre_completo = 'No se encontro informacion relacionada';
			END IF;
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
		ELSE
			LET v_cod_ret = '00001';
			LET v_iTipo = 20;
			LET v_nombre_completo = 'Debe capturar el número de la cuenta';
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
		END IF;

	ELIF pTipoBusq = 3 THEN
	--BUSQUEDA POR NUMERO DE TARJETA
		IF pTarjeta IS NOT NULL AND pTarjeta !="" THEN
			SELECT numcte,cuenta,num_tarjeta
			INTO v_numcte,v_numcta,v_numtarj
			FROM bdicheq:"informix".sc_tarjeta 
			WHERE empresa = pEmpresa
			AND num_tarjeta = pTarjeta
			AND status_tar = "A";
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				SELECT numcte,num_credito,num_tarjeta 
				INTO v_numcte,v_numcta,v_numtarj
				FROM bdicred:"informix".sd_tarjeta 
				WHERE num_tarjeta = pTarjeta
				AND status_tar = "A";
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET v_cod_ret = '00100';
					LET v_iTipo = 6;
					IF v_cod_ret = '' THEN
						let v_cod_ret = '00001';
						let v_nombre_completo = 'No se encontro informacion relacionada';
					END IF;
					RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
				END IF;
			END IF;
			IF v_numcte IS NOT NULL AND v_numcte<>'' AND v_numcte<>'0000000000' THEN
				FOREACH
					SELECT
					 case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
					INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
					FROM si_cliente cl
					LEFT JOIN si_ctepf pf ON cl.numcte = pf.numcte
					WHERE cl.numcte=v_numcte
					ORDER BY cl.numcte

					IF v_fecha_nac is null THEN
						LET v_nombre_completo = TRIM(v_nombre1);
					ELSE
						LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
								|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
					END IF;

					IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
					   LET v_rfc = v_rfc_alterno;
					END IF;
				END FOREACH;
			ELSE
				LET v_cod_ret = "00137";
				LET v_iTipo = 11;
			END IF;
			IF v_cod_ret = '' THEN
				let v_cod_ret = '00001';
			END IF;
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
		ELSE
			LET v_cod_ret = '00001';
			LET v_iTipo = 20;
			LET v_nombre_completo = 'Debe capturar el número de la tarjeta';
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
		END IF;
	ELIF pTipoBusq = 4 THEN
	--BUSQUEDA POR NUMERO DE TELEFONO
		IF pTelefono IS NOT NULL AND pTelefono !="" THEN
			select count(1) into v_cta
			from si_telefonos_actual sta, si_cliente sic
			where sta.telefono=pTelefono 
			and sta.numcte = sic.numcte and sta.status_tel='A' and sta.cofetel='V' and sta.tipo_tel=2 and sic.tipo_cliente = '1';
			IF v_cta=1 THEN
				select sta.numcte into v_numcte
				from si_telefonos_actual sta, si_cliente sic
				where 
				sta.telefono=pTelefono 
				and sta.numcte = sic.numcte and sta.status_tel='A' and sta.cofetel='V' and sta.tipo_tel=2 and sic.tipo_cliente = '1';

				IF v_numcte IS NOT NULL AND v_numcte<>'' AND v_numcte<>'0000000000' THEN
					FOREACH
						SELECT
						 case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
						INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
						FROM si_cliente cl
						LEFT JOIN si_ctepf pf ON cl.numcte = pf.numcte
						WHERE cl.numcte=v_numcte
						ORDER BY cl.numcte

						IF v_fecha_nac is null THEN
							LET v_nombre_completo = TRIM(v_nombre1);
						ELSE
							LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
									|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
						END IF;

						IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
						   LET v_rfc = v_rfc_alterno;
						END IF;
					END FOREACH;
				ELSE
					LET v_cod_ret = "02200";
					LET v_iTipo = 11;
				END IF;
				IF v_cod_ret = '' THEN
					let v_cod_ret = '00001';
					let v_nombre_completo = 'No se encontro informacion relacionada';
				END IF;
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
			ELSE
				LET v_cod_ret = "02200";
				LET v_iTipo = 11;
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
			END IF;
		ELSE
			LET v_cod_ret = '00001';
			LET v_iTipo = 20;
			LET v_nombre_completo = 'Debe capturar el número de telefono';
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
		END IF;
	ELIF pTipoBusq = 5 THEN
	--BUSQUEDA POR NUMERO DE TARJETA
		IF pTarjeta IS NOT NULL AND pTarjeta !="" THEN
			SELECT cuenta,numcte
			INTO v_numcta,v_numcte
			FROM bdicheq:"informix".sc_tarjeta
			WHERE empresa = pEmpresa
			AND num_tarjeta = pTarjeta;

			SELECT numcte,cuenta,num_tarjeta
			INTO v_numcte,v_numcta,v_numtarj
			FROM bdicheq:"informix".sc_tarjeta
			WHERE empresa = pEmpresa
			AND cuenta = v_numcta
			AND numcte = v_numcte
			AND secuencia = (SELECT MAX(secuencia)
							  FROM bdicheq:"informix".sc_tarjeta  
							 WHERE empresa = pEmpresa
							   AND cuenta = v_numcta
			AND numcte = v_numcte
						   )    
			AND status_tar in ('A', 'C', 'I');
									
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			SELECT num_credito,numcte
			INTO v_numcta,v_numcte
			FROM bdicred:"informix".sd_tarjeta  
			WHERE empresa = pEmpresa
			AND num_tarjeta = pTarjeta;

			SELECT numcte,num_credito,num_tarjeta
			INTO v_numcte,v_numcta,v_numtarj
			FROM bdicred:"informix".sd_tarjeta
			WHERE num_credito = v_numcta
			AND numcte = v_numcte
			AND secuencia = (SELECT MAX(secuencia)
			  FROM bdicred:"informix".sd_tarjeta  
			 WHERE empresa = pEmpresa
			AND num_credito = v_numcta
			AND numcte = v_numcte
			)    
			AND status_tar in ('A', 'C', 'I');
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET v_cod_ret = '00100';
					LET v_iTipo = 6;
					IF v_cod_ret = '' THEN
						let v_cod_ret = '00001';
						let v_nombre_completo = 'No se encontro informacion relacionada';
					END IF;
					RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
				END IF;
			END IF;
			IF v_numcte IS NOT NULL AND v_numcte<>'' AND v_numcte<>'0000000000' THEN
				FOREACH
					SELECT
					 case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
					INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
					FROM si_cliente cl
					LEFT JOIN si_ctepf pf ON cl.numcte = pf.numcte
					WHERE cl.numcte=v_numcte
					ORDER BY cl.numcte

					IF v_fecha_nac is null THEN
						LET v_nombre_completo = TRIM(v_nombre1);
					ELSE
						LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
								|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
					END IF;

					IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
					   LET v_rfc = v_rfc_alterno;
					END IF;
				END FOREACH;
			ELSE
				LET v_cod_ret = "00137";
				LET v_iTipo = 11;
			END IF;
			IF v_cod_ret = '' THEN
				let v_cod_ret = '00001';
			END IF;
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
		ELSE
			LET v_cod_ret = '00001';
			LET v_iTipo = 20;
			LET v_nombre_completo = 'Debe capturar el número de la tarjeta';
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
		END IF;
	ELIF pTipoBusq = 8 THEN
	--BUSQUEDA POR NUMERO DE CLIENTE COPPEL
		IF pNumero IS NOT NULL AND pNumero !="" THEN
			SELECT numcte_banco
				INTO v_numcte
				FROM "informix".si_relacion_ctebcplcpl
				WHERE empresa = TRIM(pEmpresa) AND cliente = TRIM(pNumero);
	
			IF v_numcte IS NOT NULL AND v_numcte<>'' AND v_numcte<>'0000000000' THEN
					FOREACH
						SELECT
						 case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
						INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
						FROM si_cliente cl
						LEFT JOIN si_ctepf pf ON cl.numcte = pf.numcte
						WHERE cl.numcte=v_numcte
						ORDER BY cl.numcte

						IF v_fecha_nac is null THEN
							LET v_nombre_completo = TRIM(v_nombre1);
						ELSE
							LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
									|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
						END IF;

						IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
						   LET v_rfc = v_rfc_alterno;
						END IF;
					END FOREACH;
				ELSE
					LET v_cod_ret = "00137";
					LET v_iTipo = 11;
				END IF;
				IF v_cod_ret = '' THEN
					let v_cod_ret = '00001';
					let v_nombre_completo = 'No se encontro informacion relacionada';
				END IF;
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
		ELSE
			LET v_cod_ret = '00001';
			LET v_iTipo = 20;
			LET v_nombre_completo = 'Debe capturar el número de Cliente Coppel';
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
		END IF;

	-- TDC coppel pey inicio
	ELIF pTipoBusq = 9 THEN
	--BUSQUEDA TDC Coppel PAY por tarjeta
		IF pTarjeta IS NOT NULL AND pTarjeta !="" THEN
			
			select tar.numcliente,tarcta.numcuenta, tarcta.numtarjeta
			INTO v_numcte,v_numcta,v_numtarj
			from intercard:"informix".tarjetacuenta tarcta , intercard:"informix".Tarjeta tar
			where tarcta.numtarjeta = pTarjeta
			and tar.numtarjeta = tarcta.numtarjeta;		
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				
				LET v_cod_ret = '00100';
				LET v_iTipo = 11;
				IF v_cod_ret = '' THEN
					let v_cod_ret = '00001';
					let v_nombre_completo = 'No se encontro informacion relacionada';
				END IF;
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
			
			END IF;
			IF v_numcte IS NOT NULL AND v_numcte<>'' AND v_numcte<>'0000000000' THEN
				FOREACH
					SELECT
					 case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
					INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
					FROM si_cliente cl
					LEFT JOIN si_ctepf pf ON cl.numcte = pf.numcte
					WHERE cl.numcte=v_numcte
					ORDER BY cl.numcte

					IF v_fecha_nac is null THEN
						LET v_nombre_completo = TRIM(v_nombre1);
					ELSE
						LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
								|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
					END IF;

					IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
					   LET v_rfc = v_rfc_alterno;
					END IF;
				END FOREACH;
			ELSE
				LET v_cod_ret = "00137";
				LET v_iTipo = 11;
			END IF;
			IF v_cod_ret = '' THEN
				let v_cod_ret = '00001';
			END IF;
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
		ELSE
			LET v_cod_ret = '00001';
			LET v_iTipo = 20;
			LET v_nombre_completo = 'Debe capturar el número de la tarjeta';
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
		END IF;
	
	ELIF pTipoBusq = 10 THEN
	--BUSQUEDA TDC Coppel PAY por cuenta	
		IF pCuenta IS NOT NULL AND pCuenta !="" THEN
			
			select tar.numcliente,tarcta.numcuenta, tarcta.numtarjeta
			INTO v_numcte,v_numcta,v_numtarj
			from intercard:"informix".tarjetacuenta tarcta , intercard:"informix".Tarjeta tar
			where tarcta.numcuenta = pCuenta
			and tar.numtarjeta = tarcta.numtarjeta;		
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			/*	select tar.numcliente,tarcta.numcuenta, tarcta.numtarjeta
				INTO v_numcte,v_numcta,v_numtarj
				from intercard:"informix".tarjetacuenta tarcta , intercard:"informix".Tarjeta tar, 
				bdisolic:"informix".ss_solicitudes solic, bdinteg:"informix".si_relacion_ctebcplcpl relcplbcpl
				where solic.num_solicitud = pCuenta
				and relcplbcpl.numcte_banco = solic.numcte
				and tarcta.numtarjeta = relcplbcpl.num_tar_coppelaplazos
				and tar.numtarjeta = tarcta.numtarjeta;

								
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN */
				
					LET v_cod_ret = '00100';
					LET v_iTipo = 11;
					IF v_cod_ret = '' THEN
						let v_cod_ret = '00001';
						let v_nombre_completo = 'No se encontro informacion relacionada';
					END IF;
					RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;				
				
				--END IF;		
			END IF;
			IF v_numcte IS NOT NULL AND v_numcte<>'' AND v_numcte<>'0000000000' THEN
				FOREACH
					SELECT
					 case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
					INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
					FROM si_cliente cl
					LEFT JOIN si_ctepf pf ON cl.numcte = pf.numcte
					WHERE cl.numcte=v_numcte
					ORDER BY cl.numcte

					IF v_fecha_nac is null THEN
						LET v_nombre_completo = TRIM(v_nombre1);
					ELSE
						LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
								|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
					END IF;

					IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
					   LET v_rfc = v_rfc_alterno;
					END IF;
				END FOREACH;
			ELSE
				LET v_cod_ret = "00137";
				LET v_iTipo = 11;
			END IF;
			IF v_cod_ret = '' THEN
				let v_cod_ret = '00001';
			END IF;
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
		ELSE
			LET v_cod_ret = '00001';
			LET v_iTipo = 20;
			LET v_nombre_completo = 'Debe capturar el número de la tarjeta';
			RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
		END IF;
	
		-- TDC coppel pey fin
	ELSE 
	--BUSQUEDA POR NOMBRE
		IF pRazon IS NOT NULL AND pRazon !="" THEN
		-- BUSQUEDA POR RAZON SOCIAL
				IF((SELECT count (1) 
							FROM si_cliente
				WHERE razon_social = prazon
				   and apell_paterno = ''
				   and apell_materno = '') = 0) then
									let v_cod_ret = '00001';
									let v_nombre_completo = 'No se encontro Razon Social proporcionada';
					
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
			ELSE	
			FOREACH
				SELECT skip pSecuencia limit 21
					 razon_social,numcte,rfc
				INTO v_razon_soc,v_numcte,v_rfc
				FROM si_cliente
				WHERE razon_social = prazon
				   and apell_paterno = ''
				   and apell_materno = ''
				ORDER BY numcte
				LET v_nombre_completo = v_razon_soc;
				IF v_cod_ret = '' THEN
					let v_cod_ret = '00001';
					let v_nombre_completo = 'No se encontro informacion relacionada';
				END IF;
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
			END FOREACH;
			END IF;	
		ELSE
			IF pNo_Rfc IS NOT NULL AND pNo_Rfc != "" THEN
			-- BUSQUEDA POR RFC
					IF((SELECT count (1) 
						FROM si_cliente cl LEFT JOIN si_ctepf pf ON cl.numcte = pf.numcte
						WHERE rfc = pno_rfc) = 0) then
								let v_cod_ret = '00001';
								let v_nombre_completo = 'No se encontro RFC proporcionado';
							
					RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
					ELSE
				FOREACH
					SELECT skip pSecuencia limit 21
						 case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
					INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
					FROM si_cliente cl LEFT JOIN si_ctepf pf ON cl.numcte = pf.numcte
					WHERE rfc = pno_rfc
					ORDER BY pf.numcte
					LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
					 || " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
					 
					IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
					   LET v_rfc = v_rfc_alterno;
					END IF;
					IF v_cod_ret = '' THEN
						let v_cod_ret = '00001';
						let v_nombre_completo = 'No se encontro informacion relacionada';
					END IF;
					RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
				END FOREACH;
				END IF;	
			ELSE
			--BUSQUEDA POR NOMBRE COMPLETO
				---VALIDA PARAMETROS
				IF NVL(pPaterno,'') = ''  THEN
					LET v_cod_ret = "00002";
					LET v_iTipo = 20; 
					LET v_nombre_completo = 'Debe capturar al menos uno de los dos apellidos';
					RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
				ELIF NVL(pNombre1,'') = '' THEN
					LET v_cod_ret = "00003";
					LET v_iTipo = 20; 
					LET v_nombre_completo = 'Debe capturar al menos uno de los dos nombres';
					RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
				ELSE
					if ( pPaterno is null or pPaterno = "" ) then
						let pPaterno = "";
					else
						let pPaterno = trim(pPaterno);
					end if;  

					if ( pMaterno is null or pMaterno = "" ) then
						let pMaterno = "";
					else
						let pMaterno = trim(pMaterno);
					end if;  

					if ( pNombre1 is null or pNombre1 = "" ) then
						let pNombre1 = "";
					else
						let pNombre1 = trim(pNombre1);
					end if;  

					if ( pNombre2 is null or pNombre2 = "" ) then
						let pNombre2 = "";
					else
						let pNombre2 = trim(pNombre2);
					end if;  

					IF NVL(pFechaNac,'') <> '' THEN
						FOREACH
							SELECT skip pSecuencia limit 21
								case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
							INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
							FROM si_cliente cl JOIN si_ctepf pf ON cl.numcte = pf.numcte
							WHERE cl.apell_paterno = ppaterno
							AND cl.apell_materno = pmaterno
							AND cl.nombre1 matches pNombre1
							AND cl.nombre2 matches pNombre2
							AND pf.fecha_nac = pFechaNac
							ORDER BY apell_paterno, apell_materno, nombre1, nombre2

							LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
									|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);

							IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
								LET v_rfc = v_rfc_alterno;								
							END IF;
							IF v_cod_ret = '' THEN
								let v_cod_ret = '00001';
								let v_nombre_completo = 'No se encontro informacion relacionada';
							END IF;
							RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
						END FOREACH;
					ELSE
						IF((SELECT count (1) 
							FROM si_cliente cl JOIN si_ctepf pf ON cl.numcte = pf.numcte
							WHERE cl.apell_paterno = ppaterno
							AND cl.apell_materno = pmaterno
							AND cl.nombre1 = pNombre1
							AND cl.nombre2 = pNombre2) = 0) then
								let v_cod_ret = '00001';
								let v_nombre_completo = 'No se encontro informacion relacionada';
								RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo;
						ELSE
							
								FOREACH
									SELECT skip pSecuencia limit 21
										case when cl.nombre1='' then cl.razon_social else cl.nombre1 end as nombre1,cl.nombre2,cl.apell_paterno,cl.apell_materno,cl.numcte,cl.rfc,cl.rfc_alterno,pf.fecha_nac
									INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc,v_rfc_alterno,v_fecha_nac
									FROM si_cliente cl JOIN si_ctepf pf ON cl.numcte = pf.numcte
									WHERE cl.apell_paterno = ppaterno
									AND cl.apell_materno = pmaterno
									AND cl.nombre1 matches pNombre1
									AND cl.nombre2 matches pNombre2
									ORDER BY apell_paterno, apell_materno, nombre1, nombre2

									LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(UPPER(v_materno))
											|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
										
									IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
										LET v_rfc = v_rfc_alterno;
									END IF;		
									IF v_cod_ret = '' THEN
										let v_cod_ret = '00001';
										let v_nombre_completo = 'No se encontro informacion relacionada';
									END IF;
									RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc,v_fecha_nac,v_nombre1,v_nombre2,v_paterno,v_materno,v_numcta,v_numtarj,v_iTipo WITH RESUME;
								END FOREACH;
						
							
						END IF;
						 -- 
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;

END;
END PROCEDURE
DOCUMENT
'01022021  Agrega la opcion 5 para pruebas',
'Consulta clientes por nombre(s) y apellido(s), numero de Cliente, tarjeta, cuenta y por fecha de nacimiento si asi se requiere',
'AUTOR : Irving Guerrero',
'FECHA : 10/Agosto/2016',
'Ver.  : 1.1',
'BD    : bdinteg',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_obtenerctas_cte2(pEmpresa CHAR(3),
									 pNumCte CHAR(20),
									 pCuenta CHAR(20),
									 pTarjeta CHAR(20),
									 pTipoCuenta INTEGER)	
--DATOS A REGRESAR---
RETURNING CHAR(6)   AS Retorno,  
		  CHAR(20)  AS Cuenta;
		  
	-- DEFINICION DE VARIABLES
	DEFINE cCod_ret      	 CHAR(6);	
    DEFINE cNumCte      	 CHAR(20);	
    DEFINE cCuenta      	 CHAR(20); 
    DEFINE cStatus      	 CHAR(20);
	DEFINE cTarjeta      	 CHAR(20);	
	DEFINE iSqlErr      	 INTEGER;
	--IFRS
	DEFINE cMtoVen			 DECIMAL(14,2);

	--INICIALIZACION DE VARIABLES
	LET cCod_ret     	  = "000000";		
	LET cNumCte    	 	  = "";    
    LET cCuenta      	  = "";	
    LET cStatus      	  = "";
	LET cTarjeta     	  = "";	
	LET iSqlErr      	  = 0;	
	--IFRS
	LET cMtoVen			  = 0;
	

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCod_ret = iSqlErr;
				
				RETURN cCod_ret,cCuenta;	
			END IF;
		END EXCEPTION;
		
	--SET DEBUG FILE TO '/home/sysifx/respaldosbd/JesusRLopez/789/Sp_obtenerctas_cte.sql';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	IF NVL(pEmpresa,'') = '' THEN
			LET cCod_ret = '00001';			 
			RETURN cCod_ret,cCuenta;
		ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
			LET cCod_ret = '00001';			
			RETURN cCod_ret,cCuenta;		
		ELSE
			IF pCuenta <> '' THEN
				SELECT num_cte,cuenta 
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_maechq 
				WHERE cuenta = pCuenta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_maecred 
					WHERE num_credito = pCuenta;			
				END IF;
				
			ELIF pTarjeta <> '' THEN 
			
			IF SUBSTR(pTarjeta,1,6) <> '514014' THEN --TDC PAY
			
				SELECT numcte,cuenta
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE empresa = "001"
				AND num_tarjeta = pTarjeta
				AND status_tar = "A";
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE num_tarjeta = pTarjeta
					AND status_tar in ('A','I','C');
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCod_ret = '00100';						
						RETURN cCod_ret,cCuenta;
					END IF;
				END IF;
				
			END IF;			
			ELIF pNumCte <> '' THEN
				LET cNumCte = pNumCte;
			END IF;
			
				IF pTipoCuenta <> "5" AND pTipoCuenta <> "6" AND pTipoCuenta <> "7" THEN--TDC PAY
				
					SELECT numcte 
					INTO cNumCte 
					FROM bdinteg:"informix".si_cliente 
					WHERE numcte = cNumCte;

					IF cNumCte IS NULL THEN
						LET cCod_ret = "000003";				
						RETURN cCod_ret,cCuenta;
					END IF;
					
				END IF;	
			
			IF pTipoCuenta = "1" THEN
			-- *****************************************************************
			-- Extrae la informacion del Sistema de Cheques
			-- *****************************************************************		
				FOREACH
					--AAME 13042020 RQI 27 221 Se consulta num credito en caso de que sea adicional si encuentre la cuenta
					SELECT DISTINCT cuenta 
					INTO cCuenta 
					FROM bdicheq:"informix".sc_tarjeta 
					WHERE empresa = "001"
					AND numcte = cNumCte AND status_tar IN ('I','A','C')
					
					--AAME RQI 27 221 Se cambia la consulta por la cuenta obtenida en la consulta a sc_tarjeta
					SELECT DISTINCT	mc.cuenta INTO cCuenta FROM bdicheq:"informix".sc_maechq mc						
					WHERE mc.cuenta = cCuenta AND mc.empresa = pEmpresa AND mc.status_cta IN ('1','3','4','5');					
					--ORDER BY cuenta;			
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						CONTINUE FOREACH;
					END IF;

					RETURN cCod_ret, NVL(cCuenta,"") WITH RESUME;					
				END FOREACH;
				FOREACH
					SELECT DISTINCT	mc.cuenta INTO cCuenta FROM bdicheq:"informix".sc_maechq mc						
					WHERE mc.num_cte = cNumCte AND mc.empresa = pEmpresa AND mc.status_cta IN ('1','3','4','5')					
					AND cuenta NOT IN (SELECT cuenta FROM bdicheq:"informix".sc_tarjeta WHERE empresa = "001"
										AND numcte = cNumCte AND status_tar IN ('I','A','C'))
					ORDER BY cuenta	
					
					RETURN cCod_ret, NVL(cCuenta,"") WITH RESUME;	
				END FOREACH;				
				--INC 27 152 para no repetir cuentas
				IF dbinfo("sqlca.sqlerrd2") = 0 AND NVL(cCuenta,"") = "" THEN 
					LET cCod_ret = '00100';						
					RETURN cCod_ret,cCuenta;
				END IF;
							
			ELIF pTipoCuenta = "2" THEN											
				-- *********************************************************************
				-- Extrae la informacion del Sistema de Credito
				-- *********************************************************************
				
				--FOREACH
				--	SELECT DISTINCT ss.num_solicitud INTO cCuenta FROM bdisolic: ss_solicitudes ss					  
				--	WHERE numcte = cNumCte AND ss.status_solicitud = 'AT' ORDER BY 1
									
				--	RETURN cCod_ret, NVL(cCuenta,"")WITH RESUME;					
				--END FOREACH;
		
				FOREACH
					/*SELECT DISTINCT mc.num_credito INTO cCuenta	FROM bdicred:"informix".sd_maecred mc
					WHERE numcte = cNumCte AND mc.status_cred = 'AA' 
					AND num_producto in ('6001','6600','7000','8100','8500')
					ORDER BY 1	*/
                    --AAME 13042020 RQI 27 221 Se consulta num credito en caso de que sea adicional si encuentre el credito
                    SELECT DISTINCT num_credito 
                    INTO cCuenta 
                    FROM bdicred:"informix".sd_tarjeta 
                    WHERE empresa = "001"
                    AND numcte = cNumCte AND status_tar IN ('I','A','C')
                    --AAME RQI 27 221 Se cambia la consulta por la cuenta obtenida en la consulta a sd_tarjeta
					--IFRS Se contempla nuevo estatus vigente por Etapas	
                    LET cCod_ret= '000000';
                    SELECT DISTINCT mc.num_credito, mc.status_cred INTO cCuenta, cStatus FROM bdicred:"informix".sd_maecred mc
					WHERE num_credito = cCuenta AND mc.status_cred in ('AA','BA','BT','E1','E2','E3')
					--WHERE num_credito = cCuenta AND mc.status_cred in ('AA','BA','FF')
					AND num_producto in ('6001','6600','7000','8100','8500');
					--ORDER BY 1	
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						CONTINUE FOREACH;
					END IF;

					SELECT nvl(sdo.monto_vencido + sdo.mto_venc_trasp,0)
					INTO cMtoVen
					FROM bdicred:"informix".sd_maesdos sdo
					WHERE num_credito = cCuenta;
					
					IF (cMtoVen > 0) THEN
						LET cCod_ret= '000001'; --Cta con vencido
					END IF;

--                    IF 	cStatus = 'BA' THEN
--                        LET cCod_ret= '000001'; --Cta con vencido
					--ELIF cStatus = 'FF' THEN
						--continue foreach;
                    --END IF                    
				
					RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;					
				END FOREACH;
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET cCod_ret = '00100';						
					RETURN cCod_ret,cCuenta;
				END IF;
        ELIF pTipoCuenta = "3" THEN
                SELECT numcte,cuenta
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE empresa = "001"
				AND num_tarjeta = pTarjeta;
			--	AND status_tar = "A";
			RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;	

          
         --ElIF pTipoCuenta = "4" THEN ----TDC PAY Se comenta
        ElIF pTipoCuenta = "4" AND SUBSTR(pTarjeta,1,6) <> '514014' THEN --DSB JR
	    SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE empresa = "001"
			       	AND num_tarjeta = pTarjeta;
			--      	AND status_tar = "A";
	RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;	
	
		--TDC PAY Inicio -----------------------------------------------
		ELIF pTipoCuenta = "5" THEN 
			FOREACH
				select DISTINCT numcuenta INTO cCuenta 
				from intercard: "informix".TarjetaCuenta Tac, intercard:"informix".Tarjeta Tar 
				WHERE Tac.NumTarjeta = Tar.NumTarjeta
				and Tar.codproductotarjeta ='007' and Tar.numcliente = pNumCte
				
				RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;
			END FOREACH;
					
		ElIF pTipoCuenta = "6" AND SUBSTR(pTarjeta,1,6) = '514014' THEN
			   select numcuenta INTO cCuenta 
			   from intercard: "informix".TarjetaCuenta 
			   WHERE NumTarjeta =  pTarjeta;
			   
			   RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;
			   
		ElIF pTipoCuenta = "7" THEN
				select DISTINCT numcuenta INTO cCuenta 
				from intercard: "informix".TarjetaCuenta 
				WHERE numcuenta =  pCuenta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					select sol.num_solicitud INTO cCuenta 
					from bdisolic: "informix".ss_solicitudes sol,bdinteg: "informix".si_relacion_ctebcplcpl rel, intercard: "informix".Tarjeta tar
					where sol.numcte = rel.numcte_banco  
					and rel.num_tar_coppelaplazos =tar.numtarjeta
					and rel.empresa = pEmpresa 
					and sol.num_solicitud = pCuenta;
				END IF;

				RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;
		--TDC PAY Fin --------------------------------------------------

        END IF;	
	END IF;	

	END
END PROCEDURE             
DOCUMENT
'DESCRIPCION: Realiza consulta de Cliente para regresar la información de sus cuentas de cheques, créditos, activos y con estatus vencido',
'Folio: 98',
'Autor: Scarlett Mendoza',
'Proyecto Tarjetas Personalizadas: ',
'Fecha: 17-10-2017',
'BD:bdinteg';

CREATE PROCEDURE "informix".sp_obtenerctas_cte2_web(pEmpresa CHAR(3),
									 pNumCte CHAR(20),
									 pCuenta CHAR(20),
									 pTarjeta CHAR(20),
									 pTipoCuenta INTEGER)	
--DATOS A REGRESAR---
RETURNING CHAR(5)   AS Retorno,  
		  CHAR(20)  AS Cuenta;
		  
	-- DEFINICION DE VARIABLES
	DEFINE cCod_ret      	 CHAR(5);	
    DEFINE cNumCte      	 CHAR(20);	
    DEFINE cCuenta      	 CHAR(20); 
    DEFINE cStatus      	 CHAR(20);
	DEFINE cTarjeta      	 CHAR(20);	
	DEFINE iSqlErr      	 INTEGER;	
	--IFRS
	DEFINE cMtoVen			 DECIMAL(14,2);	   

	--INICIALIZACION DE VARIABLES
	LET cCod_ret     	  = "00000";		
	LET cNumCte    	 	  = "";    
    LET cCuenta      	  = "";	
    LET cStatus      	  = "";
	LET cTarjeta     	  = "";	
	LET iSqlErr      	  = 0;	
	--IFRS
	LET cMtoVen			  = 0;

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCod_ret = iSqlErr;
				
				RETURN cCod_ret,cCuenta;	
			END IF;
		END EXCEPTION;
		
	--SET DEBUG FILE TO '/tmp/Sp_obtenerctas_cte.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	IF NVL(pEmpresa,'') = '' THEN
			LET cCod_ret = '00001';			 
			RETURN cCod_ret,cCuenta;
		ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
			LET cCod_ret = '00001';			
			RETURN cCod_ret,cCuenta;		
		ELSE
			IF pCuenta <> '' THEN
				SELECT num_cte,cuenta 
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_maechq 
				WHERE cuenta = pCuenta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_maecred 
					WHERE num_credito = pCuenta;			
				END IF;
				
			ELIF pTarjeta <> '' THEN
			
			IF SUBSTR(pTarjeta,1,6) <> '514014' THEN --TDC PAY
			
				SELECT numcte,cuenta
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE empresa = "001"
				AND num_tarjeta = pTarjeta
				AND status_tar = "A";
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE num_tarjeta = pTarjeta
					AND status_tar in ('A','I','C');
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCod_ret = '00100';						
						RETURN cCod_ret,cCuenta;
					END IF;
				END IF;
				
			END IF;			
			ELIF pNumCte <> '' THEN
				LET cNumCte = pNumCte;
			END IF;
			
			IF pTipoCuenta <> "5" AND pTipoCuenta <> "6" AND pTipoCuenta <> "7" THEN--TDC PAY
				
				SELECT numcte 
				INTO cNumCte 
				FROM bdinteg:"informix".si_cliente 
				WHERE numcte = cNumCte;
	
				IF cNumCte IS NULL THEN
					LET cCod_ret = "00003";				
					RETURN cCod_ret,cCuenta;
				END IF;
				
			END IF;

			IF pTipoCuenta = "1" THEN
			-- *****************************************************************
			-- Extrae la informacion del Sistema de Cheques
			-- *****************************************************************		
				FOREACH
					--AAME 13042020 RQI 27 221 Se consulta num credito en caso de que sea adicional si encuentre la cuenta
					SELECT DISTINCT cuenta 
					INTO cCuenta 
					FROM bdicheq:"informix".sc_tarjeta 
					WHERE empresa = "001"
					AND numcte = cNumCte AND status_tar IN ('I','A','C')
					
					--AAME RQI 27 221 Se cambia la consulta por la cuenta obtenida en la consulta a sc_tarjeta
					SELECT DISTINCT	mc.cuenta INTO cCuenta FROM bdicheq:"informix".sc_maechq mc						
					WHERE mc.cuenta = cCuenta AND mc.empresa = pEmpresa AND mc.status_cta IN ('1','3','4','5');					
					--ORDER BY cuenta;			
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						CONTINUE FOREACH;
					END IF;

					RETURN cCod_ret, NVL(cCuenta,"") WITH RESUME;					
				END FOREACH;
				FOREACH
					SELECT DISTINCT	mc.cuenta INTO cCuenta FROM bdicheq:"informix".sc_maechq mc						
					WHERE mc.num_cte = cNumCte AND mc.empresa = pEmpresa AND mc.status_cta IN ('1','3','4','5')					
					AND cuenta NOT IN (SELECT cuenta FROM bdicheq:"informix".sc_tarjeta WHERE empresa = "001"
										AND numcte = cNumCte AND status_tar IN ('I','A','C'))
					ORDER BY cuenta	
					
					RETURN cCod_ret, NVL(cCuenta,"") WITH RESUME;	
				END FOREACH;				
				--INC 27 152 para no repetir cuentas
				IF dbinfo("sqlca.sqlerrd2") = 0 AND NVL(cCuenta,"") = "" THEN 
					LET cCod_ret = '00100';						
					RETURN cCod_ret,cCuenta;
				END IF;
							
			ELIF pTipoCuenta = "2" THEN											
				-- *********************************************************************
				-- Extrae la informacion del Sistema de Credito
				-- *********************************************************************
		
				FOREACH
					/*SELECT DISTINCT mc.num_credito INTO cCuenta	FROM bdicred:"informix".sd_maecred mc
					WHERE numcte = cNumCte AND mc.status_cred = 'AA' 
					AND num_producto in ('6001','6600','7000','8100','8500')
					ORDER BY 1	*/
                    --AAME 13042020 RQI 27 221 Se consulta num credito en caso de que sea adicional si encuentre el credito 
                    SELECT DISTINCT num_credito 
                    INTO cCuenta 
                    FROM bdicred:"informix".sd_tarjeta 
                    WHERE empresa = "001"
                    AND numcte = cNumCte AND status_tar IN ('I','A','C')
                    --AAME RQI 27 221 Se cambia la consulta por la cuenta obtenida en la consulta a sd_tarjeta
					--IFRS Se contempla nuevo estatus vigente por Etapas	
					 LET cCod_ret= '00000';
                    SELECT DISTINCT mc.num_credito, mc.status_cred INTO cCuenta, cStatus FROM bdicred:"informix".sd_maecred mc
					WHERE num_credito = cCuenta AND mc.status_cred in ('AA','BA','BT','E1','E2','E3')
					--WHERE num_credito = cCuenta AND mc.status_cred in ('AA','BA','FF')
					AND num_producto in ('6001','6600','7000','8100','8500');
					--ORDER BY 1	
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						CONTINUE FOREACH;
					END IF;

					SELECT nvl(sdo.monto_vencido + sdo.mto_venc_trasp,0)
					INTO cMtoVen
					FROM bdicred:"informix".sd_maesdos sdo
					WHERE num_credito = cCuenta;
					
					IF (cMtoVen > 0) THEN
						LET cCod_ret= '00001'; --Cta con vencido
					END IF;

--                    IF 	cStatus = 'BA' THEN
--                        LET cCod_ret= '000001'; --Cta con vencido
					--ELIF cStatus = 'FF' THEN
						--continue foreach;
                    --END IF                    
				
					RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;					
				END FOREACH;
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET cCod_ret = '00100';						
					RETURN cCod_ret,cCuenta;
				END IF;
        ELIF pTipoCuenta = "3" THEN
                SELECT numcte,cuenta
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE empresa = "001"
				AND num_tarjeta = pTarjeta;
			
			RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;	

          
          --ElIF pTipoCuenta = "4" THEN ----TDC PAY Se comenta
        ElIF pTipoCuenta = "4" AND SUBSTR(pTarjeta,1,6) <> '514014' THEN --DSB JR
			SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE empresa = "001"
			       	AND num_tarjeta = pTarjeta;
			RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;
			
			--TDC PAY Inicio -----------------------------------------------
		ELIF pTipoCuenta = "5" THEN 
			FOREACH
				select DISTINCT numcuenta INTO cCuenta 
				from intercard: "informix".TarjetaCuenta Tac, intercard:"informix".Tarjeta Tar 
				WHERE Tac.NumTarjeta = Tar.NumTarjeta
				and Tar.codproductotarjeta ='007' and Tar.numcliente = pNumCte
				
				RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;
			END FOREACH;
					
		ElIF pTipoCuenta = "6" AND SUBSTR(pTarjeta,1,6) = '514014' THEN
			   select numcuenta INTO cCuenta 
			   from intercard: "informix".TarjetaCuenta 
			   WHERE NumTarjeta =  pTarjeta;
			   
			   RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;
			   
		ElIF pTipoCuenta = "7" THEN
				select DISTINCT numcuenta INTO cCuenta 
				from intercard: "informix".TarjetaCuenta 
				WHERE numcuenta =  pCuenta;

				RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;
		--TDC PAY Fin --------------------------------------------------

        END IF;	
	END IF;		

	END
END PROCEDURE             
DOCUMENT
'DESCRIPCION: Realiza consulta de Cliente para regresar la información de sus cuentas de cheques, créditos, activos y con estatus vencido',
'Folio: 98',
'Autor: Scarlett Mendoza',
'Proyecto Tarjetas Personalizadas: ',
'Fecha: 17-10-2017',
'BD:bdinteg';

CREATE PROCEDURE "informix".sp_obtenernumproducto (p_sEmpresa CHAR(3), p_sNumCuenta CHAR(20), p_sNumTarjeta CHAR(20))

RETURNING	 VARCHAR(6) as sNumProducto --numero de producto

	DEFINE iSqlErr				INTEGER;
	DEFINE v_sNumProducto 		CHAR(4);
	DEFINE v_sTipoCuenta		CHAR(2);
	DEFINE cProducto            CHAR(100);
	DEFINE cProductoTran        CHAR(4);
	DEFINE iCantidad	        integer;	DEFINE vPRoTar        		CHAR(4);	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Erick Zamora
	-- FECHA: 23-03-2009
	-- Obtiene el numero de producto al que hace referencia una cuenta 
	-- SET DEBUG FILE TO '/home/tmp/leonardo/sp_obtenernumproducto.out';
	-- TRACE ON;
	------------------------------------------------------------------------------------------------------
	
	LET v_sNumProducto = "";
	LET cProducto 	   = '';
	LET cProductoTran  = '';
	LET vPRoTar  	   = '';	LET iCantidad      = 0; --DSB PAY
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN 
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
--		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/tmp/cons_cta_o_tar.out";
		--TRACE ON;
		
	--DSB PAY INICIO
	
	IF p_sNumCuenta is null THEN
		LET p_sNumCuenta = '';
	END IF;
	
	LET vPRoTar = SUBSTR(p_sNumCuenta,1,2);  

	IF vPRoTar = '65' THEN
	
		select count(numcuenta)
		INTO iCantidad 
		from  intercard:"informix".TarjetaCuenta 
		where numcuenta = p_sNumCuenta;
				
		IF (iCantidad) > 0 THEN		
			LET v_sNumProducto = "6500";
		ELSE
			LET v_sNumProducto = "0000";
		END IF;
	ELSE
	--DSB PAY FIN
		
		SELECT TRIM(valor)
		INTO cProducto
		FROM bditransfer:"informix".tf_param 
		WHERE empresa = p_sEmpresa
        AND cod_param = '4';
	
		LET v_sNumProducto = "0000";
		--SE OBTIENE EL NUMERO DE CUENTA DE LA TARJETA DE DEBITO
		IF p_sNumCuenta = "" AND p_sNumTarjeta <> "" THEN
			SELECT prodtarjeta INTO v_sNumProducto FROM bdicheq:sc_tarjeta WHERE empresa = p_sEmpresa AND num_tarjeta = p_sNumTarjeta;
			IF v_sNumProducto is null THEN
			   LET v_sNumProducto = "000000";
			END IF
			
			IF TRIM(cProducto) = NVL(v_sNumProducto, '') THEN 
				LET v_sNumProducto = '0858';
			END IF;
		
			RETURN v_sNumProducto;
		END IF

		IF p_sNumTarjeta <> '' THEN
			SELECT prodtarjeta 
			INTO cProductoTran 
			FROM bdicheq:"informix".sc_tarjeta 
			WHERE empresa = p_sEmpresa 
			AND num_tarjeta = p_sNumTarjeta;
		END IF	
		
		IF TRIM(cProducto) <> NVL(cProductoTran, '') THEN 
		
			LET v_sTipoCuenta = SUBSTR(p_sNumCuenta,1,2);
			SELECT producto 
			INTO v_sNumProducto 
			FROM bdicheq:sc_maechq 
			WHERE empresa = p_sEmpresa 
			AND cuenta = p_sNumCuenta;
		
			IF v_sNumProducto is null or v_sNumProducto = "" THEN
				SELECT num_producto 
				INTO v_sNumProducto 
				FROM bdisolic:ss_solicitudes 
				WHERE empresa = p_sEmpresa 
				AND num_solicitud = p_sNumCuenta;
				  
				IF v_sNumProducto is null or v_sNumProducto = "" THEN			  
					SELECT num_producto 
					INTO v_sNumProducto 
					FROM bdicred:sd_maecred 
					WHERE empresa = p_sEmpresa 
					AND num_credito = p_sNumCuenta;
					
					IF v_sNumProducto is null or v_sNumProducto = "" THEN
						SELECT cod_instrum 
						INTO v_sNumProducto 
						FROM bdinvers:sv_maeinv 
						WHERE empresa = p_sEmpresa 
						AND cuenta = p_sNumCuenta;
					END IF
				END IF					
			END IF
			
			IF v_sNumProducto is null or v_sNumProducto = "" THEN
			   LET v_sNumProducto = "0000";
			END IF;
		ELSE
			LET v_sNumProducto = '0858';
		END IF;
		
		END IF; --DSB PAY 
		RETURN v_sNumProducto;
	END
END PROCEDURE
DOCUMENT
'Folio: 1611',
'AUTOR :95594213 Leonardo Plata',
'FECHA : 01/07/2014',
'MODIFICACIÓN: Se Modifica sp para que en caso de que el producto de la tarjeta sea 8000 retorne codigo de error',
'SUSTENTO: modificaciones_promotoria.pdf',
'SOLICITA: Rodolfo Gomez ',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_tdcaplazos(pEmpresa CHAR(3),pTipoProceso CHAR(1), pNumCte CHAR(20), pNumTarjetaAct CHAR(20))
	RETURNING   CHAR(6)  AS codigo_retorno,	---cod_ret
				CHAR(20) AS	numCte_ref	; ---Número de referencia del cliente

	-- declara variables 
    DEFINE v_cod_ret            CHAR(6);
	DEFINE cFechaSistema 		DATE;
	DEFINE iSqlErr				INTEGER;
	DEFINE v_numcte_ref 		CHAR(20);
	DEFINE cNumTarCoppelaplazos CHAR(16);
	DEFINE numSolicitud 		CHAR(20);
	DEFINE numCredito	 		CHAR(20);
	DEFINE sNumCteCoppel		CHAR(20);
	DEFINE sSucursal			CHAR(4);
	
	
	-- inicia variables 
	LET v_cod_ret = '000000';
	--LET cFechaSistema = DATE(1);
	LET iSqlErr = 0;
	LET v_numcte_ref = "";
	LET cNumTarCoppelaplazos = "";
	LET numSolicitud = "";
	LET numCredito = "";
	LET sNumCteCoppel = "";
	LET sSucursal = "";

	SET ISOLATION TO DIRTY READ;

	BEGIN
	
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET v_cod_ret = iSqlErr;
			END IF;
			RETURN v_cod_ret,v_numcte_ref;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/informix/JesusR/Sp_tdcaplazos.out";
		--TRACE ON;	
		
		-- SE OBTIENE FECHA HOY
		SELECT fecha_hoy INTO cFechaSistema FROM bdinteg:"informix".si_fechas WHERE empresa =pEmpresa;
		
		IF pEmpresa = '' OR pTipoProceso = '' OR  pNumCte = '' OR (pTipoProceso != '3' AND pNumTarjetaAct = '') THEN
			
			LET v_cod_ret = '000001';
			RETURN v_cod_ret,v_numcte_ref;
			
		END IF;
		
		--pTipoProceso 1 = REPOSICION Y ALTA DE TARJETA TDC A PLAZOS.
		--pTipoProceso 2 = OBTENER REFERENCIA DEL CLIENTE.
		--pTipoProceso 3 = OBTENER REFERENCIA POR NUMERO DE CLIENTE.
		--pTipoProceso 4 = VALIDAR QUE EL CLIENTE TENGA UNA TDCOPPELAPLAZOS.
		IF pTipoProceso = '1' THEN
	
			IF EXISTS (select numcte_banco from bdinteg:"informix".si_relacion_ctebcplcpl where numcte_banco = pNumCte) THEN
			
				SELECT suc_asigna 
				INTO sSucursal 
				FROM bdicred:"informix".bitacora_activacion 
				WHERE empresa = pEmpresa AND numtarjeta = pNumTarjetaAct;
				
				update bdinteg:"informix".si_relacion_ctebcplcpl 
				set num_tar_coppelaplazos = pNumTarjetaAct,
				fecha_asigna_coppelapla = cFechaSistema,   
				sucursal_CoppelAPla = sSucursal,  
				envio_CoppelAPla = 0
				where empresa = pEmpresa
				AND numcte_banco = pNumCte;
				
				LET v_cod_ret = '000000';				
			
			ELSE			
				-- NO EXISTE CLIENTE
				LET v_cod_ret = '000002';
			
			END IF;
	
		ELIF  pTipoProceso = '2' THEN
		
			SELECT FIRST 1 numCte_ref
			INTO v_numcte_ref
			FROM bdinteg: "informix".si_refclientes 
			WHERE empresa = pEmpresa 
			AND numcte = pNumCte;
			
			LET v_cod_ret = '000000';

		ELIF  pTipoProceso = '3' THEN

			--BUSCAMOS EL NUMERO DE REFERENCIA DE si_refclientes
			IF EXISTS (SELECT numCte_ref FROM bdinteg:"informix".si_refclientes WHERE empresa = pEmpresa AND numcte = pNumCte AND numCte_ref != '') THEN
				
				SELECT FIRST 1 NVL(numCte_ref, '')
				INTO v_numcte_ref
				FROM bdinteg:"informix".si_refclientes 
				WHERE empresa = pEmpresa 
				AND numcte = pNumCte 
				AND numCte_ref != '';
			ELSE
			--BUSCAMOS EL NUMERO DE REFERENCIA DE ss_refpersonales
				SELECT FIRST 1 NVL(numCte_ref, '')
				INTO v_numcte_ref
				FROM  bdisolic:"informix".ss_refpersonales 
				WHERE empresa = pEmpresa 
				AND numcte = pNumCte 
				AND numCte_ref != '' 
				AND numCte_ref NOT IN('R1', 'R2');
			END IF;

			LET v_cod_ret = '000000';
			
		ELIF  pTipoProceso = '4' THEN
			SELECT num_tar_coppelaplazos 
			INTO  cNumTarCoppelaplazos
			FROM  bdinteg:"informix".si_relacion_ctebcplcpl 
			WHERE empresa = pEmpresa
			AND numcte_banco = pNumCte;
			
			IF Trim(cNumTarCoppelaplazos) <> "0" THEN
				LET v_cod_ret = '000002';
			END IF;
			
				
		-- ELIF  pTipoProceso = '5' THEN
			-- SELECT LIMIT 1 num_solicitud
			-- INTO numSolicitud
			-- FROM bdisolic: "informix".ss_solicitudes
			-- WHERE numcte = pNumCte AND num_producto= '6500';
			
			
			-- IF TRIM(numSolicitud) <> "" THEN
				-- select num_credito 
				-- INTO numCredito
				-- FROM bdicred:"informix".sd_maecred 
				-- WHERE num_credito = numSolicitud;
				
				-- IF TRIM(numCredito) IS NULL THEN
				
					-- INSERT INTO bdicred:"informix".sd_maecred
						   -- (EMPRESA                ,NUM_CREDITO
						   -- ,NUM_PRODUCTO           ,EJECUTIVO
						   -- ,NUMCTE                 ,DIVISA
						   -- ,SUCURSAL               ,ID_ORIGEN
						   -- ,ORIGEN                 ,COD_TIPO_LINEA
						   -- ,COD_LINEA              ,PORC_REC_PROP
						   -- ,STATUS_CRED            ,BANDERA_RENOVAC
						   -- ,BANDERA_PRORROGA       ,PERIODO_PLAZO
						   -- ,PLAZO                  ,FECHA_APERTURA
						   -- ,FECHA_VENCIM           ,PERIOD_PAGO_CAP
						   -- ,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
						   -- ,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
						   -- ,COD_TASA_BASE          ,FACTOR_SOBRETASA
						   -- ,SOBRETASA              ,TASA_INTERES
						   -- ,COD_TASA_MORA          ,SOBRETASA_MORA
						   -- ,FACT_SOBRET_MORA       ,TASA_MORATORIOS
						   -- ,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
						   -- ,ES_FISICA              ,BANDERA_FI_FO
						   -- ,CODIGO_PRO             ,SUPERFICIE
						   -- ,ACTIVIDAD              ,CAL_EDOS_FIN
						   -- ,TIPO_CALCULO           ,ADMITE_TLP
						   -- ,REL_GARCRED            ,ID_UNIDAD_PROD
						   -- ,NUM_APER_ANT           ,REV_TASA_VAR_PER
						   -- ,DIA_PARA_REVISAR       ,COD_PROD
						   -- ,BANDERA_MINISTRA       ,NUM_FIDEICOMISO
						   -- ,CREDITO_EXTERNO        ,GRACIA_CAPITAL
						   -- ,DIFERIMIENTO_INT       ,FECHA_FIN_PRORRATEO
						   -- ,CAMPO_TRAB1            ,CAMPO_TRAB2
						   -- ,CAMPO_TRAB3            ,CAMPO_TRAB4
						   -- ,CALIFICACION_RIESGO    ,COD_AGRICOLA
						   -- ,TASA_BASE_PISO         ,SOBRETASA_PISO
						   -- ,FACTOR_PISO            ,TASA_PISO
						   -- ,TASA_BASE_TECHO        ,SOBRETASA_TECHO
						   -- ,FACTOR_TECHO           ,TASA_TECHO
						   -- )
					 -- SELECT SOL.EMPRESA                ,numSolicitud
						   -- ,SOL.NUM_PRODUCTO           ,USER
						   -- ,pNumCte          ,'01'
						   -- ,SOL.SUCURSAL               ,''
						   -- ,''                         ,''
						   -- ,''              ,0
						   -- ,'AA'                       ,'N'
						   -- ,'N'                        ,SOL.PERIODO_PLAZO
						   -- ,1                 ,CURRENT
						   -- ,CURRENT               ,1
						   -- ,1        ,0
						   -- ,0          ,1
						   -- ,1          ,SOL.FACTOR_SOBRETASA
						   -- ,1              ,1
						   -- ,SOL.COD_TASA_MORA          ,SOL.SOBRETASA_MORA
						   -- ,SOL.FACT_SOBRET_MORA       ,1
						   -- ,''                         ,''
						   -- ,TIP.ES_FISICA              ,''
						   -- ,DEF.COD_PROD               ,0
						   -- ,''             				,''
						   -- ,2				           ,''
						   -- ,0                          ,''
						   -- ,''                         ,SOL.REV_TASA_VAR_PER
						   -- ,SOL.DIA_PARA_REVISAR       ,''
						   -- ,'P'                        ,''
						   -- ,''                         ,SOL.GRACIA_CAP
						   -- ,SOL.DIFERIMIENTO_INT       ,CURRENT
						   -- ,0                          ,0
						   -- ,''                         ,''
						   -- ,'A'                        ,''
						   -- ,SOL.TASA_BASE_PISO         ,SOL.SOBRETASA_PISO
						   -- ,SOL.FACTOR_PISO            ,SOL.TASA_PISO
						   -- ,SOL.TASA_BASE_TECHO        ,0
						   -- ,SOL.FACTOR_TECHO           ,0
					 -- FROM   BDISOLIC:"informix".SS_SOLICITUDES SOL
						  -- , BDINTEG:"informix".SI_CLIENTE      CLI
						  -- , BDINTEG:"informix".SI_TIPPER       TIP
						  -- , BDICRED: "informix".SD_DEFINICION           DEF
					 -- WHERE  DEF.EMPRESA         = SOL.EMPRESA
					 -- AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
					 -- AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
					 -- AND    CLI.NUMCTE          = SOL.NUMCTE
					 -- AND    CLI.EMPRESA         = SOL.EMPRESA
					 -- AND    SOL.NUM_SOLICITUD   = numSolicitud
					 -- AND    SOL.EMPRESA         = pEmpresa;
					 
				-- END IF;			
			-- END IF;
			
		ELIF  pTipoProceso = '6' THEN
			SELECT cliente 
			INTO sNumCteCoppel
			FROM bdinteg: "informix".si_relacion_ctebcplcpl 
			WHERE numcte_banco = pNumCte;
			LET v_numcte_ref = sNumCteCoppel;
			
			IF TRIM(sNumCteCoppel) = "" THEN
				LET v_cod_ret = '000004';
			END IF;
			
		ELSE
			-- NO SE RECIBE PARAMETRO pTipoProceso VALIDO
			LET v_cod_ret = '000003';
		
		END IF;
	   
		RETURN NVL(v_cod_ret,0),NVL(v_numcte_ref,0);
	END;
END PROCEDURE
DOCUMENT
'MODIFICACION: 99805011 - Efrain Miranda Miranda',
'Folio: ',
'RQM: TDC Coppel Plazos fijos ',
'Descripcion: El procedimiento se encarga de actualizar la tabla si_relacion_ctebcplcpl',
'Fecha: ',
'Solicito: Luis Gil',
'BD: BDINTEG',

'MODIFICACION: 99805029 - Jesús Javier Sánchez Guerrero',
'Folio: ',
'RQM: TDC Coppel Plazos fijos ',
'Descripcion: Se actualiza procedimiento para obtener el numero de referencia del cliente',
'Fecha: 19/01/2022',
'BD: BDINTEG',

'MODIFICACION: 94206041 - Jesús Rosario López Castro',
'Folio: ',
'RQM: TDC Coppel Plazos fijos ',
'Descripcion: Validar que el cliente tenga TDCoppelAPlazos',
'Solicito: Luis Gil',
'Fecha: 07/03/2022',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_ctehuella_prue(pempresa CHAR(3),
                                         psucursal CHAR(4),
                                         pejecutivo CHAR(8),
                                         pautoriza CHAR(8),
                                         pfecha_alta date,
                                         pfuncion CHAR(1),
                                         pnumcte CHAR(20),
                                         pmapad char(942),
                                         pmapai char(942)) 
										 
  RETURNING CHAR(5),smallint;

define vcodret CHAR(5);
define vsigsec smallint;
define vexiste CHAR(1);
define vtp_persona CHAR(2);
define vsqlerr INTEGER;
define visamerr INTEGER;
define vesfisica CHAR(1);



LET vcodret = "000";
LET vsigsec = 0;
LET vexiste = 0;
LET vtp_persona = "";

--SET DEBUG FILE TO '/informix/logspssql/sp_ctehuellaconcambio.sql';
--TRACE ON;


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vsigsec;
   END IF;
END EXCEPTION;

--- Verifica recepcion correcta de datos
IF pnumcte IS NULL OR Trim(pnumcte) = ""
   OR pmapad IS NULL OR pmapad = ""
   OR pmapai IS NULL OR pmapai = "" then
   LET vcodret = "110";
   RETURN vcodret,vsigsec;
END IF;

SELECT tpo_persona INTO vtp_persona
FROM   si_cliente
WHERE  numcte = pnumcte;

SELECT es_fisica INTO vesfisica
   FROM si_tipper
   WHERE tpo_persona = vtp_persona;
IF UPPER(vesfisica) != "S" THEN
   LET vcodret = "120";
   RETURN vcodret,vsigsec;
END IF;

SELECT 1 INTO vexiste
   FROM si_sucursales
   WHERE sucursal=psucursal;
IF vexiste IS NULL THEN
   LET vcodret="111";
   RETURN vcodret,vsigsec;
END IF;

SELECT 1 INTO vexiste
   FROM si_ejecut
   WHERE ejecutivo=pejecutivo;
IF vexiste IS NULL THEN
   LET vcodret="112";
   RETURN vcodret,vsigsec;
END IF;
if Trim(pautoriza) <> "" then
   SELECT 1 INTO vexiste
     FROM si_ejecut
    WHERE ejecutivo=pautoriza;
   IF vexiste IS NULL THEN
      LET vcodret="112";
      RETURN vcodret,vsigsec;
   END IF;
END IF;

IF pfuncion != "A" and pfuncion != "C" THEN
   let vcodret = "130";
   RETURN vcodret,vsigsec;
END IF
-- ****************** Actualizacion de Parametros *****************
IF pfuncion="A" THEN
   SELECT 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte
      AND estado ="A";
   IF vexiste = "1" THEN
      let vcodret = "131";
      RETURN vcodret,vsigsec;
   END IF

   /*SELECT 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte; CIB20220428: se comentÃ³ el select debido a que retornaba dos datos*/
	
	SELECT LIMIT 1 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte; -- CIB20220428: se agregÃ³ LIMIT 1 esto para limitar el retorno de datos a solo 1  */

   IF vexiste = "1" THEN
      select max(secuencia) + 1 INTO vsigsec
      from   si_cte_huella
      where  numcte = pnumcte;
      /*RETURN vcodret,vsigsec; CIB20220428: se comentÃ³ el return debido a que terminaba el proceso sin agregar los datos en la tabla*/
   ELSE
      LET vsigsec = 1;
   END IF;
   BEGIN
      INSERT INTO si_cte_huella
        (numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,fech_ult_camb)
      VALUES
         (pnumcte,vsigsec,"A",pmapad,pmapai,pejecutivo,psucursal,pfecha_alta,CURRENT);
   END;
   RETURN vcodret,vsigsec;
ELIF pfuncion = "C" then
     BEGIN
        UPDATE si_cte_huella SET estado = "I",usuario_camb = pautoriza,
               fecha_camb = pfecha_alta,
	       fech_ult_camb = CURRENT
        WHERE  numcte = pnumcte and estado = "A";
        -- Agrega la Nueva Huella
        select max(secuencia) + 1 INTO vsigsec
          from   si_cte_huella
         where  numcte = pnumcte;
         IF vsigsec is null  THEN
            let vsigsec = 1;
         END IF
         INSERT INTO si_cte_huella
           (numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,fech_ult_camb)
         VALUES
           (pnumcte,vsigsec,"A",pmapad,pmapai,pejecutivo,psucursal,pfecha_alta,CURRENT);
     END;
     RETURN vcodret,vsigsec;
END IF;

RETURN vcodret,vsigsec;
END;
END PROCEDURE
DOCUMENT
"Alta, de Huella de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Mario Escobar",
"FECHA : 04/Enero/2007",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"-----------------------------------------------------",
"Autor: 90231110 - Rolando JosuÃ© UrÃ­as GarcÃ­a",
"Fecha: 28/04/2022 - CIB20220428",
"ModificaciÃ³n: Se modificÃ³ el SELECT 1 INTO vexiste FROM si_cte_huella WHERE numcte = pnumcte ya que cuando se ejecutaba retornaba el error 284",
"..............debido a que se retornaban 2 datos y en la validaciÃ³n de IF vexiste = '1' THEN select max(secuencia) + 1 INTO vsigsec from   si_cte_huella",
"..............where numcte = pnumcte RETURN vcodret,vsigsec ELSE LET vsigsec = 1; END IF; a pesar que ya estaba retornando bien, el return terminaba la ejecuciÃ³n",
"..............sin haber agregado los datos a la tabla por lo que se comentÃ³ el RETURN vcodret,vsigsec",
"Sustento: Se definio por correo electronico el dÃ­a miercoles 27 de abril por Jaime Gonzales Prado",
"Solicita: Jaime Gonzales Prado",
"Folio: 1997",
"Proyecto: INC-SPCTEHUELLA284YNOINSERTA",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_guardar_bitacora_rostro_prue(pEmpresa CHAR(3), pSucursal CHAR(4), pNumCliente CHAR(20), pPromotor CHAR(8), pFecha_insert DATETIME YEAR TO SECOND,pTiempo_inicio DATETIME HOUR TO FRACTION(3),pTiempo_fin DATETIME HOUR TO FRACTION(3), tipo_rostro CHAR(2), ptipo_proceso CHAR(1),pcodigo CHAR(6),pintentos INTEGER, ipMaquina CHAR(15))
RETURNING CHAR(5) AS CodigoRetorno;
		
-- *	DEFINICION DE VARIABLES		  
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet            CHAR(5);
	
-- *	ASIGNACION DE VARIABLES
	LET	iSqlErr 		= 0;
	LET cCodRet 	= '00001';
	
-- *	CONTROL DE ERRORES
	BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
--	SET DEBUG FILE TO '/home/JA/CoppelFace/sp_guardar_bitacora_rostro.out';
--	TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	LET pEmpresa 		= TRIM(pEmpresa);
	LET pSucursal 		= TRIM(pSucursal);
	LET pNumCliente 	= TRIM(pNumCliente);
	LET pPromotor 		= TRIM(pPromotor);
	LET tipo_rostro 	= TRIM(tipo_rostro);
	LET ptipo_proceso 	= TRIM(ptipo_proceso);
	LET ipMaquina 		= TRIM(ipMaquina);
	
	--VALIDAR PARAMETROS VACIOS O NULOS
	IF NVL(pEmpresa,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pNumCliente,'') = '' OR NVL(pPromotor,'') = '' OR NVL(pFecha_insert,'') = ''
		OR NVL(pTiempo_inicio,'') = '' OR NVL(pTiempo_fin,'') = '' OR NVL(tipo_rostro,'') = '' OR NVL(ptipo_proceso,'') = ''  OR NVL(ipMaquina,'') = '' THEN
		LET cCodRet = '00002';
	ELSE

		INSERT INTO bdinteg:"informix".si_bitacora_rostro(empresa, sucursal, numcte, promotor, fecha_inserta, tiempo_inicio, tiempo_fin, tipo_rostro, tipo_proceso, codigo,hora_inicio_ms, hora_fin_ms, intentos, ip)
		VALUES(pEmpresa, pSucursal, pNumCliente, pPromotor, pFecha_insert, pTiempo_inicio, pTiempo_fin, tipo_rostro, ptipo_proceso, pcodigo,pTiempo_inicio, pTiempo_fin, pintentos, ipMaquina);
	
		LET cCodRet = '00000';
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio.........: 1433-Reconocimiento_Facial',
'Autor.........: 94565457 - Jose Angel Gaxiola Gaxiola',
'Fecha.........: 20/06/2014',
'Descripcion...: Se crea procedimiento para guardar bitacora de tiempos de coppel face en la tabla "si_bitacora_rostro".',
'Solicita......: Daniel Zambada',
'BD............: bdinteg',
'Folio: 1680 - SoporteBiometricoFacial',
'------------------------------------------------------------------------------------------',
'Autor: 95142134 Mario Gallardo',
'Fecha: 27/11/2014',
'Modificació®º Se agrega Parâ®¥tro de entrada y se agregan nuevos campos para la tabla si_bitacora_rostro ',
'Sustento: RQI 23 008 Biometria Facial.pdf',
'Solicita: Rodolfo Gomez',
'------------------------------------------------------------------------------------------',
'Autor: 97915041 RocÃ­o Vidales',
'Fecha: 17/07/2017',
'ModificaciÃ³n: Se agrega Parametro de entrada Ip para insertarlo en la tabla si_bitacora_rostro',
'Sustento: RQI 271.1 - Solicitud de Ip en Bitacora',
'Solicita: Abraham  Narvaez Jacinto',
'------------------------------------------------------------------------------------------',
'Autor: 95281495-Ernesto Aguilera',
'Fecha: 10/10/2018',
'ModificaciÃ³n: Se agrega Parametro de entrada Ip para insertarlo en la tabla si_bitacora_rostro',
'Sustento: Actualmente este procedimeinto existe en produccion, cuando se libero se comento el insert',
'al campo ip, ya que la tabla no estaba lista con ese campo. Se solicita que ya empiece a guardar la ip',
'Solicita: Abraham  Narvaez Jacinto',
'------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_ctanvl2_generadocs_pba( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER; 
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cDescErr     CHAR(50);
    DEFINE iAbierto     SMALLINT;
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE dtFechaHoy   DATE;
    DEFINE cCuenta      CHAR(20);
    DEFINE cNumCte      CHAR(20);
    DEFINE cCodRetPDF   CHAR(5);
    
    LET cCodRet1   = '000';
    LET cCodRet2   = '000';
    LET cCodRet3   = 'PROCESO FINALIZADO CORRECTAMENTE'; 
    LET iSqlErr	   = 0;
    LET iIsamErr   = 0;
    LET cDescErr   = '';
    LET iAbierto   = 0;    
    LET iContador1 = 0;
    LET iContador2 = 0;
    LET dtFechaHoy = '';
    LET cCuenta    = '';
    LET cNumCte    = '';
    LET cCodRetPDF = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctanvl2_generadocs_pba.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1   = iSqlErr;
            LET cCodRet2   = iIsamErr;
            LET cCodRet3   = cDescErr;
            LET cCuenta    = cCuenta;
            LET cNumCte    = cNumCte;
            LET cCodRetPDF = cCodRetPDF;
            IF iAbierto = 1 THEN
                ROLLBACK WORK;
                LET iAbierto = 0;
            END IF;
            RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctanvl2_generadocs_pba.out";
    TRACE ON;
    
    SELECT fecha_hoy
      INTO dtFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
     
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.num_cte
          INTO cCuenta, cNumCte
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE mae.cuenta = noc.cuenta
           AND mae.producto = '2900'
           --- AND noc.fecha_alta = dtFechaHoy
           AND mae.cuenta IN('29000000004','29004742417')
        
        BEGIN WORK;
        LET iAbierto = 1;
        
        LET iContador1 = iContador1 + 1;
        
        EXECUTE PROCEDURE bdinteg:sp_ctanvl2_generapdf(cCuenta, cNumCte)
        INTO cCodRetPDF;
        
        IF cCodRetPDF = '000' THEN
            LET iContador2 = iContador2 + 1;
        END IF;
        
        COMMIT WORK;
        LET iAbierto = 0;
        
        LET cCuenta    = '';
        LET cNumCte    = '';
        LET cCodRetPDF = '';
    END FOREACH;
    
    END; 
    
    RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
    
END PROCEDURE;