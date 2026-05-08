// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

// Check on-hand inventory for an item across every site/warehouse.
// WarehousesOnHand lives in the `warehouse` submodule.

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.scm.common;
import ballerinax/microsoft.dynamics365.scm.warehouse;
import ballerinax/microsoft.dynamics365.scm.mock.server;

const string ITEM = "ITM-1001";

public function main() returns error? {
    http:Listener mockListener = check server:startMock();

    common:Connection conn = check new (
        config = {auth: {token: "demo-bearer-token"}},
        serviceUrl = "http://localhost:9091/data"
    );
    warehouse:Client wh = check new (conn);

    warehouse:WarehousesOnHandCollection snapshot = check wh->listWarehousesOnHand(queries = {
        filter: "ItemNumber eq '" + ITEM + "'"
    });

    warehouse:WarehouseOnHand[] rows = snapshot.value ?: [];
    io:println(string `On-hand for ${ITEM} (${rows.length()} locations):`);

    decimal total = 0d;
    foreach warehouse:WarehouseOnHand r in rows {
        decimal avail = r.AvailableOnHandQuantity ?: 0d;
        total += avail;
        io:println(string `  [${r.dataAreaId ?: ""}] site=${r.InventorySiteId ?: ""} wh=${r.InventoryWarehouseId ?: ""}   avail=${avail}  reserved=${r.ReservedOnHandQuantity ?: 0d}`);
    }
    io:println("");
    io:println(string `Total available: ${total}`);

    check mockListener.gracefulStop();
}
