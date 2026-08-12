create procedure "informix".sp_rep_cartera_quebrantar_archivo(sfecha date, ctipoarchivo char(1))
returning char (6) as Resultado, char(80) as Mensaje;

--Juan AndrÃÂÃÂ©s Coronel MorÃÂÃÂ¡n

--22-01-2008
--Obtener datos de clientes con tarjeta de credito

--  Paul IvAn Quintero Varela
--  18/02/2008
--  Se modifica para  que una vez obtenida la informacion la descargue en un archivo de salida

--  Paul Ivan Quintero Varela
--  26/02/2008
--  Se agrega ademas los siguientes datos:
--          Se obtiene los Intereses Vigentes
--          Se obtiene el Iva de los Intereses Vigentes
--          Se obtiene el Interes Moratorio Ordinario
--          Se obtiene el Iva de Intereses Moratorio Ordinarios
--          Se obtiene el Interes Moratorio Copete
--          Se obtiene el Iva de Intereses Moratorio Copete


DEFINE cNumCredito, cNumCte char(20);
DEFINE pNum_Vencidos    Smallint;

DEFINE cApellido1,cApellido2,cNombre1,cNombre2 char(20);
DEFINE cRfc                     char(13);
DEFINE cApellidoCasada          char(26);

DEFINE cSector                  char(2);
DEFINE dFechaNac                date;
DEFINE cCurp                    char(20);
DEFINE cSexo                    char(1);
DEFINE cEdoCivil                char(2);
DEFINE cNumIdentificacion       char(30);

DEFINE cEmail                   char(60);
DEFINE cTipoIdentificacion      char(40);
DEFINE cNacionalidad            char(15);

DEFINE cNumEstado,cNumCiudad integer;
DEFINE cPoblacion               char(80);
DEFINE cNumColonia, cNumCalle integer;
DEFINE cNumExterior, cNumInterior char(10);


DEFINE cCodPostal               char(5);
DEFINE cPuntoCardinal           char(1);
DEFINE iManzana, iAndador, iEtapa, iLote, iEdificio, iEntrada  integer;

DEFINE cDepartamento            char(6);
DEFINE cComplemento             char(80);
DEFINE cEntreCalles             char(40);
DEFINE sOtros                   smallint;

DEFINE mIngresoMensual          money(14,2);
DEFINE cPuesto                  char(3);
DEFINE cLugarTrabajo            char(25);
DEFINE cTelefono, cTelTrab, cExtTrab char(13);

DEFINE sElementoRes             smallint;
DEFINE cDescripcion             char(80);
DEFINE sElemResTrabajo          smallint;
DEFINE cDescripPermTrabajo      char(80);

DEFINE cActividad               char(45);

---Domicilio de Trabajo
DEFINE cNumEstadoTrab, cNumCiudadTrab integer;
DEFINE cPoblacionTrab           char(80);
DEFINE cNumColoniaTrab, cNumCalleTrab integer;
DEFINE cNumExteriorTrab, cNumInteriorTrab char(10);

DEFINE cCodPostalTrab           char(5);
DEFINE cPuntoCardinalTrab       char(1);
DEFINE iManzanaTrab, iAndadorTrab, iEtapaTrab, iLoteTrab, iEdificioTrab, iEntradaTrab integer;

DEFINE cDepartamentoTrab        char(6);
DEFINE cComplementoTrab         char(80);
DEFINE cEntreCallesTrab         char(40);
DEFINE iOtrosTrab               smallint;

------- PENDIENTES DE GENERAR
DEFINE cSituacion               char(1);
DEFINE sCausa                   smallint;
DEFINE dFechaMovtoSit           date;
DEFINE cEvaluacionCC            char(1);
DEFINE cExisteCC                char(2);
DEFINE iContadorRegistros       integer;
-----

DEFINE cSucursal                char(4);

DEFINE dFechaUltDisp            date;
DEFINE iMaxSecDisp, iCuantosDisp Integer;
DEFINE fMontoUltDisp            decimal(14,2);
DEFINE cFolioSuc                char(16);
DEFINE fMontoComi, fAbonoMensual, fSaldoMesAnt decimal(14,2);
DEFINE iRef                     Integer;
DEFINE mMonto                   decimal(14,2);
DEFINE dFechaUltCapitalizacion date;
DEFINE mMontoInteresCap, mMontoIvaIntCap, fSaldoMesActual decimal(14,2);
DEFINE cUltMov                  char(4);
DEFINE dFechaUltMov             date;
DEFINE fMontoUltMov, mMontoInteresCapMesAnt, mMontoIvaIntCapMesAnt decimal(14,2);
DEFINE cNumSucursal           char(4);
DEFINE mPorcIva            decimal(14,2);
DEFINE mIntVencido, mIvaIntVencido, mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope decimal(14,2);
define cMesesVencidos           integer;
DEFINE cNumTarjeta              char(20);
DEFINE dFechaUltPago            date;
DEFINE iMaxSecPago, iCuantosPagos integer;
DEFINE fMontoPago               decimal(14,2);
DEFINE cRefCoppel               char(20);

DEFINE dFechaHoy                date;
DEFINE dFechaCapAux             date;
DEFINE iContador                smallint;
DEFINE cBegin                   char(1);
define vfechamax              date;


    DEFINE SQL_ERR            INTEGER;
    DEFINE ISAM_ERR           INTEGER;
    DEFINE ERROR_INFO         VARCHAR(80);
    DEFINE P_COD_RET          VARCHAR(6);
    DEFINE P_MENSAJE          VARCHAR(80);

DEFINE cSql                   CHAR(2024);
DEFINE cNombreArchivo1	      CHAR(70);
DEFINE cNombreArchivo2	      CHAR(70);
DEFINE  cRuta				  CHAR(100);

-- jom ini
define cNumRegTotal           integer;
define sSaldoActTotal         decimal(14,2);
define sFechadeCorte          date;
define fSaldoMesVencido       decimal(14,2);
define fSaldoMesNoExig        decimal(14,2);
define mIvaIntMoraPagado      decimal(14,2);
define mIvaIntMoraTotal       decimal(14,2);
-- jom fin
define var_rga                char(05);

--Envio de SMS & Correo
DEFINE cNom_Cte               char(150);
DEFINE cNom_Producto          char(100);
DEFINE cNum_Tarjeta            char(20);
DEFINE dFechaRegistro         date;
DEFINE pNumCel                char(13);
DEFINE COD_RET				  char(05);
DEFINE cCorreo				  char(100);

   

--Asignanado valor a la variable mensaje cuando, este sea exitoso
LET P_MENSAJE = 'Proceso Exitoso. Archivo generado correctamente';   

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
--        drop table temp_cb_rep_cart_quebrantar;
        If cBegin = 'S' then
            RollBack Work;
        End if;
        RETURN P_COD_RET, P_MENSAJE;
    END EXCEPTION;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 4;

  -- SET DEBUG FILE TO "/informix/Joel/Envio_SMS/Prueba_JOel.out";
  -- trace on;
  --Set debug file to '/ifxsif01/PEDRO/rep_cart_quebrantar/sp_rep_cartera_quebrantar_archivo.out';
  --trace on;
   

Let cBegin = 'N';
let vfechamax = null;

--jom ini
let cNumRegTotal    = 0;
let sSaldoActTotal  = 0;
--jom fin

--Seleccionamos la ruta de donde se depositarÃÂÃÂ¡n los archivos generados
	SELECT TRIM(valor_alfabetico) INTO cRuta 
	FROM bdicobranza:"informix".cb_param_campania WHERE empresa = '001' and tipo_campania = 50 and grupo_parametro = 'CAT_PROMOS'
	and num_parametro = 2;
	

	--let cRuta = '/ifxsif01/PEDRO/rep_cart_quebrantar/';----PRUEBA	

LET  cSql="";
LET  pNum_Vencidos=0;
LET  cNumSucursal = '0000';
LET  mPorcIva= 0;
LET  mIntVencido= 0;
LET  mIvaIntVencido= 0;
LET  mIntMoraOrdi= 0;
LET  mIvaIntMoraOrdi= 0;
LET  mIntMoraCope= 0;
LET  mIvaIntMoraCope= 0;
let  fSaldoMesVencido=0;


    Let P_cod_ret  = "00000";
    Let iContador  = 0;
    Let cSituacion = '';
    let sCausa     = 0;
	let dFechaHoy = DATE(1);

    Select max(fechareporte)
    Into dFechaHoy
    From bdicobranza:cb_rep_cart_quebrantar;
    
	--Let dFechaHoy = mdy('02','04','2022');
    Let cBegin = 'N';
	
	--Excepcion por si el parametro de entrada Tipo Archivo es diferente de P o D
	IF TRIM(ctipoarchivo) not in ('P','D') OR ctipoarchivo IS NULL THEN
        LET P_COD_RET    = '000001';
        LET P_MENSAJE   = 'El parÃÂÃÂ¡metro tipo archivo no es correcto. Utilice "P" o "D"';
        RETURN P_COD_RET, P_MENSAJE;
    END IF;	 
	
	--Comparando Fecha_hoy con fechareporte
	IF sfecha > dFechaHoy THEN
        LET sfecha = dFechaHoy;
    END IF;	 

	LET  cNombreArchivo1= TRIM(cRuta)||'CarteraQuebrantada' || LPAD(TRIM(MONTH(dFechaHoy)::CHAR(2)),2,'0') ||YEAR(dFechaHoy) || '.txt';
	LET  cNombreArchivo2= TRIM(cRuta)||'CifrasCarteraQuebrantada' || LPAD(TRIM(MONTH(dFechaHoy)::CHAR(2)),2,'0') ||YEAR(dFechaHoy) || '.txt';

--    insert into bdicobranza:cb_rep_cart_quebrantar_cifras values (cNumRegTotal,sSaldoActTotal,current);

--    If iContador > 0 then
--        Begin Work;
--    Insert into bdicobranza:cb_rep_cart_quebrantar
--    Select * From Temp_cb_rep_cart_quebrantar;
--        Commit Work;
--    End if;

