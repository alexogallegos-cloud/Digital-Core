CREATE PROCEDURE "informix".sp_soldocta_atm(
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
	pCant15   FLOAT(8))
	
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
		
		--SET DEBUG FILE TO '/tmp/Ricardo/log_soldocta.out';
		--TRACE ON;
		
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
			
			SELECT plaza_cajagen INTO cPlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal;

			SELECT cod_proveedor INTO cProveedor FROM bdisuc:"informix".ss_proveedores WHERE plaza = cPlaza;
		
			IF cProveedor IS NOT NULL THEN
				
				SELECT valor INTO iValor FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = '0005';

				UPDATE bdisuc:"informix".ss_param_cajagen SET valor = valor + 1 WHERE codigo = '0005';
				
				LET cFolio = LPAD(iValor, 8, '0');
				
				INSERT INTO bdisuc:"informix".ss_operaciones (empresa, cod_trans, fecha_operacion, sucursal, folio_sucursal, folio_oper, reversado, usuario, divisa, monto,
				denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, denominacion_13, denominacion_14, denominacion_15, 
				cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, cantidad_8, cantidad_9, cantidad_10, cantidad_11, cantidad_12, cantidad_13, cantidad_14, cantidad_15)
				VALUES (pEmpresa, pTransacc, pFecha, pSucursal, pFolioSuc, cFolio, '0', pEmpleado, pDivisa, pMonto,
				pDenom1, pDenom2, pDenom3, pDenom4, pDenom5, pDenom6, pDenom7, pDenom8, pDenom9, pDenom10, pDenom11, pDenom12, pDenom13, pDenom14, pDenom15, 
				pCant1, pCant2, pCant3, pCant4, pCant5, pCant6, pCant7, pCant8, pCant9, pCant10, pCant11, pCant12, pCant13, pCant14, pCant15);
				
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
'FECHA:2020-01-20',
'DESCRIPCION: Se renombra sp para que solo se mande llamar desde ofi',
'SOLICITA: Gabriela Angulo';

CREATE PROCEDURE "informix".sp_monitor_atm_admin(pempresa      CHAR(3),
                                           pplaza        CHAR(3),
                                           psucursal     CHAR(4),
                                           pregistro     SMALLINT,
                                           pfinicio      DATE,
                                           pffin         DATE)


       returning CHAR(8),CHAR(4),
                 DATE,CHAR(8),DATE,CHAR(8),DATE,
                 CHAR(8),CHAR(2),DECIMAL(14,2),DATE,
                 CHAR(8),CHAR(40),CHAR(30),CHAR(4),CHAR(35),
                 CHAR(18),CHAR(18),CHAR(18),
                 CHAR(18),CHAR(18),CHAR(18),
                 CHAR(18),CHAR(18),CHAR(18),
                 CHAR(18),CHAR(18),CHAR(18);


define vcodret char(5);
define vsqlerr integer;

define vfoliooper char(8);
define vsucursal char(4);
define vfechasolicitud date;
define vusuariosolicitud char(8);
define vfechaenvio date;
define vusuarioenvio char(8);
define vfecharecepcion date;
define vusuariorecepcion char(8);
define vstatus char(2);
define vmonto decimal(14,2);
define vfechareversion date;
define vusuarioreversion char(8);
define vplaza char(3);
define vcont smallint;
define vnombre char(40);
define vdescripcion char(30);
define vcod_trans char(4);
define vdesc_trans char(35);

DEFINE vdeno_1           CHAR(18);
DEFINE vdeno_2           CHAR(18);
DEFINE vdeno_3           CHAR(18);
DEFINE vdeno_4           CHAR(18);
DEFINE vdeno_5           CHAR(18);
DEFINE vdeno_6           CHAR(18);
DEFINE vcant_1           INTEGER;
DEFINE vcant_2           INTEGER;
DEFINE vcant_3           INTEGER;
DEFINE vcant_4           INTEGER;
DEFINE vcant_5           INTEGER;
DEFINE vcant_6           INTEGER;



let vcodret = "000";
let  vsqlerr = 0;

let vfoliooper = "";
let vsucursal = "";
let vfechasolicitud ="";
let vusuariosolicitud = "";
let vfechaenvio ="";
let vusuarioenvio = "";
let vfecharecepcion = "";
let vusuariorecepcion = "";
let vstatus = "";
let vmonto = 0;
let vfechareversion ="";
let vusuarioreversion = "";
let vplaza = "";
Let vcont = 0;
let vnombre ="";
let vdescripcion ="";
let vcod_trans ="";
let vdesc_trans = "";

