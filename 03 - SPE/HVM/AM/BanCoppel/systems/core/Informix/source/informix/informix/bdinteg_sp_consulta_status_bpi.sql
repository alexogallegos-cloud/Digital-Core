CREATE PROCEDURE "informix".sp_consulta_status_bpi(pEmpresa char(3), pNumCte char(9))
	RETURNING char (5),char (4),char (40), integer, date, date,char(1);

--Realizó: Javier A. Chávez Trujillo
--Fecha: 17/12/08
--Solicitó: Mauricio León
--Actividad: Retorna el número y nombre de sucursal asi como el status y la fecha en que se registro


--Realizó: Francisco Rodríguez Ibarra
--Fecha: 18/01/2013
--Solicitó: Walber Castro
--Actividad: Se modifica sp, para retornar el estatus de bloqueo_temporal del cliente de la tabla bpi_avatar.


--Define variables
define sql_err integer;
define cod_ret char (5);
define vSucursal char (4);
define vNombre char(40);
define vFstatus date;
define vIdStatus integer;
define vFregistro date;
define vStatus char(1);

--Inicializa variables
LET sql_err = 0;
LET cod_ret = '000';
LET vSucursal = '';
LET vNombre = '';
LET vFstatus = '';
LET vIdStatus = 0;
LET vFregistro = '';
LET vStatus='';

--SET DEBUG FILE TO "/tmp/Manuel/sp_consulta_status_bpi.out";
--TRACE ON;

BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret, vSucursal, vNombre, vIdStatus, vFstatus, vFregistro,vStatus;
   END EXCEPTION;
   
   SET ISOLATION TO DIRTY READ ;
   SET LOCK MODE TO WAIT 3 ;
   
   IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumcte) THEN

		--Se agrega una fecha default para cuando obtiene las fechas vacias o nulas.
		--SELECT b.suc_registro, c.nombre, b.id_status, b.f_status, b.f_registro 
		SELECT b.suc_registro, c.nombre, b.id_status, NVL(b.f_status,(EXTEND(MDY(1,01,1900), YEAR to DAY))), NVL(b.f_registro,(EXTEND(MDY(1,01,1900), YEAR to DAY))) 
		INTO vSucursal, vNombre, vIdStatus, vFstatus, vFregistro
		FROM bdinteg:"informix".si_bpiusuarios b
		INNER JOIN bdinteg:"informix".si_sucursales c
		ON b.empresa = pEmpresa
			AND b.empresa = c.empresa
			AND b.suc_registro = c.sucursal
		WHERE b.numcte = pNumCte;
		
		--Se agrega este query para traerse el estatus de acceso avatar.
		SELECT bloqueo_temporal INTO vStatus FROM bdibpi:"informix".bpi_avatar WHERE num_cte=TRIM(pNumCte);
		
		IF(NVL(vStatus, '') = '') THEN
			LET vStatus='F';
		END IF;
	ELSE
		LET cod_ret = '001'; -- El cliente No existe
	END IF;

	RETURN cod_ret, vSucursal, vNombre, vIdStatus, vFstatus, vFregistro,vStatus;

END;

END PROCEDURE;