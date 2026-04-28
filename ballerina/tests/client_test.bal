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

// ---- ReleasedProductsV2 --------------------------------------------------

@test:Config
function testListReleasedProductsDefaultCompany() returns error? {
    ReleasedProductsV2Collection response = check scmClient->listReleasedProductsV2();
    ReleasedProductV2[] rows = <ReleasedProductV2[]>response.value;
    test:assertTrue(rows.length() >= 3);
    foreach ReleasedProductV2 p in rows {
        test:assertEquals(p.dataAreaId, "USMF");
    }
}

@test:Config
function testListReleasedProductsFilterEq() returns error? {
    ReleasedProductsV2Collection response = check scmClient->listReleasedProductsV2(
        queries = {filter: "ItemNumber eq 'ITM-1001'"}
    );
    ReleasedProductV2[] rows = <ReleasedProductV2[]>response.value;
    test:assertEquals(rows.length(), 1);
    test:assertEquals(rows[0].ItemNumber, "ITM-1001");
}

@test:Config
function testListReleasedProductsTopSkip() returns error? {
    ReleasedProductsV2Collection page = check scmClient->listReleasedProductsV2(
        queries = {top: 2, skip: 0, count: true}
    );
    ReleasedProductV2[] rows = <ReleasedProductV2[]>page.value;
    test:assertEquals(rows.length(), 2);
    int? total = <int?>page["@odata.count"];
    test:assertTrue(total is int && total >= 3);
}

@test:Config
function testCreateReleasedProductEchoes() returns error? {
    ReleasedProductV2 draft = {dataAreaId: "USMF", ItemNumber: "ITM-NEW"};
    ReleasedProductV2 created = check scmClient->createReleasedProductsV2(payload = draft);
    test:assertEquals(created.ItemNumber, "ITM-NEW");
    test:assertTrue(created["@odata.etag"] is string);
}

// ---- Warehouses ----------------------------------------------------------

@test:Config
function testListWarehouses() returns error? {
    WarehousesCollection response = check scmClient->listWarehouses();
    Warehouse[] rows = <Warehouse[]>response.value;
    test:assertTrue(rows.length() >= 3);
}

@test:Config
function testListWarehousesFilterEq() returns error? {
    WarehousesCollection response = check scmClient->listWarehouses(
        queries = {filter: "WarehouseId eq '11'"}
    );
    Warehouse[] rows = <Warehouse[]>response.value;
    test:assertEquals(rows.length(), 1);
    test:assertEquals(rows[0].WarehouseId, "11");
}

// ---- WarehousesOnHand (the demo-critical read) ---------------------------

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
function testListWarehousesOnHandCount() returns error? {
    WarehousesOnHandCollection response = check scmClient->listWarehousesOnHand(queries = {count: true});
    int? count = <int?>response["@odata.count"];
    test:assertTrue(count is int && count >= 3);
}

@test:Config
function testListWarehousesOnHandSelect() returns error? {
    WarehousesOnHandCollection response = check scmClient->listWarehousesOnHand(
        queries = {selectFields: "ItemNumber,AvailableOnHandQuantity", top: 1}
    );
    WarehouseOnHand[] rows = <WarehouseOnHand[]>response.value;
    test:assertEquals(rows.length(), 1);
    test:assertTrue(rows[0].ItemNumber is string);
}

// ---- SalesOrderHeadersV2 -------------------------------------------------

@test:Config
function testListSalesOrderHeadersV2() returns error? {
    SalesOrderHeadersV2Collection response = check scmClient->listSalesOrderHeadersV2();
    SalesOrderHeaderV2[] rows = <SalesOrderHeaderV2[]>response.value;
    test:assertTrue(rows.length() >= 2);
}

@test:Config
function testCreateSalesOrderEchoes() returns error? {
    SalesOrderHeaderV2 draft = {
        dataAreaId: "USMF",
        SalesOrderNumber: "SO-DEMO-001"
    };
    SalesOrderHeaderV2 created = check scmClient->createSalesOrderHeadersV2(payload = draft);
    test:assertEquals(created.SalesOrderNumber, "SO-DEMO-001");
    test:assertTrue(created["@odata.etag"] is string);
}

@test:Config
function testGetSalesOrderV2MissingKeyReturns404() returns error? {
    SalesOrderHeaderV2|error result = scmClient->getSalesOrderHeadersV2(
        dataAreaId = "USMF",
        salesOrderNumber = "DOES-NOT-EXIST"
    );
    test:assertTrue(result is error);
}

// ---- Unmapped entities ---------------------------------------------------

@test:Config
function testListUnmappedEntityReturnsEmpty() returns error? {
    // InventoryMovementJournalHeaders is in the spec but has no stub data;
    // mock should still return an empty collection cleanly.
    InventoryMovementJournalHeadersCollection response =
            check scmClient->listInventoryMovementJournalHeaders();
    InventoryMovementJournalHeader[] rows = <InventoryMovementJournalHeader[]>response.value;
    test:assertEquals(rows.length(), 0);
}

@test:Config
function testListNegativeTopIsIgnored() returns error? {
    ReleasedProductsV2Collection response = check scmClient->listReleasedProductsV2(queries = {top: -1});
    ReleasedProductV2[] rows = <ReleasedProductV2[]>response.value;
    test:assertTrue(rows.length() > 0, "negative \\$top should be ignored, not panic");
}
