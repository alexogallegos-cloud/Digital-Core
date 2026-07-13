CREATE PROCEDURE "informix".cancelatarjeta(pEmpresa CHAR(3), 
                 pCuenta CHAR(20), pNumTarjeta CHAR(20), 
                 pNumCte CHAR(20))

	RETURNING
	CHAR(5),
	money(14,2),
	CHAR(10); -- Codigo de retorno

	DEFINE vCodRet	  CHAR(5);
	DEFINE vActualizo INTEGER;
	DEFINE vSqlErr	  INTEGER;
    DEFINE vmonto_aut MONEY(14,2);
    DEFINE vtipo_tar  CHAR(1);
	DEFINE cFolio_canc  CHAR(10);
    DEFINE cFolio_param  CHAR(10);
    DEFINE cBinTar  CHAR(6);

	LET vcodret    = "000";
	LET vActualizo = 0;
	LET vSqlErr    = 0;
    LET vmonto_aut = 0;
    LET vtipo_tar  = "";
	LET cFolio_canc  = "";
	LET cFolio_param  = "";
	LET cBinTar  = "";

	BEGIN
		ON EXCEPTION SET vSqlErr		
			IF vSqlErr <> 0 THEN
				LET vCodRet = vSqlErr;
				RETURN TRIM(vCodRet),vmonto_aut,TRIM(cFolio_canc);
			END IF;
		END EXCEPTION;
		
   -- SET DEBUG FILE TO '/home/tmp/MireyaR/cancelatarjeta';
   -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
		-- ACTUALIZAR EL ESTADO DE LA TARJETA
		
		    SELECT valor 
			INTO cFolio_canc
			FROM "informix".sd_param
			WHERE empresa = pEmpresa
			AND cod_param = '085';
			
			LET cFolio_param = cFolio_canc::INTEGER + 1;
			LET cFolio_param = LPAD(TRIM(cFolio_param),10,'0');
			
	--DSB PAY INICIO
	LET cBinTar = SUBSTR(pNumTarjeta,1,6);

	IF TRIM(cBinTar) = '514014' THEN
		LET vcodret    = "000";
	ELSE
	--DSB PAY FIN
		
			UPDATE "informix".sd_tarjeta
			SET  status_tar = 'C', folio_canc = cFolio_canc
			WHERE empresa = pEmpresa 
			AND num_credito = pCuenta 
			AND numcte = pNumCte 
			AND num_tarjeta = pNumTarjeta;

                -- Checa el Tipo de Tarjeta por el Monto Linea = Autorizado
                SELECT tipo_tarjeta INTO vtipo_tar
                FROM   "informix".sd_tarjeta
                WHERE  num_tarjeta = pNumTarjeta;
                IF vtipo_tar = "T" THEN -- Si es Titular Saca Otorgado
                   SELECT monto_otorgado INTO vmonto_aut
                   FROM   "informix".sd_maesdos 
                   WHERE  num_credito = pCuenta;
                ELSE -- Si no toma el Monto Limite Tarjeta
                   SELECT limite_aut INTO vmonto_aut
                   FROM   "informix".sd_tarjeta
                   WHERE  num_tarjeta = pNumTarjeta;
                END IF

		-- VERIFICAR SI SE CAMBIO EL ESTADO DE LA TARJETA
		
		SELECT
			1 INTO vActualizo 
		FROM
			"informix".sd_tarjeta
		WHERE
			empresa = pEmpresa AND
			num_credito = pCuenta AND
			numcte = pNumCte AND
			num_tarjeta = pNumTarjeta AND
			status_tar = 'C';


		IF vActualizo <> 1 THEN
			LET vCodRet = "101";
			
		END IF
		
	END IF;		
		IF vCodRet = "000" THEN
		   
		  	UPDATE "informix".sd_param
			SET valor= cFolio_param
			WHERE empresa = pEmpresa
			AND cod_param = '085';
			
		END IF
		
		RETURN TRIM(vCodRet),vmonto_aut,TRIM(cFolio_canc);
	END
END PROCEDURE
DOCUMENT
'MODIFICO: Mireya Reyes',
'DESCRIPCION: Se agrega nuevo parámetro de salida, retornando el folio de cancelación, consultandolo en la tabla sd_param.', 
'FECHA DE MODIFICACIÓN: 29 de Julio del 2014',
'VERSION: 20140729.1726',
'BD: BDICRED';

