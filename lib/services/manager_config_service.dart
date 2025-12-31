class ManagerConfigService {
  static int vehicles = 4;
  static int tripsPerVehicle = 3;

  static int get totalTrips => vehicles * tripsPerVehicle;
}