-- para Generar el archivo de Salida de Cartera Quebrantada.

              let cSql = "";
              let cSql = ' UNLOAD TO ' || TRIM(cRuta)|| '''CarteraQuebrantadaRegistros.unl''' || ' DELIMITER ' || '''"|"''';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  ' SELECT ' ;
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Num_Credito,' || '''" "''' || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCte,' || '''" "''' || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a. Apellido1,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Apellido2,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Nombre1,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Nombre2,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.FechaNac,date"("1")"")", ' ;
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Rfc,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Curp,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sexo,' || '''" "''' || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.EdoCivil,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ApellidoCasada,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Nacionalidad,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Actividad,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.TipoIdentificacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumIdentificacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Email,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumEstado,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCiudad,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Poblacion,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumColonia,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCalle,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumExterior,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumInterior,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.CodPostal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.PuntoCardinal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Manzana,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Andador,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Etapa,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Lote,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Edificio,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Entrada,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Departamento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Complemento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.EntreCalles,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.AntigDomic,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Telefono,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Otros,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.SituacionEsp,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.CausaSitEsp,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Sector,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.LugarTrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.AntigTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Puesto,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.IngresoMensual,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumEstadoTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCiudadTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.PoblacionTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumColoniaTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.NumCalleTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumExteriorTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.NumInteriorTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.CodPostalTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.PuntoCardinalTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.ManzanaTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.AndadorTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.EtapaTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.LoteTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.EdificioTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.EntradaTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.DepartamentoTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ComplementoTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.EntreCallesTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.OtrosTrab,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.TelTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ExtTrab,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.sucursal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Fecha_Ult_Disp,date"("1")"")", ' ;
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Monto_Ult_Disp,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Monto_Comi_Ult_Disp,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Abono_Mensual_Al_Qub,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Capit,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Capit,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sdo_Mes_Ant,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sdo_Actual,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Sdo_Vencido,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Fecha_Ult_Mov,date"("1")"")", ' ;
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Tipo_Ult_Mov,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Monto_Ult_Mov,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Vencido,0")" '||'''+'''||' nvl"("a.Int_Vencido_bal,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Vencido,0")" '||'''+'''||' nvl"("a.Iva_Int_Vencido_bal,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Mora_Ordi,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Mora_Ordi,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Int_Mora_Cope,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.Iva_Int_Mora_Cope,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.meses_vencidos,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.dias_vencido,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.atr,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("a.act,0")", ';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("to_char"("a.fecha_vencido,''"''' || '%d/%m/%Y' || '''"''")",date"("1")"")", ' ;  
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.Numero_Tarjeta,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")",';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =  '  nvl"("replace"("replace"("a.ReferenciaCoppel,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '"),"';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
			  let cSql =  '  nvl"("replace"("replace"("a.Producto,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")"';
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
              let cSql =' FROM bdicobranza:cb_rep_cart_quebrantar a where a.fechareporte = ''"'''  || sfecha || '''"''' ;
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
			  let cSql =  ' and nvl"("a.excluido,' || '''""''' || '")" '||'''='''||'''""'''||''';''' ;
              call sp_genera_archivo (TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql',cSql) returning var_rga;
			  
			   

              LET cSql = '';
              LET cSql = 'dbaccess bdicred '|| TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql';
              SYSTEM cSql;

              LET cSql = "sed 's/|$//g' "|| TRIM(cRuta)||"CarteraQuebrantadaRegistros.unl > " || cNombreArchivo1;
              SYSTEM cSql;

              LET cSql = '';

            -- cifras de control
            LET cSql = 'echo "UNLOAD TO ' || TRIM(cRuta)||'CarteraQuebrantadaCifras.unl' || ' DELIMITER ' || '''|'''  ||
                                ' SELECT ' ||
                                'count(*) ::INTEGER, ' ||
                                'sum(a.sdo_actual), ' ||
                                'a.fechareporte' ||
                                ' FROM bdicobranza:cb_rep_cart_quebrantar a where a.fechareporte = ''"''' || sfecha || '''"''' ||
								' and nvl(excluido,'''') ='''' '||
								' group by a.fechareporte'||
                                ' " > '|| TRIM(cRuta)||'CarteraQuebrantadaQuerysCifras.sql';
								
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred '|| TRIM(cRuta)||'CarteraQuebrantadaQuerysCifras.sql';
              SYSTEM cSql;

              LET cSql = "sed 's/|$//g' "|| TRIM(cRuta)||"CarteraQuebrantadaCifras.unl > " || cNombreArchivo2;
              SYSTEM cSql;

              LET cSql = '';

              LET cSQL = 'rm '|| TRIM(cRuta)||'CarteraQuebrantadaRegistros.unl ' || TRIM(cRuta)||'CarteraQuebrantadaQuerysCifras.sql ' || TRIM(cRuta)||'CarteraQuebrantadaQuerys.sql ' || TRIM(cRuta)||'CarteraQuebrantadaCifras.unl';
              SYSTEM cSql;
              LET cSql = '';

--			  LET cSql = "scp " || trim(cNombreArchivo1) || " sysbancartera@10.36.193.35:/sysx/progs/archivoscartera";
--              SYSTEM cSql;
              LET cNombreArchivo1 = "";

              LET cSql = '';
--			  LET cSql = "scp " || trim(cNombreArchivo2) || " sysbancartera@10.36.193.35:/sysx/progs/archivoscartera";
--              SYSTEM cSql;
              LET cNombreArchivo2 = "";

    Let P_COD_RET = '000000';
    LET cSql = '';

	--Se insertan valores a la tabla bdimnsj:mnsjr_trx_batch para mandar el aviso de cancelacion del credito al usuario 
	
	---SMS ----
			LET cNom_Cte = '';
			LET cNom_Producto = '';
			LET cNum_Tarjeta = '';
			LET dFechaRegistro = dFechaHoy;
			LET pNumCel = 0;
			LET COD_RET = '';
			  
					  
			Select TRIM(NVL(a.nombre1,'')) ||' '||
					TRIM(NVL(a.nombre2,'')) ||' '||
					TRIM(NVL(a.apellido1,'')) ||' '||
					TRIM(NVL(a.apellido2,'')) AS nombre_cte
			,d.nombre_prod
			,SUBSTR(t.num_tarjeta,13,4) num_tarjeta
			,tel.telefono
			From bdicobranza:cb_rep_cart_quebrantar a
			INNER JOIN bdicred:sd_definicion as d ON d.num_producto = a.producto
			INNER JOIN bdicred:sd_tarjeta as t ON t.numcte = a.numcte
			INNER JOIN bdinteg:si_telefonos_actual tel ON tel.numcte = a.numcte
			INNER JOIN bdicred:sd_fechas as f on f.empresa = t.empresa
			where t.status_tar != 'C'
			and movil_fijo = 0 AND tipo_tel = 2  
			AND cofetel = 'V'   AND status_tel = 'A'
			AND a.fechareporte = sfecha and nvl(a.excluido,'') =''
			Group by nombre_cte,d.nombre_prod,t.num_tarjeta,tel.telefono
			into temp smsavisocancelacion with no log;
			
			FOREACH WITH HOLD
			---------- SMS
			
			SELECT nombre_cte,nombre_prod,num_tarjeta,telefono
			INTO cNom_Cte,cNom_Producto,cNumTarjeta,pNumCel
			FROM bdicred:"informix".smsavisocancelacion
			
			BEGIN WORK; 
			
			CALL bdimnsj:"informix".sp_registra_evento(1,'PROD_SMS','CANTJ_SMS','000000000','', '',2, cNom_Cte, cNom_Producto, cNumTarjeta, ''
														, '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, dFechaRegistro, '')RETURNING COD_RET;
			
			COMMIT WORK;
			
			END FOREACH;
			
			DROP TABLE bdicred:"informix".smsavisocancelacion;
			
			--- CORREO ---
			LET cNom_Cte = '';
			LET cNom_Producto = '';
			LET cNum_Tarjeta = '';
			LET dFechaRegistro = dFechaHoy;
			LET cCorreo = 0;
			LET COD_RET = '';
			
			
			Select TRIM(NVL(a.nombre1,'')) ||' '||
					TRIM(NVL(a.nombre2,'')) ||' '||
					TRIM(NVL(a.apellido1,'')) ||' '||
					TRIM(NVL(a.apellido2,'')) AS nombre_cte
			,d.nombre_prod
			,SUBSTR(t.num_tarjeta,13,4) num_tarjeta
			,sc.correo_elec
			From bdicobranza:cb_rep_cart_quebrantar a
			INNER JOIN bdicred:sd_definicion as d ON d.num_producto = a.producto
			INNER JOIN bdicred:sd_tarjeta as t ON t.numcte = a.numcte
			INNER JOIN bdinteg:si_correos as sc ON sc.numcte = a.numcte
			INNER JOIN bdicred:sd_fechas as f on f.empresa = t.empresa
			where sc.status_correo = 'A' AND a.fechareporte = sfecha and nvl(a.excluido,'') =''
			Group by nombre_cte,d.nombre_prod,t.num_tarjeta,sc.correo_elec
			into temp correoavisocancelacion with no log;
			
			FOREACH WITH HOLD
			---------- CORREO
			
			SELECT nombre_cte,nombre_prod,num_tarjeta,correo_elec
			INTO cNom_Cte,cNom_Producto,cNumTarjeta,cCorreo
			FROM bdicred:"informix".correoavisocancelacion
			
			BEGIN WORK; 
			
			CALL bdimnsj:"informix".sp_registra_evento(2,'PROD_EMAIL','CANTJ_EMAIL','000000000','', '',2, cNom_Cte, cNom_Producto, cNumTarjeta
														, '', '', '', '', '', '', '', cCorreo,'', 0, 0,0, 0, 0, dFechaRegistro, '')RETURNING COD_RET;
			
			COMMIT WORK;
			
			END FOREACH;
			
			DROP TABLE bdicred:"informix".correoavisocancelacion;
	---Actualizando tabla de parÃÂÃÂ¡metros cuando tipo archivo sea D con valor igual a 1 para que de esta forma impida desbloquear creditos nuevamente para la misma fecha
	IF  ctipoarchivo = 'D'  then 
						UPDATE bdicred:sd_param
							SET valor = '1' 
							WHERE cod_param = '108';
							
						
	END IF;	

    RETURN P_COD_RET, P_MENSAJE;

end;
end procedure
DOCUMENT
'Version: 20130416.1040',
'ModificaciÃÂÃÂ³n : Se ModificÃÂÃÂ³ SP para ponerle un filtro para quitar aquellos creditos que tengan valor en el campo de exclusiÃÂÃÂ³n a la hora de generar el archivo; ademas de sumar los campos en el archivo int_vencido + int_vencido_bal e iva_in_vencido + iva_int_vencido_bal',
'AUTOR : Marco Antonio Valenzuela LeÃÂÃÂ³n',
'FECHA : 16 Abril 2013',
'BD    : bdicred',
'Version: 20130507.1200',
'ModificaciÃÂÃÂ³n : Se ModificÃÂÃÂ³ SP cambiar la ruta donde se generarÃÂÃÂ¡n los archivos para que se guarde en /resplogifx/archivoscartera/ en lugar de /INFORMIXDUMP/',
'AUTOR : Marco Antonio Valenzuela LeÃÂÃÂ³n',
'FECHA : 07 Mayo 2013',
'BD    : bdicred',
'Version: 20131226.2034',
'ModificaciÃÂÃÂ³n : Se ModificÃÂÃÂ³ SP para igualar la fecha del parÃÂÃÂ¡metro de entrada cuando esta sea mayor a la fechareporte de la cb_rep_cart_quebrantar',
'AUTOR : Marco Antonio Valenzuela LeÃÂÃÂ³n',
'FECHA : 12 Dic 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_reporte_saldosinmateriales(pEmpresa CHAR(3) )

RETURNING CHAR(5),     -- Codigo de Retorno
          CHAR(80);   -- Mensaje de retorno
		    

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);

DEFINE iDiasVencido	    INTEGER;
DEFINE iMontoVencido	INTEGER;
DEFINE cNumcte 			CHAR(20);
DEFINE cNumCred 		CHAR(20);
DEFINE cRuta 			CHAR(80);
DEFINE cNum_producto	CHAR(4);
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
DEFINE cBCCodret		CHAR(6);   
DEFINE CBCMensajeRet	CHAR(80); 
-----

DEFINE cNomCte     	CHAR(150);
define wdiacorte        SMALLINT;
define iBandera         INT8;
define wFechamesiver, wFechafactura DATE;
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
DEFINE cCsg_codigo_ret			CHAR(6);
DEFINE cCsg_mensaje_ret			CHAR(80);
DEFINE cCsg_num_credito			CHAR(20);
DEFINE cCsg_cod_tipcred			CHAR(2);
DEFINE cStatus					CHAR(2);
DEFINE dtCsg_fec_origen			DATE;
DEFINE dtCsg_fec_prox_pago		DATE;
DEFINE mCsg_pago_min			MONEY(18,2);
DEFINE dtCsg_fec_ult_pago		DATE;
DEFINE iCsg_plazo				INTEGER;
DEFINE iCsg_pagos_realizados	INTEGER;
DEFINE mCsg_linea_otorgada		MONEY(18,2);
DEFINE mCsg_tasa_interes			DECIMAL(9,6);
DEFINE dCsg_tasa_moratorios		DECIMAL(9,6);
DEFINE dCsg_monto_sbc			DECIMAL(14,2);
DEFINE mCsg_cap_vig				MONEY(18,2);
DEFINE mCsg_cap_trans			MONEY(18,2);
DEFINE mCsg_cap_vdo_exig		MONEY(18,2);
DEFINE mCsg_cap_vdo_no_exig		MONEY(18,2);
DEFINE mCsg_sdo_act_total_cap	MONEY(18,2);
DEFINE mCsg_int_vig				MONEY(18,2);
DEFINE mCsg_int_vdo				MONEY(18,2);
DEFINE mCsg_int_moratorios		MONEY(18,2);
DEFINE mCsg_int_mes				MONEY(18,2);
DEFINE mCsg_sdo_act_total_int	MONEY(18,2);
DEFINE mCsg_iva_int_vig			MONEY(18,2);
DEFINE mCsg_iva_int_vdo			MONEY(18,2);
DEFINE mCsg_iva_int_moratorios	MONEY(18,2);
DEFINE mCsg_iva_int_mes			MONEY(18,2);
DEFINE mCsg_sdo_act_total_iva	MONEY(18,2);
DEFINE mCsg_com_pend			MONEY(18,2);
DEFINE mCsg_iva_com				MONEY(18,2);
DEFINE mCsg_sdo_retenido		MONEY(18,2);
DEFINE mCsg_tot_liquidacion		MONEY(18,2);
DEFINE mCsg_int_devengado		MONEY(18,2);
DEFINE mCsg_iva_int_devengado	MONEY(18,2);
DEFINE mCsg_linea_disp			MONEY(18,2);
DEFINE mCsg_pagos_vdos			MONEY(18,2);
DEFINE cCsg_desc_status_cred	CHAR(60);
DEFINE iCsg_id_bloqueo_cred		INTEGER;
DEFINE cCsg_bloqueo_cta			CHAR(60);
DEFINE cCsg_id_causa_bloq_cred	CHAR(3);
DEFINE cCsg_causa_bloqueo_cta	CHAR(50);
DEFINE cCsg_id_sit_esp_cte		CHAR(1);
DEFINE iCsg_id_causa_esp_cte	INTEGER;
DEFINE cCsg_sit_esp_cte			CHAR(75);
DEFINE cCsg_id_sit_esp_cred		CHAR(1);
DEFINE iCsg_id_causa_esp_cred	INTEGER;
DEFINE cCsg_sit_esp_cred		CHAR(75);

DEFINE cSql            	CHAR(2600);
DEFINE cNombreArchivo  	CHAR(100);
DEFINE cNombreArchivo1  CHAR(100);
DEFINE cConsulta		CHAR(2300);
DEFINE cEncabezado		CHAR(2300);


---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';
LET cNumcte 			= "";
LET cNumCred 			= "";
LET cRuta 				= "";
LET cNum_producto		= "";
LET cNomCte     		= "";
LET iDiasVencido		= 0;
LET iMontoVencido		= 0;
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
LET cBCCodret		= "";
LET CBCMensajeRet   = "";





---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
LET cCsg_codigo_ret				= "00000";
LET cCsg_mensaje_ret			= "";
LET cCsg_num_credito			= "";
LET cCsg_cod_tipcred			= "";
LET cStatus						= "";
LET dtCsg_fec_origen			= MDY(1,1,1900);
LET dtCsg_fec_prox_pago			= MDY(1,1,1900);
LET mCsg_pago_min				= 0.0;
LET dtCsg_fec_ult_pago			= MDY(1,1,1900);
LET iCsg_plazo					= 0;
LET iCsg_pagos_realizados		= 0;
LET mCsg_linea_otorgada			= 0.0;
LET mCsg_tasa_interes			= 0.0;
LET dCsg_tasa_moratorios		= 0.0;
LET dCsg_monto_sbc				= 0.0;
LET mCsg_cap_vig				= 0.0;
LET mCsg_cap_trans				= 0.0;
LET mCsg_cap_vdo_exig			= 0.0;
LET mCsg_cap_vdo_no_exig		= 0.0;
LET mCsg_sdo_act_total_cap		= 0.0;
LET mCsg_int_vig				= 0.0;
LET mCsg_int_vdo				= 0.0;
LET mCsg_int_moratorios			= 0.0;
LET mCsg_int_mes				= 0.0;
LET mCsg_sdo_act_total_int		= 0.0;
LET mCsg_iva_int_vig			= 0.0;
LET mCsg_iva_int_vdo			= 0.0;
LET mCsg_iva_int_moratorios		= 0.0;
LET mCsg_iva_int_mes			= 0.0;
LET mCsg_sdo_act_total_iva		= 0.0;
LET mCsg_com_pend				= 0.0;
LET mCsg_iva_com				= 0.0;
LET mCsg_sdo_retenido			= 0.0;
LET mCsg_tot_liquidacion		= 0.0;
LET mCsg_int_devengado			= 0.0;
LET mCsg_iva_int_devengado		= 0.0;
LET mCsg_linea_disp				= 0.0;
LET mCsg_pagos_vdos				= 0.0;
LET cCsg_desc_status_cred		= "";
LET iCsg_id_bloqueo_cred		= 0;
LET cCsg_bloqueo_cta			= "";
LET cCsg_id_causa_bloq_cred		= "";
LET cCsg_causa_bloqueo_cta		= "";
LET cCsg_id_sit_esp_cte			= "";
LET iCsg_id_causa_esp_cte		= 0;
LET cCsg_sit_esp_cte			= "";
LET cCsg_id_sit_esp_cred		= "";
LET iCsg_id_causa_esp_cred		= 0;
LET iBandera		= 0;
LET cCsg_sit_esp_cred			= "";

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = iIsamErr;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;
	
	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
    --SET ISOLATION COMMITTED READ;
    --SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	
   --SET DEBUG FILE TO "/ifxsif01/PEDRO_PRUEBAS/sps_pruebas/saldosinmaterialesdespues.out";
	--TRACE ON;
	
	IF NVL(pEmpresa,'') = ''  THEN
		LET cCodRet	= '00001';
		LET cMensajeRet	= 'PARAMETRO DE ENTRADA INVALIDOS';
		RETURN cCodRet,cMensajeRet;
	END IF;
    --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM "informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00001';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 

	--let cRuta = '/ifxsif01/PEDRO_PRUEBAS/reportes_pruebas/';----PRUEBA

		--Saldo para reporte de saldos inmateriales
	SELECT valor
	INTO iMontoVencido
	FROM "informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='083';
	
	---NO EXISTE PARAMETRO SALDO PARA REPORTE DE SALDOS INMATERIALES
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00003';
		LET cMensajeRet ='NO EXISTE PARAMETRO SALDO PARA REPORTE DE SALDOS INMATERIALES';
		RETURN cCodRet,cMensajeRet;
	END IF;	
	
	FOREACH WITH HOLD
		SELECT  numcte,num_credito,estatus_fin
		INTO cNumcte,cNumCred , cStatus
		FROM "informix".sd_saldos_inmateriales a		 
		WHERE empresa =pEmpresa
		AND num_credito > ''
		and aplica_si ='2'
		
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,cNumCred)
		INTO  cCsg_codigo_ret,cCsg_mensaje_ret,cCsg_num_credito,cCsg_cod_tipcred,dtCsg_fec_origen,dtCsg_fec_prox_pago,mCsg_pago_min,
			dtCsg_fec_ult_pago,iCsg_plazo,iCsg_pagos_realizados,mCsg_linea_otorgada,mCsg_tasa_interes,dCsg_tasa_moratorios,
			dCsg_monto_sbc,mCsg_cap_vig,mCsg_cap_trans,mCsg_cap_vdo_exig,mCsg_cap_vdo_no_exig,mCsg_sdo_act_total_cap,mCsg_int_vig,
			mCsg_int_vdo,mCsg_int_moratorios,mCsg_int_mes,mCsg_sdo_act_total_int,mCsg_iva_int_vig,mCsg_iva_int_vdo,mCsg_iva_int_moratorios,
			mCsg_iva_int_mes,mCsg_sdo_act_total_iva,mCsg_com_pend,mCsg_iva_com,mCsg_sdo_retenido,mCsg_tot_liquidacion,mCsg_int_devengado,
			mCsg_iva_int_devengado,mCsg_linea_disp,mCsg_pagos_vdos,cCsg_desc_status_cred,iCsg_id_bloqueo_cred,cCsg_bloqueo_cta,
			cCsg_id_causa_bloq_cred,cCsg_causa_bloqueo_cta,cCsg_id_sit_esp_cte,iCsg_id_causa_esp_cte,cCsg_sit_esp_cte,cCsg_id_sit_esp_cred,
			iCsg_id_causa_esp_cred,cCsg_sit_esp_cred;
			
		
		

		UPDATE "informix".sd_saldos_inmateriales
			SET 	estatus_fin  = CASE WHEN NVL(cStatus,"") ="" THEN estatus ELSE cStatus END  ,
			estatus_desc_fin =cCsg_desc_status_cred,
			saldo_capital_fin =mCsg_sdo_act_total_cap,
			meses_vencidos_fin =mCsg_pagos_vdos,
			vencido_exigible_fin =mCsg_cap_vdo_exig,
			vencido_noexigible_fin =mCsg_cap_vdo_no_exig,
			interes_vencido_fin =mCsg_int_vdo,
			iva_interes_vencido_fin =mCsg_iva_int_vdo,
			interes_moratorio_fin =mCsg_int_moratorios,
			iva_interes_moratorio_fin =mCsg_iva_int_moratorios,
			saldo_total_fin =mCsg_tot_liquidacion
		WHERE empresa = pEmpresa 
		AND num_credito =cNumCred;
		
	LET iBandera = iBandera+1;
	END FOREACH;
	IF iBandera > 0 THEN
	
		--GENERA EL NOMBRE DEL ARCHIVO
		LET cNombreArchivo = TRIM('SaldosInmaterialesDespues')||TO_CHAR(TODAY,'%d%m%y')|| '.txt';
		LET cNombreArchivo1 = TRIM('SaldosInmateriales_aux')||TO_CHAR(TODAY,'%d%m%y')|| '.txt';
		
		--SELECCIONA LOS DATOS QUE FUERON INSERTADOS EN LA TABLA 
		LET cConsulta = "SELECT a.fecha_reporte,TRIM(a.numcte) ,TRIM(a.num_credito) ,TRIM(a.nombre_cte) ,TRIM(a.estatus),TRIM(a.estatus_desc),a.saldo_capital ,a.meses_vencidos, a.dias_vencido, a.atr, a.act, to_char( a.fecha_vencido,'%d/%m/%Y') fecha_vencido, a.fecha_ult_dispo ,a.vencido_exigible ,a.vencido_noexigible ,a.interes_vencido ,a.iva_interes_vencido ,a.interes_vencido_bal ,	a.iva_interes_vencido_bal ,a.interes_vencido_orden ,	a.iva_interes_vencido_orden,a.interes_moratorio , a.iva_interes_moratorio ,a.saldo_total,a.lineanodispuesta ,a.causa_cancelacion , DECODE (a.aplica_si,'2','Aplicado','No Aplicado') ,a.estatus_fin  ,TRIM(a.estatus_desc_fin) ,a.saldo_capital_fin,a.meses_vencidos_fin,a.vencido_exigible_fin,a.vencido_noexigible_fin,a.interes_vencido_fin ,a.iva_interes_vencido_fin ,a.interes_vencido_bal_fin, a.iva_interes_vencido_bal_fin,a.interes_vencido_orden_fin,a.iva_interes_vencido_orden_fin,a.interes_moratorio_fin,a.iva_interes_moratorio_fin, a.saldo_total_fin,a.lineanodispuesta_fin, b.sucursal  FROM 'informix'.sd_saldos_inmateriales a inner join bdisolic:ss_solicitudes b on (a.empresa = b.empresa and a.num_credito = b.num_solicitud) WHERE a.empresa = '001' and a.aplica_si ='2'   " ;

	---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo "Fecha de reporte'||'|'||'No. de Cliente'||'|'||'No. de CrÃ©dito'||'|'||'Nombre del Cliente'||'|'||'Estatus'||'|'||'Descripcion Estatus'||'|'||'Saldo Capital Insoluto'||'|'||'Meses Vencidos'||'|'||'Dias Vencidos'||'|'||'ATR'||'|'||'ACT'||'|'||'Fecha vencido'||'|'||'Fecha Ult Disp'||'|'||'Vencido Exigible'||'|'||'Vencido No Exigible'||'|'||'Interes Vencido Ordinario'||'|'||'IVA Interes Vencido Ordinario'||'|'||'Interes Vencido Balanza'||'|'||'IVA Interes Vencido Balanza'||'|'||'Interes Vencido Orden'||'|'||'IVA Interes Vencido Orden'||'|'||'Interes Moratorio'||'|'||'IVA Interes Moratorio'||'|'||'Saldo Total a Aplicar'||'|'||'LinÃ©a No Dispuesta'||'|'||'Causa de la CancelaciÃ³n'||'|'||'Resultado'||'|'||'Estatus Final'||'|'||'Descripcion Estatus'||'|'||'Saldo Capital insoluto'||'|'||'Meses Vencidos'||'|'||'Vencido Exigible'||'|'||'Vencido No Exigible'||'|'||'Interes Vencido Ordinario'||'|'||'IVA Interes Vencido Ordinario'||'|'||'Interes Vencido Balanza'||'|'||'IVA Interes Vencido Balanza'||'|'||'Interes Vencido Orden'||'|'||'IVA Interes Vencido Orden'||'|'||'Interes Moratorio'||'|'||'IVA Interes Moratorio'||'|'||'Saldo Total'||'|'||'LinÃ©a No Dispuesta'||'|'||'Sucursal Origen'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  

		SYSTEM cEncabezado;

		
		--CREACION DE TEMPORALESS USADOS PARA LA CREACION DE ARCHIVO
		LET cSql = '';
		LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRuta)||TRIM(cNombreArchivo1)||' DELIMITER '||'''|'''||' '||TRIM(cConsulta)||' "> '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = "dbaccess bdicred "|| TRIM(cRuta) || "query1.sql";
		SYSTEM TRIM(cSql);

		LET cSql = cSql;
		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;

		
		--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
		LET cSql = '';
		LET cSQL = "rm "||TRIM(cRuta)||'query1.sql';		
		SYSTEM TRIM(cSql); 
		
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
		SYSTEM cSQL;   
	ELSE
		LET cCodRet = '00004';
		LET cMensajeRet ='NO EXISTE INFORMACION PARA REPORTE DE SALDOS INMATERIALES';
		RETURN cCodRet,cMensajeRet;
	END IF
	
	
	
	
	RETURN cCodRet,cMensajeRet;
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para ', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 21 Mayo 2014',
'VERSION: 20140521.1645',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_aplica_bonificacion_retencion (
	pEmpresa CHAR(3)
	,pNumCredito CHAR(20)
	,pMontoRecompensa MONEY (14,2)
	)
