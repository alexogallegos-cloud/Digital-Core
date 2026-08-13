CREATE PROCEDURE "informix".actualizaguardaconyuge_cjunk( cEmpresa CHAR(3),
                                                          cNumSolicitud CHAR(20),
                                                          cNumCte CHAR(20),
                                                          cNumCteConyuge CHAR(20),
                                                          cUsuario CHAR(8),
                                                          cTipoDirCon CHAR(1))
RETURNING char(5);

    DEFINE cCodRet char(5);
    DEFINE iSqlErr INTEGER;

    DEFINE sSucursal CHAR(4);
    DEFINE sApellPaterno CHAR(26);
    DEFINE sApellMaterno CHAR(26);
    DEFINE sNombre1 CHAR(26);
    DEFINE sNombre2 CHAR(26);
    DEFINE sRfc CHAR(13);
    DEFINE dFechaNac DATE;
    DEFINE sCurp CHAR(20);
    DEFINE sSexo CHAR(1);
    DEFINE sEstadoCivil CHAR(2);
    DEFINE sNacionalidad CHAR(3);
    DEFINE sNoFm CHAR(18);
    DEFINE sCodigoIden CHAR(2);
    DEFINE sNumIdenti CHAR(30);
    DEFINE sPersDomicilio CHAR(2);
    DEFINE sEmail CHAR(60);
    DEFINE sParentesco CHAR(2);
    DEFINE sApellCasada CHAR(26);
    DEFINE sNumcteRef CHAR(20);

    DEFINE pcalle char(40);
    DEFINE pcolonia char(60);
    DEFINE pmunicipio char(5);
    DEFINE pentre_calles char(40);
    DEFINE ppais char(3);
    DEFINE pentidad char(2);
    DEFINE plocalidad char(3);
    DEFINE pcodpostal char(5);
    DEFINE ptipotel1 char(1);
    DEFINE ptelefono1 char(13);
    DEFINE ptipotel2 char(1);
    DEFINE ptelefono2 char(13);
    DEFINE ptipotel3 char(1);
    DEFINE ptelefono3 char(13);
    DEFINE pextension char(5);
    DEFINE pestado_inegi char(2);
    DEFINE pmunicipio_inegi char(3);
    DEFINE plocalidad_inegi char(4);
    DEFINE pnociudad smallint;
    DEFINE pnoext char(10);
    DEFINE pnoint char(10);
    DEFINE pdepto char(6);
    DEFINE pnocalle integer;
    DEFINE pnocolonia integer;
    DEFINE ppuntocar char(1);
    DEFINE punihabi char(1);
    DEFINE pmanz smallint;
    DEFINE ppotros smallint;
    DEFINE pandador smallint;
    DEFINE petapa smallint;
    DEFINE plote smallint;
    DEFINE pedif smallint;
    DEFINE pentrada smallint;
    DEFINE pobserva char(80);
    DEFINE iSecuencia integer;
    DEFINE pCofeteltel1 char(1);
    DEFINE pCofeteltel2 char(1);
    DEFINE pCofeteltel3 char(1);
    DEFINE pApart_postal char (11);
    DEFINE dFechaHoy DATE;
    DEFINE wBegin CHAR(1);
    
    LET cCodRet = "000";
    
    --Set debug file to '/tmp/actualizaguardaconyuge_cjunk.out';
    --trace on;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

        update "informix".si_param 
           set valor = cast(valor as integer) + 1 
         where empresa = cEmpresa 
           and cod_param = 121;
           
        SELECT cast(valor as integer) 
          INTO iSecuencia 
          FROM "informix".si_param 
         where empresa = cEmpresa 
           and cod_param = 121;

        SELECT fecha_hoy 
          INTO dFechaHoy 
          FROM "informix".si_fechas;

        SELECT a.sucursal, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, a.string2, b.fecha_nac, b.curp, 
               b.sexo, b.estado_civil, b.nacionalidad, b.no_fm3, b.codidentifi, b.numidentifi, a.apell_casada, a.numcte_ref 
          INTO sSucursal, sApellPaterno, sApellMaterno, sNombre1, sNombre2, sRfc, sPersDomicilio, dFechaNac, sCurp, 
               sSexo, sEstadoCivil, sNacionalidad, sNoFm, sCodigoIden, sNumIdenti, sApellCasada, sNumcteRef
          FROM "informix".si_cliente a, 
               "informix".si_ctepf b
         WHERE a.numcte = b.numcte
           AND a.numcte = cNumCteConyuge;
           
        SELECT correo_elec
          INTO sEmail
          FROM "informix".si_correos
         WHERE numcte = cNumCteConyuge
           AND tipo_correo = 1
           AND status_correo = 'A';

        UPDATE "informix".si_refclientes  
           SET empresa = cEmpresa, sucursal = sSucursal, apell_paterno = sApellPaterno, apell_materno = sApellMaterno, nombre1 = sNombre1, nombre2 = sNombre2, 
               rfc = sRfc, fecha_nac = dFechaNac, curp = sCurp, sexo = sSexo, estado_civil = sEstadoCivil, nacionalidad = sNacionalidad, no_fm3 = sNoFm, 
               codidentifi = sCodigoIden, numidentifi = sNumIdenti, pers_domicilio = sPersDomicilio, email = sEmail, apellido_cas = sApellCasada, 
               numcte_ref = sNumcteRef, numcte_banco = cNumCteConyuge, 
               user_insert=cUsuario, fecha_insert = dFechaHoy
         WHERE numcte = cNumCte AND num_solicitud = cNumSolicitud AND parentesco = 'E';
               --secuencia=iSecuencia, 

        SELECT secuencia INTO iSecuencia
          FROM "informix".si_refclientes  
         WHERE numcte = cNumCte AND num_solicitud = cNumSolicitud AND parentesco = 'E';
        
        SELECT dir.calle, dir.colonia, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.municipio, dir.cod_postal, dir.apart_postal, 
               tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono, tel3.tipo_tel, tel3.telefono, tel3.extension, 
               dir.estado_inegi, dir.localidad_inegi, dir.numerociudad, dir.numeroextcalle, dir.numerointcalle, dir.departamento, 
               dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana, dir.otros, dir.andador,
               dir.etapa, dir.lote, dir.edificio, dir.entrada, dir.observaciones, dir.ind_cofeteltel1, dir.ind_cofeteltel2, dir.ind_cofeteltel3
          INTO pcalle, pcolonia, pentre_calles, ppais, pentidad, plocalidad, pmunicipio, pcodpostal,  pApart_postal, ptipotel1, ptelefono1,
               ptipotel2, ptelefono2, ptipotel3, ptelefono3, pextension, pestado_inegi, plocalidad_inegi, pnociudad, pnoext, 
               pnoint, pdepto, pnocalle, pnocolonia, ppuntocar, punihabi, pmanz, ppotros, pandador, 
               petapa, plote, pedif, pentrada, pobserva, pCofeteltel1, pCofeteltel2, pCofeteltel3
          FROM "informix".si_direcciones_actual dir
          LEFT OUTER JOIN "informix".si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN "informix".si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
          LEFT OUTER JOIN "informix".si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
         WHERE dir.numcte = cNumCteConyuge
           AND dir.tipo_dir = cTipoDirCon;
         
        IF cTipoDirCon = '1' THEN
            LET ptipotel3 = '';
            LET ptelefono3 = '';
            LET pextension = '';
        ELSE
            LET ptipotel1 = '';
            LET ptelefono1 = '';
            LET ptipotel2 = '';
            LET ptelefono2 = '';
        END IF;
        
        UPDATE "informix".si_refdirecciones
           SET tipo_dir = cTipoDirCon, calle = pcalle, colonia = pcolonia, entre_calles = pentre_calles, 
               pais = ppais, estado = pentidad, ciudad = plocalidad, municipio = pmunicipio, cod_postal = pcodpostal, apart_postal = pApart_postal, 
               tipo_telef1 = ptipotel1, telefono1 = ptelefono1, tipo_telef2 = ptipotel2, telefono2 = ptelefono2, tipo_telef3 = ptipotel3, telefono3 = ptelefono3, 
               extension = pextension, estado_inegi = pestado_inegi, 
               localidad_inegi = plocalidad_inegi, numerociudad = pnociudad, numeroextcalle = pnoext, numerointcalle = pnoint, departamento = pdepto, numerocalle = pnocalle,
               numerocolonia = pnocolonia, puntocardinal = ppuntocar, unidadhabitac = punihabi, manzana = pmanz, otros =ppotros, andador = pandador, etapa = petapa, 
               lote = plote, edificio = pedif, entrada = pentrada, observaciones = pobserva, 
               numcte_banco = cNumCteConyuge, user_insert = cUsuario, fecha_insert = dFechaHoy, ind_cofeteltel1 = pCofeteltel1, ind_cofeteltel2 = pCofeteltel2, ind_cofeteltel3 = pCofeteltel3
         WHERE numcte = cNumCte AND secuencia = iSecuencia;
    
    RETURN cCodRet;

    END;
    
