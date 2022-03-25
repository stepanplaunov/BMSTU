package flightstatistic;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;
import java.util.Iterator;

public class FlightReducer extends Reducer<AirportWritableComparable, DataWritable, Integer, Text> {
    private static final String pattern = "Name: %s Min: %f, Max: %f, Average: %f";
    @Override
    protected void reduce(AirportWritableComparable key, Iterable<DataWritable> values, Context context) throws IOException, InterruptedException {
        Iterator<DataWritable> iter = values.iterator();
        Text name = new Text(iter.next().getDescription());
        float min = Float.MAX_VALUE;
        float max = Float.MIN_VALUE;
        float average = Constants.ZERO;
        float counter = Constants.ZERO;
        while (iter.hasNext()) {
            DataWritable flight = iter.next();
            float arrDelay = flight.getDelay();
            counter++;
            average += arrDelay;
            min = Math.min(arrDelay, min);
            max = Math.max(arrDelay, max);
        }
        if (counter > Constants.ZERO) {
            context.write(key.getId(), new Text(String.format(pattern, name, min, max, average / counter)));
        }
    }
}

