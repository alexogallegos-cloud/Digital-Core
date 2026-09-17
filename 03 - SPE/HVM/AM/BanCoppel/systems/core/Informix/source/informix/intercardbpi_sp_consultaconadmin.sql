CREATE PROCEDURE "informix".sp_consultaconadmin(
psArchivoOrigen CHAR(3),
pdFecha DATE
)

RETURNING	CHAR(3) AS archivoorigen, CHAR(23) AS nomarchivo325, CHAR(23) AS nomarchivocom, DATE AS fecharegistro, DATE AS fecha, CHAR(4) AS prodtarjeta, CHAR(16) AS tarjeta,
			CHAR(12) AS cuenta, CHAR(1) AS tipomov, CHAR(4) AS tran_central, CHAR(15) AS folio325, MONEY(16,6) AS monto325, CHAR(1) AS estatus, CHAR(4) AS txnliberacion, CHAR(19) AS cuentac,
			CHAR(19) AS cuentaa, CHAR(15) AS foliosif, MONEY(16,6) AS montosif, CHAR(7) AS secintercard, MONEY(16,6) AS montointcrd, DATETIME YEAR TO FRACTION(5) AS fechahorainauth, CHAR(4) AS idterminal,
			CHAR(1) AS tipooperacion, CHAR(8) AS usuario, DATETIME YEAR TO FRACTION(5) AS fechamov, MONEY(16,6) AS monto, MONEY(16,6) AS comision, MONEY(16,6) AS comisioniva;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de interredes, obtiene informacion de tabla conadmin y conarchcomisiones.
-- AUTOR : Rochin Rocha Edgar Ivan 
-- FECHA : 01/19/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen		CHAR(3);
DEFINE vsnomarchivo325		CHAR(23);
DEFINE vsnomarchivo			CHAR(23);
DEFINE vsnomarchivocom		CHAR(23);
DEFINE vdfecharegistro		DATE;
DEFINE vdfecha				DATE;
DEFINE vsprodtarjeta		CHAR(4);
DEFINE vstarjeta			CHAR(16);
DEFINE vscuenta				CHAR(12);
DEFINE vstipomov			CHAR(1);
DEFINE vstran_central		CHAR(4);
DEFINE vsfolio325			CHAR(15);
DEFINE vmmonto325			MONEY(16,6);
DEFINE vsestatus			CHAR(1);
DEFINE vstxnliberacion		CHAR(4);
DEFINE vscuentac			CHAR(19);
DEFINE vscuentaa			CHAR(19);
DEFINE vsfoliosif			CHAR(15);
DEFINE vmmontosif			MONEY(16,6);
DEFINE vssecintercard		CHAR(7);
DEFINE vmmontointcrd		MONEY(16,6);
DEFINE vdfechahorainauth	DATETIME YEAR TO FRACTION(5);
DEFINE vsidterminal			CHAR(4);
DEFINE vstipooperacion		CHAR(1);
DEFINE vsusuario			CHAR(8);

DEFINE vdfechamov			DATETIME YEAR TO FRACTION(5);
DEFINE vmmonto				MONEY(16,6);
DEFINE vmcomision			MONEY(16,6);
DEFINE vmcomisioniva		MONEY(16,6);


DEFINE viSqlErr				INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vsnomarchivo325 = '';
LET vsnomarchivo	= '';
LET vsnomarchivocom = '';
LET vdfecharegistro = CURRENT;
LET vdfecha = CURRENT;
LET vsprodtarjeta = '';
LET vstarjeta = '';
LET vscuenta = '';
LET vstipomov = '';
LET vstran_central = '';
LET vsfolio325 = '';
LET vmmonto325 = 0.0;
LET vsestatus = '';
LET vstxnliberacion = '';
LET vscuentac = '';
LET vscuentaa = '';
LET vsfoliosif = '';
LET vmmontosif = 0.0;
LET vssecintercard = '';
LET vmmontointcrd = 0.0;
LET vdfechahorainauth = CURRENT;
LET vsidterminal = '';
LET vstipooperacion = '';
LET vsusuario = '';

LET vdfechamov = CURRENT;
LET vmmonto = 0.0;
LET vmcomision = 0.0;
LET vmcomisioniva = 0.0;

LET viSqlErr = 0;

--set debug file to "/informixuc7/perifericos/prueba.out";
--Trace on;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '' WITH RESUME;
	END IF; 
END EXCEPTION ;