END PROCEDURE
DOCUMENT
'DOCUMENTACION:',
' Modificación : Rodolfo Tortolero Varela',
'        Fecha : 05/07/2013',
'Funcionalidad : Se crea procedimiento para cuando se capture otro cliente como referencia conyuge, no inserte un nuevo registro,',
'                si no que se actualize la información en el mismo registro del nuevo conyuge.';

CREATE PROCEDURE "informix".sp_obtieneoperacionesdeldia_bei( p_sUsuario CHAR(20), p_dFecha date, pDesde INTEGER, pHasta INTEGER )
    RETURNING CHAR(6), CHAR(10), CHAR(50), CHAR(12), CHAR(12), CHAR(16), CHAR(10), CHAR(40),CHAR(40);

-- *************************************************
-- Realizo: Mauricio Leon Ibarra
-- Modificacion: Consulta las operaciones del dia de usuarios de BEI
--Fecha: 25/10/2011
-- Realizo: Jose Ruben Lopez Hernandez
-- Modificacion:Se agrego el parametro v_sDestinoSpei 
--Fecha: 12/04/2013
-- *************************************************

--Declaracion de variables
DEFINE v_sCodRet CHAR(6);
DEFINE v_sMensajeRet CHAR(60);
DEFINE intcodret        INTEGER;
DEFINE v_sFecha CHAR(10);
DEFINE v_sTransaccion CHAR(50);
DEFINE v_sOrigen CHAR(12);
DEFINE v_sDestino CHAR(12);
DEFINE v_sImporte CHAR(16);
DEFINE v_sFAplicacion CHAR(10);
DEFINE v_sFolio CHAR(40);
DEFINE v_sDestinoSpei CHAR(40);