RETURNING CHAR(5) AS codRet 

-- Codigo de Retorno
DEFINE codRet 			CHAR(5);
--Variables para el manejo de errores
DEFINE iSqlErr 	  		INTEGER;  
DEFINE iIsamErr   		INTEGER;
--retorno de sp_generafolionomina
DEFINE cCodRet 			CHAR(3);
DEFINE cNumeroFolio		CHAR(16);
--retorno de principalrefer
DEFINE codRetF 			CHAR(5);
DEFINE g_Remanente    	MONEY(14,2);
DEFINE g_IntMoraCob   	MONEY(14,2);
DEFINE g_IntVencCob   	MONEY(14,2);
DEFINE g_CapVencCob   	MONEY(14,2);
DEFINE g_IntVigCob    	MONEY(14,2);
DEFINE g_CapVigCob    	MONEY(14,2);
DEFINE g_Impuesto     	MONEY(14,2);
DEFINE g_Comision     	MONEY(14,2);
DEFINE g_Seguro       	MONEY(14,2);
BEGIN	
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN 
			LET codRet = iSqlErr;
			RETURN codRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_aplica_bonificacion_retencion"".out";     
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	LET codRet = "00000";
	
	--Valida de parametros 
	IF nvl(pEmpresa,'') = '' OR nvl(pNumCredito,'') = ''  OR nvl(pMontoRecompensa,'') = ''  
	 then 
		LET codRet = "00001";
		RETURN codRet;
	END IF;
    
	-- Llamado a sp_generafolionomina
    CALL bdicheq:"informix".sp_generafolionomina('informix')
    returning cCodRet, cNumeroFolio;
	--Valida respuesta de sp_generafolionomina
    IF (cCodRet <> "000") THEN		
        LET codRet = LPAD(TRIM(cCodRet),5,'0') ;
		return codRet;
    end if;	
	
	-- Llamado a el procedimiento almacenado de principalrefer
	CALL "informix".principalrefer(
			pEmpresa,
			pNumCredito,
			1,
			'',
			'informix',
			'9050',
			cNumeroFolio,
			'8800',
			0.0,
			pMontoRecompensa,
			cNumeroFolio
	)
	returning codRetF, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
	g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
	--Valida respuesta de principalrefer
	IF (codRetF <> "000") THEN	
        LET codRet = LPAD(TRIM(codRetF),5,'0') ;
		return codRet;
	end if;
	--En caso de no tener un codigo de retorno diferente de 00000 se considera que la operacion se realizo correctamente
	RETURN codRet;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Alejandro Rodriguez Martinez', 
'DESCRIPCION: Genera un folio de nomina y ejecuta el procedimiento almacenado principalrefer',
'Codigo de retorno 00001 indica que se ha enviado parametros de entrada invalidos',
'Codigo de retorno diferente de 00000 y 00001 indican que ha ocurrido un error en el proceso de aplcacion de bonificacion',
'FECHA : 23/Febrero/2022',
'BD    : BDICRED',
'FOLIO: 833 - Adendum RQM 10 1405 CÃ©lula de RetenciÃ³n TDC';

CREATE PROCEDURE "informix".sp_asigna_cupones_retencion(
															pTipoEjecucion SMALLINT,
															pIdCupon  INTEGER,
															pCliente CHAR(9),
															pSucursal CHAR(4),
															pEjecutivo CHAR(8),
															pFecha DATE,
															pMotivo CHAR(4))
   RETURNING CHAR(5) as cCodRet;

-- Declaracion de variables 
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	

	LET cCodRet			  = '00000';
	LET iSqlErr			  = 0;
   
						
BEGIN  -- // MANEJADOR DE ERRORES //
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
	
	IF (NVL(pTipoEjecucion, 0) = 1 OR NVL(pTipoEjecucion, 0) = 2) THEN 
		IF NVL(pIdCupon, 0) < 1 THEN 
			LET cCodRet = '00001';
			RETURN TRIM(cCodRet);
			
		END IF
		
		IF(pTipoEjecucion = 1)THEN
			IF TRIM(NVL(pCliente, '')) = '' OR TRIM(NVL(pSucursal, '')) = '' OR TRIM(NVL(pEjecutivo, '')) = '' OR TRIM(NVL(pFecha, '')) = '' OR TRIM(NVL(pMotivo, '')) = '' THEN 
				LET cCodRet = '00001';
				RETURN TRIM(cCodRet);
			END IF
		
			UPDATE bdicred:"informix".sd_cupones_retencion 
			SET sucursal = pSucursal, ejecutivo = pEjecutivo, fecha = pFecha, motivo = pMotivo,cliente = pCliente
			WHERE id_cupon = pIdCupon;
			
		ELIF (pTipoEjecucion = 2)THEN
			UPDATE bdicred:"informix".sd_cupones_retencion 
			SET cliente = null, sucursal = null, ejecutivo = null, fecha = null, motivo = null
			WHERE  id_cupon = pIdCupon;
		END IF
	ELSE
		LET cCodRet = '00002';
		RETURN TRIM(cCodRet);
	END IF
	
	RETURN cCodRet;
		
END;
END PROCEDURE
DOCUMENT
 'AUTOR: Nephtali Palillero PÃ©rez',
 'DESCRIPCION: SP que asigna Ã³ libera los cupones que se ofrecen para la retencion de clientes',
 'en el proceso de celula de retencion de TDC',
 'Codigo de retorno 00001 indica que un campo es nulo o vacio',
 ' Codigo de retorno 00002 indica que el tipo de ejecucion no es valido',
 'FOLIO: 833-Celula de Retencion',
 'FECHA: 14/Febrero/2022',	
 'BD	: BDICRED',
 'SOLICITO: Abraham Narvaez';

CREATE PROCEDURE "informix".sp_consctedetallecredito_web(pEmpresa CHAR(3), pNumCte CHAR(20), pNumCredito CHAR(20), pNumTarjeta CHAR(20)) 
RETURNING CHAR(5) 	    AS CodRet,
		  CHAR(150)     AS NomCteTitular,
		  DATE 		    AS FechaNAC,
		  CHAR(13) 	    AS RFC,
		  CHAR(20) 	    AS NumCte,
		  CHAR(20) 	    AS NumCredito, 
		  CHAR(20) 	    AS NumTarjeta,
		  CHAR(40) 	    AS NombreProducto,
		  DATE 		    AS FechaApertura,
		  CHAR(4)       AS CodigoEstatus, --Se agrega variable para retornar codigo de status
		  CHAR(60) 	    AS Estatus, 
		  DATE 		    AS FechaUltMovimiento,
		  DECIMAL(18,2) AS SaldoActual,
		  DECIMAL(18,2) AS SaldoRetenido; --Se agrega variable para retornar saldo retenido
		  
-- DEFINICION DE VARIABLES DEL PROCEDIMIENTO SP_CONSCTEDETALLECREDITO.
DEFINE cCodRet				CHAR(5);
DEFINE dFechaNAC			DATE;
DEFINE cRfc					CHAR(13);
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE cStatusCred          CHAR(4);

-- DEFINICION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
DEFINE cCodRetCSG			CHAR(6);
DEFINE cMsjRetCSG			CHAR(80);
DEFINE cNumCreditoCSG		CHAR(20);
DEFINE cCodTCredCSG			CHAR(2);
DEFINE dFechaOrigCSG		DATE;
DEFINE dFechaProxPagCSG 	DATE;
DEFINE dcPagoMinCSG			DECIMAL(18,2);
DEFINE dFechaUltPagCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagRealizadosCSG	INTEGER;
DEFINE dcLinOtorgadaCSG		DECIMAL(18,2);
DEFINE dcTasaInteresCSG		DECIMAL(9,6);
DEFINE dcTasaMoratoriosCSG 	DECIMAL(9,6);
DEFINE dcMontoSbsCSG		DECIMAL(14,2);
DEFINE dcCapVigCSG			DECIMAL(18,2);
DEFINE dcCapTransCSG		DECIMAL(18,2);
DEFINE dcCapVdoExigCSG		DECIMAL(18,2);
DEFINE dcCapVdoNoExigCSG	DECIMAL(18,2);
DEFINE dcSdoActTotCapCSG	DECIMAL(18,2);
DEFINE dcIntVigCSG			DECIMAL(18,2);
DEFINE dcIntVdoCSG			DECIMAL(18,2);
DEFINE dcIntMoratorioCSG	DECIMAL(18,2);
DEFINE dcIntMesCSG			DECIMAL(18,2);
DEFINE dcSodActTotIntCSG	DECIMAL(18,2);
DEFINE dcIvaIntVigCSG		DECIMAL(18,2);
DEFINE dcIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dcIvaIntMorCSG		DECIMAL(18,2);
DEFINE dcIvaIntMesCSG		DECIMAL(18,2);
DEFINE dcSdoActTotIvaCSG	DECIMAL(18,2);
DEFINE dcComPendCSG			DECIMAL(18,2);
DEFINE dcIvaComCSG			DECIMAL(18,2);
DEFINE dcSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dcTotalLiqCSG		DECIMAL(18,2);
DEFINE dcIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcLinDispCSG			DECIMAL(18,2);
DEFINE dcPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqCtaCSG			CHAR(60);
DEFINE cIdCausaBloqCredCSG	CHAR(3);
DEFINE cCausaBloqCtaCSG		CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG 		CHAR(75);

-- DECLARACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO SP_CONSULTACREDITOSCANCELAR
DEFINE cCodRetCCC			CHAR(6);
DEFINE cMsjRetCCC			CHAR(80);
DEFINE cNumCreditoCCC 		CHAR(20);
DEFINE cNumCteCCC 			CHAR(20);
DEFINE cNombreProductoCCC	CHAR(40);
DEFINE cNumTarjetaCCC 		CHAR(20);
DEFINE cNombreClienteCCC 	CHAR(150);

-- VARIABLES DE RETORNO DEL SP_DESC_RET
DEFINE vCodRet 	 		 	VARCHAR(5);
DEFINE vMsjRetorno 		 	VARCHAR(100);

-- INICIALIZACION DE VARIABLES DEL PROCEDIMIENTO SP_CONSCTEDETALLECREDITO.
LET cCodRet					= '00000';
LET dFechaNAC				= DATE(1);
LET cRfc					= '';
LET iSqlErr              	= 0;
LET iIsamErr             	= 0;
LET cErrorInfo           	= '';
LET cStatusCred             = '';

-- INICIALIZACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
LET cCodRetCSG				= '000000';
LET cMsjRetCSG				= '';
LET cNumCreditoCSG			= '';
LET cCodTCredCSG			= '';
LET dFechaOrigCSG			= DATE(1);
LET dFechaProxPagCSG 		= DATE(1);
LET dcPagoMinCSG			= 0.00;
LET dFechaUltPagCSG			= DATE(1);
LET iPlazoCSG				= 0;
LET iPagRealizadosCSG		= 0;
LET dcLinOtorgadaCSG		= 0.00;
LET dcTasaInteresCSG		= 0.00;
LET dcTasaMoratoriosCSG 	= 0.00;
LET dcMontoSbsCSG			= 0.00;
LET dcCapVigCSG				= 0.00;
LET dcCapTransCSG			= 0.00;
LET dcCapVdoExigCSG			= 0.00;
LET dcCapVdoNoExigCSG		= 0.00;
LET dcSdoActTotCapCSG		= 0.00;
LET dcIntVigCSG				= 0.00;
LET dcIntVdoCSG				= 0.00;
LET dcIntMoratorioCSG		= 0.00;
LET dcIntMesCSG				= 0.00;
LET dcSodActTotIntCSG		= 0.00;
LET dcIvaIntVigCSG			= 0.00;
LET dcIvaIntVdoCSG			= 0.00;
LET dcIvaIntMorCSG			= 0.00;
LET dcIvaIntMesCSG			= 0.00;
LET dcSdoActTotIvaCSG		= 0.00;
LET dcComPendCSG			= 0.00;
LET dcIvaComCSG				= 0.00;
LET dcSdoRetenidoCSG		= 0.00;
LET dcTotalLiqCSG			= 0.00;
LET dcIntDevengadoCSG		= 0.00;
LET dcIvaIntDevengadoCSG	= 0.00;
LET dcLinDispCSG			= 0.00;
LET dcPagosVdosCSG			= 0.00;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqCtaCSG				= '';
LET cIdCausaBloqCredCSG		= '';
LET cCausaBloqCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0;
LET cSitEspCredCSG 			= '';

-- INICIALIZACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTACREDITOSCANCELAR
LET cCodRetCCC				= '000000';
LET cMsjRetCCC				= '';
LET cNumCreditoCCC 			= '';
LET cNumCteCCC 				= '';
LET cNombreProductoCCC		= '';
LET cNumTarjetaCCC 			= '';
LET cNombreClienteCCC 		= '';

