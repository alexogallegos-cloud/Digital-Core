CREATE PROCEDURE "informix".sp_imprimebymfalsos(pempresa char(3),pfolio char(20))
returning char(5), char (40), char(40),char(40),char(40), char(13)
,char(100),char(100),char(100),char(100),char(40),
date,char(10),char(5),char(10);
--,char(10),char(13),char(20),char(40),char(40),char(10);



DEFINE vCodret char(5);
DEFINE vsqlerr INTEGER;
DEFINE vNombre1 char(40);
DEFINE vNombre2 char(40);
DEFINE vApell_pat char(40);
DEFINE vApell_mat char(40);
define vTelefono char(13);
define nCiudad   char(3);
define nEstado char(2);
define nNumcalle char(10);
define nCalle   integer;
define nColonia  char(6);
define nDelepob  char(3);
define idtenedor integer;  
define vNumrecibo char(10);
define serie       char(40);
define folio      char(40);
define numpieza   integer;
define fecha_emi  date;
define denominacion integer;
define nnombrecalle char(100);
define nnombreciudad char(100); 
define nnombreestado char(100);
define ndeno         char(10);
define cp            char(5);
DEFINE cCiudadoDelegacion    CHAR(3);
DEFINE cCiudadoCoppel        INTEGER;
DEFINE cNombreCol		     CHAR(100);

LET  vsqlerr = 0;
LET vCodret='000';
LET vNombre1='';
LET vNombre2='';
LET vApell_pat='';
LET vApell_mat='';
LET vTelefono ='';
LET nCiudad='';
LET nEstado='';
LET nNumcalle ='';
LET nCalle =0;
LET nColonia='';
LET nDelepob='';
LET idtenedor=0;
LET vnumrecibo='';
let serie='';
let folio='';
let numpieza=0;
let fecha_emi='';
let denominacion=0;
let nnombrecalle='';
let nnombreciudad='';
let nnombreestado=''; 
let ndeno ='';
let cp =''; 
LET cCiudadoDelegacion      = '';
LET cCiudadoCoppel          = 0;
let cNombreCol='';


--SET DEBUG FILE TO '/tmp/imprimebym.out';
--	TRACE ON;
	
BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vCodret,vNombre1,vNombre2,vApell_pat,vApell_mat,
            vTelefono, nnombrecalle, nnombreciudad,nnombreestado,cNombreCol,
            folio,fecha_emi,ndeno,cp,nNumcalle;
        END IF;
    END EXCEPTION;

/*
foreach

select id_tenedor
into idtenedor
from bdisuc:ss_recibo_bym_falsos
where num_recibo=pfolio

select  num_recibo 
into   vnumrecibo
from bdisuc:ss_piezas_bym_falsos
where num_recibo=pfolio;


end foreach;
select  ap_paterno, ap_materno, nombre_1, nombre_2,telefono
into  vApell_pat, vApell_mat,vNombre1,vNombre2 ,vTelefono
from bdisuc:ss_tenedor_pieza 
where id_tenedor=idtenedor;

*/


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;



