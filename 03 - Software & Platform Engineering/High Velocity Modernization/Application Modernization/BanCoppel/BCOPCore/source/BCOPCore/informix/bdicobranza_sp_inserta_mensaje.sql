create procedure "informix".sp_inserta_mensaje(pempresa  char(3), ptipomensaje smallint, pnumvencido  smallint, ptipomail smallint)
returning VARCHAR(6);
-- execute procedure "informix".sp_inserta_mensaje('001',5,2,0)

DEFINE pidtipomensaje	char (2);
DEFINE pnumvencidos     smallint;
DEFINE pnumcte          char(20);
DEFINE pnumcredito      char(20);
DEFINE pnombre          char(60);
DEFINE pemail           char (60);
DEFINE pmonto           decimal(18,2);
DEFINE psaldototal      decimal(18,2);
DEFINE ppagominimo      decimal(18,2);
DEFINE pmontoconvenio   decimal(18,2);
DEFINE pfechahoy		date;
DEFINE pvalor			smallint;
DEFINE vfecha			datetime year to second;
DEFINE pfecha			datetime year to second;
DEFINE pfechaprimercons datetime year to second;
DEFINE pfreestructu datetime year to second;
DEFINE cProceso  		char(4);
DEFINE cCod_ret  		smallint;
DEFINE cMensaje  		char (100);
DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE P_COD_RET        VARCHAR(6);
DEFINE P_MENSAJE        VARCHAR(80);
DEFINE v_longitud       INTEGER;  
DEFINE v_cuenta			INTEGER;  
DEFINE v_subcadena		CHAR(1);  
DEFINE v_mail_incorrecto CHAR(1);  
LET v_longitud          = 0;  
LET v_cuenta            = 1;   
LET v_subcadena         = ''; 

BEGIN

    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
            RETURNING P_COD_RET;
        RETURN P_COD_RET;
    END exception;
	
 --SET DEBUG FILE TO "/informix/Elizabeth/inserta_mensaje.out";
 --TRACE ON;

  let P_COD_RET = '111111';
  let cCod_ret = '';
  let cMensaje = '';
  let cProceso = '2030';
  let pmonto = 0;
  let vfecha = to_char(today, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S');
 
  --valida parametros
	IF NVL (pempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (ptipomensaje, '') = '' THEN
        LET cCod_Ret= '106007';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (pnumvencido, '') = '' THEN
        LET cCod_Ret= '104001';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (ptipomail, '') = '' THEN
        LET cCod_Ret= '104001';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01') RETURNING P_COD_RET;
			
	Select Fecha_Hoy
    Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = pempresa;
	
    select id_tipo_mensaje
    into pidtipomensaje
    from bdicobranza:cb_mail_configuracion
    where tipo_mensaje = ptipomensaje
    and num_vencidos = pnumvencido
	and tipo_mail = ptipomail;

    DELETE FROM bdinteg:si_mensajes_enviar WHERE date(f_mensaje) = pfechahoy and id_tipo_mensaje = pidtipomensaje;
	
	--valida el tipo de mensaje para la busqueda  en el where del select mas adelante
	if (ptipomensaje = 1 and pnumvencido <=5) then -- obtiene los meses de vencidos para mensajes de mora
		let pvalor=pnumvencido;
	end if;
	if (ptipomensaje = 1 and ptipomail >= 30) then --obtiene el valor para tipo de mensaje para mensajes de remanente y compra mayor a $5,000
		let pvalor=ptipomail;
	end if;
	if (ptipomensaje = 3) then--obtiene el valor para tipo de mensaje para convenios
		let pvalor = ptipomail;
	end if;
	if (ptipomensaje = 2) then--obtiene el valor para mensajes a venta de cartera
		let pvalor = 5;
	end if;
	if (ptipomensaje = 4 and pnumvencido > 0 ) then --valor para mensajes en reestructura moras
		let pvalor = pnumvencido;
	end if;
	if (ptipomensaje = 4 and pnumvencido = 0  and ptipomail = 0) then --valor para mensajes en reestructura preventiva
		let pvalor = 0;
	end if;
	if (ptipomensaje = 5 and pnumvencido <= 2 and ptipomail = 0) then --valor para mensajes en prestamo P moras
		let pvalor = pnumvencido;
	end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0) then --valor para mensajes en prestamo P preventiva
		let pvalor = 0;
	end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10) then --valor para mensajes en prestamo P autorizacion
		let pvalor = ptipomail;
	end if;
	