SET ISOLATION TO DIRTY READ ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
	--El campo archivo origen esta en blanco o nulo.
	LET vsarchivoorigen = '001';
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '';
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
	--El campo fecha esta en blanco o nulo.
	LET vsarchivoorigen = '002';
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '';
ELSE
	--Verifica si el archivoorigen proporcionado fue archivo de comisiones(ADC).
	IF(psArchivoOrigen = 'ADC')THEN
        LET pdFecha = MDY(Month(pdFecha),day(pdFecha),year(pdFecha)) -1 units day;
        FOREACH
		SELECT idterminal, fechamov, monto, comision, comisioniva
		INTO   vsidterminal, vdfechamov, vmmonto, vmcomision, vmcomisioniva
		FROM   intercard:conarchcomisiones
        WHERE  fechamov::DATE = pdFecha ORDER BY keyx ASC
		RETURN '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
			   NVL(vsidterminal,''), '', '', NVL(vdfechamov,CURRENT), NVL(vmmonto,0.0), NVL(vmcomision,0.0), NVL(vmcomisioniva,0.0) WITH RESUME;
		END FOREACH
	ELSE
		IF (psArchivoOrigen = 'TCD') THEN
			LET vsnomarchivo = TRIM ('BCPLTCD_' || LPAD(day(pdFecha),2,'0') || LPAD(Month(pdFecha),2,'0') || year(pdFecha) || '.TXT');
		ELSE
			LET vsnomarchivo = TRIM ('BCPLTCC_' || LPAD(day(pdFecha),2,'0') || LPAD(Month(pdFecha),2,'0') || year(pdFecha) || '.TXT');
		END IF;	
	
		FOREACH
		SELECT {+index (intercard:conadmin idx_conadmin4)} archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion,
			   cuentac, cuentaa, foliosif, montosif, secintercard, montointcrd, fechahorainauth, idterminal, tipooperacion, usuario
		INTO   vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
			   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario
		FROM   intercard:conadmin
		WHERE  archivoorigen = psArchivoOrigen and nomarchivo325 = vsnomarchivo ORDER BY keyx ASC

		RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
			   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '' WITH RESUME;
               
        END FOREACH
	END IF;
END IF;

END
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Consulta de administracion de interredes, obtiene informacion de tabla conadmin y conarchcomisiones.',
'Fecha: 01/19/2010',
'Version: 20100119.1025',
'BD: Intercard',
'',
'Modificado: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: En caso de que se consulte por archivo de comisiones(ADC) realizara la busqueda en tabla conarchcomisiones.',
'Fecha: 02/05/2010',
'Version: 20100205.1745',
'BD: Intercard''',
'Modificado: Javier Chavez BANCOPPEL',
'Proyecto: Conciliacion Automatica',
'Descripcion: Le dan formato al parametro de fecha justo despues de validar si es consulta por archivo de comisiones(ADC).Cambian el between por una comparacion simple entre la fechamov y el parametro de entrada fecha(esto solo lo realizaron en caso de ser ADC).',
'Fecha: 02/19/2010',
'Version: 20100219.1645',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de las variables de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1137',
'BD: Intercard',
'',
'Modificado: Ponce Damian Juan Fco.',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se modifica la consulta de interredes para su optización.',
'Fecha: 2012/07/11',
'Version: 20120711.1730',
'BD: Intercard'*/
;

CREATE PROCEDURE "informix".sp_interepor(pcodgironeg varchar(1),pidreceptor varchar(40),paniome varchar(6))
RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vsql                    char(1150);
DEFINE  vcodgironegs            varchar(1);
DEFINE  vinfreceptor            varchar(40);
DEFINE  vaniomes                varchar(6);


-------------- control de errores---------

--SET DEBUG FILE TO "/informix/resplogifx/interepor.out";
--TRACE ON;

BEGIN 
 ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            END IF;
 END EXCEPTION; 
 
ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr = -958  then	
                  if error_info ='informix.pasoprincipal' then
				     drop table pasoprincipal;
				  end if			
	              if error_info ='informix.paso2' then
				     drop table paso2;
				  end if			   
                  if error_info ='informix.paso3' then
				     drop table paso3;					  
				  end if
				  if error_info ='informix.paso_nego' then
				     drop table paso_nego;					  
				  end if
				   if error_info ='informix.paso_estab' then
				     drop table paso_estab;					  
				  end if
				  if error_info ='informix.paso_camp' then
				     drop table paso_camp;
				  end if		     
				  				   
		    END IF;    
 END EXCEPTION WITH RESUME;
    

LET  vcodgironegs = pcodgironeg;   
LET  vinfreceptor = pidreceptor; 
LET  vaniomes = paniome;


-------Cuerpo de SP Consulta Seguimiento a Campaña.
  IF (vcodgironegs = '' and vinfreceptor = '' and  vaniomes = '' )THEN
 
      EXECUTE PROCEDURE intercard:sp_reportenegocio() INTO vcodret,p_mensaje;
	  
	    return vcodret, p_mensaje;
	
	ELIF ((vcodgironegs is not null) and (vinfreceptor is not null) and ( vaniomes  is not null) ) THEN
	
	  EXECUTE PROCEDURE intercard:sp_segcamp (vcodgironegs,vinfreceptor,vaniomes) INTO vcodret,p_mensaje;

        return vcodret, p_mensaje;
	  
  ELSE
    LET vcodret = '0003';
    LET  p_mensaje  = 'Existe un error';
    return vcodret, p_mensaje;
	 
  END IF;
end;
END PROCEDURE;