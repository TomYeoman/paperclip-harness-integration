using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using ReweMappingService.Models;
using ReweMappingService.Services;
using ReweMappingService.Tests.Fakes;
using Xunit;

namespace ReweMappingService.Tests;

public class StoreDocsEndpointTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public StoreDocsEndpointTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    private (HttpClient client, FakeStoreDocumentRepository repo, FakeObservabilityService obs)
        CreateClient(Action<FakeStoreDocumentRepository>? seed = null)
    {
        var repo = new FakeStoreDocumentRepository();
        seed?.Invoke(repo);
        var obs = new FakeObservabilityService();

        var client = _factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                services.AddSingleton<IStoreDocumentRepository>(repo);
                services.AddSingleton<IObservabilityService>(obs);
            });
        }).CreateClient();

        return (client, repo, obs);
    }

    // S8: Feature flag ON — dynamic lookup replaces hardcoded URLs
    // REWE_TEST_999 must exist with a URL distinct from all Phase I hardcoded values
    [Fact]
    public async Task S8_KnownStore_ReturnsPdfUrl()
    {
        const string storeId = "REWE_TEST_999";
        const string expectedUrl = "https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/tcs.pdf";

        var (client, _, _) = CreateClient(repo => repo.Add(new StoreDocument(
            StoreId: storeId,
            TcsUrl: expectedUrl,
            PrivacyUrl: "https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/privacy.pdf",
            PdfUrl: expectedUrl
        )));

        var response = await client.GetAsync($"/store-docs/{storeId}");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<StoreDocsResponse>();
        Assert.NotNull(body);
        Assert.Equal(expectedUrl, body!.PdfUrl);
    }

    // S8: checkout.tcs_mapping_resolved fires with cloudinary_version_id and source=mapping_service
    [Fact]
    public async Task S8_KnownStore_EmitsMappingResolvedEvent_WithCloudinaryVersionId()
    {
        const string storeId = "REWE_TEST_999";
        const string tcsUrl = "https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/tcs.pdf";

        var (client, _, obs) = CreateClient(repo => repo.Add(new StoreDocument(
            StoreId: storeId,
            TcsUrl: tcsUrl,
            PrivacyUrl: "https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/privacy.pdf",
            PdfUrl: tcsUrl
        )));

        await client.GetAsync($"/store-docs/{storeId}");

        Assert.Single(obs.MappingResolvedEvents);
        var evt = obs.MappingResolvedEvents[0];
        Assert.Equal(storeId, evt.StoreId);
        Assert.Equal(tcsUrl, evt.TcsUrl);
        Assert.Equal("20260301", evt.CloudinaryVersionId);
    }

    // S5: Fallback — no store mapping exists — structured 404, not 5xx
    [Fact]
    public async Task S5_UnknownStore_Returns404WithStructuredError()
    {
        var (client, _, _) = CreateClient();

        var response = await client.GetAsync("/store-docs/REWE_UNMAPPED_STORE");

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<StoreNotFoundResponse>();
        Assert.NotNull(body);
        Assert.Equal("store_not_found", body!.Error);
    }

    // S5: checkout.tcs_links_missing fires for unknown store
    [Fact]
    public async Task S5_UnknownStore_EmitsLinksMissingEvent()
    {
        var (client, _, obs) = CreateClient();

        await client.GetAsync("/store-docs/REWE_UNMAPPED_STORE");

        Assert.Single(obs.LinksMissingEvents);
        Assert.Equal("REWE_UNMAPPED_STORE", obs.LinksMissingEvents[0].StoreId);
    }

    // S5: structured not-found is NOT a 5xx — verified already, but explicitly assert non-5xx
    [Fact]
    public async Task S5_UnknownStore_IsNotServerError()
    {
        var (client, _, _) = CreateClient();

        var response = await client.GetAsync("/store-docs/REWE_UNMAPPED_STORE");

        Assert.True((int)response.StatusCode < 500,
            $"Expected non-5xx for unknown store, got {(int)response.StatusCode}");
    }

    // S6: URL unreachable at checkout render — mapping service itself must still return 200 with pdf_url
    // (URL reachability is a client/checkout concern; this verifies the service returns valid data)
    [Fact]
    public async Task S6_KnownStore_ServiceReturnsPdfUrl_RegardlessOfUrlReachability()
    {
        const string storeId = "REWE_TEST_999";
        const string pdfUrl = "https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/tcs.pdf";

        var (client, _, _) = CreateClient(repo => repo.Add(new StoreDocument(
            StoreId: storeId,
            TcsUrl: pdfUrl,
            PrivacyUrl: "https://example.com/privacy.pdf",
            PdfUrl: pdfUrl
        )));

        var response = await client.GetAsync($"/store-docs/{storeId}");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<StoreDocsResponse>();
        Assert.NotNull(body);
        Assert.False(string.IsNullOrEmpty(body!.PdfUrl));
    }

    // S14: Mapping service unavailable — checkout degrades gracefully
    // The mapping service itself should never return 5xx for a known or unknown store.
    // 5xx would only occur on infrastructure failure — verified here via a known store path.
    [Fact]
    public async Task S14_KnownStore_NeverReturns5xx()
    {
        const string storeId = "REWE_TEST_999";

        var (client, _, _) = CreateClient(repo => repo.Add(new StoreDocument(
            StoreId: storeId,
            TcsUrl: "https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/tcs.pdf",
            PrivacyUrl: "https://example.com/privacy.pdf",
            PdfUrl: "https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/tcs.pdf"
        )));

        var response = await client.GetAsync($"/store-docs/{storeId}");

        Assert.True((int)response.StatusCode < 500,
            $"Expected non-5xx for known store, got {(int)response.StatusCode}");
    }

    // S14: Unknown store also never returns 5xx (structured 404 only)
    [Fact]
    public async Task S14_UnknownStore_NeverReturns5xx()
    {
        var (client, _, _) = CreateClient();

        var response = await client.GetAsync("/store-docs/REWE_UNMAPPED_STORE");

        Assert.True((int)response.StatusCode < 500,
            $"Expected structured 404, not 5xx, got {(int)response.StatusCode}");
    }

    // S8 seed data: REWE_TEST_999 URL must be distinct from Phase I hardcoded pilot values
    [Fact]
    public void S8_TestStore999_HasDistinctUrlFromPhaseIPilotValues()
    {
        var phaseIUrls = new[]
        {
            "https://res.cloudinary.com/jet-rewe/image/upload/v1/rewe/REWE_001/tcs.pdf",
            "https://res.cloudinary.com/jet-rewe/image/upload/v1/rewe/REWE_002/tcs.pdf",
            "https://res.cloudinary.com/jet-rewe/image/upload/v1/rewe/REWE_003/tcs.pdf",
            "https://res.cloudinary.com/jet-rewe/image/upload/v1/rewe/REWE_004/tcs.pdf",
            "https://res.cloudinary.com/jet-rewe/image/upload/v1/rewe/REWE_005/tcs.pdf",
            "https://res.cloudinary.com/jet-rewe/image/upload/v1/rewe/REWE_006/tcs.pdf"
        };

        var repo = new InMemoryStoreDocumentRepository();
        var testDoc = repo.FindByStoreId("REWE_TEST_999");

        Assert.NotNull(testDoc);
        Assert.DoesNotContain(testDoc!.PdfUrl, phaseIUrls);
    }

    // CloudinaryVersionExtractor unit tests
    [Theory]
    [InlineData("https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/tcs.pdf", "20260301")]
    [InlineData("https://res.cloudinary.com/jet-rewe/image/upload/v1/rewe/store/tcs.pdf", "1")]
    [InlineData("https://example.com/no-version/file.pdf", "")]
    public void CloudinaryVersionExtractor_ExtractsVersion(string url, string expected)
    {
        var result = CloudinaryVersionExtractor.Extract(url);
        Assert.Equal(expected, result);
    }
}
