package com.openpay.api.riskfraud;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : risk-fraud
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 6    FAN-OUT : 7    LOC approx: 398
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.RskEntity;

@Service
public class RskService158 {

    // Collaborators (match the graph call edges):
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final NotificationService notificationService;
    private final RskRepository011 rskRepository011;
    private final RskService032 rskService032;
    private final RskService138 rskService138;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
