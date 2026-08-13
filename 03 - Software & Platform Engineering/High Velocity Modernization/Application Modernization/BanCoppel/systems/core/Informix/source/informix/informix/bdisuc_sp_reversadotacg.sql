CREATE PROCEDURE "informix".sp_reversadotacg(folioOper CHAR (8),cSucursal CHAR(4),Cantidad MONEY (14,2))
RETURNING
CHAR(5) AS cCodRet;

--*DEFINICION DE VARIABLES*--
DEFINE cCodRet				  CHAR (5);
DEFINE cSqlErr				  SMALLINT;
DEFINE valStatus        	  CHAR (2);

--*ASIGNACION DE VARIABLES*--
LET cSqlErr					= 0;
LET valStatus               ='';

BEGIN
	------------------------
	--*CONTROL DE ERRORES*--
	------------------------
	ON EXCEPTION SET cSqlErr
		IF cSqlErr <> 0 THEN
			let cCodRet = cSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--SET debug file to "/tmp/hector/sp_reversadotacg.out";
	--trace on;
	
		--*SE VALIDA LOS PARAMETROS DE ENTRADA*--
		IF NVL(TRIM(folioOper),'')= '' OR NVL(TRIM(cSucursal),'')= '' OR Cantidad  IS NULL OR Cantidad <= 0.00 OR Cantidad = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet;
		END IF;
			--*SE OBTIENE EL FOLIO DE LA DOTACION*--
			SELECT status INTO valStatus
			FROM bdisuc:ss_mae_entradasalida 
			WHERE folio_oper = folioOper 
			AND sucursal = cSucursal 
			AND monto = Cantidad;
					   
		
		--*SE VALIDA SI EXISTE REGISTRO COMO PAGADO
		IF valStatus = '05' THEN
		   
				UPDATE bdisuc:ss_mae_entradasalida 
				SET status = '11'  
				WHERE folio_oper = folioOper 
				AND sucursal = cSucursal 
				AND monto = Cantidad 
				AND status = '05';
				
				LET cCodRet = '00000'; 
		ELIF valStatus = '11' THEN
				LET cCodRet = '00000'; 
		ELSE
			LET cCodRet = '00002'; --*OCURRIO UN ERROR AL OBTENER EL FOLIO DE OPERACION*--
		END IF;
		RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'AUTOR:			98467379-Hector Hazael Aguilar Arteaga',
'PROCEDIMIENTO: Procedimiento realizara una actualizacion del status 5 "PAGADA" a status 11 "LISTA PARA PAGARSE" en la tabla ss_mae_entradasalida',
'				debido a la incidencia que ocurria cuando por algun error no controlado como por ejemplo el error "24 TimeOut" quedan descuadrados los datos',
'				en sucursal y central provocando no poder realizar el flujo de la dotacion correctamente',				
'SOLICITO: 		Cutberto GonzÃ¡lez PÃ©rez',
'BD:            bdisuc',
'FOLIO:			1918-INC_DOTACION_CAJA_GENERAL';

CREATE PROCEDURE "informix".sp_dotatm_2(pempresa CHAR(3),
        	          	              pfolio   CHAR(8)) 

RETURNING CHAR(5),CHAR(4),MONEY(14,2);

DEFINE vcodret           CHAR(5);
DEFINE vsqlerr,visamerr  INTEGER;
DEFINE vstatus           CHAR(2);
DEFINE vsucursal	 CHAR(4);
DEFINE vmonto		 MONEY(14,2);
DEFINE vreversado	 CHAR(1);

LET vcodret    = "000";
LET vsucursal  = "";
LET vmonto	   = 0;
LET vreversado = "";
LET vstatus    = "";

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ; 

BEGIN

    ON EXCEPTION SET vsqlerr,visamerr
        IF vsqlerr != 0 THEN
            LET vcodret=vsqlerr;
            RETURN vCodRet,vsucursal,vmonto;
        END IF;
    END EXCEPTION;

    --SET debug file to "/tmp/sp_dotatm_2.out";
    --trace on;

    --- Verifica recepcion correcta de datos
    IF pempresa = '0' OR pempresa = '' OR pfolio = '0' OR pfolio = '' THEN 
        LET vcodret = "110";
    ELSE
        SELECT m.status,o.sucursal,o.monto,o.reversado
          INTO vstatus,vsucursal,vmonto,vreversado
          FROM bdisuc:"informix".ss_operaciones as o, bdisuc:"informix".ss_mae_entradasalida as m
         WHERE o.folio_oper = pfolio
		   AND o.folio_oper = m.folio_oper 
           AND o.reversado = 0;

		IF vstatus IS NULL THEN
            LET vCodRet = "100";
		ELSE
	        IF vstatus != "11" THEN
	            LET vCodRet = "104";
	        END IF

	        IF vstatus IN ("05","13") THEN
	            LET vCodRet = "107";
	        END IF;
		END IF

        RETURN vCodRet,vsucursal,vmonto;

    END IF;
