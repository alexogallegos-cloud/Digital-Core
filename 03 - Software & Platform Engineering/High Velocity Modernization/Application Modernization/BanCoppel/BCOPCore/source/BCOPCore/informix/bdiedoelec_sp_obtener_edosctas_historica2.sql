CREATE PROCEDURE "informix".sp_obtener_edosctas_historica2
(
	pEmpresa CHAR(3),
	pNoCliente CHAR(9),
	pNoCuenta CHAR(20),
	pFechaInicio DATE,
	pFechaHoy DATE
)
RETURNING 
CHAR(6) AS codRetorno,
CHAR(20) AS cuenta,
CHAR(20) AS tarjeta,
CHAR(4) AS sucursal,
CHAR(45) AS producto,
DATE AS fecha_emision,
CHAR(20) AS estatus;


DEFINE cCodRet CHAR(6);
DEFINE cCuenta CHAR(20);
DEFINE cTarjeta CHAR(20);
DEFINE cSucursal CHAR(4);
DEFINE cProducto  CHAR(45);
DEFINE dFecha_emision DATE;
DEFINE cEstatus CHAR(20);
DEFINE iSql_err INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cTipoCuenta CHAR(2);
DEFINE iExist INTEGER;
DEFINE tiempo INTEGER;
DEFINE iAnio INTEGER;
DEFINE iDate DATE;
DEFINE iDate2 DATE;
DEFINE i INTEGER;
DEFINE pfecha_alta DATE;
DEFINE iMes INTEGER;
DEFINE iAnio2 INTEGER;
	



LET cCodRet = '000000';
LET cCuenta = '';
LET cTarjeta = '';
LET cSucursal = '';
LET cProducto  = '';
LET dFecha_emision = TODAY;
LET cEstatus = '';
LET cTipoCuenta = '';
LET iSql_err	 = 0;
LET iIsamErr	 = 0;
lET iExist = 0;
LET tiempo=0;
LET iDate='';
LET iDate2='';
LET i=0;
LET pfecha_alta=TODAY;
LET iMes = 0;
LET iAnio2 = 0;