foreach
			
    select a.numcte, a.num_credito, a.email,a.pago_minimo,a.saldo_total
		, a.monto_convenio,
		to_char(a.fecha_convenio, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_convenio ,
		to_char(a.fecha_compac, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_compac , to_char(a.fecha_primercons, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_primercons,
		trim (e.apell_paterno) || ' ' || trim ( e.apell_materno) || ' ' || trim (e.nombre1) || ' ' || trim (e.nombre2) as nombre_cliente 
    into pnumcte,pnumcredito,pemail,ppagominimo,psaldototal,pmontoconvenio,pfreestructu,
		 pfecha,pfechaprimercons ,pnombre  
    from bdicobranza:cb_mail_cliente a, bdinteg:si_cliente  e 
    where a.empresa = e.empresa
		and a.numcte = e.numcte
		and a.tipo_mensaje = ptipomensaje
		and a.pagos_vencidos = pvalor --se obtine de las validaciones anteriores
		and  a.fecha_insert = pfechahoy
	--montos
	if (ptipomensaje = 1) then let pmonto = ppagominimo; end if;
    if (ptipomensaje = 3) then let pmonto = pmontoconvenio; end if;
	if (ptipomensaje = 2) then let pmonto = psaldototal; end if;
	if (ptipomensaje = 4) then let pmonto = ppagominimo; end if;
	if (ptipomensaje = 5) then let pmonto = psaldototal; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0)  then let pmonto = ppagominimo; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10)  then let pmonto = psaldototal; end if;
	--fechas
	if (ptipomensaje = 3) then let vfecha = pfecha; end if;
	if (ptipomensaje = 1 and ptipomail = 30) then let vfecha = pfechaprimercons; END IF;
	if (ptipomensaje = 4 and pnumvencido = 0 and ptipomail = 0) then let vfecha = pfreestructu; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0) then let vfecha = pfreestructu; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10) then let vfecha = pfreestructu; end if;
	
	LET v_longitud = length(pemail);
			FOR v_cuenta = 1 to v_longitud
				  LET v_subcadena = SUBSTR(pemail,v_cuenta,1);
					IF v_subcadena  in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T',
                                 'U','V','W','X','Y','Z',
                                 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t',
                                 'u','v','w','x','y','z',
                                 '1','2','3','4','5','6','7','8','9','0','@','_','-','.') THEN
						LET v_mail_incorrecto = 'F'; 
					-- INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta, nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado,f_enviado,observaciones)
					--	VALUES(current, pnumcte, pnumcredito, pnombre,pemail, pmonto,pidtipomensaje,'V',current,'DIRECCION DE CORREO INCORRECTA');
					
						CONTINUE FOR;
					ELSE
						LET v_mail_incorrecto   = 'T';
				    EXIT FOR;
				    END IF;
			END FOR
			
				IF v_mail_incorrecto = 'T' THEN
					INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta,/*num_tarjeta ,tipo_tarjeta,*/ nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado,f_enviado,observaciones)
					VALUES(current, pnumcte, pnumcredito,/* null,null,*/pnombre,pemail, pmonto,pidtipomensaje,'V',current,'DIRECCION DE CORREO INCORRECTA');
				else
					insert into bdinteg:"informix".si_mensajes_enviar(f_mensaje, numcte, cuenta,/*num_tarjeta ,tipo_tarjeta,*/ nombre_cliente, correo_cliente,
																	  monto_reportar, id_tipo_mensaje, enviado )
					values(vfecha, pnumcte, pnumcredito,/*null,null,*/ pnombre,pemail, pmonto,pidtipomensaje,'F');
				END IF;
			
end foreach
   let P_COD_RET = '000000';

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;
end
RETURN P_COD_RET;
END PROCEDURE;