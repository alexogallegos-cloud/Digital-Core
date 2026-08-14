package com.openpay.dashboard.merchants;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : merchants
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 1    FAN-OUT : 8    LOC approx: 534
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.MerEntity;
import com.openpay.dto.MerResponse;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Service
public class MerService132 {

    // Collaborators (match the graph call edges):
    private final AuditLogger auditLogger;
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final MerRepository066 merRepository066;
    private final MerRepository087 merRepository087;
    private final MerService086 merService086;
    private final MerService142 merService142;
    private final MoneyUtils moneyUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
