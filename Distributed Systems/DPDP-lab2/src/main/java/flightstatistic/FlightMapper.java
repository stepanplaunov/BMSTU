package flightstatistic;
import java.io.IOException;

import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Mapper;

public class FlightMapper extends Mapper<LongWritable, Text, AirportWritableComparable, DataWritable> {
    @Override
    public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        if (key.get() == 0) {
            return;
        }
        DataWritable writable = new DataWritable(value.toString(), EntityType.FLIGHT);
        if (writable.getDelay() > Constants.ZERO && !writable.isCancelled()) {
            context.write(new AirportWritableComparable(writable.getId(), EntityType.FLIGHT), writable);
        }
    }
}