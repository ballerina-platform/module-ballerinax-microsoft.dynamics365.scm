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

// Stub data for highlighted entity sets. Other entity sets return empty.

final readonly & json[] releasedProducts = [
    {
        "@odata.etag": "W/\"Jzs7MDs7MCcp\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1001"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7MScp\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1002"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7MicpCw==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-2001"
    }
];

final readonly & json[] warehouses = [
    {
        "@odata.etag": "W/\"Jzs7MDs7NCcpCw==\"",
        "dataAreaId": "USMF",
        "WarehouseId": "11"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7NScpCw==\"",
        "dataAreaId": "USMF",
        "WarehouseId": "12"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7NicpCw==\"",
        "dataAreaId": "USMF",
        "WarehouseId": "13"
    }
];

final readonly & json[] warehousesOnHand = [
    {
        "@odata.etag": "W/\"Jzs7MDs7NycpCw==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1001",
        "ProductColorId": "",
        "ProductConfigurationId": "",
        "ProductSizeId": "",
        "ProductStyleId": "",
        "InventorySiteId": "1",
        "InventoryWarehouseId": "11",
        "AvailableOnHandQuantity": 425.0,
        "ReservedOnHandQuantity": 25.0,
        "AvailableOrderedQuantity": 500.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7OCcpCw==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1001",
        "ProductColorId": "",
        "ProductConfigurationId": "",
        "ProductSizeId": "",
        "ProductStyleId": "",
        "InventorySiteId": "3",
        "InventoryWarehouseId": "13",
        "AvailableOnHandQuantity": 180.0,
        "ReservedOnHandQuantity": 0.0,
        "AvailableOrderedQuantity": 0.0
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7OScpCw==\"",
        "dataAreaId": "USMF",
        "ItemNumber": "ITM-1002",
        "ProductColorId": "",
        "ProductConfigurationId": "",
        "ProductSizeId": "",
        "ProductStyleId": "",
        "InventorySiteId": "1",
        "InventoryWarehouseId": "11",
        "AvailableOnHandQuantity": 88.0,
        "ReservedOnHandQuantity": 12.0,
        "AvailableOrderedQuantity": 60.0
    }
];

final readonly & json[] salesOrderHeadersV2 = [
    {
        "@odata.etag": "W/\"Jzs7MDs7QScpCw==\"",
        "dataAreaId": "USMF",
        "SalesOrderNumber": "SO-100045"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7QicpCw==\"",
        "dataAreaId": "USMF",
        "SalesOrderNumber": "SO-100046"
    }
];