-- INICIALIZACION DE VARIABLES DEL PROCEDIMIENTO SP_DESC_RET
LET vCodRet 	 			= '00000';
LET vMsjRetorno  			= '';

 --SET DEBUG FILE TO '/tmp/sp_consctedetallecredito.out';
 --TRACE ON;


	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cNombreClienteCCC = cErrorInfo;
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- VALIDAMOS LOS PARAMETROS DE ENTRADA.
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' AND NVL(pNumCredito,'') = '' AND NVL(pNumTarjeta,'') = '' THEN
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','590')
			INTO vCodRet, vMsjRetorno;
			
			LET cCodRet = '00001';
			LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
			RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
				   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
				   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
		END IF
		
		IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pNumCredito,'') <> '' AND NVL(pNumTarjeta,'') <> '' THEN
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','591')
			INTO vCodRet, vMsjRetorno;
			
			LET cCodRet = '00001';
			LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
			RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
				   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
				   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
		END IF
		
		-- CONSULTAMOS SI EXISTE EL VALOR QUE SE DESEA CONSULTAR.
		IF TRIM(NVL(pNumCte,'')) <> '' THEN
			-- VALIDAMOS SI EXISTE EL CLIENTE
			IF ( SELECT COUNT(rfc) FROM bdinteg:"informix".si_cliente WHERE numcte = TRIM(pNumCte) ) = 0 THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','592')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet = '00002';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
			
		ELIF TRIM(NVL(pNumCredito,'')) <> '' THEN
			-- VALIDAMOS SI EXISTE EL CREDITO.
			IF NOT EXISTS (SELECT num_credito, b.cod_prod FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_tipprod b 
						   WHERE a.num_credito = TRIM(pNumCredito) AND a.empresa = TRIM(pEmpresa) AND a.empresa = b.empresa  AND a.num_producto = b.abrevia_prod ) THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','593')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet = '00003';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
		ELIF TRIM(NVL(pNumTarjeta,'')) <> '' THEN
			-- VALIDAMOS SI EXISTE LA TARJETA.
			IF(SELECT num_credito FROM bdicred:"informix".sd_tarjeta WHERE empresa = TRIM(pEmpresa) AND num_tarjeta = TRIM(pNumTarjeta) ) = 0 THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','594')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet = '00004';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
		END IF
		
		-- CONSULTAMOS LOS DATOS GENERALES DEL CLIENTE.
		FOREACH 
			EXECUTE PROCEDURE bdicred:"informix".sp_consultacreditoscancelar_celula(TRIM(pEmpresa), TRIM(pNumCte), TRIM(pNumCredito), TRIM(pNumTarjeta))
			INTO cCodRetCCC, cMsjRetCCC, cNumCreditoCCC, cNumCteCCC, cNombreProductoCCC, cNumTarjetaCCC, cNombreClienteCCC , cStatusCred
			
			IF cCodRetCCC = '000001' THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','590') -- DEBE ENVIAR AL MENOS UN PARAMETRO OBLIGATORIO
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet  = '00005';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			ELIF cCodRetCCC = '000005' THEN 
				LET cCodRet  = '00011'; -- CLIENTE NO TIENE CREDITOS POR CANCELAR.
			ELIF cCodRetCCC = '000007' THEN 
				LET cCodRet  = '00013'; -- CREDITO NO PUEDE SER CANCELADO.
			ELIF cCodRetCCC = '000008' THEN 
				LET cCodRet  = '00014'; -- TARJETA NO PUEDE SER CANCELADA.
			ELIF cCodRetCCC = '000006' THEN 
				LET cCodRet  = '00012'; -- NO SE PUEDE CANCELAR CREDITO CON TARJETA ADICIONAL.
				
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			ELIF cCodRetCCC::INTEGER < 0 THEN -- ERROR NO CONTROLADO EN EL BDICRED:"informix".SP_CONSULTACREDITOSCANCELAR
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','596')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet  = '00007';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
			
			 
				-- CONSULTAMOS EL SALDO GENERAL DEL CREDITO.
				EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(TRIM(pEmpresa), TRIM(cNumCreditoCCC))
				INTO cCodRetCSG, cMsjRetCSG, cNumCreditoCSG, cCodTCredCSG, dFechaOrigCSG, dFechaProxPagCSG, dcPagoMinCSG, dFechaUltPagCSG, iPlazoCSG, iPagRealizadosCSG, dcLinOtorgadaCSG, dcTasaInteresCSG, dcTasaMoratoriosCSG, dcMontoSbsCSG, 
					 dcCapVigCSG, dcCapTransCSG, dcCapVdoExigCSG, dcCapVdoNoExigCSG, dcSdoActTotCapCSG, dcIntVigCSG, dcIntVdoCSG, dcIntMoratorioCSG, dcIntMesCSG, dcSodActTotIntCSG, dcIvaIntVigCSG, dcIvaIntVdoCSG, dcIvaIntMorCSG, dcIvaIntMesCSG,
					 dcSdoActTotIvaCSG, dcComPendCSG, dcIvaComCSG, dcSdoRetenidoCSG, dcTotalLiqCSG, dcIntDevengadoCSG, dcIvaIntDevengadoCSG, dcLinDispCSG, dcPagosVdosCSG, cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqCtaCSG, cIdCausaBloqCredCSG, 
					 cCausaBloqCtaCSG, cIdSitEspCteCSG, iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;
				
				IF cCodRetCSG = '000005' THEN -- OCURRIO UN ERROR AL REALIZAR CALCULO
					EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','597')
					INTO vCodRet, vMsjRetorno;
					
					LET cCodRet  = '00008';
					LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
					RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
						   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
						   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
				ELIF cCodRetCSG = '000006' THEN -- NO SE ENCONTRO EL FACTOR DE LA COMISION
					EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','598')
					INTO vCodRet, vMsjRetorno;
					
					LET cCodRet  = '00009';
					LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
					RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
						   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
						   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
				ELIF cCodRetCSG::INTEGER < 0 THEN -- ERROR NO CONTROLADO EN EL BDICRED:"informix".SP_CONSULTA_SALDOS_GENERAL
					EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','599')
					INTO vCodRet, vMsjRetorno;
					
					LET cCodRet  = '00010';
					LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
					RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
						   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
						   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
				END IF
				
				-- VALIDAMOS SI EXISTE EL CLIENTE Y CONSULTAMOS EL RFC DEL CLIENTE.
				SELECT rfc INTO cRfc FROM bdinteg:"informix".si_cliente WHERE numcte = TRIM(cNumCteCCC);
				
				-- CONSULTAMOS LA FECHA DE NACIMIENTO DEL CLIENTE.
				SELECT Fecha_NAC INTO dFechaNAC FROM bdinteg:"informix".si_ctepf WHERE numcte = TRIM(cNumCteCCC);
				
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00) WITH RESUME;
				
		END FOREACH
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para consultar el detalle del credito',
'AUTOR: Valentin Lopez',
'FECHA DE CREACION: 12 de Octubre del 2012',
'VERSION: 20121012.1504',
'BD: bdicred',
'MODIFICO: Carlos Ochoa Valenzuela',
'DESCRIPCION: Se declara e incluye una variable para Saldo Retenido y para obtener el codigo de descripcion e incluirlo dentro de los return.', 
'FECHA DE MODIFICACION: 10 de Diciembre del 2012',
'VERSION: 20121210.1814',
'BD: BDICRED',
'MODIFICACION: Alejandro Rodriguez Martinez',
'DESCRIPCION: Se cambia la invocacion de SP sp_consultaCreditosCancelar por el SP sp_consultacreditoscancelar_celula ', 
'FECHA DE MODIFICACION: 29 de Marzo del 2022',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_consultacreditoscancelar_celula(pEmpresa      CHAR(3), 
                                                        pNumCte       CHAR(20),
                                                        pNumCredito   CHAR(20),
                                                        pNumTarjeta   CHAR(20))
RETURNING CHAR(6)   AS CodRet,
          CHAR(80)  AS MensajeRet,
          CHAR(20)  AS NumeroCredito,
          CHAR(20)  AS NumeroCliente,
          CHAR(40)  AS NombreProducto,
          CHAR(20)  AS NumeroTarjeta,
          CHAR(150) AS NombreCliente,
		  CHAR(4)   AS CodigoStatus;

-- DECLARACION DE VARIABLES
DEFINE iSqlErr       		INTEGER;
DEFINE iIsamErr      		INTEGER;
DEFINE cErrorInfo    		CHAR(80);
DEFINE cCodRet       		CHAR(6);
DEFINE cMensajeRet   		CHAR(80);

DEFINE cNumCredito   		CHAR(20);
DEFINE cNumCte       		CHAR(20);
DEFINE cNomProducto  		CHAR(40);
DEFINE cNumTarjeta   		CHAR(20);
DEFINE cNomCte       		CHAR(150);
DEFINE cTipoTarjeta    		CHAR(1);
DEFINE cStatus              CHAR(4);

-- VARIABLES DE RETORNO DEL SP_DESC_RET
DEFINE vCodRet 	 		 	VARCHAR(5);
DEFINE vMsjRetorno 		 	VARCHAR(100);
DEFINE iBandera 		 	INTEGER;

-- INICIALIZACIONES
LET iSqlErr       			= 0;
LET iIsamErr      			= 0;
LET cErrorInfo    			= '';
LET cCodRet       			= '000000';
LET cMensajeRet   			= 'Se realizÃ³ la consulta correctamente.';

LET cNumCredito   			= '';
LET cNumCte       			= '';
LET cNomProducto  			= '';
LET cNumTarjeta   			= '';
LET cNomCte       			= '';
LET cTipoTarjeta   			= '';
LET cStatus                 = '';

-- INICIALIZACION DE VARIABLES DEL PROCEDIMIENTO SP_DESC_RET
LET vCodRet 	 			= '00000';
LET vMsjRetorno  			= '';
LET iBandera  			= 0;

--SET DEBUG FILE TO '/tmp/sp_consultacreditoscancelar_celula.out';
--TRACE ON;

