CREATE PROCEDURE "informix".renivelaesp(g_NumCredito CHAR(20),
					g_Empresa CHAR(3))
   RETURNING CHAR(5);

   DEFINE CodRet                CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nRows                 SMALLINT;

   DEFINE CuotaFija              MONEY(14,2);
   DEFINE TasaInteres            DECIMAL(9,6);
   DEFINE vPlazo                 SMALLINT;
   DEFINE Factor                 DECIMAL(9,6);

   DEFINE Interes                MONEY(14,2);
   DEFINE Capital                MONEY(14,2);
   DEFINE SdoCapital             MONEY(14,2);

   DEFINE vFecha                 DATE;
   DEFINE vSdoCap                MONEY(14,2);
   DEFINE vCapit                 MONEY(14,2);
   DEFINE vInter                 MONEY(14,2);
   DEFINE SdoInteres             MONEY(14,2);

   DEFINE MontoRealPag           MONEY(14,2);
   DEFINE StatusCuota            CHAR(1);
   DEFINE wfecha                 DATE;


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "RenivelaPLanPagos.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;



   LET CodRet = '000';

   CREATE  TEMP TABLE
      RenivPagos
         (fecha   DATE,
          sdocap  MONEY(14,2),
          capit   MONEY(14,2),
          inter   MONEY(14,2));

   INSERT INTO RenivPagos SELECT
                             fecha_cuota,
                             0,
                             0,
                             0
                          FROM
                             sd_pagocapit
                          WHERE
                             empresa  = g_Empresa
                          AND
                             num_credito = g_NumCredito
                          AND
                             status_cuota = '1';

   SELECT
      tasa_interes,
      (SELECT a.monto_cuota + b.monto_cuota
	 FROM sd_pagocapit a, sd_paginter b
	WHERE b.num_credito = a.num_credito
	  AND b.fecha_cuota = a.fecha_cuota
	  AND a.num_credito = g_NumCredito
	  AND a.fecha_cuota = (SELECT MIN(fecha_cuota) FROM sd_pagocapit d
			        WHERE d.num_credito = g_NumCredito)),
      plazo,
      sdo_capital
   INTO
      TasaInteres,
      CuotaFija,
      vPlazo,
      SdoCapital
   FROM
      sd_maecred a,
      sd_maesdos b
   WHERE
      a.empresa = g_Empresa
   AND
     a.num_credito = g_NumCredito
   AND
      b.empresa = a.empresa
   AND
      b.num_credito = a.num_credito;

   SELECT
      SUM(saldo_cuota - monto_real_pag)
   INTO
      SdoCapital
   FROM
      sd_pagocapit
   WHERE
      empresa = g_Empresa
   AND
      num_credito = g_NumCredito
   AND
     status_cuota = '1';


   LET Factor = ROUND((((TasaInteres/ 100) / 12) + 1) , 8);

   FOREACH
      SELECT
         fecha,
         sdocap,
         capit ,
         inter
      INTO
         vFecha,
         vSdoCap,
         vCapit,
         vInter
      FROM
         RenivPagos
      ORDER BY
         fecha

      LET vInter = ROUND((SdoCapital * (Factor - 1)), 2);
      LET vCapit = CuotaFija - vInter;
      IF (vCapit > SdoCapital) THEN
         LET vCapit = SdoCapital;
      END IF;
      LET vSdoCap = SdoCapital;
      LET SdoCapital = SdoCapital - vCapit;
      UPDATE
         RenivPagos
      SET
         SdoCap = vSdoCap,
         Capit  = vCapit,
         Inter  = vInter
      WHERE
         fecha = vFecha;

   END FOREACH;

   FOREACH
      SELECT
         fecha,
         sdocap,
         capit ,
         inter
      INTO
         vFecha,
         vSdoCap,
         vCapit,
         vInter
      FROM
         RenivPagos
      ORDER BY
         fecha

      UPDATE
         sd_pagocapit
      SET
         monto_cuota = vCapit,
         saldo_cuota = vCapit,
         monto_real_pag = 0
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFecha;

      UPDATE
         sd_paginter
      SET
         monto_cuota = vInter
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFecha;

   END FOREACH;

   SELECT
      SUM(monto_cuota - monto_real_pag)
   INTO
     SdoInteres
   FROM
      sd_paginter
   WHERE
      empresa = g_Empresa
   AND
      num_credito = g_NumCredito;

   UPDATE
      sd_maesdos
   SET
      sdo_no_exig = SdoInteres
   WHERE
      empresa = g_Empresa
   AND
      num_credito = g_NumCredito;


   DROP TABLE RenivPagos;

   RETURN CodRet;

END PROCEDURE

DOCUMENT
'Programa de Renivelacion de Pagos despues de un Pago Anticipado ',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Diciembre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

create procedure "informix".sp_pagoparcial( pempresa char(3),
				 ptipo char(1) )
returning	integer ,
		char(20) ,
		date ,
		decimal(14,2) ,
		decimal(14,2) ,
		decimal(14,2) ;

define r_count integer;
define r_num_credito char(20);
define r_fecha_pago date;
define r_principal decimal(14,2);
define r_interes decimal(14,2);
define r_seguros decimal(14,2);

define v_fecha_ult date;

let r_count = 0;

foreach
	select a.num_credito
	into r_num_credito
	from sd_maecred a
	where a.empresa = pempresa
	and a.status_cred <> 'CC'


        select max(a.fecha_cuota)
        into v_fecha_ult
        from sd_pagocapit a
        where a.empresa = pempresa
        and a.num_credito = r_num_credito
        and a.status_cuota in ('1','2','7');


	foreach 
		select a.fecha_cuota 
		into r_fecha_pago
		from sd_pagocapit a
		where a.empresa = pempresa
		and a.num_credito = r_num_credito
		and a.status_cuota in ('1','2','7')
		order by a.fecha_cuota

		if r_fecha_pago = v_fecha_ult then
			exit foreach;
		end if;

		-- Presenta Principal por Cuota segun el detalle de Credito
                select sum(a.monto_real_pag)
                into r_principal
                from bdicred:sd_pagocapit a
                where a.empresa = pempresa
                and a.num_credito = r_num_credito
                and a.fecha_cuota = r_fecha_pago;
                if r_principal is null then
                	let r_principal = 0;
                end if;

                -- Presenta Interes por Cuota segun el detalle de Credito
                select sum(a.monto_real_pag)
                into r_interes
                from bdicred:sd_paginter a
                where a.empresa = pempresa
                and a.num_credito = r_num_credito
                and a.fecha_cuota = r_fecha_pago;
                if r_interes is null then
                	let r_interes = 0;
                end if;


                -- Presenta Seguros por Cuota segun el detalle de Credito
                select sum(a.monto_pag)
                into r_seguros
                from bdicred:sd_detcomi a
                where a.empresa = pempresa
                and a.num_credito = r_num_credito
                and a.fecha_alta = r_fecha_pago
                and a.cod_comis in ('0101','0102','0103','0104','0105','0106');
                if r_seguros is null then
                	let r_seguros = 0;
                end if;
		
		if r_principal + r_interes + r_seguros <> 0 then
			let r_count = r_count + 1;
			return r_count, r_num_credito, r_fecha_pago, r_principal, r_interes, r_seguros with resume;	
		end if;
		
		if ptipo = '1' then
			exit foreach;
		end if;
	end foreach;
end foreach;

end procedure;