CREATE PROCEDURE "informix".consfircredper2(pEmpresa char(3), pNumeroCredito char(20), pNumeroCte char(20))
--DATOS A REGRESAR
RETURNING

CHAR(5),    -- Codigo de retorno
CHAR(20),   -- # Cliente
CHAR(26),   -- Apellido paterno
CHAR(26),   -- Apellido materno
CHAR(26),   -- Nombre 1
CHAR(26),   -- Nombre 2
CHAR(13),   -- RFC
CHAR(20),   -- # Tarjeta
DATE,    -- ExpiraciÃ³n
MONEY(14,2), -- Limite de retiro maximo por mes
CHAR(1),    -- Status tarjeta
CHAR(1),    -- Tipo de cliente
CHAR(10),   -- Fecha de Nacimiento
CHAR(4),    --Producto de Credito
CHAR(2),    -- Dia de Corte
MONEY(14,2); -- Monto Solicitado

--DECLARACION DE VARIABLES

DEFINE vCodRet          char(5);
DEFINE vNumCte          char(20);
DEFINE vApell_Paterno   char(26);
DEFINE vApell_Materno   char(26);
DEFINE vNombre1         char(26);
DEFINE vNombre2         char(26);
DEFINE vRfc             char(13);
DEFINE vNumTarjeta      char(20);
DEFINE vExpiracion      DATE;
DEFINE vLimRetXmes      money(14, 2);
DEFINE vStatusCta       char(2);
DEFINE vNumProducto		char(4);
DEFINE vStatusTarj      char(1);
DEFINE vTipoCte         char(1);
DEFINE vFechaNacimiento char(10);
DEFINE vProductoCredito char(4);
DEFINE vFechaAut        DATE;
DEFINE vDiaCorte        char(2);
DEFINE vCantReg         smallint;
DEFINE vMontoSol        money(14, 2);
DEFINE vSecuencia       integer;
DEFINE iSqlErr  		INTEGER;
DEFINE vPRoTar       	char(2);
DEFINE vFechaExp       	char(4);
							  

--INICIALIZACION DE VARIABLES

LET vCodRet = "00000";
LET vNumCte = "";
LET vApell_Paterno = "";
LET vApell_Materno = "";
LET vNombre1 = "";
LET vNombre2 = "";
LET vRfc = "";
LET vNumTarjeta = "";
LET vExpiracion = "";
LET vLimRetXmes = 0.0;
LET vStatusCta = "";
LET vNumProducto = "";
LET vStatusTarj = "";
LET vTipoCte = "";
LET vFechaNacimiento = "";
LET vProductoCredito = "";
LET vDiaCorte = "";
LET vCantReg = 0;
LET vMontoSol = 0.0;
LET vSecuencia = 0;
LET iSqlErr = 0;
LET vPRoTar = 0;
LET vFechaExp = "";



--SET DEBUG FILE TO '/home/sysifx/respaldosbd/JesusRLopez/789/consfircredper2.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET vCodRet = iSqlErr;
			RETURN vCodRet,vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vProductoCredito, vDiaCorte, vMontoSol;
		END IF;
	END EXCEPTION;				

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--DSB PAY INICIO
LET vPRoTar = SUBSTR(pNumeroCredito,1,2);  

IF vPRoTar = '65' THEN

	SELECT 
		NVL(a.numcte,''), NVL(a.apell_paterno,''), NVL(a.apell_materno,''), NVL(a.Nombre1,''), NVL(a.Nombre2,''), NVL(a.rfc,''), NVL(b.fecha_nac,'')
	INTO
		vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vFechaNacimiento
	FROM
		bdinteg:"informix".si_cliente a,	
		bdinteg:"informix".si_ctepf b
	WHERE
		a.numcte  = b.numcte AND
		a.numcte  = pNumeroCte;
		
	SELECT dia_cuota,num_producto 
	INTO vDiaCorte, vProductoCredito 
	FROM bdicred:"informix".sd_definicion WHERE num_producto = '6500';
	
	FOREACH	
		SELECT LIMIT 1 Tac.numtarjeta,Tar.fechaexp
		INTO vNumTarjeta, vFechaExp
		FROM intercard: "informix".TarjetaCuenta Tac, intercard:"informix".Tarjeta Tar
		WHERE Tac.NumTarjeta = Tar.NumTarjeta and Tac.numcuenta = pNumeroCredito ORDER by fechaasignacion DESC
	END FOREACH;
	
	LET vExpiracion = SUBSTR(vFechaExp,3,2)||'/01/20'||SUBSTR(vFechaExp,1,2) ;

	
	RETURN vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vProductoCredito, vDiaCorte, vMontoSol;	
		
		CREATE TEMP TABLE tempCredito(
		CodRet char(5),
		NumCte char(20),
		Apell_Paterno char(26),
		Apell_Materno char(26),
		Nombre1 char(26),
		Nombre2 char(26),
		Rfc char(13),
		NumTarjeta char(20),
		Expiracion DATE,
		LimRetXmes money(14, 2),
		StatusTarj char(1),
		TipoCte char(1),
		FechaNacimiento char(10),
		ProductoCredito char(4)
		);
	

		
		 IF NVL(vNumCte,'') <> '' THEN
			INSERT INTO tempCredito(CodRet, NumCte, Apell_Paterno, Apell_Materno, Nombre1, Nombre2, Rfc, NumTarjeta, Expiracion, LimRetXmes, StatusTarj, TipoCte, FechaNacimiento, ProductoCredito)	
			VALUES (vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vProductoCredito);	
	    END IF



