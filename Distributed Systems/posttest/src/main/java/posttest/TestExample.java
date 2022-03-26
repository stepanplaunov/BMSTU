package posttest;

import akka.NotUsed;
import akka.actor.ActorSystem;
import akka.stream.ActorMaterializer;
import akka.stream.javadsl.*;

import java.io.IOException;
import java.util.Arrays;
import java.util.concurrent.CompletionStage;


public class TestExample {
    public static void main(String[] args) throws IOException {
        ActorSystem system = ActorSystem.create("test");
        ActorMaterializer mat = ActorMaterializer.create(system);

        Source<Integer, NotUsed> source = Source.from(Arrays.asList(1, 2, 3, 4, 5));
        Flow<Integer, Integer, NotUsed> increment = Flow.of(Integer.class).map(x -> x + 1);
        Sink<Integer, CompletionStage<Integer>> fold = Sink.fold(0, (agg, next) -> agg + next);

        RunnableGraph<CompletionStage<Integer>> runnableGraph = source.via(increment).toMat(fold, Keep.right());
        CompletionStage<Void> result = runnableGraph.run(mat).thenAccept(i -> System.out.println("result=" + i)).thenAccept((v) -> system.terminate());
    }
}