--Asignacion de variables
LET v_sFecha = '';
LET v_sTransaccion = '';
LET v_sOrigen = '';
LET v_sDestino = '';
LET v_sImporte = '';
LET v_sFAplicacion = '';
LET v_sFolio = '';
LET v_sCodRet = '000';
LET v_sDestinoSpei='';

BEGIN
        ON EXCEPTION SET intcodret
            IF intcodret <> 0 THEN
                LET v_sCodRet  = intcodret;
                RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio,v_sDestinoSpei;
            END IF;
        END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--Se valida que el usuario no este en blanco o en nulo
	IF (NVL(p_sUsuario,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '147';
		RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio,v_sDestinoSpei ;
	END IF;

        FOREACH SELECT SKIP pDesde FIRST pHasta  DATE(fecha_oper), NVL(desc_oper,''), NVL(cuenta_origen,''), NVL(destino,''), NVL(monto_oper,'0.00'), DATE(fecha_aplic), NVL(cgenerico1,''),NVL(cgenerico2,'')
                INTO v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio,v_sDestinoSpei
                FROM bdinteg:"informix".si_bpibitacorapm a, bdinteg:"informix".si_bpioperaciones b
                WHERE DATE(fecha_oper) = DATE(p_dFecha)
                AND a.id_operacion = b.id_oper AND id_usuario = p_sUsuario
				AND id_operacion IN ('1006','1007','1008','1011','1015','1016','1017','1020','2011','2015','2020','1021','1022','1023','3025','3026','3029','3030','2001', '2002', '2003', '2004',  '2005', '2006')
                ORDER BY fecha_oper

                RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio,v_sDestinoSpei WITH RESUME;

        END FOREACH;
END
END PROCEDURE;