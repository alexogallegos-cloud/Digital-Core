package com.openpay.api.riskfraud;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : risk-fraud
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 4    FAN-OUT : 7    LOC approx: 315
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.RskEntity;
import com.openpay.dto.RskRequest;

@Service
public class RskService173 {

    // Collaborators (match the graph call edges):
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final NotificationService notificationService;
    private final RskRepository046 rskRepository046;
    private final RskService008 rskService008;
    private final RskService131 rskService131;
    private final TokenizationService tokenizationService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