foreach
	select a.id_tenedor, b.ap_paterno, b.ap_materno, b.nombre_1, b.nombre_2,
		b.telefono,c.serie,c.folio,c.id_denominacion,c.fecha_emision,
		c.num_piezas, b.calle,b.numero_calle,b.colonia,b.delegacion_poblacion,
        b.ciudad,b.estado,b.cod_postal

	into idtenedor,  vApell_pat, vApell_mat,vNombre1,vNombre2 
     ,vTelefono,serie,folio,denominacion,fecha_emi
     ,numpieza,nCalle,nNumcalle,nColonia,ndelepob
      ,nCiudad,nEstado,cp

	from bdisuc:ss_recibo_bym_falsos a, bdisuc:ss_tenedor_pieza b,   bdisuc:ss_piezas_bym_falsos c
	where a.num_recibo=pfolio
	and a.id_tenedor=b.id_tenedor
	and a.num_recibo=c.num_recibo
    

	LET nEstado= NVL(nEstado,'');


	SELECT {+AVOID_FULL(si_estados)} nombre
	INTO nnombreestado
	FROM bdinteg:"informix".si_estados
	WHERE estado =CAST(nEstado AS INTEGER) ;
			
        IF NVL(nCiudad,'') <> '' THEN
            LET cCiudadoDelegacion	= nCiudad;
        ELIF NVL(ndelepob,'') <> '' THEN
            LET cCiudadoDelegacion	= ndelepob;
        END IF;			
   -- let nCiudad= nvl(nCiudad,'');
    --if length(nEstado)='1' then
    --    let nEstado= LPAD(nEstado,3,0);
    --end if;

            IF NVL(cCiudadoDelegacion,'') <>'' THEN
                LET cCiudadoDelegacion= NVL(cCiudadoDelegacion,'');
               
                SELECT nombre, ciudad_coppel
                INTO nnombreciudad,cCiudadoCoppel
                FROM bdinteg:"informix".si_ciudades 
                WHERE estado =CAST(nEstado AS INTEGER)
                AND ciudad = CAST(cCiudadoDelegacion AS INTEGER);

                IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
                    LET cCiudadoCoppel=NVL(cCiudadoCoppel,'');
                    LET nColonia= NVL(nColonia,'');
                    SELECT nombrezona
                    INTO cNombreCol						
                    FROM bdinteg:"informix".si_catzonas 
                    WHERE  numerocolonia = nColonia
                    AND  numerociudad = cCiudadoCoppel;
                END IF;
            END IF;

            Let nCalle= NVL(nCalle,'');

            SELECT nombrecalle
            INTO nnombrecalle
            FROM bdinteg:"informix".si_catcalles
            WHERE numerocalle = nCalle;		

            let nnombrecalle=Nvl(nnombrecalle,'');
            let cNombreCol=Nvl(cNombreCol,'');
            let nnombreciudad=nvl(nnombreciudad,'');
            let nnombreestado=nvl(nnombreestado,'');

	--if  nCiudad ='' then 
	-- if nEstado ='9' then 0
	/*	let nCiudad='09';
		let ndelepob=LPAD(ndelepob,5,0);
		SELECT x.nombrecalle,y.nombre,z.nombre
		into  nnombrecalle,nnombreciudad,nnombreestado
		FROM bdinteg:si_catcalles x,bdinteg:si_ciudades y, bdinteg:si_estados z
		WHERE  x.numerocalle=nCalle
		and 
		z.estado=CAST(NVL(nCiudad,'') AS INTEGER)
		and y.ciudad=CAST(NVL(ndelepob,'') AS INTEGER)
		and y.estado=z.estado;
*/
        --IF DBINFO('sqlca.sqlerrd2') = 0 THEN
         --  Let nnombrecalle='DOMICILIO NO LOCALIZADO';
          -- let nnombreciudad='';
           -- let nnombreestado='';
        --end if;
--end if

--let nnombreestado=ndelepob;
	--else
--end if 
    --let  CAST(NVL(cCiudadoDelegacion,'') AS INTEGER)   
       -- let nCiudad= LPAD(nCiudad,5,0);
	/*	SELECT x.nombrecalle,y.nombre,z.nombre
		into  nnombrecalle,nnombreciudad,nnombreestado
		FROM bdinteg:si_catcalles x,bdinteg:si_ciudades y, bdinteg:si_estados z
		WHERE  x.numerocalle=nCalle
		and z.estado= nEstado 
		and y.ciudad=CAST(NVL(nCiudad,'') AS INTEGER)
		and y.estado=z.estado;

        
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
           Let nnombrecalle='DOMICILIO NO LOCALIZADO';
           let nnombreciudad='';
            let nnombreestado='';
        end if;
*/
	--end if;

	SELECT denominacion  
	into ndeno
	FROM bdisuc:ss_denominacion_bym_falsos
	where id_denominacion=denominacion;


	RETURN vCodret,vNombre1,vNombre2,vApell_pat,vApell_mat,
	vTelefono,nnombrecalle, nnombreciudad,nnombreestado,cNombreCol,
	folio,fecha_emi,ndeno,cp,nNumcalle with resume;
	end foreach;
    
    IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET vCodret = '001'; 
            RETURN vCodret,vNombre1,vNombre2,vApell_pat,vApell_mat,
                vTelefono,nnombrecalle, nnombreciudad,nnombreestado,cNombreCol,
                folio,fecha_emi,ndeno,cp,nNumcalle;
			--LET iPaginacionRetorno = 0 ; --SE INICIALIZA EL VALOR.
		END IF;
