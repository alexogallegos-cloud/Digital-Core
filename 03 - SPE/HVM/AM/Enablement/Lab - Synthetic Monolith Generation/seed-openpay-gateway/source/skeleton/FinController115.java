package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : WEB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 3    LOC approx: 180
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AccountingEntry;
import com.openpay.dto.AuditContext;
import com.openpay.dto.FinEntity;
import com.openpay.dto.FinResponse;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@RestController
public class FinController115 {

    // Collaborators (match the graph call edges):
    private final FinService110 finService110;
    private final FinService140 finService140;
    private final FinService151 finService151;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
