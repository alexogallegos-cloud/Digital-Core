CREATE PROCEDURE "informix".sp_concen_crg_masiva()
RETURNING
        CHAR(5) as Codigo,
        CHAR(50) as Mensaje;
		
DEFINE vempresa 	CHAR(4);
DEFINE vusuario 	CHAR(8);
DEFINE vtransac 	CHAR(4);
DEFINE vdivisa 		CHAR(2);
DEFINE vsecuencia 	CHAR(8);
DEFINE vfolio_suc 	CHAR(18);
DEFINE vfecha		DATE;

DEFINE vfolio_serv	CHAR(16);
DEFINE vsucursal	CHAR(4);
DEFINE vmonto		money;
DEFINE vcant_1000	FLOAT(8);
DEFINE vcant_500	FLOAT(8);
DEFINE vcant_200	FLOAT(8);
DEFINE vcant_100	FLOAT(8);
DEFINE vcant_50		FLOAT(8);
DEFINE vcant_20		FLOAT(8);

DEFINE vcant_1_atm	FLOAT(8);
DEFINE vcant_2_atm	FLOAT(8);
DEFINE vcant_3_atm	FLOAT(8);
DEFINE vcant_4_atm	FLOAT(8);
DEFINE vcant_5_atm	FLOAT(8);
DEFINE vcant_6_atm	FLOAT(8);

DEFINE vcod_ret 	CHAR(5);
DEFINE vDesErr 		CHAR(50);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vcodret_2 	CHAR(5);
DEFINE vfolio_2 	CHAR(8);
DEFINE vsecuencia_i INTEGER;

let vcod_ret     =   '00000';
let vempresa 	=	'001';
let vusuario 	=	'92803849';
let vtransac 	=	'0041';
let vdivisa 	=	'01';
let vsecuencia	=	'';
let vfecha		=	'01/01/1900';
let vsecuencia_i =	0;

BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vDesErr
        IF vsqlerr <> 0 THEN
           LET vcod_ret = vsqlerr;    
           RETURN vcod_ret, vDesErr;			
        END IF       
    END EXCEPTION;
	
	set isolation dirty read;
	
	SELECT fecha_hoy 
	INTO vfecha
	FROM bdinteg:si_fechas;
	
	INSERT INTO "informix".ss_atm_respaldo 
		SELECT empresa,cod_atm, saldo_anterior, saldo_total, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6,'I'
		FROM bdisuc:ss_atm;
	
	let vsecuencia = to_char(extend(current, hour to second),'%H') || to_char(extend(current, hour to second),'%M') || to_char(extend(current, hour to second),'%S') || '00';
	
	let vsecuencia_i = vsecuencia;
	
	FOREACH SELECT folio_servicio,
					sucursal,
					monto,
					cant_1000,
					cant_500,
					cant_200,
					cant_100,
					cant_50,
					cant_20
			INTO vfolio_serv,
					vsucursal,
					vmonto,
					vcant_1000,
					vcant_500,
					vcant_200,
					vcant_100,
					vcant_50,
					vcant_20
			FROM "informix".ss_crgmasiva_concen
			WHERE aplicado not in('S','N')
		
	
	SELECT cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6
	INTO vcant_1_atm, vcant_2_atm, vcant_3_atm, vcant_4_atm, vcant_5_atm, vcant_6_atm
	FROM bdisuc:ss_atm
	WHERE cod_atm = vsucursal;
	
	IF vcant_1000 > vcant_1_atm OR vcant_500 > vcant_2_atm OR vcant_200 > vcant_3_atm
		OR vcant_100 > vcant_4_atm OR vcant_50 > vcant_5_atm OR vcant_20 > vcant_6_atm THEN
			UPDATE bdisuc:ss_crgmasiva_concen SET aplicado = 'N'
			WHERE sucursal = vsucursal AND folio_servicio = vfolio_serv;
	ELSE
		let vsecuencia_i = vsecuencia_i + 1;
	
		let vsecuencia = vsecuencia_i;
			
		let vfolio_suc = TRIM(vusuario) || TRIM(vsecuencia);
	
		EXECUTE PROCEDURE "informix".sp_concen_atm(vempresa,
			vsucursal,
			vusuario,
			vfolio_suc,
			vtransac,
			vdivisa,
			vmonto,
			vfecha,
			'1000',
			'500',
			'200',
			'100',
			'50',
			'20',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			vcant_1000,
			vcant_500,
			vcant_200,
			vcant_100,
			vcant_50,
			vcant_20,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			vfolio_serv)
		INTO vcodret_2, vfolio_2;
		
		IF vcodret_2 <> '000' THEN
			UPDATE bdisuc:ss_crgmasiva_concen SET aplicado = 'N'
			WHERE sucursal = vsucursal AND folio_servicio = vfolio_serv;
		ELSE
			UPDATE bdisuc:ss_crgmasiva_concen SET aplicado = 'S', folio_suc = vfolio_suc
			WHERE sucursal = vsucursal AND folio_servicio = vfolio_serv;
		END IF
		 
	END IF
	
	END FOREACH
	
	INSERT INTO "informix".ss_atm_respaldo 
		SELECT empresa,cod_atm, saldo_anterior, saldo_total, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6,'F'
		FROM bdisuc:ss_atm;
	
	RETURN vcod_ret, 'PROCESO EXITOSO' WITH RESUME;

END
END PROCEDURE;