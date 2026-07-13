CREATE PROCEDURE "informix".sp_sw_ro_consultapersonasencontradas(pUsuarioC CHAR(8), pFuncionC CHAR(10), pIdOficio INT,pIp CHAR(15), 
                                                                                                                pMacAddress CHAR(12), pNumRegistro INT, pNumRecuperaciON INT)
        RETURNING CHAR(5) AS codRet, 
                CHAR(20) AS numeroCliente, 
                CHAR(15) AS rfc,
                CHAR(26) AS nombre1, 
                CHAR(26) AS nombre2, 
                CHAR(26) AS apPaterno, 
                CHAR(26) AS apMaterno, 
                CHAR(60) AS razonSocial,
                CHAR(20) AS noCuenta,
                CHAR(20) AS noTarjeta,
                CHAR(2) AS tipoPersona, 
                CHAR(1) AS tipoCliente, 
                INT AS status, 
                CHAR(20) AS descStatusBusqueda,
                CHAR(1) AS ind_omitido,
                CHAR(1) AS ind_bloqueocta,
                CHAR(1) AS ind_terminado,
                INT AS id_busqueda,
                INT AS id_rescte, 
                CHAR(2) AS tipocuenta,
                CHAR(1) AS ind_rfc,
                CHAR(1) AS ind_dir_empleo,
                CHAR(1) AS ind_domicilio,
                CHAR(1) AS ind_nacionalidad;
				
        DEFINE iSqlErr INT;
        DEFINE cCodRet CHAR(5);
        DEFINE cNumCliente CHAR(20);
        DEFINE cRfc CHAR(15);
        DEFINE cNombre1 CHAR(26);
        DEFINE cNombre2 CHAR(26);
        DEFINE cApPaterno CHAR(26);
        DEFINE cApMaterno CHAR(26);
        DEFINE cRazonSocial CHAR(60);
        DEFINE cNumCuenta CHAR(20);
        DEFINE cNumTarjeta CHAR(20);
        DEFINE cTipoPersona CHAR(2);
        DEFINE cTipoCliente CHAR(1);
        DEFINE cStatusBusq INT;
        DEFINE cDescStatusBusqueda CHAR(20);
        DEFINE iIdEncontrado INT;
        DEFINE iIdCte INT;
        DEFINE iRegistros INT;
        DEFINE cOmitido CHAR(1);
        DEFINE cBloqueado CHAR(1);
        DEFINE cTerminado CHAR(1);
        DEFINE cTipoCuenta CHAR(2);
        DEFINE cIndRfc CHAR(1);
        DEFINE cIndEmpleo CHAR(1);
        DEFINE cIndDomicilio CHAR(1);
        DEFINE cIndNacionalidad CHAR(1);
		
        LET iSqlErr = 0;
        LET cCodRet = '00000';
        LET cNumCliente = '';
        LET cRfc = '';
        LET cNombre1 = '';
        LET cNombre2 = '';
        LET cApPaterno = '';
        LET cApMaterno = '';
        LET cRazonSocial = '';
        LET cNumCuenta = '';
        LET cNumTarjeta = '';
        LET cTipoPersona = '';
        LET cTipoCliente = '';
        LET cStatusBusq = 0;
        LET cDescStatusBusqueda = '';
        LET iIdEncontrado = 0;
        LET iRegistros = 0;
        LET cOmitido = '';
        LET cBloqueado = '';
        LET cTerminado = '';
        LET iIdCte = 0;
        LET cTipoCuenta = '';
        LET cIndRfc = '';
        LET cIndEmpleo = '';
        LET cIndDomicilio = '';
        LET cIndNacionalidad = '';

        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, cNumCliente, cRfc, cNombre1, 
                                                cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
                                                cNumCuenta, cNumTarjeta, cTipoPersona, cTipoCliente, 
                                                cStatusBusq, cDescStatusBusqueda, cOmitido, cBloqueado, 
                                                cTerminado, iIdEncontrado, iIdCte, cTipoCuenta, 
                                                cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad;
                        END IF;
                END EXCEPTION;
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pFuncionC) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cNumCliente, cRfc, cNombre1, 
                                        cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
                                        cNumCuenta, cNumTarjeta, cTipoPersona, cTipoCliente, 
                                        cStatusBusq, cDescStatusBusqueda, cOmitido, cBloqueado, 
                                        cTerminado, iIdEncontrado, iIdCte, cTipoCuenta, 
                                        cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad;
                END IF;
                SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
                FOREACH
                        SELECT skip pNumRegistro FIRST pNumRecuperacion
                                        rp.numcte, rp.rfc, rp.nombre1, rp.nombre2, rp.apell_paterno, rp.apell_materno, rp.razon_social, rp.cuenta, rp.num_tarjeta, 
                                        rp.tipo_cliente, rp.status_busqueda, rp.ind_omitir, 
                                        nvl(rc.bloqueo_cuentas,'0'), 
                                        nvl(rc.ind_terminado,'0'), rp.id_busqueda, 
                                        nvl(rc.id_resulcte, 0),rp.tipo_cuenta, 
                                        nvl(rc.ind_rfc, '0'), 
                                        nvl(rc.ind_empleo, '0'), 
                                        nvl(rc.ind_domicilio, '0'),
                                        nvl(rc.ind_nacionalidad, '0')
                        INTO cNumCliente, cRfc, cNombre1, cNombre2, 
                                        cApPaterno, cApMaterno, cRazonSocial, cNumCuenta, 
                                        cNumTarjeta,cTipoCliente, cStatusBusq, cOmitido, 
                                        cBloqueado, cTerminado, iIdEncontrado, iIdCte, 
                                        cTipoCuenta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad
                        FROM sw_ro_resulper rp LEFT JOIN sw_ro_resulcte rc 
                                        ON rc.id_busqueda = rp.id_busqueda 
                        WHERE rp.id_oficio = pIdOficio 
                        ORDER BY rp.id_resulper
            LET cTipoPersona = '';
            IF cTipoCliente in ('1', '2') THEN
                IF cRazonSocial = '' THEN
                    LET cTipoPersona = '01';
                ELSE
                    LET cTipoPersona = '02';
                END IF;
            END IF;
                        LET cDescStatusBusqueda = '';
                        IF cStatusBusq = 0 THEN
                                LET cDescStatusBusqueda = 'NO LOCALIZADO';
                        ELIF cStatusBusq = 1 THEN
                                LET cDescStatusBusqueda = 'LOCALIZADO';
                        ELIF cStatusBusq = 2 THEN
                                LET cDescStatusBusqueda = 'HOMONIMO';
                        END IF;
            RETURN cCodRet, cNumCliente, cRfc, cNombre1, 
                                        cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
                                        cNumCuenta, cNumTarjeta, cTipoPersona, cTipoCliente, 
                                        cStatusBusq, cDescStatusBusqueda, cOmitido, cBloqueado, 
                                        cTerminado, iIdEncontrado, iIdCte, cTipoCuenta, 
                                        cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
                                WITH resume;
                        LET iRegistros = iRegistros + 1;
                END FOREACH;
                IF iRegistros = 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, cNumCliente, cRfc, cNombre1, 
                                        cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
                                        cNumCuenta, cNumTarjeta, cTipoPersona, cTipoCliente, 
                                        cStatusBusq, cDescStatusBusqueda, cOmitido, cBloqueado, 
                                        cTerminado, iIdEncontrado, iIdCte, cTipoCuenta, 
                                        cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad;
                END IF; 
        END
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 22/10/2014',
'DESCRIPCION: Busqueda de un oficio, se elimina la busqueda de oficios por mac e ip';

create procedure "informix".sp_sw_ro_consnotas(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int)
	returning
		char(5) as codret,
		int as secuencia,
		char(255) as nota
	
	define cCodRet char(5);
	define iSqlErr int;
	define iNoRegistros int;
	define iSecuenciaNota int;
	define cNota char(255);
	
	let cCodRet = '00000';
	let iSqlErr = 0;
	let iSecuenciaNota = 0;
	let cNota = '';
	let iNoRegistros = 0;
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iSecuenciaNota, cNota;
			end if;
		end exception;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' then
			let cCodRet = '00003';
			return cCodRet, iSecuenciaNota, cNota;
		end if;
		
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, iSecuenciaNota, cNota;
		end if;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		foreach
			select id_notascte, nota
			into iSecuenciaNota, cNota
			from sw_ro_notascte
			where id_resulcte = pIdCliente and id_busqueda = pIdBusqueda and id_oficio = pIdOficio
			order by id_notascte
			
			let iNoRegistros = iNoRegistros + 1;
		
			return cCodRet, iSecuenciaNota, cNota with resume;
			
		end foreach;
		
		if iNoRegistros = 0 then
			let cCodRet = '01001';
			return cCodRet, iSecuenciaNota, cNota;
		end if;
	end;
end procedure;