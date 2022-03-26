package pingstatistic;
import akka.actor.AbstractActor;
import akka.japi.Pair;
import akka.japi.pf.ReceiveBuilder;
import java.util.HashMap;
import java.util.Map;

public class CacheActor extends AbstractActor{
    private final Map<String, Long> data = new HashMap<>();

    @Override
    public Receive createReceive() {
        return ReceiveBuilder.create()
                .match(Pair.class, this::findInCache)
                .match(StoreRequest.class, this::storeToCache)
                .build();
    }

    private void storeToCache(StoreRequest request) {
        data.put(request.getUrl(), request.getTime());
    }

    private void findInCache(Pair<String, Integer> request) {
        String url = request.first();
        sender().tell(
                new CacheResponse(
                        url,
                        data.containsKey(url) ? data.get(url) : -1L
                ),
                getSelf()
        );

    }

}
