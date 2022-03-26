package zkanonymizer;

import akka.NotUsed;
import akka.actor.ActorRef;
import akka.actor.ActorSystem;
import akka.actor.Props;
import akka.http.javadsl.ConnectHttp;
import akka.http.javadsl.Http;
import akka.http.javadsl.ServerBinding;
import akka.http.javadsl.marshalling.Marshaller;
import akka.http.javadsl.marshallers.jackson.Jackson;
import akka.http.javadsl.model.HttpRequest;
import akka.http.javadsl.model.HttpResponse;
import akka.http.javadsl.model.StatusCode;
import akka.http.javadsl.model.Uri;
import akka.http.javadsl.server.AllDirectives;
import akka.http.javadsl.server.Route;
import akka.http.scaladsl.model.StatusCodes;
import akka.japi.Pair;
import akka.pattern.Patterns;
import akka.stream.ActorMaterializer;
import akka.stream.javadsl.Flow;
import org.apache.zookeeper.*;
import scala.concurrent.Future;

import java.io.IOException;
import java.time.Duration;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.ExecutionException;


import static akka.pattern.PatternsCS.pipe;
import static akka.actor.TypedActor.context;

public class ServerNode extends AllDirectives {
    private static ActorRef config;
    private static Integer port;
    private static ActorSystem system;
    private static ZkWatcher watcher;
    public static void main(String[] args) throws IOException, InterruptedException, KeeperException {
        port = Integer.parseInt(args[0]);
        system = ActorSystem.create("routes");
        ///url = args[0];system = ActorSystem.create("routes");
        config = system.actorOf(Props.create(ConfigStorageActor.class));
        watcher = new ZkWatcher(config);
        ZooKeeper zoo = new ZooKeeper("127.0.0.1:2181", 3000, watcher);
            watcher.setZk(zoo);
        zoo.create("/servers/s",
                port.toString().getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE ,
                CreateMode.EPHEMERAL_SEQUENTIAL
        );
        final Http http = Http.get(system);
        final ActorMaterializer materializer = ActorMaterializer.create(system);
        ServerNode instance = new ServerNode();
        final Flow<HttpRequest, HttpResponse, NotUsed> routeFlow;
        routeFlow = instance.createRoute(system).flow(system, materializer);
        final CompletionStage<ServerBinding> binding = http.bindAndHandle(
                routeFlow,
                ConnectHttp.toHost("localhost", port),
                materializer
        );
        System.out.println(String.format("Server online at http://localhost:%d/\nPress RETURN to stop...", port));
        System.in.read();
        binding.thenCompose(ServerBinding::unbind).thenAccept(unbound -> system.terminate());
    }

    private Route createRoute(ActorSystem system) {
        return route(
                get()
        );
    }

    private Route get() {
        return parameter("url", url ->
                    parameter("count", count -> {
                        int counter = Integer.parseInt(count);
                        final Http http = Http.get(system);
                        if (counter == 0) {
                            return completeWithFuture(http.singleRequest(HttpRequest.create(url)));
                        }
                        return
                                completeWithFuture(
                                        http.singleRequest(
                                                HttpRequest.create(
                                                    String.format("http://localhost:%d/?url=%s&count=%d",
                                                            Integer.parseInt(
                                                                    (String) Patterns
                                                                            .ask(
                                                                                    config,
                                                                                    new ServerRequest(),
                                                                                    Duration.ofMillis(3000)
                                                                            )
                                                                            .toCompletableFuture()
                                                                            .join()),
                                                            url,
                                                            counter - 1
                                                    )
                                                )
                                        )
                                );
                    })
        );
    }
}