BEGIN
    
    ON EXCEPTION SET iSql_err,iIsamErr
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus;
        END IF;
    END EXCEPTION;  
    
     --SET DEBUG FILE TO "/tmp/anj/edocta.sql";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	

	IF NVL(pEmpresa,'') <> '' AND NVL(pNoCliente,'') <> '' AND NVL(pNoCuenta,'') <> '' AND NVL(pFechaInicio,'') <> '' AND NVL(pFechaHoy,'') <> '' THEN	
		LET cTipoCuenta = SUBSTR(pNoCuenta,1,2);
			SELECT (CASE WHEN valor like '%'||cTipoCuenta||'%' THEN 1 ELSE 0 END) TarjetaCreditos 
			INTO iExist
			FROM bdicred:"informix".sd_param WHERE cod_param IN('059');
		  IF (iExist > 0) THEN--DSB 23/01/2019
			FOREACH SELECT a.cuenta, c.num_tarjeta, e.sucursal, a.producto||' '||d.nombre_prod, b.fecha_emision, 'EMITIDO' as estatus 
			INTO cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus
			FROM bdiedoelec:"informix".edelec_alta_serv a, bdicred@pld_tcp:sd_encabezado2_edocta_clon 
			b, bdicred:"informix".sd_tarjeta c, bdicred:"informix".sd_definicion d, bdicred:"informix".sd_maecred e 
			WHERE a.empresa = pEmpresa AND  c.empresa = pEmpresa AND  d.empresa = pEmpresa AND e.empresa = pEmpresa AND a.cuenta = b.num_credito 
			AND b.num_credito = a.cuenta AND b.num_credito = c.num_credito AND a.producto = d.num_producto 
			AND e.num_credito = a.cuenta AND a.cuenta = pNoCuenta AND c.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE numcte = pNoCliente AND num_credito = pNoCuenta AND tipo_tarjeta = 'T')
			AND b.fecha_emision BETWEEN pFechaInicio AND pFechaHoy ORDER BY b.fecha_emision
			
				RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
				
			END FOREACH;
				
		ELIF cTipoCuenta = '61' OR cTipoCuenta = '63' THEN
		
			FOREACH SELECT a.cuenta, e.sucursal, a.producto||' '||d.nombre_prod,b.fecha_emision, 'EMITIDO' as 
			estatus INTO cCuenta,cSucursal,cProducto,dFecha_emision,cEstatus FROM bdiedoelec:"informix".edelec_alta_serv a, bdicred@pld_tcp:sd_encabezado2_edoctacrd b, 
			bdicred:"informix".sd_definicion d, bdicred:"informix".sd_maecredcrd e  WHERE a.cuenta = b.num_credito AND b.num_credito 
			= a.cuenta  AND a.producto = d.num_producto AND e.num_credito = a.cuenta  AND a.cuenta =pNoCuenta   AND b.fecha_emision BETWEEN pFechaInicio AND pFechaHoy ORDER BY b.fecha_emision 

				RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
				
			END FOREACH;
			
		ELIF cTipoCuenta <> '61' AND cTipoCuenta <> '63' AND cTipoCuenta <> '60' THEN
		/*Modificado para mostrar hasta 3 años atras*/
            let pFechaHoy=pFechaHoy;
            let pfecha_alta=(select fecha_alta from bdicheq:sc_maenoc  where cuenta=pNoCuenta);
            
			--select mdy(month(pFechaHoy),day(fecha_alta),YEAR(pFechaHoy)) into iDate from bdicheq:sc_maenoc  where cuenta=pNoCuenta; -- tomamos la fecha de hoy pero con el dia de la fecha de alta como base
            select day(fecha_alta)into iDate from bdicheq:sc_maenoc where cuenta=pNoCuenta;            let iMes=month(pFechaHoy);
            let iAnio2=YEAR(pFechaHoy);
            
            IF iMes=2 THEN
               IF iDate>28 then
                  LET iDate=28;
               end if;
            END IF;

            let pfechahoy= MDY(iMes,iDate,iAnio2);

			select FLOOR(((pFechaHoy-pFechaInicio)/365.25)*12) into tiempo from bdicheq:sc_maenoc where cuenta=pNoCuenta; --calculamos la cantidad de meses que hay de la fecha de alta al dia de hoy
			
if pfecha_alta <= pFechaHoy THEN --si la fecha base es menor a la fecha de hoy
 if tiempo <=36 then -- si la cuenta tiene menos de 3 años
FOR i = 1 to tiempo	--mostramos mes por mes		
		FOREACH		
		SELECT  a.cuenta, c.num_tarjeta, b.sucursal, b.producto||' '|| d.nombre, ADD_MONTHS(pFechaHoy,-i) as fecha, 'EMITIDO' as estatus
			INTO cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus
			FROM bdicheq:"informix".sc_maenoc a
			left JOIN bdicheq:"informix".sc_maechq b on a.cuenta=b.cuenta
			left JOIN bdicheq:"informix".sc_tarjeta c on a.cuenta=c.cuenta and c.status_tar='A'
			left JOIN bdicheq:"informix".sc_producto d on b.producto=d.producto
			WHERE a.cuenta=pNoCuenta
			  AND c.numcte= pNoCliente
			ORDER BY 5 desc limit tiempo
		 RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
end FOREACH;