BEGIN 

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  LET cMensajeRet= cErrorInfo;
		  RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,''), NVL(cStatus,'') ;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- VALIDACIN DE LOS PARAMETROS DE ENTRADA.
	IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pNumCte,'')) = '' AND TRIM(NVL(pNumCredito,'')) = '' AND TRIM(NVL(pNumTarjeta,'')) = '' THEN
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','590')
		INTO vCodRet, vMsjRetorno;
		
		LET cCodRet= '000001';
	    LET cMensajeRet = vMsjRetorno::CHAR(80);
		RETURN cCodRet, TRIM(NVL(cMensajeRet,'')), TRIM(NVL(cNumCredito,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomProducto,'')), TRIM(NVL(cNumTarjeta,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cStatus,''));
	END IF;
	
	
		IF (NVL(pNumCte,'')) <> '' THEN
				SELECT num_credito, '', numcte
				INTO cNumCredito, cTipoTarjeta, cNumCte
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				  AND numcte = pNumCte
				  AND num_producto ='7800'
				  AND status_cred in ('AA','BA','BT','E1','E2','E3','CV','FC', 'VP');

		ELIF (NVL(pNumCredito,'')) <> '' THEN
			-- VALIDAMOS SI ES TARJETA ADICIONAL.
				SELECT num_credito, '', numcte
				INTO cNumCredito, cTipoTarjeta, cNumCte
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				  AND num_credito = pNumCredito
				  AND num_producto ='7800'
				  AND status_cred in ('AA','BA','BT','E1','E2','E3','CV','FC', 'VP');
		END IF
		
		
		IF SUBSTR(cNumCredito,1,2) = '78' THEN
			FOREACH
			SELECT DISTINCT TRIM(a.num_credito), TRIM(a.numcte), '', TRIM(c.nombre_prod),
				   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte ,status_cred
			INTO cNumCredito, cNumCte, cNumTarjeta, cNomProducto, cNomCte ,cStatus
			FROM bdicred:"informix".sd_maecred a,
				 bdinteg:"informix".si_cliente b, 
				 bdicred:"informix".sd_definicion c, 			 
				 bdicred:"informix".sd_tipprod e
			WHERE c.num_producto = a.num_producto
			  AND c.empresa = a.empresa
			  AND b.empresa = a.empresa
				AND c.num_producto = a.num_producto
			  AND b.numcte = a.numcte
			  AND b.apell_paterno = b.apell_paterno 
			  AND b.apell_materno = b.apell_materno 
			  AND e.cod_prod = 'T'		  
			  AND a.status_cred IN ('AA','BA','BT','E1','E2','E3','CV','FC', 'VP')
			  AND a.empresa = TRIM(pEmpresa)
			  AND e.empresa = TRIM(pEmpresa)    
			  AND a.numcte = pNumCte
			  AND a.num_credito = cNumCredito
			  AND a.num_producto ='7800'
			 AND status_cred in ('AA','BA','BT','E1','E2','E3','CV','FC', 'VP')
						
			LET iBandera = 1;
			
			RETURN cCodRet, TRIM(NVL(cMensajeRet,'')), TRIM(NVL(cNumCredito,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomProducto,'')), TRIM(NVL(cNumTarjeta,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cStatus,'')) WITH RESUME;
			
			END FOREACH
		END IF
			
		  IF (NVL(pNumCte,'')) <> '' THEN
				-- VALIDAMOS SI ENTRA POR NUMERO DE CLIENTE.
				SELECT num_tarjeta, tipo_tarjeta, num_credito
				INTO pNumTarjeta, cTipoTarjeta, pNumCredito
				FROM bdicred:"informix".sd_tarjeta a
				WHERE empresa = pEmpresa
					AND tipo_tarjeta = 'T'
					AND secuencia = (select max(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE empresa = a.empresa 
					AND tipo_tarjeta = 'T' AND numcte = a.numcte AND status_tar = 'A')
					AND numcte = pNumCte;

			ELIF (NVL(pNumCredito,'')) <> '' THEN
				-- VALIDAMOS SI ENTRA POR NUMERO DE CREDITO.
				SELECT num_tarjeta, tipo_tarjeta, numcte
				INTO pNumTarjeta, cTipoTarjeta, pNumCte
				FROM bdicred:"informix".sd_tarjeta a
				WHERE empresa = pEmpresa
					AND tipo_tarjeta = 'T'
					AND secuencia = (select max(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE empresa = a.empresa AND tipo_tarjeta = 'T' AND num_credito = a.num_credito)
					AND num_credito = pNumCredito;
			
			ELIF (NVL(pNumTarjeta,'')) <> '' THEN
				-- VALIDAMOS SI ES TARJETA ADICIONAL.
				SELECT num_credito, tipo_tarjeta, numcte
				INTO pNumCredito, cTipoTarjeta, pNumCte
				FROM bdicred:"informix".sd_tarjeta
				WHERE empresa = pEmpresa
				  AND num_tarjeta = pNumTarjeta;
				
			END IF
			
		IF cTipoTarjeta = 'A' THEN -- NO SE PUEDE CANCELAR CREDITO CON TARJETA ADICIONAL.
			LET cCodRet = '000006';
			RETURN cCodRet, (NVL(cMensajeRet,'')), (NVL(cNumCredito,'')), (NVL(cNumCte,'')), (NVL(cNomProducto,'')), (NVL(cNumTarjeta,'')), (NVL(cNomCte,'')), (NVL(cStatus,''));
		ELIF (pNumTarjeta) = '' THEN
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','594')
			INTO vCodRet, vMsjRetorno;
			LET cCodRet = '000004';
			LET cMensajeRet = vMsjRetorno::CHAR(80);
			RETURN cCodRet, (NVL(cMensajeRet,'')), (NVL(cNumCredito,'')), (NVL(cNumCte,'')), (NVL(cNomProducto,'')), (NVL(cNumTarjeta,'')), (NVL(cNomCte,'')), (NVL(cStatus,''));
		END IF	
	
	
	
	
	
			-- CONSULTAMOS LOS DATOS GENERALES DEL CLIENTE CON TIPO DE TARJETA DE CREDITO
			FOREACH
				SELECT DISTINCT TRIM(a.num_credito), TRIM(a.numcte), TRIM(d.num_tarjeta), TRIM(c.nombre_prod),
					   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte ,status_cred
				INTO cNumCredito, cNumCte, cNumTarjeta, cNomProducto, cNomCte ,cStatus
				FROM bdicred:"informix".sd_maecred a,
					 bdinteg:"informix".si_cliente b, 
					 bdicred:"informix".sd_definicion c, 
					 bdicred:"informix".sd_tarjeta d,
					 bdicred:"informix".sd_tipprod e
				WHERE c.num_producto = a.num_producto
				  AND c.empresa = a.empresa
				  AND b.empresa = a.empresa
				  AND d.empresa = a.empresa
				  AND c.num_producto = a.num_producto
				  AND b.numcte = a.numcte
				  AND b.apell_paterno = b.apell_paterno 
				  AND b.apell_materno = b.apell_materno 
				  AND d.num_credito = a.num_credito
				  AND d.tipo_tarjeta = 'T'
				  AND e.cod_prod = 'T'		  
				  AND a.status_cred IN ('AA','BA','BT','E1','E2','E3','CV','FC', 'VP')
				  AND d.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE a.empresa = empresa AND a.num_credito = num_credito AND tipo_tarjeta = 'T') 
				  AND a.empresa = TRIM(pEmpresa)
				  AND e.empresa = TRIM(pEmpresa)    
				  AND a.numcte = pNumCte--TRIM(NVL(pNumCte,''))--DECODE(pNumCte, '', a.numcte, pNumCte)
				  AND a.num_credito = pNumCredito--TRIM(NVL(pNumCredito,''))--DECODE(pNumCredito, '', a.num_credito, pNumCredito)
				--ORDER BY a.num_credito
				LET iBandera = 1;
				RETURN cCodRet, TRIM(NVL(cMensajeRet,'')), TRIM(NVL(cNumCredito,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomProducto,'')), TRIM(NVL(cNumTarjeta,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cStatus,'')) WITH RESUME;
				
			END FOREACH
	
	IF iBandera =  0 THEN
		IF TRIM(NVL(pNumCte,'')) <> '' THEN
			LET cCodRet = '000005'; -- CLIENTE NO TIENE CREDITOS POR CANCELAR.
		ELIF TRIM(NVL(pNumCredito,'')) <> '' THEN
			LET cCodRet = '000007'; -- CREDITO NO PUEDE SER CANCELADO.
		ELIF TRIM(NVL(pNumTarjeta,'')) <> '' THEN
			LET cCodRet = '000008'; -- TARJETA NO PUEDE SER CANCELADA.
		END IF
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','595')
		INTO vCodRet, vMsjRetorno;

		LET cCodRet = '000005';
		LET cMensajeRet = vMsjRetorno::CHAR(80);
		
		RETURN TRIM(cCodRet), TRIM(NVL(cMensajeRet,'')), TRIM(NVL(cNumCredito,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomProducto,'')), TRIM(NVL(cNumTarjeta,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cStatus,''));
	END IF;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Alejandro Rodriguez Martinez',
'DESCRIPCION: Se realiza clonado de sp_consultacreditoscancelar para realizar una consulta general para obtener la informacion basica del cliente con estatus ("AA","BA","BT","E1","E2","E3","CV","FC", "VP")', 
'FECHA DE CLONACION: 29 de Octubre del 2022',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_genera_archivos_pf()
	RETURNING 
	CHAR(5) AS codRet;
	-- DEFINICION DE VARIABLES
	DEFINE vCodRet 						CHAR(5);
	DEFINE cretCarga                    CHAR(6);
	DEFINE vRuta						VARCHAR(100);
	DEFINE sNombreArchivoFinal          VARCHAR(250);
	DEFINE cRutaFinal		            VARCHAR(110);
	define vDiaHoy						VARCHAR(2);
	DEFINE vFechaHoy				 	DATE;
	DEFINE cSQLQuestion					CHAR(40);
	DEFINE vsSQL 						CHAR(3010);
	DEFINE vsSQL1 						CHAR(300);
	DEFINE vsSQL2 						CHAR(2510);
	DEFINE vsSQL3 						CHAR(200);
	DEFINE existeProspecto              INTEGER;
	define vDatosSaldo					integer;
	define vDatosCompra					integer;
	-- VARIABLES ERROR
	DEFINE iSqlErr                      INTEGER;
	DEFINE iSamErr                     	INTEGER;
-- ASIGNACION DE VARIABLES                           *
	LET vCodRet = '00000';
	LET cretCarga = '000000';
	LET vRuta = '';
	LET sNombreArchivoFinal = '';
	LET cRutaFinal = '';
	LET vDiaHoy = '';
	LET vFechaHoy = DATE(1);
	LET vsSQL = '' ;
	LET vsSQL1 = '' ;
	LET vsSQL2 = '' ;
	LET vsSQL3 = '' ;
	let vDatosSaldo = 0;
	let vDatosCompra = 0;
	LET existeProspecto = 0;
	-- VARIABLES ERROR
	LET iSqlErr    = 0;
	LET iSamErr   = 0;
	BEGIN
		--agrega el valor sqlexception para posibles excepciones
		ON EXCEPTION SET iSqlErr, iSamErr
				IF iSqlErr <> 0 THEN
					LET vCodRet = iSqlErr;
				END IF;
				RETURN vCodRet;
		END EXCEPTION;
		
	
		--SET DEBUG FILE TO '/tmp/sp_genera_archivos_pf.out';
		--SET DEBUG FILE TO '/pisa/pisabanco/sp_genera_archivos_pf.out'; --Ruta temporal
		--TRACE ON;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--obtiene la fecha de si_fechas y la ruta
		--valida si es dia 20 el dia de la ejecucion
		SELECT fecha_hoy, day(fecha_hoy) INTO vFechaHoy, vDiaHoy FROM bdicred:"informix".sd_fechas sdf where sdf.empresa ='001';
		if vFechaHoy is not null then
			--si es 20 se generan el proceso de saldo y de compras
			--se crea archivo unl de compras
			--se crea archivo unl de saldo
			select count(*) into vDatosCompra from bdicred:"informix".sd_pf_compras_retencion spcr where spcr.promocion = '8';
			if vDiaHoy = 20 then
				--para cada uno de los porcesos se valida si existen datos en la tablas sd_pf_saldo_retencion y sd_pf_compras_retencion respectivmente
				select count(*) into vDatosSaldo from bdicred:"informix".sd_pf_saldo_retencion sdsr where sdsr.promocion = '9';
				--en caso de existir se porcede en su defecto no se realiza accion alguna
				if vDatosCompra = 0 and vDatosSaldo = 0 then 
				let vCodRet = '00001';
					return vCodRet;
				elif vDatosCompra = 0 and vDatosSaldo > 0 then
					--RESPALDO DE FORMATO DE FECHA QUE SI JALA EN SP_CARGA_DATOS_CHAMP RPAD(NVL(TO_CHAR(srp.fecha_inicio,'%Y%m%d'),''),10,' ')
					let vsSQL2 = "SELECT "  ||
					"RPAD(srp.numcte,9,' '), RPAD(NVL(srp.numcredito, ''), 12, ' '), RPAD(srp.promocion,1,' '), RPAD(NVL(TO_CHAR(srp.fecha_inicio,'%m/%d/%Y'),''),10,' '), " ||
					"RPAD(NVL(TO_CHAR(srp.fecha_fin,'%m/%d/%Y'),''),10,' '), RPAD(srp.cod_retorno,1,' '), RPAD(srp.descripcion,1,' '), RPAD(srp.indicador_envio,1,' '), " ||
					"RPAD(srp.tasa,2,' '), RPAD(srp.plazo,2,' ') " ||
					" FROM " ||
					"bdicred:informix.sd_pf_saldo_retencion srp where srp.promocion = '9';";
				elif	vDatosCompra > 0 and vDatosSaldo = 0 then
					let vsSQL2 = "SELECT "  ||
					"RPAD(cps.numcte,9,' '), RPAD(NVL(cps.numcredito, ''), 12, ' '), RPAD(cps.promocion,1,' '), RPAD(NVL(TO_CHAR(cps.fecha_inicio,'%m/%d/%Y'),''),10,' '), " ||
					"RPAD(NVL(TO_CHAR(cps.fecha_fin,'%m/%d/%Y'),''),10,' '), RPAD(cps.cod_retorno,1,' '), RPAD(cps.descripcion,1,' '), RPAD(cps.indicador_envio,1,' '), " ||
					"RPAD('',2,''), RPAD('',2,'') " ||
					" FROM " ||
					"bdicred:informix.sd_pf_compras_retencion cps where cps.promocion = '8';";
				else 
					let vsSQL2 = "SELECT * FROM (SELECT "  ||
					"RPAD(cps.numcte,9,' '), RPAD(NVL(cps.numcredito, ''), 12, ' '), RPAD(cps.promocion,1,' '), RPAD(NVL(TO_CHAR(cps.fecha_inicio,'%m/%d/%Y'),''),10,' '), " ||
					"RPAD(NVL(TO_CHAR(cps.fecha_fin,'%m/%d/%Y'),''),10,' '), RPAD(cps.cod_retorno,1,' '), RPAD(cps.descripcion,1,' '), RPAD(cps.indicador_envio,1,' '), " ||
					"RPAD('',2,''), RPAD('',2,'') " ||
					" FROM " ||
					"bdicred:informix.sd_pf_compras_retencion cps where cps.promocion = '8' " ||
					"UNION " ||
					"SELECT "  ||
					"RPAD(srp.numcte,9,' '), RPAD(NVL(srp.numcredito, ''), 12, ' '), RPAD(srp.promocion,1,' '), RPAD(NVL(TO_CHAR(srp.fecha_inicio,'%m/%d/%Y'),''),10,' '), " ||
					"RPAD(NVL(TO_CHAR(srp.fecha_fin,'%m/%d/%Y'),''),10,' '), RPAD(srp.cod_retorno,1,' '), RPAD(srp.descripcion,1,' '), RPAD(srp.indicador_envio,1,' '), " ||
					"RPAD(srp.tasa,2,' '), RPAD(srp.plazo,2,' ') " ||
					" FROM " ||
					"bdicred:informix.sd_pf_saldo_retencion srp where srp.promocion = '9') ORDER BY 8;";
				end if;
			else
				--si es diferente solo realiza el de compras
				let vsSQL2 = "SELECT "  ||
					"RPAD(cps.numcte,9,' '), RPAD(NVL(cps.numcredito, ''), 12, ' '), RPAD(cps.promocion,1,' '), RPAD(NVL(TO_CHAR(cps.fecha_inicio,'%m/%d/%Y'),''),10,' '), " ||
					"RPAD(NVL(TO_CHAR(cps.fecha_fin,'%m/%d/%Y'),''),10,' '), RPAD(cps.cod_retorno,1,' '), RPAD(cps.descripcion,1,' '), RPAD(cps.indicador_envio,1,' '), " ||
					"RPAD('',2,''), RPAD('',2,'') " ||
					" FROM " ||
					"bdicred:informix.sd_pf_compras_retencion cps where cps.promocion = '8';";
			end if;
			--se genera nombre del archivo unl
			LET cRutaFinal  = '/informix/resplogifx/archivoscredito/'; --Ruta temporal
			LET sNombreArchivoFinal = cRutaFinal || 'datosprospectos_' || LPAD(YEAR(vFechaHoy),4,0) ||""|| LPAD(MONTH(vFechaHoy),2,0) ||""|| LPAD(DAY(vFechaHoy),2,0) ||'.unl';
			LET vsSQL1 = ' echo "UNLOAD TO ' || "'" || sNombreArchivoFinal || "'" || ' DELIMITER ' || '''|''';
			
			LET vsSQL3 = ' " > ' || cRutaFinal || 'Ejecutageneraarchivospf.sql';
			LET vsSQL = TRIM(vsSQL1) || ' '  || TRIM(vsSQL2) || ' ' || TRIM(vsSQL3);
				SYSTEM vsSQL;

			LET vsSQL = '';
			LET vsSQL = 'dbaccess bdicred ' || cRutaFinal || 'Ejecutageneraarchivospf.sql';
			SYSTEM vsSQL;
		
			LET vsSQL = '';
			LET vsSQL =  "rm " || cRutaFinal || "Ejecutageneraarchivospf.sql";
			SYSTEM vsSQL;
			
			
					
		else
			let vCodRet = '00002';
			return vCodRet;
		end if;
		--se ejecuta el sp sp_carga_datos_comp()
		EXECUTE PROCEDURE bdicred:"informix".sp_carga_datos_camp() INTO cretCarga;
		--se valida que se hayan creado los prospectos en la tabla sd_prospecto
		IF TRIM(cretCarga) <> '000000' THEN
		    LET vCodRet = '00001';
		    return vCodRet;
		ELSE
		   --en caso exitoso se borran datos de la tabla sd_pf_compras_retencion y/o en su caso sd_pf_saldo_retencion
		   delete from bdicred:"informix".sd_pf_compras_retencion cps where cps.promocion = '8';
		    if vDiaHoy = 20 then
		        delete from bdicred:"informix".sd_pf_saldo_retencion srp where srp.promocion = '9'; 
		    end if;
		END IF;
		
		--se termina el procedimiento
		RETURN vCodRet;
	end;

end procedure
DOCUMENT
"DESCRIPCION: Procedimiento para paso de prospectos de retencion de saldos (promocion =9) y compras (proimocion = 8 ",
"Codigo de retorno 00001 indica  que el procedimiento interno sp_carga_datos_camp retorno diferente de 00000",
"y 00002 indica que la fecha es obtenida como nula",
"Creado por Luis GermÃ¡n Viveros Andrade ",
"FOLIO: 833-CÃ©dula de retenciÃ³n.",
"FECHA: 15 de febrero de 2022";

CREATE PROCEDURE "informix".sp_inserta_bitacora_rentencion(
	pSucursal CHAR(4), 
	pEjecutivo CHAR(8), 
	pNumcte CHAR(9),
	pNumCredito CHAR(12),
	pFecha DATE, 
	pHoraIni CHAR(19), 
	pHoraFin CHAR (19), 
	pMotivo CHAR(50), 
	pEstatus CHAR(1),
	pMotivoCancelacion CHAR(4),
	pTipoRecompensa    CHAR(1),
	chAceptaRecompensa	CHAR(1)
)
RETURNING CHAR(5) AS codRet;
	-- VARIABLES --
	DEFINE vCodRet	CHAR(5);
	DEFINE iSqlErr 	  INTEGER; 
    DEFINE iIsamErr   INTEGER;
    DEFINE pAceptaRecompensa BOOLEAN;
	-- ASIGNACION DE VARIABLES --
	LET vCodRet    = '00000';
	LET iSqlErr    = 0;
	LET iIsamErr   = 0;
	LET pAceptaRecompensa = null;
	BEGIN	
		-- MANEJO DE EXCEPCIONES --
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN 
				LET vCodRet = iSqlErr;
				RETURN vCodRet;
			END IF;
		END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/sp_inserta_bitacora_rentencion.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pSucursal,'')) = '' OR TRIM(NVL(pEjecutivo,'')) = '' OR TRIM(NVL(pNumcte,'')) = '' OR pFecha IS NULL OR TRIM(NVL(pHoraIni,'')) = '' OR TRIM(NVL(pHoraFin,'')) = '' OR TRIM(NVL(pEstatus,'')) = '' THEN 
		LET vCodRet = '00001';
		RETURN vCodRet;
	ELSE
		IF pEstatus = '1' OR pEstatus = '2' THEN
			IF (TRIM(NVL(pNumCredito,'')) = '' OR TRIM(NVL(pMotivo,'')) = '') AND pEstatus = '1' THEN 
				LET vCodRet = '00001';
			ELSE
				if pMotivoCancelacion IS NULL OR pMotivoCancelacion = ''   then
					let pMotivoCancelacion = null;
				end if
				if pTipoRecompensa = '' OR  pTipoRecompensa IS NULL then
					let pTipoRecompensa = null;
				end if
				if chAceptaRecompensa = '' OR chAceptaRecompensa IS NULL OR 
				    (chAceptaRecompensa not in ('t', 'f')) then
				    let chAceptaRecompensa = null;
				end if
				
				INSERT INTO "informix".sd_bitacora_retencion(sucursal, ejecutivo, numcte, num_credito, fecha, hora_ini, hora_fin, motivo, estatus,
				motivo_cancelacion,tipo_recompensa, acepta_recompensa)
				VALUES(pSucursal, pEjecutivo, pNumcte, TRIM(NVL(pNumCredito,'')), pFecha, pHoraIni, pHoraFin, TRIM(NVL(pMotivo,'')), pEstatus,
				pMotivoCancelacion, pTipoRecompensa, chAceptaRecompensa);
			END IF;
		ELSE
			LET vCodRet = '00002';
		END IF;
	END IF;
	
	RETURN vCodRet;
	
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Alejandro Cordova Ramirez', 
'DESCRIPCION: Inserte registros en la tabla sd_bitacora_retencion, validando los parametros de entrada',
'Codigo de retorno 00001 indica que se ha enviado parametros de entrada invalido',
'Codigo de retorno 00002 indica que se ha enviado un status diferente de 1 y 2 , el cual es invalido',
'FECHA : 30/Septiembre/2021',
'BD    : BDICRED',
'SOLICITO: Abraham Narvaez',
'MODIFICADO: Luis GermÃ¡n Viveros Andrade, se agregan 3 campos al insert pMotivoCancelacion, pTipoRecompensa y pTipoRecompensa',
'FECHA: 22/02/2022';

CREATE PROCEDURE "informix".sp_inserta_saldo_compra_pf_retencion(
        pNumCliente CHAR(9), 
        pNumCredito CHAR(12), 
        pPromocion char(1), 
        pFechInicio DATE, 
        pFechFin DATE, 
        pCodRetorno CHAR(1),
        pDescripcion	 CHAR(1), 
        pIndicadorEnvio CHAR(1), 
        pTasa CHAR(2), 
        pPlazo CHAR(2)
    )
    RETURNING	CHAR(5) AS CodRet
    DEFINE cCodRet			CHAR(5);
    DEFINE sSqlErr			SMALLINT;
    DEFINE esExiste         INTEGER;
    DEFINE dicriminante     CHAR(1);
    DEFINE cveCliente       CHAR(9);
    LET cCodRet = '00000';
    LET sSqlErr			= 0;
    BEGIN
	
    
    ON EXCEPTION SET sSqlErr
       LET cCodRet = sSqlErr;
       RETURN cCodRet;
     END EXCEPTION;

    -- SET DEBUG FILE TO "/informix/SP_INSERTA_SALDO_COMPRA_PF_RETENCION.out";
    -- TRACE ON;

	SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3; 


 --verifico tipo de carga
        IF(pPromocion is null) then
            let cCodRet = '00001';
            return cCodRet;
        else
          --VALIDO ENTRADAS
            IF (TRIM(NVL(pNumCliente, '')) = '' or TRIM(NVL(pNumCredito, '')) = '' or TRIM(NVL(pFechInicio, '')) = '' or TRIM(NVL(pFechFin, '')) = '' or TRIM(NVL(pCodRetorno, '')) = '' or
             TRIM(NVL(pDescripcion, '')) = '' or TRIM(NVL(pIndicadorEnvio, '')) = '') then
                let cCodRet = '00001';
                return cCodRet;
            end if;
            if pPromocion = '8' then
                --valido la existencia previa en tabla
                select promocion into dicriminante from bdicred:"informix".sd_pf_compras_retencion where numcredito=pNumCredito limit 1;
	            LET esExiste = dbinfo("sqlca.sqlerrd2");
	            if esExiste = 0 then
                    --realizo la insercion a la tabla sd_pf_compras_retencion
                   INSERT INTO bdicred:"informix".sd_pf_compras_retencion(numcte, numcredito, promocion, fecha_inicio, fecha_fin, cod_retorno, 
                    descripcion, indicador_envio) values (pNumCliente, pNumCredito, pPromocion, pFechInicio, pFechFin, pCodRetorno,
                    pDescripcion, pIndicadorEnvio);
                 else
                   UPDATE bdicred:"informix".sd_pf_compras_retencion 
                   SET numcte=pNumCliente, numcredito=pNumCredito, fecha_inicio=pFechInicio, fecha_fin=pFechFin, cod_retorno=pCodRetorno, descripcion=pDescripcion, 
                   indicador_envio=pIndicadorEnvio 
                   where numcredito=pNumCredito;
                end if;
             
            else
                IF(TRIM(NVL(pTasa, '')) = '' OR TRIM(NVL(pPlazo, '')) = '') then
                    let cCodRet = '00001';
                    return cCodRet;
                end if;
                 select promocion into dicriminante from bdicred:"informix".sd_pf_saldo_retencion where numcredito=pNumCredito limit 1;
                LET esExiste = dbinfo("sqlca.sqlerrd2");
                if esExiste = 0 then
                    INSERT INTO bdicred:"informix".sd_pf_saldo_retencion(numcte, numcredito, promocion, fecha_inicio, fecha_fin, cod_retorno, 
                    descripcion, indicador_envio, tasa, plazo) values (pNumCliente, pNumCredito, pPromocion, pFechInicio, pFechFin, pCodRetorno,
                    pDescripcion, pIndicadorEnvio, pTasa, pPlazo);
                 else
                    UPDATE bdicred:"informix".sd_pf_saldo_retencion 
                    SET numcte=pNumCliente, numcredito=pNumCredito, fecha_inicio=pFechInicio, fecha_fin=pFechFin, cod_retorno=pCodRetorno, 
                        descripcion=pDescripcion, indicador_envio=pIndicadorEnvio, tasa=pTasa, plazo=pPlazo 
                    where numcredito = pNumCredito;
                end if;
            end if;
        end if;
        return cCodRet;
    end;
