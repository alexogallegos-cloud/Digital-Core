create procedure "informix".conscteing(pempresa char(3),
                           pnumcte char(20),
                           pnum_direc smallint)
       returning char(5),smallint,char(1),char(60),char(3),char(2),
                        decimal(4,2),char(40),char(60),money(14,2) ;

---Modifico: Marcos Cuevas
---Fecha 2009-02-13
---Descripcion: Se agrego validacion por tipo ingreso	

define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;

define vsec_ingreso smallint;
define vtipo_ingreso char(1);
define vnombre_empresa char(60);
define vpuesto char(3);
define vpuesto_esp char(2);
define vantiguedad decimal(4,2);
define vnombre_depto char(40);
define vjefe_inmediato char(60);
define vingreso_mensual money(14,2);

let vciclo = 0;
let vcodret = "000";
let  vsqlerr = 0;

let vsec_ingreso = 0;
let vtipo_ingreso = "";
let vnombre_empresa = "";
let vpuesto = "";
let vpuesto_esp = "";
let vantiguedad = 0;
let vnombre_depto = "";
let vjefe_inmediato = "";
let vingreso_mensual = 0;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vsec_ingreso,vtipo_ingreso,vnombre_empresa,vpuesto,vpuesto_esp,
                      vantiguedad,vnombre_depto,vjefe_inmediato,vingreso_mensual;
      end if;
   end exception;
SET LOCK MODE TO WAIT 3;
SET ISOLATION  TO DIRTY READ;


   foreach
      SELECT  sec_ingreso,tipo_ingreso,nombre_empresa,puesto,puesto_esp,
                       nvl(antiguedad,0),nombre_depto,jefe_inmediato,nvl(ingreso_mensual,0)
         INTO     vsec_ingreso,vtipo_ingreso,vnombre_empresa,vpuesto,vpuesto_esp,
                       vantiguedad,vnombre_depto,vjefe_inmediato,vingreso_mensual
         FROM "informix".si_ingresos
         WHERE numcte = pnumcte
		 AND tipo_ingreso = 'T'
         ORDER BY sec_ingreso
		 
      let vciclo = vciclo+1;
      if vciclo <= pnum_direc then
         continue foreach;
      end if
      return    vcodret,vsec_ingreso,vtipo_ingreso,vnombre_empresa,vpuesto,vpuesto_esp,
                      vantiguedad,vnombre_depto,vjefe_inmediato,vingreso_mensual  with resume;
   end foreach;
end
end procedure
DOCUMENT
"Consulta de ingresos del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Daniel Zambada",
"FECHA : 30/octubre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".conscteing_n(
                           pempresa char(3),
                           pnumcte char(20),
                           pnum_direc smallint)

RETURNING
                CHAR(5), -- codigo retorno
                CHAR(3), -- Empresa
                CHAR(20), -- Numero Cliente
                SMALLINT, -- Sec Ingreso
                CHAR(1), -- Tipo Ingreso
                CHAR(60), -- Nombre Empresa
                CHAR(3), -- Puesto
                CHAR(2), -- Puesto Esp
                DECIMAL(4,2), -- Antiguedad
                CHAR(40), -- Nombre Depto
                CHAR(60), -- Jefe Inmediato
                MONEY(14,2), -- Ingreso mensual
                CHAR(8), -- User insert
                DATE, -- Fecha insert
                INTEGER, -- Clave puesto
                INTEGER, -- Clave opcion puesto
                INTEGER, -- Clave sub opcion puesto
                INTEGER, -- Sis cotiza
                INTEGER, -- Num emp lab
                INTEGER, -- Periosidad
                INTEGER; -- Tipo ingreso ext

-- Declaracion de variables
DEFINE vcodret char(5);
DEFINE vciclo smallint;
DEFINE vsqlerr integer;

-- Variables de la si_ingresos
DEFINE vempresa	CHAR(3);
DEFINE vnumcte CHAR(20);
DEFINE vsec_ingreso SMALLINT;
DEFINE vtipo_ingreso CHAR(1);
DEFINE vnombre_empresa CHAR(60);
DEFINE vpuesto CHAR(3);
DEFINE vpuesto_esp CHAR(2);
DEFINE vantiguedad DECIMAL(4,2);
DEFINE vnombre_depto CHAR(40);
DEFINE vjefe_inmediato CHAR(60);
DEFINE vingreso_mensual MONEY(14,2);
DEFINE vuser_insert CHAR(8);
DEFINE vfecha_insert DATE;
DEFINE vclavepuesto INTEGER;
DEFINE vclaveopcionpuesto INTEGER;
DEFINE vclavesubopcionpuesto INTEGER;
DEFINE vsis_cotiza INTEGER;
DEFINE vnum_emp_lab INTEGER;
DEFINE vperiosidad INTEGER;
DEFINE vtipo_ingreso_ext INTEGER;

--Inicializacion de variables
LET vciclo = 0;
LET vcodret = "000";
LET  vsqlerr = 0;