ELSE
--DSB PAY FIN		

		
--IF EXISTS (SELECT * FROM bdicred: sd_maecred WHERE num_credito = pNumeroCredito AND status_cred = 'AA') THEN
	SELECT
		NVL(a.numcte,''), a.status_cred, NVL(a.num_producto,''), NVL(b.apell_paterno,''), NVL(b.apell_materno,''), NVL(b.Nombre1,''), NVL(b.Nombre2,''), NVL(b.rfc,''), NVL(d.fecha_nac,''), a.fecha_apertura
	INTO
		vNumCte, vStatusCta, vNumProducto, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vFechaNacimiento, vFechaAut
	FROM
		bdicred: "informix".sd_maecred a,
		bdicred: "informix".sd_maesdos mae,
		bdinteg:"informix".si_cliente b,	
		bdinteg:"informix".si_ctepf d
	WHERE
		a.empresa = pEmpresa AND 
		a.num_credito = pNumeroCredito AND 
		a.empresa = mae.empresa AND 
		a.num_credito = mae.num_credito AND 
		a.status_cred IN ('AA','E1') AND
		(mae.monto_vencido + mae.mto_venc_trasp) = 0 AND
		a.numcte  = b.numcte AND
		a.numcte  = d.numcte;
--END IF;

	IF NVL(vNumCte,'') = '' THEN
--RQM 10 1473 Hallazgos Banxico se contempla producto para que siempre devuelva el dÃ­a corte correcto
	
		SELECT num_producto
		  INTO vNumProducto
		  FROM bdicred: "informix".sd_maecred 
		 WHERE empresa = pEmpresa
		   AND num_credito = pNumeroCredito;


		SELECT dia_cuota 
		  INTO vDiaCorte 
		  FROM bdicred:"informix".sd_definicion 
		 WHERE num_producto = vNumProducto;			
		 
		LET vCodRet  = "1342";
		LET vNumCte  = "";
		LET vApell_Paterno  = "";
		LET vApell_Materno  = "";
		LET vNombre1 = "";
		LET vNombre2 = "";
		LET vRfc     = "";
		LET vNumTarjeta = "";
		LET vExpiracion = "";
		LET vLimRetXmes  = 0;
		LET vStatusTarj = "";
		LET vTipoCte = "";
		LET vFechaNacimiento = "";
		LET vProductoCredito = "";

		RETURN vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vProductoCredito, vDiaCorte, vMontoSol;		 
	END IF;

CREATE TEMP TABLE tempCredito(
	CodRet char(5),
	NumCte char(20),
	Apell_Paterno char(26),
	Apell_Materno char(26),
	Nombre1 char(26),
	Nombre2 char(26),
	Rfc char(13),
	NumTarjeta char(20),
	Expiracion DATE,
	LimRetXmes money(14, 2),
	StatusTarj char(1),
	TipoCte char(1),
	FechaNacimiento char(10),
	ProductoCredito char(4)
);

SELECT dia_cuota INTO vDiaCorte FROM bdicred:"informix".sd_definicion WHERE num_producto = vNumProducto;
SELECT NVL(MAX(secuencia), 0) INTO vSecuencia FROM bdicred:sd_tarjeta WHERE num_credito = pNumeroCredito AND numcte = vNumCte;

