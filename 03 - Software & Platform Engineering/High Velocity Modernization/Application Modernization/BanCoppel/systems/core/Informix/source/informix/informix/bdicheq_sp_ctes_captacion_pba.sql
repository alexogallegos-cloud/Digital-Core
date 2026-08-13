CREATE PROCEDURE "informix".sp_ctes_captacion_pba()
RETURNING CHAR(5);
    
    DEFINE vcodret          CHAR(5);
    DEFINE vsqlerr          INTEGER;  
    DEFINE vsql             CHAR(600);
	DEFINE vfecha      		DATE; 
	DEFINE vdia         	CHAR(2);
	DEFINE vmesanio         CHAR(6);
	DEFINE vaniomes        CHAR(6);
	DEFINE Pempresa         CHAR(3);

	DEFINE vnumcte 		CHAR(20);
	DEFINE vcuenta 		CHAR(20);
	DEFINE vcuenta1 	CHAR(20);
	DEFINE vsucursal	CHAR(4);
	DEFINE vproducto	CHAR(4);
	DEFINE vprimermov	DATE;
	DEFINE vultimomov	DATE;
	DEFINE vplazo		smallint;
	DEFINE valtacta 	DATE;
	DEFINE vfechaaniv 	DATE;
	DEFINE valtacte 	DATE;
	DEFINE vsdodisp		money;
	DEFINE vsdoprom		money;
	DEFINE vciudad		CHAR(15);
	DEFINE vsexo		CHAR(1);
	DEFINE vedocivil	CHAR(2);
	DEFINE vocupacion 	CHAR(30);
	DEFINE vtasa	 	DECIMAL (11,6);
	DEFINE vstatus 		CHAR(1);
	DEFINE vsdoactual   money;
	
	DEFINE ven_transacc     CHAR(1);
    DEFINE vcontador        INTEGER;
	DEFINE vcomienza        SMALLINT;
	
	
    LET vcodret     = "00000";
    LET vsqlerr     = 0;
    LET vsql        = "";
	LET vfecha		= DATE(1);
    LET vdia  		= "";
	LET vmesanio    = "";
	LET vaniomes    = "";
    LET pempresa    = '001';
	
	LET vnumcte		= "";
	LET vcuenta 	= "";
	LET vcuenta1 	= "";
	LET vsucursal 	= "";
	LET vproducto 	= "";
	LET vprimermov	= DATE(1);
	LET vultimomov	= DATE(1);
	LET	vciudad		= "";
	LET	vocupacion 	= "";
	LET vedocivil	= "";	
	LET	vsexo		= "";
	LET vplazo		= 0;
	LET	valtacte	= DATE(1);
	LET	vfechaaniv	= DATE(1);
	LET	valtacta	= DATE(1);
	LET vsdoprom	= '0.00';
	LET vsdodisp	= '0.00'; 
	LET vtasa 		= 0;
	LET vstatus		= "";
	LET vsdoactual 	= '0.00'; 
		
    LET ven_transacc = '0';
    LET vcontador    = 0;
    LET vcomienza    = -1;
	
	
	
	SET DEBUG FILE TO "sp_ctes_captac_cut_pba.out";
	TRACE ON; 
	

    BEGIN

    ON EXCEPTION SET vsqlerr
       IF vsqlerr <> 0 THEN
	      LET vcodret = vsqlerr;
          RETURN vcodret;
          IF ven_transacc = '1' THEN
             ROLLBACK WORK;
          END IF;
       END IF;
    END EXCEPTION;
	
	   
	SET ISOLATION TO DIRTY READ;
	
	IF EXISTS (SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum BETWEEN (SELECT MIN(partnum) FROM sysmaster:systabnames) AND
                                      (SELECT MAX(partnum) FROM sysmaster:systabnames)
                  AND tabname = 'extriecap') THEN
		DROP TABLE bdicheq:"informix".extriecap;
	
	END IF	
	
	
		
