CREATE PROCEDURE "informix".sp_subearchivosnomina ( pArchivoTotales char(40), pArchivoDetalle char(40), pArchivoDat char(40), pMD5ArchivoTotales char(40), pMD5ArchivoDetalle char(40), pMD5ArchivoDat char(40), pFecha date)
RETURNING integer

define vcodret integer ;
define sql_err integer ;	
define vsql char(1024);

Let vcodret =0;
Let vsql = '';

--set debug file to "/tmp/traspasobanco/archivosnomina/sp_subenomina.out";
--trace on;

Begin

	on exception set sql_err
		if sql_err <> 0 then
			let vcodret = sql_err;
			return vcodret;
		end if;
	end exception;

    delete from sc_nominamovimientostemp;
    delete from sc_nominaencabezadosumariotemp;

    let vsql = 'echo "LOAD FROM ' || '''/tmp/traspasobanco/archivosnomina/'|| substr(pArchivoTotales,0,length(pArchivoTotales)) ||'''' || ' DELIMITER ' ||
            '''|''' || ' INSERT INTO sc_nominaencabezadosumariotemp" > /tmp/traspasobanco/archivosnomina/subetotales.sql';
    SYSTEM vsql;

    let vsql = '';
    let vsql = '/ifxsif01/bin/dbaccess bdicheq /tmp/traspasobanco/archivosnomina/subetotales.sql';
    SYSTEM vsql;

    let vcodret = 2;

    let vsql = 'echo "LOAD FROM ' || '''/tmp/traspasobanco/archivosnomina/'|| substr(pArchivoDetalle,0,length(pArchivoDetalle)) ||'''' || ' DELIMITER ' || '''|''' || ' INSERT INTO sc_nominamovimientostemp" > /tmp/traspasobanco/archivosnomina/subedetalle.sql';
    SYSTEM vsql;

    let vsql = '';
    let vsql = '/ifxsif01/bin/dbaccess bdicheq /tmp/traspasobanco/archivosnomina/subedetalle.sql';
    SYSTEM vsql;

    let vcodret = 3;
	
	--Registro de datos MD5 de archivos de dispersion
	INSERT INTO sc_md5_bitacora (nombre_archivo,md5,fecha_gen) values (pArchivoDat,pMD5ArchivoDat,pFecha);
	INSERT INTO sc_md5_bitacora (nombre_archivo,md5,fecha_gen) values (pArchivoTotales,pMD5ArchivoTotales,pFecha);
	INSERT INTO sc_md5_bitacora (nombre_archivo,md5,fecha_gen) values (pArchivoDetalle,pMD5ArchivoDetalle,pFecha);
	

    Return vcodret;

end;
End procedure
DOCUMENT
'Autor: Yonaiker Morillo',
'BD: bdicheq',
'Fecha: 23/07/2021',
'Descripcion: Se modifica para agregar parametros y una insercion de control de archivos de dispersion.';

create procedure "informix".cargocie( pempresa   char(3),
                                      psucursal  char(4),
                                      pusuario   char(8),
                                      ptransacc  char(4),
                                      ptransuc   char(4),
                                      pfolio_suc char(16),
                                      pcuenta    char(20),
                                      pdocto     integer,
                                      pmonto_tot money(14,2) )
returning char(5);
    
    define global vgfecha_hoy  date    default " ";
    define global vgtransisr   char(4) default " ";
    define global vgproducto   char(4) default " ";
    define global vgstatus_cta char(1) default " ";
    
    define vcodret     char(5);
    define vcodret2    char(5);
    define vcodret3    char(50);
    define vsqlerr     integer;
    define visamerr    integer;
    define vdescerr    char(50);
    define vacept_car  char(1);
    define vmotivo     char(2);
    define vsdocong    money(14,2);
    define vsdo_actual money(14,2);
    define vhora       datetime hour to fraction(3);
    define vmesdia     char(4);
    define vhora_w     char(4);
    define vclave      char(5);
    define vopcion     char(2);
    define vfecha_oper date;
    
    let vcodret     = "000";
    let vcodret2    = "";
    let vcodret3    = "";
    let vsqlerr     = 0;
    let visamerr    = 0;
    let vdescerr    = "";
    let vacept_car  = "";
    let vmotivo     = "";
    let vsdocong    = 0.00;
    let vsdo_actual = 0.00;
    let vhora       = "";
    let vmesdia     = "";
    let vhora_w     = "";
    let vclave      = "";
    let vopcion     = "";
    let vfecha_oper = today;
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/resplogifx/conciliachq/cargocie.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret  = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret;
        end if;
    end exception;
    
    --- set debug file to "/resplogifx/conciliachq/cargocie.out";
    --- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 2;
    
    select motivo, sdo_actual
      into vmotivo, vsdo_actual
      from sc_maechq
     where cuenta = pcuenta;
    
    let vhora = current hour to fraction;
    
    insert into sc_movdia values
    ( 0, pfolio_suc, psucursal, pusuario, vgfecha_hoy, vgfecha_hoy, vhora, ptransacc, psucursal, vgproducto, pempresa, pcuenta, 
      " ", pdocto, pmonto_tot, pmonto_tot, 0, 0, 0, " ", vgstatus_cta, vsdo_actual, ptransuc, " ", 0, "", "", "", vfecha_oper );
    
    if vgstatus_cta = "3" and ptransacc = vgtransisr then
        select cargo 
          into vacept_car
          from sc_bloqueo
         where codigo = vmotivo;
        
        select opcion
          into vopcion
          from sc_ctabloqueo
         where cuenta = pcuenta;
        
        if ( vacept_car = "N" or vopcion in("3","4") ) then
            let vsdocong = pmonto_tot;
            let vmesdia  = month(vgfecha_hoy) || day(vgfecha_hoy);
            
            insert into sc_histbloq 
            ( empresa, cuenta, tipo_mov, motivo, opcion, importe, usuario, fecha, hora, clave, status_blo, folio_suc, referencia )  
            values
            ( pempresa, pcuenta, "B", vmotivo, vopcion, pmonto_tot, pusuario, vgfecha_hoy, vhora, " ", " ", " ", " ");
            
            insert into sc_movdia values
            ( 0, pfolio_suc, psucursal, pusuario, vgfecha_hoy, vgfecha_hoy, vhora, "3353", psucursal, vgproducto, pempresa, pcuenta,
              " ", pdocto, pmonto_tot, pmonto_tot, 0, 0, 0, " ", vgstatus_cta, vsdo_actual, ptransuc, " ", 0, "", "", "", vfecha_oper );
        else
            let vsdocong = 0;
        end if;
    else
        let vsdocong = 0;
    end if;
    
    update sc_maechq
       set sdo_actual = sdo_actual - pmonto_tot,
           imp_cgos_mes = imp_cgos_mes + pmonto_tot,
           num_cgos_mes = num_cgos_mes + 1,
           fec_ult_mov = vgfecha_hoy
     where cuenta = pcuenta;
    
    return vcodret;
    
    end;
    
end procedure
document 
'Se realiza modificacion al procedimiento en los inserts a la tablas sc_ctabloqueo y sc_histbloq',
'Modifico : Jesús Manuel Aguilar Heredia',
'FECHA : 15/SEPTIEMBRE/2010',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".verificatarjetacancelada_web(pNumTarjeta CHAR(16), pOpcion SMALLINT)
	--DATOS A REGRESAR---
	RETURNING
			CHAR(5) As Cod_Ret,
			CHAR(1) As Status_Tar_Cred;  

	--DEFINICION DE VARIABLES--
    DEFINE vCantReg         SMALLINT; 
    DEFINE vCodRet          CHAR(5);
    DEFINE vCodStatusint    CHAR(3);
    DEFINE vCodStatuschq    CHAR(1);
    DEFINE vCodStatuscred   CHAR(1);
	DEFINE cProducto        CHAR(100);
	DEFINE cProductoTarjeta CHAR(4);
	DEFINE iBanderaPro      INTEGER;
	
	--INICIALIZACION DE VARIABLES--
	LET vCodRet  		 = "00000";
	LET vCantReg 		 = 0;
    LET vCodStatusint  	 = "";
    LET vCodStatuschq  	 = "";
    LET vCodStatuscred 	 = "";
	LET cProducto      	 = '';
	LET cProductoTarjeta = '';
	LET iBanderaPro      = 0;
	
	--SET DEBUG FILE TO '/tmp/verificatarjetacancelada.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    IF pOpcion = 1 THEN
		SELECT TRIM(valor)
		INTO cProducto
		FROM bditransfer:"informix".tf_param 
		WHERE empresa = '001'
        AND cod_param = '4';
		
        SELECT inttar.codstatustarjeta, chqtar.status_tar, chqtar.prodtarjeta
        INTO  vCodStatusint, vCodStatuschq, cProductoTarjeta
        FROM intercard:"informix".tarjeta inttar,
            bdicheq:"informix".sc_tarjeta chqtar
        WHERE inttar.numtarjeta = pNumTarjeta 
		AND chqtar.empresa = '001'
        AND chqtar.num_tarjeta = pNumTarjeta;
		  
		IF TRIM(cProducto) <> NVL(cProductoTarjeta, '') THEN 
			LET iBanderaPro = 0;
		ELSE
			LET iBanderaPro = 1;
		END IF;
    ELSE
        SELECT inttar.codstatustarjeta, credtar.status_tar
        INTO vCodStatusint, vCodStatuscred
        FROM intercard:"informix".tarjeta inttar,
            bdicred:"informix".sd_tarjeta credtar
        WHERE inttar.numtarjeta = pNumTarjeta 
           AND credtar.num_tarjeta = pNumTarjeta
           AND credtar.empresa = '001';
    END IF

	IF iBanderaPro = 0 THEN 
	
		--DSB 2010-10-28 Manuel Ramos Figueroa
		--Cancela la tarjeta en la bdicheq:sc_tarjeta o bdicred:sd_tarjeta segun sea el caso, si aparese activa y cancelada en la intercard:tarjeta
		--IF vCodStatusint <> 'ACT' AND (vCodStatuschq = 'C' OR vCodStatuscred = 'C') THEN
		IF vCodStatusint <> 'ACT' THEN
			--Se validan los estatus BLT,BLO,NOA los cuales no se debe cancelar la tarjeta
			IF vCodStatusint = 'BLT' OR vCodStatusint = 'BLO' OR vCodStatusint = 'NOA' THEN --DSB 22/Feb/2011
				LET vCodRet = "00011";
			ELSE
				IF (vCodStatuschq = 'A') THEN
					UPDATE bdicheq:sc_tarjeta SET status_tar='C' WHERE num_tarjeta=pNumTarjeta AND empresa='001';
				ELIF (vCodStatuscred = 'A') THEN
					UPDATE bdicred:sd_tarjeta SET status_tar='C' WHERE num_tarjeta=pNumTarjeta AND empresa='001';
				END IF
				IF  vCodStatuscred <> 'I' THEN
					LET vCodRet = "00111";
				END IF
			END IF
		END IF

		LET vCantReg = DBINFO("sqlca.sqlerrd2");

		IF vCantReg = 0 THEN
			LET vCodRet = "00132";
		END IF
	ELSE
		LET vCodRet = '00858';
	END IF;
    RETURN vCodRet,vCodStatuscred;
END PROCEDURE
DOCUMENT
'ModificÃ³: Manuel Ramos Figueroa',
'Fecha: 28/Octubre/2010',
'Descripcion: Se modifica para actualizar el campo status_tar a cancelado "C" de la bdicheq:sc_tarjeta o bdicred:sd_tarjeta segun sea el caso',
             'cuando estÃ¡ este cancelada en la intercard:tarjeta.',
'BD: bdicheq',
'ModificÃ³: Marcos Cuevas',
'Fecha: 22/Feb/2011',
'Descripcion: Se modifica para aÃ±adir validacion sobre los estatus BLT,BLO,NOA',
'                                                                                                                          ',
'ModificÃ³ : MartÃ­n Eduado Miranda Miranda',
'Fecha: 20/06/2012',
'DescripciÃ³n: Se modifica Procedimiento Almacenado para retornar el status de la Tarjeta para el caso de TDC',
'',
'Folio: 1611',
'AUTOR :95594213 Leonardo Plata',
'FECHA : 01/07/2014',
'MODIFICACIÃN: Se Modifica sp para que en caso de que el producto de la tarjeta sea 8000 retorne codigo de error',
'SUSTENTO: modificaciones_promotoria.pdf',
'SOLICITA: Rodolfo Gomez ',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_movimientos_pos_debito()
RETURNING CHAR(5)   AS cod_ret,
		  CHAR(100) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE SQL_ERR	INTEGER;
DEFINE ISAM_ERR	INTEGER;
DEFINE DATA_ERR	CHAR(95);
DEFINE ROWS_NUM INTEGER;

DEFINE dFechaIni	DATE;
DEFINE dFechaFin 	DATE;
DEFINE cCuenta 		CHAR(20);
DEFINE mMonto 		MONEY;
DEFINE mSaldo		MONEY;
DEFINE cSucursal	CHAR(4);
DEFINE cEmpresa1	CHAR(3);
DEFINE dFechaAlta	DATE;
DEFINE cFolioSuc	CHAR(16);
DEFINE dtFechaHora	DATETIME HOUR TO FRACTION (3);
DEFINE iNumSerial	INTEGER;
DEFINE cTransaccion	CHAR(4);
DEFINE cReferencia	CHAR(40);
DEFINE cCancelado	CHAR(1);
DEFINE cEmpresa2	CHAR(3);
DEFINE cDescripcion	CHAR(50);
DEFINE cEdoCuenta	CHAR(1);
DEFINE cNaturaleza	CHAR(1);
DEFINE cNumero		CHAR(4);
DEFINE cNomComercio	CHAR(30);
DEFINE dtFechaTx  	DATETIME YEAR to FRACTION(5);
DEFINE cRfc			CHAR(15);

LET ROWS_NUM = 0;

LET cCuenta 	 = '';
LET mMonto 		 = 0;
LET mSaldo		 = 0;
LET cSucursal	 = '';
LET cEmpresa1	 = '';
LET dFechaAlta	 = TODAY;
LET cFolioSuc	 = '';
LET dtFechaHora	 = CURRENT;
LET iNumSerial	 = 0;
LET cTransaccion = '';
LET cReferencia	 = '';
LET cCancelado	 = '';
LET cEmpresa2	 = '';
LET cDescripcion = '';
LET cEdoCuenta	 = '';
LET cNaturaleza	 = '';
LET cNumero		 = '';
LET cNomComercio = '';
LET dtFechaTx  	 = CURRENT;
LET cRfc		 = '';

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, DATA_ERR
        IF ROWS_NUM <> 0 THEN
			COMMIT WORK;
		END IF
		
		IF SQL_ERR <> 0 OR ISAM_ERR <> 0 THEN
			RETURN SQL_ERR, ISAM_ERR||DATA_ERR;
		END IF
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/jepolanco/sp_movimientos_pos_debito.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy INTO dFechaFin FROM bdinteg:si_fechas;
	LET dFechaIni = dFechaFin - 15;
    
	BEGIN WORK;
		TRUNCATE TABLE bdicheq:"informix".sc_movdescpos;
	COMMIT WORK;			
	
	FOREACH WITH HOLD
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_movhis_old)} cuenta, monto_tot, sdo_cuenta, sucursal,	empresa, fech_alt, folio_suc, fech_hor,	num_serial, transacc, referencia, cancelad
		INTO cCuenta, mMonto, mSaldo, cSucursal, cEmpresa1, dFechaAlta, cFolioSuc, dtFechaHora, iNumSerial, cTransaccion, cReferencia, cCancelado
		FROM bdicheq:"informix".sc_movhis_old
		WHERE fech_alt BETWEEN dFechaIni AND dFechaFin AND cancelad <> 'S' AND transacc IN ('0813','0830')
		UNION
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_movhis)} cuenta, monto_tot, sdo_cuenta, sucursal,	empresa, fech_alt, folio_suc, fech_hor,	num_serial, transacc, referencia, cancelad	
		FROM bdicheq:"informix".sc_movhis
		WHERE fech_alt BETWEEN dFechaIni AND dFechaFin AND cancelad <> 'S' AND transacc IN ('0813','0830')
		UNION
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_movdia)} cuenta, monto_tot, sdo_cuenta, sucursal,	empresa, fech_alt, folio_suc, fech_hor,	num_serial, transacc, referencia, cancelad
		FROM bdicheq:"informix".sc_movdia
		WHERE fech_alt BETWEEN dFechaIni AND dFechaFin AND cancelad <> 'S' AND transacc IN ('0813','0830')
		
		LET cReferencia = TRIM(cReferencia);
		IF cReferencia IS NULL OR cReferencia = '' THEN
			LET cReferencia = cTransaccion;
		END IF
		
		SELECT empresa, descripcion, se_emite_edocta, naturaleza, numero
		INTO cEmpresa2, cDescripcion, cEdoCuenta, cNaturaleza, cNumero
		FROM bdinteg:"informix".si_transacc
		WHERE empresa = '001' AND se_emite_edocta = 'S' AND numero = cTransaccion;
		
		IF cTransaccion = '0830' THEN
			SELECT LIMIT 1 nomcomercio325, fechatransaccion, rfc325 
			INTO cNomComercio, dtFechaTx, cRfc
			FROM bditarjeta:"informix".td_movimientos_conciliacion WHERE numcuenta = cCuenta AND folio_mov = cFolioSuc AND tipotransaccion325 = '01';
		ELIF cTransaccion = '0813' THEN
			SELECT LIMIT 1 nomcomercio325, fechatransaccion, rfc325 
			INTO cNomComercio, dtFechaTx, cRfc
			FROM bditarjeta:"informix".td_movimientos_conciliacion WHERE numcuenta = cCuenta AND folio_mov = cFolioSuc AND tipotransaccion325 = '21';			
		END IF
		
		IF ROWS_NUM = 0 THEN
			BEGIN WORK;
		END IF
		
		IF iNumSerial IS NULL THEN
			LET iNumSerial = '';
		END IF
		
		IF cNumero IS NULL THEN
			LET cNumero = '';
		END IF
		
		INSERT INTO bdicheq:"informix".sc_movdescpos (cuenta, monto_tot, sdo_cuenta, sucursal, empresa, fech_alt, folio_suc, fech_hor, num_serial, transacc, referencia, cancelad, empresa1, descripcion, se_emite_edocta, naturaleza, numero, payment, nomcomercio325, fechatransaccion, rfc325)
		VALUES (cCuenta, mMonto, mSaldo, cSucursal, cEmpresa1, dFechaAlta, cFolioSuc, dtFechaHora, iNumSerial, cTransaccion, cReferencia, cCancelado, cEmpresa2, cDescripcion, cEdoCuenta, cNaturaleza, cNumero, '', cNomComercio, dtFechaTx, cRfc);
		
		LET ROWS_NUM = ROWS_NUM + 1;
		IF ROWS_NUM = 1000 THEN
			COMMIT WORK;
			LET ROWS_NUM = 0;			
		END IF
	END FOREACH
	
	IF 	ROWS_NUM <> 0 THEN
		COMMIT WORK;
		LET ROWS_NUM = 0;
	END IF
	
	RETURN '00000', 'TERMINÃ CORRECTAMENTE';
	
END;
END PROCEDURE;