IF EXISTS (SELECT * FROM bdicred:sd_tarjeta WHERE num_credito = pNumeroCredito AND status_tar in ('A','I','C') AND secuencia = vSecuencia) THEN
	SELECT
		sd_tar.tipo_tarjeta, sd_tar.num_tarjeta, sd_tar.expiracion, sd_tar.limite_aut, sd_tar.status_tar
	INTO
		vTipoCte, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj
	FROM
		bdicred:sd_tarjeta AS sd_tar
	WHERE			
		sd_tar.empresa = pEmpresa AND
		sd_tar.num_credito = pNumeroCredito AND
		sd_tar.numcte = vNumCte AND
		--sd_tar.status_tar  != 'C' AND
        	--sd_tar.status_tar  != 'I' AND AAME RQI 27 221 Para que muestre estatus I
		sd_tar.tipo_tarjeta = 'T' AND
		sd_tar.secuencia = vSecuencia;
		
		INSERT INTO tempCredito(CodRet, NumCte, Apell_Paterno, Apell_Materno, Nombre1, Nombre2, Rfc, NumTarjeta, Expiracion, LimRetXmes, StatusTarj, TipoCte, FechaNacimiento, ProductoCredito)	
		VALUES (vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vNumProducto);		
END IF;

-- OBTENER LOS DATOS DEL FIRMANTE
FOREACH
	SELECT DISTINCT sd_tar.numcte INTO vNumCte FROM bdicred:sd_tarjeta AS sd_tar, bdinteg:si_cliente AS si_cte, bdinteg:si_ctepf AS si_pf, bdicred:sd_maecred as sd_mae
	WHERE sd_tar.empresa = pEmpresa AND sd_tar.num_credito = pNumeroCredito AND sd_tar.numcte != pNumeroCte AND sd_tar.numcte = si_cte.numcte AND sd_tar.status_tar in ('A','I','C') AND
	si_cte.empresa = pEmpresa AND sd_tar.numcte = si_pf.numcte AND sd_mae.num_credito = pNumeroCredito AND sd_tar.tipo_tarjeta = 'A'
	
	SELECT NVL(MAX(secuencia), 0) INTO vSecuencia FROM bdicred:sd_tarjeta WHERE num_credito = pNumeroCredito AND numcte = vNumCte;
	
	SELECT
		sd_tar.numcte, sd_tar.num_tarjeta, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_pf.fecha_nac, 
		sd_mae.num_producto, sd_tar.expiracion, sd_tar.limite_aut, sd_tar.status_tar, sd_tar.tipo_tarjeta
	INTO
		vNumCte, vNumTarjeta, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vFechaNacimiento, 
		vProductoCredito, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte		 
	FROM
		bdicred:sd_tarjeta AS sd_tar,
		bdinteg:si_cliente AS si_cte,
		bdinteg:si_ctepf AS si_pf,
		bdicred:sd_maecred as sd_mae
	WHERE
		sd_tar.empresa =  pEmpresa AND
		sd_tar.num_credito =  pNumeroCredito AND
		sd_tar.numcte != pNumeroCte AND
		sd_tar.numcte = si_cte.numcte AND
		--sd_tar.status_tar  != 'C' AND
        	--sd_tar.status_tar  != 'I' AND  AAME RQI 27 221 Para que muestre estatus I
		si_cte.empresa = pEmpresa AND
		sd_tar.numcte = si_pf.numcte AND
		sd_mae.num_credito = pNumeroCredito	AND
		sd_tar.tipo_tarjeta = 'A' AND
		sd_tar.secuencia = vSecuencia;
		
	

        IF NVL(vNumCte,'') <> '' THEN
			INSERT INTO tempCredito(CodRet, NumCte, Apell_Paterno, Apell_Materno, Nombre1, Nombre2, Rfc, NumTarjeta, Expiracion, LimRetXmes, StatusTarj, TipoCte, FechaNacimiento, ProductoCredito)	
			VALUES (vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vProductoCredito);	
	    END IF
		
		
END FOREACH;

END IF; --DSB PAY 

FOREACH	
	SELECT CodRet, NumCte, Apell_Paterno, Apell_Materno, Nombre1, Nombre2, Rfc, NumTarjeta, Expiracion, LimRetXmes, StatusTarj, TipoCte, FechaNacimiento, ProductoCredito 
	  INTO vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vProductoCredito
	FROM tempCredito
		
		LET vCantReg = vCantReg + 1;
		
		RETURN vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vProductoCredito, vDiaCorte, vMontoSol WITH RESUME;