CREATE TABLE bdicheq:"informix".extriecap ( 
	numcte         char(20),
	cuenta       	char(20),
	sucursal        char(4),
	plazo  		   	smallint,
	producto    	char(4),
	tasa			decimal(11,6),
	ocupacion		char(30),
	edo_civil		char(2),
	sexo			char(1),
	ciudad			char(15),
	sdoprom			money,
	sdodisp    		money,
	fechaaniv     	date,
	fechaltacte    	date,
	primermov     	date,
	ultimomov     	date,
	fech_alt     	date
	);
	
	CREATE INDEX informix.idx_extriecap
    ON informix.extriecap(numcte,cuenta);
	
	
	select to_char(pri_dia_mes - 1 units day,'%m/%d/%Y')
	into vfecha
	from bdicheq:sc_fechas
	where  empresa = pempresa;
	
	
	FOREACH WITH HOLD
		-- NUMERO DE CLIENTE, CUENTA, SUCURSAL, PRODUCTO, PRIMER MOVIMIENTO Y ULTIMO MOVIMIENTO STATUS Y SDO ACTUAL SE USAN PARA VALIDACIONES
		select  {+INDEX(bdicheq:sc_maechq ix174_1)}
		num_cte,cuenta,sucursal,producto,fecultdep,fecultret, status_cta, sdo_actual 
		into vnumcte,vcuenta,vsucursal,vproducto,vprimermov,vultimomov,vstatus, vsdoactual
		from bdicheq:sc_maechq
		where empresa = "001"
		
		
        IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET ven_transacc = '1';
        END IF;
			
			--toma la fecha de alta de cliente
			select fecha_alta
			into valtacte
			from bdinteg:si_cliente 
			where numcte = vnumcte;
			
			--Solo aplica para Pagaré
			LET vplazo		= 0;
			
			--se toma ocupacion, estado civil y sexo del cliente
			select  b.descripcion,a.estado_civil,a.sexo
			into vocupacion, vedocivil, vsexo
			from bdinteg:si_ctepf a, bdinteg:si_profesion b
			where a.numcte = vnumcte
			and a.profesion= b.profesion;
			
			-- SALDO PROMEDIO, FECHA DE ALTA DE CUENTA Y FECHA DE ANIVERSARIO PARA INVERSION CRECIENTE
			select sdo_prom_mesant,fecha_alta,fecha_mod   
			into vsdoprom, valtacta, vfechaaniv
			from bdicheq:sc_maenoc 
			where cuenta = vcuenta;
			
			-- NO ES INVERSION CRECIENTE
			IF vproducto <> '1100' THEN
			--CALL bdicred:'informix'.monthadd(valtacta,1) RETURNING vfechaaniv; 
			LET	vfechaaniv	= DATE(1);
			END IF
			
				
			--NOMBRE DE CIUDAD
			select e.nombreciudad 
			into vciudad
			from bdinteg:si_direcciones_actual d, bdinteg:si_catciudades e 
			where  d.numcte = vnumcte
			and    d.tipo_dir = "1"
			and    e.numerociudad = d.numerociudad;
			
			
			-- TASA BRUTA
			LET vaniomes = SUBSTR(vfecha,7,4) || SUBSTR(vfecha,1,2);
			LET vaniomes = vaniomes;
						
			select tasabruta, cuenta
			into vtasa, vcuenta1
			from bdicheq:sc_maehis 
			where cuenta = vcuenta
			and aniomes = vaniomes;
			
			IF vcuenta1 is null THEN
			
			CONTINUE FOREACH;
			
			END IF
			
			
			
			IF vstatus IN ('4','5','6') AND vsdoactual <= '200' THEN
			
			LET vtasa = 0;
			
			END IF
			
			LET vcuenta1 = "";
			-- SALDO DISPONIBLE
			LET vdia = SUBSTR(vfecha,4,2);
			LET vdia = vdia;
			
			IF LPAD(vdia,2,'0') = '31' THEN
						
			SELECT capvig31 ,cuenta
			INTO vsdodisp, vcuenta1
			FROM bdicheq:sc_sdodiarioc
			where cuenta = vcuenta 
			and aniomes = vaniomes;
								
			ELIF LPAD(vdia,2,'0') = '30' THEN
						
			SELECT capvig30 ,cuenta
			INTO vsdodisp,vcuenta1
			FROM bdicheq:sc_sdodiarioc
			where cuenta = vcuenta 
			and aniomes = vaniomes;
			
			ELIF LPAD(vdia,2,'0') = '29' THEN
			
			SELECT capvig29 ,cuenta
			INTO vsdodisp,vcuenta1
			FROM bdicheq:sc_sdodiarioc
			where cuenta = vcuenta 
			and aniomes = vaniomes;
			
			ELIF LPAD(vdia,2,'0') = '28' THEN
			
			SELECT capvig28 ,cuenta
			INTO vsdodisp,vcuenta1
			FROM bdicheq:sc_sdodiarioc
			where cuenta = vcuenta 
			and aniomes = vaniomes;
			
			END IF
			
			IF vcuenta1 is null THEN
			
			CONTINUE FOREACH;
			
			END IF
			
		
		
		insert into bdicheq:"informix".extriecap values (vnumcte, vcuenta, vsucursal, nvl (vplazo,0), vproducto, nvl(vtasa, 0), nvl (vocupacion, ""), nvl (vedocivil, ""),
		nvl (vsexo, ""), nvl (vciudad, ""), nvl (vsdoprom,"0.00"), nvl (vsdodisp,"0.00"), nvl (vfechaaniv, date(1)), nvl (valtacte, date(1)), nvl (vprimermov,date(1)),
		nvl (vultimomov,date(1)), nvl (valtacta,date(1)) );	
		
		
        LET vcontador = vcontador + 1;
        
        IF vcontador >= 7500 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vcontador = 0;
        END IF;
			
	END FOREACH
    
    IF ven_transacc = '1' THEN
        COMMIT WORK;
        LET ven_transacc = '0';
    END IF;

		
	-- foreach para pagares
	
	FOREACH WITH HOLD
	
	-- se toma numero de cliente, cuenta, sucursal, plazo, tasa, saldo promedio y fecha de alta
	select num_cte, cuenta, sucursal, plazo, tasa, capital, fecha_alta  
	into vnumcte, vcuenta, vsucursal, vplazo, vtasa, vsdoprom, valtacta
	from bdinvers:sv_maeinv 
	where empresa = pempresa
		
		IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET ven_transacc = '1';
        END IF;
		
	-- se asigna el producto para el pagare
	let vproducto = "3000" ;
	
	--se toma ocupacion, estado civil y sexo del cliente
	select  b.descripcion,a.estado_civil,a.sexo
	into vocupacion, vedocivil, vsexo
	from bdinteg:si_ctepf a, bdinteg:si_profesion b
	where a.numcte = vnumcte
	and a.profesion= b.profesion;
	
	
	--NOMBRE DE CIUDAD
			select e.nombreciudad 
			into vciudad
			from bdinteg:si_direcciones_actual d, bdinteg:si_catciudades e 
			where  d.numcte = vnumcte
			and    d.tipo_dir = "1"
			and    e.numerociudad = d.numerociudad;
			
	--EL SALDO DISPONIBLE Y FECHA DE ANIVERSARIO NO APLICAN PARA PAGARE
	LET vsdodisp	= '0.00'; 
	LET	vfechaaniv	= DATE(1);
	
	--toma la fecha de alta de cliente
			select fecha_alta
			into valtacte
			from bdinteg:si_cliente 
			where numcte = vnumcte;
	-- FECHA DEL PRIMER Y ULTIMO MOVIMIENTO NO APLICA PARA PAGARE
	LET vprimermov	= DATE(1);
	LET vultimomov	= DATE(1);
			
		insert into bdicheq:"informix".extriecap values (vnumcte, vcuenta, vsucursal, nvl (vplazo,0), vproducto, nvl(vtasa, 0), nvl (vocupacion, ""), nvl (vedocivil, ""),
		nvl (vsexo, ""), nvl (vciudad, ""), nvl (vsdoprom,"0.00"), nvl (vsdodisp,"0.00"), nvl (vfechaaniv, date(1)), nvl (valtacte, date(1)), nvl (vprimermov,date(1)),
		nvl (vultimomov,date(1)), nvl (valtacta,date(1)) );
		
	     LET vcontador = vcontador + 1;
        
        IF vcontador >= 7500 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vcontador = 0;
        END IF;
			
	END FOREACH
    
    IF ven_transacc = '1' THEN
        COMMIT WORK;
        LET ven_transacc = '0';
    END IF;

	LET vdia = SUBSTR(vfecha,4,2);
	LET vdia = vdia;   
	LET vmesanio =  SUBSTR(vfecha,1,2) || SUBSTR(vfecha,7,4);
	LET vmesanio = vmesanio;

    
    LET vsql = "";

	LET vsql =  ' echo "SET ISOLATION TO DIRTY READ; unload to /resplogifx/conciliachq/extriecap_'||vdia||''||vmesanio||'.unl'||
                ' select * from bdicheq:"informix".extriecap '||
                ';" > /resplogifx/conciliachq/qry_ctescapt.sql';
    SYSTEM vsql;
    
    LET vsql = "";
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/qry_ctescapt.sql";  --produccion
    --LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/qry_ctescapt.sql"; -- desarrollo
    SYSTEM vsql;
    LET vsql = "";

	Drop table bdicheq:"informix".extriecap;
	  
    END;
    
    RETURN vcodret;
	
END PROCEDURE;