LET vdeno_1             ="";
LET vdeno_2             ="";
LET vdeno_3             ="";
LET vdeno_4             ="";
LET vdeno_5             ="";
LET vdeno_6             ="";

LET vcant_1             ="";
LET vcant_2             ="";
LET vcant_3             ="";
LET vcant_4             ="";
LET vcant_5             ="";
LET vcant_6             ="";



--SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/spl/sp_monitor.out";
--trace on;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vfoliooper,vsucursal,vfechasolicitud,vusuariosolicitud,
                     vfechaenvio,vusuarioenvio,vfecharecepcion,vusuariorecepcion,vstatus,vmonto,vfechareversion,
                     vusuarioreversion,vnombre, vdescripcion,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                     vdeno_4,vdeno_5,vdeno_6, vcant_1, vcant_2, vcant_3,
                     vcant_4, vcant_5, vcant_6;

      end if;
   end exception;

   IF pplaza IS NULL or pplaza = '' THEN
      SELECT plaza_cajagen INTO vplaza
      FROM   bdinteg:si_sucursales
      WHERE  sucursal = psucursal;
   else

     LET  vplaza = pplaza;
   END IF;

   if psucursal != '' then
      foreach
         SELECT   o.folio_oper,o.cod_trans,p.descripcion,o.denominacion_1,o.denominacion_2,o.denominacion_3,
                  o.denominacion_4,o.denominacion_5,o.denominacion_6,o.cantidad_1,o.cantidad_2,o.cantidad_3,o.cantidad_4,
                  o.cantidad_5,o.cantidad_6,o.monto,o.sucursal

         INTO      vfoliooper,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                   vdeno_4,vdeno_5,vdeno_6, vcant_1, vcant_2, vcant_3,
                   vcant_4, vcant_5, vcant_6,vmonto,vsucursal

         FROM   SS_Param_cajagen p , ss_operaciones o
         WHERE o.sucursal = psucursal AND
         o.cod_trans = p.codigo and o.cod_trans between '0036' and '0040' and 
         o.fecha_operacion between pfinicio and pffin 


         SELECT    m.fecha_solicitud, m.usuario_solicitud,
                  m.fecha_envio, m.usuario_envio, m.fecha_recepcion, m.usuario_recepcion, m.status, m.fecha_reversion,
                  m.usuario_reversion
         INTO     vfechasolicitud,vusuariosolicitud,
                  vfechaenvio,vusuarioenvio,vfecharecepcion,vusuariorecepcion,vstatus,vfechareversion,
                  vusuarioreversion
         FROM ss_mae_entradasalida m
         WHERE folio_oper = vfoliooper;


         SELECT nombre
         into vnombre
         from bdinteg:si_sucursales
         where sucursal = vsucursal;

         SELECT descripcion
         into vdescripcion
         from ss_catstatus
         where status = vstatus;

         if vdescripcion is null then
          let vdescripcion = 'Operacion Realizada';
         end if;


         IF vcont < pregistro THEN
            LET vcont = vcont + 1;
            continue foreach;
         END IF
         LET vcont = vcont + 1;


        return    vfoliooper,vsucursal,vfechasolicitud,vusuariosolicitud,
                  vfechaenvio,vusuarioenvio,vfecharecepcion,vusuariorecepcion,vstatus,vmonto,vfechareversion,
                  vusuarioreversion,vnombre, vdescripcion, vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                  vdeno_4,vdeno_5,vdeno_6, vcant_1, vcant_2, vcant_3,
                  vcant_4, vcant_5, vcant_6
                  with resume;

   end foreach;



