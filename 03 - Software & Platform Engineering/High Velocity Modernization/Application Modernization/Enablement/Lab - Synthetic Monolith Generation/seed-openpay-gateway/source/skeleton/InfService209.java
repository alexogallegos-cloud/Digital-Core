package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 8    FAN-OUT : 9    LOC approx: 798
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.InfEntity;
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService209 {

    // Collaborators (match the graph call edges):
    private final ApiKeyService apiKeyService;
    private final InfRepository022 infRepository022;
    private final InfRepository039 infRepository039;
    private final InfService185 infService185;
    private final InfService257 infService257;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final NotificationService notificationService;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