END PROCEDURE
DOCUMENT
"Procedimiento para insertar los saldos (promocion =9) y compras (proimocion = 8)",
"Creado por Luis GermÃ¡n Viveros Andrade ",
"DESCRIPCION: PROCEDIMIENTO 	QUE INSERTA DAOTS DE COMPRA O SALDO EN LA TABLA SD_PF_COMPRAS_RETENCION",
"FECHA: 11-02-2022";

CREATE PROCEDURE "informix".sp_libera_cupones_retencion()
   RETURNING CHAR(5) as cCodRet;

-- Declaracion de variables 
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
    DEFINE vNumCte 			CHAR(9);
    DEFINE vSucursal 	    CHAR(4);
    DEFINE vEjecutivo 	    CHAR(8);
    DEFINE vFecha 			DATE; 
    DEFINE vMotivo 			CHAR(4);
    DEFINE vFolio 			CHAR(20);

    DEFINE vExiste           INTEGER;
	

	 LET cCodRet			  = '00000';
	 LET iSqlErr			  = 0;
     LET vNumCte              = '';
     LET vSucursal            = '';
     LET vEjecutivo           = '';
     LET vFecha               = '';
     LET vMotivo              = '';
     LET vFolio               = '';
     LET vExiste              = 0;
						
BEGIN  -- // MANEJADOR DE ERRORES //
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  

-- // ACTUALIZACION DE CUPONES //
              UPDATE bdicred:"informix".sd_cupones_retencion
              SET cliente = NULL  where   cliente is not null 
                  and sucursal is null
                  and ejecutivo is null
                  and fecha is null
                  and motivo is null;

	  RETURN cCodRet;
		
END;
END PROCEDURE

--'AUTOR : 98699921 - Abdon Obed Hernandez',
--'DESCRIPCION: SP que libera los cupones.',
--'FOLIO: 833-Cedula de Retencion',
--'FECHA : 04/02/2022',	
--'BD: BDICRED',;

CREATE PROCEDURE "informix".sp_oferta_recompensas_retencion (
	pEmpresa CHAR(3),
	pNumCte CHAR(9),
	pMotivoCancelacion  CHAR(4),
	pSemaforo  CHAR(1)
	)
RETURNING CHAR(5) AS codRet, SMALLINT as idTipoRecompensa, CHAR(20) as descripcionTipoRecompensa, CHAR(100) as descripcionRecompensa,
		money(14,2) as monto, CHAR(12) as idPlantilla, INTEGER as idCupon, CHAR(50) as tipoCupon,
		CHAR(20) as folio, DATE as vigencia,CHAR(120) as instrucciones,CHAR(4) as empresaCoppel, 
		CHAR(50) as url, CHAR(1) as promocion,CHAR(2) as plazo,CHAR(2)as tasa

--Variables para el manejo de errores
DEFINE iSqlErr 	  					INTEGER;  
DEFINE iIsamErr   					INTEGER;
-- Retorno general
DEFINE codRet 						CHAR(5);
DEFINE idTipoRecompensa 			SMALLINT;
DEFINE descripcionTipoRecompensa 	CHAR(20);
DEFINE descripcionRecompensa 		CHAR(100);DEFINE monto 						MONEY(14,2);DEFINE idPlantilla 					CHAR(12);DEFINE idCupon 						INTEGER;
DEFINE tipoCupon 					CHAR(50); --Tiempo aire, Dinero electronic etc
DEFINE folio 						CHAR(20);DEFINE vigencia 					DATE;DEFINE instrucciones 				CHAR(120);
DEFINE empresaCoppel 				CHAR(4);
DEFINE url 							CHAR(50);
--Retornos exclusivos pagos fijos
DEFINE promocion 					CHAR(1);
DEFINE plazo 						CHAR(2);
DEFINE tasa 						CHAR(2);
--Variables internas  
DEFINE ctesCount 				INTEGER;
DEFINE idDetalleCupon		 	INTEGER;
DEFINE idDetalleBonificacion 	INTEGER;
DEFINE idDetallePagoFijo 		INTEGER;
DEFINE mesesPromoRec 			CHAR(2);
DEFINE pNumCteBonificado		INTEGER;
DEFINE bonificacionesEnPeriodo	INTEGER;
DEFINE fechaHoy					DATE;
DEFINE nrowsupdate     			INTEGER;


BEGIN	
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN 
			LET codRet = iSqlErr;
			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_aplica_bonificacion_retencion"".out";     
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 

	-- Inicializacion de variables
	LET codRet = '00000';
	LET idTipoRecompensa = null;
	LET descripcionTipoRecompensa = '';
	LET descripcionRecompensa = '';
	LET monto = null;
	LET idPlantilla = '';
	LET idCupon =null;
	LET tipoCupon='';
	LET folio='';
	LET vigencia = null;
	LET instrucciones ='';
	LET empresaCoppel ='';
	LET url ='';
	LET promocion ='';
	LET plazo ='';
	LET tasa  ='';
	--inicializar variables de proceso
	LET idDetalleCupon = null;
	LET idDetalleBonificacion = null;
	LET idDetallePagoFijo = null;
	LET mesesPromoRec = '';

	--Valida de parametros 
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pMotivoCancelacion,'') = ''  OR NVL(pSemaforo,'') = ''
	 then 
		LET codRet = "00001";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
	END IF;
	-->Inicia Logica de SP
	-- inicia Validaciones de negocio -->V0002 creacion de bloque de validacion
	-- Se valida que el cliente exista 
	select numcte into pNumCte from bdinteg:si_cliente where empresa=pEmpresa and numcte=pNumCte;
	LET ctesCount = dbinfo("sqlca.sqlerrd2");
	if ctesCount = 0 then 
		LET codRet = "00002";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
	end if;
	-- Se valida que la recompensa buscada exista 
	select  tipo_recompensa, id_detalle_cupon, id_detalle_bonificacion, id_detalle_pago_fijo    
	INTO    idTipoRecompensa, idDetalleCupon, idDetalleBonificacion, idDetallePagoFijo
	from sd_recompensas_retencion  where  motivo_cancelacion = pMotivoCancelacion and semaforo = pSemaforo;
	if NVL(idTipoRecompensa,'')='' or idTipoRecompensa=0 then
		LET codRet = "00003";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;	
	end if;
	-- Se consulta la fecha actual del sistema 
	select fecha_hoy INTO fechaHoy from sd_fechas where empresa ='001';
	-- Se consulta el numero meses del periodo en el que el cliente no debe de tener una recompensa aceptada 
	select TRIM(valor) INTO mesesPromoRec from sd_param where empresa=pEmpresa and cod_param='VRR';
	if NVL(mesesPromoRec,'') = ''  THEN
		LET codRet = "00004";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;	
	end if;
	-- Se valida que no tenga una recompensa aceptada en un periodo de tiempo parametrizado 
	select numcte into pNumCteBonificado  from sd_bitacora_retencion 
	where numcte=pNumCte and fecha BETWEEN ADD_MONTHS(fechaHoy,cast(('-'||mesesPromoRec) as integer)) and fechaHoy and acepta_recompensa ='t' limit 1;
	LET bonificacionesEnPeriodo = dbinfo("sqlca.sqlerrd2");
	if bonificacionesEnPeriodo > 0 THEN
		LET codRet = "00005";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
	end if;
	-- Se valida que el tipo de recompensa exista y este configurado correctamente 
	select descripcion INTO descripcionTipoRecompensa from sd_tipos_recompensas_retencion where tipo_recompensa = idTipoRecompensa;																																	  
	if NVL(descripcionTipoRecompensa,'') = '' THEN
		LET codRet = "00006";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
	end if;
	if  (idTipoRecompensa not in (1,2,3)) or 
		(idTipoRecompensa = 1 and NVL(idDetalleCupon,'') ='' ) or 
		(idTipoRecompensa = 2 and NVL(idDetalleBonificacion,'') ='') or 
		(idTipoRecompensa = 3 and NVL(idDetallePagoFijo,'')='') then 
		LET codRet = "00006";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
	end if	
	-->Termina Validaciones de negocio
	
	-- 1->Flujo de acuerdo al tipo de recompensa -->V0002 creacion de flujo
	if  idTipoRecompensa = 1  THEN
	-- 1.1 -> LA RECOMPENSA ES CUPON
		-- Se consulta la existencia de la configuracion del cupon 
		select sdcr.descripcion as descripcionRecompensa, sdcr.monto, sdcr.idplantilla, 
			stcr.descripcion, stcr.instrucciones, stcr.empresa_coppel, stcr.url
		INTO descripcionRecompensa, monto, idPlantilla,
			tipoCupon, instrucciones, empresaCoppel,url
		from sd_detalle_cupones_retencion sdcr
		inner join sd_tipos_cupones_retencion stcr on sdcr.id_tipo_cupon = stcr.id_tipo_cupon 
		where id_detalle_cupon = idDetalleCupon;
		
		-- se valida que exista la configuracion sd_detalle_cupones_retencion -> sd_tipos_cupones_retencion 
		if NVL(descripcionRecompensa,'') = '' THEN
			LET codRet = "00006";
			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
			folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		end if;
		
		--se consulta que exista disponible un cupon 
		select min(scr.id_cupon) INTO idCupon from sd_cupones_retencion scr where scr.id_detalle_cupon = idDetalleCupon and scr.cliente is null and scr.vigencia>=fechaHoy;		
		-- se valida que exista disponible un cupon  
		if NVL(idCupon,'') = '' THEN
			LET codRet = "00007";
			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
			folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		end if; 
				
		--Si todo va bien se obtiene aparta el cupon y se obtienen los datos adicionales
		update sd_cupones_retencion set cliente = pNumCte where id_cupon= idCupon and cliente is null;
		--Se valida que en el tiempo en el que se consulta y realiza el update no le hayan ganado el cupon si es asi se manda 00007 repita el proceso
		LET nrowsupdate = dbinfo("sqlca.sqlerrd2");
		IF nrowsupdate = 0 THEN
		    LET codRet = "00007";			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
			folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		end if;
		--consultar el folio asignado 
		select scr.folio,scr.vigencia INTO folio,vigencia from sd_cupones_retencion scr where id_cupon=idCupon; 	
	elif idTipoRecompensa = 2 THEN
	-- 1.2 -> LA RECOMPENSA ES BONIFICACION
		-- se consulta que exista el detalle de bonificacion 
		select sdbr.monto, sdbr.descripcion, sdbr.idplantilla 
		into monto, descripcionRecompensa, idPlantilla
		from sd_detalle_bonificaciones_retencion sdbr where id_detalle_bonificacion = idDetalleBonificacion;
		-- se valida que exista informacion  
		if trim(NVL(descripcionRecompensa,'')) = '' THEN
			LET codRet = "00006";
			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
			folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		end if;		
	elif idTipoRecompensa = 3 THEN  
	-- 1.3 -> LA RECOMPENSA ES PAGOS FIJOS
		-- se consulta que exista el detalle de la promocion de pagos fijos  
		select  sdpfr.promocion, sdpfr.descripcion, sdpfr.plazo, sdpfr.tasa, sdpfr.idplantilla 
		into promocion, descripcionRecompensa, plazo, tasa, idPlantilla		
		from sd_detalle_pagos_fijos_retencion sdpfr where id_detalle_pago_fijo=idDetallePagoFijo;
		--se valida que se encuentre la informacion 
		if trim(NVL(descripcionRecompensa,'')) = '' THEN
			LET codRet = "00006";
			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
			folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		end if;	
		
	end if;
	
	-->Termina Logica de SP	
	RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
	folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Alejandro Rodriguez Martinez', 
'DESCRIPCION: Valida la recompensa que le corresponde al cliente al intentar cancelar su credito',
'Codigo de retorno 00001 indica que se ha enviado parametros de entrada invalidos',
'Codigo de retorno 00002 No se encontro el cliente',
'Codigo de retorno 00003 El cliente no tiene recompensas disponibles',
'Codigo de retorno 00004 No se encuentra el parametro de periodo de bonificaciones VRR',
'Codigo de retorno 00005 El cliente cuenta con una bonificacion en el periodo parametrizado (actualmente 12 anteriores a la nueva validacion)',
'Codigo de retorno 00006 Se encuentra un problema en la configuracion de recompensas ',
'Codigo de retorno 00007 Para la parte de cupon, No se encontro un cupon disponible',
'FECHA : 03/Marzo/2022',
'BD    : BDICRED',
'FOLIO: 833 - Adendum RQM 10 1405 CÃ©lula de RetenciÃ³n TDC',
'MODIFICADO: Alejandro Rodriguez Martinez se agrego la parte de validaciones de negocio y creacion de flujo de acuerdo al tipo de recompensa. Etiqueta: V0002',
'FECHA: 07/Marzo/2022',
'MODIFICADO: Alejandro Rodriguez Martinez se cambio la longitud del parametro de salida instrucciones de 100 a 120 ',
'FECHA: 24/Marzo/2022';

CREATE PROCEDURE "informix".sp_repdiarioretencion()
    RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;
    ---DECLARACIONES
		DEFINE iSqlErr			    INTEGER;
		DEFINE iIsamErr				INTEGER;
		DEFINE cTabla		      	CHAR(1);
		DEFINE v_empresa            CHAR(3);
		DEFINE cProceso             CHAR(4);
		DEFINE cCodRet,vvcCod_ret	CHAR(6);
		DEFINE cMensajeRet          CHAR(80);
		DEFINE cNombreArchivo       CHAR(80);
		DEFINE cRuta			    CHAR(80);
		DEFINE cConsulta		  	CHAR(2200);
		DEFINE cSql           		CHAR(1024);
		DEFINE dtFechaHoy           DATE;
		--DEFINE conDatos             INTEGER;
		---INICIALIZACIONES
		LET iSqlErr         = 0;   
		LET iIsamErr        = 0; 
		LET cCodRet         = "000000";
		LET cMensajeRet	    = "Proceso exitoso";
		LET cNombreArchivo 	= "Clientesretenidos_";   
		LET cTabla	        = "N"; 
		LET cConsulta		= ""; 
		LET cSql	        = ""; 
		LET cRuta	        = "";
		LET v_empresa       = '001';
		LET dtFechaHoy      = "";
		-- conDatos        = 0;
		
		BEGIN
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

--		SET DEBUG FILE TO "/informix/German/sp_repDiarioRetencion.out";
--		TRACE ON;
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		--IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallerepdiario" AND dbsname= "bdicred" AND partnum >1048577) THEN
		IF (SELECT COUNT(tabname) FROM sysmaster:systabnames WHERE tabname = "tmp_detallerepdiario" AND dbsname= "bdicred" AND partnum >1048577) > 0 THEN
			DROP  TABLE tmp_detallerepdiario;
		END IF;	
		
		--SE OBTIENE LA RUTA DE SI_PARAM.
        SELECT valor 
		INTO cRuta
		FROM bdinteg:"informix".si_param 
		WHERE cod_param = 503;
        --SE DEFINE EL NOMBRE DEL ARCHIVO EXCEL
        LET  cRuta = "/RESPALDOS" || cRuta || '/';
         --LET  cRuta = '/informix/resplogifx/archivoscredito/';

		--DETERMINACION DE FECHA CORTE:
		SELECT fecha_hoy
		  INTO dtFechaHoy
		  FROM bdicred:"informix".sd_fechas
          WHERE empresa = v_empresa;
		
        select distinct(trim(sic.nombre1) || ' ' || trim(sic.nombre2) || ' ' || trim(sic.apell_paterno) || ' ' || trim(sic.apell_materno)) nombre
            , sdbr.numcte numcte, sdbr.num_credito numcredito, sdbr.motivo_cancelacion motivo, sit.telefono celular, sico.correo_elec correo, 
            (to_char(sdbr.fecha,  '%d/%m/%y') ||' '||sdbr.hora_fin) fechahora
        from sd_bitacora_retencion sdbr, bdinteg: si_cliente sic, bdinteg: si_telefonos_actual sit,
            bdinteg:si_correos sico
        where sdbr.numcte = sic.numcte 
        and sic.numcte = sit.numcte 
        and sic.numcte = sico.numcte
        and sit.tipo_tel = 2
        and sdbr.acepta_recompensa = 't'
        and sdbr.fecha = dtFechaHoy
        into tmp_detallerepdiario; 
        
        --SE VALIDA QUE LA TABLA TEMPORAL SE HAYA CARGADO CON LOS DATOS
       -- select count(*) 
        --into conDatos
        --from tmp_detallerepdiario;
        
       -- if conDatos > 0 then
            LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
            LET cConsulta = "SELECT nombre, numcte, numcredito, motivo, celular, correo, fechahora FROM tmp_detallerepdiario";		
            LET cSql = '';
            LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
            --LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta);
            SYSTEM TRIM(cSql);
            
            LET cSql = '';
            LET cSql = "dbaccess bdicred " ||TRIM(cRuta)||'query1.sql';
            SYSTEM cSql;
            LET cSql = '';
            LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';	
            SYSTEM cSql; 
            --let cTabla = 'S';
		--else
		  --  let cCodRet = '00001';
		  --  let cMensajeRet = 'NO HAY DATOS GENERADOS ESTE DIA ' + dtFechaHoy;
		    --return cCodRet, cMensajeRet;
		--end if;
		IF cTabla="S" THEN
				DROP TABLE bdicobranza:"informix".tmp_detallerepdiario;
		END IF;
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';
		
    RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