else
   foreach
          SELECT   o.folio_oper,o.cod_trans,p.descripcion,o.denominacion_1,o.denominacion_2,o.denominacion_3,
                  o.denominacion_4,o.denominacion_5,o.denominacion_6,o.cantidad_1,o.cantidad_2,o.cantidad_3,o.cantidad_4,
                  o.cantidad_5,o.cantidad_6,o.monto,o.sucursal

         INTO      vfoliooper,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                   vdeno_4,vdeno_5,vdeno_6, vcant_1, vcant_2, vcant_3,
                   vcant_4, vcant_5, vcant_6,vmonto,vsucursal

         FROM   SS_Param_cajagen p , ss_operaciones o
         WHERE o.sucursal in (Select sucursal From bdinteg:si_sucursales
                                              Where plaza_cajagen = pplaza and
                                                    tpo_sucursal = "C" ) and

         o.cod_trans = p.codigo and o.cod_trans between '0036' and '0040' and
         o.fecha_operacion between pfinicio and pffin


         SELECT    m.fecha_solicitud, m.usuario_solicitud,
                  m.fecha_envio, m.usuario_envio, m.fecha_recepcion, m.usuario_recepcion, m.status, m.fecha_reversion,
                  m.usuario_reversion
         INTO     vfechasolicitud,vusuariosolicitud,
                  vfechaenvio,vusuarioenvio,vfecharecepcion,vusuariorecepcion,vstatus,vfechareversion,
                  vusuarioreversion
         FROM ss_mae_entradasalida m
         WHERE folio_oper = vfoliooper;

   
         SELECT nombre
         into vnombre
         from bdinteg:si_sucursales
         where sucursal = vsucursal;

         SELECT descripcion
         into vdescripcion
         from ss_catstatus
         where status = vstatus;

           if vdescripcion is null then
          let vdescripcion = 'Operacion Realizada';
         end if;

   



         IF vcont < pregistro THEN
            LET vcont = vcont + 1;
            continue foreach;
         END IF
         LET vcont = vcont + 1;


        return    vfoliooper,vsucursal,vfechasolicitud,vusuariosolicitud,
                  vfechaenvio,vusuarioenvio,vfecharecepcion,vusuariorecepcion,vstatus,vmonto,vfechareversion,
                  vusuarioreversion,vnombre, vdescripcion, vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                  vdeno_4,vdeno_5,vdeno_6, vcant_1, vcant_2, vcant_3,
                  vcant_4, vcant_5, vcant_6
                  with resume;

   end foreach;

end if;
end
end procedure
DOCUMENT
'MODIFICÓ:    	Jesus Moreno',
'FECHA:       	14/10/2019',
'DESCRIPCIÓN: 	se modifica el tipo de dato de las variables DEFINE vcant_1,vcant_2,vcant_3,vcant_4,vcant_5 ,vcant_6',
'BASE DE DATOS: bdisuc',
'FOLIO:628',
'Llamado desde:MonitorAtm.exe',
'MODIFICÓ:    	Jesus Moreno',
'FECHA:       	06/01/2020',
'DESCRIPCIÓN: 	se renombra el sp de sp_monitor_atm01 a sp_monitor_atm_admin';

