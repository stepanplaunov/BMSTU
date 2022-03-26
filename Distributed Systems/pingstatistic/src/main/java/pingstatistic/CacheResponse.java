package pingstatistic;

public class CacheResponse {
    private final String url;
    private final Long time;

    public String getUrl() {
        return url;
    }

    public Long getTime() {
        return time;
    }


    public CacheResponse(String url, Long time) {
        this.url = url;
        this.time = time;
    }
}