end
end procedure

DOCUMENT
'REALIZO:	Edgar Barrera',
'FECHA:		28/04/2020',
'FUNCION:	Recupera informacion del cliente para imprimir recibo de billetes presuntamente falsos',
'BDD:		bdisuc';

CREATE PROCEDURE "informix".sp_cancelar_solicitud_dota(pfolio CHAR(8), iOperacion INTEGER)
RETURNING CHAR(5);


DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vhora CHAR(2);

LET vhora = '';
LET vcodret = '00000';

--SET debug file to "/home/sysIFx/Ever/sp_cancelar_solicitud_dota.out";
--trace on;

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H') 
	INTO vhora FROM bdisuc:"informix".ss_operaciones
	WHERE folio_oper = pfolio;
	
	IF vhora >= 15 THEN
		LET vcodret= '00002';
	END IF;
	
	IF vcodret = '00000' THEN
		IF iOperacion = 1 THEN
			IF pfolio IS NULL or pfolio = '' THEN
				LET vcodret= '00001';
			ELSE
				UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '18' WHERE folio_oper = pfolio;
				UPDATE bdisuc:"informix".ss_operaciones SET reversado = '1' WHERE folio_oper = pfolio;
			END IF;
		END IF;
	END IF;
	
	RETURN vcodret;  
END
END PROCEDURE
DOCUMENT
'CREO: Jesus Moreno',
'FECHA: 15/06/2020',
'DESCRIPCIÓN: se crea sp para validar las solicitudes y cancelarlas antes de las 14 hrs',
'BASE DE DATOS: bdisuc',
'FOLIO:674';

CREATE PROCEDURE "informix".sp_consulta_fechausuario_oper(pfolio CHAR(8))
RETURNING CHAR(4),DATE,CHAR(8);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vfecha DATE;
DEFINE vusuario CHAR(8);

LET vcodret = '000';
LET  vsqlerr = 0;
LET vfecha = '01/01/1900';
LET vusuario = '0';

--SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/spl/sp_monitor.out";
--trace on;

BEGIN
	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			LET vcodret = vsqlerr;
			RETURN vcodret, vfecha, vusuario;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pfolio,'') <> '' THEN
		SELECT fecha_operacion, usuario 
		INTO vfecha, vusuario
		FROM bdisuc:"informix".ss_operaciones
		WHERE folio_oper = pfolio;
	ELSE
		LET vcodret = '001';
	END IF;

RETURN vcodret, vfecha, vusuario;

END
END PROCEDURE
DOCUMENT
'CREO: Jesus Moreno',
'FECHA: 16/06/2020',
'DESCRIPCIÓN: se crea para obtener la fecha operacion y usuario',
'BASE DE DATOS: bdisuc',
'FOLIO:674',
'Llamado desde:MonitorAtm.exe';

CREATE PROCEDURE "informix".sp_faltsob_atm_ofi(
	pempresa CHAR(3),
	psucursal CHAR(4),
	pcajeroprincipal CHAR(8),
	pfolio_suc CHAR(16),
	ptransaccion CHAR(4),
	pdivisa CHAR(2),
	pmonto MONEY(14,2),
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
	poperacion SMALLINT,
	pmotivo CHAR(2),
	pfolio_ope CHAR(8))