CREATE PROCEDURE "informix".sp_inserta_atm_ofi(pempresa CHAR(3),
                                           pcod_atm CHAR(4), 
                                           pdivisa  CHAR(2), 
                                           pcant_1  FLOAT,
                                           pcant_2  FLOAT,
                                           pcant_3  FLOAT,
                                           pcant_4  FLOAT,
                                           pcant_5  FLOAT,
                                           pcant_6  FLOAT,
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
LET vSaldo_ant = "";
LET vSaldo_asi = "";
LET vSaldo_tot = "";
LET bTransacInterAct     = 'F';
LET bEnTransac           = 'F';

LET vcant_1 = "";
LET vcant_2 = "";
LET vcant_3 = "";
LET vcant_4 = "";
LET vcant_5 = "";
LET vcant_6 = "";
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

	UPDATE bdisuc:"informix".ss_atm SET cantidad_1 = cantidad_1 + pcant_1,cantidad_2 = cantidad_2 + pcant_2,cantidad_3 = cantidad_3 + pcant_3,cantidad_4 = cantidad_4 + pcant_4,cantidad_5 = cantidad_5 + pcant_5,cantidad_6 = cantidad_6 + pcant_6,
	saldo_anterior = saldo_total,saldo_asignado = 0,saldo_total = saldo_total + pmonto
	WHERE empresa = pempresa AND cod_atm = pcod_atm;

ELSE
	LET vden01 = '1000';
	LET vden02 = '500';
	LET vden03 = '200';
	LET vden04 = '100';
	LET vden05 = '50';
	LET vden06 = '20';
	LET vden07 = '-1';
	
	DELETE FROM ss_atm_rec WHERE empresa = pempresa AND cod_atm = pcod_atm;
	
	INSERT INTO bdisuc:"informix".ss_atm (empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3, denominacion_4,denominacion_5,denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,	denominacion_11,denominacion_12,denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,
	cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
	cantidad_13,cantidad_14,cantidad_15)
	VALUES (pempresa, pcod_atm, pdivisa, 0, 0,pmonto,vden01, vden02, vden03, vden04, vden05, vden06,vden07,0,0,0,0,0,0,0,0,pcant_1,
			pcant_2,pcant_3,pcant_4,pcant_5,pcant_6,'0','0','0','0','0','0','0','0','0');

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
'DESCRIPCIÃ?N: Se modifica SP para realizar respaldo de la información en caso de que ocurra algun error restaurar los datos de la tabla de recuperación',
'SOLICITA: Gabriela Angulo',
'Fecha 06-Ene-2020',
'Modifico:  Jesus Moreno',
'Se quita la actualización a la tabla ss_atm_rec y se agrega un delete a la misma, se renombre sp_inserta_atm a sp_inserta_atm_ofi para que solo se mande llamar desde el sistema OFI';

CREATE PROCEDURE "informix".sp_faltsob_atm(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
        pfolio_suc CHAR(16),
  		ptransaccion CHAR(4),
		pdivisa CHAR(2),
		pmonto money(14,2),
        pfecha DATE,
		pdeno1 CHAR(18),
		pdeno2 CHAR(18),
		pdeno3 CHAR(18),
		pdeno4 CHAR(18),
        pdeno5 CHAR(18),
		pdeno6 CHAR(18),
		pdeno7 CHAR(18),
		pdeno8 CHAR(18),
		pdeno9 CHAR(18),
		pdeno10 CHAR(18),
        pdeno11 CHAR(18),
		pdeno12 CHAR(18),
		pdeno13 CHAR(18),
		pdeno14 CHAR(18),
		pdeno15 CHAR(18),
		pcant1 FLOAT(8),
		pcant2 FLOAT(8),
		pcant3 FLOAT(8),
		pcant4 FLOAT(8),
		pcant5 FLOAT(8),
		pcant6 FLOAT(8),
		pcant7 FLOAT(8),
		pcant8 FLOAT(8),
		pcant9 FLOAT(8),
        pcant10 FLOAT(8),
		pcant11 FLOAT(8),
		pcant12 FLOAT(8),
		pcant13 FLOAT(8),
		pcant14 FLOAT(8),
		pcant15 FLOAT(8), 
        poperacion smallint)

RETURNING CHAR(5),CHAR(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio CHAR(8);
DEFINE vsqlerr integer;
DEFINE visamerr INTEGER;
DEFINE vhora CHAR(5);
DEFINE vproveedor CHAR(4);
DEFINE vplaza CHAR(3);
DEFINE vnum CHAR(8);
DEFINE bTransacInterAct	CHAR(1);
DEFINE bEnTransac CHAR(1);

LET vcodret = "000";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vfolio = "";
LET vsqlerr = 0;
LET visamerr = 0;
LET bTransacInterAct = 'F';
LET bEnTransac = 'F';
	
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
			RETURN vcodret,vfolio;
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

	--SET debug file to "/tmp/Ricardo/sp_faltsob.out";
	--trace on;
	
	BEGIN WORK;
	--- Verifica recepcion correcta de datos
	IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
	   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
	   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
	   or pmonto = 0 then
	   LET vcodret = "110";
	ELSE

		select plaza_cajagen into vplaza
		from   bdinteg:si_sucursales
		where  sucursal = psucursal;

		select cod_proveedor into vproveedor
		from   ss_proveedores
		where  plaza = vplaza;

		IF EXISTS (select cod_proveedor from ss_proveedores where cod_proveedor = vproveedor) THEN
		   IF poperacion != 0 AND poperacion != 1 THEN
			  LET vcodret = "106";       
		   ELSE 

			SELECT valor
			  INTO vnum
			  FROM bdisuc:"informix".ss_param_cajagen
			 WHERE  codigo = '0005';

			UPDATE bdisuc:"informix".ss_param_cajagen
			   SET  valor = valor + 1
			 WHERE  codigo = '0005';
					
			   LET vfolio = LPAD(ROUND(vnum),8,"0");
			
			--SE AGREGA DEPURACIÓN A LA TABLA DE RECUPERACIÓN			
			DELETE FROM ss_atm_rec WHERE  cod_atm = psucursal;
			   
		    INSERT INTO ss_atm_rec(empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
			denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,denominacion_13,denominacion_14,
			denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,
			cantidad_12,cantidad_13,cantidad_14,cantidad_15 ) 
			SELECT empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
			denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,denominacion_13,denominacion_14,
			denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,
			cantidad_12,cantidad_13,cantidad_14,cantidad_15 FROM ss_atm WHERE  cod_atm = psucursal;
		   
			  INSERT INTO ss_operaciones
						 (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,procedencia,
						  denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
						  denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
						  denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
						  cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
						  cantidad_13,cantidad_14,cantidad_15)
			  VALUES
					 (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto,psucursal,
					  pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
				  pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
				  pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);
			 
			   IF poperacion = 1 THEN    
				  UPDATE ss_atm set cantidad_1 = cantidad_1 + pcant1, cantidad_2 = cantidad_2 + pcant2, 
											cantidad_3 = cantidad_3 + pcant3, cantidad_4 = cantidad_4 + pcant4,
											cantidad_5 = cantidad_5 + pcant5, cantidad_6 = cantidad_6 + pcant6,
											saldo_anterior = saldo_total,
											saldo_total =  saldo_total + pmonto
											  
				  WHERE  cod_atm = psucursal;
	 
			   ELSE
				  UPDATE ss_atm set cantidad_1 = cantidad_1 - pcant1, cantidad_2 = cantidad_2 - pcant2,
											cantidad_3 = cantidad_3 - pcant3, cantidad_4 = cantidad_4 - pcant4,
											cantidad_5 = cantidad_5 - pcant5, cantidad_6 = cantidad_6 - pcant6,
											saldo_anterior = saldo_total,
											saldo_total =  saldo_total - pmonto
				  WHERE  cod_atm = psucursal;
	 

			   END IF; 

		   END IF; 
		ELSE
		   let vcodret = "105";
		   return vcodret,vfolio;
	    END IF;
	END IF;

	COMMIT WORK;
	IF bTransacInterAct = 'T' THEN
		BEGIN WORK;
	END IF;

	RETURN vcodret,vfolio;
END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:628',
'Llamado desde:FaltaATM.exe',
'AUTOR:Jesus Moreno', 
'FECHA:2019-09-24',
'DESCRIPCIÓN: Se modifica procedimiento para realiza rollback',
'SOLICITA: Gabriela Angulo',
'AUTOR:Jesus Moreno', 
'FECHA:2020-01-06',
'DESCRIPCIÓN: Se agrega depurado a la tabla ss_atm_rec y se renombre al sp de sp_faltsob01 a sp_faltsob_atm',
'SOLICITA: Gabriela Angulo';

CREATE PROCEDURE "informix".sp_rpt_dotacionesatm_sucursal()
RETURNING CHAR(5) AS cod_ret, CHAR(150) AS msj_ret;
--VARIABLES DE CONTROL DE ERROR
DEFINE iSqlErr    INTEGER;
DEFINE iIsamErr   INTEGER;
DEFINE iPasoErr   INTEGER;
DEFINE cCod_ret	  CHAR(5);
DEFINE cMsj_ret	  CHAR(150);
DEFINE cCmd		  CHAR(500);
--VARIABLES DE ARCHIVOS
DEFINE cRuta 	  CHAR(30);
DEFINE cPrefijo   CHAR(21);
DEFINE cExtension CHAR(4);
DEFINE cArchivo  CHAR(63);
DEFINE dFecha_ant DATE;
DEFINE cDia		  CHAR(2);
DEFINE cMes		  CHAR(2);
DEFINE cAno		  CHAR(4);
DEFINE cFechaRpt  CHAR(8);
--VARIABLES
DEFINE cFolio          CHAR(8);
DEFINE cCodTrans       CHAR(4);
DEFINE cDesTrans       CHAR(35);
DEFINE cTransaccion    CHAR(40);
DEFINE cIdAtm          CHAR(6);
DEFINE cAtm            CHAR(4);
DEFINE cNomBre         CHAR(40);
DEFINE mImporte        MONEY(14,2);
DEFINE iBilletes500    INTEGER;
DEFINE mTotal500       MONEY(14,2);
DEFINE iBilletes200    INTEGER;
DEFINE mTotal200       MONEY(14,2);
DEFINE iBilletes100    INTEGER;
DEFINE mTotal100       MONEY(14,2);
DEFINE iBilletes50     INTEGER;
DEFINE mTotal50        MONEY(14,2);
DEFINE cReverso        CHAR(1);
DEFINE cReversada      CHAR(2);
DEFINE dFechaSolicitud DATE;
DEFINE cHoraSolicitud  CHAR(5);
DEFINE cNumEmpSol      CHAR(8);
DEFINE dFechaEnvio     DATE;
DEFINE cHoraEnvio      CHAR(5);
DEFINE cNumEmpEnv      CHAR(8);
DEFINE dFechaRecepcion DATE;
DEFINE cHoraRecepcion  CHAR(5);
DEFINE cNumEmpRec      CHAR(8);
DEFINE cCodStatus      CHAR(2);
DEFINE cCodPlaza       CHAR(3);
DEFINE cDescPlaza      CHAR(30);
DEFINE cPlaza		   CHAR(33);
DEFINE cNomEmp         CHAR(45);
DEFINE cDescStatus     CHAR(30);
DEFINE cStatus         CHAR(32);
DEFINE cFecHorSol      CHAR(16);
DEFINE cFecHorEnv      CHAR(16);
DEFINE cFecHorRec      CHAR(16);
DEFINE cEmpSol         CHAR(54);
DEFINE cEmpEnv         CHAR(54);
DEFINE cEmpRec         CHAR(54);

LET cFolio          = '';
LET cCodTrans       = '';
LET cDesTrans       = '';
LET cTransaccion    = '';
LET cIdAtm          = '';
LET cAtm            = '';
LET cNomBre         = '';
LET mImporte        = 0;
LET iBilletes500    = 0;
LET mTotal500       = 0;
LET iBilletes200    = 0;
LET mTotal200       = 0;
LET iBilletes100    = 0;
LET mTotal100       = 0;
LET iBilletes50     = 0;
LET mTotal50        = 0;
LET cReverso        = '';
LET cReversada      = '';
LET dFechaSolicitud = '';
LET cHoraSolicitud  = '';
LET cNumEmpSol      = '';
LET dFechaEnvio     = '';
LET cHoraEnvio      = '';
LET cNumEmpEnv      = '';
LET dFechaRecepcion = '';
LET cHoraRecepcion  = '';
LET cNumEmpRec      = '';
LET cCodStatus      = '';
LET cCodPlaza       = '';
LET cDescPlaza      = '';
LET cPlaza			= '';
LET cNomEmp         = '';
LET cDescStatus     = '';
LET cStatus         = '';
LET cFecHorSol      = '';
LET cFecHorEnv      = '';
LET cFecHorRec      = '';
LET cEmpSol         = '';
LET cEmpEnv         = '';
LET cEmpRec         = '';

LET iPasoErr = 0;
LET cCod_ret = '';
LET cMsj_ret = '';
LET cCmd = '';

LET cDia = '';
LET cMes = '';
LET cAno = '';
LET cFechaRpt = '';
LET cRuta = '/resplogifx/OFIConciliacion';
LET cExtension = '.txt';
LET cArchivo = '';

--SET DEBUG FILE TO "/resplogifx/OFIConciliacion/sp_rpt_dotacionesatm_sucursal.out";
--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
				TRUNCATE TABLE rpt_operacionatm_bancoppel_tmp;
				TRUNCATE TABLE rpt_dotacionatm_bancoppel_tmp;
				DROP TABLE IF EXISTS atms_administrados_bancoppel;
				RETURN iSqlErr, iIsamErr||' En paso: '||iPasoErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--ELIMINA INFORMACION DE LAS TABLAS DE PASO
		TRUNCATE TABLE rpt_operacionatm_bancoppel_tmp;
		TRUNCATE TABLE rpt_dotacionatm_bancoppel_tmp;
		DROP TABLE IF EXISTS atms_administrados_bancoppel;
		
		--OBTIENE LA FECHA DEL DÃA ANTERIOR DE LA FECHA ACTUAL
		SELECT fecha_ant INTO dFecha_ant FROM bdinteg:"informix".si_fechas;
		LET cDia = LPAD(DAY(dFecha_ant), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_ant), 2, '0');
		LET cAno = YEAR(dFecha_ant);
		
		--DA FORMATO 'AAAAMMDD' A LA FECHA
		LET cFechaRpt = cAno||cMes||cDia;
		
		SELECT {+INDEX (bdinteg:"informix".si_sucursales idx_si_sucursales_empzon)} sucursal FROM bdinteg:"informix".si_sucursales 
		WHERE tpo_sucursal = 'C' AND plaza_cajagen IS NOT NULL AND sucursal NOT IN (SELECT cod_atm FROM bdisuc:"informix".ss_atms_sucursal) 
		INTO TEMP atms_administrados_bancoppel;
		
		LET cPrefijo = '/OperacionesSucursal_';
		
		--NOMBRE COMPLETO DEL ARCHIVO
		LET cArchivo = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cFechaRpt)||TRIM(cExtension);

		FOREACH
			SELECT folio_oper, cod_trans, sucursal, monto, cantidad_2, (denominacion_2 * cantidad_2), cantidad_3, (denominacion_3 * cantidad_3), cantidad_4, (denominacion_4 * cantidad_4), cantidad_5, (denominacion_5 * cantidad_5), reversado
			INTO	cFolio, cCodTrans, cAtm, mImporte, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50, cReverso
			FROM bdisuc:"informix".ss_operaciones 
			WHERE fecha_operacion = (
				SELECT fecha_ant FROM bdinteg:"informix".si_fechas)
			AND sucursal IN (SELECT sucursal FROM atms_administrados_bancoppel)
			
			SELECT descripcion INTO cDesTrans FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = cCodTrans;
			
			SELECT {+INDEX (bdisuc:"informix".ss_relacionccid idx_relacioncc)} id INTO cIdAtm FROM bdisuc:"informix".ss_relacionccid WHERE cc = cAtm;
			
			SELECT nombre INTO cNombre FROM bdinteg:"informix".si_sucursales WHERE sucursal = cAtm;
			
			IF cReverso = '0' THEN
				LET cReversada = 'NO';
			ELSE
				LET cReversada = 'SI';
			END IF;
			
			LET cTransaccion = TRIM(cCodTrans)||' '||UPPER(TRIM(cDesTrans));
			LET cNombre = UPPER(TRIM(cNombre));
			
			INSERT INTO rpt_operacionatm_bancoppel_tmp VALUES (
			cFolio, cTransaccion, cIdAtm, cAtm, cNombre, mImporte, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50, cReversada);
			
		END FOREACH;
			
		LET iPasoErr = 1;
		LET cCmd= '';
		LET cCmd= 'echo "UNLOAD TO '||TRIM(cArchivo)||' DELIMITER '||"'|'"||' SELECT * FROM rpt_operacionatm_bancoppel_tmp ORDER BY folio;" >> '||TRIM(cRuta)||'/rpt_operacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 2;
		LET cCmd = '';
		LET cCmd = 'dbaccess bdisuc '||TRIM(cRuta)||'/rpt_operacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 3;
		LET cCmd = '';
		LET cCmd = 'rm -f '||TRIM(cRuta)||'/rpt_operacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET cPrefijo = '/DotacionesSucursal_';
		
		--NOMBRE COMPLETO DEL ARCHIVO
		LET cArchivo = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cFechaRpt)||TRIM(cExtension);

		FOREACH
			SELECT {+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_oper, sucursal, fecha_solicitud, hora_solicitud, usuario_solicitud, fecha_envio, hora_envio, usuario_envio, fecha_recepcion, hora_recepcion, usuario_recepcion, status, monto
			INTO cFolio, cAtm, dFechaSolicitud, cHoraSolicitud, cNumEmpSol, dFechaEnvio, cHoraEnvio, cNumEmpEnv, dFechaRecepcion, cHoraRecepcion, cNumEmpRec, cCodStatus, mImporte
			FROM bdisuc:"informix".ss_mae_entradasalida WHERE fecha_solicitud = (
				SELECT fecha_ant FROM bdinteg:"informix".si_fechas)
			AND sucursal IN (SELECT sucursal FROM atms_administrados_bancoppel)
			
			SELECT cod_trans, cantidad_2, (denominacion_2 * cantidad_2), cantidad_3, (denominacion_3 * cantidad_3), cantidad_4, (denominacion_4 * cantidad_4), cantidad_5, (denominacion_5 * cantidad_5)
			INTO cCodTrans, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50
			FROM bdisuc:"informix".ss_operaciones WHERE folio_oper = cFolio;
			
			SELECT {+INDEX (bdisuc:"informix".ss_relacionccid idx_relacioncc)} id INTO cIdAtm FROM bdisuc:"informix".ss_relacionccid WHERE cc = cAtm;
			
			SELECT nombre, plaza_cajagen INTO cNombre, cCodPlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = cAtm;
			
			SELECT descripcion INTO cDescPlaza FROM bdisuc:"informix".ss_proveedores WHERE plaza = cCodPlaza;
			
			SELECT descripcion INTO cDesTrans FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = cCodTrans;
			
			SELECT nombre INTO cNomEmp FROM bdinteg:si_ejecut WHERE ejecutivo = cNumEmpSol;
			
			LET cEmpSol = TRIM(NVL(cNumEmpSol, ''))||' '||UPPER(TRIM(NVL(cNomEmp, '')));
			
			SELECT nombre INTO cNomEmp FROM bdinteg:si_ejecut WHERE ejecutivo = cNumEmpEnv;
			
			LET cEmpEnv = TRIM(NVL(cNumEmpEnv, ''))||' '||UPPER(TRIM(NVL(cNomEmp, '')));
			
			SELECT nombre INTO cNomEmp FROM bdinteg:si_ejecut WHERE ejecutivo = cNumEmpRec;
			
			LET cEmpRec = TRIM(NVL(cNumEmpRec, ''))||' '||UPPER(TRIM(NVL(cNomEmp, '')));
			
			IF cCodStatus = '01' THEN
				LET cDescStatus = 'SOLICITUD DE DOTACION ATM';
			ELIF cCodStatus = '11' THEN
				LET cDescStatus = 'DOTACION ATM APROBADA CG';
			ELIF cCodStatus = '05' THEN
				LET cDescStatus = 'RECEPCION DE DOTACION ATM';
			ELSE 
				SELECT descripcion INTO cDescStatus FROM bdisuc:"informix".ss_catstatus WHERE status = cCodStatus;
			END IF;
			
			LET cPlaza = TRIM(cCodPlaza)||' '||UPPER(TRIM(cDescPlaza));
			LET cTransaccion = TRIM(cCodTrans)||' '||UPPER(TRIM(cDesTrans));
			LET cNombre = UPPER(TRIM(cNombre));
			LET cStatus = TRIM(cCodStatus)||' '||UPPER(TRIM(cDescStatus));
			LET cFecHorSol = dFechaSolicitud||' '||cHoraSolicitud;
			LET cFecHorEnv = NVL(dFechaEnvio, '')||' '||NVL(cHoraEnvio, '');
			LET cFecHorRec = NVL(dFechaRecepcion, '')||' '||NVL(cHoraRecepcion, '');
			
			INSERT INTO rpt_dotacionatm_bancoppel_tmp VALUES (
			cIdAtm, cAtm, cNombre, cPlaza, cTransaccion, cStatus, cFolio, cFecHorSol, cEmpSol, cFecHorEnv, cEmpEnv, cFecHorRec, cEmpRec, mImporte, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50);	
		END FOREACH;
		
		LET iPasoErr = 4;
		LET cCmd= '';
		LET cCmd= 'echo "UNLOAD TO '||TRIM(cArchivo)||' DELIMITER '||"'|'"||' SELECT * FROM rpt_dotacionatm_bancoppel_tmp ORDER BY folio;" >> '||TRIM(cRuta)||'/descarga_rpt_dotacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 5;
		LET cCmd = '';
		LET cCmd = 'dbaccess bdisuc '||TRIM(cRuta)||'/descarga_rpt_dotacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 6;
		LET cCmd = '';
		LET cCmd = 'rm -f '||TRIM(cRuta)||'/descarga_rpt_dotacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET cCod_ret = '00000';
		LET cMsj_ret = 'REPORTES GENERADOS: OperacionesSucursal y DotacionesSucursal DEL DÃA '||dFecha_ant;
		
		TRUNCATE TABLE rpt_operacionatm_bancoppel_tmp;
		TRUNCATE TABLE rpt_dotacionatm_bancoppel_tmp;
		DROP TABLE atms_administrados_bancoppel;
			
		RETURN cCod_ret, cMsj_ret;
		
	END;
END PROCEDURE;