// lib/api/mock/mock_db.dart
class MockDb {
  // ---- Products ----
  static final List<Map<String, dynamic>> products = [
    {"productId": "P#1", "name": "Cement 50kg", "price": 420},
    {"productId": "P#2", "name": "Steel Rod 10mm", "price": 680},
    {"productId": "P#3", "name": "Bricks", "price": 12},
  ];

  // ---- Distributors ----
  static final List<Map<String, dynamic>> distributors = [
    {
      "distributorId": "D001",
      "name": "ABC Traders",
      "zone": "ZONE_A",
      // goals by productId (amount based goal)
      "goals": {"P#1": 5000, "P#2": 8000, "P#3": 3000},
    },
    {
      "distributorId": "D002",
      "name": "XYZ Mart",
      "zone": "ZONE_B",
      "goals": {"P#1": 7000, "P#2": 6000, "P#3": 2500},
    },
  ];

  // ---- Orders/Bookings created by Sales Officer/Manager ----
  // booking = order meta + slot status
  static final List<Map<String, dynamic>> bookings = [
    {
      "bookingId": "BKG001",
      "orderId": "ORD1001",
      "createdByRole": "SALES OFFICER",
      "createdByPk": "SO#111",
      "distributorId": "D001",
      "distributorName": "ABC Traders",
      "items": [
        {"productId": "P#1", "name": "Cement 50kg", "price": 420, "qty": 5},
        {"productId": "P#2", "name": "Steel Rod 10mm", "price": 680, "qty": 3},
      ],
      "totalAmount": 5 * 420 + 3 * 680,
      "slotBooked": false,
      "slot": null,
      "createdAt": "2025-12-26T09:30:00Z",
      "tripId": "TRIP001", // multiple orders in one trip demo
    },
    {
      "bookingId": "BKG002",
      "orderId": "ORD1002",
      "createdByRole": "SALES OFFICER",
      "createdByPk": "SO#111",
      "distributorId": "D002",
      "distributorName": "XYZ Mart",
      "items": [
        {"productId": "P#3", "name": "Bricks", "price": 12, "qty": 200},
      ],
      "totalAmount": 12 * 200,
      "slotBooked": true,
      "slot": {
        "date": "2025-12-27",
        "time": "11:30",
        "vehicleType": "FULL",
        "pos": "A",
      },
      "createdAt": "2025-12-26T10:05:00Z",
      "tripId": "TRIP001",
    },
  ];

  // ---- Timeline per booking/order ----
  // unified tracking screen will read this
  static final Map<String, List<Map<String, dynamic>>> tracking = {
    "BKG001": [
      {
        "key": "ORDER_RECEIVED",
        "title": "Order received for ABC Traders (ORD1001)",
        "time": "2025-12-26T09:31:00Z",
      },
      {
        "key": "SLOT_NOT_BOOKED",
        "title": "Slot not booked yet for ABC Traders",
        "time": "2025-12-26T09:31:10Z",
      },
    ],
    "BKG002": [
      {
        "key": "ORDER_RECEIVED",
        "title": "Order received for XYZ Mart (ORD1002)",
        "time": "2025-12-26T10:06:00Z",
      },
      {
        "key": "SLOT_BOOKED",
        "title": "Slot booked for XYZ Mart",
        "time": "2025-12-26T10:10:00Z",
      },
    ],
  };

  // ---- Trips (NEW) ----
  static final Map<String, Map<String, dynamic>> trips = {
    "TRIP001": {
      "tripId": "TRIP001",
      "approved": false,
      "needsApproval": true, // ₹1,50,000 crossed na true
      "vehicle": null,
      "driver": null,
    },
  };
}