END FOR;
elif tiempo >36 THEN -- si la cuenta tiene mas de 3 años entonces limitamos a 36 meses
FOR i = 1 to 37	--mostramos mes por mes		
		FOREACH		
		SELECT  a.cuenta, c.num_tarjeta, b.sucursal, b.producto||' '|| d.nombre, ADD_MONTHS(pFechaHoy,-i) as fecha, 'EMITIDO' as estatus
			INTO cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus
			FROM bdicheq:"informix".sc_maenoc a
			left JOIN bdicheq:"informix".sc_maechq b on a.cuenta=b.cuenta
			left JOIN bdicheq:"informix".sc_tarjeta c on a.cuenta=c.cuenta and c.status_tar='A'
			left JOIN bdicheq:"informix".sc_producto d on b.producto=d.producto
			WHERE a.cuenta=pNoCuenta
			  AND c.numcte= pNoCliente
			ORDER BY 5 desc limit tiempo
		 RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
end FOREACH;

END FOR;
end if;
elif iDate > today THEN --si la fecha base es mayor a la fecha de hoy
 if tiempo <=36 then -- si la cuenta tiene menos de 3 aÃÂ±os
FOR i = 2 to tiempo	--mostramos mes por mes		
		FOREACH		
		SELECT  a.cuenta, c.num_tarjeta, b.sucursal, b.producto||' '|| d.nombre, ADD_MONTHS(pFechaHoy,-i) as fecha, 'EMITIDO' as estatus
			INTO cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus
			FROM bdicheq:"informix".sc_maenoc a
			left JOIN bdicheq:"informix".sc_maechq b on a.cuenta=b.cuenta
			left JOIN bdicheq:"informix".sc_tarjeta c on a.cuenta=c.cuenta and c.status_tar='A'
			left JOIN bdicheq:"informix".sc_producto d on b.producto=d.producto
			WHERE a.cuenta=pNoCuenta
			  AND c.numcte= pNoCliente
			ORDER BY 5 desc limit tiempo
		 RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
end FOREACH;

END FOR;
elif tiempo >36 THEN -- si la cuenta tiene mas de 3 años entonces limitamos a 36 meses
FOR i = 2 to 38	--mostramos mes por mes		
		FOREACH		
		SELECT  a.cuenta, c.num_tarjeta, b.sucursal, b.producto||' '|| d.nombre, ADD_MONTHS(pFechaHoy,-i) as fecha, 'EMITIDO' as estatus
			INTO cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus
			FROM bdicheq:"informix".sc_maenoc a
			left JOIN bdicheq:"informix".sc_maechq b on a.cuenta=b.cuenta
			left JOIN bdicheq:"informix".sc_tarjeta c on a.cuenta=c.cuenta and c.status_tar='A'
			left JOIN bdicheq:"informix".sc_producto d on b.producto=d.producto
			WHERE a.cuenta=pNoCuenta
			  AND c.numcte= pNoCliente
			ORDER BY 5 desc limit tiempo
		 RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
end FOREACH;

END FOR;
end if;

end if;


		
		
		
		
		
		
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000003';
		END IF;
		
	ELSE
		LET cCodRet = '000002';
	END IF;
	IF cCodret <> '000000' THEN
		RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus;
	END IF;

END;
END PROCEDURE
DOCUMENT
"DESCRIPCION: Reaaliza consulta de Cliente para regresar la información de sus cuentas de créditos 7000 y 8100 y todas las futuras tarjetas de credito",
"Folio: 531",
"Autor: 97877352 Jesús Alberto Rubio Lugo",
"Fecha: 23/01/2019",
"Solicitante: Cutberto Gonzalez",
"BD:bdiedoelec";

CREATE PROCEDURE "informix".sp_consultanombre_serv_edoctaelec
(
   pEmpresa CHAR(3),
   pNumCte CHAR(9),
   pNumCuenta CHAR(20),
   pNumTarjeta CHAR(20)
)
RETURNING CHAR(6) AS CodRet , CHAR(9) AS NumCliente, CHAR(107) AS NombreCte, CHAR(1) AS Status;

