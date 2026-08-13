CREATE PROCEDURE "informix".sp_consultacuentadebito(pnumcuenta CHAR(12),pnumcliente CHAR(9),pnumtarjeta char(16),pfecini DATE,pfecfin DATE,ptipobusqueda smallint)
	RETURNING CHAR(5),CHAR(12),CHAR(9),CHAR(16),CHAR(40),CHAR(25),CHAR(25),CHAR(25),CHAR(25),INTEGER,CHAR(30);
	--************************************
	--sp_consultacuentadebito
	--objetivo: Obtiene las cuentas de debito , ya sea por numcliente, por cuenta o por numtarjeta
	--Autor: Francisco Rodriguez Ibarra
	--Fecha: 30 Abril 2010
	--****************************************
	--Declaracion de Variables
	DEFINE vsCodRet 	CHAR(5);
	DEFINE vSqlErr		INTEGER;
	DEFINE vnumcuenta	CHAR(12);
	DEFINE vnumcliente  CHAR(9);
	DEFINE vnumtarjeta  CHAR(16);
	DEFINE vproducto   CHAR(40);
	DEFINE vquery		CHAR(50);
	DEFINE iCont		INTEGER;
	DEFINE vsecuencia   INTEGER;
	DEFINE vnombre1 CHAR(25);
	DEFINE vnombre2 CHAR(25);
	DEFINE vnombre3 CHAR(25);
	DEFINE vnombre4 CHAR(25);
	DEFINE vstatus   CHAR(30);


	--Asignacion de Valores a Variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vnumcuenta="";
	LET vnumcliente="";
	LET vnumtarjeta="";
	LET vproducto="";
	LET vquery="";
	LET iCont=0;
	LET vnombre1 = "";
	LET vnombre2 = "";
	LET vnombre3 = "";
	LET vnombre4 = "";
	LET vsecuencia=0;
	LET vstatus="";
	BEGIN

		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
				--ROLLBACK WORK;

	            RETURN vsCodRet,vnumcuenta, vnumcliente, vnumtarjeta, vproducto,vnombre1,vnombre2,vnombre3,vnombre4,vsecuencia,vstatus;
	      END IF;

		END EXCEPTION;

		SET ISOLATION DIRTY READ;

		--Busqueda por  numero de cuenta
		IF(ptipobusqueda = 1) THEN
			FOREACH
				select b.cuenta, a.numcliente, a.numtarjeta, c.nombre as Producto,
						d.nombre1,d.nombre2, d.apell_paterno, d.apell_materno, b.secuencia,e.descstatustarjeta
						into vnumcuenta,vnumcliente,vnumtarjeta,vproducto,vnombre1,vnombre2,vnombre3,vnombre4,vsecuencia,vstatus
				from intercard:tarjeta a
				left outer join bdicheq:sc_tarjeta b on (a.numtarjeta = b.num_tarjeta)
				left outer join bdicheq:sc_producto c on (b.prodtarjeta = c.producto)
                left outer join bdinteg:si_cliente d on (a.numcliente = d.numcte)
				left outer join intercard:statustarjeta e on (a.codstatustarjeta = e.codstatustarjeta)
				where  b.cuenta=trim(pnumcuenta)

				LET iCont = iCont + 1;

				RETURN vsCodRet,vnumcuenta, vnumcliente, vnumtarjeta, vproducto,vnombre1,vnombre2,vnombre3,vnombre4,vsecuencia,vstatus WITH RESUME;

			END FOREACH
		END IF

		--Busqueda por numero de cliente
		IF (ptipobusqueda = 2) THEN
			FOREACH
				select  a.numcliente,b.cuenta, a.numtarjeta, c.nombre as Producto,
						d.nombre1,d.nombre2, d.apell_paterno, d.apell_materno, b.secuencia,e.descstatustarjeta
						into vnumcliente,vnumcuenta,vnumtarjeta,vproducto,vnombre1,vnombre2,vnombre3,vnombre4,vsecuencia,vstatus
				from intercard:tarjeta a
				left outer join bdicheq:sc_tarjeta b  on(a.numtarjeta= b.num_tarjeta)
				left outer join bdinteg:si_cliente d on(d.numcte = a.numcliente )
				left outer join bdicheq:sc_producto c on ( c.producto = b.prodtarjeta)
				left outer join intercard:statustarjeta e on (a.codstatustarjeta = e.codstatustarjeta)
               	where  b.numcte=trim(pnumcliente)

				LET iCont = iCont + 1;

				RETURN vsCodRet,vnumcuenta, vnumcliente, vnumtarjeta, vproducto,vnombre1,vnombre2,vnombre3,vnombre4,vsecuencia,vstatus WITH RESUME;

			END FOREACH

		END IF

		--Busqueda  por numero de tarjeta
		IF (ptipobusqueda = 3) THEN
			FOREACH
				select b.cuenta, a.numcliente, a.numtarjeta, c.nombre as Producto,
						d.nombre1,d.nombre2, d.apell_paterno, d.apell_materno, b.secuencia,e.descstatustarjeta
						into vnumcuenta,vnumcliente,vnumtarjeta,vproducto,vnombre1,vnombre2,vnombre3,vnombre4,vsecuencia,vstatus
				from intercard:tarjeta a
				left outer join bdicheq:sc_tarjeta b on (a.numtarjeta=b.num_tarjeta)
				left outer join bdinteg:si_cliente d on (d.numcte = a.numcliente)
				left outer join bdicheq:sc_producto c on (c.producto = b.prodtarjeta)
				left outer join intercard:statustarjeta e on (a.codstatustarjeta = e.codstatustarjeta)
				where  b.num_tarjeta=trim(pnumtarjeta)

				LET iCont = iCont + 1;

				RETURN vsCodRet,vnumcuenta, vnumcliente, vnumtarjeta, vproducto,vnombre1,vnombre2,vnombre3,vnombre4,vsecuencia,vstatus WITH RESUME;

			END FOREACH

		END IF

		IF ( iCont = 0 ) THEN
			LET vsCodRet = 101; --Cliente No tiene cuentas
			RETURN vsCodRet,vnumcuenta, vnumcliente, vnumtarjeta, vproducto,vnombre1,vnombre2,vnombre3,vnombre4,vsecuencia,vstatus;
		END IF
	END;
END PROCEDURE;