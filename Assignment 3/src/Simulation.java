import java.util.ArrayList;
import java.util.List;
import java.util.Random;

class Simulation {
    private static final int ARRIVAL = 1;
    private static final int DEPARTURE = 2;
    private static final int MEASURE = 3;
    private static final int SIM_LENGTH = 1000000;

    private double time;
    private EventList eventList;
    private Server[] servers;
    private Random serviceRand;
    private Random arrivalRand;

    private int queue;
    private int inSystem;
    private boolean antithetic;
    private List<Integer> systemHistory;

    Simulation() {
        reset();
    }

    void reset() {
        time = 0;
        eventList = new EventList();
        servers = new Server[2];
        servers[0] = new Server(0);
        servers[1] = new Server(1);
        arrivalRand = new Random();
        serviceRand = new Random();
        inSystem = 0;
        queue = 0;
        systemHistory = new ArrayList<>();
        antithetic = false;

    }

    void seedOn() {
        serviceRand = new Random(0);
    }

    void antheticOn() {
        antithetic = true;
    }

    private void handleEvent(Event event) {
        switch (event.getType()) {
            case ARRIVAL:
                handleArrival();
                break;
            case DEPARTURE:
                handleDeparture(event.getServer());
                break;
            case MEASURE:
                handleMeasurement();
                break;
        }
    }

    private void handleArrival() {
        inSystem++;
        boolean serverFound = false;

        // Check if can be served right away
        for (Server server : servers) {
            if (server.available) {
                serverFound = true;
                server.available = false;
                eventList.put(new Event(DEPARTURE, getNextDeparture(), server.index));
                break;
            }
        }

        if (!serverFound) {
            queue++;
        }

        eventList.put(new Event(ARRIVAL, getNextArrival()));
    }

    private void handleDeparture(int index) {
        inSystem--;

        if (queue == 0) {
            servers[index].available = true;
        } else {
            queue--;
            eventList.put(new Event(DEPARTURE, getNextDeparture(), index));
        }
    }

    private void handleMeasurement() {
        systemHistory.add(inSystem);
        eventList.put(new Event(MEASURE, getNextMeasurement()));
    }

    private double getNextArrival() {
        double meanArrival = 1.2;
        return time - Math.log(1 - arrivalRand.nextDouble()) * meanArrival;
    }

    private double getNextDeparture() {
        return time + getServiceRand() * 2;
    }

    private double getNextMeasurement() {
        return time + 10;
    }

    private double getServiceRand() {
        return antithetic ? 1 - serviceRand.nextDouble() : serviceRand.nextDouble();
    }

    List<Integer> getSystemHistory() {
        return systemHistory;
    }

    void run() {
        System.out.print("Starting... ");

        eventList.put(new Event(ARRIVAL, getNextArrival()));
        eventList.put(new Event(MEASURE, time + 100));

        while (time < SIM_LENGTH) {
            Event event = eventList.pop();
            time = event.getTime();
            handleEvent(event);
        }

        System.out.println("finished");
    }

    private class Server {
        private int index;
        private boolean available;

        private Server(int index) {
            this.index = index;
            this.available = true;
        }
    }
}