DEFINE	cCodRet			CHAR(6);
DEFINE	iSql_err		INTEGER;
DEFINE	cNombre1		CHAR(26);
DEFINE	cNombre2		CHAR(26);
DEFINE	cApellPat		CHAR(26);
DEFINE	cApellMat		CHAR(26);
DEFINE	cStatusServElec	CHAR(1);
DEFINE	cNombreCompleto	CHAR(107);
DEFINE	cBinTar			CHAR(6);DEFINE	cProTar			CHAR(6);
LET	cCodRet			= '000000';
LET	iSql_err		= 0;
LET	cNombre1		= "";
LET	cNombre2		= "";
LET	cApellPat		= "";
LET	cApellMat		= "";  
LET	cStatusServElec	= "";
LET	cNombreCompleto	= "";
LET	cBinTar			= "";LET	cProTar			= "";
BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cStatusServElec;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/home/sysifx/respaldosbd/JesusRLopez/789/sp_consultanombre_serv_edoctaelec.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND (NVL(pNumTarjeta,'') <> '' OR NVL(pNumCte,'')<> '' OR NVL(pNumCuenta,'')<> '') THEN

		IF NVL(pNumCuenta,'') <> '' THEN
		
			--TDC PAY INICIO
			LET cProTar = SUBSTR(pNumCuenta,1,2); 
			
			IF cProTar ='65' THEN
			
				SELECT LIMIT 1 numcliente 
				INTO pNumCte
				FROM intercard: "informix".TarjetaCuenta Tac, intercard: "informix".Tarjeta Tar
				WHERE Tac.NumTarjeta = Tar.NumTarjeta
				AND Tac.numcuenta = pNumCuenta;
			
			ELSE
			--TDC PAY FIN

				 SELECT LIMIT 1 num_cte		--verifica si es tarjeta de debito
				 INTO pNumCte
				 FROM bdicheq:"informix".sc_maechq
				 WHERE empresa = pEmpresa
				 AND cuenta = pNumCuenta;
			 
			END IF;
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN

				SELECT LIMIT 1 numcte	--verifica si es tarjeta de credito
				INTO pNumCte
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				AND num_credito = pNumCuenta;

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN

					SELECT LIMIT 1 numcte	--verifica si es prestamo o reestructura
					INTO pNumCte
					FROM bdicred:"informix".sd_maecredcrd
					WHERE empresa = pEmpresa
					AND num_credito = pNumCuenta;

					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '000003';
					END IF;
				END IF;
			END IF;
		END IF;

		IF NVL(pNumTarjeta,'') <> '' THEN		
		
			--TDC PAY INICIO
			LET cBinTar = SUBSTR(pNumTarjeta,1,6); 
			
			IF cBinTar ='514014' THEN
			
				SELECT LIMIT 1 numcliente
				INTO pNumCte
				FROM intercard: "informix".Tarjeta 
				WHERE NumTarjeta  = pNumTarjeta
				AND codstatustarjeta ='ACT';

			ELSE
			--TDC PAY INICIO

				SELECT LIMIT 1 numcte
				INTO pNumCte
				FROM bdicheq:"informix".sc_tarjeta
				WHERE empresa = pEmpresa
				AND num_tarjeta = pNumTarjeta
				AND status_tar = "A";
				
			END IF;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				--AAME RQI 27 221 Se contempla la consulta de Tarjetas Inactivas
				SELECT LIMIT 1 numcte
				INTO pNumCte
				FROM bdicred:"informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_tarjeta = pNumTarjeta
				AND status_tar IN ("A","I");

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '000002';
				END IF;
			END IF;
		END IF;

		IF NVL(pNumCte,'') <> '' THEN
			SELECT nombre1, nombre2, apell_paterno, apell_materno
			INTO cNombre1, cNombre2, cApellPat, cApellMat
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pNumCte;

			LET cNombreCompleto = TRIM(cNombre1) || " " || TRIM(cNombre2) || " " || TRIM(cApellPat) ||" " || TRIM(cApellMat);

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000002';
			ELSE
				SELECT LIMIT 1 status_serv_elec
				INTO cStatusServElec
				FROM bdiedoelec:"informix".edelec_alta_serv
				WHERE numcte = pNumCte
				AND status_serv_elec = 'A';

				IF  DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cStatusServElec = 'I';
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet = '000001'; --parametros vacios
	END IF;
	
	RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cStatusServElec;
