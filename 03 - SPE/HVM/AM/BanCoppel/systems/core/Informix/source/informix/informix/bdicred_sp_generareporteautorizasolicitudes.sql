CREATE PROCEDURE "informix".sp_generareporteautorizasolicitudes( cNumeroSolicitud Char(20))

Returning char(3) as CodRet,
char(20) as NoSolicitud, 
char(20) as NumCliente,
char(4) as Sucursal, 
char(40) as nombre_sucursal,
Char(45) as EjecutivoAutoriza, 
Date as FechaInsercion, 
char(500) as Justificacion,
char(52) as NombreCliente, 
char(26) as ApePaterno,
char(26) as ApeMaterno,
char(13) as RFC,
Char(45) as EjecutivoElabora,
CHAR(5) AS Cambios_status;

--Objetivo: Llenar el Reporte: rptRelacionFechasCierre.rpt cuando algun numero de
--                 solicitud haya sido Autorizado
--Proyecto: CConCAC
--Autor: Martin Valenzuela Ojeda
--Fecha: 2008-10-24
--modificacion: se agrego un nuevo campo de retorno, que se obtiene de la tabla ss_autorizacion_especial que contiene al ejecutivo que autoriza el cambio de status
--fecha: 2010-08-02
--modifico: jesus manuel aguilar heredia

Define cNumCte		Char(20);
Define cSucursal   Char(4);
Define cNombreSucursal Char(40);
Define cEjecutivoAutoriza Char(45);
Define cEjecutivoAnaliza Char(45);
Define dFechaInsert Date ;
Define cComentario Char(500);
Define cNombreCliente Char(52);
Define cApellidoPaterno Char(26);
Define cApellidoMaterno Char(26);
Define cRFC  Char(13);
DEfine vsqlerr Integer;
Define cCodRet Char(3);
Define cCambioStatus Char(5);

Let cNumCte = '';
Let cSucursal = '';
Let cNombreSucursal = '';
Let cEjecutivoAutoriza = '';
Let cEjecutivoAnaliza = '';
Let dFechaInsert = '';
Let cComentario = '';
Let cNombreCliente = '';
Let cApellidoPaterno = '';
Let cApellidoMaterno = '';
Let cRFC = '';
Let vsqlerr = 0;
Let cCodRet = '000';
Let cCambioStatus = '';

 --SET DEBUG FILE TO "/informix/jesus/sp_generareporteautorizasolicitudes.out";
 --TRACE ON;
Begin

ON EXCEPTION SET vsqlerr
    IF vsqlerr <> 0 THEN
        Let cCodRet = vsqlerr;
        Return cCodRet, " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " " ," ", " ";
    END IF;
END EXCEPTION;

--Validacion del Parametro
If (Trim(cNumeroSolicitud) = " ") Or (cNumeroSolicitud Is Null) Then
    Let cCodRet = '111';
    Return cCodRet, " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " " , " ", " ";
End If

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    --Esta Consulta es para llenar:
    --No de Cliente, Sucursal, Nombre del que Autoriza, Fecha de Autorizacion, la Justificacion de la solicitud (comentario)
 Select  NVL(sol.numcte, " "),  NVL(sol.sucursal, " "), NVL(suc.nombre, " "), NVL(eje.nombre, " "),
     NVL(aut.fecha_insert, " "),-- NVL(aut.comentario, " "),
     Trim(cli.nombre1) ||" "|| Trim(cli.nombre2),  Trim(cli.apell_paterno), Trim(cli.apell_materno), Trim(cli.rfc)
     Into cNumCte, cSucursal, cNombreSucursal, cEjecutivoAnaliza , dFechaInsert, /*cComentario,*/ cNombreCliente, cApellidoPaterno, cApellidoMaterno, cRFC
     From bdisolic:"informix".ss_solicitudes as sol
     Left Outer Join bdisolic:"informix".ss_autorizacion as aut On (sol.num_solicitud = aut.num_solicitud and sol.status_solicitud = aut.status_solicitud And aut.revision_cac in (2,4,5) And aut.fecha_insert= (Select Max(aut2.fecha_insert) from bdisolic:"informix".ss_autorizacion as aut2 Where aut2.num_solicitud = Trim(cNumeroSolicitud) and sol.status_solicitud = aut2.status_solicitud))
     Left Outer Join bdinteg:"informix".si_ejecut as eje On (eje.ejecutivo = aut.ejecutivo_auto)
     Left Outer Join bdinteg:"informix".si_cliente as cli On (cli.numcte = sol.numcte)
     Left Outer Join bdinteg:"informix".si_sucursales as suc On (sol.sucursal = suc.sucursal)
     Where sol.num_solicitud = Trim(cNumeroSolicitud);
	 
select NVL(eje.nombre, " "),NVL(esp.comentario, " "),TRIM(esp.status_ant)||"/"||TRIM(status_nvo)
into cEjecutivoAutoriza,cComentario,cCambioStatus
from bdinteg:"informix".si_ejecut eje
inner JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= esp.empresa
													   AND esp.num_solicitud= cNumeroSolicitud
													   AND esp.numcte=cNumCte
													   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
																			 FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
																			WHERE esp_aux.empresa= esp.empresa
																			  AND esp_aux.num_solicitud= cNumeroSolicitud
																			  AND esp_aux.numcte= cNumCte)
													   AND esp.usuario_modif=eje.ejecutivo);

                                                     

     Let cCodRet = '000';
     Return cCodRet, cNumeroSolicitud, cNumCte, cSucursal, cNombreSucursal, cEjecutivoAutoriza, dFechaInsert, cComentario, cNombreCliente, cApellidoPaterno, cApellidoMaterno, cRFC, cEjecutivoAnaliza,cCambioStatus;

End
End Procedure;