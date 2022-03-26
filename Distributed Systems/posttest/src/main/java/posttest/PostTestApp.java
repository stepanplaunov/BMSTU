package posttest;

import akka.NotUsed;
import akka.actor.*;
import akka.actor.dsl.Creators;
import akka.http.javadsl.ConnectHttp;
import akka.http.javadsl.Http;
import akka.http.javadsl.IncomingConnection;
import akka.http.javadsl.ServerBinding;
import akka.http.javadsl.marshallers.jackson.Jackson;
import akka.http.javadsl.model.HttpRequest;
import akka.http.javadsl.model.HttpResponse;
import akka.http.javadsl.server.AllDirectives;
import akka.http.javadsl.server.Route;
import akka.pattern.Patterns;
import akka.stream.ActorMaterializer;
import akka.stream.javadsl.Flow;
import scala.concurrent.Future;
import java.io.IOException;
import java.util.concurrent.CompletionStage;

public class PostTestApp extends AllDirectives {
    public static final int SERVERPORT = 8080;
    public static final int TIMEOUT = 5000;
    public static void main(String[] args) throws IOException {
        ActorSystem system = ActorSystem.create("routes");
        final Http http = Http.get(system);
        final ActorMaterializer materializer = ActorMaterializer.create(system);
        PostTestApp instance = new PostTestApp();
        final Flow<HttpRequest, HttpResponse, NotUsed> routeFlow;
        routeFlow = instance.createRoute(system).flow(system, materializer);
        final CompletionStage<ServerBinding> binding = http.bindAndHandle(
                routeFlow,
                ConnectHttp.toHost("localhost", SERVERPORT),
                materializer
        );
        System.out.println("Server online at http://localhost:8080/\nPress RETURN to stop...");
        System.in.read();
        binding.thenCompose(ServerBinding::unbind).thenAccept(unbound -> system.terminate());
    }

    private Route createRoute(ActorSystem system) {
        ActorRef routerActor = system.actorOf(Props.create(RouterActor.class));
        return route(post(routerActor),
                    get(routerActor)
        );
    }
    private Route post(ActorRef routerActor) {
        return entity(Jackson.unmarshaller(Package.class),
                msg -> {
                    routerActor.tell(msg, ActorRef.noSender());
                    return complete("Test started!");
                }
        );
    }
    private Route get(ActorRef routerActor) {
        return parameter("packageId", packageID -> {
                Future<Object> result = Patterns.ask(
                        routerActor,
                        new PackageResultsRequest(Integer.parseInt(packageID)),
                        TIMEOUT
                );
                return completeOKWithFuture(result, Jackson.marshaller());
        });
    }
}