LET vempresa = "";
LET vnumcte = "";
LET vsec_ingreso = 0;
LET vtipo_ingreso = "";
LET vnombre_empresa = "";
LET vpuesto = "";
LET vpuesto_esp = "";
LET vantiguedad = 0;
LET vnombre_depto = "";
LET vjefe_inmediato = "";
LET vingreso_mensual = 0;
LET vuser_insert = "";
LET vfecha_insert  = "";
LET vclavepuesto = 0;
LET vclaveopcionpuesto = 0;
LET vclavesubopcionpuesto = 0;
LET vsis_cotiza = 0;
LET vnum_emp_lab = 0;
LET vperiosidad = 0;
LET vtipo_ingreso_ext = 0;

   -- SET DEBUG FILE TO "/respaldosbd/Daniela/conscteing.out";
  --  TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr
          IF vsqlerr <> 0 THEN
                 let vcodret = vsqlerr;
                 RETURN vcodret, vempresa, vnumcte, vsec_ingreso, vtipo_ingreso, vnombre_empresa, vpuesto, vpuesto_esp, vantiguedad, vnombre_depto,
                                 vjefe_inmediato, vingreso_mensual, vuser_insert, vfecha_insert, vclavepuesto, vclaveopcionpuesto, vclavesubopcionpuesto, 
                                 vsis_cotiza, vnum_emp_lab, vperiosidad, vtipo_ingreso_ext;
          END IF;
    END EXCEPTION;

SET ISOLATION  TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    FOREACH
          SELECT  empresa, numcte, NVL(sec_ingreso,0), NVL(tipo_ingreso,''), NVL(nombre_empresa,''), NVL(puesto,''), NVL(puesto_esp,''), NVL(antiguedad,0), NVL(nombre_depto,''), NVL(jefe_inmediato,''),
                           NVL(ingreso_mensual,0), NVL(user_insert,''), NVL(fecha_insert,'01-01-1900'), NVL(clavepuesto,0), NVL(claveopcionpuesto,0), NVL(clavesubopcionpuesto,0), NVL(sis_cotiza,0), NVL(num_emp_lab,0),
                           NVL(periosidad,0), NVL(tipo_ingreso_ext,0)
                INTO  vempresa, vnumcte, vsec_ingreso, vtipo_ingreso, vnombre_empresa, vpuesto, vpuesto_esp, vantiguedad, vnombre_depto,
                           vjefe_inmediato, vingreso_mensual, vuser_insert, vfecha_insert, vclavepuesto, vclaveopcionpuesto, vclavesubopcionpuesto, 
                           vsis_cotiza, vnum_emp_lab, vperiosidad, vtipo_ingreso_ext
              FROM  bdinteg:"informix".si_ingresos
            WHERE numcte = pnumcte
                  AND tipo_ingreso = 'T'
       ORDER BY sec_ingreso
	 
        LET vciclo = vciclo+1;
        IF vciclo <= pnum_direc THEN
            CONTINUE foreach;
        END IF;

        RETURN vcodret, vempresa, vnumcte, vsec_ingreso, vtipo_ingreso, vnombre_empresa, vpuesto, vpuesto_esp, vantiguedad, vnombre_depto,
                        vjefe_inmediato, vingreso_mensual, vuser_insert, vfecha_insert, vclavepuesto, vclaveopcionpuesto, vclavesubopcionpuesto, 
                        vsis_cotiza, vnum_emp_lab, vperiosidad, vtipo_ingreso_ext with resume;

    END FOREACH;
END
END PROCEDURE

DOCUMENT
"Consulta de ingresos del cliente",
"Autor : Daniela Ramirez",
"Fecha 11/07/2011";

CREATE PROCEDURE "informix".sp_guardabitacorahuellas(p_sSucursal CHAR(4), p_sNumCte CHAR(20), p_sNumTran CHAR(4), p_bValida_Nip BOOLEAN, p_sEstatus_Val_Nip CHAR(2), p_sUser_Insert CHAR(8), p_Fecha DATE)

RETURNING 	VARCHAR(6) --Codigo de Retorno

DEFINE CodRet			  VARCHAR(6);
DEFINE iSqlErr, iIsamErr  INTEGER;
DEFINE cInfoErr 		  CHAR(200);

LET CodRet = '000000';


	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
			INSERT INTO bdinteg: "informix".si_mensajeerror (sql_error, isam_error, descripcion, origen_error) 
			VALUES (iSqlErr, iIsamErr, cInfoErr, 'sp_guardabitacorahuellas');							  
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

		--- SET DEBUG FILE TO "/respaldosbd/Bruno/286/SP_GUARDABITACORAHUELLAS:out;
    	--- TRACE ON;

    	  SET ISOLATION TO DIRTY READ;
   		  SET LOCK MODE TO WAIT 3;
		
		INSERT INTO bdinteg: "informix".si_bitacora_autenticacion_huella VALUES (p_sSucursal, p_sNumCte, p_sNumTran, p_bValida_Nip, p_sEstatus_Val_Nip, p_sUser_Insert, p_Fecha, current);

		RETURN CodRet;
	END
END PROCEDURE;