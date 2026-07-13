CREATE PROCEDURE "informix".sp_inserta_atm_ofi(pempresa CHAR(3),
                                           pcod_atm CHAR(4), 
                                           pdivisa  CHAR(2), 
                                           pcant_1  FLOAT,
                                           pcant_2  FLOAT,
                                           pcant_3  FLOAT,
                                           pcant_4  FLOAT,
                                           pcant_5  FLOAT,
                                           pcant_6  FLOAT,
										   pcant_7  FLOAT,
										   pcant_8  FLOAT,
										   pcant_9  FLOAT,
										   pcant_10  FLOAT,
                                           pmonto   DECIMAL(14,2))
RETURNING CHAR(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vden01 CHAR(5);
DEFINE vden02 CHAR(5);
DEFINE vden03 CHAR(5);
DEFINE vden04 CHAR(5);
DEFINE vden05 CHAR(5);
DEFINE vden06 CHAR(5);
DEFINE vden07 CHAR(5);
DEFINE vden08 CHAR(5);
DEFINE vden09 CHAR(5);
DEFINE vden10 CHAR(5);
DEFINE vden11 CHAR(5);
DEFINE vSaldo_ant MONEY (14,2);
DEFINE vSaldo_asi MONEY (14,2);
DEFINE vSaldo_tot MONEY (14,2);
DEFINE bTransacInterAct	  CHAR(1);
DEFINE bEnTransac         CHAR(1);

DEFINE vcant_1  FLOAT;
DEFINE vcant_2  FLOAT;
DEFINE vcant_3  FLOAT;
DEFINE vcant_4  FLOAT;
DEFINE vcant_5  FLOAT;
DEFINE vcant_6  FLOAT;
DEFINE vcant_7  FLOAT;
DEFINE vcant_8  FLOAT;
DEFINE vcant_9  FLOAT;
DEFINE vcant_10  FLOAT;
DEFINE vmonto   DECIMAL(14,2);
DEFINE vmonto_ant   DECIMAL(14,2);

LET vcodret = "000";
LET vsqlerr = 0;
LET vden01 = "";
LET vden02 = "";
LET vden03 = "";
LET vden04 = "";
LET vden05 = "";
LET vden06 = "";
LET vden07 = "";
LET vden08 = "";
LET vden09 = "";
LET vden10 = "";
LET vden11 = "";
LET vSaldo_ant = "";
LET vSaldo_asi = "";
LET vSaldo_tot = "";
LET bTransacInterAct = 'F';
LET bEnTransac = 'F';

LET vcant_1 = "";
LET vcant_2 = "";
LET vcant_3 = "";
LET vcant_4 = "";
LET vcant_5 = "";
LET vcant_6 = "";
LET vcant_7 = "";
LET vcant_8 = "";
LET vcant_9 = "";
LET vcant_10 = "";
LET vmonto = "";
LET vmonto_ant = "";

BEGIN

ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
			IF bTransacInterAct = 'T' THEN		--DSB20150429 {
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					BEGIN WORK;
				END IF;
			ELSE
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
				ELSE
					ROLLBACK WORK;
				END IF;							
			END IF;	

            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF;
END EXCEPTION;

ON EXCEPTION IN (-535)				--DSB20150429 {
	LET bTransacInterAct = 'T';
	LET bEnTransac = 'T';
	COMMIT WORK;
	BEGIN WORK;
END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN WORK;

--SET debug file to "/tmp/Ricardo/sp_inserta_atm.out";
--trace on;

--Modificado por: PAUL IVAN QUINTERO VARELA
--25-09-2019
--Se agrega el respaldo previo a las afectaciones operativas de la transacción
--Se agrega la transaccionalidad en el proceso.

IF EXISTS (SELECT cod_atm FROM bdisuc:"informix".ss_atm WHERE cod_atm = pcod_atm) THEN
	
	DELETE FROM ss_atm_rec WHERE empresa = pempresa AND cod_atm = pcod_atm;
	
	INSERT INTO ss_atm_rec 
	SELECT * FROM ss_atm WHERE empresa = pempresa AND cod_atm = pcod_atm; 

	UPDATE bdisuc:"informix".ss_atm SET cantidad_1 = cantidad_1 + pcant_1,cantidad_2 = cantidad_2 + pcant_2,cantidad_3 = cantidad_3 + pcant_3,cantidad_4 = cantidad_4 + pcant_4,cantidad_5 = cantidad_5 + pcant_5,cantidad_6 = cantidad_6 + pcant_6,cantidad_7 = cantidad_7 + pcant_7, cantidad_8 = cantidad_8 + pcant_8,cantidad_9 = cantidad_9 + pcant_9,cantidad_10 = cantidad_10 + pcant_10,
	saldo_anterior = saldo_total,saldo_asignado = 0,saldo_total = saldo_total + pmonto
	WHERE empresa = pempresa AND cod_atm = pcod_atm;

ELSE
	LET vden01 = '1000';
	LET vden02 = '500';
	LET vden03 = '200';
	LET vden04 = '100';
	LET vden05 = '50';
	LET vden06 = '20';
	LET vden07='10';
    LET vden08='5';
    LET vden09='2';
    LET vden10='1';
    LET vden11 = '-1';
	
	DELETE FROM ss_atm_rec WHERE empresa = pempresa AND cod_atm = pcod_atm;
	
	INSERT INTO bdisuc:"informix".ss_atm (empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3, denominacion_4,denominacion_5,denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,	denominacion_11,denominacion_12,denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,
	cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
	cantidad_13,cantidad_14,cantidad_15)
	VALUES (pempresa, pcod_atm, pdivisa, 0, 0,pmonto,vden01, vden02, vden03, vden04, vden05, vden06,vden07,vden08,vden09,vden10,vden11,0,0,0,0,pcant_1,
			pcant_2,pcant_3,pcant_4,pcant_5,pcant_6,pcant_7,pcant_8,pcant_9,pcant_10,'0','0','0','0','0');

END IF;

COMMIT WORK;

IF bTransacInterAct = 'T' THEN
	BEGIN WORK;
END IF;


RETURN vcodret;

END
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:RecepDota.exe',
'AUTOR:Cristian Valentina Aguilar ', 
'FECHA:2019-11-11',
'DESCRIPCION: Se modifica SP para realizar respaldo de la información en caso de que ocurra algun error restaurar los datos de la tabla de recuperación',
'SOLICITA: Gabriela Angulo',
'Fecha 06-Ene-2020',
'Modifico:  Jesus Moreno',
'Se quita la actualización a la tabla ss_atm_rec y se agrega un delete a la misma, se renombre sp_inserta_atm a sp_inserta_atm_ofi para que solo se mande llamar desde el sistema OFI';

CREATE PROCEDURE "informix".sp_monitor_atm_admin_ofi(pempresa CHAR(3),
												pplaza CHAR(3),
												psucursal CHAR(4),
												pregistro SMALLINT,
												pfinicio DATE,
												pffin DATE)
RETURNING 
	CHAR(8),       -- vfoliooper
	CHAR(4),       -- vsucursal
	DATE,          -- vfechasolicitud
	CHAR(8),       -- vusuariosolicitud
	DATE,          -- vfechaenvio
	CHAR(8),       -- vusuarioenvio
	DATE,          -- vfeCHARecepcion
	CHAR(8),       -- vusuariorecepcion
	CHAR(2),       -- vstatus
	DECIMAL(14,2), -- vmonto
	DATE,          -- vfeCHAReversion
	CHAR(8),       -- vusuarioreversion
	CHAR(40),      -- vnombre
	CHAR(30),      -- vdescripcion
	CHAR(4),       -- vcod_trans
	CHAR(35),      -- vdesc_trans
	CHAR(18),      -- vdeno_1
	CHAR(18),      -- vdeno_2
	CHAR(18),      -- vdeno_3
	CHAR(18),      -- vdeno_4
	CHAR(18),      -- vdeno_5
	CHAR(18),      -- vdeno_6
	CHAR(18),      -- vdeno_7
	CHAR(18),      -- vdeno_8
	CHAR(18),      -- vdeno_9
	CHAR(18),      -- vdeno_10
	CHAR(18),      -- vcant_1
	CHAR(18),      -- vcant_2
	CHAR(18),      -- vcant_3
	CHAR(18),      -- vcant_4
	CHAR(18),      -- vcant_5
	CHAR(18),      -- vcant_6
	CHAR(18),      -- vcant_7
	CHAR(18),      -- vcant_8
	CHAR(18),      -- vcant_9
	CHAR(18);      -- vcant_10
	

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vfoliooper CHAR(8);
DEFINE vsucursal CHAR(4);
DEFINE vfechasolicitud DATE;
DEFINE vusuariosolicitud CHAR(8);
DEFINE vfechaenvio DATE;
DEFINE vusuarioenvio CHAR(8);
DEFINE vfeCHARecepcion DATE;
DEFINE vusuariorecepcion CHAR(8);
DEFINE vstatus CHAR(2);
DEFINE vmonto DECIMAL(14,2);
DEFINE vfeCHAReversion DATE;
DEFINE vusuarioreversion CHAR(8);
DEFINE vplaza CHAR(3);
DEFINE vcont SMALLINT;
DEFINE vnombre CHAR(40);
DEFINE vdescripcion CHAR(30);
DEFINE vcod_trans CHAR(4);
DEFINE vdesc_trans CHAR(35);

DEFINE vdeno_1 CHAR(18);
DEFINE vdeno_2 CHAR(18);
DEFINE vdeno_3 CHAR(18);
DEFINE vdeno_4 CHAR(18);
DEFINE vdeno_5 CHAR(18);
DEFINE vdeno_6 CHAR(18);
DEFINE vdeno_7 CHAR(18);
DEFINE vdeno_8 CHAR(18);
DEFINE vdeno_9 CHAR(18);
DEFINE vdeno_10 CHAR(18);


DEFINE vcant_1 INTEGER;
DEFINE vcant_2 INTEGER;
DEFINE vcant_3 INTEGER;
DEFINE vcant_4 INTEGER;
DEFINE vcant_5 INTEGER;
DEFINE vcant_6 INTEGER;
DEFINE vcant_7 INTEGER;
DEFINE vcant_8 INTEGER;
DEFINE vcant_9 INTEGER;
DEFINE vcant_10 INTEGER;

LET vcodret = "000";
LET  vsqlerr = 0;
LET vfoliooper = "";
LET vsucursal = "";
LET vfechasolicitud ="";
LET vusuariosolicitud = "";
LET vfechaenvio ="";
LET vusuarioenvio = "";
LET vfeCHARecepcion = "";
LET vusuariorecepcion = "";
LET vstatus = "";
LET vmonto = 0;
LET vfeCHAReversion ="";
LET vusuarioreversion = "";
LET vplaza = "";
LET vcont = 0;
LET vnombre ="";
LET vdescripcion ="";
LET vcod_trans ="";
LET vdesc_trans = "";
LET vdeno_1 ="";
LET vdeno_2 ="";
LET vdeno_3 ="";
LET vdeno_4 ="";
LET vdeno_5 ="";
LET vdeno_6 ="";
LET vdeno_7 ="";
LET vdeno_8 ="";
LET vdeno_9 ="";
LET vdeno_10 ="";

LET vcant_1 ="";
LET vcant_2 ="";
LET vcant_3 ="";
LET vcant_4 ="";
LET vcant_5 ="";
LET vcant_6 ="";
LET vcant_7 ="";
LET vcant_8 ="";
LET vcant_9 ="";
LET vcant_10 ="";


--SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/spl/sp_monitor.out";
--trace on;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vfoliooper,vsucursal,vfechasolicitud,vusuariosolicitud,
                     vfechaenvio,vusuarioenvio,vfeCHARecepcion,vusuariorecepcion,vstatus,vmonto,vfeCHAReversion,
                     vusuarioreversion,vnombre, vdescripcion,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,vdeno_4,vdeno_5,vdeno_6,vdeno_7,vdeno_8,vdeno_9,vdeno_10, vcant_1, vcant_2, vcant_3,vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10;

      END IF;
   END EXCEPTION;

	IF pplaza IS NULL OR pplaza = '' THEN
		SELECT plaza_cajagen INTO vplaza
		FROM   bdinteg:"informix".si_sucursales
		WHERE  sucursal = psucursal;
	ELSE
		LET  vplaza = pplaza;
	END IF;

   IF psucursal != '' THEN
      FOREACH
         SELECT   o.folio_oper,o.cod_trans,p.descripcion,o.denominacion_1,o.denominacion_2,o.denominacion_3,
                  o.denominacion_4,o.denominacion_5,o.denominacion_6,o.denominacion_7,o.denominacion_8,o.denominacion_9,o.denominacion_10,o.cantidad_1,o.cantidad_2,o.cantidad_3,o.cantidad_4,
                  o.cantidad_5,o.cantidad_6,o.cantidad_7,o.cantidad_8,o.cantidad_9,o.cantidad_10,o.monto,o.sucursal

         INTO      vfoliooper,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                     vdeno_4,vdeno_5,vdeno_6,vdeno_7,vdeno_8,vdeno_9,vdeno_10, vcant_1, vcant_2, vcant_3,
                     vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10,vmonto,vsucursal

         FROM   bdisuc:"informix".ss_param_cajagen p , bdisuc:"informix".ss_operaciones o
         WHERE o.sucursal = psucursal AND
         o.cod_trans = p.codigo AND o.cod_trans BETWEEN '0036' AND '0040' AND 
         o.fecha_operacion BETWEEN pfinicio AND pffin 


         SELECT    m.fecha_solicitud, m.usuario_solicitud,
                  m.fecha_envio, m.usuario_envio, m.fecha_recepcion, m.usuario_recepcion, m.status, m.fecha_reversion,
                  m.usuario_reversion
         INTO     vfechasolicitud,vusuariosolicitud,
                  vfechaenvio,vusuarioenvio,vfeCHARecepcion,vusuariorecepcion,vstatus,vfeCHAReversion,
                  vusuarioreversion
         FROM bdisuc:"informix".ss_mae_entradasalida m
         WHERE folio_oper = vfoliooper;
		 
		 IF NVL(vfechasolicitud, '') = '' THEN
			SELECT fecha_operacion
			INTO vfechasolicitud
			FROM bdisuc:"informix".ss_operaciones
			WHERE folio_oper = vfoliooper;
		 END IF

		 SELECT nombre
         INTO vnombre
         FROM bdinteg:"informix".si_sucursales
         WHERE sucursal = vsucursal;

         SELECT descripcion
         INTO vdescripcion
         FROM bdisuc:"informix".ss_catstatus
         WHERE status = vstatus;

         IF vdescripcion IS NULL THEN
          LET vdescripcion = 'Operacion Realizada';
         END IF;


         IF vcont < pregistro THEN
            LET vcont = vcont + 1;
            CONTINUE foreach;
         END IF
         LET vcont = vcont + 1;


        RETURN    vfoliooper,vsucursal,vfechasolicitud,vusuariosolicitud,
                  vfechaenvio,vusuarioenvio,vfeCHARecepcion,vusuariorecepcion,vstatus,vmonto,vfeCHAReversion,
                  vusuarioreversion,vnombre, vdescripcion, vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                     vdeno_4,vdeno_5,vdeno_6,vdeno_7,vdeno_8,vdeno_9,vdeno_10, vcant_1, vcant_2, vcant_3,
                     vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10
                  WITH RESUME;

   END FOREACH;

ELSE
   FOREACH
          SELECT   o.folio_oper,o.cod_trans,p.descripcion,o.denominacion_1,o.denominacion_2,o.denominacion_3,
                  o.denominacion_4,o.denominacion_5,o.denominacion_6,o.denominacion_7,o.denominacion_8,o.denominacion_9,o.denominacion_10,o.cantidad_1,o.cantidad_2,o.cantidad_3,o.cantidad_4,
                  o.cantidad_5,o.cantidad_6,o.cantidad_7,o.cantidad_8,o.cantidad_9,o.cantidad_10,o.monto,o.sucursal

         INTO      vfoliooper,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                     vdeno_4,vdeno_5,vdeno_6,vdeno_7,vdeno_8,vdeno_9,vdeno_10, vcant_1, vcant_2, vcant_3,
                     vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10,vmonto,vsucursal

         FROM   bdisuc:"informix".ss_param_cajagen p , bdisuc:"informix".ss_operaciones o
         WHERE o.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales
                                              WHERE plaza_cajagen = pplaza AND
                                                    tpo_sucursal = "C" ) AND
         o.cod_trans = p.codigo AND o.cod_trans BETWEEN '0036' AND '0040' AND
         o.fecha_operacion BETWEEN pfinicio AND pffin


         SELECT    m.fecha_solicitud, m.usuario_solicitud,
                  m.fecha_envio, m.usuario_envio, m.fecha_recepcion, m.usuario_recepcion, m.status, m.fecha_reversion,
                  m.usuario_reversion
         INTO     vfechasolicitud,vusuariosolicitud,
                  vfechaenvio,vusuarioenvio,vfeCHARecepcion,vusuariorecepcion,vstatus,vfeCHAReversion,
                  vusuarioreversion
         FROM bdisuc:"informix".ss_mae_entradasalida m
         WHERE folio_oper = vfoliooper;


		 IF NVL(vfechasolicitud, '') = '' THEN
			SELECT fecha_operacion
			INTO vfechasolicitud
			FROM bdisuc:"informix".ss_operaciones
			WHERE folio_oper = vfoliooper;
		 END IF
		 
		 
         SELECT nombre
         INTO vnombre
         FROM bdinteg:"informix".si_sucursales
         WHERE sucursal = vsucursal;

         SELECT descripcion
         INTO vdescripcion
         FROM bdisuc:"informix".ss_catstatus
         WHERE status = vstatus;

        IF vdescripcion IS NULL THEN
          LET vdescripcion = 'Operacion Realizada';
        END IF;

        IF vcont < pregistro THEN
            LET vcont = vcont + 1;
            continue foreach;
        END IF
        LET vcont = vcont + 1;


        RETURN    vfoliooper,vsucursal,vfechasolicitud,vusuariosolicitud,
                     vfechaenvio,vusuarioenvio,vfeCHARecepcion,vusuariorecepcion,vstatus,vmonto,vfeCHAReversion,vusuarioreversion,vnombre, vdescripcion,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,vdeno_4,vdeno_5,vdeno_6,vdeno_7,vdeno_8,vdeno_9,vdeno_10, vcant_1, vcant_2, vcant_3,vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10
                  WITH RESUME;

   END FOREACH;

END IF;
END
END PROCEDURE
DOCUMENT
'MODIFICÓ:    	Jesus Moreno',
'FECHA:       	14/10/2019',
'DESCRIPCIÓN: 	se modIFica el tipo de dato de las variables DEFINE vcant_1,vcant_2,vcant_3,vcant_4,vcant_5 ,vcant_6',
'BASE DE DATOS: bdisuc',
'FOLIO:628',
'Llamado desde:MonitorAtm.exe',
'MODIFICÓ:    	Jesus Moreno',
'FECHA:       	06/01/2020',
'DESCRIPCIÓN: 	se renombra el sp de sp_monitor_atm01 a sp_monitor_atm_admin';

CREATE PROCEDURE "informix".sp_recepdota_atm(pempresa CHAR(3),
											psucursal CHAR(4),
											pcajeroprincipal CHAR(8),
											pfolio_suc CHAR(16),
											pfolio_dota CHAR(8),
											ptransaccion CHAR(4),
											pdivisa CHAR(2),
											pfecha DATE,
											pmonto_dot MONEY(14,2))
RETURNING CHAR(5);

DEFINE vcodret 			  CHAR(5);
DEFINE vsqlerr,visamerr   INTEGER;
DEFINE vhora 			  CHAR(5);
DEFINE vproveedor 	 	  CHAR(4);
DEFINE vplaza 			  CHAR(3);
DEFINE vnum 			  SMALLINT;
DEFINE vmontodot 		  MONEY(14,2);
DEFINE vstatus 			  CHAR(2);
DEFINE bTransacInterAct	  CHAR(1);
DEFINE bEnTransac         CHAR(1);
DEFINE fCantidad_1        FLOAT;
DEFINE fCantidad_2        FLOAT;
DEFINE fCantidad_3        FLOAT;
DEFINE fCantidad_4        FLOAT;
DEFINE fCantidad_5        FLOAT;
DEFINE fCantidad_6        FLOAT;
DEFINE fCantidad_7        FLOAT;
DEFINE fCantidad_8        FLOAT;
DEFINE fCantidad_9        FLOAT;
DEFINE fCantidad_10       FLOAT;
DEFINE mSdoAnt            MONEY(14,2);
DEFINE mSdoTotal          MONEY(14,2);
DEFINE vfecha_depurado 	  DATE;

LET vcodret 			= "000";
LET vproveedor 			= "";
LEt vplaza 				= "";
LET vhora 				= substr(current,12,5); 
LET vnum 				= 0;
LET vmontodot 			= 0;
LET vstatus  			= "";
--LET wbegin = "";
LET bTransacInterAct     = 'F';
LET bEnTransac           = 'F';
LET fCantidad_1          = 0;
LET fCantidad_2          = 0;
LET fCantidad_3          = 0;
LET fCantidad_4          = 0;
LET fCantidad_5          = 0;
LET fCantidad_6          = 0;
LET fCantidad_7          = 0;
LET fCantidad_8          = 0;
LET fCantidad_9          = 0;
LET fCantidad_10         = 0;
LET mSdoAnt              = 0;
LET mSdoTotal            = 0;
LET vfecha_depurado 	 = "";
 
BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
			
			IF bTransacInterAct = 'T' THEN		--DSB20150429 {
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					BEGIN WORK;
				END IF;
			ELSE
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
				ELSE
					ROLLBACK WORK;
				END IF;							
			END IF;		  
	  LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;


ON EXCEPTION IN (-535)				--DSB20150429 {
	LET bTransacInterAct = 'T';
	LET bEnTransac = 'T';
	COMMIT WORK;
	BEGIN WORK;
END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN WORK;

--SET debug file to "/informix/jepolanco/recepdota.out";
--trace on;

--Modificado por: PAUL IVAN QUINTERO VARELA
--25-09-2019
--Se agrega el respaldo previo a las afectaciones operativas de la transacción
--Se agrega la transaccionalidad en el proceso.


--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto_dot = 0 or pfolio_dota = '' then
   LET vcodret = "110";
ELSE

    select plaza_cajagen into vplaza
    from   bdinteg:si_sucursales
    where  sucursal = psucursal;

    select cod_proveedor into vproveedor
    from   ss_proveedores
    where  plaza = vplaza;

    select 1,monto,status into vnum,vmontodot,vstatus
    from   ss_mae_entradasalida
    where  folio_oper = pfolio_dota;
    if vnum is null then
       LET vcodret = "100";
       return vcodret;
    else
       --if vmontodot != pmonto_dot then
       --   LET vcodret = "102";
       --   return vcodret;
       --end if
       if Trim(vstatus) = "08" then
          LET vcodret = "103";
          return vcodret;
       end if
       if Trim(vstatus) != "11" then
          LET vcodret = "104";
          return vcodret;
       end if
    end if
	
	--SE REALIZA DEPURADO DE LAS TABLAS 7 DIAS ATRAS DE LA FECHA ACTUAL
	LET vfecha_depurado = pfecha -7;
	DELETE FROM ss_mae_entradasalida_rec WHERE fecha_solicitud < vfecha_depurado;
	
	--SE VALIDA SI QUEDO UNA OPERACIÓN INCONCLUSA PARA EL CAJERO ATM, DE SER ASI SE RESTAURA COMO ESTABA LA ULTIMA VEZ Y CONTINUA CONE EL FLUJO
	IF EXISTS (SELECT cod_atm FROM  ss_atm_rec WHERE cod_atm = pSucursal) THEN
		SELECT cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10, saldo_anterior, saldo_total
		INTO fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6,fCantidad_7,fCantidad_8,fCantidad_9,fCantidad_10, mSdoAnt, mSdoTotal
		FROM bdisuc:"informix".ss_atm_rec
		WHERE empresa = pempresa 
		AND cod_atm = psucursal;

		IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
	
			UPDATE bdisuc:"informix".ss_atm 
			   SET cantidad_1 = fCantidad_1,
				   cantidad_2 = fCantidad_2,
				   cantidad_3 = fCantidad_3,
				   cantidad_4 = fCantidad_4,
				   cantidad_5 = fCantidad_5,
				   cantidad_6 = fCantidad_6,
				   cantidad_7 = fCantidad_7,
				   cantidad_8 = fCantidad_8,
				   cantidad_9 = fCantidad_9,
				   cantidad_10 = fCantidad_10,
				   saldo_anterior = mSdoAnt,
				   saldo_total = mSdoTotal					  
			WHERE empresa = pempresa AND cod_atm = psucursal;
		
			DELETE FROM bdisuc:"informix".ss_atm_rec WHERE empresa = pempresa AND cod_atm = psucursal;
			DELETE FROM bdisuc:"informix".ss_mae_entradasalida_rec WHERE folio_oper = pfolio_dota;
			
		END IF;
	END IF;
		
  INSERT INTO ss_mae_entradasalida_rec 
	SELECT * FROM ss_mae_entradasalida WHERE folio_oper = pfolio_dota;
	
    UPDATE ss_mae_entradasalida
    SET    fecha_recepcion = pfecha,
           hora_recepcion = vhora,
           usuario_recepcion = pcajeroprincipal,
           status = '05'
    WHERE  folio_oper = pfolio_dota;

  {  INSERT INTO ss_operaciones
	  (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,
           denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
           denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
           denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
           cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
           cantidad_13,cantidad_14,cantidad_15)
    VALUES
          (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dot,
           pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
	   pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
	   pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

    INSERT INTO ss_mae_entradasalida
           (empresa,cod_proveedor,folio_oper,sucursal,folio_sucursal,fecha_solicitud,hora_solicitud,usuario_solicitud,
            status,monto)
    VALUES (pempresa,vproveedor,vfolio,psucursal,pfolio_suc,pfecha,vhora,pcajeroprincipal,'01',pmonto_dot);
}

END IF;

COMMIT WORK;

IF bTransacInterAct = 'T' THEN
	BEGIN WORK;
END IF;

RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:RecepDota.exe',
'AUTOR:Cristian Valentina Aguilar ', 
'FECHA:2019-11-11',
'DESCRIPCION: Se modifica SP para que no afecta la tabla ss_cajageneral y que valide si quedo una recepción inconclusa en la tabla ss_atm, de ser así se realiza reverso y se continua con el proceso normal',
'SOLICITA: Gabriela Angulo',
'FECHA: 06-ENE-2020',
'MODIFICO:  JESUS MORENO',
'CAMBIO: Se agrega depurado a la tabla ss_mae_entradasalida_rec de 5 dias atras a la fecha actual y se renombra el sp';

CREATE PROCEDURE "informix".sp_recepdota_rec(pEmpresa       CHAR(3),
										  pSucursal      CHAR(4),
										  pFolioDota     CHAR(8),
										  pCodAtm        CHAR(4),
										  pOpt           CHAR(1))
RETURNING CHAR(6);

DEFINE vcodret            CHAR(5);
DEFINE vsqlerr,visamerr   INTEGER;
DEFINE cPlaza             CHAR(3);
DEFINE cProveedor         CHAR(4);
DEFINE dtFechaRec         DATE;
DEFINE cHoraRec           CHAR(5);
DEFINE cUserRec           CHAR(8);
DEFINE cStatus            CHAR(2);
DEFINE mSdoAsig           MONEY(14,2);
DEFINE fCantidad_1        FLOAT;
DEFINE fCantidad_2        FLOAT;
DEFINE fCantidad_3        FLOAT;
DEFINE fCantidad_4        FLOAT;
DEFINE fCantidad_5        FLOAT;
DEFINE fCantidad_6        FLOAT;
DEFINE fCantidad_7        FLOAT;
DEFINE fCantidad_8        FLOAT;
DEFINE fCantidad_9        FLOAT;
DEFINE fCantidad_10       FLOAT;
DEFINE mSdoAnt            MONEY(14,2);
DEFINE mSdoAsig2          MONEY(14,2);
DEFINE mSdoTotal          MONEY(14,2);
DEFINE bTransacInterAct	  CHAR(1);
DEFINE bEnTransac         CHAR(1);

LET vcodret              = "000";
LET vsqlerr              = 0;
LET visamerr             = 0;
LET cPlaza               = "";
LET cProveedor           = "";
LET dtFechaRec           = DATE(1);
LET cHoraRec             = "";
LET cUserRec             = "";
LET cStatus              = "";
LET mSdoAsig             = 0;
LET fCantidad_1          = 0;
LET fCantidad_2          = 0;
LET fCantidad_3          = 0;
LET fCantidad_4          = 0;
LET fCantidad_5          = 0;
LET fCantidad_6          = 0;
LET fCantidad_7          =0;
LET fCantidad_8          =0;
LET fCantidad_9          =0;
LET fCantidad_10         =0;
LET mSdoAnt              = 0;
LET mSdoAsig2            = 0;
LET mSdoTotal            = 0;
LET bTransacInterAct     = 'F';
LET bEnTransac           = 'F';

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
		IF vsqlerr <> 0 THEN
			IF bTransacInterAct = 'T' THEN		--DSB20150429 {
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					BEGIN WORK;
				END IF;
			ELSE
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
				ELSE
					ROLLBACK WORK;
				END IF;							
			END IF;	

			LET vcodret = vsqlerr;
			RETURN vcodret;
		END IF;
	END EXCEPTION;

ON EXCEPTION IN (-535)				--DSB20150429 {
	LET bTransacInterAct = 'T';
	LET bEnTransac = 'T';
	COMMIT WORK;
	BEGIN WORK;
END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN WORK;

--Creado por: PAUL IVAN QUINTERO VARELA
--25-09-2019
--Se crea procedimiento para recuperar la información a su estado original de la transacción en caso de ocurrir
--un error o incosistencia en el problema para recuperarla.


-- SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/sucursal/sp_recepdota_rec.out";
-- TRACE ON;

IF ( NVL(pEmpresa,'') = '')  OR ( NVL(pFolioDota,'') = '') OR (NVL(pOpt,'') = '') THEN

	LET vcodret = "110";
	
ELSE

	SELECT plaza_cajagen 
	  INTO cPlaza
	  FROM bdinteg:si_sucursales
	 WHERE sucursal = pSucursal;
	 
	IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
		SELECT cod_proveedor 
		  INTO cProveedor
		  FROM ss_proveedores
		 WHERE plaza = cPlaza;
	END IF;

	IF pCodAtm = 0 OR (NVL(pCodAtm,'') = '') OR (NVL(pSucursal,'') = '') THEN
		SELECT sucursal 
			INTO pCodAtm 
			FROM ss_mae_entradasalida_rec WHERE folio_oper = pFolioDota;
			
		let pSucursal = pCodAtm;
	END IF;
			
	IF pOpt IN ('1','3') THEN
	-- Recuperación función envia_dota OPCION 1
	   SELECT fecha_recepcion, hora_recepcion, usuario_recepcion, status
		 INTO dtFechaRec, cHoraRec, cUserRec, cStatus
		 FROM ss_mae_entradasalida_rec
		WHERE folio_oper = pFolioDota;
		
		IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
		   UPDATE ss_mae_entradasalida
			  SET fecha_recepcion = dtFechaRec,
				  hora_recepcion = cHoraRec,
				  usuario_recepcion = cUserRec,
				  status = cStatus
			WHERE folio_oper = pFolioDota;
		END IF;
		
		/*SELECT saldo_asignado
		  INTO mSdoAsig
		  FROM ss_cajageneral_rec
		 WHERE cod_proveedor = cProveedor;
		 
		 IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
			UPDATE ss_cajageneral
			   SET saldo_asignado = mSdoAsig
			 WHERE cod_proveedor = cProveedor;
			 
		 END IF;*/
		 
		 DELETE FROM ss_mae_entradasalida_rec WHERE folio_oper = pFolioDota;
		 
	END IF;


	IF pOpt IN ('2','3') THEN	 
	-- Recuperación función envia_OPERACIÓN OPCION 2
		SELECT cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10, saldo_anterior, saldo_asignado, saldo_total
		  INTO fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6,fCantidad_7,fCantidad_8,fCantidad_9,fCantidad_10, mSdoAnt, mSdoAsig2, mSdoTotal
		  FROM bdisuc:"informix".ss_atm_rec
		 WHERE empresa = pEmpresa 
		   AND cod_atm = pCodAtm;

		IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
		
			UPDATE bdisuc:"informix".ss_atm 
			   SET cantidad_1 = fCantidad_1,
				   cantidad_2 = fCantidad_2,
				   cantidad_3 = fCantidad_3,
				   cantidad_4 = fCantidad_4,
				   cantidad_5 = fCantidad_5,
				   cantidad_6 = fCantidad_6,
                    cantidad_7 = fCantidad_7,
                    cantidad_8 = fCantidad_8,
                    cantidad_9 = fCantidad_9,
                    cantidad_10 = fCantidad_10,
				   saldo_anterior = mSdoAnt,
				   saldo_total = mSdoTotal					  
			WHERE empresa = pEmpresa AND cod_atm = pCodAtm;

			
           DELETE FROM bdisuc:"informix".ss_atm_rec WHERE empresa = pEmpresa AND cod_atm = pCodAtm;
			
		ELSE
			
			DELETE FROM  bdisuc:"informix".ss_atm WHERE empresa = pEmpresa AND cod_atm = pCodAtm;
			DELETE FROM bdisuc:"informix".ss_atm_rec WHERE empresa = pEmpresa AND cod_atm = pCodAtm;
		END IF;
	END IF;
	
	IF pOpt IN ('4') THEN	 
	-- Recuperación función envia_OPERACIÓN OPCION 4
		DELETE FROM bdisuc:"informix".ss_atm_rec WHERE empresa = pEmpresa AND cod_atm = pCodAtm;
		DELETE FROM ss_mae_entradasalida_rec WHERE folio_oper = pFolioDota;
	END IF;
	
	IF pOpt IN ('5') THEN	 
	-- Valida si quedo alguna operacion inclonclusa
		IF EXISTS (SELECT folio_oper FROM ss_mae_entradasalida_rec WHERE folio_oper = pFolioDota) THEN
			LET vcodret = "200";
		END IF;
	END IF;
	
END IF;
COMMIT WORK;

IF bTransacInterAct = 'T' THEN
	BEGIN WORK;
END IF;

RETURN vcodret;

END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:RecepDota.exe',
'AUTOR:Cristian Valentina Aguilar ', 
'FECHA:2019-11-11',
'DESCRIPCION: Se genera procedimiento para realizar el reverso a la recepción de la dotación, para eliminar la transacción en caso de algún error en sucursal se de reverso en el servidor central.' ,
'SOLICITA: Gabriela Angulo';

CREATE PROCEDURE "informix".sp_soldocta_atm_ofi(
	pEmpresa  CHAR(3),
	pSucursal CHAR(4), 
	pEmpleado CHAR(8),
	pFolioSuc CHAR(16),
	pTransacc CHAR(4),
	pDivisa   CHAR(2),
	pMonto 	  MONEY(14,2),
	pFecha 	  DATE,
	pDenom1   CHAR(18),
	pDenom2   CHAR(18),
	pDenom3   CHAR(18),
	pDenom4   CHAR(18),
	pDenom5   CHAR(18),
	pDenom6   CHAR(18),
	pDenom7   CHAR(18),
	pDenom8   CHAR(18),
	pDenom9   CHAR(18),
	pDenom10  CHAR(18),
	pDenom11  CHAR(18),
	pDenom12  CHAR(18),
	pDenom13  CHAR(18),
	pDenom14  CHAR(18),
	pDenom15  CHAR(18),
	pCant1 	  FLOAT(8),
	pCant2 	  FLOAT(8),
	pCant3 	  FLOAT(8),
	pCant4 	  FLOAT(8),
	pCant5 	  FLOAT(8),
	pCant6 	  FLOAT(8),
	pCant7 	  FLOAT(8),
	pCant8 	  FLOAT(8),
	pCant9 	  FLOAT(8),
	pCant10   FLOAT(8),
	pCant11   FLOAT(8),
	pCant12   FLOAT(8),
	pCant13   FLOAT(8),
	pCant14   FLOAT(8),
	pCant15   FLOAT(8),
    pFechaEnt DATE)
RETURNING CHAR(5), CHAR(8);

	DEFINE cCodRet 	  CHAR(5);
	DEFINE cFolio 	  CHAR(8);
	DEFINE iSqlErr 	  INTEGER; 
	DEFINE iIsamErr   INTEGER;
	DEFINE cHora 	  CHAR(5);
	DEFINE cProveedor CHAR(4);
	DEFINE cPlaza 	  CHAR(3);
	DEFINE iValor 	  INTEGER;
	DEFINE iDenom1    INTEGER;
	DEFINE iDenom2    INTEGER;
	DEFINE iDenom3    INTEGER;
	DEFINE iDenom4    INTEGER;
	DEFINE iDenom5    INTEGER;
	DEFINE iDenom6    INTEGER;
	DEFINE iDenom7    INTEGER;
	DEFINE iDenom8    INTEGER;
	DEFINE iDenom9    INTEGER;
	DEFINE iDenom10   INTEGER;
	DEFINE iDenom11   INTEGER;
	DEFINE iDenom12   INTEGER;
	DEFINE iDenom13   INTEGER;
	DEFINE iDenom14   INTEGER;
	DEFINE iDenom15   INTEGER;	
	DEFINE iTotal1    INTEGER;
	DEFINE iTotal2    INTEGER;
	DEFINE iTotal3    INTEGER;
	DEFINE iTotal4    INTEGER;
	DEFINE iTotal5    INTEGER;
	DEFINE iTotal6    INTEGER;
	DEFINE iTotal7    INTEGER;
	DEFINE iTotal8    INTEGER;
	DEFINE iTotal9    INTEGER;
	DEFINE iTotal10   INTEGER;
	DEFINE iTotal11   INTEGER;
	DEFINE iTotal12   INTEGER;
	DEFINE iTotal13   INTEGER;
	DEFINE iTotal14   INTEGER;
	DEFINE iTotal15   INTEGER;
	DEFINE iSumTotal  INTEGER;
	DEFINE bTransacInterAct	CHAR(1);
	DEFINE bEnTransac CHAR(1);
    DEFINE vv  CHAR(10);
	
	LET cHora 	   = SUBSTR(CURRENT, 12, 5);
	LET cCodRet    = '00000';
	LET cProveedor = '';
	LEt cPlaza 	   = '';
	LET cFolio     = '';
	LET iValor 	   = 0;
	LET iSqlErr    = 0;
	LET iIsamErr   = 0;
	LET iDenom1    = pDenom1;
	LET iDenom2    = pDenom2;
	LET iDenom3    = pDenom3;
	LET iDenom4    = pDenom4;
	LET iDenom5    = pDenom5;
	LET iDenom6    = pDenom6;
	LET iDenom7    = pDenom7;
	LET iDenom8    = pDenom8;
	LET iDenom9    = pDenom9;
	LET iDenom10   = pDenom10;
	LET iDenom11   = pDenom11;
	LET iDenom12   = pDenom12;
	LET iDenom13   = pDenom13;
	LET iDenom14   = pDenom14;
	LET iDenom15   = pDenom15;
	LET iTotal1    = 0;
	LET iTotal2    = 0;
	LET iTotal3    = 0;
	LET iTotal4    = 0;
	LET iTotal5    = 0;
	LET iTotal6    = 0;
	LET iTotal7    = 0;
	LET iTotal8    = 0;
	LET iTotal9    = 0;
	LET iTotal10   = 0;
	LET iTotal11   = 0;
	LET iTotal12   = 0;
	LET iTotal13   = 0;
	LET iTotal14   = 0;
	LET iTotal15   = 0;
	LET iSumTotal  = 0;
	LET bTransacInterAct = 'F';
	LET bEnTransac = 'F';
    LET vv = '';

	BEGIN	
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN 
				IF bTransacInterAct = 'T' THEN		--DSB20150429 {
					IF bEnTransac = 'T' THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						BEGIN WORK;
					END IF;
				ELSE
					IF bEnTransac = 'T' THEN
						ROLLBACK WORK;
					END IF;							
				END IF;	
				LET cCodRet = iSqlErr;
				--ROLLBACK;
				RETURN cCodRet, cFolio;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)				--DSB20150429 {
		LET bTransacInterAct = 'T';
		COMMIT WORK;
		BEGIN WORK;
		END EXCEPTION WITH RESUME;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	--	SET DEBUG FILE TO '/tmp/log_soldocta.out';
	--	TRACE ON;
		
		BEGIN WORK;
	
		--VALIDA LA RECEPCION DE LOS DATOS
		IF 	pEmpresa  = '0' OR pEmpresa  = '' OR 
			pSucursal = '0' OR pSucursal = '' OR
			pDivisa   = '0' OR pDivisa   = '' OR 
			pEmpleado = '0' OR pEmpleado = '' OR 
			pFolioSuc = '0' OR pFolioSuc = '' OR 
			pTransacc = '0' OR pTransacc = '' OR 
			pMonto    = 0                     THEN 
			LET cCodRet = '110';
		
		ELSE
			
			IF iDenom1 IS NULL OR iDenom1 = '' THEN
				LET iDenom1 = 0;
			END IF;
			IF iDenom2 IS NULL OR iDenom2 = '' THEN
				LET iDenom2 = 0;
			END IF;
			IF iDenom3 IS NULL OR iDenom3 = '' THEN
				LET iDenom3 = 0;
			END IF;
			IF iDenom4 IS NULL OR iDenom4 = '' THEN
				LET iDenom4 = 0;
			END IF;
			IF iDenom5 IS NULL OR iDenom5 = '' THEN
				LET iDenom5 = 0;
			END IF;
			IF iDenom6 IS NULL OR iDenom6 = '' THEN
				LET iDenom6 = 0;
			END IF;
			IF iDenom7 IS NULL OR iDenom7 = '' THEN
				LET iDenom7 = 0;
			END IF;
			IF iDenom8 IS NULL OR iDenom8 = '' THEN
				LET iDenom8 = 0;
			END IF;
			IF iDenom9 IS NULL OR iDenom9 = '' THEN
				LET iDenom9 = 0;
			END IF;
			IF iDenom10 IS NULL OR iDenom10 = '' THEN
				LET iDenom10 = 0;
			END IF;
			IF iDenom11 IS NULL OR iDenom11 = '' THEN
				LET iDenom11 = 0;
			END IF;
			IF iDenom12 IS NULL OR iDenom12 = '' THEN
				LET iDenom12 = 0;
			END IF;
			IF iDenom13 IS NULL OR iDenom13 = '' THEN
				LET iDenom13 = 0;
			END IF;
			IF iDenom14 IS NULL OR iDenom14 = '' THEN
				LET iDenom14 = 0;
			END IF;
			IF iDenom15 IS NULL OR iDenom15 = '' THEN
				LET iDenom15 = 0;
			END IF;
			
			LET iTotal1	   = iDenom1  * pCant1;
			LET iTotal2	   = iDenom2  * pCant2;
			LET iTotal3	   = iDenom3  * pCant3;
			LET iTotal4	   = iDenom4  * pCant4;
			LET iTotal5	   = iDenom5  * pCant5;
			LET iTotal6	   = iDenom6  * pCant6;
			LET iTotal7	   = iDenom7  * pCant7;
			LET iTotal8	   = iDenom8  * pCant8;
			LET iTotal9	   = iDenom9  * pCant9;
			LET iTotal10   = iDenom10 * pCant10;
			LET iTotal11   = iDenom11 * pCant11;
			LET iTotal12   = iDenom12 * pCant12;
			LET iTotal13   = iDenom13 * pCant13;
			LET iTotal14   = iDenom14 * pCant14;
			LET iTotal15   = iDenom15 * pCant15;
			LET iSumTotal  = iTotal1  + iTotal2  +
							 iTotal3  + iTotal4  +
							 iTotal5  + iTotal6  +
							 iTotal7  + iTotal8  +
							 iTotal9  + iTotal10 +
							 iTotal11 + iTotal12 +
							 iTotal13 + iTotal14 +
							 iTotal15;
							 
			--VALIDA MONTO VS DESGLOSE DENOMINACIONES
			IF pMonto <> iSumTotal THEN
				LET cCodRet = '00115';
				RETURN cCodRet, cFolio;
			END IF;
			
            

    SELECT LIMIT 1 cod_trans 
    INTO vv FROM ss_operaciones a , ss_mae_entradasalida b
    WHERE a.sucursal=pSucursal 
    AND a.folio_oper=b.folio_oper
    --and folio_sucursal=pfolio_suc
    AND a.fecha_entrega=pFechaEnt
    AND b.status IN ('01','11');

    LET vv= NVL(vv,'');

    IF NOT vv = '' then
        Let cCodRet='0001';
        --let vfolio='';
       RETURN cCodRet, cFolio;
    END IF;

			SELECT plaza_cajagen INTO cPlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal;
			SELECT cod_proveedor INTO cProveedor FROM bdisuc:"informix".ss_proveedores WHERE plaza = cPlaza;
		
			IF cProveedor IS NOT NULL THEN
	
				SELECT valor INTO iValor FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = '0005';

				UPDATE bdisuc:"informix".ss_param_cajagen SET valor = valor + 1 WHERE codigo = '0005';
				
				LET cFolio = LPAD(iValor, 8, '0');
				
				INSERT INTO bdisuc:"informix".ss_operaciones (empresa, cod_trans, fecha_operacion, sucursal, folio_sucursal, folio_oper, reversado, usuario, divisa, monto,
				denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, denominacion_13, denominacion_14, denominacion_15, 
				cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, cantidad_8, cantidad_9, cantidad_10, cantidad_11, cantidad_12, cantidad_13, cantidad_14, cantidad_15,fecha_entrega)
				VALUES (pEmpresa, pTransacc, pFecha, pSucursal, pFolioSuc, cFolio, '0', pEmpleado, pDivisa, pMonto,
				pDenom1, pDenom2, pDenom3, pDenom4, pDenom5, pDenom6, pDenom7, pDenom8, pDenom9, pDenom10, pDenom11, pDenom12, pDenom13, pDenom14, pDenom15, 
				pCant1, pCant2, pCant3, pCant4, pCant5, pCant6, pCant7, pCant8, pCant9, pCant10, pCant11, pCant12, pCant13, pCant14, pCant15,pFechaEnt);
				
				INSERT INTO bdisuc:"informix".ss_mae_entradasalida (empresa, cod_proveedor, folio_oper, sucursal, folio_sucursal, fecha_solicitud, hora_solicitud, usuario_solicitud, status, monto)
				VALUES (pEmpresa, cProveedor, cFolio, pSucursal, pFolioSuc, pFecha, cHora, pEmpleado, '01', pMonto);
				
			ELSE
				LET cCodRet = '105';
				RETURN cCodRet, cFolio;
			END IF;
		END IF;
		
		COMMIT WORK;
		IF bTransacInterAct = 'T' THEN
			BEGIN WORK;
		END IF;
	
		RETURN cCodRet, cFolio;
	END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:DotaCG.exe',
'AUTOR:Jesus Moreno', 
'FECHA:2019-09-20',
'DESCRIPCION: Se modifica procedimiento para realiza rollback',
'SOLICITA: Gabriela Angulo',
'Modificado Por: DR Rorro';

CREATE PROCEDURE "informix".sp_traefolios(pEmpresa CHAR(3),psuc CHAR(5))
RETURNING CHAR(5), CHAR(20);

DEFINE cCodRet 	  CHAR(5);
--DEFINE cFolio	  CHAR(8);
DEFINE iSqlErr 	  INTEGER; 
DEFINE iIsamErr   INTEGER;   
DEFINE cFolio char(20);

LET cFolio = '';
LET cCodRet = '00000';
LET iSqlErr = 0;
LET iIsamErr = 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN 
				LET cCodRet = iSqlErr;
				--ROLLBACK;
				RETURN cCodRet,cFolio;
			END IF;
		END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    IF pEmpresa IS NULL OR pEmpresa='' OR psuc='' OR psuc IS NULL THEN
        let cCodRet='00001';
        RETURN cCodRet,cFolio;
    END IF;

    SELECT MIN(a.folio_oper) 
    INTO cFolio
    FROM ss_operaciones a,ss_mae_entradasalida b 
    WHERE a.sucursal=psuc 
    AND a.folio_oper=b.folio_oper 
    AND b.status = '11';

    IF cFolio IS NULL OR cFolio = '' THEN
        LET cCodRet='00001';
        LET cFolio= '';
        RETURN cCodRet,cFolio;
    END IF;

    RETURN cCodRet,cFolio;

END
END PROCEDURE;