END;
END PROCEDURE
DOCUMENT
"Folio:1602",
"Autor:95975071 Jairo Valdez",
"Fecha:29/04/2014",
"Modificación: Se crea SP para obtener en base al número de cliente o tarjeta el nombre del cliente y el status del servicio electronico de edo. de cta.",
"Sustento: RQI 12 231 Edo Cta Emisión Consulta Disponibilización y Respaldo OFI.pdf",
"Solicita: Rodolfo Gómez ",
"BD: bdiedoelec";

CREATE PROCEDURE "informix".sp_ins_user_paws_bpi (pempresa char(3),pnumcte char(20), pass_first_part char (4), puser_modif varchar(20)) 
    RETURNING CHAR(5) AS CodigoRetorno
 
 --******************************************
  --Se crea spl con el nombre modificado
  --RQI CheckmarxB18  BPI
  --Gabrieal Aguilar  
  --10-03-2025  
--***********************************************
  
    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_pass_second_part   CHAR (4);
	DEFINE encry_pass           VARCHAR(20);
	
	DEFINE vnumcte1         		VARCHAR(20);
	DEFINE vnumcte2         		VARCHAR(20);
	DEFINE vcodret1 			CHAR(5);
	
	LET vnumcte1 = '';
	LET vnumcte2 = '';
	LET vcodret1 = '';

   -- SET DEBUG FILE TO  "sp_ins_user_paws_bpi.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET encry_pass = "";

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		SELECT FIRST 1 numcte  
		  INTO vnumcte1
		  FROM bdiedoelec:edelec_alta_serv 
		  WHERE numcte = pnumcte;
		  
		SELECT FIRST 1 numcte  
		  INTO vnumcte2
		  FROM bdiedoelec:edelec_constancia 
		  WHERE numcte = pnumcte;
		
		IF ((vnumcte1 IS NULL OR vnumcte1 = '') AND (vnumcte2 IS NULL OR vnumcte2 = '')) THEN
		
			LET v_sCodRet = '001'; --Cliente No se encuentra en el Alta del Servicio
			RETURN v_sCodRet;
					
		END IF 
		
		SELECT password  
		  INTO encry_pass
		  FROM bdinteg:si_ejecut 
		  WHERE ejecutivo = 'informix';

		SET encryption password encry_pass;
	
		SELECT SUBSTR(sp_random(),1,4) 
		  INTO v_pass_second_part
		  FROM bdiedoelec:systables where tabname = "systables";

		/*
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','idplant',pnumcte,null,null,'1',v_pass_second_part,null,null,null,null,null,null,null,null,null,null,null)			
		INTO vcodret1;	
		
		IF vcodret1 <> '00000' THEN
		
			LET v_sCodRet=vcodret1;
			RETURN v_sCodRet; 
		
		END IF
		*/
		
		IF EXISTS (SELECT numcte FROM bdiedoelec:edelec_usr_pass WHERE numcte = pnumcte) THEN
		
			UPDATE bdiedoelec:edelec_usr_pass 
			   SET pass_first_part = encrypt_aes(pass_first_part), 
			       pass_sec_part = encrypt_aes(v_pass_second_part), 
				   fecha_ultima_mod = TODAY, 
				   user_modif = puser_modif
			 WHERE numcte = pnumcte;
			 
		ELSE
		
			INSERT INTO bdiedoelec:edelec_usr_pass (empresa,numcte,pass_first_part,pass_sec_part,fecha_alta,fecha_ultima_mod,user_modif)
				 VALUES (pempresa,pnumcte,encrypt_aes(pass_first_part),encrypt_aes(v_pass_second_part),TODAY,TODAY,puser_modif);
				 
		END IF
			
		RETURN v_sCodRet;    

    END
END PROCEDURE;