#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include <iomanip>
#include <limits>

class Ride {
protected:
    std::string rideID;
    std::string pickupLocation;
    std::string dropoffLocation;
    double distance; //mile

public:
    Ride(std::string id, std::string pickup, std::string dropoff, double miles)
        : rideID(std::move(id)),
          pickupLocation(std::move(pickup)),
          dropoffLocation(std::move(dropoff)),
          distance(miles) {}

    virtual ~Ride() = default;

    // Polymorphic interface
    virtual double fare() const = 0; // must be overriden
    virtual std::string rideDetails() const {
        return "Ride[" + rideID + "] " + pickupLocation + " -> " + dropoffLocation +
               " (" + std::to_string(distance) + " mi)";
    }
};

class StandardRide : public Ride {
public:
    using Ride::Ride; //inherit constructor
    double fare() const override {
        double f = distance * 1.5;
        return f < 2.0 ? 2.0 : f;
    }
    std::string rideDetails() const override {
        return "Standard " + Ride::rideDetails();
    }
};

class PremiumRide : public Ride {
public:
    using Ride::Ride;
    double fare() const override {
        return 5.0 + distance * 3.00;
    }
    std::string rideDetails() const override {
        return "Premium " + Ride::rideDetails();
    }
};

class Driver {
private:
    std::string driverID;
    std::string name;
    double rating;
    // Encapsulation: private list of rides
    std::vector<std::shared_ptr<Ride>> assignedRides;

public:
    Driver(std::string id, std::string nm, double rt)
        : driverID(std::move(id)),
          name(std::move(nm)),
          rating(rt) {}

    void addRide(const std::shared_ptr<Ride>& ride) {
        assignedRides.push_back(ride);
    }

    std::string getDriverInfo() const {
        std::string info = "Driver[" + driverID + "] " + name +
                           " | Rating: " + std::to_string(rating) +
                           " | Rides: " + std::to_string(assignedRides.size());
        return info;
    }

    void printRides() const {
        std::cout << getDriverInfo() << "\n";
        for (const auto& r : assignedRides) {
            std::cout << " - " << r->rideDetails()
                      << " | Fare: $" << std::fixed << std::setprecision(2) << r->fare() << "\n";
        }
    }
};

class Rider {
private:
    std::string riderID;
    std::string name;
    // Encapsulation: private history
    std::vector<std::shared_ptr<Ride>> requestedRides;

public:
    Rider(std::string id, std::string nm)
        : riderID(std::move(id)), name(std::move(nm)) {}

    void requestRide(const std::shared_ptr<Ride>& ride) {
        requestedRides.push_back(ride);
    }

    void viewRides() const {
        std::cout << "Rider[" << riderID << "] " << name
                  << " | Requested rides: " << requestedRides.size() << "\n";
        for (const auto& r : requestedRides) {
            std::cout << "  - " << r->rideDetails()
                      << " | Fare: $" << std::fixed << std::setprecision(2) << r->fare() << "\n";
        }
    }
};

int main() {
    std::cout << ">>> Program started <<<\n";

    // Make a polymorphic list of rides
    std::vector<std::shared_ptr<Ride>> rides;
    rides.push_back(std::make_shared<StandardRide>("R1001", "Downtown", "Airport", 12.3));
    rides.push_back(std::make_shared<PremiumRide>("R1002", "Mall", "Stadium", 5.0));
    rides.push_back(std::make_shared<StandardRide>("R1003", "Campus", "Museum", 1.0));

    // Polymorphism demo: same interface, different implementations
    std::cout << "=== Polymorphic Ride Summary ===\n";
    for (const auto& r : rides) {
        std::cout << r->rideDetails()
                  << " | Fare: $" << std::fixed << std::setprecision(2) << r->fare() << "\n";
    }

    // Driver & Rider demos (encapsulation of ride lists)
    Driver d1("D-01", "Olivia", 4.93);
    d1.addRide(rides[0]);
    d1.addRide(rides[2]);

    Rider u1("U-77", "Nam Tran");
    u1.requestRide(rides[1]);

    std::cout << "\n=== Driver Info ===\n";
    d1.printRides();

    std::cout << "\n=== Rider History ===\n";
    u1.viewRides();

    std::cout << "\n>>> Program finished. Press Enter to exit <<<\n";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    std::cin.get();

    return 0;
}