RETURNING CHAR(5),CHAR(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio CHAR(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora CHAR(5);
DEFINE vproveedor CHAR(4);
DEFINE vplaza CHAR(3);
DEFINE vprocedencia CHAR(4);
DEFINE vnum INTEGER;
DEFINE iContador INTEGER;
DEFINE bTransacInterAct	CHAR(1);
DEFINE bEnTransac CHAR(1);
LET vcodret = "000";
LET vproveedor = "";
LEt vplaza = "";
LET vprocedencia = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vfolio = "";
LET iContador = 0;
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

	--SET DEBUG FILE TO "/home/sysifx/Mario/trace.sql";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN WORK;
    --- Verifica recepcion correcta de datos
    IF pempresa = '0' OR pempresa = '' OR psucursal = '0' OR psucursal = '' OR pdivisa = '0' OR pdivisa = ''  OR pcajeroprincipal = '0' 
        OR pcajeroprincipal = '' OR pfolio_suc = '0' OR pfolio_suc = '' OR ptransaccion = '0' OR ptransaccion = '' OR pmonto = 0 THEN
        LET vcodret = "110";
    ELSE
        SELECT plaza_cajagen 
        INTO vplaza
        FROM bdinteg:"informix".si_sucursales
        WHERE sucursal = psucursal
		AND empresa = pempresa;

        SELECT cod_proveedor 
        INTO vproveedor
        FROM bdisuc:"informix".ss_proveedores
        WHERE plaza = vplaza;

        --IF EXISTS (SELECT cod_proveedor FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = vproveedor) THEN
		SELECT COUNT(*) INTO iContador FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = vproveedor;		
		IF iContador > 0 THEN
            IF poperacion != 0 AND poperacion != 1 THEN
                LET vcodret = "106";
            ELSE
	            SELECT valor
	            INTO vnum
	            FROM bdisuc:"informix".ss_param_cajagen
	            WHERE codigo = '0005';

	            UPDATE bdisuc:"informix".ss_param_cajagen
	            SET    valor = valor + 1
	            WHERE  codigo = '0005';
				
				LET vfolio = LPAD(ROUND(vnum),8,"0");

				SELECT sucursal 
			    INTO vprocedencia
			    FROM bdisuc:ss_atms_sucursal 
				WHERE cod_atm = psucursal;

				IF vprocedencia ="" OR vprocedencia IS NULL THEN
					LET vprocedencia = psucursal;
				END IF

				--SE AGREGA DEPURACIÓN A LA TABLA DE RECUPERACIÓN			
				DELETE FROM bdisuc:"informix".ss_atm_rec WHERE  cod_atm = psucursal;
				   
				INSERT INTO bdisuc:"informix".ss_atm_rec(empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
				denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,denominacion_13,denominacion_14,
				denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,
				cantidad_12,cantidad_13,cantidad_14,cantidad_15 ) 
				SELECT empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
				denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,denominacion_13,denominacion_14,
				denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,
				cantidad_12,cantidad_13,cantidad_14,cantidad_15 FROM ss_atm WHERE  cod_atm = psucursal;

				INSERT INTO bdisuc:"informix".ss_operaciones(empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,
				procedencia,monto,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
				denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
				denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
				cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
				cantidad_13,cantidad_14,cantidad_15,motiv_afecta,mov_aplicado)
				VALUES(pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,vprocedencia,pmonto,pdeno1,pdeno2,pdeno3,
				pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,
				pcant5,pcant6,pcant7,pcant8,pcant9,pcant10,pcant11,pcant12,pcant13,pcant14,pcant15,pmotivo,0);

				IF poperacion = 1 THEN

					UPDATE bdisuc:"informix".ss_atm 
					SET cantidad_1 = cantidad_1 + pcant1, cantidad_2 = cantidad_2 + pcant2, cantidad_3 = cantidad_3 + pcant3, 
					cantidad_4 = cantidad_4 + pcant4, cantidad_5 = cantidad_5 + pcant5, cantidad_6 = cantidad_6 + pcant6,
					cantidad_7 = cantidad_7 + pcant7, cantidad_8 = cantidad_8 + pcant8, cantidad_9 = cantidad_9 + pcant9,
					cantidad_10 = cantidad_10 + pcant10,						
					saldo_anterior = saldo_total, saldo_total =  saldo_total + pmonto
					WHERE cod_atm = psucursal;

                ELIF poperacion = 0 THEN

					UPDATE bdisuc:"informix".ss_atm 
					SET cantidad_1 = cantidad_1 - pcant1, cantidad_2 = cantidad_2 - pcant2, cantidad_3 = cantidad_3 - pcant3, 
					cantidad_4 = cantidad_4 - pcant4, cantidad_5 = cantidad_5 - pcant5, cantidad_6 = cantidad_6 - pcant6,
					cantidad_7 = cantidad_7 - pcant7, cantidad_8 = cantidad_8 - pcant8, cantidad_9 = cantidad_9 - pcant9,
					cantidad_10 = cantidad_10 - pcant10,
					saldo_anterior = saldo_total, saldo_total =  saldo_total - pmonto
					WHERE cod_atm = psucursal;

                END IF;

				IF Trim(pfolio_ope) <> '0' THEN
					UPDATE bdisuc:"informix".ss_operaciones SET mov_aplicado = 1 WHERE folio_oper = pfolio_ope;
				END IF

            END IF;
        ELSE
            LET vcodret = "105";
            RETURN vcodret,vfolio;
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
'DESCRIPCION: Se modifica procedimiento para guardar en monedas en el arqueo de cajeros ATM',
'AUTOR: 95142134 - Mario Gallardo',
'FECHA DE CREACION: 03/06/2020',
'BD: bdisuc',
'Folio: 674 - Ofi Plus';

CREATE PROCEDURE "informix".sp_faltsob_ofi(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
        pfolio_suc char(16),
  		ptransaccion char(4),
		pdivisa CHAR(2),
		pmonto money(14,2),
        pfecha date,
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
		pcant1 float(8),
		pcant2 float(8),
		pcant3 float(8),
		pcant4 float(8),
		pcant5 float(8),
		pcant6 float(8),
		pcant7 float(8),
		pcant8 float(8),
		pcant9 float(8),
        pcant10 float(8),
		pcant11 float(8),
		pcant12 float(8),
		pcant13 float(8),
		pcant14 float(8),
		pcant15 float(8), 
        poperacion smallint)
RETURNING CHAR(5),char(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio char(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vproveedor char(4);
DEFINE vplaza char(3);
DEFINE vnum char(8);

LET vcodret = "000";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vfolio = "";
	BEGIN
		ON EXCEPTION SET vsqlerr,visamerr
		   IF vsqlerr != 0 THEN
			  LET vcodret=vsqlerr;
			  RETURN vcodret,vfolio;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET debug file to "/tmp/sp_faltsob.out";
		--trace on;

		--- Verifica recepcion correcta de datos
		IF pempresa = '0' OR pempresa = '' OR psucursal = '0' OR psucursal = '' OR
		   pdivisa = '0' OR pdivisa = ''  OR pcajeroprincipal = '0' OR pcajeroprincipal = ''
		   OR pfolio_suc = '0' OR pfolio_suc = '' OR ptransaccion = '0' OR ptransaccion = ''
		   OR pmonto = 0 THEN
		   LET vcodret = "110";
		ELSE

			SELECT plaza_cajagen INTO vplaza
			FROM   bdinteg:si_sucursales
			WHERE  sucursal = psucursal;

			SELECT cod_proveedor INTO vproveedor
			FROM   ss_proveedores
			WHERE  plaza = vplaza;

			IF EXISTS (SELECT cod_proveedor FROM ss_proveedores WHERE cod_proveedor = vproveedor) THEN
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
												cantidad_7 = cantidad_7 + pcant7,
												cantidad_8 = cantidad_8 + pcant8,
												cantidad_9 = cantidad_9 + pcant9,
												cantidad_10 = cantidad_10 + pcant10,
												saldo_anterior = saldo_total,
												saldo_total =  saldo_total + pmonto
												  
					  WHERE  cod_atm = psucursal;
		 
				   ELSE
					  UPDATE ss_atm set cantidad_1 = cantidad_1 - pcant1, 
										cantidad_2 = cantidad_2 - pcant2,
										cantidad_3 = cantidad_3 - pcant3, 
										cantidad_4 = cantidad_4 - pcant4,
										cantidad_5 = cantidad_5 - pcant5, 
										cantidad_6 = cantidad_6 - pcant6,
												cantidad_7 = cantidad_7 - pcant7,
												cantidad_8 = cantidad_8 - pcant8,
												cantidad_9 = cantidad_9 - pcant9,
												cantidad_10 = cantidad_10 - pcant10,
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

	RETURN vcodret,vfolio;
	END;
END PROCEDURE;