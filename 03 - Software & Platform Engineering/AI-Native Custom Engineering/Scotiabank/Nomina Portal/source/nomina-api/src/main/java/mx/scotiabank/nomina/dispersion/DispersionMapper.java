package mx.scotiabank.nomina.dispersion;

import java.util.List;
import mx.scotiabank.nomina.common.MaskingUtil;
import mx.scotiabank.nomina.common.MoneyMapper;
import mx.scotiabank.nomina.dispersion.dto.DispersionDtos.DispersionDetalleResponse;
import mx.scotiabank.nomina.dispersion.dto.DispersionDtos.DispersionResponse;
import mx.scotiabank.nomina.dispersion.dto.DispersionDtos.MovimientoResponse;

/** Mapea las entidades de dispersion a la API, enmascarando la CLABE (PCI). */
public final class DispersionMapper {

    private DispersionMapper() {
    }

    public static DispersionResponse toResponse(Dispersion d) {
        return new DispersionResponse(
                d.getIdDispersion().toString(),
                d.getIdNomina().toString(),
                d.getEstado(),
                MoneyMapper.toApi(d.getMontoDispersado()),
                d.getReferenciaInterna(),
                d.getFechaInstruccion());
    }

    public static DispersionDetalleResponse toDetalle(Dispersion d, List<MovimientoDispersion> movs) {
        List<MovimientoResponse> movimientos = movs.stream()
                .map(DispersionMapper::toMovimiento)
                .toList();
        return new DispersionDetalleResponse(
                d.getIdDispersion().toString(),
                d.getIdNomina().toString(),
                d.getEstado(),
                MoneyMapper.toApi(d.getMontoDispersado()),
                d.getReferenciaInterna(),
                d.getFechaInstruccion(),
                movimientos);
    }

    private static MovimientoResponse toMovimiento(MovimientoDispersion m) {
        return new MovimientoResponse(
                m.getIdEmpleado().toString(),
                MoneyMapper.toApi(m.getImporte()),
                MaskingUtil.maskClabe(m.getClabeDestino()),
                m.getEstado(),
                m.getReferenciaSPEI(),
                m.getCodigoRechazoBanxico());
    }
}