END FOREACH;

DROP TABLE tempCredito;

			  
IF vCantReg = 0 THEN
	LET vCodRet  = "154";
	LET vNumCte  = "";
	LET vApell_Paterno  = "";
	LET vApell_Materno  = "";
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vRfc     = "";
	LET vNumTarjeta = "";
	LET vExpiracion = "";
	LET vLimRetXmes  = 0;
	LET vStatusTarj = "";
	LET vTipoCte = "";
	LET vFechaNacimiento = "";
	LET vProductoCredito = "";

	RETURN vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vNumTarjeta, vExpiracion, vLimRetXmes, vStatusTarj, vTipoCte, vFechaNacimiento, vProductoCredito, vDiaCorte, vMontoSol;
END IF

END
END PROCEDURE
DOCUMENT
'Especificacion: Se modifico para que consulte las cuentas de credito en la tabla intercard:tarjeta, tarjetas activas y canceladas',
'Base de Datos : bdicred',
'AUTOR : Scarlett Mendoza',
'FECHA : 17/11/2017';

create procedure "informix".sp_cancelatarj(pempresa char (3),ptarj char(20),ptipo char(1))
returning char(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
define vtarjeta char(20);
define vstatusint char(3);
define vstatust char(3);
define cBinTar char(6);

LET vcodret = "002";
LET vsqlerr = 0;
LET vtarjeta ='';
let vstatust ='';
let vstatusint ='';
let cBinTar ='';

BEGIN

ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET debug file to "/tmp/cantarj.out";
--trace on;

if pempresa='' or pempresa is null  or ptarj ='' or ptarj is null or ptipo ='' or ptipo is null then 
    let vcodret='0001';
    return vcodret;
end if;


if ptipo='1' then 
--credito
    SELECT  codstatustarjeta into vstatusint  FROM intercard:tarjeta WHERE numtarjeta=ptarj;
    
    let vstatusint=nvl(vstatusint,'');
	
--DSB PAY INICIO
LET cBinTar = SUBSTR(ptarj,1,6);

IF TRIM(cBinTar) = '514014' THEN

	 if vstatusint <> 'CAN' and vstatusint<> 'INA'  then 
		UPDATE intercard:"informix".tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=ptarj;
	 END IF;

Let vcodret='00000';
ELSE
--DSB PAY FIN

    if vstatusint = 'CAN'  then 
      SELECT status_tar into vstatust FROM bdicred:sd_tarjeta WHERE num_tarjeta=ptarj;
         let vstatust=nvl(vstatust,'');
         if vstatust <>'C' then
            UPDATE bdicred:sd_tarjeta SET status_tar='C'  WHERE  num_tarjeta=ptarj;

         end if;
         
        Let vcodret='00000';
    elif   vstatusint<> 'INA'  then 
        if  vstatusint = 'ACT' then
             SELECT status_tar into vstatust FROM bdicred:sd_tarjeta WHERE num_tarjeta=ptarj;
             let vstatust=nvl(vstatust,'');
             if vstatust ='C' then
                UPDATE intercard:tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=ptarj;
            end if;   
        else
        
        UPDATE intercard:tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=ptarj;
        
        end if;        
        Let vcodret='00000';
    end if;
	
END IF;


elif ptipo='2' then 

   SELECT  codstatustarjeta into vstatusint  FROM intercard:tarjeta WHERE numtarjeta=ptarj;
    
    let vstatusint=nvl(vstatusint,'');

     if vstatusint = 'CAN'  then 

         SELECT status_tar into vstatust FROM bdicheq:sc_tarjeta WHERE num_tarjeta=ptarj;
         let vstatust=nvl(vstatust,'');
         if vstatust <>'C' then
            UPDATE bdicheq:sc_tarjeta SET status_tar='C'  WHERE  num_tarjeta=ptarj;

           
         end if;
          Let vcodret='00000';

    elif   vstatusint <> 'INA' then 
        let vstatusint=vstatusint;
        if ( vstatusint = 'ACT') then 
             SELECT status_tar into vstatust FROM bdicheq:sc_tarjeta WHERE num_tarjeta=ptarj;
             let vstatust=nvl(vstatust,'');
                if vstatust ='C' then
                     UPDATE intercard:tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=ptarj;
                end if
            --
        else
        UPDATE intercard:tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=ptarj;
        end if
        Let vcodret='00000';
    end if;
end if;

 return vcodret;
end
end procedure;