END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/12/2019',
'DESCRIPCION: Se realiza clonación del procedimiento productivo sp_dotatm para mantener versión anterior.';

CREATE PROCEDURE "informix".sp_inserta_atm_2(pempresa CHAR(3),
                                           pcod_atm CHAR(4), 
                                           pdivisa  CHAR(2), 
                                           pcant_1  FLOAT,
                                           pcant_2  FLOAT,
                                           pcant_3  FLOAT,
                                           pcant_4  FLOAT,
                                           pcant_5  FLOAT,
                                           pcant_6  FLOAT,
                                           pmonto   DECIMAL(14,2))
RETURNING CHAR(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;

DEFINE vden01 CHAR(5);
DEFINE vden02 CHAR(5);
DEFINE vden03 CHAR(5);
DEFINE vden04 CHAR(5);
DEFINE vden05 CHAR(5);
DEFINE vden06 CHAR(5);
DEFINE vden07 CHAR(5);
DEFINE vSaldo_ant MONEY (14,2);
DEFINE vSaldo_asi MONEY (14,2);
DEFINE vSaldo_tot MONEY (14,2);

LET vcodret = "000";
LET vsqlerr = 0;
LET vden01 = "";
LET vden02 = "";
LET vden03 = "";
LET vden04 = "";
LET vden05 = "";
LET vden06 = "";
LET vden07 = "";
LET vSaldo_ant = "";
LET vSaldo_asi = "";
LET vSaldo_tot = "";

SET LOCK MODE TO WAIT 3;

BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;


    --SET debug file to "/tmp/sp_inserta_atm_2.out";
    --trace on;

    IF EXISTS (SELECT cod_atm FROM bdisuc:"informix".ss_atm WHERE cod_atm = pcod_atm) THEN

        UPDATE bdisuc:"informix".ss_atm SET cantidad_1 = cantidad_1 + pcant_1,cantidad_2 = cantidad_2 + pcant_2,cantidad_3 = cantidad_3 + pcant_3,
                          cantidad_4 = cantidad_4 + pcant_4,cantidad_5 = cantidad_5 + pcant_5,cantidad_6 = cantidad_6 + pcant_6,
                          saldo_anterior = saldo_total,saldo_asignado = 0,saldo_total = saldo_total + pmonto
        WHERE empresa = pempresa AND cod_atm = pcod_atm;

    ELSE
		LET vden01 = '1000';
        LET vden02 = '500';
        LET vden03 = '200';
        LET vden04 = '100';
        LET vden05 = '50';
        LET vden06 = '20';
        LET vden07 = '-1';
        
        INSERT INTO bdisuc:"informix".ss_atm (empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3,
                            denominacion_4,denominacion_5,denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,
                            denominacion_11,denominacion_12,denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,
                            cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
                            cantidad_13,cantidad_14,cantidad_15)
        VALUES (pempresa, pcod_atm, pdivisa, 0, 0,pmonto,vden01, vden02, vden03, vden04, vden05, vden06,vden07,0,0,0,0,0,0,0,0,pcant_1,
                pcant_2,pcant_3,pcant_4,pcant_5,pcant_6,'0','0','0','0','0','0','0','0','0');
    END IF;

    RETURN vcodret;

END
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/12/2019',
'DESCRIPCION: Se realiza clonación del procedimiento productivo sp_inserta_atm para mantener versión anterior.';

CREATE PROCEDURE "informix".sp_concensuc_web(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
        pfolio_suc char(16),
  		ptransaccion char(4),
		pdivisa CHAR(2),
		pmonto_dot money(14,2),
        pfecha  date,
		pdeno1  CHAR(18),
		pdeno2  CHAR(18),
		pdeno3  CHAR(18),
		pdeno4  CHAR(18),
        pdeno5  CHAR(18),
		pdeno6  CHAR(18),
		pdeno7  CHAR(18),
		pdeno8  CHAR(18),
		pdeno9  CHAR(18),
		pdeno10 CHAR(18),
        pdeno11 CHAR(18),
		pdeno12 CHAR(18),
		pdeno13 CHAR(18),
		pdeno14 CHAR(18),
		pdeno15 CHAR(18),
		pcant1  float(8),
		pcant2  float(8),
		pcant3  float(8),
		pcant4  float(8),
		pcant5  float(8),
		pcant6  float(8),
		pcant7  float(8),
		pcant8  float(8),
		pcant9  float(8),
        pcant10 float(8),
		pcant11 float(8),
		pcant12 float(8),
		pcant13 float(8),
		pcant14 float(8),
		pcant15 float(8),
        pfolio char(16))


RETURNING CHAR(5),char(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio char(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vproveedor char(4);
DEFINE vplaza char(3);
DEFINE vnum INTEGER;
DEFINE vmonto money(14,2);

LET vcodret = "00000";
LET vfolio = "";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vmonto = 0;


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vfolio;
   END IF;
END EXCEPTION;

--SET debug file to "/informix/c96105143/concensuc.out";
--trace on;

--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto_dot = 0 or pfolio = '' then
   LET vcodret = "00110";
ELSE

   set isolation to dirty read; 
   SET LOCK MODE TO WAIT 3;

   
   select FIRST 1 o.folio_oper,o.monto
     into vfolio, vmonto
   	from bdisuc:ss_operaciones o, bdisuc:ss_mae_entradasalida m
  	where o.folio_oper = m.folio_oper
    AND o.fecha_operacion = pfecha
    AND o.sucursal = psucursal
    AND o.cod_trans = ptransaccion
    AND o.reversado = 0
    AND m.folio_servicio = pfolio;

    if (vmonto is null) then let vmonto = 0; end if; 

    IF vfolio IS NOT NULL AND vmonto <> pmonto_dot THEN
         LET vcodret = "00109";
        RETURN vcodret,vfolio;
    END IF;

    IF vfolio IS NOT NULL AND vmonto = pmonto_dot AND pmonto_dot > 0 THEN
        UPDATE bdisuc:"informix".ss_operaciones
        SET  cod_trans = ptransaccion,
             folio_sucursal = pfolio_suc,
             denominacion_1 = pdeno1, denominacion_2 = pdeno2, denominacion_3 = pdeno3,
             denominacion_4 = pdeno4, denominacion_5 = pdeno5, denominacion_6 = pdeno6,
             denominacion_7 = pdeno7, denominacion_8 = pdeno8, denominacion_9 = pdeno9,
             denominacion_10= pdeno10,denominacion_11= pdeno11,denominacion_12= pdeno12,
             denominacion_13= pdeno13,denominacion_14= pdeno14,denominacion_15= pdeno15,
             cantidad_1 = pcant1, cantidad_2 = pcant2, cantidad_3 = pcant3,
             cantidad_4 = pcant4, cantidad_5 = pcant5, cantidad_6 = pcant6,
             cantidad_7 = pcant7, cantidad_8 = pcant8, cantidad_9 = pcant9,
             cantidad_10 = pcant10,cantidad_11 = pcant11,cantidad_12 = pcant12,
             cantidad_13 = pcant13,cantidad_14 = pcant14,cantidad_15 = pcant15
	WHERE   empresa = pempresa 
    	and     folio_oper= vfolio;

        UPDATE bdisuc:"informix".ss_mae_entradasalida
        SET  folio_sucursal = pfolio_suc,
             fecha_solicitud = pfecha,
             hora_solicitud = vhora,
             usuario_solicitud = pcajeroprincipal,
             hora_envio = vhora,
             usuario_envio = pcajeroprincipal
	WHERE empresa = pempresa
    	and   folio_oper = vfolio;
        RETURN vcodret,vfolio;

    ELSE

   	select s.plaza_cajagen,p.cod_proveedor
 	into vplaza, vproveedor
	from bdisuc:ss_proveedores p, bdinteg:si_sucursales s
	where p.plaza = s.plaza_cajagen
	and s.empresa = pempresa
	and s.sucursal = psucursal;


    	if ( vmonto = 0 ) then
        select valor into vnum
        from   ss_param_cajagen
        where  codigo = '0005';

        update ss_param_cajagen
        set    valor = valor + 1
        where  codigo = '0005';

        let vfolio = lpad(vnum,8,"0");

        INSERT INTO bdisuc:"informix".ss_operaciones
          (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,
               denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
               denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
               denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
               cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
               cantidad_13,cantidad_14,cantidad_15)
        VALUES
              (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dot,
               pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
           pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
           pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

        INSERT INTO bdisuc:"informix".ss_mae_entradasalida
               (empresa,cod_proveedor,folio_oper,sucursal,folio_sucursal,
                fecha_solicitud,hora_solicitud,usuario_solicitud,
                fecha_envio,hora_envio,usuario_envio,
                status,monto,folio_servicio)
        VALUES (pempresa,vproveedor,vfolio,psucursal,pfolio_suc,
                pfecha,vhora,pcajeroprincipal,
                pfecha,vhora,pcajeroprincipal,
                '06',pmonto_dot,pfolio);

    end if;

    END IF;

END IF;

RETURN vcodret,vfolio;
END;
END PROCEDURE;