package flightstatistic;
import org.apache.hadoop.io.WritableComparable;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

public class AirportWritableComparable implements WritableComparable<AirportWritableComparable> {
    private EntityType type;
    private int id;
    AirportWritableComparable(){}
    AirportWritableComparable(int id, EntityType type) {
        this.type = type;
        this.id = id;
    }
    public EntityType getType() {
        return type;
    }
    public int getId() {
        return id;
    }
    @Override
    public void readFields(DataInput in) throws IOException {
        this.id = in.readInt();
        this.type = EntityType.values()[in.readInt()];
    }
    @Override
    public void write(DataOutput out) throws IOException {
        out.writeInt(id);
        out.writeInt(type.ordinal());
    }
    @Override
    public int compareTo(AirportWritableComparable b) {
        Integer a = this.id - b.getId();
        Integer c = this.type.ordinal() - b.getType().ordinal();
        return (a == 0 ? c : a);
    }
}
