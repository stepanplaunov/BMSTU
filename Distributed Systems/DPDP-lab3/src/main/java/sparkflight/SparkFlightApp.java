package sparkflight;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.broadcast.Broadcast;
import scala.Tuple2;

import java.util.Map;

import java.util.Iterator;

import static scala.None.iterator;

public class SparkFlightApp {
    private static final String AIRPORT_DELIMITER = ",\"";
    private static final String FLIGHT_DELIMITER = ",";
    private static final String PATTERN = "MaxDelay: %f, CancelledPercent: %f, DelayedPercent: %f";
    private static final String RESULTPATTERN = "OriginalAirport: %s, DestinationAirport: %s, %s";
    private static final String QUOTE = "\"";

    private static JavaRDD<String> dataPrepare(JavaSparkContext sc, String arg) {
        JavaRDD<String> data = sc.textFile(arg);
        String dataHeader = data.first();
        data = data.filter(x -> !x.equals(dataHeader));
        return data;
    }

    private static String deleteSymbol(String data, String symbol) {
        return data.replaceAll(symbol, "");
    }

    private static JavaPairRDD<Tuple2<Integer, Integer>, FlightSerializable> flightToPair(JavaRDD<String> flights) {
        return flights.mapToPair(
                line -> {
                    String[] data = line.split(FLIGHT_DELIMITER);
                    int destinationAirport = Integer.parseInt(deleteSymbol(data[Constants.DESTINATION_AIRPORT_ID], QUOTE));
                    float delay = data[Constants.ARR_DELAY].length() > 0 ? Float.parseFloat(data[Constants.ARR_DELAY]) : Constants.ZERO;
                    boolean cancelled = Float.parseFloat(data[Constants.IS_CANCELED]) == 1;
                    int originAirport = Integer.parseInt(deleteSymbol(data[Constants.ORIGIN_AIRPORT_ID], QUOTE));
                    return new Tuple2<>(new Tuple2<>(originAirport, destinationAirport),
                            new FlightSerializable(originAirport, destinationAirport, delay, cancelled));
                }
        );
    }

    private static JavaPairRDD<Integer, String> airportToPair(JavaRDD<String> airport) {
        return airport.mapToPair(
                line -> {
                    String[] data = line.split(AIRPORT_DELIMITER);
                    int code = Integer.parseInt(deleteSymbol(data[Constants.CODE], QUOTE));
                    String description = deleteSymbol(data[Constants.DESCRIPTION], QUOTE);
                    return new Tuple2<>(code, description);
                }
        );
    }

    public static void main(String[] args) {
        SparkConf conf = new SparkConf().setAppName("lab3");
        JavaSparkContext sc = new JavaSparkContext(conf);
        JavaRDD<String> flights = dataPrepare(sc, args[1]);
        JavaRDD<String> airports = dataPrepare(sc, args[2]);
        JavaPairRDD<Tuple2<Integer, Integer>, FlightSerializable> flightRDD = flightToPair(flights);
        JavaPairRDD<Integer, String> airportRDD = airportToPair(airports);
        final Broadcast<Map<Integer, String>> airportBroadcasted = sc.broadcast(airportRDD.collectAsMap());
//        flightRDD.groupByKey().mapValues(
//                flightsArray ->{
//                    float cancelledCounter = Constants.ZERO;
//                    float delayedCounter = Constants.ZERO;
//                    float max = Float.MIN_VALUE;
//                    int counter = Constants.ZERO;
//                    float delay;
//                    for (FlightSerializable flight : flightsArray) {
//                        cancelledCounter += (flight.isCancelled()) ? 1 : Constants.ZERO;
//                        delay = flight.getDelay();
//
//                        if (delay > Constants.ZERO) {
//                            max = Float.max(max, delay);
//                            delayedCounter++;
//                        }
//                        counter++;
//                    }
//                    return String.format(PATTERN, max, cancelledCounter / counter * 100,    delayedCounter / counter * 100);
//                })
        flightRDD.combineByKey(
                        x -> new StatContainer(
                                x.getDelay(),
                                x.isCancelled() ? 1 : 0,
                                x.getDelay() > 0 ? 1 : 0,
                                1
                        ),
                        (statContainer, y) -> StatContainer.addValue(
                                statContainer,
                                y.getDelay(),
                                y.isCancelled(),
                                y.getDelay()
                        ),
                        StatContainer::add
                )
                .map(flight -> {
                    Tuple2<Integer, Integer> flightKey = flight._1;
                    Map<Integer, String> value = airportBroadcasted.value();
                    return String.format(RESULTPATTERN, value.get(flightKey._1), value.get(flightKey._2), flight._2.compareStat());
                })
                .saveAsTextFile(args[0]);

    }
}