"Procedimiento para generacion de archivo excel con recompensas aceptadas cedula de retencion",
"Creado por Luis GermÃ¡n Viveros Andrade 2022-02-22";

CREATE PROCEDURE "informix".respaldacredito()
   RETURNING CHAR(5);   --CodRet
                                                                                
                                                                                
   DEFINE CodRet              CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);
   --AAME INC 27 108
   DEFINE cnumcredito             CHAR(20);
                                                                                
   DEFINE wSecuenciaPago      LIKE sd_secpago.secuencia;                        
                                                                                
   DEFINE GLOBAL g_Empresa    CHAR(3)  DEFAULT ' ';                             
   DEFINE GLOBAL g_NumCredito CHAR(20) DEFAULT ' ';                             
   DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';                             
                                                                                
   LET CodRet = "000";  
	--AAME INC 27 108   
   LET cnumcredito = '';
   
   	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ; 
	
	
   SELECT MAX(secuencia)                                                        
     INTO wSecuenciaPago                                                        
     FROM sd_secpago                                                            
    WHERE empresa = g_Empresa                                                   
      AND num_credito = g_NumCredito; 

--set debug file to "respaldacredito.out";
--trace on;
  
                                                                                
   IF(wSecuenciaPago = 0 OR wSecuenciaPago IS NULL) THEN                        
      LET wSecuenciaPago = 0;                                                   
   END IF;                                                                      
                                                                                
   LET wSecuenciaPago = wSecuenciaPago + 1;                                     
	--AAME INC 27 108 Se agrega validacion para que inserte siempre y cuando no se tenga ya el respaldo del folio a consultar
	SELECT count(num_credito) INTO cnumcredito FROM "informix".sd_secpago WHERE num_credito = g_NumCredito AND folio_suc = g_Folio;
	IF cnumcredito = 0 THEN
	   INSERT INTO                                                                  
		  sd_secpago (empresa, num_credito, folio_suc, secuencia)                   
	   VALUES                                                                       
		  (g_empresa, g_NumCredito, g_Folio, wSecuenciaPago);                       
																			
	-------------------------------------------------------                         
	--    RESPALDO DE MAECRED                            --                         
	-------------------------------------------------------                         
	   INSERT INTO                                                                  
		  sd_maecredrev                                                             
			(empresa,                                                               
			 num_credito,                                                           
			 folio,                                                                 
			 num_producto,                                                          
			 ejecutivo,                                                             
			 numcte,                                                                
			 divisa,                                                                
			 sucursal,                                                              
			 id_origen,                                                             
			 origen,                                                                
			 cod_tipo_linea,                                                        
			 cod_linea,                                                             
			 porc_rec_prop,                                                         
			 status_cred,                                                           
			 bandera_renovac,                                                       
			 bandera_prorroga,                                                      
			 periodo_plazo,                                                         
			 plazo,                                                                 
			 fecha_apertura,                                                        
			 fecha_vencim,                                                          
			 period_pago_cap,                                                       
			 period_pag_int,                                                        
			 dias_trasp_cap,                                                        
			 dias_trasp_int,                                                        
			 tasa_fija_o_var,                                                       
			 cod_tasa_base,                                                         
			 factor_sobretasa,                                                      
			 sobretasa,                                                             
			 tasa_interes,                                                          
			 cod_tasa_mora,                                                         
			 sobretasa_mora,                                                        
			 fact_sobret_mora,                                                      
			 tasa_moratorios,                                                       
			 fecha_pago_cap,                                                        
			 fecha_pago_int,                                                        
			 es_fisica,                                                             
			 bandera_fi_fo,                                                         
			 codigo_pro,                                                            
			 superficie,                                                            
			 actividad,                                                             
			 cal_edos_fin,                                                          
			 tipo_calculo,                                                          
			 admite_tlp,                                                            
			 rel_garcred,                                                           
			 id_unidad_prod,                                                        
			 num_aper_ant,                                                          
			 rev_tasa_var_per,                                                      
			 dia_para_revisar,                                                      
			 cod_prod,                                                              
			 bandera_ministra,                                                      
			 num_fideicomiso,                                                       
			 credito_externo,                                                       
			 gracia_capital,                                                        
			 diferimiento_int,                                                      
			 fecha_fin_prorrateo,                                                   
			 campo_trab1,                                                           
			 campo_trab2,                                                           
			 campo_trab3,                                                           
			 campo_trab4,                                                           
			 calificacion_riesgo,                                                   
			 cod_agricola,                                                          
			 tasa_base_piso,                                                        
			 sobretasa_piso,                                                        
			 factor_piso,                                                           
			 tasa_piso,                                                             
			 tasa_base_techo,                                                       
			 sobretasa_techo,                                                       
			 factor_techo,                                                          
			 tasa_techo,
			 cod_caract,
			 cod_caract_2
			 ,cuenta_clabe)                                                            
	   SELECT                                                                       
			empresa,                                                                
			 num_credito,                                                           
			 g_folio,                                                               
			 num_producto,                                                          
			 ejecutivo,                                                             
			 numcte,                                                                
			 divisa,                                                                
			 sucursal,                                                              
			 id_origen,                                                             
			 origen,                                                                
			 cod_tipo_linea,                                                        
			 cod_linea,                                                             
			 porc_rec_prop,                                                         
			 status_cred,                                                           
			 bandera_renovac,                                                       
			 bandera_prorroga,                                                      
			 periodo_plazo,                                                         
			 plazo,                                                                 
			 fecha_apertura,                                                        
			 fecha_vencim,                                                          
			 period_pago_cap,                                                       
			 period_pag_int,                                                        
			 dias_trasp_cap,                                                        
			 dias_trasp_int,                                                        
			 tasa_fija_o_var,                                                       
			 cod_tasa_base,                                                         
			 factor_sobretasa,                                                      
			 sobretasa,                                                             
			 tasa_interes,                                                          
			 cod_tasa_mora,                                                         
			 sobretasa_mora,                                                        
			 fact_sobret_mora,                                                      
			 tasa_moratorios,                                                       
			 fecha_pago_cap,                                                        
			 fecha_pago_int,                                                        
			 es_fisica,                                                             
			 bandera_fi_fo,                                                         
			 codigo_pro,                                                            
			 superficie,                                                            
			 actividad,                                                             
			 cal_edos_fin,                                                          
			 tipo_calculo,                                                          
			 admite_tlp,                                                            
			 rel_garcred,                                                           
			 id_unidad_prod,                                                        
			 num_aper_ant,                                                          
			 rev_tasa_var_per,                                                      
			 dia_para_revisar,                                                      
			 cod_prod,                                                              
			 bandera_ministra,                                                      
			 num_fideicomiso,                                                       
			 credito_externo,                                                       
			 gracia_capital,                                                        
			 diferimiento_int,                                                      
			 fecha_fin_prorrateo,                                                   
			 campo_trab1,                                                           
			 campo_trab2,                                                           
			 campo_trab3,                                                           
			 campo_trab4,                                                           
			 calificacion_riesgo,                                                   
			 cod_agricola,                                                          
			 tasa_base_piso,                                                        
			 sobretasa_piso,                                                        
			 factor_piso,                                                           
			 tasa_piso,                                                             
			 tasa_base_techo,                                                       
			 sobretasa_techo,                                                       
			 factor_techo,                                                          
			 tasa_techo,         
			 cod_caract,
			 cod_caract_2  
			 ,cuenta_clabe			 
	   FROM                                                                         
		sd_maecred                                                                  
	   WHERE                                                                        
		 num_credito = g_NumCredito                                                 
	   AND                                                                          
		 empresa = g_Empresa;                                                       
																					
	----------------------------------------------------------                      
	--            RESPALDO DE MAESDOS                                               
	----------------------------------------------------------                      
	   INSERT INTO                                
		  sd_maesdosrev                           
			 (empresa,                            
			  num_credito,                        
			  folio,                              
			  fecha_ult_mov,                      
			  sdo_int_anticip,                    
			  sdo_int_ant_dev,                    
			  sdo_intereses,                      
			  sdo_dia_ant_int,                    
			  sdo_mes_ant_int,                    
			  sdo_acum_mes_int,                   
			  sdo_retenido,                       
			  sdo_acum_cap_int,                   
			  sdo_exig_int,                       
			  sdo_no_exig,                        
			  provision_normal,                                                     
			  dias_acum_int,                                                        
			  sdo_moratorio,                                                        
			  sdo_dia_ant_mor,                                                      
			  sdo_mes_ant_mor,                                                      
			  sdo_contab_mora,                                                      
			  dias_acum_mora,                                                       
			  sdo_capital,                                                          
			  sdo_cap_insoluto,                                                     
			  sdo_dia_ant_cap,                                                      
			  sdo_mes_ant_cap,                                                      
			  sdo_acum_mes_cap,                                                     
			  mto_capitalizado,                                                     
			  mto_ministra_cap,                                                     
			  cargos_dia_cap,                                                       
			  abonos_dia_cap,                                                       
			  cargos_mes_cap,                                                       
			  abonos_mes_cap,                                                       
			  dias_acum_cap,                                                        
			  monto_vencido,                                                        
			  mto_venc_trasp,                                                       
			  monto_financiado,                                                     
			  monto_reservado,                                                      
			  sdo_acum_vencido,                                                     
			  dias_acum_intper,                                                     
			  sdo_global_int,                                                       
			  sdo_acum_intper,                                                      
			  monto_otorgado,                                                       
			  provi_venc_normal,                                                    
			  provi_venc_anticip,                                                   
			  cap_tras_no_venci,                                                    
			  mto_venc_int,                                                         
			  mto_venc_tra_int,                                                     
			  mto_finan_vdo,                                                        
			  mto_reser_int,                                                        
			  mto_fin_ven_trasp,                                                    
			  mto_fin_vig_trasp,                                                    
			  int_tra_no_exig,                                                      
			  sdo_trab4,
			  act)                                                            
	   SELECT                                                                       
			  empresa,                                                              
			  num_credito,                                                          
			  g_Folio,                                                              
			  fecha_ult_mov,                                                        
			  sdo_int_anticip,                                                      
			  sdo_int_ant_dev,                                                      
			  sdo_intereses,                                                        
			  sdo_dia_ant_int,                                                      
			  sdo_mes_ant_int,                                                      
			  sdo_acum_mes_int,                                                     
			  sdo_retenido,                                                         
			  sdo_acum_cap_int,                                                     
			  sdo_exig_int,                                                         
			  sdo_no_exig,                                                          
			  provision_normal,                                                     
			  dias_acum_int,                                                        
			  sdo_moratorio,                                                        
			  sdo_dia_ant_mor,                                                      
			  sdo_mes_ant_mor,                                                      
			  sdo_contab_mora,                                                      
			  dias_acum_mora,                                                       
			  sdo_capital,                                                          
			  sdo_cap_insoluto,                                                     
			  sdo_dia_ant_cap,                                                      
			  sdo_mes_ant_cap,                                                      
			  sdo_acum_mes_cap,                                                     
			  mto_capitalizado,                                                     
			  mto_ministra_cap,                                                     
			  cargos_dia_cap,                                                       
			  abonos_dia_cap,                                                       
			  cargos_mes_cap,                                                       
			  abonos_mes_cap,                                                       
			  dias_acum_cap,                                                        
			  monto_vencido,                                                        
			  mto_venc_trasp,                                                       
			  monto_financiado,                                                     
			  monto_reservado,                                                      
			  sdo_acum_vencido,                                                     
			  dias_acum_intper,                                                     
			  sdo_global_int,                                                       
			  sdo_acum_intper,                                                      
			  monto_otorgado,                                                       
			  provi_venc_normal,                                                    
			  provi_venc_anticip,                                                   
			  cap_tras_no_venci,                                                    
			  mto_venc_int,                                                         
			  mto_venc_tra_int,                                                     
			  mto_finan_vdo,                                                        
			  mto_reser_int,                                                        
			  mto_fin_ven_trasp,                                                    
			  mto_fin_vig_trasp,                                                    
			  int_tra_no_exig,                                                      
			  sdo_trab4,
			  act                                                           
	   FROM sd_maesdos                                                              
	   WHERE empresa     = g_Empresa                                                
	   AND num_credito = g_NumCredito;                                              
																					
																					
	-------------------------------------                                           
	-- Inicia respaldo de sd_pagocapit --                                           
	-------------------------------------                                           
	   INSERT INTO                                                                  
		  sd_pagocapitrev                                                           
			 (empresa,                                                              
			  num_credito,                                                          
			  folio,                                                                
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  saldo_cuota,                                                          
			  imp_capitalizado,                                                     
			  factor_ajuste,                                                        
			  monto_real_pag,                                                       
			  fecha_pago,                                                           
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorios,                                                      
			  status_moratorio,                                                     
			  num_pagares,                                                          
			  porc_pago,                                                            
			  bandera_ministra,                                                     
			  status_cuota)                                                         
	   SELECT                                                                       
			  empresa,                                                              
			  num_credito,                                                          
			  g_Folio,                                                              
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  saldo_cuota,                                                          
			  imp_capitalizado,                                                     
			  factor_ajuste,                                                        
			  monto_real_pag,                                                       
			  fecha_pago,                                                           
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorios,                                                      
			  status_moratorio,                                                     
			  num_pagares,                                                          
			  porc_pago,                                                            
			  bandera_ministra,                                                     
			  status_cuota                                                          
	   FROM                                                                         
			 sd_pagocapit                                                           
	   WHERE                                                                        
			 empresa = g_Empresa                                                    
	   AND                                                                          
			 num_credito = g_NumCredito;                                            
																					
																					
	-------------------------------------                                           
	--Inicia Respaldo de sd_paginter   --                                           
	-------------------------------------                                           
	   INSERT INTO                                                                  
		  sd_paginterrev                                                            
			 (empresa,                                                              
			  num_credito,                                                          
			  folio,                                                                
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  monto_real_pag,                                                       
			  fecha_pag,                                                            
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorio,                                                       
			  status_moratorio,                                                     
			  bonifi_int_mora,                                                      
			  porc_pago,                                                            
			  status_cuota,                                                         
			  monto_financiado)                                                     
	   SELECT                                                                       
			  empresa,                                                              
			  num_credito,                                                          
			  g_Folio,                                                              
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  monto_real_pag,                                                       
			  fecha_pag,                                                            
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorio,                                                       
			  status_moratorio,                                                     
			  bonifi_int_mora,                                                      
			  porc_pago,                                                            
			  status_cuota,                                                         
			  monto_financiado                                                      
	   FROM                                                                         
			  sd_paginter                                                           
	   WHERE                                                                        
			  empresa = g_Empresa                                                   
	   AND                                                                          
			  num_credito = g_NumCredito;                                           
	-----------------------------------                                             
	-- Inicia Respaldo de sd_detmora --                                             
	-----------------------------------                                             
	   {INSERT INTO                                                                 
		  sd_detmorarev                                                             
			  (empresa, num_credito, folio, fecha_cuota, identifi_rec,              
			   sdo_acum_mes_mora, tasa_ordinaria, provi_mora_ordi,                  
			   tasa_copete, provi_mora_cope, sdo_mora_ordi, sdo_mora_cope)          
	   SELECT                                                                       
			   empresa, num_credito, g_Folio, fecha_cuota, identifi_rec,            
			   sdo_acum_mes_mora, tasa_ordinaria, provi_mora_ordi, tasa_copete,     
			   provi_mora_cope, sdo_mora_ordi, sdo_mora_cope                        
		 FROM sd_detmora                                                            
		WHERE empresa = g_Empresa                                                   
		 AND num_credito = g_NumCredito;        
	-----------------------------------                                             
	-- Inicia Respaldo de sd_detcomi --                                             
	-----------------------------------                                             
			INSERT INTO sd_detcomirev                                               
					(empresa, folio, cod_comis, num_credito, fecha_alta, secuencia, 
					 fecha_pago, monto_com, monto_pag, apli_factor,                 
					 estado_com, num_solicitud, user_insert, fecha_insert)          
			SELECT empresa, g_Folio, cod_comis, num_credito, fecha_alta, secuencia, 
					 fecha_pago, monto_com, monto_pag, apli_factor,                 
					 estado_com, num_solicitud, user_insert, fecha_insert           
			 FROM sd_detcomi                                                        
			WHERE empresa = g_Empresa                                               
			  AND num_credito = g_NumCredito;  }                                    
																					
	----------------------------------------                                        
	-- Inicia Respaldo de sd_maecredanexo --                                        
	----------------------------------------                                        
	INSERT INTO sd_maecredanexorev                                                  
			(empresa,              num_credito,         folio,                    
			 dia_corte,            dias_gracia_mora,    tp_dias_calc_mora,
			 dias_fecha_max_pago,  tp_dias_fecha_pago,  cod_tasa_base_cte,
			 factor_sobretasa_cte, sobretasa_cte,       tasa_interes_cte,
			 fecha_vencto,         prox_fecha_pago,     fecha_proceso, 
			 fecha_ult_pago  )
	SELECT empresa,              num_credito,         g_Folio,                      
		   dia_corte,            dias_gracia_mora,    tp_dias_calc_mora,
		   dias_fecha_max_pago,  tp_dias_fecha_pago,  cod_tasa_base_cte,
		   factor_sobretasa_cte, sobretasa_cte,       tasa_interes_cte,
		   fecha_vencto,         prox_fecha_pago,     fecha_proceso, 
		   fecha_ult_pago  
	  FROM sd_maecredanexo                                                          
	 WHERE empresa = g_Empresa                                                      
	   AND num_credito = g_NumCredito;                                              
	-----------------------------------                                             
	-- Inicia Respaldo de sd_escrow --                                              
	-----------------------------------                                             
	{       INSERT INTO sd_escrowrev                                                
					(empresa, num_credito, folio, fecha_venc_seg, cod_comis,        
					 monto_poliza, monto_mensual, plazo, saldo, texto)              
			SELECT empresa, num_credito, g_Folio, fecha_venc_seg, cod_comis,        
					 monto_poliza, monto_mensual, plazo, saldo, texto               
			 FROM sd_escrow                                                         
			WHERE empresa = g_Empresa                                               
			  AND num_credito = g_NumCredito;                                       
	}                                                                               
																					
	-- ---------------------------------------------------------------------        


	---------------------------------------------
	--Inicia Respaldo de sd_amortiza_credito --
	---------------------------------------------
	INSERT INTO sd_amortiza_creditorev(
		   empresa                ,
		   folio                  ,
		   num_credito            ,
		   fecha_cuota            ,
		   tipo_cuota             ,
		   capital_mto_cuota      ,
		   capital_debe           ,
		   capital_pagado         ,
		   capital_status         ,
		   capital_status_ant     ,
		   capital_fecha_pago     ,
		   interes_debe           ,
		   interes_pagado         ,
		   interes_status         ,
		   interes_status_ant     ,
		   interes_fecha_pago     ,
		   iva_debe               ,
		   iva_pagado             ,
		   iva_status             ,
		   iva_status_ant         ,
		   iva_fecha_pago         ,
		   mora_provi_ordi        ,
		   mora_provi_cope        ,
		   mora_sdo_ordi          ,
		   mora_sdo_ordi_pag      ,
		   mora_sdo_cope          ,
		   mora_sdo_cope_pag      ,
		   mora_bonificado        ,
		   mora_status            ,
		   mora_iva_debe          ,
		   mora_iva_pagado        ,
		   mora_iva_status        ,
		   mora_iva_fecha_pago    ,
		   num_pago               ,
		   campo_trabajo1         ,
		   campo_trabajo2         ,
		   campo_trabajo3         ,
		   campo_trabajo4   )
	SELECT 
		   empresa                ,
		   g_folio                ,
		   num_credito            ,
		   fecha_cuota            ,
		   tipo_cuota             ,
		   capital_mto_cuota      ,
		   capital_debe           ,
		   capital_pagado         ,
		   capital_status         ,
		   capital_status_ant     ,
		   capital_fecha_pago     ,
		   interes_debe           ,
		   interes_pagado         ,
		   interes_status         ,
		   interes_status_ant     ,
		   interes_fecha_pago     ,
		   iva_debe               ,
		   iva_pagado             ,
		   iva_status             ,
		   iva_status_ant         ,
		   iva_fecha_pago         ,
		   mora_provi_ordi        ,
		   mora_provi_cope        ,
		   mora_sdo_ordi          ,
		   mora_sdo_ordi_pag      ,
		   mora_sdo_cope          ,
		   mora_sdo_cope_pag      ,
		   mora_bonificado        ,
		   mora_status            ,
		   mora_iva_debe          ,
		   mora_iva_pagado        ,
		   mora_iva_status        ,
		   mora_iva_fecha_pago    ,
		   num_pago               ,
		   campo_trabajo1         ,
		   campo_trabajo2         ,
		   campo_trabajo3         ,
		   campo_trabajo4
	 FROM sd_amortiza_credito
	 WHERE empresa     = g_empresa
	   and Num_credito = g_numcredito;
	--------------------------------------
	END IF;
   RETURN CodRet;

