package mx.scotiabank.nomina.nomina;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

/**
 * Parser del layout de nomina. En el mock soporta un CSV simple
 * ({@code idEmpleado,clabeDestino,importe} por linea, encabezado opcional). El
 * soporte de Excel/TXT bancario real lo desarrolla una story dedicada (M6); la
 * firma no cambia.
 *
 * <p>El parser NO valida reglas de negocio — solo estructura de archivo. La
 * validacion (RN-03/RN-04/RN-05) ocurre en {@link NominaService#validar}.
 */
@Component
public class LayoutParser {

    public List<DetalleNomina> parse(UUID idNomina, MultipartFile archivo) {
        List<DetalleNomina> renglones = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(archivo.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            boolean first = true;
            while ((line = reader.readLine()) != null) {
                if (line.isBlank()) {
                    continue;
                }
                String[] cols = line.split(",");
                // Salta encabezado si la primera columna no es un UUID.
                if (first && !esUuid(cols[0].trim())) {
                    first = false;
                    continue;
                }
                first = false;
                if (cols.length < 3) {
                    continue;
                }
                UUID idEmpleado = UUID.fromString(cols[0].trim());
                String clabeDestino = cols[1].trim();
                BigDecimal importe = new BigDecimal(cols[2].trim());
                renglones.add(DetalleNomina.de(idNomina, idEmpleado, clabeDestino, importe));
            }
        } catch (IOException e) {
            throw new IllegalArgumentException("No se pudo leer el layout: " + e.getMessage());
        }
        return renglones;
    }

    private static boolean esUuid(String s) {
        try {
            UUID.fromString(s);
            return true;
        } catch (IllegalArgumentException ex) {
            return false;
        }
    }
}
