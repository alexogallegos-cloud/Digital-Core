package mx.scotiabank.nomina.dispersion;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DispersionRepository extends JpaRepository<Dispersion, UUID> {
    Optional<Dispersion> findByIdNomina(UUID idNomina);
}
