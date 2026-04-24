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

import ballerina/http;
import ballerina/test;
import ballerinax/microsoft.dynamics365.scm.mock.server;

const int MOCK_PORT = 9091;
const string MOCK_URL = "http://localhost:9091/data";

http:Listener mockListener = check new (MOCK_PORT);
Client scmClient = check new (
    config = {auth: {token: "demo-bearer-token"}},
    serviceUrl = MOCK_URL
);

@test:BeforeSuite
function startMockServer() returns error? {
    mockListener = check server:startMock({port: MOCK_PORT, contextBase: MOCK_URL + "/"});
}

@test:AfterSuite
function stopMockServer() returns error? {
    check mockListener.gracefulStop();
}

@test:Config
function testListReleasedProducts() returns error? {
    ReleasedProductsV2Collection response = check scmClient->listReleasedProductsV2();
    ReleasedProductV2[] rows = <ReleasedProductV2[]>response.value;
    test:assertTrue(rows.length() >= 2);
}

@test:Config
function testListWarehouses() returns error? {
    WarehousesCollection response = check scmClient->listWarehouses();
    Warehouse[] rows = <Warehouse[]>response.value;
    test:assertTrue(rows.length() >= 2);
}

@test:Config
function testListWarehousesOnHandForItem() returns error? {
    WarehousesOnHandCollection response = check scmClient->listWarehousesOnHand(
        queries = {filter: "ItemNumber eq 'ITM-1001'"}
    );
    WarehouseOnHand[] rows = <WarehouseOnHand[]>response.value;
    test:assertTrue(rows.length() >= 2);
    foreach WarehouseOnHand r in rows {
        test:assertEquals(r.ItemNumber, "ITM-1001");
    }
}

@test:Config
function testCreateSalesOrderHeader() returns error? {
    SalesOrderHeaderV2 draft = {
        dataAreaId: "USMF",
        SalesOrderNumber: "SO-DEMO-001"
    };
    SalesOrderHeaderV2 created = check scmClient->createSalesOrderHeadersV2(payload = draft);
    test:assertEquals(created.SalesOrderNumber, "SO-DEMO-001");
    test:assertTrue(created["@odata.etag"] is string);
}

@test:Config
function testUnmappedEntityReturnsEmpty() returns error? {
    // InventoryMovementJournalHeaders exists in the spec but has no stub
    // data in the mock; should still return an empty collection cleanly.
    InventoryMovementJournalHeadersCollection response = check scmClient->listInventoryMovementJournalHeaders();
    InventoryMovementJournalHeader[] rows = <InventoryMovementJournalHeader[]>response.value;
    test:assertEquals(rows.length(), 0);
}
