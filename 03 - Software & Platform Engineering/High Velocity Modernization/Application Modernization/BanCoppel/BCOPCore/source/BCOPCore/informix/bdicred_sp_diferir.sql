CREATE PROCEDURE "informix".sp_diferir(pcte CHAR(20), pcel CHAR(10), ptar CHAR(20), pcanal SMALLINT)
	RETURNING CHAR(5) as codret, CHAR(100) as desc_err;

    DEFINE vcodret CHAR(5);
	DEFINE vtermcdto CHAR(4);
    DEFINE vsqlerr, vcant, vcantr,vcantp, vsumavencidosr, vsumavencidosp, auxBaja INTEGER;
	DEFINE vCredito	CHAR(20);
	DEFINE cEmpresa CHAR(3);
	DEFINE vcadena CHAR(500);
	DEFINE vCliente	CHAR(20);
	DEFINE cCodRetSp CHAR (5);
	DEFINE dPagoMinimo DECIMAL(18,2);
	DEFINE dSdoActCap DECIMAL(18,2);
	DEFINE dPagoNoIntereses DECIMAL(14,2);
	DEFINE vSoloConsulta CHAR(1);

	DEFINE vSaldoGenNull INTEGER;
	DEFINE vSaldoGenOK INTEGER;

    LET vcodret    = '00000';
	LET vtermcdto   ='';
	LET vCredito   = '';
	LET cEmpresa 	= '001';
	LET vcadena	   = '';

	LET vSaldoGenNull = 0;
	LET vSaldoGenOK = 0;
	LET cCodRetSp='00000';
	
	LET dPagoMinimo = NULL;
	LET dSdoActCap = NULL;
	LET dPagoNoIntereses = NULL;

    LET vcant = 0;
    LET vcantr = 0;
    LET vcantp = 0;
    LET vsumavencidosr = 0;
    LET vsumavencidosp = 0;
	LET vSoloConsulta = '';
    
    BEGIN

		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret,'';
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


	LET vcodret = "00008";
	RETURN vcodret,'TU SOLICITUD NO PUEDE SER RECIBIDA, NO CUENTAS CON UN CREDITO PARTICIPANTE EN EL PLAN DE APOYO.';


		IF (nvl(ptar,'') = 'CONSULTAR') THEN
			LET vSoloConsulta = '1';
			LET ptar = '';
		END IF;

		IF (LENGTH(pcel) = 0 OR pcel is null) AND (LENGTH(pcte) = 0 OR pcte is null) AND (LENGTH(ptar) = 0 OR ptar is null)  THEN
			LET vcodret = "00001";
			RETURN vcodret,'DATOS DE ENTRADA INVALIDOS, VERIFIQUE.';
        END IF;
			
		IF LENGTH(pcel) > 0 AND NOT pcel is null  THEN -- Obtiene cliente por numero de celular

		   SELECT COUNT(DISTINCT(numcte))  INTO vcant 
			FROM bdinteg:si_telefonos_actual 
			WHERE telefono=pcel  AND tipo_tel='2' AND status_tel='A' ;		

		--SI HAY MAS DE UN NUMERO DE CLIENTE ASOCIADO TERMINA EL PROCESO
		    IF vcant > 1 THEN 
	           LET vcodret = "00002";
	           RETURN vcodret,'NUMERO CELULAR ASOCIADO A MAS DE UN CLIENTE';

	       --SI NO HAY NINGUN NUMERO DE CLIENTE ASOCIADO TERMINA EL PROCESO
	        ELIF vcant < 1 THEN 
	           LET vcodret = "00003";
	           RETURN vcodret,'NUMERO DE TELEFONO NO ASIGNADO A UN CLIENTE.';
  	       END IF;
		   
		   -- OBTENEMOS EL NUMERO DE CLIENTE
		    SELECT numcte  INTO vCliente
			FROM bdinteg:si_telefonos_actual a
			WHERE telefono=pcel  AND tipo_tel='2' AND status_tel='A' ;
		ELIF LENGTH(ptar) > 0 AND NOT ptar is null  THEN -- Obtiene cliente por el numero de tarjeta
            SELECT first 1 numcte INTO vCliente 
            FROM  bdicheq:sc_tarjeta b	
            WHERE b.num_tarjeta = ptar
              AND tipo_tarjeta = 'T'
              AND status_tar = 'A'; 	

            IF (nvl(vCliente,'') = '') THEN
                SELECT first 1 numcte INTO vCliente 
                FROM  bdicred:sd_tarjeta b	
                WHERE b.num_tarjeta = ptar
                  AND tipo_tarjeta = 'T'
                  AND status_tar = 'A'; 	
            END IF;

            IF (nvl(vCliente,'') = '') THEN
	           LET vcodret = "00004";
	           RETURN vcodret,'NUMERO DE TARJETA INVALIDA.';
            END IF;
        ELSE -- ASIGNA POR NUMERO DE CLIENTE PROPORCIONADO
            SELECT numcte INTO vCliente
            FROM bdinteg:si_cliente
            WHERE numcte=pcte;

            IF (nvl(vCliente,'')) = '' THEN
                LET vcodret = "00007";
                RETURN vcodret,'CLIENTE NO EXISTE.';
            END IF;
        END IF;

		-- SE VALIDA QUE EL CLIENTE YA ESTE REGISTRADO
        SELECT numcte,canal_baja INTO vcant,auxBaja
        FROM  bdicred:sd_diferir b	
        WHERE b.numcte=vCliente; 	
		
		IF auxBaja is NULL THEN
			LET auxBaja = 0;
		END IF;
		
		IF vSaldoGenNull <> auxBaja THEN
			LET vcodret = '00011';
			RETURN vcodret,'LA SOLICITUD DE CANCELACION YA SE REGISTRO PREVIAMENTE.';
		END IF;

        IF vSaldoGenNull <> vcant  THEN
	       LET vcodret = "00005";
           RETURN vcodret, 'TU SOLICITUD YA SE REGISTRO PREVIAMENTE.';
        END IF;
		
        --VALIDA QUE ESTE AL CORRIENTE AL 29 DE FEBRERO DEL 2020 y AL DIA DE HOY
	    SELECT COUNT(*), sum(case when c.status_cred <> 'AA' then 1 else 0 end), sum(case when b.status_cred not in ('AA','FF') then 1 else 0 end)
        INTO vcantr, vsumavencidosr, vsumavencidosp
        FROM  bdicred:sd_maecred b,
              bdicred:sd_maecredcont c
        WHERE b.numcte=vCliente
        AND b.num_producto IN ('6001','8100') 
        and b.num_credito = c.num_credito
        and b.fecha_apertura <= mdy('03','31','2020')
        and c.fecha = mdy('03','31','2020');


		IF (vSaldoGenNull <> nvl(vsumavencidosr,0))  THEN
            LET vcodret = "00008";
			RETURN vcodret,'TU SOLICITUD NO PUEDE SER RECIBIDA, NO CUENTAS CON UN CREDITO PARTICIPANTE EN EL PLAN DE APOYO.';
		END IF;

		IF (vSaldoGenNull <> nvl(vsumavencidosp,0))  THEN
            LET vcodret = "00009";
			RETURN vcodret,'CLIENTE NECESITA ESTAR AL CORRIENTE PARA ENTRAR AL PROGRAMA.';
		END IF;

	    SELECT COUNT(*), sum(case when c.status_cred <> 'AA' then 1 else 0 end), sum(case when b.status_cred not in ('AA','FF') then 1 else 0 end)
        INTO vcantp, vsumavencidosr, vsumavencidosp
        FROM  bdicred:sd_maecredcrd b,
              bdicred:sd_maecredcontcrd c
        WHERE b.numcte=vCliente
        AND b.num_producto IN ('6300','6800','7600','7700') 
        and b.num_credito = c.num_credito
        and b.fecha_apertura <= mdy('03','31','2020')
        and c.fecha = mdy('03','31','2020');

		IF (vSaldoGenNull <> nvl(vsumavencidosr,0))  THEN
            LET vcodret = "00008";
			RETURN vcodret,'TU SOLICITUD NO PUEDE SER RECIBIDA, NO CUENTAS CON UN CREDITO PARTICIPANTE EN EL PLAN DE APOYO.';
		END IF;

		IF (vSaldoGenNull <> nvl(vsumavencidosp,0))  THEN
            LET vcodret = "00009";
			RETURN vcodret,'CLIENTE NECESITA ESTAR AL CORRIENTE PARA ENTRAR AL PROGRAMA.';
		END IF;

		IF (vSaldoGenNull = vcantp)  THEN
        --- Valida linea de credito flexible
            select count(*)
            into vcantp
            from bdicred:sd_maecredcrd a,
                 bdicred:sd_linea_prestamo b
            where a.numcte = vCliente
              and a.num_credito = b.num_credito
              and b.fecha_otorga <= mdy('03','31','2020')
              and fecha_cancela is null;

            IF (vcantp > vSaldoGenNull) THEN
				SELECT COUNT(*), sum(case when c.status_cred <> 'AA' then 1 else 0 end), 
				sum(case when b.status_cred not in ('AA','FF') then 1 else 0 end)
				INTO vcantp, vsumavencidosr, vsumavencidosp
				FROM  bdicred:sd_maecredcrd b,
					  bdicred:sd_maecredcontcrd c
				WHERE b.numcte=vCliente
				AND b.num_producto = '6800'
				and b.num_credito = c.num_credito
				and c.fecha = mdy('03','31','2020');			
				
				IF (vSaldoGenNull <> nvl(vsumavencidosr,0))  THEN
					LET vcodret = "00008";
					RETURN vcodret,'TU SOLICITUD NO PUEDE SER RECIBIDA, NO CUENTAS CON UN CREDITO PARTICIPANTE EN EL PLAN DE APOYO.';
				END IF;

				IF (vSaldoGenNull <> nvl(vsumavencidosp,0))  THEN
					LET vcodret = "00009";
					RETURN vcodret,'CLIENTE NECESITA ESTAR AL CORRIENTE PARA ENTRAR AL PROGRAMA.';
				END IF;			
			END IF;


            IF (vSaldoGenNull = vcantp  + vcantr) THEN
                LET vcodret = "00008";
                RETURN vcodret,'TU SOLICITUD NO PUEDE SER RECIBIDA, NO CUENTAS CON UN CREDITO PARTICIPANTE EN EL PLAN DE APOYO.';
            END IF;
		END IF;

		IF (vSoloConsulta = '1') THEN
			LET vcodret = "00010";
            RETURN vcodret,'CLIENTE ES CANDIDATO AL APOYO.';
		ELSE
			INSERT INTO "informix".sd_diferir (numcte, num_tarjeta, fecha, canal, telefono)
				VALUES(vCliente, ptar,CURRENT,pcanal,pcel);
			RETURN vcodret, 'SOLICITUD RECIBIDA DE MANERA EXITOSA. CONSULTA TERMINOS Y CONDICIONES EN www.bancoppel.com';
		END IF;
	END;
END PROCEDURE;