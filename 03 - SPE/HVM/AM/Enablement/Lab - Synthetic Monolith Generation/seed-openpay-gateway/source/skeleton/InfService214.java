package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 5    FAN-OUT : 10    LOC approx: 297
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfEntity;
import com.openpay.dto.InfRequest;
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService214 {

    // Collaborators (match the graph call edges):
    private final ChnService126 chnService126;
    private final ConfigService configService;
    private final InfRepository022 infRepository022;
    private final InfRepository039 infRepository039;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final NotificationService notificationService;
    private final TrmService256 trmService256;
    private final ValidationUtils validationUtils;
    private final VaultService vaultService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
