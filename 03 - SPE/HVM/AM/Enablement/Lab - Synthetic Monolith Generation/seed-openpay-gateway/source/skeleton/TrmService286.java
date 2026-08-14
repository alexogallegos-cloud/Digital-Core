package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 10    LOC approx: 597
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmRequest;

@Service
public class TrmService286 {

    // Collaborators (match the graph call edges):
    private final ApiKeyService apiKeyService;
    private final ConfigService configService;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final NotificationService notificationService;
    private final RbacService rbacService;
    private final StringUtils stringUtils;
    private final TrmRepository030 trmRepository030;
    private final TrmService256 trmService256;
    private final TrmService266 trmService266;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