END PROCEDURE                                                                   
DOCUMENT
'Este SPL realiza el respaldo de las tablas de Credito involucradas',
'En el pago, para poder efectuar su reversion',
'AUTOR : Raul Mendoza D nes',
'FECHA : 20/Octubre/2003',
'BD    : BDICRED';

CREATE PROCEDURE "informix".principalrefer(p_Empresa  CHAR(3),
                           p_NumCredito             CHAR(20),
                           p_TpPago                 SMALLINT, 
                           p_Tarjeta                CHAR(20),
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Folio                  LIKE sd_movdia.Folio_Suc,
                           p_Transacc               LIKE sd_movdia.Transacc_Suc,
                           p_MontoSBC               MONEY(14,2),
                           p_MontoEfe               MONEY(14,2),
                           p_referencia             char(40))
  --Valores a Regresar
      RETURNING CHAR(5),     -- Codigo de Retorno
             MONEY(14,2), -- Remanente
             MONEY(14,2), -- Interes Moratorio Cobrado
             MONEY(14,2), -- Interes Vencido Cobrado
             MONEY(14,2), -- Capital Vencido Cobrado
             MONEY(14,2), -- Interes Vigente Cobrado
             MONEY(14,2), -- Capital Vigente Cobrado
             MONEY(14,2), -- Impuesto Cobrado
             MONEY(14,2), -- Comisiones Cobradas
             MONEY(14,2)  -- Seguro Cobrado

 DEFINE GLOBAL g_sistema       CHAR(2)     DEFAULT '06';

   DEFINE CodRet                CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nRows                 SMALLINT;
   DEFINE Mensaje               CHAR(80);
   DEFINE wBegin                CHAR(1);
   DEFINE vfecha_hoy            DATE;
   
   DEFINE g_IntMoraCob   MONEY(14,2);
   DEFINE g_IntVencCob   MONEY(14,2);
   DEFINE g_CapVencCob   MONEY(14,2);
   DEFINE g_IntVigCob    MONEY(14,2);
   DEFINE g_CapVigCob    MONEY(14,2);
   DEFINE g_Impuesto     MONEY(14,2);
   DEFINE g_Comision     MONEY(14,2);
   DEFINE g_Seguro       MONEY(14,2);
   DEFINE g_Remanente    MONEY(14,2);
   DEFINE g_NumProducto   CHAR(4);
   DEFINE g_NumCte        CHAR(20);
   DEFINE v_NumCredito    CHAR(20);
   DEFINE vSdoTdc_Crds 	  		DECIMAL(14,2);	-- Cobro sdo a favor para pago PFSI
   DEFINE dFechaCreds	  		DATE;
   DEFINE cNum_Credisol	  		CHAR(20);
   DEFINE dCap_Credisol	  		DECIMAL(14,2);
   DEFINE dMntoPagoCredis 		DECIMAL(14,2);
   DEFINE cNumCredito_Crds		CHAR(20);
   DEFINE cCta_Eje_Crds        	CHAR(20);
   DEFINE cProducto_Crds       	CHAR(40);
   DEFINE cNum_Cte_Crds        	CHAR(20);
   DEFINE cNom_Cte_Crds        	CHAR(150);
   DEFINE dPago_Efec_Crds      	DECIMAL(18,2);
   DEFINE dPago_Cta_Crds       	DECIMAL(18,2);
   DEFINE dMonto_Op_Crds     	DECIMAL(18,2);
   DEFINE dSaldo_Actual_Crds   	DECIMAL(18,2);
   DEFINE cStatus_Actual_Crds  	CHAR(60);
   DEFINE dFecha_ProxPago_Crds	DATE;									  
									        

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      LET Mensaje = error_info;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
	     g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      --ROLLBACK WORK;
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

   
    --SET DEBUG FILE TO "/informix/mahr/principalrefer-"||p_Transacc||".out";     
    --TRACE ON;

   LET wBegin = "N";
   LET vSdoTdc_Crds 	= 0;
   LET dFechaCreds		= DATE(1);
   LET cNum_Credisol 	= '';
   LET dCap_Credisol 	= 0;   
   LET dMntoPagoCredis	= 0;
   
   LET cNumCredito_Crds		= '';
   LET cCta_Eje_Crds        = '';
   LET cProducto_Crds       = '';
   LET cNum_Cte_Crds        = '';
   LET cNom_Cte_Crds        = '';
   LET dPago_Efec_Crds      = 0;
   LET dPago_Cta_Crds       = 0;
   LET dMonto_Op_Crds     	= 0;
   LET dSaldo_Actual_Crds   = 0;
   LET cStatus_Actual_Crds  = '';
   LET dFecha_ProxPago_Crds	= DATE(1);

   BEGIN WORK;

   LET CodRet = "000";
   LET v_NumCredito = "";
   LET vfecha_hoy = "";
   LET g_Seguro =0;
   
   SELECT descripcion
     INTO Mensaje
     FROM bdinteg:"informix".si_codret
    WHERE sistema = g_sistema
      AND codigo_retorno = CodRet;
	  
   SELECT fecha_hoy INTO vfecha_hoy FROM "informix".sd_fechas;

   LET p_Empresa     = p_Empresa;
   LET g_Remanente   = 0;
   LET g_IntMoraCob  = 0;
   LET g_IntVencCob  = 0;
   LET g_CapVencCob  = 0;
   LET g_IntVigCob   = 0;
   LET g_CapVigCob   = 0;
   LET g_Impuesto    = 0;
   LET g_Comision    = 0;
   LET g_Seguro      = 0;   
   LET nRows         = 0;
   
   --**Se selecciona el producto
   IF length(p_NumCredito) = 16 THEN
      LET p_Tarjeta = p_NumCredito;

      SELECT num_credito 
        INTO v_NumCredito
        FROM "informix".sd_tarjeta
       WHERE num_tarjeta = p_NumCredito
         AND empresa     = p_Empresa; 
   ELSE
      LET v_NumCredito = p_NumCredito;
   END IF

   --Pago de TDC por Efectivo
    IF p_MontoEfe < 1 and p_Transacc = '0600' THEN
		if p_MontoEfe > 0 THEN 
			let CodRet = '399';
		ELSE
			let CodRet = '284';
		END IF;
    ELSE
      if p_MontoEfe > 0 then
            CALL "informix".Principal(
                p_Empresa,
                v_NumCredito,
                p_TpPago,
                p_MontoEfe,
                p_Usuario,
                p_Sucursal,
                p_Folio,
                p_Transacc
            )
            returning CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
                   g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;

            IF (CodRet <> "000") THEN
                SELECT descripcion
                INTO   Mensaje
                FROM   bdinteg:"informix".si_codret
                WHERE  sistema        = "06"
                AND    codigo_retorno = CodRet;
                ROLLBACK WORK;
                IF (wBegin = "S") THEN
                   BEGIN WORK;
                END IF;
            ELSE
				if ( p_Transacc = '8324') then  --Se graba clave de rastreo para movimientos de credito SPEI
                    UPDATE "informix".sd_movdia
                       SET referencia = p_referencia
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                elif ( p_Transacc = '6246') then  -- Graba referencia saldo buen cobro            
                    UPDATE "informix".sd_movdia
                       SET referencia23 = p_referencia,
                           nro_tarjeta = p_Tarjeta
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                else
                    UPDATE "informix".sd_movdia
                       SET nro_tarjeta = p_Tarjeta
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                end if;
				
				-- Pago de TDC termina correctamente. Realiza el cobro del saldo a favor si existe un PFSI activo (Sdo Inmediato - Apoyo 2020)
				SELECT sdo_cap_insoluto INTO vSdoTdc_Crds FROM bdicred:"informix".sd_maesdos WHERE empresa = p_Empresa AND num_credito = v_NumCredito;
				
				--IF vSdoTdc_Crds < -1 AND p_Transacc = '0600' THEN -- Solo entre cuando venga de pago tdc
				IF vSdoTdc_Crds < -1 THEN -- Solo entre cuando venga de pago tdc

					SELECT count(num_credito) INTO nRows FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND tipo_contrato = '3' AND status = 2;
					IF nRows > 0 THEN	-- Existe credisolucion vigente relacionado a la TDC
				  
						SELECT max(fecha) INTO dFechaCreds FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND tipo_contrato = '3' AND status = 2;
						SELECT num_sol_prestamo INTO cNum_Credisol FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND fecha = dFechaCreds AND tipo_contrato = '3' AND status = 2;
						SELECT nvl(sdo_cap_insoluto,0) INTO dCap_Credisol FROM bdicred:sd_maesdoscrd WHERE num_credito = cNum_Credisol;
						
						IF dCap_Credisol > 1 THEN	-- Aun se tiene deuda del credito 6900 y no vuelva a entrar en la 2da ejecucion del principalrefer 	
							IF abs(vSdoTdc_Crds) < dCap_Credisol THEN	-- El saldo excedente es menor que el monto de la deuda total del credito 6900. El excedente solo cubre parte del monto de deuda 6900
								LET dMntoPagoCredis = abs(vSdoTdc_Crds);
							ELSE										-- Parte del excedente cubre la deuda total del credito 6900
								LET dMntoPagoCredis = dCap_Credisol;
							END IF;
							
							-- Elimina el pago previo para casos iterativos y asÃÂ­ no sume el monto de ambos pagos a cargar a la tdc.
							SELECT count(folio) INTO nRows FROM bdicred:"informix".sd_montopagcrd WHERE folio = p_Folio;
							IF nRows > 0 THEN
								DELETE bdicred:"informix".sd_montopagcrd WHERE folio = p_Folio;
								LET nRows = 0;
							END IF;

							--EXECUTE PROCEDURE bdicred:sp_cs_pago_anticipado(p_Empresa, cNum_Credisol, '6900', dMntoPagoCredis, 0, p_Usuario, p_Sucursal, p_Folio, '618')
							BEGIN WORK;
							EXECUTE PROCEDURE bdicred:sp_cs_pago_anticipado(p_Empresa, cNum_Credisol, '6900', dMntoPagoCredis, 0, p_Usuario, p_Sucursal, p_Folio, '8654')
							   INTO CodRet, Mensaje, cNumCredito_Crds, cCta_Eje_Crds, cProducto_Crds, cNum_Cte_Crds, cNom_Cte_Crds, dPago_Efec_Crds, dPago_Cta_Crds, 
									  dMonto_Op_Crds, dSaldo_Actual_Crds, cStatus_Actual_Crds, dFecha_ProxPago_Crds;
							IF CodRet::SMALLINT = 0 THEN
								-- Se actualiza remanente
								LET g_Remanente = g_Remanente;
								LET CodRet = "000";
							END IF;										
							
						END IF;
					END IF;  
					LET nRows = 0;
				END IF;    
				
           END IF
      END IF
	END IF;
/*
--jom ini
   else
	if p_MontoEfe > 0 THEN 
	        let CodRet = '399';
	ELSE
		let CodRet = '284';
	end if;
--jom fin
   END IF;
*/
   --Pago de TDC por Cheque
   IF p_MontoSBC > 0 THEN
   	--realiza la grabacion del Movimiento

      SELECT num_producto
        INTO g_NumProducto
        FROM "informix".sd_maecred
       WHERE empresa     = p_Empresa
         AND num_credito = v_NumCredito
		 AND status_cred      not in ('CV','FC','FF','FI')	
         AND (id_unidad_prod is null or id_unidad_prod <> 1);
		      
	 --2012-09-18 se valida que el credino no este marcado para venta en pago SBC.
	LET nrows = dbinfo("sqlca.sqlerrd2");
   IF (nrows = 0) THEN   
       LET CodRet = "008";     
    ELSE
	
		CALL "informix".Genmovref(
		p_Empresa,
		v_NumCredito,
		g_NumProducto,
		p_MontoSBC,
		p_Folio ,
		p_Sucursal,
        p_Tarjeta,
		p_referencia)

		RETURNing CodRet;
		
    END IF;          	
	
      
  	IF (CodRet <> "000") THEN
   	    SELECT descripcion
            INTO   Mensaje
       	    FROM   bdinteg:"informix".si_codret
       	    WHERE  sistema        = "06"
             AND   codigo_retorno = CodRet;
       	     ROLLBACK WORK;
       	     IF (wBegin = "S") THEN
                 BEGIN WORK;
       	     END IF;
        END IF
   END IF;

   RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
               g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
END PROCEDURE;