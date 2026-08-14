package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : WEB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 3    LOC approx: 135
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.FinRequest;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@RestController
public class FinController114 {

    // Collaborators (match the graph call edges):
    private final ConfigService configService;
    private final FinService133 finService133;
    private final TokenizationService tokenizationService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
