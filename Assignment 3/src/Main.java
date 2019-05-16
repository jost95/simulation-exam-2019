import java.util.List;

public class Main {
    private static double getMean(List<Integer> qHist) {
        int totalQueue = 0;
        int measurements = qHist.size();

        for (int q : qHist) {
            totalQueue += q;
        }

        return (double) totalQueue / measurements;
    }

    private static double getVar(double mean, List<Integer> qHist) {
        double varSum = 0;
        int measurements = qHist.size();

        for (int q : qHist) {
            varSum += Math.pow(q-mean,2);
        }

        return varSum / measurements;
    }

    private static double getCovar(double mean1, double mean2, List<Integer> qHist1, List<Integer> qHist2) {
        double covarSum = 0;
        int measurements = qHist1.size();

        for (int i = 0; i < measurements; i++) {
            covarSum += (qHist1.get(i)-mean1)*(qHist2.get(i)-mean2);
        }

        return covarSum / measurements;
    }

    private static String calcConfInt(List<Integer> qHist1, List<Integer> qHist2) {
        int measurements = qHist1.size();
        double mean1 = Main.getMean(qHist1);
        double mean2 = Main.getMean(qHist2);
        double var1 = Main.getVar(mean1, qHist1);
        double var2 = Main.getVar(mean2, qHist2);
        double covar = Main.getCovar(mean1, mean2, qHist1, qHist2);

        double avgMean = (mean1 + mean2)/2;
        double avgVar = (var1 + var2 + 2*covar)/4;
        double avgStdDev = Math.sqrt(avgVar);
        double delta = 1.96 * (avgStdDev / Math.sqrt(measurements));

        return avgMean + " +- " + delta;
    }

    public static void main(String[] args) {
        List<Integer> qHist1;
        List<Integer> qHist2;
        Simulation sim = new Simulation();

        System.out.println("Regular simulation");
        sim.seedOn();
        sim.run();
        qHist1 = sim.getQueueHistory();
        sim.reset();
        sim.seedOn();
        sim.run();
        qHist2 = sim.getQueueHistory();

        System.out.println("Regular simulation results: " + Main.calcConfInt(qHist1, qHist2));

        System.out.println("Antithetic run");
        sim.reset();
        sim.seedOn();
        sim.run();
        qHist1 = sim.getQueueHistory();
        sim.reset();
        sim.seedOn();
        sim.antheticOn();
        sim.run();
        qHist2 = sim.getQueueHistory();

        System.out.println("Antithetic simulation results: " + Main.calcConfInt(qHist1, qHist2));
    }
}
