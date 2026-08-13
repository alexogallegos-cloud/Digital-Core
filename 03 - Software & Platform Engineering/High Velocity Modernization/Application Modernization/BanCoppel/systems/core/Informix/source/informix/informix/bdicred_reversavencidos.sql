create procedure "informix".reversavencidos(empresa char(3))
returning char(6);

define vFechaHoy date;
define MVencido decimal;
define vFolioSuc   char(16);
define vSuc    char(4);
define NumCred CHAR(20);
define vStatus CHAR(2);
define pcodret varchar(10);
define mensaje varchar(80);

begin

    select fecha_hoy Into vFechaHoy from sd_fechas where empresa = '001';

    FOREACH
	SELECT num_credito, monto_vencido
	  INTO NumCred, MVencido
	  FROM pasovencido

        select sucursal, status_cred
	  Into vSuc, vStatus
	  from sd_maecred
	 where num_credito = NumCred;

	IF vStatus = "AA" THEN
		CONTINUE FOREACH;
	END IF

        update sd_maecred
	   set status_cred = 'AA'
	 where num_credito = NumCred;

	update sd_maesdos
	   set sdo_capital = sdo_capital + MVencido,
	       monto_vencido = 0
	 where num_credito = NumCred;

        select user|| substr(current,  12, 2) ||
		      substr(current, 15,2) ||
                      substr(current, 18,2)
	  Into vFolioSuc
	  from dual;

	let MVencido = MVencido * -1;
        call genmov('001', NumCred, '6001', 1, '602',
		    vFechaHoy, MVencido, vFolioSuc, vSuc, '01', '0000')
	returning pcodret, mensaje;


    end foreach;
end;
end procedure;