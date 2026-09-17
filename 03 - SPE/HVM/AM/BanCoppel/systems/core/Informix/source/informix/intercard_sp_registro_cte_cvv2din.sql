CREATE PROCEDURE "informix".sp_registro_cte_cvv2din(pnumcte varchar (11))
RETURNING char (5) as codigo ,char (100) as descripcion;

DEFINE cCodret char (5);
DEFINE vMensaje char (100);
DEFINE isam_err  integer;
DEFINE vsqlerr   integer;
DEFINE error_info varchar(80);
DEFINE vnumtarjeta char (16);
DEFINE vnumtarjetaCVV2 char (16);
DEFINE vnumcuenta varchar (13);
DEFINE vnumcliente varchar (13);
DEFINE vtitular varchar (1);
DEFINE vtabla varchar (50);
DEFINE vcampo varchar (50);
DEFINE vTransac varchar (1);
DEFINE vAnioExp varchar(4);
DEFINE vMesExp varchar(2);
DEFINE vFechaExp date;

--Set debug file to "/informix/ecy/cvv2Dinamico/spsaldos/registrotjs.out";
--trace on;

BEGIN
	ON EXCEPTION SET vsqlerr,isam_err, error_info
        IF vsqlerr <> 0 THEN
			LET cCodret = vsqlerr;
			LET  vMensaje  = error_info;
			IF vTransac <> '0' THEN --VALIDA SI SE REALIZA EL ROLLBACK
				LET cCodret=vsqlerr;
				LET vMensaje=error_info;
				--ROLLBACK WORK;
			END IF;
				
			RETURN cCodret,vMensaje;
			
        END IF;
    END EXCEPTION;
	
	--DROP TABLE IF EXISTS tbl_tjtsCVV2dinamico_reg;
	
	LET cCodret='00000';
	LET vnumtarjeta='';
	LET vMensaje='';
	LET vnumtarjetaCVV2='';
	LET vnumcuenta='';
	LET vnumcliente='';
	LET vtitular='';
	LET vtabla='intercard.tarjeta_indicadores';
	LET vcampo='tarjeta_indicadores.cvv2dinamico';
	LET vTransac='0'; -- BANDERA APAGADA PARA QUE NO HAGA ROLLBACK EN CASO DE FALLA EN SELECT
	LET vMesExp='';
	LET vAnioExp='';

	
	IF  (pnumcte IS NULL) OR (pnumcte='') THEN
	    LET cCodret='00100';
		LET vMensaje='Numero cliente vacio';
		RETURN cCodret,vMensaje;
	END IF;
	
			
	LET vFechaExp=(extend(today, year to month) +0 units month)::date;
	
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
			
	FOREACH WITH HOLD
	
			
		SELECT t.numtarjeta,t.numcliente,t.titular
		INTO vnumtarjeta,vnumcliente,vtitular
		FROM intercard:tarjeta t
		WHERE t.numcliente=pnumcte
		AND t.codstatustarjeta in ('ACT','INA','BLO','BLT')
        AND t.codstatusasignada='SIA' 
		AND (SUBSTR(t.fechaexp,3,4)||'/'||'01'||'/'||'20'||SUBSTR(t.fechaexp,1,2))::date >= vFechaExp
		AND t.codproductotarjeta NOT IN ('007')
	
		
		IF vnumtarjeta is null THEN 
			LET cCodret='00300';
			LET vMensaje='No tiene tarjetas activas';
			RETURN cCodret,vMensaje;
		END IF;
		
		SELECT numtarjeta 
			INTO vnumtarjetaCVV2
		FROM intercard:tarjeta_indicadores
		WHERE numtarjeta=vNumTarjeta;
		
		--BEGIN WORK;
		
			LET vTransac='1'; --BANDERA PRENDIDA PARA QUE HAGA ROLLBACK EN CASO DE FALLA EN INSERT
	
			IF vnumtarjetaCVV2 IS NULL THEN 
				INSERT INTO intercard:tarjeta_indicadores(numtarjeta,cvv2dinamico) VALUES (vNumTarjeta,'V');
				INSERT INTO intercard:bitacoracambiostarjeta (secuencial,tarjeta,numcliente,titular,tabla,campo,valoranterior,valornuevo,fechacambio,usuariocambio,identificadorcambio,descripcioncambio)  
				VALUES (0,vnumtarjeta,vnumcliente,vtitular,vtabla,vcampo,'F','V',CURRENT year to fraction(3),USER ,'9','inserta activa cvv2 dinamico ' );
			ELSE
				UPDATE intercard:tarjeta_indicadores SET cvv2dinamico='V'
				WHERE numtarjeta=vNumTarjeta;
				INSERT INTO intercard:bitacoracambiostarjeta (secuencial,tarjeta,numcliente,titular,tabla,campo,valoranterior,valornuevo,fechacambio,usuariocambio,identificadorcambio,descripcioncambio)  
				VALUES (0,vnumtarjeta,vnumcliente,vtitular,vtabla,vcampo,'F','V',CURRENT year to fraction(3),USER ,'9','update activa cvv2 dinamico');
			END IF;
	
		--COMMIT WORK;
		
	END FOREACH;
	
	--DROP TABLE IF EXISTS tbl_tjtsCVV2dinamico_reg;
	
	RETURN cCodret,vMensaje;
END;
END PROCEDURE;